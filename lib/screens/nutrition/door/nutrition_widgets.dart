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
import '../../../data/nutrition/nutrition_plate.dart' show kPlateNeeds;
import '../../../data/nutrition/food_values.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../brackets/hub/hub_intent_art.dart';
import '../../can_i/can_i_widgets.dart' show CanIPhoto;
import '../../../services/saved_store.dart';
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
    // No photo: the drawn plate in the door's tint, not a fork-and-knife on
    // grey (2026-09-21). `icon` is kept on the signature for revert.
    final well = ColoredBox(
        color: nutritionMarkTint(p),
        child: Center(
            child: SizedBox(
                width: iconSize * 1.5,
                height: iconSize * 1.5,
                child: HubIntentArt(mark: IntentMark.plate, tint: nutritionMarkTint(p)))));
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
class PlateRow extends StatefulWidget {
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
    this.showSwap = true,
    this.photoUrl,
  });
  final V2Palette p;
  final String slot;
  final String items;
  final bool swapped;
  final bool skipped;
  final VoidCallback onTap;
  final VoidCallback onSwap;
  final bool last;

  /// Off on a chart's day (diet_chart_plan_screen.dart): a plan is read,
  /// a plate is acted on. Same row either way.
  final bool showSwap;
  final String? photoUrl;

  @override
  State<PlateRow> createState() => _PlateRowState();
}

class _PlateRowState extends State<PlateRow> with SingleTickerProviderStateMixin {
  /// A wash of the door's tint that rises and fades when the dish CHANGES —
  /// the "some effect going around" the user asked for on a swap
  /// (2026-09-22). Only on a change: a row that flashed on first paint
  /// would flash five times on every open.
  late final AnimationController _flash =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didUpdateWidget(PlateRow old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) _flash.forward(from: 0);
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final items = widget.items;
    final slot = widget.slot;
    final swapped = widget.swapped;
    final skipped = widget.skipped;
    final last = widget.last;
    final showSwap = widget.showSwap;
    final onTap = widget.onTap;
    final onSwap = widget.onSwap;
    final url = widget.photoUrl ?? nutritionPhotoFor(items);
    return InkWell(
      onTap: () {
        pvCommitFeedback();
        onTap();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: skipped ? 0.5 : 1,
        child: AnimatedBuilder(
          animation: _flash,
          builder: (context, child) {
            // Up fast, down slow: 0 → 1 over the first fifth, then out.
            final t = _flash.value;
            final a = t < 0.2 ? t / 0.2 : 1 - (t - 0.2) / 0.8;
            return Container(
              decoration: BoxDecoration(
                  color: nutritionMarkTint(p).withValues(alpha: 0.55 * a.clamp(0, 1)),
                  borderRadius: BorderRadius.circular(14)),
              child: child,
            );
          },
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
                  Flexible(
                    child: Text(slot.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
                  ),
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
                  child: Text(plateName(items),
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
                // The numbers under every meal — the food apps' card line.
                const SizedBox(height: 3),
                NutritionGlanceLine(p: p, values: estimateMeal(items), maxLines: 2),
              ]),
            ),
            if (showSwap) ...[
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
            ],
          ]),
        ),
        ),
      ),
    );
  }
}

/// A need: a ring that fills on tap, a soft burst, the label under it.
/// Nothing turns red; an unticked ring is just a ring.
class NeedTile extends StatefulWidget {
  const NeedTile({super.key, required this.p, required this.label, required this.icon, required this.ticked, required this.onTick, required this.onOpen, this.needId, this.amount});
  final V2Palette p;
  final String label;
  final IconData icon;
  final bool ticked;

  /// The need's id — when set, the drawn mark is used instead of [icon].
  final String? needId;

