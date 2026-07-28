// =============================================================================
//  TTC Profile - the account surface, and the fact that it is REACHABLE
// -----------------------------------------------------------------------------
//  Reachability is the point of this file, not decoration. The stage shipped
//  with five tabs and a logo header carrying no actions, which meant:
//
//    * Hinglish could not be reached at all by anyone who signed up as
//      trying-to-conceive - TtcLang was only ever set by the door on the
//      pregnancy home.
//    * There was no sign-out anywhere in the stage.
//    * With `pv_life_stage` = 'trying' the splash made ttc/today the root, so
//      one system-back press exited the app.
//
//  TtcHeader had a `trailing` slot documented as "the utility row" from the
//  start, and nothing ever filled it. So the tests here assert the DOOR on
//  every tab, not just that the screen compiles - a screen nobody can open is
//  the failure this repo keeps hitting.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_community_screen.dart';
import 'package:parentveda/screens/ttc/ttc_prepare_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_profile_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
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
  });

  /// A tall surface so a ListView builds its whole subtree - several TTC cards
  /// sit below a phone-sized fold.
  Future<void> pumpTall(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('the door exists on every tab', () {
    // If this fails, the stage has silently gone back to having no way to
    // reach a language control or a sign-out.
    final tabs = <String, Widget>{
      'Today': const TtcTodayScreen(),
      'Prepare': const TtcPrepareScreen(),
      'Tools': const TtcToolsScreen(),
      'Calendar': const TtcCalendarScreen(),
      'Community': const TtcCommunityScreen(),
    };

    for (final entry in tabs.entries) {
      testWidgets('${entry.key} renders a profile door', (tester) async {
        await pumpTall(tester, entry.value);
        expect(find.byIcon(Icons.person_outline_rounded), findsWidgets,
            reason: '${entry.key} has no way into Profile');
      });
    }

    testWidgets('and tapping it opens Profile', (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      await tester.tap(find.byIcon(Icons.person_outline_rounded).first);
      await tester.pumpAndSettle();
      expect(find.byType(TtcProfileScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the language control', () {
    testWidgets('offers both languages and switches between them',
        (tester) async {
      await pumpTall(tester, const TtcProfileScreen());
      expect(find.text('Hinglish'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      expect(TtcLang.instance.hinglish, isFalse);
      await tester.tap(find.text('Hinglish'));
      await tester.pumpAndSettle();
      expect(TtcLang.instance.hinglish, isTrue,
          reason: 'the toggle did not reach TtcLang');
    });

    testWidgets('and the screen itself re-renders in the new language',
        (tester) async {
      await pumpTall(tester, const TtcProfileScreen());
      await tester.tap(find.text('Hinglish'));
      await tester.pumpAndSettle();
      // "Language" in English, "Bhasha" in Hinglish.
      expect(find.text('Bhasha'), findsOneWidget);
    });

    test('the choice survives a restart', () async {
      // Memory-only was the original bug: the toggle would have worked for one
      // session and been forgotten, which is barely better than no toggle.
      SharedPreferences.setMockInitialValues({});
      TtcLang.instance.hinglish = true;
      await Future<void>.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(TtcLang.kKey), isTrue);
      TtcLang.instance.hinglish = false;
    });
  });

  // ===========================================================================
  group('what else the screen carries', () {
    testWidgets('a sign-out', (tester) async {
      await pumpTall(tester, const TtcProfileScreen());
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('the stage switch is labelled as testing', (tester) async {
      // Not a feature. A family trying to conceive is not pregnant, and their
      // real way forward is recording a positive test. The label is what stops
      // this being mistaken for a product decision - the same convention the
      // pregnancy Profile uses twice.
      await pumpTall(tester, const TtcProfileScreen());
      expect(find.textContaining('testing'), findsWidgets);
      expect(find.text('Go to pregnancy'), findsOneWidget);
    });

    testWidgets('partner pairing says what is true rather than offering a dead button',
        (tester) async {
      await pumpTall(tester, const TtcProfileScreen());
      expect(find.text('Your partner'), findsOneWidget);
      expect(find.textContaining('being built'), findsOneWidget);
    });

    testWidgets('it builds in Hinglish too', (tester) async {
      TtcLang.instance.hinglish = true;
      await pumpTall(tester, const TtcProfileScreen());
      expect(tester.takeException(), isNull);
      TtcLang.instance.hinglish = false;
    });
  });

  // ===========================================================================
  group('the stage switch', () {
    testWidgets('sets the life stage to pregnancy', (tester) async {
      expect(LifeStageStore.instance.stage, isNot(LifeStage.pregnancy));
      await pumpTall(tester, const TtcProfileScreen());
      await tester.tap(find.text('Go to pregnancy'));
      await tester.pumpAndSettle();
      expect(LifeStageStore.instance.stage, LifeStage.pregnancy,
          reason: 'the switch did not reach LifeStageStore');
    });

    testWidgets('and says so when there is nowhere to pop back to',
        (tester) async {
      // The first version popped to the first route unconditionally. When the
      // splash had booted TTC, that route WAS ttc/today - so the stage was set
      // correctly and the screen never changed, which reads as a dead button.
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        key: UniqueKey(),
        // Mimic the splash: TTC as the FIRST route, nothing beneath it.
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: const RouteSettings(name: ttcHomeRoute),
          builder: (_) => const TtcProfileScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to pregnancy'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Close and reopen'), findsOneWidget,
          reason: 'a button that appears to do nothing is worse than one that '
              'explains itself');
    });
  });
}
