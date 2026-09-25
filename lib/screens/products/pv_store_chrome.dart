// =============================================================================
//  The store's chrome — one set of parts for every product screen
// -----------------------------------------------------------------------------
//  Built 2026-09-17 from the Mobbin marketplace audit (docs/PRODUCTS-AUDIT.md)
//  on the base-UI rule (DESIGN-SYSTEM §4.0): white ground, ink for actions,
//  the brand violet only on eyebrows and the verified mark, category colour
//  only inside the icon well. Newsreader for display through the `pvFraunces`
//  seam; Manrope for everything else.
//
//  What is deliberately the SAME as the shops she already uses (habit is the
//  point — "why make the user push against their initial habit"):
//    * a 2-column grid of square photos, price under name (Etsy, Target, Zara)
//    * heart top-right of the photo (every one of them)
//    * stars + count on one line (Amazon, Sephora, Etsy)
//    * strike-through MRP with a percent off (Amazon, Blinkit, Etsy)
//    * a sticky commit bar on the product page (all of them)
//
//  What is ours:
//    * the ParentVeda mark on SOME cards — the verified tick + "ParentVeda
//      recommends" — and its reason on the page, signed by a reviewer;
//    * "Generally not needed" drawn with the same weight as "Recommended";
//    * an honest cover block where there is no photo, never a wrong one.
//
//  ⚠️ ONE STORE, THREE NAV BARS. The pregnancy shell owns its bar (the store
//  sits inside `MainScaffold`'s IndexedStack); parenting and TTC screens
//  draw their own. `PvStoreChrome` says which, and every store screen that
//  can be a tab root takes it. Pushed detail screens (product, cart,
//  checkout) draw no bar — the sticky commit bar takes that space.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/products/pv_category_images.dart';
import '../../models/pv_product.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/pv_compare_store.dart';
import '../../services/saved_store.dart';
import '../../theme/pv_fonts.dart';
import '../post_pregnancy/pp_common.dart' show PpBottomNav, PpTab;
import '../ttc/ttc_common.dart' show TtcBottomNav;
import '../auth/onboarding/onboarding_chrome.dart' show ObPress;
import '../v2/v2_palette.dart';
import 'pv_product_screen.dart';

/// Which shell is underneath the store's tab-root screens.
enum PvStoreChrome {
  /// Inside the pregnancy `MainScaffold`: the scaffold draws the bar.
  embedded,

  /// Pushed from the parenting home: draws `PpBottomNav(products)`.
  parenting,

  /// Pushed from the TTC V3 home: draws `TtcBottomNav` on the Products slot.
  ttc,

  /// A pushed screen with no bar (search, shelf, compare).
  none,
}

V2Palette get pvStorePalette => V2PaletteStore.instance.current;

/// Card hairline — 0x1F on white (the White ground spec).
const Color kPvLine = Color(0x1F000000);

/// The three tones the recommendation band draws in. Green for yes, sand for
/// "it depends", the rose for "generally not needed" — the same weight each.
Color pvToneColor(int tone) => switch (tone) {
  0 => const Color(0xFF1F8A5B),
  1 => const Color(0xFFB0741A),
  _ => const Color(0xFFC6295A),
};

/// Star glyph colour: a warm amber, never the brand violet.
const Color kPvStar = Color(0xFFE0A526);

// ---- routing ----------------------------------------------------------------

/// Route names are load-bearing: the Ask FAB and the TTC bar read them.
const String kPvStoreRoute = 'store';
const String kPvProductRoutePrefix = 'store/product/';

/// [heroTag] is the tag of the photo that was tapped, so the product page's
/// first frame flies from it. A product can sit in two rails on one screen
/// (for-you and its own shelf), and two Heroes with one tag on one route
/// assert — so every rail scopes its tags (`pv_img_<scope>_<id>`).
void pvOpenProduct(BuildContext context, PvProduct p, {String? heroTag}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PvProductScreen(productId: p.id, heroTag: heroTag),
      settings: RouteSettings(name: '$kPvProductRoutePrefix${p.id}'),
    ),
  );
}

