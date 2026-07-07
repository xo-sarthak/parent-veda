// =============================================================================
//  Baby Name Finder - data + shared match store (parenting · S27)
// -----------------------------------------------------------------------------
//  A small catalogue of names that backs the whole Name Finder flow (quiz →
//  swipe deck → name detail → matches). Kept in the post_pregnancy module so it
//  stays isolated from the pregnancy app. Aarav carries the fully-authored
//  detail from the Claude Design mock; the rest are lighter but complete enough
//  that every screen reads real data - nothing on these screens is static.
// =============================================================================

import 'package:flutter/foundation.dart';

/// One baby name and everything the detail/swipe/match screens show for it.
class BabyName {
  const BabyName({
    required this.name,
    required this.script,
    required this.pron,
    required this.meaningShort,
    required this.meaningFull,
    required this.feel,
    required this.origin,
    required this.syllables,
    required this.numerology,
    required this.perspective,
    required this.famous,
    required this.nakshatra,
    required this.popularity,
    this.blend,
    this.similar = const [],
    this.rare = false,
    this.mutual = false,
  });

  final String name; // "Aarav"
  final String script; // Devanagari - "आरव"
  final String pron; // "aa-rav"
  final String meaningShort; // one-line gloss used on cards/lists
  final String meaningFull; // fuller quote on the detail hero
  final String feel; // "Rooted · Sanskrit" pill on the swipe card
  final String origin; // "Sanskrit" fact tile
  final int syllables;
  final int numerology; // Chaldean, offered as tradition (not a claim)
  final String perspective; // "The ParentVeda perspective" paragraph
  final String famous; // famous / mythological reference (Section 7)
  final String nakshatra; // nakshatra / rashi fit - offered as tradition, not fact
  final String popularity; // Trending / Classic / Rare (popularity trend)
  final String? blend; // optional "blend of Ravi + Deepti" note
  final List<(String, String)> similar; // (name, gloss)
  final bool rare;
  final bool mutual; // true → liking it in the deck triggers "It's a match!"
}

