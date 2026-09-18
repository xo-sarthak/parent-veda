// =============================================================================
//  Her private journal — on this phone, encrypted, hers
// -----------------------------------------------------------------------------
//  The Feelings brief: "Her private journal: the harder feelings, written
//  down — Journal — care: most sensitive data in the app." And the rules,
//  verbatim: "the journal is on-device only, encrypted at rest, never
//  uploaded · NEVER analyse, score, sentiment-read or profile a child's
//  feelings or journal, by any means, AI or otherwise · journal contents
//  default to CHILD-PRIVATE (parent owns account, consent and deletion, but
//  does not read entries by default). This default is flagged for LEGAL
//  REVIEW against DPDP parental-consent rules · do NOT build any automated
//  distress/self-harm scanning of the journal."
//
//  The user's calls (2026-09-18): 1a child-private by default; 3a encrypted
//  with the AES the app already ships (`pointycastle`, made a direct
//  dependency).
//
//  ⚠️ WHAT THIS FILE IS, MECHANICALLY. The same on-device keepsake machinery
//  as the voice clips (`sk_voice_keepsake.dart`) — the brief's own
//  instruction: "the journal here and the voice keepsake there are two ways
//  to get feelings out, so reuse the same keepsake machinery." An index of
//  ids and dates in `shared_preferences` (no text in it); each entry's text
//  in its own file under documents/skilling/journal, AES-GCM encrypted with
//  a random 256-bit key; merge-by-id on load, as the walk of 2026-09-16
//  taught the voice store.
//
//  ⚠️ THE ONE PLACE THE TEXT IS EVER READ BACK is `read(id)`, and its only
//  caller is the screen that shows her own page to her. There is no
//  search, no word count, no sentiment, no export, no sync. A test scans
//  this file for those words.
//
//  ⚠️ KEY CUSTODY IS THE FLAGGED GAP. The key lives in `shared_preferences`
//  beside the index — encrypted data with its key on the same disk is a
//  lock with the key under the mat. The seam is `SkJournalKeyStore`; the
//  real implementation is the platform keystore (Android Keystore / iOS
//  Keychain, via `flutter_secure_storage` or equal), listed in the ledger
//  (FE10) and STILL-OPEN §103 as owed before anything ships. The cipher
//  itself is real today.
//
//  ⚠️ THE CRISIS PATHWAY IS A STUB, AND STOPS. See `sk_crisis_pathway.dart`.
// =============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/bracket_resolver.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_child_store.dart';
import 'sk_content.dart';
import 'sk_content_registry.dart';
import 'sk_safety.dart';

// =============================================================================
//  The key, and where it is kept
// =============================================================================

/// Where the journal's key lives. One implementation today
/// (`SkPrefsKeyStore`); the platform keystore is the one that ships.
abstract class SkJournalKeyStore {
  Future<Uint8List> key();
  Future<void> forget();
}

/// ⚠️ NOT FOR RELEASE: the key beside the data. The seam exists so the
/// keystore implementation is a swap, not a rewrite.
class SkPrefsKeyStore implements SkJournalKeyStore {
  static const _k = 'sk_journal_key';

  @override
  Future<Uint8List> key() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_k);
    if (raw != null) return base64Decode(raw);
    final r = Random.secure();
    final k = Uint8List.fromList(List.generate(32, (_) => r.nextInt(256)));
    await prefs.setString(_k, base64Encode(k));
    return k;
  }

  @override
  Future<void> forget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_k);
  }
}

// =============================================================================
//  The cipher — AES-256-GCM, a fresh nonce per entry
// =============================================================================

class SkJournalCipher {
  const SkJournalCipher(this.key);
  final Uint8List key;

  /// nonce (12 bytes) ‖ ciphertext ‖ tag (16 bytes).
  Uint8List seal(String text) {
    final r = Random.secure();
    final nonce = Uint8List.fromList(List.generate(12, (_) => r.nextInt(256)));
    final c = pc.GCMBlockCipher(pc.AESEngine())
      ..init(true, pc.AEADParameters(pc.KeyParameter(key), 128, nonce, Uint8List(0)));
    final out = c.process(Uint8List.fromList(utf8.encode(text)));
    return Uint8List.fromList([...nonce, ...out]);
  }

  /// Null when the bytes are not ours (wrong key, tampered, truncated).
  String? open(Uint8List bytes) {
    if (bytes.length < 12 + 16) return null;
    try {
      final nonce = bytes.sublist(0, 12);
      final c = pc.GCMBlockCipher(pc.AESEngine())
        ..init(false, pc.AEADParameters(pc.KeyParameter(key), 128, nonce, Uint8List(0)));
      return utf8.decode(c.process(bytes.sublist(12)));
    } catch (_) {
      return null;
    }
  }
}

