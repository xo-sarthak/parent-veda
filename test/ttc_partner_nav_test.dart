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
