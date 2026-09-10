// =============================================================================
//  Mind & body — "Today". A do-it screen, NOT a card rail.
// -----------------------------------------------------------------------------
//  ⚠️ THE BRIEF SAYS THIS TWICE AND PUTS IT IN THE "DO NOT" LIST: *"Do not
//  render Today (Sub-tab 1) as card rails. It is a do-it screen."*
//
//  The distinction is not decoration. A card rail is a menu — it offers, and
//  the work of choosing is left with the reader. Today offers nothing to
//  choose: one movement, one breath, two ticks, decided already. On the day
//  somebody has ten minutes and no appetite for deciding anything, a menu is
//  one more thing to get through.
//
//  This is why it is reached as a GROUP TOOL rather than as a section of tiles.
//  `TtcFocusGroup.toolSurfaceId` renders a surface in place of the group's
//  rails, and it exists for exactly this: a tab whose content is a thing you
//  do. PCOS's "Where do I stand" uses the same mechanism.
//
//  ⚠️ NOTHING HERE DEFINES A PRACTICE. Today asks `ttcPracticeOfTheDay` for an
//  id and renders whatever the library says. That is the brief's loudest
//  instruction and the easiest one to break by being helpful.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_mind_today.dart';
import '../../ttc/ttc_practice_data.dart';
import 'ttc_common.dart';
import 'ttc_surface_router.dart';

class TtcMindTodayScreen extends StatelessWidget {
  const TtcMindTodayScreen({super.key});

  @override
  Widget build(BuildContext context) => const TtcMindTodayBody();
}

/// The body alone, for rendering inside a focus group's tab.
class TtcMindTodayBody extends StatelessWidget {
  const TtcMindTodayBody({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLogStore.instance,
      builder: (context, _) {
        final move = ttcPracticeOfTheDay(TtcPracticeKind.move);
        final breathe = ttcPracticeOfTheDay(TtcPracticeKind.breathe);

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label("TODAY'S MOVEMENT"),
          const SizedBox(height: 10),
          _PracticeToday(practice: move),

          const SizedBox(height: 24),
          _label("TODAY'S BREATH OR CALM"),
          const SizedBox(height: 10),
          _PracticeToday(practice: breathe),

          const SizedBox(height: 26),
          _label('AND TWO SMALL THINGS'),
          const SizedBox(height: 10),

          // ⚠️ TICKS, NOT TIMED SESSIONS — the brief is explicit. Both write
          // into the `habits` tracker rather than into anything owned here, so
          // "What you're working on" shows them too. See `ttc_mind_today.dart`.
          _HabitTick(
            field: kTtcBedtimeField,
            label: 'In bed by about eleven',
            blurb: 'Roughly is fine. This is not a bedtime you have to defend.',
          ),
          const SizedBox(height: 10),
          _HabitTick(
            field: kTtcHomeCookedField,
            label: 'Home-cooked meals today',
            // ⚠️ IT DOES NOT TEACH FOOD, AND THAT IS A BOUNDARY THE BRIEF SETS:
            // this area "references Getting ready, does not own or teach food".
            // So the tick records the fact and says nothing about what to eat.
            blurb: 'Mostly counts. What to actually eat lives in Getting ready.',
          ),

          const SizedBox(height: 26),

          // ⚠️ NO STREAK, NO COUNT, NO "3 DAYS IN A ROW". Forbidden four times
          // in the brief, and the data would support one — see the closing note
          // in `ttc_mind_today.dart` for why the absence is deliberate rather
          // than unfinished.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ttcPanel,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
                'Two cards a day, and they change tomorrow. Nothing here is '
                'counting, and a day you skip is not a day you lost.',
                style: ttcBody(12.5, color: ttcSoft, h: 1.55)),
          ),
        ]);
      },
    );
  }

  static Widget _label(String s) => Text(s,
      style: pvManrope(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: ttcMuted));
}

/// One of today's two practices, with its state on the face of it.
class _PracticeToday extends StatelessWidget {
  const _PracticeToday({required this.practice});
  final TtcPractice practice;

  @override
  Widget build(BuildContext context) {
    final done = ttcPracticeDoneToday(practice.kind);

    return GestureDetector(
      onTap: () =>
          openTtcSurface(context, 'ttc_practice/${practice.id}'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: done ? ttcPurple : ttcBorder,
              width: done ? 1.4 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(practice.title,
                  style: ttcFraunces(17, w: FontWeight.w600,
                      color: ttcTitleInk, h: 1.2)),
            ),
            if (done) ...[
              const SizedBox(width: 10),
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: ttcPurple),
            ],
          ]),
          const SizedBox(height: 8),
          Text(practice.blurb, style: ttcBody(13, color: ttcSoft, h: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.schedule_rounded, size: 14, color: ttcMuted),
            const SizedBox(width: 6),
            // ⚠️ THE CARD'S OWN WORDING, NOT A NUMBER WE FORMAT. "About 3
            // minutes" and "1 to 2 minutes" hedge on purpose, and rounding
            // either to "3 min" promises a precision the practice does not
            // have — which is the thing somebody plans their morning around.
            Text(practice.duration,
                style: ttcBody(12, color: ttcMuted, w: FontWeight.w700)),
            const Spacer(),
            Text(done ? 'Open it again' : 'Open',
                style: ttcBody(12.5, color: ttcPurple, w: FontWeight.w800)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded, size: 14,
                color: ttcPurple),
          ]),
        ]),
      ),
    );
  }
}

class _HabitTick extends StatelessWidget {
  const _HabitTick(
      {required this.field, required this.label, required this.blurb});

  final String field;
  final String label;
  final String blurb;

  @override
  Widget build(BuildContext context) {
    final on = ttcHabitTicked(field);

    return GestureDetector(
      onTap: () => ttcSetHabitTick(field, !on),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? ttcPurple : ttcBorder,
              width: on ? 1.4 : 1),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? ttcPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: on ? null : Border.all(color: ttcBorder, width: 1.4),
            ),
            child: on
                ? const Icon(Icons.check_rounded, size: 14,
                    color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: ttcBody(14, color: ttcTitleInk,
                          w: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(blurb, style: ttcBody(12.5, color: ttcSoft, h: 1.5)),
                ]),
          ),
        ]),
      ),
    );
  }
}
