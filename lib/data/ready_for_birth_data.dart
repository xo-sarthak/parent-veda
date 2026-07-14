// =============================================================================
//  Ready for Birth - the readiness layer over the hospital-bag data
// -----------------------------------------------------------------------------
//  "Ready for Birth" is a redesign of the Hospital Bag as a calm READINESS
//  experience, not a checklist. It reuses the existing bag data wholesale
//  (BagItem / catalogue / seed / HospitalBagV2Store) but reframes it:
//    • the six bag sections collapse into FOUR readiness categories
//      (Mom · Baby · Documents · Partner & Extras),
//    • every item carries a one-line "why pack this",
//    • contextual ParentVeda insights replace long articles,
//    • an emergency grab-list and a guided packing order live here too.
//  Pure data/logic - no widgets, no state. Personalisation inputs (week,
//  delivery, season, twins, hospital-provides) are passed in by the caller.
// =============================================================================

import 'package:flutter/material.dart';

import '../services/hospital_bag_store.dart' show BagCategory, BagItem, DeliveryType;
import '../theme/app_theme.dart';

// ---- the four readiness categories -----------------------------------------
enum ReadyCategory { mom, baby, documents, partnerExtras }

class ReadyCatMeta {
  const ReadyCatMeta(this.label, this.blurb, this.icon, this.color);
  final String label;
  final String blurb;
  final IconData icon;
  final Color color;
}

const Map<ReadyCategory, ReadyCatMeta> kReadyCatMeta = {
  ReadyCategory.mom: ReadyCatMeta('Mom', 'For you — labour, recovery and comfort',
      Icons.spa_rounded, AppTheme.secondary500),
  ReadyCategory.baby: ReadyCatMeta('Baby', 'The first clothes, changes and cosy things',
      Icons.child_friendly_rounded, AppTheme.tertiary400),
  ReadyCategory.documents: ReadyCatMeta('Documents', 'The papers the hospital will ask for',
      Icons.folder_rounded, AppTheme.primary500),
  ReadyCategory.partnerExtras: ReadyCatMeta('Partner & extras', 'For your partner, and the nice-to-haves',
      Icons.handshake_rounded, AppTheme.primary300),
};

/// Collapse the six bag sections into the four readiness categories.
ReadyCategory readyCategoryOfBag(BagCategory c) {
  switch (c) {
    case BagCategory.labour:
    case BagCategory.afterDelivery:
    case BagCategory.comfort:
      return ReadyCategory.mom;
    case BagCategory.baby:
      return ReadyCategory.baby;
    case BagCategory.documents:
      return ReadyCategory.documents;
    case BagCategory.partner:
    case BagCategory.custom:
      return ReadyCategory.partnerExtras;
  }
}

ReadyCategory readyCategoryOf(BagItem i) => readyCategoryOfBag(i.category);

/// The display order of the four categories (Documents first — quickest win).
const List<ReadyCategory> kReadyOrder = [
  ReadyCategory.documents,
  ReadyCategory.mom,
  ReadyCategory.baby,
  ReadyCategory.partnerExtras,
];

