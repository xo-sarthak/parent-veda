// =============================================================================
//  TTC - the daily content library
// -----------------------------------------------------------------------------
//  Seed content for Today's Journey: insights, myths, the daily ritual,
//  nutrition, movement and journal prompts. Original, bilingual, India-first.
//
//  ---------------------------------------------------------------------------
//  ALL OF THIS IS SEED CONTENT. It is authored to ParentVeda's voice so the
//  stage is a real experience from day one, and it is written to be REPLACED
//  from Directus rather than to be final. `kTtcContentIsSeed` below is the flag
//  a future fetch layer flips. Nothing here describes a specific family - it is
//  editorial, so it carries none of the "never invent data about a family" risk
//  that seeded child rows would.
//  ---------------------------------------------------------------------------
//
//  Rotation follows the parenting app's convention exactly: indexed by
//  day-of-year, so a card is stable within a day and rotates by itself without
//  any scheduling, any server call, or any state to keep.
//
//  Voice rules these were written against:
//   * Emotion before information. Never urgency, never guilt, never a deadline.
//   * "We", not "you" - this is a two-person stage.
//   * Evidence before opinion, but never a data dump: answer "what does this
//     mean for me today?"
//   * India-first: real Indian kitchens, real Indian clinics, real costs.
//   * Never a diagnosis. Anything clinical routes calmly to a doctor.
// =============================================================================

import 'ttc_chapter.dart';
import 'ttc_phase.dart';

// Callers of `ttcInsightsForPhase` get the phase type with the cards.
export 'ttc_phase.dart' show TtcDayPhase, ttcDayPhaseForCycleDay;

/// Flipped to false the day this content is served from Directus instead.
const bool kTtcContentIsSeed = true;

/// Stable day index - the same card all day, a different one tomorrow.
int ttcDayIndex([DateTime? now]) {
  final d = now ?? DateTime.now();
  return DateTime(d.year, d.month, d.day).difference(DateTime(d.year)).inDays;
}

/// Picks today's item from any list, stably.
T ttcPickForToday<T>(List<T> items, {DateTime? now, int offset = 0}) =>
    items[(ttcDayIndex(now) + offset) % items.length];

// =============================================================================
//  Today's Insight
// =============================================================================

/// One evidence-based insight a day. Under sixty seconds to read, one topic,
/// one message, one takeaway. (Master doc §3.1)
class TtcInsight {
  const TtcInsight({
    required this.id,
    required this.topic,
    required this.titleEn,
    required this.titleHi,
    required this.bodyEn,
    required this.bodyHi,
    required this.takeawayEn,
    required this.takeawayHi,
    this.readSeconds = 45,
    this.forPartner = true,
    this.phases = const {TtcDayPhase.any},
  });

  final String id;

  /// The stretches of her cycle this card fits (`ttc_phase.dart`).
  ///
  /// Additive: the default is [TtcDayPhase.any], so every older caller and
  /// every date-only rotation behaves exactly as before. Only
  /// [ttcInsightsForPhase] reads it. A card may carry `any` beside a phase: it
  /// then leads in that phase and fills in on every other day.
  final Set<TtcDayPhase> phases;

  /// One of: fertility · nutrition · lifestyle · male · medical · emotional
  final String topic;

  final String titleEn;
  final String titleHi;
  final String bodyEn;
  final String bodyHi;

  /// The single thing worth carrying into the day.
  final String takeawayEn;
  final String takeawayHi;

  /// Declared, but only used as a fallback.
  ///
  /// Every insight inherited the default of 45 seconds, so a sixty-word piece
  /// and a three-hundred-word one both claimed the same length. Prefer
  /// [readTime], which counts the words actually written.
  final int readSeconds;

  /// Seconds to read THIS piece, from its own length.
  ///
  /// ~200 words a minute, floored at fifteen so a short piece does not claim
  /// to be instant. Computed rather than declared, because a number nobody
  /// updates when the copy changes is worse than no number.
  int readTime(bool hi) {
    final words = (hi ? bodyHi : bodyEn).split(RegExp(r'\s+')).length;
    final seconds = (words / 200 * 60).round();
    return seconds < 15 ? 15 : seconds;
  }

  /// Whether this also appears on the partner's Today. Most do - male fertility
  /// is half the picture and the stage is built for two.
  final bool forPartner;

  String title(bool hi) => hi ? titleHi : titleEn;
  String body(bool hi) => hi ? bodyHi : bodyEn;
  String takeaway(bool hi) => hi ? takeawayHi : takeawayEn;
}

