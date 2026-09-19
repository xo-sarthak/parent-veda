// =============================================================================
//  Her portfolio — a gallery that keeps what she made, and cannot score it
// -----------------------------------------------------------------------------
//  The Making brief: "Your portfolio: a gallery of what she made, photos of
//  art and recordings of music — Portfolio tool — single-source: reuses the
//  keepsake and recorder; photo capture is new; no score." Resolved as
//  "The rare door where the workbook's own tool survives untouched. A
//  portfolio, not a tracker: a gallery that keeps what she made. Reuses the
//  keepsake and recorder, adds photo capture. It cannot return a score."
//
//  So this screen COMPOSES what exists and adds one thing:
//    · photos of art and made things      — NEW, this file (the brief's
//                                           "ONE new capability")
//    · recordings of the music she makes  — the voice keepsake
//                                           (`sk_voice/<door>`), reused
//    · what she tried, did again and made — the shared keepsake
//                                           (`sk_keepsake/<door>`), reused
//    · Show it                            — the showcase, PRIVATE: a show
//                                           mode on this phone (the user's
//                                           call, 2026-09-18, 3a)
//
//  ⚠️ SAVED WORK IS PERSONAL DATA, THE SAME POSTURE AS VOICE. "A photo of a
//  child's art can still show her face or name … Parent-consented, on-device
//  where possible, minimal retention, parent-deletable, and never analysed
//  or profiled." So: behind the parent's separate switch
//  (`SkChildStore.photosAllowed`, off by default); the picked file copied
//  under documents/skilling/portfolio (the picker hands back a CACHE path
//  Android purges — `lib/memories/memory_photos.dart` learnt that the hard
//  way); an index of ids, dates and captions in prefs; merge-by-id on load;
//  no upload, no analysis, and NO "how good is this drawing" of any kind —
//  "that is a score. It is out."
//
//  ⚠️ NO LIKES, NO RANKING, NO FEATURED WALL, NO CROSS-USER GALLERY (the
//  user's call, 1a). The show mode is a full-screen pager to hand to Dadi
//  in the room. Nothing leaves the phone.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/bracket_resolver.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_child_store.dart';
import 'sk_content.dart';
import 'sk_content_registry.dart';
import 'sk_safety.dart';
import 'sk_voice_keepsake.dart';

// =============================================================================
//  The store — photos only; recordings and words live in their own stores
// =============================================================================

class SkPortfolioPhoto {
  const SkPortfolioPhoto({
    required this.id,
    required this.doorId,
    required this.path,
    required this.at,
    this.caption = '',
    this.itemId,
  });
  final String id;
  final String doorId;
  final String path;
  final DateTime at;

  /// Her words for it — "a tiger", "the fort we made" — or nothing.
  final String caption;

  /// The activity it came from, when it did.
  final String? itemId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'door': doorId,
        'path': path,
        'at': at.toIso8601String(),
        'caption': caption,
        'item': itemId,
      };

  static SkPortfolioPhoto? fromJson(Map<String, dynamic> j) {
    final at = DateTime.tryParse((j['at'] ?? '') as String);
    if (at == null) return null;
    return SkPortfolioPhoto(
      id: (j['id'] ?? '') as String,
      doorId: (j['door'] ?? '') as String,
      path: (j['path'] ?? '') as String,
      at: at,
      caption: (j['caption'] ?? '') as String,
      itemId: j['item'] as String?,
    );
  }
}

class SkPortfolioStore extends ChangeNotifier {
  SkPortfolioStore._();
  static final SkPortfolioStore instance = SkPortfolioStore._();

  static const _key = 'sk_portfolio';

  final List<SkPortfolioPhoto> _photos = [];
  bool _loaded = false;

  /// Newest first.
  List<SkPortfolioPhoto> photosFor(String doorId) {
    final list = [for (final p in _photos) if (p.doorId == doorId) p]
      ..sort((a, b) => b.at.compareTo(a.at));
    return list;
  }

  bool hasPhotos(String doorId) => _photos.any((p) => p.doorId == doorId);

