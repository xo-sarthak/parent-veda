// =============================================================================
//  Door chrome — the sheet, the scaffold and the disclaimer every door shares
// -----------------------------------------------------------------------------
//  ⚠️ SMALL ON PURPOSE. Eight pregnancy doors are coming and each will bring
//  tools of its own; this is the two or three pieces they all need, and nothing
//  else. A chrome file that grows a widget per screen stops being chrome and
//  becomes a second widget library nobody can find anything in.
//
//  The door playbook's rule for a tool wired into a door is: bring it up to the
//  design language. That means a `V3HeroField` behind everything, a sheet
//  sliding over it, a round translucent close button rather than an `AppBar`,
//  and white cards with a hairline rather than a shadow — eight stacked shadows
//  on one scroll is a page that looks like it is hovering.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';

/// How much clearance the foot of a door's scroll leaves.
///
/// ⚠️ THE FAB'S OWN NUMBER, NOT A GUESS. `kAskFabReserve` is what the Ask Veda
/// button reserves for itself, and a hardcoded literal here would be a second
/// opinion about the same gap — wrong the day the button moves.
const double kPvDoorBottomInset = kAskFabReserve;

/// The urgent tint. Coral, never scarlet.
///
/// ⚠️ `danger` IN THIS DESIGN SYSTEM IS FOR DESTRUCTIVE CONFIRMATION, NOT FOR
/// URGENCY. A red block on a screen somebody opened because they are already
/// frightened shouts at them. This earns attention by sitting above everything
/// rather than by being loud, which is also why the pinned flag is at the top
/// of its tab and nowhere else on the door.
const Color kPvUrgentTint = Color(0xFFFFF0F3);
const Color kPvUrgentInk = Color(0xFFFF5A79);

/// The page-wide horizontal gutter. One number, so a rail's peek arithmetic and
/// a paragraph's margin cannot drift apart.
const double kPvDoorGutter = 18;

Widget pvDoorPad(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
    child: child);

/// The white sheet that slides over the hero field.
///
/// ⚠️ A FULL VIEWPORT MINIMUM, AND THAT IS ARITHMETIC RATHER THAN TASTE. A tab
/// showing one short rail leaves the sheet ending early, the list ending with
/// it, and the tinted field showing under the last card. A sheet at least as
/// tall as the screen always reaches the bottom of it, on any device, for any
/// tab — because the hero has already been scrolled past by the time the
/// sheet's foot is reachable.
///
/// ⚠️ AND THE SHEET OWNS THE BOTTOM CLEARANCE, NOT THE LIST. Padding on the
/// enclosing `ListView` sits BELOW the sheet's ground, so scrolling to the end
/// reveals the field through the gap. Whenever a scroll view has a coloured
/// panel inside it, the panel has to be the thing that reaches the bottom.
class PvDoorSheet extends StatelessWidget {
  const PvDoorSheet({
    super.key,
    required this.p,
    required this.children,
    this.minHeightFactor = 1,
  });

  final V2Palette p;
  final List<Widget> children;
  final double minHeightFactor;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height * minHeightFactor),
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
          // The nav pill and the Ask FAB both float over this.
          const SizedBox(height: kPvDoorBottomInset),
        ]),
      );
}

/// The medical disclaimer, at the foot of every door and every door tool.
///
/// ⚠️ EVERY CLINICAL SURFACE CARRIES THIS — CLAUDE.md, "never a diagnosis, and
/// anything clinical ends with a disclaimer". The Scans door holds forty pieces
/// of medical content and would be the worst one to leave it off.
class PvDoorDisclaimer extends StatelessWidget {
  const PvDoorDisclaimer({super.key, required this.p, this.text});

  final V2Palette p;
  final String? text;

  static const String _default =
      'This is general information, not medical advice. Your doctor knows your '
      'pregnancy; if anything here disagrees with them, they are right.';

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
          const SizedBox(width: 9),
          Expanded(
            child: Text(text ?? _default,
                style:
                    pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3)),
          ),
        ],
      );
}

