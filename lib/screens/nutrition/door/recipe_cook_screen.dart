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
import 'shopping_list_screen.dart';
import '../../products/pv_store_chrome.dart' show pvSnack;

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

  String _qty(RecipeIngredient i) => kitchenQty(i.qtyPerServing * _servings, i.unit);

  // Kept for revert — the decimal version, which printed "0.8 tsp mustard
  // seeds" once the servings stepper multiplied a quarter-teaspoon by three:
  // String _qty(RecipeIngredient i) {
  //   final q = i.qtyPerServing * _servings;
  //   final s = q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  //   return '$s ${i.unit}'.trim();
  // }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final url = nutritionRecipePhoto(r.id, r.name.en);
    return AnimatedBuilder(
      animation: Listenable.merge([V2PaletteStore.instance, NutritionDayStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        // ⚠️ ALL, SOME OR NONE — NOT "ANY" (the phone, 2026-09-23). `onList`
        // is true when ANY ingredient is on the list, so adding the rice alone
        // flipped this button to "✓ On your list" — and tapping it then
        // removed the WHOLE recipe. Now: none → add everything; some → add the
        // rest (never removes what she chose); all → on your list, and only
        // then does a tap take the recipe off.
        final store = NutritionDayStore.instance;
        final names = [for (final i in r.ingredients) i.name.en];
        final missing = names.where((n) => !store.itemOnList(r.id, n)).length;
        final allOn = missing == 0;
        final someOn = !allOn && missing < names.length;
        // final onList = NutritionDayStore.instance.onList(r.id); // kept for revert — "any", which lied about part of a recipe
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
                  const SizedBox(height: 14),
                  // ⚠️ THE NUMBERS ONCE, SMALL, HERE — and the recipe next.
                  // The page opened with "Strong in", then "Did you know",
                  // then six tiles, and the ingredients were a screen down:
                  // "I clicked for recipe. Recipe is like way below" (the
                  // user, 2026-09-22). Every recipe page in the library
                  // (MyFitnessPal, Lifesum, Yazio, HelloFresh, Noom) puts ONE
                  // line of numbers under the title and the ingredients
                  // right after; the full facts, if any, sit at the foot.
                  // So: the facts line, the three marks in their own hues
                  // with amounts, then ingredients and method; the six-tile
                  // grid and the did-you-know at the foot for whoever wants
                  // them. "Strong in" as a heading is gone; the marks stay.
                  _FactsLine(p: p, recipe: r),
                  const SizedBox(height: 10),
                  NutritionTopThree(p: p, values: estimateRecipe(r), compact: true),
                ]),
              ),
              const SizedBox(height: 22),
              _rule(p),
              // ---- servings + ingredients -------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ⚠️ THE SERVINGS CONTROL IS ITS OWN LABELLED ROW (the user,
                  // 2026-09-23). It sat beside the "Ingredients" heading as a
                  // bare "− 2 +", with "For 2 servings" on a separate line
                  // under it: the number did not say what it counted, so it
                  // read as editing the ingredients, and the control was
                  // larger than the heading it sat next to. Now the row says
                  // what it is ("Amounts for"), the unit lives INSIDE the
                  // control ("2 servings"), and the separate line is gone —
                  // one statement, not two. Kept for revert:
                  //   Row(children: [Expanded(child: nutritionHeading(p, 'Ingredients')), _stepper(p)]),
                  //   Text('For $_servings servings', ...),
                  nutritionHeading(p, 'Ingredients'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: Text('Amounts for',
                          style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w600, color: p.ink2)),
                    ),
                    _servingsControl(p),
                  ]),
                  const SizedBox(height: 6),
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
                        // ⚠️ AN ADD PER INGREDIENT, NOT A CART (2026-09-22).
                        // Blinkit's recipe page puts an ADD on every
                        // ingredient — but theirs adds a PRODUCT: a brand, a
                        // pack size, a price. Ours adds the WORD. The user
                        // drew that line himself: *"we don't decide the
                        // brand, we just say that you might need ketchup"*.
                        // All-or-nothing was the flaw worth fixing: she has
                        // the onions already.
                        _AddOne(p: p, recipeId: r.id, name: r.ingredients[i].name.en),
                      ]),
                    ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () {
                      pvCommitFeedback();
                      if (allOn) {
                        NutritionDayStore.instance.removeRecipeFromList(r.id);
                        pvSnack(context, 'Taken off your list', lift: kRecipeSnackLift);
                      } else {
                        NutritionDayStore.instance.addToList(r.id, r.ingredients.map((i) => i.name.en));
                        // ⚠️ SAY WHERE IT WENT, AND OFFER THE WAY THERE (the
                        // user, 2026-09-23: "where is that list? I don't see
                        // a pop up… at least show a go-to-your-list sort of
                        // pop up"). The list lives under Nutrition › Today,
                        // two screens away; an add with no confirmation and
                        // no route to its result is a dead end.
                        pvSnack(context, '$missing ingredients added to your list',
                            action: 'View list', onAction: () => openShoppingList(context),
                            lift: kRecipeSnackLift, icon: Icons.check_rounded);
                      }
                    },
                    icon: Icon(allOn ? Icons.check_rounded : Icons.add_shopping_cart_outlined, size: 18),
                    label: Text(allOn
                        ? 'All on your list'
                        : someOn
                            ? 'Add the other $missing to my list'
                            : 'Add everything to my list'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                  // The list, one tap away, for as long as anything is on it —
                  // the confirmation disappears after three seconds; this does
                  // not.
                  if (NutritionDayStore.instance.shopping.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => openShoppingList(context),
                        icon: const Icon(Icons.receipt_long_outlined, size: 17),
                        label: Text(
                            'See your list · ${NutritionDayStore.instance.shopping.where((x) => !x.done).length} to buy'),
                      ),
                    ),
                  ],
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
              // ---- the numbers in full, and the fact, at the foot ----------
              _rule(p),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  NutritionValuesGrid(p: p, values: estimateRecipe(r)),
                  if (r.fact case final fact?) ...[
                    const SizedBox(height: 18),
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

  /// "− 2 servings +", compact. The number carries its unit, so it cannot be
  /// read as anything else; the buttons are 32pt, not the 48pt IconButtons
  /// that made the old stepper the loudest thing in the section.
  Widget _servingsControl(V2Palette p) {
    Widget step(IconData icon, bool enabled, VoidCallback onTap, String label) => Semantics(
          button: true,
          label: label,
          child: InkWell(
            onTap: enabled
                ? () {
                    pvCommitFeedback();
                    onTap();
                  }
                : null,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 32,
              height: 32,
              child: Icon(icon, size: 16, color: enabled ? p.ink1 : p.ink3.withValues(alpha: 0.4)),
            ),
          ),
        );
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: p.line)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        step(Icons.remove_rounded, _servings > 1, () => setState(() => _servings--), 'Fewer servings'),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: Text('$_servings ${_servings == 1 ? 'serving' : 'servings'}',
              key: ValueKey(_servings),
              style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
        ),
        step(Icons.add_rounded, _servings < 8, () => setState(() => _servings++), 'More servings'),
      ]),
    );
  }

  // Kept for revert — the bare stepper that sat beside the heading.
  // ignore: unused_element
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


