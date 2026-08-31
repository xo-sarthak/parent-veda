// =============================================================================
//  "Should I get help?" — the routing, and the direction it leans
// -----------------------------------------------------------------------------
//  ⚠️ THIS TESTS AN ASYMMETRY, NOT A FUNCTION. The two errors this tool can make
//  are not equal: sending someone to an appointment she did not strictly need
//  costs her a morning; telling a 38-year-old with irregular cycles to keep
//  waiting costs her months she cannot get back.
//
//  So the assertions are lopsided on purpose. There are many tests that no path
//  says "keep waiting" and one that the reassuring branch exists at all.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_ivf_readiness_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_ivf_readiness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() => CycleStore.instance.resetForTest());

  const empty = FertilityHelpContext();

  /// Someone with nothing at all to worry about, fully answered. Every test
  /// below starts from this and changes one thing — which is what makes the
  /// assertions about that one thing.
  IvfReadinessAnswers safe() => IvfReadinessAnswers()
    ..age = IvfAge.under35
    ..trying = IvfTrying.underSix
    ..cycles = IvfCycles.regular
    ..conditionsChecked = true
    ..semen = IvfSemen.normal
    ..check = IvfCheck.no;

  IvfVerdict verdictOf(IvfReadinessAnswers a) =>
      ivfBuildReadiness(a, empty).verdict;

  // ===========================================================================
  group('the only reassuring branch is the narrow one', () {
    test('under 35, under six months, regular, nothing known, his test fine',
        () {
      expect(verdictOf(safe()), IvfVerdict.keepTrying);
    });

    test('and it still leaves the door open', () {
      final r = ivfBuildReadiness(safe(), empty);
      expect(r.openDoor.toLowerCase(), contains('always okay'),
          reason: 'someone told to keep trying who still wants to talk to a '
              'person must not have to redo the questionnaire to find the '
              'button');
      expect(r.openDoor, contains(kIvfAlwaysLine));
    });
  });

  // ===========================================================================
  //  ⚠️ THE POINT OF `enoughToReassure`: reassurance requires a complete
  //  picture, the conversation does not. One blank anywhere loses it.
  group('every missing answer falls toward the conversation', () {
    test('no age', () {
      expect(verdictOf(safe()..age = null), IvfVerdict.nowByMissingInfo);
    });
    test('no duration', () {
      expect(verdictOf(safe()..trying = null), IvfVerdict.nowByMissingInfo);
    });
    test('no cycle answer', () {
      expect(verdictOf(safe()..cycles = null), IvfVerdict.nowByMissingInfo);
    });
    test('conditions never looked at', () {
      expect(verdictOf(safe()..conditionsChecked = false),
          IvfVerdict.nowByMissingInfo);
    });
    test('conditions answered "not sure"', () {
      expect(verdictOf(safe()..conditionsUnsure = true),
          IvfVerdict.nowByMissingInfo);
    });
    test('no semen answer', () {
      expect(verdictOf(safe()..semen = null), IvfVerdict.nowByMissingInfo);
    });
    test('no previous-check answer', () {
      expect(verdictOf(safe()..check = null), IvfVerdict.nowByMissingInfo);
    });
  });

  // ===========================================================================
  group('the age and duration hinges hold at exactly 35 and 40', () {
    test('35 to 37 with six months earns the conversation', () {
      final a = safe()
        ..age = IvfAge.thirtyFiveTo37
        ..trying = IvfTrying.sixToTwelve;
      expect(verdictOf(a), IvfVerdict.nowByAge);
    });

    test('35 to 37 with under six months does NOT get told to keep waiting',
        () {
      // ⚠️ THE RULE WITH THE SHARPEST EDGE IN THE SPEC: never tell someone 35
      // or over to keep waiting. Under six months there is no positive reason
      // to refer — so the answer must be the neutral default, not reassurance.
      final a = safe()..age = IvfAge.thirtyFiveTo37;
      expect(verdictOf(a), isNot(IvfVerdict.keepTrying));
    });

    test('38 to 40 behaves the same as 35 to 37', () {
      final a = safe()
        ..age = IvfAge.thirtyEightTo40
        ..trying = IvfTrying.sixToTwelve;
      expect(verdictOf(a), IvfVerdict.nowByAge);
    });

    test('over 40 is "soon", regardless of duration', () {
      final a = safe()..age = IvfAge.over40;
      expect(verdictOf(a), IvfVerdict.soon);
      expect(ivfBuildReadiness(a, empty).timing.toLowerCase(),
          contains('soon'));
    });

    test('under 35 needs a full year, and eleven months is not a year', () {
      expect(verdictOf(safe()..trying = IvfTrying.sixToTwelve),
          IvfVerdict.keepTrying,
          reason: 'the twelve-month rule must not fire before twelve months');
      expect(verdictOf(safe()..trying = IvfTrying.overAYear),
          IvfVerdict.nowByDuration);
      expect(verdictOf(safe()..trying = IvfTrying.overTwoYears),
          IvfVerdict.nowByDuration);
    });
  });

  // ===========================================================================
  group('red flags override the clock', () {
    test('irregular cycles, four months in, aged 29', () {
      expect(verdictOf(safe()..cycles = IvfCycles.irregular),
          IvfVerdict.flagged);
    });

    test('long gaps too', () {
      expect(verdictOf(safe()..cycles = IvfCycles.longGaps),
          IvfVerdict.flagged);
    });

    test('an issue on his semen test', () {
      expect(verdictOf(safe()..semen = IvfSemen.issue), IvfVerdict.flagged);
    });

    for (final id in ['pcos', 'endo', 'miscarriage', 'pelvic']) {
      test('a known $id', () {
        final a = safe()..conditions = {id};
        expect(verdictOf(a), IvfVerdict.flagged);
      });
    }

    test('but a thyroid problem alone is not a flag', () {
      // ⚠️ AND THIS IS THE ONE THAT COULD EASILY HAVE BEEN WRONG. A thyroid
      // problem is real, affects cycles, and is usually already being treated
      // by somebody. It does not on its own mean a fertility conversation is
      // overdue — so it appears in the checklist and not in the routing.
      final a = safe()..conditions = {'thyroid'};
      expect(verdictOf(a), IvfVerdict.keepTrying);
      expect(ivfBuildReadiness(a, empty).checklist.any(
              (r) => r.value.toLowerCase().contains('thyroid')),
          isTrue,
          reason: 'it still has to reach the doctor, just not as an alarm');
    });

    test('and the reason is named plainly, not implied', () {
      final a = safe()
        ..cycles = IvfCycles.irregular
        ..semen = IvfSemen.issue;
      final timing = ivfBuildReadiness(a, empty).timing;
      expect(timing, contains('your cycles are irregular'));
      expect(timing, contains('his semen test showed an issue'));
      expect(timing, contains(' and '),
          reason: 'two reasons should read as a sentence, not a list');
    });
  });

  // ===========================================================================
  group('already in care wins over everything', () {
    test('even with every red flag set', () {
      final a = safe()
        ..check = IvfCheck.inItNow
        ..age = IvfAge.over40
        ..cycles = IvfCycles.longGaps
        ..semen = IvfSemen.issue
        ..conditions = {'pcos', 'endo'};
      expect(verdictOf(a), IvfVerdict.alreadyInCare,
          reason: 'everything below this branch would be telling someone under '
              'a consultant to go and find one');
      expect(ivfBuildReadiness(a, empty).timing.toLowerCase(),
          contains('right place to be'));
    });
  });

  // ===========================================================================
  group("his half is asked about, and 'not sure' counts", () {
    test('not knowing, six months in, earns the conversation', () {
      final a = safe()
        ..semen = IvfSemen.notSure
        ..trying = IvfTrying.sixToTwelve;
      expect(verdictOf(a), IvfVerdict.nowBySemenUnknown);
      expect(ivfBuildReadiness(a, empty).timing.toLowerCase(),
          contains('semen test'));
    });

    test('and every checklist carries his line, however it was answered', () {
      for (final v in [...IvfSemen.values, null]) {
        final a = safe()..semen = v;
        final row = ivfBuildReadiness(a, empty)
            .checklist
            .firstWhere((r) => r.label.toLowerCase().contains('semen'));
        expect(row.value, isNotEmpty,
            reason: 'male factor is about half of cases and must never be '
                'absent from the notes she takes in');
      }
    });
  });

  // ===========================================================================
  group('nothing on any path resembles a verdict', () {
    test('across every combination of the six answers', () {
      // A full sweep is 4*4*3*4*3 = 576 combinations plus condition sets. That
      // is cheap and it is the only way to be sure a branch added later cannot
      // quietly introduce a forbidden phrase.
      final banned = [
        '%',
        'per cent',
        'infertile',
        'you are fertile',
        'you will conceive',
        'you will not conceive',
        'success rate',
        'score',
        'likely to conceive',
      ];

      for (final age in IvfAge.values) {
        for (final trying in IvfTrying.values) {
          for (final cycles in IvfCycles.values) {
            for (final semen in IvfSemen.values) {
              for (final check in IvfCheck.values) {
                final a = IvfReadinessAnswers()
                  ..age = age
                  ..trying = trying
                  ..cycles = cycles
                  ..conditionsChecked = true
                  ..semen = semen
                  ..check = check;
                final r = ivfBuildReadiness(a, empty);
                final text = [
                  r.where,
                  r.timing,
                  r.openDoor,
                  for (final c in r.checklist) '${c.label} ${c.value}',
                ].join(' ').toLowerCase();

                for (final b in banned) {
                  expect(text.contains(b), isFalse,
                      reason: '"$b" appeared for $age / $trying / $cycles / '
                          '$semen / $check');
                }
                expect(r.openDoor, contains(kIvfAlwaysLine),
                    reason: 'every path must close on the disclaimer');
              }
            }
          }
        }
      }
    });

    test('and no path ever says keep waiting to someone 35 or over', () {
      for (final age in [
        IvfAge.thirtyFiveTo37,
        IvfAge.thirtyEightTo40,
        IvfAge.over40
      ]) {
        for (final trying in IvfTrying.values) {
          for (final cycles in IvfCycles.values) {
            final a = safe()
              ..age = age
              ..trying = trying
              ..cycles = cycles;
            expect(verdictOf(a), isNot(IvfVerdict.keepTrying),
                reason: '$age / $trying / $cycles was told to keep waiting');
          }
        }
      }
    });
  });

  // ===========================================================================
  group('the cycle prefill reads the logs', () {
    test('a 100-day gap suggests long gaps', () {
      const ctx = FertilityHelpContext(
          cyclesLogged: 3, cycleShortest: 28, cycleLongest: 100);
      expect(ivfSuggestedCycles(ctx), IvfCycles.longGaps);
    });

    test('a wide spread suggests irregular', () {
      const ctx = FertilityHelpContext(
          cyclesLogged: 3,
          cycleShortest: 24,
          cycleLongest: 42,
          cyclesIrregular: true);
      expect(ivfSuggestedCycles(ctx), IvfCycles.irregular);
    });

    test('and too little logged suggests nothing at all', () {
      const ctx = FertilityHelpContext(cyclesLogged: 1, cycleShortest: 28);
      expect(ivfSuggestedCycles(ctx), isNull,
          reason: 'a prefill from one interval is a guess she cannot see');
    });
  });

  // ===========================================================================
  group('it renders', () {
    Future<void> pump(WidgetTester tester, Widget child) async {
      tester.view.physicalSize = const Size(360, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: child));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }

    testWidgets('the flow, scrolled to the end', (tester) async {
      await pump(tester, const TtcIvfReadinessScreen());
      for (var i = 0; i < 14; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 60));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the read on a flagged path', (tester) async {
      final r = ivfBuildReadiness(
          safe()..cycles = IvfCycles.longGaps, empty);
      await pump(tester, TtcIvfReadinessResultScreen(result: r));
      expect(find.text('Where you are'), findsOneWidget);
    });

    testWidgets('the read on the reassuring path, and its notes',
        (tester) async {
      final r = ivfBuildReadiness(safe(), empty);
      await pump(tester, TtcIvfReadinessResultScreen(result: r));
      await pump(tester, TtcIvfNotesScreen(result: r));
      expect(find.text(kIvfChecklistDisclaimer), findsOneWidget);
    });
  });
}
