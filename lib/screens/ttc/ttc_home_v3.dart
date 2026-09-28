// =============================================================================
//  TtcHomeV3 — the Trying-to-Conceive home, rebuilt around the L1 brackets
// -----------------------------------------------------------------------------
//  Third and last of the built stages. `TtcTodayScreen` is V1 and is UNTOUCHED;
//  this sits beside it behind a toggle, the same way parenting's V3 does.
//
//  SAME SHAPES AS THE OTHER TWO STAGES, DIFFERENT CONTENT. Field, hero type,
//  door grid, section heads, journal — all shared widgets rather than
//  lookalikes, which is the whole point. A woman crosses TTC → pregnancy →
//  parenting once, and each crossing is the worst possible moment to make her
//  relearn a screen.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE CLINICAL RULES THIS SCREEN HAD TO OBEY, AND WHERE THEY CAME FROM
//  ---------------------------------------------------------------------------
//
//  A big number on a fertility hero is the most dangerous piece of type in the
//  product, because the obvious ones are all forbidden:
//
//    · **Never a personalised probability.** No "your chance this month". Held
//      by `test/ttc_clinical_review_test.dart`, which scans source rather than
//      seed lists.
//    · **Never a countdown to an outcome.** `test/ttc_home_hero_test.dart`
//      asserts the waiting chapter says "or the next cycle — both are fine",
//      and that "next" names a TRIGGER ("when you log your next period") rather
//      than a number of days. "In 14 days" has to be wrong eventually, and being
//      wrong about this is worse than being vague.
//    · **No denominator across the stage.** Chapters 2–4 come round with every
//      cycle, so "Chapter 2 of 5" would promise a finish line that does not
//      exist — the exact feeling the Journey Map's "not a step backwards" line
//      was written to prevent. Parenting says "PHASE 1 OF 20" and TTC must not.
//    · **We may not always generate a value at all.** `TimingOwnership` decides
//      that, and when a clinic owns the cycle the app defers rather than
//      computes.
//
//  So the big fact is DAY IN THIS CHAPTER — a fact about where she is, which is
//  true on a clinic cycle, true with no history, and never a prediction. It is
//  also the one `TtcTodayScreen` already settled on, so the two versions agree.
//
//  And when nothing has been logged, the hero does not show a zero: it shows
//  the invitation, because `TtcNoEstimate.noPeriodLogged` is a real state with
//  its own sentence, not a hole.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/reads/read_images.dart' show readImageFor;
import '../brackets/hub/journey_screen.dart';
import '../../data/journeys/journey_registry.dart';
import 'ttc_journal_screen.dart' show writeTtcEntry;
import '../../ttc/ttc_journal_store.dart' show TtcEntryKind;
import 'ttc_prepare_screen.dart';
import '../../data/hubs/ttc_hubs.dart';
import '../brackets/hub/hub_owed_screen.dart';
import '../brackets/hub/problem_hub_screen.dart';
import '../../data/hubs/hub_registry.dart';

import '../../localization/app_language.dart';
import '../../services/bracket_resolver.dart';
import '../../services/life_stage_store.dart';
import '../../services/ttc_surfaces.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../products/pv_store_chrome.dart' show pvSnack, PvCardRail;
import '../../services/pv_catalog_store.dart';

import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_insight_read.dart';
import '../../ttc/ttc_log_store.dart';
// Today's myth as a story, nutrition and movement as reads (2026-09-28).
import 'ttc_daily_tip_open.dart';
// Kept for revert: the hero's dates came from `ttcFertileWindowNow`; they
// come from `ttcDayContext` now (2026-09-26, consistency pass).
// import '../../ttc/ttc_fertile_window.dart';
// import '../../ttc/ttc_focus_data.dart'; // kept for revert: the old door push in _openBracket (2026-09-26)
import '../../ttc/ttc_prepare_data.dart';
import '../../ttc/ttc_products_data.dart';
import '../../ttc/ttc_reads_data.dart';
import '../../ttc/ttc_ritual_store.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_symptom_data.dart';
import '../brackets/bracket_screen.dart';
import '../v2/v2_block_grid.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';
// V3JournalSection is in the commented-out journal block. Kept for revert.
// ignore: unused_import
import '../v2/v3_daily.dart';
import '../v2/v3_daily_art.dart';
import '../../ttc/ttc_home_hero.dart';
import '../../ttc/ttc_treatment_store.dart';
// ---- the treatment round (2026-09-26, docs/TTC-TREATMENT-FLOW.md B4) --------
import '../../ttc/ttc_treatment_round.dart' show TtcRoundPhaseX;
import 'ttc_round_home_card.dart';
import 'ttc_round_strings.dart';
import 'ttc_treatment_round_screens.dart' show openTtcTreatmentResult;
// ---- the gap analysis's home work (2026-09-26) ------------------------------
import '../../services/pv_read_store.dart';
import '../../ttc/ttc_content_prefs.dart';
import '../../ttc/ttc_home_prefs.dart';
import '../../ttc/ttc_home_situation.dart';
import '../../ttc/ttc_day_context.dart';
import '../../ttc/ttc_fertility_help_store.dart';
import '../../ttc/ttc_messages_store.dart';
import '../../ttc/ttc_period_due.dart' show TtcTestAdvice;
import 'ttc_home_gap.dart';
import '../v2/pv_day_strip.dart';
import '../v2/pv_insight_rail.dart';
import '../v2/v3_hero_field.dart';
import 'ttc_chapter_screen.dart';
// import 'ttc_focus_screen.dart'; // kept for revert: the old door push in _openBracket (2026-09-26)
import 'doors/ttc_door_screen.dart' show openTtcDoor;
import 'ttc_common.dart';
import 'ttc_cycle_report_screen.dart';
import 'ttc_daily_insights.dart';
// import 'ttc_insight_screen.dart'; // kept for revert — the insight opens in the reader now
import 'ttc_journey_map_screen.dart';
import 'ttc_symptom_mark.dart';
import 'ttc_cycle_palette.dart' show TtcCycleColours;
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart' show PvMarkWell, pvWellInk;
import '../../data/brackets/ttc_brackets.dart' show kTtcBrackets;
import '../../models/bracket.dart' show Bracket;
import '../../models/pv_read.dart' show PvRead;
import 'ttc_shop_v3.dart' show openTtcProductPage;
import 'ttc_products_screen.dart';
import 'ttc_profile_screen.dart';
import 'ttc_ritual_screen.dart';
import 'ttc_practice_card_parts.dart';
import 'ttc_strings.dart';
import 'ttc_symptom_log_screen.dart';
import 'ttc_surface_router.dart';
// Kept for revert (2026-09-28): its `showTtcRowSheet` carried the myth,
// nutrition and movement sheets, which are now a story and two reads
// (ttc_daily_tip_open.dart). Restore with the three sheet cases.
// import 'ttc_today_parts.dart';
// Kept for revert (2026-09-28, H1): import 'ttc_today_screen.dart' show logTtcPeriod;
import 'ttc_cycle_companion.dart' show showTtcHomePeriodSheet;
import '../learn/pv_offering_content.dart'
    show kTtcRegistrationChecksRecorded;
import 'ttc_transition_screen.dart';

/// The four chapters' hues, on the same controlled-pastel wheel every other
/// stage uses.
///
/// ⚠️ THEY MOVE WITH THE CYCLE AND THEY DO NOT RANK IT. Rose for preparing,
/// green for knowing the rhythm, gold for trying, blue-violet for waiting —
/// four different places, not a progress ramp from cold to warm. A palette that
/// got visibly "better" toward one chapter would be scoring her cycle, which is
/// the pressure this entire stage is built to remove.
double _chapterHue(TtcChapter c) => switch (c) {
      TtcChapter.preparingTogether => 344,
      TtcChapter.knowingYourRhythm => 160,
      TtcChapter.tryingTogether => 42,
      TtcChapter.theWaitingDays => 268,
      // The fifth chapter, and the only one that is an ENDING rather than a
      // place in the loop: she is pregnant, and this stage is handing her over.
      // Green, the same hue pregnancy's own arrival wears.
      TtcChapter.aNewBeginning => 104,
    };

int _chapterNumber(TtcChapter c) => TtcChapter.values.indexOf(c) + 1;

class TtcHomeV3 extends StatefulWidget {
  const TtcHomeV3({super.key});

  @override
  State<TtcHomeV3> createState() => _TtcHomeV3State();
}

/// The reads heading on a day other than today: "Recommended reads for
/// yesterday", "... for 28 August". [dayTitle] is the insights heading for the
/// same day, so the two titles always name the same date.
String ttcReadsTitleFor(String dayTitle) {
  final t = dayTitle == 'Yesterday' || dayTitle == 'Tomorrow'
      ? dayTitle.toLowerCase()
      : dayTitle;
  return 'Recommended reads for $t';
}

