// =============================================================================
//  Critical thinking & first principles — the product shelf (placeholders)
// -----------------------------------------------------------------------------
//  `ParentVeda_Thinking_structure.pdf`: "Puzzle books, logic games,
//  brain-teaser cards (parent buys) — Product shelf — single-source the
//  shop, optional", resolved as "Age-tagged, parent-gated, through the shop
//  that exists. Optional, never a gate."
//
//  Skilling's own shelf, per the standing call (Coding question 6, held on
//  every door since): entries live here and open a parent-side sheet; the
//  shop unification later takes this list. One of each per band, titled by
//  kind, never by brand. Ids in the ledger (ST7).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkProduct> kSkThinkingProducts = [
  for (final (band, idBand, name) in [
    ('6-8', '68', 'Ask lots of whys'),
    ('8-11', '811', 'Work out how it works'),
    ('11-14', '1114', 'Think for yourself'),
  ]) ...[
    SkProduct(
      id: 'th_prod_${idBand}_book',
      title: 'A puzzle book, $name',
      kind: SkProductKind.book,
      bands: [band],
      blurb: 'Placeholder. A real, sourced puzzle book goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'th_prod_${idBand}_game',
      title: 'A logic game, $name',
      kind: SkProductKind.game,
      bands: [band],
      blurb: 'Placeholder. A real, sourced logic game goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'th_prod_${idBand}_cards',
      title: 'Brain-teaser cards, $name',
      kind: SkProductKind.game,
      bands: [band],
      blurb: 'Placeholder. A real, sourced deck goes here.',
      comingSoon: true,
    ),
  ],
];
