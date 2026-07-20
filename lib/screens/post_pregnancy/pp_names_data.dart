// =============================================================================
//  Baby Name Finder - data + shared match store (parenting · S27)
// -----------------------------------------------------------------------------
//  A small catalogue of names that backs the whole Name Finder flow (quiz →
//  swipe deck → name detail → matches). Kept in the post_pregnancy module so it
//  stays isolated from the pregnancy app. Aarav carries the fully-authored
//  detail from the Claude Design mock; the rest are lighter but complete enough
//  that every screen reads real data - nothing on these screens is static.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/cloud_synced_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';

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
    this.gender = 'boy', // 'boy' | 'girl' | 'unisex'
    this.community = 'Hindu', // Hindu | Muslim | Sikh | Christian | Secular
    this.region = 'Pan-India', // Pan-India | North | South | East | West
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
  final String gender; // who the name is for
  final String community; // religion / tradition, for the region-religion filter
  final String region; // regional flavour, for the region filter
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

  // ---- Girls & wider communities (for the who-are-we-naming filter) ---------
  BabyName(
    name: 'Anaya', gender: 'girl', community: 'Hindu', region: 'Pan-India',
    script: 'अनाया', pron: 'a-naa-ya',
    meaningShort: 'Caring; without a superior.',
    meaningFull: 'Caring and compassionate - and "without a superior", wholly free.',
    feel: 'Modern · Feminine', origin: 'Sanskrit', syllables: 3, numerology: 6,
    perspective: 'Anaya is soft, modern and widely loved, with a gentle meaning of care. Easy across languages and rarely shortened.',
    famous: 'A contemporary favourite rather than a mythological name - chosen for its softness and warmth.',
    nakshatra: "Fits the 'A' sound - Ashwini or Bharani nakshatra.",
    popularity: 'Trending',
    similar: [('Aadhya', 'first power'), ('Ira', 'earth'), ('Saanvi', 'goddess')],
  ),
  BabyName(
    name: 'Aadhya', gender: 'girl', community: 'Hindu', region: 'South',
    script: 'अद्या', pron: 'aa-dhya',
    meaningShort: 'The first power; the Goddess.',
    meaningFull: 'The first, the beginning - a name of the Goddess, the primordial power.',
    feel: 'Rooted · Devotional', origin: 'Sanskrit', syllables: 3, numerology: 7,
    perspective: 'Aadhya carries devotional depth with a fresh sound. A top pick for its meaning of beginnings.',
    famous: 'A name of Adi Shakti, the primordial Goddess - "the first".',
    nakshatra: "Fits the 'A' sound - Ashwini or Krittika nakshatra.",
    popularity: 'Trending',
    similar: [('Anaya', 'caring'), ('Saanvi', 'goddess'), ('Ira', 'earth')],
  ),
  BabyName(
    name: 'Ira', gender: 'girl', community: 'Hindu', region: 'Pan-India',
    script: 'ईरा', pron: 'ee-ra',
    meaningShort: 'The earth; Goddess Saraswati.',
    meaningFull: 'The earth - and a name of Saraswati, goddess of learning.',
    feel: 'Rooted · Sanskrit', origin: 'Sanskrit', syllables: 2, numerology: 1,
    perspective: 'Ira is short, timeless and cross-cultural, with a lovely Saraswati association. Two letters, endless warmth.',
    famous: 'A name of Saraswati; also found across cultures, from Sanskrit to Hebrew.',
    nakshatra: "Fits the 'Ee'/'I' sound - Revati or Ashwini nakshatra.",
    popularity: 'Classic',
    similar: [('Myra', 'beloved'), ('Anaya', 'caring'), ('Kiara', 'first ray')],
  ),
  BabyName(
    name: 'Myra', gender: 'girl', community: 'Secular', region: 'Pan-India',
    script: 'मायरा', pron: 'my-ra',
    meaningShort: 'Beloved; sweetly scented.',
    meaningFull: 'Beloved and sweetly scented - soft, modern, and easy everywhere.',
    feel: 'Modern · Feminine', origin: 'Latin · Sanskrit', syllables: 2, numerology: 5,
    perspective: 'Myra bridges cultures effortlessly - familiar in India and abroad. Gentle, current, and simple to say.',
    famous: 'A modern favourite with roots in both Latin ("beloved") and the Sanskrit "Meera".',
    nakshatra: "Fits the 'Ma'/'Mi' sound - Magha or Ashlesha nakshatra.",
    popularity: 'Trending',
    similar: [('Ira', 'earth'), ('Kiara', 'first ray'), ('Anaya', 'caring')],
  ),
  BabyName(
    name: 'Saanvi', gender: 'girl', community: 'Hindu', region: 'South',
    script: 'सान्वी', pron: 'saan-vi',
    meaningShort: 'Goddess Lakshmi; kind.',
    meaningFull: 'A name of Lakshmi, goddess of fortune - gentle and kind.',
    feel: 'Rooted · Devotional', origin: 'Sanskrit', syllables: 2, numerology: 3,
    perspective: 'Saanvi has soared in popularity for its Lakshmi association and soft sound. Auspicious and modern at once.',
    famous: 'A name of Goddess Lakshmi.',
    nakshatra: "Fits the 'Sa' sound - Pushya or Uttarabhadra nakshatra.",
    popularity: 'Trending',
    similar: [('Aadhya', 'first power'), ('Anaya', 'caring'), ('Ira', 'earth')],
  ),
  BabyName(
    name: 'Zara', gender: 'girl', community: 'Muslim', region: 'North',
    script: 'ज़ारा', pron: 'zaa-ra',
    meaningShort: 'Blooming flower; radiance.',
    meaningFull: 'A blooming flower, and radiance - bright and graceful.',
    feel: 'Modern · Graceful', origin: 'Arabic', syllables: 2, numerology: 8,
    perspective: 'Zara is globally loved and effortlessly elegant, with a bright meaning. Crosses cultures with ease.',
    famous: 'Borne across the Arab world and beyond; associated with blossoming and light.',
    nakshatra: "A soft 'Za' sound; pairs well with a Rohini or Ashlesha star.",
    popularity: 'Trending',
    similar: [('Inaya', 'grace'), ('Myra', 'beloved'), ('Aria', 'melody')],
  ),
  BabyName(
    name: 'Inaya', gender: 'girl', community: 'Muslim', region: 'North',
    script: 'इनाया', pron: 'i-naa-ya',
    meaningShort: "God's grace; care.",
    meaningFull: 'Care, concern and the grace of God - tender and warm.',
    feel: 'Rooted · Graceful', origin: 'Arabic', syllables: 3, numerology: 2,
    perspective: 'Inaya pairs a beautiful meaning of grace with a soft, modern sound. Increasingly chosen and easy to love.',
    famous: 'From the Arabic for care and divine grace.',
    nakshatra: "A gentle 'I' sound; sits well with a Revati star.",
    popularity: 'Trending',
    similar: [('Zara', 'radiance'), ('Anaya', 'caring'), ('Ayaan', 'gift of God')],
  ),
  BabyName(
    name: 'Ayaan', gender: 'boy', community: 'Muslim', region: 'North',
    script: 'अयान', pron: 'a-yaan',
    meaningShort: 'Gift of God; a time of prosperity.',
    meaningFull: 'A gift of God, and a time of prosperity - hopeful and bright.',
    feel: 'Modern · Graceful', origin: 'Arabic · Persian', syllables: 2, numerology: 4,
    perspective: 'Ayaan is warm, modern and widely loved across communities. A hopeful meaning with an easy sound.',
    famous: 'From Arabic/Persian roots meaning a gift of God and a time of prosperity.',
    nakshatra: "A bright 'A' sound; pairs with an Ashwini star.",
    popularity: 'Trending',
    similar: [('Kabir', 'noble'), ('Aarav', 'peaceful'), ('Ishaan', 'the sun')],
  ),
  BabyName(
    name: 'Gurleen', gender: 'girl', community: 'Sikh', region: 'North',
    script: 'गुरलीन', pron: 'gur-leen',
    meaningShort: 'Absorbed in the Guru.',
    meaningFull: 'One absorbed in the Guru - devotion and serenity.',
    feel: 'Rooted · Devotional', origin: 'Punjabi · Sikh', syllables: 2, numerology: 9,
    perspective: 'Gurleen carries gentle Sikh devotion and a melodic sound. Beloved in Punjabi families and beyond.',
    famous: 'A cherished Sikh name expressing absorption in the Guru.',
    nakshatra: "A soft 'Gu' sound; sits well with a Pushya star.",
    popularity: 'Classic',
    similar: [('Ekam', 'oneness'), ('Saanvi', 'goddess'), ('Anaya', 'caring')],
  ),
  BabyName(
    name: 'Ekam', gender: 'unisex', community: 'Sikh', region: 'North',
    script: 'एकम', pron: 'ay-kam',
    meaningShort: 'One; oneness with God.',
    meaningFull: 'One - the oneness of the divine, from Ik Onkar.',
    feel: 'Rare · Devotional', origin: 'Punjabi · Sikh', syllables: 2, numerology: 1,
    perspective: 'Ekam is spare and profound, echoing Ik Onkar. Modern, unisex, and quietly powerful.',
    famous: 'Rooted in "Ik Onkar" - the oneness of God in Sikhi.',
    nakshatra: "A clear 'E'/'A' sound; pairs with an Ashwini star.",
    popularity: 'Rare', rare: true,
    similar: [('Gurleen', 'absorbed in the Guru'), ('Advait', 'oneness'), ('Ira', 'earth')],
  ),
  BabyName(
    name: 'Aria', gender: 'girl', community: 'Christian', region: 'Pan-India',
    script: 'आरिया', pron: 'aa-ri-ya',
    meaningShort: 'A melody; air.',
    meaningFull: 'A melody, a solo song - and "air". Lyrical and light.',
    feel: 'Modern · Melodic', origin: 'Italian · Sanskrit', syllables: 3, numerology: 6,
    perspective: 'Aria is musical and international, at home in many cultures. Soft, current, and simple to spell.',
    famous: 'A musical term ("aria") for a solo song; also linked to the Sanskrit "Arya".',
    nakshatra: "A bright 'A' sound; pairs with an Ashwini star.",
    popularity: 'Trending',
    similar: [('Myra', 'beloved'), ('Kiara', 'first ray'), ('Zara', 'radiance')],
  ),
  BabyName(
    name: 'Kiara', gender: 'girl', community: 'Secular', region: 'Pan-India',
    script: 'कियारा', pron: 'ki-aa-ra',
    meaningShort: 'First ray of sun; bright.',
    meaningFull: 'The first ray of the sun - bright, warm and modern.',
    feel: 'Modern · Feminine', origin: 'Italian · Sanskrit', syllables: 3, numerology: 5,
    perspective: 'Kiara is bright and globally loved, blending Italian and Indian roots. Effortlessly modern.',
    famous: 'From Italian "chiara" (bright/clear) and Sanskrit associations with light.',
    nakshatra: "Fits the 'Ki' sound - Pushya nakshatra.",
    popularity: 'Trending',
    similar: [('Myra', 'beloved'), ('Aria', 'melody'), ('Ira', 'earth')],
  ),
];

