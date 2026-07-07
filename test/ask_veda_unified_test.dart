// Ask Veda unification: ONE engine (ask_veda/veda_core.dart), two tagged feeds.
// These assert the parenting side now retrieves real parenting content through
// the shared core, and that the domain tag keeps the feeds isolated — a parenting
// search only ever returns parenting (or universal) docs.
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/ask_veda/veda_core.dart';
import 'package:parentveda/screens/post_pregnancy/parenting_veda.dart';

void main() {
  group('Ask Veda — one engine, parenting feed (domain-tagged)', () {
    test('the whole parenting corpus is stamped parenting', () {
      expect(parentingCorpus(), isNotEmpty);
      expect(parentingCorpus().every((d) => d.domain == VedaDomain.parenting), isTrue);
    });

    test('common parenting questions retrieve parenting content', () {
      bool has(String q) => parentingVedaSearch(q).isNotEmpty;
      expect(has('he wakes every 2 hours at night'), isTrue); // 4-month sleep regression
      expect(has('when do i start solids'), isTrue); // starting solids
      expect(has('how to do tummy time'), isTrue); // activity
      expect(has('soft khichdi recipe'), isTrue); // recipe
      expect(has('white noise soother'), isTrue); // product
    });

    test('every hit stays inside the parenting domain (no cross-leak)', () {
      final hits = parentingVedaSearch('sleep', limit: 30);
      expect(hits, isNotEmpty);
      expect(
        hits.every((h) =>
            h.doc.domain == VedaDomain.parenting ||
            h.doc.domain == VedaDomain.universal),
        isTrue,
      );
    });

    test('a pregnancy-only term finds nothing in the parenting corpus', () {
      // "episiotomy" is birth content; the parenting corpus has no such doc.
      expect(parentingVedaSearch('episiotomy'), isEmpty);
    });

    test('parentingVedaAnswer builds the shared 7-section view', () {
      final v = parentingVedaAnswer('4 month sleep regression');
      expect(v.answer.trim(), isNotEmpty);
      expect(v.actions, isNotEmpty);
      // supporting content and/or a product should surface
      expect(v.content.isNotEmpty || v.products.isNotEmpty, isTrue);
    });

    test('no match returns an honest view, not a crash', () {
      final v = parentingVedaAnswer('zxqw nonsense qwerty');
      expect(v.answer.toLowerCase(), contains("don't have"));
      expect(v.content, isEmpty);
    });
  });
}
