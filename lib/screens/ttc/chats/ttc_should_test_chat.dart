// =============================================================================
//  "Should I test?" - a scripted chat over her own dates
// -----------------------------------------------------------------------------
//  The gap analysis's script, built as written:
//
//    1. "Let's work out if a test will tell you anything yet."  [Start]
//    2. Her dates: "Your period is due on <date>." Or, when we cannot say, we
//       ask when her last period started and how long her cycles run.
//    3. The branch:
//         early      how long until a test is reliable, and what an early
//                    test can and cannot show
//         due / late a home test is reliable from today, how to take it,
//                    what a faint line means
//         negative   when to test again and when to see a doctor
//         clinic     "Your clinic will tell you when to test."
//    4. Log the result, or read more.
//
//  ⚠️ THE DATE COMES FROM `ttc_period_due.dart`, the same function the "late by
//  a day" message uses, so the message and the chat it opens cannot disagree.
//
//  ⚠️ A CLINIC CYCLE NEVER REACHES A DATE. `ttcTestAdvice` checks ownership
//  before it reads anything else, and the clinic branch below names their
//  blood test and nothing we computed.
//
//  ⚠️ NEVER A CHANCE. Every line is about when a test is reliable, how to read
//  one, and when to see someone. `test/ttc_chats_test.dart` walks every branch
//  and scans what it says.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../ttc/cycle_store.dart';
import '../../../ttc/ttc_chapter.dart';
import '../../../ttc/ttc_period_due.dart';
import '../../../ttc/ttc_store.dart';
import '../../../ttc/ttc_treatment_store.dart';
import '../../../widgets/pv_date_sheet.dart';
import '../ttc_transition_screen.dart';
import 'ttc_chat.dart';

/// What the chat reads, gathered once when it opens.
class TtcShouldTestFacts {
  const TtcShouldTestFacts({
    required this.today,
    this.ownership = TimingOwnership.parentveda,
    this.lastStart,
    this.usualLength,
    this.irregular = false,
    this.betaDate,
    this.firstCycle = false,
  });

  factory TtcShouldTestFacts.fromStores() {
    final store = TtcStore.instance;
    final cycle = CycleStore.instance;
    const engine = TtcChapterEngine();
    final state = store.state();
    return TtcShouldTestFacts(
      today: DateTime.now(),
      ownership: store.ownership,
      lastStart: cycle.lastPeriodStart,
      // Her own length only. The engine's 28-day default is an assumption
      // about her, and a due date built on it would be a guess said as a fact.
      // With no completed cycle, the chat asks her instead.
      //
      // ⚠️ AND NOT ONE THE ENGINE HAS REFUSED (2026-09-26, consistency pass).
      // With a gap in her log that looks like a missed period, the average is
      // poisoned: the home says "not enough logged" and shows no due date, and
      // this chat used to name one anyway from the same bad average. Now it
      // asks her, exactly as it does with no history. Kept for revert:
      //   usualLength:
      //       cycle.cycleLengths.isEmpty ? null : engine.cycleLengthFor(state),
      //
      // ⚠️ AND A FIRST CYCLE USES THE HOME'S OWN ESTIMATE (2026-09-26, the
      // user's decision, "like Flo and What to Expect"). With one period
      // logged and no completed cycle, the hero, the calendar and the window
      // already predict from her stated usual length, else 28 days, marked as
      // an early estimate. This chat used to ask her for a length instead, so
      // it could name a different due day from the one on the home. It now
      // reads the same length (`cycleLengthFor`, which holds the stated-or-28
      // rule) and says the date is early. It still asks when nothing is
      // logged and she has never said a length: then there is no estimate
      // anywhere to agree with, and her answer is kept as her stated length.
      // Kept for revert:
      //   usualLength: cycle.cycleLengths.isEmpty ||
      //           engine.hasUnreliableHistory(state)
      //       ? null
      //       : engine.cycleLengthFor(state),
      usualLength: engine.hasUnreliableHistory(state) ||
              (cycle.lastPeriodStart == null &&
                  store.statedCycleLength == null)
          ? null
          : engine.cycleLengthFor(state),
      irregular: engine.isIrregular(state),
      betaDate: TtcTreatmentStore.instance.cycle.betaTest,
      firstCycle: cycle.cycleLengths.isEmpty,
    );
  }

