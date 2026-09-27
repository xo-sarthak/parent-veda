// =============================================================================
//  One date, one answer — every TTC surface agrees about where she is
// -----------------------------------------------------------------------------
//  The requirement, in the user's words: "The whole trying-to-conceive side
//  must be personalised to the user by the date of her cycle, and CONSISTENT.
//  What is displayed must never be confusing: the hero section and today's
//  insights must match the date of her cycle; age must be handled the same
//  everywhere."
//
//  `ttcDayContext` (lib/ttc/ttc_day_context.dart) is the one resolver. This
//  file walks a matrix of histories, every day of a cycle plus the late days,
//  and asserts that each surface which shows a date-dependent fact says the
//  same thing the resolver says:
//
//    the hero line · the insights phase · the reads · the calendar day facts
//    and its due line · the window door's dates · the "late" and "window"
//    messages · the "Should I test?" chat · the temperature chart's shading ·
//    the door order
//
//  and that a clinic-owned cycle gets no phase-based prediction on any of
//  them.
//
//  EXTENDED 2026-09-26 for the user's four decisions, each also held on its
//  own at the bottom: (1) a clinic owns the timing only with real clinic
//  dates in the treatment tracker, never on a pathway label alone; (2) a
//  first cycle is predicted from her stated length, else 28 days, and the
//  chat names the same date; (3) one definition of irregular, more than 7
//  days' spread, everywhere; (4) earlier cycles show their fertile days,
//  worked out looking back from their own length, identically on the
//  calendar, the hero, the insights, the report and the companion. Then it walks the strip: selecting another date moves the hero, the
//  insights and their titles together.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/chats/ttc_should_test_chat.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart'
    show ttcDoorOrderedGroups, kTtcIvfBracketId, kTtcAgeGroupId;
import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_daily_insights.dart';
import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/services/journey_state.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_content_prefs.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_day_context.dart';
import 'package:parentveda/ttc/ttc_fertile_window.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_home_hero.dart';
import 'package:parentveda/ttc/ttc_home_prefs.dart';
import 'package:parentveda/ttc/ttc_home_situation.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_logging_extras.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/ttc/ttc_period_due.dart';
import 'package:parentveda/ttc/ttc_phase_reads.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_content.dart';
import 'package:parentveda/ttc/ttc_treatment_round.dart';
import 'package:parentveda/screens/ttc/ttc_round_home_card.dart';
import 'package:parentveda/screens/ttc/ttc_round_strings.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

/// One history to walk.
class _Scenario {
  const _Scenario(this.name, this.lengths,
      {this.path = TtcPath.natural,
      this.monitored,
      this.logged = true,
      this.clinicDates = false,
      this.stated});

  final String name;

  /// Completed cycle lengths, oldest first. The current cycle follows them.
  final List<int> lengths;
  final TtcPath path;
  final bool? monitored;

  /// False = nothing logged at all.
  final bool logged;

  /// True = her clinic's dates for the CURRENT cycle are in the treatment
  /// tracker (a stimulation start on cycle day 2 and a blood test on day 30).
  ///
  /// ⚠️ DECIDED 2026-09-26: a cycle is clinic-owned only when the tracker
  /// holds real dates for it, never on the pathway label alone. So every
  /// clinic scenario below comes in two forms, the label with dates (the
  /// clinic everywhere) and the label alone (her own cycle everywhere).
  final bool clinicDates;

  /// Her stated usual cycle length, read on a first cycle only.
  final int? stated;
}

