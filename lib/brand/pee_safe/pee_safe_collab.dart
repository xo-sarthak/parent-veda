// =============================================================================
//  ParentVeda × Pee Safe — the collab look for product placements (item 7)
// -----------------------------------------------------------------------------
//  DEMO ONLY (docs/PEE-SAFE-DEMO.md). The way fashion apps present a designer
//  collaboration: an "A × B" lockup, a small-caps eyebrow, the brand name in
//  small caps above each product, and a quiet disclosure label at the right.
//
//  The rules this file holds for every placement:
//    · the host's own item, list or checklist comes first and is unchanged —
//      this shelf only ever renders AFTER it
//    · each placement resolves on its own placementKey, through
//      BrandStudio.resolve(), so a campaign keyed for the hospital bag can
//      never surface on the travel kit
//    · shared surface, so ParentVeda ink. Lime appears only inside Pee Safe's
//      own logo image
//    · behind kPeeSafeDemo, and labelled ("Sponsored" on ranked inventory,
//      "Presented by Pee Safe" on presented-by surfaces)
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../brand_analytics.dart';
import '../brand_context.dart';
import '../brand_models.dart';
import '../brand_studio.dart';
import 'pee_safe_brand.dart';
import 'pee_safe_products.dart';

// Kept for revert: _ink 0xFF2D144C (a purple ink, 2026-11-03: the app's one ink).
const Color _ink = Color(0xFF2F2C30);
const Color _soft = Color(0xFF69636C);
const Color _line = Color(0xFFE4E2E5);

/// The four product placements. Each one is its own campaign on its own key.
enum PeeSafePlacement {
  featuredPick(
    campaignId: kPeeSafeFeaturedId,
    slot: BrandSlot.recoFeatured,
    key: kPeeSafeFeaturedKey,
    stage: BrandStage.parenting,
    moment: PeeSafeMoment.postpartum,
    label: 'Sponsored',
    title: 'For the weeks after birth',
  ),
  hospitalBag(
    campaignId: kPeeSafeBagId,
    slot: BrandSlot.sponsoredTool,
    key: kPeeSafeBagKey,
    stage: BrandStage.pregnancy,
    moment: PeeSafeMoment.hospitalBag,
    label: 'Presented by Pee Safe',
    title: 'For the hospital bag',
  ),
  afterBirthCollection(
    campaignId: kPeeSafeCollectionId,
    slot: BrandSlot.sponsoredCollection,
    key: kPeeSafeCollectionKey,
    stage: BrandStage.parenting,
    moment: PeeSafeMoment.postpartum,
    label: 'Presented by Pee Safe',
    title: 'For after birth',
  ),
  travel(
    campaignId: kPeeSafeTravelId,
    slot: BrandSlot.nativeDiscovery,
    key: kPeeSafeTravelKey,
    stage: BrandStage.parenting,
    moment: PeeSafeMoment.travel,
    label: 'Sponsored',
    title: 'For the road',
  );

  const PeeSafePlacement({
    required this.campaignId,
    required this.slot,
    required this.key,
    required this.stage,
    required this.moment,
    required this.label,
    required this.title,
  });

  final String campaignId;
  final BrandSlot slot;
  final String key;
  final BrandStage stage;
  final PeeSafeMoment moment;
  final String label;
  final String title;

  /// The live Pee Safe campaign for this placement, or null. Null is normal:
  /// demo off, Studio off, schedule over. Only a Pee Safe campaign counts, so
  /// another brand on the same key is never drawn as this collab.
  BrandCampaign? resolve() {
    if (!kPeeSafeDemo) return null;
    try {
      final c = BrandStudio.instance.resolve(slot, captureBrandContext(stage: stage), placementKey: key);
      if (c == null || c.brand.id != kPeeSafe.id) return null;
      return c;
    } catch (_) {
      return null;
    }
  }

  List<PeeSafeProduct> get products => peeSafeFor(moment);

  /// The placement keyed on a RecoItem, for the reco detail page.
  static PeeSafePlacement? forRecoItem(String itemId) {
    for (final p in [featuredPick, travel]) {
      if (p.key == itemId) return p;
    }
    return null;
  }
}

