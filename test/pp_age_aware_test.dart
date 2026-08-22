// =============================================================================
//  Things that must change when the child's age changes
// -----------------------------------------------------------------------------
//  ⚠️ THE FAILURE THIS GUARDS LOOKS EXACTLY LIKE SUCCESS.
//
//  Three surfaces in the Development section were hardcoded to one age and
//  nobody noticed for months, because a hardcoded list is INDISTINGUISHABLE
//  FROM A CURATED ONE on screen. Four sensible activities. Six sensible
//  questions. Everything renders, nothing throws, and the content is real —
//  it is simply the wrong content for this child.
//
//  You cannot catch that by reading the screen. You catch it by asking whether
//  two different children get two different answers, which is what this file
//  does.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_data.dart';

void main() {
  group('activities follow the age', () {
    test('two different ages are not offered the same set', () {
      final newborn = activitiesForAge(1).map((a) => a.id).toSet();
      final nineMonths = activitiesForAge(9).map((a) => a.id).toSet();
      expect(newborn, isNotEmpty);
      expect(nineMonths, isNotEmpty);
      expect(newborn, isNot(equals(nineMonths)),
          reason: 'Every age got the same activities. That is what '
              '`kDevActivities.take(4)` did, and it looked curated.');
    });

    test('every age from newborn to five has activities', () {
      // ⚠️ THIS TEST USED TO ASSERT THE OPPOSITE, and the story is the useful
      // part. It read `expect(activitiesForAge(30), isEmpty)` and documented a
      // content gap: "the library runs out after twelve months".
      //
      // It did not. `activitiesForAge` was reading `kDevActivities` alone —
      // eight activities, all tagged inside 0–12 months — while
      // `kGrowExtraActivities` sat beside it with 39 more, spanning 0–3 months
      // to 4–5 years. The Development build prompt names both in one line.
      //
      // The tell was the shape of the gap: a library that stops dead at
      // exactly twelve months is a filter artefact, not an editorial decision.
      // Worth remembering, because a test that asserts a gap will happily keep
      // a real one invisible.
      for (final months in [1, 5, 9, 15, 24, 30, 42, 55]) {
        expect(activitiesForAge(months), isNotEmpty,
            reason: 'nothing for a $months-month-old');
      }
    });

    test('a year-based tag is not read as months', () {
      // `kGrowExtraActivities` tags anything past two in YEARS ("4–5 yr").
      // Parsing the digits alone would offer preschool activities to a
      // four-MONTH-old and hide them from the four-year-old they were written
      // for. Nothing would crash and the cards would print their real ages;
      // only the filter would be lying.
      expect(devAgeRange('4–5 yr')?.lo, 48);
      expect(devAgeRange('9–12 mo')?.lo, 9);
      // Up to the fifth birthday, not the month of it — otherwise 60 months
      // matches both '4–5 yr' and '5–6 yr'.
      expect(devAgeRange('4–5 yr')?.hi, 71);
    });

    test('an age range is parsed from the tag a parent reads', () {
      // ⚠️ THE TAG IS THE SINGLE SOURCE. A separate numeric field would be a
      // copy that can disagree with the label on the card, so the range is
      // parsed from the same string that is displayed.
      expect(devAgeRange('3–6 mo')?.lo, 3);
      expect(devAgeRange('3–6 mo')?.hi, 6);
      expect(devAgeRange('0–12 mo')?.hi, 12);
      expect(devAgeRange('no numbers here'), isNull);
    });

    test('an unparseable tag keeps its activity rather than hiding it', () {
      // Failing open is deliberate: a typo in a range must not make an
      // activity vanish silently. Showing it at a slightly wrong age is a
      // smaller harm than a library that quietly shrinks.
      final all = activitiesForAge(9);
      final unparseable =
          kDevActivities.where((a) => devAgeRange(a.ageTag) == null);
      for (final a in unparseable) {
        expect(all.map((x) => x.id), contains(a.id),
            reason: '${a.id} has an unparseable ageTag and was dropped');
      }
    });
  });

  group('the check-in follows the age', () {
    test('each band asks a different set', () {
      final sets = [2, 8, 18, 30, 48].map((m) =>
          checkInsForAge(m).map((q) => q.text).join('|')).toSet();
      expect(sets.length, 5,
          reason: 'Two age bands ask identical questions, so the banding is '
              'decoration.');
    });

    test('every band covers all six areas exactly once', () {
      // ⚠️ THE REFLECTION AT THE END COUNTS YESES BY AREA. A band with two
      // questions from one domain and none from another would skew it without
      // any visible sign, which is the quietest possible way to break a screen
      // whose whole promise is that it is not a score.
      for (final months in [2, 8, 18, 30, 48]) {
        final qs = checkInsForAge(months);
        expect(qs.length, 6, reason: 'band at $months months has ${qs.length}');
        expect(qs.map((q) => q.areaId).toSet().length, 6,
            reason: 'band at $months months repeats or misses an area');
      }
    });

    test('no question asks whether a child is on time', () {
      // The screen promises "no right answers". A question phrased as a
      // threshold breaks that promise no matter what the heading says.
      for (final months in [2, 8, 18, 30, 48]) {
        for (final q in checkInsForAge(months)) {
          final t = q.text.toLowerCase();
          for (final banned in ['should he', 'by now', 'yet?', 'on time']) {
            expect(t.contains(banned), isFalse,
                reason: '"${q.text}" reads as a threshold, not an observation');
          }
        }
      }
    });
  });

  group('emerging and coming soon do not overlap', () {
    test('nothing appears under both headings', () {
      // ⚠️ THE OVERLAP WAS ARITHMETIC, NOT AN OVERSIGHT. `emerging` starts one
      // month early on purpose; `comingSoon` took everything after today. Any
      // milestone opening next month satisfied both, so the same skill was
      // printed twice on one screen under two different headings.
      final store = MilestoneStore.instance;
      for (final months in [1, 4, 9, 15, 26, 40]) {
        // ⚠️ THE AGE IS SET ON THE PROFILE, NOT ON THE STORE, because that
        // is where it actually lives — `MilestoneStore._ageMonths` reads
        // `ChildProfileStore`. A debug setter on the store would let this test
        // pass against an age the app can never be in.
        ChildProfileStore.instance.debugSetDob(
            DateTime.now().subtract(Duration(days: (months * 30.5).round())));
        final emerging = store.emerging.map((m) => m.id).toSet();
        final soon = store.comingSoon.map((m) => m.id).toSet();
        expect(emerging.intersection(soon), isEmpty,
            reason: 'at $months months, '
                '${emerging.intersection(soon)} is in both lists');
      }
    });

    test('coming soon looks six months ahead, not five years', () {
      final store = MilestoneStore.instance;
      ChildProfileStore.instance
          .debugSetDob(DateTime.now().subtract(const Duration(days: 122)));
      for (final m in store.comingSoon) {
        expect(m.loMonths, lessThanOrEqualTo(10),
            reason: '"${m.title}" opens at ${m.loMonths} months and is being '
                'shown to the parent of a 4-month-old. A look ahead is '
                'reassuring; the whole road is a workload.');
      }
    });
  });

  group('a skill page explains the skill', () {
    // ⚠️ MEASURED BEFORE AND AFTER, BECAUSE "BETTER EXPLANATION" IS THE KIND OF
    // FEEDBACK THAT IS EASY TO AGREE WITH AND HARD TO VERIFY.
    //
    // Before this pass, `meaning` averaged 34 characters and `why` averaged 27
    // across all 34 skills — a caption each. On a page whose entire job is to
    // explain one skill, the two sections a parent came for were the two
    // shortest things on it, and nothing in the app could tell you that.
    List<DevStage> allStages() =>
        [for (final a in kDevAreas) ...a.journey];

    test('every skill says what it is and why it matters, at length', () {
      for (final st in allStages()) {
        expect(st.meaning.length, greaterThanOrEqualTo(80),
            reason: '"${st.name}" what-it-is is ${st.meaning.length} chars. '
                'That is a caption, not an explanation.');
        expect(st.why.length, greaterThanOrEqualTo(80),
            reason: '"${st.name}" why-it-matters is ${st.why.length} chars.');
      }
    });

    test('no skill copy sets a deadline', () {
      // The section promises a wide normal range and no scoring. Copy that says
      // "should" or "by now" breaks that promise regardless of the headings
      // around it — and it is the easiest thing in the world to write by
      // accident when describing a milestone.
      for (final st in allStages()) {
        final text = '${st.meaning} ${st.why}'.toLowerCase();
        for (final banned in ['should be', 'should have', 'by now', 'on time', 'behind']) {
          expect(text.contains(banned), isFalse,
              reason: '"${st.name}" contains "$banned", which reads as a '
                  'threshold on a page that promises there is none.');
        }
      }
    });
  });
}