// ---- one-line "why pack this" ----------------------------------------------
//  Answers "why should I pack this?" in a single calm line. Keyed by item id;
//  a gentle generic line covers custom/unknown items.
const Map<String, String> kWhyPack = {
  'labour_gown': 'Comfortable, and easy for the team to work around.',
  'labour_socks': 'Labour rooms are kept cold — warm feet help you relax.',
  'labour_lipbalm': 'Heavy breathing dries your lips surprisingly fast.',
  'labour_hairties': 'Keeps your hair off your face through the long hours.',
  'labour_water': 'A straw lets you sip lying down, without spills.',
  'labour_snacks': 'Quick energy between contractions — check what your hospital allows.',
  'labour_glasses': "If you wear them, you'll want to see your baby clearly.",
  'labour_music': 'A familiar playlist can calm and focus you.',
  'after_pads': "Post-delivery flow is heavy — you'll need more than you think.",
  'after_underwear': 'High-waist and disposable, so nothing presses on stitches.',
  'after_nursingbra': 'Soft, with easy one-hand access for feeding.',
  'after_breastpads': 'For the leaks that come as your milk settles in.',
  'after_nipplecream': 'Soothes sore skin in the early feeding days.',
  'after_outfit': 'Something loose and soft for a healing body.',
  'after_toiletries': 'Your own basics make a hospital room feel human.',
  'after_towel': 'Hospitals rarely provide a soft towel for you.',
  'after_slippers': 'Easy to slip on for slow walks down the ward.',
  'after_binder': 'Gentle support after a C-section — only if your doctor advises.',
  'baby_bodysuits': 'A few soft changes — newborns go through them fast.',
  'baby_swaddle': 'Keeps your baby snug, warm and calm.',
  'baby_mittens': 'Warm hands, and no accidental face scratches.',
  'baby_cap': 'Newborns lose heat from the head — a cap keeps them cosy.',
  'baby_diapers': 'For the very first changes — your hospital may provide some.',
  'baby_wipes': 'Gentle, water-based, for brand-new skin.',
  'baby_blanket': 'A soft cover for the cot and the ride home.',
  'baby_towel': 'A hooded towel keeps your baby warm after the first bath.',
  'baby_lotion': 'A mild moisturiser for delicate newborn skin.',
  'baby_homeoutfit': 'The going-home outfit — and those first photos.',
  'partner_clothes': 'A change of clothes, for a stay that can run long.',
  'partner_snacks': 'Keeps your partner fuelled and steady beside you.',
  'partner_charger': 'One long night drains every phone — pack a power bank.',
  'partner_cash': 'Small cash and cards for parking, canteen and forms.',
  'partner_toiletries': 'The basics, so your partner can freshen up too.',
  'docs_id': 'Admission needs a photo ID — keep it right on top.',
  'docs_admission': 'Your hospital registration and admission papers.',
  'docs_insurance': 'Insurance or TPA card, to smooth the paperwork.',
  'docs_records': 'Your scan reports and medical file, for the team.',
  'docs_birthplan': "If you've written one, keep a copy handy.",
  'docs_contacts': "Your doctor's number — saved, and on paper.",
  'comfort_pillow': 'Your own pillow makes a strange bed feel like home.',
  'comfort_eyemask': 'Blocks bright ward lights so you can rest.',
  'comfort_scent': 'A familiar scent is grounding when things feel intense.',
  'comfort_affirm': 'A few calming words to focus on during labour.',
  'sugg_nursingpillow': 'Supports your baby at the breast and saves your arms.',
  'sugg_extraoutfit': 'A spare, for the inevitable little accidents.',
  'sugg_compsocks': 'Eases the swelling that often comes after birth.',
  'sugg_handfan': 'A little cooling relief through the warm hours.',
  'sugg_speaker': 'To play your calming music out loud.',
  'sugg_journal': 'For the first notes and feelings you\'ll want to keep.',
};

String whyPack(BagItem i) =>
    kWhyPack[i.id] ?? 'A thoughtful thing to have with you.';

// ---- season -----------------------------------------------------------------
enum Season { winter, summer, monsoon, pleasant }

/// India-leaning season from a month (1–12).
Season seasonForMonth(int month) {
  if (month == 12 || month <= 2) return Season.winter;
  if (month >= 3 && month <= 5) return Season.summer;
  if (month >= 6 && month <= 9) return Season.monsoon;
  return Season.pleasant; // Oct–Nov
}

String seasonLabel(Season s) => switch (s) {
      Season.winter => 'Winter',
      Season.summer => 'Summer',
      Season.monsoon => 'Monsoon',
      Season.pleasant => 'Pleasant',
    };

// ---- hospital-provides tokens ----------------------------------------------
//  Things a hospital commonly provides; if the mother marks one, we drop the
//  matching catalogue item from "what's left" and surface a reassuring insight.
const Map<String, String> kHospitalProvidableLabel = {
  'diapers': 'Diapers',
  'blankets': 'Receiving blankets',
  'babytowel': 'Baby towels',
  'wipes': 'Wipes',
};

/// The catalogue item id a hospital-provides token removes from the bag.
const Map<String, String> kProvidesToItemId = {
  'diapers': 'baby_diapers',
  'blankets': 'baby_blanket',
  'babytowel': 'baby_towel',
  'wipes': 'baby_wipes',
};

