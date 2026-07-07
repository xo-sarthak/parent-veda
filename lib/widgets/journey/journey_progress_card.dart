// =============================================================================
//  JourneyProgressCard  -  the always-visible summary at the top of the map
// -----------------------------------------------------------------------------
//  Week • Day, trimester, days completed / remaining, a progress bar, and a
//  warm dynamic line - all derived from the PregnancyController.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';
import 'journey_palette.dart';

class JourneyProgressCard extends StatelessWidget {
  const JourneyProgressCard({super.key, required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final c = controller;
    final percent = c.progressPercent;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.journeyWeekDay(c.currentWeek, c.dayOfWeek),
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  s.trimesterName(c.currentWeek),
                  style: text.labelMedium?.copyWith(
                    color: AppTheme.primary600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  s.journeyDaysCompleted(c.daysCompleted, PregnancyController.termDays),
                  style: text.bodyMedium?.copyWith(color: AppTheme.neutral700),
                ),
              ),
              Text(
                s.journeyDaysRemaining(c.daysRemaining),
                style: text.bodyMedium?.copyWith(color: AppTheme.neutral500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: c.progress,
              minHeight: 10,
              backgroundColor: AppTheme.surfaceContainerHigh,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(JourneyColors.completed),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.journeyPercentComplete(percent),
            style: text.titleSmall?.copyWith(
              color: JourneyColors.completed,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.journeyEmotional(c.currentWeek, percent),
            style: text.bodyMedium?.copyWith(color: AppTheme.neutral700),
          ),
        ],
      ),
    );
  }
}
