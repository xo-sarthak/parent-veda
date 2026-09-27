// =============================================================================
//  Where she is, as the TTC home needs to know it
// -----------------------------------------------------------------------------
//  Added 2026-09-26 for the gap analysis's home work ("Behind: Home & daily",
//  "Behind: Guided help"). The home stopped being the same page every day of
//  the cycle: its daily card and its four reads follow her phase, its top line
//  says "Time to test" when a test can answer, its doors lead with what fits
//  her situation, and a calm card appears when it may be time for a check.
//
//  Every decision lives here, pure or reading stores, and the screen only
//  chooses words. Three reasons:
//
//    * The messages the app sends (`ttc_messages_store.dart`) make the same
//      calls. "Late" and "trying a while" come from the SAME functions there,
//      so the home and a notification can never disagree about a date.
//    * `test/ttc_home_gap_test.dart` can walk these without pumping a widget.
//    * The clinical review scans source for claim-shaped sentences; a file
//      that decides but does not phrase is easier to keep honest.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE CLINICAL RULES, AND WHERE EACH IS HELD
//  ---------------------------------------------------------------------------
//
//  * A clinic-run cycle is never phased by us and never told "Time to test":
//    `TimingOwnership` decides, before any date is read. Her clinic's blood
//    test is the answer there, and luteal support delays the period.
//  * "Late" needs a history that can carry it: `ttcReliableLateAdvice`.
//  * Door order changes ORDER, never which doors exist (CLAUDE.md: "Per-user
//    or per-pathway navigation" is refused; personalisation changes content,
//    ranking and order).
//  * Nothing here is a chance. A due date "if this cycle works" is arithmetic
//    on a day she chose to look at, stated as a condition, never as a hope.
// =============================================================================

import 'cycle_store.dart';
// Kept for revert: only the old phase code below read it.
// import 'ttc_care_pathway.dart' show TimingOwnership;
// Back since 2026-09-26, for the round's switch and the treatment label.
import 'ttc_care_pathway.dart' show TimingOwnership, TtcPath;
import 'ttc_treatment_content.dart';
import 'ttc_treatment_round.dart';
import 'ttc_treatment_store.dart';
import 'ttc_content_prefs.dart';
// Kept for revert: the phase used to be worked out here, see `ttcHomePhaseOn`.
// import 'ttc_cycle_report.dart' show ttcBleedDaysFor;
import 'ttc_daily_data.dart';
import 'ttc_day_context.dart';
import 'ttc_log_store.dart';
import 'ttc_messages_store.dart';
import 'ttc_period_due.dart';
import 'ttc_phase_reads.dart';
import 'ttc_store.dart';
import 'ttc_symptom_data.dart';

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

// =============================================================================
//  1. Late, and period day 1
// =============================================================================

/// The home's "Time to test" advice for [now], or null.
///
/// Non-null only when her period is at least a day past her usual length, on
/// her own cycle (never a clinic's), with a history steady enough to call it
/// late (the same [ttcReliableLateAdvice] the "late" message uses), and not so
/// late that a missed log is the likelier story (`looksStale`, over two weeks).
TtcTestAdvice? ttcHomeLateAdvice({DateTime? now, TtcMessageFacts? facts}) {
  final f = facts ?? TtcMessageFacts.fromStores();
  if (f.pregnancyConfirmed) return null;
  final at = now ?? DateTime.now();
  final a = ttcReliableLateAdvice(f, at);
  if (a == null || a.branch != TtcTestBranch.late) return null;
  if (a.daysLate < 1 || a.looksStale) return null;
  // ⚠️ AND ONLY WHEN THE ONE RESOLVER AGREES TODAY IS LATE (2026-09-26,
  // consistency pass). The advice and `ttcDayContext` are built from the same
  // due date and the same history test, so this is normally a no-op; it is
  // here so that "Time to test" can never sit above cards chosen for a
  // different stretch. Skipped when a test hands in its own [facts], because
  // those describe a history the stores do not hold.
  if (facts == null && ttcDayContext(at).phase != TtcDayPhase.late) {
    return null;
  }
  return a;
}

/// Whether [day] is the first day of a NEW period: the latest one she logged,
/// and not the first she ever logged (that one is usually typed in while
/// setting up, and "if you were hoping this month" is the wrong thing to say
/// to someone who has just arrived). The same rule as the "period came"
/// message.
bool ttcIsNewPeriodDayOne(DateTime day, {List<DateTime>? starts}) {
  final all = [...(starts ?? CycleStore.instance.periodStarts).map(_day)]
    ..sort();
  if (all.length < 2) return false;
  return all.last == _day(day);
}

