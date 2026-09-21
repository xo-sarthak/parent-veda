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
import '../reads/read_images.dart' show readImageFor;
import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import 'pv_door_data.dart';

/// Surfaces this door opens. Constants because each becomes a route NAME.
const String kDietSurfaceCanIEat = 'nutrition/can_i_eat';
const String kDietSurfaceRecipes = 'nutrition/recipes';
const String kDietSurfaceCharts = 'nutrition/charts';
const String kDietSurfaceFasting = 'nutrition/fasting';
const String kDietSurfaceBigger = 'nutrition/nutrients';
const String kDietSurfaceExperts = 'nutrition/experts';
const String kDietSurfaceQuestions = 'nutrition/questions';
// 2026-09-20, the consistency pass: the day as the first tab's tool, the
// recipes as an inline rail. See nutrition_today_body.dart.
const String kDietSurfaceToday = 'nutrition/today';
const String kDietSurfaceRecipeRail = 'nutrition/recipe_rail';
const String kDietSurfaceList = 'nutrition/list';

const String kDietTabEat = 'eat'; // retired 2026-09-20 (a second Is it safe?); kept for revert
const String kDietTabToday = 'today';
const String kDietTabRecipes = 'recipes';
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
  // Two hands cupping cherry tomatoes over a wooden table (StockSnap, CC0),
  // picked by eye on 2026-09-20 from a contact sheet of market, produce,
  // kitchen and bowl candidates: hands and food, no plate, no country in
  // the frame, dark enough under the door's scrim for white type. It lives
  // in the read-image table so the R2 mirror carries it with the rest.
  // The thali it replaces, kept for revert:
  //   'https://images.unsplash.com/photo-1742281257687-092746ad6021?w=900&h=700&fit=crop'
  heroImageUrl: readImageFor('nutrition_hero'),

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
    // ⚠️ THE FIRST TAB IS TODAY — 2026-09-20, the consistency pass. It used
    // to be "Can I eat this?", a 64-food safety checker: a second, weaker Is
    // it safe? next door to the real one. One home per fact — that group is
    // retired (kept below, commented, for revert) and a tile on Today points
    // at the Is it safe? door. In its place, the day: her plate, the five
    // ticks, the glasses, the cravings — the tool that makes this door
    // something she opens every day rather than reads once.
    PvDoorGroup(
      id: kDietTabToday,
      label: 'Today',
      icon: Icons.restaurant_outlined,
      mark: IntentMark.plate, // the drawn marks Scans and Complications wear (the user, 2026-09-20)
      hue: 104,
      inlineSurfaceId: kDietSurfaceToday,
      inlineLabel: 'Your plate',
    ),
    // Kept for revert:
    // PvDoorGroup(
    //   id: kDietTabEat,
    //   label: 'Can I eat this?',
    //   icon: Icons.search_rounded,
    //   hue: 104,
    //   inlineSurfaceId: kDietSurfaceCanIEat,
    //   inlineLabel: 'Search any food',
    //   layout: PvDoorLayout.stack,
    // ),

    PvDoorGroup(
      id: kDietTabNow,
      label: 'What to eat now',
      icon: Icons.restaurant_menu_outlined,
      mark: IntentMark.nextStep,
      hue: 26,
    ),

    // THE RECIPES TAB IS A TOOL, NOT A RAIL. The user asked (2026-09-20)
    // whether a rail was the right way to show recipes; the recipe apps say
    // no (a filterable photo grid, led by one card). `RecipesGridBody`.
    PvDoorGroup(
      id: kDietTabRecipes,
      label: 'Recipes',
      icon: Icons.soup_kitchen_outlined,
      mark: IntentMark.cuppedHands,
      hue: 160,
      inlineSurfaceId: kDietSurfaceRecipeRail,
      inlineLabel: '${kRecipes.length} to cook',
    ),

    // "What your body needs" is a section of What to eat now since
    // 2026-09-20, so the door keeps five tabs like every other. Kept for
    // revert:
    // PvDoorGroup(id: kDietTabNutrients, label: 'What your body needs',
    //     icon: Icons.eco_outlined, hue: 186),

    PvDoorGroup(
      id: kDietTabCharts,
      label: 'Charts & fasting',
      icon: Icons.event_note_outlined,
      mark: IntentMark.calendarDay,
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
      mark: IntentMark.askDoctor,
      hue: 344,
      inlineSurfaceId: kDietSurfaceExperts, // NutritionTalkBody since 2026-09-20
      inlineLabel: 'The dietician',
      note: 'This is general guidance, not your doctor\'s advice. Anything '
          'specific to your health goes to your doctor or our dietician.',
    ),
  ],

  sections: [
    // =========================================================================
    //  SUB-TAB 1 · Today — the tool draws above; one section under it
    // =========================================================================
    PvDoorSection(
      group: kDietTabToday,
      heading: 'Also on this door',
      tiles: [
        PvDoorToolTile(
          title: 'Is this food safe?',
          blurb: 'Papaya, paneer, street food, a packet — the Is it safe? door, one tap away.',
          surfaceId: 'can_i',
        ),
        PvDoorToolTile(
          title: 'Your shopping list',
          blurb: 'Ingredients from the recipes you picked, ticked off at the shop.',
          surfaceId: kDietSurfaceList,
        ),
      ],
    ),

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
      group: kDietTabNow, // was its own tab; five tabs like every door (2026-09-20)
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
        // "The bigger questions" was a tool tile at the end of this rail that
        // opened `NutrientsScreen` — the same twelve nutrients again, with the
        // five whole-diet cards under them. The user (2026-09-20): repetitive.
        // The five are reads now, in the next section; the tile is kept for
        // revert:
        //   PvDoorToolTile(title: 'The bigger questions', blurb: ..., surfaceId: kDietSurfaceBigger),
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

    // Recipes: the whole tab is `RecipesGridBody` (the group's inline
    // tool). The rail + tile list it had for an hour is kept for revert:
    //   PvDoorSection.inline(group: kDietTabRecipes, heading: 'Recipes for you',
    //       inlineSurfaceId: kDietSurfaceRecipeRail),
    //   PvDoorSection(group: kDietTabRecipes, heading: 'Every recipe', tiles:
    //       [PvDoorToolTile(... surfaceId: kDietSurfaceRecipes), ..._tilesFor(recipe)]),

    PvDoorSection(
      group: kDietTabNow,
      heading: 'The bigger questions',
      tiles: _tilesFor(PvDoorLibrary.dietQuestion, [
        for (final q in kNutritionPracticalCards)
          (id: q.id, title: q.title.en, blurb: _firstSentence(q.body.en)),
      ]),
    ),

    // =========================================================================
    //  SUB-TAB 4 · Charts and fasting
    // =========================================================================
    // ⚠️ EIGHT ON THE RAIL, "VIEW ALL" FOR THE REST. Nineteen chart cards
    // in a row was "a big scroll" (the user, 2026-09-20), and the "Browse
    // every chart" tool card that led it opened a filter form. The heading's
    // View all opens `DietChartBrowseScreen` — chips over full-width cards —
    // and the tool card is retired, kept for revert:
    //   PvDoorToolTile(title: 'Browse every chart', blurb: ..., surfaceId: kDietSurfaceCharts),
    PvDoorSection(
      group: kDietTabCharts,
      heading: 'Ready-made diet charts',
      moreSurfaceId: kDietSurfaceCharts,
      railMax: 8,
      tiles: [
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
      // Eight pages since 2026-09-20 (reads in the one reader — see
      // nutrition_reads.dart); the one-card form above is history.
      tiles: _tilesFor(PvDoorLibrary.fasting, [
        for (final t in [...kFastingGeneral, ...kFastingByOccasion])
          (id: t.id, title: t.title.en, blurb: _firstSentence(t.body.en)),
      ]),
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
