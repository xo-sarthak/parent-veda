// Basic smoke test for the ParentVeda Week-on-Week Card Stack.

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/main.dart';

void main() {
  testWidgets('App boots and shows the ParentVeda app bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ParentVedaApp());

    // Let the async content load + first frames settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // The AppBar brand title should be visible once booted.
    expect(find.text('ParentVeda'), findsOneWidget);
  });
}
