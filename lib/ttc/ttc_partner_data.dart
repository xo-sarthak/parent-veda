// =============================================================================
//  TTC - the partner's content
// -----------------------------------------------------------------------------
//      "Father Mode should not begin in pregnancy. It begins in TTC. His role
//       is not observer. His role is not assistant. His role is partner."
//                                                       - TTC master, §15
//
//      "This becomes significantly stronger than Pregnancy. The partner joins
//       before conception."                              - TTC master, §2.12
//
//  His voice, carried over from the pregnancy father mode and kept exactly:
//  plain-spoken, second-person, instructional without nagging. Short
//  declaratives. No exclamation marks. Never "help her" as though it were her
//  project - half of this is biologically his.
//
//  Two things this content refuses to do, both of which are the standard
//  failure of partner content in fertility apps:
//
//   1. It never tells him to manage her feelings. "Cheer her up" is not a
//      mission; sitting with her is.
//   2. It never treats his body as a footnote. Sperm takes ninety days to
//      make, and roughly half of couples who struggle have a male factor - so
//      his missions include his own sleep, drinking, heat and tests.
//
//  SEED CONTENT - see the header of ttc_daily_data.dart.
// =============================================================================

import 'ttc_chapter.dart';

/// One thing for him today. Concrete, doable, and never about fixing her.
class TtcMission {
  const TtcMission({
    required this.id,
    required this.titleEn,
    required this.titleHi,
    required this.bodyEn,
    required this.bodyHi,
    required this.forHimself,
  });

  final String id;
  final String titleEn;
  final String titleHi;
  final String bodyEn;
  final String bodyHi;

  /// True when the mission is about HIS body or habits rather than about her.
  /// Pinned by test - a partner mode where every mission is about her has
  /// quietly made him an assistant again.
  final bool forHimself;

  String title(bool hi) => hi ? titleHi : titleEn;
  String body(bool hi) => hi ? bodyHi : bodyEn;
}

