// =============================================================================
//  Multi-step flows: an X on step one, a back arrow after it (2026-09-29)
// -----------------------------------------------------------------------------
//  The user: "multi-step flows should be getting a back arrow instead of an X
//  or a cross." The tools' shell drew a round X on every page, so on step two
//  of a flow the X stepped back one page while reading as "close everything".
//
//  For every flow on the TTC side this file holds four things:
//    * step one shows the X, and the X closes the flow;
//    * step two and on show the arrow, and the arrow goes back ONE step with
//      her answers still in place;
//    * the phone's back gesture does exactly what the button does;
//    * nothing overflows at 360dp, with text at 1.5x.
//
//  Every flow is opened as a pushed route over a base page, so "closes" is
//  something the test can see: the base page is on screen again.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/medication.dart';
import 'package:parentveda/screens/ttc/ttc_appointments_screen.dart';
import 'package:parentveda/screens/ttc/ttc_edit_categories_screen.dart';
import 'package:parentveda/screens/ttc/ttc_garbh_course_screen.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_medication_screen.dart';
import 'package:parentveda/screens/ttc/ttc_records_screen.dart';
import 'package:parentveda/screens/ttc/ttc_records_v2.dart';
import 'package:parentveda/screens/ttc/ttc_supplements_screen.dart';
import 'package:parentveda/screens/ttc/ttc_treatment_screen.dart';
import 'package:parentveda/services/medicine_store.dart';
import 'package:parentveda/ttc/ttc_garbh_course.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';
import 'package:parentveda/screens/ttc/ttc_intro_flow.dart';
import 'package:parentveda/screens/ttc/ttc_ivf_readiness_screen.dart';
import 'package:parentveda/screens/ttc/ttc_pcos_stand_screen.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_summary.dart';
import 'package:parentveda/screens/ttc/ttc_round_strings.dart';
import 'package:parentveda/screens/ttc/ttc_semen_report_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/screens/ttc/ttc_treatment_round_screens.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_ivf_readiness.dart';
import 'package:parentveda/ttc/ttc_pcos_stand.dart';
import 'package:parentveda/ttc/ttc_precheck_store.dart';
import 'package:parentveda/ttc/ttc_selfcheck_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

const _base = 'The page the flow was opened from';

final Finder _close = find.byKey(const ValueKey('ttc_tool_close'));
final Finder _back = find.byKey(const ValueKey('ttc_tool_back'));

/// Opens [flow] as a pushed route over a base page, at 360dp wide, with the
/// text scaled by [scale].
Future<void> _open(WidgetTester tester, Widget flow,
    {double scale = 1.0, double height = 5000}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final nav = GlobalKey<NavigatorState>();
  await tester.pumpWidget(MaterialApp(
    key: UniqueKey(),
    navigatorKey: nav,
    builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!),
    home: const Scaffold(body: Center(child: Text(_base))),
  ));
  nav.currentState!.push(MaterialPageRoute<void>(builder: (_) => flow));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull,
      reason: 'threw or overflowed at 360dp, text x$scale');
}

/// Scrolls every list on screen back to its top.
///
/// A page she came back to keeps its scroll, and the round button rides in
/// the hero at the top of that scroll, so a page left from a button low down
/// comes back with its hero (and its button) scrolled away. She scrolls up;
/// so does the test.
Future<void> _toTop(WidgetTester tester) async {
  for (final s in tester.stateList<ScrollableState>(find.byType(Scrollable))) {
    s.position.jumpTo(s.position.minScrollExtent);
  }
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) await _toTop(tester);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// The phone's back gesture.
Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

Future<void> _expectClose(WidgetTester tester) async {
  await _toTop(tester);
  expect(_close, findsOneWidget, reason: 'step one closes');
  expect(_back, findsNothing);
}

Future<void> _expectBack(WidgetTester tester) async {
  await _toTop(tester);
  expect(_back, findsOneWidget, reason: 'a later step goes back');
  expect(_close, findsNothing, reason: 'no X that reads as "close all"');
}

