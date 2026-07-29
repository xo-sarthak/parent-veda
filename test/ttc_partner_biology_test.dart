// =============================================================================
//  What HE is told about HER body
// -----------------------------------------------------------------------------
//  His side of the stage had three things - what she may be carrying, what he
//  can do, and his own biology - and nothing at all that explained what a cycle
//  is, what ovulation means, or why the fortnight before a period feels exactly
//  like early pregnancy. He was being asked to support a process nobody had
//  ever described to him.
//
//  That is a content gap, but the fix touches two rules that are not content:
//
//    * PRIVACY. He holds no rows in `ttc_cycles` and receives only the chapter
//      she publishes. Prose is a side channel like any other - "she is probably
//      ovulating about now" would leak through text what the schema refuses to
//      hand over. So this is chapter-level by construction and these tests say
//      so out loud.
//    * NO PREDICTION. Explaining what progesterone does is teaching. Telling him
//      what she will feel on a given day is a forecast about a person whose data
//      he cannot see, and it would be wrong for many women besides.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_partner_data.dart';

void main() {
  final briefs = ttcPartnerBriefs;

  // ===========================================================================
  group('every chapter explains her body', () {
    test('in both languages, with no chapter left out', () {
      for (final c in TtcChapter.values) {
        final b = briefs[c];
        expect(b, isNotNull, reason: '$c has no brief at all');
        expect(b!.herBody(false), isNotEmpty, reason: '$c English');
        expect(b.herBody(true), isNotEmpty, reason: '$c Hinglish');
        expect(b.herBody(false), isNot(b.herBody(true)),
            reason: '$c was never actually translated');
      }
    });

    test('and it is a real explanation, not a caption', () {
      // The failure mode being prevented is a two-line placeholder that ships
      // and then nobody revisits. His "Today's learn" was exactly that.
      for (final c in TtcChapter.values) {
        expect(briefs[c]!.herBody(false).length, greaterThan(240),
            reason: '$c English is too short to have taught anything');
        expect(briefs[c]!.herBody(true).length, greaterThan(240),
            reason: '$c Hinglish is too short to have taught anything');
      }
    });

    test('it is distinct from his own half', () {
      for (final c in TtcChapter.values) {
        expect(briefs[c]!.herBody(false), isNot(briefs[c]!.yourBody(false)),
            reason: '$c reuses his biology as hers');
      }
    });
  });

  // ===========================================================================
  group('it never leaks where she is', () {
    test('no cycle day, no day count, no date', () {
      // He is shown the chapter she publishes and nothing finer. A sentence
      // that said "around day fourteen" would hand him, in prose, the exact
      // thing the own-row rule on ttc_cycles exists to withhold.
      final banned = [
        RegExp(r'\bday \d', caseSensitive: false),
        RegExp(r'\bcycle day\b', caseSensitive: false),
        RegExp(r'\bdin \d', caseSensitive: false),
        RegExp(r'\btoday she\b', caseSensitive: false),
        RegExp(r'\bright now she\b', caseSensitive: false),
      ];
      for (final c in TtcChapter.values) {
        for (final hi in [false, true]) {
          final text = briefs[c]!.herBody(hi);
          for (final b in banned) {
            expect(b.hasMatch(text), isFalse,
                reason: '$c (hinglish=$hi) leaks position: ${b.pattern}');
          }
        }
      }
    });

    test('and the screen says so where he can read it', () {
      // A privacy rule nobody is told about protects her but reassures neither
      // of them. The card carries the note itself.
      final strings =
          File('lib/screens/ttc/ttc_strings.dart').readAsStringSync();
      expect(strings, contains('partnerHerBodyNote'));
      final screen =
          File('lib/screens/ttc/ttc_partner_screen.dart').readAsStringSync();
      expect(screen, contains('t.partnerHerBodyNote'),
          reason: 'the promise is written but never rendered');
    });
  });

  // ===========================================================================
  group('it explains without predicting', () {
    test('no probability, no chance, no odds', () {
      // The stage-wide rule: never a personalised likelihood. It applies to his
      // door as much as hers - arguably more, since he is the one likelier to
      // repeat a number back to her.
      final banned = RegExp(
          r'\b(chance|chances|probability|odds|likelihood|percent|%|'
          r'sambhavna|umeed hai ki)\b',
          caseSensitive: false);
      for (final c in TtcChapter.values) {
        for (final hi in [false, true]) {
          expect(banned.hasMatch(briefs[c]!.herBody(hi)), isFalse,
              reason: '$c (hinglish=$hi) states a likelihood');
        }
      }
    });

    test('and never tells him she IS pregnant or is not', () {
      // The waiting-days text in particular has to hold this line: its whole
      // point is that the symptoms cannot answer the question.
      final text = briefs[TtcChapter.theWaitingDays]!.herBody(false);
      expect(text.toLowerCase(), contains('whether or not she is pregnant'));
      expect(text.toLowerCase(), contains('cannot answer'));
    });
  });

  // ===========================================================================
  group('the card is actually on his screen', () {
    // The wiring gate. Content that exists and is never rendered is the exact
    // failure this repo keeps hitting, and a data-only test would pass over it.
    test('_HerBodyCard is built, not merely declared', () {
      final src =
          File('lib/screens/ttc/ttc_partner_screen.dart').readAsStringSync();
      expect(src, contains('class _HerBodyCard'));
      expect(src, contains('_HerBodyCard(brief: brief, t: t)'),
          reason: 'the card exists but nothing puts it on screen');
    });

    test('and it sits above his own biology', () {
      // Order carries meaning here: he came to understand her.
      final src =
          File('lib/screens/ttc/ttc_partner_screen.dart').readAsStringSync();
      final her = src.indexOf('_HerBodyCard(brief: brief, t: t)');
      final his = src.indexOf('_YourBodyCard(brief: brief, t: t)');
      expect(her, greaterThan(-1));
      expect(his, greaterThan(-1));
      expect(her, lessThan(his));
    });
  });
}
