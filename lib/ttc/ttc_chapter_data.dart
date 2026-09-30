// =============================================================================
//  TTC - chapter content
// -----------------------------------------------------------------------------
//  What pregnancy's weekly journey is to weeks, this is to chapters.
//
//      "Every chapter has Hero, Overview, Science, Partner, Nutrition,
//       Exercise, Videos, Reads, Action Plan, Medical Guidance, Journal
//       Prompts, Ask Veda, Products. Exactly the same hierarchy as Pregnancy.
//       Only the content changes."                       - TTC master, §2.5
//
//  Organised behind the three hero shortcuts rather than as one long scroll:
//
//    ME   - what is happening in her body, and what it means today
//    US   - the couple: the partner's part, and what to talk about
//    NEXT - the action plan, the medical guidance, what is coming
//
//  That is the same "answer in ten seconds above the fold, depth below" shape
//  the weekly journey uses, adapted to a stage whose subject is two people.
//
//  SEED CONTENT - see the header of ttc_daily_data.dart. Written to ParentVeda's
//  voice so the stage is real from day one, and written to be replaced.
// =============================================================================

import 'ttc_chapter.dart';

class TtcSection {
  const TtcSection({
    required this.titleEn,
    required this.titleHi,
    required this.bodyEn,
    required this.bodyHi,
  });

  final String titleEn;
  final String titleHi;
  final String bodyEn;
  final String bodyHi;

  String title(bool hi) => hi ? titleHi : titleEn;
  String body(bool hi) => hi ? bodyHi : bodyEn;
}

class TtcAction {
  const TtcAction({
    required this.textEn,
    required this.textHi,
    this.forPartner = false,
  });

  final String textEn;
  final String textHi;

  /// True when this one is his to do. The action plan is genuinely shared -
  /// a list where every item belongs to her is not a couple-first product.
  final bool forPartner;

  String text(bool hi) => hi ? textHi : textEn;
}

class TtcChapterContent {
  const TtcChapterContent({
    required this.overviewEn,
    required this.overviewHi,
    required this.me,
    required this.us,
    required this.next,
    required this.actions,
    required this.medicalEn,
    required this.medicalHi,
    required this.askVedaEn,
    required this.askVedaHi,
  });

  /// The two-line brief at the top of the chapter.
  final String overviewEn;
  final String overviewHi;

  final List<TtcSection> me;
  final List<TtcSection> us;
  final List<TtcSection> next;

  /// The action plan - "worth doing this chapter", never "you must".
  final List<TtcAction> actions;

  /// When to involve a clinician. Every chapter carries one; none of them
  /// diagnose.
  final String medicalEn;
  final String medicalHi;

  /// Suggested questions, handed to Ask Veda pre-filled.
  final List<String> askVedaEn;
  final List<String> askVedaHi;

  String overview(bool hi) => hi ? overviewHi : overviewEn;
  String medical(bool hi) => hi ? medicalHi : medicalEn;
  List<String> askVeda(bool hi) => hi ? askVedaHi : askVedaEn;
}