const List<TtcMission> ttcMissions = [
  TtcMission(
    id: 'ask_dont_fix',
    forHimself: false,
    titleEn: 'Ask, do not fix',
    titleHi: 'Poochhein, theek karne ki koshish na karein',
    bodyEn:
        'If she brings something up tonight, the useful reply is "what would help?" - not a plan. Most of the time the answer is that nothing helps, and she wanted to say it out loud to someone who would not flinch.',
    bodyHi:
        'Agar aaj raat wo kuch kehti hai, toh kaam ka jawab hai "kya madad karega?" - koi plan nahi. Zyadatar baar jawab yahi hota hai ki kuch madad nahi karta, aur wo bas kisi aise se kehna chahti thi jo ghabraye nahi.',
  ),
  TtcMission(
    id: 'your_sleep',
    forHimself: true,
    titleEn: 'Go to bed at the same time tonight',
    titleHi: 'Aaj usi samay soyein',
    bodyEn:
        'The hormones that drive sperm production run on a daily rhythm tied to sleep. Same bedtime beats more hours. This one is about your body, not hers.',
    bodyHi:
        'Jo hormones sperm banne ko chalate hain wo neend se judi roz ki rhythm par chalte hain. Ek hi samay sona, zyada ghanton se behtar hai. Ye aapke body ki baat hai, unki nahi.',
  ),
  TtcMission(
    id: 'laptop',
    forHimself: true,
    titleEn: 'Laptop off the lap',
    titleHi: 'Laptop god se hatayein',
    bodyEn:
        'Sperm production works best a couple of degrees below body temperature. Sustained heat works against it - long hot baths, saunas, hours with a laptop resting on you. Costs nothing to change.',
    bodyHi:
        'Sperm banne ka kaam body temperature se do degree kam par sabse accha hota hai. Lagatar garmi iske khilaf jaati hai - lambe garam nahaane, sauna, ghanton tak god par laptop. Badalne mein kuch kharch nahi.',
  ),
  TtcMission(
    id: 'one_line',
    forHimself: false,
    titleEn: 'Agree on the family line',
    titleHi: 'Ghaarwaalon ke liye ek line tay karein',
    bodyEn:
        '"Good news kab de rahe ho?" is coming at the next family gathering. Agree on one short reply together tonight so neither of you is improvising alone in a room full of relatives.',
    bodyHi:
        '"Good news kab de rahe ho?" agle family function mein aayega hi. Aaj raat saath mein ek chhota sa jawab tay kar lein, taaki rishtedaaron se bhare kamre mein koi akela na sochta rahe.',
  ),
  TtcMission(
    id: 'book_your_test',
    forHimself: true,
    titleEn: 'Book your own test',
    titleHi: 'Apna test book karein',
    bodyEn:
        'A semen analysis is cheap, same-day and non-invasive. A male factor is involved in roughly half of couples who struggle, yet the woman is usually investigated first through tests that are slower and harder. Going first is the useful thing to do.',
    bodyHi:
        'Semen analysis sasta, usi din ka aur bina takleef ka hai. Jo couples mushkil jhelte hain unmein lagbhag aadhe mein mard ka factor hota hai, phir bhi aam taur par pehle aurat ke test hote hain - jo dheere aur mushkil hote hain. Pehle jaana hi kaam ki baat hai.',
  ),
  TtcMission(
    id: 'take_the_load',
    forHimself: false,
    titleEn: 'Take one thing off her list',
    titleHi: 'Unki list se ek kaam apne upar lein',
    bodyEn:
        'Not by asking what to do - by picking something and doing it. The appointment booking, the chemist run, dinner. Asking transfers the work back to her.',
    bodyHi:
        'Ye poochh kar nahi ki kya karna hai - kuch chun kar aur karke. Appointment book karna, chemist se laana, raat ka khaana. Poochhna wo kaam wapas unke upar daal deta hai.',
  ),
  TtcMission(
    id: 'your_drinking',
    forHimself: true,
    titleEn: 'Look honestly at the drinking',
    titleHi: 'Peene ko imaandaari se dekhein',
    bodyEn:
        'Heavy alcohol is linked to lower sperm quality, and it is one of the few lifestyle factors where the evidence is genuinely clear rather than soft. Occasional is not the same as heavy - only you know which this is.',
    bodyHi:
        'Zyada sharab kam sperm quality se judi hai, aur ye un gine-chune lifestyle factors mein hai jahan saboot sach mein saaf hain, narm nahi. Kabhi-kabhaar aur zyada, do alag baatein hain - aur kaunsi hai, ye sirf aap jaante hain.',
  ),
  TtcMission(
    id: 'no_window_talk',
    forHimself: false,
    titleEn: 'Do not announce the window',
    titleHi: 'Window ka elaan na karein',
    bodyEn:
        'She knows. Saying it out loud turns the evening into an appointment, and the fastest way to make this stop feeling like intimacy is to schedule it. The window is six days wide precisely so no single night has to carry it.',
    bodyHi:
        'Unhe pata hai. Ise bol dena shaam ko appointment bana deta hai, aur ise intimacy jaisa lagna band karne ka sabse tez tareeka hai use schedule kar dena. Window chhe din ki isiliye hoti hai taaki kisi ek raat par bojh na aaye.',
  ),
  TtcMission(
    id: 'walk_together',
    forHimself: false,
    titleEn: 'Walk together, no phones',
    titleHi: 'Saath tehlein, bina phone',
    bodyEn:
        'Twenty minutes, both of you, no screens. It counts as your movement for the day and it is the easiest conversation you will have all week.',
    bodyHi:
        'Bees minute, dono, bina screen. Ye din ka aapka movement bhi hai aur poore hafte ki sabse aasaan baatcheet bhi.',
  ),
  TtcMission(
    id: 'your_supplements',
    forHimself: true,
    titleEn: 'Your supplements are yours to remember',
    titleHi: 'Apne supplements khud yaad rakhein',
    bodyEn:
        'Zinc and CoQ10 are as much yours as folic acid is hers. If she is the one reminding you, the load has quietly moved back onto her again.',
    bodyHi:
        'Zinc aur CoQ10 utne hi aapke hain jitna folic acid unka. Agar wo aapko yaad dila rahi hain, toh bojh chupchaap phir unke upar aa gaya hai.',
  ),
  TtcMission(
    id: 'the_bad_day',
    forHimself: false,
    titleEn: 'When the period arrives',
    titleHi: 'Jab period aa jaye',
    bodyEn:
        'It is a loss even though nothing was confirmed. Do not move straight to next month, do not be immediately practical, and do not say "at least we know we can try again". Sit with it. Tomorrow is soon enough.',
    bodyHi:
        'Ye ek nuksaan hai, chahe kuch confirm hua hi na ho. Turant agle mahine par mat jayein, turant practical mat banein, aur ye mat kahein "chalo agli baar sahi". Bas saath baithein. Kal kaafi jaldi hai.',
  ),
  TtcMission(
    id: 'go_to_the_appointment',
    forHimself: false,
    titleEn: 'Go to the appointment with her',
    titleHi: 'Appointment par saath jayein',
    bodyEn:
        'Two people hear more than one, and a partner in the room changes how the consultation goes. Bring the questions you both saved rather than trying to remember them.',
    bodyHi:
        'Do log ek se zyada sunte hain, aur kamre mein partner ke hone se consultation ka rukh badal jaata hai. Jo sawaal aap dono ne save kiye hain wo saath le jayein - yaad karne ki koshish na karein.',
  ),
];

