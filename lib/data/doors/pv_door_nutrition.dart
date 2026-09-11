// =============================================================================
//  Nutrition & diet — the door
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Nutrition_rebuild.pdf`, 30 Aug 2026. Third of the
//  eight pregnancy briefs, and by far the most reuse of the three.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE BRIEF'S FIRST BOX IS THE WHOLE BRIEF: "nothing here is a new page"
//  ---------------------------------------------------------------------------
//
//  Its words: *"Every food page, craving page, condition-diet page, nutrient
//  page, recipe, diet chart and fasting page is ALREADY BUILT. It is all
//  reuse."* And: *"If you cannot find a page that this map says to reuse, STOP
//  and list it in your output rather than creating a new one."*
//
//  Walking the code first — the playbook's step zero — confirmed every list:
//
//    · `kFoodEntries` with Safe/Limit/Avoid and a page each
//    · `kCravingItems` + 6 `kCravingCards` ("About cravings")
//    · 4 `kTrimesterGuides`, 11 `kConditionGuides`
//    · 12 `kNutrientGuides`, 5 `kNutritionPracticalCards`
//    · 16 `kRecipes`, 19 `kDietCharts`
//    · 5 `kFastingByOccasion` + 3 `kFastingGeneral`
//    · the four paid dietician tiers, and the supplements video placeholder
//
//  So this file declares roughly seventy cards and writes almost no copy. The
//  two genuinely new items are `preg_diet_read_add_now` and
//  `kDietQuestionsChecklist`.
//
//  ⚠️ THREE THINGS THE BRIEF DID NOT KNOW, FOUND BY WALKING THE CODE. All three
//  are recorded in STILL-OPEN §35:
//
//    1. **An eleventh condition guide exists** — "Overweight in pregnancy" —
//       which the brief's list of ten omits. It is on the rail, because a door
//       that shows ten of eleven makes the eleventh unreachable.
//    2. **Fasting topics are not pages.** The eight are title-and-paragraph
//       rows rendered inline on `FastingScreen`, not tappable, with no detail
//       screen. So this door carries ONE fasting card rather than eight
//       pointing at one destination.
//    3. **The fourth paid tier is called "Book a consultation"**, not "Book one
//       session". The brief says do not change the labels, so it keeps its own.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SINGLE SOURCE, AND THE FIX WAS ONE LEVEL IN
//  ---------------------------------------------------------------------------
//
//  The brief: *"where a condition also lives in Complications, the diet card
//  LINKS to that Complications page and does not restate the condition."*
//
//  Read as "the card opens Complications instead", that throws away the eating
//  advice — which is the one thing somebody taps for on a nutrition door. And
//  it was unnecessary: every `ConditionGuide` is already pure diet ("pair carbs
//  with protein", "iron-rich foods: dal, greens") with no symptoms, no tests
//  and no management. The rule was satisfied by construction.
//
//  What was MISSING was the link. `_ComplicationsLink` at the foot of every
//  diet page said *"lives in Complications, coming soon"* and was not tappable,
//  because when it was written there was no Complications screen. There is one
//  now. So the diet card opens the diet page, and that page's own footer opens
//  the condition — see `ConditionGuide.linkId`.
//
//  ---------------------------------------------------------------------------
//  ⚠️ FIVE TABS, AND THE FIRST IS THE DEFAULT
//  ---------------------------------------------------------------------------
//
//    1. Can I eat this?      the food checker + cravings   [search screen]
//    2. What to eat now      stage, and a condition        [card rails]
//    3. Nutrients & recipes  what your body needs          [card rails]
//    4. Charts & fasting     ready-made plans              [card rails]
//    5. Talk                 the paid layer                [pinned + rails]
//
//  104 is the nutrition bracket's own green.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../nutrition_data.dart';
import 'pv_door_data.dart';

/// Surfaces this door opens. Constants because each becomes a route NAME.
const String kDietSurfaceCanIEat = 'nutrition/can_i_eat';
const String kDietSurfaceRecipes = 'nutrition/recipes';
const String kDietSurfaceCharts = 'nutrition/charts';
const String kDietSurfaceFasting = 'nutrition/fasting';
const String kDietSurfaceBigger = 'nutrition/nutrients';
const String kDietSurfaceExperts = 'nutrition/experts';
const String kDietSurfaceQuestions = 'nutrition/questions';

const String kDietTabEat = 'eat';
const String kDietTabNow = 'now';
const String kDietTabNutrients = 'nutrients';
const String kDietTabCharts = 'charts';
const String kDietTabTalk = 'talk';

/// ⚠️ BUILT FROM THE LIBRARIES, NOT TYPED OUT. Seventy hand-written cards is
/// seventy chances for a label to drift from the page it opens — and the drift
/// is invisible, because a card with the wrong title still renders and still
/// works. Reading the library means the card and the page cannot disagree.
///
/// ⚠️ AND THE BLURB IS THE PAGE'S OWN SUMMARY, TRIMMED TO ONE LINE. Writing new
/// blurbs for seventy reused pages would be writing copy on a door whose brief
/// says, twice, that nothing here is new copy.
List<PvDoorTile> _tilesFor(
  PvDoorLibrary library,
  Iterable<({String id, String title, String blurb})> rows,
) =>
    [
      for (final r in rows)
        PvDoorEntryTile(
          title: r.title,
          blurb: r.blurb,
          library: library,
          entryId: r.id,
        ),
    ];

/// One line off a longer paragraph.
///
/// ⚠️ IT CUTS AT A SENTENCE, NEVER MID-WORD. A blurb ending "…and the numbers
/// are the" reads as a rendering bug; ending at the first full stop reads as a
/// choice. Where the first sentence is itself long it is left long — a rail
/// card does not show the blurb at all, and the wide rows have room.
String _firstSentence(String s) {
  final i = s.indexOf('. ');
  return i < 0 ? s : s.substring(0, i + 1);
}

final PvDoorPage kNutritionDoor = PvDoorPage(
  bracketId: 'pregnancy_nutrition',

  // ⚠️ THE BRIEF ASKS TO KEEP THIS LINE. It is the area's own posture in five
  // words, and it is the reason the food checker leads with a verdict rather
  // than a lecture.
  heroTitle: 'Eating well, without the panic.',
  heroBlurb: 'Any food, any craving, any stage — answered plainly, for an '
      'Indian kitchen.',

  // ⚠️ THE PHOTOGRAPH HAS TO BE INDIAN FOOD OR IT CONTRADICTS THE BLURB. The
  // line under it says "for an Indian kitchen"; a bowl of salad over those
  // words is the picture arguing with the sentence.
  //
  // A South Indian veg thali on a banana leaf, viewed and chosen rather than
  // picked from a caption — see `pv_door_scans.dart` for why that distinction
  // is the whole rule about photographs here.
  heroImageUrl:
      'https://images.unsplash.com/photo-1742281257687-092746ad6021?w=900&h=700&fit=crop',

  // ⚠️ NO CLOSING LINE, AND REMOVING IT IS THE FIX RATHER THAN THE OMISSION.
  //
  // The brief pins this area's disclaimer on the Talk tab, and it is there —
  // `kDietTabTalk`'s `note`. An earlier pass here reasoned that a door leading
  // to seventy pages of food advice should also carry it at the foot of every
  // tab, and put the same sentence in `closingLine` too.
  //
  // Seen on a phone, 2026-09-10: on the Talk tab that sentence appears THREE
  // times on one screen — the tab note at the top, the closing line at the
  // bottom, and the engine's own `PvDoorDisclaimer` immediately under it,
  // which already says the stronger version ("your doctor knows your
  // pregnancy; if anything here disagrees with them, they are right").
  //
  // ⚠️ THE GENERAL SHAPE, WHICH IS WORTH MORE THAN THIS DELETION: a safety
  // line repeated is a safety line devalued. Three statements of the same
  // caution read as boilerplate and get skipped; one reads as meant. Every
  // other door's `closingLine` says something the disclaimer does not — see
  // Scans ("not every pregnancy needs every test"). This one said the
  // disclaimer again in shorter words, so it was spending the footer without
  // buying anything.
  //
  // Kept for revert:
  // closingLine: 'This is general guidance. Anything specific to your health '
  //     'goes to your doctor or our dietician.',

  groups: [
    // -------------------------------------------------------------------------
    //  1. Can I eat this? — the checker and cravings, inline
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kDietTabEat,
      label: 'Can I eat this?',
      icon: Icons.search_rounded,
      hue: 104,
      inlineSurfaceId: kDietSurfaceCanIEat,
      inlineLabel: 'Search any food',
      layout: PvDoorLayout.stack,
    ),

    PvDoorGroup(
      id: kDietTabNow,
      label: 'What to eat now',
      icon: Icons.restaurant_menu_outlined,
      hue: 26,
    ),

    PvDoorGroup(
      id: kDietTabNutrients,
      label: 'Nutrients & recipes',
      icon: Icons.eco_outlined,
      hue: 160,
    ),

    PvDoorGroup(
      id: kDietTabCharts,
      label: 'Charts & fasting',
      icon: Icons.event_note_outlined,
      hue: 42,
    ),

    // -------------------------------------------------------------------------
    //  5. Talk — the one paid layer in the area
    // -------------------------------------------------------------------------
    //  ⚠️ THE FOUR TIERS ARE RENDERED, NOT RE-CARDED. `ExpertOptionsBlock` IS
    //  the four tiers, with its own header, its own "everything above is free"
    //  line and its own booking sheet. Four cards beside it would be four
    //  copies of its rows, and the brief says keep the tiers exactly as they
    //  are and do not change the labels — which is easiest to guarantee by not
    //  retyping them.
    //
    //  ⚠️ AND THE DISCLAIMER IS THE TAB'S NOTE. The brief pins it here as
    //  [Note] reuse; `PvDoorGroup.note` is the quiet box that already exists
    //  for exactly this — a standing caution, not a clinical red flag. Using
    //  the flag treatment would spend an alarm on a disclaimer.
    PvDoorGroup(
      id: kDietTabTalk,
      label: 'Talk',
      icon: Icons.chat_bubble_outline_rounded,
      hue: 344,
      inlineSurfaceId: kDietSurfaceExperts,
      inlineLabel: 'Dieticians',
      note: 'This is general guidance, not your doctor\'s advice. Anything '
          'specific to your health goes to your doctor or our dietician.',
    ),
  ],

  sections: [
    // =========================================================================
    //  SUB-TAB 1 · Can I eat this?
    // -------------------------------------------------------------------------
    //  No cards. The brief lists five things for this tab — the search, the
    //  most-searched chips, the category chips, the food list, and cravings
    //  folded in — and all five ARE the inline screen.
    // =========================================================================

    // =========================================================================
    //  SUB-TAB 2 · What to eat now
    // =========================================================================
    PvDoorSection(
      group: kDietTabNow,
      heading: 'Food for your stage',
      // ⚠️ HER OWN TRIMESTER LEADS THE GUIDES. Seen on a phone: "Pre-pregnancy"
      // was the second card on the rail of a door only pregnant women open —
      // not wrong (a woman planning a second baby uses it) but the wrong one
      // to lead with. Same four cards for everyone; the order is hers. See
      // `PvDoorSection.lead` for why this is ranking and not structure.
      lead: (week) => week <= 13
          ? 't1'
          : week <= 27
              ? 't2'
              : 't3',
      tiles: [
        // ⚠️ THE ONE NEW READ ON THIS DOOR, AND IT SITS FIRST BECAUSE IT IS THE
        // NARROWEST QUESTION. The four stage guides beside it are long; this
        // answers "what do I add THIS month", which is what somebody actually
        // wants at a rail. The lead above hoists to the first ENTRY tile, so
        // this stays where it is.
        PvDoorGuideTile(
          title: 'Add this to your plate now',
          blurb: 'One short list per stage. Not a diet — just what to add.',
          readId: 'preg_diet_read_add_now',
        ),
        // ⚠️ TRIMESTERS FIRST, PRE-PREGNANCY LAST. `kTrimesterGuides` is in
        // life order — before, first, second, third — which is right for the
        // library and wrong for this rail. The static order is what a woman
        // with no due date set sees; the lead above refines it once there is
        // a week to go on.
        ..._tilesFor(PvDoorLibrary.dietStage, [
          for (final g in [
            ...kTrimesterGuides.where((g) => g.id != 'pre_pregnancy'),
            ...kTrimesterGuides.where((g) => g.id == 'pre_pregnancy'),
          ])
            (
              id: g.id,
              title: g.label.en,
              blurb: _firstSentence(g.focus.en),
            ),
        ]),
      ],
    ),

    // -------------------------------------------------------------------------
    //  For a condition you are managing
    // -------------------------------------------------------------------------
    //  ⚠️ ALL ELEVEN, INCLUDING THE ONE THE BRIEF'S LIST OMITS. See the header:
    //  "Overweight in pregnancy" exists and the brief names ten. Showing ten of
    //  eleven would make the eleventh unreachable from this door, which is the
    //  wiring gate pointing the other way.
    //
    //  ⚠️ AND THE TITLES ARE THE PAGES' OWN. The Complications brief's
    //  plain-phrase-first rule governs a browse list of CONDITIONS; these are
    //  diet pages, and "Anaemia / low iron" is the page's own title. Renaming
    //  them here would be editing text the brief says to reuse as-is.
    PvDoorSection(
      group: kDietTabNow,
      heading: 'For a condition you are managing',
      tiles: _tilesFor(PvDoorLibrary.dietCondition, [
        for (final g in kConditionGuides)
          (
            id: g.id,
            title: g.label.en,
            blurb: _firstSentence(g.summary.en),
          ),
      ]),
    ),

    // =========================================================================
    //  SUB-TAB 3 · Nutrients and recipes
    // =========================================================================
    PvDoorSection(
      group: kDietTabNutrients,
      heading: 'What your body needs',
      tiles: [
        ..._tilesFor(PvDoorLibrary.nutrient, [
          for (final n in kNutrientGuides)
            (
              id: n.id,
              title: n.name.en,
              blurb: _firstSentence(n.whatItDoes.en),
            ),
        ]),
        // ⚠️ "The bigger questions" IS A SECTION OF THE NUTRIENTS SCREEN, NOT A
        // PAGE — five whole-diet cards rendered under that heading. So one card
        // opens that screen, which is where they live. The brief marks it
        // [Guide] reuse and this is the reuse.
        PvDoorToolTile(
          title: 'The bigger questions',
          blurb: 'Prenatal vitamins, iron and calcium timing, veg protein and '
              'B12, and whether your thali is enough.',
          surfaceId: kDietSurfaceBigger,
        ),
        // ⚠️ COMING SOON, AND THE PLACEHOLDER ALREADY SHIPS on the nutrients
        // screen. The brief marks it [Video, COMING SOON] reuse; the card holds
        // its place at full size and does not tap.
        PvDoorVideoTile(
          title: 'Do I actually need supplements?',
          blurb: 'A dietician on what food covers, and what it usually does '
              'not.',
        ),
      ],
    ),

    PvDoorSection(
      group: kDietTabNutrients,
      heading: 'Recipes to actually cook',
      tiles: [
        PvDoorToolTile(
          title: 'Recipe library',
          blurb: 'Filter by what you need, or by where you are from.',
          surfaceId: kDietSurfaceRecipes,
        ),
        ..._tilesFor(PvDoorLibrary.recipe, [
          for (final r in kRecipes)
            (
              id: r.id,
              title: r.name.en,
              blurb: _firstSentence(r.whyNow.en),
            ),
        ]),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 4 · Charts and fasting
    // =========================================================================
    PvDoorSection(
      group: kDietTabCharts,
      heading: 'Ready-made diet charts',
      tiles: [
        // ⚠️ NOT "DIET CHARTS", WHICH IS THE HEADING IT SITS UNDER. Seen on a
        // phone: the browse-everything card and its own section printed the
        // same two words a centimetre apart, so the card looked like a label
        // for the rail rather than a thing to tap. Same fault the fasting card
        // had. A card's title has to earn its line against the heading above
        // it — if it repeats it, it is invisible.
        PvDoorToolTile(
          title: 'Browse every chart',
          blurb: 'Filter by stage, diet, condition, region — and Hindi. Free '
              'to view or download.',
          surfaceId: kDietSurfaceCharts,
        ),
        ..._tilesFor(PvDoorLibrary.dietChart, [
          for (final c in kDietCharts)
            (
              id: c.id,
              title: c.title.en,
              blurb: _firstSentence(c.description.en),
            ),
        ]),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Fasting
    // -------------------------------------------------------------------------
    //  ⚠️ ONE CARD, NOT EIGHT, AND THE BRIEF TOLD ME TO SAY SO. It lists all
    //  eight topics as `[Guide] reuse` — five occasions and three general — and
    //  they are NOT pages: `kFastingByOccasion` and `kFastingGeneral` are
    //  title-and-paragraph rows rendered inline on `FastingScreen`, not
    //  tappable, with no detail screen anywhere.
    //
    //  Eight cards each opening the same screen would be eight promises with
    //  one destination, which is worse than one honest card. Building eight
    //  pages is what the brief's own rule forbids: *"If you cannot find a page
    //  that this map says to reuse, STOP and list it in your output rather than
    //  creating a new one."* So: one card, and it is listed in STILL-OPEN §35.
    PvDoorSection(
      group: kDietTabCharts,
      heading: 'Fasting, done safely',
      tiles: [
        // ⚠️ THE CARD IS NOT NAMED AFTER ITS SECTION, AND A RENDER TEST CAUGHT
        // IT. Both read "Fasting, done safely" at first, which is the
        // repeat-the-heading failure one level down from the tab: the card's
        // title said nothing the heading had not just said, and the words she
        // needed — which fasts are covered — were only in the blurb.
        PvDoorEntryTile(
          title: 'Fasting in pregnancy',
          blurb: 'Navratri, Ramzan, Karva Chauth, Ekadashi and Jain fasts — '
              'and whether to fast at all.',
          library: PvDoorLibrary.fasting,
          // ⚠️ A REAL ID SO THE WIRING TEST STILL BITES. It validates against
          // the library even though every fasting id opens the same screen; a
          // typo here should still fail rather than pass because the
          // destination happens not to depend on it.
          entryId: 'should_i_fast',
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 5 · Talk
    // =========================================================================
    PvDoorSection(
      group: kDietTabTalk,
      heading: 'Before your appointment',
      tiles: [
        PvDoorChecklistTile(
          title: 'What to ask about your diet',
          blurb: 'Tick what matters to you, and take the list in with you.',
          surfaceId: kDietSurfaceQuestions,
        ),
      ],
    ),
  ],
);
