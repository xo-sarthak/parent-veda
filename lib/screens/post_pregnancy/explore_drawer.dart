// =============================================================================
//  ExploreDrawer - the "Explore" left drawer (parenting app)
// -----------------------------------------------------------------------------
//  Opened from the hamburger on the My Child home. Home for the section pages
//  that don't sit in the bottom-nav's four hero tabs: Recipes, Recommendations,
//  the Learn family (Masterclasses · Cohort Courses · Guides & Tools · Courses),
//  and local-services help. Each row pushes a faithfully-built Claude Design
//  screen. Warm-Nest / Editorial-Calm styled to match the app.
// =============================================================================

import 'package:flutter/material.dart';

import 'astrology_screen.dart';
import 'cohort_courses_screen.dart';
import 'courses_screen.dart';
import 'development_home_screen.dart';
import 'food_home_screen.dart';
import 'guides_tools_screen.dart';
// The Health Guide is now reached from inside the Health ecosystem, not the
// drawer directly. Kept (commented) in case we want the direct entry back.
// import 'health_guide_screen.dart';
import 'health_home_screen.dart';
import 'investments_screen.dart';
import 'journal_v2/journal_home_screen.dart';
import 'masterclasses_screen.dart';
import 'my_child_screen.dart';
import 'nuskhe_screen.dart';
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
                  _section(context, Icons.child_care_outlined, 'My Child',
                      "Who Aarav is today - his whole story.", const MyChildScreen(),
                      top: true),
                  _section(context, Icons.play_circle_outline, 'Watch',
                      'Expert videos, chosen for his stage.', const WatchHomeScreen()),
                  _section(context, Icons.emoji_objects_outlined, 'Development',
                      'Understand & nurture how he grows.', const DevelopmentHomeScreen()),
                  // Replaced by the full Health ecosystem (the Health Guide lives
                  // inside it now). Old row kept, commented, for easy revert:
                  // _section(context, Icons.monitor_heart_outlined, 'Health Guide',
                  //     "Aarav's health record & guidance.", const HealthGuideScreen()),
                  _section(context, Icons.monitor_heart_outlined, 'Health',
                      "Aarav's living health story, organised.", const HealthHomeScreen()),
                  _section(context, Icons.ramen_dining_outlined, 'Food',
                      "What to feed Aarav today - a food companion.", const FoodHomeScreen()),
                  _section(context, Icons.restaurant_menu_outlined, 'Recipes',
                      'Age-tagged, healthier Indian food.', const RecipesScreen()),
                  _section(context, Icons.recommend_outlined, 'Recommendations',
                      'What to read, watch, play & do.', const RecommendationsScreen()),
                  _section(context, Icons.auto_stories_outlined, 'Learn',
                      'A premium reading experience for parents.', const ReadingHomeScreen()),
                  _section(context, Icons.school_outlined, 'Masterclasses',
                      'One evening with an expert.', const MasterclassesScreen()),
                  _section(context, Icons.groups_outlined, 'Cohort Courses',
                      'Guided, together - small groups.', const CohortCoursesScreen()),
                  _section(context, Icons.article_outlined, 'Guides & Tools',
                      'Downloads you keep forever.', const GuidesToolsScreen()),
                  _section(context, Icons.video_library_outlined, 'Courses',
                      'Documentary guides, stage by stage.', const CoursesScreen()),
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
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, IconData icon, String title, String desc, Widget screen,
          {bool top = false}) =>
      GestureDetector(
        onTap: () {
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
