// Week page extras, part c (weeks 29 to 40): the symptom tips pair with the
// week's own symptom list, every link opens a real Symptoms page, and the
// words keep to docs/PREG-VOICE.md.
//
// The pairing is by English label, and weekContent.json is edited by hand,
// so a relabelled symptom would silently lose its tip. This turns that into
// a failing build.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/preg_week_extras.dart';
import 'package:parentveda/data/preg_week_extras_c.dart';
import 'package:parentveda/data/symptoms/symptom_library.dart';

const _first = 29;
const _last = 40;

/// PREG-VOICE.md §4, the words and phrases.
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
  'worth noting',
  'dive in',
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

Map<int, List<String>> _labelsByWeek() {
  final raw = File('lib/data/weekContent.json').readAsStringSync();
  final out = <int, List<String>>{};
  for (final w in jsonDecode(raw) as List) {
    final m = w as Map;
    final week = m['week'] as int;
    final symptoms = (m['momJourney'] as Map)['commonSymptoms'] as List;
    out[week] = [for (final s in symptoms) (s as Map)['en'] as String];
  }
  return out;
}

List<String> _strings(PregWeekExtra e) => [
  for (final t in e.symptomTips) ...[t.symptom, t.tip],
  for (final q in e.asked) ...[q.q, q.a],
];

void main() {
  final labels = _labelsByWeek();

  test('part c holds weeks 29 to 40, once each, in the shared map', () {
    final weeks = [for (final e in kPregWeekExtrasC) e.week];
    expect(weeks, [for (var w = _first; w <= _last; w++) w]);
    for (var w = _first; w <= _last; w++) {
      expect(kPregWeekExtras[w], isNotNull, reason: 'week $w');
    }
  });

  for (final e in kPregWeekExtrasC) {
    group('week ${e.week}', () {
      test('one tip for every common symptom, and no others', () {
        final wanted = labels[e.week];
        expect(
          wanted,
          isNotNull,
          reason: 'weekContent.json has no week ${e.week}',
        );
        for (final label in wanted!) {
          final matches = e.symptomTips.where((t) => t.symptom == label).length;
          expect(matches, 1, reason: '"$label" should have exactly one tip');
        }
        expect(e.symptomTips.length, wanted.length);
        for (final t in e.symptomTips) {
          expect(t.tip.trim(), isNotEmpty, reason: t.symptom);
        }
      });

      test('every symptom link opens a real Symptoms page', () {
        for (final t in e.symptomTips) {
          final id = t.symptomId;
          if (id == null) continue;
          expect(symptomById(id), isNotNull, reason: '${t.symptom} -> $id');
        }
      });

      test('two or three questions, each answered', () {
        expect(e.asked.length, inInclusiveRange(2, 3));
        for (final q in e.asked) {
          expect(q.q.trim(), isNotEmpty);
          expect(q.a.trim(), isNotEmpty, reason: q.q);
        }
      });

      test('three to five sources, all from the vetted list', () {
        expect(e.sources.length, inInclusiveRange(3, 5));
        expect(
          e.sources.toSet().length,
          e.sources.length,
          reason: 'duplicate source',
        );
        for (final s in e.sources) {
          expect(kPregWeekSources.containsKey(s), isTrue, reason: s);
        }
      });

      test('keeps to the voice guide', () {
        for (final s in _strings(e)) {
          expect(s.contains('—'), isFalse, reason: 'em dash: $s');
          expect(s.contains(' - '), isFalse, reason: 'spaced hyphen: $s');
          expect(s.contains('!'), isFalse, reason: 'exclamation: $s');
          expect(s.startsWith('Remember'), isFalse, reason: 'opener: $s');
          final lower = s.toLowerCase();
          for (final w in _banned) {
            final hit = RegExp('\\b${RegExp.escape(w)}\\b').hasMatch(lower);
            expect(hit, isFalse, reason: 'banned "$w": $s');
          }
        }
      });
    });
  }
}