class _TtcHomeV3State extends State<TtcHomeV3>
    with WidgetsBindingObserver {
  /// The day the page is describing.
  ///
  /// ⚠️ THIS IS WHY THE SCREEN BECAME STATEFUL, and the change it enables was
  /// asked for three times before it landed: *"I'm not able to go back at a
  /// date."* The strip drew seven days and every one of them was decoration —
  /// tapping did nothing, so the only way to see what she logged on Tuesday was
  /// the calendar, two screens away.
  ///
  /// Now one date owns the page: the heading names it, the cards are computed
  /// for it, and the rail's rotating content is picked for it. That is the
  /// difference between a home that shows today and a home you can walk.
  ///
  /// ⚠️ NORMALISED TO MIDNIGHT ON EVERY WRITE. A `DateTime.now()` carries a
  /// time, so `selected == today` is false four milliseconds after launch and
  /// the "Today" label silently becomes a date. Every assignment goes through
  /// `_dayOnly`.
  DateTime _selected = _dayOnly(DateTime.now());

  /// The day this screen currently believes it is.
  ///
  /// ⚠️ "TODAY" WAS CAPTURED ONCE AND NEVER RECHECKED, AND THAT WAS A REAL BUG.
  /// Reported as the highlight *"still at 30th August"* while the clock said the
  /// 31st, and the mechanism is worth writing down because it is a whole class
  /// of mistake rather than one line.
  ///
  /// `_selected` was a field initialiser and the strip's window anchor was set
  /// in `initState`. Both run exactly once, when the screen is first built. A
  /// phone left on the home overnight — or, far more commonly, backgrounded at
  /// 11pm and reopened at 8am, because Android keeps the state alive — never
  /// runs either again. So the selection ring stayed on yesterday.
  ///
  /// What made it look inconsistent rather than merely stale is that the OTHER
  /// half of the strip reads the clock on every build: `isToday` compares each
  /// date against `DateTime.now()`, so the bold number had already moved to the
  /// 31st while the ring was still around the 30th. **A screen that reads the
  /// clock in one place and caches it in another will disagree with itself, and
  /// only ever after midnight — which is why nobody catches it by looking.**
  DateTime _today = _dayOnly(DateTime.now());

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    // Resume is the moment that matters. A phone that has been in a pocket
    // since last night fires this and nothing else.
    WidgetsBinding.instance.addObserver(this);
    // Lazy loads for the gap-analysis pieces: the check card's "Not now", the
    // course card's opened steps, and the reader's progress it also counts.
    TtcHomePrefs.instance.load();
    PvReadStore.instance.load().catchError((_) {});
    // Her age band decides the check card's 6-or-12 months and the door
    // order. Lazy-loaded store: without this the home can read "unknown".
    TtcFertilityHelpStore.instance.load().catchError((_) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _rollOver();
      // A phone left in a pocket for a month resumes here rather than
      // launching: the 30-days-away check-in needs to see it too.
      TtcTreatmentStore.instance.noteOpened();
    }
  }

  /// Move the screen on if the date has changed under it.
  ///
  /// ⚠️ IT ONLY DRAGS THE SELECTION IF SHE WAS STANDING ON THE OLD TODAY. If
  /// she had deliberately tapped back to the 26th and left the app open, moving
  /// her to the 31st on resume would be the screen overruling a choice she
  /// made — and she would have no idea why the cards changed. Advancing a
  /// default is correct; advancing a decision is not.
  void _rollOver() {
    final now = _dayOnly(DateTime.now());
    if (now == _today) return;
    setState(() {
      final wasOnToday = _selected == _today;
      _today = now;
      if (wasOnToday) _selected = now;
    });
  }

  void _select(DateTime day) => setState(() => _selected = _dayOnly(day));

  /// "Today", "Yesterday", "Tomorrow", or "28 August".
  ///
  /// ⚠️ THE RELATIVE WORDS ONLY REACH ONE DAY OUT. "Two days ago" is a phrase
  /// people have to do arithmetic on; a date is not. Anything further than
  /// yesterday or tomorrow gets named, which is also what makes the heading
  /// change *visibly* as she walks the strip — three "days ago" variants in a
  /// row would look like the same screen.
  ///
  /// ⚠️ ENGLISH ONLY, DELIBERATELY, even though the eyebrow above it still has
  /// a Hindi side. New copy is English unless Hindi is asked for — CLAUDE.md,
  /// decided 2026-08-27 — and the Latin-script Hindi this file's older strings
  /// use was dropped as a house style. Writing three more of it to look
  /// consistent would be spreading a convention that is being retired. The
  /// shipped pairs stay; this is not one.
  static String _dayTitle(DateTime day) {
    final today = _dayOnly(DateTime.now());
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';
    return '${day.day} ${_CycleHeader._months[day.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ A SECOND CHECK, AND NOT A REDUNDANT ONE. The lifecycle observer covers
    // the common case; this covers a screen that is simply rebuilt for another
    // reason — a store notifying, the language flipping — after midnight
    // without the app ever having been backgrounded. Cheap, and it means the
    // stale state cannot survive any repaint.
    //
    // Deferred, because `build` must not call `setState`.
    if (_dayOnly(DateTime.now()) != _today) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _rollOver();
      });
    }

    final p = V2PaletteStore.instance.current;
    return AnimatedBuilder(
      // ⚠️ `TtcLogStore` IS IN THIS LIST NOW. Without it, logging a symptom and
      // coming back showed the old strip and the old cards — the exact
      // complaint that started this pass: *"I actually am not able to see it in
      // the home screen."* The markers read that store, so the page has to
      // rebuild when it changes.
      //
      // ⚠️ AND THREE MORE SINCE 2026-09-26: the messages store (the envelope's
      // dot), her content choices (hide intimacy reads and cards) and the home
      // prefs (the check card's "Not now", the course card's steps). Each is
      // something on this page that changes while she is looking at it.
      animation: Listenable.merge([
        TtcStore.instance,
        TtcLang.instance,
        TtcLogStore.instance,
        TtcMessagesStore.instance,
        TtcContentPrefs.instance,
        TtcHomePrefs.instance,
        // ⚠️ HER AGE BAND (2026-09-26, consistency pass). Answering it in the
        // "Trying after 35" read or the help tool changes the check card and
        // the door order; without this the home kept the old answer until
        // something else rebuilt it.
        TtcFertilityHelpStore.instance,
      ]),
      builder: (context, _) {
        final hinglish = TtcLang.instance.hinglish;
        final today = TtcStore.instance.today;
        final chapter = today.chapter;
        final accent = v2BlockTint(_chapterHue(chapter), p);

        // ---- where she is, once per build (ttc_home_situation.dart) --------
        //
        // ⚠️ THE PHASE IS FOR THE DAY THE STRIP IS ON; THE DOOR ORDER AND THE
        // CHECK CARD ARE FOR TODAY. Cards and reads follow the strip like
        // everything else in the sheet. The doors and the check card do not,
        // because doors that reshuffled as she walked the week would be a
        // menu moving under her thumb.
        final phase = ttcHomePhaseOn(_selected);
        final checkMonths = TtcHomePrefs.instance.checkDismissed
            ? null
            : ttcHomeCheckMonths();
        final doorIds = ttcHomeDoorOrderNow([
          for (final b in bracketsFor(LifeStage.tryingToConceive)) b.id,
        ]);

        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            // The field is the PAGE's surface — it does not scroll, and the
            // content sheet slides over it. See the note in v3_hero_field.dart
            // about why nobody blends two sections.
            Positioned.fill(
              child: V3HeroField(
                  accent: accent,
                  ground: p.ground,
                  variant: _chapterNumber(chapter),
                  chroma: v3FieldChroma(_chapterHue(chapter))),
            ),
            ListView(
              // ⚠️ ROOM FOR THE NAV AND THE ASK FAB. `ttcBottomInset` is what
              // every other TTC screen reserves, and V3 shipped without it —
              // the last rows of this page sat under a floating pill and an
              // opaque 56px circle. See docs/STILL-OPEN.md §9.4.
              // ⚠️ AND THEN THE SHEET TOOK IT OVER — 2026-09-16. Once the
              // field became the page's own surface, this padding stopped
              // being clearance and became a WINDOW: on the phone the last
              // ~130dp under the disclaimer showed the field through it,
              // exactly the failure parenting's `_Sheet` note describes. The
              // sheet reserves the clearance inside itself now (see `_Sheet`),
              // so the scroll view reserves nothing. Kept for revert:
              //   padding: const EdgeInsets.only(bottom: ttcBottomInset),
              padding: EdgeInsets.zero,
              children: [
                // ---- THE CYCLE HEADER ---------------------------------------
                //
                // ⚠️ THIS REPLACED THE CHAPTER HERO, AND THE TRADE IS WORTH
                // NAMING. The old hero led on "Day 6 in this chapter" — a fact
                // about where she is that is true on every pathway and never a
                // prediction, which is why it was chosen. It was also the
                // answer to a question almost nobody opens the app asking.
                //
                // What she opens the app asking is "where am I in this cycle,
                // and when are my days". So the header now leads on the week
                // and the window, and the chapter survives as the chip above
                // them — same destination, less of the screen.
                //
                // ⚠️ NOTHING THE HERO REACHED BECAME UNREACHABLE. Profile is
                // the avatar, the journey map is the chapter chip, the cycle
                // companion is the cycle-day line, and the calendar — which the
                // hero never reached at all — is the icon on the right. See the
                // wiring gate in CLAUDE.md; the reason this list is written out
                // is that a replaced hero is exactly where a door goes missing.
                _CycleHeader(
                  today: today,
                  p: p,
                  hinglish: hinglish,
                  selected: _selected,
                  todayDate: _today,
                  onSelectDay: _select,
                  onChapter: () => Navigator.of(context).push(MaterialPageRoute(
                      settings: const RouteSettings(name: 'ttc/journey_map'),
                      builder: (_) => const TtcJourneyMapScreen())),
                  onCycle: () => _openSurface(context, 'ttc_cycle'),
                  onCalendar: () => _openSurface(context, 'ttc_calendar'),
                  onProfile: () => openTtcProfile(context),
                  onMessages: () => _openSurface(context, 'ttc_messages'),
                  unread: TtcMessagesStore.instance.unreadCount,
                ),
                _Sheet(p: p, children: [
                  const SizedBox(height: 26),

                  // ---- THE ROUND'S ONE NOTICE (2026-09-26) -----------------
                  //
                  // ⚠️ NOTHING CHANGES SILENTLY (the user's rule). The check-in,
                  // "Your home now follows your round", the result prompt,
                  // "Your fertile days are back", a closed round's Undo and
                  // "Add your clinic's dates" share this one slot, strongest
                  // first, each said once (`ttcRoundNoticeNow`). Above the
                  // insights because each is about her, today.
                  if (ttcRoundNoticeNow() != null) ...[
                    _pad(const TtcRoundHomeCard()),
                    const SizedBox(height: 24),
                  ],

                  // ---- THE DAILY INSIGHTS ----------------------------------
                  //
                  // ⚠️ THE TITLE IS THE SELECTED DATE, NOT THE WORD "TODAY".
                  // Asked for precisely: *"it says my daily insights today, I
                  // go behind the date, my daily insights yesterday, my daily
                  // insights 28th August."*
                  //
                  // That is a small string and a large idea. A heading that
                  // says "Today" above cards computed for last Tuesday is a
                  // screen lying about its own contents, and it is the kind of
                  // lie nobody files a bug for — they just stop trusting the
                  // numbers. Naming the day is what makes the strip above it
                  // feel connected to the cards below rather than being two
                  // widgets that happen to share a screen.
                  _pad(_Head(
                      eyebrow:
                          hinglish ? 'Aaj ke liye' : 'My daily insights',
                      title: _dayTitle(_selected),
                      p: p)),
                  const SizedBox(height: 14),

                  // ⚠️ CARDS, NOT CIRCLES — and the circles are kept below,
                  // commented, per the revert rule. The rail of six identical
                  // bubbles could only ever say the NAME of a thing; a
                  // rectangle has room for the answer as well, which is what
                  // turns "today's insight" into "Cycle day 8". See
                  // `ttc_daily_insights.dart` for which cards a day earns.
                  _InsightRail(
                      p: p,
                      hinglish: hinglish,
                      selected: _selected,
                      phase: phase,
                      today: _today),
                  const SizedBox(height: 26),

                  // ---- IT MAY BE TIME FOR A CHECK (gap analysis, P2) -------
                  //
                  // One calm card at 12 months of trying (6 at 35 and over or
                  // with cycles that vary), by the same rule as the "trying
                  // for a while" message so the two agree. "Not now" is
                  // remembered. Above the doors because it is the one thing on
                  // this page that is about her, this month, and not a menu.
                  if (checkMonths != null) ...[
                    _pad(TtcCheckCard(p: p, months: checkMonths)),
                    const SizedBox(height: 26),
                  ],

                  // ---- NEW HERE? (gap analysis, Learning shapes, P1) -------
                  //
                  // Until she has opened two steps of "Trying to conceive
                  // 101". It names the next step instead of counting them:
                  // the course has done its job as a way in once she is in.
                  if (TtcHomePrefs.instance.offer101) ...[
                    _pad(Ttc101Card(
                        p: p, onAllSteps: () => openTtcTabV3(context, 1))),
                    const SizedBox(height: 26),
                  ],

                  // ---- THE DOORS -------------------------------------------
                  //
                  // ⚠️ NO EYEBROW ANY MORE. "WHERE TO GO" over "Start anywhere"
                  // was a label explaining a label — the title already says
                  // what the grid is for, and the eyebrow only earned its place
                  // when this section was buried in the middle of the page.
                  _pad(_Head(
                      eyebrow: '',
                      title: hinglish ? 'Kahin se bhi shuru karein' : 'Start anywhere',
                      p: p)),
                  const SizedBox(height: 14),
                  // ⚠️ ORDERED BY HER SITUATION, NEVER FILTERED (2026-09-26,
                  // gap analysis P2). A clinic pathway leads with IVF & IUI,
                  // trying long enough for a check leads with "Taking a
                  // while", the waiting and late days lead with the fertile
                  // window. Every door is still here, in a stable order
                  // otherwise: CLAUDE.md lets personalisation change order,
                  // never structure. Kept for revert, the fixed order:
                  //   for (final b in bracketsFor(LifeStage.tryingToConceive))
                  _pad(V2BlockGrid(
                    palette: p,
                    columns: 4,
                    blocks: [
                      for (final id in doorIds)
                        if (bracketById(id) case final b?)
                        V2Block(
                          label: hinglish ? b.label.hi : b.label.en,
                          icon: Icons.circle_outlined,
                          tint: v2BlockTint(b.hue, p),
                          bracketMark: bracketMarkFor(b.id),
                          onTap: () => _openBracket(context, b.id),
                        ),
                    ],
                  )),
                  const SizedBox(height: 32),

                  // ---- THE SPINE -------------------------------------------
                  //
                  // ⚠️ THE DOORS DO NOT CARRY THE SPINE, and this is the
                  // mistake parenting's first cut made: eleven problem doors
                  // and nothing else, so a screen that used to hold the whole
                  // day held only a menu. The doors cover what she comes
                  // LOOKING for; the sections cover the cycle she is actually
                  // in. Both, always.
                  //
                  // ⚠️ THE SPINE IS NOW THE HEADER, NOT A CARD IN THE SHEET —
                  // which is why this section is commented out rather than
                  // deleted. `_CycleHeader` states the same three things this
                  // card did (where she is in the cycle, whether we may
                  // estimate at all, and the way into the cycle companion) and
                  // states them above the fold instead of a screen down.
                  //
                  // Kept for revert: if the header experiment comes off, this
                  // block and `_SpineCard` go back together. The rule that
                  // matters either way is the one in the card's own doc
                  // comment — position, never probability.
                  //
                  // _pad(_Head(
                  //     eyebrow: hinglish ? 'Aapki rhythm' : 'Your rhythm',
                  //     title: hinglish ? 'Aaj kahan hain aap' : 'Where you are today',
                  //     p: p)),
                  // const SizedBox(height: 12),
                  // _pad(_SpineCard(
                  //     today: today,
                  //     p: p,
                  //     hinglish: hinglish,
                  //     onTap: () => _openSurface(context, 'ttc_cycle'))),
                  // const SizedBox(height: 32),

                  // ---- PRACTICE --------------------------------------------
                  //
                  // ⚠️ A LINK TO THE RITUAL IS NOT THE RITUAL, and the mistake
                  // is already written up in `ttc_today_screen.dart`: "density
                  // work has to know the difference between something you read
                  // and something you use."
                  //
                  // V3 shipped this as one `_LinkCard` opening the ritual
                  // screen. Same destination, so it passes a reachability
                  // check — and it still removed the thing the card is FOR.
                  // On V1 she can tick a part off from the home, see 2/5, and
                  // see a streak. On V3 completing anything cost a screen.
                  //
                  // That is not a cosmetic difference in an A/B. Ritual
                  // completion would have read as lower on V3 for a reason
                  // that has nothing to do with which home she prefers, and
                  // the toggle would have "proved" it.
                  //
                  // ⚠️ RENAMED, NOT REBUILT. The card, the store, the streak
                  // and the five parts are untouched; only the words over them
                  // changed. What the section always was — a few minutes a day
                  // of preparation before conception — had been labelled
                  // "Daily ritual", which says when it happens and nothing
                  // about what it is for.
                  //
                  // ⚠️ "GARBHADHANA SAMSKARA", NOT "GARBH SANSKAR". The two
                  // name different things and the difference is the whole point
                  // of this section: Garbh Sanskar is the PREGNANCY practice
                  // and ParentVeda already ships it, five pillars deep, in the
                  // pregnancy stage. Garbhadhana Samskara is the older,
                  // narrower idea of preparing *before* conception. Using the
                  // pregnancy name here would promise a woman who has not
                  // conceived the pregnancy feature — and would make the two
                  // stages look like the same screen twice.
                  //
                  // ⚠️ RESHAPED 2026-09-16 TO THE PARENTING V3 GRAMMAR. The
                  // user asked for the lower half of this screen to take the
                  // shapes the parenting and pregnancy V3 homes now have, so
                  // the three stages read as one app. Three decisions came
                  // with it, all the user's:
                  //
                  //   · "Sanskar", not "Samskar" — see ttc_strings.dart.
                  //   · The subtitle "Improve your chances" is gone.
                  //   · NO COUNTER AND NO STREAK. The 0/5 and the "3 days"
                  //     that `_RitualCardV3` carried are the two things the
                  //     parenting brief refused ("no counters, no streak, no
                  //     2 of 3") and the Grow feature refused before it: a
                  //     number that resets punishes the parent who had a hard
                  //     fortnight. Completing from the home is unchanged —
                  //     that is the parity invariant, and it is held by the
                  //     Done pill rather than by a fraction.
                  //
                  // Each part is now a card in the shape of parenting's
                  // "Activities to do today": a tinted mark, the part's name,
                  // TODAY'S prompt for it (the actual sentence, not the generic
                  // "why"), and a Done pill. Done stays on the page, dimmed,
                  // until tomorrow. The old intro and card are kept below for
                  // revert:
                  //   _pad(_SectionIntro(
                  //       title: TtcS.current().samskarTitle,
                  //       subtitle: TtcS.current().samskarSubtitle,
                  //       body: TtcS.current().samskarBody,
                  //       p: p)),
                  //   const SizedBox(height: 14),
                  //   _pad(_RitualCardV3(p: p, hinglish: hinglish, chapter: chapter)),
                  //
                  // ⚠️ A PHOTOGRAPH BEHIND IT, LIKE PREGNANCY'S GARBH SANSKAR.
                  // Asked for by name: "provide image behind sanskar thing, so
                  // that it looks good like we have in pregnancy v3". Pregnancy
                  // V3 (`V3GarbhBlock`, the same day's design) gives its
                  // practice a full-bleed band with the name on it and the
                  // card lifting onto the band — the page's third full-bleed
                  // moment after the hero and the film. This is that shape,
                  // with this stage's own photograph: the one the Mind & body
                  // door already carries, rather than a new id picked blind.
                  //
                  // The band sits OUTSIDE `_pad` because it reaches both edges;
                  // the cards under it inset themselves.
                  _SanskarBlock(p: p, hinglish: hinglish, chapter: chapter),
                  const SizedBox(height: 32),

                  // ---- TODAY ------------------------------------------------
                  //
                  // ⚠️ FIVE GATES V1 HAD AND V3 DID NOT. The insight, the myth,
                  // today's nutrition, today's movement and today's pick were
                  // all reachable from the V1 home and from nowhere on this
                  // one. That is the V1/V3 toggle failing its own premise: it
                  // is an A/B on how the home LOOKS, so anything only one side
                  // can reach makes the comparison about coverage instead.
                  //
                  // ⚠️ A ROW GROUP, NOT FIVE CARDS, and the reason is the same
                  // one written into `ttc_today_screen.dart`: a row is a line
                  // you scan, a card is a small article you have to read. Five
                  // more `_LinkCard`s here would have doubled the page's height
                  // to carry five sentences. The insight keeps a card because
                  // it is the one item that is genuinely an article.
                  //
                  // ⚠️ V1'S OWN TWO STRINGS, NOT NEW ONES. The eyebrow above
                  // already reads "TODAY" for the practice section, and a
                  // second "TODAY" under it read as a rendering fault. Reaching
                  // for `todaysJourney` / `todaysJourneyTitle` fixes it and
                  // costs nothing: they are the exact labels V1 puts over this
                  // exact group, so the two homes now name the same block the
                  // same way — which is what makes flipping the pill a
                  // comparison rather than a re-orientation.
                  //
                  // ⚠️ THIS BLOCK MOVED TO THE TOP OF THE PAGE AS `_DailyRail`.
                  // The five items and their five destinations are unchanged —
                  // what changed is that they are now circles above the doors
                  // instead of a card and four rows below them.
                  //
                  // Kept for revert, and the coverage argument above still
                  // applies to whichever shape is live: five gates V1 has, V3
                  // has to have. `test/ttc_home_v3_parity_test.dart` is what
                  // actually holds that, and it passes against the rail because
                  // the rail reuses these exact strings as its captions.
                  //
                  // _pad(_Head(
                  //     eyebrow: TtcS.current().todaysJourney,
                  //     title: TtcS.current().todaysJourneyTitle,
                  //     p: p)),
                  // const SizedBox(height: 12),
                  // _pad(_InsightCardV3(p: p, hinglish: hinglish)),
                  // const SizedBox(height: 10),
                  // _pad(_TodayRows(p: p, hinglish: hinglish)),
                  // const SizedBox(height: 32),

                  // ---- RECOMMENDED PRODUCTS --------------------------------
                  //
                  // ⚠️ A RAIL, AND IT SITS ABOVE THE READS RATHER THAN AT THE
                  // FOOT. The page still does not CLOSE on a shop — see the
                  // People section's note, which is the rule this obeys — but
                  // "today's pick" as a single row was the only commerce on the
                  // home and it was doing the job badly: one product, chosen by
                  // a day-of-year rotation, with no way to see the others
                  // without leaving.
                  //
                  // ⚠️ NEVER A PRODUCT THAT CLAIMS TO IMPROVE HER ODDS. The
                  // catalogue's own `whyEn` is what renders here, and every
                  // entry in `ttc_products_data.dart` carries a "look for" and
                  // a "watch out" for exactly this reason. A supplement rail on
                  // a fertility home is one careless subtitle away from being a
                  // claim, which is why the card shows the category and the
                  // price and not a benefit.
                  //
                  // Renamed 2026-09-16 to the parenting wording, and the cards
                  // take parenting's shape (an image well, the name, a chip,
                  // the price, a chevron) and open THAT product rather than
                  // the shop's front page. The chip is the category where
                  // parenting shows a why-line — the rule above stands: never
                  // a benefit under a supplement on a fertility home.
                  // Kept for revert:
                  //   _pad(_Head(
                  //       eyebrow: hinglish ? 'Saman' : 'Worth having',
                  //       title: hinglish ? 'Aapke liye' : 'Recommended for you',
                  //       p: p)),
                  _pad(_Head(
                      eyebrow: hinglish ? 'Aapke liye' : 'Recommended',
                      title: hinglish
                          ? 'Aapke liye products'
                          : 'Recommended products for you',
                      p: p)),
                  const SizedBox(height: 14),
                  // ⚠️ THE STORE'S OWN CARDS, WITH THEIR PHOTOGRAPHS (launch
                  // walk, 2026-09-27). This rail drew TTC's product guides as
                  // flat tinted blocks with a bag glyph, on the first screen a
                  // new user scrolls, while the Products tab showed the same
                  // things photographed. The same "where most couples start"
                  // pick as the Products tab; the guide rail stays for when
                  // the catalogue has nothing (a feature is never hidden).
                  // Kept for revert: _ProductRail(p: p, hinglish: hinglish),
                  ListenableBuilder(
                    listenable: PvCatalogStore.instance,
                    builder: (context, _) {
                      final picks = PvCatalogStore.instance
                          .forYou(LifeStage.tryingToConceive);
                      return picks.isEmpty
                          ? _ProductRail(p: p, hinglish: hinglish)
                          : PvCardRail(products: picks, scope: 'ttc_home');
                    },
                  ),
                  const SizedBox(height: 32),

                  // ---- RECOMMENDED READS -----------------------------------
                  // Renamed 2026-09-16 to the parenting wording. Kept for
                  // revert:
                  //   _pad(_Head(
                  //       eyebrow: hinglish ? 'Padhne ke liye' : 'To read',
                  //       title: hinglish ? 'Aapke chapter ke liye' : 'Recommended reads',
                  //       p: p)),
                  // ⚠️ THE TITLE FOLLOWS THE STRIP (2026-09-26, consistency
                  // pass). The reads under it have followed the selected day
                  // since they were chosen by phase, while the heading kept
                  // saying "for today". New wording is English only
                  // (CLAUDE.md); today's pair is unchanged. Kept for revert:
                  //   title: hinglish
                  //       ? 'Aaj ke liye reads'
                  //       : 'Recommended reads for today',
                  _pad(_Head(
                      eyebrow: hinglish ? 'Padhne ke liye' : 'Read',
                      title: _selected == _today
                          ? (hinglish
                              ? 'Aaj ke liye reads'
                              : 'Recommended reads for today')
                          : ttcReadsTitleFor(_dayTitle(_selected)),
                      p: p)),
                  const SizedBox(height: 12),
                  // ⚠️ THE THREE TABS ARE ON THE CARD NOW, as pills — the
                  // design's shape. They used to be three boxes under a link
                  // card; same three destinations. The note that put them
                  // here rather than in the hero still holds: the V3 field is
                  // a photographic surface carrying a spine chip and one
                  // large number, and three chrome circles on it is the
                  // gradient-and-shortcut hero V3 exists to replace. `ttc_chapter`
                  // opens the reader at its DEFAULT tab, so without these
                  // V3 could reach "Me" and nothing else. Kept for revert:
                  //   _pad(_LinkCard(
                  //     title: chapter.title(hinglish),
                  //     body: chapter.nextUp(hinglish),
                  //     p: p,
                  //     hue: _chapterHue(chapter),
                  //     mark: V3DailyMark.note,
                  //     onTap: () => _openSurface(context, 'ttc_chapter'),
                  //   )),
                  //   const SizedBox(height: 10),
                  //   _pad(_ChapterTabs(p: p, chapter: chapter)),
                  // ⚠️ NO CHAPTER CARD UNDER "RECOMMENDED READS" (the user,
                  // 2026-09-27: "Recommended reads for today should only carry
                  // the reads… what is this Trying Together… why is it even
                  // present?"). A chapter card is not a read, and its name
                  // explained nothing. The chapter reader stays reachable from
                  // the journey map and Learn. Kept for revert:
                  //   _pad(_ChapterCard(
                  //       p: p,
                  //       hinglish: hinglish,
                  //       chapter: chapter,
                  //       onOpen: () => _openSurface(context, 'ttc_chapter'))),
                  //   const SizedBox(height: 12),

                  // ⚠️ THE LIBRARY, WHICH THE CHAPTER CARD ALSO CANNOT REACH.
                  // `kTtcReads` is the largest body of content in the stage and
                  // the home linked to none of it — the chapter reader is a
                  // different thing written for a different moment. The rail is
                  // the read equivalent of the door grid: a way in, not a feed.
                  // ⚠️ CHOSEN BY HER PHASE SINCE 2026-09-26 (gap analysis,
                  // P1): "When to take a test" on a period day was the date
                  // rotation's doing. The rotation now only turns inside the
                  // phase's own set, and "See everything" is the way to the
                  // whole library, which four cards never were.
                  _ReadRail(
                      p: p, hinglish: hinglish, day: _selected, phase: phase),
                  // ⚠️ NO "SEE EVERYTHING" ROW (the user, 2026-09-27: "see
                  // everything is not needed"). The reads are the section;
                  // every read is one tap away on the Learn tab in the bar.
                  // Kept for revert:
                  //   const SizedBox(height: 12),
                  //   _pad(_SeeAllRow(
                  //       key: const ValueKey('ttc_home_reads_see_all'),
                  //       label: kTtcSeeEverything,
                  //       p: p,
                  //       onTap: () => openTtcTabV3(context, 1))),
                  const SizedBox(height: 32),

                  // ---- JOURNAL ---------------------------------------------
                  //
                  // ⚠️ KEPT, THOUGH THE REORDER DID NOT ASK FOR IT. The section
                  // list this page was rebuilt against names the header, the
                  // stories, the doors, the samskar, products, reads, experts
                  // and the way out — and not the journal. Dropping it was the
                  // wrong reading: `ttc_journal` has no other entrance on this
                  // home, so removing the section would not have moved it, it
                  // would have deleted it. Placed after the reads and before
                  // the people, which is where it interrupts least.
                  //
                  // ⚠️ LITERALLY PREGNANCY'S WIDGET, not a third copy of it.
                  // Same marks, same hues, same outlined button. Only the two
                  // labels differ, because only the two labels are about a
                  // different stage. Parenting made the same call for the same
                  // reason.
                  //
                  // ⚠️ RESHAPED 2026-09-16 to the parenting journal card: a
                  // square on the left (a pen, not a camera — this stage is
                  // written more than photographed), a prompt, four entry
                  // chips, "Open the journal" under it. The four destinations
                  // are exactly the four the tile card reached. The shared
                  // `V3JournalSection` is kept below for revert; the day
                  // pregnancy takes this card too it should become the shared
                  // one again.
                  //   _pad(_Head(
                  //       eyebrow: hinglish ? 'Aaj ke liye' : 'Keep today',
                  //       title: hinglish ? 'Aapki journal' : 'Your journal',
                  //       p: p)),
                  //   const SizedBox(height: 12),
                  //   _pad(V3JournalSection(
                  //     p: p,
                  //     onOpenAll: () => _openSurface(context, 'ttc_journal'),
                  //     actions: [
                  //       V3QuickAction(
                  //           icon: Icons.edit_note_rounded,
                  //           mark: V3DailyMark.memory,
                  //           hue: 42,
                  //           label: hinglish ? 'Kuch\nlikhein' : 'Write\nsomething',
                  //           onTap: () => _openSurface(context, 'ttc_journal')),
                  //       V3QuickAction(
                  //           icon: Icons.favorite_border_rounded,
                  //           mark: V3DailyMark.capsule,
                  //           hue: 344,
                  //           label: hinglish ? 'Aaj kaisa\nlaga' : 'How today\nfelt',
                  //           onTap: () => _openSurface(context, 'ttc_journal')),
                  //       V3QuickAction(
                  //           icon: Icons.checklist_rounded,
                  //           mark: V3DailyMark.note,
                  //           hue: 206,
                  //           label: hinglish ? 'Roz ka\nlog' : 'Log for\ntoday',
                  //           onTap: () => _openSurface(context, 'ttc_calendar')),
                  //       V3QuickAction(
                  //           icon: Icons.people_outline_rounded,
                  //           mark: V3DailyMark.photo,
                  //           hue: 268,
                  //           label: hinglish ? 'Saath\nmein' : 'The two\nof you',
                  //           onTap: () => _openSurface(context, 'ttc_partner')),
                  //     ],
                  //   )),
                  _pad(_Head(
                      // One name with the page it opens (launch sanity H18,
                      // 2026-09-28): the journal is shared with him and its
                      // page and the Tools tile say "Our journal". Kept for
                      // revert: hinglish ? 'Aapki journal' : 'Your journal'.
                      eyebrow: TtcS.current().journalTitle,
                      title: hinglish
                          ? 'Aaj ka kuch rakh lein'
                          : 'Keep something from today',
                      action: 'See all',
                      onAction: () => _openSurface(context, 'ttc_journal'),
                      p: p)),
                  const SizedBox(height: 14),
                  // ⚠️ THE JOURNAL, AS THE PREGNANCY HOME DRAWS IT (the user,
                  // 2026-09-27: "looks very vague… improve the
                  // representation"). A pen in a well, a paragraph and four
                  // grey chips read as a form. Now three drawn tiles, one per
                  // kind of writing, each opening that writer; the way to
                  // everything written is "See all" in the heading, not a row
                  // of its own. Kept for revert: the `_JournalInvite` call below.
                  _pad(_TtcJournalTiles(
                    p: p,
                    onNoticed: () =>
                        writeTtcEntry(context, kind: TtcEntryKind.memory),
                    onFelt: () =>
                        writeTtcEntry(context, kind: TtcEntryKind.feeling),
                    onDoctor: () =>
                        writeTtcEntry(context, kind: TtcEntryKind.question),
                  )),
                  // _pad(_JournalInvite(
                    // p: p,
                    // hinglish: hinglish,
                    // // ⚠️ EACH CHIP OPENS WHAT IT SAYS (launch walk,
                    // // 2026-09-27). "Write" and "How today felt" opened the
                    // // journal's front page, one tap short; "Log for today"
                    // // opened the CALENDAR; "The two of you" opened the
                    // // partner screen (his side is its own pass, the user's
                    // // call). Now: a memory, a feeling, the logger, and a
                    // // question for the doctor, the journal's own kinds.
                    // // Kept for revert:
                    // //   onWrite/onFelt: _openSurface(context, 'ttc_journal'),
                    // //   onLog: _openSurface(context, 'ttc_calendar'),
                    // //   onUs: _openSurface(context, 'ttc_partner'),
                    // onWrite: () =>
                        // writeTtcEntry(context, kind: TtcEntryKind.memory),
                    // onFelt: () =>
                        // writeTtcEntry(context, kind: TtcEntryKind.feeling),
                    // onLog: () => _openSurface(context, 'ttc_symptom_log'),
                    // onUs: () =>
                        // writeTtcEntry(context, kind: TtcEntryKind.question),
                    // onOpenAll: () => _openSurface(context, 'ttc_journal'),
                  // )),
                  const SizedBox(height: 32),

                  // ---- PEOPLE ----------------------------------------------
                  //
                  // ⚠️ THE ONE SECTION THAT ENDS THE PAGE, and deliberately not
                  // the products rail. TTC is the stage where the paid layer is
                  // genuinely real — thirteen offerings with named experts —
                  // which makes it the stage where closing on a shop would be
                  // most tempting and most wrong. The last thing she reads is
                  // that there is a person, not that there is a price.
                  //
                  // ⚠️ FOUR CARDS, NOT ONE LINK — 2026-09-16. The single link
                  // card named four people in a sentence and opened the whole
                  // Prepare catalogue; now each of the four is a card that
                  // opens ITS consultation, and "See everyone" is the door to
                  // the catalogue. No prices on this home: the rule that this
                  // section closes the page on a person, not a price, is why
                  // it is last and why the cards carry a role and not a rate.
                  // Kept for revert:
                  //   _pad(_LinkCard(
                  //     title: hinglish ? 'Fertility experts' : 'Fertility experts',
                  //     body: hinglish
                  //         ? 'Gynae, fertility specialist, nutritionist, psychologist — '
                  //             'video par, aapke waqt par.'
                  //         : 'A gynaecologist, a fertility specialist, a nutritionist, '
                  //             'a psychologist — on video, at a time you choose.',
                  //     p: p,
                  //     hue: 186,
                  //     mark: V3DailyMark.capsule,
                  //     onTap: () => _openSurface(context, 'ttc_prepare'),
                  //   )),
                  // ⚠️ "SEE ALL" SITS IN THE HEADING (the user, 2026-09-27:
                  // "a button with that functionality taking so much space
                  // like its own row… how is that a good user experience?").
                  // The consults, not the whole catalogue, as before.
                  _pad(_Head(
                      eyebrow: hinglish ? 'Log' : 'People',
                      title: hinglish ? 'Expert se baat karein' : 'Talk to experts',
                      action: 'See all',
                      onAction: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              settings:
                                  const RouteSettings(name: 'ttc/consults'),
                              builder: (_) => const TtcPrepareScreen(
                                  onlyCategory: 'consults'))),
                      p: p)),
                  const SizedBox(height: 14),
                  _ExpertRail(p: p, hinglish: hinglish),
                  // Kept for revert: the full-width "See everyone" row.
                  // const SizedBox(height: 12),
                  // _pad(_SeeAllRow(
                      // label: hinglish ? 'Sabko dekhein' : 'See everyone',
                      // p: p,
                      // // The consults, not the whole catalogue (2026-09-27):
                      // // "See everyone" under "Talk to experts" opened every
                      // // course and class, pregnancy's included. Kept for
                      // // revert: _openSurface(context, 'ttc_prepare').
                      // onTap: () => Navigator.of(context).push(
                          // MaterialPageRoute<void>(
                              // settings:
                                  // const RouteSettings(name: 'ttc/consults'),
                              // builder: (_) => const TtcPrepareScreen(
                                  // onlyCategory: 'consults'))))),
                  const SizedBox(height: 26),

                  // ---- THE DOOR OUT ----------------------------------------
                  //
                  // ⚠️ THE ONLY WAY TO LEAVE THIS STAGE, and V3 did not have
                  // it. A positive test on the V3 home had nowhere to go: she
                  // would have had to flip back to V1 to tell the app she is
                  // pregnant, which is not a thing anyone would work out.
                  //
                  // Understated on purpose, and it keeps V1's rule: no
                  // celebration styling, no tint block, no eyebrow. It is a
                  // door, and it must never read as "why haven't you tested?".
                  _pad(_TestDoor(p: p)),
                  const SizedBox(height: 22),

                  // ⚠️ EVERY TOOL CARRIES THIS AND THE BUSIEST SCREEN DID NOT
                  // — which is backwards, because Today is where an estimate is
                  // read fastest and questioned least. Same words as V1, in
                  // this palette.
                  _pad(_HomeDisclaimer(p: p)),
                ]),
              ],
            ),

            // ⚠️ THE DEV SWITCH MOVED TO PROFILE. It sat bottom-right over
            // the door grid and the FAB clearance, and appeared in every
            // screenshot of the product. Profile is the one surface both
            // versions and both partners share, which is what makes it
            // the only place a version toggle can actually live.
            //
//             // ---- THE DEV SWITCH --------------------------------------------
//             //
//             // TESTING-ONLY Her | Him pill, at the same coordinates `TtcPage`
//             // floats it for V1 (right 14, bottom 96) so it does not appear to
//             // move when the toggle is flipped. Remove before launch, with V1's.
//             Positioned(
//               right: 14,
//               // Same fix as the version pill on the opposite corner: a literal
//               // 96 sits behind the tab bar wherever the device has a system
//               // navigation inset. See `pvNavClearance`.
//               bottom: pvNavClearance(context),
//               child: ttcModePill(TtcS.current(), him: false),
//             ),
//
//
            // ---- THE NAV ---------------------------------------------------
            //
            // ⚠️ V3 SHIPPED WITHOUT ONE, AND THAT WAS THE LARGEST HOLE IN IT.
            // `TtcTodayScreen` (V1) gets its nav from `TtcPage`; this screen
            // builds its own Scaffold because the field has to be the page's
            // surface rather than something inside a gutter — so it inherited
            // no nav, and Prepare · Tools · Calendar · Community simply did not
            // exist in V3. Four of five tabs unreachable is not a home.
            //
            // ⚠️ THE SAME FIVE TABS AS V1, DELIBERATELY, and not a V3-specific
            // set. Two reasons, both load-bearing:
            //
            //   · This is an A/B toggle. Changing the nav AND the home means a
            //     reaction to V3 cannot be attributed to either one.
            //   · CLAUDE.md forbids per-pathway navigation — personalisation
            //     changes content, ranking and order, never structure. A
            //     version that navigates differently makes the V1→V3 crossing
            //     the thing she has to relearn, which is the exact cost this
            //     stage's shared widgets exist to avoid.
            //
            // `TtcBottomNav` is already a free-floating pill positioned in a
            // Stack, so this is a drop-in rather than a layout change.
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: SafeArea(
                  top: false, child: TtcBottomNav(active: 0, v3: true)),
            ),
          ]),
        );
      },
    );
  }

  void _openBracket(BuildContext context, String id) {
    final b = bracketById(id);
    if (b == null) return;
    final hinglish = TtcLang.instance.hinglish;

    // ⚠️ A FOCUS PAGE SHORT-CIRCUITS THE HUB, AND IT IS CHECKED FIRST.
    //
    // Conceiving used to open a hub asking "What do you need?" with three
    // answers — the fertile-window tool, "Improve my chances this cycle", and a
    // consult. The middle one opened a four-step journey whose FIRST step was
    // the fertile-window tool sitting next to it, so the menu was offering a
    // choice between a thing and a wrapper around the same thing.
    //
    // So there is no middle menu any more. The tool is section one of the page,
    // the reading is its body, the consult is its last tile.
    //
    // ⚠️ FIRST, NOT LAST, so a bracket that has both a focus page and a hub
    // config cannot depend on which happens to be found. Six of seven TTC
    // brackets still have no focus page and still open hubs, correctly — a hub
    // is right when an area really is several separate errands.
    // ⚠️ THE NEW DOOR (2026-09-26). Every TTC door now opens `TtcDoorScreen`,
    // the pregnancy door language, through the one opener; same route name
    // `ttc/focus/<id>`. The old push, kept for revert:
    //
    // final focus = ttcFocusPageFor(id);
    // if (focus != null) {
    //   Navigator.of(context).push(MaterialPageRoute<void>(
    //     settings: RouteSettings(name: 'ttc/focus/$id'),
    //     builder: (_) => TtcFocusScreen(page: focus, bracket: b),
    //   ));
    //   return;
    // }
    if (openTtcDoor(context, id)) return;

    // ⚠️ THE HUB REGISTRY DECIDES, NOT THIS SCREEN.
    //
    // Two outcomes: a hub with 2+ doors pushes the hub screen; a hub with ONE
    // door opens that door's destination directly, because a screen whose only
    // content restates the tile she just tapped is a tap of pure tax. See
    // lib/data/hubs/hub_registry.dart.
    final hub = hubFor(id);
    if (hub != null) {
      final sole = soleDoorOf(id);
      if (sole != null) {
        if (sole.action != null) {
          _hubAction(context, sole.action!);
        } else if (sole.surfaceId != null) {
          _openSurface(context, sole.surfaceId!);
        }
        return;
      }
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'hub/' + id),
        builder: (_) => ProblemHubScreen(
          config: hub,
          bracket: b,
          lang: hinglish ? AppLanguage.hinglish : AppLanguage.english,
          listenTo: V2PaletteStore.instance,
          onSurface: _openSurface,
          onAction: _hubAction,
        ),
      ));
      return;
    }


    Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: 'bracket_detail'),
      builder: (_) => BracketScreen(
        bracket: b,
        // ⚠️ TTC's language flag, not the pregnancy `AppLanguage` store. The two
        // are separate on purpose — this stage is still Hinglish and pregnancy
        // is Devanagari, and reading the wrong one would render Devanagari rows
        // inside a Hinglish shell.
        lang: hinglish ? AppLanguage.hinglish : AppLanguage.english,
        labelFor: (surfaceId) =>
            ttcSurfaceLabel(surfaceId, hinglish: hinglish),
        onOpenSurface: _openSurface,
      ),
    ));
  }

  /// The TTC hub actions.
  ///
  /// WARNING: every one either reuses a LIVE surface or says plainly that it is
  /// owed. None of them opens a vaguely-related screen and hopes -- that looks
  /// like an answer, wastes her time, and makes her think she failed to find it.
  void _hubAction(BuildContext context, String action) {
    // ⚠️ A JOURNEY FIRST, IF THIS DOOR HAS ONE.
    //
    // Doors whose destination already finishes the job fall straight through to
    // the switch below — wrapping a journey around a complete screen is the
    // same tax as a hub screen in front of a single door.
    final journey = journeyFor(action);
    if (journey != null) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'journey/' + action),
        builder: (_) => JourneyScreen(
          config: journey,
          onSurface: _openSurface,
          onAction: _hubAction,
        ),
      ));
      return;
    }

    void owed(String title, String willHold,
        {String? meanwhile, String? meanwhileWhy, String? surface}) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/owed'),
        builder: (_) => HubOwedScreen(
          title: title,
          willHold: willHold,
          meanwhileLabel: meanwhile,
          meanwhileValue: meanwhileWhy,
          onMeanwhile:
              surface == null ? null : () => _openSurface(context, surface),
        ),
      ));
    }

    switch (action) {
      // The booking engine, configured -- never a new appointment feature.
      // Scoped to the consult category. Unscoped, this opened nine categories
      // and asked her to scroll past yoga and nutrition to reach the card she
      // had just tapped a button about.
      case kTtcActConsult:
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc/consults'),
          builder: (_) => const TtcPrepareScreen(onlyCategory: 'consults'),
        ));

      // WARNING: timing and habits ONLY. This must never become a computed
      // "your chance this month" -- no personalised probability, ever.
      case kTtcActImproveChances:
        owed('Improve my chances this cycle',
            'Timing across your fertile days, and the few habits that really '
            'make a difference. We won\'t put a number on whether it will '
            'happen. That isn\'t ours to say.',
            meanwhile: 'Your cycle',
            meanwhileWhy: 'Track where you are this month.',
            surface: 'ttc_cycle');

      case kTtcActSpermHealth:
        owed('Understand sperm health',
            'What a semen analysis measures, what the numbers mean, and the '
            'ninety-day window that makes changes worth it.',
            meanwhile: 'For him, today',
            meanwhileWhy: 'His side of it, one thing at a time.',
            surface: 'ttc_partner');

      case kTtcActPcosLibrary:
        owed('Understand my PCOS',
            'What PCOS does to your cycle, in plain words, and what usually '
            'comes next.',
            meanwhile: 'Your cycle',
            meanwhileWhy: 'See what your own cycle is doing.',
            surface: 'ttc_cycle');

      case kTtcActFertilityReadinessCheck:
        owed('Should I seek fertility help?',
            'How long to try before seeing someone, by age. So you can '
            'decide, instead of wondering.',
            meanwhile: 'Tests worth knowing about',
            meanwhileWhy: 'What a first appointment usually checks.',
            surface: 'ttc_tests');

      case kTtcActPreconceptionReadiness:
        owed('Get ready before trying',
            'The few things worth doing in the months before: supplements, '
            'check-ups, and what your partner should do too.',
            meanwhile: 'Supplements',
            meanwhileWhy: 'What to start, and when.',
            surface: 'ttc_supplements');

      // WARNING: no "meanwhile" here, deliberately. After a loss, being handed
      // a cycle tracker instead of what she asked for is worse than being told
      // honestly that it is not ready.
      case kTtcActLossRecoveryLibrary:
        owed('Understand recovery and trying again',
            'What your body needs before trying again, how long doctors '
            'usually suggest, and what to expect from yourself. At your own '
            'pace.');
    }
  }

}

