// =============================================================================
//  Is it safe? — the camera: a barcode, or a photo
// -----------------------------------------------------------------------------
//  2026-09-19. Two ways to ask without typing, one answer path.
//
//  BARCODE (works today, no key, no cost). The stripes on a packet are a
//  number — an EAN-13, `890…` for India. ML Kit reads it on the phone
//  (`mobile_scanner`, already a dependency), Open Food Facts turns the
//  number into a product name for free (world.openfoodfacts.org, a crowd-
//  sourced database), and `canIMatch` turns "Maggi 2-Minute Masala Noodles"
//  into our `instant_noodles` entry through the names and aliases we already
//  wrote. Exact, instant, free — and only for packaged goods, which is why
//  the photo path exists.
//
//  PHOTO (wired, waits on a key). A picture goes to the `can-i-identify`
//  edge function, which holds the vision key and returns a NAME — never a
//  verdict. The verdict is still our reviewed data; the model only says what
//  the thing is. Until a key is set the function answers `not_configured`
//  and the sheet says so and hands her the field. Never a dead button.
//
//  ⚠️ A MISS IS DATA. Whatever path fails to match logs the query and the
//  product name to `can_i_misses` (fire-and-forget) — the desk's list of
//  what to write next. The empty state is instrumentation.
// =============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/can_i_data.dart';
import '../../models/can_i_entry.dart';
import '../../services/can_i_activity_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/remote/supabase_repo.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskVedaRoute;
import '../../widgets/pv_feedback.dart';
import '../tools/ask_veda_screen.dart';
import '../v2/v2_palette.dart';
import 'can_i_answer.dart';
import 'can_i_widgets.dart';

// -----------------------------------------------------------------------------
//  Matching
// -----------------------------------------------------------------------------

final RegExp _kSplit = RegExp(r'[^a-z0-9ऀ-ॿ]+');

List<String> _words(String s) =>
    s.toLowerCase().split(_kSplit).where((w) => w.length >= 3).toList();

/// Words that describe a packet, not a thing — a match on these alone is
/// not a match.
const Set<String> _kNoise = {
  'the', 'and', 'with', 'pack', 'packet', 'family', 'classic', 'original',
  'fresh', 'pure', 'natural', 'premium', 'india', 'indian', 'style', 'mix',
  'ready', 'instant', 'flavour', 'flavor', 'masala',
};

/// The entry a product name or a typed phrase most plausibly means.
///
/// Each entry's name and aliases are TERMS; a term matches only when every
/// one of its (non-noise) words is in the text — "glucose water" is not
/// matched by "glucose" alone, but "noodles" matches "Instant Noodles"
/// because "instant" is packet noise. The entry with the most matched words
/// wins; ties go to the longer word, so "coconut water" beats "water" for
/// "Tender coconut water 200ml". Null when nothing matches — the caller
/// logs the miss and offers Ask Veda; it never guesses.
CanIEntry? canIMatch(String text) {
  final have = _words(text).toSet();
  if (have.isEmpty) return null;
  CanIEntry? best;
  var bestScore = 0;
  var bestLen = 0;
  for (final e in kCanIEntries) {
    final terms = [e.name.en, ...e.aliases];
    var score = 0;
    var len = 0;
    for (final t in terms) {
      final words = _words(t).where((w) => !_kNoise.contains(w)).toList();
      if (words.isEmpty || !words.every(have.contains)) continue;
      final n = words.length;
      final l = words.fold<int>(0, (a, w) => w.length > a ? w.length : a);
      if (n > score || (n == score && l > len)) {
        score = n;
        len = l;
      }
    }
    if (score > bestScore || (score == bestScore && score > 0 && len > bestLen)) {
      best = e;
      bestScore = score;
      bestLen = len;
    }
  }
  return best;
}

/// Live search for the field: word-prefix on the name and aliases, in data
/// order. "pa" finds Papaya, Paneer, Paracetamol; "nt" finds nothing that
/// merely contains it. (`canISearch` in can_i_data.dart is the older
/// contains-match, kept for the classic screen.)
List<CanIEntry> canIFind(String q) {
  final needle = q.trim().toLowerCase();
  if (needle.isEmpty) return const [];
  final parts = needle.split(_kSplit).where((w) => w.isNotEmpty).toList();
  bool hit(CanIEntry e) {
    final words = [
      ...e.name.en.toLowerCase().split(_kSplit),
      ...e.name.hi.toLowerCase().split(_kSplit),
      for (final a in e.aliases) ...a.toLowerCase().split(_kSplit),
    ];
    return parts.every((p) => words.any((w) => w.startsWith(p)));
  }

  return [for (final e in kCanIEntries) if (hit(e)) e];
}

