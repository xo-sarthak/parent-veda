// =============================================================================
//  Health record, Emergency card and Milestones in the house look (2026-10-21,
//  Wave 3). The user: these still had "the old purple UI", and "i dont need
//  lavender color background at all". This pumps each screen and fails if a
//  fill, a border or an icon is lavender or violet. Violet text is allowed: the
//  small-caps eyebrows keep it on purpose.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/health_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/milestone_journey_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_common.dart';
import 'package:parentveda/screens/post_pregnancy/wallet_v2_screens.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

/// The old look, by value: the lavender greys (old ppPanel, the old live
/// surfaceAlt, the old borders and hairlines, the old Language tint) and the
/// violet.
const _lavender = {
  0xFFEDEAF0,
  0xFFF4F2F6,
  0xFFEAE7EE,
  0xFFE7DFEE,
  0xFFEFEAF2,
  0xFFEDEAF7,
  0xFFF3ECFA,
  0xFFF3EEF7,
};
const _violet = 0xFF6A30B6;

List<String> _oldLook(WidgetTester t) {
  final hits = <String>[];
  void fill(Color? c, String where) {
    if (c == null) return;
    final v = c.toARGB32();
    if (_lavender.contains(v) || v == _violet) hits.add('$where $c');
  }

  for (final w in t.widgetList(find.byWidgetPredicate((_) => true, skipOffstage: false))) {
    if (w is Container) {
      fill(w.color, 'Container');
      final d = w.decoration;
      if (d is BoxDecoration) {
        fill(d.color, 'fill');
        final b = d.border;
        if (b is Border) fill(b.top.color, 'border');
      }
    } else if (w is DecoratedBox) {
      final d = w.decoration;
      if (d is BoxDecoration) fill(d.color, 'fill');
    } else if (w is Icon) {
      fill(w.color, 'icon ${w.icon}');
    } else if (w is ColoredBox) {
      fill(w.color, 'ColoredBox');
    }
  }
  return hits;
}

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(360 * 3, 2600 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump(const Duration(milliseconds: 800));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 210)));
  });

  test('the panel colours are a plain neutral, not lavender', () {
    expect(_lavender.contains(ppPanel.toARGB32()), isFalse);
    expect(ppPanel, const Color(0xFFF3F3F4));
  });

  testWidgets('Health record: the tool shell, records first, no old colour', (t) async {
    await _pump(t, const HealthHomeScreen());
    expect(find.byType(PregToolScaffold), findsOneWidget);
    for (final k in ['visits', 'medications', 'prescriptions', 'reports', 'symptoms', 'allergies']) {
      expect(find.byKey(ValueKey('pp_health_rec_$k')), findsOneWidget, reason: k);
    }
    expect(_oldLook(t), isEmpty);
    expect(t.takeException(), isNull);
  });

  testWidgets('Emergency card: sections, an Add on each empty one, no old colour', (t) async {
    await _pump(t, const WalletEmergencyCardScreen());
    expect(find.byType(PregToolScaffold), findsOneWidget);
    for (final s in ['Allergies', 'Medicines', 'Paediatrician', 'Call first']) {
      expect(find.byKey(ValueKey('pp_emergency_section_$s')), findsOneWidget, reason: s);
    }
    expect(find.byKey(const ValueKey('pp_emergency_share')), findsOneWidget);
    expect(find.textContaining('112'), findsWidgets, reason: 'the numbers stay printed');
    expect(_oldLook(t), isEmpty);
    expect(t.takeException(), isNull);
  });

  testWidgets('Milestones: the cards and the page carry no old colour', (t) async {
    await _pump(t, const MilestoneJourneyScreen());
    // The flip cards went with R10 (2026-10-26); the journey is the one
    // Milestones place now. Was: find.byType(MilestoneFlipCard), findsWidgets.
    expect(find.byType(PpMilestonesScreen), findsOneWidget);
    expect(_oldLook(t), isEmpty);
    expect(t.takeException(), isNull);
  });
}