/// Every store notice goes through here.
///
/// ⚠️ WHITE, LIFTED, WITH A HAIRLINE — the user's call on the phone: an ink
/// snack sat on top of the ink commit bar and "the two of the same colour
/// make it look like one". So a notice is a white card with ink text, and it
/// floats ABOVE the sticky bar (52 + padding + the safe inset) rather than
/// over it. Never the brand colour, never a fill that matches a button.
void pvSnack(
  BuildContext context,
  String text, {
  String? action,
  VoidCallback? onAction,
  // How far above the screen's foot to float. Defaults to the Store's sticky
  // bar clearance; a screen with a shorter bar passes its own, or the
  // confirmation floats over its content (the recipe page, 2026-09-23: it
  // sat on top of an ingredient row).
  double? lift,
  // A leading mark for a notice that CONFIRMS something ("on your list").
  // Opt-in, never the default: this helper also carries errors ("Payment did
  // not go through"), and a tick on those would say the opposite of the words.
  IconData? icon,
}) {
  final p = pvStorePalette;
  final inset = MediaQuery.of(context).padding.bottom;
  final messenger = ScaffoldMessenger.of(context);
  // ⚠️ REDESIGNED 2026-09-23 — the user: "these pop ups… look very bland and
  // poor, and it is just staying on the screen." Two fixes in one:
  //  · STAYING: Flutter 3.44 made a SnackBar with an `action` persist until
  //    dismissed (`persist ?? action != null`). This one builds its own
  //    action inside `content` and passes no `action`, so it always times
  //    out; `persist: false` says so explicitly as well.
  //  · BLAND: still WHITE (the user's rule above — an ink notice over an ink
  //    bar reads as one object), but lifted by a soft shadow instead of a
  //    hairline, an optional tick in a tinted disc, bolder words, and the
  //    action as a small INK PILL with an arrow — the base UI's pill — rather
  //    than faint coloured text. Mobbin 2026-09-23: Notion Mail, Quicken,
  //    Drive (the action on the right, bold, short), Character AI and
  //    Linktree (the tick that says done before the words do).
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        persist: false,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.fromLTRB(16, 0, 16, (lift ?? kPvStickyBarClearance) + inset),
        duration: Duration(milliseconds: action == null ? 2200 : 3600),
        content: Container(
          padding: EdgeInsets.fromLTRB(icon == null ? 16 : 12, 10, action == null ? 16 : 8, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: p.ink1.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8)),
              BoxShadow(color: p.ink1.withValues(alpha: 0.06), blurRadius: 3, offset: const Offset(0, 1)),
            ],
          ),
          child: Row(children: [
            if (icon != null) ...[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: const Color(0xFFE3F2E6), shape: BoxShape.circle),
                child: Icon(icon, size: 17, color: const Color(0xFF2E7D4F)),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.3, color: p.ink1)),
            ),
            if (action != null) ...[
              const SizedBox(width: 10),
              Material(
                color: p.ink1,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () {
                    messenger.hideCurrentSnackBar();
                    (onAction ?? () {})();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(action,
                          style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_forward_rounded, size: 15, color: Colors.white),
                    ]),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  // Kept for revert — the white card with a hairline and a text action:
  //   SnackBar(content: Text(text, style: pvManrope(fontSize: 13.5, ...)),
  //     backgroundColor: Colors.white, shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(14), side: BorderSide(color: p.ink1 18%)),
  //     action: SnackBarAction(label: action, textColor: p.action, ...))
}

/// Where a notice floats from: above the sticky commit bar (52 pill + 12 +
/// 12 = 76) AND above the Ask pill's lane (it sits at bottom 92, 64 tall),
/// so a notice with an action never has its action under the FAB — found on
/// the phone with "View bag" half-covered.
const double kPvStickyBarClearance = 164;

// ---- the bottom bar for a tab-root screen ------------------------------------

class PvStoreNav extends StatelessWidget {
  const PvStoreNav({super.key, required this.chrome});
  final PvStoreChrome chrome;

  @override
  Widget build(BuildContext context) => switch (chrome) {
    PvStoreChrome.parenting => const Positioned(
      left: 16,
      right: 16,
      bottom: 18,
      child: PpBottomNav(active: PpTab.products),
    ),
    PvStoreChrome.ttc => const Positioned(
      left: 16,
      right: 16,
      bottom: 18,
      child: TtcBottomNav(active: 1, v3: true),
    ),
    _ => const SizedBox.shrink(),
  };
}

// ---- image ------------------------------------------------------------------

