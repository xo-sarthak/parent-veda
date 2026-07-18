// =============================================================================
//  Guided journeys — the feature stands alone; the sponsorship is an add-on
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_campaigns.dart';
import 'package:parentveda/brand/brand_models.dart';
import 'package:parentveda/screens/post_pregnancy/journeys_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_journeys_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('the journey is 30 real days, each with something to do', () {
    final j = kBreastfeedingJourney;
    expect(j.length, 30);
    for (var i = 0; i < j.days.length; i++) {
      final d = j.days[i];
      expect(d.day, i + 1, reason: 'days must be numbered in order');
      expect(d.title.trim(), isNotEmpty);
      expect(d.body.trim(), isNotEmpty);
      expect(d.action.trim(), isNotEmpty, reason: 'day ${d.day} has nothing to try');
    }
  });

  test('the days that touch a medical edge name someone to call', () {
    // The content rule that matters most: anywhere this brushes against a real
    // clinical risk, it must hand the parent to a real person rather than
    // leaving them with an app's opinion.
    const mustEscalate = [4, 6, 7, 14, 20, 27, 28];
    for (final n in mustEscalate) {
      expect(
        kBreastfeedingJourney.dayAt(n).askSomeone.trim(),
        isNotEmpty,
        reason: 'day $n touches a medical edge but names no one to ask',
      );
    }
  });

  test('a parent who misses days is never locked out or behind', () {
    final store = JourneyStore.instance;
    final j = kBreastfeedingJourney;
    store.reset(j.id);

    expect(store.hasStarted(j.id), isFalse);
    expect(store.suggestedDay(j), 1, reason: 'unstarted should suggest day 1, not day 0');

    store.start(j.id);
    // Every day is reachable immediately — the day number suggests, never gates.
    for (var n = 1; n <= j.length; n++) {
      expect(j.dayAt(n).day, n);
    }
    // The suggestion never runs past the end, however long they leave it.
    expect(store.suggestedDay(j), inInclusiveRange(1, j.length));
  });

  test('progress counts what was read, and leaving takes it all back', () {
    final store = JourneyStore.instance;
    final j = kBreastfeedingJourney;
    store.reset(j.id);
    store.start(j.id);

    expect(store.progress(j), 0);
    store.toggleDay(j.id, 1);
    store.toggleDay(j.id, 2);
    expect(store.doneCount(j.id), 2);
    expect(store.isDone(j.id, 1), isTrue);

    store.toggleDay(j.id, 1); // un-marking is allowed
    expect(store.doneCount(j.id), 1);

    // Leaving is one tap and costs nothing to undo.
    store.reset(j.id);
    expect(store.hasStarted(j.id), isFalse);
    expect(store.doneCount(j.id), 0);
  });

  testWidgets('the journey renders with no sponsor at all', (tester) async {
    // The feature must stand entirely on its own: the Brand Studio is inert
    // under test, so this is the unsponsored case — which is the default.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: JourneysScreen()));
    await tester.pumpAndSettle();

    // Retitled 18 Jul: "days" implied a schedule to fall behind on. It is 30
    // PARTS, read at whatever pace suits.
    expect(find.text('Breastfeeding, in 30 parts'), findsOneWidget);
    expect(find.textContaining('Presented by'), findsNothing);
  });

  testWidgets('a day shows its content, and marking it read sticks', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final j = kBreastfeedingJourney;
    JourneyStore.instance.reset(j.id);

    await tester.pumpWidget(MaterialApp(home: JourneyDayScreen(journey: j, day: j.dayAt(4))));
    await tester.pumpAndSettle();

    expect(find.text('It should not actually hurt'), findsOneWidget);
    expect(find.text('TRY THIS TODAY'), findsOneWidget);
    // Day 4 is one of the medical-edge days, so the escalation block must show.
    expect(find.text('ASK SOMEONE'), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 10 && find.text('Mark as read').evaluate().isEmpty; i++) {
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Mark as read'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as read'));
    await tester.pumpAndSettle();
    expect(JourneyStore.instance.isDone(j.id, 4), isTrue);
  });

  test('the sponsorship points at a journey that actually exists', () {
    final c = kBrandCampaigns.firstWhere((c) => c.slot == BrandSlot.sponsoredJourney);
    expect(journeyById(c.placementKey!), isNotNull,
        reason: 'a journey sponsorship named a journey that is not in the catalogue');
    // And it only reaches mothers who told us they are feeding this way.
    expect(c.audience.anySignal, contains('breastfeeding'));
    expect(c.audience.isUnconstrained, isFalse);
  });
}
