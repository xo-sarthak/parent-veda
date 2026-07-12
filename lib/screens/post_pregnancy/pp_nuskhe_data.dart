// =============================================================================
//  pp_nuskhe_data - content model + catalog for Dadi/Nani ke Nuskhe (S19)
// -----------------------------------------------------------------------------
//  Single source of truth for the home-remedies section. A [Remedy] carries
//  everything the landing, the per-situation list and the detail page render:
//  the one-line, a full description, age gates (with an optional caution), quick
//  facts, ingredients, method, when-to-use, the differentiating red-flags block,
//  the reviewing ayurvedic panel, related shop/read links, an optional sponsored
//  slot and an optional demo-video seam. Content is deliberately safe, standard
//  household ayurveda with clear age gates - nothing that substitutes a doctor.
//  Isolated to the post_pregnancy module.
// =============================================================================

import 'package:flutter/material.dart';

// ---- small value types ------------------------------------------------------

/// The ayurvedic reviewer credited on a remedy's "signed off by" panel.
class RemedyPanel {
  const RemedyPanel({required this.lead, required this.note});
  final String lead; // e.g. "Dr. Kamala Iyer (BAMS)"
  final String note; // trailing sentence, e.g. " & 4 practitioners…"
}

/// A related shop/read link shown under a remedy. Visual only (no live target).
class RemedyLink {
  const RemedyLink(this.tag, this.title);
  final String tag; // 'Shop' | 'Read'
  final String title;
}

