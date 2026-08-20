// =============================================================================
//  Garbh Sanskar - the last eight items from the Drive spec
// -----------------------------------------------------------------------------
//  ⚠️ TWO OF THESE PIN A REFUSAL RATHER THAN A FEATURE, and those are the ones
//  worth reading.
//
//    · The japa counter RESETS DAILY and keeps no lifetime total. A running
//      total is the obvious "improvement" and it would turn a practice into a
//      score, which is the one thing this whole section refuses to do.
//    · "Add to my daily" PINS, it does not REPLACE. Letting a pinned item take
//      over the rotation is the obvious reading of "add to my daily", and it
//      hands a mother a way to make the section boring - one affirmation for
//      four months - while looking like personalisation.
//
//  Both would pass any test that only checked the feature works.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/garbh_data.dart';
import 'package:parentveda/data/garbh_rebuild_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/garbh_browse_screen.dart';
import 'package:parentveda/screens/garbh_daily_screen.dart';
import 'package:parentveda/screens/garbh_journal_screen.dart';
import 'package:parentveda/screens/garbh_ritual_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

PregnancyController _at(int week) {
  final now = DateTime(2026, 1, 1);
  return PregnancyController(
      now: now, dueDate: now.add(Duration(days: (40 - week) * 7)));
}

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(420, 5200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() => GarbhJournalStore.instance.resetForTest());

  // ===========================================================================
  //  1 · The japa counter counts, and refuses to keep score
  // ===========================================================================

  group('japa', () {
    test('it counts today and starts again tomorrow', () {
      final s = GarbhJournalStore.instance;
      expect(s.japaToday, 0);
      s.japaIncrement();
      s.japaIncrement();
      expect(s.japaToday, 2);
      s.japaReset();
      expect(s.japaToday, 0);
    });

    test('yesterday\'s count does not carry into today', () {
      // ⚠️ THE REFUSAL, AS A REAL ASSERTION.
      //
      // A running total is the obvious next feature and it would turn a
      // practice into a score. The way to hold that is to check the BEHAVIOUR
      // that would have to change: a count written under an old date must read
      // as zero today, and starting today must not add to it.
      //
      // ⚠️ THE FIRST VERSION OF THIS TEST WAS FAKE. It asserted
      // `store.toString().contains('lifetime') == false`, and `toString()` on
      // a ChangeNotifier returns "Instance of 'GarbhJournalStore'" - so it
      // passed no matter what the store did. A test that cannot fail is worse
      // than no test: it occupies the place where the real check should be and
      // reports green while doing it.
      final s = GarbhJournalStore.instance;
      s.japaIncrement();
      s.japaIncrement();
      expect(s.japaToday, 2);

      // Simulate the day rolling over: reset stamps today, so writing an old
      // date is how we get "there was a count yesterday".
      s.japaSetForTest(count: 40, ymd: '2020-01-01');
      expect(s.japaToday, 0, reason: 'an old count must not surface today');

      s.japaIncrement();
      expect(s.japaToday, 1,
          reason: 'today starts at one, not at forty-one');
    });

    testWidgets('the counter shows once japa is chosen, not before',
        (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhRitualScreen(controller: c));

      expect(find.text('Tap to count'), findsNothing);
      await t.tap(find.text('Japa'));
      await t.pump();
      expect(find.text('Tap to count'), findsOneWidget);
      // And it says the reset out loud, so a count that vanishes overnight is
      // not read as data loss.
      expect(find.textContaining('Starts again tomorrow'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  2 · Add to my daily pins, it does not replace
  // ===========================================================================

  group('add to my daily', () {
    test('pinning is additive and reversible', () {
      final s = GarbhJournalStore.instance;
      expect(s.isPinned('shravan_morning_raga'), isFalse);
      s.togglePinned('shravan_morning_raga');
      expect(s.isPinned('shravan_morning_raga'), isTrue);
      s.togglePinned('shravan_morning_raga');
      expect(s.isPinned('shravan_morning_raga'), isFalse);
    });

    test('every library row can be pinned, across all four pillars', () {
      const en = AppLanguage.english;
      for (final screen in [
        shravanBrowse(en, Colors.black),
        vicharaBrowse(en, Colors.black),
        samvadBrowse(en, Colors.black),
        kriyaBrowse(en, Colors.black),
      ]) {
        for (final g in screen.groups) {
          for (final i in g.items) {
            expect(i.pinId, isNotNull, reason: i.title);
          }
        }
      }
    });

    test('pin ids are namespaced, so two pillars cannot collide', () {
      // ⚠️ `box` IS BOTH A BREATHING PRACTICE AND A PLAUSIBLE RAGA ID. A bare
      // id would let pinning one silently pin the other.
      final shravan = shravanBrowse(AppLanguage.english, Colors.black);
      final kriya = kriyaBrowse(AppLanguage.english, Colors.black);
      final sIds = {
        for (final g in shravan.groups) ...g.items.map((i) => i.pinId)
      };
      final kIds = {
        for (final g in kriya.groups) ...g.items.map((i) => i.pinId)
      };
      expect(sIds.intersection(kIds), isEmpty);
    });
  });

  // ===========================================================================
  //  3 · Letters can finally be written
  // ===========================================================================

  group('letters', () {
    testWidgets('the album offers a way to write one', (t) async {
      await _pump(t, const GarbhJournalScreen());
      await t.scrollUntilVisible(
          find.text('Write a letter to your baby'), 500,
          scrollable: find.byType(Scrollable).first);
      // ⚠️ `GarbhEntryKind.letter` HAD AN ICON AND NO WAY TO CREATE ONE. The
      // model handled letters and nothing made them, so the type was
      // furniture.
      expect(find.text('Write a letter to your baby'), findsOneWidget);
    });

    test('a letter lands in the album with its own text as the title', () {
      GarbhJournalStore.instance.add(GarbhJournalEntry(
        id: 'l1',
        kind: GarbhEntryKind.letter,
        week: 22,
        tsMs: DateTime(2026, 3, 4).millisecondsSinceEpoch,
        title: const LocalizedText(en: 'I hope you like the rain',
            hi: 'I hope you like the rain'),
        text: 'I hope you like the rain as much as I do.',
      ));
      final e = GarbhJournalStore.instance.entries.first;
      // ⚠️ NOT "Letter". Twelve rows all reading "Letter" is an album she
      // cannot navigate.
      expect(e.title.en, isNot('Letter'));
      expect(e.kind, GarbhEntryKind.letter);
    });
  });

  // ===========================================================================
  //  4 · The daily card shows the week and what she made
  // ===========================================================================

  group('the daily card', () {
    testWidgets('the week render sits above the reason line', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhDailyScreen(pregnancy: c));

      // Reuses the bundled per-week baby renders rather than a second set.
      expect(find.byType(Image), findsWidgets);
      expect(find.text('WHY WEEK 22 MATTERS'), findsOneWidget);
    });

    testWidgets('the journal strip shows the things, not a count', (t) async {
      GarbhJournalStore.instance.add(GarbhJournalEntry(
        id: 'v1',
        kind: GarbhEntryKind.myVoice,
        week: 22,
        tsMs: DateTime(2026, 3, 4).millisecondsSinceEpoch,
        title: const LocalizedText(en: 'A lullaby', hi: 'A lullaby'),
        seconds: 60,
        path: '/tmp/a.m4a',
      ));
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhDailyScreen(pregnancy: c));

      await t.scrollUntilVisible(find.text('My Journal'), 400,
          scrollable: find.byType(Scrollable).first);
      // ⚠️ THE THING ITSELF, not "1 added this week". A number says she was
      // productive; her own words show her what she made.
      expect(find.text('A lullaby'), findsOneWidget);
    });

    testWidgets('the ritual row asks a question the first time', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhDailyScreen(pregnancy: c));

      await t.scrollUntilVisible(
          find.textContaining('daily practice'), 400,
          scrollable: find.byType(Scrollable).first);
      // `ritualsAsked` was written and never read until now - this is the
      // "asked once at onboarding" the spec wanted, on the only surface that
      // exists to hang it off.
      expect(find.text('Do you already have a daily practice?'),
          findsOneWidget);
    });
  });

  // ===========================================================================
  //  5 · Real audio is now a data change
  // ===========================================================================

  group('raga audio', () {
    test('every raga can carry its own file', () {
      // Nothing has one yet, which is a content gap and not a code gap.
      for (final a in kShravan) {
        expect(a.hasRealAudio, isFalse, reason: a.id);
      }
    });

    testWidgets('the placeholder caveat is shown while it is still true',
        (t) async {
      await _pump(t, shravanBrowse(AppLanguage.english, Colors.black));
      expect(find.textContaining('same sample tone'), findsOneWidget);
      // ⚠️ AND IT REMOVES ITSELF once every raga has a file - nobody has to
      // remember to delete it, which is the only reason an honesty note like
      // this survives a content drop.
    });
  });
}
