// =============================================================================
//  Garbh Sanskar rebuild - the rules the spec calls non-negotiable
// -----------------------------------------------------------------------------
//  The rebuild rests on one principle: she is not completing a practice, she is
//  making something for her child. Two rules fall out of it and both are the
//  kind that erode quietly rather than break loudly, which is why they are here
//  rather than in a comment.
//
//    1. Completion is earned by doing, never claimed.
//    2. Everything she does accumulates. Nothing is consumed and discarded.
//
//  ⚠️ RULE 1 IS THE ONE MOST LIKELY TO COME BACK. "Mark complete" is the
//  obvious thing to add to any screen with a practice on it, it takes one line,
//  and it looks like a kindness. What it actually did on Kriya was sit beside
//  "Start" at identical weight, so the honest path and the skip path cost the
//  same and recorded the same thing - and a section whose whole premise is that
//  she is making something was issuing receipts for nothing.
//
//  ⚠️ AND ONE CLAIM THAT MUST NEVER APPEAR: that any of this makes the baby
//  cleverer. There is no evidence for it, and it is the exact misinformation
//  this product is positioned against. Buddhi is the pillar where the
//  temptation lives, because it is puzzles.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/garbh_data.dart';
import 'package:parentveda/data/garbh_rebuild_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/garbh_buddhi_screen.dart';
import 'package:parentveda/screens/garbh_daily_screen.dart';
import 'package:parentveda/screens/garbh_journal_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

