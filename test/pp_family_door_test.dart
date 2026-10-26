// =============================================================================
//  The Family door, held against its plan (door 13)
// -----------------------------------------------------------------------------
//  `docs/pp-door-plans/13-family.md`, FM1 to FM6, as assertions. What fails
//  silently here, and must not: a 2-month-old's mother opening on the
//  second-baby tab again; a back-to-work, sex or single-parent page written a
//  second time in Family when You, Maa already owns it; a link to the whole
//  library or the whole roster instead of the one shelf or list it names; and
//  Tele-MANAS typed into a doctor box.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/data/mind_mood_data.dart'
    show kCrisisHelplineName, kCrisisHelplineNumber;
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_kids_books_shelf.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/provider_results_screen.dart';
import 'package:parentveda/screens/post_pregnancy/scripts_library_screen.dart';

PpSection get _fam => ppSectionFor('parenting_family')!;
PpPage _page(String id) => _fam.pageById(id)!;
Iterable<PpLink> _links(PpPage p) => p.blocks.whereType<PpLink>();
List<String?> _surfaces(PpPage p) => [for (final l in _links(p)) l.surfaceId];

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

const _maa = 'pp_page/parenting_maternal/';

/// Every link in the door, page by page, exactly. A new link fails here until
/// it has a row, so a fallback target (the whole library, a door's home)
/// cannot slip in.
const _exact = <String, List<String>>{
  'fam_telling_toddler': ['pp_books/New sibling'],
  'fam_getting_ready': ['pp_page/parenting_behaviour/separation', 'pp_books/New sibling'],
  'fam_tandem_feeding': ['pp_page/parenting_feeding/bf_latch', 'pp_page/parenting_feeding/bf_supply'],
  'fam_dad_depression': ['${_maa}mind_rage'],
  'fam_dad_breastfeeding': [
    'pp_page/parenting_feeding/bf_latch',
    'pp_page/parenting_feeding/bf_supply',
    'pp_scripts/family_milk',
  ],
  'fam_dad_leave': ['${_maa}work_your_entitlement'],
  'fam_on_your_own': [
    '${_maa}people_asking_for_help',
    '${_maa}people_separated',
    'pp_page/parenting_papers/pm_birth_certificate',
    'pp_page/parenting_papers/pm_planning_ahead',
  ],
  'fam_grandparents_help': [
    'pp_page/parenting_behaviour/beh_elders',
    'pp_scripts/family_spoiling',
    'pp_scripts/family_honey',
    'pp_page/parenting_traditional/family_pressure',
  ],
  'fam_couple_on_same_page': ['pp_page/parenting_family/fam_you_two'],
  'fam_you_two': ['${_maa}people_partner', '${_maa}people_intimacy', '${_maa}people_safe_at_home'],
  'fam_sibling_jealousy': [
    'pp_page/parenting_behaviour/siblings',
    'pp_page/parenting_behaviour/beh_anger',
    'pp_page/parenting_potty/regressions',
  ],
  'fam_choosing_childcare': [
    '${_maa}work_planning',
    '${_maa}work_your_entitlement',
    '${_maa}work_milk_stash',
    '${_maa}work_pumping_no_room',
    '${_maa}work_first_week',
  ],
  'fam_settling_in': ['pp_page/parenting_behaviour/separation', 'pp_page/parenting_health/vax_uwin'],
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_family')!;

  group('FM1: each age opens on what fits', () {
    test('the tab order for every band', () {
      const fromOne = ['second', 'siblings', 'care', 'grand', 'fathers'];
      expect(door.tabOrder, {
        'infant': ['grand', 'care', 'fathers', 'second', 'siblings'],
        'toddler_1': fromOne,
        'toddler_2': fromOne,
        'preschool': fromOne,
      });
      expect(door.tabOrder.keys.toSet(), {for (final b in _fam.bandSet!.bands) b.id});
    });

    test('every page\'s age, and none outside its area\'s', () {
      const all = ['infant', 'toddler_1', 'toddler_2', 'preschool'];
      const tags = {
        'fam_tandem_feeding': ['toddler_1', 'toddler_2', 'preschool'],
        'fam_dad_breastfeeding': ['infant'],
        'fam_dad_night_shift': ['infant'],
        'fam_dad_bonding': ['infant'],
        'fam_settling_in': all,
      };
      for (final p in _fam.allPages) {
        // A new page fails here until it has a row: every age is a choice.
        expect(p.bands, tags[p.id] ?? isEmpty, reason: p.id);
      }
      final bandIds = {for (final b in _fam.bandSet!.bands) b.id};
      for (final a in _fam.areas) {
        final areaBands = a.bands.isEmpty ? bandIds : a.bands.toSet();
        for (final p in a.pages) {
          expect(areaBands.containsAll(p.bands), isTrue, reason: '${a.id}/${p.id}');
        }
      }
    });

    testWidgets('first view: Grandma, grandpa at 3 months; A second baby at 30', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await _pump(t, door, months: 3);
      expect(find.text('Raising your child with grandparents close by'), findsWidgets);
      expect(find.text('Telling your child a baby is coming'), findsNothing,
          reason: 'a baby\'s parent does not open on the second-baby tab');
      await _pump(t, door, months: 30);
      expect(find.text('Telling your child a baby is coming'), findsWidgets);
      expect(find.text('Raising your child with grandparents close by'), findsNothing);
    });
  });

  group('FM2 and FM6: links, each on its exact page', () {
    test('every link in the door, exactly, and each lands', () {
      final actual = {
        for (final p in _fam.allPages)
          if (_links(p).isNotEmpty) p.id: _surfaces(p),
      };
      expect(actual, _exact);
      for (final p in _fam.allPages) {
        for (final l in _links(p)) {
          final s = l.surfaceId;
          // pp_gap_doors_test asks every link for a screen through surfaceId!.
          expect(s, isNotNull, reason: '${p.id}: a link names a surface, never pageId');
          expect(ppScreenForSurface(s!), isNotNull, reason: '${p.id} -> $s');
          if (s.startsWith('pp_page/')) {
            final [_, section, page] = s.split('/');
            final target = ppSectionFor(section)!.pageById(page);
            expect(target, isNotNull, reason: '${p.id} -> $s');
            // A link label that is another page's title keeps that title.
            if (!l.label.startsWith('Picture')) {
              expect(l.label, target!.title, reason: '${p.id} -> $s');
            }
          }
        }
      }
    });

    test('the script links open What to say on that script', () {
      for (final s in ['pp_scripts/family_milk', 'pp_scripts/family_spoiling', 'pp_scripts/family_honey']) {
        final screen = ppScreenForSurface(s);
        expect(screen, isA<ScriptsLibraryScreen>(), reason: s);
        expect((screen! as ScriptsLibraryScreen).initialScriptId, s.split('/').last);
      }
    });

    test('the picture books open the New Sibling shelf, never the whole library', () {
      final screen = ppScreenForSurface('pp_books/New sibling');
      expect(screen, isA<PpKidsBooksScreen>());
      expect((screen! as PpKidsBooksScreen).goal, 'New Sibling');
    });

    test('FM6: the Care tab reaches You, Maa\'s five work pages and writes none', () {
      final care = _fam.areas.firstWhere((a) => a.id == 'childcare');
      expect(care.pages.map((p) => p.id), ['fam_choosing_childcare', 'fam_settling_in'],
          reason: 'no back-to-work page of its own');
      expect(_text(_page('fam_choosing_childcare')), isNot(contains('26 weeks')));
    });

    test('the pages that link here still do', () {
      for (final (section, page) in [('parenting_behaviour', 'siblings'), ('parenting_potty', 'regressions')]) {
        final p = ppSectionFor(section)!.pageById(page)!;
        expect(_surfaces(p), contains('pp_page/parenting_family/fam_sibling_jealousy'), reason: page);
      }
    });
  });

  group('FM3: the two short pages hold only what is missing', () {
    test('You two sits next to the disagreements page and links You, Maa', () {
      final grand = _fam.areas.firstWhere((a) => a.id == 'grandparents');
      final ids = grand.pages.map((p) => p.id).toList();
      expect(ids.indexOf('fam_you_two'), ids.indexOf('fam_couple_on_same_page') + 1);
      final p = _page('fam_you_two');
      expect(p.blocks.first, isA<PpIntro>());
      final words = _text(p);
      expect(words, contains('Low desire is very common'));
      expect(words, contains('181'));
      // You, Maa owns the method and the work list; not written twice.
      expect(words.toLowerCase(), isNot(contains('lubricant')));
      expect(words.toLowerCase(), isNot(contains('three conditions')));
    });

    test('Doing it on your own is on For fathers and names a father too', () {
      final fathers = _fam.areas.firstWhere((a) => a.id == 'fathers');
      expect(fathers.pages.map((p) => p.id), contains('fam_on_your_own'));
      expect(fathers.blurb, contains('parents on their own'));
      final p = _page('fam_on_your_own');
      expect(p.blocks.first, isA<PpIntro>());
      expect(_text(p), contains('single father'));
      expect(_text(p), isNot(contains('NALSA')), reason: 'You, Maa\'s people_separated owns legal aid');
    });

    test('the "keep on purpose" pages are still here', () {
      for (final id in ['fam_dad_depression', 'fam_dad_breastfeeding', 'fam_dad_leave',
          'fam_dad_night_shift', 'fam_dad_bonding', 'people_partner_anxiety']) {
        expect(_fam.pageById(id), isNotNull, reason: id);
      }
      final safety = _page('fam_couple_on_same_page').blocks.whereType<PpCallout>().single;
      expect(safety.kind, PpCalloutKind.safety);
      expect(_text(_page('fam_age_gap')), contains('There\'s no perfect age gap'));
    });
  });

  group('Tele-MANAS', () {
    test('its own card, from the constant, in no doctor box', () {
      for (final id in ['fam_dad_depression', 'people_partner_anxiety', 'fam_on_your_own']) {
        final callouts = _page(id).blocks.whereType<PpCallout>().toList();
        for (final c in callouts.where((c) => c.kind == PpCalloutKind.doctor)) {
          expect(c.text, isNot(contains(kCrisisHelplineNumber)), reason: id);
          expect(c.text, isNot(contains(kCrisisHelplineName)), reason: id);
        }
        final help = callouts.singleWhere((c) => c.text.contains(kCrisisHelplineNumber));
        expect(help.kind, isNot(PpCalloutKind.doctor), reason: id);
        expect(help.text, contains(kCrisisHelplineName), reason: id);
        // After the doctor box (BH4 rule c).
        expect(callouts.indexOf(help),
            greaterThan(callouts.indexWhere((c) => c.kind == PpCalloutKind.doctor)), reason: id);
      }
      expect(_text(_page('fam_dad_depression')), contains('Fathers call too'));
      final live = File('lib/screens/post_pregnancy/pp_family_content.dart')
          .readAsLinesSync()
          .where((l) => !l.trimLeft().startsWith('//'));
      expect(live.any((l) => l.contains('14416')), isFalse, reason: 'typed nowhere');
    });
  });

  group('FM4 and FM5', () {
    test('the tab names', () {
      expect([for (final t in door.tabs) t.label],
          ['A second baby', 'For fathers', 'Grandma, grandpa', 'Brothers and sisters', 'Care while you work']);
    });

    test('the closing opens the child psychologists\' own list', () {
      expect(door.closing!.surfaceId, 'pp_experts/Child psychologist');
      expect(ppSurfaceUnavailable(door.closing!.surfaceId), isNull);
      final screen = ppScreenForSurface(door.closing!.surfaceId);
      expect(screen, isA<ProviderResultsScreen>());
      expect((screen! as ProviderResultsScreen).need?.category, 'Child psychologist',
          reason: 'never the whole roster');
      for (final t in door.tabs) {
        expect(t.expert, isNull, reason: t.id);
      }
    });

    testWidgets('the closing card is drawn and its tap names the list', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final opened = <String>[];
      await _pump(t, door, months: 30, tab: 'siblings', opened: opened);
      final card = find.byKey(const ValueKey('pp_door_closing_card'));
      expect(card, findsOneWidget);
      expect(find.text('Talk to a child psychologist'), findsOneWidget);
      await t.ensureVisible(card);
      await t.tap(card);
      await t.pumpAndSettle();
      expect(opened, ['pp_experts/Child psychologist']);
    });

    test('no film slotted until one exists (S4); the hero', () {
      expect([for (final p in _fam.allPages) ...p.blocks.whereType<PpVideoSlot>()], isEmpty);
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });
  });
}
