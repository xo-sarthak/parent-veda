// =============================================================================
//  TTC V3 tabs: Today · Learn · Products · Tools · You (2026-09-26)
// -----------------------------------------------------------------------------
//  The user's call after the TTC gap analysis: Products takes the slot the
//  analysis gave Community (held back), everything under More moves into You,
//  and "Talk to expert" becomes a Tools tile. Four things this file holds:
//
//    1. THE BAR. Five labels, in that order, and each tab lands on its own
//       screen with the bar drawn and the right tab lit. Asserted by tapping,
//       not by reading the switch, because the wiring gate (CLAUDE.md) is
//       about what a thumb reaches.
//    2. LEARN IS COMPLETE. Every read in `kTtcReads` is on a shelf, so a read
//       added to any bracket file shows up in the library with no code change.
//    3. NOTHING LOST ITS ENTRANCE. More's rows (Calendar, Cycle companion,
//       Fertility window, All programmes and sessions) are rows on You now;
//       the consults are a Tools tile.
//    4. THE SHARED SCREENS DID NOT MOVE FOR OTHER STAGES. You keeps its back
//       arrow and has no bar on pregnancy; the store's shop-by-need is only on
//       the TTC storefront.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/learn/pv_learn_screen.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/screens/products/pv_store_screen.dart';
import 'package:parentveda/screens/profile/pv_you_content.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart';
import 'package:parentveda/screens/ttc/ttc_more_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/widgets/pv_nav_bar.dart';

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The source without its comment lines, so a kept-for-revert note that
/// names a retired screen does not count as a call to it.
String _code(String path) => _src(path)
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

