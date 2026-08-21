// =============================================================================
//  Two defects a person found by tapping, held by reading the source
//
//  ⚠️ THESE ASSERT AGAINST home_v3_screen.dart AS TEXT, NOT AGAINST A PUMPED
//  WIDGET, AND THAT IS THE ONLY THING THAT WOULD HAVE CAUGHT EITHER OF THEM.
//
//  Both bugs were invisible to every normal test because nothing was broken.
//  The Garbh landing rendered three correct pillars doing three correct
//  things; the nutrition hub opened a real, working screen from both of its
//  doors. A widget test pumps a screen and asks whether it behaves — and both
//  screens behaved perfectly. What was wrong was what was ABSENT from one list
//  and DUPLICATED in another, which is a fact about the source rather than
//  about any rendered frame.
//
//  This is the same shape as the wiring gate CLAUDE.md names: the gap is never
//  between "correct" and "incorrect", it is between "this works" and "she can
//  get to it, and it is a different place from the last door she tried".
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) {
  final f = File(path);
  expect(f.existsSync(), isTrue, reason: 'missing source file: $path');
  return f.readAsStringSync();
}

void main() {
  group('Garbh Sanskar shows every pillar it has', () {
    // The Excel feedback: "we have 4 sections those should be shown like we
    // shown in daily screen." The landing showed three; Buddhi was built,
    // reachable from the daily screen, and simply never added here.
    test('the landing block lists the same four pillars as the daily screen',
        () {
      final home = _read('lib/screens/home_v3_screen.dart');
      final garbh = home.substring(home.indexOf('---- GARBH SANSKAR'));

      for (final pillar in ['Shravan', 'Samvad', 'Buddhi', 'Kriya']) {
        expect(garbh.contains("name: '$pillar'"), isTrue,
            reason: '$pillar is missing from the V3 landing Garbh block. '
                'The daily screen has four pillars; this block must match it.');
      }
    });

    test('Vichara is not named as a pillar anywhere it still renders', () {
      // Vichara was REPLACED by Buddhi, not renamed — its two shelves
      // duplicated Samvad and Shravan. The landing row kept the old compound
      // label 'Samvad & Vichara' long after the pillar stopped existing, which
      // made it the last place in the app implying Vichara was still a thing.
      // ⚠️ MATCHES THE CODE FORM, NOT THE BARE STRING, AND THIS TEST FAILED
      // ON ITS FIRST RUN BECAUSE OF THAT. `home.contains('Samvad & Vichara')`
      // went red against the COMMENT explaining why the label was removed —
      // a source-scanning test cannot tell prose from code, so it read the
      // note about the fix as evidence the bug was still there. Any assertion
      // that greps source has to anchor on syntax the compiler sees.
      final home = _read('lib/screens/home_v3_screen.dart');
      expect(home.contains("name: 'Samvad & Vichara'"), isFalse,
          reason: 'The landing row still names Vichara as a pillar.');
    });

    test('a pillar wears one accent across both screens', () {
      // Kriya carried #3F6E62 on the landing and #8A6D3B on the daily screen.
      // Nothing failed; the same practice simply had two colours, which only
      // shows up when someone puts the two screens side by side.
      final home = _read('lib/screens/home_v3_screen.dart');
      final daily = _read('lib/screens/garbh_daily_screen.dart');

      for (final accent in [
        '0xFF9C5F51', // Samvad
        '0xFF7A6E9B', // Buddhi
        '0xFF8A6D3B', // Kriya
      ]) {
        expect(home.contains(accent) && daily.contains(accent), isTrue,
            reason: '$accent is not shared by both Garbh surfaces.');
      }
    });
  });

  group('Two nutrition doors, two destinations', () {
    // Found on a device: the hub offers "What should I eat?" and "Something
    // has been flagged", and both opened the same generic nutrition home.
    test('the two nutrition actions do not share a case', () {
      final home = _read('lib/screens/home_v3_screen.dart');

      // A shared case is written as two labels with no body between them.
      // That exact stacking is what shipped, so that is what this forbids.
      expect(
        RegExp(r'case kPgActNutritionFlag:\s*case kPgActNutritionMain:')
            .hasMatch(home),
        isFalse,
        reason: 'Both nutrition doors fall through to one destination. '
            'Two doors with the same answer teach her the labels mean nothing.',
      );
    });

    test('the flagged door lands on the condition tab', () {
      final home = _read('lib/screens/home_v3_screen.dart');
      final i = home.indexOf('case kPgActNutritionFlag:');
      expect(i, greaterThan(-1));
      final body = home.substring(i, i + 260);

      expect(body.contains('NutritionStageScreen(initialTab: 1)'), isTrue,
          reason: 'The flagged door must open the "By condition" tab, not the '
              'trimester tab she would have to leave.');
    });

    test('the flag journey stays unreachable while its content is owed', () {
      // ⚠️ THIS ONE GUARDS A TEMPTING WRONG FIX. `kPgNutritionFlag` IS
      // registered in kPregnancyJourneys, so deleting the switch case would
      // hand the door to the journey and look like a tidy-up. Two of that
      // journey's three steps are `owed: true` — she would arrive at promises
      // with nothing behind them. Registration is navigation in this repo, and
      // the switch case is what currently outranks it.
      final journeys = _read('lib/data/journeys/pregnancy_journeys.dart');
      final start = journeys.indexOf('final JourneyConfig kPgNutritionFlag');
      final flag = journeys.substring(start, journeys.indexOf('closesWhen', start));

      if (flag.contains('owed: true')) {
        final home = _read('lib/screens/home_v3_screen.dart');
        final guard = home.indexOf('case kPgActNutritionFlag:');
        final journeyCall = home.indexOf('journeyFor(');
        expect(guard, greaterThan(-1),
            reason: 'kPgNutritionFlag still has owed steps, so the switch must '
                'keep intercepting this door.');
        expect(guard, lessThan(journeyCall),
            reason: 'The case must sit ABOVE the journey guard, or the journey '
                'wins and she meets steps with no content.');
      }
    });
  });
}
