// =============================================================================
//  FoodRecipeScreen - a recipe as a food companion page (not a blog post)
// -----------------------------------------------------------------------------
//  Ingredients + steps, yes - but wrapped in understanding: a Nutrition
//  Breakdown, the signature Healthier-Version toggle (everyday ⇄ ParentVeda,
//  with what changed & why), why it's good, how often to serve, storage, common
//  mistakes, substitutions, and links out to the article/video/product/community/
//  Ask Veda. Add-to-shopping-list generates the checklist. pp-themed, no emojis.
// =============================================================================

import 'package:flutter/material.dart';
import '../../ask_veda/ask_veda_mark.dart';

import 'article_reader_screen.dart';
import 'askveda_screen.dart';
import 'pp_articles_data.dart' show kArticles;
import 'pp_food_safety.dart';
import 'pp_phases_data.dart' show ppFillChild;
import 'food_common.dart';
import 'food_saved_screen.dart';
import 'food_shopping_screen.dart';
import '../../widgets/pv_placeholders.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';
import 'pp_products_data.dart';
import 'pp_watch_data.dart';
import '../product_guide/product_guide_chooser.dart';
import 'product_detail_screen.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit, PvSecondary, pvStorePalette;
import 'pp_care_parts.dart' show PpCareStats, ppCareHeading;
import '../../widgets/pv_feedback.dart' show PvPress;
import '../../widgets/pv_toast.dart';
import '../nutrition/door/recipe_cook_screen.dart' show CookModeScreen;
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_recipes_screen.dart' show ppRecipeAgeRange;
import '../saved_toast.dart';

/// Every dish on the doc page (2026-10-21). False brings back the shell page
/// for the dishes without the Drive doc format.
const bool kPpRecipeDocPageForAll = true;

class FoodRecipeScreen extends StatefulWidget {
  const FoodRecipeScreen({super.key, required this.recipe});
  final FoodRecipe recipe;

  @override
  State<FoodRecipeScreen> createState() => _FoodRecipeScreenState();
}

class _FoodRecipeScreenState extends State<FoodRecipeScreen> {
  // ignore: unused_field
  bool _healthier = true; // retired with _healthierCard; kept for revert

