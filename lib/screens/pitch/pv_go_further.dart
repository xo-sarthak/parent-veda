// =============================================================================
//  pv_go_further.dart - "What you need" and "Go further", one shared pitch
// -----------------------------------------------------------------------------
//  Built 2026-10-23 (global pass phase 2, prototype RAJsHJcLXYpJ6DrXyjfR9S,
//  approved). The user: "whenever we have these physical situations going
//  around, we can start pitching our services... for prenatal yoga, a yoga
//  mat, a yoga consultation, a yoga class", and "in the nutrition door, if
//  you're not pitching the supplements, the dietitian, then what are we
//  doing?"
//
//  ⚠️ BELOW THE ACTION, NEVER ABOVE IT. The session or the plate is the page;
//  this sits under it (Withings, lululemon, Peloton on Mobbin all do).
//
//  ⚠️ ANYTHING THAT GOES TO THE STORE SAYS SO. A bag mark and "Store" on the
//  chip, "IN THE STORE" on the card. A need with nothing in the catalogue
//  for her week is plain grey text that does not tap - never a tap that lands
//  on an empty shelf. The product slots fill by themselves when the product
//  master sheet adds mats and supplements.
//
//  ⚠️ HER WEEK DECIDES. Products are matched against the catalogue with
//  `PvCatalogStore.fitsNow` (her real week; nothing on the week-20
//  placeholder), and the row says so in one quiet line.
//
//  ⚠️ RIGHTS, NOT A SHOP: experts and courses come from `PvLearnCatalog`, the
//  one catalogue Learn uses, so a price is never typed twice.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/learn/pv_learn_view.dart';
import '../../models/pv_product.dart';
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/pv_catalog_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../doors/pv_door_chrome.dart';
import '../learn/pv_learn_catalog.dart';
import '../learn/pv_offering_screen.dart';
import '../products/pv_store_chrome.dart' show pvOpenProduct;
import '../v2/v2_palette.dart';

/// Something a page needs that the store may sell: a yoga mat, a bolster.
class PvNeed {
  const PvNeed(this.label, {this.words = const [], this.categories = const []});

  /// What the chip says.
  final String label;

  /// Lower-case words matched against product names ("yoga mat").
  final List<String> words;

  /// Catalogue category ids that answer it outright ("pregnancy_pillow").
  final List<String> categories;
}

/// The products in the store that answer [need] for her now, best first.
/// Empty when the catalogue has nothing - the chip is then plain text.
List<PvProduct> pvProductsFor(PvNeed need, {LifeStage stage = LifeStage.pregnancy}) {
  if (need.words.isEmpty && need.categories.isEmpty) return const [];
  final store = PvCatalogStore.instance;
  final out = [
    for (final p in store.forStage(stage))
      if (!p.reviewOnly &&
          store.fitsNow(p) != false &&
          (need.categories.contains(p.categoryId) ||
              need.words.any((w) => p.name.toLowerCase().contains(w))))
        p,
  ]..sort((a, b) {
      final ra = a.reco?.band.rank ?? 9;
      final rb = b.reco?.band.rank ?? 9;
      if (ra != rb) return ra.compareTo(rb);
      return b.reviewCount.compareTo(a.reviewCount);
    });
  return out;
}

/// The offering in Learn whose title or subtitle carries one of [words]
/// ("physiotherapist", "nutritionist"), or null.
PvOfferingView? pvOfferingFor(List<String> words,
    {LifeStage stage = LifeStage.pregnancy, PvLearnKind? kind}) {
  try {
    for (final v in PvLearnCatalog.instance.all(stage: stage)) {
      if (kind != null && v.kind != kind) continue;
      final hay = '${v.title} ${v.subtitle}'.toLowerCase();
      if (words.any(hay.contains)) return v;
    }
  } catch (_) {
    // local-first: a catalogue that is not ready is no card
  }
  return null;
}

// -----------------------------------------------------------------------------
//  "What you need": chips
// -----------------------------------------------------------------------------

