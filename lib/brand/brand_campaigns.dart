// =============================================================================
//  Brand Studio — seed campaigns
// -----------------------------------------------------------------------------
//  PLACEHOLDER BRANDS. NestlingCo, MamaBloom, PureStart and TinyToes are not
//  real companies — they carry over from the old launch promo so the surfaces
//  have something honest to render until real partners are signed.
//
//  Note the shift from the promo these replace. The old slides were discount
//  creatives ("FLAT 30% OFF", "Shop the sale"). A Premiere is not a louder
//  version of that — it is a product LAUNCH: a story, an expert introduction,
//  what the thing actually does, and ParentVeda's own reading on it. If a
//  campaign here ever reads like an offer, it is in the wrong product.
//
//  Nothing in this file is imported by a screen. Only BrandStudio reads it.
// =============================================================================

import 'package:flutter/material.dart';

import 'brand_models.dart';

// ---- brands -----------------------------------------------------------------
// `certified` stays false everywhere. Certification is an editorial judgement
// with an independent evaluation — it is never set from campaign data and it is
// not for sale. See docs/BRAND-STUDIO.md §13.

const Brand kNestlingCo = Brand(
  id: 'nestlingco',
  name: 'NestlingCo',
  colour: Color(0xFF2E7D6B),
);

const Brand kPureStart = Brand(
  id: 'purestart',
  name: 'PureStart',
  colour: Color(0xFF4E8A54),
);

const Brand kMamaBloom = Brand(
  id: 'mamabloom',
  name: 'MamaBloom',
  colour: Color(0xFFC65B72),
);

const Brand kTinyToes = Brand(
  id: 'tinytoes',
  name: 'TinyToes',
  colour: Color(0xFF3C6FBF),
);

const List<Brand> kBrands = [kNestlingCo, kPureStart, kMamaBloom, kTinyToes];

// ---- campaign windows -------------------------------------------------------
// Deliberately wide so the seed data is visible while the module is in preview.
// Real campaigns run for weeks, and Premiere is used 3–6 times a year.
final _seedStart = DateTime(2026, 1, 1);
final _seedEnd = DateTime(2027, 1, 1);

// =============================================================================
//  Launch Hub launches (destination) — a launch's permanent home.
//  Parents come here on purpose, so these are never capped.
// =============================================================================

final BrandCampaign _calmBalmLaunch = BrandCampaign(
  id: 'launch_nestlingco_calm_balm',
  brand: kNestlingCo,
  slot: BrandSlot.launchHub,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  // Reaches both stages, matching the Premiere that announces it — a launch a
  // parent was just shown must not vanish when they tap through to it.
  audience: BrandAudience.everyone,
  creative: const BrandCreative(
    eyebrow: 'New from NestlingCo',
    headline: 'Calm Balm',
    subline: 'A daily balm for babies whose skin flares up.',
    story:
        'NestlingCo spent two years on a balm for the babies their old lotion could not help — the ones whose skin turns dry and angry the moment the weather shifts. It has five ingredients. It has no fragrance, because fragrance is the single most common trigger in a baby balm, and leaving it out cost them the pleasant smell most parents expect. That was the trade they chose.',
    cta: 'Explore the launch',
    expertName: 'Dr Anjali Rao',
    expertRole: 'Paediatric dermatologist · introduces this launch for ParentVeda',
    expertHook:
        'A short, fragrance-free ingredient list is the right instinct for reactive skin. Patch-test on one arm for two days before you use it everywhere — that goes for this balm and every other one.',
    highlights: [
      BrandHighlight(
        title: 'Five ingredients',
        body: 'Shea, oat oil, glycerin, beeswax, vitamin E. Nothing else, and the list is on the front of the tin, not the back.',
        icon: Icons.spa_outlined,
      ),
      BrandHighlight(
        title: 'No fragrance at all',
        body: 'Not "lightly scented" and not masked with a cover fragrance. None. It smells faintly of oats, which some parents dislike.',
        icon: Icons.air_rounded,
      ),
      BrandHighlight(
        title: 'Tested on reactive skin',
        body: 'Their own 12-week trial ran on 210 babies with dry or eczema-prone skin. It is the maker\'s own study — read it as a starting point, not proof.',
        icon: Icons.science_outlined,
      ),
    ],
    resources: [
      BrandResource(
        label: 'Understanding baby skin',
        blurb: 'What a flare-up actually is, why it happens, and when a balm is not the answer. Written by ParentVeda.',
      ),
      BrandResource(
        label: 'How to patch-test anything',
        blurb: 'Two days, one arm, one product at a time. The method works for any new product, not just this one.',
      ),
    ],
  ),
);

