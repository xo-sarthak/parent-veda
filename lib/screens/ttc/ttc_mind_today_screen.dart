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
//  ⚠️ NOTHING HERE DEFINES A PRACTICE. Today asks `ttcTodaysMove` for a card and
//  renders whatever the library says. That is the brief's loudest instruction
//  and the easiest one to break by being helpful.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REDRAWN 2026-09-10, AND THE OLD VERSION'S FAULT WAS NOT TASTE — IT WAS
//  THAT IT DREW IN A DIFFERENT LANGUAGE FROM THE PAGE IT SITS INSIDE.
//  ---------------------------------------------------------------------------
//  Reported as *"the user interface looks very bad starting from today's
//  movement"*, and there were three separate mechanical reasons for it. Worth
//  writing down, because all three are easy to reintroduce and none of them is
//  visible in a widget test:
//
//    1. NO HORIZONTAL PADDING. The focus screen wraps its own children in
//       `_pad` (18pt) but hands a GROUP TOOL straight through unpadded, on the
//       assumption that a tool insets itself — which `TtcPcosStandBody` does,
//       via `ttcToolPad`, and this did not. So every card on Today ran edge to
//       edge while every heading above it was inset, which reads as a layout
//       bug rather than a design.
//
//    2. THE WRONG PALETTE ENTIRELY. This file painted in the fixed TTC tool
//       tokens — `ttcPurple` on `Colors.white` over `ttcPanel` — while the door
//       around it paints in `V2PaletteStore.instance.current` at the bracket's
//       own hue (42, sand). A violet card on a sand page is not a card that
//       needs restyling; it is a card from another screen.
//
//    3. FLAT WHITE BOXES WHERE THE DOOR USES TINTED BLOCKS. Every other surface
//       in this stage says "this is a thing you open" with `v2BlockTint` plus a
//       large quiet mark. Today's two practices are the most important things
//       on the door and were the plainest objects on it.
//
//  So: `ttcToolPad` on everything, `V2Palette` throughout, and the two
//  practices drawn as full-width tinted blocks in the same idiom as `_TileCard`
//  — one wide block rather than a rail of narrow ones, because Today is not
//  offering a choice between them.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_garbh_course_store.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_mind_today.dart';
import '../../ttc/ttc_practice_data.dart';
import '../v2/v2_palette.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_surface_router.dart';

/// The two hues Today's blocks take.
///
/// ⚠️ BORROWED FROM THE DOOR'S OWN GROUPS, NOT INVENTED. 104 is the hue of the
/// "The practice" tab and 206 the hue of "Understand" — see
/// `ttc_focus_mind_body.dart`. Using them here means the movement block is
/// literally the colour of the library it came from, and nothing new enters the
/// door's palette to be kept in step later.
const double kTtcMoveHue = 104;
const double kTtcBreatheHue = 206;

/// Today on a page of its own, for anything that opens `ttc_mind_today` as a
/// destination rather than rendering it inside the door's first tab.
///
/// ⚠️ IT RETURNED THE BARE BODY UNTIL 2026-09-10, WHICH MEANT A NAKED COLUMN.
/// `ttcScreenForSurface('ttc_mind_today')` is a real route — a "read next" step
/// or a deep link can push it — and what arrived was a `Column` with no
/// `Scaffold` behind it: no ground colour, no safe area, no way back. Inside the
/// tab it looked fine, because the tab supplies all three, which is why this
/// survived. A body meant for two contexts has to be given the second one.
class TtcMindTodayScreen extends StatelessWidget {
  const TtcMindTodayScreen({super.key});

  @override
  Widget build(BuildContext context) => TtcToolScaffold(
        hue: kTtcBreatheHue,
        eyebrow: 'MIND & BODY',
        title: 'Today',
        intro: 'One movement, one breath and two small things. Nothing here '
            'keeps count.',
        children: const [TtcMindTodayBody()],
      );
}

/// The body alone, for rendering inside a focus group's tab.
class TtcMindTodayBody extends StatelessWidget {
  const TtcMindTodayBody({super.key, this.padded = true});

