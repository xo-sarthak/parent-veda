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
import 'ttc_fertile_window.dart';
import 'ttc_store.dart';
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
}

/// Which state the home hero is in, and the numbers it needs.
///
/// ⚠️ NO STRINGS. This returns a state and two integers; `ttc_strings.dart`
/// turns them into words. The reason is that the clinical review scans source
/// for claim-shaped sentences, and a file that both decides and phrases is a
/// file where a careless edit changes what the app asserts about her body
/// without anybody reviewing a string.
class TtcHeroLine {
  const TtcHeroLine(this.state,
      {this.days = 0, this.cycleDay, this.step, this.date});

  final TtcHeroState state;

  /// Which clinic step the treatment states are about.
  final TtcTreatmentStep? step;

  /// The date that step falls on. Only the beta state prints it.
  final DateTime? date;

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
  if (today.clinicInvolved) {
    final line = _treatmentLine(on);
    if (line != null) return line;
  }

  // ⚠️ `ignoreOwnership: true` — SEE THE NOTE ON `ttcFertileWindowNow`. The
  // hero does not act on the pathway guess. Her clinic's real dates are checked
  // FIRST, just above, so this only ever runs when there are none.
  final window = ttcFertileWindowNow(ignoreOwnership: true);
  final start = CycleStore.instance.lastPeriodStart;
  if (start == null) {
    return const TtcHeroLine(TtcHeroState.noEstimate);
  }

  final now = _dayOnly(DateTime.now());
  final day = on == null ? now : _dayOnly(on);
  final anchor = _dayOnly(start);

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
    return TtcHeroLine(TtcHeroState.pastCycle,
        days: day.difference(was).inDays + 1, date: was);
  }

  final cycleDay = day.difference(anchor).inDays + 1;
  final future = day.isAfter(now);

  // ---- no window to speak of, for two different reasons --------------------
  //
  // ⚠️ THE CYCLE DAY TRAVELS WITH BOTH. It rides in `days` rather than in
  // `cycleDay`, because `cycleDay` draws the tappable footer and these two
  // states put the number in the HEADLINE — printing it twice on one small
  // block is how a refusal ends up looking like a dashboard.
  if (window == null) {
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
  if (cycleDay < window.opensCycleDay) {
    return TtcHeroLine(TtcHeroState.windowOpensIn,
        days: window.opensCycleDay - cycleDay, cycleDay: cycleDay);
  }
  if (cycleDay < window.closesCycleDay) {
    return TtcHeroLine(TtcHeroState.windowOpen,
        days: window.closesCycleDay - cycleDay + 1, cycleDay: cycleDay);
  }
  if (cycleDay == window.closesCycleDay) {
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
  return TtcHeroLine(TtcHeroState.periodLate,
      days: -untilPeriod, cycleDay: cycleDay);
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);


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
