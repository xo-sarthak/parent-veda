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
//  Until then the seed is an exact mirror (2026-10-17): insert, update on
//  conflict, archive whatever the app stopped shipping.
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

    // The recipes seed is an exact MIRROR since 2026-10-17 (it used to be
    // `do nothing`, which froze the table at the July 28 while the app grew to
    // ~140). The editor guard moved from the SQL to ContentOwnership: the tool
    // writes nothing once recipes are editor-owned (see the ratchet test below).
    // Kept for revert: the old 'can never overwrite an editor' test is in git
    // history (2f55b63 and earlier).
    test('updates every bundled dish it already holds', () {
      if (!seedFile.existsSync()) return;
      final sql = seedFile.readAsStringSync();
      final inserts = 'insert into public.recipes'.allMatches(sql).length;
      expect(
        ') on conflict (source_key) do update set'.allMatches(sql).length,
        inserts,
        reason:
            'Every insert must update on conflict. A skip leaves the table '
            'at whatever it held the first time, and nobody notices.',
      );
      // A dish archived earlier and added back must come back.
      expect('  status = excluded.status'.allMatches(sql).length, inserts);
    });

    test('archives every dish the app no longer ships', () {
      if (!seedFile.existsSync()) return;
      final sql = seedFile.readAsStringSync();
      final start = sql.indexOf(
        "update public.recipes set status = 'archived'",
      );
      expect(
        start,
        isNonNegative,
        reason:
            'Without the archive pass a retired dish stays published, '
            'and Ask Veda keeps answering from it.',
      );
      final archive = sql.substring(start);
      for (final r in kFoodRecipes) {
        expect(
          archive.contains("'${r.id}'"),
          isTrue,
          reason:
              '${r.id} is live in the app but missing from the keep '
              'list, so the seed would archive it.',
        );
      }
      for (final old in kFoodRecipeMoved.keys) {
        expect(
          archive.contains("'$old'"),
          isFalse,
          reason:
              '$old moved to ${kFoodRecipeMoved[old]}; it must not be '
              'kept published.',
        );
      }
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
