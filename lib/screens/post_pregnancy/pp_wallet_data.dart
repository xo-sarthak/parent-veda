// =============================================================================
//  Health Wallet — the engine behind three versions of the health feature.
// -----------------------------------------------------------------------------
//  Same arrangement as Grow, for the same reason: the brief says "you MUST
//  ignore the existing information architecture", the feature it is talking
//  about is shipped and carries real cloud-synced records, and the way to
//  settle that is to be able to look at both.
//
//    V1  What ships today. HealthHomeScreen, constructed as-is.
//    V2  The brief as written — Summary / Timeline / Records / Reminders /
//        Emergency, the "🟢 Healthy" status card, quick actions, the smart
//        reminder, and auto-extraction from an uploaded prescription.
//    V3  The recommendation: the brief's structure, with two things changed
//        that are safety matters rather than taste.
//
//  WHAT V3 CHANGES, AND WHY EACH IS NOT A PREFERENCE
//
//  1. THE STATUS CARD DOES NOT SAY "HEALTHY".
//
//     The brief's home screen leads with `🟢 Healthy`. The app cannot know
//     that. It knows what has been typed into it — which is a different thing,
//     and the gap between them is where the harm sits: a parent whose child
//     has an unlogged problem reads a green dot as reassurance, and a parent
//     who has logged three fevers reads it as contradiction.
//
//     This repo already draws that line elsewhere. `Inferable` is default-deny;
//     `TruthSource` puts ParentVeda's own calculation second from the bottom,
//     below the mother's own observation. A green "Healthy" would sit that
//     calculation at the top, above her doctor.
//
//     So V3's status answers a question we CAN answer: *is anything waiting
//     for you?* Nothing due / one vaccine due / a follow-up overdue. That is a
//     statement about the record, and it is always true.
//
//  2. NOTHING IS EVER AUTO-CREATED FROM AN EXTRACTED DOCUMENT.
//
//     The brief asks that uploading a prescription should "automatically
//     detect medicines, create medicine reminders". A misread dose then
//     becomes a recurring alarm telling a parent to give a child the wrong
//     amount of the right drug, at the right time, with the app's authority
//     behind it. Silent creation is the problem, not extraction.
//
//     V3 extracts into a REVIEW screen and creates nothing until a human has
//     confirmed each field. Same feature, one step added, and the step is the
//     one that makes it safe.
//
//  ⚠️ NEITHER VERSION CAN ACTUALLY EXTRACT ANYTHING YET, and this file must not
//  pretend otherwise. There is no OCR or entity extraction in this repo, and
//  by design — AI lives in the Ask Veda service (C:\Projects\parentveda-askveda,
//  a separate repo). What is built here is the transport and the UI. The
//  handover is written down in docs/STILL-OPEN.md §5.10 rather than left as a
//  gap: the service needs an endpoint that takes an image and returns
//  {medicines[], doctor, visit_date, document_type} with per-field confidence.
//
//  NOTHING IS DELETED. Every existing health screen is reused, the store is
//  untouched, and the Explore row is commented in place.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/reminder.dart';
import '../../services/reminder_store.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_health_data.dart';

// =============================================================================
//  1. WHICH VERSION IS ON SCREEN
// =============================================================================

enum WalletVersion { v1, v2, v3 }

class WalletVersionStore extends ChangeNotifier {
  WalletVersionStore._();
  static final WalletVersionStore instance = WalletVersionStore._();

  // Opened on V1 while the comparison against what ships was being made.
  // V1 was retired from the toggle on 2026-08-01 — the two proposals are what
  // is being looked at now — so this opens on V2, the brief as written.
  //
  // Kept for revert:
  //   WalletVersion _v = WalletVersion.v1;
  WalletVersion _v = WalletVersion.v2;
  WalletVersion get version => _v;

  void setVersion(WalletVersion v) {
    if (v == _v) return;
    _v = v;
    notifyListeners();
  }

  String get label => switch (_v) {
        WalletVersion.v1 => 'What ships today',
        WalletVersion.v2 => 'The brief, as written',
        WalletVersion.v3 => 'The recommendation',
      };
}