  final DateTime today;
  final TimingOwnership ownership;
  final DateTime? lastStart;
  final int? usualLength;
  final bool irregular;
  final DateTime? betaDate;

  /// No completed cycle yet, so any due date is the first-cycle estimate
  /// (stated length, else 28 days) and the chat says it is early.
  final bool firstCycle;
}

/// The line every dated branch adds on a first cycle: the same "early
/// estimate" the home's confidence wording uses (`OvulationConfidence.low`).
const String kTtcFirstCycleEarlyLine =
    'This is an early estimate. It gets more accurate once your next period '
    'is logged.';

// ---- where the chips go ------------------------------------------------------
//  Lists, best first: see `ttcFirstOpenable`. The reads are being written in
//  parallel; each list ends on something that already ships.

const List<String> kTtcReadWhenToTest = [
  'ttc_read/ttc_read_when_to_test',
  'ttc_read/ttc_read_two_week_wait',
  'ttc_chapter',
];
const List<String> kTtcReadTwoWeekWait = [
  'ttc_read/ttc_read_two_week_wait',
  'ttc_chapter',
];
const List<String> kTtcReadHowToTest = [
  'ttc_read/ttc_read_how_to_test',
  'ttc_read/ttc_read_when_to_test',
];
const List<String> kTtcReadFaintLine = ['ttc_read/ttc_read_faint_line'];
const List<String> kTtcReadLateNegative = ['ttc_read/ttc_read_late_negative'];

/// The symptom logger, where the pregnancy test row lives.
const List<String> kTtcLogResult = ['ttc_symptom_log'];

class TtcShouldTestChat extends TtcChatScript {
  TtcShouldTestChat(
      {TtcShouldTestFacts? facts,
      this.recordPositive,
      bool? saveStatedLength})
      : facts = facts ?? TtcShouldTestFacts.fromStores(),
        // A test that hands in its own facts is describing a history the
        // stores do not hold, so its answers are not saved to them.
        saveStatedLength = saveStatedLength ?? facts == null;

  /// Whether a length she gives the chat is kept as her stated length.
  final bool saveStatedLength;

  final TtcShouldTestFacts facts;

  /// Records a positive test. `recordPositiveTest` by default, which asks
  /// before it changes anything. Swappable so a test can walk the branch.
  final Future<bool> Function(BuildContext context)? recordPositive;

  // What she told the chat, when the stores could not.
  DateTime? _pickedStart;
  int? _pickedLength;

  @override
  String get title => 'Should I test?';

  @override
  TtcChatStep start() => TtcChatStep(
        const ["Let's work out if a test will tell you anything yet."],
        [TtcChatChoice('Start', next: begin)],
      );

  /// The advice for what the chat knows right now.
  TtcTestAdvice get advice => ttcTestAdvice(
        ownership: facts.ownership,
        today: facts.today,
        lastStart: _pickedStart ?? facts.lastStart,
        cycleLength: _pickedLength ?? facts.usualLength,
        irregular: facts.irregular,
      );

  /// Step 2: read her dates, then branch.
  TtcChatStep begin() {
    final a = advice;
    return switch (a.branch) {
      TtcTestBranch.clinic => clinic(),
      TtcTestBranch.noDates => noDates(),
      TtcTestBranch.needCycleLength =>
        askLength(_pickedStart ?? facts.lastStart!),
      TtcTestBranch.early => early(a),
      TtcTestBranch.dueToday || TtcTestBranch.late => testNow(a),
    };
  }

  // ---- no dates ---------------------------------------------------------------

  TtcChatStep noDates() => TtcChatStep(
        const [
          "We don't have enough dates to say when your period is due.",
          'When did your last period start?',
        ],
        [
          TtcChatChoice('Pick the date', action: _pickStart),
          TtcChatChoice("I'm not sure", next: threeWeeks),
        ],
      );

  Future<TtcChatReply?> _pickStart(BuildContext context) async {
    final today = facts.today;
    // C4: the house date sheet (§4.0 addendum 3, "a date to set"), not the
    // Material dialog. Kept for revert:
    //   showDatePicker(context: context, initialDate: today,
    //       firstDate: today.subtract(const Duration(days: 120)),
    //       lastDate: today, helpText: 'First day of your last period');
    final picked = await showPvDateSheet(
      context,
      title: 'First day of your last period',
      initial: today,
      first: today.subtract(const Duration(days: 120)),
      last: today,
    );
    if (picked == null) return null;
    return TtcChatReply(ttcDayDate(picked), afterStart(picked));
  }

