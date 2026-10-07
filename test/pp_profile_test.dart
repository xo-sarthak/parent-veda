// =============================================================================
//  The parenting Profile, the way TTC's and pregnancy's are (2026-10-07)
//
//  The user: "Under More > Everything else ... a lot of it can go inside the
//  Profile section, which you haven't created for the parenting side." What
//  this file holds:
//
//    1. Parenting draws the SHORT profile (hero, journey, orders and bookings,
//       answers, doctor, family, "Your family's setup", things, one Settings
//       row), not the old long You.
//    2. The hero's line is derived from the child: "<name>'s parent, <age>".
//    3. Each row moved from More opens its own screen.
//    4. More no longer lists them, so nothing is listed twice.
//    5. The Developer section is still reachable, behind Settings.
//    6. 360dp at 1.5x text: no overflow.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/care_partner/care_circle_screen.dart';
import 'package:parentveda/screens/post_pregnancy/astrology_screen.dart';
import 'package:parentveda/screens/post_pregnancy/family_profile_screen.dart';
import 'package:parentveda/screens/post_pregnancy/investments_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_more_screen.dart';
import 'package:parentveda/screens/profile/pv_settings_screen.dart';
import 'package:parentveda/screens/profile/pv_you_content.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/referral/invite_friends_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/screens/v2/v3_hero_chrome.dart';

