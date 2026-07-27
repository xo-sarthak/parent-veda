// =============================================================================
//  TTC - Today's Journey, the chapters, and the content library
// -----------------------------------------------------------------------------
//  The content tests here are not busywork. This stage's whole premise is
//  emotional posture, and posture lives in copy - so the rules that matter
//  (bilingual everywhere, couple-first, no gamification, a disclaimer on every
//  clinical surface) are pinned as tests rather than left to reviewer memory.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_chapter_screen.dart';
import 'package:parentveda/screens/ttc/ttc_insight_screen.dart';
import 'package:parentveda/screens/ttc/ttc_journal_screen.dart';
import 'package:parentveda/screens/ttc/ttc_ritual_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_chapter_data.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

/// Today's Journey is a long scroll, and a ListView only builds what is on
/// screen. These tests are about whether the whole daily set is present, so
/// they run on a tall surface rather than scrolling to each card in turn.
Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('the content library is bilingual everywhere', () {
    test('every insight carries both languages, genuinely different', () {
      for (final i in ttcInsights) {
        for (final hi in [true, false]) {
          expect(i.title(hi), isNotEmpty, reason: i.id);
          expect(i.body(hi), isNotEmpty, reason: i.id);
          expect(i.takeaway(hi), isNotEmpty, reason: i.id);
        }
        expect(i.title(true), isNot(i.title(false)), reason: i.id);
        expect(i.body(true), isNot(i.body(false)), reason: i.id);
      }
    });

    test('every myth carries both languages', () {
      for (final m in ttcMyths) {
        for (final hi in [true, false]) {
          expect(m.myth(hi), isNotEmpty, reason: m.id);
          expect(m.truth(hi), isNotEmpty, reason: m.id);
        }
        expect(m.truth(true), isNot(m.truth(false)), reason: m.id);
      }
    });

    test('every nutrition card carries its Indian-context line', () {
      for (final n in ttcNutrition) {
        for (final hi in [true, false]) {
          expect(n.indian(hi), isNotEmpty, reason: n.id);
          expect(n.meal(hi), isNotEmpty, reason: n.id);
          expect(n.why(hi), isNotEmpty, reason: n.id);
        }
      }
    });

    test('every movement carries both languages', () {
      for (final m in ttcMovements) {
        for (final hi in [true, false]) {
          expect(m.title(hi), isNotEmpty, reason: m.id);
          expect(m.body(hi), isNotEmpty, reason: m.id);
        }
      }
    });

    test('every journal prompt carries both languages', () {
      for (final p in ttcJournalPrompts) {
        expect(p.text(true), isNotEmpty, reason: p.id);
        expect(p.text(false), isNotEmpty, reason: p.id);
      }
    });

    test('ids are unique so a Directus swap can key on them', () {
      void unique(Iterable<String> ids, String what) {
        expect(ids.toSet().length, ids.length, reason: 'duplicate id in $what');
      }

      unique(ttcInsights.map((e) => e.id), 'insights');
      unique(ttcMyths.map((e) => e.id), 'myths');
      unique(ttcNutrition.map((e) => e.id), 'nutrition');
      unique(ttcMovements.map((e) => e.id), 'movements');
      unique(ttcJournalPrompts.map((e) => e.id), 'prompts');
    });
  });

  // ===========================================================================
  group('rotation is stable within a day', () {
    test('the same day gives the same insight', () {
      final a = ttcPickForToday(ttcInsights, now: DateTime(2026, 7, 27));
      final b = ttcPickForToday(ttcInsights, now: DateTime(2026, 7, 27));
      expect(identical(a, b), isTrue);
    });

    test('the next day gives a different one', () {
      final a = ttcPickForToday(ttcInsights, now: DateTime(2026, 7, 27));
      final b = ttcPickForToday(ttcInsights, now: DateTime(2026, 7, 28));
      expect(a.id, isNot(b.id));
    });

    test('the offsets keep the four daily cards from moving in lockstep', () {
      // Insight, nutrition and movement use different offsets so the whole page
      // does not change character on the same rhythm.
      final day = DateTime(2026, 7, 27);
      final i = ttcDayIndex(day) % ttcInsights.length;
      final n = (ttcDayIndex(day) + 1) % ttcNutrition.length;
      final m = (ttcDayIndex(day) + 2) % ttcMovements.length;
      expect({i, n, m}.length, greaterThan(1));
    });

    test('a year of days never goes out of range', () {
      for (var d = 0; d < 366; d++) {
        final day = DateTime(2026).add(Duration(days: d));
        expect(() => ttcPickForToday(ttcInsights, now: day), returnsNormally);
        expect(() => ttcPickForToday(ttcMyths, now: day, offset: 3),
            returnsNormally);
        expect(() => ttcPromptForToday(TtcChapter.theWaitingDays, now: day),
            returnsNormally);
      }
    });
  });

  // ===========================================================================
  group('the daily ritual', () {
    test('every chapter has all five parts', () {
      for (final c in TtcChapter.values) {
        final items = ttcRituals[c];
        expect(items, isNotNull, reason: '$c has no ritual');
        expect(items!.map((e) => e.part).toSet(), TtcRitualPart.values.toSet(),
            reason: '$c is missing a part');
      }
    });

    test('ritual text differs between chapters - it is not generic wellness',
        () {
      final waiting = ttcRituals[TtcChapter.theWaitingDays]!
          .firstWhere((e) => e.part == TtcRitualPart.gratitude);
      final trying = ttcRituals[TtcChapter.tryingTogether]!
          .firstWhere((e) => e.part == TtcRitualPart.gratitude);
      expect(waiting.text(false), isNot(trying.text(false)));
    });

    test('completing one part counts, and the streak starts at one', () {
      final s = TtcRitualStore.instance;
      expect(s.completedToday(), 0);
      expect(s.streak(), 0);
      s.toggle(TtcRitualPart.breath);
      expect(s.completedToday(), 1);
      expect(s.streak(), 1);
    });

    test('a day counts on ANY one part - not all five', () {
      final s = TtcRitualStore.instance;
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      s.toggle(TtcRitualPart.action, on: yesterday);
      s.toggle(TtcRitualPart.breath);
      expect(s.streak(), 2);
    });

    test('an untouched today does not break yesterday\'s streak', () {
      final s = TtcRitualStore.instance;
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      s.toggle(TtcRitualPart.breath, on: yesterday);
      // Nothing done today yet - the streak must survive until the day is over.
      expect(s.completedToday(), 0);
      expect(s.streak(), 1);
    });

    test('untoggling removes the day entirely rather than leaving a husk', () {
      final s = TtcRitualStore.instance;
      s.toggle(TtcRitualPart.breath);
      s.toggle(TtcRitualPart.breath);
      expect(s.completedToday(), 0);
      expect(s.streak(), 0);
    });
  });

  // ===========================================================================
  group('the journal', () {
    test('an entry round-trips through encoding', () {
      final e = TtcJournalStore.instance
          .add(kind: TtcEntryKind.memory, text: 'A quiet good day');
      final back = TtcJournalEntry.decode(e.encode());
      expect(back, isNotNull);
      expect(back!.text, e.text);
      expect(back.kind, e.kind);
      expect(back.id, e.id);
    });

    test('free text survives - quotes, newlines, commas and Devanagari', () {
      // This is why the store uses JSON rather than a delimiter: quietly
      // corrupting a letter to a future child is not an acceptable failure.
      const nasty = 'She said "maybe next month",\nand I wrote: सब ठीक है | ok';
      final e = TtcJournalStore.instance
          .add(kind: TtcEntryKind.letter, text: nasty);
      final back = TtcJournalEntry.decode(e.encode());
      expect(back!.text, nasty);
    });

    test('a corrupt row is dropped, never crashes the journal', () {
      expect(TtcJournalEntry.decode('not json at all'), isNull);
      expect(TtcJournalEntry.decode('{"id":1}'), isNull);
    });

    test('entries come back newest first', () {
      final s = TtcJournalStore.instance;
      s.add(
          kind: TtcEntryKind.memory,
          text: 'older',
          on: DateTime(2026, 1, 1));
      s.add(
          kind: TtcEntryKind.memory,
          text: 'newer',
          on: DateTime(2026, 6, 1));
      expect(s.entries.first.text, 'newer');
    });

    test('questions saved for the doctor are separable', () {
      final s = TtcJournalStore.instance;
      s.add(kind: TtcEntryKind.question, text: 'Ask about AMH');
      s.add(kind: TtcEntryKind.memory, text: 'Not a question');
      expect(s.doctorQuestions.length, 1);
      expect(s.doctorQuestions.first.text, 'Ask about AMH');
    });

    test('the author is recorded from day one, for the shared journal', () {
      final e = TtcJournalStore.instance.add(
          kind: TtcEntryKind.feeling,
          text: 'his entry',
          author: TtcAuthor.partner);
      expect(TtcJournalEntry.decode(e.encode())!.author, TtcAuthor.partner);
    });

    test('deleting removes it', () {
      final e =
          TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'x');
      TtcJournalStore.instance.remove(e.id);
      expect(TtcJournalStore.instance.count, 0);
    });
  });

  // ===========================================================================
  group('chapter content follows the product rules', () {
    test('all five chapters have content', () {
      for (final c in TtcChapter.values) {
        expect(ttcChapterContent[c], isNotNull, reason: '$c has no content');
      }
    });

    test('every chapter fills all three faces - Me, Us and Next', () {
      for (final c in TtcChapter.values) {
        final content = ttcChapterContent[c]!;
        expect(content.me, isNotEmpty, reason: '$c: Me is empty');
        expect(content.us, isNotEmpty, reason: '$c: Us is empty');
        expect(content.next, isNotEmpty, reason: '$c: Next is empty');
      }
    });

    test('couple-first: every action plan has something that is his', () {
      for (final c in TtcChapter.values) {
        final actions = ttcChapterContent[c]!.actions;
        expect(actions.any((a) => a.forPartner), isTrue,
            reason: '$c: every action belongs to her - not a couple-first plan');
      }
    });

    test('every chapter carries medical guidance in both languages', () {
      for (final c in TtcChapter.values) {
        final content = ttcChapterContent[c]!;
        expect(content.medical(false), isNotEmpty, reason: '$c');
        expect(content.medical(true), isNotEmpty, reason: '$c');
      }
    });

    test('every chapter offers Ask Veda questions in both languages', () {
      for (final c in TtcChapter.values) {
        final content = ttcChapterContent[c]!;
        expect(content.askVeda(false), isNotEmpty, reason: '$c');
        expect(content.askVeda(true).length, content.askVeda(false).length,
            reason: '$c: the two languages offer different questions');
      }
    });

    test('all chapter copy is bilingual and genuinely translated', () {
      for (final c in TtcChapter.values) {
        final content = ttcChapterContent[c]!;
        expect(content.overview(true), isNot(content.overview(false)),
            reason: '$c overview');
        for (final s in [...content.me, ...content.us, ...content.next]) {
          expect(s.title(true), isNotEmpty);
          expect(s.body(true), isNotEmpty);
          expect(s.body(true), isNot(s.body(false)));
        }
      }
    });
  });

  // ===========================================================================
  group('no gamification, no blame - pinned as a test', () {
    // The master document devotes a whole section to what the product will
    // NEVER say. Left to review alone, this is exactly the kind of rule that
    // erodes one well-meaning card at a time.
    // Phrases with no innocent reading. "your fault" is deliberately NOT here:
    // the product says "it is not your fault" on purpose, and a naive substring
    // ban would forbid the reassurance along with the blame. It gets its own
    // test below instead.
    const banned = [
      'you failed',
      'you missed',
      'missed your fertile',
      'you are behind',
      'perfect cycle',
      'streak lost',
      'try harder',
      'should have',
    ];

    String allCopy() {
      final b = StringBuffer();
      for (final hi in [true, false]) {
        for (final i in ttcInsights) {
          b.writeln(i.title(hi));
          b.writeln(i.body(hi));
          b.writeln(i.takeaway(hi));
        }
        for (final m in ttcMyths) {
          // A myth QUOTES the wrong belief in order to correct it, so only the
          // truth half is held to this rule.
          b.writeln(m.truth(hi));
        }
        for (final c in TtcChapter.values) {
          final content = ttcChapterContent[c]!;
          b.writeln(content.overview(hi));
          b.writeln(content.medical(hi));
          for (final s in [...content.me, ...content.us, ...content.next]) {
            b.writeln(s.body(hi));
          }
          for (final a in content.actions) {
            b.writeln(a.text(hi));
          }
          for (final r in ttcRituals[c]!) {
            b.writeln(r.text(hi));
          }
        }
      }
      return b.toString().toLowerCase();
    }

    test('no copy anywhere blames or scores the couple', () {
      final copy = allCopy();
      for (final phrase in banned) {
        expect(copy.contains(phrase), isFalse,
            reason: 'content says "$phrase"');
      }
    });

    test('"fault" only ever appears as reassurance, never as an accusation',
        () {
      // Stripping the negated form first: whatever is left is blame.
      final copy = allCopy()
          .replaceAll('not your fault', '')
          .replaceAll('aapki galti nahi', '');
      expect(copy.contains('your fault'), isFalse);
      expect(copy.contains('aapki galti'), isFalse);
    });

    test('the waiting-days chapter never presents a countdown', () {
      final content = ttcChapterContent[TtcChapter.theWaitingDays]!;
      final copy = [
        content.overview(false),
        ...content.me.map((s) => s.body(false)),
        ...content.next.map((s) => s.body(false)),
      ].join(' ').toLowerCase();
      expect(copy.contains('countdown'), isFalse);
      expect(copy.contains('days left'), isFalse);
    });
  });

  // ===========================================================================
  group('Today renders the whole daily set', () {
    testWidgets('every section is on the screen', (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      final t = const TtcS(false);
      // These are eyebrows, which render uppercase.
      for (final label in [
        t.todaysInsight,
        t.todaysVideo,
        t.dailyRitual,
        t.todaysMyth,
        t.todaysNutrition,
        t.todaysMovement,
      ]) {
        expect(find.text(label.toUpperCase()), findsWidgets,
            reason: 'missing section: $label');
      }
      // The journal leads with a card title rather than an eyebrow.
      expect(find.text(t.myJournal), findsWidgets);
      // Today's pick sits last on purpose: education, then confidence, then
      // recommendation, then commerce.
      expect(find.text(t.todaysPick.toUpperCase()), findsOneWidget);
      expect(find.text(t.productsWatchOut), findsOneWidget);
    });

    testWidgets('the ritual shows 0/5 before anything is done', (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      expect(find.text('0/5'), findsOneWidget);
    });

    testWidgets('ticking a ritual part updates the counter live',
        (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      TtcRitualStore.instance.toggle(TtcRitualPart.breath);
      await tester.pump();
      expect(find.text('1/5'), findsOneWidget);
    });

    testWidgets('a hero shortcut opens the chapter page', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TtcTodayScreen()));
      await tester.pump();
      await tester.tap(find.text(const TtcS(false).shortcutUs));
      await tester.pumpAndSettle();
      expect(find.byType(TtcChapterScreen), findsOneWidget);
    });

    testWidgets('the insight card opens the reader', (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      final insight = ttcPickForToday(ttcInsights);
      await tester.tap(find.text(insight.title(false)).first);
      await tester.pumpAndSettle();
      expect(find.byType(TtcInsightScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the chapter page', () {
    testWidgets('all five chapters build on all three faces', (tester) async {
      for (final c in TtcChapter.values) {
        for (final tab in TtcChapterTab.values) {
          await tester.pumpWidget(MaterialApp(
              home: TtcChapterScreen(chapter: c, initialTab: tab)));
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$c / $tab threw');
        }
      }
    });

    testWidgets('switching face changes the content', (tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: TtcChapterScreen(chapter: TtcChapter.preparingTogether)));
      await tester.pump();
      final content = ttcChapterContent[TtcChapter.preparingTogether]!;
      expect(find.text(content.me.first.title(false)), findsOneWidget);

      await tester.tap(find.text(const TtcS(false).chapterTabUs));
      await tester.pumpAndSettle();
      expect(find.text(content.us.first.title(false)), findsOneWidget);
    });

    testWidgets('the action plan and medical guidance live on What\'s next',
        (tester) async {
      await pumpTall(
          tester,
          const TtcChapterScreen(
              chapter: TtcChapter.preparingTogether,
              initialTab: TtcChapterTab.next));
      final t = const TtcS(false);
      expect(find.text(t.chapterActions), findsOneWidget);
      expect(find.text(t.chapterMedical), findsOneWidget);
    });

    testWidgets('the current chapter is marked "you are here"', (tester) async {
      final current = TtcStore.instance.today.chapter;
      await tester.pumpWidget(
          MaterialApp(home: TtcChapterScreen(chapter: current)));
      await tester.pump();
      expect(find.text(const TtcS(false).chapterYouAreHere), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the ritual and journal screens', () {
    testWidgets('the ritual page builds for every chapter', (tester) async {
      for (final c in TtcChapter.values) {
        await tester
            .pumpWidget(MaterialApp(home: TtcRitualScreen(chapter: c)));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$c threw');
      }
    });

    testWidgets('the journal invites rather than showing a blank page',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TtcJournalScreen()));
      await tester.pump();
      expect(find.text(const TtcS(false).journalEmptyTitle), findsOneWidget);
    });

    testWidgets('a saved entry appears in the list', (tester) async {
      TtcJournalStore.instance
          .add(kind: TtcEntryKind.memory, text: 'A good quiet day');
      await tester.pumpWidget(const MaterialApp(home: TtcJournalScreen()));
      await tester.pump();
      expect(find.text('A good quiet day'), findsOneWidget);
    });
  });
}
