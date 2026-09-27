// =============================================================================
//  What the TTC home hero says today
// -----------------------------------------------------------------------------
//  ⚠️ THE HERO USED TO GO QUIET FOR HALF OF EVERY CYCLE, AND THAT IS THE BUG
//  THIS FILE FIXES. Reported from Flo's home: *"the message also keeps on
//  changing, which we lack"*.
//
//  Ours had five states, and four of them are refusals. The fifth said either
//  "your fertile days are here" or "your fertile days open in N days". So from
//  the day the window closed until the next period arrived — roughly a
//  fortnight, every cycle, the two-week wait — `ttcFertileWindowNow` had
//  already rolled forward onto NEXT cycle's window, and the hero spent all of
//  it saying "Expected around 20 Sep to 25 Sep, based on your usual cycle".
//
//  Fourteen days of an unchanging sentence about a cycle she is not in yet, at
//  the exact point in the month when she is thinking about this the most. The
//  gap was never the wording; it was that nothing in the model described the
//  luteal phase at all.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT WE DID NOT COPY, AND WHY IT IS THE WHOLE POINT
//  ---------------------------------------------------------------------------
//  The reference screens lead with "Best chances of conceiving" and, after the
//  window, "Time for a pregnancy test in 10 days". Neither is available to us,
//  and neither is a house-style disagreement:
//
//    · A chance framing on the home screen is a personalised probability by
//      implication, which CLAUDE.md forbids outright and
//      `test/ttc_clinical_review_test.dart` scans source for. We say WHEN,
//      never HOW LIKELY. "Your fertile days end today" carries the same
//      information and promises nothing.
//    · A countdown to a test is a countdown to an OUTCOME —
//      `test/ttc_home_hero_test.dart` already holds that line for the chapter
//      copy. It turns the second week of the wait into a number getting
//      smaller, which is the shape of every fertility app that makes people
//      feel worse. We count to a CYCLE EVENT — her period — which is the same
//      arithmetic pointed at something that is not a verdict on her.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT IS A LOOP, AND EVERY DAY OF IT IS ACCOUNTED FOR
//  ---------------------------------------------------------------------------
//  waiting to open → open, N days left → last day → the wait → period due →
//  period late → (period logged) → waiting to open.
//
//  `test/ttc_home_hero_test.dart` walks a whole synthetic cycle day by day and
//  asserts no day falls through to a refusal. A state machine with a hole in it
//  shows the hole for two days a month and looks fine in a screenshot.
// =============================================================================

import 'cycle_store.dart';
import 'ttc_chapter.dart';
import 'ttc_day_context.dart';
// Kept for revert: the hero read `ttcFertileWindowNow(ignoreOwnership: true)`.
// import 'ttc_fertile_window.dart';
import 'ttc_store.dart';
import 'ttc_treatment_round.dart';
import 'ttc_treatment_store.dart';

enum TtcHeroState {
  /// Nothing logged. Not a failure — an invitation.
  startHere,

  /// A clinic is running the timing. We do not run numbers alongside theirs.
  clinicHolds,

  /// The engine declined. There is a gap in the log.
  noEstimate,

  /// The window has not opened yet, this cycle.
  windowOpensIn,

  /// Inside the window, with days still to come.
  windowOpen,

  /// The last day of the window.
  windowLastDay,

  /// After the window, before the period is due. The two-week wait.
  waiting,

  /// The period is expected today.
  periodDue,

  /// It has not arrived.
  periodLate,

  // ---------------------------------------------------------------------------
  //  Added when the hero learned to follow the day strip — 2026-09-05
  // ---------------------------------------------------------------------------

