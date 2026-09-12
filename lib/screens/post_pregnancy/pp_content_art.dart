// =============================================================================
//  pp_content_art — the drawn animation and illustrations a page can hold
// -----------------------------------------------------------------------------
//  ⚠️ DRAWN IN CODE, AND THAT IS THE FINISHED STATE, NOT A STAND-IN.
//
//  `PpVideoSlot` renders a placeholder because a film needs a camera. An
//  animation of two sleep-cycle waves and a labelled picture of a bed do not:
//  they are geometry, and the geometry IS the explanation. So these are
//  `CustomPainter`s in the same hand as `HubIntentArt` — strokes in the ink
//  colour on the page's own tint, no photograph pretending to be one.
//
//  Two rules, both from the illustration brief:
//
//  * **The labels are the content.** A numbered badge on the picture and a
//    numbered legend under it. The painter owns WHERE each number sits; the
//    data owns WHAT it says. A page author changes copy without opening a
//    painter, and an artist redraws the scene without touching copy.
//  * **A real asset replaces the painter, not the block.** `PpIllustration.asset`
//    swaps the drawn scene for a file and keeps the legend. The badge positions
//    are then the artist's job, which is why the file, when it arrives, should
//    carry its own numbers.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';

// =============================================================================
//  THE ANIMATION
// =============================================================================

class PpAnimationView extends StatefulWidget {
  const PpAnimationView({super.key, required this.block});
  final PpAnimation block;

  @override
  State<PpAnimationView> createState() => _PpAnimationViewState();
}

class _PpAnimationViewState extends State<PpAnimationView>
    with SingleTickerProviderStateMixin {
  // ⚠️ ONE NIGHT IN TEN SECONDS, LOOPING. Slow enough to read the two rhythms
  // apart, short enough that she sees a whole night without waiting. Not
  // user-controlled: there is nothing to scrub to, the point is the ratio.
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(seconds: 10))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = ppTintFor(206);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ANIMATION',
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: p.action)),
        const SizedBox(height: 6),
        Text(widget.block.title,
            style: pvFraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.35,
                color: p.ink1)),
        const SizedBox(height: 14),
        AspectRatio(
          aspectRatio: 16 / 10,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: switch (widget.block.kind) {
                PpAnimationKind.sleepCycles =>
                  _SleepCyclesPainter(t: _c.value, p: p),
              },
            ),
          ),
        ),
        if (widget.block.caption != null) ...[
          const SizedBox(height: 12),
          Text(widget.block.caption!,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  color: p.ink1)),
        ],
      ]),
    );
  }
}

/// Two waves over one night. Hers cycles every 45 minutes, yours every 90, so
/// across the same eight hours she comes to the surface about twice as often.
/// A cursor sweeps the night; each surfacing lights as it passes.
class _SleepCyclesPainter extends CustomPainter {
  _SleepCyclesPainter({required this.t, required this.p});

  final double t;
  final V2Palette p;

  static const _herCycles = 10.5; // ~45 min in an 8-hour night
  static const _yourCycles = 5.3; // ~90 min

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rowH = h / 2;
    _row(canvas, w, rowH, 0, _herCycles, 'HER', 'a cycle every 40 to 50 min');
    _row(canvas, w, rowH, rowH, _yourCycles, 'YOU', 'about 90 minutes');

