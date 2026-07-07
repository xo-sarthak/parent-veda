// =============================================================================
//  HomeScreen - the Mother Home Screen (Daily Moment)
// -----------------------------------------------------------------------------
//  The first thing a mother sees each day: a warm acknowledgement, then a gentle
//  4–6 minute arc of six modules (Grow → Read → Talk → Garbh Sanskar → A Moment
//  For You → Baby Movement [wk 28+]), a soft completion message, and finally the
//  Emotional Check-In. Not a dashboard, not a checklist - a small daily moment.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/father_content_controller.dart';
import '../services/home_content_controller.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/home/home_modules.dart';
import 'father_home_screen.dart';
import 'read_next_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.pregnancy,
    required this.home,
    required this.father,
    required this.fatherMode,
    required this.onFatherModeChanged,
  });

  final PregnancyController pregnancy;
  final HomeContentController home;
  final FatherContentController father;

  /// Whether the Home tab is showing the father's view.
  final bool fatherMode;
  final ValueChanged<bool> onFatherModeChanged;

  @override
  Widget build(BuildContext context) {
    // Rebuild on language change (pregnancy) and content load (home).
    return AnimatedBuilder(
      animation: Listenable.merge([pregnancy, home]),
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final lang = pregnancy.language;
    final s = S(lang);

    if (pregnancy.isLoading || home.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Father Mode - the father's own Daily Moment.
    if (fatherMode) {
      return FatherHomeScreen(
        pregnancy: pregnancy,
        father: father,
        fatherMode: fatherMode,
        onFatherModeChanged: onFatherModeChanged,
      );
    }

    // Active day = the preview day (prototype review tool) or the real current
    // day of pregnancy.
    final activeDay = home.previewDay ?? pregnancy.currentDay;
    final week = (((activeDay - 1) ~/ 7) + 1).clamp(4, 40);
    final snapshot = pregnancy.weekData(week)?.snapshot;
    final day = home.dayFor(activeDay, week);

    if (snapshot == null || day == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(s.noContent, textAlign: TextAlign.center),
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
          _PreviewBar(
            home: home,
            activeDay: activeDay,
            week: week,
            exact: day.day == activeDay,
          ),
          const SizedBox(height: 18),
          HomeHeader(
            name: pregnancy.motherName,
            week: week,
            snapshot: snapshot,
            babyLearning: day.babyLearning,
            lang: lang,
            hour: hour,
            onLanguageChanged: pregnancy.setLanguage,
          ),
          const SizedBox(height: 22),
          MomentSummary(lang: lang),
          const SizedBox(height: 16),
          GrowModule(day: day, lang: lang, home: home),
          const SizedBox(height: 16),
          ReadModule(day: day, lang: lang, home: home),
          const SizedBox(height: 16),
          TalkModule(day: day, lang: lang, home: home),
          const SizedBox(height: 16),
          GarbhSanskarModule(day: day, lang: lang, home: home),
          const SizedBox(height: 16),
          NurtureModule(day: day, lang: lang, home: home),
          if (day.showsMovementCheckIn) ...[
            const SizedBox(height: 16),
            MovementModule(day: day, lang: lang, home: home),
          ],
          const SizedBox(height: 22),
          // Read Next - stage-aware reading discovery, surfaced on Home.
          ReadNextHomeCard(controller: pregnancy, lang: lang),
          const SizedBox(height: 28),
          CompletionBanner(lang: lang),
          const SizedBox(height: 22),
          EmotionalCheckIn(day: day.day, lang: lang),
        ],
      ),
    );
  }
}

/// PROTOTYPE-ONLY review control: step across days/weeks to preview authored
/// Home content. Shows the active day-of-pregnancy and flags when the day shown
/// is a fallback (i.e. that exact day isn't authored yet). Remove before launch.
class _PreviewBar extends StatelessWidget {
  const _PreviewBar({
    required this.home,
    required this.activeDay,
    required this.week,
    required this.exact,
  });

  final HomeContentController home;
  final int activeDay;
  final int week;
  final bool exact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dayInWeek = ((activeDay - 1) % 7) + 1;
    final previewing = home.previewDay != null;

    Widget btn(IconData icon, VoidCallback onTap) => InkResponse(
          onTap: onTap,
          radius: 22,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 20, color: AppTheme.primary600),
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary100, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility_rounded, size: 15, color: AppTheme.primary500),
          const SizedBox(width: 6),
          btn(Icons.keyboard_double_arrow_left_rounded,
              () => home.setPreviewDay(activeDay - 7)),
          btn(Icons.chevron_left_rounded,
              () => home.setPreviewDay(activeDay - 1)),
          Expanded(
            child: Column(
              children: [
                Text('PREVIEW · Wk $week · Day $dayInWeek',
                    textAlign: TextAlign.center,
                    style: text.labelSmall?.copyWith(
                        color: AppTheme.primary700,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
                Text(
                    exact
                        ? 'day $activeDay of 280'
                        : 'day $activeDay · not authored yet (showing nearest)',
                    textAlign: TextAlign.center,
                    style: text.labelSmall?.copyWith(
                        color: exact
                            ? AppTheme.neutral500
                            : AppTheme.secondary600,
                        fontSize: 10)),
              ],
            ),
          ),
          btn(Icons.chevron_right_rounded,
              () => home.setPreviewDay(activeDay + 1)),
          btn(Icons.keyboard_double_arrow_right_rounded,
              () => home.setPreviewDay(activeDay + 7)),
          if (previewing)
            btn(Icons.today_rounded, () => home.setPreviewDay(null)),
        ],
      ),
    );
  }
}