  /// She told us when her last period started.
  TtcChatStep afterStart(DateTime start) {
    _pickedStart = DateTime(start.year, start.month, start.day);
    if ((_pickedLength ?? facts.usualLength) != null) return begin();
    return askLength(_pickedStart!);
  }

  TtcChatStep askLength(DateTime start) => TtcChatStep(
        [
          'Your last period started on ${ttcDayDate(start)}.',
          'About how long are your cycles, from one period to the next?',
        ],
        [
          TtcChatChoice('About 21 to 25 days', next: () => withLength(23)),
          TtcChatChoice('About 26 to 30 days', next: () => withLength(28)),
          TtcChatChoice('About 31 to 35 days', next: () => withLength(33)),
          TtcChatChoice('They change a lot', next: threeWeeks),
          TtcChatChoice("I'm not sure", next: threeWeeks),
        ],
      );

  TtcChatStep withLength(int days) {
    _pickedLength = days;
    // Kept as her stated usual length (2026-09-26), so the first cycle she
    // logs is predicted from what she told us rather than from 28 days. The
    // engine reads it only until a cycle completes.
    if (saveStatedLength) TtcStore.instance.setStatedCycleLength(days);
    return begin();
  }

  /// When nobody knows the due date: the three-week rule.
  TtcChatStep threeWeeks() => TtcChatStep(
        const [
          "That's okay. When you don't know when your period is due, a test "
              'is reliable about three weeks after the last time you had sex '
              'without contraception.',
          "If that's today or earlier, you can test now.",
        ],
        [
          TtcChatChoice('How do I take it?', next: () => howTo(null)),
          const TtcChatChoice('Done', done: true),
        ],
      );

  // ---- a clinic owns the timing -------------------------------------------------

  TtcChatStep clinic() {
    final beta = facts.betaDate;
    return TtcChatStep(
      [
        'Your clinic will tell you when to test. A blood test (beta) on their '
            'date is the one to trust.',
        if (beta != null) 'Your clinic set your blood test for ${ttcDayDate(beta)}.',
        'A home test before then can mislead you. Some trigger shots contain '
            'the same hormone a home test looks for, and it can stay in your '
            'body for up to two weeks.',
      ],
      const [
        TtcChatChoice('See my clinic dates', open: ['ttc_treatment']),
        TtcChatChoice('Done', done: true),
      ],
    );
  }

  // ---- before the due date ------------------------------------------------------

  TtcChatStep early(TtcTestAdvice a) {
    final due = a.due!;
    return TtcChatStep(
      [
        if (a.rough) 'Your cycles vary, so this date is a rough guide.',
        if (facts.firstCycle) kTtcFirstCycleEarlyLine,
        'Your period is due on ${ttcDayDate(due)}. '
            "That's in ${ttcDays(a.daysUntil)}.",
        'A home test looks for hCG, a hormone your body starts making once a '
            'fertilised egg settles in the womb. Before your period is due, '
            "there often isn't enough of it to show.",
        "So a negative today doesn't tell you much. From ${ttcDayDate(due)}, "
            'a test gives you a clear answer.',
      ],
      [
        TtcChatChoice('Can a test show anything sooner?',
            next: () => earlyMore(a)),
        const TtcChatChoice('Read about the wait', open: kTtcReadTwoWeekWait),
        const TtcChatChoice('Done', done: true),
      ],
    );
  }

  TtcChatStep earlyMore(TtcTestAdvice a) => TtcChatStep(
        [
          'Some sensitive tests can pick up hCG a few days before a period is '
              'due. Many pregnancies still show negative that early, though.',
          "If you test early and it's negative, test again from "
              '${ttcShortDay(a.due!)}.',
        ],
        const [
          TtcChatChoice('Read: when to test', open: kTtcReadWhenToTest),
          TtcChatChoice('Done', done: true),
        ],
      );

  // ---- due today, or late ---------------------------------------------------------

