// =============================================================================
//  ParentVeda Food - shared UI building blocks
// -----------------------------------------------------------------------------
//  Warm, appetising, calm - never a recipe-blog look. Placeholder food images
//  (warm tints), the learning-metadata line (time · age · veg · nutrition
//  highlight), recipe cards and the little veg/non-veg indicator. pp-themed.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_food_data.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../v2/v2_palette.dart';

// Warm, food-friendly tints, varied by seed.
const List<(Color, Color)> _kFoodTints = [
  (Color(0xFFF7E9DE), Color(0xFFFBF2EA)), // peach
  (Color(0xFFF3E9F4), Color(0xFFF9F2FA)), // lavender
  (Color(0xFFFBE7EC), Color(0xFFFDF1F4)), // blush
  (Color(0xFFF3EEDD), Color(0xFFF9F5EB)), // cream
];

// Veg / non-veg indicator colours (the familiar Indian food-safety convention).
const Color _veg = Color(0xFF3E8E4F);
const Color _nonVeg = Color(0xFFB0402E);

/// A warm placeholder food image with a faint utensil motif.
class FoodThumb extends StatelessWidget {
  const FoodThumb({super.key, required this.seed, required this.height, this.width, this.radius = 16, this.child});
  final int seed;
  final double height;
  final double? width;
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tint = _kFoodTints[seed % _kFoodTints.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(children: [
        PpStriped(height: height, width: width, colorA: tint.$1, colorB: tint.$2, border: true),
        Positioned.fill(child: Center(child: Icon(Icons.ramen_dining_outlined, size: height * 0.26, color: Colors.white.withValues(alpha: 0.7)))),
        if (child != null) Positioned.fill(child: child!),
      ]),
    );
  }
}

/// Little veg / non-veg square (bordered), the way an Indian menu marks a dish.
Widget vegDot(bool veg) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(border: Border.all(color: veg ? _veg : _nonVeg, width: 1.4), borderRadius: BorderRadius.circular(3)),
      child: Center(child: Container(width: 5, height: 5, decoration: BoxDecoration(color: veg ? _veg : _nonVeg, shape: BoxShape.circle))),
    );

/// The 3-way India-style diet marker (ported from the old Recipes module onto
/// the merged model): a bordered square with a filled circle (veg), a leaf
/// (vegan) or a triangle (non-veg). Functional iconography, so the colours stay.
Widget foodDietMark(String diet, {double size = 13}) {
  // ⚠️ EGG TAKES THE NON-VEG COLOUR AND ITS OWN SHAPE, WHICH IS HOW THE
  // PACKETS DO IT. An Indian food label marks eggetarian with the brown/red
  // square rather than the green one — it is not vegetarian — but a family
  // that eats eggs needs to tell it apart from chicken at a glance. Colour
  // says "not veg", shape says "which kind", and the two carry different
  // information rather than repeating each other.
  final c = (diet == 'nonveg' || diet == 'egg') ? _nonVeg : _veg;
  final Widget inner;
  if (diet == 'vegan') {
    inner = Icon(Icons.eco, size: size * 0.66, color: c);
  } else if (diet == 'egg') {
    inner = Icon(Icons.egg_outlined, size: size * 0.72, color: c);
  } else if (diet == 'nonveg') {
    inner = Icon(Icons.arrow_drop_up, size: size * 0.98, color: c);
  } else {
    inner = Container(width: size * 0.44, height: size * 0.44, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
  }
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3), border: Border.all(color: c, width: 1.4)),
    child: inner,
  );
}

/// time · age · diet · nutrition highlight.
Widget foodMeta(FoodRecipe r) => Row(children: [
      Icon(Icons.schedule_rounded, size: 12.5, color: ppMuted),
      const SizedBox(width: 4),
      Text('${r.totalMin} min', style: ppBody(11.5, color: ppMuted, w: FontWeight.w600)),
      const SizedBox(width: 8),
      foodDietMark(r.diet),
      const SizedBox(width: 6),
      Expanded(
        child: Text('${r.ageTag}  ·  ${r.highlight}',
            style: ppBody(11.5, color: ppMuted, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ]);

Widget foodSectionHeader(String title, {String? action, VoidCallback? onAction}) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: ppJakarta(18))),
        if (action != null) PvPress(enabled: onAction != null, child: GestureDetector(onTap: onAction, behavior: HitTestBehavior.opaque, child: ppSeeAll(action))),
      ],
    );

Widget nutrientChip(String name) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
      child: Text(name, style: ppBody(11.5, color: ppPurple, w: FontWeight.w700)),
    );

/// A rail card (fixed width).
class FoodRailCard extends StatelessWidget {
  const FoodRailCard({super.key, required this.recipe, required this.onTap, this.width = 210});
  final FoodRecipe recipe;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) => PvPress(child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: width,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FoodThumb(seed: recipe.seed, height: width * 0.6),
            const SizedBox(height: 10),
            Text(recipe.title, style: ppJakarta(14).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            foodMeta(recipe),
          ]),
        ),
      ));
}

/// A wide list card (thumb left, text right). [warm] tints the subtitle for the
/// Sick-mode comfort meals.
class FoodListCard extends StatelessWidget {
  const FoodListCard({super.key, required this.recipe, required this.onTap, this.warm = false});
  final FoodRecipe recipe;
  final VoidCallback onTap;
  final bool warm;

  @override
  Widget build(BuildContext context) => PvPress(child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 118, child: FoodThumb(seed: recipe.seed, height: 84)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recipe.title, style: ppJakarta(14.5).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(ppFill(recipe.subtitle), style: ppBody(12.5, color: warm ? ppPurple : ppSoft, w: warm ? FontWeight.w600 : FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 7),
                foodMeta(recipe),
              ]),
            ),
          ]),
        ),
      ));
}

