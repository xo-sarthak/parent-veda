// =============================================================================
//  Brand Studio — seed campaigns
// -----------------------------------------------------------------------------
//  DEMO PARTNERS, NOT REAL PARTNERSHIPS. The brand names here are real so the
//  Brand Studio can be reviewed with a realistic end-to-end feel while the app
//  is in testing. None of these companies is a ParentVeda partner and none has
//  approved anything here. Accordingly, NO copy in this file asserts a fact
//  about a company: no invented trials, formulations, sample sizes or corporate
//  history, and no real clinician endorsing a real product. Every campaign
//  describes the CATEGORY in ParentVeda's own editorial voice.
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
import 'pee_safe/pee_safe_brand.dart';

// ---- brands -----------------------------------------------------------------
// `certified` stays false everywhere. Certification is an editorial judgement
// with an independent evaluation — it is never set from campaign data and it is
// not for sale. See docs/BRAND-STUDIO.md §13.

// ---------------------------------------------------------------------------
//  DEMO PARTNERS - NOT REAL PARTNERSHIPS.
// ---------------------------------------------------------------------------
//  These are real brand names, used so the Brand Studio can be reviewed with a
//  realistic end-to-end feel while the app is in testing. NONE of them is an
//  actual ParentVeda partner and none has approved anything here.
//
//  Two rules this file keeps, and must keep, now that the names are real:
//    1. NO INVENTED FACTS. No made-up trials, sample sizes, ingredient counts
//       or company history. Earlier drafts had those against fictional brands,
//       which was fine; against a real company it is fabricated research.
//       Copy here describes the CATEGORY and ParentVeda's own editorial view.
//    2. NO INVENTED ENDORSEMENTS. The expert voices are ParentVeda's, speaking
//       about the category - never a real clinician endorsing a real product.
//
//  Replace with contracted partners (and licensed logos) before anything
//  public-facing. See docs/BRAND-STUDIO.md.
//
//  logoAsset points at assets/brand/partners/. If a file is absent, BrandMark
//  falls back to a monogram automatically - so the app is complete either way.
// ---------------------------------------------------------------------------

const Brand kCetaphil = Brand(
  id: 'cetaphil',
  name: 'Cetaphil',
  colour: Color(0xFF0072CE),
  logoAsset: 'assets/brand/partners/cetaphil.png',
);

const Brand kHimalaya = Brand(
  id: 'himalaya',
  name: 'Himalaya',
  colour: Color(0xFF00843D),
  logoAsset: 'assets/brand/partners/himalaya.png',
);

const Brand kPhilipsAvent = Brand(
  id: 'philips_avent',
  name: 'Philips Avent',
  colour: Color(0xFF0B5ED7),
  logoAsset: 'assets/brand/partners/philips_avent.png',
);

const Brand kPampers = Brand(
  id: 'pampers',
  name: 'Pampers',
  colour: Color(0xFF0057A8),
  logoAsset: 'assets/brand/partners/pampers.png',
);

const Brand kNestle = Brand(
  id: 'nestle',
  name: 'Nestlé',
  colour: Color(0xFF6B4F3A),
  logoAsset: 'assets/brand/partners/nestle.png',
);

const Brand kApollo = Brand(
  id: 'apollo',
  name: 'Apollo Hospitals',
  colour: Color(0xFF00548F),
  logoAsset: 'assets/brand/partners/apollo.png',
);

const Brand kFisherPrice = Brand(
  id: 'fisher_price',
  name: 'Fisher-Price',
  colour: Color(0xFFE4002B),
  logoAsset: 'assets/brand/partners/fisher_price.png',
);