/// What she may be carrying in this chapter, and what he can do about it.
/// Deliberately separates the two, because "she feels X so do Y" is the shape
/// that turns him into her manager.
class TtcPartnerBrief {
  const TtcPartnerBrief({
    required this.sheMayFeelEn,
    required this.sheMayFeelHi,
    required this.youCanEn,
    required this.youCanHi,
    required this.herBodyEn,
    required this.herBodyHi,
    required this.yourBodyEn,
    required this.yourBodyHi,
  });

  final String sheMayFeelEn;
  final String sheMayFeelHi;
  final String youCanEn;
  final String youCanHi;

  /// WHAT IS PHYSICALLY HAPPENING TO HER - the half his side was missing.
  ///
  /// He had `sheMayFeel` (her state of mind), `youCan` (what to do) and
  /// `yourBody` (his own biology), and nowhere was he ever told what a cycle is,
  /// what ovulation means, or why the two weeks before a period feel like early
  /// pregnancy. He was being asked to support a process nobody had explained to
  /// him - which is most men, and it is not their fault.
  ///
  /// Written at CHAPTER level, never cycle-day level, and that is a privacy
  /// property rather than a stylistic one: his device holds no rows in
  /// `ttc_cycles` and he only ever receives the chapter she publishes. A field
  /// that needed her cycle day could not be filled on his side at all.
  ///
  /// Explains, never predicts. Nothing here tells him where she is today or what
  /// will happen next - that would be reading her cycle through prose.
  final String herBodyEn;
  final String herBodyHi;

  /// His half of the biology, in every chapter without exception.
  final String yourBodyEn;
  final String yourBodyHi;

  String sheMayFeel(bool hi) => hi ? sheMayFeelHi : sheMayFeelEn;
  String youCan(bool hi) => hi ? youCanHi : youCanEn;
  String herBody(bool hi) => hi ? herBodyHi : herBodyEn;
  String yourBody(bool hi) => hi ? yourBodyHi : yourBodyEn;
}