/// A product photo, or the honest cover block. `Image.network` with a quiet
/// loading well; on failure the block, never a broken-image glyph.
class PvProductImage extends StatelessWidget {
  const PvProductImage({
    super.key,
    required this.product,
    this.index = 0,
    this.fit = BoxFit.cover,
    this.radius = 16,
  });
  final PvProduct product;
  final int index;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = index < product.images.length ? product.images[index] : null;
    final well = PvCoverBlock(
      hue: product.hue,
      name: product.name,
      radius: radius,
    );
    if (url == null) return well;
    final tint = HSLColor.fromAHSL(1, product.hue, 0.18, 0.95).toColor();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        fit: fit,
        gaplessPlayback: true,
        // MOTION: the photo fades in over the tinted well instead of popping
        // (Zara, H&M). `frame == null` is "still loading"; a synchronous
        // decode (already cached) skips the fade so scrolling back is instant.
        frameBuilder: (c, child, frame, wasSync) {
          if (wasSync) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOut,
            child: frame == null
                ? Container(key: const ValueKey('well'), color: tint)
                : SizedBox.expand(key: const ValueKey('img'), child: child),
          );
        },
        errorBuilder: (_, e, s) => well,
      ),
    );
  }
}

/// No photograph yet: the category hue as a soft well and the initial of the
/// product, drawn — so the card holds its geometry and nothing pretends.
class PvCoverBlock extends StatelessWidget {
  const PvCoverBlock({
    super.key,
    required this.hue,
    required this.name,
    this.radius = 16,
  });
  final double hue;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final a = HSLColor.fromAHSL(1, hue, 0.30, 0.93).toColor();
    final b = HSLColor.fromAHSL(1, hue, 0.28, 0.87).toColor();
    final ink = HSLColor.fromAHSL(1, hue, 0.30, 0.38).toColor();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [a, b],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '' : name.characters.first.toUpperCase(),
        style: pvFraunces(
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: ink,
        ),
      ),
    );
  }
}

// ---- small parts --------------------------------------------------------------

class PvStars extends StatelessWidget {
  const PvStars({super.key, required this.rating, this.count, this.size = 13});
  final double rating;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    if (rating <= 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size + 3, color: kPvStar),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: pvManrope(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: p.ink1,
          ),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 3),
          Text(
            '($count)',
            style: pvManrope(fontSize: size - 0.5, color: p.ink3),
          ),
        ],
      ],
    );
  }
}

/// Price, MRP struck through, percent off — Amazon's line, in our type.
class PvPriceLine extends StatelessWidget {
  const PvPriceLine({
    super.key,
    required this.product,
    this.size = 15,
    this.price,
  });
  final PvProduct product;
  final double size;

  /// Override for a selected variant.
  final int? price;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final shown = price ?? product.price;
    if (shown <= 0) {
      return Text(
        product.priceNote,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: pvManrope(
          fontSize: size - 1,
          fontWeight: FontWeight.w600,
          color: p.ink2,
        ),
      );
    }
    final mrp = product.mrp;
    final off = (mrp != null && mrp > shown)
        ? ((mrp - shown) * 100 / mrp).round()
        : null;
    // A Wrap, not a Row: on a 164-px card "₹1,499 ₹2,499 40% off" is wider
    // than the card, and a Row overflows where a Wrap takes a second line.
    return Wrap(
      spacing: 6,
      runSpacing: 0,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Text(
          '₹${PvProduct.groupRupees(shown)}',
          style: pvManrope(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: p.ink1,
          ),
        ),
        if (off != null) ...[
          Text(
            '₹${PvProduct.groupRupees(mrp!)}',
            style: pvManrope(
              fontSize: size - 3,
              color: p.ink3,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            '$off% off',
            style: pvManrope(
              fontSize: size - 3,
              fontWeight: FontWeight.w700,
              color: pvToneColor(0),
            ),
          ),
        ],
      ],
    );
  }
}

