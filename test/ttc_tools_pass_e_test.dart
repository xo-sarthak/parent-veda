// =============================================================================
//  TTC tools pass, area E (2026-09-27): the fertile window, chapters, the
//  journey map and timeline, infographics, messages, guided chats, the
//  shared-phone offer and the tools hub.
// -----------------------------------------------------------------------------
//  Each group pins one behaviour the pass changed, from the user's
//  "simplicity is the main goal" addendum and docs/TTC-TOOLS-UX-NOTES.md:
//  say what this is first, name every mark where it is drawn, never a dead
//  end, and nothing changes without saying so.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/chats/ttc_chat.dart';
import 'package:parentveda/screens/ttc/chats/ttc_period_came_chat.dart';
import 'package:parentveda/screens/ttc/ttc_chapter_screen.dart';
import 'package:parentveda/screens/ttc/ttc_infographic_screen.dart';
import 'package:parentveda/screens/ttc/ttc_intimate_offer.dart';
import 'package:parentveda/screens/ttc/ttc_journey_map_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_timeline_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/screens/ttc/ttc_window_screen.dart';
import 'package:parentveda/services/family_timeline.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/notification_service.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_content_prefs.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/ttc/ttc_prepare_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(1200, 8000)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcContentPrefs.instance.resetForTest();
    FamilyTimeline.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  void logClean() {
    final now = DateTime.now();
    CycleStore.instance
      ..logPeriodStart(now.subtract(const Duration(days: 68)))
      ..logPeriodStart(now.subtract(const Duration(days: 40)))
      ..logPeriodStart(now.subtract(const Duration(days: 12)));
  }

  // ===========================================================================
  group('the fertile window says what it is before anything is read', () {
    testWidgets('one name, the plain line, the best days and why', (tester) async {
      logClean();
      await _pump(tester, const TtcWindowScreen());
      // The title is the tool's one name; the back bar no longer repeats it.
      // (The glossary has a "Fertile window" word pill too; the title is the
      // 27pt one.)
      expect(
          find.byWidgetPredicate((w) =>
              w is Text && w.data == 'Fertile window' && w.style?.fontSize == 27),
          findsOneWidget);
      expect(find.textContaining('The six days each cycle'), findsOneWidget);
      expect(find.textContaining('Your best days are'), findsOneWidget);
      expect(find.textContaining('Why six days'), findsOneWidget);
      // The old header that read like a percentage is gone.
      expect(find.text('CHANCE ON THAT DAY'), findsNothing);
      expect(find.textContaining("They aren't percentages"), findsOneWidget);
    });

    testWidgets('ovulation is a marker beside Peak, not a level of its own',
        (tester) async {
      logClean();
      await _pump(tester, const TtcWindowScreen());
      // Two Peak days in the list, one of them marked Ovulation.
      expect(find.text('Peak'), findsNWidgets(2));
      // The marker word in the list (the glossary pill is the other one).
      expect(
          find.byWidgetPredicate((w) =>
              w is Text && w.data == 'Ovulation' && w.style?.fontSize == 10.5),
          findsOneWidget);
    });

    testWidgets('the view switch is words, and the curve is one tap away',
        (tester) async {
      logClean();
      await _pump(tester, const TtcWindowScreen());
      expect(find.text('Six days'), findsOneWidget);
      await tester.tap(find.text('Whole cycle'));
      await tester.pumpAndSettle();
      expect(find.textContaining('The shaded band is your six fertile days'),
          findsOneWidget);
      // The walkthrough is retired: the picture is labelled instead.
      expect(find.text('How to read this'), findsNothing);
    });

    testWidgets('paging says where it goes, and back appears only when useful',
        (tester) async {
      logClean();
      await _pump(tester, const TtcWindowScreen());
      expect(find.text('Back to this cycle'), findsNothing);
      await tester.tap(find.text('Next cycle'));
      await tester.pumpAndSettle();
      expect(find.text('Back to this cycle'), findsOneWidget);
      expect(find.textContaining('A guess from your usual cycle length'),
          findsOneWidget);
      await tester.tap(find.text('Back to this cycle'));
      await tester.pumpAndSettle();
      expect(find.text('Back to this cycle'), findsNothing);
    });

    testWidgets('nothing logged: says what unlocks it, with the button',
        (tester) async {
      await _pump(tester, const TtcWindowScreen());
      expect(find.text('Add your last period to see your window'),
          findsOneWidget);
      expect(find.text(const TtcS(false).logPeriodCta), findsOneWidget);
    });

    testWidgets('a late cycle: says why, and the way back is on the card',
        (tester) async {
      final now = DateTime.now();
      CycleStore.instance
        ..logPeriodStart(now.subtract(const Duration(days: 100)))
        ..logPeriodStart(now.subtract(const Duration(days: 72)))
        ..logPeriodStart(now.subtract(const Duration(days: 44)));
      expect(TtcStore.instance.today.noEstimate, TtcNoEstimate.cycleOverdue);
      await _pump(tester, const TtcWindowScreen());
      expect(find.text(const TtcS(false).noEstOverdueTitle), findsOneWidget);
      expect(find.text('My period started'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the chapter page', () {
    testWidgets('says which part of the month it is, under the name',
        (tester) async {
      await _pump(tester,
          const TtcChapterScreen(chapter: TtcChapter.tryingTogether));
      expect(find.text(ttcChapterPlainPart(TtcChapter.tryingTogether)),
          findsOneWidget);
    });

    testWidgets('the doctor card is on the Me face too', (tester) async {
      await _pump(tester,
          const TtcChapterScreen(chapter: TtcChapter.preparingTogether));
      expect(find.text(const TtcS(false).chapterMedical), findsOneWidget);
    });

    testWidgets('every Us card says who it is for', (tester) async {
      await _pump(
          tester,
          const TtcChapterScreen(
              chapter: TtcChapter.preparingTogether,
              initialTab: TtcChapterTab.us));
      expect(find.text(kTtcForHim.toUpperCase()), findsOneWidget);
      expect(find.text(kTtcForYouBoth.toUpperCase()), findsOneWidget);
    });

    testWidgets('a chapter she is not in leads back to the one she is in',
        (tester) async {
      final current = TtcStore.instance.today.chapter;
      final other = TtcChapter.values.firstWhere((c) => c != current);
      await _pump(tester, TtcChapterScreen(chapter: other));
      expect(find.text(const TtcS(false).chapterYouAreHere), findsNothing);
      final link = find.byKey(const ValueKey('ttc_chapter_back_to_current'));
      expect(link, findsOneWidget);
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.text(const TtcS(false).chapterYouAreHere), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the journey map', () {
    testWidgets('draws the three repeating chapters as one loop',
        (tester) async {
      await _pump(tester, const TtcJourneyMapScreen());
      expect(find.byKey(const ValueKey('ttc_map_cycle_loop')), findsOneWidget);
      expect(find.text('These three repeat every cycle'), findsOneWidget);
      // How each chapter moves on is on every card, not only the current one.
      expect(find.textContaining('Next:'),
          findsNWidgets(TtcChapter.values.length));
    });

    testWidgets('no big zero before the first milestone', (tester) async {
      await _pump(tester, const TtcJourneyMapScreen());
      expect(find.text('0'), findsNothing);
    });
  });

  // ===========================================================================
  group('the family timeline', () {
    testWidgets('empty: names both ways to make the first entry',
        (tester) async {
      await _pump(tester, const TtcTimelineScreen());
      expect(find.text('Write in the journal'), findsOneWidget);
      expect(find.text('Log a period'), findsOneWidget);
    });

    testWidgets('one stage: the stage tag is not repeated on every row',
        (tester) async {
      final tl = FamilyTimeline.instance;
      tl.add(
          id: 'e_a',
          stage: LifeStage.tryingToConceive,
          kind: TimelineKind.milestone,
          titleEn: 'We decided',
          titleHi: 'We decided',
          on: DateTime(2026, 1, 1));
      await _pump(tester, const TtcTimelineScreen());
      expect(find.text('We decided'), findsOneWidget);
      expect(
          find.text(LifeStage.tryingToConceive.label(false).toUpperCase()),
          findsNothing);
    });
  });

  // ===========================================================================
  group('the infographic', () {
    const tile = TtcInfographicTile(
      title: 'PCOS or thyroid',
      blurb: 'b',
      headline: 'h',
      left: TtcInfographicColumn(label: 'L', points: ['one']),
      right: TtcInfographicColumn(label: 'R', points: ['two']),
    );

    testWidgets('the eyebrow is the topic, not the format', (tester) async {
      await _pump(tester, const TtcInfographicScreen(tile: tile, hue: 288));
      expect(find.text('INFOGRAPHIC'), findsNothing);
      expect(find.text('PCOS'), findsOneWidget);
    });

    testWidgets('stacked on a phone, side by side when wide', (tester) async {
      await _pump(tester, const TtcInfographicScreen(tile: tile, hue: 288),
          size: const Size(390, 5000));
      expect(find.byKey(const ValueKey('ttc_infographic_stacked')),
          findsOneWidget);
      await _pump(tester, const TtcInfographicScreen(tile: tile, hue: 288));
      expect(find.byKey(const ValueKey('ttc_infographic_side_by_side')),
          findsOneWidget);
    });
  });

  // ===========================================================================
  group('a finished chat can start again', () {
    testWidgets('Start again sits above Done and replays from the top',
        (tester) async {
      final script = TtcPeriodCameChat(
        today: DateTime(2026, 9, 10),
        lastStart: DateTime(2026, 9, 10),
        ownership: TimingOwnership.parentveda,
        logPeriod: (_) {},
      );
      await _pump(
          tester, TtcChatScreen(script: script, pause: Duration.zero));
      expect(find.text(kTtcChatStartAgain), findsNothing);
      await tester.tap(find.text("I'd rather not talk now"));
      await tester.pumpAndSettle();
      expect(find.text(kTtcChatStartAgain), findsOneWidget);
      await tester.tap(find.text(kTtcChatStartAgain));
      await tester.pumpAndSettle();
      expect(find.text("I'd rather not talk now"), findsOneWidget);
      expect(find.text('Your period came.'), findsOneWidget);
      expect(find.text(kTtcChatStartAgain), findsNothing);
    });

    test('a period the chat logged is not offered again after a restart', () {
      final logged = <DateTime>[];
      final chat = TtcPeriodCameChat(
        today: DateTime(2026, 9, 10),
        lastStart: DateTime(2026, 8, 1),
        ownership: TimingOwnership.parentveda,
        logPeriod: logged.add,
      );
      expect(chat.alreadyLogged, isFalse);
      chat.logged(DateTime(2026, 9, 10));
      chat.resetAnswers();
      expect(chat.alreadyLogged, isTrue);
      expect(logged, hasLength(1));
    });
  });

  // ===========================================================================
  group('a phone notification tap opens its message', () {
    late void Function(TtcMessage?) saved;
    setUp(() {
      saved = TtcMessagesStore.phoneTapOpener;
      TtcMessagesStore.instance.resetForTest();
    });
    tearDown(() => TtcMessagesStore.phoneTapOpener = saved);

    test('our id is claimed, marked read and opened', () {
      final now = DateTime.now();
      final store = TtcMessagesStore.instance;
      store.apply([
        TtcMessage(
            id: 'window:e',
            kind: TtcMessageKind.windowOpens,
            at: now.subtract(const Duration(hours: 1)),
            title: 't',
            body: 'b'),
      ], now);
      TtcMessage? opened;
      TtcMessagesStore.phoneTapOpener = (m) => opened = m;
      expect(
          store.handlePhoneTap(TtcMessageKind.windowOpens.notificationId),
          isTrue);
      expect(opened?.id, 'window:e');
      expect(store.delivered().single.read, isTrue);
    });

    test("another feature's id is left alone", () {
      var called = false;
      TtcMessagesStore.phoneTapOpener = (_) => called = true;
      expect(TtcMessagesStore.instance.handlePhoneTap(999001), isFalse);
      expect(called, isFalse);
    });

    test('the service offers a tap to listeners, and holds an unclaimed one',
        () {
      final service = NotificationService.instance;
      bool mine(int id) => id == 424242;
      final seen = <int>[];
      bool late(int id) {
        seen.add(id);
        return true;
      }

      service.addTapListener(mine);
      service.debugTap(424243); // nobody claims it
      service.addTapListener(late); // offered the held tap
      expect(seen, [424243]);
      service.removeTapListener(mine);
      service.removeTapListener(late);
    });
  });

  // ===========================================================================
  group('the shared-phone offer', () {
    testWidgets('offered once, says what it does, and can be undone',
        (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => ttcMaybeOfferIntimateSwitch(context),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(kTtcIntimateOfferTitle), findsOneWidget);
      expect(find.textContaining('timing always stay'), findsOneWidget);
      await tester.tap(find.text(kTtcIntimateOfferHide));
      await tester.pumpAndSettle();
      expect(TtcContentPrefs.instance.hideIntimate, isTrue);
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcContentPrefs.instance.hideIntimate, isFalse);

      // Never a second time.
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(kTtcIntimateOfferTitle), findsNothing);
    });
  });

  // ===========================================================================
  group('the tools hub', () {
    test('the product guide says it is products', () {
      expect(ttcToolById('guide')!.nameEn, 'Products');
    });

    test('supplements and medication say how they differ', () {
      expect(ttcToolById('supplements')!.descEn, contains('choose'));
      expect(ttcToolById('medication')!.descEn, contains('prescribed'));
    });

    test('every offering has a plain line saying what she gets', () {
      for (final o in ttcOfferings) {
        expect(ttcOfferingPlainLine(o.id), isNotNull, reason: o.id);
      }
    });
  });
}