/// Push whichever screen a TTC surface id names.
///
/// ⚠️ TOP-LEVEL, NOT A METHOD ON THE STATE, and the move was forced rather than
/// tidy-minded: the insight-card router is a top-level function, so a private
/// method on `_TtcHomeV3State` was out of its reach. It touches no instance
/// state — context in, navigation out — so there was never a reason for it to
/// be one, and being top-level means every widget in this file can reach a
/// surface without threading a callback down through four constructors.
void _openSurface(BuildContext context, String id) {
  final screen = ttcScreenForSurface(id);
  // Null is a real answer — see the router. Nothing happens rather than
  // something wrong.
  if (screen == null) return;
  Navigator.of(context).push(MaterialPageRoute(
    settings: RouteSettings(name: id),
    builder: (_) => screen,
  ));
}

Widget _pad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

// =============================================================================
//  The cycle header
// -----------------------------------------------------------------------------
//  The week, the window, and the two things she came to do.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE BIG LINE IS A TIMING ESTIMATE AND IT IS NEVER A PROBABILITY
//  ---------------------------------------------------------------------------
//
//  The obvious headline for a fertility home — the one every competitor
//  prints — is a chance. This one states WHEN, never HOW LIKELY, and the
//  distinction is not stylistic:
//
//    · "Your fertile days open in 5 days" is a timing estimate built from a
//      logged period and an assumed luteal phase. The app already makes it, on
//      the cycle companion and the window screen, and it is honest about being
//      an estimate.
//    · A percentage attached to her, this cycle, is a personalised probability.
//      Forbidden outright — CLAUDE.md, and `test/ttc_clinical_review_test.dart`
//      scans source for it rather than trusting a seed list.
//
// ⚠️ AND THE SCANNER READS COMMENTS TOO, WHICH IS WHY THAT SECOND BULLET IS
// DESCRIBED RATHER THAN QUOTED. Writing the forbidden sentence out as an
// example of what not to do failed the test, correctly: a regex cannot tell an
// illustration from a claim, and a comment is one careless copy-paste from
// being a string. Describe the shape, never type the line.
//
//  ⚠️ AND IT REFUSES, LOUDLY, IN THREE CASES. Nothing logged, a clinic holding
//  the timing, or an engine that has declined to estimate all produce a
//  SENTENCE rather than a number. `ttcFertileWindowNow` returns null for the
//  last two and the header says which. The failure this prevents is the one
//  already written up in `TtcNoEstimate`: "ovulation around day 40" appearing
//  on five screens from a single unlogged gap.
//
//  ⚠️ TWO ACTIONS, NOT SEVEN. Edit period dates and check symptoms — the two
//  things that make every estimate on this page better, and nothing else. A
//  header is the most valuable strip on a screen and the most tempting place
//  to put a row of shortcuts; a row of shortcuts is what the V3 field exists to
//  replace.
// =============================================================================

class _CycleHeader extends StatelessWidget {
  const _CycleHeader({
    required this.today,
    required this.p,
    required this.hinglish,
    required this.selected,
    required this.todayDate,
    required this.onSelectDay,
    required this.onChapter,
    required this.onCycle,
    required this.onCalendar,
    required this.onProfile,
    required this.onMessages,
    required this.unread,
  });

  final TtcToday today;
  final V2Palette p;
  final bool hinglish;

  /// The messages list, and how many are unread (drawn as a dot, never a
  /// number). Added 2026-09-26: the app now speaks first, and the envelope is
  /// where what it said waits.
  final VoidCallback onMessages;
  final int unread;

  /// The day the whole page is describing. Owned by the screen, not by the
  /// strip — the heading and the cards below need it too, and a selection that
  /// lived inside the strip would leave them stuck on today.
  final DateTime selected;

  /// ⚠️ PASSED IN, NOT READ FROM THE CLOCK HERE. Three widgets on this screen
  /// need to agree about which day is today, and the moment any of them asks
  /// `DateTime.now()` for itself, they can disagree — which is exactly the bug
  /// the state's `_today` field exists to fix. One source, threaded down.
  ///
  /// ⚠️ `todayDate`, NOT `today`, BECAUSE `today` IS ALREADY TAKEN on this
  /// widget — by `TtcToday`, the store's snapshot of her journey state. Two
  /// completely different meanings of the same word, and the compiler caught
  /// the collision only because they happen to be different types. Worth the
  /// clumsier name.
  final DateTime todayDate;

  final ValueChanged<DateTime> onSelectDay;

  final VoidCallback onChapter;
  final VoidCallback onCycle;
  final VoidCallback onCalendar;
  final VoidCallback onProfile;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final now = DateTime.now();

    // ---- where she is today (ttc_home_situation.dart) ----------------------
    final onToday = selected == todayDate;
    final late = onToday &&
            ttcHomeHeroLine(on: selected).state == TtcHeroState.periodLate
        ? ttcHomeLateAdvice()
        : null;
    final periodCame = onToday && ttcIsNewPeriodDayOne(selected);
    final future = selected.isAfter(todayDate);
    final sexOn = ttcSexLoggedOn(selected);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ---- avatar · date · messages · calendar --------------------------
          //
          // ⚠️ THE TWO SIDES ARE EQUAL FIXED WIDTHS NOW (2026-09-26). The
          // envelope made the right side two buttons and the left one, and
          // with plain Spacers the date would have slid off centre by half a
          // button. Each side is the same 84pt box aligned to its edge, and
          // the date takes the middle and scales down rather than pushing a
          // button off the screen (the 360pt render tests caught exactly that
          // with an Expanded on each side). The old row, for revert:
          //   _RoundButton(avatar), Spacer(), date, Spacer(), _RoundButton(cal)
          // H6 (2026-09-26): each button is a 44pt target around its 38pt
          // disc, so each side is 88 (two 44s) and the discs sit 6 apart.
          // Was 84 with 38pt targets.
          Row(children: [
            SizedBox(
              width: 88,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _RoundButton(
                    icon: Icons.person_outline_rounded,
                    p: p,
                    onTap: onProfile,
                    semantic: t.profileTitle),
              ),
            ),
            // ⚠️ THE SELECTED DAY, NOT `now`. It read `DateTime.now()`, which
            // was right when the strip was decoration and became a second
            // contradiction the moment it was not: tap back three days and the
            // cards moved, the heading moved, and the date at the top of the
            // screen sat there still saying today.
            //
            // The year appears only when the selection leaves the current one,
            // because "30 August" is unambiguous in August and actively
            // misleading the following January.
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                      '${selected.day} ${_months[selected.month - 1]}'
                      '${selected.year == now.year ? '' : ' ${selected.year}'}',
                      maxLines: 1,
                      style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                          color: p.ink1)),
                ),
              ),
            ),
            SizedBox(
              width: 88,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ⚠️ THE MESSAGES THE APP SENDS HAD NO DOOR ON THE HOME
                    // (gap analysis, "Behind: Guided help", P1). A dot when
                    // something is unread; never a count.
                    TtcMessagesButton(
                        p: p, unread: unread, onTap: onMessages),
                    // ⚠️ THE CALENDAR HAD NO ENTRANCE ON THIS HOME AT ALL
                    // before the header. It was a nav tab and nothing else,
                    // which meant the one screen showing a whole month of her
                    // own logs was reachable only by knowing which of five
                    // icons it hid behind.
                    _RoundButton(
                        icon: Icons.calendar_today_rounded,
                        p: p,
                        onTap: onCalendar,
                        semantic: t.tabCalendar),
                  ]),
            ),
          ]),
          const SizedBox(height: 16),

          // ---- the week ----------------------------------------------------
          _WeekStrip(
              p: p,
              selected: selected,
              today: todayDate,
              onSelect: onSelectDay),
          const SizedBox(height: 12),

          // ---- which chapter -----------------------------------------------
          //
          // ⚠️ MOVED TO PROFILE. "Knowing your rhythm" was a chip above the big
          // line; it is now a row under "Your chapter" in Profile, which is
          // also the only door to the journey map on this version.
          //
          // The cost is worth restating because it is not small: which chapter
          // she is in was always visible and is now two taps away, on a stage
          // whose chapters RECUR and which therefore generates that question
          // constantly. Reachability is intact, which is the non-negotiable
          // part — see the wiring gate.
          //
          // V3SpineChip(
          //   label: today.chapter.title(hinglish).toUpperCase(),
          //   tone: V3HeroTone.onField,
          //   p: p,
          //   onTap: onChapter,
          // ),
          // const SizedBox(height: 12),

          // ---- the window, or the honest refusal ---------------------------
          // ⚠️ `selected`, NOT TODAY. Everything else in this header already
          // followed the strip — the date above it, the insight cards, the
          // symptom sheet, and the two actions, which dim on a future day. The
          // hero alone described today, so standing on the 3rd gave a page
          // about the 3rd with one sentence about the 5th in the middle of it.
          _WindowLine(
              today: today,
              p: p,
              hinglish: hinglish,
              selected: selected,
              late: late,
              onTap: onCycle),
          // 18 before the launch walk tightened the hero (2026-09-27).
          const SizedBox(height: 10),

          // ---- the hero's note (gap analysis, "Behind: Home & daily", P1) --
          //
          // ⚠️ ONLY ON TODAY, AND ONLY ONE. On a late day of her own cycle, a
          // way to the "Should I test?" chat; on the first day of a new
          // period, one kind line and the read about it. Both are about now,
          // so neither follows the strip into another day, and a clinic cycle
          // gets neither late wording (her clinic's blood test is the answer).
          if (late != null) ...[
            TtcHowToTestButton(p: p),
            const SizedBox(height: 16),
          ] else if (periodCame) ...[
            TtcPeriodCameLine(p: p),
            const SizedBox(height: 16),
          ],

          // ---- the two actions ---------------------------------------------
          //
          // ⚠️ BOTH FILLED NOW. One was `p.surface` and the other
          // `p.surface.withValues(alpha: 0.55)` with a border — a hierarchy
          // nobody asked for, and it broke the thing below: *"our check symptom
          // button is a little bit less saturated than the log button, so make
          // it the same, so that this effect that we are trying to achieve for
          // the future can be implemented way better."*
          //
          // Exactly the problem. If one control is permanently at 55% opacity,
          // then dimming a control to say "not available" says nothing — the
          // reader cannot tell a disabled button from the button that always
          // looked like that. **A resting state that borrows the disabled
          // state's only signal leaves you with no disabled state.**
          // ⚠️ ONE ROW OF FOUR, ONE DESIGN (2026-09-27). Asked for directly:
          // "they seem to take so much space and don't look good, also unify
          // their button design". The four were two families on two rows
          // (white filled pills, then hairline chips), about 106pt of the
          // hero. Now they are one row of the same round button with a short
          // word under it, the shape of the header's own circles and of a
          // quick-log row in Withings
          // (https://mobbin.com/screens/4bbe6258-860c-4a84-8287-df86a6702988):
          // about 70pt, and none of the four looks more important than
          // another. Every rule the old rows held still holds: the SELECTED
          // day, never today by default; dimmed on a day not lived yet; Sex
          // drawn only when intimacy content is shown; Sex and Test making way
          // for the blood test while an IVF-shaped round runs; a selected Sex
          // is ink with a white icon (§4.0), with a haptic and an Undo.
          // Kept for revert below: the two rows as they were.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeroQuickAction(
                key: const ValueKey('ttc_home_quick_period'),
                label: 'Period',
                // H1 (launch sanity, 2026-09-28): the label says what the
                // sheet now does. Kept for revert: t.headerEditPeriod.
                semantic: 'Log or change your period',
                icon: Icons.water_drop_outlined,
                p: p,
                // ⚠️ NEVER A NEW CYCLE BY REFLEX (H1). The stock picker
                // opened on TODAY, so one OK restarted her cycle. The sheet
                // opens on her logged start, says what Save will do, and
                // asks before a new cycle, with Undo after. Kept for revert:
                // onTap: () => logTtcPeriod(context),
                onTap: () => showTtcHomePeriodSheet(context),
              ),
              _HeroQuickAction(
                key: const ValueKey('ttc_home_quick_symptoms'),
                label: 'Symptoms',
                semantic: t.headerCheckSymptoms,
                icon: Icons.checklist_rounded,
                p: p,
                enabled: !future,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        settings:
                            const RouteSettings(name: 'ttc/symptom_log'),
                        builder: (_) =>
                            TtcSymptomLogScreen(day: selected))),
              ),
              if (!ttcHomeHidesQuickRow(selected) &&
                  !TtcContentPrefs.instance.hideIntimate)
                _HeroQuickAction(
                  key: const ValueKey('ttc_home_quick_sex'),
                  label: kTtcQuickSex,
                  semantic: sexOn ? 'Sex logged. Tap to take it off' : 'Log sex',
                  icon: sexOn
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  p: p,
                  on: sexOn,
                  enabled: !future,
                  onTap: () {
                    pvCommitFeedback();
                    final logged = ttcToggleSexOn(selected);
                    if (!logged) return;
                    final day = selected == todayDate
                        ? 'today'
                        : '${selected.day} ${_months[selected.month - 1]}';
                    pvSnack(
                      context,
                      'Logged for $day',
                      icon: Icons.check_rounded,
                      action: 'Undo',
                      onAction: () {
                        if (ttcSexLoggedOn(selected)) ttcToggleSexOn(selected);
                      },
                    );
                  },
                ),
              if (!ttcHomeHidesQuickRow(selected))
                _HeroQuickAction(
                  key: const ValueKey('ttc_home_quick_test'),
                  label: kTtcQuickTest,
                  semantic: 'Log a test',
                  icon: Icons.science_outlined,
                  p: p,
                  enabled: !future,
                  onTap: () {
                    pvCommitFeedback();
                    Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'ttc/symptom_log'),
                        builder: (_) => TtcSymptomLogScreen(
                            day: selected, focusGroup: kTtcTestGroupToOpen)));
                  },
                ),
            ],
          ),
          if (ttcHomeHidesQuickRow(selected)) ...[
            const SizedBox(height: 10),
            _BloodTestLine(day: selected, p: p),
          ],
          // Kept for revert (2026-09-27): the two rows of pills and chips.
          // Row(children: [
          // Expanded(
          // child: _HeaderAction(
          // label: t.headerEditPeriod,
          // icon: Icons.water_drop_outlined,
          // p: p,
          // onTap: () => logTtcPeriod(context),
          // ),
          // ),
          // const SizedBox(width: 10),
          // Expanded(
          // child: _HeaderAction(
          // label: t.headerCheckSymptoms,
          // icon: Icons.favorite_border_rounded,
          // p: p,
          // // ⚠️ A DAY THAT HAS NOT HAPPENED CANNOT BE LOGGED. Asked for
          // // directly — *"I should not be able to log symptoms in future
          // // dates"* — and it is the right rule for a reason beyond
          // // tidiness: this store is what the cycle report reads, and a
          // // symptom recorded against next Tuesday would sit in her
          // // history as a fact about a day nobody has lived.
          // //
          // // Disabled, not hidden. A control that vanishes on some dates
          // // makes the row jump as she walks the strip, and she would have
          // // to work out why. Dimmed, it says "not this day" and stays
          // // where her thumb expects it.
          // enabled: !selected.isAfter(todayDate),
          // // ⚠️ THE SELECTED DAY, NOT TODAY. Reported as *"if I go back to
          // // 29th August and click Check symptoms, it opens the symptoms
          // // for the current day."* It did: the push named no date, so the
          // // logger defaulted to `DateTime.now()`.
          // //
          // // That is the worst class of bug on a logging screen, because
          // // it is silent and it CORRUPTS. She thinks she is recording
          // // Saturday, the row lands on Monday, and every surface reading
          // // this store — the strip, the report, the calendar — is now
          // // confidently wrong about her body.
          // //
          // // ⚠️ THE NEW LOGGER, NOT `TtcTrackerScreen`. The generic
          // // tracker rendered six five-point sliders, which asked her to
          // // GRADE feelings she had already had and gave nothing back.
          // // `TtcSymptomLogScreen` writes to the same tracker id, so the
          // // calendar, the day strip and everything else reading
          // // `symptoms` keeps working across the change.
          // onTap: () => Navigator.of(context).push(
          // MaterialPageRoute<void>(
          // settings:
          // const RouteSettings(name: 'ttc/symptom_log'),
          // builder: (_) =>
          // TtcSymptomLogScreen(day: selected))),
          // ),
          // ),
          // ]),
          //
          // // ---- one tap: sex, and a test (gap analysis, P2) ------------------
          // //
          // // ⚠️ SEX WRITES THE LOGGER'S OWN FIELD. One tap records it for the
          // // day on the strip, a second tap takes it off; it is the
          // // `sex_unprotected` chip under `symptoms`, the same fact the logger,
          // // the calendar and the report already read, never a second key.
          // // Test opens the logger at the two test cards, which is the choice
          // // the gap analysis asked for. Both dim on a future day, for the
          // // reason written on "Check symptoms" above.
          // const SizedBox(height: 10),
          // // ⚠️ HIDDEN WHILE AN IVF-SHAPED ROUND RUNS (2026-09-26, §3e), and
          // // the blood test named in its place: a clinic often asks for no sex
          // // before his sample, and a home test before the blood test can
          // // mislead. It comes back the day the round closes
          // // (`ttcHomeHidesQuickRow`). Kept for revert: the row, always.
          // //
          // // ⚠️ THE REVIEW PASS (2026-09-26, H3, H4, H5):
          // //  · SECONDARY WEIGHT. Sex and Test are two compact chips under the
          // //    two main actions (a hairline, no fill), so the hero's pills do
          // //    not compete: one line, two actions, two small chips (Flo's
          // //    late day, FLO-LATE,
          // //    https://mobbin.com/screens/f92aea87-388d-42b6-b3b0-fb36b9b71a84).
          // //  · "HIDE SEX AND INTIMACY CONTENT" REACHES THIS ROW. With it on,
          // //    the Sex chip is not drawn at all and Test takes the row; a
          // //    neutral relabel would still log sex from a word that hides it.
          // //    Logging it stays in the symptom logger, where she chose it.
          // //  · THE ON-STATE IS INK (§4.0: a selected chip is ink1 with a white
          // //    label), with a haptic, and a white notice that says it is
          // //    logged with an Undo (E7).
          // // Kept for revert: two full-width `_HeaderAction` pills, the Sex one
          // // with a rose tinted fill when on, drawn whatever the switch said.
          // if (ttcHomeHidesQuickRow(selected))
          // _BloodTestLine(day: selected, p: p)
          // else
          // Row(children: [
          // if (!TtcContentPrefs.instance.hideIntimate) ...[
          // Expanded(
          // child: _QuickChip(
          // key: const ValueKey('ttc_home_quick_sex'),
          // label: kTtcQuickSex,
          // icon: sexOn
          // ? Icons.favorite_rounded
          // : Icons.favorite_border_rounded,
          // p: p,
          // on: sexOn,
          // enabled: !future,
          // onTap: () {
          // pvCommitFeedback();
          // final logged = ttcToggleSexOn(selected);
          // if (!logged) return;
          // final day = selected == todayDate
          // ? 'today'
          // : '${selected.day} ${_months[selected.month - 1]}';
          // pvSnack(
          // context,
          // 'Logged for $day',
          // icon: Icons.check_rounded,
          // action: 'Undo',
          // onAction: () {
          // if (ttcSexLoggedOn(selected)) ttcToggleSexOn(selected);
          // },
          // );
          // },
          // ),
          // ),
          // const SizedBox(width: 10),
          // ],
          // Expanded(
          // child: _QuickChip(
          // key: const ValueKey('ttc_home_quick_test'),
          // label: kTtcQuickTest,
          // icon: Icons.science_outlined,
          // p: p,
          // enabled: !future,
          // onTap: () {
          // pvCommitFeedback();
          // Navigator.of(context).push(MaterialPageRoute<void>(
          // settings: const RouteSettings(name: 'ttc/symptom_log'),
          // builder: (_) => TtcSymptomLogScreen(
          // day: selected, focusGroup: kTtcTestGroupToOpen)));
          // },
          // ),
          // ),
          // ]),
        ]),
      ),
    );
  }
}

/// One of the hero's four quick actions (2026-09-27): a round button with a
/// short word under it, the same object for all four, so the row reads as one
/// set rather than two kinds of button. A white disc like the header's own
/// circles; ON (Sex logged) is an ink disc with a white filled icon (§4.0).
/// Dimmed as one object on a day that has not happened. The whole column is
/// the tap target, well over 44pt.
class _HeroQuickAction extends StatelessWidget {
  const _HeroQuickAction({
    super.key,
    required this.label,
    required this.semantic,
    required this.icon,
    required this.p,
    required this.onTap,
    this.enabled = true,
    this.on,
  });

  /// The short word under the disc.
  final String label;

  /// What a screen reader says: the full action ("Edit period dates").
  final String semantic;
  final IconData icon;
  final V2Palette p;
  final VoidCallback onTap;
  final bool enabled;
  final bool? on;

  @override
  Widget build(BuildContext context) {
    final lit = on == true;
    final body = SizedBox(
      width: 72,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: lit ? p.ink1 : p.surface,
            shape: BoxShape.circle,
            border: Border.all(color: lit ? p.ink1 : p.line),
          ),
          child: Icon(icon, size: 20, color: lit ? Colors.white : p.ink1),
        ),
        const SizedBox(height: 6),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: pvManrope(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink1)),
      ]),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      toggled: on,
      label: semantic,
      // ⚠️ excludeSemantics DROPS THE INKWELL'S TAP ACTION TOO, so the node
      // must carry it itself, or a screen reader hears "button" and cannot
      // press it (found on the device walk, 2026-09-27).
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: PvPress(
        enabled: enabled,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: enabled ? body : Opacity(opacity: 0.42, child: body),
          ),
        ),
      ),
    );
  }
}


/// One of the two small one-tap chips under the hero's actions (H4, H5):
/// a hairline, no fill, 44pt tall; ON is an ink fill with a white label and
/// a filled icon. Dimmed as one object on a day that has not happened.
// ignore: unused_element (kept for revert since 2026-09-27; `_HeroQuickAction` draws all four)
class _QuickChip extends StatelessWidget {
  const _QuickChip({
    // ignore: unused_element_parameter
    super.key,
    required this.label,
    required this.icon,
    required this.p,
    required this.onTap,
    // ignore: unused_element_parameter
    this.enabled = true,
    // ignore: unused_element_parameter
    this.on,
  });

  final String label;
  final IconData icon;
  final V2Palette p;
  final VoidCallback onTap;
  final bool enabled;
  final bool? on;

  @override
  Widget build(BuildContext context) {
    final lit = on == true;
    final chip = Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: lit ? p.ink1 : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: lit ? p.ink1 : p.ink1.withValues(alpha: 0.22)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: lit ? Colors.white : p.ink2),
        const SizedBox(width: 7),
        Flexible(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: lit ? Colors.white : p.ink1)),
        ),
      ]),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      toggled: on,
      label: label,
      child: PvPress(
        enabled: enabled,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: enabled ? chip : Opacity(opacity: 0.42, child: chip),
        ),
      ),
    );
  }
}

/// The one-tap row's place while an IVF-shaped round runs (§3e): her blood
/// test by its DATE, or the way to her round when none is dated yet.
class _BloodTestLine extends StatelessWidget {
  const _BloodTestLine({required this.day, required this.p});