    // The cursor.
    final x = 14 + (w - 28) * t;
    canvas.drawLine(
      Offset(x, 4),
      Offset(x, h - 4),
      Paint()
        ..color = p.ink1.withValues(alpha: 0.35)
        ..strokeWidth = 1.2,
    );
  }

  void _row(Canvas canvas, double w, double rowH, double top, double cycles,
      String who, String note) {
    const left = 14.0;
    final right = w - 14;
    final mid = top + rowH * 0.58;
    final amp = rowH * 0.26;
    final span = right - left;

    // The label.
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
              text: '$who  ',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.action)),
          TextSpan(
              text: note,
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: p.ink2)),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: span);
    tp.paint(canvas, Offset(left, top + 4));

    // The full wave, faint; the swept part, strong. A trough is deep sleep,
    // a crest is the surfacing.
    Path wave(double toX) {
      final path = Path();
      for (var i = 0; i <= 200; i++) {
        final f = i / 200;
        final x = left + span * f;
        if (x > toX) break;
        final y = mid - amp * math.cos(f * cycles * 2 * math.pi);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    canvas.drawPath(
      wave(right),
      Paint()
        ..color = p.ink1.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final cursor = left + span * t;
    canvas.drawPath(
      wave(cursor),
      Paint()
        ..color = p.ink1.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // The surfacings: one dot per crest, lit once the cursor has passed it.
    var lit = 0;
    for (var k = 0; k <= cycles.floor(); k++) {
      final f = k / cycles;
      if (f > 1) break;
      final x = left + span * f;
      final y = mid - amp;
      final passed = x <= cursor;
      if (passed) lit++;
      canvas.drawCircle(
        Offset(x, y),
        passed ? 4 : 2.5,
        Paint()
          ..color = passed ? p.action : p.ink1.withValues(alpha: 0.25),
      );
    }

    // The count so far, bottom right of the row.
    final count = TextPainter(
      text: TextSpan(
          text: 'surfaced $lit ${lit == 1 ? 'time' : 'times'}',
          style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: p.ink1.withValues(alpha: 0.75))),
      textDirection: TextDirection.ltr,
    )..layout();
    // Top right, beside the row label: at the foot it sat over the last
    // crests. Seen on a phone, 2026-09-11.
    count.paint(canvas, Offset(right - count.width, top + 4));
  }

  @override
  bool shouldRepaint(_SleepCyclesPainter old) => old.t != t || old.p != p;
}

// =============================================================================
//  THE ILLUSTRATIONS
// =============================================================================

class PpIllustrationView extends StatelessWidget {
  const PpIllustrationView({super.key, required this.block});
  final PpIllustration block;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = ppTintFor(152);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ILLUSTRATION',
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: p.action)),
        const SizedBox(height: 6),
        Text(block.title,
            style: pvFraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.35,
                color: p.ink1)),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 11,
            child: block.asset != null
                ? Image.asset(block.asset!, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _drawn(p))
                : _drawn(p),
          ),
        ),
        const SizedBox(height: 14),
        // The legend. Numbered to match the badges on the picture.
        for (final (i, l) in block.labels.indexed) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Badge(n: i + 1, p: p),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.title,
                        style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            color: p.ink1)),
                    if (l.detail != null)
                      Text(l.detail!,
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: p.ink2)),
                  ]),
            ),
          ]),
          if (i != block.labels.length - 1) const SizedBox(height: 9),
        ],
        if (block.caption != null) ...[
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 11),
          Text(block.caption!,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  color: p.ink1)),
        ],
      ]),
    );
  }

  Widget _drawn(V2Palette p) => Container(
        color: Colors.white.withValues(alpha: 0.55),
        child: CustomPaint(
          painter: switch (block.kind) {
            PpIllustrationKind.thermometerRoutes =>
              _ThermometerPainter(p: p, badges: block.labels.length),
            PpIllustrationKind.dehydrationSigns =>
              _DehydrationPainter(p: p, badges: block.labels.length),
            PpIllustrationKind.rashGrid =>
              _RashGridPainter(p: p, badges: block.labels.length),
            PpIllustrationKind.safeBedSetup =>
              _SafeBedPainter(p: p, badges: block.labels.length),
            PpIllustrationKind.backToSleep =>
              _BackToSleepPainter(p: p, badges: block.labels.length),
            PpIllustrationKind.solidsTextures =>
              _TexturesPainter(p: p, badges: block.labels.length),
            PpIllustrationKind.cutItThisWay =>
              _CutItPainter(p: p, badges: block.labels.length),
            PpIllustrationKind.allergicReaction =>
              _AllergyPainter(p: p, badges: block.labels.length),
          },
        ),
      );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.n, required this.p});
  final int n;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: p.action, shape: BoxShape.circle),
        child: Text('$n',
            style: pvManrope(
                fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
      );
}

/// Shared strokes for the two scenes.
abstract class _ScenePainter extends CustomPainter {
  _ScenePainter({required this.p, required this.badges});
  final V2Palette p;

