// =============================================================================
//  The Mind & mood door: the brief's copy, verbatim, and its two rules
// -----------------------------------------------------------------------------
//  The reachability gates live in `pv_door_scans_test.dart`, which walks
//  `kPvDoorPages`; this door inherited them on registration. What is here is
//  what this brief adds that no other has:
//
//    · **Verbatim copy, and a lot of it.** Nine rebuilt reads, seven new ones,
//      a rebuilt fear, a new baby-blues read, eighteen affirmations, a four-step
//      reset and a red flag — all from section 3, none rewritten. A sentence
//      that drifted would still compile and still render.
//    · **The duplication bug.** "Check how I am feeling" and "Help me feel
//      better" must open different tabs of one door.
//    · **Do not drop anything.** Every read in `kMmArticles` is on the door.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_mind.dart';
import 'package:parentveda/data/mind_mood_data.dart';
import 'package:parentveda/data/mind_mood_extras.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  late PvDoorPage door;
  setUp(() => door = pvDoorPageFor('pregnancy_mental_health')!);

  group('the door matches the brief', () {
    test('five sub-tabs, Feel first', () {
      expect(door.groups.map((g) => g.label), [
        'Feel',
        'Understand',
        'Track',
        'When it is more than this',
        'Talk',
      ]);
      expect(door.groups.first.id, kMindTabFeel);
    });

    test('Track is the tool, holds no cards, and does not show Feel', () {
      // "Do-it screens, not rails. Must NOT show Feel's content."
      final g = door.groups.firstWhere((g) => g.id == kMindTabTrack);
      expect(g.inlineSurfaceId, kMindSurfaceTrack);
      expect(door.sectionsOf(kMindTabTrack), isEmpty);
    });

    test('the same-day red flag is pinned on the fourth tab, whole', () {
      final g = door.groups.firstWhere((g) => g.id == kMindTabMore);
      final f = g.pinnedRedFlag!;
      expect(f.lines.length, 5);
      expect(f.lines.map((l) => l.text), [
        'A low feeling has not lifted for two weeks.',
        'You cannot sleep even when the baby lets you.',
        'Nothing interests you anymore, not even things you loved.',
        'You feel detached, like you are watching your own life from outside.',
        'You have any thought of harming yourself or the baby.',
      ]);
      expect(f.footer, contains('None of these mean you have failed'));
      expect(f.surfaceId, kMindSurfaceCrisis);
      for (final other in door.groups.where((g) => g.id != kMindTabMore)) {
        expect(other.pinnedRedFlag, isNull);
      }
    });

    test('Ask Veda is not a card, same as Scans', () {
      for (final t in door.allTiles) {
        expect(t.title.toLowerCase(), isNot(contains('ask veda')));
        expect(t.title.toLowerCase(), isNot(contains('gentle question')));
      }
    });
  });

  group('the copy is the brief\'s, verbatim', () {
    test('the nine "is this normal" reads carry the new titles', () {
      final titles = mmArticlesIn(MmArticleGroup.isThisNormal)
          .map((a) => a.title.en)
          .toList();
      expect(titles, [
        'One minute okay, next minute not',
        'Crying at everything',
        'Short temper, and the guilt after',
        'Not feeling the bond yet',
        'The guilt that follows you around',
        'Forgetting everything',
        'When it all feels like too much',
        'Numb, when everyone says you should be glowing',
        'Lonely, even in a full house',
      ]);
    });

    test('a rebuilt body is the brief\'s sentence, not a paraphrase', () {
      final a = mmArticleById('mood_swings')!;
      expect(a.body.en, startsWith('You were fine a moment ago.'));
      expect(a.body.en,
          endsWith('that is worth telling someone, and the last tab shows you who.'));
      final n = mmArticleById('numb_no_joy')!;
      expect(n.body.en, contains('So here it is said plainly: it happens'));
    });

    test('the seven "what no one talks about" reads exist, in order', () {
      final titles = mmArticlesIn(MmArticleGroup.noOneTalksAbout)
          .map((a) => a.title.en)
          .toList();
      expect(titles, [
        'When everyone polices what you eat and do',
        'Log kya kahenge',
        'The secret months, carried alone',
        "When the baby's gender becomes everyone's business",
        "No corner of the house that's yours",
        'When the nuskhe and the superstitions start',
        "Bringing him in, when he doesn't get it",
      ]);
    });

    test('"Log kya kahenge" keeps its Hindi title — the brief wrote it so', () {
      // ⚠️ NOT A STRING TO "TRANSLATE". It is the brief's title, it is what the
      // phrase is called, and an English rewrite would be the app explaining
      // her own culture to her.
      expect(mmArticleById('log_kya_kahenge')!.title.en, 'Log kya kahenge');
    });

    test('the fear is rebuilt under its new title', () {
      final a = mmArticleById('fear_not_good_mother')!;
      expect(a.title.en, 'Fear of being a bad mother');
      expect(a.body.en, startsWith('You are not even a mother yet'));
    });

    test('fear of labour links to Labour prep; something-wrong to Scans', () {
      expect(mmArticleById('fear_labour')!.linkDoor, 'pregnancy_labour');
      expect(mmArticleById('fear_something_wrong')!.linkDoor,
          'pregnancy_scans_tests');
      // And the partner piece is reached from "Bringing him in".
      expect(mmArticleById('bringing_him_in')!.linkArticleId, 'partner_support');
      expect(pvDoorEntryResolves(PvDoorLibrary.mindRead, 'partner_support'),
          isTrue);
    });

    test('baby blues, or something more? — new, and on the fourth tab', () {
      final a = mmArticleById('baby_blues_or_more')!;
      expect(a.body.en, startsWith('Most mothers feel weepy'));
      final tab4 = [
        for (final s in door.sectionsOf(kMindTabMore))
          for (final t in s.tiles)
            if (t is PvDoorEntryTile) t.entryId,
      ];
      expect(tab4, contains('baby_blues_or_more'));
    });

    test('eighteen affirmations, the brief\'s set', () {
      expect(kMmAffirmations.length, 18);
      expect(kMmAffirmations.first.text.en, 'You are allowed to find this hard.');
      expect(kMmAffirmations.last.text.en,
          'Some days you just get through, and that counts.');
      // "For her, never about the baby."
      for (final a in kMmAffirmations) {
        expect(a.text.en.toLowerCase(), isNot(contains('baby')));
      }
    });

    test('the hard-day reset is four steps, an intro and a close', () {
      expect(kMmHardDaySteps.length, 4);
      expect(kMmHardDaySteps.map((s) => s.title),
          ['Put it down', 'Breathe', 'One kind thing', 'Let the day go']);
      expect(kMmHardDayIntro, startsWith('Some days just do not go well.'));
      expect(kMmHardDayClose, 'That is it. Nothing to log. Come back whenever a day gets heavy.');
    });

    test('every read carries the byline', () {
      expect(kMmReadAuthor, 'Dr Sharanya Menon');
      expect(kMmReadAuthorRole, contains('Perinatal psychologist'));
    });
  });

  group('nothing is dropped', () {
    test('every read in the library is on the door, plus the partner piece', () {
      final onDoor = {
        for (final t in door.allTiles)
          if (t is PvDoorEntryTile && t.library == PvDoorLibrary.mindRead)
            t.entryId,
      };
      final inLibrary = kMmArticles.map((a) => a.id).toSet();
      expect(onDoor, inLibrary,
          reason: 'a read in kMmArticles is unreachable from the door');
    });

    test('the six "more than a mood" reads moved to the fourth tab', () {
      final tab4 = {
        for (final s in door.sectionsOf(kMindTabMore))
          for (final t in s.tiles)
            if (t is PvDoorEntryTile) t.entryId,
      };
      for (final a in mmArticlesIn(MmArticleGroup.moreThanMood)) {
        expect(tab4, contains(a.id), reason: a.id);
      }
      final understand = {
        for (final s in door.sectionsOf(kMindTabUnderstand))
          for (final t in s.tiles)
            if (t is PvDoorEntryTile) t.entryId,
      };
      expect(understand.intersection(tab4), isEmpty,
          reason: 'a read sits on two tabs');
    });

    test('the hard-day reset is a tool, not a film', () {
      final tiles = door.allTiles.where((t) => t.title == 'A hard-day reset');
      expect(tiles.length, 1);
      expect(tiles.single, isA<PvDoorToolTile>());
    });

    test('every price is on the face', () {
      for (final o in kMmTalkOfferings) {
        final t = door.allTiles.firstWhere((t) => t.title == o.title.en);
        expect(t.meta, contains('₹${o.priceInr.toStringAsFixed(0)}'));
      }
    });
  });

  group('the four new surfaces draw', () {
    // ⚠️ THE ONLY SCREENS THIS DOOR ADDS. Everything else it opens shipped
    // months ago. These four wrap existing data; a pump at 360dp is what
    // stands in for the phone this build could not use.
    for (final id in [
      kMindSurfaceReset,
      kMindSurfaceAffirmations,
      kMindSurfaceHelplines,
      mindSurfaceOffer('perinatal_counselling'),
    ]) {
      testWidgets('$id builds and does not overflow', (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final screen = pvDoorScreenFor(id, PregnancyController());
        expect(screen, isNotNull);
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('the reset walks its four steps and ends', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: pvDoorScreenFor(kMindSurfaceReset, PregnancyController())));
      await tester.pump();
      expect(find.text('Start'), findsOneWidget);
      Future<void> advance(String label) async {
        final f = find.text(label);
        await tester.ensureVisible(f);
        await tester.pump();
        await tester.tap(f);
        await tester.pump(const Duration(milliseconds: 300));
      }

      await advance('Start');
      for (var i = 0; i < kMmHardDaySteps.length; i++) {
        expect(find.text(kMmHardDaySteps[i].title), findsOneWidget,
            reason: kMmHardDaySteps[i].title);
        await advance('Next');
      }
      expect(find.text('Done'), findsOneWidget);
      expect(find.textContaining('Nothing to log'), findsWidgets);
    });

    testWidgets('affirmations: one at a time on "Show me one"', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: pvDoorScreenFor(kMindSurfaceAffirmations, PregnancyController())));
      await tester.pump();
      await tester.tap(find.text('Show me one'));
      await tester.pump(const Duration(milliseconds: 350));
      final shown = kMmAffirmations.where((a) => find.text(a.text.en).evaluate().isNotEmpty);
      expect(shown.length, 1, reason: 'exactly one affirmation on screen');
      expect(find.text('Another one'), findsOneWidget);
    });
  });

  group('the duplication bug', () {
    testWidgets('the door opens on the tab it is asked for', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final b = bracketById('pregnancy_mental_health')!;

      await tester.pumpWidget(MaterialApp(
        home: PvDoorScreen(
            key: const ValueKey('track'),
            page: door,
            bracket: b,
            pregnancy: PregnancyController(),
            initialGroup: kMindTabTrack),
      ));
      await tester.pump();
      // Track's tool is on screen; Feel's first section is not.
      expect(find.text('How are you feeling, today?'), findsOneWidget);
      expect(find.text('In the moment'), findsNothing);

      await tester.pumpWidget(MaterialApp(
        // A key, so the second pump builds a fresh State rather than reusing
        // the first — which is what a real app does on a second push.
        home: PvDoorScreen(
            key: const ValueKey('feel'),
            page: door,
            bracket: b,
            pregnancy: PregnancyController(),
            initialGroup: kMindTabFeel),
      ));
      await tester.pump();
      expect(find.text('In the moment'), findsOneWidget);
      expect(find.text('How are you feeling, today?'), findsNothing);
    });
  });
}
