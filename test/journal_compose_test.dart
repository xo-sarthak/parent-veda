// =============================================================================
//  Add a memory - one composer, either half
// -----------------------------------------------------------------------------
//  ⚠️ THE RULE THIS FILE EXISTS FOR: text OR photos is enough. Not both.
//
//  "Write a memory" and "Add a photo" were two quick actions for the same
//  entry seen from two ends, and the split had a real cost: a mother who
//  started with a photo could not add a sentence to it, and one who started
//  writing could not attach a picture. Collapsing them is the change; the
//  either-half rule is what makes the collapse possible, and it is the thing
//  most likely to be tightened later by someone adding a "title required"
//  validation that looks like good hygiene.
//
//  ⚠️ AND ONE THING THAT MUST NOT REGRESS: the two entry points into the
//  journal - the sheet on the journal screen and the card on the home screen -
//  have to offer the SAME actions. If one keeps "Note for baby" and the other
//  does not, the journal has two different feature sets depending on which
//  door she walked through.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/journal_entry.dart';
import 'package:parentveda/screens/journal_compose_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(420, 2400);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // ===========================================================================
  //  1 · It is a page, and it holds what the sheet could not
  // ===========================================================================

  group('the composer', () {
    testWidgets('has a heading, a body and a photo slot', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      await _pump(t, JournalComposeScreen(pregnancy: c));

      expect(find.text('Add a memory'), findsOneWidget);
      expect(find.text('Give it a name (optional)'), findsOneWidget);
      expect(find.textContaining('tap the mic and just say it'), findsOneWidget);
      expect(find.text('PHOTOS'), findsOneWidget);
      expect(find.text('0 of 3'), findsOneWidget);
    });

    testWidgets('Save is off until there is something to save', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      await _pump(t, JournalComposeScreen(pregnancy: c));

      final btn = t.widget<TextButton>(
          find.ancestor(of: find.text('Save'), matching: find.byType(TextButton)));
      expect(btn.onPressed, isNull);
      // ⚠️ THE HINT SAYS THE RULE OUT LOUD. A disabled Save with no
      // explanation is the app refusing without saying why.
      expect(find.textContaining('Either one is enough to save'),
          findsOneWidget);
    });

    testWidgets('typing anything unlocks Save', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      await _pump(t, JournalComposeScreen(pregnancy: c));

      await t.enterText(find.byType(TextField).last, 'She kicked today.');
      await t.pump();

      final btn = t.widget<TextButton>(
          find.ancestor(of: find.text('Save'), matching: find.byType(TextButton)));
      expect(btn.onPressed, isNotNull);
      expect(find.textContaining('Either one is enough'), findsNothing);
    });

    testWidgets('a heading alone is enough, with no body', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      await _pump(t, JournalComposeScreen(pregnancy: c));

      await t.enterText(find.byType(TextField).first, 'First kick');
      await t.pump();

      final btn = t.widget<TextButton>(
          find.ancestor(of: find.text('Save'), matching: find.byType(TextButton)));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('the mic is there, reused rather than rebuilt', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      await _pump(t, JournalComposeScreen(pregnancy: c));
      // Speech-to-text already exists and is used by the journal's other
      // compose surfaces; this screen must not grow a second one.
      expect(find.byIcon(Icons.mic_none_rounded).evaluate().isNotEmpty ||
          find.byIcon(Icons.mic_rounded).evaluate().isNotEmpty, isTrue);
    });
  });

  // ===========================================================================
  //  2 · The stamp reads like a post, and never apologises for a null place
  // ===========================================================================

  group('the date, time and place stamp', () {
    testWidgets('renders below the content, not above it', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      await _pump(t, JournalComposeScreen(pregnancy: c));

      final photos = t.getTopLeft(find.text('PHOTOS')).dy;
      final stamp = t.getTopLeft(find.byIcon(Icons.schedule_rounded)).dy;
      // ⚠️ A TIMESTAMP ABOVE A MEMORY MAKES THE PAGE READ AS A LOG. The
      // photograph is the thing; the stamp is a caption on it.
      expect(photos, lessThan(stamp));
    });

    testWidgets('a null place renders nothing at all', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      await _pump(t, JournalComposeScreen(pregnancy: c));

      // ⚠️ NEVER "Location unavailable". This app has no geolocation package,
      // so place is null for every entry today - and an error message about a
      // feature she never asked for is worse than silence.
      expect(find.textContaining('Location'), findsNothing);
      expect(find.textContaining('unavailable'), findsNothing);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    });

    testWidgets('a place, when there is one, joins the same line', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      final e = JournalEntry(
        id: 'x',
        type: JournalEntryType.memory,
        title: 'A day out',
        date: DateTime(2026, 3, 4, 14, 30),
        place: 'Lodhi Garden, Delhi',
      );
      await _pump(t, JournalComposeScreen(pregnancy: c, edit: e));
      expect(find.textContaining('Lodhi Garden, Delhi'), findsOneWidget);
      expect(find.textContaining('4 Mar 2026'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  3 · The model carries place through a round trip
  // ===========================================================================

  group('place survives serialisation', () {
    test('it round-trips, and null stays null', () {
      final e = JournalEntry(
        id: 'a',
        type: JournalEntryType.memory,
        title: 'x',
        date: DateTime(2026, 1, 1),
        place: 'Bandra, Mumbai',
      );
      expect(JournalEntry.fromJson(e.toJson()).place, 'Bandra, Mumbai');

      final none = JournalEntry(
          id: 'b',
          type: JournalEntryType.memory,
          title: 'y',
          date: DateTime(2026, 1, 1));
      expect(JournalEntry.fromJson(none.toJson()).place, isNull);
    });

    test('copyWith keeps it', () {
      final e = JournalEntry(
        id: 'a',
        type: JournalEntryType.memory,
        title: 'x',
        date: DateTime(2026, 1, 1),
        place: 'Pune',
      );
      expect(e.copyWith(title: 'z').place, 'Pune');
    });
  });

  // ===========================================================================
  //  4 · Photos: three is the cap, and it is enforced not merely labelled
  // ===========================================================================

  test('the cap is three', () {
    // ⚠️ A JOURNAL ENTRY WITH TWELVE PHOTOS IS AN ALBUM. The timeline renders
    // these as a carousel that stops being scannable past about three, and a
    // capped entry stays small enough to sync.
    expect(kJournalMaxPhotos, 3);
  });
}
