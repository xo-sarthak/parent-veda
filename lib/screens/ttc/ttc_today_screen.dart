// =============================================================================
//  TTC - Today's Journey
// -----------------------------------------------------------------------------
//  The emotional home of the Trying-to-Conceive stage. Not a dashboard, not a
//  tracker, not analytics.
//
//      "Pregnancy has Today's Pregnancy. Parenting has Today's Parenting.
//       Trying to Conceive gets Today's Journey. Not Today's Cycle. Not
//       Today's Ovulation."                             - TTC master, §12
//
//  The scroll, in order (master doc §2.4):
//    header · hero · rhythm · insight · video · daily ritual · myth ·
//    journal · nutrition · movement · product
//
//  Everything below the hero rotates by day-of-year, the same convention the
//  parenting app uses: stable within a day, different tomorrow, no scheduler
//  and no state to keep.
//
//  Note what the hero does NOT show: a cycle day in large type, a countdown, or
//  a "Chapter 2 of 5" bar that travels backwards when a cycle restarts. Cycle
//  day is backend truth; the couple sees a chapter.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_products_data.dart';
import '../../ttc/ttc_ritual_store.dart';
import '../../ttc/ttc_store.dart';
import 'ttc_chapter_screen.dart';
import 'ttc_today_parts.dart';
import 'ttc_common.dart';
import 'ttc_cycle_screens.dart';
import 'ttc_insight_screen.dart';
import 'ttc_journey_map_screen.dart';
import 'ttc_journal_screen.dart';
import 'ttc_partner_screen.dart';
import 'ttc_products_screen.dart';
import 'ttc_transition_screen.dart';
import 'ttc_treatment_screen.dart';
import 'ttc_ritual_screen.dart';
import 'ttc_strings.dart';

class TtcTodayScreen extends StatelessWidget {
  const TtcTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // TtcStore rebroadcasts CycleStore; the ritual and journal stores drive
      // their own cards, so all are merged into one listenable.
      animation: Listenable.merge([
        TtcStore.instance,
        TtcRitualStore.instance,
        TtcJournalStore.instance,
        TtcPartnerMode.instance,
        TtcLang.instance,
      ]),
      builder: (context, _) {
        // A paired partner lands in his own Today. The whole stage branches
        // here rather than at the doorway, so both halves share one route and
        // one back-stack.
        if (TtcPartnerMode.instance.on) return const TtcPartnerTodayScreen();

        final t = TtcS.current();
        final store = TtcStore.instance;
        final today = store.today;
        final chapter = today.chapter;
        return TtcPage(
          tab: 0,
          // TESTING-ONLY Her | Him switch, mirroring the pregnancy shell's
          // Mom | Dad pill. Remove before launch.
          overlay: ttcModePill(t, him: false),
          header: const TtcHeader(),
          children: [
            // Pregnancy has "WEEKLY SNAPSHOT" above its hero and parenting has
            // "HOW YOUR BABY IS TODAY". TTC's hero floated with nothing naming
            // it, which is part of why it read as a different app.
            ttcEyebrow(t.yourChapter.toUpperCase(), color: ttcCoral),
            const SizedBox(height: 8),
            _Hero(today: today, t: t, daysTrying: store.daysTrying),
            const SizedBox(height: 20),
            _RhythmCard(today: today, t: t),
            const SizedBox(height: 22),

            ttcSectionTitle(t.todaysJourneyTitle, eyebrow: t.todaysJourney),

            // The one real read of the day keeps its card. It is the only thing
            // here that is an article rather than a line, and the reader behind
            // it now earns the tap.
            _InsightCard(t: t),
            const SizedBox(height: 12),

            // ---- the READING becomes rows -----------------------------------
            //  Was four more full-height cards — the myth, today's nutrition,
            //  today's movement, today's pick — each with an eyebrow, a title, a
            //  paragraph and a fold, each carrying exactly one idea and given
            //  the same visual weight as the hero.
            //
            //  A row is a line you scan; a card is a small article you have to
            //  read. Four cards feels like far more than four rows at identical
            //  word count, which is the whole difference between this screen and
            //  the parenting home — it renders almost everything as grouped
            //  rows and reads as a menu rather than a wall.
            //
            //  Nothing was removed. Every row opens the same content in a sheet.
            _TodayList(t: t),
            const SizedBox(height: 12),

            // ---- the DOING keeps its cards ----------------------------------
            //  The ritual has per-item checkboxes, a count and a streak; the
            //  journal has four shortcut circles. Collapsing either into a row
            //  would take away the ability to DO the thing from Today, which is
            //  removing function rather than compacting it. Density work has to
            //  know the difference between something you read and something you
            //  use.
            _RitualCard(t: t, chapter: chapter),
            const SizedBox(height: 12),
            _JournalCard(t: t, chapter: chapter),
            const SizedBox(height: 20),
            // The door out of this stage. Always present, understated, and
            // never phrased as a prompt to test.
            TtcRecordTestCard(t: t),
            const SizedBox(height: 20),
            // Every tool carried this and the busiest screen did not - which
            // is precisely backwards, since Today is where an estimate is read
            // fastest and questioned least.
            TtcDisclaimer(t: t),
          ],
        );
      },
    );
  }
}

