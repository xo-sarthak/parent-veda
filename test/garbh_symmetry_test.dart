// Garbh Sanskar — the home and the door draw today's practice with ONE
// component (2026-09-23).
//
// The user: "the same section should not be different at two places in the
// same app." The home drew today's picks and opened the old pillar screens;
// the door drew four generic cards whose text never changed. Both now render
// `GarbhTodayPractice`, and this file is what keeps it that way:
//
//   · both call sites construct the component (a source check — the wiring
//     gate: correct-but-unreachable code is the failure this repo has hit);
//   · the component's tab ids are the door's tab ids;
//   · the home's "About" opens the door, not the old library;
//   · nothing keeps score — no streak on the component (the brief);
//   · a tick is hers for today, and it travels with her account.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_garbh.dart';
import 'package:parentveda/data/reads/read_images.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/garbh/garbh_today_practice.dart';
import 'package:parentveda/services/garbh_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('one component, two places', () {
    test('the home constructs it', () {
      final home = File('lib/screens/home_v3_screen.dart').readAsStringSync();
      expect(home, contains('body: GarbhTodayPractice('));
      expect(home, contains('onAbout: () => openGarbhDoor(context, pregnancy)'));
      // The old library is not a live destination from the home any more.
      final live = home
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(live, isNot(contains('GarbhScreen(controller')));
    });

    test("the door draws it as the Today tab's tool", () {
      final door = pvDoorPageFor('pregnancy_garbh')!;
      final today = door.groups.first;
      expect(today.id, kGarbhTabToday);
      expect(today.inlineSurfaceId, kGarbhSurfaceToday);
      final tool = pvDoorInlineToolFor(kGarbhSurfaceToday, PregnancyController());
      expect(tool, isA<GarbhTodayPractice>());
    });

    test("the component's destinations are the door's own tabs", () {
      expect(kGarbhBracketId, 'pregnancy_garbh');
      expect(kGarbhTabListenId, kGarbhTabListen);
      expect(kGarbhTabReadId, kGarbhTabRead);
      expect(kGarbhTabForYouId, kGarbhTabForYou);
      final ids = pvDoorPageFor(kGarbhBracketId)!.groups.map((g) => g.id).toSet();
      for (final item in garbhTodayItems(day: 140, week: 20)) {
        expect(ids, contains(item.tab), reason: '${item.name} names no tab');
      }
    });
  });

  group('the same shape as the finished doors', () {
    // The user, 2026-09-23: "make it consistent as the structural situation
    // as well, like the way we have our other doors like scans and tests."
    const finished = [
      'pregnancy_scans_tests',
      'pregnancy_symptoms',
      'pregnancy_nutrition',
      'pregnancy_complications',
      'pregnancy_garbh',
    ];

    test('every tab wears a drawn mark', () {
      for (final id in finished) {
        final door = pvDoorPageFor(id);
        expect(door, isNotNull, reason: id);
        for (final g in door!.groups) {
          expect(g.mark, isNotNull, reason: '$id / ${g.label}');
        }
      }
    });

    test('Garbh opens on its tool, like Symptoms and Nutrition open on theirs',
        () {
      for (final id in ['pregnancy_symptoms', 'pregnancy_nutrition', 'pregnancy_garbh']) {
        expect(pvDoorPageFor(id)!.groups.first.inlineSurfaceId, isNotNull,
            reason: id);
      }
    });
  });

  test('every Garbh tile has a picture key, and keys are unique', () {
    final door = pvDoorPageFor('pregnancy_garbh')!;
    final keys = <String>[];
    for (final t in door.allTiles) {
      final k = pvDoorGarbhPhotoKey(t);
      if (k == null) continue; // tab switches and credits
      expect(k, startsWith('garbh_'));
      keys.add(k);
    }
    expect(keys.toSet().length, keys.length);
    expect(keys, contains('garbh_listen_rain'));
    expect(keys, contains('garbh_play_word_search'));
    expect(keys, contains('garbh_read_piece_you_are_loved'));
  });

  group('what today holds', () {
    test('four pillars, in the brief order, each with a real pick', () {
      for (final day in [10, 100, 200, 270]) {
        final items = garbhTodayItems(day: day, week: ((day - 1) ~/ 7) + 1);
        expect(items.map((i) => i.pillarId),
            ['shravan', 'samvad', 'buddhi', 'kriya']);
        for (final i in items) {
          expect(i.today.trim(), isNotEmpty, reason: '${i.name} on day $day');
          expect(i.meta.trim(), isNotEmpty);
        }
      }
    });

    test('every pillar photograph is in the table and credited', () {
      for (final id in ['shravan', 'samvad', 'buddhi', 'kriya']) {
        expect(kReadImageUrls, contains('garbh_pillar_$id'));
        expect(kReadImageCredits, contains('garbh_pillar_$id'));
        expect(readImageFor('garbh_pillar_$id'), isNotNull);
      }
    });

    test('nothing keeps score — no streak in the component', () {
      final src =
          File('lib/screens/garbh/garbh_today_practice.dart').readAsStringSync();
      final code = src
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n')
          .toLowerCase();
      expect(code, isNot(contains('streak')));
    });
  });

  group('a tick is hers', () {
    test("today's ticks round-trip through her account", () async {
      final s = GarbhStore.instance;
      await s.init();
      s.markDone('samvad');
      final blob = s.cloudData() as Map;
      expect(blob['done'], contains('samvad'));
      expect(blob['doneDate'], isNotEmpty);

      s.undoDone('samvad');
      expect(s.isDone('samvad'), isFalse);
      s.applyCloudData(blob);
      expect(s.isDone('samvad'), isTrue);
      s.undoDone('samvad');
    });

    testWidgets('tapping the circle ticks and unticks', (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await GarbhStore.instance.init();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GarbhTodayPractice(
                pregnancy: PregnancyController(), day: 140, week: 20),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byKey(const ValueKey('garbh_today_kriya')), findsOneWidget);
      expect(GarbhStore.instance.isDone('kriya'), isFalse);
      await tester.tap(find.bySemanticsLabel('Mark Kriya done today'));
      await tester.pump();
      expect(GarbhStore.instance.isDone('kriya'), isTrue);
      await tester.tap(find.bySemanticsLabel('Kriya done today'));
      await tester.pump();
      expect(GarbhStore.instance.isDone('kriya'), isFalse);
    });
  });
}