  /// How many numbered badges to draw. The painter knows up to N positions;
  /// fewer labels means fewer badges, never a badge without a legend line.
  final int badges;

  Paint get ink => Paint()
    ..color = p.ink1.withValues(alpha: 0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get soft => Paint()..color = p.ink1.withValues(alpha: 0.10);

  void badge(Canvas canvas, int n, Offset at) {
    if (n > badges) return;
    canvas.drawCircle(at, 10, Paint()..color = p.action);
    canvas.drawCircle(
        at,
        10,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    final tp = TextPainter(
      text: TextSpan(
          text: '$n',
          style: pvManrope(
              fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  /// A baby, drawn small: a head and a body, lying along [dir].
  void baby(Canvas canvas, Offset head, double r, {bool onBack = true}) {
    canvas.drawCircle(head, r, ink);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(head.dx + r * 0.9, head.dy - r * 0.85, r * 3.2, r * 1.7),
      Radius.circular(r * 0.85),
    );
    canvas.drawRRect(body, ink);
    if (onBack) {
      // Two arms up, the way a baby on her back lies.
      canvas.drawLine(Offset(head.dx + r * 1.5, head.dy - r * 0.85),
          Offset(head.dx + r * 1.2, head.dy - r * 1.7), ink);
      canvas.drawLine(Offset(head.dx + r * 2.6, head.dy - r * 0.85),
          Offset(head.dx + r * 2.9, head.dy - r * 1.7), ink);
      // The face: two eyes, closed.
      canvas.drawLine(Offset(head.dx - r * 0.35, head.dy - r * 0.1),
          Offset(head.dx - r * 0.15, head.dy - r * 0.1), ink);
      canvas.drawLine(Offset(head.dx + r * 0.15, head.dy - r * 0.1),
          Offset(head.dx + r * 0.35, head.dy - r * 0.1), ink);
    }
  }

  /// A green tick in a filled circle.
  void tickAt(Canvas canvas, Offset at, double r) {
    canvas.drawCircle(at, r * 1.4, Paint()..color = p.action);
    final path = Path()
      ..moveTo(at.dx - r * 0.6, at.dy)
      ..lineTo(at.dx - r * 0.15, at.dy + r * 0.45)
      ..lineTo(at.dx + r * 0.65, at.dy - r * 0.45);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  /// A quiet cross in a faint circle.
  void crossAt(Canvas canvas, Offset at, double r) {
    final paint = Paint()
      ..color = p.ink1.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
        at, r * 1.4, Paint()..color = p.ink1.withValues(alpha: 0.10));
    canvas.drawLine(
        at - Offset(r * 0.5, r * 0.5), at + Offset(r * 0.5, r * 0.5), paint);
    canvas.drawLine(
        at - Offset(r * 0.5, -r * 0.5), at + Offset(r * 0.5, -r * 0.5), paint);
  }

  /// A katori: a shallow bowl seen from slightly above.
  void katori(Canvas canvas, Offset centre, double w) {
    final rim = Rect.fromCenter(center: centre, width: w, height: w * 0.36);
    final body = Path()
      ..moveTo(rim.left, rim.center.dy)
      ..quadraticBezierTo(rim.left + w * 0.1, rim.bottom + w * 0.32,
          rim.center.dx, rim.bottom + w * 0.34)
      ..quadraticBezierTo(rim.right - w * 0.1, rim.bottom + w * 0.32,
          rim.right, rim.center.dy);
    canvas.drawPath(body, Paint()..color = Colors.white);
    canvas.drawPath(body, ink);
    canvas.drawOval(rim, Paint()..color = Colors.white);
    canvas.drawOval(rim, ink);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.p != p || old.badges != badges;
}

/// Four katoris left to right: smooth, mashed with lumps, soft sticks,
/// chopped pieces. Four numbered points.
class _TexturesPainter extends _ScenePainter {
  _TexturesPainter({required super.p, required super.badges});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bowl = w * 0.19;
    final xs = [w * 0.15, w * 0.385, w * 0.615, w * 0.85];
    final y = h * 0.48;
    final fill = Paint()..color = p.ink1.withValues(alpha: 0.22);

    for (final (i, x) in xs.indexed) {
      katori(canvas, Offset(x, y), bowl);
      final inner = Rect.fromCenter(
          center: Offset(x, y), width: bowl * 0.78, height: bowl * 0.26);
      switch (i) {
        case 0:
          canvas.drawOval(inner, fill);
        case 1:
          canvas.drawOval(inner, fill);
          for (final d in [-0.22, 0.05, 0.25]) {
            canvas.drawCircle(
                Offset(x + bowl * d, y - bowl * 0.03), bowl * 0.05, ink);
          }
        case 2:
          for (final d in [-0.2, 0.0, 0.2]) {
            canvas.drawRRect(
                RRect.fromRectAndRadius(
                    Rect.fromCenter(
                        center: Offset(x + bowl * d, y - bowl * 0.02),
                        width: bowl * 0.13,
                        height: bowl * 0.4),
                    Radius.circular(bowl * 0.06)),
                ink);
          }
        default:
          for (final (dx, dy) in [
            (-0.2, -0.06),
            (0.0, 0.02),
            (0.2, -0.05),
            (-0.08, 0.1),
            (0.12, 0.1)
          ]) {
            canvas.drawRRect(
                RRect.fromRectAndRadius(
                    Rect.fromCenter(
                        center: Offset(x + bowl * dx, y + bowl * dy),
                        width: bowl * 0.13,
                        height: bowl * 0.13),
                    Radius.circular(bowl * 0.03)),
                ink);
          }
      }
      badge(canvas, i + 1, Offset(x, y + bowl * 0.62));
    }
    canvas.drawLine(Offset(w * 0.1, h * 0.9), Offset(w * 0.9, h * 0.9), ink);
    canvas.drawLine(Offset(w * 0.86, h * 0.86), Offset(w * 0.9, h * 0.9), ink);
    canvas.drawLine(Offset(w * 0.86, h * 0.94), Offset(w * 0.9, h * 0.9), ink);
  }
}

/// Left of each pair: the cut that is safe, ticked. Right: the shape that is
/// not, crossed. Grape, stick, nut; 4 and 5 are legend-only points.
class _CutItPainter extends _ScenePainter {
  _CutItPainter({required super.p, required super.badges});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = h * 0.075;
    final rows = [h * 0.2, h * 0.5, h * 0.8];

    final y1 = rows[0];
    for (final d in [-1.6, -0.55, 0.55, 1.6]) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(w * 0.24 + r * d * 0.5, y1),
              width: r * 0.45,
              height: r * 1.8),
          ink);
    }
    tickAt(canvas, Offset(w * 0.42, y1), r * 0.45);
    for (final d in [-1.2, 0.0, 1.2]) {
      canvas.drawCircle(Offset(w * 0.72 + r * d, y1), r * 0.5, ink);
    }
    crossAt(canvas, Offset(w * 0.9, y1), r * 0.45);
    badge(canvas, 1, Offset(w * 0.06, y1));

    final y2 = rows[1];
    for (final d in [-0.5, 0.5]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(w * 0.24 + r * d * 1.2, y2),
                  width: r * 0.5,
                  height: r * 2.2),
              Radius.circular(r * 0.2)),
          ink);
    }
    tickAt(canvas, Offset(w * 0.42, y2), r * 0.45);
    for (final d in [-1.2, 0.0, 1.2]) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(w * 0.72 + r * d, y2),
              width: r * 1.1,
              height: r * 0.5),
          ink);
    }
    crossAt(canvas, Offset(w * 0.9, y2), r * 0.45);
    badge(canvas, 2, Offset(w * 0.06, y2));

    final y3 = rows[2];
    final grain = Paint()..color = p.ink1.withValues(alpha: 0.5);
    for (var i = 0; i < 9; i++) {
      final dx = (i % 3 - 1) * r * 0.5;
      final dy = (i ~/ 3 - 1) * r * 0.45;
      canvas.drawCircle(Offset(w * 0.24 + dx, y3 + dy), r * 0.09, grain);
    }
    tickAt(canvas, Offset(w * 0.42, y3), r * 0.45);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.72, y3), width: r * 1.5, height: r * 1.0),
        ink);
    crossAt(canvas, Offset(w * 0.9, y3), r * 0.45);
    badge(canvas, 3, Offset(w * 0.06, y3));

    badge(canvas, 4, Offset(w * 0.56, y1));
    badge(canvas, 5, Offset(w * 0.56, y3));
  }
}