const List<Brand> kBrands = [
  kCetaphil,
  kHimalaya,
  kPhilipsAvent,
  kPampers,
  kNestle,
  kApollo,
  kFisherPrice,
  // Pee Safe stakeholder demo (docs/PEE-SAFE-DEMO.md, item 3): added with its
  // first campaign, the Premiere below.
  kPeeSafe,
];

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
  id: 'launch_cetaphil_calm_balm',
  brand: kCetaphil,
  slot: BrandSlot.launchHub,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  // Reaches both stages, matching the Premiere that announces it — a launch a
  // parent was just shown must not vanish when they tap through to it.
  audience: BrandAudience.everyone,
  creative: BrandCreative(
    eyebrow: 'New from Cetaphil',
    headline: 'Calm Balm',
    subline: 'A daily balm for babies whose skin flares up.',
    story:
        'Skin that turns dry and angry the moment the weather shifts is one of the most common things parents write to us about. This launch sits in that category: a plain, fragrance-free daily balm. What follows is ParentVeda\'s own reading of what matters in a baby balm — written by us, funded by nobody.',
    cta: 'Explore the launch',
    expertName: 'Dr Anjali Rao',
    expertRole: 'Paediatric dermatologist · on this category, for ParentVeda',
    expertHook:
        'A short, fragrance-free ingredient list is the right instinct for reactive skin. Patch-test on one arm for two days before you use it everywhere — that goes for this balm and every other one.',
    highlights: [
      BrandHighlight(
        title: 'Read ingredient list',
        body: 'A short list is easier to troubleshoot. If skin reacts, you can actually work out what it reacted to.',
        icon: Icons.spa_outlined,
      ),
      BrandHighlight(
        title: 'Fragrance free beats lightly',
        body: 'Fragrance is among the most common irritants in baby skincare. "Lightly scented" is still scented.',
        icon: Icons.air_rounded,
      ),
      BrandHighlight(
        title: 'Maker s own study',
        body: 'Any brand-run trial — this category is full of them — is a reason to look closer, never proof on its own.',
        icon: Icons.science_outlined,
      ),
    ],
    resources: [
      BrandResource(
        label: 'Understanding baby skin',
        blurb: 'What a flare-up actually is, why it happens, and when a balm is not the answer. Written by ParentVeda.',
      ),
      BrandResource(
        label: 'How patch test anything',
        blurb: 'Two days, one arm, one product at a time. The method works for any new product, not just this one.',
      ),
    ],
  ),
);

final BrandCampaign _folateLaunch = BrandCampaign(
  id: 'launch_himalaya_folate',
  brand: kHimalaya,
  slot: BrandSlot.launchHub,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.pregnancy, pregnancyWeekMax: 16),
  creative: const BrandCreative(
    eyebrow: 'New from Himalaya',
    headline: 'Folate+',
    subline: 'A prenatal built for the first trimester, when swallowing anything is hard.',
    story:
        'Most prenatals are one large tablet a day, which is a hard ask in the weeks when nausea is at its worst. This launch sits in that category. ParentVeda\'s view on prenatals follows — what the dose should look like, and why the one you can keep down beats the one you cannot.',
    cta: 'Explore the launch',
    expertName: 'Dr Meera Iyer',
    expertRole: 'Obstetrician · on this category, for ParentVeda',
    expertHook:
        'The dose here is unremarkable, which is a compliment — it sits in the standard range. The useful idea is the split, because a prenatal you can actually keep down beats a better one you cannot. Confirm your own dose with your doctor.',
    highlights: [
      BrandHighlight(
        // A literal, not S.now.*: this sits in a const BrandHighlight and a
        // getter can never be a constant expression.
        title: 'Timing is yours to choose',
        body: 'If a tablet can be taken when your stomach allows rather than on a fixed schedule, take advantage of that.',
        icon: Icons.medication_liquid_rounded,
      ),
      BrandHighlight(
        // A literal for the same reason as the sibling above: const context.
        title: 'Check the folate dose',
        body: '400 mcg is the ordinary, well-evidenced amount. A megadose is not better — confirm yours with your doctor.',
        icon: Icons.check_circle_outline_rounded,
      ),
    ],
    resources: [
      BrandResource(
        label: 'Why folate why now',
        blurb: 'Neural tube development begins before most women know they are pregnant. ParentVeda\'s explainer.',
      ),
    ],
  ),
);

