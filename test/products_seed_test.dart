// =============================================================================
//  The products seed matches the bundled Dart — and keeps its honest half.
// -----------------------------------------------------------------------------
//  Same temporary contract as the recipes and reads seed tests. Products get
//  two extra checks of their own, because two things here are easy to lose
//  without anyone noticing:
//
//  1. THE HONEST HALF. tool/export_ttc_corpus.dart states the rule for TTC
//     products: watchOut is exported with the same weight as lookFor, because
//     a catalogue that lists only what is good about a thing is an advert. The
//     parenting corpus was not honouring it — it grounded Ask Veda on `pros`
//     alone. Now that cons live in a table an editor can empty, the rule needs
//     a test rather than a memory.
//
//  2. THREE-VALUED SPECS. autoOff and volumeLock are nullable on purpose:
//     null means "not checked", false means "does not have it". Collapsing
//     them would silently claim a product lacks a safety feature nobody
//     actually verified — on a screen built for comparing.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_products_data.dart';
import 'package:parentveda/services/content_ownership.dart';

void main() {
  final seedFile = File('build/seed_products.sql');

  group('products seed', () {
    test('contains every bundled product, guarded against overwriting', () {
      if (!seedFile.existsSync()) {
        markTestSkipped('Run: flutter test tool/export_content_seed.dart');
        return;
      }
      final sql = seedFile.readAsStringSync();

      for (final p in kPpProducts) {
        expect(sql.contains("'${p.id}'"), isTrue,
            reason: '${p.id} ("${p.name}") is in the app but not in the seed.');
      }

      final inserts = 'insert into public.products'.allMatches(sql).length;
      expect(inserts, kPpProducts.length,
          reason: 'Regenerate: flutter test tool/export_content_seed.dart');
      expect(
        ') on conflict (source_key) do nothing;'.allMatches(sql).length,
        inserts,
        reason: 'Every insert must be guarded against overwriting an editor.',
      );
    });

    test('unchecked compare specs stay null, not false', () {
      if (!seedFile.existsSync()) {
        markTestSkipped('Run: flutter test tool/export_content_seed.dart');
        return;
      }
      final sql = seedFile.readAsStringSync();

      // Most products do not carry the soother compare specs at all, so the
      // seed must be full of nulls. If it is not, the generator coerced them
      // and every product now claims to lack a volume lock.
      final unchecked = kPpProducts.where((p) => p.autoOff == null).length;
      if (unchecked > 0) {
        expect(sql.contains('null'), isTrue,
            reason: 'Nullable compare specs were flattened; "not checked" and '
                '"does not have it" are different claims about a product.');
      }
    });
  });

  test('every product keeps its "worth knowing" half', () {
    // Not a seed check — a content check, on the bundled source. A product
    // with pros and no cons reads as an advert, and Ask Veda now grounds
    // answers on both halves (parenting_veda.dart).
    final oneSided = kPpProducts
        .where((p) => p.pros.isNotEmpty && p.cons.isEmpty)
        .map((p) => p.id)
        .toList();

    expect(
      oneSided,
      isEmpty,
      reason: 'These products list only what is good about them: '
          '${oneSided.join(', ')}. Add the caveats, or drop the pros — a '
          'one-sided entry is an advert, and it is what Ask Veda will repeat.',
    );
  });

  test('products stays bundled until the seed has actually been run', () {
    expect(ContentOwnership.isEditorOwned('products'), isFalse);
  });
}