// =============================================================================
//  2. The phase, for choosing the daily card and the reads
// =============================================================================

/// Which stretch of her cycle [day] is in, for choosing content.
///
/// ⚠️ ONE ANSWER SINCE 2026-09-26: `ttcDayContext(day).phase`, the same
/// resolver the hero, the calendar and the rest of the stage read, so the
/// cards and reads are always chosen for the stretch the hero is describing.
/// [TtcDayPhase.any] whenever it is not ours to say: nothing logged, a cycle a
/// clinic is timing, or a day with no estimate behind it (a logged period day
/// stays [TtcDayPhase.period], because that is her record, not our estimate).
/// "Late" starts the day after the due day, only on a day that has happened
/// and only with a history that can carry it; otherwise the waiting days.
TtcDayPhase ttcHomePhaseOn(DateTime day) => ttcDayContext(day).phase;

// ⚠️ KEPT FOR REVERT, AND WHY IT WENT (2026-09-26, consistency pass). This
// worked the phase out for itself, and disagreed with the hero in three
// places: it called the expected-period day itself "late" (`cycleDay >
// usualLength`) where the hero, the calendar and the chat all say "due today";
// it phased an EARLIER cycle's days with this cycle's ovulation estimate while
// the hero says in words that we do not do that; and it dropped a logged
// period day to `any` whenever the engine refused an estimate. The rules now
// live once, in `ttc_day_context.dart`.
//
// TtcDayPhase ttcHomePhaseOn(DateTime day) {
//   final store = TtcStore.instance;
//   final today = store.today;
//   if (today.ownership != TimingOwnership.parentveda) return TtcDayPhase.any;
//   final ov = today.estimatedOvulationDay;
//   final length = today.cycleLength;
//   if (ov == null || length <= 0) return TtcDayPhase.any;
//
//   final d = _day(day);
//   final starts = [...CycleStore.instance.periodStarts.map(_day)]..sort();
//   DateTime? opened;
//   for (final s in starts) {
//     if (!s.isAfter(d)) opened = s;
//   }
//   if (opened == null) return TtcDayPhase.any;
//
//   final cycleDay = d.difference(opened).inDays + 1;
//   final phase = ttcDayPhaseForCycleDay(
//     cycleDay: cycleDay,
//     ovulationDay: ov,
//     usualLength: length,
//     bleedDays: ttcBleedDaysFor(opened),
//   );
//   if (phase != TtcDayPhase.late) return phase;
//
//   final current = opened == starts.last;
//   if (!current) return TtcDayPhase.waiting;
//   return ttcLateHistoryReliable(TtcMessageFacts.fromStores())
//       ? TtcDayPhase.late
//       : TtcDayPhase.waiting;
// }

/// The one daily insight for [day], chosen by her phase, with the intimate
/// cards left out when she has asked for that.
///
/// Rotation by date happens only INSIDE the phase set (see
/// [ttcInsightsForPhase]), so a period-day card never lands in the window.
TtcInsight ttcHomeInsightFor(DateTime day, {TtcDayPhase? phase}) {
  // ⚠️ A RUNNING ROUND'S STEP FIRST (2026-09-26, §3b). A clinic cycle has no
  // natural phase (`any`), so it used to get the broad set; while a round
  // runs, the card is one written for its step. Only when no natural phase
  // applies (`any`, or none given), so a caller asking for a phase gets it.
  if (phase == null || phase == TtcDayPhase.any) {
    final step = ttcHomeRoundPhaseOn(day);
    if (step != null) {
      final card = ttcTreatmentInsightFor(step, day,
          kind: _roundFor(step)?.kind);
      if (card != null) return card;
    }
  }
  final hide = TtcContentPrefs.instance.hideIntimate;
  final picks = ttcInsightsForPhase(phase ?? ttcHomePhaseOn(day), day,
      count: 3 + kTtcIntimateInsightIds.length);
  for (final i in picks) {
    if (hide && kTtcIntimateInsightIds.contains(i.id)) continue;
    return i;
  }
  // The pool never runs dry in practice; the date rotation is the fallback.
  return ttcPickForToday(ttcInsights, now: day);
}

