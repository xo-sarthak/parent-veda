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
import '../../ttc/ttc_content_prefs.dart' show TtcContentPrefs;
// Kept for revert (2026-09-28, journal out of TTC):
// import '../../ttc/ttc_journal_store.dart' show TtcJournalStore;
import '../../ttc/ttc_messages_store.dart' show TtcMessagesStore;
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
import '../pregnancy/preg_twins.dart';
import '../pregnancy/preg_due_date_screen.dart' show openPregDueDate;
import '../pregnancy/preg_ended_screen.dart' show openPregEnded;
import '../../data/doors/pv_door_after_loss.dart' show kPregEndedRowTitle, kPregEndedRowSub;
import '../../services/pregnancy_ended_store.dart';
import '../products/pv_orders_screen.dart';
import '../saved_screen.dart';
import '../skilling/sk_child_store.dart';
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_more_marks.dart';
import '../ttc/ttc_content_prefs_sheet.dart'
    show showTtcContentPrefsSheet, kTtcWhatYouSee, kTtcHideIntimate;
import '../ttc/ttc_get_help_screen.dart'
    show kTtcGetHelpTitle, openTtcGetHelp;
// Kept for revert (2026-09-28, journal out of TTC):
// import '../ttc/ttc_journal_screen.dart';
import '../ttc/ttc_prepare_screen.dart' show TtcPrepareScreen;
// Records now opens through the Tools table (Y2), which calls openTtcRecords.
// import '../ttc/ttc_records_screen.dart' show openTtcRecords;
import '../ttc/ttc_surface_router.dart' show openTtcSurface;
import '../ttc/ttc_tools_screen.dart'
    show TtcTool, ttcToolById, ttcMovedToMoreById, kTtcMoreExpertsTitle;
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
    this.art,
    this.hideWhenEmpty = false,
  });
  final String label;
  final String Function() value;
  final void Function(BuildContext) edit;

  /// ⚠️ ADDITIVE (2026-09-29, TTC's profile V3). True for a fact that is a
  /// RECORD rather than an answer (her treatment dates, her test records):
  /// the profile shows it once there is one, and leaves the `--` to the
  /// tool that keeps it. False, every other detail, draws as before.
  final bool hideWhenEmpty;

  /// The drawn mark on TTC's profile (2026-09-29), for the section's tint.
  /// Null elsewhere: the row keeps its line icon.
  final Widget Function(Color tint)? art;

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
    this.dot,
    this.subtitleNow,
    this.listen,
    this.art,
  });

  /// The drawn mark on TTC's profile (2026-09-29), for the section's tint.
  /// Null elsewhere: the row keeps its line [icon].
  final Widget Function(Color tint)? art;
  final IconData icon;
  final String title;
  final String? subtitle;
  final int Function()? count;
  final void Function(BuildContext) open;

  /// A small dot at the row's end when this is true, never a number. The
  /// TTC Messages row uses it, the same signal as the home's envelope
  /// (review Y1, 2026-09-26: a count of unread messages is a small pressure
  /// on a screen that is meant to take pressure away, §4.9).
  final bool Function()? dot;

  /// A subtitle read at build time, for a row whose line is a STATE ("Sex
  /// and intimacy content: hidden") rather than a description. Wins over
  /// [subtitle] when set (review Y3).
  final String Function()? subtitleNow;

  /// What the row's [dot] or [subtitleNow] reads, so the screen repaints
  /// when it changes. Additive: rows without it are drawn exactly as before.
  final Listenable? listen;
}

/// A You row that IS a Tools tile: its name, icon and line read from the
/// Tools table, so the two tabs print the same thing (review Y2). The
/// destination is the tool's own too.
PvYouThing _toolThing(String id) {
  final TtcTool tool = ttcToolById(id)!;
  return PvYouThing(
    icon: tool.icon,
    title: tool.nameEn,
    subtitle: tool.descEn,
    open: tool.open,
  );
}

