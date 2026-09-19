// =============================================================================
//  What the You screen shows for each stage — the table, not a switch
// -----------------------------------------------------------------------------
//  The rule that makes You ONE screen (docs/PROFILE-AUDIT.md §4): the eight
//  sections are fixed, in order, on every stage. A stage changes what is
//  INSIDE a section — the clock under her name, the one forward action, the
//  rows under "Your details", the rows under "Your things" — and it does that
//  here, as data the screen reads. `PvYouScreen` never switches on stage.
//
//  ⚠️ EVERY VALUE HERE IS READ FROM A STORE THAT ALREADY EXISTS. Nothing is
//  computed, defaulted or invented for display: a fact she has not given
//  renders as `--` with "Add" (Apple's Medical ID), never as a guess. The
//  due date carries its SOURCE ("from your scan") because a clinic's date is
//  theirs and the profile must say so (CLAUDE.md, clinical invariants).
//
//  ⚠️ THE FORWARD ACTION IS ONE PER STAGE AND MOVES ONLY FORWARD. The stage
//  switcher the team uses stays under Developer. FAMILY-MODEL §3: forward is
//  the only direction; the second baby is the only way back.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_store.dart';
import '../../models/pv_product.dart' show PvStageCopy;
import '../../screens/post_pregnancy/pp_child_profile.dart';
import '../../services/family_profile.dart';
import '../../services/life_stage_store.dart';
import '../../services/bump_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/pv_order_store.dart';
import '../../services/saved_store.dart';
import '../../services/stage_gateway.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_treatment_store.dart';
import '../auth/onboarding/onboarding_questions.dart';
import '../belly_skin/bump_ritual_screen.dart';
import '../dear_baby_vault_screen.dart';
import '../journal_screen.dart';
import '../memories/memories_home_screen.dart';
import '../post_pregnancy/my_bookings_screen.dart';
import '../post_pregnancy/provider_results_screen.dart';
import '../pregnancy_profile_screen.dart';
import '../products/pv_orders_screen.dart';
import '../saved_screen.dart';
import '../skilling/sk_child_store.dart';
import '../ttc/ttc_journal_screen.dart';
import '../ttc/ttc_transition_screen.dart' show recordPositiveTest;
import 'pv_details_screen.dart';
import 'pv_doctor_notes_screen.dart';
import 'pv_you_sheets.dart';

/// One row under "Your details": a label, the fact (or `--`), and how to edit.
class PvYouDetail {
  const PvYouDetail({
    required this.label,
    required this.value,
    required this.edit,
    this.note,
  });
  final String label;
  final String Function() value;
  final void Function(BuildContext) edit;

  /// A quiet line under the value ("your doctor's word comes first").
  final String? note;
}

