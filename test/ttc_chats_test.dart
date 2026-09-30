// =============================================================================
//  The three scripted chats
// -----------------------------------------------------------------------------
//  "Should I test?" is built first and tested hardest, because it is the one
//  that could do harm: a wrong date tells someone a negative means something it
//  does not, and a date on a clinic cycle contradicts the one test that counts.
//
//  The branches are asserted on the pure advice AND on what the script says,
//  and every reachable line of all three chats is walked and scanned: no
//  chance, no dash, no exclamation mark, and no chip that opens nothing.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/chats/ttc_chat.dart';
import 'package:parentveda/screens/ttc/chats/ttc_cycle_report_chat.dart';
import 'package:parentveda/screens/ttc/chats/ttc_period_came_chat.dart';
import 'package:parentveda/screens/ttc/chats/ttc_should_test_chat.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_cycle_report.dart';
import 'package:parentveda/ttc/ttc_period_due.dart';

DateTime _d(int y, int m, int d) => DateTime(y, m, d);

/// Every line and chip label reachable from [start], following `next` only.
/// Actions (a date picker, the positive-test dialog) need a context and are
/// followed separately where it matters.
({List<String> lines, List<String> labels, List<List<String>> opens}) _walk(
    TtcChatStep Function() start) {
  final lines = <String>[];
  final labels = <String>[];
  final opens = <List<String>>[];
  final seen = <String>{};
  final queue = <TtcChatStep Function()>[start];
  var guard = 0;
  while (queue.isNotEmpty && guard++ < 400) {
    final step = queue.removeAt(0)();
    final sig = step.say.join('|') +
        step.choices.map((c) => c.label).join('|');
    if (!seen.add(sig)) continue;
    lines.addAll(step.say);
    for (final c in step.choices) {
      labels.add(c.label);
      if (c.open != null) opens.add(c.open!);
      if (c.next != null) queue.add(c.next!);
    }
  }
  return (lines: lines, labels: labels, opens: opens);
}

TtcChatChoice _choice(TtcChatStep step, String label) =>
    step.choices.firstWhere((c) => c.label == label,
        orElse: () => throw StateError(
            'no chip "$label" in ${step.choices.map((c) => c.label)}'));

/// Read ids the lead confirmed are written but not yet in the library's
/// aggregator. A chip naming only these hides until they land (see
/// `ttcFirstOpenable`), which is correct; anything else must resolve today.
const _pendingReads = {
  'ttc_read/ttc_read_faint_line',
  'ttc_read/ttc_read_when_to_test',
  'ttc_read/ttc_read_how_to_test',
  'ttc_read/ttc_read_late_negative',
  'ttc_read/ttc_read_two_week_wait',
  'ttc_read/ttc_read_period_came',
  'ttc_read/ttc_read_trying_takes_over',
};

final _banned = RegExp(
    r'chance|probabil|odds|%|per cent|success rate|—|–| - |!',
    caseSensitive: false);

