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
//
//  Each item also carries category-appropriate FACETS (a small typed map, plus a
//  human `subtype`) so every category screen can offer real filters + sub-filters
//  that actually narrow the list. See RecoFacetGroup / _catFacets below.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import '../../brand/brand_context.dart';
import '../../brand/brand_models.dart';
import '../../brand/brand_studio.dart';
import '../../brand/rank_floor.dart';
import '../../services/family_profile.dart';
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
    this.subtype,
    this.facets = const {},
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
  final String? subtype; // a short human "type" label, e.g. "Board book"
  final Map<String, List<String>> facets; // typed filter dimensions -> values
  final String? relatedArticleId; // ReadArticle id
  final String? relatedVideoId; // WatchVideo id
  final String? relatedProductId; // PpProduct id
  final String? relatedActivityId; // DevActivity id

  String get ageLabel {
    String m(int x) => x >= 12 ? '${(x / 12).toStringAsFixed(x % 12 == 0 ? 0 : 1)}y' : '${x}m';
    return '${m(ageMin)}–${m(ageMax)}';
  }

  /// Everything searchable, lowercased.
  String get haystack =>
      '$title $summary $category ${tags.join(' ')} ${skills.join(' ')} ${collections.join(' ')} $bestFor ${subtype ?? ''} ${facets.values.expand((v) => v).join(' ')}'
          .toLowerCase();
}

// =============================================================================
//  Facets - category-appropriate filter dimensions + sub-filters.
// -----------------------------------------------------------------------------
//  Each category declares a set of RecoFacetGroups. Every group has a `dim`
//  (the key into an item's `facets` map), a human `label`, and a list of
//  (value, label) options. The category screen renders only the options that
//  actually have items, and an item passes a group if it matches ANY selected
//  value in that group (OR within a group, AND across groups). One universal
//  "Age" group is derived from every item's age window.
// =============================================================================
class RecoFacetGroup {
  const RecoFacetGroup(this.dim, this.label, this.options);
  final String dim;
  final String label;
  final List<(String, String)> options; // (value, display label)
}

/// Universal age bands (min inclusive, max inclusive - overlap match).
const List<(String, String, int, int)> kRecoAgeBands = [
  ('nb', '0–6m', 0, 6),
  ('baby', '6–12m', 6, 12),
  ('tot', '1–2y', 12, 24),
  ('big', '2y+', 24, 72),
];

final RecoFacetGroup _ageBandGroup =
    RecoFacetGroup('age', 'Age', [for (final b in kRecoAgeBands) (b.$1, b.$2)]);

const Map<String, List<RecoFacetGroup>> _catFacets = {
  'Books': [
    RecoFacetGroup('format', 'Format', [('board', 'Board'), ('picture', 'Picture'), ('story', 'Story'), ('activity', 'Activity'), ('cloth', 'Cloth')]),
    RecoFacetGroup('language', 'Language', [('english', 'English'), ('hindi', 'Hindi'), ('bilingual', 'Bilingual'), ('wordless', 'Wordless')]),
    RecoFacetGroup('theme', 'Theme', [('contrast', 'High-contrast'), ('faces', 'Faces'), ('emotions', 'Emotions'), ('animals', 'Animals'), ('bedtime', 'Bedtime'), ('firstwords', 'First words')]),
  ],
  'Activities': [
    RecoFacetGroup('skill', 'Skill', [('sensory', 'Sensory'), ('motor', 'Motor'), ('cognitive', 'Thinking'), ('language', 'Language'), ('social', 'Social'), ('creative', 'Creative')]),
    RecoFacetGroup('place', 'Where', [('indoor', 'Indoor'), ('outdoor', 'Outdoor')]),
    RecoFacetGroup('mess', 'Mess level', [('none', 'No mess'), ('some', 'A little'), ('messy', 'Messy')]),
  ],
  'Toys': [
    RecoFacetGroup('skill', 'Skill', [('motor', 'Motor'), ('cognitive', 'Thinking'), ('sensory', 'Sensory'), ('pretend', 'Pretend')]),
    RecoFacetGroup('material', 'Material', [('wood', 'Wood'), ('cloth', 'Cloth'), ('silicone', 'Silicone'), ('plastic', 'Plastic')]),
  ],
  'Videos': [
    RecoFacetGroup('type', 'Type', [('explainer', 'Explainer'), ('howto', 'How-to'), ('series', 'Series')]),
    RecoFacetGroup('length', 'Length', [('short', 'Short'), ('medium', 'Medium'), ('long', 'Long')]),
  ],
  'Music': [
    RecoFacetGroup('type', 'Type', [('lullaby', 'Lullaby'), ('rhyme', 'Rhyme'), ('action', 'Action song'), ('instrumental', 'Instrumental')]),
    RecoFacetGroup('language', 'Language', [('hindi', 'Hindi'), ('english', 'English'), ('regional', 'Regional'), ('wordless', 'Wordless')]),
  ],
  'Outdoor': [
    RecoFacetGroup('setting', 'Setting', [('walk', 'Walk'), ('park', 'Park'), ('garden', 'Garden'), ('water', 'Water'), ('nature', 'Nature')]),
    RecoFacetGroup('energy', 'Pace', [('calm', 'Calm'), ('active', 'Active')]),
  ],
  'Experiences': [
    RecoFacetGroup('type', 'Type', [('sensory', 'Sensory'), ('water', 'Water'), ('music', 'Music'), ('art', 'Art'), ('outing', 'Outing')]),
    RecoFacetGroup('setting', 'Setting', [('indoor', 'Indoor'), ('outdoor', 'Outdoor')]),
  ],
  'Products': [
    RecoFacetGroup('use', 'For', [('sleep', 'Sleep'), ('feeding', 'Feeding'), ('travel', 'Travel'), ('care', 'Care'), ('play', 'Play')]),
  ],
  'Parent Picks': [
    RecoFacetGroup('kind', 'Kind', [('book', 'Book'), ('podcast', 'Podcast'), ('tool', 'Tool'), ('wellness', 'Wellness')]),
    RecoFacetGroup('topic', 'Topic', [('development', 'Development'), ('sleep', 'Sleep'), ('wellbeing', 'Wellbeing'), ('feeding', 'Feeding')]),
  ],
  'Events': [
    RecoFacetGroup('kind', 'Kind', [('storytime', 'Story-time'), ('festival', 'Festival'), ('workshop', 'Workshop'), ('meetup', 'Meet-up'), ('community', 'Community')]),
    RecoFacetGroup('cost', 'Cost', [('free', 'Free'), ('paid', 'Paid')]),
  ],
  'Travel': [
    RecoFacetGroup('kind', 'Kind', [('essentials', 'Essentials'), ('destination', 'Destination'), ('tips', 'Tips')]),
    RecoFacetGroup('setting', 'Setting', [('hills', 'Hills'), ('beach', 'Beach'), ('city', 'City'), ('nature', 'Nature')]),
  ],
  'Restaurants': [
    RecoFacetGroup('kind', 'Kind', [('cafe', 'Cafe'), ('family', 'Family'), ('outdoor', 'Outdoor')]),
    RecoFacetGroup('feature', 'Good for', [('stroller', 'Stroller-friendly'), ('highchairs', 'High chairs'), ('play', 'Play area'), ('quiet', 'Quiet')]),
  ],
  'Birthday Ideas': [
    RecoFacetGroup('kind', 'Kind', [('party', 'Party'), ('keepsake', 'Keepsake'), ('decor', 'Decor'), ('cake', 'Cake'), ('gifts', 'Return gifts')]),
  ],
  'Learning': [
    RecoFacetGroup('kind', 'Focus', [('language', 'Language'), ('signing', 'Signing'), ('numbers', 'Numbers'), ('music', 'Music')]),
    RecoFacetGroup('format', 'Format', [('habit', 'Daily habit'), ('flashcards', 'Flashcards'), ('routine', 'Routine'), ('app', 'App')]),
  ],
};