/// Lookup by name (used by detail/similar links). Falls back to Aarav.
BabyName babyNameByName(String name) =>
    kBabyNames.firstWhere((n) => n.name == name, orElse: () => kBabyNames.first);

// -----------------------------------------------------------------------------
//  Filter options + query for the "who are we naming" step.
// -----------------------------------------------------------------------------
const List<String> kNameGenders = ['Boy', 'Girl', 'Both'];
const List<String> kNameCommunities = ['Any', 'Hindu', 'Muslim', 'Sikh', 'Christian', 'Secular'];
const List<String> kNameRegions = ['Any', 'Pan-India', 'North', 'South', 'East', 'West'];

/// The catalogue filtered by who the parents are naming + region/religion.
/// 'Both' includes unisex; 'Any' region/community is unrestricted.
List<BabyName> namesFiltered({String gender = 'Both', String community = 'Any', String region = 'Any'}) {
  return kBabyNames.where((n) {
    final g = gender == 'Both' ||
        (gender == 'Boy' && (n.gender == 'boy' || n.gender == 'unisex')) ||
        (gender == 'Girl' && (n.gender == 'girl' || n.gender == 'unisex'));
    final c = community == 'Any' || n.community == community;
    final r = region == 'Any' || n.region == region;
    return g && c && r;
  }).toList();
}

