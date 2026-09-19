// =============================================================================
//  Creativity & expression — the product shelf (placeholders, always optional)
// -----------------------------------------------------------------------------
//  `ParentVeda_Creativity_structure.pdf`: "Crayons, clay, a cheap
//  instrument, a craft kit (parent buys, always optional) — Product shelf —
//  single-source the existing shop", resolved as "Age-tagged, parent-gated,
//  through the shop that exists. Always an option, never a gate on an
//  activity."
//
//  Skilling's own shelf, per the standing call (Coding question 6, held on
//  every door since): entries live here and open a parent-side sheet; the
//  shop unification later takes this list. Four per band, titled by kind,
//  never by brand. Every blurb names the no-supplies path, because the
//  brief says the shelf is "never a gate on an activity". Ids in the
//  ledger (MK7).
// =============================================================================

import '../../screens/skilling/sk_door_content.dart';

final List<SkProduct> kSkMakingProducts = [
  for (final (band, idBand, name) in [
    ('6-8', '68', 'Just make it'),
    ('8-11', '811', 'Make it yours'),
    ('11-14', '1114', 'Make something real'),
  ]) ...[
    SkProduct(
      id: 'mk_prod_${idBand}_crayons',
      title: 'Crayons, $name',
      kind: SkProductKind.other,
      bands: [band],
      blurb: 'Placeholder. A real, sourced box goes here. Optional; a '
          'pencil and the back of a calendar work too.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'mk_prod_${idBand}_clay',
      title: 'Clay, $name',
      kind: SkProductKind.other,
      bands: [band],
      blurb: 'Placeholder. A real, sourced pack goes here. Optional; atta '
          'dough works too.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'mk_prod_${idBand}_instrument',
      title: 'A cheap instrument, $name',
      kind: SkProductKind.other,
      bands: [band],
      blurb: 'Placeholder. A real, sourced instrument goes here. Optional; '
          'a steel dabba and two spoons work too.',
      comingSoon: true,
    ),
    SkProduct(
      id: 'mk_prod_${idBand}_kit',
      title: 'A craft kit, $name',
      kind: SkProductKind.kit,
      bands: [band],
      blurb: 'Placeholder. A real, sourced kit goes here. Optional; the '
          'junk drawer works too.',
      comingSoon: true,
    ),
  ],
];
