// =============================================================================
//  The pregnancy profile and its Settings: the way TTC's are (2026-10-01).
//
//  The user: "in pregnancy profile, settings need to be like the way it's in
//  TTC side of app, just make sure profile contains pregnancy relevant content
//  for pregnancy." The short profile was TTC's alone; pregnancy now draws it
//  from its own content. What this file holds:
//
//    1. THE SAME SHAPE as TTC's profile: hero, glance, answers, doctor,
//       journey, family, things and ONE Settings row, with the footer and the
//       Developer section behind Settings, not under the profile.
//    2. PREGNANCY'S OWN CONTENT in it, and none of TTC's: the due date and
//       the weeks left, her answers, the baby-has-arrived row, the quiet
//       "if your pregnancy has ended" row, the keepsakes, an older child.
//    3. NOTHING REPEATS: orders appear once, and a row with no editor of its
//       own does not open a second door to the shared answers page.
//    4. THE SAME SETTINGS as TTC's, in the same order, with pregnancy's
//       Messages and Find help in them.
//    5. HIS VIEW is short and has nothing of hers.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_after_loss.dart';
import 'package:parentveda/screens/profile/pv_settings_screen.dart';
import 'package:parentveda/screens/profile/pv_you_content.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    PregnancyEndedStore.instance.resetForTest();
    await PregnancyEndedStore.instance.load();
    pregnancy = PregnancyController(
      dueDate: DateTime.now().add(const Duration(days: 140)),
    );
    await pregnancy.load();
    await pregnancy.setDueDate(
      DateTime.now().add(const Duration(days: 140)),
      source: DueDateSource.scan,
    );
    PregnancyController.current = pregnancy;
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    double width = 390,
    double text = 1.0,
  }) async {
    tester.view.physicalSize = Size(width, 9000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 9000),
            textScaler: TextScaler.linear(text),
          ),
          child: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openSettings(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(kPvProfileSettingsRowKey));
    await tester.tap(find.byKey(kPvProfileSettingsRowKey));
    await tester.pumpAndSettle();
    expect(find.byType(PvSettingsScreen), findsOneWidget);
  }

  const profile = PvYouScreen(stage: LifeStage.pregnancy);

  // ===========================================================================
  group('the shape is TTC\'s', () {
    testWidgets('every part of the short profile, and one Settings row',
        (tester) async {
      await pump(tester, profile);
      expect(tester.takeException(), isNull);
      expect(find.text('Profile'), findsOneWidget);
      for (final k in [
        'pv_profile_hero',
        'pv_profile_purchases',
        'pv_profile_glance',
        'pv_profile_answers',
        'pv_profile_doctor',
        'pv_profile_journey',
        'pv_profile_family',
        'pv_profile_things',
      ]) {
        expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
      }
      expect(find.byKey(kPvProfileSettingsRowKey), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('the account, language and Developer are behind Settings',
        (tester) async {
      await pump(tester, profile);
      for (final w in [
        'Developer · debug only',
        'Language',
        'Sign out',
        'Delete account',
        'Help',
        'ParentVeda',
      ]) {
        expect(find.text(w), findsNothing, reason: '"$w" is not on the profile');
      }
    });

    testWidgets('the other stages keep the screen they had', (tester) async {
      await pump(tester, const PvYouScreen(stage: LifeStage.parenting));
      expect(find.byKey(const ValueKey('pv_profile_hero')), findsNothing);
      expect(find.text('PREFERENCES'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('pregnancy\'s own content is in it', () {
    testWidgets('the hero says the week; the glance says the date and the time left',
        (tester) async {
      await pump(tester, profile);
      expect(find.text('Pregnancy · week ${pregnancy.currentWeek}'), findsOneWidget);
      expect(find.text('Your due date'), findsOneWidget);
      expect(find.text('Time left'), findsOneWidget);
      expect(find.textContaining('weeks to go'), findsOneWidget);
      // A date from a scan is theirs, and the card says so.
      expect(find.text('From your scan. We never recalculate it.'), findsOneWidget);
    });

    testWidgets('with no real due date the glance invites her to add one',
        (tester) async {
      await pregnancy.setDueDate(DateTime.now().add(const Duration(days: 140)));
      await pump(tester, profile);
      expect(find.text('Add your due date'), findsOneWidget);
      expect(find.text('Your due date'), findsNothing);
    });

    testWidgets('her answers: the six pregnancy facts, with values',
        (tester) async {
      await pump(tester, profile);
      for (final l in [
        'Due date',
        'Twins or more',
        'First pregnancy',
        'Conditions',
        'How you eat',
        'What you want help with',
      ]) {
        expect(
          find.byKey(ValueKey('pv_profile_answer_$l')),
          findsOneWidget,
          reason: 'no "$l" answer row',
        );
      }
      expect(find.byKey(const ValueKey('pv_profile_change_answers')), findsOneWidget);
    });

    testWidgets('only the rows with an editor of their own are tappable',
        (tester) async {
      final d = pvYouContentFor(LifeStage.pregnancy).details;
      final own = [for (final x in d) if (x.ownEditor) x.label];
      expect(own, ['Due date', 'Twins or more', 'Conditions']);
    });

    testWidgets('journey: the baby has arrived, and the quiet row last',
        (tester) async {
      await pump(tester, profile);
      expect(find.byKey(const ValueKey('pv_profile_baby_arrived')), findsOneWidget);
      expect(find.text('Baby has arrived'), findsOneWidget);
      expect(find.text(kPregEndedRowTitle), findsOneWidget);
      final a = tester.getTopLeft(find.text('Baby has arrived')).dy;
      final b = tester.getTopLeft(find.text(kPregEndedRowTitle)).dy;
      expect(b, greaterThan(a), reason: 'the quiet row comes after the action');
    });

    testWidgets('the doctor note, the keepsakes and an older child',
        (tester) async {
      await pump(tester, profile);
      for (final w in [
        'Notes for your doctor',
        'Saved',
        'Memories',
        'Dear Baby vault',
        'Journal',
        'Bump journey',
        'Add an older child',
      ]) {
        expect(find.text(w), findsOneWidget, reason: '"$w" is not on the profile');
      }
    });

    testWidgets('and nothing of trying to conceive', (tester) async {
      await pump(tester, profile);
      for (final w in [
        'I got a positive test',
        'Log your period',
        'Your cycle at a glance',
        'Trying to conceive',
        'Treatment',
      ]) {
        expect(find.textContaining(w), findsNothing, reason: '"$w" is TTC\'s');
      }
    });

    testWidgets('a pregnancy that has ended says nothing about the weeks',
        (tester) async {
      await PregnancyEndedStore.instance.markEnded();
      await pump(tester, profile);
      expect(find.text('Pregnancy'), findsOneWidget);
      expect(find.textContaining('week ${pregnancy.currentWeek}'), findsNothing);
    });
  });

  // ===========================================================================
  group('nothing repeats', () {
    testWidgets('orders once: the tile under the hero, not a second row',
        (tester) async {
      await pump(tester, profile);
      expect(find.byKey(const ValueKey('pv_profile_orders')), findsOneWidget);
      expect(find.text('Orders'), findsNothing);
      expect(find.text('Your orders'), findsOneWidget);
    });

    testWidgets('no destination is offered by two rows', (tester) async {
      // Titles of the tappable rows on the profile, each once.
      await pump(tester, profile);
      for (final w in [
        'Notes for your doctor',
        'Change your answers',
        'Baby has arrived',
        kPregEndedRowTitle,
        'Saved',
        'Memories',
        'Journal',
        'Bump journey',
        'Dear Baby vault',
      ]) {
        expect(find.text(w), findsOneWidget, reason: '"$w" appears twice');
      }
    });
  });

  // ===========================================================================
  group('Settings is TTC\'s, with pregnancy\'s rows', () {
    testWidgets('the same sections, in the same order', (tester) async {
      await pump(tester, profile);
      await openSettings(tester);
      var y = -1.0;
      for (final t in [
        'pv_settings_account',
        'pv_settings_preferences',
        'pv_settings_notifications',
        'pv_settings_privacy and data',
        'pv_settings_support',
        'pv_settings_about',
      ]) {
        final f = find.byKey(ValueKey(t));
        expect(f, findsOneWidget, reason: t);
        final dy = tester.getTopLeft(f).dy;
        expect(dy, greaterThan(y), reason: '$t is out of order');
        y = dy;
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('and the rows that belong to a mother who is expecting',
        (tester) async {
      await pump(tester, profile);
      await openSettings(tester);
      for (final w in [
        'Language',
        'Reminders',
        'Messages',
        'Find help near you',
        'Data and privacy',
        'Contact us',
        'About ParentVeda',
      ]) {
        expect(find.text(w), findsWidgets, reason: 'Settings has no "$w"');
      }
      // Sign out and Delete account only exist for someone signed in, as on
      // TTC's Settings; here nobody is, so the account row says so.
      expect(find.text('Not signed in'), findsOneWidget);
      // Delivery addresses sit in Account, as they do for TTC.
      expect(find.textContaining('Delivery'), findsWidgets);
    });

    test('pregnancy fills the same Settings slots TTC does', () {
      final t = pvYouContentFor(LifeStage.tryingToConceive);
      final p = pvYouContentFor(LifeStage.pregnancy);
      expect(p.notificationThings, isNotEmpty);
      expect(p.supportThings, isNotEmpty);
      expect(p.profileThings, isNotEmpty);
      expect(t.notificationThings, isNotEmpty);
      expect(p.shortProfile, isTrue);
      expect(t.shortProfile, isFalse, reason: 'TTC asks with `groups`, as before');
      expect(p.groups, isNull,
          reason: 'groups also builds the More bento, which pregnancy does not use');
    });
  });

  // ===========================================================================
  group('his view', () {
    testWidgets('short, with nothing of hers', (tester) async {
      await pump(tester, const PvYouScreen(stage: LifeStage.pregnancy, father: true));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('pv_profile_hero')), findsOneWidget);
      expect(find.byKey(const ValueKey('pv_profile_glance')), findsNothing);
      expect(find.byKey(const ValueKey('pv_profile_answers')), findsNothing);
      expect(find.byKey(const ValueKey('pv_profile_doctor')), findsNothing);
      expect(find.byKey(const ValueKey('pv_profile_baby_arrived')), findsNothing);
      expect(find.byKey(const ValueKey('pv_profile_journey_his')), findsOneWidget);
      expect(find.text(kPregEndedRowTitle), findsNothing);
      expect(find.text('Dear Baby vault'), findsNothing);
      expect(find.byKey(kPvProfileSettingsRowKey), findsOneWidget);
    });
  });

  // ===========================================================================
  group('it holds', () {
    for (final (w, t) in [(360.0, 1.0), (360.0, 1.5), (320.0, 1.0)]) {
      testWidgets('the profile at ${w.toInt()}pt and ${t}x text', (tester) async {
        await pump(tester, profile, width: w, text: t);
        expect(tester.takeException(), isNull);
      });
      testWidgets('Settings at ${w.toInt()}pt and ${t}x text', (tester) async {
        await pump(tester, profile, width: w, text: t);
        await openSettings(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