// -----------------------------------------------------------------------------
//  Numerology (Chaldean) - each number maps to a ruling planet and a vibe.
//  Powers BOTH the Astrology page (ruling planet, lucky day/colour/element,
//  nakshatra fit) and the Numerology page (number, traits). Offered as gentle
//  tradition, never a claim.
// -----------------------------------------------------------------------------
class NumProfile {
  const NumProfile(this.number, this.planet, this.vibe, this.traits, this.luckyDay, this.luckyColour, this.element, this.blurb);
  final int number;
  final String planet;
  final String vibe; // one word
  final String traits; // comma phrase
  final String luckyDay;
  final String luckyColour;
  final String element;
  final String blurb; // a friendly paragraph for the numerology page
}

const Map<int, NumProfile> kNumerology = {
  1: NumProfile(1, 'Sun', 'Leadership', 'independent, original, a natural leader', 'Sunday', 'Gold & amber', 'Fire',
      'Ones are born to lead. The number carries the Sun\'s confidence and originality - a child who likes to do things their own way, and often first.'),
  2: NumProfile(2, 'Moon', 'Gentleness', 'sensitive, intuitive, gentle, cooperative', 'Monday', 'White & cream', 'Water',
      'Twos carry the Moon\'s softness - tender, intuitive and deeply caring. A peacemaker who feels the world keenly and brings people together.'),
  3: NumProfile(3, 'Jupiter', 'Expression', 'expressive, joyful, creative, wise', 'Thursday', 'Yellow', 'Ether',
      'Threes shine with Jupiter\'s warmth - joyful, expressive and quick to learn. A child who loves words, laughter and colour.'),
  4: NumProfile(4, 'Rahu', 'Steadiness', 'grounded, practical, hard-working, original', 'Wednesday', 'Grey & soft blue', 'Air',
      'Fours are the steady builders - practical, patient and quietly unconventional. They value structure and finish what they start.'),
  5: NumProfile(5, 'Mercury', 'Curiosity', 'quick, adaptable, communicative, free-spirited', 'Wednesday', 'Green', 'Air',
      'Fives dance to Mercury\'s quick step - curious, adaptable and charming. A free spirit who loves variety and a good conversation.'),
  6: NumProfile(6, 'Venus', 'Warmth', 'loving, harmonious, artistic, nurturing', 'Friday', 'Pink & white', 'Water',
      'Sixes glow with Venus\'s warmth - loving, harmonious and drawn to beauty. A natural nurturer who makes any room feel like home.'),
  7: NumProfile(7, 'Ketu', 'Depth', 'thoughtful, spiritual, introspective, wise', 'Monday', 'Sea-green', 'Water',
      'Sevens carry Ketu\'s quiet depth - thoughtful, intuitive and old-souled. A child who wonders about everything and feels things deeply.'),
  8: NumProfile(8, 'Saturn', 'Resolve', 'determined, disciplined, ambitious, enduring', 'Saturday', 'Deep blue & black', 'Earth',
      'Eights hold Saturn\'s resolve - determined, disciplined and built for the long game. Strong-willed, fair, and quietly powerful.'),
  9: NumProfile(9, 'Mars', 'Courage', 'brave, energetic, passionate, protective', 'Tuesday', 'Red & coral', 'Fire',
      'Nines burn with Mars\'s courage - brave, passionate and protective of those they love. A born champion with a big, warm heart.'),
};

