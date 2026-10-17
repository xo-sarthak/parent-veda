// Bug B1 (2026-10-17): the onboarding answers about a baby were given before
// the baby existed, then wiped when addChild made the new child active. The
// answers sat in the '_none' bucket and the switch loaded an empty one.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/services/family_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  test('feeding, sleep and born-early answered before the child exists survive addChild', () async {
    final p = FamilyProfileStore.instance;
    await p.init();
    expect(ChildProfileStore.instance.activeChildId, isNull,
        reason: 'the bug only happens on the first child');

    p.setFeeding(FeedingMethod.mixed);
    p.setSleep(SleepPattern.nightWaking);
    p.setBirthDetails(early: true, bornWeeks: 34);
    expect(p.feedings, {FeedingMethod.mixed}, reason: 'the set is the stored copy');

    await ChildProfileStore.instance
        .addChild(name: 'Aarav', isBoy: true, dob: DateTime(2026, 6, 1));

    expect(p.feeding, FeedingMethod.mixed);
    expect(p.sleep, SleepPattern.nightWaking);
    expect(p.premature, isTrue);
    expect(p.bornWeeks, 34);
  });

  test('a second child still starts with its own empty answers', () async {
    final p = FamilyProfileStore.instance;
    await ChildProfileStore.instance
        .addChild(name: 'Meera', isBoy: false, dob: DateTime(2026, 6, 1));
    expect(p.feeding, isNull);
    expect(p.premature, isFalse);
  });
}
