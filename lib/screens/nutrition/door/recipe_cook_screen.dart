// =============================================================================
//  Nutrition — a recipe that cooks
// -----------------------------------------------------------------------------
//  2026-09-20. The old recipe page (`RecipeDetailScreen`, kept) read like an
//  article. A recipe is a thing you DO with your hands busy, so this one is
//  built the way the cooking apps build it (MOBBIN-DISCOVERY §12):
//
//    photo hero, pinned bar with the name (Vivino / Kitchen Stories)
//    why now · a glance at what it gives
//    servings stepper that scales every quantity (Woolworths, Crouton)
//    ingredients → "Add to my list" (Woolworths' Shop ingredients, no shop)
//    method as numbered steps
//    COOK: one step per screen, big type, segmented progress, Next / Done,
//          the screen kept awake, "Enjoy" over the photo at the end
//          (Recime's play-through, HelloFresh's last card)
// =============================================================================

import 'package:flutter/material.dart';
import '../../../data/nutrition/food_values.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition_data.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../can_i/can_i_widgets.dart' show CanIPhoto;
import '../../v2/v2_palette.dart';
import 'nutrition_widgets.dart';

const String kRecipeRoute = 'nutrition/recipe';

void openRecipe(BuildContext context, Recipe r, PregnancyController c) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kRecipeRoute),
    builder: (_) => RecipeCookScreen(recipe: r, pregnancy: c),
  ));
}

class RecipeCookScreen extends StatefulWidget {
  const RecipeCookScreen({super.key, required this.recipe, required this.pregnancy});
  final Recipe recipe;
  final PregnancyController pregnancy;

  @override
  State<RecipeCookScreen> createState() => _RecipeCookScreenState();
}

class _RecipeCookScreenState extends State<RecipeCookScreen> {
  late int _servings = widget.recipe.defaultServings;

  String _qty(RecipeIngredient i) {
    final q = i.qtyPerServing * _servings;
    final s = q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    return '$s ${i.unit}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final url = nutritionRecipePhoto(r.id, r.name.en);
    return AnimatedBuilder(
      animation: Listenable.merge([V2PaletteStore.instance, NutritionDayStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final onList = NutritionDayStore.instance.onList(r.id);
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 280,
              backgroundColor: p.ground,
              surfaceTintColor: Colors.transparent,
              foregroundColor: p.ink1,
              elevation: 0,
              scrolledUnderElevation: 0,
              shape: Border(bottom: BorderSide(color: p.line)),
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _round(p, Icons.arrow_back_rounded, () => Navigator.of(context).maybePop()),
              ),
              leadingWidth: 56,
              flexibleSpace: LayoutBuilder(builder: (context, c) {
                final collapsed = c.maxHeight < 150;
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 64, bottom: 16, right: 20),
                  centerTitle: false,
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: collapsed ? 1 : 0,
                    child: Text(r.name.en,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
                  ),
                  background: Stack(fit: StackFit.expand, children: [
                    NutritionPhoto(url: url, p: p, icon: Icons.soup_kitchen_outlined, iconSize: 56),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 110,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withValues(alpha: 0.26), Colors.transparent]),
                        ),
                      ),
                    ),
                  ]),
                );
              }),
            ),
            SliverList.list(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.name.en,
                      style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w600, height: 1.1, letterSpacing: -0.6, color: p.ink1)),
                  const SizedBox(height: 8),
                  Text(r.whyNow.en, style: pvManrope(fontSize: 15, height: 1.5, color: p.ink1)),
                  const SizedBox(height: 18),
                  // What it is strong in, as marks (the user, 2026-09-21: not
                  // pills). The writer's glance strings that were pills here
                  // are kept in the data for revert; `fact` is the line now.
                  NutritionTopThree(p: p, values: estimateRecipe(r)),
                  if (r.fact case final fact?) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.only(left: 14),
                      decoration: BoxDecoration(border: Border(left: BorderSide(color: p.ink1, width: 2))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Did you know',
                            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
                        const SizedBox(height: 4),
                        Text(fact, style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink1)),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                  NutritionValuesGrid(p: p, values: estimateRecipe(r)),
                ]),
              ),
              const SizedBox(height: 22),
              _rule(p),
              // ---- servings + ingredients -------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: nutritionHeading(p, 'Ingredients')),
                    _stepper(p),
                  ]),
                  const SizedBox(height: 4),
                  Text('For $_servings ${_servings == 1 ? 'serving' : 'servings'}', style: pvManrope(fontSize: 12.5, color: p.ink3)),
                  const SizedBox(height: 10),
                  for (var i = 0; i < r.ingredients.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          border: i == r.ingredients.length - 1 ? null : Border(bottom: BorderSide(color: p.line))),
                      child: Row(children: [
                        SizedBox(
                          width: 72,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Text(_qty(r.ingredients[i]),
                                key: ValueKey(_qty(r.ingredients[i])),
                                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
                          ),
                        ),
                        Expanded(child: Text(r.ingredients[i].name.en, style: pvManrope(fontSize: 14.5, color: p.ink1))),
                      ]),
                    ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () {
                      pvCommitFeedback();
                      if (onList) {
                        NutritionDayStore.instance.removeRecipeFromList(r.id);
                      } else {
                        NutritionDayStore.instance.addToList(r.id, r.ingredients.map((i) => i.name.en));
                      }
                    },
                    icon: Icon(onList ? Icons.check_rounded : Icons.add_shopping_cart_outlined, size: 18),
                    label: Text(onList ? 'On your list' : 'Add to my list'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              _rule(p),
              // ---- method ---------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  nutritionHeading(p, 'Method', sub: '${r.steps.length} steps. Cook mode reads them one at a time.'),
                  const SizedBox(height: 14),
                  for (var i = 0; i < r.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.line)),
                          child: Text('${i + 1}', style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, color: p.ink1)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(r.steps[i].en, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1))),
                      ]),
                    ),
                ]),
              ),
              const SizedBox(height: 100),
            ]),
          ]),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: FilledButton.icon(
                onPressed: () {
                  pvCommitFeedback();
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: const RouteSettings(name: 'nutrition/cook'),
                    builder: (_) => CookModeScreen(recipe: r),
                  ));
                },
                icon: const Icon(Icons.local_fire_department_outlined, size: 18),
                label: const Text('Cook'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stepper(V2Palette p) => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: p.line)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18),
            onPressed: _servings > 1
                ? () {
                    pvCommitFeedback();
                    setState(() => _servings--);
                  }
                : null,
          ),
          Text('$_servings', style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1)),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: _servings < 8
                ? () {
                    pvCommitFeedback();
                    setState(() => _servings++);
                  }
                : null,
          ),
        ]),
      );

  Widget _rule(V2Palette p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(height: 1, color: p.line),
      );

  Widget _round(V2Palette p, IconData icon, VoidCallback onTap) => Material(
        color: Colors.white.withValues(alpha: 0.82),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: p.ink1))),
      );
}

