// =============================================================================
//  Two screens, one dataset, one verdict
// -----------------------------------------------------------------------------
//  Today looked at her history, decided a recorded gap was long enough to be a
//  month nobody logged, and said so: "Something in your dates looks off." It
//  refused to print an ovulation estimate.
//
//  Cycle Companion, one tap away, looked at the SAME history and printed
//  "Average length 54 days · Range 54-54 days" - confidently, in the largest
//  type on the screen, from that same unlogged gap.
//
//  The confident one was the wrong one, which is the dangerous way round. A
//  woman planning around a 54-day average because the app told her twice, in
//  bold, is worse off than one told nothing.
//
//  Two rules fall out and are asserted here:
//
//    * If the engine will not estimate from a history, no screen may present
//      statistics derived from it.
//    * One completed cycle is an observation, not an average, and never a
//      range.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const engine = TtcChapterEngine();

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  /// The history actually on the device: a two-month gap with nothing logged,
  /// surrounded by same-period double-taps.
  void logTheRealHistory() {
    for (final d in [
      DateTime(2026, 4, 17),
      DateTime(2026, 4, 24),
      DateTime(2026, 5, 8),
      DateTime(2026, 7, 1), // the 54-day gap - a cycle nobody logged
      DateTime(2026, 7, 5),
      DateTime(2026, 7, 7),
    ]) {
      CycleStore.instance.logPeriodStart(d);
    }
  }

  // ===========================================================================
  group('the setup that caused it', () {
    test('exactly one gap survives the plausibility filter', () {
      logTheRealHistory();
      expect(CycleStore.instance.cycleLengths, [54]);
    });

    test('and the engine already refuses to trust it', () {
      logTheRealHistory();
      final s = TtcStore.instance.state(on: DateTime(2026, 7, 9));
      expect(engine.hasUnreliableHistory(s), isTrue,
          reason: 'the premise of the whole fix');
    });
  });

  // ===========================================================================
  group('so Cycle Companion must not print statistics from it', () {
    test('the average is behind the same gate Today uses', () {
      const src = 'lib/screens/ttc/ttc_cycle_screens.dart';
      final text = File(src).readAsStringSync();
      expect(text, contains('hasUnreliableHistory'),
          reason: 'the screen no longer consults the engine at all');
      // And it shows Today's explanation rather than inventing its own, so the
      // two cannot drift into saying different things about one dataset.
      expect(text, contains('t.noEstHistoryOffTitle'));
      expect(text, contains('t.noEstHistoryOffBody'));
    });

    test('the explanation it borrows actually says what is wrong', () {
      const t = TtcS(false);
      expect(t.noEstHistoryOffBody.toLowerCase(), contains('longer than'));
      // It must not read as her fault.
      expect(t.noEstHistoryOffBody.toLowerCase(), isNot(contains('you failed')));
    });
  });

  // ===========================================================================
  group('and the calendar does not advertise a colour it never draws', () {
    test('the fertile rows know BOTH reasons a marker can be absent', () {
      // The legend already hid them on a clinic path. It did not know about the
      // other reason - an unreliable history the engine refuses to estimate
      // from - so the pathway stayed `natural`, `showsFertilityWindow` stayed
      // true, and the key promised a shading the grid had not drawn. On the one
      // screen she would go looking for it.
      const src = 'lib/screens/ttc/ttc_calendar_screen.dart';
      final text = File(src).readAsStringSync();
      expect(text, contains('behaviour.showsFertilityWindow && hasEstimate'),
          reason: 'the legend is back to knowing only one reason');
      expect(text, contains('estimatedOvulationDay'),
          reason: 'the legend no longer asks the engine anything');
    });

    test('and the engine really does refuse on this history', () {
      // Guards the test above from passing vacuously: if the engine stopped
      // refusing, the legend gate would be dead code and nobody would notice.
      logTheRealHistory();
      final s = TtcStore.instance.state(on: DateTime(2026, 7, 9));
      expect(engine.estimatedOvulationDay(s), isNull);
    });
  });

  // ===========================================================================
  group('one cycle is not an average', () {
    test('it is labelled as the single observation it is', () {
      const en = TtcS(false);
      const hi = TtcS(true);
      expect(en.cycleFirstFull, 'Your first full cycle');
      expect(hi.cycleFirstFull, isNot(en.cycleFirstFull));
      expect(en.cycleFirstFull, isNot(en.cycleAverage));
    });

    test('and carries no range', () {
      // "54-54 days" is one observation wearing a spread's clothes.
      const src = 'lib/screens/ttc/ttc_cycle_screens.dart';
      final text = File(src).readAsStringSync();
      expect(text, contains('lengths.length > 1'),
          reason: 'the range renders unconditionally again');
    });
  });
}
