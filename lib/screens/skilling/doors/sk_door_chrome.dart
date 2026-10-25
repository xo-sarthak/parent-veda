// =============================================================================
//  Skilling door chrome — the sheet, the row, the card, the disclaimer
// -----------------------------------------------------------------------------
//  ⚠️ MIRRORS `lib/screens/post_pregnancy/doors/pp_door_chrome.dart` VALUE
//  FOR VALUE, which itself mirrors the pregnancy chrome. Neither is imported
//  — both are open in other terminals — so every number here is theirs, and
//  a skilling door beside a parenting door is the same sheet, the same
//  gutter, the same hairline card. If one of these values moves there, it
//  moves here.
//
//  The one line that is skilling's own is the disclaimer: not a doctor, but
//  the door's promise about the future — that it makes none.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/doors/sk_door_data.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../../widgets/pv_feedback.dart';
import '../../ttc/doors/ttc_tab_art.dart';
import '../../ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import '../../v2/v2_palette.dart';

// =============================================================================
//  THE HOUSE LOOK, 2026-10-25
// -----------------------------------------------------------------------------
//  The user, on the skilling doors: "skilling right now doesn't look like
//  it's from the ParentVeda app". The shell was made before the house passes
//  (base UI, no lavender, the TTC door format) and never had them. What
//  follows brings it level with the parenting and pregnancy doors, mirrored
//  BY VALUE rather than imported: `PvDoorRail` and `PvShelfCard` read the
//  pregnancy door data, and the skilling stage is kept apart from the other
//  stages' engines on purpose. `test/sk_house_look_test.dart` holds the
//  numbers equal so the copies cannot drift. Approved on the prototype
//  (claude.ai/artifact/GQdX4MLR4aCv4tSmqBVncb).
// =============================================================================

/// The house's tint set: the hues the other three stages paint with.
/// Skilling's doors were written with violet, purple and pink tabs (268,
/// 288, 320, 344); the house look keeps colour off that end of the wheel
/// (no lavender, no pink-purple; DESIGN-SYSTEM §4.0).
const List<double> kSkHouseHues = [26, 42, 160, 186, 206, 232, 128, 12];

bool _offHouse(double h) {
  final x = h % 360;
  return x >= 250 && x <= 350;
}

/// The hue a door paints, one per tab, in the house set. A tab already on a
/// house hue keeps it; a violet, purple or pink one takes the first house hue
/// no other tab on the door uses, so two tabs never share a colour. The door
/// data keeps its own numbers (kept for revert); only the paint moves.
List<double> skHouseHues(List<double> hues) {
  final used = <double>{for (final h in hues) if (!_offHouse(h)) h % 360};
  return [
    for (final h in hues)
      if (!_offHouse(h))
        h % 360
      else
        () {
          final pick = kSkHouseHues.firstWhere((c) => !used.contains(c),
              orElse: () => 186);
          used.add(pick);
          return pick;
        }(),
  ];
}

/// One hue, alone (a bracket's, a closing row's).
double skHouseHue(double h) => _offHouse(h) ? 186 : h % 360;

