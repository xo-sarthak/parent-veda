// =============================================================================
//  Nutrition — one need: Eat today (rebuilt 2026-10-22)
// -----------------------------------------------------------------------------
//  The page behind each plate tick AND behind the home rail's "Eat today" card.
//  The user, walking the phone (2026-10-22): the Iron card dropped her at the
//  top of the Nutrition door, where nothing was about iron, while the Jaggery
//  card opened a page that "looks good, representative". So this page takes
//  the Jaggery page's shape (CanIVerdictScreen): a photo, the name, one clear
//  answer, then what to do about it today. Approved as drawn in the prototype
//  (artifact 1WKApV5Qck5tifamhY1TDH). Mobbin: Superpower's vitamin page
//  (question-led blocks), Withings' ingredient rows (a food with a short note
//  on the right).
//
//  It stays ONE page for both ways in: the rail and the door's long press.
//  Two pages for one nutrient would drift, and the tick here is the door's
//  tick, so the two screens agree by construction.
//
//  ⚠️ NO "MY DOCTOR SAID" ROW. That row records a yes or no on a food; nobody
//  gets a yes or no on iron. The tablet block defers to the doctor instead.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../data/nutrition_data.dart';
import '../../../data/reads/read_images.dart' show kReadImageCredits;
import '../../../services/family_profile.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/global_ask_fab.dart' show kAskVedaRoute;
import '../../../widgets/pv_feedback.dart';
import '../../can_i/can_i_widgets.dart' show CanIPhoto;
import '../../doors/pv_door_chrome.dart';
import '../../tools/ask_veda_screen.dart';
import '../../v2/v2_palette.dart';
import 'nutrition_widgets.dart';
import 'recipe_cook_screen.dart';

/// The photo for a need: the first of its foods we have a dish picture of,
/// as the read-image id (for the credit) and its URL. Null when none matches.
(String, String)? _needPhoto(List<String> foods) {
  for (final f in foods) {
    final id = nutritionDishIdFor(f);
    final url = nutritionPhotoFor(f);
    if (id != null && url != null) return (id, url);
  }
  return null;
}

/// What Send shares: the answer, the foods, and the doctor line.
String needShareText(PlateNeed need, NutrientGuide? guide, List<String> foods) {
  final b = StringBuffer('${need.label} in pregnancy\n\n');
  b.writeln(guide?.shortAnswer?.en ?? guide?.whatItDoes.en ?? need.line);
  if (foods.isNotEmpty) b.writeln('\nWhere to find it: ${foods.join(', ')}.');
  if (need.absorbLine != null) b.writeln(need.absorbLine);
  b.write('\nFrom ParentVeda. General guidance; your doctor sets any tablet and dose.');
  return b.toString();
}

class NeedScreen extends StatelessWidget {
  const NeedScreen({super.key, required this.need, required this.pregnancy});
  final PlateNeed need;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final guide = kNutrientGuides.where((g) => g.id == need.id).firstOrNull;
    final foods = [for (final f in plateFoodsFor(need)) f.en];
    final recipes = plateRecipesFor(need, diet: FamilyProfileStore.instance.diet);
    final photo = _needPhoto(foods);
    final credit = photo == null ? null : kReadImageCredits[photo.$1];
    final week = pregnancy.isDueDateSet ? pregnancy.currentWeek : null;
    final answer = guide?.shortAnswer?.en ?? guide?.whatItDoes.en ?? need.line;

    return AnimatedBuilder(
      animation: Listenable.merge([V2PaletteStore.instance, NutritionDayStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final store = NutritionDayStore.instance;
        final ticked = store.ticked(DateTime.now(), need.id);
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(slivers: [
            // ---- THE PHOTO, THEN THE BAR (the Jaggery page's pattern) ----
            SliverAppBar(
              pinned: true,
              expandedHeight: 260,
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
              actions: [
                _round(p, Icons.ios_share_rounded, () {
                  pvCommitFeedback();
                  Share.share(needShareText(need, guide, foods));
                }),
                const SizedBox(width: 12),
              ],
              flexibleSpace: LayoutBuilder(builder: (context, c) {
                final collapsed = c.maxHeight < 160;
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 64, bottom: 16, right: 80),
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: collapsed ? 1 : 0,
                    child: Text(need.label,
                        style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
                  ),
                  background: photo == null ? _well(p) : CanIPhoto(url: photo.$2, fallback: _well(p)),
                );
              }),
            ),
            SliverList.list(children: [
              if (credit != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: Text('Photo · $credit',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 10.5, color: p.ink3)),
                ),

              // ---- NAME AND THE ONE ANSWER -------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(week == null ? 'EAT TODAY' : 'EAT TODAY · WEEK $week',
                      style: pvManrope(
                          fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: p.ink2)),
                  const SizedBox(height: 6),
                  Text(need.label,
                      style: pvFraunces(
                          fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.6, height: 1.1, color: p.ink1)),
                  const SizedBox(height: 4),
                  Text('Why it matters, and how to get it', style: pvManrope(fontSize: 14, color: p.ink2)),
                  const SizedBox(height: 14),
                  Text(answer, style: pvManrope(fontSize: 16, height: 1.55, color: p.ink1)),
                ]),
              ),

