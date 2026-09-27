// =============================================================================
//  TTC - the Prepare catalogue
// -----------------------------------------------------------------------------
//      "Prepare no longer prepares for birth. It prepares for conception."
//                                                       - TTC master, §2.6
//
//  These become real Offerings in the EXISTING booking engine rather than a
//  second catalogue with its own prices and its own history:
//
//      "One engine serves both stages, so a birthing class booked while
//       pregnant and a postnatal yoga pack a year later appear in one history.
//       Two engines would split that in half, which is exactly what makes an
//       app feel like two apps."          - Product Reference, §10.1
//
//  So a fertility consult booked here sits in the same My Bookings list as the
//  birthing class she books eight months later.
//
//  Prices are in PAISE - real integers the engine can sum and charge, not
//  cosmetic "₹999" labels. They are indicative seed values; no money moves
//  anywhere in the app yet and every payment surface says so.
// =============================================================================

/// One thing a couple can buy while trying. Kept as plain data so the booking
/// engine can derive an Offering from it without this file importing the
/// engine, and so the display copy stays editable from Directus later.
/// The andrologist consultation, by id.
///
/// ⚠️ NAMED BECAUSE HIS SIDE OPENS IT DIRECTLY. The door's two Talk tiles used
/// `kTtcActConsult`, which opens the consults shelf — three cards, his the
/// third. The brief says "Consult (andrologist)", so the tile names the
/// offering and the tap lands on the person. A `TtcTalkTile.action` may be
/// either a hub action or an offering id; `openTtcFocusTile` resolves both.
const String kTtcOfferingAndrologist = 'ttc_consult_androl';

/// The free eight-session course, by id.
///
/// ⚠️ NAMED BECAUSE IT IS THE ONE OFFERING THAT IS NOT A BOOKING. Everything
/// else in this catalogue buys you a seat at a time with a person; this is a
/// self-paced course with no slot, no expert to meet and nothing to pay, and
/// `TtcOfferingScreen` sends it to `TtcGarbhCourseScreen` rather than drawing a
/// price of zero above an empty slot list.
const String kTtcOfferingGarbhCourse = 'ttc_course_garbh';

class TtcOffering {
  const TtcOffering({
    required this.id,
    required this.category,
    required this.titleEn,
    required this.titleHi,
    required this.bodyEn,
    required this.bodyHi,
    required this.expertId,
    required this.priceMinor,
    required this.kind,
    required this.sessions,
    this.forCouple = false,
  });

  final String id;

  /// One of the nine Prepare categories.
  final String category;

  final String titleEn;
  final String titleHi;
  final String bodyEn;
  final String bodyHi;

  final String expertId;

  /// Paise. Real money the engine can charge.
  final int priceMinor;

  /// 'consult' · 'masterclass' · 'cohort' · 'classPack'
  final String kind;

  /// How many sessions buying this grants.
  final int sessions;

  /// True when the thing is designed for both partners to attend. A TTC
  /// catalogue where nothing is for two people has missed the point of the
  /// stage.
  final bool forCouple;

  String title(bool hi) => hi ? titleHi : titleEn;
  String body(bool hi) => hi ? bodyHi : bodyEn;

  /// True when the thing costs nothing.
  ///
  /// ⚠️ ADDED FOR THE WORKBOOK'S ONE FREE OFFERING, and it is not cosmetic.
  /// The Mind-body row asks for "Preconception garbh sanskar (FREE acquisition
  /// hook)" — an offering whose whole purpose is that it costs nothing. Without
  /// this, `priceLabel` renders it as "₹0", which reads as a pricing bug rather
  /// than as an invitation and would quietly destroy the only acquisition hook
  /// in the stage.
  bool get isFree => priceMinor == 0;

  String get priceLabel =>
      isFree ? 'Free' : '₹${(priceMinor / 100).round()}';

  /// Hinglish label, because the price is chrome rather than content and the
  /// rest of this stage speaks Hinglish.
  String priceLabelIn(bool hi) =>
      isFree ? (hi ? 'Muft' : 'Free') : priceLabel;
}

/// The nine categories, in the order the master document lists them.
const List<(String, String, String)> ttcPrepareCategories = [
  ('consults', 'Expert consultations', 'Doctor se salaah'),
  ('courses', 'Courses', 'Courses'),
  ('yoga', 'Fertility yoga', 'Fertility yoga'),
  ('nutrition', 'Nutrition', 'Khaan-paan'),
  ('mental', 'Mental wellness', 'Mann ki sehat'),
  ('assessments', 'Medical assessments', 'Medical jaanch'),
  ('partner', 'Partner workshops', 'Partner workshops'),
  ('ivf', 'IVF support', 'IVF support'),
  ('lifestyle', 'Lifestyle programmes', 'Lifestyle programmes'),
];

