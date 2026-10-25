// =============================================================================
//  The Transition Engine - TTC → Pregnancy
// -----------------------------------------------------------------------------
//  The master document calls this the most magical moment in the whole product,
//  and it is emphatic about what "magical" means here - it means NOTHING
//  HAPPENS:
//
//      "The day a parent records Positive Pregnancy Test, the application
//       quietly changes. No onboarding. No 'create pregnancy'. No switching
//       apps. The home simply says: a beautiful new chapter begins. Everything
//       else already knows what to do."             - TTC master, §16
//
//      "Shared Journal continues. Partner continues. Calendar continues.
//       Reports continue. Care Circle continues. Nothing is lost."
//                                                       - TTC master, §3.22
//
//  ---------------------------------------------------------------------------
//  What this engine actually does
//
//  Four things, and deliberately no more:
//
//    1. Derives the due date from her last period (Naegele's rule) and stores
//       it where PregnancyController already looks - so the pregnancy app picks
//       it up with no migration and no setup screen.
//    2. Flips the life stage.
//    3. Writes the moment into the Family Timeline.
//    4. Reports what carried over, so the one screen the couple DOES see can
//       tell them the truth rather than a marketing line.
//
//  What it does NOT do: copy, migrate or transform any data. Nothing needs
//  moving, because the journal, the timeline, the bookings and the care circle
//  were all built stage-agnostic from the first commit. That was the point.
//
//  It is also reversible. A positive test can be mis-tapped, and a stage change
//  you cannot undo would be the cruellest possible bug in this product.
//
//  ---------------------------------------------------------------------------
//  ⚠️ A POSITIVE AFTER TREATMENT IS DATED BY THE CLINIC (2026-09-26, B8)
//  ---------------------------------------------------------------------------
//  CLAUDE.md: "a clinic-owned date is not ours to second-guess". After IVF or
//  a frozen transfer the pregnancy is dated from the transfer and the
//  embryo's age, the way the clinic dates it: transfer + (266 − embryo day),
//  so a day-5 transfer gives transfer + 261, stored as
//  `DueDateSource.ivfTransfer` (clinic-owned, so the pregnancy side never
//  offers to recount it: `dueDateMayBeStale` is false for it). A date her
//  clinic simply told her is `DueDateSource.clinician`. After an IUI or
//  tablets, the last period dates it as for any pregnancy (ours,
//  `lastPeriod`), with the IUI day, else the day after the trigger, as the
//  conception day when no period is logged (ours, `conception`).
//  [ttcRoundDating] works it out without changing anything, so the screen can
//  say the date and its basis BEFORE she moves (the user's rule: nothing
//  changes silently), and [TtcTransitionEngine.confirmPregnancy] takes the
//  date and its source.
// =============================================================================

import 'package:shared_preferences/shared_preferences.dart';

import '../services/family_timeline.dart';
import '../services/life_stage_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/pregnancy_records.dart';
import 'cycle_store.dart';
// Kept for revert (2026-09-28, the user: no journal in trying to conceive).
// import 'ttc_journal_store.dart';
import 'ttc_store.dart';
import 'ttc_supplements_store.dart';
import 'ttc_treatment_store.dart';

/// What survived the transition. Every field is a real count read back from the
/// stores - the screen shows these numbers rather than claiming "everything is
/// safe", because a number is checkable and a claim is not.
class TtcTransitionResult {
  const TtcTransitionResult({
    required this.dueDate,
    required this.weeksPregnant,
    // Kept for revert (2026-09-28): required this.journalEntries,
    required this.timelineEvents,
    required this.supplements,
    required this.cyclesLogged,
    required this.partnerJoined,
    required this.dueDateWasDerived,
    this.lmpUsed,
    this.clinicOwned = false,
  });

  final DateTime dueDate;

  /// Pregnancy is dated from the first day of the last period, not from
  /// conception - which is why a positive test usually lands around week four.
  final int weeksPregnant;

  // Kept for revert (2026-09-28, journal out of TTC): the count of journal
  // entries carried over. Its only reader on screen was already commented
  // out, and the journal store is now commented out too.
  // final int journalEntries;
  final int timelineEvents;
  final int supplements;
  final int cyclesLogged;
  final bool partnerJoined;

  /// False when we had no period logged and had to fall back to counting from
  /// the test itself. The screen says so rather than presenting a guess as a
  /// date.
  final bool dueDateWasDerived;