/// One face: the mild signs numbered on the left, the call-now signs on the
/// right under a coral band.
class _AllergyPainter extends _ScenePainter {
  _AllergyPainter({required super.p, required super.badges});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w * 0.5, h * 0.5);
    final r = h * 0.3;

    canvas.drawRect(
        Rect.fromLTWH(w * 0.5, 0, w * 0.5, h),
        Paint()..color = const Color(0xFFFF5A79).withValues(alpha: 0.10));

    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(c, r, ink);
    canvas.drawCircle(Offset(c.dx - r * 0.35, c.dy - r * 0.2), r * 0.06, ink);
    canvas.drawCircle(Offset(c.dx + r * 0.35, c.dy - r * 0.2), r * 0.06, ink);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(c.dx, c.dy + r * 0.35),
            width: r * 0.7,
            height: r * 0.4),
        0.15,
        2.8,
        false,
        ink);
    final hive = Paint()..color = p.ink1.withValues(alpha: 0.3);
    for (final (dx, dy) in [(-0.45, 0.35), (-0.55, 0.55), (-0.3, 0.62), (-0.62, 0.2)]) {
      canvas.drawCircle(Offset(c.dx + r * dx, c.dy + r * dy), r * 0.07, hive);
    }
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(c.dx + r * 0.38, c.dy - r * 0.08),
            width: r * 0.45,
            height: r * 0.22),
        ink);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(c.dx + r * 0.25, c.dy + r * 0.5),
            width: r * 0.4,
            height: r * 0.18),
        ink);

    badge(canvas, 1, Offset(w * 0.12, h * 0.28));
    badge(canvas, 2, Offset(w * 0.12, h * 0.5));
    badge(canvas, 3, Offset(w * 0.12, h * 0.72));
    badge(canvas, 4, Offset(w * 0.88, h * 0.28));
    badge(canvas, 5, Offset(w * 0.88, h * 0.5));
    badge(canvas, 6, Offset(w * 0.88, h * 0.72));

    void word(String text, Color colour, double cx) {
      final tp = TextPainter(
        text: TextSpan(
            text: text,
            style: pvManrope(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: colour)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, h * 0.06));
    }

    word('MILD', p.action, w * 0.25);
    word('CALL NOW', const Color(0xFFFF5A79), w * 0.75);
  }
}

