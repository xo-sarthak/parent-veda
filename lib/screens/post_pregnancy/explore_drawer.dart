// =============================================================================
//  ExploreDrawer - the "Explore" left drawer (parenting app)
// -----------------------------------------------------------------------------
//  Opened from the hamburger on the My Child home. Home for the section pages
//  that don't sit in the bottom-nav's four hero tabs: Recipes, Recommendations,
//  the Learn family (Masterclasses · Cohort Courses · Guides & Tools · Courses),
//  and local-services help. Each row pushes a faithfully-built Claude Design
//  screen. Warm-Nest / Editorial-Calm styled to match the app.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../brand/brand_models.dart';
import '../../brand/brand_preview_screen.dart';
import '../../brand/launch_hub_screen.dart';
import '../brand_showcase_screen.dart';
import 'next_baby_screens.dart';
import '../care_partner/care_circle_screen.dart';
import 'pp_child_profile.dart';

import 'astrology_screen.dart';
import 'family_profile_screen.dart';
// Merged into the unified "Courses & Masterclasses" section (LearningHomeScreen).
// Kept (commented) for easy revert:
// import 'cohort_courses_screen.dart';
// import 'courses_screen.dart';
// Kept: still imported by the commented-out V1-direct row below, and by
// GrowHomeScreen, which constructs the real DevelopmentHomeScreen for V1.
// ignore: unused_import
import 'development_home_screen.dart';
// Kept: the Skill Development row below is commented, and Grow now lives in
// the bottom nav instead. Uncommenting the row needs this back.
// ignore: unused_import
import 'grow_home_screen.dart';
import 'wallet_home_screen.dart';
// Food is merged into Recipes; "Guides & Tools" retired. Kept for revert:
// import 'food_home_screen.dart';
// import 'guides_tools_screen.dart';
import 'learning_home_screen.dart';
import '../memories/memories_home_screen.dart';
import '../referral/invite_friends_screen.dart';
import 'my_bookings_screen.dart';
import 'yoga_home_screen.dart';
// The Health Guide is now reached from inside the Health ecosystem, not the
// drawer directly. Kept (commented) in case we want the direct entry back.
// import 'health_guide_screen.dart';
// Kept: referenced by the commented-out V1-direct row below, and constructed
// for real by WalletHomeScreen.
// ignore: unused_import
import 'health_home_screen.dart';
import 'investments_screen.dart';
import 'journal_v2/journal_home_screen.dart';
// Kept: 'His journey' was removed from this menu, not from the app.
// ignore: unused_import
import 'phase_map_screen.dart';
// import 'masterclasses_screen.dart'; // merged into LearningHomeScreen
// Kept: the My Child row is commented out (it is a bottom-nav tab).
// ignore: unused_import
import 'my_child_screen.dart';
import 'nuskhe_screen.dart';
// Kept: Guided journeys is closed off, and the screen is untouched on disk.
// ignore: unused_import
import 'journeys_screen.dart';
import 'pp_common.dart';
import 'reading_home_screen.dart';
import 'watch_home_screen.dart';
import 'problem_solver_screen.dart';
import 'recipes_screen.dart';
import 'recommendations_screen.dart';