final BrandCampaign _folateLaunch = BrandCampaign(
  id: 'launch_purestart_folate',
  brand: kPureStart,
  slot: BrandSlot.launchHub,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.pregnancy, pregnancyWeekMax: 16),
  creative: const BrandCreative(
    eyebrow: 'New from PureStart',
    headline: 'Folate+',
    subline: 'A prenatal built for the first trimester, when swallowing anything is hard.',
    story:
        'Most prenatals are one large tablet taken once a day, which is a difficult ask in the weeks when nausea is at its worst. PureStart split theirs into two small tablets you can take apart, at whatever hour your stomach allows. Same folate, easier timing. It costs more to make and they charge more for it.',
    cta: 'Explore the launch',
    expertName: 'Dr Meera Iyer',
    expertRole: 'Obstetrician · introduces this launch for ParentVeda',
    expertHook:
        'The dose here is unremarkable, which is a compliment — it sits in the standard range. The useful idea is the split, because a prenatal you can actually keep down beats a better one you cannot. Confirm your own dose with your doctor.',
    highlights: [
      BrandHighlight(
        title: 'Two small tablets',
        body: 'Take them hours apart if that is what your stomach allows. Nothing is lost by splitting them.',
        icon: Icons.medication_liquid_rounded,
      ),
      BrandHighlight(
        title: 'A standard dose',
        body: '400 mcg of folate — the ordinary, well-evidenced amount. Not a megadose, and it should not be.',
        icon: Icons.check_circle_outline_rounded,
      ),
    ],
    resources: [
      BrandResource(
        label: 'Why folate, why now',
        blurb: 'Neural tube development begins before most women know they are pregnant. ParentVeda\'s explainer.',
      ),
    ],
  ),
);

final BrandCampaign _nursingLaunch = BrandCampaign(
  id: 'launch_mamabloom_nursing',
  brand: kMamaBloom,
  slot: BrandSlot.launchHub,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  // Targeting narrows: only mothers who have told us they are feeding this way.
  // A mother who has said nothing does not see this.
  audience: const BrandAudience(
    stage: BrandStage.parenting,
    anySignal: {'breastfeeding', 'mixed', 'expressed'},
  ),
  creative: const BrandCreative(
    eyebrow: 'New from MamaBloom',
    headline: 'The Night Layer',
    subline: 'Nursing clothes designed for 3 a.m., not for a photograph.',
    story:
        'MamaBloom asked 400 mothers what they actually wore for night feeds. The answer was almost never nursing wear — it was whatever opened fastest in the dark. So they built for that: one-handed, no clasp to find, no light needed. It is plain-looking on purpose.',
    cta: 'Explore the launch',
    expertName: 'Priya Nair',
    expertRole: 'Lactation consultant · introduces this launch for ParentVeda',
    expertHook:
        'Anything that shortens the gap between waking and latching helps a night feed go better. That is a real, small thing — not a fix for supply, and it will not make the night shorter.',
    highlights: [
      BrandHighlight(
        title: 'Opens one-handed',
        body: 'Because the other arm is holding a baby. No clasp, no hunting for it in the dark.',
        icon: Icons.back_hand_outlined,
      ),
      BrandHighlight(
        title: 'Plain on purpose',
        body: 'It is not designed to be seen. Mothers told them the pretty ones sat unworn in a drawer.',
        icon: Icons.bedtime_outlined,
      ),
    ],
    resources: [
      BrandResource(
        label: 'Surviving night feeds',
        blurb: 'What actually helps at 3 a.m., most of which costs nothing. ParentVeda\'s guide.',
      ),
    ],
  ),
);

