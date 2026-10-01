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
      // ⚠️ ONE MEANING FOR THIS WORD (tool rebuild, 2026-09-27, night).
      // "In moderation" sat on chai (a number: 200mg), alcohol ("now and
      // then"), hot baths and workouts (no number at all), so the same pill
      // meant a dose on one card and a kind of habit on the next. It now says
      // what all four have in common, and every one of them carries its limit
      // right beside the word (`TtcCanI.limit`), a number where there is one.
      // No verdict moved: the enum value and every answer are unchanged.
      // Kept for revert: 'In moderation'.
      case TtcVerdict.moderate:
        return hi ? 'Thoda sa theek hai' : 'Yes, with a limit';
      // ⚠️ A CLEAR NO (launch walk, 2026-09-28, the user's call). Smoking is
      // the only card on this verdict and the one with the clearest evidence;
      // an earlier audit (A-37) found "Better not" too soft for it. What to
      // Expect's own piece says plainly that quitting helps. Warm, not a
      // scold: "best to stop" rather than an order. Kept for revert:
      // 'Better not'.
      case TtcVerdict.avoid:
        return hi ? 'Behtar hai na karein' : 'No, best to stop';
      case TtcVerdict.askDoctor:
        return hi ? 'Doctor se poochhein' : 'Ask your doctor';
    }
  }
}

class TtcCanI {
  const TtcCanI({
    required this.id,
    required this.questionEn,
    this.questionHi,
    required this.verdict,
    required this.shortEn,
    this.shortHi,
    required this.whyEn,
    this.whyHi,
    required this.indianEn,
    this.indianHi,
    this.forPartner = false,
    this.limitEn,
    this.limitHi,
  });

  /// The limit a "Yes, with a limit" answer sets, said beside the verdict so
  /// the word means one thing on every card (2026-09-27, night). A number
  /// where the answer has one. Only on `moderate` answers; every limit is
  /// the answer's own short line, shortened, never a new fact. English on
  /// both sides where no Hindi was written (new copy is English).
  final String? limitEn;
  final String? limitHi;

  String? limit(bool hi) => hi ? (limitHi ?? limitEn) : limitEn;

  final String id;
  final String questionEn;
  final String? questionHi;
  final TtcVerdict verdict;

  /// The answer in one line, above the fold.
  final String shortEn;
  final String? shortHi;

  final String whyEn;
  final String? whyHi;

  /// The India-specific line - what this actually means in an Indian home.
  final String indianEn;
  final String? indianHi;

  /// True when the question is really about him.
  final bool forPartner;

  // The Hindi side is optional since 2026-09-30: the questions added then are
  // English only (CLAUDE.md, "New work is English") and fall back to it. The
  // first twelve keep their Hindi. Kept for revert: `hi ? questionHi : questionEn`.
  String question(bool hi) => hi ? (questionHi ?? questionEn) : questionEn;
  String short(bool hi) => hi ? (shortHi ?? shortEn) : shortEn;
  String why(bool hi) => hi ? (whyHi ?? whyEn) : whyEn;
  String indian(bool hi) => hi ? (indianHi ?? indianEn) : indianEn;
}

