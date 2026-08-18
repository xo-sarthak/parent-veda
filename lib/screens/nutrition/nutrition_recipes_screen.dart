// =============================================================================
//  Recipes — a filterable grid, and a cook-along recipe page
// -----------------------------------------------------------------------------
//  Ingredients are stored per ONE serving in `nutrition_data.dart`; the
//  servings selector on the detail page multiplies live, so the same 15
//  recipes serve a solo lunch or a family dinner without duplicating data.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/nutrition_data.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_placeholders.dart';
import '../v2/v2_palette.dart';

class NutritionRecipesScreen extends StatefulWidget {
  const NutritionRecipesScreen({super.key});

  @override
  State<NutritionRecipesScreen> createState() => _NutritionRecipesScreenState();
}

class _NutritionRecipesScreenState extends State<NutritionRecipesScreen> {
  String? _tag;
  RecipeRegion? _region;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final items = kRecipes.where((r) {
          if (_tag != null && !r.tags.contains(_tag)) return false;
          if (_region != null && r.region != _region) return false;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text('Recipes', style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text('Filter by need',
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: p.ink3)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _Chip(label: 'All', selected: _tag == null, p: p, onTap: () => setState(() => _tag = null)),
                    for (final f in kRecipeFilters) ...[
                      const SizedBox(width: 8),
                      _Chip(label: f.label, selected: _tag == f.tag, p: p, onTap: () => setState(() => _tag = _tag == f.tag ? null : f.tag)),
                    ],
                  ]),
                ),
                const SizedBox(height: 14),
                Text('Filter by region',
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: p.ink3)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _Chip(label: 'All', selected: _region == null, p: p, onTap: () => setState(() => _region = null)),
                    for (final r in RecipeRegion.values) ...[
                      const SizedBox(width: 8),
                      _Chip(label: r.label.now, selected: _region == r, p: p, onTap: () => setState(() => _region = _region == r ? null : r)),
                    ],
                  ]),
                ),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text('No recipes match yet. Try a different filter.',
                          style: pvManrope(fontSize: 13.5, color: p.ink3)),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.82),
                    itemBuilder: (context, i) => _RecipeCard(
                      p: p,
                      recipe: items[i],
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipe: items[i]),
                      )),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.p, required this.onTap});
  final String label;
  final bool selected;
  final V2Palette p;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? p.action.withValues(alpha: 0.10) : p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? p.action.withValues(alpha: 0.5) : p.line),
        ),
        child: Text(label, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? p.action : p.ink2)),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.p, required this.recipe, required this.onTap});
  final V2Palette p;
  final Recipe recipe;
  final VoidCallback onTap;

  Color _shift(Color c, double d) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + d).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(42, p);
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_shift(tint, 0.04), _shift(tint, -0.06)]),
                ),
                child: Center(
                  child: Icon(Icons.ramen_dining_outlined, size: 30,
                      color: HSLColor.fromColor(tint).withSaturation(0.42).withLightness(0.40).toColor()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recipe.name.now, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: pvFraunces(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
                const SizedBox(height: 4),
                Text(recipe.region.label.now,
                    style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: p.ink3)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Recipe detail
// ===========================================================================

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});
  final Recipe recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late int _servings = widget.recipe.defaultServings;

  String _fmtQty(double perServing) {
    final total = perServing * _servings;
    if (total == total.roundToDouble()) return total.toStringAsFixed(0);
    // Common cooking fractions read better than a decimal.
    final fractions = {0.25: '¼', 0.33: '⅓', 0.5: '½', 0.66: '⅔', 0.75: '¾'};
    final whole = total.floor();
    final frac = total - whole;
    for (final f in fractions.entries) {
      if ((frac - f.key).abs() < 0.02) {
        return whole == 0 ? f.value : '$whole${f.value}';
      }
    }
    return total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(r.name.now, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text(r.whyNow.now, style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
                const SizedBox(height: 16),
                PvVideoPlaceholder(title: r.videoTitle, subtitle: 'Cook along, step by step.', hue: 344),
                const SizedBox(height: 22),
                _ServingsSelector(
                  p: p,
                  servings: _servings,
                  onChanged: (v) => setState(() => _servings = v),
                ),
                const SizedBox(height: 22),
                Text('Ingredients', style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
                  child: Column(children: [
                    for (final ing in r.ingredients) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                        child: Row(children: [
                          Expanded(child: Text(ing.name.now, style: pvManrope(fontSize: 13.5, color: p.ink1))),
                          Text('${_fmtQty(ing.qtyPerServing)} ${ing.unit}',
                              style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
                        ]),
                      ),
                      if (ing != r.ingredients.last) Divider(height: 1, color: p.line),
                    ],
                  ]),
                ),
                const SizedBox(height: 22),
                Text('Steps', style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1)),
                const SizedBox(height: 10),
                for (var i = 0; i < r.steps.length; i++) ...[
                  _StepRow(p: p, index: i + 1, text: r.steps[i].now),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 12),
                Text('Nutrition at a glance (per serving)',
                    style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in r.nutritionGlance)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(999)),
                        child: Text(g, style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink2)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ServingsSelector extends StatelessWidget {
  const _ServingsSelector({required this.p, required this.servings, required this.onChanged});
  final V2Palette p;
  final int servings;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
      child: Row(children: [
        Text('Servings', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
        const Spacer(),
        _StepButton(p: p, icon: Icons.remove_rounded, onTap: servings > 1 ? () => onChanged(servings - 1) : null),
        SizedBox(
          width: 34,
          child: Text('$servings', textAlign: TextAlign.center, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1)),
        ),
        _StepButton(p: p, icon: Icons.add_rounded, onTap: servings < 12 ? () => onChanged(servings + 1) : null),
      ]),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.p, required this.icon, required this.onTap});
  final V2Palette p;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.line)),
        child: Icon(icon, size: 16, color: onTap == null ? p.ink3.withValues(alpha: 0.4) : p.ink2),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.p, required this.index, required this.text});
  final V2Palette p;
  final int index;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: p.surfaceAlt, shape: BoxShape.circle),
        child: Text('$index', style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, color: p.ink2)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1))),
    ]);
  }
}