const _scenarios = <_Scenario>[
  _Scenario('regular 28-day history', [28, 28]),
  _Scenario('32-day history', [32, 32]),
  _Scenario('first cycle only', []),
  // 2026-09-26, first-cycle decision: her stated length, not 28.
  _Scenario('first cycle, stated 33 days', [], stated: 33),
  _Scenario('irregular history', [24, 36]),
  // 2026-09-26, one definition of irregular (more than 7 days' spread): a
  // spread of exactly 7 is regular, 8 is irregular, on every surface.
  _Scenario('a spread of exactly 7 days', [25, 32]),
  _Scenario('a spread of 8 days', [24, 32]),
  // Earlier cycles of different lengths, so each cycle's look-back window
  // differs from the next (2026-09-26, earlier cycles show their window).
  _Scenario('earlier cycles of 26 and 33 days', [26, 33]),
  // A 58-day gap among two 28s: a period she did not log. The engine refuses.
  _Scenario('a missed log gap', [28, 28, 58]),
  _Scenario('clinic IUI, monitored, with clinic dates', [28, 28],
      path: TtcPath.iui, monitored: true, clinicDates: true),
  _Scenario('clinic IVF, with clinic dates', [28, 28],
      path: TtcPath.ivf, clinicDates: true),
  // The label alone (2026-09-26): her own cycle, top of the screen and cards
  // alike. Before the decision these two were the clinic scenarios above.
  _Scenario('IUI label, monitored, no clinic dates', [28, 28],
      path: TtcPath.iui, monitored: true),
  _Scenario('IVF label, no clinic dates', [28, 28], path: TtcPath.ivf),
  _Scenario('no period logged', [], logged: false),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime ago(int days) => DateTime(today.year, today.month, today.day - days);
  DateTime plus(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

  setUpAll(() async {
    CycleStore.instance;
    TtcStore.instance;
    LifeStageStore.instance;
    TtcLogStore.instance;
    TtcTreatmentStore.instance;
    await TtcFertilityHelpStore.instance.load();
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  });

  Future<void> reset() async {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    LifeStageStore.instance
      ..resetForTest()
      ..setStage(LifeStage.tryingToConceive);
    await TtcFertilityHelpStore.instance.reset();
    TtcMessagesStore.instance.resetForTest();
    TtcHomePrefs.instance.resetForTest();
    TtcContentPrefs.instance.resetForTest();
  }

  setUp(reset);

  /// Today becomes cycle day [cd] of the current cycle, after [s]'s history.
  void seed(_Scenario s, int cd) {
    CycleStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcStore.instance.setPath(s.path);
    TtcStore.instance.setStatedCycleLength(s.stated);
    if (s.monitored != null) {
      TtcStore.instance.setClinicMonitors(s.monitored);
      TtcStore.instance.setMedicationControlsOvulation(false);
    }
    if (!s.logged) return;
    final current = ago(cd - 1);
    var at = current;
    final starts = <DateTime>[current];
    for (final len in s.lengths.reversed) {
      at = plus(at, -len);
      starts.add(at);
    }
    for (final d in starts.reversed) {
      CycleStore.instance.logPeriodStart(d);
    }
    if (s.clinicDates) {
      TtcTreatmentStore.instance
        ..setDate(TtcTreatmentStep.stimStart, plus(current, 1))
        ..setDate(TtcTreatmentStep.betaTest, plus(current, 29));
    }
  }

  /// How far to walk: a whole cycle, the due day, and a fortnight past it.
  int walkTo(_Scenario s) =>
      (s.lengths.isEmpty
          ? (s.stated ?? 28)
          : (s.lengths.reduce((a, b) => a + b) / s.lengths.length).round()) +
      16;

  /// [TtcPhase] (the report's and the companion's bands) as a day phase.
  TtcDayPhase dayPhaseOf(TtcPhase p) => switch (p) {
        TtcPhase.period => TtcDayPhase.period,
        TtcPhase.beforeWindow => TtcDayPhase.beforeWindow,
        TtcPhase.fertileWindow => TtcDayPhase.window,
        TtcPhase.afterWindow => TtcDayPhase.waiting,
      };

  /// How many cycles back from the current one [start] opened.
  int cycleIndexOf(DateTime start) {
    final starts = [...CycleStore.instance.periodStarts]..sort();
    final pos = starts.indexWhere((s) =>
        s.year == start.year && s.month == start.month && s.day == start.day);
    return starts.length - 1 - pos;
  }

  const windowStates = {
    TtcHeroState.windowOpensIn,
    TtcHeroState.windowOpen,
    TtcHeroState.windowLastDay,
  };
  const periodCountStates = {
    TtcHeroState.waiting,
    TtcHeroState.periodDue,
    TtcHeroState.periodLate,
    TtcHeroState.periodExpectedBy,
  };

  // ---------------------------------------------------------------------------
  //  The hero and the resolver, for any date
  // ---------------------------------------------------------------------------
  void heroAgrees(DateTime d, String where) {
    final ctx = ttcDayContext(d);
    final line = ttcHomeHeroLine(on: d);
    final why = '$where, ${d.toIso8601String().substring(0, 10)}: hero '
        '${line.state.name}, phase ${ctx.phase.name}';

    switch (line.state) {
      case TtcHeroState.startHere:
        expect(ctx.phase, TtcDayPhase.any, reason: why);
        expect(ctx.cycleStart, isNull, reason: why);
      case TtcHeroState.clinicHolds ||
            TtcHeroState.treatmentToday ||
            TtcHeroState.treatmentSoon ||
            TtcHeroState.treatmentBeta:
        expect(ctx.clinicOwned, isTrue, reason: why);
        expect(ctx.phase, TtcDayPhase.any, reason: why);
        if (line.state == TtcHeroState.clinicHolds) {
          expect(line.days, ctx.cycleDay, reason: why);
        }
      case TtcHeroState.noEstimate:
        expect(ctx.hasWindow, isFalse, reason: why);
        expect(ctx.phase, isIn([TtcDayPhase.any, TtcDayPhase.period]),
            reason: why);
      case TtcHeroState.pastCycle:
        expect(ctx.isPastCycle || ctx.cycleStart == null, isTrue, reason: why);
        // 2026-09-26: an earlier cycle is phased from its own look-back
        // window, and is never late (she logged the period that ended it).
        // Kept for revert: `isIn([TtcDayPhase.any, TtcDayPhase.period])`.
        expect(ctx.phase, isNot(TtcDayPhase.late), reason: why);
        expect(ctx.periodDueOn, isNull, reason: why);
        if (line.days > 0) expect(line.days, ctx.cycleDay, reason: why);
        // The hero names the same look-back window the calendar shades.
        expect(line.windowFrom, ctx.lookingBack ? ctx.windowOpensOn : null,
            reason: '$why: hero window start');
        expect(line.windowTo, ctx.lookingBack ? ctx.windowClosesOn : null,
            reason: '$why: hero window end');
      case TtcHeroState.windowOpensIn:
        expect(ctx.phase, isIn([TtcDayPhase.beforeWindow, TtcDayPhase.period]),
            reason: why);
        expect(line.days, ctx.daysUntilWindow, reason: why);
      case TtcHeroState.windowOpen || TtcHeroState.windowLastDay:
        expect(ctx.inWindow, isTrue, reason: why);
        // A bleed day inside the window reads as her period (rule 4).
        expect(ctx.phase, isIn([TtcDayPhase.window, TtcDayPhase.period]),
            reason: why);
        if (line.state == TtcHeroState.windowOpen) {
          expect(line.days, ctx.windowDaysLeft, reason: why);
        } else {
          expect(ctx.windowDaysLeft, 1, reason: why);
        }
      case TtcHeroState.waiting:
        expect(ctx.phase, TtcDayPhase.waiting, reason: why);
        expect(line.days, -ctx.daysPastDue!, reason: why);
      case TtcHeroState.periodDue:
        expect(ctx.phase, TtcDayPhase.waiting, reason: why);
        expect(ctx.isExpectedPeriodDay, isTrue, reason: why);
      case TtcHeroState.periodExpectedBy:
        expect(ctx.phase, TtcDayPhase.waiting, reason: why);
        // A future day from the due day on (the hero never says "today"
        // about a day that has not come), or a past-due day on a history too
        // thin for "late".
        expect(ctx.daysPastDue,
            greaterThanOrEqualTo(ctx.isFuture ? 0 : 1), reason: why);
        expect(ctx.isFuture || !ctx.lateReliable, isTrue, reason: why);
      case TtcHeroState.periodLate:
        expect(ctx.phase, TtcDayPhase.late, reason: why);
        expect(line.days, ctx.daysPastDue, reason: why);
      // 2026-09-26: a treatment round's steps (docs/TTC-TREATMENT-FLOW.md
      // §3a). Never a phase of ours, never a window, due date or late.
      case TtcHeroState.treatmentGettingReady ||
            TtcHeroState.treatmentStimulation ||
            TtcHeroState.treatmentTrigger ||
            TtcHeroState.treatmentProcedure ||
            TtcHeroState.treatmentEmbryoDays ||
            TtcHeroState.treatmentTransfer ||
            TtcHeroState.treatmentWait ||
            TtcHeroState.treatmentTestDay ||
            TtcHeroState.treatmentResult ||
            TtcHeroState.treatmentBetweenRounds:
        expect(ctx.clinicOwned || ctx.cycleClinicOwned, isTrue, reason: why);
        expect(ctx.phase, TtcDayPhase.any, reason: why);
        expect(ctx.hasWindow, isFalse, reason: why);
        expect(ctx.periodDueOn, isNull, reason: why);
    }

    // An earlier cycle has one hero state, whatever its phase (unless a
    // clinic's date leads, which only happens on a clinic-owned account).
    if (ctx.isPastCycle) {
      if (!ctx.clinicOwned) {
        expect(line.state, TtcHeroState.pastCycle, reason: why);
      }
      return;
    }

    // And the other way round: a phase that is a claim has one hero family.
    switch (ctx.phase) {
      case TtcDayPhase.late:
        expect(line.state, TtcHeroState.periodLate, reason: why);
      case TtcDayPhase.window:
        expect(line.state,
            isIn([TtcHeroState.windowOpen, TtcHeroState.windowLastDay]),
            reason: why);
      case TtcDayPhase.beforeWindow:
        expect(line.state, TtcHeroState.windowOpensIn, reason: why);
      case TtcDayPhase.waiting:
        expect(periodCountStates, contains(line.state), reason: why);
        expect(line.state, isNot(TtcHeroState.periodLate), reason: why);
      case TtcDayPhase.period || TtcDayPhase.any:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  //  Everything else that reads a date, for any date
  // ---------------------------------------------------------------------------
  void surfacesAgree(DateTime d, String where) {
    final ctx = ttcDayContext(d);
    final why = '$where, ${d.toIso8601String().substring(0, 10)}, phase '
        '${ctx.phase.name}';

    // The phase the home's cards and reads are chosen by.
    expect(ttcHomePhaseOn(d), ctx.phase, reason: '$why: home phase');

    // The daily card is one written for that stretch.
    final card = ttcHomeInsightFor(d);
    expect(card.phases, contains(ctx.phase),
        reason: '$why: insight "${card.titleEn}"');

    // The first read is from that stretch's own list, or, while a round
    // holds the day (2026-09-26, §3b), from its step's list.
    final reads = ttcHomeReadIdsFor(d);
    final step = ttcHomeRoundPhaseOn(d);
    if (step != null) {
      expect(ctx.phase, TtcDayPhase.any, reason: '$why: a round day phased');
      expect(kTtcTreatmentPhaseReadIds[step], contains(reads.first),
          reason: '$why: round step ${step.name}, read ${reads.first}');
    } else {
      expect(kTtcPhaseReadIds[ctx.phase], contains(reads.first),
          reason: '$why: read ${reads.first}');
    }

    // The calendar's marks for the same date.
    final facts = ttcFactsFor(d);
    expect(facts.fertility, ctx.fertility, reason: '$why: calendar band');
    expect(
        facts.fertility != null && facts.fertility != FertilityLevel.low,
        ctx.inWindow,
        reason: '$why: calendar shades a different window');
    expect(facts.isExpectedPeriod, ctx.isExpectedPeriodDay,
        reason: '$why: calendar expected period');
    expect(facts.isOvulation, ctx.isOvulationDay, reason: '$why: ovulation');
    expect(facts.lookingBack, ctx.lookingBack,
        reason: '$why: calendar labels a past window differently');
    if (ttcCalendarDueLine(d, facts) != null) {
      expect(ctx.inWindow, isTrue, reason: '$why: due line off the window');
    }

    // The insight rail's own cards for the date.
    final ids = {for (final c in ttcInsightsFor(d)) c.id: c};
    // The band in words stays with the cycle she is in (2026-09-26): an
    // earlier cycle's look-back window is shaded, never graded in a card.
    // Kept for revert: `ctx.fertility != null`.
    expect(ids.containsKey('chance'), ctx.fertility != null && !ctx.lookingBack,
        reason: '$why: chance card');

    // The cycle report and the companion's bands for the cycle this date is
    // in: the same stretch as the resolver, from the same window (the current
    // cycle's estimate, or an earlier cycle's look-back).
    final start = ctx.cycleStart;
    if (start != null) {
      final index = cycleIndexOf(start);
      final report = ttcBuildCycleReport(index: index);
      final rd = report.days.where((x) => x.date == d).firstOrNull;
      if (rd != null) {
        if (ctx.hasWindow) {
          final want = ctx.phase == TtcDayPhase.late
              ? TtcDayPhase.waiting
              : ctx.phase;
          expect(rd.phase == null ? null : dayPhaseOf(rd.phase!), want,
              reason: '$why: report (cycle $index) stretch');
        } else {
          expect(rd.phase, isNull,
              reason: '$why: report (cycle $index) banded a day with no window');
        }
      }
      final spans = ttcCyclePhaseSpans(index: index);
      if (!ctx.hasWindow) {
        expect(spans, isEmpty,
            reason: '$why: companion (cycle $index) banded a cycle with no '
                'window');
      } else {
        final span = spans
            .where((x) =>
                ctx.cycleDay! >= x.firstCycleDay &&
                ctx.cycleDay! <= x.lastCycleDay)
            .firstOrNull;
        if (span != null) {
          final want = ctx.phase == TtcDayPhase.late
              ? TtcDayPhase.waiting
              : ctx.phase;
          expect(dayPhaseOf(span.phase), want,
              reason: '$why: companion (cycle $index) stretch');
        }
      }
    }

    // An earlier cycle: never a due date, never late, and no window at all
    // when her clinic ran it.
    if (ctx.isPastCycle) {
      expect(ctx.periodDueOn, isNull, reason: why);
      expect(ctx.phase, isNot(TtcDayPhase.late), reason: why);
      if (ctx.cycleClinicOwned) {
        expect(ctx.hasWindow, isFalse, reason: why);
        expect(facts.fertility, isNull, reason: why);
      }
    }
    if (ctx.cycleDay != null) {
      expect(ids['cycle_day']?.value, '${ctx.cycleDay}',
          reason: '$why: cycle day card');
    }

    // Clinic cycles: no prediction of any kind.
    //
    // ⚠️ THE CYCLE SHE IS IN, SINCE 2026-09-26 (the treatment flow's resolver
    // decision): an earlier cycle from before any round keeps its look-back
    // window while a round holds this one; an earlier cycle a round ran in is
    // held above (`cycleClinicOwned`). Kept for revert: `if (ctx.clinicOwned)`.
    if (ctx.clinicOwned && !ctx.isPastCycle) {
      expect(ctx.phase, TtcDayPhase.any, reason: why);
      expect(ctx.hasWindow, isFalse, reason: why);
      expect(ctx.periodDueOn, isNull, reason: why);
      expect(facts.fertility, isNull, reason: why);
      expect(facts.isExpectedPeriod, isFalse, reason: why);
      final line = ttcHomeHeroLine(on: d);
      expect(windowStates, isNot(contains(line.state)), reason: why);
      expect(periodCountStates, isNot(contains(line.state)), reason: why);
    }
  }

  // ---------------------------------------------------------------------------
  //  The things that only exist for today
  // ---------------------------------------------------------------------------
  void todayAgrees(_Scenario s, int cd) {
    final ctx = ttcDayContext(today);
    final why = '${s.name}, cycle day $cd, phase ${ctx.phase.name}';

    // ---- the window door's dates --------------------------------------------
    final w = ttcWindowAhead(0);
    expect(w == null, !ctx.hasWindow, reason: '$why: window door');
    if (w != null) {
      final shift = ctx.usualLength * w.cyclesAhead;
      expect(w.opensOn, plus(ctx.windowOpensOn!, shift),
          reason: '$why: window door opens');
      expect(w.closesOn, plus(ctx.windowClosesOn!, shift),
          reason: '$why: window door closes');
      expect(w.cyclesAhead == 0, !today.isAfter(ctx.windowClosesOn!),
          reason: '$why: window door rolled forward at the wrong edge');
    }

    // ---- "Time to test" on the hero ------------------------------------------
    final late = ttcHomeLateAdvice();
    expect(late != null, ctx.phase == TtcDayPhase.late,
        reason: '$why: Time to test');
    if (late != null) expect(late.due, ctx.periodDueOn, reason: why);

    // ---- the messages ---------------------------------------------------------
    final msgs = ttcMessageCandidates(TtcMessageFacts.fromStores(), now);
    final lateMsg =
        msgs.where((m) => m.kind == TtcMessageKind.lateByOne).firstOrNull;
    if (lateMsg != null) {
      final at = DateTime(lateMsg.at.year, lateMsg.at.month, lateMsg.at.day);
      final due = ctx.periodDueOn;
      expect(due, isNotNull, reason: '$why: a late message with no due date');
      expect(at, plus(due!, 1), reason: '$why: late message day');
      expect(ttcDayContext(at, now: at).phase, TtcDayPhase.late,
          reason: '$why: the late message lands on a day the home calls late');
      expect(ttcDayContext(due, now: due).phase, TtcDayPhase.waiting,
          reason: '$why: the due day itself is still the wait');
    }
    if (ctx.lateReliable &&
        ctx.periodDueOn != null &&
        (ctx.daysPastDue ?? 99) <= 7) {
      expect(lateMsg, isNotNull, reason: '$why: late message missing');
    }
    final windowMsg =
        msgs.where((m) => m.kind == TtcMessageKind.windowOpens).firstOrNull;
    if (windowMsg != null) {
      final at =
          DateTime(windowMsg.at.year, windowMsg.at.month, windowMsg.at.day);
      expect(at, ctx.windowOpensOn, reason: '$why: window message day');
    } else if (ctx.hasWindow && !ctx.windowOpensOn!.isBefore(today)) {
      fail('$why: window message missing');
    }
    if (ctx.clinicOwned) {
      expect(lateMsg, isNull, reason: why);
      expect(windowMsg, isNull, reason: why);
    }

    // ---- the "Should I test?" chat -------------------------------------------
    final advice = TtcShouldTestChat().advice;
    // 2026-09-26, first-cycle decision: the chat knows it is a first cycle,
    // and says the date is an early estimate.
    expect(TtcShouldTestFacts.fromStores().firstCycle, !ctx.hasOwnLength,
        reason: '$why: chat first-cycle flag');
    if (ctx.clinicOwned) {
      expect(advice.branch, TtcTestBranch.clinic, reason: why);
    } else if (!s.logged) {
      expect(advice.branch, TtcTestBranch.noDates, reason: why);
    } else if (ctx.periodDueOn != null) {
      // Kept for revert: `&& ctx.hasOwnLength`. A first cycle now names the
      // same due day as the home (her stated length, else 28 days) instead of
      // asking her for a length.
      expect(advice.due, ctx.periodDueOn, reason: '$why: chat due date');
      final gap = ctx.daysPastDue!;
      expect(
          advice.branch,
          gap < 0
              ? TtcTestBranch.early
              : gap == 0
                  ? TtcTestBranch.dueToday
                  : TtcTestBranch.late,
          reason: '$why: chat branch');
      expect(advice.looksStale, isFalse,
          reason: '$why: chat says "a while" while the home still estimates');
    } else if (const TtcChapterEngine()
        .hasUnreliableHistory(TtcStore.instance.state())) {
      // A length the engine will not lean on: the chat asks rather than
      // naming a date. Kept for revert: this branch also took a first cycle
      // (`!ctx.hasOwnLength ||`), which now counts on the home's estimate.
      expect(advice.branch, TtcTestBranch.needCycleLength, reason: why);
    } else {
      // Her own history (or a first cycle's estimate), but the engine has
      // stopped estimating: the cycle has run past its length by a whole
      // luteal phase.
      expect(advice.branch, TtcTestBranch.late, reason: why);
      expect(advice.looksStale, isTrue,
          reason: '$why: the home says "not enough logged" and the chat still '
              'calls it plainly late');
    }

    // ---- the temperature chart -----------------------------------------------
    final chart = ttcBuildTempChart();
    expect(chart.shaded, ctx.hasWindow, reason: '$why: chart shading');
    if (ctx.clinicOwned && s.logged) {
      expect(chart.state, TtcReportState.clinicHeld, reason: why);
    }
    if (chart.shaded && chart.fertileFrom != null) {
      final opens = ctx.windowOpensCycleDay!;
      expect(chart.fertileFrom, opens > ctx.bleedDays ? opens : ctx.bleedDays + 1,
          reason: '$why: chart band start');
      expect(chart.fertileTo,
          ctx.windowClosesCycleDay!.clamp(1, chart.days),
          reason: '$why: chart band end');
      if (cd <= chart.days) {
        expect(cd >= chart.fertileFrom! && cd <= chart.fertileTo!,
            ctx.phase == TtcDayPhase.window,
            reason: '$why: the chart shades today differently from the cards');
      }
    }

    // ---- the doors lead with the same stretch ---------------------------------
    const ids = [kTtcDoorIvf, kTtcDoorNotYet, kTtcDoorFertileWindow, 'other'];
    expect(
        ttcHomeDoorOrderNow(ids, now: now),
        ttcHomeDoorOrder(ids,
            clinicPathway: ctx.clinicOwned,
            tryingLong: false,
            phase: ctx.phase),
        reason: '$why: door order');
  }

  // ===========================================================================
  group('every scenario, every day of the cycle, plus the late days', () {
    for (final s in _scenarios) {
      test(s.name, () {
        for (var cd = 1; cd <= walkTo(s); cd++) {
          seed(s, cd);
          final where = '${s.name}, today = cycle day $cd';
          heroAgrees(today, where);
          surfacesAgree(today, where);
          todayAgrees(s, cd);
          if (!s.logged) break;
        }
      });
    }
  });

  // ===========================================================================
  group('every date the strip can show agrees too', () {
    for (final s in _scenarios) {
      test(s.name, () {
        // Mid-cycle and past due, then every date from six weeks back to six
        // days ahead (the strip's forward limit).
        for (final cd in [5, 12, 20, 31]) {
          seed(s, cd);
          for (var back = -6; back <= 42; back++) {
            final d = ago(back);
            final where = '${s.name}, today = cycle day $cd, strip on '
                '${back >= 0 ? '$back days back' : '${-back} days ahead'}';
            heroAgrees(d, where);
            surfacesAgree(d, where);
          }
          if (!s.logged) break;
        }
      });
    }
  });

  // ===========================================================================
  group('the rules the resolver holds', () {
    const regular = _Scenario('regular', [28, 28]);

    test('the due day is the wait, the next day is late', () {
      seed(regular, 29);
      expect(ttcDayContext(today).phase, TtcDayPhase.waiting);
      expect(ttcDayContext(today).isExpectedPeriodDay, isTrue);
      expect(ttcHomeHeroLine().state, TtcHeroState.periodDue);
      seed(regular, 30);
      expect(ttcDayContext(today).phase, TtcDayPhase.late);
      expect(ttcHomeHeroLine().state, TtcHeroState.periodLate);
      expect(ttcHomeLateAdvice()?.daysLate, 1);
    });

    test('late ends the morning the engine stops estimating', () {
      // 13 days past due: still late. 14: the engine has stopped, the hero
      // says "not enough logged", and the chat says "that's a while".
      seed(regular, 29 + 13);
      expect(ttcDayContext(today).phase, TtcDayPhase.late);
      seed(regular, 29 + 14);
      expect(ttcDayContext(today).phase, TtcDayPhase.any);
      expect(ttcHomeHeroLine().state, TtcHeroState.noEstimate);
      expect(ttcHomeLateAdvice(), isNull);
      expect(TtcShouldTestChat().advice.looksStale, isTrue);
    });

    test('a first cycle is never called late', () {
      seed(const _Scenario('first', []), 33);
      expect(ttcDayContext(today).phase, TtcDayPhase.waiting);
      expect(ttcHomeHeroLine().state, TtcHeroState.periodExpectedBy,
          reason: '"past your usual length" with no usual length');
    });

    test('a logged period day keeps its phase when the engine refuses', () {
      seed(const _Scenario('gap', [28, 28, 58]), 3);
      final ctx = ttcDayContext(today);
      expect(ctx.hasWindow, isFalse);
      expect(ctx.phase, TtcDayPhase.period);
      expect(ttcHomeHeroLine().state, TtcHeroState.noEstimate);
    });

    test('her logged bleed length is the period, everywhere', () {
      seed(regular, 7);
      final start = CycleStore.instance.lastPeriodStart!;
      expect(ttcDayContext(today).phase, TtcDayPhase.beforeWindow,
          reason: 'day 7 on the five-day default');
      CycleStore.instance.logBleedDays(start, 7);
      expect(ttcDayContext(today).phase, TtcDayPhase.period);
      expect(ttcHomePhaseOn(today), TtcDayPhase.period);
      expect(ttcBuildTempChart().periodTo, 7,
          reason: 'the chart band and the cards used different bleed lengths');
    });

    // ⚠️ REPLACED 2026-09-26 by the user's decision that earlier cycles show
    // their fertile days, worked out looking back from THAT cycle's own
    // length (the next test). What this held stays true in a narrower form:
    // an earlier cycle is never shaded from THIS cycle's estimate. Kept for
    // revert:
    //
    // test('an earlier cycle has no window on any surface', () {
    //   seed(regular, 20);
    //   final d = ago(20 + 12); // cycle day 13 of the previous cycle
    //   final ctx = ttcDayContext(d);
    //   expect(ctx.isPastCycle, isTrue);
    //   expect(ctx.hasWindow, isFalse);
    //   expect(ctx.phase, TtcDayPhase.any);
    //   expect(ttcHomeHeroLine(on: d).state, TtcHeroState.pastCycle);
    //   expect(ttcFactsFor(d).fertility, isNull,
    //       reason: 'the calendar shaded an earlier cycle from this one');
    //   expect(ttcInsightsFor(d).map((c) => c.id), isNot(contains('chance')));
    // });

    test(
        'an earlier cycle shows its own fertile days, looking back, identically '
        'on the calendar, the hero, the report and the companion', () {
      // Cycles of 26 and 33 days, today on day 10 of the current one. The
      // 33-day cycle ovulated around its day 19 (33 - 14): window 14 to 20.
      // The 26-day cycle before it: ovulation day 12, window 7 to 13. Neither
      // is this cycle's estimate (28 - 14 = 14 on the 29.5-day average).
      seed(const _Scenario('26 then 33', [26, 33]), 10);
      final starts = [...CycleStore.instance.periodStarts]..sort();
      for (final (index, ov) in [(1, 33 - 14), (2, 26 - 14)]) {
        final start = starts[starts.length - 1 - index];
        final opensOn = plus(start, ov - 5 - 1);
        // Six days ending on ovulation since 2026-09-27 (was ov + 1).
        final closesOn = plus(start, ov + ttcWindowClosesAfterOvulation - 1);
        for (var cd = 1; cd <= (index == 1 ? 33 : 26); cd++) {
          final d = plus(start, cd - 1);
          final ctx = ttcDayContext(d);
          final why = 'cycle $index back, day $cd';
          expect(ctx.lookingBack, isTrue, reason: why);
          expect(ctx.ovulationDay, ov, reason: why);
          expect(ctx.windowOpensOn, opensOn, reason: why);
          expect(ctx.windowClosesOn, closesOn, reason: why);
          final inside =
              cd >= ov - 5 && cd <= ov + ttcWindowClosesAfterOvulation;
          // The calendar.
          final facts = ttcFactsFor(d);
          expect(facts.fertility != null && facts.fertility != FertilityLevel.low,
              inside,
              reason: '$why: calendar');
          expect(facts.isOvulation, cd == ov, reason: '$why: calendar ov');
          expect(facts.lookingBack, isTrue, reason: why);
          // The hero on that date.
          final line = ttcHomeHeroLine(on: d);
          expect(line.state, TtcHeroState.pastCycle, reason: why);
          expect(line.days, cd, reason: why);
          expect(line.windowFrom, opensOn, reason: '$why: hero');
          expect(line.windowTo, closesOn, reason: '$why: hero');
          // The insights: phased from the same window, never graded.
          expect(ttcHomePhaseOn(d), ctx.phase, reason: why);
          expect(ttcInsightsFor(d).map((c) => c.id),
              isNot(contains('chance')),
              reason: why);
        }
        // The report and the companion, for that cycle.
        final report = ttcBuildCycleReport(index: index);
        expect(report.state, isNot(TtcReportState.noEstimate));
        for (final rd in report.days) {
          final inside = rd.cycleDay >= ov - 5 &&
              rd.cycleDay <= ov + ttcWindowClosesAfterOvulation;
          if (rd.cycleDay > 5) {
            expect(rd.phase == TtcPhase.fertileWindow, inside,
                reason: 'report, cycle $index back, day ${rd.cycleDay}');
          }
        }
        final band = ttcCyclePhaseSpans(index: index)
            .firstWhere((s) => s.phase == TtcPhase.fertileWindow);
        expect(band.firstDay, opensOn, reason: 'companion, cycle $index back');
        expect(band.lastDay, closesOn, reason: 'companion, cycle $index back');
      }
    });

    test('an earlier cycle her clinic ran shows no window; the one after it '
        'is hers', () {
      // Her last round's dates fall inside the PREVIOUS cycle; she has since
      // logged a new period and not cleared them. Today is day 5.
      seed(regular, 5);
      final starts = [...CycleStore.instance.periodStarts]..sort();
      final prev = starts[starts.length - 2];
      TtcStore.instance.setPath(TtcPath.ivf);
      TtcTreatmentStore.instance
        ..setDate(TtcTreatmentStep.stimStart, plus(prev, 1))
        ..setDate(TtcTreatmentStep.retrieval, plus(prev, 13));
      final past = ttcDayContext(plus(prev, 12));
      expect(past.cycleClinicOwned, isTrue);
      expect(past.hasWindow, isFalse);
      expect(ttcFactsFor(plus(prev, 12)).fertility, isNull);
      expect(ttcHomeHeroLine(on: plus(prev, 12)).windowFrom, isNull);
      expect(ttcBuildCycleReport(index: 1).state, TtcReportState.clinicHeld);
      expect(ttcCyclePhaseSpans(index: 1), isEmpty);
      // The cycle she is in has no clinic dates: hers.
      expect(TtcStore.instance.ownership, TimingOwnership.parentveda);
      expect(ttcDayContext(today).hasWindow, isTrue);
      expect(ttcHomeHeroLine().state, TtcHeroState.windowOpensIn);
    });

    test('the hero names this cycle\'s window, even after today has passed it',
        () {
      // Today in the waiting days; the strip back on a day before the window.
      seed(regular, 20);
      final d = ago(12); // cycle day 8
      final ctx = ttcDayContext(d);
      expect(ttcHomeHeroLine(on: d).state, TtcHeroState.windowOpensIn);
      expect(ctx.windowOpensOn, ago(20 - 9));
      // The window door, for today, has rolled on to next cycle's.
      expect(ttcFertileWindowNow()!.cyclesAhead, 1);
      expect(ttcFertileWindowNow()!.opensOn, isNot(ctx.windowOpensOn));
    });

    test('a clinic cycle shows her clinic\'s date first, then her cycle day',
        () {
      // 2026-09-26: the IVF label alone is her own cycle now, so the clinic
      // cycle is the label plus a date her clinic gave her for this cycle.
      // Kept for revert: the seed alone, with no date, was a clinic cycle.
      seed(const _Scenario('ivf', [28, 28], path: TtcPath.ivf), 10);
      TtcTreatmentStore.instance.setDate(
          TtcTreatmentStep.stimStart, CycleStore.instance.lastPeriodStart);
      expect(ttcHomeHeroLine().state, TtcHeroState.clinicHolds);
      expect(ttcHomeHeroLine().days, 10);
      TtcTreatmentStore.instance
          .setDate(TtcTreatmentStep.retrieval, plus(today, 3));
      expect(ttcHomeHeroLine().state, TtcHeroState.treatmentSoon);
      expect(ttcDayContext(today).phase, TtcDayPhase.any);
    });
  });

  // ===========================================================================
  //  The four decisions of 2026-09-26, each held once more on its own
  // ===========================================================================
  group('decision 1: a clinic owns the timing only with real clinic dates', () {
    const regular = _Scenario('regular', [28, 28]);

    void allOwn(String why) {
      final ctx = ttcDayContext(today);
      expect(TtcStore.instance.ownership, TimingOwnership.parentveda,
          reason: why);
      expect(ctx.clinicOwned, isFalse, reason: why);
      expect(ctx.hasWindow, isTrue, reason: '$why: resolver');
      expect(ttcHomeHeroLine().state, TtcHeroState.windowOpensIn,
          reason: '$why: hero');
      expect(ttcFactsFor(ctx.windowPeakOn!).fertility, FertilityLevel.peak,
          reason: '$why: calendar');
      expect(ttcFertileWindowNow(), isNotNull, reason: '$why: window door');
      expect(TtcShouldTestChat().advice.branch, TtcTestBranch.early,
          reason: '$why: chat');
      expect(ttcBuildCycleReport().state, isNot(TtcReportState.clinicHeld),
          reason: '$why: report');
      expect(ttcCyclePhaseSpans(), isNotEmpty, reason: '$why: companion');
      expect(ttcBuildTempChart().shaded, isTrue, reason: '$why: chart');
      expect(
          ttcMessageCandidates(TtcMessageFacts.fromStores(), now)
              .any((m) => m.kind == TtcMessageKind.windowOpens),
          isTrue,
          reason: '$why: window message');
    }

    void allClinic(String why) {
      final ctx = ttcDayContext(today);
      expect(ctx.clinicOwned, isTrue, reason: why);
      expect(ctx.hasWindow, isFalse, reason: '$why: resolver');
      expect(ctx.periodDueOn, isNull, reason: '$why: due');
      expect(windowStates, isNot(contains(ttcHomeHeroLine().state)),
          reason: '$why: hero');
      // 2026-09-26: the cycle she is in and any cycle a round ran in; the
      // earlier cycles before treatment keep their look-back (the resolver
      // decision). Kept for revert: every one of 60 days back was checked.
      for (var back = 0; back < 60; back++) {
        final c = ttcDayContext(ago(back));
        if (c.isPastCycle && !c.cycleClinicOwned) continue;
        expect(ttcFactsFor(ago(back)).fertility, isNull,
            reason: '$why: calendar $back days back');
      }
      expect(ttcFertileWindowNow(), isNull, reason: '$why: window door');
      expect(TtcShouldTestChat().advice.branch, TtcTestBranch.clinic,
          reason: '$why: chat');
      expect(ttcBuildCycleReport().state, TtcReportState.clinicHeld,
          reason: '$why: report');
      expect(ttcCyclePhaseSpans(), isEmpty, reason: '$why: companion');
      expect(ttcBuildTempChart().shaded, isFalse, reason: '$why: chart');
      expect(ttcHomeLateAdvice(), isNull, reason: '$why: time to test');
    }

    for (final path in [
      TtcPath.ivf,
      TtcPath.iui,
      TtcPath.ovulationInduction,
      TtcPath.frozenEmbryoTransfer,
    ]) {
      test('${path.name}: the label alone is her own cycle everywhere', () {
        seed(_Scenario(path.name, const [28, 28], path: path), 5);
        allOwn('${path.name}, label only');
      });

      test('${path.name}: a date for this cycle hands everything to the clinic',
          () {
        seed(_Scenario(path.name, const [28, 28], path: path), 5);
        TtcTreatmentStore.instance
            .setDate(TtcTreatmentStep.betaTest, plus(today, 20));
        allClinic('${path.name}, with a clinic date');
        // And clearing the round hands it back.
        TtcTreatmentStore.instance.clearCycle();
        allOwn('${path.name}, dates cleared');
      });
    }

    test('dates from a round before this cycle do not own it', () {
      seed(const _Scenario('ivf', [28, 28], path: TtcPath.ivf), 5);
      TtcTreatmentStore.instance
          .setDate(TtcTreatmentStep.transfer, ago(10)); // previous cycle
      allOwn('an old round');
    });

    test('a "trying naturally" label with clinic dates is still the clinic',
        () {
      seed(regular, 5);
      TtcTreatmentStore.instance
          .setDate(TtcTreatmentStep.retrieval, plus(today, 8));
      expect(TtcStore.instance.ownership, TimingOwnership.clinicGuided);
      allClinic('natural label, IUI date');
      TtcTreatmentStore.instance
          .setDate(TtcTreatmentStep.stimStart, ago(2));
      expect(TtcStore.instance.ownership, TimingOwnership.clinicControlled,
          reason: 'a stimulation start means medication is timing it');
    });

    test('her two answers still pick the tier once dates exist', () {
      seed(const _Scenario('iui', [28, 28], path: TtcPath.iui), 5);
      TtcStore.instance
        ..setClinicMonitors(true)
        ..setMedicationControlsOvulation(false);
      expect(TtcStore.instance.ownership, TimingOwnership.parentveda,
          reason: 'answers without dates own nothing');
      TtcTreatmentStore.instance
          .setDate(TtcTreatmentStep.retrieval, plus(today, 8));
      expect(TtcStore.instance.ownership, TimingOwnership.clinicGuided);
      TtcStore.instance.setMedicationControlsOvulation(true);
      expect(TtcStore.instance.ownership, TimingOwnership.clinicControlled);
    });

    test('the journey state agrees with the screens', () {
      seed(const _Scenario('ivf', [28, 28], path: TtcPath.ivf), 5);
      expect(currentJourneyState().mayInfer(Inferable.fertilityTiming), isTrue,
          reason: 'label only');
      TtcTreatmentStore.instance
          .setDate(TtcTreatmentStep.betaTest, plus(today, 20));
      expect(currentJourneyState().mayInfer(Inferable.fertilityTiming),
          isFalse,
          reason: 'with a clinic date');
    });
  });

  group('decision 2: a first cycle is predicted like Flo and What to Expect',
      () {
    const first = _Scenario('first', []);

    test('28 days by default, an early estimate, and the chat agrees', () {
      seed(first, 10);
      final start = CycleStore.instance.lastPeriodStart!;
      final ctx = ttcDayContext(today);
      expect(ctx.usualLength, 28);
      expect(ctx.confidence, OvulationConfidence.low,
          reason: 'the "early estimate" wording');
      expect(ctx.periodDueOn, plus(start, 28));
      expect(ctx.ovulationDay, 14);
      final chat = TtcShouldTestChat();
      expect(chat.facts.firstCycle, isTrue);
      expect(chat.advice.branch, TtcTestBranch.early,
          reason: 'the chat asked for a length instead of using the estimate');
      expect(chat.advice.due, ctx.periodDueOn);
      expect(chat.begin().say, contains(kTtcFirstCycleEarlyLine));
    });

    test('her stated length when she gave one, everywhere', () {
      seed(const _Scenario('first, 33', [], stated: 33), 10);
      final start = CycleStore.instance.lastPeriodStart!;
      final ctx = ttcDayContext(today);
      expect(ctx.usualLength, 33);
      expect(ctx.ovulationDay, 19);
      expect(ctx.periodDueOn, plus(start, 33));
      expect(ctx.windowOpensOn, plus(start, 13));
      expect(ttcHomeHeroLine().state, TtcHeroState.windowOpensIn);
      expect(ttcHomeHeroLine().days, 4);
      expect(ttcFactsFor(plus(start, 33)).isExpectedPeriod, isTrue);
      expect(ttcFertileWindowNow()!.opensOn, ctx.windowOpensOn);
      expect(TtcShouldTestChat().advice.due, ctx.periodDueOn);
    });

    test('a completed cycle replaces the stated length', () {
      seed(const _Scenario('first, 33', [30], stated: 33), 10);
      expect(ttcDayContext(today).usualLength, 30);
    });

    test('with nothing logged the chat still asks, and keeps her answer', () {
      seed(const _Scenario('none', [], logged: false), 1);
      final chat = TtcShouldTestChat();
      expect(chat.advice.branch, TtcTestBranch.noDates);
      final step = chat.afterStart(ago(3));
      expect(step.say.last, contains('how long are your cycles'));
      chat.withLength(33);
      expect(TtcStore.instance.statedCycleLength, 33,
          reason: 'her answer was not kept as her stated length');
      // And the first period she logs is predicted from it.
      CycleStore.instance.logPeriodStart(ago(3));
      expect(ttcDayContext(today).periodDueOn, plus(ago(3), 33));
    });
  });

  group('decision 3: one definition of irregular (more than 7 days)', () {
    Future<void> check(List<int> lengths, {required bool irregular}) async {
      seed(_Scenario('$lengths', lengths), 10);
      final why = 'lengths $lengths';
      expect(kTtcIrregularSpreadDays, 7);
      final state = TtcStore.instance.state();
      expect(const TtcChapterEngine().isIrregular(state), irregular,
          reason: '$why: engine');
      expect(TtcFertilityHelpStore.instance.context.cyclesIrregular, irregular,
          reason: '$why: the help tool');
      expect(TtcMessageFacts.fromStores().irregular, irregular,
          reason: '$why: the messages');
      expect(TtcMessageFacts.fromStores().monthsBeforeCheck,
          irregular ? 6 : 12,
          reason: '$why: the six-month message');
      expect(ttcDayContext(today).lateReliable, !irregular,
          reason: '$why: whether "late" can be said');
      expect(ttcDayContext(today).confidence,
          irregular ? OvulationConfidence.low : OvulationConfidence.medium,
          reason: '$why: confidence');
      expect(TtcShouldTestChat().advice.rough, irregular,
          reason: '$why: the chat\'s rough-date line');
    }

    test('a spread of exactly 7 days is regular', () async {
      await check([25, 32], irregular: false);
    });

    test('a spread of 8 days is irregular (the engine said regular before)',
        () async {
      await check([24, 32], irregular: true);
    });
  });

  // ===========================================================================
  //  Treatment rounds (docs/TTC-TREATMENT-FLOW.md B2, the user's decisions of
  //  2026-09-26): the round runs every surface from its first treatment date
  //  until it closes; a label or a planned round is her own cycle; the cycle
  //  after a closed round is hers once she logs a period; the app asks after
  //  7 quiet days or a 30-day return, and never closes a round on its own.
  // ===========================================================================
  group('treatment rounds', () {
    const regular = _Scenario('regular', [28, 28]);

    /// Her clinic's dates for [kind], as days after the current period start
    /// (cycle day 1 = offset 0). The trigger carries its minute.
    Map<TtcTreatmentStep, DateTime> datesFor(TtcRoundKind kind, DateTime p) {
      DateTime at(int n, [int h = 0, int m = 0]) =>
          DateTime(p.year, p.month, p.day + n, h, m);
      return switch (kind) {
        TtcRoundKind.ivfFresh || TtcRoundKind.notSure => {
            TtcTreatmentStep.baselineScan: at(1),
            TtcTreatmentStep.stimStart: at(2),
            TtcTreatmentStep.trigger: at(12, 21, 15),
            TtcTreatmentStep.retrieval: at(14),
            TtcTreatmentStep.transfer: at(19),
            TtcTreatmentStep.betaTest: at(30),
          },
        TtcRoundKind.ivfFreezeAll => {
            TtcTreatmentStep.baselineScan: at(1),
            TtcTreatmentStep.stimStart: at(2),
            TtcTreatmentStep.trigger: at(12, 22),
            TtcTreatmentStep.retrieval: at(14),
          },
        TtcRoundKind.iui => {
            TtcTreatmentStep.stimStart: at(1),
            TtcTreatmentStep.trigger: at(12, 21),
            TtcTreatmentStep.iui: at(14),
            TtcTreatmentStep.betaTest: at(28),
          },
        TtcRoundKind.ovulationInduction => {
            TtcTreatmentStep.stimStart: at(1),
            TtcTreatmentStep.trigger: at(13, 20),
            TtcTreatmentStep.betaTest: at(29),
          },
        TtcRoundKind.fetMedicated => {
            TtcTreatmentStep.estrogenStart: at(1),
            TtcTreatmentStep.progesteroneStart: at(14),
            TtcTreatmentStep.transfer: at(19),
            TtcTreatmentStep.betaTest: at(29),
          },
        TtcRoundKind.fetNatural => {
            TtcTreatmentStep.trigger: at(12, 21),
            TtcTreatmentStep.transfer: at(19),
            TtcTreatmentStep.betaTest: at(28),
          },
      };
    }

    List<DateTime> scansFor(TtcRoundKind kind, DateTime p) =>
        kind == TtcRoundKind.fetNatural
            ? [plus(p, 1), plus(p, 9)]
            : [plus(p, 7)];

    /// Today is day [k] after her current period started, with a round of
    /// [kind] saved.
    void seedRound(TtcRoundKind kind, int k) {
      seed(regular, k + 1);
      final p = CycleStore.instance.lastPeriodStart!;
      TtcStore.instance.setPath(ttcPathForKind(kind));
      TtcTreatmentStore.instance.startRound(
          kind: kind, dates: datesFor(kind, p), scans: scansFor(kind, p));
    }

    void noPrediction(String why) {
      final ctx = ttcDayContext(today);
      expect(ctx.clinicOwned, isTrue, reason: why);
      expect(ctx.phase, TtcDayPhase.any, reason: why);
      expect(ctx.hasWindow, isFalse, reason: '$why: window');
      expect(ctx.periodDueOn, isNull, reason: '$why: due');
      expect(ttcFactsFor(today).fertility, isNull, reason: '$why: calendar');
      expect(ttcFactsFor(today).isExpectedPeriod, isFalse, reason: why);
      expect(ttcFertileWindowNow(), isNull, reason: '$why: window door');
      expect(ttcHomeLateAdvice(), isNull, reason: '$why: time to test');
      final line = ttcHomeHeroLine();
      expect(windowStates, isNot(contains(line.state)), reason: '$why: hero');
      expect(periodCountStates, isNot(contains(line.state)),
          reason: '$why: hero');
      final msgs = ttcMessageCandidates(TtcMessageFacts.fromStores(), now);
      expect(
          msgs.where((m) =>
              m.kind == TtcMessageKind.windowOpens ||
              m.kind == TtcMessageKind.lateByOne),
          isEmpty,
          reason: '$why: messages');
      expect(TtcShouldTestChat().advice.branch, TtcTestBranch.clinic,
          reason: '$why: chat');
      expect(ttcBuildTempChart().shaded, isFalse, reason: '$why: chart');
    }

    for (final kind in TtcRoundKind.values) {
      test('${kind.name}: every day of the round, no window, due or late',
          () {
        for (var k = 0; k <= 36; k++) {
          seedRound(kind, k);
          final why = '${kind.name}, round day $k';
          final first = ttcFirstTreatmentDate(TtcTreatmentStore.instance.cycle)!;
          if (today.isBefore(first)) {
            // Planned: her own cycle, and the round named in the small line.
            expect(TtcStore.instance.ownership, TimingOwnership.parentveda,
                reason: why);
            expect(ttcHomeHeroLine().upcomingOn, first, reason: why);
            expect(ttcHomeRoundPhaseOn(today), isNull, reason: why);
          } else {
            noPrediction(why);
            final step = ttcTreatmentPhase(
                TtcTreatmentStore.instance.cycle, today);
            expect(step.isRunning, isTrue, reason: why);
            expect(ttcHomeRoundPhaseOn(today), step, reason: why);
            expect(kTtcRoundHeroStates, contains(ttcHomeHeroLine().state),
                reason: '$why: hero ${ttcHomeHeroLine().state.name}');
            // The daily card and the reads follow the step.
            expect(kTtcTreatmentInsights[step],
                contains(ttcHomeInsightFor(today)),
                reason: '$why: card');
            final reads = ttcHomeReadIdsFor(today);
            expect(kTtcTreatmentPhaseReadIds[step], contains(reads.first),
                reason: '$why: reads');
            // Sex and Test hide on the IVF shapes only (§3e).
            expect(ttcHomeHidesQuickRow(today), ttcRoundIsIvfShaped(kind),
                reason: '$why: one-tap row');
          }
          heroAgrees(today, why);
          surfacesAgree(today, why);
        }
      });
    }

    test('the strip, back through the round and the cycles before it', () {
      seedRound(TtcRoundKind.ivfFresh, 22);
      for (var back = -6; back <= 70; back++) {
        final d = ago(back);
        final where = 'ivf round day 22, strip $back days back';
        heroAgrees(d, where);
        surfacesAgree(d, where);
      }
      // A cycle from before the round keeps its look-back window.
      final starts = [...CycleStore.instance.periodStarts]..sort();
      final prev = starts[starts.length - 2];
      final ctx = ttcDayContext(plus(prev, 12));
      expect(ctx.isPastCycle, isTrue);
      expect(ctx.cycleClinicOwned, isFalse);
      expect(ctx.lookingBack, isTrue,
          reason: 'pre-treatment cycles keep their look-back window');
    });

    test('a round with a kind and no dates is her own cycle', () {
      seed(regular, 5);
      TtcStore.instance.setPath(TtcPath.ivf);
      TtcTreatmentStore.instance.startRound(kind: TtcRoundKind.ivfFresh);
      expect(TtcStore.instance.ownership, TimingOwnership.parentveda);
      expect(ttcDayContext(today).hasWindow, isTrue);
      expect(ttcHomeHeroLine().state, TtcHeroState.windowOpensIn);
    });

    test('dates saved for next month leave this month hers', () {
      seed(regular, 5);
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {
            TtcTreatmentStep.baselineScan: plus(today, 26),
            TtcTreatmentStep.stimStart: plus(today, 27),
          });
      expect(TtcStore.instance.ownership, TimingOwnership.parentveda);
      expect(ttcDayContext(today).hasWindow, isTrue);
      final line = ttcHomeHeroLine();
      expect(line.state, TtcHeroState.windowOpensIn);
      expect(line.upcomingOn, plus(today, 26));
      expect(line.upcomingStep, TtcTreatmentStep.baselineScan);
    });

    test('after a round ends, her own cycle is back once she logs a period', () {
      seedRound(TtcRoundKind.ivfFresh, 32);
      final store = TtcTreatmentStore.instance;
      store.closeRound(TtcRoundOutcome.negative);
      // The cycle the round ran in stays the clinic's: between rounds.
      expect(TtcStore.instance.ownership, isNot(TimingOwnership.parentveda));
      expect(ttcHomeHeroLine().state, TtcHeroState.treatmentBetweenRounds);
      expect(ttcHomeRoundPhaseOn(today), TtcRoundPhase.betweenRounds);
      expect(ttcDayContext(today).hasWindow, isFalse);
      expect(ttcHomeHidesQuickRow(today), isFalse,
          reason: 'the one-tap row comes back the day the round closes');
      expect(ttcRoundNoticeNow(), TtcRoundNotice.closed,
          reason: 'closed, with its undo');
      expect(store.returnAnnouncementDue(ownCycleAgain: false), isFalse);
      // She logs a period: her own cycle, every surface.
      CycleStore.instance.logPeriodStart(today);
      expect(TtcStore.instance.ownership, TimingOwnership.parentveda);
      expect(ttcDayContext(today).clinicOwned, isFalse);
      expect(ttcHomeRoundPhaseOn(today), isNull);
      expect(ttcHomeHeroLine().state, isNot(TtcHeroState.treatmentBetweenRounds));
      heroAgrees(today, 'after the round, day 1');
      surfacesAgree(today, 'after the round, day 1');
      // The fertile days coming back are said once.
      expect(ttcRoundNoticeNow(), TtcRoundNotice.fertileBack);
      store.markReturnAnnounced();
      expect(ttcRoundNoticeNow(), isNot(TtcRoundNotice.fertileBack));
      // The round's own cycle, looking back, stays the clinic's.
      final starts = [...CycleStore.instance.periodStarts]..sort();
      final roundCycle = ttcDayContext(plus(starts[starts.length - 2], 10));
      expect(roundCycle.cycleClinicOwned, isTrue);
      expect(roundCycle.hasWindow, isFalse);
    });

    test('7 quiet days asks; the round never closes on its own', () {
      // IVF dates end at day 30; today is day 36 then day 37.
      seedRound(TtcRoundKind.ivfFresh, 36);
      final store = TtcTreatmentStore.instance;
      store.stillGoing(now: plus(today, -6));
      expect(store.checkInDue(), isFalse, reason: 'six quiet days');
      seedRound(TtcRoundKind.ivfFresh, 37);
      store.stillGoing(now: plus(today, -7));
      expect(store.checkInDue(), isTrue, reason: 'seven quiet days');
      expect(ttcRoundNoticeNow(), TtcRoundNotice.checkIn);
      // Still clinic, still open: never closed quietly.
      expect(store.cycle.isClosed, isFalse);
      expect(TtcStore.instance.ownership, isNot(TimingOwnership.parentveda));
      noPrediction('a quiet round');
    });

    test('a return after 30 days asks before anything is assumed', () {
      seedRound(TtcRoundKind.iui, 10);
      final store = TtcTreatmentStore.instance;
      store.noteOpened(now: plus(today, -31));
      store.noteOpened();
      expect(store.askOnReturnPending, isTrue);
      expect(ttcRoundNoticeNow(), TtcRoundNotice.checkIn);
      // A period logged on her return changes nothing about the round.
      CycleStore.instance.logPeriodStart(today);
      expect(store.cycle.isClosed, isFalse);
      expect(TtcStore.instance.ownership, isNot(TimingOwnership.parentveda),
          reason: 'the round still runs until she answers');
      expect(ttcRoundNoticeNow(), TtcRoundNotice.checkIn);
    });

    test('the first treatment day is announced once', () {
      seedRound(TtcRoundKind.ivfFresh, 0);
      // Saved the day before its first date: nothing to announce yet.
      expect(ttcRoundNoticeNow(), isNot(TtcRoundNotice.active));
      // Next morning (the dates move back a day): announced, once.
      seed(regular, 2);
      final p = CycleStore.instance.lastPeriodStart!;
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: datesFor(TtcRoundKind.ivfFresh, p),
          now: plus(today, -1));
      expect(ttcRoundNoticeNow(), TtcRoundNotice.active);
      store.markActiveAnnounced();
      expect(ttcRoundNoticeNow(), isNot(TtcRoundNotice.active));
    });

    testWidgets('the home, at 360dp, on every step of an IVF and an IUI round',
        (tester) async {
      tester.view.physicalSize = const Size(360, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      // (kind, day after the period started): one day in every step.
      for (final (kind, k) in [
        (TtcRoundKind.ivfFresh, 0), // planned
        (TtcRoundKind.ivfFresh, 1), // getting ready
        (TtcRoundKind.ivfFresh, 6), // stimulation
        (TtcRoundKind.ivfFresh, 12), // trigger day
        (TtcRoundKind.ivfFresh, 13), // the day before collection
        (TtcRoundKind.ivfFresh, 14), // collection
        (TtcRoundKind.ivfFresh, 16), // embryo days
        (TtcRoundKind.ivfFresh, 19), // transfer
        (TtcRoundKind.ivfFresh, 23), // the wait
        (TtcRoundKind.ivfFresh, 30), // test day
        (TtcRoundKind.ivfFresh, 32), // waiting to hear
        (TtcRoundKind.iui, 14), // IUI day
        (TtcRoundKind.iui, 20), // the wait after an IUI
        (TtcRoundKind.fetMedicated, 8), // estrogen day
      ]) {
        seedRound(kind, k);
        await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: const TtcHomeV3()));
        await tester.pump(const Duration(milliseconds: 300));
        final why = '${kind.name}, round day $k';
        expect(tester.takeException(), isNull, reason: '$why: threw');
        final line = ttcHomeHeroLine();
        if (kTtcRoundHeroStates.contains(line.state)) {
          final (_, big, _) = ttcRoundHeroCopy(line, today);
          expect(find.text(big), findsWidgets, reason: '$why: hero "$big"');
          // The blood test is a date, never a count.
          expect(big, isNot(matches(RegExp(r'in \d+ days'))), reason: why);
        } else {
          expect(line.upcomingOn, isNotNull, reason: '$why: planned');
          expect(find.text(ttcRoundUpcomingLine(line)), findsOneWidget,
              reason: '$why: the round named under her own cycle');
        }
        final hidden = ttcHomeHidesQuickRow(today);
        expect(find.byKey(const ValueKey('ttc_home_quick_sex')),
            hidden ? findsNothing : findsOneWidget,
            reason: '$why: Sex button');
        expect(find.byKey(const ValueKey('ttc_home_blood_test_line')),
            hidden ? findsOneWidget : findsNothing,
            reason: '$why: blood test line');
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    // -------------------------------------------------------------------------
    //  The calendar, per round state (2026-09-26, §3c, B5)
    // -------------------------------------------------------------------------
    test('the calendar: named clinic dates, soft bands, no natural marks', () {
      for (final kind in TtcRoundKind.values) {
        for (final k in const [0, 1, 6, 12, 14, 16, 19, 23, 30, 32]) {
          seedRound(kind, k);
          final why = '${kind.name}, round day $k';
          final r = TtcTreatmentStore.instance.cycle;
          final p = CycleStore.instance.lastPeriodStart!;
          final first = ttcFirstTreatmentDate(r)!;
          // Every day from the round's first date on: no window, no
          // expected period, whether the round runs yet or is only planned
          // (rule 2b), and the calendar agrees with the resolver.
          for (var n = 0; n <= 40; n++) {
            final d = plus(p, n);
            if (d.isBefore(first)) continue;
            final f = ttcFactsFor(d);
            expect(f.fertility, isNull, reason: '$why, +$n: fertile');
            expect(f.isOvulation, isFalse, reason: '$why, +$n: ovulation');
            expect(f.isExpectedPeriod, isFalse, reason: '$why, +$n: expected');
            expect(ttcDayContext(d).hasWindow, isFalse, reason: '$why, +$n');
          }
          // Each clinic date is a named marker, for her kind of round.
          for (final e in r.dates.entries) {
            final f = ttcFactsFor(e.value);
            expect(f.isClinicDate, isTrue, reason: '$why: ${e.key.name}');
            // The trigger carries its time since 2026-09-27 (tools pass,
            // "Trigger injection · 10:15pm"). Was:
            //   expect(f.treatment,
            //       contains(ttcCalendarDateLabel(e.key, kind)), ...);
            expect(
                f.treatment,
                contains(e.key.needsTime
                    ? '${ttcCalendarDateLabel(e.key, kind)} · '
                        '${ttcRoundTime(e.value)}'
                    : ttcCalendarDateLabel(e.key, kind)),
                reason: '$why: ${e.key.name}');
          }
          for (final sc in r.scans) {
            expect(ttcFactsFor(sc).treatment, contains(ttcScanLabel(kind)),
                reason: '$why: scan');
          }
          // The bands, only between her own dates.
          final stim = r[TtcTreatmentStep.stimStart];
          final trig = r[TtcTreatmentStep.trigger];
          final hasMedicine = stim != null &&
              trig != null &&
              kind != TtcRoundKind.ovulationInduction &&
              kind != TtcRoundKind.fetMedicated &&
              kind != TtcRoundKind.fetNatural;
          if (hasMedicine) {
            expect(ttcFactsFor(plus(stim, 1)).roundBand, TtcRoundBand.medicine,
                reason: '$why: injection days');
          }
          final beta = r[TtcTreatmentStep.betaTest];
          if (beta != null) {
            expect(ttcFactsFor(beta).roundBand, isNull,
                reason: '$why: the test day is a marker, not a band');
            expect(ttcFactsFor(plus(beta, -1)).roundBand,
                TtcRoundBand.waitingForTest,
                reason: '$why: the wait');
          }
        }
      }
    });

    testWidgets('the calendar\'s "Coming up": the next clinic date, the test '
        'by its date', (tester) async {
      tester.view.physicalSize = const Size(360, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      for (final k in const [0, 6, 13, 23]) {
        seedRound(TtcRoundKind.ivfFresh, k);
        await tester.pumpWidget(
            MaterialApp(key: UniqueKey(), home: const TtcCalendarScreen()));
        await tester.pump(const Duration(milliseconds: 300));
        final why = 'ivf, round day $k';
        expect(tester.takeException(), isNull, reason: why);
        final r = TtcTreatmentStore.instance.cycle;
        final next = ttcRoundNextAfter(r, plus(today, -1))!;
        expect(find.byKey(const ValueKey('ttc_calendar_round_upcoming')),
            findsOneWidget,
            reason: why);
        expect(find.text(ttcCalendarDateLabel(next.$1, r.kind)), findsWidgets,
            reason: '$why: the next clinic date is named');
        // The blood test, wherever it shows, is a date.
        final beta = r[TtcTreatmentStep.betaTest]!;
        expect(find.text(ttcRoundDate(beta)), findsWidgets,
            reason: '$why: the test by its date');
        expect(find.textContaining(RegExp(r'Until your blood test')),
            findsNothing,
            reason: '$why: the old countdown card');
        expect(find.byKey(const ValueKey('ttc_calendar_see_round')),
            findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    test('a closed round\'s dates stay on the calendar, as a past round', () {
      seedRound(TtcRoundKind.ivfFresh, 32);
      final r = TtcTreatmentStore.instance.cycle;
      TtcTreatmentStore.instance.closeRound(TtcRoundOutcome.negative);
      final xfer = r[TtcTreatmentStep.transfer]!;
      expect(ttcFactsFor(xfer).treatment,
          contains('$kTtcCalendarPastRound · Embryo transfer'));
      expect(ttcFactsFor(plus(xfer, 2)).roundBand, TtcRoundBand.waitingForTest);
    });

    test('a treatment label with no dates is invited to add them', () {
      seed(const _Scenario('ivf', [28, 28], path: TtcPath.ivf), 5);
      expect(ttcHomeInvitesClinicDates(), isTrue);
      expect(ttcRoundNoticeNow(), TtcRoundNotice.invite);
      seed(regular, 5);
      expect(ttcRoundNoticeNow(), isNull, reason: 'trying naturally');
    });
  });

  // ===========================================================================
  group('age: one saved answer, one rule, every reader', () {
    final groups = [
      const TtcFocusGroup(
          id: 'first', label: 'First', icon: Icons.circle_outlined, hue: 1),
      const TtcFocusGroup(
          id: 'second', label: 'Second', icon: Icons.circle_outlined, hue: 2),
      const TtcFocusGroup(
          id: kTtcAgeGroupId, label: 'Age', icon: Icons.circle_outlined, hue: 3),
    ];

    Future<void> answer(FertilityAgeBand band) async {
      await TtcFertilityHelpStore.instance.setAgeBand(band);
      TtcStore.instance.setJourneyStart(ago(200)); // about six and a half months
    }

    test('35 and over: six months, the age tab moves, everyone agrees',
        () async {
      seed(const _Scenario('regular', [28, 28]), 10);
      await answer(FertilityAgeBand.thirtyEightTo40);
      final band = TtcFertilityHelpStore.instance.ageBand;
      expect(ttcDayContext(today).ageBand, band);
      expect(TtcFertilityHelpStore.instance.context.ageBand, band);
      expect(TtcMessageFacts.fromStores().ageBand, band);
      expect(TtcMessageFacts.fromStores().monthsBeforeCheck, 6);
      expect(ttcHomeCheckMonths(), 6,
          reason: 'the home check card and the message disagree about age');
      expect(
          ttcDoorOrderedGroups(groups,
                  bracketId: kTtcIvfBracketId, ageBand: band)
              .map((g) => g.id)
              .toList()[1],
          kTtcAgeGroupId);
      expect(ttcHomeDoorOrderNow(
              [kTtcDoorFertileWindow, kTtcDoorNotYet, 'x'],
              now: now).first,
          kTtcDoorNotYet,
          reason: 'the doors did not lead with "Taking a while" at 35+');
    });

    test('under 35: twelve months, nothing moves, everyone agrees', () async {
      seed(const _Scenario('regular', [28, 28]), 10);
      await answer(FertilityAgeBand.under35);
      final band = TtcFertilityHelpStore.instance.ageBand;
      expect(TtcMessageFacts.fromStores().monthsBeforeCheck, 12);
      expect(ttcHomeCheckMonths(), isNull);
      expect(
          ttcDoorOrderedGroups(groups,
                  bracketId: kTtcIvfBracketId, ageBand: band)
              .map((g) => g.id)
              .toList(),
          ['first', 'second', kTtcAgeGroupId]);
    });

    test('the IVF readiness check starts from her saved answer', () {
      final src = File('lib/screens/ttc/ttc_ivf_readiness_screen.dart')
          .readAsStringSync();
      expect(src, contains('_a.age = _ctx.ageBand;'),
          reason: 'the readiness check asks her age again from blank');
    });

    test('the home rebuilds when her age answer changes', () {
      final src =
          File('lib/screens/ttc/ttc_home_v3.dart').readAsStringSync();
      // Line-ending agnostic: the file is CRLF on Windows checkouts.
      expect(src, matches(RegExp(r'TtcFertilityHelpStore\.instance,\r?\n')),
          reason: 'the home does not listen to the age store');
    });
  });

  // ===========================================================================
  group('selecting another date moves the hero, the insights and the titles '
      'together', () {
    String keyFor(DateTime d) => 'ttc_day_${d.year}-${d.month}-${d.day}';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', //
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const short = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcHomeV3()));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    testWidgets('back from the waiting days into the window', (tester) async {
      // A 32-day history: the window is cycle days 13 to 18 (six days ending
      // on ovulation since 2026-09-27; it was 13 to 19). Today is day 20,
      // the first of the waiting days, so the window door has already rolled
      // on to NEXT cycle's window. The strip steps back three days, to day 17.
      seed(const _Scenario('32', [32, 32]), 20);
      await pump(tester);

      expect(find.text('Recommended reads for today'), findsOneWidget);

      final target = ago(3);
      await tester.tap(find.byKey(ValueKey(keyFor(target))));
      await tester.pump(const Duration(milliseconds: 400));

      final title = '${target.day} ${months[target.month - 1]}';
      // The page's date, the insights heading and the reads heading.
      expect(find.text(title), findsWidgets,
          reason: 'the insights title did not follow the strip');
      expect(find.text(ttcReadsTitleFor(title)), findsOneWidget,
          reason: 'the reads title still says today');

      // The hero: this cycle's window, counted from the selected day.
      final ctx = ttcDayContext(target);
      expect(ctx.phase, TtcDayPhase.window);
      // Day 17 to day 18: two days (was 'today and 2 more days' with the
      // seventh day).
      expect(find.text('today and tomorrow'), findsOneWidget,
          reason: 'the hero did not count from the selected day');
      final o = ctx.windowOpensOn!, c = ctx.windowClosesOn!;
      expect(
          find.text('${o.day} ${short[o.month - 1]} to '
              '${c.day} ${short[c.month - 1]}'),
          findsOneWidget,
          reason: 'the hero printed a different window from the one it counts '
              "in (next cycle's, from the clock)");
      expect(ttcFertileWindowNow()!.cyclesAhead, 1,
          reason: 'the scenario no longer exercises the rolled-forward case');

      // The insight card is one written for that stretch.
      final card = ttcHomeInsightFor(target);
      expect(card.phases, contains(TtcDayPhase.window));
      expect(find.text(card.titleEn, skipOffstage: false), findsWidgets,
          reason: "the insight rail is not showing the selected day's card");

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
