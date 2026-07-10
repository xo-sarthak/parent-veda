// =============================================================================
//  ParentVeda Recommendations - the intelligent discovery engine
// -----------------------------------------------------------------------------
//  NOT a catalogue or a feed. A curated engine that answers "what is genuinely
//  worth my time for my child today?". Every item carries the ParentVeda take
//  (why we recommend it + what to consider), an age window, the skills it
//  supports and cross-links into the rest of the app. The engine builds a live
//  personalisation context from the child's age + current leap and from what the
//  parent has already saved/watched/read/compared, scores items by age-fit +
//  stage-fit + interest overlap, diversifies by category, and explains WHY each
//  recommendation appears. In-memory; a real ML layer slots in behind the same
//  API later. Nothing here depends on the pregnancy app.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_development_data.dart';
import 'pp_leaps_data.dart';
import 'pp_products_data.dart';
import 'pp_reading_data.dart';
import 'pp_watch_data.dart';

// ---- categories -------------------------------------------------------------
const List<(String, IconData)> kRecoCategories = [
  ('Books', Icons.menu_book_outlined),
  ('Activities', Icons.extension_outlined),
  ('Toys', Icons.toys_outlined),
  ('Videos', Icons.play_circle_outline),
  ('Music', Icons.music_note_outlined),
  ('Outdoor', Icons.park_outlined),
  ('Experiences', Icons.auto_awesome_outlined),
  ('Products', Icons.shopping_bag_outlined),
  ('Parent Picks', Icons.favorite_border),
  ('Events', Icons.celebration_outlined),
  ('Travel', Icons.luggage_outlined),
  ('Restaurants', Icons.restaurant_outlined),
  ('Birthday Ideas', Icons.cake_outlined),
  ('Learning', Icons.school_outlined),
];

IconData recoCatIcon(String category) =>
    kRecoCategories.firstWhere((c) => c.$1 == category, orElse: () => kRecoCategories.first).$2;

// ---- item model -------------------------------------------------------------
class RecoItem {
  const RecoItem({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.ageMin,
    required this.ageMax,
    required this.why,
    required this.consider,
    required this.bestFor,
    required this.skills,
    required this.benefits,
    required this.pvRating,
    required this.communityLoves,
    required this.seed,
    this.indian = false,
    this.price,
    this.collections = const [],
    this.tags = const [],
    this.relatedArticleId,
    this.relatedVideoId,
    this.relatedProductId,
    this.relatedActivityId,
  });

  final String id;
  final String category; // one of kRecoCategories names
  final String title;
  final String summary; // one-line
  final int ageMin; // months
  final int ageMax; // months
  final String why; // "Why ParentVeda recommends it"
  final String consider; // "Things to consider"
  final String bestFor;
  final List<String> skills; // skills supported
  final List<String> benefits; // development benefits
  final double pvRating; // 0..5
  final int communityLoves; // saves within the community (a soft signal)
  final int seed; // placeholder imagery + deterministic tiebreak
  final bool indian; // a "hidden Indian gem"
  final String? price;
  final List<String> collections; // smart-collection ids this belongs to
  final List<String> tags; // search + relevance keywords
  final String? relatedArticleId; // ReadArticle id
  final String? relatedVideoId; // WatchVideo id
  final String? relatedProductId; // PpProduct id
  final String? relatedActivityId; // DevActivity id

  String get ageLabel {
    String m(int x) => x >= 12 ? '${(x / 12).toStringAsFixed(x % 12 == 0 ? 0 : 1)}y' : '${x}m';
    return '${m(ageMin)}–${m(ageMax)}';
  }

  /// Everything searchable, lowercased.
  String get haystack => '$title $summary $category ${tags.join(' ')} ${skills.join(' ')} ${collections.join(' ')} $bestFor'.toLowerCase();
}

// ---- smart collections ------------------------------------------------------
class RecoCollection {
  const RecoCollection(this.id, this.title, this.subtitle, this.icon);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  List<RecoItem> get items => kReco.where((r) => r.collections.contains(id)).toList();
}

const List<RecoCollection> kRecoCollections = [
  RecoCollection('emotions', 'Books About Emotions', 'Naming big feelings, gently.', Icons.favorite_border),
  RecoCollection('sensory', 'Sensory Play Collection', 'Textures, sounds and light to explore.', Icons.blur_on_rounded),
  RecoCollection('rainyday', 'Rainy Day Activities', 'Cosy indoor ideas for grey days.', Icons.umbrella_outlined),
  RecoCollection('weekend', 'Weekend Family Ideas', 'Make the two days count, together.', Icons.weekend_outlined),
  RecoCollection('openended', 'Open-Ended Toys', 'Play with no single right answer.', Icons.extension_outlined),
  RecoCollection('firstbday', 'First Birthday Ideas', 'A gentle, meaningful first celebration.', Icons.cake_outlined),
  RecoCollection('travel', 'Travel Essentials', 'What actually helps on the go.', Icons.luggage_outlined),
  RecoCollection('indianbooks', 'Indian Story Books', 'Our own tales, our own faces.', Icons.auto_stories_outlined),
  RecoCollection('montessori', 'Montessori Picks', 'Simple, real, child-led.', Icons.spa_outlined),
  RecoCollection('music', 'Music & Rhymes', 'The songs that soothe and teach.', Icons.music_note_outlined),
];

