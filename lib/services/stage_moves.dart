// =============================================================================
//  Stage moves — one function per move between life stages (2026-10-24)
// -----------------------------------------------------------------------------
//  docs/STAGE-TRANSITIONS.md, step 1.
//
//  ⚠️ WHY ONE PLACE. Each screen used to do its own share of a move: the loss
//  page set the stage and forgot the TTC "pregnant" flag and the due date;
//  onboarding set the parenting stage and forgot the birthday, the story and
//  the Dear Baby letters. Every screen that makes a move now calls the one
//  function here, so a fix lands once and the tests (test/
//  stage_transitions_test.dart) cover every caller. TTC → Pregnancy stays in
//  `TtcTransitionEngine` (lib/ttc/ttc_transition.dart), which already was
//  this for its move.
//
//  Nothing here deletes her data. A move changes what the app shows next,
//  never what she has already told it.
// =============================================================================

import 'package:shared_preferences/shared_preferences.dart';

import '../ttc/ttc_store.dart';
import 'dear_baby_vault_store.dart';
import 'family_timeline.dart';
import 'life_stage_store.dart';
import 'pregnancy_controller.dart';

/// Weeks of pregnancy at birth when the baby came early (before 37 weeks),
/// read from the due date we already hold. Null when on time, with no real due
/// date, or for an impossible answer (under 20 weeks, or after the due date).
/// Moved from pv_you_sheets.dart's `_bornWeeksFor` (2026-10-24) so the tests
/// can reach it.
int? bornWeeksFor(DateTime dob, {PregnancyController? controller}) {
  final c = controller ?? PregnancyController.current;
  if (c == null || !c.isDueDateSet) return null;
  final daysEarly = DateTime(c.dueDate.year, c.dueDate.month, c.dueDate.day)
      .difference(DateTime(dob.year, dob.month, dob.day))
      .inDays;
  if (daysEarly <= 0) return null; // on or after the due date: not early
  final weeks = (280 - daysEarly) ~/ 7;
  return weeks < 37 && weeks >= 20 ? weeks : null;
}

/// The timeline id for a baby born on [dob] (STAGE-TRANSITIONS B3). The first
/// baby keeps the fixed 'baby_born'; a later baby, on a different day, gets an
/// id dated by its birthday, because `FamilyTimeline.add` ignores an id it
/// already holds and a second child would otherwise never enter the story.
/// Twins share a birthday and so share the one entry.
String babyBornIdFor(DateTime dob) {
  const id = 'baby_born';
  final first = FamilyTimeline.instance.byId(id);
  if (first == null) return id;
  final f = first.date;
  if (f.year == dob.year && f.month == dob.month && f.day == dob.day) return id;
  return '$id:${DateTime(dob.year, dob.month, dob.day).toIso8601String().substring(0, 10)}';
}

/// The birth: Pregnancy → Parenting.
///
/// The stage starts on the BIRTHDAY, not the day she tapped (a baby born on
/// Monday and told on Thursday is three days old, not zero), the family story
/// gets the day, and the Dear Baby letters open. The birth sheet and
/// onboarding's parenting join both call this (B4: onboarding used to date
/// the stage from sign-up, add no story entry and keep the letters shut).
///
/// The due date is kept on purpose: it is what "born early" is measured from.
Future<void> recordBirth({
  required DateTime dob,
  required String name,
  String? childId,
}) async {
  final day = DateTime(dob.year, dob.month, dob.day);
  LifeStageStore.instance.setStage(LifeStage.parenting, at: day);
  final title = name.trim().isEmpty ? 'Baby was born' : '${name.trim()} was born';
  FamilyTimeline.instance.add(
    id: babyBornIdFor(day),
    stage: LifeStage.parenting,
    kind: TimelineKind.milestone,
    titleEn: title,
    titleHi: title,
    detailEn: 'The day pregnancy ended and parenting began.',
    on: day,
  );
  await DearBabyVaultStore.instance.markBorn(
    dob: day,
    childId: childId,
    name: name,
  );
}

/// After a loss, "I'm ready. Move to trying to conceive" (STAGE-TRANSITIONS
/// B2, the user's "clean restart, loss kept", 2026-10-24).
///
/// It used to change the stage alone, which left the TTC side believing she
/// was still pregnant (the home stuck on "A new beginning", its messages
/// silent) and the old due date counting weeks. Now:
///  * the TTC side's "pregnant" mark is cleared, so its home and messages
///    work again;
///  * the due date is cleared everywhere it went (memory, phone, cloud), so
///    nothing counts weeks of a pregnancy that has ended;
///  * the stage moves to trying.
///
/// Kept, on purpose: the loss itself and its date (`PregnancyEndedStore`), her
/// cycle log, and the story. Her current cycle waits for the first period she
/// logs after the loss - `CycleStore.restartOn` derives that from the loss
/// date, so this function has nothing to set for it.
Future<void> moveToTtcAfterLoss() async {
  TtcStore.instance.clearPregnancyConfirmation();
  final ctrl = PregnancyController.current;
  if (ctrl != null) {
    await ctrl.clearDueDate();
  } else {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(PregnancyController.kDueDateKey);
      await prefs.remove(PregnancyController.kDueDateSourceKey);
    } catch (_) {/* local-first: a storage failure never blocks the move */}
  }
  LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
}
