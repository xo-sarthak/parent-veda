// =============================================================================
//  Nutrition — landing
// -----------------------------------------------------------------------------
//  Five doors, one search, one small persistent disclaimer, and two shortcuts
//  (Diet charts, Fasting) that do not fit the five-tile shape but are full
//  sections in their own right (§6, §7 of the brief). Everything reachable
//  from here is free — see the header of `nutrition_data.dart` and
//  `ExpertOptionsBlock` in `nutrition_stage_screen.dart` for the one place
//  money appears.
//
//  Visual language matches the newest hub screens (`problem_hub_screen.dart`):
//  `V2Palette`, `pvFraunces` / `pvManrope`, outlined-pill buttons, no filled
//  violet. English only for now — see `nutrition_data.dart`'s header.
//
//  ⚠️ INTEGRATION: call `nutritionHomeScreen(pregnancy: ...)` to get the entry
//  widget. This file does not register a route; the integrator pushes it from
//  wherever Nutrition is meant to open (Tools hub, a home tile, etc).
//
//  ⚠️ IT TAKES THE PREGNANCY CONTROLLER NOW, AND THAT IS NOT PLUMBING FOR ITS
//  OWN SAKE. Two screens under this one — Cravings and Diet charts — were
//  rebuilt to answer at HER stage rather than in general, and neither can do
//  that without her week. The landing itself barely uses it; it is a conduit,
//  and the alternative (each child reaching for a singleton) is how a screen
//  ends up impossible to test with a fixed week.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../prepare/consultations_screen.dart';
import '../v2/v2_palette.dart';
import 'cravings_screen.dart';
import 'diet_charts_screen.dart';
import 'fasting_screen.dart';
import 'food_verdict_screen.dart';
import 'nutrients_screen.dart';
import 'nutrition_recipes_screen.dart';
import 'nutrition_stage_screen.dart';

/// The entry point the integrator routes to.
Widget nutritionHomeScreen({required PregnancyController pregnancy}) =>
    NutritionHomeScreen(pregnancy: pregnancy);

/// ⚠️ THE NUTRITIONIST THIS SECTION POINTS AT, NAMED ONCE.
///
/// Same rule as `kScanConsultRole` on the scans side: the card's words and the
/// filter it applies are one fact, and a literal at the call site is how they
/// drift. `sp_nutrition` is the Prenatal Nutritionist in `prepare_data.dart`.
const String kNutritionConsultRole = 'sp_nutrition';

class NutritionHomeScreen extends StatelessWidget {
  const NutritionHomeScreen({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
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
            title: Text('Nutrition',
                style: pvFraunces(
                    fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text('Eating well for you and your baby, made simple',
                    style: pvManrope(fontSize: 14, height: 1.4, color: p.ink2)),
                const SizedBox(height: 18),
                _SearchBar(p: p, onTap: () => openFoodSearch(context)),
                const SizedBox(height: 22),
                _Tile(
                  p: p,
                  hue: V2NutritionHues.canIEat,
                  icon: Icons.help_outline_rounded,
                  title: 'Can I eat this?',
                  blurb: 'Search any food and get a calm, clear answer.',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const FoodCheckScreen(),
                  )),
                ),
                const SizedBox(height: 10),
                _Tile(
                  p: p,
                  hue: V2NutritionHues.stage,
                  icon: Icons.timeline_rounded,
                  title: 'Food for my stage',
                  blurb: 'By trimester, or by a condition you are managing.',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NutritionStageScreen(),
                  )),
                ),
                const SizedBox(height: 10),
                _Tile(
                  p: p,
                  hue: V2NutritionHues.nutrients,
                  icon: Icons.spa_outlined,
                  title: 'Nutrients',
                  blurb: 'What each one does, and where to find it in a thali.',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NutrientsScreen(),
                  )),
                ),
                const SizedBox(height: 10),
                _Tile(
                  p: p,
                  hue: V2NutritionHues.recipes,
                  icon: Icons.soup_kitchen_outlined,
                  title: 'Recipes',
                  blurb: 'Real Indian recipes, filtered by what you need.',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NutritionRecipesScreen(),
                  )),
                ),
                const SizedBox(height: 10),
                _Tile(
                  p: p,
                  hue: V2NutritionHues.cravings,
                  icon: Icons.favorite_border_rounded,
                  title: 'Cravings',
                  blurb: 'Why they happen, and what is worth mentioning.',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CravingsScreen(pregnancy: pregnancy),
                  )),
                ),
                const SizedBox(height: 20),

                // ---- THE ONE PAID THING, SAID PLAINLY --------------------
                //
                // ⚠️ ON THE LANDING SCREEN, NOT BURIED THREE TAPS DOWN.
                // Review: "consult expert nutritionist to get customized diet
                // plan should be a clear option on main Nutrition landing
                // screen." It previously lived only inside
                // `ExpertOptionsBlock` on the stage screen, which meant the
                // one thing in this section a mother might actually want to
                // buy was reachable only by someone already browsing
                // trimester guidance.
                //
                // ⚠️ IT SITS AFTER THE FIVE FREE DOORS, NOT BEFORE THEM. This
                // section's whole promise is that everything in it is free;
                // opening with a paid tile would reframe the free content as
                // a sample of something better. Clear and findable is the
                // ask — first is not.
                //
                // ⚠️ AND IT NAMES WHAT IT IS. "Get a plan built around your
                // trimester, your condition and what you actually eat" is the
                // honest difference between this and the fourteen free charts
                // above it. A vague "talk to an expert" would be selling the
                // absence of information.
                _ConsultCard(
                  p: p,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      settings: const RouteSettings(name: 'consults'),
                      builder: (_) => ConsultationsScreen(
                          lang: pregnancy.language,
                          onlyRole: kNutritionConsultRole),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _GuidanceCard(p: p),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                    child: _Shortcut(
                      p: p,
                      icon: Icons.receipt_long_rounded,
                      label: 'Diet charts',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DietChartsScreen(pregnancy: pregnancy),
                      )),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Shortcut(
                      p: p,
                      icon: Icons.nights_stay_outlined,
                      label: 'Fasting',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const FastingScreen(),
                      )),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Hues for the five doors, off the app's controlled wheel. Kept local to
