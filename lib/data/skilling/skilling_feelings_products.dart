// =============================================================================
//  Emotional intelligence & resilience — the product shelf (placeholders)
// -----------------------------------------------------------------------------
//  `ParentVeda_Feelings_structure.pdf`: "Feelings cards, a journal, a
//  picture book (parent buys) — Product shelf — single-source the shop,
//  optional", resolved as "Age-tagged, parent-gated, through the shop that
//  exists. Optional, never a gate."
//
//  Skilling's own shelf, per the standing call (Coding question 6, held on
//  every door since): entries live here and open a parent-side sheet; the
//  shop unification later takes this list. One of each per band, titled by
//  kind, never by brand. Ids in the ledger (FE8).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkProduct> kSkFeelingsProducts = [
  for (final (band, idBand, name) in [
    ('6-8', '68', 'Name what you feel'),
    ('8-11', '811', 'Handle the big feelings'),
    ('11-14', '1114', 'Find your way through'),
  ]) ...[
    SkProduct(
      id: 'fe_prod_${idBand}_cards',
      title: 'Feelings cards, $name',
      kind: SkProductKind.game,
      bands: [band],
      blurb: 'Placeholder. A real, sourced deck goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'fe_prod_${idBand}_journal',
      title: 'A paper journal, $name',
      kind: SkProductKind.other,
      bands: [band],
      blurb: 'Placeholder. A real, sourced notebook goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'fe_prod_${idBand}_book',
      title: 'A picture book, $name',
      kind: SkProductKind.book,
      bands: [band],
      blurb: 'Placeholder. A real, sourced picture book goes here.',
      comingSoon: true,
    ),
  ],
];