// ---- the hero ---------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({required this.today, required this.t, required this.daysTrying});

  final TtcToday today;
  final TtcS t;
  final int? daysTrying;

  String _greeting(TtcS t) {
    final h = DateTime.now().hour;
    if (h < 12) return t.goodMorning;
    if (h < 17) return t.goodAfternoon;
    return t.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final chapter = today.chapter;
    // Deliberately the SAME construction as the pregnancy hero: two-stop purple
    // gradient, two soft decorative circles bleeding off the corners, a divider
    // above the shortcuts, and circular shortcut buttons. TTC had a
    // purple-to-coral gradient, a flat bar and rounded squares - individually
    // small, together enough that the two never read as one component.
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ttcPurple, ttcPurpleDeep],
          ),
        ),
        child: Stack(children: [
          Positioned(
            right: -36,
            top: -36,
            child: _circle(150, Colors.white.withValues(alpha: 0.10)),
          ),
          Positioned(
            right: 30,
            bottom: -40,
            child: _circle(100, ttcCoral.withValues(alpha: 0.22)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(_greeting(t),
                style: ttcBody(13,
                    color: Colors.white.withValues(alpha: 0.92),
                    w: FontWeight.w600)),
          ),
          if (daysTrying != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(t.daysTrying(daysTrying!),
                  style: ttcBody(11, color: Colors.white, w: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 14),

        // The chapter name is the hero's headline - the emotional equivalent of
        // pregnancy's "Week 20 · Day 3". Fraunces, because this is a hero
        // moment and hero moments are the only place Fraunces is allowed.
        // The ⓘ sits ON the title, because "what does Preparing Together
        // actually mean?" is a question about the title. Answering it beside
        // the thing that raised it is the whole reason this is not a card
        // further down the page.
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(chapter.title(hi),
                style:
                    ttcFraunces(29, w: FontWeight.w600, color: Colors.white)),
          ),
          TtcChapterInfoButton(chapter: chapter, t: t),
        ]),
        const SizedBox(height: 8),
        Text(chapter.tagline(hi),
            style: ttcBody(13.5,
                color: Colors.white.withValues(alpha: 0.94), h: 1.5)),
        const SizedBox(height: 16),

        // Progress WITHIN this chapter only. Never a global 1→5 bar: chapters
        // 2-4 ride the cycle and repeat, and a bar that slid backwards every
        // month would read as failure.
        //
        // The bar was correct and unreadable: a sliver of white with nothing
        // saying what it measured or what lay past it. Both shipped stages
        // label their progress ("Trimester 3", "Phase 1 of 20") and name what
        // comes next; this one said nothing for twenty-eight days, which is
        // what made the stage feel stopped.
        Row(children: [
          Expanded(
            child: Text(t.dayOfChapter(today.daysIntoChapter, today.chapterLength),
                style: ttcBody(11,
                    color: Colors.white.withValues(alpha: 0.8),
                    w: FontWeight.w700)),
          ),
          // The forward link both other stages carry - "View week ›" and
          // "Phase map ›". The Journey Map holds the sentence that answers
          // "does this repeat mean I am going backwards", so it should be one
          // tap from here rather than three.
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const TtcJourneyMapScreen(),
              settings: const RouteSettings(name: 'ttc/map'),
            )),
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(t.journeyMapLink,
                  style: ttcBody(11,
                      color: Colors.white, w: FontWeight.w800)),
              const SizedBox(width: 3),
              const Icon(Icons.chevron_right_rounded,
                  size: 15, color: Colors.white),
            ]),
          ),
        ]),
        const SizedBox(height: 9),
        TtcChapterBar(today: today),
        const SizedBox(height: 18),

        // ---------------------------------------------------------------------
        //  THREE THINGS WERE HERE AND ARE NOW IN THE ⓘ SHEET.
        //
        //    * `nextUp()`  — "Next: Knowing Your Rhythm, from the day you log
        //      your next period". It named an internal chapter she has no
        //      reason to recognise yet, so it explained nothing and cost two
        //      lines. Now the sheet's "What moves you on", where it can be a
        //      sentence instead of a clause.
        //    * `focus()`  — "FOCUS · Health and habits". A category label. It
        //      told her which drawer she was in, which the title already does.
        //      Dropped entirely; it is the one of the four that had no content
        //      to move.
        //    * `goal()`  — "WORTH DOING · Start folic acid and see a doctor
        //      once". The only genuinely actionable line in the hero, and
        //      STATIC for all twenty-eight days of a chapter, so it was
        //      wallpaper by day three. Now the sheet's "Worth doing", read once.
        //
        //  Between them they were four attempts to EXPLAIN the chapter inside a
        //  component whose job is to ORIENT — and none had room to do it, which
        //  is why all four read as vague. Separating those two jobs is the whole
        //  fix. Nothing was deleted except the category label.
        // ---------------------------------------------------------------------

        // Three shortcuts, exactly where pregnancy puts Baby / Mother /
        // What's next. Here the subject is the couple.
        Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
        const SizedBox(height: 14),
        Row(children: [
          TtcHeroShortcut(
              icon: Icons.self_improvement_rounded,
              label: t.shortcutMe,
              onTap: () =>
                  openTtcChapter(context, today.chapter, tab: TtcChapterTab.me)),
          TtcHeroShortcut(
              icon: Icons.favorite_rounded,
              label: t.shortcutUs,
              onTap: () =>
                  openTtcChapter(context, today.chapter, tab: TtcChapterTab.us)),
          TtcHeroShortcut(
              icon: Icons.event_available_rounded,
              label: t.shortcutNext,
              onTap: () => openTtcChapter(context, today.chapter,
                  tab: TtcChapterTab.next)),
        ]),
              ]),
          ),
        ]),
      ),
    );
  }

  static Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