const Map<TtcChapter, TtcPartnerBrief> ttcPartnerBriefs = {
  TtcChapter.preparingTogether: TtcPartnerBrief(
    sheMayFeelEn:
        'Mostly fine, and quietly aware that a lot of what comes next will happen to her body rather than yours.',
    sheMayFeelHi:
        'Zyadatar theek, aur chupchaap ye jaanti hui ki aage jo hoga wo zyadatar unke body ke saath hoga, aapke nahi.',
    youCanEn:
        'Make the first appointment yourself. Book both your tests at the same time, not hers first. That one act sets the tone for the next year.',
    youCanHi:
        'Pehli appointment khud book karein. Dono ke test ek saath karwayein - pehle unke nahi. Ye ek kaam agle poore saal ka rukh tay kar deta hai.',
    herBodyEn:
        'One cycle, two halves. Counting starts on the first day of bleeding, and for roughly the next two weeks her body ripens a single egg while the lining of the womb rebuilds. The egg is released somewhere around the middle. The second half is a wait - that lining held ready in case the egg was fertilised, and shed if it was not. The shedding is the next period, and the count starts again.\n\nSo a period is the end of something, not the beginning of nothing. Most of a cycle is her body preparing, quietly, without any signal either of you would notice.',
    herBodyHi:
        'Ek cycle, do hisse. Ginti bleeding ke pehle din se shuru hoti hai, aur agle lagbhag do hafte body ek egg pakaati hai jabki bachchedani ki lining dobara banti hai. Egg beech mein kahin release hota hai. Doosra hissa intezaar ka hai - wahi lining taiyaar rakhi jaati hai agar egg fertilise ho gaya ho, aur nahi hua toh nikal jaati hai. Wahi agla period hai, aur ginti phir se shuru.\n\nToh period kisi cheez ka ant hai, shuruaat nahi. Cycle ka zyadatar hissa body ki chupchaap taiyaari hai - bina kisi aise signal ke jo aap dono ko dikhe.',
    yourBodyEn:
        'Sperm takes about ninety days to make. What you change this month shows up around three months from now, so starting now is not early - it is exactly on time.',
    yourBodyHi:
        'Sperm banne mein lagbhag nabbe din lagte hain. Is mahine aap jo badlenge wo teen mahine baad dikhega - toh abhi shuru karna jaldi nahi hai, bilkul sahi waqt hai.',
  ),
  TtcChapter.knowingYourRhythm: TtcPartnerBrief(
    sheMayFeelEn:
        'Absorbed in learning her own cycle, and slightly worried that it is becoming the only thing she thinks about.',
    sheMayFeelHi:
        'Apna cycle samajhne mein lagi hui, aur thodi si chintit ki kahin yahi ek cheez uske dimaag mein na reh jaye.',
    youCanEn:
        'Agree on one time a week to talk about all of this, and let the rest of the week be about anything else. Not avoidance - a container.',
    youCanHi:
        'Hafte mein ek waqt tay karein jab is sab par baat hogi, aur baaki hafta kisi aur cheez ka rahe. Ye ignore karna nahi - ek jagah bana dena hai.',
    herBodyEn:
        'Ovulation is a single moment: one egg released, surviving about a day. Sperm survive far longer - up to five days inside her. That mismatch is the entire reason people talk about a fertile window rather than a fertile date, and why the days BEFORE the egg is released matter more than the day itself.\n\nIt is also why a cycle that moves by a few days from month to month is ordinary rather than a fault. The second half of a cycle is fairly fixed in length; almost all the variation sits in the first half, in how long that egg takes to be ready. A "late" ovulation is not lateness. It is her body taking the time it needed.',
    herBodyHi:
        'Ovulation ek pal hai: ek egg release hota hai, aur lagbhag ek din zinda rehta hai. Sperm us se kaafi zyada chalte hain - unke andar paanch din tak. Yahi farak poori wajah hai ki log fertile window kehte hain, fertile date nahi - aur isiliye egg release hone se PEHLE ke din us din se zyada maayne rakhte hain.\n\nIsi wajah se cycle ka har mahine do-chaar din aage-peechhe hona aam baat hai, kharaabi nahi. Cycle ka doosra hissa lagbhag tay lambai ka hota hai; poora farak pehle hisse mein hota hai - ki egg taiyaar hone mein kitna waqt leta hai. "Late" ovulation der nahi hai. Body ne jitna waqt chahiye tha, utna liya hai.',
    yourBodyEn:
        'This is your ninety-day window too. Pick one thing - sleep, drinking, the laptop, movement - and hold it for three months without being reminded.',
    yourBodyHi:
        'Ye nabbe din ki window aapki bhi hai. Ek cheez chunein - neend, sharab, laptop, movement - aur teen mahine bina yaad dilaye nibhayein.',
  ),
  TtcChapter.tryingTogether: TtcPartnerBrief(
    sheMayFeelEn:
        'Aware of the days, and quietly dreading the moment this stops feeling like closeness and starts feeling like a task.',
    sheMayFeelHi:
        'Dino ka pata hai, aur chupchaap dar hai ki kahin ye kareeb aana na lage aur kaam lagne lage.',
    youCanEn:
        'Do not name the window out loud. If tonight is not the night for either of you, say so lightly and mean it. Six days exist so one can be skipped without cost.',
    youCanHi:
        'Window ka naam mat lein. Agar aaj raat dono mein se kisi ka man nahi hai, toh halke se keh dein aur sach mein waisa hi samjhein. Chhe din isiliye hain ki ek bina kisi nuksaan ke chhoot sake.',
    herBodyEn:
        'Her body opens the window before the egg arrives, not after. Cervical fluid changes - clearer, thinner, stretchier - and that change is doing an actual job: it lets sperm through and keeps them alive for days. Some women also notice a dull ache low on one side.\n\nPlenty notice nothing at all, and noticing nothing means nothing. There is no version of this she can do better by concentrating harder, and none of it is a test either of you can pass or fail.',
    herBodyHi:
        'Body window egg aane se pehle kholti hai, baad mein nahi. Cervical fluid badalta hai - saaf, patla, khinchne wala - aur ye badlaav sach mein ek kaam kar raha hai: ye sperm ko andar jaane deta hai aur unhe kai din zinda rakhta hai. Kuch logon ko neeche ek taraf halka dard bhi mehsoos hota hai.\n\nBahuton ko kuch bhi mehsoos nahi hota, aur kuch mehsoos na hona ka koi matlab nahi hai. Aisa koi tareeka nahi hai jisme dhyaan lagane se ye behtar ho jaye, aur ye koi test nahi hai jise aap dono mein se koi paas ya fail kar sake.',
    yourBodyEn:
        'Nothing special is required of you this week. Every day or every other day across the window is plenty - more adds nothing and makes it heavier.',
    yourBodyHi:
        'Is hafte aapse kuch khaas nahi chahiye. Window mein roz ya ek din chhod kar kaafi hai - usse zyada kuch nahi jodta aur baat bhaari kar deta hai.',
  ),
  TtcChapter.theWaitingDays: TtcPartnerBrief(
    sheMayFeelEn:
        'Reading meaning into every twinge, and knowing perfectly well that she is doing it. Early pregnancy and an approaching period feel identical.',
    sheMayFeelHi:
        'Har chhote ehsaas mein matlab dhoondh rahi hai, aur achhi tarah jaanti hai ki wo aisa kar rahi hai. Shuruaati pregnancy aur aata hua period ek jaise lagte hain.',
    youCanEn:
        'Do not ask if she has tested. Plan something for the weekend that has nothing to do with any of this. If the period comes, do not move straight to next month.',
    youCanHi:
        'Ye mat poochhein ki test kiya ya nahi. Weekend ke liye kuch aisa plan karein jiska is sab se lena-dena na ho. Agar period aa jaye, toh turant agle mahine par mat jayein.',
    herBodyEn:
        'Once the egg is released, the structure it came from starts producing progesterone. That hormone holds the lining of the womb in place - and it is also what makes her tired, tender, warm, hungry, and often more emotional than she wants to be.\n\nHere is the part worth understanding properly: progesterone does all of that whether or not she is pregnant. Early pregnancy and an ordinary approaching period genuinely feel the same, because the same hormone is driving both. She is not imagining symptoms and she is not reading too much into them - she is having real ones that simply cannot answer the question.\n\nThat is why these two weeks are hard in a way the rest of the cycle is not. There is nothing to do, nothing to check, and no way to know early.',
    herBodyHi:
        'Egg release hone ke baad, jis structure se wo aaya tha wahi progesterone banana shuru kar deta hai. Ye hormone bachchedani ki lining ko apni jagah rakhta hai - aur yahi unhe thaka hua, dukhta hua, garam, bhookha, aur aksar apni marzi se zyada emotional bana deta hai.\n\nAb dhyaan se samajhne wali baat: progesterone ye sab tab bhi karta hai jab pregnancy na ho. Shuruaati pregnancy aur aam taur par aata hua period sach mein ek jaise lagte hain, kyunki dono ke peechhe wahi hormone hai. Wo na symptoms soch rahi hain, na zyada matlab nikaal rahi hain - unhe asli symptoms ho rahe hain jo bas is sawaal ka jawaab de hi nahi sakte.\n\nIsi wajah se ye do hafte cycle ke baaki hisse se alag mushkil hote hain. Kuch karne ko nahi hai, kuch check karne ko nahi hai, aur jaldi jaanne ka koi tareeka nahi hai.',
    yourBodyEn:
        'You will be somewhere different from her on the same day - one hopeful, one already sure it has not worked. Say where you are instead of guessing where she is.',
    yourBodyHi:
        'Ek hi din aap dono alag jagah honge - ek ummeed mein, doosra pehle se maan chuka. Unka andaaza lagane ke bajaye ye kahein ki aap kahan hain.',
  ),
  TtcChapter.aNewBeginning: TtcPartnerBrief(
    sheMayFeelEn:
        'Relieved, and immediately anxious about a completely new set of things. Both at once, and both real.',
    sheMayFeelHi:
        'Rahat mein, aur turant bilkul nayi cheezon ki chinta mein. Dono ek saath, aur dono asli.',
    youCanEn:
        'Book the first appointment. Agree together who you are telling and when, before either of you tells anyone.',
    youCanHi:
        'Pehli appointment book karein. Kise batana hai aur kab, ye saath mein tay karein - kisi ke kuch kehne se pehle.',
    herBodyEn:
        'A test looks for hCG, a hormone that only exists once a pregnancy has implanted - usually a few days before a period would have been due, which is why testing earlier than that tells you nothing rather than telling you no.\n\nPregnancy is counted from the first day of her last period, not from conception. So on the day of a positive test she is already considered around four weeks pregnant. That is a convention doctors use, not a mistake in the arithmetic, and a dating scan is what settles it properly.\n\nMuch of what she feels over the next weeks will be the progesterone she already knows from the second half of a cycle, turned up and left on.',
    herBodyHi:
        'Test hCG dhoondhta hai - ek hormone jo tabhi banta hai jab pregnancy implant ho chuki ho, aam taur par period ki tareekh se kuch din pehle. Isiliye us se pehle test karne par "nahi" nahi milta, kuch bhi nahi milta.\n\nPregnancy ki ginti aakhri period ke pehle din se hoti hai, conception se nahi. Toh positive test wale din wo pehle se lagbhag chaar hafte pregnant maani jaati hain. Ye doctors ka tareeka hai, hisaab ki galti nahi - aur dating scan hi ise theek se tay karta hai.\n\nAgle kuch hafton mein wo jo mehsoos karengi, uska bahut kuch wahi progesterone hoga jo cycle ke doosre hisse se aap dono jaante hain - bas zyada, aur lagataar.',
    yourBodyEn:
        'Whatever this chapter took, you both learned how you handle something that matters enormously and is not in your control. Pregnancy will ask for that again.',
    yourBodyHi:
        'Is chapter ne jo bhi liya, aap dono ne seekha ki jo cheez bahut maayne rakhti hai aur haath mein nahi hai, use kaise jhelte hain. Pregnancy ismein se phir maangegi.',
  ),
};
