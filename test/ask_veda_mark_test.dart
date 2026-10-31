// =============================================================================
//  The Ask Veda mark (Aurora, 2026-10-24) is ONE widget on every Ask Veda
//  surface: the FAB, the three Ask Veda screens, every "Ask Veda" row and
//  every search way-on row.
//
//  What this holds:
//    * the mark paints at a row size, a button size and the FAB size;
//    * it runs no ticker when the phone asks for reduced motion (and under
//      `flutter test` by default, so the FAB never breaks pumpAndSettle);
//    * it moves when allowed to;
//    * the FAB draws it;
//    * the wiring gate: every Ask Veda site still names `AskVedaMark(`, and
//      the files that are only Ask Veda have no live sparkle left in them.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ask_veda/ask_veda_mark.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';

/// Every file that draws the Ask Veda mark today (the 2026-10-24 audit).
const _sites = [
  'lib/widgets/global_ask_fab.dart',
  'lib/screens/post_pregnancy/pp_section_extras.dart',
  'lib/ask_veda/ask_veda_search_shell.dart',
  'lib/screens/tools/ask_veda_screen.dart',
  'lib/screens/post_pregnancy/askveda_screen.dart',
  'lib/screens/ttc/ttc_askveda_screen.dart',
  'lib/screens/global_search.dart',
  'lib/screens/tools_hub_screen.dart',
  'lib/screens/can_i_screen.dart',
  'lib/screens/report_screen.dart',
  'lib/screens/can_i/can_i_verdict_screen.dart',
  'lib/screens/nutrition/door/need_screen.dart',
  'lib/screens/garbh_screen.dart',
  'lib/screens/mind_mood/mm_talk_tab.dart',
  'lib/screens/product_guide/product_guide_screen.dart',
  'lib/screens/post_pregnancy/my_child_screen.dart',
  'lib/screens/post_pregnancy/pp_common.dart',
  'lib/screens/post_pregnancy/post_pregnancy_home.dart',
  'lib/screens/post_pregnancy/food_recipe_screen.dart',
  'lib/screens/post_pregnancy/watch_player_screen.dart',
  'lib/screens/post_pregnancy/watch_quicklearn_screen.dart',
  'lib/screens/post_pregnancy/watch_shorts_screen.dart',
  'lib/screens/post_pregnancy/reco_detail_screen.dart',
  'lib/screens/ttc/ttc_chapter_screen.dart',
  'lib/screens/ttc/ttc_partner_screen.dart',
  'lib/screens/ttc/ttc_tests_screen.dart',
  'lib/screens/home_focus_screen.dart',
  'lib/screens/doors/pv_door_screen.dart',
  'lib/screens/post_pregnancy/doors/pp_door_screen.dart',
  'lib/screens/ttc/doors/ttc_door_screen.dart',
  'lib/screens/post_pregnancy/pp_search.dart',
  'lib/screens/post_pregnancy/pp_tools_tab.dart',
  'lib/screens/ttc/ttc_learn_screen.dart',
  'lib/screens/ttc/ttc_tools_screen.dart',
  'lib/screens/pregnancy/preg_learn_screen.dart',
  'lib/screens/can_i/can_i_door.dart',
  'lib/screens/search/pv_search_screen.dart',
  'lib/screens/reader/pv_reader_screen.dart',
  'lib/screens/profile/pv_you_screen.dart',
];

/// Files that are only Ask Veda: no sparkle may be left live in them. The
/// parenting screen keeps one, as the fallback for the ParentVeda logo image.
const _vedaOnly = {
  'lib/widgets/global_ask_fab.dart': <String>[],
  'lib/screens/tools/ask_veda_screen.dart': ['_ => Icons.auto_awesome_rounded'],
  'lib/screens/post_pregnancy/askveda_screen.dart': ["errorBuilder: (_, _, _) => const Icon(Icons.auto_awesome_rounded, size: 26"],
  'lib/screens/ttc/ttc_askveda_screen.dart': <String>[],
};

/// The live (not commented-out) part of a line.
String _live(String line) {
  final i = line.indexOf('//');
  return i == -1 ? line : line.substring(0, i);
}

void main() {
  for (final size in [16.0, 24.0, 56.0]) {
    testWidgets('the mark paints at $size', (t) async {
      await t.pumpWidget(Center(child: AskVedaMark(size: size)));
      expect(t.getSize(find.byType(AskVedaMark)), Size.square(size));
    });
  }

  testWidgets('reduced motion: no ticker, so pumpAndSettle completes', (t) async {
    AskVedaMark.debugAnimateInTests = true;
    addTearDown(() => AskVedaMark.debugAnimateInTests = false);
    await t.pumpWidget(const MediaQuery(
      data: MediaQueryData(disableAnimations: true),
      child: Center(child: AskVedaMark(size: 56)),
    ));
    await t.pumpAndSettle();
    expect(t.hasRunningAnimations, isFalse);
  });

  testWidgets('allowed to move, it moves; small, it stays still', (t) async {
    AskVedaMark.debugAnimateInTests = true;
    addTearDown(() => AskVedaMark.debugAnimateInTests = false);
    await t.pumpWidget(const Center(child: AskVedaMark(size: 56)));
    await t.pump(const Duration(milliseconds: 100));
    expect(t.hasRunningAnimations, isTrue);

    await t.pumpWidget(const Center(child: AskVedaMark(size: 16)));
    await t.pump();
    expect(t.hasRunningAnimations, isFalse, reason: 'under 18pt the drift is invisible');
  });

  testWidgets('under flutter test it stays still by default', (t) async {
    await t.pumpWidget(const Center(child: AskVedaMark(size: 56)));
    await t.pumpAndSettle();
    expect(t.hasRunningAnimations, isFalse);
  });

  testWidgets('the FAB draws the Ask Veda mark', (t) async {
    final c = PregnancyController();
    addTearDown(c.dispose);
    FabState.instance.markAppLive();
    await t.pumpWidget(MaterialApp(
      home: Stack(fit: StackFit.expand, children: [
        const SizedBox.expand(),
        GlobalAskFab(pregnancy: c),
      ]),
    ));
    await t.pump();
    if (!FabState.instance.visible) return; // the FAB is switched off app-wide
    expect(
      find.descendant(of: find.byType(GlobalAskFab), matching: find.byType(AskVedaMark)),
      findsOneWidget,
    );
  });

  test('wiring gate: every Ask Veda site draws AskVedaMark', () {
    final missing = [
      for (final f in _sites)
        if (!File(f).readAsStringSync().contains('AskVedaMark(')) f,
    ];
    expect(missing, isEmpty, reason: 'these Ask Veda sites lost the mark');
  });

  test('no live sparkle is left in the Ask Veda-only files', () {
    final left = <String>[];
    _vedaOnly.forEach((f, allowed) {
      final lines = File(f).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final live = _live(lines[i]);
        if (!live.contains('Icons.auto_awesome')) continue;
        if (allowed.any(live.contains)) continue;
        left.add('$f:${i + 1}: ${lines[i].trim()}');
      }
    });
    expect(left, isEmpty, reason: 'draw AskVedaMark, not the stock sparkle');
  });
}
