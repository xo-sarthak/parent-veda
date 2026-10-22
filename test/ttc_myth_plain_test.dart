// Myth vs fact, plain and standalone (2026-10-21). The user: "this seems
// very ambiguous ... it should be made simple and value adding".
//
// Round 2 (2026-10-22): plain had turned into clipped ("Usually not.", "It
// hasn't."). The user: "sentences that look complete rather than just bland
// statements, more warm and reassuring". So every fact now opens with a whole
// sentence that answers the myth, across all three stages.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reading_data.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

/// The stubs the 10-21 pass opened with. Each answers the myth without saying
/// what it is answering, which reads cold on a card she meets alone.
const _stubs = [
  'no.',
  'yes.',
  'usually not',
  'not usually',
  'it hasn\'t',
  'it isn\'t',
  'it doesn\'t',
  'they don\'t',
  'they aren\'t',
  'you can.',
  'not on its own',
  'only up to a point',
  'not always',
  'not really',
  'no pillow',
];

void _expectWholeOpening(String fact, String where) {
  final t = fact.trim();
  final first = t.split(RegExp(r'(?<=[.!?])\s')).first;
  final lower = t.toLowerCase();
  for (final s in _stubs) {
    expect(lower.startsWith(s), isFalse, reason: '$where opens with "$s": $t');
  }
  expect(first.split(RegExp(r'\s+')).length, greaterThanOrEqualTo(5),
      reason: '$where: the first sentence is a stub: "$first"');
}

void main() {
  test('every daily myth has a short fact and a why that stands alone', () {
    for (final m in ttcMyths) {
      expect(m.whyEn, isNotNull, reason: m.id);
      // Kept for revert (2026-10-22): lessThan(120). A whole, warm sentence
      // needs a little more room than a clipped one.
      expect(m.truthEn.length, lessThan(170), reason: '${m.id}: one sentence');
      // A why that points back at a slide she has left is the old bug.
      for (final back in ['More than that', 'More often than that', 'That ', 'This ']) {
        expect(m.whyEn!.startsWith(back), isFalse, reason: '${m.id}: "$back"');
      }
    }
  });

  test('the story shows the why as its own slide', () {
    final s = File('lib/screens/ttc/ttc_daily_tip_open.dart').readAsStringSync();
    expect(s, contains('myth.whyEn'));
    expect(s, contains('kTtcMythWhySlide'));
  });

  group('every fact opens with a whole sentence', () {
    test('TTC daily myths', () {
      for (final m in ttcMyths) {
        _expectWholeOpening(m.truthEn, m.id);
        _expectWholeOpening(m.whyEn!, '${m.id} why');
      }
    });

    test('TTC and pregnancy reads', () {
      for (final r in [...kTtcReadsAsWritten, ...kPregnancyReads]) {
        for (final s in r.sections) {
          final mf = s.mythFact;
          if (mf != null) _expectWholeOpening(mf.fact.en, r.id);
        }
      }
    });

    test('pregnancy weekly myth-busters', () {
      final weeks = jsonDecode(
          File('lib/data/weekContent.json').readAsStringSync()) as List;
      for (final w in weeks) {
        final mb = (w as Map)['mythBuster'] as Map?;
        final en = (mb?['truth'] as Map?)?['en'] as String?;
        if (en != null && en.isNotEmpty) {
          _expectWholeOpening(en, 'week ${w['week']}');
        }
      }
    });

    test('parenting reads', () {
      for (final a in kReadArticles) {
        for (final s in a.sections) {
          final mf = s.mythFact;
          if (mf != null) _expectWholeOpening(mf.fact, a.id);
        }
      }
    });
  });
}
