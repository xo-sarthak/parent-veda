// =============================================================================
//  FatherHomeScreen — the Father Mode "Daily Moment"
// -----------------------------------------------------------------------------
//  The first screen a father sees each day. Not pregnancy education — a small
//  daily act of becoming a father: a warm greeting, a gentle "Today's Moment"
//  invitation, then three modules (Learn → Talk To Your Baby → Mission), a soft
//  acknowledgement, and an Emotional Check-In.
//
//  Same design language and palette as the mother Home, with the signature
//  accent shifted to the grounded slate (see father_modules.dart).
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/father_content_controller.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/father/father_modules.dart';
import '../widgets/home/home_modules.dart' show ModeToggle;

class FatherHomeScreen extends StatelessWidget {
  const FatherHomeScreen({
    super.key,
    required this.pregnancy,
    required this.father,
    required this.fatherMode,
    required this.onFatherModeChanged,
  });

  final PregnancyController pregnancy;
  final FatherContentController father;
  final bool fatherMode;
  final ValueChanged<bool> onFatherModeChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pregnancy, father]),
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final lang = pregnancy.language;
    final s = S(lang);

    if (pregnancy.isLoading || father.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Active day = the preview day (prototype review tool) or the real current
    // day of pregnancy.
    final activeDay = father.previewDay ?? pregnancy.currentDay;
    final week = (((activeDay - 1) ~/ 7) + 1).clamp(4, 40);
    final day = father.dayFor(activeDay, week);

    if (day == null) {
      return SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          children: [
            ModeToggle(fatherMode: fatherMode, onChanged: onFatherModeChanged),
            const SizedBox(height: 64),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(s.noContent, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      );
    }

    final hour = DateTime.now().hour;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          ModeToggle(fatherMode: fatherMode, onChanged: onFatherModeChanged),
          const SizedBox(height: 12),
          _FatherPreviewBar(
            father: father,
            activeDay: activeDay,
            week: week,
            exact: day.day == activeDay,
          ),
          const SizedBox(height: 18),
          FatherHeader(
            name: pregnancy.fatherName,
            week: week,
            day: activeDay,
            lang: lang,
            hour: hour,
            onLanguageChanged: pregnancy.setLanguage,
          ),
          const SizedBox(height: 20),
          FatherMomentCard(intro: day.intro.of(lang), lang: lang),
          const SizedBox(height: 16),
          FatherLearnModule(day: day, lang: lang, father: father),
          const SizedBox(height: 16),
          FatherTalkModule(day: day, lang: lang, father: father),
          const SizedBox(height: 16),
          FatherMissionModule(day: day, lang: lang, father: father),
          const SizedBox(height: 28),
          FatherCompletionBanner(lang: lang),
          const SizedBox(height: 22),
          FatherEmotionalCheckIn(day: day.day, lang: lang),
        ],
      ),
    );
  }
}

/// PROTOTYPE-ONLY review control (mirrors the mother Home's): step across
/// days/weeks to preview authored Father content. Remove before launch.
class _FatherPreviewBar extends StatelessWidget {
  const _FatherPreviewBar({
    required this.father,
    required this.activeDay,
    required this.week,
    required this.exact,
  });

  final FatherContentController father;
  final int activeDay;
  final int week;
  final bool exact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dayInWeek = ((activeDay - 1) % 7) + 1;
    final previewing = father.previewDay != null;

    Widget btn(IconData icon, VoidCallback onTap) => InkResponse(
          onTap: onTap,
          radius: 22,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 20, color: AppTheme.fatherSlate600),
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.fatherSlate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fatherSlate100, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_rounded, size: 15, color: AppTheme.fatherSlate500),
          const SizedBox(width: 6),
          btn(Icons.keyboard_double_arrow_left_rounded,
              () => father.setPreviewDay(activeDay - 7)),
          btn(Icons.chevron_left_rounded, () => father.setPreviewDay(activeDay - 1)),
          Expanded(
            child: Column(
              children: [
                Text('PREVIEW · Wk $week · Day $dayInWeek',
                    textAlign: TextAlign.center,
                    style: text.labelSmall?.copyWith(
                        color: AppTheme.fatherSlate700,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
                Text(
                    exact
                        ? 'day $activeDay of 280'
                        : 'day $activeDay · not authored yet (showing nearest)',
                    textAlign: TextAlign.center,
                    style: text.labelSmall?.copyWith(
                        color: exact ? AppTheme.neutral500 : AppTheme.secondary600,
                        fontSize: 10)),
              ],
            ),
          ),
          btn(Icons.chevron_right_rounded, () => father.setPreviewDay(activeDay + 1)),
          btn(Icons.keyboard_double_arrow_right_rounded,
              () => father.setPreviewDay(activeDay + 7)),
          if (previewing)
            btn(Icons.today_rounded, () => father.setPreviewDay(null)),
        ],
      ),
    );
  }
}
