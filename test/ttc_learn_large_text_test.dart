// =============================================================================
//  TTC Learn: nothing overflows at 360dp and 1.5x text (2026-09-29)
// -----------------------------------------------------------------------------
//  Found by the tab-root header pass: at 1.5x on a 360dp phone Learn's topic
//  tiles (a Column in a fixed 108 height) and row layouts overflowed. A phone with its text size turned up is a normal
//  phone, not an edge case; the fixed heights now grow with the text scale
//  and the rows give way. This pumps the whole page, every shelf opened, at
//  360dp wide and 1.5x, and fails on any overflow.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcPartnerMode.instance.on = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
    TtcLearnRecents.instance.resetForTest();
  });

  Future<List<String>> overflowsAt(
      WidgetTester tester, double scale, {bool partner = false}) async {
    TtcPartnerMode.instance.on = partner;
    tester.view.physicalSize = const Size(360, 30000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final errors = <String>[];
    final old = FlutterError.onError;
    FlutterError.onError = (d) => errors.add(d.toString());
    try {
      await tester.pumpWidget(MaterialApp(
        key: UniqueKey(),
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const TtcLearnScreen(),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      for (var guard = 0; guard < 20; guard++) {
        final more = find.textContaining('Show all ');
        if (more.evaluate().isEmpty) break;
        await tester.tap(more.first);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));
    } finally {
      FlutterError.onError = old;
    }
    return errors
        .where((e) => e.contains('overflowed'))
        .map((e) => e.split('\n').take(12).join('\n'))
        .toList();
  }

  for (final partner in [false, true]) {
    testWidgets(
        '${partner ? 'his' : 'her'} Learn at 360dp and 1.5x: no overflow',
        (tester) async {
      final o = await overflowsAt(tester, 1.5, partner: partner);
      expect(o, isEmpty, reason: o.join('\n---\n'));
    });
  }

  testWidgets('and at 1x, nothing changed for the common case',
      (tester) async {
    final o = await overflowsAt(tester, 1.0);
    expect(o, isEmpty, reason: o.join('\n---\n'));
  });
}
