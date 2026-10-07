// =============================================================================
//  PpBreastTimerScreen — left and right, one thumb (surface pp_feed_timer)
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P1 (Behind · Logging): "No timer, no last side ...
//  Add a running timer per side: tap 'Left' to start, tap again to pause, tap
//  'Right' to switch, 'Done' to save. Show 'Last side: Left, 1h 40m ago' on
//  the log and the home."
//
//  The engine is the fork's `BreastTimer` (f3e0a27): it stores TIMESTAMPS, not
//  a ticking count, so the time is right after the phone sleeps or the app is
//  killed mid-feed; this screen only repaints once a second. Done writes one
//  ordinary feed into FeedingStore, so the feed syncs and shows in the history
//  like any other (no second feed table).
//
//  The look: two round discs, the pregnancy contraction timer's press target
//  (`_TimerDisc`): the running side is ink-filled with white numerals, the
//  other white with a hairline. Mobbin: Oura's session timer (one numeral in a
//  ring, one quiet way out) https://mobbin.com/screens/08366dca-8bef-401f-a5d2-2514448fdf7d
//  and Messages' countdown (the number is the screen)
//  https://mobbin.com/screens/f8d9681d-1640-4d56-b333-893c9cd440e5.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit;
import '../v2/v2_palette.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import 'pp_care_log_data.dart';
import 'pp_care_parts.dart';
import 'pp_feeding_data.dart';

/// "Last side: Left, 1h 40m ago", for the log and the home. Null when no
/// breastfeed with a side is on record.
String? ppLastSideLine({DateTime? now}) {
  for (final f in FeedingStore.instance.all) {
    if (f.kind != FeedKind.breast || f.side == null) continue;
    final note = (f.note ?? '').toLowerCase();
    final side = switch (f.side!) {
      FeedSideX.left => 'Left',
      FeedSideX.right => 'Right',
      FeedSideX.both => note.contains('ended on left')
          ? 'Left'
          : note.contains('ended on right')
              ? 'Right'
              : 'Both',
    };
    return 'Last side: $side, ${ppCareAgo(f.time, now: now)}';
  }
  return null;
}

class PpBreastTimerScreen extends StatefulWidget {
  const PpBreastTimerScreen({super.key});

  @override
  State<PpBreastTimerScreen> createState() => _PpBreastTimerScreenState();
}

class _PpBreastTimerScreenState extends State<PpBreastTimerScreen> {
  final _t = BreastTimer.instance;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _t.init();
    FeedingStore.instance.init();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _t.running != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _done() {
    final saved = _t.finish();
    pvCommitFeedback();
    ppCareSaved(context, saved ? 'Feed saved to the feeding log.' : 'Nothing was timed, so nothing was saved.');
    if (saved) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_t, FeedingStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final next = ppNextBreastSide();
        final last = ppLastSideLine();
        return PregToolScaffold(
          hue: 206,
          eyebrow: 'Feeding',
          mark: IntentMark.feedMark,
          title: 'Breastfeed timer',
          intro: 'Tap a side to start, tap it again to pause, tap the other side to switch.',
          children: [
            if (!_t.isActive && (next != null || last != null))
              pregToolPad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (next != null)
                  Text(next.suggestion,
                      key: const ValueKey('pp_timer_suggestion'),
                      style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3, color: p.ink1)),
                if (last != null) ...[
                  const SizedBox(height: 4),
                  Text(last, key: const ValueKey('pp_timer_last_side'),
                      style: pvManrope(fontSize: 13.5, color: p.ink2)),
                ],
                const SizedBox(height: 20),
              ])),
            pregToolPad(Row(children: [
              Expanded(child: _SideDisc(side: TimerSide.left, timer: _t, onTap: () => _tap(TimerSide.left))),
              const SizedBox(width: 14),
              Expanded(child: _SideDisc(side: TimerSide.right, timer: _t, onTap: () => _tap(TimerSide.right))),
            ])),
            const SizedBox(height: 20),
            pregToolPad(Center(
              child: Text(
                _t.isActive ? 'This feed: ${ppCareTimer(_t.totalSeconds())}' : 'Not started',
                key: const ValueKey('pp_timer_total'),
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1),
              ),
            )),
            const SizedBox(height: 20),
            if (_t.isActive) ...[
              pregToolPad(PvCommit(key: const ValueKey('pp_timer_done'), label: 'Done, save this feed', onTap: _done)),
              const SizedBox(height: 8),
              pregToolPad(Center(
                child: TextButton(
                  key: const ValueKey('pp_timer_discard'),
                  onPressed: () {
                    _t.discard();
                    ppCareSaved(context, 'Timer cleared. Nothing was saved.');
                  },
                  child: Text('Clear without saving',
                      style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink2)),
                ),
              )),
            ] else
              pregToolPad(Text(
                'The timer keeps going if your phone sleeps or you leave this page. '
                'A feed forgotten for three hours is cleared, not saved.',
                style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
              )),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  void _tap(TimerSide side) {
    pvCommitFeedback();
    _t.tap(side);
  }
}

class _SideDisc extends StatelessWidget {
  const _SideDisc({required this.side, required this.timer, required this.onTap});
  final TimerSide side;
  final BreastTimer timer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final on = timer.running == side;
    final secs = timer.secondsFor(side);
    final label = side == TimerSide.left ? 'Left' : 'Right';
    final state = on ? 'Tap to pause' : (secs > 0 ? 'Paused' : 'Tap to start');
    const ink = Color(0xFF2F2C30);
    return Semantics(
      button: true,
      label: '$label side, ${ppCareTimer(secs)}, $state',
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: Material(
          color: on ? ink : Colors.white,
          shape: CircleBorder(side: BorderSide(color: on ? ink : p.line, width: on ? 0 : 1.5)),
          child: InkWell(
            key: ValueKey('pp_timer_${side.name}'),
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(label,
                      style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: on ? Colors.white : p.ink1)),
                  const SizedBox(height: 4),
                  Text(ppCareTimer(secs),
                      style: pvFraunces(
                          fontSize: 34, fontWeight: FontWeight.w600, height: 1.0, color: on ? Colors.white : p.ink1)),
                  const SizedBox(height: 6),
                  Text(state,
                      style: pvManrope(
                          fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white70 : p.ink2)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
