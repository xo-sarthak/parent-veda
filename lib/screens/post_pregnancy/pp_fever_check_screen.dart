// =============================================================================
//  PpFeverCheckScreen — his age, his temperature, and a straight answer
// -----------------------------------------------------------------------------
//  The Health section promises exactly this, three times over:
//
//    "His age and his temperature, and a straight answer: see a doctor now, or
//     watch him at home. Ten seconds."
//
//  ⚠️ THIS IS THE ONE TOOL IN THE APP THAT GIVES A DIRECTIVE ANSWER, and it is
//  worth being explicit about why that is allowed here when it is refused
//  everywhere else.
//
//  Every other check in this app deliberately withholds a verdict: the newborn
//  quick check answers per item and never totals, the sleep check gives a range
//  and no judgement. Those refusals are right because the questions are
//  genuinely uncertain and a verdict would be false precision.
//
//  Fever in a small baby is not that kind of question. **Under three months, a
//  temperature of 38 C is a same-day medical problem regardless of how well the
//  baby looks**, and that rule is not a matter of degree, interpretation or
//  parental judgement. A tool that answered "here are some things to consider"
//  would be hedging on the one question where hedging costs the most.
//
//  So it answers. And the answer only ever escalates:
//
//    * It can say GO NOW. It can say SEE SOMEONE TODAY.
//    * It can say WATCH HIM AT HOME -- and even then it lists what would change
//      that, and repeats that her own judgement outranks the tool.
//    * It NEVER says "he is fine". Nothing here has examined the baby.
//
//  ⚠️ THE RED-FLAG QUESTION COMES BEFORE THE THERMOMETER, and that ordering is
//  the most important line in the file. A baby who is grunting, floppy, or has a
//  rash that does not fade under a glass needs to be seen at ANY temperature,
//  including a normal one. Asking for the number first would let a reassuring
//  reading answer a question the number cannot answer.
//
//  ⚠️ NOTHING IS SAVED, and there is no history. A record of past fevers invites
//  comparison, and comparison is not how this decision is made.
//
//  ⚠️ EVERY THRESHOLD IS REQUIRED_REVIEW. A paediatrician signs these off before
//  this ships. A wrong cutoff here is the most consequential single number in the
//  product.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_age_bands.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';

/// How urgent the answer is. Ordered, so the worst answer always wins.
enum _Urgency { now, today, home }

class _Answer {
  const _Answer(this.urgency, this.headline, this.body, this.then);
  final _Urgency urgency;
  final String headline;
  final String body;

  /// What would change the answer. Present on every outcome, including the
  /// calmest one.
  final List<String> then;
}

// REQUIRED_REVIEW: every age cutoff and every temperature below.
//
// The three age groups are not arbitrary. Under 3 months a baby cannot mount a
// useful immune response and cannot show the signs older children show, which is
// why the rule is the temperature alone. From 3 to 6 months the threshold rises
// but the margin is still thin. Past 6 months, how he SEEMS matters more than
// what the thermometer says.
const double _feverC = 38.0; // REQUIRED_REVIEW: 100.4 F
const double _highC = 39.0; // REQUIRED_REVIEW: 102.2 F

/// The red flags that outrank the thermometer entirely.
// REQUIRED_REVIEW: this list, and whether anything is missing from it.
const List<String> _redFlags = [
  'Breathing hard: ribs sucking in, nostrils flaring, or grunting',
  'A rash that does not fade when you press a glass on it',
  'A fit or seizure',
  'Floppy, or very hard to wake',
  'No urine for 12 hours, or no tears when crying',
  'A bulging or sunken soft spot',
  'Cold, mottled or blue hands and feet',
  'Constant crying you cannot settle at all',
];

class PpFeverCheckScreen extends StatefulWidget {
  const PpFeverCheckScreen({super.key});

  @override
  State<PpFeverCheckScreen> createState() => _PpFeverCheckScreenState();
}

class _PpFeverCheckScreenState extends State<PpFeverCheckScreen> {
  /// Prefilled from the child's real age, because the app already knows it and
  /// the repo's rule is derive, never ask. She can change it: a grandmother may
  /// be using this for a different child.
  late int _months = ppMonthsSinceBirth;

  /// null until she answers. Deliberately three-state: an unanswered red-flag
  /// question must not default to "no".
  bool? _anyRedFlag;

  double? _temp;