class ExploreDrawer extends StatelessWidget {
  const ExploreDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 20, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ppEyebrow('ParentVeda'),
            const SizedBox(height: 10),
            Text('Explore', style: ppFraunces(32, h: 1.1)),
            const SizedBox(height: 6),
            Text('Everything else, one tap away.', style: ppBody(14)),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  // MY CHILD REMOVED from Explore: it is a bottom-nav tab, so a
                  // drawer row for it was a second door to the screen you are
                  // standing on. Kept for revert:
                  // _section(context, Icons.child_care_outlined, 'My Child',
                  //     "Who ${ChildProfileStore.instance.name} is today - his whole story.", const MyChildScreen(),
                  //     top: true, onTapOverride: () {
                  //   final nav = Navigator.of(context);
                  //   nav.pop();
                  //   openPpTab(context, 0);
                  // }),
                  //
                  // Renamed from 'My Family Profile'. Kept for revert:
                  // _section(context, Icons.tune_rounded, 'My Family Profile',
                  //     'Personalise ParentVeda for your family.', const FamilyProfileScreen()),
                  _section(context, Icons.tune_rounded, 'Personalize ParentVeda experience',
                      'Tune what you see, for your family.', const FamilyProfileScreen(),
                      top: true),
                  // GUIDED JOURNEYS REMOVED FROM THE APP. The screen and its
                  // content are untouched on disk; only this door is closed, so
                  // uncommenting brings it straight back. Kept for revert:
                  // _section(context, Icons.route_rounded, 'Guided journeys',
                  //     'One short read at a time, for the hard stretches.', const JourneysScreen()),
                  //
                  // HIS JOURNEY removed from the MENU, not from the app — the
                  // phase map is still reached from the My Child hero. Kept:
                  // _section(context, Icons.timeline_rounded, 'His journey',
                  //     "Every phase from birth to five, on his timeline.", const PhaseMapScreen()),
                  _section(context, Icons.play_circle_outline, 'Watch',
                      'Expert videos, chosen for his stage.', const WatchHomeScreen()),
                  // SKILL DEVELOPMENT MOVED OUT OF EXPLORE and into the bottom
                  // nav as "Brain", replacing the Ask Veda tab — see
                  // PpBottomNav in pp_common.dart. A drawer row as well would
                  // be a second door to a hero tab.
                  //
                  // Two earlier states, both kept for revert:
                  //   the original, opening V1 directly —
                  // _section(context, Icons.emoji_objects_outlined, 'Skill Development',
                  //     'Understand & nurture how he grows.', const DevelopmentHomeScreen()),
                  //   then the three-version wrapper —
                  // _section(context, Icons.emoji_objects_outlined, 'Skill Development',
                  //     'Understand & nurture how he grows.', const GrowHomeScreen()),
                  // Replaced by the full Health ecosystem (the Health Guide lives
                  // inside it now). Old row kept, commented, for easy revert:
                  // _section(context, Icons.monitor_heart_outlined, 'Health Guide',
                  //     "Aarav's health record & guidance.", const HealthGuideScreen()),
                  // Now opens the three-version wrapper (V1 = this exact
                  // screen, unchanged; V2 = the Health Wallet brief as
                  // written; V3 = the recommendation). Old row kept,
                  // commented, for easy revert:
                  // _section(context, Icons.monitor_heart_outlined, 'Health',
                  //     "${ChildProfileStore.instance.name}'s living health story, organised.", const HealthHomeScreen()),
                  _section(context, Icons.monitor_heart_outlined, 'Health',
                      "${ChildProfileStore.instance.name}'s living health story, organised.", const WalletHomeScreen()),
                  // Food is merged into Recipes now (one unified food companion). Kept for revert:
                  // _section(context, Icons.ramen_dining_outlined, 'Food',
                  //     "What to feed Aarav today - a food companion.", const FoodHomeScreen()),
                  _section(context, Icons.restaurant_menu_outlined, 'Recipes',
                      'Age-tagged Indian food, meal plans & shopping.', const RecipesScreen()),
                  _section(context, Icons.recommend_outlined, 'Recommendations',
                      'What to read, watch, play & do.', const RecommendationsScreen()),
                  _section(context, Icons.auto_stories_outlined, 'READ',
                      'Guided reads, collections and short videos.', const ReadingHomeScreen()),
                  _section(context, Icons.school_outlined, 'Courses & Masterclasses',
                      'Live cohorts, courses & masterclasses.', const LearningHomeScreen()),
                  _section(context, Icons.self_improvement_outlined, 'Yoga & Classes',
                      'Live & recorded classes for every stage.', const YogaHomeScreen()),
                  _section(context, Icons.event_available_outlined, 'My Bookings',
                      'Your classes & sessions, all in one place.', const MyBookingsScreen()),
                  _section(context, Icons.card_giftcard_outlined, 'Invite a friend',
                      'You both get a free consultation.', const InviteFriendsScreen()),
                  _section(context, Icons.diversity_1_outlined, 'Your Care Circle',
                      'The people supporting you through this.',
                      const CareCircleScreen()),
                  _section(context, Icons.auto_awesome_outlined, 'Memories',
                      'Beautiful cards for the moments that matter.', const MemoriesHomeScreen()),
                  // Masterclasses + Cohort Courses + Courses are now one section (above);
                  // "Guides & Tools" is retired. All kept (commented) for easy revert:
                  // _section(context, Icons.school_outlined, 'Masterclasses',
                  //     'One evening with an expert.', const MasterclassesScreen()),
                  // _section(context, Icons.groups_outlined, 'Cohort Courses',
                  //     'Guided, together - small groups.', const CohortCoursesScreen()),
                  // _section(context, Icons.article_outlined, 'Guides & Tools',
                  //     'Downloads you keep forever.', const GuidesToolsScreen()),
                  // _section(context, Icons.video_library_outlined, 'Courses',
                  //     'Documentary guides, stage by stage.', const CoursesScreen()),
                  _section(context, Icons.handshake_outlined, 'Find help',
                      'Vetted local services near you.', const ProblemSolverScreen()),
                  _section(context, Icons.local_florist_outlined, 'Dadi/Nani Nuskhe',
                      'Home remedies, safely.', const NuskheScreen()),
                  _section(context, Icons.savings_outlined, 'Investments & Savings',
                      'Plan ahead for their future.', const InvestmentsScreen()),
                  _section(context, Icons.auto_awesome_outlined, 'Astrology & Numerology',
                      'Optional cosmic notes.', const AstrologyScreen()),
                  _section(context, Icons.menu_book_outlined, 'My Journal V2',
                      'A keepsake storybook of their life.', const JournalWelcomeScreen()),

