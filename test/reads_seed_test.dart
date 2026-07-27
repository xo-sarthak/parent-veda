// =============================================================================
//  The reads seed matches the bundled Dart.
// -----------------------------------------------------------------------------
//  Same contract as test/recipes_seed_test.dart, and deliberately temporary for
//  the same reason: once an editor genuinely edits an article, the database is
//  SUPPOSED to differ from the Dart, and this test has done its job.
//
//  Reads carry one extra risk worth a test of its own. An article's body is a
//  nested structure — sections, each with paragraphs and optional inline tips
//  and myth-vs-fact cards — flattened into jsonb. A shape mismatch there does
//  not throw; it renders an article with its signature elements quietly
//  missing, which nobody notices from a row count.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reading_data.dart';
import 'package:parentveda/services/content_ownership.dart';

void main() {
  final seedFile = File('build/seed_reads.sql');

  group('reads seed', () {
    test('contains every bundled article, guarded against overwriting', () {
      if (!seedFile.existsSync()) {
        markTestSkipped('Run: flutter test tool/export_content_seed.dart');
        return;
      }
      final sql = seedFile.readAsStringSync();

      for (final a in kReadArticles) {
        expect(
          sql.contains("'${a.id}'"),
          isTrue,
          reason: '${a.id} ("${a.title}") is in the app but not in the seed.',
        );
      }

      final inserts = 'insert into public.reads'.allMatches(sql).length;
      expect(inserts, kReadArticles.length,
          reason: 'Regenerate: flutter test tool/export_content_seed.dart');

      expect(
        ') on conflict (source_key) do nothing;'.allMatches(sql).length,
        inserts,
        reason: 'Every insert must be guarded, or a re-run replaces published '
            'work with the older bundled copy.',
      );
    });

    test('the reader\'s signature elements survive the round trip', () {
      if (!seedFile.existsSync()) {
        markTestSkipped('Run: flutter test tool/export_content_seed.dart');
        return;
      }
      final sql = seedFile.readAsStringSync();

      // These exist in the bundled articles, so they must exist in the seed.
      // If the section flattener ever drops a key, the article still publishes
      // and still reads — just without the tip or the myth-vs-fact card that
      // made it worth writing.
      final hasTip = kReadArticles.any((a) => a.sections.any((s) => s.tip != null));
      final hasMyth =
          kReadArticles.any((a) => a.sections.any((s) => s.mythFact != null));

      if (hasTip) {
        expect(sql.contains('tip'), isTrue,
            reason: 'Articles carry inline ParentVeda tips; none reached the seed.');
      }
      if (hasMyth) {
        expect(sql.contains('mythFact'), isTrue,
            reason: 'Articles carry myth-vs-fact cards; none reached the seed.');
      }
      expect(sql.contains('paragraphs'), isTrue,
          reason: 'No article body reached the seed at all.');
    });
  });

  test('reads stays bundled until the seed has actually been run', () {
    // Three-part flip — see test/recipes_seed_test.dart. Change this in the
    // same commit as the AskVeda SOURCE_SPECS entry, never before.
    expect(ContentOwnership.isEditorOwned('reads'), isFalse);
  });
}
