// Ask Veda retrieval: the corpus now indexes the newer app content - scan/test
// guides, the remaining Garbh pillars (breath + womb-connection) and the weekly
// written articles. These assert each new family is actually reachable through
// vedaSearch/vedaAnswer (content-only path; community stays excluded).
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/veda_answer.dart';
import 'package:parentveda/services/veda_index.dart';

void main() {
  final p = PregnancyController();

  bool hasKind(String q, VedaKind kind) =>
      vedaSearch(q, p, limit: 8).any((h) => h.doc.kind == kind);

  bool hasDocId(String q, String idPrefix) =>
      vedaSearch(q, p, limit: 8).any((h) => h.doc.id.startsWith(idPrefix));

  group('Ask Veda - newly indexed sources', () {
    test('scan & test guides are retrievable', () {
      expect(hasKind('anomaly scan', VedaKind.scan), isTrue);
      expect(hasKind('glucose screening in pregnancy', VedaKind.scan), isTrue);
      expect(hasKind('group b strep test', VedaKind.scan), isTrue);
      // report-glossary terms live in the body, so jargon resolves too
      expect(hasKind('what does NAD mean on my scan report', VedaKind.scan), isTrue);
    });

    test('Garbh breath practices (Kriya) are retrievable', () {
      expect(hasDocId('a breathing exercise to calm down', 'kriya_'), isTrue);
      expect(hasDocId('bhramari breath', 'kriya_'), isTrue);
    });

    test('Garbh womb-connection scripts (Samvad) are retrievable', () {
      expect(hasDocId('read aloud to my baby', 'samvad_'), isTrue);
    });

    test('weekly written articles are retrievable', () {
      expect(hasDocId('eating well in the second trimester', 'wkarticle_'), isTrue);
    });

    test('vedaAnswer forms a grounded answer from a scan guide', () {
      // A specific query that goes through retrieval (not a hand-authored
      // showcase) and lands on a scan doc.
      final r = vedaAnswer('group b strep swab', p);
      expect(r.answer.trim(), isNotEmpty);
      expect(r.view, isNotNull); // retrieval path
      expect(r.view!.content, isNotNull);
    });

    test('community is still never a source for the answer path', () {
      // includeCommunity:false is what the answer uses - no community docs leak in.
      final hits = vedaSearch('pregnancy', p, includeCommunity: false, limit: 20);
      expect(hits.any((h) => h.doc.kind == VedaKind.community), isFalse);
    });
  });
}
