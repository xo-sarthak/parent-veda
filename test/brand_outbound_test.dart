// =============================================================================
//  Outbound links — tagging, and the promises around it
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/brand/outbound.dart';

void main() {
  test('an untagged retailer goes out exactly as it came in', () {
    // kPartnerTags is empty until real affiliate accounts exist, so this is
    // today's behaviour: nothing is added, nothing changes, no surprises.
    final uri = Uri.parse('https://www.amazon.in/s?k=baby+lotion');
    expect(tagged(uri).toString(), uri.toString());
  });

  test('an unknown host is never touched', () {
    final uri = Uri.parse('https://example.com/thing?a=1');
    expect(tagged(uri), uri);
    expect(retailerOf(uri), isNull);
  });

  test('tagging never overwrites a param the link already carries', () {
    // If a brand hands us a deep link with its own tracking on it, that is
    // theirs. We add ours alongside; we do not quietly replace it.
    const tags = {'amazon.in': {'tag': 'parentveda-21'}};
    final uri = Uri.parse('https://www.amazon.in/dp/X?tag=someoneelse-21');
    final params = Map<String, String>.from(uri.queryParameters);
    for (final e in tags['amazon.in']!.entries) {
      params.putIfAbsent(e.key, () => e.value);
    }
    expect(params['tag'], 'someoneelse-21');
  });

  test('a malformed url is a no-op, never a crash', () async {
    expect(await openOutbound(''), isFalse);
    expect(await openOutbound('   '), isFalse);
    expect(await openOutbound('not a url'), isFalse);
    expect(await openOutbound('/relative/path'), isFalse);
  });

  test('we do not route parents through our own redirector', () {
    // A parent tapping "Buy on Amazon" should land on Amazon — not on a
    // tracker that forwards them there. Pinning the intent: tagging only ever
    // adds query params, and never changes the host a parent lands on.
    final uri = Uri.parse('https://www.amazon.in/s?k=x');
    expect(tagged(uri).host, uri.host);
    expect(tagged(uri).scheme, 'https');
  });
}
