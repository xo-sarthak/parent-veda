// =============================================================================
//  Your first weeks: the reads behind the door
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Your first weeks", P2: *"The first week she uses
//  the app is thin."* These are our own versions of what a woman needs between
//  a positive test and her first scan, written for India, in the pregnancy
//  voice (`docs/PREG-VOICE.md`), never Flo's or What to Expect's sentences.
//
//  Every read here sits on a tile of `kFirstWeeksDoor`
//  (`pv_door_first_weeks.dart`); `test/pv_door_first_weeks_test.dart` fails if
//  one is orphaned.
//
//  ⚠️ WHAT THIS FILE DOES NOT WRITE. The first antenatal visit itself
//  (`preg_scan_read_first_visit`), the hCG explainer
//  (`preg_scan_read_early_bloods`), morning sickness and the first trimester
//  (`preg_week_read_*`) already exist. So do "Telling your boss you're
//  pregnant" (`preg_work_read_telling_your_boss`, Work & money) and "Getting
//  an older child ready for the baby" (`preg_ready_read_older_child`, Getting
//  ready), both written in parallel on 2026-09-29. The door opens those; these
//  reads go around them and point to them in words.
//
//  ⚠️ THE CLINICAL LINE THIS FILE HOLDS
//
//  · The early-pregnancy hospital signs (heavy bleeding, one-sided pain,
//    shoulder-tip pain, fainting, fever) live in ONE callout, `_goNow`, used
//    by every early-worry read, so no two reads can drift apart on them. They
//    match the call-now lines on the ectopic and miscarriage condition pages.
//  · Never a personal probability. Population numbers only, and no sentence
//    puts "your" beside a chance word (the door test scans every string).
//  · Nothing about learning the baby's sex (PCPNDT Act). The family read
//    answers the "boy or girl" question by saying no one will tell.
//  · Legal and money lines say "you may be entitled to" and "check with your
//    HR", with the Act named. Each is listed in the build report for a check.
//  · `reviewed: false`, ParentVeda editorial, until a clinician has read them.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The Your first weeks bracket's own hue (`pregnancy_brackets.dart`), so a
/// read opened from the door keeps the door's colour.
const double _hue = 200;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('Your first weeks');
final LocalizedText _kFound = _en('Just found out');
final LocalizedText _kVisit = _en('Your first visit');
final LocalizedText _kWorry = _en('Early worries');
final LocalizedText _kTell = _en('Telling people');

/// The early-pregnancy hospital signs, in one place. The same five signs as
/// the door's pinned flag (`kFirstWeeksFlag`), in sentences.
final PvCallout _goNow = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Go to hospital straight away if'),
  body: _en("You're bleeding heavily (soaking a pad in an hour or less, or "
      "passing clots), you have sharp pain low down on one side or severe "
      "pain in your tummy, or you have pain at the tip of your shoulder. Go "
      "too if you feel faint or dizzy, you pass out, or you have a fever of "
      "38°C or more with pain or bleeding. If you can't get there safely, "
      "call 108 for an ambulance. For a fever on its own, any spotting, or "
      "vomiting that stops you keeping fluids down, call your doctor today."),
);

/// The Telling people reads' call line: her body first, then the pressure
/// of telling, then safety at home.
final PvCallout _tellCall = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Please get help straight away if'),
  body: _en("You have heavy bleeding, sharp pain on one side of your tummy, "
      "pain at the tip of your shoulder, a fever with pain or bleeding, or you "
      "feel faint. Go to hospital, or call 108. If telling people, or keeping "
      "it quiet, leaves you low or panicky most days, tell your doctor, or "
      "call Tele-MANAS free on 14416 at any hour. If anyone at home hurts or "
      "threatens you, call the women's helpline on 181, or 112 in an "
      "emergency."),
);

