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
// =============================================================================

import 'package:shared_preferences/shared_preferences.dart';

import '../services/family_timeline.dart';
import '../services/life_stage_store.dart';
import '../services/pregnancy_controller.dart';
import 'cycle_store.dart';
import 'ttc_journal_store.dart';
import 'ttc_store.dart';
import 'ttc_supplements_store.dart';

/// What survived the transition. Every field is a real count read back from the
/// stores - the screen shows these numbers rather than claiming "everything is
/// safe", because a number is checkable and a claim is not.
class TtcTransitionResult {
  const TtcTransitionResult({
    required this.dueDate,
    required this.weeksPregnant,
    required this.journalEntries,
    required this.timelineEvents,
    required this.supplements,
    required this.cyclesLogged,
    required this.partnerJoined,
    required this.dueDateWasDerived,
  });

  final DateTime dueDate;

  /// Pregnancy is dated from the first day of the last period, not from
  /// conception - which is why a positive test usually lands around week four.
  final int weeksPregnant;

  final int journalEntries;
  final int timelineEvents;
  final int supplements;
  final int cyclesLogged;
  final bool partnerJoined;

  /// False when we had no period logged and had to fall back to counting from
  /// the test itself. The screen says so rather than presenting a guess as a
  /// date.
  final bool dueDateWasDerived;
}

class TtcTransitionEngine {
  const TtcTransitionEngine();

  /// Naegele's rule: 280 days from the first day of the last menstrual period.
  static const int gestationDays = 280;

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
  Future<TtcTransitionResult> confirmPregnancy({DateTime? on}) async {
    final when = on ?? DateTime.now();
    final today = DateTime(when.year, when.month, when.day);

    // --- 1. the due date ----------------------------------------------------
    final lmp = CycleStore.instance.lastPeriodStart;
    final derived = lmp != null;
    // With no period logged we cannot date the pregnancy properly. Rather than
    // refuse, we assume the common case - a test taken around week four - and
    // the screen states plainly that a scan will correct it.
    final effectiveLmp = lmp ?? today.subtract(const Duration(days: 28));
    final due = dueDateFrom(effectiveLmp);

    TtcStore.instance.confirmPregnancy(on: today);

    // Stored where PregnancyController already looks, so the pregnancy app
    // needs no migration and no setup screen - it simply loads with a date.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          PregnancyController.kDueDateKey, due.toIso8601String());
    } catch (_) {/* local-first: a storage failure never blocks the moment */}

    // --- 2. the life stage --------------------------------------------------
    LifeStageStore.instance.setStage(LifeStage.pregnancy, at: today);

    // --- 3. the family's story ----------------------------------------------
    FamilyTimeline.instance.add(
      id: 'ttc_positive_test',
      stage: LifeStage.tryingToConceive,
      kind: TimelineKind.milestone,
      titleEn: 'A positive test',
      titleHi: 'Positive test',
      detailEn: 'The day this chapter ended and the next one began.',
      detailHi: 'Jis din ye chapter khatam hua aur agla shuru hua.',
      on: today,
    );
    FamilyTimeline.instance.add(
      id: 'pregnancy_started',
      stage: LifeStage.pregnancy,
      kind: TimelineKind.milestone,
      titleEn: 'Pregnancy began',
      titleHi: 'Pregnancy shuru hui',
      detailEn: 'Dated from your last period, as pregnancies always are.',
      detailHi:
          'Aapke aakhri period se gini gayi, jaise pregnancy hamesha gini jaati hai.',
      on: effectiveLmp,
    );

    // --- 4. what carried over ------------------------------------------------
    return TtcTransitionResult(
      dueDate: due,
      weeksPregnant: weeksFrom(effectiveLmp, on: today),
      journalEntries: TtcJournalStore.instance.count,
      timelineEvents: FamilyTimeline.instance.count,
      supplements: TtcSupplementsStore.instance.items.length,
      cyclesLogged: CycleStore.instance.completedCycles,
      partnerJoined: TtcStore.instance.partnerJoined,
      dueDateWasDerived: derived,
    );
  }

  /// Undoes the transition. A positive test can be mis-tapped, and this is the
  /// one write in the product where being unable to go back would be cruel.
  ///
  /// The timeline entries are removed too - a life story should not carry a
  /// pregnancy that was recorded by accident.
  Future<void> undo() async {
    TtcStore.instance.clearPregnancyConfirmation();
    LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
    FamilyTimeline.instance.remove('ttc_positive_test');
    FamilyTimeline.instance.remove('pregnancy_started');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(PregnancyController.kDueDateKey);
    } catch (_) {/* best-effort */}
  }
}
