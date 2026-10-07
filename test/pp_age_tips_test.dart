// The tips by age, added 2026-10-02 from the parenting gap analysis.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_daily_tips.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('keys are unique and ids round-trip', () {
    final keys = [for (final t in kAgeTips) t.key];
    expect(keys.toSet().length, keys.length);
    for (final t in kAgeTips) {
      expect(dailyTipById(t.id)?.title, t.tip.title);
    }
  });

  test('every week from birth to six years has a real choice of tips', () {
    for (var w = 0; w < 313; w++) {
      expect(ageTipsFor(w).length, greaterThanOrEqualTo(15), reason: 'week $w');
    }
    expect(ageTipsFor(400), isNotEmpty, reason: 'past six, the last window');
  });

  test('every tip has a mechanism and an honest source', () {
    final year = RegExp(r'\b(19|20)\d{2}\b');
    for (final a in kAgeTips) {
      final t = a.tip;
      expect(t.why.trim(), isNotEmpty, reason: a.key);
      expect(t.source.trim(), isNotEmpty, reason: a.key);
      expect(year.hasMatch(t.source), isFalse, reason: a.key);
      expect(t.source.contains('et al'), isFalse, reason: a.key);
    }
  });

  test('a baby gets a baby tip; no child falls back to the general rotation',
      () {
    expect(dailyTipId().startsWith('tip_'), isTrue);
    ChildProfileStore.instance
        .debugSetDob(DateTime.now().subtract(const Duration(days: 20)));
    final id = dailyTipId();
    expect(id.startsWith('atip_'), isTrue);
    final tip = kAgeTips.firstWhere((t) => t.id == id);
    expect(tip.fits(ChildProfileStore.instance.ageInWeeks.floor()), isTrue);
    expect(dailyTip().title, tip.tip.title);
  });
}
