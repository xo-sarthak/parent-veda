// =============================================================================
//  C1, Pregnancy: every tool a door offers is a Tools row (2026-10-30)
// -----------------------------------------------------------------------------
//  Rule C1 (docs/preg-ttc-tool-plans/00-MASTER.md): a door may show a tool; it
//  may never be the only way to find it. Parenting's test reads the door data
//  against `ppToolGroups()`; Pregnancy's rows live in a widget, so this pumps
//  the hub she sees and reads each row's key (`preg_tool_<route>`).
//
//  Tools routes and door ids name one tool two ways (`tools/kegel` and
//  `move/kegel`), so [_sameTool] maps the door id to its row, and the test
//  PROVES each pairing by the screen the door id builds, rather than trusting
//  the table. Plan: docs/preg-ttc-tool-plans/C1-tools-rows.md.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/ask_veda/pv_veda_links.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/models/scan_appointment.dart';
import 'package:parentveda/screens/brackets/pv_checklist_screen.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/doors/pv_list_row.dart';
import 'package:parentveda/screens/global_search.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/pregnancy/preg_due_date_screen.dart';
import 'package:parentveda/screens/tools/contraction_tracker_screen.dart';
import 'package:parentveda/screens/tools/due_date_calculator_screen.dart';
import 'package:parentveda/screens/tools/kegel_care_screen.dart';
import 'package:parentveda/screens/tools/product_checklist_screen.dart';
import 'package:parentveda/screens/tools/readings_log_screen.dart';
import 'package:parentveda/screens/tools/ready_for_birth_screen.dart';
import 'package:parentveda/screens/tools_hub_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart';
import 'package:parentveda/services/father_preview.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/scans_store.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

/// A door id that opens the same tool as a Tools row under another route,
/// with the screens that prove it (null: the door's own tab, opened by the
/// row that opens the door).
const Map<String, (String, Set<Type>?)> _sameTool = {
  'ready/bag': ('tools/hospital_bag', {ReadyForBirthScreen}),
  'hospital_bag': ('tools/hospital_bag', {ReadyForBirthScreen}),
  'hospital_bag/partner': ('tools/hospital_bag', {ReadyForBirthScreen}),
  'contractions': ('tools/contractions', {ContractionTrackerScreen}),
  'move/kegel': ('tools/kegel', {KegelCareScreen}),
  'first_weeks/due_date': ('tools/due_date', {DueDateCalculatorScreen, PregDueDateScreen}),
  'ready/store': ('tools/product_checklist', {ProductChecklistScreen}),
  'conditions/readings': ('tools/readings', {ReadingsLogScreen}),
  'scans/questions': ('questions', {PvChecklistScreen}),
  'conditions/questions': ('questions', {PvChecklistScreen}),
  'nutrition/questions': ('questions', {PvChecklistScreen}),
  'bump_journey': ('tools/bump', null),
  // The Symptoms door's own tabs: the Check in row opens the door.
  'symptoms/today': ('bracket/symptoms', null),
  'symptoms/week': ('bracket/symptoms', null),
  'symptoms/send': ('bracket/symptoms', null),
  'symptoms/calling': ('bracket/symptoms', null),
  'symptoms/normal': ('bracket/symptoms', null),
};

/// Not tools under M6 (records, tracks, calculates, checks or plans her own
/// data), so they stay in their doors. Named one by one, with why.
bool _allowed(String id) =>
    id.startsWith('door/tab/') || // switches the door's own tab, pushes nothing
    id.startsWith('garbh/') || // practices; the Garbh journal stays the door's (P2)
    (id.startsWith('mind/') && id != 'mind/track') || // practices, helplines; the gentle check-in opens from Mood check-in (P5 D1)
    id == 'move/today' || // the Move door's activity (GLOBAL-CHANGES #16)
    id == 'move/yoga' || // classes and videos
    id == 'birthing_classes' || // a course
    id == 'pregnancy/twins' || // a page
    id == 'belly_skin/itching' || // a written page (`showsAs`)
    id == 'conditions/after_loss' || // a page
    id == 'nutrition/experts' || // people to talk to
    id == 'nutrition/recipe_rail' || // recipes
    id == 'nutrition/for_week'; // reading for her week

