// =============================================================================
//  The Behaviour door, held against its brief
// -----------------------------------------------------------------------------
//  `Behaviour_Parenting.pdf` (31 Aug 2026) as assertions. What fails silently
//  here: a second lying or listening page coming back; the crying-too-much
//  page growing prose around its step-through; a coming-soon scaffold that is
//  not in the owed ledger; the checker opening unfiltered from here; a
//  toddler tab on an infant's selector.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/data/mind_mood_data.dart' show kCrisisHelplineName, kCrisisHelplineNumber;
import 'package:parentveda/screens/doors/pv_door_rail.dart' show pvDoorRailCardKey;
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_inline_tools.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_age_bands.dart' show kPpChildBands;
import 'package:parentveda/screens/post_pregnancy/pp_behaviour_bands.dart' show kBehTooMuchForYou;
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_scripts_data.dart' show kPpScripts, ppScriptsForBand;
import 'package:parentveda/screens/post_pregnancy/reading_reader_screen.dart' show ReadingReaderScreen;
import 'package:parentveda/screens/post_pregnancy/pp_book_docs.dart' show kPpBookArticles;
import 'package:parentveda/screens/post_pregnancy/scripts_library_screen.dart';
import 'package:parentveda/screens/post_pregnancy/what_changed_screen.dart';

PpSection get _beh => ppSectionFor('parenting_behaviour')!;
PpArea _area(String id) => _beh.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _beh.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

