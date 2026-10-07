// =============================================================================
//  RemedyListScreen + RemedyDetailScreen on the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  Holds the redraw: both pages on the shared tool shell, the "not medical
//  advice, a doctor comes first" line on the list, the red-flag block and the
//  honest "Written by our team ... Not yet reviewed by a doctor" line on every
//  remedy, no "signed off" / "Validated by" claim and no named reviewer, and
//  no overflow at 360dp at 1x and 1.5x text, for EVERY situation and EVERY
//  remedy (a shared layout is checked on each item, not one sample).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_nuskhe_data.dart';
import 'package:parentveda/screens/post_pregnancy/remedy_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/remedy_list_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart' show PregToolScaffold;

Future<void> _pump(WidgetTester t, Widget screen, double scale) async {
  t.view.physicalSize = const Size(360 * 3, 2400 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: const Size(360, 2400), textScaler: TextScaler.linear(scale)),
      child: screen,
    ),
  ));
  await t.pumpAndSettle();
}

String _allText(WidgetTester t) => t
    .widgetList<Text>(find.byType(Text, skipOffstage: false))
    .map((w) => w.data ?? w.textSpan?.toPlainText() ?? '')
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  for (final scale in const [1.0, 1.5]) {
    testWidgets('every situation list fits 360dp at ${scale}x, safety line first', (t) async {
      for (final c in kNuskheCategories) {
        await _pump(t, RemedyListScreen(category: c.name), scale);
        expect(t.takeException(), isNull, reason: c.name);
        expect(find.byType(PregToolScaffold), findsOneWidget);
        expect(find.byKey(const ValueKey('remedy_list_safety')), findsOneWidget);
        expect(find.textContaining('not medical advice'), findsOneWidget);
        final all = _allText(t);
        expect(all, isNot(contains('reviewed')), reason: c.name);
        expect(all, isNot(contains('signed off')), reason: c.name);
      }
    });

    testWidgets('every remedy detail fits 360dp at ${scale}x, written-by line present', (t) async {
      for (final r in kRemedies) {
        await _pump(t, RemedyDetailScreen(remedy: r), scale);
        expect(t.takeException(), isNull, reason: r.id);
        expect(find.byType(PregToolScaffold), findsOneWidget);

        final scroll = find.byType(Scrollable).first;
        await t.scrollUntilVisible(find.byKey(const ValueKey('remedy_red_flags')), 400, scrollable: scroll);
        await t.scrollUntilVisible(find.byKey(const ValueKey('remedy_written_by')), 400, scrollable: scroll);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: r.id);
        expect(find.byKey(const ValueKey('remedy_find_doctor')), findsOneWidget);
        expect(
            find.textContaining('Written by our team from published guidance. Not yet reviewed by a doctor.'),
            findsOneWidget,
            reason: r.id);

        final all = _allText(t);
        expect(all, isNot(contains('signed off')), reason: r.id);
        expect(all, isNot(contains('Validated by')), reason: r.id);
        expect(all, isNot(contains('BAMS')), reason: r.id);
      }
    });
  }
}