  /// Whether this inserts its own 18pt gutter.
  ///
  /// ⚠️ TRUE ALMOST EVERYWHERE, AND FALSE IN EXACTLY ONE PLACE. The focus screen
  /// hands a group tool straight into the sheet with no inset of its own, so
  /// Today has to bring one — that omission is what made this tab render edge to
  /// edge under inset headings, which is the bug this file's header describes.
  ///
  /// Session 8 of the garbh sanskar course shows the real Today widget inside a
  /// screen that is ALREADY padded, and two nested gutters make a narrow column
  /// down the middle of the page. Hence the flag rather than a second copy of
  /// the layout.
  final bool padded;

  Widget _inset(Widget child) => padded ? ttcToolPad(child) : child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // ⚠️ THREE LISTENABLES, AND THE THIRD IS EASY TO FORGET. The ticks live in
      // `TtcLogStore`, the chosen practice in `TtcGarbhCourseStore`, and the
      // colours in `V2PaletteStore` — which the ground switcher changes under
      // every screen at once. Miss it and Today is the one tab that does not
      // repaint.
      animation: Listenable.merge([
        TtcLogStore.instance,
        TtcGarbhCourseStore.instance,
        V2PaletteStore.instance,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final move = ttcTodaysMove();
        final breathe = ttcTodaysBreathe();
        final hers = ttcTodayIsHerPractice;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // WARNING: 8, NOT 22 — the same lesson `TtcPcosStandBody` carries.
          // Inline under the door's tab rail this is the second gap in a row,
          // and two gaps read as one large empty band.
          const SizedBox(height: 8),

          // ⚠️ ONE LINE THAT SAYS WHERE THE TWO CARDS CAME FROM, and it only
          // appears once there is something to say. Before session 8 the cards
          // are the day's and the line would be explaining a mechanism nobody
          // asked about; after it, its absence would make her own choice look
          // like a coincidence.
          if (hers) ...[
            _inset(_YourPracticeStrip(p: p)),
            const SizedBox(height: 18),
          ],

          _inset(_label("TODAY'S MOVEMENT", p)),
          const SizedBox(height: 10),
          _inset(_PracticeBlock(practice: move, hue: kTtcMoveHue, p: p)),

          const SizedBox(height: 22),
          _inset(_label("TODAY'S BREATH OR CALM", p)),
          const SizedBox(height: 10),
          _inset(
              _PracticeBlock(practice: breathe, hue: kTtcBreatheHue, p: p)),

          // ⚠️ THE COUPLE PART IS SHOWN ONLY IF SHE ASKED FOR IT IN SESSION 8.
          // It is not a third practice and does not get a block — it is a line
          // she chose to be reminded of, and the brief offers "or neither".
          if (TtcGarbhCourseStore.instance.couple case final part?) ...[
            const SizedBox(height: 22),
            _inset(_label('AND ONE THING TOGETHER', p)),
            const SizedBox(height: 10),
            _inset(_CouplePart(part: part, p: p)),
          ],

          const SizedBox(height: 24),
          _inset(_label('AND TWO SMALL THINGS', p)),
          const SizedBox(height: 10),

          // ⚠️ TICKS, NOT TIMED SESSIONS — the brief is explicit. Both write
          // into the `habits` tracker rather than into anything owned here, so
          // "What you're working on" shows them too. See `ttc_mind_today.dart`.
          //
          // ⚠️ ONE PANEL WITH A HAIRLINE BETWEEN THEM, NOT TWO CARDS. They are
          // the same kind of thing done at the same moment, and two separate
          // bordered boxes made a four-item list out of a two-item one.
          _inset(_TickPanel(p: p)),

          const SizedBox(height: 22),

          // ⚠️ NO STREAK, NO COUNT, NO "3 DAYS IN A ROW". Forbidden four times
          // in the brief, and the data would support one — see the closing note
          // in `ttc_mind_today.dart` for why the absence is deliberate rather
          // than unfinished.
          _inset(Text(
              hers
                  ? 'This is the practice you chose. Nothing here keeps count, '
                      "and a day you skip isn't a day lost."
                  : 'Two cards a day, and they change tomorrow. Nothing here '
                      "keeps count, and a day you skip isn't a day lost.",
              style: pvManrope(fontSize: 12.5, height: 1.6, color: p.ink3))),
          const SizedBox(height: 10),
        ]);
      },
    );
  }

  static Widget _label(String s, V2Palette p) => Text(s,
      style: pvManrope(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: p.ink3));
}

