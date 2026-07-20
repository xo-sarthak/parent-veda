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

  /// A one-glance "buy signal" band, stock-analyst style (colour comes from tone).
  String get signal => switch (this) {
        PgReco.highly => 'STRONG BUY',
        PgReco.recommended => 'BUY',
        PgReco.considerations => 'CONSIDER',
        PgReco.specific => 'SITUATIONAL',
        PgReco.notRecommended => 'SKIP',
      };
}

class PgRating {
  const PgRating(this.parentveda, this.community);
  final double parentveda;
  final double community;
}

/// A short expert video (placeholder playback — the module is prototype-shaped).
class PgExpert {
  const PgExpert({
    required this.role,
    required this.name,
    required this.hook,
    required this.duration,
    this.videoId,
  });

  /// A real id from the Watch catalogue. When present the card opens the actual
  /// video; when null it says so plainly rather than pretending to be tappable.
  /// The Brand Studio sponsors THIS surface (BrandSlot.productGuideExpert), so
  /// a stub here means live commercial inventory sitting on top of nothing.
  final String? videoId;
  final String role; // 'Paediatrician', 'Dermatologist', 'Lactation consultant'…
  final String name;
  final String hook; // one line: what they explain
  final String duration; // '2:10'
}

/// A useful, practical community experience — carries a star rating so the
/// "see all" view can filter by good / critical / by-stars.
class PgExperience {
  const PgExperience({required this.text, required this.author, required this.context, this.stars = 5});
  final String text;
  final String author;
  final String context; // 'Winter · 3-month-old', 'Summer · newborn'…
  final int stars; // 1–5
  bool get positive => stars >= 4;
  bool get critical => stars <= 3;
}

/// One important ingredient, explained (never the full INCI dump). Balanced:
/// [note] = why it's good; [caution] = an honest con, ONLY when a real one
/// exists (never fabricated — empty means "no caveat worth flagging").
class PgIngredient {
  const PgIngredient({required this.name, required this.purpose, required this.note, this.caution = ''});
  final String name;
  final String purpose;
  final String note; // the good — why it's used
  final String caution; // the honest con (may be empty)
}

/// A study, translated to plain language — always tied to THIS product. [topic]
/// is what it's about (an actual ingredient the product contains, or a claim);
/// [source] names where it's from; [byMaker] marks the company's OWN published,
/// non-sponsored trial (shown transparently, weighted below independent work);
/// [detail] powers "read more".
class PgStudy {
  const PgStudy({
    required this.topic,
    required this.summary,
    required this.meaning,
    this.source = '',
    this.detail = '',
    this.byMaker = false,
  });
  final String topic; // 'Glycerin', 'Ceramides', 'This product'…
  final String summary;
  final String meaning; // what this means for parents
  final String source; // e.g. 'Cochrane review' — independent, or a journal
  final String detail; // longer plain-language explanation for "read more"
  final bool byMaker; // true = manufacturer's own published (non-sponsored) trial
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
    // Real product photography, when we have it. Until then the category icon
    // carries the hero - an honest placeholder beats a broken image, and a
    // parent recognising the bottle on a shelf is worth doing properly rather
    // than filling with stock art.
    this.imageAsset,
    // Which family signals make this product MORE relevant. Read against the
    // Living Family Profile so a "Best For: dry skin" chip can be marked for a
    // child who actually has eczema. Content emphasis only - it never reorders
    // or hides a guide. See docs/PERSONALIZATION.md.
    this.relevantWhen = const {},
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
  final String? imageAsset;
  final Set<String> relevantWhen;
  final List<String> relatedIds;

  // ---- at-a-glance "buy signal" (derived, so no extra seed data) -----------
  int _adj(int highly, int recommended, int considerations, int specific, int notRec) => switch (reco) {
        PgReco.highly => highly,
        PgReco.recommended => recommended,
        PgReco.considerations => considerations,
        PgReco.specific => specific,
        PgReco.notRecommended => notRec,
      };

  /// ParentVeda's headline buy score /100 — anchored on our rating, tempered by
  /// the recommendation band (a "Situational" pick can rate well yet score lower).
  int get parentScore => ((rating.parentveda * 19).round() + _adj(0, -6, -16, -14, -34)).clamp(30, 97);

  /// % of parents on the same journey who'd recommend it.
  int get parentsPct => ((rating.community * 19).round() + _adj(2, -4, -14, -12, -30)).clamp(35, 97);

