// =============================================================================
//  A treatment round: which step she is on, and whether it runs the app
// -----------------------------------------------------------------------------
//  Added 2026-09-26 for docs/TTC-TREATMENT-FLOW.md (B1 and B2). PURE: every
//  function here takes a round and a date and answers. The store holds the
//  round (`ttc_treatment_store.dart`), `TtcStore.ownership` asks
//  [ttcTreatmentActive] and [ttcRoundTier], and the home asks
//  [ttcTreatmentPhase]. No strings a person reads live here; the words are in
//  `lib/screens/ttc/ttc_round_strings.dart`.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE STEP IS DERIVED FROM HER DATES, NEVER ASKED (CLAUDE.md)
//  ---------------------------------------------------------------------------
//  She never picks "I'm in stimulation". The step is the latest clinic date on
//  or before the day, read in the order a round runs. The only things asked
//  are the unknowable ones: the kind, the dates, the embryo's day, the result.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE SWITCH (the user's decision 1, 2026-09-26)
//  ---------------------------------------------------------------------------
//  A round runs the app from its FIRST TREATMENT DATE (pill, down-regulation,
//  estrogen, first tablet or injection, baseline scan or first monitoring
//  scan, whichever is earliest) until it is CLOSED. Dates saved for next month
//  do not switch this month off: she may well be trying on her own until then.
//  The tier (who owns the timing) comes from the kind and whether a trigger is
//  dated (decision 2), which is why the two old questions are retired.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NEVER CLOSED QUIETLY (decision 3, CHANGED from the proposal)
//  ---------------------------------------------------------------------------
//  Nothing here closes a round. [ttcTreatmentNeedsCheckIn] and
//  [ttcTreatmentAskOnReturn] only say when to ASK; the answer is hers.
//
//  ⚠️ NOTHING HERE IS A CHANCE. Dates, days and steps only. No field may grow
//  that reads as how likely a round is to work. `test/ttc_clinical_review_test`
//  scans this file with the rest of `lib/ttc`.
// =============================================================================

import 'ttc_care_pathway.dart';
import 'ttc_treatment_store.dart';

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Where a round stands on a date: the design's S0 to S11.
enum TtcRoundPhase {
  /// S0. No round, or nothing dated.
  ownCycle,

  /// S1. Dated, but its first treatment date is still ahead. Her own cycle.
  planned,

  /// S2. Pill cycle, down-regulation, baseline scan, or estrogen for a frozen
  /// transfer.
  gettingReady,

  /// S3. From the first injection or tablet (or the first scan of a natural
  /// frozen transfer) to the trigger.
  stimulation,

  /// S4. Trigger day, then the day and a half before collection or IUI.
  trigger,

  /// S5. Egg collection or IUI day.
  procedure,

  /// S6. After egg collection: the lab's days, to transfer or freezing.
  embryoDays,

  /// S7. Transfer day.
  transfer,

  /// S8. The wait, to the blood test.
  waiting,

  /// S9. Test day, then waiting to hear, until she records a result.
  testDay,

  /// S10. Closed with a positive test.
  result,

  /// S11. Closed any other way: between rounds.
  betweenRounds,
}

extension TtcRoundPhaseX on TtcRoundPhase {
  /// S2 to S9: the round is running and runs the home.
  bool get isRunning =>
      index >= TtcRoundPhase.gettingReady.index &&
      index <= TtcRoundPhase.testDay.index;
}

/// The IVF family and a medicated frozen transfer: the clinic times it all,
/// and a clinic often asks for no sex before his sample (§3e).
bool ttcRoundIsIvfShaped(TtcRoundKind? kind) =>
    kind == null ||
    kind == TtcRoundKind.ivfFresh ||
    kind == TtcRoundKind.ivfFreezeAll ||
    kind == TtcRoundKind.fetMedicated ||
    kind == TtcRoundKind.notSure;

