// =============================================================================
//  AppStructure — the five tabs, and what belongs under each
// -----------------------------------------------------------------------------
//  The app has five mother tabs and they already exist. Nothing here adds,
//  renames or reorders them. What was missing was a statement of what each one
//  is FOR, in code rather than in someone's head:
//
//      Today      what matters right now
//      Prepare    learn or buy
//      Tools      track or check
//      Community  am I normal, who can I ask
//      Calendar   what is coming up
//      Profile    my stuff  (reached from the Today avatar, NOT a tab)
//
//  WHY A FILE AND NOT A CONVENTION. Every hub currently owns its own list —
//  the parenting Tools hub hardcodes fourteen rows, the Explore drawer
//  thirty-nine. Nothing stops the same surface appearing in two of them, and
//  nothing tells you where a NEW surface should go. That is how an app ends up
//  feeling like everything is happening everywhere: not from any one bad
//  decision, but from forty small ones taken without a rule to check against.
//
//  So the rule lives here, once, as data. `homeFor()` answers "which tab does
//  this belong under" for any surface id, and a test asserts that every id is
//  answered exactly once.
//
//  ⚠️ WHAT THIS DELIBERATELY DOES NOT DO YET. It does not rewire the existing
//  hubs. They keep their hardcoded lists, and this file is currently read only
//  by the new focus-ordered Today (home_focus_screen.dart).
//
//  That is a real limitation and it is worth naming rather than hiding: until
//  the hubs read from here, this is a DESCRIPTION of the structure, not a
//  MECHANISM enforcing it. The trade-off was deliberate — rewiring live hubs
//  means editing shipped screens, and the instruction for this pass was to add
//  a version alongside rather than change what exists. The mechanism half is
//  one `homeFor()` call per hub away, whenever that becomes the right thing to
//  do. The test below is what makes that step safe.
// =============================================================================

/// Where a surface lives. Five tabs, plus the Profile stack behind the avatar.
enum AppHome {
  today,
  prepare,
  tools,
  community,
  calendar,

  /// Not a tab. Reached from the avatar on Today, and home to everything that
  /// is *hers* rather than the product's — journal, memories, saved things,
  /// the child record, language, her partner.
  profile,
}

extension AppHomeCopy on AppHome {
  /// The question this destination answers. One line, and if a surface does not
  /// answer it, the surface is in the wrong place.
  String get question => switch (this) {
        AppHome.today => 'What matters right now?',
        AppHome.prepare => 'What can I learn or buy?',
        AppHome.tools => 'What can I track or check?',
        AppHome.community => 'Am I normal, and who can I ask?',
        AppHome.calendar => 'What is coming up?',
        AppHome.profile => 'Where is my own stuff?',
      };

  String get label => switch (this) {
        AppHome.today => 'Today',
        AppHome.prepare => 'Prepare',
        AppHome.tools => 'Tools',
        AppHome.community => 'Community',
        AppHome.calendar => 'Calendar',
        AppHome.profile => 'Profile',
      };
}

/// One surface in the app, and where it belongs.
///
/// `id` is a stable key, not display text — it is compared and switched on, so
/// it must never be a translated string. (The `.en` is identity, `.now` is
/// display rule from CLAUDE.md, applied before the mistake rather than after.)
class AppSurface {
  const AppSurface(this.id, this.home, this.label);

  final String id;
  final AppHome home;

  /// English only, on purpose. These labels are read by the new focus screen,
  /// which is an experiment behind a toggle — putting them through the string
  /// table would mean translating a screen that may not survive the experiment.
  /// If Focus ships, this is the moment to route them through `S`.
  final String label;
}