  final DateTime day;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final on = ttcHomeBloodTestOn(day);
    final kind = TtcTreatmentStore.instance.cycle.kind;
    final label = on == null ? kTtcSeeRound : ttcBloodTestLine(on, kind);
    return Semantics(
      button: true,
      label: label,
      // excludeSemantics drops the child's tap action, so the node
      // carries it (accessibility sweep, TTC launch walk, 2026-09-27).
      onTap: () => _openSurface(context, 'ttc_treatment'),
      excludeSemantics: true,
      child: Material(
        key: const ValueKey('ttc_home_blood_test_line'),
        color: p.surface,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => _openSurface(context, 'ttc_treatment'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(children: [
              Icon(Icons.biotech_outlined, size: 18, color: p.ink1),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink1)),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The day strip - scrollable, tappable, and marked with what she logged.
///
/// ⚠️ IT READS `ttcFactsFor`, THE CALENDAR'S OWN ENGINE. Every marker here -
/// period start, fertile day, ovulation, expected period - is the same function
/// the month grid calls, so a day cannot be coral in the header and plain in
/// the calendar. Re-deriving them from `CycleStore` would have been four lines
/// shorter and the two would have drifted the first time either changed.
///
/// ---------------------------------------------------------------------------
///  ⚠️ THE THREE THINGS THIS DID NOT DO, AND WHY EACH MATTERED
/// ---------------------------------------------------------------------------
///
/// It rendered seven fixed days with today at index 3, the whole row wrapped in
/// one `GestureDetector` that opened the calendar, and a 4px dot for "something
/// logged". Every part of that was a near-miss:
///
///  1. **You could not go back.** Three days of history, and no way to reach a
///     fourth without leaving the screen. *"I'm not able to go back at a
///     date."* Now it is a `ListView` over ~26 weeks of past.
///
///  2. **The days were not tappable - the ROW was.** Tapping Tuesday did not
///     select Tuesday, it opened the calendar. That is the worst kind of dead
///     control: it responds, so it feels wired, and it takes you somewhere
///     else. The calendar keeps its own button in the row above.
///
///  3. **A 4px dot cannot say WHAT.** *"How? Using emojis and stuff."* The dot
///     answered "did you log?" when the question is "what did I log?" - and it
///     is the same colour for a day of cramps and a day of joy.
///
/// ⚠️ SIX DAYS OF FUTURE, NOT ZERO AND NOT A MONTH. Enough to see the fertile
/// tint arriving, which is the single most useful forward-looking thing this
/// strip does. Further out and it becomes a planner for days that have not
/// happened, on a screen whose subject is how she feels.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip(
      {required this.p,
      required this.selected,
      required this.today,
      required this.onSelect});

  final V2Palette p;
  final DateTime selected;

  /// The screen's single idea of today. See `_TtcHomeV3State._today`.
  final DateTime today;

  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) => PvDayStrip(
        p: p,
        selected: selected,
        today: today,
        onSelect: onSelect,
        // ⚠️ INK, NOT CORAL (2026-09-28): the cycle palette gives rose to the
        // period alone (`TtcCycleColours`); a rose "today" circle read as a
        // period day. Today and selected are ink on every cycle view.
        // Kept for revert: accent: ttcCoral,
        accent: TtcCycleColours.today,
        keyPrefix: 'ttc_day_',
        // ---- WHAT SHE LOGGED ------------------------------------------------
        //
        // ⚠️ THE ASYMMETRY IS THE FEATURE, and it was asked for twice: *"if
        // I'm not on a date but a symptom was logged on that particular date,
        // it shows a heart below that date. The moment I'm on that date it
        // shows the symptom icons."* Thirty days of symptom icons at 15pt is
        // noise nobody can parse; thirty hearts is a scannable answer to
        // "when have I been logging?" — and the detail arrives on the one day
        // you asked about.
        markFor: (date, selected) {
          final marks = ttcDayMarkers(date);
          if (marks.shown.isEmpty) return null;
          return selected
              ? _MarkRow(marks: marks, p: p)
              // The heart she asked for, in the palette's "logged" ink
              // (2026-09-28). Kept for revert: ttcCoral at 0.75.
              : Icon(Icons.favorite_rounded,
                  size: 10,
                  color: TtcCycleColours.logged.withValues(alpha: 0.75));
        },
      );
}

// =============================================================================
//  KEPT FOR REVERT — the strip as it was before it became `PvDayStrip`
//  (lib/screens/v2/pv_day_strip.dart, 2026-09-21). The mechanism moved
//  verbatim; only the marks slot and the two tones are new. If the shared
//  widget ever has to be unwound, this is what TTC goes back to.
// =============================================================================
// class _WeekStrip extends StatefulWidget {
//   const _WeekStrip(
//       {required this.p,
//       required this.selected,
//       required this.today,
//       required this.onSelect});
//
//   final V2Palette p;
//   final DateTime selected;
//
//   /// The screen's single idea of today. See `_TtcHomeV3State._today`.
//   final DateTime today;
//
//   final ValueChanged<DateTime> onSelect;
//
//   @override
//   State<_WeekStrip> createState() => _WeekStripState();
// }
//
// class _WeekStripState extends State<_WeekStrip> {
//   static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
//
//   /// ~26 weeks back. Long enough that nobody hits the end while browsing, short
//   /// enough that the list is 187 cheap items rather than an infinite builder
//   /// whose scroll offset has to be computed from an epoch.
//   static const _daysBack = 180;
//   static const _daysForward = 6;
//   static const _slot = 46.0;
//
//   final _sc = ScrollController();
//   bool _centred = false;
//
//   /// ⚠️ NOT `late final` ANY MORE. It was, and it was set from
//   /// `DateTime.now()` in `initState` — so the 187-day window was anchored to
//   /// whichever day the screen was first opened on and stayed there. After
//   /// midnight the strip's last cell was five days ahead instead of six, and
//   /// its idea of "today" was a day behind the numbers it was drawing.
//   late DateTime _first = widget.today.subtract(const Duration(days: _daysBack));
//
//   @override
//   void didUpdateWidget(_WeekStrip old) {
//     super.didUpdateWidget(old);
//     if (old.today != widget.today) {
//       // Re-anchor, and let it re-centre once: on the morning after, landing on
//       // today is what she wants, and it is also the only moment where moving
//       // the scroll position under her is not rude.
//       setState(() {
//         _first = widget.today.subtract(const Duration(days: _daysBack));
//         _centred = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _sc.dispose();
//     super.dispose();
//   }
//
//   /// Put the selected day on screen after the first layout.
//   ///
//   /// ⚠️ ONCE, NOT ON EVERY BUILD. `_centred` is the guard, and it is load
//   /// bearing: re-centring on every build would yank the strip back under her
//   /// thumb the instant she scrolled, because a scroll rebuilds nothing but a
//   /// tap rebuilds everything. It is also why this cannot be
//   /// `initialScrollOffset` - the viewport width is not known until layout, and
//   /// centring needs it.
//   void _centre(double viewport) {
//     if (_centred || !_sc.hasClients) return;
//     _centred = true;
//     final index = widget.selected.difference(_first).inDays;
//     final target = (index * _slot) - (viewport / 2) + (_slot / 2);
//     _sc.jumpTo(target.clamp(0.0, _sc.position.maxScrollExtent));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // ⚠️ THE LIVE CLOCK, NOT `widget.today`, FOR THE TODAY MARKER.
//     //
//     // The parent keeps a `_today` and refreshes it on resume, which is right
//     // for deciding what the page is ABOUT. But the previous version of this
//     // line read that cached value, so if it ever failed to refresh, the marker
//     // for today was wrong too — and a strip that is confidently wrong about
//     // which day it is, is worse than one that is merely stale.
//     //
//     // The window anchor still comes from the parent (`_first`), so the list
//     // does not reshuffle under a scroll. Only the "which of these is today"
//     // question is answered from the clock, every build, unconditionally.
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     const count = _daysBack + _daysForward + 1;
//
//     return LayoutBuilder(builder: (context, box) {
//       WidgetsBinding.instance
//           .addPostFrameCallback((_) => _centre(box.maxWidth));
//
//       final selIndex =
//           widget.selected.difference(_first).inDays.toDouble();
//
//       return SizedBox(
//         height: 84,
//         child: Stack(children: [
//           // ⚠️ THE CORAL DISC IS ONE WIDGET THAT MOVES, NOT A PROPERTY OF A
//           // CELL — 2026-09-05. Asked for directly: *"I don't need that purple
//           // outline… instead take that pink background. Have a good motion. It
//           // seems sliding through to that particular date."*
//           //
//           // Drawn per-cell it can only ever appear and disappear: the old cell
//           // repaints without it and the new one repaints with it, which is a
//           // cut, not a move. Lifting it out of the list and translating it is
//           // what makes the same pixels read as one object travelling to the day
//           // you tapped.
//           //
//           // ⚠️ IT SITS *UNDER* THE LIST, WHICH IS WHY THE NUMBER STILL SHOWS.
//           // The cells paint no background of their own, so the disc shows
//           // through and each date's own digits draw on top of it. Painted over
//           // the list it would cover the number it is meant to highlight.
//           //
//           // ⚠️ AND IT TRACKS TWO THINGS AT ONCE. The `AnimatedBuilder` on the
//           // scroll controller keeps it glued to its date while the strip is
//           // dragged (instantly, no easing — a marker that lags behind a scroll
//           // looks broken); the `TweenAnimationBuilder` eases only the change of
//           // SELECTION. One of those must be immediate and the other must not,
//           // which is why they are two separate animations and not one.
//           Positioned(
//             left: 0,
//             top: 20,
//             child: AnimatedBuilder(
//               animation: _sc,
//               builder: (context, _) => TweenAnimationBuilder<double>(
//                 tween: Tween<double>(end: selIndex),
//                 duration: const Duration(milliseconds: 260),
//                 curve: Curves.easeOutCubic,
//                 builder: (context, v, child) => Transform.translate(
//                   offset: Offset(
//                       v * _slot -
//                           (_sc.hasClients ? _sc.offset : 0) +
//                           (_slot - 34) / 2,
//                       0),
//                   child: child,
//                 ),
//                 child: Container(
//                   width: 34,
//                   height: 34,
//                   decoration: const BoxDecoration(
//                       color: ttcCoral, shape: BoxShape.circle),
//                 ),
//               ),
//             ),
//           ),
//           ListView.builder(
//           controller: _sc,
//           scrollDirection: Axis.horizontal,
//           itemCount: count,
//           padding: EdgeInsets.zero,
//           itemBuilder: (context, i) {
//             final date = DateTime(_first.year, _first.month, _first.day + i);
//             return _WeekDay(
//               // ⚠️ A KEY PER DATE, SO A TEST CAN TAP ONE. Finding a day by its
//               // number does not work here: the list spans six months, so `29`
//               // is ambiguous the moment two months' worth is built, and the
//               // cards below can print a bare number too — a cycle day of 8 and
//               // the 8th of the month are the same string on one screen.
//               key: ValueKey('ttc_day_${date.year}-${date.month}-${date.day}'),
//               date: date,
//               isToday: date == today,
//               isSelected: date == widget.selected,
//               isFuture: date.isAfter(today),
//               letter: _dayLetters[(date.weekday - 1) % 7],
//               p: widget.p,
//               width: _slot,
//               onTap: () => widget.onSelect(date),
//             );
//           },
//         ),
//         ]),
//       );
//     });
//   }
// }
//
// class _WeekDay extends StatelessWidget {
//   const _WeekDay({
//     super.key,
//     required this.date,
//     required this.isToday,
//     required this.isSelected,
//     required this.isFuture,
//     required this.letter,
//     required this.p,
//     required this.width,
//     required this.onTap,
//   });
//
//   final DateTime date;
//   final bool isToday;
//   final bool isSelected;
//   final bool isFuture;
//   final String letter;
//   final V2Palette p;
//   final double width;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     // =========================================================================
//     //  ⚠️ THE STRIP DRAWS ONE THING: WHICH DAY IS TODAY.
//     // -------------------------------------------------------------------------
//     //  Everything the cycle knows — period starts, fertile days, an expected
//     //  period — is COMMENTED OUT BELOW, kept for revert, and it comes back when
//     //  the distinction is designed properly against the reference. Asked for
//     //  directly: *"in future I will be letting you mark the distinction like
//     //  the competitor app does. But you don't have to do it right now."*
//     //
//     //  ⚠️ AND THE REASON IT HAD TO COME OFF NOW IS WORTH KEEPING. Three rounds
//     //  were lost to "the pink circle is stuck on the 30th", and every round the
//     //  answer was the same: there was more than one pink circle. First a filled
//     //  coral disc for a logged period start sitting beside the today marker;
//     //  then, after that became a ring, a coral RING on the 30th sitting beside
//     //  today's disc. Each time the extra mark was correct, data-driven, and
//     //  completely indistinguishable from "the today marker has not moved".
//     //
//     //  **A second marker in the same colour as the primary one is not extra
//     //  information, it is a bug the reader can see and you cannot.** The strip
//     //  is a date picker first. It shows the date.
//     // =========================================================================
//
//     // final TtcDayFacts facts = ttcFactsFor(date);
//     //
//     // final isFertile =
//     //     facts.fertility != null && facts.fertility != FertilityLevel.low;
//     //
//     // if (facts.isPeriodStart) {
//     //   ring = ttcCoral;
//     // } else if (isFertile) {
//     //   fill = ttcFertilityTint(facts.fertility!);
//     // } else if (facts.isExpectedPeriod) {
//     //   ring = ttcCoral.withValues(alpha: 0.55);
//     // }
//
//     // ⚠️ NO `fill` AND NO `selectedRing` — 2026-09-05. THE CELL DRAWS NO
//     // BACKGROUND AT ALL ANY MORE.
//     //
//     // It used to paint coral on today and a purple ring on the selection. The
//     // ring is gone because it was asked to go — *"I don't need that purple
//     // outline… instead take that pink background"* — and the coral is gone from
//     // here because it now lives in `_WeekStrip` as one disc that slides. See
//     // the note there for why a per-cell fill can only cut and never move.
//     //
//     // ⚠️ WHAT THIS COSTS, AND HOW IT IS PAID. The old arrangement had one
//     // permanent, unmissable mark on today. With the disc following the
//     // selection, today has no fill whenever you are looking at another day —
//     // and *"keep the today marked as where it is so that I know what day is
//     // today"* is the requirement. It is paid twice: the word TODAY sits above
//     // it in coral instead of a weekday letter, and its digits stay coral while
//     // every other unselected day is ink. Two marks, neither of them a disc, so
//     // neither can be confused with the cursor.
//     final onDisc = isSelected;
//
//     final marks = ttcDayMarkers(date);
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: SizedBox(
//         width: width,
//         child: Column(children: [
//           // ⚠️ THE WORD, NOT JUST THE COLOUR. A weekday letter is the same
//           // glyph on every seventh cell, so "T" over today carries no
//           // information at all. Replacing it removes the last way to misread
//           // which cell is the current one — and it costs nothing, because the
//           // letter it replaces was the least useful mark on the strip.
//           // ⚠️ A FIXED 14 SO THE DISC KNOWS WHERE THE CIRCLE STARTS. The
//           // sliding marker is positioned from outside this cell, so its `top`
//           // is arithmetic over this row's height plus the gap below it. Left to
//           // the font, that height changes with the text scale and the disc
//           // drifts off the number on exactly the devices whose owners cannot
//           // read it anyway.
//           SizedBox(
//             height: 14,
//             child: Text(isToday ? 'TODAY' : letter,
//               maxLines: 1,
//               overflow: TextOverflow.visible,
//               style: pvManrope(
//                   fontSize: isToday ? 8 : 10.5,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: isToday ? 0.4 : 0.6,
//                   // A future day is dimmer, so the strip has a visible "now"
//                   // edge without a divider drawn between two dates.
//                   color: isToday
//                       ? ttcCoral
//                       : isFuture
//                           ? p.ink3.withValues(alpha: 0.5)
//                           : p.ink3)),
//           ),
//           const SizedBox(height: 6),
//           SizedBox(
//             width: 34,
//             height: 34,
//             child: Center(
//               child: Text('${date.day}',
//                   style: pvManrope(
//                       fontSize: 13.5,
//                       fontWeight: isSelected || isToday
//                           ? FontWeight.w900
//                           : FontWeight.w700,
//                       // White on the disc; coral on today when the disc is
//                       // elsewhere; dimmer ahead of today; ordinary ink behind.
//                       color: onDisc
//                           ? Colors.white
//                           : isToday
//                               ? ttcCoral
//                               : isFuture
//                                   ? p.ink3
//                                   : p.ink1)),
//             ),
//           ),
//           const SizedBox(height: 4),
//
//           // ---- WHAT SHE LOGGED --------------------------------------------
//           //
//           // ⚠️ THE ASYMMETRY IS THE FEATURE, and it was asked for twice:
//           // *"if I'm not on a date but a symptom was logged on that particular
//           // date, it shows a heart below that date. The moment I'm on that date
//           // it shows the symptom icons."*
//           //
//           // Which is a genuinely good interaction rather than a decorative one.
//           // Thirty days of symptom icons at 15pt is noise nobody can parse;
//           // thirty hearts is a scannable answer to "when have I been logging?"
//           // - and the detail arrives on the one day you asked about.
//           SizedBox(
//             height: 18,
//             child: marks.shown.isEmpty
//                 ? null
//                 : isSelected
//                     ? _MarkRow(marks: marks, p: p)
//                     : Icon(Icons.favorite_rounded,
//                         size: 10, color: ttcCoral.withValues(alpha: 0.75)),
//           ),
//         ]),
//       ),
//     );
//   }
// }

/// The logged symptoms under the selected date: two of them, then a count.
class _MarkRow extends StatelessWidget {
  const _MarkRow({required this.marks, required this.p});

  final ({List<TtcSymptom> shown, int more}) marks;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    // ⚠️ TWO BUBBLES *OR* ONE BUBBLE AND A COUNT. Never two and a count: at
    // a 46pt slot width that is 16 + 2 + 16 + 2 + 14 = 50, which overflows.
    // Four pixels of overflow from exactly this arithmetic - a fixed number of
    // fixed-width children in a fixed-width box - is a mistake already made
    // once on the logging screen this strip feeds.
    final showTwo = marks.more == 0 && marks.shown.length >= 2;
    final bubbles = marks.shown.take(showTwo ? 2 : 1).toList();
    final overflow = marks.more + (marks.shown.length - bubbles.length);

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (final s in bubbles) ...[
        Builder(builder: (_) {
          final tint = v2BlockTint(s.hue % 360, p);
          final deep = HSLColor.fromColor(tint)
              .withSaturation(0.5)
              .withLightness(0.38)
              .toColor();
          return Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: tint, shape: BoxShape.circle),
            // ⚠️ 18, NOT 16, AND THE TWO EXTRA POINTS ARE THE WHOLE REASON THE
            // DRAWN FACE WORKS HERE. An emoji is a full-colour glyph and stays
            // legible at almost any size; two hairlines and two dots do not.
            // At 16 the mark inside was 9pt and the mouth curve closed up into
            // a smudge. 18 gives it 12, which is the floor — see the stroke
            // note in `ttc_mood_face.dart`.
            child: TtcSymptomMark(symptom: s, size: 12, ink: deep),
          );
        }),
        const SizedBox(width: 2),
      ],
      if (overflow > 0)
        Text('+$overflow',
            style: pvManrope(
                fontSize: 9, fontWeight: FontWeight.w800, color: p.ink2)),
    ]);
  }
}

/// The one big line: when her days are, or why we will not say.
class _WindowLine extends StatelessWidget {
  const _WindowLine(
      {required this.today,
      required this.p,
      required this.hinglish,
      required this.selected,
      required this.onTap,
      this.late});

  final TtcToday today;
  final V2Palette p;
  final bool hinglish;

  /// The day the strip is standing on. Not always today.
  final DateTime selected;

  /// Set when today is late on her own cycle and a home test can answer
  /// (`ttcHomeLateAdvice`). Turns the late state into "Time to test".
  final TtcTestAdvice? late;

  final VoidCallback onTap;

  static const _short = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String _fmt(DateTime d) => '${d.day} ${_short[d.month - 1]}';

  /// ⚠️ THE TALLEST THE BLOCK EVER GETS, AND IT IS FIXED — 2026-09-05.
  ///
  /// Reported: *"the homescreen hero is fixed in size i mean height wise"*. It
  /// was not, and the effect is worse than it sounds. The headline runs to one
  /// line on most days and two on others, so the strip, the two buttons and
  /// everything below them sat at a different height depending on where in her
  /// cycle she was — the page rearranged itself between days, and between the
  /// day she selected on the strip and today.
  ///
  /// Fixing the height costs a little whitespace on short days and buys a page
  /// whose furniture is in the same place every morning. That is the right
  /// trade for a screen somebody opens daily for a year.
  ///
  /// ⚠️ MEASURED AGAINST THE WORST CASE, NOT A TYPICAL ONE. Two lines of
  /// 30pt Fraunces at 1.12 (67), the gap (6), two lines of 13.5pt Manrope at
  /// 1.45 (39), the gap (8) and the cycle-day row (18) — 138, rounded up.
  /// `ttc_home_hero_test.dart` renders every state and fails on an overflow, so
  /// a longer string cannot quietly start clipping.
  /// ⚠️ 140, AND THE CONTENT HUGS THE BOTTOM OF IT — CORRECTED 2026-09-05.
  ///
  /// The first version was 146 with the content top-aligned and a `Spacer`
  /// pushing the cycle-day footer down. On a state with a one-line headline and
  /// no footer that left most of the box empty, directly above the two buttons,
  /// and it was reported as exactly that: *"a lot of spaces there between that
  /// heading and the entry date row."*
  ///
  /// ⚠️ THE FIX IS WHICH END THE SLACK SITS AT, NOT HOW MUCH THERE IS. A fixed
  /// box always has slack on short days — that is the price of the page not
  /// jumping. Top-aligned, the slack falls between the text and the buttons,
  /// where it reads as a hole. Bottom-aligned, it falls between the day strip
  /// and the text, where the strip already has air and it reads as breathing
  /// room. Same pixels, and only one of them looks like a mistake.
  /// ⚠️ 176 SINCE THE LEAD-IN GREW — 2026-09-05, AND THE NUMBER IS MEASURED
  /// RATHER THAN REASONED. I estimated 160 from line heights and the render
  /// test failed with "A RenderFlex overflowed by 14 pixels" at 360pt — the
  /// narrow width the insight tests deliberately use, where a lead-in wraps a
  /// word earlier than arithmetic on font sizes suggests.
  ///
  /// Third time this session that a height computed from type metrics was
  /// wrong at phone width, and the same lesson each time: the render test is
  /// the measurement, the arithmetic is the guess. The block got taller because
  /// its contents did, which is the opposite of the earlier problem: the height
  /// was reserving room that nothing filled. Now a lead at 23 and an answer at
  /// 44 occupy most of it on every state.
  ///
  /// Worst case that actually occurs is a two-line lead with a one-line answer
  /// ("Past your usual length by" / "3 days") or a one-line lead with a
  /// two-line answer ("Your fertile days are" / "today and 2 more days") —
  /// about 150 either way. The pairing that would overflow, a two-line lead AND
  /// a two-line answer, cannot happen: the long leads all take short answers.
  ///
  /// The note below is the history, kept because the reasoning still applies.
  ///
  /// ⚠️ 136, AND CENTRED — THIRD ATTEMPT, 2026-09-05. The first was 146
  /// top-aligned, which put the slack between the text and the buttons and was
  /// reported as a hole. The second was 140 bottom-aligned, then 172 when the
  /// type grew — which moved the same hole ABOVE the text, between the strip
  /// and the headline, and was reported again.
  ///
  /// The mistake both times was reserving room for the worst case and then
  /// arguing about which end the leftover sits at. 172 fitted a two-line big
  /// line plus a lead plus two lines of sub — a combination that never occurs.
  /// The real worst case is a two-line big line with a one-line sub and no
  /// lead: 86 + 8 + 18 = 112, or a one-line big with a lead and a two-line sub:
  /// 20 + 2 + 43 + 8 + 36 = 109. 136 covers both with a little air.
  ///
  /// Centred, so the ~25 of slack on a short day splits either side and is
  /// invisible instead of pooling at one end. Measure the worst case that
  /// HAPPENS, not the worst case the layout can express.
  /// ⚠️ 128 SINCE THE LAUNCH WALK (2026-09-27): at 150 the usual one-line
  /// answer left about sixty points of empty band between the date range and
  /// the four quick buttons. The FittedBox below scales the rare long pairing
  /// down rather than clipping it, so tightening costs nothing there.
  /// Kept for revert: static const double blockHeight = 150;
  static const double blockHeight = 128;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();

    // ⚠️ THE DECISION IS NOT MADE HERE ANY MORE. `ttcHomeHeroLine()` returns
    // a state and a number; this only chooses words. The refusals, the truth
    // hierarchy and the whole cycle loop live in `ttc_home_hero.dart`, where
    // they can be walked day by day in a test without pumping a widget.
    final line = ttcHomeHeroLine(on: selected);

    // ⚠️ THREE PARTS, NOT TWO — 2026-09-05. A small lead-in, ONE huge phrase,
    // and a quiet explainer. See `ttc_strings.dart` for why the split is the
    // whole difference between this hero and a bland one: the answer she opened
    // the app for now arrives in type she can read across the room, instead of
    // being set in the same size as the sentence explaining it.
    //
    // ⚠️ THE BIG SLOT TAKES THE ANSWER, NEVER THE SUBJECT. "end today", "in 3
    // days", "today and 2 more days". If it ever reads as a topic, the split
    // has been used backwards.
    final (lead, big, sub) = switch (line.state) {
      TtcHeroState.startHere =>
        ('', t.headerStartHere, t.headerStartHereBody),

      // ⚠️ THE SUB-LINE IS AN EXIT, NOT AN EXPLANATION. This state is a trap:
      // one tap on a path label sets it, `setPath` clears her two answers so
      // the pathway default applies, and the only way back is two questions on
      // the treatment screen that nothing on this page points at. It was hit
      // repeatedly during testing and read, correctly, as the app being stuck.
      //
      // The rule underneath is right and stays — we do not publish a window
      // into a cycle a clinic may be running. What was wrong is that the
      // sentence delivering that refusal was a dead end. It is now the door,
      // and the whole block already opens the treatment screen.
      // ⚠️ SINCE 2026-09-26 A LABEL CANNOT PUT HER HERE. A cycle is
      // clinic-held only when her clinic's dates for it are in the tracker
      // (`TtcStore.ownership`), and the dates lead the hero whenever one is
      // still ahead, so this state means they have all passed. Kept for
      // revert: the sub-line was `t.headerNotOnTreatment`.
      TtcHeroState.clinicHolds => (
          t.leadYouAreOn,
          t.headerCycleDayBig(line.days),
          t.headerClinicDatesPassed,
        ),
      TtcHeroState.noEstimate => line.days > 0
          ? (t.leadYouAreOn, t.headerCycleDayBig(line.days),
              t.headerNoEstimateShort)
          : ('', t.headerNoEstimate, t.headerNoEstimateBody),

      // ---- the window ----------------------------------------------------
      TtcHeroState.windowOpensIn => (
          t.leadFertileDays + t.headerOpenVerb,
          t.bigInDays(line.days),
          _dates(),
        ),
      TtcHeroState.windowOpen => (
          t.leadFertileDays + t.headerAreVerb,
          t.bigTodayAndMore(line.days),
          _dates(),
        ),
      TtcHeroState.windowLastDay => (
          t.leadFertileDays,
          t.bigEndToday,
          t.headerWindowLastDayBody,
        ),

      // ---- the wait ------------------------------------------------------
      TtcHeroState.waiting => (
          t.leadPeriodMayStart,
          t.bigInDays(line.days),
          t.headerWaitingBody,
        ),
      TtcHeroState.periodDue => (
          t.leadPeriodMayStart,
          t.bigToday,
          t.headerPeriodDueBody,
        ),
      TtcHeroState.periodLate => (
          t.leadPastUsual,
          t.bigDays(line.days),
          t.headerPeriodLateBody,
        ),
      TtcHeroState.periodExpectedBy => (
          '',
          t.headerPeriodExpectedBy,
          t.headerPeriodExpectedByBody,
        ),

      // ---- her clinic's calendar -----------------------------------------
      TtcHeroState.treatmentToday => (
          line.step!.label(hinglish),
          t.bigToday,
          t.headerStepTodayBody,
        ),
      TtcHeroState.treatmentSoon => (
          line.step!.label(hinglish),
          t.bigInDays(line.days),
          t.headerStepInBody,
        ),
      TtcHeroState.treatmentBeta => (
          t.leadBetaOn,
          _fmt(line.date!),
          t.headerBetaOnBody,
        ),

      // ---- a round's step (2026-09-26, §3a) -----------------------------
      TtcHeroState.treatmentGettingReady ||
      TtcHeroState.treatmentStimulation ||
      TtcHeroState.treatmentTrigger ||
      TtcHeroState.treatmentProcedure ||
      TtcHeroState.treatmentEmbryoDays ||
      TtcHeroState.treatmentTransfer ||
      TtcHeroState.treatmentWait ||
      TtcHeroState.treatmentTestDay ||
      TtcHeroState.treatmentResult ||
      TtcHeroState.treatmentBetweenRounds =>
        ttcRoundHeroCopy(line, selected),

      // ⚠️ `days == 0` MEANS EARLIER THAN ANYTHING SHE HAS LOGGED, which is
      // the one case where there genuinely is no day to name.
      //
      // ⚠️ AND AN EARLIER CYCLE NAMES ITS FERTILE DAYS, LOOKING BACK
      // (2026-09-26): "Day N" with "your fertile days that cycle were around
      // X to Y". Kept for revert: the sub-line was
      // `t.headerPastCycleBodyOn(_fmt(line.date!))` and the no-cycle body
      // `t.headerPastCycleBody`.
      TtcHeroState.pastCycle => line.days > 0
          ? (
              t.leadEarlierCycle,
              t.headerPastCycleDay(line.days),
              line.windowFrom != null && line.windowTo != null
                  ? t.headerPastCycleWindow(
                      _fmt(line.windowFrom!), _fmt(line.windowTo!))
                  : t.headerPastCycleNoWindow(_fmt(line.date!)),
            )
          : ('', t.headerPastCycle, t.headerBeforeFirstPeriodBody),
    };

    // ⚠️ THE TAP FOLLOWS THE SENTENCE. The hero has always opened the cycle
    // companion, which is the right destination for a window and the wrong one
    // for "Egg retrieval in 3 days" — that belongs to the treatment screen,
    // which is where the dates live and where they are edited. A headline that
    // opens somewhere unrelated to what it says is a door in the wrong wall.
    const treatment = {
      TtcHeroState.clinicHolds,
      TtcHeroState.treatmentToday,
      TtcHeroState.treatmentSoon,
      TtcHeroState.treatmentBeta,
      ...kTtcRoundHeroStates,
    };

    // "Waiting to hear" opens the result, since that is what it asks for.
    if (line.state == TtcHeroState.treatmentTestDay && line.days > 0) {
      return _block(lead, big, sub,
          onTapOverride: () => openTtcTreatmentResult(context));
    }
    // S1: a planned round's first date in the small line (§3a).
    if (line.upcomingOn != null) {
      return _block(lead, big, ttcRoundUpcomingLine(line),
          openTreatment: true);
    }