/// The pathway label a round implies, for the surfaces that still read it
/// (the door order, Ask Veda's context).
TtcPath ttcPathForKind(TtcRoundKind kind) => switch (kind) {
      TtcRoundKind.ovulationInduction => TtcPath.ovulationInduction,
      TtcRoundKind.iui => TtcPath.iui,
      TtcRoundKind.ivfFresh ||
      TtcRoundKind.ivfFreezeAll ||
      TtcRoundKind.notSure =>
        TtcPath.ivf,
      TtcRoundKind.fetMedicated ||
      TtcRoundKind.fetNatural =>
        TtcPath.frozenEmbryoTransfer,
    };

// =============================================================================
//  The rows a kind of round has, in order
// =============================================================================

/// One row of "Here's how your round usually goes": a step, or the scans.
class TtcRoundRow {
  const TtcRoundRow.step(this.step) : scans = false;
  const TtcRoundRow.scans()
      : step = null,
        scans = true;

  final TtcTreatmentStep? step;

  /// The monitoring scans, as one row with its own "Add another scan".
  final bool scans;
}

/// The rows for [kind], in the order a round of that kind usually runs. A
/// legacy round (no kind) and "not sure yet" take the IVF shape.
List<TtcRoundRow> ttcRoundRows(TtcRoundKind? kind) {
  return switch (kind) {
    TtcRoundKind.ovulationInduction => const [
        TtcRoundRow.step(TtcTreatmentStep.stimStart),
        TtcRoundRow.scans(),
        TtcRoundRow.step(TtcTreatmentStep.trigger),
        TtcRoundRow.step(TtcTreatmentStep.progesteroneStart),
        TtcRoundRow.step(TtcTreatmentStep.betaTest),
        TtcRoundRow.step(TtcTreatmentStep.reviewAppointment),
      ],
    TtcRoundKind.iui => const [
        TtcRoundRow.step(TtcTreatmentStep.stimStart),
        TtcRoundRow.scans(),
        TtcRoundRow.step(TtcTreatmentStep.trigger),
        TtcRoundRow.step(TtcTreatmentStep.iui),
        TtcRoundRow.step(TtcTreatmentStep.progesteroneStart),
        TtcRoundRow.step(TtcTreatmentStep.betaTest),
        TtcRoundRow.step(TtcTreatmentStep.reviewAppointment),
      ],
    TtcRoundKind.ivfFreezeAll => const [
        TtcRoundRow.step(TtcTreatmentStep.pillStart),
        TtcRoundRow.step(TtcTreatmentStep.downRegStart),
        TtcRoundRow.step(TtcTreatmentStep.baselineScan),
        TtcRoundRow.step(TtcTreatmentStep.stimStart),
        TtcRoundRow.scans(),
        TtcRoundRow.step(TtcTreatmentStep.trigger),
        TtcRoundRow.step(TtcTreatmentStep.retrieval),
        TtcRoundRow.step(TtcTreatmentStep.reviewAppointment),
      ],
    TtcRoundKind.fetMedicated => const [
        TtcRoundRow.step(TtcTreatmentStep.estrogenStart),
        TtcRoundRow.scans(),
        TtcRoundRow.step(TtcTreatmentStep.progesteroneStart),
        TtcRoundRow.step(TtcTreatmentStep.transfer),
        TtcRoundRow.step(TtcTreatmentStep.betaTest),
        TtcRoundRow.step(TtcTreatmentStep.repeatBeta),
        TtcRoundRow.step(TtcTreatmentStep.reviewAppointment),
      ],
    TtcRoundKind.fetNatural => const [
        TtcRoundRow.scans(),
        TtcRoundRow.step(TtcTreatmentStep.trigger),
        TtcRoundRow.step(TtcTreatmentStep.transfer),
        TtcRoundRow.step(TtcTreatmentStep.progesteroneStart),
        TtcRoundRow.step(TtcTreatmentStep.betaTest),
        TtcRoundRow.step(TtcTreatmentStep.repeatBeta),
        TtcRoundRow.step(TtcTreatmentStep.reviewAppointment),
      ],
    TtcRoundKind.ivfFresh || TtcRoundKind.notSure || null => const [
        TtcRoundRow.step(TtcTreatmentStep.pillStart),
        TtcRoundRow.step(TtcTreatmentStep.downRegStart),
        TtcRoundRow.step(TtcTreatmentStep.baselineScan),
        TtcRoundRow.step(TtcTreatmentStep.stimStart),
        TtcRoundRow.scans(),
        TtcRoundRow.step(TtcTreatmentStep.trigger),
        TtcRoundRow.step(TtcTreatmentStep.retrieval),
        TtcRoundRow.step(TtcTreatmentStep.progesteroneStart),
        TtcRoundRow.step(TtcTreatmentStep.transfer),
        TtcRoundRow.step(TtcTreatmentStep.betaTest),
        TtcRoundRow.step(TtcTreatmentStep.repeatBeta),
        TtcRoundRow.step(TtcTreatmentStep.reviewAppointment),
      ],
  };
}