const List<TtcInsight> ttcInsights = [
  TtcInsight(
    id: 'fertile_window_length',
    topic: 'fertility',
    phases: {TtcDayPhase.beforeWindow, TtcDayPhase.window},
    titleEn: 'Your fertile window is wider than most people think',
    titleHi: 'Fertile window utna chhota nahi jitna log samajhte hain',
    bodyEn:
        "An egg lives for about a day after it's released, but sperm can survive around five days inside the body. So the days before ovulation count just as much as the day itself. That's why we show you a window of several days instead of one date.\n\nIt also means you don't have to get one day exactly right. Couples who are close a few times across that window do just as well as couples who plan around a test.",
    bodyHi:
        'Egg release hone ke baad lagbhag ek din tak zinda rehta hai. Sperm body ke andar takreeban paanch din tak reh sakta hai. Iska matlab - ovulation se PEHLE ke din utne hi important hain jitna khud ka din. Isiliye ParentVeda ek hi din nahi, kuch dino ki window dikhata hai.\n\nAur iska ek aur matlab - aapko ek hi din perfectly pakadna zaroori nahi hai. Jo couples us window mein bas kuch baar kareeb aate hain, wo utna hi accha karte hain jitne wo jo test dekh kar plan karte hain.',
    takeawayEn: 'A few relaxed days are better than one perfectly timed day.',
    takeawayHi: 'Kuch aaram se bitaye din, ek perfectly planned din se behtar hain.',
  ),
  TtcInsight(
    id: 'folic_acid_timing',
    topic: 'nutrition',
    phases: {TtcDayPhase.any},
    titleEn: "Folic acid works before you know you're pregnant",
    titleHi: 'Folic acid tab kaam karta hai jab pata bhi nahi hota',
    bodyEn:
        "A baby's neural tube, which becomes the brain and spine, closes in the first four weeks. This often happens before you've even missed a period. Folic acid needs to be in your body by then. That's why every guideline says to start it while you're trying, not after a positive test.\n\n400 micrograms a day is the usual advice. Your doctor may suggest more if you have diabetes, epilepsy or a high BMI, or if a past pregnancy was affected by a neural tube defect.",
    bodyHi:
        'Baby ka neural tube - jo aage chal kar brain aur spine banta hai - pehle chaar hafton mein band ho jaata hai, aksar period miss hone se bhi pehle. Tab tak folic acid body mein pehle se hona chahiye. Isiliye har guideline kehti hai - koshish karte waqt shuru karein, positive test ke baad nahi.\n\nRoz 400 microgram standard salaah hai. Agar aapko diabetes, epilepsy, zyada BMI ho, ya pehle kisi pregnancy mein neural tube defect raha ho, toh doctor zyada bhi keh sakte hain.',
    takeawayEn: 'If you start one thing this week, make it folic acid.',
    takeawayHi: 'Is hafte agar ek cheez shuru karni hai, toh folic acid karein.',
    forPartner: false,
  ),
  TtcInsight(
    id: 'sperm_cycle_90_days',
    topic: 'male',
    phases: {TtcDayPhase.any},
    titleEn: 'Sperm take about three months to make',
    titleHi: 'Sperm banne mein lagbhag teen mahine lagte hain',
    bodyEn:
        "The sperm released today started forming around seventy to ninety days ago. That's good news. It means the changes a man makes now, to sleep, alcohol, smoking, heat, weight and stress, show up in about three months.\n\nIt also means results aren't instant, and one hard month doesn't undo anything. Keeping it up over a season matters far more than any one week.",
    bodyHi:
        'Aaj jo sperm release hota hai, wo lagbhag sattar se nabbe din pehle banna shuru hua tha. Ye asal mein achhi khabar hai: matlab aaj jo badlaav mard karta hai - neend, sharab, smoking, garmi, wazan, stress - wo teen mahine mein dikhte hain.\n\nIska ye bhi matlab hai ki result turant nahi milta, aur ek mushkil mahina sab kuch kharab nahi karta. Ek season tak consistency, kisi ek hafte se kahin zyada maayne rakhti hai.',
    takeawayEn: 'What he changes today shows up in about three months.',
    takeawayHi: 'Jo aaj badlega, wo lagbhag teen mahine baad dikhega.',
  ),
  TtcInsight(
    id: 'cervical_mucus',
    topic: 'fertility',
    phases: {TtcDayPhase.beforeWindow, TtcDayPhase.window},
    titleEn: 'Your body already gives you a signal, for free',
    titleHi: 'Aapka body pehle se ek signal deta hai - bilkul muft',
    bodyEn:
        "In the days before ovulation, cervical mucus (the fluid from your cervix) usually gets clearer, more slippery and stretchier. It's often compared to raw egg white. After ovulation it usually turns thicker and drier again.\n\nThis costs nothing and needs no kit. Many women find it a more reliable everyday guide than an app's guess. It shows what your body is doing right now, not what a calendar expects.",
    bodyHi:
        'Ovulation ke paas aate dino mein cervical mucus aam taur par zyada saaf, chikna aur khinchne wala ho jaata hai - jise aksar kacche ande ke safed hisse se compare karte hain. Ovulation ke baad ye phir se gaadha aur sookha ho jaata hai.\n\nIsmein kuch kharch nahi, koi kit nahi chahiye. Bahut si auratein ise app ki prediction se zyada bharosemand maanti hain, kyunki ye batata hai ki body abhi kya kar raha hai - na ki calendar kya soch raha hai.',
    takeawayEn: 'Watch what your body does, not only what the app predicts.',
    takeawayHi: 'App ki prediction ke saath, apne body ko bhi dekhein.',
    forPartner: false,
  ),
  TtcInsight(
    id: 'how_long_is_normal',
    topic: 'medical',
    phases: {TtcDayPhase.any},
    titleEn: 'How long is normal before seeing a doctor?',
    titleHi: 'Doctor se milne se pehle kitna time normal hai?',
    bodyEn:
        "About eight in ten couples conceive within a year of trying, and around nine in ten within two. So most of the time, more time really is the answer.\n\nThe usual advice is to see a doctor after a year of trying, or after six months if the woman is over thirty-five. Go sooner, at any age, if periods are very irregular or have stopped, if you know there's endometriosis or PCOS, if there's been pelvic surgery or infection before, or if there's a known issue on the male side. Going earlier is never wrong. It just isn't required.",
    bodyHi:
        'Das mein se lagbhag aath couples ek saal ke andar conceive kar lete hain, aur das mein se nau do saal ke andar. Toh zyadatar waqt, thoda aur samay hi asli jawab hota hai.\n\nAam salaah ye hai ki ek saal koshish ke baad doctor se milein - ya chhe mahine baad agar aurat pentiis se upar hai, ya kisi bhi umar mein pehle agar periods bahut irregular ya band hain, endometriosis ya PCOS pata hai, pehle pelvic surgery ya infection hua hai, ya mard ki taraf koi issue pata hai. Jaldi jaana kabhi galat nahi - bas zaroori nahi.',
    takeawayEn: 'Most couples need time, not treatment. Going early is still fine.',
    takeawayHi: 'Zyadatar couples ko ilaaj nahi, samay chahiye. Jaldi jaana phir bhi theek hai.',
  ),
  TtcInsight(
    id: 'stress_and_fertility',
    topic: 'emotional',
    phases: {TtcDayPhase.any},
    titleEn: "Stress is real, and it's not your fault",
    titleHi: 'Stress asli hai - aur ye aapki galti nahi hai',
    bodyEn:
        'Very high stress that goes on for a long time can delay or stop ovulation, so the link is real. But the true picture is smaller than the one people repeat. Everyday work stress and everyday worry are not what stops a healthy couple from conceiving.\n\nThis matters because "just relax" is one of the most painful things anyone can say to you right now. It turns a medical unknown into a personal failure. It isn\'t one.',
    bodyHi:
        'Tez aur lambe samay ka stress ovulation ko der kar sakta hai ya rok sakta hai - toh ye connection kalpana nahi hai. Lekin sach us baat se kaafi chhota hai jo log dohraate hain: rozmarra ka office stress aur aam chinta, kisi healthy couple ko conceive karne se nahi rokti.\n\nYe isliye maayne rakhta hai kyunki "bas relax karo" is chapter mein kahi jaane wali sabse takleef dene wali baat hai. Ye ek medical uncertainty ko personal failure bana deti hai. Wo hai nahi.',
    takeawayEn: '"Just relax" isn\'t advice. Your stress didn\'t cause this.',
    takeawayHi: '"Bas relax karo" salaah nahi hai. Aapke stress ne ye nahi kiya.',
  ),
  TtcInsight(
    id: 'caffeine',
    topic: 'lifestyle',
    phases: {TtcDayPhase.any},
    titleEn: "You don't have to give up chai",
    titleHi: 'Chai chhodne ki zaroorat nahi hai',
    bodyEn:
        "Most advice puts the limit at around 200mg of caffeine a day while you're trying and during pregnancy. In Indian terms, that's about two to three cups of home-made chai, or about two cups of filter coffee.\n\nWhat's easy to miss is caffeine in other places. Cola, energy drinks, green tea and dark chocolate all add to the total. So the useful habit isn't cutting out chai. It's noticing everything else.",
    bodyHi:
        'Zyadatar guidance conceive karne ki koshish aur pregnancy ke dauraan roz lagbhag 200mg caffeine ki hadd batati hai. Practically, ye ghar ki do-teen cup chai hai, ya lagbhag do cup filter coffee.\n\nJo cheez aksar chhoot jaati hai wo hai chhupi hui caffeine: cola, energy drinks, green tea aur dark chocolate - sab total mein judte hain. Toh kaam ki aadat chai chhodna nahi hai - baaki sab ko notice karna hai.',
    takeawayEn: 'Two to three cups of chai is fine. Count the cola too.',
    takeawayHi: 'Do-teen cup chai theek hai. Cola bhi gina karein.',
  ),
  TtcInsight(
    id: 'lh_strips',
    topic: 'fertility',
    phases: {TtcDayPhase.beforeWindow, TtcDayPhase.window},
    titleEn: 'What an ovulation strip really tells you',
    titleHi: 'Ovulation strip asal mein kya batati hai',
    bodyEn:
        'An LH strip picks up a rise in LH, the hormone that triggers ovulation. This rise usually comes twelve to thirty-six hours before an egg is released. So a positive means "soon", not "now". It\'s a sign you can relax about timing for the next couple of days, not a reason to rush.\n\nThere are two honest limits. A rise doesn\'t prove an egg was released. And with PCOS, LH can stay high all month, so strips can confuse more than they help. Your doctor may suggest another way to track.',
    bodyHi:
        'LH strip us hormone surge ko pakadti hai jo aam taur par egg release hone se baarah se chhattis ghante pehle aata hai. Toh positive ka matlab hai "jald", "abhi" nahi - aur ye agle do din timing ke baare mein aaram karne ka signal hai, bhaagne ka nahi.\n\nDo imaandaar hadd. Surge ye sabit nahi karta ki egg sach mein release hua. Aur PCOS mein LH poora mahina high reh sakta hai, jisse strips madad ke bajaye confuse karti hain - doctor koi doosra tareeka bata sakte hain.',
    takeawayEn: 'A positive strip means soon, not now. With PCOS it can mislead.',
    takeawayHi: 'Positive strip ka matlab "jald" hai, "abhi" nahi. PCOS mein ye galat raasta dikha sakti hai.',
  ),
  TtcInsight(
    id: 'vitamin_d_india',
    topic: 'nutrition',
    phases: {TtcDayPhase.any},
    titleEn: 'Low vitamin D is very common in India',
    titleHi: 'Vitamin D ki kami India mein chupchaap aam hai',
    bodyEn:
        "Study after study finds that most Indian adults are low in vitamin D, even people who spend time outdoors. Sunscreen, poor air quality, indoor work, darker skin and covered clothing all cut down how much your body makes.\n\nIt's one of the cheapest blood tests there is, and one of the easiest things to fix. It's worth testing both of you. Low vitamin D has been linked to sperm quality as well as to how regular cycles are.",
    bodyHi:
        'Ek ke baad ek study batati hai ki zyadatar Indian adults mein vitamin D kam hai - un logon mein bhi jo dhoop mein rehte hain. Sunscreen, hawa ki quality, indoor kaam, gehri skin aur dhaka hua kapda - sab kam kar dete hain ki asal mein kitna banta hai.\n\nYe sabse saste blood tests mein se ek hai aur sabse aasaani se theek hone wali cheez. Dono partners ka test karwana theek hai: kam vitamin D ka sambandh sperm quality aur cycle ki regularity dono se juda hai.',
    takeawayEn: "You can both test for this. It's cheap and easy to fix.",
    takeawayHi: 'Dono ka test ho sakta hai. Sasta hai aur theek ho jaata hai.',
  ),
  TtcInsight(
    id: 'heat_and_sperm',
    topic: 'male',
    phases: {TtcDayPhase.any},
    titleEn: 'Heat matters more than most men are told',
    titleHi: 'Garmi utni maayne rakhti hai jitna aksar bataya nahi jaata',
    bodyEn:
        "Sperm are made best at a couple of degrees below core body temperature. That's the whole reason the testes sit outside the body. Heat that goes on for a long time works against this: long hot baths, saunas, a laptop resting on the lap for hours, and very tight synthetic underwear in Indian summers.\n\nNone of these is a disaster and none is permanent. But they're some of the easiest things on this whole list to change, and they cost nothing.",
    bodyHi:
        'Sperm banne ka kaam body ke core temperature se do degree kam par sabse accha hota hai - isi wajah se testes body ke bahar hote hain. Lagatar garmi iske khilaf jaati hai: lambe garam paani ke nahaane, sauna, ghanton tak god par laptop, aur Indian garmi mein bahut tight synthetic underwear.\n\nInmein se koi bhi aafat nahi hai aur na hi permanent. Lekin poori list mein ye badalne ke sabse aasaan cheezein hain, aur inmein kuch kharch nahi hota.',
    takeawayEn: 'Laptop off the lap. Loose cotton. It costs nothing to try.',
    takeawayHi: 'Laptop god se hatayein. Dheela cotton pehnein. Koshish muft hai.',
  ),
  TtcInsight(
    id: 'pcos_basics',
    topic: 'medical',
    phases: {TtcDayPhase.any},
    titleEn: 'PCOS explained, without the panic',
    titleHi: 'PCOS - bina ghabrahat ke',
    bodyEn:
        "PCOS is a hormone pattern, not a disease you either have or don't. It often means you ovulate irregularly or not very often. That makes timing harder, not impossible. Many women with PCOS conceive naturally, and many more with straightforward help such as ovulation induction (medicine that helps you ovulate).\n\nWhat helps again and again: regular movement, food that keeps blood sugar steady, good sleep, and working with a doctor rather than around one. What doesn't help is any one food, tea or powder sold as a cure.",
    bodyHi:
        'PCOS ek hormonal pattern hai, aisi bimari nahi jo ya toh hoti hai ya nahi. Aam taur par iska matlab hai ovulation irregular ya kam hota hai - jisse timing mushkil hoti hai, namumkin nahi. Bahut si auratein PCOS ke saath naturally conceive karti hain, aur bahut si thodi si madad se jaise ovulation induction.\n\nJo hamesha madad karta hai: regular movement, aisa khana jo blood sugar sthir rakhe, neend, aur doctor ke saath kaam karna - unke bina nahi. Jo madad nahi karta: koi bhi ek khana, chai ya powder jo "ilaaj" bol kar becha jaata hai.',
    takeawayEn: 'PCOS makes timing harder, not impossible. No single food cures it.',
    takeawayHi: 'PCOS timing mushkil karta hai, namumkin nahi. Koi ek khana iska ilaaj nahi.',
  ),
  TtcInsight(
    id: 'two_week_wait',
    topic: 'emotional',
    phases: {TtcDayPhase.waiting},
    titleEn: 'Why the wait feels longer than it is',
    titleHi: 'Intezaar asal se lamba kyun lagta hai',
    bodyEn:
        "The time between ovulation and your period is about two weeks, and it's the part of the cycle with nothing to do. Every twinge starts to feel like a clue. Early pregnancy signs and normal pre-period signs come from the same hormone. That's why they feel exactly the same, and why watching for symptoms can't tell you anything.\n\nThe kindest thing you can do with these days is give them a purpose other than watching. Something to finish, somewhere to go, someone to see.",
    bodyHi:
        'Ovulation aur period ke beech ka waqt lagbhag do hafte ka hota hai, aur cycle ka yahi hissa hai jismein karne ko kuch nahi hota. Har chhota sa ehsaas sabooot lagne lagta hai. Shuruaati pregnancy ke symptoms aur aam period se pehle ke symptoms ek hi hormone se bante hain - isiliye wo bilkul ek jaise lagte hain, aur isiliye symptom dekhna kuch bata nahi sakta.\n\nIn dino ke saath sabse achhi baat ye ki jaa sakti hai ki inhe dekhne ke alawa koi maqsad de dein. Kuch poora karne ko, kahin jaane ko, kisi se milne ko.',
    takeawayEn: "Early pregnancy and a coming period feel the same. Symptoms can't tell you which.",
    takeawayHi: 'Shuruaati pregnancy aur period se pehle ek jaisa lagta hai. Symptom dekhne se pata nahi chalta.',
  ),
  TtcInsight(
    id: 'sleep_and_hormones',
    topic: 'lifestyle',
    phases: {TtcDayPhase.any},
    titleEn: 'Sleep is a fertility habit, not a luxury',
    titleHi: 'Neend ek fertility aadat hai, aish nahi',
    bodyEn:
        "The hormones behind ovulation and making sperm are released on a daily rhythm linked to sleep and darkness. Shift work and short nights, night after night, upset that rhythm for both of you.\n\nSeven to nine hours, at about the same time each night, is the whole advice. If you can't change your shift work, and for many people in India that's how it is, keeping your schedule steady matters more than the hours themselves.",
    bodyHi:
        'Jo hormones ovulation aur sperm banne ko chalate hain, wo neend aur andhere se judi ek roz ki rhythm par nikalte hain. Shift work aur lagatar chhoti raatein us rhythm ko couple ke dono taraf bigaadti hain.\n\nSaat se nau ghante, roz lagbhag ek hi samay - poori salaah bas itni hai. Agar shift work badla nahi ja sakta - aur India mein bahut logon ke liye nahi badal sakta - toh jo bhi schedule hai uski consistency, ghanton se zyada maayne rakhti hai.',
    takeawayEn: 'A regular bedtime beats more hours. For both of you.',
    takeawayHi: 'Ek hi samay sona, zyada ghanton se behtar hai. Dono ke liye.',
  ),
  TtcInsight(
    id: 'weight_and_cycles',
    topic: 'lifestyle',
    phases: {TtcDayPhase.any},
    titleEn: 'Small weight changes can restart cycles',
    titleHi: 'Wazan mein chhota badlaav cycles wapas la sakta hai',
    bodyEn:
        "Body fat helps the body make and control oestrogen. So cycles can become irregular at both ends of the range, when weight is too high or too low. Athletes and people who don't eat enough lose their cycles as often as anyone.\n\nWhere weight plays a part, research keeps finding that a change of around five per cent of body weight is often enough to bring ovulation back. That's a small number, and it's the only reason we mention it. It's not here to make anyone feel judged.",
    bodyHi:
        'Body fat us tareeke ka hissa hai jisse body oestrogen banata aur sambhalta hai, isliye cycles range ke dono siron par irregular ho sakte hain - bahut zyada aur bahut kam, dono par. Athletes aur kam khaane wale log utni hi baar cycles khote hain jitne aur koi.\n\nJahan wazan ek wajah hai, research baar-baar batati hai ki body weight ka lagbhag paanch pratishat badlaav aksar ovulation wapas laane ke liye kaafi hota hai. Ye sach mein chhota number hai, aur isi wajah se ye batane layak hai - kisi ko judge karne ke liye nahi.',
    takeawayEn: 'Around five per cent is often enough. Both directions count.',
    takeawayHi: 'Lagbhag paanch pratishat aksar kaafi hota hai. Dono taraf ginti hai.',
  ),
  TtcInsight(
    id: 'semen_analysis',
    topic: 'male',
    phases: {TtcDayPhase.any},
    titleEn: 'The test that should come first, and rarely does',
    titleHi: 'Wo test jo pehle hona chahiye, aur aksar hota nahi',
    bodyEn:
        "A male factor plays a part in roughly forty to fifty per cent of couples who find it hard to conceive. Yet the woman is usually tested first, with tests that are more invasive, cost more and take longer.\n\nA semen analysis is a simple, low-cost, same-day test. Doing it early doesn't accuse anyone. It just means you're looking at the whole picture, not half of it. If the result is unexpected, repeat it after two to three months before deciding anything. Results can vary a lot from one sample to the next.",
    bodyHi:
        'Jo couples conceive karne mein mushkil jhelte hain, unmein lagbhag chalis se pachas pratishat mein mard ki taraf ka factor shaamil hota hai. Phir bhi aam taur par pehle aurat ke test hote hain - jo zyada takleefdeh, zyada mehnge aur zyada dheere hote hain.\n\nSemen analysis ek simple, sasta, usi din ka test hai. Ise jaldi karwana kisi par ilzaam nahi hai - iska bas matlab hai ki aap poori tasveer dekh rahe hain, aadhi nahi. Agar result unexpected aaye, toh nateeja nikalne se pehle do-teen mahine baad dobara karwayein; samples ke beech results kaafi badalte hain.',
    takeawayEn: 'Cheap, quick, and it checks the half that usually gets skipped.',
    takeawayHi: 'Sasta, jaldi - aur wo aadha hissa dekhta hai jo aksar chhoot jaata hai.',
  ),
  TtcInsight(
    id: 'indian_plate',
    topic: 'nutrition',
    phases: {TtcDayPhase.any},
    titleEn: 'A fertility diet looks a lot like a normal Indian thali',
    titleHi: 'Fertility diet dikhne mein aam Indian thali jaisi hi hai',
    bodyEn:
        "There's no fertility superfood. What research supports is a pattern: whole grains instead of refined ones, dal and other plant protein, lots of vegetables, healthy fats, and less ultra-processed food and sugar.\n\nA thali with roti or brown rice, dal, a sabzi, dahi and a little ghee already covers most of that. The changes worth making are usually small swaps, not big replacements. Try bajra or jowar in place of maida, and add one more vegetable.",
    bodyHi:
        'Koi fertility superfood nahi hota. Research jise support karti hai wo ek pattern hai: refined ki jagah sabut anaaj, dal aur doosra plant protein, khoob sabziyan, achhi fats, aur kam ultra-processed khana aur cheeni.\n\nRoti ya brown rice, dal, sabzi, dahi aur thoda ghee wali thali mein ye zyadatar pehle se hai. Jo badlaav karne layak hain wo aksar swap hain, replacement nahi - maida ki jagah bajra ya jowar, aur ek extra sabzi.',
    takeawayEn: 'No superfood needed. Swap maida for bajra and add one vegetable.',
    takeawayHi: 'Koi superfood nahi. Maida ki jagah bajra, aur ek sabzi zyada.',
  ),
  TtcInsight(
    id: 'amh_meaning',
    topic: 'medical',
    phases: {TtcDayPhase.any},
    titleEn: "AMH isn't a fertility score",
    titleHi: 'AMH koi fertility score nahi hai',
    bodyEn:
        "AMH gives an estimate of how many eggs are left, which is the size of your egg reserve. It says very little about the quality of those eggs. On its own, it's a poor guide to whether you'll conceive naturally.\n\nIts real use is planning. It helps a specialist predict how the ovaries will respond to IVF stimulation, the medicines used to grow eggs. A low AMH with regular cycles isn't a verdict, and it's no reason to book treatment in a panic. Ask what the number changes about the plan. If the answer is nothing, then it changes nothing.",
    bodyHi:
        'AMH andaaza lagata hai ki kitne eggs bache hain - reserve ki ginti. Ye un eggs ki quality ke baare mein bahut kam batata hai, aur akele ye kharaab predictor hai ki aurat naturally conceive karegi ya nahi.\n\nIska asli istemaal planning hai: ye specialist ko batata hai ki ovaries IVF stimulation par kaisa jawab denge. Regular cycles wali aurat mein kam AMH koi faisla nahi hai, aur ghabra kar treatment book karne ki wajah bhi nahi. Poochhein ki ye number plan mein kya badalta hai - agar jawab "kuch nahi" hai, toh sach mein kuch nahi badalta.',
    takeawayEn: 'AMH counts eggs, not chances. Ask what it changes about the plan.',
    takeawayHi: 'AMH eggs ginta hai, mauke nahi. Poochhein ki ye plan mein kya badalta hai.',
  ),
  TtcInsight(
    id: 'alcohol_smoking',
    topic: 'lifestyle',
    phases: {TtcDayPhase.any},
    titleEn: 'The two habits with the clearest evidence',
    titleHi: 'Do cheezein jinke saboot sabse saaf hain',
    bodyEn:
        "Most lifestyle advice about fertility is soft. Two things aren't. Smoking, including breathing in other people's smoke at home, is clearly linked to lower fertility in both partners and to earlier menopause. Heavy drinking is linked to upset ovulation and lower sperm quality.\n\nA social drink now and then while trying isn't the same as heavy drinking, and the evidence there is mixed. Smoking has no such grey area, for either of you.",
    bodyHi:
        'Is field ki zyadatar lifestyle salaah narm hoti hai. Do cheezein nahi hain. Smoking - ghar mein passive smoking bhi - dono partners mein kam fertility aur jaldi menopause se lagatar judi hai. Zyada sharab, ovulation bigadne aur kam sperm quality se judi hai.\n\nKoshish ke dauraan kabhi-kabhaar social drinking, heavy drinking jaisi baat nahi hai, aur wahan saboot sach mein mile-jule hain. Smoking mein aisa koi grey area nahi hai - dono ke liye.',
    takeawayEn: "No amount of smoking is safe here. Other people's smoke counts too.",
    takeawayHi: 'Yahan smoking ki koi safe matra nahi hai. Passive bhi ginti hai.',
  ),
  TtcInsight(
    id: 'bbt_truth',
    topic: 'fertility',
    phases: {TtcDayPhase.window, TtcDayPhase.waiting},
    titleEn: 'Temperature tells you afterwards, not before',
    titleHi: 'Temperature baad mein batata hai, pehle nahi',
    bodyEn:
        "Basal body temperature, your temperature at rest, goes up a little after ovulation and stays up. It's useful for confirming that ovulation happened, and for learning the shape of your own cycle over a few months.\n\nWhat it can't do is warn you that ovulation is coming. By the time your temperature rises, the window has mostly closed. So treat it as a record, not an alarm. And if measuring at 6am every day makes all this feel heavier, it's perfectly fine to stop.",
    bodyHi:
        'Basal body temperature ovulation ke baad thoda badh jaata hai aur bada rehta hai. Ye ye confirm karne ke liye sach mein kaam ka hai ki ovulation hua, aur kuch mahinon mein apne cycle ka aakaar samajhne ke liye.\n\nJo ye nahi kar sakta wo hai aane wale ovulation ki khabar dena - jab tak temperature badhta hai, window lagbhag band ho chuki hoti hai. Toh ise record maanein, alarm nahi. Aur agar roz subah 6 baje naapna poori baat ko bhaari bana deta hai, toh rok dena bilkul theek faisla hai.',
    takeawayEn: "It confirms ovulation happened. It can't warn you it's coming.",
    takeawayHi: 'Ye batata hai ki ovulation hua. Aane se pehle nahi bata sakta.',
  ),
  TtcInsight(
    id: 'lubricant',
    topic: 'fertility',
    phases: {TtcDayPhase.beforeWindow, TtcDayPhase.window},
    titleEn: "Most lubricants aren't sperm-friendly",
    titleHi: 'Zyadatar lubricants sperm ke liye theek nahi hote',
    bodyEn:
        "This is small, rarely mentioned, and easy to fix. Many everyday lubricants, and saliva too, make it harder for sperm to move. If you use one, look for a product labelled fertility-friendly or sperm-safe.\n\nIt's unlikely to be the reason you haven't conceived yet. But it's a two-minute change that costs almost nothing, just like taking the laptop off his lap.",
    bodyHi:
        'Ye chhoti baat hai, kam batayi jaati hai, aur aasaani se theek ho jaati hai. Bahut se aam lubricants - aur thook - sperm ke chalne ki kshamta kam kar dete hain. Agar aap istemaal karte hain, toh aisa product dhoondhein jispar saaf likha ho fertility-friendly ya sperm-safe.\n\nYe shayad hi wajah hogi ki couple conceive nahi kar paya. Lekin ye do minute ka badlaav hai jismein kuch kharch nahi - yaani laptop god se hataane wali hi category.',
    takeawayEn: 'If you use one, choose a fertility-friendly product.',
    takeawayHi: 'Agar istemaal karte hain, toh fertility-friendly product chunein.',
  ),
  TtcInsight(
    id: 'thyroid',
    topic: 'medical',
    phases: {TtcDayPhase.any},
    titleEn: 'The thyroid test worth doing early',
    titleHi: 'Thyroid test jo jaldi karwana theek hai',
    bodyEn:
        "An underactive thyroid can cause irregular cycles, upset ovulation and raise the risk of early miscarriage. It's common in Indian women, often without clear symptoms.\n\nTSH is a low-cost blood test, and when it's off, treatment is usually one tablet a day. Of everything in a fertility check-up, it's one of the cheapest to test and one of the easiest to put right.",
    bodyHi:
        'Kam kaam karta thyroid irregular cycles kar sakta hai, ovulation bigaad sakta hai aur shuruaati miscarriage ka khatra badha sakta hai - aur ye Indian auraton mein aam hai, aksar bina saaf symptoms ke.\n\nTSH ek sasta blood test hai, aur jab ye theek nahi hota, toh ilaaj aam taur par roz ki ek goli hoti hai. Poore fertility work-up mein ye check karne ke liye sabse saste mein se ek hai, aur theek karne ke liye sabse seedha.',
    takeawayEn: 'A cheap test, a common problem, usually one tablet.',
    takeawayHi: 'Sasta test, aam samasya, aam taur par ek goli.',
    forPartner: false,
  ),
  TtcInsight(
    id: 'talking_to_family',
    topic: 'emotional',
    phases: {TtcDayPhase.any},
    titleEn: "You don't have to answer",
    titleHi: 'Aapko jawab na dene ka haq hai',
    bodyEn:
        '"Good news kab de rahe ho?" comes up at every wedding, every festival and most family calls. It\'s usually meant kindly, but it can land like a bill.\n\nYou don\'t owe anyone an update on your body. A short, kind line you can repeat works better than a new answer each time. Something like "we\'ll tell you first when there\'s something to tell." Agree on one line together, so neither of you is making it up alone in a room full of relatives.',
    bodyHi:
        '"Good news kab de rahe ho?" har shaadi, har tyohaar aur zyadatar family calls mein aata hai. Aksar ye pyaar se poochha jaata hai, aur bill jaisa lagta hai.\n\nAapko apne body ka status update kisi ko dena zaroori nahi hai. Har baar naya jawab sochne se behtar hai ek chhoti, meethi, dohraane layak line - jaise "jab batane layak kuch hoga, sabse pehle aapko batayenge." Ek line dono milkar tay kar lein, taaki rishtedaaron se bhare kamre mein koi akela na sochta rahe.',
    takeawayEn: 'Agree on one line together. Use it every time.',
    takeawayHi: 'Ek line saath mein tay karein. Har baar wahi istemaal karein.',
  ),
  TtcInsight(
    id: 'exercise_amount',
    topic: 'lifestyle',
    phases: {TtcDayPhase.any},
    titleEn: "Movement helps, until it's too much",
    titleHi: 'Movement madad karta hai - jab tak zyada na ho jaye',
    bodyEn:
        "Moderate, regular activity helps your hormone balance, how your body uses insulin, and your sleep. It helps a lot with PCOS. Around thirty minutes on most days is the usual advice, and a brisk walk counts.\n\nThe other side is real too. Very hard training, especially when you're not eating enough, can stop ovulation completely. If your cycles have become irregular since starting a new training routine, mention it to a doctor instead of pushing through.",
    bodyHi:
        'Moderate regular activity hormone balance, insulin sensitivity aur neend ko support karti hai, aur PCOS mein khaas madad karti hai. Zyadatar dino mein lagbhag tees minute aam salaah hai, aur tez chalna bhi ginta hai.\n\nDoosra sira bhi asli hai: bahut tez training, khaaskar kam khaane ke saath, ovulation poori tarah rok sakti hai. Agar naye training routine ke baad se cycles irregular ho gaye hain, toh use jhelte rehne ke bajaye doctor ko batana theek hai.',
    takeawayEn: 'Thirty minutes most days. A brisk walk counts.',
    takeawayHi: 'Zyadatar dino mein tees minute. Tez chalna bhi ginta hai.',
  ),
  TtcInsight(
    id: 'ivf_is_not_failure',
    topic: 'medical',
    phases: {TtcDayPhase.any},
    titleEn: 'Treatment is a path, not a verdict',
    titleHi: 'Ilaaj ek raasta hai, faisla nahi',
    bodyEn:
        'Couples often put off seeing a specialist because going there feels like admitting something. It helps to say this plainly: ovulation induction, IUI and IVF are steps on a path, and many couples only need the first one.\n\nGoing early costs you nothing but a consultation. Waiting can cost time, and for some causes time matters. Whatever you decide, decide it together and with good information, not because a relative gave an opinion at a wedding.',
    bodyHi:
        'Couples aksar specialist ke paas jaane mein der karte hain kyunki wahan pahunchna haar maanne jaisa lagta hai. Ise saaf kehna zaroori hai: ovulation induction, IUI aur IVF ek raaste ke padaav hain, aur bahut se couples ko inmein se sirf pehla hi chahiye hota hai.\n\nJaldi jaane mein ek consultation ke alawa kuch kharch nahi. Intezaar karne mein waqt ja sakta hai, jo kuch wajahon ke liye maayne rakhta hai. Jo bhi tay karein, saath mein karein aur jaankari ke saath karein - isliye nahi ki kisi rishtedaar ne shaadi mein apni raay de di.',
    takeawayEn: 'Going early costs one consultation. Decide together, with facts.',
    takeawayHi: 'Ek consultation ka kharch bas ek consultation hai. Saath mein, jaankari ke saath tay karein.',
  ),
];


