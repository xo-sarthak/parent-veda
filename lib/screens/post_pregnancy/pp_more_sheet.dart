// =============================================================================
//  PpMoreSheet — the "More" tab of the parenting bar
// -----------------------------------------------------------------------------
//  The V3 home design (2026-09-16) reshaped the bar to
//
//      Home · Products · Tools · Brain activities · More
//
//  and said of the last one: "More opens a sheet holding Community and
//  everything else that used to be a tab or lives in the Explore drawer."
//
//  ⚠️ A SHEET, NOT A SCREEN, AND NOT A TAB IN THE USUAL SENSE. The other four
//  tabs pop to the home and push a destination; this one opens OVER wherever
//  she is and closes back to it. So it is never "active" in the bar — there is
//  no screen for it to be active on — and `openPpTabTo` special-cases it
//  before the popUntil that the real tabs share.
//
//  WHAT IS IN IT. Two groups:
//
//    1. THE SEVEN THE DESIGN NAMES, in its order and with its copy —
//       Community first (it lost its tab and this is where it went), then
//       Watch, Learn, Recipes, Memories, Find help, Settings.
//    2. EVERYTHING ELSE from the Explore drawer, read from the SAME list the
//       drawer renders (`ppExploreEntries`), minus the rows group 1 already
//       covers. A feature is never hidden: the drawer had twenty-odd rows and
//       a bar that replaces the hamburger must reach every one of them.
//
//  The dedupe is by TITLE, which is the one field both lists agree on. It is
//  a string match and it will drift if a drawer row is renamed — the test in
//  test/pp_home_v3_design_test.dart pins that every drawer entry is reachable
//  from the sheet, so a rename fails loudly rather than producing a duplicate.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../memories/memories_home_screen.dart';
import '../v2/v2_palette.dart';
import 'community_screen.dart';
import 'courses_explore_screen.dart';
import 'explore_drawer.dart';
import 'family_profile_screen.dart';
import 'pp_child_profile.dart';
import 'problem_solver_screen.dart';
import 'recipes_explore_screen.dart';
import 'watch_home_screen.dart';

/// The rows the design names, in its order. Each maps onto a destination the
/// app already has — nothing here is new, only re-doored.
///
/// Settings opens the family profile: it is where language, the child's
/// details and what the app shows are tuned. There is no separate parenting
/// settings screen; the pregnancy `ProfileScreen` needs a `PregnancyController`
/// and would be the wrong screen for a parent of a toddler.
List<ExploreEntry> _named() => [
      ExploreEntry(Icons.people_outline_rounded, 'Community',
          'Parents whose babies are the same age as ${ChildProfileStore.instance.nameMid}.',
          const CommunityScreen()),
      ExploreEntry(Icons.play_circle_outline, 'Watch',
          'Every video, phase by phase.', const WatchHomeScreen()),
      ExploreEntry(Icons.school_outlined, 'Learn',
          'Short courses, one sitting each.', const CoursesExploreScreen()),
      ExploreEntry(Icons.restaurant_menu_outlined, 'Recipes',
          'Food for you now, for ${ChildProfileStore.instance.nameMid} later.',
          const RecipesExploreScreen()),
      ExploreEntry(Icons.photo_camera_outlined, 'Memories',
          'Everything you have saved so far.', const MemoriesHomeScreen()),
      ExploreEntry(Icons.place_outlined, 'Find help',
          'Lactation, paediatrics and night help near you.',
          const ProblemSolverScreen()),
      ExploreEntry(Icons.settings_outlined, 'Settings',
          'Your family, reminders and language.', const FamilyProfileScreen()),
    ];

/// Drawer titles that the named rows above already stand for. A drawer row
/// with one of these titles is not repeated under "Everything else".
const Set<String> _coveredDrawerTitles = {
  'Watch',
  'Courses & Masterclasses', // → Learn
  'Recipes',
  'Memories',
  'Find help',
  'Personalize ParentVeda experience', // → Settings
};

/// The sheet's full content, in order: the named seven, then the rest of the
/// drawer. Exposed so a test can assert the drawer is fully covered.
List<ExploreEntry> ppMoreSheetEntries() => [
      ..._named(),
      for (final e in ppExploreEntries())
        if (!_coveredDrawerTitles.contains(e.title)) e,
    ];

void showPpMoreSheet(BuildContext context) {
  final p = V2PaletteStore.instance.current;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      expand: false,
      builder: (ctx, sc) {
        final named = _named();
        final rest = ppMoreSheetEntries().skip(named.length).toList();
        return Container(
          decoration: BoxDecoration(
            color: p.ground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(children: [
            // Grab handle and a close button — the design's sheet header.
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Row(children: [
                const SizedBox(width: 38),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: Icon(Icons.close_rounded, color: p.ink3),
                  splashRadius: 20,
                ),
              ]),
            ),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 26),
                children: [
                  Text('More',
                      style: pvFraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: p.ink1)),
                  const SizedBox(height: 14),
                  for (final e in named) _MoreRow(entry: e, p: p),
                  const SizedBox(height: 18),
                  Text('EVERYTHING ELSE',
                      style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: p.action)),
                  const SizedBox(height: 10),
                  for (final e in rest) _MoreRow(entry: e, p: p),
                ],
              ),
            ),
          ]),
        );
      },
    ),
  );
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.entry, required this.p});

  final ExploreEntry entry;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: entry.onTapOverride ??
              () {
                // Close the sheet, then push from the screen underneath — a
                // route pushed from inside the sheet's own context would sit
                // above a sheet that then never closes.
                final nav = Navigator.of(context);
                nav.pop();
                nav.push(MaterialPageRoute<void>(
                    settings: RouteSettings(name: 'pp/more/${entry.title}'),
                    builder: (_) => entry.screen));
              },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              Icon(entry.icon, size: 22, color: p.ink2),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title,
                          style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: p.ink1)),
                      const SizedBox(height: 2),
                      Text(entry.desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 13, height: 1.3, color: p.ink3)),
                    ]),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ]),
          ),
        ),
      );
}
