// =============================================================================
//  TTC - tracker definitions
// -----------------------------------------------------------------------------
//  Eight of the Tools tiles - symptoms, weight, sleep, mood, stress, lifestyle,
//  partner health and hydration - are the same object with different fields.
//  Rather than eight near-identical stores and eight near-identical screens,
//  they are DEFINED here and rendered by one screen over one store.
//
//  That is not only less code. It is the reason they will still feel like one
//  product in a year: a new tracker cannot drift from the others, because there
//  is only one implementation to drift from.
//
//  The house rules each definition has to satisfy:
//
//   * Every tracker states WHY it exists. A field a parent cannot see the point
//     of is a field that should not be asked for.
//     ("Never ask users to provide information unless ParentVeda can use it to
//      improve their experience." - master doc, Part 6 principles)
//   * No tracker has a target, a goal or a streak. They record; they do not
//     grade.
//   * Scales are labelled at both ends in words, never as 1-10 with no anchor.
// =============================================================================

/// How a field is captured.
enum TtcFieldKind {
  /// A real quantity with a unit - weight in kg, sleep in hours.
  number,

  /// A short worded scale. Always anchored at both ends.
  scale,

  /// One of a few named options.
  choice,
}

class TtcField {
  const TtcField({
    required this.id,
    required this.labelEn,
    required this.labelHi,
    required this.kind,
    this.unit,
    this.min = 0,
    this.max = 4,
    this.step = 1,
    this.choicesEn = const [],
    this.choicesHi = const [],
    this.lowEn = '',
    this.lowHi = '',
    this.highEn = '',
    this.highHi = '',
  });

  final String id;
  final String labelEn;
  final String labelHi;
  final TtcFieldKind kind;

  final String? unit;
  final double min;
  final double max;
  final double step;

  final List<String> choicesEn;
  final List<String> choicesHi;

  /// Word anchors for a scale, so "3" is never shown without meaning.
  final String lowEn;
  final String lowHi;
  final String highEn;
  final String highHi;

  String label(bool hi) => hi ? labelHi : labelEn;
  String low(bool hi) => hi ? lowHi : lowEn;
  String high(bool hi) => hi ? highHi : highEn;
  List<String> choices(bool hi) => hi ? choicesHi : choicesEn;

  /// The word for a recorded value, used everywhere a value is displayed.
  String display(bool hi, double v) {
    switch (kind) {
      case TtcFieldKind.number:
        final s = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
        return unit == null ? s : '$s $unit';
      case TtcFieldKind.choice:
        final c = choices(hi);
        final i = v.round();
        return (i >= 0 && i < c.length) ? c[i] : '';
      case TtcFieldKind.scale:
        final c = choices(hi);
        final i = v.round();
        if (i >= 0 && i < c.length) return c[i];
        return v.toStringAsFixed(0);
    }
  }
}

class TtcTracker {
  const TtcTracker({
    required this.id,
    required this.iconKey,
    required this.titleEn,
    required this.titleHi,
    required this.subtitleEn,
    required this.subtitleHi,
    required this.whyEn,
    required this.whyHi,
    required this.fields,
    this.forPartner = false,
    this.disclaimerEn,
    this.disclaimerHi,
  });

  final String id;
  final String iconKey;
  final String titleEn;
  final String titleHi;
  final String subtitleEn;
  final String subtitleHi;

  /// Why this tracker exists at all - shown above the log, always.
  final String whyEn;
  final String whyHi;

  final List<TtcField> fields;

  /// True when this is his to fill in.
  final bool forPartner;

  /// Present on anything that touches clinical ground.
  final String? disclaimerEn;
  final String? disclaimerHi;

  String title(bool hi) => hi ? titleHi : titleEn;
  String subtitle(bool hi) => hi ? subtitleHi : subtitleEn;
  String why(bool hi) => hi ? whyHi : whyEn;
  String? disclaimer(bool hi) => hi ? disclaimerHi : disclaimerEn;
}

// ---- shared scales ----------------------------------------------------------

const _lowToHighEn = ['None', 'A little', 'Some', 'A lot', 'Severe'];
const _lowToHighHi = ['Bilkul nahi', 'Thoda', 'Kuch', 'Kaafi', 'Bahut zyada'];