final BrandCampaign _nursingLaunch = BrandCampaign(
  id: 'launch_philips_avent_nursing',
  brand: kPhilipsAvent,
  slot: BrandSlot.launchHub,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  // Targeting narrows: only mothers who have told us they are feeding this way.
  // A mother who has said nothing does not see this.
  audience: const BrandAudience(
    stage: BrandStage.parenting,
    anySignal: {'breastfeeding', 'mixed', 'expressed'},
  ),
  creative: BrandCreative(
    eyebrow: 'New from Philips Avent',
    headline: 'The Night Layer',
    subline: 'Nursing clothes designed for 3 a.m., not for a photograph.',
    story:
        'Ask mothers what they actually wear for night feeds and the answer is rarely nursing wear — it is whatever opens fastest in the dark. This launch sits in that category. ParentVeda\'s guidance on night feeds follows, most of which costs nothing.',
    cta: 'Explore the launch',
    expertName: 'Priya Nair',
    expertRole: 'Lactation consultant · on this category, for ParentVeda',
    expertHook:
        'Anything that shortens the gap between waking and latching helps a night feed go better. That is a real, small thing — not a fix for supply, and it will not make the night shorter.',
    highlights: [
      BrandHighlight(
        title: 'One handed whole test',
        body: 'The other arm is holding a baby. Anything needing two hands or a light fails at 3 a.m.',
        icon: Icons.back_hand_outlined,
      ),
      BrandHighlight(
        title: 'Pretty ones stay drawer',
        body: 'Night wear is not seen by anyone. Buy for the 3 a.m. test, not the photograph.',
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
  id: 'launch_pampers_softfit',
  brand: kPampers,
  slot: BrandSlot.launchHub,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting, childAgeMonthsMax: 24),
  creative: BrandCreative(
    eyebrow: 'New from Pampers',
    headline: 'SoftFit',
    subline: 'A diaper that changed its waistband, and not much else.',
    story:
        'Red marks at the hip are one of the most common nappy complaints we hear. This launch sits in that category. Before you switch brands over it, here is ParentVeda\'s own guidance — the answer is often cheaper than a new pack.',
    cta: 'Explore the launch',
    expertName: 'Dr Anjali Rao',
    expertRole: 'Paediatric dermatologist · on this category, for ParentVeda',
    expertHook:
        'Red marks at the hip are usually fit, not the material — a size up often solves it for free. Try that before you switch brands.',
    highlights: [
      BrandHighlight(
        title: 'Try size up first',
        body: 'Red marks at the hip are usually fit, not material. Going up a size often solves it for nothing.',
        icon: Icons.child_friendly_rounded,
      ),
    ],
    resources: [
      BrandResource(
        label: 'Reading nappy rash',
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
  id: 'premiere_cetaphil_calm_balm_2026',
  brand: kCetaphil,
  slot: BrandSlot.premiere,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  // BUG FIX: this used to target `parenting`, but the only Premiere trigger is
  // the pregnancy shell (MainScaffold) asking for pregnancy-stage campaigns —
  // so it could never resolve and the flagship product had literally never
  // rendered once. A baby lotion is honestly relevant to both stages (a
  // third-trimester parent is buying exactly this), so it reaches everyone.
  audience: BrandAudience.everyone,
  maxImpressions: 1, // once per campaign — persisted, survives reinstall
  linkedCampaignId: 'launch_cetaphil_calm_balm',
  creative: const BrandCreative(
    eyebrow: 'A ParentVeda Premiere',
    headline: 'Calm Balm',
    subline: 'Fragrance-free daily care, and what to look for in any balm.',
    story:
        'A fragrance-free daily balm, launching into the category parents ask us about most. ParentVeda has no stake in it — here is what we think actually matters when you choose one.',
    cta: 'Watch the launch',
    videoRef: null, // no film yet — the surface renders its own title sequence
  ),
);

// =============================================================================
//  Pee Safe — stakeholder demo (docs/PEE-SAFE-DEMO.md, item 3)
// -----------------------------------------------------------------------------
//  Same two rules as every seed above: no invented facts about the company,
//  and the expert speaks about the CATEGORY for ParentVeda. Audience is
//  everyone (P3: relevance, not stage — TTC included). Listed only while
//  kPeeSafeDemo is on.
// =============================================================================

final BrandCampaign _peeSafeLaunch = BrandCampaign(
  id: kPeeSafeLaunchId,
  brand: kPeeSafe,
  slot: BrandSlot.launchHub,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: BrandAudience.everyone,
  creative: const BrandCreative(
    eyebrow: 'New from Pee Safe',
    headline: 'Care for the in-between',
    subline: 'Everyday hygiene for pregnancy, the hospital bag and the weeks after birth.',
    story:
        'The things mothers ask us about least out loud are often the body\'s quieter changes: more discharge in pregnancy, bleeding after birth, a public toilet with a toddler in tow. Pee Safe makes everyday intimate and toilet hygiene products for those moments. What follows is ParentVeda\'s own reading of what matters, whichever brand you buy.',
    cta: 'Explore the launch',
    // Item 10b: the brand page's film slot reads this (the launch's creative).
    videoRef: kPeeSafeLaunchFilm,
    expertName: 'Dr Meera Iyer',
    expertRole: 'Obstetrician · on this category, for ParentVeda',
    expertHook:
        'Less is more down there. Water and a mild, unperfumed wash on the outside are enough, and after birth it is pads only until your check-up. If you soak a pad within an hour, pass large clots or run a fever, see your doctor.',
    highlights: [
      BrandHighlight(
        title: 'Water is usually enough',
        body: 'The vagina cleans itself. Wash the outside gently, skip perfume, and never douche.',
        icon: Icons.water_drop_outlined,
      ),
      BrandHighlight(
        title: 'Pads after birth',
        body: 'Nothing internal, no tampons or cups, until your doctor has seen you after the birth.',
        icon: Icons.health_and_safety_outlined,
      ),
      BrandHighlight(
        title: 'Pack for the first week',
        body: 'Maternity pads, disposable underwear and a way to rinse with water cover most of the first days.',
        icon: Icons.luggage_outlined,
      ),
    ],
    // Item 5: every resource points at a real read (pee_safe_reads.dart), so
    // the brand page's shelf and the launch's list open PvReaderScreen.
    // test/pee_safe_reads_test.dart holds each readId to a read that exists.
    // The item-3 pair, kept for revert (no readId, toast on tap):
    // BrandResource(label: 'Discharge in pregnancy', blurb: 'What is normal, what changes, and when to call your doctor. Written by ParentVeda.'),
    // BrandResource(label: 'Bleeding after birth', blurb: 'How long it lasts, how it changes, and the signs that need a doctor. ParentVeda\'s guide.'),
    resources: [
      BrandResource(
        label: 'Discharge in pregnancy',
        blurb: 'What is normal, what changes, and when to call your doctor. Written by ParentVeda.',
        readId: 'ps_read_discharge',
      ),
      BrandResource(
        label: 'UTIs and toilet hygiene',
        blurb: 'Why urine infections are more common in pregnancy, and what really helps on the loo.',
        readId: 'ps_read_uti',
      ),
      BrandResource(
        label: 'Bleeding after birth, and the pads for it',
        blurb: 'How long it lasts, how it changes, and the signs that need a doctor. ParentVeda\'s guide.',
        readId: 'ps_read_lochia',
      ),
      BrandResource(
        label: 'Gentle care down below after birth',
        blurb: 'Stitches, soreness and the first weeks, step by step.',
        readId: 'ps_read_peri',
      ),
      BrandResource(
        label: 'When your periods come back',
        blurb: 'When to expect them, how they can feel, and why contraception matters first.',
        readId: 'ps_read_periods',
      ),
      BrandResource(
        label: 'Intimate hygiene while trying to conceive',
        blurb: 'What to keep, what to drop, and why simple is kindest.',
        readId: 'ps_read_ttc',
      ),
      BrandResource(
        label: 'Intimate hygiene: your questions',
        blurb: 'Short answers to the questions people search for late at night.',
        readId: 'ps_read_faq',
      ),
    ],
  ),
);

/// Item 5 — the Pee Safe reading shelf. ParentVeda's reads, Pee Safe's
/// funding, a visible attribution on every one (pee_safe_reads.dart). The
/// placement is the shelf itself, so this can never brand another collection.
final BrandCampaign _peeSafeEducation = BrandCampaign(
  id: kPeeSafeEducationId,
  brand: kPeeSafe,
  slot: BrandSlot.sponsoredEducation,
  placementKey: kPeeSafeReadsPlacement,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: BrandAudience.everyone,
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Read with Pee Safe',
    subline: 'ParentVeda\'s reads on intimate and toilet hygiene, funded by Pee Safe.',
    story: '',
    cta: '',
  ),
);

/// Item 6 — the postpartum recovery kit. ParentVeda's checklist, Pee Safe's
/// funding. Its own placementKey, so it can never brand another tool.
final BrandCampaign _peeSafeKitTool = BrandCampaign(
  id: kPeeSafeKitToolId,
  brand: kPeeSafe,
  slot: BrandSlot.sponsoredTool,
  placementKey: kPeeSafeKitPlacement,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: BrandAudience.everyone,
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Recovery kit',
    subline: "ParentVeda's postpartum checklist, funded by Pee Safe.",
    story: '',
    cta: '',
  ),
);

// ---- Product placements (item 7) --------------------------------------------
// Four campaigns, four keys, one per surface. The host content (a reco item, a
// checklist, a collection) is ParentVeda's and unchanged; the products render
// after it, through PeeSafeCollabShelf (pee_safe/pee_safe_collab.dart).

/// The featured pick. Keyed on an EXISTING RecoItem with its own rating
/// (pp_selfcare, 4.5): Pee Safe buys consideration, never a rating. Inserted by
/// the rank floor, so never slot 0 and never above a better pick.
final BrandCampaign _peeSafeFeatured = BrandCampaign(
  id: kPeeSafeFeaturedId,
  brand: kPeeSafe,
  slot: BrandSlot.recoFeatured,
  placementKey: kPeeSafeFeaturedKey,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: BrandAudience.everyone,
  creative: const BrandCreative(
    eyebrow: 'Featured',
    headline: 'Featured with Pee Safe',
    subline: 'Placed by merit, labelled, and never above a better pick.',
    story: '',
    cta: '',
  ),
);

/// Pee Safe rows after the hospital bag checklist (V1, the one that opens).
final BrandCampaign _peeSafeBag = BrandCampaign(
  id: kPeeSafeBagId,
  brand: kPeeSafe,
  slot: BrandSlot.sponsoredTool,
  placementKey: kPeeSafeBagKey,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: BrandAudience.everyone,
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Hospital bag',
    subline: 'Pee Safe picks after your own list.',
    story: '',
    cta: '',
  ),
);

/// The "After birth care" collection. ParentVeda chose every pick in it.
final BrandCampaign _peeSafeCollection = BrandCampaign(
  id: kPeeSafeCollectionId,
  brand: kPeeSafe,
  slot: BrandSlot.sponsoredCollection,
  placementKey: kPeeSafeCollectionKey,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: BrandAudience.everyone,
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'After Birth Care',
    subline: 'Supported by Pee Safe.',
    story: '',
    cta: '',
  ),
);

/// Travel products after "The 4-month travel kit" reco.
final BrandCampaign _peeSafeTravel = BrandCampaign(
  id: kPeeSafeTravelId,
  brand: kPeeSafe,
  slot: BrandSlot.nativeDiscovery,
  placementKey: kPeeSafeTravelKey,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: BrandAudience.everyone,
  creative: const BrandCreative(
    eyebrow: 'Sponsored',
    headline: 'For the road',
    subline: 'Pee Safe travel hygiene, after the travel kit.',
    story: '',
    cta: '',
  ),
);

final BrandCampaign _peeSafePremiere = BrandCampaign(
  id: kPeeSafePremiereId,
  brand: kPeeSafe,
  slot: BrandSlot.premiere,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: BrandAudience.everyone,
  maxImpressions: 1, // once per campaign; the demo replays via replayPremiere()
  linkedCampaignId: kPeeSafeLaunchId,
  creative: const BrandCreative(
    eyebrow: 'A ParentVeda Premiere',
    headline: 'Care for the in-between',
    subline: 'Everyday hygiene for pregnancy, birth and the weeks after.',
    story:
        'Pee Safe makes everyday intimate and toilet hygiene products. ParentVeda has written what we think matters in this category, whichever brand you choose.',
    cta: "See what's new",
    // Item 10b: the bundled film. If it fails to load, the Premiere plays its
    // own title sequence instead (premiere_screen.dart _startFilm).
    // Kept for revert: videoRef: null,
    videoRef: kPeeSafeLaunchFilm,
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
  id: 'edu_cetaphil_skin',
  brand: kCetaphil,
  slot: BrandSlot.sponsoredEducation,
  placementKey: 'skin', // a ReadCollection id in pp_reading_data.dart
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Understanding baby skin',
    subline: 'ParentVeda\'s collection on skin, funded by Cetaphil.',
    story: '',
    cta: '',
  ),
);

/// Product 8 — a tool. The sponsor line is small on purpose: a parent opened
/// this to track their baby's sleep, not to meet a brand.
final BrandCampaign _sleepToolSponsor = BrandCampaign(
  id: 'tool_pampers_sleep',
  brand: kPampers,
  slot: BrandSlot.sponsoredTool,
  placementKey: 'sleep_journey',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Sleep journey',
    subline: 'Supported by Pampers.',
    story: '',
    cta: '',
  ),
);