// =============================================================================
//  Phase cards: written for one stretch of the cycle
// -----------------------------------------------------------------------------
//  TTC gap analysis, "Behind: Home & daily", P1. A card that says "your period
//  came" is only true on a period day, so these live in their OWN list rather
//  than in `ttcInsights`:
//
//   * `ttcInsights` is still rotated by date alone in places that know nothing
//     about the cycle (the partner screen, the older Today screen, today's
//     home card until it is wired to `ttcInsightsForPhase`). A phase card in
//     that list would turn up on the wrong day, and on a day like a negative
//     test that is not a small mistake.
//   * `ttcInsights` also promises a Hindi side that differs from the English
//     (`test/ttc_daily_test.dart`). New work is English, so these repeat the
//     English in the Hi fields, as every English-only piece in the app does.
//
//  The cost: `ttcInsightReadById` resolves `ttcInsights` only, so a phase card
//  opens fine (`openTtcInsight` takes the object) but is not offered in
//  another insight's "Read next" rail. That is the right way round.
//
//  Facts agree with `reads/ttc_reads_conceiving.dart` and
//  `reads/ttc_reads_waiting.dart`: a window of about six days ending on
//  ovulation day, every one to two days is enough, implantation 6 to 12 days
//  after ovulation, a test is reliable from the day the period is due, test
//  again in three days to a week after a late negative.
// =============================================================================

