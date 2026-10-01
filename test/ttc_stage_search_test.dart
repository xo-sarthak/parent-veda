// Ask Veda as the trying-to-conceive side's search (2026-09-30, the user: "I
// can search for anything inside the trying to conceive side of the app").
// The stage search finds the stage's own things as she types, each hit opens
// its real screen, and the Ask Veda screen shows the hits with one row that
// asks the whole question. The floating button is back on this stage only.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_askveda_screen.dart';
import 'package:parentveda/screens/ttc/ttc_stage_search.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the index', () {
    test('nothing under two letters', () {
      expect(ttcStageSearch(''), isEmpty);
      expect(ttcStageSearch('c'), isEmpty);
    });

    test('"chai" finds the Can I answer about chai', () {
      final hits = ttcStageSearch('chai');
      expect(
        hits.any((h) =>
            h.kind == TtcStageHitKind.canI && h.title.toLowerCase().contains('chai')),
        isTrue,
      );
    });

    test('"fertile window" finds its topic and its tool', () {
      final hits = ttcStageSearch('fertile window');
      expect(hits.any((h) => h.kind == TtcStageHitKind.door), isTrue);
      expect(hits.any((h) => h.kind == TtcStageHitKind.tool), isTrue);
    });

    test('"pregnancy test" finds articles', () {
      final hits = ttcStageSearch('pregnancy test');
      expect(hits.where((h) => h.kind == TtcStageHitKind.article), isNotEmpty);
    });

    test('at most four of each kind, title matches first', () {
      final hits = ttcStageSearch('test');
      for (final k in TtcStageHitKind.values) {
        final of = hits.where((h) => h.kind == k).toList();
        expect(of.length, lessThanOrEqualTo(4), reason: k.name);
        for (var i = 1; i < of.length; i++) {
          expect(of[i - 1].score, greaterThanOrEqualTo(of[i].score));
        }
      }
    });
  });

  testWidgets('every kind of hit opens a screen without an error',
      (tester) async {
    final pushed = <Route<dynamic>>[];
    final obs = _Obs(pushed.add);
    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [obs],
      home: Builder(builder: (c) => const Scaffold(body: SizedBox())),
    ));
    final ctx = tester.element(find.byType(Scaffold));
    for (final q in ['chai', 'fertile window', 'pregnancy test', 'folic', 'ovulation']) {
      for (final h in ttcStageSearch(q)) {
        pushed.clear();
        h.open(ctx);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: '${h.kind.name}: ${h.title}');
        expect(pushed, isNotEmpty, reason: '${h.kind.name}: ${h.title} opened nothing');
        Navigator.of(ctx).popUntil((r) => r.isFirst);
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
  });

  testWidgets('typing shows the stage hits and one Ask Veda row',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TtcAskVedaScreen()));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'chai');
    await tester.pump();
    expect(find.byKey(const ValueKey('ttc_ask_search')), findsOneWidget);
    expect(find.byKey(const ValueKey('ttc_ask_search_ask')), findsOneWidget);
    expect(find.text('Ask Veda: "chai"'), findsOneWidget);
    expect(find.text('Can I…?'), findsOneWidget);
  });

  // Hidden again the same day on the user's word; the rule that holds is that
  // the other stages stay off. Kept for revert: expect(kAskFabInTtc, isTrue).
  test('the floating button: other stages stay off', () {
    expect(FabState.kAskFabEnabled, isFalse,
        reason: 'the other stages stay off until their own pass');
  });
}

class _Obs extends NavigatorObserver {
  _Obs(this.onPush);
  final void Function(Route<dynamic>) onPush;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) onPush(route);
  }
}