    // ⚠️ "TIME TO TEST" WHEN A TEST CAN ANSWER (2026-09-26, gap analysis,
    // "Behind: Home & daily", P1). The late state said how many days past her
    // usual length and stopped there, on the one day she most wants to know
    // what to do. Now, on her own cycle with a steady history (the same rule
    // the "late" message uses, so the two cannot name different dates), the
    // big line says what a test can do today.
    //
    // It is not a countdown to a test and it is not a chance: it appears only
    // once a test is already reliable, and it says so. A clinic cycle never
    // reaches here (`ttcHomeLateAdvice` refuses first), and neither does a
    // future day or an irregular history; those keep the words above.
    final advice = late;
    if (advice != null && line.state == TtcHeroState.periodLate) {
      return _block('', kTtcTimeToTest, ttcTimeToTestBody(advice.daysLate),
          onTapOverride: () => openTtcSurface(context, 'ttc_chat/should_test'));
    }

    return _block(lead, big, sub,
        openTreatment: treatment.contains(line.state));
  }

  // Kept for revert: `_openBody` joined the count and the dates into one
  // sentence for the body slot. The three-part hero puts the count in the BIG
  // slot and the dates in the sub-line, so the two no longer share a string.
  //
  // String _openBody(int days) { ... }

  /// The window's own dates, and it still says "expected" when projected.
  ///
  /// ⚠️ `ignoreOwnership: true`, LIKE THE HERO ABOVE IT — AND FORGETTING IT
  /// HERE PRODUCED A VISIBLE BUG ON THE DEVICE. The headline read "Your fertile
  /// days open / in 8 days" while this returned '' — so the sub-line was blank
  /// and the ⓘ sat alone at the right of an empty row.
  ///
  /// Two calls to the same function, one bypassing the gate and one not, is a
  /// mismatch nothing catches: both are valid Dart, both compile, and the only
  /// symptom is a missing line under a headline that renders perfectly.
  ///
  /// ⚠️ THE SELECTED DAY'S OWN WINDOW SINCE 2026-09-26 (consistency pass).
  /// `ttcFertileWindowNow` answers for TODAY and rolls forward once today's
  /// window has closed, so with today in the waiting days and the strip back
  /// on a day before the window, the big line counted to THIS cycle's window
  /// ("in 2 days") while this line printed NEXT cycle's dates. The resolver
  /// gives the window of the cycle the selected day is in, which is the only
  /// window the two states that print dates ever describe. Kept for revert:
  ///   final w = ttcFertileWindowNow(ignoreOwnership: true);
  ///   if (w == null) return '';
  ///   return w.cyclesAhead > 0
  ///       ? t.headerWindowProjected(_fmt(w.opensOn), _fmt(w.closesOn))
  ///       : t.headerWindowDates(_fmt(w.opensOn), _fmt(w.closesOn));
  String _dates() {
    final t = TtcS.current();
    final ctx = ttcDayContext(selected);
    final opens = ctx.windowOpensOn;
    final closes = ctx.windowClosesOn;
    if (opens == null || closes == null) return '';
    return t.headerWindowDates(_fmt(opens), _fmt(closes));
  }

  Widget _block(String lead, String big, String sub,
      {bool openTreatment = false, VoidCallback? onTapOverride}) {
    return Builder(builder: (context) => GestureDetector(
      onTap: onTapOverride ??
          (openTreatment
              ? () => openTtcSurface(context, 'ttc_treatment')
              : onTap),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: blockHeight,
        child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: SizedBox(
        width: 330,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ---- the lead-in ---------------------------------------
              //
              // ⚠️ IT CAN BE EMPTY, AND THEN IT TAKES NO ROOM. Four states —
              // the invitation, the two refusals and a future day — are a
              // complete sentence on their own, and a lead-in invented to fill
              // the slot would be copy written to satisfy a layout.
              if (lead.isNotEmpty) ...[
                // ⚠️ AND THE WHOLE COLUMN SCALES DOWN RATHER THAN OVERFLOWING.
              // Three separate heights this session were computed from font
              // metrics and each was wrong at some width — the last one failed
              // the 360pt render test by 14 pixels. `BoxFit.scaleDown` only
              // acts when the content genuinely does not fit, so on a normal
              // phone nothing is scaled at all and on a narrow one the hero
              // shrinks a little instead of clipping. It ends a class of bug
              // rather than another instance of it.
              //
              // ⚠️ BIG TOO, AND IN THE SAME FACE AS THE ANSWER — 2026-09-05.
                // Asked for: *"can we have 'Your fertile days open' also
                // written in big text so tht the hero section looks filling."*
                //
                // It was 14.5pt Manrope against a 40pt Fraunces answer — a
                // caption above a headline, two different voices, and a hero
                // that was mostly empty because only one of its three lines had
                // any weight. At 23pt Fraunces the two halves read as ONE
                // sentence that happens to grow at the important word, which is
                // what the reference does and what makes its hero feel full
                // without being taller.
                //
                // ⚠️ LIGHTER, NOT JUST SMALLER. w500 against the answer's w600,
                // and `ink2` against `ink1`. If the lead-in matched the answer
                // in weight as well as face, the size difference alone would
                // not be enough to say which half is the answer.
                Text(lead,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvFraunces(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                        height: 1.15,
                        letterSpacing: -0.5,
                        color: p.ink2)),
                const SizedBox(height: 2),
              ],

              // ---- the answer ----------------------------------------
              //
              // ⚠️ 40pt AGAINST THE OLD 30. This is the change, and everything
              // else here is arrangement around it. At 30 the answer was set in
              // the same weight as the page it sat on and had to be READ; at 40
              // it is seen before it is read, which is what a hero is for.
              //
              // Two lines, because "today and 2 more days" is the longest thing
              // it ever has to say and it must not shrink to fit.
              Text(big,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvFraunces(
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      height: 1.06,
                      letterSpacing: -1.6,
                      color: p.ink1)),
              const SizedBox(height: 8),

              // ---- the explainer, with the way in --------------------
              //
              // ⚠️ THE ⓘ REPLACED A SEPARATE "Cycle day 5" FOOTER ROW. That row
              // was the visible door to the cycle companion, so removing it
              // needed a replacement rather than a deletion — the wiring gate.
              // The whole block has always been tappable; the mark is what says
              // so. The cycle day itself did not go anywhere: it is the first
              // insight card, six lines down this same screen.
              // ⚠️ THE ⓘ FOLLOWS THE WORDS IT EXPLAINS (the user, launch walk,
              // 2026-09-27: "that i button on hero seems in odd position").
              // It sat at the far right of the block, level with a short date
              // line, so it floated alone at the screen's edge. Inline now,
              // right after the dates. Kept for revert: Row(Expanded(Text(sub)),
              // SizedBox(width: 8), Padding(top: 2, Icon(info, 15, ink3))).
              // ⚠️ A PILL WITH A CHEVRON, NOT AN ⓘ (the user, 2026-09-27:
              // "do we even need the i button… it looks out of form"). An ⓘ
              // promises an explanation; this opens her cycle. The dates sit
              // in a soft pill that ends in a chevron, the way a tappable
              // summary reads everywhere else in the app. Kept for revert: the
              // Row of Flexible(Text(sub)), SizedBox(6) and
              // Icon(info_outline_rounded, 17, p.action).
              Container(
                padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(sub,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 13,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              color: p.ink1)),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 18, color: p.ink2),
                  ],
                ),
              ),
            ]),
        ),
        ),
      ),
    ));
  }
}

/// Whether the hero carries the late day's "Should I test?" pill on [today]:
/// the hero says late for her own cycle and the late advice stands. The one
/// rule the header and the insight rail both read (H1).
bool ttcHomeShowsLatePill(DateTime today) =>
    ttcHomeHeroLine(on: today).state == TtcHeroState.periodLate &&
    ttcHomeLateAdvice() != null;

class _RoundButton extends StatelessWidget {
  const _RoundButton(
      {required this.icon,
      required this.p,
      required this.onTap,
      required this.semantic});

  final IconData icon;
  final V2Palette p;
  final VoidCallback onTap;
  final String semantic;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semantic,
        // H6: a 44pt target around the 38pt disc.
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.surface.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: p.line),
                ),
                child: Icon(icon, size: 18, color: p.ink2),
              ),
            ),
          ),
        ),
      );
}

// ignore: unused_element (kept for revert since 2026-09-27; `_HeroQuickAction` draws all four)
class _HeaderAction extends StatelessWidget {
  // `key` and `on` were for the one-tap Sex pill, which is `_QuickChip` since
  // the review pass (H4, H5). Kept for revert: `super.key,` and `this.on,`.
  const _HeaderAction({
    required this.label,
    required this.icon,
    required this.p,
    required this.onTap,
    // ignore: unused_element_parameter
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final V2Palette p;
  final VoidCallback onTap;

  /// For a toggle (the one-tap Sex button): whether it is recorded for the
  /// day. Null for an ordinary action. Shown by a filled icon and a tinted
  /// fill, never by dimming, because dimming already means "not this day".
  final bool? on = null;

  /// False on a day that has not happened yet.
  ///
  /// ⚠️ ONE OPACITY ON THE WHOLE CONTROL, NOT THREE DIMMED COLOURS. Fading the
  /// fill, the icon and the label separately means three values to keep in step
  /// and a result that never quite reads as one object going quiet. `Opacity`
  /// over the finished button is both simpler and more honest about what is
  /// being said: this entire thing is not available.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: on == true ? v2BlockTint(344, p) : p.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: p.action),
        const SizedBox(width: 7),
        Flexible(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: p.ink1)),
        ),
      ]),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      toggled: on,
      label: label,
      child: InkWell(
        // ⚠️ A NULL CALLBACK, NOT AN `onTap` THAT RETURNS EARLY. `InkWell` reads
        // null as "not tappable" and stops drawing a ripple, so the control
        // stops *feeling* pressable as well as looking it. A guard inside the
        // callback would still flash a ripple on every tap, which is the app
        // saying "yes" and then doing nothing.
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: enabled ? button : Opacity(opacity: 0.42, child: button),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  The hero
// -----------------------------------------------------------------------------

// ⚠️ SUPERSEDED BY `_CycleHeader`, KEPT FOR REVERT.
//
// The chapter hero: a spine chip, "Day 6 in this chapter", and the one
// forward-looking line. Every clinical argument in it still stands — no
// denominator, no countdown to an outcome, an invitation rather than a zero
// — and the header that replaced it obeys all three. What changed is which
// question the top of the page answers: "where am I in this chapter" became
// "where am I in this cycle, and when are my days".
//
// Uncomment this and re-point the `_CycleHeader(...)` call in `build` to put
// it back; nothing else moved.
// class _Hero extends StatelessWidget {
//   const _Hero(
//       {required this.today,
//       required this.p,
//       required this.hinglish,
//       required this.onSpine,
//       required this.onSaved,
//       required this.onProfile});
//
//   final TtcToday today;
//   final V2Palette p;
//   final bool hinglish;
//   final VoidCallback onSpine;
//   final VoidCallback onSaved;
//   final VoidCallback onProfile;
//
//   @override
//   Widget build(BuildContext context) {
//     final chapter = today.chapter;
//     final logged = today.noEstimate != TtcNoEstimate.noPeriodLogged;
//
//     return SizedBox(
//       height: 300,
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ⚠️ NO "OF 4". Parenting's eyebrow reads "PHASE 1 OF 20" because
//               // parenting's phases run once, in order, and end. TTC chapters
//               // come round again with every cycle, so a denominator would draw
//               // a finish line across something that loops.
//               //
//               // ink2 rather than ink3, for the reason written out in
//               // pp_home_v3.dart: a grey calibrated for a neutral ground loses
//               // contrast on a tinted one faster than it loses lightness.
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: V3HeroChrome(
//                   tone: V3HeroTone.onField,
//                   p: p,
//                   onSaved: onSaved,
//                   onProfile: onProfile,
//                 ),
//               ),
//               const Spacer(),
//               // ⚠️ THE EYEBROW IS THE DOOR TO THE JOURNEY MAP. Same move as the
//               // other two stages, and it lands hardest here: TTC's chapters
//               // RECUR, so "where am I in the whole thing" is the question this
//               // stage generates most often and had no answer to on V3.
//               //
//               // No denominator in the label — see the hero note. The chip says
//               // which chapter, never which of how many.
//               V3SpineChip(
//                 label: chapter.title(hinglish).toUpperCase(),
//                 tone: V3HeroTone.onField,
//                 p: p,
//                 onTap: onSpine,
//               ),
//               const SizedBox(height: 10),
//               if (logged) ...[
//                 Text(
//                     hinglish
//                         ? 'Din ${today.daysIntoChapter}'
//                         : 'Day ${today.daysIntoChapter}',
//                     style: pvFraunces(
//                         fontSize: 42,
//                         fontWeight: FontWeight.w600,
//                         height: 1.05,
//                         letterSpacing: -1.3,
//                         color: p.ink1)),
//                 const SizedBox(height: 2),
//                 Text(
//                     hinglish
//                         ? 'is chapter mein, ${today.chapterLength} mein se'
//                         : 'in this chapter, of about ${today.chapterLength}',
//                     style: pvManrope(
//                         fontSize: 13.5,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.3,
//                         color: p.ink2)),
//               ] else ...[
//                 // ⚠️ THE INVITATION, NOT A ZERO. "Day 0" is what the parenting
//                 // hero shipped with for a fortnight and it is worse here: a
//                 // number implies we are counting something, and before a period
//                 // is logged we are counting nothing. `noPeriodLogged` is a real
//                 // state with its own sentence.
//                 Text(hinglish ? 'Shuruaat' : 'Start here',
//                     style: pvFraunces(
//                         fontSize: 38,
//                         fontWeight: FontWeight.w600,
//                         height: 1.05,
//                         letterSpacing: -1.2,
//                         color: p.ink1)),
//                 const SizedBox(height: 2),
//                 Text(
//                     hinglish
//                         ? 'Apna last period log karein, phir yahan aapki rhythm dikhegi'
//                         : 'Log your last period, and your rhythm shows up here',
//                     style: pvManrope(
//                         fontSize: 13.5,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.3,
//                         height: 1.4,
//                         color: p.ink2)),
//               ],
//               const SizedBox(height: 14),
//               // The one forward-looking line, and it names a TRIGGER rather
//               // than a date. `nextUp` is the string the hero test guards.
//               Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Container(
//                   margin: const EdgeInsets.only(top: 6),
//                   width: 6,
//                   height: 6,
//                   decoration: BoxDecoration(
//                       color: p.ink2.withValues(alpha: 0.5),
//                       shape: BoxShape.circle),
//                 ),
//                 const SizedBox(width: 9),
//                 Expanded(
//                   child: Text(chapter.nextUp(hinglish),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: pvManrope(
//                           fontSize: 13.5, height: 1.45, color: p.ink2)),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// -----------------------------------------------------------------------------
//  Shared shapes — identical to parenting's, different content
// -----------------------------------------------------------------------------

class _Sheet extends StatelessWidget {
  const _Sheet({required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        // The sheet owns the bottom clearance. See the long note on parenting's
        // `_Sheet`: once the background belongs to the page, every piece of
        // padding in the scroll view is a window onto it.
        constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height * 0.72),
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...children,
          // Clearance for the floating nav AND the Ask FAB, inside the opaque
          // sheet. `ttcBottomInset` is what every other TTC screen reserves;
          // 150 is what the parenting sheet reserves. Whichever is larger.
          SizedBox(height: ttcBottomInset > 150 ? ttcBottomInset : 150),
        ]),
      );
}

class _Head extends StatelessWidget {
  const _Head(
      {required this.eyebrow,
      required this.title,
      required this.p,
      this.action,
      this.onAction});

  final String eyebrow;
  final String title;
  final V2Palette p;

  /// A short link at the right of the title ("See all"), in place of a
  /// full-width row under the section (2026-09-27).
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ⚠️ `p.action`, NOT `p.ink3` — the section eyebrow is PURPLE on every
        // other V3 screen, and this copy of `_Head` shipped grey.
        //
        // The mechanism is worth naming because it will happen again: the
        // shape was copied from pregnancy and parenting by hand, and one
        // colour token drifted in the copying. Nothing failed — grey is a
        // legal colour, the layout is identical, and no test looks at a
        // Color. It is only visible by putting the three screens side by side,
        // which is exactly what a copied widget makes nobody do.
        //
        // The real fix is a shared `_Head`; it is not shared today because the
        // three take different label types. Until then this comment is the
        // guard.
        //
        // ⚠️ AN EMPTY EYEBROW RENDERS NOTHING, rather than an empty line. The
        // doors section dropped its eyebrow when it moved up the page, and
        // without this guard a blank `Text` still reserved its line height and
        // its 5px gap — a gap nobody could account for by reading the call.
        if (eyebrow.isNotEmpty) ...[
          Text(eyebrow.toUpperCase(),
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: p.action)),
          const SizedBox(height: 5),
        ],
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Text(title,
                style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.5,
                    color: p.ink1)),
          ),
          if (action != null && onAction != null)
            Semantics(
              button: true,
              label: action,
              excludeSemantics: true,
              onTap: onAction,
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 2, 3),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(action!,
                        style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: p.action)),
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: p.action),
                  ]),
                ),
              ),
            ),
        ]),
      ]);
}

/// Title, subtitle, then a paragraph — for a section that has to explain itself
/// before it can be used.
///
/// ⚠️ THE ONLY SECTION ON THIS PAGE THAT EARNS THREE LEVELS. Every other head
/// is an eyebrow and a title, because every other section is self-evident from
/// the thing under it: a grid of doors, a rail of products, a journal. The
/// samskar is not. "Daily Preconception Samskar" over five tick-boxes is a
/// phrase most people meet for the first time here, and a section whose name
/// needs a sentence should be given the sentence rather than left to be
/// guessed at from the tasks.
// Superseded 2026-09-16: the Sanskar section takes `_Head` + a body line like
// every other section, now that its subtitle is gone. Kept for revert.
// ignore: unused_element
class _SectionIntro extends StatelessWidget {
  const _SectionIntro(
      {required this.title,
      required this.subtitle,
      required this.body,
      required this.p});

  final String title;
  final String subtitle;
  final String body;
  final V2Palette p;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.5,
                color: p.ink1)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: p.action)),
        const SizedBox(height: 9),
        Text(body,
            style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
      ]);
}

// ⚠️ SUPERSEDED BY `_CycleHeader` + `_WindowLine`, KEPT FOR REVERT.
//
// The rule this card was written around is the one that matters and it has
// been carried into the header verbatim: it shows POSITION and refuses to
// show PROBABILITY, and when confidence is unknown it says the app has
// nothing to lean on rather than printing an estimate anyway.
// /// The cycle spine, as one card.
// ///
// /// ⚠️ IT SHOWS POSITION AND REFUSES TO SHOW PROBABILITY. `fertility` is a level
// /// this app is allowed to name; a percentage is not, and neither is anything
// /// that reads as a target. When confidence is unknown the card says the app has
// /// nothing to lean on rather than printing an estimate anyway — the exact
// /// failure `TtcNoEstimate` was added to stop, after "ovulation around day 40"
// /// appeared on five screens from a single unlogged gap.
// class _SpineCard extends StatelessWidget {
//   const _SpineCard(
//       {required this.today,
//       required this.p,
//       required this.hinglish,
//       required this.onTap});
//
//   final TtcToday today;
//   final V2Palette p;
//   final bool hinglish;
//   final VoidCallback onTap;
//
//   String get _line {
//     if (today.noEstimate == TtcNoEstimate.noPeriodLogged) {
//       return hinglish
//           ? 'Abhi tak kuch log nahi hua. Pehla period log karte hi cycle yahan banna shuru ho jayega.'
//           : 'Nothing logged yet. Log one period and your cycle starts taking shape here.';
//     }
//     if (today.clinicInvolved) {
//       // ⚠️ WE DEFER, WE DO NOT COMPUTE. When a clinic owns the timing, an app
//       // estimate beside it is a second opinion she did not ask for. Truth
//       // hierarchy: treating clinician outranks ParentVeda's calculation by six
//       // places.
//       return hinglish
//           ? 'Aapki clinic timing sambhaal rahi hai. Hum yahan sirf aapke saath chal rahe hain — apna hisaab nahi laga rahe.'
//           : 'Your clinic is holding the timing. We are keeping you company here, '
//               'not running our own numbers alongside theirs.';
//     }
//     if (today.confidence == OvulationConfidence.unknown) {
//       return hinglish
//           ? 'Abhi itna record nahi hai ki hum kuch keh sakein. Jaise-jaise aap log karengi, yeh saaf hota jayega.'
//           : 'Not enough logged yet for us to say anything useful. It gets clearer as you go.';
//     }
//     return hinglish
//         ? 'Cycle day ${today.cycleDay}. Aapki rhythm, jitna abhi tak pata hai.'
//         : 'Cycle day ${today.cycleDay}. Your rhythm, as far as we know it.';
//   }
//
//   @override
//   Widget build(BuildContext context) => InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
//           decoration: BoxDecoration(
//             color: p.surface,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: p.line),
//           ),
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(_line,
//                 style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
//             const SizedBox(height: 12),
//             Row(children: [
//               Text(hinglish ? 'Cycle kholein' : 'Open your cycle',
//                   style: pvManrope(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: p.action)),
//               const SizedBox(width: 4),
//               Icon(Icons.arrow_forward_rounded, size: 15, color: p.action),
//             ]),
//           ]),
//         ),
//       );
// }

/// A titled card with a drawn mark. The shape every "one thing" section on the
/// other two stages uses.
// Superseded 2026-09-16: the chapter card became `_ChapterCard` and the
// experts link became `_ExpertRail`. Kept for revert.
// ignore: unused_element
class _LinkCard extends StatelessWidget {
  const _LinkCard(
      {required this.title,
      required this.body,
      required this.p,
      required this.hue,
      required this.mark,
      required this.onTap});

  final String title;
  final String body;
  final V2Palette p;
  final double hue;
  final V3DailyMark mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SizedBox(
                width: 28, height: 28, child: V3DailyArt(mark: mark, tint: tint)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: pvFraunces(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.3,
                      color: p.ink1)),
              const SizedBox(height: 5),
              Text(body,
                  style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// =============================================================================
//  The gates V1 had and V3 did not
// -----------------------------------------------------------------------------
//  Everything below is a V1 home component restated in the V3 palette. None of
//  it is new product: same data, same destinations, same words where the words
//  were already right. The V1/V3 pill is an A/B on how the home LOOKS, and the
//  moment one side can reach something the other cannot, the comparison stops
//  being about that.
//
//  ⚠️ THE DESTINATIONS ARE SHARED, NOT COPIED. `showTtcRowSheet`,
//  `TtcInsightScreen`, `openTtcChapter`, `openTtcProducts` and
//  `recordPositiveTest` are the same functions V1 calls. A second set styled
//  for V3 would be two things to keep in step, and this file already carries a
//  comment about a `_Head` that drifted a colour by being copied once.
// =============================================================================

// =============================================================================
//  The three rails
// =============================================================================

/// The five daily items, as circles.
///
/// ⚠️ THE SAME FIVE DESTINATIONS AND THE SAME FIVE OFFSETS as the card-and-rows
/// group this replaced. `ttcPickForToday` is a deterministic day-of-year
/// rotation, so an offset is not decoration — it is what stops the myth and the
/// movement being drawn from the same index every morning. Change one here and
/// V1 and V3 show different content on the same day, which is the one thing an
/// A/B toggle must not do.
///
/// ⚠️ THE CAPTIONS ARE THE SHIPPED STRINGS. `todaysInsight`, `todaysMyth`,
/// `todaysNutrition`, `todaysMovement`, `todaysPick` — not new labels that mean
/// the same thing. Two reasons: the Hinglish halves already exist, and
/// `test/ttc_home_v3_parity_test.dart` finds these five by text to prove V3
/// still reaches what V1 reaches. A hand-typed copy would look identical and
/// fail the test, which is precisely the failure already written up against
/// `todaysInsight`'s curly apostrophe.
///
/// ⚠️ DRAWN MARKS, NOT PHOTOGRAPHS. The reference this shape came from uses
/// image thumbnails; we have no per-item art and inventing an asset pipeline
/// for five rotating items is not the job. `V3DailyArt` in a tinted disc is the
/// stage's existing visual language and degrades honestly — see the note in
/// docs/STILL-OPEN.md if real thumbnails are ever commissioned.
// =============================================================================
//  THE DAILY INSIGHTS RAIL
// -----------------------------------------------------------------------------
//  ⚠️ RECTANGLES WITH ANSWERS ON THEM, REPLACING SIX IDENTICAL CIRCLES.
//
//  The old rail is kept below, commented, per the revert rule. What it could
//  not do is the whole reason this exists: a 66pt circle with a caption under
//  it has room for the NAME of a thing and nothing else. Six of them in a row
//  is a menu — every item the same size, the same shape, the same weight, and
//  none of them telling you anything until you tap.
//
//  A card has a second line, so "today's insight" can become the insight,
//  "cycle day" can become "8", and the fertility band can be a word rather than
//  a colour you have to remember the key for. The screen starts answering
//  questions instead of listing where answers might be.
//
//  ⚠️ THE SET IS COMPUTED FOR THE SELECTED DAY. `ttcInsightsFor` decides which
//  contextual cards a day has earned; this widget appends the five evergreen
//  ones. That order matters — what is unusual about this day first, what is
//  true every day last.
//
//  ⚠️ AND THE EVERGREEN FIVE ARE NOT OPTIONAL. `ttc_home_v3_parity_test.dart`
//  asserts that today's insight, myth, nutrition, movement and pick are all
//  reachable from V3, because they are reachable from V1 and the Current | V3
//  pill is meant to compare two DESIGNS, not two feature sets. Dropping one
//  here because the card looked redundant would make the A/B measure the wrong
//  thing. Their rotation offsets (0/3/1/2/4) are also preserved exactly, so
//  both homes show the same item on the same day.
// =============================================================================
class _InsightRail extends StatelessWidget {
  const _InsightRail(
      {required this.p,
      required this.hinglish,
      required this.selected,
      required this.phase,
      required this.today});

  final V2Palette p;
  final bool hinglish;
  final DateTime selected;

  /// Where in her cycle [selected] falls (`ttcHomePhaseOn`).
  final TtcDayPhase phase;

  /// The screen's one idea of today.
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final hi = hinglish;
    final t = TtcS.current();

    // ⚠️ `now: selected`, WHICH IS THE POINT. `ttcPickForToday` already took an
    // optional date - it was only ever called without one. Threading the
    // selected day through means walking back through the strip walks back
    // through the content too, so yesterday's insight is genuinely yesterday's
    // rather than today's under a different heading.
    //
    // ⚠️ AND BY PHASE SINCE 2026-09-26 (gap analysis, "Behind: Home & daily",
    // P1). The date alone could put "your period came" in the fertile window.
    // `ttcHomeInsightFor` picks from the cards written for this stretch of
    // her cycle first, rotating by date only inside that set, and leaves the
    // closeness card out when she has asked to hide intimacy content. Kept
    // for revert:
    //   final insight = ttcPickForToday(ttcInsights, now: selected);
    final insight = ttcHomeInsightFor(selected, phase: phase);
    final myth = ttcPickForToday(ttcMyths, now: selected, offset: 3);
    final n = ttcPickForToday(ttcNutrition, now: selected, offset: 1);
    // One picker (launch sanity MB18, 2026-09-28): the movement Mind & body ›
    // Today names. Kept for revert:
    //   final m = ttcPickForToday(ttcMovements, now: selected, offset: 2);
    final m = ttcTodaysMoveTip(on: selected);
    final product = ttcPickForToday(ttcProducts, now: selected, offset: 4);

    // ⚠️ A RUNNING ROUND LEADS THE RAIL (2026-09-26, §3e): its step, and
    // its blood test named by DATE where "Should I test?" would sit. The
    // natural "Should I test?" card never shows on a clinic cycle anyway
    // (its phases are the waiting and late days).
    final roundStep = ttcHomeRoundPhaseOn(selected);
    final roundKind = TtcTreatmentStore.instance.cycle.kind;
    final bloodTest = ttcHomeBloodTestOn(selected);

    final cards = <TtcInsightCard>[
      if (roundStep != null && roundStep.isRunning)
        TtcInsightCard(
          id: 'round_step',
          eyebrow: ttcRoundKindShort(roundKind).toUpperCase(),
          value: ttcRoundPhaseName(roundStep, roundKind),
          caption: 'Your round',
          hue: 206,
          art: TtcInsightArt.note,
          go: TtcInsightGo.treatment,
        ),
      if (bloodTest != null)
        TtcInsightCard(
          id: 'blood_test',
          eyebrow: ttcStepLabel(TtcTreatmentStep.betaTest, roundKind)
              .toUpperCase(),
          value: ttcRoundDate(bloodTest),
          caption: "Your clinic's date",
          hue: 268,
          art: TtcInsightArt.ring,
          go: TtcInsightGo.treatment,
        ),
      // ⚠️ THE WAITING-DAYS CARD OFFERS "SHOULD I TEST?" (2026-09-26). Only on
      // today, and only in the waiting or late days of her own cycle: the chat
      // answers from today's dates, so offering it under last Tuesday would
      // open an answer about a different day than the one she is looking at.
      // FIRST on the rail on those days, because it is the question those
      // days are about; past the third card it sat off screen at phone width.
      //
      // ⚠️ ONE ENTRANCE ON A LATE DAY (review H1, 2026-09-26). On a late day
      // the hero already says "Time to test" with the one "Should I test?"
      // pill under it; a third way in, here, made one question three
      // buttons. So the card is for the waiting days, and for a late day only
      // when the hero has no pill to offer. Kept for revert:
      //   (phase == TtcDayPhase.waiting || phase == TtcDayPhase.late)
      if (selected == today &&
          (phase == TtcDayPhase.waiting ||
              (phase == TtcDayPhase.late && !ttcHomeShowsLatePill(today))))
        const TtcInsightCard(
          id: 'should_test',
          eyebrow: kTtcShouldTestEyebrow,
          value: kTtcShouldTestValue,
          caption: kTtcShouldTestCaption,
          hue: 268,
          art: TtcInsightArt.ring,
          go: TtcInsightGo.shouldTest,
        ),
      ...ttcInsightsFor(selected),
      TtcInsightCard(
        id: 'insight',
        eyebrow: t.todaysInsight,
        value: insight.title(hi),
        hue: 206,
        art: TtcInsightArt.note,
        go: TtcInsightGo.insight,
      ),
      TtcInsightCard(
        id: 'myth',
        eyebrow: t.todaysMyth,
        value: myth.myth(hi),
        hue: 42,
        art: TtcInsightArt.balance,
        go: TtcInsightGo.myth,
      ),
      TtcInsightCard(
        id: 'nutrition',
        eyebrow: t.todaysNutrition,
        value: n.meal(hi),
        caption: n.nutrient(hi),
        hue: 104,
        art: TtcInsightArt.meal,
        go: TtcInsightGo.nutrition,
      ),
      TtcInsightCard(
        id: 'movement',
        eyebrow: t.todaysMovement,
        value: m.title(hi),
        hue: 160,
        art: TtcInsightArt.move,
        go: TtcInsightGo.movement,
      ),
      // ⚠️ THE REPORT IS ON THE RAIL BY REQUEST - *"have it as a button in
      // daily insights"* - and the placement earns it. It was a button at the
      // FOOT of the logging screen: the payoff for logging, reachable only by
      // going back into the thing you had just finished doing.
      TtcInsightCard(
        id: 'report',
        eyebrow: t.reportShort,
        value: 'What your cycle shows',
        hue: 268,
        art: TtcInsightArt.ring,
        go: TtcInsightGo.report,
      ),
      TtcInsightCard(
        id: 'pick',
        eyebrow: t.todaysPick,
        value: product.name(hi),
        hue: 344,
        art: TtcInsightArt.product,
        go: TtcInsightGo.products,
      ),
    ];

    return SizedBox(
      // ⚠️ 112, AND THE NUMBER IS MEASURED OFF THE REFERENCE RATHER THAN
      // GUESSED AT — twice now, because the first pass at "smaller" was still
      // too big. In the screenshot each card is about 31% of the screen width
      // and very close to square: on a 360dp phone that is roughly 111 x 113.
      //
      // Ours are 100 x 112, deliberately a little under. Three at 100 plus two
      // 8pt gaps is 316 inside a 324pt gutter, so three fit whole AND there is
      // slack — *"so that three can fit with a bit of space available still."*
      // Landing exactly on 108 would fill the row edge to edge, and a rail that
      // ends flush at the screen edge gives no hint that it scrolls.
      //
      // A `SizedBox` around a rail must equal its tallest child. Reserve more
      // and the surplus lands on top of the section gap below as a hole; this
      // rail has already shipped that bug once at 128 around a 104pt child.
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: cards.length,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 8),
          child: _InsightTile(
            card: cards[i],
            p: p,
            // ⚠️ TODAY'S PICK OPENS THE PRODUCT IT NAMES (launch sanity H2,
            // 2026-09-28). It opened the top of the store (Folic acid in the
            // hero) under a card that said CoQ10, so she had to hunt for the
            // thing she tapped. Kept for revert: every card through
            // `_openInsight`, where `products` opens the whole store.
            onTap: cards[i].id == 'pick'
                ? () => openTtcProductPage(context, product.id)
                : () => _openInsight(context, cards[i], hi, selected,
                    insight: insight, myth: myth, n: n, m: m),
          ),
        ),
      ),
    );
  }
}