  /// The selected day is in a cycle BEFORE the current one.
  ///
  /// ⚠️ NO LONGER A REFUSAL — DECIDED 2026-09-26. An earlier cycle now carries
  /// the fertile days it had, worked out looking back from THAT cycle's own
  /// length (`ttcLookBackOvulationDay`): "Cycle day N · your fertile days that
  /// cycle were around X to Y", in [TtcHeroLine.windowFrom] and
  /// [TtcHeroLine.windowTo]. The objection below was to reconstructing a past
  /// window from THIS cycle's assumptions; a completed cycle's own length is a
  /// fact she logged, so the arithmetic rests on two facts, not two guesses,
  /// and the copy says "looking back" rather than presenting it as history we
  /// observed. Still no grade, in any tense. The note below is kept for the
  /// reasoning.
  ///
  /// ⚠️ A REFUSAL, AND IT HAS TO BE. The window engine estimates ovulation for
  /// the cycle she is in now, from the signals of that cycle. It has no
  /// estimate for a cycle two months back, and the arithmetic that would
  /// produce one — assume the usual length, assume the usual luteal phase — is
  /// a guess resting on two guesses, printed as history. Somebody scrolling
  /// back to check "was I in my window that week" would be reading an invention
  /// and would have no way to tell.
  pastCycle,

  // ---------------------------------------------------------------------------
  //  The treatment states — 2026-09-05
  // ---------------------------------------------------------------------------
  //  ⚠️ THESE EXIST BECAUSE THE HERO WAS SUBTRACTING AND NOT REPLACING. When a
  //  clinic owns the timing we refuse to publish a fertile window, correctly —
  //  and then put nothing in the hole, so the biggest type on the screen said
  //  "Your clinic holds this" every day forever. Reported, repeatedly.
  //
  //  ⚠️ A TREATMENT CYCLE IS THE ONE WHERE WE KNOW *MORE*, NOT LESS.
  //  `TtcTreatmentStore` holds her clinic's own dates — stimulation, trigger,
  //  retrieval, transfer, beta — and its file header already states the
  //  principle: "we stopped competing with the clinic and started CARRYING what
  //  the clinic says." Leading on the next of those dates is that sentence
  //  applied to the hero. It is not a prediction of ours; it is her calendar.

  /// A clinic step falls on the selected day.
  treatmentToday,

  /// The next clinic step is [TtcHeroLine.days] away.
  treatmentSoon,

  /// The beta test, named by DATE rather than counted down to.
  ///
  /// ⚠️ THE ONE STEP THAT DOES NOT GET A COUNTDOWN, AND THE RULE IS WORTH
  /// STATING: count down to things she DOES, name the date of things that
  /// JUDGE. A trigger shot and a retrieval are actions and a shrinking number
  /// helps her prepare. The beta is a verdict, and a number getting smaller in
  /// the largest type on the screen is the shape that makes a two-week wait
  /// worse — the same reason the natural-cycle hero counts to a period and
  /// never to a pregnancy test.
  treatmentBeta,

  /// A FUTURE day at or past when the period is expected.
  ///
  /// ⚠️ SEPARATE FROM `periodLate` BECAUSE "3 days past your usual length" IS
  /// FALSE ABOUT A DAY THAT HAS NOT HAPPENED. The strip runs six days forward,
  /// so on day 26 of a 28-day cycle she can select a day that is arithmetically
  /// "late" and factually just Thursday.
  periodExpectedBy,

  // ---------------------------------------------------------------------------
  //  A treatment ROUND's steps — 2026-09-26 (docs/TTC-TREATMENT-FLOW.md §3a)
  // ---------------------------------------------------------------------------
  //  Additive. A round saved by the start flow (one with a kind) leads with
  //  the STEP it is on, derived from her clinic's dates (`ttcTreatmentPhase`),
  //  and the next date after it: "IVF · Stimulation / Injection day 6 / Next
  //  scan Thursday". The three states above stay for a legacy round (dates
  //  with no kind). The rule is unchanged: count days she DOES things, name
  //  the DATE of the test that judges. The blood test is never counted down.

  /// S2: pill cycle, down-regulation, baseline scan, estrogen.
  treatmentGettingReady,

  /// S3: injection or tablet day N ([TtcHeroLine.days]).
  treatmentStimulation,

  /// S4: trigger day ([TtcHeroLine.days] == 0, [TtcHeroLine.date] carries the
  /// time), or the day and a half after it.
  treatmentTrigger,

  /// S5: egg collection or IUI today ([TtcHeroLine.step]).
  treatmentProcedure,

