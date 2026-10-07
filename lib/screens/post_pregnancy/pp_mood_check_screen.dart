// =============================================================================
//  You, Maa — a two-question check-in for her own mood (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P2 (You, Maa door): "Add a two-question check-in (low mood,
//  loss of interest) with the crisis path pinned, never a score."
//
//  ⚠️ DISAGREEMENT, LOGGED: the door's earlier brief said "no tools, no scored
//  mood tracker; the triage is the front door". The gap analysis wins (the
//  user's rule), and keeps that brief's spirit: there is NO score, NOTHING is
//  saved, and the triage keeps its place pinned above the door's rails.
//
//  THE TWO QUESTIONS are the standard two-question screen for low mood used by
//  midwives and GPs (the Whooley questions), in plain words.
//  REQUIRED_REVIEW (perinatal counsellor): the wording of both questions and
//  of each answer.
//
//  WHAT IT DOES WITH THE ANSWERS: one "yes" is enough to say "talk to your
//  doctor, you do not have to wait". It never names a condition and never
//  shows a number. The crisis path (Tele-MANAS 14416, 112) is pinned at the
//  top whatever she answers, because the frightening thoughts are not one of
//  the two questions and must never wait behind them.
//
//  NOTHING IS STORED, on purpose: no local row, no cloud row. A mood answer is
//  the most private thing in the app, and a record of it helps no one here.
//
//  Mobbin: the question large, two full-width answer cards with a line under
//  each, after Fresha (mobbin.com/screens/b7008fdd-a89a-4c70-9abe-1815b7dda8bf)
//  and Ro (mobbin.com/screens/8805b5d2-91aa-4032-93fb-4631e6f0c324).
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../mind_mood/mm_crisis_path.dart' show MmCrisisPathScreen;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvSecondary, kPvInk, pvStorePalette;

const List<(String, String)> kPpMoodQuestions = [
  ('Over the last two weeks, have you often felt down, low or hopeless?',
      'Most days, for much of the day.'),
  ('Over the last two weeks, have you often had little interest or joy in things you usually enjoy?',
      'Things that used to lift you, and now do not.'),
];

/// What one or more "yes" means. Never a condition, never a number.
const String kPpMoodTalkLine =
    'Thank you for being honest. It is worth talking to your doctor about how you have been feeling. '
    'You do not have to wait for your next check-up, and you do not have to be sure first. '
    'This is common after a baby, and it gets better with help.';

const String kPpMoodOkLine =
    'Thank you for checking in. If that changes, even a little, come back any time. '
    'Rest and help with the baby matter for you too.';

class PpMoodCheckScreen extends StatefulWidget {
  const PpMoodCheckScreen({super.key});

  @override
  State<PpMoodCheckScreen> createState() => _PpMoodCheckScreenState();
}

class _PpMoodCheckScreenState extends State<PpMoodCheckScreen> {
  final List<bool?> _answers = List<bool?>.filled(kPpMoodQuestions.length, null);

  bool get _done => !_answers.contains(null);
  bool get _anyYes => _answers.contains(true);

  void _crisis() => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'mind/crisis'),
        builder: (_) => const MmCrisisPathScreen(),
      ));

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: 288,
      eyebrow: 'You, the mother', // was 'You, Maa' (English only, 2026-10-07)
      mark: IntentMark.moodArc,
      title: 'How have you been?',
      intro: 'Two questions about the last two weeks. No score, and nothing is saved.',
      children: [
        // ---- pinned: the crisis path, whatever she answers ----
        pregToolPad(Material(
          key: const ValueKey('pp_mood_crisis'),
          color: const Color(0xFFFFF1F0),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _crisis,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.call_outlined, size: 20, color: p.ink1),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'If you have thoughts of harming yourself or your baby, call Tele-MANAS on 14416, '
                    'free, day and night, or 112. Tap here for the numbers.',
                    style: pvManrope(fontSize: 13.5, height: 1.5, fontWeight: FontWeight.w600, color: p.ink1),
                  ),
                ),
              ]),
            ),
          ),
        )),
        const SizedBox(height: 22),
        for (var i = 0; i < kPpMoodQuestions.length; i++) ...[
          pregToolPad(Text(kPpMoodQuestions[i].$1,
              style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3, color: p.ink1))),
          const SizedBox(height: 4),
          pregToolPad(Text(kPpMoodQuestions[i].$2, style: pvManrope(fontSize: 13, color: p.ink3))),
          const SizedBox(height: 10),
          pregToolPad(_answer(i, true, 'Yes', 'More often than not')),
          const SizedBox(height: 8),
          pregToolPad(_answer(i, false, 'No', 'Not really')),
          const SizedBox(height: 22),
        ],
        if (_done) ...[
          pregToolPad(Container(
            key: ValueKey(_anyYes ? 'pp_mood_talk' : 'pp_mood_ok'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: Text(_anyYes ? kPpMoodTalkLine : kPpMoodOkLine,
                style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1)),
          )),
          const SizedBox(height: 14),
          pregToolPad(PvSecondary(
            label: 'Start again',
            onTap: () => setState(() => _answers.fillRange(0, _answers.length, null)),
          )),
        ],
      ],
    );
  }

  Widget _answer(int q, bool value, String title, String line) {
    final p = pvStorePalette;
    final on = _answers[q] == value;
    return Material(
      key: ValueKey('pp_mood_q${q}_${value ? 'yes' : 'no'}'),
      color: on ? kPvInk : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: on ? kPvInk : p.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _answers[q] = value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: on ? Colors.white : p.ink1)),
            const SizedBox(height: 2),
            Text(line, style: pvManrope(fontSize: 12.5, color: on ? Colors.white70 : p.ink3)),
          ]),
        ),
      ),
    );
  }
}