// =============================================================================
//  One practice, as a full-width block
// =============================================================================

/// ⚠️ FULL WIDTH, NOT A RAIL CARD, AND THE DIFFERENCE IS THE ARGUMENT AGAIN.
/// A 142pt rail card is sized to sit beside its siblings so you can compare
/// them. There is exactly one movement today and nothing to compare it with, so
/// it gets the width — and the width is what lets the blurb, the timing and the
/// setting all show without a tap.
class _PracticeBlock extends StatelessWidget {
  const _PracticeBlock(
      {required this.practice, required this.hue, required this.p});

  final TtcPractice practice;
  final double hue;
  final V2Palette p;

  /// The mark behind the block. Read from the animation rather than the kind,
  /// so the walk gets a walk and the listen gets a wave.
  IconData get _mark => switch (practice.anim) {
        TtcBreathAnim() => Icons.air_rounded,
        TtcBodyScanAnim() => Icons.accessibility_new_rounded,
        TtcListenAnim() => Icons.graphic_eq_rounded,
        TtcTimerAnim() => Icons.directions_walk_rounded,
        TtcFigureAnim() => Icons.self_improvement_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final done = ttcPracticeDoneToday(practice.kind);
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();

    return InkWell(
      onTap: () => openTtcSurface(context, 'ttc_practice/${practice.id}'),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(22),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          // Large, quiet, and cropped by the block — the same treatment the
          // door's own tiles use where there is no illustration yet.
          Positioned(
            right: -18,
            bottom: -14,
            child: Icon(_mark,
                size: 132, color: Colors.white.withValues(alpha: 0.42)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _Chip(
                        label: practice.kind == TtcPracticeKind.move
                            ? 'MOVE'
                            : 'BREATHE',
                        icon: practice.kind == TtcPracticeKind.move
                            ? Icons.self_improvement_rounded
                            : Icons.air_rounded,
                        fg: deep,
                        bg: Colors.white.withValues(alpha: 0.82)),
                    const Spacer(),
                    // ⚠️ DONE IS A CHIP THAT SAYS SO, NOT A TICK IN A CORNER. A
                    // bare check mark on a coloured block reads as a selection
                    // control — something you are being asked to set — which is
                    // exactly backwards on a card recording what already
                    // happened.
                    if (done)
                      _Chip(
                          label: 'DONE TODAY',
                          icon: Icons.check_rounded,
                          fg: Colors.white,
                          bg: deep.withValues(alpha: 0.92)),
                  ]),
                  const SizedBox(height: 14),
                  Text(practice.title,
                      style: pvFraunces(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          height: 1.18,
                          letterSpacing: -0.4,
                          color: p.ink1)),
                  const SizedBox(height: 8),
                  // Room for the whole blurb: the block is full width and the
                  // blurb is two lines by construction in the library.
                  Text(practice.blurb,
                      style: pvManrope(
                          fontSize: 13, height: 1.55, color: p.ink2)),
                  const SizedBox(height: 14),
                  Row(children: [
                    Icon(Icons.schedule_rounded, size: 14, color: deep),
                    const SizedBox(width: 6),
                    // ⚠️ THE CARD'S OWN WORDING, NOT A NUMBER WE FORMAT. "About
                    // 3 minutes" and "1 to 2 minutes" hedge on purpose, and
                    // rounding either to "3 min" promises a precision the
                    // practice does not have — which is the thing somebody
                    // plans their morning around.
                    Flexible(
                      child: Text(practice.duration,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: deep)),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.place_outlined, size: 14, color: deep),
                    const SizedBox(width: 6),
                    Flexible(
                      flex: 2,
                      child: Text(practice.setting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: deep)),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  // The affordance, spelled out. On a block with no chevron and
                  // no button, "is this a card or a picture" is a real question.
                  Row(children: [
                    Text(done ? 'Do it again' : 'Start',
                        style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: p.ink1)),
                    const SizedBox(width: 5),
                    Icon(Icons.arrow_forward_rounded, size: 15, color: p.ink1),
                  ]),
                ]),
          ),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label,
      required this.icon,
      required this.fg,
      required this.bg});

  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 5),
          Text(label,
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: fg)),
        ]),
      );
}

