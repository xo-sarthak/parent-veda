// =============================================================================
//  Launch promo data — sponsored brand creatives shown on app open
// -----------------------------------------------------------------------------
//  A data-driven list of full-screen promo slides for the launch pop-up carousel
//  (see widgets/launch_promo.dart). Each slide is a styled placeholder creative
//  (peach header + offer rows + CTA), OR a real brand image if [imageAsset] is
//  set — real partners will supply a full-bleed creative + a [url] to open. The
//  brand names here are placeholders (not real companies) until real sponsors
//  are wired in. Swap/extend this list to change what the pop-up promotes.
// =============================================================================

import 'package:flutter/material.dart';

class PromoSlide {
  const PromoSlide({
    required this.brand,
    required this.headline,
    required this.subline,
    required this.offers,
    required this.cta,
    required this.header,
    required this.body,
    required this.ink,
    required this.accent,
    required this.icon,
    this.imageAsset,
    this.url,
  });

  /// Sponsor name, shown as a small "Sponsored · brand" tag.
  final String brand;

  /// Big creative headline (rendered on the coloured header panel).
  final String headline;

  /// One supporting line under the offer rows.
  final String subline;

  /// 1–3 offer rows (e.g. "ADD ₹600 → GET ₹60"). Each becomes a pill.
  final List<String> offers;

  /// Call-to-action button label.
  final String cta;

  /// Colours for the placeholder creative.
  final Color header; // top rounded panel (peach-like in the reference)
  final Color body; // lower background
  final Color ink; // headline / text colour
  final Color accent; // offer pill + CTA colour

  final IconData icon;

  /// If set, a full-bleed brand image is shown instead of the placeholder.
  final String? imageAsset;

  /// Optional deep-link / web URL opened when the CTA (or creative) is tapped.
  final String? url;
}

/// The slides shown in the launch pop-up carousel. Placeholder sponsors for now.
const List<PromoSlide> kLaunchPromos = [
  PromoSlide(
    brand: 'NestlingCo',
    headline: 'BABY ESSENTIALS,\nSORTED',
    subline: 'Trusted, tested picks for your little one — delivered.',
    offers: [
      'FLAT 30% OFF your first order',
      'FREE delivery over ₹499',
    ],
    cta: 'Shop the sale',
    header: Color(0xFFFBD9A8),
    body: Color(0xFFEAF3F4),
    ink: Color(0xFF223A43),
    accent: Color(0xFF2E7D6B),
    icon: Icons.child_friendly_rounded,
  ),
  PromoSlide(
    brand: 'MamaBloom',
    headline: 'MATERNITY WEAR\nYOU\'LL LIVE IN',
    subline: 'Soft, breathable, bump-friendly styles for every trimester.',
    offers: [
      'FLAT ₹500 OFF your first look',
      'Buy 2, get the 3rd at 50%',
    ],
    cta: 'Explore the edit',
    header: Color(0xFFF6C9CE),
    body: Color(0xFFF4ECEF),
    ink: Color(0xFF4A2530),
    accent: Color(0xFFC65B72),
    icon: Icons.checkroom_rounded,
  ),
  PromoSlide(
    brand: 'PureStart',
    headline: 'PRENATAL CARE,\nMADE SIMPLE',
    subline: 'Doctor-formulated folate + prenatal packs for these early weeks.',
    offers: [
      'BUY 2 GET 1 FREE on prenatal packs',
      'FREE nutrition consult on ₹999+',
    ],
    cta: 'Start your pack',
    header: Color(0xFFCDE3C4),
    body: Color(0xFFEDF4EA),
    ink: Color(0xFF23402A),
    accent: Color(0xFF4E8A54),
    icon: Icons.medication_liquid_rounded,
  ),
  PromoSlide(
    brand: 'TinyToes',
    headline: 'DIAPERS &\nWIPES, MONTHLY',
    subline: 'Never run out — soft, rash-free essentials on auto-refill.',
    offers: [
      'TRIAL PACK at just ₹99',
      'SAVE 20% on every subscription',
    ],
    cta: 'Grab the trial',
    header: Color(0xFFC7D8F2),
    body: Color(0xFFECF1F8),
    ink: Color(0xFF22324D),
    accent: Color(0xFF3C6FBF),
    icon: Icons.spa_rounded,
  ),
];
