// =============================================================================
//  TTC shell, stores and wiring
// -----------------------------------------------------------------------------
//  Two jobs:
//
//  1. The five TTC destinations build and navigate between each other.
//  2. The stage is actually REACHABLE - the doorway on the pregnancy Home is
//     rendered and calls openTtc(). A module that compiles and is unreachable
//     is the failure mode this repo has hit before, so it is pinned here rather
//     than assumed.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_community_screen.dart';
import 'package:parentveda/screens/ttc/ttc_prepare_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  // The TTC stores are singletons that load from shared_preferences on first
  // construction. Without a mock the plugin channel throws into the test zone,
  // which the binding reports as a failure even though the store itself catches
  // it. Mocking also makes the persistence path real rather than a no-op.
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  group('the five destinations build', () {
    testWidgets('Today', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TtcTodayScreen()));
      await tester.pump();
      expect(find.text('Preparing Together'), findsOneWidget);
    });

    testWidgets('Prepare, Tools, Calendar and Community', (tester) async {
      for (final screen in const <Widget>[
        TtcPrepareScreen(),
        TtcToolsScreen(),
        TtcCalendarScreen(),
        TtcCommunityScreen(),
      ]) {
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$screen threw');
      }
    });
  });

  group('the shell is the same five destinations as pregnancy', () {
    testWidgets('all five tabs are on screen', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TtcTodayScreen()));
      await tester.pump();
      for (final label in ['Today', 'Prepare', 'Tools', 'Calendar', 'Community']) {
        expect(find.text(label), findsWidgets, reason: 'missing tab $label');
      }
    });

    testWidgets('tapping a tab actually navigates', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TtcTodayScreen()));
      await tester.pump();

      await tester.tap(find.text('Tools').last);
      await tester.pumpAndSettle();
      expect(find.byType(TtcToolsScreen), findsOneWidget);

      await tester.tap(find.text('Community').last);
      await tester.pumpAndSettle();
      expect(find.byType(TtcCommunityScreen), findsOneWidget);
    });
  });

  group('a feature is never hidden', () {
    testWidgets('with nothing logged, the rhythm card invites rather than vanishing',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TtcTodayScreen()));
      await tester.pump();
      final t = const TtcS(false);
      expect(find.text(t.logPeriodTitle), findsOneWidget);
      expect(find.text(t.logPeriodCta), findsOneWidget);
    });

    testWidgets('every Tools tile is listed from day one, used or not',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TtcToolsScreen()));
      await tester.pump();
      // Tile count, not tool count - Medication and Reports were folded into
      // the tiles they already opened. Coverage of the master document's tools
      // is asserted by name in ttc_tools_test.dart, which is the promise that
      // actually matters.
      expect(TtcToolsScreen.toolCount, 20);
    });

    testWidgets('all nine Prepare categories render', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TtcPrepareScreen()));
      await tester.pump();
      expect(TtcPrepareScreen.categories.length, 9);
    });

    testWidgets('Community holds a room for loss, not only for hope',
        (tester) async {
      final names =
          TtcCommunityScreen.rooms.map((r) => r.name.toLowerCase()).toList();
      expect(names.any((n) => n.contains('loss')), isTrue);
      // And the partner is a room of his own, not a footnote in hers.
      expect(names.any((n) => n.contains('partner')), isTrue);
    });
  });

  group('the doorway on the pregnancy Home', () {
    // The WIRING GATE: correct-but-unreachable code is the failure this repo
    // has actually hit. Pinned against the source so it cannot silently regress.
    final home =
        File('lib/screens/home_screen_b.dart').readAsStringSync();

    test('is rendered in the Home scroll', () {
      expect(home.contains('_ttcDoorway(context)'), isTrue,
          reason: 'the TTC doorway is defined but never placed in the list');
    });

    test('sits directly below the parenting doorway', () {
      final pp = home.indexOf('_postPregnancyDoorway(context),');
      final ttc = home.indexOf('_ttcDoorway(context),');
      expect(pp, greaterThan(-1));
      expect(ttc, greaterThan(pp),
          reason: 'the TTC door must sit below the parenting door');
    });

    test('opens the TTC stage', () {
      expect(home.contains('openTtc(context)'), isTrue);
    });

    test('syncs the app language into the TTC module', () {
      expect(home.contains('TtcLang.instance.hinglish'), isTrue,
          reason: 'TTC would otherwise always render in English');
    });
  });

  group('the auth stage selector is finally persisted', () {
    final auth =
        File('lib/screens/auth/auth_flow_screen.dart').readAsStringSync();

    test('the profile step writes the declared stage', () {
      expect(auth.contains('LifeStageStore.instance.setStageId(_stage)'), isTrue,
          reason: 'the Trying/Pregnant/New parent answer is being dropped again');
    });

    test('"trying" maps to the TTC stage', () {
      LifeStageStore.instance.setStageId('trying');
      expect(LifeStageStore.instance.stage, LifeStage.tryingToConceive);
      expect(LifeStageStore.instance.isTrying, isTrue);
    });

    test('the auth screen\'s own ids all map to a real stage', () {
      for (final entry in {
        'trying': LifeStage.tryingToConceive,
        'pregnant': LifeStage.pregnancy,
        'new': LifeStage.parenting,
      }.entries) {
        LifeStageStore.instance.resetForTest();
        LifeStageStore.instance.setStageId(entry.key);
        expect(LifeStageStore.instance.stage, entry.value,
            reason: 'auth id "${entry.key}"');
      }
    });

    test('an unknown or empty answer is ignored, never guessed at', () {
      LifeStageStore.instance.setStageId('');
      expect(LifeStageStore.instance.stage, isNull);
      LifeStageStore.instance.setStageId('something-else');
      expect(LifeStageStore.instance.stage, isNull);
    });

    test('re-declaring the same stage keeps the original entry date', () {
      final long = DateTime(2026, 1, 1);
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive, at: long);
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      expect(LifeStageStore.instance.enteredAt, long,
          reason: 'a months-old journey must not be reset by re-onboarding');
    });
  });

  group('CycleStore records only what was observed', () {
    test('a logged period becomes cycle day 1', () {
      final c = CycleStore.instance;
      c.logPeriodStart(DateTime.now());
      expect(c.lastPeriodStart, isNotNull);
      expect(TtcStore.instance.today.cycleDay, 1);
    });

    test('logging the same day twice is a no-op, not a duplicate', () {
      final c = CycleStore.instance;
      final d = DateTime(2026, 7, 1);
      c.logPeriodStart(d);
      c.logPeriodStart(d);
      expect(c.periodStarts.length, 1);
    });

    test('cycle lengths are derived from consecutive starts', () {
      final c = CycleStore.instance;
      c.logPeriodStart(DateTime(2026, 5, 1));
      c.logPeriodStart(DateTime(2026, 5, 29)); // 28
      c.logPeriodStart(DateTime(2026, 6, 26)); // 28
      expect(c.cycleLengths, [28, 28]);
      expect(c.completedCycles, 2);
    });

    test('an older cycle logged late still sorts correctly', () {
      final c = CycleStore.instance;
      c.logPeriodStart(DateTime(2026, 6, 26));
      c.logPeriodStart(DateTime(2026, 5, 29)); // remembered afterwards
      expect(c.cycleLengths, [28]);
      expect(c.lastPeriodStart, DateTime(2026, 6, 26));
    });

    test('an implausible gap is dropped rather than poisoning the average', () {
      final c = CycleStore.instance;
      c.logPeriodStart(DateTime(2025, 1, 1));
      c.logPeriodStart(DateTime(2026, 5, 1)); // ~485 days - a mis-tap
      c.logPeriodStart(DateTime(2026, 5, 29)); // 28
      expect(c.cycleLengths, [28]);
    });

    test('a mis-tap is undoable', () {
      final c = CycleStore.instance;
      final d = DateTime(2026, 7, 1);
      c.logPeriodStart(d);
      c.removePeriodStart(d);
      expect(c.periodStarts, isEmpty);
    });
  });

  group('TtcStore is the one place screens ask where they are', () {
    test('a positive test is recorded, and is undoable', () {
      final s = TtcStore.instance;
      expect(s.pregnancyConfirmed, isFalse);
      s.confirmPregnancy();
      expect(s.pregnancyConfirmed, isTrue);
      expect(s.today.chapter, TtcChapter.aNewBeginning);
      s.clearPregnancyConfirmation();
      expect(s.pregnancyConfirmed, isFalse);
    });

    test('the journey start falls back to when the stage was declared', () {
      final when = DateTime(2026, 3, 4);
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive, at: when);
      expect(TtcStore.instance.journeyStart, when);
    });

    test('every medical path can be named in both languages', () {
      for (final p in TtcPath.values) {
        expect(p.label(false), isNotEmpty);
        expect(p.label(true), isNotEmpty);
      }
    });
  });

  group('the module stays isolated', () {
    test('no TTC screen imports a pregnancy or parenting screen', () {
      final dir = Directory('lib/screens/ttc');
      final offenders = <String>[];
      for (final f in dir.listSync().whereType<File>()) {
        for (final line in f.readAsLinesSync()) {
          if (!line.startsWith('import ')) continue;
          final bad = line.contains('post_pregnancy/') ||
              line.contains('screens/father/') ||
              line.contains('home_screen_b') ||
              line.contains('week_flow_screen');
          if (bad) offenders.add('${f.path}: $line');
        }
      }
      expect(offenders, isEmpty,
          reason: 'TTC must import nothing from another stage\'s screens');
    });
  });
}