PregnancyController _at(int week) {
  final now = DateTime(2026, 1, 1);
  return PregnancyController(
      now: now, dueDate: now.add(Duration(days: (40 - week) * 7)));
}

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(420, 5200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

GarbhJournalEntry _entry(
        {required int week, GarbhEntryKind kind = GarbhEntryKind.myVoice,
        int seconds = 60, String? rel, String id = 'e1'}) =>
    GarbhJournalEntry(
      id: id,
      kind: kind,
      week: week,
      tsMs: DateTime(2026, 1, 1).millisecondsSinceEpoch + week,
      title: LocalizedText(en: 'Entry $id', hi: 'Entry $id'),
      seconds: seconds,
      relationship: rel,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() => GarbhJournalStore.instance.resetForTest());

  // ===========================================================================
  //  1 · Completion is earned, never claimed
  // ===========================================================================

  group('no "Mark complete" survives anywhere in this section', () {
    testWidgets('the daily card offers no claim button', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhDailyScreen(pregnancy: c));

      for (final label in ['Mark complete', 'Mark done', 'Mark as done']) {
        expect(find.text(label), findsNothing, reason: label);
      }
    });

    testWidgets('Buddhi says it finishes on its own', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhBuddhiScreen(controller: c, daily: true));

      expect(find.textContaining('finishes on its own'), findsOneWidget);
      expect(find.text('Mark complete'), findsNothing);
    });
  });

  // ===========================================================================
  //  2 · Buddhi promises her calm, never a cleverer baby
  // ===========================================================================

  group('Buddhi makes no claim about the baby', () {
    testWidgets('it says so outright, and never the opposite', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhBuddhiScreen(controller: c, daily: true));

      // ⚠️ THE POSITIVE ASSERTION MATTERS AS MUCH AS THE NEGATIVE ONE. A page
      // that simply omits the claim leaves a mother to assume it, because
      // every competitor in this category makes it.
      expect(find.textContaining('will not make your baby cleverer'),
          findsOneWidget);
      expect(find.textContaining('This one is not'), findsOneWidget);
    });

    testWidgets('it says it does not go into My Journal', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhBuddhiScreen(controller: c, daily: true));

      // She will have watched three other pillars land there, so the absence
      // needs a reason or it reads as a bug.
      expect(find.textContaining('Nothing here goes into My Journal'),
          findsOneWidget);
    });

    testWidgets('it serves one puzzle as today, not a menu of four',
        (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhBuddhiScreen(controller: c, daily: true));
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('MORE'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  3 · Why today, and not any other day
  // ===========================================================================

  group('the week reason is about development, not encouragement', () {
    test('every week from 1 to 40 has a line', () {
      for (var w = 1; w <= 40; w++) {
        expect(garbhWeekReason(w).en.trim(), isNotEmpty, reason: 'week $w');
      }
    });

    test('week 22 is about hearing, which is what makes today matter', () {
      expect(garbhWeekReason(22).en.toLowerCase(), contains('hearing'));
    });

    test('no line praises her effort instead of naming a fact', () {
      // ⚠️ "You are doing so well" is true in ANY week, which is exactly what
      // makes it useless here: a reason that applies every day is not a reason
      // to do something today.
      const praise = ['you are doing', 'well done', 'keep going', 'proud'];
      for (final r in kGarbhWeekReasons) {
        final l = r.line.en.toLowerCase();
        for (final p in praise) {
          expect(l.contains(p), isFalse, reason: '"${r.line.en}"');
        }
      }
    });

    test('no line claims a practice improves development', () {
      const overclaim = ['smarter', 'cleverer', 'higher iq', 'boost'];
      for (final r in kGarbhWeekReasons) {
        final l = r.line.en.toLowerCase();
        for (final o in overclaim) {
          expect(l.contains(o), isFalse, reason: '"${r.line.en}"');
        }
      }
    });

    testWidgets('it renders on the daily card, keyed to her week', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhDailyScreen(pregnancy: c));
      expect(find.text('WHY WEEK 22 MATTERS'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  4 · My Journal accumulates, and counts the right thing
  // ===========================================================================

  group('My Journal', () {
    test('groups by the week stamped at creation, newest first', () {
      final s = GarbhJournalStore.instance;
      s.add(_entry(week: 20, id: 'a'));
      s.add(_entry(week: 22, id: 'b'));
      s.add(_entry(week: 20, id: 'c'));

      expect(s.byWeek.keys.toList(), [22, 20]);
      expect(s.byWeek[20]!.length, 2);
    });

    test('the header counts HER voice, not everything', () {
      final s = GarbhJournalStore.instance;
      s.add(_entry(week: 22, kind: GarbhEntryKind.myVoice, seconds: 100, id: 'a'));
      s.add(_entry(week: 22, kind: GarbhEntryKind.heard, seconds: 900, id: 'b'));

      // ⚠️ A TOTAL INCLUDING RAGAS WOULD BE A BIGGER NUMBER AND A WORSE ONE.
      // She did not make the raga; reading "17 minutes of your voice" when
      // most of it is a music track is flattery, not information.
      expect(s.myVoiceSeconds, 100);
      expect(s.myVoiceCount, 1);
    });

    test('family recordings are counted separately, with her label kept', () {
      final s = GarbhJournalStore.instance;
      s.add(_entry(
          week: 22, kind: GarbhEntryKind.familyVoice, rel: 'Dadi', id: 'f'));
      expect(s.familyCount, 1);
      expect(s.myVoiceCount, 0);
      // The label is HER word, stored with the recording rather than derived
      // from a sender identity.
      expect(s.entries.first.relationship, 'Dadi');
    });

    testWidgets('an empty album says what it will become', (t) async {
      await _pump(t, const GarbhJournalScreen());
      // ⚠️ THE MOST IMPORTANT EMPTY STATE IN THE SECTION: it is what a mother
      // sees on day one, before she has any reason to believe this is for
      // anything.
      expect(find.textContaining('that is only today'), findsOneWidget);
      expect(find.textContaining('months of your voice'), findsOneWidget);
    });

    testWidgets('a filled album groups under week headings', (t) async {
      GarbhJournalStore.instance.add(_entry(week: 22, id: 'a'));
      await _pump(t, const GarbhJournalScreen());
      expect(find.text('WEEK 22'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  5 · My ritual is multi-faith and the Gita plan lands before the birth
  // ===========================================================================

  group('My ritual', () {
    test('the list is genuinely multi-faith', () {
      final ids = kGarbhRituals.map((r) => r.id).toSet();
      for (final id in ['gita_40', 'quran', 'bible', 'silence', 'japa']) {
        expect(ids.contains(id), isTrue, reason: id);
      }
    });

    test('the Gita plan finishes the week BEFORE the due date', () {
      // ⚠️ NOT ON IT. A plan completing on the due date completes on a day she
      // is quite likely to be in labour, or to have delivered a week earlier.
      // Finishing early means the arc closes while she is there to see it.
      final p = gitaPlanProgress(39);
      expect(p.finishWeek, 39);
      expect(p.weeksLeft, 0);
      expect(p.progress, 1.0);
    });

    test('progress is partial mid-pregnancy and never exceeds one', () {
      expect(gitaPlanProgress(20).progress, closeTo(20 / 39, 0.001));
      expect(gitaPlanProgress(45).progress, 1.0);
      expect(gitaPlanProgress(45).weeksLeft, 0);
    });

    test('japa is the one with a counter', () {
      expect(garbhRitualById('japa')!.hasCounter, isTrue);
      expect(garbhRitualById('gita_40')!.isPlan, isTrue);
      expect(garbhRitualById('silence')!.isPlan, isFalse);
    });
  });

  // ===========================================================================
  //  6 · Vichara is gone, Buddhi took its place
  // ===========================================================================

  testWidgets('the daily card shows Buddhi and not Vichara', (t) async {
    final c = _at(22);
    addTearDown(c.dispose);
    await _pump(t, GarbhDailyScreen(pregnancy: c));

    expect(find.text('Buddhi'), findsOneWidget);
    expect(find.text('Vichara'), findsNothing);
    // The other three are untouched.
    expect(find.text('Shravan'), findsOneWidget);
    expect(find.text('Samvad'), findsOneWidget);
    expect(find.text('Kriya'), findsOneWidget);
  });

  test('the four puzzles Buddhi serves are the ones that already shipped', () {
    // Promotion, not new content - the point of the change is that these were
    // buried behind a door named after something else.
    expect(kPuzzles.length, 4);
  });
}
