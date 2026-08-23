// =============================================================================
//  The tools a bracket declares must actually be drawn
// -----------------------------------------------------------------------------
//  ⚠️ THIS FILE EXISTS BECAUSE SEVENTEEN TOOLS WERE INVISIBLE AND NOTHING
//  NOTICED.
//
//  Tools used to render on `PpSectionScreen`. They were moved up to
//  `ProblemHubScreen` on explicit feedback ("bring it out on main Sleep
//  section"), and the section's block was commented out. That was right for
//  the seven parenting brackets that render a hub screen.
//
//  Four do not. `hub_registry.dart` sends a bracket with ONE door straight to
//  that door's destination, skipping the hub entirely — so Behaviour, Health,
//  First 40 Days and Traditional had their tools declared on one screen and
//  drawn on another they never reach. 2 + 9 + 4 + 2 = 17.
//
//  ⚠️ WHY NOTHING CAUGHT IT. Every existing guard asked a different question:
//  "does this tool's surface resolve?" (yes), "does it compile?" (yes), "does
//  the hub render its tools?" (yes, when a hub renders at all). Reachability
//  was never asserted, and reachability was the only thing broken. This is the
//  wiring gate in its purest form: correct code, wired to nothing. A source
//  scan would also have passed — against the commented-out block.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/hubs/hub_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';

/// Pump the section on a surface tall enough to lay the whole page out.
///
/// ⚠️ A TALL VIEWPORT INSTEAD OF SCROLLING, AND THREE FAILED ATTEMPTS SAY WHY.
/// `dragUntilVisible` was tried against `SingleChildScrollView` (zero matches —
/// the only one here is the conditional band-chip strip), then bare `ListView`
/// (two on Health), then `Scrollable.first` (exhausts its iterations when a
/// label also appears higher up the page). Every one of those reported itself
/// as *missing content*, which is exactly how a widget test lies about what it
/// proved — it would have been easy to "fix the bug" that was never there.
///
/// A `ListView` builds what fits its viewport, so making the viewport twelve
/// thousand pixels tall builds all of it and removes scrolling from the test
/// entirely. What is being asserted is that the widget is DRAWN, not that a
/// parent can reach it by a particular gesture.
Future<void> _pumpFull(WidgetTester tester, PpSection section) async {
  tester.view.physicalSize = const Size(1200, 12000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: PpSectionScreen(section: section, onSurface: (_, _) {}),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // The four that skip the hub. Named explicitly rather than derived, so the
  // day one of them gains a second door THIS list is what fails and asks
  // whether the move was intended — rather than the tools silently changing
  // which screen draws them.
  const skipsHub = [
    'parenting_behaviour',
    'parenting_health',
    'parenting_first_40',
    'parenting_traditional',
  ];

  group('a bracket with no hub screen draws its own tools', () {
    test('those four really do skip the hub screen', () {
      for (final id in skipsHub) {
        expect(showsHubScreen(id), isFalse,
            reason: '$id now renders a hub; move it out of this list and check '
                'its tools are not drawn twice');
      }
    });

    for (final id in skipsHub) {
      testWidgets('$id draws every tool it declares', (tester) async {
        final section = ppSectionFor(id);
        expect(section, isNotNull, reason: id);
        if (section!.tools.isEmpty) return;

        await _pumpFull(tester, section);

        expect(find.text('TOOLS'), findsOneWidget,
            reason: '$id has ${section.tools.length} tools and no hub screen '
                'to draw them on');

        for (final t in section.tools) {
          // ⚠️ `findsWidgets`, NOT `findsOneWidget`. First 40 Days names a tool
          // "Puchho ParentVeda" and also names a page that, so an exactly-one
          // assertion fails on a duplicate that is not a defect. The claim
          // being made is "this is on the screen", and that is what is checked.
          expect(find.text(t.label), findsWidgets,
              reason: '$id declares the tool "${t.label}" and draws it nowhere');
        }
      });
    }
  });

  group('a bracket that HAS a hub screen does not draw them twice', () {
    testWidgets('sleep leaves its tools to the hub', (tester) async {
      expect(showsHubScreen('parenting_sleep'), isTrue);
      final section = ppSectionFor('parenting_sleep')!;
      expect(section.tools, isNotEmpty);

      await _pumpFull(tester, section);

      // The heading must be absent entirely. If this ever fails, a parent is
      // being offered the sleep log twice on two consecutive screens — the
      // duplicate-door shape this review already fixed three times.
      expect(find.text('TOOLS'), findsNothing,
          reason: 'parenting_sleep renders a hub screen, which already draws '
              'these tools');
    });
  });

  group('the expert offer', () {
    testWidgets('behaviour offers a child psychologist', (tester) async {
      final closing = hubFor('parenting_behaviour')?.closing;
      expect(closing, isNotNull,
          reason: 'behaviour is the one-door bracket with real psychologist '
              'supply behind it, so its closing offer is live config now');
      expect(closing!.surfaceId, 'pp_experts/Child psychologist');

      await _pumpFull(tester, ppSectionFor('parenting_behaviour')!);
      expect(find.text(closing.label.en), findsOneWidget);
    });

    testWidgets('sleep does not draw a closing here — the hub does that',
        (tester) async {
      await _pumpFull(tester, ppSectionFor('parenting_sleep')!);
      final closing = hubFor('parenting_sleep')!.closing!;
      expect(find.text(closing.label.en), findsNothing);
    });
  });
}
