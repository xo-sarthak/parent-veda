// =============================================================================
//  LivingHalo
// -----------------------------------------------------------------------------
//  The Size Reveal centrepiece: one calm container for every week — soft
//  concentric rings with the week's figure gently floating at the centre. The
//  figure crossfades between the week's Fruit emoji and an original cartoon
//  Baby illustration (a stage-accurate embryo for weeks 4–5, a growing
//  silhouette for later weeks). No rotating shimmer or hard pulse.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../theme/app_theme.dart';
import '../cards/food_emoji.dart';

class LivingHalo extends StatefulWidget {
  const LivingHalo({
    super.key,
    required this.week,
    required this.babyMode,
    required this.lang,
  });

  final int week;
  final bool babyMode;
  final AppLanguage lang;

  @override
  State<LivingHalo> createState() => _LivingHaloState();
}

class _LivingHaloState extends State<LivingHalo> with TickerProviderStateMixin {
  late final AnimationController _morph; // flipbook entry in baby mode
  late final AnimationController _float; // slow vertical float

  @override
  void initState() {
    super.initState();
    _morph = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150), value: 1);
    _float = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3800))
      ..repeat(reverse: true);
    if (widget.babyMode) _morph.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant LivingHalo old) {
    super.didUpdateWidget(old);
    // Flipbook: replay the quick morph when the week changes in baby mode.
    if (widget.babyMode && widget.week != old.week) {
      _morph.forward(from: 0);
    }
    if (widget.babyMode && !old.babyMode) {
      _morph.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _morph.dispose();
    _float.dispose();
    super.dispose();
  }

  /// Picks the right "baby mode" art for this week. The earliest weeks show
  /// genuinely different *stages* (a ball of cells, then a curled embryo); from
  /// week 6 on, a single curled figure that *develops* week by week — never the
  /// same silhouette zoomed in.
  CustomPainter _babyPainter() {
    final entry = 0.6 + 0.4 * _morph.value; // gentle flipbook scale-in
    if (widget.week <= 5) {
      return _EmbryoStagePainter(week: widget.week, t: entry);
    }
    return _GrowingBabyPainter(week: widget.week, t: entry);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 210,
      child: AnimatedBuilder(
        animation: Listenable.merge([_float, _morph]),
        builder: (context, _) {
          final f = Curves.easeInOut.transform(_float.value); // 0..1
          final dy = (f - 0.5) * 12; // gentle ~±6px bob
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer soft ring.
              Container(
                width: 196,
                height: 196,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary100.withValues(alpha: 0.35),
                ),
              ),
              // Middle ring.
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary100.withValues(alpha: 0.6),
                ),
              ),
              // Inner clean disc the figure sits on.
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.surface, AppTheme.secondary50],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondary500.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
              // The gently floating figure: fruit emoji or baby illustration.
              Transform.translate(
                offset: Offset(0, dy),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  child: widget.babyMode
                      ? _BabyFigure(
                          key: ValueKey('baby${widget.week}'),
                          week: widget.week,
                          fallback: _babyPainter(),
                        )
                      : Text(
                          foodEmojiForWeek(widget.week),
                          key: ValueKey('fruit${widget.week}'),
                          style: const TextStyle(fontSize: 66),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shows the per-week baby illustration from `assets/baby/week_NN.jpg` when one
/// exists, and otherwise falls back to the built-in vector drawing. This lets
/// real artwork be dropped in week by week without any code change.
///
/// The provided artwork has a soft-pink background baked in (not transparent),
/// so the image is clipped to a circle: the square edges vanish and the image's
/// own pink blends into the surrounding rings — the figure reads as floating in
/// the halo rather than sitting in a square box.
class _BabyFigure extends StatelessWidget {
  const _BabyFigure({super.key, required this.week, required this.fallback});

  final int week;
  final CustomPainter fallback;

  String get _asset =>
      'assets/baby/week_${week.toString().padLeft(2, '0')}.jpg';

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        _asset,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        // No image for this week yet → use the vector figure (it sits well
        // within the circle, so the clip never crops it).
        errorBuilder: (context, error, stack) => CustomPaint(
          size: const Size(122, 122),
          painter: fallback,
        ),
      ),
    );
  }
}

/// Stage-accurate early-pregnancy art (weeks 4–5), drawn fresh per stage so the
/// "first appearance → forming embryo" transformation reads clearly:
///   • Week 4 — a blastocyst: a soft membrane holding a little cluster of cells.
///   • Week 5 — the first embryo: a curled C-shaped body with a head, eye spot
///     and a tiny limb bud, the baby's very first form.
/// [t] (0.6..1) drives a gentle scale/fade-in flipbook when the week appears.
class _EmbryoStagePainter extends CustomPainter {
  _EmbryoStagePainter({required this.week, required this.t});
  final int week;
  final double t;