const _badges = {
  'ARTICLE', 'SHORT ARTICLE', 'CARDS', 'INTERACTIVE', 'FLAGGED CALLOUT',
  'STEP-LIST', 'CHART', 'ACTIVITY', 'ANIMATION', 'VIDEO',
};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_behaviour')!;

  group('the map', () {
    test('five tabs, every area placed once, the dissolved area gone', () {
      expect([for (final t in door.tabs) t.id], ['crying', 'tantrums', 'this_one_thing', 'scared', 'calm']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _beh.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(_beh.areas.map((a) => a.id), isNot(contains('rules_and_others')), reason: 'folded into Three to six');
      for (final t in door.tabs) {
        expect(t.redFlagPageId, isNull, reason: 'no red-flag tab, by design');
      }
      expect(door.closing!.surfaceId, 'pp_experts/Child psychologist');
    });

    test('the infant area: six pages, the crying-too-much page is its step-through', () {
      expect(_listed('crying'), ['crying_normal', 'wont_settle', 'cant_spoil', 'temperament', 'crying_too_much', 'crying_doctor']);
      final p = _page('crying_too_much');
      expect(p.format, 'INTERACTIVE');
      expect(p.blocks.single, isA<PpInteractive>());
      final i = p.blocks.single as PpInteractive;
      expect(i.kind, PpInteractiveKind.night);
      // 2026-10-07 voice pass: door pages name no child pronoun, so "him"
      // became "your baby" here and in pp_behaviour_content.dart together.
      expect(i.items.map((x) => x.title), contains('Never shake your baby, not even lightly'));
      expect(i.closing, contains('Tell your doctor today'));
      expect(_page('crying_doctor').format, 'FLAGGED CALLOUT');
    });

    test('the toddler areas keep every card', () {
      expect(_listed('ziddi'), ['beh_ziddi', 'beh_choices', 'beh_strict_or_soft']);
      expect(_listed('first_feelings'), [
        'first_tantrums', 'hitting_biting', 'separation', 'beh_tantrum_or_meltdown', 'beh_tantrum_steps', 'beh_tantrum_public',
      ]);
      expect(_listed('the_no_year'), ['defiance', 'sharing']);
      expect(_listed('specific_behaviours'), ['beh_throwing', 'beh_screaming', 'beh_anger', 'beh_not_listening', 'beh_whining']);
      expect(_listed('screen_time'), ['beh_screen_limits', 'beh_screen_ending', 'beh_screens_family']);
      // Door 8 (BH7, BH3): "After you've shouted" after the no-hitting page,
      // and the phrases page that had no way in. Was the first four only.
      expect(_listed('discipline'),
          ['beh_no_hitting', 'beh_after_shouting', 'beh_consequences', 'beh_timeouts', 'beh_elders', 'beh_words_that_hurt']);
      expect(_listed('calming'), [
        'beh_calm_corner', 'beh_balloon_breathing', 'beh_name_the_feeling', 'beh_calm_jar', 'beh_connection_games', 'beh_feelings_checkin',
      ]);
    });

    test('three to six: the merge, the reslot and the one written page', () {
      // Door 8 (BH3): the doubled listening card is off; was after big feelings.
      expect(_listed('older_child'), [
        'beh_big_feelings', 'beh_friendships', 'beh_older_lying', 'siblings', 'beh_back_talk',
      ]);
      final back = _page('beh_back_talk');
      expect(back.title, 'Back-talk, and "I hate you"');
      expect(back.bands, ['preschool']);
      expect(back.blocks.whereType<PpScript>().single.lines.first.say, 'You are allowed to be this angry with me.');
      // 2026-10-07: the relatives' line is now in English (English-only doors).
      expect(back.blocks.whereType<PpIndiaNote>().single.text, contains('look how this child talks back'));
      expect(back.blocks.whereType<PpSteps>().single.steps, hasLength(5));
    });

    // Filled from the fork (5127abf) on the user's word, 2026-10-07.
    test('the two new areas, filled 2026-10-02 from the parenting gap analysis', () {
      expect(_listed('scared'), hasLength(7), reason: 'six from the brief plus comfort objects');
      expect(_listed('habits'), hasLength(7), reason: 'five plus nappy fights and eating non-food');
      for (final id in [..._listed('scared'), ..._listed('habits')]) {
        expect(_page(id).comingSoon, isFalse, reason: id);
        expect(_page(id).blocks.first, isA<PpIntro>(), reason: id);
      }
      expect(_page('beh_fear_worth_checking').format, 'FLAGGED CALLOUT');
    });

    test('the reformats', () {
      final balloon = _page('beh_balloon_breathing');
      expect(balloon.format, 'ANIMATION');
      expect((balloon.orderedBlocks.first as PpAnimation).kind, PpAnimationKind.breathing);
      expect(balloon.blocks.whereType<PpSteps>(), isNotEmpty, reason: 'the steps stay under the circle');
      final jar = _page('beh_calm_jar');
      expect(jar.format, 'VIDEO');
      expect(jar.orderedBlocks.first, isA<PpVideoSlot>());
      final chart = _page('beh_screen_limits').blocks.whereType<PpTable>().single;
      expect(chart.rowMonths, hasLength(chart.rows.length));
      expect(chart.herRow(30), 2, reason: 'a two-and-a-half-year-old leads with the 2 to 5 row');
    });

    test('every listed page wears a badge from the vocabulary', () {
      for (final p in _beh.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });
  });

  group('single source', () {
    test('one lying page, one listening page', () {
      expect(_beh.pageById('lying'), isNull, reason: 'merged into beh_older_lying');
      final lying = _page('beh_older_lying');
      expect(lying.orderedBlocks.first, isA<PpVideoSlot>(), reason: 'the merged film');
      expect(lying.blocks.whereType<PpScript>(), isNotEmpty, reason: 'the merged script');
      // Door 8 (BH3): the card that opened the listening page from Three to
      // six is gone too, so from three the page shows once. Was: the card
      // existed, empty, opening it.
      expect(_beh.pageById('beh_cooperation'), isNull, reason: 'one listening card');
      expect(_page('beh_not_listening').inBand('preschool'), isTrue);
    });

    test('the aggression mechanism is written once and linked from the other two', () {
      for (final id in ['hitting_biting', 'beh_no_hitting']) {
        expect(_page(id).blocks.whereType<PpLink>().any((l) => l.pageId == 'beh_anger'), isTrue, reason: id);
      }
      expect(_page('defiance').blocks.whereType<PpLink>().any((l) => l.pageId == 'beh_ziddi'), isTrue,
          reason: 'the will-before-words explanation lives on the ziddi page');
    });

    test('the checker opens pre-filtered from here, and the scripts tool has no age chips', () {
      expect(door.tabs[2].tools.single.surfaceId, 'pp_what_changed/behaviour');
      final w = ppScreenForSurface('pp_what_changed/behaviour');
      expect(w, isA<WhatChangedScreen>());
      expect((w as WhatChangedScreen).initialCategories, ['Behaviour', 'Mood']);
      expect(door.tabs[1].tools.single.surfaceId, 'pp_scripts');
      final src = File('lib/screens/post_pregnancy/scripts_library_screen.dart').readAsStringSync();
      final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      expect(live.contains('_pad(_bandRow())'), isFalse, reason: 'the band chips are off the live screen');
      expect(live.contains("'Show every age'"), isFalse);
    });
  });

  group('the age rule', () {
    test('the section auto-scopes', () => expect(_beh.autoScope, isTrue));

    // Step 0 · S9 (2026-10-25): no tab locks. The toddler tabs are on the
    // selector for an infant's parent as "For later", and open.
    testWidgets('an infant parent sees one tab for now and four for later; a four-year-old\'s sees four, without Crying', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageMonths(3);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(3), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Crying, the first year'), findsWidgets);
      // Door 8 (BH1): the page is a Right now card on this tab, not a rail
      // card too. Was `find.text('When the crying is too much')`.
      expect(find.byKey(const ValueKey('pp_beh_right_now_card_crying_too_much')), findsOneWidget);
      // The toddler tabs are on the selector, for later, with no lock.
      // 2026-10-07: tab label now English (was 'Tantrums and the ziddi years').
      expect(find.text('Tantrums'), findsWidgets);
      expect(find.text('Shy and clingy'), findsWidgets); // was 'Scared, shy or clingy' (the user's word, 2026-10-26)
      expect(find.text('For later'), findsNWidgets(4), reason: 'one line per later card');
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing, reason: 'no tab locks (S9)');
      // Landing on a later tab opens it: one line, then its pages. Was the
      // lock panel, with the pages hidden.
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey('later'), door: door, onSurface: (_, _) {}, initialTabId: 'tantrums')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_door_later_line')), findsOneWidget);
      expect(find.textContaining('This usually starts from 1 year'), findsOneWidget);
      // 2026-10-07: page title now English (was 'How to handle a ziddi bachcha').
      expect(find.text('How to handle a stubborn child'), findsWidgets);
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsOneWidget); // the consult card again (step 0 · S3, 2026-10-25); was the closing line (2026-10-21)

      _ageMonths(48);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(48), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Crying, the first year'), findsNothing, reason: 'a tab he has grown past is gone, not locked');
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      for (final t in door.tabs.skip(1)) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
      expect(find.text('What to say'), findsOneWidget);
      // Door 8 (BH4): a four-year-old opens on Keeps doing this, whose
      // child psychologist row replaces the closing card, so the tab never
      // pitches twice. Was the closing card (step 0 · S3).
      expect(find.byKey(const ValueKey('pp_door_tab_expert')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsNothing);
    });

    testWidgets('the scripts tool opens on his band with no chooser', (tester) async {
      _ageMonths(30);
      tester.view.physicalSize = const Size(1200, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: ScriptsLibraryScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 TO 3'), findsOneWidget);
      expect(find.text('Under 1'), findsNothing);
      expect(find.text('Show every age'), findsNothing);
    });
  });
  // ===========================================================================
  //  Door 8, the plan held (docs/pp-door-plans/08-behaviour.md, BH1 to BH8)
  // ===========================================================================
  group('door 8: the plan, held', () {
    test('BH1: the tab order for each age', () {
      expect(door.tabOrder, {
        'infant': ['crying', 'tantrums', 'this_one_thing', 'scared', 'calm'],
        'toddler_1': ['tantrums', 'calm', 'scared', 'this_one_thing', 'crying'],
        'toddler_2': ['tantrums', 'this_one_thing', 'calm', 'scared', 'crying'],
        'preschool': ['this_one_thing', 'calm', 'tantrums', 'scared', 'crying'],
      });
      expect(door.tabOrder.keys.toSet(), {for (final b in kPpChildBands.bands) b.id},
          reason: 'every band has an order');
    });

    test('BH1: Right now is the plan\'s cards for each age, and every one opens', () {
      for (final b in kPpChildBands.bands) {
        final picks = ppBehRightNowPicks(band: b.id);
        expect([for (final c in picks) c.name], _rightNow[b.id], reason: b.id);
        expect(picks.last.surfaceId, 'pp_scripts', reason: '${b.id}: What to say, last');
        for (final c in picks) {
          if (c.pageId case final id?) {
            expect(_page(id).inBand(b.id), isTrue, reason: '${b.id}: $id is for this age');
          } else {
            expect(ppScreenForSurface(c.surfaceId!), isA<ScriptsLibraryScreen>(), reason: c.name);
          }
        }
      }
    });

    test('BH1: Right now draws on the tab her age opens, and nowhere else', () {
      for (final b in kPpChildBands.bands) {
        final hosts = [
          for (final t in door.tabs)
            if (t.inlineSurfaceId case final id? when ppBehShelfShows(id, band: b.id)) t.id,
        ];
        expect(hosts, [door.tabOrder[b.id]!.first], reason: b.id);
      }
    });

    test('BH2: the family scripts a baby\'s tab promises exist, and every script link lands', () {
      // The tool side was built in the tools pass (29-33-other.md); the door
      // holds that its promise is kept.
      final infant = ppScriptsForBand('infant');
      expect(infant.length, greaterThanOrEqualTo(5));
      for (final id in ['family_spoiling', 'family_let_cry', 'family_milk', 'family_honey']) {
        expect(infant.any((s) => s.id == id), isTrue, reason: id);
      }
      expect(kPpScripts.firstWhere((s) => s.id == 'family_honey').safety, contains('No honey'));
      final scriptIds = {for (final s in kPpScripts) s.id};
      for (final p in _beh.allPages) {
        for (final l in p.blocks.whereType<PpLink>()) {
          final s = l.surfaceId;
          if (s != null && s.startsWith('pp_scripts/')) {
            expect(scriptIds, contains(s.substring('pp_scripts/'.length)), reason: '${p.id}: $s');
          }
        }
      }
      // "Read the whole thing" is wired at the call site: the router builds
      // the tool, and a tool with no opener uses its own (the wiring gate).
      expect(ppScreenForSurface('pp_scripts'), isA<ScriptsLibraryScreen>());
      final src = File('lib/screens/post_pregnancy/scripts_library_screen.dart').readAsStringSync();
      expect(src, contains('ppOpenScriptPage(context, pageId)'));
    });

    test('BH3: the ages fixed, the loose page placed, nothing doubled', () {
      expect(_page('beh_comfort_object').bands, ['toddler_1', 'toddler_2', 'preschool']);
      expect(_page('beh_eating_nonfood').bands, ['toddler_1', 'toddler_2', 'preschool']);
      expect(_page('hitting_biting').bands, ['toddler_1', 'toddler_2']);
      expect(_page('beh_anger').blocks.whereType<PpLink>().any((l) => l.pageId == 'hitting_biting'), isTrue,
          reason: 'from three, the anger page is the way to the moment');
      expect(_listed('discipline'), contains('beh_words_that_hurt'));
      // No page sits outside its own area's ages: that is how hitting showed
      // at three to six only under "Earlier".
      for (final a in _beh.areas) {
        for (final p in a.pages) {
          if (a.bands.isEmpty) continue;
          expect(p.bands, isNotEmpty, reason: '${p.id}: an untagged page reads as every age');
          expect(a.bands.toSet().containsAll(p.bands), isTrue, reason: '${p.id} vs ${a.id}');
        }
      }
      // Every page on a tab, once.
      final ids = [for (final p in _beh.allPages) p.id];
      expect(ids, hasLength(ids.toSet().length));
      final placed = {for (final t in door.tabs) ...t.areaIds};
      for (final a in _beh.areas) {
        expect(placed, contains(a.id));
      }
    });

    test('BH4: a child psychologist on Keeps doing this, the right specialist on each consult', () {
      final keeps = door.tabs.firstWhere((t) => t.id == 'this_one_thing');
      expect(keeps.expert!.surfaceId, 'pp_experts/Child psychologist');
      expect(door.closing!.surfaceId, 'pp_experts/Child psychologist', reason: 'the closing card stays');
      PpConsult consult(String id) => _page(id).blocks.whereType<PpConsult>().single;
      expect(consult('crying_doctor').surface, 'pp_experts/Pediatrician');
      expect(consult('siblings').surface, 'pp_experts/Child psychologist');
    });

    test('BH4: help for her, beside the worry and never stacked with a warning', () {
      // The step-through: Tele-MANAS is a step, two away from never-shake.
      final steps = (_page('crying_too_much').blocks.single as PpInteractive).items;
      final help = steps.indexWhere((i) => i.title.contains(kCrisisHelplineNumber));
      final shake = steps.indexWhere((i) => i.title.startsWith('Never shake'));
      expect(help, greaterThanOrEqualTo(0));
      expect(steps[help].title, contains(kCrisisHelplineName));
      expect(shake - help, greaterThan(1), reason: 'not next to the warning');
      // ⚠️ PER CALLOUT, NOT THE PAGE'S TEXT JOINED (door 8 review). Joined,
      // this passed while the helpline rode inside the doctor box on
      // "After you've shouted". Now: its own card, no warning or doctor box
      // carries it, and it sits more than a block away from each.
      for (final id in ['beh_no_hitting', 'beh_after_shouting']) {
        final blocks = _page(id).blocks;
        final card = blocks.indexWhere((b) => b is PpCallout && b.text == kBehTooMuchForYou);
        expect(card, greaterThanOrEqualTo(0), reason: '$id: the card, on its own');
        expect((blocks[card] as PpCallout).kind, PpCalloutKind.key, reason: id);
        expect(kBehTooMuchForYou, contains('$kCrisisHelplineName, $kCrisisHelplineNumber'));
        for (final (i, b) in blocks.indexed) {
          if (b is! PpCallout || i == card) continue;
          if (b.kind != PpCalloutKind.safety && b.kind != PpCalloutKind.doctor) continue;
          expect(b.text, isNot(contains(kCrisisHelplineNumber)), reason: '$id: inside a warning box');
          expect((card - i).abs(), greaterThan(1), reason: '$id: rule c, never stacked with the warning');
        }
        expect(blocks.whereType<PpLink>().any((l) => l.surfaceId == 'pp_page/parenting_maternal/mind_rage'),
            isTrue, reason: id);
      }
      // The source never types the number: one constant (mind_mood_data.dart).
      for (final f in ['pp_behaviour_content.dart', 'pp_behaviour_bands.dart', 'pp_behaviour_more.dart']) {
        expect(File('lib/screens/post_pregnancy/$f').readAsStringSync().contains('14416'), isFalse, reason: f);
      }
    });

    test('BH5: one book a page, the plan\'s books, never on a page with a warning', () {
      final books = <String, String>{};
      for (final p in _beh.allPages) {
        final links = [
          for (final l in p.blocks.whereType<PpLink>())
            if (l.surfaceId case final s? when s.startsWith('pp_book/') || s.startsWith('pp_books/')) s,
        ];
        expect(links.length, lessThanOrEqualTo(1), reason: '${p.id}: one book a page');
        if (links.isEmpty) continue;
        books[p.id] = links.single;
        final warned = (p.format ?? '').contains('FLAG') ||
            p.pinned ||
            p.blocks.any((b) => b is PpCallout && b.kind == PpCalloutKind.safety);
        expect(warned, isFalse, reason: '${p.id} carries a warning');
      }
      expect(books, {
        'first_tantrums': 'pp_book/book_no_bad_kids',
        'beh_big_feelings': 'pp_book/book_good_inside',
        'beh_consequences': 'pp_book/book_no_drama_discipline',
        'beh_not_listening': 'pp_book/book_how_to_talk_so_kids_will_listen_listen_s',
        'beh_timeouts': 'pp_book/book_positive_discipline',
        'beh_elders': 'pp_book/book_punishment_free_parenting',
        'beh_anger': 'pp_book/book_whole_brain',
        'beh_scared_everything': 'pp_books/Worry',
        'siblings': 'pp_books/New sibling',
      });
      for (final s in books.values) {
        if (s.startsWith('pp_book/')) {
          // The book it names, not just a reader (door 8 review: a reader on
          // the fallback article passed `isA` too).
          final w = ppScreenForSurface(s);
          expect(w, isA<ReadingReaderScreen>(), reason: s);
          expect((w as ReadingReaderScreen).article.id, s.substring('pp_book/'.length), reason: s);
        } else {
          // BHO4 (door 9 build): the shelf opens on its goal. Was a toast
          // naming two titles (`kPpNotYetWords[s]`), kept for revert. The
          // books it shows are held in pp_early_learning_door_test.
          expect(ppSurfaceUnavailable(s), isNull, reason: s);
          expect(ppScreenForSurface(s), isNotNull, reason: s);
        }
      }
      // A typo never opens the reader's fallback article.
      expect(ppScreenForSurface('pp_book/book_not_a_book'), isNull);
      // A real book the parenting shelf does not carry fails too: the guard
      // reads the lookup's own list (door 8 review). It passed before.
      expect(ppScreenForSurface('pp_book/book_expecting_better'), isNull);
      // And every pp_book id that does open, opens itself.
      for (final a in kPpBookArticles) {
        final w = ppScreenForSurface('pp_book/${a.id}');
        expect((w as ReadingReaderScreen).article.id, a.id, reason: a.id);
      }
    });

    test('BH6: links land on the page they name', () {
      for (final p in _beh.allPages) {
        for (final l in p.blocks.whereType<PpLink>()) {
          expect(l.surfaceId, isNot('pp_sleep'), reason: '${p.id}: the journey screen, not the Sleep door');
          final s = l.surfaceId;
          if (s != null && s.startsWith('pp_page/')) {
            final [_, section, page] = s.split('/');
            expect(ppSectionFor(section)?.pageById(page), isNotNull, reason: '${p.id}: $s');
          }
        }
      }
      bool links(String id, String to) =>
          _page(id).blocks.whereType<PpLink>().any((l) => l.surfaceId == to || l.pageId == to);
      expect(links('siblings', 'pp_page/parenting_family/fam_sibling_jealousy'), isTrue);
      expect(links('beh_ziddi', 'pp_page/parenting_development/dev_speech_flags'), isTrue);
      expect(links('beh_head_banging', 'pp_page/parenting_special_care/dev_autism_signs'), isTrue);
      expect(links('beh_eating_nonfood', 'pp_page/parenting_special_care/dev_autism_signs'), isTrue);
      expect(links('crying_normal', 'pp_page/parenting_health/tummy_colic'), isTrue);
      expect(links('crying_normal', 'pp_page/parenting_sleep/gentle_settling'), isTrue);
      expect(links('wont_settle', 'pp_page/parenting_sleep/gentle_settling'), isTrue);
      expect(links('beh_screen_limits', 'beh_screen_ending'), isTrue);
      expect(links('beh_screen_ending', 'beh_screens_family'), isTrue);
      expect(links('beh_screens_family', 'beh_screen_limits'), isTrue);
    });

    test('BH7: colic named, tantrums given an end, the new page and parts, the thin pages written', () {
      final colic = _page('crying_normal');
      expect(colic.title, 'Colic, or normal crying?');
      final colicText = colic.blocks.whereType<PpArticle>().firstWhere((a) => a.heading == 'Is it colic?').paragraphs.join(' ');
      expect(colicText, contains('more than three hours a day'));
      expect(colicText, contains('three to four months'), reason: "Health's tummy_colic figure");
      expect(_page('first_tantrums').blocks.whereType<PpArticle>().any((a) => a.heading == 'When do tantrums stop?'), isTrue);
      expect(_page('beh_tantrum_public').blocks.whereType<PpArticle>().any((a) => a.heading == 'At functions and festivals'), isTrue);
      expect(_page('beh_screens_family').blocks.whereType<PpArticle>().any((a) => a.heading == 'The phone at meals'), isTrue);
      final shout = _page('beh_after_shouting');
      expect(shout.bands, ['toddler_1', 'toddler_2', 'preschool']);
      expect(shout.blocks.first, isA<PpIntro>());
      expect(_listed('discipline'), contains('beh_after_shouting'));
      // The six thin pages, past the plan's line (about 700 characters).
      for (final id in [
        'beh_comfort_object', 'beh_nail_biting', 'beh_fear_dogs', 'beh_feelings_checkin', 'beh_eating_nonfood', 'beh_calm_jar',
      ]) {
        final n = [for (final b in _page(id).blocks) ..._strings(b)].join().length;
        expect(n, greaterThan(700), reason: '$id: $n characters');
      }
      // The dog bite goes to a doctor the same day.
      expect(_page('beh_fear_dogs').blocks.whereType<PpCallout>().any((c) => c.kind == PpCalloutKind.doctor), isTrue);
      // Every new clinical line carries its review mark in the source.
      final src = [
        for (final f in ['pp_behaviour_content.dart', 'pp_behaviour_bands.dart', 'pp_behaviour_more.dart'])
          File('lib/screens/post_pregnancy/$f').readAsStringSync(),
      ].join('\n');
      for (final mark in [
        'REQUIRED_REVIEW (paediatrician):\r\n        // the rule of threes',
        'REQUIRED_REVIEW (child psychologist; Tele-MANAS, MoHFW)',
        'REQUIRED_REVIEW (paediatrician): bite first aid',
        "id: 'beh_after_shouting'",
      ]) {
        expect(src.replaceAll('\r\n', '\n').contains(mark.replaceAll('\r\n', '\n')), isTrue, reason: mark);
      }
    });

    test('BH8: the fifteen film slots stay; the intro waits for its film (S4)', () {
      final slots = [for (final p in _beh.allPages) ...p.blocks.whereType<PpVideoSlot>()];
      expect(slots, hasLength(15));
      expect(slots.map((s) => s.slotId).toSet(), hasLength(15));
    });
  });

  group('door 8: on screen', () {
    Future<void> pump(WidgetTester t, int months, {String? tab, List<String>? opened}) async {
      _ageMonths(months);
      t.view.physicalSize = const Size(1200, 9000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
          home: PpDoorScreen(
              key: ValueKey('beh_${months}_$tab'),
              door: door,
              initialTabId: tab,
              onSurface: (_, id) => opened?.add(id))));
      await t.pumpAndSettle();
    }

    testWidgets('every age opens on its tab, on Right now, each card once', (t) async {
      for (final MapEntry(key: m, value: opens) in {4: 'crying', 18: 'tantrums', 30: 'tantrums', 48: 'this_one_thing'}.entries) {
        await pump(t, m);
        final tab = door.tabs.firstWhere((x) => x.id == opens);
        expect(find.descendant(of: find.byKey(pvDoorRailCardKey(0)), matching: find.text(tab.label)),
            findsOneWidget, reason: '$m months opens on $opens');
        expect(find.byKey(const ValueKey('pp_beh_right_now_shelf')), findsOneWidget, reason: '$m');
        final shelf = find.byKey(const ValueKey('pp_beh_right_now_shelf'));
        for (final c in ppBehRightNowPicks()) {
          // In the row once. ("No to everything" is also the area heading
          // below it at two to three, which is the area, not a second card.)
          expect(find.descendant(of: shelf, matching: find.text(c.name)), findsOneWidget, reason: '$m: ${c.name}');
          if (c.surfaceId case final s?) {
            expect(door.tabs.firstWhere((x) => x.id == opens).tools.where((x) => x.surfaceId == s).isEmpty ||
                    find.text(c.name).evaluate().length == 1,
                isTrue,
                reason: '$m: the ${c.name} tool row is not drawn under the row that has it');
          }
          // The colic card is named as its page, so findsOneWidget above
          // already says it is drawn once.
          if (c.pageId case final id? when _page(id).title != c.name) {
            expect(find.text(_page(id).title), findsNothing, reason: '$m: $id is on the row, not the rail too');
          }
        }
        expect(t.takeException(), isNull);
      }
    });

    testWidgets('three to six: the psychologist after the first rail, and a card opens its page', (t) async {
      final opened = <String>[];
      await pump(t, 48, opened: opened);
      final row = find.byKey(const ValueKey('pp_door_tab_expert'));
      expect(row, findsOneWidget);
      await t.ensureVisible(row);
      await t.tap(row);
      await t.pumpAndSettle();
      expect(opened, ['pp_experts/Child psychologist']);
      await t.tap(find.byKey(const ValueKey('pp_beh_right_now_card_pp_scripts')));
      await t.pumpAndSettle();
      expect(opened.last, 'pp_scripts');
      await t.tap(find.byKey(const ValueKey('pp_beh_right_now_card_beh_not_listening')));
      await t.pumpAndSettle();
      expect(find.byType(PpDoorScreen), findsNothing, reason: 'the reader is on top');
    });
  });
}

