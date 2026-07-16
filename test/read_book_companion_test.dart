// =============================================================================
//  Book Companion — the reading experience
// -----------------------------------------------------------------------------
//  Books with a companion open BookCompanionScreen (hero + sticky nav +
//  progress); everything else still opens the generic Learn V2 reader.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/read_next_data.dart';
import 'package:parentveda/models/read_item.dart';
import 'package:parentveda/screens/book_companion_screen.dart';
import 'package:parentveda/services/book_companion_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

ReadItem get _book => kReadItems.firstWhere((r) => r.id == 'book_what_to_expect');

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: BookCompanionScreen(item: _book, controller: PregnancyController())));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
}

Future<void> _scrollTo(WidgetTester tester, Finder f) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 40 && f.evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pump();
  }
  await tester.ensureVisible(f);
  await tester.pump();
  // Nudge back so the target is not sitting under the pinned nav bar, which
  // would otherwise swallow the tap.
  await tester.drag(scrollable, const Offset(0, 150));
  await tester.pumpAndSettle();
}

/// The nav bar scrolls horizontally, so later chips are not built until the
/// bar is scrolled to them.
Future<void> _navTo(WidgetTester tester, String id) async {
  final nav = find.descendant(
    of: find.byKey(const ValueKey('companion-nav')),
    matching: find.byType(Scrollable),
  );
  final chip = find.byKey(ValueKey('navchip-$id'));
  for (var i = 0; i < 10 && chip.evaluate().isEmpty; i++) {
    await tester.drag(nav, const Offset(-160, 0));
    await tester.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    BookCompanionStore.instance.reset('book_what_to_expect');
  });

  // ---- content contract (fixed by the writing Bible) ------------------------
  test('the companion carries every section the Bible requires', () {
    final c = _book.companion!;
    expect(_book.hasCompanion, isTrue);
    expect(_book.readingTime, '8 min');
    expect(c.recommendedFor, isNotEmpty);
    expect(c.themes, isNotEmpty);
    expect(c.about, isNotEmpty);
    expect(c.authorIntro, isNotEmpty, reason: 'About the Author is part of the hierarchy');
    expect(c.otherBooks.length, 3);
    expect(c.philosophy, isNotEmpty);
    expect(c.ideas.length, 5, reason: 'five ideas is a hard cap');
    expect(c.chapters.length, 6);
    expect(c.perspective, isNotEmpty);
    expect(c.quotes.length, 2);
    for (final i in c.ideas) {
      expect(i.body, isNotEmpty);
      expect(i.pointers.length, inInclusiveRange(2, 3));
    }
    for (final ch in c.chapters) {
      expect(ch.keyPoints, isNotEmpty, reason: '${ch.title} has no key points');
    }
  });

  test('the ParentVeda Rating stays a future-ready placeholder, not an invented number', () {
    // The Bible says keep room for it and do NOT implement one. A made-up score
    // on a book would be the same mistake the Product Guide work avoided.
    expect(_book.companion!.parentVedaRating, isNull);
  });

  // ---- hero -----------------------------------------------------------------
  testWidgets('the hero answers "what is this book?" before asking anything', (tester) async {
    await _pump(tester);
    expect(find.text("What to Expect When You're Expecting"), findsWidgets);
    expect(find.text('Heidi Murkoff'), findsOneWidget);
    expect(find.text('8 min'), findsOneWidget);
    expect(find.text('RECOMMENDED FOR'), findsOneWidget);
    expect(find.text('THEMES'), findsOneWidget);
    expect(find.text('Read summary'), findsOneWidget);
  });

  // ---- sticky navigation ----------------------------------------------------
  testWidgets('section chips are present and stay pinned while scrolling', (tester) async {
    await _pump(tester);
    // By key, not by label: "Ideas" and "Chapters" also name the progress
    // meters in the hero, so the text alone is ambiguous.
    for (final id in ['overview', 'ideas', 'chapters', 'take', 'quotes']) {
      await _navTo(tester, id);
      expect(find.byKey(ValueKey('navchip-$id')), findsOneWidget, reason: '$id chip missing');
    }
    // Scroll a long way down; the bar is pinned, so it is still there.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2500));
    await tester.pump();
    expect(find.byKey(const ValueKey('companion-nav')), findsOneWidget,
        reason: 'the nav bar did not stay pinned while scrolling');
  });

  testWidgets('tapping a chip jumps to that section', (tester) async {
    await _pump(tester);
    await _navTo(tester, 'quotes');
    await tester.tap(find.byKey(const ValueKey('navchip-quotes')));
    await tester.pumpAndSettle();
    // The quotes section renders its context tag once it is on screen.
    expect(find.textContaining('copilot'), findsOneWidget);
  });

  // ---- accordions -----------------------------------------------------------
  testWidgets('ideas are collapsed by default and open on tap', (tester) async {
    await _pump(tester);
    await _scrollTo(tester, find.text('Every Pregnancy Is Its Own Story'));
    expect(find.text('Every Pregnancy Is Its Own Story'), findsOneWidget);
    expect(find.textContaining('No two pregnancies unfold'), findsNothing);

    await tester.tap(find.text('Every Pregnancy Is Its Own Story'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No two pregnancies unfold'), findsOneWidget);
  });

  testWidgets('a chapter opens to its sub-labelled key points', (tester) async {
    await _pump(tester);
    await _scrollTo(tester, find.text('First Trimester (Months 1–3)'));
    expect(find.text('KEY POINTS COVERED'), findsNothing);

    await tester.tap(find.text('First Trimester (Months 1–3)'));
    await tester.pumpAndSettle();
    expect(find.text('KEY POINTS COVERED'), findsOneWidget);
    expect(find.text("Baby's Development"), findsOneWidget);
    expect(find.text('Your Body and Emotions'), findsOneWidget);
  });

  // ---- progress -------------------------------------------------------------
  testWidgets('opening an idea moves reading progress', (tester) async {
    await _pump(tester);
    expect(find.text('0 / 5'), findsOneWidget);

    await _scrollTo(tester, find.text('Every Pregnancy Is Its Own Story'));
    await tester.tap(find.text('Every Pregnancy Is Its Own Story'));
    await tester.pumpAndSettle();

    expect(BookCompanionStore.instance.ideasExplored('book_what_to_expect'), 1);
  });

  test('progress means explored, not completed — collapsing does not undo it', () {
    final s = BookCompanionStore.instance;
    s.reset('b');
    s.markIdea('b', 0);
    s.markIdea('b', 0); // idempotent
    expect(s.ideasExplored('b'), 1);
    s.markChapter('b', 3);
    expect(s.chaptersExplored('b'), 1);
    expect(s.ideaOpened('b', 0), isTrue);
    expect(s.ideaOpened('b', 1), isFalse);
  });
}