              // ---- WHERE TO FIND IT --------------------------------------
              _rule(p, top: 22),
              // The line under the heading was 'No amounts, no grams. A
              // serving of any of the above is the tick.' under the button;
              // the user asked for the measure (2026-10-22). Kept for revert.
              _section(p, 'Where to find it',
                  sub: 'A serving of any one of these counts. The amounts are a guide, not a target.',
                  child: Column(children: [
                    for (final f in foods)
                      Container(
                        key: ValueKey('need_food_$f'),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(
                              child: Text(f,
                                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w600, color: p.ink1))),
                          if (platePortionFor(need.id, f) case final portion?)
                            Flexible(
                              child: Text(portion,
                                  textAlign: TextAlign.right,
                                  style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
                            ),
                        ]),
                      ),
                  ])),

              // ---- HELP IT ABSORB ----------------------------------------
              if (need.absorbLine case final line?)
                _section(p, 'Help it absorb',
                    top: 0, child: Text(line, style: pvManrope(fontSize: 15, height: 1.55, color: p.ink1))),

              // ---- THE TICK (the door's own tick) ------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Material(
                  color: p.ground,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    key: const ValueKey('need_tick'),
                    onTap: () {
                      pvCommitFeedback();
                      store.toggleTick(DateTime.now(), need.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ticked ? p.ink1 : Colors.transparent,
                            border: Border.all(color: p.ink1, width: 2),
                          ),
                          child: ticked ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(ticked ? 'Done for today' : 'I had ${need.label.toLowerCase()} today',
                                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                            Text(ticked ? 'Tap again if that was a mistake.' : 'Ticks it on your plate in Nutrition',
                                style: pvManrope(fontSize: 12.5, color: p.ink3)),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),

              // ---- COOK IT TODAY -----------------------------------------
              if (recipes.isNotEmpty) ...[
                _rule(p, top: 18),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                  child: nutritionHeading(p, 'Cook it today'),
                ),
                SizedBox(
                  height: 196,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: recipes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => RecipeCard(
                      p: p,
                      recipeId: recipes[i].id,
                      minutes: recipes[i].minutes,
                      name: recipes[i].name.en,
                      line: recipes[i].whyNow.en,
                      url: nutritionRecipePhoto(recipes[i].id, recipes[i].name.en),
                      onTap: () => openRecipe(context, recipes[i], pregnancy),
                    ),
                  ),
                ),
              ],

              // ---- ABOUT THE TABLET --------------------------------------
              if (guide != null) ...[
                _rule(p, top: 22),
                _section(p, 'About ${need.label.toLowerCase()} tablets',
                    child: Text(
                        '${guide.supplementNote.en} Take the one your doctor gives you, in the dose they set.',
                        style: pvManrope(fontSize: 15, height: 1.55, color: p.ink1))),
              ],

              // ---- SEND · ASK VEDA ---------------------------------------
              _rule(p),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        pvCommitFeedback();
                        Share.share(needShareText(need, guide, foods));
                      },
                      icon: const Icon(Icons.ios_share_rounded, size: 18),
                      label: const Text('Send'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        pvCommitFeedback();
                        Navigator.of(context).push(MaterialPageRoute<void>(
                          settings: const RouteSettings(name: kAskVedaRoute),
                          builder: (_) => AskVedaScreen(
                              controller: pregnancy,
                              initialQuery: 'How do I get enough ${need.label.toLowerCase()} in pregnancy?'),
                        ));
                      },
                      icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                      label: const Text('Ask Veda'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PvDoorDisclaimer(
                    p: p,
                    text: 'General guidance for a healthy pregnancy, not a prescription. Your prenatal tablet '
                        "and any dose are your doctor's to set. If your doctor has told you something "
                        'different, go with your doctor.'),
              ),
              const SizedBox(height: 28),
            ]),
          ]),
        );
      },
    );
  }

  Widget _well(V2Palette p) => ColoredBox(
        // Plain neutral grey, not surfaceAlt (lavender-grey; no lavender grounds).
        color: const Color(0xFFF2F2F3),
        child: Center(child: Icon(Icons.restaurant_outlined, size: 56, color: p.ink3)),
      );

  Widget _round(V2Palette p, IconData icon, VoidCallback onTap) => Material(
        color: Colors.white.withValues(alpha: 0.82),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onTap, child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: p.ink1))),
      );

  Widget _rule(V2Palette p, {double top = 0}) => Padding(
        padding: EdgeInsets.fromLTRB(20, top, 20, 0),
        child: Container(height: 1, color: p.line),
      );

  Widget _section(V2Palette p, String title, {String? sub, required Widget child, double top = 22}) => Padding(
        padding: EdgeInsets.fromLTRB(20, top, 20, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          nutritionHeading(p, title, sub: sub),
          const SizedBox(height: 12),
          child,
        ]),
      );
}

