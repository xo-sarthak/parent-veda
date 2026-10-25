// =============================================================================
//  Log a feed, tools pass 01 (2026-10-25): docs/pp-tool-plans/01-log-a-feed.md
// -----------------------------------------------------------------------------
//  Holds the fixes the audit asked for: one child's feeds never show for
//  another, an edit keeps the feed's id, feeds count per 24 hours, the
//  one-tap repeat switches the side, the "ask once" store, and the relevance
//  brain reading the log only with her yes and never taking expressed milk
//  for formula.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/feeding_journey_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_feeding_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/services/pp_use_consent.dart';

void main() {
  final feeds = FeedingStore.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
    feeds.debugReset();
    PpUseConsent.instance.debugReset();
  });

  test('one child at a time: twins never share a feed log', () async {
    final store = ChildProfileStore.instance;
    final a = await store.addChild(name: 'Aarav', isBoy: true, dob: DateTime.now().subtract(const Duration(days: 40)));
    final b = await store.addChild(name: 'Meera', isBoy: false, dob: DateTime.now().subtract(const Duration(days: 40)));
    await store.switchTo(a.id);
    feeds.log(time: DateTime.now().subtract(const Duration(hours: 1)), kind: FeedKind.breast, side: FeedSideX.left);
    expect(feeds.all, hasLength(1));

    await store.switchTo(b.id);
    expect(feeds.all, isEmpty, reason: "Aarav's feed must not show for Meera");
    expect(feeds.last, isNull);
    expect(feeds.countLast24h, 0);
    feeds.log(time: DateTime.now(), kind: FeedKind.bottle, milk: BottleMilk.formula, amountMl: 90);

    await store.switchTo(a.id);
    expect(feeds.all.single.kind, FeedKind.breast);
  });

  test('an edit keeps the id, so it syncs as the same feed', () {
    feeds.log(time: DateTime.now(), kind: FeedKind.breast, side: FeedSideX.left);
    final f = feeds.all.single;
    feeds.update(FeedLog(id: f.id, time: f.time, kind: FeedKind.breast, side: FeedSideX.right, note: 'sleepy'));
    expect(feeds.all, hasLength(1));
    expect(feeds.all.single.id, f.id);
    expect(feeds.all.single.side, FeedSideX.right);
    expect(feeds.all.single.note, 'sleepy');
  });

  test('feeds count per 24 hours, across midnight', () {
    final now = DateTime.now();
    feeds.log(time: now.subtract(const Duration(hours: 2)), kind: FeedKind.breast);
    feeds.log(time: now.subtract(const Duration(hours: 23)), kind: FeedKind.breast);
    feeds.log(time: now.subtract(const Duration(hours: 25)), kind: FeedKind.breast);
    expect(feeds.countLast24h, 2);
    expect(feeds.avgGapMinutes, 21 * 60);
  });

  test('the one-tap repeat switches the breast side and keeps a bottle', () {
    final t = DateTime(2026, 10, 25, 3);
    final left = FeedLog(id: 'x', time: t, kind: FeedKind.breast, side: FeedSideX.left, durationMin: 12);
    expect(ppFeedRepeat(left, t).side, FeedSideX.right);
    expect(ppFeedRepeat(left, t).durationMin, isNull, reason: 'a repeat is logged now, not timed');
    expect(ppFeedRepeatLabel(left), 'Breast, right');
    final bottle = FeedLog(id: 'y', time: t, kind: FeedKind.bottle, milk: BottleMilk.expressed, amountMl: 110);
    expect(ppFeedRepeatLabel(bottle), 'Bottle, 110 ml');
  });

  test('ask once: unasked is a no, and the answer is kept', () async {
    final c = PpUseConsent.instance;
    expect(c.unasked(PpUseKind.feeds), isTrue);
    expect(c.allows(PpUseKind.feeds), isFalse);
    c.set(PpUseKind.feeds, true);
    expect(c.allows(PpUseKind.feeds), isTrue);
    c.set(PpUseKind.feeds, false);
    expect(c.allows(PpUseKind.feeds), isFalse);
    expect(c.unasked(PpUseKind.feeds), isFalse);
    await Future<void>.delayed(Duration.zero);
    c.debugReset();
    await c.init();
    expect(c.answerFor(PpUseKind.feeds), PpUseAnswer.no, reason: 'kept across a restart');
  });

  test('relevance: the log only with her yes, and expressed milk is not formula', () {
    feeds.log(time: DateTime.now(), kind: FeedKind.bottle, milk: BottleMilk.expressed, amountMl: 100);
    expect(PpSituation.now().signals, isNot(contains(PpSignal.breastfeeding)), reason: 'no yes yet');

    PpUseConsent.instance.set(PpUseKind.feeds, true);
    final s = PpSituation.now().signals;
    expect(s, contains(PpSignal.breastfeeding));
    expect(s, isNot(contains(PpSignal.formula)), reason: 'a bottle of her own milk is not formula');

    feeds.log(time: DateTime.now(), kind: FeedKind.bottle, milk: BottleMilk.formula, amountMl: 60);
    expect(PpSituation.now().signals, contains(PpSignal.formula));
  });

  testWidgets('the screen: 24-hour count, repeat chip, ask card, tap to edit', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2800 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    feeds.log(time: DateTime.now().subtract(const Duration(hours: 1)), kind: FeedKind.breast, side: FeedSideX.left);
    await t.pumpWidget(const MaterialApp(home: FeedingJourneyScreen()));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('feed in 24 h'), findsOneWidget);
    expect(find.text('Same as last: Breast, right'), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_use_ask_feeds')), findsOneWidget);

    await t.tap(find.byKey(const ValueKey('pp_use_yes_feeds')));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('pp_use_ask_feeds')), findsNothing, reason: 'asked once');

    await t.tap(find.byKey(ValueKey('pp_feed_row_${feeds.all.single.id}')));
    await t.pumpAndSettle();
    expect(find.text('Edit this feed'), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_feed_note')), findsOneWidget);
  });

  test('wiring: the consent store boots, and You lists every kind', () {
    expect(File('lib/main.dart').readAsStringSync(), contains('PpUseConsent.instance.init()'));
    expect(File('lib/screens/profile/pv_data_privacy_screen.dart').readAsStringSync(),
        contains('for (final kind in PpUseKind.values)'));
  });
}
