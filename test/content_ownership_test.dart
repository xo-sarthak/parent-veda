// =============================================================================
//  The ratchet holds — tests that scan the SOURCE, not just the data.
// -----------------------------------------------------------------------------
//  Correct-but-unreachable code is this repo's known failure mode, so these
//  assert against the actual text of the export tools rather than against a
//  helper they might have stopped calling. A guard nobody invokes is not a
//  guard, and it would fail in the quietest possible way: an editor's published
//  work replaced by an older bundled copy, with no error anywhere.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/content_ownership.dart';
import 'package:parentveda/services/content_registry.dart';

void main() {
  const exportTools = <String>[
    'tool/export_veda_corpus.dart',
    'tool/export_ttc_corpus.dart',
  ];

  group('export tools respect content ownership', () {
    for (final path in exportTools) {
      test('$path consults ContentOwnership before emitting', () {
        final src = File(path).readAsStringSync();

        expect(
          src.contains("import 'package:parentveda/services/content_ownership.dart'"),
          isTrue,
          reason: '$path must import the ownership map to be able to skip '
              'editor-owned types.',
        );
        expect(
          src.contains('ContentOwnership.isKindEditorOwned'),
          isTrue,
          reason: '$path must ask before emitting. Without this call the tool '
              'will overwrite editor-published content on its next run.',
        );
        expect(
          src.contains('SKIPPED'),
          isTrue,
          reason: '$path must report what it skipped. A content type silently '
              'vanishing from the corpus is how "why did Ask Veda stop '
              'knowing about this?" starts.',
        );
      });
    }
  });

  group('the ownership map is coherent', () {
    test('every editor-owned table has a migration that creates it', () {
      final migrations = Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .map((f) => f.readAsStringSync())
          .join('\n');

      for (final table in ContentOwnership.editorOwned) {
        expect(
          // Or a VIEW — programmes are read through one, because resolving
          // "who hosts this" is a join whose rule belongs beside the data.
          RegExp('create (table (if not exists )?|or replace view |view )'
                  '(public\\.)?$table\\b',
                  caseSensitive: false)
              .hasMatch(migrations),
          isTrue,
          reason: '$table is marked editor-owned, so the app expects Supabase '
              'to be its source of truth — but no migration creates it. The '
              'flip was done out of order.',
        );
      }
    });

    test('every registered store declares a known table', () {
      for (final store in ContentRegistry.stores) {
        expect(
          ContentOwnership.known,
          contains(store.table),
          reason: '${store.table} has a store but no entry in '
              'ContentOwnership. Add it — bundled is a valid answer, silence '
              'is not, because the export tools read that map to decide '
              'whether they may overwrite it.',
        );
      }
    });

    test('an unknown type defaults to bundled, never to editor-owned', () {
      // Default-deny: forgetting an entry must fail SAFE. Defaulting to
      // editor-owned would mean a forgotten type silently stops being
      // exported, and Ask Veda would quietly lose that knowledge.
      expect(ContentOwnership.isEditorOwned('a_table_nobody_added'), isFalse);
      expect(ContentOwnership.isKindEditorOwned('nonexistent_kind'), isFalse);
    });
  });
}
