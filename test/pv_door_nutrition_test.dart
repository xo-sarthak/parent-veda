// =============================================================================
//  The Nutrition door reuses, and reuses everything
// -----------------------------------------------------------------------------
//  The reachability gates live in `pv_door_scans_test.dart`, which walks
//  `kPvDoorPages` — so this door inherited every one of them on registration
//  and none is repeated here.
//
//  What IS here is the one claim this brief makes that no other has, and it is
//  a claim about COVERAGE rather than about correctness:
//
//    *"If a rail names ten conditions or twelve nutrients, all of those pages
//    exist and are reused, even the ones not shown in a screenshot."*
//
//  A door that shows eleven of twelve nutrients is not broken. Every test
//  passes, every card works, and one page has silently become unreachable —
//  which on a landing that REPLACED the old menu is the wiring gate pointing
//  the other way. So these tests count.
//
//  ⚠️ AND THEY COUNT AGAINST THE LIBRARIES, NOT AGAINST A NUMBER. Asserting
//  "twelve nutrient cards" would pass forever while a thirteenth nutrient sat
//  unreachable. Asserting "as many cards as there are nutrients" fails the day
//  one is added, which is the day somebody can still fix it.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/checklists/pv_checklist.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

/// Every entry tile on the door from one library.
List<PvDoorEntryTile> _from(PvDoorPage door, PvDoorLibrary library) => [
      for (final t in door.allTiles)
        if (t is PvDoorEntryTile && t.library == library) t,
    ];