// --------------------------------------------------------------------------
// KEPT FOR REVERT. Superseded: the hero no longer carries FOCUS / WORTH DOING.
//
//   Widget _heroFact(String label, String value) => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(label.toUpperCase(),
//               style: ttcBody(9.5,
//                   color: Colors.white.withValues(alpha: 0.75),
//                   w: FontWeight.w800)),
//           const SizedBox(height: 3),
//           Text(value,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: ttcBody(12.5,
//                   color: Colors.white, w: FontWeight.w700, h: 1.3)),
//         ],
//       );

}

// ---- the rhythm card --------------------------------------------------------
//  The one place the cycle surfaces on Today - and even here it is phrased as
//  rhythm rather than arithmetic. Three honest states: no period logged, logged
//  but no estimate worth showing, and a graded fertility reading.

class _RhythmCard extends StatelessWidget {
  const _RhythmCard({required this.today, required this.t});

  final TtcToday today;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;

    // State 1 - nothing logged. The empty state IS the feature's advertisement.
    if (today.cycleDay == null) {
      return TtcEmpty(
        icon: Icons.favorite_border_rounded,
        title: t.logPeriodTitle,
        body: t.logPeriodBody,
        cta: t.logPeriodCta,
        onTap: () => logTtcPeriod(context),
      );
    }

    // State 1b - a clinic is running this cycle. Said plainly, instead of the
    // "still learning your rhythm" copy below, which would be untrue: we are
    // not learning, we are deliberately not putting numbers next to a doctor's.
    if (today.clinicInvolved) return TtcTreatmentEntryCard(t: t);