/// The ParentVeda mark: verified tick in the brand violet + the band word.
/// On a card it is the only place the brand colour appears.
class PvRecoMark extends StatelessWidget {
  const PvRecoMark({super.key, required this.band, this.compact = false});
  final PvRecoBand band;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final recommends = band.recommends;
    final label = recommends ? 'ParentVeda recommends' : band.label;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPvLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (recommends)
            Icon(
              Icons.verified_rounded,
              size: compact ? 12 : 14,
              color: p.action,
            )
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pvToneColor(band.tone),
              ),
            ),
          const SizedBox(width: 5),
          Text(
            label,
            style: pvManrope(
              fontSize: compact ? 10 : 11.5,
              fontWeight: FontWeight.w700,
              color: p.ink1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Heart — saves through `SavedStore` (kind product), the one owner of every
/// bookmark. Listens so the same heart is lit on the shelf and on the page.
class PvHeart extends StatelessWidget {
  const PvHeart({
    super.key,
    required this.product,
    this.size = 32,
    this.onWhite = true,
  });
  final PvProduct product;
  final double size;
  final bool onWhite;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: SavedStore.instance,
      builder: (context, _) {
        final saved = SavedStore.instance.isSaved(
          SavedKind.product,
          product.id,
        );
        return InkWell(
          onTap: () {
            SavedStore.instance.toggle(
              SavedKind.product,
              product.id,
              title: product.name,
              subtitle: product.brand,
              stage: product.stage.id,
            );
            // ⚠️ NO NOTICE — 2026-09-20, the user's walk: the snack rose to
            // a third of the way up the screen ("a very abrupt position")
            // and told her where the item went in words. Myntra and Blinkit
            // say it with the heart itself and a count on the wishlist icon
            // in the header, which is where it now lives (`PvWishlistScreen`).
            // Kept for revert:
            //   pvSnack(context, saved ? 'Removed from Saved' : 'Saved — find it under Saved · Products');
          },
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: onWhite
                  ? Colors.white.withValues(alpha: 0.94)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: onWhite ? Border.all(color: kPvLine) : null,
            ),
            child: AnimatedScale(
              scale: saved ? 1.0 : 0.92,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: size * 0.55,
                color: saved ? const Color(0xFFC6295A) : p.ink1,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Section header: display title, optional "See all" link in the action ink.
class PvSectionHead extends StatelessWidget {
  const PvSectionHead({
    super.key,
    required this.title,
    this.eyebrow,
    this.action,
    this.onAction,
  });
  final String title;
  final String? eyebrow;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    eyebrow!.toUpperCase(),
                    style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: p.action,
                    ),
                  ),
                ),
              Text(
                title,
                style: pvFraunces(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                  color: p.ink1,
                ),
              ),
            ],
          ),
        ),
        if (action != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 6),
              child: Text(
                action!,
                style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: p.action,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Hairline chip; selected = ink fill (Etsy's filter chip, the base-UI rule).
class PvChip extends StatelessWidget {
  const PvChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.count,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leading;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final fg = selected ? Colors.white : p.ink2;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        // No `alignment`: a Container with one and no width fills whatever it
        // is given, and inside a Wrap that is the whole line (found on the
        // phone - every size chip rendered full-width). The Row centres.
        decoration: BoxDecoration(
          color: selected ? p.ink1 : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? p.ink1 : kPvLine, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 15, color: fg),
              const SizedBox(width: 6),
            ],
            // A bounded box, not Flexible: inside a Wrap a Flexible child makes
            // the chip's Row take the whole line (found on the phone - the size
            // chips rendered full-width). 200 px still ellipsises the longest
            // sort label on a small phone.
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 5),
              Text(
                '$count',
                style: pvManrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white70 : p.ink3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The one filled pill per screen (ObPrimary's shape, with a busy state).
class PvCommit extends StatelessWidget {
  const PvCommit({
    super.key,
    required this.label,
    this.onTap,
    this.busy = false,
    this.icon,
    this.trailing,
  });
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final IconData? icon;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final enabled = onTap != null && !busy;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: enabled || busy ? p.ink1 : p.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: trailing == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            if (busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: enabled ? Colors.white : p.ink3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (trailing != null && !busy)
              Text(
                trailing!,
                style: pvManrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// White outlined pill — the secondary commit (Add to cart beside Buy now).
class PvSecondary extends StatelessWidget {
  const PvSecondary({super.key, required this.label, this.onTap, this.icon});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.ink1, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: p.ink1),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: p.ink1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A round ink icon button on white (top bars: back, cart, share).
class PvRoundIcon extends StatelessWidget {
  const PvRoundIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge,
    this.size = 40,
  });
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: kPvLine),
            ),
            child: Icon(icon, size: size * 0.5, color: p.ink1),
          ),
        ),
        if (badge != null && badge! > 0)
          Positioned(
            right: -3,
            top: -3,
            // MOTION: the count pops when it changes (Sephora's bag icon).
            child: _Pop(
              key: ValueKey(badge),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: p.ink1,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$badge',
                  style: pvManrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---- the product card ---------------------------------------------------------

/// The 2-column grid card. Square photo, heart, the ParentVeda mark on the
/// photo when it has one, brand · name · stars · price. A compare tick when
/// the shelf asks for it.
class PvProductCard extends StatelessWidget {
  const PvProductCard({
    super.key,
    required this.product,
    this.compare = false,
    this.width,
    this.heroScope = 'card',
    this.onOpen,
  });
  final PvProduct product;
  final bool compare;
  final double? width;

  /// Which rail or grid this card is in; keeps Hero tags unique per route.
  final String heroScope;

  /// Called before the page opens — search records the query here.
  final void Function(PvProduct)? onOpen;

  String get heroTag => 'pv_img_${heroScope}_${product.id}';

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    // MOTION: the card scales 0.98 under the thumb (ObPress), and its photo
    // is the Hero that becomes the product page's first frame — the tap and
    // the page are one object, which is the whole feel of Zara's open.
    final card = ObPress(
      child: InkWell(
        onTap: () {
          onOpen?.call(product);
          pvOpenProduct(context, product, heroTag: heroTag);
        },
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: heroTag,
                      child: PvProductImage(product: product, radius: 16),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PvHeart(product: product, size: 30),
                  ),
                  if (product.reco != null)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: PvRecoMark(
                        band: product.reco!.band,
                        compact: true,
                      ),
                    ),
                  if (product.reviewOnly)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: _tag(p, 'Information only'),
                    )
                  // TTC's own "PARENTVEDA PICK" badge would sit above the mark
                  // that says the same thing; the mark wins, the badge is dropped.
                  else if (product.badge.isNotEmpty &&
                      !product.badge.toLowerCase().contains('parentveda'))
                    Positioned(left: 8, top: 8, child: _tag(p, product.badge)),
                ],
              ),
            ),
            const SizedBox(height: 9),
            if (product.brand.isNotEmpty)
              Text(
                product.brand.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: p.ink3,
                ),
              ),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 3),
            PvStars(
              rating: product.rating,
              count: product.reviewCount,
              size: 12,
            ),
            const SizedBox(height: 3),
            if (!product.reviewOnly) PvPriceLine(product: product, size: 14.5),
            if (compare) ...[
              const SizedBox(height: 4),
              PvCompareTick(product: product),
            ],
          ],
        ),
      ),
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }

  Widget _tag(V2Palette p, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: p.ink1,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: pvManrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}

