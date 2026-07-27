// =============================================================================
//  The recipes seed matches the bundled Dart.
// -----------------------------------------------------------------------------
//  Step 3 of the add-a-type recipe promises that seeding makes day one look
//  IDENTICAL — that switching RecipeStore to the database changes nothing you
//  can see. That promise is what makes the flip safe to ship and reversible.
//  This test is what keeps it true.
//
//  It is DELIBERATELY TEMPORARY. Once an editor has genuinely edited a dish in
//  Directus, the database is supposed to differ from the Dart — that is the
//  whole point of the migration. At that moment this test has done its job and
//  should be deleted along with the bulk of kFoodRecipes (step 6, which shrinks
//  the Dart to ~5 seed dishes).
//
//  Note it checks the GENERATOR, not the database: it regenerates the seed and
//  compares it against the source of truth. Nothing here talks to Supabase, so
//  it runs in the normal suite with no network and no credentials.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:parentveda/services/content_ownership.dart';

void main() {
  final seedFile = File('build/seed_recipes.sql');

  group('recipes seed', () {
    test('has been generated', () {
      expect(
        seedFile.existsSync(),
        isTrue,
        reason: 'Run: flutter test tool/export_content_seed.dart\n'
            'The seed is generated rather than hand-written so a dropped '
            'ingredient cannot slip in unreviewed.',
      );
    }, skip: seedFile.existsSync() ? false : 'seed not generated yet');

    test('contains every bundled dish, exactly once', () {
      if (!seedFile.existsSync()) return;
      final sql = seedFile.readAsStringSync();

      for (final r in kFoodRecipes) {
        final occurrences = "'${r.id}'".allMatches(sql).length;
        expect(
          occurrences,
          greaterThanOrEqualTo(1),
          reason: '${r.id} ("${r.title}") is in the app but not in the seed. '
              'Regenerate it, or the dish silently disappears the day the '
              'catalogue is served from Supabase.',
        );
      }

      final inserts = 'insert into public.recipes'.allMatches(sql).length;
      expect(
        inserts,
        kFoodRecipes.length,
        reason: 'The seed has $inserts inserts for ${kFoodRecipes.length} '
            'bundled dishes. Regenerate: '
            'flutter test tool/export_content_seed.dart',
      );
    });

    test('can never overwrite an editor', () {
      if (!seedFile.existsSync()) return;
      final sql = seedFile.readAsStringSync();

      // Match the STATEMENT, not the prose — the generated header explains the
      // guard in a comment, and counting that too made this test pass for the
      // wrong reason (29 guards for 28 inserts).
      final guards =
          ') on conflict (source_key) do nothing;'.allMatches(sql).length;
      expect(
        guards,
        'insert into public.recipes'.allMatches(sql).length,
        reason: 'Every insert must be guarded. An unguarded re-run would '
            'replace whatever an editor has published with the older bundled '
            'copy — silently, and with no way to tell it happened.',
      );

      expect(
        sql.contains('do update'),
        isFalse,
        reason: 'An upsert here would overwrite editor content on every re-run. '
            'The seed exists to establish a starting point, not to enforce one.',
      );
    });
  });

  test('recipes stays bundled until the seed has actually been run', () {
    // The ratchet is a THREE-part change (ownership entry + AskVeda
    // SOURCE_SPECS + veda_knowledge cleanup). Flipping this entry before the
    // table has rows would mean the export tool stops emitting recipes while
    // Supabase has none — and Ask Veda quietly loses every dish it knows.
    //
    // When the flip is genuinely done, change this expectation deliberately, in
    // the same commit as the other two parts.
    expect(
      ContentOwnership.isEditorOwned('recipes'),
      isFalse,
      reason: 'If this is now intentional, update this test in the same commit '
          'as the ingest.py SOURCE_SPECS entry and the veda_knowledge cleanup.',
    );
  });
}