// -----------------------------------------------------------------------------
//  Open Food Facts
// -----------------------------------------------------------------------------

/// The product a barcode names, or null when the database has never seen
/// it (common for regional Indian brands) or the network is off.
Future<String?> canIProductForBarcode(String code) async {
  try {
    final r = await http.get(
      Uri.parse('https://world.openfoodfacts.org/api/v2/product/$code?fields=product_name,brands,generic_name,categories'),
      headers: {'User-Agent': 'ParentVeda/1.0 (Flutter; is-it-safe)'},
    ).timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body);
    if (j is! Map || j['status'] != 1) return null;
    final p = j['product'];
    if (p is! Map) return null;
    final parts = [
      for (final k in ['product_name', 'generic_name', 'brands', 'categories'])
        if (p[k] is String && (p[k] as String).trim().isNotEmpty) (p[k] as String).trim(),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  } catch (_) {
    return null;
  }
}

// -----------------------------------------------------------------------------
//  The barcode screen
// -----------------------------------------------------------------------------

const String kCanIScanRoute = 'can_i/scan';

Future<void> openCanIScan(BuildContext context, PregnancyController c) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: kCanIScanRoute),
      builder: (_) => CanIScanScreen(controller: c),
    ));

class CanIScanScreen extends StatefulWidget {
  const CanIScanScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<CanIScanScreen> createState() => _CanIScanScreenState();
}

class _CanIScanScreenState extends State<CanIScanScreen> {
  final MobileScannerController _cam = MobileScannerController(
    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _busy = false;

  @override
  void dispose() {
    _cam.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_busy) return;
    final code = cap.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (code == null || code.isEmpty) return;
    setState(() => _busy = true);
    pvCommitFeedback();
    await _cam.stop();
    final product = await canIProductForBarcode(code);
    if (!mounted) return;
    final entry = product == null ? null : canIMatch(product);
    final again = await showCanIIdentifyResult(context, widget.controller,
        entry: entry, product: product, source: 'barcode', query: code);
    if (!mounted) return;
    if (again) {
      setState(() => _busy = false);
      await _cam.start();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        MobileScanner(controller: _cam, onDetect: _onDetect),
        // The finder — four corners, nothing else over the picture.
        Center(
          child: SizedBox(
            width: 260,
            height: 170,
            child: CustomPaint(painter: _CornersPainter()),
          ),
        ),
        SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(children: [
                Material(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                        width: 38, height: 38, child: Icon(Icons.arrow_back_rounded, size: 19, color: Colors.white)),
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _cam.toggleTorch(),
                    child: const SizedBox(
                        width: 38, height: 38, child: Icon(Icons.flashlight_on_outlined, size: 19, color: Colors.white)),
                  ),
                ),
              ]),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(children: [
                Text(_busy ? 'Looking it up…' : 'Point at the barcode on the packet',
                    textAlign: TextAlign.center,
                    style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Packaged food and medicines. For a fruit or a dish, type its name instead.',
                    textAlign: TextAlign.center,
                    style: pvManrope(fontSize: 13, height: 1.45, color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 16),
                if (_busy)
                  SizedBox(
                      width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: p.ground)),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const l = 26.0;
    final w = size.width, h = size.height;
    for (final (x, y, dx, dy) in [(0.0, 0.0, 1.0, 1.0), (w, 0.0, -1.0, 1.0), (0.0, h, 1.0, -1.0), (w, h, -1.0, -1.0)]) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * l, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * l), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// -----------------------------------------------------------------------------
//  The photo path
// -----------------------------------------------------------------------------

/// Take a picture, ask the function what it is, open the answer. The
/// function's `not_configured` is a first-class state here — the sheet says
/// photo lookup is switching on soon and hands her the field.
///
/// HER WORD HELPS (the user's suggestion, 2026-09-19: "that drink could be
/// anything"). After the picture, a small sheet shows it back with one
/// optional field — "What is it? A word helps" — and the word travels with
/// the photo as a hint. A model told "this is chaas" reads a glass of
/// something white far better than one told nothing; and when the model
/// still cannot tell (or is not switched on yet), her word alone is matched,
/// so the photo was never the only way in.
Future<void> canISnap(BuildContext context, PregnancyController c) async {
  final x = await ImagePicker().pickImage(
      source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 72);
  if (x == null || !context.mounted) return;
  final bytes = await x.readAsBytes();
  if (!context.mounted) return;
  final hint = await _askHint(context, bytes);
  if (hint == null || !context.mounted) return; // she backed out
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
        child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2))),
  );
  final res = await SupabaseRepo.invokeEdgeResult('can-i-identify', {
    'image': base64Encode(bytes),
    'mime': 'image/jpeg',
    if (hint.isNotEmpty) 'hint': hint,
  });
  if (!context.mounted) return;
  Navigator.of(context).pop(); // the spinner
  final name = res.ok ? (res.data?['name'] as String?) : null;
  final notConfigured = res.status == 503 || res.data?['error'] == 'not_configured';
  var entry = (name == null || name == 'unknown') ? null : canIMatch(name);
  // The model drew a blank, or is not on yet, but she told us: her word is
  // the query, and the sheet is the ordinary found / not-found one.
  if (entry == null && hint.isNotEmpty) entry = canIMatch(hint);
  await showCanIIdentifyResult(context, c,
      entry: entry,
      product: name ?? (hint.isNotEmpty ? hint : null),
      source: 'photo',
      query: hint.isNotEmpty ? hint : 'photo',
      notConfigured: notConfigured && entry == null);
}

