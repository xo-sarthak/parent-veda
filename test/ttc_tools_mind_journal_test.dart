// =============================================================================
//  TTC tools pass, 2026-09-27: mind, ritual, journal, care circle, course,
//  practice player, food ideas.
// -----------------------------------------------------------------------------
//  One focused test per behaviour fix, so each one fails loudly if it slides
//  back: a tap on a journal entry reads it (it used to offer only "Delete?"),
//  delete sits behind a menu and a confirm, a prompt travels into the entry,
//  the ritual shows ticks and no score, the care circle has no dead plus
//  buttons, an empty clock opens at a sensible hour and a cancelled one saves
//  nothing, the practice player has labelled step controls, and the food ideas
//  can swap a day and only link recipes that exist.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/nutrition_data.dart' show kRecipes;
import 'package:parentveda/screens/ttc/ttc_care_circle_screen.dart';
import 'package:parentveda/screens/ttc/ttc_garbh_course_screen.dart';
// Kept for revert (2026-09-28, the user: no journal in trying to conceive).
// import 'package:parentveda/screens/ttc/ttc_journal_screen.dart';
import 'package:parentveda/screens/ttc/ttc_mind_today_screen.dart';
import 'package:parentveda/screens/ttc/ttc_nutrition_screen.dart';
import 'package:parentveda/screens/ttc/ttc_practice_screen.dart';
import 'package:parentveda/screens/ttc/ttc_ritual_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_garbh_course.dart';
import 'package:parentveda/ttc/ttc_garbh_course_store.dart';
// import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {double width = 400, double height = 3000}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcStore.instance.resetForTest();
    // Kept for revert (2026-09-28): TtcJournalStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcGarbhCourseStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  // Kept for revert (2026-09-28, the user: no journal in trying to conceive).
  // The journal page and store are commented out; these two groups with them.
  // group('the journal store: an edit changes her own words only', () {
  //   test('her entry changes, keeping its id, date, kind and prompt', () {
  //     final e = TtcJournalStore.instance.add(
  //         kind: TtcEntryKind.letter, text: 'First words', prompt: 'A prompt');
  //     expect(TtcJournalStore.instance.update(e.id, text: '  Better words '),
  //         isTrue);
  //     final after = TtcJournalStore.instance.entries.single;
  //     expect(after.id, e.id);
  //     expect(after.dateIso, e.dateIso);
  //     expect(after.kind, TtcEntryKind.letter);
  //     expect(after.prompt, 'A prompt');
  //     expect(after.text, 'Better words');
  //   });
  //
  //   test("a partner's entry and an empty edit are refused", () {
  //     final his = TtcJournalStore.instance.add(
  //         kind: TtcEntryKind.memory, text: 'His', author: TtcAuthor.partner);
  //     expect(TtcJournalStore.instance.update(his.id, text: 'Changed'),
  //         isFalse);
  //     final mine =
  //         TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'Mine');
  //     expect(TtcJournalStore.instance.update(mine.id, text: '   '), isFalse);
  //     expect(
  //         TtcJournalStore.instance.entries.map((e) => e.text).toSet(),
  //         {'His', 'Mine'});
  //   });
  // });
  //
  // // ===========================================================================
  // group('the journal page', () {
  //   testWidgets('says who can read it, once', (tester) async {
  //     await _pump(tester, const TtcJournalScreen());
  //     expect(find.text(ttcJournalWhoSees(false)), findsOneWidget);
  //     TtcStore.instance.setPartnerJoined(true);
  //     await tester.pump();
  //     expect(find.text(ttcJournalWhoSees(true)), findsOneWidget);
  //   });
  //
  //   testWidgets('a tap on an entry READS it; it never offers delete',
  //       (tester) async {
  //     TtcJournalStore.instance
  //         .add(kind: TtcEntryKind.letter, text: 'Dear little one');
  //     await _pump(tester, const TtcJournalScreen());
  //     await tester.tap(find.text('Dear little one'));
  //     await tester.pumpAndSettle();
  //     expect(find.byType(TtcJournalEntryScreen), findsOneWidget);
  //     expect(find.byType(AlertDialog), findsNothing,
  //         reason: 'a tap used to open "Delete this entry?"');
  //     expect(find.text('Edit'), findsOneWidget);
  //     expect(TtcJournalStore.instance.count, 1);
  //   });
  //
  //   testWidgets('delete is behind the menu AND a confirm; Keep it keeps it',
  //       (tester) async {
  //     TtcJournalStore.instance
  //         .add(kind: TtcEntryKind.memory, text: 'A quiet day');
  //     await _pump(tester, const TtcJournalScreen());
  //     await tester.tap(find.text('A quiet day'));
  //     await tester.pumpAndSettle();
  //
  //     await tester.tap(find.byTooltip('More'));
  //     await tester.pumpAndSettle();
  //     await tester.tap(find.text('Delete entry'));
  //     await tester.pumpAndSettle();
  //     expect(find.text('Delete this entry?'), findsOneWidget);
  //     await tester.tap(find.text('Keep it'));
  //     await tester.pumpAndSettle();
  //     expect(TtcJournalStore.instance.count, 1);
  //
  //     await tester.tap(find.byTooltip('More'));
  //     await tester.pumpAndSettle();
  //     await tester.tap(find.text('Delete entry'));
  //     await tester.pumpAndSettle();
  //     await tester.tap(find.text('Delete'));
  //     await tester.pumpAndSettle();
  //     expect(TtcJournalStore.instance.count, 0);
  //     expect(find.byType(TtcJournalEntryScreen), findsNothing,
  //         reason: 'the page closes on the entry it deleted');
  //   });
  //
  //   testWidgets("his entry can be read, not edited or deleted here",
  //       (tester) async {
  //     TtcJournalStore.instance.add(
  //         kind: TtcEntryKind.feeling,
  //         text: 'From him',
  //         author: TtcAuthor.partner);
  //     await _pump(tester, const TtcJournalScreen());
  //     await tester.tap(find.text('From him'));
  //     await tester.pumpAndSettle();
  //     expect(find.text('Edit'), findsNothing);
  //     expect(find.byTooltip('More'), findsNothing);
  //   });
  //
  //   testWidgets('the prompt card opens the writer WITH the prompt, and saves it',
  //       (tester) async {
  //     await _pump(tester, const TtcJournalScreen());
  //     final prompt =
  //         ttcPromptForToday(TtcStore.instance.today.chapter).text(false);
  //     // T11 (2026-09-28): one write button; the prompt is a tappable line
  //     // under it. Kept for revert: find.text('Write about this')
  //     await tester.tap(find.byKey(const ValueKey('ttc_journal_prompt')));
  //     await tester.pumpAndSettle();
  //     expect(find.byType(TtcJournalWriteScreen), findsOneWidget);
  //     expect(find.text(prompt), findsOneWidget,
  //         reason: 'the prompt has to travel into the writer');
  //     await tester.enterText(find.byType(TextField), 'My answer');
  //     await tester.pump();
  //     await tester.tap(find.text('Save'));
  //     await tester.pumpAndSettle();
  //     final e = TtcJournalStore.instance.entries.single;
  //     expect(e.text, 'My answer');
  //     expect(e.prompt, prompt);
  //   });
  //
  //   testWidgets('the writer lets her pick the kind; empty Save does nothing',
  //       (tester) async {
  //     await _pump(tester, const TtcJournalScreen());
  //     await tester.tap(find.text('Write something'));
  //     await tester.pumpAndSettle();
  //     await tester.tap(find.text('Save'));
  //     await tester.pumpAndSettle();
  //     expect(TtcJournalStore.instance.count, 0);
  //     expect(find.byType(TtcJournalWriteScreen), findsOneWidget);
  //
  //     await tester.tap(find.text(TtcEntryKind.question.label(false)));
  //     await tester.pump();
  //     expect(find.textContaining('Appointments page'), findsOneWidget,
  //         reason: 'a question for the doctor says where it goes');
  //     await tester.enterText(find.byType(TextField), 'Ask about AMH');
  //     await tester.pump();
  //     await tester.tap(find.text('Save'));
  //     await tester.pumpAndSettle();
  //     expect(TtcJournalStore.instance.entries.single.kind,
  //         TtcEntryKind.question);
  //   });
  //
  //   testWidgets('leaving with words typed asks first', (tester) async {
  //     await _pump(tester, const TtcJournalScreen());
  //     await tester.tap(find.text('Write something'));
  //     await tester.pumpAndSettle();
  //     await tester.enterText(find.byType(TextField), 'Half a thought');
  //     await tester.pump();
  //     await tester.tap(find.byTooltip('Close'));
  //     await tester.pumpAndSettle();
  //     expect(find.text('Discard this entry?'), findsOneWidget);
  //     await tester.tap(find.text('Keep writing'));
  //     await tester.pumpAndSettle();
  //     expect(find.byType(TtcJournalWriteScreen), findsOneWidget);
  //   });
  //
  //   testWidgets('an edit from the entry page changes the words in place',
  //       (tester) async {
  //     TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'Before');
  //     await _pump(tester, const TtcJournalScreen());
  //     await tester.tap(find.text('Before'));
  //     await tester.pumpAndSettle();
  //     await tester.tap(find.text('Edit'));
  //     await tester.pumpAndSettle();
  //     await tester.enterText(find.byType(TextField), 'After');
  //     await tester.pump();
  //     await tester.tap(find.text('Save'));
  //     await tester.pumpAndSettle();
  //     expect(TtcJournalStore.instance.entries.single.text, 'After');
  //     expect(TtcJournalStore.instance.count, 1);
  //   });
  // });
  //
  // // ===========================================================================
  group('the ritual: ticks, no score, one part open', () {
    testWidgets('no "0/5" count, and the header says any one part is enough',
        (tester) async {
      await _pump(tester,
          const TtcRitualScreen(chapter: TtcChapter.tryingTogether));
      expect(find.textContaining('/5'), findsNothing);
      // The intro is one block with the chapter's reason since 2026-09-28,
      // and names the part. Kept for revert:
      //   expect(find.textContaining("Do any one and that's enough"),
      //       findsOneWidget);
      expect(find.textContaining('doing any one part is enough for today'),
          findsOneWidget);
      // No chapter name on its own (the user, 2026-09-27).
      expect(find.textContaining(TtcChapter.tryingTogether.title(false)),
          findsNothing);
    });

    testWidgets('one part open at a time; ticking shows what is done',
        (tester) async {
      await _pump(tester,
          const TtcRitualScreen(chapter: TtcChapter.tryingTogether));
      final mark = find.text(const TtcS(false).ritualMarkDone);
      expect(mark, findsOneWidget, reason: 'only the open part has a button');
      await tester.tap(mark);
      await tester.pump();
      expect(TtcRitualStore.instance.completedToday(), 1);
      expect(find.textContaining('Done today:'), findsOneWidget);
      // Opening another part closes the first.
      await tester.tap(find.text(TtcRitualPart.gratitude.title(false)));
      await tester.pump();
      expect(find.text(const TtcS(false).ritualMarkDone), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the care circle', () {
    testWidgets('no dead plus buttons; one honest line instead',
        (tester) async {
      await _pump(tester, const TtcCareCircleScreen());
      expect(find.byIcon(Icons.add_rounded), findsNothing);
      expect(find.textContaining("Soon you'll be able to add your doctor"),
          findsOneWidget);
      expect(kTtcCareCircleShowAddRows, isFalse);
    });

    testWidgets('the partner card is the invite when he has not joined',
        (tester) async {
      await _pump(tester, const TtcCareCircleScreen());
      // ⚠️ THE ROW SAYS ITS ACTION (2026-09-27, tools rebuild): every member
      // of the circle now names what a tap does. Kept for revert:
      //   expect(find.textContaining('Tap to invite'), findsOneWidget);
      expect(find.text('Invite your partner'), findsOneWidget);
      TtcStore.instance.setPartnerJoined(true);
      await tester.pump();
      expect(find.text('Invite your partner'), findsNothing);
      expect(find.text('See what your partner can see'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the course: an empty clock opens at a sensible hour', () {
    test('defaults per row', () {
      expect(kTtcDefaultWake, const TimeOfDay(hour: 6, minute: 30));
      expect(kTtcDefaultBed, const TimeOfDay(hour: 23, minute: 0));
      expect(kTtcDefaultMeals, const [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 13, minute: 0),
        TimeOfDay(hour: 20, minute: 0),
      ]);
    });

    testWidgets('a cancelled clock saves nothing', (tester) async {
      await _pump(tester,
          TtcCourseSessionScreen(session: ttcCourseSessionById('gs_body')!),
          height: 5000);
      // The clocks live on the session's "Keep it" part since the session was
      // split into parts (2026-09-27, tools rebuild). The part is named
      // "Your plan" since 2026-09-28. Kept for revert:
      //   await tester.tap(find.textContaining('Keep it'));
      await tester.tap(find.textContaining('Your plan'));
      await tester.pump();
      await tester.tap(find.text('Wake'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(TtcGarbhCourseStore.instance.wakeTime, isNull);
    });

    test('the session-one step matches its panel (no "four things")', () {
      final s1 = kTtcCourseSessions.first;
      expect(s1.steps.join(' '), isNot(contains('four things')));
    });
  });

  // ===========================================================================
  group('the practice player', () {
    testWidgets('labelled Previous and Next step controls move the lit step',
        (tester) async {
      final practice = ttcPracticesOfKind(TtcPracticeKind.move).first;
      await _pump(tester, TtcPracticeScreen(practice: practice),
          height: 4000);
      expect(find.text('Previous step'), findsOneWidget);
      expect(find.text('Next step'), findsOneWidget);
      // Twice since 2026-09-27: the list's counter, and the ring, which says
      // the step while the steps follow the timer. Kept for revert:
      //   expect(find.text('Step 1 of ${practice.steps.length}'), findsOneWidget);
      // Once since 2026-09-28 (launch sanity MB14): one step counter, in the
      // ring while the steps follow the timer. Kept for revert:
      //   expect(find.text('Step 1 of ${practice.steps.length}'), findsNWidgets(2));
      expect(find.text('Step 1 of ${practice.steps.length}'), findsOneWidget);
      await tester.tap(find.text('Next step'));
      await tester.pump();
      expect(find.text('Step 2 of ${practice.steps.length}'), findsOneWidget);
      await tester.tap(find.text('Previous step'));
      await tester.pump();
      expect(find.text('Step 1 of ${practice.steps.length}'), findsOneWidget);
      // The line under Mark done says the timer marks it done (2026-09-27);
      // "Tap again to undo" shows once it is done. Kept for revert:
      //   expect(find.textContaining('Tap again to undo'), findsOneWidget);
      expect(find.textContaining('Finishing the timer marks it done'),
          findsOneWidget);
    });
  });

  // ===========================================================================
  group('Mind and body Today', () {
    testWidgets('says what Start does, and the bedtime can be set here',
        (tester) async {
      await _pump(tester, const TtcMindTodayScreen(), height: 4000);
      // Since 2026-09-28 Start is a real button and the help line is gone
      // (the player explains itself). Kept for revert:
      //   expect(find.textContaining('Opens the steps and a timer'), findsWidgets);
      // Named since 2026-09-28. Kept for revert: find.text('Start').
      expect(find.text('Start practice'), findsWidgets);
      expect(find.textContaining('Opens the steps and a timer'), findsNothing);
      expect(find.text('Pick your own time'), findsOneWidget);
      await tester.tap(find.text('Pick your own time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(TtcGarbhCourseStore.instance.bedtime, isNull,
          reason: 'a cancelled clock must not save a bedtime');
    });
  });

  // ===========================================================================
  group("this week's food ideas", () {
    test('every linked recipe exists in the recipe library', () {
      for (final entry in kTtcNutritionRecipes.entries) {
        expect(ttcNutrition.any((n) => n.id == entry.key), isTrue,
            reason: 'no food idea ${entry.key}');
        expect(kRecipes.any((r) => r.id == entry.value), isTrue,
            reason: 'recipe ${entry.value} is gone; the link would be dead');
      }
    });

    test('a swap never lands on an idea already shown this week', () {
      final week = TtcNutritionScreen.weekFrom(DateTime(2026, 9, 27));
      final shown = {for (final e in week) e.$2.id};
      final next = ttcNextNutritionIdea(week.first.$2, shown);
      expect(next.id, isNot(week.first.$2.id));
      expect(shown.contains(next.id), isFalse);
    });

    testWidgets('the page is named for what it is, and Swap changes a day',
        (tester) async {
      await _pump(tester, const TtcNutritionScreen(), height: 5000);
      // ⚠️ ONE SHELL, ONE NAME (2026-09-27): the page wears the tool shell
      // now, and its name is the hero's eyebrow, set in capitals. Kept for
      // revert: expect(find.text("This week's food ideas"), findsOneWidget);
      expect(find.text("THIS WEEK'S FOOD IDEAS"), findsOneWidget);
      final firstMeal = TtcNutritionScreen.weekFrom(DateTime.now())
          .first
          .$2
          .meal(false);
      expect(find.text(firstMeal), findsOneWidget);
      // Change 5 (2026-09-28). Was: find.text('Swap this day')
      await tester.tap(find.text('Swap this food idea').first);
      await tester.pump();
      expect(find.text(firstMeal), findsNothing);
    });
  });
}