/// The rows the start flow asks for first: where a round of [kind] begins.
List<TtcRoundRow> ttcRoundOpeningRows(TtcRoundKind kind) {
  return switch (kind) {
    TtcRoundKind.ovulationInduction || TtcRoundKind.iui => const [
        TtcRoundRow.step(TtcTreatmentStep.stimStart),
      ],
    TtcRoundKind.fetMedicated => const [TtcRoundRow.step(TtcTreatmentStep.estrogenStart)],
    TtcRoundKind.fetNatural => const [TtcRoundRow.scans()],
    TtcRoundKind.ivfFresh ||
    TtcRoundKind.ivfFreezeAll ||
    TtcRoundKind.notSure =>
      const [
        TtcRoundRow.step(TtcTreatmentStep.baselineScan),
        TtcRoundRow.step(TtcTreatmentStep.stimStart),
        TtcRoundRow.step(TtcTreatmentStep.pillStart),
        TtcRoundRow.step(TtcTreatmentStep.downRegStart),
      ],
  };
}

// =============================================================================
//  The switch
// =============================================================================

/// The steps that START a round, whichever comes first.
const List<TtcTreatmentStep> kTtcRoundStartSteps = [
  TtcTreatmentStep.pillStart,
  TtcTreatmentStep.downRegStart,
  TtcTreatmentStep.estrogenStart,
  TtcTreatmentStep.baselineScan,
  TtcTreatmentStep.stimStart,
];

/// The round's first treatment date, or null when nothing is dated.
///
/// The earliest start step or monitoring scan. When she has only dated later
/// steps (she started tracking mid-round), the earliest date she has, leaving
/// out the review appointment, which is not treatment.
DateTime? ttcFirstTreatmentDate(TtcTreatmentCycle r) {
  final starts = <DateTime>[
    for (final s in kTtcRoundStartSteps)
      if (r[s] case final d?) _day(d),
    for (final s in r.scans) _day(s),
  ];
  final pool = starts.isNotEmpty
      ? starts
      : <DateTime>[
          for (final e in r.dates.entries)
            if (e.key != TtcTreatmentStep.reviewAppointment) _day(e.value),
        ];
  if (pool.isEmpty) return null;
  return pool.reduce((a, b) => a.isBefore(b) ? a : b);
}

/// The last date in the round, steps and scans alike.
DateTime? ttcLastRoundDate(TtcTreatmentCycle r) {
  final all = r.allDates;
  if (all.isEmpty) return null;
  return all.reduce((a, b) => a.isAfter(b) ? a : b);
}

/// True when the round runs the app on [on]: from its first treatment date
/// until it is closed.
bool ttcTreatmentActive(TtcTreatmentCycle r, DateTime on) {
  if (r.isEmpty) return false;
  final d = _day(on);
  if (r.closedOn != null && !d.isBefore(r.closedOn!)) return false;
  final first = ttcFirstTreatmentDate(r);
  return first != null && !d.isBefore(first);
}

