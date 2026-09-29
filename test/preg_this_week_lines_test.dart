// The "This week" card on the pregnancy home reads babyLearning.en cold.
//
// lib/screens/preg_daily_insights.dart puts each day's `babyLearning.en` on a
// small card under the eyebrow "This week" (card id 'forming'). Until
// 2026-09-29 these were poetic fragments ("halfway there, ears tuning to your
// voice") that did not read as sentences on their own. They were rewritten to
// docs/PREG-VOICE.md: one short, complete, true sentence per day.
//
// This pins the shape so a later content pass cannot slide back: every one of
// the 259 days has a line, it is a sentence (capital, full stop), it fits a
// small card, it carries none of the voice guide's banned habits, and no two
// days say the same thing.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _first = 4;
const _last = 40;

List<Map<String, dynamic>> _week(int w) {
  final f = File('lib/data/home/week_${w.toString().padLeft(2, '0')}.json');
  return (jsonDecode(f.readAsStringSync()) as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
}

/// PREG-VOICE.md §4, the words that could plausibly turn up in a line about
/// the baby's week. Word-bounded so "remembering" in a longer word is not a
/// false hit, while the opener habit "Remember," is.
final _banned = RegExp(
  r"\b(journey|navigate|empower|delve|embark|holistic|game-changer|crucial|"
  r"genuinely|actually|quietly|simply|truly|mama|mommy|momma|miracle|"
  r"magical|blessed|rest assured|you've got this|don't worry|remember)\b",
  caseSensitive: false,
);

/// Never the baby's sex (PCPNDT Act): no gendered pronoun for the baby.
final _sexed = RegExp(r'\b(he|she|his|him|her|hers|boy|girl)\b',
    caseSensitive: false);

void main() {
  for (var w = _first; w <= _last; w++) {
    final days = _week(w);

    test('week $w has seven days', () {
      expect(days, hasLength(7));
    });

    for (final d in days) {
      final day = d['day'];
      final en = ((d['babyLearning'] as Map)['en'] as String?) ?? '';

      test('week $w day $day: "This week" line is a short clean sentence', () {
        expect(en.trim(), isNotEmpty);
        expect(en, en.trim(), reason: 'no stray whitespace');
        expect(en[0], en[0].toUpperCase(),
            reason: 'starts with a capital: "$en"');
        expect(RegExp('[A-Z]').hasMatch(en[0]), isTrue,
            reason: 'starts with a letter: "$en"');
        expect(en.endsWith('.'), isTrue, reason: 'ends with a full stop: "$en"');
        expect(en.length, lessThanOrEqualTo(90),
            reason: 'fits the card: "$en" is ${en.length} chars');
        expect(en.contains('—'), isFalse, reason: 'no em dash: "$en"');
        expect(en.contains(' - '), isFalse, reason: 'no spaced hyphen: "$en"');
        expect(en.contains('!'), isFalse, reason: 'no exclamation: "$en"');
        expect(_banned.firstMatch(en)?.group(0), isNull,
            reason: 'banned word in "$en"');
        expect(_sexed.firstMatch(en)?.group(0), isNull,
            reason: 'gendered word in "$en"');
      });
    }
  }

  test('all 259 days have a line and no two are the same', () {
    var total = 0;
    final seen = <String, String>{};
    final dupes = <String>[];
    for (var w = _first; w <= _last; w++) {
      for (final d in _week(w)) {
        total++;
        final en = ((d['babyLearning'] as Map)['en'] as String?) ?? '';
        final key = en.trim().toLowerCase();
        final where = 'week $w day ${d['day']}';
        final prior = seen[key];
        if (prior != null) dupes.add('"$en" at $prior and $where');
        seen[key] = where;
      }
    }
    expect(total, 259);
    expect(dupes, isEmpty, reason: dupes.join('\n'));
  });
}
