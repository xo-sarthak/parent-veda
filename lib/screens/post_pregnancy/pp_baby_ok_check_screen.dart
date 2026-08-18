// =============================================================================
//  PpBabyOkCheckScreen — "is my baby OK?", in four checks
// -----------------------------------------------------------------------------
//  ⚠️ THE FIRST 40 DAYS SECTION PROMISED THIS THREE TIMES BEFORE IT EXISTED:
//  a tool tile and two in-page links, all tappable, all leading nowhere. Found
//  by the link resolver in `test/pp_sleep_check_test.dart`.
//
//  Its promise, from the section's own copy, is the specification:
//
//    "Four things in thirty seconds. Nothing to log, no streaks."
//    "Wet nappies, weight, jaundice and feeds."
//    "Tap through the four checks and see whether anything needs a call."
//
//  ⚠️ IT ANSWERS PER CHECK AND NEVER TOTALS THEM.
//
//  This is the whole design and it is worth defending, because the obvious build
//  is a four-question quiz with a verdict at the end. That version would be
//  worse in both directions at once:
//
//  * A green "all fine" is a reassurance nobody can give from four taps, and its
//    failure mode is a mother who was right to worry deciding not to call.
//  * A red "see a doctor" from a summed score is a diagnosis by arithmetic, on
//    the most frightened reader in the app.
//
//  So each check resolves ON ITS OWN, immediately, into one of two honest
//  answers: "that is what we expect" or "that one is worth a call". A single
//  check can send her to a doctor without the other three arguing her out of it,
//  which is exactly how newborn red flags actually work: not enough wet nappies
//  matters whether or not feeding looks fine.
//
//  ⚠️ NOTHING IS SAVED. No history, no streak, no "you last checked 2 days ago".
//  The spec says "nothing to log" and the reason is that a daily newborn checklist
//  with a memory becomes a chore she is failing at, in the fortnight she has least
//  to spare.
//
//  ⚠️ EVERY THRESHOLD IS MARKED REQUIRED_REVIEW. Nappy counts, feed intervals and
//  the jaundice rule are the load-bearing numbers in this screen and a
//  paediatrician must sign them off before it ships.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';

/// One check: a question, the answers, and what each answer means.
class _Check {
  const _Check({
    required this.id,
    required this.title,
    required this.question,
    required this.note,
    required this.expected,
    required this.expectedMeans,
    required this.concern,
    required this.concernMeans,
  });

  final String id;
  final String title;
  final String question;

  /// The context she needs before answering. Without it the question is a trap:
  /// "enough wet nappies" means nothing if you do not know what enough is.
  final String note;

  final String expected;
  final String expectedMeans;
  final String concern;

  /// ⚠️ ALWAYS NAMES WHO TO CALL. A concern that names a symptom and stops has
  /// made the fear and given it nowhere to go.
  final String concernMeans;
}

// REQUIRED_REVIEW: every number and threshold in this list.
const List<_Check> _checks = [
  _Check(
    id: 'nappies',
    title: 'Wet nappies',
    // REQUIRED_REVIEW: six heavy wet nappies a day from about day five.
    question: 'How many properly wet nappies in the last 24 hours?',
    note: 'From about day five, expect six or more heavy wet nappies a day. '
        'Before that it climbs day by day, roughly one on day one, two on day '
        'two, and so on.',
    expected: 'Six or more',
    expectedMeans: 'That is the single most useful sign that he is getting '
        'enough milk. Nothing else on this list matters as much.',
    concern: 'Fewer than six, or hard to tell',
    concernMeans: 'Call your paediatrician today. It usually means feeding '
        'needs adjusting rather than anything being wrong with him, and it is '
        'much easier to fix early.',
  ),
  _Check(
    id: 'feeds',
    title: 'Feeds',
    // REQUIRED_REVIEW: 8 to 12 feeds in 24 hours; wake by 3h day / 4h night in
    // the first fortnight.
    question: 'Roughly how often is he feeding?',
    note: 'Eight to twelve times in 24 hours is normal, and it will not be '
        'evenly spaced. In the first two weeks do not let him go more than '
        'three hours in the day or four at night without a feed, even if that '
        'means waking him.',
    expected: 'Eight or more times, and he wakes for them',
    expectedMeans: 'That is what a newborn does. Cluster feeding in the '
        'evening is normal and is not a sign your milk is short.',
    concern: 'Fewer than eight, or too sleepy to wake for feeds',
    concernMeans: 'Call your paediatrician today. A newborn who is too sleepy '
        'to feed is a reason to be seen, not a good sleeper.',
  ),
  _Check(
    id: 'jaundice',
    title: 'Yellowness',
    // REQUIRED_REVIEW: face-only usually mild; below the chest, or palms and
    // soles, or before 24h, or after two weeks = same-day review.
    question: 'Where can you see yellow on him?',
    note: 'Look in daylight, near a window, with his clothes off. Press gently '
        'on the skin and look at the colour as you lift your finger. Yellow on '
        'the face only is usually mild.',
    expected: 'Face only, or none at all',
    expectedMeans: 'Common in the first week and usually settles on its own. '
        'Keep feeding often, which is what clears it.',
    concern: 'On the chest or lower, on the palms or soles, in the first 24 '
        'hours, or still there after two weeks',
    concernMeans: 'Get him seen today, not tomorrow. Any of those needs a '
        'proper look and a blood level rather than a judgement by eye.',
  ),
  _Check(
    id: 'weight',
    title: 'Weight',
    // REQUIRED_REVIEW: up to ~10% loss normal, back to birth weight by ~2 weeks.
    question: 'What did the last weighing say?',
    note: 'Losing weight in the first days is normal, up to about a tenth of '
        'his birth weight. He should be back to his birth weight by around two '
        'weeks.',
    expected: 'Gaining, or back to birth weight by two weeks',
    expectedMeans: 'That is the answer everything else is trying to predict. '
        'If the weight is going the right way, he is getting enough.',
    concern: 'Still below birth weight after two weeks, or lost more than a '
        'tenth',
    concernMeans: 'Call your paediatrician. This is the one worth acting on '
        'even when everything else looks fine.',
  ),
];

