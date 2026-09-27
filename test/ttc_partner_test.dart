// =============================================================================
//  TTC Partner Mode
// -----------------------------------------------------------------------------
//  The master document is emphatic that the partner is "not observer, not
//  assistant" and that TTC's partner experience must be STRONGER than
//  pregnancy's. That is easy to say and easy to lose - a partner mode decays
//  into an assistant one card at a time.
//
//  So the two rules that hold it up are pinned here:
//    1. A real share of his content is about HIS body, not about managing hers.
//    2. His journal entries are attributed to him and land in the shared
//       journal she reads.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_partner_screen.dart';
import 'package:parentveda/screens/ttc/ttc_profile_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_partner_data.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';
import 'package:parentveda/screens/ttc/ttc_round_strings.dart'
    show ttcPartnerRoundLine;

Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcPartnerMode.instance.on = false;
    TtcLang.instance.hinglish = false;
  });

  tearDown(() => TtcPartnerMode.instance.on = false);

  // ===========================================================================
  group('he is a partner, not an assistant', () {
    test('a real share of the missions are about his own body', () {
      final his = ttcMissions.where((m) => m.forHimself).length;
      expect(his, greaterThanOrEqualTo(4),
          reason:
              'too few missions are about him - this has become an assistant mode');
      // And not so many that supporting her disappears either.
      expect(his, lessThan(ttcMissions.length));
    });

    test('every chapter tells him something about his own half', () {
      for (final c in TtcChapter.values) {
        final brief = ttcPartnerBriefs[c];
        expect(brief, isNotNull, reason: '$c has no partner brief');
        expect(brief!.yourBody(false), isNotEmpty, reason: '$c');
        expect(brief.yourBody(true), isNotEmpty, reason: '$c');
      }
    });

    test('no mission tells him to manage her feelings', () {
      const banned = ['cheer her up', 'calm her down', 'tell her to relax'];
      for (final m in ttcMissions) {
        final copy = '${m.title(false)} ${m.body(false)}'.toLowerCase();
        for (final b in banned) {
          expect(copy.contains(b), isFalse, reason: '${m.id} says "$b"');
        }
      }
    });

    test('his content is bilingual throughout', () {
      for (final m in ttcMissions) {
        expect(m.title(true), isNotEmpty, reason: m.id);
        expect(m.body(true), isNot(m.body(false)), reason: m.id);
      }
      for (final c in TtcChapter.values) {
        final b = ttcPartnerBriefs[c]!;
        expect(b.sheMayFeel(true), isNot(b.sheMayFeel(false)), reason: '$c');
        expect(b.youCan(true), isNot(b.youCan(false)), reason: '$c');
      }
    });

    test('mission ids are unique', () {
      final ids = ttcMissions.map((m) => m.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  // ===========================================================================
  group('one brain, two doors', () {
    test('his insights come from the shared library, not a second one', () {
      final forHim = ttcInsights.where((i) => i.forPartner).toList();
      expect(forHim, isNotEmpty);
      // And some are hers alone, so the flag is doing real work.
      expect(ttcInsights.any((i) => !i.forPartner), isTrue);
    });

    test('he reads the same chapter she is in', () {
      // Both sides resolve from TtcStore, so they cannot disagree about where
      // the couple is.
      final chapter = TtcStore.instance.today.chapter;
      expect(ttcPartnerBriefs.containsKey(chapter), isTrue);
    });
  });

  // ===========================================================================
  group('the partner screen', () {
    testWidgets('builds and shows his mission, her brief and his half',
        (tester) async {
      await pumpTall(tester, const TtcPartnerTodayScreen());
      final t = const TtcS(false);
      expect(find.text(t.partnerMission.toUpperCase()), findsOneWidget);
      expect(find.text(t.partnerSupport), findsOneWidget);
      expect(find.text(t.partnerYourBody), findsOneWidget);
      expect(find.text(t.partnerJournal), findsOneWidget);
    });

    testWidgets('builds in every chapter', (tester) async {
      // Driving the chapter through the store rather than a parameter, since
      // the screen reads it the same way the app does.
      TtcStore.instance.confirmPregnancy();
      await pumpTall(tester, const TtcPartnerTodayScreen());
      expect(tester.takeException(), isNull);
      TtcStore.instance.clearPregnancyConfirmation();
      CycleStore.instance
          .logPeriodStart(DateTime.now().subtract(const Duration(days: 12)));
      await pumpTall(tester, const TtcPartnerTodayScreen());
      expect(tester.takeException(), isNull);
    });

    testWidgets('builds in Hinglish', (tester) async {
      TtcLang.instance.hinglish = true;
      await pumpTall(tester, const TtcPartnerTodayScreen());
      expect(tester.takeException(), isNull);
      TtcLang.instance.hinglish = false;
    });
  });

  // ===========================================================================
  group('the shell branches to him', () {
    testWidgets('her Today renders when partner mode is off', (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      expect(find.byType(TtcPartnerTodayScreen), findsNothing);
      expect(find.text(const TtcS(false).myJournal), findsWidgets);
    });

    testWidgets('turning partner mode on swaps the whole stage',
        (tester) async {
      await pumpTall(tester, const TtcTodayScreen());
      TtcPartnerMode.instance.on = true;
      await tester.pump();
      expect(find.byType(TtcPartnerTodayScreen), findsOneWidget);
      expect(find.text(const TtcS(false).partnerYourBody), findsOneWidget);
    });

    testWidgets('the dev switch is reachable from both sides', (tester) async {
      // ⚠️ IT LIVES IN PROFILE NOW, and Profile is precisely why that works:
      // it is the one surface on both versions AND both partners' shells, so a
      // control for crossing between them can only live there. Pinned to her
      // Today, the switch was unreachable from his half of the product except
      // by going back.
      await pumpTall(tester, const TtcProfileScreen());
      expect(find.text(const TtcS(false).partnerHim), findsOneWidget);
      TtcPartnerMode.instance.on = true;
      await tester.pump();
      expect(find.text(const TtcS(false).partnerHer), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the shared journal is genuinely shared', () {
    test('his entries are attributed to him', () {
      final e = TtcJournalStore.instance.add(
          kind: TtcEntryKind.feeling,
          text: 'Hard week',
          author: TtcAuthor.partner);
      expect(e.author, TtcAuthor.partner);
    });

    test('both authors land in one list, in one order', () {
      final s = TtcJournalStore.instance;
      s.add(
          kind: TtcEntryKind.memory,
          text: 'hers',
          on: DateTime(2026, 7, 1));
      s.add(
          kind: TtcEntryKind.memory,
          text: 'his',
          author: TtcAuthor.partner,
          on: DateTime(2026, 7, 2));
      expect(s.count, 2);
      // Newest first, regardless of who wrote it - not grouped by author.
      expect(s.entries.first.text, 'his');
    });
  });

  // ===========================================================================
  //  His round line (2026-09-26, docs/TTC-TREATMENT-FLOW.md §3g, B10): the
  //  round is couple-scoped, so he sees its step and date, and what it asks
  //  of him. Never her cycle, and never the result.
  // ===========================================================================
  group('his round line', () {
    DateTime day(int n) {
      final t = DateTime.now();
      return DateTime(t.year, t.month, t.day + n);
    }

    TtcTreatmentCycle round() => TtcTreatmentCycle(
          dates: {
            TtcTreatmentStep.baselineScan: day(-12),
            TtcTreatmentStep.stimStart: day(-11),
            TtcTreatmentStep.trigger: DateTime(
                day(-2).year, day(-2).month, day(-2).day, 22, 15),
            TtcTreatmentStep.retrieval: day(0),
            TtcTreatmentStep.transfer: day(5),
            TtcTreatmentStep.betaTest: day(16),
          },
          kind: TtcRoundKind.ivfFresh,
        );

    setUp(() => TtcTreatmentStore.instance.resetForTest());
    tearDown(() => TtcTreatmentStore.instance.resetForTest());

    test('every day of the round: the step and its date, never her cycle', () {
      final banned = RegExp(
          r'cycle day|period|fertile|ovulat|late|not this time|positive|'
          r'negative|chance|%',
          caseSensitive: false);
      final r = round();
      for (var n = -14; n <= 20; n++) {
        final line = ttcPartnerRoundLine(r, day(n));
        if (line == null) continue;
        final (a, b, c) = line;
        final all = '$a $b ${c ?? ''}';
        expect(banned.hasMatch(all), isFalse, reason: 'day $n: $all');
      }
      // Collection day asks for his sample.
      final (_, what, note) = ttcPartnerRoundLine(r, day(-1))!;
      expect(what, 'Egg collection tomorrow');
      expect(note, contains('sample'));
      // The blood test is named by its date, never counted down to.
      final (_, test, _) = ttcPartnerRoundLine(r, day(10))!;
      expect(test, startsWith('Blood test on '));
      expect(test, isNot(matches(RegExp(r'in \d+ days'))));
    });

    test('closed: nothing, the result is hers to tell', () {
      for (final o in TtcRoundOutcome.values) {
        expect(ttcPartnerRoundLine(round().closed(o, day(0)), day(1)), isNull,
            reason: o.name);
      }
      // Waiting to hear after the test: nothing either.
      expect(ttcPartnerRoundLine(round(), day(17)), isNull);
    });

    testWidgets('his home shows the round, and none of her cycle',
        (tester) async {
      CycleStore.instance
        ..logPeriodStart(DateTime.now().subtract(const Duration(days: 40)))
        ..logPeriodStart(DateTime.now().subtract(const Duration(days: 13)));
      final r = round();
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh, dates: r.dates);
      TtcPartnerMode.instance.on = true;
      await pumpTall(tester, const TtcPartnerTodayScreen());
      final card = find.byKey(const ValueKey('ttc_partner_round_line'));
      expect(card, findsOneWidget);
      final line = ttcPartnerRoundLine(
          TtcTreatmentStore.instance.cycle, DateTime.now())!;
      expect(find.descendant(of: card, matching: find.text(line.$2)),
          findsOneWidget);
      expect(find.textContaining('Cycle day'), findsNothing);
      // ⚠️ HER STATUS, NOT THE WORDS (2026-09-28): his "For you today" rail
      // rotates by date and can hold a read titled "Your fertile window is
      // wider than most people think", which is teaching, not her cycle. The
      // test checks no line about HER days. Kept for revert:
      //   expect(find.textContaining('fertile window', findRichText: true),
      //       findsNothing);
      expect(find.textContaining('Your fertile days are', findRichText: true),
          findsNothing);
      expect(find.textContaining('Her fertile window', findRichText: true),
          findsNothing);
    });

    testWidgets('no round, no line', (tester) async {
      await pumpTall(tester, const TtcPartnerTodayScreen());
      expect(find.byKey(const ValueKey('ttc_partner_round_line')),
          findsNothing);
    });
  });
}
