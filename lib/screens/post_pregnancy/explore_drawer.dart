// =============================================================================
//  ExploreDrawer — the "Explore" left drawer (parenting app)
// -----------------------------------------------------------------------------
//  Opened from the hamburger on the My Child home. A home for sections that
//  don't sit in the bottom-nav's four hero tabs — starting with Recipes (→
//  Recipe page). More sections (Recommendations, Nuskhe, Courses, …) slot in
//  here as they're greenlit. Warm-Nest styled to match the app.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'recipes_screen.dart';

class ExploreDrawer extends StatelessWidget {
  const ExploreDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ppEyebrow('ParentVeda'),
            const SizedBox(height: 10),
            Text('Explore', style: ppFraunces(32, h: 1.1)),
            const SizedBox(height: 6),
            Text('Everything else, one tap away.', style: ppBody(14)),
            const SizedBox(height: 24),

            _section(
              context,
              Icons.restaurant_menu_outlined,
              'Recipes',
              'Age-tagged, healthier Indian food.',
              () {
                final nav = Navigator.of(context);
                nav.pop(); // close the drawer
                nav.push(MaterialPageRoute(builder: (_) => const RecipesScreen()));
              },
              top: true,
            ),

            const Spacer(),
            Text('More sections coming soon.', style: ppBody(12, color: ppMuted)),
          ]),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, IconData icon, String title, String desc, VoidCallback onTap,
          {bool top = false}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: const BorderSide(color: ppHair),
            ),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 22, color: ppPurple),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ppJakarta(16)),
                const SizedBox(height: 2),
                Text(desc, style: ppBody(12)),
              ]),
            ),
            const SizedBox(width: 10),
            const Text('→', style: TextStyle(color: ppMuted)),
          ]),
        ),
      );
}