/// Every tool id the doors offer: tool and checklist tiles, and the tools
/// drawn inline on a tab or in a section.
Set<String> _doorToolIds() => {
      for (final p in kPvDoorPages) ...[
        for (final g in p.groups) ?g.inlineSurfaceId,
        for (final s in p.sections) ...[
          ?s.inlineSurfaceId,
          for (final t in s.tiles)
            ?switch (t) {
              PvDoorToolTile(:final surfaceId) => surfaceId,
              PvDoorChecklistTile(:final surfaceId) => surfaceId,
              _ => null,
            },
        ],
      ],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FatherPreview.instance.on = false;
    pregnancy = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
    await pregnancy.load();
  });
  tearDown(() => FatherPreview.instance.on = false);

  Future<void> pumpHub(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 9000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ToolsHubScreen(controller: pregnancy))));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The routes of the rows on screen, read from their keys.
  Set<String> routes(WidgetTester tester) => {
        for (final e in find.byType(PvListRow, skipOffstage: false).evaluate())
          if (e.widget.key case ValueKey<String>(:final value) when value.startsWith('preg_tool_'))
            value.substring('preg_tool_'.length),
      };

  testWidgets('every door tool is also a Tools row', (tester) async {
    await pumpHub(tester);
    final listed = routes(tester);
    final missing = <String>[];
    for (final id in _doorToolIds()) {
      if (listed.contains(id) || _allowed(id)) continue;
      final same = _sameTool[id];
      if (same == null || !listed.contains(same.$1)) missing.add(id);
    }
    expect(missing, isEmpty, reason: 'a door offers a tool the Tools tab does not list');
  });

  test('every "same tool" pairing opens the screen it claims', () {
    for (final MapEntry(key: id, value: (_, types)) in _sameTool.entries) {
      if (types == null) continue;
      final w = pvDoorScreenFor(id, PregnancyController());
      expect(w, isNotNull, reason: id);
      expect(types, contains(w.runtimeType), reason: '$id builds ${w.runtimeType}');
    }
  });

  testWidgets('the C1 rows are on the tab, and each opens through its door id', (tester) async {
    await pumpHub(tester);
    final listed = routes(tester);
    for (final r in [
      'can_i',
      'conditions/find',
      'belly_skin/checker',
      'scans/timeline',
      'scans/reports',
      'scans/decoder',
      'tests_scans',
      'questions',
      'calendar',
      'ready/names',
      'nutrition/list',
    ]) {
      expect(listed, contains(r), reason: r);
    }
    for (final id in ['conditions/find', 'belly_skin/checker', 'scans/timeline', 'scans/reports', 'scans/decoder']) {
      expect(pvDoorScreenFor(id, PregnancyController()), isNotNull, reason: id);
    }
  });

  // C1 Q2 (the user, 2026-10-30): one mark per row, as Parenting's tab.
  testWidgets('every row draws its own mark, and no two rows share one', (tester) async {
    await pumpHub(tester);
    final seen = <Object, String>{};
    final twice = <String>[];
    for (final e in find.byType(PvListRow, skipOffstage: false).evaluate()) {
      final row = e.widget as PvListRow;
      if (row.title.contains('(debug)')) continue;
      final marks = find.descendant(
          of: find.byWidget(row), matching: find.byType(TtcMarkLeading), skipOffstage: false);
      if (marks.evaluate().isEmpty) continue; // Ask Veda wears its own mark
      final m = marks.evaluate().first.widget as TtcMarkLeading;
      final art = ttcMarkArtOf(tab: m.tab, tool: m.tool);
      if (seen[art] case final other?) twice.add('${row.title} and $other');
      seen[art] = row.title;
    }
    expect(seen.length, greaterThan(25), reason: 'the rows were read');
    expect(twice, isEmpty, reason: 'two rows draw the same glyph');
  });

  test('R9: the pin no longer forbids the rows M7 brought back', () {
    final hub = _code('lib/screens/tools_hub_screen.dart');
    expect(hub, contains("_Tool('Is it safe?'"));
    expect(hub, contains('_Tool(s.tsrTitle'));
  });

  // X4 (C1 Q3): every row she can see on Tools, global search finds by name.
  testWidgets('global search finds every Tools row by its title', (tester) async {
    await pumpHub(tester);
    final titles = [
      for (final e in find.byType(PvListRow, skipOffstage: false).evaluate())
        if (!(e.widget as PvListRow).title.contains('(debug)')) (e.widget as PvListRow).title,
    ];
    expect(titles.length, greaterThan(25));
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      ctx = c;
      return const Scaffold();
    })));
    final missing = <String>[];
    for (final t in titles) {
      showGlobalSearch(ctx, pregnancy);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), t);
      await tester.pumpAndSettle();
      final hit = find.descendant(of: find.byType(ListTile), matching: find.text(t));
      if (hit.evaluate().isEmpty) missing.add(t);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();
    }
    expect(missing, isEmpty, reason: 'a Tools row global search cannot find');
  });

  // X5: his side. His Tools tab keeps her trackers off his list; search and
  // Ask Veda now follow it.
  testWidgets("his side: her rows are off his Tools, his search and Ask Veda's links",
      (tester) async {
    FatherPreview.instance.on = true;
    await pumpHub(tester);
    final his = routes(tester);
    for (final r in ['tools/movement', 'tools/weight', 'tools/kegel', 'tools/due_date', 'scans/reports', 'conditions/find']) {
      expect(his, isNot(contains(r)), reason: r);
    }
    for (final id in kPvVedaHerOnlyToolIds) {
      final tool = pvVedaToolById(id);
      expect(tool, isNotNull, reason: id);
      expect(his, isNot(contains(tool!.route)), reason: '$id is on his Tools');
      expect(pvVedaToolStepsAside(id), isNotNull, reason: '$id opens for him from Ask Veda');
    }
    // What stays on his Tools still opens from Ask Veda.
    for (final id in ['hospital_bag', 'birth_plan', 'contractions', 'spiritual_reading']) {
      expect(pvVedaToolStepsAside(id), isNull, reason: id);
    }
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      ctx = c;
      return const Scaffold();
    })));
    showGlobalSearch(ctx, pregnancy);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'weight');
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(ListTile), matching: find.text('Weight')), findsNothing);
    FatherPreview.instance.on = false;
  });

  test('the father preview keeps search and Ask Veda to the hub\'s her-only set', () {
    final hub = _code('lib/screens/tools_hub_screen.dart');
    // Records and Find a condition sit behind the same father check as Track.
    expect(hub, contains("if (!FatherPreview.instance.on)\n        _ToolGroup('Records'"));
    expect(_code('lib/screens/global_search.dart'), contains('.where((d) => !(him && d.hers))'));
  });

  // B1: one "booked" rule for the Calendar and the Scans timeline.
  test('booked: whole words, in order, and a completed visit is not booked', () async {
    final store = ScansStore.instance;
    final day = DateTime.now().add(const Duration(days: 10));
    String iso(DateTime d) => d.toIso8601String().substring(0, 10);
    await store.addAppointment(Appointment(id: 'c1_a', title: 'My NT scan at Apollo', dateIso: iso(day)));
    await store.addAppointment(Appointment(id: 'c1_b', title: 'Doctor appointment', dateIso: iso(day)));
    await store.addAppointment(
        Appointment(id: 'c1_c', title: 'Anomaly scan', dateIso: iso(day), status: 'completed'));
    expect(store.bookedFor(['NT scan'])?.id, 'c1_a');
    expect(store.bookedFor(['nt'])?.id, 'c1_a', reason: 'a whole word');
    expect(store.bookedFor(['point']), isNull, reason: 'never inside a word');
    expect(store.bookedFor(['Anomaly scan']), isNull, reason: 'completed');
    expect(store.bookedFor(['scan NT']), isNull, reason: 'in order');
    expect(_code('lib/screens/pregnancy/calendar/preg_cal_data.dart'),
        contains('ScansStore.instance.bookedFor([c.title])'));
    expect(_code('lib/screens/brackets/scan_timeline_screen.dart'), contains('store.bookedFor(['));
  });

  // TW1: the second twin, derived.
  test('the second twin added through Add a child is a multiple birth', () async {
    final store = ChildProfileStore.instance;
    final born = DateTime.now().subtract(const Duration(days: 20));
    final first = await store.addChild(name: 'Asha', isBoy: false, dob: born);
    await store.setAnswers(first.id, multiple: true);
    final second = await store.addChild(name: 'Arya', isBoy: false, dob: born.add(const Duration(hours: 1)));
    expect(second.multiple, isTrue);
    expect(store.twinOf(second)?.id, first.id);
    final later = await store.addChild(name: 'Dev', isBoy: true, dob: born.add(const Duration(days: 400)));
    expect(later.multiple, isNot(isTrue));
    expect(store.twinOf(later), isNull);
    for (final f in ['lib/screens/post_pregnancy/multichild_sheet.dart', 'lib/screens/profile/pv_you_sheets.dart']) {
      expect(_code(f), contains('twinOf('), reason: '$f says so in its toast');
    }
  });

  // P4's hand-over: the timer's pushed pages wear the tool shell.
  test("the contraction timer's history, summary and session pages are on PregToolScaffold", () {
    final src = _code('lib/screens/tools/contraction_tracker_screen.dart');
    for (final cls in ['class _SummaryScreen', 'class _ContractionHistoryScreen', 'class _SessionDetailScreen']) {
      final at = src.indexOf(cls);
      expect(at, greaterThan(-1), reason: cls);
      final next = src.indexOf('\nclass ', at + 1);
      final body = src.substring(at, next < 0 ? src.length : next);
      expect(body, contains('PregToolScaffold('), reason: cls);
      expect(body, isNot(contains('appBar: AppBar()')), reason: cls);
    }
  });
}
