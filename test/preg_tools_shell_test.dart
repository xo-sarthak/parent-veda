// The pregnancy Tools audit (2026-09-30): every tool's front page wears the one
// shell, the hub draws marks not glyphs, and the rows another door already
// covers are commented out (kept for revert).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';
import 'package:parentveda/screens/brackets/hub/hub_intent_art.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  const tools = [
    'lib/screens/tools/baby_movement_screen.dart',
    'lib/screens/tools/kegel_care_screen.dart',
    'lib/screens/tools/weight_tracker_screen.dart',
    'lib/screens/tools/medicine_tracker_screen.dart',
    'lib/screens/tools/contraction_tracker_screen.dart',
    'lib/screens/tools/product_checklist_screen.dart',
    'lib/screens/tools/due_date_calculator_screen.dart',
    'lib/screens/tools/ready_for_birth_screen.dart',
    'lib/screens/belly_skin/bump_ritual_screen.dart',
    'lib/screens/read_next_screen.dart',
    'lib/screens/reminders_screen.dart',
    'lib/screens/tools/spiritual_reading_screen.dart',
  ];

  test('every tool front page is built on PregToolScaffold', () {
    for (final f in tools) {
      expect(_code(f), contains('PregToolScaffold('), reason: f);
    }
  });

  test('the hub draws marks, and the rows a door already covers are gone', () {
    final hub = _code('lib/screens/tools_hub_screen.dart');
    expect(hub, contains('mark: IntentMark.'));
    for (final gone in ['s.symToolTitle', 's.tsrTitle', 's.garbhToolTitle', "'Is it safe?'"]) {
      expect(hub, isNot(contains('_Tool($gone')), reason: '$gone is a door already');
    }
  });

  testWidgets('the shell shows the mark, the title and the sentence, with a back button',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PregToolScaffold(
        hue: 206,
        eyebrow: 'Track',
        title: 'Weight',
        intro: 'A record, not a target.',
        mark: IntentMark.scaleMark,
        children: [Text('body')],
      ),
    ));
    expect(find.text('TRACK'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('A record, not a target.'), findsOneWidget);
    expect(find.byKey(const ValueKey('preg_tool_header_mark')), findsOneWidget);
    expect(find.byKey(const ValueKey('preg_tool_back')), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
