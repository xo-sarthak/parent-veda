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
import '../localization/app_language.dart';

LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

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

  /// Sponsor name, shown as a small _t("Sponsored · brand", 'प्रायोजित · ब्रांड') tag.
  final String brand;

  /// Big creative headline (rendered on the coloured header panel).
  final LocalizedText headline;

  /// One supporting line under the offer rows.
  final LocalizedText subline;

  /// 1–3 offer rows (e.g. _t("ADD ₹600 → GET ₹60", '₹600 जोड़िए → ₹60 पाइए')). Each becomes a pill.
  final List<LocalizedText> offers;

  /// Call-to-action button label.
  final LocalizedText cta;

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
final List<PromoSlide> kLaunchPromos = [
  PromoSlide(
    brand: 'NestlingCo',
    headline: _t('BABY ESSENTIALS,\nSORTED', 'शिशु की ज़रूरी चीज़ें,\\nएक जगह'),
    subline: _t('Trusted, tested picks for your little one — delivered.', 'आपके नन्हे के लिए भरोसेमंद, परखी हुई चीज़ें — घर तक।'),
    offers: [
      _t('FLAT 30% OFF your first order', 'पहले ऑर्डर पर सीधे 30% छूट'),
      _t('FREE delivery over ₹499', '₹499 से ऊपर मुफ़्त डिलीवरी'),
    ],
    cta: _t('Shop the sale', 'सेल देखिए'),
    header: Color(0xFFFBD9A8),
    body: Color(0xFFEAF3F4),
    ink: Color(0xFF223A43),
    accent: Color(0xFF2E7D6B),
    icon: Icons.child_friendly_rounded,
  ),
  PromoSlide(
    brand: 'MamaBloom',
    headline: _t('MATERNITY WEAR\nYOU\'LL LIVE IN', 'मैटरनिटी कपड़े\\nजो रोज़ पहनना चाहेंगी'),
    subline: _t('Soft, breathable, bump-friendly styles for every trimester.', 'हर तिमाही के लिए नरम, साँस लेने वाले, बंप के अनुकूल कपड़े।'),
    offers: [
      _t('FLAT ₹500 OFF your first look', 'पहली ख़रीद पर सीधे ₹500 छूट'),
      _t('Buy 2, get the 3rd at 50%', '2 लीजिए, तीसरा 50% पर'),
    ],
    cta: _t('Explore the edit', 'चुनी हुई चीज़ें देखिए'),
    header: Color(0xFFF6C9CE),
    body: Color(0xFFF4ECEF),
    ink: Color(0xFF4A2530),
    accent: Color(0xFFC65B72),
    icon: Icons.checkroom_rounded,
  ),
  PromoSlide(
    brand: 'PureStart',
    headline: _t('PRENATAL CARE,\nMADE SIMPLE', 'Prenatal देखभाल,\\nअब आसान'),
    subline: _t('Doctor-formulated folate + prenatal packs for these early weeks.', 'इन शुरुआती हफ़्तों के लिए डॉक्टर के बनाए Folate + prenatal पैक।'),
    offers: [
      _t('BUY 2 GET 1 FREE on prenatal packs', 'Prenatal पैक पर 2 लीजिए, 1 मुफ़्त'),
      _t('FREE nutrition consult on ₹999+', '₹999+ पर मुफ़्त पोषण परामर्श'),
    ],
    cta: _t('Start your pack', 'अपना पैक शुरू कीजिए'),
    header: Color(0xFFCDE3C4),
    body: Color(0xFFEDF4EA),
    ink: Color(0xFF23402A),
    accent: Color(0xFF4E8A54),
    icon: Icons.medication_liquid_rounded,
  ),
  PromoSlide(
    brand: 'TinyToes',
    headline: _t('DIAPERS &\nWIPES, MONTHLY', 'नैपियाँ और\\nवाइप्स, हर महीने'),
    subline: _t('Never run out — soft, rash-free essentials on auto-refill.', 'कभी ख़त्म न हों — नरम, रैश-रहित चीज़ें अपने आप हर महीने।'),
    offers: [
      _t('TRIAL PACK at just ₹99', 'ट्रायल पैक सिर्फ़ ₹99 में'),
      _t('SAVE 20% on every subscription', 'हर सब्सक्रिप्शन पर 20% बचत'),
    ],
    cta: _t('Grab the trial', 'ट्रायल लीजिए'),
    header: Color(0xFFC7D8F2),
    body: Color(0xFFECF1F8),
    ink: Color(0xFF22324D),
    accent: Color(0xFF3C6FBF),
    icon: Icons.spa_rounded,
  ),
];
