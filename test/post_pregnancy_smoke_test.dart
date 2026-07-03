// Smoke test: the post-pregnancy My Child home must build without throwing
// (catches layout/overflow errors before running on a device).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/post_pregnancy_home.dart';
import 'package:parentveda/screens/post_pregnancy/product_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/products_discovery_screen.dart';

void main() {
  final screens = <String, Widget>{
    'My Child home': const PostPregnancyHome(),
    'Products discovery': const ProductsDiscoveryScreen(),
    'Product detail': const ProductDetailScreen(),
  };

  screens.forEach((name, screen) {
    testWidgets('$name builds without throwing', (tester) async {
      // Size close to a real phone so rail/overflow behaviour is realistic.
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
