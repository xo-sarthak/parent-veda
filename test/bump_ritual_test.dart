// =============================================================================
//  The bump ritual — the album, and what the design forbids
// -----------------------------------------------------------------------------
//  Built from the Claude Design board (2026-09-11): 1a's top — header, add
//  card, Then & Now — over 1b's album, trimester bands with a two-up grid
//  read forward. The tests hold the design's rules rather than its pixels:
//
//    · the weeks sit in trimester bands, read forward like a book;
//    · missing weeks are simply not drawn;
//    · each band's line writes its moment in ("Halfway was week 20"), and
//      the moments still ahead are stated as pages not yet turned;
//    · no count as a score, no percentage, no streak, no trophy;
//    · empty is an invitation that names what it becomes.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/bump_photo.dart';
import 'package:parentveda/screens/belly_skin/bump_ritual_screen.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/services/bump_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

Widget _host(PregnancyController c) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: BumpRitualBody(controller: c),
          ),
        ),
      ),
    );

/// A controller at a given week.
PregnancyController _at(int week) {
  final c = PregnancyController();
  c.setDueDate(DateTime.now().add(Duration(days: (40 - week) * 7)));
  return c;
}

BumpPhoto _photo(int week, {String caption = '', bool fav = false}) => BumpPhoto(
      id: 'w$week',
      imageUrl: '', // resolves to nothing → the tinted box, no file access
      weekNumber: week,
      date: DateTime(2026, 5, 19).add(Duration(days: (week - 8) * 7)),
      caption: caption,
      isFavorite: fav,
    );

void main() {
  setUp(() => BumpStore.instance.debugSeed(const []));

  group('words and dates', () {
    test('weeks in words', () {
      expect(weeksInWords(8), 'Eight weeks');
      expect(weeksInWords(20), 'Twenty weeks');
      expect(weeksInWords(24), 'Twenty-four weeks');
      expect(weeksInWords(37), 'Thirty-seven weeks');
    });

    test('the date shape is the design\'s', () {
      expect(bumpDate(DateTime(2026, 8, 25)), 'Tue, 25 Aug');
    });
  });

  testWidgets('empty: an invitation, and the two features named', (tester) async {
    await tester.pumpWidget(_host(_at(9)));
    await tester.pumpAndSettle();
    expect(find.text('One photo a week, in the same spot.'), findsOneWidget);
    expect(find.text('Add your first photo'), findsOneWidget);
    expect(find.text('THEN & NOW'), findsOneWidget);
    expect(find.text('YOUR BOOK'), findsOneWidget);
    expect(find.text('Miss a week and nothing breaks. Most people do.'), findsOneWidget);
    // Nothing that reads as a task.
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('of 40'), findsNothing);
  });

  testWidgets('the main view: header, add card, trimester bands, read forward',
      (tester) async {
    BumpStore.instance.debugSeed([
      _photo(8, caption: 'The first one.'),
      _photo(10),
      _photo(12),
      _photo(16),
      _photo(18),
      _photo(20, caption: 'The scan day.'),
      _photo(22, caption: 'Kicks all through the night now.', fav: true),
    ]);
    await tester.pumpWidget(_host(_at(24)));
    await tester.pumpAndSettle();

    // The header is a description, never a progress state.
    expect(find.text('Twenty-four weeks'), findsOneWidget);
    expect(find.text("It runs from week 8 to week 22. This week isn't in it yet."),
        findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('7 photos'), findsNothing);
    expect(find.textContaining('Complete'), findsNothing);

    // This week is not in yet → the add card, at the top.
    expect(find.text('Add this week'), findsOneWidget);

    // Two bands, and no third — she has no third-trimester photo.
    expect(find.text('First trimester'), findsOneWidget);
    expect(find.text('Second trimester'), findsOneWidget);
    expect(find.text('Third trimester'), findsNothing);

    // Each band writes its moment into its line.
    expect(find.text('It ended in week 12.'), findsOneWidget);
    expect(find.text("Halfway was week 20. You're in week 24 now."), findsOneWidget);

    // Read forward: week 8 above week 12, week 12 above week 22.
    final y8 = tester.getTopLeft(find.text('Week 8')).dy;
    final y12 = tester.getTopLeft(find.text('Week 12')).dy;
    final y22 = tester.getTopLeft(find.text('Week 22')).dy;
    expect(y8, lessThan(y12));
    expect(y12, lessThan(y22));

    // Missing weeks are not drawn.
    expect(find.text('Week 14'), findsNothing);
    expect(find.text('Week 9'), findsNothing);

    // The two still ahead are pages not yet turned, not badges.
    expect(find.text('Still ahead'), findsOneWidget);
    expect(find.text('The third trimester begins'), findsOneWidget);
    expect(find.text('Full term'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsNothing);
    expect(find.byIcon(Icons.emoji_events_outlined), findsNothing);

    // Then & Now is offered, and the book is a row at the end.
    expect(find.text('Then & Now'), findsOneWidget);
    expect(find.text('Week 8 beside week 22, or any two you like.'), findsOneWidget);
    expect(find.text('Your bump journey book'), findsOneWidget);
  });

  testWidgets('this week in the book: no add card, the header says so',
      (tester) async {
    BumpStore.instance.debugSeed([_photo(22), _photo(24)]);
    await tester.pumpWidget(_host(_at(24)));
    await tester.pumpAndSettle();
    expect(find.text('Week 24 is in your book.'), findsOneWidget);
    expect(find.text('Add this week'), findsNothing);
  });

  testWidgets('one photo: Then & Now waits for a second', (tester) async {
    BumpStore.instance.debugSeed([_photo(12)]);
    await tester.pumpWidget(_host(_at(14)));
    await tester.pumpAndSettle();
    expect(find.text('Then & Now'), findsNothing);
    expect(find.textContaining('once you have two weeks'), findsOneWidget);
  });

  testWidgets('a band whose moment has passed says so even with one photo',
      (tester) async {
    BumpStore.instance.debugSeed([_photo(22)]);
    await tester.pumpWidget(_host(_at(24)));
    await tester.pumpAndSettle();
    expect(find.text('Second trimester'), findsOneWidget);
    expect(find.text("Halfway was week 20. You're in week 24 now."), findsOneWidget);
    expect(find.text('First trimester'), findsNothing,
        reason: 'no first-trimester photo, so no empty band');
  });

  testWidgets('the same week twice: the line drops the pair', (tester) async {
    BumpStore.instance.debugSeed([_photo(20), _photo(20)]);
    await tester.pumpWidget(_host(_at(20)));
    await tester.pumpAndSettle();
    expect(find.text('Any two of your photos, side by side.'), findsOneWidget);
  });

  test('every caller opens the new screen', () {
    final c = PregnancyController();
    expect(pvDoorScreenFor('bump_journey', c), isA<BumpRitualScreen>());
    expect(pvDoorInlineToolFor('bump_journey', c), isA<BumpRitualBody>());
  });
}
