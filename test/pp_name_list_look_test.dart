// =============================================================================
//  The baby-name browse list in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  NameListScreen is a pushed list page as pregnancy draws one: the serif
//  title, a stadium search, ink chips for the filters the naming home promises
//  (who, community, region), and the names as unboxed rows. A filter narrows
//  the count; nothing overflows at 360dp and 1.5x text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/doors/pv_list_row.dart';
import 'package:parentveda/screens/post_pregnancy/name_list_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_names_data.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: no overflow, a filter narrows the list', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        home: const NameListScreen(),
      ));
      await t.pumpAndSettle();
      expect(find.text('Take your time'), findsOneWidget);
      expect(find.byType(PvListRow), findsWidgets);
      expect(find.text('${kBabyNames.length} names'), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.tap(find.text('Girl'));
      await t.pumpAndSettle();
      final girls = namesFiltered(gender: 'Girl').length;
      expect(find.text('$girls names'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