NumProfile numProfile(int n) => kNumerology[((n - 1) % 9) + 1] ?? kNumerology[1]!;

// -----------------------------------------------------------------------------
//  Shared match store - the names both parents have said yes to.
// -----------------------------------------------------------------------------
//  A plain ChangeNotifier singleton (same pattern as PpCompareStore). Seeded
//  with the mock's "you both love" set so the matches screen always reads right;
//  liking a name in the swipe deck adds to it, and tapping a name in the list
//  crowns it. In-memory only - no persistence wired yet.
class NameMatchStore extends ChangeNotifier with CloudSyncedStore {
  NameMatchStore._();
  static final NameMatchStore instance = NameMatchStore._();

  // EMPTY, not seeded. This used to start as six liked names and a crowned
  // "Aarav". Harmless while likes were private - actively wrong now that both
  // parents' votes are compared: two accounts starting from the SAME six seeded
  // likes would "match" on all six before either parent had swiped once, and
  // the one moment this feature exists for would be a fake.
  final List<String> _liked = [];
  String _crowned = '';

  /// Names BOTH parents have liked, from public.pp_name_matches(). Derived
  /// server-side and never stored - see 0027_pp_name_votes.sql.
  final List<String> _matches = [];

  // ---- persistence (user_state KV; own-only, a personal preference) --------
  static const _prefsKey = 'pp_names';

  @override
  String get cloudKey => _prefsKey;

  // Only the crown rides in the KV blob. LIKES are votes now: they live in
  // pp_name_votes, one row per parent per name, because the partner's side has
  // to be able to count them. Keeping a second copy here would let the two
  // drift, and a match computed from stale likes is worse than no match.
  @override
  Object cloudData() => {'crowned': _crowned};

