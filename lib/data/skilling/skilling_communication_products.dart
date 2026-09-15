// =============================================================================
//  Communication & articulation — the product shelf (placeholder entries)
// -----------------------------------------------------------------------------
//  `ParentVeda_Communication_structure.pdf`: "Story decks, picture books,
//  conversation games (parent buys) — Product shelf — single-source the
//  existing shop", resolved as "Story card decks, picture books, conversation
//  games, puppets. Age-tagged, parent-gated, sold through the shop that
//  already exists. Never an ad shown to the child."
//
//  The user's standing call (Coding question 6, reconfirmed 2026-09-15,
//  question 5, a): skilling's own shelf now, the shops unified later. So the
//  entries live here and open a parent-side sheet, as Coding's do. One per
//  kind per band, titled by kind, never by brand. Ids in the ledger (SC6).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkProduct> kSkCommunicationProducts = [
  for (final (band, idBand, name) in [
    ('6-8', '68', 'Say it out loud'),
    ('8-11', '811', 'Tell it and explain it'),
    ('11-14', '1114', 'Say what you think'),
  ]) ...[
    SkProduct(
      id: 'cm_prod_${idBand}_deck',
      title: 'A story card deck, $name',
      kind: SkProductKind.game,
      bands: [band],
      blurb: 'Placeholder. A real, sourced deck goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'cm_prod_${idBand}_book',
      title: 'A picture book, $name',
      kind: SkProductKind.book,
      bands: [band],
      blurb: 'Placeholder. A real, sourced book goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'cm_prod_${idBand}_game',
      title: 'A conversation game, $name',
      kind: SkProductKind.game,
      bands: [band],
      blurb: 'Placeholder. A real, sourced game goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'cm_prod_${idBand}_puppet',
      title: 'A puppet, $name',
      kind: SkProductKind.other,
      bands: [band],
      blurb: 'Placeholder. A real, sourced puppet goes here.',
      comingSoon: true,
    ),
  ],
];
