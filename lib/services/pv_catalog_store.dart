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

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/products/pv_affiliate.dart' show pvGuardRetailerPrice;
import '../data/products/pv_catalog_adapters.dart';
import '../data/products/pv_product_rows.dart';
import 'remote/supabase_repo.dart';
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
    // Server rows pass the same Amazon / Flipkart price guard as the seed.
    // Kept for revert: _all = rows;
    _all = [for (final r in rows) pvGuardRetailerPrice(r)];
    notifyListeners();
  }

  // ---- the product sheet, from the cloud (store Track A, 2026-10-28) ------
  //
  // PLUG AND PLAY: the sheet importer writes `products` rows with
  // domain = 'store' (0120); they are laid over the built-in catalogue here,
  // so a new product or a changed link needs no app release.
  //
  // Local-first: the last rows read are kept on the phone and applied
  // before any network, so the shelf is the same offline. A failed read
  // keeps the cache; only an answer from the server replaces it.

  static const _rowsCacheKey = 'pv_store_sheet_rows';
  Future<void>? _loading;

  Future<void> loadFromCloud() => _loading ??= _loadFromCloud();

  Future<void> _loadFromCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_rowsCacheKey);
      if (cached != null) {
        applyStoreRows(
          List<Map<String, dynamic>>.from(
            (jsonDecode(cached) as List).map(
              (e) => Map<String, dynamic>.from(e as Map),
            ),
          ),
        );
      }
      final fresh = await SupabaseRepo.selectPublicWhere(
        'products',
        'domain',
        'store',
      );
      if (fresh == null) return; // no answer: the cache stands
      await prefs.setString(_rowsCacheKey, jsonEncode(fresh));
      applyStoreRows(fresh);
    } catch (e) {
      debugPrint('[catalog] sheet rows not loaded: $e');
    }
  }

  /// Lays the sheet's [rows] over the built-in catalogue. Unreadable rows
  /// are skipped (pvProductFromStoreRow); everything passes the price guard.
  void applyStoreRows(List<Map<String, dynamic>> rows) {
    final cats = {for (final c in categories) c.id};
    final read = [
      for (final r in rows) ?pvProductFromStoreRow(r, categoryIds: cats),
    ];
    _all = [
      for (final p in pvMergeStoreRows(buildPvCatalog(), read))
        pvGuardRetailerPrice(p),
    ];
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

  List<PvProduct> inCategory(String categoryId, {String? subId}) => _hersFirst([
        for (final p in all)
          if (p.categoryId == categoryId && (subId == null || p.subId == subId)) p
      ]);

  /// Does [p] fit where she is NOW: her real pregnancy week, or her child's
  /// real age? Null when there is no clock to read (no due date yet, no child
  /// saved, TTC, Skilling) - then nothing is reordered (2026-10-23).
  ///
  /// ⚠️ THE WEEK-20 PLACEHOLDER IS NOT A WEEK. `forYou` used to filter on
  /// `currentWeek` even with no due date, so a woman who had not given one
  /// was shown week-20 products as hers.
  bool? fitsNow(PvProduct p) {
    switch (p.stage) {
      case LifeStage.pregnancy:
        final c = PregnancyController.current;
        if (c == null || !c.isDueDateSet) return null;
        return p.suitsWeek(c.currentWeek);
      case LifeStage.parenting:
        final kids = ChildProfileStore.instance;
        if (!kids.hasRealChild) return null;
        return p.suitsAge(kids.ageInMonths);
      default:
        return null;
    }
  }

  int? _realPregWeek() {
    final c = PregnancyController.current;
    return c == null || !c.isDueDateSet ? null : c.currentWeek;
  }

  /// Stable: what fits her week or her child's age first, the rest after in
  /// their own order. Ranking, never a filter - every product stays on the
  /// shelf (the user, 2026-10-23: "a week-20 mother should see week-20
  /// products... or we are losing money").
  List<PvProduct> _hersFirst(List<PvProduct> list) {
    final fits = [for (final p in list) if (fitsNow(p) == true) p];
    if (fits.isEmpty || fits.length == list.length) return list;
    return [...fits, for (final p in list) if (fitsNow(p) != true) p];
  }

  /// The ParentVeda-recommends rail: only the top two bands, strongest first.
  List<PvProduct> recommended(LifeStage stage, {int limit = 8}) {
    final list = [for (final p in forStage(stage)) if (p.recommends) p]
      ..sort((a, b) => a.reco!.band.rank.compareTo(b.reco!.band.rank));
    // Hers first (2026-10-23); kept for revert: `list.take(limit)`.
    return _hersFirst(list).take(limit).toList();
  }

  /// Bestsellers / most reviewed — the "what other parents buy" rail.
  List<PvProduct> popular(LifeStage stage, {int limit = 8}) {
    final list = forStage(stage).where((p) => !p.reviewOnly).toList()
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    // Hers first (2026-10-23); kept for revert: `list.take(limit)`.
    return _hersFirst(list).take(limit).toList();
  }

  /// "For you right now" — the stage's own clock decides. Pregnancy: the
  /// week; parenting: the child's age in months; TTC: everyone trying
  /// (nothing about her cycle reaches a shelf, by design).
  List<PvProduct> forYou(LifeStage stage, {int limit = 6}) {
    final s = stage.shopStage;
    Iterable<PvProduct> list = forStage(s).where((p) => !p.reviewOnly);
    switch (s) {
      case LifeStage.pregnancy:
        // Only a REAL week filters (2026-10-23). Kept for revert:
        //   final week = PregnancyController.current?.currentWeek;
        //   if (week != null) list = list.where((p) => p.suitsWeek(week));
        list = list.where((p) => fitsNow(p) != false);
      case LifeStage.parenting:
        // Only a real child's age filters (2026-10-23). Kept for revert:
        //   list = list.where((p) => p.suitsAge(ChildProfileStore.instance.ageInMonths));
        list = list.where((p) => fitsNow(p) != false);
      case LifeStage.tryingToConceive:
        list = list.where((p) => !p.forPartner);
      case LifeStage.skilling:
        break;
    }
    // ⚠️ IN LATE PREGNANCY EVERYTHING "FITS" (relevance Batch 4, PREG 14,
    // 2026-10-28). Sheet picks carry one week, the week to have it by, and
    // `suitsWeek` reads that as "from two weeks before, for ever", so at week
    // 36 the whole catalogue fits and the rail fell back to ratings: a pillow
    // for week 20 beside the hospital bag. Now a closeness tier comes first:
    // due about now, then what is useful any week, then what she could have
    // had earlier. We rank instead of inventing an end week for each pick:
    // the sheet gives one week, and an end week we made up would be a claim we
    // cannot stand behind.
    final week = s == LifeStage.pregnancy ? _realPregWeek() : null;
    final out = list.toList()
      ..sort((a, b) {
        if (week != null) {
          final ta = pvWeekTier(a, week), tb = pvWeekTier(b, week);
          if (ta != tb) return ta.compareTo(tb);
        }
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
        // No real due date = no week to name: the week-20 stand-in is not
        // her week (2026-10-27, PREG fault 2). Kept for revert:
        //   final w = PregnancyController.current?.currentWeek;
        final c = PregnancyController.current;
        final w = (c == null || !c.isDueDateSet) ? null : c.currentWeek;
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

/// How close [p] is to pregnancy week [week], for ranking (relevance Batch 4,
/// PREG 14): 0 when its "have it by" week is within [kPvDueSoonWeeks] either
/// side, 1 when it names no week (useful at any), 2 when that week is further
/// off. A pure function so the rule is tested without a store.
const int kPvDueSoonWeeks = 4;

int pvWeekTier(PvProduct p, int week) {
  final from = p.weekFrom;
  if (from == null) return 1;
  return (from - week).abs() <= kPvDueSoonWeeks ? 0 : 2;
}
