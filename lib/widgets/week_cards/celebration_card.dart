// =============================================================================
//  Week 40 · Celebration finale
// -----------------------------------------------------------------------------
//  A calm, premium "Welcome, little one." moment: a soft baby orb, an elegant
//  title, a short message, and a single button to download the keepsake booklet.
//  Gentle bokeh drifts behind it and re-fires every time the card appears.
//  Deliberately simple — no emoji clutter, no on-card memories grid.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../screens/journey_booklet_screen.dart';
import '../../theme/app_theme.dart';

class CelebrationCard extends StatefulWidget {
  const CelebrationCard({
    super.key,
    required this.language,
    required this.dateRanges,
    required this.completionDate,
  });

  final AppLanguage language;

  /// Pre-formatted "22–28 Oct" range per week (4–40), for the booklet.
  final Map<int, String> dateRanges;
  final String completionDate;

  @override
  State<CelebrationCard> createState() => _CelebrationCardState();
}

class _CelebrationCardState extends State<CelebrationCard>
    with TickerProviderStateMixin {
  // Slow drifting bokeh behind the scene.
  late final AnimationController _drift;
  // A soft entrance for the orb + title each time the card appears.
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))
      ..repeat();
    _intro = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fire the gentle celebration every time the card becomes visible.
    _intro.forward(from: 0);
    _drift
      ..reset()
      ..repeat();
  }

  @override
  void dispose() {
    _drift.dispose();
    _intro.dispose();
    super.dispose();
  }

  void _openBooklet() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JourneyBookletScreen(
        lang: widget.language,
        dateRanges: widget.dateRanges,
        completionDate: widget.completionDate,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(widget.language);

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // Soft blush easing into clean white — calm, not loud.
                colors: [AppTheme.secondary50, AppTheme.primary50, Colors.white],
                stops: [0.0, 0.5, 1.0],
              ),
              border: Border.all(color: AppTheme.outlineVariant, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Gentle drifting bokeh.
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _drift,
                    builder: (context, _) =>
                        CustomPaint(painter: _BokehPainter(_drift.value)),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _badge(text, s),
                            const SizedBox(height: 34),
                            _intro1(child: _babyOrb()),
                            const SizedBox(height: 30),
                            _intro1(
                              child: Text(
                                s.celebrationTitle,
                                textAlign: TextAlign.center,
                                style: text.displaySmall?.copyWith(
                                  fontSize: 38,
                                  color: AppTheme.primary800,
                                  fontWeight: FontWeight.w600,
                                  height: 1.08,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.celebrationSubtitle,
                              textAlign: TextAlign.center,
                              style: text.titleMedium?.copyWith(
                                color: AppTheme.primary500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Text(
                                s.celebrationBody,
                                textAlign: TextAlign.center,
                                style: text.bodyMedium?.copyWith(
                                  color: AppTheme.neutral600,
                                  height: 1.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              s.appName.toUpperCase(),
                              style: text.labelSmall?.copyWith(
                                color: AppTheme.primary400,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openBooklet,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary500,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            label: Text(
              s.createBooklet,
              style: text.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Soft fade + rise entrance driven by the intro controller.
  Widget _intro1({required Widget child}) {
    return AnimatedBuilder(
      animation: _intro,
      builder: (context, c) {
        final v = Curves.easeOutCubic.transform(_intro.value.clamp(0.0, 1.0));
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * 14), child: c),
        );
      },
      child: child,
    );
  }

  Widget _badge(TextTheme text, S s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppTheme.secondary100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 15, color: AppTheme.secondary500),
            const SizedBox(width: 8),
            Text(
              s.celebrationBadge,
              style: text.labelMedium?.copyWith(
                color: AppTheme.primary700,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );

  Widget _babyOrb() => Container(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Colors.white, AppTheme.secondary50],
            stops: [0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondary400.withValues(alpha: 0.28),
              blurRadius: 44,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Text('👶', style: TextStyle(fontSize: 68)),
      );
}

/// Soft, slow-drifting pastel bokeh — a calm celebratory shimmer, far quieter
/// than confetti. Deterministic layout, gentle downward drift, low opacity.
class _BokehPainter extends CustomPainter {
  _BokehPainter(this.t);

  /// 0..1 loop phase driving the slow drift.
  final double t;

  static const _colors = [
    AppTheme.secondary200,
    AppTheme.primary200,
    AppTheme.secondary100,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(11); // fixed seed → stable, pleasing layout
    final count = (size.width * size.height / 18000).clamp(10, 26).toInt();
    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final speed = 0.25 + rng.nextDouble() * 0.4;
      final startY = rng.nextDouble();
      final y = ((startY + t * speed) % 1.0) * size.height;
      final r = 4.0 + rng.nextDouble() * 9.0;
      final color = _colors[i % _colors.length]
          .withValues(alpha: 0.10 + 0.12 * rng.nextDouble());
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_BokehPainter oldDelegate) => oldDelegate.t != t;
}