/// Product 13 — a milestone. Editorial content, brand-funded, and the
/// milestone itself is never moved, reworded or gated by the sponsorship.
final BrandCampaign _developmentMilestone = BrandCampaign(
  id: 'milestone_pampers_development',
  brand: kPampers,
  slot: BrandSlot.sponsoredMilestone,
  placementKey: 'development_journey',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting, childAgeMonthsMax: 24),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Development journey',
    subline: 'Supported by Pampers.',
    story: '',
    cta: '',
  ),
);

/// Product 11 — a community campaign. The participation is the point; the
/// brand is named for funding it and never sees who took part.
final BrandCampaign _communityCampaign = BrandCampaign(
  id: 'community_philips_avent_nightfeeds',
  brand: kPhilipsAvent,
  slot: BrandSlot.communityCampaign,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(
    stage: BrandStage.parenting,
    anySignal: {'breastfeeding', 'mixed', 'expressed', 'nightWaking'},
  ),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'The 3 a.m. thread',
    subline: 'Parents swapping what actually helps at night. Funded by Philips Avent.',
    story: '',
    cta: '',
  ),
);

/// Product 10 — a live expert session. The doctor stays independent: the brand
/// funds the room, and does not choose the answers given in it.
final BrandCampaign _liveSession = BrandCampaign(
  id: 'live_himalaya_firsttrimester',
  brand: kHimalaya,
  slot: BrandSlot.liveSession,
  placementKey: 'prepare_hub',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.pregnancy),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Live sessions',
    subline: 'Supported by Himalaya.',
    story: '',
    cta: '',
  ),
);