// 2026-09-28 (explicit labels): the chat choices name their thing. Was
// 'I took one already', 'What does it mean?', 'Shall we log it?' and
// 'It started yesterday'.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final today = _d(2026, 9, 10);

  // ===========================================================================
  group('when is it due, and what can a test say', () {
    TtcTestAdvice advise({
      TimingOwnership owner = TimingOwnership.parentveda,
      DateTime? last,
      int? len = 28,
    }) =>
        ttcTestAdvice(
            ownership: owner, today: today, lastStart: last, cycleLength: len);

    test('early: before the due date, with the days until it', () {
      final a = advise(last: _d(2026, 8, 20)); // due 17 Sep
      expect(a.branch, TtcTestBranch.early);
      expect(a.due, _d(2026, 9, 17));
      expect(a.daysUntil, 7);
    });

    test('due today', () {
      final a = advise(last: _d(2026, 8, 13));
      expect(a.branch, TtcTestBranch.dueToday);
    });

    test('late, with how late', () {
      final a = advise(last: _d(2026, 8, 10));
      expect(a.branch, TtcTestBranch.late);
      expect(a.daysLate, 3);
      expect(a.looksStale, isFalse);
      expect(advise(last: _d(2026, 6, 1)).looksStale, isTrue);
    });

    test('clinic: no date, whatever the dates say', () {
      for (final owner in [
        TimingOwnership.clinicGuided,
        TimingOwnership.clinicControlled,
      ]) {
        final a = advise(owner: owner, last: _d(2026, 8, 10));
        expect(a.branch, TtcTestBranch.clinic);
        expect(a.due, isNull);
      }
    });

    test('no dates, and no cycle length', () {
      expect(advise().branch, TtcTestBranch.noDates);
      expect(advise(last: _d(2026, 8, 20), len: null).branch,
          TtcTestBranch.needCycleLength);
    });
  });

  // ===========================================================================
  group('"Should I test?" says the right thing on each branch', () {
    TtcShouldTestChat chat({
      TimingOwnership owner = TimingOwnership.parentveda,
      DateTime? last,
      int? len,
      DateTime? beta,
    }) =>
        TtcShouldTestChat(
          facts: TtcShouldTestFacts(
            today: today,
            ownership: owner,
            lastStart: last,
            usualLength: len,
            betaDate: beta,
          ),
        );

    // D7 (2026-09-28): no Start chip; the opening runs into the first step.
    // Kept for revert: expect(s.say.single, <opening>);
    //                  expect(s.choices.single.label, 'Start');
    test('it opens with the gap analysis line and goes straight on', () {
      final s = chat(last: _d(2026, 8, 20), len: 28).start();
      expect(s.say.first,
          "Let's work out if a test will tell you anything yet.");
      expect(s.say.length, greaterThan(1),
          reason: 'the first real step follows the opening line');
      expect(s.choices.map((c) => c.label), isNot(contains('Start')));
      expect(s.choices, isNotEmpty);
    });

    test('early', () {
      final s = chat(last: _d(2026, 8, 20), len: 28).begin();
      expect(s.say.join(' '), contains('Your period is due on Thu 17 Sep'));
      expect(s.say.join(' '), contains("doesn't tell you much"));
      expect(s.say.join(' '), isNot(contains('reliable from today')));
    });

    test('due today', () {
      final s = chat(last: _d(2026, 8, 13), len: 28).begin();
      expect(s.say, contains('Your period is due today.'));
      expect(s.say, contains('A home test is reliable from today.'));
    });

    test('late, then negative: when to retest and when to see a doctor', () {
      final c = chat(last: _d(2026, 8, 5), len: 28);
      final s = c.begin();
      expect(s.say.join(' '), contains('was due on Wed 2 Sep, 8 days ago'));
      final res = _choice(s, 'I took a test already').next!();
      final neg = _choice(res, 'Negative').next!();
      final text = neg.say.join(' ');
      expect(text, contains('test again in three days'));
      expect(text, contains('book a visit with your doctor'));
    });

    test('a faint line and a positive both point to a doctor', () {
      final c = chat(last: _d(2026, 8, 13), len: 28);
      final res = _choice(c.begin(), 'I took a test already').next!();
      expect(_choice(res, 'A faint line').next!().say.join(' '),
          contains('see your doctor'));
      final pos = _choice(res, 'Positive').next!().say.join(' ');
      expect(pos, contains('doctor can confirm'));
      expect(pos, contains('straight away'));
    });

    test('clinic: their date, never ours', () {
      final s = chat(
        owner: TimingOwnership.clinicControlled,
        last: _d(2026, 8, 5),
        len: 28,
        beta: _d(2026, 9, 18),
      ).begin();
      final text = s.say.join(' ');
      expect(text, contains('Your clinic will tell you when to test.'));
      expect(text, contains('Fri 18 Sep'));
      expect(text, isNot(contains('period is due')));
      expect(text, isNot(contains('was due on')));
    });

    test('no dates: we say so and ask', () {
      final c = chat();
      final s = c.begin();
      expect(s.say.first,
          "We don't have enough dates to say when your period is due.");
      expect(s.say, contains('When did your last period start?'));
      // She picks a date, then a length: the chat carries on with her answer.
      final ask = c.afterStart(_d(2026, 8, 20));
      expect(ask.say.join(' '), contains('About how long are your cycles'));
      final after = _choice(ask, 'About 26 to 30 days').next!();
      expect(after.say.join(' '), contains('Your period is due on Thu 17 Sep'));
      // Not sure at all: the three-week rule, never a guessed date.
      final unsure = _choice(s, "I'm not sure").next!();
      expect(unsure.say.join(' '), contains('three weeks'));
    });

    test('a period logged but no cycle length: it asks, never assumes 28', () {
      final s = chat(last: _d(2026, 8, 20)).begin();
      expect(s.say.join(' '), contains('About how long are your cycles'));
    });
  });

  // ===========================================================================
  group('every line of every chat', () {
    final scripts = <String, TtcChatStep Function()>{
      for (final owner in TimingOwnership.values)
        for (final last in [null, _d(2026, 8, 20), _d(2026, 8, 13), _d(2026, 8, 5), _d(2026, 5, 1)])
          'should_test ${owner.name} $last': () => TtcShouldTestChat(
                facts: TtcShouldTestFacts(
                    today: today,
                    ownership: owner,
                    lastStart: last,
                    usualLength: 28,
                    irregular: last == _d(2026, 8, 5)),
              ).start(),
      'should_test no length': () => TtcShouldTestChat(
            facts: TtcShouldTestFacts(today: today, lastStart: _d(2026, 8, 20)),
          ).start(),
      for (final owner in TimingOwnership.values)
        for (final last in [null, today, _d(2026, 7, 1)])
          'period_came ${owner.name} $last': () => TtcPeriodCameChat(
                today: today,
                lastStart: last,
                ownership: owner,
                logPeriod: (_) {},
              ).start(),
      'report empty': () =>
          TtcCycleReportChat(facts: const TtcCycleReportFacts()).start(),
      'report ready': () => TtcCycleReportChat(
            facts: TtcCycleReportFacts(
              start: _d(2026, 8, 1),
              ranDays: 38,
              bleedDays: 9,
              state: TtcReportState.ready,
              fertileFrom: _d(2026, 8, 19),
              fertileTo: _d(2026, 8, 25),
              lengthNote: const TtcFinding(
                  headline: '38 days, 9 days longer than usual',
                  detail: 'Your recent cycles have averaged 29 days.'),
              loggedDays: 9,
              findings: const [
                TtcFinding(
                    headline: 'Cramps',
                    detail: '4 days this cycle, mostly in the waiting days.'),
              ],
            ),
          ).start(),
      'report clinic': () => TtcCycleReportChat(
            facts: TtcCycleReportFacts(
              start: _d(2026, 8, 1),
              ranDays: 29,
              state: TtcReportState.clinicHeld,
            ),
          ).start(),
      'report current': () => TtcCycleReportChat(
            facts: TtcCycleReportFacts(
                start: _d(2026, 9, 1), state: TtcReportState.noEstimate),
          ).start(),
    };

    test('no chance, no dash, no exclamation mark', () {
      for (final e in scripts.entries) {
        final w = _walk(e.value);
        expect(w.lines, isNotEmpty, reason: e.key);
        for (final t in [...w.lines, ...w.labels]) {
          expect(_banned.hasMatch(t), isFalse, reason: '${e.key}: $t');
        }
      }
    });

    test('every chip opens something real, or waits for a named read', () {
      for (final e in scripts.entries) {
        for (final ids in _walk(e.value).opens) {
          final ok = ttcFirstOpenable(ids) != null ||
              ids.every(_pendingReads.contains);
          expect(ok, isTrue, reason: '${e.key}: $ids opens nothing');
        }
      }
    });

    test('a clinic cycle is never told a fertile window or a due date', () {
      for (final owner in [
        TimingOwnership.clinicGuided,
        TimingOwnership.clinicControlled,
      ]) {
        for (final last in [_d(2026, 8, 20), _d(2026, 8, 5)]) {
          final w = _walk(() => TtcShouldTestChat(
                facts: TtcShouldTestFacts(
                    today: today,
                    ownership: owner,
                    lastStart: last,
                    usualLength: 28),
              ).start());
          final text = w.lines.join(' ');
          expect(text, isNot(contains('period is due')), reason: owner.name);
          expect(text, isNot(contains('fertile')), reason: owner.name);
        }
      }
    });
  });

  // ===========================================================================
  group('"My period came"', () {
    test('it logs only when she says so', () {
      final logged = <DateTime>[];
      final c = TtcPeriodCameChat(
          today: today,
          lastStart: _d(2026, 8, 12),
          ownership: TimingOwnership.parentveda,
          logPeriod: logged.add);
      final meaning = _choice(c.start(), 'What does my period mean?').next!();
      expect(logged, isEmpty);
      expect(meaning.say, contains('Shall we log your period?'));
      _choice(meaning, 'My period started yesterday').next!();
      expect(logged, [_d(2026, 9, 9)]);
    });

    test('already logged: it says so instead of asking', () {
      final c = TtcPeriodCameChat(
          today: today,
          lastStart: today,
          ownership: TimingOwnership.parentveda,
          logPeriod: (_) => fail('must not log twice'));
      final meaning = _choice(c.start(), 'What does my period mean?').next!();
      expect(meaning.say.last, "It's logged for Thu 10 Sep.");
    });
  });

  // ===========================================================================
  group('"My cycle report"', () {
    test('one next step: nothing, or what is worth showing a doctor', () {
      final calm = TtcCycleReportChat(
          facts: TtcCycleReportFacts(
              start: _d(2026, 8, 1), ranDays: 29, bleedDays: 5,
              state: TtcReportState.ready));
      expect(calm.nextStep().say.first, 'Nothing here needs action.');

      final long = TtcCycleReportChat(
          facts: TtcCycleReportFacts(
              start: _d(2026, 8, 1), ranDays: 38, bleedDays: 9,
              state: TtcReportState.ready));
      final text = long.nextStep().say.first;
      expect(text, startsWith('Worth showing a doctor if this keeps happening'));
      expect(text, contains('longer than 35 days'));
      expect(text, contains('more than 7 days'));
      expect(long.nextStep().say.last, contains("isn't a diagnosis"));
    });

    test('a clinic-held cycle names no fertile days', () {
      final c = TtcCycleReportChat(
          facts: TtcCycleReportFacts(
              start: _d(2026, 8, 1),
              ranDays: 29,
              state: TtcReportState.clinicHeld,
              // Even if a caller passed dates, the state decides.
              fertileFrom: _d(2026, 8, 10),
              fertileTo: _d(2026, 8, 16)));
      final text = c.walk().say.join(' ');
      expect(text, contains("we don't mark fertile days"));
      expect(text, isNot(contains('your fertile days were')));
    });

    test('from the live stores, the last completed cycle', () {
      CycleStore.instance.resetForTest();
      final now = DateTime.now();
      CycleStore.instance
        ..logPeriodStart(now.subtract(const Duration(days: 40)))
        ..logPeriodStart(now.subtract(const Duration(days: 10)));
      final f = TtcCycleReportFacts.fromStores();
      expect(f.ranDays, 30);
    });
  });

  // ===========================================================================
  group('the chat widget', () {
    testWidgets('speaks, offers chips, and answers a tap', (tester) async {
      // Tall enough that the whole conversation is laid out at once; a list
      // only builds what is on screen.
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: TtcChatScreen(
          pause: Duration.zero,
          script: TtcShouldTestChat(
            facts: TtcShouldTestFacts(
                today: today, lastStart: _d(2026, 8, 20), usualLength: 28),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Should I test?'), findsOneWidget);
      expect(find.text("Let's work out if a test will tell you anything yet."),
          findsOneWidget);
      // D7 (2026-09-28): the answer follows by itself, no Start tap. Kept
      // for revert: tap 'Start', then expect the Start bubble.
      expect(find.text('Start'), findsNothing);
      expect(find.textContaining('Your period is due on Thu 17 Sep'),
          findsOneWidget);
    });
  });
}