  static Future<Directory> folder() async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/skilling/portfolio');
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  /// Copy the picked file out of the cache into documents, then index it.
  Future<SkPortfolioPhoto?> keep(String doorId, String pickedPath,
      {String caption = '', String? itemId}) async {
    try {
      final src = File(pickedPath);
      if (!src.existsSync()) return null;
      final id = '${DateTime.now().microsecondsSinceEpoch}';
      final ext = pickedPath.contains('.') ? pickedPath.split('.').last : 'jpg';
      final dst = File('${(await folder()).path}/$id.$ext');
      await src.copy(dst.path);
      final p = SkPortfolioPhoto(
          id: id, doorId: doorId, path: dst.path, at: DateTime.now(), caption: caption, itemId: itemId);
      _photos.add(p);
      await _save();
      notifyListeners();
      return p;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String id) async {
    final i = _photos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final p = _photos.removeAt(i);
    try {
      final f = File(p.path);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
    await _save();
    notifyListeners();
  }

  Future<void> forgetAll() async {
    for (final p in _photos) {
      try {
        final f = File(p.path);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
    _photos.clear();
    await _save();
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _photos.clear();
    _loaded = true;
  }

  @visibleForTesting
  void debugAdd(SkPortfolioPhoto p) {
    _photos.add(p);
    notifyListeners();
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      for (final j in (jsonDecode(raw) as List)) {
        final p = SkPortfolioPhoto.fromJson(Map<String, dynamic>.from(j));
        if (p != null && !_photos.any((x) => x.id == p.id)) _photos.add(p);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode([for (final p in _photos) p.toJson()]));
    } catch (_) {}
  }
}

// =============================================================================
//  Adding a photo — camera or gallery, a caption in her words, nothing else
// =============================================================================

/// Opens the picker, then a small sheet for her caption. Returns true when a
/// photo was kept. Plugin calls are guarded: on a phone without a camera,
/// or under `flutter test`, this simply returns false.
Future<bool> skAddPhoto(BuildContext context, {required String doorId, String? itemId}) async {
  final p = V2PaletteStore.instance.current;
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Keep a photo of it',
              style: pvFraunces(fontSize: kSkHeadingSize, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 6),
          Text('A drawing, a thing you built, anything you made. It stays on this phone.',
              style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink3)),
          const SizedBox(height: 14),
          _Row(
              key: const Key('sk-photo-camera'),
              label: 'Take a photo',
              icon: Icons.photo_camera_outlined,
              p: p,
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera)),
          const SizedBox(height: 10),
          _Row(
              key: const Key('sk-photo-gallery'),
              label: 'Pick one from the phone',
              icon: Icons.photo_library_outlined,
              p: p,
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery)),
        ]),
      ),
    ),
  );
  if (source == null || !context.mounted) return false;
  XFile? picked;
  try {
    picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
  } catch (_) {
    picked = null;
  }
  if (picked == null || !context.mounted) return false;
  final caption = await _askCaption(context, p);
  if (!context.mounted) return false;
  final kept = await SkPortfolioStore.instance.keep(doorId, picked.path, caption: caption ?? '', itemId: itemId);
  return kept != null;
}

