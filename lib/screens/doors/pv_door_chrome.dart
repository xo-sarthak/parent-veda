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