/// Every destination a card can have, in one place.
///
/// ⚠️ AN EXHAUSTIVE SWITCH ON PURPOSE. `TtcInsightGo` is a plain enum and Dart
/// will warn on a missing case, which is the cheapest possible version of the
/// wiring gate: adding a card kind that goes nowhere becomes a compile-time
/// complaint rather than a tile that does nothing on a device three weeks from
/// now. This stage has shipped correct-but-unreachable code before.
void _openInsight(
  BuildContext context,
  TtcInsightCard card,
  bool hi,
  DateTime selected, {
  required TtcInsight insight,
  required TtcMyth myth,
  required TtcNutrition n,
  required TtcMovement m,
}) {
  switch (card.go) {
    case TtcInsightGo.shouldTest:
      _openSurface(context, 'ttc_chat/should_test');
    case TtcInsightGo.treatment:
      _openSurface(context, 'ttc_treatment');
    case TtcInsightGo.window:
      _openSurface(context, 'ttc_window');
    case TtcInsightGo.cycle:
      _openSurface(context, 'ttc_cycle');
    case TtcInsightGo.products:
      openTtcProducts(context);
    case TtcInsightGo.read:
      final id = card.readId;
      if (id != null) _openSurface(context, 'ttc_read/$id');
    case TtcInsightGo.report:
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/cycle_report'),
        builder: (_) => const TtcCycleReportScreen(),
      ));
    case TtcInsightGo.logger:
      // ⚠️ OPENS ON THE SELECTED DAY, not on today. A card that says "how did
      // that day feel?" and then opens a form dated today would write her
      // answer to the wrong date - silently, and in the one store the calendar,
      // the strip and the report all read.
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/symptom_log'),
        builder: (_) => TtcSymptomLogScreen(day: selected),
      ));
    case TtcInsightGo.insight:
      // The article format, 2026-09-17 — see ttc_insight_read.dart. Kept for
      // revert:
      // Navigator.of(context).push(MaterialPageRoute<void>(
      //   settings: const RouteSettings(name: 'ttc/insight'),
      //   builder: (_) => TtcInsightScreen(insight: insight),
      // ));
      openTtcInsight(context, insight);
    // ⚠️ NO SHEETS FOR THE DAILY THREE (the user, 2026-09-28: "pop-ups that
    // come from below, not good UI, not a good way to give information").
    // The myth opens the story deck every door myth opens; nutrition and
    // movement open as reads in the one reader. See ttc_daily_tip_open.dart.
    // Kept for revert, the three sheets:
    //   case TtcInsightGo.myth:
    //     showTtcRowSheet(
    //       context,
    //       eyebrow: TtcS.current().todaysMyth,
    //       title: myth.myth(hi),
    //       body: [
    //         Container(
    //           width: double.infinity,
    //           padding: const EdgeInsets.all(15),
    //           decoration: BoxDecoration(
    //             color: ttcPanel,
    //             borderRadius: BorderRadius.circular(ttcCardRadius),
    //           ),
    //           child: Text(myth.truth(hi),
    //               style: ttcBody(14, color: ttcTitleInk, h: 1.65)),
    //         ),
    //       ],
    //     );
    //   case TtcInsightGo.nutrition:
    //     showTtcRowSheet(
    //       context,
    //       eyebrow: n.nutrient(hi),
    //       title: n.meal(hi),
    //       body: [
    //         Text(n.why(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
    //         const SizedBox(height: 16),
    //         Container(
    //           width: double.infinity,
    //           padding: const EdgeInsets.all(15),
    //           decoration: BoxDecoration(
    //             color: ttcCautionCard,
    //             borderRadius: BorderRadius.circular(ttcCardRadius),
    //           ),
    //           child: Text(n.indian(hi),
    //               style: ttcBody(13.5, color: ttcBrown, h: 1.6)),
    //         ),
    //       ],
    //     );
    //   case TtcInsightGo.movement:
    //     showTtcRowSheet(
    //       context,
    //       eyebrow: TtcS.current().todaysMovement,
    //       title: m.title(hi),
    //       body: [Text(m.body(hi), style: ttcBody(14, color: ttcInk, h: 1.7))],
    //     );
    case TtcInsightGo.myth:
      openTtcMythStory(context, myth, hi);
    case TtcInsightGo.nutrition:
      openTtcTipRead(context, ttcNutritionAsRead(n));
    case TtcInsightGo.movement:
      openTtcTipRead(context, ttcMovementAsRead(m));
  }
}

/// One card: a tinted block with the answer written on it.
///
/// ⚠️ NO WHITE HALF ANY MORE. It was a tinted head over a white body, and the
/// note back was *"we definitely don't need this white division of it. It
/// should stay just as the texture... it can be written inside of it as well."*
///
/// Which is right, and the reasoning that produced the split was wrong in a way
/// worth naming. The argument had been that a white body puts the answer on the
/// highest-contrast surface on the screen. True in isolation, and it ignored
/// what the split costs: a horizontal seam across every card in the rail, so
/// eight cards read as sixteen shapes. The eye counts edges, and doubling the
/// edges is what made a rail of small blocks feel heavy at any size.
///
/// The tints here are already pale — `v2BlockTint` is a controlled-pastel wheel
/// — so ink on one of them clears contrast comfortably. The contrast argument
/// was solving a problem the palette had already solved.
///
/// ⚠️ AND SMALLER — 100 x 112, down from 158 x 168 via 118 x 132. See the
/// rail's note for where the number came from; the short version is that three
/// cards per screen is what makes a rail read as a rail rather than as a stack
/// of panels you swipe.
///
/// ⚠️ EVERYTHING INSIDE SHRANK WITH THE BOX, WHICH IS THE PART THAT IS EASY TO
/// SKIP. A card resized without its type resized is not a smaller card, it is
/// the same card clipping its own contents — and `maxLines` hides that as
/// ellipses rather than as an overflow anyone would notice.
class _InsightTile extends StatelessWidget {
  const _InsightTile(
      {required this.card, required this.p, required this.onTap});

  final TtcInsightCard card;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvInsightTile(
        eyebrow: card.eyebrow,
        value: card.value,
        caption: card.caption,
        hue: card.hue,
        art: card.art,
        p: p,
        onTap: onTap,
      );
}

// =============================================================================
//  KEPT FOR REVERT — the tile and its painter as they were before they became
//  `PvInsightTile` / `PvInsightMark` (lib/screens/v2/pv_insight_rail.dart,
//  2026-09-21). Moved verbatim, sizes and all.
// =============================================================================
// class _InsightTile extends StatelessWidget {
//   const _InsightTile(
//       {required this.card, required this.p, required this.onTap});
//
//   static const double width = 100;
//   static const double height = 112;
//
//   final TtcInsightCard card;
//   final V2Palette p;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     // ⚠️ `% 360` IS NOT DEFENSIVE PADDING. `v2BlockTint` asserts hue <= 360,
//     // and a symptom hue arriving from the data file has already tripped it once
//     // in this stage. A hue is an angle; wrapping it is the correct arithmetic.
//     final tint = v2BlockTint(card.hue % 360, p);
//     final deep = HSLColor.fromColor(tint)
//         .withSaturation(0.45)
//         .withLightness(0.34)
//         .toColor();
//
//     return Semantics(
//       button: true,
//       label: '${card.eyebrow}: ${card.value}',
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(18),
//         child: Container(
//           width: width,
//           height: height,
//           decoration: BoxDecoration(
//             color: tint,
//             borderRadius: BorderRadius.circular(18),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: Stack(children: [
//             // The mark fills the block and is cropped by its edge, the same
//             // device the focus rail uses. With the white body gone it has the
//             // whole card to sit in, so it can be quieter and still register.
//             Positioned.fill(
//               child: CustomPaint(
//                   painter: _InsightMark(
//                       art: card.art, ink: deep.withValues(alpha: 0.5))),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(card.eyebrow.toUpperCase(),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: pvManrope(
//                             fontSize: 7.5,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 0.6,
//                             height: 1.25,
//                             color: deep)),
//                     const Spacer(),
//                     Text(card.value,
//                         maxLines: card.caption == null ? 4 : 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: pvJakarta(
//                             fontSize: _valueSize(card.value),
//                             fontWeight: FontWeight.w800,
//                             height: 1.2,
//                             color: p.ink1)),
//                     if (card.caption != null) ...[
//                       const SizedBox(height: 3),
//                       Text(card.caption!,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: pvManrope(
//                               fontSize: 8.5,
//                               height: 1.25,
//                               color: p.ink2.withValues(alpha: 0.85))),
//                     ],
//                   ]),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
//
//   /// ⚠️ THE SIZE FOLLOWS THE LENGTH, and this is the one piece of type on the
//   /// card that could not be a constant. The same slot holds "8" and "Cut back
//   /// on chai to two cups" - a size that suits the sentence makes the number
//   /// look like a label, and a size that suits the number turns the sentence
//   /// into four ellipsised lines. Three steps, chosen at the lengths where the
//   /// text stops fitting rather than at round numbers.
//   ///
//   /// ⚠️ ALL THREE CAME DOWN WITH THE CARD, TWICE. 30/19/14.5 at 158pt became
//   /// 26/16/12.5 at 118, and is 22/14/11 at 100 — a type scale that does not
//   /// shrink with its container is how a resize turns into an overflow, or (with
//   /// `maxLines` set, as here) into silent ellipses that nobody files a bug for.
//   static double _valueSize(String v) {
//     if (v.length <= 3) return 22;
//     if (v.length <= 12) return 14;
//     return 11;
//   }
// }
//
// /// The drawn mark in a card's head.
// ///
// /// ⚠️ DRAWN, NOT AN ICON FONT AND NOT AN ASSET. Same reason the rest of this
// /// stage paints its own art: an icon at this size reads as a button affordance,
// /// and these are not buttons in the head - they are the card's texture. Each
// /// mark is a few strokes tuned to sit behind the eyebrow without competing
// /// with it, which no shipped icon set does.
// class _InsightMark extends CustomPainter {
//   const _InsightMark({required this.art, required this.ink});
//
//   final TtcInsightArt art;
//   final Color ink;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final stroke = Paint()
//       ..color = ink.withValues(alpha: 0.5)
//       ..strokeWidth = 2
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;
//     final fill = Paint()..color = ink.withValues(alpha: 0.32);
//
//     // Anchored bottom-right, so the eyebrow at top-left never collides with it
//     // regardless of how many lines the eyebrow takes.
//     final cx = size.width - 22;
//     final cy = size.height - 20;
//
//     // ⚠️ SCALED ABOUT ITS OWN CENTRE, NOT REDRAWN AT NEW NUMBERS. The geometry
//     // below was tuned inside a 158 x 168 card; the card is now 100 x 112, so
//     // every radius and bar length is proportionally half again too big and the
//     // mark starts crowding the value text. Rewriting thirty constants would
//     // have to be redone the next time the card moves — a single transform about
//     // the anchor keeps the drawing and its position independent.
//     canvas.save();
//     canvas.translate(cx, cy);
//     canvas.scale(0.72);
//     canvas.translate(-cx, -cy);
//
//     switch (art) {
//       case TtcInsightArt.level:
//         // Three ascending bars: the shape of a band getting stronger.
//         for (var i = 0; i < 3; i++) {
//           final h = 9.0 + i * 8;
//           canvas.drawRRect(
//               RRect.fromRectAndRadius(
//                   Rect.fromLTWH(cx - 12 + i * 11, cy + 6 - h, 7, h),
//                   const Radius.circular(3)),
//               fill);
//         }
//       case TtcInsightArt.number:
//       case TtcInsightArt.ring:
//         // An open ring - a cycle, with the gap saying it is not finished.
//         canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: 15),
//             -1.9, 4.9, false, stroke);
//         canvas.drawCircle(Offset(cx + 13, cy - 8), 3.2, fill);
//       case TtcInsightArt.symptom:
//         // A pulse: quiet, one peak, quiet.
//         final path = Path()..moveTo(cx - 20, cy);
//         path.lineTo(cx - 8, cy);
//         path.lineTo(cx - 3, cy - 13);
//         path.lineTo(cx + 3, cy + 8);
//         path.lineTo(cx + 8, cy);
//         path.lineTo(cx + 20, cy);
//         canvas.drawPath(path, stroke);
//       case TtcInsightArt.droplet:
//         final path = Path()
//           ..moveTo(cx, cy - 17)
//           ..quadraticBezierTo(cx + 14, cy - 1, cx, cy + 13)
//           ..quadraticBezierTo(cx - 14, cy - 1, cx, cy - 17)
//           ..close();
//         canvas.drawPath(path, fill);
//       case TtcInsightArt.note:
//         // Lines of text, shortening - a page of something to read.
//         for (var i = 0; i < 4; i++) {
//           canvas.drawLine(Offset(cx - 18, cy - 12 + i * 8),
//               Offset(cx + 18 - i * 7, cy - 12 + i * 8), stroke);
//         }
//       case TtcInsightArt.balance:
//         // Two pans on a beam: the myth on one side, the fact on the other.
//         canvas.drawLine(Offset(cx - 19, cy - 8), Offset(cx + 19, cy - 8),
//             stroke);
//         canvas.drawLine(Offset(cx, cy - 8), Offset(cx, cy + 12), stroke);
//         canvas.drawCircle(Offset(cx - 14, cy + 2), 5, fill);
//         canvas.drawCircle(Offset(cx + 14, cy + 2), 5, fill);
//       case TtcInsightArt.log:
//         canvas.drawCircle(Offset(cx, cy), 15, stroke);
//         canvas.drawLine(Offset(cx - 7, cy), Offset(cx + 7, cy), stroke);
//         canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy + 7), stroke);
//       case TtcInsightArt.meal:
//         // A bowl.
//         canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy - 2), radius: 16),
//             0.15, 2.85, false, stroke);
//         canvas.drawLine(Offset(cx - 18, cy - 2), Offset(cx + 18, cy - 2),
//             stroke);
//         canvas.drawCircle(Offset(cx, cy - 12), 3.5, fill);
//       case TtcInsightArt.move:
//         // A stride.
//         canvas.drawCircle(Offset(cx + 2, cy - 16), 4.5, fill);
//         canvas.drawLine(Offset(cx + 2, cy - 11), Offset(cx - 2, cy + 1),
//             stroke);
//         canvas.drawLine(Offset(cx - 2, cy + 1), Offset(cx - 11, cy + 11),
//             stroke);
//         canvas.drawLine(Offset(cx - 2, cy + 1), Offset(cx + 9, cy + 11),
//             stroke);
//       case TtcInsightArt.product:
//         canvas.drawRRect(
//             RRect.fromRectAndRadius(
//                 Rect.fromLTWH(cx - 15, cy - 12, 30, 26),
//                 const Radius.circular(5)),
//             fill);
//         canvas.drawLine(Offset(cx - 15, cy - 4), Offset(cx + 15, cy - 4),
//             stroke);
//     }
//     canvas.restore();
//   }
//
//   @override
//   bool shouldRepaint(_InsightMark old) =>
//       old.art != art || old.ink != ink;
// }

// =============================================================================
//  KEPT FOR REVERT - the circle rail this replaced
// -----------------------------------------------------------------------------
//  Six 66pt bubbles with captions under them. Same six destinations as the
//  cards above, so nothing was lost by commenting it out; what it could not do
//  was carry the answer as well as the label, or change from one day to the
//  next. If the cards turn out to be too heavy for the top of the home, this
//  goes back with a one-line swap in `_TtcHomeV3State.build`.
// =============================================================================
/*
class _DailyRail extends StatelessWidget {
  const _DailyRail({required this.p, required this.hinglish});

  final V2Palette p;
  final bool hinglish;

  @override
  Widget build(BuildContext context) {
    final hi = hinglish;
    final t = TtcS.current();

    final insight = ttcPickForToday(ttcInsights);
    final myth = ttcPickForToday(ttcMyths, offset: 3);
    final n = ttcPickForToday(ttcNutrition, offset: 1);
    final m = ttcPickForToday(ttcMovements, offset: 2);
    final product = ttcPickForToday(ttcProducts, offset: 4);

    // ⚠️ 104, MEASURED, NOT GUESSED. A circle (66) + gap (8) + a two-line
    // caption (~26) is 100, so 128 left 28dp of nothing under every bubble —
    // which landed on top of the section gap below and read on the device as a
    // hole between the rail and "Start anywhere". A `SizedBox` around a rail
    // has to be sized to the rail's tallest child, not rounded up for comfort.
    return SizedBox(
      height: 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          _Story(
            caption: t.todaysInsight,
            hue: 206,
            mark: V3DailyMark.note,
            p: p,
            // The article format (ttc_insight_read.dart). Kept for revert:
            // onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            //   builder: (_) => TtcInsightScreen(insight: insight),
            //   settings: const RouteSettings(name: 'ttc/insight'),
            // )),
            onTap: () => openTtcInsight(context, insight),
          ),
          _Story(
            caption: t.todaysMyth,
            hue: 42,
            mark: V3DailyMark.voice,
            p: p,
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
          _Story(
            caption: t.todaysNutrition,
            hue: 104,
            mark: V3DailyMark.capsule,
            p: p,
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
                    color: ttcCautionCard,
                    borderRadius: BorderRadius.circular(ttcCardRadius),
                  ),
                  child: Text(n.indian(hi),
                      style: ttcBody(13.5, color: ttcBrown, h: 1.6)),
                ),
              ],
            ),
          ),
          _Story(
            caption: t.todaysMovement,
            hue: 160,
            mark: V3DailyMark.memory,
            p: p,
            onTap: () => showTtcRowSheet(
              context,
              eyebrow: t.todaysMovement,
              title: m.title(hi),
              body: [
                Text(m.body(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
              ],
            ),
          ),
          // ⚠️ THE REPORT LIVES IN THE DAILY RAIL, and that placement was a
          // decision rather than convenience. It was a button at the FOOT of
          // the logging screen — the payoff for logging, reachable only by
          // going back into the thing you had just finished doing. Here it sits
          // beside the day's content, which is where someone looks when they
          // want to know what the app has made of their week.
          _Story(
            caption: t.reportShort,
            hue: 160,
            mark: V3DailyMark.note,
            p: p,
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'ttc/cycle_report'),
              builder: (_) => const TtcCycleReportScreen(),
            )),
          ),
          _Story(
            caption: t.todaysPick,
            hue: 344,
            mark: V3DailyMark.photo,
            p: p,
            // The product rail below shows the catalogue; this circle keeps the
            // one rotating pick V1 has, so the two homes still agree.
            onTap: () => openTtcProducts(context),
            tooltip: product.name(hi),
          ),
        ],
      ),
    );
  }
}

/// One circle and its caption.
class _Story extends StatelessWidget {
  const _Story({
    required this.caption,
    required this.hue,
    required this.mark,
    required this.p,
    required this.onTap,
    this.tooltip,
  });

  final String caption;
  final double hue;
  final V3DailyMark mark;
  final V2Palette p;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    return Semantics(
      button: true,
      label: tooltip == null ? caption : '$caption, $tooltip',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 82,
          child: Column(children: [
            Container(
              width: 66,
              height: 66,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
                // The ring is what makes it read as a story rather than a
                // button. Same tint, one step darker, so it never becomes a
                // second colour to account for.
                border: Border.all(
                    color: HSLColor.fromColor(tint)
                        .withSaturation(0.42)
                        .withLightness(0.72)
                        .toColor(),
                    width: 2),
              ),
              child: V3DailyArt(mark: mark, tint: tint),
            ),
            const SizedBox(height: 8),
            Text(caption.toUpperCase(),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    height: 1.35,
                    color: p.ink2)),
          ]),
        ),
      ),
    );
  }
}

*/

/// Products worth having, as a rail.
/// The products rail, in the design's card: an image well, the name, one
/// line, the price and a chevron. Opens THE product.
///
/// ⚠️ THE WELL DRAWS A MARK, NOT A PHOTOGRAPH. `TtcProduct.photos` is empty
/// across the catalogue today. The parenting rail makes the same call for
/// the same reason — a wrong photograph is read as THIS product.
///
/// ⚠️ THE ONE LINE IS "LOOK FOR", NEVER "WHY". The design's line reads
/// "Folate — from three months before": a category and a moment. The section
/// comment above the call site is the rule — on a fertility home, one line
/// under a supplement is the shortest route to an implied promise about her
/// odds — and `whyEn` is exactly that line. `lookForEn` ("Plain 400mcg folic
/// acid. That is all most people need.") is a shopping instruction, makes no
/// claim about outcome, and is what the catalogue was written to put beside
/// a price. The category rides in the chip.
class _ProductRail extends StatelessWidget {
  const _ProductRail({required this.p, required this.hinglish});

  final V2Palette p;
  final bool hinglish;

  @override
  Widget build(BuildContext context) {
    // Four, taken off the same deterministic rotation the daily pick uses so
    // the rail is stable within a day and moves between them.
    final picks = [
      for (var i = 0; i < 4; i++) ttcPickForToday(ttcProducts, offset: 4 + i),
    ];

    return SizedBox(
      // Well 104 + a two-line name + a two-line look-for + the price row.
      // 262 left a dead band under the look-for on the phone.
      height: 244,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: picks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final product = picks[i];
          final tint = v2BlockTint((344 + (i * 24)) % 360, p);
          final ink = HSLColor.fromColor(tint)
              .withSaturation(0.46)
              .withLightness(0.42)
              .toColor();
          return SizedBox(
            width: 178,
            child: InkWell(
              onTap: () => openTtcProductPage(context, product.id),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.line),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 104,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: tint,
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(Icons.shopping_bag_outlined,
                            size: 30, color: ink),
                      ),
                      const SizedBox(height: 10),
                      Text(product.name(hinglish),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvFraunces(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              letterSpacing: -0.3,
                              color: p.ink1)),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Text(
                            hinglish ? product.lookForHi : product.lookForEn,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 12.5, height: 1.4, color: p.ink2)),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        Expanded(
                          child: Text(product.priceEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: p.ink1)),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 18, color: p.ink3),
                      ]),
                    ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// The 142dp rail this replaces, which opened the shop's front page. Kept for
