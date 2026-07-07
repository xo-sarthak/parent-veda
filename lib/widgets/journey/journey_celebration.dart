// =============================================================================
//  Journey celebration  -  full-screen moment for a reached major milestone
// -----------------------------------------------------------------------------
//  Achievements and ParentVeda-journey milestones that the mother has already
//  reached open this celebratory full screen (large illustration, copy, and a
//  Continue button) instead of a bottom-sheet preview.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/journey_node.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';
import 'journey_palette.dart';

Future<void> showJourneyCelebration(
  BuildContext context, {
  required PregnancyController controller,
  required JourneyMilestone milestone,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, _, _) => _CelebrationScreen(
        controller: controller,
        milestone: milestone,
      ),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

class _CelebrationScreen extends StatefulWidget {
  const _CelebrationScreen({required this.controller, required this.milestone});

  final PregnancyController controller;
  final JourneyMilestone milestone;

  @override
  State<_CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<_CelebrationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final lang = widget.controller.language;
    final text = Theme.of(context).textTheme;
    final m = widget.milestone;
    final color = JourneyColors.forType(m.type);

    final body = m.sections.isNotEmpty ? m.sections.first.body.of(lang) : '';

    final scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    final fade = CurvedAnimation(parent: _c, curve: Curves.easeIn);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.16),
              AppTheme.scaffoldBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: scale,
                  child: Container(
                    width: 132,
                    height: 132,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Text(m.emoji, style: const TextStyle(fontSize: 64)),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: fade,
                  child: Column(
                    children: [
                      Text(
                        m.title.of(lang),
                        textAlign: TextAlign.center,
                        style: text.displaySmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: text.titleMedium?.copyWith(
                          color: AppTheme.neutral700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: color),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(s.continueJourney),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
