// Functional test: the Baby Name swipe deck advances on pass, confirms a like,
// and opens the shortlist.
//
// These assertions used to say "It's a match!" on "a mutual yes" - but nothing
// in the naming code knows about a partner, so the celebration fired on ONE
// person's like. The copy (and these tests with it) now describe what actually
// happened. Restore the mutual language only when name_votes lands and a match
// is derived from both parents' votes - see
// docs/BACKEND-COUPLE-NAMING-BRIEF.md §4.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/name_swipe_screen.dart';

void main() {
  testWidgets('Name swipe: pass, like, then open the shortlist', (tester) async {
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

    // Like Vihaan - HER like alone - and the confirmation overlay appears.
    await tester.tap(find.byKey(const ValueKey('name-like')));
    await tester.pumpAndSettle();
    expect(find.text('Added to your list'), findsOneWidget);

    // Open the shortlist from the overlay.
    await tester.tap(find.text('See our list'));
    await tester.pumpAndSettle();
    expect(find.text('Names you love'), findsOneWidget);
  });

  testWidgets('Name swipe: drag left passes, drag right likes', (tester) async {
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

    // Drag right on Vihaan → like → the confirmation overlay fires.
    await tester.drag(find.text('Vihaan'), const Offset(320, 0));
    await tester.pumpAndSettle();
    expect(find.text('Added to your list'), findsOneWidget);
  });
}
