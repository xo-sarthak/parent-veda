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
import '../../services/pregnancy_controller.dart';
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

  double get _growth {
    const first = PregnancyController.firstContentWeek;
    const last = PregnancyController.lastContentWeek;
    final t = ((widget.week - first) / (last - first)).clamp(0.0, 1.0);
    return 0.42 + 0.58 * t; // baby fills from ~42% to 100%
  }

  /// Picks the right "baby mode" art for this week. The earliest weeks show
  /// genuinely different *stages* (a ball of cells, then a curled embryo) rather
  /// than the same silhouette zoomed in. Later weeks keep the soft
  /// growing-bump silhouette.
  CustomPainter _babyPainter() {
    final entry = 0.6 + 0.4 * _morph.value; // gentle flipbook scale-in
    if (widget.week <= 5) {
      return _EmbryoStagePainter(week: widget.week, t: entry);
    }
    return _BabyBumpPainter(growth: _growth * entry);
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
                      ? CustomPaint(
                          key: ValueKey('baby${widget.week}'),
                          size: const Size(122, 122),
                          painter: _babyPainter(),
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

/// An original soft "baby bump" silhouette: a curled cartoon baby that grows
/// with [growth] (0..1 of the inner circle).
class _BabyBumpPainter extends CustomPainter {
  _BabyBumpPainter({required this.growth});
  final double growth;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.width * 0.5 * growth.clamp(0.2, 1.0);
    final body = Paint()..color = const Color(0xFFFFD9C2); // soft peach
    final shade = Paint()..color = const Color(0xFFFFC4A8);

    // Curled body (a soft kidney/bean shape)
    final bodyPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(c.dx + s * 0.18, c.dy + s * 0.30), radius: s * 0.62));
    canvas.drawPath(bodyPath, body);

    // Head
    final headC = Offset(c.dx - s * 0.30, c.dy - s * 0.34);
    canvas.drawCircle(headC, s * 0.46, body);
    // cheek shade
    canvas.drawCircle(Offset(headC.dx - s * 0.12, headC.dy + s * 0.16), s * 0.12, shade);

    // tiny knee bump
    canvas.drawCircle(Offset(c.dx + s * 0.55, c.dy + s * 0.55), s * 0.22, shade);

    // closed eye + smile on the head (only when big enough to read)
    if (growth > 0.45) {
      final ink = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.05
        ..strokeCap = StrokeCap.round
        ..color = AppTheme.neutral700;
      final eye = Path()
        ..moveTo(headC.dx - s * 0.02, headC.dy - s * 0.06)
        ..quadraticBezierTo(headC.dx + s * 0.10, headC.dy + s * 0.02, headC.dx + s * 0.20, headC.dy - s * 0.06);
      canvas.drawPath(eye, ink);
    }
  }

  @override
  bool shouldRepaint(_BabyBumpPainter old) => old.growth != growth;
}