const List<TtcInsight> ttcPhaseInsights = [
  // Period days (cycle days 1 to 5 of a logged period)
  TtcInsight(
    id: 'period_new_start',
    topic: 'emotional',
    phases: {TtcDayPhase.period},
    titleEn: "Your period came. It's a new start",
    titleHi: "Your period came. It's a new start",
    bodyEn:
        "If you were hoping this month would be different, it's okay to feel low today. A period doesn't mean anything is wrong. Most couples take several months, and each cycle is a fresh try.\n\nYou don't need a plan today. Today can be for looking after yourself.",
    bodyHi:
        "If you were hoping this month would be different, it's okay to feel low today. A period doesn't mean anything is wrong. Most couples take several months, and each cycle is a fresh try.\n\nYou don't need a plan today. Today can be for looking after yourself.",
    takeawayEn: "Each cycle starts fresh. Last month doesn't count against this one.",
    takeawayHi: "Each cycle starts fresh. Last month doesn't count against this one.",
    forPartner: false,
  ),
  TtcInsight(
    id: 'period_day_one',
    topic: 'fertility',
    phases: {TtcDayPhase.period},
    titleEn: "Day 1 is worth writing down",
    titleHi: "Day 1 is worth writing down",
    bodyEn:
        "The first day of real flow, not spotting, is day 1 of your new cycle. Logging that one date lets us show your fertile days more closely next time.\n\nIf you can, note how long the bleeding lasts too. After a few months, these dates are some of the most useful notes you can take to a doctor.",
    bodyHi:
        "The first day of real flow, not spotting, is day 1 of your new cycle. Logging that one date lets us show your fertile days more closely next time.\n\nIf you can, note how long the bleeding lasts too. After a few months, these dates are some of the most useful notes you can take to a doctor.",
    takeawayEn: "Log day 1. Everything else in your cycle is counted from it.",
    takeawayHi: "Log day 1. Everything else in your cycle is counted from it.",
    forPartner: false,
  ),
  TtcInsight(
    id: 'period_be_gentle',
    topic: 'lifestyle',
    phases: {TtcDayPhase.period},
    titleEn: "Be gentle with yourself today",
    titleHi: "Be gentle with yourself today",
    bodyEn:
        "Period days can bring cramps and tiredness, and trying can make them feel heavier. It's fine to do less today. A hot-water bottle or an early night counts as looking after yourself.\n\nIf the pain stops you getting through your day, or painkillers don't help, mention it to a doctor. Strong period pain isn't something you have to put up with.",
    bodyHi:
        "Period days can bring cramps and tiredness, and trying can make them feel heavier. It's fine to do less today. A hot-water bottle or an early night counts as looking after yourself.\n\nIf the pain stops you getting through your day, or painkillers don't help, mention it to a doctor. Strong period pain isn't something you have to put up with.",
    takeawayEn: "Doing less today is allowed.",
    takeawayHi: "Doing less today is allowed.",
    forPartner: false,
  ),
  TtcInsight(
    id: 'period_what_it_means',
    topic: 'medical',
    phases: {TtcDayPhase.period},
    titleEn: "What this period does and doesn't mean",
    titleHi: "What this period does and doesn't mean",
    bodyEn:
        "A period tells you one thing: this cycle didn't lead to a pregnancy. It doesn't mean something is wrong with either of you. It doesn't mean anything you did caused it, or that next month will go the same way.\n\nFor most healthy couples, more time is the answer. If you've been trying for a year, or six months if you're over thirty-five, that's a good time to see a doctor.",
    bodyHi:
        "A period tells you one thing: this cycle didn't lead to a pregnancy. It doesn't mean something is wrong with either of you. It doesn't mean anything you did caused it, or that next month will go the same way.\n\nFor most healthy couples, more time is the answer. If you've been trying for a year, or six months if you're over thirty-five, that's a good time to see a doctor.",
    takeawayEn: "A period closes one cycle. It doesn't decide the next one.",
    takeawayHi: "A period closes one cycle. It doesn't decide the next one.",
  ),
  TtcInsight(
    id: 'period_nothing_to_time',
    topic: 'fertility',
    phases: {TtcDayPhase.period},
    titleEn: "There's nothing to time this week",
    titleHi: "There's nothing to time this week",
    bodyEn:
        "While your period is on, there's nothing to plan or count. Your fertile days come later in the cycle, and your home will show them as they get close.\n\nThis is a good week for small, steady things. Keep taking your folic acid and try to get to bed on time. None of it has to be perfect.",
    bodyHi:
        "While your period is on, there's nothing to plan or count. Your fertile days come later in the cycle, and your home will show them as they get close.\n\nThis is a good week for small, steady things. Keep taking your folic acid and try to get to bed on time. None of it has to be perfect.",
    takeawayEn: "Nothing to time this week. We'll show you when your window is near.",
    takeawayHi: "Nothing to time this week. We'll show you when your window is near.",
  ),
  // The waiting days (after the window, until the period is due)
  TtcInsight(
    id: 'wait_first_week',
    topic: 'fertility',
    phases: {TtcDayPhase.waiting},
    titleEn: "What's happening inside this week",
    titleHi: "What's happening inside this week",
    bodyEn:
        "If an egg was fertilised, it's now a tiny ball of cells drifting down the tube towards the womb. It takes about five days to get there, and you won't feel any of it.\n\nProgesterone rises after every ovulation, pregnant or not. So sore breasts or bloating this week are normal in any cycle.",
    bodyHi:
        "If an egg was fertilised, it's now a tiny ball of cells drifting down the tube towards the womb. It takes about five days to get there, and you won't feel any of it.\n\nProgesterone rises after every ovulation, pregnant or not. So sore breasts or bloating this week are normal in any cycle.",
    takeawayEn: "This week feels the same in every cycle. That's normal.",
    takeawayHi: "This week feels the same in every cycle. That's normal.",
  ),
  TtcInsight(
    id: 'wait_implantation',
    topic: 'fertility',
    phases: {TtcDayPhase.waiting},
    titleEn: "When implantation happens",
    titleHi: "When implantation happens",
    bodyEn:
        "If there's a pregnancy, it settles into the lining of the womb between 6 and 12 days after ovulation. For most, it's around day 8 to 10. Only after that does your body start making hCG, the hormone a test looks for.\n\nNothing you do can help or disturb this. Work, lifting everyday things and sex are all fine.",
    bodyHi:
        "If there's a pregnancy, it settles into the lining of the womb between 6 and 12 days after ovulation. For most, it's around day 8 to 10. Only after that does your body start making hCG, the hormone a test looks for.\n\nNothing you do can help or disturb this. Work, lifting everyday things and sex are all fine.",
    takeawayEn: "Implantation looks after itself. Everyday life is fine.",
    takeawayHi: "Implantation looks after itself. Everyday life is fine.",
  ),
  TtcInsight(
    id: 'wait_symptoms_same',
    topic: 'emotional',
    phases: {TtcDayPhase.waiting},
    titleEn: "Why your body can't give you the answer yet",
    titleHi: "Why your body can't give you the answer yet",
    bodyEn:
        "Tender breasts, cramps and feeling tired can mean a period is on its way. They can also mean you're pregnant. The same hormone, progesterone, causes both, so they feel the same.\n\nIt's natural to notice every twinge. Try not to read each one as a yes or a no. It's your body doing what it does every month.",
    bodyHi:
        "Tender breasts, cramps and feeling tired can mean a period is on its way. They can also mean you're pregnant. The same hormone, progesterone, causes both, so they feel the same.\n\nIt's natural to notice every twinge. Try not to read each one as a yes or a no. It's your body doing what it does every month.",
    takeawayEn: "Early signs and period signs feel the same. Only a test can tell.",
    takeawayHi: "Early signs and period signs feel the same. Only a test can tell.",
  ),
  TtcInsight(
    id: 'wait_test_timing',
    topic: 'medical',
    phases: {TtcDayPhase.waiting},
    titleEn: "When a test starts to mean something",
    titleHi: "When a test starts to mean something",
    bodyEn:
        "A home test looks for hCG, which only starts after implantation. Before about 11 days after ovulation, most tests say no even when there is a pregnancy.\n\nFrom the day your period is due, most home tests give an answer you can rely on. Testing earlier won't harm anything, but an early negative can hurt for no reason.",
    bodyHi:
        "A home test looks for hCG, which only starts after implantation. Before about 11 days after ovulation, most tests say no even when there is a pregnancy.\n\nFrom the day your period is due, most home tests give an answer you can rely on. Testing earlier won't harm anything, but an early negative can hurt for no reason.",
    takeawayEn: "Wait for the day your period is due. That's when a test can tell you something.",
    takeawayHi: "Wait for the day your period is due. That's when a test can tell you something.",
  ),
  TtcInsight(
    id: 'wait_pick_test_day',
    topic: 'emotional',
    phases: {TtcDayPhase.waiting},
    titleEn: "Pick your test day now",
    titleHi: "Pick your test day now",
    bodyEn:
        "Choosing your test day in advance saves you asking the question every morning. The day your period is due is a good one. Write it down and tell your partner.\n\nKeep only one or two tests at home. It's easier to wait when there isn't a big pack in the drawer.",
    bodyHi:
        "Choosing your test day in advance saves you asking the question every morning. The day your period is due is a good one. Write it down and tell your partner.\n\nKeep only one or two tests at home. It's easier to wait when there isn't a big pack in the drawer.",
    takeawayEn: "Decide your test day once, so you don't decide it every morning.",
    takeawayHi: "Decide your test day once, so you don't decide it every morning.",
  ),
  TtcInsight(
    id: 'wait_something_kind',
    topic: 'emotional',
    phases: {TtcDayPhase.waiting},
    titleEn: "Plan something kind for yourself",
    titleHi: "Plan something kind for yourself",
    bodyEn:
        "The second week of the wait is often the harder one. Feeling tired or low is common in this half of every cycle, and it says nothing about whether this month worked.\n\nGive these evenings something else to hold. Meet a friend, cook a dish you love, or start a film you've been saving.",
    bodyHi:
        "The second week of the wait is often the harder one. Feeling tired or low is common in this half of every cycle, and it says nothing about whether this month worked.\n\nGive these evenings something else to hold. Meet a friend, cook a dish you love, or start a film you've been saving.",
    takeawayEn: "Put one thing you enjoy in your week.",
    takeawayHi: "Put one thing you enjoy in your week.",
  ),
  TtcInsight(
    id: 'wait_live_normally',
    topic: 'lifestyle',
    phases: {TtcDayPhase.waiting},
    titleEn: "You can carry on as normal",
    titleHi: "You can carry on as normal",
    bodyEn:
        "Keep taking folic acid, 400 micrograms a day, and keep caffeine under 200 mg. Skip alcohol and smoking, as you would if you knew you were pregnant.\n\nThe rest of life can go on. Work, travel and the exercise you already do are all fine. Warm baths are fine too, but save very hot tubs and saunas until you know.",
    bodyHi:
        "Keep taking folic acid, 400 micrograms a day, and keep caffeine under 200 mg. Skip alcohol and smoking, as you would if you knew you were pregnant.\n\nThe rest of life can go on. Work, travel and the exercise you already do are all fine. Warm baths are fine too, but save very hot tubs and saunas until you know.",
    takeawayEn: "Live as usual, with folic acid and no alcohol.",
    takeawayHi: "Live as usual, with folic acid and no alcohol.",
  ),
  // Late (past her usual cycle length)
  TtcInsight(
    id: 'late_how_to_test',
    topic: 'medical',
    phases: {TtcDayPhase.late},
    titleEn: "Your period is late. Here's how to test",
    titleHi: "Your period is late. Here's how to test",
    bodyEn:
        "Once your period is late, a home test can give you a real answer. Use your first urine of the morning, when hCG is most concentrated. Follow the leaflet and read the result within the time it gives.\n\nTwo lines, even if the second is faint, usually mean pregnant. Only the control line means negative for today.",
    bodyHi:
        "Once your period is late, a home test can give you a real answer. Use your first urine of the morning, when hCG is most concentrated. Follow the leaflet and read the result within the time it gives.\n\nTwo lines, even if the second is faint, usually mean pregnant. Only the control line means negative for today.",
    takeawayEn: "Test with first-morning urine, and read it on time.",
    takeawayHi: "Test with first-morning urine, and read it on time.",
    forPartner: false,
  ),
  TtcInsight(
    id: 'late_negative',
    topic: 'medical',
    phases: {TtcDayPhase.late},
    titleEn: "A late period and a negative test",
    titleHi: "A late period and a negative test",
    bodyEn:
        "This is very common. Usually you ovulated later than normal this month, so the whole cycle has shifted and hCG hasn't built up yet. Illness, travel or a hard month can move ovulation too.\n\nTest again in three days to a week, with first-morning urine. Most pregnancies show on a home test by a week after a missed period.",
    bodyHi:
        "This is very common. Usually you ovulated later than normal this month, so the whole cycle has shifted and hCG hasn't built up yet. Illness, travel or a hard month can move ovulation too.\n\nTest again in three days to a week, with first-morning urine. Most pregnancies show on a home test by a week after a missed period.",
    takeawayEn: "Test again in three days to a week. A later ovulation is the usual reason.",
    takeawayHi: "Test again in three days to a week. A later ovulation is the usual reason.",
    forPartner: false,
  ),
  TtcInsight(
    id: 'late_see_doctor',
    topic: 'medical',
    phases: {TtcDayPhase.late},
    titleEn: "When a late period needs a doctor",
    titleHi: "When a late period needs a doctor",
    bodyEn:
        "Book a visit if your period is over a week late and tests are still negative, or if you've had no period for three months. It's rarely urgent, and a doctor can find out why.\n\nGo to a hospital the same day if a late period comes with strong pain low down on one side, pain at the tip of your shoulder, dizziness or fainting, or much heavier bleeding than usual. These are rare but need care today. If the pain is severe or you faint, call 108 or 112.",
    bodyHi:
        "Book a visit if your period is over a week late and tests are still negative, or if you've had no period for three months. It's rarely urgent, and a doctor can find out why.\n\nGo to a hospital the same day if a late period comes with strong pain low down on one side, pain at the tip of your shoulder, dizziness or fainting, or much heavier bleeding than usual. These are rare but need care today. If the pain is severe or you faint, call 108 or 112.",
    takeawayEn: "Over a week late with negative tests: book a visit. Strong pain on one side: go today.",
    takeawayHi: "Over a week late with negative tests: book a visit. Strong pain on one side: go today.",
  ),
  // The fertile window
  TtcInsight(
    id: 'window_every_day_or_two',
    topic: 'fertility',
    phases: {TtcDayPhase.window},
    titleEn: "Every day or two is enough",
    titleHi: "Every day or two is enough",
    bodyEn:
        "Your fertile window is about six days long, ending on the day you ovulate. Being together every one to two days across it is all you need to do.\n\nIt doesn't have to be daily, and there's no need to save it up. This is what doctors' guidelines advise, and it works as well as careful timing.",
    bodyHi:
        "Your fertile window is about six days long, ending on the day you ovulate. Being together every one to two days across it is all you need to do.\n\nIt doesn't have to be daily, and there's no need to save it up. This is what doctors' guidelines advise, and it works as well as careful timing.",
    takeawayEn: "Every one to two days across your window. That's enough.",
    takeawayHi: "Every one to two days across your window. That's enough.",
  ),
  TtcInsight(
    id: 'window_no_single_day',
    topic: 'fertility',
    phases: {TtcDayPhase.window},
    titleEn: "No one day decides this",
    titleHi: "No one day decides this",
    bodyEn:
        "It's easy to feel that everything rests on one night. It doesn't. Sperm can wait around five days for an egg, so the days before ovulation count as much as the day itself.\n\nIf tonight isn't right for one of you, tomorrow still counts. That's why the window is several days long.",
    bodyHi:
        "It's easy to feel that everything rests on one night. It doesn't. Sperm can wait around five days for an egg, so the days before ovulation count as much as the day itself.\n\nIf tonight isn't right for one of you, tomorrow still counts. That's why the window is several days long.",
    takeawayEn: "Skipping a night is fine. The window is several days wide.",
    takeawayHi: "Skipping a night is fine. The window is several days wide.",
  ),
  TtcInsight(
    id: 'window_closeness',
    topic: 'emotional',
    phases: {TtcDayPhase.window},
    titleEn: "These days are for being close",
    titleHi: "These days are for being close",
    bodyEn:
        "When sex starts to feel like a date on a calendar, it can weigh on both of you. That's very common, and it's nobody's fault.\n\nTry to keep some of this time just for each other. A slow evening or a cuddle on the sofa counts too. If the pressure feels heavy, say so to each other.",
    bodyHi:
        "When sex starts to feel like a date on a calendar, it can weigh on both of you. That's very common, and it's nobody's fault.\n\nTry to keep some of this time just for each other. A slow evening or a cuddle on the sofa counts too. If the pressure feels heavy, say so to each other.",
    takeawayEn: "Closeness matters more than getting it perfect.",
    takeawayHi: "Closeness matters more than getting it perfect.",
  ),
  TtcInsight(
    id: 'window_he_helps',
    topic: 'male',
    phases: {TtcDayPhase.window},
    titleEn: "Your partner can help with this too",
    titleHi: "Your partner can help with this too",
    bodyEn:
        "The fertile days can start to feel like your job to track and plan. They don't have to be. Share your window with your partner, so he knows the days without you having to tell him each time.\n\nHe can also start the evening sometimes, so it isn't always you. Keeping his laptop off his lap and going easy on alcohol help his side too.",
    bodyHi:
        "The fertile days can start to feel like your job to track and plan. They don't have to be. Share your window with your partner, so he knows the days without you having to tell him each time.\n\nHe can also start the evening sometimes, so it isn't always you. Keeping his laptop off his lap and going easy on alcohol help his side too.",
    takeawayEn: "Share the planning. This is something you do together.",
    takeawayHi: "Share the planning. This is something you do together.",
    forPartner: false,
  ),
  TtcInsight(
    id: 'window_no_tracking',
    topic: 'fertility',
    phases: {TtcDayPhase.window},
    titleEn: "You don't need to track to do this right",
    titleHi: "You don't need to track to do this right",
    bodyEn:
        "Strips and charts help some people, especially with irregular cycles. But they aren't a must. Being together every two days through the middle of your cycle covers your fertile days without any of them.\n\nIf tracking has started to feel heavy, it's okay to take a break from it.",
    bodyHi:
        "Strips and charts help some people, especially with irregular cycles. But they aren't a must. Being together every two days through the middle of your cycle covers your fertile days without any of them.\n\nIf tracking has started to feel heavy, it's okay to take a break from it.",
    takeawayEn: "Tracking is optional. Every two days mid-cycle covers your window.",
    takeawayHi: "Tracking is optional. Every two days mid-cycle covers your window.",
  ),
];

