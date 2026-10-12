// The Dear Baby vault as a keepsake (2026-10-10): the invitation is always on
// top, and letters read oldest first under their trimester.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/dear_baby_vault_screen.dart';
import 'package:parentveda/services/daily_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(1080, 4000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
        home: DearBabyVaultScreen(controller: PregnancyController())));
    await t.pumpAndSettle();
  }

  testWidgets('an empty vault invites the first letter', (t) async {
    SharedPreferences.setMockInitialValues({});
    await DailyStore.instance.init();
    await pump(t);
    expect(find.text('Letters to\nyour baby'), findsOneWidget);
    if (DailyStore.instance.talkEntries.isEmpty) {
      expect(find.text('Write your first letter'), findsOneWidget);
    }
    expect(find.text('Write'), findsOneWidget);
    expect(find.text('Say it aloud'), findsOneWidget);
  });

  testWidgets('letters sit under their trimester, oldest first', (t) async {
    SharedPreferences.setMockInitialValues({});
    await DailyStore.instance.init();
    final s = DailyStore.instance;
    await s.saveTalk(day: 200, week: 29, prompt: '', text: 'Third letter', spoken: false);
    await s.saveTalk(day: 60, week: 9, prompt: '', text: 'First letter', spoken: true);
    await s.saveTalk(day: 120, week: 18, prompt: '', text: 'Second letter', spoken: false);
    await pump(t);

    expect(find.text("Today's letter"), findsOneWidget);
    for (final h in ['FIRST TRIMESTER', 'SECOND TRIMESTER', 'THIRD TRIMESTER']) {
      expect(find.text(h), findsOneWidget, reason: h);
    }
    final y1 = t.getTopLeft(find.text('First letter')).dy;
    final y2 = t.getTopLeft(find.text('Second letter')).dy;
    final y3 = t.getTopLeft(find.text('Third letter')).dy;
    expect(y1 < y2 && y2 < y3, isTrue, reason: 'a vault reads as a story');
    expect(find.text('Spoken'), findsOneWidget);
  });
}