  TtcChatStep testNow(TtcTestAdvice a) {
    final due = a.due!;
    return TtcChatStep(
      [
        if (a.rough) 'Your cycles vary, so this date is a rough guide.',
        if (facts.firstCycle) kTtcFirstCycleEarlyLine,
        if (a.branch == TtcTestBranch.dueToday)
          'Your period is due today.'
        else
          'Your period was due on ${ttcDayDate(due)}, '
              '${ttcDays(a.daysLate)} ago.',
        if (a.looksStale)
          "That's a while. If you've had a period since then, logging it "
              'keeps this right.',
        'A home test is reliable from today.',
      ],
      [
        TtcChatChoice('How do I take it?', next: () => howTo(a)),
        TtcChatChoice('I took one already', next: () => result(a)),
        if (a.looksStale)
          const TtcChatChoice('Log a period', open: ['ttc_cycle']),
        TtcChatChoice("I'll test later", next: later),
      ],
    );
  }

  TtcChatStep howTo(TtcTestAdvice? a) => TtcChatStep(
        const [
          'Use your first wee of the morning if you can. It has the most hCG '
              'in it.',
          'Follow the timing on the packet, and read the result within the '
              'time it gives.',
          'Any line in the result window counts, even a faint one, as long as '
              'it shows up in that time. A line that appears later than that '
              "doesn't count.",
        ],
        [
          TtcChatChoice("I've taken it", next: () => result(a)),
          const TtcChatChoice('Read: how to test', open: kTtcReadHowToTest),
          TtcChatChoice("I'll test later", next: later),
        ],
      );

  TtcChatStep result(TtcTestAdvice? a) => TtcChatStep(
        const ['What did it show?'],
        [
          TtcChatChoice('Positive', next: positive),
          TtcChatChoice('Negative', next: () => negative(a)),
          TtcChatChoice('A faint line', next: faint),
          TtcChatChoice("I'll test later", next: later),
        ],
      );

  TtcChatStep positive() => TtcChatStep(
        const [
          "That's big news, and it's okay to feel lots of things at once.",
          'A doctor can confirm it with a blood test or a scan, and start your '
              "care. There's no rush today.",
          'If you have strong pain low in your belly, especially on one side, '
              'or heavy bleeding, see a doctor straight away.',
        ],
        [
          TtcChatChoice('Record my positive test', action: _recordPositive),
          const TtcChatChoice('Log it for today', open: kTtcLogResult),
          const TtcChatChoice('Done', done: true),
        ],
      );

  Future<TtcChatReply?> _recordPositive(BuildContext context) async {
    // It asks before it changes anything, and it moves her to the pregnancy
    // hand-off. Nothing to say after it: the transition screen speaks.
    await (recordPositive ?? recordPositiveTest)(context);
    return null;
  }

  TtcChatStep negative(TtcTestAdvice? a) {
    final early = a == null ||
        a.branch == TtcTestBranch.dueToday ||
        (a.branch == TtcTestBranch.late && a.daysLate < 3);
    return TtcChatStep(
      [
        if (early)
          'A test on the day your period is due can still miss an early '
              "pregnancy. If your period hasn't come in three days, test "
              'again.'
        else
          "If your period still hasn't come, test again in three days.",
        "If you've had two negative tests and your period is a week late or "
            'more, book a visit with your doctor. Cycles can shift for lots '
            'of reasons, like stress, illness or travel, and your doctor can '
            'help find out why.',
      ],
      const [
        TtcChatChoice('Log the result', open: kTtcLogResult),
        TtcChatChoice('Read: late and negative', open: kTtcReadLateNegative),
        TtcChatChoice('Done', done: true),
      ],
    );
  }

  TtcChatStep faint() => TtcChatStep(
        const [
          'A faint line that shows up within the reading time usually means '
              "the test picked up hCG. It's often just early, when there's "
              'only a little of it.',
          'Test again in two days with your first morning wee. The line is '
              'usually clearer by then.',
          "Either way, it's a good time to see your doctor, who can check "
              'with a blood test.',
        ],
        const [
          TtcChatChoice('Read: faint lines', open: kTtcReadFaintLine),
          TtcChatChoice('Log the result', open: kTtcLogResult),
          TtcChatChoice('Done', done: true),
        ],
      );

  TtcChatStep later() => const TtcChatStep(
        [
          "That's fine. A test will be just as reliable whenever you're "
              'ready.',
          'You can come back to this chat any time.',
        ],
        [TtcChatChoice('Done', done: true)],
      );
}

/// The screen, for the router.
class TtcShouldTestChatScreen extends StatelessWidget {
  const TtcShouldTestChatScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      TtcChatScreen(script: TtcShouldTestChat());
}