/// Every daily insight: the everyday set and the phase cards, one pool for
/// id lookups and for [ttcInsightsForPhase].
const List<TtcInsight> ttcAllInsights = [...ttcInsights, ...ttcPhaseInsights];

/// Today's insight cards for where she is in her cycle.
///
/// Cards tagged with [phase] come first, rotated by [day] inside that set so
/// the order is stable all day and turns over tomorrow. The rest of [count] is
/// filled from cards tagged [TtcDayPhase.any], rotated the same way. No card
/// appears twice, and fewer than [count] come back only if the library runs
/// out. Pure: same inputs, same cards.
///
/// For [TtcDayPhase.any] (phase unknown, or a clinic-run cycle) only `any`
/// cards are returned, so a card written for a period day never appears when
/// we cannot say it is one.
List<TtcInsight> ttcInsightsForPhase(
  TtcDayPhase phase,
  DateTime day, {
  int count = 3,
}) {
  if (count <= 0) return const [];
  final start = ttcDayIndex(day);

  List<TtcInsight> rotated(List<TtcInsight> pool) => [
        for (var i = 0; i < pool.length; i++)
          pool[(start + i) % pool.length],
      ];

  final tagged = phase == TtcDayPhase.any
      ? const <TtcInsight>[]
      : ttcAllInsights.where((i) => i.phases.contains(phase)).toList();
  final general = ttcAllInsights
      .where((i) => i.phases.contains(TtcDayPhase.any))
      .toList();

  final out = <TtcInsight>[];
  final seen = <String>{};
  for (final i in [...rotated(tagged), ...rotated(general)]) {
    if (out.length >= count) break;
    if (seen.add(i.id)) out.add(i);
  }
  return out;
}

// =============================================================================
//  Daily Myth
// =============================================================================

/// One myth, one truth. Short, friendly, research-backed. (Master doc §3.3)
class TtcMyth {
  const TtcMyth({
    required this.id,
    required this.mythEn,
    required this.mythHi,
    required this.truthEn,
    required this.truthHi,
  });

  final String id;
  final String mythEn;
  final String mythHi;
  final String truthEn;
  final String truthHi;

  String myth(bool hi) => hi ? mythHi : mythEn;
  String truth(bool hi) => hi ? truthHi : truthEn;
}