  @override
  void applyCloudData(Object data) {
    if (data is! Map) return;
    _crowned = (data['crowned'] ?? _crowned).toString();
    // Back-compat: a blob written before votes existed still carries 'liked'.
    // Adopt it once so nobody loses a shortlist; _syncVotes then pushes it up.
    final l = data['liked'];
    if (l is List && _liked.isEmpty) {
      _liked.addAll(l.map((e) => e.toString()));
    }
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(cloudData()));
    } catch (_) {}
  }

  // The mixin's override pushes to the cloud; this keeps the LOCAL cache
  // current too, so an offline/logged-out user still gets persistence. Every
  // mutation already calls notifyListeners(), so one override covers them all.
  @override
  void notifyListeners() {
    super.notifyListeners();
    persistLocalCache();
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) applyCloudData(jsonDecode(raw));
    } catch (_) {/* keep the starter state */}
    notifyListeners();
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
    try {
      await _syncVotes();
    } catch (_) {/* stay local */}
  }

  // ---- votes + matches -----------------------------------------------------
  static const _votesTable = 'pp_name_votes';

  /// Adopt my votes from the cloud, push up anything only this device has, then
  /// refresh the matches. Registered so it re-runs after a login.
  Future<void> _syncVotes() async {
    SyncRegistry.register(_syncVotes);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // Own rows only - RLS forbids reading the partner's, by design.
      final rows = await SupabaseRepo.fetch(_votesTable, orderBy: 'created_at');
      final cloud = <String>{
        for (final r in rows)
          if (r['liked'] == true) (r['name'] ?? '').toString(),
      };
      for (final n in _liked) {
        if (n.isEmpty || cloud.contains(n)) continue;
        cloud.add(n);
        await _pushVote(n, true);
      }
      _liked
        ..clear()
        ..addAll(cloud);
      await _refreshMatches();
      await persistLocalCache();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> _pushVote(String name, bool liked) async {
    if (name.isEmpty || !SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.upsert(
        _votesTable,
        {'name': name, 'liked': liked},
        onConflict: 'user_id,name',
      );
    } catch (_) {/* offline - pushed up on the next sync */}
  }

  /// Ask the database for the intersection. We cannot compute this ourselves:
  /// the partner's votes are unreadable to us, which is the point.
  Future<void> _refreshMatches() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows = await SupabaseRepo.callFunction('pp_name_matches');
      _matches
        ..clear()
        ..addAll(rows.map((e) => e.toString()));
    } catch (_) {/* leave the last known matches */}
  }

  List<String> get liked => List.unmodifiable(_liked);

  /// Names both parents liked. Empty when unpaired, or when nothing overlaps.
  List<String> get matches => List.unmodifiable(_matches);

  /// How many names the two of them AGREE on - the real thing, at last.
  int get matchedCount => _matches.length;

  bool isMatch(String name) => _matches.contains(name);
  /// How many names SHE has liked.
  ///
  /// Named `matchedCount` until 19 July 2026, which is how the UI came to say
  /// "3 names you've BOTH said yes to" while counting one person's likes -
  /// there is no partner concept in this store at all. A mother who liked six
  /// names alone was told her partner had liked all six, and a couple
  /// comparing screens would have found out immediately.
  ///
  /// A real match needs both parents' votes (name_votes, per
  /// docs/BACKEND-COUPLE-NAMING-BRIEF.md §4) and is DERIVED from the
  /// intersection, never stored. Until that lands, the copy says "you like".
  /// When it does, add a separate `matchedCount` reading from the intersection
  /// and restore the "both" language then - do not point it back at this list.
  int get likedCount => _liked.length;
  String get crowned => _crowned;

  bool isLiked(String name) => _liked.contains(name);

  void like(String name) {
    if (_liked.contains(name)) return;
    _liked.add(name);
    notifyListeners();
    _pushVote(name, true).then((_) => _refreshMatches()).then((_) {
      if (_matches.isNotEmpty) notifyListeners();
    });
  }

  /// An explicit "not for me". Recorded (liked = false) so the name is not
  /// offered again, and so a later un-skip is an upsert rather than a new row.
  void skip(String name) {
    if (_liked.remove(name)) notifyListeners();
    _pushVote(name, false);
  }

  void crown(String name) {
    _crowned = name;
    if (!_liked.contains(name)) {
      _liked.add(name);
      _pushVote(name, true);
    }
    notifyListeners();
  }
}