// ---- The first need page, kept for revert -----------------------------------
// A PvDoorToolScaffold with chips for the foods, the recipe rail, the tablet
// note and an "I had some today" button. Replaced by the Eat today layout above.
// class NeedScreen extends StatelessWidget {
//   const NeedScreen({super.key, required this.need, required this.pregnancy});
//   final PlateNeed need;
//   final PregnancyController pregnancy;
//
//   @override
//   Widget build(BuildContext context) {
//     final guide = kNutrientGuides.where((g) => g.id == need.id).firstOrNull;
//     final foods = plateFoodsFor(need);
//     final recipes = plateRecipesFor(need, diet: FamilyProfileStore.instance.diet);
//     return PvDoorToolScaffold(
//       hue: 104,
//       eyebrow: 'Did you get… · ${need.label}',
//       title: need.label,
//       intro: guide?.whatItDoes.en ?? need.line,
//       children: [
//         ListenableBuilder(
//           listenable: NutritionDayStore.instance,
//           builder: (context, _) {
//             final p = V2PaletteStore.instance.current;
//             final store = NutritionDayStore.instance;
//             final ticked = store.ticked(DateTime.now(), need.id);
//             return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               pvDoorPad(nutritionHeading(p, 'What counts', sub: 'Any one of these today, and the tick is honest.')),
//               const SizedBox(height: 12),
//               pvDoorPad(Wrap(spacing: 8, runSpacing: 8, children: [
//                 for (final f in foods)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                         color: p.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: p.line)),
//                     child: Text(f.en, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
//                   ),
//               ])),
//               if (recipes.isNotEmpty) ...[
//                 const SizedBox(height: 26),
//                 pvDoorPad(nutritionHeading(p, 'Recipes that give it')),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   height: 196,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
//                     itemCount: recipes.length,
//                     separatorBuilder: (_, _) => const SizedBox(width: 12),
//                     itemBuilder: (_, i) => RecipeCard(
//                       p: p,
//                       recipeId: recipes[i].id,
//                   minutes: recipes[i].minutes,
//                   name: recipes[i].name.en,
//                       line: recipes[i].whyNow.en,
//                       url: nutritionRecipePhoto(recipes[i].id, recipes[i].name.en),
//                       onTap: () => openRecipe(context, recipes[i], pregnancy),
//                     ),
//                   ),
//                 ),
//               ],
//               if (guide != null) ...[
//                 const SizedBox(height: 26),
//                 pvDoorPad(nutritionHeading(p, 'About the tablet')),
//                 const SizedBox(height: 8),
//                 pvDoorPad(Text(guide.supplementNote.en, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1))),
//               ],
//               const SizedBox(height: 26),
//               pvDoorPad(FilledButton.icon(
//                 onPressed: () {
//                   pvCommitFeedback();
//                   store.toggleTick(DateTime.now(), need.id);
//                 },
//                 icon: Icon(ticked ? Icons.check_rounded : Icons.add_rounded, size: 18),
//                 label: Text(ticked ? 'Done for today' : 'I had some today'),
//                 style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
//               )),
//               const SizedBox(height: 8),
//               pvDoorPad(Text(
//                   ticked ? 'Tap again if that was a mistake.' : 'No amounts, no grams. A serving of any of the above is the tick.',
//                   style: pvManrope(fontSize: 12, color: p.ink3))),
//               const SizedBox(height: 22),
//               pvDoorPad(PvDoorDisclaimer(
//                   p: p,
//                   text: 'General guidance. Your prenatal tablet and any dose are your doctor\'s to set; this page never replaces them.')),
//             ]);
//           },
//         ),
//       ],
//     );
//   }
// }
