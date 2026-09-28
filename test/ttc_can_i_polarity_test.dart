// =============================================================================
//  TTC "Can I...?" - the verdict chip answers the question actually asked
// -----------------------------------------------------------------------------
//  Launch sanity T7 (2026-09-28), a blocker. The verdict chip is written for a
//  permission question ("Can I ...?"): "Yes, this is fine", "Yes, with a
//  limit", "Better not", "Ask your doctor". Three entries were asked the other
//  way round - "Should I avoid papaya?", "Can we have sex too often?", "Does
//  smoking really matter?" - so a bold "Yes, this is fine" sat above an answer
//  that began "No." On a food-safety card she reads the chip, not the
//  paragraph, and the chip told her to avoid ripe fruit.
//
//  The mechanism worth knowing: a yes/no label is only meaningful relative to
//  the question's POLARITY. "Can I X?" -> yes means do it. "Should I avoid X?"
//  -> yes means don't. The label was fixed text, so the only way to keep it
//  true is to hold every question to the one polarity it was written for.
//  This test walks every entry, in both languages, rather than the three the
//  walk happened to open.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/ttc/ttc_can_i_data.dart';

/// A permission question: the chip's "Yes" means "you can".
final _permissionEn = RegExp(r'^(Can (I|we|he)|Is it (fine|OK|okay) to)\b');

/// Words that turn a question into "is there a harm?", where a "Yes" means
/// the opposite of what the chip intends. Also the excess words that made
/// "Can he take LONG hot baths?" answer "Yes, with a limit: not long ones".
const _flippingWordsEn = [
  'avoid',
  'should',
  'matter',
  'too',
  'harm',
  'bad for',
  'dangerous',
  'stop',
  'intense',
  'long',
  'heavy',
  'very',
];

/// Whole-word match, so "every" does not trip "very".
bool _hasWord(String hay, String w) =>
    RegExp(r'\b' + RegExp.escape(w) + r'\b').hasMatch(hay);

/// The same flips in the shipped Hindi side (Latin-script, kept as it is).
const _flippingWordsHi = ['bachna', 'maayne', 'nuksaan', 'zyada baar', 'lambe'];

String _firstWord(String s) =>
    s.trim().split(RegExp(r'[\s.,:;!-]+')).first.toLowerCase();

void main() {
  group('Can I...? verdicts agree with their questions (T7)', () {
    test('there are entries to walk', () {
      expect(ttcCanI, isNotEmpty);
    });

    for (final e in ttcCanI) {
      test('${e.id}: the question is a permission question', () {
        expect(_permissionEn.hasMatch(e.questionEn), isTrue,
            reason: '"${e.questionEn}" must be asked as "Can I/we/he ...?" '
                'or "Is it fine to ...?" so the verdict chip answers it');
        final en = e.questionEn.toLowerCase();
        for (final w in _flippingWordsEn) {
          expect(_hasWord(en, w), isFalse,
              reason: '"${e.questionEn}" contains "$w", which flips what '
                  '"${e.verdict.label(false)}" means');
        }
        final hi = e.questionHi.toLowerCase();
        expect(hi.startsWith('kya '), isTrue, reason: e.questionHi);
        for (final w in _flippingWordsHi) {
          expect(_hasWord(hi, w), isFalse,
              reason: '"${e.questionHi}" contains "$w"');
        }
      });

      test('${e.id}: the answer\'s first word agrees with the verdict', () {
        final en = _firstWord(e.shortEn);
        final hi = _firstWord(e.shortHi);
        switch (e.verdict) {
          case TtcVerdict.safe:
          case TtcVerdict.moderate:
            // "Yes" on the chip must not sit above an answer opening "No".
            expect(en, isNot(anyOf('no', 'not', 'never', 'avoid')),
                reason: '${e.verdict.label(false)} above "${e.shortEn}"');
            expect(hi, isNot(anyOf('nahi', 'nahin', 'mat')),
                reason: '${e.verdict.label(true)} above "${e.shortHi}"');
          case TtcVerdict.avoid:
            // "Better not" must not sit above an answer opening "Yes".
            expect(en, isNot(anyOf('yes', 'sure', 'fine')),
                reason: '${e.verdict.label(false)} above "${e.shortEn}"');
            expect(hi, isNot(anyOf('haan', 'theek')),
                reason: '${e.verdict.label(true)} above "${e.shortHi}"');
          case TtcVerdict.askDoctor:
            // A referral can open either way; it only must not be a flat no
            // that the chip does not say.
            expect(en, isNot('no'), reason: e.shortEn);
        }
      });
    }

    test('the three the walk hit now read the right way round', () {
      final papaya = ttcCanIById('papaya')!;
      expect(papaya.questionEn, startsWith('Can I eat'));
      expect(papaya.verdict, TtcVerdict.safe);
      expect(papaya.shortEn, startsWith('Yes.'));

      final sex = ttcCanIById('sex_frequency')!;
      expect(sex.questionEn, isNot(contains('too often')));
      expect(sex.verdict, TtcVerdict.safe);
      expect(sex.shortEn, startsWith('Yes.'));

      final smoking = ttcCanIById('smoking')!;
      expect(smoking.questionEn, startsWith('Can I keep smoking'));
      expect(smoking.verdict, TtcVerdict.avoid);
      expect(smoking.shortEn, startsWith('No.'));
    });

    test('no medical meaning moved: verdicts are the ones that shipped', () {
      // The fix rephrased questions; it did not change a single verdict.
      const shipped = {
        'chai': TtcVerdict.moderate,
        'alcohol': TtcVerdict.moderate,
        'smoking': TtcVerdict.avoid,
        'painkillers': TtcVerdict.askDoctor,
        'hot_bath': TtcVerdict.moderate,
        'exercise': TtcVerdict.moderate,
        'hair_dye': TtcVerdict.safe,
        'travel': TtcVerdict.safe,
        'papaya': TtcVerdict.safe,
        'xray': TtcVerdict.askDoctor,
        'sex_frequency': TtcVerdict.safe,
        'ayurvedic': TtcVerdict.askDoctor,
      };
      for (final entry in shipped.entries) {
        expect(ttcCanIById(entry.key)?.verdict, entry.value, reason: entry.key);
      }
    });
  });
}
