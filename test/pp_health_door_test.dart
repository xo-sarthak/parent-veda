// =============================================================================
//  The Health door, held against its rebuild brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Health_rebuild.pdf` as assertions. What fails silently here:
//  the red-flag list growing a fourth copy; a coming-soon scaffold that is not
//  in the owed ledger (the card would hold its place forever with nobody
//  owing it); the dosing table quietly coming back; a merged page returning
//  to the rail beside the tool it merged into.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_red_flags.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart' show pvDoorRailCardKey;
import 'package:parentveda/screens/doors/pv_shelf_card.dart' show PvShelfCard;
import 'package:parentveda/screens/post_pregnancy/pp_page_read.dart' show ppPageAsRead;
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart' show VaxStore;
import 'package:parentveda/screens/reader/pv_read_offer.dart';

PpSection get _health => ppSectionFor('parenting_health')!;
PpArea _area(String id) => _health.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _health.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

const _badges = {
  'CHART', 'ANIMATION', 'TOOL', 'CAROUSEL', 'CARDS', 'TABLE', 'VIDEO',
  'INTERACTIVE', 'RED FLAG', 'ARTICLE', 'ILLUSTRATION', 'AUDIO LIBRARY',
  'STEPS', 'SCRIPT',
};

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_health')!;

  group('the map', () {
    test('seven tabs (Medicines added 2026-10-07), and every collection placed or named as merged', () {
      expect(door.tabs, hasLength(7));
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _health.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.hiddenAreaIds, ['not_sure'], reason: 'the flow that IS the What Changed tool');
      expect([for (final t in door.tabs) t.id], ['wrong', 'help', 'shots', 'growing', 'well', 'medicines', 'records']);
    });

    test('get help now: the canonical list pinned, the signs film, the speeds as a story, the three new pieces', () {
      expect(door.tabs[1].redFlagPageId, 'health_go_now');
      // The signs film folded into the go-now page (door 2, §2g), and three
      // new go-now pages joined (§5b). Was health_go_now, health_signs_video,
      // health_three_speeds, health_choking_response, health_fit,
      // health_accidents.
      expect(_listed('emergency'), [
        'health_go_now', 'health_three_speeds', 'health_choking_response', 'health_fit',
        'ill_febrile_seizure', 'health_accidents', 'ill_bites', 'ill_head_bump',
      ]);
      // The door pins the first and keeps it off the rail.
      expect(door.tabs[1].redFlagPageId, 'health_go_now');
      expect(_page('health_go_now').format, 'RED FLAG');
      expect(_page('health_go_now').orderedBlocks.first, isA<PpVideoSlot>(), reason: 'the film is on the list again');
      expect(_page('health_signs_video').linkedOnly, isTrue, reason: 'old links still open');
      final speeds = _page('health_three_speeds');
      expect(speeds.format, 'INTERACTIVE');
      expect(speeds.blocks.single, isA<PpInteractive>());
      expect((speeds.blocks.single as PpInteractive).items, hasLength(9), reason: 'the nine rows of the table');
      expect(_page('health_choking_response').orderedBlocks.first, isA<PpVideoSlot>());
      // Filled 2026-10-02 from the parenting gap analysis.
      expect(_page('health_fit').comingSoon, isFalse);
      expect(_page('health_fit').orderedBlocks.first, isA<PpVideoSlot>());
      expect(_page('health_accidents').comingSoon, isFalse);
      expect(_page('health_accidents').blocks, isNotEmpty);
      expect(door.tabs[1].footer, contains('believe yourself'));
      expect(door.tabs[0].jumpToTabId, 'help', reason: 'panic is one tap from the default tab');
    });

    test('something\'s wrong: the reformats', () {
      expect(_page('fever_reading').format, 'ILLUSTRATION');
      expect(_page('fever_reading').blocks.whereType<PpIllustration>().single.kind,
          PpIllustrationKind.thermometerRoutes);
      expect(_page('fever_reading').blocks.whereType<PpTable>(), isNotEmpty, reason: 'what is normal by route stays');
      expect(_page('fever_bringing_down').blocks.whereType<PpCarousel>().single.cards.every((c) => c.myth), isTrue,
          reason: 'the sponging myths as myth-vs-fact');
      expect(_page('cold_blocked_nose').format, 'VIDEO');
      expect(_page('tummy_ors').format, 'VIDEO');
      expect(_page('prev_medicine').format, 'VIDEO');
      for (final id in ['cold_blocked_nose', 'tummy_ors', 'prev_medicine']) {
        expect(_page(id).orderedBlocks.first, isA<PpVideoSlot>(), reason: id);
      }
      expect(_page('tummy_dehydration').blocks.whereType<PpIllustration>().single.kind,
          PpIllustrationKind.dehydrationSigns);
      expect(_page('skin_which_rash').blocks.whereType<PpIllustration>().single.kind,
          PpIllustrationKind.rashGrid);
      expect(_page('skin_which_rash').blocks.whereType<PpIllustration>().single.labels, hasLength(8));
      expect(_page('skin_which_rash').blocks.whereType<PpCallout>().any((c) => c.title == 'The glass test'), isTrue);
      expect(_page('ill_teething_fever').comingSoon, isFalse, reason: 'filled 2026-10-02');
    });

    test('the dosing page is reframed: no numbers, the bottle and the mistakes', () {
      final p = _page('fever_dosing');
      expect(p.title, contains('reading the dose right'));
      expect(p.blocks.whereType<PpTable>(), isEmpty, reason: 'the mg-by-weight table must not render');
      expect(p.blocks.whereType<PpChartCard>(), isEmpty, reason: 'nor the ceilings card');
      final all = [for (final b in p.blocks) ..._strings(b)].join(' ');
      expect(RegExp(r'\d+ to \d+ mg').hasMatch(all), isFalse, reason: 'no dose range anywhere in live copy');
      expect(p.blocks.whereType<PpSteps>().single.heading, contains('bottle'));
      expect(p.blocks.whereType<PpCards>().any((c) => c.heading!.contains('overdose')), isTrue);
    });

    test('the merges are absences on the rail, with the tool leading', () {
      for (final id in ['vax_schedule', 'health_emergency_card', 'rec_wallet']) {
        expect(_page(id).linkedOnly, isTrue, reason: id);
        expect(_page(id).toolSurfaceId, isNotNull, reason: id);
      }
      expect(_listed('vaccines'), isNot(contains('vax_schedule')));
      expect(door.tabs[2].tools.single.surfaceId, 'pp_vaccines');
      // The emergency card left Records (door 2, §2c): Get help now has it.
      expect(door.tabs[6].tools.map((t) => t.surfaceId).toSet(), {'pp_health_home', 'pp_doctor_visit'});
      // the remedies pages open the one tool, filtered
      expect(_page('fever_remedies').toolSurfaceId, 'pp_nuskhe/Fever');
      expect(_page('cough_remedies').toolSurfaceId, 'pp_nuskhe/Cold & cough');
      expect(ppScreenForSurface('pp_nuskhe/Fever'), isNotNull);
    });

    test('every listed page wears a badge from the vocabulary', () {
      for (final p in _health.allPages) {
        expect(_badges, contains(p.format), reason: '${p.id}: "${p.format}"');
      }
    });
  });

  group('single source', () {
    test('the go-now list is one list, read by the page and the fever red flags', () {
      final go = _page('health_go_now').blocks.whereType<PpCallout>()
          .firstWhere((c) => c.kind == PpCalloutKind.doctor);
      for (final sign in kPpGoNowSigns) {
        expect(go.text, contains(sign), reason: 'go-now page: "$sign"');
      }
      final fever = _page('fever_red_flags').blocks.whereType<PpCallout>().map((c) => c.text).join(' ');
      for (final sign in kPpGoNowSigns) {
        expect(fever, contains(sign), reason: 'fever red flags: "$sign"');
      }
      // The fever check's gate is the same constant: a source check, since
      // the list there is private.
      final src = File('lib/screens/post_pregnancy/pp_fever_check_screen.dart').readAsStringSync();
      expect(src.contains('const List<String> _redFlags = kPpGoNowSigns;'), isTrue);
    });

    test('the choking response is canonical here and Feeding points at it', () {
      final feeding = ppSectionFor('parenting_feeding')!.pageById('safety_choking_response')!;
      expect(feeding.toolSurfaceId, 'pp_page/parenting_health/health_choking_response');
      expect(feeding.blocks, isEmpty, reason: 'no second copy');
      expect(ppScreenForSurface(feeding.toolSurfaceId!), isNotNull);
    });

    test('every coming-soon scaffold is in the owed ledger', () {
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      for (final s in kPpSections) {
        for (final p in s.allPages.where((p) => p.comingSoon)) {
          expect(ledger.contains(p.id), isTrue,
              reason: '${s.id}/${p.id} is a coming-soon card nobody has logged as owed');
        }
      }
    });
  });

  group('the age rule', () {
    test('the section auto-scopes and the newborn-only pages are tagged', () {
      expect(_health.autoScope, isTrue);
      expect(_page('fever_under_3m').bands, ['hb_nb']);
      expect(_page('ill_jaundice').bands, ['hb_nb']);
    });
  });

  group('on screen', () {
    testWidgets('the door renders six cards, the jump, the tools and the closing', (tester) async {
      _ageMonths(8);
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      for (final t in door.tabs) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
      expect(find.text('Is this an emergency?'), findsOneWidget);
      expect(find.text('Fever check'), findsOneWidget);
      // Every calm tab has its own expert row now (door 2, §3b), so it ends
      // on the doctor sentence, not the door's consult card.
      expect(find.byKey(const ValueKey('pp_door_tab_expert')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsNothing);
      expect(find.text('A fever in a baby under three months'), findsNothing,
          reason: 'an 8-month-old does not see the newborn page');
      // Tap the jump: the Get help now tab, with the red flag pinned.
      await tester.tap(find.text('Is this an emergency?'));
      await tester.pumpAndSettle();
      expect(find.text('Go to a hospital now'), findsWidgets);
      expect(find.textContaining('believe yourself'), findsOneWidget);
      // The tab's two scaffolds (health_fit, health_accidents) were filled
      // 2026-10-02, so nothing on Get help now is coming soon any more.
      expect(find.text('Coming soon'), findsNothing, reason: 'the scaffolds are filled');
      expect(find.text('Common accidents, fast'), findsWidgets);
    });
  });
  //  Door 2 of the door-by-door pass (docs/pp-door-plans/02-health.md),
  //  built 2026-10-25. The plan's tables, as data.
  // ===========================================================================
  group('door 2: the plan, held', () {
    PpDoorTab tab(String id) => door.tabs.firstWhere((t) => t.id == id);
    bool hasConsult(String id) => _page(id).blocks.any((b) => b is PpConsult);
    const n = 'hb_nb', i = 'hb_infant', t = 'hb_toddler', c = 'hb_child';

    test('§2a: Something\'s wrong and Get help now lead, the rest follow his age', () {
      expect(door.tabOrder, {
        n: ['wrong', 'help', 'records', 'shots', 'growing', 'medicines', 'well'],
        i: ['wrong', 'help', 'shots', 'growing', 'medicines', 'well', 'records'],
        t: ['wrong', 'help', 'medicines', 'well', 'shots', 'growing', 'records'],
        c: ['wrong', 'help', 'well', 'medicines', 'growing', 'shots', 'records'],
      });
      for (final order in door.tabOrder.values) {
        expect(order.toSet(), {for (final x in door.tabs) x.id}, reason: 'every tab named once');
      }
    });

    test('§2b: the two shorter labels', () {
      expect(tab('well').label, 'Keeping well');
      expect(tab('records').label, 'Records and first checks');
    });

    test('§2c: tools have ages and their places', () {
      expect(tab('well').tools.single.bands, [i, t, c], reason: 'no home remedy under three months');
      expect(tab('help').tools.single.surfaceId, 'pp_emergency_card');
      expect([for (final x in tab('records').tools) x.surfaceId], ['pp_health_home', 'pp_doctor_visit']);
      final visit = tab('wrong').tools.firstWhere((x) => x.surfaceId == 'pp_doctor_visit');
      expect(visit.atEnd, isTrue, reason: 'a sick-day visit, after the pages');
      expect([for (final x in tab('wrong').tools.take(2)) x.surfaceId], ['pp_fever_check', 'pp_what_changed']);
    });

    test('§2e: every page carries the plan\'s band tags', () {
      const all = <String>[], itc = [i, t, c], nit = [n, i, t], it = [i, t], tc = [t, c], ni = [n, i];
      const want = <String, List<String>>{
        'health_go_now': all, 'health_signs_video': all, 'health_three_speeds': all,
        'health_choking_response': all, 'health_fit': all, 'health_accidents': all,
        'ill_febrile_seizure': itc, 'ill_bites': all, 'ill_head_bump': all,
        'fever_what_number': itc, 'fever_reading': all, 'fever_under_3m': [n],
        'fever_bringing_down': itc, 'fever_dosing': itc, 'fever_red_flags': all,
        'fever_remedies': itc, 'fever_long': itc,
        'cold_common': all, 'cold_blocked_nose': nit, 'cough_syrups': itc,
        'cough_remedies': itc, 'cough_breathing': all,
        'tummy_diarrhoea': all, 'tummy_ors': all, 'tummy_dehydration': all,
        'tummy_vomiting': all, 'tummy_constipation': itc, 'ill_worms': tc,
        'tummy_colic': ni, 'tummy_poo': ni,
        'skin_which_rash': all, 'skin_hfmd': itc, 'skin_nappy_rash': nit,
        'skin_eczema': all, 'skin_heat_rash': all, 'ill_insect_bites': all,
        'skin_newborn': [n], 'skin_chickenpox': itc,
        'ill_teething': it, 'ill_ear': itc, 'ill_dengue': all, 'ill_eyes': all,
        'ill_jaundice': [n], 'ill_allergies': itc, 'ill_teething_fever': it,
        'ill_uti': all, 'ill_throat': tc, 'ill_nosebleed': tc, 'ill_thrush': ni,
        'vax_schedule': all, 'vax_what_each': all, 'vax_after': all,
        'vax_catch_up': itc, 'vax_uwin': all, 'vax_cost': all,
        'growth_normal': all, 'growth_percentiles': all, 'growth_flags': all,
        'ill_anaemia': itc,
        'health_emergency_card': all, 'rec_wallet': all, 'rec_doctor_visit': all,
        'rec_checkups_by_age': all, 'rec_abha': all, 'rec_surgery': itc,
        'prev_handwashing': all, 'prev_immunity': all, 'prev_vitamin_a': itc,
        'prev_monsoon': all, 'prev_pollution': all, 'prev_heat': all,
        'prev_sick_home': all, 'prev_private_parts': tc, 'prev_head_lice': tc,
        'prev_nails_ears': all,
        'prev_medicine_box': all, 'prev_medicine': all, 'prev_antibiotics': all,
        'prev_allergy_probiotics': all,
        'teeth_when': it, 'teeth_brushing': itc, 'teeth_dentist': itc,
        'eyes_checks': all, 'eyes_screens': tc, 'ears_hearing': all,
        'nb_screening': ni, 'nb_first_visits': ni, 'nb_boys_girls': ni,
        'lt_asthma': tc, 'lt_weight': tc, 'lt_coeliac': tc,
      };
      for (final MapEntry(:key, :value) in want.entries) {
        expect(_page(key).bands, value, reason: key);
      }
      // Every page on a tab is in the table: a new page has to be placed.
      for (final x in door.tabs) {
        for (final id in x.areaIds) {
          for (final p in _area(id).pages) {
            expect(want.containsKey(p.id), isTrue, reason: '${p.id} has no row');
          }
        }
      }
    });

    test('H2: a first rail for his age on Something\'s wrong, every page real and his', () {
      final rails = tab('wrong').ageRail;
      expect({for (final e in rails.entries) e.key: e.value.pageIds}, {
        n: ['fever_under_3m', 'ill_jaundice', 'skin_newborn', 'tummy_colic', 'cold_blocked_nose', 'ill_thrush'],
        i: ['ill_teething_fever', 'cold_common', 'tummy_diarrhoea', 'skin_nappy_rash', 'skin_eczema', 'ill_ear', 'ill_febrile_seizure'],
        t: ['cold_common', 'skin_hfmd', 'tummy_diarrhoea', 'tummy_vomiting', 'ill_ear', 'cough_breathing', 'ill_eyes'],
        c: ['ill_throat', 'cold_common', 'tummy_constipation', 'ill_ear', 'skin_chickenpox', 'ill_worms'],
      });
      for (final MapEntry(key: band, value: rail) in rails.entries) {
        for (final id in rail.pageIds) {
          expect(_page(id).inBand(band), isTrue, reason: '$id on the $band rail is not for $band');
          expect(_page(id).linkedOnly, isFalse, reason: id);
        }
      }
      expect(rails.values.map((r) => r.title), [
        'In the first three months', 'Common at 3 to 12 months', 'The creche years', 'Common at 3 to 5 years',
      ]);
    });

    test('§3a: no pitch on a go-now page or on Get help now (source scan)', () {
      final help = tab('help');
      expect(help.expert, isNull);
      expect(help.closing!.surfaceId, startsWith('pp_class/'), reason: 'H3: the class, never a consult');
      const noPitch = [
        'health_go_now', 'health_choking_response', 'health_fit', 'health_accidents',
        'ill_febrile_seizure', 'ill_bites', 'ill_head_bump',
        'fever_under_3m', 'tummy_dehydration', 'growth_flags', 'prev_private_parts', 'ill_teething',
      ];
      for (final id in [...noPitch, ..._listed('emergency')]) {
        expect(hasConsult(id), isFalse, reason: '$id: a go-now page is never sold to');
        for (final l in _page(id).blocks.whereType<PpLink>()) {
          expect(l.surfaceId?.startsWith('pp_products') ?? false, isFalse, reason: '$id sells ${l.label}');
        }
      }
    });

    test('§3b: an expert on every calm tab; Something\'s wrong carries the safety line', () {
      for (final id in ['wrong', 'shots', 'growing', 'well', 'medicines', 'records']) {
        final x = tab(id).expert;
        expect(x, isNotNull, reason: id);
        expect(ppSurfaceUnavailable(x!.surfaceId), isNull, reason: '$id: a real category');
      }
      expect(tab('wrong').expert!.note, 'Not for an emergency. For that, Get help now.');
      expect(tab('well').expert!.surfaceId, 'pp_experts/Child derma');
    });

    test('§3c: the worry pages carry a consult, to the right person', () {
      String surface(String id) => _page(id).blocks.whereType<PpConsult>().first.surface;
      for (final id in [
        'fever_red_flags', 'cough_breathing', 'ill_allergies', 'prev_antibiotics',
        'cold_common', 'fever_long', 'tummy_diarrhoea', 'tummy_vomiting', 'tummy_constipation',
        'skin_hfmd', 'ill_ear', 'ill_eyes', 'ill_uti', 'lt_asthma', 'lt_coeliac', 'vax_catch_up',
        'ill_dengue', 'ill_throat', 'ill_worms', 'nb_boys_girls',
      ]) {
        expect(surface(id), 'pp_experts/Pediatrician', reason: id);
      }
      for (final id in ['skin_which_rash', 'skin_eczema', 'skin_nappy_rash', 'ill_insect_bites']) {
        expect(surface(id), 'pp_experts/Child derma', reason: id);
      }
      for (final id in ['growth_percentiles', 'lt_weight', 'ill_anaemia']) {
        expect(surface(id), 'pp_experts/Nutritionist', reason: id);
      }
      for (final (id, owed) in [
        ('teeth_when', 'Paediatric dentist'), ('teeth_brushing', 'Paediatric dentist'),
        ('teeth_dentist', 'Paediatric dentist'), ('eyes_checks', 'Ophthalmologist'),
        ('eyes_screens', 'Ophthalmologist'), ('ears_hearing', 'Audiologist'),
      ]) {
        expect(surface(id), 'pp_experts/$owed', reason: id);
      }
    });

    test('H5: the seven owed specialists answer in plain words, and send her to a paediatrician', () {
      for (final (cat, words) in [
        ('Paediatric dentist', 'paediatric dentists'), ('Ophthalmologist', "children's eye doctors"),
        ('ENT', "children's ENT doctors"), ('Audiologist', 'audiologists'),
        ('Allergist', "children's allergy doctors"), ('Chest', "children's chest doctors"),
        ('Hormone', "children's hormone doctors"),
      ]) {
        final why = ppSurfaceUnavailable('pp_experts/$cat');
        expect(why, "We're adding $words. A paediatrician can check this first.", reason: cat);
        expect(kPpNearestExpert[cat], 'Pediatrician');
      }
    });

    test('H5 / D2: a Health consult in the reader says it is not for an emergency', () {
      final read = ppPageAsRead(_health, _page('tummy_vomiting'));
      expect(pvReadOwnConsult(read)!.surfaceId, 'pp_experts/Pediatrician');
      expect(pvReadConsultNote(read), contains('Not for an emergency'));
      final feeding = ppSectionFor('parenting_feeding')!;
      expect(pvReadConsultNote(ppPageAsRead(feeding, feeding.pageById('bf_low_supply')!)), isNull,
          reason: 'only Health');
    });

    test('H4: Health never sells a medicine; every shelf is equipment and says why when empty', () {
      const equipment = {
        'pp_products/Underarm thermometers', 'pp_products/Infrared Thermometers',
        'pp_products/Nasal aspirators', 'pp_products/Ultrasonic Humidifiers',
        'pp_products/Oral syringes', 'pp_products/Mosquito nets',
        'pp_products/True HEPA Air Purifiers', 'pp_products/Finger toothbrushes',
        'pp_products/Baby nail clippers', 'pp_products/Lice combs',
        'pp_products/Sun hats and sunscreen', 'pp_products/Health record folders',
        'pp_products/First aid',
      };
      final shelves = {
        for (final p in _health.allPages)
          for (final b in p.blocks.whereType<PpLink>())
            if (b.surfaceId case final s? when s.startsWith('pp_products')) s,
      };
      expect(shelves, equipment);
      for (final s in shelves) {
        // Opens its shelf, or says plainly why not (S8).
        final why = ppSurfaceUnavailable(s);
        if (why != null) expect(why, isNotEmpty, reason: s);
      }
      expect(ppSurfaceUnavailable('pp_products/Underarm thermometers'), contains('flexible tip'));
      expect(ppSurfaceUnavailable('pp_products/Nasal aspirators'), contains('chemist'));
      // The digital one leads, before the forehead scanner (§3f).
      final reading = [
        for (final b in _page('fever_reading').blocks.whereType<PpLink>())
          if (b.surfaceId?.startsWith('pp_products') ?? false) b.surfaceId,
      ];
      expect(reading, ['pp_products/Underarm thermometers', 'pp_products/Infrared Thermometers']);
    });

    test('H6: the fifteen new pages, each placed, each with its doctor line', () {
      for (final (id, area) in [
        ('ill_dengue', 'other_illness'), ('ill_febrile_seizure', 'emergency'),
        ('ill_throat', 'other_illness'), ('ill_worms', 'tummy'), ('ill_anaemia', 'growth'),
        ('prev_vitamin_a', 'prevention'), ('prev_heat', 'prevention'), ('ill_bites', 'emergency'),
        ('ill_insect_bites', 'skin'), ('nb_boys_girls', 'newborn_checks'),
        ('ill_nosebleed', 'other_illness'), ('ill_head_bump', 'emergency'),
        ('vax_uwin', 'vaccines'), ('rec_abha', 'records'), ('prev_medicine_box', 'medicines'),
      ]) {
        expect(_listed(area), contains(id), reason: '$id in $area');
        final p = _page(id);
        expect(p.blocks.first, isA<PpIntro>(), reason: id);
        if (id != 'vax_uwin' && id != 'rec_abha') {
          expect(p.blocks.whereType<PpCallout>().any((x) => x.kind == PpCalloutKind.doctor), isTrue,
              reason: '$id: a clinical page ends on a doctor line');
        }
      }
      expect(_listed('medicines').first, 'prev_medicine_box', reason: 'first on the Medicines tab');
      // Every new page is held for the paediatrician's read.
      final src = File('lib/screens/post_pregnancy/pp_health_content.dart').readAsStringSync();
      for (final id in ['ill_dengue', 'ill_bites', 'ill_anaemia', 'prev_vitamin_a', 'ill_febrile_seizure']) {
        final at = src.indexOf("id: '$id'");
        expect(src.substring(at - 600, at + 3000), contains('REQUIRED_REVIEW'), reason: id);
      }
      // Dengue: paracetamol only.
      final dengue = [for (final b in _page('ill_dengue').blocks) ..._strings(b)].join(' ');
      expect(dengue, contains('Never ibuprofen'));
    });

    test('H8: his poo, from First 40, on the tummy rail', () {
      final p = _page('tummy_poo');
      expect(p.toolSurfaceId, 'pp_page/parenting_first_40/f40_nappy_poop');
      expect(ppScreenForSurface(p.toolSurfaceId!), isNotNull);
    });

    test('§4: the new demo films have slots', () {
      List<String> slots(String id) => [for (final b in _page(id).blocks.whereType<PpVideoSlot>()) b.slotId];
      expect(slots('fever_reading'), contains('health/temp_underarm'));
      expect(slots('skin_which_rash'), contains('health/glass_test'));
      expect(slots('teeth_brushing'), contains('health/first_teeth_brushing'));
      expect(slots('health_choking_response'), contains('health/infant_cpr'));
      // Already filmed slots, so not a second one (§4's saline and medicine).
      expect(slots('cold_blocked_nose'), ['health/nose_saline']);
      expect(slots('prev_medicine'), ['health/giving_medicine']);
    });

    test('§5a: the thin pages are thin no more', () {
      int chars(String id) => [for (final b in _page(id).blocks) ..._strings(b)].join(' ').length;
      // Each page against its size in the plan's §5a table, before the build:
      // it gained what the table said it lacked.
      for (final (id, before) in [
        ('teeth_when', 783), ('teeth_dentist', 666), ('eyes_screens', 787), ('ill_thrush', 895),
        ('lt_coeliac', 901), ('ears_hearing', 913), ('nb_screening', 1049),
        ('nb_first_visits', 755), ('ill_uti', 1070), ('rec_surgery', 1074), ('prev_private_parts', 1121),
        ('prev_head_lice', 842), ('eyes_checks', 1139), ('lt_asthma', 1361),
      ]) {
        expect(chars(id), greaterThan(before + 100), reason: id);
      }
      // prev_nails_ears already had all three things §5a named (no buds, no
      // oil, cut while he sleeps): it gained the when-line and the clippers.
      // lt_weight had nothing named; it gained the India note.
      expect(_page('ill_teething_fever').blocks.whereType<PpCards>().single.heading, 'What teething does do');
      // A table page: it gains the late, gappy and chipped cards, not length.
      expect(_page('teeth_when').blocks.whereType<PpCards>().single.heading, 'Late, gappy, or chipped');
      expect(_page('ill_uti').blocks.whereType<PpCallout>().any((x) => x.title == 'The one line to remember'), isTrue);
      expect([for (final b in _page('prev_private_parts').blocks) ..._strings(b)].join(' '), contains('1098'));
    });

    test('§5c: giving medicine and the dose point at each other', () {
      expect(_page('prev_medicine').blocks.whereType<PpLink>().any((l) => l.pageId == 'fever_dosing'), isTrue);
      expect(_page('fever_dosing').blocks.whereType<PpLink>().any((l) => l.pageId == 'prev_medicine'), isTrue);
    });

    test('H-M2: a page written for her age leads an untagged one; a signal still wins', () {
      final lifted = ppRelevanceOrder(['every', 'hers'],
          situation: const PpSituation(ageMonths: 7, daysOld: 210), text: (x) => x, forHerAge: (x) => x == 'hers');
      expect(lifted, ['hers', 'every']);
      expect(kPpForHerAgeLift, lessThan(kPpSignalLift));
    });

    test('H1: the Vaccines card says when a dose is near, and only then', () {
      expect(tab('shots').dueLine, isNotNull);
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 35)));
      expect(VaxStore.instance.dueSoonLine, 'Due in 7 days', reason: 'the 6-week visit');
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 43)));
      expect(VaxStore.instance.dueSoonLine, isNull, reason: '10 weeks is 27 days away');
    });

    // What she sees first, at one age in each band (plan §6.6).
    for (final (label, days, railTitle, firstPage) in [
      ('3 weeks', 21, 'In the first three months', 'fever_under_3m'),
      ('7 months', 213, 'Common at 3 to 12 months', 'ill_teething_fever'),
      ('2 years', 730, 'The creche years', 'cold_common'),
      ('4 years', 1461, 'Common at 3 to 5 years', 'ill_throat'),
    ]) {
      testWidgets('first view at $label: Something\'s wrong, the checks, then his age\'s rail and the expert',
          (tester) async {
        ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(Duration(days: days)));
        tester.view.physicalSize = const Size(1200, 7000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
        await tester.pumpAndSettle();
        expect(find.descendant(of: find.byKey(pvDoorRailCardKey(0)), matching: find.text('Something\'s wrong')),
            findsOneWidget);
        expect(find.descendant(of: find.byKey(pvDoorRailCardKey(1)), matching: find.text('Get help now')),
            findsOneWidget);
        expect(find.text(railTitle), findsOneWidget);
        expect(find.byKey(const ValueKey('pp_door_age_rail')), findsOneWidget);
        final cards = [for (final x in tester.widgetList<PvShelfCard>(find.byType(PvShelfCard))) x.title];
        expect(cards.take(3), ['Fever check', 'Something suddenly different', _page(firstPage).title]);
        // Shown once: the rail's pages are skipped on the area rails below.
        expect(cards.where((x) => x == _page(firstPage).title), hasLength(1));
        expect(find.byKey(const ValueKey('pp_door_tab_expert')), findsOneWidget);
        expect(find.text('Not for an emergency. For that, Get help now.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Get help now: no expert, no consult card, and the class at the very end', (tester) async {
      _ageMonths(8);
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          MaterialApp(home: PpDoorScreen(door: door, initialTabId: 'help', onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_door_tab_expert')), findsNothing);
      expect(find.text('Talk to a paediatrician'), findsNothing);
      expect(find.text('Learn it on a calm day: baby first aid and CPR'), findsOneWidget);
      final footer = tester.getTopLeft(find.textContaining('believe yourself')).dy;
      final klass = tester.getTopLeft(find.text('Learn it on a calm day: baby first aid and CPR')).dy;
      expect(klass, greaterThan(footer), reason: 'after the footer, never above the rails');
    });

    testWidgets('a 5-week-old: the Vaccines card reads "Due in 7 days"', (tester) async {
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 35)));
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Due in 7 days'), findsOneWidget);
    });
  });
}

Iterable<String> _strings(PpBlock b) {
  if (b is PpIntro) return [b.text];
  if (b is PpArticle) return [?b.heading, ...b.paragraphs];
  if (b is PpSteps) return [?b.heading, for (final s in b.steps) ...[s.title, ?s.detail]];
  if (b is PpCards) return [?b.heading, for (final c in b.cards) ...[c.title, c.line]];
  if (b is PpTable) return [?b.heading, ...b.columns, for (final r in b.rows) ...r];
  if (b is PpChartCard) return [b.title, ?b.subtitle, ?b.note, for (final (l, v) in b.rows) ...[l, v]];
  if (b is PpCallout) return [?b.title, b.text];
  if (b is PpWhenLine) return [b.text];
  if (b is PpIndiaNote) return [b.text];
  if (b is PpLink) return [b.label, ?b.blurb];
  return const [];
}
