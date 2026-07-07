// =============================================================================
//  DevelopmentCheckinScreen — a gentle check-in (not an assessment)
// -----------------------------------------------------------------------------
//  A few soft, adaptive questions to build understanding — never a score, never
//  a comparison. Answers gather a warm, reassuring reflection; if some are "not
//  yet", it simply, kindly suggests keeping an eye and mentioning it to the
//  paediatrician if the parent wishes. Understanding over evaluation.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_development_data.dart';

class DevelopmentCheckinScreen extends StatelessWidget {
  const DevelopmentCheckinScreen({super.key});

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
            final answered = kCheckIns.where((q) => _s.checkInAnswer(q.text) != null).length;
            final yeses = kCheckIns.where((q) => _s.checkInAnswer(q.text) == true).length;
            final notYet = kCheckIns.where((q) => _s.checkInAnswer(q.text) == false).length;
            final allDone = answered == kCheckIns.length;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Development')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('A gentle check-in', color: ppCoral)),
                const SizedBox(height: 8),
                _pad(Text('Let’s see how Aarav is doing', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('A few soft questions — just to understand where he is. There are no right answers, no scores, and no comparing.', style: ppBody(14, h: 1.5))),

                const SizedBox(height: 20),
                _pad(Column(children: [for (final q in kCheckIns) _question(q)])),

                if (allDone) ...[
                  const SizedBox(height: 8),
                  _pad(_reflection(context, yeses, notYet)),
                ] else ...[
                  const SizedBox(height: 8),
                  _pad(Text('${kCheckIns.length - answered} to go — answer them however feels true today.', style: ppBody(12.5, color: ppMuted))),
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
        child: GestureDetector(
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
        ),
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
              ? 'Lovely — Aarav is doing so much of what we’d hope for right now, and clearly delighting in you along the way. Keep offering the everyday moments of play and closeness; they’re doing exactly what they should.'
              : 'Aarav is showing lots of lovely, emerging skills. A few “not yet”s are completely normal — every baby walks this path at their own pace, and these can bloom any week now. Keep gently offering chances to practise, and enjoy where he is.',
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
              Expanded(child: Text('If anything ever sits on your mind, there’s no need to wait or worry alone — a quick word with your paediatrician is always a good idea. That’s peace of mind, not a red flag.', style: ppBody(12.5, color: ppInk, h: 1.5))),
            ]),
          ),
        ],
        const SizedBox(height: 14),
        Row(children: [
          GestureDetector(
            onTap: () => openPpTab(context, 1),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [Text('Ask Veda anything', style: ppBody(13, color: ppPurple, w: FontWeight.w700)), const SizedBox(width: 6), const Icon(Icons.arrow_forward, size: 14, color: ppPurple)]),
          ),
        ]),
      ]),
    );
  }
}