/// Nutrition since these tiles do not appear anywhere else in the app.
class V2NutritionHues {
  static const canIEat = 344.0; // dusty rose
  static const stage = 26.0; // peach
  static const nutrients = 104.0; // sage
  static const recipes = 42.0; // sand
  static const cravings = 268.0; // soft violet
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.p, required this.onTap});
  final V2Palette p;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Icon(Icons.search_rounded, color: p.ink3, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Type any food',
                  style: pvManrope(fontSize: 14, color: p.ink3)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.p,
    required this.hue,
    required this.icon,
    required this.title,
    required this.blurb,
    required this.onTap,
  });

  final V2Palette p;
  final double hue;
  final IconData icon;
  final String title;
  final String blurb;
  final VoidCallback onTap;

  Color _shift(Color c, double d) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + d).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_shift(tint, 0.045), _shift(tint, -0.045)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  size: 24,
                  color: HSLColor.fromColor(tint)
                      .withSaturation(0.46)
                      .withLightness(0.38)
                      .toColor()),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: pvFraunces(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: p.ink1)),
                const SizedBox(height: 3),
                Text(blurb,
                    style: pvManrope(fontSize: 12.5, height: 1.35, color: p.ink2)),
              ]),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

/// "Talk to a nutritionist" — the section's one paid door.
///
/// ⚠️ IT LOOKS DIFFERENT FROM THE FIVE FREE TILES ON PURPOSE. A paid offer
/// dressed identically to free content is the shape that makes people
/// distrust an app: she taps what she thinks is another article and hits a
/// price. Filled rather than outlined, with the word "Paid" on it, so the
/// difference is visible before the tap rather than after it.
class _ConsultCard extends StatelessWidget {
  const _ConsultCard({required this.p, required this.onTap});

  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: p.action.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 14, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.action.withValues(alpha: 0.30)),
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person_outline_rounded, size: 22, color: p.action),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text('Talk to a nutritionist',
                                  style: pvFraunces(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: p.ink1)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: p.action,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('PAID',
                                  style: pvManrope(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: p.onAction)),
                            ),
                          ]),
                          const SizedBox(height: 5),
                          Text(
                              'A diet plan built around your trimester, any '
                              'condition you are managing, and what you '
                              'actually eat at home.',
                              style: pvManrope(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: p.ink2)),
                        ]),
                  ),
                ]),
          ),
        ),
      );
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.p});
  final V2Palette p;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, size: 16, color: p.ink3),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
              'This is general guidance. Anything specific to your health '
              'goes to your doctor or our dietician.',
              style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
        ),
      ]),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.p, required this.icon, required this.label, required this.onTap});
  final V2Palette p;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line, width: 1.2),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: p.ink2),
          const SizedBox(width: 7),
          Text(label,
              style: pvManrope(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
        ]),
      ),
    );
  }
}

