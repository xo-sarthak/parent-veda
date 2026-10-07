// =============================================================================
//  First 40 days: Din by din follows the day (gap analysis P2)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_din_by_din.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final area = ppSectionFor('parenting_first_40')!.areas.firstWhere((a) => a.id == kPpDinTabId);

  test('one line for each of the 40 days', () {
    expect(kPpDinLines, hasLength(40));
    expect(ppDinToday(kPpDinTabId, day: 1)!.line, kPpDinLines.first);
    expect(ppDinToday(kPpDinTabId, day: 41), isNull);
    expect(ppDinToday('ceremonies', day: 5), isNull);
  });

  test('her day range leads the rail', () {
    expect(ppDinOrder(area.pages, day: 3).first.id, 'f40_days_1_7');
    expect(ppDinOrder(area.pages, day: 12).first.id, 'f40_days_8_15');
    expect(ppDinOrder(area.pages, day: 20).first.id, 'f40_days_16_30');
    expect(ppDinOrder(area.pages, day: 35).first.id, 'f40_days_31_40');
    expect(ppDinOrder(area.pages, day: 45).first.id, kPpDinAfterPageId);
    expect(ppDinOrder(area.pages, day: 12), hasLength(area.pages.length), reason: 'nothing dropped');
  });

  testWidgets('day 12 on the door: the card and the line', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 11)));
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(home: _Door())));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('pp_din_today')), findsOneWidget);
    expect(find.text('DAY 12 OF 40'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}

class _Door extends StatelessWidget {
  const _Door();
  @override
  Widget build(BuildContext context) =>
      PpDoorScreen(door: ppDoorFor('parenting_first_40')!, onSurface: (_, _) {}, initialTabId: kPpDinTabId);
}