/// "25 min · serves 4 · ≈ 320 kcal" — the one line under the title.
class _FactsLine extends StatelessWidget {
  const _FactsLine({required this.p, required this.recipe});
  final V2Palette p;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final v = estimateRecipe(recipe);
    // ⚠️ `recipe.minutes`, NOT `steps.length * 6` (the phone, 2026-09-23).
    // The line invented its time from the step count — "about 30 min" on a
    // dish the card, reading the real field, called 35 — two numbers for one
    // recipe, one of them made up. Kept for revert:
    //   final mins = recipe.steps.length * 6;
    final mins = recipe.minutes;
    final parts = [
      '$mins min',
      'serves ${recipe.defaultServings}',
      if (v.kcal > 0) '≈ ${v.kcal.round()} kcal a serving',
    ];
    return Text(parts.join('  ·  '),
        style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink2));
  }
}

/// One ingredient's add. A plus that becomes a tick — Blinkit's ADD, minus
/// the brand, the pack size and the price.
class _AddOne extends StatelessWidget {
  const _AddOne({required this.p, required this.recipeId, required this.name});
  final V2Palette p;
  final String recipeId;
  final String name;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: NutritionDayStore.instance,
        builder: (context, _) {
          final on = NutritionDayStore.instance.itemOnList(recipeId, name);
          return Semantics(
            button: true,
            label: on ? '$name is on your list' : 'Add $name to your list',
            child: InkWell(
              onTap: () {
                pvCommitFeedback();
                NutritionDayStore.instance.toggleItem(recipeId, name);
                final nowOn = NutritionDayStore.instance.itemOnList(recipeId, name);
                pvSnack(context, nowOn ? '$name is on your list' : '$name is off your list',
                    action: nowOn ? 'View list' : null,
                    onAction: nowOn ? () => openShoppingList(context) : null,
                    lift: kRecipeSnackLift,
                    icon: nowOn ? Icons.check_rounded : Icons.remove_rounded);
              },
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: on ? p.ink1 : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: on ? p.ink1 : p.line),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(on ? Icons.check_rounded : Icons.add_rounded,
                      size: 13, color: on ? p.ground : p.ink2),
                  const SizedBox(width: 3),
                  Text(on ? 'On list' : 'Add',
                      style: pvManrope(
                          fontSize: 11, fontWeight: FontWeight.w800, color: on ? p.ground : p.ink2)),
                ]),
              ),
            ),
          );
        },
      );
}