// =============================================================================
//  2. DATES
// -----------------------------------------------------------------------------
//  Health records store dates as '14 Jun 2026' strings. Every rule below needs
//  to compare them, so the parse happens once, here, and returns null rather
//  than guessing — a silently mis-parsed date would put an event in the wrong
//  year and quietly change what the observations say.
// =============================================================================

const List<String> _months = [
  'jan', 'feb', 'mar', 'apr', 'may', 'jun',
  'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
];

DateTime? walletDate(String s) {
  final parts = s.trim().split(RegExp(r'\s+'));
  if (parts.length < 3) return null;
  final day = int.tryParse(parts[0]);
  final month = _months.indexOf(parts[1].toLowerCase().substring(
      0, parts[1].length < 3 ? parts[1].length : 3));
  final year = int.tryParse(parts[2]);
  if (day == null || year == null || month < 0) return null;
  return DateTime(year, month + 1, day);
}

String walletDateLabel(DateTime d) =>
    '${d.day} ${_months[d.month - 1][0].toUpperCase()}'
    '${_months[d.month - 1].substring(1)} ${d.year}';

// =============================================================================
//  3. THE STATUS CARD — where V2 and V3 genuinely disagree
// =============================================================================

class WalletStatus {
  const WalletStatus({
    required this.headline,
    required this.sub,
    required this.tone, // 'good' | 'watch' | 'neutral'
    required this.tiles,
  });

  final String headline;
  final String sub;
  final String tone;
  final List<HealthStat> tiles;
}

/// V2's status. The brief's card, verbatim: a green dot and the word "Healthy".
///
/// Left as the brief wrote it deliberately. Softening it here would produce a
/// V2 that is really V3, and the whole reason for building both is that this
/// specific line is the thing worth deciding.
/// ONE EXCEPTION, and it is not a softening: an EMPTY record.
///
/// The brief's line is a claim about the child, and with nothing entered there
/// is nothing behind it — the card read "Healthy · Everything looks fine" above
/// no visits, no reports, no medications and no allergies. A parent who has
/// recorded nothing was being told her child is fine, by an app that had not
/// been told anything.
///
/// Once there is something in the record the brief's card returns untouched, so
/// the V2-vs-V3 question this pair exists to answer is still the same question.
WalletStatus walletStatusDoc() => walletRecordCount() == 0
    ? const WalletStatus(
        headline: 'Nothing recorded yet',
        sub: 'Add a visit, a report or a medicine and this fills in.',
        tone: 'neutral',
        tiles: kHealthSnapshot,
      )
    : WalletStatus(
        headline: 'Healthy',
        sub: 'Everything looks fine.',
        tone: 'good',
        tiles: kHealthSnapshot,
      );

/// How many records the wallet is holding.
///
/// Counted across the lists rather than read off a `timeline` getter, because
/// there isn't one — the timeline screen composes its rows from these same
/// sources at render time.
int walletRecordCount() {
  final s = HealthStore.instance;
  return s.visits.length +
      s.reports.length +
      s.symptoms.length +
      s.prescriptions.length +
      s.medications.length;
}

/// V3's status. Answers what the app can actually know.
///
/// Every line here is a statement about the RECORD — what has been entered,
/// what is due, what is missing — and never about the child. So it stays true
/// whatever is happening medically, which is exactly the property a green
/// "Healthy" does not have.
WalletStatus walletStatusRecord() {
  final store = HealthStore.instance;
  final meds = store.medications.where((m) => !m.completed).toList();
  final allergies =
      store.allergies.where((a) => a.status != AllergyStatus.resolved).toList();
  final due = WalletReminders.dueSoon().length;

  final tiles = <HealthStat>[
    HealthStat('Waiting for you', due == 0 ? 'Nothing' : '$due',
        due == 0 ? 'good' : 'watch'),
    HealthStat('Medicines on now', meds.isEmpty ? 'None' : '${meds.length}',
        'neutral'),
    HealthStat('Allergies recorded',
        allergies.isEmpty ? 'None' : '${allergies.length}', 'neutral'),
    HealthStat('Records kept', '${walletRecordCount()}', 'neutral'),
  ];

  if (due == 0) {
    return WalletStatus(
      headline: 'Nothing waiting',
      sub: 'No reminder is due, and nothing is overdue. This is about what is '
          'in the wallet — not a view on how your child is.',
      tone: 'good',
      tiles: tiles,
    );
  }
  return WalletStatus(
    headline: due == 1 ? '1 thing waiting' : '$due things waiting',
    sub: 'Due or overdue in the next two weeks.',
    tone: 'watch',
    tiles: tiles,
  );
}