/// One row or tile under "Your things".
class PvYouThing {
  const PvYouThing({
    required this.icon,
    required this.title,
    required this.open,
    this.subtitle,
    this.count,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final int Function()? count;
  final void Function(BuildContext) open;
}

/// The one forward action of a stage.
class PvYouAction {
  const PvYouAction({
    required this.label,
    required this.icon,
    required this.run,
    this.note,
  });
  final String label;
  final IconData icon;
  final String? note;
  final Future<void> Function(BuildContext) run;
}

class PvYouStageContent {
  const PvYouStageContent({
    required this.stage,
    required this.clock,
    required this.action,
    required this.details,
    required this.tiles,
    required this.things,
    required this.childrenInvitation,
    required this.whatWeStore,
  });
  final LifeStage stage;

  /// "Week 21 · day 3", "Aarav · 4 months", "Trying · a few months".
  final String Function() clock;
  final PvYouAction? action;
  final List<PvYouDetail> details;
  final List<PvYouThing> tiles;
  final List<PvYouThing> things;

  /// The line under the child chips when there are no children yet.
  final String childrenInvitation;

  /// The plain-language list for Data and privacy.
  final List<String> whatWeStore;
}

// ---- helpers ------------------------------------------------------------------

/// The onboarding answer for [questionId], as the option labels she chose, or
/// `--`. Reads the same store the questions wrote to.
String _answer(String stageId, String questionId) {
  final store = FamilyProfileStore.instance;
  final q = onboardingQuestionsFor(
    stageId,
  ).where((q) => q.id == questionId).firstOrNull;
  if (q == null) return '--';
  final raw = store.otherFor(questionId);
  if (raw == null || raw.isEmpty) return '--';
  final ids = raw.split(',');
  final labels = [
    for (final o in q.options)
      if (ids.contains(o.id)) o.label,
  ];
  return labels.isEmpty ? '--' : labels.join(', ');
}

String _orDash(String? s) => (s == null || s.trim().isEmpty) ? '--' : s;

String _list<T>(Set<T> s, String Function(T) label) =>
    s.isEmpty ? '--' : s.map(label).join(', ');

void _push(BuildContext c, Widget w, String name) => Navigator.of(c).push(
  MaterialPageRoute<void>(
    builder: (_) => w,
    settings: RouteSettings(name: name),
  ),
);

/// Opens the stage's question editor for one question.
void _editQuestion(BuildContext c, String stageId, String questionId) => _push(
  c,
  PvDetailsScreen(stageId: stageId, focusId: questionId),
  'you/details',
);

String _monthWord(DateTime d) {
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

// ---- the common things -----------------------------------------------------------

PvYouThing _saved() => PvYouThing(
  icon: Icons.bookmark_outline_rounded,
  title: 'Saved',
  count: () => SavedStore.instance.items().length,
  open: (c) => _push(c, const SavedScreen(), 'saved'),
);

PvYouThing _orders() => PvYouThing(
  icon: Icons.receipt_long_outlined,
  title: 'Orders',
  count: () => PvOrderStore.instance.orders.length,
  open: (c) => _push(c, const PvOrdersScreen(), 'store/orders'),
);

PvYouThing _memories() => PvYouThing(
  icon: Icons.photo_library_outlined,
  title: 'Memories',
  open: (c) => _push(c, const MemoriesHomeScreen(), 'memories'),
);

PvYouThing _bookings() => PvYouThing(
  icon: Icons.event_available_outlined,
  title: 'Bookings',
  subtitle: 'Consults, classes and courses you have booked',
  count: () => BookingStore.instance.bookings().length,
  open: (c) => _push(c, const MyBookingsScreen(), 'bookings'),
);

PvYouThing _addresses() => PvYouThing(
  icon: Icons.home_outlined,
  title: 'Addresses',
  subtitle: 'Where orders are delivered',
  count: () => PvOrderStore.instance.addresses.length,
  open: (c) => showPvAddressesSheet(c),
);

PvYouThing _doctorNotes(LifeStage stage) => PvYouThing(
  icon: Icons.medical_information_outlined,
  title: 'Notes for your doctor',
  subtitle: 'What you have logged, laid out for the appointment',
  open: (c) => _push(c, PvDoctorNotesScreen(stage: stage), 'you/doctor_notes'),
);

PvYouThing _findHelp() => PvYouThing(
  icon: Icons.location_on_outlined,
  title: 'Find help near you',
  subtitle: 'Lactation, paediatrics and night help',
  open: (c) => _push(c, const ProviderResultsScreen(), 'pp/providers'),
);

// ---- per stage -------------------------------------------------------------------

PvYouStageContent pvYouContentFor(LifeStage stage) => switch (stage.shopStage) {
  LifeStage.tryingToConceive => _trying,
  LifeStage.pregnancy => _pregnancy,
  LifeStage.parenting => stage == LifeStage.skilling ? _skilling : _parenting,
  LifeStage.skilling => _skilling,
};

final PvYouStageContent _trying = PvYouStageContent(
  stage: LifeStage.tryingToConceive,
  clock: () {
    final d = _answer('trying', 'ttc_duration');
    return d == '--' ? 'Trying' : 'Trying · ${d.toLowerCase()}';
  },
  action: PvYouAction(
    label: 'I got a positive test',
    icon: Icons.favorite_rounded,
    note: 'Carries everything you have logged into pregnancy.',
    run: (c) async {
      await recordPositiveTest(c);
    },
  ),
  details: [
    PvYouDetail(
      label: 'Trying since',
      value: () => _answer('trying', 'ttc_duration'),
      edit: (c) => _editQuestion(c, 'trying', 'ttc_duration'),
    ),
    PvYouDetail(
      label: 'Cycles',
      value: () => _answer('trying', 'ttc_cycles'),
      edit: (c) => _editQuestion(c, 'trying', 'ttc_cycles'),
    ),
    PvYouDetail(
      label: 'Folic acid',
      value: () => _answer('trying', 'ttc_folic'),
      edit: (c) => _editQuestion(c, 'trying', 'ttc_folic'),
    ),
    PvYouDetail(
      label: 'Treatment',
      value: () {
        final t = TtcTreatmentStore.instance;
        if (!t.hasDates) return '--';
        return 'A cycle with ${t.cycle.dates.length} dates logged';
      },
      edit: (c) => _push(
        c,
        PvDetailsScreen(stageId: 'trying', focusId: 'treatment'),
        'you/details',
      ),
      note: 'Dates from your clinic. We remind; we never reschedule.',
    ),
    PvYouDetail(
      label: 'Test records',
      value: () {
        final n = TtcRecordsStore.instance.count;
        return n == 0 ? '--' : '$n on file';
      },
      edit: (c) => _push(
        c,
        PvDetailsScreen(stageId: 'trying', focusId: 'records'),
        'you/details',
      ),
    ),
  ],
  tiles: [
    _saved(),
    PvYouThing(
      icon: Icons.edit_note_rounded,
      title: 'Journal',
      open: (c) => _push(c, const TtcJournalScreen(), 'ttc/journal'),
    ),
    _orders(),
  ],
  things: [_bookings(), _addresses(), _doctorNotes(LifeStage.tryingToConceive)],
  childrenInvitation: 'Your first child\'s page appears here after the birth.',
  whatWeStore: [
    'Your name, phone and email, and the partner you paired with.',
    'What you log while trying: cycle days, symptoms, tests and their readings, supplements and medicines, appointments.',
    'What you save, journal and buy.',
    'Nothing about you is sold. Community posts are never used as a source.',
  ],
);

final PvYouStageContent _pregnancy = PvYouStageContent(
  stage: LifeStage.pregnancy,
  clock: () {
    final c = PregnancyController.current;
    return c == null ? 'Pregnancy' : 'Week ${c.currentWeek}';
  },
  action: PvYouAction(
    label: 'Baby has arrived',
    icon: Icons.child_care_rounded,
    note:
        'Adds your baby and opens the parenting home. Nothing from pregnancy is deleted.',
    run: (c) async {
      final added = await showPvAddChildSheet(c, arrival: true);
      if (added && c.mounted) {
        LifeStageStore.instance.setStage(LifeStage.parenting);
        openStageDoor(c, StageDoor.parenting);
      }
    },
  ),
  details: [
    PvYouDetail(
      label: 'Due date',
      value: () {
        final c = PregnancyController.current;
        if (c == null) return '--';
        final src = switch (c.dueDateSource) {
          DueDateSource.scan => 'from your scan',
          DueDateSource.clinician => 'from your doctor',
          DueDateSource.ivfTransfer => 'from your transfer date',
          DueDateSource.lastPeriod => 'from your last period',
          DueDateSource.conception => 'from your conception date',
          DueDateSource.unknown => '',
        };
        return src.isEmpty
            ? _monthWord(c.dueDate)
            : '${_monthWord(c.dueDate)} · $src';
      },
      edit: (c) =>
          _push(c, const PregnancyProfileScreen(), 'pregnancy_profile'),
      note:
          'A date from a scan or your doctor is theirs — we never recalculate it.',
    ),
    PvYouDetail(
      label: 'First pregnancy',
      value: () => switch (FamilyProfileStore.instance.parity) {
        Parity.first => 'Yes',
        Parity.subsequent => 'No — I have been pregnant before',
        null => '--',
      },
      edit: (c) => _editQuestion(c, 'pregnancy', 'preg_parity'),
    ),
    PvYouDetail(
      label: 'Conditions',
      value: () =>
          _list(FamilyProfileStore.instance.pregConditions, (x) => x.label.en),
      edit: (c) =>
          _push(c, const PregnancyProfileScreen(), 'pregnancy_profile'),
      note:
          'Anything here changes what leads, never what exists. Your doctor\'s word comes first.',
    ),
    PvYouDetail(
      label: 'How you eat',
      value: () => _orDash(FamilyProfileStore.instance.diet?.label.en),
      edit: (c) => _editQuestion(c, 'pregnancy', 'preg_diet'),
    ),
    PvYouDetail(
      label: 'What you want help with',
      value: () =>
          _list(FamilyProfileStore.instance.pregPriorities, (x) => x.label.en),
      edit: (c) => _editQuestion(c, 'pregnancy', 'preg_priorities'),
    ),
  ],
  tiles: [_saved(), _memories(), _orders()],
  things: [
    PvYouThing(
      icon: Icons.mail_outline_rounded,
      title: 'Dear Baby vault',
      subtitle: 'Letters that open when your baby is born',
      open: (c) {
        final ctl = PregnancyController.current;
        if (ctl != null) {
          _push(c, DearBabyVaultScreen(controller: ctl), 'dear_baby');
        }
      },
    ),
    PvYouThing(
      icon: Icons.edit_note_rounded,
      title: 'Journal',
      open: (c) {
        final ctl = PregnancyController.current;
        if (ctl != null) _push(c, JournalScreen(controller: ctl), 'journal');
      },
    ),
    PvYouThing(
      icon: Icons.pregnant_woman_rounded,
      title: 'Bump journey',
      subtitle: 'One photo a week, kept in order',
      count: () => BumpStore.instance.count,
      open: (c) {
        final ctl = PregnancyController.current;
        if (ctl != null) _push(c, BumpRitualScreen(controller: ctl), 'bump');
      },
    ),
    _bookings(),
    _addresses(),
    _doctorNotes(LifeStage.pregnancy),
    _findHelp(),
  ],
  childrenInvitation:
      'Your baby\'s page appears here after the birth. An older child can be added now.',
  whatWeStore: [
    'Your name, phone and email, your due date and where it came from, and the partner you paired with.',
    'What you log: symptoms, weight, movements, medicines, scans and appointments, your journal and letters.',
    'The answers you gave us so the home leads with what matters to you.',
    'What you save, book and buy.',
    'Nothing about you is sold. Community posts are never used as a source.',
  ],
);

final PvYouStageContent _parenting = PvYouStageContent(
  stage: LifeStage.parenting,
  clock: () {
    final s = ChildProfileStore.instance;
    if (!s.hasRealChild) return 'Parenting';
    return '${s.active.name} · ${s.ageLabel}';
  },
  action: PvYouAction(
    label: 'Add a child',
    icon: Icons.person_add_alt_1_outlined,
    note: 'A second child gets their own records; nothing moves.',
    run: (c) async {
      await showPvAddChildSheet(c);
    },
  ),
  details: [
    PvYouDetail(
      label: 'What matters most right now',
      value: () =>
          _list(FamilyProfileStore.instance.priorities, (x) => x.label),
      edit: (c) => _editQuestion(c, 'parenting', 'pp_priorities'),
    ),
    PvYouDetail(
      label: 'How you like to learn',
      value: () => _list(FamilyProfileStore.instance.learnings, (x) => x.label),
      edit: (c) => _push(
        c,
        const PvDetailsScreen(stageId: 'parenting', focusId: 'learning'),
        'you/details',
      ),
    ),
    PvYouDetail(
      label: 'Reminders you want',
      value: () => _list(FamilyProfileStore.instance.notify, (x) => x.label),
      edit: (c) => _push(
        c,
        const PvDetailsScreen(stageId: 'parenting', focusId: 'notify'),
        'you/details',
      ),
      note: 'Only what you choose — never noise.',
    ),
  ],
  tiles: [_saved(), _memories(), _orders()],
  things: [
    _bookings(),
    _addresses(),
    _doctorNotes(LifeStage.parenting),
    _findHelp(),
  ],
  childrenInvitation: 'Add your child and their page appears here.',
  whatWeStore: [
    'Your name, phone and email, and the partner you paired with.',
    'Each child\'s name, birthday and what you log about them: feeds, sleep, growth, vaccines, milestones, health notes.',
    'The answers you gave us so the home leads with what matters to you.',
    'What you save, book and buy.',
    'Nothing about you or your child is sold. Community posts are never used as a source.',
  ],
);

final PvYouStageContent _skilling = PvYouStageContent(
  stage: LifeStage.skilling,
  clock: () {
    final s = SkChildStore.instance;
    if (s.name.isEmpty) return 'Skilling';
    final y = s.ageYears;
    return y == null ? s.name : '${s.name} · $y';
  },
  action: null,
  details: [
    PvYouDetail(
      label: 'Your role',
      value: () => switch (SkChildStore.instance.verification.name) {
        'none' => '--',
        final v => v[0].toUpperCase() + v.substring(1),
      },
      edit: (c) => _push(
        c,
        const PvDetailsScreen(stageId: 'skilling', focusId: 'role'),
        'you/details',
      ),
      note: 'Who set up the grown-up gate.',
    ),
  ],
  tiles: [
    _saved(),
    PvYouThing(
      icon: Icons.auto_awesome_outlined,
      title: 'Her keepsakes',
      open: (c) => showPvKeepsakesSheet(c),
    ),
    _orders(),
  ],
  things: [_bookings(), _addresses()],
  childrenInvitation: 'Add your child and their page appears here.',
  whatWeStore: [
    'Your name, phone and email.',
    'Your child\'s name and age, and what she makes: her journal, photos and voice keepsakes — kept on this phone only, never sent anywhere.',
    'The grown-up PIN, as a hash. We cannot read it back.',
    'What you save, book and buy.',
  ],
);