// revert:
// class _ProductRail extends StatelessWidget {
//   const _ProductRail({required this.p, required this.hinglish});
//
//   final V2Palette p;
//   final bool hinglish;
//
//   @override
//   Widget build(BuildContext context) {
//     // Four, taken off the same deterministic rotation the daily pick uses so
//     // the rail is stable within a day and moves between them.
//     final picks = [
//       for (var i = 0; i < 4; i++) ttcPickForToday(ttcProducts, offset: 4 + i),
//     ];
//
//     return SizedBox(
//       // ⚠️ SAME ARITHMETIC AS THE FOCUS RAIL, SAME FIX. 18 + 158 + 11 + 158 is
//       // 345, and the gap that follows pushes the third card to 356 — four
//       // points visible on a 360pt screen, which reads as a clipping bug rather
//       // than as an invitation to swipe. 142 wide with a 10pt gap leaves 38.
//       height: 150,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 18),
//         itemCount: picks.length,
//         separatorBuilder: (_, _) => const SizedBox(width: 10),
//         itemBuilder: (context, i) {
//           final product = picks[i];
//           final tint = v2BlockTint((344 + (i * 24)) % 360, p);
//           return InkWell(
//             onTap: () => openTtcProducts(context),
//             borderRadius: BorderRadius.circular(18),
//             child: Container(
//               width: 142,
//               padding: const EdgeInsets.all(13),
//               decoration: BoxDecoration(
//                 color: p.surface,
//                 borderRadius: BorderRadius.circular(18),
//                 border: Border.all(color: p.line),
//               ),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 34,
//                       height: 34,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                           color: tint, borderRadius: BorderRadius.circular(11)),
//                       child: Icon(Icons.shopping_bag_outlined,
//                           size: 17,
//                           color: HSLColor.fromColor(tint)
//                               .withSaturation(0.46)
//                               .withLightness(0.42)
//                               .toColor()),
//                     ),
//                     const SizedBox(height: 11),
//                     Text(product.name(hinglish),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: pvFraunces(
//                             fontSize: 14.5,
//                             fontWeight: FontWeight.w600,
//                             height: 1.25,
//                             letterSpacing: -0.2,
//                             color: p.ink1)),
//                     const Spacer(),
//                     // ⚠️ CATEGORY AND PRICE, NEVER A BENEFIT. See the section
//                     // comment: a one-line claim under a supplement on a
//                     // fertility home is the shortest route this product has to
//                     // an implied promise about her odds.
//                     Text(product.category.toUpperCase(),
//                         style: pvManrope(
//                             fontSize: 9,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 0.9,
//                             color: p.ink3)),
//                     const SizedBox(height: 3),
//                     Text(product.priceEn,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: pvManrope(
//                             fontSize: 11.5,
//                             fontWeight: FontWeight.w700,
//                             color: p.ink2)),
//                   ]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

/// Reads from the stage library, as a rail — the design's card: a tinted
/// well inside the padding, a "READ · N MIN" chip, the title, the standfirst.
class _ReadRail extends StatelessWidget {
  const _ReadRail(
      {required this.p,
      required this.hinglish,
      required this.day,
      required this.phase});

  final V2Palette p;
  final bool hinglish;

  /// The day the strip is on, and where in her cycle it falls.
  final DateTime day;
  final TtcDayPhase phase;

  @override
  Widget build(BuildContext context) {
    if (kTtcReads.isEmpty) return const SizedBox.shrink();
    // ⚠️ BY PHASE, NOT BY DAY OF YEAR (2026-09-26). `ttcHomeReadIdsFor`
    // rotates inside the phase's own list (`ttc_phase_reads.dart`) and leaves
    // out intimacy reads when she has asked for that. The day-of-year pick is
    // kept for revert, and as the fallback if the phase lists ever come back
    // empty, so the rail is never a blank strip:
    //   kTtcReads[(_dayOfYear() + i) % kTtcReads.length]
    final byPhase = [
      for (final id in ttcHomeReadIdsFor(day, phase: phase)) ?ttcReadById(id),
    ];
    final picks = byPhase.isNotEmpty
        ? byPhase
        : [
            for (var i = 0; i < 4 && i < kTtcReads.length; i++)
              kTtcReads[(_dayOfYear() + i) % kTtcReads.length],
          ];

    // ⚠️ ROWS, NOT A RAIL (the user, 2026-09-27: one app, one way to show
    // the same section, and the best one). Three reads as rows: the photo or
    // the door's drawn page mark, the title in the serif, and the topic with
    // its reading time. The pregnancy home already shows reads this way, and
    // Learn and the doors draw a read as a row too. Flo's rail of full-photo
    // cards (Mobbin 05fec5cd-4ac8-4fab-b374-04d47cc994ab) needs a strong
    // picture for every read; without one our rail showed empty book-icon
    // boxes. Rows also make reading the thing to do, not something to swipe
    // past. The rail below is kept for revert, unreached.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(children: [
        // H10 (launch sanity, 2026-09-28): never the same drawing twice in
        // this list. Two Fertile window reads both wore the moon and read as
        // one row repeated; the second now wears a mark of its own subject
        // (`ttcHomeReadMarks`). Kept for revert: no `mark:` argument.
        for (final (read, mark) in ttcHomeReadMarks(picks.take(3).toList()))
          _ReadRow(
            key: ValueKey('ttc_home_read_${read.id}'),
            read: read,
            p: p,
            hinglish: hinglish,
            mark: mark,
            onTap: () => openTtcSurface(context, '$kTtcReadPrefix${read.id}'),
          ),
      ]),
    );
    // return SizedBox(
    //   height: 236,
    //   child: ListView.separated(
    //     scrollDirection: Axis.horizontal,
    //     padding: const EdgeInsets.symmetric(horizontal: 18),
    //     itemCount: picks.length,
    //     separatorBuilder: (_, _) => const SizedBox(width: 12),
    //     itemBuilder: (context, i) {
    //       final read = picks[i];
    //       final tint = v2BlockTint(read.hue, p);
    //       final deep = HSLColor.fromColor(tint).withLightness(0.82).toColor();
    //       return SizedBox(
    //         width: 210,
    //         child: InkWell(
    //           onTap: () =>
    //               openTtcSurface(context, '$kTtcReadPrefix${read.id}'),
    //           borderRadius: BorderRadius.circular(20),
    //           child: Container(
    //             padding: const EdgeInsets.all(14),
    //             decoration: BoxDecoration(
    //               color: p.surface,
    //               borderRadius: BorderRadius.circular(20),
    //               border: Border.all(color: p.line),
    //             ),
    //             child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   // ⚠️ NEVER AN EMPTY BLOCK (launch walk, 2026-09-27):
    //                   // the tinted gradient read as a picture that failed to
    //                   // load. The read's photograph when it has one, else the
    //                   // same tint carrying a book mark, so it reads as meant.
    //                   // Kept for revert: the bare gradient Container.
    //                   ClipRRect(
    //                     borderRadius: BorderRadius.circular(14),
    //                     child: SizedBox(
    //                       height: 86,
    //                       width: double.infinity,
    //                       child: read.imageUrl != null
    //                           ? Image.network(read.imageUrl!,
    //                               fit: BoxFit.cover,
    //                               errorBuilder: (_, _, _) =>
    //                                   _readMark(tint, deep))
    //                           : _readMark(tint, deep),
    //                     ),
    //                   ),
    //                   const SizedBox(height: 10),
    //                   _Chip(
    //                       label:
    //                           '${TtcS.current().readOpen} · ${read.minutes} min',
    //                       p: p),
    //                   const SizedBox(height: 8),
    //                   Text(hinglish ? read.title.hi : read.title.en,
    //                       maxLines: 2,
    //                       overflow: TextOverflow.ellipsis,
    //                       style: pvFraunces(
    //                           fontSize: 15,
    //                           fontWeight: FontWeight.w600,
    //                           height: 1.25,
    //                           letterSpacing: -0.3,
    //                           color: p.ink1)),
    //                   const SizedBox(height: 4),
    //                   // ⚠️ `Expanded`, so a two-line title and a standfirst
    //                   // share the card's fixed height without either
    //                   // overflowing — the parenting rail's lesson.
    //                   Expanded(
    //                     child: Text(
    //                         hinglish ? read.teaser.hi : read.teaser.en,
    //                         maxLines: 2,
    //                         overflow: TextOverflow.ellipsis,
    //                         style: pvManrope(
    //                             fontSize: 12.5, height: 1.4, color: p.ink2)),
    //                   ),
    //                 ]),
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }

  /// Same day-of-year rotation `ttcPickForToday` uses, so the reads rail turns
  /// over on the same schedule as everything else on this page rather than on
  /// one of its own.
  /// The tint with a book mark, for a read without a photograph.
  // Unreached since the reads became rows (2026-09-27); kept for revert.
  // ignore: unused_element
  Widget _readMark(Color tint, Color deep) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tint, deep]),
        ),
        child: Center(
          child: Icon(Icons.menu_book_rounded,
              size: 30, color: p.ink1.withValues(alpha: 0.55)),
        ),
      );

  static int _dayOfYear() {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays;
  }
}

// The 196dp rail this replaces. Kept for revert:
// /// Reads from the stage library, as a rail.
// class _ReadRail extends StatelessWidget {
//   const _ReadRail({required this.p, required this.hinglish});
//
//   final V2Palette p;
//   final bool hinglish;
//
//   @override
//   Widget build(BuildContext context) {
//     if (kTtcReads.isEmpty) return const SizedBox.shrink();
//     final picks = [
//       for (var i = 0; i < 4 && i < kTtcReads.length; i++)
//         kTtcReads[(_dayOfYear() + i) % kTtcReads.length],
//     ];
//
//     return SizedBox(
//       height: 150,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 18),
//         itemCount: picks.length,
//         separatorBuilder: (_, _) => const SizedBox(width: 11),
//         itemBuilder: (context, i) {
//           final read = picks[i];
//           final tint = v2BlockTint(read.hue, p);
//           return InkWell(
//             onTap: () =>
//                 openTtcSurface(context, '$kTtcReadPrefix${read.id}'),
//             borderRadius: BorderRadius.circular(18),
//             child: Container(
//               width: 196,
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: p.surface,
//                 borderRadius: BorderRadius.circular(18),
//                 border: Border.all(color: p.line),
//               ),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                           color: tint,
//                           borderRadius: BorderRadius.circular(999)),
//                       child: Text(
//                           (hinglish ? read.kicker.hi : read.kicker.en)
//                               .toUpperCase(),
//                           style: pvManrope(
//                               fontSize: 8.5,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: 0.8,
//                               color: HSLColor.fromColor(tint)
//                                   .withSaturation(0.46)
//                                   .withLightness(0.34)
//                                   .toColor())),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(hinglish ? read.title.hi : read.title.en,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: pvFraunces(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             height: 1.25,
//                             letterSpacing: -0.25,
//                             color: p.ink1)),
//                     const Spacer(),
//                     Row(children: [
//                       Text(TtcS.current().readOpen,
//                           style: pvManrope(
//                               fontSize: 11.5,
//                               fontWeight: FontWeight.w800,
//                               color: p.action)),
//                       const SizedBox(width: 3),
//                       Icon(Icons.arrow_forward_rounded,
//                           size: 13, color: p.action),
//                     ]),
//                   ]),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   /// Same day-of-year rotation `ttcPickForToday` uses, so the reads rail turns
//   /// over on the same schedule as everything else on this page rather than on
//   /// one of its own.
//   static int _dayOfYear() {
//     final now = DateTime.now();
//     return now.difference(DateTime(now.year, 1, 1)).inDays;
//   }
// }

// ⚠️ SUPERSEDED BY `_DailyRail`, KEPT FOR REVERT. Same insight, same
// destination, same `ttcPickForToday(ttcInsights)` rotation — as a circle in
// the rail rather than a card with the takeaway inlined.
//
// ⚠️ THE ONE THING THE RAIL DOES NOT CARRY is the takeaway panel: the
// sentence meant to survive the day, readable without opening anything. It
// is still on `TtcInsightScreen`, one tap in. If the rail is kept, that is
// the loss to weigh.
// /// Today's insight — the one item here that is genuinely an article.
// class _InsightCardV3 extends StatelessWidget {
//   const _InsightCardV3({required this.p, required this.hinglish});
//
//   final V2Palette p;
//   final bool hinglish;
//
//   @override
//   Widget build(BuildContext context) {
//     final insight = ttcPickForToday(ttcInsights);
//     final tint = v2BlockTint(206, p);
//     return InkWell(
//       onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
//         builder: (_) => TtcInsightScreen(insight: insight),
//         settings: const RouteSettings(name: 'ttc/insight'),
//       )),
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
//         decoration: BoxDecoration(
//           color: p.surface,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: p.line),
//         ),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             // ⚠️ THE SHIPPED STRING, NOT A HAND-TYPED COPY OF IT. The literal
//             // here was 'TODAY’S INSIGHT' with a curly apostrophe while
//             // `todaysInsight` carries a straight one — visually identical,
//             // never equal, and it also meant the Hinglish half was a second
//             // translation of a string that already had one.
//             Text(TtcS.current().todaysInsight.toUpperCase(),
//                 style: pvManrope(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 1.3,
//                     color: p.action)),
//             const Spacer(),
//             Text(TtcS.current().readSeconds(insight.readTime(hinglish)),
//                 style: pvManrope(
//                     fontSize: 11, fontWeight: FontWeight.w700, color: p.ink3)),
//           ]),
//           const SizedBox(height: 9),
//           Text(insight.title(hinglish),
//               style: pvFraunces(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   height: 1.25,
//                   letterSpacing: -0.3,
//                   color: p.ink1)),
//           const SizedBox(height: 7),
//           Text(insight.body(hinglish).split('\n\n').first,
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//               style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
//           const SizedBox(height: 12),
//           // The one takeaway — the part meant to survive the day. Kept from V1
//           // because it is the reason this is a card and not a row.
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: tint,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Text(insight.takeaway(hinglish),
//                 style: pvManrope(
//                     fontSize: 13,
//                     height: 1.45,
//                     fontWeight: FontWeight.w700,
//                     color: p.ink1)),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// ⚠️ SUPERSEDED BY `_DailyRail`, KEPT FOR REVERT. The four rows and their
// four `ttcPickForToday` offsets (myth 3, nutrition 1, movement 2, pick 4)
// moved into the rail UNCHANGED — see the warning there about why those
// numbers are load-bearing rather than arbitrary.
// /// Today's myth, nutrition, movement and pick — four rows in one card.
// class _TodayRows extends StatelessWidget {
//   const _TodayRows({required this.p, required this.hinglish});
//
//   final V2Palette p;
//   final bool hinglish;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = hinglish;
//     final t = TtcS.current();
//     // ⚠️ THE SAME OFFSETS AS V1. `ttcPickForToday` is a deterministic
//     // day-of-year rotation, so an offset is not decoration — it is what stops
//     // the myth and the movement being drawn from the same index every day.
//     // Change one here and the two homes show different things on the same
//     // morning, which is the one thing an A/B toggle must not do.
//     final myth = ttcPickForToday(ttcMyths, offset: 3);
//     final n = ttcPickForToday(ttcNutrition, offset: 1);
//     final m = ttcPickForToday(ttcMovements, offset: 2);
//     final product = ttcPickForToday(ttcProducts, offset: 4);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: p.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: p.line),
//       ),
//       child: Column(children: [
//         _Row(
//           p: p,
//           hue: 42,
//           icon: Icons.lightbulb_outline_rounded,
//           eyebrow: t.todaysMyth,
//           title: myth.myth(hi),
//           onTap: () => showTtcRowSheet(
//             context,
//             eyebrow: t.todaysMyth,
//             title: myth.myth(hi),
//             body: [
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: ttcPanel,
//                   borderRadius: BorderRadius.circular(ttcCardRadius),
//                 ),
//                 child: Text(myth.truth(hi),
//                     style: ttcBody(14, color: ttcTitleInk, h: 1.65)),
//               ),
//             ],
//           ),
//         ),
//         _Row(
//           p: p,
//           hue: 104,
//           icon: Icons.restaurant_rounded,
//           eyebrow: t.todaysNutrition,
//           title: n.meal(hi),
//           onTap: () => showTtcRowSheet(
//             context,
//             eyebrow: n.nutrient(hi),
//             title: n.meal(hi),
//             body: [
//               Text(n.why(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
//               const SizedBox(height: 16),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: ttcCautionCard,
//                   borderRadius: BorderRadius.circular(ttcCardRadius),
//                 ),
//                 child: Text(n.indian(hi),
//                     style: ttcBody(13.5, color: ttcBrown, h: 1.6)),
//               ),
//             ],
//           ),
//         ),
//         _Row(
//           p: p,
//           hue: 160,
//           icon: Icons.directions_walk_rounded,
//           eyebrow: t.todaysMovement,
//           title: m.title(hi),
//           meta: m.minutes > 0 ? t.minutes(m.minutes) : null,
//           onTap: () => showTtcRowSheet(
//             context,
//             eyebrow: t.todaysMovement,
//             title: m.title(hi),
//             body: [
//               Text(m.body(hi), style: ttcBody(14, color: ttcInk, h: 1.7)),
//             ],
//           ),
//         ),
//         _Row(
//           p: p,
//           hue: 344,
//           icon: Icons.shopping_bag_outlined,
//           eyebrow: t.todaysPick,
//           title: product.name(hi),
//           meta: product.priceEn,
//           last: true,
//           onTap: () => openTtcProducts(context),
//         ),
//       ]),
//     );
//   }
// }
//
// class _Row extends StatelessWidget {
//   const _Row({
//     required this.p,
//     required this.hue,
//     required this.icon,
//     required this.eyebrow,
//     required this.title,
//     required this.onTap,
//     this.meta,
//     this.last = false,
//   });
//
//   final V2Palette p;
//   final double hue;
//
//   // ⚠️ A LINE ICON, NOT A `V3DailyMark`. The five marks are deliberately
//   // abstract — they are wallpaper for a section, and on a card the size of the
//   // journal's they read as texture. At 21px in a row they stop being abstract
//   // and start being WRONG: `capsule` is a pill beside a plate of food and
//   // `photo` is a picture frame beside a supplement. V3's hub and journey rows
//   // already use line icons for the same reason.
//   final IconData icon;
//   final String eyebrow;
//   final String title;
//   final String? meta;
//   final bool last;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final tint = v2BlockTint(hue, p);
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
//         decoration: BoxDecoration(
//           border: last ? null : Border(bottom: BorderSide(color: p.line)),
//         ),
//         child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//           Container(
//             width: 34,
//             height: 34,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: tint,
//               borderRadius: BorderRadius.circular(11),
//             ),
//             child: Icon(icon,
//                 size: 18,
//                 color: HSLColor.fromColor(tint)
//                     .withSaturation(0.46)
//                     .withLightness(0.42)
//                     .toColor()),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(eyebrow.toUpperCase(),
//                   style: pvManrope(
//                       fontSize: 9.5,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.1,
//                       color: p.ink3)),
//               const SizedBox(height: 3),
//               Text(title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: pvFraunces(
//                       fontSize: 15.5,
//                       fontWeight: FontWeight.w600,
//                       height: 1.25,
//                       letterSpacing: -0.2,
//                       color: p.ink1)),
//             ]),
//           ),
//           if (meta != null && meta!.isNotEmpty) ...[
//             const SizedBox(width: 10),
//             Text(meta!,
//                 style: pvManrope(
//                     fontSize: 11.5,
//                     fontWeight: FontWeight.w700,
//                     color: p.ink3)),
//           ],
//           const SizedBox(width: 6),
//           Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
//         ]),
//       ),
//     );
//   }
// }

/// Me · Us · What's next — the chapter reader's three tabs, as shortcuts.
// Superseded 2026-09-16 by the pills on `_ChapterCard`. Kept for revert.
// ignore: unused_element
class _ChapterTabs extends StatelessWidget {
  const _ChapterTabs({required this.p, required this.chapter});

  final V2Palette p;
  final TtcChapter chapter;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    Widget chip(String label, IconData icon, TtcChapterTab tab) => Expanded(
          child: InkWell(
            onTap: () => openTtcChapter(context, chapter, tab: tab),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.line),
              ),
              child: Column(children: [
                Icon(icon, size: 18, color: p.action),
                const SizedBox(height: 6),
                Text(label,
                    style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink2)),
              ]),
            ),
          ),
        );

    return Row(children: [
      chip(t.shortcutMe, Icons.self_improvement_rounded, TtcChapterTab.me),
      const SizedBox(width: 9),
      chip(t.shortcutUs, Icons.favorite_border_rounded, TtcChapterTab.us),
      const SizedBox(width: 9),
      chip(t.shortcutNext, Icons.event_available_outlined, TtcChapterTab.next),
    ]);
  }
}

/// The door out of the stage. Never a prompt to test.
///
/// The design's shape (2026-09-16): a hairline above, the label and a chevron,
/// the body under it. No border, no tint, no fill — even less of a card than
/// before, which is the right direction for the one row on this page that
/// must never read as "why haven't you tested?".
class _TestDoor extends StatelessWidget {
  const _TestDoor({required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    // ⚠️ A CARD SHE WILL SEE (the user, 2026-09-27: "record a positive test is
    // just plain text that won't even get noticed"). Still no celebration,
    // no push to test: a white card with a drawn well, the words, and a
    // chevron, like every other door on this page. Kept for revert: the
    // hairline-topped text row (padding top 20, Border(top: p.line)).
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => recordPositiveTest(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(children: [
            // The Test button's icon (2026-09-27): the drawn capsule read as
            // a medicine. Kept for revert: V3DailyArt(mark: V3DailyMark.capsule).
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: v2BlockTint(152, p),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.science_outlined,
                  size: 24, color: pvWellInk(v2BlockTint(152, p))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.transitionRecord,
                        style: pvFraunces(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            color: p.ink1)),
                    const SizedBox(height: 3),
                    Text(t.transitionRecordBody,
                        style: pvManrope(
                            fontSize: 13, height: 1.45, color: p.ink2)),
                  ]),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

// The bordered card this replaces. Kept for revert:
// /// The door out of the stage. Never a prompt to test.
// class _TestDoor extends StatelessWidget {
//   const _TestDoor({required this.p});
//
//   final V2Palette p;
//
//   @override
//   Widget build(BuildContext context) {
//     final t = TtcS.current();
//     return InkWell(
//       onTap: () => recordPositiveTest(context),
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           // No tint block and no fill — see the section comment. The border
//           // alone is what makes it a door rather than an offer.
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: p.line),
//         ),
//         child: Row(children: [
//           Icon(Icons.auto_awesome_outlined, size: 18, color: p.ink3),
//           const SizedBox(width: 12),
//           Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(t.transitionRecord,
//                   style: pvManrope(
//                       fontSize: 13.5,
//                       fontWeight: FontWeight.w700,
//                       color: p.ink1)),
//               const SizedBox(height: 2),
//               Text(t.transitionRecordBody,
//                   style:
//                       pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3)),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
// }

/// The estimates disclaimer, in this palette.
class _HomeDisclaimer extends StatelessWidget {
  const _HomeDisclaimer({required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
        const SizedBox(width: 9),
        Expanded(
          child: Text(TtcS.current().estimatesDisclaimer,
              style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3)),
        ),
      ]);
}

/// The daily ritual — done from here, not merely linked to.
///
/// ⚠️ TWO TAP TARGETS PER ROW, AND THAT IS THE DESIGN. The tick completes; the
/// row opens the ritual at that part. Completing must never require reading
/// first — a woman who already knows what "today's breath" means should not
/// have to open a page to say she did it. V1 makes the same split for the same
/// reason.
///
/// ⚠️ ITS OWN `ListenableBuilder`. The page's top-level builder listens to
/// `TtcStore` and `TtcLang` only, so a tick would have changed the store and
/// repainted nothing. Scoping the listener to this card also means ticking one
/// item does not rebuild the doors, the reads and the journal.
// ⚠️ SUPERSEDED 2026-09-16 by `_SanskarCards`. This card carried the 0/5
// counter and the streak; both were refused by the user on the same grounds
// the Grow feature refused a streak. Completing from the home — the parity
// invariant — survives in the Done pill. Kept for revert.
// ignore: unused_element
class _RitualCardV3 extends StatelessWidget {
  const _RitualCardV3(
      {required this.p, required this.hinglish, required this.chapter});

  final V2Palette p;
  final bool hinglish;
  final TtcChapter chapter;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final items = ttcRituals[chapter] ?? const <TtcRitualItem>[];

    return ListenableBuilder(
      listenable: TtcRitualStore.instance,
      builder: (context, _) {
        final store = TtcRitualStore.instance;
        final done = store.completedToday();
        final streak = store.streak();

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 6),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(t.dailyRitualBody,
                    style:
                        pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('$done/${store.total}',
                    style: pvFraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                        color: p.action)),
                // ⚠️ A STREAK WITH NOTHING ATTACHED TO IT. No colour, no
                // warning, no "you lost it" state anywhere in the product —
                // this is the stage built to remove pressure, and a streak
                // that can be broken is the commonest way an app puts it back.
                if (streak > 0)
                  Text(t.dayStreak(streak),
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink3)),
              ]),
            ]),
            const SizedBox(height: 14),
            for (var i = 0; i < items.length; i++)
              _RitualRow(
                p: p,
                hinglish: hinglish,
                item: items[i],
                done: store.isDone(items[i].part),
                last: i == items.length - 1,
                onToggle: () => TtcRitualStore.instance.toggle(items[i].part),
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TtcRitualScreen(chapter: chapter, focus: items[i].part),
                    settings: const RouteSettings(name: 'ttc/ritual'),
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }
}

// Superseded with `_RitualCardV3`. Kept for revert.
// ignore: unused_element
class _RitualRow extends StatelessWidget {
  const _RitualRow({
    required this.p,
    required this.hinglish,
    required this.item,
    required this.done,
    required this.last,
    required this.onToggle,
    required this.onOpen,
  });

  final V2Palette p;
  final bool hinglish;
  final TtcRitualItem item;
  final bool done;
  final bool last;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        margin: EdgeInsets.only(bottom: last ? 0 : 12),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: p.line)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              // Generous around a 22px circle: this is the smallest target on
              // the home and the one most often tapped one-handed.
              padding: const EdgeInsets.only(right: 12, top: 1, bottom: 4),
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? p.action : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: done ? p.action : p.line, width: 1.6),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),
            ),
          ),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.part.title(hinglish),
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink1)),
              const SizedBox(height: 2),
              Text(item.text(hinglish),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
        ]),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  The 2026-09-16 reshape — the "TTC V3 Home" Claude Design, applied below the
//  doors. Built first straight from the parenting widgets, then brought to the
//  design the user had made in the meantime; the two agreed on every section
//  and differed on the details below, which are now the design's.
// -----------------------------------------------------------------------------

/// A small uppercase format chip, sized to its word wherever it is placed.
/// Same widget as parenting's, including the `widthFactor` fix.
// Unreached since the reads became rows (2026-09-27); kept for revert.
// ignore: unused_element
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.p});

  final String label;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3)),
        ),
      );
}

/// The Sanskar section as pregnancy V3 draws its practice: a full-bleed
/// photograph with the name and one line on it, and the first of the five
/// rows lifting onto the band. No explainer card — the review: "i dont need a
/// separate card just for so much text, looks bland". What the section is
/// for is one sentence on the photograph; what it asks is the five rows.
///
/// Mirrors `V3GarbhBlock` (v2/v3_garbh.dart) in geometry — 172dp band, a
/// 22dp overlap, the same dark scrim, the same gold eyebrow — so the two
/// stages' practices are visibly the same idea. It is not that widget because
/// that one takes `HomeDay` and pillar rows; the shape is shared, the binding
/// differs.
///
/// ⚠️ THE PHOTOGRAPH IS THE MIND & BODY DOOR'S. Reused rather than a new
/// Unsplash id picked without seeing it: that door has been walked on a phone
/// with this picture, so it is known to load and known to be a calm figure
/// rather than a surprise. `errorBuilder` paints the dark ground if it ever
/// does not arrive, and the type stays readable on that.
class _SanskarBlock extends StatelessWidget {
  const _SanskarBlock(
      {required this.p, required this.hinglish, required this.chapter});

