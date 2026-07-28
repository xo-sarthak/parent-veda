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
  });

  final String id;

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
    titleEn: 'The fertile window is wider than most people think',
    titleHi: 'Fertile window utna chhota nahi jitna log samajhte hain',
    bodyEn:
        'An egg lives for about a day after it is released. Sperm can survive around five days inside the body. That means the days BEFORE ovulation matter as much as the day itself - which is why ParentVeda shows a window of several days rather than pointing at one.\n\nIt also means you do not have to get a single day right. Couples who are simply close a few times across that window do as well as couples who plan around a test.',
    bodyHi:
        'Egg release hone ke baad lagbhag ek din tak zinda rehta hai. Sperm body ke andar takreeban paanch din tak reh sakta hai. Iska matlab - ovulation se PEHLE ke din utne hi important hain jitna khud ka din. Isiliye ParentVeda ek hi din nahi, kuch dino ki window dikhata hai.\n\nAur iska ek aur matlab - aapko ek hi din perfectly pakadna zaroori nahi hai. Jo couples us window mein bas kuch baar kareeb aate hain, wo utna hi accha karte hain jitne wo jo test dekh kar plan karte hain.',
    takeawayEn: 'A few relaxed days beat one perfectly-timed one.',
    takeawayHi: 'Kuch aaram se bitaye din, ek perfectly planned din se behtar hain.',
  ),
  TtcInsight(
    id: 'folic_acid_timing',
    topic: 'nutrition',
    titleEn: 'Folic acid works before you know you are pregnant',
    titleHi: 'Folic acid tab kaam karta hai jab pata bhi nahi hota',
    bodyEn:
        "A baby's neural tube - which becomes the brain and spine - closes in the first four weeks, often before a period is even missed. Folic acid has to already be in the body by then, which is why every guideline says start it while trying, not after a positive test.\n\n400 micrograms daily is the standard recommendation. Your doctor may suggest more if you have diabetes, epilepsy, a high BMI, or a previous pregnancy affected by a neural tube defect.",
    bodyHi:
        'Baby ka neural tube - jo aage chal kar brain aur spine banta hai - pehle chaar hafton mein band ho jaata hai, aksar period miss hone se bhi pehle. Tab tak folic acid body mein pehle se hona chahiye. Isiliye har guideline kehti hai - koshish karte waqt shuru karein, positive test ke baad nahi.\n\nRoz 400 microgram standard salaah hai. Agar aapko diabetes, epilepsy, zyada BMI ho, ya pehle kisi pregnancy mein neural tube defect raha ho, toh doctor zyada bhi keh sakte hain.',
    takeawayEn: 'If you start one thing this week, start folic acid.',
    takeawayHi: 'Is hafte agar ek cheez shuru karni hai, toh folic acid karein.',
    forPartner: false,
  ),
  TtcInsight(
    id: 'sperm_cycle_90_days',
    topic: 'male',
    titleEn: 'Sperm takes about three months to make',
    titleHi: 'Sperm banne mein lagbhag teen mahine lagte hain',
    bodyEn:
        'The sperm released today began forming roughly seventy to ninety days ago. That is genuinely good news: it means the changes a man makes now - sleep, alcohol, smoking, heat, weight, stress - show up in about three months.\n\nIt also means results are not instant, and a single hard month does not undo anything. Consistency across a season matters far more than any one week.',
    bodyHi:
        'Aaj jo sperm release hota hai, wo lagbhag sattar se nabbe din pehle banna shuru hua tha. Ye asal mein achhi khabar hai: matlab aaj jo badlaav mard karta hai - neend, sharab, smoking, garmi, wazan, stress - wo teen mahine mein dikhte hain.\n\nIska ye bhi matlab hai ki result turant nahi milta, aur ek mushkil mahina sab kuch kharab nahi karta. Ek season tak consistency, kisi ek hafte se kahin zyada maayne rakhti hai.',
    takeawayEn: 'What he changes today shows up around three months from now.',
    takeawayHi: 'Jo aaj badlega, wo lagbhag teen mahine baad dikhega.',
  ),
  TtcInsight(
    id: 'cervical_mucus',
    topic: 'fertility',
    titleEn: 'Your body already gives you a signal - for free',
    titleHi: 'Aapka body pehle se ek signal deta hai - bilkul muft',
    bodyEn:
        'In the days approaching ovulation, cervical mucus usually becomes clearer, more slippery and stretchier - often compared to raw egg white. After ovulation it typically turns thicker and drier again.\n\nThis costs nothing and needs no kit. Many women find it a more reliable everyday guide than an app prediction, because it reflects what the body is doing right now rather than what a calendar expects.',
    bodyHi:
        'Ovulation ke paas aate dino mein cervical mucus aam taur par zyada saaf, chikna aur khinchne wala ho jaata hai - jise aksar kacche ande ke safed hisse se compare karte hain. Ovulation ke baad ye phir se gaadha aur sookha ho jaata hai.\n\nIsmein kuch kharch nahi, koi kit nahi chahiye. Bahut si auratein ise app ki prediction se zyada bharosemand maanti hain, kyunki ye batata hai ki body abhi kya kar raha hai - na ki calendar kya soch raha hai.',
    takeawayEn: 'Watch what your body does, not only what the app predicts.',
    takeawayHi: 'App ki prediction ke saath, apne body ko bhi dekhein.',
    forPartner: false,
  ),
  TtcInsight(
    id: 'how_long_is_normal',
    topic: 'medical',
    titleEn: 'How long is normal before seeing someone?',
    titleHi: 'Doctor se milne se pehle kitna time normal hai?',
    bodyEn:
        'About eight in ten couples conceive within a year of trying, and around nine in ten within two. So most of the time, more time is genuinely the answer.\n\nThe usual guidance is to see a doctor after a year of trying - or after six months if the woman is over thirty-five, or sooner at any age if periods are very irregular or absent, there is known endometriosis or PCOS, previous pelvic surgery or infection, or a known issue on the male side. Going earlier is never wrong; it just is not required.',
    bodyHi:
        'Das mein se lagbhag aath couples ek saal ke andar conceive kar lete hain, aur das mein se nau do saal ke andar. Toh zyadatar waqt, thoda aur samay hi asli jawab hota hai.\n\nAam salaah ye hai ki ek saal koshish ke baad doctor se milein - ya chhe mahine baad agar aurat pentiis se upar hai, ya kisi bhi umar mein pehle agar periods bahut irregular ya band hain, endometriosis ya PCOS pata hai, pehle pelvic surgery ya infection hua hai, ya mard ki taraf koi issue pata hai. Jaldi jaana kabhi galat nahi - bas zaroori nahi.',
    takeawayEn: 'Most couples need time, not treatment. Going early is still fine.',
    takeawayHi: 'Zyadatar couples ko ilaaj nahi, samay chahiye. Jaldi jaana phir bhi theek hai.',
  ),
  TtcInsight(
    id: 'stress_and_fertility',
    topic: 'emotional',
    titleEn: 'Stress is real - and it is not your fault',
    titleHi: 'Stress asli hai - aur ye aapki galti nahi hai',
    bodyEn:
        'Severe, sustained stress can delay or suppress ovulation, so the link is not imaginary. But the honest version is narrower than the version people repeat: ordinary work stress and ordinary worry are not what stops a healthy couple conceiving.\n\nThe reason this matters is that "just relax" is one of the most painful things anyone says during this chapter. It converts a medical uncertainty into a personal failure. It is not one.',
    bodyHi:
        'Tez aur lambe samay ka stress ovulation ko der kar sakta hai ya rok sakta hai - toh ye connection kalpana nahi hai. Lekin sach us baat se kaafi chhota hai jo log dohraate hain: rozmarra ka office stress aur aam chinta, kisi healthy couple ko conceive karne se nahi rokti.\n\nYe isliye maayne rakhta hai kyunki "bas relax karo" is chapter mein kahi jaane wali sabse takleef dene wali baat hai. Ye ek medical uncertainty ko personal failure bana deti hai. Wo hai nahi.',
    takeawayEn: '"Just relax" is not advice. Your stress did not cause this.',
    takeawayHi: '"Bas relax karo" salaah nahi hai. Aapke stress ne ye nahi kiya.',
  ),
  TtcInsight(
    id: 'caffeine',
    topic: 'lifestyle',
    titleEn: 'You do not have to give up chai',
    titleHi: 'Chai chhodne ki zaroorat nahi hai',
    bodyEn:
        'Most guidance places the limit around 200mg of caffeine a day while trying to conceive and during pregnancy. In practical Indian terms that is roughly two to three cups of home-made chai, or about two cups of filter coffee.\n\nWhat is easy to miss is caffeine hiding elsewhere: cola, energy drinks, green tea and dark chocolate all add to the total. So the useful habit is not cutting chai out - it is noticing everything else.',
    bodyHi:
        'Zyadatar guidance conceive karne ki koshish aur pregnancy ke dauraan roz lagbhag 200mg caffeine ki hadd batati hai. Practically, ye ghar ki do-teen cup chai hai, ya lagbhag do cup filter coffee.\n\nJo cheez aksar chhoot jaati hai wo hai chhupi hui caffeine: cola, energy drinks, green tea aur dark chocolate - sab total mein judte hain. Toh kaam ki aadat chai chhodna nahi hai - baaki sab ko notice karna hai.',
    takeawayEn: 'Two to three cups of chai is fine. Count the cola too.',
    takeawayHi: 'Do-teen cup chai theek hai. Cola bhi gina karein.',
  ),
  TtcInsight(
    id: 'lh_strips',
    topic: 'fertility',
    titleEn: 'What an ovulation strip actually tells you',
    titleHi: 'Ovulation strip asal mein kya batati hai',
    bodyEn:
        'An LH strip detects the hormone surge that usually comes twelve to thirty-six hours before an egg is released. So a positive means "soon", not "now" - and it is a signal to relax about timing for the next couple of days, not to rush.\n\nTwo honest limits. A surge does not prove an egg was actually released. And in PCOS, LH can run high all month, which makes strips confusing rather than helpful - your doctor may suggest tracking a different way.',
    bodyHi:
        'LH strip us hormone surge ko pakadti hai jo aam taur par egg release hone se baarah se chhattis ghante pehle aata hai. Toh positive ka matlab hai "jald", "abhi" nahi - aur ye agle do din timing ke baare mein aaram karne ka signal hai, bhaagne ka nahi.\n\nDo imaandaar hadd. Surge ye sabit nahi karta ki egg sach mein release hua. Aur PCOS mein LH poora mahina high reh sakta hai, jisse strips madad ke bajaye confuse karti hain - doctor koi doosra tareeka bata sakte hain.',
    takeawayEn: 'A positive strip means soon, not now. In PCOS it can mislead.',
    takeawayHi: 'Positive strip ka matlab "jald" hai, "abhi" nahi. PCOS mein ye galat raasta dikha sakti hai.',
  ),
  TtcInsight(
    id: 'vitamin_d_india',
    topic: 'nutrition',
    titleEn: 'Vitamin D deficiency is the quiet Indian default',
    titleHi: 'Vitamin D ki kami India mein chupchaap aam hai',
    bodyEn:
        'Study after study finds a majority of Indian adults are low in vitamin D - including people who spend time outdoors. Sunscreen, air quality, indoor work, darker skin and covered clothing all reduce how much is actually made.\n\nIt is one of the cheapest blood tests available and one of the easiest things to correct. Both partners are worth testing: low vitamin D has been linked to sperm quality as well as cycle regularity.',
    bodyHi:
        'Ek ke baad ek study batati hai ki zyadatar Indian adults mein vitamin D kam hai - un logon mein bhi jo dhoop mein rehte hain. Sunscreen, hawa ki quality, indoor kaam, gehri skin aur dhaka hua kapda - sab kam kar dete hain ki asal mein kitna banta hai.\n\nYe sabse saste blood tests mein se ek hai aur sabse aasaani se theek hone wali cheez. Dono partners ka test karwana theek hai: kam vitamin D ka sambandh sperm quality aur cycle ki regularity dono se juda hai.',
    takeawayEn: 'Both of you can test for this. It is cheap and fixable.',
    takeawayHi: 'Dono ka test ho sakta hai. Sasta hai aur theek ho jaata hai.',
  ),
  TtcInsight(
    id: 'heat_and_sperm',
    topic: 'male',
    titleEn: 'Heat matters more than most men are told',
    titleHi: 'Garmi utni maayne rakhti hai jitna aksar bataya nahi jaata',
    bodyEn:
        'Sperm production works best a couple of degrees below core body temperature - which is the whole reason the testes sit outside the body. Sustained heat works against that: long hot baths, saunas, a laptop resting directly on the lap for hours, and very tight synthetic underwear in Indian summers.\n\nNone of these is a catastrophe and none is permanent. But they are among the easiest things on this entire list to change, and they cost nothing.',
    bodyHi:
        'Sperm banne ka kaam body ke core temperature se do degree kam par sabse accha hota hai - isi wajah se testes body ke bahar hote hain. Lagatar garmi iske khilaf jaati hai: lambe garam paani ke nahaane, sauna, ghanton tak god par laptop, aur Indian garmi mein bahut tight synthetic underwear.\n\nInmein se koi bhi aafat nahi hai aur na hi permanent. Lekin poori list mein ye badalne ke sabse aasaan cheezein hain, aur inmein kuch kharch nahi hota.',
    takeawayEn: 'Laptop off the lap. Loose cotton. It costs nothing to try.',
    takeawayHi: 'Laptop god se hatayein. Dheela cotton pehnein. Koshish muft hai.',
  ),
  TtcInsight(
    id: 'pcos_basics',
    topic: 'medical',
    titleEn: 'PCOS explained without the panic',
    titleHi: 'PCOS - bina ghabrahat ke',
    bodyEn:
        'PCOS is a hormonal pattern, not a disease you either have or do not. It commonly means ovulation is irregular or infrequent - which makes timing harder, not impossible. Many women with PCOS conceive naturally, and many more with straightforward help such as ovulation induction.\n\nWhat consistently helps: regular movement, a diet that keeps blood sugar steady, sleep, and working with a doctor rather than around one. What does not help is any single food, tea or powder sold as a cure.',
    bodyHi:
        'PCOS ek hormonal pattern hai, aisi bimari nahi jo ya toh hoti hai ya nahi. Aam taur par iska matlab hai ovulation irregular ya kam hota hai - jisse timing mushkil hoti hai, namumkin nahi. Bahut si auratein PCOS ke saath naturally conceive karti hain, aur bahut si thodi si madad se jaise ovulation induction.\n\nJo hamesha madad karta hai: regular movement, aisa khana jo blood sugar sthir rakhe, neend, aur doctor ke saath kaam karna - unke bina nahi. Jo madad nahi karta: koi bhi ek khana, chai ya powder jo "ilaaj" bol kar becha jaata hai.',
    takeawayEn: 'PCOS makes timing harder, not impossible. No single food cures it.',
    takeawayHi: 'PCOS timing mushkil karta hai, namumkin nahi. Koi ek khana iska ilaaj nahi.',
  ),
  TtcInsight(
    id: 'two_week_wait',
    topic: 'emotional',
    titleEn: 'Why the wait feels longer than it is',
    titleHi: 'Intezaar asal se lamba kyun lagta hai',
    bodyEn:
        'The stretch between ovulation and a period is around two weeks, and it is the part of the cycle with nothing to do. Every twinge becomes evidence. Early pregnancy symptoms and ordinary pre-period symptoms are produced by the same hormone, which is exactly why they feel identical - and why symptom-spotting cannot tell you anything.\n\nThe kindest thing you can do with these days is give them a purpose that is not watching. Something to finish, somewhere to go, someone to see.',
    bodyHi:
        'Ovulation aur period ke beech ka waqt lagbhag do hafte ka hota hai, aur cycle ka yahi hissa hai jismein karne ko kuch nahi hota. Har chhota sa ehsaas sabooot lagne lagta hai. Shuruaati pregnancy ke symptoms aur aam period se pehle ke symptoms ek hi hormone se bante hain - isiliye wo bilkul ek jaise lagte hain, aur isiliye symptom dekhna kuch bata nahi sakta.\n\nIn dino ke saath sabse achhi baat ye ki jaa sakti hai ki inhe dekhne ke alawa koi maqsad de dein. Kuch poora karne ko, kahin jaane ko, kisi se milne ko.',
    takeawayEn: 'Early pregnancy and pre-period feel the same. Symptom-spotting cannot tell you.',
    takeawayHi: 'Shuruaati pregnancy aur period se pehle ek jaisa lagta hai. Symptom dekhne se pata nahi chalta.',
  ),
  TtcInsight(
    id: 'sleep_and_hormones',
    topic: 'lifestyle',
    titleEn: 'Sleep is a fertility habit, not a luxury',
    titleHi: 'Neend ek fertility aadat hai, aish nahi',
    bodyEn:
        'The hormones that drive ovulation and sperm production are released on a daily rhythm tied to sleep and darkness. Shift work and chronically short nights disrupt that rhythm on both sides of a couple.\n\nSeven to nine hours, at roughly the same time each night, is the whole recommendation. If shift work is not negotiable - and for many people in India it is not - consistency of whatever schedule you have matters more than the hours themselves.',
    bodyHi:
        'Jo hormones ovulation aur sperm banne ko chalate hain, wo neend aur andhere se judi ek roz ki rhythm par nikalte hain. Shift work aur lagatar chhoti raatein us rhythm ko couple ke dono taraf bigaadti hain.\n\nSaat se nau ghante, roz lagbhag ek hi samay - poori salaah bas itni hai. Agar shift work badla nahi ja sakta - aur India mein bahut logon ke liye nahi badal sakta - toh jo bhi schedule hai uski consistency, ghanton se zyada maayne rakhti hai.',
    takeawayEn: 'Same bedtime beats more hours. Both of you.',
    takeawayHi: 'Ek hi samay sona, zyada ghanton se behtar hai. Dono ke liye.',
  ),
  TtcInsight(
    id: 'weight_and_cycles',
    topic: 'lifestyle',
    titleEn: 'Small weight changes can restart cycles',
    titleHi: 'Wazan mein chhota badlaav cycles wapas la sakta hai',
    bodyEn:
        'Body fat is part of how the body makes and regulates oestrogen, so cycles can become irregular at both ends of the range - too high and too low. Athletes and people who under-eat lose cycles as often as anyone else.\n\nWhere weight is a factor, research repeatedly finds that a shift of around five per cent of body weight is often enough to restore ovulation. That is a genuinely small number, and it is the reason this is worth mentioning at all - not to make anyone feel judged.',
    bodyHi:
        'Body fat us tareeke ka hissa hai jisse body oestrogen banata aur sambhalta hai, isliye cycles range ke dono siron par irregular ho sakte hain - bahut zyada aur bahut kam, dono par. Athletes aur kam khaane wale log utni hi baar cycles khote hain jitne aur koi.\n\nJahan wazan ek wajah hai, research baar-baar batati hai ki body weight ka lagbhag paanch pratishat badlaav aksar ovulation wapas laane ke liye kaafi hota hai. Ye sach mein chhota number hai, aur isi wajah se ye batane layak hai - kisi ko judge karne ke liye nahi.',
    takeawayEn: 'Around five per cent is often enough. Both directions count.',
    takeawayHi: 'Lagbhag paanch pratishat aksar kaafi hota hai. Dono taraf ginti hai.',
  ),
  TtcInsight(
    id: 'semen_analysis',
    topic: 'male',
    titleEn: 'The test that should happen first, and rarely does',
    titleHi: 'Wo test jo pehle hona chahiye, aur aksar hota nahi',
    bodyEn:
        'A male factor is involved in roughly forty to fifty per cent of couples who struggle to conceive. Yet the woman is usually investigated first, through tests that are more invasive, more expensive and slower.\n\nA semen analysis is a simple, inexpensive, same-day test. Doing it early does not accuse anyone of anything - it just means you are looking at the whole picture instead of half of it. If the result is unexpected, repeat it after two to three months before drawing conclusions; results vary a great deal between samples.',
    bodyHi:
        'Jo couples conceive karne mein mushkil jhelte hain, unmein lagbhag chalis se pachas pratishat mein mard ki taraf ka factor shaamil hota hai. Phir bhi aam taur par pehle aurat ke test hote hain - jo zyada takleefdeh, zyada mehnge aur zyada dheere hote hain.\n\nSemen analysis ek simple, sasta, usi din ka test hai. Ise jaldi karwana kisi par ilzaam nahi hai - iska bas matlab hai ki aap poori tasveer dekh rahe hain, aadhi nahi. Agar result unexpected aaye, toh nateeja nikalne se pehle do-teen mahine baad dobara karwayein; samples ke beech results kaafi badalte hain.',
    takeawayEn: 'Cheap, quick, and it looks at the half that usually gets skipped.',
    takeawayHi: 'Sasta, jaldi - aur wo aadha hissa dekhta hai jo aksar chhoot jaata hai.',
  ),
  TtcInsight(
    id: 'indian_plate',
    topic: 'nutrition',
    titleEn: 'A fertility diet looks a lot like a normal Indian thali',
    titleHi: 'Fertility diet dikhne mein aam Indian thali jaisi hi hai',
    bodyEn:
        'There is no fertility superfood. What research supports is a pattern: whole grains instead of refined, dal and other plant protein, plenty of vegetables, healthy fats, and less ultra-processed food and sugar.\n\nA thali with roti or brown rice, dal, a sabzi, dahi and a little ghee is already most of that. The changes worth making are usually swaps, not replacements - bajra or jowar in place of maida, and one extra vegetable.',
    bodyHi:
        'Koi fertility superfood nahi hota. Research jise support karti hai wo ek pattern hai: refined ki jagah sabut anaaj, dal aur doosra plant protein, khoob sabziyan, achhi fats, aur kam ultra-processed khana aur cheeni.\n\nRoti ya brown rice, dal, sabzi, dahi aur thoda ghee wali thali mein ye zyadatar pehle se hai. Jo badlaav karne layak hain wo aksar swap hain, replacement nahi - maida ki jagah bajra ya jowar, aur ek extra sabzi.',
    takeawayEn: 'No superfood. Swap maida for bajra and add one vegetable.',
    takeawayHi: 'Koi superfood nahi. Maida ki jagah bajra, aur ek sabzi zyada.',
  ),
  TtcInsight(
    id: 'amh_meaning',
    topic: 'medical',
    titleEn: 'AMH is not a fertility score',
    titleHi: 'AMH koi fertility score nahi hai',
    bodyEn:
        'AMH estimates how many eggs remain - the quantity of the reserve. It says very little about the quality of those eggs, and on its own it is a poor predictor of whether a woman will conceive naturally.\n\nIts real use is planning: it helps a specialist predict how ovaries will respond to IVF stimulation. A low AMH in a woman with regular cycles is not a verdict, and it is not a reason to panic-book treatment. Ask what the number changes about the plan - if the answer is nothing, it changes nothing.',
    bodyHi:
        'AMH andaaza lagata hai ki kitne eggs bache hain - reserve ki ginti. Ye un eggs ki quality ke baare mein bahut kam batata hai, aur akele ye kharaab predictor hai ki aurat naturally conceive karegi ya nahi.\n\nIska asli istemaal planning hai: ye specialist ko batata hai ki ovaries IVF stimulation par kaisa jawab denge. Regular cycles wali aurat mein kam AMH koi faisla nahi hai, aur ghabra kar treatment book karne ki wajah bhi nahi. Poochhein ki ye number plan mein kya badalta hai - agar jawab "kuch nahi" hai, toh sach mein kuch nahi badalta.',
    takeawayEn: 'AMH counts eggs, not chances. Ask what it changes about the plan.',
    takeawayHi: 'AMH eggs ginta hai, mauke nahi. Poochhein ki ye plan mein kya badalta hai.',
  ),
  TtcInsight(
    id: 'alcohol_smoking',
    topic: 'lifestyle',
    titleEn: 'The two things with the clearest evidence',
    titleHi: 'Do cheezein jinke saboot sabse saaf hain',
    bodyEn:
        'Most lifestyle advice in this space is soft. Two things are not. Smoking - including passive smoking at home - is consistently linked to reduced fertility in both partners and to earlier menopause. Heavy alcohol is linked to disrupted ovulation and to lower sperm quality.\n\nOccasional social drinking while trying is not the same as heavy drinking, and the evidence there is genuinely mixed. Smoking has no such grey area, for either of you.',
    bodyHi:
        'Is field ki zyadatar lifestyle salaah narm hoti hai. Do cheezein nahi hain. Smoking - ghar mein passive smoking bhi - dono partners mein kam fertility aur jaldi menopause se lagatar judi hai. Zyada sharab, ovulation bigadne aur kam sperm quality se judi hai.\n\nKoshish ke dauraan kabhi-kabhaar social drinking, heavy drinking jaisi baat nahi hai, aur wahan saboot sach mein mile-jule hain. Smoking mein aisa koi grey area nahi hai - dono ke liye.',
    takeawayEn: 'Smoking has no safe amount here. Passive counts.',
    takeawayHi: 'Yahan smoking ki koi safe matra nahi hai. Passive bhi ginti hai.',
  ),
  TtcInsight(
    id: 'bbt_truth',
    topic: 'fertility',
    titleEn: 'Temperature tells you afterwards, not before',
    titleHi: 'Temperature baad mein batata hai, pehle nahi',
    bodyEn:
        'Basal body temperature rises slightly after ovulation and stays up. It is genuinely useful for confirming that ovulation happened and for learning the shape of your own cycle over a few months.\n\nWhat it cannot do is tell you ovulation is coming - by the time the temperature rises, the window has essentially closed. So treat it as a record, not an alarm. And if daily 6am measuring makes the whole thing heavier, stopping is a perfectly good decision.',
    bodyHi:
        'Basal body temperature ovulation ke baad thoda badh jaata hai aur bada rehta hai. Ye ye confirm karne ke liye sach mein kaam ka hai ki ovulation hua, aur kuch mahinon mein apne cycle ka aakaar samajhne ke liye.\n\nJo ye nahi kar sakta wo hai aane wale ovulation ki khabar dena - jab tak temperature badhta hai, window lagbhag band ho chuki hoti hai. Toh ise record maanein, alarm nahi. Aur agar roz subah 6 baje naapna poori baat ko bhaari bana deta hai, toh rok dena bilkul theek faisla hai.',
    takeawayEn: 'It confirms ovulation happened. It cannot warn you it is coming.',
    takeawayHi: 'Ye batata hai ki ovulation hua. Aane se pehle nahi bata sakta.',
  ),
  TtcInsight(
    id: 'lubricant',
    topic: 'fertility',
    titleEn: 'Most lubricants are not sperm-friendly',
    titleHi: 'Zyadatar lubricants sperm ke liye theek nahi hote',
    bodyEn:
        'This is small, rarely mentioned, and easy to fix. Many ordinary lubricants - and saliva - reduce how well sperm can move. If you use one, look for a product specifically labelled fertility-friendly or sperm-safe.\n\nIt is unlikely to be the reason a couple has not conceived. But it is a two-minute change that costs almost nothing, which puts it in the same bracket as taking the laptop off his lap.',
    bodyHi:
        'Ye chhoti baat hai, kam batayi jaati hai, aur aasaani se theek ho jaati hai. Bahut se aam lubricants - aur thook - sperm ke chalne ki kshamta kam kar dete hain. Agar aap istemaal karte hain, toh aisa product dhoondhein jispar saaf likha ho fertility-friendly ya sperm-safe.\n\nYe shayad hi wajah hogi ki couple conceive nahi kar paya. Lekin ye do minute ka badlaav hai jismein kuch kharch nahi - yaani laptop god se hataane wali hi category.',
    takeawayEn: 'If you use one, choose a fertility-friendly product.',
    takeawayHi: 'Agar istemaal karte hain, toh fertility-friendly product chunein.',
  ),
  TtcInsight(
    id: 'thyroid',
    topic: 'medical',
    titleEn: 'The thyroid test worth doing early',
    titleHi: 'Thyroid test jo jaldi karwana theek hai',
    bodyEn:
        'An underactive thyroid can cause irregular cycles, disrupt ovulation and raise the risk of early miscarriage - and it is common in Indian women, often without obvious symptoms.\n\nTSH is an inexpensive blood test, and when it is off, treatment is usually a single daily tablet. Of everything on a fertility work-up, this is one of the cheapest to check and among the most straightforward to correct.',
    bodyHi:
        'Kam kaam karta thyroid irregular cycles kar sakta hai, ovulation bigaad sakta hai aur shuruaati miscarriage ka khatra badha sakta hai - aur ye Indian auraton mein aam hai, aksar bina saaf symptoms ke.\n\nTSH ek sasta blood test hai, aur jab ye theek nahi hota, toh ilaaj aam taur par roz ki ek goli hoti hai. Poore fertility work-up mein ye check karne ke liye sabse saste mein se ek hai, aur theek karne ke liye sabse seedha.',
    takeawayEn: 'Cheap test, common problem, usually one tablet.',
    takeawayHi: 'Sasta test, aam samasya, aam taur par ek goli.',
    forPartner: false,
  ),
  TtcInsight(
    id: 'talking_to_family',
    topic: 'emotional',
    titleEn: 'You are allowed to not answer',
    titleHi: 'Aapko jawab na dene ka haq hai',
    bodyEn:
        '"Good news kab de rahe ho?" arrives at every wedding, every festival and most family calls. It is usually meant warmly and it lands like a bill.\n\nYou do not owe anyone a status update on your body. A short, kind, repeatable line helps more than a new answer each time - something like "we will tell you first when there is something to tell." Agree on one line together, so neither of you is improvising alone in a room full of relatives.',
    bodyHi:
        '"Good news kab de rahe ho?" har shaadi, har tyohaar aur zyadatar family calls mein aata hai. Aksar ye pyaar se poochha jaata hai, aur bill jaisa lagta hai.\n\nAapko apne body ka status update kisi ko dena zaroori nahi hai. Har baar naya jawab sochne se behtar hai ek chhoti, meethi, dohraane layak line - jaise "jab batane layak kuch hoga, sabse pehle aapko batayenge." Ek line dono milkar tay kar lein, taaki rishtedaaron se bhare kamre mein koi akela na sochta rahe.',
    takeawayEn: 'Agree on one line together. Use it every time.',
    takeawayHi: 'Ek line saath mein tay karein. Har baar wahi istemaal karein.',
  ),
  TtcInsight(
    id: 'exercise_amount',
    topic: 'lifestyle',
    titleEn: 'Movement helps - until it is too much',
    titleHi: 'Movement madad karta hai - jab tak zyada na ho jaye',
    bodyEn:
        'Moderate regular activity supports hormone balance, insulin sensitivity and sleep, and it helps notably in PCOS. Around thirty minutes most days is the usual recommendation, and a brisk walk counts.\n\nThe other end is real too: very intense training, especially combined with under-eating, can stop ovulation altogether. If cycles have become irregular since a new training routine, that is worth mentioning to a doctor rather than pushing through.',
    bodyHi:
        'Moderate regular activity hormone balance, insulin sensitivity aur neend ko support karti hai, aur PCOS mein khaas madad karti hai. Zyadatar dino mein lagbhag tees minute aam salaah hai, aur tez chalna bhi ginta hai.\n\nDoosra sira bhi asli hai: bahut tez training, khaaskar kam khaane ke saath, ovulation poori tarah rok sakti hai. Agar naye training routine ke baad se cycles irregular ho gaye hain, toh use jhelte rehne ke bajaye doctor ko batana theek hai.',
    takeawayEn: 'Thirty minutes most days. A brisk walk counts.',
    takeawayHi: 'Zyadatar dino mein tees minute. Tez chalna bhi ginta hai.',
  ),
  TtcInsight(
    id: 'ivf_is_not_failure',
    topic: 'medical',
    titleEn: 'Treatment is a route, not a verdict',
    titleHi: 'Ilaaj ek raasta hai, faisla nahi',
    bodyEn:
        'Couples often delay seeing a specialist because arriving there feels like an admission. It is worth naming plainly: ovulation induction, IUI and IVF are steps on a path, and many couples need only the first of them.\n\nGoing early costs you nothing but a consultation. Waiting can cost time that, for some causes, matters. Whatever you decide, decide it together and decide it with information - not because a relative had an opinion at a wedding.',
    bodyHi:
        'Couples aksar specialist ke paas jaane mein der karte hain kyunki wahan pahunchna haar maanne jaisa lagta hai. Ise saaf kehna zaroori hai: ovulation induction, IUI aur IVF ek raaste ke padaav hain, aur bahut se couples ko inmein se sirf pehla hi chahiye hota hai.\n\nJaldi jaane mein ek consultation ke alawa kuch kharch nahi. Intezaar karne mein waqt ja sakta hai, jo kuch wajahon ke liye maayne rakhta hai. Jo bhi tay karein, saath mein karein aur jaankari ke saath karein - isliye nahi ki kisi rishtedaar ne shaadi mein apni raay de di.',
    takeawayEn: 'A consultation costs a consultation. Decide together, with facts.',
    takeawayHi: 'Ek consultation ka kharch bas ek consultation hai. Saath mein, jaankari ke saath tay karein.',
  ),
];

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
        'Sperm survive around five days, so the window is roughly six days long. The days before ovulation matter as much as the day itself.',
    truthHi:
        'Sperm lagbhag paanch din zinda rehte hain, toh window karib chhe din ki hoti hai. Ovulation se pehle ke din utne hi important hain jitna khud ka din.',
  ),
  TtcMyth(
    id: 'infertility_is_female',
    mythEn: 'Infertility is mostly a woman\'s problem.',
    mythHi: 'Infertility zyadatar aurat ki samasya hoti hai.',
    truthEn:
        'A male factor is involved in roughly forty to fifty per cent of cases. A semen analysis is quick and inexpensive, and is often the sensible first test.',
    truthHi:
        'Lagbhag chalis se pachas pratishat maamlon mein mard ka factor shaamil hota hai. Semen analysis jaldi aur sasta hai, aur aksar samajhdaari bhara pehla test hota hai.',
  ),
  TtcMyth(
    id: 'stress_causes_infertility',
    mythEn: 'Stress alone causes infertility.',
    mythHi: 'Sirf stress se infertility hoti hai.',
    truthEn:
        'Severe sustained stress can delay ovulation, but ordinary worry does not stop a healthy couple conceiving. "Just relax" is not medical advice.',
    truthHi:
        'Tez aur lagatar stress ovulation mein der kar sakta hai, lekin aam chinta kisi healthy couple ko conceive karne se nahi rokti. "Bas relax karo" medical salaah nahi hai.',
  ),
  TtcMyth(
    id: 'lying_down_after',
    mythEn: 'You must lie down with your legs up afterwards.',
    mythHi: 'Baad mein taange upar karke letna zaroori hai.',
    truthEn:
        'Sperm reach the cervix within minutes. Position and posture have never been shown to change the outcome - do whatever is comfortable.',
    truthHi:
        'Sperm minton mein cervix tak pahunch jaate hain. Position ya posture se nateeja badalta hai, ye kabhi sabit nahi hua - jo aaram se ho, wahi karein.',
  ),
  TtcMyth(
    id: 'age_cliff_35',
    mythEn: 'Fertility falls off a cliff at thirty-five.',
    mythHi: 'Pentiis par fertility ekdum girr jaati hai.',
    truthEn:
        'Fertility declines gradually from the early thirties, faster after thirty-seven. It is a slope, not a cliff - and thirty-five is a guideline for when to seek help sooner, not a deadline.',
    truthHi:
        'Fertility tees ki shuruaat se dheere-dheere kam hoti hai, aur santees ke baad tezi se. Ye dhalaan hai, khaai nahi - aur pentiis ek guideline hai ki madad kab jaldi leni hai, deadline nahi.',
  ),
  TtcMyth(
    id: 'irregular_means_infertile',
    mythEn: 'Irregular periods mean you cannot conceive.',
    mythHi: 'Irregular periods ka matlab conceive nahi kar sakte.',
    truthEn:
        'Irregular cycles make timing harder and are worth investigating, but many women with irregular periods conceive - some naturally, many with simple help.',
    truthHi:
        'Irregular cycles timing mushkil karte hain aur inhe jaanchna theek hai, lekin bahut si auratein irregular periods ke saath conceive karti hain - kuch naturally, bahut si thodi si madad se.',
  ),
  TtcMyth(
    id: 'previous_child',
    mythEn: 'If you conceived before, it will happen easily again.',
    mythHi: 'Pehle conceive ho gaya toh dobara aasaani se ho jayega.',
    truthEn:
        'Secondary infertility is real and common. Age, weight, a new condition or a male-side change can all shift things. It deserves the same attention as the first time.',
    truthHi:
        'Secondary infertility asli aur aam hai. Umar, wazan, koi nayi condition ya mard ki taraf badlaav - sab kuch badal sakte hain. Ise pehli baar jitna hi dhyaan chahiye.',
  ),
  TtcMyth(
    id: 'more_is_better',
    mythEn: 'The more you try, the better the chances.',
    mythHi: 'Jitna zyada koshish, utna zyada mauka.',
    truthEn:
        'Every day or every other day across the fertile window is plenty. More than that adds nothing, and turning it into a schedule takes a toll on both of you.',
    truthHi:
        'Fertile window mein roz ya ek din chhod kar kaafi hai. Usse zyada kuch nahi jodta, aur ise schedule bana dena dono par bhaari padta hai.',
  ),
  TtcMyth(
    id: 'app_predicts',
    mythEn: 'The app knows exactly when you ovulate.',
    mythHi: 'App ko theek pata hai aap kab ovulate karti hain.',
    truthEn:
        'Any app - including this one - is estimating from past cycles. Your body\'s own signals are better evidence, which is why we always show how confident the estimate is.',
    truthHi:
        'Koi bhi app - ye bhi - pichhle cycles se andaaza lagata hai. Aapke body ke apne signals behtar saboot hain, isiliye hum hamesha batate hain ki andaaza kitna pakka hai.',
  ),
  TtcMyth(
    id: 'hot_foods',
    mythEn: 'Certain "hot" or "cold" foods stop you conceiving.',
    mythHi: 'Kuch "garam" ya "thandi" cheezein conceive hone se rokti hain.',
    truthEn:
        'No single food prevents or causes conception. What is supported is the overall pattern - whole grains, dal, vegetables, healthy fats - not any one item to fear or chase.',
    truthHi:
        'Koi ek khana conceive hone se na rokta hai na karata hai. Jo support karta hai wo poora pattern hai - sabut anaaj, dal, sabziyan, achhi fats - koi ek cheez jise darein ya peechha karein, wo nahi.',
  ),
  TtcMyth(
    id: 'birth_control_delay',
    mythEn: 'Years on the pill delay fertility for years.',
    mythHi: 'Saalon tak pill lene se fertility saalon tak late hoti hai.',
    truthEn:
        'For most women cycles return within one to three months of stopping, regardless of how long they were on it. The injectable is the main exception and can take longer.',
    truthHi:
        'Zyadatar auraton mein pill band karne ke ek se teen mahine mein cycles wapas aa jaate hain, chahe kitne saal li ho. Injectable iska mukhya apwaad hai aur usmein zyada waqt lag sakta hai.',
  ),
  TtcMyth(
    id: 'position_gender',
    mythEn: 'You can choose the baby\'s sex by timing or position.',
    mythHi: 'Timing ya position se bachche ka gender chuna ja sakta hai.',
    truthEn:
        'There is no evidence for any of it. In India, sex determination and selection are also illegal under the PCPNDT Act - and ParentVeda will never help with it.',
    truthHi:
        'Iska koi saboot nahi hai. India mein sex determination aur selection PCPNDT Act ke tahat gair-kanooni bhi hai - aur ParentVeda ismein kabhi madad nahi karega.',
  ),
  TtcMyth(
    id: 'miscarriage_blame',
    mythEn: 'A miscarriage means you did something wrong.',
    mythHi: 'Miscarriage ka matlab aapne kuch galat kiya.',
    truthEn:
        'Most early losses are caused by chromosomal errors that nothing could have prevented - not lifting, not travelling, not working, not stress.',
    truthHi:
        'Zyadatar shuruaati loss chromosomal galtiyon se hote hain jinhe kuch bhi nahi rok sakta tha - na saamaan uthana, na safar, na kaam, na stress.',
  ),
  TtcMyth(
    id: 'ivf_last_resort',
    mythEn: 'IVF is the only treatment there is.',
    mythHi: 'IVF hi ek ilaaj hai.',
    truthEn:
        'It is one of several. Ovulation induction and IUI are simpler, cheaper and often enough. A good clinic starts with the least you need, not the most.',
    truthHi:
        'Ye kai mein se ek hai. Ovulation induction aur IUI aasaan, saste aur aksar kaafi hote hain. Achha clinic sabse kam zaroori cheez se shuru karta hai, sabse zyada se nahi.',
  ),
  TtcMyth(
    id: 'symptom_spotting',
    mythEn: 'Early symptoms tell you before a test can.',
    mythHi: 'Shuruaati symptoms test se pehle bata dete hain.',
    truthEn:
        'Early pregnancy and pre-period symptoms come from the same hormone, so they feel identical. Only a test can tell you - and waiting for it is genuinely the hardest part.',
    truthHi:
        'Shuruaati pregnancy aur period se pehle ke symptoms ek hi hormone se aate hain, isliye ek jaise lagte hain. Sirf test bata sakta hai - aur uska intezaar sach mein sabse mushkil hissa hai.',
  ),
  TtcMyth(
    id: 'male_age',
    mythEn: 'A man\'s age does not matter.',
    mythHi: 'Mard ki umar maayne nahi rakhti.',
    truthEn:
        'It matters less sharply than a woman\'s, but it does matter. Sperm quality and DNA integrity decline gradually from around forty, with a slower rise in some risks.',
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
            : 'One minute of breathing, to slow the nervous system.';
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
            : 'One small action. Never more than two minutes.';
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
          'You are not waiting for your life to start. You are already building the family - this is the first part of it, not the wait before it.',
      textHi:
          'Aap zindagi shuru hone ka intezaar nahi kar rahe. Aap pehle se family bana rahe hain - ye uska pehla hissa hai, uske pehle ka intezaar nahi.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn:
          'Breathe in for four. Hold for four. Out for six. Six times. The longer out-breath is the part that calms - do not rush it.',
      textHi:
          'Chaar tak saans lein. Chaar tak roken. Chhe tak chhodein. Chhe baar. Lambi saans chhodna hi shaant karta hai - jaldi na karein.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.conversation,
      textEn:
          'Ask each other: what do you hope our home feels like, once there is a child in it?',
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
      textEn: 'Put your folic acid somewhere you cannot miss it tomorrow.',
      textHi: 'Apna folic acid aisi jagah rakhein jahan kal nazar aa hi jaye.',
    ),
  ],
  TtcChapter.knowingYourRhythm: [
    TtcRitualItem(
      part: TtcRitualPart.reflection,
      textEn:
          'Learning your cycle is not the same as watching it. The goal is to know your body well enough to stop checking, not to check more often.',
      textHi:
          'Apna cycle samajhna aur use ghoorna, do alag cheezein hain. Maqsad hai body ko itna jaan lena ki baar-baar dekhna band ho jaye - aur zyada dekhna nahi.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn:
          'Sit. Breathe normally. Count ten breaths without changing anything about them. If you lose count, start at one - that is the practice, not a failure.',
      textHi:
          'Baithein. Saamanya saans lein. Bina kuch badle das saans ginein. Ginti bhool jayein toh ek se shuru karein - yahi abhyaas hai, galti nahi.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.conversation,
      textEn:
          'Ask each other: is there anything about this month you have not said out loud yet?',
      textHi:
          'Ek doosre se poochhein: is mahine ke baare mein kuch hai jo abhi tak zubaan par nahi aaya?',
    ),
    TtcRitualItem(
      part: TtcRitualPart.gratitude,
      textEn: 'Name one thing that had nothing to do with trying.',
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
          'These are days to be close, not days to perform. If tonight is not the night for either of you, that is allowed - the window is several days wide for exactly this reason.',
      textHi:
          'Ye din kareeb aane ke hain, kuch "karke dikhane" ke nahi. Agar aaj raat dono mein se kisi ka man nahi hai, toh theek hai - window kai din ki isi wajah se hoti hai.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn:
          'Breathe together. Same room, same pace, one minute. Nothing to say, nothing to decide.',
      textHi:
          'Saath mein saans lein. Ek kamra, ek raftaar, ek minute. Kuch kehna nahi, kuch tay nahi karna.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.conversation,
      textEn:
          'Ask each other: what is one thing I do that makes this feel lighter for you?',
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
          'Nothing you do now changes what is already happening or not happening. That sounds hard, and it is also freedom - these days belong to you, not to the outcome.',
      textHi:
          'Ab aap jo bhi karein, jo ho raha hai ya nahi ho raha, wo nahi badlega. Ye sunne mein mushkil hai, aur ye azaadi bhi hai - ye din aapke hain, nateeje ke nahi.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn:
          'When a thought about the test arrives, notice it, breathe out slowly, and let it pass without arguing with it. Then do it again in ten minutes, because it will come back.',
      textHi:
          'Jab test ka khayal aaye, use notice karein, dheere se saans chhodein, aur bina behes kiye jaane dein. Phir das minute baad dobara - kyunki wo wapas aayega.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.conversation,
      textEn:
          'Ask each other: what should we do this weekend that has nothing to do with any of this?',
      textHi:
          'Ek doosre se poochhein: is weekend hum aisa kya karein jiska is sab se koi lena-dena na ho?',
    ),
    TtcRitualItem(
      part: TtcRitualPart.gratitude,
      textEn: 'Name one ordinary thing today that you would have missed if you were busy waiting.',
      textHi: 'Aaj ki ek aam si baat batayein jo intezaar mein khoye rehte toh chhoot jaati.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.action,
      textEn: 'Do one thing today purely because you enjoy it. Not because it helps.',
      textHi: 'Aaj ek cheez sirf isliye karein ki aapko achhi lagti hai. Isliye nahi ki madad karti hai.',
    ),
  ],
  TtcChapter.aNewBeginning: [
    TtcRitualItem(
      part: TtcRitualPart.reflection,
      textEn:
          'Whatever this chapter took from you, it also taught you how to face something together. That does not disappear now - you will need it.',
      textHi:
          'Is chapter ne aapse jo bhi liya, usne aapko saath mein kuch jhelna bhi sikhaya. Wo ab khatam nahi hota - aage kaam aayega.',
    ),
    TtcRitualItem(
      part: TtcRitualPart.breath,
      textEn: 'Four in, six out. Ten times. There is no hurry from here.',
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
      textEn: 'Book your first appointment. That is the only task today.',
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
        'Folate is the food form of folic acid, and it is needed before conception rather than after.',
    whyHi:
        'Folate folic acid ka khaane wala roop hai, aur ye conceive karne ke baad nahi, pehle chahiye hota hai.',
    mealEn: 'Palak dal with a squeeze of lemon, and roti.',
    mealHi: 'Palak dal, upar se thoda nimbu, aur roti.',
    indianEn:
        'Lemon at the end matters twice over - it protects folate and helps iron absorb. Add it off the heat, not while boiling.',
    indianHi:
        'Aakhir mein nimbu do wajah se zaroori hai - folate bachata hai aur iron sokhne mein madad karta hai. Ise aanch se hata kar daalein, ubalte waqt nahi.',
  ),
  TtcNutrition(
    id: 'iron_bajra',
    nutrientEn: 'Iron',
    nutrientHi: 'Iron',
    whyEn:
        'Low iron is very common in Indian women and is linked to irregular ovulation as well as tiredness.',
    whyHi:
        'Indian auraton mein iron ki kami bahut aam hai, aur iska sambandh irregular ovulation aur thakaan dono se hai.',
    mealEn: 'Bajra roti with gud and a bowl of rajma.',
    mealHi: 'Bajre ki roti, gud ke saath, aur ek katori rajma.',
    indianEn:
        'Chai and coffee block iron absorption. Keep them an hour away from your iron-rich meal rather than with it.',
    indianHi:
        'Chai aur coffee iron sokhne se rokte hain. Inhe iron wale khaane ke saath nahi, ek ghanta pehle ya baad rakhein.',
  ),
  TtcNutrition(
    id: 'omega3',
    nutrientEn: 'Omega-3',
    nutrientHi: 'Omega-3',
    whyEn:
        'Omega-3 fats support hormone production in both partners and are linked to better sperm quality.',
    whyHi:
        'Omega-3 fats dono partners mein hormone banne ko support karti hain, aur behtar sperm quality se judi hain.',
    mealEn: 'A spoon of ground flaxseed in dahi, or fish twice a week.',
    mealHi: 'Dahi mein ek chammach pisi alsi, ya hafte mein do baar machhli.',
    indianEn:
        'Flaxseed must be ground to be absorbed - whole seeds pass straight through. Grind a week\'s worth and keep it in the fridge.',
    indianHi:
        'Alsi pisi honi chahiye tabhi sokhi jaati hai - sabut beej seedhe nikal jaate hain. Hafte bhar ki pees kar fridge mein rakhein.',
  ),
  TtcNutrition(
    id: 'protein_dal',
    nutrientEn: 'Protein',
    nutrientHi: 'Protein',
    whyEn:
        'Most Indian vegetarian diets run low on protein, which affects hormone balance and how steady your energy feels.',
    whyHi:
        'Zyadatar Indian vegetarian khaane mein protein kam hota hai, jo hormone balance aur din bhar ki energy dono par asar daalta hai.',
    mealEn: 'Dal, dahi and a handful of roasted chana as a snack.',
    mealHi: 'Dal, dahi aur snack mein ek mutthi bhuna chana.',
    indianEn:
        'Dal and rice together make a complete protein - the combination Indian kitchens got right long before the science explained it.',
    indianHi:
        'Dal aur chawal saath mein poora protein bante hain - ye jodi Indian rasoi ne science ke samjhaane se bahut pehle sahi kar li thi.',
  ),
  TtcNutrition(
    id: 'vitamin_d_food',
    nutrientEn: 'Vitamin D',
    nutrientHi: 'Vitamin D',
    whyEn:
        'Most Indian adults are low, and it affects cycle regularity as well as sperm quality.',
    whyHi:
        'Zyadatar Indian adults mein kami hai, aur iska asar cycle ki regularity aur sperm quality dono par padta hai.',
    mealEn: 'Fortified milk, egg yolk, and fifteen minutes of morning sun.',
    mealHi: 'Fortified doodh, ande ki zardi, aur pandrah minute subah ki dhoop.',
    indianEn:
        'Food alone rarely fixes a real deficiency here. Test first - it is one of the cheapest blood tests there is - then let a doctor decide the dose.',
    indianHi:
        'Sirf khaane se asli kami shayad hi theek hoti hai. Pehle test karwayein - ye sabse saste blood tests mein se hai - phir doctor dose tay karein.',
  ),
  TtcNutrition(
    id: 'zinc_male',
    nutrientEn: 'Zinc',
    nutrientHi: 'Zinc',
    whyEn:
        'Zinc is directly involved in sperm production and testosterone - this one is mostly for him.',
    whyHi:
        'Zinc seedhe sperm banne aur testosterone se juda hai - ye zyadatar unke liye hai.',
    mealEn: 'Pumpkin seeds, chana, cashews, or a small portion of meat.',
    mealHi: 'Kaddu ke beej, chana, kaju, ya thoda sa maans.',
    indianEn:
        'A fistful of roasted chana at four o\'clock does more for this than most supplements sold for it.',
    indianHi:
        'Shaam chaar baje ek mutthi bhuna chana, iske liye beche jaane wale zyadatar supplements se zyada kaam karta hai.',
  ),
  TtcNutrition(
    id: 'whole_grains',
    nutrientEn: 'Whole grains',
    nutrientHi: 'Sabut anaaj',
    whyEn:
        'Steady blood sugar supports ovulation, and it matters even more in PCOS.',
    whyHi:
        'Sthir blood sugar ovulation ko support karta hai, aur PCOS mein aur bhi zyada maayne rakhta hai.',
    mealEn: 'Jowar or bajra roti in place of maida, most days.',
    mealHi: 'Zyadatar dino mein maida ki jagah jowar ya bajre ki roti.',
    indianEn:
        'You do not have to give up rice. Adding dal, dahi and a sabzi to it flattens the sugar spike more than switching grain does.',
    indianHi:
        'Chawal chhodna zaroori nahi. Uske saath dal, dahi aur sabzi jodna, anaaj badalne se zyada sugar spike ko kam karta hai.',
  ),
  TtcNutrition(
    id: 'hydration',
    nutrientEn: 'Water',
    nutrientHi: 'Paani',
    whyEn:
        'Hydration affects cervical mucus, energy and how well everything else works. It is the least glamorous item on this list.',
    whyHi:
        'Paani cervical mucus, energy aur baaki sab kuch ke theek chalne par asar daalta hai. Is list mein ye sabse kam chamakdaar cheez hai.',
    mealEn: 'Nimbu paani without sugar, and a bottle you actually keep near you.',
    mealHi: 'Bina cheeni ka nimbu paani, aur ek bottle jo sach mein paas rakhein.',
    indianEn:
        'In Indian summers, thirst arrives after you are already low. Drink on a schedule rather than on thirst.',
    indianHi:
        'Indian garmi mein pyaas tab lagti hai jab kami ho chuki hoti hai. Pyaas par nahi, samay par piyein.',
  ),
  TtcNutrition(
    id: 'antioxidants',
    nutrientEn: 'Antioxidants',
    nutrientHi: 'Antioxidants',
    whyEn:
        'Oxidative stress damages both eggs and sperm. Colour on the plate is the simplest proxy for antioxidants.',
    whyHi:
        'Oxidative stress eggs aur sperm dono ko nuksaan pahunchata hai. Thali par rang, antioxidants ka sabse aasaan pata hai.',
    mealEn: 'Amla, seasonal fruit, tomatoes, and dark leafy sabzi.',
    mealHi: 'Amla, mausami phal, tamatar, aur gehri hari sabzi.',
    indianEn:
        'One amla has many times the vitamin C of an orange, costs almost nothing in season, and survives being turned into murabba or juice.',
    indianHi:
        'Ek amle mein santre se kai guna vitamin C hota hai, mausam mein lagbhag muft hai, aur murabba ya juice banne ke baad bhi bacha rehta hai.',
  ),
  TtcNutrition(
    id: 'less_processed',
    nutrientEn: 'Less processed food',
    nutrientHi: 'Kam processed khana',
    whyEn:
        'Trans fats and heavily processed food are among the few dietary factors consistently linked to poorer fertility outcomes.',
    whyHi:
        'Trans fats aur zyada processed khana un gine-chune dietary factors mein hai jo lagatar kharaab fertility se jude paye gaye hain.',
    mealEn: 'Anything cooked at home, in ghee or mustard oil, beats a packet.',
    mealHi: 'Ghar ka bana kuch bhi - ghee ya sarson ke tel mein - packet se behtar hai.',
    indianEn:
        'Ghee is not the villain here. Repeatedly reheated frying oil, and bakery items made with vanaspati, are.',
    indianHi:
        'Yahan ghee villain nahi hai. Baar-baar garam kiya gaya talne ka tel, aur vanaspati wali bakery cheezein hain.',
  ),
  TtcNutrition(
    id: 'b12',
    nutrientEn: 'Vitamin B12',
    nutrientHi: 'Vitamin B12',
    whyEn:
        'Deficiency is very common in Indian vegetarians and is linked to ovulation problems and early pregnancy risk.',
    whyHi:
        'Indian vegetarians mein iski kami bahut aam hai, aur ye ovulation ki dikkat aur shuruaati pregnancy ke khatre se judi hai.',
    mealEn: 'Dahi, paneer, milk, eggs - or a supplement if you eat no dairy.',
    mealHi: 'Dahi, paneer, doodh, ande - ya supplement agar dairy bilkul nahi khate.',
    indianEn:
        'A pure vegetarian diet almost always needs a B12 supplement. This is one of the few places where food genuinely is not enough.',
    indianHi:
        'Shuddh shakahari khaane mein lagbhag hamesha B12 supplement chahiye hota hai. Ye un gine-chune jagahon mein hai jahan khana sach mein kaafi nahi hai.',
  ),
  TtcNutrition(
    id: 'coq10',
    nutrientEn: 'CoQ10',
    nutrientHi: 'CoQ10',
    whyEn:
        'Studied for egg and sperm quality, particularly over thirty-five. Promising rather than proven.',
    whyHi:
        'Egg aur sperm quality ke liye study kiya gaya hai, khaaskar pentiis ke baad. Ummeed jagata hai, sabit nahi hua.',
    mealEn: 'Found in small amounts in nuts and whole grains.',
    mealHi: 'Meve aur sabut anaaj mein thodi matra mein milta hai.',
    indianEn:
        'This is a supplement question, not a food one - and one to ask your doctor rather than a chemist. Doses sold over the counter vary enormously.',
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
        'Fifteen minutes at a comfortable pace. Walking after a meal blunts the blood-sugar spike better than the same walk at any other time of day.',
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
        'Lie back, soles of the feet together, knees falling open, a cushion under each knee. Stay five minutes. It opens the hips and settles the nervous system - do not force the knees down.',
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
        'Squats, a loaded bag, resistance bands - anything that makes muscles work. Muscle improves insulin sensitivity, which matters a great deal in PCOS.',
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
        'A low lunge on each side, ninety seconds each. If you sit at a desk most of the day, this is the one your body has been asking for.',
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
        'Recovery is when the body actually adapts. A deliberate rest day is a decision, not a gap - and skipping rest is one of the few ways exercise starts working against you.',
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
        'Lie on your back with your legs resting up a wall for five minutes. It is not doing anything for conception - it is doing something for your evening, which is reason enough.',
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
        'Twenty minutes, both of you, no screens. The exercise is almost secondary - this is the easiest conversation you will have all week.',
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
        'Ten slow lifts, holding three seconds each, releasing completely between. Releasing fully matters as much as lifting - a permanently tight pelvic floor is not a strong one.',
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
        'Not a workout - a decision. Repeated small choices move the needle far more reliably than a gym membership you use in bursts.',
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
        'On hands and knees, arch and round the spine with the breath, ten times. Two minutes, and the lower back stops complaining.',
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
        'Morning light sets the daily rhythm the hormones run on - and it is the single easiest thing you can do for sleep tonight. Vitamin D is a bonus.',
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
        'Fifteen minutes of slow movement with the breath. Hot or very intense yoga is worth avoiding while trying - the heat is the reason, not the yoga.',
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
    textEn: 'How are you feeling today - honestly, not usefully?',
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
    textEn: 'Something someone said that you are still carrying.',
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
    textEn: 'What are these waiting days actually like?',
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
    textEn: 'What is one habit you have actually kept so far?',
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
    textEn: 'Write about the day you found out. You will want this later.',
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
