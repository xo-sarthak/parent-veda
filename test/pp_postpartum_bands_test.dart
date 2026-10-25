// =============================================================================
//  Her bands, in weeks, on her youngest child's clock (You, Maa plan M2)
// -----------------------------------------------------------------------------
//  What failed silently before 2026-10-25: "the first 6 weeks" was months 0
//  to 2, so a mother at week 7 (and up to week 8.7) was still shown stitches
//  and lochia; "6 weeks to 3 months" lasted about four weeks; and the band
//  followed whichever child was on screen, so tapping a toddler moved a
//  three-week-postpartum mother to "6 months and beyond".
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_age_bands.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
  });
  tearDown(() => ChildProfileStore.instance.resetForTest());

  String her(double weeks) => kPpPostpartumBands.bandForWeeks(weeks).id;

  test('the boundaries are weeks: 0-6, 6-13, 13-26, 26+', () {
    expect(her(0), 'pp_0_6w');
    expect(her(5.9), 'pp_0_6w');
    expect(her(6), 'pp_6w_3m');
    expect(her(7), 'pp_6w_3m', reason: 'week 7 is past the first six weeks');
    expect(her(12), 'pp_6w_3m');
    expect(her(13), 'pp_3_6m');
    expect(her(14), 'pp_3_6m');
    expect(her(25.9), 'pp_3_6m');
    expect(her(26), 'pp_6m');
    expect(her(200), 'pp_6m');
  });

  test('the labels did not move', () {
    expect([for (final b in kPpPostpartumBands.bands) b.label], [
      'The first 6 weeks',
      '6 weeks to 3 months',
      '3 to 6 months',
      '6 months and beyond',
    ]);
  });

  test('week 7 on the live clock is the second band, not the first', () {
    ChildProfileStore.instance
        .debugSetDob(DateTime.now().subtract(const Duration(days: 7 * 7 + 1)));
    expect(kPpPostpartumBands.active.id, 'pp_6w_3m');
  });

  test('with two children, the younger one sets her band, whichever is on screen',
      () async {
    final store = ChildProfileStore.instance;
    // The older child, 3 years.
    store.debugSetDob(DateTime.now().subtract(const Duration(days: 3 * 365)));
    final older = store.activeChildId!;
    // A newborn, 3 weeks. addChild makes it active; it awaits prefs, which the
    // mock answers.
    await store.addChild(
        name: 'Baby',
        isBoy: false,
        dob: DateTime.now().subtract(const Duration(days: 21)));
    expect(kPpPostpartumBands.active.id, 'pp_0_6w');
    await store.switchTo(older);
    expect(store.ageInMonths, greaterThan(30), reason: 'the toddler is on screen');
    expect(kPpPostpartumBands.active.id, 'pp_0_6w',
        reason: 'her recovery follows her latest birth');
  });

  test('a child band set keeps the selected child, and its old months answer',
      () {
    ChildProfileStore.instance
        .debugSetDob(DateTime.now().subtract(const Duration(days: 400)));
    final months = ChildProfileStore.instance.ageInMonths;
    expect(kPpChildBands.active.id, kPpChildBands.bandFor(months).id);
    expect(kPpSleepBands.active.id, kPpSleepBands.bandFor(months).id);
    // Every week of the first six years agrees with the months lookup.
    for (var d = 0; d < 6 * 365; d += 3) {
      final w = d / 7.0;
      final m = (w / 4.345).floor();
      expect(kPpChildBands.bandForWeeks(w).id, kPpChildBands.bandFor(m).id,
          reason: 'day $d');
    }
  });
}
