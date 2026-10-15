// =============================================================================
//  DevelopmentCheckinScreen - a gentle check-in that knows when to say "ask"
// -----------------------------------------------------------------------------
//  Redrawn 2026-10-07 for the parenting gap pass, on the shared tool shell
//  (`PregToolScaffold`), and given what the gap analysis found missing (P1,
//  Behind · Health & safety): "Our check-in gives six 'not yet's at 20 months
//  the same 'these can bloom any week now' as one." Now:
//
//    * a few questions for THIS child's age (derived, never asked), each with
//      Yes / Not yet, filled with the child's name or he/she (`ppFillChild`);
//    * every band ends with "has a skill been lost?";
//    * the reflection follows the answers: all yes is a warm line; a few "not
//      yet"s is reassurance plus "keep offering chances"; ANY "act early" sign
//      not yet, a lost skill, or three or more "not yet"s says, calmly: "It is
//      worth asking your paediatrician about this at your next visit, or sooner
//      if you are worried. Early help works best." (`checkInWorthAsking`).
//    * never a score, never a comparison, never a diagnosis.
//
//  Mobbin: Noom's chip answers https://mobbin.com/screens/f5f057c4-65ea-454e-9f3a-bb22ad6926af
//  (two plain choices per row) and the TTC self-checks' result card (one
//  sentence, one action), so the three stages' checks read alike.
//  The previous screen is `DevelopmentCheckinClassic` below, kept for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvChip;
import '../v2/v2_palette.dart';
import '../../theme/pv_fonts.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'pp_phases_data.dart' show ppFillChild;
import 'pp_search.dart' show openPpAskVeda;
import '../../widgets/pv_feedback.dart' show PvPress;

/// The line the gap analysis asked for, word for word.
const String kCheckInWorthAskingLine = 'It is worth asking your paediatrician about this at your next visit, '
    'or sooner if you are worried. Early help works best.';

class DevelopmentCheckinScreen extends StatelessWidget {
  const DevelopmentCheckinScreen({super.key});

  DevStore get _s => DevStore.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_s, ChildProfileStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final c = ChildProfileStore.instance;
        final questions = checkInsForAge(c.ageInMonths);
        final answered = questions.where((q) => _s.checkInAnswer(q.text) != null).length;
        final allDone = answered == questions.length;
        return PregToolScaffold(
          hue: 28,
          eyebrow: 'Development',
          mark: IntentMark.stepsMark,
          title: 'A gentle check-in',
          intro: 'A few questions for ${c.nameMid}\'s age. No scores and no comparing: just a clearer picture.',
          children: [
            // How far through, as Hers and Liven show it (Mobbin audit,
            // 2026-10-07; mobbin.com/screens/36a95b41-2c68-44be-942f-9249916a4699,
            // mobbin.com/screens/529b0ea8-3610-4a28-93d6-13231f1aaad8). Progress
            // through the questions, never a score.
            pregToolPad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$answered of ${questions.length} answered',
                  key: const ValueKey('pp_checkin_progress'),
                  style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: questions.isEmpty ? 0 : answered / questions.length,
                  minHeight: 5,
                  backgroundColor: p.line,
                  valueColor: AlwaysStoppedAnimation<Color>(p.ink1),
                ),
              ),
            ])),
            const SizedBox(height: 18),
            for (final (i, q) in questions.indexed)
              pregToolPad(_Question(q: q, index: i, p: p)),
            const SizedBox(height: 6),
            if (allDone)
              pregToolPad(_Reflection(questions: questions, p: p))
            else
              pregToolPad(Text(
                '${questions.length - answered} to go. Answer however feels true today.',
                style: pvManrope(fontSize: 13, color: p.ink2),
              )),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.q, required this.index, required this.p});
  final CheckInQ q;
  final int index;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final s = DevStore.instance;
    final a = s.checkInAnswer(q.text);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ppFillChild(q.text),
            style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, height: 1.4, color: p.ink1)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          KeyedSubtree(
            key: ValueKey('checkin_${index}_yes'),
            child: PvChip(label: 'Yes', selected: a == true, onTap: () => s.setCheckIn(q.text, true)),
          ),
          KeyedSubtree(
            key: ValueKey('checkin_${index}_no'),
            child: PvChip(label: q.yesIsConcern ? 'No' : 'Not yet', selected: a == false, onTap: () => s.setCheckIn(q.text, false)),
          ),
        ]),
      ]),
    );
  }
}