/// The four recommended reads for [day], by phase, intimate reads left out
/// when she has asked for that.
List<String> ttcHomeReadIdsFor(DateTime day,
    {TtcDayPhase? phase, int count = 4}) {
  // A running round's step first (2026-09-26, §3b), as for the card above.
  if (phase == null || phase == TtcDayPhase.any) {
    final step = ttcHomeRoundPhaseOn(day);
    if (step != null) {
      final ids = ttcTreatmentReadIdsFor(step, day,
          count: count, kind: _roundFor(step)?.kind);
      if (ids.isNotEmpty) return ids;
    }
  }
  final hide = TtcContentPrefs.instance.hideIntimate;
  final ids = ttcReadIdsForPhase(phase ?? ttcHomePhaseOn(day), day,
      count: count + kTtcIntimateReadIds.length);
  return [
    for (final id in ids)
      if (!(hide && kTtcIntimateReadIds.contains(id))) id,
  ].take(count).toList();
}

// =============================================================================
//  2b. A treatment round (2026-09-26, docs/TTC-TREATMENT-FLOW.md B4)
// =============================================================================

/// The round whose step [phase] describes: the current round while it runs,
/// else the round she last closed.
TtcTreatmentCycle? _roundFor(TtcRoundPhase phase) {
  final t = TtcTreatmentStore.instance;
  if (phase.isRunning) return t.cycle;
  return t.lastClosed;
}

/// The round step the home's content follows on [day], or null when no round
/// holds it (the natural phase then chooses, as before).
///
/// Non-null only while a clinic owns the cycle she is in TODAY
/// (`TtcStore.ownership`, the one switch): a running round's step on [day]
/// (S2 to S9), or, for a day in the cycle she is in, the result or "between
/// rounds" of the round she last closed while its dates still hold that
/// cycle (S10, S11). A day before any of that (an earlier cycle, or before
/// the first treatment date) is null.
TtcRoundPhase? ttcHomeRoundPhaseOn(DateTime day) {
  if (TtcStore.instance.ownership == TimingOwnership.parentveda) return null;
  final t = TtcTreatmentStore.instance;
  final d = _day(day);
  if (!t.cycle.isEmpty) {
    final p = ttcTreatmentPhase(t.cycle, d);
    if (p.isRunning) return p;
  }
  final last = t.lastClosed;
  final start = CycleStore.instance.lastPeriodStart;
  if (last == null || (start != null && d.isBefore(_day(start)))) return null;
  if (!ttcRoundRanDuring(last, start, null, DateTime.now())) return null;
  final p = ttcTreatmentPhase(last, d);
  return p == TtcRoundPhase.result || p == TtcRoundPhase.betweenRounds
      ? p
      : null;
}

/// Whether the home hides the one-tap Sex and Test row on [day] (§3e): while
/// an IVF-shaped round runs (IVF, freeze-all, not sure, a medicated frozen
/// transfer, or a legacy round), where a clinic often asks for no sex before
/// his sample and a home test before the blood test can mislead. A round of
/// tablets, an IUI or a natural frozen transfer keeps it: her own signals and
/// timed sex are what those clinics work with. Everything comes back the day
/// the round closes.
bool ttcHomeHidesQuickRow(DateTime day) {
  final step = ttcHomeRoundPhaseOn(day);
  if (step == null || !step.isRunning) return false;
  return ttcRoundIsIvfShaped(TtcTreatmentStore.instance.cycle.kind);
}

/// The blood test the home names instead of "Should I test?" on [day], while
/// a round runs: the next (or today's) test date. Null when none is dated.
DateTime? ttcHomeBloodTestOn(DateTime day) {
  final step = ttcHomeRoundPhaseOn(day);
  if (step == null || !step.isRunning) return null;
  final r = TtcTreatmentStore.instance.cycle;
  final d = _day(day);
  for (final s in [TtcTreatmentStep.betaTest, TtcTreatmentStep.repeatBeta]) {
    final at = r[s];
    if (at != null && !_day(at).isBefore(d)) return _day(at);
  }
  return null;
}

/// True when a treatment label is set with no clinic dates behind it: the
/// home's "Add your clinic's dates" card (the resolver pass's decision).
bool ttcHomeInvitesClinicDates() {
  final t = TtcTreatmentStore.instance;
  return TtcStore.instance.path != TtcPath.natural &&
      t.cycle.isEmpty &&
      TtcStore.instance.ownership == TimingOwnership.parentveda;
}

// =============================================================================
//  3. One-tap sex, into the logger's own field
// =============================================================================