const List<TtcMyth> ttcMyths = [
  TtcMyth(
    id: 'one_fertile_day',
    mythEn: 'You only have one fertile day each month.',
    mythHi: 'Har mahine sirf ek hi fertile din hota hai.',
    truthEn:
        'Sperm survive around five days, so your fertile window is about six days long. The days before ovulation count just as much as the day itself.',
    truthHi:
        'Sperm lagbhag paanch din zinda rehte hain, toh window karib chhe din ki hoti hai. Ovulation se pehle ke din utne hi important hain jitna khud ka din.',
  ),
  TtcMyth(
    id: 'infertility_is_female',
    mythEn: 'Infertility is mostly a woman\'s problem.',
    mythHi: 'Infertility zyadatar aurat ki samasya hoti hai.',
    truthEn:
        "A male factor plays a part in roughly forty to fifty per cent of cases. A semen analysis is quick and low-cost, and it's often a sensible first test.",
    truthHi:
        'Lagbhag chalis se pachas pratishat maamlon mein mard ka factor shaamil hota hai. Semen analysis jaldi aur sasta hai, aur aksar samajhdaari bhara pehla test hota hai.',
  ),
  TtcMyth(
    id: 'stress_causes_infertility',
    mythEn: 'Stress alone causes infertility.',
    mythHi: 'Sirf stress se infertility hoti hai.',
    truthEn:
        'Very high stress over a long time can delay ovulation, but everyday worry doesn\'t stop a healthy couple from conceiving. "Just relax" isn\'t medical advice.',
    truthHi:
        'Tez aur lagatar stress ovulation mein der kar sakta hai, lekin aam chinta kisi healthy couple ko conceive karne se nahi rokti. "Bas relax karo" medical salaah nahi hai.',
  ),
  TtcMyth(
    id: 'lying_down_after',
    mythEn: 'You have to lie down with your legs up afterwards.',
    mythHi: 'Baad mein taange upar karke letna zaroori hai.',
    truthEn:
        'Sperm reach the cervix within minutes. No position has ever been shown to change the result, so do whatever feels comfortable.',
    truthHi:
        'Sperm minton mein cervix tak pahunch jaate hain. Position ya posture se nateeja badalta hai, ye kabhi sabit nahi hua - jo aaram se ho, wahi karein.',
  ),
  TtcMyth(
    id: 'age_cliff_35',
    mythEn: 'Fertility drops off a cliff at thirty-five.',
    mythHi: 'Pentiis par fertility ekdum girr jaati hai.',
    truthEn:
        "Fertility goes down slowly from the early thirties, and faster after thirty-seven. It's a slope, not a cliff. Thirty-five is a guide for when to get help sooner, not a deadline.",
    truthHi:
        'Fertility tees ki shuruaat se dheere-dheere kam hoti hai, aur santees ke baad tezi se. Ye dhalaan hai, khaai nahi - aur pentiis ek guideline hai ki madad kab jaldi leni hai, deadline nahi.',
  ),
  TtcMyth(
    id: 'irregular_means_infertile',
    mythEn: "Irregular periods mean you can't conceive.",
    mythHi: 'Irregular periods ka matlab conceive nahi kar sakte.',
    truthEn:
        'Irregular cycles make timing harder and are worth checking, but many women with irregular periods do conceive. Some conceive naturally, and many with simple help.',
    truthHi:
        'Irregular cycles timing mushkil karte hain aur inhe jaanchna theek hai, lekin bahut si auratein irregular periods ke saath conceive karti hain - kuch naturally, bahut si thodi si madad se.',
  ),
  TtcMyth(
    id: 'previous_child',
    mythEn: 'If you got pregnant before, it will happen easily again.',
    mythHi: 'Pehle conceive ho gaya toh dobara aasaani se ho jayega.',
    truthEn:
        'Secondary infertility, trouble conceiving after an earlier pregnancy, is real and common. Age, weight, a new health condition or a change on the male side can all make a difference. It deserves the same care as the first time.',
    truthHi:
        'Secondary infertility asli aur aam hai. Umar, wazan, koi nayi condition ya mard ki taraf badlaav - sab kuch badal sakte hain. Ise pehli baar jitna hi dhyaan chahiye.',
  ),
  TtcMyth(
    id: 'more_is_better',
    mythEn: 'The more you try, the better the chances.',
    mythHi: 'Jitna zyada koshish, utna zyada mauka.',
    truthEn:
        "Every day or every other day across the fertile window is plenty. More than that doesn't add anything, and turning it into a timetable wears you both down.",
    truthHi:
        'Fertile window mein roz ya ek din chhod kar kaafi hai. Usse zyada kuch nahi jodta, aur ise schedule bana dena dono par bhaari padta hai.',
  ),
  TtcMyth(
    id: 'app_predicts',
    mythEn: 'The app knows exactly when you ovulate.',
    mythHi: 'App ko theek pata hai aap kab ovulate karti hain.',
    truthEn:
        "Every app, this one included, is making an estimate from your past cycles. Your body's own signs are better evidence. That's why we always show how sure the estimate is.",
    truthHi:
        'Koi bhi app - ye bhi - pichhle cycles se andaaza lagata hai. Aapke body ke apne signals behtar saboot hain, isiliye hum hamesha batate hain ki andaaza kitna pakka hai.',
  ),
  TtcMyth(
    id: 'hot_foods',
    mythEn: 'Some "hot" or "cold" foods stop you from conceiving.',
    mythHi: 'Kuch "garam" ya "thandi" cheezein conceive hone se rokti hain.',
    truthEn:
        "No single food stops pregnancy or causes it. What the evidence supports is your overall way of eating: whole grains, dal, vegetables and healthy fats. There's no one food to fear or chase.",
    truthHi:
        'Koi ek khana conceive hone se na rokta hai na karata hai. Jo support karta hai wo poora pattern hai - sabut anaaj, dal, sabziyan, achhi fats - koi ek cheez jise darein ya peechha karein, wo nahi.',
  ),
  TtcMyth(
    id: 'birth_control_delay',
    mythEn: 'Years on the pill delay fertility for years.',
    mythHi: 'Saalon tak pill lene se fertility saalon tak late hoti hai.',
    truthEn:
        'For most women, cycles come back within one to three months of stopping, however long they were on it. The injection is the main exception and can take longer.',
    truthHi:
        'Zyadatar auraton mein pill band karne ke ek se teen mahine mein cycles wapas aa jaate hain, chahe kitne saal li ho. Injectable iska mukhya apwaad hai aur usmein zyada waqt lag sakta hai.',
  ),
  TtcMyth(
    id: 'position_gender',
    mythEn: 'You can choose the baby\'s sex by timing or position.',
    mythHi: 'Timing ya position se bachche ka gender chuna ja sakta hai.',
    truthEn:
        "There's no evidence for any of it. In India, sex determination and sex selection are also illegal under the PCPNDT Act, and ParentVeda will never help with either.",
    truthHi:
        'Iska koi saboot nahi hai. India mein sex determination aur selection PCPNDT Act ke tahat gair-kanooni bhi hai - aur ParentVeda ismein kabhi madad nahi karega.',
  ),
  TtcMyth(
    id: 'miscarriage_blame',
    mythEn: 'A miscarriage means you did something wrong.',
    mythHi: 'Miscarriage ka matlab aapne kuch galat kiya.',
    truthEn:
        "Most early losses happen because of chromosome problems that nothing could have prevented. They aren't caused by lifting, travelling, working or stress.",
    truthHi:
        'Zyadatar shuruaati loss chromosomal galtiyon se hote hain jinhe kuch bhi nahi rok sakta tha - na saamaan uthana, na safar, na kaam, na stress.',
  ),
  TtcMyth(
    id: 'ivf_last_resort',
    mythEn: 'IVF is the only treatment there is.',
    mythHi: 'IVF hi ek ilaaj hai.',
    truthEn:
        "It's one of several. Ovulation induction and IUI are simpler, cheaper and often enough. A good clinic starts with the least you need, not the most.",
    truthHi:
        'Ye kai mein se ek hai. Ovulation induction aur IUI aasaan, saste aur aksar kaafi hote hain. Achha clinic sabse kam zaroori cheez se shuru karta hai, sabse zyada se nahi.',
  ),
  TtcMyth(
    id: 'symptom_spotting',
    mythEn: 'Early symptoms tell you before a test can.',
    mythHi: 'Shuruaati symptoms test se pehle bata dete hain.',
    truthEn:
        'Early pregnancy signs and pre-period signs come from the same hormone, so they feel exactly the same. Only a test can tell you, and waiting for it is often the hardest part.',
    truthHi:
        'Shuruaati pregnancy aur period se pehle ke symptoms ek hi hormone se aate hain, isliye ek jaise lagte hain. Sirf test bata sakta hai - aur uska intezaar sach mein sabse mushkil hissa hai.',
  ),
  TtcMyth(
    id: 'male_age',
    mythEn: "A man's age doesn't matter.",
    mythHi: 'Mard ki umar maayne nahi rakhti.',
    truthEn:
        "It matters less sharply than a woman's age, but it does matter. Sperm quality and the health of sperm DNA slowly go down from around forty, and some risks rise a little.",
    truthHi:
        'Aurat ki umar jitna tez asar nahi karti, lekin asar karti hai. Chalis ke aas-paas se sperm quality aur DNA integrity dheere-dheere kam hoti hai, aur kuch khatre halke se badhte hain.',
  ),
];

// =============================================================================
//  The Daily Ritual
// =============================================================================

/// TTC's answer to Garbh Sanskar: a five-minute daily practice, five parts.
/// (Master doc §2.4 - "Today's Reflection · Breath · Conversation · Gratitude ·
/// Action". Five minutes, exactly like Garbh Sanskar, different purpose.)
enum TtcRitualPart { reflection, breath, conversation, gratitude, action }

extension TtcRitualPartCopy on TtcRitualPart {
  String title(bool hi) {
    switch (this) {
      case TtcRitualPart.reflection:
        return hi ? 'Aaj ka vichaar' : "Today's reflection";
      case TtcRitualPart.breath:
        return hi ? 'Aaj ki saans' : "Today's breath";
      case TtcRitualPart.conversation:
        return hi ? 'Aaj ki baat' : "Today's conversation";
      case TtcRitualPart.gratitude:
        return hi ? 'Aaj ka shukr' : "Today's gratitude";
      case TtcRitualPart.action:
        return hi ? 'Aaj ka kaam' : "Today's action";
    }
  }

  /// Why this part exists at all - shown once, in the ritual's explainer.
  String why(bool hi) {
    switch (this) {
      case TtcRitualPart.reflection:
        return hi
            ? 'Ek chhota sa vichaar, dhyaan se padhne ke liye.'
            : 'One small thought, to read slowly.';
      case TtcRitualPart.breath:
        return hi
            ? 'Ek minute ki saans - nervous system ko dheema karne ke liye.'
            : 'One minute of breathing, to help your body calm down.';
      case TtcRitualPart.conversation:
        return hi
            ? 'Ek sawaal, ek doosre se poochhne ke liye.'
            : 'One question, to ask each other.';
      case TtcRitualPart.gratitude:
        return hi
            ? 'Ek cheez jo aaj achhi thi - chahe kitni bhi chhoti ho.'
            : 'One thing that was good today, however small.';
      case TtcRitualPart.action:
        return hi
            ? 'Ek chhota kaam. Do minute se zyada nahi.'
            : 'One small thing to do. Never more than two minutes.';
    }
  }
}

class TtcRitualItem {
  const TtcRitualItem({
    required this.part,
    required this.textEn,
    required this.textHi,
  });

  final TtcRitualPart part;
  final String textEn;
  final String textHi;

  String text(bool hi) => hi ? textHi : textEn;
}

/// The ritual is chapter-aware: the same five parts, but what they ask changes
/// with where the couple is. A gratitude prompt during the waiting days should
/// not sound like one during the fertile window.
const Map<TtcChapter, List<TtcRitualItem>> ttcRituals = {
  TtcChapter.preparingTogether: [
    TtcRitualItem(
      part: TtcRitualPart.reflection,
      textEn:
          "You're not waiting for your life to start. You're already building your family. This is the first part of it, not the wait before it.",
      textHi:
          'Aap zindagi shuru hone ka intezaar nahi kar rahe. Aap pehle se family bana rahe hain - ye uska pehla hissa hai, uske pehle ka intezaar nahi.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn:
          "Breathe in for four. Hold for four. Breathe out for six. Do this six times. The longer out-breath is what calms you, so don't rush it.",
      textHi:
          'Chaar tak saans lein. Chaar tak roken. Chhe tak chhodein. Chhe baar. Lambi saans chhodna hi shaant karta hai - jaldi na karein.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.conversation,
      textEn:
          "Ask each other: once there's a child here, how do you hope our home will feel?",
      textHi:
          'Ek doosre se poochhein: jab ghar mein bachcha hoga, tab aap chahte hain ghar kaisa lage?',
    ),
    TtcRitualItem(
      part: TtcRitualPart.gratitude,
      textEn: 'Name one thing your body did well for you today.',
      textHi: 'Ek cheez batayein jo aapke body ne aaj aapke liye acchi ki.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.action,
      textEn: "Put your folic acid somewhere you can't miss it tomorrow.",
      textHi: 'Apna folic acid aisi jagah rakhein jahan kal nazar aa hi jaye.',
    ),
  ],
  TtcChapter.knowingYourRhythm: [
    TtcRitualItem(
      part: TtcRitualPart.reflection,
      textEn:
          "Learning your cycle isn't the same as watching it. The aim is to know your body well enough to stop checking, not to check more.",
      textHi:
          'Apna cycle samajhna aur use ghoorna, do alag cheezein hain. Maqsad hai body ko itna jaan lena ki baar-baar dekhna band ho jaye - aur zyada dekhna nahi.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn:
          "Sit down. Breathe normally. Count ten breaths without changing them. If you lose count, start again at one. That's the practice, not a failure.",
      textHi:
          'Baithein. Saamanya saans lein. Bina kuch badle das saans ginein. Ginti bhool jayein toh ek se shuru karein - yahi abhyaas hai, galti nahi.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.conversation,
      textEn:
          "Ask each other: is there anything about this month you haven't said out loud yet?",
      textHi:
          'Ek doosre se poochhein: is mahine ke baare mein kuch hai jo abhi tak zubaan par nahi aaya?',
    ),
    TtcRitualItem(
      part: TtcRitualPart.gratitude,
      textEn: 'Name one thing today that had nothing to do with trying.',
      textHi: 'Ek cheez batayein jiska koshish se koi lena-dena nahi tha.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.action,
      textEn: 'Drink one full glass of water before you put this phone down.',
      textHi: 'Ye phone rakhne se pehle ek poora glass paani piyein.',
    ),
  ],
  TtcChapter.tryingTogether: [
    TtcRitualItem(
      part: TtcRitualPart.reflection,
      textEn:
          "These are days to be close, not days to perform. If tonight isn't the night for one of you, that's okay. The window is several days wide for exactly this reason.",
      textHi:
          'Ye din kareeb aane ke hain, kuch "karke dikhane" ke nahi. Agar aaj raat dono mein se kisi ka man nahi hai, toh theek hai - window kai din ki isi wajah se hoti hai.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn:
          'Breathe together. Same room, same pace, one minute. Nothing to say and nothing to decide.',
      textHi:
          'Saath mein saans lein. Ek kamra, ek raftaar, ek minute. Kuch kehna nahi, kuch tay nahi karna.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.conversation,
      textEn:
          "Ask each other: what's one thing I do that makes this feel lighter for you?",
      textHi:
          'Ek doosre se poochhein: main aisa kya karta/karti hoon jisse ye aapke liye halka lagta hai?',
    ),
    TtcRitualItem(
      part: TtcRitualPart.gratitude,
      textEn: 'Name one thing you like about the person next to you.',
      textHi: 'Apne saath wale insaan ki ek baat batayein jo aapko pasand hai.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.action,
      textEn: 'Put both phones in another room for an hour tonight.',
      textHi: 'Aaj raat ek ghante ke liye dono phone doosre kamre mein rakh dein.',
    ),
  ],
  TtcChapter.theWaitingDays: [
    TtcRitualItem(
      part: TtcRitualPart.reflection,
      textEn:
          "Nothing you do now changes what is or isn't already happening. That can feel hard, but it's also a kind of freedom. These days belong to you, not to the result.",
      textHi:
          'Ab aap jo bhi karein, jo ho raha hai ya nahi ho raha, wo nahi badlega. Ye sunne mein mushkil hai, aur ye azaadi bhi hai - ye din aapke hain, nateeje ke nahi.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn:
          'When a thought about the test comes, notice it, breathe out slowly, and let it pass without arguing with it. Do the same again in ten minutes, because it will come back.',
      textHi:
          'Jab test ka khayal aaye, use notice karein, dheere se saans chhodein, aur bina behes kiye jaane dein. Phir das minute baad dobara - kyunki wo wapas aayega.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.conversation,
      textEn:
          'Ask each other: what can we do this weekend that has nothing to do with any of this?',
      textHi:
          'Ek doosre se poochhein: is weekend hum aisa kya karein jiska is sab se koi lena-dena na ho?',
    ),
    TtcRitualItem(
      part: TtcRitualPart.gratitude,
      textEn: "Name one ordinary thing from today that you'd have missed if you were busy waiting.",
      textHi: 'Aaj ki ek aam si baat batayein jo intezaar mein khoye rehte toh chhoot jaati.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.action,
      textEn: 'Do one thing today just because you enjoy it. Not because it helps.',
      textHi: 'Aaj ek cheez sirf isliye karein ki aapko achhi lagti hai. Isliye nahi ki madad karti hai.',
    ),
  ],
  TtcChapter.aNewBeginning: [
    TtcRitualItem(
      part: TtcRitualPart.reflection,
      textEn:
          "Whatever this chapter took from you, it also taught you how to face something together. That stays with you now, and you'll need it.",
      textHi:
          'Is chapter ne aapse jo bhi liya, usne aapko saath mein kuch jhelna bhi sikhaya. Wo ab khatam nahi hota - aage kaam aayega.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn: "Breathe in for four, out for six. Ten times. There's no hurry from here.",
      textHi: 'Chaar tak andar, chhe tak bahar. Das baar. Ab yahan se koi jaldi nahi.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.conversation,
      textEn: 'Ask each other: who do we want to tell, and when?',
      textHi: 'Ek doosre se poochhein: kise batana hai, aur kab?',
    ),
    TtcRitualItem(
      part: TtcRitualPart.gratitude,
      textEn: 'Name one person who made this chapter easier.',
      textHi: 'Ek insaan ka naam lein jisne ye chapter aasaan banaya.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.action,
      textEn: "Book your first appointment. That's the only task today.",
      textHi: 'Apni pehli appointment book karein. Aaj bas yahi kaam hai.',
    ),
  ],
};