// The deck. Boy names (the mock's quiz picks "Boy"); Aarav is the hero.
const List<BabyName> kBabyNames = [
  BabyName(
    name: 'Aarav',
    famous:
        "No single mythic bearer - its charm is the sound itself, close to 'ravi' (the sun) and the soft hum of music. A name parents choose for its feeling, not its lore.",
    nakshatra: "Fits the 'A' sound - Ashwini, Bharani or Krittika nakshatra.",
    popularity: 'Trending',
    script: 'आरव',
    pron: 'aa-rav',
    meaningShort: 'Peaceful; the calm sound of music.',
    meaningFull: 'Peaceful - the calm, pleasant sound of music.',
    feel: 'Rooted · Sanskrit',
    origin: 'Sanskrit',
    syllables: 2,
    numerology: 5,
    blend: 'blend of Ravi + Deepti',
    perspective:
        "Once rare, Aarav has become one of India's most-loved modern names of the last decade - traditional in root, yet fresh on the tongue. It carries a gentle, musical softness that works beautifully across regions.",
    similar: [
      ('Aarush', 'first light'),
      ('Vihaan', 'dawn'),
      ('Reyansh', 'ray of light'),
    ],
  ),
  BabyName(
    name: 'Vihaan',
    famous:
        'Rooted in the Sanskrit for daybreak. A fresh, modern pick rather than a mythological name - it carries the feeling of a new beginning.',
    nakshatra: "Fits the 'V' / 'Vee' sound - Poorvashada or Uttarashada nakshatra.",
    popularity: 'Trending',
    script: 'विहान',
    pron: 'vi-haan',
    meaningShort: 'Dawn, the first ray of light.',
    meaningFull: 'Dawn - the first ray of light, the beginning of a new day.',
    feel: 'Modern · Sanskrit',
    origin: 'Sanskrit',
    syllables: 2,
    numerology: 8,
    perspective:
        'Vihaan pairs a bright, hopeful meaning with an easy, modern sound. Popular yet timeless, it travels well across languages and rarely gets shortened.',
    similar: [
      ('Vivaan', 'full of life'),
      ('Aarav', 'peaceful'),
      ('Reyansh', 'ray of light'),
    ],
    mutual: true,
  ),
  BabyName(
    name: 'Reyansh',
    famous:
        "A newer coinage - 'Reyan' + 'ansh', a ray or part of the sun. No ancient bearer; all contemporary shine, which is exactly its appeal.",
    nakshatra: "Fits the 'Re' sound - Rohini nakshatra.",
    popularity: 'Trending',
    script: 'रेयांश',
    pron: 'rey-aansh',
    meaningShort: 'A ray of light; part of the sun.',
    meaningFull: 'A ray of light - a small, radiant part of the sun.',
    feel: 'Modern · Sanskrit',
    origin: 'Sanskrit',
    syllables: 3,
    numerology: 1,
    perspective:
        'Reyansh has climbed fast among new parents for its luminous meaning and contemporary feel. Distinctive without being hard to say.',
    similar: [
      ('Reyaan', 'little king'),
      ('Vihaan', 'dawn'),
      ('Aarush', 'first light'),
    ],
    mutual: true,
  ),
  BabyName(
    name: 'Kabir',
    famous:
        'Carried by Sant Kabir, the 15th-century mystic poet-saint whose dohe are loved across faiths - a name with genuine literary and devotional weight.',
    nakshatra: "Fits the 'Ka' / 'Ki' sound - Punarvasu or Pushya nakshatra.",
    popularity: 'Classic',
    script: 'कबीर',
    pron: 'ka-beer',
    meaningShort: 'Great, noble - after the mystic poet-saint.',
    meaningFull: 'Great and noble - carried by Kabir, the beloved 15th-century mystic poet-saint.',
    feel: 'Rooted · Devotional',
    origin: 'Arabic · Sant tradition',
    syllables: 2,
    numerology: 3,
    perspective:
        'Kabir crosses communities gracefully and carries a rich literary, devotional legacy. Short, dignified, and instantly recognisable.',
    similar: [
      ('Kavya', 'poetry'),
      ('Arjun', 'bright'),
      ('Aarav', 'peaceful'),
    ],
    mutual: true,
  ),
  BabyName(
    name: 'Aarush',
    famous:
        'A gentle Sanskrit word for the first red light of dawn - a soft, modern cousin of Aarav rather than a name from the epics.',
    nakshatra: "Fits the 'A' sound - Ashwini or Bharani nakshatra.",
    popularity: 'Classic',
    script: 'आरुष',
    pron: 'aa-rush',
    meaningShort: 'The first rays of the sun.',
    meaningFull: 'The first rays of the sun - calm, red light at daybreak.',
    feel: 'Modern · Sanskrit',
    origin: 'Sanskrit',
    syllables: 2,
    numerology: 6,
    perspective:
        'A close cousin of Aarav with the same dawn-light warmth. Soft, easy to spell, and gentle to say.',
    similar: [
      ('Aarav', 'peaceful'),
      ('Vihaan', 'dawn'),
      ('Reyansh', 'ray of light'),
    ],
  ),
  BabyName(
    name: 'Ishaan',
    famous:
        'One of the names of Lord Shiva, guardian of the north-east (Ishanya) direction - strong roots, yet an easy modern sound.',
    nakshatra: "Fits the 'Ee' / 'I' sound - Revati or Ashwini nakshatra.",
    popularity: 'Classic',
    script: 'ईशान',
    pron: 'ee-shaan',
    meaningShort: 'The sun; a name of Lord Shiva.',
    meaningFull: 'The sun - and one of the names of Lord Shiva, guardian of the north-east.',
    feel: 'Rooted · Sanskrit',
    origin: 'Sanskrit',
    syllables: 2,
    numerology: 7,
    perspective:
        'Ishaan blends a strong devotional root with a clean, modern sound. Familiar across India yet never overused.',
    similar: [
      ('Ishir', 'refreshing'),
      ('Arjun', 'bright'),
      ('Aarav', 'peaceful'),
    ],
  ),
  BabyName(
    name: 'Advait',
    famous:
        'From Advaita Vedanta - the philosophy of non-duality taught by Adi Shankaracharya. A whole idea folded into three syllables.',
    nakshatra: "Fits the 'A' sound - Ashwini or Bharani nakshatra.",
    popularity: 'Rare',
    script: 'अद्वैत',
    pron: 'ad-vait',
    meaningShort: 'Unique; oneness, non-duality.',
    meaningFull: 'Unique - the philosophical idea of oneness, that all is non-dual.',
    feel: 'Rare · Sanskrit',
    origin: 'Sanskrit',
    syllables: 2,
    numerology: 9,
    perspective:
        'For parents drawn to depth, Advait carries a whole Vedantic idea in three syllables. Rare, thoughtful, and increasingly loved.',
    similar: [
      ('Advik', 'unique'),
      ('Arnav', 'ocean'),
      ('Ishaan', 'the sun'),
    ],
    rare: true,
  ),
  BabyName(
    name: 'Vivaan',
    famous:
        'A modern Sanskrit name for the morning rays, popularised by contemporary parents rather than myth. A natural pair with Vihaan.',
    nakshatra: "Fits the 'V' sound - Poorvashada nakshatra.",
    popularity: 'Trending',
    script: 'विवान',
    pron: 'vi-vaan',
    meaningShort: 'Full of life; rays of the morning sun.',
    meaningFull: 'Full of life - the first rays of the morning sun.',
    feel: 'Modern · Sanskrit',
    origin: 'Sanskrit',
    syllables: 2,
    numerology: 4,
    perspective:
        'Vivaan is lively and bright, a favourite for its upbeat meaning and effortless sound. A natural pair with Vihaan.',
    similar: [
      ('Vihaan', 'dawn'),
      ('Reyansh', 'ray of light'),
      ('Aarav', 'peaceful'),
    ],
  ),
  BabyName(
    name: 'Arjun',
    famous:
        "The peerless archer of the Mahabharata - Krishna's friend and the seeker to whom the Bhagavad Gita is spoken. Few names carry a bigger story.",
    nakshatra: "Fits the 'A' sound - Ashwini, Bharani or Krittika nakshatra.",
    popularity: 'Classic',
    script: 'अर्जुन',
    pron: 'ar-jun',
    meaningShort: 'Bright, shining; the great archer.',
    meaningFull: 'Bright and shining - carried by Arjun, the peerless archer of the Mahabharata.',
    feel: 'Rooted · Devotional',
    origin: 'Sanskrit · Epic',
    syllables: 2,
    numerology: 2,
    perspective:
        'Arjun is strong, classic, and pan-Indian, with a hero of the epics behind it. Timeless without feeling old-fashioned.',
    similar: [
      ('Aryan', 'noble'),
      ('Kabir', 'noble'),
      ('Ishaan', 'the sun'),
    ],
  ),
];

