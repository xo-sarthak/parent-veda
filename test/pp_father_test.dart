// =============================================================================
//  The father's side after the birth (gap analysis P1, Behind · Partner)
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_father_card.dart';
import 'package:parentveda/screens/post_pregnancy/pp_father_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a job for every week of the first year, then a monthly one', () {
    expect(kPpFatherJobs, hasLength(52));
    expect(ppFatherJobFor(6), isNotEmpty);
    expect(ppFatherJobFor(80), isIn(kPpFatherMonthJobs));
    expect(ppFatherAgeLine('Meera', 6, 1), 'Meera is 6 weeks.');
    expect(ppFatherAgeLine('Meera', 30, 7), 'Meera is 7 months.');
  });

  test('never a dose or a diagnosis in his lines', () {
    for (final l in [...kPpFatherJobs, ...kPpFatherMonthJobs]) {
      expect(RegExp(r'\b(mg|ml|dose|diagnos)', caseSensitive: false).hasMatch(l), isFalse, reason: l);
    }
  });

  test('a paired father in parenting lands on the parenting home', () {
    final src = File('lib/screens/splash_screen.dart').readAsStringSync();
    expect(src, contains("if (role == 'father' && stage == LifeStage.parenting.id)"));
    final home = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
    expect(home, contains('if (FatherPreview.instance.on)'));
    expect(home, contains('PpFatherCard('));
  });

  test('the card\'s pages exist', () {
    expect(ppScreenForSurface(kPpFatherPagesSurface), isNotNull);
    expect(ppScreenForSurface(kPpFatherNightSurface), isNotNull);
  });

  testWidgets('the card on a 360 phone at 1.5x', (tester) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 43)));
    tester.view.physicalSize = const Size(360 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    String? opened;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
      child: MaterialApp(
          home: Scaffold(
              body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PpFatherCard(p: V2PaletteStore.instance.current, onSurface: (s) => opened = s)))),
    ));
    expect(find.textContaining('is 6 weeks.'), findsOneWidget);
    expect(find.textContaining('This week, '), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pp_father_night')));
    expect(opened, kPpFatherNightSurface);
    expect(tester.takeException(), isNull);
  });
}