/// One bed, flush to the wall, a mother on her side, the baby on her back
/// beside her with clear space around her head. Eight numbered points.
class _SafeBedPainter extends _ScenePainter {
  _SafeBedPainter({required super.p, required super.badges});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // The wall, on the left, and the floor line.
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.06, h), soft);
    canvas.drawLine(Offset(0, h * 0.86), Offset(w, h * 0.86), ink);

    // The bed: a firm mattress on a low frame, flush to the wall.
    final bed = Rect.fromLTWH(w * 0.06, h * 0.40, w * 0.82, h * 0.30);
    canvas.drawRRect(RRect.fromRectAndRadius(bed, const Radius.circular(6)),
        Paint()..color = Colors.white);
    canvas.drawRRect(
        RRect.fromRectAndRadius(bed, const Radius.circular(6)), ink);
    // legs
    canvas.drawLine(Offset(w * 0.10, h * 0.70), Offset(w * 0.10, h * 0.86), ink);
    canvas.drawLine(Offset(w * 0.84, h * 0.70), Offset(w * 0.84, h * 0.86), ink);

    // The pillow, at the far end, away from the baby.
    final pillow = Rect.fromLTWH(w * 0.66, h * 0.30, w * 0.18, h * 0.10);
    canvas.drawRRect(
        RRect.fromRectAndRadius(pillow, const Radius.circular(8)), soft);
    canvas.drawRRect(
        RRect.fromRectAndRadius(pillow, const Radius.circular(8)), ink);

    // The mother, on her side, taking the middle of the bed. A long rounded
    // shape and a head near the pillow.
    final mother = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.30, h * 0.24, w * 0.40, h * 0.16),
      Radius.circular(h * 0.08),
    );
    canvas.drawRRect(mother, ink);
    canvas.drawCircle(Offset(w * 0.74, h * 0.32), h * 0.075, ink);

    // Her blanket, no higher than her waist, and nowhere near the baby.
    final blanket = Path()
      ..moveTo(w * 0.30, h * 0.40)
      ..lineTo(w * 0.52, h * 0.40)
      ..lineTo(w * 0.52, h * 0.24);
    canvas.drawPath(blanket, ink..strokeWidth = 2.4);

    // The baby, on her back, on the wall side of her mother, with clear space.
    baby(canvas, Offset(w * 0.16, h * 0.31), h * 0.055);

    // The numbered points. The order matches the legend the page declares.
    badge(canvas, 1, Offset(w * 0.47, h * 0.62)); // firm flat mattress
    badge(canvas, 2, Offset(w * 0.06, h * 0.53)); // no gap to the wall
    badge(canvas, 3, Offset(w * 0.24, h * 0.18)); // on her back, beside you
    badge(canvas, 4, Offset(w * 0.75, h * 0.22)); // pillows away from her
    badge(canvas, 5, Offset(w * 0.15, h * 0.47)); // her own light layer
    badge(canvas, 6, Offset(w * 0.56, h * 0.47)); // blanket at your waist
    badge(canvas, 7, Offset(w * 0.82, h * 0.40)); // hair tied, no cords
    badge(canvas, 8, Offset(w * 0.90, h * 0.78)); // low bed or floor mattress
  }
}

