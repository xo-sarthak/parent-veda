// =============================================================================
//  One practice, from the Mind & body library
// -----------------------------------------------------------------------------
//  ⚠️ ONE SCREEN FOR TWELVE CARDS, NOT TWELVE SCREENS. `TtcDoTile` resolves
//  through `ttcScreenForSurface`, and the obvious build for twelve Do cards is
//  twelve entries in that switch. Every one would be the same layout with
//  different words, and a thirteenth practice would need a code change and a
//  release. The surface id carries the practice — `ttc_practice/<id>` — exactly
//  as `ttc_read/<id>` does.
//
//  ⚠️ NOTHING ON THIS SCREEN IS TYPED HERE. Title, duration, setting, steps,
//  "skip it if" and the animation spec all come from `ttc_practice_data.dart`.
//
//  ⚠️ THE STEPS ARE THE PRODUCT; THE ANIMATION IS THE HELP. The brief:
//  *"Every movement card must work WITHOUT the animation: the step list, the
//  timer and the 'skip it if' note are the fallback and must always be
//  visible."* So the step list is not a fallback that appears when something
//  fails — it is always there, and the player sits above it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_mind_today.dart';
import '../../ttc/ttc_practice_data.dart';
import '../v2/v2_palette.dart';
import 'ttc_mind_today_screen.dart'
    show kTtcMoveHue, kTtcBreatheHue, kTtcBreatheFieldHue;
import 'ttc_practice_card_parts.dart';
import 'ttc_practice_player.dart';
import 'ttc_common.dart' show ttcTitleInk;
import 'ttc_tool_chrome.dart';

/// The hue for this area. 42 is the bracket's own, from `ttc_brackets.dart`.
///
/// ⚠️ KEPT, AND NO LONGER WHAT THIS SCREEN OPENS IN. A practice now takes the
/// hue of its own library — 104 for Move, 206 for Breathe — because that is the
/// colour of the block she tapped on Today. Landing sand-coloured after tapping
/// a sage block reads as having arrived somewhere else, and the whole point of
/// a do-it screen is that opening the card and doing the practice are one
/// motion. The door itself is still 42; a practice is a room inside it.
const double kTtcMindHue = 42;

class TtcPracticeScreen extends StatefulWidget {
  const TtcPracticeScreen({super.key, required this.practice});

  final TtcPractice practice;

  @override
  State<TtcPracticeScreen> createState() => _TtcPracticeScreenState();
}

class _TtcPracticeScreenState extends State<TtcPracticeScreen> {
  /// Which step is lit. Driven by the reader, not by a clock.
  ///
  /// ⚠️ THE BRIEF ASKS FOR A STEP LIST THAT ADVANCES ON A TIMER, AND THIS ONE
  /// ADVANCES ON A TAP INSTEAD. Deliberate, and the reason is in the brief's own
  /// shared rules: *"No countdown pressure… Leaving mid-way is fine."* A list
  /// that moves on its own is a countdown by another name — it takes the step
  /// away while you are still in it, and on a floor practice you are not looking
  /// at the phone when it happens. The forward and back controls are here, the
  /// current step is highlighted, and the session ring above still runs the
  /// clock. Written down rather than silently substituted; see §31.
  int _step = 0;

  // ⚠️ THE STEPS CAN NOW FOLLOW THE TIMER, AND SHE DECIDES (2026-09-27, tools
  // rebuild). The note above is still right that a list which moves on its
  // own takes a step away while you are in it; the user's verdict on the
  // player was that tapping from the mat is worse ("poor functionality"), and
  // every workout player on Mobbin moves with its clock (Future Pro's move
  // name over its countdown, https://mobbin.com/screens/72efd39a-7519-4765-8b86-eb7494d029ef;
  // Life Reset's workout counter with previous and next either side,
  // https://mobbin.com/screens/126e582a-4c14-4201-87c3-3d70ef52c059).
  //
  // So: ON by default where the steps are a sequence through the time (the
  // drawn movement cards, and the body relaxation whose figure already walks
  // down the body), with a labelled switch, and the moment she moves a step
  // herself the switch turns off, visibly, and the list is hers again. The
  // walk and the breathing cards keep their steps still: their steps are
  // how-to lines, not a sequence the clock can split.
  bool get _followable =>
      widget.practice.anim is TtcFigureAnim ||
      widget.practice.anim is TtcBodyScanAnim;
  late bool _follow = _followable;

