// Tools pass, the Other family (29-33), 2026-10-26. Plan and decisions:
// docs/pp-tool-plans/29-33-other.md. This file holds the backend half and the
// fixes that are about data: a vote that can be taken back, a deck that does
// not ask again, matches on a screen, and a chosen name that reaches the child
// only when she says so.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/name_astro_screens.dart';
import 'package:parentveda/screens/post_pregnancy/name_journey_feed_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_journey_shortlist_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_names_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_names_v2_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tools_tab.dart';
import 'package:parentveda/services/raga_audio_store.dart';

String _src(String path) => File(path).readAsStringSync();

Future<void> _tall(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final s = NameMatchStore.instance;
    for (final n in [...s.liked]) {
      s.clearVote(n);
    }
  });

  group('31 Baby names: votes', () {
    test('the heart takes a name back as a liked:false vote, and the crown goes with it', () {
      final s = NameMatchStore.instance;
      s.crown('Meera');
      expect(s.isLiked('Meera'), isTrue);
      s.unlike('Meera');
      expect(s.isLiked('Meera'), isFalse);
      // Answered, so the deck will not ask again; a tombstone, not a delete.
      expect(s.hasVoted('Meera'), isTrue);
      expect(s.crowned, isEmpty);
    });

    test('undo forgets the answer on this phone, so the card is asked again', () {
      final s = NameMatchStore.instance;
      s.like('Ira');
      s.clearVote('Ira');
      expect(s.isLiked('Ira'), isFalse);
      expect(s.hasVoted('Ira'), isFalse);
    });

    test('a name this build does not know is dropped from a list, never shown as Aarav', () {
      expect(babyNameOrNull('Zzqx-not-a-name'), isNull);
      expect(babyNameOrNull(kBabyNames.first.name), isNotNull);
      final src = _src('lib/screens/post_pregnancy/name_journey_shortlist_screen.dart');
      expect(src, contains('?babyNameOrNull(l)'));
    });

    test('pp_name_votes: the columns the client writes are the columns 0027 made', () {
      final mig = _src('supabase/migrations/0027_pp_name_votes.sql');
      final client = _src('lib/screens/post_pregnancy/pp_names_data.dart');
      for (final col in ['user_id', 'name', 'liked', 'updated_at']) {
        expect(client, contains("'$col':"), reason: 'the vote upload writes $col');
      }
      for (final col in ['user_id', 'name', 'liked']) {
        expect(mig, contains(col), reason: '0027 has $col');
      }
      // updated_at arrived with the per-item merge (step 7, 0105).
      final merge = Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('0105'))
          .map((f) => f.readAsStringSync())
          .join();
      expect(merge, contains('pp_name_votes'));
      expect(merge, contains('updated_at'));
    });

    test('the leftover fake-match flag is on no name', () {
      expect(kBabyNames.where((n) => n.mutual), isEmpty);
    });
  });

  group('31 Baby names: the deck', () {
    testWidgets('it leaves out names she already answered, and undo takes the like back', (tester) async {
      await _tall(tester);
      final first = namesForSelection(gender: 'Both', community: 'Any', region: 'Any', vibes: {}).first;
      NameMatchStore.instance.skip(first.name);

      await tester.pumpWidget(const MaterialApp(home: NameJourneyFeedScreen(startAtQuiz: true)));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const ValueKey('pp_names_quiz_start')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pp_names_quiz_start')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pp_names_primer_begin')));
      await tester.pumpAndSettle();

      // The first card is not the name she already skipped.
      final deck = namesForSelection(gender: 'Both', community: 'Any', region: 'Any', vibes: {});
      final next = deck.firstWhere((n) => !NameMatchStore.instance.hasVoted(n.name));
      expect(next.name, isNot(first.name));
      expect(find.text(next.name), findsWidgets);

      await tester.tap(find.bySemanticsLabel('We like this').first);
      await tester.pumpAndSettle();
      expect(NameMatchStore.instance.isLiked(next.name), isTrue);

      await tester.tap(find.bySemanticsLabel('Undo the last name').first);
      await tester.pumpAndSettle();
      expect(NameMatchStore.instance.isLiked(next.name), isFalse);
      expect(NameMatchStore.instance.hasVoted(next.name), isFalse);
    });

    testWidgets('a pass is recorded', (tester) async {
      await _tall(tester);
      await tester.pumpWidget(const MaterialApp(home: NameJourneyFeedScreen(startAtQuiz: true)));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const ValueKey('pp_names_quiz_start')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pp_names_quiz_start')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pp_names_primer_begin')));
      await tester.pumpAndSettle();
      final deck = namesForSelection(gender: 'Both', community: 'Any', region: 'Any', vibes: {});
      final shown = deck.firstWhere((n) => !NameMatchStore.instance.hasVoted(n.name));
      await tester.tap(find.bySemanticsLabel('Not for us').first);
      await tester.pumpAndSettle();
      expect(NameMatchStore.instance.hasVoted(shown.name), isTrue);
      expect(NameMatchStore.instance.isLiked(shown.name), isFalse);
    });

    testWidgets('a second visit goes straight to the names', (tester) async {
      await _tall(tester);
      SharedPreferences.setMockInitialValues({
        NameJourneyFeedScreen.tasteKey: '{"who":2,"vibes":[],"community":"Any","region":"Any"}',
      });
      await tester.pumpWidget(const MaterialApp(home: NameJourneyFeedScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_names_quiz_start')), findsNothing);
      expect(find.bySemanticsLabel('We like this'), findsWidgets);
    });
  });

  group('31 Baby names: the shortlist and the chosen name', () {
    testWidgets('"You both love" leads the shortlist, and says what fills it', (tester) async {
      await _tall(tester);
      NameMatchStore.instance.like(kBabyNames.first.name);
      await tester.pumpWidget(const MaterialApp(home: NameJourneyShortlistScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_shortlist_both')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_shortlist_both_empty')), findsOneWidget);
      // Reachable: the live shortlist reads the database's matches.
      expect(_src('lib/screens/post_pregnancy/name_journey_shortlist_screen.dart'), contains('store.matches'));
    });

    testWidgets('a name can be taken off the shortlist', (tester) async {
      await _tall(tester);
      final n = kBabyNames.first.name;
      NameMatchStore.instance.like(n);
      await tester.pumpWidget(const MaterialApp(home: NameJourneyShortlistScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('pp_shortlist_remove_$n')));
      await tester.pump();
      expect(NameMatchStore.instance.isLiked(n), isFalse);
      expect(find.text('$n is off your shortlist.'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    test('the "use this name" offer needs a child on record with no name yet', () async {
      final kids = ChildProfileStore.instance;
      if (!kids.hasRealChild) {
        expect(ppNameOfferFor('Aanya'), isFalse, reason: 'a pregnancy has no record to name');
        await kids.update(name: Child.placeholder);
      }
      if (kids.active.name == Child.placeholder) {
        expect(ppNameOfferFor('Aanya'), isTrue);
        await kids.update(name: 'Aanya');
      }
      expect(ppNameOfferFor('Aanya'), isFalse, reason: 'never over a name she gave');
    });

    test('the over-promise is gone, and the story opens with the name', () {
      final src = _src('lib/screens/post_pregnancy/name_journey_shortlist_screen.dart');
      final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      // The note is commented out on the live page (the page before keeps it, for revert).
      expect(src, contains(r"//   '${n.name} will gently flow through ParentVeda"));
      expect(live, contains('ppNameOfferFor(n.name)'));
      expect(live, contains("WriteStoryScreen(initialTitle: 'The story behind"));
      expect(live, contains('ChildProfileStore.instance.update(name: n.name)'));
    });
  });

  group('31 Baby names: tradition said as tradition', () {
    for (final page in ['astro', 'numerology']) {
      testWidgets('the $page page states no custom as fact', (tester) async {
        await _tall(tester);
        final name = kBabyNames.first.name;
        await tester.pumpWidget(MaterialApp(
            home: page == 'astro' ? NameAstrologyScreen(name: name) : NameNumerologyScreen(name: name)));
        await tester.pumpAndSettle();
        expect(find.textContaining('RULING PLANET'), findsNothing);
        expect(find.textContaining('Auspicious'), findsNothing);
        expect(find.textContaining('not a prediction'), findsOneWidget);
      });
    }

    test('the Tools row counts the names it has', () {
      final row = ppToolGroups().expand((g) => g.tools).firstWhere((t) => t.surfaceId == 'pp_names');
      expect(row.line, startsWith('${ppThousands(kBabyNames.length)} names'));
    });
  });

  group('30 Sleep Sounds: the timer', () {
    tearDown(() => RagaAudioStore.instance.resetForTest());

    test('her choice counts from play, not from arrival', () {
      final a = RagaAudioStore.instance;
      a.armSleepTimer(const Duration(minutes: 20));
      expect(a.sleepChoice, const Duration(minutes: 20));
      expect(a.sleepAfter, isNull, reason: 'nothing counts down while nothing plays');
    });

    test('a stop does not clear her choice', () async {
      final a = RagaAudioStore.instance;
      a.armSleepTimer(const Duration(minutes: 15));
      await a.stop();
      expect(a.sleepChoiceMade, isTrue);
      expect(a.sleepChoice, const Duration(minutes: 15));
    });

    test('"All night" is a choice, not a blank the default fills', () {
      final a = RagaAudioStore.instance;
      a.armSleepTimer(null);
      expect(a.sleepChoiceMade, isTrue);
      expect(a.sleepChoice, isNull);
      // The screen arms the default only when nothing was ever chosen.
      expect(_src('lib/screens/post_pregnancy/pp_sounds_screen.dart'),
          contains('if (!_audio.sleepChoiceMade) {'));
    });
  });
}
