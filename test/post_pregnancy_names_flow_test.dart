// Functional test: the Baby Name Finder swipe deck advances on pass, raises the
// "It's a match!" celebration on a mutual like, and opens the shared list.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/name_swipe_screen.dart';

void main() {
  testWidgets('Name Finder: pass, match, then open the shared list', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: NameSwipeScreen()));
    await tester.pump();

    // First card is the hero, Aarav.
    expect(find.text('Aarav'), findsWidgets);

    // Pass → the card flies off and the next name (Vihaan) comes forward.
    await tester.tap(find.byKey(const ValueKey('name-pass')));
    await tester.pumpAndSettle();
    expect(find.text('Vihaan'), findsWidgets);

    // Like Vihaan — a mutual yes — and the celebration overlay appears.
    await tester.tap(find.byKey(const ValueKey('name-like')));
    await tester.pumpAndSettle();
    expect(find.text("It's a match!"), findsOneWidget);

    // Open the shared shortlist from the overlay.
    await tester.tap(find.text('See our list'));
    await tester.pumpAndSettle();
    expect(find.text('Names you both love'), findsOneWidget);
  });

  testWidgets('Name Finder: drag left passes, drag right matches', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: NameSwipeScreen()));
    await tester.pump();
    expect(find.text('Aarav'), findsOneWidget);

    // Drag the card left past the threshold → pass → next name comes forward.
    await tester.drag(find.text('Aarav'), const Offset(-320, 0));
    await tester.pumpAndSettle();
    expect(find.text('Vihaan'), findsOneWidget);

    // Drag right on Vihaan (a mutual yes) → like → the match overlay fires.
    await tester.drag(find.text('Vihaan'), const Offset(320, 0));
    await tester.pumpAndSettle();
    expect(find.text("It's a match!"), findsOneWidget);
  });
}