// =============================================================================
//  The strip that says whose practice this is
// =============================================================================

class _YourPracticeStrip extends StatelessWidget {
  const _YourPracticeStrip({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(13, 11, 11, 11),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: p.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The practice you built in session eight.',
                      style: pvManrope(
                          fontSize: 12.5, height: 1.5, color: p.ink2)),
                  const SizedBox(height: 6),
                  // ⚠️ THE WAY BACK IS ON THE SAME LINE AS THE FACT. Undoing
                  // this without it means finding the course and redoing
                  // session 8 to choose something else, which is a settings
                  // screen with extra steps.
                  GestureDetector(
                    onTap: TtcGarbhCourseStore.instance.clearDailyPractice,
                    behavior: HitTestBehavior.opaque,
                    child: Text('Go back to a different card each day',
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: p.action)),
                  ),
                ]),
          ),
        ]),
      );
}

/// The gratitude or conversation line, when she asked for one.
class _CouplePart extends StatelessWidget {
  const _CouplePart({required this.part, required this.p});
  final TtcCoupleDaily part;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final (title, blurb) = switch (part) {
      TtcCoupleDaily.gratitude => (
          'One thing you like about each other',
          'Say it out loud, one each. It takes about thirty seconds, and '
              "people say it's the part that changed the most.",
        ),
      TtcCoupleDaily.conversation => (
          'One honest question, and just listen',
          'Ask, and let the answer be, without trying to fix it. That is the '
              'whole practice.',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: pvFraunces(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: p.ink1)),
        const SizedBox(height: 6),
        Text(blurb,
            style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2)),
      ]),
    );
  }
}

// =============================================================================
//  The two habit ticks
// =============================================================================

class _TickPanel extends StatelessWidget {
  const _TickPanel({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    // ⚠️ THE BEDTIME SHE SET IN SESSION 5 IS SHOWN WHERE SHE SET IT FOR. The
    // brief's label is "In bed by about eleven"; eleven is the course's own
    // suggestion, and once she has named a different time, printing ours over
    // hers is the app forgetting what it asked her.
    final bed = TtcGarbhCourseStore.instance.bedtime;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(children: [
        _Tick(
          p: p,
          field: kTtcBedtimeField,
          label: bed == null ? 'In bed by about eleven' : 'In bed by about $bed',
          blurb: "Roughly is fine. You don't have to be strict about it.",
        ),
        Divider(height: 1, thickness: 1, color: p.line, indent: 15, endIndent: 15),
        _Tick(
          p: p,
          field: kTtcHomeCookedField,
          label: 'Home-cooked meals today',
          // ⚠️ IT DOES NOT TEACH FOOD, AND THAT IS A BOUNDARY THE BRIEF SETS:
          // this area "references Getting ready, does not own or teach food".
          // So the tick records the fact and says nothing about what to eat.
          blurb: 'Mostly home-cooked counts. What to eat is in Getting ready.',
        ),
      ]),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick(
      {required this.p,
      required this.field,
      required this.label,
      required this.blurb});

  final V2Palette p;
  final String field;
  final String label;
  final String blurb;

  @override
  Widget build(BuildContext context) {
    final on = ttcHabitTicked(field);

    return InkWell(
      onTap: () => ttcSetHabitTick(field, !on),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            width: 23,
            height: 23,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? p.action : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: on ? null : Border.all(color: p.line, width: 1.6),
            ),
            child: on
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: p.ink1)),
                  const SizedBox(height: 4),
                  Text(blurb,
                      style: pvManrope(
                          fontSize: 12.5, height: 1.5, color: p.ink3)),
                ]),
          ),
        ]),
      ),
    );
  }
}