Set<String> providedItemIds(Set<String> tokens) =>
    {for (final t in tokens) if (kProvidesToItemId[t] != null) kProvidesToItemId[t]!};

// ---- contextual insight cards ----------------------------------------------
class ReadyInsight {
  const ReadyInsight(this.icon, this.text);
  final IconData icon;
  final String text;
}

/// The intelligent, contextual insights that replace long articles. Ordered by
/// relevance; the caller shows the top few.
List<ReadyInsight> readyInsights({
  required int week,
  required DeliveryType delivery,
  required Season season,
  required bool twins,
  required Set<String> hospitalProvides,
}) {
  final out = <ReadyInsight>[];

  // Timing (week-aware, never pressuring).
  if (week >= 38) {
    out.add(const ReadyInsight(Icons.event_available_rounded,
        "You're full term — your bag is best kept packed and by the door now."));
  } else if (week >= 36) {
    out.add(const ReadyInsight(Icons.event_available_rounded,
        'Around week 36 is the ideal time to have everything packed and ready.'));
  } else if (week >= 32) {
    out.add(const ReadyInsight(Icons.inventory_2_outlined,
        'A lovely time to start collecting essentials — no rush, just a little at a time.'));
  } else {
    out.add(const ReadyInsight(Icons.spa_outlined,
        'Plenty of time yet. Explore what you\'ll eventually need, gently.'));
  }

  // Delivery type.
  if (delivery == DeliveryType.csection) {
    out.add(const ReadyInsight(Icons.checkroom_rounded,
        'For your planned C-section, loose high-waisted clothing is usually more comfortable afterward.'));
  }

  // Twins.
  if (twins) {
    out.add(const ReadyInsight(Icons.child_friendly_rounded,
        'Twins on the way — pack a few extra bodysuits, more diapers and a second going-home outfit.'));
  }

  // Season.
  switch (season) {
    case Season.winter:
      out.add(const ReadyInsight(Icons.ac_unit_rounded,
          'Winter delivery — one extra blanket and a warm cap make the ride home cosy.'));
      break;
    case Season.summer:
      out.add(const ReadyInsight(Icons.wb_sunny_rounded,
          'Summer delivery — light muslin layers keep your baby comfortable; skip the heavy blanket.'));
      break;
    case Season.monsoon:
      out.add(const ReadyInsight(Icons.umbrella_rounded,
          'Monsoon days — a waterproof cover for the bag and one spare dry set are worth it.'));
      break;
    case Season.pleasant:
      break;
  }

  // Hospital provides.
  for (final t in hospitalProvides) {
    final label = kHospitalProvidableLabel[t];
    if (label != null) {
      out.add(ReadyInsight(Icons.local_hospital_outlined,
          'Your hospital provides ${label.toLowerCase()} — no need to pack your own.'));
    }
  }

  // Always-true gentle reassurance (kept last).
  out.add(const ReadyInsight(Icons.favorite_border_rounded,
      'Most hospitals provide a cot and basic newborn care — pack for comfort, not duplication.'));

  return out;
}

// ---- emergency grab-list ----------------------------------------------------
class GrabItem {
  const GrabItem(this.icon, this.title, this.sub);
  final IconData icon;
  final String title;
  final String sub;
}

const List<GrabItem> kEmergencyGrab = [
  GrabItem(Icons.luggage_rounded, 'Your hospital bag', 'Packed and by the door'),
  GrabItem(Icons.folder_rounded, 'Documents folder', 'ID, admission papers, records'),
  GrabItem(Icons.smartphone_rounded, 'Phone + charger', "And your doctor's number"),
  GrabItem(Icons.water_drop_outlined, 'Water bottle', 'For the journey there'),
];

// ---- guided packing order ---------------------------------------------------
//  Documents first (fastest win), then Mom, Baby, Partner & extras.
const List<ReadyCategory> kGuidedOrder = [
  ReadyCategory.documents,
  ReadyCategory.mom,
  ReadyCategory.baby,
  ReadyCategory.partnerExtras,
];

/// A gentle estimate of minutes left from the number of unpacked items.
int estMinutesFor(int remaining) => remaining <= 0 ? 0 : (remaining * 0.6).ceil().clamp(1, 60);
