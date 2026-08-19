// =============================================================================
//  GarbhDailyScreen — all four pillars, as they appear on the daily home
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE OF A FIX THAT WENT HALF-WAY.
//
//  The `garbh_daily` surface used to return `GarbhScreen`, whose own header says
//  it is "a calm LIBRARY (NO 'today' framing)". So a door promising "today's
//  practice" opened a menu of pillars and asked her to choose, then browse a
//  repository with mark-complete stripped out. That was found in the destination
//  audit and pointed at `ShravanScreen(daily: true)` instead.
//
//  Which fixed the framing and broke the scope. Review, immediately:
//
//    "This should be the complete Garbh Sanskar we have in tool. Why are you
//     just showing raga here. Like we have 4 sections, those should be shown
//     like we show in the daily screen."
//
//  Correct. Shravan is the listening pillar — the ragas. Sending the whole
//  section's door to one pillar is narrower than sending it to a library.
//
//  ⚠️ FOUR PILLARS, NOT THREE. The daily home groups Samvad and Vichara into one
//  row, which is defensible there because the row is one line in a long page.
//  Here they are separate, because this screen IS the practice and the two are
//  genuinely different acts: Samvad is speaking to the baby, Vichara is what she
//  holds in her own mind.
//
//  ⚠️ AND THE STATE IS THE POINT. Each pillar shows what TODAY holds and whether
//  she has done it. A daily practice screen that cannot say "you have done two of
//  four" is a menu wearing a date.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/garbh_data.dart';
import '../localization/app_language.dart';
import '../services/garbh_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/pv_fonts.dart';
import '../data/garbh_rebuild_data.dart';
import 'garbh_buddhi_screen.dart';
import 'garbh_journal_screen.dart';
import 'garbh_screen.dart'
    show ShravanScreen, SamvadScreen, KriyaScreen, gameForPuzzle;
import 'v2/v2_palette.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

class GarbhDailyScreen extends StatelessWidget {
  const GarbhDailyScreen({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final lang = S.current;

    return AnimatedBuilder(
      animation:
          Listenable.merge([GarbhStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final store = GarbhStore.instance;
        final cd = pregnancy.currentDay;
        final tri = pregnancy.currentWeek <= 13
            ? 1
            : pregnancy.currentWeek <= 27
                ? 2
                : 3;

        final pillars = <_Pillar>[
          _Pillar(
            id: 'shravan',
            name: 'Shravan',
            tag: 'Listening',
            today: shravanForDay(cd).title.en,
            icon: Icons.music_note_rounded,
            accent: const Color(0xFF6B5B95),
            open: () => ShravanScreen(controller: pregnancy, daily: true),
          ),
          _Pillar(
            id: 'samvad',
            name: 'Samvad',
            tag: 'Talking to your baby',
            today: promptForDay(cd, tri).text.en,
            icon: Icons.record_voice_over_rounded,
            accent: const Color(0xFF9C5F51),
            open: () => SamvadScreen(controller: pregnancy, daily: true),
          ),
          // ⚠️ VICHARA IS REPLACED BY BUDDHI HERE, NOT RENAMED.
          //
          // Vichara served a reflective read; its Sacred Insights and
          // Uplifting Vibrations shelves duplicated Samvad and Shravan, so as
          // a pillar it was two copies wearing a third name. Buddhi is the
          // one genuinely distinct thing that was inside it - the brain
          // fitness games - promoted to stand on its own.
          //
          // ⚠️ AND IT IS THE ONE PILLAR THAT IS NOT FOR THE BABY, which is
          // why its tag says so out loud. See garbh_buddhi_screen.dart.
          _Pillar(
            id: 'buddhi',
            name: 'Buddhi',
            tag: 'Just for you',
            today: buddhiTodayLine(cd).en,
            icon: Icons.psychology_alt_outlined,
            accent: const Color(0xFF7A6E9B),
            open: () => GarbhBuddhiScreen(
              controller: pregnancy,
              daily: true,
              onOpenPuzzle: (ctx, puzzle) => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                      builder: (_) => gameForPuzzle(puzzle, pregnancy,
                          markComplete: true))),
            ),
          ),
          _Pillar(
            id: 'kriya',
            name: 'Kriya',
            tag: 'Breath and grounding',
            today: kriyaForDay(cd).title.en,
            icon: Icons.spa_rounded,
            accent: const Color(0xFF8A6D3B),
            open: () => KriyaScreen(controller: pregnancy, daily: true),
          ),
        ];

        final done = pillars.where((x) => store.isDone(x.id)).length;

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(_en('Garbh Sanskar').of(lang),
                style: pvManrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: p.ink1)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
            children: [
              Text(_en("Today's practice").of(lang),
                  style: pvFraunces(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: p.ink1)),
              const SizedBox(height: 8),
              Text(
                  _en('Four short things. Do one, do all four, or do none. '
                          'Nothing here keeps score.')
                      .of(lang),
                  style: pvManrope(
                      fontSize: 14, height: 1.55, color: p.ink2)),
              const SizedBox(height: 6),
              // ⚠️ A COUNT, NOT A STREAK. "Two of four today" is orientation;
              // "3 day streak" is a debt she can default on. This app does not
              // do streaks, and a practice meant to calm her is the last place
              // to start.
              Text(_en('$done of 4 done today').of(lang),
                  style: pvManrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: p.action)),
              const SizedBox(height: 20),

              // ---- WHY TODAY, AND NOT ANY OTHER DAY --------------------
              //
              // ⚠️ THE SINGLE MOST IMPORTANT LINE ON THIS CARD, and the one
              // the section was missing. Without it every day's practice is
              // interchangeable with every other day's, so there is no reason
              // to do it TODAY rather than at the weekend, and a daily
              // practice with no reason to be daily is a to-do list.
              //
              // ⚠️ IT IS ABOUT THE BABY'S DEVELOPMENT, NEVER ABOUT HER
              // EFFORT. "You are doing so well" is true in any week, which is
              // exactly what makes it useless here. See garbh_rebuild_data
              // for why these are banded rather than written per week, and
              // for the rule that they say what is FORMING and never that a
              // practice improves it.
              _WhyToday(week: pregnancy.currentWeek, p: p, lang: lang),
              const SizedBox(height: 22),

              for (final x in pillars) ...[
                _PillarCard(
                  pillar: x,
                  done: store.isDone(x.id),
                  p: p,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      settings: RouteSettings(name: 'garbh/${x.id}'),
                      builder: (_) => x.open(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // ---- WHAT TODAY LEFT BEHIND -----------------------------
              // Last on the card, because it is the consequence of
              // everything above it rather than another thing to do.
              const SizedBox(height: 14),
              _JournalStrip(week: pregnancy.currentWeek, p: p),
            ],
          ),
        );
      },
    );
  }
}