    final fert = today.fertility;
    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(t.yourRhythm, style: ttcJakarta(16))),
          // Cycle day is shown small and quiet - present for the woman who
          // wants it, never the headline.
          Text(t.cycleDayQuiet(today.cycleDay!),
              style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),

        // State 2 - logged, but we will not pretend to an estimate. WHICH
        // reason matters: "still learning your rhythm" is true for a new user
        // and reads as a broken app to someone with a year of entries.
        if (fert == null) ...[
          Text(_noEstimateTitle(t, today.noEstimate),
              style: ttcBody(14, color: ttcInk, w: FontWeight.w700)),
          const SizedBox(height: 5),
          // Capped: the Cycle Companion behind "Understand this" carries the
          // full version, so nothing is lost by folding it here.
          TtcExpandableText(
              text: _noEstimateBody(t, today.noEstimate), t: t),
        ]

        // State 3 - a graded reading, always with its confidence attached.
        else ...[
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: ttcFertilityTint(fert),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(fert.label(hi),
                  style: ttcBody(12,
                      color: ttcFertilityInk(fert), w: FontWeight.w800)),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(t.chanceLabel,
                  style: ttcBody(12.5, color: ttcSoft, w: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          if (today.estimatedOvulationDay != null)
            Text(t.estimatedOvulation(today.estimatedOvulationDay!),
                style: ttcBody(13.5, color: ttcInk, w: FontWeight.w700)),
          const SizedBox(height: 4),
          // Confidence is never optional wording - it ships with every estimate.
          Text(today.confidence.phrase(hi), style: ttcBody(12.5)),
        ],

        const SizedBox(height: 14),
        ttcDivider(),
        const SizedBox(height: 12),

        // Two doors, not one. This card was a dead end: it raised the only
        // question on the screen a newcomer cannot answer - what is a cycle
        // day, what is ovulation, why is this "low" - and routed nowhere,
        // while the three screens that explain it sat in Tools.
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => logTtcPeriod(context),
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                const Icon(Icons.add_circle_outline_rounded,
                    size: 17, color: ttcPurple),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(t.logNewPeriod,
                      overflow: TextOverflow.ellipsis,
                      style:
                          ttcBody(13, color: ttcPurple, w: FontWeight.w800)),
                ),
              ]),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const TtcCycleScreen(),
              settings: const RouteSettings(name: 'ttc/cycle'),
            )),
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(t.understandThis,
                  style: ttcBody(13, color: ttcSoft, w: FontWeight.w800)),
              const Icon(Icons.chevron_right_rounded,
                  size: 17, color: ttcSoft),
            ]),
          ),
        ]),

        // The way IN to the care pathway.
        //
        // Everything about treatment cycles was gated behind a card that only
        // appeared once a clinic path was already set - and nothing in the app
        // could set one. This is the door that was missing, and it belongs
        // exactly here: on the card whose numbers stop being right the moment
        // a clinic takes over the timing.
        const SizedBox(height: 12),
        ttcDivider(),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => openTtcTreatment(context),
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            const Icon(Icons.local_hospital_outlined,
                size: 16, color: ttcMuted),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.pathwayEntry,
                        style: ttcBody(12.5,
                            color: ttcInk, w: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(t.pathwayEntryBody,
                        style: ttcBody(11, color: ttcMuted, h: 1.4)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 17, color: ttcMuted),
          ]),
        ),
      ]),
    );
  }
}

/// Naming the refusal, so a blank is never just a blank.
///
/// Shared with the Cycle Companion and the Ovulation Companion - the same
/// number was missing on all three, and three different explanations for one
/// cause is how a user concludes the app is guessing.
String _noEstimateTitle(TtcS t, TtcNoEstimate why) {
  switch (why) {
    case TtcNoEstimate.historyLooksOff:
      return t.noEstHistoryOffTitle;
    case TtcNoEstimate.cycleOverdue:
      return t.noEstOverdueTitle;
    case TtcNoEstimate.none:
    case TtcNoEstimate.noPeriodLogged:
    case TtcNoEstimate.notEnoughHistory:
    case TtcNoEstimate.clinicOwnsTiming:
      return t.noEstimateYet;
  }
}

String _noEstimateBody(TtcS t, TtcNoEstimate why) {
  switch (why) {
    case TtcNoEstimate.historyLooksOff:
      return t.noEstHistoryOffBody;
    case TtcNoEstimate.cycleOverdue:
      return t.noEstOverdueBody;
    case TtcNoEstimate.none:
    case TtcNoEstimate.noPeriodLogged:
    case TtcNoEstimate.notEnoughHistory:
    case TtcNoEstimate.clinicOwnsTiming:
      return t.noEstimateBody;
  }
}