final BrandCampaign _diaperLaunch = BrandCampaign(
  id: 'launch_tinytoes_softfit',
  brand: kTinyToes,
  slot: BrandSlot.launchHub,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting, childAgeMonthsMax: 24),
  creative: const BrandCreative(
    eyebrow: 'New from TinyToes',
    headline: 'SoftFit',
    subline: 'A diaper that changed its waistband, and not much else.',
    story:
        'TinyToes did not reinvent the diaper. They changed the waistband after a year of complaints about red marks at the hip, and left everything else alone. It is a small, honest change, and they are launching it as one rather than calling it a breakthrough.',
    cta: 'Explore the launch',
    expertName: 'Dr Anjali Rao',
    expertRole: 'Paediatric dermatologist · introduces this launch for ParentVeda',
    expertHook:
        'Red marks at the hip are usually fit, not the material — a size up often solves it for free. Try that before you switch brands.',
    highlights: [
      BrandHighlight(
        title: 'A softer waistband',
        body: 'The one change they made. Everything else is the diaper you already know.',
        icon: Icons.child_friendly_rounded,
      ),
    ],
    resources: [
      BrandResource(
        label: 'Reading a nappy rash',
        blurb: 'What rash means what, and which ones need a doctor. ParentVeda\'s guide.',
      ),
    ],
  ),
);

// =============================================================================
//  Premiere (takeover) — the rarest, most expensive placement.
//  Once per campaign, 3–6 times a year, always skippable.
// =============================================================================

final BrandCampaign _calmBalmPremiere = BrandCampaign(
  id: 'premiere_nestlingco_calm_balm_2026',
  brand: kNestlingCo,
  slot: BrandSlot.premiere,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  // BUG FIX: this used to target `parenting`, but the only Premiere trigger is
  // the pregnancy shell (MainScaffold) asking for pregnancy-stage campaigns —
  // so it could never resolve and the flagship product had literally never
  // rendered once. A baby lotion is honestly relevant to both stages (a
  // third-trimester parent is buying exactly this), so it reaches everyone.
  audience: BrandAudience.everyone,
  maxImpressions: 1, // once per campaign — persisted, survives reinstall
  linkedCampaignId: 'launch_nestlingco_calm_balm',
  creative: const BrandCreative(
    eyebrow: 'A ParentVeda Premiere',
    headline: 'Calm Balm',
    subline: 'Five ingredients. No fragrance. Two years in the making.',
    story:
        'NestlingCo built a balm for the babies their old lotion could not help. Five ingredients, no fragrance, and a smell most parents will not love. Here is why they made that trade.',
    cta: 'Watch the launch',
    videoRef: null, // no film yet — the surface renders its own title sequence
  ),
);

// =============================================================================
//  Presented-by (Phase 2)
// -----------------------------------------------------------------------------
//  ParentVeda's content, a brand's funding, a visible attribution. Every one of
//  these names its exact placement (placementKey) so buying "tool sponsorship"
//  cannot brand every tool in the app.
//
//  The creative here is deliberately thin: on a presented-by surface the brand
//  gets a LINE, not a story. The content is ours.
// =============================================================================

/// Product 3 — an educational collection. "Understanding Baby Skin, presented
/// by X". The collection is ParentVeda's; the brand funded it existing.
final BrandCampaign _skinEducation = BrandCampaign(
  id: 'edu_nestlingco_skin',
  brand: kNestlingCo,
  slot: BrandSlot.sponsoredEducation,
  placementKey: 'skin', // a ReadCollection id in pp_reading_data.dart
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Understanding baby skin',
    subline: 'ParentVeda\'s collection on skin, funded by NestlingCo.',
    story: '',
    cta: '',
  ),
);

