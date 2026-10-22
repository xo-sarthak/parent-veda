// =============================================================================
//  The bump ritual — the album, and what the design forbids
// -----------------------------------------------------------------------------
//  Built from the Claude Design board (2026-09-11): 1a's top — header, add
//  card, Then & Now — over 1b's album, trimester bands with a two-up grid
//  read forward. The tests hold the design's rules rather than its pixels:
//
//    · every week from this one back to 4 is a row, newest first, with a
//      "+" that adds a photo FOR THAT WEEK (2026-10-22; this replaced the
//      trimester bands and "missing weeks are simply not drawn");
//    · each passed moment is written beside its week ("Halfway."), and the
//      moments still ahead are stated as pages not yet turned;
//    · a week's cover is its favourite, else its earliest, and the favourite
//      is one per week;
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
import 'package:parentveda/widgets/pv_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

BumpPhoto _photo(int week,
        {String caption = '', bool fav = false, String? id, int day = 0}) =>
    BumpPhoto(
      id: id ?? 'w$week',
      imageUrl: '', // resolves to nothing → the tinted box, no file access
      weekNumber: week,
      date: DateTime(2026, 5, 19)
          .add(Duration(days: (week - 8) * 7 + day)),
      caption: caption,
      isFavorite: fav,
    );

/// The add sheet's title, told apart from the row label and the chip.
Finder _sheetTitle(String text) => find.byWidgetPredicate(
    (w) => w is Text && w.data == text && w.style?.fontSize == 22);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    BumpStore.instance.debugSeed(const []);
  });

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

  testWidgets('the main view: header, add card, week rows newest first',
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

    // The trimester bands are gone (kept in the source for revert).
    expect(find.text('First trimester'), findsNothing);
    expect(find.text('Second trimester'), findsNothing);

    // Every week from this one back to 4 is a row, newest first.
    expect(find.text('Week 24 · this week'), findsOneWidget);
    for (var w = 4; w <= 24; w++) {
      expect(find.byKey(ValueKey('bump_week_row_$w')), findsOneWidget,
          reason: 'week $w');
      expect(find.byKey(ValueKey('bump_week_add_$w')), findsOneWidget,
          reason: 'week $w');
    }
    expect(find.byKey(const ValueKey('bump_week_row_25')), findsNothing);
    expect(find.byKey(const ValueKey('bump_week_row_3')), findsNothing);
    final y22 = tester.getTopLeft(find.text('Week 22')).dy;
    final y12 = tester.getTopLeft(find.text('Week 12')).dy;
    final y8 = tester.getTopLeft(find.text('Week 8')).dy;
    expect(y22, lessThan(y12));
    expect(y12, lessThan(y8));

    // A week without a photo is an invitation, not a gap.
    expect(find.text('Week 14'), findsOneWidget);
    expect(find.text('1 photo'), findsNWidgets(7));
    expect(find.text('Add one'), findsNWidgets(21 - 7));

    // A passed moment is written beside its week.
    expect(find.text('The first trimester ended here.'), findsOneWidget);
    expect(find.text('Halfway.'), findsOneWidget);

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

  testWidgets('a passed moment is written beside its week, photo or not',
      (tester) async {
    BumpStore.instance.debugSeed([_photo(22)]);
    await tester.pumpWidget(_host(_at(24)));
    await tester.pumpAndSettle();
    expect(find.text('Halfway.'), findsOneWidget);
    expect(find.text('Second trimester'), findsNothing);
  });

  testWidgets('the same week twice: the line drops the pair', (tester) async {
    BumpStore.instance.debugSeed([_photo(20), _photo(20)]);
    await tester.pumpWidget(_host(_at(20)));
    await tester.pumpAndSettle();
    expect(find.text('Any two of your photos, side by side.'), findsOneWidget);
  });

  testWidgets('empty: week rows from this week back to 4, no future frames',
      (tester) async {
    await tester.pumpWidget(_host(_at(9)));
    await tester.pumpAndSettle();
    expect(find.text('Week 9 · this week'), findsOneWidget);
    for (var w = 4; w <= 9; w++) {
      expect(find.byKey(ValueKey('bump_week_add_$w')), findsOneWidget,
          reason: 'week $w');
    }
    expect(find.text('Add one'), findsNWidgets(6));
    // The old three frames (this week and the next two) are gone.
    expect(find.text('Week 10'), findsNothing);
    expect(find.text('Week 11'), findsNothing);
  });

  testWidgets("a row's + opens the add sheet on that week", (tester) async {
    await tester.pumpWidget(_host(_at(9)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bump_week_add_7')));
    await tester.pumpAndSettle();
    expect(_sheetTitle('Week 7'), findsOneWidget);
    // This week is still a chip she can pick.
    await tester.tap(find.byKey(const ValueKey('bump_week_chip_9')));
    await tester.pump();
    expect(_sheetTitle('Week 9'), findsOneWidget);
  });

  testWidgets('a week ahead in the strip says why, and is not picked',
      (tester) async {
    await tester.pumpWidget(_host(_at(9)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bump_week_add_9')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bump_week_chip_10')), findsOneWidget);
    expect(find.byKey(const ValueKey('bump_week_chip_11')), findsOneWidget);
    expect(find.byKey(const ValueKey('bump_week_chip_12')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('bump_week_chip_10')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("You're not in week 10 yet. Add it when you get there."),
        findsOneWidget);
    expect(_sheetTitle('Week 9'), findsOneWidget);
    expect(_sheetTitle('Week 10'), findsNothing);
    PvToast.instance.dismiss();
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('the photo page offers Move to another week', (tester) async {
    BumpStore.instance.debugSeed([_photo(20)]);
    await tester.pumpWidget(_host(_at(22)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('bump_week_tile_w20')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bump_week_tile_w20')));
    await tester.pumpAndSettle();
    expect(find.text('Move to another week'), findsOneWidget);
  });

  test('adding to a past week saves it under that week', () async {
    await BumpStore.instance.addPhoto(
      sourcePath: 'missing.jpg', // no file: saveImage falls back to the path
      week: 19,
      journalLabel: 'Bump, week 19',
    );
    expect(BumpStore.instance.hasWeek(19), isTrue);
    expect(BumpStore.instance.photos.single.weekNumber, 19);
  });

  test('setWeek moves a photo to another week', () async {
    BumpStore.instance.debugSeed([_photo(20), _photo(22)]);
    await BumpStore.instance.setWeek('w20', 18);
    expect(BumpStore.instance.hasWeek(20), isFalse);
    expect(BumpStore.instance.photosForWeek(18).single.id, 'w20');
    expect(BumpStore.instance.photosForWeek(22).single.id, 'w22');
  });

  test('a favourite moved into a week with its own cover drops its heart',
      () async {
    BumpStore.instance.debugSeed([
      _photo(20, fav: true),
      _photo(18, id: 'a18', fav: true),
    ]);
    await BumpStore.instance.setWeek('w20', 18);
    expect(BumpStore.instance.coverFor(18)!.id, 'a18');
    expect(
        BumpStore.instance.photos.where((x) => x.isFavorite).map((x) => x.id),
        ['a18']);
  });

  test('the cover is the favourite, else the earliest; one favourite a week',
      () async {
    BumpStore.instance.debugSeed([
      _photo(20, id: 'b', day: 1),
      _photo(20, id: 'a', day: 0),
      _photo(20, id: 'c', day: 2),
      _photo(21, id: 'other', fav: true),
    ]);
    final s = BumpStore.instance;
    expect(s.coverFor(20)!.id, 'a', reason: 'earliest added');
    expect(s.photosForWeek(20).map((x) => x.id), ['a', 'b', 'c']);

    await s.toggleFavorite('c');
    expect(s.coverFor(20)!.id, 'c');
    expect(s.photosForWeek(20).map((x) => x.id), ['c', 'a', 'b']);

    await s.toggleFavorite('b');
    final favs = s.photos.where((x) => x.isFavorite).map((x) => x.id).toSet();
    expect(favs, {'b', 'other'},
        reason: 'exclusive within week 20, another week untouched');
    expect(s.coverFor(20)!.id, 'b');

    await s.toggleFavorite('b');
    expect(s.coverFor(20)!.id, 'a', reason: 'no favourite: back to earliest');
  });

  test('every caller opens the new screen', () {
    final c = PregnancyController();
    expect(pvDoorScreenFor('bump_journey', c), isA<BumpRitualScreen>());
    expect(pvDoorInlineToolFor('bump_journey', c), isA<BumpRitualBody>());
  });
}