/// Shared by Today and the Cycle Companion, so a period is logged the same way
/// wherever it is logged from.
Future<void> logTtcPeriod(BuildContext context) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: now,
    // A period start is always in the past; offering the future would invite
    // the one input the engine has to reject.
    firstDate: now.subtract(const Duration(days: 400)),
    lastDate: now,
    helpText: TtcS.current().logPeriodTitle,
  );
  if (picked == null) return;

  // Ask before accepting a start that cannot be a new cycle.
  //
  // The store already refuses to AVERAGE gaps under fifteen days, silently. So
  // an entry three days after the last one was kept, shown in the list, and
  // counted for nothing - with no way for her to know. Eleven entries once
  // produced exactly one usable cycle, and the app's only response was to feel
  // like it needed more logging.
  //
  // She can still add it. Some people bleed twice in a month and want both on
  // record. What she cannot do any more is add it without being told.
  final gap = CycleStore.instance.daysSincePreviousStart(picked);
  if (gap != null && gap < CycleStore.minPlausibleCycleDays) {
    if (!context.mounted) return;
    final ok = await _confirmCloseStart(context, gap);
    if (ok != true) return;
  }
  CycleStore.instance.logPeriodStart(picked);
}

Future<bool?> _confirmCloseStart(BuildContext context, int gap) {
  final t = TtcS.current();
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      content: Text(t.tooCloseWarning(gap), style: ttcBody(13.5, h: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(t.tooCloseCancel,
              style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(t.tooCloseKeep,
              style: ttcBody(13, color: ttcPurple, w: FontWeight.w800)),
        ),
      ],
    ),
  );
}

// ---- Today's Insight --------------------------------------------------------

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.t});
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final insight = ttcPickForToday(ttcInsights);
    return TtcCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => TtcInsightScreen(insight: insight),
        settings: const RouteSettings(name: 'ttc/insight'),
      )),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ttcEyebrow(t.todaysInsight),
          const Spacer(),
          Text(t.readSeconds(insight.readTime(hi)),
              style: ttcBody(11, color: ttcMuted, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        Text(insight.title(hi), style: ttcJakarta(17)),
        const SizedBox(height: 8),
        Text(
          insight.body(hi).split('\n\n').first,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: ttcBody(13.5, h: 1.55),
        ),
        const SizedBox(height: 12),
        // The one takeaway. This is the part that is meant to survive the day.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ttcPanel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(insight.takeaway(hi),
              style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w700, h: 1.45)),
        ),
      ]),
    );
  }
}

// ---- Today's Video ----------------------------------------------------------

// --------------------------------------------------------------------------
// KEPT FOR REVERT. REMOVED FROM TODAY. Its entire content was "coming soon" - it spent a
// section of the most valuable screen in the stage advertising an absence.
// "A feature is never hidden" is about HER empty data (an empty journal
// invites her to write); this was OUR content gap, which she can do nothing
// about and cannot be invited into. Restore the moment videos exist.
//
// class _VideoCard extends StatelessWidget {
//   const _VideoCard({required this.t, required this.chapter});
//   final TtcS t;
//   final TtcChapter chapter;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     final insight = ttcPickForToday(ttcInsights);
//     return TtcCard(
//       padding: const EdgeInsets.all(14),
//       onTap: () => ttcSoon(context, t.todaysVideo),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         TtcStriped(
//           height: 148,
//           child: Center(
//             child: Container(
//               width: 46,
//               height: 46,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.9),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.play_arrow_rounded,
//                   size: 26, color: ttcPurple),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         ttcEyebrow(t.todaysVideo),
//         const SizedBox(height: 7),
//         Text(insight.title(hi), style: ttcJakarta(15.5)),
//         const SizedBox(height: 6),
//         // The "why now" line every recommendation in this product carries.
//         Row(children: [
//           const Icon(Icons.auto_awesome_outlined, size: 14, color: ttcCoral),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(t.whyNow(chapter.title(hi)),
//                 style: ttcBody(12, color: ttcCoral, w: FontWeight.w600)),
//           ),
//         ]),
//         const SizedBox(height: 8),
//         Text(t.videoComing, style: ttcBody(11.5, color: ttcMuted)),
//       ]),
//     );
//   }
// }

