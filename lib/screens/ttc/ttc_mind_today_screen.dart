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
import '../products/pv_store_chrome.dart' show pvSnack;
import '../../ttc/ttc_daily_data.dart' show TtcRitualPart;
import '../v2/v2_palette.dart';
import 'doors/ttc_door_screen.dart' show openTtcDoor;
import 'ttc_practice_card_parts.dart';
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

/// The hue a breathing page's hero FIELD is painted from, not its cards.
///
/// ⚠️ 186, NOT 206, AND THE REASON IS THE FIELD'S SECOND HUE (launch sanity
/// MB13, 2026-09-28). `V3HeroField` paints two hues, the one it is given and
/// one 34 degrees further round, so a gradient has somewhere to travel to.
/// From 206 (the slate blue of the Breathe card) the second hue lands on 240,
/// which at the field's lightness is lilac, so the player she opened from a
/// blue card had a purple header. From 106 the movement field's second hue is
/// 138, still green, which is why only breath showed it. Starting at 186 puts
/// both stops (186 and 220) inside the blue family and centred on the card's
/// 206. Cards, rings and buttons still use [kTtcBreatheHue].
const double kTtcBreatheFieldHue = 186;

/// The Getting ready door, where food is taught (the bracket id).
const String kTtcGettingReadyDoorId = 'ttc_preconception_health';

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
        // The breath field's hue (MB13, 2026-09-28). Kept for revert:
        //   hue: kTtcBreatheHue,
        hue: kTtcBreatheFieldHue,
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

          // Sentence case (tools pass, 2026-09-27). Kept for revert:
          //   "TODAY'S MOVEMENT", "TODAY'S BREATH OR CALM",
          //   'AND ONE THING TOGETHER', 'AND TWO SMALL THINGS'
          _inset(_label("Today's movement", p)),
          // 12 under a heading, the door's rhythm (2026-09-27; was 10).
          const SizedBox(height: 12),
          _inset(_PracticeBlock(practice: move, hue: kTtcMoveHue, p: p)),

          // 24, the door's gap between blocks (2026-09-27; was 22).
          const SizedBox(height: 24),
          // "Today's breath", the Sanskar's own name for the same card (MB18,
          // 2026-09-28: one picker, so one name). Kept for revert:
          //   _inset(_label("Today's breathing", p)),
          _inset(_label("Today's breath", p)),
          const SizedBox(height: 12),
          _inset(
              _PracticeBlock(practice: breathe, hue: kTtcBreatheHue, p: p)),

          // ⚠️ THE COUPLE PART IS SHOWN ONLY IF SHE ASKED FOR IT IN SESSION 8.
          // It is not a third practice and does not get a block — it is a line
          // she chose to be reminded of, and the brief offers "or neither".
          if (TtcGarbhCourseStore.instance.couple case final part?) ...[
            const SizedBox(height: 24),
            _inset(_label('One thing together', p)),
            const SizedBox(height: 12),
            _inset(_CouplePart(part: part, p: p)),
          ],

          const SizedBox(height: 24),
          _inset(_label('Two small things', p)),
          // 6 under a serif heading before its one-line intro (was 4).
          const SizedBox(height: 6),
          // Why these two are here, in one line (tools pass, 2026-09-27).
          _inset(Text(
              'Two small habits that make the rest easier. Tick them when '
              "they're done.",
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2))),
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

  // Sentence-case labels read at 14 with no tracking (2026-09-27); the old
  // style was 10.5 with 1.4 letter spacing, for capitals.
  //
  // ⚠️ THE DOOR'S ONE HEADING STYLE (door pass, 2026-09-27). Inside the Mind
  // & body door this panel is a tab like any other, and a small bold sans
  // heading here beside the serif headings on every other tab read as a
  // random font (the user: "maintain consistency ... don't add random
  // fonts"). The same numbers as `ttcDoorHeadingStyle` in
  // doors/ttc_door_screen.dart, copied rather than imported so a tool body
  // does not import the door that renders it. Kept for revert:
  //   pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)
  static Widget _label(String s, V2Palette p) => Text(s,
      style: pvFraunces(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.45,
          color: p.ink1));
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
  // Unused since the art left the card (2026-09-28); kept for revert.
  // ignore: unused_element
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
          // ⚠️ NO ART BEHIND THE WORDS (the user, 2026-09-28: the basics of
          // placement inside these cards). The 132pt faded figure sat under
          // the time and place line. Headspace and Calm keep a practice card's
          // text on a clean ground (https://mobbin.com/screens/d05b1798-9389-4073-999b-693b84cca19e);
          // the card's colour already says Move or Breathe. Kept for revert:
          //   Positioned(right: -18, bottom: -14, child: Icon(_mark, size: 132,
          //       color: Colors.white.withValues(alpha: 0.42))),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⚠️ NO KIND CHIP (launch sanity MB6 and MB2, 2026-09-28).
                  // The heading above each card already says "Today's
                  // movement" or "Today's breath"; a "Move" chip inside said it
                  // a second time, and its seated-meditator icon showed
                  // meditation on a card about neck rolls. Headspace's Today
                  // cards carry a title, one line and the action, nothing
                  // naming the section again
                  // (https://mobbin.com/screens/efc82d96-660f-4e91-bff9-1f3d083c34eb).
                  // Kept for revert, the chip that led the row:
                  //   _Chip(
                  //       label: practice.kind == TtcPracticeKind.move
                  //           ? 'Move' : 'Breathe',
                  //       icon: practice.kind == TtcPracticeKind.move
                  //           ? Icons.self_improvement_rounded
                  //           : Icons.air_rounded,
                  //       fg: deep,
                  //       bg: Colors.white.withValues(alpha: 0.82)),
                  //   const Spacer(),
                  //
                  // ⚠️ DONE IS A CHIP THAT SAYS SO, NOT A TICK IN A CORNER. A
                  // bare check mark on a coloured block reads as a selection
                  // control — something you are being asked to set — which is
                  // exactly backwards on a card recording what already
                  // happened.
                  if (done) ...[
                    _Chip(
                        label: 'Done today',
                        icon: Icons.check_rounded,
                        fg: Colors.white,
                        bg: deep.withValues(alpha: 0.92)),
                    const SizedBox(height: 14),
                  ],
                  // 18, under the 21 of the heading above it now that the
                  // heading is serif too (2026-09-27): a card title the same
                  // size as its section heading flattens the hierarchy.
                  // Kept for revert: 21.
                  Text(practice.title,
                      style: pvFraunces(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.18,
                          letterSpacing: -0.4,
                          color: p.ink1)),
                  const SizedBox(height: 6),
                  // Room for the whole blurb: the block is full width and the
                  // blurb is two lines by construction in the library.
                  Text(practice.blurb,
                      style: pvManrope(
                          fontSize: 13.5, height: 1.5, color: p.ink2)),
                  const SizedBox(height: 10),
                  // ⚠️ ONE QUIET LINE FOR TIME AND PLACE (2026-09-28): two bold
                  // coloured lines with icons made four text styles in one
                  // card. The card's own wording, unformatted, as before.
                  Text('${practice.duration} · ${practice.setting}',
                      maxLines: 2,
                      style: pvManrope(
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: p.ink3)),
                  const SizedBox(height: 16),
                  // Kept for revert (2026-09-28): the icon row below.
                  // ignore: dead_code
                  if (false) Row(children: [
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
                  // ⚠️ A BUTTON, NOT A LINE OF BOLD TEXT (2026-09-28): an ink
                  // pill says "press me" the way every other action in the app
                  // does. Kept for revert: Row(Text('Start', w800), arrow icon).
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 9, 12, 9),
                    decoration: BoxDecoration(
                      color: p.ink1,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(done ? 'Do it again' : 'Start',
                          style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: Colors.white),
                    ]),
                  ),
                  // ⚠️ WHAT "START" LEADS TO, SAID BEFORE THE TAP (tools pass,
                  // 2026-09-27). She had to go in to find out it is a guided
                  // page, and that the "Done today" chip comes from a button
                  // at its end.
                  // The help line went with the button (2026-09-28): the
                  // player says what to do on its own page. Kept for revert.
                  // ignore: dead_code
                  if (false && !done) ...[
                    const SizedBox(height: 4),
                    Text(
                        'Opens the steps and a timer. Tap "Mark done today" '
                        'at the end.',
                        style: pvManrope(
                            fontSize: 12, height: 1.45, color: p.ink2)),
                  ],
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
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: fg)),
        ]),
      );
}