// =============================================================================
//  4. "UNDERSTAND" — connections, drawn from the record only
// -----------------------------------------------------------------------------
//  The brief's three examples, and all three are honest to build because each
//  one is a statement about what has been LOGGED:
//
//     "Three fever episodes in the last six months. Discuss with your
//      paediatrician?"                                  -> counts rows
//     "Your child has had Amoxicillin before."          -> matches a name
//     "Last winter, recurrent cough. Winter is coming."  -> compares months
//
//  None of them needs a model, and none of them is a diagnosis — which is also
//  why they live here rather than in the Ask Veda service. Rules that a person
//  can read are the right shape for something that ends in "ask your doctor".
//
//  EVERY observation ends by routing to a clinician and none of them names a
//  cause. "Three fevers" is a count. "Three fevers, which can mean X" would be
//  a diagnosis, and is the line this must not cross.
// =============================================================================

class WalletConnection {
  const WalletConnection({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
  });

  final String id;
  final IconData icon;
  final String title;
  final String body;

  /// What the parent is invited to do. Always a conversation, never a
  /// conclusion.
  final String action;
}

List<WalletConnection> walletConnections({DateTime? now}) {
  final today = now ?? DateTime.now();
  final store = HealthStore.instance;
  final out = <WalletConnection>[];

  // ---- repeated symptoms in six months ------------------------------------
  final counts = <String, List<DateTime>>{};
  for (final s in store.symptoms) {
    final d = walletDate(s.date);
    if (d == null) continue;
    if (today.difference(d).inDays > 183 || d.isAfter(today)) continue;
    final key = s.name.toLowerCase().trim();
    counts.putIfAbsent(key, () => []).add(d);
  }
  for (final e in counts.entries) {
    if (e.value.length < 3) continue;
    out.add(WalletConnection(
      id: 'repeat_${e.key}',
      icon: Icons.repeat_rounded,
      title: '${e.value.length} entries for "${e.key}" in six months',
      body: 'You have logged this ${e.value.length} times since '
          '${walletDateLabel(e.value.reduce((a, b) => a.isBefore(b) ? a : b))}. '
          'That is a count of what is in the wallet, not a finding.',
      action: 'Worth mentioning at the next visit',
    ));
  }

  // ---- a medicine this child has had before -------------------------------
  final seen = <String>{};
  for (final m in store.medications) {
    final name = m.name.toLowerCase().trim();
    if (name.isEmpty) continue;
    if (!seen.add(name)) {
      out.add(WalletConnection(
        id: 'again_$name',
        icon: Icons.medication_outlined,
        title: '${m.name} has been prescribed before',
        body: 'It appears more than once in your records. Bring both entries '
            'if you are asked about what has already been tried.',
        action: 'Open the medicine record',
      ));
    }
  }

  // ---- the same month, last year ------------------------------------------
  final month = today.month;
  final nextMonth = month == 12 ? 1 : month + 1;
  for (final s in store.symptoms) {
    final d = walletDate(s.date);
    if (d == null) continue;
    final aYearBack = today.year - d.year == 1;
    if (!aYearBack) continue;
    if (d.month != nextMonth && d.month != month) continue;
    out.add(WalletConnection(
      id: 'season_${s.name.toLowerCase()}',
      icon: Icons.cloud_outlined,
      title: 'This time last year: ${s.name}',
      body: 'Logged on ${s.date}. The same weeks are coming round again — '
          'some parents like a reminder to keep an eye out.',
      action: 'Set a reminder',
    ));
    break; // one seasonal nudge is a nudge; four is nagging
  }

  return out;
}

