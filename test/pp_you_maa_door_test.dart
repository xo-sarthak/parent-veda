// =============================================================================
//  The You, Maa door, held against its brief
// -----------------------------------------------------------------------------
//  `You_Parenting_Maa_rebuild.pdf` as assertions. What fails silently here:
//  the frightening-thoughts route sliding down from the top; a tool or a
//  scored tracker appearing; the mother's path wired to the baby's checker;
//  the shop and circle links going dead again; Going back drawing an empty
//  card in the first six weeks; First 40 Days growing a second copy of the
//  bleeding page; weight-loss framing creeping into the food area.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_page_read.dart' show ppPageAsRead;
import 'package:parentveda/screens/post_pregnancy/pp_yoga_data.dart' show kYogaAfterCheckIds;
import 'package:parentveda/screens/reader/pv_read_offer.dart'
    show pvReadOwnConsultAfter, pvReadConsultNote;

PpSection get _you => ppSectionFor('parenting_maternal')!;
PpArea _area(String id) => _you.areas.firstWhere((a) => a.id == id);
PpPage _page(String id) => _you.pageById(id)!;
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

void _ageDays(int days) => ChildProfileStore.instance
    .debugSetDob(DateTime.now().subtract(Duration(days: days)));

Iterable<String> _surfaces(PpPage p) => [
      for (final b in p.blocks)
        if (b is PpLink && b.surfaceId != null) b.surfaceId!,
    ];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_maternal')!;

  group('the map', () {
    test('five tabs, every area placed once, the triage first, one unscored check-in', () {
      expect([for (final t in door.tabs) t.id], ['today', 'body', 'moving_eating', 'people', 'going_back']);
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect({...placed, ...door.hiddenAreaIds}, {for (final a in _you.areas) a.id});
      expect(placed, hasLength(placed.toSet().length));
      expect(door.tabs.first.areaIds.first, 'how_are_you');
      // The two-question check-in since 2026-10-07 (gap analysis P2),
      // unscored and unsaved (test/pp_mood_check_test.dart). Door 3
      // (2026-10-25) added the session for her week on Today (M1) and the
      // movement tools on Moving and eating (§3). Still no scored tracker.
      const tools = {
        'today': ['pp_mood_check', 'pp_maa_ten_minutes'],
        'moving_eating': ['pp_kegel', 'pp_yoga', 'pp_maa_can_i'],
      };
      for (final t in door.tabs) {
        expect(t.tools.map((x) => x.surfaceId), tools[t.id] ?? isEmpty,
            reason: '${t.id}: no scored tracker');
      }
      expect(_you.tools, isEmpty);
      expect(door.closing!.surfaceId, 'pp_experts/Maternal mental health');
    });

    test('the frightening-thoughts route is pinned at the very top and reaches the crisis path', () {
      expect(door.tabs[0].redFlagPageId, 'you_route_scary');
      expect(_listed('how_are_you').first, 'you_route_scary');
      expect(_surfaces(_page('you_route_scary')), contains('pp_crisis_path'));
      expect(ppScreenForSurface('pp_crisis_path'), isNotNull);
      expect(_listed('how_are_you'), hasLength(8), reason: 'eight routes');
    });

    test('the mother is never wired to the baby\'s checker', () {
      for (final p in _you.allPages) {
        expect(_surfaces(p), isNot(contains('pp_what_changed')), reason: p.id);
      }
      expect(door.tabs.every((t) => t.tools.every((x) => x.surfaceId != 'pp_what_changed')), isTrue);
    });

    test('the dead links are wired: the shop and the circle', () {
      final src = File('lib/screens/post_pregnancy/pp_you_maa_content.dart').readAsStringSync();
      final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      expect(live.contains('_shopSurface = null'), isFalse);
      expect(live.contains('_circleSurface = null'), isFalse);
      expect(ppScreenForSurface('pp_products'), isNotNull);
      expect(ppScreenForSurface('pp_community/mothers_4th_trimester'), isNotNull);
      final all = [for (final p in _you.allPages) ..._surfaces(p)];
      // Door 3 (M8): each shop link opens the one stocked shelf it names, never
      // the whole store. Was `pp_products` at least six times.
      final shop = [for (final s in all) if (s.startsWith('pp_products')) s];
      expect(shop, isNot(contains('pp_products')));
      expect(shop.length, greaterThanOrEqualTo(5));
      for (final s in shop) {
        expect(ppSurfaceUnavailable(s), isNull, reason: '$s: not stocked');
      }
      expect(all.where((s) => s == 'pp_community/mothers_4th_trimester').length, greaterThanOrEqualTo(3));
    });

    test('the dead card: Going back is tagged out of the first six weeks', () {
      expect(_area('back_to_work').bands, isNot(contains('pp_0_6w')));
      expect(_area('back_to_work').bands, isNotEmpty);
    });

    test('the two scaffolds are in the ledger', () {
      final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
      expect(_page('body_your_sleep').comingSoon, isFalse, reason: 'filled 2026-10-02');
      for (final id in ['body_thyroid']) {
        expect(_page(id).comingSoon, isFalse, reason: '$id filled 2026-10-02');
        expect(ledger.contains(id), isTrue, reason: '$id is a coming-soon card nobody has logged as owed');
      }
      expect(_listed('your_body'), containsAll(['body_your_sleep', 'body_thyroid']));
    });

    test('no weight-loss framing in the food area: never as a goal in a title or heading', () {
      // The body copy names the weight question in order to answer it honestly
      // once, and corrects a myth about it; what must never appear is weight
      // loss as the POINT of a page or a section. Titles and headings carry
      // the framing, so those are what is checked.
      final heads = <String>[];
      for (final a in ['feeding_yourself', 'healing_kitchen', 'movement']) {
        heads.add(_area(a).title);
        for (final p in _area(a).pages) {
          heads.add(p.title);
          for (final b in p.blocks) {
            if (b is PpArticle && b.heading != null) heads.add(b.heading!);
            if (b is PpSteps && b.heading != null) heads.add(b.heading!);
            if (b is PpCards && b.heading != null) heads.add(b.heading!);
          }
        }
      }
      final goal = RegExp(r'lose weight|weight loss|slim|get your body back', caseSensitive: false);
      for (final h in heads) {
        expect(goal.hasMatch(h), isFalse, reason: h);
      }
    });
  });

  group('single source: the one home for her recovery', () {
    test('First 40 Days\' acute pages and its breasts card are windows into You', () {
      final f40 = ppSectionFor('parenting_first_40')!;
      const windows = {
        'f40_lochia': 'pp_page/parenting_maternal/body_lochia',
        'f40_after_normal_delivery': 'pp_page/parenting_maternal/body_perineum',
        'f40_after_csection': 'pp_page/parenting_maternal/body_csection_early',
        'f40_breasts': 'pp_page/parenting_maternal/body_breasts',
        'f40_pregnant_again': 'pp_page/parenting_maternal/people_intimacy',
      };
      for (final e in windows.entries) {
        final p = f40.pageById(e.key)!;
        expect(p.toolSurfaceId, e.value, reason: e.key);
        expect(p.blocks, isEmpty, reason: '${e.key}: no second copy');
        expect(p.comingSoon, isFalse, reason: e.key);
        expect(ppScreenForSurface(e.value), isNotNull, reason: e.value);
      }
    });

    test('Feeding\'s mastitis flag links into the one breast-health page', () {
      final feeding = ppSectionFor('parenting_feeding')!.pageById('bf_mastitis')!;
      expect(_surfaces(feeding), contains('pp_page/parenting_maternal/body_breasts'));
    });
  });

  group('the age rule, on her timeline', () {
    test('the section auto-scopes on the postpartum bands', () {
      expect(_you.autoScope, isTrue);
      expect(_you.bandSet!.bands.first.id, 'pp_0_6w');
    });

    testWidgets('day 10: four tabs open, Going back locked; day 100: all five, no lock', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      _ageDays(10);
      await tester.pumpWidget(MaterialApp(home: PpDoorScreen(key: const ValueKey(10), door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('Read this one first'), findsOneWidget);
      expect(find.text('I am having thoughts that frighten me'), findsOneWidget);
      // Step 0 · S9: no lock; Going back says "For later" on its card.
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      expect(find.text('For later'), findsOneWidget, reason: 'Going back');
      // Door 3: every tab has its own expert row, so the closing card is not
      // drawn as well (one pitch per tab). Was the closing card (S3).
      expect(find.byKey(const ValueKey('pp_door_tab_expert')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsNothing);
      expect(find.textContaining('For you  '), findsOneWidget, reason: 'the hero speaks to her, not about the baby');
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey('locked'), door: door, onSurface: (_, _) {}, initialTabId: 'going_back')));
      await tester.pumpAndSettle();
      // Was the lock panel, 'This opens when you are 2 months in.'
      expect(find.byKey(const ValueKey('pp_door_later_line')), findsOneWidget);
      expect(find.text('Planning your return, starting about four weeks out'), findsWidgets, reason: 'a tab for later opens on its pages');

      _ageDays(100);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey(100), door: door, onSurface: (_, _) {}, initialTabId: 'going_back')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      expect(find.text('Planning your return, starting about four weeks out'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  DOOR 3: THE PLAN, HELD (`docs/pp-door-plans/03-you-maa.md`, built
  //  2026-10-25). What would fail silently: Today sliding off the first tab;
  //  a first-band page showing at week 7; a paid card above the free line on a
  //  mind page; a shop link to the whole store again; a link to the baby's
  //  recipes; a slot id in a fourth prefix.
  // ===========================================================================
  group('door 3: the plan, held', () {
    const b0 = 'pp_0_6w', b1 = 'pp_6w_3m', b2 = 'pp_3_6m', b3 = 'pp_6m';
    final live = File('lib/screens/post_pregnancy/pp_you_maa_content.dart')
        .readAsStringSync()
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    List<PpConsult> consults(PpPage p) => [for (final b in p.blocks) if (b is PpConsult) b];
    List<PpLink> links(PpPage p) => [for (final b in p.blocks) if (b is PpLink) b];
    tearDown(() => ChildProfileStore.instance.resetForTest());

    test('M1: Today leads every band, the rest follow her weeks', () {
      expect(door.tabOrder, {
        b0: ['today', 'body', 'moving_eating', 'people', 'going_back'],
        b1: ['today', 'moving_eating', 'body', 'people', 'going_back'],
        b2: ['today', 'moving_eating', 'going_back', 'body', 'people'],
        b3: ['today', 'going_back', 'moving_eating', 'body', 'people'],
      });
    });

    test('M1: the second Today card opens the session for her week', () {
      final today = door.tabs.first;
      expect(today.tools[1].label, '10 minutes for you today');
      expect(today.tools[1].surfaceId, kPpMaaTenMinutes);
      const want = {
        5: 'pp_page/parenting_maternal/pf_ex_breathing',
        60: 'pp_yoga/co_pelvic_rec',
        120: 'pp_yoga/co_deepcore_rec',
        250: 'pp_page/parenting_maternal/move_getting_stronger',
      };
      for (final e in want.entries) {
        _ageDays(e.key);
        expect(ppMaaTenMinutesTarget(), e.value, reason: 'day ${e.key}');
        expect(ppSurfaceUnavailable(kPpMaaTenMinutes), isNull, reason: 'day ${e.key}');
        expect(ppScreenForSurface(kPpMaaTenMinutes), isNotNull, reason: 'day ${e.key}');
      }
    });

    test('M3: Body has its own red flag, and each tab one red row', () {
      expect(door.tabs.firstWhere((t) => t.id == 'body').redFlagPageId, 'body_red_flags');
      expect(door.tabs.first.redFlagPageId, 'you_route_scary');
    });

    test('M3: the shelves hold real pages of their band, six at most', () {
      for (final tab in door.tabs.where((t) => t.ageRail.isNotEmpty)) {
        expect(tab.id, anyOf('body', 'moving_eating'));
        for (final MapEntry(key: band, value: rail) in tab.ageRail.entries) {
          expect(rail.pageIds.length, lessThanOrEqualTo(6), reason: '${tab.id} $band');
          for (final id in rail.pageIds) {
            final p = _you.pageById(id);
            expect(p, isNotNull, reason: id);
            expect(p!.inBand(band), isTrue, reason: '$id is not for $band');
            expect(p.linkedOnly, isFalse, reason: id);
          }
        }
        expect(tab.ageRail.keys.toSet(), {b0, b1, b2, b3}, reason: tab.id);
      }
      // The pelvic-floor exercises reach the tab she opens to move.
      final moving = door.tabs.firstWhere((t) => t.id == 'moving_eating');
      expect(moving.ageRail[b0]!.pageIds, contains('pf_ex_breathing'));
      expect(moving.ageRail[b1]!.pageIds, contains('pf_ex_kegels'));
    });

    test('§6: an expert on every tab, each to the right people', () {
      const want = {
        'today': 'pp_experts/Maternal mental health',
        'body': 'pp_experts/Gynecologist',
        'moving_eating': 'pp_experts/Physiotherapist',
        'people': 'pp_experts/Maternal mental health',
        'going_back': 'pp_experts/Lactation expert',
      };
      for (final t in door.tabs) {
        expect(t.expert?.surfaceId, want[t.id], reason: t.id);
      }
      for (final t in door.tabs.where((t) => t.expert!.surfaceId.endsWith('Maternal mental health'))) {
        expect(t.expert!.note, contains('14416'), reason: '${t.id}: the free line (M5)');
      }
    });

    test('§3: the movement tools, and the Can I card is now the tool', () {
      final moving = door.tabs.firstWhere((t) => t.id == 'moving_eating');
      expect(moving.tools.map((t) => t.label),
          ['Kegel Care', 'Classes for after birth', 'Can I eat or take this?']);
      expect(_page('cani_search').linkedOnly, isTrue);
    });

    test('§4: the band tags', () {
      expect(_page('body_hair_fall').bands, [b1, b2, b3]);
      expect(_page('body_wrist_neck').bands, [b1, b2, b3]);
      expect(_page('move_running').bands, [b2, b3]);
      expect(_page('people_intimacy').bands, [b0, b1, b2, b3]);
      expect(_page('you_route_stiff').bands, [b0, b1, b2, b3]);
      expect(_page('you_route_work').bands, [b1, b2, b3]);
      for (final p in _area('your_mind').pages) {
        expect(p.bands, [b0, b1, b2, b3], reason: '${p.id}: mind pages are for every band');
      }
      expect(
          [for (final b in _page('move_running').blocks) if (b is PpWhenLine) b.text].join(),
          contains('physio or doctor'));
      expect(links(_page('you_route_stiff')).map((l) => l.pageId), contains('move_first_weeks'));
    });

    test('M2: at week 7 no first-six-weeks page shows', () {
      _ageDays(7 * 7 + 1);
      expect(_you.bandSet!.active.id, b1);
      for (final p in _you.allPages.where((p) => p.bands.length == 1 && p.bands.first == b0)) {
        expect(p.inBand(_you.bandSet!.active.id), isFalse, reason: p.id);
      }
    });

    test('M4: every link lands; nothing opens the baby\'s recipes', () {
      for (final p in _you.allPages) {
        for (final l in links(p)) {
          expect(l.surfaceId ?? l.pageId, isNotNull, reason: '${p.id}: "${l.label}" goes nowhere');
          expect(l.surfaceId, isNot('pp_food'), reason: '${p.id}: pp_food is the baby\'s library');
          if (l.pageId case final id?) {
            expect(_you.pageById(id), isNotNull, reason: '${p.id} -> $id');
          }
          if (l.surfaceId case final s?) {
            expect(ppScreenForSurface(s) ?? ppSurfaceUnavailable(s), isNotNull, reason: s);
          }
        }
      }
      // Each route ends on a page, one tap (the scary one on the crisis path).
      for (final p in _area('how_are_you').pages.where((p) => p.id != 'you_route_scary')) {
        expect(links(p).any((l) => l.pageId != null), isTrue, reason: p.id);
      }
      expect(links(_page('move_after_csection')).map((l) => l.label),
          isNot(contains('The recovery programme, on demand')), reason: 'it did not exist');
    });

    test('M5: no paid card on the crisis pages; free help above every paid card on a mind page', () {
      for (final id in ['you_route_scary', 'mind_psychosis', 'circle_safe', 'people_safe_at_home']) {
        expect(consults(_page(id)), isEmpty, reason: id);
        expect(links(_page(id)).where((l) => l.surfaceId?.startsWith('pp_products') ?? false), isEmpty, reason: id);
      }
      final mind = [..._area('your_mind').pages, _page('people_partner_low')];
      for (final p in mind.where((p) => consults(p).isNotEmpty)) {
        final r = ppPageAsRead(_you, p);
        // The reader draws the page's consult under this section (Feeding D2).
        final at = pvReadOwnConsultAfter(r);
        final above = [for (final s in r.sections.take(at + 1)) s.callout?.body.en ?? ''].join(' ');
        expect(above, contains('14416'), reason: '${p.id}: the free line sits above the paid card');
        // At the foot, the crisis tile (where there is one) leads the consults.
        final foot = [for (final n in r.nextSteps) n.surfaceId];
        final crisis = foot.indexOf('pp_crisis_path');
        if (crisis >= 0) {
          expect(crisis, lessThan(foot.indexWhere((s) => s?.startsWith('pp_experts') ?? false)),
              reason: p.id);
        }
      }
    });

    test('M8: no shop link on a mind or crisis page; no unstocked promise left', () {
      for (final p in [..._area('your_mind').pages, ..._area('how_are_you').pages, _page('circle_safe')]) {
        expect(links(p).where((l) => l.surfaceId?.startsWith('pp_products') ?? false), isEmpty, reason: p.id);
      }
      // A shop link never promises what the store does not carry. (A sitz bath
      // as home care, in a page's own words, is not a promise to sell one.)
      final unstocked = RegExp(r'sitz|cooler bag|belt|binder|scar.*sheet', caseSensitive: false);
      for (final p in _you.allPages) {
        for (final l in links(p).where((l) => l.surfaceId?.startsWith('pp_products') ?? false)) {
          expect(unstocked.hasMatch('${l.label} ${l.blurb}'), isFalse, reason: '${p.id}: ${l.label}');
        }
      }
      expect(live, isNot(contains('_shopSurface,')), reason: 'no link to the whole store');
    });

    test('M6: a gynaecologist next to the worry, one pitch a page', () {
      for (final id in [
        'people_intimacy', 'body_when_normal', 'body_thyroid', 'body_contraception',
        'body_after_gdm', 'body_after_bp', 'body_screening', 'people_spacing',
      ]) {
        final c = consults(_page(id));
        expect(c, hasLength(1), reason: id);
        expect(c.single.surface, 'pp_experts/Gynecologist', reason: id);
      }
      expect(ppSurfaceUnavailable('pp_experts/Gynecologist'), isNull);
    });

    test('§6: classes next to the skill, none after-check on a first-band page', () {
      const want = {
        'move_first_weeks': 'pp_yoga/po_gentle_rec',
        'move_walking': 'pp_yoga/po_gentle_rec',
        'pf_ex_kegels': 'pp_yoga/co_pelvic_rec',
        'move_core_reconnect': 'pp_yoga/co_group',
        'body_diastasis': 'pp_yoga/co_1to1',
        'move_diastasis_training': 'pp_yoga/co_1to1',
        'move_after_csection': 'pp_yoga/po_1to1',
      };
      for (final e in want.entries) {
        expect(links(_page(e.key)).map((l) => l.surfaceId), contains(e.value), reason: e.key);
        expect(ppScreenForSurface(e.value), isNotNull, reason: e.value);
      }
      for (final p in _you.allPages.where((p) => p.bands.contains(b0) && p.bands.length == 1)) {
        for (final l in links(p)) {
          final id = l.surfaceId?.replaceFirst('pp_yoga/', '');
          expect(kYogaAfterCheckIds.contains(id), isFalse, reason: '${p.id}: $id is after-check');
        }
      }
    });

    test('S8: an after-check class before six weeks says so; after, it opens', () {
      _ageDays(10);
      expect(ppSurfaceUnavailable('pp_yoga/co_pelvic_rec'), contains('six-week check'));
      expect(ppSurfaceUnavailable('pp_yoga/po_gentle_rec'), isNull);
      _ageDays(60);
      expect(ppSurfaceUnavailable('pp_yoga/co_pelvic_rec'), isNull);
    });

    test('M7: the eight new pages, in place, tagged and reviewed', () {
      const placed = {
        'body_contraception': ('your_body', 'body_when_normal'),
        'body_after_gdm': ('your_body', 'body_thyroid'),
        'body_after_bp': ('your_body', 'body_after_gdm'),
        'body_screening': ('your_body', 'body_after_bp'),
        'people_partner_low': ('people_around_you', 'people_partner'),
        'people_safe_at_home': ('people_around_you', 'people_saying_no'),
        'people_spacing': ('people_around_you', 'people_intimacy'),
        'work_schemes': ('back_to_work', 'work_your_entitlement'),
      };
      final src = File('lib/screens/post_pregnancy/pp_you_maa_content.dart').readAsStringSync();
      for (final MapEntry(key: id, value: (area, after)) in placed.entries) {
        final ids = [for (final p in _area(area).pages) p.id];
        expect(ids.indexOf(id), ids.indexOf(after) + 1, reason: '$id after $after');
        final at = src.indexOf("id: '$id'");
        final next = src.indexOf('    PpPage(', at);
        expect(src.substring(at, next), contains('REQUIRED_REVIEW'), reason: id);
      }
      expect(_page('body_after_gdm').bands, [b1, b2, b3]);
      expect(_page('body_screening').bands, [b1, b2, b3]);
      expect(_page('people_spacing').bands, [b2, b3]);
      final safe = _page('people_safe_at_home');
      expect(consults(safe), isEmpty);
      expect(links(safe), isEmpty, reason: 'no product, no class, no consult');
      expect(links(_page('mind_relationship')).map((l) => l.pageId), contains('people_safe_at_home'));
      expect(links(_page('people_separated')).map((l) => l.pageId), contains('people_safe_at_home'));
      // Clinical pages end with a doctor box.
      for (final id in ['body_contraception', 'body_after_gdm', 'body_after_bp', 'body_screening', 'people_spacing']) {
        expect(_page(id).blocks.whereType<PpCallout>().any((c) => c.kind == PpCalloutKind.doctor),
            isTrue, reason: id);
      }
      // The after-BP consult comes after the go-now cards, with the safety line.
      final bp = _page('body_after_bp').blocks;
      expect(bp.indexWhere((b) => b is PpConsult), greaterThan(bp.indexWhere((b) => b is PpCards)));
      expect(pvReadConsultNote(ppPageAsRead(_you, _page('body_after_bp'))), contains('112'));
    });

    test('M9: one prefix for every film, the six demos added', () {
      final slots = [
        for (final p in _you.allPages)
          for (final b in p.blocks)
            if (b is PpVideoSlot) b.slotId,
      ];
      expect(slots.toSet(), hasLength(slots.length), reason: 'no slot twice');
      for (final s in slots) {
        expect(s, startsWith('you_maa/'), reason: s);
      }
      for (final id in [
        'move_first_weeks', 'move_diastasis_training', 'move_getting_stronger',
        'pf_ex_functional', 'body_back_posture', 'body_wrist_neck',
      ]) {
        expect(_page(id).blocks.whereType<PpVideoSlot>(), isNotEmpty, reason: id);
      }
    });

    test('§5: the mood check opens her crisis screen, not the pregnancy one', () {
      final src = File('lib/screens/post_pregnancy/pp_mood_check_screen.dart')
          .readAsStringSync()
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(src, contains('PpCrisisPathScreen()'));
      expect(src, isNot(contains('MmCrisisPathScreen')));
    });

    testWidgets('first view at 3 weeks, 7 weeks, 4 months and 8 months', (tester) async {
      tester.view.physicalSize = const Size(1200, 7000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      for (final days in [21, 50, 120, 245]) {
        _ageDays(days);
        await tester.pumpWidget(MaterialApp(
            home: PpDoorScreen(key: ValueKey(days), door: door, onSurface: (_, _) {})));
        await tester.pumpAndSettle();
        expect(find.text('I am having thoughts that frighten me'), findsOneWidget, reason: 'day $days');
        expect(find.text('10 minutes for you today'), findsOneWidget, reason: 'day $days');
        expect(find.byKey(const ValueKey('pp_door_tab_expert')), findsOneWidget, reason: 'day $days');
      }
      // Body at 3 weeks: her shelf, picked for her week.
      _ageDays(21);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(key: const ValueKey('body'), door: door, onSurface: (_, _) {}, initialTabId: 'body')));
      await tester.pumpAndSettle();
      expect(find.text('Right now for you'), findsOneWidget);
      expect(find.text('Picked for you, 3 weeks after the birth'), findsOneWidget);
      expect(find.text('When to call a doctor, not wait'), findsWidgets, reason: "Body's red flag");
    });
  });
}