  /// The day's reference for this need — "27 mg" — as a small line under
  /// the name (2026-09-22). It replaces the paragraph that spelt all five
  /// out in prose above the row; the reference is still one quiet number,
  /// never a bar.
  final String? amount;
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
                // Unticked: the ring in the need's own hue, so the five read
                // as five things before she has tapped any.
                border: Border.all(
                    color: widget.ticked
                        ? p.ink1
                        : widget.needId == null
                            ? p.line
                            : nutritionNeedTint(p, widget.needId!),
                    width: widget.ticked ? 1.4 : 2),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.ticked
                    ? Icon(Icons.check_rounded, key: const ValueKey(true), size: 22, color: p.ground)
                    : widget.needId != null
                        ? Padding(
                            key: const ValueKey(false),
                            padding: const EdgeInsets.all(9),
                            child: nutritionNeedGlyph(p, widget.needId!, size: 26))
                        : Icon(widget.icon, key: const ValueKey(false), size: 22, color: p.ink1),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        Text(widget.label,
            style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: widget.ticked ? p.ink1 : p.ink2)),
        if (widget.amount case final a?) ...[
          const SizedBox(height: 1),
          Text(a, style: pvManrope(fontSize: 10.5, color: p.ink3)),
        ],
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
/// The heart on a recipe photo. White disc, ink outline, filled when saved —
/// the store's own toggle, so the Saved screen and this card stay one truth.
class _SaveHeart extends StatelessWidget {
  const _SaveHeart({required this.p, required this.recipeId, required this.title});
  final V2Palette p;
  final String recipeId;
  final String title;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: SavedStore.instance,
        builder: (context, _) {
          final on = SavedStore.instance.isSaved(SavedKind.recipe, recipeId);
          return Material(
            color: p.ground.withValues(alpha: 0.92),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                pvCommitFeedback();
                SavedStore.instance.toggle(SavedKind.recipe, recipeId, title: title, stage: 'pregnancy');
              },
              child: SizedBox(
                width: 30,
                height: 30,
                child: Icon(on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 16, color: on ? const Color(0xFFC2185B) : p.ink2),
              ),
            ),
          );
        },
      );
}

/// The three marks as white pills, bottom-left on a recipe photo — Blinkit's
/// chip position, in our hand.
///
/// ⚠️ THE DISC IS FOR READABILITY, NOT DECORATION. On white the marks are
/// bare and coloured (the user's call, 2026-09-22 morning); on a photograph
/// a bare mark disappears into whatever is behind it, so each one sits on a
/// near-opaque white disc. Amounts are dropped here — three numbers over a
/// photo is a label, not a glance; they are still on the recipe page.
class _MarkPills extends StatelessWidget {
  const _MarkPills({required this.p, required this.values});
  final V2Palette p;
  final NutritionValues values;

  @override
  Widget build(BuildContext context) {
    final top = nutritionTopThree(values);
    if (top.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < top.length; i++) ...[
        if (i > 0) const SizedBox(width: 5),
        Container(
          width: 26,
          height: 26,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: p.ground.withValues(alpha: 0.92), shape: BoxShape.circle),
          child: nutritionNeedGlyph(p, top[i].$1, size: 16),
        ),
      ],
    ]);
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.p, required this.name, required this.line, required this.url, required this.onTap, this.width = 168, this.values, this.recipeId, this.minutes});
  final V2Palette p;
  final NutritionValues? values;
  final String name;
  final String line;
  final String? url;
  final VoidCallback onTap;
  final double width;

  /// When given, the card carries a save heart on its photo and `SavedKind
  /// .recipe` becomes reachable.
  ///
  /// ⚠️ THIS CLOSED A WIRING GAP, NOT A DESIGN ONE. `SavedKind.recipe` has
  /// existed since the saved-items build and `SavedScreen` renders a Recipes
  /// section — but nothing in the app could put a recipe in it, so the
  /// section could only ever be empty. Blinkit's card (the user, 2026-09-22)
  /// carries a bookmark on every photo, which is where the affordance
  /// belongs: on the thing, not on a page one level in.
  final String? recipeId;

  /// Kitchen minutes. Drawn under the title with a clock, Blinkit's own
  /// position for it (the user, 2026-09-22).
  final int? minutes;

  @override
  Widget build(BuildContext context) => PvPress(
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          // In a grid cell the height is the cell's and the photo takes what
          // the two lines leave; in a rail the photo is 120 and the card is
          // as tall as its words. One card, both homes.
          child: SizedBox(
            width: width,
            child: LayoutBuilder(builder: (context, box) {
              final photo = ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: box.hasBoundedHeight ? null : 120,
                  width: width,
                  child: Stack(fit: StackFit.expand, children: [
                    NutritionPhoto(url: url, p: p, icon: Icons.soup_kitchen_outlined),
                    if (recipeId != null)
                      Positioned(top: 6, right: 6, child: _SaveHeart(p: p, recipeId: recipeId!, title: name)),
                    // ⚠️ THE MARKS RIDE ON THE PHOTO NOW (2026-09-22, second
                    // pass on Blinkit). They were bare marks under the line —
                    // the user's own call that morning — and he revised it on
                    // seeing Blinkit's cards: *"if it makes it look good then
                    // I'm fine with it... the way we were doing it was looking
                    // bad"*. The pill is not decoration: a bare mark on a
                    // photograph is unreadable, so each one gets a white disc,
                    // which is also exactly what Blinkit does with its chips.
                    if (values != null && !values!.isEmpty)
                      Positioned(left: 6, bottom: 6, child: _MarkPills(p: p, values: values!)),
                  ]),
                ),
              );
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (box.hasBoundedHeight) Expanded(child: photo) else photo,
                const SizedBox(height: 8),
                // 14.5, the plate row's size — a recipe name on the grid and a
                // dish name on a chart's day were two sizes for one kind of
                // thing (the user, 2026-09-22).
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
                if (minutes != null) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.schedule_rounded, size: 12.5, color: p.ink3),
                    const SizedBox(width: 4),
                    Text('$minutes mins',
                        style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink2)),
                  ]),
                ],
                const SizedBox(height: 2),
                Text(line, maxLines: 2, overflow: TextOverflow.ellipsis, style: pvManrope(fontSize: 12, height: 1.35, color: p.ink2)),
                // Kept for revert — the marks under the line, before they
                // moved onto the photo (2026-09-22):
                // if (values != null) ...[
                //   const SizedBox(height: 6),
                //   NutritionTopThree(p: p, values: values!, compact: true),
                // ],
              ]);
            }),
          ),
        ),
      );
}