/// Three babies: on her back, large and centred with a tick; on her side and
/// on her front, small and crossed out.
class _BackToSleepPainter extends _ScenePainter {
  _BackToSleepPainter({required super.p, required super.badges});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // The mattress everything lies on.
    canvas.drawLine(Offset(w * 0.06, h * 0.72), Offset(w * 0.94, h * 0.72),
        ink..strokeWidth = 2.4);

    // Centre: on her back.
    baby(canvas, Offset(w * 0.34, h * 0.50), h * 0.11);
    tickAt(canvas, Offset(w * 0.50, h * 0.22), h * 0.06);

    // Left, small: on her side (head drawn as a profile, arm down).
    final sideHead = Offset(w * 0.12, h * 0.58);
    canvas.drawCircle(sideHead, h * 0.05, ink);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.10, h * 0.61, w * 0.05, h * 0.10),
            const Radius.circular(6)),
        ink);
    crossAt(canvas, Offset(w * 0.12, h * 0.36), h * 0.045);

    // Right, small: on her front (face down, no face).
    final frontHead = Offset(w * 0.86, h * 0.60);
    canvas.drawCircle(frontHead, h * 0.05, ink);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.70, h * 0.57, w * 0.13, h * 0.07),
            const Radius.circular(6)),
        ink);
    crossAt(canvas, Offset(w * 0.80, h * 0.36), h * 0.045);

    badge(canvas, 1, Offset(w * 0.34, h * 0.86)); // on her back
    badge(canvas, 2, Offset(w * 0.12, h * 0.86)); // not on her side
    badge(canvas, 3, Offset(w * 0.80, h * 0.86)); // not on her front
    badge(canvas, 4, Offset(w * 0.60, h * 0.30)); // once she rolls herself
  }
}

/// A baby's head and shoulders, front on, with the four places a temperature
/// is taken numbered: under the arm, forehead, ear, mouth.
class _ThermometerPainter extends _ScenePainter {
  _ThermometerPainter({required super.p, required super.badges});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final head = Offset(w * 0.5, h * 0.4);
    final r = h * 0.24;

