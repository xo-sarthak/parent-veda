// =============================================================================
//  Nutrition door — the pieces
// -----------------------------------------------------------------------------
//  2026-09-20. The door's own language, deliberately not Is it safe?'s:
//  that door judges (a dot, a word); this one nourishes. So no verdict
//  colours, no red anywhere, no counts she can fail. Warm photography, a
//  tick that celebrates, glasses that fill, "not today" always available.
//
//  Mobbin (MOBBIN-DISCOVERY §12): Crouton's day rows for the plate; Noom's
//  "Did it today → Done for today" with a soft squiggle burst for the tick
//  (no streak, no fire icon); Yazio/Noom's row of glasses for water; Atoms'
//  deliberate press for the feel of *doing*.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/nutrition/nutrition_photos.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../can_i/can_i_widgets.dart' show CanIPhoto;
import '../../v2/v2_palette.dart';

/// The door's one photo well: a dish photo, or the slot icon in a neutral
/// well. Reuses the retrying photo from Is it safe? (the hosts are the same).
class NutritionPhoto extends StatelessWidget {
  const NutritionPhoto({super.key, required this.url, required this.p, this.icon = Icons.restaurant_outlined, this.iconSize = 26});
  final String? url;
  final V2Palette p;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final well = ColoredBox(color: p.surfaceAlt, child: Center(child: Icon(icon, size: iconSize, color: p.ink3)));
    return url == null ? well : CanIPhoto(url: url!, fallback: well);
  }
}

/// A section heading in the door's type.
Widget nutritionHeading(V2Palette p, String text, {String? sub, Widget? trailing}) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(text,
                style: pvFraunces(
                    fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.45, color: p.ink1)),
            if (sub != null) ...[
              const SizedBox(height: 4),
              Text(sub, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
            ],
          ]),
        ),
        ?trailing,
      ],
    );

/// One slot on the plate: photo, the slot's name, the dishes, Swap.
class PlateRow extends StatelessWidget {
  const PlateRow({
    super.key,
    required this.p,
    required this.slot,
    required this.items,
    required this.swapped,
    required this.skipped,
    required this.onTap,
    required this.onSwap,
    this.last = false,
  });
  final V2Palette p;
  final String slot;
  final String items;
  final bool swapped;
  final bool skipped;
  final VoidCallback onTap;
  final VoidCallback onSwap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final url = nutritionPhotoFor(items);
    return InkWell(
      onTap: () {
        pvCommitFeedback();
        onTap();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: skipped ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: p.line))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(width: 72, height: 72, child: NutritionPhoto(url: url, p: p)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(slot.toUpperCase(),
                      style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
                  if (swapped) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.swap_horiz_rounded, size: 13, color: p.ink3),
                  ],
                  if (skipped) ...[
                    const SizedBox(width: 8),
                    Text('not today', style: pvManrope(fontSize: 10, fontWeight: FontWeight.w700, color: p.ink3)),
                  ],
                ]),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(items,
                      key: ValueKey(items),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: p.ink1,
                          decoration: skipped ? TextDecoration.lineThrough : null)),
                ),
              ]),
            ),
            const SizedBox(width: 10),
            PvPress(
              child: Material(
                color: p.surface,
                shape: StadiumBorder(side: BorderSide(color: p.line)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    pvCommitFeedback();
                    onSwap();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Swap', style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink1)),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A need: a ring that fills on tap, a soft burst, the label under it.
/// Nothing turns red; an unticked ring is just a ring.
class NeedTile extends StatefulWidget {
  const NeedTile({super.key, required this.p, required this.label, required this.icon, required this.ticked, required this.onTick, required this.onOpen});
  final V2Palette p;
  final String label;
  final IconData icon;
  final bool ticked;
  final VoidCallback onTick;
  final VoidCallback onOpen;

  @override
  State<NeedTile> createState() => _NeedTileState();
}

class _NeedTileState extends State<NeedTile> with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 620));

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _tap() {
    if (!widget.ticked) {
      HapticFeedback.mediumImpact();
      _burst.forward(from: 0);
    } else {
      HapticFeedback.selectionClick();
    }
    widget.onTick();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return GestureDetector(
      onTap: _tap,
      onLongPress: () {
        pvCommitFeedback();
        widget.onOpen();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // 58 wide: five across a 360-dp phone inside the 18-pt gutters with
        // room to breathe (64 left them flush).
        SizedBox(
          width: 58,
          height: 58,
          child: Stack(alignment: Alignment.center, children: [
            AnimatedBuilder(
              animation: _burst,
              builder: (_, _) => CustomPaint(size: const Size(58, 58), painter: _BurstPainter(_burst.value, p.ink1)),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              width: widget.ticked ? 50 : 46,
              height: widget.ticked ? 50 : 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.ticked ? p.ink1 : p.surface,
                border: Border.all(color: widget.ticked ? p.ink1 : p.line, width: 1.4),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(widget.ticked ? Icons.check_rounded : widget.icon,
                    key: ValueKey(widget.ticked), size: 22, color: widget.ticked ? p.ground : p.ink1),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        Text(widget.label,
            style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: widget.ticked ? p.ink1 : p.ink2)),
      ]),
    );
  }
}

/// Six short strokes flying out and fading — Noom's squiggles, in ink.
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final c = size.center(Offset.zero);
    final ease = Curves.easeOutCubic.transform(t);
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - t) * 0.9)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 + 0.3;
      final r1 = 23 + 12 * ease;
      final r2 = r1 + 6 * (1 - ease);
      canvas.drawLine(c + Offset(math.cos(a) * r1, math.sin(a) * r1), c + Offset(math.cos(a) * r2, math.sin(a) * r2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}

/// Eight glasses. Tap one to fill up to it; tap the last filled to empty it.
class GlassesRow extends StatelessWidget {
  const GlassesRow({super.key, required this.p, required this.filled, required this.total, required this.onTap});
  final V2Palette p;
  final int filled;
  final int total;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < total; i++)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(i);
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 34,
                height: 44,
                child: CustomPaint(painter: _GlassPainter(filled: i < filled, p: p)),
              ),
            ),
        ],
      );
}