  /// The logged period it was counted from (2026-10-22), so the screen can
  /// name the day. Null when the date came from a clinic or was guessed.
  final DateTime? lmpUsed;

  /// Dated by her clinic (a transfer, an IUI, or a date they gave). The
  /// screen never questions such a date (CLAUDE.md, a clinic-owned date is
  /// not ours to second-guess).
  final bool clinicOwned;
}

/// Whether the date on the new-chapter page needs her to look again.
///
/// The user (walk 2026-10-20): the page said "about 2 weeks pregnant". Weeks
/// count from the first day of the last period; ovulation is about two weeks
/// later, and a home test turns positive from about 8 days after it (about 3
/// weeks), usually around 4. So under 3 weeks the period she logged was
/// almost certainly not her last one, or it was a light implantation bleed,
/// which is easy to mistake for a period. We ASK, and never move her date
/// for her: the same as a midwife asking "was that bleed lighter than usual?".
enum TtcDatingCheck {
  /// Nothing to say beyond the date.
  fine,

  /// Under 21 days: a positive test is not usually possible yet.
  tooEarly,

  /// 21 to 27 days: possible with an early test. The first scan confirms.
  early,

  /// Over 10 weeks since the logged period: probably a period went unlogged.
  stale,

  /// No period logged, so about 4 weeks was assumed.
  guessed,

  /// Her clinic dated it. Never questioned.
  clinic,
}

/// Pure: which [TtcDatingCheck] applies on [today].
TtcDatingCheck ttcDatingCheck(
    {DateTime? lmp, required DateTime today, bool clinicOwned = false}) {
  if (clinicOwned) return TtcDatingCheck.clinic;
  if (lmp == null) return TtcDatingCheck.guessed;
  final days = DateTime(today.year, today.month, today.day)
      .difference(DateTime(lmp.year, lmp.month, lmp.day))
      .inDays;
  if (days < 21) return TtcDatingCheck.tooEarly;
  if (days < 28) return TtcDatingCheck.early;
  if (days > 70) return TtcDatingCheck.stale;
  return TtcDatingCheck.fine;
}

/// What a treatment round needs before its pregnancy can be dated.
enum TtcRoundDatingNeed {
  /// A date and its source are ready.
  ready,

  /// A transfer is dated but the embryo's day is not: ask it.
  embryoDay,

  /// Nothing to count from: offer the transfer date, or her clinic's date.
  noDate,
}

/// A due date worked out from a round, with where it came from.
class TtcRoundDating {
  const TtcRoundDating({
    required this.need,
    this.due,
    this.source,
    this.from,
    this.fromStep,
    this.embryoDay,
  });

  final TtcRoundDatingNeed need;
  final DateTime? due;
  final DueDateSource? source;

  /// The date it counts from, and which step that is (null: her last
  /// period).
  final DateTime? from;
  final TtcTreatmentStep? fromStep;
  final int? embryoDay;
}

/// Whether a round of [kind] is dated from its transfer.
bool ttcRoundDatesFromTransfer(TtcRoundKind? kind) =>
    kind != TtcRoundKind.iui && kind != TtcRoundKind.ovulationInduction;

