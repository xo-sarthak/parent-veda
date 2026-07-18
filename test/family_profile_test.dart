// Tests for the ParentVeda Personalization Engine (Living Family Profile): the
// engine query API (the intelligence layer) + the profile/onboarding screens.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/family_intelligence_onboarding.dart';
import 'package:parentveda/screens/post_pregnancy/family_profile_screen.dart';
import 'package:parentveda/services/family_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final p = FamilyProfileStore.instance;

  test('a health condition drives boosts, signal-match and Todays Focus', () {
    p.clearConditions();
    p.toggleCondition(HealthCondition.eczema);
    expect(p.recoBoosts().containsKey('eczema'), isTrue);
    expect(p.matchesSignal('the best eczema cream for babies'), isTrue);
    expect(p.personalizedFocus().toLowerCase(), contains('skin'));
    expect(p.aiContext().toLowerCase(), contains('eczema'));
  });

  test('priority ordering surfaces a chosen priority first, hides nothing', () {
    if (!p.wants(Priority.sleep)) p.togglePriority(Priority.sleep);
    final items = <(String, Priority)>[
      ('feeding', Priority.feeding),
      ('sleep', Priority.sleep),
      ('play', Priority.play),
    ];
    final ordered = p.orderByPriority(items, (e) => e.$2);
    expect(ordered.first.$1, 'sleep'); // moved to front
    expect(ordered.length, items.length); // nothing dropped
  });

  test('completeness grows as fields are filled', () {
    p.clearConditions();
    p.setFeeding(null);
    p.setSleep(null);
    // priorities may already have sleep from the previous test; clear it too
    if (p.wants(Priority.sleep)) p.togglePriority(Priority.sleep);
    p.setLearning(null);
    final before = p.completenessPercent;
    p.setFeeding(FeedingMethod.mixed);
    p.setSleep(SleepPattern.nightWaking);
    expect(p.completenessPercent, greaterThan(before));
  });

  testWidgets('My Family Profile page renders and a chip toggles', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: FamilyProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('My Family Profile'), findsOneWidget);
    expect(find.textContaining('personalised'), findsOneWidget); // completeness meter
    // toggle a priority chip
    final scrollable = find.byType(Scrollable).first;
    final wasOn = FamilyProfileStore.instance.wants(Priority.milestones);
    await tester.scrollUntilVisible(find.text('Milestones'), 200, scrollable: scrollable, maxScrolls: 30);
    await tester.ensureVisible(find.text('Milestones').first);
    await tester.pump();
    await tester.tap(find.text('Milestones').first);
    await tester.pump();
    // The tap flipped the priority in the store.
    expect(FamilyProfileStore.instance.wants(Priority.milestones), !wasOn);
  });

  testWidgets('The Intelligence onboarding opens and advances', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: FamilyIntelligenceOnboarding()));
    await tester.pumpAndSettle();

    expect(find.text("Let's begin"), findsOneWidget); // welcome card
    await tester.tap(find.text("Let's begin"));
    await tester.pumpAndSettle();
    expect(find.textContaining('The basics on'), findsWidgets); // advanced to layer 1
  });
}