Future<String?> _askCaption(BuildContext context, V2Palette p) {
  final ctl = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(22, 18, 22, 22 + MediaQuery.of(ctx).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('What is it?',
            style: pvFraunces(fontSize: kSkHeadingSize, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 6),
        Text('Your words. Or skip it.', style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink3)),
        const SizedBox(height: 14),
        TextField(
          key: const Key('sk-photo-caption'),
          controller: ctl,
          autofocus: true,
          maxLength: 60,
          style: pvManrope(fontSize: kSkBodySize, color: p.ink1),
          decoration: InputDecoration(
            hintText: 'A tiger. The fort we made.',
            counterText: '',
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
            style: FilledButton.styleFrom(
                backgroundColor: p.action,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () => Navigator.of(ctx).pop(ctl.text.trim()),
            child: Text('Keep it',
                style: pvManrope(fontSize: kSkButtonSize, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
    ),
  );
}

// =============================================================================
//  The screen
// =============================================================================

class SkPortfolioScreen extends StatefulWidget {
  const SkPortfolioScreen({super.key, required this.doorId, this.onSurface});
  final String doorId;
  final void Function(BuildContext, String)? onSurface;

  @override
  State<SkPortfolioScreen> createState() => _SkPortfolioScreenState();
}

class _SkPortfolioScreenState extends State<SkPortfolioScreen> {
  @override
  void initState() {
    super.initState();
    SkPortfolioStore.instance.load();
    SkVoiceStore.instance.load();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          V2PaletteStore.instance,
          SkPortfolioStore.instance,
          SkVoiceStore.instance,
          SkChildStore.instance,
        ]),
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final photos = SkPortfolioStore.instance.photosFor(widget.doorId);
    final clips = SkVoiceStore.instance.clipsFor(widget.doorId);
    final s = SkChildStore.instance;
    final name = s.name;
    final title = bracketById(widget.doorId)?.title.now ?? '';
    final content = skDoorContentFor(widget.doorId);
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
                      fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.action)),
            const SizedBox(height: 8),
            Text(content?.keepsakeTitle ?? 'Your portfolio',
                style: pvFraunces(
                    fontSize: kSkTitleSize, fontWeight: FontWeight.w600, height: 1.18, color: p.ink1)),
            const SizedBox(height: 10),
            Text(
                name.isEmpty
                    ? 'What you made, kept. Photos of things, recordings of tunes, and what you tried. Nobody marks it.'
                    : 'What $name made, kept. Photos of things, recordings of tunes, and what $name tried. Nobody marks it.',
                style: pvManrope(fontSize: kSkLeadSize, fontWeight: FontWeight.w500, height: 1.5, color: p.ink2)),
            const SizedBox(height: 22),

            // ---- photos --------------------------------------------------
            if (!s.photosAllowed)
              _Note(
                key: const Key('sk-photos-off'),
                p: p,
                text: 'Keeping photos is off until a grown-up turns it on, under For the grown-up. '
                    'Then a picture of anything you make can live here.',
              )
            else ...[
              _Row(
                key: const Key('sk-photo-add'),
                label: 'Keep a photo of something you made',
                icon: Icons.add_a_photo_outlined,
                p: p,
                onTap: () => skAddPhoto(context, doorId: widget.doorId),
              ),
              const SizedBox(height: 14),
              if (photos.isEmpty)
                Text('No photos yet. Make something, then keep a picture of it.',
                    key: const Key('sk-photos-empty'),
                    style: pvManrope(fontSize: kSkBodySize, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2))
              else ...[
                _Grid(photos: photos, p: p, onTap: (ph) => _open(context, p, ph)),
                const SizedBox(height: 14),
                _Row(
                  key: const Key('sk-show-it'),
                  label: 'Show it',
                  icon: Icons.slideshow_outlined,
                  p: p,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: RouteSettings(name: 'sk_show/${widget.doorId}'),
                    builder: (_) => SkShowScreen(doorId: widget.doorId),
                  )),
                ),
              ],
            ],
            const SizedBox(height: 26),

            // ---- recordings and words — the reused keepsakes ----------------
            _Heading('Also yours', p),
            const SizedBox(height: 12),
            _Row(
              key: const Key('sk-portfolio-voice'),
              label: clips.isEmpty ? 'Your recordings' : 'Your recordings (${_few(clips.length)})',
              icon: Icons.mic_none_rounded,
              p: p,
              onTap: () => widget.onSurface?.call(context, 'sk_voice/${widget.doorId}'),
            ),
            const SizedBox(height: 10),
            _Row(
              key: const Key('sk-portfolio-words'),
              label: 'What you tried and made',
              icon: Icons.auto_awesome_outlined,
              p: p,
              onTap: () => widget.onSurface?.call(context, 'sk_keepsake/${widget.doorId}'),
            ),
            const SizedBox(height: 26),
            Text('Kept on this phone. Never marked, never judged — not by a grown-up, not by the app.',
                style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.5, color: p.ink3)),
          ],
        ),
      ),
    );
  }

  /// "a few", never a number on a child screen.
  static String _few(int n) => n == 1 ? 'one' : n < 4 ? 'a few' : 'lots';

  Future<void> _open(BuildContext context, V2Palette p, SkPortfolioPhoto ph) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: p.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(aspectRatio: 4 / 3, child: _Photo(path: ph.path, p: p)),
            ),
            const SizedBox(height: 12),
            Text(ph.caption.isEmpty ? 'Something you made' : ph.caption,
                style: pvFraunces(fontSize: kSkHeadingSize, fontWeight: FontWeight.w600, color: p.ink1)),
            const SizedBox(height: 4),
            Text(_when(ph.at),
                style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: p.action)),
            const SizedBox(height: 14),
            TextButton(
              key: const Key('sk-photo-remove'),
              onPressed: () async {
                await SkPortfolioStore.instance.remove(ph.id);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text('Take it out', style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink3)),
            ),
          ]),
        ),
      );

  static String _when(DateTime t) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${t.day} ${m[t.month - 1]} ${t.year}'.toUpperCase();
  }
}