/// Who owns the timing while this round runs (§2a, decision 2). A legacy
/// round has no kind and answers from the IVF shape; `TtcStore` gives legacy
/// rounds the evidence rule they always had instead of calling this.
TimingOwnership ttcRoundTier(TtcTreatmentCycle r) {
  final triggered = r[TtcTreatmentStep.trigger] != null;
  return switch (r.kind) {
    TtcRoundKind.ovulationInduction || TtcRoundKind.iui => triggered
        ? TimingOwnership.clinicControlled
        : TimingOwnership.clinicGuided,
    TtcRoundKind.fetNatural => TimingOwnership.clinicGuided,
    TtcRoundKind.ivfFresh ||
    TtcRoundKind.ivfFreezeAll ||
    TtcRoundKind.fetMedicated ||
    TtcRoundKind.notSure ||
    null =>
      TimingOwnership.clinicControlled,
  };
}

/// True when this round ran during the cycle that began on [start] and ended
/// before [next] (null: the cycle she is in): a date of it falls there, or the
/// cycle lies inside the stretch it ran (first treatment date to its last
/// date, or to [today] while it is still open). For earlier cycles only;
/// `TtcStore.ownership` answers the cycle she is in.
bool ttcRoundRanDuring(
    TtcTreatmentCycle r, DateTime? start, DateTime? next, DateTime today) {
  if (r.anyDateWithin(start, next)) return true;
  if (r.kind == null) return false; // legacy: its dates are the evidence
  final first = ttcFirstTreatmentDate(r);
  final last = ttcLastRoundDate(r);
  if (first == null || last == null) return false;
  final t = _day(today);
  final end = r.isClosed ? last : (last.isAfter(t) ? last : t);
  final lo = start == null ? null : _day(start);
  final hi = next == null ? null : _day(next).subtract(const Duration(days: 1));
  // Overlap of [first, end] with [lo, hi].
  return (hi == null || !first.isAfter(hi)) && (lo == null || !end.isBefore(lo));
}

// =============================================================================
//  The step on a date
// =============================================================================

/// Where [r] stands on [date] (S0 to S11). See [TtcRoundPhase].
TtcRoundPhase ttcTreatmentPhase(TtcTreatmentCycle r, DateTime date) {
  if (r.isEmpty) return TtcRoundPhase.ownCycle;
  final d = _day(date);
  if (r.closedOn != null && !d.isBefore(r.closedOn!)) {
    return r.outcome == TtcRoundOutcome.positive
        ? TtcRoundPhase.result
        : TtcRoundPhase.betweenRounds;
  }
  final first = ttcFirstTreatmentDate(r);
  if (first == null || d.isBefore(first)) return TtcRoundPhase.planned;

  DateTime? at(TtcTreatmentStep s) => r[s] == null ? null : _day(r[s]!);
  bool on(DateTime? x) => x != null && d == x;
  bool since(DateTime? x) => x != null && !d.isBefore(x);
  final kind = r.kind;

  // ---- latest first: the blood test, then back through the round ----------
  if (since(at(TtcTreatmentStep.betaTest)) ||
      since(at(TtcTreatmentStep.repeatBeta))) {
    return TtcRoundPhase.testDay;
  }
  final xfer = at(TtcTreatmentStep.transfer);
  if (on(xfer)) return TtcRoundPhase.transfer;
  if (since(xfer)) return TtcRoundPhase.waiting;

  // IUI day. A legacy blob kept an IUI in "Egg retrieval / IUI", so an IUI
  // round reads that step too.
  final iuiDay = at(TtcTreatmentStep.iui) ??
      (kind == TtcRoundKind.iui ? at(TtcTreatmentStep.retrieval) : null);
  if (on(iuiDay)) return TtcRoundPhase.procedure;
  if (since(iuiDay)) return TtcRoundPhase.waiting;

  final opu = kind == TtcRoundKind.iui ? null : at(TtcTreatmentStep.retrieval);
  if (on(opu)) return TtcRoundPhase.procedure;
  if (since(opu)) return TtcRoundPhase.embryoDays;

  final trig = at(TtcTreatmentStep.trigger);
  if (trig != null && since(trig)) {
    switch (kind) {
      case TtcRoundKind.ovulationInduction:
        // Tablets and a trigger: the trigger day and the day after are the
        // timed days, then the wait.
        return d.difference(trig).inDays <= 1
            ? TtcRoundPhase.trigger
            : TtcRoundPhase.waiting;
      case TtcRoundKind.fetNatural:
        // The trigger times her own ovulation; the transfer follows days later.
        return on(trig) ? TtcRoundPhase.trigger : TtcRoundPhase.gettingReady;
      default:
        return TtcRoundPhase.trigger; // to the collection or the IUI
    }
  }

  if (since(at(TtcTreatmentStep.stimStart))) return TtcRoundPhase.stimulation;
  final firstScan = r.scans.isEmpty ? null : _day(r.scans.first);
  if (since(firstScan) &&
      (kind == TtcRoundKind.fetNatural ||
          kind == TtcRoundKind.ovulationInduction ||
          kind == TtcRoundKind.iui)) {
    return TtcRoundPhase.stimulation; // "scans" for these kinds
  }
  return TtcRoundPhase.gettingReady;
}

