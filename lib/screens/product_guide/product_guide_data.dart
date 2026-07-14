// =============================================================================
//  ParentVeda Product Guide — data model + catalogue (shared, app-independent)
// -----------------------------------------------------------------------------
//  Powers the "world's most trustworthy parenting product page". This is NOT an
//  Amazon spec sheet: a parent should decide in ~10 seconds whether a product
//  suits their child (hero: recommendation, verdict, best-for, watch-out), and
//  only go deeper if they want to (experts, community, ingredients, research,
//  category-specific specs). Lives in its own folder so BOTH apps (pregnancy +
//  parenting) can import it; styling is self-contained in the screen. Only
//  research-before-you-buy products get a Guide — this seed covers the key ones.
// =============================================================================

import 'package:flutter/material.dart';

/// The ParentVeda recommendation band — a label, never bare stars. Ordered best
/// → most cautious; the screen maps [tone] to a colour + status dot.
enum PgReco { highly, recommended, considerations, specific, notRecommended }

extension PgRecoX on PgReco {
  String get label => switch (this) {
        PgReco.highly => 'Highly recommended',
        PgReco.recommended => 'Recommended',
        PgReco.considerations => 'Recommended with considerations',
        PgReco.specific => 'For specific use',
        PgReco.notRecommended => 'Generally not needed',
      };

  /// 0 = positive, 1 = neutral, 2 = cautious — the screen picks the colour.
  int get tone => switch (this) {
        PgReco.highly => 0,
        PgReco.recommended => 0,
        PgReco.considerations => 1,
        PgReco.specific => 1,
        PgReco.notRecommended => 2,
      };
}

class PgRating {
  const PgRating(this.parentveda, this.community);
  final double parentveda;
  final double community;
}

/// A short expert video (placeholder playback — the module is prototype-shaped).
class PgExpert {
  const PgExpert({required this.role, required this.name, required this.hook, required this.duration});
  final String role; // 'Paediatrician', 'Dermatologist', 'Lactation consultant'…
  final String name;
  final String hook; // one line: what they explain
  final String duration; // '2:10'
}

/// A useful, practical community experience (not a star dump).
class PgExperience {
  const PgExperience({required this.text, required this.author, required this.context});
  final String text;
  final String author;
  final String context; // 'Winter · 3-month-old', 'Summer · newborn'…
}

/// One important ingredient, explained (never the full INCI dump).
class PgIngredient {
  const PgIngredient({required this.name, required this.purpose, required this.note});
  final String name;
  final String purpose;
  final String note; // the ParentVeda note
}

/// A study, translated to plain language.
class PgStudy {
  const PgStudy({required this.summary, required this.meaning});
  final String summary;
  final String meaning; // what this means for parents
}

/// A single category-appropriate spec (fields differ per category by design).
class PgSpec {
  const PgSpec(this.label, this.value);
  final String label;
  final String value;
}

class ProductGuide {
  const ProductGuide({
    required this.id,
    required this.category,
    required this.icon,
    required this.brand,
    required this.name,
    required this.reco,
    required this.rating,
    required this.verdict,
    required this.beforeYouBuy,
    required this.bestFor,
    required this.whyLike,
    required this.watchOut,
    this.experts = const [],
    this.experiences = const [],
    this.ingredients = const [],
    this.studies = const [],
    this.specs = const [],
    this.buyLabel = 'See buying options',
    this.relatedIds = const [],
  });

  final String id;
  final String category; // 'Baby skincare', 'Feeding', 'Baby gear'…
  final IconData icon;
  final String brand;
  final String name;

  final PgReco reco;
  final PgRating rating;

  /// ≤20 words — the instant summary.
  final String verdict;

  /// The ParentVeda differentiator: ONE honest sentence before recommending.
  final String beforeYouBuy;

  final List<String> bestFor; // chips
  final List<String> whyLike; // ≤3
  final List<String> watchOut; // ≤3

  // Deep dive (all optional).
  final List<PgExpert> experts;
  final List<PgExperience> experiences;
  final List<PgIngredient> ingredients;
  final List<PgStudy> studies;
  final List<PgSpec> specs;

  final String buyLabel;
  final List<String> relatedIds;
}

