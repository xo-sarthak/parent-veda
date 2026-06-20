// =============================================================================
//  MyBabyScreen
// -----------------------------------------------------------------------------
//  The "My Baby" tab. Its home is the entry point into the Week-on-Week Card
//  Stack (the weekly pregnancy journey we built): a calm landing card the mother
//  taps to open her current week's full journey.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'weekly_card_stack_screen.dart';

class MyBabyScreen extends StatelessWidget {
  const MyBabyScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lang = controller.language;
    final s = S(lang);
    final week = controller.currentWeek;

    void openJourney() {
      // Always open the journey at the mother's current week, no matter which
      // week she last browsed to before leaving the stack.
      controller.selectWeek(controller.currentWeek);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WeeklyCardStackScreen(controller: controller),
      ));
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(s.myBabyTab,
              style: text.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: openJourney,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary500, AppTheme.primary700],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary500.withValues(alpha: 0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.spa_rounded, color: Colors.white, size: 26),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text('${s.weekWord} $week',
                        style: text.labelMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 18),
                Text(s.weeklyJourneyTitle,
                    style: text.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(s.weeklyJourneySubtitle,
                    style: text.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92), height: 1.5)),
                const SizedBox(height: 20),
                Row(children: [
                  Text(s.openWeeklyJourney,
                      style: text.labelLarge?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
