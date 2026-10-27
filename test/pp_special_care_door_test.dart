// =============================================================================
//  The Special care door, held against its plan (door 12)
// -----------------------------------------------------------------------------
//  `docs/pp-door-plans/12-special-care.md`, SC1 to SC7, as assertions. What
//  fails silently here, and must not: a three-year-old's parent opening on
//  the NICU again; a speech page that rewrites Development's signs instead of
//  linking them; a consult that opens the whole roster instead of the
//  specialist it names; Tele-MANAS typed into a doctor box; and any page
//  that promises a cure.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/data/mind_mood_data.dart'
    show kCrisisHelplineName, kCrisisHelplineNumber;
import 'package:parentveda/widgets/pv_placeholders.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/provider_results_screen.dart';

PpSection get _sc => ppSectionFor('parenting_special_care')!;
PpPage _page(String id) => _sc.pageById(id)!;
Iterable<PpLink> _links(PpPage p) => p.blocks.whereType<PpLink>();
Iterable<String?> _surfaces(PpPage p) => _links(p).map((l) => l.surfaceId);

/// This door's own pages a page links, by id. Written as `pp_page/` surfaces,
/// because `pp_gap_doors_test` asks every link in the door for a screen.
const _own = 'pp_page/parenting_special_care/';
Iterable<String> _ownLinks(PpPage p) => [
      for (final s in _surfaces(p))
        if (s != null && s.startsWith(_own)) s.substring(_own.length),
    ];

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

String _text(PpPage p) => [
      for (final b in p.blocks)
        if (b is PpIntro) b.text
        else if (b is PpArticle) ...[if (b.heading != null) b.heading!, ...b.paragraphs]
        else if (b is PpSteps) ...[if (b.heading != null) b.heading!, for (final s in b.steps) '${s.title} ${s.detail ?? ''}']
        else if (b is PpCards) ...[if (b.heading != null) b.heading!, for (final c in b.cards) '${c.title} ${c.line}']
        else if (b is PpCallout) '${b.title ?? ''} ${b.text}'
        else if (b is PpIndiaNote) b.text
        else if (b is PpWhenLine) b.text
        else if (b is PpConsult) '${b.title} ${b.whoFor}'
        else if (b is PpLink) '${b.label} ${b.blurb ?? ''}',
    ].join(' ');

Future<void> _pump(WidgetTester t, PpDoor door,
    {required int months, String? tab, List<String>? opened}) async {
  _ageMonths(months);
  await t.pumpWidget(MaterialApp(
      home: PpDoorScreen(
          key: ValueKey('$months/$tab'),
          door: door,
          onSurface: (_, s) => opened?.add(s),
          initialTabId: tab)));
  await t.pumpAndSettle();
}