// =============================================================================
//  The doc-format recipe pieces (2026-10-15, the 7–8 month pilot)
// -----------------------------------------------------------------------------
//  Mobbin, §21 of docs/MOBBIN-DISCOVERY.md: every recipe app leads its card and
//  its page with the dish itself (Blinkit, Noom, NYT Cooking, Kitchen Stories,
//  Lifesum, MyFitnessPal), the bookmark on the photo, the title under it, and
//  one line of time and one fact. These render only for dishes that carry the
//  doc format (FoodRecipe.docFormat); every other dish keeps its shelf card
//  until the user has approved the pilot.
// =============================================================================

/// '7 to 8 mo' -> '7–8 months', '12 mo+' -> '12 months+'. Display only: the
/// tag itself is what ppRecipeAgeRange parses, so it is never rewritten.
String foodAgeLabel(String tag) => tag
    .replaceAll(' to ', '–')
    .replaceAll(RegExp(r'\s*mo\b'), ' months');

/// The dish photo when there is one, the warm tinted thumb when there is not
/// (or when the asset has not been dropped in yet), so a missing file is a
/// placeholder and never a red error box.
class FoodPhoto extends StatelessWidget {
  const FoodPhoto({super.key, required this.recipe, required this.height, this.radius = 16});
  final FoodRecipe recipe;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // `double.infinity` means "fill the box I am given" (cook mode's closing
    // picture). The thumb sizes its motif from the height, so resolve it first.
    if (!height.isFinite) {
      return LayoutBuilder(
        builder: (context, box) => FoodPhoto(recipe: recipe, height: box.maxHeight, radius: radius),
      );
    }
    // ⚠️ NEUTRAL, NOT THE TINTED THUMB (2026-10-17). FoodThumb rotates peach,
    // lavender and blush stripes by seed, and with 27 of the 28 doc dishes
    // still waiting on their photo, most cards came out lilac or pink: the
    // user's "old UI hints, the lavender background some places". Mobbin:
    // where a recipe has no picture (Woolworths) the block is a pale neutral,
    // never a coloured stripe. FoodThumb stays as it was for the old cards.
    // Was: final thumb = FoodThumb(seed: recipe.seed, height: height, radius: radius);
    final thumb = _NeutralFoodBlock(height: height, radius: radius);
    final path = recipe.photo;
    if (path == null) return thumb;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        path,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => thumb,
      ),
    );
  }
}

/// The doc-format dish before its photo arrives: the page's own pale surface
/// and a line bowl in the third ink.
class _NeutralFoodBlock extends StatelessWidget {
  const _NeutralFoodBlock({required this.height, required this.radius});
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        width: double.infinity,
        color: p.surfaceAlt,
        alignment: Alignment.center,
        child: Icon(Icons.ramen_dining_outlined, size: height * 0.24, color: p.ink3),
      ),
    );
  }
}

/// A white disc that sits on a photo (the §20a rule: marks on a photograph are
/// white discs, never tinted pills).
Widget foodPhotoDisc({required Widget child, double size = 30}) => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 6)],
      ),
      child: child,
    );

/// The recipe card that opens the doc-format page: photo 4:3, bookmark top
/// right and the diet mark bottom left on the photo, the title in two lines,
/// then "25 min · 7–8 months". Works in a rail and in the two-column grid.
class FoodPhotoCard extends StatelessWidget {
  const FoodPhotoCard({super.key, required this.recipe, required this.onTap, this.width = 196, this.photoHeight, this.note});
  final FoodRecipe recipe;

  /// One more line under the time and age, for the child on screen: an
  /// allergy on the record, or a food new to them (tools pass, Food,
  /// 2026-10-25). Null draws nothing.
  final String? note;
  final VoidCallback onTap;
  final double width;

  /// Defaults to 4:3 of [width]. A rail that also holds shelf cards passes
  /// their picture height, so the photos line up across one row.
  final double? photoHeight;

  @override
  Widget build(BuildContext context) {
    final r = recipe;
    final h = photoHeight ?? width * 0.75;
    final p = V2PaletteStore.instance.current;
    return SizedBox(
      width: width,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          PvPress(child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: FoodPhoto(recipe: r, height: h),
          )),
          Positioned(
            left: 8,
            bottom: 8,
            child: IgnorePointer(child: foodPhotoDisc(size: 26, child: foodDietMark(r.diet, size: 12))),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: AnimatedBuilder(
              animation: FoodStore.instance,
              builder: (context, _) {
                final saved = FoodStore.instance.isSaved(r.id);
                return Semantics(
                  button: true,
                  label: saved ? 'Saved. Tap to remove' : 'Save recipe',
                  child: PvPress(child: GestureDetector(
                    key: ValueKey('food_photo_card_save_${r.id}'),
                    onTap: () => FoodStore.instance.toggleSave(r.id),
                    behavior: HitTestBehavior.opaque,
                    child: foodPhotoDisc(
                      child: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, size: 17, color: ppInk),
                    ),
                  )),
                );
              },
            ),
          ),
        ]),
        PvPress(child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Was ppJakarta and ppMuted (#A99CBB, a lavender grey); the house
              // palette since 2026-10-17.
              Text(r.title,
                  style: pvJakarta(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.schedule_rounded, size: 12.5, color: p.ink3),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('${r.totalMin} min  ·  ${foodAgeLabel(r.ageTag)}',
                      style: pvManrope(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
              if (note != null) ...[
                const SizedBox(height: 4),
                Text(note!,
                    key: ValueKey('food_photo_card_note_${r.id}'),
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, height: 1.35, color: p.ink1)),
              ],
            ]),
          ),
        )),
      ]),
    );
  }
}
