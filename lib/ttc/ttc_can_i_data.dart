// =============================================================================
//  TTC - "Can I...?"
// -----------------------------------------------------------------------------
//  The fastest way to settle an everyday worry, in the same shape the pregnancy
//  app uses: a verdict in a small colour language, then the short answer, then
//  why, then an Indian-context line.
//
//  The important difference from the pregnancy version: while TRYING, almost
//  everything is fine. Pregnancy answers are cautious because something is
//  already growing; here, most of these end in "yes". A safety checker that
//  says no to everything during a stage where nothing has happened yet is not
//  being careful - it is manufacturing anxiety in the one stage that already
//  has too much of it.
//
//  So the honest split below is deliberate: mostly `safe`, a few `moderate`,
//  and `avoid` reserved for the two things with genuinely clear evidence.
//
//  SEED CONTENT - see the header of ttc_daily_data.dart. Never a diagnosis;
//  every page ends with a disclaimer and anything clinical routes to a doctor.
// =============================================================================

/// The verdict, in the product's small calm colour language. Never a traffic
/// light - see ttcVerdictTint in the screen.
enum TtcVerdict { safe, moderate, avoid, askDoctor }

extension TtcVerdictCopy on TtcVerdict {
  String label(bool hi) {
    switch (this) {
      case TtcVerdict.safe:
        return hi ? 'Haan, theek hai' : 'Yes, this is fine';
      case TtcVerdict.moderate:
        return hi ? 'Thoda sa theek hai' : 'In moderation';
      case TtcVerdict.avoid:
        return hi ? 'Behtar hai na karein' : 'Better not';
      case TtcVerdict.askDoctor:
        return hi ? 'Doctor se poochhein' : 'Ask your doctor';
    }
  }
}

class TtcCanI {
  const TtcCanI({
    required this.id,
    required this.questionEn,
    required this.questionHi,
    required this.verdict,
    required this.shortEn,
    required this.shortHi,
    required this.whyEn,
    required this.whyHi,
    required this.indianEn,
    required this.indianHi,
    this.forPartner = false,
  });

  final String id;
  final String questionEn;
  final String questionHi;
  final TtcVerdict verdict;

  /// The answer in one line, above the fold.
  final String shortEn;
  final String shortHi;

  final String whyEn;
  final String whyHi;

  /// The India-specific line - what this actually means in an Indian home.
  final String indianEn;
  final String indianHi;

  /// True when the question is really about him.
  final bool forPartner;

  String question(bool hi) => hi ? questionHi : questionEn;
  String short(bool hi) => hi ? shortHi : shortEn;
  String why(bool hi) => hi ? whyHi : whyEn;
  String indian(bool hi) => hi ? indianHi : indianEn;
}

