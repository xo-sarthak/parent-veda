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

import '../screens/post_pregnancy/pp_child_profile.dart' show ChildProfileStore;
import '../screens/ttc/ttc_intro_flow.dart' show TtcIntroGate;
import '../ttc/ttc_store.dart';
import '../ttc/ttc_trying_time.dart' show TtcTryingBasis;
import 'dear_baby_vault_store.dart';
import 'family_timeline.dart';
import 'life_stage_store.dart';
import 'pregnancy_controller.dart';
import 'pregnancy_ended_store.dart';
import 'pregnancy_records.dart';
import 'reminder_store.dart';

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
  // The pregnancy's record ends in this child (R1, 2026-10-25). Before the
  // stage moves, so a phone that has never made its record yet makes it as
  // the pregnancy it still is.
  await PregnancyRecords.instance
      .end(PregnancyOutcome.birth, on: day, childId: childId)
      .catchError((_) {});
  LifeStageStore.instance.setStage(LifeStage.parenting, at: day);
  await _forgetFamilyMove(); // this pregnancy is over; no undo goes back from it
  await _forgetTryingMove(); // nor to the trying that came before it
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

/// A loss, as she tells us on "If your pregnancy has ended" (STAGE-TRANSITIONS
/// R4, 2026-10-25). The flag stops the weeks, the tip and the pregnancy
/// messages, as before; now her own pregnancy-only reminders pause too (the
/// hospital bag, the evening check-in), because the page promises the week
/// reminders stop. Her medicines and everything else she set stay on. The
/// stage stays pregnancy: moving on is her own later step.
Future<void> recordLoss() async {
  await PregnancyEndedStore.instance.markEnded();
  ReminderStore.instance.pauseForLoss();
  // Her pregnancy's record ends here (R1). Nothing of it is removed: it is
  // kept for her, to look at or delete when she chooses, never asked now.
  await PregnancyRecords.instance
      .end(PregnancyOutcome.loss, on: PregnancyEndedStore.instance.endedAt)
      .catchError((_) {});
}

/// "Go back to my pregnancy view": the loss undone, and the reminders the
/// loss paused switched back on (never one she had turned off herself).
Future<void> undoLoss() async {
  await PregnancyEndedStore.instance.undo();
  ReminderStore.instance.resumeAfterLossUndo();
  await PregnancyRecords.instance.undoEnd().catchError((_) {});
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
  // The next positive test is TTC's own move, not a return to her children.
  await _forgetFamilyMove();
}

// ---- "Add a pregnancy" from the family (STAGE-TRANSITIONS F2, 2026-10-25) ---

/// Where the family move came from, so its undo can go back exactly there.
/// Local only: the undo is a phone action, and a phone without these keys
/// works it out instead (see [pregnancyCameFromFamily]).
const String kPregnancyFromStageKey = 'pv_pregnancy_from_stage';
const String kPregnancyFromAtKey = 'pv_pregnancy_from_at';
const String kPregnancyFromTimelineKey = 'pv_pregnancy_from_timeline';