/// The drawn mark for a skilling tab: the TTC family's objects, the same
/// marks the parenting and pregnancy rails draw. Keyed on the tab's id, with
/// a fallback on its kind, so a new door draws something sensible before it
/// is given its own.
TtcTabMark skTabMarkFor(SkDoorTab t) => switch (t.id) {
      // Coding
      'today' => TtcTabMark.sun,
      'things_to_do' => TtcTabMark.checklist,
      'ai' => TtcTabMark.magnifier,
      'made_and_tried' => TtcTabMark.sprout,
      // Communication
      'say_it_out_loud' => TtcTabMark.twoBubbles,
      'tell_and_explain' => TtcTabMark.flagPath,
      'say_what_you_think' => TtcTabMark.signpost,
      'your_voice' => TtcTabMark.heartHand,
      // Confidence
      'use_your_voice' => TtcTabMark.sunrise,
      'stand_up_and_say_it' => TtcTabMark.flagPath,
      'give_a_real_talk' => TtcTabMark.twoFigures,
      'hear_yourself_back' => TtcTabMark.twoBubbles,
      'your_talks' => TtcTabMark.heartHand,
      // Thinking
      'ask_lots_of_whys' => TtcTabMark.magnifier,
      'work_out_how_it_works' => TtcTabMark.checklist,
      'think_for_yourself' => TtcTabMark.signpost,
      'you_kept_thinking' => TtcTabMark.sprout,
      // Stillness
      'breathe_and_wiggle' => TtcTabMark.sunrise,
      'sit_and_settle' => TtcTabMark.lotus,
      'find_your_calm' => TtcTabMark.heartHand,
      'quiet_moments' => TtcTabMark.sprout,
      // Feelings
      'name_what_you_feel' => TtcTabMark.cloudRain,
      'handle_the_big_feelings' => TtcTabMark.hotBottle,
      'find_your_way_through' => TtcTabMark.windingPath,
      'your_journal' => TtcTabMark.openBook,
      'you_practised' => TtcTabMark.sprout,
      // Making
      'just_make_it' => TtcTabMark.tulip,
      'make_it_yours' => TtcTabMark.sunrise,
      'make_something_real' => TtcTabMark.flagPath,
      'prompts' => TtcTabMark.magnifier,
      'your_portfolio' => TtcTabMark.heartHand,
      _ => switch (t.kind) {
          SkTabKind.today => TtcTabMark.sun,
          SkTabKind.activities => TtcTabMark.checklist,
          SkTabKind.lessons => TtcTabMark.openBook,
          SkTabKind.crossBand => TtcTabMark.magnifier,
          SkTabKind.keepsake => TtcTabMark.heartHand,
          SkTabKind.pages => TtcTabMark.openBook,
        },
    };

/// Lessons on a door whose band tabs already use the book draw two bubbles
/// instead (Feelings' lessons are conversations).
TtcTabMark skTabMarkOn(SkDoor door, SkDoorTab t) =>
    door.doorId == 'skilling_feelings' && t.id == 'lessons'
        ? TtcTabMark.twoBubbles
        : t.id == 'lessons'
            ? TtcTabMark.openBook
            : skTabMarkFor(t);

/// How much clearance the foot of a door's scroll leaves — the FAB's own
/// number, not a guess.
const double kSkDoorBottomInset = kAskFabReserve;

/// The urgent tint. Coral, never scarlet — see the pregnancy chrome for why.
const Color kSkUrgentTint = Color(0xFFFFF0F3);
const Color kSkUrgentInk = Color(0xFFFF5A79);

/// The page-wide horizontal gutter. One number, so a rail's peek arithmetic
/// and a paragraph's margin cannot drift apart.
const double kSkDoorGutter = 18;

Widget skDoorPad(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: kSkDoorGutter),
    child: child);

/// The white sheet that slides over the hero field. A full viewport minimum,
/// and the sheet owns the bottom clearance — see the pregnancy file's note on
/// why a list's bottom padding shows the field through the gap.
class SkDoorSheet extends StatelessWidget {
  const SkDoorSheet(
      {super.key, required this.p, required this.children, this.minHeight = 0});

  final V2Palette p;
  final List<Widget> children;

  /// A floor while the header's search is active (`pvLiveSearchSheetMin`),
  /// so the field can ride to the top over a short list of results.
  final double minHeight;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
            minHeight: minHeight > MediaQuery.sizeOf(context).height
                ? minHeight
                : MediaQuery.sizeOf(context).height),
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...children,
          const SizedBox(height: kSkDoorBottomInset),
        ]),
      );
}

/// The disclaimer at the foot of every skilling door.
///
/// The parenting wording names her child's doctor; this names the one thing
/// the stage promises, which is nothing about her future. Same shape, same
/// type, same place.
class SkDoorDisclaimer extends StatelessWidget {
  const SkDoorDisclaimer({super.key, required this.p, this.text});

  final V2Palette p;
  final String? text;

  static const String _default =
      'This teaches a way of thinking and keeps what she tried. It measures '
      'nothing, ranks no one, and promises nothing about who she will become.';

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
          const SizedBox(width: 9),
          Expanded(
            child: Text(text ?? _default,
                style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3)),
          ),
        ],
      );
}

