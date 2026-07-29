// =============================================================================
//  TTC Tools - the trackers, the cycle tools, supplements and the test library
// -----------------------------------------------------------------------------
//  The wiring assertions here matter more than usual: this hub is twenty-two
//  tiles, and a tile that compiles but opens nothing is exactly the failure
//  this repo has hit before. So every tile is proven to either open a real
//  screen or to declare itself unbuilt - it cannot do neither.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_supplements_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tests_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tracker_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart' show TtcAuthor;
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';
import 'package:parentveda/ttc/ttc_tests_data.dart';
import 'package:parentveda/ttc/ttc_trackers_data.dart';

Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  // A UniqueKey per pump forces a brand-new element tree. Without it Flutter
  // reuses the previous MaterialApp element - and with it the Navigator's route
  // stack - so a screen pushed by the previous iteration would still be on top
  // and the next tile would be hidden behind it.
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcSupplementsStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('the hub lists every tool from day one', () {
    test('every tool the master document names is still findable', () {
      // This used to assert `toolCount == 22`, which counted TILES when the
      // promise is about TOOLS. Medication and Reports were separate tiles that
      // opened the Supplements and Records screens - deliberately, so there is
      // one list rather than two that disagree, but nothing on screen said so
      // and it read as broken routing. They are now named inside the tiles they
      // always opened.
      //
      // Counting tiles would have blocked that merge; what actually matters is
      // that no capability stopped being findable by the word she looks for.
      final names = [
        for (final g in ttcToolGroups)
          for (final t in g.tools) '${t.nameEn} ${t.nameHi}'
      ].join(' ').toLowerCase();

      for (final capability in [
        'cycle', 'ovulation', 'fertility', 'symptom', 'weight', 'sleep',
        'partner', 'mood', 'stress', 'lifestyle', 'journal',
        'supplement', 'medication', 'test', 'report', 'record', 'appointment',
        'movement', 'nutrition', 'journey', 'can i', 'worth knowing',
      ]) {
        expect(names, contains(capability),
            reason: '"$capability" is no longer findable in the hub');
      }
    });

    test('and every tile still leads somewhere distinct enough to matter', () {
      // Was 20 after Medication and Reports were folded into the tiles they
      // already opened. Medication has since been UNfolded - not as a
      // reversal, but because it finally has its own destination: a real
      // record with a name, a dose, a schedule and reminders, instead of a
      // curated supplement list it could never hold a prescription in.
      //
      // The rule the number is standing in for has not changed: a tile must
      // lead somewhere that is genuinely its own. Splitting when that becomes
      // true is the same rule as merging when it is not.
      expect(TtcToolsScreen.toolCount, 21);
    });

    test('supplements and medication are not the same destination', () {
      final ids = [
        for (final g in ttcToolGroups)
          for (final t in g.tools) t.id
      ];
      expect(ids, contains('supplements'));
      expect(ids, contains('medication'));
    });

    test('every tile has a unique id', () {
      final ids = [
        for (final g in ttcToolGroups)
          for (final t in g.tools) t.id
      ];
      expect(ids.toSet().length, ids.length);
    });

    test('every tile is named in both languages', () {
      for (final g in ttcToolGroups) {
        expect(g.title(true), isNotEmpty);
        expect(g.title(false), isNotEmpty);
        for (final t in g.tools) {
          expect(t.name(true), isNotEmpty, reason: t.id);
          expect(t.name(false), isNotEmpty, reason: t.id);
        }
      }
    });

    testWidgets('the grid renders all twenty-two', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      for (final g in ttcToolGroups) {
        for (final t in g.tools) {
          expect(find.text(t.name(false)), findsWidgets, reason: t.id);
        }
      }
    });

    testWidgets('every tile is built - nothing says "Soon" any more',
        (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      final unbuilt = [
        for (final g in ttcToolGroups)
          for (final t in g.tools)
            if (!t.built) t.id
      ];
      expect(unbuilt, isEmpty,
          reason: 'these tiles still declare themselves unbuilt: $unbuilt');
      // The marker only ever renders for an unbuilt tile, so with none left it
      // must be absent. If a future tile ships as `built: false`, the assertion
      // above names it and this one catches a missing marker.
      expect(find.text('Soon'), findsNothing);
    });
  });

  // ===========================================================================
  group('every built tile actually opens something', () {
    testWidgets('tapping each built tile pushes a route', (tester) async {
      for (final g in ttcToolGroups) {
        for (final tool in g.tools) {
          if (!tool.built) continue;
          await pumpTall(tester, const TtcToolsScreen());
          expect(find.text(tool.name(false)), findsWidgets,
              reason: 'tile "${tool.id}" is not on the hub at all');
          await tester.tap(find.text(tool.name(false)).first);
          await tester.pumpAndSettle();
          // Something other than the hub must now be on screen.
          expect(find.byType(TtcToolsScreen), findsNothing,
              reason: '"${tool.id}" is marked built but opened nothing');
        }
      }
    });
  });

  // ===========================================================================
  group('the tracker definitions', () {
    test('every tracker is bilingual and explains why it exists', () {
      for (final t in ttcTrackers) {
        for (final hi in [true, false]) {
          expect(t.title(hi), isNotEmpty, reason: t.id);
          expect(t.subtitle(hi), isNotEmpty, reason: t.id);
          expect(t.why(hi), isNotEmpty, reason: t.id);
        }
        expect(t.why(true), isNot(t.why(false)), reason: t.id);
      }
    });

    test('every field is bilingual, and every scale is anchored in words', () {
      for (final t in ttcTrackers) {
        expect(t.fields, isNotEmpty, reason: t.id);
        for (final f in t.fields) {
          expect(f.label(true), isNotEmpty, reason: '${t.id}/${f.id}');
          expect(f.label(false), isNotEmpty, reason: '${t.id}/${f.id}');
          if (f.kind != TtcFieldKind.number) {
            expect(f.choices(true).length, f.choices(false).length,
                reason: '${t.id}/${f.id} has different options per language');
            expect(f.choices(false), isNotEmpty,
                reason: '${t.id}/${f.id} has no options');
          }
        }
      }
    });

    test('a number field always carries a unit - "72" alone means nothing', () {
      for (final t in ttcTrackers) {
        for (final f in t.fields) {
          if (f.kind == TtcFieldKind.number) {
            expect(f.unit, isNotNull, reason: '${t.id}/${f.id}');
          }
        }
      }
    });

    test('no tracker defines a target or a goal', () {
      // Guarding the rule structurally: TtcField has no target field at all,
      // so this asserts the copy does not smuggle one in.
      for (final t in ttcTrackers) {
        final copy = '${t.why(false)} ${t.subtitle(false)}'.toLowerCase();
        for (final word in ['target', 'goal', 'streak', 'score']) {
          // "no goal here to beat" is allowed; a goal being SET is not.
          if (copy.contains(word)) {
            expect(
              copy.contains('no $word') ||
                  copy.contains('not a $word') ||
                  copy.contains('$word here to beat'),
              isTrue,
              reason: '${t.id} mentions "$word" approvingly',
            );
          }
        }
      }
    });

    test('the partner tracker exists and is marked as his', () {
      final p = ttcTrackerById('partner_health');
      expect(p, isNotNull);
      expect(p!.forPartner, isTrue);
    });
  });

  // ===========================================================================
  group('the log store', () {
    test('logging the same field twice in a day overwrites, never appends', () {
      final s = TtcLogStore.instance;
      s.log('weight', 'kg', 61);
      s.log('weight', 'kg', 62);
      expect(s.history('weight', 'kg').length, 1);
      expect(s.valueFor('weight', 'kg')!.value, 62);
    });

    test('different days are separate entries', () {
      final s = TtcLogStore.instance;
      s.log('mood', 'mood', 3, on: DateTime(2026, 7, 1));
      s.log('mood', 'mood', 1, on: DateTime(2026, 7, 2));
      expect(s.history('mood', 'mood').length, 2);
    });

    test('history comes back oldest first', () {
      final s = TtcLogStore.instance;
      s.log('mood', 'mood', 1, on: DateTime(2026, 7, 2));
      s.log('mood', 'mood', 3, on: DateTime(2026, 7, 1));
      expect(s.history('mood', 'mood').first.value, 3);
      expect(s.latest('mood', 'mood')!.value, 1);
    });

    test('clearing removes just that day', () {
      final s = TtcLogStore.instance;
      s.log('sleep', 'hours', 7, on: DateTime(2026, 7, 1));
      s.log('sleep', 'hours', 8);
      s.clear('sleep', 'hours');
      expect(s.valueFor('sleep', 'hours'), isNull);
      expect(s.history('sleep', 'hours').length, 1);
    });

    test('days logged are newest first and deduplicated across fields', () {
      final s = TtcLogStore.instance;
      s.log('sleep', 'hours', 7, on: DateTime(2026, 7, 1));
      s.log('sleep', 'quality', 3, on: DateTime(2026, 7, 1));
      s.log('sleep', 'hours', 8, on: DateTime(2026, 7, 3));
      expect(s.daysLogged('sleep'), ['2026-07-03', '2026-07-01']);
    });

    test('an average describes only when there is something to describe', () {
      final s = TtcLogStore.instance;
      expect(s.recentAverage('sleep', 'hours'), isNull);
      s.log('sleep', 'hours', 6);
      s.log('sleep', 'hours', 8, on: DateTime.now().subtract(const Duration(days: 1)));
      expect(s.recentAverage('sleep', 'hours'), 7);
    });
  });

  // ===========================================================================
  group('the tracker screen', () {
    testWidgets('every tracker builds', (tester) async {
      for (final t in ttcTrackers) {
        await pumpTall(tester, TtcTrackerScreen(tracker: t));
        expect(tester.takeException(), isNull, reason: '${t.id} threw');
      }
    });

    testWidgets('why it exists is shown before anything is asked for',
        (tester) async {
      final tracker = ttcTrackerById('mood')!;
      await pumpTall(tester, TtcTrackerScreen(tracker: tracker));
      expect(find.text(tracker.why(false)), findsOneWidget);
    });

    testWidgets('choosing an option records it', (tester) async {
      final tracker = ttcTrackerById('mood')!;
      await pumpTall(tester, TtcTrackerScreen(tracker: tracker));
      await tester.tap(find.text('Okay').first);
      await tester.pump();
      expect(TtcLogStore.instance.valueFor('mood', 'mood')!.value, 2);
    });

    testWidgets('an empty tracker invites rather than showing a blank list',
        (tester) async {
      await pumpTall(tester, TtcTrackerScreen(tracker: ttcTrackerById('sleep')!));
      expect(find.text(const TtcS(false).trackerEmptyTitle), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the cycle tools agree with the engine', () {
    testWidgets('all three build with no data at all', (tester) async {
      for (final screen in const <Widget>[
        TtcCycleScreen(),
        TtcOvulationScreen(),
        TtcFertilityWindowScreen(),
      ]) {
        await pumpTall(tester, screen);
        expect(tester.takeException(), isNull, reason: '$screen threw');
      }
    });

    testWidgets('the cycle screen invites a first period', (tester) async {
      await pumpTall(tester, const TtcCycleScreen());
      expect(find.text(const TtcS(false).logPeriodCta), findsWidgets);
    });

    testWidgets('with cycles logged it shows the average and range',
        (tester) async {
      CycleStore.instance
        ..logPeriodStart(DateTime(2026, 5, 1))
        ..logPeriodStart(DateTime(2026, 5, 29))
        ..logPeriodStart(DateTime(2026, 6, 28));
      await pumpTall(tester, const TtcCycleScreen());
      // 28 and 30 → average 29, range 28-30.
      expect(find.text('29 days'), findsOneWidget);
      expect(find.text('28–30 days'), findsOneWidget);
    });

    testWidgets('a logged LH positive is reflected back', (tester) async {
      CycleStore.instance.logPeriodStart(
          DateTime.now().subtract(const Duration(days: 15))); // day 16
      CycleStore.instance.logLhPositive(16);
      await pumpTall(tester, const TtcOvulationScreen());
      // The engine puts ovulation the day after the surge.
      expect(find.text(const TtcS(false).estimatedOvulation(17)), findsOneWidget);
    });

    testWidgets('the fertility window renders a graded cycle', (tester) async {
      CycleStore.instance
        ..logPeriodStart(DateTime(2026, 5, 1))
        ..logPeriodStart(DateTime(2026, 5, 29))
        ..logPeriodStart(
            DateTime.now().subtract(const Duration(days: 10))); // day 11
      await pumpTall(tester, const TtcFertilityWindowScreen());
      expect(find.text('Ovulation'), findsOneWidget);
      expect(find.text('Peak'), findsWidgets);
    });
  });

  // ===========================================================================
  group('supplements record without grading', () {
    test('adding, ticking and removing', () {
      final s = TtcSupplementsStore.instance;
      final item = s.add('Folic acid', dose: '400 mcg daily');
      expect(s.items.length, 1);
      expect(s.isTaken(item.id), isFalse);
      s.toggleTaken(item.id);
      expect(s.isTaken(item.id), isTrue);
      expect(s.takenToday(), 1);
      s.remove(item.id);
      expect(s.items, isEmpty);
    });

    test('removing a supplement takes its taken-history with it', () {
      final s = TtcSupplementsStore.instance;
      final item = s.add('Iron');
      s.toggleTaken(item.id);
      s.remove(item.id);
      final again = s.add('Iron');
      // A new id, so the old ticks cannot leak onto it.
      expect(s.isTaken(again.id), isFalse);
    });

    test('his supplements are held separately from hers', () {
      final s = TtcSupplementsStore.instance;
      s.add('Folic acid');
      s.add('Zinc', author: TtcAuthor.partner);
      expect(s.forAuthor(TtcAuthor.me).length, 1);
      expect(s.forAuthor(TtcAuthor.partner).length, 1);
    });

    test('the suggested list is bilingual and includes one for him', () {
      expect(ttcSuggestedSupplements.any((e) => e.forPartner), isTrue);
      for (final s in ttcSuggestedSupplements) {
        expect(s.note(true), isNotEmpty, reason: s.name);
        expect(s.note(false), isNotEmpty, reason: s.name);
      }
    });

    testWidgets('the screen invites when empty, and adds from a suggestion',
        (tester) async {
      await pumpTall(tester, const TtcSupplementsScreen());
      expect(find.text(const TtcS(false).supplementsEmptyTitle), findsOneWidget);
      await tester.tap(find.text('Folic acid').first);
      await tester.pump();
      expect(TtcSupplementsStore.instance.items.length, 1);
    });
  });

  // ===========================================================================
  group('the medical test library', () {
    test('his tests are listed, not footnoted', () {
      expect(ttcTestsFor(him: true), isNotEmpty);
      expect(ttcTestById('semen'), isNotNull);
      expect(ttcTestById('semen')!.forHim, isTrue);
    });

    test('every test says when in the cycle to take it', () {
      // Getting this wrong is the most common reason a fertility test is
      // repeated, so it is required rather than optional.
      for (final t in ttcTests) {
        expect(t.when(false), isNotEmpty, reason: t.id);
        expect(t.when(true), isNotEmpty, reason: t.id);
      }
    });

    test('every test carries a real Indian price range', () {
      for (final t in ttcTests) {
        expect(t.cost(false), contains('₹'), reason: t.id);
      }
    });

    test('every test explains how to read the result', () {
      for (final t in ttcTests) {
        expect(t.reading(false), isNotEmpty, reason: t.id);
        expect(t.reading(true), isNotEmpty, reason: t.id);
      }
    });

    test('AMH is explicitly talked down from being a fertility score', () {
      final amh = ttcTestById('amh')!;
      expect(amh.reading(false).toLowerCase(), contains('quality'));

      // The card-level line is the one an anxious person reads first, and it
      // used to say "how many eggs remain - the size of the reserve" while its
      // own correction sat two fields below. The assertion here used to be
      // `contains('estimate')`, which was a proxy for hedging and happened to
      // pin that exact sentence in place.
      //
      // What actually matters is that the first line does not frame AMH as a
      // countdown of what is left, so that is what is asserted now.
      final what = amh.what(false).toLowerCase();
      expect(what, isNot(contains('how many eggs')));
      expect(what, isNot(contains('remain')));
      expect(what, contains('respond'),
          reason: 'AMH predicts ovarian response, and should say so first');
    });

    testWidgets('the screen builds and both segments have tests',
        (tester) async {
      await pumpTall(tester, const TtcTestsScreen());
      expect(find.text('AMH'), findsOneWidget);
      await tester.tap(find.text(const TtcS(false).testForHim));
      await tester.pumpAndSettle();
      expect(find.text('Semen analysis'), findsOneWidget);
    });
  });
}
