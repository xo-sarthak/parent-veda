// =============================================================================
//  PvCatalogStore — the one catalogue every product surface reads
// -----------------------------------------------------------------------------
//  Singleton `ChangeNotifier`, like every store here. Built once from the
//  three source catalogues through `buildPvCatalog()`; when the unified
//  `products` table (migration 0083) is deployed, `applyRows` replaces the
//  seed with server rows and every screen repaints — the same shape as
//  `ContentStore`, kept separate because this catalogue spans three source
//  domains and the parenting `ProductCatalogStore` still exists underneath
//  (it feeds `pp.productCatalog`, which the adapter reads).
//
//  ⚠️ STAGE NARROWS WHAT LEADS, NEVER WHAT EXISTS. `forStage` is the shelf's
//  default; `search` and `byId` always see everything. The user's rule for
//  the storefront: a pregnant mother opens Products and sees pregnancy first,
//  "but she can be easily navigating to trying-to-conceive or parenting".
//
//  "For you right now" is the only personalised rail and it changes ORDER and
//  CONTENT only (docs/PERSONALIZATION.md) — pregnancy week from
//  `PregnancyController.current`, child age from `ChildProfileStore`.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../data/products/pv_catalog_adapters.dart';
import '../models/pv_product.dart';
import '../screens/post_pregnancy/pp_child_profile.dart';
import 'life_stage_store.dart';
import 'pregnancy_controller.dart';

class PvSearchResult {
  const PvSearchResult(this.all, this.byStage);
  final List<PvProduct> all;
  final Map<LifeStage, List<PvProduct>> byStage;
  int count(LifeStage s) => byStage[s]?.length ?? 0;
}

class PvCatalogStore extends ChangeNotifier {
  PvCatalogStore._();
  static final PvCatalogStore instance = PvCatalogStore._();

  List<PvProduct>? _all;
  List<PvCategory>? _categories;

  List<PvProduct> get all => _all ??= buildPvCatalog();
  List<PvCategory> get categories => _categories ??= buildPvCategories();

  /// Server rows replace the seed wholesale. Not wired to a table yet — the
  /// migration exists; the push is the user's. Kept so the seam is real.
  void applyRows(List<PvProduct> rows) {
    if (rows.isEmpty) return;
    _all = rows;
    notifyListeners();
  }

  // ---- lookups ---------------------------------------------------------------

  PvProduct? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  PvCategory? category(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<PvCategory> categoriesFor(LifeStage stage) =>
      [for (final c in categories) if (c.stage == stage.shopStage) c];

  List<PvProduct> forStage(LifeStage stage) =>
      [for (final p in all) if (p.stage == stage.shopStage) p];

  List<PvProduct> inCategory(String categoryId, {String? subId}) => [
        for (final p in all)
          if (p.categoryId == categoryId && (subId == null || p.subId == subId)) p
      ];

  /// The ParentVeda-recommends rail: only the top two bands, strongest first.
  List<PvProduct> recommended(LifeStage stage, {int limit = 8}) {
    final list = [for (final p in forStage(stage)) if (p.recommends) p]
      ..sort((a, b) => a.reco!.band.rank.compareTo(b.reco!.band.rank));
    return list.take(limit).toList();
  }

  /// Bestsellers / most reviewed — the "what other parents buy" rail.
  List<PvProduct> popular(LifeStage stage, {int limit = 8}) {
    final list = forStage(stage).where((p) => !p.reviewOnly).toList()
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return list.take(limit).toList();
  }

  /// "For you right now" — the stage's own clock decides. Pregnancy: the
  /// week; parenting: the child's age in months; TTC: everyone trying
  /// (nothing about her cycle reaches a shelf, by design).
  List<PvProduct> forYou(LifeStage stage, {int limit = 6}) {
    final s = stage.shopStage;
    Iterable<PvProduct> list = forStage(s).where((p) => !p.reviewOnly);
    switch (s) {
      case LifeStage.pregnancy:
        final week = PregnancyController.current?.currentWeek;
        if (week != null) {
          list = list.where((p) => p.suitsWeek(week));
        }
      case LifeStage.parenting:
        final months = ChildProfileStore.instance.ageInMonths;
        list = list.where((p) => p.suitsAge(months));
      case LifeStage.tryingToConceive:
        list = list.where((p) => !p.forPartner);
      case LifeStage.skilling:
        break;
    }
    final out = list.toList()
      ..sort((a, b) {
        final ra = a.reco?.band.rank ?? 9;
        final rb = b.reco?.band.rank ?? 9;
        if (ra != rb) return ra.compareTo(rb);
        return b.reviewCount.compareTo(a.reviewCount);
      });
    // One per category, so the rail reads as a shortlist, not a shelf.
    final seen = <String>{};
    return [for (final p in out) if (seen.add(p.categoryId)) p].take(limit).toList();
  }

  /// A word the week/age rail can put in its header ("Week 28", "4 months").
  String clockLabel(LifeStage stage) {
    switch (stage.shopStage) {
      case LifeStage.pregnancy:
        final w = PregnancyController.current?.currentWeek;
        return w == null ? '' : 'Week $w';
      case LifeStage.parenting:
        // No saved child = no age to name ("0 weeks" on a fresh phone is a
        // claim about a baby that is not there).
        final c = ChildProfileStore.instance;
        return c.hasRealChild ? c.ageLabel : '';
      default:
        return '';
    }
  }

  /// "You might also like": the editor's related ids first, then the same
  /// stage's recommended products from OTHER categories. Same-category
  /// neighbours belong to "Compare with similar" — found on the phone with
  /// the same thermometer in both rails.
  List<PvProduct> related(PvProduct p, {int limit = 6}) {
    final out = <PvProduct>[
      for (final id in p.relatedIds)
        if (byId(id) != null && id != p.id) byId(id)!,
    ];
    final others = forStage(p.stage).where((o) => o.categoryId != p.categoryId && !o.reviewOnly).toList()
      ..sort((a, b) {
        final ra = a.reco?.band.rank ?? 9;
        final rb = b.reco?.band.rank ?? 9;
        if (ra != rb) return ra.compareTo(rb);
        return b.reviewCount.compareTo(a.reviewCount);
      });
    final seenCats = <String>{};
    for (final o in others) {
      if (out.length >= limit) break;
      if (out.any((e) => e.id == o.id)) continue;
      if (!seenCats.add(o.categoryId)) continue; // one per category
      out.add(o);
    }
    return out.take(limit).toList();
  }

  List<String> brands(LifeStage stage) =>
      forStage(stage).map((p) => p.brand).where((b) => b.isNotEmpty).toSet().toList()..sort();

  /// Cross-stage search with per-stage counts — H&M's `ALL [507] · WOMEN
  /// [271] · BABY [21]` chips. Name, brand, category, sub, best-for.
  PvSearchResult search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const PvSearchResult([], {});
    final terms = q.split(RegExp(r'\s+'));
    bool hit(PvProduct p) {
      final cat = category(p.categoryId);
      final hay = [
        p.name,
        p.brand,
        cat?.name ?? '',
        p.subId ?? '',
        ...p.bestFor,
        p.summary,
      ].join(' ').toLowerCase();
      return terms.every(hay.contains);
    }

    final hits = [for (final p in all) if (hit(p)) p];
    final by = <LifeStage, List<PvProduct>>{};
    for (final p in hits) {
      (by[p.stage] ??= []).add(p);
    }
    return PvSearchResult(hits, by);
  }
}
