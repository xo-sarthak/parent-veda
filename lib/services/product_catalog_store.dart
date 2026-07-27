// =============================================================================
//  ProductCatalogStore — the parenting product catalogue, served from Supabase.
// -----------------------------------------------------------------------------
//  NAMED CAREFULLY. `ProductStore` already exists and is something else
//  entirely: a user's SAVED products, cloud-synced per person. This is the
//  catalogue every user sees. The pairing matches the other flipped types —
//  FoodStore/RecipeStore, ReadingStore/ReadStore — where the user's list and
//  the content it points at are separate stores by design, because one is
//  private and one is published.
//
//  The type with the strongest reason to leave the app binary: prices,
//  retailers and availability go stale on their own, without anyone editing
//  anything. Every other content type decays slowly; this one decays on a
//  schedule somebody else sets.
//
//  What moved and what did not:
//    this store       -> the 23 products. Editorial.
//    kPpCategories,   -> categories, concerns and stages. Stay in Dart: they
//    kPpConcerns,        carry icons and drive the filter rows, so a new one is
//    kPpStages           a new piece of UI, not a new product on a shelf.
//    PpCompareStore   -> what is being compared right now. Session state.
//    ProductStore     -> the user's saved list. User data.
//
//  NOTE the three-valued compare specs (autoOff, volumeLock). Null means "not
//  checked"; false means "does not have it". Different claims to make about a
//  product a parent is choosing between, so null is preserved, not coerced.
// =============================================================================

import '../screens/post_pregnancy/pp_products_data.dart';
import 'content_store.dart';
import 'remote/content_repo.dart';

class ProductCatalogStore extends ContentStore<PpProduct> {
  ProductCatalogStore._()
      : super(
          table: 'products',
          cacheKey: 'content_products_v1',
          seed: kPpProducts,
          domain: 'parenting',
        );

  static final ProductCatalogStore instance = ProductCatalogStore._();

  @override
  List<ContentOrder> get order => const [ContentOrder('sort')];

  static String _text(Object? v) => (v as String?) ?? '';

  static List<String> _strings(Object? v) => (v as List?)
          ?.map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(growable: false) ??
      const [];

  static Map<String, String> _stringMap(Object? v) => (v as Map?)?.map(
        (k, val) => MapEntry(k.toString(), val?.toString() ?? ''),
      ) ??
      const {};

  @override
  PpProduct fromMap(Map<String, dynamic> row) => PpProduct(
        id: (row['source_key'] as String?) ?? _text(row['id']),
        name: _text(row['name']),
        brand: _text(row['brand']),
        category: _text(row['category']),
        sub: _text(row['sub']),
        // numeric(2,1) arrives as a num or a string depending on how the
        // driver renders decimals — parse defensively rather than cast, or a
        // rating silently becomes 0 and the product sorts last everywhere.
        rating: switch (row['rating']) {
          final num n => n.toDouble(),
          final String s => double.tryParse(s) ?? 0,
          _ => 0,
        },
        reviews: (row['reviews'] as num?)?.toInt() ?? 0,
        price: (row['price_inr'] as num?)?.toInt() ?? 0,
        retailer: _text(row['retailer']),
        verified: row['verified'] as bool? ?? false,
        parentVeda: row['parent_veda'] as bool? ?? false,
        bestseller: row['bestseller'] as bool? ?? false,
        badge: _text(row['badge']),
        bestFor: _text(row['best_for']),
        summary: _text(row['summary']),
        pros: _strings(row['pros']),
        cons: _strings(row['cons']),
        specs: _stringMap(row['specs']),
        sound: row['spec_sound'] as String?,
        autoOff: row['spec_auto_off'] as bool?,
        volumeLock: row['spec_volume_lock'] as bool?,
        power: row['spec_power'] as String?,
      );

  @override
  Map<String, dynamic> toCacheMap(PpProduct p) => <String, dynamic>{
        'source_key': p.id,
        'name': p.name,
        'brand': p.brand,
        'category': p.category,
        'sub': p.sub,
        'price_inr': p.price,
        'retailer': p.retailer,
        'rating': p.rating,
        'reviews': p.reviews,
        'verified': p.verified,
        'parent_veda': p.parentVeda,
        'bestseller': p.bestseller,
        'badge': p.badge,
        'best_for': p.bestFor,
        'summary': p.summary,
        'pros': p.pros,
        'cons': p.cons,
        'specs': p.specs,
        'spec_sound': p.sound,
        'spec_auto_off': p.autoOff,
        'spec_volume_lock': p.volumeLock,
        'spec_power': p.power,
      };
}