// =============================================================================
//  Show it — the showcase, private: a full-screen pager to hand to family
// =============================================================================

/// The six the pregnancy invite suggests, restated here rather than imported
/// from a pregnancy screen; "someone else" is the seventh. Caption only —
/// nothing is sent to anyone.
const List<String> kSkShowingTo = ['Papa', 'Mumma', 'Dadi', 'Dada', 'Nani', 'Nana', 'someone else'];

class SkShowScreen extends StatefulWidget {
  const SkShowScreen({super.key, required this.doorId});
  final String doorId;

  @override
  State<SkShowScreen> createState() => _SkShowScreenState();
}

class _SkShowScreenState extends State<SkShowScreen> {
  String? _to;

  @override
  Widget build(BuildContext context) {
    final photos = SkPortfolioStore.instance.photosFor(widget.doorId).reversed.toList();
    final name = SkChildStore.instance.name;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Row(children: [
              // The parent-gated way to open settings does not apply: this
              // is a back button on a black screen, nothing else.
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  key: const Key('sk-show-close'),
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ),
              const Spacer(),
              Text(
                  _to == null
                      ? (name.isEmpty ? 'Made by me' : 'Made by $name')
                      : (name.isEmpty ? 'For $_to' : 'For $_to, made by $name'),
                  style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              const SizedBox(width: 44),
            ]),
          ),
          if (_to == null)
            SizedBox(
              height: kSkTap,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final who in kSkShowingTo)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        key: Key('sk-show-to-$who'),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        label: Text(who, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700)),
                        onPressed: () => setState(() => _to = who),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: photos.isEmpty
                ? Center(
                    child: Text('Nothing to show yet.',
                        style: pvManrope(fontSize: kSkBodySize, color: Colors.white70)))
                : PageView.builder(
                    key: const Key('sk-show-pager'),
                    itemCount: photos.length,
                    itemBuilder: (context, i) {
                      final ph = photos[i];
                      return Column(children: [
                        Expanded(child: Center(child: _Photo(path: ph.path, p: null))),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          child: Text(ph.caption.isEmpty ? '' : ph.caption,
                              textAlign: TextAlign.center,
                              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ]);
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

// =============================================================================
//  Bits
// =============================================================================

class _Photo extends StatelessWidget {
  const _Photo({required this.path, required this.p});
  final String path;
  final V2Palette? p;

  @override
  Widget build(BuildContext context) {
    final f = File(path);
    if (!f.existsSync()) {
      return Container(
        color: p?.surfaceAlt ?? Colors.white10,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_outlined, color: p?.ink3 ?? Colors.white38),
      );
    }
    return Image.file(f, fit: BoxFit.contain);
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.photos, required this.p, required this.onTap});
  final List<SkPortfolioPhoto> photos;
  final V2Palette p;
  final void Function(SkPortfolioPhoto) onTap;

  @override
  Widget build(BuildContext context) => GridView.builder(
        key: const Key('sk-photo-grid'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: photos.length,
        itemBuilder: (context, i) {
          final ph = photos[i];
          return Material(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onTap(ph),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: _Photo(path: ph.path, p: p)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Text(ph.caption.isEmpty ? 'Something I made' : ph.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
                ),
              ]),
            ),
          );
        },
      );
}

class _Row extends StatelessWidget {
  const _Row({super.key, required this.label, required this.icon, required this.p, required this.onTap});
  final String label;
  final IconData icon;
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
              Icon(icon, size: 22, color: p.action),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: pvManrope(fontSize: kSkButtonSize, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
              Icon(Icons.chevron_right_rounded, size: 22, color: p.ink3),
            ]),
          ),
        ),
      );
}

class _Note extends StatelessWidget {
  const _Note({super.key, required this.p, required this.text});
  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(16)),
        child: Text(text,
            style: pvManrope(fontSize: kSkBodySize, fontWeight: FontWeight.w500, height: 1.5, color: p.ink2)),
      );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Text(text,
      style: pvFraunces(fontSize: kSkHeadingSize, fontWeight: FontWeight.w600, color: p.ink1));
}
