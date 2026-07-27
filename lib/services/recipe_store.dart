// =============================================================================
//  RecipeStore — the Food companion's dish catalogue, served from Supabase.
// -----------------------------------------------------------------------------
//  The second content type to flip (after articles), and the first one where
//  the split between CONTENT and ENGINE had to be drawn explicitly:
//
//    this store        -> the 28 dishes. Editorial. An editor may add, edit,
//                         unpublish, translate.
//    pp_food_data.dart -> browseRecipes / planForDay / buildMeals / todaysMeals.
//                         Which dish is offered for Tuesday lunch is product
//                         behaviour, and behaviour does not move to Directus.
//    FoodStore         -> saved dishes + shopping list. User data. Untouched.
//
//  Everything local-first lives in the base class (lib/services/content_store.dart);
//  what is left here is the table, the ordering, and the row mapping.
//
//  NOTE ON THE MAPPER: a Supabase row and a cached row must decode identically,
//  which is why toCacheMap writes the DB's own column names and shapes. jsonb
//  arrays and text[] both arrive as List<dynamic> either way, so one set of
//  coercions serves both paths.
// =============================================================================

import '../screens/post_pregnancy/pp_food_data.dart';
import 'content_store.dart';
import 'remote/content_repo.dart';

class RecipeStore extends ContentStore<FoodRecipe> {
  RecipeStore._()
      : super(
          table: 'recipes',
          cacheKey: 'content_recipes_v1',
          seed: kFoodRecipes,
          domain: 'parenting',
        );

  static final RecipeStore instance = RecipeStore._();

  @override
  List<ContentOrder> get order => const [ContentOrder('sort')];

  // ---- coercions ------------------------------------------------------------
  // Deliberately forgiving: a content backend must never crash the app, and a
  // half-filled row from an editor mid-edit is a normal thing to receive.

  static List<String> _strings(Object? v) => (v as List?)
          ?.map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(growable: false) ??
      const [];

  static Set<String> _stringSet(Object? v) => _strings(v).toSet();

  static Map<String, String> _stringMap(Object? v) => (v as Map?)?.map(
        (k, val) => MapEntry(k.toString(), val?.toString() ?? ''),
      ) ??
      const {};

  static int _int(Object? v, int fallback) =>
      (v as num?)?.toInt() ?? fallback;

  static String _text(Object? v) => (v as String?) ?? '';

  @override
  FoodRecipe fromMap(Map<String, dynamic> row) => FoodRecipe(
        // source_key is the identity the rest of the app already uses
        // ('ragipancake'). The uuid primary key is Directus's business, not the
        // app's — every cross-reference in the Dart points at the source key.
        id: (row['source_key'] as String?) ?? _text(row['id']),
        title: _text(row['title']),
        subtitle: _text(row['subtitle']),
        category: _text(row['category']),
        slot: _text(row['slot']),
        ageTag: _text(row['age_tag']),
        veg: row['veg'] as bool? ?? true,
        vegan: row['vegan'] as bool? ?? false,
        immunity: row['immunity'] as bool? ?? false,
        comfortOnly: row['comfort_only'] as bool? ?? false,
        prepMin: _int(row['prep_min'], 0),
        cookMin: _int(row['cook_min'], 0),
        serves: _int(row['serves'], 2),
        difficulty: _text(row['difficulty']),
        frequency: _text(row['frequency']),
        highlight: _text(row['highlight']),
        why: _text(row['why']),
        healthierNote: _text(row['healthier_note']),
        ingredients: _strings(row['ingredients']),
        equipment: _strings(row['equipment']),
        steps: _strings(row['steps']),
        storage: _strings(row['storage']),
        mistakes: _strings(row['mistakes']),
        substitutions: _stringMap(row['substitutions']),
        nutrients: ((row['nutrients'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .map((m) => FoodNutrient(
                  _text(m['name']),
                  _text(m['amount']),
                  _text(m['note']),
                ))
            .toList(growable: false),
        tags: _stringSet(row['tags']),
        situations: _stringSet(row['situations']),
        ingredientKeys: _stringSet(row['ingredient_keys']),
        relatedArticle: row['related_article'] as String?,
        relatedVideoId: row['related_video_id'] as String?,
        relatedProductId: row['related_product_id'] as String?,
        relatedCommunity: row['related_community'] as String?,
        seed: _int(row['shuffle_seed'], 0),
      );

  @override
  Map<String, dynamic> toCacheMap(FoodRecipe r) => <String, dynamic>{
        'source_key': r.id,
        'title': r.title,
        'subtitle': r.subtitle,
        'category': r.category,
        'slot': r.slot,
        'age_tag': r.ageTag,
        'veg': r.veg,
        'vegan': r.vegan,
        'immunity': r.immunity,
        'comfort_only': r.comfortOnly,
        'prep_min': r.prepMin,
        'cook_min': r.cookMin,
        'serves': r.serves,
        'difficulty': r.difficulty,
        'frequency': r.frequency,
        'highlight': r.highlight,
        'why': r.why,
        'healthier_note': r.healthierNote,
        'ingredients': r.ingredients,
        'equipment': r.equipment,
        'steps': r.steps,
        'storage': r.storage,
        'mistakes': r.mistakes,
        'substitutions': r.substitutions,
        'nutrients': r.nutrients
            .map((n) => {'name': n.name, 'amount': n.amount, 'note': n.note})
            .toList(growable: false),
        'tags': r.tags.toList(growable: false),
        'situations': r.situations.toList(growable: false),
        'ingredient_keys': r.ingredientKeys.toList(growable: false),
        'related_article': r.relatedArticle,
        'related_video_id': r.relatedVideoId,
        'related_product_id': r.relatedProductId,
        'related_community': r.relatedCommunity,
        'shuffle_seed': r.seed,
      };
}
