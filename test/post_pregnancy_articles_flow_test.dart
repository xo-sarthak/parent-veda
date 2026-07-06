// Functional test for the Article archive filters — the topic + age-band
// queries behind the chips actually narrow the list.
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_articles_data.dart';

void main() {
  test('default filter (All · 3–6 mo) returns every article', () {
    final all = filterArticles();
    expect(all.length, kArticles.length);
    expect(all.any((a) => a.featured), isTrue);
  });

  test('topic chip narrows the list', () {
    final sleep = filterArticles(topic: 'Sleep').map((a) => a.id);
    expect(sleep, contains('sleepcycles'));
    expect(sleep, isNot(contains('distractedfeeds'))); // a Feeding article
    expect(filterArticles(topic: 'Sleep').every((a) => a.category == 'Sleep'), isTrue);
  });

  test('age band narrows the list', () {
    expect(filterArticles(age: '0–3 mo'), isEmpty); // sample content is all 3–6 mo
    expect(filterArticles(age: '3–6 mo'), isNotEmpty);
  });
}
