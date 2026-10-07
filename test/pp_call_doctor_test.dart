// =============================================================================
//  The home's "When to call the doctor" opens this phase's lines; the phase
//  video card only for a film that can play (gap analysis P1)
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_age_page_parts.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every phase has its own call-the-doctor lines', () {
    for (final ph in kPhases) {
      expect(ph.sections.any((s) => s.heading.toLowerCase() == 'when to call the doctor'), isTrue,
          reason: 'phase ${ph.number}');
    }
  });

  testWidgets('the sheet: this phase, 112 and 108, then the symptom check', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 100)));
    var checked = false;
    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showPpCallDoctorSheet(ctx,
                phase: currentPhase(), p: V2PaletteStore.instance.current, onCheck: () => checked = true),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('pp_call_doctor_sheet')), findsOneWidget);
    expect(find.textContaining('112 or 108'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('pp_call_doctor_check')));
    await t.pumpAndSettle();
    expect(checked, isTrue);
  });

  test('wired: the home link opens the sheet; the video card needs a playable film', () {
    final home = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
    expect(home, contains('showPpCallDoctorSheet(context,'));
    expect(home, contains('bool plays(WatchVideo v) => pvResolveVideoUrl(v) != null;'));
  });
}