// =============================================================================
//  Today's Nutrition
// =============================================================================

/// One recommendation, one explanation, one meal, one nutrient, one Indian
/// context - the exact shape the pregnancy app uses. (Master doc §2.4)
class TtcNutrition {
  const TtcNutrition({
    required this.id,
    required this.nutrientEn,
    required this.nutrientHi,
    required this.whyEn,
    required this.whyHi,
    required this.mealEn,
    required this.mealHi,
    required this.indianEn,
    required this.indianHi,
  });

  final String id;
  final String nutrientEn;
  final String nutrientHi;
  final String whyEn;
  final String whyHi;
  final String mealEn;
  final String mealHi;

  /// The Indian-context line - the part that makes this ours rather than
  /// translated from an American app.
  final String indianEn;
  final String indianHi;

  String nutrient(bool hi) => hi ? nutrientHi : nutrientEn;
  String why(bool hi) => hi ? whyHi : whyEn;
  String meal(bool hi) => hi ? mealHi : mealEn;
  String indian(bool hi) => hi ? indianHi : indianEn;
}

const List<TtcNutrition> ttcNutrition = [
  TtcNutrition(
    id: 'folate_greens',
    nutrientEn: 'Folate',
    nutrientHi: 'Folate',
    whyEn:
        'Folate is the form of folic acid found in food, and you need it before you conceive, not after.',
    whyHi:
        'Folate folic acid ka khaane wala roop hai, aur ye conceive karne ke baad nahi, pehle chahiye hota hai.',
    mealEn: 'Palak dal with a squeeze of lemon, and roti.',
    mealHi: 'Palak dal, upar se thoda nimbu, aur roti.',
    indianEn:
        "The lemon at the end helps twice. It protects folate and helps your body take in iron. Add it after you turn off the heat, not while it's boiling.",
    indianHi:
        'Aakhir mein nimbu do wajah se zaroori hai - folate bachata hai aur iron sokhne mein madad karta hai. Ise aanch se hata kar daalein, ubalte waqt nahi.',
  ),
  TtcNutrition(
    id: 'iron_bajra',
    nutrientEn: 'Iron',
    nutrientHi: 'Iron',
    whyEn:
        "Low iron is very common in Indian women. It's linked to irregular ovulation as well as tiredness.",
    whyHi:
        'Indian auraton mein iron ki kami bahut aam hai, aur iska sambandh irregular ovulation aur thakaan dono se hai.',
    mealEn: 'Bajra roti with gud and a bowl of rajma.',
    mealHi: 'Bajre ki roti, gud ke saath, aur ek katori rajma.',
    indianEn:
        'Chai and coffee stop your body taking in iron. Have them an hour before or after your iron-rich meal, not with it.',
    indianHi:
        'Chai aur coffee iron sokhne se rokte hain. Inhe iron wale khaane ke saath nahi, ek ghanta pehle ya baad rakhein.',
  ),
  TtcNutrition(
    id: 'omega3',
    nutrientEn: 'Omega-3',
    nutrientHi: 'Omega-3',
    whyEn:
        "Omega-3 fats help both partners make hormones, and they're linked to better sperm quality.",
    whyHi:
        'Omega-3 fats dono partners mein hormone banne ko support karti hain, aur behtar sperm quality se judi hain.',
    mealEn: 'A spoon of ground flaxseed in dahi, or fish twice a week.',
    mealHi: 'Dahi mein ek chammach pisi alsi, ya hafte mein do baar machhli.',
    indianEn:
        "Flaxseed has to be ground for your body to absorb it. Whole seeds pass straight through. Grind a week's worth and keep it in the fridge.",
    indianHi:
        'Alsi pisi honi chahiye tabhi sokhi jaati hai - sabut beej seedhe nikal jaate hain. Hafte bhar ki pees kar fridge mein rakhein.',
  ),
  TtcNutrition(
    id: 'protein_dal',
    nutrientEn: 'Protein',
    nutrientHi: 'Protein',
    whyEn:
        'Most Indian vegetarian diets are low in protein. That affects hormone balance and how steady your energy feels.',
    whyHi:
        'Zyadatar Indian vegetarian khaane mein protein kam hota hai, jo hormone balance aur din bhar ki energy dono par asar daalta hai.',
    mealEn: 'Dal, dahi and a handful of roasted chana as a snack.',
    mealHi: 'Dal, dahi aur snack mein ek mutthi bhuna chana.',
    indianEn:
        'Dal and rice together make a complete protein. Indian kitchens got this pairing right long before science explained it.',
    indianHi:
        'Dal aur chawal saath mein poora protein bante hain - ye jodi Indian rasoi ne science ke samjhaane se bahut pehle sahi kar li thi.',
  ),
  TtcNutrition(
    id: 'vitamin_d_food',
    nutrientEn: 'Vitamin D',
    nutrientHi: 'Vitamin D',
    whyEn:
        'Most Indian adults are low in it, and it affects how regular your cycles are as well as sperm quality.',
    whyHi:
        'Zyadatar Indian adults mein kami hai, aur iska asar cycle ki regularity aur sperm quality dono par padta hai.',
    mealEn: 'Fortified milk, egg yolk, and fifteen minutes of morning sun.',
    mealHi: 'Fortified doodh, ande ki zardi, aur pandrah minute subah ki dhoop.',
    indianEn:
        "Food alone rarely fixes a real shortage. Get tested first, because it's one of the cheapest blood tests there is. Then let a doctor decide the dose.",
    indianHi:
        'Sirf khaane se asli kami shayad hi theek hoti hai. Pehle test karwayein - ye sabse saste blood tests mein se hai - phir doctor dose tay karein.',
  ),
  TtcNutrition(
    id: 'zinc_male',
    nutrientEn: 'Zinc',
    nutrientHi: 'Zinc',
    whyEn:
        'Zinc is directly involved in making sperm and testosterone, so this one is mostly for him.',
    whyHi:
        'Zinc seedhe sperm banne aur testosterone se juda hai - ye zyadatar unke liye hai.',
    mealEn: 'Pumpkin seeds, chana, cashews, or a small portion of meat.',
    mealHi: 'Kaddu ke beej, chana, kaju, ya thoda sa maans.',
    indianEn:
        "A handful of roasted chana at four o'clock does more for this than most supplements sold for it.",
    indianHi:
        'Shaam chaar baje ek mutthi bhuna chana, iske liye beche jaane wale zyadatar supplements se zyada kaam karta hai.',
  ),
  TtcNutrition(
    id: 'whole_grains',
    nutrientEn: 'Whole grains',
    nutrientHi: 'Sabut anaaj',
    whyEn:
        'Steady blood sugar helps ovulation, and it matters even more with PCOS.',
    whyHi:
        'Sthir blood sugar ovulation ko support karta hai, aur PCOS mein aur bhi zyada maayne rakhta hai.',
    mealEn: 'Jowar or bajra roti instead of maida, on most days.',
    mealHi: 'Zyadatar dino mein maida ki jagah jowar ya bajre ki roti.',
    indianEn:
        "You don't have to give up rice. Adding dal, dahi and a sabzi to it keeps the sugar spike lower than switching grains does.",
    indianHi:
        'Chawal chhodna zaroori nahi. Uske saath dal, dahi aur sabzi jodna, anaaj badalne se zyada sugar spike ko kam karta hai.',
  ),
  TtcNutrition(
    id: 'hydration',
    nutrientEn: 'Water',
    nutrientHi: 'Paani',
    whyEn:
        "Drinking enough water affects cervical mucus, your energy and how well everything else works. It's the least exciting thing on this list.",
    whyHi:
        'Paani cervical mucus, energy aur baaki sab kuch ke theek chalne par asar daalta hai. Is list mein ye sabse kam chamakdaar cheez hai.',
    mealEn: 'Nimbu paani without sugar, and a water bottle you keep close by.',
    mealHi: 'Bina cheeni ka nimbu paani, aur ek bottle jo sach mein paas rakhein.',
    indianEn:
        "In Indian summers, you only feel thirsty once you're already low. Drink at set times, not only when you're thirsty.",
    indianHi:
        'Indian garmi mein pyaas tab lagti hai jab kami ho chuki hoti hai. Pyaas par nahi, samay par piyein.',
  ),
  TtcNutrition(
    id: 'antioxidants',
    nutrientEn: 'Antioxidants',
    nutrientHi: 'Antioxidants',
    whyEn:
        "Oxidative stress, a kind of wear and tear on cells, damages both eggs and sperm. A colourful plate is the easiest sign you're getting antioxidants.",
    whyHi:
        'Oxidative stress eggs aur sperm dono ko nuksaan pahunchata hai. Thali par rang, antioxidants ka sabse aasaan pata hai.',
    mealEn: 'Amla, seasonal fruit, tomatoes, and dark leafy sabzi.',
    mealHi: 'Amla, mausami phal, tamatar, aur gehri hari sabzi.',
    indianEn:
        'One amla has many times the vitamin C of an orange. It costs almost nothing in season, and it keeps its goodness even as murabba or juice.',
    indianHi:
        'Ek amle mein santre se kai guna vitamin C hota hai, mausam mein lagbhag muft hai, aur murabba ya juice banne ke baad bhi bacha rehta hai.',
  ),
  TtcNutrition(
    id: 'less_processed',
    nutrientEn: 'Less processed food',
    nutrientHi: 'Kam processed khana',
    whyEn:
        'Trans fats and heavily processed food are among the few foods linked again and again to poorer fertility.',
    whyHi:
        'Trans fats aur zyada processed khana un gine-chune dietary factors mein hai jo lagatar kharaab fertility se jude paye gaye hain.',
    mealEn: 'Anything cooked at home, in ghee or mustard oil, is better than a packet.',
    mealHi: 'Ghar ka bana kuch bhi - ghee ya sarson ke tel mein - packet se behtar hai.',
    indianEn:
        "Ghee isn't the problem here. Frying oil that's heated again and again, and bakery items made with vanaspati, are.",
    indianHi:
        'Yahan ghee villain nahi hai. Baar-baar garam kiya gaya talne ka tel, aur vanaspati wali bakery cheezein hain.',
  ),
  TtcNutrition(
    id: 'b12',
    nutrientEn: 'Vitamin B12',
    nutrientHi: 'Vitamin B12',
    whyEn:
        "A shortage is very common in Indian vegetarians. It's linked to ovulation problems and to risks in early pregnancy.",
    whyHi:
        'Indian vegetarians mein iski kami bahut aam hai, aur ye ovulation ki dikkat aur shuruaati pregnancy ke khatre se judi hai.',
    mealEn: "Dahi, paneer, milk and eggs, or a supplement if you don't eat dairy.",
    mealHi: 'Dahi, paneer, doodh, ande - ya supplement agar dairy bilkul nahi khate.',
    indianEn:
        "A pure vegetarian diet almost always needs a B12 supplement. This is one of the few times when food alone isn't enough.",
    indianHi:
        'Shuddh shakahari khaane mein lagbhag hamesha B12 supplement chahiye hota hai. Ye un gine-chune jagahon mein hai jahan khana sach mein kaafi nahi hai.',
  ),
  TtcNutrition(
    id: 'coq10',
    nutrientEn: 'CoQ10',
    nutrientHi: 'CoQ10',
    whyEn:
        "It's been studied for egg and sperm quality, especially over thirty-five. The results look promising, but they aren't proven.",
    whyHi:
        'Egg aur sperm quality ke liye study kiya gaya hai, khaaskar pentiis ke baad. Ummeed jagata hai, sabit nahi hua.',
    mealEn: 'Found in small amounts in nuts and whole grains.',
    mealHi: 'Meve aur sabut anaaj mein thodi matra mein milta hai.',
    indianEn:
        'This is a question about supplements, not food, and one to ask your doctor rather than a chemist. The doses sold over the counter vary hugely.',
    indianHi:
        'Ye supplement ka sawaal hai, khaane ka nahi - aur chemist se nahi, doctor se poochhne wala. Bina prescription bikne wale doses bahut alag-alag hote hain.',
  ),
];

