// =============================================================================
//  TTC mind tools rebuild, 2026-09-27 (night): the practice player, the daily
//  ritual, the journal, the course sessions and the care circle.
// -----------------------------------------------------------------------------
//  One test per defect fixed, so each fails loudly if it slides back:
//   · the player's timer stopped at zero with the button still on "Pause",
//     and finishing did nothing; now it stops, marks the practice done and
//     offers Undo;
//   · a floor practice needed a tap per step; now the lit step follows the
//     timer until she moves it herself, and the switch says which;
//   · a breathing practice done with eyes closed had no cue; an optional
//     vibration, off by default, is one tap away;
//   · the ritual wore the V1 purple chrome and the breath part was words
//     only; now it is in the tool shell, the breath has a timer and the
//     prompts can be written into the journal;
//   · the journal's list had no months, an entry's kind could not be changed,
//     nothing said "saved", and a delete could not be undone;
//   · a course session was one long scroll; now it is Read, Do it, Keep it,
//     with Back / Next and the next session at the end;
//   · the care circle was two status cards; now every member has an action.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_care_circle_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart' show TtcCard;
import 'package:parentveda/screens/ttc/ttc_garbh_course_screen.dart';
import 'package:parentveda/screens/ttc/ttc_journal_screen.dart';
import 'package:parentveda/screens/ttc/ttc_practice_player.dart';
import 'package:parentveda/screens/ttc/ttc_practice_screen.dart';
import 'package:parentveda/screens/ttc/ttc_ritual_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_garbh_course.dart';
import 'package:parentveda/ttc/ttc_garbh_course_store.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_mind_today.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {double width = 360, double height = 3000}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump(const Duration(milliseconds: 300));
}