  /// S6: embryo day N, or the lab's days on a freeze-all.
  treatmentEmbryoDays,

  /// S7: transfer day.
  treatmentTransfer,

  /// S8: the wait, with the blood test named by its DATE.
  treatmentWait,

  /// S9: blood test today ([TtcHeroLine.days] == 0), then waiting to hear.
  treatmentTestDay,

  /// S10: the round closed with a positive test.
  treatmentResult,

  /// S11: a closed round still holds this cycle; her own cycle comes back
  /// with the next period she logs.
  treatmentBetweenRounds,
}

/// The round states, for surfaces that treat them as one family.
const Set<TtcHeroState> kTtcRoundHeroStates = {
  TtcHeroState.treatmentGettingReady,
  TtcHeroState.treatmentStimulation,
  TtcHeroState.treatmentTrigger,
  TtcHeroState.treatmentProcedure,
  TtcHeroState.treatmentEmbryoDays,
  TtcHeroState.treatmentTransfer,
  TtcHeroState.treatmentWait,
  TtcHeroState.treatmentTestDay,
  TtcHeroState.treatmentResult,
  TtcHeroState.treatmentBetweenRounds,
};

/// Which state the home hero is in, and the numbers it needs.
///
/// ⚠️ NO STRINGS. This returns a state and two integers; `ttc_strings.dart`
/// turns them into words. The reason is that the clinical review scans source
/// for claim-shaped sentences, and a file that both decides and phrases is a
/// file where a careless edit changes what the app asserts about her body
/// without anybody reviewing a string.
class TtcHeroLine {
  const TtcHeroLine(this.state,
      {this.days = 0,
      this.cycleDay,
      this.step,
      this.date,
      this.windowFrom,
      this.windowTo,
      this.kind,
      this.countStep,
      this.nextStep,
      this.nextOn,
      this.upcomingStep,
      this.upcomingOn});

  final TtcHeroState state;

  // ---- a round (2026-09-26) -------------------------------------------------

  /// The round's kind, for the eyebrow ("IVF · Stimulation").
  final TtcRoundKind? kind;

  /// The step [days] counts from (estrogen, stimulation, collection,
  /// transfer), when the state counts days.
  final TtcTreatmentStep? countStep;

  /// The next clinic date after the day: a step, or a scan when [nextStep]
  /// is null and [nextOn] is set.
  final TtcTreatmentStep? nextStep;
  final DateTime? nextOn;

  /// S1: a planned round's first date, shown under her own cycle's line
  /// ("IVF starts with a scan on Tue 14 Oct"). A scan when [upcomingStep] is
  /// null and [upcomingOn] is set.
  final TtcTreatmentStep? upcomingStep;
  final DateTime? upcomingOn;

  /// This line with a planned round's first date added.
  TtcHeroLine withUpcoming(TtcTreatmentStep? step, DateTime on) => TtcHeroLine(
        state,
        days: days,
        cycleDay: cycleDay,
        step: this.step,
        date: date,
        windowFrom: windowFrom,
        windowTo: windowTo,
        kind: kind,
        countStep: countStep,
        nextStep: nextStep,
        nextOn: nextOn,
        upcomingStep: step,
        upcomingOn: on,
      );

  /// Which clinic step the treatment states are about.
  final TtcTreatmentStep? step;

  /// The date that step falls on. Only the beta state prints it.
  final DateTime? date;

  /// An earlier cycle's fertile days, worked out looking back from that
  /// cycle's own length ([TtcHeroState.pastCycle] only). Null when there is no
  /// window to show for it (a clinic ran it, or its length looks like a missed
  /// log).
  final DateTime? windowFrom;
  final DateTime? windowTo;

  /// Meaning depends on the state: days until the window opens, days of window
  /// remaining including today, days until the period, or days late.
  final int days;

  /// Shown as the tappable "Cycle day N" footer. Null where we have refused,
  /// because a cycle day printed under "not enough to say yet" is the same
  /// overreach in smaller type.
  final int? cycleDay;
}

