// The Dear Baby vault as a keepsake (2026-10-10): the invitation is always on
// top before the birth, and letters read oldest first under their trimester.
// 2026-10-15 (STILL-OPEN §83.2): read aloud on every letter, the book sealed
// until birth, the opening at birth, and the way back to it from parenting.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/dear_baby_vault_screen.dart';
import 'package:parentveda/screens/profile/pv_you_content.dart';
import 'package:parentveda/services/daily_store.dart';
import 'package:parentveda/services/dear_baby_vault_store.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> fresh({bool letters = true}) async {
    SharedPreferences.setMockInitialValues({});
    DearBabyVaultStore.instance.resetForTest();
    DearBabyVaultScreen.resetSessionForTest();
    await DailyStore.instance.init();
    await DearBabyVaultStore.instance.init();
    if (letters) {
      final s = DailyStore.instance;
      if (s.talkEntries.isEmpty) {
        await s.saveTalk(day: 60, week: 9, prompt: '', text: 'First letter', spoken: true);
        await s.saveTalk(day: 120, week: 18, prompt: '', text: 'Second letter', spoken: false);
      }
    }
  }

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(1080, 4000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
        home: DearBabyVaultScreen(controller: PregnancyController())));
    await t.pumpAndSettle();
  }

  testWidgets('an empty vault invites the first letter', (t) async {
    await fresh(letters: false);
    await pump(t);
    expect(find.text('Letters to\nyour baby'), findsOneWidget);
    if (DailyStore.instance.talkEntries.isEmpty) {
      expect(find.text('Write your first letter'), findsOneWidget);
    }
    expect(find.text('Write'), findsOneWidget);
    expect(find.text('Say it aloud'), findsOneWidget);
  });

  testWidgets('letters sit under their trimester, oldest first', (t) async {
    await fresh(letters: false);
    final s = DailyStore.instance;
    await s.saveTalk(day: 200, week: 29, prompt: '', text: 'Third letter', spoken: false);
    await s.saveTalk(day: 60, week: 9, prompt: '', text: 'First letter', spoken: true);
    await s.saveTalk(day: 120, week: 18, prompt: '', text: 'Second letter', spoken: false);
    await pump(t);

    expect(find.text("Today's letter"), findsOneWidget);
    for (final h in ['FIRST TRIMESTER', 'SECOND TRIMESTER', 'THIRD TRIMESTER']) {
      expect(find.text(h), findsOneWidget, reason: h);
    }
    final y1 = t.getTopLeft(find.text('First letter').first).dy;
    final y2 = t.getTopLeft(find.text('Second letter').first).dy;
    final y3 = t.getTopLeft(find.text('Third letter').first).dy;
    expect(y1 < y2 && y2 < y3, isTrue, reason: 'a vault reads as a story');
    expect(find.text('Spoken'), findsWidgets);
  });

  testWidgets('before birth: read aloud on every letter, the book sealed', (t) async {
    await fresh();
    await pump(t);
    final n = DailyStore.instance.talkEntries.length;
    expect(find.text('Read aloud'), findsNWidgets(n));
    expect(find.text('Read them all aloud'), findsOneWidget);
    expect(find.text('Your letters, as a book'), findsOneWidget);
    expect(find.text('Download your letters book'), findsNothing);
    // The sealed book still answers a tap: it says when it opens.
    await t.tap(find.byKey(const ValueKey('dear_baby_book')));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Your book opens the day your baby is born.'), findsOneWidget);
    await t.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('a letter answers the tap before the voice starts', (t) async {
    await fresh();
    await pump(t);
    await t.tap(find.text('Read aloud').first);
    await t.pump();
    expect(find.text('Reading · Stop'), findsOneWidget);
    await t.tap(find.text('Reading · Stop'));
    await t.pump();
    expect(find.text('Reading · Stop'), findsNothing);
  });

  testWidgets('the loss path never opens anything', (t) async {
    await fresh();
    // No markBorn, no parenting stage: "My pregnancy ended" does neither.
    expect(DearBabyVaultStore.instance.unlocked,
        LifeStageStore.instance.stage == LifeStage.parenting);
    if (!DearBabyVaultStore.instance.unlocked) {
      await pump(t);
      expect(find.text('Open the envelope'), findsNothing);
    }
  });

  testWidgets('at birth the letters open, once, and the book unlocks', (t) async {
    await fresh();
    await DearBabyVaultStore.instance
        .markBorn(dob: DateTime(2027, 2, 14), childId: null, name: 'Asha');
    await pump(t);

    // The vault hands over to the opening on the first visit.
    expect(find.text('Welcome, Asha'), findsOneWidget);
    expect(find.text('Open the envelope'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('dear_baby_open_cta')));
    await t.pumpAndSettle();
    expect(find.text('Read your letters'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('dear_baby_open_cta')));
    await t.pumpAndSettle();

    expect(DearBabyVaultStore.instance.opened, isTrue);
    expect(find.text('Letters to\nAsha'), findsOneWidget);
    expect(find.text('Download your letters book'), findsOneWidget);
    // A letter written now would carry a pregnancy week that is over.
    expect(find.text('Write'), findsNothing);
    expect(find.text('Read aloud'), findsWidgets);
  });

  testWidgets('"Later" means later: no second hand-over this session', (t) async {
    await fresh();
    await DearBabyVaultStore.instance.markBorn(dob: DateTime(2027, 2, 14), name: 'Asha');
    await pump(t);
    await t.tap(find.text('Later'));
    await t.pumpAndSettle();
    expect(DearBabyVaultStore.instance.opened, isFalse);
    expect(find.text('Your letters are ready to open'), findsOneWidget);

    await t.pumpWidget(const SizedBox());
    await pump(t);
    expect(find.text('Open the envelope'), findsNothing);
  });

  testWidgets('the parenting home card shows only until they are opened', (t) async {
    await fresh();
    Future<void> card() async {
      await t.pumpWidget(MaterialApp(
          home: Scaffold(
              body: DearBabyLettersReadyCard(p: V2PaletteStore.instance.current))));
      await t.pump();
    }

    await card();
    if (!DearBabyVaultStore.instance.unlocked) {
      expect(find.byKey(const ValueKey('dear_baby_ready_card')), findsNothing);
    }
    await DearBabyVaultStore.instance.markBorn(dob: DateTime(2027, 2, 14));
    await card();
    expect(find.byKey(const ValueKey('dear_baby_ready_card')), findsOneWidget);
    await DearBabyVaultStore.instance.markOpened();
    await t.pump();
    expect(find.byKey(const ValueKey('dear_baby_ready_card')), findsNothing);
  });

  test('parenting You keeps the way back to the letters', () {
    final rows = pvYouContentFor(LifeStage.parenting).keepsakeThings;
    expect(rows.map((r) => r.title), contains('Dear Baby letters'));
    final row = rows.firstWhere((r) => r.title == 'Dear Baby letters');
    expect(row.shown, isNotNull,
        reason: 'a family that joined at parenting has no letters to show');
  });
}