/// A parent (Parenting or the learning space) is expecting again.
///
/// ⚠️ THE STAGE MOVES TO PREGNANCY; HER CHILDREN STAY WHERE THEY ARE. A
/// pregnant mother with older children is a state the app already knows: the
/// pregnancy home is the root and each child's home opens over it from the
/// family switch. Moving into that state, rather than inventing a "parenting
/// with a pregnancy on the side", means the splash, the messages (B5 counts
/// from the stage's `enteredAt`), the WhatsApp guide, the loss path and the
/// arrival card all work unchanged.
///
/// The order is `confirmPregnancy`'s, for the same reason: the new record
/// first (it seals the last pregnancy's bag and birth plan, and setting the
/// due date re-dates whatever record is current), then the date, then the
/// stage, then the story.
Future<PregnancyRecord?> startPregnancyFromFamily({
  required DateTime due,
  required DueDateSource source,
  DateTime? today,
}) async {
  final now = today ?? DateTime.now();
  final day = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);
  final from = LifeStageStore.instance.stage ?? LifeStage.parenting;
  final fromAt = LifeStageStore.instance.enteredAt;

  final made = await PregnancyRecords.instance
      .startNew(due: dueDay, dueDateSource: source.name, today: day)
      .then<PregnancyRecord?>((r) => r)
      .catchError((_) => null);

  final ctrl = PregnancyController.current;
  if (ctrl != null) {
    await ctrl.setDueDate(dueDay, source: source);
  } else {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PregnancyController.kDueDateKey, dueDay.toIso8601String());
      await prefs.setString(PregnancyController.kDueDateSourceKey, source.name);
    } catch (_) {/* local-first */}
  }

  LifeStageStore.instance.setStage(LifeStage.pregnancy, at: day);

  // A dated id once any pregnancy has begun before (B3): `add` ignores an id
  // it already holds, so a fixed one would keep this pregnancy out of the story.
  final timelineId = FamilyTimeline.instance.byId('pregnancy_started') == null
      ? 'pregnancy_started'
      : 'pregnancy_started:${day.toIso8601String().substring(0, 10)}';
  FamilyTimeline.instance.add(
    id: timelineId,
    stage: LifeStage.pregnancy,
    kind: TimelineKind.milestone,
    titleEn: 'Pregnancy began',
    titleHi: 'Pregnancy began',
    detailEn: source.clinicOwned
        ? 'Dated by your clinic.'
        : 'Counted the way every pregnancy is, from about two weeks before conception.',
    on: dueDay.subtract(const Duration(days: 280)),
  );

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPregnancyFromStageKey, from.name);
    if (fromAt != null) {
      await prefs.setString(kPregnancyFromAtKey, fromAt.toIso8601String());
    } else {
      await prefs.remove(kPregnancyFromAtKey);
    }
    await prefs.setString(kPregnancyFromTimelineKey, timelineId);
  } catch (_) {/* local-first: the undo then works it out */}
  return made;
}

/// Did the pregnancy on screen come from the family move (and so its "the
/// test was wrong" goes back to her children, not to trying)?
///
/// The key says so on the phone that made the move. Elsewhere it is derived:
/// she has a child, and TTC did not confirm THIS pregnancy (a confirmation
/// on or after the record's start is TTC's own move).
Future<bool> pregnancyCameFromFamily() async {
  if (LifeStageStore.instance.stage != LifeStage.pregnancy) return false;
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(kPregnancyFromStageKey) != null) return true;
  } catch (_) {}
  if (!ChildProfileStore.instance.hasRealChild) return false;
  final cur = PregnancyRecords.instance.current;
  final confirmed = TtcStore.instance.pregnancyConfirmedOn;
  if (cur == null) return false;
  return confirmed == null || confirmed.isBefore(cur.startedOn);
}

/// "The test was wrong": the family move undone. The new record goes and
/// the pregnancy before it gets its bag and birth plan back, its due date
/// returns (it is what "born early" was measured from), and the stage goes
/// back to where it was, dated as it was (the child's birthday, not today).
Future<void> undoPregnancyFromFamily() async {
  LifeStage back = LifeStage.parenting;
  DateTime? at;
  String? timelineId;
  try {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(kPregnancyFromStageKey);
    if (s == LifeStage.skilling.name) back = LifeStage.skilling;
    at = DateTime.tryParse(prefs.getString(kPregnancyFromAtKey) ?? '');
    timelineId = prefs.getString(kPregnancyFromTimelineKey);
  } catch (_) {}

  if (timelineId != null) FamilyTimeline.instance.remove(timelineId);

  final made = PregnancyRecords.instance.current;
  if (made != null) {
    await PregnancyRecords.instance.undoStart(made).catchError((_) {});
  }
  final prev = PregnancyRecords.instance.latest;
  // Without the key, the stage dates from the last birth, as recordBirth did.
  at ??= prev?.endedOn;

  final ctrl = PregnancyController.current;
  final prevDue = prev?.dueDate;
  if (ctrl != null) {
    if (prevDue != null) {
      final src = DueDateSource.values.firstWhere(
          (v) => v.name == prev?.dueDateSource,
          orElse: () => DueDateSource.unknown);
      await ctrl.setDueDate(prevDue, source: src);
    } else {
      await ctrl.clearDueDate();
    }
  }

  LifeStageStore.instance.setStage(back, at: at);
  await _forgetFamilyMove();
}

