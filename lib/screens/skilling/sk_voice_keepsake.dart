// =============================================================================
//  "Your voice, saved" — the voice keepsake: a store, a record sheet, a screen
// -----------------------------------------------------------------------------
//  The Communication brief's practice keepsake: "she records a story or a
//  prompt, it keeps what she tried." Its instruction was to REUSE the
//  pregnancy journal's recorder ("record-in-your-voice and on-device save …
//  do NOT build a second recording system"). What exists — `_VoiceRecordSheet`
//  in `lib/widgets/journal/journal_create.dart` — records on the phone and
//  then UPLOADS every clip to Supabase Storage through `JournalStore.saveAudio`,
//  and is welded to `PregnancyController`. Right for a mother's journal; for
//  a child's voice it breaks the shell's consent line ("nothing about her is
//  sent anywhere") on the strength of a consent that is still a stub.
//
//  So this is the user's call (2026-09-15, question 1, option a): the SAME
//  mechanism — the `record` and `audioplayers` packages, the same sheet
//  shape — with the cloud call left out. Not a second recording system; the
//  first one without its upload. The pregnancy file is untouched. When a real
//  consent adapter exists and a parent has consented to cloud storage as a
//  separate line, the cloud copy is a backend job (a child-scoped bucket,
//  RLS, retention, a delete that deletes) — see `BACKEND-PATTERNS.md` §16a.
//
//  ⚠️ WHAT THE STORE EXPOSES, AND WHAT IT DOES NOT. Clips, by door, newest
//  first; a record; a delete; forget-all (with consent). No count, no total
//  minutes, no "you recorded N times" — the keepsake's rule holds for sound
//  as it does for words. A clip is a title, a file and a day.
//
//  ⚠️ NO CHILD DATA LEAVES THE PHONE. Files live under the app's documents
//  folder (`skilling/voice/`); the index is `shared_preferences`; nothing
//  imports `SupabaseRepo` or `StorageService`.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/bracket_resolver.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_child_store.dart';
import 'sk_content.dart';
import 'sk_practice_store.dart';

/// One saved clip.
class SkVoiceClip {
  const SkVoiceClip({
    required this.id,
    required this.doorId,
    required this.title,
    required this.path,
    required this.at,
    this.itemId,
  });
  final String id;
  final String doorId;

  /// What she recorded: the activity's title, or "Something I wanted to say".
  final String title;
  final String path;
  final DateTime at;

  /// The activity it belongs to, when it does.
  final String? itemId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'door': doorId,
        'title': title,
        'path': path,
        'at': at.toIso8601String(),
        'item': itemId,
      };

  static SkVoiceClip? fromJson(Map<String, dynamic> j) {
    final at = DateTime.tryParse((j['at'] ?? '') as String);
    if (at == null) return null;
    return SkVoiceClip(
      id: (j['id'] ?? '') as String,
      doorId: (j['door'] ?? '') as String,
      title: (j['title'] ?? '') as String,
      path: (j['path'] ?? '') as String,
      at: at,
      itemId: j['item'] as String?,
    );
  }
}

class SkVoiceStore extends ChangeNotifier {
  SkVoiceStore._();
  static final SkVoiceStore instance = SkVoiceStore._();

  static const _key = 'sk_voice';

  final List<SkVoiceClip> _clips = [];
  bool _loaded = false;

  /// Her clips for a door, newest first.
  List<SkVoiceClip> clipsFor(String doorId) {
    final list = [for (final c in _clips) if (c.doorId == doorId) c]
      ..sort((a, b) => b.at.compareTo(a.at));
    return list;
  }

  bool hasClips(String doorId) => _clips.any((c) => c.doorId == doorId);

