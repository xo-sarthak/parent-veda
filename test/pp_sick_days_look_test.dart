// =============================================================================
//  Sick-day meals in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  SickDaysScreen moved onto PregToolScaffold. The safety note still opens
//  from the (i), every situation chip still swaps the meals, and nothing
//  overflows at 360dp and 1.5x text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:parentveda/screens/post_pregnancy/sick_days_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: no overflow through the note and every situation', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        home: const SickDaysScreen(),
      ));
      await t.pumpAndSettle();
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.tap(find.byKey(const ValueKey('sick_days_info')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('sick_days_note')), findsOneWidget);
      expect(find.textContaining('not medical remedies'), findsOneWidget);
      expect(t.takeException(), isNull);

      for (final s in kSickSituations) {
        final chip = find.byKey(ValueKey('sick_days_chip_$s'));
        await t.ensureVisible(chip);
        await t.pumpAndSettle(); // the scroll lands on the next frame
        await t.tap(chip);
        await t.pumpAndSettle();
        expect(find.text('For ${s.toLowerCase()}'), findsOneWidget);
        expect(t.takeException(), isNull);
      }
    });
  }
}
