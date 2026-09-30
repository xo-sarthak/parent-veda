// =============================================================================
//  For partners (pregnancy) — the reads written to HIM
// -----------------------------------------------------------------------------
//  Added 2026-09-30 from the pregnancy gap analysis: the stage had one read
//  for a partner ("How your partner can support you now") and one for the
//  labour room ("What your partner should do"), both written to HER about him.
//  These are written to the father or partner directly: "you" is him, "she" is
//  the mother, "your baby" is theirs. The door is for the lead to build; the
//  ids are in `kPartnerReadIds` for it.
//
//  Beyond `docs/PREG-VOICE.md`:
//
//  · Every clinical fact comes from a read that already exists, so the two
//    cannot disagree: the signs of labour, "When to go to hospital" and the
//    folder (`pregnancy_reads_labour_birth.dart`), the feeding and first-days
//    reads (`pregnancy_reads_labour_feeding.dart`), "How your partner can
//    support you now" (`pregnancy_reads_weekly_a.dart`), the car-seat read
//    (`pregnancy_reads_ready.dart`), "His paternity leave"
//    (`pregnancy_reads_work.dart`) and "For her partner: your grief too"
//    (`pregnancy_reads_loss.dart`). What a partner can DO is the subject,
//    not what medicine does, and every read defers to her own doctor.
//  · The labour room itself is NOT here. `preg_labour_read_partner` already
//    covers it, and these reads point to it rather than repeat it.
//  · No numbers about how common a feeling is, and no chance word beside
//    "your" (`test/pregnancy_reads_shape_test.dart` scans for exactly that).
//  · Nothing about the baby's sex, in any form (PCPNDT Act).
//  · `reviewed: false`, ParentVeda editorial, until a doctor has read them.
//
//  Not yet spread into `kPregnancyReads`: the lead does that in
//  `pregnancy_reads.dart`, one line. Until then `readNext` ids that point at
//  sibling reads resolve through that list.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, as in the other pregnancy reads files.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

const double _hue = 206;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('For partners');

final LocalizedText _kForYou = _en('For you, her partner');
final LocalizedText _kYourself = _en('Looking after you');
final LocalizedText _kTogether = _en('For the two of you');
final LocalizedText _kLoss = _en('After a loss');

/// The pregnancy danger signs, written to him, in one place so they can't
/// drift apart between reads. Agrees with the signs in "How your partner can
/// support you now" and "When to go to hospital".
final PvCallout _takeHerIn = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Take her to hospital straight away, and call on the way, if'),
  body: _en("She has heavy bleeding, a severe headache with blurred vision or "
      "flashing lights, sudden swelling of the face or hands, constant pain "
      "that doesn't come and go, a fever, or fluid leaking. Go too if your "
      "baby is moving much less than usual. Call her doctor or the hospital "
      "for any other bleeding, even light. If she feels faint or is in severe "
      "pain, don't drive her yourself: call 108 for an ambulance."),
);

final LocalizedText _evPartner = _en('WHO recommendations on health promotion '
    'interventions for maternal and newborn health (2015), on male '
    'involvement · Yargawa and Leonardi-Bee, Journal of Epidemiology and '
    'Community Health (2015) · NICE guideline NG201, Antenatal care · '
    'Ministry of Health and Family Welfare, Pradhan Mantri Surakshit '
    'Matritva Abhiyan (PMSMA) guidance.');

/// Every read in this file, for the door to hang its tiles on.
const List<String> kPartnerReadIds = [
  'preg_partner_read_first_days',
  'preg_partner_read_each_trimester',
  'preg_partner_read_first_time_dad',
  'preg_partner_read_feeding',
  'preg_partner_read_sympathy',
  'preg_partner_read_your_feelings',
  'preg_partner_read_couple_questions',
  'preg_partner_read_after_loss_partner',
];