// =============================================================================
//  The strip that says whose practice this is
// =============================================================================

class _YourPracticeStrip extends StatelessWidget {
  const _YourPracticeStrip({required this.p});
  final V2Palette p;

  /// Back to a different card each day, said out loud with a way back
  /// (the user's rule: tell her before anything changes). Until 2026-09-28 a
  /// tap on the bold line cleared her session 8 choice silently.
  void _clear(BuildContext context) {
    final store = TtcGarbhCourseStore.instance;
    final move = store.moveId;
    final breathe = store.breatheId;
    final couple = store.couple;
    store.clearDailyPractice();
    pvSnack(context, 'Today now shows a different practice each day.',
        icon: Icons.check_rounded,
        action: 'Undo',
        onAction: () => store.setDailyPractice(
            moveId: move, breatheId: breathe, couple: couple),
        lift: 24);
  }

  // ⚠️ THE CARD FAMILY'S SHAPE, AND A BUTTON FOR THE WAY BACK (2026-09-28).
  // It was a 16pt strip with an icon and a line of bold coloured text as the
  // action, a text link the user's pass rules out. Now the family's radius
  // and padding, one sentence, and a white pill that says what it does, as
  // Noom's "Today's plan" puts a small pill on a row
  // (https://mobbin.com/screens/1368bd6c-14cf-4d22-abd9-c429c529443c).
  // The strip as it was is `_buildStrip`, kept for revert.
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: kTtcCardPad,
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(kTtcCardRadius),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('You picked this practice in the free preconception course.',
              style: ttcCardBody(p)),
          const SizedBox(height: 12),
          TtcQuietPill(
            label: 'Show a different practice each day',
            icon: Icons.shuffle_rounded,
            onTap: () => _clear(context),
          ),
        ]),
      );

  // Kept for revert (2026-09-28). Nothing calls it.
  // ignore: unused_element
  Widget _buildStrip(BuildContext context) => Container(
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
                  // Kept for revert (2026-09-27): 'The practice you built in
                  // session eight.' Someone who came from a link does not know
                  // what session eight is.
                  Text(
                      'You picked this practice in the free preconception '
                      'course.',
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
                    child: Text('Show a different practice each day instead',
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

    // ⚠️ THE SAME CARD AS THE TWO PRACTICES ABOVE IT (2026-09-28). It was a
    // white bordered box with a 16.5 title and a 12.5 body, the one card on
    // Today in a different shape. Now the family's tint, padding and type,
    // with a "Together" chip where the practices say Move or Breathe, in the
    // colour the home's Sanskar gives the same part (`ttcRitualPartHue`), so
    // gratitude is one colour wherever she meets it. No button: it is a line
    // to say to each other, and there is nothing to open.
    // Kept for revert: Container(padding: all(15), surface, radius 18,
    //   border p.line; title pvFraunces 16.5; blurb pvManrope 12.5).
    final tint = v2BlockTint(
        ttcRitualPartHue(part == TtcCoupleDaily.gratitude
            ? TtcRitualPart.gratitude
            : TtcRitualPart.conversation),
        p);
    return Container(
      width: double.infinity,
      padding: kTtcCardPad,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(kTtcCardRadius),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TtcCardChip(
            label: 'Together',
            icon: Icons.people_outline_rounded,
            fg: ttcCardDeep(tint),
            bg: Colors.white.withValues(alpha: 0.82)),
        const SizedBox(height: 14),
        Text(title, style: ttcCardTitle(p)),
        const SizedBox(height: 6),
        Text(blurb, style: ttcCardBody(p)),
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

    // The family's radius (2026-09-28; was 18) so the panel lines up with the
    // cards above it. It stays white with a hairline: it is a checklist, not a
    // practice, and Noom's "Today's plan" keeps its ticks on a plain ground
    // (https://mobbin.com/screens/1368bd6c-14cf-4d22-abd9-c429c529443c).
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(kTtcCardRadius),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        _Tick(
          p: p,
          field: kTtcBedtimeField,
          label: bed == null ? 'In bed by about eleven' : 'In bed by about $bed',
          blurb: "Roughly is fine. You don't have to be strict about it.",
          // ⚠️ THE TIME IS CHANGEABLE HERE (tools pass, 2026-09-27). It could
          // only be set in session 5 of the course, which most people never
          // open, so "eleven" read as a rule she was already failing. The
          // same store field the course writes, so both stay in step.
          action: bed == null ? 'Pick your own time' : 'Change time',
          onAction: () => _pickBedtime(context, bed),
        ),
        // Indented to the card's 18 with the rows (2026-09-28; was 15).
        Divider(height: 1, thickness: 1, color: p.line, indent: 18, endIndent: 18),
        _Tick(
          p: p,
          field: kTtcHomeCookedField,
          label: 'Home-cooked meals today',
          // ⚠️ IT DOES NOT TEACH FOOD, AND THAT IS A BOUNDARY THE BRIEF SETS:
          // this area "references Getting ready, does not own or teach food".
          // So the tick records the fact and says nothing about what to eat.
          // ⚠️ "GETTING READY" IS A PILL THAT GOES THERE (launch sanity MB8,
          // 2026-09-28). The blurb named another door she could not tap. Now
          // the words say what counts and the pill opens the Getting ready
          // door on its Diet tab, the same quiet pill as the bedtime's. Kept
          // for revert:
          //   blurb: 'Mostly home-cooked counts. What to eat is in Getting '
          //       'ready.',
          blurb: 'Mostly home-cooked counts.',
          action: 'What to eat, in Getting ready',
          actionIcon: Icons.restaurant_outlined,
          onAction: () => openTtcDoor(context, kTtcGettingReadyDoorId,
              initialGroup: 'diet'),
        ),
      ]),
    );
  }
}

