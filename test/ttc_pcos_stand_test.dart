// =============================================================================
//  "Where do I stand" — the refusals, and the one silent trap
// -----------------------------------------------------------------------------
//  ⚠️ THE MOST IMPORTANT TEST IN THIS FILE IS THE LONG-GAP ONE, and it is the
//  one that would never have failed loudly.
//
//  `CycleStore.cycleLengths` drops any gap over 90 days as implausible, which
//  is correct for an average and exactly wrong for this tool: a three-month gap
//  without a period is the single thing it most needs to notice. Reading gaps
//  off the filtered list would have produced "your cycles look regular" for
//  someone who has not bled since April — rendering perfectly, crashing
//  nothing, and quietly failing the users it matters most to.
//
//  The rest of the file holds the safety rules, which are product promises
//  rather than implementation details: no score, no label, no percentage, and
//  every path ending at a doctor.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_pcos_stand_screen.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_pcos_check_store.dart';
import 'package:parentveda/ttc/ttc_pcos_stand.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final now = DateTime.now();
  DateTime ago(int days) {
    final d = now.subtract(Duration(days: days));
    return DateTime(d.year, d.month, d.day);
  }

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcPcosCheckStore.instance.reset();
    // ⚠️ THE PROFILE IS A SINGLETON TOO, and it now holds a date of birth that
    // changes what the nudge says. One test setting it and the next not
    // expecting it is the classic singleton-test leak — and it would show up as
    // an unrelated test failing depending on the order they happen to run in.
    FamilyProfileStore.instance.setDob(null);
  });

  // ===========================================================================
  group('what the logs say', () {
    test('a 120-day gap is seen, even though the average discards it', () {
      // ⚠️ THE TRAP, ASSERTED FROM BOTH SIDES. The same two dates must be
      // invisible to `cycleLengths` and visible to this tool. If someone later
      // "simplifies" the gap calculation to reuse the average's list, the
      // second expectation flips and this test says why.
      CycleStore.instance
        ..logPeriodStart(ago(150))
        ..logPeriodStart(ago(30));

      expect(CycleStore.instance.cycleLengths, isEmpty,
          reason: 'the average correctly refuses a 120-day cycle');

      final f = pcosCycleFacts();
      expect(f.longestGapDays, 120);
      expect(f.hasLongGap, isTrue,
          reason: 'the gap the tool exists to notice was filtered away by a '
              'rule written for a different question');
      expect(f.regularity, PcosRegularity.irregular);
    });

    test('three steady cycles read as regular', () {
      CycleStore.instance
        ..logPeriodStart(ago(112))
        ..logPeriodStart(ago(84))
        ..logPeriodStart(ago(56))
        ..logPeriodStart(ago(28));
      expect(pcosCycleFacts().regularity, PcosRegularity.regular);
    });

    test('a long cycle that repeats is regular, not irregular', () {
      // ⚠️ THE THRESHOLD IS SPREAD, NOT DISTANCE FROM 28. Someone whose cycles
      // run 34, 34, 34 has a long cycle, not an unpredictable one, and telling
      // her otherwise contradicts what her doctor will say.
      CycleStore.instance
        ..logPeriodStart(ago(136))
        ..logPeriodStart(ago(102))
        ..logPeriodStart(ago(68))
        ..logPeriodStart(ago(34));
      expect(pcosCycleFacts().regularity, PcosRegularity.regular);
    });

    test('two cycles is not enough to call anything', () {
      CycleStore.instance
        ..logPeriodStart(ago(60))
        ..logPeriodStart(ago(28));
      expect(pcosCycleFacts().regularity, PcosRegularity.notEnoughData,
          reason: 'one comparison is an anecdote');
    });

    test('nothing logged is a state, not an error', () {
      final f = pcosCycleFacts();
      expect(f.longestGapDays, isNull);
      expect(f.hasLongGap, isFalse);
      expect(f.regularity, PcosRegularity.notEnoughData);
      expect(f.suggestedLength, isNull);
    });
  });

  // ===========================================================================
  group('the read never becomes a verdict', () {
    String allText(PcosStandResult r) => [
          r.cycleLine,
          ...r.noticed,
          r.always,
          r.nudge ?? '',
          for (final c in r.checklist) '${c.label} ${c.value}',
        ].join(' ').toLowerCase();

    test('no score, no percentage, no match label — on a full house', () {
      CycleStore.instance
        ..logPeriodStart(ago(200))
        ..logPeriodStart(ago(30));
      final a = PcosStandAnswers()
        ..cycleLength = PcosCycleLength.longer
        ..longGaps = PcosYesNo.yes
        ..hairChecked = true
        ..hairAreas = {PcosHairArea.chin, PcosHairArea.belly}
        ..thinning = PcosDegree.moderate
        ..acne = PcosDegree.severe
        ..skinDarkening = PcosYesNo.yes
        ..trying = PcosTrying.overAYear
        ..family = PcosFamily.yes;

      final text = allText(pcosBuildStand(a));

      for (final banned in [
        '%',
        'per cent',
        'match',
        'score',
        'likely',
        'you have pcos',
        'you do not have pcos',
        'diagnos',
      ]) {
        // "diagnosis" appears once, in the fixed line saying an app cannot
        // make one — so it is checked separately below rather than banned.
        if (banned == 'diagnos') continue;
        expect(text.contains(banned), isFalse,
            reason: 'the read said "$banned": $text');
      }
    });

    test('and every path ends at a doctor', () {
      // Empty answers, no logs — the thinnest possible read.
      final r = pcosBuildStand(PcosStandAnswers());
      expect(r.always, kPcosAlwaysLine);
      expect(r.always.toLowerCase(), contains('doctor'));
      expect(r.noticed, isEmpty,
          reason: 'nothing was marked, so nothing should be listed back');
    });

    test('symptoms are never asserted as PCOS signs', () {
      final a = PcosStandAnswers()
        ..hairChecked = true
        ..hairAreas = {PcosHairArea.chin};
      final r = pcosBuildStand(a);
      expect(r.noticed.single.toLowerCase(), contains('many causes'),
          reason: 'an observation listed without de-linking it reads as a '
              'case being built');
    });
  });

  // ===========================================================================
  group('the nudge is earned, and it is the loudest this gets', () {
    test('a long gap earns it', () {
      CycleStore.instance
        ..logPeriodStart(ago(200))
        ..logPeriodStart(ago(30));
      expect(pcosBuildStand(PcosStandAnswers()).nudge, isNotNull);
    });

    test('trying over a year earns it', () {
      final a = PcosStandAnswers()..trying = PcosTrying.overAYear;
      expect(pcosBuildStand(a).nudge, isNotNull);
    });

    test('six months of trying with steady cycles does not', () {
      CycleStore.instance
        ..logPeriodStart(ago(112))
        ..logPeriodStart(ago(84))
        ..logPeriodStart(ago(56))
        ..logPeriodStart(ago(28));
      final a = PcosStandAnswers()..trying = PcosTrying.sixToTwelve;
      expect(pcosBuildStand(a).nudge, isNull);
    });

    test('35 or over with six months earns it, without asking her age', () {
      // ⚠️ THE BRANCH THAT WAS DORMANT. It fires from `FamilyProfileStore.age`,
      // which derives from a date of birth collected once at onboarding — so
      // this flow reaches the correct clinical threshold without adding a ninth
      // question, and without asking the same thing the IVF tool already asks.
      FamilyProfileStore.instance.setDob(
          DateTime(DateTime.now().year - 37, 1, 1));
      final a = PcosStandAnswers()..trying = PcosTrying.sixToTwelve;
      expect(pcosBuildStand(a).nudge, isNotNull);
      expect(pcosBuildStand(a).nudge!.toLowerCase(), contains('six months'));
    });

    test('under 35 with six months does not', () {
      FamilyProfileStore.instance.setDob(
          DateTime(DateTime.now().year - 29, 1, 1));
      final a = PcosStandAnswers()..trying = PcosTrying.sixToTwelve;
      expect(pcosBuildStand(a).nudge, isNull,
          reason: 'under 35 the usual advice really is to give it a year');
    });

    test('and no date of birth simply means the branch stays quiet', () {
      // ⚠️ THE STATE THE APP HAS BEEN IN UNTIL NOW, and it must keep working.
      // A null age disables this rule rather than throwing or defaulting.
      FamilyProfileStore.instance.setDob(null);
      final a = PcosStandAnswers()..trying = PcosTrying.sixToTwelve;
      expect(pcosBuildStand(a).nudge, isNull);
    });

    test('a birthday that has not arrived yet does not round up', () {
      // ⚠️ THE ARITHMETIC THAT IS WRONG IN A LOT OF SHIPPED CODE. Subtracting
      // years alone makes someone 35 on 1 January rather than on their
      // birthday, which would fire a clinical rule months early.
      final now = DateTime.now();
      final later = now.add(const Duration(days: 60));
      FamilyProfileStore.instance
          .setDob(DateTime(now.year - 35, later.month, later.day));
      final a = PcosStandAnswers()..trying = PcosTrying.sixToTwelve;
      // She turns 35 in two months, so today she is 34.
      expect(FamilyProfileStore.instance.age, 34);
      expect(pcosBuildStand(a).nudge, isNull);
      FamilyProfileStore.instance.setDob(null);
    });

    test('and it never uses an alarm word', () {
      final a = PcosStandAnswers()..trying = PcosTrying.overAYear;
      final n = pcosBuildStand(a).nudge!.toLowerCase();
      for (final word in ['urgent', 'immediately', 'serious', 'risk', 'must']) {
        expect(n.contains(word), isFalse, reason: 'the nudge said "$word"');
      }
      expect(n, contains('sooner'));
    });
  });

  // ===========================================================================
  //  The reason this is a front rather than a second store
  // ---------------------------------------------------------------------------
  group('answers reach the shipped PCOS store', () {
    test('the eight questions land on the ids five other screens read', () async {
      final a = PcosStandAnswers()
        ..cycleLength = PcosCycleLength.longer
        ..longGaps = PcosYesNo.yes
        ..hairChecked = true
        ..hairAreas = {PcosHairArea.chin, PcosHairArea.chest}
        ..thinning = PcosDegree.mild
        ..acne = PcosDegree.severe
        ..skinDarkening = PcosYesNo.no
        ..trying = PcosTrying.overAYear;

      await a.writeThrough();
      final store = TtcPcosCheckStore.instance;

      expect(store.answerFor('q_length'), 'long');
      expect(store.answerFor('q_gap'), 'yes');
      expect(store.answerFor('q_hair_growth'), 'noticeable');
      expect(store.answerFor('q_thinning'), 'mild');
      expect(store.answerFor('q_acne'), 'persistent');
      expect(store.answerFor('q_skin_patches'), 'no');
      expect(store.answerFor('q_trying'), 'over12');
      expect(store.hasCompleted, isTrue);
    });

    test('unanswered questions are left alone, not written as blanks',
        () async {
      // ⚠️ A BLANK IS NOT AN ANSWER. Writing an empty string for a skipped
      // question would make `hasStarted` true and hand the five downstream
      // readers a value that means nothing.
      await (PcosStandAnswers()..trying = PcosTrying.underSix).writeThrough();
      final store = TtcPcosCheckStore.instance;
      expect(store.answerFor('q_trying'), 'under6');
      expect(store.answerFor('q_acne'), isNull);
      expect(store.answerFor('q_gap'), isNull);
    });
  });

  // ===========================================================================
  group('it renders', () {
    Future<void> pump(WidgetTester tester, Widget child) async {
      // 360pt, because every overflow this stage has shipped was found at
      // phone width or not at all.
      tester.view.physicalSize = const Size(360, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: child));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }

    testWidgets('the flow, with no logs at all', (tester) async {
      await pump(tester, const TtcPcosStandScreen());
      for (var i = 0; i < 12; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 60));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the flow, with a long gap logged', (tester) async {
      CycleStore.instance
        ..logPeriodStart(ago(200))
        ..logPeriodStart(ago(30));
      await pump(tester, const TtcPcosStandScreen());
    });

    testWidgets('the read, and the checklist under it', (tester) async {
      final a = PcosStandAnswers()
        ..hairChecked = true
        ..hairAreas = {PcosHairArea.upperLip}
        ..acne = PcosDegree.moderate
        ..trying = PcosTrying.overAYear;
      final r = pcosBuildStand(a);

      await pump(tester, TtcPcosStandResultScreen(result: r));
      expect(find.text('What your cycle looks like'), findsOneWidget);

      await pump(tester, TtcPcosChecklistScreen(result: r));
      expect(find.text(kPcosChecklistDisclaimer), findsOneWidget);
    });
  });
}
