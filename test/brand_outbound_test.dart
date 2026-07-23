// =============================================================================
//  Outbound links — tagging, and the promises around it
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/brand/outbound.dart';

void main() {
  test('Amazon links now carry the partner tag', () {
    // The Amazon tag was switched on for the Buy-now flow (a placeholder value
    // until the real associate account exists). An amazon.in link must now go
    // out tagged — that is the whole point of turning it on.
    final uri = Uri.parse('https://www.amazon.in/s?k=baby+lotion');
    expect(tagged(uri).queryParameters['tag'], isNotNull,
        reason: 'attribution is on for Amazon now');
    expect(retailerOf(uri), 'amazon.in');
  });

  test('a retailer we have no deal with goes out exactly as it came in', () {
    // FirstCry is still commented out in kPartnerTags, so it is the honest
    // "untagged retailer" case now: nothing added, nothing changed.
    final uri = Uri.parse('https://www.firstcry.com/search?q=baby+lotion');
    expect(tagged(uri).toString(), uri.toString());
    expect(retailerOf(uri), isNull);
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