  FoodRecipe get r => widget.recipe;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  The recipe on the shell every TTC and pregnancy tool wears. Mobbin:
  //  prep and cook time as the stat strip, after Kitchen Stories' time rings
  //  (mobbin.com/screens/0b1f70cc-5c8c-46ae-9253-53d6d5eff547); Save beside the
  //  one ink action, then ingredients as a plain list, after Noom
  //  (mobbin.com/screens/b93dcf56-1078-493d-9977-469355ca45ee); numbered steps
  //  in circles, after Yazio (mobbin.com/screens/b5bbdf6c-22f2-46f5-b6d1-7b60360ea8a1).
  //  The old page is `_buildBeforeShell`, kept for revert.
  @override
  Widget build(BuildContext context) {
    // The Drive doc format got the new page in the 2026-10-15 pilot. Since
    // 2026-10-21 every dish opens it (the user: "one image per recipe is
    // enough"); the shell page below is kept for revert.
    if (kPpRecipeDocPageForAll || r.docFormat) return _buildDocPage(context);
    final p = pvStorePalette;
    final body = pvManrope(fontSize: 14, height: 1.55, color: p.ink1);
    Widget dot(String t) => pregToolPad(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 10),
              child: Container(width: 5, height: 5, decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle)),
            ),
            Expanded(child: Text(t, style: body)),
          ]),
        ));
    Widget head(String t) => pregToolPad(ppCareHeading(t));
    return AnimatedBuilder(
      animation: foodListenable,
      builder: (context, _) {
        final saved = FoodStore.instance.isSaved(r.id);
        return PregToolScaffold(
          hue: 96,
          eyebrow: r.ageTag,
          mark: IntentMark.cookMark,
          title: r.title,
          intro: _fill(r.subtitle),
          children: [
            pregToolPad(PpCareStats([
              ('${r.prepMin} min', 'prep'),
              ('${r.cookMin} min', 'cook'),
              (r.veg ? 'Veg' : 'Non-veg', r.difficulty.toLowerCase()),
            ])),
            const SizedBox(height: 16),
            pregToolPad(Row(children: [
              Expanded(
                child: PvSecondary(
                  key: const ValueKey('pp_recipe_save'),
                  label: saved ? 'Saved' : 'Save',
                  icon: saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  onTap: () => FoodStore.instance.toggleSave(r.id),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PvCommit(
                  key: const ValueKey('pp_recipe_shop'),
                  label: 'Add to list',
                  onTap: () {
                    FoodStore.instance.addRecipeToShopping(r);
                    pvToast(context, 'Ingredients added to your shopping list', kind: PvToastKind.done);
                  },
                ),
              ),
            ])),
            const SizedBox(height: 24),
            head('Why it is good'),
            const SizedBox(height: 6),
            pregToolPad(Text(_fill(r.why), style: body)),
            const SizedBox(height: 24),
            head('Ingredients'),
            const SizedBox(height: 8),
            for (final i in r.ingredients) dot(i),
            if (_equipmentFor(r).isNotEmpty) ...[
              const SizedBox(height: 16),
              head('You will need'),
              const SizedBox(height: 8),
              for (final e in _equipmentFor(r)) dot(e),
            ],
            const SizedBox(height: 20),
            head('Steps'),
            const SizedBox(height: 10),
            for (var i = 0; i < r.steps.length; i++)
              pregToolPad(Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_fill(r.steps[i]), style: body)),
                ]),
              )),
            if (r.nutrients.isNotEmpty) ...[
              const SizedBox(height: 12),
              head('What is in it'),
              const SizedBox(height: 8),
              for (final n in r.nutrients) dot('${n.name}, ${n.amount}. ${_fill(n.note)}'),
            ],
            const SizedBox(height: 18),
            head('Good to know'),
            const SizedBox(height: 8),
            dot('How often: ${r.frequency}'),
            for (final x in r.storage) dot(x),
            if (r.mistakes.isNotEmpty) ...[
              const SizedBox(height: 18),
              head('Easy to get wrong'),
              const SizedBox(height: 8),
              for (final m in r.mistakes) dot(_fill(m)),
            ],
            if (r.substitutions.isNotEmpty) ...[
              const SizedBox(height: 18),
              head('Swaps'),
              const SizedBox(height: 8),
              for (final e in r.substitutions.entries) dot('${e.key}: ${e.value}'),
            ],
          ],
        );
      },
    );
  }

  // Kept for revert (2026-10-07): the page before the shared shell.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            _hero(),
            const SizedBox(height: 18),
            _pad(Text(r.title, style: ppFraunces(25, h: 1.15))),
            const SizedBox(height: 6),
            _pad(Text(_fill(r.subtitle), style: ppBody(14, h: 1.5))),
            const SizedBox(height: 12),
            _pad(_dietServesRow()),
            const SizedBox(height: 18),
            // ⚠️ THE VIDEO CAME UP FROM THE FOOT OF THE PAGE. It was one row
            // in the links list below — under the steps, the mistakes and the
            // storage notes — which is the one place a parent standing at a
            // hob will never scroll to. Feedback: "add video at top of all
            // recipes".
            //
            // ⚠️ AND IT RENDERS FOR EVERY RECIPE, NOT ONLY THE FIVE THAT HAVE
            // A FILE. Twenty-three of twenty-eight recipes have no
            // `relatedVideoId`, and showing the block on five of them would
            // make the video look like a property of those dishes rather than
            // something the section is still filming. The placeholder carries
            // the real 16:9 geometry and says so plainly, which is the
            // established pattern here — a placeholder you delete to ship is a
            // second implementation; one that is the real component with an
            // empty input is a state.
            _pad(_recipeVideo()),
            const SizedBox(height: 16),
            // WHY first, timings second. A parent decides whether to cook it on
            // the strength of what it does for the baby - the 15-minute block
            // only matters once she has decided.
            _pad(_why()),
            const SizedBox(height: 18),
            _pad(_statStrip()),
            const SizedBox(height: 22),
            // Healthier-version toggle RETIRED: one recipe, already the good
            // version. Offering an "everyday" alternative undercut the whole
            // point of the page. Kept commented for revert.
            // _pad(_healthierCard()),
            // const SizedBox(height: 22),
            _pad(_ingredients()),
            const SizedBox(height: 22),
            _pad(_steps()),
            const SizedBox(height: 8),
            _pad(_addToShopping()),
            const SizedBox(height: 8),
            _pad(ppSectionDivider()),
            _pad(_nutrition()),
            const SizedBox(height: 22),
            _pad(_bulletsSection('Good to know', [
              ('How often', r.frequency),
              for (final s in r.storage) ('Storage', s),
            ], Icons.info_outline_rounded)),
            const SizedBox(height: 22),
            _pad(_mistakes()),
            const SizedBox(height: 22),
            if (r.substitutions.isNotEmpty) ...[_pad(_subs()), const SizedBox(height: 22)],
            _pad(_related()),
          ],
        ),
      ),
    );
  }

  // ---- hero ---------------------------------------------------------------
  Widget _hero() => Stack(children: [
        FoodThumb(seed: r.seed, height: 240, radius: 0),
        Positioned(
          top: 8,
          left: 12,
          child: _round(Icons.arrow_back, () => Navigator.of(context).maybePop()),
        ),
        Positioned(
          top: 8,
          right: 12,
          child: AnimatedBuilder(
            animation: foodListenable,
            builder: (context, _) {
              final saved = FoodStore.instance.isSaved(r.id);
              return _round(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, () {
                void flip() => FoodStore.instance.toggleSave(r.id);
                flip();
                final nav = Navigator.of(context);
                pvSaveToast(context,
                    nowSaved: !saved,
                    undo: flip,
                    where: 'Saved to your recipes',
                    onView: () => nav.push(MaterialPageRoute<void>(builder: (_) => const FoodSavedScreen())));
              });
            },
          ),
        ),
      ]);

  Widget _round(IconData i, VoidCallback onTap) => PvPress(child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8)]),
          child: Icon(i, size: 19, color: ppInk),
        ),
      ));

  // ---- diet marker · serves · immunity ------------------------------------
  /// The demonstration, at the top where a cooking parent will see it.
  Widget _recipeVideo() {
    final id = r.relatedVideoId;
    if (id != null) {
      final v = watchVideoById(id);
      return PvVideoPlaceholder(
        title: v.title,
        subtitle: 'Watch it made, start to finish',
        duration: '${(v.seconds / 60).ceil()} min',
        hue: 104,
        flat: true,
        onTap: () => _push(
            v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v)),
      );
    }
    // ⚠️ `slotId` IS THE WIRING, WRITTEN DOWN AT THE MOMENT THE SLOT IS
    // CREATED rather than worked out again when the file arrives. Same
    // convention as PpVideoSlot on the section pages.
    return PvVideoPlaceholder(
      title: '${r.title}, step by step',
      subtitle: 'The texture to aim for, and the one bit that is easy to '
          'get wrong.',
      duration: '4 min',
      hue: 104,
      flat: true,
      slotId: 'food/recipe/${r.id}',
    );
  }

  Widget _dietServesRow() => Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            foodDietMark(r.diet, size: 15),
            const SizedBox(width: 7),
            Text(r.diet == 'vegan' ? 'Vegan' : (r.veg ? 'Veg' : 'Non-veg'), style: ppBody(12.5, color: ppSoft, w: FontWeight.w600)),
          ]),
          Text('Serves ${r.serves}', style: ppBody(12.5, color: ppSoft, w: FontWeight.w600)),
          if (r.immunity)
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.shield_moon_outlined, size: 14, color: Color(0xFFC98A2B)),
              const SizedBox(width: 5),
              Text('Immunity', style: ppBody(12.5, color: const Color(0xFFC98A2B), w: FontWeight.w700)),
            ]),
        ],
      );

  // ---- stat strip ---------------------------------------------------------
  Widget _statStrip() => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          _stat('Prep', '${r.prepMin} min'),
          _div(),
          _stat('Cook', r.cookMin == 0 ? 'No-cook' : '${r.cookMin} min'),
          _div(),
          _stat('Level', r.difficulty),
          _div(),
          _stat('Age', r.ageTag),
        ]),
      );

  Widget _stat(String label, String value) => Expanded(
        child: Column(children: [
          Text(value, style: ppJakarta(13.5), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(label.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.5)),
        ]),
      );

  Widget _div() => Container(width: 1, height: 26, color: ppLine);

  // ---- healthier version (signature) --------------------------------------
  // RETIRED - see the build order above. Kept for revert.
  // ignore: unused_element
  Widget _healthierCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFF6ECEF)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.volunteer_activism_outlined, size: 16, color: ppPurple),
            const SizedBox(width: 8),
            ppEyebrow('Healthier version', color: ppPurple, spacing: 1.0),
          ]),
          const SizedBox(height: 14),
          // toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
            child: Row(children: [
              _seg('Everyday', !_healthier, () => setState(() => _healthier = false)),
              _seg('ParentVeda', _healthier, () => setState(() => _healthier = true)),
            ]),
          ),
          const SizedBox(height: 14),
          if (_healthier)
            Text(r.healthierNote, style: ppBody(13.5, color: ppInk, h: 1.55))
          else
            Text(
              'The way it’s usually made leans on sugar, refined flour or deep-frying. Tap “ParentVeda” to see the small changes that make the same dish genuinely better for your baby - without losing what he loves.',
              style: ppBody(13.5, color: ppSoft, h: 1.55),
            ),
        ]),
      );

  Widget _seg(String label, bool on, VoidCallback onTap) => Expanded(
        child: PvPress(child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? ppPurple : Colors.transparent, borderRadius: BorderRadius.circular(999)),
            child: Text(label, style: ppBody(12.5, color: on ? Colors.white : ppSoft, w: FontWeight.w700)),
          ),
        )),
      );

  // ---- ingredients + equipment, side by side ------------------------------
  //  Ingredients left, kit right. Finding out you needed a blender halfway
  //  through is what turns a recipe into an abandoned mess, so the equipment
  //  is called out before the first step, not buried inside one.
  Widget _ingredients() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 3,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ingredients', style: ppJakarta(17)),
            const SizedBox(height: 12),
            for (final ing in r.ingredients)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(margin: const EdgeInsets.only(top: 7), width: 6, height: 6, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(ing, style: ppBody(13.5, color: ppInk, h: 1.4))),
                ]),
              ),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('You will need', style: ppJakarta(17)),
            const SizedBox(height: 12),
            for (final eq in _equipmentFor(r))
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_rounded, size: 14, color: ppPurple),
                  const SizedBox(width: 8),
                  Expanded(child: Text(eq, style: ppBody(13.5, color: ppInk, h: 1.4))),
                ]),
              ),
          ]),
        ),
      ]);

  /// The two or three things that actually decide whether this recipe is
  /// possible tonight. Authored per-recipe where we have it; otherwise inferred
  /// from the steps, since "spoon and plate" is not worth listing.
  List<String> _equipmentFor(FoodRecipe r) {
    if (r.equipment.isNotEmpty) return r.equipment;
    final text = '${r.steps.join(' ')} ${r.title}'.toLowerCase();
    final out = <String>[];
    void add(String label, List<String> cues) {
      if (cues.any(text.contains) && !out.contains(label)) out.add(label);
    }
    add('Blender or mixie', ['blend', 'puree', 'purée', 'grind', 'smooth paste']);
    add('Pressure cooker', ['pressure cook', 'cooker', 'whistle']);
    add('Steamer', ['steam']);
    add('Grater', ['grate']);
    add('Sieve or strainer', ['sieve', 'strain']);
    add('Non-stick pan', ['pan', 'sauté', 'saute', 'roast', 'tawa']);
    add('Saucepan', ['boil', 'simmer']);
    if (out.isEmpty) out.add('Just a bowl and spoon');
    return out.take(3).toList();
  }

  Widget _steps() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('How to make it', style: ppJakarta(17)),
        const SizedBox(height: 14),
        for (int i = 0; i < r.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                child: Text('${i + 1}', style: ppBody(12.5, color: ppPurple, w: FontWeight.w800)),
              ),
              const SizedBox(width: 13),
              Expanded(child: Text(r.steps[i], style: ppBody(14, color: ppInk, h: 1.5))),
            ]),
          ),
      ]);

  Widget _addToShopping() => PvPress(child: GestureDetector(
        onTap: () {
          FoodStore.instance.addRecipeToShopping(r);
          pvToast(context, 'Ingredients added to your shopping list',
              kind: PvToastKind.done, action: 'View', onAction: () => _push(const FoodShoppingScreen()));
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_shopping_cart_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text('Add ingredients to shopping list', style: ppBody(13.5, color: Colors.white, w: FontWeight.w700)),
          ]),
        ),
      ));

  // ---- nutrition breakdown ------------------------------------------------
  Widget _nutrition() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Nutrition breakdown', style: ppJakarta(17)),
        const SizedBox(height: 4),
        Text('What’s in it, and why it helps him - no calorie counting.', style: ppBody(12.5, color: ppMuted)),
        const SizedBox(height: 14),
        for (final n in r.nutrients)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(n.name, style: ppJakarta(14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                      child: Text(n.amount, style: ppBody(10.5, color: ppPurple, w: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 5),
                  Text(n.note, style: ppBody(12.5, h: 1.4)),
                ]),
              ),
            ]),
          ),
      ]);

  Widget _why() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow('Why this is good for him', color: ppPurple, spacing: 0.8),
          const SizedBox(height: 10),
          Text(_fill(r.why), style: ppBody(14, color: ppInk, h: 1.6)),
        ]),
      );

  Widget _bulletsSection(String title, List<(String, String)> rows, IconData icon) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: ppJakarta(17)),
        const SizedBox(height: 12),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 16, color: ppPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '${row.$1}: ', style: ppBody(13.5, color: ppInk, w: FontWeight.w700)),
                  TextSpan(text: row.$2, style: ppBody(13.5, color: ppSoft)),
                ]), style: const TextStyle(height: 1.5)),
              ),
            ]),
          ),
      ]);

  Widget _mistakes() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Watch out for', style: ppJakarta(17)),
        const SizedBox(height: 12),
        for (final m in r.mistakes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.error_outline_rounded, size: 16, color: ppCoral),
              const SizedBox(width: 12),
              Expanded(child: Text(m, style: ppBody(13.5, color: ppInk, h: 1.5))),
            ]),
          ),
      ]);

  Widget _subs() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Swaps & substitutions', style: ppJakarta(17)),
        const SizedBox(height: 12),
        for (final e in r.substitutions.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '${e.key} ', style: ppBody(13.5, color: ppInk, w: FontWeight.w700)),
              TextSpan(text: '→ ${e.value}', style: ppBody(13.5, color: ppSoft)),
            ]), style: const TextStyle(height: 1.5)),
          ),
      ]);

  // ---- related (ecosystem) ------------------------------------------------
  Widget _related({String title = 'Connected in ParentVeda'}) {
    final rows = <(IconData, String, String, VoidCallback)>[
      // Was () => _push(const ArticleReaderScreen()): the sleep piece (2026-10-25).
      if (r.relatedArticle != null) (Icons.menu_book_outlined, 'Article', _fill(r.relatedArticle!), _openRelatedArticle),
      if (r.relatedVideoId != null)
        (Icons.play_circle_outline, 'Watch', watchVideoById(r.relatedVideoId!).title, () {
          final v = watchVideoById(r.relatedVideoId!);
          _push(v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v));
        }),
      // NATIVE DISCOVERY (BrandSlot.nativeDiscovery): a product named inside
      // content routes through the guide check, so a parent who taps it lands
      // on the trusted in-depth Guide when one exists rather than straight on a
      // buy page. Never dressed as an advertisement - it is the product the
      // recipe already mentions.
      if (r.relatedProductId != null)
        (
          Icons.shopping_bag_outlined,
          'Product',
          productById(r.relatedProductId!).name,
          () => openProductWithGuideCheck(
                context,
                id: productById(r.relatedProductId!).id,
                name: productById(r.relatedProductId!).name,
                onOpenNormal: () => _push(ProductDetailScreen(product: productById(r.relatedProductId!))),
              )
        ),
      // Community is out of parenting for now (2026-10-07). Kept for revert:
      // if (r.relatedCommunity != null) (Icons.groups_outlined, 'Community', r.relatedCommunity!, () => openPpTab(context, 3)),
      // Re-enabled 2026-10-28 for the new community (openPpTab 3 opens lib/screens/community).
      if (r.relatedCommunity != null) (Icons.groups_outlined, 'Community', r.relatedCommunity!, () => openPpTab(context, 3)),
      (Icons.auto_awesome_outlined, 'Ask Veda', 'Ask about feeding at ${r.ageTag}', () => openPpTab(context, 1)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: title == 'Connected in ParentVeda' ? ppJakarta(17) : pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, color: ppInk)),
      const SizedBox(height: 14),
      for (final row in rows)
        PvPress(child: GestureDetector(
          onTap: row.$4,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
            child: Row(children: [
              // The Ask Veda row draws the Ask Veda mark (2026-10-24).
              row.$2 == 'Ask Veda'
                  ? const AskVedaMark(size: 38)
                  : Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: Icon(row.$1, size: 18, color: ppPurple)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(row.$2.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                  const SizedBox(height: 3),
                  Text(row.$3, style: ppBody(13.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
            ]),
          ),
        )),
    ]);
  }
  // ===========================================================================
  //  THE DOC-FORMAT PAGE (2026-10-15) — piloted on Mixed dal khichdi
  // ---------------------------------------------------------------------------
  //  Mobbin §21 (docs/MOBBIN-DISCOVERY.md). What every recipe app agrees on:
  //  the dish photo first, back and save as rounds ON it (Lifesum, NYT,
  //  Instacart, Yazio); the title in a serif and one line under it; ONE facts
  //  strip (Postmates' Servings | Prep | Cook, HelloFresh's Difficulty);
  //  quantities in their own column (Apple News, Crouton); numbered steps as
  //  cards with the minutes picked out (Crouton, Kitchen Stories); a cook
  //  mode (Recime, HelloFresh, and ours from pregnancy); nutrition low and
  //  plain (MyFitnessPal, Hers); one action pinned at the foot (Lifesum).
  //
  //  Ours, because this is a baby's food and no app in the library covers it:
  //  the AGE the dish is written for, set against the child's own age — the
  //  app derives it and never asks; the TEXTURE in the facts; and "Take care"
  //  as a calm block ruled on the left, never red.
  //
  //  Declined: calories and macro rings (no calorie counting, and the doc has
  //  none); a servings stepper (baby portions are fixed, and "1 tiny pinch"
  //  does not scale); ratings (we have none to show); Cherrypick's
  //  Ingredients / Method / Nutrition tabs (one scroll reads better with a
  //  baby on one arm).
  // ===========================================================================

  // ---- the child on the page (tools pass, Food, 2026-10-25) -----------------
  //  The dish copy says "he" and "his" about eighty times, and `ppFill` only
  //  fills `{child}`-style placeholders, so a girl's parent read "his iron
  //  stores". `ppFillChild` turns he/his into she/her, or the name when the
  //  profile has no sex given; the placeholders still fill first.
  static String _fill(String s) => ppFillChild(ppFill(s));

  /// The related article, by its title in the archive, through the one reader.
  /// It opened `ArticleReaderScreen()` with no article, so it always drew the
  /// default sleep piece under a feeding label.
  void _openRelatedArticle() {
    final a = kArticles.where((x) => x.title == r.relatedArticle).firstOrNull;
    if (a == null) {
      pvToast(context, 'That article is still being written. Ask Veda can answer it now.');
      return;
    }
    _push(ArticleReaderScreen(article: a));
  }

  void _askVeda() => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/ask_veda'),
        builder: (_) => AskVedaScreen(
            initialQuery: 'Is ${r.title} right for ${ChildProfileStore.instance.nameMid} at '
                '${ChildProfileStore.instance.ageLabel}?'),
      ));

  /// "We made this": the dish joins what you have cooked. Toast with Undo.
  Widget _madeThis(V2Palette p) => AnimatedBuilder(
        animation: FoodStore.instance,
        builder: (context, _) {
          final made = FoodStore.instance.isCooked(r.id);
          return PvSecondary(
            key: const ValueKey('pp_recipe_made'),
            label: made ? 'You made this' : 'We made this',
            icon: made ? Icons.check_rounded : null,
            onTap: () {
              if (made) {
                FoodStore.instance.unmarkCooked(r.id);
                pvToast(context, 'Removed from what you have made',
                    action: 'Undo', onAction: () => FoodStore.instance.markCooked(r.id));
              } else {
                FoodStore.instance.markCooked(r.id);
                pvToast(context, 'Saved: you made ${r.title}',
                    action: 'Undo', onAction: () => FoodStore.instance.unmarkCooked(r.id));
              }
            },
          );
        },
      );

  /// An allergy on the child's record that this dish touches (D2: always warn).
  Widget? _allergyCallout() {
    final a = ppAllergyMatch([r.title, ...r.ingredients]);
    if (a == null) return null;
    return PpAllergyCallout(allergy: a, childName: ChildProfileStore.instance.nameMid);
  }

  Widget _buildDocPage(BuildContext context) {
    final p = pvStorePalette;
    return AnimatedBuilder(
      animation: foodListenable,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: _docBar(p),
        body: ListView(
          key: const ValueKey('pp_recipe_doc_page'),
          padding: EdgeInsets.zero,
          children: [
            _docHero(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${foodAgeLabel(r.ageTag)} · ${r.category}'.toUpperCase(),
                    style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
                const SizedBox(height: 8),
                Text(r.title,
                    style: pvFraunces(fontSize: 30, fontWeight: FontWeight.w600, height: 1.12, letterSpacing: -0.3, color: p.ink1)),
                const SizedBox(height: 8),
                Text(_fill(r.subtitle), style: pvManrope(fontSize: 15.5, height: 1.5, color: p.ink2)),
                const SizedBox(height: 12),
                _docMetaLine(p),
                const SizedBox(height: 18),
                _docFacts(p),
                const SizedBox(height: 12),
                _docAgeFit(p),
                if (_allergyCallout() case final w?) ...[
                  const SizedBox(height: 12),
                  w,
                ],
                _docSection(p, 'Why this is good for ${ChildProfileStore.instance.them}'),
                Text(_fill(r.why), style: _docBody(p)),
                _docSection(p, 'What you need', side: 'Serves ${r.serves}'),
                _docIngredients(p),
                if (r.equipment.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('You’ll also need',
                      style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink2)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final e in r.equipment) _docChip(p, Icons.soup_kitchen_outlined, _cap(e.replaceFirst(RegExp(r'^an? '), ''))),
                  ]),
                ],
                _docSection(p, 'How to make it', sub: '${r.steps.length} steps. Cook step by step reads them one at a time.'),
                for (var i = 0; i < r.steps.length; i++) _docStep(p, i),
                const SizedBox(height: 14),
                _madeThis(p),
                if (r.nutrients.isNotEmpty) ...[
                  _docSection(p, 'What’s in it'),
                  _docNutrients(p),
                ],
                _docSection(p, 'Good to know'),
                _docGoodToKnow(p),
                if (r.mistakes.isNotEmpty) ...[
                  _docSection(p, 'Take care'),
                  _docTakeCare(p),
                ],
                if (r.substitutions.isNotEmpty) ...[
                  _docSection(p, 'You can swap'),
                  for (final e in r.substitutions.entries) _docSwap(p, e.key, e.value),
                ],
                const SizedBox(height: 30),
                // Was _related(title: 'More on ParentVeda'): the old page's rows,
                // a purple mark in a lilac well. Kept for revert.
                _docRelated(p),
                const SizedBox(height: 18),
                Text('By ParentVeda team', style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink3)),
                const SizedBox(height: 10),
                const PpFoodDisclaimer(),
                const SizedBox(height: 28),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _docBody(V2Palette p) => pvManrope(fontSize: 15, height: 1.6, color: p.ink1);

  // ---- more on ParentVeda: plain rows, ink marks, grey hairline -------------
  // 2026-10-17 (the user: "old UI hints, the lavender background some places,
  // pink purple"). The shared _related rows put a purple mark in a lilac well
  // with lavender-grey labels. Mobbin: Kitchen Stories, Alma and Yazio all end
  // a recipe with white rows, a grey hairline and ink icons; none tints them.
  // Same rows and taps as _related, in the house palette.
  Widget _docRelated(V2Palette p) {
    final rows = <(IconData, String, String, VoidCallback)>[
      // Was () => _push(const ArticleReaderScreen()): the sleep piece (2026-10-25).
      if (r.relatedArticle != null) (Icons.menu_book_outlined, 'Article', _fill(r.relatedArticle!), _openRelatedArticle),
      if (r.relatedVideoId != null)
        (Icons.play_circle_outline, 'Watch', watchVideoById(r.relatedVideoId!).title, () {
          final v = watchVideoById(r.relatedVideoId!);
          _push(v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v));
        }),
      if (r.relatedProductId != null)
        (
          Icons.shopping_bag_outlined,
          'Product',
          productById(r.relatedProductId!).name,
          () => openProductWithGuideCheck(
                context,
                id: productById(r.relatedProductId!).id,
                name: productById(r.relatedProductId!).name,
                onOpenNormal: () => _push(ProductDetailScreen(product: productById(r.relatedProductId!))),
              )
        ),
      // Was () => openPpTab(context, 1): Ask Veda with nothing typed (2026-10-25).
      (Icons.auto_awesome_outlined, 'Ask Veda', 'Ask about feeding at ${foodAgeLabel(r.ageTag)}', _askVeda),
    ];
    return Column(
      key: const ValueKey('pp_recipe_doc_related'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('More on ParentVeda', style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 14),
        for (final row in rows)
          PvPress(child: GestureDetector(
            onTap: row.$4,
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: p.line)),
              child: Row(children: [
                // The Ask Veda row draws the Ask Veda mark (2026-10-24).
                row.$2 == 'Ask Veda'
                    ? const AskVedaMark(size: 38)
                    : Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(11)),
                        child: Icon(row.$1, size: 18, color: p.ink1),
                      ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(row.$2.toUpperCase(),
                        style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: p.ink3)),
                    const SizedBox(height: 3),
                    Text(row.$3,
                        style: pvManrope(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
              ]),
            ),
          )),
      ],
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _lowerFirst(String s) => s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

  Widget _docSection(V2Palette p, String title, {String? side, String? sub}) => Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Text(title, style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, color: p.ink1))),
            if (side != null) Text(side, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
          ]),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink3)),
          ],
        ]),
      );

  // ---- the photo, with back and save on it ---------------------------------
  Widget _docHero(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final top = MediaQuery.paddingOf(context).top;
    final saved = FoodStore.instance.isSaved(r.id);
    return Stack(children: [
      FoodPhoto(recipe: r, height: w * 0.75 + top, radius: 0),
      Positioned(
        top: top + 8,
        left: 14,
        child: Semantics(
          button: true,
          label: 'Back',
          child: _round(Icons.arrow_back, () => Navigator.of(context).maybePop()),
        ),
      ),
      Positioned(
        top: top + 8,
        right: 14,
        child: Semantics(
          button: true,
          label: saved ? 'Saved. Tap to remove' : 'Save recipe',
          child: KeyedSubtree(
            key: const ValueKey('pp_recipe_save'),
            child: _round(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, () {
              void flip() => FoodStore.instance.toggleSave(r.id);
              flip();
              final nav = Navigator.of(context);
              pvSaveToast(context,
                  nowSaved: !saved,
                  undo: flip,
                  where: 'Saved to your recipes',
                  onView: () => nav.push(MaterialPageRoute<void>(builder: (_) => const FoodSavedScreen())));
            }),
          ),
        ),
      ),
    ]);
  }

  // ---- diet · serves · meal role -------------------------------------------
  Widget _docMetaLine(V2Palette p) {
    final style = pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2);
    Widget sep() => Text('  ·  ', style: style);
    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
      foodDietMark(r.diet, size: 14),
      const SizedBox(width: 7),
      Text(r.vegLabel, style: style),
      sep(),
      Text('Serves ${r.serves}', style: style),
      if (r.mealRole != null) ...[sep(), Text(r.mealRole!, style: style)],
    ]);
  }

  // ---- Prep | Cook | Level | Texture ---------------------------------------
  Widget _docFacts(V2Palette p) {
    Widget cell(String value, String label) => Expanded(
          child: Column(children: [
            Text(value,
                style: pvJakarta(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(label,
                style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: p.ink3)),
          ]),
        );
    Widget rule() => Container(width: 1, height: 28, color: p.line);
    return Container(
      key: const ValueKey('pp_recipe_doc_facts'),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
      child: Row(children: [
        cell('${r.prepMin} min', 'PREP'),
        rule(),
        cell(r.cookMin == 0 ? 'No-cook' : '${r.cookMin} min', 'COOK'),
        rule(),
        cell(r.difficulty, 'LEVEL'),
        rule(),
        if (r.texture != null) cell(r.texture!, 'TEXTURE') else cell(foodAgeLabel(r.ageTag), 'AGE'),
      ]),
    );
  }

  // ---- is it right for her child now? Derived, never asked -----------------
  Widget _docAgeFit(V2Palette p) {
    final c = ChildProfileStore.instance;
    final months = c.devAgeInMonths;
    final range = ppRecipeAgeRange(r.ageTag);
    final made = 'Made for ${foodAgeLabel(r.ageTag)}';
    final (IconData icon, String line) = range == null || (months >= range.$1 && months <= range.$2)
        ? (Icons.check_circle_outline_rounded, 'Right for ${c.nameMid} now, at $months months.')
        : months < range.$1
            ? (Icons.schedule_rounded, '$made, and ${c.nameMid} is $months months. One to keep for when ${c.they} gets there.')
            : (Icons.trending_up_rounded, '$made, and ${c.nameMid} is $months months. Still a good meal; ${c.they} may be ready for more texture now.');
    return Container(
      key: const ValueKey('pp_recipe_doc_agefit'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(14)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: p.ink1),
        const SizedBox(width: 10),
        Expanded(child: Text(line, style: pvManrope(fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w600, color: p.ink1))),
      ]),
    );
  }

  // ---- ingredients: amount in its own column, Add on each row --------------
  Widget _docIngredients(V2Palette p) {
    final shop = FoodStore.instance.shopping;
    return Column(children: [
      for (var i = 0; i < r.ingredients.length; i++)
        Container(
          key: ValueKey('pp_recipe_ing_$i'),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // The amount column only when the dish has one: the older dishes
            // keep the quantity inside the ingredient line.
            if (r.amounts.isNotEmpty) ...[
              SizedBox(
                width: 118,
                child: Text(i < r.amounts.length ? r.amounts[i] : '',
                    style: pvJakarta(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.35, color: p.ink1)),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(r.ingredients[i], style: pvManrope(fontSize: 14.5, height: 1.4, color: p.ink1))),
            if (foodShoppable(r.ingredients[i])) ...[
              const SizedBox(width: 10),
              _docAddOne(p, r.ingredients[i], shop.containsKey(r.ingredients[i])),
            ] else
              const SizedBox(width: 42),
          ]),
        ),
    ]);
  }

  Widget _docAddOne(V2Palette p, String line, bool on) => Semantics(
        button: true,
        label: on ? '$line is on your list. Tap to remove' : 'Add $line to your list',
        child: PvPress(child: GestureDetector(
          key: ValueKey('pp_recipe_add_$line'),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) {
              FoodStore.instance.removeLine(line);
            } else {
              FoodStore.instance.addLines([line]);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? p.ink1 : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: on ? p.ink1 : p.line, width: 1.2),
            ),
            child: Icon(on ? Icons.check_rounded : Icons.add_rounded, size: 17, color: on ? Colors.white : p.ink1),
          ),
        )),
      );

  Widget _docChip(V2Palette p, IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: p.line)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: p.ink2),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink1))),
        ]),
      );

  // ---- one card per step, the minutes picked out ---------------------------
  static final RegExp _minutes = RegExp(r'(about )?\d+(\s*[–-]\s*\d+)?\s*(minutes?|min|hours?)\b');

  Widget _docStep(V2Palette p, int i) {
    final text = _fill(r.steps[i]);
    final spans = <TextSpan>[];
    var at = 0;
    for (final m in _minutes.allMatches(text)) {
      if (m.start > at) spans.add(TextSpan(text: text.substring(at, m.start)));
      spans.add(TextSpan(text: m.group(0), style: const TextStyle(fontWeight: FontWeight.w800)));
      at = m.end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return Container(
      key: ValueKey('pp_recipe_step_$i'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle),
          child: Text('${i + 1}', style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text.rich(TextSpan(children: spans), style: _docBody(p)),
          ),
        ),
      ]),
    );
  }

  // ---- what's in it: the nutrient and where it comes from, no numbers ------
  Widget _docNutrients(V2Palette p) => LayoutBuilder(
        builder: (context, box) {
          final w = (box.maxWidth - 10) / 2;
          return Wrap(spacing: 10, runSpacing: 10, children: [
            for (final n in r.nutrients)
              Container(
                width: w,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n.name, style: pvJakarta(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                  const SizedBox(height: 4),
                  // Only the first letter is lowered: a doc note can carry
                  // "vitamin-C" or "(tomato/lemon)" later in the line, and
                  // lowering the whole note printed "vitamin-c".
                  Text('From ${_lowerFirst(_fill(n.note).replaceAll(RegExp(r'\.$'), ''))}',
                      style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
                ]),
              ),
          ]);
        },
      );

  // ---- how often · storing ----------------------------------------------------
  Widget _docGoodToKnow(V2Palette p) {
    Widget tile(IconData icon, String label, String text) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 18, color: p.ink1),
              const SizedBox(height: 8),
              Text(label, style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: p.ink3)),
              const SizedBox(height: 4),
              Text(text, style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink1)),
            ]),
          ),
        );
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        tile(Icons.event_repeat_outlined, 'HOW OFTEN', r.frequency),
        const SizedBox(width: 10),
        tile(Icons.kitchen_outlined, 'STORING', r.storage.join(' ')),
      ]),
    );
  }

  // ---- take care: calm, ruled on the left, never red ------------------------
  Widget _docTakeCare(V2Palette p) => Container(
        key: const ValueKey('pp_recipe_doc_takecare'),
        padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: p.ink1, width: 3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final m in r.mistakes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(_fill(m), style: _docBody(p)),
            ),
        ]),
      );

  // A swap with nothing after it is a note in the doc ("change the vegetables
  // each time", "add a little mashed carrot"): the line alone, no arrow.
  Widget _docSwap(V2Palette p, String from, String to) => to.isEmpty
      ? Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(_cap(from), style: pvManrope(fontSize: 14.5, height: 1.45, color: p.ink1)),
        )
      : Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Flexible(child: Text(_cap(from), style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.swap_horiz_rounded, size: 18, color: p.ink3),
          ),
          Flexible(child: Text(_cap(to), style: pvManrope(fontSize: 14.5, color: p.ink1))),
        ]),
      );

  // ---- the pinned foot: add everything, or cook it --------------------------
  Widget _docBar(V2Palette p) => Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: p.line))),
        child: Row(children: [
          Expanded(
            child: PvSecondary(
              key: const ValueKey('pp_recipe_shop'),
              label: 'Add all to list',
              icon: Icons.shopping_basket_outlined,
              onTap: () {
                FoodStore.instance.addRecipeToShopping(r);
                // pvToast, the one notice (toasts pass, 1b3f04e). The Material
                // SnackBar it replaces took the theme's purple. Mobbin: Recime's
                // "6 items added · View groceries" is the same shape. Lifted
                // over the pinned foot so it never covers the two buttons.
                pvToast(context, 'Added to your shopping list',
                    kind: PvToastKind.done,
                    action: 'View',
                    onAction: () => _push(const FoodShoppingScreen()),
                    lift: 84);
                // Kept for revert:
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //   content: const Text('Ingredients added to your shopping list'),
                //   behavior: SnackBarBehavior.floating,
                //   action: SnackBarAction(label: 'View', onPressed: () => _push(const FoodShoppingScreen())),
                // ));
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PvCommit(
              key: const ValueKey('pp_recipe_cook'),
              label: 'Cook step by step',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: RouteSettings(name: 'pp/recipe/${r.id}/cook'),
                builder: (_) => CookModeScreen.steps(
                  title: r.title,
                  steps: [for (final s in r.steps) _fill(s)],
                  ingredientLines: [
                    for (var i = 0; i < r.ingredients.length; i++)
                      i < r.amounts.length ? '${r.amounts[i]}  ${r.ingredients[i]}' : r.ingredients[i],
                  ],
                  enjoyLine: '${r.title} · cool it till just warm before ${ChildProfileStore.instance.they} eats.',
                  photo: FoodPhoto(recipe: r, height: double.infinity, radius: 0),
                ),
              )),
            ),
          ),
        ]),
      );
}