/// The day number the hero leads with in [phase] on [date], and the step it
/// counts from: injection day 6, estrogen day 6, embryo day 3, 4 days after
/// transfer. Null when the phase has no count (or its date is missing).
(int, TtcTreatmentStep)? ttcRoundDayCount(
    TtcTreatmentCycle r, TtcRoundPhase phase, DateTime date) {
  final d = _day(date);
  (int, TtcTreatmentStep)? from(TtcTreatmentStep s, {int plus = 1}) {
    final at = r[s];
    if (at == null) return null;
    final n = d.difference(_day(at)).inDays + plus;
    return n < 0 ? null : (n, s);
  }

  switch (phase) {
    case TtcRoundPhase.gettingReady:
      return from(TtcTreatmentStep.estrogenStart) ??
          from(TtcTreatmentStep.downRegStart);
    case TtcRoundPhase.stimulation:
      return from(TtcTreatmentStep.stimStart);
    case TtcRoundPhase.embryoDays:
      // Collection is day 0 in the lab's own counting.
      return from(TtcTreatmentStep.retrieval, plus: 0);
    case TtcRoundPhase.waiting:
      return from(TtcTreatmentStep.transfer, plus: 0) ??
          from(TtcTreatmentStep.iui, plus: 0) ??
          (r.kind == TtcRoundKind.iui
              ? from(TtcTreatmentStep.retrieval, plus: 0)
              : null) ??
          from(TtcTreatmentStep.trigger, plus: 0);
    default:
      return null;
  }
}

/// The next clinic date strictly after [date]: a step (with the trigger's
/// time) or a scan (step null). Null when nothing is ahead.
(TtcTreatmentStep?, DateTime)? ttcRoundNextAfter(
    TtcTreatmentCycle r, DateTime date) {
  final d = _day(date);
  (TtcTreatmentStep?, DateTime)? best;
  void consider(TtcTreatmentStep? s, DateTime at) {
    if (!_day(at).isAfter(d)) return;
    if (best == null || _day(at).isBefore(_day(best!.$2))) best = (s, at);
  }

  for (final e in r.dates.entries) {
    consider(e.key, e.value);
  }
  for (final s in r.scans) {
    consider(null, s);
  }
  return best;
}

// =============================================================================
//  The calendar's soft bands (2026-09-26, B5, §3c)
// =============================================================================