/// Product 7 — a guided journey. ParentVeda built the 30 days and wrote every
/// word of them; Philips Avent funded the placement. Targeted to mothers who told
/// us they are breastfeeding, so it never reaches a mother who is not.
final BrandCampaign _breastfeedingJourney = BrandCampaign(
  id: 'journey_philips_avent_breastfeeding',
  brand: kPhilipsAvent,
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
    subline: 'Supported by Philips Avent.',
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
  id: 'reco_cetaphil_featured',
  brand: kCetaphil,
  slot: BrandSlot.recoFeatured,
  placementKey: 'bk_contrast', // an existing RecoItem (pvRating 4.8), rated on its own merits
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  maxImpressions: 30,
  creative: const BrandCreative(
    eyebrow: 'Featured',
    headline: 'Featured by Cetaphil',
    subline: 'Placed by merit, labelled, and never above a better pick.',
    story: '',
    cta: '',
  ),
);

/// Product 9 — a curated collection. A brand funds the theme existing;
/// ParentVeda still chooses every pick in it, and the picks do not change.
final BrandCampaign _sponsoredCollection = BrandCampaign(
  id: 'collection_pampers_sensory',
  brand: kPampers,
  slot: BrandSlot.sponsoredCollection,
  placementKey: 'sensory', // an existing RecoCollection id
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  maxImpressions: 30,
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Sensory Play Collection',
    subline: 'Supported by Pampers.',
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
  id: 'guide_expert_cetaphil',
  brand: kCetaphil,
  slot: BrandSlot.productGuideExpert,
  placementKey: 'lotion',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Expert videos',
    subline: 'Supported by Cetaphil.',
    story: '',
    cta: '',
  ),
);

