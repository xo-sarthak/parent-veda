// =============================================================================
//  Belly & Skin — landing + area lists
// -----------------------------------------------------------------------------
//  A smaller, commerce-leaning section by design: content plus products, no
//  course, no consultation. Landing is one line of intro, then tiles for the
//  five areas, the Ingredient Safety Checker, and the bump photo ritual.
//  ⚠️ PRODUCTS GET NO TILE HERE — they only ever surface at the foot of a
//  relevant content page (see bs_article_screen.dart), never as their own
//  destination on this screen.
//
//  ⚠️ ENTRY POINT: `bellySkinHomeScreen()`. Nothing in this repo routes to it
//  yet — the integrator still has to add a door somewhere (Explore, Tools,
//  wherever this section is meant to live) that pushes it. That is
//  deliberate: this build owns five files and none of them is a navigation
//  host.
//
//  The optional `controller` parameter is the seam for the one piece of real
//  cross-feature wiring this section wants: "My Bump Journey"
//  (bump_journey_screen.dart) requires a live `PregnancyController`, which
//  this section has no way to construct on its own (there is no app-wide
//  singleton for it — every screen that needs one receives it explicitly).
//  Pass one in when wiring the real door and the ritual tile opens the actual
//  journey; omit it and the tile still renders — a feature is never hidden —
//  and instead explains where to find it, rather than crashing on a null.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/belly_skin_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../bump_journey_screen.dart';
import '../brackets/hub/hub_solution_cards.dart';
import '../v2/v2_palette.dart';
import 'bs_article_screen.dart';
import 'bs_itching_screen.dart';
import 'ingredient_checker_screen.dart';

const _lang = AppLanguage.english;

/// The integrator's entry point. See the file header for what still needs
/// wiring on the caller's side.
Widget bellySkinHomeScreen({PregnancyController? controller}) =>
    BellySkinHomeScreen(controller: controller);

class BellySkinHomeScreen extends StatelessWidget {
  const BellySkinHomeScreen({super.key, this.controller});
  final PregnancyController? controller;

  void _openArea(BuildContext context, BsArea area) {
    if (area == BsArea.itching) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'belly_skin/itching'),
        builder: (_) => BsItchingScreen(pregnancy: controller),
      ));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'belly_skin/area/${area.name}'),
      builder: (_) => BsAreaListScreen(area: area),
    ));
  }

  void _openChecker(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'belly_skin/checker'),
      builder: (_) => const IngredientCheckerScreen(),
    ));
  }

  void _openBumpRitual(BuildContext context) {
    if (controller != null) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'bump_journey'),
        builder: (_) => BumpJourneyScreen(controller: controller!),
      ));
      return;
    }
    // No controller to hand the ritual screen (see file header). Rather than
    // a dead tap, say where it actually lives today.
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RitualElsewhereSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;

    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        elevation: 0,
        foregroundColor: p.ink1,
        title: Text('Belly & Skin',
            style: pvJakarta(
                fontSize: 18, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        children: [
          Text('Your changing skin and bump, cared for simply',
              style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 22),
          for (final area in BsArea.values) ...[
            _AreaTile(
              info: kBsAreaInfo[area]!,
              p: p,
              onTap: () => _openArea(context, area),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          _ToolTile(
            title: 'Ingredient Safety Checker',
            blurb: 'Search any cream, serum or treatment. Free, always.',
            badge: 'FREE',
            icon: Icons.search_rounded,
            hue: 268,
            p: p,
            onTap: () => _openChecker(context),
          ),
          const SizedBox(height: 10),
          _ToolTile(
            title: 'The bump ritual',
            blurb: 'Your ongoing bump photos, the warm counterpart to the '
                'practical care above.',
            badge: null,
            icon: Icons.photo_camera_back_outlined,
            hue: 206,
            p: p,
            onTap: () => _openBumpRitual(context),
          ),
        ],
      ),
    );
  }
}

class _RitualElsewhereSheet extends StatelessWidget {
  const _RitualElsewhereSheet();
  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: p.line),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.photo_camera_back_outlined, size: 28, color: p.ink1),
          const SizedBox(height: 12),
          Text('Find My Bump Journey from Home or your Profile',
              textAlign: TextAlign.center,
              style: pvFraunces(
                  fontSize: 16.5, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 8),
          Text(
              'Your bump photos live there already, week by week.',
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
        ]),
      ),
    );
  }
}

class _AreaTile extends StatelessWidget {
  const _AreaTile({required this.info, required this.p, required this.onTap});
  final BsAreaInfo info;
  final V2Palette p;
  final VoidCallback onTap;

  Color _shift(Color c, double d) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + d).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(info.hue, p);
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
              child: Icon(Icons.spa_outlined,
                  size: 22,
                  color: HSLColor.fromColor(tint)
                      .withSaturation(0.46)
                      .withLightness(0.40)
                      .toColor()),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.title.of(_lang),
                      style: pvFraunces(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: p.ink1)),
                  const SizedBox(height: 4),
                  Text(info.blurb.of(_lang),
                      style: pvManrope(
                          fontSize: 12.5, height: 1.4, color: p.ink2)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

/// The Ingredient Checker and the Bump ritual — visually distinct from the
/// five area tiles (a plain icon well, no gradient) so they read as "tools",
/// not as a sixth and seventh area.
class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.title,
    required this.blurb,
    required this.badge,
    required this.icon,
    required this.hue,
    required this.p,
    required this.onTap,
  });
  final String title;
  final String blurb;
  final String? badge;
  final IconData icon;
  final double hue;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.38)
        .toColor();
    return Material(
      color: p.surfaceAlt,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Icon(icon, size: 26, color: ink),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(title,
                          style: pvFraunces(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                              color: p.ink1)),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: ink,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(badge!,
                            style: pvManrope(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Colors.white)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Text(blurb,
                      style: pvManrope(
                          fontSize: 12.5, height: 1.4, color: p.ink2)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

/// A one-line reason to open the page, for the area list card. `videoSubtitle`
/// is written to already be that one-liner on every page; the block fallback
/// only matters if a future page is added without one.
LocalizedText _teaserFor(BsPage page) {
  if (page.videoSubtitle != null) return page.videoSubtitle!;
  for (final b in page.blocks) {
    if (b.paragraphs.isNotEmpty) return b.paragraphs.first;
    if (b.bullets.isNotEmpty) return b.bullets.first;
  }
  return page.title;
}

// ===========================================================================
//  Area list — one per area (2..4..8 pages), Areas 1/2/4/5 only
// ===========================================================================

class BsAreaListScreen extends StatelessWidget {
  const BsAreaListScreen({super.key, required this.area});
  final BsArea area;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final info = kBsAreaInfo[area]!;
    final pages = bsPagesForArea(area);

    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        elevation: 0,
        foregroundColor: p.ink1,
        title: Text(info.title.of(_lang),
            style: pvJakarta(
                fontSize: 17, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        children: [
          Text(info.blurb.of(_lang),
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 20),
          SolutionGroup(
            title: const LocalizedText(en: 'Read', hi: 'Read'),
            p: p,
            lang: _lang,
            cards: [
              for (final page in pages)
                SolutionCard(
                  type: SolutionType.read,
                  title: page.title,
                  value: _teaserFor(page),
                  p: p,
                  lang: _lang,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: RouteSettings(name: 'belly_skin/page/${page.id}'),
                    builder: (_) => BsArticleScreen(page: page),
                  )),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
