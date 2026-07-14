// =============================================================================
//  Product Guide — the "which view?" chooser + detail-page banner
// -----------------------------------------------------------------------------
//  When a parent taps a product that HAS a Product Guide, we don't guess where
//  to send them — we ask. `openProductWithGuideCheck` shows a calm two-option
//  sheet (in-depth Product Guide vs the quick product page) only when a Guide
//  exists; otherwise it opens the normal page with zero friction. Detail screens
//  can also drop `productGuideBanner(...)` in to surface the Guide inline.
//  Shared by both apps.
// =============================================================================

import 'package:flutter/material.dart';

import 'product_guide_data.dart';
import 'product_guide_screen.dart';
import 'product_guide_style.dart';

/// Open a tapped product. If a Product Guide exists for it (by [id] or [name]),
/// ask the parent which view they'd like; otherwise just [onOpenNormal].
void openProductWithGuideCheck(
  BuildContext context, {
  String? id,
  String? name,
  required VoidCallback onOpenNormal,
}) {
  final guide = guideForProduct(id: id, name: name);
  if (guide == null) {
    onOpenNormal();
    return;
  }
  showProductViewChooser(context, guide: guide, onOpenNormal: onOpenNormal);
}

/// The two-option sheet: the trusted in-depth Guide, or the quick product page.
void showProductViewChooser(
  BuildContext context, {
  required ProductGuide guide,
  required VoidCallback onOpenNormal,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: pgBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: pgLine, borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 16),
          Text('How would you like to see this?', style: pgTitle(18)),
          const SizedBox(height: 6),
          Text('This is a product parents often research — we can go deep, or keep it quick.',
              style: pgBody(13, color: pgSoft, h: 1.5)),
          const SizedBox(height: 18),

          _choice(
            context,
            icon: Icons.menu_book_rounded,
            accent: pgPurple,
            title: 'ParentVeda Product Guide',
            sub: 'Is it right for your child? Recommendation, verdict, experts, ingredients — in 10 seconds or deep.',
            featured: true,
            onTap: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProductGuideScreen(guide: guide)));
            },
          ),
          const SizedBox(height: 12),
          _choice(
            context,
            icon: Icons.sell_outlined,
            accent: pgSoft,
            title: 'Quick product page',
            sub: 'Price, specs and buy — the usual view.',
            featured: false,
            onTap: () {
              Navigator.of(ctx).pop();
              onOpenNormal();
            },
          ),
        ]),
      ),
    ),
  );
}

Widget _choice(
  BuildContext context, {
  required IconData icon,
  required Color accent,
  required String title,
  required String sub,
  required bool featured,
  required VoidCallback onTap,
}) =>
    GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: featured ? pgPurple.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: featured ? pgPurple.withValues(alpha: 0.35) : pgHair, width: featured ? 1.6 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44, alignment: Alignment.center,
            decoration: BoxDecoration(color: featured ? pgPurple.withValues(alpha: 0.12) : pgPanel, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 21, color: accent == pgSoft ? pgSoft : accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(title, style: pgTitle(15))),
                if (featured) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: pgPurple, borderRadius: BorderRadius.circular(999)),
                    child: Text('TRUSTED', style: pgEyebrow(Colors.white).copyWith(fontSize: 8.5)),
                  ),
                ],
              ]),
              const SizedBox(height: 3),
              Text(sub, style: pgBody(12.5, color: pgSoft, h: 1.4)),
            ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: pgMuted),
        ]),
      ),
    );

/// An inline banner for a product detail page: "there's a Guide for this".
Widget productGuideBanner(BuildContext context, ProductGuide guide, {EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20)}) =>
    Padding(
      padding: padding,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProductGuideScreen(guide: guide))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [pgPurple.withValues(alpha: 0.08), pgCoral.withValues(alpha: 0.06)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: pgPurple.withValues(alpha: 0.20)),
          ),
          child: Row(children: [
            Container(
              width: 38, height: 38, alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.menu_book_rounded, size: 19, color: pgPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Read the ParentVeda Product Guide', style: pgTitle(13.5)),
                const SizedBox(height: 1),
                Text('Is it right for your child? Decide in 10 seconds.', style: pgBody(11.5, color: pgSoft)),
              ]),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: pgPurple),
          ]),
        ),
      ),
    );
