// PvPress at scale (tap feedback second pass, 2026-10-15): a scroll is not a
// press, and only the innermost press settles.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/widgets/pv_feedback.dart';

double _scaleOf(WidgetTester tester, Key key) => tester
    .widget<AnimatedScale>(find.descendant(of: find.byKey(key), matching: find.byType(AnimatedScale)).first)
    .scale;

void main() {
  testWidgets('a press settles while down and lets go on lift', (tester) async {
    const k = Key('card');
    await tester.pumpWidget(MaterialApp(
        home: Center(child: PvPress(key: k, child: GestureDetector(onTap: () {}, child: const ColoredBox(color: Colors.white, child: SizedBox(width: 200, height: 100)))))));
    final g = await tester.startGesture(tester.getCenter(find.byKey(k)));
    await tester.pump();
    expect(_scaleOf(tester, k), 0.98);
    await g.up();
    await tester.pump();
    expect(_scaleOf(tester, k), 1);
  });

  testWidgets('a scroll is not a press: moving past the slop lets go', (tester) async {
    const k = Key('card');
    await tester.pumpWidget(MaterialApp(
        home: Center(child: PvPress(key: k, child: GestureDetector(onTap: () {}, child: const ColoredBox(color: Colors.white, child: SizedBox(width: 200, height: 100)))))));
    final g = await tester.startGesture(tester.getCenter(find.byKey(k)));
    await tester.pump();
    expect(_scaleOf(tester, k), 0.98);
    await g.moveBy(const Offset(0, kTouchSlop + 4));
    await tester.pump();
    expect(_scaleOf(tester, k), 1, reason: 'the finger is scrolling, not pressing');
    await g.up();
  });

  testWidgets('only the innermost press settles', (tester) async {
    const outer = Key('outer');
    const inner = Key('inner');
    await tester.pumpWidget(MaterialApp(
        home: Center(
            child: PvPress(
                key: outer,
                child: GestureDetector(
                    onTap: () {},
                    child: Container(
                        color: Colors.white,
                        width: 300,
                        height: 200,
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: PvPress(
                                key: inner,
                                child: GestureDetector(onTap: () {}, child: const ColoredBox(color: Colors.black, child: SizedBox(width: 40, height: 40)))))))))));
    // On the inner icon: the icon settles, the card does not.
    var g = await tester.startGesture(tester.getCenter(find.byKey(inner)));
    await tester.pump();
    expect(_scaleOf(tester, inner), 0.98);
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale).first).scale, 1, reason: 'the card stays still');
    await g.up();
    await tester.pump();
    // On the card away from the icon: the card settles.
    g = await tester.startGesture(tester.getBottomRight(find.byKey(outer)) - const Offset(10, 10));
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale).first).scale, 0.98);
    await g.up();
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale).first).scale, 1);
  });
}
