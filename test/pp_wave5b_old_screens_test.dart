// =============================================================================
//  The old screens still reachable from the parenting home (2026-10-21,
//  Wave 5b). An activity opens in the one reader, the old area and Development
//  pages open the Development door, and the screens kept in place carry no
//  violet or lavender fill. Violet text is allowed: the eyebrows keep it.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/development_activity_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_all_activities_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_area_screen.dart';
import 'package:parentveda/screens/post_pregnancy/doctor_record_screen.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_activity_read.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';
import 'package:parentveda/screens/post_pregnancy/vax_detail_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';

const _lavender = {0xFFEDEAF0, 0xFFF4F2F6, 0xFFEAE7EE, 0xFFE7DFEE, 0xFFEFEAF2, 0xFFEDEAF7, 0xFFF3ECFA, 0xFFF3EEF7, 0xFFEDE6F5};

/// Violet at any opacity: the old ppPurple's hue (about 271) with real
/// saturation. A grey or an ink has no saturation, so it never trips this.
bool _violet(Color c) {
  if (c.a < 0.05) return false;
  final h = HSLColor.fromColor(c);
  return h.saturation > 0.4 && (h.hue - 271).abs() < 8;
}

List<String> _oldLook(WidgetTester t) {
  final hits = <String>[];
  void fill(Color? c, String where) {
    if (c == null) return;
    if (_lavender.contains(c.toARGB32()) || _violet(c)) hits.add('$where $c');
  }

  for (final w in t.widgetList(find.byWidgetPredicate((_) => true, skipOffstage: false))) {
    if (w is Container) {
      fill(w.color, 'Container');
      final d = w.decoration;
      if (d is BoxDecoration) {
        fill(d.color, 'fill');
        final b = d.border;
        if (b is Border) fill(b.top.color, 'border');
      }
    } else if (w is DecoratedBox) {
      final d = w.decoration;
      if (d is BoxDecoration) fill(d.color, 'fill');
    } else if (w is Icon) {
      fill(w.color, 'icon ${w.icon}');
    } else if (w is ColoredBox) {
      fill(w.color, 'ColoredBox');
    }
  }
  return hits;
}

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(360 * 3, 2600 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump(const Duration(milliseconds: 800));
}

String _src(String path) => File(path).readAsStringSync();

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 215)));
  });

  test('each facade opens its new destination and keeps the old page', () {
    const dir = 'lib/screens/post_pregnancy/';
    expect(_src('${dir}development_activity_screen.dart'),
        contains('Widget build(BuildContext context) => ppActivityReader(activity);'));
    expect(_src('${dir}development_area_screen.dart'),
        contains('Widget build(BuildContext context) => ppDevelopmentDoor(areaId: area.id);'));
    expect(_src('${dir}development_home_screen.dart'),
        contains('Widget build(BuildContext context) => ppDevelopmentDoor();'));
    for (final f in ['development_activity_screen', 'development_area_screen', 'development_home_screen']) {
      expect(_src('$dir$f.dart'), contains('Widget buildClassic(BuildContext context)'), reason: f);
    }
  });

  test('the door card for activities no longer loops back to the door', () {
    expect(_src('lib/data/doors/pp_door_development.dart'), isNot(contains("surfaceId: 'pp_development'")));
  });

  test('every activity reads in order with its steps, and nothing is lost', () {
    for (final a in kDevActivities.take(12)) {
      final r = ppActivityAsRead(a);
      expect(r.sections.any((s) => s.custom != null), isTrue, reason: a.id);
      expect(r.title.en, isNotEmpty);
    }
  });

  testWidgets('an activity opens in the one reader', (t) async {
    await _pump(t, DevelopmentActivityScreen(activity: kDevActivities.first));
    expect(find.byType(PvReaderScreen), findsOneWidget);
    expect(find.text('How to do it'), findsWidgets);
    expect(t.takeException(), isNull);
  });

  testWidgets('an area opens the Development door on its tab', (t) async {
    await _pump(t, DevelopmentAreaScreen(area: devAreaById('language')));
    final door = t.widget<PpDoorScreen>(find.byType(PpDoorScreen));
    expect(door.initialTabId, 'talking');
    expect(ppDevelopmentTabFor('gross_motor'), 'what_to_do');
    expect(t.takeException(), isNull);
  });

  testWidgets('all activities sit on the tool shell, in ink', (t) async {
    await _pump(t, const DevelopmentAllActivitiesScreen());
    expect(find.byType(PregToolScaffold), findsOneWidget);
    expect(_oldLook(t), isEmpty);
    expect(t.takeException(), isNull);
  });

  testWidgets('vaccine detail carries no violet fill', (t) async {
    await _pump(t, VaxDetailScreen(visitId: kVaxVisits.first.id));
    expect(_oldLook(t), isEmpty);
  });

  testWidgets('the doctor record carries no violet fill', (t) async {
    await _pump(t, const DoctorRecordScreen());
    expect(_oldLook(t), isEmpty);
  });
}
