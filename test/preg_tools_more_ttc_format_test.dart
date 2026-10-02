// Pregnancy Tools and More wear the trying-to-conceive format (2026-10-02).
//
// The user: "in pregnancy, tools section, match its format and UI with TTC,
// the marks used in TTC and the overall structure, to maintain app
// consistency; same goes for the pregnancy More section", and "in pregnancy
// profile, change your answers feels like one item isn't visible".
//
// What this pins:
//   - both tabs open on TtcTabRootHeader (the one tab-root header), not a
//     hand-drawn title;
//   - the Tools groups are violet caps eyebrows, and each row's leading is a
//     mark of the TTC family at 44, never the old square well;
//   - More's rows draw TTC's marks; its section headings stay the one serif
//     heading TTC's More uses;
//   - the three marks drawn for this (hospital bag, stopwatch, bell) paint;
//   - the Change your answers row carries a pill on its right, in both stages;
//   - Products keeps the stage switch, under the search, on the pregnancy
//     storefront.
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import 'package:parentveda/screens/pregnancy/preg_more_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';
import 'package:parentveda/screens/ttc/ttc_tab_root_header.dart';
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart';
import 'package:parentveda/screens/tools_hub_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pregnancy = PregnancyController(
        dueDate: DateTime.now().add(const Duration(days: 140)));
    await pregnancy.load();
  });

  Future<void> pump(WidgetTester tester, Widget w,
      {double height = 3200}) async {
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: w)));
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('Tools', () {
    testWidgets('opens on the one tab-root header, with no overflow',
        (tester) async {
      await pump(tester, ToolsHubScreen(controller: pregnancy));
      expect(find.byType(TtcTabRootHeader), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every row leads with a TTC-family mark, none with a well',
        (tester) async {
      await pump(tester, ToolsHubScreen(controller: pregnancy));
      final marks = find.byType(TtcMarkLeading, skipOffstage: false);
      // Track 5 + Get ready 5 + Keep 3 + Ask 1 = 14 rows in a release build
      // (the debug workbenches have no mark and keep their well).
      expect(marks.evaluate().length, greaterThanOrEqualTo(14));
      // The only wells left are the two debug workbench rows, which exist in
      // debug builds only and have no mark.
      expect(find.byKey(const ValueKey('pv_mark_well'), skipOffstage: false),
          findsNWidgets(kDebugMode ? 2 : 0),
          reason: 'the old square wells are gone from her list');
    });

    test('the groups are the violet caps eyebrow, not the serif heading', () {
      final src = _code('lib/screens/tools_hub_screen.dart');
      expect(src, contains('_pad(_eyebrow(p, g.title))'));
      expect(src, contains('color: p.action'));
      expect(src, isNot(contains('PregSectionHeading(g.title)')));
    });
  });

  group('More', () {
    testWidgets('opens on the one tab-root header and draws TTC marks',
        (tester) async {
      await pump(tester, PregMoreScreen(pregnancy: pregnancy));
      expect(find.byType(TtcTabRootHeader), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('pv_mark_well'), skipOffstage: false),
          findsNothing,
          reason: 'every More row draws a TTC mark, not the old well');
    });

    test('its rows are mapped to TTC marks, by id', () {
      final src = _code('lib/screens/pregnancy/preg_more_screen.dart');
      for (final id in [
        'preg_more_all_reads',
        'preg_more_all_films',
        'preg_more_messages',
        'preg_more_calendar',
        'preg_more_journey_map',
        'preg_more_week',
        'preg_more_employer',
        'preg_more_invite',
      ]) {
        expect(src, contains("'$id': ttcArt"), reason: id);
      }
    });
  });

  group('a tool front page wears the same mark as its row', () {
    testWidgets('the header mark is the TTC family mark, not the old well',
        (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: PregToolScaffold(
          hue: 206,
          eyebrow: 'Track',
          title: 'Weight',
          mark: IntentMark.scaleMark,
          children: const [SizedBox(height: 10)],
        ),
      ));
      await tester.pump();
      final header = find.byKey(const ValueKey('preg_tool_header_mark'));
      expect(header, findsOneWidget);
      expect(
          find.descendant(of: header, matching: find.byType(TtcMarkLeading)),
          findsOneWidget);
      expect(find.byKey(const ValueKey('pv_mark_well')), findsNothing);
    });

    test('every mark a pregnancy tool uses has a TTC counterpart', () {
      // The marks the Tools list passes (tools_hub_screen.dart). A mark with
      // none would fall back to the old well on its front page.
      for (final m in [
        IntentMark.stepsMark,
        IntentMark.scaleMark,
        IntentMark.pillMark,
        IntentMark.chartLog,
        IntentMark.lotusMark,
        IntentMark.nextStep,
        IntentMark.bagMark,
        IntentMark.reportPage,
        IntentMark.timelineRail,
        IntentMark.calendarDay,
        IntentMark.listMark,
        IntentMark.bookMark,
        IntentMark.bodyMark,
        IntentMark.lampMark,
        IntentMark.askDoctor,
      ]) {
        expect(ttcFamilyMarkForIntent(m, const Color(0xFFE4DDF5)), isNotNull,
            reason: '$m has no TTC-family mark');
      }
    });
  });

  group('the marks drawn for pregnancy', () {
    for (final m in [
      TtcToolMark.hospitalBag,
      TtcToolMark.stopwatch,
      TtcToolMark.bell,
    ]) {
      testWidgets('${m.name} paints inside its box', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Center(
            child: SizedBox(
              width: 44,
              height: 44,
              child: TtcToolArt(mark: m, tint: const Color(0xFFE4DDF5)),
            ),
          ),
        ));
        expect(find.byType(CustomPaint), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Change your answers', () {
    test('is an action in both stages: a pill on its right, not a blank', () {
      final src = _code('lib/screens/profile/pv_you_screen.dart');
      // Two rows (the TTC V3 profile and the pregnancy-aware one), one pill.
      expect(RegExp(r'trailing:\s*const _EditAnswersPill\(\)')
              .allMatches(src)
              .length,
          2);
      expect(src, contains("label: 'Edit answers'"));
    });
  });

  group('Products', () {
    test('pregnancy wears the TTC header and keeps the stage switch', () {
      final src = _code('lib/screens/products/pv_store_screen.dart');
      expect(src, contains('widget.chrome == PvStoreChrome.embedded'));
      expect(src, contains('PvStageSwitch('));
      // The switch is drawn after the header in the scroll view.
      expect(
          src.indexOf('SliverToBoxAdapter(child: _header(p))'),
          lessThan(src.indexOf('SliverToBoxAdapter(child: _stageRow(p))')));
    });
  });
}