// =============================================================================
//  The store
// =============================================================================

/// One page. The index holds only this — no text, no length, no words.
class SkJournalEntry {
  const SkJournalEntry({
    required this.id,
    required this.doorId,
    required this.at,
    required this.path,
    this.promptId,
  });
  final String id;
  final String doorId;
  final DateTime at;
  final String path;

  /// The prompt she wrote from, when she did.
  final String? promptId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'door': doorId,
        'at': at.toIso8601String(),
        'path': path,
        'prompt': promptId,
      };

  static SkJournalEntry? fromJson(Map<String, dynamic> j) {
    final at = DateTime.tryParse((j['at'] ?? '') as String);
    if (at == null) return null;
    return SkJournalEntry(
      id: (j['id'] ?? '') as String,
      doorId: (j['door'] ?? '') as String,
      at: at,
      path: (j['path'] ?? '') as String,
      promptId: j['prompt'] as String?,
    );
  }
}

class SkJournalStore extends ChangeNotifier {
  SkJournalStore._();
  static final SkJournalStore instance = SkJournalStore._();

  static const _key = 'sk_journal';

  /// The seam. Tests and the (future) keystore set it.
  SkJournalKeyStore keyStore = SkPrefsKeyStore();

  final List<SkJournalEntry> _entries = [];
  bool _loaded = false;

  /// Newest first. Dates and ids only; the text stays in its file until
  /// she opens the page.
  List<SkJournalEntry> entriesFor(String doorId) {
    final list = [for (final e in _entries) if (e.doorId == doorId) e]
      ..sort((a, b) => b.at.compareTo(a.at));
    return list;
  }

  bool hasEntries(String doorId) => _entries.any((e) => e.doorId == doorId);

  static Future<Directory> folder() async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/skilling/journal');
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  Future<SkJournalCipher> _cipher() async => SkJournalCipher(await keyStore.key());

  /// Seal the text to its own file, then index it. The text never touches
  /// `shared_preferences` and never leaves the device.
  Future<SkJournalEntry?> write(String doorId, String text, {String? promptId}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    try {
      final id = '${DateTime.now().microsecondsSinceEpoch}';
      final f = File('${(await folder()).path}/$id.enc');
      await f.writeAsBytes((await _cipher()).seal(trimmed), flush: true);
      final e = SkJournalEntry(
          id: id, doorId: doorId, at: DateTime.now(), path: f.path, promptId: promptId);
      _entries.add(e);
      await _save();
      notifyListeners();
      return e;
    } catch (_) {
      return null;
    }
  }

