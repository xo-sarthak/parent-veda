// =============================================================================
//  The commission line, beside the one door out (gap analysis P1, Trust)
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/brand/outbound.dart';

void main() {
  test('the line says we may earn, and that it never changes what we suggest', () {
    expect(kPvCommissionLine, contains('We may earn a commission'));
    expect(kPvCommissionLine, contains('never changes'));
  });

  test('the retailer button goes through openOutbound and carries the line', () {
    final src = File('lib/screens/products/pv_product_screen.dart').readAsStringSync();
    final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
    expect(live, contains('await openOutbound(url, productId: p.id)'));
    expect(live.contains('launchUrl('), isFalse, reason: 'no second way out');
    expect(live, contains("ValueKey('pv_product_commission')"));
  });

  test('a link out to Amazon carries the partner tag', () {
    final out = tagged(Uri.parse('https://www.amazon.in/s?k=baby+carrier'));
    expect(out.queryParameters['tag'], isNotEmpty);
  });
}
