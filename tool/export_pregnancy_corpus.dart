// =============================================================================
//  EXPORT TOOL (not a test) — dump the PREGNANCY in-app corpus to JSON.
// -----------------------------------------------------------------------------
//  Run:  flutter test tool/export_pregnancy_corpus.dart
//  Out:  build/pregnancy_corpus.json
//
//  Then, in the Ask Veda repo (C:\Projects\parentveda-askveda):
//    python -m ingest.import_corpus C:/Projects/parentveda/build/pregnancy_corpus.json --prune-prefix pv
//    python -m ingest.ingest
//
//  ⚠️ `--prune-prefix pv`, NEVER a plain `--prune`. These documents share the
//  `pregnancy` domain with the older offline corpus (`export_veda_corpus.dart`:
//  can-I, symptoms, products, weekly articles). A plain --prune would delete
//  every one of those, because this file does not contain them. The prefix
//  limits the prune to ids that start `pv` (`pvread_`, `pvfaq_`, `pvdoor_`,
//  `pvtool_`), which only this export makes.
//
//  The logic is `lib/ask_veda/pv_veda_corpus.dart` (so a test can check it);
//  this file only writes it down. Companion to `export_ttc_corpus.dart`.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ask_veda/pv_veda_corpus.dart';

void main() {
  test('export the pregnancy corpus to build/pregnancy_corpus.json', () {
    final out = buildPregnancyVedaCorpus();

    final f = File('build/pregnancy_corpus.json');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(out));

    final byKind = <String, int>{};
    var words = 0;
    for (final d in out) {
      byKind[d['kind'] as String] = (byKind[d['kind'] as String] ?? 0) + 1;
      words += (d['body'] as String).split(RegExp(r'\s+')).length;
    }
    // ignore: avoid_print
    print('\nEXPORTED ${out.length} docs (~$words words) -> build/pregnancy_corpus.json');
    for (final k in (byKind.keys.toList()..sort())) {
      // ignore: avoid_print
      print('   ${k.padRight(10)} ${byKind[k]}');
    }
    // ignore: avoid_print
    print('\nNext, in the Ask Veda repo:\n'
        '   python -m ingest.import_corpus C:/Projects/parentveda/build/pregnancy_corpus.json --prune-prefix pv\n'
        '   python -m ingest.ingest');

    expect(out, isNotEmpty);
  });
}
