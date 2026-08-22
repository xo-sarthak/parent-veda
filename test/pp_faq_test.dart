// =============================================================================
//  Every question a tracker prints has an answer behind it
// -----------------------------------------------------------------------------
//  ⚠️ THE QUESTION STRING IS A KEY AS WELL AS COPY, WHICH IS THE TRAP.
//
//  `ppFaqSheet` looks the answer up by exact question text. So the sentence in
//  `milestone_journey_screen.dart` and the sentence in `pp_faq_data.dart` have
//  to stay byte-identical — and one of them is copy, which somebody will
//  reword. Nothing would fail: the sheet falls back to corpus search, the
//  search finds nothing, and the parent is told the app does not know. That is
//  precisely the bug this data file was written to fix, and it would come back
//  silently the first time a question is polished.
//
//  This is the same shape as `.en` is identity / `.now` is display: two strings
//  that look interchangeable, where one is a key.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_faq_data.dart';

/// Pull the question lists straight out of the tracker screens, so the test
/// reads what actually ships rather than a copy of it.
List<({String file, String question})> _printedQuestions() {
  const files = [
    'lib/screens/post_pregnancy/feeding_journey_screen.dart',
    'lib/screens/post_pregnancy/growth_journey_screen.dart',
    'lib/screens/post_pregnancy/milestone_journey_screen.dart',
    'lib/screens/post_pregnancy/sleep_journey_screen.dart',
  ];
  final out = <({String file, String question})>[];
  for (final path in files) {
    final src = File(path).readAsStringSync();
    final start = src.indexOf('ppLearnBlock(context, const [');
    expect(start, greaterThan(-1), reason: '$path no longer calls ppLearnBlock');
    final end = src.indexOf('])', start);
    final block = src.substring(start, end);
    for (final m in RegExp(r"'([^']{12,})'").allMatches(block)) {
      out.add((file: path.split('/').last, question: m.group(1)!));
    }
  }
  return out;
}

void main() {
  test('every printed FAQ question has a written answer', () {
    final printed = _printedQuestions();
    expect(printed.length, greaterThanOrEqualTo(16),
        reason: 'Expected four questions from each of the four trackers. '
            'Fewer means the extraction broke, not that the app improved.');

    for (final q in printed) {
      expect(ppFaqAnswer(q.question, 4), isNotNull,
          reason: '${q.file} prints "${q.question}" and pp_faq_data.dart has '
              'no entry for it. The sheet will fall back to corpus search and '
              'tell the parent the app does not know.');
    }
  });

  test('an answer is a real answer, not a stub', () {
    // ⚠️ LENGTH IS A CRUDE PROXY AND IT IS THE RIGHT ONE HERE. The failure
    // being guarded is a question wired to a placeholder so the test above
    // goes green — "Coming soon" would pass a null check perfectly.
    for (final f in kPpFaqs) {
      expect(f.general.length, greaterThan(120),
          reason: '"${f.question}" has a ${f.general.length}-character '
              'general answer, which is a stub rather than an answer.');
    }
  });

  test('a banded answer differs from the general one', () {
    // A band that repeats the general text is the appearance of age-awareness
    // without the substance, and it costs a reader nothing to spot but costs
    // us the claim.
    for (final f in kPpFaqs) {
      for (final months in [3, 8, 20, 48]) {
        final a = f.forAge(months);
        expect(a.trim(), isNotEmpty,
            reason: '"${f.question}" answers nothing at $months months');
      }
      final banded = [f.under6m, f.m6to12, f.m12to36, f.over36m]
          .whereType<String>()
          .toList();
      for (final b in banded) {
        expect(b, isNot(equals(f.general)),
            reason: '"${f.question}" has a band identical to its general '
                'answer. Either write a different one or drop the band.');
      }
    }
  });

  test('at least half the questions actually vary by age', () {
    // ⚠️ NOT ALL OF THEM SHOULD. "What does a growth percentile mean" has one
    // true answer at every age, and inventing four would be padding. But if
    // almost none varied, the age-banding would be decoration — the feedback
    // asked for answers that "change based on child age", so this asserts the
    // feature is real without forcing it where it does not belong.
    final varying = kPpFaqs
        .where((f) => f.forAge(3) != f.forAge(30) || f.forAge(8) != f.forAge(48))
        .length;
    expect(varying * 2, greaterThanOrEqualTo(kPpFaqs.length),
        reason: 'Only $varying of ${kPpFaqs.length} FAQs change with age.');
  });
}