/// The six numbers as a tile grid — "Per serving, estimated" — with the
/// caveat under. The meal sheet, the recipe page and the chart plan all
/// draw this one; Cherrypick's per-serving block, in the base UI.
class NutritionValuesGrid extends StatelessWidget {
  const NutritionValuesGrid({super.key, required this.p, required this.values, this.title = 'Per serving, estimated'});
  final V2Palette p;
  final NutritionValues values;
  final String title;

  @override
  Widget build(BuildContext context) {
    final tiles = nutritionTiles(values);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
      const SizedBox(height: 10),
      GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.55),
        itemCount: tiles.length,
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
              color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
          // Scales down rather than overflowing on a narrow phone (or the
          // test's square glyphs).
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(tiles[i].$2, style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1)),
              const SizedBox(height: 2),
              Text(tiles[i].$1, style: pvManrope(fontSize: 11.5, color: p.ink2)),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(kNutritionEstimateNote, style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3)),
    ]);
  }
}

/// The glance line under a dish: "≈ 320 kcal · 12 g protein · 3 mg iron".
class NutritionGlanceLine extends StatelessWidget {
  const NutritionGlanceLine({super.key, required this.p, required this.values, this.size = 11.5, this.maxLines = 1});
  final V2Palette p;
  final NutritionValues? values;
  final double size;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final v = values;
    if (v == null || v.isEmpty) return const SizedBox.shrink();
    return Text(nutritionGlance(v),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: pvManrope(fontSize: size, fontWeight: FontWeight.w600, height: 1.4, color: p.ink3));
  }
}

/// The five needs' marks — drawn (`IntentMark`), the same hand as the door's
/// rail cards, worn by the ticks, "Strong in", the need pages and the chips.
/// The Material line icons they replaced (spa, local_drink, egg_alt, eco,
/// grass) are kept in `nutritionNeedIcon` for revert.
IntentMark nutritionNeedMark(String id) => switch (id) {
      'iron' => IntentMark.ironMark,
      'calcium' => IntentMark.calciumMark,
      'protein' => IntentMark.proteinMark,
      'folic_acid' => IntentMark.folateMark,
      _ => IntentMark.fibreMark,
    };

/// The door's tint for a mark on a white ground: the Nutrition hue, the
/// same seed the rail cards use. For anything that is NOT a need — the
/// needs wear their own hue (`nutritionNeedTint`).
Color nutritionMarkTint(V2Palette p) => v2BlockTint(104, p);

/// One hue per need — 2026-09-22, the user: "every mark you have used is
/// very green … different nutrients, at least use a different colour."
/// Iron the rust of a spinach stem, calcium the blue of milk's cool,
/// protein the ochre of an egg yolk, folate the green it always was, fibre
/// the wheat gold. The same five hues everywhere a need appears — the ticks,
/// the cards, the legend, the need pages — so a colour becomes a name.
double nutritionNeedHue(String id) => switch (id) {
      'iron' => 344,
      'calcium' => 206,
      'protein' => 26,
      'folic_acid' => 104,
      _ => 42,
    };