/// BH1's table, by band.
const Map<String, List<String>> _rightNow = {
  'infant': ['Colic, or normal crying?', "Won't settle", "When it's too much", "You can't spoil him", 'What to say'],
  'toddler_1': ['Tantrum steps', 'He hit someone', 'Cries when I leave', 'Two choices', 'What to say'],
  'toddler_2': ['Tantrum steps', 'He hits', 'No to everything', 'Screens off', 'What to say'],
  'preschool': ['Not listening', 'Anger', 'Screen limits', 'Calm corner', 'What to say'],
};

Iterable<String> _strings(PpBlock b) {
  if (b is PpIntro) return [b.text];
  if (b is PpArticle) return [?b.heading, ...b.paragraphs];
  if (b is PpSteps) return [?b.heading, for (final s in b.steps) ...[s.title, ?s.detail]];
  if (b is PpCards) return [?b.heading, for (final c in b.cards) ...[c.title, c.line]];
  if (b is PpCallout) return [?b.title, b.text];
  if (b is PpWhenLine) return [b.text];
  if (b is PpIndiaNote) return [b.text];
  if (b is PpVideoSlot) return [b.title, ?b.subtitle];
  if (b is PpLink) return [b.label, ?b.blurb];
  if (b is PpScript) return [?b.heading, for (final l in b.lines) ...[l.say, ?l.notThis, ?l.why]];
  return const [];
}
