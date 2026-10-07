// =============================================================================
//  "Aarav ▾": the child switch on the home, only with two or more (gap P2)
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_switch.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';

Widget _host() => MaterialApp(
    home: Scaffold(body: Center(child: PpChildSwitch(p: V2PaletteStore.instance.current))));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
  });

  testWidgets('one child: nothing drawn', (t) async {
    await t.pumpWidget(_host());
    expect(find.byKey(const ValueKey('pp_child_switch')), findsNothing);
  });

  testWidgets('two children: the name, the sheet, and the switch', (t) async {
    final store = ChildProfileStore.instance;
    final a = await store.addChild(name: 'Aarav', isBoy: true, dob: DateTime(2025, 1, 5));
    final b = await store.addChild(name: 'Meera', isBoy: false, dob: DateTime(2026, 6, 29));
    await store.switchTo(a.id);
    await t.pumpWidget(_host());
    expect(find.text('Aarav'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('pp_child_switch')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('pp_child_switch_add')), findsOneWidget);
    await t.tap(find.byKey(ValueKey('pp_child_switch_${b.id}')));
    await t.pumpAndSettle();
    expect(store.active.id, b.id);
  });

  test('wired into the home hero', () {
    expect(File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync(), contains('PpChildSwitch(p: p)'));
  });
}