/// A stretch of a round the calendar shades, drawn from her clinic's dates
/// only. Never computed forward: with an end date missing there is no band.
enum TtcRoundBand {
  /// From the first injection (or medicine) to the trigger.
  medicine,

  /// The days between the transfer (or IUI, or a tablets round's trigger)
  /// and the blood test.
  waitingForTest,
}

/// The band [date] falls in for round [r], or null.
///
/// ⚠️ MIRROR, NEVER COMPUTE (§1, rule 1). "Injection days" run from her
/// dated first injection to her dated trigger, or to her last dated scan when
/// the trigger is not in yet; the wait runs strictly between two dates she
/// entered. A tablets round gets no medicine band (the five days are typical,
/// not hers), and a frozen transfer none (no trigger ends it). A closed round
/// shades nothing from the day it closed.
TtcRoundBand? ttcRoundBandOn(TtcTreatmentCycle r, DateTime date) {
  if (r.isEmpty) return null;
  final d = _day(date);
  if (r.closedOn != null && !d.isBefore(r.closedOn!)) return null;
  DateTime? at(TtcTreatmentStep s) => r[s] == null ? null : _day(r[s]!);
  final kind = r.kind;

  // ---- the wait: strictly between the procedure and the blood test ---------
  final beta = at(TtcTreatmentStep.betaTest);
  final from = at(TtcTreatmentStep.transfer) ??
      at(TtcTreatmentStep.iui) ??
      (kind == TtcRoundKind.iui ? at(TtcTreatmentStep.retrieval) : null) ??
      (kind == TtcRoundKind.ovulationInduction
          ? at(TtcTreatmentStep.trigger)
          : null);
  if (from != null && beta != null && d.isAfter(from) && d.isBefore(beta)) {
    return TtcRoundBand.waitingForTest;
  }

  // ---- the medicine days: first injection to the trigger -------------------
  if (kind == TtcRoundKind.ovulationInduction ||
      kind == TtcRoundKind.fetMedicated ||
      kind == TtcRoundKind.fetNatural) {
    return null;
  }
  final stim = at(TtcTreatmentStep.stimStart);
  if (stim == null) return null;
  var end = at(TtcTreatmentStep.trigger);
  if (end == null) {
    for (final s in r.scans) {
      final x = _day(s);
      if (!x.isBefore(stim) && (end == null || x.isAfter(end))) end = x;
    }
  }
  if (end == null || end.isBefore(stim)) return null;
  return !d.isBefore(stim) && !d.isAfter(end) ? TtcRoundBand.medicine : null;
}

/// The blood test that is next or today, else the most recent one.
DateTime? ttcRoundBloodTest(TtcTreatmentCycle r) =>
    r[TtcTreatmentStep.repeatBeta] ?? r[TtcTreatmentStep.betaTest];

// =============================================================================
//  The check-in: never close, always ask (decision 3)
// =============================================================================

/// Days with nothing new, and nothing ahead, after which the home asks.
const int kTtcCheckInQuietDays = 7;

/// Days away after which the first return asks before anything is assumed.
const int kTtcAskOnReturnDays = 30;

/// True when [r] is open, every date has passed, and nothing has been added
/// or changed for [kTtcCheckInQuietDays] days.
bool ttcTreatmentNeedsCheckIn(TtcTreatmentCycle r, DateTime now) {
  if (r.isEmpty || r.isClosed) return false;
  final today = _day(now);
  final all = r.allDates;
  if (all.any((d) => !d.isBefore(today))) return false;
  var last = all.reduce((a, b) => a.isAfter(b) ? a : b);
  final touched = r.lastActivity;
  if (touched != null && _day(touched).isAfter(last)) last = _day(touched);
  return today.difference(last).inDays >= kTtcCheckInQuietDays;
}