// -----------------------------------------------------------------------------
//  Cook mode
// -----------------------------------------------------------------------------

class CookModeScreen extends StatefulWidget {
  const CookModeScreen({super.key, required this.recipe});
  final Recipe recipe;

  @override
  State<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends State<CookModeScreen> {
  int _step = 0;
  bool get _done => _step >= widget.recipe.steps.length;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final r = widget.recipe;
    final url = nutritionRecipePhoto(r.id, r.name.en);
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
            child: Row(children: [
              Expanded(
                child: Row(children: [
                  for (var i = 0; i < r.steps.length; i++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        height: 4,
                        margin: EdgeInsets.only(right: i == r.steps.length - 1 ? 0 : 5),
                        decoration: BoxDecoration(
                            color: i <= _step ? p.ink1 : p.line, borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                ]),
              ),
              const SizedBox(width: 12),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).maybePop()),
            ]),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                    position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(a), child: child),
              ),
              child: _done ? _enjoy(p, url) : _stepView(p),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(children: [
              if (!_done)
                OutlinedButton(
                  onPressed: () => _ingredients(context, p),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(52, 52), padding: EdgeInsets.zero),
                  child: const Icon(Icons.format_list_bulleted_rounded, size: 20),
                ),
              if (!_done) const SizedBox(width: 10),
              if (_step > 0 && !_done) ...[
                OutlinedButton(
                  onPressed: () {
                    pvCommitFeedback();
                    setState(() => _step--);
                  },
                  style: OutlinedButton.styleFrom(minimumSize: const Size(52, 52), padding: EdgeInsets.zero),
                  child: const Icon(Icons.arrow_back_rounded, size: 20),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    pvCommitFeedback();
                    if (_done) {
                      Navigator.of(context).maybePop();
                    } else {
                      setState(() => _step++);
                    }
                  },
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  child: Text(_done ? 'Done' : (_step == r.steps.length - 1 ? 'Finish' : 'Next')),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _stepView(V2Palette p) => Padding(
        key: ValueKey(_step),
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('STEP ${_step + 1} OF ${widget.recipe.steps.length}',
              style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
          const SizedBox(height: 14),
          Text(widget.recipe.steps[_step].en,
              style: pvFraunces(fontSize: 26, fontWeight: FontWeight.w500, height: 1.35, letterSpacing: -0.3, color: p.ink1)),
        ]),
      );

  Widget _enjoy(V2Palette p, String? url) => Padding(
        key: const ValueKey('enjoy'),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: url == null
                  ? ColoredBox(color: p.surfaceAlt, child: Center(child: Icon(Icons.restaurant_outlined, size: 56, color: p.ink3)))
                  : CanIPhoto(url: url, fallback: ColoredBox(color: p.surfaceAlt)),
            ),
          ),
          const SizedBox(height: 22),
          Text('Enjoy it.', style: pvFraunces(fontSize: 30, fontWeight: FontWeight.w600, height: 1.1, color: p.ink1)),
          const SizedBox(height: 6),
          Text('${widget.recipe.name.en} · ${widget.recipe.whyNow.en}',
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
          const SizedBox(height: 16),
        ]),
      );

  void _ingredients(BuildContext context, V2Palette p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('INGREDIENTS · ${widget.recipe.defaultServings} SERVINGS',
              style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
          const SizedBox(height: 10),
          for (final i in widget.recipe.ingredients)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                  '${(i.qtyPerServing * widget.recipe.defaultServings).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} ${i.unit}  ${i.name.en}',
                  style: pvManrope(fontSize: 14, color: p.ink1)),
            ),
        ]),
      ),
    );
  }
}