  static const Color _peachLight = Color(0xFFFFD9C6);
  static const Color _peachMid = Color(0xFFFFC2A6);
  static const Color _peachDeep = Color(0xFFF7A98A);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final base = size.width * 0.5;
    final alpha = t.clamp(0.0, 1.0);
    if (week <= 4) {
      _paintBlastocyst(canvas, c, base * 0.82 * t, alpha);
    } else {
      _paintEmbryo(canvas, c, base * 0.92 * t, alpha);
    }
  }

  // Week 4 — a ball of cells inside a soft membrane.
  void _paintBlastocyst(Canvas canvas, Offset c, double r, double alpha) {
    // Outer membrane (zona pellucida).
    canvas.drawCircle(
        c, r, Paint()..color = _peachLight.withValues(alpha: 0.45 * alpha));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..color = _peachMid.withValues(alpha: 0.7 * alpha),
    );

    // Inner cell mass — a few overlapping cells in two warm shades.
    final cells = <(Offset, double, Color)>[
      (Offset(c.dx - r * 0.30, c.dy - r * 0.24), r * 0.40, _peachMid),
      (Offset(c.dx + r * 0.28, c.dy - r * 0.28), r * 0.36, _peachLight),
      (Offset(c.dx + r * 0.32, c.dy + r * 0.26), r * 0.38, _peachDeep),
      (Offset(c.dx - r * 0.30, c.dy + r * 0.28), r * 0.34, _peachLight),
      (Offset(c.dx + r * 0.02, c.dy + r * 0.02), r * 0.42, _peachMid),
    ];
    for (final (pos, cr, col) in cells) {
      canvas.drawCircle(pos, cr, Paint()..color = col.withValues(alpha: alpha));
      // soft highlight
      canvas.drawCircle(
        Offset(pos.dx - cr * 0.30, pos.dy - cr * 0.32),
        cr * 0.30,
        Paint()..color = Colors.white.withValues(alpha: 0.35 * alpha),
      );
    }
  }

  // Week 5 — a curled C-shaped embryo with a head, eye spot and limb bud.
  void _paintEmbryo(Canvas canvas, Offset c, double r, double alpha) {
    final headC = Offset(c.dx + r * 0.20, c.dy - r * 0.46);
    final bodyRect = Rect.fromCircle(center: c, radius: r);

    // Curled body as a thick, round-capped C stroke with a peach gradient.
    final body = Path()
      ..moveTo(headC.dx, headC.dy + r * 0.10)
      ..quadraticBezierTo(
          c.dx - r * 0.62, c.dy - r * 0.10, c.dx - r * 0.12, c.dy + r * 0.46)
      ..quadraticBezierTo(
          c.dx + r * 0.18, c.dy + r * 0.78, c.dx + r * 0.50, c.dy + r * 0.46);
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.46
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_peachLight, _peachDeep],
        ).createShader(bodyRect),
    );

    // Head.
    canvas.drawCircle(
        headC, r * 0.40, Paint()..color = _peachLight.withValues(alpha: alpha));
    canvas.drawCircle(
        headC, r * 0.40,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.04
          ..color = _peachDeep.withValues(alpha: 0.5 * alpha));

    // Eye spot (the dark dot visible on early embryos).
    canvas.drawCircle(
      Offset(headC.dx - r * 0.06, headC.dy + r * 0.04),
      r * 0.07,
      Paint()..color = AppTheme.neutral700.withValues(alpha: 0.85 * alpha),
    );

    // Tiny limb bud.
    canvas.drawCircle(
      Offset(c.dx - r * 0.28, c.dy + r * 0.18),
      r * 0.12,
      Paint()..color = _peachMid.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_EmbryoStagePainter old) =>
      old.week != week || old.t != t;
}

/// An original, soft-shaded "growing baby": a curled, left-facing side-profile
/// figure that genuinely *develops* with the week — a big-headed early fetus
/// (~wk 6) that lengthens, rounds out, grows real arms and legs, and gains
/// facial features (closed eye, nose, mouth, ear, chubby cheek) toward a full
/// curled newborn (~wk 40). Proportions are driven by [week], so each week
/// looks distinct rather than the same shape scaled. [t] (0.6..1) is the gentle
/// flipbook scale-in when the figure appears.
class _GrowingBabyPainter extends CustomPainter {
  _GrowingBabyPainter({required this.week, required this.t});
  final int week;
  final double t;

  static const Color _light = Color(0xFFFFE2D1);
  static const Color _mid = Color(0xFFFFC8AE);
  static const Color _deep = Color(0xFFF3A083);
  static const Color _crease = Color(0xFFE08C6B);

  // Developmental progress 0 (wk6) → 1 (wk40).
  double get _p => ((week - 6) / (40 - 6)).clamp(0.0, 1.0);
  // Facial features fade in ~wk10 → wk23.
  double get _face => ((week - 10) / 13).clamp(0.0, 1.0);
  // Arms/legs grow in ~wk8 → wk18.
  double get _limb => ((week - 8) / 10).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final s = size.shortestSide;
    final p = _p, face = _face, limb = _limb;

