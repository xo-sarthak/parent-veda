// =============================================================================
//  The four TTC open points closed on 2026-07-27
// -----------------------------------------------------------------------------
//  S9.5 clinic-led cycles - S9.4 splash routing - S9.3 posting - S9.2 deep-links
//
//  The clinic-led group matters most. An IVF couple was being shown a calendar
//  fertility window that can contradict their clinic - and "contradicting a
//  doctor" is the one failure this product must never have. The suppression is
//  in the ENGINE rather than in each screen, so these tests check the engine
//  first and the surfaces second.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/community_data.dart';
import 'package:parentveda/models/community_models.dart';
import 'package:parentveda/screens/ttc/ttc_can_i_screen.dart';
import 'package:parentveda/screens/ttc/ttc_community_screen.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/screens/ttc/ttc_products_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tests_screen.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/services/community_store.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_can_i_data.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_products_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_tests_data.dart';

Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const engine = TtcChapterEngine();
  final today = DateTime(2026, 7, 27);

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  /// A couple with two clean 28-day cycles, currently on day 13 - one day
  /// before a calendar-estimated ovulation. The worst possible day to be shown
  /// a "Peak" reading you should not trust.
  void seedDay13() {
    CycleStore.instance
      ..logPeriodStart(DateTime(2026, 5, 1))
      ..logPeriodStart(DateTime(2026, 5, 29))
      ..logPeriodStart(DateTime.now().subtract(const Duration(days: 12)));
  }

  // ===========================================================================
  group('S9.5 - a clinic-run cycle gets no calendar reading', () {
    TtcJourneyState state({required TimingOwnership ownership}) =>
        TtcJourneyState(
          journeyStart: today.subtract(const Duration(days: 200)),
          lastPeriodStart: today.subtract(const Duration(days: 12)), // day 13
          cycleLengths: const [28, 28],
          ownership: ownership,
          today: today,
        );

    test('naturally, day 13 is peak - that is the reading being suppressed',
        () {
      final s = state(ownership: TimingOwnership.parentveda);
      expect(engine.fertilityFor(s, 13), FertilityLevel.peak);
      expect(engine.resolve(s).estimatedOvulationDay, 14);
    });

    test('on a clinic path there is no fertility grade, on any day', () {
      for (final o in [
        TimingOwnership.clinicGuided,
        TimingOwnership.clinicControlled,
      ]) {
        final s = state(ownership: o);
        for (var day = 1; day <= 28; day++) {
          expect(engine.fertilityFor(s, day), isNull, reason: '$o day $day');
        }
      }
    });

    test('and no ovulation day is published', () {
      final r = engine.resolve(state(ownership: TimingOwnership.clinicControlled));
      expect(r.estimatedOvulationDay, isNull);
      expect(r.fertility, isNull);
      expect(r.inFertileWindow, isFalse);
      expect(r.clinicInvolved, isTrue);
    });

    test('but the chapters still work - the waiting days are real in IVF too',
        () {
      // Suppressing the numbers must not strand her in Chapter 1 forever.
      for (final o in TimingOwnership.values) {
        expect(engine.resolve(state(ownership: o)).chapter,
            TtcChapter.tryingTogether,
            reason: '$o');
      }
    });

    test('cycle day is still counted - her records stay useful', () {
      expect(
          engine.resolve(state(ownership: TimingOwnership.clinicControlled))
              .cycleDay,
          13);
    });

    test('the store derives ownership and passes it to the engine', () {
      seedDay13();
      expect(TtcStore.instance.today.fertility, isNotNull);
      TtcStore.instance.setPath(TtcPath.ivf);
      expect(TtcStore.instance.ownership, TimingOwnership.clinicControlled);
      expect(TtcStore.instance.today.fertility, isNull,
          reason: 'an IVF couple is still being shown a calendar window');
    });

    testWidgets("Today's rhythm card explains rather than guessing",
        (tester) async {
      seedDay13();
      TtcStore.instance.setPath(TtcPath.ivf);
      await pumpTall(tester, const TtcTodayScreen());
      final t = const TtcS(false);
      expect(find.text(TtcStore.instance.ownership.title(false)), findsOneWidget);
      // And never the "still learning your rhythm" copy, which would be untrue.
      expect(find.text(t.noEstimateYet), findsNothing);
    });

    testWidgets('Fertility Window replaces the six-day model', (tester) async {
      seedDay13();
      TtcStore.instance.setPath(TtcPath.iui);
      await pumpTall(tester, const TtcFertilityWindowScreen());
      final t = const TtcS(false);
      expect(find.text(TtcStore.instance.ownership.title(false)), findsOneWidget);
      expect(find.text(t.fertilityWindowNote), findsNothing);
      expect(find.text('Peak'), findsNothing);
    });

    testWidgets('a fully medicated cycle stops asking for LH strips',
        (tester) async {
      seedDay13();
      TtcStore.instance.setPath(TtcPath.ivf);
      await pumpTall(tester, const TtcOvulationScreen());
      final t = const TtcS(false);
      expect(find.text(TtcStore.instance.ownership.title(false)), findsOneWidget);
      // On IVF the surge is caused by a trigger, so a strip tells us nothing we
      // would act on - and asking for data we intend to ignore breaks the rule
      // about never collecting what we cannot use.
      expect(find.text(t.ovulationSignals), findsNothing);
    });

    testWidgets('but a clinic-GUIDED cycle keeps them', (tester) async {
      // The middle tier, and the reason it exists. On monitored letrozole or a
      // natural-cycle FET her own LH surge is exactly what the clinic is timing
      // around - so we stop predicting, but we keep listening.
      seedDay13();
      TtcStore.instance.setPath(TtcPath.ovulationInduction);
      expect(TtcStore.instance.ownership, TimingOwnership.clinicGuided);
      await pumpTall(tester, const TtcOvulationScreen());
      final t = const TtcS(false);
      expect(find.text(t.ovulationSignals), findsOneWidget,
          reason: 'the middle tier has collapsed back into the binary');
      // Still no prediction, though.
      expect(TtcStore.instance.today.fertility, isNull);
    });

    testWidgets('a natural path is untouched', (tester) async {
      seedDay13();
      await pumpTall(tester, const TtcFertilityWindowScreen());
      expect(find.text(TtcStore.instance.ownership.title(false)), findsNothing);
      expect(find.text('Ovulation'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('S9.4 - the splash routes by life stage', () {
    final splash = File('lib/screens/splash_screen.dart').readAsStringSync();

    test('it reads the life stage from prefs, not the async store', () {
      // LifeStageStore loads asynchronously from its constructor, so reading
      // `stage` at splash time would often be null and send her to the wrong
      // home.
      expect(splash.contains('LifeStageStore.kLifeStageKey'), isTrue);
    });

    test('"trying" boots into the TTC stage', () {
      expect(splash.contains('LifeStage.tryingToConceive.id'), isTrue);
      expect(splash.contains('_ttcRoute()'), isTrue);
    });

    test('the TTC route is named so the Ask Veda FAB knows the stage', () {
      // Without the name the FAB opens the pregnancy Ask Veda and answers her
      // with a week number.
      expect(splash.contains('RouteSettings(name: ttcHomeRoute)'), isTrue);
    });

    test('a paired father still gets his own shell first', () {
      expect(splash.contains("role != 'father' &&"), isTrue,
          reason: 'a father declaring "trying" would lose his Slate shell');
    });

    test('the id written by auth is the id the splash matches on', () {
      // Two ends of the same string; a rename on either side would silently
      // stop routing anyone.
      expect(LifeStage.tryingToConceive.id, 'trying');
      LifeStageStore.instance.setStageId('trying');
      expect(LifeStageStore.instance.stage, LifeStage.tryingToConceive);
    });

    testWidgets('the TTC shell marks the app live, so the FAB can appear',
        (tester) async {
      // Booting straight to TTC skips MainScaffold, which is normally the only
      // thing that does this.
      final source =
          File('lib/screens/ttc/ttc_common.dart').readAsStringSync();
      expect(source.contains('markAppLive'), isTrue,
          reason: 'a TTC user booted by the splash would never see the FAB');
    });
  });

  // ===========================================================================
  group('S9.3 - she can write a post', () {
    testWidgets('the feed offers a way in', (tester) async {
      await pumpTall(tester, const TtcCommunityScreen());
      expect(find.text(const TtcS(false).communityWrite), findsOneWidget);
    });

    test('a TTC post goes through the SHARED store', () {
      final store = CommunityStore.instance;
      final before = store.createdPosts.length;
      store.addPost(const CommunityPost(
        id: 'ttcuser_test1',
        communityId: 'ttc_loss',
        author: 'Anonymous',
        authorEmoji: '',
        text: 'testing',
        type: PostType.experience,
        stage: 'Trying',
        isUser: true,
      ));
      expect(store.createdPosts.length, before + 1);
      // Same list the other two stages read from - one social layer.
      expect(store.createdPosts.first.stage, 'Trying');
    });

    testWidgets('her own post appears in the TTC feed', (tester) async {
      CommunityStore.instance.addPost(const CommunityPost(
        id: 'ttcuser_test2',
        communityId: 'ttc_naturally',
        author: 'You',
        authorEmoji: '',
        text: 'A post I wrote myself',
        type: PostType.experience,
        stage: 'Trying',
        isUser: true,
      ));
      await pumpTall(tester, const TtcCommunityScreen());
      expect(find.text('A post I wrote myself'), findsOneWidget);
    });

    test('anonymity is offered - this stage needs it', () {
      // The seeded Loss & Recovery post is signed "Anonymous" for a reason. A
      // feed that forces a name on those posts simply does not get them.
      final source =
          File('lib/screens/ttc/ttc_community_screen.dart').readAsStringSync();
      expect(source.contains('communityAnonymous'), isTrue);
      expect(source.contains("'Anonymous'"), isTrue);
    });

    test('a post from another stage does not leak into the TTC feed', () {
      CommunityStore.instance.addPost(const CommunityPost(
        id: 'ppuser_test3',
        communityId: 'baby_sleep', // a PARENTING room
        author: 'You',
        authorEmoji: '',
        text: 'parenting post',
        type: PostType.experience,
        stage: 'Parenting',
        isUser: true,
      ));
      final ttcVisible = CommunityStore.instance.createdPosts
          .where((p) => kTtcCommunityIds.contains(p.communityId));
      expect(ttcVisible.any((p) => p.id == 'ppuser_test3'), isFalse);
    });
  });

  // ===========================================================================
  group('S9.2 - Ask Veda deep-links land on the item', () {
    testWidgets('a test pointer opens that test expanded', (tester) async {
      await pumpTall(tester, const TtcTestsScreen(focusId: 'amh'));
      final amh = ttcTestById('amh')!;
      // The expanded half is on screen, not just the title.
      expect(find.text(amh.reading(false)), findsOneWidget);
    });

    testWidgets("a pointer at one of HIS tests flips the segment",
        (tester) async {
      // Otherwise the card being scrolled to is not rendered at all.
      await pumpTall(tester, const TtcTestsScreen(focusId: 'semen'));
      expect(find.text('Semen analysis'), findsOneWidget);
      expect(find.text(ttcTestById('semen')!.reading(false)), findsOneWidget);
    });

    testWidgets('a Can I pointer opens that answer expanded', (tester) async {
      await pumpTall(tester, const TtcCanIScreen(focusId: 'papaya'));
      expect(find.text(ttcCanIById('papaya')!.why(false)), findsOneWidget);
    });

    testWidgets('the rest of the library still renders', (tester) async {
      // A research page that narrows to the one pointed-at item starts to look
      // like a shop.
      await pumpTall(tester, const TtcCanIScreen(focusId: 'papaya'));
      expect(find.text(ttcCanIById('chai')!.question(false)), findsOneWidget);
    });

    testWidgets('a product pointer highlights without reordering',
        (tester) async {
      await pumpTall(tester, const TtcProductsScreen(focusId: 'folic'));
      expect(tester.takeException(), isNull);
      // Every other product is still there.
      for (final p in ttcProducts.take(4)) {
        expect(find.text(p.name(false)), findsWidgets, reason: p.id);
      }
    });

    testWidgets('an unknown id degrades to the plain library', (tester) async {
      await pumpTall(tester, const TtcTestsScreen(focusId: 'not_a_test'));
      expect(tester.takeException(), isNull);
      expect(find.text('AMH'), findsOneWidget);
    });

    test('the Ask Veda screen strips the prefix before passing the id', () {
      final source =
          File('lib/screens/ttc/ttc_askveda_screen.dart').readAsStringSync();
      for (final prefix in ['ttctest_', 'ttccani_', 'ttcprod_']) {
        expect(source.contains("focusId: id.substring('$prefix'.length)"),
            isTrue,
            reason: '$prefix pointers would open the library unfocused');
      }
    });
  });
}