/// A quantity the way a kitchen writes it (the phone, 2026-09-23: "0.8 tsp
/// mustard seeds" on the sambar).
///
/// ⚠️ ROUNDING HERE IS NOT A LOSS OF PRECISION, IT IS THE PRECISION. A spoon
/// measure has quarters and nothing finer, so 0.8 tsp is not more accurate
/// than 3/4 tsp — it is a number nobody can measure. Each unit rounds to the
/// finest step a real kitchen has:
///   tsp, tbsp, cup  -> nearest quarter, drawn as a fraction (1/4 1/2 3/4)
///   pcs             -> nearest half ("1 1/2 pcs"), never below a half
///   g               -> 5 g under 100, 10 g under 500, 25 g above
/// Anything that rounds to nothing shows as "a pinch" (spoons) or the
/// smallest step, never "0 tsp".
String kitchenQty(double q, String unit) {
  String frac(double v, double step) {
    final r = (v / step).round() * step;
    final whole = r.floor();
    final rest = r - whole;
    final f = switch ((rest * 4).round()) { 1 => '¼', 2 => '½', 3 => '¾', _ => '' };
    if (whole == 0) return f.isEmpty ? '' : f;
    return f.isEmpty ? '$whole' : '$whole$f';
  }

  switch (unit) {
    case 'tsp' || 'tbsp' || 'cup':
      final v = frac(q, 0.25);
      return v.isEmpty ? 'a pinch' : '$v $unit';
    case 'pcs':
      final v = frac(q < 0.5 ? 0.5 : q, 0.5);
      return '$v $unit';
    case 'g':
      final step = q < 100 ? 5.0 : q < 500 ? 10.0 : 25.0;
      final r = ((q / step).round() * step).clamp(step, double.infinity);
      return '${r.toInt()} g';
    default:
      final s = q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);
      return '$s $unit'.trim();
  }
}

/// The shopping list, from anywhere a recipe can add to it.
void openShoppingList(BuildContext context) => Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'nutrition/list'),
      builder: (_) => const ShoppingListScreen(),
    ));

/// Where a confirmation floats on the recipe page: just above the Cook bar,
/// clear of the ingredient rows.
const double kRecipeSnackLift = 96;