class PvWhatYouNeed extends StatelessWidget {
  const PvWhatYouNeed({super.key, required this.needs, required this.p});
  final List<PvNeed> needs;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final n in needs) _chip(context, n),
        ]),
      );

  Widget _chip(BuildContext context, PvNeed n) {
    final hits = pvProductsFor(n);
    if (hits.isEmpty) {
      // Nothing to buy (water), or nothing in the store yet: plain text.
      return Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: const Color(0xFFF4F4F5), borderRadius: BorderRadius.circular(999)),
        // Center(widthFactor: 1), not `alignment`: an aligned Container in a
        // Wrap grows to the full width and the grey pill would span the row.
        child: Center(
          widthFactor: 1,
          child: Text(n.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
        ),
      );
    }
    return Material(
      color: Colors.white,
      shape: StadiumBorder(side: BorderSide(color: p.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('pv_need_${n.label}'),
        onTap: () {
          pvCommitFeedback();
          pvOpenProduct(context, hits.first);
        },
        child: Container(
          height: 38,
          padding: const EdgeInsets.fromLTRB(6, 0, 10, 0),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: Color(0xFFF4F4F5), shape: BoxShape.circle),
              child: Icon(Icons.shopping_bag_outlined, size: 14, color: p.ink1),
            ),
            const SizedBox(width: 8),
            // Flexible: a long label at a large text size shrinks with an
            // ellipsis instead of running off a 360pt screen.
            Flexible(
              child: Text(n.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
            ),
            const SizedBox(width: 8),
            Text('Store', style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink3)),
            Icon(Icons.chevron_right_rounded, size: 16, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  "Go further": up to three cards, one of each kind
// -----------------------------------------------------------------------------

/// One card on the row.
class PvFurtherItem {
  const PvFurtherItem.product(PvProduct this.product) : offering = null;
  const PvFurtherItem.offering(PvOfferingView this.offering) : product = null;
  final PvProduct? product;
  final PvOfferingView? offering;
}

/// The row's items: the best product for [needs], then each offering found
/// for the [offerings] word lists, in order. At most three, never padded.
List<PvFurtherItem> pvFurtherItems({
  List<PvNeed> needs = const [],
  List<List<String>> offerings = const [],
}) {
  final out = <PvFurtherItem>[];
  for (final n in needs) {
    final hits = pvProductsFor(n);
    if (hits.isNotEmpty) {
      out.add(PvFurtherItem.product(hits.first));
      break;
    }
  }
  final seen = <String>{};
  for (final words in offerings) {
    final v = pvOfferingFor(words);
    if (v != null && seen.add(v.id)) out.add(PvFurtherItem.offering(v));
  }
  return out.take(3).toList();
}

/// A rail of `PvDoorRailCard`s, the door's own card, so it is the same height
/// as every other rail (the door symmetry test counts one horizontal ListView
/// per section).
class PvGoFurtherRail extends StatelessWidget {
  const PvGoFurtherRail({super.key, required this.items, required this.p, this.week});
  final List<PvFurtherItem> items;
  final V2Palette p;

  /// Her real week, for the one line under the row. Null: no line.
  final int? week;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: kPvRailCardHeight,
        child: ListView.separated(
          key: const ValueKey('pv_go_further_rail'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: kPvRailGap),
          itemBuilder: (context, i) => _card(context, items[i], i),
        ),
      ),
      if (week != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Text('Picked for week $week.', style: pvManrope(fontSize: 12, color: p.ink3)),
        ),
    ]);
  }

  Widget _card(BuildContext context, PvFurtherItem it, int i) {
    if (it.product case final pr?) {
      return PvDoorRailCard(
        p: p,
        hue: 30,
        index: i,
        icon: Icons.shopping_bag_outlined,
        chip: 'In the store',
        title: pr.name,
        meta: pr.hasPrice ? '${pr.priceLabel} · Shop' : 'Shop',
        imageUrl: pr.images.isEmpty ? null : pr.images.first,
        onTap: () {
          pvCommitFeedback();
          pvOpenProduct(context, pr);
        },
      );
    }
    final v = it.offering!;
    final (chip, icon, verb) = switch (v.kind) {
      PvLearnKind.consult => ('Expert', Icons.chat_bubble_outline_rounded, 'Book a call'),
      PvLearnKind.course => ('Course', Icons.menu_book_outlined, 'View'),
      PvLearnKind.masterclass => ('Live class', Icons.event_outlined, 'See times'),
      PvLearnKind.cohort => ('Group', Icons.groups_outlined, 'See times'),
      _ => ('Class', Icons.self_improvement_rounded, 'See times'),
    };
    return PvDoorRailCard(
      p: p,
      hue: v.hue,
      index: i,
      icon: icon,
      chip: chip,
      title: v.kind == PvLearnKind.consult ? v.title.replaceFirst('Consult with ', '') : v.title,
      meta: v.isFree ? verb : '${v.priceLabel} · $verb',
      imageUrl: v.cover,
      onTap: () {
        pvCommitFeedback();
        pvOpenOffering(context, v);
      },
    );
  }
}

// -----------------------------------------------------------------------------
//  The Nutrition door's "For your week" row
// -----------------------------------------------------------------------------

/// What her week's food asks for from the store: a supplement. The catalogue
/// carries none yet; the card appears by itself when the product master sheet
/// adds one (by name or by a supplements category).
const PvNeed kNutritionSupplementNeed = PvNeed(
  'Supplements',
  words: ['iron', 'folic', 'prenatal vitamin', 'calcium', 'supplement'],
  categories: ['supplements', 'pvs_supplements', 'prenatal_vitamins'],
);

/// A supplement for her week (when the store has one), the dietitian and a
/// course, then the doctor line whenever a supplement is offered.
class PvNutritionForWeek extends StatelessWidget {
  const PvNutritionForWeek({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final items = pvFurtherItems(
      needs: const [kNutritionSupplementNeed],
      offerings: const [
        ['nutritionist', 'dietitian'],
        ['complete pregnancy guide'],
      ],
    );
    if (items.isEmpty) return const SizedBox(height: kPvRailCardHeight);
    final pills = items.any((i) => i.product != null);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PvGoFurtherRail(
        items: items,
        p: p,
        week: pregnancy.isDueDateSet ? pregnancy.currentWeek : null,
      ),
      // ⚠️ NEVER A DOSE FROM US (CLAUDE.md: never a diagnosis; the app never
      // contradicts her clinician). Shown whenever a supplement is on the row.
      if (pills)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text(
            'Supplements are a question for your doctor. ParentVeda explains '
            'and reminds; your doctor decides the dose.',
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2),
          ),
        ),
    ]);
  }
}
