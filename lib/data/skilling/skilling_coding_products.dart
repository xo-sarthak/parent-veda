// =============================================================================
//  Coding & AI literacy — the product shelf (placeholder entries)
// -----------------------------------------------------------------------------
//  `ParentVeda_Coding_structure_v2.pdf`: "placeholder related-product entries
//  (kits, robotics, books), age-tagged, resolving through the existing
//  commerce surface, parent-gated."
//
//  ⚠️ THE ONE PLACE THE BUILD DEPARTS FROM THE BRIEF'S WORDING, ON THE
//  USER'S CALL. The "existing commerce surface" is the parenting shop
//  (`pp_products`), whose catalogue is Sleep / Skincare / Feeding / Play and
//  whose age axis is months. The user's answer (2026-09-14, question 6):
//  build the shelf alone on the skilling side; the product engines are to be
//  unified later in one pass. So these entries render on the grown-up
//  screen as cards and open a parent-side sheet, and nothing here imports
//  the parenting shop. When the unification comes, this list is the input.
//
//  Placeholders: one kit, one robotics set, one book per band, titled by
//  kind and never by brand. No product copy is authored. Ids are in the owed
//  ledger (S6).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkProduct> kSkCodingProducts = [
  for (final (band, idBand, name) in [
    ('6-8', '68', 'Unplugged'),
    ('8-11', '811', 'Blocks'),
    ('11-14', '1114', 'Projects'),
  ]) ...[
    SkProduct(
      id: 'cd_prod_${idBand}_kit',
      title: 'A coding kit, $name level',
      kind: SkProductKind.kit,
      bands: [band],
      blurb: 'Placeholder. A real, sourced kit goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'cd_prod_${idBand}_robot',
      title: 'A robotics set, $name level',
      kind: SkProductKind.robotics,
      bands: [band],
      blurb: 'Placeholder. A real, sourced set goes here.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'cd_prod_${idBand}_book',
      title: 'A good book, $name level',
      kind: SkProductKind.book,
      bands: [band],
      blurb: 'Placeholder. A real, sourced book goes here.',
      comingSoon: true,
    ),
  ],
];
