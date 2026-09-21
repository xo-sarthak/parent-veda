// =============================================================================
//  DoctorTasks — everything that needs the doctor, as ONE list
// -----------------------------------------------------------------------------
//  The Home used to lead with a nag card ("Add your bank account") riding up
//  into the photograph. The user asked whether that was fair, and the field
//  (Mobbin, 2026-09-21) answers no: Monzo puts a one-line "You have 4
//  notifications · See all"; Deel, Jobber and Craft put a bell with a count;
//  Asana and Greenlight show at most three rows with "View all"; Whatnot
//  keeps "Today's tasks — you're all caught up" so the section exists even
//  when empty. Nobody leads with the nag.
//
//  So the pile of things-that-need-her is computed ONCE here, from state the
//  stores already hold, and shown in three places from the same list:
//
//     "Needs you" on Home       → one swipe rail, work first, then set-up
//     (the bell, since 2026-09-21 evening, holds UPDATES — doctor_updates.dart
//     — not this list; a chore is not a notification)
//
//  Two kinds. SETUP is the first week (bank account, hours, QR printed, a
//  photo on the profile) and lives in the "Set up your practice" carousel as
//  well, with a done-state. WORK is the running practice (prescriptions
//  owed, a class opening, bookings paused) and is what the bell is really
//  for. Both count towards the bell; a doctor with eighteen prescriptions
//  owed sees "18" and a list, not eighteen cards.
//
//  Pure: no store is read here. The caller passes what it has, so the
//  function is testable and the Home, the Inbox and the tests agree.
// =============================================================================

enum DoctorTaskKind { setup, work }

class DoctorTask {
  const DoctorTask({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.action,
    this.urgent = false,
    this.done = false,
    this.count = 0,
  });
  final String id;
  final DoctorTaskKind kind;
  // `icon` (IconData) was removed 2026-09-21: every row, rail card and
  // update draws a DoctorMark for the id instead (doctorMarkForTask), so
  // the model carries no Material dependency.
  final String title;
  final String body;
  /// The verb on the row / card.
  final String action;
  /// A class open now, a call in ten minutes: rose well, top of the list.
  final bool urgent;
  /// Setup only: shown ticked in the carousel, not counted by the bell.
  final bool done;
  /// Work only: how many things this row stands for (18 prescriptions).
  final int count;
}

/// What the caller knows. Every field has a "don't know" default so a
/// partner account or a cold cache produces a shorter list, never a wrong one.
class DoctorTaskInput {
  const DoctorTaskInput({
    this.consults = true,
    this.accountKnown = false,
    this.hasAccount = false,
    this.accountRejected = false,
    this.hasHours = true,
    this.paused = false,
    this.qrPrinted = false,
    this.hasPhoto = false,
    this.prescriptionsOwed = 0,
    this.classesOpenNow = 0,
    this.nextClassTitle,
    this.callInMinutes,
    this.callWith,
  });
  final bool consults;
  final bool accountKnown;
  final bool hasAccount;
  final bool accountRejected;
  final bool hasHours;
  final bool paused;
  final bool qrPrinted;
  final bool hasPhoto;
  final int prescriptionsOwed;
  final int classesOpenNow;
  final String? nextClassTitle;
  final int? callInMinutes;
  final String? callWith;
}

/// The list, urgent first, then work, then setup. Setup items are included
/// with their done-state so the carousel can draw ticks; [pending] filters
/// to what still needs her.
List<DoctorTask> doctorTasks(DoctorTaskInput i) {
  final out = <DoctorTask>[];

  // ---- work -------------------------------------------------------------
  if (i.classesOpenNow > 0) {
    out.add(DoctorTask(
      id: 'class_open',
      kind: DoctorTaskKind.work,
      title: i.nextClassTitle == null ? 'A class is open' : '${i.nextClassTitle} is open',
      body: 'Your students can join. Start when you are ready.',
      action: 'Start class',
      urgent: true,
      count: i.classesOpenNow,
    ));
  }
  if (i.callInMinutes != null && i.callInMinutes! <= 15 && i.callInMinutes! >= -30) {
    final m = i.callInMinutes!;
    out.add(DoctorTask(
      id: 'call_soon',
      kind: DoctorTaskKind.work,
      title: m <= 0 ? 'Your consultation has started' : 'Consultation in $m min',
      body: i.callWith == null ? 'Join from Home or Appointments.' : 'With ${i.callWith}. Join from Home or Appointments.',
      action: 'Join',
      urgent: true,
    ));
  }
  if (i.prescriptionsOwed > 0) {
    final n = i.prescriptionsOwed;
    out.add(DoctorTask(
      id: 'rx_owed',
      kind: DoctorTaskKind.work,
      title: n == 1 ? 'A prescription is waiting' : '$n prescriptions are waiting',
      body: 'Past consultations without one. Parents see it the moment you save.',
      action: 'Write',
      count: n,
    ));
  }
  if (i.consults && i.hasHours && i.paused) {
    out.add(const DoctorTask(
      id: 'paused',
      kind: DoctorTaskKind.work,
      title: 'You are not taking bookings',
      body: 'Your hours are set but paused. Parents see no slots.',
      action: 'Resume',
    ));
  }
  if (i.accountRejected) {
    out.add(const DoctorTask(
      id: 'account_rejected',
      kind: DoctorTaskKind.work,
      title: 'We could not verify your bank account',
      body: 'Check the details and submit again. Payouts wait until it is verified.',
      action: 'Fix',
      urgent: true,
    ));
  }

  // ---- setup (only for a consulting identity) --------------------------
  if (i.consults) {
    out.add(DoctorTask(
      id: 'setup_hours',
      kind: DoctorTaskKind.setup,
      title: 'Set your hours',
      body: 'Parents book inside them. Two sessions a day is the usual shape.',
      action: 'Set hours',
      done: i.hasHours,
    ));
    out.add(DoctorTask(
      id: 'setup_account',
      kind: DoctorTaskKind.setup,
      title: 'Add your bank account',
      body: 'Required to get paid. We verify it before the first transfer.',
      action: 'Add account',
      // Unknown (no server answer yet) counts as done: never nag on a guess.
      done: !i.accountKnown || i.hasAccount,
    ));
    out.add(DoctorTask(
      id: 'setup_qr',
      kind: DoctorTaskKind.setup,
      title: 'Print your QR poster',
      body: 'On the consulting-room wall, it brings your patients to you here.',
      action: 'Open kit',
      done: i.qrPrinted,
    ));
    out.add(DoctorTask(
      id: 'setup_photo',
      kind: DoctorTaskKind.setup,
      title: 'Add your photo',
      body: 'Parents choose a face. Camera or gallery, one tap.',
      action: 'Add photo',
      done: i.hasPhoto,
    ));
  }

  out.sort((a, b) {
    if (a.urgent != b.urgent) return a.urgent ? -1 : 1;
    if (a.kind != b.kind) return a.kind == DoctorTaskKind.work ? -1 : 1;
    return 0;
  });
  return out;
}

extension DoctorTaskListX on List<DoctorTask> {
  /// What still needs her: every work item, and setup items not yet done.
  List<DoctorTask> get pending => where((t) => !t.done).toList();
  List<DoctorTask> get setup => where((t) => t.kind == DoctorTaskKind.setup).toList();
  List<DoctorTask> get work => where((t) => t.kind == DoctorTaskKind.work).toList();
  int get setupDone => setup.where((t) => t.done).length;
}
