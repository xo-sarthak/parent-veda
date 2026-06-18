// =============================================================================
//  Week 40 · Celebration finale
// -----------------------------------------------------------------------------
//  The grand finale shown as the very last card on week 40 — a festive, joyful
//  "Welcome, little one." moment with confetti that re-fires EVERY time the card
//  becomes visible, celebration emojis and a baby orb. A button opens the
//  keepsake-booklet flow: fill any missing weeks, then generate a multi-page PDF
//  of the whole journey. Fully bilingual.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../screens/journey_booklet_screen.dart';
import '../../services/memory_store.dart';
import '../../theme/app_theme.dart';
import '../memories/memories_section.dart';

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
  // Continuous gentle confetti fall.
  late final AnimationController _confetti;
  // A quick pop for the emojis + baby orb each time the card appears.
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _confetti = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _intro = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fire the celebration every time the card becomes visible again.
    _intro.forward(from: 0);
    _confetti
      ..reset()
      ..repeat();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _intro.dispose();
    super.dispose();
  }

  void _openBooklet(S s) {
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary100,
                    AppTheme.secondary100,
                    AppTheme.surface,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
                border: Border.all(color: AppTheme.outlineVariant, width: 1),
              ),
              child: Stack(
                children: [
                  // Festive, looping confetti behind everything.
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _confetti,
                      builder: (context, _) => CustomPaint(
                        painter: _ConfettiPainter(_confetti.value),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                    child: Column(
                      children: [
                        _badge(text, s),
                        const SizedBox(height: 22),
                        _pop(child: const Text('🎉  🥳  🎊',
                            style: TextStyle(fontSize: 26))),
                        const SizedBox(height: 18),
                        _pop(child: _babyOrb()),
                        const SizedBox(height: 22),
                        Text(
                          s.celebrationTitle,
                          textAlign: TextAlign.center,
                          style: text.displayMedium
                              ?.copyWith(color: AppTheme.primary800),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.celebrationSubtitle,
                          textAlign: TextAlign.center,
                          style: text.titleLarge?.copyWith(
                            color: AppTheme.primary600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s.celebrationBody,
                            textAlign: TextAlign.center,
                            style: text.bodyLarge?.copyWith(height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 22),
                        // A small on-card preview of the journey's memories.
                        AnimatedBuilder(
                          animation: MemoryStore.instance,
                          builder: (context, _) =>
                              MemoryCollage(lang: widget.language),
                        ),
                        const SizedBox(height: 8),
                        Text('💕  ${s.appName}  💕',
                            style: text.labelMedium?.copyWith(
                                color: AppTheme.primary500,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _openBooklet(s),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary500,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.auto_stories_rounded, color: Colors.white),
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

  /// Gentle scale + fade-in driven by the intro controller.
  Widget _pop({required Widget child}) {
    return AnimatedBuilder(
      animation: _intro,
      builder: (context, c) {
        final t = Curves.elasticOut.transform(_intro.value.clamp(0.0, 1.0));
        return Opacity(
          opacity: _intro.value.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.6 + 0.4 * t, child: c),
        );
      },
      child: child,
    );
  }

  Widget _badge(TextTheme text, S s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration_rounded, size: 16, color: AppTheme.primary600),
            const SizedBox(width: 8),
            Text(
              s.celebrationBadge,
              style: text.labelMedium?.copyWith(
                color: AppTheme.primary700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _babyOrb() => Container(
        width: 132,
        height: 132,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.surface, AppTheme.primary50],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary400.withValues(alpha: 0.30),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Text('👶', style: TextStyle(fontSize: 60)),
      );
}

/// Soft, deterministic confetti — little dots and tilted ribbons in the app's
/// palette that fall gently and loop, so the finale always feels celebratory.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);

  /// 0..1 loop phase driving the fall.
  final double t;

  static const _colors = [
    AppTheme.primary400,
    AppTheme.secondary400,
    AppTheme.tertiary400,
    AppTheme.primary300,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7); // fixed seed → stable, pleasing layout
    final count = (size.width * size.height / 9000).clamp(24, 80).toInt();
    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      // Each piece falls at its own speed and wraps around.
      final speed = 0.5 + rng.nextDouble();
      final startY = rng.nextDouble();
      final y = ((startY + t * speed) % 1.0) * size.height;
      final color = _colors[i % _colors.length]
          .withValues(alpha: 0.18 + 0.22 * rng.nextDouble());
      final paint = Paint()..color = color;
      if (i.isEven) {
        canvas.drawCircle(Offset(x, y), 2.0 + rng.nextDouble() * 2.5, paint);
      } else {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rng.nextDouble() * math.pi + t * math.pi * 2);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 4, height: 9),
            const Radius.circular(2),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