/// The picture back, one optional field, Identify. Null = she backed out.
Future<String?> _askHint(BuildContext context, Uint8List bytes) {
  final p = V2PaletteStore.instance.current;
  final ctl = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, 20 + MediaQuery.viewInsetsOf(ctx).bottom + MediaQuery.paddingOf(ctx).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YOUR PHOTO',
            style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(bytes, width: 92, height: 92, fit: BoxFit.cover),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('What is it?',
                  style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
              const SizedBox(height: 4),
              Text('A word helps: "chaas", "cough syrup", "the pink one". Optional.',
                  style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        TextField(
          controller: ctl,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          decoration: const InputDecoration(hintText: 'Tell us what it is (optional)'),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: () {
            pvCommitFeedback();
            Navigator.pop(ctx, ctl.text.trim());
          },
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text('Identify'),
        ),
      ]),
    ),
  );
}

// -----------------------------------------------------------------------------
//  The result sheet — one for both paths
// -----------------------------------------------------------------------------

/// Returns true when she wants to scan again.
Future<bool> showCanIIdentifyResult(
  BuildContext context,
  PregnancyController c, {
  required CanIEntry? entry,
  required String? product,
  required String source,
  required String query,
  bool notConfigured = false,
}) async {
  final p = V2PaletteStore.instance.current;
  if (entry == null) {
    CanIActivityStore.instance.logMiss(query, source: source, product: product);
  }
  final again = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + MediaQuery.paddingOf(ctx).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            entry != null
                ? 'FOUND'
                : notConfigured
                    ? 'PHOTO LOOKUP'
                    : 'NOT IN OUR LIST YET',
            style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
        const SizedBox(height: 6),
        if (entry != null) ...[
          if (product != null) ...[
            Text(product,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2)),
            const SizedBox(height: 10),
          ],
          CanIRow(
              entry: entry,
              p: p,
              last: true,
              onTap: () {
                Navigator.pop(ctx, false);
                openCanIAnswer(context, entry, c);
              }),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              pvCommitFeedback();
              Navigator.pop(ctx, false);
              openCanIAnswer(context, entry, c);
            },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: Text('Open ${entry.name.now}'),
          ),
        ] else if (notConfigured) ...[
          Text('Switching on soon',
              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
          const SizedBox(height: 8),
          Text('Photo lookup is not live in this build yet. Type what it is and the answer is the same.',
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Type it instead'),
          ),
        ] else ...[
          Text(product ?? 'We could not read that',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
          const SizedBox(height: 8),
          Text(
              product == null
                  ? 'The barcode is not in the food database — common for regional brands. '
                      'Type the name and we will look it up that way.'
                  : 'We have noted it, so the answer can be written. Until then, ask Veda '
                      'or type the plain name — "noodles", not the brand.',
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              pvCommitFeedback();
              Navigator.pop(ctx, false);
              Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: kAskVedaRoute),
                builder: (_) => AskVedaScreen(
                    controller: c,
                    initialQuery: 'Is ${product ?? 'this'} safe in pregnancy?'),
              ));
            },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Ask Veda'),
          ),
          if (source == 'barcode') ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              child: const Text('Scan another'),
            ),
          ],
        ],
      ]),
    ),
  );
  return again ?? false;
}
