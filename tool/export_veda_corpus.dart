// =============================================================================
//  EXPORT TOOL (not a test) — dump the app's Ask Veda knowledge to JSON.
// -----------------------------------------------------------------------------
//  Run:  flutter test tool/export_veda_corpus.dart
//  Out:  build/veda_corpus.json
//
//  Why it lives here and runs via `flutter test`: the corpora pull in Flutter
//  (IconData/Color, rootBundle, shared_preferences), so a plain `dart run` can't
//  load them. Keeping it OUT of test/ means it never runs in the normal suite.
//
//  The JSON is consumed by the AskVeda backend importer (parentveda-askveda),
//  which uploads it to Supabase so the RAG service can ground answers on the
//  SAME knowledge the app has offline.
//
//  Bilingual: VedaDoc is monolingual (the corpus resolves language at build
//  time), so we build it TWICE — English + Hinglish — and merge by doc id.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/veda_showcase.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/post_pregnancy/parenting_veda.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/veda_index.dart';

void main() {
  test('export Ask Veda corpus to build/veda_corpus.json', () {
    final p = PregnancyController();

    // Pregnancy corpus, once per language (corpus() caches per language key).
    p.setLanguage(AppLanguage.english);
    final pregEn = VedaIndex.corpus(p);
    p.setLanguage(AppLanguage.hinglish);
    final pregHi = {for (final d in VedaIndex.corpus(p)) d.id: d};

    // Parenting corpus (English only today).
    final parenting = parentingCorpus();

    final out = <Map<String, dynamic>>[];

    void add(VedaDoc d, {String? titleHi, String? bodyHi}) {
      out.add(<String, dynamic>{
        'doc_id': d.id,
        'kind': d.kind.name,
        'domain': d.domain.name,
        'source_label': d.sourceLabel,
        'title': d.title,
        'body': d.body,
        'title_hi': titleHi,
        'body_hi': bodyHi,
        'keywords': d.keywords,
      });
    }

    for (final d in pregEn) {
      final hi = pregHi[d.id];
      add(d, titleHi: hi?.title, bodyHi: hi?.body);
    }
    for (final d in parenting) {
      add(d);
    }

    // The seeded showcase answers become CONTENT PIECES (not hardwired answers).
    // We flatten the useful prose sections into one body; the UI-ish sections
    // (products/services) are app concerns, not grounding material.
    for (final sc in kVedaShowcase) {
      String join(List<String> parts) =>
          parts.where((s) => s.trim().isNotEmpty).join('\n\n');
      out.add(<String, dynamic>{
        'doc_id': 'showcase_${sc.id}',
        'kind': 'showcase',
        'domain': 'pregnancy',
        'source_label': 'Ask Veda answer',
        'title': sc.question.en,
        'body': join([sc.answer.en, sc.meaning.en, ...sc.actions.map((a) => a.en)]),
        'title_hi': sc.question.hi,
        'body_hi': join([sc.answer.hi, sc.meaning.hi, ...sc.actions.map((a) => a.hi)]),
        'keywords': sc.keywords,
      });
    }

    final f = File('build/veda_corpus.json');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(out));

    // Breakdown, so we can see exactly what's being exported before uploading.
    final byKind = <String, int>{};
    final byDomain = <String, int>{};
    var withHi = 0;
    for (final m in out) {
      byKind[m['kind'] as String] = (byKind[m['kind'] as String] ?? 0) + 1;
      byDomain[m['domain'] as String] = (byDomain[m['domain'] as String] ?? 0) + 1;
      if ((m['body_hi'] as String?)?.trim().isNotEmpty ?? false) withHi++;
    }
    // ignore: avoid_print
    print('\nEXPORTED ${out.length} docs -> build/veda_corpus.json');
    // ignore: avoid_print
    print('WITH HINGLISH: $withHi');
    // ignore: avoid_print
    print('BY DOMAIN: $byDomain');
    // ignore: avoid_print
    print('BY KIND:');
    final kinds = byKind.keys.toList()..sort();
    for (final k in kinds) {
      // ignore: avoid_print
      print('   ${k.padRight(16)} ${byKind[k]}');
    }

    expect(out, isNotEmpty);
  });
}