/// The compare tick. The store enforces two-at-a-time and same-category and
/// the tick explains a refusal instead of staying silent.
class PvCompareTick extends StatelessWidget {
  const PvCompareTick({super.key, required this.product});
  final PvProduct product;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PvCompareStore.instance,
      builder: (context, _) {
        final on = PvCompareStore.instance.contains(product.id);
        return InkWell(
          onTap: () {
            final r = PvCompareStore.instance.toggle(product);
            switch (r) {
              case PvCompareResult.wrongCategory:
                pvSnack(
                  context,
                  'Compare within one category — a stroller against a thermometer has no shared rows.',
                );
              case PvCompareResult.replaced:
                pvSnack(context, 'Two at a time — swapped the oldest out.');
              default:
                break;
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                on
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 18,
                color: on ? p.ink1 : p.ink3,
              ),
              const SizedBox(width: 5),
              Text(
                'Compare',
                style: pvManrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: p.ink2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A horizontal rail of cards at a fixed width.
///
/// A `Row` in a horizontal `SingleChildScrollView`, NOT a `ListView`: a
/// horizontal ListView needs a fixed height, and any guessed height leaves
/// slack under the cards (found on the phone as "white space for no reason").
/// The Row sizes itself to the tallest card, so the gap under the rail is the
/// section spacing and nothing else. Six to eight cards; laziness buys nothing.
class PvCardRail extends StatelessWidget {
  const PvCardRail({
    super.key,
    required this.products,
    this.cardWidth = 164,
    this.compare = false,
    this.scope = 'rail',
  });
  final List<PvProduct> products;
  final double cardWidth;
  final bool compare;
  final String scope;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < products.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          PvProductCard(
            product: products[i],
            width: cardWidth,
            compare: compare,
            heroScope: scope,
          ),
        ],
      ],
    ),
  );
}

// ---- the stage switch ---------------------------------------------------------

/// H&M's `WOMEN +` corner / Tabby's `Women Men Kids` line, in our type: the
/// three stage words, the current one in ink, the others quiet. One tap
/// changes the whole storefront. Never hidden — the other two stages are
/// always one tap away, which is the whole reason there is one store.
class PvStageSwitch extends StatelessWidget {
  const PvStageSwitch({
    super.key,
    required this.stage,
    required this.onChanged,
  });
  final LifeStage stage;
  final ValueChanged<LifeStage> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    // scaleDown: three display words fit a 360-px phone at 22px, but a large
    // text scale (or the test font) would push the third off the edge.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in PvStageCopy.shopStages) ...[
            InkWell(
              onTap: () => onChanged(s),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.shopLabel,
                      style: pvFraunces(
                        fontSize: 22,
                        fontWeight: s == stage
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: s == stage ? p.ink1 : p.ink3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 2,
                      width: s == stage ? 22 : 0,
                      decoration: BoxDecoration(
                        color: p.ink1,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// Category tile: the tinted well with a drawn glyph, name under. The only
/// place the category's colour lives (DESIGN-SYSTEM §4.5).
/// A photo that tries again. The free hosts throttle by IP — Wikimedia
/// answers 429 to a phone sharing an IP with thousands (Indian carriers
/// NAT) and to a strip of nineteen tiles asking at once — and a tile that
/// gives up on the first refusal is an icon for the whole visit. One retry
/// at 2 s, one at 5 s, then the fallback. The same shape as `CanIPhoto`
/// (Is it safe?); the end state is our own host (R2, STILL-OPEN §63.18),
/// where none of this is needed.
class PvRetryImage extends StatefulWidget {
  const PvRetryImage({
    super.key,
    required this.url,
    required this.fallback,
    this.tint,
    this.fit = BoxFit.cover,
  });
  final String url;
  final Widget fallback;
  final Color? tint;
  final BoxFit fit;

  @override
  State<PvRetryImage> createState() => _PvRetryImageState();
}

class _PvRetryImageState extends State<PvRetryImage> {
  int _attempt = 0;
  Timer? _retry;
  static const _delays = [Duration(seconds: 2), Duration(seconds: 5)];

  @override
  void dispose() {
    // A retry due after the tile is gone is a timer nobody wants.
    _retry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Image.network(
        widget.url,
        key: ValueKey('${widget.url}#$_attempt'),
        fit: widget.fit,
        gaplessPlayback: true,
        frameBuilder: (c, child, frame, wasSync) {
          if (wasSync) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: frame == null
                ? Container(key: const ValueKey('tint'), color: widget.tint)
                : SizedBox.expand(key: const ValueKey('img'), child: child),
          );
        },
        errorBuilder: (_, _, _) {
          if (_attempt < _delays.length && _retry == null) {
            final next = _attempt + 1;
            _retry = Timer(_delays[_attempt], () {
              _retry = null;
              if (mounted && _attempt == next - 1) setState(() => _attempt = next);
            });
          }
          return widget.fallback;
        },
      );
}

class PvCategoryTile extends StatelessWidget {
  const PvCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.count,
  });
  final PvCategory category;
  final VoidCallback onTap;
  final int? count;

  static IconData iconFor(String id) {
    const rules = <(List<String>, IconData)>[
      (['sleep', 'pillow', 'swaddle'], Icons.bedtime_outlined),
      (['skin', 'stretch'], Icons.spa_outlined),
      (['feed', 'pump', 'nursing'], Icons.local_drink_outlined),
      (['play'], Icons.toys_outlined),
      (['health', 'test'], Icons.health_and_safety_outlined),
      (['move'], Icons.directions_car_outlined),
      (['wear', 'band', 'sock'], Icons.checkroom_outlined),
      (['supp'], Icons.medication_outlined),
      (['kit'], Icons.science_outlined),
      (['book'], Icons.menu_book_outlined),
      (['wellness'], Icons.self_improvement_outlined),
    ];
    for (final (words, icon) in rules) {
      if (words.any(id.contains)) return icon;
    }
    return Icons.shopping_bag_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final tint = v2BlockTint(category.hue, p);
    final ink = HSLColor.fromAHSL(1, category.hue, 0.32, 0.36).toColor();
    // ⚠️ A PHOTO OF THE OBJECT, NOT A GLYPH — 2026-09-20, the user's call
    // ("make this page look real, not static"), Blinkit's tile grammar: the
    // object on a soft tint, the label beneath. The icon-on-tint tile that
    // stood here is now the fallback — for a category the photo map does not
    // know, and for a photo that fails to load — so the strip is never
    // broken and a new Directus category still gets a tile.
    final iconTile = Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(iconFor(category.id), size: 28, color: ink),
    );
    final url = pvCategoryImageFor(category.id);
    final tile = url == null
        ? iconTile
        : SizedBox(
            width: 72,
            height: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: PvRetryImage(url: url, tint: tint, fallback: iconTile),
            ),
          );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          tile,
          const SizedBox(height: 7),
          SizedBox(
            width: 80,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: p.ink1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The store's search pill — ONE widget for the home and the search screen,
/// one geometry (46 tall, 14 side padding, hairline), so the Hero between
/// them is a slide and never a second shape appearing under the first.
class PvSearchPill extends StatelessWidget {
  const PvSearchPill({super.key, required this.child, this.hero = false, this.onTap});
  final Widget child;
  final bool hero;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget pill = Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPvLine),
      ),
      child: child,
    );
    if (onTap != null) {
      pill = InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: pill);
    }
    if (!hero) return pill;
    return Hero(
      tag: kPvSearchHeroTag,
      // The words inside differ between the two ends; the flight shows the
      // shell only, so text never stretches.
      flightShuttleBuilder: (_, _, _, _, _) => Material(
        type: MaterialType.transparency,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: kPvLine),
          ),
        ),
      ),
      child: Material(type: MaterialType.transparency, child: pill),
    );
  }
}

