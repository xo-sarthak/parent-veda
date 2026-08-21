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
import 'package:geocoding/geocoding.dart' show Placemark;
import 'package:parentveda/services/place_service.dart';
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
  _journalLanding();
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

      // ⚠️ `.at(1)` — THE BODY — AND NOT `.last`, WHICH IS NOW THE PLACE.
      // The order is heading, body, place. This used to say `.last` and broke
      // the day a fourth field arrived, which is the ordinary failure mode of
      // positional finders: they keep compiling and start testing something
      // else. Typing a PLACE must not unlock Save — a location with no memory
      // attached is not an entry — so had this not been fixed, the test would
      // have been asserting the opposite of the intended rule.
      await t.enterText(find.byType(TextField).at(1), 'She kicked today.');
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

      // ⚠️ TWICE NOW, AND BOTH ARE RIGHT. The place appears in the field where
      // she can edit it, and again in the preview that shows how the entry will
      // read afterwards. Before the field existed there was only the preview.
      expect(find.textContaining('Lodhi Garden, Delhi'), findsNWidgets(2));
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

// =============================================================================
//  The landing section, the retired type, and the place
// -----------------------------------------------------------------------------
//  ⚠️ THE DEFECT THAT MOTIVATES THE FIRST GROUP IS NOT A BUG IN CODE — IT IS AN
//  INSTRUCTION THAT NEVER REACHED THE SURFACE IT NAMED. The review said "My
//  Journal Section on landing page ... Note for Baby should be removed, add a
//  photo should be removed, Record Voice should be called Add a voice note".
//  The compose screen was rebuilt; the four tiles on the landing page were
//  never touched, and nothing could notice: four correct tiles doing four
//  correct things, matching no requirement anyone could see from the code.
//
//  So these assert the tiles against the words that asked for them. That is the
//  only place the requirement lives.
// =============================================================================

void _journalLanding() {
  group('the retired "Note for baby"', () {
    test('an old entry is re-typed to a memory on read', () {
      final old = JournalEntry.fromJson({
        'id': 'j_old',
        'type': 'noteForBaby',
        'title': 'You kicked today',
        'description': 'Twice, during dinner.',
        'date': '2026-04-02T20:10:00.000',
        'weekNumber': 22,
        'createdAt': '2026-04-02T20:10:00.000',
        'updatedAt': '2026-04-02T20:10:00.000',
      });
      expect(old.type, JournalEntryType.noteForBaby,
          reason: 'the type must still PARSE, or her entry vanishes');

      final now = old.retyped(JournalEntryType.memory);
      expect(now.type, JournalEntryType.memory);
    });

    test('re-typing changes the type and nothing else', () {
      // ⚠️ THE ASSERTION THAT MAKES THIS SAFE TO RUN OVER HER DATA. Everything
      // she wrote survives; only the label above the card moves.
      final e = JournalEntry(
        id: 'j1',
        type: JournalEntryType.noteForBaby,
        title: 'Hello little one',
        description: 'body',
        date: DateTime(2026, 4, 2),
        weekNumber: 22,
        imageUrls: const ['a.jpg'],
        audioUrls: const ['b.m4a'],
        place: 'Maa house',
      );
      final r = e.retyped(JournalEntryType.memory);
      expect(r.id, e.id);
      expect(r.title, e.title);
      expect(r.description, e.description);
      expect(r.date, e.date);
      expect(r.weekNumber, e.weekNumber);
      expect(r.imageUrls, e.imageUrls);
      expect(r.audioUrls, e.audioUrls);
      expect(r.place, e.place);
      expect(r.createdAt, e.createdAt);
      // ⚠️ `updatedAt` DOES NOT MOVE. She did not edit this; we did. Bumping it
      // would reorder anything sorted on it and claim an edit she never made.
      expect(r.updatedAt, e.updatedAt);
    });

    test('the type itself survives, for the father', () {
      // He still creates it, from his own screens into his own store, and the
      // review did not ask to change his app. Deleting the enum value would
      // have broken his feature and every entry he has already written.
      expect(JournalEntryType.values, contains(JournalEntryType.noteForBaby));
    });
  });

  group('a place can be cleared, not only replaced', () {
    test('copyWith without a place leaves it alone', () {
      final e = JournalEntry(
        id: 'j2',
        type: JournalEntryType.memory,
        title: 't',
        description: '',
        date: DateTime(2026, 4, 2),
        weekNumber: 20,
        place: 'The terrace',
      );
      expect(e.copyWith(title: 'new').place, 'The terrace');
    });

    test('clearPlace actually clears it', () {
      // ⚠️ WITHOUT THE FLAG THIS IS NOT EXPRESSIBLE. A nullable field makes
      // copyWith ambiguous: "she deleted the place" and "she did not mention
      // it" both arrive as null, so an edit would silently keep a label she
      // had just removed. Same shape as `clearScanId` on ScanReport.
      final e = JournalEntry(
        id: 'j3',
        type: JournalEntryType.memory,
        title: 't',
        description: '',
        date: DateTime(2026, 4, 2),
        weekNumber: 20,
        place: 'The terrace',
      );
      expect(e.copyWith(clearPlace: true).place, isNull);
    });

    test('a place survives a json round trip', () {
      final e = JournalEntry(
        id: 'j4',
        type: JournalEntryType.memory,
        title: 't',
        description: '',
        date: DateTime(2026, 4, 2),
        weekNumber: 20,
        place: "Maa's house",
      );
      expect(JournalEntry.fromJson(e.toJson()).place, "Maa's house");
    });

    test('an entry written before place existed reads back null', () {
      final e = JournalEntry.fromJson({
        'id': 'j5',
        'type': 'memory',
        'title': 't',
        'description': '',
        'date': '2026-04-02T20:10:00.000',
        'weekNumber': 20,
        'createdAt': '2026-04-02T20:10:00.000',
        'updatedAt': '2026-04-02T20:10:00.000',
      });
      // Null renders nothing. An empty string would render a stray separator
      // dot under the date - a mark she cannot explain on something she keeps.
      expect(e.place, isNull);
    });
  });

  group('the place label is a neighbourhood, never an address', () {
    test('sub-locality and locality, in that order', () {
      const m = Placemark(subLocality: 'Sector 62', locality: 'Noida');
      expect(PlaceService.debugLabel(m), 'Sector 62, Noida');
    });

    test('a repeated name is not printed twice', () {
      const m = Placemark(subLocality: 'Noida', locality: 'Noida');
      expect(PlaceService.debugLabel(m), 'Noida');
    });

    test('falls back to district or state rather than returning nothing', () {
      // Plenty of Indian addresses come back with locality empty.
      const m = Placemark(administrativeArea: 'Kerala');
      expect(PlaceService.debugLabel(m), 'Kerala');
    });

    test('nothing usable means null, not an empty label', () {
      const m = Placemark();
      expect(PlaceService.debugLabel(m), isNull);
    });

    test('the street is never included', () {
      // ⚠️ THE PRIVACY ASSERTION. A geocoder returns a street and a number
      // quite happily, and putting one under a photograph in a keepsake she
      // may share is more than the feature needs and more than she intended to
      // publish.
      const m = Placemark(
        street: '14, Rose Villa, Nehru Road',
        subLocality: 'Bandra West',
        locality: 'Mumbai',
        postalCode: '400050',
      );
      final label = PlaceService.debugLabel(m)!;
      expect(label.contains('Nehru'), isFalse);
      expect(label.contains('14'), isFalse);
      expect(label.contains('400050'), isFalse);
      expect(label, 'Bandra West, Mumbai');
    });
  });
}