const List<TtcOffering> ttcOfferings = [
  // ---- expert consultations -------------------------------------------------
  TtcOffering(
    id: 'ttc_consult_fertility',
    category: 'consults',
    kind: 'consult',
    sessions: 1,
    expertId: 'ttc_dr_fertility',
    priceMinor: 89900,
    titleEn: 'Fertility specialist consultation',
    titleHi: 'Fertility specialist se consultation',
    bodyEn:
        'A private video call to look at where you both are, which tests are worth doing, and what a sensible plan for the next six months looks like. Notes and any suggested tests are saved to your records.',
    bodyHi:
        'Ek private video consultation - ye dekhne ke liye ki aap dono kahan hain, kaunse tests sach mein karwane layak hain, aur agle chhe mahine ka samajhdaari bhara plan kya hai. Notes aur recommend kiye gaye tests aapke records mein save ho jaate hain.',
    forCouple: true,
  ),
  TtcOffering(
    id: 'ttc_consult_gynae',
    category: 'consults',
    kind: 'consult',
    sessions: 1,
    expertId: 'ttc_dr_gynae',
    priceMinor: 59900,
    titleEn: 'Gynaecologist consultation',
    titleHi: 'Gynaecologist se consultation',
    bodyEn:
        'For irregular cycles, painful periods, PCOS or endometriosis. Or for a check-up before you start trying.',
    bodyHi:
        'Irregular cycles, dardnaak periods, PCOS, endometriosis, ya koshish shuru karne se pehle ek pre-conception check ke liye.',
  ),
  TtcOffering(
    id: kTtcOfferingAndrologist,
    category: 'consults',
    kind: 'consult',
    sessions: 1,
    expertId: 'ttc_dr_androl',
    priceMinor: 59900,
    titleEn: 'Male fertility consultation',
    titleHi: 'Male fertility consultation',
    bodyEn:
        "For your partner. How to read a semen analysis properly, what can change and what can't, and when it's worth seeing a urologist or andrologist in person.",
    bodyHi:
        'Unke liye. Semen analysis ko theek se padhna, kya badla ja sakta hai aur kya nahi, aur kab urologist ya andrologist se milkar milna theek hai.',
  ),

  // ---- courses --------------------------------------------------------------
  TtcOffering(
    id: 'ttc_course_basics',
    category: 'courses',
    kind: 'masterclass',
    sessions: 1,
    expertId: 'ttc_dr_fertility',
    priceMinor: 29900,
    titleEn: 'Fertility, honestly',
    titleHi: 'Fertility, sach-sach',
    bodyEn:
        "Ninety minutes on what affects getting pregnant and what doesn't, including the things the internet often gets wrong. Recorded, so you can watch together.",
    bodyHi:
        'Nabbe minute is baat par ki conception par asal mein kya asar daalta hai aur kya nahi - wo baatein bhi jo internet zor-shor se galat batata hai. Recorded, saath mein dekhein.',
    forCouple: true,
  ),
  TtcOffering(
    id: 'ttc_course_pcos',
    category: 'courses',
    kind: 'cohort',
    sessions: 6,
    expertId: 'ttc_dr_gynae',
    priceMinor: 249900,
    titleEn: 'The PCOS programme',
    titleHi: 'PCOS programme',
    bodyEn:
        'Six weeks, live, in a small group. What PCOS is, insulin and food, exercise that helps, treatment choices, and the feelings that rarely get any time.',
    bodyHi:
        'Chhe hafte, live, chhote group mein: PCOS samajhna, insulin aur khaana, kaunsa movement madad karta hai, ilaaj ke vikalp, aur wo emotional hissa jiske liye koi waqt nahi nikalta.',
  ),

  // ---- fertility yoga -------------------------------------------------------
  TtcOffering(
    id: 'ttc_yoga_pack',
    category: 'yoga',
    kind: 'classPack',
    sessions: 8,
    expertId: 'ttc_yoga_lead',
    priceMinor: 199900,
    titleEn: 'Fertility yoga, eight classes',
    titleHi: 'Fertility yoga - aath classes',
    bodyEn:
        "Live small classes, planned around your cycle, not your fitness. Use them any time over two months. There's no hot yoga here and nothing intense, because both work against what you're trying to do.",
    bodyHi:
        'Live, chhoti classes, aapki fitness nahi - aapke cycle ke hisaab se. Do mahine mein kabhi bhi istemaal karein. Yahan na hot yoga hai na kuch bahut tez - dono us cheez ke khilaf jaate hain jo aap kar rahi hain.',
  ),

  // ---- nutrition ------------------------------------------------------------
  TtcOffering(
    id: 'ttc_nutrition_consult',
    category: 'nutrition',
    kind: 'consult',
    sessions: 1,
    expertId: 'ttc_nutritionist',
    priceMinor: 49900,
    titleEn: 'Nutritionist consultation',
    titleHi: 'Nutritionist se consultation',
    bodyEn:
        'A food plan for both of you, made from what you already cook in your Indian kitchen. No calorie counting, no imported ingredients, and no dieting rules.',
    bodyHi:
        'Aap dono ke liye Indian rasoi ka plan, usi ke aas-paas jo aap pehle se banate hain. Na calorie ginti, na bahar ki cheezein, na diet culture.',
    forCouple: true,
  ),

  // ---- mental wellness ------------------------------------------------------
  TtcOffering(
    id: 'ttc_psych_consult',
    category: 'mental',
    kind: 'consult',
    sessions: 1,
    expertId: 'ttc_psychologist',
    priceMinor: 79900,
    titleEn: 'Talking to a psychologist',
    titleHi: 'Psychologist se baat',
    bodyEn:
        'Worry is what most people feel at this stage, and "just relax" isn\'t a treatment. One private session with someone who works with couples trying to conceive.',
    bodyHi:
        'Kyunki is chapter mein chinta hi aam haalat hai, aur "bas relax karo" koi ilaaj nahi hai. Ek session, private, kisi aise ke saath jo conceive ki koshish karne wale couples ke saath kaam karta hai.',
  ),
  TtcOffering(
    id: 'ttc_loss_support',
    category: 'mental',
    kind: 'cohort',
    sessions: 4,
    expertId: 'ttc_psychologist',
    priceMinor: 149900,
    titleEn: 'After a loss',
    titleHi: 'Ek nuksaan ke baad',
    bodyEn:
        "Four sessions in a small group, for couples after a miscarriage or a failed cycle. There's no timetable for this, and no one here will give you one.",
    bodyHi:
        'Chaar sessions, chhota group, un couples ke liye jinhone miscarriage ya failed cycle dekha hai. Iska koi schedule nahi hota, aur koi aapko dega bhi nahi.',
    forCouple: true,
  ),

  // ---- medical assessments --------------------------------------------------
  TtcOffering(
    id: 'ttc_assessment_couple',
    category: 'assessments',
    kind: 'consult',
    sessions: 1,
    expertId: 'ttc_dr_fertility',
    priceMinor: 129900,
    titleEn: 'Couple assessment',
    titleHi: 'Couple assessment',
    bodyEn:
        "Both of you, one appointment. Which tests each of you should have, in what order, and your results explained to you together when they come in. So you aren't tested first while your partner's side waits.",
    bodyHi:
        'Aap dono, ek appointment. Kis-kis ko kaunse test karwane hain, kis kram mein, aur results aane par dono ko saath mein samjhaana - na ki pehle unki jaanch aur unka aadha hissa intezaar mein.',
    forCouple: true,
  ),

  // ---- partner workshops ----------------------------------------------------
  TtcOffering(
    id: 'ttc_partner_workshop',
    category: 'partner',
    kind: 'masterclass',
    sessions: 1,
    expertId: 'ttc_dr_androl',
    priceMinor: 19900,
    titleEn: 'The half nobody talks about',
    titleHi: 'Wo aadha hissa jiski baat nahi hoti',
    bodyEn:
        "Ninety minutes for him. How sperm is made, what the ninety days mean, what a semen analysis does and doesn't tell you, and what is worth changing.",
    bodyHi:
        'Unke liye nabbe minute: sperm asal mein kaise banta hai, nabbe din ki window ka matlab kya hai, semen analysis kya batata hai aur kya nahi, aur sach mein badalne layak kya hai.',
  ),

  // ---- IVF support ----------------------------------------------------------
  TtcOffering(
    id: 'ttc_ivf_prep',
    category: 'ivf',
    kind: 'cohort',
    sessions: 5,
    expertId: 'ttc_dr_fertility',
    priceMinor: 299900,
    titleEn: 'Preparing for IVF',
    titleHi: 'IVF ki taiyaari',
    bodyEn:
        "Five sessions on what an IVF cycle involves, the medicines and how to take them, the waiting, the costs clinics don't tell you upfront, and how to decide what to do next, whatever happens.",
    bodyHi:
        'Paanch sessions: cycle mein asal mein hota kya hai, dawaiyan aur unhe kaise lena hai, intezaar, wo kharche jo pehle koi nahi batata, aur jo bhi ho uske baad aage kya karna hai ye kaise tay karein.',
    forCouple: true,
  ),

  // ---- lifestyle ------------------------------------------------------------
  TtcOffering(
    id: 'ttc_lifestyle_90',
    category: 'lifestyle',
    kind: 'cohort',
    sessions: 6,
    expertId: 'ttc_nutritionist',
    priceMinor: 179900,
    titleEn: 'The ninety-day programme',
    titleHi: 'Nabbe din ka programme',
    bodyEn:
        'Sperm takes about ninety days to make, and an egg takes about the same to grow. This programme is for both of you, across those same ninety days. Sleep, food, exercise, and the two habits with the clearest evidence behind them.',
    bodyHi:
        'Sperm banne mein lagbhag nabbe din lagte hain aur egg pakne mein bhi lagbhag utne hi. Ye programme aap dono ke liye theek usi window ka hai - neend, khaana, movement, aur wo do aadatein jinke saboot sabse saaf hain.',
    forCouple: true,
  ),
  // ---- the one free thing in the catalogue ----------------------------------
  //
  // ⚠️ THE WORKBOOK ASKS FOR THIS EXPLICITLY: Mind-body prep → Course →
  // "Preconception garbh sanskar (FREE acquisition hook)". It is the only
  // zero-price entry here and that is the entire point of it — the stage's
  // thirteen other offerings are priced, and this is the one that lets someone
  // meet a ParentVeda expert without paying first.
  //
  // ⚠️ IT PROMISES NO OUTCOME. Not conception, and nothing about a child who
  // does not exist yet. See `ttc_read_garbh_sanskar` for the reasoning; the
  // copy below is written to the same line.
  TtcOffering(
    id: 'ttc_course_garbh',
    category: 'mental',
    kind: 'masterclass',
    titleEn: 'Preconception garbh sanskar',
    titleHi: 'Conceive se pehle ka garbh sanskar',
    bodyEn:
        'Eight short sessions for both of you, where you do the practice, not '
        'just read about it. Breath, stillness, sound, talking and gratitude, '
        'as a way to get ready, in whatever tradition suits you. It won\'t '
        "make a pregnancy happen, and it doesn't claim to. It's a way to spend "
        'the waiting that calms you instead of wearing you down. Free, and it '
        'stays free.',
    bodyHi:
        'Aath chhoti sessions, dono ke liye, sirf batayi nahi - sikhayi gayi. '
        'Saans, thehraav, dhwani, baatcheet aur shukr - abhyas taiyaari ke roop '
        'mein, jis bhi soch mein aapko theek lage. Ye pregnancy nahi karwaata, '
        'aur aisa daava bhi nahi karta. Ye intezaar ko kaatne ka ek shaant '
        'tareeka hai. Muft hai, aur muft hi rahega.',
    expertId: 'ttc_yoga_lead',
    priceMinor: 0,
    sessions: 8,
    forCouple: true,
  ),
];

