// =============================================================================
//  SEED GENERATOR (not a test) — turn bundled Dart content into seed SQL.
// -----------------------------------------------------------------------------
//  Run:  flutter test tool/export_content_seed.dart
//  Out:  build/seed_recipes.sql   (and one file per type as more are flipped)
//
//  Why generate rather than hand-write: step 3 of the add-a-type recipe says the
//  seed must make day one look IDENTICAL to the bundled app. Transcribing 28
//  dishes × 30 fields by hand is how a dropped ingredient or a swapped step
//  gets into the database — a difference nobody reviews, because nobody
//  re-reads a 900-line INSERT. Generating it means the only thing that can
//  drift is this file, and test/recipes_seed_test.dart watches that.
//
//  Reads and products: every statement is `on conflict (source_key) do
//  nothing`, so running the output twice is a no-op and it can NEVER overwrite
//  an editor's edit. That property is what makes a flip reversible: seed,
//  ship, and if it goes wrong, flip ContentOwnership back without having lost
//  anything.
//
//  Recipes (since 2026-10-17): an exact MIRROR instead. `do update` plus an
//  archive pass, because a seed that can only add froze the table at the July
//  28 while the app moved on. Safe for the same reason in a different place:
//  the tool checks ContentOwnership and writes nothing once recipes are
//  editor-owned. Kept for revert: the do-nothing recipe insert is in git
//  history (2f55b63 and earlier).
//
//  It lives in tool/ and runs via `flutter test` for the same reason the corpus
//  exporters do — the data pulls in Flutter (IconData/Color), so `dart run`
//  cannot load it, and keeping it out of test/ means it never runs in the suite.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_products_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reading_data.dart';
import 'package:parentveda/services/content_ownership.dart';

// ---- SQL literal helpers ----------------------------------------------------

/// A quoted SQL string, or NULL. Single quotes are doubled — the standard
/// escape, and the only one that is safe regardless of what the prose contains.
/// Deliberately NOT dollar-quoting: content is authored by humans and a `$$`
/// inside a note would end the literal early and produce a syntax error at the
/// worst possible moment (halfway through a 900-line insert).
String _s(String? v) {
  if (v == null) return 'null';
  return "'${v.replaceAll("'", "''")}'";
}

String _b(bool v) => v ? 'true' : 'false';

/// A nullable boolean. The compare specs are three-valued on purpose — "this
/// product has no auto-off" and "we have not checked" are different claims to
/// make about something a parent is choosing between, so null must survive
/// rather than collapsing to false.
String _nb(bool? v) => v == null ? 'null' : _b(v);

/// A Postgres text[] built explicitly rather than via '{a,b}' syntax, which
/// needs its own escaping rules for commas, braces and quotes.
String _arr(Iterable<String> items) {
  if (items.isEmpty) return "'{}'::text[]";
  return 'array[${items.map(_s).join(', ')}]::text[]';
}

String _json(Object? value) => "${_s(jsonEncode(value))}::jsonb";

/// Split an age tag like '6–12 mo' / '1-3 yr' into filterable months.
/// Returns (min, max); either may be null when the tag does not say.
(int?, int?) _ageMonths(String tag) {
  final t = tag.toLowerCase().replaceAll('–', '-').replaceAll('+', '');
  final nums = RegExp(
    r'\d+',
  ).allMatches(t).map((m) => int.parse(m.group(0)!)).toList();
  if (nums.isEmpty) return (null, null);
  final isYears = t.contains('yr') || t.contains('year');
  final scale = isYears ? 12 : 1;
  final lo = nums.first * scale;
  final hi = nums.length > 1 ? nums[1] * scale : null;
  return (lo, hi);
}

/// One recipe as the row the table holds: column name -> SQL literal, in
/// insert order. The ONE place the recipes column list lives. The insert, the
/// `do update` set and test/recipes_export_contract_test.dart all read these
/// keys, so a column added by a migration but forgotten here fails a test
/// instead of staying empty in production (the 0096 columns did, until
/// 2026-10-17).
Map<String, String> recipeRow(FoodRecipe r, int sort) {
  final (ageMin, ageMax) = _ageMonths(r.ageTag);
  return <String, String>{
    'source_key': _s(r.id),
    'status': "'published'",
    'domain': "'parenting'",
    'title': _s(r.title),
    'subtitle': _s(r.subtitle),
    'category': _s(r.category),
    'slot': _s(r.slot),
    'age_tag': _s(r.ageTag),
    'age_min_months': '${ageMin ?? 'null'}',
    'age_max_months': '${ageMax ?? 'null'}',
    'veg': _b(r.veg),
    'vegan': _b(r.vegan),
    'immunity': _b(r.immunity),
    'comfort_only': _b(r.comfortOnly),
    'prep_min': '${r.prepMin}',
    'cook_min': '${r.cookMin}',
    'serves': '${r.serves}',
    'difficulty': _s(r.difficulty),
    'frequency': _s(r.frequency),
    'highlight': _s(r.highlight),
    'why': _s(r.why),
    'healthier_note': _s(r.healthierNote),
    'ingredients': _json(r.ingredients),
    'equipment': _json(r.equipment),
    'steps': _json(r.steps),
    'storage': _json(r.storage),
    'mistakes': _json(r.mistakes),
    'substitutions': _json(r.substitutions),
    'nutrients': _json(
      r.nutrients
          .map((n) => {'name': n.name, 'amount': n.amount, 'note': n.note})
          .toList(),
    ),
    'tags': _arr(r.tags),
    'situations': _arr(r.situations),
    'ingredient_keys': _arr(r.ingredientKeys),
    'related_article': _s(r.relatedArticle),
    'related_video_id': _s(r.relatedVideoId),
    'related_product_id': _s(r.relatedProductId),
    'related_community': _s(r.relatedCommunity),
    'shuffle_seed': '${r.seed}',
    'sort': '$sort',
    // 0096, the recipe-doc page. Null / empty on a dish without the doc format,
    // which is the column default, so an older dish writes what it always had.
    'photo': _s(r.photo),
    'amounts': _json(r.amounts),
    'texture': _s(r.texture),
    'meal_role': _s(r.mealRole),
    'also_in': _arr(r.alsoIn),
    'doc_id': _s(r.docId),
  };
}

