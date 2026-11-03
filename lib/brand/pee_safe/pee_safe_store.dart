// =============================================================================
//  Pee Safe in the live store (2026-11-03)
// -----------------------------------------------------------------------------
//  The demo's product placements were on the old Recommendations screens
//  (RecoItem, the parenting purple), which the shipped app no longer opens.
//  The store parents actually browse is the catalogue (PvProduct, the shelves
//  in pv_catalog_adapters.dart). So Pee Safe's 13 products go there, each on
//  the shelf where a parent already looks for it:
//
//    · Maternal Recovery (pregnancy store, the weeks after birth): pads,
//      period pants, the peri bottle, and the period range for when periods
//      come back
//    · Skincare & Hygiene: liners, the wash, wipes, the seat spray
//    · Parenting · On the move: the travel kit, the seat spray, wipes
//
//  The rules hold, unchanged:
//    · Labelled: badge "Sponsored", brand "Pee Safe", on every card.
//    · No ratings and no reviews of ours: rating 0, nothing invented. No
//      price either (it goes stale); the price note sends her to the store,
//      which shows the live price.
//    · Not ranked up: the products join the end of their shelf, after the
//      ones ParentVeda chose. Sponsorship buys a place on the shelf, never a
//      better place than a better product.
//    · Behind kPeeSafeDemo, like every Pee Safe surface.
//
//  Out of the TTC store on purpose: the TTC read says no intimate product
//  helps you conceive, and a shelf of them would say otherwise.
// =============================================================================

import '../../services/life_stage_store.dart' show LifeStage;
import '../../models/pv_product.dart';
import 'pee_safe_brand.dart';
import 'pee_safe_products.dart';

/// Where each product sits: (stage, category, sub-shelf or null for "All").
/// A product on two stages has two rows, with two ids.
const List<(String, LifeStage, String, String?)> _kShelves = [
  ('ps_night_pads', LifeStage.pregnancy, 'pvs_maternal_recovery', 'pvs_graded_flow_maternity_pads'),
  ('ps_all_night_kit', LifeStage.pregnancy, 'pvs_maternal_recovery', 'pvs_graded_flow_maternity_pads'),
  ('ps_period_panty', LifeStage.pregnancy, 'pvs_maternal_recovery', 'pvs_disposable_pull_up_underwear'),
  ('ps_jet_spray', LifeStage.pregnancy, 'pvs_maternal_recovery', 'pvs_ergonomic_peri_bottles'),
  ('ps_menstrual_cup', LifeStage.pregnancy, 'pvs_maternal_recovery', null),
  ('ps_cup_sterilizer', LifeStage.pregnancy, 'pvs_maternal_recovery', null),
  ('ps_cramp_relief', LifeStage.pregnancy, 'pvs_maternal_recovery', null),
  ('ps_zero_period_kit', LifeStage.pregnancy, 'pvs_maternal_recovery', null),
  ('ps_panty_liners', LifeStage.pregnancy, 'pvs_skincare_and_hygiene', 'pvs_organic_panty_liners'),
  ('ps_intimate_wash', LifeStage.pregnancy, 'pvs_skincare_and_hygiene', null),
  ('ps_intimate_wipes', LifeStage.pregnancy, 'pvs_skincare_and_hygiene', null),
  ('ps_seat_sanitizer', LifeStage.pregnancy, 'pvs_skincare_and_hygiene', null),
  ('ps_travels_kit', LifeStage.parenting, 'on_the_move', null),
  ('ps_seat_sanitizer', LifeStage.parenting, 'on_the_move', null),
  ('ps_intimate_wipes', LifeStage.parenting, 'on_the_move', null),
];

/// The label on every card: the disclosure, as the store's own badge.
const String kPeeSafeStoreBadge = 'Sponsored';

/// The store rows, in shelf order. Empty when the demo flag is off.
List<PvProduct> peeSafeStoreProducts() {
  if (!kPeeSafeDemo) return const [];
  final byId = {for (final p in kPeeSafeProducts) p.id: p};
  return [
    for (final (id, stage, cat, sub) in _kShelves)
      if (byId[id] case final p?)
        PvProduct(
          // The parenting copy of a product takes its own id: ids are unique
          // across the whole catalogue.
          id: stage == LifeStage.parenting ? '${p.id}_pp' : p.id,
          stage: stage,
          categoryId: cat,
          subId: sub,
          name: p.name,
          brand: kPeeSafe.name,
          summary: p.line,
          images: [p.image],
          priceNote: "Price on Pee Safe's store",
          retailer: kPeeSafe.name,
          buyUrl: p.url,
          badge: kPeeSafeStoreBadge,
          hue: 84,
        ),
  ];
}