class _Reflection extends StatelessWidget {
  const _Reflection({required this.questions, required this.p});
  final List<CheckInQ> questions;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final s = DevStore.instance;
    final c = ChildProfileStore.instance;
    final ask = checkInWorthAsking(questions, s.checkInAnswer);
    final notYet = questions.where((q) {
      final a = s.checkInAnswer(q.text);
      return q.yesIsConcern ? a == true : a == false;
    }).length;
    final line = ask
        ? kCheckInWorthAskingLine
        : notYet == 0
            ? '${c.name} is doing so much of what we would expect right now. '
                'Keep offering the everyday play and closeness; it is doing its job.'
            : 'A "not yet" or two is common at every age. Children grow in bursts and in their own order. '
                'Keep offering chances to practise, and check in again in a few weeks.';
    return Container(
      key: ValueKey(ask ? 'checkin_result_ask' : 'checkin_result_ok'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ask ? p.ink1 : p.line, width: ask ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(ask ? Icons.local_hospital_outlined : Icons.favorite_border_rounded, size: 20, color: p.ink1),
          const SizedBox(width: 8),
          Expanded(
            child: Text(ask ? 'Worth a word with your doctor' : 'What this tells us',
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(line, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1)),
        if (ask) ...[
          const SizedBox(height: 8),
          Text('This is not a diagnosis. Many children who start late catch up, and when help is needed, '
              'starting early makes it easier.',
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
        ],
        const SizedBox(height: 10),
        TextButton(
          key: const ValueKey('checkin_ask_veda'),
          style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: p.ink1),
          onPressed: () => openPpAskVeda(context, 'What should I ask the paediatrician about my child\'s development?'),
          child: Text('Questions to take to the visit  →',
              style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
        ),
      ]),
    );
  }
}

// =============================================================================
//  Kept for revert: the 2026-08 screen.
// =============================================================================

/// The 2026-08 check-in, kept for revert. Unreachable.
// ignore: unused_element
class DevelopmentCheckinClassic extends StatelessWidget {
  const DevelopmentCheckinClassic({super.key});

  DevStore get _s => DevStore.instance;
  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _s,
          builder: (context, _) {
            // ⚠️ THE QUESTIONS FOLLOW HIS AGE. They used to be one fixed list
            // written for a four-month-old, asked of every parent — so the
            // mother of a two-year-old was asked whether he smiles back and
            // brings his hands together at his chest. Age comes from the
            // profile; she is never asked for it.
            final questions =
                checkInsForAge(ChildProfileStore.instance.ageInMonths);
            final answered = questions.where((q) => _s.checkInAnswer(q.text) != null).length;
            final yeses = questions.where((q) => _s.checkInAnswer(q.text) == true).length;
            final notYet = questions.where((q) => _s.checkInAnswer(q.text) == false).length;
            final allDone = answered == questions.length;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Development')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('A gentle check-in', color: ppCoral)),
                const SizedBox(height: 8),
                _pad(Text('Let’s see how ${ChildProfileStore.instance.nameMid} is doing', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('A few soft questions - just to understand where he is. There are no right answers, no scores, and no comparing.', style: ppBody(14, h: 1.5))),

                const SizedBox(height: 20),
                _pad(Column(children: [for (final q in questions) _question(q)])),

                if (allDone) ...[
                  const SizedBox(height: 8),
                  _pad(_reflection(context, yeses, notYet)),
                ] else ...[
                  const SizedBox(height: 8),
                  _pad(Text('${questions.length - answered} to go - answer them however feels true today.', style: ppBody(12.5, color: ppMuted))),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _question(CheckInQ q) {
    final answer = _s.checkInAnswer(q.text);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(q.text, style: ppBody(14.5, color: ppInk, h: 1.45, w: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(children: [
          _choice('Yes', answer == true, ppPurple, () => _s.setCheckIn(q.text, true)),
          const SizedBox(width: 10),
          _choice('Not yet', answer == false, ppSoft, () => _s.setCheckIn(q.text, false)),
        ]),
      ]),
    );
  }

  Widget _choice(String label, bool on, Color accent, VoidCallback onTap) => Expanded(
        child: PvPress(child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? accent.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: on ? accent : ppBorder),
            ),
            child: Text(label, style: ppBody(13, color: on ? accent : ppSoft, w: FontWeight.w700)),
          ),
        )),
      );

  Widget _reflection(BuildContext context, int yeses, int notYet) {
    final allYes = notYet == 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFFCEAF0)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.favorite_rounded, size: 16, color: ppCoral), const SizedBox(width: 8), ppEyebrow('What this tells us', color: ppCoral, spacing: 0.8)]),
        const SizedBox(height: 12),
        Text(
          allYes
              ? 'Lovely - ${ChildProfileStore.instance.nameMid} is doing so much of what we’d hope for right now, and clearly delighting in you along the way. Keep offering the everyday moments of play and closeness; they’re doing exactly what they should.'
              : '${ChildProfileStore.instance.name} is showing lots of lovely, emerging skills. A few “not yet”s are completely normal - every baby walks this path at their own pace, and these can bloom any week now. Keep gently offering chances to practise, and enjoy where he is.',
          style: ppBody(14, color: ppInk, h: 1.6),
        ),
        if (!allYes) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.medical_services_outlined, size: 16, color: ppPurple),
              const SizedBox(width: 10),
              Expanded(child: Text('If anything ever sits on your mind, there’s no need to wait or worry alone - a quick word with your paediatrician is always a good idea. That’s peace of mind, not a red flag.', style: ppBody(12.5, color: ppInk, h: 1.5))),
            ]),
          ),
        ],
        const SizedBox(height: 14),
        Row(children: [
          PvPress(child: GestureDetector(
            onTap: () => openPpTab(context, 1),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [Text('Ask Veda anything', style: ppBody(13, color: ppPurple, w: FontWeight.w700)), const SizedBox(width: 6), const Icon(Icons.arrow_forward, size: 14, color: ppPurple)]),
          )),
        ]),
      ]),
    );
  }
}
