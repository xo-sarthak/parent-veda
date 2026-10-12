// The parenting Ask Veda corpus (`lib/ask_veda/pp_veda_corpus.dart`): what the
// export writes is what the screen can open, and the clinical half travels.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ask_veda/pp_veda_corpus.dart';
import 'package:parentveda/screens/post_pregnancy/askveda_screen.dart' as screen;
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

import 'dart:io';

void main() {
  final docs = buildParentingVedaCorpus();

  test('every door page that is not coming soon is a document', () {
    final ids = {for (final d in docs) d['doc_id'] as String};
    for (final s in kPpSections) {
      for (final a in s.areas) {
        for (final p in a.pages) {
          if (p.comingSoon) continue;
          expect(ids, contains(ppVedaPageId(s.id, p.id)), reason: '${s.id}/${p.id}');
        }
      }
    }
  });

  test('every id is this export\'s own and resolves to something real', () {
    for (final d in docs) {
      final id = d['doc_id'] as String;
      expect(id.startsWith(kPpVedaPrefix), isTrue, reason: id);
      expect(ppVedaTarget(id), isNotNull, reason: id);
      expect(d['domain'], 'parenting');
    }
  });

  test('a page\'s doctor lines are in its body', () {
    for (final s in kPpSections) {
      for (final a in s.areas) {
        for (final p in a.pages) {
          if (p.comingSoon) continue;
          final body = docs.firstWhere((d) => d['doc_id'] == ppVedaPageId(s.id, p.id))['body'] as String;
          for (final b in p.blocks.whereType<PpWhenLine>()) {
            expect(body, contains(b.text), reason: '${s.id}/${p.id}');
          }
        }
      }
    }
  });

  test('the parenting Ask Veda screen opens these ids', () {
    expect(screen.AskVedaScreen, isNotNull);
    final src = File('lib/screens/post_pregnancy/askveda_screen.dart').readAsStringSync();
    expect(src, contains('openPpVedaDoc(context, it.docId)'));
    // The service scopes to parenting only when told (app/answer.py scope_domain).
    expect(src, contains("stage: 'parenting'"));
  });
}
