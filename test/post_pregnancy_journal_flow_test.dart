// Functional test for the My Journal V2 Storybook reader: page through every
// template (catches overflow in the new full-bleed/monthly/collage/quote pages),
// open the Contents nav sheet and jump, and toggle immersive full-screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/journal_v2/journal_storybook_screens.dart';

void main() {
  testWidgets('Storybook reader: page through, nav sheet, immersive', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: StorybookReaderScreen()));
    await tester.pump();
    expect(find.text('1 / 13'), findsOneWidget);

    // walk to the last page - builds every page template on the way
    for (var i = 0; i < 12; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('13 / 13'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // open the Contents / Bookmarks sheet and jump to a chapter
    await tester.tap(find.text('Contents'));
    await tester.pumpAndSettle();
    expect(find.text('Bookmarks'), findsOneWidget);
    await tester.tap(find.text('Tiny Beginnings').first);
    await tester.pumpAndSettle();

    // tap a page to enter immersive full-screen (chrome fades)
    await tester.tap(find.byType(PageView));
    await tester.pump(const Duration(milliseconds: 260));
    expect(tester.takeException(), isNull);
  });
}