  /// Which step the timer is on, `progress` 0 to 1.
  int _stepAt(double progress) {
    final n = widget.practice.steps.length;
    if (n == 0) return 0;
    if (progress >= 1) return n - 1;
    // The body relaxation's first and last steps are settling in and coming
    // out; its figure runs over the middle ones, so the list does too.
    if (widget.practice.anim is TtcBodyScanAnim && n > 2) {
      if (progress <= 0) return 0;
      return (1 + (progress * (n - 2)).floor()).clamp(1, n - 2);
    }
    return (progress * n).floor().clamp(0, n - 1);
  }

  void _onProgress(double progress, bool running) {
    if (!_follow || !mounted) return;
    final next = _stepAt(progress);
    if (next != _step) setState(() => _step = next);
  }

  /// She moved a step herself: the list is hers, and the switch says so.
  void _setStepByHand(int i) => setState(() {
        _step = i;
        _follow = false;
      });

  /// The timer ran to the end: mark it done, say so, offer the way back.
  void _onFinished() {
    final kind = widget.practice.kind;
    if (ttcPracticeDoneToday(kind)) return;
    ttcSetPracticeDone(kind, true);
    if (!mounted) return;
    pvSnack(context, 'Marked done on your Mind and body Today tab.',
        icon: Icons.check_rounded,
        action: 'Undo',
        onAction: () => ttcSetPracticeDone(kind, false),
        lift: 24);
  }