// =============================================================================
//  Today's Movement
// =============================================================================

/// "Not fitness. Movement." (Master doc §3.11)
class TtcMovement {
  const TtcMovement({
    required this.id,
    required this.kind,
    required this.titleEn,
    required this.titleHi,
    required this.bodyEn,
    required this.bodyHi,
    required this.minutes,
  });

  final String id;

  /// walk · yoga · strength · stretch · breath · rest
  final String kind;
  final String titleEn;
  final String titleHi;
  final String bodyEn;
  final String bodyHi;
  final int minutes;

  String title(bool hi) => hi ? titleHi : titleEn;
  String body(bool hi) => hi ? bodyHi : bodyEn;
}

const List<TtcMovement> ttcMovements = [
  TtcMovement(
    id: 'walk_after_dinner',
    kind: 'walk',
    titleEn: 'A walk after dinner',
    titleHi: 'Khaane ke baad tehalna',
    bodyEn:
        'Fifteen minutes at an easy pace. A walk after a meal lowers the blood-sugar spike more than the same walk at any other time of day.',
    bodyHi:
        'Pandrah minute aaram ki raftaar se. Khaane ke baad chalna, din ke kisi bhi aur samay ke mukable blood-sugar spike ko zyada kam karta hai.',
    minutes: 15,
  ),
  TtcMovement(
    id: 'supta_baddha',
    kind: 'yoga',
    titleEn: 'Supta baddha konasana',
    titleHi: 'Supta baddha konasana',
    bodyEn:
        "Lie on your back with the soles of your feet together and your knees falling open. Put a cushion under each knee and stay for five minutes. It opens the hips and calms the nervous system. Don't push your knees down.",
    bodyHi:
        'Peeth ke bal letein, dono pairon ke talwe milayein, ghutne khulne dein, har ghutne ke neeche ek takiya. Paanch minute rukein. Ye kulhe kholta hai aur nervous system ko shaant karta hai - ghutnon ko zabardasti neeche na dabayein.',
    minutes: 5,
  ),
  TtcMovement(
    id: 'strength_twice',
    kind: 'strength',
    titleEn: 'Something heavy, twice a week',
    titleHi: 'Kuch bhaari, hafte mein do baar',
    bodyEn:
        'Squats, a heavy bag, resistance bands: anything that makes your muscles work. Muscle helps your body use insulin better, which matters a lot with PCOS.',
    bodyHi:
        'Squats, bhara hua bag, resistance bands - kuch bhi jisse muscles kaam karein. Muscle insulin sensitivity behtar karta hai, jo PCOS mein bahut maayne rakhta hai.',
    minutes: 20,
  ),
  TtcMovement(
    id: 'hip_stretch',
    kind: 'stretch',
    titleEn: 'Unlock the hips',
    titleHi: 'Kulhe kholein',
    bodyEn:
        'Do a low lunge on each side, ninety seconds each. If you sit at a desk most of the day, your body has been asking for this one.',
    bodyHi:
        'Dono taraf ek-ek low lunge, nabbe second har taraf. Agar aap din bhar desk par baithte hain, toh aapka body yahi maang raha tha.',
    minutes: 4,
  ),
  TtcMovement(
    id: 'rest_day',
    kind: 'rest',
    titleEn: 'Today, rest counts as movement',
    titleHi: 'Aaj aaram bhi movement hai',
    bodyEn:
        'Rest is when your body adapts and gets stronger. A planned rest day is a choice, not a gap. Skipping rest is one of the few ways exercise starts to work against you.',
    bodyHi:
        'Body asal mein aaram ke dauraan hi badalta hai. Soch samajh kar liya gaya rest day ek faisla hai, khaali jagah nahi - aur aaram na lena un gine-chune tareekon mein hai jisse exercise ulta asar karne lagti hai.',
    minutes: 0,
  ),
  TtcMovement(
    id: 'legs_up_wall',
    kind: 'yoga',
    titleEn: 'Legs up the wall',
    titleHi: 'Deewar par taange',
    bodyEn:
        "Lie on your back with your legs resting up a wall for five minutes. It won't help you conceive. It will help your evening, and that's reason enough.",
    bodyHi:
        'Peeth ke bal letein aur taange deewar par tikayein, paanch minute. Ye conceive karne ke liye kuch nahi kar raha - ye aapki shaam ke liye kuch kar raha hai, aur wahi kaafi wajah hai.',
    minutes: 5,
  ),
  TtcMovement(
    id: 'walk_together',
    kind: 'walk',
    titleEn: 'Walk together, no phones',
    titleHi: 'Saath mein tehlein, phone ke bina',
    bodyEn:
        'Twenty minutes, both of you, no screens. The exercise almost comes second. This will be the easiest talk you have all week.',
    bodyHi:
        'Bees minute, dono, bina screen. Exercise lagbhag doosri baat hai - poore hafte ki sabse aasaan baatcheet yahi hogi.',
    minutes: 20,
  ),
  TtcMovement(
    id: 'pelvic_floor',
    kind: 'strength',
    titleEn: 'Pelvic floor, gently',
    titleHi: 'Pelvic floor, halke se',
    bodyEn:
        "Ten slow squeezes, holding each for three seconds, and letting go fully in between. Letting go matters as much as squeezing. A pelvic floor that's always tight isn't a strong one.",
    bodyHi:
        'Das dheere lifts, har ek teen second roken, beech mein poori tarah chhodein. Poori tarah chhodna utna hi zaroori hai jitna uthana - hamesha tight pelvic floor mazboot nahi hota.',
    minutes: 4,
  ),
  TtcMovement(
    id: 'stairs',
    kind: 'walk',
    titleEn: 'Take the stairs today',
    titleHi: 'Aaj seedhiyan lein',
    bodyEn:
        'Not a workout, just a choice. Small choices made again and again make more difference than a gym membership you use now and then.',
    bodyHi:
        'Ye workout nahi - ek faisla hai. Baar-baar liye chhote faisle, us gym membership se kahin zyada bharosemand hain jo kabhi-kabhi istemaal hoti hai.',
    minutes: 3,
  ),
  TtcMovement(
    id: 'cat_cow',
    kind: 'stretch',
    titleEn: 'Cat and cow',
    titleHi: 'Cat aur cow',
    bodyEn:
        'On your hands and knees, arch and round your back as you breathe, ten times. Two minutes, and your lower back will feel looser.',
    bodyHi:
        'Haath-ghutnon par, saans ke saath reedh ko upar-neeche karein, das baar. Do minute, aur kamar shikayat karna band kar deti hai.',
    minutes: 3,
  ),
  TtcMovement(
    id: 'morning_sun',
    kind: 'walk',
    titleEn: 'Ten minutes of morning light',
    titleHi: 'Das minute subah ki roshni',
    bodyEn:
        "Morning light sets the daily rhythm your hormones follow. It's also the easiest thing you can do for better sleep tonight. Vitamin D is a bonus.",
    bodyHi:
        'Subah ki roshni wo roz ki rhythm set karti hai jis par hormones chalte hain - aur aaj raat ki neend ke liye ye sabse aasaan cheez hai. Vitamin D upar se.',
    minutes: 10,
  ),
  TtcMovement(
    id: 'gentle_flow',
    kind: 'yoga',
    titleEn: 'A gentle flow, not a hard one',
    titleHi: 'Halka flow, mushkil nahi',
    bodyEn:
        "Fifteen minutes of slow movement with your breath. It's best to avoid hot or very intense yoga while trying. The heat is the reason, not the yoga.",
    bodyHi:
        'Pandrah minute dheere movement, saans ke saath. Koshish ke dauraan hot ya bahut tez yoga se bachna theek hai - wajah garmi hai, yoga nahi.',
    minutes: 15,
  ),
];

// =============================================================================
//  Journal prompts
// =============================================================================

/// "Same component. Different prompts." (Master doc §2.4)
class TtcJournalPrompt {
  const TtcJournalPrompt({
    required this.id,
    required this.textEn,
    required this.textHi,
    this.chapter,
  });

  final String id;
  final String textEn;
  final String textHi;

  /// When set, the prompt only appears in that chapter.
  final TtcChapter? chapter;

  String text(bool hi) => hi ? textHi : textEn;
}

const List<TtcJournalPrompt> ttcJournalPrompts = [
  TtcJournalPrompt(
    id: 'feeling',
    textEn: 'How are you really feeling today? The honest answer, not the useful one.',
    textHi: 'Aaj aap kaisa mehsoos kar rahe hain - sach mein, kaam ki baat nahi?',
  ),
  TtcJournalPrompt(
    id: 'hope',
    textEn: 'What gave you hope today?',
    textHi: 'Aaj kis cheez ne ummeed di?',
  ),
  TtcJournalPrompt(
    id: 'partner',
    textEn: 'Something you appreciated about your partner this week.',
    textHi: 'Is hafte partner ki koi baat jo achhi lagi.',
  ),
  TtcJournalPrompt(
    id: 'doctor_questions',
    textEn: 'Questions you want to ask at your next appointment.',
    textHi: 'Agli appointment mein jo sawaal poochhne hain.',
  ),
  TtcJournalPrompt(
    id: 'future_family',
    textEn: 'Write to the child you hope to have. Anything at all.',
    textHi: 'Us bachche ko likhein jiski ummeed hai. Kuch bhi.',
  ),
  TtcJournalPrompt(
    id: 'hard_thing',
    textEn: 'What was the hardest part of this month?',
    textHi: 'Is mahine ka sabse mushkil hissa kya tha?',
  ),
  TtcJournalPrompt(
    id: 'said_to_you',
    textEn: "Something someone said that you're still carrying.",
    textHi: 'Kisi ki kahi koi baat jo abhi tak saath hai.',
  ),
  TtcJournalPrompt(
    id: 'body_thanks',
    textEn: 'One thing you want to thank your body for.',
    textHi: 'Ek baat jiske liye apne body ka shukriya kehna hai.',
  ),
  TtcJournalPrompt(
    id: 'not_about_this',
    textEn: 'Something good that happened that had nothing to do with any of this.',
    textHi: 'Koi achhi baat jiska is sab se koi lena-dena nahi tha.',
  ),
  TtcJournalPrompt(
    id: 'learned',
    textEn: 'Something you learned about your own body recently.',
    textHi: 'Haal hi mein apne body ke baare mein kuch jo pata chala.',
  ),
  TtcJournalPrompt(
    id: 'waiting',
    textEn: 'What are these waiting days really like for you?',
    textHi: 'Ye intezaar ke din asal mein kaise lagte hain?',
    chapter: TtcChapter.theWaitingDays,
  ),
  TtcJournalPrompt(
    id: 'closeness',
    textEn: 'When did you last feel close to each other, outside of all this?',
    textHi: 'Aakhri baar kab ek doosre ke kareeb mehsoos hua, is sab se hat kar?',
    chapter: TtcChapter.tryingTogether,
  ),
  TtcJournalPrompt(
    id: 'first_habit',
    textEn: "What's one habit you've kept up so far?",
    textHi: 'Ab tak koi ek aadat jo sach mein nibhai hai?',
    chapter: TtcChapter.preparingTogether,
  ),
  TtcJournalPrompt(
    id: 'rhythm_noticed',
    textEn: 'What have you noticed about your own rhythm this cycle?',
    textHi: 'Is cycle mein apni rhythm ke baare mein kya notice kiya?',
    chapter: TtcChapter.knowingYourRhythm,
  ),
  TtcJournalPrompt(
    id: 'the_day',
    textEn: "Write about the day you found out. You'll want this later.",
    textHi: 'Us din ke baare mein likhein jab pata chala. Aage ye padhna achha lagega.',
    chapter: TtcChapter.aNewBeginning,
  ),
  TtcJournalPrompt(
    id: 'tell_family',
    textEn: 'What do you wish your family would say instead?',
    textHi: 'Aap chahte hain ki ghaarwaale iski jagah kya kehte?',
  ),
];

/// Today's prompt, preferring one written for the current chapter.
TtcJournalPrompt ttcPromptForToday(TtcChapter chapter, {DateTime? now}) {
  final forChapter =
      ttcJournalPrompts.where((p) => p.chapter == chapter).toList();
  final general = ttcJournalPrompts.where((p) => p.chapter == null).toList();
  // Chapter-specific prompts surface roughly every third day, so the couple
  // gets material written for exactly where they are without the general
  // prompts disappearing.
  final day = ttcDayIndex(now);
  if (forChapter.isNotEmpty && day % 3 == 0) {
    return forChapter[(day ~/ 3) % forChapter.length];
  }
  return general[day % general.length];
}