/// The chrome a tool opened from a door wears.
///
/// ⚠️ A ROUND TRANSLUCENT BUTTON, NOT AN `AppBar`. An app bar is a horizontal
/// band of chrome that has to be filled with something, and on a screen whose
/// hero already says where you are it gets filled with the same words twice.
/// The doors themselves have no app bar for the same reason, and a tool that
/// grew one would announce itself as a different kind of screen.
class PvDoorToolScaffold extends StatelessWidget {
  const PvDoorToolScaffold({
    super.key,
    required this.hue,
    required this.eyebrow,
    required this.title,
    required this.intro,
    required this.children,
    this.variant = 2,
    this.action,
  });

  final double hue;

  /// Small, letterspaced, above the title. What this tool is called.
  final String eyebrow;

  /// One Fraunces line. What this screen is.
  final String title;

  /// ⚠️ WHAT IT IS FOR, AND WHAT IT WILL NOT DO, BEFORE THE FIRST INPUT. The
  /// playbook's comprehension rule, and the half people skip is the second one:
  /// a tool that says what it does and not what it does not leaves the reader
  /// to assume the most useful possible answer.
  final String intro;

  final List<Widget> children;
  final int variant;

  /// A pinned action at the foot, over the scroll.
  final Widget? action;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final tint = v2BlockTint(hue % 360, p);

          return Scaffold(
            backgroundColor: p.ground,
            body: Stack(children: [
              Positioned.fill(
                child: V3HeroField(
                    accent: tint,
                    ground: p.ground,
                    variant: variant,
                    chroma: v3FieldChroma(hue)),
              ),
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 22, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Material(
                              color: Colors.white.withValues(alpha: 0.55),
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () =>
                                    Navigator.of(context).maybePop(),
                                child: SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: Icon(Icons.arrow_back_rounded,
                                        size: 19, color: p.ink1)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(eyebrow.toUpperCase(),
                              style: pvManrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: p.ink2)),
                          const SizedBox(height: 8),
                          Text(title,
                              style: pvFraunces(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w600,
                                  height: 1.15,
                                  letterSpacing: -0.6,
                                  color: p.ink1)),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: Text(intro,
                                style: pvManrope(
                                    fontSize: 13.5,
                                    height: 1.55,
                                    color: p.ink2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PvDoorSheet(p: p, minHeightFactor: 0.8, children: [
                    const SizedBox(height: 22),
                    ...children,
                  ]),
                ],
              ),
              if (action case final a?)
                Positioned(left: 0, right: 0, bottom: 0, child: a),
            ]),
          );
        },
      );
}


/// Rail geometry. One set of numbers, so a rail on a door and a rail of one
/// card inside an embedded tool cannot drift apart.
const double kPvRailCardWidth = 142;
const double kPvRailCardHeight = 176;
const double kPvRailGap = 10;

/// One card on a rail, in the door's language.
///
/// ⚠️ THIS IS `_RailCard` PROMOTED, FOR THE SAME REASON `PvDoorRow` WAS: a
/// screen that renders INSIDE a door needs the door's card without holding a
/// `PvDoorTile`. The user's rule on the phone, 2026-09-12: *"it should not be
/// a tile, it should be the card representation we're having"* — said of the
/// reports locker's "Add a report", which is not a tile on a door section but
/// an action inside an embedded tool. Same card, plain values.
class PvDoorRailCard extends StatelessWidget {
  const PvDoorRailCard({
    super.key,
    required this.p,
    required this.hue,
    required this.icon,
    required this.chip,
    required this.title,
    this.meta,
    this.index = 0,
    this.dimmed = false,
    this.onTap,
  });

  final V2Palette p;
  final double hue;
  final IconData icon;

  /// The badge, top-left — "Tool", "Article", "Coming soon".
  final String chip;
  final String title;