/// Product 8 — a tool. The sponsor line is small on purpose: a parent opened
/// this to track their baby's sleep, not to meet a brand.
final BrandCampaign _sleepToolSponsor = BrandCampaign(
  id: 'tool_tinytoes_sleep',
  brand: kTinyToes,
  slot: BrandSlot.sponsoredTool,
  placementKey: 'sleep_journey',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Sleep journey',
    subline: 'Supported by TinyToes.',
    story: '',
    cta: '',
  ),
);

/// Product 13 — a milestone. Editorial content, brand-funded, and the
/// milestone itself is never moved, reworded or gated by the sponsorship.
final BrandCampaign _developmentMilestone = BrandCampaign(
  id: 'milestone_tinytoes_development',
  brand: kTinyToes,
  slot: BrandSlot.sponsoredMilestone,
  placementKey: 'development_journey',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting, childAgeMonthsMax: 24),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Development journey',
    subline: 'Supported by TinyToes.',
    story: '',
    cta: '',
  ),
);

/// Product 11 — a community campaign. The participation is the point; the
/// brand is named for funding it and never sees who took part.
final BrandCampaign _communityCampaign = BrandCampaign(
  id: 'community_mamabloom_nightfeeds',
  brand: kMamaBloom,
  slot: BrandSlot.communityCampaign,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(
    stage: BrandStage.parenting,
    anySignal: {'breastfeeding', 'mixed', 'expressed', 'nightWaking'},
  ),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'The 3 a.m. thread',
    subline: 'Parents swapping what actually helps at night. Funded by MamaBloom.',
    story: '',
    cta: '',
  ),
);

/// Product 10 — a live expert session. The doctor stays independent: the brand
/// funds the room, and does not choose the answers given in it.
final BrandCampaign _liveSession = BrandCampaign(
  id: 'live_purestart_firsttrimester',
  brand: kPureStart,
  slot: BrandSlot.liveSession,
  placementKey: 'prepare_hub',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.pregnancy),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Live sessions',
    subline: 'Supported by PureStart.',
    story: '',
    cta: '',
  ),
);

/// Product 7 — a guided journey. ParentVeda built the 30 days and wrote every
/// word of them; MamaBloom funded the placement. Targeted to mothers who told
/// us they are breastfeeding, so it never reaches a mother who is not.
final BrandCampaign _breastfeedingJourney = BrandCampaign(
  id: 'journey_mamabloom_breastfeeding',
  brand: kMamaBloom,
  slot: BrandSlot.sponsoredJourney,
  placementKey: 'jrn_breastfeeding_30',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(
    stage: BrandStage.parenting,
    anySignal: {'breastfeeding', 'mixed', 'expressed'},
  ),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: '30 days of breastfeeding',
    subline: 'Supported by MamaBloom.',
    story: '',
    cta: '',
  ),
);

// =============================================================================
//  Ranked inventory (Phase 3)
// -----------------------------------------------------------------------------
//  A sponsored item enters a ranked list ONLY at a position its own merit
//  earns, and only if it clears the quality floor unpaid. placementKey names an
//  existing RecoItem id — a brand features something already in the catalogue
//  and judged on its own terms, rather than injecting new inventory.
// =============================================================================

/// Product 5 — a featured recommendation. Inserted by the rank floor, labelled
/// on the item, and unable to outrank anything better. See rank_floor.dart.
final BrandCampaign _featuredReco = BrandCampaign(
  id: 'reco_nestlingco_featured',
  brand: kNestlingCo,
  slot: BrandSlot.recoFeatured,
  placementKey: 'bk_contrast', // an existing RecoItem (pvRating 4.8), rated on its own merits
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  maxImpressions: 30,
  creative: const BrandCreative(
    eyebrow: 'Featured',
    headline: 'Featured by NestlingCo',
    subline: 'Placed by merit, labelled, and never above a better pick.',
    story: '',
    cta: '',
  ),
);