  /// Where clips live. One folder, so forget-all is one directory.
  static Future<Directory> folder() async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/skilling/voice');
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  void add(SkVoiceClip clip) {
    _clips.add(clip);
    _save();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    final i = _clips.indexWhere((c) => c.id == id);
    if (i < 0) return;
    final c = _clips.removeAt(i);
    try {
      final f = File(c.path);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
    _save();
    notifyListeners();
  }

  /// Withdrawn with consent — see `SkChildStore.forget`. Deletes the files.
  Future<void> forgetAll() async {
    for (final c in _clips) {
      try {
        final f = File(c.path);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
    _clips.clear();
    _save();
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _clips.clear();
    _loaded = true;
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      for (final j in (jsonDecode(raw) as List)) {
        final c = SkVoiceClip.fromJson(Map<String, dynamic>.from(j));
        if (c != null) _clips.add(c);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode([for (final c in _clips) c.toJson()]));
    } catch (_) {}
  }
}

// =============================================================================
//  The record sheet
// =============================================================================

/// Open the recorder for a door, optionally for one activity. Resolves true
/// when a clip was saved.
Future<bool> skRecordVoice(
  BuildContext context, {
  required String doorId,
  String? itemId,
  String? title,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: V2PaletteStore.instance.current.ground,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (_) => _RecordSheet(doorId: doorId, itemId: itemId, title: title),
  );
  return saved ?? false;
}

class _RecordSheet extends StatefulWidget {
  const _RecordSheet({required this.doorId, this.itemId, this.title});
  final String doorId;
  final String? itemId;
  final String? title;

  @override
  State<_RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<_RecordSheet> {
  final AudioRecorder _rec = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _recording = false;
  bool _playing = false;
  bool _noMic = false;
  String? _path;

  @override
  void dispose() {
    _rec.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_recording) {
      final path = await _rec.stop();
      if (!mounted) return;
      setState(() {
        _recording = false;
        _path = path;
      });
      return;
    }
    if (!await _rec.hasPermission()) {
      if (mounted) setState(() => _noMic = true);
      return;
    }
    final dir = await SkVoiceStore.folder();
    final path = '${dir.path}/v_${DateTime.now().microsecondsSinceEpoch}.m4a';
    await _rec.start(const RecordConfig(), path: path);
    if (mounted) {
      setState(() {
        _recording = true;
        _noMic = false;
        _path = null;
      });
    }
  }

  Future<void> _play() async {
    final p = _path;
    if (p == null) return;
    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    await _player.play(DeviceFileSource(p));
    if (!mounted) return;
    setState(() => _playing = true);
    _player.onPlayerComplete.first.then((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  void _save() {
    final p = _path;
    if (p == null) return;
    SkVoiceStore.instance.add(SkVoiceClip(
      id: 'v_${DateTime.now().microsecondsSinceEpoch}',
      doorId: widget.doorId,
      title: widget.title ?? 'Something I wanted to say',
      path: p,
      at: DateTime.now(),
      itemId: widget.itemId,
    ));
    Navigator.of(context).pop(true);
  }

  Future<void> _discard() async {
    final p = _path;
    if (p != null) {
      try {
        final f = File(p);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final has = _path != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                    color: p.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text('YOUR VOICE',
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: p.action)),
            const SizedBox(height: 6),
            Text(widget.title ?? 'Say it in your voice',
                style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: p.ink1)),
            const SizedBox(height: 6),
            Text(
                _noMic
                    ? 'The microphone is off. A grown-up can turn it on in the '
                        'phone\'s settings.'
                    : _recording
                        ? 'Recording. Tap the big button when you are done.'
                        : has
                            ? 'Listen back, then keep it or try again.'
                            : 'Tap the big button and start talking. It stays '
                                'on this phone.',
                style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2)),
            const SizedBox(height: 22),
            Center(
              child: Material(
                color: _recording ? const Color(0xFFFF5A79) : p.action,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: const Key('sk-voice-record'),
                  onTap: _toggle,
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: Icon(
                        _recording ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 44,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (has && !_recording) ...[
              Row(children: [
                Expanded(
                  child: _Button(
                    label: _playing ? 'Stop' : 'Listen back',
                    icon: _playing
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    p: p,
                    onTap: _play,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Button(
                    label: 'Try again',
                    icon: Icons.replay_rounded,
                    p: p,
                    onTap: () async {
                      await _player.stop();
                      await _discardFile();
                      if (mounted) {
                        setState(() {
                          _path = null;
                          _playing = false;
                        });
                      }
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: kSkTap,
                child: FilledButton(
                  key: const Key('sk-voice-save'),
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                      backgroundColor: p.action,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: Text('Keep it',
                      style: pvManrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _discard,
                  child: Text('Not this one',
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink3)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _discardFile() async {
    final p = _path;
    if (p == null) return;
    try {
      final f = File(p);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
  }
}

class _Button extends StatelessWidget {
  const _Button(
      {required this.label,
      required this.icon,
      required this.p,
      required this.onTap});
  final String label;
  final IconData icon;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: kSkTap,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.line),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 20, color: p.action),
              const SizedBox(width: 8),
              Text(label,
                  style: pvManrope(
                      fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
            ]),
          ),
        ),
      );
}

// =============================================================================
//  The screen — her clips, then the words
// =============================================================================

class SkVoiceKeepsakeScreen extends StatefulWidget {
  const SkVoiceKeepsakeScreen({super.key, required this.doorId});
  final String doorId;

  @override
  State<SkVoiceKeepsakeScreen> createState() => _SkVoiceKeepsakeScreenState();
}

class _SkVoiceKeepsakeScreenState extends State<SkVoiceKeepsakeScreen> {
  final AudioPlayer _player = AudioPlayer();
  String? _playingId;

  @override
  void initState() {
    super.initState();
    SkVoiceStore.instance.load();
    SkPracticeStore.instance.load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(SkVoiceClip c) async {
    if (_playingId == c.id) {
      await _player.stop();
      setState(() => _playingId = null);
      return;
    }
    await _player.stop();
    await _player.play(DeviceFileSource(c.path));
    if (!mounted) return;
    setState(() => _playingId = c.id);
    _player.onPlayerComplete.first.then((_) {
      if (mounted) setState(() => _playingId = null);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          V2PaletteStore.instance,
          SkVoiceStore.instance,
          SkPracticeStore.instance,
          SkChildStore.instance,
        ]),
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final clips = SkVoiceStore.instance.clipsFor(widget.doorId);
    final lines = SkPracticeStore.instance.entriesFor(widget.doorId);
    final name = SkChildStore.instance.name;
    final title = bracketById(widget.doorId)?.title.now ?? '';
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            skBack(context, p),
            const SizedBox(height: 18),
            if (title.isNotEmpty)
              Text(title.toUpperCase(),
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: p.action)),
            const SizedBox(height: 8),
            Text('Your voice, saved',
                style: pvFraunces(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1.18,
                    color: p.ink1)),
            const SizedBox(height: 10),
            Text(
                'The stories and things ${name.isEmpty ? 'you' : name} said out '
                'loud, and what ${name.isEmpty ? 'you' : 'she'} tried. It all '
                'stays on this phone.',
                style: pvManrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: p.ink2)),
            const SizedBox(height: 22),
            // ⚠️ OFF UNTIL A PARENT TURNS IT ON. The tasks' rule. The screen
            // still exists (a feature is never hidden); what it shows is the
            // invitation, addressed to the grown-up, not a record button.
            if (!SkChildStore.instance.voiceAllowed)
              Container(
                key: const Key('sk-voice-off'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.lock_outline_rounded, size: 20, color: p.ink2),
                  const SizedBox(height: 10),
                  Text('Recording is off.',
                      style: pvFraunces(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: p.ink1)),
                  const SizedBox(height: 6),
                  Text('A grown-up can turn it on under "For the grown-up". '
                      'Recordings stay on this phone and can be deleted any '
                      'time.',
                      style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2)),
                ]),
              )
            else
              _Button(
                label: 'Record something',
                icon: Icons.mic_rounded,
                p: p,
                onTap: () => skRecordVoice(context, doorId: widget.doorId),
              ),
            const SizedBox(height: 24),
            if (clips.isEmpty && SkChildStore.instance.voiceAllowed)
              Container(
                key: const Key('sk-voice-empty'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.line),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.mic_none_rounded, size: 22, color: p.action),
                  const SizedBox(height: 10),
                  Text('Nothing recorded yet, and that is fine.',
                      style: pvFraunces(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: p.ink1)),
                  const SizedBox(height: 6),
                  Text('Tell a story, describe something, or say what you '
                      'think. Tap Record something and it lands here.',
                      style: pvManrope(fontSize: 15, height: 1.5, color: p.ink2)),
                ]),
              )
            else
              for (final c in clips) ...[
                _ClipRow(
                  clip: c,
                  p: p,
                  playing: _playingId == c.id,
                  onPlay: () => _play(c),
                  onDelete: () => SkVoiceStore.instance.remove(c.id),
                ),
                const SizedBox(height: 10),
              ],
            if (lines.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text('What you tried',
                  style: pvFraunces(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      height: 1.22,
                      color: p.ink1)),
              const SizedBox(height: 12),
              for (final l in lines) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.line),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.title,
                        style: pvManrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: p.ink1)),
                    const SizedBox(height: 3),
                    Text(l.word,
                        style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2)),
                  ]),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ClipRow extends StatelessWidget {
  const _ClipRow({
    required this.clip,
    required this.p,
    required this.playing,
    required this.onPlay,
    required this.onDelete,
  });
  final SkVoiceClip clip;
  final V2Palette p;
  final bool playing;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final d = clip.at;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Row(children: [
        Material(
          color: playing ? p.action : v2BlockTint(26, p),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPlay,
            child: SizedBox(
              width: kSkTap,
              height: kSkTap,
              child: Icon(playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 26, color: playing ? Colors.white : p.ink1),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(clip.title,
                style: pvManrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: p.ink1)),
            const SizedBox(height: 3),
            Text('${d.day} ${_months[d.month - 1]}',
                style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2)),
          ]),
        ),
        IconButton(
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline_rounded, size: 20, color: p.ink3),
          tooltip: 'Remove',
        ),
      ]),
    );
  }
}
