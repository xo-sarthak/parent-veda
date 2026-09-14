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

import '../../../theme/pv_fonts.dart';
import '../../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../v2/v2_palette.dart';

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
  const SkDoorSheet({super.key, required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        constraints:
            BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
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