// ---- The Daily Ritual -------------------------------------------------------

class _RitualCard extends StatelessWidget {
  const _RitualCard({required this.t, required this.chapter});
  final TtcS t;
  final TtcChapter chapter;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final store = TtcRitualStore.instance;
    final items = ttcRituals[chapter] ?? const <TtcRitualItem>[];
    final done = store.completedToday();
    final streak = store.streak();

    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ttcEyebrow(t.dailyRitual),
                const SizedBox(height: 6),
                Text(t.dailyRitualTitle, style: ttcJakarta(17)),
              ],
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$done/${store.total}',
                style: ttcJakarta(16, color: ttcPurple)),
            // A streak with no pressure attached: no colour, no warning, and
            // no "you lost it" state anywhere in the product.
            if (streak > 0)
              Text(t.dayStreak(streak),
                  style: ttcBody(10.5, color: ttcMuted, w: FontWeight.w700)),
          ]),
        ]),
        const SizedBox(height: 8),
        Text(t.dailyRitualBody, style: ttcBody(13, h: 1.5)),
        const SizedBox(height: 14),
        for (var i = 0; i < items.length; i++) ...[
          _ritualRow(context, items[i], store.isDone(items[i].part), hi),
          if (i < items.length - 1) ...[
            const SizedBox(height: 10),
            ttcDivider(),
            const SizedBox(height: 10),
          ],
        ],
      ]),
    );
  }

  Widget _ritualRow(
      BuildContext context, TtcRitualItem item, bool done, bool hi) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => TtcRitualScreen(chapter: chapter, focus: item.part),
        settings: const RouteSettings(name: 'ttc/ritual'),
      )),
      behavior: HitTestBehavior.opaque,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Tapping the tick completes; tapping the row opens the ritual. Two
        // targets, because completing must never require reading first.
        GestureDetector(
          onTap: () => TtcRitualStore.instance.toggle(item.part),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(right: 11, top: 1),
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? ttcPurple : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: done ? ttcPurple : ttcBorder, width: 1.6),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
          ),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.part.title(hi),
                style: ttcBody(13.5, color: ttcInk, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(item.text(hi),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(12.5, h: 1.45)),
          ]),
        ),
      ]),
    );
  }
}

// ---- Daily Myth -------------------------------------------------------------

// --------------------------------------------------------------------------
// KEPT FOR REVERT. Superseded by a row in _TodayList. Same content, opened in a sheet.
//
// class _MythCard extends StatelessWidget {
//   const _MythCard({required this.t});
//   final TtcS t;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     final myth = ttcPickForToday(ttcMyths, offset: 3);
//     return TtcCard(
//       color: ttcCoralTint,
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         ttcEyebrow(t.todaysMyth),
//         const SizedBox(height: 10),
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Icon(Icons.close_rounded, size: 17, color: ttcCoral),
//           const SizedBox(width: 9),
//           Expanded(
//             child: Text(myth.myth(hi),
//                 style: ttcBody(13.5,
//                     color: ttcInk, w: FontWeight.w700, h: 1.45)),
//           ),
//         ]),
//         const SizedBox(height: 11),
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Icon(Icons.check_rounded, size: 17, color: ttcPurple),
//           const SizedBox(width: 9),
//           // No myth detail screen exists, so this opens in place rather than
//           // hiding a second half nobody could reach.
//           Expanded(child: TtcExpandableText(text: myth.truth(hi), t: t)),
//         ]),
//       ]),
//     );
//   }
// }