/// The need's tint on a white ground.
Color nutritionNeedTint(V2Palette p, String id) => v2BlockTint(nutritionNeedHue(id), p);

/// A need's mark at [size], in its own hue.
Widget nutritionNeedGlyph(V2Palette p, String id, {double size = 24}) =>
    SizedBox(width: size, height: size, child: HubIntentArt(mark: nutritionNeedMark(id), tint: nutritionNeedTint(p, id)));

/// The key to the marks — "what is what". One row, the five marks with
/// their names, for the top of any list that wears them bare (the recipe
/// grid). The user, 2026-09-22: "how is a person able to know what is what?"
class NutritionMarkLegend extends StatelessWidget {
  const NutritionMarkLegend({super.key, required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < kPlateNeeds.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            nutritionNeedGlyph(p, kPlateNeeds[i].id, size: 16),
            const SizedBox(width: 4),
            Text(kPlateNeeds[i].label, style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, color: p.ink2)),
          ],
        ]),
      );
}

/// Kept for revert (2026-09-21): the line icons the needs wore before.
IconData nutritionNeedIcon(String id) => switch (id) {
      'iron' => Icons.spa_outlined,
      'calcium' => Icons.local_drink_outlined,
      'protein' => Icons.egg_alt_outlined,
      'folic_acid' => Icons.eco_outlined,
      _ => Icons.grass_outlined,
    };

/// What a dish is strongest in, as three marks with the amount under each
/// — the pictorial line the user asked for (2026-09-21: "not just pills";
/// "chia seeds: fibre, omega-3, calcium"). Hollow ring, ink mark, the tick's
/// own geometry at 48pt.
class NutritionTopThree extends StatelessWidget {
  const NutritionTopThree({super.key, required this.p, required this.values, this.title = 'Strong in', this.compact = false});
  final V2Palette p;
  final NutritionValues values;
  final String title;

  /// On a grid card: three small wells and the amounts, no title.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final top = nutritionTopThree(values);
    if (compact) {
      // Bare marks in their own hues, no wells (the user, 2026-09-22: on a
      // recipe card "do not use tinted background, just use plain mark, and
      // make it different colours"). Scales down on a narrow card rather
      // than overflowing.
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < top.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            nutritionNeedGlyph(p, top[i].$1, size: 18),
            const SizedBox(width: 4),
            Text(top[i].$3, style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, color: p.ink2)),
          ],
        ]),
      );
    }
    // The tinted well — the door's rail cards and the doctor app's rows put
    // a concept mark in one; the tick keeps its ring because it flips to a
    // check.
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
      const SizedBox(height: 12),
      Row(children: [
        for (var i = 0; i < top.length; i++) ...[
          if (i > 0) const SizedBox(width: 22),
          Column(children: [
            nutritionNeedWell(p, top[i].$1, size: 48, radius: 15),
            const SizedBox(height: 8),
            Text(top[i].$3, style: pvFraunces(fontSize: 15, fontWeight: FontWeight.w600, color: p.ink1)),
            const SizedBox(height: 1),
            Text(top[i].$2, style: pvManrope(fontSize: 11.5, color: p.ink2)),
          ]),
        ],
      ]),
    ]);
  }
}

/// Any mark in the door's tinted well — for rows that are not a need.
Widget nutritionMarkWell(V2Palette p, IntentMark mark, {double size = 40, double radius = 12}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: nutritionMarkTint(p), borderRadius: BorderRadius.circular(radius)),
      padding: EdgeInsets.all(size * 0.2),
      child: HubIntentArt(mark: mark, tint: nutritionMarkTint(p)),
    );

/// A need's mark in ITS OWN tinted well — `DoctorArtTile`'s geometry: the
/// tint as the ground, the mark at 60% of the tile.
Widget nutritionNeedWell(V2Palette p, String id, {double size = 48, double radius = 15}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: nutritionNeedTint(p, id), borderRadius: BorderRadius.circular(radius)),
      padding: EdgeInsets.all(size * 0.2),
      child: HubIntentArt(mark: nutritionNeedMark(id), tint: nutritionNeedTint(p, id)),
    );