/// How the pregnancy after [round] is dated (B8). Pure: nothing changes.
///
/// IVF, freeze-all, frozen transfers, "not sure" and a legacy round: the
/// transfer day plus (266 − embryo day), [DueDateSource.ivfTransfer]; with
/// the embryo day missing, [TtcRoundDatingNeed.embryoDay]. An IUI or tablets:
/// [lastPeriod] + 280 ([DueDateSource.lastPeriod]); with none logged, the IUI
/// day as conception, else the day after the trigger (ovulation follows a
/// trigger by about a day and a half), + 266 ([DueDateSource.conception]).
TtcRoundDating ttcRoundDating(TtcTreatmentCycle round,
    {DateTime? lastPeriod, int? embryoDay}) {
  DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
  final kind = round.kind;
  if (ttcRoundDatesFromTransfer(kind)) {
    final xfer = round[TtcTreatmentStep.transfer];
    if (xfer == null) {
      return const TtcRoundDating(need: TtcRoundDatingNeed.noDate);
    }
    final e = embryoDay ?? round.embryoDay;
    if (e == null) {
      return TtcRoundDating(
          need: TtcRoundDatingNeed.embryoDay,
          from: day(xfer),
          fromStep: TtcTreatmentStep.transfer);
    }
    return TtcRoundDating(
      need: TtcRoundDatingNeed.ready,
      due: day(xfer).add(Duration(days: 266 - e)),
      source: DueDateSource.ivfTransfer,
      from: day(xfer),
      fromStep: TtcTreatmentStep.transfer,
      embryoDay: e,
    );
  }
  if (lastPeriod != null) {
    return TtcRoundDating(
      need: TtcRoundDatingNeed.ready,
      due: TtcTransitionEngine.dueDateFrom(lastPeriod),
      source: DueDateSource.lastPeriod,
      from: day(lastPeriod),
    );
  }
  final iui = round[TtcTreatmentStep.iui] ??
      (kind == TtcRoundKind.iui ? round[TtcTreatmentStep.retrieval] : null);
  if (iui != null) {
    return TtcRoundDating(
      need: TtcRoundDatingNeed.ready,
      due: day(iui).add(const Duration(days: 266)),
      source: DueDateSource.conception,
      from: day(iui),
      fromStep: TtcTreatmentStep.iui,
    );
  }
  final trig = round[TtcTreatmentStep.trigger];
  if (trig != null) {
    return TtcRoundDating(
      need: TtcRoundDatingNeed.ready,
      due: day(trig).add(const Duration(days: 1 + 266)),
      source: DueDateSource.conception,
      from: day(trig),
      fromStep: TtcTreatmentStep.trigger,
    );
  }
  return const TtcRoundDating(need: TtcRoundDatingNeed.noDate);
}

class TtcTransitionEngine {
  const TtcTransitionEngine();

  /// Naegele's rule: 280 days from the first day of the last menstrual period.
  static const int gestationDays = 280;

  /// The timeline ids for the pregnancy confirmed on [day] (2026-10-24,
  /// STAGE-TRANSITIONS B3).
  ///
  /// ⚠️ A SECOND PREGNANCY USED TO VANISH FROM THE STORY. The ids were fixed
  /// ('ttc_positive_test', 'pregnancy_started') and `FamilyTimeline.add`
  /// ignores an id it already holds, so after a loss and a new positive test
  /// nothing was recorded - and an undo then deleted the FIRST pregnancy's
  /// entries. The first pregnancy keeps the fixed ids (every existing story
  /// and test reads them); a later one, on a different day, gets ids dated by
  /// its confirmation day. The same day gives the same ids, so confirming
  /// twice stays idempotent and undo finds exactly this pregnancy's entries.
  static ({String positive, String started}) timelineIdsFor(DateTime day) {
    const positive = 'ttc_positive_test';
    const started = 'pregnancy_started';
    final first = FamilyTimeline.instance.byId(positive);
    final d = DateTime(day.year, day.month, day.day);
    if (first == null) return (positive: positive, started: started);
    final f = first.date;
    if (f.year == d.year && f.month == d.month && f.day == d.day) {
      return (positive: positive, started: started);
    }
    final tag = d.toIso8601String().substring(0, 10);
    return (positive: '$positive:$tag', started: '$started:$tag');
  }

  /// Works out the due date without changing anything. Exposed separately so a
  /// screen can preview it before the couple commits.
  static DateTime dueDateFrom(DateTime lastPeriodStart) =>
      DateTime(lastPeriodStart.year, lastPeriodStart.month,
              lastPeriodStart.day)
          .add(const Duration(days: gestationDays));