const _newPages = ['sc_not_talking', 'sc_therapies', 'sc_hearing', 'sc_from_birth'];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_special_care')!;

  group('SC1: each age opens on what fits', () {
    test('the tab order for every band', () {
      const fromOne = ['more', 'help', 'you', 'twins', 'early'];
      expect(door.tabOrder, {
        'infant': ['early', 'twins', 'more', 'help', 'you'],
        'toddler_1': fromOne,
        'toddler_2': fromOne,
        'preschool': fromOne,
      });
      expect(door.tabOrder.keys.toSet(), {for (final b in _sc.bandSet!.bands) b.id});
    });

    test('every page\'s age, and none outside its area\'s', () {
      const fromOne = ['toddler_1', 'toddler_2', 'preschool'];
      const tags = {
        'sc_nicu': ['infant'],
        'sc_preemie_home': ['infant', 'toddler_1'],
        'sc_twins_breastfeeding': ['infant', 'toddler_1'],
        'sc_twins_pumping': ['infant'],
        'sc_not_talking': fromOne,
        'sc_therapies': fromOne,
        'dev_autism_signs': fromOne,
        'sc_sensory': fromOne,
        'sc_attention': ['toddler_2', 'preschool'],
        'sc_late_bloomer': fromOne,
      };
      for (final p in _sc.allPages) {
        // A new page fails here until it has a row: every age is a choice.
        expect(p.bands, tags[p.id] ?? isEmpty, reason: p.id);
      }
      final bandIds = {for (final b in _sc.bandSet!.bands) b.id};
      for (final a in _sc.areas) {
        final areaBands = a.bands.isEmpty ? bandIds : a.bands.toSet();
        for (final p in a.pages) {
          expect(areaBands.containsAll(p.bands), isTrue, reason: '${a.id}/${p.id}');
        }
      }
      // Not talking yet leads its area, so it leads Extra support from one.
      final more = _sc.areas.firstWhere((a) => a.id == 'additional_needs');
      expect(more.pages.first.id, 'sc_not_talking');
    });

    testWidgets('first view: the NICU at 3 months; Not talking yet first on Extra support at 18 and 40', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await _pump(t, door, months: 3);
      expect(find.text('If your baby goes to the NICU'), findsWidgets);
      expect(find.text('Not talking yet: what to do next'), findsNothing,
          reason: 'a baby\'s parent does not open on speech');
      for (final m in [18, 40]) {
        await _pump(t, door, months: m);
        final first = find.text('Not talking yet: what to do next');
        expect(first, findsWidgets, reason: 'Extra support opens at $m months');
        // The first page card on the tab: above or left of every other one.
        final firstAt = t.getTopLeft(first.first);
        for (final other in ['Speech therapy and the other therapies, explained',
            'Early signs of autism, and what to do if you wonder']) {
          final o = find.text(other);
          if (o.evaluate().isEmpty) continue;
          final at = t.getTopLeft(o.first);
          expect(firstAt.dy < at.dy || (firstAt.dy == at.dy && firstAt.dx < at.dx), isTrue,
              reason: '$other drawn before Not talking yet at $m months');
        }
        expect(find.text('If your baby goes to the NICU'), findsNothing,
            reason: 'the NICU tab is last from one');
      }
    });
  });

  group('SC2 and SC3: the new pages and the steps', () {
    test('the four new pages are in Extra support, with their doctor line', () {
      final more = _sc.areas.firstWhere((a) => a.id == 'additional_needs');
      for (final id in _newPages) {
        expect(more.pages.map((p) => p.id), contains(id));
        final p = _page(id);
        expect(p.linkedOnly, isFalse, reason: '$id is a card, not only a link');
        expect(p.blocks.first, isA<PpIntro>(), reason: id);
      }
    });

    test('every page has a doctor callout, a consult, or a link to a page with one', () {
      bool direct(PpPage p) =>
          p.blocks.any((b) => (b is PpCallout && b.kind == PpCalloutKind.doctor) || b is PpConsult);
      for (final p in _sc.allPages) {
        if (direct(p)) continue;
        final linked = [for (final id in _ownLinks(p)) _sc.pageById(id)!];
        expect(linked.any(direct), isTrue, reason: '${p.id} sends a worried parent nowhere');
      }
    });

    test('Not talking yet links Development\'s signs and never repeats them', () {
      final p = _page('sc_not_talking');
      expect(_surfaces(p), containsAll([
        'pp_page/parenting_development/dev_speech_by_age',
        'pp_page/parenting_development/dev_speech_flags',
        'pp_page/parenting_early_learning/skills_language',
      ]));
      expect(_ownLinks(p), contains('sc_hearing'));
      expect(p.blocks.whereType<PpCards>(), isEmpty, reason: 'no by-age cards of its own');
      final words = _text(p);
      for (final s in ['DEIC', 'free up to six years', 'RCI', 'wait five seconds', '16 to 18 months']) {
        expect(words.toLowerCase(), contains(s.toLowerCase()));
      }
      // DV10, Special care's half: both of Development's speech pages link back.
      final dev = ppSectionFor('parenting_development')!;
      for (final id in ['dev_speech_by_age', 'dev_speech_flags']) {
        expect(_surfaces(dev.pageById(id)!), contains('pp_page/parenting_special_care/sc_not_talking'), reason: id);
      }
    });

    test('the therapies: four kinds, the cost in rupees only, how to choose', () {
      final p = _page('sc_therapies');
      final words = _text(p);
      for (final s in ['Speech therapy', 'Occupational therapy', 'Physiotherapy', 'special educator',
          '₹500 to ₹1,500', 'DEIC', 'Rehabilitation Council of India', 'paid upfront']) {
        expect(words, contains(s));
      }
      expect(words, isNot(contains(r'$')), reason: 'rupees only (the user, 2026-10-26)');
      expect(words, isNot(contains('USD')));
    });

    test('hearing checks: where to test here; the signs and the ears are Health\'s, linked', () {
      final p = _page('sc_hearing');
      expect(_surfaces(p), containsAll([
        'pp_page/parenting_health/ears_hearing',
        'pp_page/parenting_health/ill_ear',
      ]));
      expect(_text(p), isNot(contains('By 6 months')), reason: 'Health\'s signs, not a twin');
      expect(_surfaces(ppSectionFor('parenting_health')!.pageById('ears_hearing')!),
          contains('pp_page/parenting_special_care/sc_hearing'));
    });

    test('a diagnosis from birth: the steps and the three links', () {
      final p = _page('sc_from_birth');
      for (final s in ['Down syndrome', 'cerebral palsy', 'in writing', 'DEIC', 'parent group', 'UDID']) {
        expect(_text(p), contains(s));
      }
      expect(_ownLinks(p), containsAll(['sc_help_india', 'sc_parent_wellbeing']));
      expect(_surfaces(p), contains('pp_page/parenting_feeding/bf_lactation_help'));
    });

    test('Help in India is steps; the schemes are named with what to do', () {
      final p = _page('sc_help_india');
      expect(p.format, 'STEPS');
      final steps = p.blocks.whereType<PpSteps>().single;
      expect(steps.steps.map((s) => s.title), [
        'Start at the DEIC',
        'The disability certificate and UDID card',
        'Niramaya health insurance',
        'Tax',
        'Pensions and scholarships',
        'School',
        'Check every professional',
      ]);
      final words = _text(p);
      for (final s in ['swavlambancard.gov.in', 'medical board', 'National Trust', '80DD',
          'district social welfare office', 'IEP', 'shadow teacher', 'RCI']) {
        expect(words, contains(s));
      }
      expect(p.blocks.whereType<PpCards>(), isNotEmpty, reason: 'the old cards stay below');
      expect(_surfaces(p), contains('pp_page/parenting_early_learning/school_admission'));
    });

    test('acting early gains the questions for the assessment', () {
      final groups = _page('sc_late_bloomer').blocks.whereType<PpSteps>().map((s) => s.heading);
      expect(groups, contains('Questions to ask at the assessment'));
    });

    test('no page names a cure: the one word is the warning about centres', () {
      final cure = RegExp(r'\bcur(e|es|ed|ing)\b', caseSensitive: false);
      final hits = <String>[
        for (final p in _sc.allPages)
          for (final m in cure.allMatches(_text(p))) '${p.id}: ${m.group(0)}',
      ];
      expect(hits, ['sc_therapies: cure']);
      expect(_page('sc_therapies').blocks.whereType<PpSteps>().last.steps.last.title,
          'Be careful of any centre that promises a "cure"');
      for (final p in _sc.allPages) {
        expect(_text(p).toLowerCase(), isNot(contains('outgrow')), reason: p.id);
      }
    });
  });

  group('SC4: the right specialist next to the worry', () {
    test('the expert row and each consult open the specialist they name, or "joining"', () {
      final more = door.tabs.firstWhere((t) => t.id == 'more');
      expect(more.expert!.surfaceId, 'pp_experts/Development expert');
      expect(ppSurfaceUnavailable(more.expert!.surfaceId), contains('developmental paediatricians are joining'),
          reason: 'placeholder profiles: the tap says so, and offers a paediatrician');
      for (final t in door.tabs.where((t) => t.id != 'more')) {
        expect(t.expert, isNull, reason: t.id);
      }
      final consults = {
        for (final p in _sc.allPages)
          for (final c in p.blocks.whereType<PpConsult>()) p.id: c.surface,
      };
      expect(consults, {
        'sc_not_talking': 'pp_experts/Speech therapist',
        'sc_attention': 'pp_experts/Child psychologist',
        'sc_from_birth': 'pp_experts/Development expert',
      });
      // Which list opens, not only that one does.
      for (final s in ['pp_experts/Speech therapist', 'pp_experts/Child psychologist']) {
        expect(ppSurfaceUnavailable(s), isNull, reason: s);
        final screen = ppScreenForSurface(s);
        expect(screen, isA<ProviderResultsScreen>(), reason: s);
        expect((screen! as ProviderResultsScreen).need?.category, s.split('/').last,
            reason: '$s must not open the whole roster');
      }
    });

    testWidgets('the row sits on Extra support and its tap names the category', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final opened = <String>[];
      await _pump(t, door, months: 30, tab: 'more', opened: opened);
      final row = find.byKey(const ValueKey('pp_door_tab_expert'));
      expect(row, findsOneWidget);
      await t.ensureVisible(row);
      await t.tap(row);
      await t.pumpAndSettle();
      expect(opened, ['pp_experts/Development expert']);
    });

    testWidgets('the closing card shows on the other tabs (S3)', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await _pump(t, door, months: 30, tab: 'help');
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsOneWidget);
      expect(find.text('Talk to a paediatrician'), findsOneWidget);
      expect(door.closing!.surfaceId, 'pp_experts/Pediatrician');
    });
  });

  group('SC5: links both ways, each on its exact page', () {
    test('every link lands; the exact pages SC5 names', () {
      const exact = {
        'dev_autism_signs': [
          'pp_page/parenting_behaviour/beh_head_banging',
          'pp_page/parenting_behaviour/beh_eating_nonfood',
        ],
        'sc_nicu': [
          'pp_page/parenting_feeding/bf_exclusive_pumping',
          'pp_page/parenting_feeding/bf_special_situations',
          'pp_page/parenting_first_40/f40_small_or_early',
        ],
        // Final review item 5: the pumping link went with the blocks that
        // repeated First 40; sc_nicu still has it.
        'sc_preemie_home': [
          'pp_page/parenting_first_40/f40_small_or_early',
          'pp_page/parenting_development/dev_born_early',
        ],
        'sc_parent_wellbeing': [
          'pp_page/parenting_maternal/mind_rage',
          'pp_page/parenting_maternal/mind_love_but_not_okay',
        ],
      };
      for (final MapEntry(key: id, value: targets) in exact.entries) {
        expect(_surfaces(_page(id)), containsAll(targets), reason: id);
      }
      for (final p in _sc.allPages) {
        for (final l in _links(p)) {
          final s = l.surfaceId;
          expect(s, isNotNull, reason: '${p.id}: pp_gap_doors_test wants a surface');
          expect(s, startsWith('pp_page/'), reason: '${p.id}: a page link names a page');
          expect(ppScreenForSurface(s!), isNotNull, reason: '${p.id} -> $s');
        }
        for (final id in _ownLinks(p)) {
          expect(_sc.pageById(id), isNotNull, reason: '${p.id} -> $id');
        }
      }
      // BH6's direction: Behaviour's two pages still point here.
      final beh = ppSectionFor('parenting_behaviour')!;
      for (final id in ['beh_head_banging', 'beh_eating_nonfood']) {
        expect(_surfaces(beh.pageById(id)!), contains('pp_page/parenting_special_care/dev_autism_signs'), reason: id);
      }
      // First 40's small-baby page still links the way in.
      expect(_surfaces(ppSectionFor('parenting_first_40')!.pageById('f40_small_or_early')!),
          containsAll([
            'pp_page/parenting_special_care/sc_preemie_home',
            // Final review item 5: the NICU link opens the NICU page.
            'pp_page/parenting_special_care/sc_nicu',
          ]));
    });

    test('Tele-MANAS is its own card, from the constant, never in a doctor box', () {
      final p = _page('sc_parent_wellbeing');
      final callouts = p.blocks.whereType<PpCallout>().toList();
      for (final c in callouts.where((c) => c.kind == PpCalloutKind.doctor)) {
        expect(c.text, isNot(contains(kCrisisHelplineNumber)));
        expect(c.text, isNot(contains(kCrisisHelplineName)));
      }
      final help = callouts.singleWhere((c) => c.text.contains(kCrisisHelplineNumber));
      expect(help.kind, isNot(PpCalloutKind.doctor));
      expect(help.text, contains(kCrisisHelplineName));
      // Typed nowhere in the live source.
      final live = File('lib/screens/post_pregnancy/pp_special_care_content.dart')
          .readAsLinesSync()
          .where((l) => !l.trimLeft().startsWith('//'));
      expect(live.any((l) => l.contains('14416')), isFalse);
    });
  });

  group('SC6 and SC7', () {
    test('two film slots, no intro slotted; the hero', () {
      final films = [for (final p in _sc.allPages) ...p.blocks.whereType<PpVideoSlot>()];
      expect(films.map((f) => f.slotId), ['special_care/kangaroo_care', 'special_care/speech_session']);
      expect(_page('sc_nicu').blocks.whereType<PpVideoSlot>().single.title, 'Kangaroo care in the NICU');
      expect(_page('sc_therapies').blocks.whereType<PpVideoSlot>().single.title,
          'What a speech therapy session looks like');
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });

    testWidgets('a film answers a tap', (t) async {
      final film = _page('sc_therapies').blocks.whereType<PpVideoSlot>().single;
      await t.pumpWidget(MaterialApp(
          home: Scaffold(body: Center(child: SizedBox(width: 320, child: PpBlockView(block: film))))));
      await t.tap(find.byType(PvVideoPlaceholder));
      await t.pump();
      expect(find.text(kPvFilmPendingNote), findsOneWidget);
      await t.pump(const Duration(seconds: 6));
      await t.pumpAndSettle();
    });

    test('the tab names', () {
      expect([for (final t in door.tabs) t.label],
          ['Preemies and NICU', 'Twins', 'Extra support', 'Help in India', 'Looking after you']);
    });
  });
}