/// Opens a clock at her bedtime (or eleven) and saves only what she picks. A
/// cancelled clock changes nothing.
Future<void> _pickBedtime(BuildContext context, String? current) async {
  TimeOfDay start = const TimeOfDay(hour: 23, minute: 0);
  final parts = (current ?? '').split(':');
  if (parts.length == 2) {
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h != null && m != null) start = TimeOfDay(hour: h, minute: m);
  }
  final t = await showTimePicker(context: context, initialTime: start);
  if (t == null) return;
  TtcGarbhCourseStore.instance.setTimes(
      bed: '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}');
}

class _Tick extends StatelessWidget {
  const _Tick(
      {required this.p,
      required this.field,
      required this.label,
      required this.blurb,
      this.action,
      this.actionIcon = Icons.schedule_rounded,
      this.onAction});

  final V2Palette p;
  final String field;
  final String label;
  final String blurb;

  /// An optional small link under the blurb (the bedtime's "Change time").
  final String? action;

  /// The pill's icon. The bedtime's clock by default.
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final on = ttcHabitTicked(field);

    // ⚠️ ONE EDGE, TWO TEXT STYLES, A BUTTON FOR THE TIME (2026-09-28). The
    // row's inset is the card family's 18 (was 15), the hint is the family's
    // body colour rather than a third grey, and "Change time" is a small white
    // pill instead of a line of bold coloured text.
    return InkWell(
      onTap: () => ttcSetHabitTick(field, !on),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
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
                          fontSize: 12.5, height: 1.5, color: p.ink2)),
                  if (action != null && onAction != null) ...[
                    const SizedBox(height: 10),
                    TtcQuietPill(
                        label: action!,
                        icon: actionIcon,
                        onTap: onAction!),
                  ],
                  // Kept for revert (2026-09-28): the action as bold text.
                  // ignore: dead_code
                  if (false && action != null && onAction != null)
                    // ignore: dead_code
                    GestureDetector(
                      onTap: onAction,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 2),
                        child: Text(action!,
                            style: pvManrope(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: p.action)),
                      ),
                    ),
                ]),
          ),
        ]),
      ),
    );
  }
}