final List<PvRead> kPregnancyReadsFirst = [
  // ===========================================================================
  //  JUST FOUND OUT
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  What to do this week
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_this_week',
    hue: _hue,
    kicker: _kFound,
    title: _en("You're pregnant: what to do this week"),
    teaser: _en("The few things worth doing now, the ones that can wait, and "
        "how to register your pregnancy."),
    shortAnswer: _en("Start folic acid if you haven't already, and stop "
        "alcohol, smoking and all tobacco. Keep taking any regular medicine "
        "until a doctor has checked it. Then book your first antenatal visit "
        "and register your pregnancy, which gets you your Mother and Child "
        "Protection card."),
    scaleSetter: _en("What matters this week fits on one short list. If you "
        "had a drink or took a tablet before you knew, you're far from alone, "
        "and a small amount before you knew is unlikely to have caused harm. "
        "What counts is what you do from today."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("A positive test can bring joy, shock and fear within the same "
              "minute. Whatever you feel is allowed. You don't need to have "
              "it all worked out today."),
          _en("Your body has already started the work. By the time a test "
              "turns positive you're usually about four weeks pregnant, "
              "because pregnancy is counted from the first day of your last "
              "period. This week needs only a few steady steps."),
        ],
      ),
      PvReadSection(
        heading: _en('Which tablets should I start?'),
        paragraphs: [
          _en("Folic acid, every day. It helps your baby's brain and spine "
              "form properly in these first weeks. The usual dose is 400 "
              "micrograms a day, from now until at least 12 weeks. If you "
              "haven't been taking it, start today. Starting now still helps."),
          _en("Some women need a higher dose, for example if you have "
              "diabetes, take medicine for epilepsy, or had an earlier "
              "pregnancy affected by a spine problem. Many doctors in India "
              "prescribe a 5 mg tablet. Take the dose your doctor gives you."),
          _en("Folic acid is free at government health centres, and your ASHA "
              "worker can bring it to you. Iron and calcium usually start "
              "after the first three months, when your doctor says. Don't add "
              "other supplements or herbal mixes on your own. High doses of "
              "vitamin A, for example, aren't safe in pregnancy."),
        ],
        tip: PvReadTip(
          title: _en('If the tablet makes you feel sick'),
          body: _en("Take it at night, with a little food. Folic acid is the "
              "one to keep going if you can only manage one."),
        ),
      ),
      PvReadSection(
        heading: _en('What should I stop today?'),
        bullets: [
          _en("Alcohol. There's no amount known to be safe in pregnancy, so "
              "the advice is none at all."),
          _en("Smoking and all tobacco: cigarettes, bidis, gutka, khaini, and "
              "paan or supari with tobacco in it. Stay away from other "
              "people's smoke where you can. The free National Tobacco "
              "Quitline on 1800-11-2356 can help you stop."),
          _en("Too much caffeine. Keep it under 200 mg a day, which is about "
              "two small cups of coffee. Tea and cola count too."),
          _en("Raw or undercooked meat, fish and eggs, and milk that hasn't "
              "been boiled or pasteurised. Wash fruit and vegetables well."),
          _en("Very hot baths, saunas and steam rooms."),
        ],
        paragraphs: [
          _en("Tell anyone who offers you an X-ray, dental treatment or a new "
              "medicine that you're pregnant. The Nutrition section has much "
              "more on eating well now."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the medicines I already take?'),
        paragraphs: [
          _en("Please don't stop a regular medicine on your own. Tablets for "
              "thyroid, epilepsy, blood pressure, diabetes, asthma or low mood "
              "often need to carry on, and stopping suddenly can do more harm "
              "than good. Some need a change of dose or a switch to another "
              "medicine. Call the doctor who prescribes them this week and "
              "say you're pregnant."),
          _en("For a headache or a fever, paracetamol is the usual choice in "
              "pregnancy. Avoid ibuprofen and similar painkillers unless your "
              "doctor says otherwise. Ayurvedic and herbal medicines count as "
              "medicines too, so ask about those as well. A chemist can check "
              "a label in a minute, and the Is it safe? section answers many "
              "everyday questions."),
        ],
      ),
      PvReadSection(
        heading: _en('When should I see a doctor?'),
        paragraphs: [
          _en("Book your first antenatal visit now. Most women are seen "
              "between 8 and 12 weeks. Go sooner if you have pain or bleeding, "
              "a health condition, an earlier ectopic pregnancy, or if this "
              "pregnancy came through IVF."),
          _en("If you already have a gynaecologist, call their clinic. If you "
              "don't, a government health centre or your ASHA worker can see "
              "you and guide you. There's a read on this door about choosing "
              "a doctor and a hospital, and you can change later if you want "
              "to."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I register my pregnancy?'),
        paragraphs: [
          _en("The Ministry of Health and Family Welfare asks every woman to "
              "register her pregnancy within the first 12 weeks. You can do "
              "it at a government health centre or sub-centre, or through "
              "your ASHA worker, ANM or anganwadi. They'll usually ask for "
              "an ID such as Aadhaar."),
          _en("When you register, you get a Mother and Child Protection card "
              "(the MCP card). It records every visit, test and injection in "
              "your pregnancy, and later your baby's growth and vaccines. "
              "Carry it to every appointment."),
          _en("Registering also opens the free care you may be entitled to: "
              "tests, tablets and vaccines, a free delivery in a government "
              "hospital under the Janani Shishu Suraksha Karyakram (JSSK), and "
              "cash benefit schemes such as the Pradhan Mantri Matru Vandana "
              "Yojana (PMMVY). Who qualifies for the cash schemes varies, so "
              "ask your ASHA worker or health centre. You can register even "
              "if you see a private doctor too."),
        ],
      ),
      PvReadSection(
        heading: _en('What can wait?'),
        paragraphs: [
          _en("A lot. You don't need to buy anything for the baby yet, plan "
              "the birth, or decide on names. Telling people can wait until "
              "you're ready. Maternity leave forms come much later."),
          _en("If the list in your head feels long, keep only three things "
              "for this week: folic acid, no alcohol or tobacco, and a call to "
              "book your visit. Everything else has time."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en("I had a few drinks before I knew. Have I harmed my "
            "baby?"),
        answer: _en("It's very unlikely. Many women drink before they know "
            "they're pregnant. Stop now, and tell your doctor at your first "
            "visit so it's on your record."),
      ),
      PvReadFaq(
        question: _en("I haven't taken any folic acid. Is it too late?"),
        answer: _en("No. Start today and keep going until at least 12 weeks, "
            "or for as long as your doctor advises. It still helps."),
      ),
      PvReadFaq(
        question: _en('Can I carry on working?'),
        answer: _en("Usually, yes. If your work involves heavy lifting, "
            "chemicals, radiation or long hours on your feet, ask your doctor "
            "at your first visit. The read on telling your boss has more."),
      ),
      PvReadFaq(
        question: _en('Should I take a second pregnancy test to be sure?'),
        answer: _en("A clear positive on a home test is reliable. Your doctor "
            "will confirm it, often with a blood test or a scan."),
      ),
    ],
    evidence: _en('Ministry of Health and Family Welfare, antenatal care '
        'guidance and the Mother and Child Protection Card · Janani Shishu '
        'Suraksha Karyakram (JSSK) · Pradhan Mantri Matru Vandana Yojana '
        'guidelines, Ministry of Women and Child Development · National '
        'Tobacco Quitline Services, MoHFW · WHO recommendations on antenatal '
        'care for a positive pregnancy experience (2016) · NICE guideline '
        'NG201, Antenatal care (2021).'),
    readNext: [
      'preg_first_read_due_date',
      'preg_first_read_choosing_care',
      'preg_first_read_visit_questions',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Due date
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_due_date',
    hue: _hue,
    kicker: _kFound,
    title: _en('Working out your due date'),
    teaser: _en("How your due date is counted, why an early scan is more "
        "exact, and which date ParentVeda follows."),
    shortAnswer: _en("Your due date is usually counted as 40 weeks from the "
        "first day of your last period. A dating scan in the first three "
        "months is more exact, so if a scan or your doctor gives you a date, "
        "that's the one to use, and it's the one ParentVeda follows. Most "
        "babies come in the weeks around it, not on the day."),
    scaleSetter: _en("A due date is a best guess, not an appointment. It "
        "helps your doctor time your tests and scans. Your baby will choose "
        "the day."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Pregnancy weeks confuse almost everyone at first. They're "
              "counted from the first day of your last period, not from the "
              "day you conceived. So in the first two weeks of \"pregnancy\", "
              "you weren't pregnant yet, and when your period is a week late "
              "you're already about five weeks along."),
          _en("Doctors count this way because the first day of a period is "
              "a date most women know, and the day of conception usually "
              "isn't."),
        ],
      ),
      PvReadSection(
        heading: _en('How is the date worked out?'),
        paragraphs: [
          _en("Take the first day of your last period and add 280 days, which "
              "is 40 weeks, or about nine months and a week. A last period "
              "that began on 1 March gives a due date in the first week of "
              "December."),
          _en("This count assumes a cycle of about 28 days, with the egg "
              "released around day 14. If your cycles are usually longer or "
              "shorter, the real date may shift by a few days or more."),
        ],
      ),
      PvReadSection(
        heading: _en("What if my periods are irregular, or I don't remember?"),
        paragraphs: [
          _en("That's very common. You may have long or uneven cycles, PCOS, "
              "or have stopped the pill or been breastfeeding recently. Or you "
              "may not have noted the date. None of this is a problem."),
          _en("A dating scan answers it. In the first three months, babies "
              "grow at almost the same rate, so measuring your baby's length "
              "on a scan tells your doctor how many weeks along you are. Your "
              "doctor will usually send you for one between about 7 and 13 "
              "weeks."),
        ],
      ),
      PvReadSection(
        heading: _en('What do "weeks and days" mean?'),
        paragraphs: [
          _en("Doctors write how far along you are as weeks plus days, such "
              "as 9w3d or 9+3. That means nine weeks and three days. Your "
              "report may call it gestational age, or GA."),
          _en("Families often count in months (\"she's in her third "
              "month\"), and doctors count in weeks because it's more exact. "
              "The first trimester runs to the end of week 13, the second "
              "from week 14 to 27, and the third from week 28 until your baby "
              "comes."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does the scan date come first?'),
        paragraphs: [
          _en("An early scan is usually accurate to within about a week. "
              "Counting from a period can be further out, because cycles and "
              "memories vary. So when the two disagree by more than a few "
              "days, doctors usually go with the scan."),
          _en("Once an early scan has set your date, it usually stays the "
              "same. Later scans measure your baby's growth, not your dates. "
              "If a report at 20 or 32 weeks says your baby is \"measuring "
              "two weeks ahead\", that's about size, and your due date "
              "normally doesn't move."),
          _en("After IVF, the date comes from the day of your embryo "
              "transfer and the age of the embryo. Your clinic will give it "
              "to you, and it's the most exact date there is."),
        ],
        tip: PvReadTip(
          title: _en('Keep one date'),
          body: _en("Write the date your doctor gives you on your MCP card or "
              "antenatal file, and use that same date everywhere, including "
              "here."),
        ),
      ),
      PvReadSection(
        heading: _en('Which date does ParentVeda use?'),
        paragraphs: [
          _en("You can set your due date from your last period, a conception "
              "date, an IVF transfer, a scan, or a date your doctor told you. "
              "When the date came from a scan, a transfer or your doctor, "
              "ParentVeda follows it and won't show a different number of "
              "its own. Your clinic's date is the one that counts."),
          _en("If you set it from your period and later get a scan date, "
              "update it with the due date calculator on this door. Choose "
              "\"Ultrasound dating\" or \"I know my due date\". Your weeks, "
              "reminders and weekly reads will move to match."),
        ],
      ),
      PvReadSection(
        heading: _en('Will my baby come on that day?'),
        paragraphs: [
          _en("Probably not, and that's normal. Only about 4 or 5 babies in "
              "100 arrive on the due date itself. Most healthy babies come "
              "between 37 and 42 weeks."),
          _en("It can help to think of a due month rather than a day. Many "
              "women tell relatives \"early December\" instead of a date, so "
              "the phone calls asking for news start later."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en("My scan date is different from my period date. Which "
            "one is right?"),
        answer: _en("If the scan was in the first three months, your doctor "
            "will usually go with the scan. Use the date your doctor writes "
            "down."),
      ),
      PvReadFaq(
        question: _en('Will my due date change at later scans?'),
        answer: _en("Usually not. Later scans check growth. Your doctor may "
            "change the date only in special cases, and will tell you if they "
            "do."),
      ),
      PvReadFaq(
        question: _en('My report says "GA". What is that?'),
        answer: _en("GA is gestational age: how many weeks and days pregnant "
            "you are on the day of the scan, counted the same way as above."),
      ),
      PvReadFaq(
        question: _en("My family wants the birth on an auspicious date. Can "
            "we choose one?"),
        answer: _en("Talk to your doctor early. A planned birth before 39 "
            "weeks without a medical reason isn't advised, because babies "
            "born earlier can have more trouble with breathing and feeding. "
            "Your doctor will guide you on what's safe."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 700, Methods for estimating the due '
        'date (2017) · ACOG Committee Opinion 765, Avoidance of nonmedically '
        'indicated early-term deliveries (2019) · NICE guideline NG201, '
        'Antenatal care (2021) · Ministry of Health and Family Welfare, '
        'antenatal care guidance.'),
    readNext: [
      'preg_first_read_this_week',
      'preg_first_read_visit_questions',
    ],
  ),

  // ===========================================================================
  //  YOUR FIRST VISIT
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Choosing a doctor and a hospital
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_choosing_care',
    hue: _hue,
    kicker: _kVisit,
    title: _en('Choosing a doctor and a hospital'),
    teaser: _en("Government or private, what to ask before you choose, and "
        "why distance at 2 in the morning matters."),
    shortAnswer: _en("Government hospitals give antenatal care and the birth "
        "free, while private care costs more but often means seeing the same "
        "doctor each time. Whichever you choose, ask who will be at the "
        "birth, whether there's a newborn unit and a blood bank, and what it "
        "will cost. Choose somewhere you can reach quickly at night."),
    scaleSetter: _en("You don't have to decide this week. Any qualified doctor "
        "or government centre can do your first visit, and many women change "
        "doctors or hospitals along the way. A few questions now make the "
        "choice easier."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("For many families, this choice is shaped by money, distance, "
              "and where your mother or sister gave birth. Those are good "
              "reasons. What matters most is that you feel listened to, and "
              "that the place can handle an emergency for you and your baby."),
        ],
      ),
      PvReadSection(
        heading: _en("What's the difference between government and private "
            "care?"),
        paragraphs: [
          _en("Government care runs from the sub-centre and primary health "
              "centre up to community health centres, district hospitals and "
              "medical college hospitals. Antenatal check-ups, blood tests, "
              "tablets and vaccines are free. Under the Janani Shishu "
              "Suraksha Karyakram (JSSK), a delivery in a government hospital "
              "is free too, including a caesarean, medicines, food and "
              "transport, and care for your newborn."),
          _en("Under the Pradhan Mantri Surakshit Matritva Abhiyan (PMSMA), "
              "many government centres hold a free check-up with a specialist "
              "on the 9th of every month for women in the second and third "
              "trimesters. The big government hospitals have specialists, "
              "blood banks and newborn units. The trade-off is often long "
              "queues, and you may see a different doctor each time."),
          _en("Private care ranges from a small nursing home to a large "
              "hospital. You usually see the same doctor, waits are shorter, "
              "and rooms are more private. Costs vary a great deal, so ask "
              "early. Many women use both: they register at a government "
              "centre for the free tests and card, and see a private doctor "
              "too. That's fine. Tell each about the other."),
        ],
      ),
      PvReadSection(
        heading: _en('What kind of doctor should I see?'),
        paragraphs: [
          _en("An obstetrician and gynaecologist, often called a gynae. Their "
              "degree will usually be an MD, MS or DNB in obstetrics and "
              "gynaecology, or a DGO. In government centres, routine checks "
              "are often done by a medical officer or a trained nurse or ANM, "
              "who will send you to a specialist when you need one."),
          _en("If you want to check a doctor's registration, the National "
              "Medical Commission and your state medical council keep "
              "registers you can search."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask before I choose?'),
        bullets: [
          _en("\"Will you be at the birth? Who comes if you're away?\""),
          _en("\"Who do I call at night if something worries me?\""),
          _en("\"Is the hospital open for births day and night, with an "
              "anaesthetist and an operating theatre ready?\""),
          _en("\"Is there a blood bank, and a newborn unit (NICU) in the same "
              "building?\""),
          _en("\"What does a normal birth cost, and a caesarean? What isn't "
              "included in the package?\""),
          _en("\"Do you take my health insurance, and is it cashless?\""),
          _en("\"How often do births here end in a caesarean, and when would "
              "you advise one?\""),
          _en("\"Can someone from my family stay with me in labour?\""),
          _en("\"Will my baby stay with me after the birth, and is there help "
              "with breastfeeding?\""),
        ],
        paragraphs: [
          _en("It's fair to ask every one of these. A good doctor won't mind."),
        ],
      ),
      PvReadSection(
        heading: _en('How far is too far?'),
        paragraphs: [
          _en("Think about how long the trip would take at 2 in the morning, "
              "in the rain, in traffic. A famous hospital across the city may "
              "be less useful than a good one twenty minutes away."),
          _en("Save the hospital's labour ward number in your phone, and "
              "work out now how you'd get there. 108 is the emergency "
              "ambulance, and many states run a free ambulance for pregnant "
              "women on 102. Ask your ASHA worker which one works where you "
              "live."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my pregnancy needs extra care?'),
        paragraphs: [
          _en("If you have diabetes, high blood pressure, a thyroid or heart "
              "condition, are carrying twins, had IVF, or had a caesarean or a "
              "loss before, choose a hospital with specialists and a newborn "
              "unit on site. A larger hospital or a medical college is often "
              "the safer place for the birth, even if you have check-ups "
              "closer to home."),
        ],
      ),
      PvReadSection(
        heading: _en('Going to your mother\'s home for the birth?'),
        paragraphs: [
          _en("Many women in India go to their mother's home for the last "
              "months and the birth. If you plan to, choose the doctor there "
              "early, ideally by about 28 to 32 weeks, and visit them at "
              "least once before you're due. Carry every report and your MCP "
              "card, and ask your current doctor when it's safe to travel."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en('Can I change doctors later?'),
        answer: _en("Yes. Ask for copies of your reports and your notes, and "
            "carry them to your new doctor."),
      ),
      PvReadFaq(
        question: _en('Is a government hospital safe?'),
        answer: _en("Government hospitals deliver a large share of India's "
            "babies and the bigger ones handle the most complex cases. The "
            "right choice depends on what's near you and what your pregnancy "
            "needs."),
      ),
      PvReadFaq(
        question: _en('Should I choose a woman doctor?'),
        answer: _en("If it helps you feel at ease, yes. You can also ask for a "
            "woman to be in the room for any examination."),
      ),
    ],
    evidence: _en('Janani Shishu Suraksha Karyakram (JSSK), Ministry of Health '
        'and Family Welfare · Pradhan Mantri Surakshit Matritva Abhiyan '
        '(PMSMA) guidance · LaQshya labour room quality improvement '
        'initiative, MoHFW (2017) · WHO recommendations on intrapartum care '
        'for a positive childbirth experience (2018) · National Medical '
        'Commission, Indian Medical Register.'),
    readNext: [
      'preg_first_read_visit_questions',
      'preg_scan_read_first_visit',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Questions to ask at the first visit
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_visit_questions',
    hue: _hue,
    kicker: _kVisit,
    title: _en('Questions to ask at your first visit'),
    teaser: _en("What your doctor will ask you, why they test your urine every "
        "time, and the questions worth asking back."),
    shortAnswer: _en("Write your questions down before you go, and start with "
        "the one that worries you most. Ask about your tablets, the tests and "
        "scans ahead, what's safe at work and at home, and who to call if "
        "something feels wrong. Knowing what you'll be asked helps too, so "
        "you can answer quickly."),
    scaleSetter: _en("First visits in India can be short and busy. A little "
        "preparing the night before means you leave with answers instead of "
        "a list of things you forgot to ask."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("What happens at the visit, what's checked and what to carry, "
              "is in the read \"Your first antenatal visit, and the ones "
              "after\" on this door. This one is about the talking: what "
              "you'll be asked, and what to ask."),
        ],
      ),
      PvReadSection(
        heading: _en('What will the doctor ask me?'),
        bullets: [
          _en("The first day of your last period, and how regular your cycles "
              "are."),
          _en("Any earlier pregnancies, births, miscarriages or abortions."),
          _en("Health conditions such as thyroid, diabetes, high blood "
              "pressure, epilepsy, asthma, heart problems or TB, and any "
              "operations."),
          _en("Every medicine you take, including ayurvedic and herbal ones."),
          _en("Illnesses in your family, such as diabetes, thalassaemia or "
              "twins."),
          _en("Whether you and your husband are related by blood. This is a "
              "routine question in India, because some inherited conditions "
              "are more common then. It isn't a judgement."),
          _en("Whether you smoke, chew tobacco or drink, what work you do, "
              "and how you've been feeling in yourself."),
        ],
        paragraphs: [
          _en("Some of these are private. You can ask to speak to your doctor "
              "alone for a few minutes, even if family came with you. What you "
              "tell them stays in your notes."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do they test my urine every time?'),
        paragraphs: [
          _en("A urine sample is one of the quickest checks there is. It "
              "looks for protein, which can point to a kidney problem and, "
              "later in pregnancy, to high blood pressure trouble "
              "(pre-eclampsia). It looks for sugar, a clue to pregnancy "
              "diabetes. And it looks for infection."),
          _en("Urine infections are common in pregnancy and sometimes cause "
              "no symptoms at all. Treating them early stops them spreading "
              "to the kidneys. At the first visit your sample may also be sent "
              "to a lab to grow any germs (a urine culture). If you've been "
              "vomiting a lot, the test also shows whether you're short of "
              "fluids."),
        ],
        tip: PvReadTip(
          title: _en('Giving a clean sample'),
          body: _en("Wash your hands and clean yourself front to back. Pass a "
              "little urine into the toilet first, then fill the container "
              "midway, and close the lid."),
        ),
      ),
      PvReadSection(
        heading: _en('What should I ask?'),
        paragraphs: [
          _en("Pick the ones that matter to you. You don't need them all."),
        ],
        bullets: [
          _en("Tablets: \"Which ones, what dose, and for how long? Can I take "
              "them at night if they make me sick?\""),
          _en("Tests: \"Which tests are you sending me for today, and what "
              "is each one for? Which are free here?\""),
          _en("Scans: \"When is my dating scan? Do you advise the 11 to 13 "
              "week scan for me?\""),
          _en("Daily life: \"Is my work safe? Can I travel, exercise, and "
              "have sex?\""),
          _en("Warning signs: \"Which symptoms should I call you about, and "
              "who do I call at night?\""),
          _en("Your history: \"Does anything in my history change my care?\""),
          _en("The birth: \"Where would I deliver, and roughly what will it "
              "cost?\""),
          _en("Next time: \"When should I come back?\""),
        ],
      ),
      PvReadSection(
        heading: _en('What if something feels too awkward to say?'),
        paragraphs: [
          _en("Many women stay silent about the things that matter most: an "
              "unusual discharge, constipation or piles, pain during sex, an "
              "earlier abortion, feeling low, or trouble at home. Doctors "
              "hear all of these every day, and none of them will shock "
              "yours."),
          _en("If it's hard to say out loud, write it on a slip of paper and "
              "hand it over. That counts as asking, and your doctor can only "
              "help with what they know."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I make the most of a short visit?'),
        bullets: [
          _en("Say the thing that worries you most first, before the doctor "
              "starts writing."),
          _en("Bring someone if you can. Two people remember more than one."),
          _en("Ask the doctor to explain again, or in Hindi or your own "
              "language, if a word is new. It's okay to ask twice."),
          _en("Write down the answers, or record a voice note on your phone."),
          _en("Take a photo of the prescription and the test slip before you "
              "leave."),
          _en("Before you go, repeat back what you'll do next, and when to "
              "come back."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I feel rushed or not heard?'),
        paragraphs: [
          _en("You can say, \"I have one more question, it's important to "
              "me.\" The nurse or the ANM can often explain tests and tablets "
              "after the doctor has seen you. If you keep leaving without "
              "answers, it's okay to look for another doctor."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en('Can I ask my mother-in-law to wait outside?'),
        answer: _en("Yes. You can ask the doctor or nurse to call you in alone "
            "for part of the visit. Many clinics do this routinely."),
      ),
      PvReadFaq(
        question: _en('Is it rude to ask about costs?'),
        answer: _en("Not at all. Asking early helps you plan and avoids "
            "surprises at the counter."),
      ),
      PvReadFaq(
        question: _en('Should my husband come?'),
        answer: _en("If he can, it helps. He'll hear the plan first-hand and "
            "can remember what you don't."),
      ),
    ],
    evidence: _en('Ministry of Health and Family Welfare, antenatal care '
        'guidance and the Mother and Child Protection Card · WHO '
        'recommendations on antenatal care for a positive pregnancy '
        'experience (2016) · NICE guideline NG201, Antenatal care (2021).'),
    readNext: [
      'preg_scan_read_first_visit',
      'preg_first_read_choosing_care',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  First visit after IVF or a loss
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_ivf_or_loss',
    hue: _hue,
    kicker: _kVisit,
    title: _en('Your first visit after IVF or a loss'),
    teaser: _en("Moving from the IVF clinic to an obstetrician, the medicines "
        "not to stop, and what to tell your doctor after a loss."),
    shortAnswer: _en("After IVF, your fertility clinic usually looks after you "
        "until about 8 to 12 weeks, then hands you over to an obstetrician. "
        "Keep taking every medicine the clinic prescribed until they tell you "
        "to stop. After a loss, tell your doctor at your first call, and ask "
        "whether an early scan is right for you."),
    scaleSetter: _en("Most pregnancies after IVF or after a loss go well. "
        "These first weeks can still feel heavier than they do for others, "
        "and that's understandable. A clear plan for your care takes some of "
        "the weight off."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("If this pregnancy came after treatment, or after a pregnancy "
              "that ended, you may feel hope and fear side by side. You may "
              "not want to tell anyone, or plan anything, until a scan says "
              "all is well. Both are okay. This read covers the practical "
              "side."),
        ],
      ),
      PvReadSection(
        heading: _en('When does care move from the IVF clinic?'),
        paragraphs: [
          _en("Your fertility clinic will usually see you for the first "
              "scans, often at about 6 to 7 weeks to see the heartbeat, and "
              "then hand you over to an obstetrician somewhere between 8 and "
              "12 weeks. Some IVF specialists carry on through the whole "
              "pregnancy. Ask your clinic what their plan is."),
          _en("Before you leave the clinic, ask for a written summary. It "
              "should have:"),
        ],
        bullets: [
          _en("The date of your embryo transfer, the embryo's age, and how "
              "many were transferred."),
          _en("Your hCG blood results and early scan reports."),
          _en("Every medicine you're on, with the dose, and the date each one "
              "should stop."),
          _en("Anything the clinic wants your obstetrician to watch."),
        ],
      ),
      PvReadSection(
        heading: _en('Which medicines should I keep taking?'),
        paragraphs: [
          _en("Many IVF pregnancies need hormone support in the early weeks. "
              "This is often progesterone, as pessaries, injections or "
              "tablets, and sometimes oestrogen, aspirin or heparin "
              "injections. Keep taking each one exactly as prescribed until "
              "the clinic says to stop, even if a new doctor or a relative "
              "suggests otherwise. If two doctors give you different plans, "
              "ask them to speak to each other."),
          _en("Vaginal progesterone often leaves a white or creamy discharge. "
              "That's expected. Bleeding isn't, so call the clinic if you "
              "bleed."),
        ],
      ),
      PvReadSection(
        heading: _en('Is an IVF pregnancy looked after differently?'),
        paragraphs: [
          _en("Mostly, no. You'll have the same visits, tests and scans as "
              "anyone else. Your due date comes from your transfer date, so "
              "it's the most exact date there is."),
          _en("In large groups of women, IVF pregnancies have somewhat "
              "higher rates of twins, high blood pressure, pregnancy diabetes "
              "and placenta problems. So your doctor may offer a few extra "
              "checks. That's care, not a sign that something is wrong. If "
              "you're carrying twins, the first-trimester scan also checks "
              "whether they share a placenta, which decides how often you're "
              "scanned."),
        ],
      ),
      PvReadSection(
        heading: _en('After a loss, what should I tell my doctor?'),
        paragraphs: [
          _en("Tell them about every earlier pregnancy at your first call, "
              "not only at the first visit. Carry the reports and discharge "
              "papers from any miscarriage, ectopic pregnancy, stillbirth or "
              "early birth."),
          _en("After an ectopic pregnancy, you should be offered an early "
              "scan to check where this pregnancy is growing. After a "
              "miscarriage, many doctors offer an early scan for reassurance. "
              "After two or more losses, your care may follow the results of "
              "earlier tests, and some women are prescribed progesterone or "
              "other medicines. Take them exactly as prescribed."),
          _en("The read \"Your care in a pregnancy after a loss\" on this "
              "door goes through the extra checks in more detail."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I carry to the first visit?'),
        bullets: [
          _en("The IVF clinic's summary, or your earlier discharge papers and "
              "scan reports."),
          _en("Results of any tests done after earlier losses, such as "
              "thyroid, blood sugar or antibody tests."),
          _en("Your blood group and your husband's, if you know them."),
          _en("The strips or boxes of every medicine you take, with the dose "
              "written on each."),
          _en("A short note of dates: each earlier pregnancy, how many weeks "
              "it reached, and what happened."),
        ],
        paragraphs: [
          _en("Writing the dates down before the visit means you don't have "
              "to tell a painful story from memory in a busy room."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I cope with the waiting?'),
        paragraphs: [
          _en("Counting the days to each scan is very common. It can help to "
              "plan something small for the day after each one, and to choose "
              "one or two people to share results with. You don't have to "
              "feel happy to be doing well."),
          _en("Mind & mood has reads written for these weeks: \"Pregnant "
              "again after a loss\" and \"After IVF, and finding it hard\". "
              "A counsellor can help too, and asking for one is a strong "
              "thing to do."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en("Should I stay in bed after my IVF transfer?"),
        answer: _en("Bed rest hasn't been shown to help. Gentle everyday "
            "activity is fine unless your clinic has told you otherwise."),
      ),
      PvReadFaq(
        question: _en("Can I ask for more scans to feel sure?"),
        answer: _en("You can ask. Your doctor will explain which scans are "
            "useful when. Sometimes an extra early scan is offered for "
            "reassurance, especially after a loss."),
      ),
      PvReadFaq(
        question: _en("Do I still need the usual tests after IVF?"),
        answer: _en("Yes. You'll be offered the same blood tests and scans as "
            "any pregnancy, including the 11 to 13 week scan."),
      ),
    ],
    evidence: _en('NICE guideline NG126, Ectopic pregnancy and miscarriage '
        '(2019, updated 2023) · RCOG Green-top Guideline 17, Recurrent '
        'miscarriage (2023) · ESHRE guideline, Recurrent pregnancy loss '
        '(2022) · NICE guideline CG156, Fertility problems (2013, updated '
        '2017) · NICE guideline NG137, Twin and triplet pregnancy (2019).'),
    readNext: [
      'preg_loss_read_next_pregnancy_care',
      'preg_first_read_anxiety',
    ],
  ),

  // ===========================================================================
  //  EARLY WORRIES
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Spotting
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_spotting',
    hue: _hue,
    kicker: _kWorry,
    title: _en('Spotting in early pregnancy'),
    teaser: _en("Why a little blood can appear in the first weeks, what to do "
        "right now, and the signs that mean hospital."),
    shortAnswer: _en("Light spotting in the first three months is common, and "
        "many women who have it go on to have a healthy pregnancy. It still "
        "deserves a call to your doctor the same day, because only a check "
        "can show the cause. Heavy bleeding, or bleeding with strong or "
        "one-sided pain, means going to hospital straight away."),
    scaleSetter: _en("About one woman in four has some bleeding in the first "
        "trimester, and most of those pregnancies carry on normally. The call "
        "to your doctor isn't because something is wrong. It's because the "
        "harmless kinds and the ones that need care can look the same at "
        "first."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Seeing blood when you're pregnant is frightening. Take a "
              "breath. Here is what it can mean and what to do."),
          _en("Spotting means a few drops of pink, red or brown blood on your "
              "underwear or the tissue, not enough to fill a pad. Bleeding is "
              "more than that: you need a pad, or it's flowing like a period. "
              "Both need a call. Heavy bleeding needs a hospital."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does it happen?'),
        bullets: [
          _en("Implantation: a little spotting as the pregnancy settles into "
              "the lining of the womb, often around the time your period was "
              "due."),
          _en("A tender cervix: the neck of the womb has more blood vessels "
              "in pregnancy, so sex or an internal examination can bring on "
              "spotting. This doesn't harm the pregnancy."),
          _en("A small collection of blood beside the pregnancy (a "
              "subchorionic haematoma), which usually settles on its own."),
          _en("An infection of the vagina or cervix, which can be treated."),
          _en("Sometimes, the start of a miscarriage, or a pregnancy growing "
              "outside the womb (an ectopic pregnancy). This is why a check "
              "matters."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I do right now?'),
        bullets: [
          _en("Call your doctor today and tell them what you've seen."),
          _en("Use a pad, not a tampon or a menstrual cup, so you can see how "
              "much there is."),
          _en("Note the colour, how many pads you use in an hour, whether "
              "there are clots, and any pain."),
          _en("Avoid sex until you've been checked."),
          _en("Rest if it helps you feel better. Strict bed rest hasn't been "
              "shown to prevent a miscarriage."),
        ],
        tip: PvReadTip(
          title: _en("If you're Rh negative"),
          body: _en("Tell whoever sees you straight away. Depending on your "
              "weeks and the bleeding, you may need an injection called "
              "anti-D, which works best within 72 hours."),
        ),
      ),
      PvReadSection(
        heading: _en('What will the doctor do?'),
        paragraphs: [
          _en("They'll ask how much blood there is and whether you have pain, "
              "and may gently examine you. Most women are sent for a scan. In "
              "the early weeks this is often an internal (transvaginal) scan, "
              "which sees more than a scan over the tummy and doesn't harm "
              "the pregnancy."),
          _en("If it's too early to see much on a scan, your doctor may check "
              "your hCG level in your blood and repeat it after about 48 "
              "hours. How the number changes tells them more than one number "
              "alone. Waiting for that second result is hard. It's still the "
              "right way to get a clear answer."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I carry on with daily life?'),
        paragraphs: [
          _en("Once your doctor has checked you and the spotting is light, "
              "most women can go on with ordinary life: work, cooking, "
              "walking, a short trip. Rest more if you're tired, and drink "
              "plenty of water."),
          _en("Many doctors suggest avoiding sex until a few days after the "
              "spotting has stopped, mainly so fresh spotting doesn't cause a "
              "new scare. Ask yours what they'd prefer. Avoid heavy lifting "
              "and hard exercise for a few days if they make you uneasy."),
          _en("If you're travelling, carry your reports and know where the "
              "nearest hospital with a labour ward is. Keep a pad with you "
              "so you can see if the bleeding changes."),
        ],
      ),
      PvReadSection(
        heading: _en('What if it turns out to be an ectopic pregnancy?'),
        paragraphs: [
          _en("An ectopic pregnancy grows outside the womb, usually in a "
              "tube, and can't carry on. It's found with a scan and hCG blood "
              "tests. When it's found early, it can often be treated with "
              "medicine or with keyhole surgery. The Complications section "
              "has a full page on it, and it's on this door."),
        ],
      ),
      PvReadSection(
        heading: _en('Did I cause this?'),
        paragraphs: [
          _en("No. Spotting isn't caused by going to work, climbing stairs, "
              "a bumpy auto ride, lifting your child or eating the \"wrong\" "
              "food. When an early pregnancy does end, it's most often "
              "because of a chromosome problem present from the very start, "
              "which nothing you did caused and nothing could have "
              "prevented."),
          _en("If a check shows the pregnancy is ending, there is care for "
              "your body and your heart. ParentVeda has a quiet After a loss "
              "section for that time, whenever you want it."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en('Is brown discharge the same as bleeding?'),
        answer: _en("Brown usually means older blood leaving slowly. It's "
            "often less worrying than fresh red blood, but still tell your "
            "doctor."),
      ),
      PvReadFaq(
        question: _en('I spotted after sex. Have I hurt the baby?'),
        answer: _en("No. The spotting comes from the cervix, not from the "
            "pregnancy. Tell your doctor, and wait until you've been checked "
            "before having sex again."),
      ),
      PvReadFaq(
        question: _en('Can I go to work tomorrow?'),
        answer: _en("If the spotting is light, you have no pain, and your "
            "doctor has checked you, usually yes. Rest if you'd feel better."),
      ),
    ],
    evidence: _en('NICE guideline NG126, Ectopic pregnancy and miscarriage: '
        'diagnosis and initial management (2019, updated 2023) · ACOG '
        'Practice Bulletin 200, Early pregnancy loss (2018) · RCOG Green-top '
        'Guideline 22, The use of anti-D immunoglobulin for rhesus D '
        'prophylaxis (2011) · Ministry of Health and Family Welfare, '
        'antenatal care guidance.'),
    readNext: [
      'preg_first_read_cramps',
      'preg_first_read_faint_line',
      'preg_first_read_anxiety',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Cramps
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_cramps',
    hue: _hue,
    kicker: _kWorry,
    title: _en('Cramps and twinges in the first weeks'),
    teaser: _en("The mild, period-like cramps many women feel, what eases "
        "them, and the kind of pain you should never wait out."),
    shortAnswer: _en("Mild, period-like cramps that come and go are common in "
        "early pregnancy, as your womb grows and your bowels slow down. Pain "
        "that is strong, steady or on one side, or comes with bleeding, "
        "shoulder-tip pain or feeling faint, is different. Go to hospital "
        "straight away for those."),
    scaleSetter: _en("Most early cramps are your body making room. Knowing "
        "what the usual kind feels like makes it easier to spot the pain "
        "that needs a doctor."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Many women feel a dull ache or cramp low in the tummy in the "
              "first weeks, and some are sure their period is about to start. "
              "It's one of the most common early feelings, and on its own it's "
              "rarely a sign that something is wrong."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does my tummy cramp?'),
        bullets: [
          _en("Your womb is growing, and the muscles and bands around it are "
              "stretching."),
          _en("The pregnancy settling into the womb lining can cause a little "
              "cramping, around the time your period was due."),
          _en("Progesterone slows your bowels, so wind, bloating and "
              "constipation are common and can cramp."),
          _en("A full bladder, or a mild tightening after an orgasm."),
        ],
      ),
      PvReadSection(
        heading: _en('What kind of cramp is usual?'),
        paragraphs: [
          _en("The usual kind is mild and dull, low in the middle or on both "
              "sides. It comes and goes. It eases when you rest, change "
              "position, pass wind or open your bowels. There's no bleeding "
              "with it, and you feel well otherwise."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps?'),
        bullets: [
          _en("Lie down on your side for a while, or have a warm (not hot) "
              "bath."),
          _en("A warm water bottle wrapped in a towel on your lower back."),
          _en("Drink plenty of water, and eat fibre such as fruit, dal, "
              "vegetables and whole grains to keep your bowels moving."),
          _en("A short, gentle walk can shift trapped wind."),
          _en("Empty your bladder often."),
          _en("If you need a painkiller, paracetamol at the usual dose is the "
              "one to use in pregnancy. Avoid ibuprofen and similar "
              "painkillers unless your doctor advises them."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I ease constipation?'),
        paragraphs: [
          _en("Constipation is one of the most common causes of early "
              "cramps, and it's easy to miss. Pregnancy hormones slow your "
              "bowels, and iron tablets can make it worse."),
        ],
        bullets: [
          _en("Drink a glass of warm water when you wake up, and plenty "
              "through the day."),
          _en("Add fibre: fruit such as guava, papaya that's fully ripe and "
              "pears, leafy vegetables, dal, and whole wheat roti."),
          _en("Soaked raisins, figs or prunes help many women."),
          _en("Isabgol (psyllium husk) is generally considered safe in "
              "pregnancy, but ask your doctor before any laxative."),
          _en("If iron tablets are the trigger, tell your doctor. Don't just "
              "stop them."),
        ],
      ),
      PvReadSection(
        heading: _en('What about cramps after sex?'),
        paragraphs: [
          _en("A mild tightening or ache after sex or an orgasm is common and "
              "usually settles within an hour with rest. It doesn't harm the "
              "pregnancy. If it's strong, lasts, or comes with bleeding, call "
              "your doctor, and wait until you've been checked before having "
              "sex again."),
        ],
      ),
      PvReadSection(
        heading: _en('When is pain a warning sign?'),
        paragraphs: [
          _en("Go to hospital straight away if the pain is sharp or severe, "
              "stays on one side, or doesn't ease with rest. Go too if pain "
              "comes with bleeding, with pain at the tip of your shoulder, or "
              "with feeling faint or dizzy."),
          _en("One-sided pain can be a sign of an ectopic pregnancy, where "
              "the pregnancy grows outside the womb, usually in a tube. It "
              "affects about 1 to 2 pregnancies in 100 and usually shows "
              "between 5 and 10 weeks. Pain at the tip of the shoulder can "
              "mean internal bleeding from it. It's treatable, and it's "
              "safest when it's found early."),
          _en("Call your doctor today if it burns when you pass urine, you "
              "need to go much more often with pain, or you have a fever. "
              "These can be signs of a urine infection."),
        ],
      ),
      PvReadSection(
        heading: _en('Who should ask for an early scan?'),
        paragraphs: [
          _en("Tell your doctor as soon as your test is positive if you've "
              "had an ectopic pregnancy before, surgery on your tubes, a "
              "pelvic infection, or IVF, or if you became pregnant with a "
              "copper-T (an IUD) in place. An early scan can check where the "
              "pregnancy is growing."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I tell the doctor?'),
        paragraphs: [
          _en("If you call about pain, it helps to say where it is, when it "
              "started, whether it comes and goes or stays, and how strong it "
              "is on a scale of 1 to 10. Say whether there's any bleeding, "
              "fever, or pain when you pass urine, and whether you've had an "
              "ectopic pregnancy or tube surgery before."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en("It feels like my period is coming. Is that normal?"),
        answer: _en("Yes, mild period-like cramps are common early on. If "
            "they come with bleeding, or get stronger, call your doctor."),
      ),
      PvReadFaq(
        question: _en('Can cramps be caused by gas?'),
        answer: _en("Often, yes. Bloating and wind are very common in early "
            "pregnancy. Pain that doesn't ease after passing wind still needs "
            "checking."),
      ),
      PvReadFaq(
        question: _en('Will lifting my toddler cause cramps that harm the '
            'baby?'),
        answer: _en("Lifting your child won't harm the pregnancy. Bend your "
            "knees and keep your back straight to protect yourself."),
      ),
    ],
    evidence: _en('NICE guideline NG126, Ectopic pregnancy and miscarriage '
        '(2019, updated 2023) · ACOG Practice Bulletin 193, Tubal ectopic '
        'pregnancy (2018) · NICE guideline NG201, Antenatal care (2021) · '
        'Ministry of Health and Family Welfare, antenatal care guidance.'),
    readNext: [
      'preg_first_read_spotting',
      'preg_first_read_no_symptoms',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  No symptoms
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_no_symptoms',
    hue: _hue,
    kicker: _kWorry,
    title: _en("When you don't feel pregnant"),
    teaser: _en("Few symptoms, symptoms that come and go, and why how you "
        "feel says little about how your pregnancy is doing."),
    shortAnswer: _en("Plenty of healthy pregnancies come with few symptoms or "
        "none, and symptoms often change from day to day. How you feel "
        "doesn't show how your pregnancy is doing. Call your doctor if "
        "symptoms stop suddenly along with pain or bleeding."),
    scaleSetter: _en("About three women in ten have no nausea at all, and "
        "many others feel only a little tired. Feeling fine is a common way "
        "to be pregnant, even if it doesn't match the stories you've heard."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("You may have been told to expect sickness, sore breasts and "
              "exhaustion from the first week. So when you feel almost "
              "normal, it's easy to start wondering if something is wrong."),
        ],
        mythFact: PvMythFact(
          myth: _en("If you don't feel sick, the pregnancy isn't strong."),
          fact: _en("Symptoms show how your body reacts to pregnancy "
              "hormones, and that differs a lot between women and between "
              "pregnancies. Strong symptoms or mild ones don't tell you how "
              "the pregnancy is doing."),
        ),
      ),
      PvReadSection(
        heading: _en('Is it normal to feel nothing much?'),
        paragraphs: [
          _en("Yes. Early symptoms depend on how quickly your hormones rise, "
              "how sensitive you are to them, and how far along you are. Many "
              "women notice very little before 6 or 7 weeks. Some feel more "
              "in one pregnancy than another."),
          _en("Your sister, your friend or your mother-in-law may have been "
              "sick every day. Their pregnancy isn't a measure for yours."),
        ],
      ),
      PvReadSection(
        heading: _en('What are the usual early signs, anyway?'),
        paragraphs: [
          _en("Early pregnancy can show up in many small ways, and most "
              "women have only a few of them:"),
        ],
        bullets: [
          _en("Tiredness, sometimes heavy."),
          _en("Tender or fuller breasts."),
          _en("Needing to pass urine more often."),
          _en("Feeling sick, or going off some foods."),
          _en("A metallic taste, or a sharper sense of smell."),
          _en("Bloating, and mild period-like cramps."),
          _en("Moods that change more than usual."),
          _en("A little more white discharge than normal."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do my symptoms come and go?'),
        paragraphs: [
          _en("Good days and bad days are normal. Nausea can vanish for a day "
              "and return the next. Tiredness can depend on how you slept. "
              "Breast tenderness often fades after the first weeks as your "
              "body adjusts."),
          _en("Many symptoms ease gradually around 12 to 14 weeks, as the "
              "placenta takes over making hormones. That's expected, and for "
              "many women it's the start of feeling more like themselves."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my symptoms stop suddenly?'),
        paragraphs: [
          _en("On its own, a good day is usually just a good day. If the "
              "change comes with bleeding or cramping, call your doctor the "
              "same day."),
          _en("To be honest with you, a pregnancy can sometimes stop growing "
              "without any sign at all, and this is found on a scan. That's "
              "one reason the early scans are routine. It also means you "
              "don't need to watch your symptoms for clues. They can't give "
              "you the answer, and the scan can."),
          _en("If the change is playing on your mind, you don't have to wait "
              "for your next visit. Call your doctor and say so."),
          _en("If you've had a loss before, feeling well can be the most "
              "unsettling thing of all, because it may be how the last one "
              "felt too. Tell your doctor at your first call. Many offer an "
              "early scan for reassurance, and you don't need a symptom to "
              "ask for one."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I feel more sure?'),
        bullets: [
          _en("Keep your appointments. A scan from about 6 to 7 weeks can "
              "usually show the heartbeat, and your dating scan confirms how "
              "your baby is growing."),
          _en("From around 12 weeks, your doctor can listen to your baby's "
              "heartbeat with a small handheld monitor at your visits."),
          _en("Try not to keep repeating home tests. The line's darkness "
              "isn't a guide to how the pregnancy is going."),
          _en("Home heartbeat monitors aren't advised. They're hard to use, "
              "and they can easily pick up your own heartbeat or miss your "
              "baby's."),
          _en("Write down what's worrying you and take it to your next "
              "visit."),
        ],
      ),
      PvReadSection(
        heading: _en('Making the most of feeling well'),
        paragraphs: [
          _en("If you feel well, use it. It's a good time to start gentle "
              "daily walks, get into the habit of your folic acid, book your "
              "visit and register your pregnancy, and sort out the paperwork "
              "at work before tiredness arrives."),
          _en("Eat regular meals with dal, vegetables, fruit, milk or curd, "
              "and keep drinking water. Sleep when you can. Symptoms may "
              "still turn up in a week or two, and if they do, you'll have "
              "a head start."),
        ],
      ),
      PvReadSection(
        heading: _en('When worry keeps coming back'),
        paragraphs: [
          _en("Feeling fine but anxious is a very common mix in these weeks. "
              "Try to notice what's going right: you're taking your folic "
              "acid, you've booked your visit, and you know when to call. The "
              "read \"Anxious in the first weeks\" has more that can help."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en("I was sick all the time in my first pregnancy and "
            "hardly at all now. Is that okay?"),
        answer: _en("Yes. Symptoms often differ between pregnancies, even in "
            "the same woman."),
      ),
      PvReadFaq(
        question: _en('Should I take another pregnancy test to check?'),
        answer: _en("It won't tell you how the pregnancy is going. If you're "
            "worried, call your doctor instead."),
      ),
      PvReadFaq(
        question: _en('Does feeling well mean I can skip the early scan?'),
        answer: _en("No. The early scans check dates and growth, and they "
            "matter whether you feel well or not."),
      ),
    ],
    evidence: _en('ACOG Practice Bulletin 189, Nausea and vomiting of '
        'pregnancy (2018) · NICE guideline NG126, Ectopic pregnancy and '
        'miscarriage (2019, updated 2023) · NICE guideline NG201, Antenatal '
        'care (2021) · Ministry of Health and Family Welfare, antenatal care '
        'guidance.'),
    readNext: [
      'preg_first_read_anxiety',
      'preg_first_read_faint_line',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Sickness that is too much
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_sickness_too_much',
    hue: _hue,
    kicker: _kWorry,
    title: _en('When sickness is too much'),
    teaser: _en("How to tell ordinary morning sickness from the severe kind, "
        "and the treatment that helps."),
    shortAnswer: _en("Feeling sick is common in early pregnancy, but it "
        "shouldn't stop you eating and drinking altogether. If you can't keep "
        "fluids down for 24 hours, you're vomiting many times a day, or your "
        "urine is dark and scanty, call your doctor the same day. Severe "
        "sickness (hyperemesis) is a medical condition with safe treatment."),
    scaleSetter: _en("About seven women in ten feel sick in early pregnancy, "
        "and one to three in a hundred have the severe kind. You don't have "
        "to work out which one you have. If sickness is stopping your life, "
        "it's worth asking for treatment."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Relatives may tell you everyone feels sick and you just have "
              "to bear it. They mean well, and for mild sickness they're "
              "partly right. But severe sickness isn't a test of strength, "
              "and you don't have to push through it. There are medicines "
              "that are safe in pregnancy and that work."),
        ],
      ),
      PvReadSection(
        heading: _en("How do I know it's more than morning sickness?"),
        paragraphs: [
          _en("Call your doctor the same day if any of these fit:"),
        ],
        bullets: [
          _en("You can't keep any fluids down for 24 hours."),
          _en("You're vomiting more than three or four times a day."),
          _en("Your urine is dark and there's very little of it."),
          _en("You feel dizzy or light-headed when you stand up."),
          _en("You've lost more than about two kilos."),
          _en("You can't keep your tablets down."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en("Don't wait until tomorrow if"),
          body: _en("You're vomiting blood or something that looks like "
              "coffee grounds, you have tummy pain or a fever with the "
              "vomiting, or you feel faint. Go to hospital."),
        ),
      ),
      PvReadSection(
        heading: _en('Why do some women have it worse?'),
        paragraphs: [
          _en("Nobody knows every reason. In large groups of women, severe "
              "sickness is more common with twins, in a first pregnancy, in "
              "women who had it in an earlier pregnancy, and where a mother "
              "or sister had it too. Women who get motion sickness or "
              "migraines often feel sicker in pregnancy as well."),
          _en("None of these is something you did. If you had severe "
              "sickness before, tell your doctor early this time, as starting "
              "treatment sooner can help."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I tell the doctor?'),
        bullets: [
          _en("How many times a day you're vomiting, and for how many days."),
          _en("What you've kept down in the last 24 hours, food and drink."),
          _en("How often you're passing urine, and its colour."),
          _en("Whether you've lost weight, and roughly how much."),
          _en("Which remedies and medicines you've already tried."),
        ],
        paragraphs: [
          _en("With severe sickness, please don't keep a religious or "
              "festival fast. Ask your doctor, and let your family know it's "
              "on medical advice."),
        ],
      ),
      PvReadSection(
        heading: _en('What can the doctor do?'),
        paragraphs: [
          _en("Several anti-sickness medicines are safe in pregnancy, such as "
              "doxylamine with vitamin B6, and your doctor can choose others "
              "if that one doesn't help. Many women find they can eat again "
              "within days."),
          _en("If you're short of fluids, you may be given fluids through a "
              "drip, sometimes in a day ward or with a short stay in "
              "hospital. If the vomiting has gone on for a while, you may be "
              "given vitamin B1 (thiamine) too. Your doctor may also pause "
              "your iron tablets for a few weeks, since iron can make nausea "
              "worse. Keep your folic acid going."),
          _en("The Complications section has a full page on severe vomiting "
              "(hyperemesis), with the signs and how it's managed. It's on "
              "this door too."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps at home alongside treatment?'),
        bullets: [
          _en("Small sips often, rather than a glass at once: water, oral "
              "rehydration solution (ORS), coconut water, or nimbu paani with "
              "a pinch of salt."),
          _en("Cold drinks and ice chips often stay down better than warm "
              "ones."),
          _en("Eat whatever you can keep down, even if it's plain. This "
              "isn't the time for a perfect diet."),
          _en("Rest, and keep away from cooking smells. Ask someone else to "
              "do the tadka for a while."),
          _en("Rinse your mouth after vomiting and wait a little before "
              "brushing, to protect your teeth."),
        ],
        paragraphs: [
          _en("The read \"Managing morning sickness\" on this door has more "
              "on everyday remedies such as ginger."),
        ],
      ),
      PvReadSection(
        heading: _en('Getting help at home and at work'),
        paragraphs: [
          _en("Severe sickness can make it impossible to work, cook or look "
              "after other children. Ask your doctor for a note if you need "
              "time off, and let your family take over the kitchen. It's "
              "common to feel low or tearful when you're this unwell. If "
              "you're struggling, tell your doctor, or call Tele-MANAS free "
              "on 14416."),
          _en("At work, you may be able to start later when the roads are "
              "quieter, work from home for a while, or take sick leave with a "
              "doctor's note. Keep a small bag with water, ORS, a spare top "
              "and a few mints, so a bad moment on the way doesn't become a "
              "bad day."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go to hospital straight away if'),
      body: _en("You can't keep any fluids down and feel dizzy or faint, "
          "you're vomiting blood, or you have heavy bleeding, sharp pain low "
          "down on one side, severe tummy pain, or pain at the tip of your "
          "shoulder. Go too if you have a fever of 38°C or more with pain or "
          "vomiting. If you can't get there safely, call 108. For vomiting "
          "more than three or four times a day, dark and scanty urine, or "
          "weight you're losing, call your doctor today."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Will the vomiting harm my baby?'),
        answer: _en("When it's treated, severe sickness doesn't usually harm "
            "the baby. Your baby takes what it needs from your reserves in "
            "these early weeks. What matters most is keeping you from getting "
            "dehydrated."),
      ),
      PvReadFaq(
        question: _en('Are anti-sickness medicines safe in pregnancy?'),
        answer: _en("The ones doctors use for pregnancy sickness have been "
            "used by many women and are considered safe. Your doctor will "
            "choose one for you."),
      ),
      PvReadFaq(
        question: _en('Will it be like this for the whole pregnancy?'),
        answer: _en("For most women sickness eases by 12 to 14 weeks. The "
            "severe kind can last longer, and treatment helps while it does."),
      ),
    ],
    evidence: _en('RCOG Green-top Guideline 69, The management of nausea and '
        'vomiting of pregnancy and hyperemesis gravidarum (2016) · ACOG '
        'Practice Bulletin 189, Nausea and vomiting of pregnancy (2018) · '
        'FOGSI good clinical practice recommendations on hyperemesis · NICE '
        'guideline NG201, Antenatal care (2021).'),
    readNext: [
      'preg_week_read_managing_nausea',
      'preg_first_read_no_symptoms',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  A faint line, or a low hCG number
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_faint_line',
    hue: _hue,
    kicker: _kWorry,
    title: _en('A faint line, or a low hCG number'),
    teaser: _en("What a pale line on a home test means, why the darkness "
        "isn't a guide, and why one blood number says so little."),
    shortAnswer: _en("A faint line that appears within the time on the pack "
        "usually still means you're pregnant. How dark it looks depends on "
        "the test, the time of day and how early you are, not on how healthy "
        "the pregnancy is. One hCG number on its own tells very little; your "
        "doctor looks at how it changes, and at a scan."),
    scaleSetter: _en("Faint lines and puzzling numbers are some of the most "
        "searched worries of early pregnancy. Most turn out to be about "
        "timing. The few that need care are found by repeating the test and "
        "doing a scan, which your doctor will arrange."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Home tests and early blood tests both measure hCG, the "
              "pregnancy hormone. It rises fast in the first weeks, which is "
              "why a test that was negative a few days ago can be positive "
              "now."),
        ],
      ),
      PvReadSection(
        heading: _en('Does a faint line count?'),
        paragraphs: [
          _en("Usually, yes. If a second line shows up within the reading "
              "time on the pack, even a pale one, the test has found hCG. It "
              "looks faint when the level is still low, often because it's "
              "very early."),
          _en("A line can also look lighter if your urine is dilute, for "
              "example later in the day after lots of water. Brands differ in "
              "how sensitive they are, too. The first urine of the morning is "
              "the most concentrated."),
          _en("A thin grey line that appears only after the reading time is "
              "often an evaporation line, not a result. If you're unsure, "
              "test again in two or three days with first-morning urine, or "
              "ask your doctor for a blood test."),
        ],
        tip: PvReadTip(
          title: _en('After fertility treatment'),
          body: _en("If you had an hCG trigger injection, a home test can show "
              "positive from the injection itself for about 10 to 14 days. "
              "Your clinic will time a blood test for you."),
        ),
      ),
      PvReadSection(
        heading: _en('When is the best time to test?'),
        paragraphs: [
          _en("Most home tests are most reliable from the first day of a "
              "missed period. Testing earlier can give a negative even when "
              "you're pregnant, because there isn't enough hCG yet to show."),
          _en("Use the first urine of the morning, follow the steps on the "
              "pack exactly, and read the result at the time it says, not "
              "an hour later. If the test is negative and your period still "
              "hasn't come, test again in three days, or ask your doctor for "
              "a blood test."),
          _en("If your cycles are long or irregular, count from when your "
              "period was most likely due, not from a 28-day calendar."),
        ],
      ),
      PvReadSection(
        heading: _en('Should I keep testing to see it get darker?'),
        paragraphs: [
          _en("It's very tempting, and many women do. But the line's darkness "
              "isn't a reliable guide. It changes with the brand, the urine "
              "and the time of day, so a lighter line tomorrow can mean "
              "nothing at all. Later on, very high hCG can even make some "
              "tests look paler. Once you've had a positive, it's kinder to "
              "yourself to stop testing and let your doctor take over."),
        ],
      ),
      PvReadSection(
        heading: _en('What does an hCG blood test show?'),
        paragraphs: [
          _en("A blood test gives a number instead of a line. In healthy "
              "pregnancies that number varies widely from woman to woman, even "
              "at the same week, so one reading can't show how things are "
              "going. That's why doctors often repeat it after about 48 hours. "
              "Early on, hCG usually rises quickly over two to three days, and "
              "the rise slows after the first weeks."),
          _en("Once the level is high enough, a scan becomes more useful than "
              "the number. The Scans & tests read \"hCG and your early blood "
              "tests\" explains the tests in more detail."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my number is low, or rising slowly?'),
        paragraphs: [
          _en("A lower number can mean you're just earlier than you "
              "thought. It can also mean a pregnancy that isn't developing, "
              "or, less often, one growing outside the womb (an ectopic "
              "pregnancy). Your doctor tells these apart by repeating the "
              "test and doing a scan. A single low number isn't a verdict."),
          _en("Sometimes a test is positive and then a period comes a few "
              "days later. This is a very early loss, sometimes called a "
              "chemical pregnancy. It's common, it isn't caused by anything "
              "you did, and the sadness you may feel is real."),
        ],
      ),
      PvReadSection(
        heading: _en('While you wait for the next result'),
        paragraphs: [
          _en("Waiting two days can feel like two weeks. Plan something for "
              "those days, choose one person to talk to, and try not to "
              "compare numbers on forums. Other women's numbers aren't a "
              "guide to yours. If the waiting is hard to bear, the reads on "
              "anxiety in these weeks can help."),
          _en("If you have pain or bleeding while you wait, don't wait for "
              "the next result. Follow the signs at the end of this read, and "
              "call your doctor or go to hospital as they say."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en("My friend's hCG was much higher at the same week. "
            "Should I worry?"),
        answer: _en("No. Healthy numbers vary widely. What your doctor looks "
            "at is how your own number changes, and the scan."),
      ),
      PvReadFaq(
        question: _en('Is a digital test more accurate?'),
        answer: _en("It gives a word instead of a line, which some women find "
            "easier. It isn't more accurate about how the pregnancy is "
            "going."),
      ),
      PvReadFaq(
        question: _en('Can I have a positive test and not be pregnant?'),
        answer: _en("It's rare. It can happen after an hCG injection, after a "
            "very early loss, or with a few medical conditions. A blood test "
            "and a scan settle it."),
      ),
    ],
    evidence: _en('NICE guideline NG126, Ectopic pregnancy and miscarriage '
        '(2019, updated 2023) · ACOG Practice Bulletin 193, Tubal ectopic '
        'pregnancy (2018) · ACOG Practice Bulletin 200, Early pregnancy loss '
        '(2018) · Ministry of Health and Family Welfare, antenatal care '
        'guidance.'),
    readNext: [
      'preg_scan_read_early_bloods',
      'preg_first_read_spotting',
      'preg_first_read_anxiety',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Anxiety
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_anxiety',
    hue: _hue,
    kicker: _kWorry,
    title: _en('Anxious in the first weeks'),
    teaser: _en("Why the weeks before your first scan can feel so tense, what "
        "helps day to day, and when to ask for more help."),
    shortAnswer: _en("Worry in the first weeks is very common, especially "
        "before the first scan, after IVF or after a loss. Small steps help: "
        "fewer searches, one person to talk to, and your questions written "
        "down for your doctor. If worry fills most of your days for two weeks "
        "or more, tell your doctor. Help works and is safe in pregnancy."),
    scaleSetter: _en("Almost every woman worries in these weeks. For most, "
        "it eases after the first scans. For some it grows into anxiety that "
        "needs care, and that's common too, and treatable."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("The first weeks are a strange time. Something huge has "
              "happened, and there's nothing to see yet. Many women check "
              "their underwear every time they go to the bathroom, or lie "
              "awake adding up weeks. If that's you, you're not alone, and "
              "it doesn't mean you're doing anything wrong."),
        ],
      ),
      PvReadSection(
        heading: _en('Why am I so anxious?'),
        bullets: [
          _en("There's a lot you can't know yet, and waiting for scans is "
              "hard."),
          _en("Hormones, tiredness and poor sleep all turn up the volume on "
              "worry."),
          _en("A past loss, IVF, or a long wait to get pregnant makes this "
              "pregnancy feel precious and fragile."),
          _en("Pressure from family, or keeping the news secret, can leave "
              "you carrying it alone."),
          _en("Searching online at night brings up the rarest and worst "
              "stories first."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps day to day?'),
        bullets: [
          _en("Give worry a time. Ten minutes in the evening to write your "
              "worries down, then put the list away until your next visit."),
          _en("Pick one trusted source and stop searching after that. Your "
              "doctor and this app are enough for most questions."),
          _en("Tell one person how you feel: your husband, a sister, a close "
              "friend."),
          _en("Breathe slowly: in for 4, out for 6, for a few minutes. Mind & "
              "mood has guided breathing you can follow."),
          _en("Move a little each day. A walk in the morning light helps "
              "both mood and sleep."),
          _en("Make a plan for \"what if\": your doctor's number and the "
              "nearest hospital saved in your phone. With a plan in place, "
              "your mind can stop rehearsing."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the wait for the first scan?'),
        paragraphs: [
          _en("The days before a scan are often the hardest. Plan something "
              "small for the day after it, and take someone with you if you "
              "can. It's okay to tell the person doing the scan that you're "
              "nervous and ask them to tell you as soon as they see the "
              "heartbeat."),
          _en("If this pregnancy comes after a loss or after IVF, you may "
              "need an extra scan, a longer talk with your doctor, or a "
              "counsellor. Asking for any of these is reasonable."),
        ],
      ),
      PvReadSection(
        heading: _en('How can my husband and family help?'),
        bullets: [
          _en("Listen without rushing to fix it. \"That sounds hard\" helps "
              "more than \"stop thinking about it\"."),
          _en("Come to the scans and appointments when they can."),
          _en("Take over a few jobs at home, so there's room to rest."),
          _en("Keep frightening stories and comments away from her."),
          _en("Help her keep to one trusted source instead of searching."),
        ],
        paragraphs: [
          _en("If you're the one reading this for her, you can share it with "
              "her, or read \"How your partner can support you now\" in the "
              "weekly reads."),
        ],
      ),
      PvReadSection(
        heading: _en('When is it more than worry?'),
        paragraphs: [
          _en("The World Health Organization estimates that about one "
              "pregnant woman in ten worldwide has a mental health condition, "
              "most often depression or anxiety, and more in lower-income "
              "countries. Tell your doctor if, for two weeks or more:"),
        ],
        bullets: [
          _en("You feel worried or on edge most of the day, nearly every day."),
          _en("You have panic attacks: a racing heart, trouble breathing, a "
              "sense of dread."),
          _en("You can't sleep even when you're exhausted, or can't eat."),
          _en("You spend hours checking, searching or asking for "
              "reassurance, and it never helps for long."),
          _en("You feel low, numb or hopeless, or have frightening thoughts "
              "that keep coming back."),
        ],
      ),
      PvReadSection(
        heading: _en('Who can help?'),
        paragraphs: [
          _en("Start with your doctor. Talking therapy is safe in pregnancy "
              "and works well for anxiety. Some medicines are safe in "
              "pregnancy too, and your doctor can weigh them with you. If you "
              "already take medicine for anxiety or depression, don't stop it "
              "without asking."),
          _en("Tele-MANAS, the government's mental health helpline, is free "
              "on 14416, day and night, in many Indian languages. You can "
              "also talk to a counsellor through this door."),
          _en("Some women fear that telling a doctor about anxiety will be "
              "held against them, or make them look like a bad mother. It "
              "won't. Doctors ask about mood at antenatal visits because "
              "anxiety is common and treatable, and asking for help is part "
              "of looking after your baby."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Get help straight away if'),
      body: _en("You have any thought of harming yourself, or feel you can't "
          "keep yourself safe. Call Tele-MANAS on 14416 now, or 112 if you're "
          "in danger, and tell someone near you. Go to hospital straight away "
          "for heavy bleeding, sharp pain on one side of your tummy, pain at "
          "the tip of your shoulder, fainting, or a fever with pain or "
          "bleeding. Tell your doctor this week if worry or low mood has "
          "filled most days for two weeks."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can my worrying harm the baby?'),
        answer: _en("Everyday worry doesn't harm your baby. Anxiety that goes "
            "on for weeks is worth treating for your own sake, and getting "
            "help is good for you both."),
      ),
      PvReadFaq(
        question: _en('Is it silly to call my doctor just because I feel '
            'anxious?'),
        answer: _en("No. How you feel is part of your pregnancy care, and "
            "doctors would rather hear from you."),
      ),
      PvReadFaq(
        question: _en("I'm happy about the baby. Why do I feel so scared?"),
        answer: _en("Joy and fear often arrive together, because this matters "
            "so much. Feeling both is normal."),
      ),
    ],
    evidence: _en('WHO guide for integration of perinatal mental health in '
        'maternal and child health services (2022) · Tele-MANAS, National '
        'Tele Mental Health Programme, Ministry of Health and Family Welfare '
        '(2022) · NICE guideline CG192, Antenatal and postnatal mental health '
        '(2014, updated 2020) · ACOG Clinical Practice Guideline 4, Screening '
        'and diagnosis of mental health conditions during pregnancy and '
        'postpartum (2023).'),
    readNext: [
      'preg_first_read_no_symptoms',
      'preg_first_read_when_to_tell',
    ],
  ),

  // ===========================================================================
  //  TELLING PEOPLE
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  When to tell
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_when_to_tell',
    hue: _hue,
    kicker: _kTell,
    title: _en('When to tell people'),
    teaser: _en("Why many couples wait until 12 weeks, the good reasons to "
        "tell sooner, and getting through the weeks when no one knows."),
    shortAnswer: _en("There's no right time, only the one that suits you. "
        "Many couples wait until after the 12-week scan, when most early "
        "losses have passed. Others tell a few close people sooner so they "
        "have help. You can tell different people at different times."),
    scaleSetter: _en("Whether you tell everyone this week or keep it to "
        "yourselves for months, it doesn't change anything for your baby. "
        "It's a choice about support and privacy, and it's yours."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Some women want to tell the whole world the moment the test "
              "turns positive. Others want to wait until they can see a bump. "
              "Most feel somewhere in between, and often a husband and wife "
              "feel differently. Talking it through together first saves "
              "hurt later."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do many people wait until 12 weeks?'),
        paragraphs: [
          _en("Most miscarriages happen before 12 weeks. By then you've "
              "usually had your dating scan and perhaps the 11 to 13 week "
              "scan, and many women feel steadier. If a loss does happen "
              "early, fewer people need to be told."),
          _en("In many Indian families there's also a custom of not "
              "announcing early, sometimes to keep away nazar (the evil eye). "
              "Whatever the reason, waiting is a common and reasonable "
              "choice."),
        ],
      ),
      PvReadSection(
        heading: _en('Why might I tell sooner?'),
        bullets: [
          _en("You're sick or exhausted and need help at home."),
          _en("Your work involves heavy lifting, chemicals, radiation or "
              "night shifts, and needs to change now."),
          _en("It's getting hard to hide, or the excuses are wearing you "
              "down."),
          _en("If something did go wrong, you'd want people around you "
              "rather than grieving alone."),
          _en("After IVF or a loss, some women want support early. Others "
              "want to wait longer. Both make sense."),
        ],
      ),
      PvReadSection(
        heading: _en('Who should I tell first?'),
        paragraphs: [
          _en("A common order is your husband, then a doctor, then one or two "
              "people you trust most. Close family often comes next, then "
              "work, then everyone else. Before you tell anyone, decide "
              "whether they can share the news, and say so clearly."),
          _en("Your doctor should hear early even if nobody else does, "
              "especially if you take regular medicine, work with anything "
              "hazardous, or have had a loss. What you tell your doctor stays "
              "private."),
        ],
      ),
      PvReadSection(
        heading: _en("How do I get through the weeks when no one knows?"),
        bullets: [
          _en("Keep dry snacks and water in your bag for nausea at work or "
              "on the bus."),
          _en("At functions, a glass of juice or soda in your hand stops most "
              "questions. \"I'm on medicine\" or \"not tonight\" is enough."),
          _en("If a festival fast comes up, you don't have to keep it the "
              "old way. Eat something discreetly, or say you're not well. Ask "
              "your doctor "
              "before any long fast."),
          _en("Book early-morning appointments, or say you have a checkup, "
              "which is true."),
          _en("Loose kurtas and dupattas help if you're bloated."),
          _en("If your job has safety risks, you can tell one person at work, "
              "such as HR or your manager, and ask them to keep it private."),
        ],
        paragraphs: [
          _en("You don't owe anyone an explanation. Mind & mood has a read on "
              "the feelings of these weeks, \"The secret months, carried "
              "alone\"."),
        ],
      ),
      PvReadSection(
        heading: _en("What if something goes wrong after we've told people?"),
        paragraphs: [
          _en("This is the fear behind waiting, and it's worth thinking "
              "about. If it happens, you don't have to tell everyone "
              "yourself. You can ask one trusted person to pass the news on, "
              "and to ask others to give you space. A short line is enough: "
              "\"We lost the pregnancy. We're being looked after, and we'll "
              "talk when we're ready.\""),
          _en("Many women who have been through it say they were glad the "
              "people close to them knew, because it meant they had help. "
              "ParentVeda has an After a loss section, with words for "
              "telling family, if you ever need it."),
        ],
      ),
      PvReadSection(
        heading: _en('Telling friends who are trying for a baby'),
        paragraphs: [
          _en("If a friend or sister has been trying for a long time, or has "
              "had a loss, think about telling her privately and early, "
              "before a group announcement. A message can be kinder than "
              "a call, so she can react in her own time. She may be happy "
              "for you and sad for herself at once. Both are allowed."),
        ],
      ),
      PvReadSection(
        heading: _en('What about social media?'),
        paragraphs: [
          _en("Wait until you're comfortable, and tell close family before "
              "they read it online. If you share a scan photo, crop out your "
              "name, the hospital and the dates printed on it."),
          _en("If the pregnancy wasn't planned, or you're still sorting out "
              "how you feel, you don't have to tell anyone until you're "
              "ready. Your doctor can talk it through with you in "
              "confidence."),
        ],
      ),
    ],
    whenToSeeSomeone: _tellCall,
    faqs: [
      PvReadFaq(
        question: _en("My husband wants to tell everyone and I don't. What do "
            "we do?"),
        answer: _en("Agree on a small circle for now and a date to talk again, "
            "for example after your 12-week scan."),
      ),
      PvReadFaq(
        question: _en('Is it bad luck to tell early?'),
        answer: _en("Telling people doesn't change what happens in a "
            "pregnancy. If the custom matters to your family, it's fine to "
            "follow it."),
      ),
      PvReadFaq(
        question: _en('Do I have to tell work by a certain week?'),
        answer: _en("There's no rule to tell early, but you'll need to give "
            "written notice before your leave. The read on telling your boss "
            "has more."),
      ),
    ],
    evidence: _en('ACOG Practice Bulletin 200, Early pregnancy loss (2018) · '
        'NICE guideline NG126, Ectopic pregnancy and miscarriage (2019, '
        'updated 2023) · Ministry of Health and Family Welfare, antenatal '
        'care guidance.'),
    readNext: [
      'preg_first_read_telling_family',
      'preg_work_read_telling_your_boss',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Telling family
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_first_read_telling_family',
    hue: _hue,
    kicker: _kTell,
    title: _en('Telling your family'),
    teaser: _en("Who hears first, the flood of advice, and a kind, firm "
        "answer to \"boy or girl?\""),
    shortAnswer: _en("Tell your family when it feels right to you both, and "
        "decide together who hears first, so neither side feels left out. "
        "Expect advice and guesses about \"boy or girl\". You can answer "
        "kindly: \"We'll love whoever comes.\" No one, including your doctor, "
        "will tell you the baby's sex, because that's the law."),
    scaleSetter: _en("For most families this is happy news, and the fuss that "
        "follows comes from love. A little planning helps you keep the joy "
        "and set gentle limits on the rest."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("In India, a pregnancy is rarely just a couple's news. Parents, "
              "in-laws, aunts and cousins will all have feelings about it, "
              "and opinions. Deciding a few things together first makes the "
              "telling easier."),
        ],
      ),
      PvReadSection(
        heading: _en('Who should we tell first?'),
        paragraphs: [
          _en("Talk it over as a couple. If both sets of parents are close, "
              "telling them at the same time, or on the same day, can prevent "
              "hurt feelings. In a joint family, elders may expect to hear "
              "before anyone else, and it can be kind to let them."),
          _en("You don't need a big announcement. A box of mithai, a quiet "
              "word after dinner, a video call, or telling them on a festival "
              "day all work. Say whether they can share it, and with whom."),
        ],
      ),
      PvReadSection(
        heading: _en('What if they react differently from what I hoped?'),
        paragraphs: [
          _en("Some relatives cry with joy. Others worry out loud about money, "
              "your age, your health or your job. A first reaction is often "
              "surprise, and it usually softens. Give people a little time, "
              "and let your husband talk to his own family if it gets "
              "difficult."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I answer "boy or girl?"'),
        paragraphs: [
          _en("You'll hear guesses from the shape of your bump, your "
              "cravings, your skin, or a ring swinging on a thread. These are "
              "old games and none of them can tell. It's fine to smile and "
              "let them pass."),
          _en("Under the Pre-Conception and Pre-Natal Diagnostic Techniques "
              "(PCPNDT) Act, 1994, no doctor, scan centre or test may reveal "
              "the sex of a baby before birth, and asking them to is an "
              "offence too. So no one will tell you, and you don't have to "
              "ask."),
          _en("Some women face real pressure for a son. That pressure isn't "
              "your fault, and a baby of either sex is equally welcome and "
              "equally precious. A calm line helps: \"We'll be happy with a "
              "healthy baby, whoever it is.\""),
        ],
        tip: PvReadTip(
          title: _en('Let him answer too'),
          body: _en("When your husband says it to his own family, it often "
              "lands better and ends the question sooner."),
        ),
      ),
      PvReadSection(
        heading: _en('What do I do with all the advice?'),
        paragraphs: [
          _en("You'll hear about ghee, papaya, coconut water, eating for two, "
              "not lifting your arms, and much more. Some of it is wise, some "
              "of it is outdated, and all of it comes from someone who cares."),
          _en("One line covers most of it: \"Thank you, I'll check with my "
              "doctor.\" Then follow what your doctor says. If a custom is "
              "safe and makes your family happy, there's no harm in joining "
              "in."),
        ],
      ),
      PvReadSection(
        heading: _en('What about customs and ceremonies?'),
        paragraphs: [
          _en("Some families mark the news with a puja or a visit to a "
              "temple, and many wait for a ceremony such as godh bharai in "
              "the seventh month to celebrate openly. You can choose what "
              "feels right for you both."),
          _en("If a custom involves fasting, long travel, or foods or "
              "remedies you're unsure about, check with your doctor first. "
              "Most customs can be adapted, and elders usually understand "
              "when you explain it's on medical advice."),
        ],
      ),
      PvReadSection(
        heading: _en('If your family has waited a long time for this'),
        paragraphs: [
          _en("After years of trying, IVF, or a loss, your parents may cry, "
              "worry, or want to do everything for you. Their fear can feel "
              "heavy on top of yours. It's okay to share less, to ask them "
              "for specific help, and to tell them what you don't want to "
              "hear."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I set gentle limits?'),
        bullets: [
          _en("Ask people not to pass on the news until you say so."),
          _en("It's okay to say no to visits when you're sick or tired."),
          _en("You can ask people not to touch your tummy, or to comment on "
              "your weight."),
          _en("Agree with your husband on who handles which relative."),
        ],
        paragraphs: [
          _en("If anyone at home hurts you, threatens you or controls what "
              "you eat, where you go or whether you see a doctor, that's "
              "never okay, and pregnancy doesn't make it your duty to bear "
              "it. Tell your doctor, or call the women's helpline on 181. In "
              "an emergency, call 112."),
        ],
      ),
    ],
    whenToSeeSomeone: _tellCall,
    faqs: [
      PvReadFaq(
        question: _en("Can a scan centre tell us if we pay extra?"),
        answer: _en("No. It's against the law for anyone to reveal the sex "
            "before birth, whatever is offered. Scans are there to check your "
            "baby's health."),
      ),
      PvReadFaq(
        question: _en("My mother-in-law told everyone before we were ready. "
            "What now?"),
        answer: _en("It's done, and it came from excitement. Let your husband "
            "talk to her, and agree how news will be shared from now on."),
      ),
      PvReadFaq(
        question: _en('Should we tell family about a scan result that worries '
            'us?'),
        answer: _en("Only if it helps you. It's fine to wait until your "
            "doctor has explained what it means."),
      ),
    ],
    evidence: _en('Pre-Conception and Pre-Natal Diagnostic Techniques '
        '(Prohibition of Sex Selection) Act, 1994 · Protection of Women from '
        'Domestic Violence Act, 2005 · Women Helpline 181, Ministry of Women '
        'and Child Development · WHO recommendations on antenatal care for a '
        'positive pregnancy experience (2016).'),
    readNext: [
      'preg_scan_read_sex_law',
      'preg_ready_read_older_child',
      'preg_first_read_when_to_tell',
    ],
  ),
];

/// A read in this file by id, or null.
PvRead? firstWeeksReadById(String id) {
  for (final r in kPregnancyReadsFirst) {
    if (r.id == id) return r;
  }
  return null;
}
