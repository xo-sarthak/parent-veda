// =============================================================================
//  Confidence & public speaking — the product shelf (placeholder entries)
// -----------------------------------------------------------------------------
//  `ParentVeda_Confidence_structure.pdf`: "A toy mic, prompt cards, a little
//  stage timer (parent buys) … Age-tagged, parent-gated, through the shop
//  that already exists. Never an ad to the child."
//
//  Skilling's own shelf, per the standing call (Coding question 6, held on
//  Communication and here): entries live here and open a parent-side
//  sheet; the shop unification later takes this list. One of each per
//  band, titled by kind, never by brand. Ids in the ledger (SF6).
//
//  ⚠️ THE STAGE TIMER IS A PROP, NOT A SCORE. A little timer a child holds
//  while she practises a two-minute talk is the brief's own item. Nothing
//  in the app reads it; nothing in the app times her.
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkProduct> kSkConfidenceProducts = [
  for (final (band, idBand, name) in [
    ('6-8', '68', 'Use your voice'),
    ('8-11', '811', 'Stand up and say it'),
    ('11-14', '1114', 'Give a real talk'),
  ]) ...[
    SkProduct(
      id: 'cf_prod_${idBand}_mic',
      title: 'A toy mic, $name',
      kind: SkProductKind.other,
      bands: [band],
      blurb: 'Placeholder. A real, sourced toy mic goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'cf_prod_${idBand}_cards',
      title: 'Prompt cards, $name',
      kind: SkProductKind.game,
      bands: [band],
      blurb: 'Placeholder. A real, sourced deck goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'cf_prod_${idBand}_timer',
      title: 'A little stage timer, $name',
      kind: SkProductKind.other,
      bands: [band],
      blurb: 'Placeholder. A real, sourced timer goes here. A prop she '
          'holds; the app never times her.',
      comingSoon: true,
    ),
  ],
];