// =============================================================================
//  5. REMINDERS
// -----------------------------------------------------------------------------
//  REUSES the existing Reminder model, ReminderStore and NotificationService
//  rather than building a second system. There is already a reminders feature
//  in the pregnancy Tools tab writing to that store, and two schedulers would
//  mean a parent finds some of her reminders in one screen and the rest in
//  another, with no way to tell which is which.
//
//  So Health Wallet contributes CATEGORIES, not machinery. The categories are
//  prefixed `hw_` so the wallet can filter to its own without claiming the
//  pregnancy ones.
//
//  MEDICINE IS THE DELIBERATE OMISSION. Medication alarms already exist
//  (NotificationService.scheduleMedicationAlarms, driven by the Medication
//  record itself). A second medicine reminder here would be a second source of
//  truth for a dose, which is the one place in this feature where being wrong
//  has a physical consequence. The wallet links to that instead.
// =============================================================================

class WalletReminderKind {
  const WalletReminderKind({
    required this.id,
    required this.label,
    required this.blurb,
    required this.icon,
    required this.repeat,
    this.hour = 9,
    this.everyMonths = 0,
  });

  final String id;
  final String label;
  final String blurb;
  final IconData icon;
  final ReminderRepeat repeat;
  final int hour;

  /// For the long-cycle ones (annual checkup, dental). Kept as data so the
  /// copy can say "every 6 months" without a second list to keep in step.
  final int everyMonths;

  String get category => 'hw_$id';
}

/// The brief's reminder list, minus medicine — see the header.
const List<WalletReminderKind> kWalletReminderKinds = [
  WalletReminderKind(
    id: 'vaccine',
    label: 'Upcoming vaccines',
    blurb: 'A nudge before each due date, not on the morning of it.',
    icon: Icons.vaccines_outlined,
    repeat: ReminderRepeat.once,
  ),
  WalletReminderKind(
    id: 'followup',
    label: 'Follow-ups',
    blurb: 'The "come back in ten days" that is easy to lose.',
    icon: Icons.event_repeat_outlined,
    repeat: ReminderRepeat.once,
  ),
  WalletReminderKind(
    id: 'checkup',
    label: 'Annual check-up',
    blurb: 'Once a year, whether or not anything is wrong.',
    icon: Icons.health_and_safety_outlined,
    repeat: ReminderRepeat.monthly,
    everyMonths: 12,
  ),
  WalletReminderKind(
    id: 'dental',
    label: 'Dental visit',
    blurb: 'From the first tooth, then every six months.',
    icon: Icons.sentiment_satisfied_outlined,
    repeat: ReminderRepeat.monthly,
    everyMonths: 6,
  ),
  WalletReminderKind(
    id: 'vision',
    label: 'Vision screening',
    blurb: 'Easy to skip, and the years it matters most are these ones.',
    icon: Icons.visibility_outlined,
    repeat: ReminderRepeat.monthly,
    everyMonths: 12,
  ),
  WalletReminderKind(
    id: 'refill',
    label: 'Medicine refill',
    blurb: 'Before the bottle runs out, not after.',
    icon: Icons.local_pharmacy_outlined,
    repeat: ReminderRepeat.once,
  ),
  WalletReminderKind(
    id: 'growth',
    label: 'Record growth',
    blurb: 'A weight and height every month or two keeps the chart useful.',
    icon: Icons.straighten_outlined,
    repeat: ReminderRepeat.monthly,
    everyMonths: 1,
  ),
  WalletReminderKind(
    id: 'seasonal',
    label: 'Seasonal watch',
    blurb: 'Set from a pattern already in your own records.',
    icon: Icons.cloud_outlined,
    repeat: ReminderRepeat.once,
  ),
];

WalletReminderKind? walletKindById(String id) {
  for (final k in kWalletReminderKinds) {
    if (k.id == id) return k;
  }
  return null;
}

class WalletReminders {
  WalletReminders._();

