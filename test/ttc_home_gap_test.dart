// =============================================================================
//  The TTC home's gap-analysis work - 2026-09-26
// -----------------------------------------------------------------------------
//  The gap analysis ("Behind: Home & daily", "Behind: Guided help", "Behind:
//  Settings", "Learning shapes") asked the home to speak to where she is. This
//  file holds each piece, and the rules under them:
//
//    1. Late on her own cycle: "Time to test", with "How to take a test".
//       Never on a clinic cycle, never on a guess of a history.
//    2. The first day of a new period: one kind line.
//    3. The daily card and the four reads follow her phase.
//    4. The envelope, with an unread dot, opens Messages.
//    5. One-tap Sex writes the logger's own field, and undoes.
//    6. The doors change order for her situation, and none disappears.
//    7. The 12-month (or 6-month) check card, and "Not now".
//    8. The calendar's two lines, natural cycles only.
//    9. "Hide sex and intimacy content" hides what it says, in Learn too.
//   10. "Trying to conceive 101", in its order, and the home card for it.
//   11. The chat entry points are wired (the wiring gate).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/profile/pv_you_content.dart';
import 'package:parentveda/screens/ttc/chats/ttc_should_test_chat.dart';
import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_content_prefs_sheet.dart';
import 'package:parentveda/screens/ttc/ttc_home_gap.dart';
import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart';
import 'package:parentveda/screens/ttc/ttc_messages_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_symptom_log_screen.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_content_prefs.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_home_prefs.dart';
import 'package:parentveda/ttc/ttc_home_situation.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/ttc/ttc_phase_reads.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime ago(int days) =>
      DateTime(today.year, today.month, today.day - days);

  setUpAll(() async {
    CycleStore.instance;
    TtcStore.instance;
    LifeStageStore.instance;
    TtcLogStore.instance;
    TtcTreatmentStore.instance;
    await TtcFertilityHelpStore.instance.load();
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  });

  setUp(() async {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    LifeStageStore.instance
      ..resetForTest()
      ..setStage(LifeStage.tryingToConceive);
    await TtcFertilityHelpStore.instance.reset();
    TtcMessagesStore.instance.resetForTest();
    TtcHomePrefs.instance.resetForTest();
    TtcContentPrefs.instance.resetForTest();
  });

  /// Two clean 28-day cycles, and today one day past the usual length.
  void lateByOne() {
    CycleStore.instance
      ..logPeriodStart(ago(85))
      ..logPeriodStart(ago(57))
      ..logPeriodStart(ago(29));
  }

  /// Two clean 28-day cycles, and today cycle day 13 (the fertile window).
  void inWindow() {
    CycleStore.instance
      ..logPeriodStart(ago(68))
      ..logPeriodStart(ago(40))
      ..logPeriodStart(ago(12));
  }

  /// The chats type their lines in on timers; let them finish, then leave.
  Future<void> drain(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  }

  Future<void> pumpHome(WidgetTester tester, {double height = 3200}) async {
    // 360pt wide, the narrow phone the other home tests use.
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: TtcHomeV3()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  }

  // ===========================================================================
  group('1. late: Time to test', () {
    test('a day past the usual length, on a steady natural history', () {
      lateByOne();
      final a = ttcHomeLateAdvice();
      expect(a, isNotNull);
      expect(a!.daysLate, 1);
      expect(ttcTimeToTestBody(a.daysLate),
          'Your period is 1 day later than usual. A home test is reliable '
          'from today.');
    });

    test('the same due date the late message names', () {
      lateByOne();
      final facts = TtcMessageFacts.fromStores();
      final advice = ttcReliableLateAdvice(facts, now)!;
      final msg = ttcMessageCandidates(facts, now)
          .where((m) => m.kind == TtcMessageKind.lateByOne)
          .firstOrNull;
      expect(msg, isNotNull, reason: 'the late message went quiet');
      expect(advice.due, ago(1));
    });

    test('never on a clinic cycle', () {
      lateByOne();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      expect(ttcHomeLateAdvice(), isNull);
    });

    test('never on a history too short to call anything late', () {
      CycleStore.instance
        ..logPeriodStart(ago(57))
        ..logPeriodStart(ago(29));
      expect(ttcHomeLateAdvice(), isNull,
          reason: 'one completed cycle is not a usual length');
    });

    test('not on the due day itself', () {
      CycleStore.instance
        ..logPeriodStart(ago(84))
        ..logPeriodStart(ago(56))
        ..logPeriodStart(ago(28));
      expect(ttcHomeLateAdvice(), isNull);
    });

    testWidgets('the hero says it, with the button to the chat',
        (tester) async {
      lateByOne();
      await pumpHome(tester);
      expect(find.text(kTtcTimeToTest), findsOneWidget);
      expect(find.text(ttcTimeToTestBody(1)), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_home_how_to_test')),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_home_how_to_test')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(TtcShouldTestChatScreen), findsOneWidget);
      await drain(tester);
    });

    testWidgets('a clinic cycle keeps its own words', (tester) async {
      lateByOne();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      await pumpHome(tester);
      expect(find.text(kTtcTimeToTest), findsNothing);
      expect(find.byKey(const ValueKey('ttc_home_how_to_test')), findsNothing);
    });

    test('the words promise nothing and count down to nothing', () {
      final copy = [
        kTtcTimeToTest,
        for (var d = 1; d <= 14; d++) ttcTimeToTestBody(d),
      ].join(' ').toLowerCase();
      expect(RegExp(r'chance|odds|likelihood|probabilit').hasMatch(copy),
          isFalse);
      expect(RegExp(r'\btest in \d').hasMatch(copy), isFalse);
      expect(copy.contains('!'), isFalse);
      expect(copy.contains('—'), isFalse);
    });
  });

  // ===========================================================================
  group('2. period day 1', () {
    test('the first day of a new period, not the first ever logged', () {
      CycleStore.instance
        ..logPeriodStart(ago(56))
        ..logPeriodStart(ago(28))
        ..logPeriodStart(today);
      expect(ttcIsNewPeriodDayOne(today), isTrue);
      expect(ttcIsNewPeriodDayOne(ago(1)), isFalse);

      CycleStore.instance
        ..resetForTest()
        ..logPeriodStart(today);
      expect(ttcIsNewPeriodDayOne(today), isFalse,
          reason: 'the first period she logs is usually set-up, not news');
    });

    testWidgets('the kind line shows, and opens the read', (tester) async {
      CycleStore.instance
        ..logPeriodStart(ago(56))
        ..logPeriodStart(ago(28))
        ..logPeriodStart(today);
      await pumpHome(tester);
      // 2026-09-30: one slim pill with the link only; the kind sentence
      // moved into the read. Kept for revert:
      // expect(find.text(kTtcPeriodCameLine), findsOneWidget);
      expect(find.text(kTtcPeriodCameLink), findsOneWidget);
      expect(ttcFirstSurface(['ttc_read/$kTtcPeriodCameReadId']), isNotNull,
          reason: 'the read the line promises does not resolve');
    });
  });

  // ===========================================================================
  group('3. cards and reads by phase', () {
    test('the phase follows the cycle', () {
      inWindow();
      expect(ttcHomePhaseOn(today), TtcDayPhase.window);
      expect(ttcHomePhaseOn(ago(12)), TtcDayPhase.period);
      // ⚠️ AN EARLIER CYCLE IS NOT PHASED FROM THIS ONE'S ESTIMATE (2026-09-26,
      // consistency pass). This asserted `waiting`, worked out with THIS
      // cycle's ovulation day, on a day whose hero says "In an earlier cycle
      // ... we only work out fertile days for the cycle you're in". The cards
      // now follow the hero: only a logged period day keeps a phase there.
      //
      // ⚠️ AND PHASED FROM ITS OWN LENGTH SINCE LATER THE SAME DAY (the
      // user's decision: earlier cycles show their fertile days, looking
      // back). Its last day is after its own look-back window, so the waiting
      // days again, now for the right reason: the hero on that date names the
      // same window. Kept for revert: `TtcDayPhase.any`.
      expect(ttcHomePhaseOn(ago(13)), TtcDayPhase.waiting,
          reason: 'the last day of the previous cycle');
    });

    test('late only with a history that can carry it', () {
      lateByOne();
      expect(ttcHomePhaseOn(today), TtcDayPhase.late);
    });

    test('a clinic cycle is not phased by us', () {
      inWindow();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      expect(ttcHomePhaseOn(today), TtcDayPhase.any);
    });

    test('the daily card is one written for the phase', () {
      for (final phase in [
        TtcDayPhase.period,
        TtcDayPhase.window,
        TtcDayPhase.waiting,
        TtcDayPhase.late,
      ]) {
        for (var i = 0; i < 10; i++) {
          final card = ttcHomeInsightFor(ago(i), phase: phase);
          expect(card.phases, contains(phase),
              reason: '${phase.name}: "${card.titleEn}" is not a '
                  '${phase.name} card');
        }
      }
    });

    test('the four reads come from the phase set first', () {
      for (final phase in [TtcDayPhase.period, TtcDayPhase.waiting]) {
        final own = kTtcPhaseReadIds[phase]!;
        for (var i = 0; i < 10; i++) {
          final ids = ttcHomeReadIdsFor(ago(i), phase: phase);
          expect(ids, hasLength(4));
          expect(own.contains(ids.first), isTrue,
              reason: '${phase.name}: ${ids.first} leads');
          for (final id in ids) {
            expect(ttcReadById(id), isNotNull);
          }
        }
      }
    });

    // ⚠️ "SEE EVERYTHING" LEFT THE HOME (the user, 2026-09-27: "see
    // everything is not needed… recommended reads should only talk about
    // recommended reads"). Every read is on the Learn tab in the bar. Kept for
    // revert: the test tapped `ttc_home_reads_see_all` and expected
    // TtcLearnScreen.
    testWidgets('the phase reads are on the home, as rows, with no extra row',
        (tester) async {
      inWindow();
      await pumpHome(tester);
      final ids = ttcHomeReadIdsFor(today, phase: TtcDayPhase.window);
      expect(find.text(ttcReadById(ids.first)!.title.en), findsWidgets);
      expect(find.byKey(ValueKey('ttc_home_read_${ids.first}')), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_home_reads_see_all')), findsNothing);
    });

    testWidgets('the waiting days offer "Should I test?"', (tester) async {
      CycleStore.instance
        ..logPeriodStart(ago(76))
        ..logPeriodStart(ago(48))
        ..logPeriodStart(ago(20));
      expect(ttcHomePhaseOn(today), TtcDayPhase.waiting);
      await pumpHome(tester);
      expect(find.text(kTtcShouldTestValue), findsOneWidget);
    });
  });

  // ===========================================================================
  group('4. the envelope', () {
    testWidgets('no dot when nothing is unread', (tester) async {
      inWindow();
      await pumpHome(tester);
      expect(find.byKey(const ValueKey('ttc_home_messages')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('ttc_home_messages_dot')), findsNothing);
    });

    testWidgets('a dot when something is, and it opens Messages',
        (tester) async {
      inWindow();
      // `apply` is the store's pure fold; a delivered, unread message.
      TtcMessagesStore.instance.apply([
        TtcMessage(
          id: 'test:2',
          kind: TtcMessageKind.periodCame,
          at: DateTime.now().subtract(const Duration(hours: 1)),
          title: 'Your period came',
          body: 'A test message.',
        ),
      ], DateTime.now());
      expect(TtcMessagesStore.instance.unreadCount, 1);
      await pumpHome(tester);
      expect(
          find.byKey(const ValueKey('ttc_home_messages_dot')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ttc_home_messages')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcMessagesScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  group('5. one-tap sex', () {
    Set<String> loggedToday() => TtcLogStore.instance
        .valuesOn(kTtcSymptomTracker, TtcLogStore.dayKey(today))
        .where((v) => v.value > 0)
        .map((v) => v.field)
        .toSet();

    test('one tap logs the logger\'s own field, the next takes it off', () {
      TtcLogStore.instance.log(kTtcSymptomTracker, 'sex_none', 1, on: today);
      expect(ttcToggleSexOn(today), isTrue);
      expect(loggedToday(), contains('sex_unprotected'));
      expect(loggedToday(), isNot(contains('sex_none')),
          reason: '"None" and "had sex" on one day');
      expect(ttcSexLoggedOn(today), isTrue);

      expect(ttcToggleSexOn(today), isFalse);
      expect(loggedToday(), isNot(contains('sex_unprotected')));
      expect(ttcSexLoggedOn(today), isFalse);
    });

    test('the id is a chip the logger already has, not a new key', () {
      expect(ttcSymptomById(kTtcSexLoggedId), isNotNull);
      final sex = kTtcSymptomGroups.firstWhere((g) => g.id == 'sex');
      expect(sex.symptoms.map((s) => s.id), contains(kTtcSexLoggedId));
    });

    testWidgets('the home button toggles it, and Test opens the logger',
        (tester) async {
      inWindow();
      await pumpHome(tester);
      final sexButton = find.byKey(const ValueKey('ttc_home_quick_sex'));
      expect(sexButton, findsOneWidget);
      await tester.tap(sexButton);
      await tester.pump();
      expect(loggedToday(), contains('sex_unprotected'));
      await tester.tap(sexButton);
      await tester.pump();
      expect(loggedToday(), isNot(contains('sex_unprotected')));

      await tester.tap(find.byKey(const ValueKey('ttc_home_quick_test')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcSymptomLogScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  group('6. doors by situation', () {
    final ids = [
      for (final b in bracketsFor(LifeStage.tryingToConceive)) b.id,
    ];

    void sameDoors(List<String> out) {
      expect(out.length, ids.length, reason: 'a door was added or lost');
      expect(out.toSet(), ids.toSet(), reason: 'a door disappeared');
    }

    test('otherwise the existing order', () {
      final out = ttcHomeDoorOrder(ids,
          clinicPathway: false, tryingLong: false, phase: TtcDayPhase.window);
      expect(out, ids);
    });

    test('waiting or late: the fertile window first', () {
      for (final phase in [TtcDayPhase.waiting, TtcDayPhase.late]) {
        final out = ttcHomeDoorOrder(ids,
            clinicPathway: false, tryingLong: false, phase: phase);
        expect(out.first, kTtcDoorFertileWindow);
        sameDoors(out);
      }
    });

    test('trying a long while: "Taking a while" first', () {
      expect(ids, contains(kTtcDoorNotYet),
          reason: 'the new door is registered');
      final out = ttcHomeDoorOrder(ids,
          clinicPathway: false, tryingLong: true, phase: TtcDayPhase.window);
      expect(out.first, kTtcDoorNotYet);
      sameDoors(out);
    });

    test('a clinic pathway: IVF & IUI first', () {
      final out = ttcHomeDoorOrder(ids,
          clinicPathway: true, tryingLong: true, phase: TtcDayPhase.waiting);
      expect(out.take(3).toList(),
          [kTtcDoorIvf, kTtcDoorNotYet, kTtcDoorFertileWindow]);
      sameDoors(out);
    });

    test('a leader that is not registered is skipped, never invented', () {
      final without = [for (final id in ids) if (id != kTtcDoorNotYet) id];
      final out = ttcHomeDoorOrder(without,
          clinicPathway: false, tryingLong: true, phase: TtcDayPhase.window);
      expect(out, without);
    });

    testWidgets('every door is still on the home', (tester) async {
      lateByOne();
      await pumpHome(tester);
      for (final b in bracketsFor(LifeStage.tryingToConceive)) {
        expect(find.text(b.label.en), findsWidgets,
            reason: '${b.id} is missing from the home');
      }
    });
  });

  // ===========================================================================
  group('7. it may be time for a check', () {
    test('12 months, or 6 at 35 and over, by the message\'s own rule', () {
      final twelve = TtcMessageFacts(journeyStart: ago(370));
      expect(ttcHomeCheckMonths(facts: twelve, now: now), 12);
      final early = TtcMessageFacts(journeyStart: ago(200));
      expect(ttcHomeCheckMonths(facts: early, now: now), isNull);
      final older = TtcMessageFacts(
          journeyStart: ago(200),
          ageBand: FertilityAgeBand.thirtyFiveTo37);
      expect(ttcHomeCheckMonths(facts: older, now: now), 6);
      final irregular =
          TtcMessageFacts(journeyStart: ago(200), cyclesVaryOrPcos: true);
      expect(ttcHomeCheckMonths(facts: irregular, now: now), 6);
    });

    test('not on a clinic path, and not once she is in care', () {
      expect(
          ttcHomeCheckMonths(
              facts: TtcMessageFacts(
                  journeyStart: ago(400),
                  ownership: TimingOwnership.clinicControlled),
              now: now),
          isNull);
      expect(
          ttcHomeCheckMonths(
              facts: TtcMessageFacts(
                  journeyStart: ago(400), alreadyInCare: true),
              now: now),
          isNull);
    });

    test('the words, and never a chance or a diagnosis', () {
      // Kept for revert (2026-09-28): "It's been about a year".
      expect(ttcCheckTitle(12), 'About a year of trying');
      expect(
          ttcCheckBody(12),
          "That's the point where guidelines suggest a simple check for both "
          'of you. Most causes are findable, and many are easy to treat.');
      final copy = [
        ttcCheckTitle(6),
        ttcCheckBody(6),
        ttcCheckTitle(12),
        ttcCheckBody(12),
      ].join(' ').toLowerCase();
      expect(RegExp(r'chance|odds|diagnos|infertil').hasMatch(copy), isFalse);
      expect(copy.contains('!'), isFalse);
    });

    testWidgets('the card shows, and "Not now" is remembered',
        (tester) async {
      inWindow();
      TtcStore.instance.setJourneyStart(ago(400));
      await pumpHome(tester);
      final card = find.byKey(const ValueKey('ttc_home_check_card'));
      expect(card, findsOneWidget);
      // Kept for revert (2026-09-28): "It's been about a year".
      expect(find.text('About a year of trying'), findsOneWidget);
      final notNow = find.byKey(const ValueKey('ttc_home_check_not_now'));
      await tester.ensureVisible(notNow);
      await tester.tap(notNow);
      await tester.pump();
      expect(TtcHomePrefs.instance.checkDismissed, isTrue);
      expect(card, findsNothing);

      final p = await SharedPreferences.getInstance();
      expect(p.getBool('ttc_home_check_dismissed'), isTrue,
          reason: '"Not now" has to survive a restart');
    });

    test('the "what a check involves" read resolves', () {
      expect(ttcReadById(kTtcCheckReadId), isNotNull);
    });
  });

  // ===========================================================================
  group('8. the calendar, natural cycles only', () {
    test('a fertile day names the due date it would bring', () {
      inWindow();
      final facts = ttcFactsFor(today);
      final line = ttcCalendarDueLine(today, facts);
      expect(line, isNotNull);
      expect(line, startsWith('If this cycle works, your due date would be '
          'around'));
      final due = ttcDueDateIfConceivedOn(today);
      expect(due.difference(today).inDays, 266);
      expect(line, contains('${due.year}'));
    });

    test('an ordinary day names nothing', () {
      inWindow();
      final d = ago(10); // cycle day 3, a period day
      expect(ttcCalendarDueLine(d, ttcFactsFor(d)), isNull);
    });

    test('a clinic cycle gets neither line', () {
      inWindow();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      expect(ttcCalendarDueLine(today, ttcFactsFor(today)), isNull);
      final expected = ago(12).add(const Duration(days: 28));
      expect(ttcFactsFor(expected).isExpectedPeriod, isFalse);
    });

    test('"Period expected" on the day, on her own cycle', () {
      inWindow();
      final expected = DateTime(ago(12).year, ago(12).month, ago(12).day + 28);
      expect(ttcFactsFor(expected).isExpectedPeriod, isTrue);
      expect(kTtcCalendarPeriodExpected, 'Period expected');
    });
  });

  // ===========================================================================
  group('9. hide sex and intimacy content', () {
    test('the home leaves intimacy cards and reads out', () async {
      await TtcContentPrefs.instance.setHideIntimate(true);
      for (var i = 0; i < 30; i++) {
        final card = ttcHomeInsightFor(ago(i), phase: TtcDayPhase.window);
        expect(kTtcIntimateInsightIds.contains(card.id), isFalse);
        final ids = ttcHomeReadIdsFor(ago(i), phase: TtcDayPhase.window);
        expect(ids.where(kTtcIntimateReadIds.contains), isEmpty);
        expect(ids, hasLength(4));
      }
    });

    test('and puts them back when she turns it off', () async {
      await TtcContentPrefs.instance.setHideIntimate(false);
      final seen = <String>{
        for (var i = 0; i < 30; i++)
          ...ttcHomeReadIdsFor(ago(i), phase: TtcDayPhase.window),
      };
      expect(seen.where(kTtcIntimateReadIds.contains), isNotEmpty);
    });

    test('Learn hides the intimacy reads, never a timing read', () async {
      await TtcContentPrefs.instance.setHideIntimate(true);
      final sex = ttcReadById('ttc_read_sex_homework')!;
      final timing = ttcReadById('ttc_read_timing_myths')!;
      expect(ttcLearnShows(sex), isFalse);
      expect(ttcLearnShows(timing), isTrue);
      await TtcContentPrefs.instance.setHideIntimate(false);
      expect(ttcLearnShows(sex), isTrue);
    });

    testWidgets('Learn search does not list a hidden read', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final sex = ttcReadById('ttc_read_sex_homework')!;

      await TtcContentPrefs.instance.setHideIntimate(true);
      await tester.pumpWidget(const MaterialApp(home: TtcLearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      // A word from the title, not the title: the field itself would match.
      await tester.enterText(find.byType(TextField), 'homework');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(sex.title.en), findsNothing);

      await TtcContentPrefs.instance.setHideIntimate(false);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(sex.title.en), findsWidgets);
    });

    testWidgets('the switch lives in You, TTC only, and moves the pref',
        (tester) async {
      final titles = [
        for (final t in pvYouContentFor(LifeStage.tryingToConceive).things)
          t.title
      ];
      expect(titles, containsAll(['Messages', kTtcWhatYouSee]));
      for (final s in [LifeStage.pregnancy, LifeStage.parenting]) {
        expect(
            pvYouContentFor(s).things.map((t) => t.title),
            isNot(contains(kTtcWhatYouSee)),
            reason: 'the switch is TTC only');
      }

      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: TtcContentPrefsSheet())));
      expect(find.text(kTtcHideIntimate), findsOneWidget);
      expect(find.text(kTtcHideIntimateLine), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_hide_intimate_switch')));
      await tester.pump();
      expect(TtcContentPrefs.instance.hideIntimate, isTrue);
    });
  });

  // ===========================================================================
  group('10. Trying to conceive 101', () {
    test('seven steps, in the gap analysis\'s order', () {
      expect(kTtcLearnStartIds, [
        'ttc_read_three_months_before',
        'ttc_read_folic_acid',
        'ttc_read_how_conception_works',
        'ttc_read_timing_myths',
        'ttc_read_stress_fertility',
        'ttc_read_when_to_test',
        'ttc_read_when_to_seek_help',
      ]);
      expect(ttcLearnStartHere().map((r) => r.id).toList(), kTtcLearnStartIds,
          reason: 'a step does not resolve to a read');
      expect(TtcS.current().learnStartTitle, 'Trying to conceive 101');
    });

    test('no counts in the course copy', () {
      final copy =
          '${TtcS.current().learnStartTitle} ${TtcS.current().learnStartLead}';
      expect(RegExp(r'\d+ of \d+|\bseven\b|\b7\b').hasMatch(copy), isFalse);
    });

    test('the home card steps aside after two steps are opened', () async {
      expect(TtcHomePrefs.instance.offer101, isTrue);
      await TtcHomePrefs.instance.markOpened('ttc_read_three_months_before');
      expect(TtcHomePrefs.instance.offer101, isTrue);
      await TtcHomePrefs.instance.markOpened('ttc_read_not_in_course');
      expect(TtcHomePrefs.instance.offer101, isTrue,
          reason: 'a read outside the course counted');
      await TtcHomePrefs.instance.markOpened('ttc_read_folic_acid');
      expect(TtcHomePrefs.instance.offer101, isFalse);
    });

    testWidgets('someone new sees it on the home', (tester) async {
      inWindow();
      await pumpHome(tester);
      expect(find.byKey(const ValueKey('ttc_home_101_card')), findsOneWidget);
      expect(find.text(kTtc101Title), findsOneWidget);
      expect(
          find.text('Next: ${ttcReadById(kTtc101ReadIds.first)!.title.en}'),
          findsOneWidget);
    });
  });

  // ===========================================================================
  group('11. the chats are reachable', () {
    test('after a new period: offered today or yesterday, never the first',
        () {
      final starts = [ago(56), ago(28), today];
      expect(ttcShouldOfferPeriodTalk(start: today, starts: starts), isTrue);
      expect(
          ttcShouldOfferPeriodTalk(
              start: ago(1), starts: [ago(57), ago(29), ago(1)]),
          isTrue);
      expect(
          ttcShouldOfferPeriodTalk(
              start: ago(5), starts: [ago(61), ago(33), ago(5)]),
          isFalse,
          reason: 'a period from last week is not news today');
      expect(ttcShouldOfferPeriodTalk(start: today, starts: [today]), isFalse);
      expect(
          ttcShouldOfferPeriodTalk(start: ago(28), starts: starts), isFalse,
          reason: 'correcting an older period is not a new one');
    });

    test('both ways of logging a period call it', () {
      expect(_src('lib/screens/ttc/ttc_cycle_companion.dart'),
          contains('showTtcPeriodCameNudge('));
      expect(_src('lib/screens/ttc/ttc_today_screen.dart'),
          contains('showTtcPeriodCameNudge('));
    });

    test('the cycle report walks her through it', () {
      final src = _src('lib/screens/ttc/ttc_cycle_report_screen.dart');
      expect(src, contains("'ttc_chat/cycle_report'"));
      // Kept for revert (2026-09-28): contains('Walk me through it')
      expect(src, contains('Walk me through my report'));
      expect(src, contains('_WalkMeThrough('));
    });

    testWidgets('the pregnancy test card offers "Should I test?"',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 9000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: TtcSymptomLogScreen(day: today, focusGroup: 'ovulation_test')));
      await tester.pump(const Duration(milliseconds: 500));
      // The logger wears the tool shell since 2026-09-27, whose sheet is a
      // full screen tall, so even this tall surface scrolls to the test card;
      // the scroll to the test card starts on the frame above, so its 320ms
      // run and the frame after it have to pass before a tap lands.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      final link = find.byKey(const ValueKey('ttc_log_should_test'));
      expect(link, findsOneWidget);
      await tester.tap(link);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(TtcShouldTestChatScreen), findsOneWidget);
      await drain(tester);
    });

    test('every surface the home opens resolves', () {
      for (final id in [
        'ttc_messages',
        'ttc_chat/should_test',
        'ttc_chat/period_came',
        'ttc_chat/cycle_report',
        'ttc_fertility_help',
        'ttc_read/$kTtcPeriodCameReadId',
        'ttc_read/$kTtcCheckReadId',
        for (final id in kTtc101ReadIds) 'ttc_read/$id',
      ]) {
        expect(ttcFirstSurface([id]), id, reason: '$id does not resolve');
      }
    });
  });
}