  @override
  Widget build(BuildContext context) {
    final pr = widget.practice;

    return AnimatedBuilder(
      animation: TtcLogStore.instance,
      builder: (context, _) {
        final done = ttcPracticeDoneToday(pr.kind);

        final pal = V2PaletteStore.instance.current;
        final hue = widget.practice.kind == TtcPracticeKind.move
            ? kTtcMoveHue
            : kTtcBreatheHue;
        final tint = v2BlockTint(hue, pal);
        final deep = HSLColor.fromColor(tint)
            .withSaturation(0.44)
            .withLightness(0.36)
            .toColor();
        // Whether the ring carries the step counter: a drawn-figure card
        // whose steps follow the timer (MB11 and MB14, 2026-09-28).
        final ringCounts = pr.anim is TtcFigureAnim && _follow;

        return TtcToolScaffold(
          // ⚠️ THE HEADER IS THE CARD'S COLOUR (launch sanity MB13,
          // 2026-09-28). A breath field painted from 206 travels to 240, a
          // lilac, under a slate-blue card; see `kTtcBreatheFieldHue`. Kept
          // for revert: hue: hue,
          hue: pr.kind == TtcPracticeKind.move ? hue : kTtcBreatheFieldHue,
          // ⚠️ ONE WORD FOR THE KIND (launch sanity MB6, 2026-09-28): the
          // Today headings say "Today's movement" and "Today's breath", so
          // the page they open says MOVEMENT or BREATH. Kept for revert:
          //   pr.kind == TtcPracticeKind.move ? 'MOVE' : 'BREATHE AND CALM',
          eyebrow: pr.kind == TtcPracticeKind.move ? 'MOVEMENT' : 'BREATH',
          title: pr.title,
          intro: pr.blurb,
          children: [
            // ---- how long, and where ---------------------------------
            //  ⚠️ THE WHOLE SHEET IS PADDED HERE RATHER THAN LINE BY LINE.
            //  `TtcToolScaffold` hands its children straight into the sheet, so
            //  every row below used to be responsible for its own inset and one
            //  of them always forgets. `ttcToolPad` around the column is one
            //  place to be wrong instead of fifteen.
            ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // ⚠️ CLEAR OF THE SHEET'S ROUNDED TOP (launch sanity MB10,
            // 2026-09-28). The line began on the sheet's first pixel, so its
            // corner curve cut in beside "About" and the line looked half on
            // the header. Headspace starts a session page's first line well
            // inside the sheet
            // (https://mobbin.com/screens/d5b9ff12-33e0-4ec4-ae64-82c70e68ba0d).
            const SizedBox(height: 22),
            // ⚠️ ONE QUIET LINE FOR TIME AND PLACE (2026-09-28), the card's own
            // words, as on the Today card she tapped to get here: two bold
            // lines with a clock and a pin were icons for plain facts, and a
            // fourth text style under the title and intro. Headspace's
            // session page says "Podcast" and "4 min" in one quiet line
            // (https://mobbin.com/screens/f2297328-ef5d-42b9-96ba-e851f428f5e4).
            Text('${pr.duration} · ${pr.setting}', style: ttcCardMeta(pal)),
            // Kept for revert (2026-09-28): the icon row below.
            // ignore: dead_code
            if (false) Row(children: [
              Icon(Icons.schedule_rounded, size: 15, color: pal.ink3),
              const SizedBox(width: 7),
              Text(pr.duration,
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: pal.ink2)),
              const SizedBox(width: 12),
              Icon(Icons.place_outlined, size: 15, color: pal.ink3),
              const SizedBox(width: 7),
              Expanded(
                child: Text(pr.setting,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: pal.ink2)),
              ),
            ]),

            const SizedBox(height: 20),
            // ⚠️ RING, THEN THE STEP SHE IS ON AND ITS CONTROLS, THEN THE LIST
            // (launch sanity MB14, 2026-09-28). The ring and Start took the
            // first screen and Previous and Next sat under the whole list, so
            // while the timer ran the step and the controls were a scroll
            // apart; "Step 1 of 6" was printed twice; and the two settings
            // were a bare switch and a line of text that was secretly one.
            // Now: the ring (which counts each step), the step she is on in
            // words with Previous and Next right under it, the full list as
            // "All steps", the two settings as labelled switches together,
            // then Skip it if and Mark done. One step counter: in the ring
            // while the steps follow the timer, on the step card otherwise.
            // Future's player keeps the move and its time under the clock
            // (https://mobbin.com/screens/e554df4e-de96-4fc3-81f2-652f44d009ca),
            // pushr puts its controls straight under the count
            // (https://mobbin.com/screens/1e4dd6e2-2e83-4fda-8069-51c74faf0cd9),
            // Opal keeps the one setting under the breath
            // (https://mobbin.com/screens/b7a85dff-8e86-4211-9dec-73f5bf2ac492).
            // The old order is kept for revert at the foot of this build.
            TtcPracticeSession(
              practice: pr,
              onFinished: _onFinished,
              onProgress: _onProgress,
              stepClock: ringCounts,
              showVibrate: false,
              // The sound switch sits with the other settings below.
              showSound: false,
              caption: ringCounts
                  ? 'Step ${_step + 1} of ${pr.steps.length}'
                  : null,
            ),
            const SizedBox(height: 20),

            // ---- the step she is on, and the two controls -----------
            if (pr.steps.isNotEmpty) ...[
              Semantics(
                liveRegion: true,
                child: Container(
                  width: double.infinity,
                  padding: kTtcCardPad,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(kTtcCardRadius),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!ringCounts) ...[
                          Text('Step ${_step + 1} of ${pr.steps.length}',
                              style: ttcCardMeta(pal)),
                          const SizedBox(height: 6),
                        ],
                        Text(pr.steps[_step],
                            style: pvManrope(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                color: pal.ink1)),
                      ]),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: _StepButton(
                    label: 'Previous step',
                    icon: Icons.arrow_back_rounded,
                    enabled: _step > 0,
                    filled: false,
                    deep: deep,
                    onTap: () => _setStepByHand(_step - 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StepButton(
                    label: 'Next step',
                    icon: Icons.arrow_forward_rounded,
                    enabled: _step < pr.steps.length - 1,
                    filled: true,
                    deep: deep,
                    onTap: () => _setStepByHand(_step + 1),
                  ),
                ),
              ]),
              const SizedBox(height: 28),
            ],

            // ---- every step --------------------------------------------
            Text('All steps',
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: pal.ink1)),
            const SizedBox(height: 10),