/// Product 4 — a sponsored Research Corner on a Product Guide.
final BrandCampaign _guideResearch = BrandCampaign(
  id: 'guide_research_cetaphil',
  brand: kCetaphil,
  slot: BrandSlot.productGuideResearch,
  placementKey: 'lotion',
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'Research corner',
    subline: 'Supported by Cetaphil. They chose none of it.',
    story: '',
    cta: '',
  ),
);

/// Product 6 — a sponsored educational note under a comparison. Never one of
/// the compared products; never touches the table.
final BrandCampaign _compareNote = BrandCampaign(
  id: 'compare_pampers_note',
  brand: kPampers,
  slot: BrandSlot.compareGuide,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  creative: const BrandCreative(
    eyebrow: 'Presented',
    headline: 'How to compare well',
    subline: 'Supported by Pampers.',
    story: '',
    cta: '',
  ),
);

/// Product 12 — sampling. FLAGGED: collects requests it cannot fulfil.
final BrandCampaign _sampling = BrandCampaign(
  id: 'sample_cetaphil_calm_balm',
  brand: kCetaphil,
  slot: BrandSlot.productSampling,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(stage: BrandStage.parenting),
  maxImpressions: 20,
  creative: const BrandCreative(
    eyebrow: 'Free sample',
    headline: 'Try Calm Balm free',
    subline: 'A 15g tin, posted to you. No card, no subscription.',
    story:
        'A limited number of tins go to parents whose babies have reactive skin. ParentVeda runs the list and never passes your details on — the brand sees a count, not a name, and never your address.',
    cta: 'Register interest',
  ),
);

