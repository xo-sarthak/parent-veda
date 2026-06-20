// =============================================================================
//  Journey node cards
// -----------------------------------------------------------------------------
//  A single bottom-sheet that adapts to the milestone type:
//    * achievement / pvJourney → celebration copy + Continue
//    * medical                 → info sheet (why / timing / tips / questions)
//    * babyDev                 → development card (+ View Week)
//    * mother                  → experience card
//    * feature                 → preview + Launch (which is "coming soon")
//  Future milestones show an "expected in N weeks" preview note.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/journey_node.dart';
import '../../screens/tools/baby_movement_screen.dart';
import '../../screens/tools/contraction_tracker_screen.dart';
import '../../screens/tools/kegel_care_screen.dart';
import '../../screens/tools/weight_tracker_screen.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';
import 'journey_palette.dart';

/// Opens the milestone card. [onViewWeek] is called (after the sheet closes)
/// when the user taps a "View Week N" action.
Future<void> showJourneyNodeCard(
  BuildContext context, {
  required PregnancyController controller,
  required JourneyMilestone milestone,
  required void Function(int week) onViewWeek,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    showDragHandle: true,
    builder: (ctx) => _NodeCard(
      controller: controller,
      milestone: milestone,
      onViewWeek: onViewWeek,
    ),
  );
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.controller,
    required this.milestone,
    required this.onViewWeek,
  });

  final PregnancyController controller;
  final JourneyMilestone milestone;
  final void Function(int week) onViewWeek;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final text = Theme.of(context).textTheme;
    final m = milestone;
    final color = JourneyColors.forType(m.type);

    final reached = m.posDay <= controller.currentDay;
    final weeksAway =
        reached ? 0 : ((m.posDay - controller.currentDay) / 7).ceil();

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: emoji badge + type eyebrow + title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(m.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _typeLabel(s, m.type),
                          style: text.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.title.of(lang),
                          style: text.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Timing line: range label, or "reached on" / "expected in".
              _timingLine(context, s, lang, reached, weeksAway, color),

              const SizedBox(height: 16),

              // Sections
              for (final sec in m.sections) ...[
                if (sec.label.of(lang).trim().isNotEmpty) ...[
                  Text(
                    sec.label.of(lang),
                    style: text.labelLarge?.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(sec.body.of(lang), style: text.bodyLarge),
                ] else
                  Text(
                    sec.body.of(lang),
                    style: text.titleMedium?.copyWith(height: 1.5),
                  ),
                const SizedBox(height: 14),
              ],

              // Bullet blocks
              for (final block in m.bullets) ...[
                Text(
                  block.label.of(lang),
                  style: text.labelLarge?.copyWith(color: color),
                ),
                const SizedBox(height: 6),
                for (final item in block.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7, right: 8),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(item.of(lang), style: text.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              if (m.type == JourneyNodeType.medical) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.medicalDisclaimer,
                          style: text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              const SizedBox(height: 4),
              _actions(context, s, color, reached),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timingLine(
    BuildContext context,
    S s,
    AppLanguage lang,
    bool reached,
    int weeksAway,
    Color color,
  ) {
    final text = Theme.of(context).textTheme;
    String label;
    IconData icon;
    if (!reached) {
      icon = Icons.schedule_rounded;
      label = s.expectedInWeeks(weeksAway);
    } else if (milestone.type == JourneyNodeType.achievement) {
      icon = Icons.check_circle_rounded;
      final start = controller.weekDates(milestone.anchorWeek).start;
      label = s.reachedOn(s.formatLongDate(start));
    } else if (milestone.rangeLabel != null) {
      icon = Icons.event_rounded;
      label = milestone.rangeLabel!.of(lang);
    } else {
      icon = Icons.event_rounded;
      label = '${s.weekWord} ${milestone.anchorWeek}';
    }
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.neutral500),
        const SizedBox(width: 6),
        Text(label, style: text.labelMedium),
      ],
    );
  }

  Widget _actions(BuildContext context, S s, Color color, bool reached) {
    final m = milestone;

    if (m.type == JourneyNodeType.feature) {
      final builder = _toolBuilder(m.id);
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: color),
          onPressed: () {
            Navigator.of(context).pop();
            if (builder != null) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => builder()));
            } else {
              _showComingSoon(context, s, color, m.emoji);
            }
          },
          icon: const Icon(Icons.lock_open_rounded, size: 18),
          label: Text(s.launchFeatureCta),
        ),
      );
    }

    if (m.ctaWeek != null) {
      final week = m.ctaWeek!;
      return Row(
        children: [
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: () {
                Navigator.of(context).pop();
                onViewWeek(week);
              },
              child: Text(s.viewWeekN(week)),
            ),
          ),
        ],
      );
    }

    // Celebration-style close (achievements, mother, pvJourney with no CTA).
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(s.continueJourney),
      ),
    );
  }

  /// Maps a feature-unlock milestone to its real tool screen, or null when the
  /// tool isn't built yet (→ coming-soon).
  Widget Function()? _toolBuilder(String id) {
    switch (id) {
      case 'f_movement':
        return () => BabyMovementScreen(controller: controller);
      case 'f_weight':
        return () => WeightTrackerScreen(controller: controller);
      case 'f_kegel':
        return () => KegelCareScreen(controller: controller);
      case 'f_contraction':
        return () => ContractionTrackerScreen(controller: controller);
      default: // f_hospital — not built yet
        return null;
    }
  }

  void _showComingSoon(
      BuildContext context, S s, Color color, String emoji) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Text(emoji, style: const TextStyle(fontSize: 34)),
        title: Text(s.featureComingSoonTitle, textAlign: TextAlign.center),
        content: Text(s.featureComingSoonBody, textAlign: TextAlign.center),
        actions: [
          Center(
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(s.gotIt),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(S s, JourneyNodeType type) {
    switch (type) {
      case JourneyNodeType.achievement:
        return s.typeAchievementLabel;
      case JourneyNodeType.medical:
        return s.typeMedicalLabel;
      case JourneyNodeType.babyDev:
        return s.typeBabyLabel;
      case JourneyNodeType.mother:
        return s.typeMotherLabel;
      case JourneyNodeType.pvJourney:
        return s.typePvLabel;
      case JourneyNodeType.feature:
        return s.typeFeatureLabel;
      case JourneyNodeType.week:
        return s.weekWord;
    }
  }
}