    // Shoulders and arms, then the head over them.
    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.6, w * 0.56, h * 0.5),
        Radius.circular(h * 0.16));
    canvas.drawRRect(body, Paint()..color = Colors.white);
    canvas.drawRRect(body, ink);
    canvas.drawCircle(head, r, Paint()..color = Colors.white);
    canvas.drawCircle(head, r, ink);
    canvas.drawCircle(Offset(head.dx - r * 0.35, head.dy - r * 0.1), r * 0.06, ink);
    canvas.drawCircle(Offset(head.dx + r * 0.35, head.dy - r * 0.1), r * 0.06, ink);
    canvas.drawArc(
        Rect.fromCenter(center: Offset(head.dx, head.dy + r * 0.4), width: r * 0.5, height: r * 0.3),
        0.3, 2.5, false, ink);
    // Ears.
    canvas.drawOval(Rect.fromCenter(center: Offset(head.dx - r * 1.02, head.dy), width: r * 0.28, height: r * 0.5), ink);
    canvas.drawOval(Rect.fromCenter(center: Offset(head.dx + r * 1.02, head.dy), width: r * 0.28, height: r * 0.5), ink);
    // The thermometer, under the left arm.
    canvas.drawLine(Offset(w * 0.3, h * 0.66), Offset(w * 0.22, h * 0.86), ink..strokeWidth = 3);
    canvas.drawCircle(Offset(w * 0.22, h * 0.86), r * 0.12, Paint()..color = p.action);

    badge(canvas, 1, Offset(w * 0.26, h * 0.72)); // under the arm
    badge(canvas, 2, Offset(head.dx, head.dy - r * 0.62)); // forehead
    badge(canvas, 3, Offset(head.dx + r * 1.3, head.dy)); // ear
    badge(canvas, 4, Offset(head.dx, head.dy + r * 0.72)); // mouth
  }
}

/// A baby, front on, with the dehydration signs numbered where they show:
/// the soft spot, the eyes, the mouth, the nappy, the belly skin, and how he
/// is.
class _DehydrationPainter extends _ScenePainter {
  _DehydrationPainter({required super.p, required super.badges});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final head = Offset(w * 0.5, h * 0.3);
    final r = h * 0.18;

    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.46, w * 0.4, h * 0.44),
        Radius.circular(h * 0.14));
    canvas.drawRRect(body, Paint()..color = Colors.white);
    canvas.drawRRect(body, ink);
    canvas.drawCircle(head, r, Paint()..color = Colors.white);
    canvas.drawCircle(head, r, ink);
    // Eyes drawn a little hollow.
    canvas.drawArc(Rect.fromCenter(center: Offset(head.dx - r * 0.35, head.dy), width: r * 0.3, height: r * 0.22), 3.3, 3.0, false, ink);
    canvas.drawArc(Rect.fromCenter(center: Offset(head.dx + r * 0.35, head.dy), width: r * 0.3, height: r * 0.22), 3.3, 3.0, false, ink);
    canvas.drawLine(Offset(head.dx - r * 0.2, head.dy + r * 0.45), Offset(head.dx + r * 0.2, head.dy + r * 0.45), ink);
    // The nappy.
    canvas.drawLine(Offset(w * 0.3, h * 0.76), Offset(w * 0.7, h * 0.76), ink);
    // The skin pinch, a small tent on the belly.
    final pinch = Path()
      ..moveTo(w * 0.44, h * 0.66)
      ..lineTo(w * 0.5, h * 0.6)
      ..lineTo(w * 0.56, h * 0.66);
    canvas.drawPath(pinch, ink);

    badge(canvas, 4, Offset(w * 0.82, h * 0.8)); // urine
    badge(canvas, 3, Offset(head.dx + r * 1.45, head.dy + r * 0.45)); // mouth
    badge(canvas, 2, Offset(head.dx - r * 1.45, head.dy)); // tears / eyes
    badge(canvas, 1, Offset(head.dx, head.dy - r * 1.3)); // soft spot
    badge(canvas, 5, Offset(w * 0.18, h * 0.62)); // skin
    badge(canvas, 6, Offset(w * 0.18, h * 0.86)); // how he is
  }
}

/// Eight rashes as a grid of swatches, each drawn in its own hand: pimples,
/// pinpoints, dry patches, greasy scales, a nappy zone, blisters, crusted
/// crops, welts. Numbered to the legend.
class _RashGridPainter extends _ScenePainter {
  _RashGridPainter({required super.p, required super.badges});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const cols = 4;
    const rows = 2;
    final cw = w / cols;
    final ch = h / rows;
    final dot = Paint()..color = p.ink1.withValues(alpha: 0.35);
    final soft = Paint()..color = p.ink1.withValues(alpha: 0.12);