// =============================================================================
//  The lockup — "ParentVeda × Pee Safe"
// =============================================================================

/// The shared collab lockup. Our wordmark in ParentVeda ink, a hairline ×, and
/// Pee Safe's own logo in its own colour: the only lime on a shared surface.
class PeeSafeCollabLockup extends StatelessWidget {
  const PeeSafeCollabLockup({super.key, this.height = 18});

  /// Cap height of the lockup; the wordmark and logo scale from it.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ParentVeda × Pee Safe',
      excludeSemantics: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('ParentVeda',
            style: pvFraunces(fontSize: height, height: 1, fontWeight: FontWeight.w600, color: _ink)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: height * 0.45),
          child: Text('×', style: pvManrope(fontSize: height * 0.9, height: 1, fontWeight: FontWeight.w300, color: _soft)),
        ),
        Image.asset(
          kPeeSafe.logoAsset!,
          height: height * 1.25,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Text('Pee Safe',
              style: pvJakarta(fontSize: height * 0.9, height: 1, fontWeight: FontWeight.w800, color: _ink)),
        ),
      ]),
    );
  }
}

// =============================================================================
//  The shelf — products after the host's own content
// =============================================================================

/// Renders nothing unless [placement]'s own campaign resolves. Goes AFTER the
/// host's item or list, never above it.
class PeeSafeCollabShelf extends StatefulWidget {
  const PeeSafeCollabShelf({super.key, required this.placement, this.padding = EdgeInsets.zero});

  final PeeSafePlacement placement;
  final EdgeInsets padding;

  @override
  State<PeeSafeCollabShelf> createState() => _PeeSafeCollabShelfState();
}

class _PeeSafeCollabShelfState extends State<PeeSafeCollabShelf> {
  BrandCampaign? _campaign;

  @override
  void initState() {
    super.initState();
    _campaign = widget.placement.resolve();
    final c = _campaign;
    if (c != null) BrandAnalytics.instance.event(c, BrandEvent.impression);
  }

  @override
  Widget build(BuildContext context) {
    final c = _campaign;
    final products = widget.placement.products;
    if (c == null || products.isEmpty) return const SizedBox.shrink();
    final p = widget.placement;
    return Padding(
      padding: widget.padding,
      child: Container(
        key: ValueKey('ps_collab_${p.name}'),
        padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              const Flexible(child: PeeSafeCollabLockup(height: 15)),
              const SizedBox(width: 10),
              const Spacer(),
              _label(p.label),
            ]),
          ),
          const SizedBox(height: 14),
          Text('THE COLLAB EDIT',
              style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: _soft)),
          const SizedBox(height: 4),
          Text(p.title, style: pvFraunces(fontSize: 19, height: 1.15, fontWeight: FontWeight.w600, color: _ink)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text('Any brand will do. What sits above was chosen by ParentVeda, and does not change because of these.',
                style: pvManrope(fontSize: 12, height: 1.45, color: _soft)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 212,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _card(products[i], c),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: _line)),
        child: Text(text, style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, color: _soft)),
      );

  Widget _card(PeeSafeProduct prod, BrandCampaign c) => PvPress(
        child: GestureDetector(
          key: ValueKey('ps_collab_product_${widget.placement.name}_${prod.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            BrandAnalytics.instance.event(c, BrandEvent.opened, meta: {'product': prod.id});
            prod.open(campaign: c);
          },
          child: SizedBox(
            width: 128,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(prod.image,
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(width: 128, height: 128, color: _line)),
              ),
              const SizedBox(height: 8),
              Text('PEE SAFE',
                  style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: _soft)),
              const SizedBox(height: 2),
              Text(prod.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvJakarta(fontSize: 12.5, height: 1.25, fontWeight: FontWeight.w700, color: _ink)),
              const Spacer(),
              // Flexible (item 11): at a large system text size "View in
              // store" outgrew the 128-wide card and overflowed. Kept for
              // revert: the Text sat in the Row unwrapped.
              Row(children: [
                Flexible(
                  child: Text('View in store',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, color: _ink)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.open_in_new_rounded, size: 12, color: _ink),
              ]),
            ]),
          ),
        ),
      );
}
