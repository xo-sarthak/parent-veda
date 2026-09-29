// Week page extras, weeks 17 to 28 (lib/data/preg_week_extras_b.dart).
//
// The symptom tips pair with weekContent.json by label, so a label rewritten
// on one side and not the other would leave a symptom with no tip, or a tip
// the screen never shows. Nothing would error. These checks make that a
// build failure, and hold the part file to docs/PREG-VOICE.md.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/preg_week_extras.dart';
import 'package:parentveda/data/preg_week_extras_b.dart';
import 'package:parentveda/data/symptoms/symptom_library.dart';

const _first = 17;
const _last = 28;

/// `momJourney.commonSymptoms[i].en` for every week in weekContent.json.
Map<int, List<String>> _commonSymptoms() {
  final raw = File('lib/data/weekContent.json').readAsStringSync();
  final out = <int, List<String>>{};
  for (final w in jsonDecode(raw) as List) {
    final m = w as Map;
    final list = ((m['momJourney'] as Map)['commonSymptoms'] as List)
        .map((s) => (s as Map)['en'] as String)
        .toList();
    out[m['week'] as int] = list;
  }
  return out;
}

const _banned = [
  'journey',
  'navigate',
  'empower',
  'delve',
  'embark',
  'holistic',
  'game-changer',
  'crucial',
  "you've got this",
  'rest assured',
  'we understand how you feel',
  "it's important to note",
  "it's worth noting",
  "let's dive in",
  'genuinely',
  'actually',
  'quietly',
  'simply',
  'truly',
  'the single most',
  'the one thing nobody tells you',
  "here's the thing",
  'mama',
  'mommy',
  'momma',
  'miracle',
  'magical',
  'blessed',
  "don't worry",
];

Iterable<String> _strings(PregWeekExtra e) sync* {
  for (final t in e.symptomTips) {
    yield t.tip;
  }
  for (final q in e.asked) {
    yield q.q;
    yield q.a;
  }
}

void main() {
  final symptoms = _commonSymptoms();

  test('part b holds weeks 17 to 28, once each, in order', () {
    expect(kPregWeekExtrasB.map((e) => e.week).toList(),
        [for (var w = _first; w <= _last; w++) w]);
    for (var w = _first; w <= _last; w++) {
      expect(kPregWeekExtras[w], isNotNull, reason: 'week $w not in the merged map');
    }
  });

  for (final e in kPregWeekExtrasB) {
    group('week ${e.week}', () {
      test('every common symptom has exactly one tip, and no tip is orphaned', () {
        final labels = symptoms[e.week];
        expect(labels, isNotNull, reason: 'week ${e.week} missing from weekContent.json');
        for (final label in labels!) {
          expect(e.symptomTips.where((t) => t.symptom == label).length, 1,
              reason: 'week ${e.week}: "$label" needs exactly one tip');
        }
        for (final t in e.symptomTips) {
          expect(labels, contains(t.symptom),
              reason: 'week ${e.week}: tip for "${t.symptom}" matches no label');
        }
      });

      test('every symptomId opens a real Symptoms page', () {
        for (final t in e.symptomTips) {
          if (t.symptomId == null) continue;
          expect(symptomById(t.symptomId!), isNotNull,
              reason: 'week ${e.week}: "${t.symptomId}" does not resolve');
        }
      });

      test('two or three questions, each with an answer', () {
        expect(e.asked.length, inInclusiveRange(2, 3));
        for (final q in e.asked) {
          expect(q.q.trim(), isNotEmpty);
          expect(q.a.trim(), isNotEmpty);
        }
      });

      test('three to five vetted sources, no repeats', () {
        expect(e.sources.length, inInclusiveRange(3, 5));
        expect(e.sources.toSet().length, e.sources.length);
        for (final k in e.sources) {
          expect(kPregWeekSources.containsKey(k), isTrue,
              reason: 'week ${e.week}: "$k" is not in kPregWeekSources');
        }
      });

      test('voice: no dashes as punctuation, no "!", no banned words', () {
        for (final s in _strings(e)) {
          expect(s.contains('—'), isFalse, reason: 'em dash in: $s');
          expect(s.contains(' - '), isFalse, reason: 'spaced hyphen in: $s');
          expect(s.contains('!'), isFalse, reason: '"!" in: $s');
          final lower = s.toLowerCase();
          for (final w in _banned) {
            expect(RegExp('\\b${RegExp.escape(w)}\\b').hasMatch(lower), isFalse,
                reason: 'banned "$w" in: $s');
          }
        }
      });
    });
  }
}