const List<TtcCanI> ttcCanI = [
  TtcCanI(
    id: 'chai',
    questionEn: 'Can I drink chai and coffee?',
    questionHi: 'Kya main chai aur coffee pi sakti hoon?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes - up to about 200mg of caffeine a day.',
    shortHi: 'Haan - roz lagbhag 200mg caffeine tak.',
    whyEn:
        'Very high caffeine intake has been linked to a longer time to conceive in some studies, though the evidence is not strong. 200mg is the limit most guidelines use while trying and during pregnancy, so keeping to it now means nothing has to change later.',
    whyHi:
        'Bahut zyada caffeine ka sambandh kuch studies mein conceive karne mein zyada waqt lagne se juda hai, halanki saboot mazboot nahi hain. Koshish ke dauraan aur pregnancy mein zyadatar guidelines 200mg ki hadd rakhti hain - abhi se usmein rehne ka matlab hai baad mein kuch badalna nahi padega.',
    indianEn:
        'Two to three cups of home-made chai, or about two filter coffees. What catches people out is the cola, green tea and dark chocolate nobody counts.',
    indianHi:
        'Ghar ki do-teen cup chai, ya lagbhag do filter coffee. Log cola, green tea aur dark chocolate ginna bhool jaate hain - wahi pakadta hai.',
  ),
  TtcCanI(
    id: 'alcohol',
    questionEn: 'Can I drink alcohol?',
    questionHi: 'Kya main sharab pi sakti hoon?',
    verdict: TtcVerdict.moderate,
    shortEn:
        'Occasionally, yes. Heavy drinking is a different question, and the answer there is no.',
    shortHi:
        'Kabhi-kabhaar, haan. Zyada peena alag baat hai, aur uska jawab nahi hai.',
    whyEn:
        'Heavy alcohol is consistently linked to disrupted ovulation and to lower sperm quality. The evidence on occasional social drinking while trying is genuinely mixed. Once pregnancy is confirmed the guidance becomes none at all - which is worth knowing, because you may be pregnant for two weeks before a test can tell you.',
    whyHi:
        'Zyada sharab, ovulation bigadne aur kam sperm quality se lagatar judi hai. Koshish ke dauraan kabhi-kabhaar peene par saboot sach mein mile-jule hain. Pregnancy confirm hone ke baad salaah bilkul na peene ki ho jaati hai - aur ye jaanna zaroori hai, kyunki test batane se do hafte pehle hi aap pregnant ho sakti hain.',
    indianEn:
        'The practical version most couples settle on: normal through the first half of the cycle, and nothing once the fertile window has passed.',
    indianHi:
        'Zyadatar couples jo practical tareeka apnate hain: cycle ke pehle aadhe hisse mein normal, aur fertile window guzarne ke baad kuch nahi.',
  ),
  TtcCanI(
    id: 'smoking',
    questionEn: 'Does smoking really matter?',
    questionHi: 'Kya smoking sach mein maayne rakhti hai?',
    verdict: TtcVerdict.avoid,
    shortEn: 'Yes. This is one of the two things with genuinely clear evidence.',
    shortHi: 'Haan. Ye un do cheezon mein hai jinke saboot sach mein saaf hain.',
    whyEn:
        'Smoking is linked to reduced fertility in both partners, to earlier menopause, and to a higher risk of miscarriage. There is no safe amount here and no grey area, which is unusual - most lifestyle advice in this space is much softer than this.',
    whyHi:
        'Smoking dono partners mein kam fertility, jaldi menopause aur zyada miscarriage ke khatre se judi hai. Yahan koi safe matra nahi hai aur koi grey area nahi - jo asaamaanya hai, kyunki is field ki zyadatar lifestyle salaah isse kahin narm hoti hai.',
    indianEn:
        'Passive smoking counts. If someone smokes indoors at home, that is part of this - and it is a conversation worth having even though it is an awkward one.',
    indianHi:
        'Passive smoking bhi ginti hai. Agar ghar ke andar koi smoke karta hai, toh wo bhi ismein hai - aur ye baat karne layak hai, chahe thodi awkward ho.',
  ),
  TtcCanI(
    id: 'painkillers',
    questionEn: 'Can I take painkillers for period cramps?',
    questionHi: 'Kya main period cramps ke liye painkiller le sakti hoon?',
    verdict: TtcVerdict.askDoctor,
    shortEn:
        'Paracetamol is generally the one doctors suggest. Ibuprofen around ovulation is worth asking about.',
    shortHi:
        'Aam taur par doctor paracetamol batate hain. Ovulation ke aas-paas ibuprofen ke baare mein poochh lena theek hai.',
    whyEn:
        'NSAIDs like ibuprofen can interfere with ovulation when taken regularly around mid-cycle. For period pain - which happens at the opposite end of the cycle - that is much less of a concern. This is exactly the kind of question worth two minutes with a doctor rather than an internet search.',
    whyHi:
        'Ibuprofen jaisi NSAIDs, agar cycle ke beech mein regular li jayein, toh ovulation mein rukawat daal sakti hain. Period ke dard ke liye - jo cycle ke doosre sire par hota hai - ye utni chinta ki baat nahi. Ye theek wahi sawaal hai jiske liye internet search se behtar hai doctor ke saath do minute.',
    indianEn:
        'Combination "period pain" tablets sold over the counter in India often contain an NSAID plus something else. Read the box, or take it to the chemist and ask what is in it.',
    indianHi:
        'India mein bina prescription bikne wali "period pain" ki combination goliyon mein aksar NSAID ke saath kuch aur bhi hota hai. Dabba padhein, ya chemist ko dikha kar poochhein ki usmein kya hai.',
  ),
  TtcCanI(
    id: 'hot_bath',
    questionEn: 'Can he take long hot baths?',
    questionHi: 'Kya wo lambe garam paani ke nahaane le sakte hain?',
    forPartner: true,
    verdict: TtcVerdict.moderate,
    shortEn: 'A normal bath is fine. Long, very hot ones and saunas are worth cutting.',
    shortHi: 'Normal nahaana theek hai. Lambe, bahut garam nahaane aur sauna chhodne layak hain.',
    whyEn:
        'Sperm production works best a couple of degrees below core body temperature, which is why the testes sit outside the body. Sustained heat works against that. The effect is temporary and reverses - but it reverses on the ninety-day cycle, not overnight.',
    whyHi:
        'Sperm banne ka kaam body ke core temperature se do degree kam par sabse accha hota hai - isiliye testes body ke bahar hote hain. Lagatar garmi iske khilaf jaati hai. Ye asar temporary hai aur wapas theek ho jaata hai - lekin nabbe din ke cycle par, raat bhar mein nahi.',
    indianEn:
        'The far more common version of this in Indian homes is not a hot bath - it is a laptop resting on the lap for four hours every evening.',
    indianHi:
        'Indian gharon mein iska zyada aam roop garam nahaana nahi hai - char ghante roz shaam ko god par rakha laptop hai.',
  ),
  TtcCanI(
    id: 'exercise',
    questionEn: 'Can I keep doing intense workouts?',
    questionHi: 'Kya main tez workout jaari rakh sakti hoon?',
    verdict: TtcVerdict.moderate,
    shortEn:
        'Moderate exercise helps. Very intense training, especially with under-eating, can stop ovulation.',
    shortHi:
        'Moderate exercise madad karti hai. Bahut tez training, khaaskar kam khaane ke saath, ovulation rok sakti hai.',
    whyEn:
        'Around thirty minutes most days supports hormone balance, insulin sensitivity and sleep, and helps notably in PCOS. The other end is real too: if cycles became irregular after a new training routine started, that is worth mentioning to a doctor rather than pushing through.',
    whyHi:
        'Zyadatar dino mein lagbhag tees minute, hormone balance, insulin sensitivity aur neend ko support karta hai, aur PCOS mein khaas madad karta hai. Doosra sira bhi asli hai: agar naye training routine ke baad cycles irregular ho gaye, toh use jhelte rehne ke bajaye doctor ko batana theek hai.',
    indianEn:
        'Hot yoga is the one worth pausing while trying - and the reason is the heat, not the yoga.',
    indianHi:
        'Koshish ke dauraan hot yoga rokne layak hai - aur wajah garmi hai, yoga nahi.',
  ),
  TtcCanI(
    id: 'hair_dye',
    questionEn: 'Can I colour my hair?',
    questionHi: 'Kya main baal colour kara sakti hoon?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. There is no good evidence that hair colour affects fertility.',
    shortHi: 'Haan. Aisa koi accha saboot nahi hai ki hair colour fertility par asar daalta hai.',
    whyEn:
        'Very little is absorbed through the scalp, and what is absorbed has not been shown to affect conception or early pregnancy. This is one of the most common worries and one of the least supported.',
    whyHi:
        'Scalp se bahut kam absorb hota hai, aur jo hota hai uska conception ya shuruaati pregnancy par asar dikhaya nahi gaya hai. Ye sabse aam chinta mein se ek hai aur sabse kam saboot wali.',
    indianEn:
        'Henna is fine too. The thing worth checking is that a "natural" henna is actually only henna - some are mixed with PPD, which is a skin-reaction question rather than a fertility one.',
    indianHi:
        'Mehndi bhi theek hai. Dekhne layak baat ye hai ki "natural" mehndi sach mein sirf mehndi ho - kuch mein PPD milaya jaata hai, jo skin reaction ka sawaal hai, fertility ka nahi.',
  ),
  TtcCanI(
    id: 'travel',
    questionEn: 'Can we travel during the fertile window?',
    questionHi: 'Kya hum fertile window mein safar kar sakte hain?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. Flying, long drives and altitude do not affect conception.',
    shortHi: 'Haan. Flight, lambi drive aur unchai, conception par asar nahi daalte.',
    whyEn:
        'Nothing about travel makes conception less likely. Couples sometimes plan whole months around being in the same city for a particular week - which is worth doing if it is easy, and not worth reorganising your life over, because the window is six days wide.',
    whyHi:
        'Safar ki koi baat conception ko kam nahi karti. Couples kabhi-kabhi poora mahina isi hisaab se plan karte hain ki khaas hafte mein ek hi shehar mein hon - agar aasaan ho toh theek hai, lekin uske liye zindagi badalna zaroori nahi, kyunki window chhe din ki hoti hai.',
    indianEn:
        'If a wedding or a festival falls in the middle of it, go. A month you enjoyed is not a month you wasted.',
    indianHi:
        'Agar beech mein koi shaadi ya tyohaar aa jaye, toh jaayein. Jo mahina achha guzra, wo barbaad nahi hua.',
  ),
  TtcCanI(
    id: 'papaya',
    questionEn: 'Should I avoid papaya and pineapple?',
    questionHi: 'Kya mujhe papita aur ananas se bachna chahiye?',
    verdict: TtcVerdict.safe,
    shortEn: 'No. Ripe fruit is fine, and neither prevents nor causes conception.',
    shortHi: 'Nahi. Paka phal theek hai, aur na ye conception rokta hai na karata hai.',
    whyEn:
        'The concern comes from unripe papaya, which contains latex that has been studied at doses far beyond anything anyone eats. Ripe papaya is ordinary fruit. Pineapple appears in the opposite myth - that eating the core helps implantation - and there is no evidence for that either.',
    whyHi:
        'Ye chinta kacche papite se aati hai, jismein latex hota hai - aur uski study un matraon par hui hai jo koi khaata hi nahi. Paka papita aam phal hai. Ananas ulte myth mein aata hai - ki uska core khaane se implantation mein madad milti hai - aur uska bhi koi saboot nahi.',
    indianEn:
        'Both the "avoid papaya" and the "eat pineapple core" advice circulate widely in Indian family groups. Neither has anything behind it.',
    indianHi:
        'Indian family groups mein "papita mat khao" aur "ananas ka core khao" - dono khoob ghoomti hain. Dono ke peechhe kuch nahi hai.',
  ),
  TtcCanI(
    id: 'xray',
    questionEn: 'Can I have an X-ray or a dental procedure?',
    questionHi: 'Kya main X-ray ya dental procedure karwa sakti hoon?',
    verdict: TtcVerdict.askDoctor,
    shortEn:
        'Usually yes - and dental work is better done now than during pregnancy.',
    shortHi:
        'Aam taur par haan - aur dental kaam pregnancy ke dauraan se abhi karwa lena behtar hai.',
    whyEn:
        'Diagnostic X-rays involve very low doses, and dental X-rays are among the lowest of all. Tell whoever is doing it that you are trying to conceive so they can time it and shield you appropriately. Gum disease is linked to pregnancy complications, so a dental check-up before rather than during is genuinely a good idea.',
    whyHi:
        'Diagnostic X-ray mein bahut kam dose hota hai, aur dental X-ray toh sabse kam mein se hai. Jo bhi kar raha hai use bata dein ki aap conceive karne ki koshish kar rahi hain, taaki wo samay aur shielding theek rakh sake. Mashuda ki bimari pregnancy ki complications se judi hai, isliye dental check-up pehle karwa lena sach mein achhi baat hai.',
    indianEn:
        'Say it out loud at the reception, not just in the chair. It changes when in your cycle they will schedule it.',
    indianHi:
        'Ye reception par bhi keh dein, sirf chair par nahi. Isse tay hota hai ki cycle ke kis hisse mein appointment denge.',
  ),
  TtcCanI(
    id: 'sex_frequency',
    questionEn: 'Can we have sex too often?',
    questionHi: 'Kya hum zyada baar sex kar sakte hain?',
    verdict: TtcVerdict.safe,
    shortEn: 'No such thing. Every day or every other day across the window is plenty.',
    shortHi: 'Aisa kuch nahi hota. Window mein roz ya ek din chhod kar kaafi hai.',
    whyEn:
        'Daily does not meaningfully reduce sperm quality in men with normal counts. The old advice to "save up" is not supported - longer abstinence raises the count but lowers movement, and the two cancel out.',
    whyHi:
        'Normal count wale mardon mein roz karne se sperm quality mein khaas kami nahi aati. "Bacha kar rakho" wali purani salaah ka saboot nahi hai - zyada gap count badhata hai lekin chaal kam karta hai, aur dono ek doosre ko kaat dete hain.',
    indianEn:
        'The real limit is not biological. It is that turning it into a schedule is what makes couples stop enjoying it - which is the cost worth watching.',
    indianHi:
        'Asli hadd biological nahi hai. Asli baat ye hai ki ise schedule bana dene se hi couples ka man hatta hai - aur yahi wo nuksaan hai jispar nazar rakhni chahiye.',
  ),
  TtcCanI(
    id: 'ayurvedic',
    questionEn: 'Can I take ayurvedic fertility supplements?',
    questionHi: 'Kya main ayurvedic fertility supplements le sakti hoon?',
    verdict: TtcVerdict.askDoctor,
    shortEn: 'Tell your doctor exactly what you are taking, including these.',
    shortHi: 'Doctor ko theek-theek batayein ki aap kya le rahi hain, ye bhi.',
    whyEn:
        'Some traditional preparations are well tolerated; some interact with thyroid or diabetes medication, and a few sold as fertility aids have been found to contain heavy metals. The problem is rarely the tradition - it is that an unlabelled mixture cannot be checked against anything else you take.',
    whyHi:
        'Kuch paramparik cheezein theek se sah li jaati hain; kuch thyroid ya diabetes ki dawai se takraati hain, aur fertility ke naam par biki kuch cheezon mein bhaari dhaatuein mili hain. Dikkat parampara mein shayad hi hoti hai - dikkat ye hai ki bina label wale mishran ko aapki baaki dawaiyon ke saath jaancha nahi ja sakta.',
    indianEn:
        'Take the actual packet to your appointment. "Some ayurvedic tablets" is not something a doctor can check; a label is.',
    indianHi:
        'Appointment par asli packet le jaayein. "Kuch ayurvedic goliyan" doctor check nahi kar sakte; label kar sakte hain.',
  ),
];

TtcCanI? ttcCanIById(String id) {
  for (final q in ttcCanI) {
    if (q.id == id) return q;
  }
  return null;
}
