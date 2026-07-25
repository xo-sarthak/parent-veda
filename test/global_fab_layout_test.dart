// =============================================================================
//  The global Ask-Veda FAB must never collapse the app it floats over
// -----------------------------------------------------------------------------
//  GlobalAskFab is stacked over the WHOLE app in MaterialApp.builder. It used to
//  return a bare SizedBox.shrink() when hidden - a zero-sized NON-positioned
//  child - which collapsed the enclosing loose Stack to 0x0 and rendered the
//  entire app at zero size: a completely black screen.
//
//  Because the FAB hides itself on every PopupRoute, that black screen appeared
//  over the Ask Veda screen, the Premiere takeover, and EVERY modal bottom sheet
//  and dialog in both apps. It looked like a renderer/Impeller bug; it was
//  layout. These tests pin the invariant so it cannot come back.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';

/// The ORIGINAL, unforgiving shape: a plain Stack under LOOSE constraints (a
/// Center loosens them exactly like being a non-positioned child of the outer
/// Stack in main.dart did), with the app as a Positioned.fill. Here the hidden
/// FAB is the only thing that can decide the Stack's size - so this shell fails
/// outright if the FAB ever goes back to a bare SizedBox.shrink().
Widget _looseShell(PregnancyController c, Widget child) => MaterialApp(
      home: Center(
        child: Stack(children: [
          Positioned.fill(child: child),
          GlobalAskFab(pregnancy: c),
        ]),
      ),
    );

/// The shape main.dart uses today: StackFit.expand belt-and-braces on top.
Widget _appShell(PregnancyController c, Widget child) => MaterialApp(
      home: Stack(fit: StackFit.expand, children: [
        Offstage(
          offstage: false,
          child: Stack(fit: StackFit.expand, children: [
            child,
            GlobalAskFab(pregnancy: c),
          ]),
        ),
      ]),
    );

void main() {
  const key = ValueKey('app-content');
  final content = Container(key: key, color: const Color(0xFFFBF9FE));

  testWidgets('the app fills the screen while the FAB is HIDDEN', (t) async {
    final c = PregnancyController();
    addTearDown(c.dispose);

    // Default state: not live yet -> FAB hidden. This is the case that used to
    // black the screen out.
    expect(FabState.instance.visible, isFalse);

    await t.pumpWidget(_looseShell(c, content));
    await t.pump();

    final size = t.getSize(find.byKey(key));
    expect(size, t.view.physicalSize / t.view.devicePixelRatio,
        reason: 'the app collapsed while the FAB was hidden - black screen');
    expect(size.width, greaterThan(0));
    expect(size.height, greaterThan(0));
  });

  testWidgets('the app still fills the screen while the FAB is SHOWN',
      (t) async {
    final c = PregnancyController();
    addTearDown(c.dispose);

    FabState.instance.markAppLive();
    expect(FabState.instance.visible, isTrue);

    await t.pumpWidget(_appShell(c, content));
    await t.pump();

    expect(t.getSize(find.byKey(key)),
        t.view.physicalSize / t.view.devicePixelRatio);
  });

  testWidgets('a hidden FAB is a Positioned child, never a bare SizedBox',
      (t) async {
    final c = PregnancyController();
    addTearDown(c.dispose);

    await t.pumpWidget(_appShell(c, content));
    await t.pump();

    // Whatever the FAB renders while hidden must be positioned, otherwise it
    // participates in sizing its parent Stack and can collapse it.
    final fab = find.descendant(
      of: find.byType(GlobalAskFab),
      matching: find.byType(Positioned),
    );
    expect(fab, findsOneWidget);
  });
}
