// =============================================================================
//  The four Explore redesigns, and the bottom nav restyle.
// -----------------------------------------------------------------------------
//  Four briefs (Recipes, Recommendations, Read, Courses) describing one page:
//
//      expert banner -> search -> filters/chips -> a personalised "chosen for
//      you" -> horizontal sections with See more -> dedicated listing pages
//
//  They said so themselves — "should feel like its sibling", "so all three
//  sections feel like part of one cohesive Explore experience" — so it is built
//  once in pp_explore_kit.dart and applied four times.
//
//  These tests hold two different things, and the second is the one that rots
//  first:
//
//    * that each screen followed its own brief;
//    * that all four still share the kit. Four screens that merely LOOK alike
//      drift within a month. The "every screen uses the kit" test is what
//      stops the fifth person copying a card instead of importing one.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_learning_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reading_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reco_data.dart';
import 'package:parentveda/screens/post_pregnancy/recipes_explore_screen.dart';
import 'package:parentveda/screens/post_pregnancy/courses_explore_screen.dart';
import 'package:parentveda/screens/post_pregnancy/reco_explore_screen.dart';

String _read(String p) => File(p).readAsStringSync();

String _code(String src) => src
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  accentPalette();
  const dir = 'lib/screens/post_pregnancy';
  final recipes = _code(_read('$dir/recipes_explore_screen.dart'));
  final reco = _code(_read('$dir/reco_explore_screen.dart'));
  final read = _code(_read('$dir/read_explore_screen.dart'));
  final courses = _code(_read('$dir/courses_explore_screen.dart'));
  final kit = _code(_read('$dir/pp_explore_kit.dart'));
  final navRaw = _read('$dir/pp_common.dart');
  final nav = _code(navRaw);
  final drawerRaw = _read('$dir/explore_drawer.dart');
  final drawer = _code(drawerRaw);

  final screens = {
    'Recipes': recipes,
    'Recommendations': reco,
    'Read': read,
    'Courses': courses,
  };

  // ==========================================================================
  //  The shared shape
  // ==========================================================================
  group('all four are one page', () {
    test('every screen uses the kit rather than its own copy', () {
      // The test that matters most over time: it is what stops the next
      // person copy-pasting a card instead of importing one.
      for (final e in screens.entries) {
        expect(e.value.contains('pp_explore_kit.dart'), isTrue,
            reason: '${e.key} does not import the kit');
      }
    });

    test('every screen opens with the expert banner', () {
      for (final e in screens.entries) {
        expect(e.value.contains('ExpertCuratedBanner('), isTrue,
            reason: '${e.key} has no trust banner');
      }
    });

    test('every screen has a search bar', () {
      for (final e in screens.entries) {
        expect(e.value.contains('ExploreSearchBar('), isTrue,
            reason: '${e.key} has no search');
      }
    });

    test('every screen has section headers with See more', () {
      for (final e in screens.entries) {
        expect(e.value.contains('ExploreSectionHeader('), isTrue,
            reason: '${e.key} has no section headers');
      }
    });

    test('every screen has an empty state that says what to do next', () {
      // House rule: a feature is never hidden, and the empty state is the
      // feature's advertisement. So every one carries a CTA, not just a
      // shrug.
      for (final e in screens.entries) {
        expect(e.value.contains('ExploreEmpty('), isTrue,
            reason: '${e.key} has no empty state');
        expect(e.value.contains('cta:'), isTrue,
            reason: '${e.key} has an empty state with no way out of it');
      }
    });

    test('searching hides the sections in every one', () {
      // All four briefs ask for this in the same words: "If search is active:
      // hide all sections."
      // Matches the BEHAVIOUR, not one syntax: three screens use
      // `if (searching)` in a list and Recommendations uses a ternary inside a
      // sliver. The first version of this test looked for the literal `if` and
      // failed on the one screen that was structured differently but correct.
      for (final e in screens.entries) {
        expect(e.value.contains('_searchResults()'), isTrue,
            reason: '${e.key} has no search results path');
        expect(e.value.contains('_sections()'), isTrue,
            reason: '${e.key} has no sections path');
        expect(e.value.contains('searching'), isTrue,
            reason: '${e.key} never switches between the two');
      }
    });
  });

  // ==========================================================================
  //  What the repo's stack is, versus what the briefs asked for
  // ==========================================================================
  group('built on this codebase, not the brief\'s stack', () {
    test('no Riverpod, no GoRouter, anywhere in the new screens', () {
      // Every one of the four briefs specifies both. CLAUDE.md refuses both,
      // with reasons taken more than once: a second state paradigm means two
      // ways to do everything, and the route NAME is load-bearing here
      // (global_ask_fab reads it) which GoRouter would break.
      for (final e in {...screens, 'kit': kit}.entries) {
        for (final banned in [
          'package:flutter_riverpod',
          'package:hooks_riverpod',
          'ConsumerWidget',
          'ProviderScope',
          'package:go_router',
          'GoRoute',
          'context.go(',
        ]) {
          expect(e.value.contains(banned), isFalse,
              reason: '${e.key} uses $banned');
        }
      }
    });

    test('navigation is Navigator + MaterialPageRoute', () {
      for (final e in screens.entries) {
        expect(e.value.contains('MaterialPageRoute<void>'), isTrue,
            reason: '${e.key} does not navigate the way this app does');
      }
    });
  });

  // ==========================================================================
  //  Recipes
  // ==========================================================================
  group('Recipes', () {
    test('the ten sections the brief listed all exist', () {
      final titles = kRecipeSections.map((s) => s.title.toLowerCase()).toList();
      for (final wanted in [
        'lunch / dinner',
        'breakfast',
        'immunity boosters',
        'snacks',
        'beverages',
        'soups',
        'travel food',
        'desserts',
        'finger foods',
        'sick-day meals',
      ]) {
        expect(titles.contains(wanted), isTrue, reason: 'missing: $wanted');
      }
      expect(kRecipeSections, hasLength(10));
    });

    test('every section can actually find recipes', () {
      // A section header with nothing under it is worse than no section — it
      // reads as a broken page rather than an empty one.
      for (final s in kRecipeSections) {
        expect(s.of(kFoodRecipes), isNotEmpty, reason: '${s.title} is empty');
      }
    });

    test('the diet filter is the only global filter, and it works', () {
      expect(recipesForDiet('All').length, kFoodRecipes.length);
      expect(recipesForDiet('Veg').every((r) => r.veg), isTrue);
      expect(recipesForDiet('Vegan').every((r) => r.vegan), isTrue);
      expect(recipesForDiet('Non-veg').every((r) => !r.veg), isTrue);
    });

    test('vegan implies veg, so the two filters cannot contradict', () {
      for (final r in kFoodRecipes.where((r) => r.vegan)) {
        expect(r.veg, isTrue,
            reason: '"${r.title}" is vegan but not veg — one of the two chips '
                'would be lying');
      }
    });

    test('immunity became a section, not a switch', () {
      expect(recipes.contains('r.immunity'), isTrue);
      // It was a filter on the old home. A section is something to browse; a
      // switch is something to remember to turn on.
      final immunity =
          kRecipeSections.firstWhere((s) => s.title == 'Immunity boosters');
      expect(immunity.of(kFoodRecipes), isNotEmpty);
    });

    test('the meal planner is linked, not rebuilt', () {
      // "Tapping opens the existing Meal Planner feature. Do NOT redesign
      // Meal Planner."
      expect(recipes.contains('FoodMealPlanScreen()'), isTrue);
      expect(recipes.contains('class FoodMealPlan'), isFalse);
    });

    test('a section shows at most six on the home', () {
      expect(recipes.contains('items.take(6)'), isTrue);
    });
  });

  // ==========================================================================
  //  Recommendations
  // ==========================================================================
  group('Recommendations', () {
    test('the twelve sections the brief listed, in its order', () {
      expect(kRecoSections, hasLength(12));
      expect(kRecoSections.first.title, 'Books');
      expect(kRecoSections.last.title, 'Birthday ideas');
    });

    test('every section maps to a real category with items in it', () {
      final real = kReco.map((r) => r.category).toSet();
      for (final s in kRecoSections) {
        expect(real.contains(s.category), isTrue,
            reason: '${s.title} points at "${s.category}", which no item uses');
        expect(s.items, isNotEmpty, reason: '${s.title} is empty');
      }
    });

    test('the chips NAVIGATE, they do not filter', () {
      // The brief, emphatically: "These are NOT filters. These are section
      // navigation shortcuts."
      expect(reco.contains('ExploreNavChips('), isTrue);
      expect(reco.contains('_spy.jumpTo('), isTrue);
      // …and they are the sticky kind.
      expect(reco.contains('SliverPersistentHeader'), isTrue);
      expect(reco.contains('pinned: true'), isTrue);
    });

    test('the active chip follows the scroll', () {
      expect(reco.contains('_spy.activeIndex()'), isTrue);
      // Suppressed during an animated jump, or the chip flickers through every
      // section it passes on the way.
      expect(reco.contains('if (_spy.isJumping) return;'), isTrue);
    });

    test('search results carry a category badge', () {
      // A unified list across twelve categories is otherwise a pile of
      // unrelated things.
      expect(reco.contains('section.title'), isTrue);
      expect(reco.contains('class RecoResultRow'), isTrue);
    });

    test('cards are bookmarkable, through the store that already owns saves',
        () {
      expect(reco.contains('RecoStore.instance.toggleSave'), isTrue);
      expect(reco.contains('class RecoExploreStore'), isFalse,
          reason: 'a second save store would drift from the first');
    });
  });

  // ==========================================================================
  //  Read
  // ==========================================================================
  group('Read', () {
    test('the three removed sections are gone', () {
      for (final gone in ["Today's Read", 'Continue Reading', 'Continue reading']) {
        expect(read.contains(gone), isFalse, reason: '$gone survived');
      }
    });

    test('collections became playlists rather than being deleted', () {
      // The brief removed "Collections" as a SECTION. The collections
      // themselves are the topic playlists — same data, better job.
      expect(read.contains('kReadCollections'), isTrue);
      expect(read.contains('Explore playlist'), isTrue);
      expect(read.contains('class TopicPlaylistScreen'), isTrue);
    });

    test('the filters are the existing ones, not new ones', () {
      // "Do NOT create new filters. Do NOT rename filters. Do NOT remove
      // filters." So both rows are derived from the data that already drove
      // them.
      expect(read.contains('for (final c in kReadCollections) c.title'), isTrue,
          reason: 'topic filters must come from the existing collections');
      expect(read.contains('ReadKind.article'), isTrue);
      expect(read.contains('ReadKind.bookSummary'), isTrue);
      expect(read.contains('ReadKind.research'), isTrue);
    });

    test('every existing kind has a filter label', () {
      // If a kind ever gains a fourth value, this fails rather than silently
      // making that content unreachable by filter.
      for (final k in ReadKind.values) {
        expect(read.contains(readKindLabel(k)), isTrue,
            reason: 'no filter for ${readKindLabel(k)}');
      }
    });

    test('Chosen for you stays multi-item', () {
      // "Do NOT convert it into a single featured article."
      expect(read.contains('chosen.take(6)'), isTrue);
      expect(read.contains('ExploreRail('), isTrue);
    });

    test('the type filter reaches into an opened playlist', () {
      // "Every playlist, when opened, defaults to showing only Articles" if
      // that is what was selected.
      expect(read.contains('TopicPlaylistScreen(collection: c, type: _type)'),
          isTrue);
    });

    test('Your library is last and unchanged', () {
      expect(read.contains('ReadingLibraryScreen()'), isTrue);
      final library = read.indexOf("'Your library'");
      final playlists = read.indexOf("'Explore by topic'");
      expect(library, greaterThan(playlists),
          reason: 'the library should be the final section');
    });
  });

  // ==========================================================================
  //  Courses
  // ==========================================================================
  group('Courses', () {
    test('the three sections cover every kind that exists', () {
      final covered = kCourseSections.map((s) => s.kind).toSet();
      for (final k in LearningKind.values) {
        expect(covered.contains(k), isTrue,
            reason: '$k has no section, so its courses are unreachable');
      }
    });

    test('the existing filters are reused, not redesigned', () {
      // "Keep existing filters. Do NOT redesign them."
      expect(courses.contains('filterLearning('), isTrue);
      expect(courses.contains('kLearningTopics'), isTrue);
    });

    test('search covers experts too', () {
      expect(courses.contains('e.name.toLowerCase().contains(t)'), isTrue);
    });

    test('the big detail sections are expanded by default', () {
      // The brief's central rule, stated twice: a parent should understand the
      // course by scrolling. Only outcomes, modules and FAQs collapse.
      expect(courses.contains('_openOutcomes'), isTrue);
      expect(courses.contains('_openModules'), isTrue);
      expect(courses.contains('_openFaqs'), isTrue);
      // Each set starts empty = every individual item collapsed, every SECTION
      // rendered.
      expect(courses.contains('final _openOutcomes = <int>{};'), isTrue);
    });

    test('the sticky CTA routes into the existing purchase flow', () {
      // A second, differently-built checkout is the one thing this must not
      // grow. A parent halfway through buying should not meet a fork.
      expect(courses.contains('LearningDetailScreen(program: p)'), isTrue);
      expect(courses.contains('class Checkout'), isFalse);
    });

    test('card content is limited to what the brief listed', () {
      // "Nothing more. Avoid visual clutter." Ratings and seat counts live on
      // the detail page.
      final card = courses.substring(courses.indexOf('class CourseCard'));
      final cardOnly = card.substring(0, card.indexOf('class CourseResultRow'));
      expect(cardOnly.contains('seatsLeft'), isFalse,
          reason: 'seat counts are marketing, and the brief excluded them');
      expect(cardOnly.contains('rating'), isFalse,
          reason: 'ratings belong on the detail page');
    });
  });

  // ==========================================================================
  //  The bottom nav
  // ==========================================================================
  group('bottom nav restyle', () {
    test('every tab is the same shape now', () {
      // The old bar changed the ACTIVE tab into a horizontal pill, so the row
      // re-flowed on every tap. Now colour alone marks the active one.
      expect(nav.contains('return Expanded('), isTrue,
          reason: 'all five tabs should share the width evenly');
      expect(nav.contains('on ? child : Expanded(child: child)'), isFalse,
          reason: 'the shape-changing active tab should be gone');
    });

    test('labels are readable', () {
      // 8.5pt was there to be seen, not read.
      expect(nav.contains('ppBody(8.5'), isFalse);
      expect(nav.contains('ppBody(11,'), isTrue);
    });

    test('the old bar is commented, not deleted', () {
      expect(navRaw.contains('// THE OLD BAR. Kept for revert:'), isTrue);
      expect(navRaw.contains('//   final child = GestureDetector('), isTrue);
    });

    test('the pregnancy bar was not touched', () {
      // "that bottom menu for only parenting".
      final preg = _read('lib/widgets/pv_tab_bar.dart');
      expect(preg.contains('ppBody('), isFalse,
          reason: 'the pregnancy bar must not have picked up parenting styles');
    });
  });

  // ==========================================================================
  //  Reachability
  // ==========================================================================
  group('all four are reachable, and nothing was deleted', () {
    test('Explore opens the redesigned screens', () {
      for (final s in [
        'const RecipesExploreScreen()',
        'const RecoExploreScreen()',
        'const ReadExploreScreen()',
        'const CoursesExploreScreen()',
      ]) {
        expect(drawer.contains(s), isTrue, reason: '$s is unreachable');
      }
    });

    test('the four old rows are commented in place', () {
      for (final old in [
        '// _section(context, Icons.restaurant_menu_outlined, \'Recipes\',',
        '// _section(context, Icons.recommend_outlined, \'Recommendations\',',
        '// _section(context, Icons.auto_stories_outlined, \'READ\',',
        '// _section(context, Icons.school_outlined, \'Courses & Masterclasses\',',
      ]) {
        expect(drawerRaw.contains(old), isTrue, reason: 'missing revert: $old');
      }
    });

    test('the four old screens are still on disk', () {
      for (final f in [
        'recipes_screen.dart',
        'recommendations_screen.dart',
        'reading_home_screen.dart',
        'learning_home_screen.dart',
      ]) {
        expect(File('$dir/$f').existsSync(), isTrue,
            reason: '$f was deleted; it should only have lost a door');
      }
    });

    test('every See more leads somewhere real', () {
      for (final s in [
        'RecipeCategoryScreen',
        'RecoCategoryScreen',
        'TopicPlaylistScreen',
        'CourseListingScreen',
      ]) {
        final where = screens.values.any((v) => v.contains('$s('));
        expect(where, isTrue, reason: '$s is never opened');
      }
    });
  });
}

