// =============================================================================
//  Two Hinglish bugs found by looking at the app rather than the code
// -----------------------------------------------------------------------------
//  Both were invisible in English and obvious the moment the stage was opened
//  in Hinglish - which nobody could do until the language toggle shipped, so
//  they had been sitting there since the stage was written.
//
//    1. The bottom nav's labels were hardcoded English. The one component
//       visible on EVERY screen was the one component that never translated.
//    2. "Her" and "Him" were both "Unka" - the same word on both halves of a
//       two-way switch, so there was no way to tell which side you were on.
//
//  Worth noting how they were found: not by a test, and not by reading. By
//  turning the app to Hinglish and looking at it.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_profile_screen.dart';
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
    // ⚠️ THESE TESTS PIN THE CLASSIC BAR'S CONTRACT. V3 is the default since
    // 2026-09-17 (STILL-OPEN §62) and its bar has different destinations; the
    // classic bar is kept for reference and this file keeps holding it.
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v1);
  });

  tearDown(() => TtcLang.instance.hinglish = false);

  Future<void> pumpTall(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 9000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('the navigation speaks the same language as everything above it', () {
    testWidgets('English shows English labels', (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      expect(find.text('Today'), findsWidgets);
      expect(find.text('Prepare'), findsWidgets);
    });

    testWidgets('and Hinglish shows Hinglish', (tester) async {
      TtcLang.instance.hinglish = true;
      await pumpTall(tester, const TtcTodayScreen());
      expect(find.text('Aaj'), findsWidgets,
          reason: 'the nav was hardcoded English on every screen in the stage');
      expect(find.text('Taiyaari'), findsWidgets);
      expect(find.text('Prepare'), findsNothing);
    });

    test('every tab has its own word in both languages', () {
      const en = TtcS(false);
      const hi = TtcS(true);
      final enTabs = [en.tabToday, en.tabPrepare, en.tabTools, en.tabCalendar,
          en.tabCommunity];
      final hiTabs = [hi.tabToday, hi.tabPrepare, hi.tabTools, hi.tabCalendar,
          hi.tabCommunity];
      expect(enTabs.toSet().length, 5, reason: 'two tabs share a label');
      expect(hiTabs.toSet().length, 5, reason: 'two tabs share a label');
    });
  });

  // ===========================================================================
  group('a two-way switch needs two different words', () {
    test('Her and Him are distinguishable in both languages', () {
      for (final hi in [false, true]) {
        final t = TtcS(hi);
        expect(t.partnerHer, isNot(t.partnerHim),
            reason: hi
                ? 'both halves said "Unka" - you could not tell which side '
                    'you were on'
                : 'English');
      }
    });

    testWidgets('and both appear on the switch', (tester) async {
      // ⚠️ THE SWITCH MOVED TO PROFILE, so this pumps Profile. The invariant is
      // unchanged and is the reason the test exists: a two-way control whose
      // halves read the same word is a control you cannot tell the state of.
      // Where it lives is a product decision; that it says two things is not.
      TtcLang.instance.hinglish = true;
      await pumpTall(tester, const TtcProfileScreen());
      const t = TtcS(true);
      expect(find.text(t.partnerHer), findsOneWidget);
      expect(find.text(t.partnerHim), findsOneWidget);
    });
  });

  // ===========================================================================
  group('nothing else in the chrome shares a word by accident', () {
    test('the profile screen labels its two languages differently', () {
      const t = TtcS(true);
      expect(t.profileHinglish, isNot(t.profileEnglish));
    });

    // ⚠️ RETIRED WITH THE FOLD IT GUARDED. "See the whole cycle" was removed
    // from the fertility window screen — the screen now shows only the window
    // itself, and the whole month lives on the calendar and the cycle
    // companion. The strings are commented out in `ttc_strings.dart` rather
    // than deleted, and this comes back with them.
    //
    // The class of bug it caught is real and still worth catching elsewhere: a
    // toggle whose two labels are the same word reads as a dead control.
    //
    // test('and the fold/unfold pair on the fertility window differs', () {
    //   for (final hi in [false, true]) {
    //     final t = TtcS(hi);
    //     expect(t.windowSeeWhole, isNot(t.windowHideWhole));
    //   }
    // });

    test('the two paging arrows on the fertility window differ', () {
      for (final hi in [false, true]) {
        final t = TtcS(hi);
        expect(t.windowNextCycle, isNot(t.windowPrevCycle));
      }
    });
  });
}