            //  ⚠️ THE LIVE STEP IS A FILLED ROW, NOT A BOLDER FONT. Weight
            //  alone is what this had, and on a floor practice the phone is
            //  arm's length away on the mat: at that distance w700 against w400
            //  in the same colour is not a difference you can find without
            //  reading. A tinted row with a filled number is findable in a
            //  glance, which is the only interaction this list ever gets.
            for (var i = 0; i < pr.steps.length; i++) ...[
              GestureDetector(
                onTap: () => _setStepByHand(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(
                      vertical: 11, horizontal: 11),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: i == _step ? tint : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i == _step ? ttcTitleInk : pal.surfaceAlt,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('${i + 1}',
                              style: pvManrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      i == _step ? Colors.white : pal.ink2)),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(pr.steps[i],
                              // ⚠️ NO `maxLines`, ANYWHERE IN THIS LIST. The
                              // brief: the step text "must survive the largest
                              // accessibility text size". A clipped instruction
                              // is worse than a long screen.
                              style: pvManrope(
                                  fontSize: 13.5,
                                  height: 1.55,
                                  color: i == _step ? pal.ink1 : pal.ink2,
                                  fontWeight: i == _step
                                      ? FontWeight.w700
                                      : FontWeight.w400)),
                        ),
                      ]),
                ),
              ),
            ],

            // ---- which side, where sides matter ----------------------
            if (pr.anim case TtcFigureAnim(sides: true)) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.swap_horiz_rounded, size: 15, color: pal.ink3),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'This one uses both sides. Do the whole thing on one '
                      'side, then on the other.',
                      style: pvManrope(
                          fontSize: 12.5, height: 1.5, color: pal.ink2)),
                ),
              ]),
            ],

            // ---- the settings, labelled, together ----------------------
            // ⚠️ SHOWN FOR EVERY PRACTICE NOW (2026-09-28): every practice has
            // at least the end tone, so every one carries "Sound cues". Kept
            // for revert, the condition when there were two settings only:
            //   if (_followable || pr.anim is TtcBreathAnim) ...[
            ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
                decoration: BoxDecoration(
                  color: pal.surface,
                  borderRadius: BorderRadius.circular(kTtcCardRadius),
                  border: Border.all(color: pal.line),
                ),
                child: Column(children: [
                  if (_followable)
                    _FollowSwitch(
                      on: _follow,
                      onChanged: (v) => setState(() => _follow = v),
                    ),
                  if (pr.anim is TtcBreathAnim) const TtcVibrateSwitch(),
                  const TtcSoundSwitch(),
                ]),
              ),
            ],

            const SizedBox(height: 18),

            // ---- skip it if ------------------------------------------
            //
            // ⚠️ PER-CARD, AND THE GENERAL SAFETY LINE IS NOT HERE. The brief
            // separates them: one general line on the practice tab, and a
            // specific caution on each card. Repeating the general one twelve
            // times is what stops it being read.
            //  ⚠️ WARM, NOT ALARMING, AND NOT THE PALETTE'S OWN HUE EITHER. A
            //  caution painted in the practice's colour disappears into the
            //  page; painted red it reads as a red flag, which this is not —
            //  "put a cushion under the knees" is not a reason to call anyone.
            //  Sand (42) is the stage's caution tint and is used here for the
            //  same reason the door uses it for paid blocks: distinct without
            //  being loud.
            // The card family's inset and corner (2026-09-28; was all(14),
            // radius 16), so the one note on this page is the same shape as
            // the card that opened it.
            Container(
              padding: kTtcCardPad,
              decoration: BoxDecoration(
                color: v2BlockTint(42, pal),
                borderRadius: BorderRadius.circular(kTtcCardRadius),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: pal.ink2),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kept for revert (2026-09-27): 'SKIP IT IF'.
                            // And (2026-09-28): 'Skip it if'.
                            Text('Skip this practice if',
                                style: pvManrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: pal.ink1)),
                            const SizedBox(height: 5),
                            Text(pr.skipIf,
                                style: pvManrope(
                                    fontSize: 12.5,
                                    height: 1.55,
                                    color: pal.ink1)),
                          ]),
                    ),
                  ]),
            ),

            const SizedBox(height: 22),

            // ---- done today ------------------------------------------
            //
            // ⚠️ A TOGGLE, AND NO CONGRATULATION. Tapping it again undoes it —
            // a tick that only goes one way turns a mis-tap into a permanent
            // small lie. It says "Done today" rather than anything warmer,
            // because a screen that celebrates makes the days she does not open
            // it into days she let something down. There is no streak; see
            // `ttc_mind_today.dart`.
            GestureDetector(
              onTap: () => ttcSetPracticeDone(pr.kind, !done),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? pal.surfaceAlt : ttcTitleInk,
                  borderRadius: BorderRadius.circular(16),
                  border: done ? Border.all(color: pal.line) : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(done ? Icons.check_rounded : Icons.circle_outlined,
                      size: 17, color: done ? pal.ink1 : Colors.white),
                  const SizedBox(width: 9),
                  Text(done ? 'Done today' : 'Mark done today',
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: done ? pal.ink1 : Colors.white)),
                ]),
              ),
            ),
            // What the button does, under it (tools pass, 2026-09-27): it
            // was not clear that it feeds Today or that a second tap undoes.
            // Since the rebuild the timer marks it done on its own at the
            // end, so the line says that first. Kept for revert:
            //   'Shows as done on your Mind and body Today tab. '
            //   'Tap again to undo.'
            const SizedBox(height: 8),
            Center(
              child: Text(
                  done
                      ? 'Shows as done on your Mind and body Today tab. '
                          'Tap again to undo.'
                      : 'Finishing the timer marks it done for you. It shows '
                          'on your Mind and body Today tab.',
                  textAlign: TextAlign.center,
                  style: pvManrope(
                      fontSize: 12.5, height: 1.45, color: pal.ink3)),
            ),
            const SizedBox(height: 10),
            // Kept for revert (2026-09-28, launch sanity MB14): the order
            // before, ring, then "What to do" with its own counter and the
            // follow switch, the list, then Previous and Next under the list.
            // const SizedBox(height: 20),
            // TtcPracticeSession(
            // practice: pr,
            // onFinished: _onFinished,
            // onProgress: _onProgress,
            // caption: pr.anim is TtcFigureAnim && _follow
            // ? 'Step ${_step + 1} of ${pr.steps.length}'
            // : null,
            // ),
            // const SizedBox(height: 24),
            //
            // // ---- the steps -------------------------------------------
            // // Kept for revert (2026-09-27): 'WHAT TO DO' in tracked capitals,
            // // with two small unlabelled up and down arrows beside it. The
            // // arrows are now the labelled buttons under the list.
            // //   Row(children: [Text('WHAT TO DO'), Spacer(),
            // //     _StepNudge(up), _StepNudge(down)]),
            // Row(children: [
            // Expanded(
            // child: Text('What to do',
            // style: pvManrope(
            // fontSize: 14.5,
            // fontWeight: FontWeight.w800,
            // color: pal.ink1)),
            // ),
            // Text('Step ${_step + 1} of ${pr.steps.length}',
            // style: pvManrope(
            // fontSize: 12.5,
            // fontWeight: FontWeight.w700,
            // color: pal.ink3)),
            // ]),
            // if (_followable) ...[
            // const SizedBox(height: 4),
            // _FollowSwitch(
            // on: _follow,
            // onChanged: (v) => setState(() => _follow = v),
            // ),
            // ],
            // const SizedBox(height: 12),
            //
            // //  ⚠️ THE LIVE STEP IS A FILLED ROW, NOT A BOLDER FONT. Weight
            // //  alone is what this had, and on a floor practice the phone is
            // //  arm's length away on the mat: at that distance w700 against w400
            // //  in the same colour is not a difference you can find without
            // //  reading. A tinted row with a filled number is findable in a
            // //  glance, which is the only interaction this list ever gets.
            // for (var i = 0; i < pr.steps.length; i++) ...[
            // GestureDetector(
            // onTap: () => _setStepByHand(i),
            // behavior: HitTestBehavior.opaque,
            // child: AnimatedContainer(
            // duration: const Duration(milliseconds: 140),
            // padding: const EdgeInsets.symmetric(
            // vertical: 11, horizontal: 11),
            // margin: const EdgeInsets.only(bottom: 4),
            // decoration: BoxDecoration(
            // color: i == _step ? tint : Colors.transparent,
            // borderRadius: BorderRadius.circular(14),
            // ),
            // child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // children: [
            // Container(
            // width: 24,
            // height: 24,
            // alignment: Alignment.center,
            // decoration: BoxDecoration(
            // color: i == _step ? deep : pal.surfaceAlt,
            // borderRadius: BorderRadius.circular(999),
            // ),
            // child: Text('${i + 1}',
            // style: pvManrope(
            // fontSize: 11,
            // fontWeight: FontWeight.w800,
            // color:
            // i == _step ? Colors.white : pal.ink2)),
            // ),
            // const SizedBox(width: 11),
            // Expanded(
            // child: Text(pr.steps[i],
            // // ⚠️ NO `maxLines`, ANYWHERE IN THIS LIST. The
            // // brief: the step text "must survive the largest
            // // accessibility text size". A clipped instruction
            // // is worse than a long screen.
            // style: pvManrope(
            // fontSize: 13.5,
            // height: 1.55,
            // color: i == _step ? pal.ink1 : pal.ink2,
            // fontWeight: i == _step
            // ? FontWeight.w700
            // : FontWeight.w400)),
            // ),
            // ]),
            // ),
            // ),
            // ],
            //
            // // ⚠️ PREVIOUS AND NEXT, LABELLED AND BIG ENOUGH FOR THE MAT
            // // (tools pass, 2026-09-27). Two 30pt arrows with no words were the
            // // only way to move, and on a floor practice the phone is at arm's
            // // length. Now two full-width halves, 52 tall, that say what they
            // // do. Still moved by her, never by a clock (see `_step`). Mobbin:
            // // Future's workout player (a large next control at the foot).
            // const SizedBox(height: 8),
            // Row(children: [
            // Expanded(
            // child: _StepButton(
            // label: 'Previous step',
            // icon: Icons.arrow_back_rounded,
            // enabled: _step > 0,
            // filled: false,
            // deep: deep,
            // onTap: () => _setStepByHand(_step - 1),
            // ),
            // ),
            // const SizedBox(width: 10),
            // Expanded(
            // child: _StepButton(
            // label: 'Next step',
            // icon: Icons.arrow_forward_rounded,
            // enabled: _step < pr.steps.length - 1,
            // filled: true,
            // deep: deep,
            // onTap: () => _setStepByHand(_step + 1),
            // ),
            // ),
            // ]),
            //
            // // ---- which side, where sides matter ----------------------
            // if (pr.anim case TtcFigureAnim(sides: true)) ...[
            // const SizedBox(height: 6),
            // Row(children: [
            // Icon(Icons.swap_horiz_rounded, size: 15, color: pal.ink3),
            // const SizedBox(width: 8),
            // Expanded(
            // child: Text(
            // 'This one uses both sides. Do the whole thing on one '
            // 'side, then on the other.',
            // style: pvManrope(
            // fontSize: 12.5, height: 1.5, color: pal.ink2)),
            // ),
            // ]),
            // ],
                ])),
          ],
        );
      },
    );
  }
}

