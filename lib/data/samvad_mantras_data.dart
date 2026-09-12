// =============================================================================
//  Samvad — mantras, blessings and one folk lullaby, to read aloud
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Garbh_Sanskar_pillars_build.pdf`, pillar 2, 12 Sep
//  2026: *"Mantras & lullabies: a set of traditional (public-domain) mantras
//  and lullabies, each with the text, a simple transliteration, and a
//  one-line plain meaning; plus two or three original lullabies. No
//  copyrighted lyrics."*
//
//  ⚠️ EVERY LINE HERE IS OLDER THAN COPYRIGHT, AND SAYS WHERE IT IS FROM.
//  Vedic and Upanishadic verses, Pali from the canon, the opening of the
//  Guru Granth Sahib, the Basmala, the priestly blessing from the King James
//  Bible (1611), and one Hindustani folk lullaby that has no author. Each
//  carries its [source]. Nothing from a film, a record or a living writer —
//  the SHARED rule: *"When in doubt, leave it out."* Two well-known
//  lullabies were left out for exactly that reason; see the foot of the file.
//
//  ⚠️ THE TRANSLITERATION IS WHAT SHE READS ALOUD. The record-first screen
//  shows [transliteration] as the passage, because a mother who reads
//  Devanagari will know the line already and one who does not can still say
//  it. [original] is shown above it, in its script, as the thing itself.
//  The Hindi voice cannot read Arabic or Gurmukhi script, which is the
//  second reason the Latin line is the one that is spoken.
//
//  ⚠️ THE MEANING IS ONE PLAIN LINE, NOT A COMMENTARY. Spiritual reading
//  (`spiritual_reading_data.dart`) deliberately quotes no scripture and
//  reflects instead; this file is the other half of that decision — the
//  lines themselves, with the least interpretation that lets her know what
//  she is saying to her baby.
//
//  ⚠️ MULTI-FAITH BY CONSTRUCTION, LIKE MY RITUAL. Nothing here is
//  recommended over anything else; the shelf is a shelf.
//
//  The original lullabies the brief also asks for already exist — sixteen in
//  `read_to_baby_data.dart` under `kRtbRhymes` — and sit on the same shelf.
// =============================================================================

/// One line to say to the baby, in its own script and in ours.
class SamvadMantra {
  const SamvadMantra({
    required this.id,
    required this.title,
    required this.tradition,
    required this.original,
    required this.transliteration,
    required this.meaning,
    required this.source,
  });

  final String id;

  /// What the shelf calls it — "The Gayatri", "Bismillah".
  final String title;

  /// A plain word for where it comes from — "Vedic", "Buddhist", "Folk".
  final String tradition;

  /// The line in its script.
  final String original;

  /// The line in Latin letters, as it is said.
  final String transliteration;

  /// One plain sentence.
  final String meaning;

  /// The public-domain source, named.
  final String source;

  /// What the record-first screen shows and the narrator speaks.
  String get readAloud => transliteration;

  /// The key a narration manifest would carry a recording under.
  String get narrationKey => 'samvad.mantra_$id';
}

const List<SamvadMantra> kSamvadMantras = [
  SamvadMantra(
    id: 'gayatri',
    title: 'The Gayatri',
    tradition: 'Vedic',
    original: 'ॐ भूर्भुवः स्वः। तत्सवितुर्वरेण्यं। भर्गो देवस्य धीमहि। '
        'धियो यो नः प्रचोदयात्॥',
    transliteration: 'Om bhur bhuvah svah, tat savitur varenyam, bhargo '
        'devasya dhimahi, dhiyo yo nah prachodayat.',
    meaning: 'We hold in mind the light that made the sun; may it brighten '
        'our thoughts.',
    source: 'Rigveda 3.62.10',
  ),
  SamvadMantra(
    id: 'asato_ma',
    title: 'From darkness to light',
    tradition: 'Upanishadic',
    original: 'असतो मा सद्गमय। तमसो मा ज्योतिर्गमय। मृत्योर्मा अमृतं गमय॥',
    transliteration: 'Asato ma sadgamaya, tamaso ma jyotirgamaya, mrityor ma '
        'amritam gamaya.',
    meaning: 'Lead me from what is untrue to what is true, from darkness to '
        'light, from what ends to what does not.',
    source: 'Brihadaranyaka Upanishad 1.3.28',
  ),
  SamvadMantra(
    id: 'sarve_bhavantu',
    title: 'May all be well',
    tradition: 'Sanskrit',
    original: 'सर्वे भवन्तु सुखिनः। सर्वे सन्तु निरामयाः। सर्वे भद्राणि पश्यन्तु। '
        'मा कश्चिद्दुःखभाग्भवेत्॥',
    transliteration: 'Sarve bhavantu sukhinah, sarve santu niramayah, sarve '
        'bhadrani pashyantu, ma kashchid duhkha-bhag bhavet.',
    meaning: 'May everyone be happy, may everyone be free of illness, may '
        'everyone see what is good, may no one suffer.',
    source: 'Traditional shanti mantra (Garuda Purana)',
  ),
  SamvadMantra(
    id: 'om_shanti',
    title: 'Om shanti',
    tradition: 'Vedic',
    original: 'ॐ शान्तिः शान्तिः शान्तिः॥',
    transliteration: 'Om shantih, shantih, shantih.',
    meaning: 'Peace — in the body, in the mind, and in the world around us.',
    source: 'The closing of the Upanishadic shanti mantras',
  ),
  SamvadMantra(
    id: 'lokah',
    title: 'For every living thing',
    tradition: 'Sanskrit',
    original: 'लोकाः समस्ताः सुखिनो भवन्तु॥',
    transliteration: 'Lokah samastah sukhino bhavantu.',
    meaning: 'May all beings, everywhere, be happy and free.',
    source: 'Traditional Sanskrit blessing',
  ),
  SamvadMantra(
    id: 'metta',
    title: 'Loving-kindness',
    tradition: 'Buddhist',
    original: 'सब्बे सत्ता सुखिता होन्तु। सब्बे सत्ता अवेरा होन्तु।',
    transliteration: 'Sabbe satta sukhita hontu. Sabbe satta avera hontu.',
    meaning: 'May all beings be happy. May all beings be free from ill will.',
    source: 'Pali, the Metta Sutta tradition',
  ),
  SamvadMantra(
    id: 'om_mani',
    title: 'Om mani padme hum',
    tradition: 'Buddhist',
    original: 'ॐ मणिपद्मे हूँ',
    transliteration: 'Om mani padme hum.',
    meaning: 'The jewel in the lotus — compassion, said over and over until '
        'it settles.',
    source: 'Traditional Buddhist mantra',
  ),
  SamvadMantra(
    id: 'mool_mantar',
    title: 'Ik Onkar',
    tradition: 'Sikh',
    original: 'ੴ ਸਤਿ ਨਾਮੁ ਕਰਤਾ ਪੁਰਖੁ ਨਿਰਭਉ ਨਿਰਵੈਰੁ ਅਕਾਲ ਮੂਰਤਿ ਅਜੂਨੀ ਸੈਭੰ '
        'ਗੁਰ ਪ੍ਰਸਾਦਿ ॥',
    transliteration: 'Ik Onkar, sat naam, karta purakh, nirbhau, nirvair, '
        'akaal moorat, ajooni, saibhang, gur prasaad.',
    meaning: 'There is one, and its name is truth: the maker, without fear, '
        'without hate, beyond time, unborn, self-existing, known by grace.',
    source: 'Mool Mantar, Guru Granth Sahib (1604)',
  ),
  SamvadMantra(
    id: 'bismillah',
    title: 'Bismillah',
    tradition: 'Islamic',
    original: 'بِسْمِ اللَّٰهِ الرَّحْمَٰنِ الرَّحِيمِ',
    transliteration: 'Bismillah ir-Rahman ir-Rahim.',
    meaning: 'In the name of God, the most gracious, the most merciful — '
        'said before anything begins.',
    source: 'The Basmala, the opening of the Quran',
  ),
  SamvadMantra(
    id: 'aaronic',
    title: 'A blessing',
    tradition: 'Christian',
    original: 'The Lord bless thee, and keep thee: the Lord make his face '
        'shine upon thee, and be gracious unto thee: the Lord lift up his '
        'countenance upon thee, and give thee peace.',
    transliteration: 'The Lord bless thee, and keep thee: the Lord make his '
        'face shine upon thee, and be gracious unto thee: the Lord lift up '
        'his countenance upon thee, and give thee peace.',
    meaning: 'May you be kept safe, looked on kindly, and given peace.',
    source: 'Numbers 6:24–26, King James Version (1611)',
  ),
  SamvadMantra(
    id: 'nini_baba',
    title: 'Nini baba nini',
    tradition: 'Folk lullaby',
    original: 'निनी बाबा निनी, मक्खन रोटी चीनी।\nमक्खन रोटी हो गई, '
        'मेरा बाबा सो गया।',
    transliteration: 'Nini baba nini, makkhan roti chini. Makkhan roti ho '
        'gayi, mera baba so gaya.',
    meaning: 'Sleep, little one, sleep — butter, bread and sugar; the bread '
        'is done, and my little one has fallen asleep.',
    source: 'Hindustani folk lullaby, traditional',
  ),
];

/// A mantra by id, or null.
SamvadMantra? samvadMantraById(String id) {
  for (final m in kSamvadMantras) {
    if (m.id == id) return m;
  }
  return null;
}

// -----------------------------------------------------------------------------
//  Left out, on purpose
// -----------------------------------------------------------------------------
//  "Chanda mama door ke" (1955, film) and "Lalla lalla lori" (1974, film) are
//  the lullabies most Indian mothers reach for, and both have an author and a
//  studio. The folk couplet under the second predates the film, but the words
//  everyone knows are the film's. Neither is here. If a folklorist confirms a
//  public-domain text, it is one more entry above.
