// =============================================================================
//  P4 birth prep: the contraction timer's clinical rules, its running
//  session, and the timer after a loss (2026-10-28).
// -----------------------------------------------------------------------------
//  docs/preg-ttc-tool-plans/P4-birth-prep.md, findings C1-C9 and "Clinical
//  calls". Each number these tests lean on is a named const in
//  `contraction_tracker_screen.dart` with a BEFORE-LAUNCH clinician CHECK.
//
//  What this holds:
//    · C1 before 37 weeks, 4 contractions in 20 minutes is "call now",
//      whatever the pattern, and the standing line is on the page;
//    · C2 "not sure" counts as yes for waters and movements, and light
//      bleeding before 37 weeks is "call now";
//    · C3 the reading comes from the last hour only; a first baby holds the
//      5-1-1 pattern for that hour, a later baby (a child on her profile)
//      does not wait for it;
//    · C4 a running session comes back within 2 hours, a contraction in
//      progress included, and an older one does not;
//    · C5 under 5 seconds is not kept, and "take back" has its Undo;
//    · C6 the copied summary is the real last hour, or says "This session";
//    · after a loss the note shows, the movement question goes, and nothing
//      reads the pattern as labour.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/tools/contraction_tracker_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/services/tools_store.dart';

final DateTime _t0 = DateTime(2026, 10, 28, 3, 0);

Contraction _c(int start, int dur, int interval) => Contraction(
  startIso: _t0.add(Duration(seconds: start)).toIso8601String(),
  endIso: _t0.add(Duration(seconds: start + dur)).toIso8601String(),
  durationSeconds: dur,
  intervalSeconds: interval,
);