/// A wall clock the test moves by hand, for the player.
DateTime _now = DateTime(2026, 9, 27, 9);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcGarbhCourseStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    _now = DateTime(2026, 9, 27, 9);
    ttcPracticeNow = () => _now;
  });
  tearDown(() => ttcPracticeNow = DateTime.now);

  // ===========================================================================
  group('the practice player', () {
    final breath = ttcPracticeById('mb_longout')!;
    final move = ttcPracticeById('mb_loosen')!;

    testWidgets('the timer stops at the end, marks it done, and offers Undo',
        (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: breath), height: 4000);
      expect(ttcPracticeDoneToday(breath.kind), isFalse);
      expect(find.textContaining('Finishing the timer marks it done'),
          findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pump();
      expect(find.text('Pause'), findsOneWidget);
      _now = _now.add(const Duration(seconds: 20));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('0:40 left'), findsOneWidget,
          reason: 'time left is said in words once started');

      _now = _now.add(const Duration(seconds: 45));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Pause'), findsNothing,
          reason: 'the button used to stay on "Pause" past zero');
      expect(find.text('Start again'), findsOneWidget);
      expect(ttcPracticeDoneToday(breath.kind), isTrue);
      expect(find.text('Marked done on your Mind and body Today tab.'),
          findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(ttcPracticeDoneToday(breath.kind), isFalse);
    });

    testWidgets('the vibration is off by default and turns on with one tap',
        (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: breath), height: 4000);
      // A labelled switch since 2026-09-28 (launch sanity MB14), not a line of
      // text that was secretly a toggle. Kept for revert:
      //   expect(find.text('Vibrate on each breath: off'), findsOneWidget);
      //   await tester.tap(find.text('Vibrate on each breath: off'));
      //   expect(find.text('Vibrate on each breath: on'), findsOneWidget);
      final row = find.ancestor(
          of: find.text('Vibrate on each breath'),
          matching: find.byType(TtcVibrateSwitch));
      expect(row, findsOneWidget);
      final sw = find.descendant(of: row, matching: find.byType(Switch));
      expect(tester.widget<Switch>(sw).value, isFalse);
      await tester.tap(sw);
      await tester.pump();
      expect(tester.widget<Switch>(sw).value, isTrue);
      expect(ttcPracticeVibrate.value, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('ttc_practice_vibrate'), isTrue);
      // Put it back, for the next test's default.
      await tester.tap(sw);
      await tester.pump();
    });

    testWidgets('a movement card has no vibration switch', (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: move), height: 4000);
      expect(find.textContaining('Vibrate on each breath'), findsNothing);
    });

    testWidgets('the lit step follows the timer until she moves it herself',
        (tester) async {
      await _pump(tester, TtcPracticeScreen(practice: move), height: 4000);
      final n = move.steps.length;
      expect(find.text('The steps move along with the timer.'),
          findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pump();
      // Half way through a six-step card is step four.
      _now = _now.add(Duration(seconds: move.anim.seconds ~/ 2));
      await tester.pump(const Duration(milliseconds: 150));
      // One counter since 2026-09-28 (launch sanity MB14): the ring carries
      // it while the steps follow the timer. Kept for revert:
      //   expect(find.text('Step 4 of $n'), findsNWidgets(2),
      //       reason: 'the list counter and the ring both say it');
      expect(find.text('Step 4 of $n'), findsOneWidget,
          reason: 'the ring says it, and nothing repeats it');

      await tester.tap(find.text('Previous step'));
      await tester.pump();
      expect(find.text('Step 3 of $n'), findsOneWidget);
      expect(find.textContaining('You move the steps'), findsOneWidget,
          reason: 'moving a step by hand turns the follow off, visibly');

      _now = _now.add(const Duration(seconds: 30));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Step 3 of $n'), findsOneWidget,
          reason: 'once she has taken over, the clock leaves the list alone');
      await tester.tap(find.text('Pause'));
      await tester.pump();
    });

    testWidgets('every practice still renders at 360dp', (tester) async {
      for (final pr in kTtcPractices) {
        await _pump(tester, TtcPracticeScreen(practice: pr), height: 4000);
        expect(tester.takeException(), isNull, reason: pr.id);
      }
    });
  });

  // ===========================================================================
  group('the daily ritual', () {
    testWidgets('wears the tool shell, not the V1 purple cards',
        (tester) async {
      await _pump(tester,
          const TtcRitualScreen(chapter: TtcChapter.tryingTogether));
      expect(find.byType(TtcToolScaffold), findsOneWidget);
      expect(find.byType(TtcCard), findsNothing);
      // The home's name for it since 2026-09-28 (launch sanity H15). Kept
      // for revert: const TtcS(false).ritualTitle.toUpperCase()
      expect(find.text(const TtcS(false).sanskarTitle.toUpperCase()),
          findsOneWidget,
          reason: "the home band's name is the eyebrow");
      expect(find.text('Tap a part to open it.'), findsOneWidget);
    });

    testWidgets('the breath part carries a one-minute timer that ticks it',
        (tester) async {
      await _pump(
          tester,
          const TtcRitualScreen(
              chapter: TtcChapter.tryingTogether,
              focus: TtcRitualPart.breath));
      expect(find.byType(TtcPracticeSession), findsOneWidget);
      await tester.tap(find.text('Start'));
      await tester.pump();
      // Today's breath practice since 2026-09-28 (MB18), one to two minutes.
      // Kept for revert: const Duration(seconds: 61)
      _now = _now.add(
          Duration(seconds: ttcSanskarBreathPractice().anim.seconds + 1));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 300));
      expect(TtcRitualStore.instance.isDone(TtcRitualPart.breath), isTrue);
      expect(find.text('Breath marked done for today.'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(TtcRitualStore.instance.isDone(TtcRitualPart.breath), isFalse);
    });

    testWidgets('a prompt can be written into the journal, carried in',
        (tester) async {
      await _pump(
          tester,
          const TtcRitualScreen(
              chapter: TtcChapter.tryingTogether,
              focus: TtcRitualPart.gratitude));
      final item = ttcRituals[TtcChapter.tryingTogether]!
          .firstWhere((i) => i.part == TtcRitualPart.gratitude);
      await tester.tap(find.text('Write about it in our journal'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcJournalWriteScreen), findsOneWidget);
      expect(find.text(item.text(false)), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'The tea this morning');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final e = TtcJournalStore.instance.entries.single;
      expect(e.prompt, item.text(false));
      expect(e.kind, TtcEntryKind.feeling);
    });

    testWidgets('the action part has no journal link', (tester) async {
      await _pump(
          tester,
          const TtcRitualScreen(
              chapter: TtcChapter.tryingTogether,
              focus: TtcRitualPart.action));
      expect(find.text('Write about it in our journal'), findsNothing);
    });
  });

  // ===========================================================================
  group('the journal', () {
    testWidgets('first open is an invitation, and a save says so',
        (tester) async {
      await _pump(tester, const TtcJournalScreen());
      expect(find.text(const TtcS(false).journalEmptyTitle), findsOneWidget);
      await tester.tap(find.text('Write something'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Day one');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pump();
      // findsWidgets: during the pop both routes' scaffolds hold the notice.
      expect(find.text('Saved to Our journal.'), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('Day one'), findsOneWidget);
    });

    testWidgets('entries are headed by month', (tester) async {
      TtcJournalStore.instance.add(
          kind: TtcEntryKind.memory, text: 'In August', on: DateTime(2026, 8, 3));
      TtcJournalStore.instance.add(
          kind: TtcEntryKind.memory, text: 'In Sept A', on: DateTime(2026, 9, 3));
      TtcJournalStore.instance.add(
          kind: TtcEntryKind.memory, text: 'In Sept B', on: DateTime(2026, 9, 9));
      await _pump(tester, const TtcJournalScreen());
      expect(find.byType(TtcJournalMonthHead), findsNWidgets(2));
      expect(find.text('September 2026'), findsOneWidget);
      expect(find.text('August 2026'), findsOneWidget);
    });

    testWidgets('an edit can move an entry to another kind', (tester) async {
      TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'Ask AMH');
      await _pump(tester, const TtcJournalScreen());
      await tester.tap(find.text('Ask AMH'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TtcEntryKind.question.label(false)));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Changes saved.'), findsWidgets);
      await tester.pumpAndSettle();
      final e = TtcJournalStore.instance.entries.single;
      expect(e.kind, TtcEntryKind.question);
      expect(e.text, 'Ask AMH');
    });

    testWidgets('a delete asks first, and can be undone', (tester) async {
      final e = TtcJournalStore.instance
          .add(kind: TtcEntryKind.letter, text: 'Dear little one');
      await _pump(tester, const TtcJournalScreen());
      await tester.tap(find.text('Dear little one'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete entry'));
      await tester.pumpAndSettle();
      expect(find.textContaining('You can undo it'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(TtcJournalStore.instance.count, 0);
      expect(find.text('Entry deleted.'), findsWidgets);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      final back = TtcJournalStore.instance.entries.single;
      expect(back.id, e.id, reason: 'same id, so the cloud sees one row');
      expect(back.dateIso, e.dateIso);
    });

    test('the store: restore is idempotent, a kind-only edit counts', () {
      final e =
          TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'x');
      TtcJournalStore.instance.restore(e);
      expect(TtcJournalStore.instance.count, 1);
      expect(
          TtcJournalStore.instance
              .update(e.id, text: 'x', kind: TtcEntryKind.feeling),
          isTrue);
      expect(TtcJournalStore.instance.entries.single.kind,
          TtcEntryKind.feeling);
      expect(TtcJournalStore.instance.update(e.id, text: 'x'), isFalse,
          reason: 'nothing changed');
    });
  });

  // ===========================================================================
  group('a course session, in parts', () {
    test('every session has Read, and only the parts it needs', () {
      for (final s in kTtcCourseSessions) {
        final parts = ttcCourseParts(s);
        expect(parts.first, TtcCoursePart.read);
        expect(parts.contains(TtcCoursePart.keep),
            s.action != TtcCourseAction.none,
            reason: 'session ${s.number}');
      }
      expect(ttcCourseParts(ttcCourseSessionById('gs_food')!),
          [TtcCoursePart.read, TtcCoursePart.keep],
          reason: 'the food session has nothing to play');
    });

    testWidgets('Read first; Next walks the parts; the end offers session 2',
        (tester) async {
      final s1 = kTtcCourseSessions.first;
      await _pump(tester, TtcCourseSessionScreen(session: s1), height: 4000);
      expect(find.text(s1.saidPlainly), findsOneWidget);
      expect(find.byType(TtcPracticeSession), findsNothing,
          reason: 'the timer waits on its own part now');

      await tester.tap(find.text('Next: Do it'));
      await tester.pump();
      expect(find.byType(TtcPracticeSession), findsOneWidget);
      expect(find.text(s1.saidPlainly), findsNothing);

      final s2 = kTtcCourseSessions[1];
      await tester.tap(find.text('Next session: ${s2.title}'));
      await tester.pumpAndSettle();
      expect(find.text(s2.saidPlainly), findsOneWidget);
      expect(TtcGarbhCourseStore.instance.isOpened(s2.id), isTrue);
    });

    testWidgets('session 8 keeps its save on the Keep it part',
        (tester) async {
      final s8 = kTtcCourseSessions.last;
      await _pump(tester, TtcCourseSessionScreen(session: s8), height: 4000);
      expect(find.text('Set as my daily practice'), findsNothing);
      await tester.tap(find.text('2  Keep it'));
      await tester.pump();
      expect(find.text('Set as my daily practice'), findsOneWidget);
      expect(find.text('Back to the course'), findsOneWidget);
    });

    testWidgets('every part of every session renders at 360dp',
        (tester) async {
      for (final s in kTtcCourseSessions) {
        await _pump(tester, TtcCourseSessionScreen(session: s), height: 4000);
        final parts = ttcCourseParts(s);
        for (var i = 0; i < parts.length; i++) {
          final part = parts[i];
          await tester.tap(find.text('${i + 1}  ${part.label}'));
          await tester.pump();
          expect(tester.takeException(), isNull,
              reason: 'session ${s.number}, ${part.label}');
        }
      }
    });
  });

  // ===========================================================================
  group('the care circle', () {
    testWidgets('renders at 360dp, joined or not', (tester) async {
      await _pump(tester, const TtcCareCircleScreen());
      expect(tester.takeException(), isNull);
      TtcStore.instance.setPartnerJoined(true);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Joined. You share the journal.'), findsOneWidget);
    });

    testWidgets('every member says what a tap does, and it goes somewhere',
        (tester) async {
      // 400 wide: the Appointments page this opens overflows by 12 at 360
      // under the test font (reported, not this file's to fix).
      await _pump(tester, const TtcCareCircleScreen(), width: 400);
      expect(find.byType(TtcToolScaffold), findsOneWidget);
      expect(find.byType(TtcCircleMember), findsNWidgets(4));
      expect(find.text('Invite your partner'), findsOneWidget);
      expect(find.text('Open Appointments'), findsOneWidget);
      expect(find.text('Talk to an expert'), findsOneWidget);

      await tester.tap(find.text('Open Appointments'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcCareCircleScreen), findsNothing,
          reason: 'the doctor row opens the Appointments page');
    });
  });
}
