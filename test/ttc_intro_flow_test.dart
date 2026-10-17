// =============================================================================
//  The TTC first-run flow
// -----------------------------------------------------------------------------
//  ⚠️ THE POINT OF THIS FILE IS THE WIRING GATE, NOT THE WIDGETS. A first-run
//  flow is the single easiest thing in an app to build correctly and never
//  show: it renders once, on a state most developers have already passed
//  through, so a broken gate looks exactly like a working one from the second
//  launch onward.
//
//  So the first two tests do not look at the flow at all. They ask whether
//  `TtcHomeScreen` — the thing every route into the stage actually pushes —
//  puts it on screen, and whether it stops doing so afterwards.
//
//  ⚠️ AND THE ANSWERS HAVE TO LAND SOMEWHERE. Three questions that write
//  nothing are three screens of friction, so each one is checked against the
//  store it claims to feed rather than against its own widget.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/hubs/parenting_hubs.dart';
import 'package:parentveda/data/hubs/pregnancy_hubs.dart';
import 'package:parentveda/data/hubs/ttc_hubs.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_intro_flow.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TtcIntroGate.resetForTest();
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  Future<void> pumpStageEntry(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: TtcHomeScreen()));
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ===========================================================================
  //  ⚠️ THE FILM ONLY, SINCE ONBOARDING V3 (2026-10-17). Onboarding now asks
  //  where she is, her last period and how long, once, and writes the same
  //  stores; the language question went on the user's word ("NO LANGUAGE
  //  QUES!"). These tests used to walk language → film → three questions.
  //  Kept for revert in git history (the pre-V3 version of this file).
  group('the gate', () {
    testWidgets('a first arrival in the stage gets the introduction',
        (tester) async {
      await pumpStageEntry(tester);
      expect(find.text(const TtcS(false).introVideoTitle), findsOneWidget,
          reason: 'the first-run flow is built but nothing shows it');
      expect(find.text(const TtcS(false).introLanguageTitle), findsNothing,
          reason: 'no language question (2026-10-17)');
    });

    testWidgets('and a later arrival goes straight to the home',
        (tester) async {
      await TtcIntroGate.markSeen();
      await pumpStageEntry(tester);
      expect(find.text(const TtcS(false).introVideoTitle), findsNothing);
    });

    testWidgets('skipping still counts as seen — it never asks twice',
        (tester) async {
      await pumpStageEntry(tester);
      await tester.tap(find.text(const TtcS(false).introSkip));
      await tester.pump(const Duration(milliseconds: 300));

      expect(await TtcIntroGate.owed(), isFalse,
          reason: 'a skipped introduction would return on every launch');
    });
  });

  // ===========================================================================
  group('the film is the whole introduction', () {
    testWidgets('it can be left, and finishing it asks nothing', (tester) async {
      final t = const TtcS(false);
      await pumpStageEntry(tester);
      expect(find.text(t.introSkip), findsOneWidget);
      await tester.tap(find.text(t.introContinue));
      await tester.pump(const Duration(milliseconds: 400));

      // None of the old questions follow the film any more.
      expect(find.text(t.introPeriodTitle), findsNothing);
      expect(find.text(t.introTryingTitle), findsNothing);
      expect(find.text(t.introPathTitle), findsNothing);
      expect(await TtcIntroGate.owed(), isFalse);
      // ⚠️ NOTHING INVENTED FROM SILENCE.
      expect(CycleStore.instance.periodStarts, isEmpty);
    });
  });

  // ===========================================================================
  //  The answers still reach the engines — from onboarding now
  // ---------------------------------------------------------------------------
  group('the answers onboarding asks are read by something', () {
    test('onboarding writes the period, the path and the journey start', () {
      final src = File('lib/screens/auth/onboarding/onboarding_flow.dart')
          .readAsStringSync();
      expect(src, contains('CycleStore.instance.logPeriodStart('));
      expect(src, contains('ttc.setPath('));
      expect(src, contains('ttc.setJourneyStart('));
      expect(src, contains('plan.setPlannedStart('));
    });

    testWidgets('the pathway answer reaches TimingOwnership', (tester) async {
      TtcStore.instance.setPath(TtcPath.ivf);

      // ⚠️ THE ONE ANSWER WITH REAL TEETH. A clinic owns the timing only with
      // a real date from her clinic for this cycle (2026-09-26), never on the
      // pathway label alone.
      expect(TtcStore.instance.path, TtcPath.ivf);
      expect(TtcStore.instance.pathway.ownership,
          TimingOwnership.clinicControlled);
      expect(TtcStore.instance.today.clinicInvolved, isFalse);
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      expect(TtcStore.instance.today.clinicInvolved, isTrue);
      expect(TtcStore.instance.today.behaviour.showsFertilityWindow, isFalse,
          reason: 'a clinic-run cycle must not get an app-made window');
    });

    test('the how-long answer anchors mid-band, the same in both places', () {
      // Nine months for "six months to a year": the readiness rules raise
      // seeking help at twelve months, so the bottom of a band delays that
      // by half a year and the top brings it forward by the same.
      expect(TtcTryingFor.sixToTwelve.approxMonths, 9);
      expect(TtcTryingFor.upToSix.approxMonths, 3);
      expect(TtcTryingFor.justStarted.approxMonths, 0);
      expect(TtcTryingFor.overAYear.approxMonths, 18);
      final src = File('lib/screens/auth/onboarding/onboarding_flow.dart')
          .readAsStringSync();
      expect(src, contains("{'starting': 0, 'months': 3, 'six': 9, 'year': 18}"),
          reason: "onboarding's bands are the intro's");
    });
  });

  _hubVideoTests();
}

// =============================================================================
//  The video at the top of each door screen
// -----------------------------------------------------------------------------
//  ⚠️ ASSERTED AGAINST THE CONFIGS, NOT A PUMPED SCREEN, because the failure
//  this guards is a data omission: a hub added later with no slot renders the
//  old support line and looks completely fine. Nobody notices one hub out of
//  eight has no film until someone opens all eight side by side.
//
//  ⚠️ AND IT ASSERTS THE OTHER TWO STAGES ARE UNTOUCHED. The whole argument for
//  making this a `HubConfig` field rather than a flag on `ProblemHubScreen` was
//  that pregnancy and parenting render exactly what they rendered before. That
//  is a claim, so it gets a test.
// =============================================================================

void _hubVideoTests() {
  group('the door screens carry a video slot', () {
    test('every TTC hub declares one', () {
      for (final hub in kTtcHubs) {
        expect(hub.heroVideoSlot, isNotNull,
            reason: '${hub.bracketId} has no film slot, so its door screen '
                'still opens on the old support line');
        expect(hub.heroVideoSlot, isNotEmpty);
      }
    });

    test('and the ids are unique, so two doors cannot share a film', () {
      final ids = kTtcHubs.map((h) => h.heroVideoSlot).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('pregnancy and parenting are untouched', () {
      // ⚠️ THE POINT OF THE FIELD. If either of these ever becomes non-null by
      // accident, two other stages silently grow a video header nobody
      // commissioned — and the content bill triples.
      for (final hub in [...kPregnancyHubs, ...kParentingHubs]) {
        expect(hub.heroVideoSlot, isNull,
            reason: '${hub.bracketId} grew a video slot it never asked for');
      }
    });
  });
}