  /// How many completed weeks pregnant on [on], counting from the last period.
  static int weeksFrom(DateTime lastPeriodStart, {DateTime? on}) {
    final now = on ?? DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastPeriodStart.year, lastPeriodStart.month,
            lastPeriodStart.day))
        .inDays;
    if (days < 0) return 0;
    return days ~/ 7;
  }

  /// Records the positive test and moves the family into pregnancy.
  ///
  /// Everything here is idempotent: running it twice produces the same state
  /// and one timeline entry, because a screen rebuild must never be able to
  /// double-apply the most important write in the product.
  ///
  /// [dueDate] and [source] (2026-09-26, B8): a date worked out from a
  /// treatment round, or one her clinic gave her. It is stored as given with
  /// its source, so a clinic-owned date is never recounted from her period.
  /// Without them, the last period dates it, as before.
  Future<TtcTransitionResult> confirmPregnancy(
      {DateTime? on, DateTime? dueDate, DueDateSource? source}) async {
    final when = on ?? DateTime.now();
    final today = DateTime(when.year, when.month, when.day);

    // --- 1. the due date ----------------------------------------------------
    final lmp = CycleStore.instance.lastPeriodStart;
    final given = dueDate == null
        ? null
        : DateTime(dueDate.year, dueDate.month, dueDate.day);
    final derived = given != null || lmp != null;
    // With no period logged we cannot date the pregnancy properly. Rather than
    // refuse, we assume the common case - a test taken around week four - and
    // the screen states plainly that a scan will correct it.
    //
    // A given date counts back 280 days to the start the weeks are counted
    // from, the same arithmetic the pregnancy side uses the other way.
    final effectiveLmp = given != null
        ? given.subtract(const Duration(days: gestationDays))
        : (lmp ?? today.subtract(const Duration(days: 28)));
    final due = given ?? dueDateFrom(effectiveLmp);

    TtcStore.instance.confirmPregnancy(on: today);

    // ⚠️ A NEW PREGNANCY'S RECORD, BEFORE THE DUE DATE MOVES (R1,
    // 2026-10-25). The one before it is sealed: its undated things (the bag,
    // the birth plan, scans ticked) are kept with it and this one starts
    // clean. First, because setting the due date re-dates the current record,
    // and until this runs that is still the old pregnancy's.
    await PregnancyRecords.instance
        .startNew(
            due: due,
            dueDateSource: (source ??
                    (given == null && lmp != null
                        ? DueDateSource.lastPeriod
                        : DueDateSource.unknown))
                .name,
            today: today)
        .catchError((_) => PregnancyRecord(id: '', startedOn: today));

    // ⚠️ THROUGH THE RUNNING CONTROLLER, NOT AROUND IT (2026-10-22). The user:
    // "Yes, I'm pregnant", then the button "landed me on preg week 20". This
    // wrote the date to storage only, but the pregnancy controller had read
    // storage once, at app start, and sat on its week-20 placeholder, so the
    // shell opened on week 20 until a restart. And the cloud never heard,
    // so the next launch could take the account's stale due date over hers.
    // `setDueDate` moves memory, storage and the cloud (queued if offline)
    // together. Without a controller (tests, a build where main.dart has not
    // run) the storage write below is the fallback.
    final ctrl = PregnancyController.current;
    if (ctrl != null) {
      await ctrl.setDueDate(due,
          source: source ??
              (given == null && lmp != null
                  ? DueDateSource.lastPeriod
                  : DueDateSource.unknown));
    } else {
    // Stored where PregnancyController already looks, so the pregnancy app
    // needs no migration and no setup screen - it simply loads with a date.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          PregnancyController.kDueDateKey, due.toIso8601String());
      // Where it came from (2026-09-26, B8), under the controller's own key,
      // so a date her clinic owns is read back as theirs.
      if (source != null) {
        await prefs.setString(
            PregnancyController.kDueDateSourceKey, source.name);
      } else {
        await prefs.remove(PregnancyController.kDueDateSourceKey);
      }
    } catch (_) {/* local-first: a storage failure never blocks the moment */}
    }

    // --- 2. the life stage --------------------------------------------------
    LifeStageStore.instance.setStage(LifeStage.pregnancy, at: today);

    // --- 3. the family's story ----------------------------------------------
    // Ids by pregnancy (B3, 2026-10-24); were the fixed 'ttc_positive_test'
    // and 'pregnancy_started'. Kept for revert: the two literal ids below.
    final ids = timelineIdsFor(today);
    FamilyTimeline.instance.add(
      id: ids.positive, // was 'ttc_positive_test'
      stage: LifeStage.tryingToConceive,
      kind: TimelineKind.milestone,
      titleEn: "You're pregnant", // was 'A positive test' (2026-10-10)
      titleHi: 'Positive test',
      detailEn: 'The day this chapter ended and the next one began.',
      detailHi: 'Jis din ye chapter khatam hua aur agla shuru hua.',
      on: today,
    );
    FamilyTimeline.instance.add(
      id: ids.started, // was 'pregnancy_started'
      stage: LifeStage.pregnancy,
      kind: TimelineKind.milestone,
      titleEn: 'Pregnancy began',
      titleHi: 'Pregnancy shuru hui',
      detailEn: source?.clinicOwned ?? false
          ? 'Dated by your clinic, from your treatment.'
          : 'Counted from your last period, the way every pregnancy is.',
      detailHi:
          'Aapke aakhri period se gini gayi, jaise pregnancy hamesha gini jaati hai.',
      on: effectiveLmp,
    );

    // --- 4. what carried over ------------------------------------------------
    return TtcTransitionResult(
      dueDate: due,
      weeksPregnant: weeksFrom(effectiveLmp, on: today),
      // Kept for revert (2026-09-28):
      //   journalEntries: TtcJournalStore.instance.count,
      timelineEvents: FamilyTimeline.instance.count,
      supplements: TtcSupplementsStore.instance.items.length,
      cyclesLogged: CycleStore.instance.completedCycles,
      partnerJoined: TtcStore.instance.partnerJoined,
      dueDateWasDerived: derived,
      lmpUsed: given == null ? lmp : null,
      clinicOwned: source?.clinicOwned ?? false,
    );
  }

  /// Dates the pregnancy again from the day SHE says her last period started
  /// (2026-10-22, "Change the date" on the new-chapter page). Her word beats
  /// our reading of the log (the truth hierarchy: her observation sits above
  /// our calculation). Her cycle log is left exactly as it is: only the
  /// pregnancy's date and its timeline entry move.
  Future<TtcTransitionResult> redate(
      TtcTransitionResult r, DateTime lastPeriodStart,
      {DateTime? on}) async {
    final when = on ?? DateTime.now();
    final today = DateTime(when.year, when.month, when.day);
    final lmp = DateTime(
        lastPeriodStart.year, lastPeriodStart.month, lastPeriodStart.day);
    final due = dueDateFrom(lmp);
    // Through the running controller, as in [confirmPregnancy].
    final ctrl = PregnancyController.current;
    if (ctrl != null) {
      await ctrl.setDueDate(due, source: DueDateSource.lastPeriod);
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            PregnancyController.kDueDateKey, due.toIso8601String());
        await prefs.remove(PregnancyController.kDueDateSourceKey);
      } catch (_) {/* local-first: a storage failure never blocks the moment */}
    }
    // This pregnancy's entry (B3); was the fixed 'pregnancy_started'.
    // Kept for revert:
    //   FamilyTimeline.instance.refreshDerived('pregnancy_started', on: lmp);
    final confirmed = TtcStore.instance.pregnancyConfirmedOn ?? today;
    FamilyTimeline.instance
        .refreshDerived(timelineIdsFor(confirmed).started, on: lmp);
    return TtcTransitionResult(
      dueDate: due,
      weeksPregnant: weeksFrom(lmp, on: today),
      timelineEvents: r.timelineEvents,
      supplements: r.supplements,
      cyclesLogged: r.cyclesLogged,
      partnerJoined: r.partnerJoined,
      dueDateWasDerived: true,
      lmpUsed: lmp,
    );
  }

  /// Undoes the transition. A positive test can be mis-tapped, and this is the
  /// one write in the product where being unable to go back would be cruel.
  ///
  /// The timeline entries are removed too - a life story should not carry a
  /// pregnancy that was recorded by accident.
  Future<void> undo() async {
    // Only THIS pregnancy's entries (B3, 2026-10-24): read the day before the
    // confirmation is cleared. Kept for revert:
    //   FamilyTimeline.instance.remove('ttc_positive_test');
    //   FamilyTimeline.instance.remove('pregnancy_started');
    final confirmed = TtcStore.instance.pregnancyConfirmedOn;
    final ids = confirmed == null
        ? (positive: 'ttc_positive_test', started: 'pregnancy_started')
        : timelineIdsFor(confirmed);
    TtcStore.instance.clearPregnancyConfirmation();
    LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
    FamilyTimeline.instance.remove(ids.positive);
    FamilyTimeline.instance.remove(ids.started);
    // Its record goes, and the pregnancy before it gets its things back (R1).
    final made = PregnancyRecords.instance.current;
    if (made != null) {
      await PregnancyRecords.instance.undoStart(made).catchError((_) {});
    }
    // The date goes everywhere it went (2026-10-22): memory, storage and the
    // cloud, or a mis-tap undone here comes back on the next launch or the
    // other phone. Storage only, as before, when there is no controller.
    final ctrl = PregnancyController.current;
    if (ctrl != null) {
      await ctrl.clearDueDate();
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(PregnancyController.kDueDateKey);
        await prefs.remove(PregnancyController.kDueDateSourceKey);
      } catch (_) {/* best-effort */}
    }
  }
}