    // Flipbook scale-in around the centre.
    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.scale(t);
    canvas.translate(-w / 2, -h / 2);

    Offset pt(double nx, double ny) => Offset(nx * w, ny * h);

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_light, _deep],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // 1) Soft grounding shadow beneath the curl.
    canvas.drawOval(
      Rect.fromCenter(center: pt(0.52, 0.88), width: s * 0.5, height: s * 0.11),
      Paint()..color = _crease.withValues(alpha: 0.12),
    );

    // 2) A leg, behind the body, curling up toward the belly (lengthens later).
    if (limb > 0) {
      final legPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s * (0.13 + 0.06 * p)
        ..color = _mid;
      final hip = pt(0.62, 0.72);
      final knee = pt(0.40 - 0.05 * limb, 0.66);
      final foot = pt(0.47, 0.82);
      canvas.drawPath(
        Path()
          ..moveTo(hip.dx, hip.dy)
          ..quadraticBezierTo(knee.dx, knee.dy - s * 0.10, knee.dx, knee.dy)
          ..quadraticBezierTo(knee.dx, knee.dy + s * 0.12, foot.dx, foot.dy),
        legPaint,
      );
    }

    // 3) Body (torso + rump) — a single smooth curled mass, belly facing left.
    final body = Path()
      ..moveTo(w * 0.50, h * 0.44)
      ..cubicTo(w * 0.66, h * 0.40, w * 0.78, h * 0.50, w * 0.76, h * 0.62)
      ..cubicTo(w * 0.74, h * 0.77, w * 0.62, h * 0.87, w * 0.50, h * 0.85)
      ..cubicTo(w * 0.40, h * 0.835, w * 0.37, h * 0.70, w * 0.395, h * 0.60)
      ..cubicTo(w * 0.405, h * 0.52, w * 0.45, h * 0.46, w * 0.50, h * 0.44)
      ..close();
    canvas.drawPath(body, fill);

    // Soft belly crease for depth (where the leg tucks in).
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.42, h * 0.58)
        ..quadraticBezierTo(w * 0.52, h * 0.66, w * 0.60, h * 0.64),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02
        ..strokeCap = StrokeCap.round
        ..color = _crease.withValues(alpha: 0.18),
    );

    // 4) An arm across the chest, in front of the body (grows in).
    if (limb > 0) {
      final armPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s * (0.09 + 0.04 * p)
        ..color = _mid;
      canvas.drawLine(pt(0.55, 0.50), pt(0.42, 0.48 + 0.02 * (1 - limb)), armPaint);
    }

    // 5) Head — large early, a touch smaller (relatively) later.
    final headR = s * (0.255 - 0.045 * p);
    final headC = pt(0.44, 0.355);
    canvas.drawCircle(headC, headR, fill);
    // Soft sheen, upper-left (gives the figure a gentle 3D roundness).
    canvas.drawCircle(
      Offset(headC.dx - headR * 0.32, headC.dy - headR * 0.36),
      headR * 0.5,
      Paint()..color = Colors.white.withValues(alpha: 0.26),
    );

    // 6) Face / eye.
    if (face > 0) {
      final ink = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = _crease.withValues(alpha: 0.85 * face);
      // Chubby cheek (rounder with age).
      canvas.drawCircle(
        Offset(headC.dx - headR * 0.34, headC.dy + headR * 0.30),
        headR * (0.20 + 0.16 * p),
        Paint()..color = _light.withValues(alpha: 0.45),
      );
      // Closed, content eye.
      final eyeC = Offset(headC.dx - headR * 0.42, headC.dy - headR * 0.05);
      ink.strokeWidth = headR * 0.09;
      canvas.drawPath(
        Path()
          ..moveTo(eyeC.dx - headR * 0.17, eyeC.dy)
          ..quadraticBezierTo(
              eyeC.dx, eyeC.dy + headR * 0.16, eyeC.dx + headR * 0.17, eyeC.dy),
        ink,
      );
      // Tiny mouth.
      ink.strokeWidth = headR * 0.07;
      canvas.drawPath(
        Path()
          ..moveTo(headC.dx - headR * 0.46, headC.dy + headR * 0.34)
          ..quadraticBezierTo(headC.dx - headR * 0.34, headC.dy + headR * 0.42,
              headC.dx - headR * 0.24, headC.dy + headR * 0.34),
        ink,
      );
    } else {
      // Early embryo: a single dark eye spot, no formed face yet.
      canvas.drawCircle(
        Offset(headC.dx - headR * 0.38, headC.dy),
        headR * 0.16,
        Paint()..color = _crease.withValues(alpha: 0.85),
      );
    }

    // 7) A little ear, appearing with the face.
    if (face > 0) {
      canvas.drawCircle(
        Offset(headC.dx + headR * 0.58, headC.dy + headR * 0.06),
        headR * (0.16 + 0.04 * p),
        fill,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GrowingBabyPainter old) => old.week != week || old.t != t;
}
