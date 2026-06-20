// =============================================================================
//  UpcomingSection  —  "Coming Up" below the map
// -----------------------------------------------------------------------------
//  Shows the next not-yet-reached milestone in each category (medical,
//  achievement, baby development, feature unlock) with how far away it is.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/journey_node.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';
import 'journey_palette.dart';

class UpcomingSection extends StatelessWidget {
  const UpcomingSection({
    super.key,
    required this.controller,
    required this.nodes,
    required this.onTap,
  });

  final PregnancyController controller;
  final List<MapNode> nodes;
  final void Function(JourneyMilestone) onTap;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final text = Theme.of(context).textTheme;
    final today = controller.currentDay;

    // First future milestone in each highlighted category, in journey order.
    const categories = [
      JourneyNodeType.medical,
      JourneyNodeType.achievement,
      JourneyNodeType.babyDev,
      JourneyNodeType.feature,
    ];

    final picks = <JourneyMilestone>[];
    for (final cat in categories) {
      for (final n in nodes) {
        final m = n.milestone;
        if (m != null && m.type == cat && m.posDay > today) {
          picks.add(m);
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.comingUpTitle, style: text.headlineSmall),
        const SizedBox(height: 12),
        if (picks.isEmpty)
          Text(s.nothingUpcoming, style: text.bodyMedium)
        else
          for (final m in picks) ...[
            _UpcomingTile(
              milestone: m,
              weeksAway: ((m.posDay - today) / 7).ceil(),
              label: m.title.of(lang),
              when: s.inWeeksShort(((m.posDay - today) / 7).ceil()),
              color: JourneyColors.forType(m.type),
              onTap: () => onTap(m),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({
    required this.milestone,
    required this.weeksAway,
    required this.label,
    required this.when,
    required this.color,
    required this.onTap,
  });

  final JourneyMilestone milestone;
  final int weeksAway;
  final String label;
  final String when;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child:
                    Text(milestone.emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(when, style: text.labelMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}
