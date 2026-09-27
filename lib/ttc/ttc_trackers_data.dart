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
    this.readId,
    this.group,
    this.start,
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

  /// The piece that explains this field, where another area of the stage owns
  /// the subject.
  ///
  /// ⚠️ A REFERENCE BY ID, NEVER A COPY — the rebuild brief's Step 5. Getting
  /// ready is the single source for before-you-start body prep; it is NOT the
  /// owner of stress, which belongs to Mind and body. So the stress field names
  /// that area's read id and the article stays edited in exactly one place.
  ///
  /// ⚠️ AND IT IS ON THE FIELD, NOT THE TRACKER. The brief says "the 'Track
  /// what you're working on' STRESS PIECE references the Mind and body
  /// content" — one field of nine, not the whole tracker. A tracker-level link
  /// would put a stress article at the top of a screen where eight of the nine
  /// rows are about something else.
  ///
  /// Null on every other field, and that is the normal case: a field explains
  /// itself unless somebody else owns the subject.
  final String? readId;

  /// The eyebrow this field sits under.
  ///
  /// ⚠️ IN THE DATA, NOT IN THE SCREEN. The design groups nine fields under
  /// four headings — Sleep, Movement, Stress, Cutting down — and the obvious
  /// shortcut is to hard-code those four in the widget. That would make the
  /// tracker screen know about one tracker, which is the one thing it has
  /// never done: it renders any tracker from a definition, and eight of them
  /// used to share it.
  ///
  /// Null means no eyebrow, which is every other tracker: they have one or two
  /// fields and grouping them would be ceremony.
  final String? group;

  /// Where a stepper lands on its first tap.
  ///
  /// ⚠️ NOT `min`, AND THE DIFFERENCE IS THE WHOLE POINT OF IT. Minutes moved
  /// starts at 0 and steps by 5, so a first tap on `+` from `min` gives "5
  /// minutes" and eleven more taps are needed to reach a walk. The design
  /// starts it at 20 — the answer somebody is most likely to be reaching for —
  /// and every other value is one or two taps either side of it.
  ///
  /// Null falls back to `min`, which is right for a field with no obvious
  /// middle.
  final double? start;

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
    subtitleEn: "Notice, don't diagnose",
    subtitleHi: 'Notice karein, diagnosis nahi',
    whyEn:
        'Noting what your body does over a few cycles turns "I think this happens sometimes" into something you can show your doctor. It can\'t spot pregnancy. Early pregnancy and a period on its way can feel exactly the same, because the same hormone is behind both.',
    whyHi:
        'Kuch cycles tak apne body ko log karna, "shayad kabhi-kabhi aisa hota hai" ko aisi cheez bana deta hai jo aap doctor ko dikha sakein. Ye pregnancy pehchaanne ke liye nahi hai - shuruaati pregnancy aur aane wala period ek jaise lagte hain, kyunki dono ek hi hormone hain.',
    disclaimerEn:
        "This keeps a note of what you noticed. It doesn't read anything into it, and it's never a diagnosis.",
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
    subtitleEn: 'Just a number, not a judgement',
    subtitleHi: 'Ek number, faisla nahi',
    whyEn:
        "Body fat helps your body make and balance oestrogen. So cycles can become irregular when weight is very low or very high. Where weight plays a part, a change of around five per cent is often enough to bring ovulation back. That's a small change.\n\nThere's no target here and no ideal weight shown. A number on a screen telling you you're wrong has never helped anyone.",
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

  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'mood',
    iconKey: 'mood',
    titleEn: 'Mood',
    titleHi: 'Mood',
    subtitleEn: 'However today went',
    subtitleHi: 'Aaj jaisa bhi raha',
    whyEn:
        "It's not a score to improve. It's here because months blur together. It helps to see when the hard days bunch up: around the waiting, a period or a family gathering. Then they're easier to prepare for, and much easier to explain to someone else.",
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

  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  TtcTracker(
    id: 'partner_health',
    iconKey: 'partner',
    titleEn: 'Partner Health',
    titleHi: 'Partner ki sehat',
    subtitleEn: 'Half the picture',
    subtitleHi: 'Aadhi tasveer',
    whyEn:
        "In roughly forty to fifty per cent of couples who struggle to conceive, the man's side plays a part. Sperm takes about ninety days to make, so what's noted here today shows up around three months from now.\n\nIn most Indian clinics the woman is tested first, with tests that are slower, cost more and are more invasive. This is the other half.",
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
        group: 'Cutting down',
        labelEn: 'Alcohol today',
        labelHi: 'Aaj sharab',
        kind: TtcFieldKind.choice,
        choicesEn: ['None', '1 drink', '2 drinks', 'More than 2'],
        choicesHi: ['Bilkul nahi', '1 drink', '2 drink', '2 se zyada'],
      ),
      TtcField(
        id: 'smoking',
        group: 'Cutting down',
        labelEn: 'Smoked today',
        labelHi: 'Aaj smoke kiya',
        kind: TtcFieldKind.choice,
        choicesEn: ['No', 'Yes'],
        choicesHi: ['Nahi', 'Haan'],
      ),
      TtcField(
        id: 'heat',
        labelEn: 'Long time in heat (hot bath, sauna, laptop on lap)',
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
  // ===========================================================================
  //  ⚠️ ONE HABIT TRACKER, MERGED FROM FOUR — 2026-09-04
  // ---------------------------------------------------------------------------
  //  `getting_ready_rebuild.pdf` asks for "ONE tracker, reuse and consolidate
  //  the separate sleep/movement/stress trackers". It shipped first as one
  //  DESTINATION listing four trackers, which is a menu wearing a tracker's
  //  name — logging sleep took two taps and nothing was actually consolidated.
  //  Merged properly on request, and the Tools hub now carries one tile where
  //  it carried four.
  //
  //  ⚠️ THE OLD FOUR ARE COMMENTED OUT BELOW, NOT DELETED, and their FIELD IDS
  //  ARE PRESERVED EXACTLY. `hours`, `quality`, `minutes`, `kind`, `stress`,
  //  `caffeine`, `alcohol`, `smoking`, `water` — all nine were unique across
  //  the four trackers, which is the only reason this merge is a rename of the
  //  tracker half of the key and nothing more. Had two of them collided, every
  //  logged row for one would have had to be rewritten or lost.
  //
  //  ⚠️ AND EXISTING DATA MOVES WITH IT. `TtcLogStore` keys every row
  //  `tracker/field/day`, so a merge without a migration silently hides every
  //  night of sleep anybody has already logged. See `kTtcHabitMerge` in
  //  `ttc_log_store.dart` — it remaps on local load AND on the way in from
  //  Postgres, because the cloud table keys on the tracker id too and would
  //  otherwise re-introduce the old ids on every pull.
  //
  //  ⚠️ FIELD ORDER IS THE ORDER SHE LIVES THEM. Sleep and movement first
  //  because they are what the section tells her to work on; the three she is
  //  cutting down next; water last because it is the least consequential thing
  //  here and putting it first would say otherwise.
  // ===========================================================================
  TtcTracker(
    id: 'habits',
    iconKey: 'lifestyle',
    titleEn: "What you're working on",
    titleHi: 'Aap jis par kaam kar rahe hain',
    subtitleEn: 'A record, not a report card',
    subtitleHi: 'Ek record, report card nahi',
    whyEn:
        "Sleep, movement and cutting down are the habits with the strongest proof behind them while you're trying. This lets you see what you've been doing. There's no score, no streak and nothing to beat. Log the ones you care about and leave the rest blank.",
    whyHi:
        'Neend, movement aur kam karna - koshish ke dauraan inhi aadaton ke peeche sabse saaf saboot hain. Ye isliye hai ki aap dekh sakein ki aapne asal mein kya kiya - number dene ke liye nahi. Jo aapko theek lage wahi log karein, baaki chhod dein.',
    fields: [
      TtcField(
        id: 'hours',
        group: 'Sleep',
        start: 7,
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
        group: 'Sleep',
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
      TtcField(
        id: 'minutes',
        group: 'Movement',
        start: 20,
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
        group: 'Movement',
        labelEn: 'What kind',
        labelHi: 'Kis tarah ka',
        kind: TtcFieldKind.choice,
        choicesEn: ['Walk', 'Yoga', 'Strength', 'Stretch', 'Rest day'],
        choicesHi: ['Tehalna', 'Yoga', 'Strength', 'Stretch', 'Aaram ka din'],
      ),
      TtcField(
        id: 'stress',
        group: 'Stress',
        // ⚠️ MIND AND BODY OWNS THIS SUBJECT, AND THE LINK SAYS SO. Getting
        // ready records the number; the piece explaining what stress does and
        // does not do to fertility lives one door over and is referenced by id.
        readId: 'ttc_read_stress_fertility',
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
      // ⚠️ TWO FIELDS ADDED FOR MIND & BODY'S "Today" — 2026-09-05, and they
      // are added HERE rather than given their own store on purpose.
      //
      // Today shows two habit ticks: "In bed by about eleven" and "Home-cooked
      // meals today". The quick build is a boolean in a new store beside the
      // Today screen. That would give the app two places a sleep habit is
      // recorded — this tracker and that store — and the woman who ticks it on
      // Today would not see it in "What you're working on", which is the
      // screen whose entire job is showing her what she has been doing.
      //
      // So the tick writes into the tracker that already owns habits. One
      // record, two surfaces, and the food one satisfies the brief's rule that
      // this area "references Getting ready, does not own or teach food" — it
      // records the fact and teaches nothing.
      TtcField(
        id: 'bedtime',
        group: 'Sleep',
        labelEn: 'In bed by about eleven',
        labelHi: 'Kareeb gyarah baje tak bistar par',
        kind: TtcFieldKind.choice,
        choicesEn: ['No', 'Yes'],
        choicesHi: ['Nahi', 'Haan'],
      ),
      TtcField(
        id: 'homecooked',
        group: 'Food',
        labelEn: 'Home-cooked meals today',
        labelHi: 'Aaj ghar ka khana',
        kind: TtcFieldKind.choice,
        choicesEn: ['No', 'Some', 'Mostly'],
        choicesHi: ['Nahi', 'Kuch', 'Zyadatar'],
      ),
      TtcField(
        id: 'caffeine',
        group: 'Cutting down',
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
        labelEn: 'Smoke today (yours or around you)',
        labelHi: 'Aaj smoke - apna ya aas-paas ka',
        kind: TtcFieldKind.choice,
        choicesEn: ['None', 'Passive only', 'Yes'],
        choicesHi: ['Bilkul nahi', 'Sirf passive', 'Haan'],
      ),
      TtcField(
        id: 'water',
        group: 'Cutting down',
        start: 1,
        labelEn: 'Glasses of water',
        labelHi: 'Paani ke glass',
        kind: TtcFieldKind.number,
        unit: 'glasses',
        min: 0,
        max: 20,
      ),
    ],
  ),

  // ===========================================================================
  //  KEPT FOR REVERT — the four this replaced
  // ---------------------------------------------------------------------------
  //  Uncommenting these alone is NOT a revert: the rows have moved under the
  //  `habits` tracker id and `kTtcHabitMerge` keeps moving them. Reverting
  //  means removing that map as well, and accepting that anything logged since
  //  the merge stays where it is.
  // ===========================================================================
  /*
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
  */
];

TtcTracker? ttcTrackerById(String id) {
  for (final t in ttcTrackers) {
    if (t.id == id) return t;
  }
  return null;
}