Future<void> _forgetFamilyMove() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kPregnancyFromStageKey);
    await prefs.remove(kPregnancyFromAtKey);
    await prefs.remove(kPregnancyFromTimelineKey);
  } catch (_) {/* local-first */}
}

// ---- "Trying again" from the family (STAGE-TRANSITIONS R1, 2026-10-25) -------

/// Where the move came from, so its undo goes back exactly there. Local, as
/// F2's keys are.
const String kTryingFromStageKey = 'pv_trying_from_stage';
const String kTryingFromAtKey = 'pv_trying_from_at';
const String kTryingFromTimelineKey = 'pv_trying_from_timeline';
const String kTryingFromConfirmedKey = 'pv_trying_from_confirmed';
const String kTryingFromIntroSeenKey = 'pv_trying_from_intro_seen';
// T1/TC5 (2026-10-27): her "how long" pick before the move, for the undo.
const String kTryingFromBasisKey = 'pv_trying_from_basis';
const String kTryingFromBasisDateKey = 'pv_trying_from_basis_date';

/// Pure, so the tests read it: whether "Trying again" is offered. Her side,
/// in Parenting or the learning space. A pregnancy going is its own stage,
/// and trying is already trying.
bool tryingAgainOfferedFor({required LifeStage? stage, required bool father}) =>
    !father && (stage == LifeStage.parenting || stage == LifeStage.skilling);

/// A parent is trying for another baby.
///
/// ⚠️ THE STAGE MOVES TO TRYING; HER CHILDREN STAY WHERE THEY ARE. A trying
/// mother with a child is a state the app already knows (the family switch
/// lists Trying first, then the children), so the TTC home becomes the root
/// and each child's home opens over it. Nothing about the children changes.
///
/// Three things the stage alone would get wrong, the after-loss move's lesson
/// (B2):
///  * the TTC side's "pregnant" mark from the pregnancy that brought her first
///    child is cleared, or the TTC home opens on "A new beginning";
///  * the TTC introduction is owed again, so she is asked her last period,
///    how long and whether a clinic is involved, instead of the app counting
///    a cycle from a period logged years ago;
///  * the story gets the day.
/// The due date stays: it is what "born early" is measured from (M16).
Future<void> startTryingFromFamily({DateTime? today}) async {
  final now = today ?? DateTime.now();
  final day = DateTime(now.year, now.month, now.day);
  final from = LifeStageStore.instance.stage ?? LifeStage.parenting;
  final fromAt = LifeStageStore.instance.enteredAt;
  final confirmed = TtcStore.instance.pregnancyConfirmedOn;
  final introSeen = await TtcIntroGate.seen().catchError((_) => false);
  final basis = TtcStore.instance.tryingBasis;
  final basisDate = TtcStore.instance.tryingBasisDate;

  TtcStore.instance.clearPregnancyConfirmation();
  await TtcIntroGate.oweAgain().catchError((_) {});
  LifeStageStore.instance.setStage(LifeStage.tryingToConceive, at: day);
  // ⚠️ TRYING AGAIN COUNTS FROM TODAY (TC5, 2026-10-27). The intro no longer
  // asks "how long" (film only since 2026-10), so her old start stayed and
  // the doctor check counted the years with her child as years of trying.
  // She can change it ("How long have you been trying?" > Change).
  TtcStore.instance.setTryingBasis(TtcTryingBasis.again, date: day);

  final timelineId = 'trying_again:${day.toIso8601String().substring(0, 10)}';
  FamilyTimeline.instance.add(
    id: timelineId,
    stage: LifeStage.tryingToConceive,
    kind: TimelineKind.milestone,
    titleEn: 'Started trying again',
    titleHi: 'Started trying again',
    on: day,
  );

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kTryingFromStageKey, from.name);
    if (fromAt != null) {
      await prefs.setString(kTryingFromAtKey, fromAt.toIso8601String());
    } else {
      await prefs.remove(kTryingFromAtKey);
    }
    await prefs.setString(kTryingFromTimelineKey, timelineId);
    if (confirmed != null) {
      await prefs.setString(kTryingFromConfirmedKey, confirmed.toIso8601String());
    } else {
      await prefs.remove(kTryingFromConfirmedKey);
    }
    await prefs.setBool(kTryingFromIntroSeenKey, introSeen);
    if (basis != null) {
      await prefs.setString(kTryingFromBasisKey, basis.name);
    } else {
      await prefs.remove(kTryingFromBasisKey);
    }
    if (basisDate != null) {
      await prefs.setString(kTryingFromBasisDateKey, basisDate.toIso8601String());
    } else {
      await prefs.remove(kTryingFromBasisDateKey);
    }
  } catch (_) {/* local-first: the undo then goes back to parenting */}
}

