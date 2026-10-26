// =============================================================================
//  The Early Learning door, held against its brief
// -----------------------------------------------------------------------------
//  `Early_Learning_Parenting.pdf` as assertions. What fails silently here:
//  the activity picker coming back as a tool beside the rail that IS the
//  set; the stories going back behind the school tab; a habit page losing
//  its Behaviour twin; a coming-soon scaffold not in the owed ledger; the
//  old home's Prepare-for-school door landing on the whole library again.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/data/kids_books.dart';
import 'package:parentveda/screens/post_pregnancy/pp_early_learning_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_kids_books_shelf.dart';
import 'package:parentveda/widgets/pv_placeholders.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

PpSection get _el => ppSectionFor('parenting_early_learning')!;
PpArea _area(String id) => _el.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _el.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_early_learning')!;

  group('the map', () {
    test('five tabs, every area placed once, the everyday things at the front', () {
      expect([for (final t in door.tabs) t.id], ['today', 'stories', 'habits', 'before_letters', 'school']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _el.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.tabs.first.areaIds.first, 'today', reason: 'not behind a school button');
      for (final t in door.tabs) {
        expect(t.redFlagPageId, isNull, reason: 'no red-flag strip; no emergencies here');
      }
      expect(door.closing!.surfaceId, 'pp_experts/Early learning expert');
    });

    test('the activity set exists once: the rail, never also a tool', () {
      expect(_listed('today'), hasLength(36));
      for (final t in door.tabs) {
        expect(t.tools.map((x) => x.surfaceId), isNot(contains('pp_activities')), reason: t.id);
      }
      expect(door.tabs[0].tools.single.surfaceId, 'pp_recos');
      expect(door.tabs[0].tools.single.atEnd, isTrue, reason: 'the shop card comes after the free things');
      expect(door.tabs[3].tools.single.surfaceId, 'pp_milestones', reason: 'the one tracker, Development\'s');
      // No masterclass card until the course exists (gap analysis P2, 2026-10-07).
      expect(door.tabs[4].tools, isEmpty);
    });

    test('stories and rhymes: the how-to, six collections, the new collection', () {
      expect(door.tabs[1].areaIds, [
        'story_time', 'bedtime_tales', 'panchatantra', 'jataka', 'birbal', 'tenali', 'world_tales', 'rhymes',
      ]);
      expect(_listed('bedtime_tales'), hasLength(10));
      expect(_listed('panchatantra'), hasLength(12));
      expect(_listed('jataka'), hasLength(10));
      expect(_listed('birbal'), hasLength(10));
      expect(_listed('tenali'), hasLength(6));
      expect(_listed('world_tales'), hasLength(10));
      // EL3 (door 9 build): written out. Was comingSoon, 'AUDIO LIBRARY'.
      expect(_page('rhymes_collection').comingSoon, isFalse);
      expect(_page('rhymes_collection').format, 'CARDS');
    });

    test('the habits: fifteen, and the five twins link to their Behaviour page', () {
      expect(_listed('habits'), hasLength(15));
      const twins = {
        'hab_sharing': 'pp_page/parenting_behaviour/sharing',
        'hab_waiting': 'pp_page/parenting_behaviour/sharing',
        'hab_kindness': 'pp_page/parenting_behaviour/beh_friendships',
        'hab_truth': 'pp_page/parenting_behaviour/beh_older_lying',
        'hab_screens': 'pp_page/parenting_behaviour/beh_screen_ending',
      };
      for (final (id, target) in twins.entries.map((e) => (e.key, e.value))) {
        expect(_page(id).blocks.whereType<PpLink>().map((l) => l.surfaceId), contains(target), reason: id);
        expect(ppScreenForSurface(target), isNotNull, reason: target);
      }
    });

    test('before letters and starting school: the split, and the one new page', () {
      // EL4 and EL5 (door 9 build) add one page each.
      expect(_listed('early_skills'), ['skills_prewriting', 'skills_numeracy', 'skills_literacy', 'skills_colours_shapes', 'skills_language', 'skills_can_do_3_4_5']);
      expect(_page('skills_language').comingSoon, isFalse, reason: 'filled 2026-10-02');
      expect(_listed('school'), ['school_what_readiness', 'school_checklist', 'school_choosing', 'school_admission', 'school_first_day', 'school_what_next']);
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final p in _el.allPages.where((p) => p.comingSoon)) {
        expect(ledger.contains(p.id), isTrue, reason: '${p.id} is a coming-soon card nobody has logged as owed');
      }
    });

    test('the anti-worksheet line survives in live copy', () {
      final src = File('lib/screens/post_pregnancy/pp_early_learning_content.dart').readAsStringSync();
      expect(src.contains('worksheets can wait'), isTrue);
    });

    test('the old home\'s Prepare-for-school door lands on the school tab', () {
      final src = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
      expect(src.contains("kPpActSchoolReadiness: 'parenting_early_learning/school'"), isTrue);
      expect(door.tabFor('school')!.id, 'school');
    });
  });

  group('the age rule', () {
    test('the section auto-scopes', () => expect(_el.autoScope, isTrue));

    testWidgets('a baby\'s parent: today and stories open, habits from 1, before letters from 2, school from 3', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageMonths(5);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(5), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Peekaboo'), findsOneWidget, reason: 'a baby activity on the rail');
      expect(find.text('Playing sabzi shop'), findsNothing, reason: 'a two-year-old\'s');
      // Step 0 · S9: no lock; the three later tabs say "For later" (was
      // "From 1 year", "From 2 years", "From 3 years" with a lock).
      expect(find.text('For later'), findsNWidgets(3), reason: 'Good habits, Before letters and numbers, Starting school');
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsOneWidget); // the consult card again (step 0 · S3, 2026-10-25); was the closing line (2026-10-21)

      _ageMonths(40);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey(40), door: door, onSurface: (_, _) {}, initialTabId: 'stories')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      // EL2 (door 9 build): Birbal's stories say four to five, so a
      // three-year-old's rail has Panchatantra instead. Was 'Akbar and
      // Birbal' findsOneWidget.
      expect(find.text('Panchatantra stories'), findsOneWidget, reason: 'a three-year-old\'s collection is on the rail');
      expect(find.text('Rhymes and songs'), findsWidgets);
    });
  });

  // ===========================================================================
  //  Door 9, the plan held (docs/pp-door-plans/09-early-learning.md, EL1-EL9)
  // ===========================================================================
  group('door 9: the plan, held', () {
    const storyAreas = ['story_time', 'bedtime_tales', 'panchatantra', 'jataka', 'birbal', 'tenali', 'world_tales'];
    final bands = kPpEarlyLearningBands.bands;

    test('EL1: from one to three, Today opens on talking, Help him talk first', () {
      final today = door.tabs.first;
      expect(today.ageRail.keys.toSet(), {'one', 'two'}, reason: 'one to three only');
      for (final b in ['one', 'two']) {
        final rail = today.ageRail[b]!;
        expect(rail.title, 'Talking first');
        expect(rail.pageIds.first, 'skills_language', reason: b);
        for (final id in rail.pageIds) {
          expect(_el.pageById(id)?.inBand(b), isTrue, reason: '$id at $b');
        }
      }
      expect(_page('skills_language').title, 'Help him talk');
      expect(_page('skills_language').blocks.first, isA<PpIntro>());
      expect(_page('skills_language').blocks.whereType<PpSteps>().first.heading, 'Five minutes a day');
      final links = {for (final l in _page('skills_language').blocks.whereType<PpLink>()) l.surfaceId};
      expect(links, containsAll([
        'pp_page/parenting_development/dev_speech_by_age',
        'pp_page/parenting_development/dev_two_languages',
      ]));
      // DV10's Early learning half: Development's speech pages link here.
      for (final id in ['dev_speech_by_age', 'dev_speech_flags']) {
        final dev = ppSectionFor('parenting_development')!.pageById(id)!;
        expect(dev.blocks.whereType<PpLink>().map((l) => l.surfaceId),
            contains('pp_page/parenting_early_learning/skills_language'), reason: id);
      }
    });

    test('EL2: no story shows below the age it says', () {
      int? stated(String s) {
        final m = RegExp(r'^From (?:about )?(birth|one|eighteen|two|three|four|five)\b( and a half)?').firstMatch(s);
        if (m == null) return null;
        const base = {'birth': 0, 'one': 12, 'eighteen': 18, 'two': 24, 'three': 36, 'four': 48, 'five': 60};
        return base[m[1]]! + (m[2] == null ? 0 : 6);
      }

      var checked = 0;
      for (final a in storyAreas.map(_area)) {
        for (final page in a.pages) {
          final when = page.blocks.whereType<PpWhenLine>().first.text;
          final from = stated(when);
          expect(from, isNotNull, reason: '${page.id}: "$when"');
          checked++;
          for (final b in bands) {
            if (!a.inBand(b.id) || !page.inBand(b.id)) continue;
            expect(b.toMonths, greaterThan(from!), reason: '${page.id} says "$when" and shows at ${b.label}');
          }
        }
      }
      expect(checked, 61, reason: 'three how-tos and 58 stories');
      // The bedtime tales run to five; the collections open at their ages.
      expect(_area('bedtime_tales').bands, contains('four'));
      expect(_area('panchatantra').bands, ['three', 'four']);
      expect(_area('world_tales').bands, ['three', 'four']);
      for (final id in ['jataka', 'birbal', 'tenali']) {
        expect(_area(id).bands, ['four'], reason: id);
      }
    });

    test('EL2: under three, the Stories tab is the how-to and the bedtime tales', () {
      final stories = door.tabs[1];
      for (final b in ['one', 'two']) {
        final shown = {
          for (final id in stories.areaIds)
            if (_area(id).inBand(b)) for (final x in _area(id).pagesFor(b)) x.id,
        };
        expect(shown, contains('st_bed_sleepy_elephant'), reason: b);
        expect(shown.where((id) => id.startsWith('st_pan_') || id.startsWith('st_jat_') || id.startsWith('st_world_')), isEmpty, reason: b);
      }
    });

    test('a page is never tagged outside its own area\'s ages', () {
      for (final a in _el.areas) {
        if (a.bands.isEmpty) continue;
        for (final page in a.pages) {
          for (final b in page.bands) {
            expect(a.bands, contains(b), reason: '${page.id} is tagged $b in ${a.id}');
          }
        }
      }
    });

    test('EL3: the rhymes are written out, folk rhymes only', () {
      final r = _page('rhymes_collection');
      expect(r.blocks.first, isA<PpIntro>());
      final cards = [for (final c in r.blocks.whereType<PpCards>()) ...c.cards];
      expect(cards, hasLength(10));
      final text = [for (final c in cards) '${c.title} ${c.line}'].join(' ');
      expect(text, contains('(Machli jal ki rani hai)'));
      for (final film in ['Lakdi ki kaathi', 'Nani teri morni', 'Chanda mama']) {
        expect(text.toLowerCase(), isNot(contains(film.toLowerCase())), reason: 'a film song, under copyright');
      }
    });

    test('EL3/EL9: every story audio row and every film answers a tap', () {
      final rows = [
        for (final a in storyAreas.map(_area))
          for (final page in a.pages)
            for (final s in page.blocks.whereType<PpAudioSlot>())
              if (s.title == 'Listen to this story') s,
      ];
      expect(rows, hasLength(58));
      for (final s in rows) {
        expect(s.pendingNote, kPpStoryAudioNote, reason: s.slotId);
      }
      final films = [for (final page in _el.allPages) ...page.blocks.whereType<PpVideoSlot>()];
      expect(films, hasLength(15), reason: 'the slots stay');
      for (final f in films) {
        expect(f.slotId, startsWith('early_learning/'), reason: 'EL8: one prefix');
      }
    });

    testWidgets('EL3: a story audio row says it is still being recorded', (t) async {
      final row = _page('st_bed_sleepy_elephant').blocks.whereType<PpAudioSlot>().single;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: PpBlockView(block: row))));
      await t.tap(find.byType(PvAudioPlaceholder));
      await t.pump();
      expect(find.text(kPpStoryAudioNote), findsOneWidget);
      await t.pump(const Duration(seconds: 6));
      await t.pumpAndSettle();
    });

    testWidgets('EL9: a film says it is still being made', (t) async {
      final film = _page('act_prewriting_lines').blocks.whereType<PpVideoSlot>().single;
      await t.pumpWidget(MaterialApp(
          home: Scaffold(body: Center(child: SizedBox(width: 320, child: PpBlockView(block: film))))));
      await t.tap(find.byType(PvVideoPlaceholder));
      await t.pump();
      expect(find.text(kPvFilmPendingNote), findsOneWidget);
      await t.pump(const Duration(seconds: 6));
      await t.pumpAndSettle();
    });

    test('EL4: what most children can do at 3, 4 and 5, and preschool from two', () {
      final p = _page('skills_can_do_3_4_5');
      expect(p.bands, ['two', 'three', 'four']);
      expect(p.blocks.first, isA<PpIntro>());
      expect([for (final c in p.blocks.whereType<PpCards>().single.cards) c.title], ['Around 3', 'Around 4', 'Around 5']);
      final callouts = p.blocks.whereType<PpCallout>().toList();
      expect(callouts.map((c) => c.text).join(' '), contains('Reading at 5 is not expected. Loving books is.'));
      final doctor = callouts.singleWhere((c) => c.kind == PpCalloutKind.doctor);
      expect(doctor.text, contains('paediatrician'));
      expect(p.blocks.whereType<PpLink>().map((l) => l.surfaceId), contains('pp_milestones'));
      expect(_page('school_choosing').bands, ['two', 'three', 'four']);
      expect(_area('school').bands, ['two', 'three', 'four']);
    });

    test('EL5: nursery admission, with the law on her side', () {
      final p = _page('school_admission');
      expect(p.bands, ['two', 'three', 'four']);
      expect(p.format, 'STEPS');
      final steps = p.blocks.whereType<PpSteps>().single.steps;
      expect(steps, hasLength(6));
      final text = [for (final s in steps) '${s.title} ${s.detail ?? ''}'].join(' ');
      for (final must in ['cut-off', '25%', 'lottery', 'No test, no interview', 'anganwadi', 'birth certificate']) {
        expect(text, contains(must));
      }
      final papers = p.blocks.whereType<PpLink>().firstWhere((l) => l.surfaceId != null).surfaceId!;
      expect(papers, 'pp_section/parenting_papers');
      expect(ppScreenForSurface(papers), isNotNull);
    });

    test('EL6: the links land on the exact page, and the twins link back', () {
      const exact = {
        'hab_bedtime': 'pp_page/parenting_sleep/bedtime_routine',
        'school_first_day': 'pp_page/parenting_behaviour/separation',
        'school_checklist': 'pp_page/parenting_potty/school_and_public',
        'hab_screens': 'pp_page/parenting_behaviour/beh_screen_limits',
        'hab_sharing': 'pp_page/parenting_behaviour/sharing',
        'hab_truth': 'pp_page/parenting_behaviour/beh_older_lying',
        'hab_brushing': 'pp_page/parenting_health/teeth_brushing',
      };
      for (final (id, target) in exact.entries.map((e) => (e.key, e.value))) {
        expect(_page(id).blocks.whereType<PpLink>().map((l) => l.surfaceId), contains(target), reason: id);
        expect(ppScreenForSurface(target), isNotNull, reason: target);
      }
      for (final id in exact.keys) {
        expect(_page(id).blocks.whereType<PpLink>().map((l) => l.surfaceId),
            isNot(anyOf(contains('pp_section/parenting_sleep'), contains('pp_section/parenting_behaviour'))),
            reason: '$id: a page, not a whole door');
      }
      // The twins link back.
      const back = {
        'parenting_behaviour': ('sharing', 'hab_sharing'),
        'parenting_health': ('teeth_brushing', 'hab_brushing'),
        'parenting_sleep': ('bedtime_routine', 'hab_bedtime'),
      };
      for (final (section, (page, twin)) in back.entries.map((e) => (e.key, e.value))) {
        final links = ppSectionFor(section)!.pageById(page)!.blocks.whereType<PpLink>().map((l) => l.surfaceId);
        expect(links, contains('pp_page/parenting_early_learning/$twin'), reason: '$section/$page');
      }
      final lying = ppSectionFor('parenting_behaviour')!.pageById('beh_older_lying')!;
      expect(lying.blocks.whereType<PpLink>().map((l) => l.surfaceId), contains('pp_page/parenting_early_learning/hab_truth'));
      // The top screen question, answered on the habit page.
      final screens = _page('hab_screens').blocks.whereType<PpArticle>().map((a) => a.heading);
      expect(screens, contains('YouTube, cartoons and "learning" apps'));
    });

    test('EL7: no fake class, the shop after the free things, one item where it helps', () {
      // No card promises a masterclass that does not exist.
      final consults = [for (final page in _el.allPages) ...page.blocks.whereType<PpConsult>()];
      for (final c in consults) {
        expect(c.title.toLowerCase(), isNot(contains('masterclass')), reason: c.title);
      }
      for (final t in _el.tools) {
        expect(t.label.toLowerCase(), isNot(contains('masterclass')), reason: t.label);
      }
      expect(consults.where((c) => c.title == 'Talk to an early learning expert'), hasLength(2));
      expect(door.tabs[0].tools.single.label, 'Toys and crayons');
      // "His milestones" in the plan; one name for the tracker everywhere (R3).
      expect(door.tabs[3].tools.single.label, 'Milestones');
      const items = {
        'act_prewriting_lines': 'pp_toys/Crayons',
        'skills_prewriting': 'pp_toys/Play Dough',
        'act_lid_matching': 'pp_toys/Puzzles',
      };
      for (final (id, target) in items.entries.map((e) => (e.key, e.value))) {
        final shop = [
          for (final l in _page(id).blocks.whereType<PpLink>())
            if ((l.surfaceId ?? '').startsWith('pp_toys') || (l.surfaceId ?? '').startsWith('pp_products')) l.surfaceId,
        ];
        expect(shop, [target], reason: '$id: one item');
        expect(ppSurfaceUnavailable(target), isNull, reason: '$target is stocked');
        expect(ppScreenForSurface(target), isNotNull, reason: target);
      }
    });

    test('EL8: the titles, and the two thin stories written out', () {
      expect(_page('st_jat_banyan_deer').title, "The deer who took another deer's place");
      expect(_el.allPages.map((p) => p.title), containsAll(["The deer who took another deer's place", "The king's cats and the milk"]));
      int words(String id) => _page(id).blocks.whereType<PpArticle>().expand((a) => a.paragraphs).join(' ').length;
      expect(words('st_bed_moon_follows'), greaterThan(1100));
      expect(words('st_pan_donkey_tiger_skin'), greaterThan(1100));
      expect(_page('st_bed_moon_follows').blocks.whereType<PpArticle>().single.paragraphs.last,
          contains('Thank you for walking me home'));
    });

    testWidgets('first view at 18 months: Talking first, Help him talk before the activities', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      _ageMonths(18);
      await t.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(18), door: door, onSurface: (_, _) {})));
      await t.pumpAndSettle();
      expect(find.text('Talking first'), findsOneWidget);
      expect(find.text('Help him talk'), findsOneWidget, reason: 'once: the area rail skips it');
      expect(t.getTopLeft(find.text('Help him talk')).dy,
          lessThan(t.getTopLeft(find.text('Stacking and nesting steel bowls')).dy),
          reason: 'the first rail, above the activities');

      _ageMonths(40);
      await t.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(40), door: door, onSurface: (_, _) {})));
      await t.pumpAndSettle();
      expect(find.text('Talking first'), findsNothing, reason: 'one to three only');
    });
  });

  // ===========================================================================
  //  BHO4 / PT13: pp_books/<goal> opens the picture books on their own screen
  // ===========================================================================
  group('BHO4: the picture books shelf, on one goal', () {
    const links = {'pp_books/Worry': 'Anxiety', 'pp_books/New sibling': 'New Sibling', 'pp_books/Potty': 'Potty Training'};

    test('the three page links open the shelf on their goal, never a toast', () {
      for (final (id, goal) in links.entries.map((e) => (e.key, e.value))) {
        expect(ppSurfaceUnavailable(id), isNull, reason: id);
        final w = ppScreenForSurface(id);
        expect(w, isA<PpKidsBooksScreen>(), reason: id);
        expect((w as PpKidsBooksScreen).goal, goal, reason: id);
      }
      // A typo opens nothing, so the link gate catches it.
      expect(ppScreenForSurface('pp_books/Worries'), isNull);
      // The pages still name these links.
      expect(ppSectionFor('parenting_behaviour')!.pageById('beh_scared_everything')!.blocks.whereType<PpLink>().map((l) => l.surfaceId), contains('pp_books/Worry'));
      expect(ppSectionFor('parenting_behaviour')!.pageById('siblings')!.blocks.whereType<PpLink>().map((l) => l.surfaceId), contains('pp_books/New sibling'));
    });

    for (final (id, goal) in links.entries.map((e) => (e.key, e.value))) {
      testWidgets('$id shows every $goal book, at every age, each with its age', (t) async {
        t.view.physicalSize = const Size(1200, 9000);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.reset);
        _ageMonths(14); // younger than the worry books (3 to 5): all ages still show
        await t.pumpWidget(MaterialApp(home: ppScreenForSurface(id)!));
        await t.pumpAndSettle();
        final mine = [for (final b in kKidsBooks) if (b.goals.contains(goal)) b];
        expect(mine, isNotEmpty);
        for (final b in mine) {
          final row = find.byKey(ValueKey('pp_kids_book_${b.id}'));
          expect(row, findsOneWidget, reason: '${b.title} ($goal)');
          expect(find.descendant(of: row, matching: find.textContaining(b.ageText)), findsOneWidget, reason: b.title);
        }
        final other = kKidsBooks.firstWhere((b) => !b.goals.contains(goal));
        expect(find.byKey(ValueKey('pp_kids_book_${other.id}')), findsNothing, reason: 'only $goal');
        if (goal == 'Anxiety') {
          expect(mine.any((b) => !b.suits(14)), isTrue, reason: 'the case the shelf missed: books older than him');
        }
      });
    }
  });
}
