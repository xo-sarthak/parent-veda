// =============================================================================
//  EXPORT TOOL (not a test) — dump the PARENTING in-app corpus to JSON.
// -----------------------------------------------------------------------------
//  Run:  flutter test tool/export_parenting_corpus.dart
//  Out:  build/parenting_corpus.json
//
//  Then, in the Ask Veda repo (C:\Projects\parentveda-askveda):
//    python -m ingest.import_corpus C:/Projects/parentveda/build/parenting_corpus.json --prune-prefix ppv
//    python -m ingest.ingest
//
//  ⚠️ `--prune-prefix ppv`, NEVER `pp` and never a plain `--prune`. The older
//  parenting documents (`export_veda_corpus.dart`: `know_`, `ppart_`, `pprec_`,
//  `ppprod_`, `ppexp_`) share the `parenting` domain and are not in this file;
//  either wider prune would delete them.
//
//  The logic is `lib/ask_veda/pp_veda_corpus.dart` (so a test can check it);
//  this file only writes it down. Companion to `export_pregnancy_corpus.dart`.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ask_veda/pp_veda_corpus.dart';

void main() {
  test('export the parenting corpus to build/parenting_corpus.json', () {
    final out = buildParentingVedaCorpus();

    final f = File('build/parenting_corpus.json');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(out));

    final byKind = <String, int>{};
    var words = 0;
    for (final d in out) {
      byKind[d['kind'] as String] = (byKind[d['kind'] as String] ?? 0) + 1;
      words += (d['body'] as String).split(RegExp(r'\s+')).length;
    }
    // ignore: avoid_print
    print('\nEXPORTED ${out.length} docs (~$words words) -> build/parenting_corpus.json');
    for (final k in (byKind.keys.toList()..sort())) {
      // ignore: avoid_print
      print('   ${k.padRight(10)} ${byKind[k]}');
    }
    // ignore: avoid_print
    print('\nNext, in the Ask Veda repo:\n'
        '   python -m ingest.import_corpus C:/Projects/parentveda/build/parenting_corpus.json --prune-prefix ppv\n'
        '   python -m ingest.ingest');

    expect(out, isNotEmpty);
  });
}