/// [n] contractions [every] seconds apart, [dur] long, from [from].
List<Contraction> _run(
  int n,
  int every,
  int dur, {
  int from = 0,
  int firstGap = 0,
}) => [
  for (var i = 0; i < n; i++)
    _c(from + i * every, dur, i == 0 ? firstGap : every),
];

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const clear = ContractionSymptoms();
  final s = S(AppLanguage.english);

  group('C1: before 37 weeks', () {
    test(
      '4 contractions in 20 minutes at week 32 is preterm, pattern or not',
      () {
        final four = _run(
          4,
          300,
          30,
        ); // 15 minutes, short, too few for a pattern
        expect(classifyContractions(four), isNot(LaborState.laborLikely));
        expect(assessContractions(four, 32, clear), AssessLevel.preterm);
        // At term the same four are no reason to call.
        expect(assessContractions(four, 39, clear), isNot(AssessLevel.preterm));
      },
    );

    test('8 in 60 minutes is preterm; 3 in 20 is not', () {
      expect(pretermFrequencyMet(_run(8, 480, 30)), isTrue); // 56 minutes
      expect(pretermFrequencyMet(_run(3, 300, 30)), isFalse);
      expect(pretermFrequencyMet(_run(4, 420, 30)), isFalse); // 21 minutes
      expect(
        assessContractions(_run(3, 300, 30), 32, clear),
        AssessLevel.noPattern,
      );
    });

    test('the numbers are named, each with its clinician check', () {
      final src = File(
        'lib/screens/tools/contraction_tracker_screen.dart',
      ).readAsStringSync();
      expect(kCtPretermBeforeWeek, 37);
      expect(kCtPretermShortCount, 4);
      expect(kCtPretermShortWindow, const Duration(minutes: 20));
      expect(kCtPretermLongCount, 8);
      expect(kCtPretermLongWindow, const Duration(minutes: 60));
      expect(
        'BEFORE-LAUNCH clinician CHECK'.allMatches(src).length,
        greaterThanOrEqualTo(6),
      );
    });
  });

  group('C2: not sure counts as yes', () {
    final none = <Contraction>[];
    test('waters not sure escalates, like yes', () {
      expect(
        assessContractions(
          none,
          39,
          const ContractionSymptoms(waterBroken: 'unsure'),
        ),
        AssessLevel.callNow,
      );
      expect(
        assessContractions(
          none,
          39,
          const ContractionSymptoms(waterBroken: 'yes'),
        ),
        AssessLevel.callNow,
      );
    });

    test('movements not sure escalates, like yes', () {
      expect(
        assessContractions(
          none,
          39,
          const ContractionSymptoms(movementReduced: 'unsure'),
        ),
        AssessLevel.callNow,
      );
      expect(
        assessContractions(
          none,
          39,
          const ContractionSymptoms(movementReduced: 'yes'),
        ),
        AssessLevel.callNow,
      );
    });

    test(
      'light bleeding is call now before 37 weeks, heavy is the emergency',
      () {
        const light = ContractionSymptoms(bleeding: 'light');
        expect(assessContractions(none, 32, light), AssessLevel.callNow);
        expect(assessContractions(none, 39, light), AssessLevel.insufficient);
        expect(
          assessContractions(
            none,
            39,
            const ContractionSymptoms(bleeding: 'heavy'),
          ),
          AssessLevel.emergency,
        );
        expect(
          assessContractions(
            none,
            39,
            const ContractionSymptoms(severePain: 'yes'),
          ),
          AssessLevel.emergency,
        );
      },
    );

    test('the reading says what to do, in words of its own', () {
      expect(s.assessTitle('callNow'), 'Call your maternity unit now');
      expect(s.assessTitle('callNow'), isNot(s.assessTitle('emergency')));
    });
  });

  group('C3: time to call, from the last hour', () {
    // Six contractions 5 minutes apart, a minute long: 26 minutes of timing.
    final halfHour = _run(6, 300, 60);

    test(
      'first baby: the 5-1 pattern for only half an hour is not the call',
      () {
        expect(classifyContractions(halfHour), isNot(LaborState.activeLabor));
        expect(
          assessContractions(halfHour, 39, clear),
          isNot(AssessLevel.activeLabor),
        );
      },
    );

    test('later baby: the same half hour is the call', () {
      expect(
        classifyContractions(halfHour, laterBaby: true),
        LaborState.activeLabor,
      );
      expect(
        assessContractions(halfHour, 39, clear, laterBaby: true),
        AssessLevel.activeLabor,
      );
    });

    test('first baby: held for the hour, it is the call', () {
      expect(classifyContractions(_run(13, 300, 60)), LaborState.activeLabor);
    });

    test('the n >= 8 shortcut is gone: 8 in 35 minutes is not an hour', () {
      expect(
        classifyContractions(_run(8, 300, 60)),
        isNot(LaborState.activeLabor),
      );
    });

    test('a scattered start no longer waters down a regular last hour', () {
      // Two hours of contractions 20 minutes apart, then an hour of 5-1.
      final scattered = _run(6, 1200, 40);
      final regular = _run(13, 300, 60, from: 6300, firstGap: 300);
      final session = [...scattered, ...regular];
      // The old whole-session average: about 9 minutes apart.
      final ints = [
        for (final c in session)
          if (c.intervalSeconds > 0) c.intervalSeconds,
      ];
      expect(ints.reduce((a, b) => a + b) / ints.length, greaterThan(300));
      // The reading only looks at the last hour.
      expect(contractionsInLastHour(session).every(regular.contains), isTrue);
      expect(classifyContractions(session), LaborState.activeLabor);
    });

    test('the levels are actions, not a diagnosis', () {
      for (final key in ['active', 'activeLater', 'likely', 'early']) {
        expect(
          s.assessTitle(key).toLowerCase(),
          isNot(contains('labour likely')),
        );
        expect(
          s.assessTitle(key).toLowerCase(),
          isNot(contains('active labour')),
        );
      }
      expect(
        s.assessTitle('active'),
        'This is the pattern hospitals ask you to call about',
      );
      expect(
        s.ctFollowHospital,
        'Your hospital may have told you something different. Follow them.',
      );
    });
  });

  group('C6: the copied summary', () {
    test(
      'under an hour it says "This session", with her week and symptoms',
      () {
        final text = contractionSummaryText(
          s,
          _run(4, 300, 45),
          week: 38,
          symptoms: const ContractionSymptoms(waterBroken: 'unsure'),
        );
        expect(text, startsWith('${s.thisSessionContractions}:\n4 '));
        expect(text, contains('${s.ctSummaryWeek}: 38.'));
        expect(text, contains(s.ctSymWaters));
      },
    );

    test('over an hour it is the real last hour', () {
      final session = [
        ..._run(6, 1200, 40),
        ..._run(13, 300, 60, from: 6300, firstGap: 300),
      ];
      final text = contractionSummaryText(s, session, week: 39);
      final lastHour = contractionsInLastHour(session).length;
      expect(lastHour, lessThan(session.length));
      expect(text, startsWith('${s.lastHourLabel}:\n$lastHour '));
      expect(
        text,
        contains('${s.ctSummarySymptoms}: ${s.ctSummaryNoSymptoms}.'),
      );
    });

    test('after a loss: no week, no baby', () {
      final text = contractionSummaryText(
        s,
        _run(4, 300, 45),
        week: 30,
        afterLoss: true,
        symptoms: const ContractionSymptoms(movementReduced: 'yes'),
      );
      expect(text, isNot(contains(s.ctSummaryWeek)));
      expect(text, isNot(contains(s.ctSymMovement)));
    });
  });

  group('after a loss: the engine', () {
    test('no preterm, no labour, and movements are not asked about', () {
      final halfHour = _run(13, 300, 60);
      expect(
        assessContractions(halfHour, 30, clear, afterLoss: true),
        AssessLevel.timingOnly,
      );
      expect(
        assessContractions(
          halfHour,
          30,
          const ContractionSymptoms(movementReduced: 'yes'),
          afterLoss: true,
        ),
        AssessLevel.timingOnly,
      );
      // Bleeding heavy is still the emergency.
      expect(
        assessContractions(
          halfHour,
          30,
          const ContractionSymptoms(bleeding: 'heavy'),
          afterLoss: true,
        ),
        AssessLevel.emergency,
      );
    });
  });

  // ---- the screen ------------------------------------------------------------

  group('the screen', () {
    late PregnancyController c;
    late PregnancyController c38;
    late PregnancyController c32;
    var now = DateTime(2026, 10, 28, 3, 0);

    // Each controller loads from its own empty storage: `load()` keeps what
    // it finds, so a second one would read the first one's state.
    Future<PregnancyController> weeksToGo(int w) async {
      SharedPreferences.setMockInitialValues({});
      final p = PregnancyController(
        dueDate: DateTime.now().add(Duration(days: w * 7 + 1)),
      );
      await p.load();
      return p;
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      PregnancyEndedStore.instance.resetForTest();
      now = DateTime(2026, 10, 28, 3, 0);
      contractionClock = () => now;
      c32 = await weeksToGo(8);
      c38 = await weeksToGo(2);
      SharedPreferences.setMockInitialValues({});
      c = c38;
    });

    tearDown(() {
      contractionClock = DateTime.now;
      PregnancyEndedStore.instance.resetForTest();
    });

    Future<void> pump(WidgetTester t) async {
      t.view.physicalSize = const Size(900, 2800);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(home: ContractionTrackerScreen(controller: c)),
      );
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
    }

    Future<void> wait(WidgetTester t, int secs) async {
      now = now.add(Duration(seconds: secs));
      await t.pump(Duration(seconds: secs));
    }

    /// Close the screen and let any notice run out, so no timer outlives
    /// the test.
    Future<void> done(WidgetTester t) async {
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 6));
    }

    Future<void> seedLive(Map<String, Object?> live) async {
      SharedPreferences.setMockInitialValues({
        ToolsStore.contractionLiveKey: jsonEncode(live),
      });
    }

    testWidgets('C1: the standing line shows before 37 weeks, not after', (
      t,
    ) async {
      c = c32;
      expect(c.currentWeek, 32);
      await pump(t);
      expect(find.byKey(const ValueKey('ct_preterm_line')), findsOneWidget);
      expect(find.text(s.ctPretermLine), findsOneWidget);
      await done(t);

      c = c38;
      expect(c.currentWeek, 38);
      await pump(t);
      expect(find.byKey(const ValueKey('ct_preterm_line')), findsNothing);
      await done(t);
    });

    testWidgets(
      'C5: a contraction under 5 seconds is not kept, and she is told',
      (t) async {
        await pump(t);
        await t.tap(find.byKey(const ValueKey('ct_disc_home')));
        await wait(t, 3);
        await t.tap(find.byKey(const ValueKey('ct_disc_active')));
        await t.pump();
        await t.pump(const Duration(milliseconds: 300));
        expect(find.text(s.ctUnderMinimum), findsOneWidget);
        // Back at the start: nothing was kept.
        expect(find.byKey(const ValueKey('ct_disc_home')), findsOneWidget);
        expect(find.byKey(const ValueKey('ct_charts')), findsNothing);
        await done(t);
      },
    );

    testWidgets('C5: take back the last one, and Undo puts it back', (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('ct_disc_home')));
      await wait(t, 40);
      await t.tap(find.byKey(const ValueKey('ct_disc_active')));
      await wait(t, 1);
      expect(find.byKey(const ValueKey('ct_disc_rest')), findsOneWidget);
      await t.ensureVisible(find.byKey(const ValueKey('ct_take_back')));
      await t.tap(find.byKey(const ValueKey('ct_take_back')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text(s.ctTookBack), findsOneWidget);
      expect(find.byKey(const ValueKey('ct_disc_home')), findsOneWidget);
      await t.tap(find.text(s.ctUndo));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('ct_disc_rest')), findsOneWidget);
      await done(t);
    });

    testWidgets('C4: a session left within 2 hours is picked up again', (
      t,
    ) async {
      final start = now.subtract(const Duration(minutes: 30));
      await seedLive({
        'sessionId': 'ct_resume',
        'contractions': [
          Contraction(
            startIso: start.toIso8601String(),
            endIso: start.add(const Duration(seconds: 50)).toIso8601String(),
            durationSeconds: 50,
            intervalSeconds: 0,
          ).toJson(),
        ],
      });
      await pump(t);
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const ValueKey('ct_disc_rest')), findsOneWidget);
      expect(find.text(s.ctPickedUp), findsOneWidget);
      await done(t);
    });

    testWidgets(
      'C4: a contraction in progress when she left is still running',
      (t) async {
        await seedLive({
          'sessionId': 'ct_mid',
          'contractions': [],
          'activeStartIso': now
              .subtract(const Duration(seconds: 20))
              .toIso8601String(),
        });
        await pump(t);
        await t.pump(const Duration(milliseconds: 100));
        expect(find.byKey(const ValueKey('ct_disc_active')), findsOneWidget);
        expect(find.text('00:20'), findsOneWidget);
        await done(t);
      },
    );

    testWidgets('C4: older than 2 hours starts fresh, and is let go', (
      t,
    ) async {
      final start = now.subtract(const Duration(hours: 3));
      await seedLive({
        'sessionId': 'ct_stale',
        'contractions': [
          Contraction(
            startIso: start.toIso8601String(),
            endIso: start.add(const Duration(seconds: 50)).toIso8601String(),
            durationSeconds: 50,
            intervalSeconds: 0,
          ).toJson(),
        ],
      });
      await pump(t);
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const ValueKey('ct_disc_home')), findsOneWidget);
      expect(find.text(s.ctPickedUp), findsNothing);
      expect(await ToolsStore.instance.loadLiveContraction(), isNull);
      await done(t);
    });

    testWidgets('C4 + C8: End session lets it go, and says where it went', (
      t,
    ) async {
      await t.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () => Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => ContractionTrackerScreen(controller: c),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      t.view.physicalSize = const Size(900, 2800);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('ct_disc_home')));
      await wait(t, 40);
      await t.tap(find.byKey(const ValueKey('ct_disc_active')));
      await wait(t, 1);
      expect(await ToolsStore.instance.loadLiveContraction(), isNotNull);
      await t.ensureVisible(find.byKey(const ValueKey('ct_end_session')));
      await t.tap(find.byKey(const ValueKey('ct_end_session')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text(s.ctSavedToHistory), findsOneWidget);
      expect(await ToolsStore.instance.loadLiveContraction(), isNull);
      await done(t);
    });

    testWidgets('C4: starting a contraction puts it on the phone at once', (
      t,
    ) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('ct_disc_home')));
      await t.pump();
      final live = await ToolsStore.instance.loadLiveContraction();
      expect(live, isNotNull);
      expect(live!.activeStartIso, now.toIso8601String());
      await done(t);
    });

    testWidgets('after a loss: the note shows, Get ready and the movement '
        'question go, the timer works', (t) async {
      await PregnancyEndedStore.instance.markEnded();
      c = c32; // week 32: no preterm line after a loss either
      await pump(t);
      expect(
        find.byKey(const ValueKey('preg_after_loss_note')),
        findsOneWidget,
      );
      expect(find.text(kCtAfterLossNote), findsOneWidget);
      expect(find.text('GET READY'), findsNothing);
      expect(find.byKey(const ValueKey('ct_preterm_line')), findsNothing);
      expect(find.byKey(const ValueKey('ct_call_earlier')), findsNothing);

      await t.ensureVisible(find.text(s.safetyUpdate));
      await t.tap(find.text(s.safetyUpdate));
      await t.pumpAndSettle();
      expect(find.text(s.qWaterBroken), findsOneWidget);
      expect(find.text(s.qMovementReduced), findsNothing);
      await t.tap(find.text(s.doneWord));
      await t.pumpAndSettle();

      // The timer itself still works.
      await t.tap(find.byKey(const ValueKey('ct_disc_home')));
      await wait(t, 40);
      await t.tap(find.byKey(const ValueKey('ct_disc_active')));
      await wait(t, 1);
      expect(find.byKey(const ValueKey('ct_disc_rest')), findsOneWidget);
      await done(t);
    });

    testWidgets('C2: waters not sure asks their colour', (t) async {
      await pump(t);
      await t.ensureVisible(find.text(s.safetyUpdate));
      await t.tap(find.text(s.safetyUpdate));
      await t.pumpAndSettle();
      expect(find.text(s.qWatersColour), findsNothing);
      await t.tap(find.text(s.optNotSure).first);
      await t.pump();
      expect(find.text(s.qWatersColour), findsOneWidget);
      expect(find.text(s.watersDark), findsOneWidget);
      await t.tap(find.text(s.doneWord));
      await t.pumpAndSettle();
      expect(find.text(s.assessTitle('callNow')), findsOneWidget);
      await done(t);
    });
  });

  group('store: delete and restore travel', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('a deleted session comes back on Undo, same id', () async {
      final store = ToolsStore.instance;
      await store.init();
      final session = ContractionSession(
        id: 'ct_del_${DateTime.now().microsecondsSinceEpoch}',
        dateIso: _t0.toIso8601String(),
        contractions: _run(3, 300, 50),
      );
      await store.saveContractionSession(session);
      expect(store.hasContractionSession(session.id), isTrue);
      final gone = await store.deleteContractionSession(session.id);
      expect(gone?.id, session.id);
      expect(store.hasContractionSession(session.id), isFalse);
      await store.restoreContractionSession(gone!);
      expect(store.hasContractionSession(session.id), isTrue);
    });

    test('deleting the running session lets the running copy go too', () async {
      final store = ToolsStore.instance;
      await store.init();
      final id = 'ct_live_${DateTime.now().microsecondsSinceEpoch}';
      await store.saveContractionSession(
        ContractionSession(
          id: id,
          dateIso: _t0.toIso8601String(),
          contractions: _run(1, 0, 50),
        ),
      );
      await store.saveLiveContraction(
        LiveContractionState(sessionId: id, contractions: _run(1, 0, 50)),
      );
      await store.deleteContractionSession(id);
      expect(await store.loadLiveContraction(), isNull);
    });

    test('the soft delete uses the ledger, the way a kick session does', () {
      final src = _code('lib/services/tools_store.dart');
      final at = src.indexOf('deleteContractionSession(String id)');
      final body = src.substring(at, src.indexOf('\n  }', at));
      expect(body, contains('_ctSync.remove(id, _contractionToRow(gone))'));
      expect(body, contains('_ctSync.push(_ctRows)'));
    });
  });

  group('wiring', () {
    final src = _code('lib/screens/tools/contraction_tracker_screen.dart');

    test('the screen keeps itself awake while timing, and lets go', () {
      expect(src, contains('WakelockPlus.enable()'));
      expect(src, contains('WakelockPlus.disable()'));
      expect(src, contains('_keepAwake(false);'));
    });

    test('father preview asks how she is feeling', () {
      expect(src, contains('FatherPreview.instance.on'));
      expect(src, contains('s.laborPromptBodyPartner'));
      expect(s.laborPromptBodyPartner, contains('How is she feeling?'));
    });

    test('the call-earlier line opens the Labour read', () {
      expect(src, contains('openPvDoorRead(context, kCtWhenToGoReadId'));
      expect(
        File('lib/data/doors/pv_door_labour.dart').readAsStringSync(),
        contains("'$kCtWhenToGoReadId'"),
      );
    });

    test('later baby is derived from a child on her profile, never asked', () {
      expect(src, contains('ChildProfileStore.instance.hasRealChild'));
    });

    test('one name, no Hinglish, no emoji in the timer toasts', () {
      expect(s.contractionToolTitle, 'Contraction timer');
      expect(s.toolContractionTitle, s.contractionToolTitle);
      expect(src, isNot(contains("'Awaaz on karein'")));
      expect(s.summaryCopied, isNot(contains('💜')));
      expect(s.laborSavedNote, isNot(contains('💜')));
    });

    test('End session says where it went', () {
      final at = src.indexOf('Future<void> _endSession()');
      final body = src.substring(at, src.indexOf('\n  }', at));
      expect(body, contains('s.ctSavedToHistory'));
      expect(body, contains('clearLiveContraction()'));
    });
  });
}