// =============================================================================
//  The catalogue
// =============================================================================

/// Product 15 — a sponsored notification. The single most restrained placement
/// in the system, and the demo shows exactly why: it is PUSHED (arrives
/// unasked), so it is frequency-capped both per-campaign (maxImpressions) and
/// globally (BrandNotifications enforces a minimum gap between ANY two), and it
/// only ever reaches a parent it genuinely fits.
///
/// This is the prompt's own example — "a new breast pump launch for
/// breastfeeding mothers" — targeted so a mother who has not told us she
/// breastfeeds never receives it. maxImpressions: 1 means it is sent once, ever.
final BrandCampaign _pumpNotification = BrandCampaign(
  id: 'notif_philips_avent_pump',
  brand: kPhilipsAvent,
  slot: BrandSlot.sponsoredNotification,
  maxImpressions: 1,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(
    stage: BrandStage.parenting,
    anySignal: {'breastfeeding', 'expressed', 'mixed'},
    childAgeMonthsMax: 12,
  ),
  creative: const BrandCreative(
    eyebrow: 'From Philips Avent',
    // The notification TITLE and BODY come from headline + subline; the story
    // and CTA are unused for this slot (there is no landing screen yet — the
    // notification is the whole experience).
    headline: 'A quieter night pump',
    subline: 'Philips Avent’s new hospital-grade pump runs at library volume. Worth a look while you are up.',
    story: '',
    cta: '',
  ),
);

// ---- Sponsored notifications (Pee Safe demo, item 8) -------------------------
// Three pushed campaigns, each its own id and audience, each sent at most once
// (maxImpressions: 1) and all behind the global gap in BrandNotifications. The
// titles are plain: brand notifications never take a phone_emoji mark, and
// postpartum is a sensitive moment besides. A tap opens the screen that fits
// (openPeeSafeNotification), not the generic sponsor sheet.