// ---- Today's Journal --------------------------------------------------------

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.t, required this.chapter});
  final TtcS t;
  final TtcChapter chapter;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final prompt = ttcPromptForToday(chapter);
    final count = TtcJournalStore.instance.count;
    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(t.myJournal, style: ttcJakarta(17))),
          GestureDetector(
            onTap: () => openTtcJournal(context),
            behavior: HitTestBehavior.opaque,
            child: Text(count == 0 ? t.seeAll : t.entryCount(count),
                style: ttcBody(12, color: ttcPurple, w: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 12),
        // Today's prompt, written for this chapter where one exists.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: ttcPanel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(prompt.text(hi),
              style: ttcBody(13.5, color: ttcTitleInk, w: FontWeight.w600, h: 1.5)),
        ),
        const SizedBox(height: 14),
        // Four large quick-entries, the same shape as the pregnancy Home's.
        Row(children: [
          for (final kind in TtcEntryKind.values) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => writeTtcEntry(context,
                    kind: kind,
                    prompt: kind == TtcEntryKind.feeling ? prompt.text(hi) : null),
                behavior: HitTestBehavior.opaque,
                child: Column(children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: ttcPanel, shape: BoxShape.circle),
                    child: Icon(ttcEntryIcon(kind), size: 20, color: ttcPurple),
                  ),
                  const SizedBox(height: 7),
                  Text(kind.label(hi),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ttcBody(10.5, w: FontWeight.w700, h: 1.25)),
                ]),
              ),
            ),
            if (kind != TtcEntryKind.values.last) const SizedBox(width: 8),
          ],
        ]),
      ]),
    );
  }
}

// ---- Today's Nutrition ------------------------------------------------------

// --------------------------------------------------------------------------
// KEPT FOR REVERT. Superseded by a row in _TodayList. Same content, opened in a sheet.
//
// class _NutritionCard extends StatelessWidget {
//   const _NutritionCard({required this.t});
//   final TtcS t;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     final n = ttcPickForToday(ttcNutrition, offset: 1);
//     return TtcCard(
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           ttcEyebrow(t.todaysNutrition),
//           const Spacer(),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//                 color: ttcPanel, borderRadius: BorderRadius.circular(999)),
//             child: Text(n.nutrient(hi),
//                 style: ttcBody(11, color: ttcPurple, w: FontWeight.w800)),
//           ),
//         ]),
//         const SizedBox(height: 11),
//         Text(n.meal(hi), style: ttcJakarta(16)),
//         const SizedBox(height: 7),
//         TtcExpandableText(text: n.why(hi), t: t),
//         const SizedBox(height: 12),
//         // The India-first line. This is the part that makes the section ours
//         // rather than translated from somewhere else.
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: const Color(0xFFFDF6EC),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Icon(Icons.emoji_objects_outlined, size: 16, color: ttcBrown),
//             const SizedBox(width: 9),
//             Expanded(
//               child: Text(n.indian(hi),
//                   style: ttcBody(12.5, color: ttcBrown, h: 1.5, w: FontWeight.w600)),
//             ),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// ---- Today's Movement -------------------------------------------------------

// --------------------------------------------------------------------------
// KEPT FOR REVERT. Superseded by a row in _TodayList. Same content, opened in a sheet.
//
// class _MovementCard extends StatelessWidget {
//   const _MovementCard({required this.t});
//   final TtcS t;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     final m = ttcPickForToday(ttcMovements, offset: 2);
//     return TtcCard(
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           ttcEyebrow(t.todaysMovement),
//           const Spacer(),
//           if (m.minutes > 0)
//             Text(t.minutes(m.minutes),
//                 style: ttcBody(11, color: ttcMuted, w: FontWeight.w700)),
//         ]),
//         const SizedBox(height: 11),
//         Row(children: [
//           Container(
//             width: 42,
//             height: 42,
//             alignment: Alignment.center,
//             decoration:
//                 const BoxDecoration(color: ttcPanel, shape: BoxShape.circle),
//             child: Icon(ttcMovementIcon(m.kind), size: 20, color: ttcPurple),
//           ),
//           const SizedBox(width: 13),
//           Expanded(child: Text(m.title(hi), style: ttcJakarta(15.5))),
//         ]),
//         const SizedBox(height: 10),
//         TtcExpandableText(text: m.body(hi), t: t),
//       ]),
//     );
//   }
// }

// ---- Today's Product --------------------------------------------------------