const _moodEn = ['Very low', 'Low', 'Okay', 'Good', 'Really good'];
const _moodHi = ['Bahut kam', 'Kam', 'Theek', 'Achha', 'Bahut achha'];

const _qualityEn = ['Poor', 'Broken', 'Okay', 'Good', 'Deep'];
const _qualityHi = ['Kharaab', 'Tooti hui', 'Theek', 'Achhi', 'Gehri'];

// =============================================================================

const List<TtcTracker> ttcTrackers = [
  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'symptoms',
    iconKey: 'healing',
    titleEn: 'Symptom Companion',
    titleHi: 'Symptom Companion',
    subtitleEn: 'Notice, do not diagnose',
    subtitleHi: 'Notice karein, diagnosis nahi',
    whyEn:
        'Logging what your body does across a few cycles turns "I think this happens sometimes" into something you can actually show a doctor. It is not for spotting pregnancy - early pregnancy and an approaching period feel identical, because they are the same hormone.',
    whyHi:
        'Kuch cycles tak apne body ko log karna, "shayad kabhi-kabhi aisa hota hai" ko aisi cheez bana deta hai jo aap doctor ko dikha sakein. Ye pregnancy pehchaanne ke liye nahi hai - shuruaati pregnancy aur aane wala period ek jaise lagte hain, kyunki dono ek hi hormone hain.',
    disclaimerEn:
        'This records what you noticed. It never interprets it, and it is never a diagnosis.',
    disclaimerHi:
        'Ye sirf record karta hai ki aapne kya notice kiya. Ye uska matlab nahi nikalta, aur ye kabhi diagnosis nahi hai.',
    fields: [
      TtcField(
        id: 'cramping',
        labelEn: 'Cramping',
        labelHi: 'Cramps',
        kind: TtcFieldKind.scale,
        choicesEn: _lowToHighEn,
        choicesHi: _lowToHighHi,
        lowEn: 'None',
        lowHi: 'Bilkul nahi',
        highEn: 'Severe',
        highHi: 'Bahut zyada',
      ),
      TtcField(
        id: 'bloating',
        labelEn: 'Bloating',
        labelHi: 'Pet phoolna',
        kind: TtcFieldKind.scale,
        choicesEn: _lowToHighEn,
        choicesHi: _lowToHighHi,
        lowEn: 'None',
        lowHi: 'Bilkul nahi',
        highEn: 'Severe',
        highHi: 'Bahut zyada',
      ),
      TtcField(
        id: 'breast',
        labelEn: 'Breast tenderness',
        labelHi: 'Chhaati mein dard',
        kind: TtcFieldKind.scale,
        choicesEn: _lowToHighEn,
        choicesHi: _lowToHighHi,
        lowEn: 'None',
        lowHi: 'Bilkul nahi',
        highEn: 'Severe',
        highHi: 'Bahut zyada',
      ),
      TtcField(
        id: 'fatigue',
        labelEn: 'Tiredness',
        labelHi: 'Thakaan',
        kind: TtcFieldKind.scale,
        choicesEn: _lowToHighEn,
        choicesHi: _lowToHighHi,
        lowEn: 'None',
        lowHi: 'Bilkul nahi',
        highEn: 'Severe',
        highHi: 'Bahut zyada',
      ),
      TtcField(
        id: 'headache',
        labelEn: 'Headache',
        labelHi: 'Sar dard',
        kind: TtcFieldKind.scale,
        choicesEn: _lowToHighEn,
        choicesHi: _lowToHighHi,
        lowEn: 'None',
        lowHi: 'Bilkul nahi',
        highEn: 'Severe',
        highHi: 'Bahut zyada',
      ),
      TtcField(
        id: 'mucus',
        labelEn: 'Cervical mucus',
        labelHi: 'Cervical mucus',
        kind: TtcFieldKind.choice,
        choicesEn: ['Dry', 'Sticky', 'Creamy', 'Watery', 'Egg-white'],
        choicesHi: ['Sookha', 'Chipchipa', 'Creamy', 'Paani jaisa', 'Ande jaisa'],
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'weight',
    iconKey: 'weight',
    titleEn: 'Weight',
    titleHi: 'Wazan',
    subtitleEn: 'A number, not a verdict',
    subtitleHi: 'Ek number, faisla nahi',
    whyEn:
        'Body fat is part of how the body makes and regulates oestrogen, so cycles can become irregular at both ends of the range. Where weight is a factor, a shift of around five per cent is often enough to restore ovulation - which is a genuinely small number.\n\nThere is no target here and no ideal weight shown, because a number on a screen telling you that you are wrong has never helped anyone.',
    whyHi:
        'Body fat us tareeke ka hissa hai jisse body oestrogen banata aur sambhalta hai, isliye cycles range ke dono siron par irregular ho sakte hain. Jahan wazan ek wajah hai, lagbhag paanch pratishat ka badlaav aksar ovulation wapas laane ke liye kaafi hota hai - jo sach mein chhota number hai.\n\nYahan koi target nahi hai aur koi "sahi wazan" nahi dikhaya jaata, kyunki screen par ek number jo aapko galat batata hai, usse aaj tak kisi ka bhala nahi hua.',
    fields: [
      TtcField(
        id: 'kg',
        labelEn: 'Weight',
        labelHi: 'Wazan',
        kind: TtcFieldKind.number,
        unit: 'kg',
        min: 30,
        max: 200,
        step: 0.5,
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'sleep',
    iconKey: 'sleep',
    titleEn: 'Sleep',
    titleHi: 'Neend',
    subtitleEn: 'A fertility habit, not a luxury',
    subtitleHi: 'Ek fertility aadat, aish nahi',
    whyEn:
        'The hormones driving ovulation and sperm production are released on a daily rhythm tied to sleep and darkness. Seven to nine hours at roughly the same time is the whole recommendation.\n\nIf shift work is not negotiable - and for many people in India it is not - consistency of whatever schedule you have matters more than the hours themselves.',
    whyHi:
        'Jo hormones ovulation aur sperm banne ko chalate hain, wo neend aur andhere se judi ek roz ki rhythm par nikalte hain. Roz lagbhag ek hi samay saat se nau ghante - poori salaah bas itni hai.\n\nAgar shift work badla nahi ja sakta - aur India mein bahut logon ke liye nahi badal sakta - toh jo bhi schedule hai uski consistency, ghanton se zyada maayne rakhti hai.',
    fields: [
      TtcField(
        id: 'hours',
        labelEn: 'Hours slept',
        labelHi: 'Kitne ghante soye',
        kind: TtcFieldKind.number,
        unit: 'hrs',
        min: 0,
        max: 14,
        step: 0.5,
      ),
      TtcField(
        id: 'quality',
        labelEn: 'How it felt',
        labelHi: 'Kaisi lagi',
        kind: TtcFieldKind.scale,
        choicesEn: _qualityEn,
        choicesHi: _qualityHi,
        lowEn: 'Poor',
        lowHi: 'Kharaab',
        highEn: 'Deep',
        highHi: 'Gehri',
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'mood',
    iconKey: 'mood',
    titleEn: 'Mood',
    titleHi: 'Mood',
    subtitleEn: 'However today actually was',
    subtitleHi: 'Aaj jaisa bhi raha',
    whyEn:
        'This is not here to be improved. It is here because months blur together, and being able to see that the hard days cluster - around the waiting, around a period, around a family gathering - makes them easier to prepare for and much easier to explain to someone else.',
    whyHi:
        'Ye yahan "behtar karne" ke liye nahi hai. Ye isliye hai kyunki mahine aapas mein ghul-mil jaate hain, aur ye dekh paana ki mushkil din kab ikatthe aate hain - intezaar ke aas-paas, period ke aas-paas, kisi family function ke aas-paas - unke liye taiyaar rehna aasaan bana deta hai, aur kisi ko samjhana usse bhi aasaan.',
    fields: [
      TtcField(
        id: 'mood',
        labelEn: 'Today',
        labelHi: 'Aaj',
        kind: TtcFieldKind.scale,
        choicesEn: _moodEn,
        choicesHi: _moodHi,
        lowEn: 'Very low',
        lowHi: 'Bahut kam',
        highEn: 'Really good',
        highHi: 'Bahut achha',
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'stress',
    iconKey: 'stress',
    titleEn: 'Stress',
    titleHi: 'Stress',
    subtitleEn: 'Noticing, not fixing',
    subtitleHi: 'Notice karna, theek karna nahi',
    whyEn:
        'Severe sustained stress can delay or suppress ovulation, so this is worth seeing. But the honest version is narrower than the version people repeat: ordinary work stress and ordinary worry are not what stops a healthy couple conceiving.\n\nNothing here will ever tell you to relax.',
    whyHi:
        'Tez aur lambe samay ka stress ovulation ko der kar sakta hai ya rok sakta hai, isliye ise dekhna theek hai. Lekin sach us baat se chhota hai jo log dohraate hain: rozmarra ka office stress aur aam chinta, kisi healthy couple ko conceive karne se nahi rokti.\n\nYahan kuch bhi aapse kabhi "relax karo" nahi kahega.',
    fields: [
      TtcField(
        id: 'stress',
        labelEn: 'How heavy today felt',
        labelHi: 'Aaj kitna bhaari laga',
        kind: TtcFieldKind.scale,
        choicesEn: _lowToHighEn,
        choicesHi: _lowToHighHi,
        lowEn: 'Light',
        lowHi: 'Halka',
        highEn: 'Very heavy',
        highHi: 'Bahut bhaari',
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'lifestyle',
    iconKey: 'lifestyle',
    titleEn: 'Lifestyle',
    titleHi: 'Lifestyle',
    subtitleEn: 'The two with the clearest evidence',
    subtitleHi: 'Do cheezein jinke saboot sabse saaf',
    whyEn:
        'Most lifestyle advice in this space is soft. Two things are not: smoking - including passive smoking at home - and heavy alcohol are both consistently linked to reduced fertility in either partner.\n\nCaffeine is here for a different reason: the limit while trying is around 200mg a day, which is two to three cups of chai. What catches people out is the cola, green tea and dark chocolate nobody counts.',
    whyHi:
        'Is field ki zyadatar lifestyle salaah narm hoti hai. Do cheezein nahi hain: smoking - ghar mein passive smoking bhi - aur zyada sharab, dono kisi bhi partner mein kam fertility se lagatar judi hain.\n\nCaffeine yahan alag wajah se hai: koshish ke dauraan hadd roz lagbhag 200mg hai, yaani do-teen cup chai. Log cola, green tea aur dark chocolate ginna bhool jaate hain - wahi pakadta hai.',
    fields: [
      TtcField(
        id: 'caffeine',
        labelEn: 'Caffeine today',
        labelHi: 'Aaj caffeine',
        kind: TtcFieldKind.choice,
        choicesEn: ['None', '1 cup', '2 cups', '3 cups', 'More than 3'],
        choicesHi: ['Bilkul nahi', '1 cup', '2 cup', '3 cup', '3 se zyada'],
      ),
      TtcField(
        id: 'alcohol',
        labelEn: 'Alcohol today',
        labelHi: 'Aaj sharab',
        kind: TtcFieldKind.choice,
        choicesEn: ['None', '1 drink', '2 drinks', 'More than 2'],
        choicesHi: ['Bilkul nahi', '1 drink', '2 drink', '2 se zyada'],
      ),
      TtcField(
        id: 'smoking',
        labelEn: 'Smoke today - yours or around you',
        labelHi: 'Aaj smoke - apna ya aas-paas ka',
        kind: TtcFieldKind.choice,
        choicesEn: ['None', 'Passive only', 'Yes'],
        choicesHi: ['Bilkul nahi', 'Sirf passive', 'Haan'],
      ),
      TtcField(
        id: 'water',
        labelEn: 'Glasses of water',
        labelHi: 'Paani ke glass',
        kind: TtcFieldKind.number,
        unit: 'glasses',
        min: 0,
        max: 20,
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'partner_health',
    iconKey: 'partner',
    titleEn: 'Partner Health',
    titleHi: 'Partner ki sehat',
    subtitleEn: 'Half the picture',
    subtitleHi: 'Aadhi tasveer',
    whyEn:
        'A male factor is involved in roughly forty to fifty per cent of couples who struggle, and sperm takes about ninety days to make - so what is recorded here today shows up around three months from now.\n\nThis exists because in most Indian clinics the woman is investigated first, through tests that are slower, costlier and more invasive. This is the other half.',
    whyHi:
        'Jo couples mushkil jhelte hain unmein lagbhag chalis se pachas pratishat mein mard ka factor hota hai, aur sperm banne mein lagbhag nabbe din lagte hain - toh aaj jo yahan record hota hai, wo teen mahine baad dikhta hai.\n\nYe isliye hai kyunki zyadatar Indian clinics mein pehle aurat ke test hote hain - jo dheere, mehnge aur zyada takleefdeh hote hain. Ye doosra aadha hissa hai.',
    forPartner: true,
    fields: [
      TtcField(
        id: 'sleep',
        labelEn: 'Hours slept',
        labelHi: 'Kitne ghante soye',
        kind: TtcFieldKind.number,
        unit: 'hrs',
        min: 0,
        max: 14,
        step: 0.5,
      ),
      TtcField(
        id: 'alcohol',
        labelEn: 'Alcohol today',
        labelHi: 'Aaj sharab',
        kind: TtcFieldKind.choice,
        choicesEn: ['None', '1 drink', '2 drinks', 'More than 2'],
        choicesHi: ['Bilkul nahi', '1 drink', '2 drink', '2 se zyada'],
      ),
      TtcField(
        id: 'smoking',
        labelEn: 'Smoked today',
        labelHi: 'Aaj smoke kiya',
        kind: TtcFieldKind.choice,
        choicesEn: ['No', 'Yes'],
        choicesHi: ['Nahi', 'Haan'],
      ),
      TtcField(
        id: 'heat',
        labelEn: 'Long heat exposure - hot bath, sauna, laptop on lap',
        labelHi: 'Lambi garmi - garam nahaana, sauna, god par laptop',
        kind: TtcFieldKind.choice,
        choicesEn: ['No', 'Yes'],
        choicesHi: ['Nahi', 'Haan'],
      ),
      TtcField(
        id: 'movement',
        labelEn: 'Moved today',
        labelHi: 'Aaj movement kiya',
        kind: TtcFieldKind.choice,
        choicesEn: ['No', 'A walk', 'A proper session'],
        choicesHi: ['Nahi', 'Tehla', 'Poora session'],
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'exercise',
    iconKey: 'exercise',
    titleEn: 'Movement',
    titleHi: 'Movement',
    subtitleEn: 'Not fitness - movement',
    subtitleHi: 'Fitness nahi - movement',
    whyEn:
        'Moderate regular activity supports hormone balance, insulin sensitivity and sleep, and it helps notably in PCOS. Around thirty minutes most days is the usual recommendation, and a brisk walk counts.\n\nThe other end is real too: very intense training, especially with under-eating, can stop ovulation altogether. This is why there is no goal here to beat.',
    whyHi:
        'Moderate regular activity hormone balance, insulin sensitivity aur neend ko support karti hai, aur PCOS mein khaas madad karti hai. Zyadatar dino mein lagbhag tees minute aam salaah hai, aur tez chalna bhi ginta hai.\n\nDoosra sira bhi asli hai: bahut tez training, khaaskar kam khaane ke saath, ovulation poori tarah rok sakti hai. Isiliye yahan koi goal nahi hai jise "beat" karna ho.',
    fields: [
      TtcField(
        id: 'minutes',
        labelEn: 'Minutes moved',
        labelHi: 'Kitne minute',
        kind: TtcFieldKind.number,
        unit: 'min',
        min: 0,
        max: 300,
        step: 5,
      ),
      TtcField(
        id: 'kind',
        labelEn: 'What kind',
        labelHi: 'Kis tarah ka',
        kind: TtcFieldKind.choice,
        choicesEn: ['Walk', 'Yoga', 'Strength', 'Stretch', 'Rest day'],
        choicesHi: ['Tehalna', 'Yoga', 'Strength', 'Stretch', 'Aaram ka din'],
      ),
    ],
  ),
];

TtcTracker? ttcTrackerById(String id) {
  for (final t in ttcTrackers) {
    if (t.id == id) return t;
  }
  return null;
}
