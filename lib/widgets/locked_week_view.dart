// =============================================================================
//  LockedWeekView
// -----------------------------------------------------------------------------
//  A premium, comforting "this week is still ahead of you" state for future,
//  not-yet-unlocked weeks. Gentle floating clouds drift behind a frosted glass
//  panel with a softly glowing lock — reassuring, never a harsh error screen.
// =============================================================================

import 'dart:ui';

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../theme/app_theme.dart';

class LockedWeekView extends StatefulWidget {
  const LockedWeekView({
    super.key,
    required this.week,
    required this.currentWeek,
    required this.language,
  });

  final int week;
  final int currentWeek;
  final AppLanguage language;

  @override
  State<LockedWeekView> createState() => _LockedWeekViewState();
}

class _LockedWeekViewState extends State<LockedWeekView>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(widget.language);
    final weeksAway = widget.week - widget.currentWeek;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          // ---- Soft gradient sky ------------------------------------------
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary100,
                    AppTheme.surfaceContainer,
                    AppTheme.scaffoldBackground,
                  ],
                ),
              ),
            ),
          ),
          // ---- Gently floating clouds -------------------------------------
          _FloatingCloud(
            controller: _floatController,
            alignment: const Alignment(-0.7, -0.55),
            size: 120,
            phase: 0,
          ),
          _FloatingCloud(
            controller: _floatController,
            alignment: const Alignment(0.75, -0.2),
            size: 92,
            phase: 0.5,
          ),
          _FloatingCloud(
            controller: _floatController,
            alignment: const Alignment(-0.5, 0.7),
            size: 104,
            phase: 0.25,
          ),
          // ---- Frosted blur over the sky ----------------------------------
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                color: AppTheme.surface.withValues(alpha: 0.18),
              ),
            ),
          ),
          // ---- Centre content ---------------------------------------------
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GlowingLock(glow: _glowController),
                  const SizedBox(height: 28),
                  Text(
                    widget.language.isEnglish
                        ? 'Week ${widget.week}'
                        : 'Hafta ${widget.week}',
                    style: text.displaySmall?.copyWith(
                      color: AppTheme.primary700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.onItsWay,
                    textAlign: TextAlign.center,
                    style: text.titleLarge?.copyWith(
                      color: AppTheme.primary600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    weeksAway <= 1 ? s.openNextWeek : s.openInWeeks(weeksAway),
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(height: 1.55),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.spa_rounded,
                            size: 16, color: AppTheme.secondary400),
                        const SizedBox(width: 8),
                        Text(
                          s.youAreInWeek(widget.currentWeek),
                          style: text.labelMedium?.copyWith(
                            color: AppTheme.neutral700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCloud extends StatelessWidget {
  const _FloatingCloud({
    required this.controller,
    required this.alignment,
    required this.size,
    required this.phase,
  });

  final AnimationController controller;
  final Alignment alignment;
  final double size;

  /// 0..1 offset so clouds don't all bob in sync.
  final double phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + phase) % 1.0;
        final dy = (0.5 - (t - 0.5).abs()) * 18; // gentle vertical bob
        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(0, dy - 9),
            child: child,
          ),
        );
      },
      child: Icon(
        Icons.cloud_rounded,
        size: size,
        color: AppTheme.surface.withValues(alpha: 0.85),
      ),
    );
  }
}

class _GlowingLock extends StatelessWidget {
  const _GlowingLock({required this.glow});

  final AnimationController glow;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(glow.value);
        return Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary300, AppTheme.primary500],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary400.withValues(alpha: 0.25 + 0.35 * t),
                blurRadius: 24 + 22 * t,
                spreadRadius: 2 + 4 * t,
              ),
            ],
          ),
          child: const Icon(Icons.lock_rounded, color: Colors.white, size: 44),
        );
      },
    );
  }
}