RecoCollection recoCollectionById(String id) =>
    kRecoCollections.firstWhere((c) => c.id == id, orElse: () => kRecoCollections.first);

// =============================================================================
//  Catalogue - curated, not exhaustive. Weighted for the 0-2y window (Aarav is
//  ~4 months) but spanning ages so the engine has range. Warm ParentVeda voice.
// =============================================================================
const List<RecoItem> kReco = [
  // ---- Books ----------------------------------------------------------------
  RecoItem(
    id: 'bk_contrast', category: 'Books', title: 'Black, White & Red Baby Book', summary: 'Bold high-contrast art made for new eyes.',
    ageMin: 0, ageMax: 6, seed: 1, pvRating: 4.8, communityLoves: 2140, indian: false, price: '₹349',
    why: 'At this age a baby sees bold contrast far more clearly than soft colour. These pages give his developing eyes something they can actually lock onto - and every focused gaze is visual attention being built.',
    consider: 'The fascination fades once colour vision matures (around 5-6 months), so enjoy it now rather than saving it.',
    bestFor: 'The first few months of focused looking.',
    skills: ['Visual attention', 'Focus'], benefits: ['Visual tracking', 'Early attention'],
    collections: ['sensory', 'montessori'], tags: ['high contrast', 'newborn', 'visual', 'board book'],
    relatedActivityId: 'highcontrast', relatedVideoId: 'q_play',
  ),
  RecoItem(
    id: 'bk_cloth', category: 'Books', title: 'Cloth Crinkle Book', summary: 'Soft, washable, crinkly - and safe to chew.',
    ageMin: 2, ageMax: 10, seed: 2, pvRating: 4.6, communityLoves: 1680, price: '₹249',
    why: 'Sound and texture in one, with nothing to tear or hurt little gums. As he mouths and crinkles it, he is joining cause (his hand) to effect (the sound) - the heart of what he is learning now.',
    consider: 'It is more a sensory toy than a story - pair it with a picture book for language.',
    bestFor: 'Tummy time and teething days.',
    skills: ['Cause & effect', 'Sensory exploration'], benefits: ['Fine motor', 'Auditory play'],
    collections: ['sensory'], tags: ['cloth', 'crinkle', 'teething', 'tummy time'],
    relatedActivityId: 'texture',
  ),
  RecoItem(
    id: 'bk_indianfaces', category: 'Books', title: 'Peekaboo Baby - Indian Faces', summary: 'Familiar faces and a mirror page.',
    ageMin: 3, ageMax: 12, seed: 3, pvRating: 4.9, communityLoves: 2610, indian: true, price: '₹399',
    why: 'Babies are wired to love faces, and seeing faces like his own - and his own, in the mirror - is powerful. The lift-the-flap peekaboo plants the very first seed of object permanence.',
    consider: 'Flaps need supervising until he is past the "everything in the mouth" stage.',
    bestFor: 'The dawn of peekaboo games.',
    skills: ['Object permanence', 'Social connection'], benefits: ['Social wiring', 'Self-recognition'],
    collections: ['indianbooks', 'sensory'], tags: ['peekaboo', 'mirror', 'faces', 'indian', 'flap'],
    relatedActivityId: 'peekaboo', relatedArticleId: 'leap4',
  ),
  RecoItem(
    id: 'bk_emotions', category: 'Books', title: 'How Are You Feeling Today?', summary: 'Everyday emotions in simple pictures.',
    ageMin: 18, ageMax: 48, seed: 4, pvRating: 4.7, communityLoves: 1420, indian: true,
    why: 'A picture book that introduces emotions through simple, everyday situations - particularly valuable for toddlers beginning to identify and express feelings, long before they have the words.',
    consider: 'The story moves slowly and is better appreciated after two years of age.',
    bestFor: 'Toddlers learning to name big feelings.',
    skills: ['Emotional literacy', 'Language'], benefits: ['Self-expression', 'Empathy'],
    collections: ['emotions', 'indianbooks'], tags: ['emotions', 'feelings', 'toddler'],
    relatedArticleId: 'tantrums',
  ),

  // ---- Activities -----------------------------------------------------------
  RecoItem(
    id: 'ac_peekaboo', category: 'Activities', title: 'Peekaboo, slow and silly', summary: 'The classic game, with a purpose.',
    ageMin: 3, ageMax: 12, seed: 5, pvRating: 4.9, communityLoves: 3010,
    why: 'Behind the giggles, peekaboo is teaching him that things (and you) still exist when out of sight - the foundation of object permanence and a secure sense that you always come back.',
    consider: 'Follow his lead on pace; too fast and it overwhelms rather than delights.',
    bestFor: 'Right now - it is a Leap 4 favourite.',
    skills: ['Object permanence', 'Cause & effect', 'Social connection'], benefits: ['Cognitive', 'Bonding'],
    collections: ['rainyday'], tags: ['peekaboo', 'game', 'indoor', 'free', 'rainy'],
    relatedActivityId: 'peekaboo',
  ),
  RecoItem(
    id: 'ac_tummy', category: 'Activities', title: 'Tummy-time mirror play', summary: 'Build strength, one happy minute at a time.',
    ageMin: 0, ageMax: 8, seed: 6, pvRating: 4.7, communityLoves: 2280,
    why: 'A mirror gives him a reason to lift and hold his head - building the neck and core strength every future movement, from rolling to sitting, depends on.',
    consider: 'Keep sessions short and stop before the grumbles; ending happy makes the next one easier.',
    bestFor: 'Daily floor time.',
    skills: ['Neck & core strength', 'Visual tracking'], benefits: ['Gross motor'],
    collections: ['montessori'], tags: ['tummy time', 'motor', 'mirror', 'floor'],
    relatedActivityId: 'tummy_play', relatedVideoId: 'tummytime',
  ),
  RecoItem(
    id: 'ac_sensorybin', category: 'Activities', title: 'A little texture basket', summary: 'A few safe things that feel different.',
    ageMin: 3, ageMax: 18, seed: 7, pvRating: 4.6, communityLoves: 1560,
    why: 'Offering silk, a wooden spoon and a crinkly cloth feeds his senses and builds the neural pathways curiosity and creativity grow from - no toy required.',
    consider: 'Everything must be larger than his mouth, and it needs close supervision.',
    bestFor: 'Rainy afternoons at home.',
    skills: ['Sensory exploration', 'Fine motor'], benefits: ['Curiosity', 'Tactile learning'],
    collections: ['sensory', 'rainyday', 'montessori'], tags: ['sensory', 'texture', 'rainy', 'indoor', 'free'],
    relatedActivityId: 'texture',
  ),

  // ---- Toys -----------------------------------------------------------------
  RecoItem(
    id: 'ty_ring', category: 'Toys', title: 'Wooden grasping ring', summary: 'Light, simple, endlessly reachable.',
    ageMin: 3, ageMax: 12, seed: 8, pvRating: 4.8, communityLoves: 1990, indian: true, price: '₹299',
    why: 'A plain, light ring is exactly what a reaching baby needs - easy to grasp, safe to mouth, and open-ended. He decides what it is, which is where real play begins.',
    consider: 'Choose untreated or food-safe finished wood, since it will spend a lot of time in his mouth.',
    bestFor: 'The reach-and-grasp stage.',
    skills: ['Reaching', 'Grasp', 'Hand-eye coordination'], benefits: ['Fine motor'],
    collections: ['openended', 'montessori'], tags: ['wooden', 'grasp', 'teether', 'open-ended', 'indian'],
    relatedActivityId: 'reach_ring', relatedProductId: 'dozy',
  ),
  RecoItem(
    id: 'ty_stacker', category: 'Toys', title: 'Open-ended stacking cups', summary: 'Stack, nest, pour, hide - for years.',
    ageMin: 6, ageMax: 36, seed: 9, pvRating: 4.9, communityLoves: 2740,
    why: 'Few toys last as long or teach as much: nesting, stacking, sorting, pouring in the bath, hiding a small toy underneath. Open-ended play like this grows with him.',
    consider: 'Not much use before he can sit and grasp well (around 6 months).',
    bestFor: 'From six months to the toddler years.',
    skills: ['Problem solving', 'Sequences', 'Fine motor'], benefits: ['Cognitive', 'Cause & effect'],
    collections: ['openended', 'montessori'], tags: ['stacking', 'cups', 'open-ended', 'bath'],
  ),
  RecoItem(
    id: 'ty_highcontrast', category: 'Toys', title: 'High-contrast soft rattle', summary: 'Bold patterns plus a gentle sound.',
    ageMin: 0, ageMax: 6, seed: 10, pvRating: 4.5, communityLoves: 1240, price: '₹329',
    why: 'Bold black-white-red patterns hold his gaze while the soft rattle rewards the first swipes of his hand - pairing visual attention with early cause and effect.',
    consider: 'He will not truly grasp it for a few weeks yet; for now it is mostly to look at.',
    bestFor: 'The newborn months.',
    skills: ['Visual attention', 'Cause & effect'], benefits: ['Visual', 'Auditory'],
    collections: ['sensory'], tags: ['rattle', 'high contrast', 'newborn'],
    relatedActivityId: 'highcontrast',
  ),

  // ---- Videos (for parents / stage-appropriate) -----------------------------
  RecoItem(
    id: 'vd_leap4', category: 'Videos', title: 'Inside Leap 4: the world of events', summary: 'What the fussiness really means.',
    ageMin: 3, ageMax: 6, seed: 11, pvRating: 4.9, communityLoves: 3320,
    why: 'A short, calming watch for YOU, not him - it explains exactly what his brain is working out right now, so the clingy days feel like a leap forward instead of a step back.',
    consider: 'This is parent viewing; at 4 months, screens are not for him yet.',
    bestFor: 'Parents in the thick of the 4-month wobble.',
    skills: ['Understanding development'], benefits: ['Parent confidence'],
    collections: [], tags: ['leap', 'brain', 'parent', 'development'],
    relatedVideoId: 'leap4brain', relatedArticleId: 'leap4',
  ),
  RecoItem(
    id: 'vd_sleep', category: 'Videos', title: 'The 4-month sleep shift, explained', summary: 'Why nights change - and what helps.',
    ageMin: 3, ageMax: 6, seed: 12, pvRating: 4.8, communityLoves: 2900,
    why: 'Dr Ananya walks through what is happening in his sleep and the gentle, no-cry changes that actually help - the difference between panic and patience at 2am.',
    consider: 'Guidance, not a quick fix; sleep matures on its own timeline.',
    bestFor: 'The regression weeks.',
    skills: ['Understanding development'], benefits: ['Parent confidence'],
    collections: [], tags: ['sleep', 'regression', 'parent'],
    relatedVideoId: 'sleep4mo', relatedArticleId: 'sleepcycles', relatedProductId: 'dozy',
  ),

  // ---- Music ----------------------------------------------------------------
  RecoItem(
    id: 'mu_lullabies', category: 'Music', title: 'Gentle Indian lullabies', summary: 'The songs grandmothers have always sung.',
    ageMin: 0, ageMax: 24, seed: 13, pvRating: 4.8, communityLoves: 2050, indian: true,
    why: 'Slow, repetitive lullabies in your own language soothe his nervous system and wire his brain for the rhythm and melody of speech - and they are a ritual you will both come to love.',
    consider: 'Your live, imperfect voice matters more than any recording - hum along.',
    bestFor: 'Wind-down and bedtime.',
    skills: ['Language', 'Emotional connection'], benefits: ['Soothing', 'Language rhythm'],
    collections: ['music', 'indianbooks'], tags: ['lullaby', 'music', 'sleep', 'indian', 'bedtime'],
    relatedActivityId: 'song',
  ),
  RecoItem(
    id: 'mu_rhymes', category: 'Music', title: 'Action rhymes & finger play', summary: 'Songs with movement and a pause.',
    ageMin: 4, ageMax: 24, seed: 14, pvRating: 4.7, communityLoves: 1610, indian: true,
    why: 'Rhymes with a tickle or a pause at the end teach anticipation and turn-taking - and the repetition is a gift to a language-building brain.',
    consider: 'The "join in" magic really blooms a little later, from six months.',
    bestFor: 'Playful, connected minutes together.',
    skills: ['Anticipation', 'Language', 'Turn-taking'], benefits: ['Language', 'Bonding'],
    collections: ['music'], tags: ['rhymes', 'music', 'finger play', 'indian'],
    relatedActivityId: 'song',
  ),

  // ---- Outdoor --------------------------------------------------------------
  RecoItem(
    id: 'od_walk', category: 'Outdoor', title: 'A slow morning stroller walk', summary: 'Fresh air, shade and new things to see.',
    ageMin: 0, ageMax: 36, seed: 15, pvRating: 4.7, communityLoves: 1880,
    why: 'A gentle walk in the cool of the morning gives him new sights and sounds to take in and helps regulate everyone\'s mood and sleep - one of the simplest, best things you can do together.',
    consider: 'Keep him shaded and go before the day heats up; skip it on high-pollution mornings.',
    bestFor: 'Most days, weather allowing.',
    skills: ['Sensory exploration'], benefits: ['Mood', 'Sleep rhythm'],
    collections: ['weekend'], tags: ['walk', 'outdoor', 'stroller', 'morning', 'weekend', 'free'],
  ),
  RecoItem(
    id: 'od_park', category: 'Outdoor', title: 'Under-the-tree blanket time', summary: 'A shady patch of grass and sky.',
    ageMin: 2, ageMax: 36, seed: 16, pvRating: 4.6, communityLoves: 1330,
    why: 'Lay a blanket under a tree and let him watch the leaves move - dappled light and gentle motion are mesmerising, and it is tummy time with a view.',
    consider: 'Bring a light cloth for sun and insects; avoid the midday heat.',
    bestFor: 'Calm weekend mornings.',
    skills: ['Visual tracking', 'Sensory exploration'], benefits: ['Calm', 'Visual'],
    collections: ['weekend'], tags: ['park', 'outdoor', 'nature', 'weekend', 'free'],
  ),

  // ---- Experiences ----------------------------------------------------------
  RecoItem(
    id: 'ex_sensory', category: 'Experiences', title: 'Baby sensory class', summary: 'Lights, textures and songs, together.',
    ageMin: 3, ageMax: 12, seed: 17, pvRating: 4.5, communityLoves: 940,
    why: 'A gentle, structured hour of lights, textures and songs - lovely for him, and quietly wonderful for you, meeting other parents at the same stage.',
    consider: 'Worth it for the community as much as the class; not essential - you can do much of it at home.',
    bestFor: 'Parents wanting connection and routine.',
    skills: ['Sensory exploration', 'Social connection'], benefits: ['Sensory', 'Parent support'],
    collections: ['sensory'], tags: ['class', 'sensory', 'experience', 'community'],
  ),
  RecoItem(
    id: 'ex_swim', category: 'Experiences', title: 'Parent-and-baby water time', summary: 'Warm water, close and calm.',
    ageMin: 4, ageMax: 24, seed: 18, pvRating: 4.4, communityLoves: 760,
    why: 'Warm-water sessions build confidence and are a beautiful skin-to-skin bonding experience - the buoyancy lets him move in ways he cannot on land.',
    consider: 'Only warm, clean, baby-appropriate pools; keep sessions short and never force it.',
    bestFor: 'Confident, water-loving families.',
    skills: ['Gross motor', 'Confidence'], benefits: ['Motor', 'Bonding'],
    collections: [], tags: ['swim', 'water', 'experience'],
  ),

  // ---- Products (cross-linked to the real catalogue) ------------------------
  RecoItem(
    id: 'pr_soother', category: 'Products', title: 'Dozy white-noise soother', summary: 'Steady sound that mimics the womb.',
    ageMin: 0, ageMax: 24, seed: 19, pvRating: 4.6, communityLoves: 2410, price: '₹1,999',
    why: 'Steady white noise recreates the constant whoosh of the womb - genuinely soothing during the 4-month sleep shift. We like this one for its true continuous sound and an auto-off timer.',
    consider: 'Keep the volume gentle and across the room; it is a sleep aid, not a habit to depend on forever.',
    bestFor: 'Light-sleeping babies in noisy homes.',
    skills: [], benefits: ['Sleep'],
    collections: ['travel'], tags: ['sleep', 'white noise', 'soother', 'product'],
    relatedProductId: 'dozy', relatedArticleId: 'sleepcycles',
  ),
  RecoItem(
    id: 'pr_carrier', category: 'Products', title: 'Ergonomic soft carrier', summary: 'Hands free, baby close.',
    ageMin: 0, ageMax: 18, seed: 20, pvRating: 4.7, communityLoves: 1990, price: '₹2,799',
    why: 'Being carried close regulates a young baby and frees your hands for everything else. A supportive, ergonomic carrier that keeps his hips in the healthy "M" position is worth the investment.',
    consider: 'Check the hip-healthy seat and your own back support; try before you commit if you can.',
    bestFor: 'Busy days and contact naps.',
    skills: [], benefits: ['Bonding', 'Regulation'],
    collections: ['travel'], tags: ['carrier', 'babywearing', 'product', 'travel'],
  ),

  // ---- Parent Picks ---------------------------------------------------------
  RecoItem(
    id: 'pp_book', category: 'Parent Picks', title: 'The Wonder Weeks (for parents)', summary: 'Make sense of the fussy leaps.',
    ageMin: 0, ageMax: 20, seed: 21, pvRating: 4.6, communityLoves: 1720,
    why: 'The framework behind the leaps in this app - it turns "why is he suddenly so fussy?" into "ah, his brain is doing something new." A calming read for the hard weeks.',
    consider: 'Treat the exact week-charts loosely; every baby varies by a week or two.',
    bestFor: 'Parents who like to understand the why.',
    skills: [], benefits: ['Parent confidence'],
    collections: [], tags: ['parent', 'book', 'wonder weeks', 'development'],
  ),
  RecoItem(
    id: 'pp_selfcare', category: 'Parent Picks', title: 'Five minutes for you, too', summary: 'A tiny reset in the fourth-month fog.',
    ageMin: 0, ageMax: 12, seed: 22, pvRating: 4.5, communityLoves: 1330,
    why: 'You cannot pour from an empty cup. A short, honest guide to protecting your own calm - because how you are doing matters, deeply, to how he is doing.',
    consider: 'Not a fix for real low mood - if the fog does not lift, please reach out for support.',
    bestFor: 'Every tired parent.',
    skills: [], benefits: ['Parent wellbeing'],
    collections: [], tags: ['parent', 'wellness', 'selfcare'],
    relatedVideoId: 'mumwellness', relatedArticleId: 'matrescence',
  ),

  // ---- Events ---------------------------------------------------------------
  RecoItem(
    id: 'ev_storytime', category: 'Events', title: 'Library baby story-time', summary: 'A free weekly circle of songs & books.',
    ageMin: 0, ageMax: 36, seed: 23, pvRating: 4.5, communityLoves: 680,
    why: 'Many libraries run a free weekly baby story-time - songs, rhymes and board books with other little ones. Gentle exposure to language and community, at no cost.',
    consider: 'Check timings suit his naps; babies dip in and out and that is perfectly fine.',
    bestFor: 'A low-key weekly ritual.',
    skills: ['Language', 'Social connection'], benefits: ['Language', 'Community'],
    collections: ['weekend'], tags: ['event', 'library', 'story time', 'free', 'weekend'],
  ),
  RecoItem(
    id: 'ev_festival', category: 'Events', title: 'His first festival, gently', summary: 'Celebrate without overwhelming.',
    ageMin: 0, ageMax: 24, seed: 24, pvRating: 4.4, communityLoves: 590, indian: true,
    why: 'Festivals are precious firsts - soft lamps, family faces and familiar songs. Keep it calm and he will soak up the warmth without the overstimulation of crowds and crackers.',
    consider: 'Protect his ears from loud sounds and his eyes from harsh lights; have a quiet room to retreat to.',
    bestFor: 'Family festival days.',
    skills: ['Social connection'], benefits: ['Belonging'],
    collections: [], tags: ['festival', 'event', 'indian', 'family'],
  ),

  // ---- Travel ---------------------------------------------------------------
  RecoItem(
    id: 'tv_essentials', category: 'Travel', title: 'The 4-month travel kit', summary: 'What actually helps on the go.',
    ageMin: 0, ageMax: 18, seed: 25, pvRating: 4.6, communityLoves: 1210,
    why: 'A short, honest list of what earns its place in the bag - not fifty gadgets. The soother, a familiar cloth, and his routine matter more than any product.',
    consider: 'Pack light; the most-forgotten essential is a spare set of clothes for you, not just him.',
    bestFor: 'First trips away.',
    skills: [], benefits: ['Calmer travel'],
    collections: ['travel'], tags: ['travel', 'packing', 'essentials'],
  ),
  RecoItem(
    id: 'tv_hillstation', category: 'Travel', title: 'A slow hill-station break', summary: 'Cool air, calm, no rush.',
    ageMin: 3, ageMax: 36, seed: 26, pvRating: 4.3, communityLoves: 540, indian: true,
    why: 'A gentle, cool-weather destination beats a packed itinerary. Babies travel best when the days stay slow and the routine stays roughly intact.',
    consider: 'Watch the altitude and long drives; break journeys often and keep feeds/naps sacred.',
    bestFor: 'A first family holiday.',
    skills: [], benefits: ['Family time'],
    collections: ['travel'], tags: ['travel', 'holiday', 'hills', 'indian'],
  ),

  // ---- Restaurants ----------------------------------------------------------
  RecoItem(
    id: 'rs_friendly', category: 'Restaurants', title: 'Baby-friendly cafe outings', summary: 'Where a stroller and a feed are welcome.',
    ageMin: 0, ageMax: 36, seed: 27, pvRating: 4.4, communityLoves: 720,
    why: 'A calm, spacious cafe with room for a stroller and an easy corner to feed lets you keep a little of your old life. Off-peak hours mean a gentler crowd for everyone.',
    consider: 'Go between rushes; a quiet nook beats a "kids menu" at this age.',
    bestFor: 'A short outing that suits you both.',
    skills: [], benefits: ['Parent wellbeing'],
    collections: ['weekend'], tags: ['restaurant', 'cafe', 'outing', 'weekend'],
  ),

  // ---- Birthday Ideas -------------------------------------------------------
  RecoItem(
    id: 'bd_first', category: 'Birthday Ideas', title: 'A gentle first birthday', summary: 'Meaningful over Instagrammable.',
    ageMin: 9, ageMax: 15, seed: 28, pvRating: 4.7, communityLoves: 1450, indian: true,
    why: 'A first birthday is really for the grown-ups. A small gathering, familiar faces, his own food and a short window before nap will mean far more to him than a big themed party.',
    consider: 'Keep it short and time it around his sleep - an overtired baby remembers none of it, but feels all of it.',
    bestFor: 'Planning the first big day.',
    skills: ['Social connection'], benefits: ['Belonging'],
    collections: ['firstbday'], tags: ['birthday', 'first birthday', 'party', 'indian'],
  ),
  RecoItem(
    id: 'bd_keepsake', category: 'Birthday Ideas', title: 'A first-year keepsake', summary: 'Capture the year, not just the day.',
    ageMin: 9, ageMax: 15, seed: 29, pvRating: 4.6, communityLoves: 890,
    why: 'A hand-print, a letter to his future self, or a little storybook of his first year is the gift that lasts. ParentVeda\'s Journal can turn your photos into exactly this.',
    consider: 'Do it before the day so you are present at the party, not behind a camera.',
    bestFor: 'Sentimental parents.',
    skills: [], benefits: ['Memory keeping'],
    collections: ['firstbday'], tags: ['birthday', 'keepsake', 'journal', 'memory'],
  ),

  // ---- Learning -------------------------------------------------------------
  RecoItem(
    id: 'ln_narrate', category: 'Learning', title: 'Narrate-your-day habit', summary: 'The simplest language builder there is.',
    ageMin: 0, ageMax: 24, seed: 30, pvRating: 4.9, communityLoves: 2680,
    why: 'Talking through the ordinary - "now we\'re pouring the water" - and pausing for his reply wires his brain for language months before words appear. It is free, and it is the single best "learning resource" you have.',
    consider: 'It can feel silly at first; do it anyway - the back-and-forth is what counts.',
    bestFor: 'Every single day.',
    skills: ['Language', 'Turn-taking'], benefits: ['Language', 'Bonding'],
    collections: ['montessori'], tags: ['language', 'talking', 'learning', 'free'],
    relatedActivityId: 'narrate', relatedArticleId: 'talking', relatedVideoId: 'babbling',
  ),
  RecoItem(
    id: 'ln_signing', category: 'Learning', title: 'A few first baby signs', summary: 'Give him words before speech.',
    ageMin: 6, ageMax: 18, seed: 31, pvRating: 4.4, communityLoves: 1040,
    why: 'A handful of simple signs - "milk", "more", "all done" - can ease the frustration of the pre-verbal months by giving him a way to tell you what he needs.',
    consider: 'Start light, from around six months; a few consistent signs beat a big vocabulary.',
    bestFor: 'The pre-talking stretch.',
    skills: ['Communication', 'Language'], benefits: ['Communication'],
    collections: [], tags: ['signing', 'communication', 'learning'],
  ),
];