const List<TtcCanI> ttcCanI = [
  TtcCanI(
    id: 'chai',
    limitEn: 'about 200mg of caffeine a day',
    limitHi: 'about 200mg of caffeine a day',
    questionEn: 'Can I drink chai and coffee?',
    questionHi: 'Kya main chai aur coffee pi sakti hoon?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, up to about 200mg of caffeine a day.',
    shortHi: 'Haan - roz lagbhag 200mg caffeine tak.',
    whyEn:
        "Some studies link very high caffeine to taking longer to conceive, though the evidence isn't strong. Most guidelines use 200mg as the limit while trying and during pregnancy. Keeping to it now means nothing has to change later.",
    whyHi:
        'Bahut zyada caffeine ka sambandh kuch studies mein conceive karne mein zyada waqt lagne se juda hai, halanki saboot mazboot nahi hain. Koshish ke dauraan aur pregnancy mein zyadatar guidelines 200mg ki hadd rakhti hain - abhi se usmein rehne ka matlab hai baad mein kuch badalna nahi padega.',
    indianEn:
        "That's two to three cups of home-made chai, or about two filter coffees. What people forget to count is cola, green tea and dark chocolate.",
    indianHi:
        'Ghar ki do-teen cup chai, ya lagbhag do filter coffee. Log cola, green tea aur dark chocolate ginna bhool jaate hain - wahi pakadta hai.',
  ),
  TtcCanI(
    id: 'alcohol',
    limitEn: 'now and then, never heavy',
    limitHi: 'now and then, never heavy',
    questionEn: 'Can I drink alcohol?',
    questionHi: 'Kya main sharab pi sakti hoon?',
    verdict: TtcVerdict.moderate,
    shortEn:
        'Now and then, yes. Heavy drinking is a different question, and there the answer is no.',
    shortHi:
        'Kabhi-kabhaar, haan. Zyada peena alag baat hai, aur uska jawab nahi hai.',
    whyEn:
        "Heavy drinking is linked again and again to upset ovulation and to poorer sperm quality. The evidence on an occasional social drink while trying is mixed. Once pregnancy is confirmed, the advice is no alcohol at all. That's worth knowing, because you may be pregnant for two weeks before a test can tell you.",
    whyHi:
        'Zyada sharab, ovulation bigadne aur kam sperm quality se lagatar judi hai. Koshish ke dauraan kabhi-kabhaar peene par saboot sach mein mile-jule hain. Pregnancy confirm hone ke baad salaah bilkul na peene ki ho jaati hai - aur ye jaanna zaroori hai, kyunki test batane se do hafte pehle hi aap pregnant ho sakti hain.',
    indianEn:
        'What most couples end up doing: drinking as normal in the first half of the cycle, and not at all once the fertile window has passed.',
    indianHi:
        'Zyadatar couples jo practical tareeka apnate hain: cycle ke pehle aadhe hisse mein normal, aur fertile window guzarne ke baad kuch nahi.',
  ),
  TtcCanI(
    id: 'smoking',
    // ⚠️ THE QUESTION IS ASKED THE WAY THE CHIP ANSWERS (launch sanity T7,
    // 2026-09-28). The verdict chip is written for "Can I ...?", so a
    // question asked the other way round ("Does it matter?") put "Better
    // not" above an answer that began "Yes." Same meaning, same verdict:
    // smoking is still the clear no. `test/ttc_can_i_polarity_test.dart`
    // holds every entry to it.
    // Kept for revert (2026-09-28):
    //   questionEn: 'Does smoking really matter?',
    //   questionHi: 'Kya smoking sach mein maayne rakhti hai?',
    //   shortEn: "Yes. It's one of the two things where the evidence is clear.",
    //   shortHi: 'Haan. Ye un do cheezon mein hai jinke saboot sach mein saaf hain.',
    questionEn: 'Can I keep smoking while we try?',
    questionHi: 'Kya main koshish ke dauraan smoking jaari rakh sakti hoon?',
    verdict: TtcVerdict.avoid,
    shortEn: "No. It's one of the two things where the evidence is clear.",
    shortHi: 'Nahi. Ye un do cheezon mein hai jinke saboot sach mein saaf hain.',
    whyEn:
        "Smoking is linked to lower fertility in both partners, to earlier menopause and to a higher risk of miscarriage. There's no safe amount here and no grey area. That's unusual, because most lifestyle advice on this topic is much less firm.",
    whyHi:
        'Smoking dono partners mein kam fertility, jaldi menopause aur zyada miscarriage ke khatre se judi hai. Yahan koi safe matra nahi hai aur koi grey area nahi - jo asaamaanya hai, kyunki is field ki zyadatar lifestyle salaah isse kahin narm hoti hai.',
    indianEn:
        "Passive smoking counts too. If someone smokes indoors at home, that's part of this. It's worth talking about, even though it's an awkward talk.",
    indianHi:
        'Passive smoking bhi ginti hai. Agar ghar ke andar koi smoke karta hai, toh wo bhi ismein hai - aur ye baat karne layak hai, chahe thodi awkward ho.',
  ),
  TtcCanI(
    id: 'painkillers',
    questionEn: 'Can I take painkillers for period cramps?',
    questionHi: 'Kya main period cramps ke liye painkiller le sakti hoon?',
    verdict: TtcVerdict.askDoctor,
    shortEn:
        'Doctors usually suggest paracetamol. If you take ibuprofen around ovulation, ask about it.',
    shortHi:
        'Aam taur par doctor paracetamol batate hain. Ovulation ke aas-paas ibuprofen ke baare mein poochh lena theek hai.',
    whyEn:
        "NSAIDs, painkillers like ibuprofen, can get in the way of ovulation if you take them regularly in the middle of your cycle. Period pain comes at the other end of the cycle, so it's much less of a worry then. This is just the kind of question worth two minutes with a doctor, not an internet search.",
    whyHi:
        'Ibuprofen jaisi NSAIDs, agar cycle ke beech mein regular li jayein, toh ovulation mein rukawat daal sakti hain. Period ke dard ke liye - jo cycle ke doosre sire par hota hai - ye utni chinta ki baat nahi. Ye theek wahi sawaal hai jiske liye internet search se behtar hai doctor ke saath do minute.',
    indianEn:
        'In India, "period pain" tablets sold without a prescription often mix an NSAID with something else. Read the box, or show it to the chemist and ask what\'s in it.',
    indianHi:
        'India mein bina prescription bikne wali "period pain" ki combination goliyon mein aksar NSAID ke saath kuch aur bhi hota hai. Dabba padhein, ya chemist ko dikha kar poochhein ki usmein kya hai.',
  ),
  TtcCanI(
    id: 'hot_bath',
    limitEn: 'normal baths, not long very hot ones or saunas',
    limitHi: 'normal baths, not long very hot ones or saunas',
    // Launch sanity T7 audit (2026-09-28): "Can he take LONG hot baths?"
    // answered "Yes, with a limit: ... not long very hot ones" said yes and
    // no to the same thing. The question now names the habit, and the limit
    // carries the "not long, not very hot" part. Answer unchanged.
    // Kept for revert (2026-09-28):
    //   questionEn: 'Can he take long hot baths?',
    //   questionHi: 'Kya wo lambe garam paani ke nahaane le sakte hain?',
    questionEn: 'Can he take hot baths?',
    questionHi: 'Kya wo garam paani se nahaa sakte hain?',
    forPartner: true,
    verdict: TtcVerdict.moderate,
    shortEn: 'A normal bath is fine. Long, very hot baths and saunas are worth cutting.',
    shortHi: 'Normal nahaana theek hai. Lambe, bahut garam nahaane aur sauna chhodne layak hain.',
    whyEn:
        "Sperm are made best a couple of degrees below the body's core temperature. That's why the testes sit outside the body. Heat that goes on for a long time works against this. The effect is temporary and wears off, but it takes the ninety-day cycle, not one night.",
    whyHi:
        'Sperm banne ka kaam body ke core temperature se do degree kam par sabse accha hota hai - isiliye testes body ke bahar hote hain. Lagatar garmi iske khilaf jaati hai. Ye asar temporary hai aur wapas theek ho jaata hai - lekin nabbe din ke cycle par, raat bhar mein nahi.',
    indianEn:
        "In Indian homes, the far more common version of this isn't a hot bath. It's a laptop resting on the lap for four hours every evening.",
    indianHi:
        'Indian gharon mein iska zyada aam roop garam nahaana nahi hai - char ghante roz shaam ko god par rakha laptop hai.',
  ),
  TtcCanI(
    id: 'exercise',
    limitEn: 'moderate exercise, not very hard training',
    limitHi: 'moderate exercise, not very hard training',
    // Launch sanity T7 audit (2026-09-28): "Can I keep doing INTENSE
    // workouts?" answered "Yes, with a limit: ... not very hard training"
    // said yes and no to the same thing. The question now names the habit
    // and the limit keeps it moderate. Answer unchanged.
    // Kept for revert (2026-09-28):
    //   questionEn: 'Can I keep doing intense workouts?',
    //   questionHi: 'Kya main tez workout jaari rakh sakti hoon?',
    questionEn: 'Can I keep up my workouts?',
    questionHi: 'Kya main apna workout jaari rakh sakti hoon?',
    verdict: TtcVerdict.moderate,
    shortEn:
        "Moderate exercise helps. Very hard training, especially if you're not eating enough, can stop ovulation.",
    shortHi:
        'Moderate exercise madad karti hai. Bahut tez training, khaaskar kam khaane ke saath, ovulation rok sakti hai.',
    whyEn:
        'About thirty minutes on most days helps hormone balance, insulin sensitivity and sleep, and helps a lot with PCOS. Too much is a real problem too. If your cycles became irregular after you started a new training routine, tell a doctor instead of pushing through.',
    whyHi:
        'Zyadatar dino mein lagbhag tees minute, hormone balance, insulin sensitivity aur neend ko support karta hai, aur PCOS mein khaas madad karta hai. Doosra sira bhi asli hai: agar naye training routine ke baad cycles irregular ho gaye, toh use jhelte rehne ke bajaye doctor ko batana theek hai.',
    indianEn:
        'Hot yoga is the one worth pausing while trying. The reason is the heat, not the yoga.',
    indianHi:
        'Koshish ke dauraan hot yoga rokne layak hai - aur wajah garmi hai, yoga nahi.',
  ),
  TtcCanI(
    id: 'hair_dye',
    questionEn: 'Can I colour my hair?',
    questionHi: 'Kya main baal colour kara sakti hoon?',
    verdict: TtcVerdict.safe,
    shortEn: "Yes. There's no good evidence that hair colour affects fertility.",
    shortHi: 'Haan. Aisa koi accha saboot nahi hai ki hair colour fertility par asar daalta hai.',
    whyEn:
        "Very little passes through the scalp, and what does hasn't been shown to affect conception or early pregnancy. It's one of the most common worries, with some of the least evidence behind it.",
    whyHi:
        'Scalp se bahut kam absorb hota hai, aur jo hota hai uska conception ya shuruaati pregnancy par asar dikhaya nahi gaya hai. Ye sabse aam chinta mein se ek hai aur sabse kam saboot wali.',
    indianEn:
        'Henna is fine too. Just check that a "natural" henna is only henna. Some are mixed with PPD, a dye that can cause skin reactions. That\'s a skin question, not a fertility one.',
    indianHi:
        'Mehndi bhi theek hai. Dekhne layak baat ye hai ki "natural" mehndi sach mein sirf mehndi ho - kuch mein PPD milaya jaata hai, jo skin reaction ka sawaal hai, fertility ka nahi.',
  ),
  TtcCanI(
    id: 'travel',
    questionEn: 'Can we travel during the fertile window?',
    questionHi: 'Kya hum fertile window mein safar kar sakte hain?',
    verdict: TtcVerdict.safe,
    shortEn: "Yes. Flying, long drives and high altitude don't affect conception.",
    shortHi: 'Haan. Flight, lambi drive aur unchai, conception par asar nahi daalte.',
    whyEn:
        "Nothing about travel makes conception less likely. Some couples plan whole months around being in the same city for one week. That's worth doing if it's easy. It isn't worth rearranging your life for, because the window is six days wide.",
    whyHi:
        'Safar ki koi baat conception ko kam nahi karti. Couples kabhi-kabhi poora mahina isi hisaab se plan karte hain ki khaas hafte mein ek hi shehar mein hon - agar aasaan ho toh theek hai, lekin uske liye zindagi badalna zaroori nahi, kyunki window chhe din ki hoti hai.',
    indianEn:
        "If a wedding or a festival falls in the middle of it, go. A month you enjoyed isn't a wasted month.",
    indianHi:
        'Agar beech mein koi shaadi ya tyohaar aa jaye, toh jaayein. Jo mahina achha guzra, wo barbaad nahi hua.',
  ),
  TtcCanI(
    id: 'papaya',
    // Launch sanity T7 (2026-09-28): "Should I avoid ...?" under a chip that
    // says "Yes, this is fine" read as "yes, avoid it" on a food-safety
    // card. Asked as "Can I eat ...?" the chip and the answer both say yes;
    // the answer itself is unchanged (ripe fruit is fine).
    // Kept for revert (2026-09-28):
    //   questionEn: 'Should I avoid papaya and pineapple?',
    //   questionHi: 'Kya mujhe papita aur ananas se bachna chahiye?',
    //   shortEn: "No. Ripe fruit is fine. It doesn't stop conception, and it doesn't cause it.",
    //   shortHi: 'Nahi. Paka phal theek hai, aur na ye conception rokta hai na karata hai.',
    questionEn: 'Can I eat papaya and pineapple?',
    questionHi: 'Kya main papita aur ananas kha sakti hoon?',
    verdict: TtcVerdict.safe,
    shortEn: "Yes. Ripe fruit is fine. It doesn't stop conception, and it doesn't cause it.",
    shortHi: 'Haan. Paka phal theek hai, aur na ye conception rokta hai na karata hai.',
    whyEn:
        "The worry comes from unripe papaya. It contains latex, which has been studied at doses far higher than anyone eats. Ripe papaya is ordinary fruit. Pineapple comes up in the opposite myth, that eating the core helps implantation. There's no evidence for that either.",
    whyHi:
        'Ye chinta kacche papite se aati hai, jismein latex hota hai - aur uski study un matraon par hui hai jo koi khaata hi nahi. Paka papita aam phal hai. Ananas ulte myth mein aata hai - ki uska core khaane se implantation mein madad milti hai - aur uska bhi koi saboot nahi.',
    indianEn:
        'Both "avoid papaya" and "eat the pineapple core" get shared a lot in Indian family groups. Neither has anything behind it.',
    indianHi:
        'Indian family groups mein "papita mat khao" aur "ananas ka core khao" - dono khoob ghoomti hain. Dono ke peechhe kuch nahi hai.',
  ),
  TtcCanI(
    id: 'xray',
    questionEn: 'Can I have an X-ray or a dental procedure?',
    questionHi: 'Kya main X-ray ya dental procedure karwa sakti hoon?',
    verdict: TtcVerdict.askDoctor,
    shortEn:
        'Usually yes. And dental work is better done now than during pregnancy.',
    shortHi:
        'Aam taur par haan - aur dental kaam pregnancy ke dauraan se abhi karwa lena behtar hai.',
    whyEn:
        "X-rays taken to check for a problem use very low doses, and dental X-rays are among the lowest of all. Tell whoever is doing it that you're trying to conceive, so they can time it and shield you properly. Gum disease is linked to problems in pregnancy, so a dental check-up before, not during, is a good idea.",
    whyHi:
        'Diagnostic X-ray mein bahut kam dose hota hai, aur dental X-ray toh sabse kam mein se hai. Jo bhi kar raha hai use bata dein ki aap conceive karne ki koshish kar rahi hain, taaki wo samay aur shielding theek rakh sake. Mashuda ki bimari pregnancy ki complications se judi hai, isliye dental check-up pehle karwa lena sach mein achhi baat hai.',
    indianEn:
        "Say it at the front desk too, not just in the chair. It changes when in your cycle they'll book it.",
    indianHi:
        'Ye reception par bhi keh dein, sirf chair par nahi. Isse tay hota hai ki cycle ke kis hisse mein appointment denge.',
  ),
  TtcCanI(
    id: 'sex_frequency',
    // Launch sanity T7 (2026-09-28): "Can we have sex too often?" asks
    // whether there is a harm, so "Yes, this is fine" read as "yes, you can
    // overdo it". Asked as the permission it really is; the answer is the
    // same (there is no such thing as too often).
    // Kept for revert (2026-09-28):
    //   questionEn: 'Can we have sex too often?',
    //   questionHi: 'Kya hum zyada baar sex kar sakte hain?',
    //   shortEn: 'No such thing. Every day or every other day across the window is plenty.',
    //   shortHi: 'Aisa kuch nahi hota. Window mein roz ya ek din chhod kar kaafi hai.',
    questionEn: 'Can we have sex every day?',
    questionHi: 'Kya hum roz sex kar sakte hain?',
    verdict: TtcVerdict.safe,
    shortEn:
        "Yes. There's no such thing as too often. Every day or every other day across the window is plenty.",
    shortHi:
        'Haan. Zyada jaisa kuch nahi hota. Window mein roz ya ek din chhod kar kaafi hai.',
    whyEn:
        'Having sex daily doesn\'t really lower sperm quality in men with normal counts. The old advice to "save it up" isn\'t backed by evidence. Waiting longer raises the count but lowers how well sperm move, and the two cancel out.',
    whyHi:
        'Normal count wale mardon mein roz karne se sperm quality mein khaas kami nahi aati. "Bacha kar rakho" wali purani salaah ka saboot nahi hai - zyada gap count badhata hai lekin chaal kam karta hai, aur dono ek doosre ko kaat dete hain.',
    indianEn:
        "The real limit isn't in the body. Turning sex into a timetable is what makes couples stop enjoying it. That's the cost to watch for.",
    indianHi:
        'Asli hadd biological nahi hai. Asli baat ye hai ki ise schedule bana dene se hi couples ka man hatta hai - aur yahi wo nuksaan hai jispar nazar rakhni chahiye.',
  ),
  TtcCanI(
    id: 'ayurvedic',
    questionEn: 'Can I take ayurvedic fertility supplements?',
    questionHi: 'Kya main ayurvedic fertility supplements le sakti hoon?',
    verdict: TtcVerdict.askDoctor,
    shortEn: "Tell your doctor exactly what you're taking, including these.",
    shortHi: 'Doctor ko theek-theek batayein ki aap kya le rahi hain, ye bhi.',
    whyEn:
        "Some traditional remedies suit people well. Some clash with thyroid or diabetes medicines, and a few sold as fertility aids have been found to contain heavy metals. The problem is rarely the tradition. It's that a mixture with no label can't be checked against anything else you take.",
    whyHi:
        'Kuch paramparik cheezein theek se sah li jaati hain; kuch thyroid ya diabetes ki dawai se takraati hain, aur fertility ke naam par biki kuch cheezon mein bhaari dhaatuein mili hain. Dikkat parampara mein shayad hi hoti hai - dikkat ye hai ki bina label wale mishran ko aapki baaki dawaiyon ke saath jaancha nahi ja sakta.',
    indianEn:
        'Take the real packet to your appointment. A doctor can\'t check "some ayurvedic tablets", but they can check a label.',
    indianHi:
        'Appointment par asli packet le jaayein. "Kuch ayurvedic goliyan" doctor check nahi kar sakte; label kar sakte hain.',
  ),
  // ===========================================================================
  //  2026-09-30: thirty more (the user: "why do we have so few questions in
  //  Can I?"). Written to docs/TTC-VOICE.md, English only (CLAUDE.md, "New work
  //  is English"; the Hindi side falls back to it). Verdicts stay calm: mostly
  //  yes, "No" only where the evidence is clear (vaping, beside smoking), and
  //  "Ask your doctor" where a doctor must decide (isotretinoin, testosterone,
  //  regular medicines). Each is general guidance, never a diagnosis.
  // ===========================================================================

  // ---- Food and drink ---------------------------------------------------------
  TtcCanI(
    id: 'fish',
    limitEn: 'two or three portions a week, low-mercury fish',
    questionEn: 'Can I eat fish while trying?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, two or three portions a week of low-mercury fish.',
    whyEn:
        "Fish gives you protein, iodine and omega-3 fats, which are good for you and for an early pregnancy. The one thing to watch is mercury, which builds up in large fish that eat other fish. Choosing smaller fish keeps the benefit without the mercury.",
    indianEn:
        'Rohu, pomfret, sardines (mathi), mackerel (bangda) and prawns are all good choices. Keep large surmai (king mackerel) and shark to now and then.',
  ),
  TtcCanI(
    id: 'green_tea',
    limitEn: 'counts towards about 200mg of caffeine a day',
    questionEn: 'Can I drink green tea?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes. It has caffeine too, so count it with your chai and coffee.',
    whyEn:
        "A cup of green tea has less caffeine than coffee, but it still adds up. Two or three cups a day is fine alongside a little chai. Very large amounts of green tea extract, in capsules, are a different thing and are best left out while you try.",
    indianEn:
        "Many people switch to green tea thinking it's caffeine-free. It isn't, so keep your total for the day under about 200mg.",
  ),
  TtcCanI(
    id: 'energy_drinks',
    limitEn: 'one can now and then, counted with your caffeine',
    questionEn: 'Can I have energy drinks?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, now and then. One can can use up half your caffeine for the day.',
    whyEn:
        'Energy drinks often hold 80 to 160mg of caffeine a can, plus a lot of sugar. One now and then is fine. Having them every day makes it easy to go over the 200mg most guidelines suggest while trying.',
    indianEn:
        'Check the label: the caffeine is usually printed in mg per can. Colas count too, at about 40mg a can.',
  ),
  TtcCanI(
    id: 'spicy_food',
    questionEn: 'Can I eat spicy food?',
    verdict: TtcVerdict.safe,
    shortEn: "Yes. Spicy food doesn't affect your chances of conceiving.",
    whyEn:
        "There's no evidence that chilli, masala or spicy food changes ovulation, sperm or implantation. If it gives you heartburn or an upset stomach, that's a comfort question, not a fertility one.",
    indianEn:
        "You don't need to cut out pickles, chutneys or your usual masala. Eat the way you enjoy, with plenty of vegetables and dal alongside.",
  ),
  TtcCanI(
    id: 'fasting',
    limitEn: 'short fasts, eating well on the other days',
    questionEn: 'Can I keep my religious fasts?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, short fasts are fine if you eat well on the other days.',
    whyEn:
        "A day's fast now and then doesn't stop you conceiving. What matters is your overall eating over weeks: enough food, protein and folic acid. Long or very strict fasts can unsettle your cycle, and during treatment your clinic may ask you to eat normally.",
    indianEn:
        'Navratri, Ramadan, ekadashi or a weekly vrat are all fine for most people. Drink enough water, break the fast with a proper meal, and keep taking folic acid.',
  ),
  TtcCanI(
    id: 'dieting',
    limitEn: 'slow and steady, no crash diets',
    questionEn: 'Can I diet to lose weight while trying?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, gently. Slow weight loss can help, but crash diets can upset your cycle.',
    whyEn:
        "If you carry extra weight, losing even a small amount can help ovulation. Very low-calorie or fad diets can have the opposite effect and stop you getting enough of what a pregnancy needs. About half a kilo to a kilo a week is a steady pace.",
    indianEn:
        'Smaller portions of rice and roti, more dal, vegetables and curd, and a daily walk work better than skipping meals. A dietitian can help if you want a plan.',
  ),
  TtcCanI(
    id: 'herbal_tea',
    limitEn: 'ordinary teas in normal amounts',
    questionEn: 'Can I drink herbal teas?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, ordinary ones like tulsi, ginger or mint, in normal amounts.',
    whyEn:
        "Everyday herbal teas are fine a cup or two a day. Strong herbal mixtures sold for fertility or cleansing are different: their contents and doses aren't tested, and some herbs aren't known to be safe in early pregnancy.",
    indianEn:
        'Tulsi, adrak, saunf or pudina tea is fine. Ask your doctor before a kadha or blend taken every day for weeks.',
  ),
  TtcCanI(
    id: 'raw_milk',
    questionEn: 'Can I drink unboiled milk?',
    verdict: TtcVerdict.moderate,
    limitEn: 'boil it first',
    shortEn: 'Yes, once it is boiled. Raw milk can carry germs that matter in early pregnancy.',
    whyEn:
        "Unboiled milk and cheese made from it can carry listeria, an infection that is rare but serious in pregnancy. You may be pregnant for a couple of weeks before you know, so it's worth boiling milk from now on.",
    indianEn:
        'Packet milk is pasteurised and fine. Milk straight from a dairy or a doodhwala should be boiled, and so should paneer made from it.',
  ),

  // ---- Body and habits ----------------------------------------------------------
  TtcCanI(
    id: 'lubricant',
    limitEn: 'a sperm-friendly one, or none',
    questionEn: 'Can I use lubricant?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, but choose a sperm-friendly one. Many regular lubes slow sperm down.',
    whyEn:
        "Most everyday lubricants, and saliva, can make it harder for sperm to swim. Sperm-friendly lubricants are made to match the body's own fluid. If you need one, it's much better than sex that hurts.",
    indianEn:
        'Look for "sperm-friendly" or "fertility-friendly" on the pack at a chemist or online. A little plain coconut oil is another option many couples use.',
  ),
  TtcCanI(
    id: 'get_up_after',
    questionEn: 'Can I get up straight after sex?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. Getting up straight away does not wash anything away.',
    whyEn:
        'Sperm reach the cervix within minutes. Lying still with your legs up has never been shown to make pregnancy more likely. Stay lying down if you like it, and get up if you need to.',
    indianEn:
        "Going to the bathroom afterwards is fine too. It's a common worry, and there's no need for it.",
  ),
  TtcCanI(
    id: 'sauna',
    limitEn: 'short sessions, and not in the two-week wait',
    questionEn: 'Can I use a sauna or steam room?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, for short sessions. In the two-week wait, skip the very hot ones.',
    whyEn:
        "A short sauna doesn't affect your eggs. In the days after ovulation you could be in a very early pregnancy, when a long stay at high heat is best avoided. A warm shower or bath is always fine.",
    indianEn:
        'Salon steam and spa sessions are the same thing: keep them short, and leave them out from ovulation until your period or a test.',
  ),
  TtcCanI(
    id: 'yoga',
    questionEn: 'Can I do yoga while trying?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. Yoga is a good way to stay active and calm while trying.',
    whyEn:
        "Regular yoga is gentle exercise and can help you sleep and feel less tense. There's no pose that stops you conceiving. In the two-week wait, many people choose gentler practice and skip hot yoga.",
    indianEn:
        'Home yoga, a class or a YouTube routine are all fine. Pranayama and slow stretching are a good fit for the waiting days.',
  ),
  TtcCanI(
    id: 'swimming',
    questionEn: 'Can I go swimming?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. Swimming is safe and good exercise while trying.',
    whyEn:
        "Pool chlorine doesn't affect fertility. Swimming works your whole body without strain, and it's fine to keep going into a pregnancy.",
    indianEn:
        "A club or hotel pool is fine. If you get thrush easily, change out of a wet costume soon after.",
  ),
  TtcCanI(
    id: 'massage',
    questionEn: 'Can I get a massage?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. A massage is fine, and good for stress.',
    whyEn:
        "There's no evidence that a massage affects conceiving. In the two-week wait, a gentle one is a kind way to rest. Tell the therapist you're trying if they use strong oils or very deep pressure on the belly.",
    indianEn:
        'A home champi or an oil massage is fine. The same goes for a spa, with its steam kept short.',
  ),
  TtcCanI(
    id: 'night_shifts',
    questionEn: 'Can I keep working night shifts?',
    verdict: TtcVerdict.moderate,
    limitEn: 'with as much regular sleep as you can get',
    shortEn: 'Yes. Shifts can unsettle your cycle a little, so protect your sleep.',
    whyEn:
        "Many people conceive while working nights. Changing shifts can make cycles less regular for some, which makes your fertile days harder to spot. Regular sleep, even at odd hours, helps. If your cycle becomes very irregular, see a doctor.",
    indianEn:
        'Nurses, doctors, call centre and IT teams often work shifts. Blackout curtains and a fixed sleep time after a night shift help most.',
  ),
  TtcCanI(
    id: 'fly_wait',
    questionEn: 'Can I fly in the two-week wait?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. Flying does not affect implantation.',
    whyEn:
        "Airport scanners, cabin pressure and sitting on a plane don't stop an egg implanting. Drink water and walk around on long flights, the same advice as for anyone.",
    indianEn:
        'Weddings, work trips and visits home are all fine to go ahead with. Carry your folic acid.',
  ),
  TtcCanI(
    id: 'skincare',
    limitEn: 'pause retinol and retinoid creams',
    questionEn: 'Can I keep using my skincare?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, mostly. Pause retinol and retinoid creams while you try.',
    whyEn:
        'Moisturisers, sunscreen, face wash and most creams are fine. Vitamin A creams (retinol, tretinoin, adapalene) are usually paused while trying, because you may be pregnant for a while before you know. Tablets for acne are a separate question for your doctor.',
    indianEn:
        'Check the ingredients for "retinol", "retinoid", "tretinoin" or "adapalene". Niacinamide, azelaic acid and plain sunscreen are gentler swaps for now.',
  ),
  TtcCanI(
    id: 'vaping',
    questionEn: 'Can I keep vaping while we try?',
    verdict: TtcVerdict.avoid,
    shortEn: 'No, best to stop. Nicotine affects fertility whether you smoke or vape.',
    whyEn:
        "Vapes still deliver nicotine, which affects eggs, sperm and an early pregnancy. They aren't a safe swap for cigarettes while trying. Stopping helps both of you, and a doctor can help you do it.",
    indianEn:
        "The same goes for gutka, khaini and paan with tobacco. Tele-MANAS (14416) and your doctor can help if stopping is hard.",
  ),

  // ---- For him --------------------------------------------------------------------
  TtcCanI(
    id: 'laptop_lap',
    forPartner: true,
    limitEn: 'on a table rather than on the lap',
    questionEn: 'Can he use a laptop on his lap?',
    verdict: TtcVerdict.moderate,
    shortEn: 'Yes, but a table is better. Heat on the lap can lower sperm quality a little.',
    whyEn:
        'Sperm are made best a little cooler than the body. A laptop resting on the lap for hours warms the testicles. It\'s a small effect, but an easy one to fix.',
    indianEn:
        'A desk, a table or a pillow under the laptop is enough. Work-from-home days on the bed are the usual culprit.',
  ),
  TtcCanI(
    id: 'cycling',
    forPartner: true,
    questionEn: 'Can he keep cycling?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. Everyday cycling is fine for his fertility.',
    whyEn:
        "Normal cycling to work or for fitness hasn't been shown to harm sperm. A well-fitting seat and padded shorts help on long rides. Staying active is good for sperm.",
    indianEn:
        'If he rides a lot, standing up now and then on long rides relieves pressure. Otherwise, keep going.',
  ),
  TtcCanI(
    id: 'underwear',
    forPartner: true,
    questionEn: 'Can he wear tight underwear?',
    verdict: TtcVerdict.moderate,
    limitEn: 'looser is a little better',
    shortEn: 'Yes. Looser underwear may help a little, but it is a small effect.',
    whyEn:
        "Some studies found men in looser underwear had slightly better sperm counts, because the testicles stay cooler. It's a small, easy change, not a cause of trouble on its own.",
    indianEn:
        'Cotton boxers are an easy switch. Tight jeans all day in the heat add to the warmth too.',
  ),
  TtcCanI(
    id: 'phone_pocket',
    forPartner: true,
    questionEn: 'Can he keep his phone in his pocket?',
    verdict: TtcVerdict.safe,
    shortEn: "Yes. The evidence on phones and sperm is weak.",
    whyEn:
        "A few studies suggest a link between phones in trouser pockets and sperm, but they don't show the phone is the cause. There's no need to worry about it. A laptop on the lap and long hot baths are clearer things to change.",
    indianEn:
        'If he wants to, a shirt or bag pocket is an easy option. It isn\'t something to argue about.',
  ),
  TtcCanI(
    id: 'testosterone',
    forPartner: true,
    questionEn: 'Can he take testosterone or muscle-building boosters?',
    verdict: TtcVerdict.askDoctor,
    shortEn: 'Ask a doctor first. Testosterone and steroids can stop sperm being made.',
    whyEn:
        "Extra testosterone, from injections, gels or gym steroids, tells the body to stop making its own, and sperm production can drop sharply. It usually recovers after stopping, but that can take months. Plain protein powder is a different thing and is fine.",
    indianEn:
        'Gym "boosters" sold online sometimes contain hidden steroids. If he uses any, a doctor or andrologist can advise how to come off them.',
  ),

  // ---- Medicines and tests ------------------------------------------------------------
  TtcCanI(
    id: 'cold_medicine',
    questionEn: 'Can I take cold and flu medicine?',
    verdict: TtcVerdict.moderate,
    limitEn: 'simple ones; ask about combination tablets in the two-week wait',
    shortEn: 'Yes, simple ones. Paracetamol, steam and rest are fine while trying.',
    whyEn:
        "A cold won't stop you conceiving. Paracetamol for fever or aches is fine. Some combination cold tablets contain decongestants that are best avoided in early pregnancy, so in the two-week wait ask the chemist for a simpler option.",
    indianEn:
        'Haldi doodh, steam, ginger tea and rest are fine too. Tell the chemist you are trying for a baby.',
  ),
  TtcCanI(
    id: 'antibiotics',
    questionEn: 'Can I take antibiotics?',
    verdict: TtcVerdict.moderate,
    limitEn: 'when a doctor prescribes them',
    shortEn: 'Yes, when a doctor prescribes them. Tell them you are trying.',
    whyEn:
        "Common antibiotics don't affect fertility, and an untreated infection can do more harm. A few antibiotics are avoided in early pregnancy, so your doctor can pick one that suits someone trying.",
    indianEn:
        "Don't buy antibiotics over the counter without a prescription. Finish the course your doctor gives you.",
  ),
  TtcCanI(
    id: 'vaccines',
    questionEn: 'Can I get vaccines while trying?',
    verdict: TtcVerdict.moderate,
    limitEn: 'wait a month after MMR or chickenpox',
    shortEn: 'Yes. For MMR or chickenpox vaccines, wait a month before trying.',
    whyEn:
        "Most vaccines, like flu and tetanus, are fine at any time. MMR (rubella) and chickenpox are live vaccines, so doctors advise waiting a month after them before trying. It's a good time to check you're protected against rubella.",
    indianEn:
        'Ask your doctor for a rubella test if you are not sure you had the MMR vaccine as a child. The Vaccines tool keeps a note of what you have had.',
  ),
  TtcCanI(
    id: 'regular_meds',
    questionEn: 'Can I keep taking my regular medicines?',
    verdict: TtcVerdict.askDoctor,
    shortEn: 'Ask your doctor. Do not stop any regular medicine on your own.',
    whyEn:
        "Most regular medicines are fine, and stopping some suddenly can be harmful. A few need changing before pregnancy, such as some for epilepsy, blood pressure or acne. Your doctor can check each one and switch any that need it.",
    indianEn:
        'Take the strips or a photo of each medicine to your appointment. Include ayurvedic and homeopathic ones too.',
  ),
  TtcCanI(
    id: 'thyroid_tablets',
    questionEn: 'Can I keep taking my thyroid tablets?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. Keep taking them, and get your TSH checked while trying.',
    whyEn:
        "Thyroxine is safe while trying and in pregnancy, and a well-controlled thyroid helps you conceive. Your dose often needs to go up once you're pregnant, so tell your doctor as soon as you get a positive test.",
    indianEn:
        'Thyroid problems are common in India. Take your tablet on an empty stomach, apart from calcium and iron.',
  ),
  TtcCanI(
    id: 'after_pill',
    questionEn: 'Can we try straight after I come off the pill?',
    verdict: TtcVerdict.safe,
    shortEn: 'Yes. You can try as soon as you stop.',
    whyEn:
        "The pill doesn't harm future fertility. Some people ovulate in the first month, others take a few months for cycles to settle. There's no need to wait, though your first period helps date a pregnancy.",
    indianEn:
        'After the injection (Depo), fertility can take longer to come back, sometimes up to a year. That is normal.',
  ),
  TtcCanI(
    id: 'isotretinoin',
    questionEn: 'Can I take isotretinoin for acne?',
    verdict: TtcVerdict.askDoctor,
    shortEn: 'Ask your doctor now. It must be stopped at least a month before you try.',
    whyEn:
        "Isotretinoin tablets can seriously harm a baby in early pregnancy. Doctors advise stopping at least one month before trying, and using contraception until then. Your dermatologist and your gynaecologist can plan the timing with you.",
    indianEn:
        'It is sold under several brand names. Check the strip for "isotretinoin", and tell your doctor even if you only take it now and then.',
  ),
];

TtcCanI? ttcCanIById(String id) {
  for (final q in ttcCanI) {
    if (q.id == id) return q;
  }
  return null;
}