/// True when [r] is open and she last opened the app [kTtcAskOnReturnDays]
/// or more days before [now]. The store flags it on that return, so the home
/// asks before anything she logs is read as either answer.
bool ttcTreatmentAskOnReturn(
    TtcTreatmentCycle r, DateTime now, DateTime? lastOpened) {
  if (r.isEmpty || r.isClosed || lastOpened == null) return false;
  return _day(now).difference(_day(lastOpened)).inDays >= kTtcAskOnReturnDays;
}

// =============================================================================
//  Dates that look wrong: confirm, never refuse
// =============================================================================

enum TtcDateProblemKind {
  /// Before a step that comes earlier in a round.
  beforeEarlierStep,

  /// After a step that comes later in a round.
  afterLaterStep,

  /// More than [kTtcFarPastDays] days ago.
  farPast,

  /// More than [kTtcFarFutureDays] days ahead.
  farFuture,
}

class TtcDateProblem {
  const TtcDateProblem(this.kind, [this.other]);
  final TtcDateProblemKind kind;

  /// The step it clashes with, for the order problems.
  final TtcTreatmentStep? other;
}

const int kTtcFarPastDays = 90;
const int kTtcFarFutureDays = 270;

/// (earlier, later, strictly): pairs a round always runs in this order.
/// Strict pairs cannot share a day (collection is 34 to 36 hours after the
/// trigger, so never the same date).
const List<(TtcTreatmentStep, TtcTreatmentStep, bool)> _kOrder = [
  (TtcTreatmentStep.pillStart, TtcTreatmentStep.stimStart, true),
  (TtcTreatmentStep.downRegStart, TtcTreatmentStep.stimStart, true),
  (TtcTreatmentStep.baselineScan, TtcTreatmentStep.stimStart, false),
  (TtcTreatmentStep.stimStart, TtcTreatmentStep.trigger, false),
  (TtcTreatmentStep.trigger, TtcTreatmentStep.retrieval, true),
  (TtcTreatmentStep.trigger, TtcTreatmentStep.iui, true),
  (TtcTreatmentStep.retrieval, TtcTreatmentStep.transfer, true),
  (TtcTreatmentStep.estrogenStart, TtcTreatmentStep.transfer, true),
  (TtcTreatmentStep.estrogenStart, TtcTreatmentStep.progesteroneStart, false),
  (TtcTreatmentStep.progesteroneStart, TtcTreatmentStep.transfer, false),
  (TtcTreatmentStep.transfer, TtcTreatmentStep.betaTest, true),
  (TtcTreatmentStep.iui, TtcTreatmentStep.betaTest, true),
  (TtcTreatmentStep.trigger, TtcTreatmentStep.betaTest, true),
  (TtcTreatmentStep.retrieval, TtcTreatmentStep.betaTest, true),
  (TtcTreatmentStep.betaTest, TtcTreatmentStep.repeatBeta, true),
];

/// Whether putting [step] on [date] looks wrong for [r]. Her clinic's date
/// wins every time, so the screen asks her to check, and never refuses.
TtcDateProblem? ttcTreatmentDateProblem(
    TtcTreatmentCycle r, TtcTreatmentStep step, DateTime date,
    {DateTime? now}) {
  final x = _day(date);
  for (final (a, b, strict) in _kOrder) {
    if (step == b && r[a] != null) {
      final other = _day(r[a]!);
      if (x.isBefore(other) || (strict && x == other)) {
        return TtcDateProblem(TtcDateProblemKind.beforeEarlierStep, a);
      }
    }
    if (step == a && r[b] != null) {
      final other = _day(r[b]!);
      if (x.isAfter(other) || (strict && x == other)) {
        return TtcDateProblem(TtcDateProblemKind.afterLaterStep, b);
      }
    }
  }
  final today = _day(now ?? DateTime.now());
  if (today.difference(x).inDays > kTtcFarPastDays) {
    return const TtcDateProblem(TtcDateProblemKind.farPast);
  }
  if (x.difference(today).inDays > kTtcFarFutureDays) {
    return const TtcDateProblem(TtcDateProblemKind.farFuture);
  }
  return null;
}