final List<PvRead> kPregnancyReadsPartner = [
  // ---------------------------------------------------------------------------
  //  The first days after the news
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_partner_read_first_days',
    hue: _hue,
    kicker: _kForYou,
    title: _en('What to do in the first days after the news'),
    teaser: _en("How to be there, what she may be feeling, what to ask and "
        "what to keep to yourself, the first doctor visit, telling the "
        "family, and money."),
    shortAnswer: _en("Be there, ask her what she needs, and take on a few "
        "jobs without being reminded. Let her decide who is told and when. "
        "Book the first doctor visit together, and keep money talk calm and "
        "shared. There's no test to pass in these first days."),
    scaleSetter: _en("Most partners feel unsure in the first days, and that's "
        "normal. Nobody expects you to know what to do. A few small habits "
        "help a lot, and you can start them today."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The news can land as joy, shock or both in the same minute. You "
            "might feel proud, scared and lost before lunch. All of that is "
            "allowed, and none of it says anything about the father you'll "
            "be."),
        _en("This read is for you. It covers how to be there for her, what "
            "she may be feeling, and the few things worth doing this week."),
      ]),
      PvReadSection(
        heading: _en('How do I be there for her?'),
        paragraphs: [
          _en("Start by asking what she needs today, and mean it. Some days "
              "that's quiet. Some days it's a plate of something plain and a "
              "short walk."),
        ],
        bullets: [
          _en("Ask before you fix. 'Do you want advice, or do you want me to "
              "listen?' is a good question."),
          _en("Take over one regular job completely, like the morning tea or "
              "the evening cooking, and keep it up without being reminded."),
          _en("Keep water and dry biscuits near her. Nausea can start early."),
          _en("Put your phone down when she's telling you how she feels."),
        ],
      ),
      PvReadSection(
        heading: _en('What might she be feeling?'),
        paragraphs: [
          _en("Joy, worry, tiredness and nausea can all arrive together. Some "
              "women feel very little for the first weeks, and that's common "
              "too. She may be tearful or short-tempered. That's mostly "
              "tiredness and a very big change landing on the nearest "
              "person. It isn't a verdict on you."),
          _en("Many women feel anxious in the first weeks, and that's one "
              "reason couples wait before telling people. A steady, calm "
              "partner helps more than reassurance you can't promise."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask, and what should I keep to myself?'),
        paragraphs: [
          _en("Good questions for this week: How are you feeling today? What "
              "would help most right now? Who would you like to tell first? "
              "Do you want me at the first visit?"),
          _en("Keep these to yourself until she asks for them:"),
        ],
        bullets: [
          _en("The news itself, until she says who can be told."),
          _en("Stories about other women's pregnancies or births, good or "
              "bad."),
          _en("Advice from friends or the internet. Note the question down "
              "and ask her doctor."),
          _en("Comments on what she eats, or what she's 'allowed' to do."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens at the first doctor visit?'),
        paragraphs: [
          _en("Book it together. At the first antenatal visit the pregnancy is "
              "registered, which gets her a Mother and Child Protection card, "
              "and her doctor plans her check-ups and scans. Offer to come. "
              "It's where the pregnancy becomes real for both of you."),
          _en("If she takes any regular medicine, she should keep taking it "
              "until a doctor has checked it. Folic acid, and no alcohol or "
              "tobacco, are the other two basics. If you smoke, keep it away "
              "from her and away from the house."),
        ],
        tip: PvReadTip(
          title: _en('Be the note-taker'),
          body: _en("Keep her questions in a note on your phone, and write "
              "down what the doctor says. It leaves her free to listen."),
        ),
      ),
      PvReadSection(
        heading: _en('How do we tell the family?'),
        paragraphs: [
          _en("There's no right time. Many couples wait until after the "
              "12-week scan, and some tell one or two close people sooner "
              "to get help. In many families there's also a custom of not "
              "announcing early, sometimes for nazar. Decide together, then "
              "stick to it."),
          _en("Your best job here is to hold the line. If she asked you to "
              "keep it private, your mother hears it when she's ready. When "
              "you do tell someone, say clearly whether they can pass it on. "
              "And when the advice starts, you can be the one who says 'the "
              "doctor said', so she doesn't have to."),
        ],
      ),
      PvReadSection(
        heading: _en('What about money worries?'),
        paragraphs: [
          _en("It's natural for money to be the first thing on your mind: the "
              "hospital, leave, the months ahead. Have the talk with her, not "
              "around her. Pick a calm time, write down what you know "
              "(savings, insurance, your leave), and leave the rest as "
              "questions for the coming weeks."),
          _en("Try not to bring every worry to her each evening. Share some "
              "with a friend or your brother, or keep a list and go through "
              "it together once a week. The work door has reads on what a "
              "delivery may cost, insurance and paternity leave."),
        ],
      ),
    ],
    whenToSeeSomeone: _takeHerIn,
    faqs: [
      PvReadFaq(
        question: _en("She's tired and snappy. Is it something I did?"),
        answer: _en("Very likely not. Tiredness, nausea and a huge change "
            "land on whoever is nearest. Do the jobs above without being "
            "asked, and give it time."),
      ),
      PvReadFaq(
        question: _en('Should I come to the first scan?'),
        answer: _en("If she'd like you there, yes. It's often when the "
            "pregnancy becomes real for both of you, and most partners are "
            "glad they went. Ask her first."),
      ),
    ],
    evidence: _evPartner,
    readNext: [
      'preg_first_read_this_week',
      'preg_first_read_when_to_tell',
      'preg_partner_read_each_trimester',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Trimester by trimester
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_partner_read_each_trimester',
    hue: _hue,
    kicker: _kForYou,
    title: _en('Things you can do, trimester by trimester'),
    teaser: _en("Doable jobs for each stage, from the first scan to the "
        "hospital route, with food, sleep, appointments and your leave."),
    shortAnswer: _en("In the first trimester, take over food smells and "
        "come to the first scan. In the second, share the appointment diary "
        "and sort out leave and money. In the third, own the hospital bag, "
        "the route and the plan for the first weeks at home."),
    scaleSetter: _en("The help that works is practical and specific. A "
        "partner who keeps the appointment diary does more than one who asks "
        "'how are you feeling' every evening. Pick two or three jobs from "
        "each list and do them well."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Pregnancy happens in her body, and the appointments fall in "
            "office hours. It's easy to feel like a bystander. You're not one "
            "if you take on tasks rather than wait to be asked."),
        _en("Read the list for the trimester you're in, and glance at the "
            "next one so nothing arrives as a surprise."),
      ]),
      PvReadSection(
        heading: _en('What can I do in the first trimester?'),
        bullets: [
          _en("Take over the cooking, or at least the frying, while smells "
              "set off her nausea. Keep biscuits by the bed and the water "
              "bottle full."),
          _en("Come to the first scan. Ask your manager for the morning "
              "early, since most scans are in office hours."),
          _en("Be the one who remembers the tablets her doctor has "
              "prescribed, like folic acid."),
          _en("Let her sleep. Tiredness can be heavy in these weeks. Take the "
              "early-morning tasks, and go easy on late evenings out."),
          _en("Agree together who is told, and when, and stick to it."),
          _en("Learn what's normal this early: tiredness, nausea and mood "
              "swings are common, and her doctor is the person for anything "
              "that worries either of you."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I do in the second trimester?'),
        bullets: [
          _en("Keep the appointment diary. Learn the names of the tests "
              "(anomaly scan, glucose test, growth scan) and the week each "
              "falls in, so the plan isn't carried in one head."),
          _en("Walk together in the evening. It's easier to keep up as a "
              "pair."),
          _en("Have the money conversation: what the hospital package covers, "
              "what insurance covers, and what leave each of you can take."),
          _en("Ask HR about your leave now, and get the answer in writing. "
              "Paternity leave isn't law for private jobs in India, so it "
              "needs asking for. Central government employees may get 15 "
              "days."),
          _en("Talk to your baby. From about 24 weeks your baby can hear "
              "voices, and will know yours at birth."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I do in the third trimester?'),
        bullets: [
          _en("Own the hospital route. Drive it in daylight and at night, "
              "and find where to park and which entrance is open at 3am."),
          _en("Own the folder and the bag, and put them by the door from about "
              "36 weeks. Keep the car filled with fuel, or save two cab apps "
              "as a backup."),
          _en("Learn the signs of labour and when to go in, so two people "
              "know them when it matters. 'Is labour near?' and 'When to go "
              "to hospital' on the labour door cover both."),
          _en("Come to the birth class if there is one. Knowing what to do "
              "with your hands changes what it's like to be in the room."),
          _en("Plan the first two weeks at home: who cooks, who sleeps when, "
              "who handles the visitors."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I help with food and sleep?'),
        paragraphs: [
          _en("Her appetite can change from week to week. She may go off "
              "foods she loved and crave others. Cook what she can eat this "
              "week, keep the fridge stocked with what works, and ask her "
              "doctor, not the internet, about tablets and supplements."),
          _en("Sleep gets harder as the bump grows. Help with extra pillows, "
              "take the early-morning jobs, keep the room comfortable, and "
              "don't wake her with your own late-night phone. A rested "
              "partner is a better helper too."),
        ],
      ),
      PvReadSection(
        heading: _en("What should I ask at her appointments?"),
        bullets: [
          _en("What are the dates of the scans and tests still to come?"),
          _en("Which hospital will the birth be in, and how many people can "
              "be with her in the room?"),
          _en("Which number do we call at night, and who answers it?"),
          _en("Which signs mean we come in straight away?"),
        ],
      ),
      PvReadSection(
        heading: _en('What if I can only do a little?'),
        paragraphs: [
          _en("Many partners work long hours or live far away. Do what you "
              "can, and say so plainly. One job done steadily beats five "
              "started and dropped."),
          _en("Phone her doctor's clinic to book the slot. Order the "
              "groceries. Be the one who reads the discharge papers. None of "
              "it needs you in the room, and all of it takes weight off "
              "her."),
        ],
        tip: PvReadTip(
          title: _en('Say what you can do'),
          body: _en("'I can't come on Tuesday, but I'll do every night "
              "feed on Saturday' is worth more than a promise you can't "
              "keep."),
        ),
      ),
    ],
    whenToSeeSomeone: _takeHerIn,
    faqs: [
      PvReadFaq(
        question: _en("I can't get leave for every appointment. What then?"),
        answer: _en("Choose the ones that matter most to you both, often the "
            "first scan and the anomaly scan, and take notes or ask her to "
            "call you from the clinic for the rest."),
      ),
      PvReadFaq(
        question: _en('Is there a free check-up day we can use?'),
        answer: _en("Under the Pradhan Mantri Surakshit Matritva Abhiyan, "
            "government health centres offer a free antenatal check-up on "
            "the 9th of every month, in the second and third trimesters."),
      ),
    ],
    evidence: _evPartner,
    readNext: [
      'preg_week_read_partner_support',
      'preg_partner_read_first_time_dad',
      'preg_work_read_paternity_leave',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Seven things before the baby comes
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_partner_read_first_time_dad',
    hue: _hue,
    kicker: _kForYou,
    title: _en('Seven things to do before the baby comes (first-time dads)'),
    teaser: _en("The hospital, the folder, help at home, the ride home, your "
        "leave, the first week's food, and one way to settle a baby."),
    shortAnswer: _en("Seven jobs cover most of it: know the hospital and "
        "the route, keep a documents folder, line up help at home, plan how "
        "you'll travel home, sort your leave, plan the first week's food, and "
        "learn one way to settle your baby. Start them in the last three "
        "months."),
    scaleSetter: _en("Nobody is ready for a first baby, and you don't need "
        "to be. You only need these seven done, and you can do one every "
        "weekend."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Most of the fear before a first baby comes from not knowing what "
            "to do when it begins. These seven jobs answer that. They're "
            "practical, and most take an hour or two."),
        _en("Read them with her, tick them off together, and tell her doctor "
            "anything you're unsure about."),
        _en("Nothing here replaces what her doctor tells you. Where the "
            "hospital has its own rules, follow them. The jobs are in the "
            "order that's easiest to do, not the order of importance."),
      ]),
      PvReadSection(
        heading: _en('1. Do you know the hospital and the way there?'),
        paragraphs: [
          _en("Go once in daylight and once at night. Find the entrance for "
              "the labour ward, where to park and which desk to go to. Time "
              "the trip in traffic. Ask the hospital how many people can be "
              "in the room, whether that's different at night or for a "
              "C-section, and save the labour ward number on paper and on "
              "your phone. In an emergency, dial 108."),
        ],
        tip: PvReadTip(
          title: _en('Have a backup'),
          body: _en("Keep the car filled with fuel from 36 weeks, or save "
              "two cab apps and a driver's number. Decide who looks after "
              "an older child or an elderly parent at short notice."),
        ),
      ),
      PvReadSection(
        heading: _en('2. Is the documents folder ready?'),
        paragraphs: [
          _en("Put these in one folder by about 36 weeks, and keep it by the "
              "door: her pregnancy file and antenatal card, the latest scan "
              "and blood reports with her blood group, photo ID such as "
              "Aadhaar, any insurance card, the hospital registration papers, "
              "a charger, some cash and her birth plan if she's written one."),
        ],
        tip: PvReadTip(
          title: _en('Two copies'),
          body: _en("Take a photo of each paper on your phone as well. If "
              "the folder stays in the car, you still have everything the "
              "desk asks for."),
        ),
      ),
      PvReadSection(
        heading: _en('3. Who will help at home?'),
        paragraphs: [
          _en("Talk it through before the birth, when everyone is calm. Decide "
              "who helps at night, who cooks, who looks after the house and "
              "any older child, and how many visitors to allow. If you plan "
              "paid help, book it by 32 to 34 weeks. You can be the one who "
              "tells relatives to keep visits short, so she doesn't have "
              "to."),
          _en("The first weeks often have a name and a rhythm at home, like "
              "jaapa or sawa mahina: rest, warm food and help from family. "
              "Much of it is wise. Agree in advance which parts you'll keep."),
        ],
      ),
      PvReadSection(
        heading: _en('4. How will you travel home?'),
        paragraphs: [
          _en("If you have a car, fit a rear-facing baby car seat in the back "
              "before the due date, and practise once or twice. In a cab, "
              "carry your own seat and fit it yourself. Don't use a "
              "second-hand seat unless you know its whole story. A newborn "
              "shouldn't travel on a scooter or motorbike. Some government "
              "hospitals offer free transport home, so ask before discharge."),
        ],
      ),
      PvReadSection(
        heading: _en('5. What will your leave look like?'),
        paragraphs: [
          _en("Ask HR early and get the answer in writing. Paternity leave "
              "isn't law for private jobs, so it depends on your company. "
              "Central government employees may get 15 days. Plan it for "
              "when she'll need you most, often straight after the birth, "
              "and set up a handover at work so you aren't answering calls "
              "with the baby in your arms."),
        ],
      ),
      PvReadSection(
        heading: _en('6. What will you eat in the first week?'),
        paragraphs: [
          _en("Warm, simple food and plenty of water help her recovery. Decide "
              "who cooks, stock dal, rice, vegetables and staples before the "
              "birth, and keep a few dishes she loves in mind. Nobody should "
              "be shopping in week one."),
        ],
      ),
      PvReadSection(
        heading: _en('7. Which one soothing skill will you learn?'),
        paragraphs: [
          _en("Pick one and get good at it: holding your baby skin to skin, "
              "burping, or rocking to sleep. Ask a nurse to show you before "
              "you leave hospital. If your baby cries and your patience is "
              "going, lay the baby down safely and take a minute. That "
              "isn't failing. It's what calm parents do."),
        ],
        tip: PvReadTip(
          title: _en('Start in the hospital'),
          body: _en("The nurses handle newborns every day. Ask one to show "
              "you how to hold your baby, burp the baby and change a "
              "nappy, and do it once while she watches."),
        ),
      ),
    ],
    whenToSeeSomeone: _takeHerIn,
    faqs: [
      PvReadFaq(
        question: _en("What if we only manage three of the seven?"),
        answer: _en("Start with the route, the folder and the help at home. "
            "Those three matter most on the day."),
      ),
      PvReadFaq(
        question: _en('Is there a read for the labour room itself?'),
        answer: _en("Yes. 'What your partner should do' on the labour door "
            "covers the room, the jobs in order and what to say."),
      ),
    ],
    evidence: _en('Ministry of Health and Family Welfare, Janani Shishu '
        'Suraksha Karyakram (JSSK) guidelines, on free transport home · WHO '
        'recommendations: intrapartum care for a positive childbirth '
        'experience (2018) · NICE guideline NG235, Intrapartum care (2023) · '
        'Central Civil Services (Leave) Rules, 1972 · UN ECE Regulations 44 '
        'and 129 (i-Size) on child restraints.'),
    readNext: [
      'preg_labour_read_partner',
      'preg_labour_read_when_to_go',
      'preg_ready_read_help',
      'preg_ready_read_buying_safely',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Feeding, before and after
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_partner_read_feeding',
    hue: _hue,
    kicker: _kForYou,
    title: _en('How you can help with feeding, before and after the birth'),
    teaser: _en("What to learn with her now, the night shifts you can take, "
        "food and water for her, and how to hold back unwanted advice."),
    shortAnswer: _en("You can do nearly everything except breastfeed. Before "
        "the birth, learn the basics with her. After it, bring water and "
        "food at every feed, take night jobs, burp and settle the baby, "
        "and keep advice she doesn't want away from her."),
    scaleSetter: _en("Feeding is a skill that she and your baby learn "
        "together in the first days. Most of the trouble in week one comes "
        "from not knowing what normal looks like. You can learn that too."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Breast milk is all your baby needs for the first six months, "
            "with no water, ghutti or honey. Some women can't breastfeed, or "
            "need to add formula, and that's never a failure. Her doctor "
            "will help her feed your baby well, whichever way it is."),
        _en("Either way, there's a lot for you to do."),
      ]),
      PvReadSection(
        heading: _en('What can I learn before the birth?'),
        bullets: [
          _en("What a good latch looks like: a wide mouth with plenty of "
              "breast in it, not just the nipple. It's what makes feeding "
              "comfortable."),
          _en("That newborns feed often, 8 to 12 times in 24 hours. It "
              "doesn't mean she has too little milk."),
          _en("That the first milk is colostrum, a small amount of thick, "
              "yellowish milk that is exactly what a newborn needs."),
          _en("Who to ask in hospital. Find out, at a visit, whether a "
              "feeding counsellor or nurse can help, and how to ask."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I do in the first hours?'),
        paragraphs: [
          _en("If she and the baby are well, your baby goes onto her bare "
              "chest for skin to skin, and most babies are ready for a first "
              "feed within the hour. Remind the nurse about skin to skin and "
              "the first feed if it's in her plan. Help her sit comfortably "
              "while the baby feeds. After a C-section, if she can't hold the "
              "baby yet, you can hold your baby skin to skin until she can."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I take night shifts?'),
        paragraphs: [
          _en("You can't breastfeed, but you can make every night feed "
              "easier."),
        ],
        bullets: [
          _en("Bring the baby to her, then change the nappy and burp the baby "
              "after the feed, so she can go straight back to sleep."),
          _en("To burp, hold your baby upright against your shoulder and pat "
              "or rub the back gently."),
          _en("Once feeding is going well, you can give a night feed with "
              "expressed milk, so she gets a longer stretch of sleep. Ask "
              "her doctor or the hospital nurse when to start."),
          _en("Settle the baby afterwards by rocking or skin to skin."),
        ],
      ),
      PvReadSection(
        heading: _en('What if she has had a C-section?'),
        paragraphs: [
          _en("She can still feed, often in the first hour in theatre or in "
              "recovery. Milk can take a little longer to come in, so feeding "
              "often and asking for help early matter. Side-lying and "
              "underarm holds keep the baby off her wound."),
          _en("Your part is the lifting. Pass her the baby, take the baby "
              "back, and put a pillow where she needs it. She'll be told not "
              "to lift anything heavier than the baby for about six weeks, "
              "so the nappy bags, the bucket and the shopping are yours."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I look after her while she feeds?'),
        paragraphs: [
          _en("Bring her water and something to eat at every feed. Keep the "
              "room calm, and keep visitors short. Watch her mood as well as "
              "the baby's. If she seems low for more than two weeks, help "
              "her talk to her doctor."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I protect her from advice she does not want?'),
        paragraphs: [
          _en("Everyone has an opinion on feeding. Give her one sentence to "
              "rely on: 'The doctor asked for breast milk only.' Then let "
              "her family know that ghutti, water and honey are not for a "
              "newborn, and that honey is unsafe for babies under a year."),
          _en("Keep criticism away from her, whichever way she feeds. A "
              "tired mother who is being judged feeds less well and sleeps "
              "less. You can be the one who says it to the relatives."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I know it is going well?'),
        paragraphs: [
          _en("Nappies are the easiest guide. Wet nappies go up by about one "
              "a day, until there are at least six a day from about day five. "
              "Most babies lose some weight in the first days, up to about a "
              "tenth of their birth weight, and are back to it by about two "
              "weeks. The baby doctor will weigh your baby and tell you if "
              "it's on track."),
          _en("A baby who wakes for feeds, has plenty of wet nappies and "
              "settles after most feeds is usually getting enough. If you're "
              "unsure, call the doctor. That's what the call is for."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your baby\'s doctor the same day if'),
      body: _en("Your baby isn't feeding at all, has fewer wet nappies than "
          "expected, is very sleepy and hard to wake for feeds, or looks "
          "yellow in the first day. Call too if she has a fever, or a hot, "
          "red, painful patch on her breast. Go to hospital now if your baby "
          "is floppy, blue around the lips, or breathing very fast or with "
          "grunting, or if she is soaking a pad in an hour."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('She is in pain when feeding. Is that normal?'),
        answer: _en("It can hurt at first, but it shouldn't keep hurting. Ask "
            "the nurse or her doctor to check the latch. It usually "
            "improves with small changes."),
      ),
      PvReadFaq(
        question: _en('What if she needs to use formula?'),
        answer: _en("It's never a failure. Her doctor will help her feed "
            "your baby well, and your job is to support her, not to judge."),
      ),
    ],
    evidence: _en('WHO / UNICEF Baby-Friendly Hospital Initiative (2018) and '
        'Ten Steps to Successful Breastfeeding · WHO infant and young child '
        'feeding guidance · Indian Academy of Pediatrics infant feeding '
        'guidelines · Ministry of Health and Family Welfare, Mothers\' '
        'Absolute Affection (MAA) programme (2016).'),
    readNext: [
      'preg_labour_read_bf_start',
      'preg_labour_read_feeding_help',
      'preg_labour_read_first_40',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Sympathy symptoms
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_partner_read_sympathy',
    hue: _hue,
    kicker: _kYourself,
    title: _en('Can you have pregnancy symptoms too?'),
    teaser: _en("Why some partners feel sick, tired or hungry along with "
        "her, what helps, and when to see a doctor yourself."),
    shortAnswer: _en("Yes. Some partners feel tired, queasy or sleep badly, "
        "or gain weight, while their partner is pregnant. It's common, it's "
        "usually stress and closeness, and there's nothing to be "
        "embarrassed about. See a doctor if it's severe or doesn't settle."),
    scaleSetter: _en("It has a name, sympathy pregnancy (couvade), and "
        "partners have reported it for a very long time. It isn't a "
        "sign that something is wrong with you, her or your baby."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("You might wake feeling queasy when she does. You might crave "
            "what she's craving, or notice your trousers are tighter. If "
            "you've been wondering whether you're imagining it, you're not."),
        _en("Plenty of partners feel something, and most keep quiet because "
            "it feels silly. It isn't. It's a sign that you're paying "
            "attention, and that the pregnancy has reached you too."),
      ]),
      PvReadSection(
        heading: _en('What can it feel like?'),
        bullets: [
          _en("Queasiness or a sensitive stomach, sometimes in the morning."),
          _en("Tiredness, even on a normal day."),
          _en("Changes in appetite, with cravings or eating more."),
          _en("Putting on weight, often because you're eating with her."),
          _en("Sleeping badly, or waking in the night."),
          _en("Backache, headache or toothache with no clear reason."),
          _en("Mood swings, feeling edgy or teary."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does it happen?'),
        paragraphs: [
          _en("Nobody knows exactly. The most likely reasons are ordinary "
              "ones. You're worried about her and the baby. You're sleeping "
              "less. You're eating the same food and keeping the same hours. "
              "And you're closer to her than ever, so her changes can echo "
              "in you."),
          _en("Stress can do a lot to a body: an unsettled stomach, broken "
              "sleep, a tight back. Your mind is busy with a very big change, "
              "and your body keeps it company."),
          _en("It doesn't mean you're making it up, and it doesn't mean "
              "you're taking anything from her. Her pregnancy is hers. This "
              "is your own body reacting to big news."),
        ],
      ),
      PvReadSection(
        heading: _en('Should I tell her?'),
        paragraphs: [
          _en("Yes, lightly, when it suits you both. Many women find it "
              "touching rather than funny, and it opens an easy talk about "
              "how each of you is feeling. She has enough to carry, so say "
              "it as a small thing you've noticed, not as a competition."),
        ],
      ),
      PvReadSection(
        heading: _en('When does it show up?'),
        paragraphs: [
          _en("Some partners notice it early, when the news is new and she's "
              "unwell. Others feel it more near the birth, as nerves build. "
              "It usually settles once the baby is here. There's no set "
              "pattern, and not having it says nothing about how much you "
              "care."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the weight I have put on?'),
        paragraphs: [
          _en("It's common when you're eating together, snacking for comfort "
              "and sleeping badly. Go gently: regular meals, an evening walk "
              "and enough sleep. Skip crash diets. Her doctor guides her "
              "food, not yours, and your own doctor can help with yours."),
        ],
      ),
      PvReadSection(
        heading: _en('What if people tease me?'),
        paragraphs: [
          _en("Friends and relatives may joke about it. You can laugh along "
              "and leave it there, or say it's not a joke to you. You don't "
              "have to explain it. If a symptom is making work or sleep hard, "
              "that's a health question, and it's fair to treat it like "
              "one."),
        ],
        tip: PvReadTip(
          title: _en('A one-line answer'),
          body: _en("'Bit of a sympathy pregnancy, it seems' is enough. "
              "Then change the subject. You owe no one a longer answer, and "
              "a calm reply ends most teasing quickly."),
        ),
      ),
      PvReadSection(
        heading: _en('What helps?'),
        bullets: [
          _en("Mention it to her once, as above, and then let it be."),
          _en("Eat regular meals and drink water, so you aren't both "
              "snacking for comfort."),
          _en("Protect your sleep. Go to bed at a fixed time, and put the "
              "phone away."),
          _en("Walk with her in the evening. It's good for both of you."),
          _en("Talk about what's worrying you, to her or to a friend. Feelings "
              "you don't say often show up in the body."),
        ],
        tip: PvReadTip(
          title: _en('Her symptoms come first'),
          body: _en("If you're both queasy, let her have the quieter room "
              "and the first plate. Yours can wait."),
        ),
      ),
      PvReadSection(
        heading: _en('When should I see a doctor myself?'),
        paragraphs: [
          _en("Go if a symptom is severe, keeps getting worse, or doesn't "
              "settle over a few weeks. Go if you're losing weight without "
              "meaning to, or can't keep food down. Symptoms can have "
              "ordinary causes that have nothing to do with the pregnancy, "
              "and you deserve the same care you'd give her."),
          _en("Go too if you feel low most days, or worry so much that you "
              "can't sleep or work. That's not something to carry alone, "
              "and a doctor or counsellor can help."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('See a doctor yourself, the same day, if'),
      body: _en("You have chest pain, breathlessness, fainting, or a severe "
          "headache, whatever you think the cause is. See your doctor within "
          "a few days if symptoms keep getting worse, or if you've felt low "
          "most days for two weeks. If you have any thought of harming "
          "yourself, call Tele-MANAS on 14416, free, day and night, or 112 "
          "if you're in danger now."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is it a sign something is wrong with the baby?'),
        answer: _en("No. It says something about you and how close you are to "
            "her, not about your baby. Her doctor's check-ups are what tell "
            "you how the pregnancy is going."),
      ),
      PvReadFaq(
        question: _en('Does it go away after the birth?'),
        answer: _en("For most partners it settles once the baby is here, or "
            "sooner. If it doesn't, or you feel low, tell a doctor."),
      ),
    ],
    evidence: _en('Brennan and colleagues, Journal of Reproductive and '
        'Infant Psychology (2007), a review of couvade syndrome · NICE '
        'guideline CG192, Antenatal and postnatal mental health (2014, '
        'updated 2020) · Tele-MANAS details from the Ministry of Health and '
        'Family Welfare, Government of India.'),
    readNext: [
      'preg_partner_read_your_feelings',
      'preg_week_read_partner_support',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  His own feelings
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_partner_read_your_feelings',
    hue: _hue,
    kicker: _kYourself,
    title: _en('Your own feelings in her pregnancy'),
    teaser: _en("Worry, money, feeling left out, fear of the birth and "
        "what's changing between you, and who to talk to."),
    shortAnswer: _en("Worry, pride, fear and feeling left out are all "
        "normal for a partner. Say them to someone you trust, and to her "
        "when it's a calm moment. If you feel low for weeks, tell a doctor "
        "or a counsellor. You don't have to carry it alone."),
    scaleSetter: _en("In many Indian homes the husband is expected to "
        "handle everything and feel nothing. That's a heavy thing to carry. "
        "Partners also get less sleep, more worry and no appointments of "
        "their own."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Most of what's written in pregnancy is for her, and so are most "
            "of the appointments. It's easy to feel that your feelings "
            "don't count. They do."),
        _en("This read names the common ones, so they feel less strange."),
      ]),
      PvReadSection(
        heading: _en('Is it normal to feel worried?'),
        paragraphs: [
          _en("Yes. You might worry about her health, about the baby, about "
              "whether you'll be a good father. Worry shows how much you "
              "care. It's most useful when you turn it into a small job: a "
              "question for the doctor, a route you'll check, a folder you'll "
              "fill."),
        ],
      ),
      PvReadSection(
        heading: _en('What about money?'),
        paragraphs: [
          _en("Money worries land hardest on the partner who sees himself as "
              "the earner. Write down what you know, talk it through with "
              "her once a week rather than every evening, and ask about "
              "leave and insurance early. The work door has reads on the "
              "cost of a delivery and on government schemes."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I feel left out?'),
        paragraphs: [
          _en("The bump, the kicks and the fuss are all around her. You can "
              "feel like a visitor in your own pregnancy. Come to a scan. "
              "Talk to your baby from about 24 weeks. Take one job "
              "completely. The closeness you want usually comes from doing "
              "things together."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I am excited and she is anxious?'),
        paragraphs: [
          _en("You can be in different places on the same day. Try not to "
              "talk her out of her worry or match it. Ask what's on her mind, "
              "listen to the whole answer, and share your excitement "
              "gently. Both feelings belong in the room."),
        ],
      ),
      PvReadSection(
        heading: _en('What if the family puts pressure on me?'),
        paragraphs: [
          _en("Elders may have firm views on what she should eat, where she "
              "should deliver and what you should be doing. You may feel "
              "caught between them and her. Agree with her the two or three "
              "things that aren't up for debate, like the tablets, the scans "
              "and the hospital, and then be the one who says so calmly. "
              "'The doctor said' is a good sentence to have ready."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I ask for help at work?'),
        paragraphs: [
          _en("Yes. Tell your manager about the due date in good time, ask "
              "about leave early, and plan a handover. If you're running on "
              "little sleep, say so to someone you trust at work. Most "
              "managers have been through it, or will."),
        ],
      ),
      PvReadSection(
        heading: _en('What if the birth frightens me?'),
        paragraphs: [
          _en("Many partners are scared of seeing her in pain, of "
              "something going wrong, or of not knowing what to do. Fear "
              "eases with knowing. Read 'What your partner should do' on the "
              "labour door, and ask the hospital what to expect. If you think "
              "you might feel faint, say so to the nurse. It happens, and "
              "they'll help."),
        ],
      ),
      PvReadSection(
        heading: _en('Will things change between us?'),
        paragraphs: [
          _en("They will, and that's a fact of a baby, not a fault in you. "
              "You'll have less time alone, less sleep and less certainty. "
              "Closeness and sex may change, and you may not feel ready at "
              "the same time. Set aside ten minutes a day to check in, and "
              "be patient with each other."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I feel fine, or even happy, while she struggles?'),
        paragraphs: [
          _en("That's normal too. Feeling good doesn't make you a poor "
              "partner, and feeling guilty about it doesn't help her. Let "
              "your good mood be useful: cook, book, carry and listen."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I do with a worry today?'),
        bullets: [
          _en("Write it down in a line, so it stops going round your head."),
          _en("Decide if it's a question for her doctor, a job for you, or "
              "something you can't settle yet."),
          _en("If it's a question, put it in the note on your phone for the "
              "next visit. If it's a job, do it this week."),
          _en("If it can't be settled, tell someone you trust and go for a "
              "walk."),
        ],
      ),
      PvReadSection(
        heading: _en('Who can I talk to?'),
        paragraphs: [
          _en("Choose one or two people: a friend, a brother, a colleague you "
              "trust. Many men find it easier to talk side by side, on a walk "
              "or a drive, than face to face. You can also tell her. She'd "
              "rather know than guess."),
          _en("If you feel low most days for two weeks, lose interest in "
              "things, drink more than usual or can't sleep even when you "
              "could, see a doctor or a counsellor. Tele-MANAS is free on "
              "14416, day and night, and it's for you too."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Get help today if'),
      body: _en("You have any thought of harming yourself, or feel you can't "
          "keep yourself safe. Call Tele-MANAS on 14416 (or 1-800-891-4416), "
          "free, day and night, or 112 if you're in danger now. Tell a doctor "
          "this week if you've felt low, numb or hopeless, or haven't been "
          "able to sleep or eat, for more than two weeks."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should I tell her I am scared?'),
        answer: _en("Usually yes, at a calm time, in a sentence or two. It "
            "tells her she isn't alone, and she may be feeling the same."),
      ),
      PvReadFaq(
        question: _en('Can fathers get depressed too?'),
        answer: _en("Yes. Partners can feel very low during pregnancy and "
            "after the birth. It's worth raising with a doctor, and it's "
            "never a sign of weakness."),
      ),
    ],
    evidence: _en('Paulson and Bazemore, Journal of the American Medical '
        'Association (2010), prenatal and postpartum depression in fathers · '
        'NICE guideline CG192, Antenatal and postnatal mental health (2014, '
        'updated 2020) · Tele-MANAS details from the Ministry of Health and '
        'Family Welfare, Government of India.'),
    readNext: [
      'preg_partner_read_sympathy',
      'preg_partner_read_couple_questions',
      'preg_week_read_partner_support',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Questions to ask each other
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_partner_read_couple_questions',
    hue: _hue,
    kicker: _kTogether,
    title: _en('Questions to ask each other'),
    teaser: _en("Twelve warm questions for the two of you, about the baby, "
        "the first weeks, home and what you hope for."),
    shortAnswer: _en("Twelve questions to ask each other while you wait: "
        "light ones about names and hopes, practical ones about the first "
        "weeks, and gentle ones about what scares you. There are no right "
        "answers. Pick one a week."),
    scaleSetter: _en("Couples often plan the cot and skip the conversation. "
        "These questions take five minutes each, and they help you know what "
        "the other one is picturing."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("There are no right answers here. You don't have to agree, and "
            "you don't have to finish in one evening. Pick one a week, ask it "
            "over tea or on a walk, and listen to the whole answer before "
            "you give yours."),
        _en("If a question brings up something hard, that's useful too. Come "
            "back to it another day. The aim isn't to have a perfect plan. "
            "It's to know each other a little better before the baby "
            "arrives, and to have had a few good evenings along the way."),
      ]),
      PvReadSection(
        heading: _en('What are we looking forward to?'),
        bullets: [
          _en("What are you most looking forward to?"),
          _en("What names do you like, and what do the names mean to you?"),
          _en("What's one thing you'd like to do with the baby in the first "
              "year?"),
          _en("What do you want your baby to hear in our house, every day?"),
        ],
      ),
      PvReadSection(
        heading: _en('What do we want the first weeks to look like?'),
        bullets: [
          _en("What do you want the first week to look like, at home and in "
              "hospital?"),
          _en("Who do we both want around, and who do we want to visit later?"),
          _en("What will you do in the night, and what will you need from "
              "me?"),
          _en("What would make the first month easier for you?"),
        ],
      ),
      PvReadSection(
        heading: _en('What scares us, and what would we do differently?'),
        bullets: [
          _en("What scares you most about the birth, or about being a parent?"),
          _en("What would help you feel less scared?"),
          _en("What do you want to do differently from your own childhood?"),
          _en("What do you want to keep exactly the same?"),
        ],
        tip: PvReadTip(
          title: _en('Ask in the car or on a walk'),
          body: _en("Many people find it easier to talk side by side than "
              "across a table. A short walk or a drive works well."),
        ),
      ),
      PvReadSection(
        heading: _en('Why ask at all?'),
        paragraphs: [
          _en("Most of what you each picture is never said out loud. One of "
              "you imagines grandparents in the house for a month. The other "
              "imagines the three of you alone. Plans made over tea are "
              "easier than plans made on no sleep, and a question asked "
              "kindly now saves a sharp word later."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we pick one a week?'),
        paragraphs: [
          _en("Choose a regular moment, such as Sunday tea or the evening "
              "walk. Take turns to choose the question. Start with a light "
              "one, like names or what you're looking forward to, and leave "
              "the harder ones for a week when you both feel rested."),
          _en("Keep the answers if you'd like to. Some couples jot a line in "
              "a notebook. Look at it again when your baby is a month old, "
              "and see what stayed the same and what changed."),
        ],
      ),
      PvReadSection(
        heading: _en('What do we do with the answers?'),
        paragraphs: [
          _en("Use them to plan, not to win. If you both want your mothers "
              "around in the first fortnight, plan it. If one of you wants "
              "quiet, agree how you'll say so kindly. If you don't know yet, "
              "say that. Some answers will only arrive after the baby does, "
              "and that's fine."),
        ],
      ),
      PvReadSection(
        heading: _en('What if we answer differently?'),
        paragraphs: [
          _en("You will, sometimes. Different answers aren't a problem. "
              "They're what you're finding out. Try saying back what you "
              "heard before you reply: 'So you'd like your mother here for "
              "the first two weeks.' It helps each of you feel heard."),
          _en("If a topic gets tense, such as family, money or names, leave "
              "it for another day. You have months."),
          _en("If you notice you're the one asking every time, say so kindly. "
              "Take turns to choose, and to listen first. The questions are "
              "an invitation, not an exam, and either of you can say 'pass' "
              "and come back later."),
        ],
      ),
      PvReadSection(
        heading: _en('What if one of us would rather not talk?'),
        paragraphs: [
          _en("That's fine. Some people take longer to find words. Offer the "
              "question, and tell them they can answer tomorrow. Some find it "
              "easier to write a reply in a message. Others prefer a walk."),
          _en("If it's always hard to talk about the baby, or about how each "
              "of you feels, it's worth telling her doctor or a counsellor. "
              "It's a small step, and many couples say they wish they'd "
              "taken it sooner."),
        ],
      ),
    ],
    whenToSeeSomeone: _takeHerIn,
    faqs: [
      PvReadFaq(
        question: _en('Do we have to decide names now?'),
        answer: _en("No. Many families wait until after the birth, and some "
            "keep the name until the naamkaran. The question is about what "
            "you each like, not about settling it."),
      ),
      PvReadFaq(
        question: _en('What if she would rather talk to her mother or a '
            'friend?'),
        answer: _en("That's fine. She can do both. Keep asking, so she knows "
            "you want to know."),
      ),
    ],
    evidence: _evPartner,
    readNext: [
      'preg_ready_read_choosing_name',
      'preg_partner_read_your_feelings',
      'preg_ready_read_help',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  If the pregnancy ends
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_partner_read_after_loss_partner',
    hue: _hue,
    kicker: _kLoss,
    title: _en('If the pregnancy ends: how to be there'),
    teaser: _en("For a partner whose pregnancy has ended: how she may grieve "
        "differently, what to say, what to take off her, and looking after "
        "yourself."),
    shortAnswer: _en("We're so sorry. She may grieve differently from you, "
        "and both ways are real. Stay close, say little and mean it, take "
        "practical jobs off her, and look after yourself too. There's no "
        "right way to grieve."),
    scaleSetter: _en("This page is written to you, her partner, whether the "
        "pregnancy ended early or later. It was your baby as well. You don't "
        "need to read it all today."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("We're so sorry. Whatever the number of weeks, this was a loss "
            "for you both."),
        _en("You may be trying to stay strong for her and not knowing what "
            "to do with your own sadness. This read is here for both."),
      ]),
      PvReadSection(
        heading: _en('Will she grieve the way I do?'),
        paragraphs: [
          _en("Often not, and neither of you is getting it wrong. Her body "
              "has been through it, and she may feel it as a loss of a whole "
              "picture: a name, a due date, a place in the home. You may "
              "grieve more privately, or by keeping busy, or later."),
          _en("Some men grieve by doing: fixing things, working, handling "
              "the hospital. That's a real way of grieving. She may read "
              "your silence as not caring, so it helps to say it once: "
              "'I'm sad too.'"),
        ],
      ),
      PvReadSection(
        heading: _en('What might I be feeling?'),
        bullets: [
          _en("Helplessness, watching her in pain and not being able to fix "
              "it."),
          _en("Sadness you feel you have to hide."),
          _en("Fear for her health, especially after heavy bleeding or "
              "surgery."),
          _en("Anger, at the doctors, the timing or yourself."),
          _en("Guilt, about going back to work, or about feeling better "
              "sooner than she does."),
        ],
      ),
      PvReadSection(
        heading: _en('What if the pregnancy ended later on?'),
        paragraphs: [
          _en("After a later loss or a stillbirth there's more to handle: the "
              "hospital stay, the paperwork and the rites your family keeps "
              "for the baby. If you can, take these on, and ask a brother or "
              "a friend to help you."),
          _en("You may be asked about seeing your baby, photos or tests. You "
              "can decide together, and you can ask the staff for time."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I say?'),
        bullets: [
          _en("'I'm so sorry. I'm here.'"),
          _en("'This isn't your fault, and it isn't mine.'"),
          _en("'Do you want to talk, or would you rather I just stay with "
              "you?'"),
          _en("'I'm sad too.'"),
          _en("Or nothing at all. Sitting beside her is enough."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I not say?'),
        bullets: [
          _en("Anything that looks for a reason, like 'you were working too "
              "hard'."),
          _en("Anything that makes her feel she should feel better already."),
          _en("'It was God's will', unless she says it first."),
          _en("Plans for another baby. If she brings it up, listen."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I take off her?'),
        bullets: [
          _en("The phone calls and messages. Tell the family what happened, "
              "so she doesn't have to say it again and again."),
          _en("The hospital, the papers, the chemist and the bills."),
          _en("Visitors, questions and advice she isn't ready for, even from "
              "your own family."),
          _en("Meals, water and rest. If the baby was born later in "
              "pregnancy, her body is recovering from a birth, with "
              "bleeding for weeks and milk that may come in."),
          _en("Watching for warning signs. Take her to hospital straight "
              "away if she has heavy bleeding, a fever, severe pain or feels "
              "faint."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I look after myself?'),
        paragraphs: [
          _en("You're allowed to grieve. Talk to a friend, a brother or a "
              "colleague you trust. Many men find it easier to talk side by "
              "side, on a walk or a drive. Eat, sleep when you can, and ask "
              "your manager about a few days of leave."),
          _en("If your family expects you back at normal in a day or two, "
              "you can say you're sad too and need a little time. If people "
              "ask what went wrong, you can say: 'The doctors say nothing "
              "anyone did caused it. Please don't ask her about it.'"),
        ],
      ),
      PvReadSection(
        heading: _en('Is there a right way to grieve?'),
        paragraphs: [
          _en("No. Grief comes in waves. A good week can be followed by a "
              "hard day, for either of you. Hard dates may come back, like "
              "the due date. Put them in your calendar and plan them "
              "together."),
        ],
      ),
      PvReadSection(
        heading: _en('Where can we find more help?'),
        paragraphs: [
          _en("ParentVeda has an After a loss section, with reads for both of "
              "you. 'For her partner: your grief too' is written to you, and "
              "'Telling family, and what people will say' helps with the "
              "calls. Her own doctor is the person for her body, her "
              "recovery and any questions about what happened. You can go "
              "with her and ask your own."),
          _en("If either of you feels low for weeks, or can't cope, please "
              "tell a doctor or a counsellor. Tele-MANAS is free on 14416, "
              "day and night."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Get help today if'),
      body: _en("Either of you has any thought of harming yourself, or feels "
          "you can't stay safe. Call Tele-MANAS on 14416 (or 1-800-891-4416), "
          "free, day and night, or 112 if someone is in danger now. Tell a "
          "doctor this week if either of you has felt low, numb or hopeless, "
          "or hasn't been able to sleep or eat, for more than two weeks. For "
          "her body: heavy bleeding, fever, severe pain or feeling faint mean "
          "going to hospital straight away."),
    ),
    faqs: [
      PvReadFaq(
        question: _en("She doesn't want to talk. What do I do?"),
        answer: _en("Stay near, and let her know you'll listen whenever she's "
            "ready. Small acts count: a cup of tea, a quiet evening, taking "
            "a call for her."),
      ),
      PvReadFaq(
        question: _en('When should I go back to work?'),
        answer: _en("When you both feel it's okay. Some couples need a few "
            "days together first."),
      ),
    ],
    evidence: _en('WHO, Why we need to talk about losing a baby (2019) · NICE '
        'guideline CG192, Antenatal and postnatal mental health (2014, '
        'updated 2020) · Tele-MANAS details from the Ministry of Health and '
        'Family Welfare, Government of India.'),
    readNext: [
      'preg_loss_read_his_grief',
      'preg_loss_read_grief',
      'preg_loss_read_telling_family',
      'preg_loss_read_someone_to_talk',
    ],
  ),
];