/// Lookup by name (used by detail/similar links). Falls back to Aarav.
BabyName babyNameByName(String name) =>
    kBabyNames.firstWhere((n) => n.name == name, orElse: () => kBabyNames.first);

// -----------------------------------------------------------------------------
//  Shared match store - the names both parents have said yes to.
// -----------------------------------------------------------------------------
//  A plain ChangeNotifier singleton (same pattern as PpCompareStore). Seeded
//  with the mock's "you both love" set so the matches screen always reads right;
//  liking a name in the swipe deck adds to it, and tapping a name in the list
//  crowns it. In-memory only - no persistence wired yet.
class NameMatchStore extends ChangeNotifier {
  NameMatchStore._();
  static final NameMatchStore instance = NameMatchStore._();

  final List<String> _liked = ['Aarav', 'Vihaan', 'Reyansh', 'Kabir', 'Ishaan', 'Arjun'];
  String _crowned = 'Aarav';

  List<String> get liked => List.unmodifiable(_liked);
  int get matchedCount => _liked.length;
  String get crowned => _crowned;

  bool isLiked(String name) => _liked.contains(name);

  void like(String name) {
    if (!_liked.contains(name)) {
      _liked.add(name);
      notifyListeners();
    }
  }

  void crown(String name) {
    _crowned = name;
    if (!_liked.contains(name)) _liked.add(name);
    notifyListeners();
  }
}