// ---- lookups ----------------------------------------------------------------
RecoItem recoById(String id) => kReco.firstWhere((r) => r.id == id, orElse: () => kReco.first);
List<RecoItem> recoByCategory(String category) => kReco.where((r) => r.category == category).toList();

// =============================================================================
//  The personalisation context - built live from the child + the parent's
//  signals across the app. This is the "understand the child first" step.
// =============================================================================
class RecoContext {
  RecoContext({required this.ageMonths, required this.interests, required this.stageWords, required this.viewed, required this.leapLabel});
  final int ageMonths;
  final Set<String> interests; // keywords from saved/watched/read/compared
  final Set<String> stageWords; // keywords from the current leap's "working on"
  final Set<String> viewed; // reco ids already opened
  final String leapLabel; // e.g. "Leap 4"

  static RecoContext build() {
    final child = ChildProfileStore.instance;
    final leap = currentLeap(child);
    final interests = <String>{};
    void addWords(String s) {
      for (final w in s.toLowerCase().split(RegExp(r'[^a-z]+'))) {
        if (w.length >= 4) interests.add(w);
      }
    }

    // signals: saved/recent videos, saved articles, saved activities, compared products
    for (final v in WatchStore.instance.saved) {
      addWords(v.category);
      addWords(v.topic);
    }
    for (final v in WatchStore.instance.recentlyWatched.take(4)) {
      addWords(v.category);
    }
    for (final a in ReadingStore.instance.saved) {
      addWords(readCollectionById(a.collection).title);
    }
    for (final act in DevStore.instance.savedActivities) {
      for (final sk in act.skills) {
        addWords(sk);
      }
    }
    for (final p in PpCompareStore.instance.selected) {
      addWords(p.category);
    }

    final stageWords = <String>{};
    for (final w in leap.workingOn) {
      for (final t in w.toLowerCase().split(RegExp(r'[^a-z]+'))) {
        if (t.length >= 4) stageWords.add(t);
      }
    }

    return RecoContext(
      ageMonths: child.ageInMonths,
      interests: interests,
      stageWords: stageWords,
      viewed: RecoStore.instance.viewedIds,
      leapLabel: leap.label,
    );
  }
}