/// Product 9 — a curated collection. A brand funds the theme existing;
/// ParentVeda still chooses every pick in it, and the picks do not change.
final BrandCampaign _sponsoredCollection = BrandCampaign(
  id: 'collection_tinytoes_sensory',
  brand: kTinyToes,
  slot: BrandSlot.sponsoredCollection,
  placementKey: 'sensory', // an existing RecoCollection id
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  maxImpressions: 30,
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Sensory Play Collection',
    subline: 'Supported by TinyToes.',
    story: '',
    cta: '',
  ),
);

// =============================================================================
//  Research surfaces (Product 4 + 6) — FLAGGED, see needs_attention.dart
// -----------------------------------------------------------------------------
//  Built at the product owner's direction despite contradicting shipped copy.
//  The hard rules that make them survivable at all:
//    · sponsorship cannot touch parentScore/parentsPct/expertsPct (tested)
//    · a sponsored study is labelled and sorted BELOW independent research
//    · a Compare sponsor may never be one of the two products being compared
// =============================================================================

/// Product 4 — a sponsored expert video on a Product Guide.
final BrandCampaign _guideExpert = BrandCampaign(
  id: 'guide_expert_nestlingco',
  brand: kNestlingCo,
  slot: BrandSlot.productGuideExpert,
  placementKey: 'lotion',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Expert videos',
    subline: 'Supported by NestlingCo.',
    story: '',
    cta: '',
  ),
);

/// Product 4 — a sponsored Research Corner on a Product Guide.
final BrandCampaign _guideResearch = BrandCampaign(
  id: 'guide_research_nestlingco',
  brand: kNestlingCo,
  slot: BrandSlot.productGuideResearch,
  placementKey: 'lotion',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Research corner',
    subline: 'Supported by NestlingCo. They chose none of it.',
    story: '',
    cta: '',
  ),
);

/// Product 6 — a sponsored educational note under a comparison. Never one of
/// the compared products; never touches the table.
final BrandCampaign _compareNote = BrandCampaign(
  id: 'compare_tinytoes_note',
  brand: kTinyToes,
  slot: BrandSlot.compareGuide,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'How to compare well',
    subline: 'Supported by TinyToes.',
    story: '',
    cta: '',
  ),
);

/// Product 12 — sampling. FLAGGED: collects requests it cannot fulfil.
final BrandCampaign _sampling = BrandCampaign(
  id: 'sample_nestlingco_calm_balm',
  brand: kNestlingCo,
  slot: BrandSlot.productSampling,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  maxImpressions: 20,
  creative: const BrandCreative(
    eyebrow: 'Free sample',
    headline: 'Try Calm Balm free',
    subline: 'A 15g tin, posted to you. No card, no subscription.',
    story:
        'NestlingCo will send 500 tins to parents whose babies have reactive skin. ParentVeda runs the list and never passes your details on — the brand sees a count, not a name.',
    cta: 'Register interest',
  ),
);

// =============================================================================
//  The catalogue
// =============================================================================

/// Every campaign in the ecosystem. Read ONLY by BrandStudio — never import
/// this from a screen.
final List<BrandCampaign> kBrandCampaigns = [
  // Phase 1 — takeover + destination
  _calmBalmPremiere,
  _calmBalmLaunch,
  _folateLaunch,
  _nursingLaunch,
  _diaperLaunch,
  // Phase 2 — presented-by
  _skinEducation,
  _sleepToolSponsor,
  _developmentMilestone,
  _communityCampaign,
  _liveSession,
  _breastfeedingJourney,
  // Phase 3 — ranked inventory
  _featuredReco,
  _sponsoredCollection,
  // Research surfaces — flagged, see needs_attention.dart
  _guideExpert,
  _guideResearch,
  _compareNote,
  // Sampling — flagged, no fulfilment behind it
  _sampling,
];