/// Below this, the archive pass would retire most of the library. A list that
/// short means a broken build, not a decision, so the export refuses.
const int kRecipeExportMinimum = 100;

void main() {
  test('generate build/seed_recipes.sql from kFoodRecipes', () {
    // Recipes are bundled: the Dart list is the truth and the table is its
    // mirror. If an editor ever owns them, this file must stop writing them,
    // or every run would put the older bundled copy back over the editor's.
    // That is the guard `do nothing` used to be (BACKEND-PATTERNS, "An exact
    // mirror").
    if (ContentOwnership.isEditorOwned('recipes')) {
      // ignore: avoid_print
      print('\nSKIPPED recipes: editor-owned, the table is the truth.');
      return;
    }
    if (kFoodRecipes.length < kRecipeExportMinimum) {
      throw StateError(
        'kFoodRecipes has ${kFoodRecipes.length} dishes (< $kRecipeExportMinimum). '
        'The archive pass would retire the rest of the library, so nothing was written.',
      );
    }

    final buf = StringBuffer()
      ..writeln(
        '-- GENERATED by tool/export_content_seed.dart — do not edit by hand.',
      )
      ..writeln(
        '-- Source: lib/screens/post_pregnancy/pp_food_data.dart (kFoodRecipes)',
      )
      ..writeln('--')
      ..writeln(
        '-- An exact mirror of the bundled list: new dishes are inserted, changed',
      )
      ..writeln(
        '-- dishes updated, and dishes no longer in the app archived (last statement).',
      )
      ..writeln(
        '-- Safe to re-run. Recipes are bundled (the Dart is the truth), so the',
      )
      ..writeln(
        '-- table follows it; the tool refuses to run once they are editor-owned.',
      )
      ..writeln();

    for (var i = 0; i < kFoodRecipes.length; i++) {
      final row = recipeRow(kFoodRecipes[i], i);
      final cols = row.keys.toList();
      buf
        ..writeln('insert into public.recipes (')
        ..writeln('  ${cols.join(', ')}')
        ..writeln(') values (')
        ..writeln('  ${row.values.join(',\n  ')}')
        ..writeln(') on conflict (source_key) do update set')
        ..writeln(
          [
            for (final c in cols)
              if (c != 'source_key') '  $c = excluded.$c',
            '  updated_at = now()',
          ].join(',\n'),
        )
        ..writeln(';')
        ..writeln();
    }

    // Retire what the app no longer ships (a dish removed, or moved to a new id
    // by kFoodRecipeMoved). Archived, not deleted: a saved or cooked reference
    // still resolves, it is reversible, and Ask Veda's ingest reads only
    // `published`, so the dish leaves the index on the next run.
    buf
      ..writeln(
        'update public.recipes set status = \'archived\', updated_at = now()',
      )
      ..writeln(' where status = \'published\'')
      ..writeln('   and source_key not in (')
      ..writeln('  ${kFoodRecipes.map((r) => _s(r.id)).join(',\n  ')}')
      ..writeln(');')
      ..writeln()
      ..writeln('-- Sanity check after running this file:')
      ..writeln(
        "--   select count(*) from public.recipes where status = 'published';   -- expect ${kFoodRecipes.length}",
      );

    final f = File('build/seed_recipes.sql');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(buf.toString());

    // ignore: avoid_print
    print(
      '\nGENERATED ${kFoodRecipes.length} recipes -> build/seed_recipes.sql',
    );

    expect(kFoodRecipes, isNotEmpty);
  });

  test('generate build/seed_reads.sql from kReadArticles', () {
    final buf = StringBuffer()
      ..writeln('-- GENERATED by tool/export_content_seed.dart — do not edit by hand.')
      ..writeln('-- Source: lib/screens/post_pregnancy/pp_reading_data.dart (kReadArticles)')
      ..writeln('-- Safe to re-run: on conflict (source_key) do nothing.')
      ..writeln();

    for (var i = 0; i < kReadArticles.length; i++) {
      final a = kReadArticles[i];
      final (ageMin, ageMax) = _ageMonths(a.ageTag);

      // The reader's blocks, flattened to the jsonb shape ReadStore decodes.
      // Optional inline elements are omitted rather than written as null, so
      // the stored JSON reads the way an editor would write it.
      final sections = a.sections
          .map((s) => <String, dynamic>{
                if (s.heading != null) 'heading': s.heading,
                'paragraphs': s.paragraphs,
                if (s.tip != null)
                  'tip': {'title': s.tip!.title, 'body': s.tip!.body},
                if (s.mythFact != null)
                  'mythFact': {
                    'myth': s.mythFact!.myth,
                    'fact': s.mythFact!.fact,
                  },
                if (s.image) 'image': true,
              })
          .toList();

      buf
        ..writeln('insert into public.reads (')
        ..writeln('  source_key, status, domain, title, teaser, why_today,')
        ..writeln('  collection, kind, age_tag, age_min_months, age_max_months, minutes,')
        ..writeln('  author, author_role, evidence, sections,')
        ..writeln('  related_activity, related_video_id, related_video_ids,')
        ..writeln('  related_recipe_id, related_product_id, related_community,')
        ..writeln('  shuffle_seed, sort')
        ..writeln(') values (')
        ..writeln('  ${_s(a.id)}, \'published\', \'parenting\', ${_s(a.title)}, ${_s(a.teaser)}, ${_s(a.whyToday)},')
        ..writeln('  ${_s(a.collection)}, ${_s(a.kind.name)}, ${_s(a.ageTag)}, ${ageMin ?? 'null'}, ${ageMax ?? 'null'}, ${a.minutes},')
        ..writeln('  ${_s(a.author)}, ${_s(a.authorRole)}, ${_s(a.evidence)}, ${_json(sections)},')
        ..writeln('  ${_s(a.relatedActivity)}, ${_s(a.relatedVideoId)}, ${_arr(a.relatedVideoIds)},')
        ..writeln('  ${_s(a.relatedRecipeId)}, ${_s(a.relatedProductId)}, ${_s(a.relatedCommunity)},')
        ..writeln('  ${a.seed}, $i')
        ..writeln(') on conflict (source_key) do nothing;')
        ..writeln();
    }

    buf
      ..writeln('-- Sanity check after running this file:')
      ..writeln('--   select count(*) from public.reads;   -- expect ${kReadArticles.length}');

    final f = File('build/seed_reads.sql');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(buf.toString());

    // ignore: avoid_print
    print('GENERATED ${kReadArticles.length} reads -> build/seed_reads.sql');

    expect(kReadArticles, isNotEmpty);
  });

  test('generate build/seed_products.sql from kPpProducts', () {
    final buf = StringBuffer()
      ..writeln('-- GENERATED by tool/export_content_seed.dart — do not edit by hand.')
      ..writeln('-- Source: lib/screens/post_pregnancy/pp_products_data.dart (kPpProducts)')
      ..writeln('-- Safe to re-run: on conflict (source_key) do nothing.')
      ..writeln('--')
      ..writeln('-- price_inr is WHOLE RUPEES, matching the bundled Dart exactly.')
      ..writeln();

    for (var i = 0; i < kPpProducts.length; i++) {
      final p = kPpProducts[i];
      buf
        ..writeln('insert into public.products (')
        ..writeln('  source_key, status, domain, name, brand, category, sub,')
        ..writeln('  price_inr, retailer, rating, reviews,')
        ..writeln('  verified, parent_veda, bestseller, badge, best_for, summary,')
        ..writeln('  pros, cons, specs,')
        ..writeln('  spec_sound, spec_auto_off, spec_volume_lock, spec_power,')
        ..writeln('  sort')
        ..writeln(') values (')
        ..writeln('  ${_s(p.id)}, \'published\', \'parenting\', ${_s(p.name)}, ${_s(p.brand)}, ${_s(p.category)}, ${_s(p.sub)},')
        ..writeln('  ${p.price}, ${_s(p.retailer)}, ${p.rating}, ${p.reviews},')
        ..writeln('  ${_b(p.verified)}, ${_b(p.parentVeda)}, ${_b(p.bestseller)}, ${_s(p.badge)}, ${_s(p.bestFor)}, ${_s(p.summary)},')
        ..writeln('  ${_json(p.pros)}, ${_json(p.cons)}, ${_json(p.specs)},')
        ..writeln('  ${_s(p.sound)}, ${_nb(p.autoOff)}, ${_nb(p.volumeLock)}, ${_s(p.power)},')
        ..writeln('  $i')
        ..writeln(') on conflict (source_key) do nothing;')
        ..writeln();
    }

    buf
      ..writeln('-- Sanity check after running this file:')
      ..writeln('--   select count(*) from public.products;   -- expect ${kPpProducts.length}');

    final f = File('build/seed_products.sql');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(buf.toString());

    // ignore: avoid_print
    print('GENERATED ${kPpProducts.length} products -> build/seed_products.sql');

    expect(kPpProducts, isNotEmpty);
  });
}