// =============================================================================
//  Catalogue — the products parents actively research. Rich but concise.
// =============================================================================
const List<ProductGuide> kProductGuides = [
  // ----------------------------------------------------------- skincare ------
  ProductGuide(
    id: 'baby_lotion',
    category: 'Baby skincare',
    icon: Icons.spa_rounded,
    brand: 'ParentVeda',
    name: 'Fragrance-Free Baby Lotion',
    reco: PgReco.highly,
    rating: PgRating(4.8, 4.7),
    verdict: 'An excellent fragrance-free daily moisturiser for babies with dry or sensitive skin.',
    beforeYouBuy: 'Not every baby needs a daily moisturiser — this is most useful for dry or sensitive skin, or in winter.',
    bestFor: ['Dry skin', 'Sensitive skin', 'Newborn', 'Winter'],
    whyLike: ['Rich, lasting hydration', 'Spreads easily, absorbs fast', 'Fragrance- and dye-free'],
    watchOut: ['Can feel heavy on already-oily skin', 'A little pricier than basic lotions'],
    experts: [
      PgExpert(role: 'Dermatologist', name: 'Dr. Anaya Rao', hook: 'How to moisturise newborn skin — and when you don\'t need to', duration: '2:20'),
      PgExpert(role: 'Paediatrician', name: 'Dr. Vikram Sethi', hook: 'Reading a baby lotion label in 60 seconds', duration: '1:10'),
    ],
    experiences: [
      PgExperience(text: 'Cleared my baby\'s dry winter cheeks in a few days.', author: 'Meera', context: 'Winter · 4-month-old'),
      PgExperience(text: 'Felt a bit heavy in Delhi summer — we switched to a lighter one.', author: 'Sana', context: 'Summer · 8-month-old'),
      PgExperience(text: 'No reaction at all on very sensitive skin — a relief.', author: 'Ritu', context: 'Newborn'),
    ],
    ingredients: [
      PgIngredient(name: 'Glycerin', purpose: 'Draws in and holds moisture.', note: 'A gentle, widely-used humectant — well tolerated by most babies.'),
      PgIngredient(name: 'Ceramides', purpose: 'Rebuild the skin barrier.', note: 'Especially helpful for dry or eczema-prone skin.'),
      PgIngredient(name: 'Fragrance', purpose: 'Adds scent.', note: 'This product is fragrance-free — many parents prefer that for newborns.'),
    ],
    studies: [
      PgStudy(summary: 'Daily moisturising in the first weeks reduced eczema risk in at-risk babies in several trials.', meaning: 'If eczema runs in your family, a gentle daily moisturiser may genuinely help — worth discussing with your doctor.'),
    ],
    specs: [
      PgSpec('Texture', 'Light cream'),
      PgSpec('Free from', 'Fragrance, dyes, parabens'),
      PgSpec('Key ingredients', 'Glycerin, ceramides'),
      PgSpec('Volume', '200 ml'),
      PgSpec('Age', 'Newborn+'),
    ],
    relatedIds: ['baby_wash', 'diapers'],
  ),
  ProductGuide(
    id: 'baby_wash',
    category: 'Baby skincare',
    icon: Icons.water_drop_outlined,
    brand: 'ParentVeda',
    name: 'Tear-Free Baby Wash',
    reco: PgReco.recommended,
    rating: PgRating(4.6, 4.6),
    verdict: 'A gentle, tear-free wash that doubles as shampoo for everyday baby baths.',
    beforeYouBuy: 'Newborns rarely need soap every day — plain water is often enough; a mild wash is handy 2–3 times a week.',
    bestFor: ['Newborn', 'Sensitive skin', 'Everyday'],
    whyLike: ['Genuinely tear-free', 'One bottle for hair and body', 'Rinses clean, no residue'],
    watchOut: ['Not a moisturiser — pair with lotion if skin is dry'],
    experts: [
      PgExpert(role: 'Paediatrician', name: 'Dr. Vikram Sethi', hook: 'How often does a baby actually need washing?', duration: '1:40'),
    ],
    experiences: [
      PgExperience(text: 'No stinging eyes even when it runs down — finally.', author: 'Priya', context: '6-month-old'),
      PgExperience(text: 'A little goes a long way; one bottle lasted months.', author: 'Kavya', context: 'Newborn'),
    ],
    specs: [
      PgSpec('Texture', 'Light gel'),
      PgSpec('Free from', 'Soap, sulphates, fragrance'),
      PgSpec('Use', 'Hair + body'),
      PgSpec('Volume', '250 ml'),
      PgSpec('Age', 'Newborn+'),
    ],
    relatedIds: ['baby_lotion'],
  ),
  // ---------------------------------------------------------- diapering ------
  ProductGuide(
    id: 'diapers',
    category: 'Diapering',
    icon: Icons.child_friendly_rounded,
    brand: 'ParentVeda',
    name: 'Newborn Diapers',
    reco: PgReco.highly,
    rating: PgRating(4.7, 4.8),
    verdict: 'Soft, snug newborn diapers with a wetness line and a gentle cord-stump cut-out.',
    beforeYouBuy: 'Newborn size is outgrown in a few weeks — buy just a pack or two before the birth, not in bulk.',
    bestFor: ['Newborn', 'Sensitive skin', 'Overnight'],
    whyLike: ['Snug newborn fit, few leaks', 'Wetness indicator line', 'Soft, breathable against skin'],
    watchOut: ['Newborn size lasts only ~3–4 weeks', 'Pricier than economy packs'],
    experiences: [
      PgExperience(text: 'Almost no leaks overnight, even on a tummy-sleeper.', author: 'Anjali', context: 'Newborn'),
      PgExperience(text: 'The wetness line is genuinely useful for new parents.', author: 'Farhan', context: '1-month-old'),
      PgExperience(text: 'Brought a little redness — we alternate with a cloth now.', author: 'Deepa', context: 'Summer · newborn'),
    ],
    specs: [
      PgSpec('Size', 'Newborn (up to 5 kg)'),
      PgSpec('Features', 'Wetness line, cord cut-out'),
      PgSpec('Absorbency', 'Up to 12 hours'),
      PgSpec('Free from', 'Fragrance, lotion, latex'),
    ],
    relatedIds: ['baby_wipes'],
  ),
  ProductGuide(
    id: 'baby_wipes',
    category: 'Diapering',
    icon: Icons.cleaning_services_outlined,
    brand: 'ParentVeda',
    name: 'Water Wipes',
    reco: PgReco.recommended,
    rating: PgRating(4.6, 4.7),
    verdict: 'Thick, 99%-water wipes that are gentle enough for newborn skin and nappy changes.',
    beforeYouBuy: 'For the first weeks, cotton wool and warm water is gentlest — water wipes are the convenient everyday step up.',
    bestFor: ['Newborn', 'Sensitive skin', 'Travel'],
    whyLike: ['99% water, fragrance-free', 'Thick — fewer per change', 'Gentle on broken or red skin'],
    watchOut: ['Costlier than standard wipes', 'Keep the pack sealed so they don\'t dry out'],
    ingredients: [
      PgIngredient(name: 'Purified water', purpose: 'Cleans gently.', note: 'Makes up ~99% — the closest thing to cotton and water.'),
      PgIngredient(name: 'Fruit extract (trace)', purpose: 'Mild skin conditioner.', note: 'A tiny amount; the product stays fragrance-free.'),
    ],
    specs: [
      PgSpec('Composition', '99% water'),
      PgSpec('Free from', 'Fragrance, alcohol, parabens'),
      PgSpec('Count', '60 per pack'),
      PgSpec('Age', 'Newborn+'),
    ],
    relatedIds: ['diapers'],
  ),
  // ------------------------------------------------------------ feeding ------
  ProductGuide(
    id: 'bottle_sterilizer',
    category: 'Feeding',
    icon: Icons.local_fire_department_outlined,
    brand: 'ParentVeda',
    name: 'Electric Steam Sterilizer',
    reco: PgReco.specific,
    rating: PgRating(4.4, 4.3),
    verdict: 'A fast, fuss-free steam sterilizer — genuinely useful if you bottle-feed regularly.',
    beforeYouBuy: 'A sterilizer helps in the first few months if you use bottles a lot — but not every family needs one; boiling water works too.',
    bestFor: ['Bottle feeding', 'First 3 months', 'Twins'],
    whyLike: ['Sterilises a full set in ~8 minutes', 'Holds bottles, pump parts and teats', 'Simple one-button use'],
    watchOut: ['Takes counter space', 'Not needed if you rarely use bottles'],
    experts: [
      PgExpert(role: 'Paediatrician', name: 'Dr. Nandini Iyer', hook: 'Do you really need to sterilise — and for how long?', duration: '2:45'),
    ],
    experiences: [
      PgExperience(text: 'A lifesaver with twins and endless bottles.', author: 'Rhea', context: 'Twins · newborn'),
      PgExperience(text: 'We mostly breastfeed, so it sat unused — would skip it.', author: 'Nisha', context: '2-month-old'),
    ],
    specs: [
      PgSpec('Type', 'Electric steam'),
      PgSpec('Capacity', '6 bottles'),
      PgSpec('Cycle', '~8 minutes'),
      PgSpec('Fits', 'Bottles, teats, pump parts'),
    ],
    relatedIds: ['breast_pump', 'formula'],
  ),
  ProductGuide(
    id: 'breast_pump',
    category: 'Feeding',
    icon: Icons.favorite_border_rounded,
    brand: 'ParentVeda',
    name: 'Single Electric Breast Pump',
    reco: PgReco.considerations,
    rating: PgRating(4.5, 4.4),
    verdict: 'A quiet, comfortable electric pump — great for occasional expressing, less so for exclusive pumping.',
    beforeYouBuy: 'How often you\'ll pump matters most: for the odd bottle a single pump is plenty; for daily/return-to-work, consider a double.',
    bestFor: ['Occasional expressing', 'Returning to work', 'Building a stash'],
    whyLike: ['Quiet motor', 'Adjustable, comfortable suction', 'Few parts — quick to clean'],
    watchOut: ['Single pump is slow for exclusive pumping', 'Check flange size for comfort'],
    experts: [
      PgExpert(role: 'Lactation consultant', name: 'Dr. Leena Menon', hook: 'Getting a comfortable latch — and the right flange size', duration: '3:00'),
      PgExpert(role: 'Lactation consultant', name: 'Dr. Leena Menon', hook: 'Single vs double: which pump for your situation', duration: '1:50'),
    ],
    experiences: [
      PgExperience(text: 'Comfortable and quiet enough to use beside a sleeping baby.', author: 'Tara', context: 'Returning to work'),
      PgExperience(text: 'Too slow when I tried exclusive pumping — a double is better for that.', author: 'Ishita', context: 'Exclusive pumping'),
    ],
    specs: [
      PgSpec('Type', 'Single electric'),
      PgSpec('Modes', 'Massage + express'),
      PgSpec('Suction levels', '9'),
      PgSpec('Power', 'Mains + battery'),
    ],
    relatedIds: ['bottle_sterilizer'],
  ),
  ProductGuide(
    id: 'formula',
    category: 'Feeding',
    icon: Icons.local_drink_rounded,
    brand: 'ParentVeda',
    name: 'Stage 1 Infant Formula',
    reco: PgReco.specific,
    rating: PgRating(4.5, 4.5),
    verdict: 'A solid first-stage formula for when breastfeeding isn\'t possible or is being supplemented.',
    beforeYouBuy: 'All first-stage formulas in India meet the same safety standard — brand matters far less than choosing one and using it correctly.',
    bestFor: ['Formula feeding', 'Combination feeding', 'Supplementing'],
    whyLike: ['Meets first-stage nutrition standards', 'Mixes smoothly, fewer clumps', 'Widely available'],
    watchOut: ['Never make it more concentrated than the label says', 'Switch brands only if your doctor advises'],
    experts: [
      PgExpert(role: 'Paediatrician', name: 'Dr. Nandini Iyer', hook: 'How to prepare a bottle safely, step by step', duration: '2:30'),
      PgExpert(role: 'Nutritionist', name: 'Dr. Aarti Bal', hook: 'Reading a formula tin: what actually matters', duration: '2:05'),
    ],
    experiences: [
      PgExperience(text: 'Settled easily with my baby when we combination-fed.', author: 'Pooja', context: 'Combination feeding'),
      PgExperience(text: 'Doctor said any stage-1 is fine — this one mixed cleanest.', author: 'Simran', context: 'Supplementing'),
    ],
    ingredients: [
      PgIngredient(name: 'Whey/casein blend', purpose: 'The protein base.', note: 'First-stage blends are designed to be gentle on newborn digestion.'),
      PgIngredient(name: 'DHA/ARA', purpose: 'Support brain and eye development.', note: 'Now standard in most first-stage formulas.'),
      PgIngredient(name: 'Iron', purpose: 'Prevents iron deficiency.', note: 'Infant formulas are iron-fortified by regulation.'),
    ],
    studies: [
      PgStudy(summary: 'Regulators set a common nutritional floor for stage-1 formula; head-to-head brand differences in outcomes are minimal.', meaning: 'Pick one that suits your budget and availability, and focus on safe, correct preparation.'),
    ],
    specs: [
      PgSpec('Stage', '1 (0–6 months)'),
      PgSpec('Base', 'Cow\'s milk'),
      PgSpec('Fortified', 'Iron, DHA/ARA, vitamins'),
      PgSpec('Form', 'Powder'),
    ],
    relatedIds: ['bottle_sterilizer', 'breast_pump'],
  ),
  // -------------------------------------------------------------- gear -------
  ProductGuide(
    id: 'baby_carrier',
    category: 'Baby gear',
    icon: Icons.backpack_outlined,
    brand: 'ParentVeda',
    name: 'Ergonomic Baby Carrier',
    reco: PgReco.highly,
    rating: PgRating(4.7, 4.6),
    verdict: 'A supportive, ergonomic carrier that keeps hands free and settles fussy babies beautifully.',
    beforeYouBuy: 'Look for an ergonomic "M-shape" seat that supports the hips — the fabric type matters less than the fit for you and baby.',
    bestFor: ['Newborn', 'Fussy evenings', 'Small homes', 'Travel'],
    whyLike: ['Even weight across the hips and back', 'Ergonomic seat for baby\'s hips', 'Great for contact naps and colic'],
    watchOut: ['Can be warm in peak summer', 'A short learning curve to fit it well'],
    experts: [
      PgExpert(role: 'Occupational therapist', name: 'Dr. Kabir Shah', hook: 'Hip-healthy carrying: the M-position explained', duration: '2:15'),
    ],
    experiences: [
      PgExperience(text: 'The only thing that settled our witching-hour baby.', author: 'Neha', context: 'Fussy evenings · 6-week-old'),
      PgExperience(text: 'Warm at midday, so we use it mornings and evenings.', author: 'Zoya', context: 'Summer · 3-month-old'),
    ],
    specs: [
      PgSpec('Positions', 'Front-in, front-out, hip, back'),
      PgSpec('Seat', 'Ergonomic (M-shape)'),
      PgSpec('Weight range', '3.5–15 kg'),
      PgSpec('Support', 'Lumbar + wide straps'),
    ],
    relatedIds: ['stroller'],
  ),
  ProductGuide(
    id: 'stroller',
    category: 'Baby gear',
    icon: Icons.stroller_rounded,
    brand: 'ParentVeda',
    name: 'Lightweight Travel Stroller',
    reco: PgReco.recommended,
    rating: PgRating(4.5, 4.5),
    verdict: 'A lightweight, one-hand-fold stroller ideal for travel, cities and small homes.',
    beforeYouBuy: 'For newborns, check it reclines fully (or takes a car seat) — a lightweight stroller shines from a few months onward.',
    bestFor: ['Travel', 'City use', 'Small homes'],
    whyLike: ['Very light, one-hand fold', 'Compact folded footprint', 'Smooth to push and steer'],
    watchOut: ['Small wheels struggle on rough ground', 'Limited storage basket'],
    experiences: [
      PgExperience(text: 'Folds small enough for our tiny flat and the car boot.', author: 'Aisha', context: 'City · 5-month-old'),
      PgExperience(text: 'Bumpy on broken pavements — fine for malls and airports.', author: 'Rohan', context: 'Travel'),
    ],
    specs: [
      PgSpec('Weight', '5.8 kg'),
      PgSpec('Fold', 'One-hand, self-standing'),
      PgSpec('Recline', 'Multi-position'),
      PgSpec('Travel friendly', 'Cabin-friendly folded'),
    ],
    relatedIds: ['baby_carrier'],
  ),
];

