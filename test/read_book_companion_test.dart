// Smoke test: the "What to Expect When You're Expecting" book in the pregnancy
// Read-Next carousel renders its rich companion (About / Key ideas / Chapters).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/read_next_data.dart';
import 'package:parentveda/screens/read_reader_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  testWidgets('What to Expect renders its book companion', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final book = kReadItems.firstWhere((r) => r.id == 'book_what_to_expect');
    expect(book.hasCompanion, isTrue);

    await tester.pumpWidget(MaterialApp(home: ReadReaderScreen(item: book, controller: PregnancyController())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('The most important ideas'), 300, scrollable: scrollable, maxScrolls: 50);
    expect(find.text('The most important ideas'), findsOneWidget);
    // Key ideas render as numbered "milestone" bars.
    await tester.scrollUntilVisible(find.text('1. Every pregnancy is its own story'), 300, scrollable: scrollable, maxScrolls: 50);
    expect(find.text('1. Every pregnancy is its own story'), findsOneWidget);
    expect(find.text('WHAT THE AUTHOR MEANS'), findsWidgets);

    // Chapters are collapsed teasers; Read more reveals the Key Points.
    await tester.scrollUntilVisible(find.text('Chapter by chapter'), 300, scrollable: scrollable, maxScrolls: 50);
    expect(find.text('Chapter by chapter'), findsOneWidget);
    expect(find.text('KEY POINTS COVERED'), findsNothing);

    // Reveal the chapter cards (they build lazily below the heading).
    for (var i = 0; i < 30 && find.text('Read more').evaluate().isEmpty; i++) {
      await tester.drag(scrollable, const Offset(0, -260));
      await tester.pump();
    }
    expect(find.text('Before You Conceive'), findsOneWidget);

    await tester.ensureVisible(find.text('Read more').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read more').first);
    await tester.pumpAndSettle();
    expect(find.text('KEY POINTS COVERED'), findsWidgets);
  });
}
