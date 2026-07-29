// =============================================================================
//  TTC - Nutrition Planner
// -----------------------------------------------------------------------------
//  Not a meal plan to follow. A week of ideas built from the same library that
//  feeds Today's nutrition card, so the planner and the daily card can never
//  suggest two different things on the same day.
//
//  The rules this screen keeps, from §3.9 and the product's standing content
//  rules:
//
//   * Indian-family first. Every entry carries an India-specific line, and that
//     line is the part that makes it ours rather than translated.
//   * No calorie counting, no macros, no diet culture, and no plan to fall off.
//     There is nothing to tick and nothing to complete.
//   * Both of you. Nutrition in this stage is not "her diet" - zinc is his in
//     the same way folate is hers.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_daily_data.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

void openTtcNutrition(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcNutritionScreen(),
    settings: const RouteSettings(name: 'ttc/nutrition'),
  ));
}

class TtcNutritionScreen extends StatelessWidget {
  const TtcNutritionScreen({super.key});

  /// The coming week, built from the same rotation Today uses - so the planner
  /// and the daily card agree by construction rather than by coincidence.
  static List<(DateTime, TtcNutrition)> weekFrom(DateTime start) => [
        for (var i = 0; i < 7; i++)
          (
            DateTime(start.year, start.month, start.day + i),
            ttcPickForToday(ttcNutrition,
                now: DateTime(start.year, start.month, start.day + i),
                offset: 1),
          )
      ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final week = weekFrom(DateTime.now());
        // The nutrients this week actually leans on - a summary of the week
        // rather than a target to hit.
        final nutrients =
            week.map((e) => e.$2.nutrient(hi)).toSet().toList();

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.nutritionTitle),
                const SizedBox(height: 16),
                Text(t.nutritionIntro, style: ttcBody(14, h: 1.6)),
                const SizedBox(height: 20),

                TtcCard(
                  color: ttcPanel,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ttcEyebrow(t.nutritionFocus, color: ttcPurple),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final n in nutrients)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999)),
                                child: Text(n,
                                    style: ttcBody(12,
                                        color: ttcPurple,
                                        w: FontWeight.w800)),
                              ),
                          ],
                        ),
                      ]),
                ),
                const SizedBox(height: 20),

                ttcSectionTitle(t.nutritionWeek),
                for (final (day, n) in week) ...[
                  _DayCard(day: day, nutrition: n, t: t),
                  const SizedBox(height: 11),
                ],

                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(t.nutritionDisclaimer,
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.nutrition, required this.t});

  final DateTime day;
  final TtcNutrition nutrition;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final today = DateTime.now();
    final isToday = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;

    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(isToday ? t.calendarToday : _weekday(day),
              style: ttcBody(11.5,
                  color: isToday ? ttcPurple : ttcMuted,
                  w: FontWeight.w800)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: ttcPanel, borderRadius: BorderRadius.circular(999)),
            child: Text(nutrition.nutrient(hi),
                style: ttcBody(11, color: ttcPurple, w: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(nutrition.meal(hi), style: ttcJakarta(15.5)),
        const SizedBox(height: 7),
        Text(nutrition.why(hi), style: ttcBody(13, h: 1.5)),
        const SizedBox(height: 12),
        // The India-first line. The part that makes this ours.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF6EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.emoji_objects_outlined, size: 15, color: ttcBrown),
            const SizedBox(width: 9),
            Expanded(
              child: Text(nutrition.indian(hi),
                  style:
                      ttcBody(12.5, color: ttcBrown, h: 1.5, w: FontWeight.w600)),
            ),
          ]),
        ),
      ]),
    );
  }

  static String _weekday(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return days[d.weekday - 1];
  }
}
