// =============================================================================
//  The parenting V3 home, reshaped to the 2026-09-16 Claude Design
// -----------------------------------------------------------------------------
//  Three things are pinned here, each for a reason the build actually hit:
//
//    1. THE ACTIVITIES DAY-MACHINE. "Done stays until tomorrow", "Change swaps
//       at once and does not come straight back", "tomorrow is fresh" are
//       rules about TIME, and a rule about time is the easiest thing to get
//       subtly wrong and never see, because nobody waits until midnight to
//       check. The store takes a clock so the test can.
//
//    2. THE MORE SHEET COVERS THE DRAWER. The bottom bar lost its hamburger
//       route to Explore; if the sheet misses a drawer row, that feature is
//       hidden with nothing failing. The dedupe is by title, so a renamed row
//       must fail here rather than show twice.
//
//    3. THE SECTIONS ARE ON THE SCREEN, by their new names and in their new
//       order, with the old names gone. Test counts prove nothing about
//       reachability; a rendered widget does.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/explore_drawer.dart';
import 'package:parentveda/screens/post_pregnancy/pp_common.dart';
import 'package:parentveda/screens/post_pregnancy/pp_grow_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_activities_store.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_changes.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_v3.dart';
import 'package:parentveda/screens/post_pregnancy/pp_more_sheet.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/life_stage_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  //  1. Activities to do today
  // ==========================================================================
  group('PpHomeActivitiesStore', () {
    late PpHomeActivitiesStore store;
    var today = DateTime(2026, 9, 16, 10);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = PpHomeActivitiesStore.instance;
      store.resetForTest();
      today = DateTime(2026, 9, 16, 10);
      store.now = () => today;
      await store.ensureLoaded();
    });

    test('shows three, and the same three on a second look', () {
      final a = store.todays(4);
      final b = store.todays(4);
      expect(a.length, kPpHomeActivityCount);
      expect(a.map((x) => x.id), b.map((x) => x.id));
      expect(a.map((x) => x.id).toSet().length, 3, reason: 'no duplicates');
    });

    test('Done keeps the card on the page for the day', () async {
      final before = store.todays(4);
      await store.markDone(before.first.id);
      final after = store.todays(4);
      expect(after.map((x) => x.id), before.map((x) => x.id),
          reason: 'a completed activity is not replaced until tomorrow');
      expect(store.isDone(before.first.id), isTrue);
      expect(store.allDone, isFalse);
      // And the Brain tab's record agrees — one event, one writer.
      expect(GrowStore.instance.isCompletedToday(before.first.id), isTrue);
    });

    test('Change swaps the card at once, and the old one does not return',
        () {
      final before = store.todays(4);
      final gone = before[1].id;
      store.swap(gone, 4);
      final after = store.todays(4);
      expect(after.length, 3);
      expect(after[1].id, isNot(gone), reason: 'swapped in place');
      expect(after[0].id, before[0].id, reason: 'the other slots hold still');
      expect(after[2].id, before[2].id);
      expect(store.wasSwappedIn(after[1].id), isTrue);
      // Swap again: the rejected one must not be what comes back.
      store.swap(after[1].id, 4);
      expect(store.todays(4)[1].id, isNot(gone));
    });

    test('a completed card cannot be swapped away', () async {
      final before = store.todays(4);
      await store.markDone(before[0].id);
      store.swap(before[0].id, 4);
      expect(store.todays(4)[0].id, before[0].id);
    });

    test('all three done reads as all done', () async {
      for (final a in store.todays(4)) {
        await store.markDone(a.id);
      }
      expect(store.allDone, isTrue);
    });

    test('tomorrow brings three new ones, and the old three sit out', () async {
      final day1 = store.todays(4).map((x) => x.id).toSet();
      for (final id in day1) {
        await store.markDone(id);
      }
      today = today.add(const Duration(days: 1));
      final day2 = store.todays(4).map((x) => x.id).toSet();
      expect(day2.length, 3);
      expect(day2.intersection(day1), isEmpty,
          reason: 'yesterday\'s three are on cooldown');
      expect(store.allDone, isFalse, reason: 'done resets with the day');
    });

    test('never fewer than three, even for an age the pool is thin at', () {
      // 30 months suits only a handful of activities exactly; the picker
      // widens the band rather than showing a shorter list.
      expect(store.todays(30).length, kPpHomeActivityCount);
      expect(store.todays(58).length, kPpHomeActivityCount);
    });
  });

  // ==========================================================================
  //  2. How {name} is doing — derived, and only what is changing
  // ==========================================================================
  group('phaseChangesFor', () {
    test('every phase yields a handful of cards, one per domain with a '
        'milestone', () {
      for (final phase in kPhases) {
        final changes = phaseChangesFor(phase);
        expect(changes, isNotEmpty, reason: 'phase ${phase.number}');
        expect(changes.length, lessThanOrEqualTo(PhaseDomain.values.length));
        final domains = changes.map((c) => c.domain).toList();
        expect(domains.toSet().length, domains.length,
            reason: 'one card per domain');
        for (final c in changes) {
          expect(c.milestones.every((m) => m.domain == c.domain), isTrue);
          expect(c.title, isNotEmpty);
          expect(c.notice, isNotEmpty);
          expect(c.paragraphs().length, 2);
        }
      }
    });

    test('a phase with fewer things changing shows fewer cards', () {
      // Phase 1 has three milestones in three domains; later phases have up
      // to six across five. The section must shrink and grow with the data
      // rather than pad to a grid.
      expect(phaseChangesFor(kPhases.first).length, 3);
      expect(phaseChangesLine(phaseChangesFor(kPhases.first), kPhases.first),
          'Three things are changing at 0–4 weeks.');
    });

    test('the sheet has a video for every card', () {
      for (final phase in kPhases) {
        for (final c in phaseChangesFor(phase)) {
          expect(c.video, isNotNull,
              reason: 'phase ${phase.number} ${c.category} has no video');
        }
      }
    });
  });

  // ==========================================================================
  //  3. The bottom bar and the More sheet
  // ==========================================================================
  group('bottom bar', () {
    test('is Home · Products · Tools · Brain activities · More, in that order',
        () {
      expect(PpTab.values,
          [PpTab.home, PpTab.products, PpTab.tools, PpTab.brain, PpTab.more]);
    });

    test('the More sheet reaches every Explore drawer row exactly once', () {
      final sheet = ppMoreSheetEntries();
      final titles = sheet.map((e) => e.title).toList();
      expect(titles.first, 'Community',
          reason: 'Community lost its tab; it is first in More');
      expect(titles.toSet().length, titles.length, reason: 'no duplicates');
      // Every drawer destination is in the sheet — by screen type, since the
      // sheet renames a few (Courses & Masterclasses → Learn).
      final sheetScreens = sheet.map((e) => e.screen.runtimeType).toSet();
      for (final e in ppExploreEntries()) {
        expect(sheetScreens, contains(e.screen.runtimeType),
            reason: '"${e.title}" is in the drawer but not in More');
      }
    });
  });

  // ==========================================================================
  //  4. The screen
  // ==========================================================================
  group('PpHomeV3', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      PpHomeActivitiesStore.instance.resetForTest();
    });

    Future<void> scrollUntil(WidgetTester tester, String text) async {
      for (var i = 0; i < 12; i++) {
        if (find.textContaining(text, skipOffstage: false).evaluate().isNotEmpty) {
          return;
        }
        await tester.drag(find.byType(ListView).first, const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    testWidgets('What to buy is the first tile', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PpHomeV3()));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      final labels = bracketsFor(LifeStage.parenting)
          .map((b) => b.label.en)
          .toList();
      final buy = labels.firstWhere((l) => l.toLowerCase().contains('buy'));
      final buyPos = tester.getTopLeft(find.text(buy).first);
      for (final l in labels) {
        if (l == buy) continue;
        final pos = tester.getTopLeft(find.text(l).first);
        expect(
            pos.dy > buyPos.dy || (pos.dy == buyPos.dy && pos.dx > buyPos.dx),
            isTrue,
            reason: '"$l" is drawn before "$buy"');
      }
    });

    testWidgets('the sections carry their new names and the old ones are gone',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PpHomeV3()));
      await tester.pump(const Duration(milliseconds: 400));

      for (final t in [
        'Activities to do today with your baby',
        'Recommended reads for today',
        'Recommended products for your baby',
        'Record a memory for your child today',
      ]) {
        await scrollUntil(tester, t);
        expect(find.textContaining(t, skipOffstage: false), findsWidgets,
            reason: '"$t" is not on the screen');
      }
      for (final gone in [
        'Short enough for today',
        'Keep today',
        'One thing to try',
        'Things that help',
        'This phase, in a video',
      ]) {
        expect(find.textContaining(gone, skipOffstage: false), findsNothing,
            reason: '"$gone" is still on the screen');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('the video sits above the phase text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PpHomeV3()));
      await tester.pump(const Duration(milliseconds: 400));
      await scrollUntil(tester, 'THIS PHASE EXPLAINED');
      await tester.pump(const Duration(milliseconds: 200));

      final head = find.textContaining('THIS PHASE EXPLAINED', skipOffstage: false);
      final play = find.byIcon(Icons.play_arrow_rounded, skipOffstage: false);
      final readMore =
          find.textContaining('Read the full description', skipOffstage: false);
      expect(head, findsOneWidget);
      expect(play, findsWidgets);
      expect(readMore, findsOneWidget);
      final headY = tester.getTopLeft(head).dy;
      final playY = tester.getTopLeft(play.first).dy;
      final textY = tester.getTopLeft(readMore).dy;
      expect(playY, greaterThan(headY));
      expect(textY, greaterThan(playY),
          reason: 'the written description must follow the video');
    });

    testWidgets('Done marks the card and keeps it', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PpHomeV3()));
      await tester.pump(const Duration(milliseconds: 400));
      await scrollUntil(tester, 'Activities to do today');
      await tester.pump(const Duration(milliseconds: 200));

      final done = find.text('Done', skipOffstage: false);
      expect(done, findsNWidgets(3));
      // ⚠️ scrollUntilVisible, NOT ensureVisible. The sheet is one tall Column
      // inside a ListView, so ensureVisible reveals the Column (already
      // "visible") and leaves the card two screens below the fold.
      await tester.scrollUntilVisible(done.first, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(done.first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Done today', skipOffstage: false), findsOneWidget);
      expect(find.text('Done', skipOffstage: false), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });
}
