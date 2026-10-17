// =============================================================================
//  The one Yoga & fitness hub (2026-10-16): catalogue, wiring, cycle phase
// -----------------------------------------------------------------------------
//  The hub replaced a retired month-tab screen that the Move door had wired
//  back in, and a marketplace reached only from Prepare. This holds the parts a
//  device walk would not catch: every way in opens the hub, the retired screen
//  stays unpushed, the catalogue folds every source with a stage label, the
//  door's count cannot drift from the list, and TTC's practice of the day
//  follows the cycle phase.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/move/pv_move_catalog.dart';
import 'package:parentveda/data/garbh_data.dart' show garbhMonth;
import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tools_tab.dart';
import 'package:parentveda/screens/v2/v3_film_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_yoga_data.dart';
import 'package:parentveda/ttc/ttc_mind_today.dart';
import 'package:parentveda/ttc/ttc_phase.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';

String _src(String p) => File(p).readAsStringSync();

/// The source with whole-line `//` comments removed, so a "kept for revert"
/// line does not count as a call.
String _live(String p) => _src(p)
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  // The phone walk of 2026-10-17: a session opened the old Prepare player,
  // More kept a redundant pill into old Prepare, and Kegel Care was missing
  // from Parenting's Tools.
  group('walk fixes', () {
    test('a session opens the house film page, not the old player', () {
      final hub = _live('lib/screens/post_pregnancy/yoga_home_screen.dart');
      expect(hub, contains('V3FilmScreen('));
      expect(hub, isNot(contains('PrepareVideoScreen(')));
    });

    test("a session's film spans exactly its pregnancy month", () {
      for (final s in kYogaSessions) {
        final f = pvSessionFilm(s);
        expect(f.id, s.id);
        expect(garbhMonth(f.weekStart), s.month, reason: s.id);
        expect(garbhMonth(f.weekEnd), s.month, reason: s.id);
        if (f.weekEnd < 40) {
          expect(garbhMonth(f.weekEnd + 1), isNot(s.month), reason: s.id);
        }
      }
    });

    testWidgets('the film page opens with no pregnancy, and offers no save',
        (t) async {
      final f = pvSessionFilm(kYogaSessions.first);
      await t.pumpWidget(MaterialApp(
          home: V3FilmScreen(
              video: f, week: f.weekStart, pregnancy: null, canSave: false)));
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull);
      expect(find.text(f.title.en), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing);
    });

    test('Parenting Tools lists Kegel Care and Yoga & fitness', () {
      final ids = [
        for (final g in ppToolGroups())
          for (final t in g.tools) t.surfaceId,
      ];
      expect(ids, containsAll(['pp_kegel', 'pp_yoga']));
    });

    test("Pregnancy More has no 'All programmes and sessions' pill", () {
      final more = _live('lib/screens/pregnancy/preg_more_screen.dart');
      expect(more, isNot(contains("ValueKey('preg_more_all_programmes')")));
      expect(more, isNot(contains('PrepareHubScreen(')));
    });
  });

  group('wiring', () {
    test('every way in opens the hub', () {
      for (final f in [
        'lib/screens/doors/pv_door_router.dart',
        'lib/services/surface_router.dart',
        'lib/screens/post_pregnancy/pp_surface_router.dart',
        'lib/screens/prepare/prepare_hub_screen.dart',
        'lib/screens/post_pregnancy/explore_drawer.dart',
        'lib/screens/post_pregnancy/my_bookings_screen.dart',
        'lib/screens/ttc/ttc_more_tab.dart',
      ]) {
        expect(_live(f), contains('YogaHomeScreen('), reason: f);
      }
    });

    test('the retired month-tab screen is pushed from nowhere', () {
      final hits = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.replaceAll('\\', '/').endsWith('prepare/prenatal_yoga_screen.dart'))
          .where((f) => _live(f.path).contains('PrenatalYogaScreen('))
          .map((f) => f.path)
          .toList();
      expect(hits, isEmpty);
    });

    test("the door's yoga count is read from the list, never typed", () {
      final door = _live('lib/data/doors/pv_door_move.dart');
      expect(door, contains('kYogaSessions.length'));
      expect(door, isNot(contains('22 follow-along')));
    });
  });

  group('catalogue', () {
    final all = pvMoveCatalog();

    test('folds every source once', () {
      final practices = ttcPracticesOfKind(TtcPracticeKind.move).length;
      expect(all.length, kYogaClasses.length + kYogaSessions.length + 1 + practices);
      expect(all.map((i) => i.id).toSet().length, all.length, reason: 'ids are unique');
    });

    test('every item sits on a real chip', () {
      final chips = kPvMoveChips.map((c) => c.$1).toSet()..remove('all');
      for (final i in all) {
        expect(chips, contains(i.chip), reason: i.id);
      }
    });

    test('stage labels: sessions are pregnancy, post-IVF and practices fertility, postnatal after birth', () {
      for (final i in all) {
        if (i.kind == PvMoveKind.session) expect(i.stageLabel, 'Pregnancy');
        if (i.kind == PvMoveKind.practice) expect(i.stageLabel, 'Fertility');
        if (i.yogaClass?.category == 'postnatal') expect(i.stageLabel, 'After birth');
      }
    });

    test('the six-week ids are real classes, labelled, never removed', () {
      for (final id in kYogaAfterCheckIds) {
        expect(kYogaClasses.any((c) => c.id == id), isTrue, reason: id);
        expect(all.firstWhere((i) => i.id == id).afterCheck, isTrue, reason: id);
      }
    });

    test('filters narrow and the empty filter shows everything', () {
      expect(pvMoveFiltered().length, all.length);
      final live = pvMoveFiltered(modes: {YogaMode.liveOneToOne});
      expect(live, isNotEmpty);
      expect(live.every((i) => i.mode == YogaMode.liveOneToOne), isTrue);
      expect(pvMoveFiltered(chip: 'prenatal').every((i) => i.chip == 'prenatal'), isTrue);
    });
  });

  group('TTC practice follows the cycle', () {
    final start = DateTime(2026, 10, 1);

    test('a phase only ever gets a practice tagged for it', () {
      for (final phase in TtcDayPhase.values.where((p) => p != TtcDayPhase.any)) {
        for (var d = 0; d < 14; d++) {
          final p = ttcPracticeOfTheDay(TtcPracticeKind.move,
              on: start.add(Duration(days: d)), phase: phase);
          expect(p.phases, contains(phase), reason: '${phase.name} day $d: ${p.id}');
        }
      }
    });

    test('any, or no phase, is the old rotation exactly', () {
      for (var d = 0; d < 14; d++) {
        final on = start.add(Duration(days: d));
        expect(ttcPracticeOfTheDay(TtcPracticeKind.move, on: on, phase: TtcDayPhase.any).id,
            ttcPracticeOfTheDay(TtcPracticeKind.move, on: on).id);
      }
    });

    test('the two partners never land on the same card', () {
      for (final phase in TtcDayPhase.values) {
        for (var d = 0; d < 14; d++) {
          final on = start.add(Duration(days: d));
          final hers = ttcPracticeOfTheDay(TtcPracticeKind.move, on: on, phase: phase);
          final his = ttcPracticeOfTheDay(TtcPracticeKind.move,
              on: on, offset: kTtcPartnerOffset, phase: phase);
          expect(his.id, isNot(hers.id), reason: '${phase.name} day $d');
        }
      }
    });

    test('the breath library is untouched by phases', () {
      for (final p in ttcPracticesOfKind(TtcPracticeKind.breathe)) {
        expect(p.phases, {TtcDayPhase.any}, reason: p.id);
      }
    });
  });
}
