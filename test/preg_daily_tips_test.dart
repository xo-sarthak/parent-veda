// Holds the daily pregnancy tips (lib/data/preg_daily_tips.dart) to their
// shape and to the voice rules in docs/PREG-VOICE.md §2 and §4.
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/preg_daily_tips.dart';

void main() {
  // docs/PREG-VOICE.md §4, the banned list (words matched as whole words,
  // phrases as written).
  const bannedWords = [
    'journey', 'navigate', 'empower', 'delve', 'embark', 'holistic',
    'game-changer', 'crucial', 'genuinely', 'actually', 'quietly', 'simply',
    'truly', 'mama', 'mommy', 'momma', 'miracle', 'magical', 'blessed',
  ];
  const bannedPhrases = [
    "you've got this", 'rest assured', 'we understand how you feel',
    "it's important to note", "it's worth noting", "let's dive in",
    'the single most', 'the one thing nobody tells you', "here's the thing",
    "don't worry",
  ];

  test('every week 4 to 40 has exactly 7 non-empty tips', () {
    for (var w = 4; w <= 40; w++) {
      final tips = kPregDailyTips[w];
      expect(tips, isNotNull, reason: 'week $w has no tips');
      expect(tips!.length, 7, reason: 'week $w');
      for (final t in tips) {
        expect(t.trim(), isNotEmpty, reason: 'week $w has an empty tip');
      }
    }
    expect(kPregDailyTips.keys.toSet(),
        {for (var w = 4; w <= 40; w++) w});
  });

  test('no tip uses dashes as punctuation, "!" or a banned word', () {
    for (final e in kPregDailyTips.entries) {
      for (final t in e.value) {
        final lower = t.toLowerCase();
        expect(t.contains('—'), isFalse, reason: 'em dash, week ${e.key}: $t');
        expect(t.contains(' - '), isFalse, reason: 'spaced hyphen, week ${e.key}: $t');
        expect(t.contains('!'), isFalse, reason: 'exclamation, week ${e.key}: $t');
        for (final w in bannedWords) {
          expect(RegExp('\\b${RegExp.escape(w)}\\b').hasMatch(lower), isFalse,
              reason: 'banned "$w", week ${e.key}: $t');
        }
        for (final p in bannedPhrases) {
          expect(lower.contains(p), isFalse,
              reason: 'banned "$p", week ${e.key}: $t');
        }
        expect(lower.startsWith('remember'), isFalse,
            reason: '"remember" as an opener, week ${e.key}: $t');
      }
    }
  });

  test('pregDailyTipFor picks the right tip and clamps', () {
    expect(pregDailyTipFor(12, 1), kPregDailyTips[12]![0]);
    expect(pregDailyTipFor(12, 7), kPregDailyTips[12]![6]);
    expect(pregDailyTipFor(2, 3), kPregDailyTips[4]![2]);
    expect(pregDailyTipFor(0, 1), kPregDailyTips[4]![0]);
    expect(pregDailyTipFor(42, 5), kPregDailyTips[40]![4]);
    expect(pregDailyTipFor(20, 0), kPregDailyTips[20]![0]);
    expect(pregDailyTipFor(20, 9), kPregDailyTips[20]![6]);
  });
}
