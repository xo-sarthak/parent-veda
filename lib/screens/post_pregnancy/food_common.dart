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

/// time · age · veg · nutrition highlight.
Widget foodMeta(FoodRecipe r) => Row(children: [
      Icon(Icons.schedule_rounded, size: 12.5, color: ppMuted),
      const SizedBox(width: 4),
      Text('${r.totalMin} min', style: ppBody(11.5, color: ppMuted, w: FontWeight.w600)),
      const SizedBox(width: 8),
      vegDot(r.veg),
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
        if (action != null) GestureDetector(onTap: onAction, behavior: HitTestBehavior.opaque, child: ppSeeAll(action)),
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
  Widget build(BuildContext context) => GestureDetector(
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
      );
}

/// A wide list card (thumb left, text right).
class FoodListCard extends StatelessWidget {
  const FoodListCard({super.key, required this.recipe, required this.onTap});
  final FoodRecipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
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
                Text(recipe.subtitle, style: ppBody(12.5, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 7),
                foodMeta(recipe),
              ]),
            ),
          ]),
        ),
      );
}
