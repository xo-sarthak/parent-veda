// =============================================================================
//  Meditation, yoga & mindfulness — the product shelf (placeholders)
// -----------------------------------------------------------------------------
//  `ParentVeda_Stillness_structure.pdf`: "A cushion, a kids' mat, calm
//  cards (parent buys) — Product shelf — single-source the shop, optional",
//  resolved as "Parent-gated, through the existing shop. Optional, never a
//  gate."
//
//  Skilling's own shelf, per the standing call (Coding question 6, held on
//  every door since): entries live here and open a parent-side sheet; the
//  shop unification later takes this list. One of each per band, titled by
//  kind, never by brand. Ids in the ledger (SL7).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkProduct> kSkStillnessProducts = [
  for (final (band, idBand, name) in [
    ('6-8', '68', 'Breathe and wiggle'),
    ('8-11', '811', 'Sit and settle'),
    ('11-14', '1114', 'Find your calm'),
  ]) ...[
    SkProduct(
      id: 'sl_prod_${idBand}_cushion',
      title: 'A cushion, $name',
      kind: SkProductKind.other,
      bands: [band],
      blurb: 'Placeholder. A real, sourced sitting cushion goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'sl_prod_${idBand}_mat',
      title: 'A kids\' mat, $name',
      kind: SkProductKind.other,
      bands: [band],
      blurb: 'Placeholder. A real, sourced kids\' yoga mat goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'sl_prod_${idBand}_cards',
      title: 'Calm cards, $name',
      kind: SkProductKind.game,
      bands: [band],
      blurb: 'Placeholder. A real, sourced deck goes here.',
      comingSoon: true,
    ),
  ],
];