/// The full facet groups a category could offer (age band first, then its own).
List<RecoFacetGroup> recoFacetsFor(String category) => [
      _ageBandGroup,
      ...(_catFacets[category] ?? const <RecoFacetGroup>[]),
    ];

/// Does [it] match a single facet value on dimension [dim]? Age is derived from
/// the item's window; every other dimension reads the item's `facets` map.
bool recoMatchesFacet(RecoItem it, String dim, String value) {
  if (dim == 'age') {
    final band = kRecoAgeBands.firstWhere((b) => b.$1 == value, orElse: () => kRecoAgeBands.first);
    return it.ageMin <= band.$4 && it.ageMax >= band.$3;
  }
  final vals = it.facets[dim];
  return vals != null && vals.contains(value);
}

/// The facet groups worth showing for [category] given its [pool] of items -
/// only options that actually have items, and only groups that meaningfully
/// narrow (>= 2 live options).
List<RecoFacetGroup> recoFacetGroupsFor(String category, List<RecoItem> pool) {
  final out = <RecoFacetGroup>[];
  for (final g in recoFacetsFor(category)) {
    final opts = g.options.where((o) => pool.any((it) => recoMatchesFacet(it, g.dim, o.$1))).toList();
    if (opts.length >= 2) out.add(RecoFacetGroup(g.dim, g.label, opts));
  }
  return out;
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
//  Every category carries at least a handful of picks so its filters have room
//  to work.
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
    subtype: 'Board book', facets: {'format': ['board'], 'language': ['english'], 'theme': ['contrast', 'faces']},
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
    subtype: 'Cloth book', facets: {'format': ['cloth'], 'language': ['wordless'], 'theme': ['contrast', 'animals']},
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
    subtype: 'Lift-the-flap book', facets: {'format': ['board'], 'language': ['bilingual'], 'theme': ['faces']},
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
    subtype: 'Picture book', facets: {'format': ['picture', 'story'], 'language': ['english'], 'theme': ['emotions']},
    relatedArticleId: 'tantrums',
  ),
  RecoItem(
    id: 'bk_animals', category: 'Books', title: 'First Words: Animals', summary: 'Big, friendly animals and their names.',
    ageMin: 6, ageMax: 24, seed: 32, pvRating: 4.6, communityLoves: 1290, indian: true, price: '₹299',
    why: 'One clear picture and one clear word per page is exactly right for a baby learning that things have names. Point, name, pause - and watch him start to point back.',
    consider: 'Keep it a naming game, not a quiz; the joy is in the back-and-forth, not "getting it right".',
    bestFor: 'The first-words months.',
    skills: ['Language', 'Vocabulary'], benefits: ['Language', 'Attention'],
    collections: ['indianbooks'], tags: ['animals', 'first words', 'naming', 'indian'],
    subtype: 'First-words board book', facets: {'format': ['board'], 'language': ['bilingual'], 'theme': ['animals', 'firstwords']},
    relatedActivityId: 'narrate',
  ),
  RecoItem(
    id: 'bk_bedtime', category: 'Books', title: 'Goodnight, Little Moon', summary: 'A calm, repetitive bedtime story.',
    ageMin: 6, ageMax: 36, seed: 33, pvRating: 4.7, communityLoves: 1550, price: '₹379',
    why: 'A soft, predictable "goodnight to everything" story becomes part of the wind-down ritual itself. The repetition soothes, and reading the same book nightly builds anticipation and calm.',
    consider: 'He may want it every single night for months - that repetition is the point, not boredom.',
    bestFor: 'The bedtime routine.',
    skills: ['Language', 'Routine'], benefits: ['Soothing', 'Language rhythm'],
    collections: ['music'], tags: ['bedtime', 'story', 'routine', 'sleep'],
    subtype: 'Bedtime story', facets: {'format': ['story', 'picture'], 'language': ['english'], 'theme': ['bedtime']},
    relatedArticleId: 'sleepcycles',
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
    subtype: 'Connection game', facets: {'skill': ['cognitive', 'social'], 'place': ['indoor'], 'mess': ['none']},
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
    subtype: 'Motor play', facets: {'skill': ['motor'], 'place': ['indoor'], 'mess': ['none']},
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
    subtype: 'Sensory play', facets: {'skill': ['sensory', 'motor'], 'place': ['indoor'], 'mess': ['some']},
    relatedActivityId: 'texture',
  ),
  RecoItem(
    id: 'ac_ballroll', category: 'Activities', title: 'Roll the ball back and forth', summary: 'The first game of taking turns.',
    ageMin: 6, ageMax: 18, seed: 35, pvRating: 4.6, communityLoves: 1180,
    why: 'Sitting facing each other and rolling a soft ball is turn-taking in its simplest form - the give-and-take that underpins conversation, sharing and play for years to come.',
    consider: 'He may just want to hold or mouth the ball at first; the turn-taking clicks in its own time.',
    bestFor: 'Newly-sitting babies.',
    skills: ['Turn-taking', 'Gross motor', 'Social connection'], benefits: ['Social', 'Motor'],
    collections: ['rainyday'], tags: ['ball', 'turn taking', 'indoor', 'free'],
    subtype: 'Social play', facets: {'skill': ['social', 'motor'], 'place': ['indoor'], 'mess': ['none']},
  ),
  RecoItem(
    id: 'ac_fingerpaint', category: 'Activities', title: 'Edible finger painting', summary: 'Squish, smear and explore - safely.',
    ageMin: 8, ageMax: 30, seed: 37, pvRating: 4.4, communityLoves: 980,
    why: 'A little yoghurt tinted with beetroot or turmeric turns into safe, taste-proof paint. The mess is the learning: cause and effect, colour, texture and pure sensory joy.',
    consider: 'It is genuinely messy - lay a sheet down, strip him to a nappy, and keep it short.',
    bestFor: 'Warm days you can hose down after.',
    skills: ['Sensory exploration', 'Creativity', 'Fine motor'], benefits: ['Creativity', 'Tactile learning'],
    collections: ['sensory'], tags: ['painting', 'messy', 'art', 'sensory'],
    subtype: 'Messy play', facets: {'skill': ['sensory', 'creative'], 'place': ['indoor', 'outdoor'], 'mess': ['messy']},
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
    subtype: 'Grasping toy', facets: {'skill': ['motor', 'sensory'], 'material': ['wood']},
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
    subtype: 'Stacking toy', facets: {'skill': ['cognitive', 'motor'], 'material': ['plastic']},
  ),
  RecoItem(
    id: 'ty_highcontrast', category: 'Toys', title: 'High-contrast soft rattle', summary: 'Bold patterns plus a gentle sound.',
    ageMin: 0, ageMax: 6, seed: 10, pvRating: 4.5, communityLoves: 1240, price: '₹329',
    why: 'Bold black-white-red patterns hold his gaze while the soft rattle rewards the first swipes of his hand - pairing visual attention with early cause and effect.',
    consider: 'He will not truly grasp it for a few weeks yet; for now it is mostly to look at.',
    bestFor: 'The newborn months.',
    skills: ['Visual attention', 'Cause & effect'], benefits: ['Visual', 'Auditory'],
    collections: ['sensory'], tags: ['rattle', 'high contrast', 'newborn'],
    subtype: 'Rattle', facets: {'skill': ['sensory', 'motor'], 'material': ['cloth']},
    relatedActivityId: 'highcontrast',
  ),
  RecoItem(
    id: 'ty_teether', category: 'Toys', title: 'Silicone fruit teether', summary: 'Soft on sore gums, easy to hold.',
    ageMin: 3, ageMax: 12, seed: 38, pvRating: 4.5, communityLoves: 1360, indian: true, price: '₹249',
    why: 'A soft, food-grade silicone teether with easy-grip shapes gives sore gums relief and busy hands something to explore - and the different textures are their own little sensory lesson.',
    consider: 'Look for one-piece food-grade silicone with no detachable parts; wash it often.',
    bestFor: 'The teething and mouthing months.',
    skills: ['Grasp', 'Sensory exploration'], benefits: ['Fine motor', 'Soothing'],
    collections: ['montessori'], tags: ['teether', 'silicone', 'teething', 'grasp', 'indian'],
    subtype: 'Teether', facets: {'skill': ['sensory', 'motor'], 'material': ['silicone']},
  ),
  RecoItem(
    id: 'ty_shapesorter', category: 'Toys', title: 'Wooden shape sorter', summary: 'Match the shape, solve the puzzle.',
    ageMin: 12, ageMax: 36, seed: 39, pvRating: 4.7, communityLoves: 1470,
    why: 'Working out which shape fits which hole is early problem-solving you can watch happen - trial, error, and the quiet triumph of getting it. It builds spatial thinking and patient focus.',
    consider: 'Too advanced before about a year; start with two or three shapes, not the full set.',
    bestFor: 'The determined toddler.',
    skills: ['Problem solving', 'Shapes', 'Fine motor'], benefits: ['Cognitive', 'Spatial'],
    collections: ['montessori', 'openended'], tags: ['shapes', 'sorter', 'wooden', 'puzzle'],
    subtype: 'Puzzle toy', facets: {'skill': ['cognitive'], 'material': ['wood']},
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
    subtype: 'Parent explainer', facets: {'type': ['explainer'], 'length': ['short']},
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
    subtype: 'Parent explainer', facets: {'type': ['explainer'], 'length': ['medium']},
    relatedVideoId: 'sleep4mo', relatedArticleId: 'sleepcycles', relatedProductId: 'dozy',
  ),
  RecoItem(
    id: 'vd_massage', category: 'Videos', title: 'How to: a calming baby massage', summary: 'A simple, step-by-step routine.',
    ageMin: 0, ageMax: 12, seed: 41, pvRating: 4.7, communityLoves: 2010,
    why: 'A short how-to you can follow along with, hands-on: gentle strokes that soothe, aid digestion and are a beautiful daily moment of connection - the oldest bonding ritual there is.',
    consider: 'Watch once for the technique, then put the screen away and simply be with him.',
    bestFor: 'A calm part of the evening routine.',
    skills: ['Bonding', 'Regulation'], benefits: ['Bonding', 'Soothing'],
    collections: [], tags: ['massage', 'how to', 'bonding', 'routine'],
    subtype: 'How-to', facets: {'type': ['howto'], 'length': ['short']},
  ),
  RecoItem(
    id: 'vd_signs', category: 'Videos', title: 'How-to: your first baby signs', summary: 'Milk, more, all done - shown clearly.',
    ageMin: 6, ageMax: 18, seed: 42, pvRating: 4.5, communityLoves: 1240,
    why: 'A clear demonstration of a handful of everyday signs, so you can start giving him a way to "tell" you what he needs before words arrive - easing a lot of pre-verbal frustration.',
    consider: 'Consistency matters more than quantity; pick three signs and use them every day.',
    bestFor: 'The pre-talking stretch.',
    skills: ['Communication', 'Language'], benefits: ['Communication'],
    collections: [], tags: ['signing', 'how to', 'communication'],
    subtype: 'How-to', facets: {'type': ['howto'], 'length': ['medium']},
  ),
  RecoItem(
    id: 'vd_rhymeseries', category: 'Videos', title: 'Sing-along rhyme series', summary: 'A gentle set of action rhymes.',
    ageMin: 6, ageMax: 24, seed: 43, pvRating: 4.4, communityLoves: 1090, indian: true,
    why: 'A calm, slow-paced series of Indian action rhymes to learn together - the value is you singing them off-screen afterwards, not the screen itself.',
    consider: 'Use it as a songbook for you; keep his own screen time near zero at this age.',
    bestFor: 'Building your own repertoire of rhymes.',
    skills: ['Language', 'Rhythm'], benefits: ['Language', 'Bonding'],
    collections: ['music'], tags: ['rhymes', 'series', 'songs', 'indian'],
    subtype: 'Series', facets: {'type': ['series'], 'length': ['short']},
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
    subtype: 'Lullaby', facets: {'type': ['lullaby'], 'language': ['hindi']},
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
    subtype: 'Action rhyme', facets: {'type': ['action'], 'language': ['hindi']},
    relatedActivityId: 'song',
  ),
  RecoItem(
    id: 'mu_classical', category: 'Music', title: 'Soft Indian classical for calm', summary: 'Gentle ragas for quiet moments.',
    ageMin: 0, ageMax: 36, seed: 44, pvRating: 4.5, communityLoves: 1120, indian: true,
    why: 'Slow instrumental ragas make a lovely, wordless backdrop for calm play or a settling-down evening - rich, patterned sound that is soothing without being stimulating.',
    consider: 'Keep it low and in the background; it is an atmosphere, not a performance to focus on.',
    bestFor: 'Quiet play and evenings.',
    skills: ['Emotional connection'], benefits: ['Soothing', 'Calm'],
    collections: ['music'], tags: ['classical', 'raga', 'instrumental', 'calm', 'indian'],
    subtype: 'Instrumental', facets: {'type': ['instrumental'], 'language': ['wordless']},
  ),
  RecoItem(
    id: 'mu_english', category: 'Music', title: 'Classic English nursery rhymes', summary: 'The old favourites, sung simply.',
    ageMin: 4, ageMax: 36, seed: 45, pvRating: 4.4, communityLoves: 980,
    why: 'The familiar rhymes are packed with rhyme, rhythm and repetition - exactly the patterns a language-building brain loves - and they give you a shared songbook to fall back on anywhere.',
    consider: 'Sing them yourself as much as you play them; your voice is the real magic.',
    bestFor: 'Everyday sing-alongs.',
    skills: ['Language', 'Rhythm'], benefits: ['Language', 'Bonding'],
    collections: ['music'], tags: ['rhymes', 'nursery', 'english', 'songs'],
    subtype: 'Rhyme', facets: {'type': ['rhyme'], 'language': ['english']},
  ),
  RecoItem(
    id: 'mu_regional', category: 'Music', title: 'Lullabies in your mother tongue', summary: 'The songs of your own childhood.',
    ageMin: 0, ageMax: 24, seed: 46, pvRating: 4.6, communityLoves: 1040, indian: true,
    why: 'A lullaby in your regional language carries your family, your accent and your memories - and hearing it wires him for the exact speech sounds of home.',
    consider: 'Ask the grandparents for the ones they sang; those are the most precious of all.',
    bestFor: 'Passing down what was sung to you.',
    skills: ['Language', 'Emotional connection'], benefits: ['Soothing', 'Belonging'],
    collections: ['music'], tags: ['lullaby', 'regional', 'mother tongue', 'indian'],
    subtype: 'Lullaby', facets: {'type': ['lullaby'], 'language': ['regional']},
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
    subtype: 'Stroller walk', facets: {'setting': ['walk'], 'energy': ['calm']},
  ),
  RecoItem(
    id: 'od_park', category: 'Outdoor', title: 'Under-the-tree blanket time', summary: 'A shady patch of grass and sky.',
    ageMin: 2, ageMax: 36, seed: 16, pvRating: 4.6, communityLoves: 1330,
    why: 'Lay a blanket under a tree and let him watch the leaves move - dappled light and gentle motion are mesmerising, and it is tummy time with a view.',
    consider: 'Bring a light cloth for sun and insects; avoid the midday heat.',
    bestFor: 'Calm weekend mornings.',
    skills: ['Visual tracking', 'Sensory exploration'], benefits: ['Calm', 'Visual'],
    collections: ['weekend'], tags: ['park', 'outdoor', 'nature', 'weekend', 'free'],
    subtype: 'Blanket time', facets: {'setting': ['park', 'nature'], 'energy': ['calm']},
  ),
  RecoItem(
    id: 'od_garden', category: 'Outdoor', title: 'A patch of garden to explore', summary: 'Grass, leaves and safe things to touch.',
    ageMin: 8, ageMax: 48, seed: 47, pvRating: 4.5, communityLoves: 990,
    why: 'Letting a crawling or walking child explore a small, safe patch of garden - grass underfoot, a leaf to hold, a bug to watch - is unbeatable open-ended sensory learning.',
    consider: 'Sweep for anything he could mouth or that could sting, and stay within arm\'s reach.',
    bestFor: 'Curious crawlers and new walkers.',
    skills: ['Sensory exploration', 'Gross motor'], benefits: ['Curiosity', 'Motor'],
    collections: ['weekend'], tags: ['garden', 'nature', 'outdoor', 'explore'],
    subtype: 'Nature play', facets: {'setting': ['garden', 'nature'], 'energy': ['active']},
  ),
  RecoItem(
    id: 'od_water', category: 'Outdoor', title: 'Gentle water play outdoors', summary: 'A shallow tray on a warm day.',
    ageMin: 6, ageMax: 36, seed: 48, pvRating: 4.4, communityLoves: 860,
    why: 'A shallow tray of water with a cup and a sponge is pure delight and quietly teaches pouring, cause-and-effect and early physics - the "why does it splash?" of it all.',
    consider: 'Never leave him alone near even a little water, not for a second; keep it shaded.',
    bestFor: 'Hot afternoons in the shade.',
    skills: ['Sensory exploration', 'Cause & effect'], benefits: ['Sensory', 'Motor'],
    collections: [], tags: ['water', 'splash', 'outdoor', 'sensory'],
    subtype: 'Water play', facets: {'setting': ['water'], 'energy': ['active']},
  ),
  RecoItem(
    id: 'od_sunset', category: 'Outdoor', title: 'Evening sky-watching', summary: 'A calm end-of-day ritual outside.',
    ageMin: 0, ageMax: 36, seed: 49, pvRating: 4.5, communityLoves: 720,
    why: 'Stepping outside for the changing colours of the evening sky is a gentle way to close the day - the soft light and cooler air help settle an overstimulated little one before bed.',
    consider: 'Keep it short as bedtime nears so it soothes rather than winds him up.',
    bestFor: 'The witching-hour wind-down.',
    skills: ['Sensory exploration'], benefits: ['Calm', 'Sleep rhythm'],
    collections: [], tags: ['sky', 'evening', 'outdoor', 'calm'],
    subtype: 'Calm ritual', facets: {'setting': ['nature'], 'energy': ['calm']},
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
    subtype: 'Sensory class', facets: {'type': ['sensory', 'class'], 'setting': ['indoor']},
  ),
  RecoItem(
    id: 'ex_swim', category: 'Experiences', title: 'Parent-and-baby water time', summary: 'Warm water, close and calm.',
    ageMin: 4, ageMax: 24, seed: 18, pvRating: 4.4, communityLoves: 760,
    why: 'Warm-water sessions build confidence and are a beautiful skin-to-skin bonding experience - the buoyancy lets him move in ways he cannot on land.',
    consider: 'Only warm, clean, baby-appropriate pools; keep sessions short and never force it.',
    bestFor: 'Confident, water-loving families.',
    skills: ['Gross motor', 'Confidence'], benefits: ['Motor', 'Bonding'],
    collections: [], tags: ['swim', 'water', 'experience'],
    subtype: 'Water class', facets: {'type': ['water'], 'setting': ['indoor']},
  ),
  RecoItem(
    id: 'ex_music', category: 'Experiences', title: 'Parent-and-baby music circle', summary: 'Live songs, shakers and smiles.',
    ageMin: 3, ageMax: 24, seed: 50, pvRating: 4.5, communityLoves: 820,
    why: 'Live music with other babies - real instruments, simple shakers, songs with actions - is joyful and quietly builds rhythm, listening and turn-taking. And you will hum the songs at home for days.',
    consider: 'Some babies just watch at first, and that is full participation at this age.',
    bestFor: 'Families who love a singalong.',
    skills: ['Rhythm', 'Language', 'Social connection'], benefits: ['Language', 'Community'],
    collections: ['music'], tags: ['music', 'class', 'songs', 'experience'],
    subtype: 'Music class', facets: {'type': ['music'], 'setting': ['indoor']},
  ),
  RecoItem(
    id: 'ex_art', category: 'Experiences', title: 'A messy art playdate', summary: 'Paint, dough and no clean-up at home.',
    ageMin: 12, ageMax: 48, seed: 51, pvRating: 4.3, communityLoves: 540,
    why: 'A drop-in messy-play session lets a toddler squish, smear and create with all the mess and none of the home clean-up - rich sensory and creative play in a space built for it.',
    consider: 'Dress him in clothes you do not mind staining; it is meant to get everywhere.',
    bestFor: 'Toddlers who love to get stuck in.',
    skills: ['Creativity', 'Sensory exploration'], benefits: ['Creativity', 'Sensory'],
    collections: [], tags: ['art', 'messy', 'class', 'experience'],
    subtype: 'Art session', facets: {'type': ['art'], 'setting': ['indoor']},
  ),
  RecoItem(
    id: 'ex_farm', category: 'Experiences', title: 'A visit to a petting farm', summary: 'Real animals, up close and gentle.',
    ageMin: 12, ageMax: 60, seed: 52, pvRating: 4.4, communityLoves: 610,
    why: 'Seeing, hearing and (gently) touching real animals brings the animals from his books to life - wonderful for vocabulary, curiosity and awe, all in the fresh air.',
    consider: 'Wash hands well after, watch for over-excited grabbing, and let him set the pace.',
    bestFor: 'A memorable weekend outing.',
    skills: ['Language', 'Sensory exploration'], benefits: ['Curiosity', 'Language'],
    collections: ['weekend'], tags: ['farm', 'animals', 'outing', 'experience'],
    subtype: 'Outing', facets: {'type': ['outing'], 'setting': ['outdoor']},
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
    subtype: 'Sleep aid', facets: {'use': ['sleep']},
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
    subtype: 'Babywearing', facets: {'use': ['travel', 'care']},
  ),
  RecoItem(
    id: 'pr_monitor', category: 'Products', title: 'A simple video baby monitor', summary: 'Peace of mind, without the app overload.',
    ageMin: 0, ageMax: 36, seed: 53, pvRating: 4.4, communityLoves: 1180, price: '₹4,499',
    why: 'A straightforward monitor lets you step away and still keep an eye and ear on him - the reassurance to actually rest or eat while he naps. We favour a plain dedicated screen over one more phone app.',
    consider: 'A monitor is a tool, not a sensor to fret over; a good sleep space matters more than fancy features.',
    bestFor: 'Homes where his room is out of earshot.',
    skills: [], benefits: ['Parent wellbeing'],
    collections: [], tags: ['monitor', 'safety', 'product', 'sleep'],
    subtype: 'Monitor', facets: {'use': ['care', 'sleep']},
  ),
  RecoItem(
    id: 'pr_swaddle', category: 'Products', title: 'Breathable muslin swaddles', summary: 'Airy cotton for calmer newborn sleep.',
    ageMin: 0, ageMax: 6, seed: 54, pvRating: 4.6, communityLoves: 1540, indian: true, price: '₹899',
    why: 'A snug swaddle recreates the cosy containment of the womb and tames the startle reflex that wakes newborns. Light Indian muslin breathes well in the heat, which matters here.',
    consider: 'Stop swaddling once he shows signs of rolling, and never swaddle too tightly around the hips.',
    bestFor: 'The newborn weeks.',
    skills: [], benefits: ['Sleep', 'Soothing'],
    collections: ['travel'], tags: ['swaddle', 'muslin', 'sleep', 'newborn', 'indian'],
    subtype: 'Swaddle', facets: {'use': ['sleep', 'care']},
  ),
  RecoItem(
    id: 'pr_feeding', category: 'Products', title: 'Silicone bib & bowl set', summary: 'For the gloriously messy solids stage.',
    ageMin: 6, ageMax: 36, seed: 55, pvRating: 4.5, communityLoves: 1210, price: '₹799',
    why: 'A catch-all silicone bib and a suction bowl that stays put make starting solids far less stressful - less on the floor, more self-feeding, and a wipe-clean end to every meal.',
    consider: 'A suction bowl buys you time, not a miracle; some flinging is simply how he learns.',
    bestFor: 'Starting solids and baby-led weaning.',
    skills: ['Self-feeding'], benefits: ['Independence'],
    collections: [], tags: ['feeding', 'bib', 'bowl', 'solids', 'product'],
    subtype: 'Feeding gear', facets: {'use': ['feeding']},
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
    subtype: 'Book', facets: {'kind': ['book'], 'topic': ['development']},
  ),
  RecoItem(
    id: 'pp_selfcare', category: 'Parent Picks', title: 'Five minutes for you, too', summary: 'A tiny reset in the fourth-month fog.',
    ageMin: 0, ageMax: 12, seed: 22, pvRating: 4.5, communityLoves: 1330,
    why: 'You cannot pour from an empty cup. A short, honest guide to protecting your own calm - because how you are doing matters, deeply, to how he is doing.',
    consider: 'Not a fix for real low mood - if the fog does not lift, please reach out for support.',
    bestFor: 'Every tired parent.',
    skills: [], benefits: ['Parent wellbeing'],
    collections: [], tags: ['parent', 'wellness', 'selfcare'],
    subtype: 'Wellness guide', facets: {'kind': ['wellness'], 'topic': ['wellbeing']},
    relatedVideoId: 'mumwellness', relatedArticleId: 'matrescence',
  ),
  RecoItem(
    id: 'pp_podcast', category: 'Parent Picks', title: 'A calm parenting podcast', summary: 'Company for the 2am feeds.',
    ageMin: 0, ageMax: 60, seed: 56, pvRating: 4.4, communityLoves: 990,
    why: 'A warm, evidence-based podcast is perfect for tired eyes - listen during feeds or walks. The best ones leave you feeling steadier and less alone, not more anxious.',
    consider: 'Skip any that trade in fear or rigid rules; you want reassurance, not pressure.',
    bestFor: 'Long feeds and stroller walks.',
    skills: [], benefits: ['Parent confidence'],
    collections: [], tags: ['podcast', 'parent', 'listening', 'development'],
    subtype: 'Podcast', facets: {'kind': ['podcast'], 'topic': ['development']},
  ),
  RecoItem(
    id: 'pp_sleeptool', category: 'Parent Picks', title: 'A simple sleep-log habit', summary: 'See the pattern under the chaos.',
    ageMin: 0, ageMax: 24, seed: 57, pvRating: 4.3, communityLoves: 760,
    why: 'Jotting down naps and night wakings for a week often reveals a rhythm you could not feel in the fog - and a little pattern is the first step to gently shaping better sleep.',
    consider: 'Track to understand, not to obsess; put it away once you have the picture.',
    bestFor: 'The "why won\'t he sleep?" weeks.',
    skills: [], benefits: ['Parent confidence'],
    collections: [], tags: ['sleep', 'tracking', 'habit', 'parent'],
    subtype: 'Tool', facets: {'kind': ['tool'], 'topic': ['sleep']},
  ),
  RecoItem(
    id: 'pp_food', category: 'Parent Picks', title: 'First foods, without the fear', summary: 'A calm guide to starting solids.',
    ageMin: 5, ageMax: 18, seed: 58, pvRating: 4.5, communityLoves: 1080, indian: true,
    why: 'A reassuring, India-aware guide to starting solids - what to offer, how to spot readiness, and how to keep mealtimes joyful rather than a battle. It takes the anxiety out of a big milestone.',
    consider: 'General guidance, not medical advice; check allergies and timing with your paediatrician.',
    bestFor: 'The run-up to six months.',
    skills: [], benefits: ['Parent confidence'],
    collections: [], tags: ['solids', 'feeding', 'weaning', 'parent', 'indian'],
    subtype: 'Book', facets: {'kind': ['book'], 'topic': ['feeding']},
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
    subtype: 'Story-time', facets: {'kind': ['storytime'], 'cost': ['free']},
  ),
  RecoItem(
    id: 'ev_festival', category: 'Events', title: 'His first festival, gently', summary: 'Celebrate without overwhelming.',
    ageMin: 0, ageMax: 24, seed: 24, pvRating: 4.4, communityLoves: 590, indian: true,
    why: 'Festivals are precious firsts - soft lamps, family faces and familiar songs. Keep it calm and he will soak up the warmth without the overstimulation of crowds and crackers.',
    consider: 'Protect his ears from loud sounds and his eyes from harsh lights; have a quiet room to retreat to.',
    bestFor: 'Family festival days.',
    skills: ['Social connection'], benefits: ['Belonging'],
    collections: [], tags: ['festival', 'event', 'indian', 'family'],
    subtype: 'Festival', facets: {'kind': ['festival'], 'cost': ['free']},
  ),
  RecoItem(
    id: 'ev_playgroup', category: 'Events', title: 'A neighbourhood playgroup', summary: 'Familiar faces, week after week.',
    ageMin: 6, ageMax: 48, seed: 59, pvRating: 4.5, communityLoves: 830,
    why: 'A regular, informal playgroup gives him gentle social exposure and gives you a lifeline of other parents at the same stage - the seeing-the-same-faces-weekly kind of belonging that carries you.',
    consider: 'Parallel play (side by side, not together) is completely normal at this age; do not expect sharing yet.',
    bestFor: 'Building a little village.',
    skills: ['Social connection'], benefits: ['Community', 'Social'],
    collections: ['weekend'], tags: ['playgroup', 'community', 'meetup', 'free'],
    subtype: 'Meet-up', facets: {'kind': ['meetup'], 'cost': ['free']},
  ),
  RecoItem(
    id: 'ev_workshop', category: 'Events', title: 'A baby-massage workshop', summary: 'Learn the strokes, hands-on.',
    ageMin: 0, ageMax: 12, seed: 60, pvRating: 4.4, communityLoves: 620,
    why: 'A guided workshop teaches you the gentle strokes that soothe and aid digestion, with an instructor to correct your technique - and you meet other new parents in the same tender weeks.',
    consider: 'A one-off class is plenty; the value is learning something you then do at home for free.',
    bestFor: 'New parents wanting a skill and a circle.',
    skills: ['Bonding'], benefits: ['Bonding', 'Parent support'],
    collections: [], tags: ['workshop', 'massage', 'class', 'paid'],
    subtype: 'Workshop', facets: {'kind': ['workshop'], 'cost': ['paid']},
  ),
  RecoItem(
    id: 'ev_museum', category: 'Events', title: 'A quiet museum morning', summary: 'Space, calm and things to see.',
    ageMin: 12, ageMax: 60, seed: 61, pvRating: 4.2, communityLoves: 430,
    why: 'A museum at opening time is spacious, calm and full of colour and form for little eyes - a lovely, low-key outing where he can look about from the carrier or toddle in the quiet.',
    consider: 'Go right at opening before the crowds, and keep it short - one gallery is plenty.',
    bestFor: 'A gentle rainy-day outing.',
    skills: ['Sensory exploration'], benefits: ['Curiosity'],
    collections: [], tags: ['museum', 'outing', 'community', 'paid'],
    subtype: 'Community outing', facets: {'kind': ['community'], 'cost': ['paid']},
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
    subtype: 'Packing list', facets: {'kind': ['essentials']},
  ),
  RecoItem(
    id: 'tv_hillstation', category: 'Travel', title: 'A slow hill-station break', summary: 'Cool air, calm, no rush.',
    ageMin: 3, ageMax: 36, seed: 26, pvRating: 4.3, communityLoves: 540, indian: true,
    why: 'A gentle, cool-weather destination beats a packed itinerary. Babies travel best when the days stay slow and the routine stays roughly intact.',
    consider: 'Watch the altitude and long drives; break journeys often and keep feeds/naps sacred.',
    bestFor: 'A first family holiday.',
    skills: [], benefits: ['Family time'],
    collections: ['travel'], tags: ['travel', 'holiday', 'hills', 'indian'],
    subtype: 'Destination', facets: {'kind': ['destination'], 'setting': ['hills']},
  ),
  RecoItem(
    id: 'tv_beach', category: 'Travel', title: 'A calm beach stay', summary: 'Shade, sea breeze and slow days.',
    ageMin: 6, ageMax: 48, seed: 62, pvRating: 4.2, communityLoves: 480, indian: true,
    why: 'A quiet stretch of coast, well out of the midday sun, is soothing for everyone - the sound of the waves, the open sky, and no itinerary to keep. Slow is the whole point.',
    consider: 'Shade, a hat and gentle sun protection are non-negotiable; keep him cool and hydrated.',
    bestFor: 'A restful winter escape.',
    skills: [], benefits: ['Family time', 'Calm'],
    collections: ['travel'], tags: ['travel', 'beach', 'holiday', 'indian'],
    subtype: 'Destination', facets: {'kind': ['destination'], 'setting': ['beach']},
  ),
  RecoItem(
    id: 'tv_carkit', category: 'Travel', title: 'The road-trip car kit', summary: 'Smoother miles with a baby aboard.',
    ageMin: 0, ageMax: 36, seed: 63, pvRating: 4.4, communityLoves: 690,
    why: 'A little planning - a well-fitted car seat, sunshades, a stash of snacks and a few quiet toys within reach - turns a dreaded drive into a doable one. Timing the drive around a nap is the real trick.',
    consider: 'Stop often to feed and stretch; never take him out of the car seat while moving, ever.',
    bestFor: 'Long drives to family.',
    skills: [], benefits: ['Calmer travel'],
    collections: ['travel'], tags: ['travel', 'car', 'road trip', 'tips'],
    subtype: 'Travel tips', facets: {'kind': ['tips']},
  ),
  RecoItem(
    id: 'tv_grandparents', category: 'Travel', title: 'A trip to the grandparents', summary: 'The most meaningful journey of all.',
    ageMin: 0, ageMax: 60, seed: 64, pvRating: 4.7, communityLoves: 1120, indian: true,
    why: 'Time with grandparents is priceless for him and a lifeline for you - extra loving hands, family stories, and roots. The familiarity of family, even in a new place, keeps him settled.',
    consider: 'Agree gently on routines and rules in advance so love does not tip into too much.',
    bestFor: 'Staying close to family.',
    skills: ['Social connection'], benefits: ['Belonging', 'Parent support'],
    collections: ['travel'], tags: ['travel', 'family', 'grandparents', 'city', 'indian'],
    subtype: 'Destination', facets: {'kind': ['destination'], 'setting': ['city']},
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
    subtype: 'Cafe', facets: {'kind': ['cafe'], 'feature': ['stroller', 'quiet']},
  ),
  RecoItem(
    id: 'rs_family', category: 'Restaurants', title: 'A relaxed family restaurant', summary: 'High chairs and no side-eye.',
    ageMin: 6, ageMax: 60, seed: 65, pvRating: 4.3, communityLoves: 560,
    why: 'A genuinely family-friendly restaurant - high chairs on hand, unfussed staff, a bit of noise already in the air - lets you actually enjoy a meal out without bracing for every squeak.',
    consider: 'Bring a couple of quiet toys and order early; a hungry wait is where outings unravel.',
    bestFor: 'A proper meal out, together.',
    skills: [], benefits: ['Parent wellbeing'],
    collections: ['weekend'], tags: ['restaurant', 'family', 'outing', 'weekend'],
    subtype: 'Family restaurant', facets: {'kind': ['family'], 'feature': ['highchairs']},
  ),
  RecoItem(
    id: 'rs_outdoor', category: 'Restaurants', title: 'An open-air garden eatery', summary: 'Fresh air and room to roam.',
    ageMin: 12, ageMax: 60, seed: 66, pvRating: 4.3, communityLoves: 480,
    why: 'An outdoor spot with a bit of lawn means a toddler can toddle between bites and the open air softens the noise for everyone - far more forgiving than a hushed indoor room.',
    consider: 'Check for shade and that the space is safely fenced from roads or water.',
    bestFor: 'Restless toddlers who need to move.',
    skills: [], benefits: ['Parent wellbeing'],
    collections: ['weekend'], tags: ['restaurant', 'outdoor', 'garden', 'outing'],
    subtype: 'Outdoor eatery', facets: {'kind': ['outdoor'], 'feature': ['play']},
  ),
  RecoItem(
    id: 'rs_quietbrunch', category: 'Restaurants', title: 'A quiet weekday brunch spot', summary: 'Calm hours, gentle crowd.',
    ageMin: 0, ageMax: 36, seed: 67, pvRating: 4.4, communityLoves: 510,
    why: 'A calm cafe on a weekday morning - after the rush, before lunch - is about the easiest outing there is: space, quiet, and a good chance he naps in the carrier while you finally sit.',
    consider: 'Weekday mid-morning is the sweet spot; weekends undo all the calm.',
    bestFor: 'A gentle solo-parent outing.',
    skills: [], benefits: ['Parent wellbeing'],
    collections: [], tags: ['restaurant', 'brunch', 'quiet', 'cafe'],
    subtype: 'Quiet cafe', facets: {'kind': ['cafe'], 'feature': ['quiet', 'stroller']},
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
    subtype: 'Party plan', facets: {'kind': ['party']},
  ),
  RecoItem(
    id: 'bd_keepsake', category: 'Birthday Ideas', title: 'A first-year keepsake', summary: 'Capture the year, not just the day.',
    ageMin: 9, ageMax: 15, seed: 29, pvRating: 4.6, communityLoves: 890,
    why: 'A hand-print, a letter to his future self, or a little storybook of his first year is the gift that lasts. ParentVeda\'s Journal can turn your photos into exactly this.',
    consider: 'Do it before the day so you are present at the party, not behind a camera.',
    bestFor: 'Sentimental parents.',
    skills: [], benefits: ['Memory keeping'],
    collections: ['firstbday'], tags: ['birthday', 'keepsake', 'journal', 'memory'],
    subtype: 'Keepsake', facets: {'kind': ['keepsake']},
  ),
  RecoItem(
    id: 'bd_decor', category: 'Birthday Ideas', title: 'Gentle DIY decor', summary: 'Soft, non-plastic, and personal.',
    ageMin: 9, ageMax: 24, seed: 68, pvRating: 4.4, communityLoves: 620,
    why: 'A few paper garlands, fresh flowers and a fabric backdrop feel warmer than a pile of balloons - and are kinder to the planet and to his lungs. Homemade always photographs with more heart, too.',
    consider: 'Skip foil balloons and confetti near a baby who mouths everything; keep small pieces well out of reach.',
    bestFor: 'A cosy at-home celebration.',
    skills: [], benefits: ['Belonging'],
    collections: ['firstbday'], tags: ['birthday', 'decor', 'diy', 'party'],
    subtype: 'Decor', facets: {'kind': ['decor']},
  ),
  RecoItem(
    id: 'bd_cake', category: 'Birthday Ideas', title: 'A mindful smash cake', summary: 'A first taste, not a sugar rush.',
    ageMin: 9, ageMax: 15, seed: 69, pvRating: 4.3, communityLoves: 540,
    why: 'A small, lightly-sweetened cake - or a fruit-and-yoghurt version - lets him have the joyful "smash" moment without a big sugar hit his system is not ready for. The photos are just as gorgeous.',
    consider: 'Keep added sugar minimal under one year, and watch for any first-time ingredient reactions.',
    bestFor: 'The cake-smash moment.',
    skills: [], benefits: ['Joy'],
    collections: ['firstbday'], tags: ['birthday', 'cake', 'smash cake', 'food'],
    subtype: 'Cake', facets: {'kind': ['cake']},
  ),
  RecoItem(
    id: 'bd_returngifts', category: 'Birthday Ideas', title: 'Meaningful return gifts', summary: 'Little things that are actually used.',
    ageMin: 9, ageMax: 60, seed: 70, pvRating: 4.3, communityLoves: 470, indian: true,
    why: 'A small plant, a story book or a packet of seeds beats another plastic trinket - a return gift that does not end up in the bin the next morning, and quietly models a gentler kind of celebration.',
    consider: 'Match the gift to the guests\' ages; keep anything tiny away from the babies in the room.',
    bestFor: 'Thoughtful party hosts.',
    skills: [], benefits: ['Belonging'],
    collections: ['firstbday'], tags: ['birthday', 'return gifts', 'party', 'indian'],
    subtype: 'Return gifts', facets: {'kind': ['gifts']},
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
    subtype: 'Language habit', facets: {'kind': ['language'], 'format': ['habit']},
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
    subtype: 'Signing', facets: {'kind': ['signing'], 'format': ['routine']},
  ),
  RecoItem(
    id: 'ln_flashcards', category: 'Learning', title: 'First-words picture cards', summary: 'Everyday things, one clear image each.',
    ageMin: 6, ageMax: 24, seed: 71, pvRating: 4.3, communityLoves: 890, indian: true,
    why: 'A small set of bilingual picture cards - fruit, animals, home things - is a lovely naming game. Keep it playful and slow, and let him lead which cards he lingers on.',
    consider: 'Cards are for shared play, not drilling; never test or push. Real objects beat pictures every time.',
    bestFor: 'Playful naming games.',
    skills: ['Language', 'Vocabulary'], benefits: ['Language'],
    collections: [], tags: ['flashcards', 'first words', 'language', 'indian'],
    subtype: 'Flashcards', facets: {'kind': ['language'], 'format': ['flashcards']},
  ),
  RecoItem(
    id: 'ln_counting', category: 'Learning', title: 'Counting in everyday moments', summary: 'Numbers, woven into the day.',
    ageMin: 12, ageMax: 36, seed: 72, pvRating: 4.4, communityLoves: 760,
    why: 'Counting the stairs as you climb, or the grapes on his plate, plants the earliest sense of number in the most natural way - real, useful maths long before any worksheet.',
    consider: 'It is about the rhythm and words of counting now, not "correct" answers; keep it light.',
    bestFor: 'The busy toddler months.',
    skills: ['Numeracy', 'Language'], benefits: ['Cognitive', 'Language'],
    collections: ['montessori'], tags: ['counting', 'numbers', 'maths', 'learning', 'free'],
    subtype: 'Number habit', facets: {'kind': ['numbers'], 'format': ['habit']},
  ),
  RecoItem(
    id: 'ln_musiclearn', category: 'Learning', title: 'Learning through song', summary: 'The tune that teaches the words.',
    ageMin: 0, ageMax: 24, seed: 73, pvRating: 4.5, communityLoves: 980,
    why: 'Songs are how tiny children learn best - melody and rhyme make words stick, and the actions add memory and movement. A sung "clean-up" or "bath-time" turns a routine into learning.',
    consider: 'Repeat the same few songs; the familiarity is exactly what makes them powerful.',
    bestFor: 'Turning routines into rituals.',
    skills: ['Language', 'Rhythm', 'Memory'], benefits: ['Language', 'Bonding'],
    collections: ['music'], tags: ['song', 'music', 'learning', 'routine'],
    subtype: 'Song routine', facets: {'kind': ['music'], 'format': ['routine']},
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

    // Personalization engine (Level 2): the family's EXPLICIT priorities + health
    // conditions count as interests, so matching items rank higher. This only
    // re-orders/surfaces — nothing is ever hidden or removed.
    final fp = FamilyProfileStore.instance;
    for (final k in fp.recoBoosts().keys) {
      addWords(k);
    }
    for (final c in fp.conditions) {
      addWords(c.label);
    }
    for (final pr in fp.priorities) {
      addWords(pr.label);
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

// ---- Brand Product 5 · featured recommendations -----------------------------
//
// Note where this lives: AFTER _ranked, never inside _score. _score has no
// commercial term and must never grow one — the moment money is an input to
// merit, "better" and "paying" become the same word and no amount of labelling
// repairs it. A sponsored item earns its slot at its real score; sponsorship
// only buys the right to be CONSIDERED. See lib/brand/rank_floor.dart.

/// The reco item a live campaign has featured, if any — and only if it clears
/// the quality floor on its own merits.
RecoItem? _featuredItem() {
  try {
    final c = BrandStudio.instance.resolve(
      BrandSlot.recoFeatured,
      captureBrandContext(stage: BrandStage.parenting),
    );
    if (c == null) return null;
    final id = c.placementKey;
    if (id == null) return null;
    for (final r in kReco) {
      // A product we would not recommend unpaid cannot be bought in at any
      // price. Sponsorship buys consideration, not entry.
      if (r.id == id) return clearsQualityFloor(r.pvRating) ? r : null;
    }
  } catch (_) {/* no feature */}
  return null;
}

/// The id of the currently featured reco, for the UI to label. Null is normal.
///
/// Exposed so a card can render its SPONSORED tag on the item itself rather
/// than in a legend somewhere above it.
String? featuredRecoId() => _featuredItem()?.id;

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

  final promo = _featuredItem();
  if (promo == null) return out;
  return insertWithRankFloor<RecoItem>(
    organic: out,
    promo: promo,
    scoreOf: (r) => _score(r, ctx),
    isSame: (a, b) => a.id == b.id,
  );
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