  final V2Palette p;
  final bool hinglish;
  final TtcChapter chapter;

  static const double _band = 196;
  static const double _overlap = 22;
  static const String _image =
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=900&h=520&fit=crop';

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    return Stack(clipBehavior: Clip.none, children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: _band,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(_image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: const Color(0xFF201C24))),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0x40000000), Color(0xD9000000)],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: _overlap + 16,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((hinglish ? 'Roz ka abhyaas' : 'Practice').toUpperCase(),
                      style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          color: const Color(0xFFF0C078))),
                  const SizedBox(height: 7),
                  Text(t.sanskarTitle,
                      style: pvFraunces(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          letterSpacing: -0.55,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  // The one line. On the photograph, not in a card of its own.
                  Text(t.sanskarBody,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.white.withValues(alpha: 0.86))),
                ]),
          ),
          // ⚠️ NO "i" (launch sanity H15, 2026-09-28). It promised an
          // explanation and opened the same ritual page every card opens:
          // two ways to one place, one of them mislabelled. The name is
          // already glossed in the line on the photograph ("Ayurveda calls
          // this Garbhadhana Sanskar"), so the button did not earn its
          // place. Kept for revert:
          // Positioned(
          //   right: 16,
          //   top: 14,
          //   child: InkWell(
          //     onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          //       builder: (_) => TtcRitualScreen(chapter: chapter),
          //       settings: const RouteSettings(name: 'ttc/ritual'),
          //     )),
          //     customBorder: const CircleBorder(),
          //     child: Container(
          //       width: 26,
          //       height: 26,
          //       alignment: Alignment.center,
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         border: Border.all(
          //             color: Colors.white.withValues(alpha: 0.55)),
          //       ),
          //       child: Text('i',
          //           style: pvFraunces(
          //               fontSize: 13,
          //               fontStyle: FontStyle.italic,
          //               color: Colors.white)),
          //     ),
          //   ),
          // ),
        ]),
      ),
      // The rows, the first lifting onto the band.
      Padding(
        padding: const EdgeInsets.only(top: _band - _overlap),
        child: _SanskarCards(p: p, hinglish: hinglish, chapter: chapter),
      ),
    ]);
  }
}

/// The five parts of the day's Sanskar, one row-card each, plus the footer.
///
/// ⚠️ ITS OWN `ListenableBuilder`, for the reason `_RitualCardV3` gave: the
/// page's top-level builder does not listen to `TtcRitualStore`, so a tick
/// would change the store and repaint nothing — and scoping the listener here
/// means ticking one part does not rebuild the doors, the reads and the
/// journal.
class _SanskarCards extends StatelessWidget {
  const _SanskarCards(
      {required this.p, required this.hinglish, required this.chapter});

  final V2Palette p;
  final bool hinglish;
  final TtcChapter chapter;

  static IconData _icon(TtcRitualPart part) => switch (part) {
        TtcRitualPart.reflection => Icons.menu_book_outlined,
        TtcRitualPart.breath => Icons.air_rounded,
        TtcRitualPart.conversation => Icons.people_outline_rounded,
        TtcRitualPart.gratitude => Icons.favorite_border_rounded,
        TtcRitualPart.action => Icons.handyman_outlined,
      };

  // The design's hues, part by part. Since 2026-09-28 they live in
  // `ttcRitualPartHue` (ttc_practice_card_parts.dart), so the ritual page
  // paints each part the colour of the card she tapped here. Same numbers.
  // Kept for revert:
  //   TtcRitualPart.reflection => 42, breath => 104, conversation => 268,
  //   gratitude => 344, action => 26
  static double _hue(TtcRitualPart part) => ttcRitualPartHue(part);

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    // One picker (launch sanity MB18, 2026-09-28): the breath part is Mind &
    // body › Today's breath. Kept for revert:
    //   final items = ttcRituals[chapter] ?? const <TtcRitualItem>[];
    final items = ttcSanskarItems(chapter);
    return ListenableBuilder(
      listenable: TtcRitualStore.instance,
      builder: (context, _) {
        final store = TtcRitualStore.instance;
        final allDone =
            items.isNotEmpty && items.every((i) => store.isDone(i.part));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final item in items) ...[
            _pad(_SanskarCard(
              p: p,
              hinglish: hinglish,
              item: item,
              icon: _icon(item.part),
              hue: _hue(item.part),
              done: store.isDone(item.part),
              onToggle: () => store.toggle(item.part),
              onOpen: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      TtcRitualScreen(chapter: chapter, focus: item.part),
                  settings: const RouteSettings(name: 'ttc/ritual'),
                ),
              ),
            )),
            const SizedBox(height: 12),
          ],
          // No count, no streak. One line about tomorrow.
          _pad(Text(allDone ? t.sanskarFooterAllDone : t.sanskarFooter,
              style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2))),
        ]);
      },
    );
  }
}

/// One part of the Sanskar, in the design's row: a tinted mark, the part's
/// name and its one line, and the Done pill on the RIGHT. Done stays on the
/// page, dimmed, until tomorrow.
///
/// ⚠️ TWO TAP TARGETS, AND THAT IS THE DESIGN — carried over from the row it
/// replaces. The pill completes; the row body opens the ritual at that part.
/// Completing must never require reading first. "Done today" is itself a tap
/// target that un-does, because the store allows it and V1 allows it; a tick
/// that cannot be taken back is a worse control than one that can.
class _SanskarCard extends StatelessWidget {
  const _SanskarCard({
    required this.p,
    required this.hinglish,
    required this.item,
    required this.icon,
    required this.hue,
    required this.done,
    required this.onToggle,
    required this.onOpen,
  });

  final V2Palette p;
  final bool hinglish;
  final TtcRitualItem item;
  final IconData icon;
  final double hue;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  // ⚠️ REDRAWN AS THE PRACTICE CARD FAMILY (2026-09-28). The user, after the
  // Mind & body Today cards were fixed: "do this Headspace thing for ALL cards
  // like this ... especially Preconception Sanskar". The row this replaces
  // had an icon well, a 16pt title, a 12.5 body and an outlined "Done" pill on
  // the right squeezing the words into a narrow column; three widths of text
  // and two edges. Now it is the same object as `_PracticeBlock`: the part's
  // own tint (the icon well's colour, now the card's), the title with "Done
  // today" as a chip beside it, today's words as the body, and one ink pill
  // under them. Headspace's Today list and its practice card
  // (https://mobbin.com/screens/efc82d96-660f-4e91-bff9-1f3d083c34eb,
  // https://mobbin.com/screens/d05b1798-9389-4073-999b-693b84cca19e).
  //
  // ⚠️ STILL TWO TAP TARGETS, the rule above: the card opens the ritual at
  // this part, the pill completes. Done is taken back with "Mark not done"
  // where the pill was, so the tick still goes both ways without a hidden tap
  // on a chip.
  // The old row is `_buildRow` below, kept for revert.
  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final tint = v2BlockTint(hue, p);
    return Container(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(kTtcCardRadius),
        // The first card lifts onto the photograph; the shadow is what makes
        // that read as depth. All five carry it so the column is one thing.
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: kTtcCardPad,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The chip sits beside the title rather than on a row of its
                  // own, so ticking a part does not push the card taller.
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: done ? 0.62 : 1,
                        child: Text(item.part.title(hinglish),
                            style: ttcCardTitle(p)),
                      ),
                    ),
                    if (done) ...[
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: TtcCardChip.done(t.sanskarDoneToday, tint),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  // The thing itself, not what it is for (2026-09-27): today's
                  // thought, question or step, so she can do it here.
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: done ? 0.62 : 1,
                    child: Text(item.text(hinglish),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: ttcCardBody(p)),
                  ),
                  const SizedBox(height: 16),
                  // Kept for revert (2026-09-28): the label was
                  // `t.sanskarDone` ("Done"), which on a filled button reads as
                  // a state. The ritual page's own words for the same act.
                  if (done)
                    TtcQuietPill(
                        label: 'Mark not done',
                        icon: Icons.undo_rounded,
                        onTap: onToggle)
                  else
                    TtcInkPill(
                        label: t.ritualMarkDone,
                        icon: Icons.check_rounded,
                        onTap: onToggle),
                ]),
          ),
        ),
      ),
    );
  }

  // Kept for revert (2026-09-28): the row card with the icon well and the
  // Done pill on the right. Nothing calls it.
  // ignore: unused_element
  Widget _buildRow(BuildContext context) {
    final t = TtcS.current();
    // ⚠️ THE DIM IS ON THE CONTENTS, NOT THE CARD. Dimming the whole card
    // made its white surface translucent, and the first card sits on the
    // photograph — on the phone the band showed through "Done today". The
    // surface stays opaque; only what is on it fades.
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
        // The first row lifts onto the photograph; the shadow is what makes
        // that read as depth rather than as a card cut off by a picture.
        // All five carry it so the column is one thing.
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: done ? 0.62 : 1,
        child: Row(children: [
          Expanded(
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(12),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: v2BlockTint(hue, p),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 21, color: p.ink1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.part.title(hinglish),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvFraunces(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                letterSpacing: -0.3,
                                color: p.ink1)),
                        const SizedBox(height: 3),
                        // ⚠️ THE THING ITSELF, NOT WHAT IT IS FOR (2026-09-27,
                        // the user's simplicity pass). "One small thought, to
                        // read slowly" beside a Done button left her asking
                        // what the thought was. The card shows today's
                        // thought, question or step, so she can do it here and
                        // tap Done. Kept for revert: item.part.why(hinglish),
                        // two lines.
                        Text(item.text(hinglish),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 12.5, height: 1.4, color: p.ink2)),
                      ]),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          if (done)
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 34,
                padding: const EdgeInsets.fromLTRB(6, 0, 12, 0),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0xFF2E9E6B), shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(t.sanskarDoneToday,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: p.ink2)),
                ]),
              ),
            )
          else
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: p.action.withValues(alpha: 0.42)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_rounded, size: 14, color: p.action),
                  const SizedBox(width: 6),
                  Text(t.sanskarDone,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: p.action)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

/// The chapter card with its three tabs ON it, as pills: Me · Us · What's
/// next, each opening the chapter reader at that tab. Tapping the card body
/// opens the reader at its default.
// Unreached since 2026-09-27 (the user's simplicity pass); kept for revert.
// ignore: unused_element
class _ChapterCard extends StatelessWidget {
  const _ChapterCard(
      {required this.p,
      required this.hinglish,
      required this.chapter,
      required this.onOpen});

  final V2Palette p;
  final bool hinglish;
  final TtcChapter chapter;
  final VoidCallback onOpen;

  Widget _pill(BuildContext context, String label, TtcChapterTab tab,
          {bool lead = false}) =>
      InkWell(
        onTap: () => openTtcChapter(context, chapter, tab: tab),
        borderRadius: BorderRadius.circular(999),
        // ⚠️ NO `alignment` ON A CONTAINER INSIDE A WRAP (launch walk,
        // 2026-09-27): a Container with an alignment expands to the width it
        // is offered, so the three pills each filled the line and stacked as
        // three full-width buttons. Sized by padding instead. Kept for revert:
        //   height: 30, padding: symmetric(horizontal: 13),
        //   alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: lead
                ? p.action.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border.all(
                color: lead ? p.action.withValues(alpha: 0.42) : p.line),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: lead ? p.action : p.ink2)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: v2BlockTint(_chapterHue(chapter), p),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.menu_book_outlined, size: 22, color: p.ink1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chapter.title(hinglish),
                        style: pvFraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.3,
                            color: p.ink1)),
                    const SizedBox(height: 4),
                    // ⚠️ WHAT THIS PART OF THE MONTH IS, NOT WHAT COMES
                    // NEXT (2026-09-27). "Next: The Waiting Days, once
                    // ovulation has passed" explained one invented name with
                    // another. Kept for revert:
                    //   Text(chapter.nextUp(hinglish), ...)
                    Text(ttcChapterPlainPart(chapter),
                        style: pvManrope(
                            fontSize: 12.5, height: 1.4, color: p.ink2)),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        // "Me" leads because it is the reader's default tab — the one the
        // card body opens — and the pill says so before she taps.
        Wrap(spacing: 8, runSpacing: 8, children: [
          // Who each tab is for, said plainly (2026-09-27). "Me" and "Us"
          // on a card that also names a chapter read as labels, not doors.
          // Kept for revert: t.shortcutMe, t.shortcutUs, t.shortcutNext.
          _pill(context, 'For you', TtcChapterTab.me, lead: true),
          _pill(context, 'For you both', TtcChapterTab.us),
          _pill(context, t.shortcutNext, TtcChapterTab.next),
        ]),
      ]),
    );
  }
}

/// "Keep something from today": the design's card — a tinted well with a
/// pen beside the prompt, then four entry chips across the card, and "Open
/// the journal" under it.
// Unreached since 2026-09-27 (the user's simplicity pass); kept for revert.
// ignore: unused_element
class _JournalInvite extends StatelessWidget {
  const _JournalInvite({
    required this.p,
    required this.hinglish,
    required this.onWrite,
    required this.onFelt,
    required this.onLog,
    required this.onUs,
    required this.onOpenAll,
  });

  final V2Palette p;
  final bool hinglish;
  final VoidCallback onWrite;
  final VoidCallback onFelt;
  final VoidCallback onLog;
  final VoidCallback onUs;
  final VoidCallback onOpenAll;

  Widget _chip(String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        // No `alignment:` on the Container — inside a Wrap it would fill the
        // run. The parenting card learned this on a phone.
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            border: Border.all(color: p.line),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(label,
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink1)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  InkWell(
                    onTap: onWrite,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: v2BlockTint(268, p),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.edit_outlined, size: 28, color: p.ink1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                        hinglish
                            ? 'Aaj kaisa laga, kuch jo dhyaan mein aaya, ya '
                                'aap dono ke liye ek note.'
                            // Matches the three chips below (2026-09-27).
                            // Kept for revert: 'How today felt, something you
                            // noticed, or a note for the two of you.'
                            : 'Write how today felt, something you noticed, '
                                'or a question for your doctor.',
                        style: pvManrope(
                            fontSize: 13, height: 1.5, color: p.ink2)),
                  ),
                ]),
                const SizedBox(height: 16),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  // ⚠️ THREE CHIPS, EACH NAMING WHAT IT WRITES (2026-09-27).
                  // "Write" wrote a memory without saying so, and "Log for
                  // today" opened the symptom logger: not journal writing, and
                  // already the Symptoms button at the top of the home. Kept
                  // for revert:
                  //   _chip(hinglish ? 'Likhein' : 'Write', onWrite),
                  //   _chip(hinglish ? 'Aaj ka log' : 'Log for today', onLog),
                  _chip(hinglish ? 'Likhein' : 'Something you noticed', onWrite),
                  _chip(hinglish ? 'Aaj kaisa laga' : 'How today felt', onFelt),
                  // Kept for revert: 'The two of you' (it opened his side).
                  _chip(hinglish ? 'Doctor ke liye' : 'For the doctor', onUs),
                ]),
              ]),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onOpenAll,
          borderRadius: BorderRadius.circular(8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(hinglish ? 'Journal kholein' : 'Open the journal',
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink2)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 16, color: p.ink3),
          ]),
        ),
      ]);
}

/// The four people, one card each, each opening ITS consultation.
///
/// ⚠️ ROLES, NOT NAMES. `TtcOffering.expertId` points at ids
/// ('ttc_dr_gynae', …) that no record in the app resolves to a person yet —
/// the catalogue has thirteen offerings and no expert table. So the card says
/// what the person is, which is true, rather than who, which would be
/// invented. The circle is a person mark for the same reason: the design
/// draws it as the place a photograph goes, and there is no photograph yet.
///
/// ⚠️ NO PRICE. This section closes the page on a person, not a rate; the
/// offering page carries the price, one tap in.
class _ExpertRail extends StatelessWidget {
  const _ExpertRail({required this.p, required this.hinglish});

  final V2Palette p;
  final bool hinglish;

  // ⚠️ PEOPLE, NOT ROLES (TTC launch walk, 2026-09-27; the user: "put them
  // for now", from the expert roster). The rail showed four bare roles with a
  // grey person glyph. Now the roster name, a verified tick, what she does and
  // the price, the same people the consults page lists. Kept for revert:
  //   ('ttc_consult_gynae', 'Gynaecologist', 'Gynaecologist', 206),
  //   ('ttc_consult_fertility', 'Fertility specialist', 'Fertility specialist', 268),
  //   ('ttc_nutrition_consult', 'Nutritionist', 'Nutritionist', 104),
  //   ('ttc_psych_consult', 'Psychologist', 'Psychologist', 344),
  // ⚠️ THE ROSTER'S OWN TITLES (2026-09-27, build 11): the home said
  // "Gynaecologist" and "Fertility specialist" where the consults page, from
  // the same roster, says "IVF gynaecologist". One person, one title.
  // Kept for revert: 'Gynaecologist', 'Fertility specialist', 'Nutritionist',
  // 'Psychologist'.
  static const List<(String, String, String, double)> _experts = [
    ('ttc_consult_gynae', 'Dr Ruchika Sood', 'IVF gynaecologist', 206),
    ('ttc_consult_fertility', 'Dr Surbhi Sharma',
        'IVF gynaecologist, Bloom IVF', 268),
    ('ttc_nutrition_consult', 'Akanksha Srivastava',
        'Maternal and child nutritionist', 104),
    ('ttc_psych_consult', 'Parmeshwari', 'Clinical psychologist', 344),
  ];

  static String _initials(String name) => name
      .replaceAll('Dr ', '')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join();

  @override
  Widget build(BuildContext context) => SizedBox(
        // H9 (2026-09-28): room for a two-line name and a video line. Kept
        // for revert: height: 160.
        height: 204,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: _experts.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final (id, name, role, hue) = _experts[i];
            final offering = ttcOfferingById(id);
            final price = offering == null
                ? null
                : '₹${(offering.priceMinor ~/ 100).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
            return SizedBox(
              width: 152,
              child: InkWell(
                onTap: () {
                  if (offering == null) {
                    openTtcSurface(context, 'ttc_prepare');
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: RouteSettings(name: 'ttc/prepare/$id'),
                    builder: (_) => TtcOfferingScreen(offering: offering),
                  ));
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: p.line),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: v2BlockTint(hue, p),
                            shape: BoxShape.circle,
                          ),
                          // Kept for revert: Icon(Icons.person_outline_rounded,
                          //     size: 26, color: p.ink1),
                          child: Text(_initials(name),
                              style: pvManrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: p.ink1)),
                        ),
                        const SizedBox(height: 10),
                        // ⚠️ A NAME IS NEVER CUT (launch sanity H9,
                        // 2026-09-28). "Akanksha Srivasta…" and "nutritionist
                        // · ₹499 · on vi…" on a trust surface looked careless.
                        // The name wraps to two lines with the tick after its
                        // last word, the role gets its own two lines, and
                        // price and video share a line with a video icon.
                        // Kept for revert: the name in a one-line Row with
                        // the tick, then '$role · $price · on video' in two.
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(text: '$name '),
                            // ⚠️ NO TICK UNTIL A REGISTRATION CHECK IS
                            // RECORDED (the user, 2026-09-28): the expert's
                            // own page says "A named clinician" until then,
                            // and a tick here would claim what that page
                            // declines to. Kept for revert: the tick always.
                            if (kTtcRegistrationChecksRecorded)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Icon(Icons.verified_rounded,
                                    size: 14, color: p.action),
                              ),
                          ]),
                          key: ValueKey('ttc_expert_rail_name_$id'),
                          maxLines: 2,
                          style: pvFraunces(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              letterSpacing: -0.3,
                              color: p.ink1),
                        ),
                        const SizedBox(height: 4),
                        Text(role,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 12.5, height: 1.35, color: p.ink2)),
                        const Spacer(),
                        Row(children: [
                          Icon(Icons.videocam_outlined,
                              size: 15, color: p.ink2),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                                price == null ? 'On video' : '$price · on video',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pvManrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: p.ink1)),
                          ),
                        ]),
                      ]),
                ),
              ),
            );
          },
        ),
      );
}

/// A wide surface card with a label and a chevron — "See everyone".
// Unreached since 2026-09-27 (the user's simplicity pass); kept for revert.
// ignore: unused_element
class _SeeAllRow extends StatelessWidget {
  const _SeeAllRow(
      // ignore: unused_element_parameter
      {super.key, required this.label, required this.p, required this.onTap});

  final String label;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink1)),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
          ]),
        ),
      );
}

/// The home's journal (2026-09-27): three drawn tiles in one card, one per
/// kind of writing, in the pregnancy home's shape (`V3JournalSection`'s tile
/// look), and one honest line on who reads it. The way to everything written
/// is the section heading's "See all", not a full-width row.
class _TtcJournalTiles extends StatelessWidget {
  const _TtcJournalTiles({
    required this.p,
    required this.onNoticed,
    required this.onFelt,
    required this.onDoctor,
  });

  final V2Palette p;
  final VoidCallback onNoticed;
  final VoidCallback onFelt;
  final VoidCallback onDoctor;

  Widget _tile(String key, String label, V3DailyMark mark, double hue,
          VoidCallback onTap) =>
      Expanded(
        child: Semantics(
          button: true,
          label: label.replaceAll('\n', ' '),
          excludeSemantics: true,
          onTap: onTap,
          child: InkWell(
            key: ValueKey(key),
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  height: 58,
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: v2BlockTint(hue, p),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: V3DailyArt(mark: mark, tint: v2BlockTint(hue, p)),
                ),
                const SizedBox(height: 8),
                Text(label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: p.ink1)),
              ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // The journal's own name for this kind (2026-09-27): the writer
            // calls it "A memory". Kept for revert: 'Something\nyou noticed'.
            _tile('ttc_home_journal_noticed', 'A memory',
                V3DailyMark.memory, 42, onNoticed),
            const SizedBox(width: 8),
            _tile('ttc_home_journal_felt', 'How today\nfelt',
                V3DailyMark.note, 344, onFelt),
            const SizedBox(width: 8),
            _tile('ttc_home_journal_doctor', 'For the\ndoctor',
                V3DailyMark.capsule, 206, onDoctor),
          ]),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(children: [
              Icon(Icons.people_outline_rounded, size: 16, color: p.ink3),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Your partner can read what you write here.',
                    style: pvManrope(
                        fontSize: 12.5, height: 1.4, color: p.ink3)),
              ),
            ]),
          ),
        ]),
      );
}

/// One read on the home, as a row (2026-09-27): 74dp photo or the door's
/// drawn page mark, the title in the serif, "TOPIC · N MIN READ" under it.
/// The pregnancy home's row shape (`V3ReadRow`), fed by a `PvRead`.
/// The door a TTC read belongs to, by its topic line (the same match the
/// home's read rows always used).
Bracket? _ttcReadDoor(PvRead read) => [
      for (final b in kTtcBrackets)
        if (b.label.en == read.kicker.en) b
    ].firstOrNull;

/// A drawn mark for a read by what it is about, for when its door's mark is
/// already on the list (H10). Keyword-led, so it says something true about
/// the read rather than being a random picture.
IntentMark _ttcReadSubjectMark(PvRead read) {
  final t = '${read.title.en} ${read.kicker.en}'.toLowerCase();
  bool has(List<String> ws) => ws.any(t.contains);
  if (has(['sperm', 'semen', 'his ', 'male', 'men '])) return IntentMark.spermMark;
  if (has(['temperature', 'bbt', 'thermometer'])) return IntentMark.thermoMark;
  if (has(['mucus', 'discharge', 'lubric'])) return IntentMark.dropMark;
  if (has(['test', 'strip', 'kit'])) return IntentMark.checkMark;
  if (has(['ovulat', 'cycle', 'period', 'window', 'fertile'])) {
    return IntentMark.cycleRing;
  }
  if (has(['food', 'eat', 'diet', 'meal'])) return IntentMark.plate;
  if (has(['folic', 'supplement', 'vitamin', 'tablet', 'pill'])) {
    return IntentMark.pillMark;
  }
  if (has(['stress', 'mood', 'feel', 'worry', 'calm', 'mind'])) {
    return IntentMark.moodArc;
  }
  if (has(['sleep'])) return IntentMark.sleepMark;
  if (has(['doctor', 'clinic', 'scan'])) return IntentMark.askDoctor;
  return read.title.en.trim().endsWith('?')
      ? IntentMark.questionMark
      : IntentMark.bookMark;
}

/// Each read with the mark to draw, or null to draw its door's own mark. A
/// read with a photograph needs neither. A door mark already drawn higher up
/// the list is replaced by the read's subject mark, and a subject mark never
/// repeats either; the last resort walks a short list of reading marks.
/// Pure, so `test/ttc_home_read_marks_test.dart` holds the rule.
List<(PvRead, IntentMark?)> ttcHomeReadMarks(List<PvRead> reads) {
  final usedDoors = <String>{};
  final usedMarks = <IntentMark>{};
  final out = <(PvRead, IntentMark?)>[];
  for (final r in reads) {
    if (readImageFor(r.id, own: r.imageUrl) != null) {
      out.add((r, null));
      continue;
    }
    final door = _ttcReadDoor(r);
    final doorMark = door == null ? null : bracketMarkFor(door.id);
    if (doorMark != null && usedDoors.add(door!.id)) {
      out.add((r, null));
      continue;
    }
    var m = doorMark == null ? IntentMark.pageMark : _ttcReadSubjectMark(r);
    if (usedMarks.contains(m)) {
      m = const [
        IntentMark.bookMark,
        IntentMark.questionMark,
        IntentMark.lampMark,
        IntentMark.compassMark,
        IntentMark.pageMark,
      ].firstWhere((x) => !usedMarks.contains(x),
          orElse: () => IntentMark.pageMark);
    }
    usedMarks.add(m);
    out.add((r, m));
  }
  return out;
}

class _ReadRow extends StatelessWidget {
  const _ReadRow({
    super.key,
    required this.read,
    required this.p,
    required this.hinglish,
    required this.onTap,
    this.mark,
  });

  final PvRead read;
  final V2Palette p;
  final bool hinglish;
  final VoidCallback onTap;

  /// A drawn mark in place of the door's own (H10), when the door's mark is
  /// already higher up the list.
  final IntentMark? mark;

  @override
  Widget build(BuildContext context) {
    final topic = read.kicker.en.trim();
    // ⚠️ THE DOOR'S OWN DRAWING WHEN THERE IS NO PHOTO (2026-09-27, build 11 on
    // the phone): three identical pink page icons said nothing. A read's
    // topic is its door, so it wears that door's mark and tint (the moon for
    // Fertile window), the same mark the door grid above shows.
    final door = [
      for (final b in kTtcBrackets)
        if (b.label.en == read.kicker.en) b
    ].firstOrNull;
    final doorMark = door == null ? null : bracketMarkFor(door.id);
    final meta = [
      if (topic.isNotEmpty) topic.toUpperCase(),
      '${read.minutes} MIN READ',
    ].join(' · ');
    return Semantics(
      button: true,
      label: '${read.title.en}, ${read.minutes} minute read',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PvMarkWell(
                p: p,
                hue: door?.hue ?? read.hue,
                size: 74,
                photo: readImageFor(read.id, own: read.imageUrl),
                bracket: mark != null ? null : doorMark,
                mark: mark ?? (doorMark == null ? IntentMark.pageMark : null)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hinglish ? read.title.hi : read.title.en,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 16,
                            letterSpacing: -0.4,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            color: p.ink1)),
                    const SizedBox(height: 5),
                    Text(meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: p.ink3)),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
