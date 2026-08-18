// =============================================================================
//  The bottom bar — one component, and it stays one
// -----------------------------------------------------------------------------
//  ⚠️ THIS FILE EXISTS BECAUSE OF HOW THE NAV ACTUALLY WENT WRONG, WHICH WAS
//  NOT A DESIGN MISTAKE.
//
//  Every rule was written down and agreed. Then the app grew three bottom bars,
//  each was fixed once by a different pass, and each ended up with a DIFFERENT
//  HALF of the same fix:
//
//    pregnancy   container removed  ·  still re-flowed the row on tap
//    parenting   reflow fixed       ·  still drew a filled disc
//    TTC         neither
//
//  The parenting bar had even diagnosed the reflow in its own comment — and
//  ended that comment with "PARENTING ONLY. The pregnancy bar is deliberately
//  untouched."
//
//  So the thing worth testing is not the rules. It is that there is ONE
//  implementation for them to be true of. A rule written in three places is a
//  rule that will be true in two.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/theme/app_theme.dart';
import 'package:parentveda/widgets/pv_nav_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const items = [
    PvNavItem(Icons.home_rounded, 'Today'),
    PvNavItem(Icons.school_rounded, 'Prepare'),
    PvNavItem(Icons.widgets_rounded, 'Tools'),
    PvNavItem(Icons.calendar_today_rounded, 'Calendar'),
    PvNavItem(Icons.groups_rounded, 'Community'),
  ];

  Widget host(int active) => MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: PvNavBar(
                items: items, activeIndex: active, onTap: (_) {}),
          ),
        ),
      );

  group('nothing moves when you switch tabs', () {
    // ⚠️ THE RULE THE USER CAUGHT ON A PHONE. Two of the three bars made the
    // active tab a horizontal pill, so selecting a tab re-flowed the row and
    // the other four labels slid sideways. Colour is the only thing that may
    // change.
    testWidgets('every label sits in the same place, whichever tab is active',
        (tester) async {
      final positions = <int, List<Offset>>{};

      for (final active in [0, 2, 4]) {
        await tester.pumpWidget(host(active));
        await tester.pumpAndSettle();
        positions[active] = [
          for (final it in items) tester.getCenter(find.text(it.label)),
        ];
      }

      for (final a in [2, 4]) {
        for (var i = 0; i < items.length; i++) {
          expect((positions[a]![i] - positions[0]![i]).distance, lessThan(0.5),
              reason: 'label "${items[i].label}" moved when tab $a became '
                  'active — the bar must not re-flow');
        }
      }
    });

    testWidgets('every label is visible in every state', (tester) async {
      for (final active in [0, 4]) {
        await tester.pumpWidget(host(active));
        await tester.pumpAndSettle();
        for (final it in items) {
          expect(find.text(it.label), findsOneWidget, reason: it.label);
        }
      }
    });
  });

  group('no container behind the active tab', () {
    // A filled violet shape parked on every screen at all times is how `action`
    // stops meaning "you can act on this". The active state is ink and weight.
    testWidgets('no decoration is filled with the accent', (tester) async {
      await tester.pumpWidget(host(0));
      await tester.pumpAndSettle();

      final accent = AppTheme.primary600;
      final filled = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.color == accent;
      });
      expect(filled, isEmpty,
          reason: 'a container is filled with the accent — §4.9 says the '
              'active tab gets colour and weight, not a box');
    });
  });

  group('the active tab is marked TWICE', () {
    testWidgets('colour and weight both change', (tester) async {
      await tester.pumpWidget(host(0));
      await tester.pumpAndSettle();

      TextStyle styleOf(String label) {
        final t = tester.widget<Text>(find.text(label));
        return t.style ??
            DefaultTextStyle.of(
                    tester.element(find.text(label)))
                .style;
      }

      final on = styleOf('Today');
      final off = styleOf('Tools');

      expect(on.color, isNot(equals(off.color)), reason: 'colour must change');
      expect(on.fontWeight, isNot(equals(off.fontWeight)),
          reason: 'weight must change — colour alone is not enough');
    });
  });

  group('the inactive label is readable', () {
    // It was `neutral400` — 2.73:1 on our ground, against a WCAG AA floor of
    // 4.5:1, on the most-seen text in the app. This asserts the ramp value
    // rather than the rendered colour, because the rendered one is mid-tween.
    test('neutral600 clears AA on the app ground', () {
      double lin(int c) {
        final v = c / 255;
        return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
      }

      double y(Color c) =>
          0.2126 * lin((c.r * 255).round()) +
          0.7152 * lin((c.g * 255).round()) +
          0.0722 * lin((c.b * 255).round());

      double ratio(Color a, Color b) {
        final ya = y(a), yb = y(b);
        final hi = ya > yb ? ya : yb;
        final lo = ya > yb ? yb : ya;
        return (hi + 0.05) / (lo + 0.05);
      }

      final r = ratio(AppTheme.neutral600, AppTheme.scaffoldBackground);
      expect(r, greaterThanOrEqualTo(4.5),
          reason: 'inactive nav labels measure ${r.toStringAsFixed(2)}:1 — '
              'WCAG AA needs 4.5:1 for text this size');
    });
  });
}