/// The switch that lets the lit step follow the timer. Says what it does in
/// both states, so a switch that turned itself off (she moved a step by hand)
/// is never a mystery.
class _FollowSwitch extends StatelessWidget {
  const _FollowSwitch({required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return MergeSemantics(
      child: Row(children: [
        Expanded(
          child: Text(
              on
                  ? 'The steps move along with the timer.'
                  : 'You move the steps. Turn on to follow the timer.',
              style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
        ),
        Switch(
          value: on,
          onChanged: onChanged,
          // Kept for revert (2026-09-28, one black switch app-wide): activeTrackColor: p.ink1,
        ),
      ]),
    );
  }
}

/// One of the two step controls under the list: a word and an arrow, 52 tall.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.filled,
    required this.deep,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool filled;
  final Color deep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final fg = !enabled
        ? p.ink3.withValues(alpha: 0.5)
        : (filled ? Colors.white : p.ink1);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled && enabled ? ttcTitleInk : p.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (!filled) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 7),
            ],
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
            ),
            if (filled) ...[
              const SizedBox(width: 7),
              Icon(icon, size: 18, color: fg),
            ],
          ]),
        ),
      ),
    );
  }
}

// Kept for revert (2026-09-27): the small unlabelled arrow, replaced by
// `_StepButton`. Nothing uses it.
// ignore: unused_element
class _StepNudge extends StatelessWidget {
  const _StepNudge(
      {required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon,
            size: 18,
            color: enabled ? p.ink1 : p.ink3.withValues(alpha: 0.45)),
      ),
    );
  }
}
