// =============================================================================
//  The two apps should look like one product
// -----------------------------------------------------------------------------
//  A mother crosses from the pregnancy app into the parenting app by tapping a
//  single doorway on the pregnancy home — no loading, no transition. Two visual
//  languages one tap apart is the worst case for noticing a mismatch.
//
//  The palettes were already identical (the same hexes, declared twice). What
//  made the apps feel unrelated was FORM, and these tests pin the parts of that
//  which are cheap to assert and easy to regress.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/multichild_sheet.dart';
import 'package:parentveda/screens/post_pregnancy/my_child_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_common.dart';
import 'package:parentveda/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  // ---- the shared card language --------------------------------------------
  test('the parenting card lift matches the pregnancy app, not a purple glow', () {
    // Parenting cards used to float on #6A30B6 @15%, blur 26, spread -12, y+14.
    // Pregnancy cards sit on an ink lift with no spread. Side by side that read
    // as two design teams, and it was the single biggest visual tell.
    expect(ppCardShadow.length, 1);
    final s = ppCardShadow.first;
    expect(s.color, const Color(0x0D2D144C), reason: 'ink-tinted, not purple');
    expect(s.blurRadius, 22);
    expect(s.spreadRadius, 0, reason: 'a negative spread is what made cards hover');
    expect(s.offset, const Offset(0, 10));
  });

  test('the parenting card radius matches the pregnancy home', () {
    // Parenting radii had drifted across 16/17/18/20/22/24/26 because every
    // card hand-rolled its own decoration. ppCardRadius is the fix.
    expect(ppCardRadius, 26);
  });

  test('the palettes are the same values, so only form can diverge', () {
    expect(ppPurple, AppTheme.primary);
    expect(ppCoral, AppTheme.secondary);
    expect(ppBg, AppTheme.scaffoldBackground);
    expect(ppTitleInk, AppTheme.primary900);
  });

  test('ppCardDecoration is the one card shell', () {
    final d = ppCardDecoration();
    expect(d.boxShadow, ppCardShadow);
    expect((d.border as Border).top.color, ppLine);
    expect(d.borderRadius, BorderRadius.circular(ppCardRadius));

    // Tinted is the pregnancy HomeCard's highlighted-module treatment.
    final t = ppCardDecoration(accent: ppPurple, tinted: true);
    expect(t.gradient, isNotNull);
    expect(t.color, isNull);
  });

  // ---- the merged hero ------------------------------------------------------
  testWidgets('the home states the child once, not twice', (tester) async {
    // The leap header said "AARAV IS IN / Leap 4" and the identity block
    // immediately below said "Curious Explorer / Aarav" — the name printed
    // twice, back to back, for ~90pt of nothing new.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MyChildScreen(home: true)));
    await tester.pump();

    final name = ChildProfileStore.instance.name;
    expect(find.text(name), findsOneWidget, reason: 'the name is printed more than once again');
    // The old header's phrasing is gone with it.
    expect(find.text('${name.toUpperCase()} IS IN'), findsNothing);
  });

  testWidgets('the child switcher is reachable from the home', (tester) async {
    // MultiChildSheet was fully built and orphaned: nothing opened it, and its
    // own header comment described an entry point ("tap Aarav ▾") that did not
    // exist. Tapping the name is that entry point.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MyChildScreen(home: true)));
    await tester.pump();

    await tester.tap(find.text(ChildProfileStore.instance.name));
    await tester.pumpAndSettle();

    expect(find.byType(MultiChildSheet), findsOneWidget);
    expect(find.text('Your children'), findsOneWidget);
  });

  testWidgets('the switcher lists real children, not hard-coded names', (tester) async {
    // It used to render the literals "Aarav" and "Meher", with the tap on the
    // second going to a "coming soon" snackbar — switchTo() was never called.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MultiChildSheet())));
    await tester.pump();

    final store = ChildProfileStore.instance;
    for (final c in store.children) {
      expect(find.text(c.name), findsOneWidget, reason: '${c.name} missing from the switcher');
    }
    // "Meher" was a literal in the old sheet; she only appears if she is real.
    if (!store.children.any((c) => c.name == 'Meher')) {
      expect(find.text('Meher'), findsNothing, reason: 'a hard-coded child came back');
    }
  });
}
