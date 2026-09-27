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
  group('the gate', () {
    testWidgets('a first arrival in the stage gets the introduction',
        (tester) async {
      await pumpStageEntry(tester);
      expect(find.text(const TtcS(false).introLanguageTitle), findsOneWidget,
          reason: 'the first-run flow is built but nothing shows it');
    });

    testWidgets('and a later arrival goes straight to the home',
        (tester) async {
      await TtcIntroGate.markSeen();
      await pumpStageEntry(tester);
      expect(find.text(const TtcS(false).introLanguageTitle), findsNothing);
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
  group('every step can be left', () {
    testWidgets('skip is on the language step, the video and all three questions',
        (tester) async {
      final t = const TtcS(false);
      await pumpStageEntry(tester);

      // Walk the whole flow, asserting the escape exists at each stop. A skip
      // that only appears on the screens we do not mind losing is a funnel,
      // not an escape.
      expect(find.text(t.introSkip), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(t.introVideoTitle), findsOneWidget);
      expect(find.text(t.introSkip), findsOneWidget);

      await tester.tap(find.text(t.introContinue));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(t.introPeriodTitle), findsOneWidget);
      expect(find.text(t.introSkip), findsOneWidget);

      // "I don't know" is a real answer here, not a skip — see the note on the
      // step. It moves on without writing a guessed date.
      await tester.tap(find.text(t.introDontKnow));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(t.introTryingTitle), findsOneWidget);

      await tester.tap(find.text(t.introRatherNotSay));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(t.introPathTitle), findsOneWidget);
      expect(find.text(t.introSkip), findsOneWidget);
    });

    testWidgets('and declining every question leaves the stage unconfigured',
        (tester) async {
      final t = const TtcS(false);
      await pumpStageEntry(tester);

      await tester.tap(find.text('English'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(t.introContinue));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(t.introDontKnow));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(t.introRatherNotSay));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(t.introRatherNotSay));
      await tester.pump(const Duration(milliseconds: 400));

      // ⚠️ NOTHING INVENTED FROM SILENCE. A guessed period start is worse than
      // none: with no date the engine refuses to estimate and says so; with a
      // wrong one it estimates confidently and is wrong everywhere at once.
      expect(CycleStore.instance.periodStarts, isEmpty);
      expect(find.text(t.introPathTitle), findsNothing,
          reason: 'the flow did not finish');
    });
  });

  // ===========================================================================
  //  The answers reach the engines
  // ---------------------------------------------------------------------------
  //  Three questions instead of the reference app's seventeen, and the whole
  //  justification for each is that something concrete reads it. These assert
  //  that claim rather than trusting it.
  group('the three answers are read by something', () {
    testWidgets('the pathway answer reaches TimingOwnership', (tester) async {
      final t = const TtcS(false);
      await pumpStageEntry(tester);

      await tester.tap(find.text('English'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(t.introContinue));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(t.introDontKnow));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(t.introRatherNotSay));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text(TtcPath.ivf.label(false)));
      await tester.pump(const Duration(milliseconds: 400));

      // ⚠️ THE ONE ANSWER WITH REAL TEETH. It decides whether the app may
      // generate a fertile window at all — a woman on IVF shown an ovulation
      // estimate is being handed a second opinion against a clinician who
      // outranks our calculation by six places in the truth hierarchy.
      //
      // ⚠️ 2026-09-26, THE USER'S DECISION: the answer sets the pathway (and
      // with it the tier), and the first date her clinic gives her for this
      // cycle hands the timing over. The label alone is her own cycle. Kept
      // for revert: the two expectations below held straight after the tap.
      expect(TtcStore.instance.path, TtcPath.ivf);
      expect(TtcStore.instance.pathway.ownership,
          TimingOwnership.clinicControlled);
      expect(TtcStore.instance.today.clinicInvolved, isFalse);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      expect(TtcStore.instance.today.clinicInvolved, isTrue);
      expect(TtcStore.instance.today.behaviour.showsFertilityWindow, isFalse,
          reason: 'a clinic-run cycle must not get an app-made window');
    });

    testWidgets('the how-long answer anchors mid-band, not at an edge',
        (tester) async {
      // Nine months for "six months to a year". The readiness rules raise
      // seeking help at twelve months, so anchoring at the bottom of a band
      // delays that by half a year and the top brings it forward by the same —
      // and she is never told which the app picked.
      expect(TtcTryingFor.sixToTwelve.approxMonths, 9);
      expect(TtcTryingFor.upToSix.approxMonths, 3);
      expect(TtcTryingFor.justStarted.approxMonths, 0);
    });

    testWidgets('and every option carries copy in both languages',
        (tester) async {
      for (final option in TtcTryingFor.values) {
        expect(option.label(false), isNotEmpty);
        expect(option.label(true), isNotEmpty);
      }
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