/// ⚠️ THE LOGGER'S OWN IDS, NEVER A NEW KEY FOR THE SAME FACT. The symptom
/// logger stores "had sex" as the `sex_unprotected` chip under the `symptoms`
/// tracker (`ttc_symptom_data.dart`), and the calendar, the strip and the
/// cycle report all read that. A home button with its own key would be a
/// second truth about one evening.
const String kTtcSexLoggedId = 'sex_unprotected';

/// Either sex chip counts as "logged" for the button, so a protected entry
/// made in the logger lights it too.
const Set<String> kTtcSexHadIds = {'sex_unprotected', 'sex_protected'};

bool ttcSexLoggedOn(DateTime day) => TtcLogStore.instance
    .valuesOn(kTtcSymptomTracker, TtcLogStore.dayKey(day))
    .any((v) => v.value > 0 && kTtcSexHadIds.contains(v.field));

/// One tap logs sex for [day]; the next tap takes it off again. Returns the
/// new state. "None" is cleared when sex is logged, as the logger would.
bool ttcToggleSexOn(DateTime day) {
  final log = TtcLogStore.instance;
  if (ttcSexLoggedOn(day)) {
    for (final id in kTtcSexHadIds) {
      log.clear(kTtcSymptomTracker, id, on: day);
    }
    return false;
  }
  log.clear(kTtcSymptomTracker, 'sex_none', on: day);
  log.log(kTtcSymptomTracker, kTtcSexLoggedId, 1, on: day);
  return true;
}

// =============================================================================
//  4. The doors, in the order that fits her
// =============================================================================

const String kTtcDoorFertileWindow = 'ttc_conceiving';
const String kTtcDoorIvf = 'ttc_infertility';
const String kTtcDoorNotYet = 'ttc_not_yet';

/// [ids] reordered for her situation. ORDER ONLY: every id that comes in goes
/// out, once, and nothing is added (a lead door that is not in [ids], such as
/// a door still being built, is simply skipped).
///
/// Leaders, strongest first: a clinic pathway puts IVF & IUI first; trying
/// long enough for a check puts "Taking a while" next; the waiting or late
/// days put the fertile window (which holds waiting and testing) next. The
/// rest keep their own order.
List<String> ttcHomeDoorOrder(
  List<String> ids, {
  required bool clinicPathway,
  required bool tryingLong,
  required TtcDayPhase phase,
}) {
  final leaders = <String>[
    if (clinicPathway) kTtcDoorIvf,
    if (tryingLong) kTtcDoorNotYet,
    if (phase == TtcDayPhase.waiting || phase == TtcDayPhase.late)
      kTtcDoorFertileWindow,
  ].where(ids.contains).toList();
  return [
    ...leaders,
    for (final id in ids)
      if (!leaders.contains(id)) id,
  ];
}

/// [ttcHomeDoorOrder] from the live stores, for today (not the day the strip
/// is on: doors that jumped as she walked the week would be a menu moving
/// under her thumb).
List<String> ttcHomeDoorOrderNow(List<String> ids, {DateTime? now}) {
  final at = now ?? DateTime.now();
  final facts = TtcMessageFacts.fromStores();
  return ttcHomeDoorOrder(
    ids,
    clinicPathway: TtcStore.instance.today.clinicInvolved,
    tryingLong: ttcTryingLongReached(facts, at, ignoreCare: true),
    phase: ttcHomePhaseOn(at),
  );
}

// =============================================================================
//  5. "It may be time for a check"
// =============================================================================

/// The months after which the check card appears (6 or 12), when it should
/// show today, else null. The same rule as the "trying for a while" message,
/// so the card and the message agree.
int? ttcHomeCheckMonths({DateTime? now, TtcMessageFacts? facts}) {
  final f = facts ?? TtcMessageFacts.fromStores();
  return ttcTryingLongReached(f, now ?? DateTime.now())
      ? f.monthsBeforeCheck
      : null;
}

// =============================================================================
//  6. The calendar's two lines
// =============================================================================

/// Days from conception to a due date, the standard count (280 from the last
/// period, less the two weeks before ovulation).
const int kTtcConceptionToDueDays = 266;

/// "If this cycle works, your due date would be around ..." for a fertile day.
DateTime ttcDueDateIfConceivedOn(DateTime fertileDay) {
  final d = _day(fertileDay);
  return DateTime(d.year, d.month, d.day + kTtcConceptionToDueDays);
}
