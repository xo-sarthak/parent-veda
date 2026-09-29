// Week page extras, part a (weeks 4 to 16). Holds the pairing with
// weekContent.json, the Symptoms door links, the shape of "Asked this week"
// and "Where this comes from", and the voice rules of docs/PREG-VOICE.md.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/preg_week_extras.dart';
import 'package:parentveda/data/preg_week_extras_a.dart';
import 'package:parentveda/data/symptoms/symptom_library.dart';

/// PREG-VOICE §4, the banned words and phrases.
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

void main() {
  final weeks = (jsonDecode(File('lib/data/weekContent.json').readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  List<String> labelsFor(int week) {
    final w = weeks.firstWhere((e) => e['week'] == week);
    final list = (w['momJourney'] as Map<String, dynamic>)['commonSymptoms'] as List;
    return [for (final s in list) (s as Map<String, dynamic>)['en'] as String];
  }

  test('part a covers weeks 4 to 16, once each', () {
    expect([for (final e in kPregWeekExtrasA) e.week], [for (var w = 4; w <= 16; w++) w]);
    for (var w = 4; w <= 16; w++) {
      expect(kPregWeekExtras[w], isNotNull, reason: 'week $w not reachable through kPregWeekExtras');
    }
  });

  for (final e in kPregWeekExtrasA) {
    group('week ${e.week}', () {
      test('every common symptom has exactly one tip, and nothing else does', () {
        final labels = labelsFor(e.week);
        for (final label in labels) {
          expect(e.symptomTips.where((t) => t.symptom == label).length, 1, reason: '"$label"');
        }
        for (final t in e.symptomTips) {
          expect(labels, contains(t.symptom));
          expect(t.tip.trim(), isNotEmpty);
        }
      });

      test('every symptom link opens a real Symptoms door page', () {
        for (final t in e.symptomTips) {
          if (t.symptomId != null) {
            expect(symptomById(t.symptomId!), isNotNull, reason: t.symptomId);
          }
        }
      });

      test('two or three questions, each answered', () {
        expect(e.asked.length, inInclusiveRange(2, 3));
        for (final q in e.asked) {
          expect(q.q.trim(), isNotEmpty);
          expect(q.a.trim(), isNotEmpty);
        }
      });

      test('three to five sources, all vetted', () {
        expect(e.sources.length, inInclusiveRange(3, 5));
        expect(e.sources.toSet().length, e.sources.length);
        for (final s in e.sources) {
          expect(kPregWeekSources.keys, contains(s));
        }
      });

      test('voice: no dashes as punctuation, no "!", no banned words', () {
        final strings = [
          for (final t in e.symptomTips) t.tip,
          for (final q in e.asked) ...[q.q, q.a],
        ];
        for (final s in strings) {
          expect(s.contains('—'), isFalse, reason: s);
          expect(s.contains(' - '), isFalse, reason: s);
          expect(s.contains('!'), isFalse, reason: s);
          expect(s.trimLeft().toLowerCase().startsWith('remember'), isFalse, reason: s);
          final lower = s.toLowerCase();
          for (final b in _banned) {
            expect(RegExp('\\b${RegExp.escape(b)}\\b').hasMatch(lower), isFalse, reason: '"$b" in: $s');
          }
        }
      });
    });
  }
}
