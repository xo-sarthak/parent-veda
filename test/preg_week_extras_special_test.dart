// The pregnancy pages for weeks 1 to 3, 41 and 42 (weekContent.json runs 4 to
// 40). Pins their coverage, their sources and the voice rules of
// docs/PREG-VOICE.md.
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/preg_week_extras.dart';

List<String> _strings(PregSpecialWeekPage p) => [
      p.id,
      p.chipLabel,
      p.title,
      p.shortAnswer,
      if (p.callYourDoctor != null) p.callYourDoctor!,
      for (final s in p.sections) ...[s.heading, ...s.paragraphs, ...s.bullets],
      for (final q in p.asked) ...[q.q, q.a],
    ];

const _banned = [
  'journey', 'navigate', 'empower', 'delve', 'embark', 'holistic',
  'game-changer', 'crucial', "you've got this", 'rest assured',
  'we understand how you feel', "it's important to note",
  "it's worth noting", "let's dive in", 'genuinely', 'actually', 'quietly',
  'simply', 'truly', 'the single most', 'the one thing nobody tells you',
  "here's the thing", 'mama', 'mommy', 'momma', 'miracle', 'magical',
  'blessed', "don't worry",
];

void main() {
  final pages = kPregSpecialWeekPages;

  test('three pages with unique ids', () {
    expect(pages, hasLength(3));
    expect(pages.map((p) => p.id).toSet(),
        {'weeks_1_3', 'week_41', 'week_42'});
  });

  test('weeks cover exactly 1, 2, 3, 41 and 42 with no overlap', () {
    final all = [for (final p in pages) ...p.weeks];
    expect(all.toSet().length, all.length, reason: 'a week is on two pages');
    expect(all.toSet(), {1, 2, 3, 41, 42});
  });

  test('every page is filled in', () {
    for (final p in pages) {
      expect(p.sections.length, inInclusiveRange(3, 5), reason: p.id);
      expect(p.sources.length, inInclusiveRange(3, 5), reason: p.id);
      expect(p.callYourDoctor, isNotNull, reason: p.id);
      expect(p.shortAnswer.trim(), isNotEmpty, reason: p.id);
    }
  });

  test('every source is in the vetted list', () {
    for (final p in pages) {
      for (final s in p.sources) {
        expect(kPregWeekSources.containsKey(s), isTrue,
            reason: '${p.id} cites unknown source $s');
      }
    }
  });

  test('voice: no dashes as punctuation, no "!", no banned words', () {
    for (final p in pages) {
      for (final s in _strings(p)) {
        expect(s.contains('—'), isFalse, reason: '${p.id}: $s');
        expect(s.contains(' - '), isFalse, reason: '${p.id}: $s');
        expect(s.contains('!'), isFalse, reason: '${p.id}: $s');
        final lower = s.toLowerCase();
        for (final b in _banned) {
          expect(RegExp('\\b${RegExp.escape(b)}\\b').hasMatch(lower), isFalse,
              reason: '${p.id} uses "$b": $s');
        }
      }
    }
  });

  test('pregSpecialPageFor finds the right page', () {
    expect(pregSpecialPageFor(1)?.id, 'weeks_1_3');
    expect(pregSpecialPageFor(2)?.id, 'weeks_1_3');
    expect(pregSpecialPageFor(3)?.id, 'weeks_1_3');
    expect(pregSpecialPageFor(41)?.id, 'week_41');
    expect(pregSpecialPageFor(42)?.id, 'week_42');
    expect(pregSpecialPageFor(4), isNull);
    expect(pregSpecialPageFor(20), isNull);
    expect(pregSpecialPageFor(40), isNull);
  });

  test('the late weeks keep the movements warning and defer to the doctor', () {
    for (final id in ['week_41', 'week_42']) {
      final p = pages.firstWhere((p) => p.id == id);
      expect(p.callYourDoctor, contains('movements'));
      expect(p.callYourDoctor, contains('day or night'));
      expect(p.callYourDoctor, contains('green or brown'));
    }
  });
}
