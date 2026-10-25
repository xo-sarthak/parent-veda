// Functional test: the Baby Name swipe deck passes, likes, and opens the
// shortlist.
//
// MOVED ONTO THE LIVE DECK (tools pass 31, 2026-10-26). These tests drove the
// retired V1 `NameSwipeScreen`, which no way into the app opens any more, and
// its "Added to your list" overlay fired on three names carrying a leftover
// fake-match flag. The flag is gone, so the overlay is gone with it; the live
// deck (`NameJourneyFeedScreen`) is what a parent swipes. The V1 tests are kept
// below, commented, for revert.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/name_journey_feed_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_names_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_names_v2_data.dart';

Future<void> _openDeck(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: NameJourneyFeedScreen(startAtQuiz: true)));
  await tester.pump();
  final start = find.byKey(const ValueKey('pp_names_quiz_start'));
  await tester.ensureVisible(start);
  await tester.pumpAndSettle();
  await tester.tap(start);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('pp_names_primer_begin')));
  await tester.pumpAndSettle();
}

List<BabyName> _unanswered() => [
      for (final n in namesForSelection(gender: 'Both', community: 'Any', region: 'Any', vibes: {}))
        if (!NameMatchStore.instance.hasVoted(n.name)) n,
    ];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Name deck: pass, like, then open the shortlist', (tester) async {
    await _openDeck(tester);
    final deck = _unanswered();
    expect(find.text(deck[0].name), findsWidgets);

    // Pass: the next name comes forward.
    await tester.tap(find.bySemanticsLabel('Not for us').first);
    await tester.pumpAndSettle();
    expect(find.text(deck[1].name), findsWidgets);

    // Like: it goes into her shortlist.
    await tester.tap(find.bySemanticsLabel('We like this').first);
    await tester.pumpAndSettle();
    expect(NameMatchStore.instance.isLiked(deck[1].name), isTrue);

    // Open the shortlist from the counter.
    await tester.tap(find.bySemanticsLabel(RegExp(r'in your shortlist$')).first);
    await tester.pumpAndSettle();
    expect(find.text('Your shortlist'), findsOneWidget);
  });

  testWidgets('Name deck: drag left passes, drag right likes', (tester) async {
    await _openDeck(tester);
    final deck = _unanswered();

    await tester.drag(find.text(deck[0].name).first, const Offset(-320, 0));
    await tester.pumpAndSettle();
    expect(find.text(deck[1].name), findsWidgets);
    expect(NameMatchStore.instance.hasVoted(deck[0].name), isTrue);

    await tester.drag(find.text(deck[1].name).first, const Offset(320, 0));
    await tester.pumpAndSettle();
    expect(NameMatchStore.instance.isLiked(deck[1].name), isTrue);
  });
}

// Kept for revert (tools pass 31): the V1 screen's tests.
//
// import 'package:parentveda/screens/post_pregnancy/name_swipe_screen.dart';
//
// testWidgets('Name swipe: pass, like, then open the shortlist', (tester) async {
//   await tester.pumpWidget(const MaterialApp(home: NameSwipeScreen()));
//   await tester.pump();
//   expect(find.text('Aarav'), findsWidgets);
//   await tester.tap(find.byKey(const ValueKey('name-pass')));
//   await tester.pumpAndSettle();
//   expect(find.text('Vihaan'), findsWidgets);
//   await tester.tap(find.byKey(const ValueKey('name-like')));
//   await tester.pumpAndSettle();
//   expect(find.text('Added to your list'), findsOneWidget);
//   await tester.tap(find.text('See our list'));
//   await tester.pumpAndSettle();
//   expect(find.text('Names you love'), findsOneWidget);
// });
//
// testWidgets('Name swipe: drag left passes, drag right likes', (tester) async {
//   await tester.pumpWidget(const MaterialApp(home: NameSwipeScreen()));
//   await tester.pump();
//   await tester.drag(find.text('Aarav'), const Offset(-320, 0));
//   await tester.pumpAndSettle();
//   expect(find.text('Vihaan'), findsOneWidget);
//   await tester.drag(find.text('Vihaan'), const Offset(320, 0));
//   await tester.pumpAndSettle();
//   expect(find.text('Added to your list'), findsOneWidget);
// });
