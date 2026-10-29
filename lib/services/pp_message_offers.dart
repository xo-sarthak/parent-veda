// =============================================================================
//  The offers a Parenting message may make, for one child's age, and only the
//  ones that exist (PP 11, 2026-10-29; the Pregnancy twin is
//  `preg_message_offers.dart`)
// -----------------------------------------------------------------------------
//  The same rule as Pregnancy: a message never points at something we do not
//  have, so each offer is READ from a live store and an empty answer is
//  silence.
//
//  What counts as real, and FOR THIS AGE:
//    * a class: a programme PUBLISHED IN THE PANEL (`ProgrammeStore`) that has
//      an age window (migration 0124) around the child's age. One with no
//      window is for every age, so it is not "for this age" and is not sent;
//    * a toy: a Store toy whose age window is its own. ⚠️ A TOY WITH NO WINDOW
//      READS AS 0 TO 72 MONTHS (`_fromToy` defaults it), so `suitsAge` alone
//      is true for every child, and "For this age" would be a lie for 145 of
//      the 281 toys. Only the 136 with a real window are offered.
//
//  Best first: a class, then the toys that start closest to the child's age
//  (the highest lower bound that still fits), then the better score.
// =============================================================================

import '../data/learn/pv_learn_view.dart' show PvLearnKind;
import '../data/products/pv_sheet_products.dart' show kSheetToyCategoryId;
import '../models/pv_product.dart' show PvProduct;
import '../screens/learn/pv_learn_catalog.dart' show PvLearnCatalog;
import 'life_stage_store.dart';
import 'programme_store.dart';
import 'pv_catalog_store.dart';

/// One thing a Parenting message can offer. [ref] is what a tap opens:
/// `product:<id>` or `learn:<offering view id>`; [ageLabel] reads
/// mid-sentence ("4-5 years").
class PpOffer {
  const PpOffer({
    required this.ref,
    required this.name,
    required this.ageLabel,
    this.isClass = false,
  });
  final String ref;
  final String name;
  final String ageLabel;
  final bool isClass;
}

/// A toy whose age window is its own, not the 0-72 default.
bool ppToyHasAgeWindow(PvProduct p) =>
    !(p.ageMinMonths == 0 && p.ageMaxMonths == 72);

String _monthsLabel(int? from, int? to) {
  String one(int m) =>
      m >= 24 && m % 12 == 0 ? '${m ~/ 12} years' : '$m months';
  if (from != null && to != null) return '${one(from)} to ${one(to)}';
  if (from != null) return 'from ${one(from)}';
  return 'up to ${one(to!)}';
}

/// Everything real for a child of [months], best first. Empty when nothing
/// exists, and on any failure: a store that is not ready is no offer.
List<PpOffer> ppOffersForAge(int months) {
  final out = <PpOffer>[];

  try {
    final published = {for (final p in ProgrammeStore.instance.all) p.id};
    for (final v in PvLearnCatalog.instance.all(stage: LifeStage.parenting)) {
      if (v.kind == PvLearnKind.consult || !published.contains(v.id)) continue;
      if (!v.hasAgeWindow || !v.fitsAge(months)) continue;
      out.add(
        PpOffer(
          ref: 'learn:${v.id}',
          name: v.title,
          ageLabel: _monthsLabel(v.ageFromMonths, v.ageToMonths),
          isClass: true,
        ),
      );
    }
  } catch (_) {
    /* no class */
  }

  try {
    final toys =
        [
          for (final p in PvCatalogStore.instance.forStage(LifeStage.parenting))
            if (p.categoryId == kSheetToyCategoryId &&
                !p.comingSoon &&
                ppToyHasAgeWindow(p) &&
                p.suitsAge(months))
              p,
        ]..sort((a, b) {
          final byStart = b.ageMinMonths.compareTo(a.ageMinMonths);
          return byStart != 0
              ? byStart
              : (b.score ?? 0).compareTo(a.score ?? 0);
        });
    for (final p in toys) {
      final label = p.specs.where((s) => s.$1 == 'Age').firstOrNull?.$2 ?? '';
      out.add(
        PpOffer(
          ref: 'product:${p.id}',
          name: p.name,
          ageLabel: label.isNotEmpty
              ? label.toLowerCase()
              : _monthsLabel(p.ageMinMonths, p.ageMaxMonths),
        ),
      );
    }
  } catch (_) {
    /* no toy */
  }

  return out;
}