/// One full-width row in the door's card language. Plain values, so a tool
/// row, a pinned page and a closing offer all wear it without a tile model.
class SkDoorRow extends StatelessWidget {
  const SkDoorRow({
    super.key,
    required this.p,
    required this.hue,
    required this.icon,
    required this.chip,
    required this.title,
    required this.blurb,
    this.onTap,
    this.dimmed = false,
  });

  final V2Palette p;
  final double hue;
  final IconData icon;
  final String chip;
  final String title;
  final String blurb;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();

    return InkWell(
      onTap: dimmed ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: dimmed ? 0.62 : 1,
        child: SkDoorCard(
          p: p,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: deep),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: pvFraunces(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                  const SizedBox(height: 4),
                  Text(blurb,
                      style: pvManrope(
                          fontSize: 13, height: 1.45, color: p.ink2)),
                  const SizedBox(height: 9),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: p.ground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: p.line),
                    ),
                    child: Text(chip,
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: p.ink3)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (!dimmed)
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
//  SkDoorRail — `PvDoorRail`, by value
// -----------------------------------------------------------------------------
//  The flat rail of white tab cards that sits across the seam between the
//  photograph and the sheet. Replaces `SkDoorCarousel` (the coverflow deck,
//  kept for revert in its own file). 150 wide, 112 tall (grown with the text
//  size, never shrinking the name), radius 18, the page hairline, an ink ring
//  on the open tab, a 38 drawn mark, the name at 14, a chevron. A tab she has
//  not reached carries "For later"-style one line (the age it opens) and a
//  smaller mark, as the parenting rail does.
// =============================================================================

const Key kSkDoorRailKey = ValueKey('sk-door-rail');
Key skDoorRailCardKey(int i) => ValueKey('sk-door-rail-$i');

class SkDoorRail extends StatefulWidget {
  const SkDoorRail({
    super.key,
    required this.door,
    required this.tabs,
    required this.hues,
    required this.lines,
    required this.selected,
    required this.p,
    required this.onPick,
  });

  final SkDoor door;
  final List<SkDoorTab> tabs;

  /// One house hue per tab ([skHouseHues]).
  final List<double> hues;

  /// One line per tab, empty for none: the age a locked tab opens.
  final List<String> lines;
  final int selected;
  final V2Palette p;
  final ValueChanged<int> onPick;

  static const double cardWidth = 150;
  static const double cardHeight = 112;
  static const double markSize = 38;
  static const double overlap = 40;

  /// `PvDoorRail.heightFor`, the same arithmetic.
  static double heightFor(TextScaler scaler, {bool withLine = false}) {
    final name = scaler.scale(14) * 1.2 * 2;
    final line = withLine ? 3 + scaler.scale(12) * 1.4 : 0.0;
    final mark = withLine ? 28.0 : markSize;
    final need = 24 + 2 + mark + 6 + name + line;
    return need > cardHeight ? need.ceilToDouble() : cardHeight;
  }

  static double heightOf(BuildContext context, List<String> lines) => heightFor(
      MediaQuery.textScalerOf(context),
      withLine: lines.any((l) => l.isNotEmpty));

  @override
  State<SkDoorRail> createState() => _SkDoorRailState();
}

class _SkDoorRailState extends State<SkDoorRail> {
  final _ctl = ScrollController();

  @override
  void didUpdateWidget(SkDoorRail old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected && _ctl.hasClients) {
      final x = widget.selected * (SkDoorRail.cardWidth + 10);
      _ctl.animateTo(x.clamp(0.0, _ctl.position.maxScrollExtent),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = SkDoorRail.heightOf(context, widget.lines);
    return SizedBox(
      key: kSkDoorRailKey,
      height: height,
      child: SingleChildScrollView(
        controller: _ctl,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: kSkDoorGutter),
        child: Row(children: [
          for (var i = 0; i < widget.tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            _card(i, height),
          ],
        ]),
      ),
    );
  }