class _GlassPainter extends CustomPainter {
  _GlassPainter({required this.filled, required this.p});
  final bool filled;
  final V2Palette p;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // A tumbler: slightly narrower at the base.
    final path = Path()
      ..moveTo(w * 0.12, h * 0.08)
      ..lineTo(w * 0.88, h * 0.08)
      ..lineTo(w * 0.78, h * 0.94)
      ..lineTo(w * 0.22, h * 0.94)
      ..close();
    if (filled) {
      final water = Path()
        ..moveTo(w * 0.17, h * 0.36)
        ..lineTo(w * 0.83, h * 0.36)
        ..lineTo(w * 0.78, h * 0.94)
        ..lineTo(w * 0.22, h * 0.94)
        ..close();
      canvas.drawPath(water, Paint()..color = const Color(0xFF9CC9E8));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = filled ? p.ink1 : p.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GlassPainter old) => old.filled != filled;
}

/// An ink chip with an optional leading widget — the door's chip.
class NutritionChip extends StatelessWidget {
  const NutritionChip({super.key, required this.label, required this.p, required this.onTap, this.selected = false, this.leading});
  final String label;
  final V2Palette p;
  final VoidCallback onTap;
  final bool selected;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => PvPress(
        child: Material(
          color: selected ? p.ink1 : p.surface,
          shape: StadiumBorder(side: BorderSide(color: selected ? p.ink1 : p.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              onTap();
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(leading == null ? 14 : 10, 8, 14, 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (leading != null) ...[leading!, const SizedBox(width: 7)],
                Text(label,
                    style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? p.ground : p.ink1)),
              ]),
            ),
          ),
        ),
      );
}

/// A recipe card for a rail: photo, name, one line, minutes-free.
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.p, required this.name, required this.line, required this.url, required this.onTap, this.width = 168});
  final V2Palette p;
  final String name;
  final String line;
  final String? url;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) => PvPress(
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: width,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(height: 120, width: width, child: NutritionPhoto(url: url, p: p, icon: Icons.soup_kitchen_outlined)),
              ),
              const SizedBox(height: 8),
              Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
              const SizedBox(height: 2),
              Text(line, maxLines: 2, overflow: TextOverflow.ellipsis, style: pvManrope(fontSize: 12, height: 1.35, color: p.ink2)),
            ]),
          ),
        ),
      );
}