List<TtcOffering> ttcOfferingsIn(String category) =>
    ttcOfferings.where((o) => o.category == category).toList();

TtcOffering? ttcOfferingById(String id) {
  for (final o in ttcOfferings) {
    if (o.id == id) return o;
  }
  return null;
}

/// ⚠️ ONE PLAIN LINE PER OFFERING, SAYING WHAT SHE GETS (2026-09-27, TTC tools
/// pass). Several titles don't say what they are ("The half nobody talks
/// about" is a talk for him about sperm health; "Fertility, honestly" is a
/// recorded class), so she had to open each one to find out. The lines are
/// drawn from each offering's own body; no fact is new.
///
/// ⚠️ NOT YET ON SCREEN. The list she sees is the unified learn screen, which
/// builds its rows in `lib/screens/learn/pv_learn_catalog.dart` (`_fromTtc`,
/// `subtitle: who`). One line there (`subtitle: ttcOfferingPlainLine(o.id) ??
/// who`, or a separate row line) makes these reachable. Handed over rather
/// than edited, because that file belongs to another area.
const Map<String, String> kTtcOfferingPlainLine = {
  'ttc_consult_fertility':
      'One video call with a fertility specialist about your next six months',
  'ttc_consult_gynae':
      'One video call about your cycles, periods, PCOS or a check-up',
  kTtcOfferingAndrologist:
      'One video call for him about his semen report',
  'ttc_course_basics':
      'A recorded 90-minute class on what affects getting pregnant',
  'ttc_course_pcos': 'Six live group sessions on living with PCOS',
  'ttc_yoga_pack': 'Eight gentle live yoga classes to use over two months',
  'ttc_nutrition_consult':
      'One video call for a food plan from your own kitchen',
  'ttc_psych_consult':
      'One private session with a psychologist for the worry of trying',
  'ttc_loss_support':
      'Four small-group sessions after a miscarriage or a failed cycle',
  'ttc_assessment_couple':
      'One appointment for you both: which tests, and your results together',
  'ttc_partner_workshop': 'A 90-minute talk for him about sperm health',
  'ttc_ivf_prep': 'Five sessions on what an IVF cycle involves',
  'ttc_lifestyle_90':
      'Six sessions for you both, across the 90 days sperm and eggs take to grow',
  kTtcOfferingGarbhCourse: 'Free: eight short sessions of calm practices',
};

/// The plain line for an offering, or null.
String? ttcOfferingPlainLine(String id) => kTtcOfferingPlainLine[id];