void main() {
  late PvDoorPage door;
  setUp(() => door = pvDoorPageFor('pregnancy_nutrition')!);

  group('the door matches the brief', () {
    test('five sub-tabs, Can I eat this first', () {
      expect(door.groups.length, 5);
      expect(door.groups.first.id, kDietTabEat);
      expect(door.groups.map((g) => g.label), [
        'Can I eat this?',
        'What to eat now',
        'Nutrients & recipes',
        'Charts & fasting',
        'Talk',
      ]);
    });

    test('sub-tab 1 is a search screen, not a rail, and carries no cards', () {
      // The brief says so by name, and its DO NOT list repeats it. All five
      // things it lists for this tab — search, most-searched, category chips,
      // the food list, cravings folded in — ARE the inline screen.
      final g = door.groups.first;
      expect(g.layout, PvDoorLayout.stack);
      expect(g.inlineSurfaceId, kDietSurfaceCanIEat);
      expect(door.sectionsOf(kDietTabEat), isEmpty);
    });

    test('sub-tabs 2, 3, 4 and 5 are card rails', () {
      for (final id in [
        kDietTabNow,
        kDietTabNutrients,
        kDietTabCharts,
        kDietTabTalk
      ]) {
        final g = door.groups.firstWhere((g) => g.id == id);
        expect(g.layout, PvDoorLayout.rails);
      }
    });

    test('the hero line the brief asks to keep is kept', () {
      expect(door.heroTitle, 'Eating well, without the panic.');
    });

    test('the disclaimer is the area\'s own words, pinned as a note', () {
      // The brief marks it [Note] reuse on Talk. It is a NOTE and not a red
      // flag on purpose — the flag treatment is coral and urgent, and spending
      // that on a disclaimer is spending an alarm on a caveat.
      final talk = door.groups.firstWhere((g) => g.id == kDietTabTalk);
      expect(talk.pinnedRedFlag, isNull,
          reason: 'a disclaimer is not a red flag.');
      expect(talk.note, isNotNull);
      expect(talk.note!.toLowerCase(), contains('general guidance'));
    });

    test('and it is said ONCE, not three times', () {
      // ⚠️ THIS ASSERTION REPLACES ITS OWN OPPOSITE. It used to require the
      // same caution in `closingLine` as well, on the reasoning that a door
      // opening onto seventy pages of food advice should repeat it. On a phone
      // that produced three statements of one sentence on the Talk tab: the
      // note at the top, the closing line at the bottom, and the engine's
      // `PvDoorDisclaimer` under that — which already says the stronger
      // version.
      //
      // A safety line repeated is a safety line devalued. Every other door's
      // closing line says something its disclaimer does not; this one said the
      // disclaimer again, so it is gone.
      expect(door.closingLine, isNull,
          reason: 'the area disclaimer is pinned on Talk and rendered by '
              'PvDoorDisclaimer; a third copy in the footer is noise.');
    });

    test('no tab on this door pins a red flag', () {
      // Nutrition has no same-day emergency; the areas that do carry one.
      for (final g in door.groups) {
        expect(g.pinnedRedFlag, isNull);
      }
    });
  });

  group('everything the brief says to reuse is on the door', () {
    test('all four stage guides', () {
      final ids = _from(door, PvDoorLibrary.dietStage).map((t) => t.entryId);
      expect(ids.toSet(), kTrimesterGuides.map((g) => g.id).toSet());
    });

    test('pre-pregnancy is last on the rail, not second', () {
      // Seen on a phone: the library is in life order and the rail copied it,
      // so "Pre-pregnancy" was the second card on a door only pregnant women
      // open. Still there — a woman planning a second baby uses it — but last.
      final ids = _from(door, PvDoorLibrary.dietStage).map((t) => t.entryId);
      expect(ids.toList(), ['t1', 't2', 't3', 'pre_pregnancy']);
    });

    test('her own trimester leads, and the narrow read stays first', () {
      // ⚠️ RANKING, NEVER STRUCTURE. Same four cards at every week; only the
      // order moves. And "Add this to your plate now" sits first regardless —
      // the hoist goes to the first ENTRY tile, not to index zero.
      final section = door.sections
          .firstWhere((s) => s.heading == 'Food for your stage');
      List<String> order(int week) => [
            for (final t in section.tilesFor(week))
              if (t is PvDoorEntryTile) t.entryId,
          ];
      expect(order(8), ['t1', 't2', 't3', 'pre_pregnancy']);
      expect(order(20), ['t2', 't1', 't3', 'pre_pregnancy']);
      expect(order(34), ['t3', 't1', 't2', 'pre_pregnancy']);
      for (final w in [8, 20, 34]) {
        expect(section.tilesFor(w).first, isA<PvDoorGuideTile>(),
            reason: 'the narrow read leads at week $w');
        expect(section.tilesFor(w).length, section.tiles.length,
            reason: 'nothing is added or hidden at week $w');
      }
    });

    test('every condition guide, including the one the brief omits', () {
      // ⚠️ THE BRIEF LISTS TEN AND ELEVEN EXIST. "Overweight in pregnancy" is
      // the extra, and it is on the rail because this door REPLACED the
      // landing — showing ten of eleven would make the eleventh unreachable.
      final ids = _from(door, PvDoorLibrary.dietCondition).map((t) => t.entryId);
      expect(ids.toSet(), kConditionGuides.map((g) => g.id).toSet());
      expect(ids, contains('overweight'),
          reason: 'the eleventh guide is the one a brief-following build '
              'would silently drop.');
    });

    test('all twelve nutrients', () {
      final ids = _from(door, PvDoorLibrary.nutrient).map((t) => t.entryId);
      expect(ids.toSet(), kNutrientGuides.map((g) => g.id).toSet());
    });

    test('every recipe', () {
      final ids = _from(door, PvDoorLibrary.recipe).map((t) => t.entryId);
      expect(ids.toSet(), kRecipes.map((r) => r.id).toSet());
    });

    test('every diet chart', () {
      final ids = _from(door, PvDoorLibrary.dietChart).map((t) => t.entryId);
      expect(ids.toSet(), kDietCharts.map((c) => c.id).toSet());
    });

    test('the filterable libraries also keep their tool card', () {
      // ⚠️ THE CARDS AND THE TOOL ARE NOT REDUNDANT. Nineteen chart cards on a
      // rail is how she finds "Bengali regional chart" by looking; the tool is
      // how she finds it by filtering on stage, diet, condition, region and
      // Hindi. The brief lists both, and it is right to.
      final surfaces = [
        for (final t in door.allTiles)
          if (t is PvDoorToolTile) t.surfaceId,
      ];
      expect(surfaces, contains(kDietSurfaceCharts));
      expect(surfaces, contains(kDietSurfaceRecipes));
      expect(surfaces, contains(kDietSurfaceBigger));
    });

    test('the supplements film is a coming-soon video, not a guide', () {
      final videos = [
        for (final t in door.allTiles)
          if (t is PvDoorVideoTile) t,
      ];
      expect(videos.length, 1);
      expect(videos.single.title, 'Do I actually need supplements?');
      expect(videos.single.comingSoon, isTrue);
      expect(videos.single.format, PvDoorFormat.video);
    });

    test('fasting is one card, and it is honest about why', () {
      // ⚠️ THE BRIEF LISTS EIGHT AND NONE OF THEM IS A PAGE.
      // `kFastingByOccasion` and `kFastingGeneral` are title-and-paragraph rows
      // rendered inline on `FastingScreen`, not tappable, with no detail
      // screen. Eight cards each opening the same screen would be eight
      // promises with one destination; building eight pages is what the brief
      // forbids. So: one card, listed in STILL-OPEN §35.
      final fasting = _from(door, PvDoorLibrary.fasting);
      expect(fasting.length, 1);
      expect(fasting.single.title, isNot('Fasting, done safely'),
          reason: 'the card must not repeat its own section heading.');
      // The blurb is where the eight actually get named.
      final blurb = fasting.single.blurb.toLowerCase();
      for (final word in ['navratri', 'ramzan', 'karva chauth', 'ekadashi']) {
        expect(blurb, contains(word));
      }
    });
  });

  group('only two things on this door are new', () {
    test('one read, and it is the trimester guide', () {
      final reads = [
        for (final r in kPregnancyReads)
          if (r.id.startsWith('preg_diet_')) r.id,
      ];
      expect(reads, ['preg_diet_read_add_now']);
    });

    test('one checklist, and it names her stage', () {
      expect(pvChecklistById('diet_questions'), isNotNull);
      expect(kDietQuestionsChecklist.subject, isNotNull);
    });

    test('the door writes no other prose card', () {
      // ⚠️ THE REUSE RULE, AS A COUNT. Every tile on this door is either a
      // library entry, a tool pointing at a shipped screen, the one new read,
      // the one new checklist, or the coming-soon film. A `PvDoorGuideTile`
      // that is not the trimester read means somebody wrote an article on a
      // door whose brief says, twice, that nothing here is new copy.
      for (final t in door.allTiles) {
        if (t is! PvDoorGuideTile) continue;
        expect(t.readId, 'preg_diet_read_add_now',
            reason: '"${t.title}" is a new guide on a reuse-only door.');
      }
    });
  });

  group('single source, wired one level in', () {
    test('the six conditions Complications owns carry a link', () {
      // ⚠️ THE DIET CARD STILL OPENS THE DIET PAGE. Reading the brief as "the
      // card opens Complications instead" would throw away the eating advice,
      // which is the one thing somebody taps for here. The link lives at the
      // foot of the diet page, where "more about the condition itself" is the
      // next question rather than the first.
      const expected = {
        'gestational_diabetes': 'gdm',
        'anemia_iron': 'anemia',
        'thyroid': 'thyroid',
        'pcos': 'pcos',
        'high_bp_preeclampsia': 'high_bp',
        'twins': 'twin_pregnancy',
        // ⚠️ THE BRIEF SAID THIS ONE OWNS ITS CONTENT AND HAS NO PAGE. `piles`
        // exists. Walking the code beat the brief.
        'constipation_piles': 'piles',
      };
      final byId = {for (final g in kConditionGuides) g.id: g};
      expected.forEach((guideId, linkId) {
        expect(byId[guideId]?.linkId, linkId,
            reason: '$guideId should link to $linkId.');
      });
    });

    test('the diet-only ones carry no link, and that is right', () {
      const dietOnly = [
        'healthy_weight_gain',
        'underweight',
        'brain_development',
        'overweight',
      ];
      final byId = {for (final g in kConditionGuides) g.id: g};
      for (final id in dietOnly) {
        expect(byId[id]?.linkId, isNull,
            reason: '$id has no condition page — a link would have to be '
                'invented.');
      }
    });

    test('every link resolves in the library it names', () {
      for (final g in kConditionGuides) {
        final id = g.linkId;
        if (id == null) continue;
        final library = switch (g.linkLibrary) {
          ConditionLink.complication => PvDoorLibrary.condition,
          ConditionLink.finding => PvDoorLibrary.finding,
        };
        expect(pvDoorEntryResolves(library, id), isTrue,
            reason: '${g.id} links to "$id", which is not in '
                '${library.name}.');
      }
    });

    test('twins links to a finding because no condition page exists', () {
      // The rule is `docs/PREGNANCY-DOOR-BUILD.md` §4a — one page per question.
      // Twins only exists as something a report says.
      final twins = kConditionGuides.firstWhere((g) => g.id == 'twins');
      expect(twins.linkLibrary, ConditionLink.finding);
      expect(pvDoorEntryResolves(PvDoorLibrary.condition, 'twin_pregnancy'),
          isFalse,
          reason: 'a twins CONDITION page now exists — point the link at it '
              'and record the change in §4a.');
    });
  });

  group('the language rule', () {
    test('no heading or tab label on this door carries jargon', () {
      // The brief: "no jargon in any heading or blurb we write". Card titles
      // are the pages' own and are exempt — "Anaemia / low iron" is that
      // page's title, and renaming it would be editing text marked reuse.
      const jargon = [
        'gestational',
        'preeclampsia',
        'hyperemesis',
        'oligohydramnios',
        'dha',
      ];
      for (final s in door.sections) {
        for (final w in jargon) {
          expect(s.heading.toLowerCase(), isNot(contains(w)),
              reason: 'heading "${s.heading}" carries "$w".');
        }
      }
      for (final g in door.groups) {
        for (final w in jargon) {
          expect(g.label.toLowerCase(), isNot(contains(w)));
        }
      }
    });

    test('no blurb we wrote ends mid-sentence', () {
      // ⚠️ THE BLURBS ARE TRIMMED FROM THE PAGES' OWN SUMMARIES, so the trim
      // has to cut at a sentence. One ending "…and the numbers are the" reads
      // as a rendering bug rather than as a choice.
      for (final t in door.allTiles) {
        final b = t.blurb.trim();
        expect(b, isNotEmpty, reason: '"${t.title}" has no blurb.');
        expect(RegExp(r'[.!?…]$').hasMatch(b), isTrue,
            reason: '"${t.title}" blurb stops mid-sentence: "$b"');
      }
    });
  });

  group('every nutrition surface builds', () {
    test('inline and pushed, for each one a tile or a tab names', () {
      // ⚠️ BOTH WAYS, because a door surface can be rendered on a tab AND
      // pushed as a screen. Two of the nutrition surfaces are bodies, and a
      // body with no screen shell is a tile that opens nothing.
      final c = PregnancyController();
      for (final g in door.groups) {
        if (g.inlineSurfaceId case final s?) {
          expect(pvDoorInlineToolFor(s, c), isNotNull,
              reason: 'tab "${g.label}" declares inline "$s".');
          expect(pvDoorScreenFor(s, c), isNotNull,
              reason: '"$s" renders inline and cannot be pushed.');
        }
      }
      for (final t in door.allTiles) {
        final id = switch (t) {
          PvDoorToolTile(:final surfaceId) => surfaceId,
          PvDoorChecklistTile(:final surfaceId) => surfaceId,
          PvDoorTalkTile(:final surfaceId) => surfaceId,
          _ => null,
        };
        if (id == null) continue;
        expect(pvDoorScreenFor(id, c), isNotNull,
            reason: '"${t.title}" opens nothing.');
      }
    });
  });
}