double _score(RecoItem it, RecoContext ctx) {
  double s = 0;
  final m = ctx.ageMonths;
  // age fit - the strongest signal
  if (m >= it.ageMin && m <= it.ageMax) {
    s += 50;
  } else {
    final dist = m < it.ageMin ? it.ageMin - m : m - it.ageMax;
    s += (18 - dist * 5).clamp(-40.0, 18.0);
  }
  // interest overlap (what the parent has been exploring)
  final hay = it.haystack;
  final interestHits = ctx.interests.where(hay.contains).length;
  s += interestHits * 7;
  // current developmental stage
  final stageHits = ctx.stageWords.where(hay.contains).length;
  s += stageHits * 6;
  // quality + community
  s += it.pvRating * 2.5;
  s += (it.communityLoves / 1500).clamp(0.0, 3.0);
  // gentle novelty - nudge un-opened items up
  if (!ctx.viewed.contains(it.id)) s += 4;
  // deterministic tiebreak (no randomness)
  s += it.seed % 5;
  return s;
}

List<RecoItem> _ranked(RecoContext ctx, {Iterable<RecoItem>? pool}) {
  final list = (pool ?? kReco).toList()..sort((a, b) => _score(b, ctx).compareTo(_score(a, ctx)));
  return list;
}

/// A short, human explanation of WHY this item is surfacing for this child.
String recoReason(RecoItem it, RecoContext ctx) {
  final m = ctx.ageMonths;
  final closing = m >= it.ageMin && it.ageMax - m >= 0 && it.ageMax - m <= 2;
  final hay = it.haystack;
  if (closing) return 'A lovely age for this - the window won\'t stay open long.';
  if (ctx.stageWords.any(hay.contains)) return 'Supports what he\'s working on in ${ctx.leapLabel} right now.';
  if (ctx.interests.any(hay.contains)) return 'Because you\'ve been exploring similar things.';
  if (m >= it.ageMin && m <= it.ageMax) return 'Right for his $m-month stage.';
  if (m < it.ageMin) return 'Worth knowing - one to look forward to.';
  return 'A ParentVeda favourite for this stage.';
}