const Map<TtcChapter, TtcChapterContent> ttcChapterContent = {
  // ===========================================================================
  TtcChapter.preparingTogether: TtcChapterContent(
    overviewEn:
        "This chapter isn't about trying yet. It's about both of you starting in better shape than you otherwise would.",
    overviewHi:
        'Ye chapter abhi koshish ka nahi hai. Ye us koshish tak behtar haalat mein pahunchne ka hai - dono ka.',
    me: [
      TtcSection(
        titleEn: 'The three months before matter most',
        titleHi: 'Pehle ke teen mahine sabse zyada maayne rakhte hain',
        bodyEn:
            "An egg takes around ninety days to mature before it's released, and sperm take about the same time to form. So what you do in this chapter isn't practice for the real thing. It already is the real thing.\n\nThat's also why nothing here needs to be dramatic. Small changes kept up for three months do more than big changes kept up for three days.",
        bodyHi:
            'Ek egg release hone se pehle lagbhag nabbe din tak pakta hai, aur sperm banne mein bhi lagbhag utna hi samay lagta hai. Toh is chapter ki aadatein "asli cheez" ki taiyaari nahi hain - wo pehle se asli cheez hain.\n\nIsi wajah se yahan kuch bhi dramatic hona zaroori nahi. Teen mahine tak nibhaye chhote badlaav, teen din ke bade badlaav se behtar hain.',
      ),
      TtcSection(
        titleEn: 'Folic acid, and why the timing matters so much',
        titleHi: 'Folic acid, aur timing hi asli baat kyun hai',
        bodyEn:
            "The neural tube, which becomes the baby's brain and spinal cord, closes in the first four weeks after conception. That's often before you've even missed a period. So folic acid needs to be in your body already by then.\n\n400 micrograms a day is the standard dose. Your doctor may suggest more if you have diabetes, epilepsy, a higher BMI, or a past pregnancy affected by a neural tube defect. It's cheap, every chemist has it, and nothing else on this page has stronger evidence behind it.",
        bodyHi:
            'Neural tube - jo aage brain aur spinal cord banta hai - conception ke pehle chaar hafton mein band ho jaata hai, aksar period miss hone se bhi pehle. Tab tak folic acid aapke body mein pehle se hona chahiye.\n\nRoz 400 microgram standard hai. Agar aapko diabetes, epilepsy, zyada BMI ho, ya pehle kisi pregnancy mein neural tube defect raha ho, toh doctor zyada keh sakte hain. Ye sasta hai, har chemist par milta hai, aur is page par sabse zyada saboot wali cheez hai.',
      ),
      TtcSection(
        titleEn: 'The blood tests worth doing once',
        titleHi: 'Jo blood tests ek baar karwa lene chahiye',
        bodyEn:
            "This isn't a full fertility work-up. It's a handful of tests that are cheap, often come back low, and are easy to put right: TSH (thyroid), vitamin D, vitamin B12, haemoglobin, and blood sugar.\n\nEach of these can affect your cycles or early pregnancy. Each is common in Indian adults, and each is usually fixed with a tablet, not a procedure. Doing them now means you won't find out about them six months in.",
        bodyHi:
            'Poora fertility work-up nahi - bas kuch jo saste hain, jinki kami aam hai, aur jo aasaani se theek ho jaate hain: TSH (thyroid), vitamin D, vitamin B12, haemoglobin, aur blood sugar.\n\nInmein se har ek cycles ya shuruaati pregnancy par asar daal sakta hai, har ek Indian adults mein aam hai, aur har ek aam taur par goli se theek hota hai, procedure se nahi. Abhi karwa lene ka matlab hai ki chhe mahine baad pata nahi chalega.',
      ),
    ],
    us: [
      TtcSection(
        titleEn: 'Half of this is his',
        titleHi: 'Iska aadha hissa unka hai',
        bodyEn:
            "A male factor is part of the reason for roughly forty to fifty per cent of couples who struggle. Yet in most Indian clinics the woman is tested first, with tests that are slower, costlier and more invasive.\n\nHis version of this chapter is short: sleep, alcohol, smoking, heat, weight, and a semen analysis if you'd like a first result to compare against. Sperm take about three months to make, so he has the same ninety-day window you do.",
        bodyHi:
            'Jo couples mushkil jhelte hain unmein lagbhag chalis se pachas pratishat mein mard ka factor hota hai. Phir bhi zyadatar Indian clinics mein pehle aurat ke test hote hain - jo dheere, mehnge aur zyada takleefdeh hote hain.\n\nUnka chapter chhota hai: neend, sharab, smoking, garmi, wazan, aur agar baseline chahiye toh ek semen analysis. Sperm banne mein lagbhag teen mahine lagte hain, toh unke paas bhi wahi nabbe din ki window hai.',
      ),
      TtcSection(
        titleEn: 'The conversation worth having now',
        titleHi: 'Wo baat jo abhi kar leni chahiye',
        bodyEn:
            "Before anything gets hard, it helps to agree on a few things while they're still easy: how long you'll try before seeing someone, what you'll each tell family, and what you'll do when one of you is having a bad month and the other isn't.\n\nCouples who decide these early argue about them much less later. That's because the decision was made by both of you, not by whoever was more upset that day.",
        bodyHi:
            'Kuch mushkil hone se pehle, kuch cheezein tay kar lena theek hai jab tak wo aasaan hain: kitne time koshish karenge phir doctor ke paas jayenge, ghaarwaalon ko kaun kya batayega, aur jab ek ka mahina kharaab ho aur doosre ka na ho tab kya karenge.\n\nJo couples ye baatein pehle tay kar lete hain, wo baad mein inpar bahut kam ladte hain - kyunki faisla dono ne kiya tha, na ki us din jo zyada pareshaan tha usne.',
      ),
    ],
    next: [
      TtcSection(
        titleEn: 'What comes after this chapter',
        titleHi: 'Is chapter ke baad kya',
        bodyEn:
            "Once a couple of cycles are logged, ParentVeda can start describing your own rhythm instead of an average one. That's the next chapter, Knowing Your Rhythm. All it needs from you is the first day of your period, logged when it comes.",
        bodyHi:
            'Jab do-ek cycles log ho jayenge, ParentVeda aapki apni rhythm batana shuru kar dega - kisi average ki nahi. Wahi agla chapter hai - Apni Rhythm Samajhna - aur uske liye bas itna chahiye ki period ka pehla din aane par log kar dein.',
      ),
    ],
    actions: [
      TtcAction(
        textEn: 'Start 400mcg folic acid daily',
        textHi: 'Roz 400mcg folic acid shuru karein',
      ),
      TtcAction(
        textEn: 'Book the five basic blood tests',
        textHi: 'Paanch basic blood tests karwa lein',
      ),
      TtcAction(
        textEn: 'Log the first day of your next period',
        textHi: 'Agle period ka pehla din log karein',
      ),
      TtcAction(
        textEn: 'Stop smoking completely. Second-hand smoke counts too',
        textHi: 'Smoking bilkul band - passive bhi ginta hai',
        forPartner: true,
      ),
      TtcAction(
        textEn: 'Laptop off the lap, loose cotton, no long hot baths',
        textHi: 'Laptop god se hatayein, dheela cotton, lambe garam nahaane nahi',
        forPartner: true,
      ),
      TtcAction(
        textEn: "Agree together how long you'll try before seeing a doctor",
        textHi: 'Saath mein tay karein - kitna time koshish, phir doctor',
      ),
    ],
    medicalEn:
        'See a doctor before you start trying, not after, if you have PCOS, endometriosis, thyroid disease, diabetes, a past pregnancy loss, past pelvic surgery or infection, or if you take regular medicine of any kind. One pre-conception visit (a check-up before you start trying) can change how the next year goes.',
    medicalHi:
        'Koshish shuru karne se pehle doctor se milein - baad mein nahi - agar aapko PCOS, endometriosis, thyroid, diabetes, pehle pregnancy loss, pehle pelvic surgery ya infection hua ho, ya aap koi regular dawai lete hon. Ek pre-conception consultation agle poore saal ki tasveer badal sakti hai.',
    askVedaEn: [
      'What should we both do before trying to conceive?',
      'Which blood tests are worth doing before pregnancy?',
      'How much folic acid should I take and when do I start?',
      "Is it normal to feel anxious before we've even started?",
      'What can he do that really makes a difference?',
    ],
    askVedaHi: [
      'Conceive karne se pehle hum dono ko kya karna chahiye?',
      'Pregnancy se pehle kaunse blood tests karwane chahiye?',
      'Folic acid kitna lena chahiye aur kab shuru karein?',
      'Shuru karne se pehle hi ghabrahat ho rahi hai - kya ye normal hai?',
      'Wo aisa kya kar sakte hain jisse sach mein farak pade?',
    ],
  ),

  // ===========================================================================
  TtcChapter.knowingYourRhythm: TtcChapterContent(
    overviewEn:
        'The aim of this chapter is to learn your body well enough that you can stop checking it, not to check it more carefully.',
    overviewHi:
        'Is chapter ka maqsad hai apne body ko itna samajh lena ki baar-baar dekhna band ho jaye - aur dhyaan se dekhna nahi.',
    me: [
      TtcSection(
        titleEn: "What's happening in your body right now",
        titleHi: 'Abhi asal mein ho kya raha hai',
        bodyEn:
            "From the first day of your period until ovulation, a group of follicles is maturing and oestrogen is rising. That rising oestrogen thickens the lining of your womb. Closer to ovulation, it also changes your cervical mucus.\n\nThis part of the cycle varies the most, between women and between months. The days after ovulation are much more steady. That's exactly why ParentVeda estimates ovulation by counting back from your next expected period, not forward from this one.",
        bodyHi:
            'Period ke pehle din se ovulation tak, kuch follicles pakte hain aur oestrogen badhta hai. Yahi badhta oestrogen uterus ki lining mota karta hai, aur ovulation ke paas cervical mucus badalta hai.\n\nCycle ka yahi hissa auraton ke beech aur mahinon ke beech sabse zyada badalta hai. Ovulation ke BAAD ke din kahin zyada ek jaise hote hain - aur isiliye ParentVeda ovulation ka andaaza agle period se peechhe ki taraf lagata hai, is period se aage ki taraf nahi.',
      ),
      TtcSection(
        titleEn: 'Three signs, most useful first',
        titleHi: 'Teen signals, kaam ke hisaab se',
        bodyEn:
            'Cervical mucus is free, needs no kit, and tells you what\'s happening now. It gets clearer, more slippery and stretchier as ovulation gets close.\n\nAn LH strip picks up the hormone rise twelve to thirty-six hours before the egg is released. It\'s useful, but it means "soon", not "now". With PCOS it can read high all month and mislead you.\n\nBasal temperature (your temperature at rest) confirms ovulation happened, after the fact. It\'s good for learning your pattern over a few months, but no use as a warning.',
        bodyHi:
            'Cervical mucus muft hai, koi kit nahi chahiye, aur ye batata hai ki abhi kya ho raha hai - ovulation paas aate hi zyada saaf, chikna aur khinchne wala.\n\nLH strip hormone surge ko release se baarah se chhattis ghante pehle pakadti hai. Kaam ki hai, lekin iska matlab "jald" hai, "abhi" nahi - aur PCOS mein ye poora mahina high reh kar galat raasta dikha sakti hai.\n\nBasal temperature baad mein confirm karta hai ki ovulation hua. Kuch mahinon mein apna pattern samajhne ke liye accha; chetavni ke liye bekaar.',
      ),
      TtcSection(
        titleEn: 'When cycles are irregular',
        titleHi: 'Jab cycles irregular hon',
        bodyEn:
            "Irregular cycles make timing harder, not impossible. They're worth mentioning to a doctor rather than working around on your own. PCOS, thyroid problems, a big change in weight and intense training are the common reasons.\n\nParentVeda handles this by lowering its confidence, not by hiding the estimate or pretending to be sure. If your cycles vary a lot, we'll tell you so plainly, instead of showing you a date we can't stand behind.",
        bodyHi:
            'Irregular cycles timing mushkil karte hain, namumkin nahi - aur inhe akele sambhaalne ke bajaye doctor ko batana theek hai. PCOS, thyroid ki dikkat, wazan mein bada badlaav aur bahut tez training aam wajahein hain.\n\nParentVeda ise aise sambhaalta hai ki apna confidence kam kar deta hai - estimate chhupata nahi, aur jhootha bharosa bhi nahi dikhata. Agar aapke cycles bahut badalte hain, toh hum saaf keh denge - koi aisi date nahi dikhayenge jispar hum khade na ho sakein.',
      ),
    ],
    us: [
      TtcSection(
        titleEn: 'This is the month to stop talking about it all the time',
        titleHi: 'Is mahine iski baat lagatar na karein',
        bodyEn:
            "The most common thing couples say in this chapter is that trying for a baby has slowly become the only topic at home. It happens bit by bit, and neither of you chooses it.\n\nA practical fix that works: agree on when you'll talk about it, say once a week on a walk, and let the rest of the week be about anything else. You're not avoiding it. You're giving it its own time.",
        bodyHi:
            'Is chapter mein couples sabse zyada yahi batate hain ki ghar mein baat sirf isi ki hone lagi hai. Ye dheere-dheere hota hai aur koi jaan-boojh kar nahi karta.\n\nEk kaam ka hal: tay kar lein ki kab baat karenge - jaise hafte mein ek baar, tehalte hue - aur baaki hafta kisi aur cheez ka rahe. Ye ignore karna nahi hai. Ye ek jagah bana dena hai.',
      ),
      TtcSection(
        titleEn: 'What he can track',
        titleHi: 'Wo kya track kar sakte hain',
        bodyEn:
            'Not your cycle. That\'s yours. But sleep, alcohol, exercise and stress are his to notice, and they change sperm quality with a ninety-day delay.\n\nThe better answer to "how can I help?" usually isn\'t asking you what to do. It\'s picking one of these and keeping it up for three months without being reminded.',
        bodyHi:
            'Unka cycle nahi - wo uska hai. Lekin neend, sharab, exercise aur stress unke apne hain, aur ye nabbe din ke lag ke saath sperm quality badalte hain.\n\n"Main kaise madad karoon?" ka behtar roop aksar ye poochhna nahi hai ki kya karna hai. Ye inmein se ek chun kar teen mahine tak bina yaad dilaye nibhana hai.',
      ),
    ],
    next: [
      TtcSection(
        titleEn: 'The fertile window is coming',
        titleHi: 'Fertile window aa rahi hai',
        bodyEn:
            "Once the window opens, you'll move into Trying Together. It's about six days long, and the whole point of that length is that no single day has to be right.\n\nNothing needs planning now. When it comes, ParentVeda will tell you once, gently, and won't keep repeating it.",
        bodyHi:
            'Jab window khulegi, aap Saath Mein Koshish chapter mein aa jayenge. Wo lagbhag chhe din ki hoti hai, aur itni lambi isiliye hai taaki kisi ek din ka sahi hona zaroori na ho.\n\nAbhi kuch plan karne ki zaroorat nahi. Jab aayegi, ParentVeda ek baar chupchaap bata dega, aur baar-baar nahi dohrayega.',
      ),
    ],
    actions: [
      TtcAction(
        textEn: 'Log the first day of each period as it happens',
        textHi: 'Har period ka pehla din usi waqt log karein',
      ),
      TtcAction(
        textEn: 'Notice cervical mucus once a day. It costs nothing',
        textHi: 'Din mein ek baar cervical mucus dekhein - kuch kharch nahi',
      ),
      TtcAction(
        textEn: 'Agree on one time a week to talk about all of this',
        textHi: 'Hafte mein ek waqt tay karein jab is sab par baat hogi',
      ),
      TtcAction(
        textEn: 'Pick one habit and hold it for three months',
        textHi: 'Ek aadat chunein aur teen mahine nibhayein',
        forPartner: true,
      ),
    ],
    medicalEn:
        'Worth talking to a doctor about: cycles shorter than twenty-one days or longer than thirty-five, cycles that vary by more than a week or two, bleeding between periods, periods that have stopped, or pain bad enough to stop your day. None of these means something is wrong. They mean a conversation will help you more than an app can.',
    medicalHi:
        'Doctor se poochhne layak: ikkis din se chhote ya paintiis din se lambe cycles, aise cycles jo ek-do hafte se zyada badalte hon, periods ke beech bleeding, periods ka band ho jaana, ya itna dard ki din ruk jaye. Inmein se kuch bhi ye nahi kehta ki kuch galat hai - ye kehta hai ki app se zyada ek baatcheet kaam ki hai.',
    askVedaEn: [
      "How do I know when I'm ovulating?",
      'Why is my cycle different every month?',
      'Are ovulation strips accurate if I have PCOS?',
      'My body feels like a project now. Is that normal?',
      'How long should we try before seeing someone?',
    ],
    askVedaHi: [
      'Mujhe kaise pata chalega ki main ovulate kar rahi hoon?',
      'Mera cycle har mahine alag kyun hota hai?',
      'PCOS hai toh kya ovulation strips sahi hoti hain?',
      'Ab apna body ek project jaisa lagta hai. Kya ye normal hai?',
      'Kisi ko dikhane se pehle kitne time koshish karni chahiye?',
    ],
  ),

  // ===========================================================================
  TtcChapter.tryingTogether: TtcChapterContent(
    overviewEn:
        "These are days to be close, not days to perform. That's exactly why the window is several days wide.",
    overviewHi:
        'Ye din kareeb aane ke hain, kuch karke dikhane ke nahi. Window kai din ki isi wajah se hoti hai.',
    me: [
      TtcSection(
        titleEn: 'Why the window is six days and not one',
        titleHi: 'Window chhe din ki kyun hai, ek nahi',
        bodyEn:
            "Sperm can survive around five days inside the body. An egg lives about a day after it's released. Together, that gives a window of about six days, ending on the day you ovulate.\n\nWhat this means for you is reassuring. Being together every day or every other day across those days works as well as any amount of testing and timing. There's no single day to hit.",
        bodyHi:
            'Sperm reproductive tract ke andar lagbhag paanch din tak zinda reh sakte hain. Egg release ke baad lagbhag ek din. Dono milakar lagbhag chhe din ki window banti hai, jo ovulation ke din khatam hoti hai.\n\nIska practical matlab tasalli dene wala hai: un dino mein roz ya ek din chhod kar saath hona, kisi bhi testing aur timing jitna hi asardaar hai. Koi ek din pakadna zaroori nahi.',
      ),
      TtcSection(
        titleEn: "Things that don't matter, whatever you've heard",
        titleHi: 'Jo cheezein maayne nahi rakhtin, chahe jo suna ho',
        bodyEn:
            "Position doesn't matter. Lying with your legs up afterwards doesn't matter, because sperm reach the cervix within minutes. Timing it to a certain hour doesn't matter.\n\nOne thing does matter, and hardly anyone mentions it: most ordinary lubricants, and saliva, make sperm move less well. If you use one, look for a product labelled fertility-friendly.",
        bodyHi:
            'Position maayne nahi rakhti. Baad mein taange upar karke letna maayne nahi rakhta - sperm minton mein cervix tak pahunch jaate hain. Kisi khaas ghante ki timing maayne nahi rakhti.\n\nEk cheez sach mein maayne rakhti hai aur shayad hi batayi jaati hai: zyadatar aam lubricants aur thook, sperm ke chalne ki kshamta kam karte hain. Agar istemaal karte hain, toh fertility-friendly likha product dhoondhein.',
      ),
    ],
    us: [
      TtcSection(
        titleEn: 'When it starts to feel like a task',
        titleHi: 'Jab ye kaam jaisa lagne lage',
        bodyEn:
            "This is the strain couples mention most in this whole stage, and almost nobody says it out loud. Sex on a schedule stops feeling close and starts feeling like homework with a deadline. The partner who feels called on often stops saying so, and that makes it worse.\n\nWhat helps: don't announce the window out loud every month. Don't treat a night that doesn't happen as a loss. And keep in mind that the window is six days long so that one night can be skipped at no cost.",
        bodyHi:
            'Poore stage mein sabse zyada yahi dabaav mehsoos hota hai, aur lagbhag koi ise kehta nahi. Schedule par sex intimacy nahi rehta, deadline wala assignment ban jaata hai - aur jise "bulaya gaya" mehsoos hota hai wo aksar kehna band kar deta hai, jisse baat aur bigadti hai.\n\nJo madad karta hai: har mahine window ka elaan na karna. Jo raat nahi hui use nuksaan na maanna. Aur ye yaad rakhna ki chhe din isiliye hain ki ek raat bina kisi kharche ke chhoot sakti hai.',
      ),
      TtcSection(
        titleEn: 'His part, plainly',
        titleHi: 'Unka hissa, saaf-saaf',
        bodyEn:
            "Be there with her, and don't make it a performance. Don't ask her what day it is. Don't tell anyone else what week you're in. Don't turn the evening into a project.\n\nAnd if it doesn't happen tonight, say so lightly and mean it. The most useful thing a partner can do in this chapter is make it okay to skip a day without either of you saying sorry.",
        bodyHi:
            'Saath hona, kuch "karke dikhana" nahi. Unse ye na poochhein ki aaj kaunsa din hai. Kisi aur ko ye na batayein ki kaunsa hafta chal raha hai. Shaam ko project na banayein.\n\nAur agar aaj raat nahi hua, toh halke se keh dein - aur sach mein waisa hi samjhein. Is chapter mein partner ka sabse kaam ka kaam yahi hai ki ek din chhootna mumkin ho, bina kisi ke maafi maange.',
      ),
    ],
    next: [
      TtcSection(
        titleEn: 'Then the waiting',
        titleHi: 'Phir intezaar',
        bodyEn:
            "After the window closes comes the hardest part of the cycle: about two weeks with nothing to do. ParentVeda won't put a countdown in front of you. Instead, it will suggest things to fill the days with, because that's the only thing that really helps.",
        bodyHi:
            'Window band hone ke baad cycle ka sabse mushkil hissa aata hai - lagbhag do hafte, jismein karne ko kuch nahi. ParentVeda aapke saamne countdown nahi rakhega. Uski jagah in dino ko bharne ke liye cheezein sujhayega, kyunki sach mein wahi madad karta hai.',
      ),
    ],
    actions: [
      TtcAction(
        textEn: 'Be together every day or every other day this week',
        textHi: 'Is hafte roz ya ek din chhod kar saath rahein',
      ),
      TtcAction(
        textEn: 'If you use lubricant, switch to a fertility-friendly one',
        textHi: 'Lubricant istemaal karte hain toh fertility-friendly lein',
      ),
      TtcAction(
        textEn: "Don't announce the window out loud this month",
        textHi: 'Is mahine window ka elaan na karein',
        forPartner: true,
      ),
      TtcAction(
        textEn: 'Plan one evening this week that has nothing to do with this',
        textHi: 'Is hafte ek shaam plan karein jiska is sab se lena-dena na ho',
      ),
    ],
    medicalEn:
        'Nothing in this chapter needs a doctor. Worth mentioning at your next appointment, not urgently: pain during sex, bleeding after sex, or a window that never seems to come across several cycles.',
    medicalHi:
        'Is chapter mein kisi cheez ke liye doctor zaroori nahi. Agli appointment par batane layak - abhi bhaagne layak nahi: sex ke dauraan dard, sex ke baad bleeding, ya aisi window jo kai cycles se aati hi nahi lagti.',
    askVedaEn: [
      'How often should we try during the fertile window?',
      'Does position or lying down afterwards make any difference?',
      'What lubricants are safe when trying to conceive?',
      'Sex has started to feel like a task. What do other couples do?',
      'Does stress really stop you getting pregnant?',
    ],
    askVedaHi: [
      'Fertile window mein kitni baar koshish karni chahiye?',
      'Position ya baad mein letne se kuch farak padta hai?',
      'Conceive karne ki koshish mein kaunse lubricants safe hain?',
      'Sex ab kaam jaisa lagne laga hai. Baaki couples kya karte hain?',
      'Kya stress sach mein conceive hone se rokta hai?',
    ],
  ),

  // ===========================================================================
  TtcChapter.theWaitingDays: TtcChapterContent(
    overviewEn:
        "Nothing you do now changes what is or isn't already happening. That's hard to hear. But it also means these two weeks ask nothing of you.",
    overviewHi:
        'Ab aap jo bhi karein, jo ho raha hai ya nahi ho raha, wo nahi badlega. Ye sunne mein mushkil hai. Aur yahi is pandrah din ki ek azaadi bhi hai.',
    me: [
      TtcSection(
        titleEn: "Why spotting symptoms can't tell you",
        titleHi: 'Symptoms dekhne se kyun kuch pata nahi chalta',
        bodyEn:
            'After ovulation, progesterone rises whether or not an egg was fertilised. Progesterone is what causes sore breasts, tiredness, mild cramps, mood changes and nausea.\n\nSo early pregnancy and a period on its way can feel exactly the same, because the same hormone is doing the same thing. Every twinge you notice these two weeks is real. But none of it tells you either way.',
        bodyHi:
            'Ovulation ke baad progesterone badhta hai, chahe egg fertilise hua ho ya nahi. Progesterone hi chhaati mein dard, thakaan, halke cramps, mood ke badlaav aur ulti jaisa ehsaas karata hai.\n\nIsliye shuruaati pregnancy aur aam aane wala period bilkul ek jaise lagte hain - kyunki dono ek hi hormone ke ek hi kaam se bante hain. In pandrah dino mein aapko jo bhi mehsoos hota hai wo asli hai - aur uska koi bhi saboot kisi taraf nahi hai.',
      ),
      TtcSection(
        titleEn: 'When a test can tell you something',
        titleHi: 'Test kab sach mein kuch batayega',
        bodyEn:
            "A home test looks for hCG, which only appears after implantation (when the embryo settles into the womb lining). That's usually six to twelve days after ovulation. Then it takes a few days to rise to a level a test can pick up.\n\nTesting early mostly gives a negative that means nothing, and then another one. The day your period is due is when a test starts to tell you something real. Before that, you're mostly paying money to feel worse.",
        bodyHi:
            'Ghar ka test hCG dhoondhta hai, jo implantation ke baad hi banta hai - aam taur par ovulation ke chhe se baarah din baad - aur phir pakad mein aane layak level tak pahunchne mein kuch din lagte hain.\n\nJaldi test karne se zyadatar aisa negative aata hai jiska koi matlab nahi, aur phir ek aur. Jis din period aana tha, tab test sach mein kuch batata hai. Usse pehle sab kuch, paisa dekar bura mehsoos karna hai.',
      ),
    ],
    us: [
      TtcSection(
        titleEn: "You won't feel the same on the same day",
        titleHi: 'Ek hi din dono ek jagah nahi honge',
        bodyEn:
            'One of you will feel hopeful on a day the other has decided it hasn\'t worked. That\'s normal. It doesn\'t mean one of you cares less.\n\nIt helps to say out loud where you are, rather than guessing where the other is. "I\'m having a bad day about this" is more useful than a week of careful silence.',
        bodyHi:
            'Ek din aap mein se ek ummeed mein hoga aur doosre ne maan liya hoga ki nahi hua. Ye farak normal hai, aur iska matlab ye nahi ki kisi ek ko kam farak padta hai.\n\nDoosre ka andaaza lagane ke bajaye ye keh dena behtar hai ki aap kahan hain. "Aaj mera is baare mein mann kharaab hai" - ek hafte ki sochi-samjhi chuppi se zyada kaam ka hai.',
      ),
      TtcSection(
        titleEn: 'If the period arrives',
        titleHi: 'Agar period aa jaye',
        bodyEn:
            "It's a loss, even when nothing was ever confirmed, and it's okay to treat it as one. You don't have to be practical about the next cycle straight away.\n\nWhat helps most couples is deciding beforehand what that day looks like: who tells whom, whether you take the evening off, and whether you talk about it at all. Deciding early means neither of you has to make a choice on the worst day of the month.",
        bodyHi:
            'Ye ek nuksaan hai, chahe kuch confirm hua hi na ho, aur ise waisa maanne ka haq hai. Turant agle cycle ke baare mein practical hona zaroori nahi.\n\nZyadatar couples ko sabse zyada ye madad karta hai ki us din ka pehle se tay ho - kaun kise batayega, shaam chhutti lenge ya nahi, baat karenge bhi ya nahi. Pehle se tay hone ka matlab hai ki mahine ke sabse bure din koi faisla nahi lena padta.',
      ),
    ],
    next: [
      TtcSection(
        titleEn: 'A new cycle is not starting over',
        titleHi: 'Naya cycle "phir se shuru" nahi hai',
        bodyEn:
            "When your period comes, ParentVeda moves you back to Knowing Your Rhythm. That isn't a reset, and it isn't a step backwards. It's the same path carrying on, and you now know one more cycle's worth about your own body than you did last month.\n\nThat's also why you'll never see a progress bar here that slides backwards.",
        bodyHi:
            'Period aane par ParentVeda aapko wapas Apni Rhythm Samajhna chapter mein le jaata hai. Ye reset nahi hai aur peechhe jaana bhi nahi - ye wahi safar aage badh raha hai, pichhle mahine se ek cycle zyada jaankari ke saath.\n\nIsi wajah se aapko yahan koi aisa progress bar kabhi nahi dikhega jo peechhe jaata ho.',
      ),
    ],
    actions: [
      TtcAction(
        textEn: 'Wait until your period is due before testing',
        textHi: 'Test se pehle period ki date aane dein',
      ),
      TtcAction(
        textEn: "Plan something for this weekend that isn't about this",
        textHi: 'Is weekend kuch aisa plan karein jo is baare mein na ho',
      ),
      TtcAction(
        textEn: 'Say out loud where you are with it this week',
        textHi: 'Is hafte keh dein ki aap kahan hain is sab mein',
        forPartner: true,
      ),
      TtcAction(
        textEn: 'Keep taking folic acid. It matters most right now',
        textHi: 'Folic acid lete rahein - abhi sabse zyada zaroori hai',
      ),
    ],
    medicalEn:
        "Take a test and speak to a doctor if your period is over a week late. If you have a positive test with pain on one side, pain at the tip of your shoulder, dizziness or bleeding, get seen the same day. Don't wait. This isn't common. It's written here because it's the one thing in this chapter worth acting on straight away.",
    medicalHi:
        'Test karein aur doctor se baat karein agar period ek hafte se zyada late ho, ya positive test ke saath ek taraf dard, kandhe ke upar dard, chakkar ya bleeding ho - ye usi din dikhane wali baat hai, intezaar wali nahi. Ye aam nahi hai; ye yahan isliye likha hai kyunki is chapter mein sirf yahi cheez turant kuch karne layak hai.',
    askVedaEn: [
      'When is the earliest a pregnancy test will be accurate?',
      'Are early pregnancy symptoms different from period symptoms?',
      'My period is late but the test is negative. What does that mean?',
      'How do people get through the two-week wait?',
      "If this month doesn't work, is that something I did?",
    ],
    askVedaHi: [
      'Pregnancy test sabse jaldi kab sahi aata hai?',
      'Shuruaati pregnancy ke symptoms period ke symptoms se alag hote hain?',
      'Period late hai lekin test negative hai - iska kya matlab?',
      'Log do hafte ka intezaar kaise kaatte hain?',
      'Agar is mahine nahi hua, toh kya wo meri wajah se hai?',
    ],
  ),

  // ===========================================================================
  TtcChapter.aNewBeginning: TtcChapterContent(
    // Kept for revert (2026-09-28, journal out of TTC): both lines named the
    // journal first, which left the stage.
    //   'A positive test. Nothing here starts over. Your journal, your partner, your calendar, your reports and your care circle all carry straight through.',
    //   'Positive test. Yahan kuch phir se shuru nahi hota - aapka journal, partner, calendar, reports aur care circle, sab seedhe aage chalte hain.',
    overviewEn:
        'A positive test. Nothing here starts over. Your partner, your calendar, your reports and your care circle all carry straight through.',
    overviewHi:
        'Positive test. Yahan kuch phir se shuru nahi hota - aapka partner, calendar, reports aur care circle, sab seedhe aage chalte hain.',
    me: [
      TtcSection(
        titleEn: 'What happens now',
        titleHi: 'Ab kya hoga',
        bodyEn:
            "Pregnancy is dated from the start of your last period, not from conception. That's why you're already thought of as around four weeks pregnant on the day of a positive test. It's just how it's counted, not a mistake in the maths.\n\nYour first appointment is usually somewhere between six and eight weeks. Until then, the only things that matter are to keep taking folic acid and to tell your doctor about any medicine you take.",
        bodyHi:
            'Pregnancy ki ginti aakhri period ke pehle din se hoti hai, conception se nahi - isiliye positive test wale din aap pehle se lagbhag chaar hafte pregnant maani jaati hain. Ye ek convention hai, hisaab ki galti nahi.\n\nPehli appointment aam taur par chhe se aath hafte ke beech hoti hai. Us se pehle bas do cheezein maayne rakhti hain - folic acid lete rehna, aur doctor ko apni har dawai ke baare mein bata dena.',
      ),
    ],
    us: [
      TtcSection(
        titleEn: 'Whatever this chapter took, it also taught you something',
        titleHi: 'Is chapter ne jo bhi liya, kuch sikhaya bhi',
        bodyEn:
            "You now know how you each behave when something matters hugely and neither of you is in control. That's not a small thing to have learned, and pregnancy will ask for it again.\n\nOne practical decision worth making today rather than later: who you're telling, and when. Deciding it together now means one of you won't tell someone before the other is ready.",
        bodyHi:
            'Ab aap dono jaante hain ki jab koi cheez bahut maayne rakhti ho aur kisi ke haath mein na ho, tab aap kaisa behave karte hain. Ye seekhna chhoti baat nahi hai, aur pregnancy ismein se phir maangegi.\n\nEk practical faisla aaj hi kar lene layak: kise batana hai aur kab. Abhi saath mein tay kar lene se wo sthiti nahi aayegi jahan ek ne kisi ko bata diya ho aur doosre ne nahi.',
      ),
    ],
    next: [
      TtcSection(
        titleEn: 'The app changes around you',
        titleHi: 'App chupchaap badal jaata hai',
        bodyEn:
            "Your Today screen becomes Week 4. Prepare changes what it gets you ready for. Tools adjust. The community rooms change. Nothing is moved across, nothing needs setting up again, and nothing is lost.\n\nThat's why this stage was built the way it was.",
        bodyHi:
            'Aaj Ka Safar, Hafta 4 ban jaata hai. Prepare ka maqsad badal jaata hai. Tools dhal jaate hain. Community rooms badal jaate hain. Kuch migrate nahi hota, kuch dobara set nahi karna padta, aur kuch khota nahi.\n\nIs stage ko is tareeke se banane ka maqsad yahi tha.',
      ),
    ],
    actions: [
      TtcAction(
        textEn: 'Book your first pregnancy appointment',
        textHi: 'Apni pehli pregnancy appointment book karein',
      ),
      TtcAction(
        textEn: "Keep taking folic acid. Don't stop now",
        textHi: 'Folic acid lete rahein - abhi band na karein',
      ),
      TtcAction(
        textEn: 'Tell your doctor about every medication you take',
        textHi: 'Doctor ko apni har dawai ke baare mein batayein',
      ),
      TtcAction(
        textEn: 'Decide together who you are telling, and when',
        textHi: 'Saath mein tay karein - kise batana hai aur kab',
        forPartner: true,
      ),
    ],
    medicalEn:
        'Contact a doctor the same day, not at your booked appointment, if you have bleeding, severe or one-sided pain, pain at the tip of your shoulder, or feel faint. Early pregnancy usually goes smoothly. These are the exceptions worth knowing about, not worrying about.',
    medicalHi:
        'Usi din doctor se sampark karein - booked appointment ka intezaar na karein - agar bleeding ho, tez ya ek taraf dard ho, kandhe ke upar dard ho, ya chakkar aaye. Shuruaati pregnancy aam taur par bina kisi dikkat ke guzarti hai; ye apwaad hain jinhe jaan lena theek hai, jinpar pareshaan hona nahi.',
    askVedaEn: [
      'How many weeks pregnant am I after a positive test?',
      'When should my first pregnancy appointment be?',
      'Which of my medications are safe in early pregnancy?',
      "I'm scared to be happy about this. Is that normal?",
      'Who should we tell, and when?',
    ],
    askVedaHi: [
      'Positive test ke baad main kitne hafte pregnant hoon?',
      'Meri pehli pregnancy appointment kab honi chahiye?',
      'Meri kaunsi dawaiyan shuruaati pregnancy mein safe hain?',
      'Mujhe khush hone se dar lag raha hai. Kya ye normal hai?',
      'Kise batayein, aur kab?',
    ],
  ),
};