class _Pillar {
  const _Pillar({
    required this.id,
    required this.name,
    required this.tag,
    required this.today,
    required this.icon,
    required this.accent,
    required this.open,
  });

  final String id;
  final String name;
  final String tag;
  final String today;
  final IconData icon;
  final Color accent;
  final Widget Function() open;
}

/// Why this week matters, said in one line.
class _WhyToday extends StatelessWidget {
  const _WhyToday(
      {required this.week, required this.p, required this.lang});
  final int week;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
        decoration: BoxDecoration(
          color: p.action.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WHY WEEK $week MATTERS',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: p.action)),
          const SizedBox(height: 7),
          Text(garbhWeekReason(week).of(lang),
              style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink1)),
        ]),
      );
}

/// What she added this week, and the way into the whole thing.
///
/// ⚠️ A STRIP, NOT A LIST, AND IT IS THE PAYOFF OF THE ENTIRE SECTION. Every
/// practice above it writes here. Without this the daily card is a checklist
/// that empties itself every night; with it, the card visibly leaves something
/// behind, which is the difference between "completing a practice" and
/// "making something for your child".
class _JournalStrip extends StatelessWidget {
  const _JournalStrip({required this.week, required this.p});
  final int week;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final store = GarbhJournalStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final mine = store.thisWeek(week);
        return Material(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'garbh/journal'),
              builder: (_) => const GarbhJournalScreen(),
            )),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 15),
              child: Row(children: [
                Icon(Icons.auto_stories_outlined, size: 20, color: p.ink2),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Journal',
                            style: pvManrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: p.ink1)),
                        const SizedBox(height: 3),
                        Text(
                            mine.isEmpty
                                ? 'Everything you make lands here, week by '
                                    'week.'
                                : '${mine.length} added this week',
                            style: pvManrope(
                                fontSize: 12, height: 1.4, color: p.ink3)),
                      ]),
                ),
                Icon(Icons.chevron_right_rounded, size: 19, color: p.ink3),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _PillarCard extends StatelessWidget {
  const _PillarCard(
      {required this.pillar,
      required this.done,
      required this.p,
      required this.onTap});

  final _Pillar pillar;
  final bool done;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: pillar.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(pillar.icon, size: 23, color: pillar.accent),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⚠️ THE TAG IS FLEXIBLE, THE NAME IS NOT.
                  //
                  // Both were unbounded Text in a Row, so the row's width
                  // depended entirely on how long someone made a tag - and
                  // adding Buddhi, whose tag is longer than the other three,
                  // painted Flutter's overflow stripe across the card on a
                  // narrow phone. The pillar NAME must never be trimmed (it
                  // is the thing she is choosing), so the tag is the half
                  // that yields.
                  Row(children: [
                    Text(pillar.name,
                        style: pvFraunces(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(pillar.tag.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                              color: p.ink3)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(pillar.today,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 13, height: 1.4, color: p.ink2)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Done is a quiet tick, not a trophy.
            Icon(done ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                size: done ? 21 : 20,
                color: done ? pillar.accent : p.ink3),
          ]),
        ),
      );
}