/// A labelled sponsored product slot (optional, per remedy).
class RemedySponsor {
  const RemedySponsor(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

/// The default reviewing panel (used unless a remedy names its own lead vaidya).
const RemedyPanel kDefaultPanel = RemedyPanel(
  lead: 'Dr. Kamala Iyer (BAMS)',
  note: ' & 4 practitioners, cross-checked by an MBBS paediatrician.',
);
const RemedyPanel _panelDeshpande = RemedyPanel(
  lead: 'Dr. Anil Deshpande (BAMS, MD Ayurveda)',
  note: ' & the panel, cross-checked by an MBBS paediatrician.',
);
const RemedyPanel _panelNair = RemedyPanel(
  lead: 'Dr. Lakshmi Nair (BAMS)',
  note: ' & 4 practitioners, cross-checked by an MBBS paediatrician.',
);

// ---- the remedy model -------------------------------------------------------

class Remedy {
  const Remedy({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.oneLine,
    required this.description,
    required this.age,
    this.ageWarning,
    required this.frequency,
    required this.prepTime,
    required this.ingredients,
    required this.steps,
    required this.whenToUse,
    required this.redFlags,
    this.reviewer = kDefaultPanel,
    this.related = const [],
    this.sponsor,
    this.hasVideo = false,
    this.videoNote,
    this.popular = false,
  });

  final String id;
  final String name;
  final String category; // one of kNuskheCategories names
  final IconData icon;
  final String oneLine; // short subtitle for list rows / search results
  final String description; // fuller hero paragraph on the detail page
  final String age; // "0+ mo" - shown as a quick fact + list meta
  final String? ageWarning; // e.g. "8+ months only" - shows the caution pill
  final String frequency; // "2×/day"
  final String prepTime; // "5 min"
  final List<String> ingredients;
  final List<String> steps;
  final String whenToUse;
  final List<String> redFlags; // "when NOT to use - see a doctor"
  final RemedyPanel reviewer;
  final List<RemedyLink> related;
  final RemedySponsor? sponsor;
  final bool hasVideo;
  final String? videoNote; // caption under the demo-video placeholder
  final bool popular;

  /// A gated remedy (age warning present) shows the coral caution pill instead
  /// of the green "Vaidya-approved" pill on list rows and popular rows.
  bool get isCaution => ageWarning != null;

  /// Right-hand pill label on list/popular rows.
  String get pillLabel => ageWarning ?? 'Vaidya-approved';

  /// Right-hand meta on list/popular rows.
  String get rowMeta => ageWarning != null ? 'read cautions' : age;
}

// ---- categories -------------------------------------------------------------

class NuskheCategory {
  const NuskheCategory(this.icon, this.name);
  final IconData icon;
  final String name;
}

const List<NuskheCategory> kNuskheCategories = [
  NuskheCategory(Icons.masks_outlined, 'Cold & cough'),
  NuskheCategory(Icons.thermostat, 'Fever'),
  NuskheCategory(Icons.local_dining_outlined, 'Stomach & colic'),
  NuskheCategory(Icons.child_care_outlined, 'Teething'),
  NuskheCategory(Icons.bedtime_outlined, 'Sleep issues'),
  NuskheCategory(Icons.spa_outlined, 'Skin issues'),
];

IconData nuskheCategoryIcon(String name) =>
    kNuskheCategories.firstWhere((c) => c.name == name, orElse: () => kNuskheCategories.first).icon;

// ---- the catalog ------------------------------------------------------------

const List<Remedy> kRemedies = [
  // ===== Cold & cough ========================================================
  Remedy(
    id: 'ajwain_potli',
    name: 'Ajwain potli for a blocked nose',
    category: 'Cold & cough',
    icon: Icons.eco_outlined,
    oneLine: 'A warm carom-seed compress that eases congestion.',
    description:
        'A warm carom-seed compress that eases congestion and helps a stuffy baby breathe and feed. Preventive and soothing - warmed near the chest and feet, never applied to skin directly.',
    age: '0+ mo',
    frequency: '2×/day',
    prepTime: '5 min',
    ingredients: [
      '2 tbsp ajwain (carom seeds)',
      'A clean, soft muslin cloth',
      'A flat tawa to dry-roast',
    ],
    steps: [
      'Dry-roast the ajwain on a tawa until fragrant, 1-2 minutes.',
      'Tie it into the muslin cloth to make a small potli.',
      "Test the warmth on your own inner wrist first, then rest it near (not on) baby's chest and feet.",
    ],
    whenToUse:
        'At the first signs of a stuffy nose or mild cold, especially before naps and feeds when congestion makes it hardest for baby to settle.',
    redFlags: [
      'Fever above 100.4°F (38°C) in a baby under 3 months.',
      'Fast, laboured, or wheezy breathing.',
      'Never place the hot potli directly on skin - warm only.',
      'Cold lasting beyond 5 days, or a baby refusing feeds.',
    ],
    related: [
      RemedyLink('Shop', 'Buy organic ajwain - 24 Mantra'),
      RemedyLink('Read', 'Baby colds: what actually helps'),
    ],
    sponsor: RemedySponsor('Organic India · whole-seed ajwain', 'Single-origin, lab-tested purity.'),
    hasVideo: true,
    videoNote: 'Watch: rolling and warming the potli safely',
    popular: true,
  ),
  Remedy(
    id: 'mustard_garlic_rub',
    name: 'Mustard-oil & garlic chest rub',
    category: 'Cold & cough',
    icon: Icons.spa_outlined,
    oneLine: 'A warming massage oil that loosens chest congestion.',
    description:
        'The classic dadi chest and back rub - mustard oil gently warmed with garlic and ajwain, massaged onto the chest, back and soles to ease a rattly cold and comfort a fussy baby before sleep.',
    age: '3+ mo',
    frequency: '1-2×/day',
    prepTime: '10 min',
    ingredients: [
      '3 tbsp mustard oil (sarson ka tel)',
      '2 crushed garlic cloves',
      'A pinch of ajwain',
    ],
    steps: [
      'Warm the oil on low heat with the garlic and ajwain until fragrant, then switch off.',
      'Cool it fully to comfortably warm and strain out the solids.',
      'Test on your wrist, then massage a thin film onto the chest, back and soles - keep it away from the face and nostrils.',
    ],
    whenToUse:
        'For a mild chesty cold, best massaged before an evening bath or bedtime so baby settles more easily.',
    redFlags: [
      'Any difficulty breathing, chest indrawing or a bluish tinge - go to a doctor now.',
      'Broken or irritated skin, or a known mustard allergy.',
      'Do not use on a baby under 3 months without a paediatrician\'s okay.',
      'A cough with high fever, or lasting beyond a week.',
    ],
    reviewer: _panelDeshpande,
    related: [
      RemedyLink('Shop', 'Cold-pressed mustard oil'),
      RemedyLink('Read', 'Is baby massage safe during a cold?'),
    ],
    hasVideo: true,
    videoNote: 'Watch: the gentle chest-and-back stroke',
  ),
  Remedy(
    id: 'tulsi_honey',
    name: 'Tulsi & honey for a lingering cough',
    category: 'Cold & cough',
    icon: Icons.local_florist_outlined,
    oneLine: 'A few drops of tulsi-honey to soothe the throat.',
    description:
        'Fresh tulsi (holy basil) juice with a little honey - a time-honoured throat soother for an older baby with a dry, tickly cough. Honey means this one is strictly for over-ones.',
    age: '12+ mo',
    ageWarning: '1 year+ only (honey)',
    frequency: '2×/day',
    prepTime: '5 min',
    ingredients: [
      '6-8 fresh tulsi leaves',
      '½ tsp raw honey',
      'A clean mortar to crush',
    ],
    steps: [
      'Rinse and lightly crush the tulsi leaves to release their juice.',
      'Mix a few drops of the juice into the honey.',
      'Offer half a teaspoon, up to twice a day.',
    ],
    whenToUse:
        'For a dry, lingering throat-tickle cough in a child over one year, especially at bedtime.',
    redFlags: [
      'NEVER give honey to a baby under 12 months - risk of infant botulism.',
      'A wet cough with fast breathing or wheeze.',
      'Fever that will not settle, or a cough lasting beyond 2 weeks.',
      'Any choking, gagging or trouble swallowing.',
    ],
    reviewer: _panelNair,
    related: [
      RemedyLink('Read', 'Why honey is a no under one'),
      RemedyLink('Shop', 'Raw forest honey'),
    ],
  ),
  Remedy(
    id: 'steam_humidity',
    name: 'Warm steam & a humid room',
    category: 'Cold & cough',
    icon: Icons.air,
    oneLine: 'Moist air that thins mucus and eases breathing.',
    description:
        'Not a potion but the most reliable dadi trick of all - sitting with baby in a warm, steamy bathroom, or running a humidifier, so moist air loosens thick mucus and makes a blocked nose easier to clear.',
    age: '0+ mo',
    frequency: 'As needed',
    prepTime: '10 min',
    ingredients: [
      'A bathroom you can fill with steam, or a cool-mist humidifier',
      'Optional: a pinch of ajwain in the hot water (out of reach)',
    ],
    steps: [
      'Run a hot shower with the door shut to steam up the bathroom.',
      'Sit with baby in the warm, moist air for 10-15 minutes - never near the hot water itself.',
      'Afterwards, a saline drop and a gentle nasal-suction clears the loosened mucus.',
    ],
    whenToUse:
        'Any time congestion makes feeding or sleeping hard - it is safe from birth and works within minutes.',
    redFlags: [
      'Keep baby well away from hot water, kettles and steam sources - scald risk.',
      'Laboured or very fast breathing, or ribs pulling in with each breath.',
      'A high fever alongside the cold, especially under 3 months.',
      'No improvement after a few days.',
    ],
    related: [
      RemedyLink('Shop', 'Cool-mist humidifier'),
      RemedyLink('Read', 'Saline drops: the safe decongestant'),
    ],
  ),
  Remedy(
    id: 'turmeric_milk_cold',
    name: 'Golden haldi milk at bedtime',
    category: 'Cold & cough',
    icon: Icons.local_cafe_outlined,
    oneLine: 'Warm milk with a pinch of turmeric to soothe a cold.',
    description:
        'The bedtime haldi-doodh - warm milk with a small pinch of turmeric - a comforting, mildly anti-inflammatory drink for an older baby fighting a cold. For children already on cow\'s milk.',
    age: '12+ mo',
    ageWarning: '1 year+ only',
    frequency: '1×/day',
    prepTime: '8 min',
    ingredients: [
      '1 cup whole milk',
      'A small pinch of turmeric (haldi)',
      'Optional tiny pinch of black pepper',
    ],
    steps: [
      'Warm the milk gently and whisk in the pinch of turmeric.',
      'Simmer 2-3 minutes so the turmeric cooks in, then cool to drinking-warm.',
      'Offer at bedtime, once a day.',
    ],
    whenToUse:
        'A soothing wind-down for a child over one with a mild cold - comforting rather than curative.',
    redFlags: [
      'Not for babies under one, or those not yet on cow\'s milk.',
      'A known milk allergy or lactose intolerance.',
      'High fever, breathing trouble, or a cold that is getting worse.',
      'Turmeric is a food-pinch here - never a large "medicinal" dose.',
    ],
    reviewer: _panelNair,
    related: [
      RemedyLink('Read', 'Haldi doodh: myth vs fact'),
    ],
  ),

  // ===== Fever ===============================================================
  Remedy(
    id: 'lukewarm_sponge',
    name: 'Lukewarm sponging for comfort',
    category: 'Fever',
    icon: Icons.water_drop_outlined,
    oneLine: 'Gentle tepid sponging to help a feverish baby feel better.',
    description:
        'The safest, oldest fever comfort - wiping a warm-but-feverish baby with a lukewarm-water sponge to help them feel cooler and calmer. Comfort care, never a replacement for a doctor\'s advice on the fever itself.',
    age: '0+ mo',
    frequency: 'As needed',
    prepTime: '2 min',
    ingredients: [
      'A bowl of lukewarm (never cold) water',
      'A soft, clean cloth or sponge',
    ],
    steps: [
      'Dip the cloth in lukewarm water and wring it well.',
      'Gently wipe the forehead, neck, armpits and folds - keep the room comfortable, not cold.',
      'Dress baby lightly and offer frequent feeds or fluids.',
    ],
    whenToUse:
        'To keep a mildly feverish baby comfortable while you monitor them - alongside, not instead of, your paediatrician\'s guidance.',
    redFlags: [
      'ANY fever in a baby under 3 months - see a doctor the same day.',
      'Fever above 102°F (39°C), or lasting more than 2-3 days.',
      'Never use cold water, ice or rubbing alcohol - it can cause shivering and harm.',
      'Drowsiness, a rash that will not fade, a stiff neck, or refusing fluids - urgent care.',
    ],
    reviewer: _panelDeshpande,
    related: [
      RemedyLink('Read', 'Fever in babies: when to worry'),
    ],
  ),
  Remedy(
    id: 'dhania_water',
    name: 'Coriander-seed (dhania) water',
    category: 'Fever',
    icon: Icons.grain,
    oneLine: 'A cooling coriander-seed water to sip for hydration.',
    description:
        'A mild, cooling dhania-seed water traditionally offered to keep a feverish older baby hydrated and comfortable. Gentle and hydrating - it supports comfort, it does not treat the fever.',
    age: '8+ mo',
    frequency: '2-3×/day',
    prepTime: '15 min',
    ingredients: [
      '1 tsp coriander seeds (dhania)',
      '1 cup water',
    ],
    steps: [
      'Soak the coriander seeds in a cup of water for a few hours or overnight.',
      'Strain out the seeds; a splash can be diluted in more water.',
      'Offer small, frequent sips (for babies already taking water, 6 months+).',
    ],
    whenToUse:
        'To encourage fluids in a feverish older baby who is off their feeds - hydration is the real goal.',
    redFlags: [
      'Not a substitute for seeing a doctor about the fever itself.',
      'Any fever under 3 months, or a high or persistent fever.',
      'Signs of dehydration - few wet nappies, no tears, a sunken soft spot.',
      'Unusual drowsiness, breathing trouble or a non-fading rash.',
    ],
    reviewer: _panelNair,
    related: [
      RemedyLink('Read', 'Keeping a sick baby hydrated'),
    ],
  ),
  Remedy(
    id: 'chandan_forehead',
    name: 'Cooling sandalwood forehead paste',
    category: 'Fever',
    icon: Icons.spa_outlined,
    oneLine: 'A dab of chandan paste for a cooling, calming feel.',
    description:
        'A thin smear of sandalwood (chandan) paste on the forehead - a traditional cooling comfort for a warm, restless baby. It soothes and calms; it is not a treatment for the fever.',
    age: '6+ mo',
    frequency: 'As needed',
    prepTime: '5 min',
    ingredients: [
      '½ tsp pure sandalwood powder',
      'A few drops of clean water or rose water',
    ],
    steps: [
      'Mix the sandalwood powder with a little water to a smooth, thin paste.',
      'Do a small patch test on the inner arm first.',
      'Dab a thin layer across the forehead; wipe off gently after it dries.',
    ],
    whenToUse:
        'To help a warm, fretful baby feel a little cooler and calmer while you watch the fever and follow medical advice.',
    redFlags: [
      'Comfort only - it does not lower a fever or replace a doctor.',
      'Any redness or reaction - wipe off and stop.',
      'Fever under 3 months, high fever, or fever with a rash, stiff neck or drowsiness.',
      'Only pure sandalwood - never a scented or synthetic "chandan".',
    ],
    related: [
      RemedyLink('Shop', 'Pure sandalwood powder'),
    ],
  ),

  // ===== Stomach & colic =====================================================
  Remedy(
    id: 'hing_paste',
    name: 'Hing (asafoetida) tummy rub',
    category: 'Stomach & colic',
    icon: Icons.local_dining_outlined,
    oneLine: 'A warm hing paste around the navel to ease trapped gas.',
    description:
        'The go-to dadi remedy for a gassy, colicky baby - a little hing mixed with warm water or oil, dabbed around (never in) the navel to help release trapped wind and settle a crying tummy.',
    age: '1+ mo',
    frequency: 'As needed',
    prepTime: '3 min',
    ingredients: [
      'A small pinch of good-quality hing (asafoetida)',
      '1 tsp warm water, or a little warm oil',
    ],
    steps: [
      'Mix the pinch of hing into the warm water or oil to a runny paste.',
      'Test the warmth on your wrist.',
      'Dab a thin ring around the navel (never inside it) and rub the tummy softly, clockwise.',
    ],
    whenToUse:
        'When a baby is drawing up their legs and crying with obvious trapped gas, especially in the evening colic hours.',
    redFlags: [
      'Never put hing inside the navel or let baby ingest it.',
      'A hard, swollen, tender belly, or forceful/green vomiting.',
      'Blood in the stool, or no wet nappies.',
      'A fever alongside the tummy pain, or inconsolable crying for hours.',
    ],
    reviewer: _panelDeshpande,
    related: [
      RemedyLink('Read', 'Colic: what helps and what doesn\'t'),
      RemedyLink('Shop', 'Compounded hing (heeng)'),
    ],
    hasVideo: true,
    videoNote: 'Watch: the clockwise anti-gas tummy rub',
    popular: true,
  ),
  Remedy(
    id: 'tummy_massage_bicycle',
    name: 'Tummy massage & bicycle legs',
    category: 'Stomach & colic',
    icon: Icons.self_improvement,
    oneLine: 'Gentle massage and leg-cycling to move trapped wind.',
    description:
        'No ingredients, just hands - a soft clockwise tummy massage followed by gently cycling baby\'s legs, the most effective and doctor-endorsed way to move trapped gas and ease colic discomfort.',
    age: '0+ mo',
    frequency: 'As needed',
    prepTime: '5 min',
    ingredients: [
      'Warm hands (a drop of baby-safe oil is optional)',
      'A calm, warm surface to lay baby on',
    ],
    steps: [
      'Lay baby on their back and rub your palms warm.',
      'Massage the tummy in slow, clockwise circles around the navel.',
      'Then hold the ankles and gently "cycle" the legs, and press both knees softly up towards the tummy.',
    ],
    whenToUse:
        'During evening colic or any time baby seems bloated and unsettled - lovely after a warm bath, before a feed rather than straight after.',
    redFlags: [
      'Stop if baby seems in real pain rather than gassy discomfort.',
      'A tense, swollen or tender belly, or vomiting.',
      'Do not massage straight after a full feed.',
      'Persistent inconsolable crying, blood in stool, or fever - see a doctor.',
    ],
    related: [
      RemedyLink('Read', 'The 5-minute anti-colic routine'),
    ],
    hasVideo: true,
    videoNote: 'Watch: massage and the bicycle stretch',
  ),
  Remedy(
    id: 'saunf_water',
    name: 'Saunf (fennel) water for wind',
    category: 'Stomach & colic',
    icon: Icons.grass,
    oneLine: 'A mild fennel-seed water traditionally used to settle gas.',
    description:
        'A weak, cooled fennel-seed water - a gentle traditional carminative for a windy older baby. Best kept very mild and occasional; for younger, breastfed babies, the fennel is better taken by the nursing mother.',
    age: '6+ mo',
    ageWarning: '6+ months only',
    frequency: '1×/day',
    prepTime: '15 min',
    ingredients: [
      '½ tsp fennel seeds (saunf)',
      '1 cup water',
    ],
    steps: [
      'Boil the fennel seeds in the water for a few minutes, then switch off.',
      'Let it steep and cool fully, then strain.',
      'Offer just a teaspoon or two (only for babies already on water, 6 months+).',
    ],
    whenToUse:
        'An occasional settler for a gassy older baby - for young breastfed babies, the nursing mother can take fennel instead.',
    redFlags: [
      'No water at all (including "gripe" waters) for babies under 6 months.',
      'A swollen, tender belly, vomiting, or blood in the stool.',
      'Never make it strong or give it in large amounts.',
      'Ongoing tummy trouble or poor weight gain - see a doctor.',
    ],
    reviewer: _panelNair,
    related: [
      RemedyLink('Read', 'Gripe water: is it safe?'),
    ],
  ),
  Remedy(
    id: 'ajwain_water_digest',
    name: 'Mild ajwain water for digestion',
    category: 'Stomach & colic',
    icon: Icons.eco_outlined,
    oneLine: 'A very dilute carom-seed water to ease a heavy tummy.',
    description:
        'A weak ajwain water traditionally offered to an older baby with a sluggish, gassy tummy. Kept very mild - warming and digestive without being strong.',
    age: '8+ mo',
    ageWarning: '8+ months only',
    frequency: '1×/day',
    prepTime: '15 min',
    ingredients: [
      '¼ tsp ajwain (carom seeds)',
      '1 cup water',
    ],
    steps: [
      'Boil the ajwain in the water for 2-3 minutes.',
      'Cool fully and strain thoroughly.',
      'Offer a teaspoon or two for an older baby already on solids and water.',
    ],
    whenToUse:
        'Occasionally, for an older baby whose tummy seems heavy or gassy after new foods.',
    redFlags: [
      'Not for young babies - only from 8 months, and always very dilute.',
      'Vomiting, a hard swollen belly, or blood in the stool.',
      'Diarrhoea or signs of dehydration.',
      'Any ongoing feeding or tummy problem - check with a doctor.',
    ],
    reviewer: _panelDeshpande,
    related: [
      RemedyLink('Shop', 'Organic ajwain'),
    ],
  ),

  // ===== Teething ============================================================
  Remedy(
    id: 'chilled_spoon',
    name: 'A chilled (not frozen) spoon',
    category: 'Teething',
    icon: Icons.ac_unit,
    oneLine: 'Something cool and firm to press on sore gums.',
    description:
        'The simplest teething comfort - a clean metal spoon or teether cooled in the fridge (never the freezer) for baby to press and gum. The gentle cold numbs sore gums beautifully.',
    age: '4+ mo',
    frequency: 'As needed',
    prepTime: '30 min',
    ingredients: [
      'A clean metal spoon or a solid silicone teether',
      'A fridge (not the freezer)',
    ],
    steps: [
      'Chill the spoon or teether in the fridge for 20-30 minutes.',
      'Check it is cool, not icy - a frozen surface can hurt delicate gums.',
      'Let baby gum the rounded back of the spoon under your watch.',
    ],
    whenToUse:
        'Any time gums look sore and baby is chewing on everything - lovely just before a feed when sore gums make latching fussy.',
    redFlags: [
      'Never use a frozen or ice-hard object - it can bruise the gums.',
      'Teething does NOT cause high fever or diarrhoea - suspect illness and see a doctor.',
      'Skip amber "teething necklaces" - strangulation and choking risk.',
      'No teething gels with benzocaine or hidden ingredients.',
    ],
    related: [
      RemedyLink('Shop', 'Solid silicone teether'),
      RemedyLink('Read', 'Teething: signs vs illness'),
    ],
  ),
  Remedy(
    id: 'gum_massage',
    name: 'Clean-finger gum massage',
    category: 'Teething',
    icon: Icons.back_hand_outlined,
    oneLine: 'A gentle rub with a clean finger to soothe the gums.',
    description:
        'Dadi\'s free remedy - a clean, gentle fingertip rubbed firmly over baby\'s sore gums. The counter-pressure eases the ache of a tooth pushing through, and the closeness soothes.',
    age: '3+ mo',
    frequency: 'As needed',
    prepTime: '2 min',
    ingredients: [
      'Clean, well-washed hands',
      'Optional: a clean, damp gauze pad',
    ],
    steps: [
      'Wash your hands thoroughly.',
      'Rub a clean fingertip, firmly and gently, back and forth over the sore gum.',
      'A cool, damp gauze pad wrapped on the finger adds soothing texture.',
    ],
    whenToUse:
        'Whenever gums look tender and baby wants to chew - a calming few minutes on your lap.',
    redFlags: [
      'Keep nails short and hands spotless to avoid scratches or infection.',
      'High fever, diarrhoea or vomiting are NOT from teething - see a doctor.',
      'Bleeding, pus or a swollen, angry gum.',
      'Refusing all feeds for a prolonged spell.',
    ],
    related: [
      RemedyLink('Read', 'Soothing sore gums, drug-free'),
    ],
    hasVideo: true,
    videoNote: 'Watch: the gentle gum-massage technique',
  ),
  Remedy(
    id: 'cool_washcloth',
    name: 'A cool, damp washcloth to chew',
    category: 'Teething',
    icon: Icons.dry_cleaning_outlined,
    oneLine: 'A chilled clean cloth gives sore gums something to work on.',
    description:
        'A clean cotton washcloth, dampened and chilled, twisted so baby can grip and gum one end. The cool texture soothes, and the chewing satisfies the urge to bite down.',
    age: '4+ mo',
    frequency: 'As needed',
    prepTime: '20 min',
    ingredients: [
      'A clean cotton washcloth or muslin',
      'Cool (not freezing) water',
    ],
    steps: [
      'Dampen one end of a clean washcloth with cool water and wring it out.',
      'Chill it briefly in the fridge, then check it is cool, not icy.',
      'Hand baby the firm end to gnaw on, always supervised.',
    ],
    whenToUse:
        'During the peak drooly, chewy stage - especially handy out and about.',
    redFlags: [
      'Always supervise - a wet cloth is a choking/suffocation risk if left alone.',
      'Use it once, then wash it - never a stale, damp cloth.',
      'A real fever, loose stools or a poorly baby means it is not just teething.',
      'Any swelling, bleeding or refusal to feed.',
    ],
    related: [
      RemedyLink('Shop', 'Organic-cotton muslin cloths'),
    ],
  ),

  // ===== Sleep issues ========================================================
  Remedy(
    id: 'bedtime_oil_massage',
    name: 'Bedtime oil massage (abhyanga)',
    category: 'Sleep issues',
    icon: Icons.spa_outlined,
    oneLine: 'A warm, calming massage that helps baby settle to sleep.',
    description:
        'The heart of the Indian bedtime - a slow, warm oil massage (abhyanga) before the evening bath. The rhythm and touch calm the nervous system and help a fussy baby fall into deeper, longer sleep.',
    age: '0+ mo',
    frequency: '1×/day',
    prepTime: '10 min',
    ingredients: [
      '2-3 tbsp baby-safe oil (coconut, or a mild sesame in winter)',
      'A warm room and warm hands',
    ],
    steps: [
      'Warm the oil to body temperature and rub your palms together.',
      'Massage with slow, firm-gentle strokes - arms and legs outward, tummy clockwise, back last.',
      'Follow with a warm bath and a feed to complete the wind-down.',
    ],
    whenToUse:
        'As a nightly ritual before bath and bed - the predictability is half the magic.',
    redFlags: [
      'Skip broken, irritated or eczema-flared skin, or patch-test a new oil first.',
      'Never massage straight after a full feed.',
      'A baby who is unwell, feverish or unusually floppy needs rest, not massage.',
      'Persistent, extreme sleeplessness or breathing pauses in sleep - see a doctor.',
    ],
    reviewer: _panelNair,
    related: [
      RemedyLink('Shop', 'Cold-pressed baby coconut oil'),
      RemedyLink('Read', 'The science of baby massage & sleep'),
    ],
    hasVideo: true,
    videoNote: 'Watch: the full bedtime massage sequence',
    popular: true,
  ),
  Remedy(
    id: 'jaiphal_pinch',
    name: 'Nutmeg (jaiphal) for restful sleep',
    category: 'Sleep issues',
    icon: Icons.nightlight_outlined,
    oneLine: 'A trace of jaiphal, traditionally used to calm before sleep.',
    description:
        'A whisper of nutmeg (jaiphal) is a classic dadi sleep aid - but it is potent, so this one carries firm limits: a barely-there trace, only for an older baby, and only occasionally. When in doubt, skip it and lean on the massage instead.',
    age: '8+ mo',
    ageWarning: '8+ months only · use sparingly',
    frequency: 'Occasional',
    prepTime: '5 min',
    ingredients: [
      'A whole jaiphal (nutmeg) and a fine stone/grater',
      'A teaspoon of warm milk (for a child already on cow\'s milk) or expressed feed',
    ],
    steps: [
      'Rub the nutmeg on a stone with a drop of water to get a barely-visible trace.',
      'Mix that trace into a teaspoon of warm milk or feed.',
      'Offer occasionally at bedtime - never daily, never more than a trace.',
    ],
    whenToUse:
        'Very occasionally, for an older baby who is unusually restless at night - always as a tiny trace, not a spoonful.',
    redFlags: [
      'Nutmeg is toxic in excess - more than a trace can cause serious harm. When unsure, do not use it.',
      'Not for babies under 8 months, and never daily.',
      'Any drowsiness, vomiting, a racing heart or unusual behaviour - stop and seek care.',
      'Ongoing sleep problems are better solved by routine than by jaiphal.',
    ],
    reviewer: _panelDeshpande,
    related: [
      RemedyLink('Read', 'Nutmeg for babies: the honest limits'),
    ],
    popular: true,
  ),
  Remedy(
    id: 'winddown_bath',
    name: 'A warm wind-down bath & routine',
    category: 'Sleep issues',
    icon: Icons.bedtime_outlined,
    oneLine: 'A calm, dim, repeatable routine that cues sleep.',
    description:
        'Less a nuskha, more the wisdom behind them all - a warm bath, dim lights and the same gentle steps each night, so baby\'s body learns that sleep is coming. The single most effective "remedy" for restless nights.',
    age: '0+ mo',
    frequency: 'Nightly',
    prepTime: '20 min',
    ingredients: [
      'A warm (not hot) bath',
      'Dim lights and a quiet room',
    ],
    steps: [
      'Keep the same short sequence nightly - bath, massage, feed, a soft lullaby.',
      'Dim the lights and lower your voice as you go.',
      'Put baby down drowsy-but-awake in the same safe sleep space.',
    ],
    whenToUse:
        'Every night - the repetition is what teaches a baby\'s body to wind down.',
    redFlags: [
      'Always follow safe-sleep basics - firm flat surface, on the back, no loose bedding.',
      'Never leave a baby unattended in the bath, even for a second.',
      'Breathing pauses, snoring/gasping in sleep, or extreme unsettledness - see a doctor.',
      'Sudden night-waking with fever or pain is illness, not a sleep phase.',
    ],
    related: [
      RemedyLink('Read', 'Building a baby bedtime routine'),
    ],
  ),

  // ===== Skin issues =========================================================
  Remedy(
    id: 'coconut_moisturise',
    name: 'Coconut oil for dry skin',
    category: 'Skin issues',
    icon: Icons.water_drop_outlined,
    oneLine: 'A light coconut-oil massage to soften dry baby skin.',
    description:
        'The gentlest everyday moisturiser - a thin film of pure coconut oil smoothed onto clean, slightly damp skin to soften dry patches and keep baby\'s skin barrier soft and supple.',
    age: '0+ mo',
    frequency: '1-2×/day',
    prepTime: '3 min',
    ingredients: [
      'Pure, cold-pressed coconut oil',
      'Clean hands',
    ],
    steps: [
      'Warm a little oil between your palms.',
      'Smooth a thin layer onto clean, slightly damp skin, especially the dry spots.',
      'A little goes a long way - avoid the face if baby is prone to breakouts.',
    ],
    whenToUse:
        'After a bath while skin is still damp, or any time you notice dry, flaky patches.',
    redFlags: [
      'Angry, weeping, cracked or infected-looking skin needs a doctor, not oil.',
      'A spreading rash, blisters, or a rash with fever.',
      'A known coconut allergy - patch-test anything new.',
      'Eczema that is not settling with gentle care.',
    ],
    related: [
      RemedyLink('Shop', 'Cold-pressed baby coconut oil'),
      RemedyLink('Read', 'Caring for newborn skin'),
    ],
    sponsor: RemedySponsor('Coco Soul · virgin coconut oil', 'Cold-pressed, nothing added.'),
  ),
  Remedy(
    id: 'oatmeal_pricklyheat',
    name: 'Oatmeal bath for prickly heat',
    category: 'Skin issues',
    icon: Icons.grass,
    oneLine: 'A soothing oatmeal soak to calm heat-rash itchiness.',
    description:
        'A monsoon and summer saviour - finely ground oats swirled into a lukewarm bath to calm the itch and sting of prickly heat (ghamoriyan) and leave hot, bumpy skin feeling soothed.',
    age: '3+ mo',
    frequency: '1×/day',
    prepTime: '10 min',
    ingredients: [
      '2-3 tbsp plain oats, finely ground (colloidal-style)',
      'A lukewarm bath',
    ],
    steps: [
      'Blitz plain oats to a fine powder.',
      'Stir the powder into a lukewarm (not hot) bath until the water looks milky.',
      'Let baby soak 5-10 minutes, then pat - do not rub - dry and dress in loose cotton.',
    ],
    whenToUse:
        'In hot, humid weather when prickly heat flares - keeping baby cool and in loose cotton prevents it best.',
    redFlags: [
      'A rash with fever, blisters, pus or fast spreading is not prickly heat - see a doctor.',
      'Broken or raw skin.',
      'A known oat/gluten sensitivity - patch-test first.',
      'Itchy rash that keeps returning or won\'t settle.',
    ],
    reviewer: _panelNair,
    related: [
      RemedyLink('Read', 'Beating prickly heat in babies'),
      RemedyLink('Shop', 'Colloidal oatmeal soak'),
    ],
  ),
  Remedy(
    id: 'coconut_cradlecap',
    name: 'Coconut oil for cradle cap',
    category: 'Skin issues',
    icon: Icons.spa_outlined,
    oneLine: 'Softening those flaky scalp patches gently, overnight.',
    description:
        'The kind way to loosen cradle cap - a little coconut oil massaged into the flaky scalp, left to soften the scales, then gently combed and washed away. Patience, never picking.',
    age: '0+ mo',
    frequency: 'Few times a week',
    prepTime: '5 min',
    ingredients: [
      'Pure coconut oil',
      'A soft baby brush or fine comb',
    ],
    steps: [
      'Massage a little oil into the scaly scalp and leave 15-20 minutes (or overnight).',
      'Gently loosen the softened flakes with a soft brush - never pick or scratch.',
      'Wash with a mild baby shampoo to rinse the oil and flakes away.',
    ],
    whenToUse:
        'For the harmless yellowish scalp scales of cradle cap - gentle and repeated over days, not forced.',
    redFlags: [
      'Never pick or scratch - it can break the skin and invite infection.',
      'Redness spreading beyond the scalp, weeping, swelling or a bad smell.',
      'Cradle cap that spreads to the face and body, or an itchy, distressed baby.',
      'Anything that looks infected or is not improving - see a doctor.',
    ],
    related: [
      RemedyLink('Read', 'Cradle cap: gentle care that works'),
    ],
  ),
  Remedy(
    id: 'besan_ubtan',
    name: 'Gentle besan ubtan for a cleansing rub',
    category: 'Skin issues',
    icon: Icons.face_retouching_natural,
    oneLine: 'A mild traditional ubtan for the weekly bath - kept soft.',
    description:
        'The traditional pre-bath ubtan - a soft, mild paste of besan (gram flour) used as an occasional gentle cleanser. Kept smooth and used lightly so it soothes rather than scrubs delicate skin.',
    age: '3+ mo',
    ageWarning: 'Skip on sensitive/eczema skin',
    frequency: '1-2×/week',
    prepTime: '5 min',
    ingredients: [
      '1 tbsp besan (gram flour)',
      'A little milk or water (and a drop of oil) to soften',
    ],
    steps: [
      'Mix the besan with enough milk/water to a soft, smooth, lump-free paste.',
      'Patch-test on the arm, then smooth on very gently - never scrub.',
      'Rinse off completely with lukewarm water and moisturise after.',
    ],
    whenToUse:
        'An occasional, gentle weekly cleanse for healthy skin - not for daily use and not on delicate faces if baby is prone to dryness.',
    redFlags: [
      'Skip entirely on eczema, rashes, broken or very sensitive skin.',
      'Any redness or irritation - rinse off and stop.',
      'Never rub hard or use it as a "fairness" treatment - that is a harmful myth.',
      'A rash that appears or worsens - check with a doctor.',
    ],
    reviewer: _panelDeshpande,
    related: [
      RemedyLink('Read', 'Ubtan for babies: gentle, or skip?'),
    ],
  ),
];

// ---- queries ----------------------------------------------------------------

/// A safe fallback used by the zero-arg detail route (and anywhere a remedy is
/// missing) - the signature ajwain-potli remedy.
Remedy get fallbackRemedy => kRemedies.first;

Remedy? remedyById(String id) {
  for (final r in kRemedies) {
    if (r.id == id) return r;
  }
  return null;
}

List<Remedy> remediesByCategory(String category) =>
    kRemedies.where((r) => r.category == category).toList();

int remedyCount(String category) => remediesByCategory(category).length;

List<Remedy> get popularRemedies => kRemedies.where((r) => r.popular).toList();

/// Filter by name, category or one-line (used by the landing search box).
List<Remedy> searchRemedies(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return kRemedies.where((r) {
    return r.name.toLowerCase().contains(q) ||
        r.category.toLowerCase().contains(q) ||
        r.oneLine.toLowerCase().contains(q);
  }).toList();
}
