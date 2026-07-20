// =============================================================================
//  PhaseMapScreen — the whole 0–5 year road, and where he is on it
// -----------------------------------------------------------------------------
//  Replaces the Leap Calendar. The difference is not cosmetic: the leap calendar
//  showed ten equal stops at fixed weeks, which was the part of the Wonder Weeks
//  framework that failed replication. This shows twenty AAP/CDC-aligned age
//  phases of deliberately unequal width, because that is how development is
//  actually checkpointed clinically.
//
//  Phases behind him are settled, the current one is marked, and the ones ahead
//  are readable but quiet. Nothing is locked — a parent can read ahead as far
//  as she likes.
// =============================================================================

import 'package:flutter/material.dart';

import 'phase_detail_screen.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_phases_data.dart';

class PhaseMapScreen extends StatelessWidget {
  const PhaseMapScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final child = ChildProfileStore.instance;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: child,
          builder: (context, _) {
            final months = child.ageInMonths.toDouble();
            final currentIndex = phaseIndexForMonths(months);
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'My Child')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('The road so far', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('${child.name}’s journey', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 8),
                _pad(Text(
                  'Twenty phases from birth to five years, following the checkpoints paediatricians actually use. They are different lengths on purpose — development moves fastest at the start.',
                  style: ppBody(14, h: 1.55),
                )),
                const SizedBox(height: 24),
                for (var i = 0; i < kPhases.length; i++)
                  _pad(_row(context, kPhases[i], i, currentIndex)),
                const SizedBox(height: 18),
                _pad(Text(
                  'Every child moves through these at their own pace. The ages are where most children are, never a deadline — and your paediatrician knows your child better than any table does.',
                  textAlign: TextAlign.center,
                  style: ppBody(12, color: ppMuted, h: 1.55),
                )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(BuildContext context, AgePhase p, int i, int currentIndex) {
    final past = i < currentIndex;
    final now = i == currentIndex;
    final ink = past ? ppMuted : ppInk;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => PhaseDetailScreen(phase: p)),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: now ? p.accent.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: now ? p.accent.withValues(alpha: 0.45) : ppHair,
            width: now ? 1.4 : 1,
          ),
        ),
        child: Row(children: [
          // The marker: settled behind him, ringed where he is, open ahead.
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: past ? ppLine : (now ? p.accent : Colors.transparent),
              shape: BoxShape.circle,
              border: Border.all(color: now ? p.accent : ppLine, width: 2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(p.name,
                      style: ppJakarta(14.5, color: ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (now) ...[
                  const SizedBox(width: 8),
                  Text('NOW',
                      style: ppBody(9, color: p.accent, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                ],
                if (p.checkpoint && !now) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.verified_outlined, size: 13, color: ppMuted.withValues(alpha: 0.8)),
                ],
              ]),
              const SizedBox(height: 3),
              Text('${p.ageLabel} · ${p.tagline}',
                  style: ppBody(12.5, color: past ? ppMuted : ppSoft, h: 1.4),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, size: 19, color: ppMuted),
        ]),
      ),
    );
  }
}