  Widget _card(int i, double height) {
    final p = widget.p;
    final t = widget.tabs[i];
    final on = i == widget.selected;
    final tint = v2BlockTint(widget.hues[i], p);
    final line = i < widget.lines.length ? widget.lines[i] : '';
    final small = line.isNotEmpty;
    return PvPress(
      key: skDoorRailCardKey(i),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (on) return;
          pvCommitFeedback();
          widget.onPick(i);
        },
        child: AnimatedContainer(
          key: ValueKey(height),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: SkDoorRail.cardWidth,
          height: height,
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: on ? p.ink1 : p.line, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TtcMarkLeading(
                tab: skTabMarkOn(widget.door, t),
                tint: tint,
                size: small ? 28 : SkDoorRail.markSize,
              ),
              const Spacer(),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 14,
                              fontWeight: on ? FontWeight.w800 : FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -0.1,
                              color: p.ink1)),
                      if (small) ...[
                        const SizedBox(height: 3),
                        Text(line,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: p.ink3)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  SkShelfCard — `PvShelfCard`, by value
// -----------------------------------------------------------------------------
//  Replaces the tinted 142×176 card with the title printed on colour. 148
//  wide; a 128-tall picture (the tab's drawn mark on its pale ground) with a
//  white badge for what it is; the title at 14 on two lines; one grey line
//  ("Activity · Unplugged", "Activity · Tried", "Lesson · Story frames").
//  Colour lives in the picture only, never under the words.
// =============================================================================

const double kSkShelfCardWidth = 148;
const double kSkShelfPictureHeight = 128;

/// `pvShelfRailHeight`, the same arithmetic.
double skShelfRailHeight(TextScaler s) =>
    (kSkShelfPictureHeight + 8 + s.scale(14) * 1.25 * 2 + 3 + s.scale(12) * 1.3 + 4)
        .ceilToDouble();

Key skShelfCardKey(String title) => ValueKey('sk-shelf-card-$title');

class SkShelfCard extends StatelessWidget {
  const SkShelfCard({
    super.key,
    required this.p,
    required this.hue,
    required this.mark,
    required this.kindIcon,
    required this.title,
    required this.line,
    required this.onTap,
    this.comingSoon = false,
  });

  final V2Palette p;
  final double hue;
  final TtcTabMark mark;

  /// What it is, top left: the kind's own line icon.
  final IconData kindIcon;
  final String title;
  final String line;
  final VoidCallback onTap;
  final bool comingSoon;

  Color get _ground => HSLColor.fromAHSL(1, hue % 360, 0.52, 0.9).toColor();
  Color get _artTint => HSLColor.fromAHSL(1, hue % 360, 0.6, 0.8).toColor();

  @override
  Widget build(BuildContext context) => Semantics(
        button: !comingSoon,
        label: comingSoon ? '$title, coming soon' : '$title, $line',
        excludeSemantics: true,
        child: Opacity(
          opacity: comingSoon ? 0.62 : 1,
          child: PvPress(
            child: InkWell(
              key: skShelfCardKey(title),
              onTap: comingSoon ? null : onTap,
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: kSkShelfCardWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: kSkShelfCardWidth,
                        height: kSkShelfPictureHeight,
                        child: Stack(fit: StackFit.expand, children: [
                          ColoredBox(
                            color: _ground,
                            child: Center(
                              child: FractionallySizedBox(
                                widthFactor: 0.56,
                                heightFactor: 0.56,
                                child: TtcTabArt(mark: mark, tint: _artTint),
                              ),
                            ),
                          ),
                          if (comingSoon)
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.62),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Coming soon',
                                    style: pvManrope(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                            ),
                          Positioned(
                            left: 7,
                            top: 7,
                            child: ExcludeSemantics(
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.10),
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Icon(kindIcon, size: 15, color: p.ink1),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                    const SizedBox(height: 3),
                    Text(line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: p.ink3)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// A white card with a hairline. The door's one container.
class SkDoorCard extends StatelessWidget {
  const SkDoorCard(
      {super.key, required this.p, required this.child, this.padding});

  final V2Palette p;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: child,
      );
}
