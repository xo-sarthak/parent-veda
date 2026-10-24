// =============================================================================
//  ask_veda_mark.dart - the one mark that means "Ask Veda", everywhere
// -----------------------------------------------------------------------------
//  Ask Veda used the stock sparkle (`Icons.auto_awesome`), the same glyph
//  Fitbit, Opera, Evernote and a dozen other apps put on their AI. It read as
//  generic. The marks people remember are alive (Meta AI's ring, ChatGPT's
//  orb), so this one is too: AURORA, a violet sphere with saffron, pink and
//  gold light drifting inside it and a soft highlight on top (prototype
//  artifact 3372duZQUunNEUxbC2ZWTV, option H, chosen 2026-10-24 "for the time
//  being"; the H-vs-K call is STILL-OPEN).
//
//  ⚠️ ONE WIDGET, EVERY SITE. The FAB, the three Ask Veda screens, every
//  "Ask Veda" row and every search way-on row draw `AskVedaMark`. If the mark
//  changes again (K adds rings going out from the sphere), it changes in
//  `_AuroraPainter` and nowhere else. A call site that draws its own sparkle
//  is the bug `test/ask_veda_mark_test.dart` exists to catch.
//
//  ⚠️ ITS OWN COLOURS, ON PURPOSE. The house look is ink on white; this mark
//  is the one thing allowed to break it (the user asked for experimental,
//  2026-10-24). The colours live here, not in the theme, so nothing else can
//  borrow them by accident.
//
//  ⚠️ WHEN IT STAYS STILL. The drift is one AnimationController repeating
//  forever, so it is paused - painted at a fixed moment, no ticker - when:
//    * the phone asks for reduced motion (`MediaQuery.disableAnimations`);
//    * the caller passes `animate: false`;
//    * the mark is smaller than 18pt, where the drift is invisible and the
//      repaint is pure cost (a list of rows would tick for nothing);
//    * under `flutter test`. The FAB is on nearly every screen, and a ticker
//      that never stops makes every `pumpAndSettle` in the suite time out.
//      The trade-off: the motion itself is not exercised by widget tests;
//      the still frame and the wiring are.
// =============================================================================

import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AskVedaMark extends StatefulWidget {
  const AskVedaMark({super.key, this.size = 24, this.animate = true});

  final double size;
  final bool animate;

  /// Lets the mark's own test run the drift under `flutter test`.
  @visibleForTesting
  static bool debugAnimateInTests = false;

  @override
  State<AskVedaMark> createState() => _AskVedaMarkState();
}

class _AskVedaMarkState extends State<AskVedaMark> with SingleTickerProviderStateMixin {
  // 42s holds whole cycles of the 6s and 7s blobs and 8 of the third, so the
  // loop closes without a jump.
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 42));

  static bool get _underTest {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return true;
    }
  }

  bool _shouldMove(BuildContext context) =>
      widget.animate &&
      widget.size >= 18 &&
      !(MediaQuery.maybeOf(context)?.disableAnimations ?? false) &&
      (!_underTest || AskVedaMark.debugAnimateInTests);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AskVedaMark old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final move = _shouldMove(context);
    if (move && !_c.isAnimating) {
      _c.repeat();
    } else if (!move && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: CustomPaint(painter: _AuroraPainter(_c)),
        ),
      );
}

/// The sphere. Every length is a fraction of the side, so one drawing serves
/// the 16pt row icon and the 56pt FAB alike.
class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  static const _base = [Color(0xFF5B3FE0), Color(0xFF7A5CFF), Color(0xFF9C84FF)];
  static const _saffron = Color(0xFFFF9A1F);
  static const _pink = Color(0xFFFF3D8B);
  static const _gold = Color(0xFFFFD27A);

  /// 0 -> 1 -> 0 over [period] seconds, eased like CSS ease-in-out.
  double _swing(double seconds, double period) => (1 - math.cos(2 * math.pi * seconds / period)) / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & Size.square(s);
    final secs = t.value * 42;

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, 0.4),
          radius: 0.75,
          colors: _base,
          stops: [0, 0.6, 1],
        ).createShader(rect),
    );

    // The light inside: three soft blobs screened over the violet, so where
    // they cross they brighten rather than muddy.
    canvas.saveLayer(rect, Paint());
    void blob(Color c, double cx, double cy, double r) => canvas.drawCircle(
          Offset(cx * s, cy * s),
          r * s,
          Paint()
            ..color = c
            ..blendMode = BlendMode.screen
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.12 * s),
        );
    final a = _swing(secs, 6), b = _swing(secs, 7), g = _swing(secs, 5.25);
    blob(_saffron, 0.275 + 0.25 * a, 0.325 + 0.2 * a, 0.375);
    blob(_pink, 0.775 - 0.25 * b, 0.525 + 0.15 * b, 0.375);
    blob(_gold, 0.475 + 0.15 * g, 1.025 - 0.3 * g, 0.275);
    canvas.restore();

    // The highlight that makes it a sphere, not a disc.
    canvas.drawOval(
      Rect.fromLTWH(0.18 * s, 0.12 * s, 0.34 * s, 0.22 * s),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.04 * s),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}