// =============================================================================
//  Engine - the surfaces the screens read from.
// =============================================================================

/// The hero: a handful of highly-relevant picks, diversified so it is never all
/// one category. Answers "what is worth my time for my child today?".
List<RecoItem> recommendedToday({int count = 7}) {
  final ctx = RecoContext.build();
  final ranked = _ranked(ctx);
  final out = <RecoItem>[];
  final perCat = <String, int>{};
  for (final it in ranked) {
    if ((perCat[it.category] ?? 0) >= 2) continue; // diversify
    out.add(it);
    perCat[it.category] = (perCat[it.category] ?? 0) + 1;
    if (out.length >= count) break;
  }
  return out;
}

/// Age-ranked picks within one category.
List<RecoItem> topForCategory(String category, {int? limit}) {
  final ctx = RecoContext.build();
  final list = _ranked(ctx, pool: recoByCategory(category));
  return limit == null ? list : list.take(limit).toList();
}

/// ParentVeda Original - what children of this exact age are learning.
List<RecoItem> growingThisMonth({int count = 6}) {
  final ctx = RecoContext.build();
  final pool = kReco.where((r) => ctx.ageMonths >= r.ageMin && ctx.ageMonths <= r.ageMax && r.skills.isNotEmpty);
  return _ranked(ctx, pool: pool).take(count).toList();
}

