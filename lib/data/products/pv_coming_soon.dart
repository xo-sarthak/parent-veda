// =============================================================================
//  Coming soon: the essentials the team's sheet does not cover yet
// -----------------------------------------------------------------------------
//  ⚠️ THE SHEET IS THE SOURCE OF TRUTH (2026-10-28, the user: "consider the
//  sheet as the source of truth, and wherever a product or category is
//  essential and the sheet does not cover it, have it, but say Coming soon on
//  it, like marketplace apps do").
//
//  When the invented seed products left the store (pv_catalog_adapters.dart),
//  a few essentials were left with nothing on their shelf. Each gets ONE
//  place-holder here: a plain name, no brand, no price, no photo, no link,
//  never sold here, never in a cart. It marks a GAP TO FILL IN THE SHEET, not
//  a product: the day the sheet (or the live store rows) puts one real
//  product on the same shelf, the place-holder steps aside by itself
//  ([pvPlaceComingSoon]), so nobody has to remember to delete it.
//
//  Each entry names the retired seed product whose shelf it stands on, so it
//  inherits that seed's stage, shelf, sub-shelf, week and age, and nothing
//  else: the seed's name, brand, price, reviews and specs stay out.
//
//  DELIBERATELY NO PLACE-HOLDER (keep the shelf empty, its own empty line
//  shows): feeding bottles and sterilisers (India's IMS Act; the Feeding door
//  never promotes bottles) and baby lotion (NHS: nothing on a newborn's skin
//  in the first month). Not an oversight; do not add them.
// =============================================================================

import '../../models/pv_product.dart';

/// One gap: the place-holder's [id] (prefixed [kPvComingSoonPrefix]), its
/// plain [name], the retired seed product whose shelf it stands on
/// ([seedId]), and one honest [line] on what belongs there.
class PvComingSoonEntry {
  const PvComingSoonEntry({
    required this.id,
    required this.name,
    required this.seedId,
    required this.line,
  });
  final String id;
  final String name;
  final String seedId;
  final String line;
}

/// The one line a place-holder's page says, and nothing invented after it.
const String kPvComingSoonLine =
    "We're choosing the ones we'd recommend. Coming soon.";

/// The words on a place-holder's pill.
const String kPvComingSoonLabel = 'Coming soon';

const List<PvComingSoonEntry> kPvComingSoon = [
  // ---- Pregnancy ----
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}belly_band',
    name: 'Belly support band',
    seedId: 'bb_overall',
    line: 'A soft band that supports the bump and the lower back.',
  ),
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}maternity_wear',
    name: 'Maternity wear',
    seedId: 'mw_overall',
    line: 'Leggings, kurtis and nursing tops that grow with the bump.',
  ),
  // ---- Parenting ----
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}white_noise',
    name: 'White-noise machine',
    seedId: 'dozy',
    line: 'A steady sound that masks the household between sleep cycles.',
  ),
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}sleep_sack',
    name: 'Sleep sack',
    // Stands on 'Sleepwear & sacks' (the retired Merino sack's shelf), where
    // the Sleep door's overheating page sends "Sleep sacks and bags".
    // It sat on the snugglesack's 'Bedding & blackout' shelf, which left
    // pp_products/sleepwear_and_sacks empty (SL5).
    // Kept for revert: seedId: 'snugglesack',
    seedId: 'merinosack',
    line: 'A wearable blanket, so there is nothing loose in the cot.',
  ),
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}blackout_curtains',
    name: 'Blackout curtains',
    seedId: 'hushcurtains',
    line: 'Keeps early light from ending naps and nights too soon.',
  ),
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}nappy_rash_cream',
    name: 'Nappy rash cream',
    seedId: 'rashcream',
    line: 'A barrier cream for the nappy area.',
  ),
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}baby_wash',
    name: 'Baby wash',
    seedId: 'babywash',
    line: 'A mild, fragrance-free wash for bath time.',
  ),
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}weaning_spoons',
    name: 'Weaning spoons and bowls',
    seedId: 'spoons',
    line: 'Soft spoons and steady bowls for first foods.',
  ),
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}baby_proofing',
    name: 'Baby-proofing (corner guards, cabinet locks)',
    seedId: 'cornerguard',
    line: 'For the day crawling starts: corners, cabinets and drawers.',
  ),
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}first_aid_kit',
    name: 'Baby first-aid kit',
    seedId: 'firstaid',
    line: 'The basics in one place, for small bumps and fevers.',
  ),
  PvComingSoonEntry(
    id: '${kPvComingSoonPrefix}stroller',
    name: 'Stroller',
    seedId: 'stroller',
    line: 'For walks from the newborn weeks on.',
  ),
];

/// The step-aside rule, pure so it is tested without a store: a
/// place-holder stays only while no REAL product shares its stage and shelf.
/// Real products are never touched, and their order is kept.
List<PvProduct> pvPlaceComingSoon(List<PvProduct> all) {
  String shelf(PvProduct p) => '${p.stage.name}|${p.categoryId}';
  final filled = {
    for (final p in all)
      if (!p.comingSoon) shelf(p),
  };
  return [
    for (final p in all)
      if (!p.comingSoon || !filled.contains(shelf(p))) p,
  ];
}

/// Real products first, place-holders after, each group in its own order.
/// Every shelf and search list uses it (a place-holder never leads).
List<PvProduct> pvComingSoonLast(List<PvProduct> list) => [
      for (final p in list)
        if (!p.comingSoon) p,
      for (final p in list)
        if (p.comingSoon) p,
    ];