  _Answer? get _answer {
    // ⚠️ RED FLAGS FIRST, AND THEY SHORT-CIRCUIT THE TEMPERATURE ENTIRELY.
    if (_anyRedFlag == true) {
      return const _Answer(
        _Urgency.now,
        'Go now',
        'What you have described needs to be seen straight away, whatever the '
            'thermometer says. Take him to the nearest hospital emergency, or '
            'call 112.',
        [
          'Do not wait to see if it settles.',
          'Do not give paracetamol instead of going.',
          'Take any medicines he is on with you.',
        ],
      );
    }
    if (_anyRedFlag == null || _temp == null) return null;

    final t = _temp!;

    // ⚠️ UNDER 3 MONTHS: THE TEMPERATURE ALONE DECIDES.
    // REQUIRED_REVIEW: this is the single most important rule in the screen.
    if (_months < 3) {
      if (t >= _feverC) {
        return const _Answer(
          _Urgency.now,
          'He needs to be seen today',
          'A temperature of 38 C or above in a baby under three months is '
              'always a reason to be seen the same day, even if he seems '
              'perfectly well otherwise. This is not us being cautious. It is '
              'the rule doctors use.',
          [
            'Go to a paediatrician or a hospital today, not tomorrow.',
            'Do not give paracetamol before he is examined unless a doctor '
                'tells you to. It can mask what they need to see.',
            'Say his age in days when you call.',
          ],
        );
      }
      // REQUIRED_REVIEW: low temperature in a newborn as a red flag.
      if (t < 36.5) {
        return const _Answer(
          _Urgency.now,
          'He needs to be seen today',
          'A temperature below 36.5 C in a baby under three months matters as '
              'much as a high one. Small babies go cold when they are unwell '
              'rather than hot.',
          [
            'Warm him with skin to skin and a blanket on the way.',
            'Go to a paediatrician or a hospital today.',
          ],
        );
      }
      return const _Answer(
        _Urgency.home,
        'No fever on that reading',
        'That is a normal temperature. If he still seems wrong to you, that is '
            'reason enough to have him seen. Nothing here has examined him.',
        [
          'Take it again if he seems worse.',
          'At this age, call about anything that worries you. Nobody will mind.',
        ],
      );
    }

    if (t < _feverC) {
      return const _Answer(
        _Urgency.home,
        'That is not a fever',
        'Below 38 C is not a fever. Being wrapped up, just fed, or just woken '
            'can lift a reading by half a degree, so unwrap him, wait fifteen '
            'minutes and take it again before acting on a borderline number.',
        [
          'Come back if it climbs above 38 C.',
          'If he seems unwell with a normal temperature, that still counts. '
              'Trust it.',
        ],
      );
    }

    // REQUIRED_REVIEW: 3 to 6 months at any fever = same-day review.
    if (_months < 6) {
      return const _Answer(
        _Urgency.today,
        'Get him seen today',
        'Between three and six months, a fever is worth a doctor looking at him '
            'the same day rather than waiting it out.',
        [
          'Keep offering feeds, more often and smaller.',
          'Ask about paracetamol rather than guessing the dose.',
          'Go sooner if anything on the first list appears.',
        ],
      );
    }

    if (t >= _highC) {
      return const _Answer(
        _Urgency.today,
        'Worth a doctor today',
        'A high temperature on its own is not dangerous, and how he SEEMS '
            'matters more than the number. But at this height it is worth '
            'someone looking at him today rather than tonight.',
        [
          'Fluids matter more than bringing the number down.',
          'Paracetamol is for making him comfortable, not for chasing a number.',
          'Go straight away if anything on the first list appears.',
        ],
      );
    }

    return const _Answer(
      _Urgency.home,
      'You can watch him at home',
      'At this age a fever is usually a virus doing its job, and it will often '
          'run three days. Fluids, rest, and something for comfort if he is '
          'miserable.',
      [
        'Come back to a doctor if it is still there on day five.',
        'Go sooner if he stops drinking, has far fewer wet nappies, or if '
            'anything on the first list appears.',
        'And go if he simply seems wrong to you. That outranks this screen.',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final a = _answer;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 44),
          children: [
            ppV3Back(context, p),
            const SizedBox(height: 16),
            Text('Fever check', style: pvFraunces(fontSize: 27, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
            const SizedBox(height: 9),
            Text(
                'His age and his temperature. Nothing is saved, and this does '
                'not replace a doctor looking at him.',
                style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),

            // ---- 1. RED FLAGS, BEFORE THE THERMOMETER --------------------
            const SizedBox(height: 26),
            Text('First: is any of this happening?',
                style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
            const SizedBox(height: 8),
            Text(
                'These need a doctor at any temperature, including a normal '
                'one.',
                style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.line),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final f in _redFlags) ...[
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(Icons.circle,
                                  size: 5, color: ppAlertInk(p)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(f,
                                  style:
                                      pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink1)),
                            ),
                          ]),
                      const SizedBox(height: 9),
                    ],
                  ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _Choice(
                  label: 'None of these',
                  selected: _anyRedFlag == false,
                  concern: false,
                  onTap: () => setState(() => _anyRedFlag = false),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _Choice(
                  label: 'Yes, one of these',
                  selected: _anyRedFlag == true,
                  concern: true,
                  onTap: () => setState(() => _anyRedFlag = true),
                ),
              ),
            ]),