/// ParentVeda Original - a weekend bundle (a mix of activity/outing/book/etc).
List<RecoItem> weekendPicks({int count = 6}) {
  final ctx = RecoContext.build();
  final pool = kReco.where((r) => r.tags.contains('weekend') || r.category == 'Outdoor' || r.category == 'Experiences' || r.collections.contains('weekend'));
  return _ranked(ctx, pool: pool).take(count).toList();
}

/// ParentVeda Original - things that are especially valuable in the current
/// developmental window and won't be for long.
List<RecoItem> beforeTheyGrowOut({int count = 6}) {
  final ctx = RecoContext.build();
  final m = ctx.ageMonths;
  final pool = kReco.where((r) => m >= r.ageMin && r.ageMax - m >= 0 && r.ageMax - m <= 3);
  final list = pool.toList()..sort((a, b) => (a.ageMax - m).compareTo(b.ageMax - m));
  return list.take(count).toList();
}

/// ParentVeda Original - thoughtful Indian discovery.
List<RecoItem> hiddenIndianGems({int count = 6}) {
  final ctx = RecoContext.build();
  return _ranked(ctx, pool: kReco.where((r) => r.indian)).take(count).toList();
}

/// ParentVeda Community loves - most-saved, but age-weighted (never a raw
/// popularity contest).
List<RecoItem> communityLoves({int count = 6}) {
  final ctx = RecoContext.build();
  final list = kReco.toList()
    ..sort((a, b) {
      final af = (ctx.ageMonths >= a.ageMin && ctx.ageMonths <= a.ageMax) ? 1 : 0;
      final bf = (ctx.ageMonths >= b.ageMin && ctx.ageMonths <= b.ageMax) ? 1 : 0;
      if (af != bf) return bf - af;
      return b.communityLoves.compareTo(a.communityLoves);
    });
  return list.take(count).toList();
}