/// A More row that LEFT Tools because it is not a tool (2026-09-28): its
/// name, icon, line and destination read from `ttcMovedToMore`, so the row
/// is word for word what the Tools row was.
PvYouThing _movedThing(String id) {
  final TtcTool tool = ttcMovedToMoreById(id)!;
  return PvYouThing(
    icon: tool.icon,
    title: tool.nameEn,
    subtitle: tool.descEn,
    open: tool.open,
  );
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

/// A titled group of rows ("Your health", "Your app").
class PvYouGroup {
  const PvYouGroup({
    required this.title,
    required this.things,
    this.caption,
    this.icon,
    this.status,
    this.dot,
    this.listen,
  });
  final String title;
  final List<PvYouThing> things;

  // ⚠️ ADDITIVE (2026-09-28, the More tab's bento, pv_more_bento.dart). A
  // group is a TILE there, and a tile names what is inside it before she
  // taps. Every field below is optional and only the bento reads them.

  /// One line naming the rows inside ("Doctor notes, records, treatment").
  final String? caption;

  /// The tile's line icon.
  final IconData? icon;

  /// A live state for the tile ("A treatment round is in progress"), or
  /// null for none. PayPal's value on a card, never a score.
  final String? Function()? status;

  /// A dot on the tile, never a number (the Messages rule, review Y1).
  final bool Function()? dot;

  /// What [status] and [dot] read, so the tile repaints when they change.
  final Listenable? listen;
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
    this.groups,
    this.journeyThings = const [],
    this.journeyCaption,
    this.tilesCaption,
    this.profileThings = const [],
    this.preferenceThings = const [],
    this.notificationThings = const [],
    this.supportThings = const [],
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

  /// ⚠️ SHORT AND GROUPED (2026-09-27, trying to conceive only, the user's
  /// choice after the launch walk; Flo, Clue and Lifesum on Mobbin). When
  /// set, the screen draws these titled groups under the tiles instead of
  /// [things] in one long card, and folds [details] into a row of its own
  /// ("Your answers"), so the top level is short and nothing sits twice.
  /// Null on every other stage, which draws exactly as before.
  final List<PvYouGroup>? groups;

  // ⚠️ ADDITIVE (2026-09-28, Tools holds only tools). Read by the More
  // bento only; every other stage leaves them empty and draws as before.

  /// Rows under "Your journey" after the chapters and the forward action
  /// (TTC: the journey map, which left Tools).
  final List<PvYouThing> journeyThings;

  /// The "Your journey" tile's caption, naming what is inside, or null for
  /// the screen's own line.
  final String? journeyCaption;

  /// The "Your things" tile's caption, or null for the tiles' names.
  final String? tilesCaption;

  // ⚠️ ADDITIVE (2026-09-29, the Profile and Settings split, TTC only). The
  // profile draws [profileThings] under its own heading; the Settings page
  // draws the other three in its Preferences, Notifications and Support
  // groups. Every other stage leaves them empty and draws as before.

  /// Rows about her health on the profile (TTC: Notes for your doctor).
  /// Hers only: the partner's view never draws them.
  final List<PvYouThing> profileThings;

  /// Extra rows in Settings, Preferences (TTC: What you see).
  final List<PvYouThing> preferenceThings;

  /// Extra rows in Settings, Notifications (TTC: Messages).
  final List<PvYouThing> notificationThings;

  /// Extra rows in Settings, Support (TTC: Get help now).
  final List<PvYouThing> supportThings;
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

// [stage]: one stage's saves only (2026-09-30: trying to conceive's profile
// counted and opened pregnancy saves too). Kept for revert: no stage, every
// item counted, `const SavedScreen()`.
PvYouThing _saved({Widget Function(Color)? art, String? stage}) => PvYouThing(
  icon: Icons.bookmark_outline_rounded,
  art: art,
  title: 'Saved',
  count: () => stage == 'trying'
      ? [
          for (final i in SavedStore.instance.items(stage: stage))
            if (kTtcSavedKinds.contains(i.kind)) i,
        ].length
      : SavedStore.instance.items().length,
  open: (c) => _push(c, SavedScreen(stage: stage), 'saved'),
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

PvYouThing _doctorNotes(LifeStage stage, {Widget Function(Color)? art}) =>
    PvYouThing(
  icon: Icons.medical_information_outlined,
  art: art,
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

// ---- TTC rows for the profile and Settings (2026-09-29) --------------------------
//
// The same words, icons, lines and destinations as the rows in `_trying`'s
// groups below (kept for the bento's revert), built once here.

/// The Messages row: what the app has sent her. A dot, never a number (Y1).
PvYouThing _ttcMessages() => PvYouThing(
  icon: Icons.mail_outline_rounded,
  title: 'Messages',
  subtitle: 'What we have sent you, and when we send it',
  dot: () => TtcMessagesStore.instance.unreadCount > 0,
  listen: TtcMessagesStore.instance,
  open: (c) => openTtcSurface(c, 'ttc_messages'),
);

/// The shared-phone switch's row, with its state as the line (Y3).
PvYouThing _ttcWhatYouSee() => PvYouThing(
  icon: Icons.visibility_outlined,
  title: kTtcWhatYouSee,
  subtitle: kTtcHideIntimate,
  subtitleNow: () => TtcContentPrefs.instance.hideIntimate
      ? kTtcIntimateStateHidden
      : kTtcIntimateStateShown,
  listen: TtcContentPrefs.instance,
  open: (c) => showTtcContentPrefsSheet(c),
);

/// The one calm page of helplines.
PvYouThing _ttcGetHelp() => PvYouThing(
  icon: Icons.phone_in_talk_outlined,
  title: kTtcGetHelpTitle,
  subtitle: 'Helplines you can call now, and who to call when',
  open: (c) => openTtcGetHelp(c),
);

// ---- per stage -------------------------------------------------------------------

PvYouStageContent pvYouContentFor(LifeStage stage) => switch (stage.shopStage) {
  LifeStage.tryingToConceive => _trying,
  LifeStage.pregnancy => _pregnancy,
  LifeStage.parenting => stage == LifeStage.skilling ? _skilling : _parenting,
  LifeStage.skilling => _skilling,
};

/// The "What you see" row's state line (Y3). English only.
const String kTtcIntimateStateShown = 'Sex and intimacy content: shown';
const String kTtcIntimateStateHidden = 'Sex and intimacy content: hidden';

final PvYouStageContent _trying = PvYouStageContent(
  stage: LifeStage.tryingToConceive,
  // The card's line carries the facts that matter (Lifesum's profile card):
  // how long, and her cycle when she has said. Kept for revert: the "Trying ·
  // <duration>" line alone.
  clock: () {
    final d = _answer('trying', 'ttc_duration');
    final c = _answer('trying', 'ttc_cycles');
    return [
      d == '--' ? 'Trying' : 'Trying · ${d.toLowerCase()}',
      // Only a real answer; "cycles not sure" read as a slip.
      if (c != '--' && !c.toLowerCase().contains('not sure'))
        'cycles ${c.toLowerCase()}',
    ].join(' · ');
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
    // "Trying for" (2026-09-29): the answer is a length of time ("6 to 12
    // months"), and "since" read wrongly before a duration. Kept for revert:
    //   label: 'Trying since',
    PvYouDetail(
      label: 'Trying for',
      art: ttcArtTab(TtcTabMark.clock),
      value: () => _answer('trying', 'ttc_duration'),
      edit: (c) => _editQuestion(c, 'trying', 'ttc_duration'),
    ),
    PvYouDetail(
      label: 'Cycles',
      art: ttcArtTool('cycle'),
      value: () => _answer('trying', 'ttc_cycles'),
      edit: (c) => _editQuestion(c, 'trying', 'ttc_cycles'),
    ),
    PvYouDetail(
      label: 'Folic acid',
      art: ttcArtTool('supplements'),
      value: () => _answer('trying', 'ttc_folic'),
      edit: (c) => _editQuestion(c, 'trying', 'ttc_folic'),
    ),
    PvYouDetail(
      label: 'Treatment',
      art: ttcArtTool('treatment'),
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
      hideWhenEmpty: true,
    ),
    PvYouDetail(
      label: 'Test records',
      art: ttcArtTool('records'),
      value: () {
        final n = TtcRecordsStore.instance.count;
        return n == 0 ? '--' : '$n on file';
      },
      hideWhenEmpty: true,
      edit: (c) => _push(
        c,
        PvDetailsScreen(stageId: 'trying', focusId: 'records'),
        'you/details',
      ),
    ),
  ],
  // The bookmark mark on the profile (2026-09-29). Kept for revert: _saved(),
  tiles: [
    _saved(art: ttcArtMore(TtcMoreMark.bookmark), stage: 'trying'),
    // A count like its two neighbours (2026-09-27, build 11): "11 Saved",
    // "2 Orders" and a bare "Journal" read as three different kinds of tile.
    // Kept for revert: no count.
    // Kept for revert (2026-09-28, journal out of TTC): the user took the
    // journal out of the stage.
    // PvYouThing(
    //   icon: Icons.edit_note_rounded,
    //   title: 'Journal',
    //   count: () => TtcJournalStore.instance.count,
    //   open: (c) => _push(c, const TtcJournalScreen(), 'ttc/journal'),
    // ),
    // ⚠️ ORDERS LIVES UNDER "BOOKINGS AND ORDERS" (2026-09-28, the More
    // bento): a tile named for orders with no Orders row broke the rule that a
    // label names what is behind it, and Orders sits beside the delivery
    // addresses it uses. Kept for revert: _orders(),
  ],
  // ⚠️ MORE'S ROWS LIVE HERE SINCE 2026-09-26. The V3 bar became Today ·
  // Learn · Products · Tools · You, and the More tab went. Everything it held
  // is below, so nothing lost its entrance: Calendar, the cycle companion,
  // the fertility window and the unscoped programmes list (Journal was
  // already a tile; Profile is this screen). Community is held back on
  // purpose, the user's call. `test/ttc_tabs_v3_test.dart` pins every row.
  //
  // The doctor's note leads (Flo's "Report for a doctor" sits first under
  // the identity card): it says the app is for her and her clinician.
  //
  // Kept for revert:
  //   things: [_bookings(), _addresses(), _doctorNotes(LifeStage.tryingToConceive)],
  things: [
    _doctorNotes(LifeStage.tryingToConceive),
    // ⚠️ TWO ROWS FROM THE GAP ANALYSIS (2026-09-26, "Behind: Guided help" and
    // "Behind: Settings"), TTC only. The messages the app now sends wait in a
    // list, and this is its second door after the home's envelope. "What you
    // see" opens a small sheet with the one content switch, because this
    // shared screen has no switch row and must not grow one for one stage.
    // Y1: a dot, not a number, like the home's envelope. Kept for revert:
    //   count: () => TtcMessagesStore.instance.unreadCount,
    PvYouThing(
      icon: Icons.mail_outline_rounded,
      title: 'Messages',
      subtitle: 'What we have sent you, and when we send it',
      dot: () => TtcMessagesStore.instance.unreadCount > 0,
      listen: TtcMessagesStore.instance,
      open: (c) => openTtcSurface(c, 'ttc_messages'),
    ),
    // Y3: the line says whether hiding is on, so she can see it without
    // opening the sheet (the Settings value pattern). Kept for revert:
    //   subtitle: kTtcHideIntimate,
    PvYouThing(
      icon: Icons.visibility_outlined,
      title: kTtcWhatYouSee,
      subtitle: kTtcHideIntimate,
      subtitleNow: () => TtcContentPrefs.instance.hideIntimate
          ? kTtcIntimateStateHidden
          : kTtcIntimateStateShown,
      listen: TtcContentPrefs.instance,
      open: (c) => showTtcContentPrefsSheet(c),
    ),
    // ⚠️ THE TREATMENT ROUND'S ROW (2026-09-26, docs/TTC-TREATMENT-FLOW.md
    // §2b). Additive: one more way to the round, beside records. It opens the
    // treatment screen, whose top is the start card when no round exists.
    PvYouThing(
      icon: Icons.event_note_outlined,
      title: 'Treatment',
      subtitle: "Your clinic's dates, step by step",
      open: (c) => openTtcSurface(c, 'ttc_treatment'),
    ),
    // Y2: from the Tools table. Kept for revert: folder_shared_outlined,
    // 'Records and reports', 'Both your results, in one folder',
    // openTtcRecords.
    _toolThing('records'),
    PvYouThing(
      icon: Icons.calendar_month_outlined,
      title: 'Calendar',
      subtitle: 'Your cycle days, month by month',
      open: (c) => openTtcSurface(c, 'ttc_calendar'),
    ),
    // Y2: from the Tools table, so "Cycle companion" and "Fertility window"
    // are one name, one icon, one line and one destination on both tabs.
    // Kept for revert: timeline_rounded / 'Your periods, and what they tell
    // you' / ttc_cycle, and wb_twilight_rounded / 'The days that count most
    // this cycle' / ttc_window. The words moved to Tools unchanged.
    _toolThing('cycle'),
    _toolThing('window'),
    PvYouThing(
      icon: Icons.auto_awesome_outlined,
      title: 'All programmes and sessions',
      subtitle: 'Yoga, food, mind, tests, IVF support and more',
      open: (c) => _push(c, const TtcPrepareScreen(), 'ttc/prepare'),
    ),
    _bookings(),
    _addresses(),
  ],
  // ⚠️ THE TOP LEVEL, SHORT (2026-09-27). `things` above stays as the list
  // any older caller reads; the screen draws these groups for TTC. Calendar,
  // the cycle companion and the fertile window left You: they live on Today
  // (the header's calendar, the hero) and on Tools, and three doors to one
  // screen made You the longest list in the app.
  groups: [
    // The bento fields (2026-09-28): a caption naming the five rows, the
    // round's state on the tile. Kept for revert:
    //   PvYouGroup(title: 'Your health', things: [
    // ⚠️ NO TOOLS IN MORE (2026-09-28, the user: More holds everything that
    // is not a tool). Records and reports is a Tools row already, so its
    // second door here is gone; the treatment round records her clinic's
    // dates, so it moved to Tools as "Treatment cycle", taking the tile's
    // "round in progress" state with it (the Tools row shows it now).
    // Kept for revert (2026-09-28):
    //   caption: 'Notes for your doctor, records, treatment, your answers and helplines',
    //   status: () => TtcTreatmentStore.instance.hasDates
    //       ? 'A treatment round is in progress' : null,
    //   listen: TtcTreatmentStore.instance,
    PvYouGroup(
        title: 'Your health',
        caption:
            'Notes for your doctor, your answers about trying, and helplines to call',
        icon: Icons.favorite_border_rounded,
        things: [
      _doctorNotes(LifeStage.tryingToConceive),
      // Kept for revert (2026-09-28): a Tools row.
      // _toolThing('records'),
      // Kept for revert (2026-09-28): Tools' "Treatment cycle" row now.
      // PvYouThing(
      //   icon: Icons.event_note_outlined,
      //   title: 'Treatment',
      //   subtitle: "Your clinic's dates, step by step",
      //   subtitleNow: () => TtcTreatmentStore.instance.hasDates
      //       ? 'A round is in progress'
      //       : "Your clinic's dates, step by step",
      //   listen: TtcTreatmentStore.instance,
      //   open: (c) => openTtcSurface(c, 'ttc_treatment'),
      // ),
      PvYouThing(
        icon: Icons.fact_check_outlined,
        title: 'Your answers',
        subtitle: 'How long you have been trying, your cycles, folic acid',
        open: (c) => _push(
          c,
          const PvDetailsScreen(stageId: 'trying'),
          'you/details',
        ),
      ),
      // ⚠️ THE STANDING WAY TO A PERSON (2026-09-28, the user's option B).
      // The low-mood lines came off the top of the door tabs; this row, and
      // the end of Mind & body's Today and Hard days, open the one calm page
      // of helplines instead (ttc_get_help_screen.dart). Last in the group,
      // so it is found when looked for and never reads as a warning.
      PvYouThing(
        icon: Icons.phone_in_talk_outlined,
        title: kTtcGetHelpTitle,
        subtitle: 'Helplines you can call now, and who to call when',
        open: (c) => openTtcGetHelp(c),
      ),
    ]),
    // Kept for revert: PvYouGroup(title: 'Your app', things: [
    PvYouGroup(
        title: 'Your app',
        caption: 'Messages we send you, and the topics you choose to see',
        icon: Icons.mail_outline_rounded,
        dot: () => TtcMessagesStore.instance.unreadCount > 0,
        listen: TtcMessagesStore.instance,
        things: [
      PvYouThing(
        icon: Icons.mail_outline_rounded,
        title: 'Messages',
        subtitle: 'What we have sent you, and when we send it',
        dot: () => TtcMessagesStore.instance.unreadCount > 0,
        listen: TtcMessagesStore.instance,
        open: (c) => openTtcSurface(c, 'ttc_messages'),
      ),
      PvYouThing(
        icon: Icons.visibility_outlined,
        title: kTtcWhatYouSee,
        subtitle: kTtcHideIntimate,
        subtitleNow: () => TtcContentPrefs.instance.hideIntimate
            ? kTtcIntimateStateHidden
            : kTtcIntimateStateShown,
        listen: TtcContentPrefs.instance,
        open: (c) => showTtcContentPrefsSheet(c),
      ),
    ]),
    // ⚠️ A NEW TILE FOR WHAT LEFT TOOLS (2026-09-28, the user: Tools holds
    // only tools). Booking an expert and the courses are not tools, so they
    // are here, with the whole catalogue they belong to beside them: what she
    // can book sits on one tile, what she HAS booked on the next. The rows
    // read their words from `ttcMovedToMore`, so they say what Tools said.
    // American Airlines' More (booking and help as tiles over grouped rows,
    // https://mobbin.com/screens/71e3fc57-af3c-446a-863e-a76f4088e03a).
    PvYouGroup(
        title: kTtcMoreExpertsTitle,
        caption:
            'Book a video call with a specialist, your free course, and every programme you can join',
        icon: Icons.support_agent_outlined,
        things: [
      _movedThing('expert'),
      _movedThing('courses'),
      // From "Bookings and orders" (2026-09-28): the catalogue belongs with
      // the two filtered doors into it, and "All" says it is the whole of
      // what the two rows above are part of. Kept for revert:
      //   title: 'Programmes and sessions',
      //   subtitle: 'Consults, courses and classes you can book',
      PvYouThing(
        icon: Icons.auto_awesome_outlined,
        title: 'All programmes and sessions',
        subtitle:
            'Yoga, food, mind, tests, partner workshops and IVF support, as well as the two above',
        open: (c) => _push(c, const TtcPrepareScreen(), 'ttc/prepare'),
      ),
    ]),
    // Kept for revert: PvYouGroup(title: 'Bookings and orders', things: [
    // Kept for revert (2026-09-28), the caption before the programmes moved:
    //   'Programmes to book, what you have booked, delivery addresses'
    PvYouGroup(
        title: 'Bookings and orders',
        caption: 'What you have booked, your orders and delivery addresses',
        icon: Icons.event_available_outlined,
        things: [
      // Moved to "Experts and courses" (2026-09-28). Kept for revert:
      // PvYouThing(
      //   icon: Icons.auto_awesome_outlined,
      //   title: 'Programmes and sessions',
      //   subtitle: 'Consults, courses and classes you can book',
      //   open: (c) => _push(c, const TtcPrepareScreen(), 'ttc/prepare'),
      // ),
      _bookings(),
      _orders(),
      _addresses(),
    ]),
  ],
  // The journey map left Tools (2026-09-28): a view of her journey, so it
  // sits on the journey's tile, under the chapters.
  // The journey map left More and Tools' moved list on 2026-09-30 (the
  // user). Kept for revert: journeyThings: [_movedThing('map')],
  journeyThings: const [],
  journeyCaption:
      'Where you are across the four chapters, the "I got a positive test" button, and your journey map with its family timeline',
  // What Saved holds on this stage since 2026-09-30 (kTtcSavedKinds). Kept
  // for revert: 'What you bookmarked: reads, tests, answers and cards',
  tilesCaption: 'Articles, videos, recipes and products you bookmarked',
  // ⚠️ THE PROFILE AND SETTINGS SPLIT (2026-09-29, the user: More holds what
  // the app offers; account, preferences, support and developer sit behind
  // ONE Settings row on the profile). The rows are built by the same
  // functions the groups above use, so a row says the same words wherever it
  // is drawn. Where each former row went: `kTtcFormerYouRows` in
  // lib/screens/ttc/ttc_more_tab.dart.
  profileThings: [
    _doctorNotes(
      LifeStage.tryingToConceive,
      // A note for the doctor: the door family's "See a doctor" bubble.
      art: ttcArtTab(TtcTabMark.doctorChat),
    ),
  ],
  preferenceThings: [_ttcWhatYouSee()],
  notificationThings: [_ttcMessages()],
  supportThings: [_ttcGetHelp()],
  childrenInvitation: 'Your first child\'s page appears here after the birth.',
  whatWeStore: [
    'Your name, phone and email, and the partner you paired with.',
    'What you log while trying: cycle days, symptoms, tests and their readings, supplements and medicines, appointments.',
    // Kept for revert (2026-09-28, journal out of TTC):
    //   'What you save, journal and buy.',
    // Still honest about storage: older entries stay on the phone and in sync.
    'What you save and buy, and any journal entries you wrote before.',
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
      // ⚠️ THE DATE EDITOR, NOT THE PROFILE (2026-09-30, pregnancy gap
      // analysis P1): the profile screen had no due-date field. Kept for
      // revert: _push(c, const PregnancyProfileScreen(), 'pregnancy_profile')
      edit: (c) {
        final pc = PregnancyController.current;
        if (pc == null) {
          _push(c, const PregnancyProfileScreen(), 'pregnancy_profile');
          return;
        }
        openPregDueDate(c, pc);
      },
      note:
          'A date from a scan or your doctor is theirs — we never recalculate it.',
    ),
    // The promise onboarding makes ("You can say so later"), kept (2026-09-30,
    // gap analysis P2). One answer, shared with the hospital bag's switch.
    PvYouDetail(
      label: 'Twins or more',
      value: pregTwinsValue,
      edit: (c) => showPregTwinsSheet(c),
      note: 'Your weeks will say so, and the pieces for twins lead. Your due date is not changed.',
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
    // ⚠️ LAST, AND QUIET ON PURPOSE (2026-09-29, pregnancy gap analysis,
    // "Behind · After a loss", P1). Oura keeps "My pregnancy ended" as one
    // plain row in its pregnancy details; a loss is not a feature to
    // advertise, it is a door that has to be findable on the worst day.
    PvYouThing(
      icon: Icons.spa_outlined,
      title: kPregEndedRowTitle,
      subtitle: kPregEndedRowSub,
      subtitleNow: () => PregnancyEndedStore.instance.ended
          ? 'Your Today shows support pages. Tap to change this.'
          : kPregEndedRowSub,
      listen: PregnancyEndedStore.instance,
      open: (c) {
        final ctl = PregnancyController.current;
        if (ctl != null) openPregEnded(c, ctl);
      },
    ),
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