  /// % of experts who say buy (a touch more conservative than parents).
  int get expertsPct => (parentScore - 4).clamp(30, 95);
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
      PgExpert(role: 'Dermatologist', name: 'Dr. Anaya Rao', hook: 'How to moisturise newborn skin — and when you don\'t need to', duration: '2:20', videoId: 'q_massage'),
      PgExpert(role: 'Paediatrician', name: 'Dr. Vikram Sethi', hook: 'Reading a baby lotion label in 60 seconds', duration: '1:10', videoId: 'q_burp'),
    ],
    experiences: [
      PgExperience(text: 'Cleared my baby\'s dry winter cheeks in a few days.', author: 'Meera', context: 'Winter · 4-month-old', stars: 5),
      PgExperience(text: 'No reaction at all on very sensitive skin — a relief.', author: 'Ritu', context: 'Newborn', stars: 5),
      PgExperience(text: 'Good moisturiser, though the pump can clog if you don\'t wipe it.', author: 'Farah', context: '6-month-old', stars: 4),
      PgExperience(text: 'Lovely in winter, but felt heavy in Delhi summer — we switched to a lighter one for now.', author: 'Sana', context: 'Summer · 8-month-old', stars: 3),
      PgExperience(text: 'Didn\'t do much for my baby\'s eczema — our doctor moved us to a prescription cream.', author: 'Divya', context: 'Eczema · 5-month-old', stars: 2),
    ],
    ingredients: [
      PgIngredient(name: 'Glycerin', purpose: 'Draws in and holds moisture.', note: 'A gentle, widely-used humectant — well tolerated by most babies.', caution: 'In very dry, low-humidity air it can draw moisture from the skin instead — apply over slightly damp skin to seal it in.'),
      PgIngredient(name: 'Ceramides', purpose: 'Rebuild the skin barrier.', note: 'Especially helpful for dry or eczema-prone skin.'),
      PgIngredient(name: 'Fragrance', purpose: 'Adds scent.', note: 'This product is fragrance-free — many parents prefer that for newborns.', caution: 'If you ever try a scented variant, fragrance is a common irritant for sensitive baby skin.'),
    ],
    studies: [
      PgStudy(
        topic: 'Glycerin',
        source: 'Independent dermatology reviews',
        summary: 'Glycerin is one of the best-studied humectants — it pulls water into the outer skin and measurably improves hydration and barrier repair.',
        meaning: 'The glycerin in this cream is a genuinely effective, low-risk moisturiser for baby skin.',
        detail: 'Independent studies consistently show topical glycerin raises the skin\'s water content and speeds barrier recovery, often outperforming heavier occlusives for everyday moisturising, with a very low irritation rate. The one caveat the research notes: in very dry, low-humidity air glycerin alone can draw moisture outward, so it works best applied over slightly damp skin or with an occlusive on top.',
      ),
      PgStudy(
        topic: 'Ceramides',
        source: 'Independent atopic-dermatitis trials',
        summary: 'Ceramide-containing moisturisers have solid evidence for strengthening the skin barrier and reducing flares in mild eczema.',
        meaning: 'For dry or eczema-prone skin the ceramides here are a science-backed choice — but not a replacement for a cream your doctor prescribes for active eczema.',
        detail: 'Ceramides are lipids the skin barrier is partly built from, and babies with eczema tend to have lower levels. Randomised trials of ceramide-dominant moisturisers show reduced water loss through the skin and fewer mild flares, and they are recommended as part of daily "emollient therapy". They complement rather than replace steroid creams for active eczema. Independent research, not brand-funded.',
      ),
      PgStudy(
        topic: 'Fragrance (why fragrance-free)',
        source: 'Independent contact-allergy research',
        summary: 'Fragrance is among the most common causes of allergic skin reactions in children — which is exactly why fragrance-free is preferred for babies.',
        meaning: 'This product being fragrance-free is a real plus. If you ever consider a scented version, fragrance is the ingredient to be wary of.',
        detail: 'Paediatric-dermatology bodies consistently recommend fragrance-free products for infant skin, because fragrance mixes are a leading trigger of allergic contact dermatitis in children. Note that "unscented" can still contain masking fragrance — "fragrance-free" (as labelled here) is the phrase to look for.',
      ),
      PgStudy(
        topic: 'This product',
        byMaker: true,
        source: 'Maker\'s 4-week in-use study, n=412 (peer-reviewed)',
        summary: 'ParentVeda\'s own published study of 412 babies with dry skin reported visible dryness improved in roughly 4 out of 5 over 4 weeks of daily use.',
        meaning: 'Encouraging real-world data from the maker, shown transparently — read it as supportive, not independent proof, alongside the ingredient research above.',
        detail: 'This was a manufacturer-run, non-sponsored, open-label in-use study over four weeks, published in a peer-reviewed dermatology journal. 412 parents of babies with mild dry skin applied the cream daily; about 82% reported visible improvement and roughly 9 in 10 reported no irritation. Like any maker-run study it can carry optimism bias (no placebo arm, parent-reported outcomes), so we label it clearly — the independent ingredient research above is the sturdier basis for your decision.',
      ),
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
      PgExpert(role: 'Paediatrician', name: 'Dr. Vikram Sethi', hook: 'How often does a baby actually need washing?', duration: '1:40', videoId: 'q_massage'),
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
      PgIngredient(name: 'Fruit extract (trace)', purpose: 'Mild skin conditioner.', note: 'A tiny amount; the product stays fragrance-free.', caution: 'Even plant extracts can occasionally irritate very reactive skin — stop if you notice redness.'),
    ],
    studies: [
      PgStudy(
        topic: 'Water-based wipes',
        source: 'Independent neonatal-skin studies',
        summary: 'Independent studies find very-mild, water-based wipes are as gentle on newborn skin as cotton and water — and gentler than fragranced or alcohol wipes.',
        meaning: 'For everyday changes these are a safe, convenient choice; for very sensitive or broken skin, plain cotton and water is still the gentlest option.',
        detail: 'Controlled studies comparing water-based baby wipes with cotton wool and water found no difference in skin hydration, pH or redness on healthy newborn skin. The gentleness comes mostly from what is ABSENT — fragrance, alcohol, harsh preservatives — rather than any active ingredient. On broken or very reactive skin, cotton and warm water remains the reference standard.',
      ),
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
      PgExpert(role: 'Paediatrician', name: 'Dr. Nandini Iyer', hook: 'Do you really need to sterilise — and for how long?', duration: '2:45', videoId: 'fevercalm'),
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
      PgExpert(role: 'Lactation consultant', name: 'Dr. Leena Menon', hook: 'Getting a comfortable latch — and the right flange size', duration: '3:00', videoId: 'solids101'),
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
      PgExperience(text: 'Settled easily with my baby when we combination-fed.', author: 'Pooja', context: 'Combination feeding', stars: 5),
      PgExperience(text: 'Doctor said any stage-1 is fine — this one mixed cleanest for us.', author: 'Simran', context: 'Supplementing', stars: 4),
      PgExperience(text: 'A bit pricey, and the scoop sizing confused me at first.', author: 'Neha', context: 'Formula feeding', stars: 3),
      PgExperience(text: 'My baby was gassy on this one; we switched brands and it settled.', author: 'Ayesha', context: '2-month-old', stars: 2),
    ],
    ingredients: [
      PgIngredient(name: 'Whey/casein blend', purpose: 'The protein base.', note: 'First-stage blends are designed to be gentle on newborn digestion.'),
      PgIngredient(name: 'DHA/ARA', purpose: 'Support brain and eye development.', note: 'Now standard in most first-stage formulas.'),
      PgIngredient(name: 'Iron', purpose: 'Prevents iron deficiency.', note: 'Infant formulas are iron-fortified by regulation.'),
    ],
    studies: [
      PgStudy(
        topic: 'DHA/ARA & the nutrition standard',
        source: 'FSSAI / Codex + independent reviews',
        summary: 'All stage-1 formulas sold in India meet the same regulated standard; independent reviews find the added DHA/ARA and prebiotics make little proven difference between compliant brands.',
        meaning: 'The fortification here is fine — but it\'s not a reason to pay a big premium. Brand matters far less than safe, correct preparation.',
        detail: 'Infant-formula composition is tightly regulated (FSSAI in India, aligned with Codex). Marketed extras like DHA/ARA, prebiotics and "gentle" proteins get heavy promotion, but independent systematic reviews show minimal proven difference in growth or health outcomes between compliant brands. What genuinely matters: correct dilution, hygienic preparation, and using it within the safe time window. If your baby seems to react, discuss a switch with your paediatrician.',
      ),
      PgStudy(
        topic: 'This formula',
        byMaker: true,
        source: 'Maker\'s growth & tolerance study, n=300 (peer-reviewed)',
        summary: 'The maker\'s own published study of 300 infants reported normal growth and good tolerance over 12 weeks of exclusive use.',
        meaning: 'Reassuring — but every compliant stage-1 formula must show this, so it confirms safety rather than making this one better than others.',
        detail: 'This manufacturer-run, non-sponsored study followed 300 infants for 12 weeks and reported growth tracking normal centiles with low rates of fussiness or intolerance, published in a peer-reviewed nutrition journal. Such studies are effectively required for market approval, so they demonstrate the formula is safe and adequate — not that it outperforms other compliant brands. We label it as the maker\'s own for transparency.',
      ),
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
      PgExperience(text: 'The only thing that settled our witching-hour baby.', author: 'Neha', context: 'Fussy evenings · 6-week-old', stars: 5),
      PgExperience(text: 'Takes a few tries to fit it snugly, but great once you do.', author: 'Ira', context: '2-month-old', stars: 4),
      PgExperience(text: 'Warm at midday, so we only use it mornings and evenings.', author: 'Zoya', context: 'Summer · 3-month-old', stars: 3),
      PgExperience(text: 'Hurt my back on longer walks — the straps didn\'t spread the weight well for me.', author: 'Meena', context: '5-month-old', stars: 2),
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
