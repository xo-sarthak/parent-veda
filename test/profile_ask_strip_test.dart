// =============================================================================
//  ProfileAskStrip — it renders, it answers, and it never comes back
// -----------------------------------------------------------------------------
//  Widget-level proof that progressive profiling is actually wired. The store
//  tests prove shouldAsk/markAsked behave; these prove the UI honours them.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/profile_analytics.dart';
import 'package:parentveda/widgets/profile_ask_strip.dart';

const _en = AppLanguage.english;
const _hi = AppLanguage.hinglish;

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
    await tester.pumpWidget(_host(dietStrip(_en, 'test')));
    expect(find.text('How do you eat?'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
  });

  testWidgets('the page underneath is never blocked', (tester) async {
    await tester.pumpWidget(_host(dietStrip(_en, 'test')));
    // Whether or not the strip shows, what she came for is still on screen.
    expect(find.text('page body'), findsOneWidget);
  });

  testWidgets('answering records the value and closes the strip', (tester) async {
    p.setDiet(null);
    expect(p.shouldAsk(ProfileField.diet), isTrue, reason: 'precondition');
    await tester.pumpWidget(_host(dietStrip(_en, 'test')));

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
    await tester.pumpWidget(_host(pregPrioritiesStrip(_en, 'test')));
    expect(find.text('What would you most like help with?'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.text('What would you most like help with?'), findsNothing);
    expect(p.pregPriorities, isEmpty, reason: 'she answered nothing');
    expect(p.shouldAsk(ProfileField.pregPriorities), isFalse,
        reason: 'dismissing must not be re-asked - that is nagging');
  });

  // -- the bug this file did not catch ---------------------------------------
  //  The strip shipped with seven English literals and no reference to
  //  AppLanguage at all, and every test above passed throughout - because they
  //  all ran in English. An English-only widget test cannot fail on missing
  //  Hindi. So this one asks in Hindi and asserts on the Devanagari, which is
  //  the only shape of test that would have caught it.
  //
  //  It also pins the other half: what she READS is Hindi, what we REPORT is
  //  English. Those are different questions of the same string, and the type
  //  system cannot tell them apart - only a test can.
  testWidgets('in Hindi the strip renders Hindi and reports English',
      (tester) async {
    p.clearPregConditions();
    ProfileAnalytics.instance.clearRecent();
    // pregHealth is untouched by every test above, so it is genuinely unasked.
    expect(p.shouldAsk(ProfileField.pregHealth), isTrue, reason: 'precondition');

    await tester.pumpWidget(_host(pregHealthStrip(_hi, 'test')));

    expect(find.text('क्या आपके डॉक्टर ने ध्यान रखने लायक़ कुछ बताया है?'),
        findsOneWidget,
        reason: 'the question must be in her language');
    expect(find.text('अभी नहीं'), findsOneWidget,
        reason: '"Not now" was one of the seven hardcoded English literals');
    expect(find.text('ख़ून की कमी'), findsOneWidget,
        reason: 'the chips come from the enum labels, so those must localise too');
    expect(find.text('Anemia'), findsNothing,
        reason: 'and the English must be gone, not merely joined');

    await tester.tap(find.text('ख़ून की कमी'));
    await tester.pumpAndSettle();

    expect(p.hasPregCondition(PregCondition.anemia), isTrue,
        reason: 'the Hindi chip must still write the same enum value');
    // `.en` is identity: if the analytics value followed the screen instead,
    // "what mothers want help with" would split into an English count and a
    // Hindi count, and neither would be true.
    expect(
        ProfileAnalytics.instance.recent
            .any((e) => e.contains('stripAnswered') && e.contains('value=Anemia')),
        isTrue,
        reason: 'the reported value is the English label, not the shown one');
  });
}