            // Everything below is irrelevant once a red flag is present, so it
            // is not shown. Asking for a temperature after "go now" invites her
            // to keep answering questions instead of leaving.
            if (_anyRedFlag == false) ...[
              const SizedBox(height: 30),
              Text('How old is he?', style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
              const SizedBox(height: 10),
              Row(children: [
                for (final (label, m) in const [
                  ('Under 3 months', 1),
                  ('3 to 6 months', 4),
                  ('Over 6 months', 12),
                ]) ...[
                  Expanded(
                    child: _Choice(
                      label: label,
                      selected: _bandOf(_months) == _bandOf(m),
                      concern: false,
                      onTap: () => setState(() => _months = m),
                    ),
                  ),
                  if (label != 'Over 6 months') const SizedBox(width: 7),
                ],
              ]),

              const SizedBox(height: 26),
              Text('What did the thermometer say?',
                  style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
              const SizedBox(height: 8),
              Text(
                  'Under the arm is fine. Unwrap him and wait fifteen minutes '
                  'after a bath or a feed before you take it.',
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
              const SizedBox(height: 12),
              for (final (label, c) in const [
                ('Below 38 C  (below 100.4 F)', 37.2),
                ('38 to 39 C  (100.4 to 102.2 F)', 38.4),
                ('Above 39 C  (above 102.2 F)', 39.4),
                ('Below 36.5 C  (below 97.7 F)', 36.0),
              ]) ...[
                _Choice(
                  label: label,
                  selected: _temp == c,
                  concern: false,
                  wide: true,
                  onTap: () => setState(() => _temp = c),
                ),
                const SizedBox(height: 8),
              ],
            ],

            if (a != null) ...[
              const SizedBox(height: 28),
              _AnswerCard(answer: a),
            ],

            const SizedBox(height: 22),
            Text(
                'If he seems wrong to you and this screen says otherwise, '
                'believe yourself. You know him and this does not.',
                style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.6, color: p.ink3)),
          ],
        ),
      ),
    );
  }

  /// Which of the three age rules applies. Kept as a helper so the chips
  /// highlight correctly whatever exact month the profile supplies.
  int _bandOf(int months) => months < 3
      ? 0
      : months < 6
          ? 1
          : 2;
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer});
  final _Answer answer;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final urgent = answer.urgency != _Urgency.home;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: urgent ? ppAlertTint(p) : p.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: urgent ? ppAlertInk(p).withValues(alpha: 0.5) : p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(
              urgent
                  ? Icons.medical_services_outlined
                  : Icons.home_outlined,
              size: 19,
              color: urgent ? ppAlertInk(p) : p.action),
          const SizedBox(width: 10),
          Expanded(
            child: Text(answer.headline,
                style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(answer.body, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w500, height: 1.65, color: p.ink1)),
        const SizedBox(height: 14),
        // ⚠️ PRESENT ON EVERY OUTCOME, including "watch him at home". An answer
        // that stops at "you can wait" has told her nothing about when to stop
        // waiting, which is the part she will actually need at 2am.
        Text('What would change this',
            style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, height: 1.55, color: p.ink2)
                .copyWith(letterSpacing: 0.7)),
        const SizedBox(height: 8),
        for (final t in answer.then) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(Icons.circle, size: 4, color: p.ink3),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(t, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink1)),
            ),
          ]),
          const SizedBox(height: 7),
        ],
      ]),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.concern,
    required this.onTap,
    this.wide = false,
  });

  final String label;
  final bool selected;
  final bool concern;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: wide ? double.infinity : null,
          alignment: wide ? Alignment.centerLeft : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (concern ? ppAlertTint(p) : p.surfaceAlt)
                : p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected
                    ? (concern ? ppAlertInk(p) : p.action)
                    : p.line,
                width: selected ? 1.4 : 1),
          ),
          child: Text(label,
              textAlign: wide ? TextAlign.start : TextAlign.center,
              style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4, color: p.ink1)),
        ),
      );
}