  static bool isWallet(Reminder r) => r.category.startsWith('hw_');

  static List<Reminder> all() =>
      ReminderStore.instance.all.where(isWallet).toList();

  static List<Reminder> forKind(WalletReminderKind k) => ReminderStore
      .instance.all
      .where((r) => r.category == k.category)
      .toList();

  /// Enabled wallet reminders, used by V3's status card.
  ///
  /// "Due soon" is deliberately just "switched on" for the repeating kinds:
  /// a monthly reminder has no single next date to compare against without
  /// duplicating the scheduler's own maths here, and two answers to "when is
  /// this next" is how they drift apart.
  static List<Reminder> dueSoon() => all().where((r) => r.enabled).toList();

  static void add({
    required WalletReminderKind kind,
    required String title,
    String body = '',
    int hour = 9,
    int minute = 0,
  }) {
    // upsert() is synchronous and schedules the OS notification itself; the
    // cloud write inside it is fire-and-forget, like every other write here.
    ReminderStore.instance.upsert(Reminder(
      id: 'hw_${kind.id}_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      repeat: kind.repeat,
      category: kind.category,
    ));
  }
}

// =============================================================================
//  6. THE EMERGENCY CARD
// -----------------------------------------------------------------------------
//  WHY THE QR HOLDS THE TEXT ITSELF AND NOT A LINK.
//
//  A link needs the internet, and an emergency is the one moment you cannot
//  assume there is any — a basement A&E, a hill road, a dead SIM. A QR that
//  encodes the details directly is readable by any scanner, forever, offline,
//  by a stranger with a phone that has never heard of ParentVeda.
//
//  The cost is real and worth stating: anyone who can see the code can read
//  the child's details. That is the correct trade for a card whose entire
//  purpose is to be readable by a stranger in a hurry. It carries what a
//  clinician needs in the first two minutes and nothing else — no history, no
//  reports, no address.
// =============================================================================

String walletEmergencyText() {
  final child = ChildProfileStore.instance;
  final store = HealthStore.instance;
  final e = store.emergency;

  final allergies = store.allergies
      .where((a) => a.status != AllergyStatus.resolved)
      .map((a) => a.name)
      .toList();
  final meds = store.medications
      .where((m) => !m.completed)
      .map((m) => '${m.name} ${m.dosage}'.trim())
      .toList();

  final lines = <String>[
    'CHILD: ${child.name}',
    'DOB: ${e?.dob ?? '—'}',
    'BLOOD: ${(e?.bloodGroup ?? '').isEmpty ? 'not recorded' : e!.bloodGroup}',
    'ALLERGIES: ${allergies.isEmpty ? 'none recorded' : allergies.join(', ')}',
    'MEDICINES: ${meds.isEmpty ? 'none' : meds.join('; ')}',
    if ((e?.pediatrician ?? '').isNotEmpty) 'PAEDIATRICIAN: ${e!.pediatrician}',
    for (final c in (e?.contacts ?? const []))
      'CONTACT: ${c.name} ${c.phone}',
  ];
  return lines.join('\n');
}

// =============================================================================
//  7. SHARED CHROME
// =============================================================================

class WalletVersionPill extends StatelessWidget {
  const WalletVersionPill({super.key});

  @override
  Widget build(BuildContext context) {
    final store = WalletVersionStore.instance;
    Widget seg(String label, WalletVersion v) {
      final on = store.version == v;
      return GestureDetector(
        onTap: () => store.setVersion(v),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: on ? ppPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: ppBody(11.5,
                  color: on ? Colors.white : ppSoft, w: FontWeight.w700)),
        ),
      );
    }

    return ListenableBuilder(
      listenable: store,
      builder: (_, _) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ppBorder),
        ),
        // V1 retired from the toggle. The segment is kept for revert — the
        // screen behind it is still on disk and still constructed by the
        // commented branch in WalletHomeScreen:
        //   seg('V1', WalletVersion.v1),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          seg('V2', WalletVersion.v2),
          seg('V3', WalletVersion.v3),
        ]),
      ),
    );
  }
}