/// Did the trying on screen come from the family move (so its undo goes back
/// to her children)? Only the phone that made it knows; elsewhere the row is
/// not offered, and trying carries on as any trying does.
Future<bool> tryingCameFromFamily() async {
  if (LifeStageStore.instance.stage != LifeStage.tryingToConceive) return false;
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kTryingFromStageKey) != null;
  } catch (_) {
    return false;
  }
}

/// "Not trying after all": back to where she came from, dated as it was,
/// with the TTC mark and the introduction as they were. Whatever she logged
/// in between (a period, a test) is kept: a move never deletes what she told
/// us.
Future<void> undoTryingFromFamily() async {
  var back = LifeStage.parenting;
  DateTime? at;
  String? timelineId;
  DateTime? confirmed;
  var introSeen = false;
  TtcTryingBasis? basis;
  DateTime? basisDate;
  try {
    final prefs = await SharedPreferences.getInstance();
    final b = prefs.getString(kTryingFromBasisKey);
    basis = TtcTryingBasis.values.where((v) => v.name == b).firstOrNull;
    basisDate = DateTime.tryParse(prefs.getString(kTryingFromBasisDateKey) ?? '');
    if (prefs.getString(kTryingFromStageKey) == LifeStage.skilling.name) {
      back = LifeStage.skilling;
    }
    at = DateTime.tryParse(prefs.getString(kTryingFromAtKey) ?? '');
    timelineId = prefs.getString(kTryingFromTimelineKey);
    confirmed = DateTime.tryParse(prefs.getString(kTryingFromConfirmedKey) ?? '');
    introSeen = prefs.getBool(kTryingFromIntroSeenKey) ?? false;
  } catch (_) {}

  if (timelineId != null) FamilyTimeline.instance.remove(timelineId);
  if (confirmed != null) TtcStore.instance.confirmPregnancy(on: confirmed);
  if (introSeen) await TtcIntroGate.markSeen().catchError((_) {});
  // Her "how long" pick as it was before the move (TC5, 2026-10-27).
  TtcStore.instance.setTryingBasis(basis, date: basisDate);
  LifeStageStore.instance.setStage(back, at: at);
  await _forgetTryingMove();
}

Future<void> _forgetTryingMove() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    for (final k in [
      kTryingFromStageKey,
      kTryingFromAtKey,
      kTryingFromTimelineKey,
      kTryingFromConfirmedKey,
      kTryingFromIntroSeenKey,
      kTryingFromBasisKey,
      kTryingFromBasisDateKey,
    ]) {
      await prefs.remove(k);
    }
  } catch (_) {/* local-first */}
}
