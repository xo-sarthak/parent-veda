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

  String get priceLabel => '₹${(priceMinor / 100).round()}';
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
        'A private video consultation to look at where you both are, which tests are actually worth doing, and what a sensible next six months looks like. Notes and any recommended tests are saved to your records.',
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
        'For irregular cycles, painful periods, PCOS, endometriosis, or a pre-conception check before you start trying.',
    bodyHi:
        'Irregular cycles, dardnaak periods, PCOS, endometriosis, ya koshish shuru karne se pehle ek pre-conception check ke liye.',
  ),
  TtcOffering(
    id: 'ttc_consult_androl',
    category: 'consults',
    kind: 'consult',
    sessions: 1,
    expertId: 'ttc_dr_androl',
    priceMinor: 59900,
    titleEn: 'Male fertility consultation',
    titleHi: 'Male fertility consultation',
    bodyEn:
        'For him. Reading a semen analysis properly, what can be changed and what cannot, and when a urologist or andrologist is worth seeing in person.',
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
        'Ninety minutes on what actually affects conception and what does not - including the things the internet gets loudly wrong. Recorded, watch together.',
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
        'Six weeks, live, in a small group: understanding PCOS, insulin and food, movement that helps, treatment options, and the emotional side nobody schedules time for.',
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
    titleEn: 'Fertility yoga - eight classes',
    titleHi: 'Fertility yoga - aath classes',
    bodyEn:
        'Live, small, and built around your cycle rather than your fitness. Redeem any time over two months. Nothing here is hot yoga, and nothing here is intense - both work against what you are trying to do.',
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
        'An Indian-kitchen plan for both of you, built around what you already cook. No calorie counting, no imported ingredients, no diet culture.',
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
        'Because anxiety is the default emotional state of this chapter, and "just relax" is not a treatment. One session, privately, with someone who works with couples trying to conceive.',
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
        'Four sessions, small group, for couples after a miscarriage or a failed cycle. There is no timetable for this and nobody will give you one.',
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
        'Both of you, one appointment. Which tests each of you should do, in what order, and read back to you together when the results arrive - rather than her being investigated first while his half waits.',
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
        'Ninety minutes for him: how sperm is actually made, what the ninety-day window means, what a semen analysis does and does not say, and what is genuinely worth changing.',
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
        'Five sessions covering what the cycle actually involves, the medications and how to take them, the waiting, the costs nobody quotes upfront, and how to decide what to do next whatever happens.',
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
        'Sperm takes about ninety days to make and an egg about the same to mature. This is a programme for both of you across exactly that window - sleep, food, movement, and the two habits with the clearest evidence behind them.',
    bodyHi:
        'Sperm banne mein lagbhag nabbe din lagte hain aur egg pakne mein bhi lagbhag utne hi. Ye programme aap dono ke liye theek usi window ka hai - neend, khaana, movement, aur wo do aadatein jinke saboot sabse saaf hain.',
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