    for (var i = 0; i < 8; i++) {
      final cx = (i % cols) * cw;
      final cy = (i ~/ cols) * ch;
      final cell = Rect.fromLTWH(cx + 6, cy + 6, cw - 12, ch - 12);
      canvas.drawRRect(RRect.fromRectAndRadius(cell, const Radius.circular(10)),
          Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromRectAndRadius(cell, const Radius.circular(10)), ink);
      final c = cell.center;
      final u = cell.width / 10;
      switch (i) {
        case 0: // baby acne: a few small pimples
          for (final (dx, dy) in [(-2.0, -1.5), (0.5, -2.2), (1.8, 0.2), (-1.0, 1.4)]) {
            canvas.drawCircle(Offset(c.dx + dx * u, c.dy + dy * u), u * 0.5, dot);
          }
        case 1: // heat rash: many pinpoints
          for (var k = 0; k < 20; k++) {
            canvas.drawCircle(Offset(c.dx + ((k % 5) - 2) * u * 0.9, c.dy + ((k ~/ 5) - 1.5) * u * 0.9), u * 0.16, dot);
          }
        case 2: // eczema: a dry rough patch
          canvas.drawOval(Rect.fromCenter(center: c, width: u * 6, height: u * 4), soft);
          for (var k = 0; k < 6; k++) {
            canvas.drawLine(Offset(c.dx - u * 2 + k * u * 0.8, c.dy - u), Offset(c.dx - u * 2.4 + k * u * 0.8, c.dy + u), ink..strokeWidth = 1);
          }
        case 3: // cradle cap: greasy scales
          for (final (dx, dy) in [(-1.8, -1.2), (0.2, -1.6), (1.6, -0.4), (-0.8, 0.6), (1.0, 1.2)]) {
            canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(c.dx + dx * u, c.dy + dy * u), width: u * 1.6, height: u * 1.1), Radius.circular(u * 0.3)), soft);
          }
        case 4: // nappy rash: a red zone where the nappy sits
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(c.dx, c.dy + u * 0.5), width: u * 6, height: u * 3.5), Radius.circular(u)), soft);
          canvas.drawLine(Offset(c.dx - u * 3.5, c.dy - u * 1.5), Offset(c.dx + u * 3.5, c.dy - u * 1.5), ink);
        case 5: // HFMD: small blisters
          for (final (dx, dy) in [(-2.0, -1.0), (0.0, -1.8), (2.0, -0.8), (-1.0, 1.2), (1.2, 1.4)]) {
            canvas.drawCircle(Offset(c.dx + dx * u, c.dy + dy * u), u * 0.55, Paint()..color = Colors.white);
            canvas.drawCircle(Offset(c.dx + dx * u, c.dy + dy * u), u * 0.55, ink..strokeWidth = 1.5);
          }
        case 6: // chickenpox: crops, some crusted
          for (final (dx, dy, crust) in [(-2.0, -1.4, false), (0.3, -2.0, true), (1.9, -0.2, false), (-1.2, 0.8, true), (1.0, 1.6, false), (-2.2, 1.8, false)]) {
            canvas.drawCircle(Offset(c.dx + dx * u, c.dy + dy * u), u * 0.5, crust ? dot : soft);
            canvas.drawCircle(Offset(c.dx + dx * u, c.dy + dy * u), u * 0.5, ink..strokeWidth = 1.2);
          }
        default: // hives: raised welts that move
          for (final (dx, dy) in [(-1.6, -1.0), (1.2, -0.2), (-0.4, 1.4)]) {
            canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(c.dx + dx * u, c.dy + dy * u), width: u * 3, height: u * 1.6), Radius.circular(u)), soft);
            canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(c.dx + dx * u, c.dy + dy * u), width: u * 3, height: u * 1.6), Radius.circular(u)), ink..strokeWidth = 1.2);
          }
      }
      badge(canvas, i + 1, Offset(cell.left + 14, cell.top + 14));
    }
  }
}
