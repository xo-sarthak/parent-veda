// =============================================================================
//  ProfileAskStrip — it renders, it answers, and it never comes back
// -----------------------------------------------------------------------------
//  Widget-level proof that progressive profiling is actually wired. The store
//  tests prove shouldAsk/markAsked behave; these prove the UI honours them.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/widgets/profile_ask_strip.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: ListView(children: [child, const Text('page body')])),
    );

void main() {
  final p = FamilyProfileStore.instance;

  testWidgets('the strip asks when the field is unknown', (tester) async {
    p.setDiet(null);
    // Assert the precondition rather than guarding on it: a silent early return
    // would let this test pass while proving nothing.
    expect(p.shouldAsk(ProfileField.diet), isTrue,
        reason: 'precondition - diet is unknown and unasked');
    await tester.pumpWidget(_host(dietStrip('test')));
    expect(find.text('How do you eat?'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
  });

  testWidgets('the page underneath is never blocked', (tester) async {
    await tester.pumpWidget(_host(dietStrip('test')));
    // Whether or not the strip shows, what she came for is still on screen.
    expect(find.text('page body'), findsOneWidget);
  });

  testWidgets('answering records the value and closes the strip', (tester) async {
    p.setDiet(null);
    expect(p.shouldAsk(ProfileField.diet), isTrue, reason: 'precondition');
    await tester.pumpWidget(_host(dietStrip('test')));

    await tester.tap(find.text('Vegetarian'));
    await tester.pumpAndSettle();

    expect(p.diet, DietPreference.vegetarian, reason: 'the answer must stick');
    expect(find.text('How do you eat?'), findsNothing,
        reason: 'a single-select strip closes on the first tap');
    expect(p.shouldAsk(ProfileField.diet), isFalse,
        reason: 'and must never ask again');
  });

  testWidgets('dismissing is permanent, even though the field stays unknown',
      (tester) async {
    // pregPriorities is untouched by the tests above.
    expect(p.shouldAsk(ProfileField.pregPriorities), isTrue,
        reason: 'precondition - this field is untouched by the tests above');
    await tester.pumpWidget(_host(pregPrioritiesStrip('test')));
    expect(find.text('What would you most like help with?'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.text('What would you most like help with?'), findsNothing);
    expect(p.pregPriorities, isEmpty, reason: 'she answered nothing');
    expect(p.shouldAsk(ProfileField.pregPriorities), isFalse,
        reason: 'dismissing must not be re-asked - that is nagging');
  });
}