// --------------------------------------------------------------------------
// KEPT FOR REVERT. Superseded by a row in _TodayList, which opens the product guide.
//
// class _ProductCard extends StatelessWidget {
//   const _ProductCard({required this.t});
//   final TtcS t;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     // Today's pick rotates from the research library, and it opens the research
//     // page rather than a buy flow. Commerce sits last on this screen and stays
//     // last: education, then confidence, then recommendation, then commerce.
//     final product = ttcPickForToday(ttcProducts, offset: 4);
//     return TtcCard(
//       onTap: () => openTtcProducts(context),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         ttcEyebrow(t.todaysPick),
//         const SizedBox(height: 10),
//         Text(product.name(hi), style: ttcJakarta(16)),
//         const SizedBox(height: 7),
//         Text(product.why(hi),
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//             style: ttcBody(13, h: 1.55)),
//         const SizedBox(height: 12),
//         Row(children: [
//           const Icon(Icons.error_outline_rounded, size: 14, color: ttcBrown),
//           const SizedBox(width: 7),
//           Expanded(
//             child: Text(t.productsWatchOut,
//                 style: ttcBody(11.5, color: ttcBrown, w: FontWeight.w700)),
//           ),
//           Text(product.priceEn,
//               style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
//         ]),
//       ]),
//     );
//   }
// }

// ---- shared icon maps -------------------------------------------------------

IconData ttcEntryIcon(TtcEntryKind kind) {
  switch (kind) {
    case TtcEntryKind.memory:
      return Icons.auto_stories_outlined;
    case TtcEntryKind.letter:
      return Icons.drafts_outlined;
    case TtcEntryKind.question:
      return Icons.help_outline_rounded;
    case TtcEntryKind.feeling:
      return Icons.favorite_border_rounded;
  }
}

IconData ttcMovementIcon(String kind) {
  switch (kind) {
    case 'walk':
      return Icons.directions_walk_rounded;
    case 'yoga':
      return Icons.self_improvement_rounded;
    case 'strength':
      return Icons.fitness_center_rounded;
    case 'stretch':
      return Icons.accessibility_new_rounded;
    case 'breath':
      return Icons.air_rounded;
    default:
      return Icons.bedtime_outlined;
  }
}

// ---- Today's list -----------------------------------------------------------

/// Four rows where there were four cards.
///
/// The video card is deliberately absent — see the note on `_VideoCard`, which is
/// kept commented rather than deleted.
class _TodayList extends StatelessWidget {
  const _TodayList({required this.t});
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final myth = ttcPickForToday(ttcMyths, offset: 3);
    final n = ttcPickForToday(ttcNutrition, offset: 1);
    final m = ttcPickForToday(ttcMovements, offset: 2);
    final product = ttcPickForToday(ttcProducts, offset: 4);

    return TtcCard(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(children: [
        TtcTodayRow(
          icon: Icons.lightbulb_outline_rounded,
          eyebrow: t.todaysMyth,
          title: myth.myth(hi),
          onTap: () => showTtcRowSheet(
            context,
            eyebrow: t.todaysMyth,
            title: myth.myth(hi),
            body: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: ttcPanel,
                  borderRadius: BorderRadius.circular(ttcCardRadius),
                ),
                child: Text(myth.truth(hi),
                    style: ttcBody(14, color: ttcTitleInk, h: 1.65)),
              ),
            ],
          ),
        ),
        TtcTodayRow(
          icon: Icons.restaurant_rounded,
          eyebrow: t.todaysNutrition,
          title: n.meal(hi),
          onTap: () => showTtcRowSheet(
            context,
            eyebrow: n.nutrient(hi),
            title: n.meal(hi),
            body: [
              Text(n.why(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF6EC),
                  borderRadius: BorderRadius.circular(ttcCardRadius),
                ),
                child: Text(n.indian(hi),
                    style: ttcBody(13.5, color: ttcBrown, h: 1.6)),
              ),
            ],
          ),
        ),
        TtcTodayRow(
          icon: Icons.directions_walk_rounded,
          eyebrow: t.todaysMovement,
          title: m.title(hi),
          meta: m.minutes > 0 ? t.minutes(m.minutes) : '',
          onTap: () => showTtcRowSheet(
            context,
            eyebrow: t.todaysMovement,
            title: m.title(hi),
            body: [
              Text(m.body(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
            ],
          ),
        ),
        // The only row with a real destination already: the product guide.
        TtcTodayRow(
          icon: Icons.shopping_bag_outlined,
          eyebrow: t.todaysPick,
          title: product.name(hi),
          meta: product.priceEn,
          last: true,
          onTap: () => openTtcProducts(context),
        ),
      ]),
    );
  }
}
