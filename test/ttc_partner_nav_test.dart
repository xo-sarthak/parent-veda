// =============================================================================
//  His half has a way out of it
// -----------------------------------------------------------------------------
//  The partner's Today was a raw Scaffold with no navigation at all: five
//  cards, and the only exit was toggling back to Her. He could not reach
//  Prepare, Tools, Calendar or Community from his own home.
//
//  The fix is the SAME five destinations, not a reduced set. Per-user
//  navigation is forbidden in this product - personalisation changes content,
//  ranking and order, never structure, because everyone has to learn one
//  ParentVeda - and the father shell in pregnancy makes the same choice.
//
//  The obvious worry is that sharing her Calendar leaks her cycle to him. It
//  does not, and not because of a check on this screen: his device has no rows
//  in ttc_cycles, so there is simply no cycle to draw. The privacy lives in the
//  own-row rule, which is where it belongs and where it is already tested.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_partner_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcPartnerMode.instance.on = false;
  });

  tearDown(() => TtcPartnerMode.instance.on = false);

  Future<void> pumpTall(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 9000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('he can get out of his own home', () {
    testWidgets('the partner Today renders a bottom nav at all',
        (tester) async {
      await pumpTall(tester, const TtcPartnerTodayScreen());
      expect(find.byType(TtcBottomNav), findsOneWidget,
          reason: 'his half had no navigation whatsoever');
    });

    testWidgets('and it is reached through the Her/Him switch too',
        (tester) async {
      TtcPartnerMode.instance.on = true;
      await pumpTall(tester, const TtcTodayScreen());
      expect(find.byType(TtcBottomNav), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the same five destinations, not a reduced set', () {
    testWidgets('all five are offered', (tester) async {
      await pumpTall(tester, const TtcPartnerTodayScreen());
      for (final label in ['Today', 'Prepare', 'Tools', 'Calendar',
          'Community']) {
        expect(find.text(label), findsWidgets,
            reason: '$label is missing from his navigation');
      }
    });

    testWidgets('hers offers exactly the same five', (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      for (final label in ['Today', 'Prepare', 'Tools', 'Calendar',
          'Community']) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });
  });

  // ===========================================================================
  group('his palette, her structure', () {
    testWidgets('the partner page renders on the slate background',
        (tester) async {
      await pumpTall(tester, const TtcPartnerTodayScreen());
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, ttcSlateBg,
          reason: 'his half should still read as his');
    });

    testWidgets('and hers does not', (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, ttcBg);
    });

    testWidgets('the mode switch survives the move to the shared page',
        (tester) async {
      // It sits in TtcPage's overlay slot now rather than a hand-rolled Stack.
      await pumpTall(tester, const TtcPartnerTodayScreen());
      expect(find.text('Her'), findsOneWidget);
      expect(find.text('Him'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('his nav is his colour, not hers', () {
    test('the inactive tabs are not left on her lavender', () {
      // `ttcMuted` is 0xFFA99CBB - a lavender grey. Against her near-white
      // background it reads as neutral; against his warm cream one it reads
      // unmistakably as HER PURPLE. Only the active pill had been given a slate
      // variant, so four of his five tabs wore the other app's colour on every
      // screen of his half.
      //
      // ⚠️ THE EVIDENCE MOVED, AND THE GUARANTEE IS STRONGER FOR IT.
      //
      // This asserted the literal source `slate ? ttcSlateSoft : ttcMuted`
      // inside `TtcBottomNav`. That bar now delegates to the shared `PvNavBar`,
      // which takes an `accent` and an `inactive` — so his palette is passed in
      // rather than branched on, and the same fix is true of all three stages
      // instead of this one.
      //
      // The bug it was written for is worth keeping on the record: his four
      // inactive tabs were left on `ttcMuted`, a lavender grey chosen against
      // HER near-white background. On his warm cream it read unmistakably as her
      // purple. A muted tone is never neutral in the abstract; it is neutral
      // against the background it was picked for.
      // ⚠️ SLICE TO THE CLASS, NOT TO END-OF-FILE. `substring(indexOf(...))`
      // with no end ran to the last line of a 1,200-line file, so "no
      // Colors.white in the nav bar" was really "no Colors.white anywhere below
      // it" — and `TtcPage` further down uses white legitimately. A source-grep
      // test that reads too much file fails for reasons that have nothing to do
      // with what it is checking.
      final src = File('lib/screens/ttc/ttc_common.dart').readAsStringSync();
      final from = src.indexOf('class TtcBottomNav');
      final next = src.indexOf('\nclass ', from + 1);
      final nav = src.substring(from, next == -1 ? src.length : next);

      expect(nav, contains('PvNavBar('),
          reason: 'TtcBottomNav must delegate to the one shared bar');
      expect(nav, contains('accent: slate ? ttcSlate : ttcPurple'),
          reason: 'his accent must still be his, passed to the shared bar');
      expect(nav.contains('Colors.white'), isFalse,
          reason: 'a white-on-filled-pill active tab would mean the old bar '
              'has grown back');
    });
  });

  // ===========================================================================
  group("his Today's learn is an article, not a caption", () {
    // The same insight rendered as a full read on her Today and as a title plus
    // one line on his. Both open the same screen, but only hers looked like it
    // had anything behind it - so his door was there and nobody would push it.
    //
    // Asserted against the SOURCE because the difference is which pieces of the
    // insight are rendered, and a widget probe for "is there a paragraph" is
    // exactly the kind of test that passes on an empty string.
    const src = 'lib/screens/ttc/ttc_partner_screen.dart';

    test('it shows how long it takes to read', () {
      final learn = _classBody(src, '_LearnCard');
      expect(learn, contains('insight.readTime(hi)'));
    });

    test('and the opening paragraph, like hers', () {
      final learn = _classBody(src, '_LearnCard');
      expect(learn, contains("insight.body(hi).split('\\n\\n').first"));
    });

    test('with the takeaway in a panel, like hers', () {
      final learn = _classBody(src, '_LearnCard');
      expect(learn, contains('insight.takeaway(hi)'));
      expect(learn, contains('ttcSlatePanel'),
          reason: 'the takeaway lost the panel that makes it read as the point');
    });
  });
}

/// The source of one class, so a check on `_LearnCard` cannot be satisfied by
/// something that happens to appear in a different card on the same screen.
String _classBody(String path, String name) {
  final text = File(path).readAsStringSync();
  final start = text.indexOf('class $name');
  expect(start, greaterThan(-1), reason: '$name no longer exists');
  final next = text.indexOf('\nclass ', start + 1);
  return next == -1 ? text.substring(start) : text.substring(start, next);
}