FontWeight? _weightOf(WidgetTester tester, Finder label) => tester
    .widget<AnimatedDefaultTextStyle>(find
        .ancestor(of: label, matching: find.byType(AnimatedDefaultTextStyle))
        .first)
    .style
    .fontWeight;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Records loads in its constructor; let that land once, on the real clock,
  // before any test adds a row (the same guard ttc_records_rebuild_test uses).
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await TtcRecordsStore.instance.ensureLoaded();
    // Appointments loads in its constructor too, with no handle to await:
    // touched here, on the real clock, its load cannot land mid-test and
    // clear the visit a test just added.
    TtcAppointmentsStore.instance.isLoaded;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TtcIntroGate.resetForTest();
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcSelfCheckStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    await TtcPrecheckStore.instance.load();
    await TtcPrecheckStore.instance.reset();
    await TtcFertilityHelpStore.instance.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  // ===========================================================================
  group('the shell', () {
    Widget scaffold(TtcToolLeading leading) => TtcToolScaffold(
          hue: 200,
          eyebrow: 'A tool',
          title: 'A title',
          intro: 'One line.',
          leading: leading,
          children: const [SizedBox(height: 40)],
        );

    testWidgets('close by default: an X, read out as "Close"', (tester) async {
      final semantics = tester.ensureSemantics();
      await _open(
          tester,
          const TtcToolScaffold(
              hue: 200,
              eyebrow: 'A tool',
              title: 'A title',
              intro: 'One line.',
              children: [SizedBox(height: 40)]));
      await _expectClose(tester);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(tester.getSemantics(find.byType(TtcToolClose)),
          isSemantics(label: 'Close', isButton: true, hasTapAction: true));
      semantics.dispose();
    });

    testWidgets('back: an arrow in the same round button, read out as "Back"',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await _open(tester, scaffold(TtcToolLeading.back));
      await _expectBack(tester);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(tester.getSemantics(find.byType(TtcToolClose)),
          isSemantics(label: 'Back', isButton: true, hasTapAction: true),
          reason: 'said as "Back", and a screen reader can still press it');
      final close = tester.getSize(find.byType(TtcToolClose));
      expect(close, const Size(38, 38), reason: 'the same round button');
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_back_rounded));
      expect(icon.color, const Color(0xFF2F2C30), reason: 'the one black');
      semantics.dispose();
    });
  });

  // ===========================================================================
  group('Start a round (three pages in one screen)', () {
    bool chosen(WidgetTester tester, String kind) => tester
        .widget<TtcRoundOption>(find.byKey(ValueKey('ttc_start_kind_$kind')))
        .selected;

    testWidgets('step one: the X closes the flow', (tester) async {
      await _open(tester, const TtcTreatmentStartScreen());
      expect(find.text(kTtcStartKindTitle), findsOneWidget);
      await _expectClose(tester);
      await _tap(tester, _close);
      expect(find.text(_base), findsOneWidget);
      expect(find.byType(TtcTreatmentStartScreen), findsNothing);
    });

    testWidgets('steps two and three: the arrow goes back one step, keeping '
        'the kind', (tester) async {
      await _open(tester, const TtcTreatmentStartScreen());
      await _tap(tester, find.byKey(const ValueKey('ttc_start_kind_ivfFresh')));
      await _tap(tester, find.byKey(const ValueKey('ttc_start_next')));
      expect(find.text(kTtcStartDateTitle), findsOneWidget);
      await _expectBack(tester);
      expect(find.byKey(const ValueKey('ttc_start_back')), findsNothing,
          reason: 'one back, not a second worded one at the foot');

      await _tap(tester, find.byKey(const ValueKey('ttc_start_later')));
      expect(find.text(kTtcStartReviewTitle), findsOneWidget);
      await _expectBack(tester);

      await _tap(tester, _back);
      expect(find.text(kTtcStartDateTitle), findsOneWidget,
          reason: 'three goes back to two, not out');
      await _tap(tester, _back);
      expect(find.text(kTtcStartKindTitle), findsOneWidget);
      expect(chosen(tester, 'ivfFresh'), isTrue, reason: 'her answer kept');
      await _expectClose(tester);
      expect(TtcTreatmentStore.instance.cycle.isEmpty, isTrue,
          reason: 'stepping back saves nothing');
    });

    testWidgets('the back gesture matches: back one step, then close',
        (tester) async {
      await _open(tester, const TtcTreatmentStartScreen());
      await _tap(tester, find.byKey(const ValueKey('ttc_start_kind_iui')));
      await _tap(tester, find.byKey(const ValueKey('ttc_start_next')));
      await _tap(tester, find.byKey(const ValueKey('ttc_start_later')));
      await _systemBack(tester);
      expect(find.text(kTtcStartDateTitle), findsOneWidget);
      await _systemBack(tester);
      expect(find.text(kTtcStartKindTitle), findsOneWidget);
      expect(chosen(tester, 'iui'), isTrue);
      await _systemBack(tester);
      expect(find.text(_base), findsOneWidget);
    });

    testWidgets('no overflow at 360dp and 1.5x on any step', (tester) async {
      await _open(tester, const TtcTreatmentStartScreen(), scale: 1.5);
      await _tap(tester, find.byKey(const ValueKey('ttc_start_kind_ivfFresh')));
      await _tap(tester, find.byKey(const ValueKey('ttc_start_next')));
      expect(tester.takeException(), isNull);
      await _tap(tester, find.byKey(const ValueKey('ttc_start_later')));
      expect(tester.takeException(), isNull);
      await _expectBack(tester);
    });
  });

  // ===========================================================================
  group('Should I seek fertility help? (questions, answer, notes)', () {
    testWidgets('the questions close; the answer and the notes go back, and '
        'her answers are kept', (tester) async {
      await _open(tester, const TtcIvfReadinessScreen());
      await _expectClose(tester);
      await _tap(tester, find.text('Yes, it was normal'));
      await _tap(tester, find.byKey(const ValueKey('ttc_ivf_see')));
      expect(find.text('What your answers add up to.'), findsOneWidget);
      await _expectBack(tester);

      await _tap(tester, find.text('What to take with you').first);
      expect(find.byType(TtcIvfNotesScreen), findsOneWidget);
      await _expectBack(tester);
      await _tap(tester, _back);
      await _toTop(tester);
      expect(find.text('What your answers add up to.'), findsOneWidget);

      await _tap(tester, _back);
      expect(find.byKey(const ValueKey('ttc_ivf_see')), findsOneWidget);
      expect(_weightOf(tester, find.text('Yes, it was normal')),
          FontWeight.w800,
          reason: 'her answer is still chosen');
      await _expectClose(tester);
      await _tap(tester, _close);
      expect(find.text(_base), findsOneWidget);
    });

    testWidgets('the back gesture matches', (tester) async {
      await _open(tester, const TtcIvfReadinessScreen());
      await _tap(tester, find.byKey(const ValueKey('ttc_ivf_see')));
      await _systemBack(tester);
      expect(find.byKey(const ValueKey('ttc_ivf_see')), findsOneWidget);
      await _systemBack(tester);
      expect(find.text(_base), findsOneWidget);
    });

    testWidgets('no overflow at 360dp and 1.5x', (tester) async {
      final r = ivfBuildReadiness(
          IvfReadinessAnswers(), TtcFertilityHelpStore.instance.context);
      await _open(tester, TtcIvfReadinessResultScreen(result: r), scale: 1.5);
      await _expectBack(tester);
      await _open(tester, TtcIvfNotesScreen(result: r), scale: 1.5);
      await _expectBack(tester);
    });
  });

  // ===========================================================================
  group('PCOS symptom check (questions, pattern, notes)', () {
    testWidgets('the questions close; the pattern and the notes go back, and '
        'her answers are kept', (tester) async {
      await _open(tester, const TtcPcosStandScreen());
      await _expectClose(tester);
      await _tap(tester, find.text('Mostly 21 to 35 days'));
      await _tap(tester, find.byKey(const ValueKey('ttc_pcos_stand_see')));
      expect(find.text('What your cycle looks like'), findsOneWidget);
      await _expectBack(tester);

      await _tap(tester, find.text('What to take with you'));
      expect(find.byType(TtcPcosChecklistScreen), findsOneWidget);
      await _expectBack(tester);
      await _tap(tester, _back);
      expect(find.text('What your cycle looks like'), findsOneWidget);

      await _tap(tester, _back);
      expect(find.byKey(const ValueKey('ttc_pcos_stand_see')), findsOneWidget);
      expect(_weightOf(tester, find.text('Mostly 21 to 35 days')),
          FontWeight.w800);
      await _expectClose(tester);
    });

    testWidgets('the back gesture matches', (tester) async {
      await _open(tester, const TtcPcosStandScreen());
      await _tap(tester, find.byKey(const ValueKey('ttc_pcos_stand_see')));
      await _systemBack(tester);
      expect(find.byKey(const ValueKey('ttc_pcos_stand_see')), findsOneWidget);
      await _systemBack(tester);
      expect(find.text(_base), findsOneWidget);
    });

    testWidgets('no overflow at 360dp and 1.5x', (tester) async {
      final r = pcosBuildStand(
          PcosStandAnswers()..cycleLength = PcosCycleLength.longer);
      await _open(tester, TtcPcosStandResultScreen(result: r), scale: 1.5);
      await _expectBack(tester);
      await _open(tester, TtcPcosChecklistScreen(result: r), scale: 1.5);
      await _expectBack(tester);
    });
  });

  // ===========================================================================
  group('Read your semen report (numbers, then the reading in place)', () {
    testWidgets('the numbers close; the reading goes back to them, filled in',
        (tester) async {
      await _open(tester, const TtcSemenReportScreen());
      await _expectClose(tester);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '20');
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Read my report back to me'));
      expect(find.text('Have the report read properly'), findsOneWidget);
      await _expectBack(tester);

      await _tap(tester, _back);
      expect(find.text('Read my report back to me'), findsOneWidget,
          reason: 'back to the numbers, not out of the tool');
      expect(
          find.descendant(
              of: find.byType(TextField).at(0),
              matching: find.textContaining('20')),
          findsOneWidget,
          reason: 'the number he typed is still there');
      await _expectClose(tester);
      await _tap(tester, _close);
      expect(find.text(_base), findsOneWidget);
    });

    testWidgets('the back gesture matches: the reading, then out',
        (tester) async {
      await _open(tester, const TtcSemenReportScreen());
      await _tap(tester, find.text('Read my report back to me'));
      await _systemBack(tester);
      expect(find.text('Read my report back to me'), findsOneWidget);
      await _systemBack(tester);
      expect(find.text(_base), findsOneWidget);
    });

    testWidgets('no overflow at 360dp and 1.5x', (tester) async {
      await _open(tester, const TtcSemenReportScreen(), scale: 1.5);
      await _tap(tester, find.text('Read my report back to me'));
      expect(tester.takeException(), isNull);
      await _expectBack(tester);
    });
  });

  // ===========================================================================
  group('Pre-pregnancy checklist: My next 3 steps', () {
    testWidgets('opened from the checklist, it goes back to it',
        (tester) async {
      await _open(tester, const TtcPrecheckSummaryScreen(), scale: 1.5);
      await _expectBack(tester);
      await _tap(tester, _back);
      expect(find.text(_base), findsOneWidget);
    });
  });

  // ===========================================================================
  //  2026-09-29, approved by the user: a page pushed from a list or from
  //  another page is a step too. It goes back; only a tool's front page, the
  //  first step of a flow and a full-screen form keep the X.
  group('a page opened from a list goes back', () {
    DateTime inDays(int n) {
      final t = DateTime.now();
      return DateTime(t.year, t.month, t.day + n, 10);
    }

    /// The detail page shows the arrow, and the arrow returns to the page
    /// underneath.
    Future<void> expectBackToBase(WidgetTester tester) async {
      await _expectBack(tester);
      await _tap(tester, _back);
      expect(find.text(_base), findsOneWidget);
    }

    testWidgets('one visit: the list closes, the visit goes back to it',
        (tester) async {
      TtcAppointmentsStore.instance.resetForTest();
      TtcAppointmentsStore.schedulePhone = ({
        required int id,
        required String title,
        required String body,
        required DateTime when,
      }) async {};
      TtcAppointmentsStore.cancelPhone = (id) async {};
      TtcAppointmentsStore.instance
          .add(title: 'Follicle scan', startsLocal: inDays(2));
      await _open(tester, const TtcAppointmentsScreen());
      await _expectClose(tester);
      await _tap(tester, find.text('Follicle scan'));
      expect(find.byType(TtcAppointmentScreen), findsOneWidget);
      await _expectBack(tester);
      await _tap(tester, _back);
      expect(find.byType(TtcAppointmentScreen), findsNothing);
      await _expectClose(tester);
    });

    testWidgets('one medicine, and a medicine that was removed',
        (tester) async {
      MedicineStore.instance.addMed(const Medication(
        id: 'back_m1',
        name: 'Letrozole',
        type: MedType.medication,
        dose: '2.5 mg',
        frequency: 'Once a day',
        startDateIso: '2026-09-01T00:00:00.000',
      ));
      await _open(tester, const TtcMedicineDetailScreen(id: 'back_m1'),
          scale: 1.5);
      expect(find.text('Letrozole'), findsWidgets);
      await expectBackToBase(tester);

      await _open(tester, const TtcMedicineDetailScreen(id: 'no_such_med'));
      expect(find.text('Not on the list any more.'), findsOneWidget);
      expect(find.textContaining('Close this'), findsNothing,
          reason: 'the copy names the arrow, not an X');
      await expectBackToBase(tester);
    });

    testWidgets('one supplement, and a supplement that was removed',
        (tester) async {
      TtcSupplementsStore.instance.resetForTest();
      final s = TtcSupplementsStore.instance.add('Folic acid');
      await _open(tester, TtcSupplementDetailScreen(id: s.id), scale: 1.5);
      await expectBackToBase(tester);

      await _open(tester, const TtcSupplementDetailScreen(id: 'no_such'));
      expect(find.text('Not on the list any more.'), findsOneWidget);
      expect(find.textContaining('Close this'), findsNothing);
      await expectBackToBase(tester);
    });

    testWidgets('records: a test\'s results and one result go back; the '
        'records list closes', (tester) async {
      final store = TtcRecordsStore.instance;
      final r = store.add(
          label: 'AMH',
          testId: 'amh',
          value: '2.1',
          unit: 'ng/mL',
          takenOn: DateTime(2025, 3, 4));
      store.add(
          label: 'AMH',
          testId: 'amh',
          value: '1.2',
          unit: 'ng/mL',
          takenOn: DateTime(2026, 8, 18));
      await _open(tester, const TtcRecordsScreen());
      await _expectClose(tester);
      await _tap(tester, find.text('AMH').first);
      expect(find.byType(TtcRecordTrendScreen), findsOneWidget);
      await _expectBack(tester);
      await _tap(tester, _back);
      await _expectClose(tester);

      await _open(tester, TtcRecordDetailScreen(recordId: r.id), scale: 1.5);
      await expectBackToBase(tester);
      await _open(
          tester, const TtcRecordDetailScreen(recordId: 'no_such_record'));
      expect(find.text('This result has been removed.'), findsOneWidget);
      await expectBackToBase(tester);
    });

    testWidgets('a past round, opened from the plan', (tester) async {
      final store = TtcTreatmentStore.instance;
      store.startRound(
        kind: TtcRoundKind.iui,
        dates: {TtcTreatmentStep.betaTest: inDays(-6)},
        clinic: 'City IVF',
      );
      store.closeRound(TtcRoundOutcome.negative,
          now: DateTime.now().subtract(const Duration(days: 30)));
      await _open(tester, const TtcTreatmentScreen());
      await _expectClose(tester);
      await _tap(tester, find.byKey(const ValueKey('ttc_round_past_1')));
      expect(find.byType(TtcPastRoundScreen), findsOneWidget);
      await _expectBack(tester);
      await _tap(tester, _back);
      expect(find.byType(TtcPastRoundScreen), findsNothing);
    });

    testWidgets('a course lesson', (tester) async {
      await _open(
          tester, TtcCourseSessionScreen(session: kTtcCourseSessions.first),
          scale: 1.5);
      await expectBackToBase(tester);
    });

    testWidgets('Edit categories, opened from the logger', (tester) async {
      await _open(tester, const TtcEditCategoriesScreen(), scale: 1.5);
      await expectBackToBase(tester);
    });
  });

  // ===========================================================================
  group('the first-run flow', () {
    Future<void> pumpStage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcHomeScreen()));
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('step one has no arrow; later steps go back one step',
        (tester) async {
      const t = TtcS(false);
      await pumpStage(tester);
      expect(find.text(t.introLanguageTitle), findsOneWidget);
      expect(_back, findsNothing, reason: 'the first screen; Skip leaves');

      await tester.tap(find.text('English'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(t.introVideoTitle), findsOneWidget);
      expect(_back, findsOneWidget);
      await tester.tap(_back);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(t.introLanguageTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the back gesture steps back too, and never leaves mid-flow',
        (tester) async {
      const t = TtcS(false);
      await pumpStage(tester);
      await tester.tap(find.text('English'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(t.introContinue));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(t.introPeriodTitle), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(t.introVideoTitle), findsOneWidget);
      expect(await TtcIntroGate.owed(), isTrue,
          reason: 'stepping back is not skipping');
    });
  });
}
