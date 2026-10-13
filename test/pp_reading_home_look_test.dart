// =============================================================================
//  The parenting reads library in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  ReadingHomeScreen (More > All reads) is drawn as pregnancy draws a pushed
//  library page: serif title, section headings, ink chips, reads as unboxed
//  rows, shelves of PvShelfCard. The type filter still narrows; nothing
//  overflows at 360dp and 1.5x text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/doors/pv_list_row.dart';
import 'package:parentveda/screens/post_pregnancy/reading_home_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: no overflow, the type filter narrows', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        home: const ReadingHomeScreen(),
      ));
      await t.pumpAndSettle();
      expect(find.text('What to read today'), findsOneWidget);
      expect(find.byType(PvListRow), findsWidgets);
      expect(t.takeException(), isNull);

      await t.scrollUntilVisible(find.text('Book Summaries'), 300,
          scrollable: find.byType(Scrollable).first, maxScrolls: 40);
      await t.ensureVisible(find.text('Book Summaries'));
      await t.pumpAndSettle();
      await t.tap(find.text('Book Summaries'));
      await t.pumpAndSettle();
      // Filtered: the count line names the filter.
      // 31 book companions (2026-10-13) lengthen the list, so the count line
      // can sit above the viewport after the scroll: scroll back up to it.
      await t.scrollUntilVisible(find.textContaining('All topics · Book Summaries'), -300,
          scrollable: find.byType(Scrollable).first, maxScrolls: 40);
      expect(find.textContaining('All topics · Book Summaries'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
