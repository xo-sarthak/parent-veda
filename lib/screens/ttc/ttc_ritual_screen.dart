// =============================================================================
//  TTC - the daily ritual
// -----------------------------------------------------------------------------
//  Pregnancy has Garbh Sanskar. TTC has this: five parts, five minutes.
//
//      "Today's Reflection · Today's Breath · Today's Conversation ·
//       Today's Gratitude · Today's Action. Five minutes. Exactly like Garbh
//       Sanskar. Different purpose."                     - TTC master, §2.4
//
//  Garbh Sanskar splits into a DAILY face (one item per pillar, with
//  completion) and a LIBRARY face. This is the daily face; the library arrives
//  with the Tools hub. The content is chapter-aware, because a gratitude prompt
//  during the waiting days should not sound like one during the fertile window.
//
//  There is no timer, no audio requirement, no score, and no way to fail. The
//  tick exists so the couple can see they did it, not so the app can grade it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_ritual_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

class TtcRitualScreen extends StatelessWidget {
  const TtcRitualScreen({super.key, required this.chapter, this.focus});

  final TtcChapter chapter;

  /// Which part was tapped to get here - scrolled into view and opened.
  final TtcRitualPart? focus;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcRitualStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final store = TtcRitualStore.instance;
        final items = ttcRituals[chapter] ?? const <TtcRitualItem>[];
        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.ritualTitle),
                const SizedBox(height: 18),

                // The chapter this ritual belongs to, so it never reads as
                // generic wellness content bolted on.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ttcCardRadius),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [ttcPurple, ttcPurpleDeep],
                    ),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chapter.title(hi),
                            style: ttcFraunces(21,
                                w: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 7),
                        Text(t.dailyRitualBody,
                            style: ttcBody(13,
                                color: Colors.white.withValues(alpha: 0.93),
                                h: 1.5)),
                        const SizedBox(height: 14),
                        Row(children: [
                          Text('${store.completedToday()}/${store.total}',
                              style: ttcBody(13,
                                  color: Colors.white, w: FontWeight.w800)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TtcProgressBar(
                                value: store.completedToday() / store.total),
                          ),
                        ]),
                      ]),
                ),
                const SizedBox(height: 20),

                for (final item in items) ...[
                  _RitualPartCard(
                    item: item,
                    t: t,
                    done: store.isDone(item.part),
                    expanded: focus == null || focus == item.part,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RitualPartCard extends StatelessWidget {
  const _RitualPartCard({
    required this.item,
    required this.t,
    required this.done,
    required this.expanded,
  });

  final TtcRitualItem item;
  final TtcS t;
  final bool done;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: ttcPanel, shape: BoxShape.circle),
            child: Icon(_icon(item.part), size: 19, color: ttcPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.part.title(hi), style: ttcJakarta(15.5)),
                  const SizedBox(height: 2),
                  Text(item.part.why(hi), style: ttcBody(11.5)),
                ]),
          ),
        ]),
        const SizedBox(height: 14),
        Text(item.text(hi), style: ttcBody(14.5, color: ttcInk, h: 1.68)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => TtcRitualStore.instance.toggle(item.part),
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: done ? ttcPanel : ttcPurple,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(done ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 17, color: done ? ttcPurple : Colors.white),
              const SizedBox(width: 8),
              Text(done ? t.ritualDone : t.ritualMarkDone,
                  style: ttcBody(13.5,
                      color: done ? ttcPurple : Colors.white,
                      w: FontWeight.w800)),
            ]),
          ),
        ),
      ]),
    );
  }

  IconData _icon(TtcRitualPart part) {
    switch (part) {
      case TtcRitualPart.reflection:
        return Icons.psychology_outlined;
      case TtcRitualPart.breath:
        return Icons.air_rounded;
      case TtcRitualPart.conversation:
        return Icons.forum_outlined;
      case TtcRitualPart.gratitude:
        return Icons.wb_sunny_outlined;
      case TtcRitualPart.action:
        return Icons.task_alt_rounded;
    }
  }
}