const String kPvSearchHeroTag = 'store-search-pill';

/// The hint, per stage — three things she might type, in her stage's words.
String pvSearchHintFor(LifeStage stage) => switch (stage.shopStage) {
      LifeStage.pregnancy => 'Search pillows, creams, bras…',
      LifeStage.parenting => 'Search bottles, soothers, strollers…',
      _ => 'Search folic acid, strips, tests…',
    };

/// Two cards to a row, rows sized to their content.
///
/// ⚠️ NOT A `SliverGrid`. A grid gives every cell one aspect ratio, and a
/// card whose name runs to one line leaves ~40 px of nothing under its
/// price — so the gap between rows read as "not defined" against the
/// 12-px gap between columns (the user, 2026-09-20, on the breast-pump
/// shelf). Here each row is two cards stretched to the taller of the two,
/// and the space between rows is one number: [rowGap]. What you see is
/// the gap, and only the gap.
class PvProductGridSliver extends StatelessWidget {
  const PvProductGridSliver({
    super.key,
    required this.products,
    this.heroScope = 'grid',
    this.compare = false,
    this.onOpen,
    this.rowGap = 22,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 0),
  });
  final List<PvProduct> products;
  final String heroScope;
  final bool compare;
  final void Function(PvProduct)? onOpen;
  final double rowGap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final rows = (products.length + 1) ~/ 2;
    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, r) {
            final a = products[r * 2];
            final b = r * 2 + 1 < products.length ? products[r * 2 + 1] : null;
            return Padding(
              padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : rowGap),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: PvProductCard(product: a, compare: compare, heroScope: heroScope, onOpen: onOpen)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: b == null
                          ? const SizedBox.shrink()
                          : PvProductCard(product: b, compare: compare, heroScope: heroScope, onOpen: onOpen),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: rows,
        ),
      ),
    );
  }
}


/// The well-tinted "why" panel — used for guidance, the reco reason, the
/// "before you buy" sentence. surfaceAlt, no border (a quiet fact card).
class PvWell extends StatelessWidget {
  const PvWell({super.key, required this.child, this.tint});
  final Widget child;
  final Color? tint;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: tint ?? pvStorePalette.surfaceAlt,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

/// Read the catalogue's category for a product, or a stub.
PvCategory pvCategoryOf(PvProduct p) =>
    PvCatalogStore.instance.category(p.categoryId) ??
    PvCategory(
      id: p.categoryId,
      stage: p.stage,
      name: p.categoryId,
      hue: p.hue,
    );

/// A one-shot pop: 0.6 → 1 with a slight overshoot, keyed so a changed value
/// re-runs it. Used for the bag count.
class _Pop extends StatefulWidget {
  const _Pop({super.key, required this.child});
  final Widget child;

  @override
  State<_Pop> createState() => _PopState();
}

class _PopState extends State<_Pop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: CurvedAnimation(
      parent: _c,
      curve: Curves.elasticOut,
    ).drive(Tween(begin: 0.6, end: 1)),
    child: widget.child,
  );
}