// -----------------------------------------------------------------------------
//  Lookups
// -----------------------------------------------------------------------------
ProductGuide? pgById(String id) {
  for (final g in kProductGuides) {
    if (g.id == id) return g;
  }
  return null;
}

/// Distinct categories in first-seen order.
List<String> get pgCategories {
  final seen = <String>[];
  for (final g in kProductGuides) {
    if (!seen.contains(g.category)) seen.add(g.category);
  }
  return seen;
}

List<ProductGuide> pgInCategory(String category) =>
    kProductGuides.where((g) => g.category == category).toList();

/// Maps an app's own product id (or a lowercase name keyword) to a Guide, so a
/// product tapped elsewhere can offer "read the Product Guide". Extend as real
/// catalogue items are matched to guides.
const Map<String, String> kProductToGuide = {
  // hospital-bag catalogue ids (pregnancy side)
  'baby_lotion': 'baby_lotion',
  'baby_diapers': 'diapers',
  'baby_wipes': 'baby_wipes',
  'after_nursingbra': 'breast_pump', // nearest guide
};

/// Find a Guide for a tapped product by its id, else by a keyword in its name.
ProductGuide? guideForProduct({String? id, String? name}) {
  if (id != null) {
    final direct = pgById(id);
    if (direct != null) return direct;
    final mapped = kProductToGuide[id];
    if (mapped != null) return pgById(mapped);
  }
  if (name != null) {
    final n = name.toLowerCase();
    for (final g in kProductGuides) {
      final key = g.name.toLowerCase().split(' ').last; // 'lotion', 'stroller'…
      if (n.contains(key) || n.contains(g.category.toLowerCase())) return g;
    }
  }
  return null;
}