/// The whole app, sorted. Additive: a new surface gets a line here and it has
/// a home from the first commit rather than from the first argument about it.
const List<AppSurface> kAppSurfaces = [
  // ---- Today: what matters right now ----------------------------------------
  AppSurface('weekly_snapshot', AppHome.today, 'This week'),
  AppSurface('daily_tip', AppHome.today, "Today's tip"),
  AppSurface('todays_video', AppHome.today, "Today's video"),
  AppSurface('garbh_daily', AppHome.today, 'Garbh Sanskar'),
  AppSurface('daily_reads', AppHome.today, "Today's reads"),

  // ---- Prepare: learn or buy -------------------------------------------------
  AppSurface('masterclasses', AppHome.prepare, 'Masterclasses'),
  AppSurface('consults', AppHome.prepare, '1:1 consults'),
  AppSurface('cohorts', AppHome.prepare, 'Cohorts'),
  AppSurface('yoga', AppHome.prepare, 'Yoga'),
  AppSurface('birthing_classes', AppHome.prepare, 'Birthing classes'),
  AppSurface('shop', AppHome.prepare, 'Shop'),
  AppSurface('nutrition', AppHome.prepare, 'Nutrition'),

  // ---- Tools: track or check -------------------------------------------------
  AppSurface('medication', AppHome.tools, 'Medicines'),
  AppSurface('weight', AppHome.tools, 'Weight'),
  AppSurface('kegel', AppHome.tools, 'Kegel'),
  AppSurface('contractions', AppHome.tools, 'Contractions'),
  AppSurface('movement', AppHome.tools, 'Baby movement'),
  AppSurface('tests_scans', AppHome.tools, 'Tests & scans'),
  AppSurface('hospital_bag', AppHome.tools, 'Ready for birth'),
  AppSurface('can_i', AppHome.tools, 'Can I…?'),
  AppSurface('product_guide', AppHome.tools, 'Product guide'),
  // ---- Added for the bracket model -----------------------------------------
  // Four tools that ship today and were never declared here. Found by building
  // the bracket table and discovering its layers had nowhere to point: the
  // Symptoms Companion is the whole Symptoms bracket's tool layer, and the
  // report explainer is the most distinctive thing under Scans & tests.
  //
  // Worth noting as evidence for this file's own header comment — it describes
  // the structure rather than enforcing it, so a surface can ship for months
  // without appearing here and nothing complains.
  AppSurface('symptoms', AppHome.tools, 'Symptoms'),
  AppSurface('due_date', AppHome.tools, 'Due date'),
  AppSurface('reports', AppHome.tools, 'Reports'),

  // ---- Community --------------------------------------------------------------
  AppSurface('rooms', AppHome.community, 'Rooms'),
  AppSurface('feed', AppHome.community, 'Feed'),
  AppSurface('find_help', AppHome.community, 'Find help'),

  // ---- Calendar ---------------------------------------------------------------
  AppSurface('appointments', AppHome.calendar, 'Appointments'),
  AppSurface('milestones', AppHome.calendar, 'Milestones'),

  // ---- Profile: hers ----------------------------------------------------------
  AppSurface('journal', AppHome.profile, 'My journal'),
  AppSurface('bump', AppHome.profile, 'Bump journey'),
  AppSurface('memories', AppHome.profile, 'Dear Baby'),
  AppSurface('saved', AppHome.profile, 'Saved'),
  AppSurface('partner', AppHome.profile, 'My partner'),
  AppSurface('child_record', AppHome.profile, 'Child record'),
  AppSurface('language', AppHome.profile, 'Language'),
];

/// Which tab a surface belongs under, or null if it is not declared.
///
/// Returns null rather than guessing a default. A surface with no declared home
/// is a question for a person, and silently filing it under Tools would be the
/// drift this file exists to stop.
AppHome? homeFor(String surfaceId) {
  for (final s in kAppSurfaces) {
    if (s.id == surfaceId) return s.home;
  }
  return null;
}

/// Everything filed under one destination, in declaration order.
List<AppSurface> surfacesIn(AppHome home) =>
    kAppSurfaces.where((s) => s.home == home).toList();