/// Natural-language-ish search across every category.
List<RecoItem> recoSearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final terms = q.split(RegExp(r'[^a-z0-9]+')).where((t) => t.length >= 2).toList();
  if (terms.isEmpty) return const [];
  final scored = <(RecoItem, int)>[];
  for (final it in kReco) {
    final hay = it.haystack;
    var hits = 0;
    for (final t in terms) {
      if (hay.contains(t)) hits++;
    }
    if (hits > 0) scored.add((it, hits));
  }
  scored.sort((a, b) => b.$2.compareTo(a.$2));
  return scored.map((e) => e.$1).toList();
}

/// Related items (same category / shared collection), excluding [it].
List<RecoItem> relatedReco(RecoItem it, {int count = 4}) {
  final out = <RecoItem>[];
  final seen = <String>{it.id};
  void add(Iterable<RecoItem> xs) {
    for (final x in xs) {
      if (out.length >= count) return;
      if (seen.add(x.id)) out.add(x);
    }
  }

  add(kReco.where((r) => r.collections.any(it.collections.contains)));
  add(recoByCategory(it.category));
  add(kReco);
  return out.take(count).toList();
}

// =============================================================================
//  RecoStore - saved bookmarks, viewed history (Continue Exploring) + wishlists.
// =============================================================================
class RecoStore extends ChangeNotifier {
  RecoStore._();
  static final RecoStore instance = RecoStore._();