  /// Her page, for her. The only reader.
  Future<String?> read(String id) async {
    final i = _entries.indexWhere((e) => e.id == id);
    if (i < 0) return null;
    try {
      final f = File(_entries[i].path);
      if (!f.existsSync()) return null;
      return (await _cipher()).open(await f.readAsBytes());
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String id) async {
    final i = _entries.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final e = _entries.removeAt(i);
    try {
      final f = File(e.path);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
    await _save();
    notifyListeners();
  }

  /// The parent's one power over the journal: delete it all. Files, index,
  /// and the key — so nothing that was hers can be read back by anyone.
  Future<void> forgetAll() async {
    for (final e in _entries) {
      try {
        final f = File(e.path);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
    _entries.clear();
    await _save();
    try {
      await keyStore.forget();
    } catch (_) {}
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _entries.clear();
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
        final e = SkJournalEntry.fromJson(Map<String, dynamic>.from(j));
        if (e != null && !_entries.any((x) => x.id == e.id)) _entries.add(e);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode([for (final e in _entries) e.toJson()]));
    } catch (_) {}
  }
}

// =============================================================================
//  The screen — hers
// =============================================================================

/// Her journal: the pages she has written, newest first, and a place to
/// write. Speaks to the child. The safety bar is at its foot on the door
/// that carries one, and the trusted-adult line sits above the pages so
/// help is inside the journal, not only around it.
class SkJournalScreen extends StatefulWidget {
  const SkJournalScreen({super.key, required this.doorId});
  final String doorId;

  @override
  State<SkJournalScreen> createState() => _SkJournalScreenState();
}

class _SkJournalScreenState extends State<SkJournalScreen> {
  @override
  void initState() {
    super.initState();
    SkJournalStore.instance.load();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          V2PaletteStore.instance,
          SkJournalStore.instance,
          SkChildStore.instance,
        ]),
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final entries = SkJournalStore.instance.entriesFor(widget.doorId);
    final title = bracketById(widget.doorId)?.title.now ?? '';
    final safety = skDoorContentFor(widget.doorId)?.safety;
    return Scaffold(
      backgroundColor: p.ground,
      bottomNavigationBar: skSafetyBarFor(widget.doorId),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            Row(children: [skBack(context, p)]),
            const SizedBox(height: 18),
            if (title.isNotEmpty)
              Text(title.toUpperCase(),
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: p.action)),
            const SizedBox(height: 8),
            Text('Your journal',
                style: pvFraunces(
                    fontSize: kSkTitleSize,
                    fontWeight: FontWeight.w600,
                    height: 1.18,
                    color: p.ink1)),
            const SizedBox(height: 10),
            Text(
                'Yours. It stays on this phone, locked, and nobody reads it '
                'but you. Not a grown-up, not the app.',
                style: pvManrope(
                    fontSize: kSkLeadSize,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: p.ink2)),
            if (safety != null) ...[
              const SizedBox(height: 12),
              Text(safety.trustedAdultLine,
                  style: pvManrope(
                      fontSize: kSkBodySize,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: p.action)),
            ],
            const SizedBox(height: 22),
            _WriteButton(
              key: const Key('sk-journal-write'),
              p: p,
              onTap: () => _write(context, p),
            ),
            const SizedBox(height: 26),
            if (entries.isEmpty)
              Text('No pages yet. Write one whenever you like, about anything.',
                  key: const Key('sk-journal-empty'),
                  style: pvManrope(
                      fontSize: kSkBodySize,
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                      color: p.ink2))
            else
              for (final e in entries) ...[
                _PageRow(e: e, p: p, onTap: () => _open(context, p, e)),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _write(BuildContext context, V2Palette p) async {
    final ctl = TextEditingController();
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(22, 18, 22, 22 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('A new page',
              style: pvFraunces(fontSize: kSkHeadingSize, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 6),
          Text('Anything at all. Spelling does not matter. Nobody marks it.',
              style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink3)),
          const SizedBox(height: 14),
          TextField(
            key: const Key('sk-journal-field'),
            controller: ctl,
            autofocus: true,
            minLines: 5,
            maxLines: 12,
            style: pvManrope(fontSize: kSkBodySize, height: 1.5, color: p.ink1),
            decoration: InputDecoration(
              hintText: 'Today I felt…',
              filled: true,
              fillColor: p.ground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: kSkTap,
            child: FilledButton(
              key: const Key('sk-journal-save'),
              style: FilledButton.styleFrom(
                  backgroundColor: p.action,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () => Navigator.of(ctx).pop(ctl.text),
              child: Text('Keep it',
                  style: pvManrope(fontSize: kSkButtonSize, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
    if (text != null && text.trim().isNotEmpty) {
      await SkJournalStore.instance.write(widget.doorId, text);
    }
  }

  Future<void> _open(BuildContext context, V2Palette p, SkJournalEntry e) async {
    final text = await SkJournalStore.instance.read(e.id);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_when(e.at),
              style: pvManrope(
                  fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: p.action)),
          const SizedBox(height: 10),
          Flexible(
            child: SingleChildScrollView(
              child: Text(text ?? 'This page could not be opened.',
                  key: const Key('sk-journal-text'),
                  style: pvManrope(fontSize: kSkBodySize, height: 1.55, color: p.ink1)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            key: const Key('sk-journal-remove'),
            onPressed: () async {
              await SkJournalStore.instance.remove(e.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text('Tear this page out',
                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink3)),
          ),
        ]),
      ),
    );
  }

  static String _when(DateTime t) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${t.day} ${m[t.month - 1]} ${t.year}'.toUpperCase();
  }
}

class _WriteButton extends StatelessWidget {
  const _WriteButton({super.key, required this.p, required this.onTap});
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: kSkTap + 8,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.line)),
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 22, color: p.action),
              const SizedBox(width: 14),
              Text('Write a page',
                  style: pvManrope(
                      fontSize: kSkButtonSize, fontWeight: FontWeight.w700, color: p.ink1)),
            ]),
          ),
        ),
      );
}

class _PageRow extends StatelessWidget {
  const _PageRow({required this.e, required this.p, required this.onTap});
  final SkJournalEntry e;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: kSkTap),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Icon(Icons.lock_outline_rounded, size: 20, color: p.ink3),
              const SizedBox(width: 14),
              Expanded(
                child: Text('A page from ${_SkJournalScreenState._when(e.at)}',
                    style: pvManrope(
                        fontSize: kSkBodySize, fontWeight: FontWeight.w600, color: p.ink1)),
              ),
              Icon(Icons.chevron_right_rounded, size: 22, color: p.ink3),
            ]),
          ),
        ),
      );
}
