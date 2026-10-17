// =============================================================================
//  The recipes export writes every column the migrations give `public.recipes`.
// -----------------------------------------------------------------------------
//  0096 added six recipe-doc columns (photo, amounts, texture, meal_role,
//  also_in, doc_id) and the export kept writing the old list. Nothing failed:
//  the columns just stayed empty in production. This test reads the schema
//  from the migration files (no database needed) and compares it with the
//  keys of `recipeRow`, the one place the export's column list lives. A new
//  migration column now fails here until the export writes it, and a misspelt
//  export column fails too.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';

import '../tool/export_content_seed.dart' as seed;

/// Columns the database fills itself, or that only an editor would set. The
/// export must not write them.
const Set<String> _dbOwned = {
  'id', // gen_random_uuid()
  'created_at',
  'updated_at',
  'published_at', // timestamps (updated_at is set on conflict)
  'title_hi', 'subtitle_hi', // Hindi, owed only when asked (CLAUDE.md)
  'hero_image', 'hero_file', // Directus picker; the bundled dish uses `photo`
};

/// Every column `public.recipes` has, read from the migration files.
Set<String> _schemaColumns() {
  final cols = <String>{};
  final files =
      Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final f in files) {
    final sql = f.readAsStringSync();

    final create = RegExp(
      r'create table if not exists public\.recipes \(([\s\S]*?)\n\);',
    ).firstMatch(sql);
    if (create != null) {
      for (final line in create.group(1)!.split('\n')) {
        final m = RegExp(
          r'^\s{2}([a-z_]+)\s+(?:uuid|text|varchar|int|boolean|jsonb|timestamptz)',
        ).firstMatch(line);
        if (m != null) cols.add(m.group(1)!);
      }
    }

    for (final alter in RegExp(
      r'alter table public\.recipes([\s\S]*?);',
    ).allMatches(sql)) {
      for (final m in RegExp(
        r'add column (?:if not exists )?([a-z_]+)',
      ).allMatches(alter.group(1)!)) {
        cols.add(m.group(1)!);
      }
    }
  }
  return cols;
}

void main() {
  test('the schema parse finds the table (guards the guard)', () {
    final cols = _schemaColumns();
    // Spot checks from 0047 and 0096. If these vanish the regex broke, and an
    // empty set would make the main test meaningless.
    expect(
      cols,
      containsAll(['source_key', 'why', 'nutrients', 'texture', 'doc_id']),
    );
  });

  test('the export writes exactly the columns the migrations declare', () {
    final schema = _schemaColumns().difference(_dbOwned);
    final exported = seed.recipeRow(kFoodRecipes.first, 0).keys.toSet();

    expect(
      schema.difference(exported),
      isEmpty,
      reason:
          'These recipes columns exist in the database but the export '
          'never writes them, so they stay empty: '
          '${schema.difference(exported)}. Add them to recipeRow in '
          'tool/export_content_seed.dart (or to _dbOwned here, if the '
          'database fills them itself).',
    );
    expect(
      exported.difference(schema),
      isEmpty,
      reason:
          'The export writes columns no migration creates: '
          '${exported.difference(schema)}. Pasting the seed would fail.',
    );
  });
}