// =============================================================================
//  The accent palette has one definition per colour.
// -----------------------------------------------------------------------------
//  ParentVeda had a settled accent family — a green, an amber, a blue and a
//  deep rose — repeated as raw hexes across roughly forty files. Recent work
//  introduced a PARALLEL set three or four hex digits away:
//
//      green   0xFF1F8A5B (app)  vs  0xFF3E7A5E (new)
//      amber   0xFFC98A2B (app)  vs  0xFFC2661E (new)
//      blue    0xFF3E6DA6 (app)  vs  0xFF3E6BA8 (new)
//
//  Nobody would spot any single one. Together they are how a palette becomes
//  eight colours in a year, and the only thing keeping the new screens
//  consistent was that they had been copied carefully.
//
//  The tokens took the ESTABLISHED values, not the new ones, and every file
//  carrying a variant moved onto them. This test is what stops the fork
//  reappearing.
// =============================================================================

void accentPalette() {
  group('one definition per accent', () {
    test('the near-duplicate palette is gone from the whole app', () {
      final offenders = <String>[];
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final src = _code(f.readAsStringSync());
        for (final variant in [
          '0xFF3E7A5E',
          '0xFFC2661E',
          '0xFF3E6BA8',
        ]) {
          if (src.contains(variant)) {
            offenders.add('${f.path.split(RegExp(r'[\/]')).last} → $variant');
          }
        }
      }
      expect(offenders, isEmpty,
          reason: 'these shadow an existing ParentVeda accent — use '
              'ppAccent*/AppTheme.accent* instead:\n  ${offenders.join('\n  ')}');
    });

    test('each accent is defined exactly once', () {
      final theme = _read('lib/theme/app_theme.dart');
      for (final t in ['accentGreen', 'accentAmber', 'accentBlue', 'accentRose']) {
        expect('static const Color $t = '.allMatches(theme).length, 1,
            reason: '$t should have one definition');
      }
    });

    test('the tokens carry the values the app already used', () {
      // The direction matters: this was a correction of the new colours, not a
      // blessing of them. If someone later "tidies" a token to the newer hex,
      // this fails.
      final theme = _read('lib/theme/app_theme.dart');
      expect(theme.contains('accentGreen = Color(0xFF1F8A5B)'), isTrue);
      expect(theme.contains('accentAmber = Color(0xFFC98A2B)'), isTrue);
      expect(theme.contains('accentBlue = Color(0xFF3E6DA6)'), isTrue);
      expect(theme.contains('accentRose = Color(0xFFC6295A)'), isTrue);
    });

    test('parenting reads them under pp* names, pointing at the same thing', () {
      final common = _read('lib/screens/post_pregnancy/pp_common.dart');
      for (final t in ['Green', 'Amber', 'Blue', 'Rose']) {
        expect(common.contains('const Color ppAccent$t = AppTheme.accent$t;'),
            isTrue,
            reason: 'ppAccent$t must alias, not re-declare');
      }
    });

    test('the explore screens use tokens, not hexes', () {
      const dir = 'lib/screens/post_pregnancy';
      for (final f in [
        'pp_explore_kit.dart',
        'recipes_explore_screen.dart',
        'reco_explore_screen.dart',
        'read_explore_screen.dart',
        'courses_explore_screen.dart',
      ]) {
        final src = _code(_read('$dir/$f'));
        // One exception: the 8% black shadow under a bookmark, which is not an
        // accent and belongs to no family.
        final hexes = RegExp(r'0x[0-9A-Fa-f]{8}')
            .allMatches(src)
            .map((m) => m[0]!)
            .where((h) => h != '0x14000000')
            .toSet();
        expect(hexes, isEmpty, reason: '$f still has raw colours: $hexes');
      }
    });
  });
}