const _labels = ['Today', 'Learn', 'Products', 'Tools', 'You'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
    TtcLearnRecents.instance.resetForTest();
    TtcToolRecents.instance.resetForTest();
  });

  Future<void> pumpTall(WidgetTester tester, Widget child,
      {double height = 6000}) async {
    tester.view.physicalSize = Size(1200, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// A bare screen with only the bar, standing in for the home.
  Widget host() => const Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: TtcBottomNav(active: 0, v3: true),
        ),
      );

  int litTab(WidgetTester tester) =>
      tester.widget<PvNavBar>(find.byType(PvNavBar).last).activeIndex;

  // ===========================================================================
  group('the bar', () {
    testWidgets('five labels, in order, and More and Talk to expert are gone',
        (tester) async {
      await pumpTall(tester, host(), height: 1600);
      final xs = <double>[];
      for (final l in _labels) {
        expect(find.text(l), findsOneWidget, reason: '"$l" is not on the bar');
        xs.add(tester.getCenter(find.text(l)).dx);
      }
      for (var i = 1; i < xs.length; i++) {
        expect(xs[i], greaterThan(xs[i - 1]),
            reason: '${_labels[i]} is out of order');
      }
      expect(find.text('More'), findsNothing);
      expect(find.text('Talk to expert'), findsNothing);
      expect(find.text('Community'), findsNothing);
    });

    test('the route map lights the right tab', () {
      expect(ttcV3ActiveFor(ttcHomeRoute, 0), 0);
      expect(ttcV3ActiveFor(kTtcLearnRoute, 0), 1);
      expect(ttcV3ActiveFor('ttc/products', 0), 2);
      expect(ttcV3ActiveFor('ttc/tools', 0), 3);
      expect(ttcV3ActiveFor('ttc/consults', 0), 3,
          reason: 'the consults are a Tools tile now');
      expect(ttcV3ActiveFor(kTtcYouRoute, 0), 4);
      // More's old rows live under You; the calendar is Today's since the
      // launch walk (its front door is the home header). Was 4.
      expect(ttcV3ActiveFor('ttc/calendar', 3), 0);
      expect(ttcV3ActiveFor('ttc_calendar', 3), 0);
      expect(ttcV3ActiveFor('ttc/journal', 3), 4);
      // V1's Tools index still lands on Tools.
      expect(ttcV3ActiveFor('ttc/something', 2), 3);
    });

    const expected = {
      'Learn': (TtcLearnScreen, 1),
      'Products': (PvStoreScreen, 2),
      'Tools': (TtcToolsScreen, 3),
      'You': (PvYouScreen, 4),
    };
    for (final e in expected.entries) {
      testWidgets('${e.key} opens its screen, with the bar, lit', (tester) async {
        await pumpTall(tester, host());
        await tester.tap(find.text(e.key));
        await tester.pumpAndSettle();
        expect(find.byType(e.value.$1), findsOneWidget,
            reason: '${e.key} did not open ${e.value.$1}');
        expect(find.byType(PvNavBar), findsWidgets,
            reason: '${e.key} lost the bar');
        expect(litTab(tester), e.value.$2,
            reason: '${e.key} lit the wrong tab');
        expect(tester.takeException(), isNull);
      });
    }

    test('More is retired, not deleted', () {
      final code = _code('lib/screens/ttc/ttc_common.dart');
      expect(code, isNot(contains('TtcMoreScreen(')),
          reason: 'the bar must not push the retired More screen');
      expect(TtcMoreScreen, isNotNull, reason: 'kept on disk for revert');
    });
  });

  // ===========================================================================
  group('Learn', () {
    test('every read in kTtcReads is on a shelf, exactly once', () {
      final shelved = [
        for (final s in ttcLearnShelves())
          for (final r in s.reads) r.id
      ];
      expect(shelved.toSet(), {for (final r in kTtcReads) r.id});
      expect(shelved.length, kTtcReads.length,
          reason: 'a read sits on two shelves');
    });

    test('Start here resolves, and the questions come from the reads', () {
      expect(ttcLearnStartHere(), isNotEmpty);
      for (final (faq, read) in ttcLearnFaqs()) {
        expect(read.faqs.map((f) => f.question.en),
            contains(faq.question.en));
      }
    });

    testWidgets('lists every read, and a read opens the one reader',
        (tester) async {
      await pumpTall(tester, const TtcLearnScreen(), height: 30000);
      expect(tester.takeException(), isNull);
      // Open every folded shelf.
      for (var guard = 0; guard < 20; guard++) {
        final more = find.textContaining('Show all ');
        if (more.evaluate().isEmpty) break;
        await tester.tap(more.first);
        await tester.pump();
      }
      for (final r in kTtcReads) {
        expect(find.text(r.title.en), findsWidgets,
            reason: '"${r.title.en}" is not in the library');
      }
      // The bar is drawn on the tab, lit on Learn.
      expect(find.byType(TtcBottomNav), findsOneWidget);

      await tester.tap(find.text(ttcLearnStartHere().first.title.en).first);
      await tester.pumpAndSettle();
      expect(find.byType(PvReaderScreen), findsOneWidget,
          reason: 'a read must open in PvReaderScreen');
    });

    testWidgets('search finds a read by a word in its title', (tester) async {
      await pumpTall(tester, const TtcLearnScreen(), height: 3000);
      final target = kTtcReads.first;
      final word = target.title.en
          .split(RegExp(r'[^A-Za-z]+'))
          .firstWhere((w) => w.length >= 5);
      await tester.enterText(find.byType(TextField), word);
      await tester.pump();
      expect(find.text(target.title.en), findsWidgets);
      expect(find.textContaining('Ask Veda about'), findsOneWidget,
          reason: 'the way on under results');
    });
  });

  // ===========================================================================
  group('You holds what More held', () {
    test('the TTC rows are in the content table, Community is not', () {
      final titles = [
        for (final t in pvYouContentFor(LifeStage.tryingToConceive).things)
          t.title
      ];
      for (final row in [
        'Notes for your doctor',
        'Calendar',
        'Cycle companion',
        'Fertile window',
        'All programmes and sessions',
      ]) {
        expect(titles, contains(row), reason: '"$row" lost its entrance');
      }
      expect(titles.any((t) => t.toLowerCase().contains('community')), isFalse,
          reason: 'Community is held back');
      expect(
          [
            for (final t in pvYouContentFor(LifeStage.tryingToConceive).tiles)
              t.title
          ],
          contains('Journal'));
    });

    testWidgets('the You tab: the rows, the bar, no back arrow',
        (tester) async {
      await pumpTall(
        tester,
        const PvYouScreen(
          stage: LifeStage.tryingToConceive,
          bottomNav: TtcBottomNav(active: 4, v3: true),
        ),
        height: 9000,
      );
      // ⚠️ SHORT AND GROUPED (2026-09-27): Calendar, the cycle companion
      // and the fertile window left You (they live on Today and Tools), and
      // the programmes row is "Programmes and sessions". Kept for revert:
      //   'Calendar', 'Cycle companion', 'Fertile window',
      //   'All programmes and sessions'
      for (final row in [
        'Notes for your doctor',
        'Records and reports',
        'Treatment',
        'Your answers',
        'Messages',
        'What you see',
        'Programmes and sessions',
        'Bookings',
      ]) {
        expect(find.text(row), findsWidgets, reason: row);
      }
      for (final gone in ['Calendar', 'Cycle companion', 'Fertile window']) {
        expect(find.text(gone), findsNothing, reason: '$gone lives on Today and Tools');
      }
      expect(find.byType(TtcBottomNav), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing,
          reason: 'a tab root has no back arrow');
    });

    testWidgets('other stages: You is exactly as before', (tester) async {
      await pumpTall(tester, const PvYouScreen(stage: LifeStage.pregnancy),
          height: 9000);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byType(PvNavBar), findsNothing);
    });
  });

  // ===========================================================================
  group('Tools', () {
    test('Talk to an expert is a tile', () {
      expect(ttcToolById('expert')?.nameEn, 'Talk to an expert');
    });

    testWidgets('the expert tile opens the consults', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      expect(find.text('Talk to an expert'), findsWidgets);
      await tester.tap(find.text('Talk to an expert').first);
      await tester.pumpAndSettle();
      expect(find.byType(PvLearnScreen), findsOneWidget);
    });

    testWidgets('find a tool by what it is for', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      await tester.enterText(find.byType(TextField), 'sleep');
      await tester.pump();
      expect(find.text("What you're working on"), findsOneWidget,
          reason: 'the habits tool names sleep in its purpose line');
      expect(find.text('Supplements'), findsNothing);
    });

    testWidgets('the strip is never empty, and shows what she opened last',
        (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      expect(find.text('GOOD PLACES TO START'), findsOneWidget);
      // 'mood' left the hub on 2026-09-27 (folded into 'symptoms').
      await TtcToolRecents.instance.touch('symptoms');
      await tester.pump();
      expect(find.text('RECENTLY USED'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('at phone width', () {
    // 392 logical px, the main test phone. Overflow shows up as an exception.
    Future<void> pumpPhone(WidgetTester tester, Widget child) async {
      tester.view.physicalSize = const Size(392 * 3, 20000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('Learn, Tools and the You tab lay out without overflow',
        (tester) async {
      await pumpPhone(tester, const TtcLearnScreen());
      expect(tester.takeException(), isNull);
      await pumpPhone(tester, const TtcToolsScreen());
      expect(tester.takeException(), isNull);
      await pumpPhone(
          tester,
          const PvYouScreen(
            stage: LifeStage.tryingToConceive,
            bottomNav: TtcBottomNav(active: 4, v3: true),
          ));
      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  group('Products', () {
    testWidgets('shop by need is on the TTC storefront only', (tester) async {
      await pumpTall(
          tester,
          const PvStoreScreen(
              chrome: PvStoreChrome.ttc,
              initialStage: LifeStage.tryingToConceive));
      expect(find.text('SHOP BY NEED'), findsOneWidget);
      expect(find.text('Starting folic acid'), findsOneWidget);

      await pumpTall(
          tester,
          const PvStoreScreen(
              chrome: PvStoreChrome.none, initialStage: LifeStage.pregnancy));
      expect(find.text('SHOP BY NEED'), findsNothing);
    });
  });
}