/// Week 36: the hospital bag. Pregnancy only, weeks 36 to 40.
final BrandCampaign _peeSafeNotifBag = BrandCampaign(
  id: kPeeSafeNotifBagId,
  brand: kPeeSafe,
  slot: BrandSlot.sponsoredNotification,
  maxImpressions: 1,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(
    stage: BrandStage.pregnancy,
    pregnancyWeekMin: 36,
    pregnancyWeekMax: 40,
  ),
  creative: const BrandCreative(
    // Kept for revert: eyebrow 'From Pee Safe', headline 'Your hospital bag,
    // at 36 weeks', subline 'A few small things make a hospital bathroom
    // easier: pads, wipes, a seat cover. Your list is ready to check.'
    eyebrow: 'ParentVeda · with Pee Safe',
    headline: '36 weeks: the pocket most bags forget',
    subline: 'Maternity pads, a few wipes and a toilet seat cover make the first hospital bathroom trip easier. They are on your bag list, ready to tick.',
    story: '',
    cta: '',
  ),
);

/// The first days after birth: peri care. Parenting, a baby under one month
/// (the context knows months, not days; "day 3" is the moment it is written
/// for, and the gap plus the once-only cap keep it to one send).
final BrandCampaign _peeSafeNotifPeri = BrandCampaign(
  id: kPeeSafeNotifPeriId,
  brand: kPeeSafe,
  slot: BrandSlot.sponsoredNotification,
  maxImpressions: 1,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(
    stage: BrandStage.parenting,
    childAgeMonthsMax: 0,
  ),
  creative: const BrandCreative(
    // Kept for revert: eyebrow 'From Pee Safe', headline 'Gentle care in the
    // first days', subline 'How to keep clean and comfortable while you heal.
    // If bleeding gets heavier, you have a fever, or the pain grows, see your
    // doctor.'
    eyebrow: 'ParentVeda · with Pee Safe',
    headline: 'Healing down there, gently',
    subline: 'Warm water, a fresh pad every few hours, pat dry. Two minutes on what helps while you heal. If bleeding gets heavier, you have a fever, or the pain grows, see your doctor.',
    story: '',
    cta: '',
  ),
);

/// Travel: a baby old enough for the first trips (3 to 24 months).
final BrandCampaign _peeSafeNotifTravel = BrandCampaign(
  id: kPeeSafeNotifTravelId,
  brand: kPeeSafe,
  slot: BrandSlot.sponsoredNotification,
  maxImpressions: 1,
  schedule: BrandSchedule(start: _seedStart, end: _seedEnd),
  audience: const BrandAudience(
    stage: BrandStage.parenting,
    childAgeMonthsMin: 3,
    childAgeMonthsMax: 24,
  ),
  creative: const BrandCreative(
    // Kept for revert: eyebrow 'From Pee Safe', headline 'Travelling with your
    // baby', subline 'What helps with public toilets on the road, packed
    // light. The travel kit has the list.'
    eyebrow: 'ParentVeda · with Pee Safe',
    headline: 'First trips: the toilet-stop pouch',
    subline: 'A seat cover, a few wipes and a spare pad fit in one small pouch, so a highway stop is no drama. The travel kit has the list.',
    story: '',
    cta: '',
  ),
);

/// Every campaign in the ecosystem. Read ONLY by BrandStudio — never import
/// this from a screen.
final List<BrandCampaign> kBrandCampaigns = [
  // Pee Safe demo first: resolve() returns the first eligible Premiere, so
  // this is the one the app and the Brand Showcase open.
  if (kPeeSafeDemo) ...[
    _peeSafePremiere,
    _peeSafeLaunch,
    _peeSafeEducation,
    _peeSafeKitTool,
    _peeSafeFeatured,
    _peeSafeBag,
    _peeSafeCollection,
    _peeSafeTravel,
    // Before the pump: resolve() returns the first eligible notification.
    _peeSafeNotifBag,
    _peeSafeNotifPeri,
    _peeSafeNotifTravel,
  ],
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
  // One featured pick only: while the Pee Safe demo runs, its featured pick
  // replaces Cetaphil's rather than sitting beside it (docs/PEE-SAFE-DEMO.md).
  if (!kPeeSafeDemo) _featuredReco,
  _sponsoredCollection,
  // Research surfaces — flagged, see needs_attention.dart
  _guideExpert,
  _guideResearch,
  _compareNote,
  // Sampling — flagged, no fulfilment behind it
  _sampling,
  // Notification — one demo campaign, so the mechanism can be seen working
  _pumpNotification,
];