/// ⚠️ THE ORDER OF THESE CHECKS IS THE TRUTH HIERARCHY, NOT CONVENIENCE. A
/// clinic outranks our calculation by six places, so it is asked before any
/// arithmetic runs — not after, as a label on top of a number we already
/// computed.
///
/// [on] is the day the STRIP is standing on, which is not always today.
/// Reported by pointing at the reference app: its hero says "today and 2 more
/// days" while the strip sits on the 3rd and today is the 5th, and "end today"
/// once the strip is back on the 5th. The rest of our screen already followed
/// the selection — the heading, the insight cards, the symptom sheet, and the
/// two actions, which already dim on a future day. The hero was the one piece
/// still describing today from inside a page describing another day.
TtcHeroLine ttcHomeHeroLine({DateTime? on}) {
  final line = _heroLine(on);
  // ---- S1: a planned round, named under her own cycle's line ---------------
  //
  // ⚠️ ADDITIVE, AND ONLY UNDER HER OWN CYCLE'S STATES (2026-09-26, §3a). A
  // round whose first treatment date is still ahead does not hand the cycle
  // over (decision 1), so the big line stays hers; the round's first date
  // rides along for the small line: "IVF starts with a scan on Tue 14 Oct."
  final round = TtcTreatmentStore.instance.cycle;
  if (round.kind == null || round.isClosed) return line;
  if (line.state == TtcHeroState.clinicHolds ||
      line.state == TtcHeroState.treatmentToday ||
      line.state == TtcHeroState.treatmentSoon ||
      line.state == TtcHeroState.treatmentBeta ||
      kTtcRoundHeroStates.contains(line.state)) {
    return line;
  }
  final day = _dayOnly(on ?? DateTime.now());
  if (ttcTreatmentPhase(round, day) != TtcRoundPhase.planned) return line;
  final first = ttcFirstTreatmentDate(round);
  if (first == null) return line;
  TtcTreatmentStep? step;
  for (final s in TtcTreatmentStep.values) {
    final at = round[s];
    if (at != null && _dayOnly(at) == first) {
      step = s;
      break;
    }
  }
  return line.withUpcoming(step, first);
}