  /// One fact above the title, where there is one — a week range, a price.
  final String? meta;

  /// Position in its rail. Each card steps the hue by 22° so a rail reads as
  /// separate blocks rather than one slab.
  final int index;

  /// A coming-soon card: the same card a shade back, and not tappable.
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint((hue + index * 22) % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();

    return InkWell(
      onTap: dimmed ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: dimmed ? 0.62 : 1,
        child: Container(
          width: kPvRailCardWidth,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            // The mark, quiet and large, where an illustration would sit.
            Positioned(
              right: -22,
              bottom: 22,
              child: Icon(icon,
                  size: 96, color: Colors.white.withValues(alpha: 0.34)),
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, size: 10, color: deep),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(chip,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: deep)),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  if (meta case final m?) ...[
                    Text(m.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: deep.withValues(alpha: 0.85))),
                    const SizedBox(height: 4),
                  ],
                  Text(title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.22,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A rail holding one card inside an embedded tool — an action, not a
/// section. Same height and gutter as a door rail so the two line up.
class PvDoorSingleRail extends StatelessWidget {
  const PvDoorSingleRail({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: kPvRailCardHeight,
        child: Align(alignment: Alignment.centerLeft, child: child),
      );
}

/// One full-width row in the door's card language.
///
/// ⚠️ THIS IS `_WideTile` PROMOTED, AND THE REASON IT MOVED HERE IS A SCREEN
/// THAT IS NOT A DOOR. The Complications door renders `ConditionsHomeBody`
/// inline, and that body drew its rows with `SolutionCard` — the pre-V3 hub
/// card, with a hard blue glyph tile and a bare small-caps `READ` floating
/// under the text. Beside the door's own rows it read as a screen from an
/// older version of the app pasted into a new one. Seen on a phone,
/// 2026-09-10.
///
/// ⚠️ SO THE ROW IS THE SHARED THING, NOT THE TILE MODEL. Taking plain values
/// rather than a `PvDoorTile` is what lets a screen that has never heard of the
/// door engine wear its language — an embedded body has `ConditionEntry`s, not
/// tiles, and asking it to build tiles it does not otherwise need would be
/// making the caller adapt to the widget.
///
/// ⚠️ AND THE HUE STAYS THE CALLER'S. `SolutionType.read` is blue on every hub
/// in the app, deliberately — "she learns the colour once". Changing the SHAPE
/// to the door's is what was asked for; changing the colour as well would
/// break a rule that has nothing to do with this.
class PvDoorRow extends StatelessWidget {
  const PvDoorRow({
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

  /// Drives the glyph tile's tint and the chip's ink.
  final double hue;

  final IconData icon;

  /// The small pill under the text — "Article", "Tool", "Coming soon".
  final String chip;

  final String title;
  final String blurb;

  final VoidCallback? onTap;

  /// A coming-soon row: the same row a shade back, and not tappable.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();

    return InkWell(
      // ⚠️ A DIMMED ROW DOES NOT RESPOND TO A TAP. A tap that does nothing
      // teaches that taps do nothing, which spreads doubt to the rows that
      // work.
      onTap: dimmed ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: dimmed ? 0.62 : 1,
        child: PvDoorCard(
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
                  // ⚠️ THE CHIP IS A BORDERED CAPSULE, NOT LOOSE SMALL CAPS.
                  // The old hub card set the type in coloured letters with
                  // nothing around them, which reads as a fourth line of copy;
                  // an outlined pill reads as a label about the row.
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

/// A white card with a hairline. The door's one container.
///
/// ⚠️ A HAIRLINE, NOT A SHADOW, AND IT IS NOT A PREFERENCE. Eight stacked
/// shadows on one scroll is a page that looks like it is hovering; a border is
/// one pixel that says "this is a thing" and then stops competing.
class PvDoorCard extends StatelessWidget {
  const PvDoorCard(
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
