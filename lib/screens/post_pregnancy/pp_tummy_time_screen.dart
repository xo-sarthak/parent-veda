// =============================================================================
//  PpTummyTimeScreen — a gentle timer for tummy time (surface pp_tummy_time)
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P2 (Behind · Logging): "Add a tummy time timer on
//  the Development door with a soft daily total and no target." The fork had
//  one (aab9f8f) that kept sessions on the phone; this one writes to
//  `TummyStore` (child-scoped, co-parented, migration 0094) and wears the
//  shared tool shell.
//
//  ONE DISC IS THE TIMER AND THE BUTTON, the contraction timer's and the
//  movement counter's pattern: tap to start, tap to stop and save. Leaving the
//  page mid-session saves what was done rather than losing it.
//
//  NO TARGET, NO STREAK, NO "MINUTES LEFT". Today's total and the week, plain.
//  A few minutes at a time, several times a day, is what the pages say; a goal
//  turns play into a test.
//
//  Mobbin: Oura's session timer https://mobbin.com/screens/08366dca-8bef-401f-a5d2-2514448fdf7d,
//  pushr's one large count with one control
//  https://mobbin.com/screens/1e4dd6e2-2e83-4fda-8069-51c74faf0cd9.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../pregnancy/preg_tool_parts.dart' show PregFoldRow;
import '../v2/v2_palette.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import 'pp_care_log_data.dart';
import 'pp_care_parts.dart';
import 'pp_child_profile.dart';

String _mins(int seconds) {
  final m = (seconds / 60).round();
  return seconds > 0 && m == 0 ? 'under a minute' : '$m min';
}

class PpTummyTimeScreen extends StatefulWidget {
  const PpTummyTimeScreen({super.key});

  @override
  State<PpTummyTimeScreen> createState() => _PpTummyTimeScreenState();
}

class _PpTummyTimeScreenState extends State<PpTummyTimeScreen> {
  final _store = TummyStore.instance;
  DateTime? _start;
  Timer? _tick;

  int get _elapsed => _start == null ? 0 : DateTime.now().difference(_start!).inSeconds;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  @override
  void dispose() {
    _tick?.cancel();
    // Leaving mid-session keeps what was done.
    if (_start != null) _store.log(start: _start!, seconds: _elapsed);
    super.dispose();
  }

  void _toggle() {
    pvCommitFeedback();
    if (_start == null) {
      setState(() => _start = DateTime.now());
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      return;
    }
    final secs = _elapsed;
    final start = _start!;
    _tick?.cancel();
    setState(() => _start = null);
    final saved = _store.log(start: start, seconds: secs);
    ppCareSaved(context, saved ? 'Tummy time saved: ${_mins(secs)}.' : 'Under ten seconds, so nothing was saved.');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, ChildProfileStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final c = ChildProfileStore.instance;
        final running = _start != null;
        const ink = Color(0xFF2F2C30);
        return PregToolScaffold(
          hue: 140,
          eyebrow: 'Development',
          mark: IntentMark.playMark,
          title: 'Tummy time',
          intro: 'A few minutes at a time, while ${c.they} is awake and you are right there.',
          children: [
            pregToolPad(Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Semantics(
                  button: true,
                  label: running ? 'Tummy time running, ${ppCareTimer(_elapsed)}. Tap to stop and save.' : 'Start tummy time',
                  excludeSemantics: true,
                  child: Material(
                    color: running ? ink : Colors.white,
                    shape: CircleBorder(side: BorderSide(color: running ? ink : p.line, width: running ? 0 : 1.5)),
                    child: InkWell(
                      key: const ValueKey('pp_tummy_disc'),
                      customBorder: const CircleBorder(),
                      onTap: _toggle,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            if (running)
                              Text(ppCareTimer(_elapsed),
                                  key: const ValueKey('pp_tummy_clock'),
                                  style: pvFraunces(fontSize: 52, fontWeight: FontWeight.w600, color: Colors.white))
                            else
                              Icon(Icons.play_arrow_rounded, size: 64, color: p.ink1),
                            const SizedBox(height: 4),
                            Text(running ? 'Tap to stop and save' : 'Start',
                                style: pvManrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: running ? Colors.white70 : p.ink1)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 22),
            pregToolPad(PpCareStats([
              (_store.secondsToday == 0 ? 'None yet' : _mins(_store.secondsToday), 'today'),
              ('${_store.todays.length}', _store.todays.length == 1 ? 'session today' : 'sessions today'),
            ])),
            const SizedBox(height: 26),
            pregToolPad(ppCareHeading('This week')),
            const SizedBox(height: 12),
            pregToolPad(PpWeekBars(
              values: [for (final s in _store.lastDays(7)) (s / 60).round()],
              unit: 'min',
            )),
            const SizedBox(height: 22),
            PregFoldRow(
              keyPrefix: 'pp_tummy_why',
              fold: 'why',
              icon: Icons.info_outline_rounded,
              title: 'Why tummy time helps',
              body: Text(
                'Lying on the tummy, awake, builds the neck, shoulder and back strength a baby needs to roll, '
                'sit and crawl, and eases the flat spot from sleeping on the back. Start with a minute or two '
                'on your chest from the first days, and build up through the day. Crying is a sign to stop and '
                'try again later, not a sign of failure.',
                style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1),
              ),
            ),
            PregFoldRow(
              keyPrefix: 'pp_tummy_safe',
              fold: 'safe',
              icon: Icons.shield_outlined,
              title: 'Keeping it safe',
              body: Text(
                'Only while awake and watched, on a firm, flat surface. Sleep is always on the back. '
                'Not straight after a big feed. If your baby seems floppy, very stiff, or always turns the head '
                'one way, mention it to your paediatrician.',
                style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1),
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