TtcHeroLine _heroLine(DateTime? on) {
  final today = TtcStore.instance.today;

  if (today.noEstimate == TtcNoEstimate.noPeriodLogged) {
    return const TtcHeroLine(TtcHeroState.startHere);
  }
  // ⚠️ THE `clinicInvolved` EARLY RETURN IS GONE — 2026-09-05, AND IT WAS THE
  // WHOLE BUG. Reported after a device pass: *"Still your clinic holds. This is
  // the line that I keep seeing again and again, nothing changes."* Every state
  // added the day before was unreachable on a clinic-run account, because this
  // check sat above all of them and returned first.
  //
  // ⚠️ AND THE FIELD ITSELF SAYS NOT TO DO THIS. `ttc_chapter.dart`:
  // *"Convenience for the many surfaces that only care 'is anyone else
  // involved?' — a card heading, a disclaimer. Anything that changes what is
  // COMPUTED must use `behaviour` instead."* Branching the hero on it is
  // exactly the misuse that sentence exists to prevent, and the refusal it was
  // trying to enforce is ALREADY enforced one layer down:
  // `ttcFertileWindowNow` opens with `if (!today.behaviour.showsFertilityWindow)
  // return null`. The guard was not just misplaced, it was redundant.
  //
  // ⚠️ WHAT A CLINIC ACTUALLY FORBIDS IS A PREDICTION, NOT A FACT. The truth
  // hierarchy says we do not compute a window alongside theirs. Her cycle day
  // is not a computation — it is her own logged period subtracted from the
  // date, the one number on this screen that is hers rather than ours. So a
  // clinic-run cycle still gets a hero that moves every morning.

  // ---- her clinic's own calendar, before anything of ours ------------------
  //
  // ⚠️ IT IS CHECKED FIRST BECAUSE IT OUTRANKS EVERYTHING WE COULD COMPUTE.
  // The truth hierarchy puts a treating clinician at the top and ParentVeda's
  // calculation second from the bottom. A date her clinic gave her is not our
  // estimate at all — it is the strongest fact on this screen, and it was the
  // only one the hero never looked at.
  //
  // ⚠️ A ROUND LEADS WITH ITS STEP, A LEGACY ROUND WITH ITS NEXT DATE
  // (2026-09-26). A round saved by the start flow has a kind, and on a day it
  // is running the hero names the step (`_roundLine`). A legacy round keeps
  // the next-date line, now only for a day in the cycle she is in or in a
  // cycle the round ran in: earlier cycles from before treatment keep their
  // own look-back line (the resolver's decision). Kept for revert:
  //   final line = _treatmentLine(on);
  //   if (line != null) return line;
  if (today.clinicInvolved) {
    final round = TtcTreatmentStore.instance.cycle;
    final at = _dayOnly(on ?? DateTime.now());
    if (round.kind != null) {
      final line = _roundLine(round, at);
      if (line != null) return line;
    } else {
      final c = ttcDayContext(at);
      if (!c.isPastCycle || c.cycleClinicOwned) {
        final line = _treatmentLine(on);
        if (line != null) return line;
      }
    }
    final between = _betweenRoundsLine(at);
    if (between != null) return between;
  }

  // ⚠️ `ignoreOwnership: true` IS GONE — 2026-09-26, CONSISTENCY PASS. The
  // hero was the one surface that published a window into a clinic-owned
  // cycle (by the 2026-09-05 decision recorded on `ttcFertileWindowNow`),
  // which made it the one surface disagreeing with everything below it: on
  // such a cycle the insight cards, the reads, the calendar, the window door
  // and the messages all (correctly) refuse, so the hero said "your fertile
  // days open in 3 days" above cards chosen for "we do not know". The brief
  // for this pass says it in as many words: clinic-owned cycles get no
  // phase-based prediction anywhere, consistently.
  //
  // What the 2026-09-05 decision was protecting is kept: the hero does NOT go
  // back to a clinic refusal. It leads on her clinic's dates when there are
  // any (above), and otherwise on her own cycle day, with the way out ("Not on
  // treatment? Change this") as its second line, so it still moves every
  // morning and is never a dead end. Kept for revert:
  //   final window = ttcFertileWindowNow(ignoreOwnership: true);
  //
  // ⚠️ AND THE LABEL CAN NO LONGER PUT HER HERE (2026-09-26, the user's
  // decision). A clinic owns the timing only when the treatment tracker holds
  // a real date for this cycle (`TtcStore.ownership`), so the account with
  // "one stray tap on IVF" that the 2026-09-05 exception protected now gets
  // her own cycle's window on the hero AND on every card, and a clinic-held
  // hero always has her clinic's dates behind it: the next one leads, and
  // once all have passed, her cycle day with a way to add the next.
  // `ignoreOwnership` itself is retired in `ttc_fertile_window.dart`.
  final start = CycleStore.instance.lastPeriodStart;
  if (start == null) {
    // Nothing logged is the invitation on every pathway, not a refusal.
    return const TtcHeroLine(TtcHeroState.startHere);
    // Kept for revert: return const TtcHeroLine(TtcHeroState.noEstimate);
  }

  final now = _dayOnly(DateTime.now());
  final day = on == null ? now : _dayOnly(on);
  final anchor = _dayOnly(start);

  // THE one resolver: the same window, due date and history test the cards,
  // the calendar, the window door and the messages read.
  final ctx = ttcDayContext(day);

  // ---- a day in an earlier cycle -------------------------------------------
  //
  // ⚠️ IT NAMES THE DAY NOW — CORRECTED 2026-09-05. This returned a bare
  // "An earlier cycle", which was reported as saying nothing: *"flo says if i
  // go way back 'past cycle: day 17'… why are we still on past cycle?"*
  //
  // The refusal was over-applied. What we cannot honestly reconstruct for a
  // past cycle is a FERTILE WINDOW — that needs an ovulation estimate for a
  // cycle whose signals we no longer have, and printing one as history is a
  // guess she has no way to identify. Her cycle DAY is not that: it is the date
  // minus whichever logged period she was in, arithmetic on her own data, and
  // exactly as true for August as for today.
  //
  // ⚠️ AND STILL NO FERTILITY GRADE. The reference app pairs its day number
  // with "low chances of getting pregnant". That is the personalised
  // probability CLAUDE.md forbids outright, and it does not become allowed by
  // being in the past.
  if (day.isBefore(anchor)) {
    // The period she was actually in on that date — the latest start on or
    // before it. `periodStarts` is kept sorted, so the last match wins.
    DateTime? was;
    for (final st in CycleStore.instance.periodStarts) {
      final d = _dayOnly(st);
      if (!d.isAfter(day)) was = d;
    }
    if (was == null) {
      // Earlier than anything she has logged. There is no cycle to be a day of.
      return const TtcHeroLine(TtcHeroState.pastCycle);
    }
    // ⚠️ AND ITS FERTILE DAYS, LOOKING BACK (2026-09-26): the resolver's own
    // look-back window for that cycle, the one the calendar shades and the
    // report bands, so all three name the same days.
    return TtcHeroLine(TtcHeroState.pastCycle,
        days: day.difference(was).inDays + 1,
        date: was,
        windowFrom: ctx.lookingBack ? ctx.windowOpensOn : null,
        windowTo: ctx.lookingBack ? ctx.windowClosesOn : null);
  }

  final cycleDay = day.difference(anchor).inDays + 1;
  final future = day.isAfter(now);

  // ---- no window to speak of, for two different reasons --------------------
  //
  // ⚠️ THE CYCLE DAY TRAVELS WITH BOTH. It rides in `days` rather than in
  // `cycleDay`, because `cycleDay` draws the tappable footer and these two
  // states put the number in the HEADLINE — printing it twice on one small
  // block is how a refusal ends up looking like a dashboard.
  final opensDay = ctx.windowOpensCycleDay;
  final closesDay = ctx.windowClosesCycleDay;
  if (opensDay == null || closesDay == null) {
    return today.clinicInvolved
        ? TtcHeroLine(TtcHeroState.clinicHolds, days: cycleDay)
        : TtcHeroLine(TtcHeroState.noEstimate, days: cycleDay);
  }

  // ---- the window, compared on CYCLE DAYS ----------------------------------
  //
  // ⚠️ `opensCycleDay` AND `closesCycleDay` ARE WITHIN-CYCLE NUMBERS, WHICH IS
  // WHY THIS WORKS FOR ANY DAY. `TtcFertileWindow` also carries `openNow` and
  // `daysUntilOpen`, and both are measured from TODAY — using them would have
  // pinned the hero to today no matter which day was selected, which is the bug
  // being fixed. The cycle-day fields are the same window described in a frame
  // that does not move.
  if (cycleDay < opensDay) {
    return TtcHeroLine(TtcHeroState.windowOpensIn,
        days: opensDay - cycleDay, cycleDay: cycleDay);
  }
  if (cycleDay < closesDay) {
    return TtcHeroLine(TtcHeroState.windowOpen,
        days: closesDay - cycleDay + 1, cycleDay: cycleDay);
  }
  if (cycleDay == closesDay) {
    return TtcHeroLine(TtcHeroState.windowLastDay, cycleDay: cycleDay);
  }

  // ---- past the window: the wait, then the period --------------------------
  //
  // ⚠️ THE CYCLE LENGTH IS AN ESTIMATE AND THE COPY SAYS SO. `cycleLength` is
  // her usual length, not a promise about this one; the strings for these
  // states all hedge ("may", "around", "cycles move"). A due date printed flat
  // is read as a deadline, and a period that misses a deadline is frightening
  // in a way a period that is a few days out is not.
  final length = today.cycleLength;
  if (length <= 0) {
    return const TtcHeroLine(TtcHeroState.noEstimate);
  }

  final untilPeriod = length + 1 - cycleDay;
  if (untilPeriod > 0) {
    return TtcHeroLine(TtcHeroState.waiting,
        days: untilPeriod, cycleDay: cycleDay);
  }

  // A day that has not happened cannot be "past" anything.
  if (future) {
    return TtcHeroLine(TtcHeroState.periodExpectedBy, cycleDay: cycleDay);
  }
  if (untilPeriod == 0) {
    return TtcHeroLine(TtcHeroState.periodDue, cycleDay: cycleDay);
  }
  // ⚠️ "PAST YOUR USUAL LENGTH" NEEDS A USUAL LENGTH — 2026-09-26. This said
  // it on a first cycle, where the length is the engine's 28-day default, and
  // on a history too uneven to lean on, while the cards below it (rightly)
  // stayed on the waiting days and the "late" message stayed silent. The word
  // now needs the same history the message needs (`ttcLateHistoryReliable`,
  // via `ttcDayContext`). Without it the hero says the period "may have
  // started" by now, which is true on any history. Kept for revert: the
  // periodLate return below ran unconditionally.
  if (!ctx.lateReliable) {
    return TtcHeroLine(TtcHeroState.periodExpectedBy, cycleDay: cycleDay);
  }
  return TtcHeroLine(TtcHeroState.periodLate,
      days: -untilPeriod, cycleDay: cycleDay);
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The hero for a day a round is running on: its step, the day count that
/// step keeps, and the next clinic date after the day (§3a). Null on a day
/// the round is not running (planned, or before its first treatment date).
///
/// ⚠️ THE BLOOD TEST IS A DATE, NEVER A COUNT. In the wait the big line is
/// "Blood test on Fri 24 Oct"; the count is the days AFTER transfer, which is
/// a thing that has happened, not a verdict getting closer.
TtcHeroLine? _roundLine(TtcTreatmentCycle round, DateTime day) {
  final phase = ttcTreatmentPhase(round, day);
  if (!phase.isRunning) return null;
  final count = ttcRoundDayCount(round, phase, day);
  final next = ttcRoundNextAfter(round, day);

  TtcHeroLine line(TtcHeroState s,
          {int days = 0, TtcTreatmentStep? step, DateTime? date}) =>
      TtcHeroLine(s,
          days: count?.$1 ?? days,
          countStep: count?.$2,
          kind: round.kind,
          nextStep: next?.$1,
          nextOn: next?.$2,
          step: step,
          date: date);

  switch (phase) {
    case TtcRoundPhase.gettingReady:
      return line(TtcHeroState.treatmentGettingReady);
    case TtcRoundPhase.stimulation:
      return line(TtcHeroState.treatmentStimulation);
    case TtcRoundPhase.trigger:
      final trig = round[TtcTreatmentStep.trigger]!;
      return line(TtcHeroState.treatmentTrigger,
          days: day.difference(_dayOnly(trig)).inDays,
          step: TtcTreatmentStep.trigger,
          date: trig);
    case TtcRoundPhase.procedure:
      final iui = round[TtcTreatmentStep.iui];
      final isIui = (iui != null && _dayOnly(iui) == day) ||
          round.kind == TtcRoundKind.iui;
      return line(TtcHeroState.treatmentProcedure,
          step: isIui ? TtcTreatmentStep.iui : TtcTreatmentStep.retrieval,
          date: day);
    case TtcRoundPhase.embryoDays:
      return line(TtcHeroState.treatmentEmbryoDays);
    case TtcRoundPhase.transfer:
      return line(TtcHeroState.treatmentTransfer,
          step: TtcTreatmentStep.transfer, date: day);
    case TtcRoundPhase.waiting:
      final beta = round[TtcTreatmentStep.betaTest];
      return line(TtcHeroState.treatmentWait,
          step: TtcTreatmentStep.betaTest,
          date: beta == null || _dayOnly(beta).isBefore(day)
              ? null
              : _dayOnly(beta));
    case TtcRoundPhase.testDay:
      // The latest test on or before the day: the repeat, once it is here.
      final rep = round[TtcTreatmentStep.repeatBeta];
      final beta = round[TtcTreatmentStep.betaTest];
      final useRep = rep != null && !_dayOnly(rep).isAfter(day);
      final at = _dayOnly(useRep ? rep : beta!);
      return TtcHeroLine(TtcHeroState.treatmentTestDay,
          days: day.difference(at).inDays,
          kind: round.kind,
          step: useRep ? TtcTreatmentStep.repeatBeta : TtcTreatmentStep.betaTest,
          date: at,
          nextStep: next?.$1,
          nextOn: next?.$2);
    case TtcRoundPhase.ownCycle ||
          TtcRoundPhase.planned ||
          TtcRoundPhase.result ||
          TtcRoundPhase.betweenRounds:
      return null;
  }
}

/// S10 and S11: the round she last closed still holds the cycle she is in
/// (its dates fall in it), so predictions stay off until her next period. The
/// review appointment, when she added one still ahead, rides in [date].
TtcHeroLine? _betweenRoundsLine(DateTime day) {
  final store = TtcTreatmentStore.instance;
  final last = store.lastClosed;
  final start = CycleStore.instance.lastPeriodStart;
  if (last == null) return null;
  if (start != null && day.isBefore(_dayOnly(start))) return null;
  if (!ttcRoundRanDuring(last, start, null, DateTime.now())) return null;
  final review = last[TtcTreatmentStep.reviewAppointment];
  return TtcHeroLine(
    last.outcome == TtcRoundOutcome.positive
        ? TtcHeroState.treatmentResult
        : TtcHeroState.treatmentBetweenRounds,
    kind: last.kind,
    step: TtcTreatmentStep.reviewAppointment,
    date: review == null || _dayOnly(review).isBefore(day)
        ? null
        : _dayOnly(review),
  );
}


/// The next thing her clinic has her booked for, on or after [on].
///
/// Null when a clinic owns the timing but we have no dates at all — the caller
/// then falls through to the cycle-day line, which is still better than a
/// refusal and still moves every morning.
TtcHeroLine? _treatmentLine(DateTime? on) {
  final cycle = TtcTreatmentStore.instance.cycle;
  final day = _dayOnly(on ?? DateTime.now());

  // ⚠️ NO DATES MEANS FALL THROUGH, NOT "add some" — CORRECTED 2026-09-05.
  //
  // This returned a `treatmentEmpty` state whose hero read "Add your clinic
  // dates". It was built on the empty-state rule — a feature is never hidden,
  // the empty state is its advertisement — and it was the wrong rule to reach
  // for, because the hero is not that feature's shelf. It is the first thing
  // she reads every morning.
  //
  // The result was another clinic sentence in the biggest type on the screen,
  // for an account that only has a treatment path because of one stray tap and
  // has no treatment. Reported as exactly that.
  //
  // So: her clinic's calendar leads the hero when it has something to say, and
  // says nothing when it does not. The invitation to add dates belongs on the
  // treatment screen, where it already is.
  if (cycle.dates.isEmpty) return null;

  // ⚠️ THE NEXT ONE ON OR AFTER THE SELECTED DAY, NOT AFTER TODAY. The strip
  // moves, and a hero that answers "what is next" from the clock while the rest
  // of the page answers from the selection is the inconsistency that took three
  // rounds to find the first time.
  TtcTreatmentStep? bestStep;
  DateTime? bestDate;
  for (final entry in cycle.dates.entries) {
    final d = _dayOnly(entry.value);
    if (d.isBefore(day)) continue;
    if (bestDate == null || d.isBefore(bestDate)) {
      bestDate = d;
      bestStep = entry.key;
    }
  }

  // Everything is behind her. Fall through rather than printing a past date as
  // though it were coming — a cycle whose dates have all passed is between
  // cycles, and the cycle-day line is the honest thing to say.
  if (bestStep == null || bestDate == null) return null;

  final gap = bestDate.difference(day).inDays;

  if (bestStep == TtcTreatmentStep.betaTest) {
    return TtcHeroLine(TtcHeroState.treatmentBeta,
        step: bestStep, date: bestDate, days: gap);
  }
  return gap == 0
      ? TtcHeroLine(TtcHeroState.treatmentToday,
          step: bestStep, date: bestDate)
      : TtcHeroLine(TtcHeroState.treatmentSoon,
          step: bestStep, date: bestDate, days: gap);
}