class PpBabyOkCheckScreen extends StatefulWidget {
  const PpBabyOkCheckScreen({super.key});

  @override
  State<PpBabyOkCheckScreen> createState() => _PpBabyOkCheckScreenState();
}

class _PpBabyOkCheckScreenState extends State<PpBabyOkCheckScreen> {
  /// checkId -> true when she picked the expected answer, false when concern.
  ///
  /// ⚠️ IN MEMORY ONLY. It is deliberately not a store: nothing here survives
  /// leaving the screen. See the header.
  final Map<String, bool> _answers = {};

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 44),
          children: [
            ppV3Back(context, p),
            const SizedBox(height: 16),
            Text('Is my baby OK?', style: pvFraunces(fontSize: 27, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
            const SizedBox(height: 9),
            Text(
                'Four things, thirty seconds. Nothing is saved and nothing is '
                'scored.',
                style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),
            const SizedBox(height: 24),
            for (final c in _checks) ...[
              _CheckCard(
                check: c,
                answer: _answers[c.id],
                onAnswer: (ok) => setState(() => _answers[c.id] = ok),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            // ⚠️ THE LINE THAT REPLACES A SUMMARY VERDICT. Everything above
            // answers for itself; this says the one thing a total would have
            // said wrong.
            Container(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 16),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.line),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('None of this replaces your own feeling',
                        style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.55, color: p.ink1)),
                    const SizedBox(height: 6),
                    Text(
                        'If all four look fine and he still seems wrong to you, '
                        'that is reason enough to have him seen. You do not '
                        'need a number to be allowed to worry.',
                        style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1)),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard(
      {required this.check, required this.answer, required this.onAnswer});

  final _Check check;

  /// null until answered.
  final bool? answer;
  final void Function(bool expected) onAnswer;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final answered = answer != null;
    final concern = answer == false;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: concern ? ppAlertInk(p) : p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(check.title, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
        const SizedBox(height: 6),
        Text(check.question, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w500, height: 1.55, color: p.ink1)),
        const SizedBox(height: 8),
        // The context comes BEFORE the buttons, because a question she cannot
        // answer accurately is worse than no question.
        Text(check.note, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
        const SizedBox(height: 14),
        _Option(
          label: check.expected,
          selected: answer == true,
          concern: false,
          onTap: () => onAnswer(true),
        ),
        const SizedBox(height: 8),
        _Option(
          label: check.concern,
          selected: answer == false,
          concern: true,
          onTap: () => onAnswer(false),
        ),
        if (answered) ...[
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
            decoration: BoxDecoration(
              color: concern ? ppAlertTint(p) : p.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(
                  concern
                      ? Icons.medical_services_outlined
                      : Icons.check_circle_outline_rounded,
                  size: 17,
                  color: concern ? ppAlertInk(p) : p.action),
              const SizedBox(width: 10),
              Expanded(
                child: Text(concern ? check.concernMeans : check.expectedMeans,
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1)),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option(
      {required this.label,
      required this.selected,
      required this.concern,
      required this.onTap});

  final String label;
  final bool selected;
  final bool concern;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    // ⚠️ THE CONCERN OPTION IS NOT RED UNTIL IT IS CHOSEN. Colouring it in
    // advance makes one answer look like the wrong answer, which pushes an
    // anxious reader toward the other one. That is the opposite of what a
    // triage tool needs.
    final edge = selected ? (concern ? ppAlertInk(p) : p.action) : p.line;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
        decoration: BoxDecoration(
          color: selected
              ? (concern ? ppAlertTint(p) : p.surfaceAlt)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: edge, width: selected ? 1.4 : 1),
        ),
        child: Row(children: [
          Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 17,
              color: selected ? (concern ? ppAlertInk(p) : p.action) : p.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.5, color: p.ink1)),
          ),
        ]),
      ),
    );
  }
}
