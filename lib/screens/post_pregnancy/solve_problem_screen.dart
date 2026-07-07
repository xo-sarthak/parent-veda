// =============================================================================
//  SolveProblemScreen — Solve Problem · full guide (parenting app · S7)
// -----------------------------------------------------------------------------
//  A challenge, fully explained: what's happening → what helps (numbered) →
//  watch → explained products → go-deeper (FAQ/course/room). Faithful build of
//  Claude Design S7. Reached from Home → "Challenges to watch" → any row.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'watch_home_screen.dart';

class SolveProblemScreen extends StatelessWidget {
  const SolveProblemScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // The Watch section routes to the real video-learning module (ParentVeda Watch).
  void _watch(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WatchHomeScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, "Today's challenge")),

            const SizedBox(height: 24),
            _pad(ppEyebrow('Solve · sleep')),
            const SizedBox(height: 10),
            _pad(Text('The 4-month sleep regression', style: ppFraunces(31, h: 1.15))),
            const SizedBox(height: 14),
            _pad(Text(
                "Around now, his sleep cycles reorganise into mature, adult-like patterns with lighter phases he briefly surfaces from. Layered on top of Leap 4's clinginess, bedtime can fall apart almost overnight. It's development, not regression — and it's temporary.",
                style: ppBody(15, h: 1.65))),

            _pad(ppSectionDivider()),
            _pad(ppEyebrow('What helps', color: ppSoft, spacing: 1.2)),
            const SizedBox(height: 6),
            _pad(_num('01', 'Start winding down earlier',
                '20 minutes before you think you need to — an overtired baby fights sleep harder.', top: true)),
            _pad(_num('02', 'Same 3-step routine, every night',
                'Feed, dim, cuddle — in that order. Predictability is the cue his brain learns.', top: true)),
            _pad(_num('03', 'Practise rolling in the daytime',
                'So the new skill gets rehearsed on the mat, not at 2am in the cot.', top: true, bottom: true)),

            _pad(ppSectionDivider()),
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Watch', style: ppJakarta(16)),
              GestureDetector(onTap: () => _watch(context), child: Text('See all', style: ppBody(12, color: ppPurple, w: FontWeight.w600))),
            ])),
            const SizedBox(height: 14),
            _pad(_video(context, 'The 4-month regression, explained', '3 min')),
            _pad(_video(context, 'Drowsy but awake: the hardest skill', '4 min', top: true)),

            _pad(ppSectionDivider()),
            _pad(Text('What can help', style: ppJakarta(16))),
            const SizedBox(height: 6),
            _pad(Text('Explained, never pushed. Add only if it fits your home.', style: ppBody(12, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(ppProductRow(context, 'White-noise soother', 'Masks joint-home sound between cycles.', '₹1,499', top: true, productId: 'dozy')),
            _pad(ppProductRow(context, 'Blackout curtains', 'Keeps early light from ending naps too soon.', '₹1,299', top: true, bottom: true, productId: 'hushcurtains')),

            _pad(ppSectionDivider()),
            _pad(Text('Go deeper', style: ppJakarta(16))),
            const SizedBox(height: 14),
            _pad(ppDeeperRow(context, 'FAQ', 'Should I sleep-train at 4 months?', top: true)),
            _pad(ppDeeperRow(context, 'Course', 'Sleep Bootcamp · Module 2', top: true)),
            _pad(ppDeeperRow(context, 'Room', 'March 2025 babies · 42 replies', top: true, bottom: true)),
          ],
        ),
      ),
    );
  }

  Widget _num(String n, String title, String desc, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n, style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(14, color: ppInk, w: FontWeight.w600, h: 1.5)),
              const SizedBox(height: 3),
              Text(desc, style: ppBody(13, h: 1.5)),
            ]),
          ),
        ]),
      );

  Widget _video(BuildContext context, String title, String dur, {bool top = false}) => GestureDetector(
        onTap: () => _watch(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.only(top: top ? 14 : 0, bottom: 14),
          decoration: BoxDecoration(border: Border(top: top ? const BorderSide(color: ppHair) : BorderSide.none)),
          child: Row(children: [
            SizedBox(
              width: 80,
              height: 54,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(alignment: Alignment.center, children: const [
                  PpStriped(height: 60),
                  Icon(Icons.play_arrow_rounded, color: ppPurple, size: 24),
                ]),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ppBody(14, color: ppInk, h: 1.35)),
                const SizedBox(height: 4),
                Text(dur, style: ppBody(12, color: ppMuted)),
              ]),
            ),
          ]),
        ),
      );
}