                  // MOVED OUT OF TOOLS, per the review. Tools is for the things
                  // you use ON your child — trackers and journeys. Launches and
                  // the Brand Studio are things to browse, which is what Explore
                  // is for.
                  //
                  // The Launch Hub keeps its one front door: a destination is
                  // visited on purpose, never pushed at anyone
                  // (docs/BRAND-STUDIO.md §3). Moving the door does not change
                  // that — it is still exactly one.
                  _section(context, Icons.auto_awesome_outlined, 'Launches',
                      'New, and worth knowing about.',
                      const LaunchHubScreen(stage: BrandStage.parenting)),
                  _section(context, Icons.workspace_premium_outlined, 'Brand Studio',
                      'All 15 brand products, walked end to end.',
                      const BrandShowcaseScreen()),
                  if (kDebugMode)
                    _section(context, Icons.science_outlined, 'Brand Studio (debug)',
                        'Every campaign, and why it is blocked.',
                        const BrandPreviewScreen()),

                  // DUE DATE and TRACK OVULATION: two separate features now,
                  // not one "Due date & ovulation" tool. They were in Tools and
                  // did nothing but show a snackbar; each now asks the one
                  // question that decides whether it applies, and says plainly
                  // that the stage switch itself is still being built rather
                  // than opening a pregnancy home over a toddler's data.
                  _section(context, Icons.calendar_month_outlined, 'Due date',
                      'Expecting again? Start here.',
                      const NextBabyScreen(intent: NextBabyIntent.dueDate)),
                  _section(context, Icons.egg_outlined, 'Track ovulation',
                      'Trying for another? Your cycle, understood.',
                      const NextBabyScreen(intent: NextBabyIntent.ovulation)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, IconData icon, String title, String desc, Widget screen,
          {bool top = false, VoidCallback? onTapOverride}) =>
      GestureDetector(
        onTap: onTapOverride ??
            () {
              final nav = Navigator.of(context);
              nav.pop(); // close the drawer
              nav.push(MaterialPageRoute<void>(builder: (_) => screen));
            },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: const BorderSide(color: ppHair),
            ),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 22, color: ppPurple),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ppJakarta(16)),
                const SizedBox(height: 2),
                Text(desc, style: ppBody(12)),
              ]),
            ),
            const SizedBox(width: 10),
            const Text('→', style: TextStyle(color: ppMuted)),
          ]),
        ),
      );
}
