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
import 'package:parentveda/ttc/ttc_reads_data.dart';
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
      // ⚠️ DESCRIPTIONS COUNT NOW, AND THE REASON IS THE HABIT MERGE — 2026-09-04.
      //
      // Sleep, Stress, Lifestyle and Movement had a tile each. They are fields
      // inside one `habits` tracker now, and one tile cannot be called all four
      // things — so searching titles alone said four capabilities had vanished
      // when none had.
      //
      // The rule this test protects is "no capability stops being findable by
      // the word she looks for". A tile's description is where she looks
      // second and it is on the same screen, so it satisfies the rule. What
      // would NOT satisfy it is a capability named nowhere in the hub at all.
      final names = [
        for (final g in ttcToolGroups)
          for (final t in g.tools)
            '${t.nameEn} ${t.nameHi} ${t.descEn} ${t.descHi}'
      ].join(' ').toLowerCase();

      for (final capability in [
        'cycle', 'ovulation', 'fertility', 'symptom', 'weight', 'sleep',
        'partner', 'mood', 'stress', 'lifestyle', 'journal',
        'supplement', 'medication', 'test', 'report', 'record', 'appointment',
        'movement', 'nutrition', 'journey', 'can i',
        // 2026-09-27: the product guide is named "Products" now. Kept for
        // revert: 'worth knowing',
        // 2026-09-28 (launch sanity T1): the Products row left the hub; it
        // opened the store the bar's Products tab already opens. Kept for
        // revert: 'products',
        // The five checks the level-map checklist added. Each was reachable
        // only from inside one journey step before this, which is the
        // contextual entrance, not an index. A woman told "you might have
        // PCOS" opens Tools and looks for the word.
        // 2026-09-28 (T1/T2/D18): BMI is found on the Weight row, and the
        // specialist check goes by its one name. Kept for revert:
        // 'pcos', 'weight and fertility', 'specialist', 'vaccination',
        'pcos', 'bmi', 'fertility help', 'specialist', 'vaccination',
        'checklist',
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
      //
      // 21 -> 26: the PCOS check, the BMI reading, the "see a specialist?"
      // self-check, Vaccinations and the pre-pregnancy checklist. Each has its
      // own screen; none of them is a second door onto a screen already listed
      // here. `Weight and fertility` sits beside `Weight` on purpose - one
      // logs a series, one reads a single number against South Asian cut-offs.
      //
      // ⚠️ 26 -> 23 ON 2026-09-04. Sleep, Stress, Lifestyle and Movement became
      // one `habits` tracker, so four tiles became one. Four fewer tiles, one
      // more, and not a single capability lost — all four are named on the new
      // tile and the findability test above asserts it.
      // ⚠️ 23 -> 24 ON 2026-09-17. Courses left the V3 bar (slot 2 is the
      // unified store) and became the first tile of Plan and learn.
      // ⚠️ 24 -> 25 ON 2026-09-26. "Talk to expert" left the V3 bar and
      // became a Tools tile (Care and medicines), opening the same consults.
      // ⚠️ 25 -> 24 ON 2026-09-27: Mood folded into "Symptoms and mood"
      // (both opened the one logger). Kept for revert: 25.
      // ⚠️ 24 -> 22 ON 2026-09-28 (launch sanity T1): "Weight and fertility"
      // folded into Weight (the BMI page opens from the Weight page) and
      // "Products" left the hub (it opened a tab). Kept for revert: 24.
      expect(TtcToolsScreen.toolCount, 22);
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
      // T4 (launch sanity, 2026-09-28): one sentence above the controls, the
      // whole "why" one tap away. Kept for revert (2026-09-28):
      // expect(find.text(tracker.why(false)), findsOneWidget);
      expect(find.text(ttcTrackerWhyLead(tracker, false)), findsOneWidget);
      expect(find.text(tracker.why(false)), findsNothing);
      await tester.tap(find.byKey(const ValueKey('ttc_tracker_why_more')));
      await tester.pumpAndSettle();
      expect(find.text(tracker.why(false)), findsOneWidget);
    });

    testWidgets('Weight: controls first, and BMI is on the page (T2, T4)',
        (tester) async {
      final tracker = ttcTrackerById('weight')!;
      await pumpTall(tester, TtcTrackerScreen(tracker: tracker));
      expect(find.text(ttcTrackerWhyLead(tracker, false)), findsOneWidget);
      expect(find.text(tracker.why(false)), findsNothing,
          reason: 'two paragraphs no longer sit above the first control');
      expect(find.byKey(const ValueKey('ttc_weight_bmi_row')), findsOneWidget,
          reason: 'the BMI screen is reached from the Weight page');
      expect(find.text('Work out your BMI'), findsOneWidget);
    });

    testWidgets('choosing an option records it', (tester) async {
      final tracker = ttcTrackerById('mood')!;
      await pumpTall(tester, TtcTrackerScreen(tracker: tracker));
      await tester.tap(find.text('Okay').first);
      await tester.pump();
      expect(TtcLogStore.instance.valueFor('mood', 'mood')!.value, 2);
    });

    // =========================================================================
    //  ⚠️ THE HABIT MERGE, AND THE HALF THAT CAN LOSE SOMEBODY'S DATA
    // -------------------------------------------------------------------------
    //  Sleep, Movement, Stress and Lifestyle became one `habits` tracker on
    //  2026-09-04. `TtcLogStore` keys rows `tracker/field/day`, so without a
    //  remap every night of sleep anybody had logged would still be in the file
    //  and invisible in the app — a silent loss, on a store whose whole promise
    //  is that it records what she tells it.
    // =========================================================================
    test('the four old tracker ids fold into habits', () {
      for (final old in ['sleep', 'exercise', 'stress', 'lifestyle']) {
        expect(ttcMergedTracker(old), 'habits', reason: old);
      }
    });

    test('and nothing else moves', () {
      for (final other in ['symptoms', 'weight', 'mood', 'partner_health']) {
        expect(ttcMergedTracker(other), other, reason: other);
      }
      expect(ttcMergedTracker('habits'), 'habits');
    });

    test('the merged tracker carries every field the four had', () {
      final habits = ttcTrackerById('habits')!;
      final ids = habits.fields.map((f) => f.id).toSet();
      for (final f in [
        'hours', 'quality', // sleep
        'minutes', 'kind', // movement
        'stress', // stress
        'caffeine', 'alcohol', 'smoking', 'water', // lifestyle
      ]) {
        expect(ids, contains(f), reason: '"$f" was dropped in the merge');
      }
    });

    test('no two fields collide, which is the only reason the merge is safe',
        () {
      // If two of the four trackers had shared a field id, remapping the
      // tracker half of the key would land one row on another and lose it.
      // They did not — and this asserts it stays true if fields are added.
      final habits = ttcTrackerById('habits')!;
      final ids = habits.fields.map((f) => f.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('the stress field references Mind and body, and does not copy it', () {
      // ⚠️ THE REBUILD BRIEF'S STEP 5c. Getting ready is the single source for
      // before-you-start body prep; it does NOT own stress, which belongs to
      // Mind and body. So the field names that area's read by id and the
      // article stays edited in exactly one place.
      final stress = ttcTrackerById('habits')!
          .fields
          .firstWhere((f) => f.id == 'stress');
      expect(stress.readId, 'ttc_read_stress_fertility');
      expect(ttcReadById(stress.readId!), isNotNull,
          reason: 'the field points at a read that is not in the library, so '
              'the link renders and opens nothing');
    });

    test('and no other field claims to be explained by somebody else', () {
      // One field in nine carries a link. If that ever becomes most of them,
      // the tracker has turned into a reading list.
      final linked = ttcTrackerById('habits')!
          .fields
          .where((f) => f.readId != null)
          .length;
      expect(linked, 1);
    });

    testWidgets('the link names the read, so renaming the article renames it',
        (tester) async {
      await pumpTall(
          tester, TtcTrackerScreen(tracker: ttcTrackerById('habits')!));
      // The "Read:" prefix went when the link became a proper tappable row —
      // a chevron and the action violet say "this opens something" better than
      // a word did, and the title alone is what the read is called.
      final title = ttcReadById('ttc_read_stress_fertility')!.title.en;
      expect(find.text(title), findsOneWidget);
    });

    test('the old four are gone from the catalogue, not just from the hub', () {
      for (final old in ['sleep', 'exercise', 'stress', 'lifestyle']) {
        expect(ttcTrackerById(old), isNull,
            reason: '$old still resolves, so two doors open one room');
      }
    });

    // ⚠️ THE EMPTY INVITE WAS ON THE HISTORY LIST, AND THE HISTORY LIST IS
    // GONE — 2026-09-04. Thirty day-cards were replaced by "Look back", which
    // is reached from the header rather than sitting under the fields, so
    // there is no longer a blank list on this screen to invite anything into.
    //
    // The rule underneath it survives and matters more here than it did: an
    // untouched tracker must read as an invitation rather than as a form. That
    // is now one sentence at the top of the sheet, before anything is asked
    // for, and it is the most important copy on the screen — nine empty fields
    // read as nine things she has failed to do unless something says otherwise
    // first.
    testWidgets('an untouched tracker gives permission before it asks',
        (tester) async {
      await pumpTall(
          tester, TtcTrackerScreen(tracker: ttcTrackerById('habits')!));
      expect(
          // The tool shell's intro since the tool rebuild (2026-09-27): it
          // names the day strip too. Was (tools pass, the same day):
          //   find.text('Write down as much or as little as you like. One '
          //       'thing is enough. Each answer saves as you tap.'),
          find.text(kTtcTrackerIntro),
          findsOneWidget);
    });

    testWidgets('and looking back is offered without being the screen',
        (tester) async {
      await pumpTall(
          tester, TtcTrackerScreen(tracker: ttcTrackerById('habits')!));
      // "Past 4 weeks" since 2026-09-27 (tools pass). Was: 'Look back'.
      expect(find.text('Past 4 weeks'), findsOneWidget);
      await tester.tap(find.text('Past 4 weeks'));
      await tester.pumpAndSettle();
      // The chart heads with the field's own name since the tool rebuild
      // (2026-09-27), under a two-view switch. Was:
      //   expect(find.text('Looking back'), findsOneWidget);
      expect(find.text(kTtcTrackerEntriesTitle), findsOneWidget);
      // The rule the strip exists under: it describes, it never assesses.
      expect(
          find.text("A blank space is a day you didn't write anything down."),
          findsOneWidget);
    });

    testWidgets('a scale stays on one row; named choices may wrap',
        (tester) async {
      // The design wraps both. A five-option ORDERED scale wraps 4 + 1 on a
      // 354pt sheet, which makes its far end look like a separate control —
      // the exact bug the screen this replaced had already fixed once.
      await pumpTall(
          tester, TtcTrackerScreen(tracker: ttcTrackerById('habits')!));
      // The stress scale is None → Severe, and "Severe" is the far end that
      // used to be orphaned.
      final first = tester.getTopLeft(find.text('None').first);
      final last = tester.getTopLeft(find.text('Severe').first);
      expect(last.dy, closeTo(first.dy, 1.0),
          reason: 'the far end of the stress scale dropped to its own line');
      expect(last.dx, greaterThan(first.dx));
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
      // ⚠️ THE WORDS MOVED, THE BEHAVIOUR DID NOT. The rebuilt Companion opens
      // its empty state on a named invitation rather than a generic CTA — the
      // assertion still holds that a screen with no data offers the one action
      // that changes that.
      await pumpTall(tester, const TtcCycleScreen());
      expect(find.text('Add a period date'), findsOneWidget);
    });

    testWidgets('with cycles logged it shows the average and range',
        (tester) async {
      CycleStore.instance
        ..logPeriodStart(DateTime(2026, 5, 1))
        ..logPeriodStart(DateTime(2026, 5, 29))
        ..logPeriodStart(DateTime(2026, 6, 28));
      await pumpTall(tester, const TtcCycleScreen());
      // 28 and 30 → usual 29, spread 28 to 30.
      //
      // ⚠️ THIS FIXTURE IS MONTHS IN THE PAST, WHICH MAKES IT THE INTERESTING
      // CASE RATHER THAN A STALE ONE. The current cycle is long overdue, so the
      // engine refuses to estimate and the Companion shows its no-estimate
      // body — and her rhythm numbers must still be there. Refusing to draw
      // THIS cycle is not a reason to stop stating her history.
      expect(find.text('29 days'), findsOneWidget);
      expect(find.text('28 to 30 days'), findsOneWidget);
    });

    testWidgets('a logged LH positive is reflected back', (tester) async {
      CycleStore.instance.logPeriodStart(
          DateTime.now().subtract(const Duration(days: 15))); // day 16
      CycleStore.instance.logLhPositive(16);
      await pumpTall(tester, const TtcOvulationScreen());
      // The engine puts ovulation the day after the surge. The rebuilt tool
      // (2026-09-27) says it as "Day 17, <date>" and names the test. Was:
      //   expect(find.text(const TtcS(false).estimatedOvulation(17)),
      //       findsOneWidget);
      expect(find.textContaining('Day 17, '), findsOneWidget);
      expect(find.text('From your positive test on day 16.'), findsOneWidget);
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