class _Names extends NavigatorObserver {
  final names = <String?>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      names.add(route.settings.name);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LifeStageStore.instance.resetForTest();
    ChildProfileStore.instance.resetForTest();
  });
  tearDown(() => ChildProfileStore.instance.resetForTest());

  const profile = PvYouScreen(stage: LifeStage.parenting);

  Future<_Names> pump(
    WidgetTester tester,
    Widget child, {
    double width = 390,
    double text = 1.0,
    double height = 9000,
  }) async {
    final names = _Names();
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: Size(width, height),
          textScaler: TextScaler.linear(text),
        ),
        child: MaterialApp(
          key: UniqueKey(),
          navigatorObservers: [names],
          home: child,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return names;
  }

  group('the short profile draws for parenting', () {
    testWidgets('its parts, and one Settings row', (tester) async {
      await pump(tester, profile);
      expect(tester.takeException(), isNull);
      expect(find.text('Profile'), findsWidgets);
      for (final k in [
        'pv_profile_hero',
        'pv_profile_journey',
        'pv_profile_purchases',
        'pv_profile_answers',
        'pv_profile_doctor',
        'pv_profile_family',
        'pv_profile_setup',
        'pv_profile_things',
      ]) {
        expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
      }
      expect(find.byKey(kPvProfileSettingsRowKey), findsOneWidget);
      // The long You's eyebrows are gone; Settings holds them.
      expect(find.text('PREFERENCES'), findsNothing);
      expect(find.text('Developer'), findsNothing);
      // No cycle glance: that is trying to conceive's.
      expect(find.byKey(const ValueKey('pv_profile_glance')), findsNothing);
    });

    testWidgets('with no child: "Add a child" carries the invitation',
        (tester) async {
      await pump(tester, profile);
      expect(find.byKey(const ValueKey('pv_profile_add_child')), findsOneWidget);
      expect(find.text('Add a child'), findsOneWidget);
      expect(find.text('Parenting'), findsWidgets);
    });

    testWidgets('with a child: the hero names the parent, and a row opens the child',
        (tester) async {
      ChildProfileStore.instance
          .debugSetDob(DateTime.now().subtract(const Duration(days: 125)));
      final c = ChildProfileStore.instance.active;
      c.name = 'Meera';
      final names = await pump(tester, profile);
      expect(
        find.textContaining("Meera's parent, ${ChildProfileStore.instance.ageLabel}"),
        findsOneWidget,
      );
      final row = find.byKey(ValueKey('pv_profile_child_${c.id}'));
      expect(row, findsOneWidget);
      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(names.names, contains('you/child/${c.id}'));
    });
  });

  group('the rows moved from More', () {
    final moved = <String, (String, Type)>{
      'Personalize ParentVeda': ('pp/family_profile', FamilyProfileScreen),
      'Your Care Circle': ('pp/care_circle', CareCircleScreen),
      'Invite a friend': ('pp/invite', InviteFriendsScreen),
      'Investments and savings': ('pp/investments', InvestmentsScreen),
      'Astrology and numerology': ('pp/astrology', AstrologyScreen),
    };

    test('are the parenting content\'s setup rows, in order', () {
      expect(
        [for (final t in pvYouContentFor(LifeStage.parenting).setupThings) t.title],
        moved.keys.toList(),
      );
      // No other stage has them.
      for (final s in [LifeStage.tryingToConceive, LifeStage.pregnancy, LifeStage.skilling]) {
        expect(pvYouContentFor(s).setupThings, isEmpty, reason: s.name);
      }
    });

    for (final e in moved.entries) {
      testWidgets('"${e.key}" opens its screen', (tester) async {
        final names = await pump(tester, profile);
        final row = find.text(e.key);
        expect(row, findsOneWidget);
        await tester.ensureVisible(row);
        await tester.tap(row);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(names.names, contains(e.value.$1));
        expect(find.byType(e.value.$2), findsOneWidget);
      });
    }

    testWidgets('More no longer lists them', (tester) async {
      await pump(tester, const PpMoreScreen(), height: 6000);
      expect(tester.takeException(), isNull);
      for (final t in kPpMovedToProfile) {
        expect(find.byKey(ValueKey('pp_more_rest_$t')), findsNothing, reason: t);
        expect(find.text(t), findsNothing, reason: t);
      }
      // What the app offers stays on More.
      expect(find.byKey(const ValueKey('pp_more_find_help')), findsOneWidget);
    });
  });

  group('Settings', () {
    testWidgets('holds the account, language and the Developer section',
        (tester) async {
      await pump(tester, profile);
      await tester.ensureVisible(find.byKey(kPvProfileSettingsRowKey));
      await tester.tap(find.byKey(kPvProfileSettingsRowKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(PvSettingsScreen), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      // Ships in every build (kPvShipDeveloperSection, 2026-10-07).
      expect(kPvShipDeveloperSection, isTrue);
      expect(find.byKey(const ValueKey('pv_settings_developer')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('no overflow', () {
    for (final t in [1.0, 1.5]) {
      testWidgets('the profile at 360dp and ${t}x text', (tester) async {
        await pump(tester, profile, width: 360, text: t);
        expect(tester.takeException(), isNull);
      });
      testWidgets('Settings at 360dp and ${t}x text', (tester) async {
        await pump(tester, profile, width: 360, text: t);
        await tester.ensureVisible(find.byKey(kPvProfileSettingsRowKey));
        await tester.tap(find.byKey(kPvProfileSettingsRowKey));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(PvSettingsScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  // The user, 2026-10-07: "i still dont see profile section and settings option
  // in parenting". The avatar on the parenting home opened the three-stage
  // menu, and the profile it was handed was never called. Wiring, held both in
  // the source and on a pumped header.
  test('the parenting home asks its avatar to open the profile', () {
    final src = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
    expect(src, contains('avatarOpensProfile: true'));
    expect(src, contains('onProfile: () => openPvYou(context, stage: LifeStage.parenting)'));
  });

  testWidgets('a header told to open the profile does', (t) async {
    var opened = 0;
    await t.pumpWidget(MaterialApp(
        home: Scaffold(
            body: V3HeroChrome(
      tone: V3HeroTone.onField,
      p: V2PaletteStore.instance.current,
      initial: 'M',
      onSaved: null,
      onProfile: () => opened++,
      avatarOpensProfile: true,
    ))));
    await t.tap(find.text('M'));
    await t.pumpAndSettle();
    expect(opened, 1);
  });
}
