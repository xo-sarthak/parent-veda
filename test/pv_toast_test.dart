// The one notice (lib/widgets/pv_toast.dart): it shows, it morphs instead of
// stacking, it leaves on time, it swipes away, Undo runs once, and it still
// speaks with animations off.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/pv_sync_health.dart';
import 'package:parentveda/widgets/pv_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  late BuildContext ctx;
  Future<void> pump(WidgetTester t, {bool still = false}) async {
    await t.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        final page = const Scaffold(body: SizedBox.expand());
        return still
            ? MediaQuery(
                data: MediaQuery.of(c).copyWith(disableAnimations: true),
                child: page)
            : page;
      }),
    ));
  }

  Future<void> drain(WidgetTester t) async {
    PvToast.instance.dismiss();
    await t.pump(const Duration(milliseconds: 400));
  }

  testWidgets('a done notice shows its words and a tick', (t) async {
    await pump(t);
    pvToast(ctx, 'Logged for 14 October', kind: PvToastKind.done);
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Logged for 14 October'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await drain(t);
  });

  testWidgets('a second notice morphs the first, never stacks', (t) async {
    await pump(t);
    pvToast(ctx, 'First');
    await t.pump(const Duration(milliseconds: 100));
    pvToast(ctx, 'Second', kind: PvToastKind.done);
    await t.pump();
    // The swap starts on the next frame; let it run out.
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    expect(find.byType(PvToastCard), findsOneWidget);
    await drain(t);
  });

  testWidgets('it leaves on its own', (t) async {
    await pump(t);
    pvToast(ctx, 'Copied');
    await t.pump();
    await t.pump(const Duration(milliseconds: 2400));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(PvToastCard), findsNothing);
  });

  testWidgets('a swipe down sends it away', (t) async {
    await pump(t);
    pvToast(ctx, 'Saved to your library', kind: PvToastKind.saved);
    await t.pump(const Duration(milliseconds: 400));
    await t.drag(find.byType(PvToastCard), const Offset(0, 120));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(PvToastCard), findsNothing);
  });

  testWidgets('Undo runs once, however fast she taps', (t) async {
    await pump(t);
    var undone = 0;
    pvToast(ctx, 'Removed from your bag',
        kind: PvToastKind.undo, action: 'Undo', onAction: () => undone++);
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('Undo'));
    await t.tap(find.text('Undo'), warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 400));
    expect(undone, 1);
    expect(find.byType(PvToastCard), findsNothing);
  });

  testWidgets('a working notice resolves in place', (t) async {
    await pump(t);
    final h = pvToastWorking(ctx, 'Booking…');
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // No timeout while working.
    await t.pump(const Duration(seconds: 8));
    expect(find.text('Booking…'), findsOneWidget);
    h.done('Booked');
    await t.pump();
    // The swap starts on the next frame; let it run out.
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.text('Booked'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await drain(t);
  });

  testWidgets('closed completes when a newer notice replaces it', (t) async {
    await pump(t);
    var closed = false;
    final h = pvToast(ctx, 'Letter deleted.',
        kind: PvToastKind.undo, action: 'Undo', onAction: () {});
    unawaited(h.closed.then((_) => closed = true));
    await t.pump(const Duration(milliseconds: 400));
    expect(closed, isFalse);
    pvToast(ctx, 'Copied');
    await t.pump();
    expect(closed, isTrue);
    await drain(t);
  });

  testWidgets('with animations off it still speaks', (t) async {
    await pump(t, still: true);
    pvToast(ctx, 'Copied');
    await t.pump();
    expect(find.text('Copied'), findsOneWidget);
    await drain(t);
  });

  test('the offline notice only hears network failures', () {
    expect(PvSyncHealth.looksLikeNetwork(TimeoutException('x')), isTrue);
    expect(
        PvSyncHealth.looksLikeNetwork(
            Exception('SocketException: Failed host lookup')),
        isTrue);
    expect(PvSyncHealth.looksLikeNetwork(Exception('column "foo" does not exist')),
        isFalse);
  });
}