  final Set<String> _saved = {'ac_peekaboo', 'bk_indianfaces'};
  final List<String> _viewed = ['vd_leap4', 'ln_narrate'];
  // named wishlists → item ids
  final Map<String, Set<String>> _lists = {
    'Weekend Ideas': {'od_walk'},
    'Books to Buy': {'bk_indianfaces'},
    'Birthday Wishlist': {},
    'Travel Ideas': {},
    'Activities to Try': {'ac_tummy'},
  };

  // ---- saved / bookmarks ----
  bool isSaved(String id) => _saved.contains(id);
  void toggleSave(String id) {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    notifyListeners();
  }

  List<RecoItem> get saved => _saved.map(recoById).toList();
  int get savedCount => _saved.length;

  // ---- viewed / continue exploring ----
  Set<String> get viewedIds => _viewed.toSet();
  List<RecoItem> get continueExploring => _viewed.reversed.map(recoById).toList();
  void markViewed(String id) {
    _viewed.remove(id);
    _viewed.add(id);
    if (_viewed.length > 12) _viewed.removeAt(0);
    notifyListeners();
  }

  // ---- wishlists ----
  List<String> get listNames => _lists.keys.toList();
  Set<String> listItems(String name) => _lists[name] ?? {};
  int listCount(String name) => _lists[name]?.length ?? 0;

  bool isInList(String name, String id) => _lists[name]?.contains(id) ?? false;
  void toggleInList(String name, String id) {
    final set = _lists.putIfAbsent(name, () => <String>{});
    set.contains(id) ? set.remove(id) : set.add(id);
    notifyListeners();
  }

  void createList(String name) {
    final n = name.trim();
    if (n.isNotEmpty && !_lists.containsKey(n)) {
      _lists[n] = <String>{};
      notifyListeners();
    }
  }

  /// Every id that sits in any wishlist (for the library's "in a list" view).
  List<RecoItem> get allWishlisted {
    final ids = <String>{};
    for (final s in _lists.values) {
      ids.addAll(s);
    }
    return ids.map(recoById).toList();
  }
}
