// His side of pregnancy (2026-10-13): her app with less on it, and one block
// of his own. Same tabs as hers, nothing of hers he could log or read.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/preg_daily_insights.dart';
import 'package:parentveda/screens/pregnancy/preg_partner_home.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/screens/v2/pv_insight_rail.dart' show PvInsightArt;

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r', '')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

PregInsight _card(String id) => PregInsight(
      id: id,
      eyebrow: 'e',
      value: 'v',
      hue: 0,
      art: PvInsightArt.values.first,
      go: PregInsightGo.values.first,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController loaded;

  setUpAll(() async {
    final due = DateTime.now().add(const Duration(days: 140));
    SharedPreferences.setMockInitialValues({
      PregnancyController.kDueDateKey:
          DateTime(due.year, due.month, due.day).toIso8601String(),
    });
    loaded = PregnancyController(dueDate: due);
    await loaded.load();
  });

  test('his rail keeps the week and the baby, never what she logs', () {
    final kept = pregRailForHim([
      for (final id in [
        'size', 'forming', 'scan', 'scan_window_anomaly', 'myth_w20',
        'read_x', 'symptom_nausea', 'log', 'eat_done', 'eat_iron',
        'safe_coffee', 'move_walk',
      ])
        _card(id),
    ]).map((c) => c.id);
    expect(kept, ['size', 'forming', 'scan', 'scan_window_anomaly',
      'myth_w20', 'read_x']);
  });

  testWidgets('his block: his part, how she may feel, scans, the baby, his '
      'journal, the guide', (t) async {
    t.view.physicalSize = const Size(1200, 4000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PregPartnerHomeBlock(
              p: V2PaletteStore.instance.current, pregnancy: loaded),
        ),
      ),
    ));
    await t.pump();
    for (final k in [
      'preg_partner_mission', 'preg_partner_scans', 'preg_partner_talk',
      'preg_partner_journal', 'preg_partner_guide',
    ]) {
      expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
    }
    expect(find.text('Your part this week'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  test('her home hides her records on his side and carries his block', () {
    final s = _code('lib/screens/home_v3_screen.dart');
    expect(s, contains('final him = FatherPreview.instance.on;'));
    expect(s, contains('if (him) return null;'), reason: 'no symptom dots');
    expect(s, contains('onCalendar: him'), reason: 'no appointment editor');
    expect(s, contains('pregRailForHim'));
    expect(s, contains('PregPartnerHomeBlock(p: p, pregnancy: pregnancy)'));
    expect(s, contains('if (day != null && !him) ...['), reason: 'Garbh');
    expect(RegExp(r'if \(!him\) \.\.\.\[').allMatches(s).length,
        greaterThanOrEqualTo(2),
        reason: 'medicines and her journal');
    expect(s, contains('if (!him)\n              _ToolsRow('));
  });

  test('his tabs are hers, without the Slate bar', () {
    final s = _code('lib/screens/main_scaffold.dart');
    expect(s, contains("key: const ValueKey('preg_home_him')"));
    expect(s, contains('father: false,'));
    expect(s, isNot(contains('FatherDailyScreen(controller')));
  });

  test('Tools and More trim what is hers alone', () {
    final tools = _code('lib/screens/tools_hub_screen.dart');
    expect(tools, contains("if (!FatherPreview.instance.on)\n        _ToolGroup('Track'"));
    expect(tools, contains("_Tool('Your journal'"));
    final more = _code('lib/screens/pregnancy/preg_more_screen.dart');
    expect(more, contains("if (!FatherPreview.instance.on)\n              _row('preg_more_calendar'"));
    expect(more, contains("'preg_more_partner_guide'"));
  });
}
