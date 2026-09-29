// =============================================================================
//  Work, money and rights — the reads behind the pregnancy door
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Work, money and rights", P2: *"Their answers are
//  American; ours do not exist."* What to Expect has 11 career and 23 money
//  articles written for the US (FMLA, US insurance); Flo has a baby budget
//  course. These are our own versions, written for India, in the pregnancy
//  voice (`docs/PREG-VOICE.md`), never their sentences.
//
//  Every read here sits on a tile of `kWorkMoneyDoor`
//  (`pv_door_work_money.dart`); `test/pv_door_work_money_test.dart` fails if
//  one is orphaned.
//
//  ⚠️ THE LINE THIS FILE HOLDS ON LAW AND MONEY
//
//  · Only facts we are sure of, each tied to the Act, rule or scheme that
//    gives it, and worded as "you may be entitled to" with a pointer to HR,
//    the insurer or the scheme office. Laws and amounts change; the reads
//    say so, and the door's Leave and Money tabs carry the same note.
//  · The Maternity Benefit Act, 1961 as amended in 2017 is named because it
//    is what HR teams and payslips still cite. Its maternity rules are carried
//    into the Code on Social Security, 2020; one line says so rather than
//    dating when each state moved.
//  · Private delivery costs: one rough range only, the same one the TTC read
//    `ttc_read_money_before_baby` already ships, marked as rough and followed
//    by "ask for a written estimate". No other rupee figure is invented; the
//    scheme amounts are the schemes' own.
//  · Every read ends at a person with the urgent tone, because a worry about
//    a job or a bill must never delay care. The money reads say care in a
//    government hospital is free under JSSK.
//  · No sentence puts "your" beside a chance word
//    (`test/pregnancy_reads_shape_test.dart`).
//  · `reviewed: false`, ParentVeda editorial. No lawyer, insurer or clinician
//    has read these yet; the build report lists every claim to check.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The Work, money and rights bracket's own hue (`pregnancy_brackets.dart`),
/// so a read opened from the door keeps the door's colour.
const double _hue = 226;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('Work, money and rights');
final LocalizedText _kWork = _en('Work');
final LocalizedText _kLeave = _en('Leave and rights');
final LocalizedText _kMoney = _en('Money');

/// The work reads' call line: the pregnancy warning signs, with the job put
/// second in plain words.
final PvCallout _workCall = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Leave work and get care straight away if'),
  body: _en("You have bleeding from your vagina, fluid leaking, strong pain in "
      "your tummy, a severe headache with blurred vision, fits, or you faint. "
      "The same goes if your baby is moving less than usual. Your work can "
      "wait. Call your doctor or go to hospital, and for heavy bleeding or "
      "fainting call 108 for an ambulance."),
);

/// The leave and rights reads' call line: the same signs, and help for the
/// worry itself.
final PvCallout _rightsCall = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Your health comes before any job'),
  body: _en("If you have bleeding, fluid leaking, strong pain in your tummy, a "
      "severe headache with blurred vision, fits, or your baby is moving less "
      "than usual, go to hospital straight away, whatever is happening at "
      "work. Ask the doctor for a certificate for your employer afterwards. "
      "If worry about your job is stopping you sleeping or eating, or you "
      "feel you can't cope, talk to your doctor, or call Tele-MANAS free on "
      "14416, day and night."),
);

/// The money reads' call line: cost must never delay care.
final PvCallout _moneyCall = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en("Don't let cost delay care"),
  body: _en("If you have bleeding, fluid leaking, strong pain in your tummy, a "
      "severe headache with blurred vision, fits, a high fever, or your baby "
      "is moving less than usual, go to the nearest hospital straight away. "
      "Pregnancy and delivery care in government hospitals is free under the "
      "Janani Shishu Suraksha Karyakram (JSSK), and so is the ambulance. Call "
      "102 or 108 in most states."),
);

/// The paternity read's call line: the weeks after the birth, which is when
/// his leave falls.
final PvCallout _afterBirthCall = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('After the birth, get help straight away if'),
  body: _en("You have heavy bleeding, a fever, a severe headache, chest pain "
      "or breathlessness, or pain and swelling in one leg. Call your doctor "
      "or go to hospital, and call 108 if it's heavy bleeding or chest pain. "
      "If you have thoughts of harming yourself or your baby, tell your "
      "partner or someone close and get help now: call Tele-MANAS free on "
      "14416, or 112 in an emergency. For your baby, call the doctor straight "
      "away if they won't feed, are hard to wake, have a fever or are "
      "breathing fast."),
);

final List<PvRead> kPregnancyReadsWork = [
  // ===========================================================================
  //  WORK
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Working while pregnant
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_working_while_pregnant',
    hue: _hue,
    kicker: _kWork,
    title: _en('Working while pregnant: getting through the day'),
    teaser: _en("Tiredness, the commute, sitting and standing, and the small "
        "changes that make a working day easier."),
    shortAnswer: _en("Most women can keep working through a healthy pregnancy, "
        "often until a few weeks before the due date. What helps most is small "
        "changes: regular breaks, water and snacks at hand, a seat on the "
        "commute, and asking for help early. If your doctor says your work "
        "needs to change, that comes first."),
    scaleSetter: _en("Women in India work through pregnancy in offices, shops, "
        "schools, hospitals, kitchens and fields. Feeling tired, sick or slow "
        "at work is common, and it doesn't mean you're coping badly. For most "
        "women it eases in the middle months."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Some days you'll feel like yourself at work. Other days a 10 am "
            "meeting will feel like the end of a long shift. Both are normal. "
            "Your body is doing a lot of work that nobody can see yet."),
        _en("You don't have to prove anything by pushing through. A few small "
            "changes, and a word with the right person at work, usually make "
            "the day much easier."),
      ]),
      PvReadSection(
        heading: _en('Why am I so tired at work?'),
        paragraphs: [
          _en("In the first three months, rising hormones, a growing blood "
              "supply and building the placenta take a lot of energy. Many "
              "women also feel sick, often worst in the morning or when "
              "they're hungry. By the middle months most women get some "
              "energy back. In the last months, the weight of your bump, "
              "broken sleep and heartburn can make you tired again."),
        ],
        bullets: [
          _en("Take a short break every hour or so. Stand up, stretch, walk "
              "to the window, refill your water."),
          _en("Do your hardest work at the time of day you feel best."),
          _en("Eat something small every two to three hours, so your energy "
              "doesn't dip."),
          _en("Go to bed earlier on work nights, and rest after work without "
              "guilt. The housework can wait or be shared."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I get through the commute?'),
        paragraphs: [
          _en("A crowded train, bus or metro is hard when you're sick, tired "
              "or carrying a bump. Being on your feet in a crush for an hour "
              "is tiring, and a sudden jolt can make you lose your balance."),
        ],
        bullets: [
          _en("Use the ladies' coach or women's compartment where there is "
              "one. It's usually less crowded, and women often make room "
              "for a pregnant woman."),
          _en("Ask for a seat. Many buses and metros have reserved or "
              "priority seats, and most people will stand up if you ask. You "
              "don't need to be showing to ask."),
          _en("If you can, ask to shift your hours so you travel outside the "
              "rush, even by 30 minutes."),
          _en("Keep water, a small snack and a paper bag in your handbag on "
              "sick days."),
          _en("Autos and cabs are fine. Bumpy roads are uncomfortable but "
              "don't harm your baby. If you ride a scooter or bike, ask your "
              "doctor about it, especially later on as your balance changes."),
        ],
        tip: PvReadTip(
          title: _en('Wearing a seatbelt with a bump'),
          body: _en("Always wear it. Put the lap belt low, under your bump and "
              "across the tops of your thighs, and the shoulder belt between "
              "your breasts and to the side of your bump. Never put the belt "
              "across the middle of your bump."),
        ),
      ),
      PvReadSection(
        heading: _en('Is sitting all day, or standing all day, a problem?'),
        paragraphs: [
          _en("Neither is harmful in itself, but staying in one position for "
              "hours can make your back ache and your feet and ankles swell."),
          _en("If you sit at a desk, get up every 30 to 60 minutes. Keep your "
              "feet on a small stool or a box, sit with a cushion behind your "
              "lower back, and don't cross your legs for long."),
          _en("If you stand for your work, as many teachers, nurses, shop and "
              "factory workers do, sit whenever you can and move your weight "
              "from foot to foot. Wear flat, cushioned shoes. Later in "
              "pregnancy, ask for a chair or a stool at your counter or "
              "station. It's a reasonable request, and you can ask your doctor "
              "for a note to support it."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps with nausea and hunger at work?'),
        bullets: [
          _en("Keep a snack drawer: roasted chana, makhana, plain biscuits, "
              "fruit, nuts or a small box of poha."),
          _en("Sip water through the day. A bottle on your desk helps you "
              "notice how much you've had."),
          _en("If the smell of the pantry or canteen sets you off, eat "
              "somewhere else, or ask a colleague to warm your lunch."),
          _en("A seat near the washroom helps, both for nausea and for the "
              "many bathroom trips."),
          _en("If you're vomiting many times a day or can't keep water down, "
              "call your doctor. That needs treatment, not a stronger will."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I work from home?'),
        paragraphs: [
          _en("There's no general rule in Indian law that says you can work "
              "from home while you're pregnant. But many employers agree to it "
              "for some days a week, especially on bad days in the first months "
              "or in the last weeks, if the job allows it."),
          _en("It helps to ask with a plan: which days, how you'll stay in "
              "touch, and what will get done. If your doctor thinks a long "
              "commute isn't good for you, a note from them makes the request "
              "easier. After your maternity leave, the Maternity Benefit Act "
              "lets your employer allow work from home on terms you both agree, "
              "where the work suits it."),
        ],
      ),
      PvReadSection(
        heading: _en('How long can I keep working?'),
        paragraphs: [
          _en("If your pregnancy is healthy and your work isn't physically "
              "hard, you can usually work for as long as you feel well. Many "
              "women stop a few weeks before the due date. Under the Maternity "
              "Benefit Act, up to 8 of your 26 weeks of leave can be taken "
              "before your due date."),
          _en("If you have a condition such as high blood pressure, or a "
              "twin pregnancy, or your work is heavy, your doctor may suggest "
              "stopping earlier or changing what you do. Follow their advice. "
              "Our read on planning your leave goes through when to start it."),
        ],
      ),
    ],
    whenToSeeSomeone: _workCall,
    faqs: [
      PvReadFaq(
        question: _en('My manager wants me to stay late every day. What can I '
            'do?'),
        answer: _en("Tell them plainly that you need to keep to your hours for "
            "now, and offer what you can do instead. If your doctor has "
            "advised shorter hours or rest, ask for a note and share it. If "
            "it doesn't change, speak to HR."),
      ),
      PvReadFaq(
        question: _en('Is it okay to take the stairs at work?'),
        answer: _en("Yes, if you feel steady. Hold the rail, go at your own "
            "pace, and take the lift when you're tired or carrying things. "
            "Later in pregnancy your balance changes, so go slowly."),
      ),
      PvReadFaq(
        question: _en('Can I keep my laptop on my lap?'),
        answer: _en("Yes. Laptops don't harm your baby. You may find it more "
            "comfortable on a table as your bump grows, and a raised screen "
            "is kinder to your neck."),
      ),
      PvReadFaq(
        question: _en("My family says I should stop working now that I'm "
            "pregnant. Should I?"),
        answer: _en("That's your choice to make with your doctor. In a healthy "
            "pregnancy, working is safe for most women, and many find it "
            "helps them feel like themselves. If your work is heavy or your "
            "doctor has concerns, that changes things."),
      ),
    ],
    evidence: _en('Maternity Benefit Act, 1961, as amended by the Maternity '
        'Benefit (Amendment) Act, 2017 · ACOG Committee Opinion 733, '
        'Employment considerations during pregnancy and the postpartum period '
        '(2018) · NICE guideline NG201, Antenatal care (2021) · Ministry of '
        'Health and Family Welfare, Mother and Child Protection card.'),
    readNext: [
      'preg_work_read_safe_at_work',
      'preg_work_read_telling_your_boss',
      'preg_work_read_planning_leave',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Telling your boss
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_telling_your_boss',
    hue: _hue,
    kicker: _kWork,
    title: _en("Telling your boss you're pregnant"),
    teaser: _en("When to tell work, who to tell first, what to say, and what "
        "to ask about your leave."),
    shortAnswer: _en("There's no fixed time you have to tell work. Many women "
        "wait until after the first trimester scan, but tell sooner if your "
        "job is physically hard, involves chemicals or night shifts, or you "
        "need time off for sickness or checkups. Tell your manager yourself, "
        "keep it short, and follow up in writing."),
    scaleSetter: _en("Telling work can feel harder than telling family. Most "
        "managers have had this conversation before, and many will be kind "
        "about it. Planning what you'll say takes most of the worry out of it."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("You may be worried about how your boss will react, what it means "
            "for a promotion, or who will do your work while you're away. "
            "Those worries are common. Going in with a plan helps you stay "
            "calm and makes the conversation about the practical things."),
      ]),
      PvReadSection(
        heading: _en('When should I tell work?'),
        paragraphs: [
          _en("The law doesn't set a date for telling your employer you're "
              "pregnant. The Maternity Benefit Act asks you to give written "
              "notice of your leave, and your leave can start up to 8 weeks "
              "before your due date. So there's time."),
          _en("Many women wait until after the first trimester scan, around 12 "
              "weeks, when they feel more settled. There are good reasons to "
              "tell earlier:"),
        ],
        bullets: [
          _en("Your work is physically hard, or involves heavy lifting, "
              "chemicals, radiation, heat or night shifts, and needs to "
              "change."),
          _en("You're very sick or tired and need time off or a lighter "
              "load."),
          _en("You'll need time for checkups and scans during working "
              "hours."),
          _en("You'd rather your manager hears it from you than from the "
              "office grapevine."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm too sick to wait?"),
        paragraphs: [
          _en("Some women are so sick in the early weeks that they can't "
              "keep up at work, long before they're ready to tell anyone. If "
              "that's you, you can take sick leave with a certificate from "
              "your doctor. The certificate doesn't have to say you're "
              "pregnant."),
          _en("If the sickness goes on for weeks, it's often easier to tell "
              "your manager early, so they understand why and can make room "
              "for it. Severe vomiting in pregnancy (hyperemesis gravidarum) "
              "is a medical condition, and it's treated like one."),
        ],
      ),
      PvReadSection(
        heading: _en('Who should I tell first?'),
        paragraphs: [
          _en("Usually your direct manager, in person or on a private call. "
              "Then HR, who can tell you the leave and insurance details in "
              "writing. In a small office, the owner may be both."),
          _en("If you trust a colleague, you may want to tell them first. "
              "Just ask them to keep it to themselves until you've spoken to "
              "your manager."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I say?'),
        paragraphs: [
          _en("Keep it short and clear. You don't have to share medical "
              "details, only what affects your work. Here's one way to say "
              "it, which you can change to sound like you:"),
          _en("\"I wanted you to hear this from me first. I'm pregnant, and "
              "the baby is due in (month). I'm feeling well and plan to keep "
              "working until around (month). I'd like to plan my maternity "
              "leave and a handover with you. Could we find some time next "
              "week to go through it?\""),
          _en("If you're having a hard time with sickness, you can add: \"The "
              "first few months have been tiring, so I may need some "
              "flexibility for a while. I'll keep you posted.\""),
        ],
        tip: PvReadTip(
          title: _en('Follow up in writing'),
          body: _en("After you've talked, send a short email: thank them, "
              "give your due date, and say you'll share your leave dates "
              "soon. It keeps a record of what was agreed, which helps if "
              "anything is questioned later."),
        ),
      ),
      PvReadSection(
        heading: _en('What should I ask about?'),
        paragraphs: [
          _en("Ask HR for the company's maternity policy in writing. It "
              "should cover at least what the law gives, and some give more. "
              "These are worth asking:"),
        ],
        bullets: [
          _en("How many weeks of paid leave you'll get, and how to apply."),
          _en("Whether the company health insurance covers the delivery, up "
              "to what limit, and how to add your baby."),
          _en("How time off for checkups and scans works."),
          _en("Whether your duties can change if your work is heavy or "
              "risky, or your hours if the commute is hard."),
          _en("Whether you can work from home some days."),
          _en("Whether there's a crèche, and what the policy is on nursing "
              "breaks when you're back."),
        ],
      ),
      PvReadSection(
        heading: _en("What if the reaction isn't kind?"),
        paragraphs: [
          _en("Most conversations go better than women expect. If yours "
              "doesn't, stay calm and keep it short. You don't have to "
              "answer questions about whether you'll come back, or how many "
              "children you plan to have."),
          _en("Write down what was said, with the date. Then speak to HR. If "
              "you're told you may lose your job because you're pregnant, "
              "read our piece on your rights at work. The Maternity Benefit Act "
              "protects you in several ways, and there are people who can help."),
        ],
      ),
    ],
    whenToSeeSomeone: _workCall,
    faqs: [
      PvReadFaq(
        question: _en('Do I have to tell work about my IVF or a past loss?'),
        answer: _en("No. You only need to share what affects your work, like "
            "your due date, time off for appointments, or duties your doctor "
            "has asked you to avoid. The rest is your own."),
      ),
      PvReadFaq(
        question: _en("What if I'm told in a job interview that they'd rather "
            "not hire a pregnant woman?"),
        answer: _en("Write down what was said, with the date and names. Our "
            "read on your rights at work covers changing jobs while "
            "pregnant, and who you can ask for advice."),
      ),
      PvReadFaq(
        question: _en('Should I tell my clients too?'),
        answer: _en("Tell your manager first. Then agree together when and "
            "how to tell clients, usually once the handover plan is ready."),
      ),
    ],
    evidence: _en('Maternity Benefit Act, 1961, as amended by the Maternity '
        'Benefit (Amendment) Act, 2017 · ACOG Committee Opinion 733, '
        'Employment considerations during pregnancy and the postpartum period '
        '(2018).'),
    readNext: [
      'preg_work_read_planning_leave',
      'preg_work_read_maternity_leave',
      'preg_work_read_your_rights',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Safe at work
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_safe_at_work',
    hue: _hue,
    kicker: _kWork,
    title: _en('Staying safe at work'),
    teaser: _en("Heat, chemicals, night shifts and heavy lifting: what to "
        "change, what's fine, and how to ask."),
    shortAnswer: _en("Most jobs are safe in pregnancy. A few things need "
        "changing: heavy lifting, long hours in heat, some chemicals and "
        "fumes, radiation, some infections, and a lot of night shifts. "
        "Computer screens, laptops and phones are fine. Tell your doctor what "
        "your work involves, and ask your employer for changes early."),
    scaleSetter: _en("If you work at a desk, in a shop or in a classroom, "
        "most of what you do is already safe. If your work involves heat, "
        "chemicals or heavy loads, small changes usually solve it, and your "
        "doctor can help you ask for them."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Start by telling your doctor exactly what you do in a day: the "
            "hours, what you lift, what you breathe in or touch, and how hot "
            "it gets. They know your pregnancy and can tell you what should "
            "change for you."),
        _en("The things below are what doctors and workplace health guidance "
            "most often ask pregnant women to look at."),
      ]),
      PvReadSection(
        heading: _en('What about heat?'),
        paragraphs: [
          _en("In pregnancy your body already runs a little warmer, and you "
              "get dehydrated more quickly. Hot kitchens, factory floors, "
              "outdoor work and Indian summers, especially in a heatwave, can "
              "make you dizzy, sick or faint."),
        ],
        bullets: [
          _en("Drink water often, before you feel thirsty. Keep a bottle "
              "with you."),
          _en("Take breaks in the shade or a cool room, and ask for more of "
              "them on hot days."),
          _en("Wear loose, light cotton clothes, and cover your head outside."),
          _en("If you feel dizzy, sick, confused or stop sweating in the heat, "
              "stop work, move somewhere cool, drink water and get help."),
        ],
      ),
      PvReadSection(
        heading: _en('What about chemicals, fumes and infections?'),
        paragraphs: [
          _en("Some substances are best avoided in pregnancy, or handled only "
              "with good protection. If your work involves any of these, "
              "tell your doctor and ask your employer about safer duties:"),
        ],
        bullets: [
          _en("Lead, for example in battery, paint, pottery glaze or "
              "recycling work."),
          _en("Solvents and strong fumes, in painting, printing, dry "
              "cleaning or some factories."),
          _en("Pesticides and weedkillers in farm or garden work."),
          _en("Anaesthetic gases and cancer medicines, for hospital staff."),
          _en("X-rays and other radiation, for radiology and some lab and "
              "industrial staff. Tell your radiation safety officer."),
          _en("Infections such as rubella, chickenpox and CMV, for people "
              "who work closely with young children or with patients. Ask "
              "your doctor to check your immunity."),
        ],
        tip: PvReadTip(
          title: _en('Working in a salon or with cleaning products'),
          body: _en("Work in a well-aired space, wear gloves, take breaks "
              "from strong smells, and don't mix cleaning products. Ask to "
              "leave the harshest jobs, like hair straightening treatments "
              "or strong solvent work, to someone else for now."),
        ),
      ),
      PvReadSection(
        heading: _en('Are night shifts and long hours okay?'),
        paragraphs: [
          _en("Many nurses, doctors, call centre staff and factory workers do "
              "shifts. Some studies suggest that working many night shifts, "
              "or very long hours, is linked with more miscarriage and early "
              "birth. The evidence isn't firm, but it's reason enough to ask "
              "for day shifts where you can, especially in the first months."),
          _en("If you do work nights, protect your sleep in the day, eat "
              "regular meals, and don't do long runs of nights back to back."),
        ],
      ),
      PvReadSection(
        heading: _en('How much can I lift?'),
        paragraphs: [
          _en("There's no single weight limit that suits every woman. As a "
              "rule, lift less than you did before, and lift less as your "
              "pregnancy goes on. Lifting heavy loads often, lifting from the "
              "floor, or lifting above your shoulders are the hardest on your "
              "body."),
          _en("Bend your knees, keep the load close to you, and don't twist "
              "while you lift. Ask for help or a trolley. If lifting is a big "
              "part of your job, ask your doctor what's right for you, and ask "
              "your employer to move you to lighter work for now."),
        ],
      ),
      PvReadSection(
        heading: _en('Are computer screens and phones safe?'),
        paragraphs: [
          _en("Yes. Computer screens, laptops, phones, Wi-Fi, printers and "
              "photocopiers don't harm your baby. The energy they give off "
              "is very low, and not the kind that affects a pregnancy."),
          _en("What screens can do is give you a stiff neck, sore eyes and a "
              "sore back. Raise the screen to eye level, rest your eyes by "
              "looking away every 20 minutes, and get up often."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I ask for changes?'),
        paragraphs: [
          _en("Ask your doctor for a short note that says what you should "
              "avoid, like heavy lifting or night shifts. Take it to your "
              "manager or HR and ask what can change: different duties, "
              "different hours, more breaks, or a chair."),
          _en("The Maternity Benefit Act also says that, if you ask, you "
              "shouldn't be given hard physical work or work with long hours "
              "of standing in the month before the last six weeks of your "
              "pregnancy. Many employers make changes well before that "
              "when asked."),
        ],
      ),
    ],
    whenToSeeSomeone: _workCall,
    faqs: [
      PvReadFaq(
        question: _en('Is the airport body scanner safe if I travel for '
            'work?'),
        answer: _en("Security scanners use very low energy and are considered "
            "safe in pregnancy. Airlines have their own rules later in "
            "pregnancy and often ask for a doctor's letter, so check before "
            "you book."),
      ),
      PvReadFaq(
        question: _en("I'm a teacher. Should I worry about infections at "
            "school?"),
        answer: _en("Tell your doctor you work with children. They can check "
            "whether you're immune to rubella and chickenpox. Wash your hands "
            "often, and tell your doctor if there's an outbreak at school or "
            "you get a rash."),
      ),
      PvReadFaq(
        question: _en('I work on a farm. What should I change?'),
        answer: _en("Stay away from pesticide spraying and mixing, and from "
            "fields that have just been sprayed. Take breaks in the shade, "
            "drink plenty of water, and leave the heaviest loads to others."),
      ),
    ],
    evidence: _en('Maternity Benefit Act, 1961, as amended by the Maternity '
        'Benefit (Amendment) Act, 2017 · ACOG Committee Opinion 733, '
        'Employment considerations during pregnancy and the postpartum period '
        '(2018) · WHO, Heat and health fact sheet · National Action Plan on '
        'Heat Related Illnesses, Ministry of Health and Family Welfare · RCOG, '
        'Chickenpox in pregnancy, Green-top Guideline 13.'),
    readNext: [
      'preg_work_read_working_while_pregnant',
      'preg_work_read_your_rights',
      'preg_work_read_telling_your_boss',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Planning your leave, and going back
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_planning_leave',
    hue: _hue,
    kicker: _kWork,
    title: _en('Planning your leave, and going back'),
    teaser: _en("When to start your leave, how to hand over calmly, and "
        "thinking about work after your baby comes."),
    shortAnswer: _en("Decide roughly when you'll stop, give your employer "
        "written notice of your leave, and plan a simple handover. Many women "
        "keep most of their leave for after the birth. Whether and when you "
        "go back is yours to decide, and you don't have to decide it now."),
    scaleSetter: _en("Planning your leave can feel like one more job on a long "
        "list. It doesn't have to be done all at once. A date, a written "
        "request and a handover note cover most of it."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("It's common to worry about leave: what happens to your work, "
            "whether people will forget you, whether you'll want to come back. "
            "Most of those questions answer themselves once you've made a "
            "plan and the baby is here. For now, focus on the few things you "
            "can sort out."),
      ]),
      PvReadSection(
        heading: _en('When should I start my leave?'),
        paragraphs: [
          _en("If you're entitled to 26 weeks under the Maternity Benefit Act, "
              "up to 8 of them can be taken before your due date. The rest "
              "are after the birth."),
          _en("Many women work until two to four weeks before the due date, "
              "so they have more time with the baby. Others stop earlier "
              "because the commute or the work is hard, or their doctor "
              "advises it. There's no right answer. Think about how you feel, "
              "how far you travel, and what your doctor says."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I apply for it?'),
        bullets: [
          _en("Give your employer written notice with the date you plan to "
              "start leave. An email to your manager and HR is usually "
              "enough, but follow your company's process."),
          _en("Your company may ask for a doctor's certificate with your due "
              "date. Ask for it at your next checkup."),
          _en("Keep a copy of everything you send and receive."),
          _en("If your baby comes before you've applied, the Maternity "
              "Benefit Act lets you give notice as soon as you can after the "
              "birth."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I hand over without stress?'),
        paragraphs: [
          _en("Start a handover note a few weeks before you plan to stop, "
              "because babies don't always wait for the date. Keep adding to "
              "it."),
        ],
        bullets: [
          _en("What you're working on, and where each thing stands."),
          _en("Who to contact for what, inside and outside the company."),
          _en("Where files and passwords are kept, following your company's "
              "rules."),
          _en("Who will cover each part of your work while you're away."),
          _en("Whether you want to be contacted during leave, and how. It's "
              "fine to say no."),
        ],
        tip: PvReadTip(
          title: _en('Set an out-of-office'),
          body: _en("Write it before your last week, so it's ready even if "
              "you stop suddenly. Name who to contact instead, and don't give "
              "a return date you're not sure of."),
        ),
      ),
      PvReadSection(
        heading: _en('What helps when I go back?'),
        paragraphs: [
          _en("The Maternity Benefit Act gives some support for returning "
              "mothers. You may be entitled to two nursing breaks a day, on "
              "top of your usual rest break, until your baby is 15 months old. "
              "Workplaces with 50 or more employees must have a crèche nearby, "
              "and you can visit your baby there four times a day. After your "
              "leave, your employer may let you work from home on terms you "
              "both agree, if your work allows it."),
          _en("Ask HR about these before you go on leave, and again a month "
              "before you return. A gradual return, such as shorter days or a "
              "few days from home in the first weeks, is worth asking for too."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I plan childcare before I go back?'),
        paragraphs: [
          _en("Start thinking about it a few months before your leave ends. "
              "Good crèches and nannies often have waiting lists, and family "
              "members need time to plan too."),
        ],
        bullets: [
          _en("Visit the crèche or meet the nanny with your baby, and ask "
              "how they handle feeding, sleep and illness."),
          _en("Plan a settling-in period of a week or two, with short days "
              "at first, before you go back full time."),
          _en("If you're breastfeeding and want to carry on, practise "
              "expressing milk and feeding from a cup or bottle a few weeks "
              "before you return."),
          _en("Have a back-up plan for days when your baby is unwell and "
              "can't go to the crèche."),
        ],
      ),
      PvReadSection(
        heading: _en('Should I go back to work at all?'),
        paragraphs: [
          _en("Many women start thinking about this in pregnancy, often with "
              "a lot of opinions from family. Some know they'll go back. Some "
              "know they won't. Many aren't sure, and that's fine."),
          _en("It can help to think about money, who will look after the "
              "baby, how you feel about your work, and what you'd like the "
              "next few years to look like. Talk it through with your "
              "partner. You don't have to decide before the baby comes. Many "
              "women find their answer only after a few months at home, and "
              "some change it later. Any of these choices can be a good one."),
        ],
      ),
    ],
    whenToSeeSomeone: _workCall,
    faqs: [
      PvReadFaq(
        question: _en('What if my baby comes early?'),
        answer: _en("Your leave still applies. Tell your employer as soon as "
            "you can, even by message, and send the formal notice once "
            "you're able. Your handover note will help your team in the "
            "meantime."),
      ),
      PvReadFaq(
        question: _en('Can I add my earned leave to my maternity leave?'),
        answer: _en("Many companies allow it, so you can stay home longer. "
            "Ask HR how your earned leave and any unpaid leave can be added "
            "on, and get the answer in writing."),
      ),
      PvReadFaq(
        question: _en("I feel guilty leaving my team busy. Is that normal?"),
        answer: _en("Very. But your leave is part of your job's terms, not a "
            "favour. A good handover is all your team needs from you."),
      ),
    ],
    evidence: _en('Maternity Benefit Act, 1961, as amended by the Maternity '
        'Benefit (Amendment) Act, 2017 · Ministry of Labour and Employment, '
        'Maternity Benefit Amendment Act 2017: frequently asked questions.'),
    readNext: [
      'preg_work_read_maternity_leave',
      'preg_work_read_paternity_leave',
      'preg_work_read_money_plan',
    ],
  ),

  // ===========================================================================
  //  LEAVE AND RIGHTS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Maternity leave under the Act
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_maternity_leave',
    hue: _hue,
    kicker: _kLeave,
    title: _en('Maternity leave: your 26 weeks'),
    teaser: _en("What the Maternity Benefit Act gives you, who it covers, and "
        "what to check with HR."),
    shortAnswer: _en("If you work somewhere with 10 or more employees and have "
        "worked there for at least 80 days in the 12 months before your due "
        "date, you may be entitled to 26 weeks of paid maternity leave under "
        "the Maternity Benefit Act. Up to 8 weeks can be before your due date. "
        "From your third child, it's 12 weeks."),
    scaleSetter: _en("Most women in formal jobs in India are covered by this "
        "law, and many companies follow it closely. Your company's policy can give you more than the law, but not less. HR "
        "can confirm exactly what applies to you."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("India's main law on maternity leave is the Maternity Benefit Act, "
            "1961. It was changed in 2017 to give longer leave and add new "
            "support for mothers going back to work. The newer Code on Social "
            "Security, 2020 carries these maternity rules over."),
        _en("Here's what it says, in plain words. Use it to understand your "
            "company's policy and to know what to ask. For your exact "
            "situation, check with HR."),
      ]),
      PvReadSection(
        heading: _en('How much leave does the law give?'),
        bullets: [
          _en("26 weeks of paid leave for each of your first two children. Up "
              "to 8 of those weeks can be taken before your due date."),
          _en("12 weeks if you already have two or more children. Up to 6 of "
              "those weeks can be before your due date."),
          _en("12 weeks if you adopt a baby under three months old, or have "
              "a baby through surrogacy as the commissioning mother, from the "
              "day the baby is handed to you."),
          _en("6 weeks of leave after a miscarriage or a medical termination "
              "of pregnancy."),
          _en("Up to one extra month if you're unwell because of the "
              "pregnancy, the birth, an early birth or a miscarriage, with a "
              "medical certificate."),
        ],
        tip: PvReadTip(
          title: _en('Fewer weeks before means more after'),
          body: _en("The 8 weeks before your due date are the most you can "
              "take before the birth, not a rule that you must. If you work "
              "until closer to your due date, the weeks you didn't use can "
              "be taken after the birth, so you still have 26 weeks in all."),
        ),
      ),
      PvReadSection(
        heading: _en('Who is covered?'),
        paragraphs: [
          _en("The Act covers women working in factories, mines and "
              "plantations, and in shops and other establishments with 10 or "
              "more employees. That includes most offices, IT companies, "
              "hospitals, schools and shops of that size, in private "
              "companies as well as the public sector."),
          _en("To qualify, you need to have worked for that employer for at "
              "least 80 days in the 12 months before your expected due date. "
              "It covers women employed directly or through an agency."),
          _en("If you're covered by ESIC, your maternity pay usually comes "
              "from ESIC instead of your employer. If you work for the "
              "government, for yourself or in informal work, different rules "
              "apply, and our read on those goes through them."),
        ],
      ),
      PvReadSection(
        heading: _en('How am I paid during leave?'),
        paragraphs: [
          _en("The Act says you're paid your average daily wage for each day "
              "of leave. In most salaried jobs this means your salary carries "
              "on as usual. Some companies pay only the basic part, or treat "
              "allowances differently, so ask HR how your pay will be worked "
              "out."),
          _en("The Act also says the pay for the weeks before the birth can "
              "be paid in advance when you show proof of pregnancy, and the "
              "rest soon after you show proof of the birth."),
        ],
      ),
      PvReadSection(
        heading: _en('What else does the Act give me?'),
        bullets: [
          _en("A medical bonus if your employer doesn't give you free care "
              "before and after the birth. The Act names ₹3,500, and the "
              "government can set a higher amount."),
          _en("Two nursing breaks a day, on top of your usual rest break, "
              "until your baby is 15 months old."),
          _en("A crèche, in workplaces with 50 or more employees, which you "
              "can visit four times a day."),
          _en("Work from home after your leave, if your work allows it and "
              "you and your employer agree the terms."),
          _en("Protection from being dismissed, or having your terms made "
              "worse, while you're on maternity leave."),
          _en("Your employer has to tell you about these benefits in writing "
              "when you join."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I check with HR?'),
        bullets: [
          _en("How many weeks you'll get, and whether the company gives more "
              "than the law."),
          _en("How to apply, and what documents they need."),
          _en("How your pay, bonus and increments are handled during leave."),
          _en("Whether you can add earned leave or unpaid leave."),
          _en("What the policy is on work from home, the crèche and nursing "
              "breaks when you return."),
          _en("Whether the company health insurance covers the delivery and "
              "your baby."),
        ],
        tip: PvReadTip(
          title: _en('Get it in writing'),
          body: _en("Ask for the policy document and your leave dates by "
              "email. If a question comes up later, a written answer is much "
              "easier to rely on than a remembered conversation."),
        ),
      ),
    ],
    whenToSeeSomeone: _rightsCall,
    faqs: [
      PvReadFaq(
        question: _en("I changed jobs recently. Will I still get maternity "
            "leave?"),
        answer: _en("It depends on whether you'll have worked at least 80 days "
            "for your new employer in the 12 months before your due date. If "
            "not, you may not qualify under the Act, though some companies "
            "give leave anyway. Ask HR."),
      ),
      PvReadFaq(
        question: _en('Does it matter if my baby is my third?'),
        answer: _en("Yes. The 26 weeks are for women with fewer than two "
            "children. If you already have two or more, the Act gives 12 "
            "weeks. Your company may give more."),
      ),
      PvReadFaq(
        question: _en('Can my employer ask me to come back early?'),
        answer: _en("They can ask, but you don't have to agree. The Act also "
            "says you shouldn't work in the six weeks after the birth."),
      ),
      PvReadFaq(
        question: _en('I work in a small shop with five people. Am I '
            'covered?'),
        answer: _en("The Act applies to shops and establishments with 10 or "
            "more employees, so you may not be covered by it. Ask your "
            "employer what they'll give, and look at the government schemes "
            "in our money tab."),
      ),
    ],
    evidence: _en('Maternity Benefit Act, 1961, as amended by the Maternity '
        'Benefit (Amendment) Act, 2017 · Code on Social Security, 2020, '
        'Chapter VI, Maternity benefit · Ministry of Labour and Employment, '
        'Maternity Benefit Amendment Act 2017: frequently asked questions.'),
    readNext: [
      'preg_work_read_your_rights',
      'preg_work_read_government_informal',
      'preg_work_read_paternity_leave',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Government, self-employed and informal work
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_government_informal',
    hue: _hue,
    kicker: _kLeave,
    title: _en('Government jobs, self-employed and informal work'),
    teaser: _en("If the Maternity Benefit Act isn't your rulebook: central "
        "government leave, ESIC, and help if you work for yourself."),
    shortAnswer: _en("Central government employees may be entitled to 180 days "
        "of maternity leave under the leave rules. If you're covered by ESIC, "
        "your maternity pay may come from ESIC. If you're self-employed or in "
        "informal work, there's no paid leave law, but schemes like PMMVY, "
        "JSY and JSSK may help. Your HR, ESIC office or anganwadi centre can "
        "confirm."),
    scaleSetter: _en("Not every working woman is covered by the same law. That "
        "doesn't mean there's no help. It means the help comes from a "
        "different place, and it's worth finding out which one is yours."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The Maternity Benefit Act covers most private and public "
            "workplaces with 10 or more employees. But government employees "
            "have their own service rules, many lower-paid workers are "
            "covered through ESIC, and women who work for themselves or in "
            "informal work aren't covered by a leave law at all."),
        _en("Find your situation below. Rules and amounts are updated from "
            "time to time, so check the details before you plan around them."),
      ]),
      PvReadSection(
        heading: _en('I work for the central government. What do I get?'),
        paragraphs: [
          _en("Under the Central Civil Services (Leave) Rules, 1972, you may "
              "be entitled to:"),
        ],
        bullets: [
          _en("180 days of maternity leave if you have fewer than two "
              "children."),
          _en("Child care leave of up to 730 days across your whole service, "
              "to look after your two eldest children until they turn 18."),
          _en("If your husband is a central government employee, he may get "
              "15 days of paternity leave."),
        ],
        tip: PvReadTip(
          title: _en('Ask your establishment section'),
          body: _en("Your office's establishment section or HR can tell you "
              "how to apply, what documents they need, and how your leave "
              "and pay will be recorded."),
        ),
      ),
      PvReadSection(
        heading: _en('I work for a state government, a bank or a PSU'),
        paragraphs: [
          _en("State governments, public sector companies and banks set their "
              "own leave rules. Many give leave similar to the central "
              "government's, but the details differ. Ask your HR or "
              "establishment section for the current rules in writing."),
        ],
      ),
      PvReadSection(
        heading: _en("I'm covered by ESIC. What changes?"),
        paragraphs: [
          _en("ESIC (Employees' State Insurance) covers many workers in "
              "factories and establishments, usually those earning up to "
              "₹21,000 a month. If you're covered, your maternity pay may come "
              "from ESIC rather than your employer, for up to 26 weeks, if "
              "enough contributions have been paid for you in the months "
              "before."),
          _en("ESIC also gives you medical care at its hospitals and "
              "dispensaries during pregnancy and the birth. Ask at your ESIC "
              "branch office or dispensary how to claim, and keep your ESIC "
              "card or number ready."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm not sure which group I'm in?"),
        paragraphs: [
          _en("Start with your payslip. If it shows an ESI deduction, you're "
              "covered by ESIC. If you have an appointment letter from a "
              "company with 10 or more employees, the Maternity Benefit Act "
              "is likely to apply. If you work for a government office, your "
              "service rules apply."),
          _en("If you're not sure, ask your employer in writing which rules "
              "cover your maternity leave. If you get no payslip and no "
              "letter, the government schemes are the place to start, and "
              "your ASHA worker or anganwadi centre can help."),
        ],
      ),
      PvReadSection(
        heading: _en("I'm self-employed or a freelancer"),
        paragraphs: [
          _en("There's no law that gives you paid leave, so your leave is "
              "whatever you can plan for. It helps to start early:"),
        ],
        bullets: [
          _en("Work out how many weeks you'd like to take off, and what that "
              "costs you in lost income."),
          _en("Put aside a little each month now to cover it."),
          _en("Tell regular clients your plans, and line up someone who can "
              "cover urgent work."),
          _en("Check your health insurance for maternity cover and its "
              "waiting period. Our read on insurance goes through it."),
          _en("Look at the government schemes. Some depend on income, not on "
              "the kind of work you do."),
        ],
      ),
      PvReadSection(
        heading: _en('I work in informal work'),
        paragraphs: [
          _en("If you do domestic work, farm work, construction, daily wage "
              "work or run a small shop, these may help:"),
        ],
        bullets: [
          _en("Pradhan Mantri Matru Vandana Yojana (PMMVY): a cash benefit "
              "for eligible women, meant partly to make up for lost wages."),
          _en("Janani Suraksha Yojana (JSY): cash support for giving birth in "
              "a hospital."),
          _en("Janani Shishu Suraksha Karyakram (JSSK): free delivery and "
              "care in government hospitals."),
          _en("If you're a registered construction worker, your state's "
              "construction workers welfare board may give a maternity "
              "benefit."),
          _en("Many states run their own maternity schemes on top of these."),
        ],
        tip: PvReadTip(
          title: _en('Where to ask'),
          body: _en("Your ASHA worker, the anganwadi centre or your nearest "
              "government health centre can tell you which schemes apply to "
              "you and help you register. An e-Shram card can also help you "
              "show you're an informal worker."),
        ),
      ),
    ],
    whenToSeeSomeone: _rightsCall,
    faqs: [
      PvReadFaq(
        question: _en('I work on contract for a government office. Which rules '
            'apply?'),
        answer: _en("It depends on who employs you. If you're hired through "
            "an agency, the agency may be your employer under the Maternity "
            "Benefit Act. Ask both the office and the agency, in writing."),
      ),
      PvReadFaq(
        question: _en('I run my own business. Can I get any cash help?'),
        answer: _en("Some schemes, like PMMVY, depend on your family's income "
            "and other conditions, not on having a job. Ask at your anganwadi "
            "centre whether you qualify."),
      ),
      PvReadFaq(
        question: _en("I'm an ASHA or anganwadi worker. What do I get?"),
        answer: _en("Pregnant ASHA and anganwadi workers are among the groups "
            "PMMVY names. Your supervisor can tell you what your state gives "
            "for leave."),
      ),
    ],
    evidence: _en('Central Civil Services (Leave) Rules, 1972 · Employees\' '
        'State Insurance Act, 1948 · Maternity Benefit Act, 1961, as amended '
        '2017 · Pradhan Mantri Matru Vandana Yojana guidelines (2022), '
        'Ministry of Women and Child Development · Janani Suraksha Yojana and '
        'Janani Shishu Suraksha Karyakram, National Health Mission · Building '
        'and Other Construction Workers Act, 1996.'),
    readNext: [
      'preg_work_read_schemes',
      'preg_work_read_maternity_leave',
      'preg_work_read_money_plan',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  His paternity leave
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_paternity_leave',
    hue: _hue,
    kicker: _kLeave,
    title: _en('His paternity leave'),
    teaser: _en("What fathers can get in India, how to plan it, and how to "
        "make the days count."),
    shortAnswer: _en("There's no law that gives fathers paternity leave in "
        "private jobs, so it depends on his company's policy. Central "
        "government employees may get 15 days. Ask early, and plan the days "
        "for when you'll need him most."),
    scaleSetter: _en("Paternity leave in India is often short, and some fathers "
        "get none. A little planning goes a long way. Even a week or two, well "
        "timed, can make the first weeks much easier for you both."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The first weeks with a newborn are tiring for both parents. "
            "You'll be healing from the birth and feeding round the clock. "
            "Having your partner home, even for a short time, helps you rest, "
            "and helps him learn to care for the baby from day one."),
        _en("This read is for you both. Share it with him if it helps. It "
            "covers what the rules say, what companies usually give, and how "
            "to plan his time off so it lands when you need it most, not "
            "only when it's easiest for his office."),
      ]),
      PvReadSection(
        heading: _en('Does the law give fathers leave?'),
        paragraphs: [
          _en("For private jobs, no. There's no national law on paternity "
              "leave, so it depends on the employer's policy."),
          _en("Central government employees may be entitled to 15 days of "
              "paternity leave under the Central Civil Services (Leave) Rules, "
              "1972, if they have fewer than two children. It can be taken "
              "from 15 days before the birth up to six months after. Some "
              "state governments give paternity leave too, under their own "
              "rules."),
        ],
      ),
      PvReadSection(
        heading: _en('What do private companies give?'),
        paragraphs: [
          _en("It varies a lot. Some give none. Many give a few days to two "
              "weeks. Some larger companies now give several weeks, or offer "
              "parental leave that either parent can take."),
          _en("He should ask HR early in the pregnancy, and get the answer "
              "in writing. It's also worth asking whether he can add earned "
              "leave, work from home for a while, or work shorter hours in "
              "the first weeks."),
        ],
      ),
      PvReadSection(
        heading: _en('When is his leave most useful?'),
        paragraphs: [
          _en("There's no single best time. Think about when you'll have the "
              "least help."),
        ],
        bullets: [
          _en("Straight after the birth, especially after a caesarean, when "
              "you'll need help to move, lift and rest."),
          _en("When family helpers leave, if your mother or mother-in-law is "
              "staying for the first weeks."),
          _en("Split into two parts, if his company allows, so you have help "
              "at the start and again later."),
        ],
      ),
      PvReadSection(
        heading: _en('What can he do in those days?'),
        paragraphs: [
          _en("Leave is most useful when he takes on real jobs, not only "
              "visitors and errands. Here's what helps most:"),
        ],
        bullets: [
          _en("Nappy changes, burping, bathing and settling the baby."),
          _en("At night, bring the baby to you for feeds, and settle them "
              "after, so you can go back to sleep."),
          _en("Make sure you eat, drink water and rest."),
          _en("Keep visitors to a number you're comfortable with."),
          _en("Watch how you're feeling. Tearful days in the first two weeks "
              "are common. Low mood that lasts longer, or doesn't lift, needs "
              "a doctor."),
          _en("Handle the paperwork: register the birth, add the baby to "
              "health insurance, and keep the hospital papers together."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we plan it together?'),
        bullets: [
          _en("Sit down in the middle months and agree when he'll take leave, "
              "and what each of you will do in the first weeks."),
          _en("Ask him to plan a handover at his work too, so he isn't "
              "answering calls while holding the baby."),
          _en("Agree what happens if the baby comes early, or if you need to "
              "stay longer in hospital. Babies rarely arrive on the due date."),
          _en("Keep his manager informed of the due date, so it's not a "
              "surprise when he needs to leave in a hurry."),
        ],
      ),
      PvReadSection(
        heading: _en('What if we live with family?'),
        paragraphs: [
          _en("In many Indian homes, the grandmothers take charge of the baby "
              "in the first weeks. That help is precious. His time at home "
              "still matters. He can learn to hold, change and settle the "
              "baby alongside them, and he can speak up for you when you "
              "need rest or fewer visitors."),
          _en("If you're going to your mother's home for the delivery, his "
              "leave may be most useful when you come back to your own home, "
              "and the help around you is smaller."),
        ],
      ),
      PvReadSection(
        heading: _en('What if he gets little or no leave?'),
        paragraphs: [
          _en("Plan around it together. He could take earned leave, work from "
              "home for a few days, or ask for flexible hours. Line up help "
              "from family or friends for the weeks he's at work, and share "
              "the night-time care on weekends so you both get some sleep."),
          _en("Talk about this before the birth, so you're not deciding it "
              "on no sleep."),
        ],
      ),
    ],
    whenToSeeSomeone: _afterBirthCall,
    faqs: [
      PvReadFaq(
        question: _en('Can he take paternity leave if we adopt?'),
        answer: _en("Central government rules give 15 days of paternity leave "
            "on adoption too. In a private company, it depends on the "
            "policy, so he should ask HR."),
      ),
      PvReadFaq(
        question: _en("His boss makes him feel bad for asking. What can he "
            "say?"),
        answer: _en("He can keep it simple: \"Our baby is due in (month) and "
            "I'd like to take my paternity leave then. I'll plan a handover "
            "so my work is covered.\" Asking for leave the policy gives is "
            "normal."),
      ),
      PvReadFaq(
        question: _en('Is it worth it if he only gets a few days?'),
        answer: _en("Yes. A few days at the right time, like the day you come "
            "home from hospital, can make a big difference."),
      ),
    ],
    evidence: _en('Central Civil Services (Leave) Rules, 1972, paternity '
        'leave rules · Maternity Benefit Act, 1961, as amended 2017 · WHO '
        'recommendations on maternal and newborn care for a positive postnatal '
        'experience (2022) · Registration of Births and Deaths Act, 1969.'),
    readNext: [
      'preg_work_read_planning_leave',
      'preg_work_read_maternity_leave',
      'preg_work_read_baby_budget',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Your rights at work
  // ---------------------------------------------------------------------------
  //  First section carries the myth block: the door's myth tile opens here.
  PvRead(
    id: 'preg_work_read_your_rights',
    hue: _hue,
    kicker: _kLeave,
    title: _en('Your rights at work while pregnant'),
    teaser: _en("What the law protects, changing jobs while pregnant, and what "
        "to do if you're treated unfairly."),
    shortAnswer: _en("Under the Maternity Benefit Act, your employer can't "
        "dismiss you, or make your terms worse, because you're on maternity "
        "leave. If you're let go while pregnant, you may still be entitled to "
        "your maternity benefit. If it happens, keep everything in writing and "
        "contact the labour department or the Labour Commissioner's office."),
    scaleSetter: _en("Most employers treat pregnant employees fairly, and the "
        "law is on your side if one doesn't. Knowing what it says helps you "
        "stay calm and ask for what's yours."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("It's a common fear, and some women do face it. This read goes "
              "through what the law says, and what to do step by step if "
              "you're treated unfairly."),
        ],
        mythFact: PvMythFact(
          myth: _en("A private company can let you go once you tell them "
              "you're pregnant, and there's nothing you can do."),
          fact: _en("The Maternity Benefit Act protects women during "
              "maternity leave, and even if you're let go while pregnant, you "
              "may still be entitled to your maternity benefit. There are "
              "offices whose job is to enforce this."),
        ),
      ),
      PvReadSection(
        heading: _en('What does the law protect?'),
        bullets: [
          _en("While you're on maternity leave, your employer can't dismiss "
              "you, give you a notice that ends during your leave, or change "
              "your terms to your disadvantage."),
          _en("If you're dismissed at any time during pregnancy, and you "
              "would otherwise have qualified, you don't lose your maternity "
              "benefit or medical bonus, unless the dismissal was for serious "
              "misconduct as defined in the rules."),
          _en("You shouldn't be made to work in the six weeks after the "
              "birth, a miscarriage or a medical termination."),
          _en("If you ask, you shouldn't be given hard physical work or long "
              "hours of standing in the month before the last six weeks of "
              "your pregnancy."),
          _en("You may be entitled to nursing breaks, a crèche and work from "
              "home by agreement when you go back, as our maternity leave "
              "read explains."),
        ],
      ),
      PvReadSection(
        heading: _en('Do I get time off for checkups?'),
        paragraphs: [
          _en("The Maternity Benefit Act doesn't set aside separate time off "
              "for antenatal checkups. Most women use sick or casual leave, "
              "or agree flexible hours with their manager. Some companies "
              "have a policy for it, so ask HR."),
          _en("Book early or late appointments where you can, and share the "
              "dates with your manager ahead of time."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm on contract or probation?"),
        paragraphs: [
          _en("The Act counts the days you've worked, not your job title. It "
              "covers women employed directly or through an agency. Being on "
              "probation or a fixed-term contract doesn't by itself take away "
              "your maternity benefit if you meet the 80-day rule."),
          _en("What happens when a contract ends during pregnancy is less "
              "clear, and depends on the facts. If it's happening to you, get "
              "advice early."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I change jobs while pregnant?'),
        paragraphs: [
          _en("You can. There's no rule that says you must tell an interviewer "
              "you're pregnant. Whether to tell is your choice, and some women "
              "prefer to be open from the start."),
          _en("Before you move, check two things. First, to get maternity "
              "leave under the Act, you need at least 80 days with your new "
              "employer in the 12 months before your due date. Second, check "
              "whether the new company's health insurance covers the "
              "delivery. Group policies often cover maternity from the first "
              "day, but check the limit."),
        ],
      ),
      PvReadSection(
        heading: _en("What should I do if I'm treated unfairly?"),
        paragraphs: [
          _en("Stay calm and move step by step. You don't need to do it all "
              "at once."),
        ],
        bullets: [
          _en("Write down what happened, with dates, times and names. Keep "
              "emails, messages and letters."),
          _en("Ask for any decision, like a dismissal or a change in your "
              "role, and the reason for it, in writing."),
          _en("Raise it with HR, or through the company's grievance process, "
              "by email."),
          _en("If that doesn't help, write to the Inspector under the "
              "Maternity Benefit Act. Your state's labour department or the "
              "Labour Commissioner's office can tell you who that is."),
          _en("For some employers, like central government bodies, banks, "
              "railways and mines, the Chief Labour Commissioner (Central) is "
              "the office to contact."),
          _en("Get legal advice. Women are entitled to free legal aid from the "
              "District Legal Services Authority. The national legal aid "
              "helpline is 15100."),
        ],
        tip: PvReadTip(
          title: _en("Don't wait too long"),
          body: _en("There are time limits for complaints and appeals. If "
              "something has gone wrong, write to HR and ask for advice "
              "within a few weeks, not months."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I look after myself through this?'),
        paragraphs: [
          _en("Being treated unfairly at work while pregnant is stressful. "
              "Lean on your partner, a friend or family, and let someone help "
              "with the letters and calls. Tell your doctor if you're not "
              "sleeping or eating, or feel low most days."),
        ],
      ),
    ],
    whenToSeeSomeone: _rightsCall,
    faqs: [
      PvReadFaq(
        question: _en('Can my employer cut my pay because I need more '
            'breaks?'),
        answer: _en("Talk to HR and ask for their answer in writing. If your "
            "doctor has advised breaks or lighter work, share a note. If "
            "your pay or role changes unfairly, the labour department can "
            "advise you."),
      ),
      PvReadFaq(
        question: _en('Can I be denied a promotion because I was on leave?'),
        answer: _en("The Act says your terms can't be made worse because of "
            "maternity leave. If you think this has happened, ask for the "
            "reasons in writing and take advice."),
      ),
      PvReadFaq(
        question: _en('Is there a helpline I can call?'),
        answer: _en("For free legal help, call the legal aid helpline on 15100. "
            "For worry and stress, Tele-MANAS answers free on 14416, day and "
            "night."),
      ),
    ],
    evidence: _en('Maternity Benefit Act, 1961, as amended by the Maternity '
        'Benefit (Amendment) Act, 2017 · Code on Social Security, 2020, '
        'Chapter VI · Legal Services Authorities Act, 1987 · National Legal '
        'Services Authority · Office of the Chief Labour Commissioner '
        '(Central), Ministry of Labour and Employment.'),
    readNext: [
      'preg_work_read_maternity_leave',
      'preg_work_read_telling_your_boss',
      'preg_work_read_government_informal',
    ],
  ),

  // ===========================================================================
  //  MONEY
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  What a delivery may cost
  // ---------------------------------------------------------------------------
  //  ⚠️ ONE RANGE ONLY, the one `ttc_read_money_before_baby` already ships,
  //  marked as rough, followed by "ask for a written estimate".
  PvRead(
    id: 'preg_work_read_delivery_cost',
    hue: _hue,
    kicker: _kMoney,
    title: _en('What a delivery may cost in India'),
    teaser: _en("Free care in government hospitals, a rough guide to private "
        "costs, and how to avoid a surprise bill."),
    shortAnswer: _en("In a government hospital, delivery is free under JSSK, "
        "including a caesarean, medicines, tests and food. In a private "
        "hospital, costs vary widely by city, hospital and type of birth. Ask "
        "two or three hospitals for a written estimate, and ask what it "
        "leaves out."),
    scaleSetter: _en("Most families worry about the delivery bill. The cost of "
        "a birth isn't a measure of good care, and free care is available to "
        "everyone at government hospitals. Knowing the numbers early lets you "
        "plan and compare calmly."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The same delivery can cost very different amounts across town. "
            "That's not always about the quality of care. Much of it is the "
            "hospital, the room and the city."),
        _en("This read gives you a rough picture, what to ask, and where free "
            "care is. It can't give you a price. Only the hospital can, so "
            "always ask for their estimate in writing."),
        _en("It helps to start early. If you compare hospitals in the middle "
            "months, you have time to check your insurance, save towards the "
            "gap, and change your plan without pressure."),
      ]),
      PvReadSection(
        heading: _en('Is delivery free in a government hospital?'),
        paragraphs: [
          _en("Yes. Under the Janani Shishu Suraksha Karyakram (JSSK), every "
              "pregnant woman who gives birth in a government hospital or "
              "health centre is entitled to:"),
        ],
        bullets: [
          _en("A free delivery, normal or caesarean."),
          _en("Free medicines, tests and blood if needed."),
          _en("Free food while you're in hospital."),
          _en("Free transport from home to hospital, between hospitals if "
              "you're referred, and back home."),
          _en("No user charges of any kind."),
          _en("The same free care for a sick newborn, and for babies up to "
              "one year old."),
        ],
      ),
      PvReadSection(
        heading: _en('What does a private delivery cost?'),
        paragraphs: [
          _en("It depends a lot on the city, the hospital, your room, and how "
              "the birth goes. As a very rough guide only, a normal delivery "
              "in a private city hospital often costs somewhere around ₹50,000 "
              "to ₹1.5 lakh. A caesarean usually costs more, sometimes much "
              "more. Smaller towns often cost less, and large corporate "
              "hospitals in metros can cost more."),
          _en("These are not quotes. Prices change, and every hospital "
              "charges differently. Ask for a written estimate."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do quotes vary so much?'),
        bullets: [
          _en("The room you choose. General ward, shared room, single room "
              "and suite can differ a lot, and some other charges rise with "
              "the room."),
          _en("A normal birth or a caesarean, and how many days you stay."),
          _en("The doctor's and anaesthetist's fees, and whether an epidural "
              "is included."),
          _en("Whether your baby needs care in the newborn unit (NICU). This "
              "is charged by the day and can add a large amount."),
          _en("Medicines, tests and consumables, which are often billed "
              "separately."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask the hospital?'),
        paragraphs: [
          _en("Many private hospitals offer a delivery package. Before you "
              "choose, ask:"),
        ],
        bullets: [
          _en("What does the package include, and for how many days?"),
          _en("What isn't included? Ask about the epidural, NICU, extra days, "
              "the baby's doctor, tests and medicines."),
          _en("What changes if a normal birth becomes a caesarean?"),
          _en("What's the deposit, and when is it paid?"),
          _en("Does the hospital take your insurance cashless, and what do "
              "you need to do before admission?"),
          _en("Are the baby's paediatrician visits and first vaccines "
              "included, or charged separately?"),
          _en("Can you give me all of this in writing, with the date?"),
        ],
        tip: PvReadTip(
          title: _en('Cost should never decide how your baby is born'),
          body: _en("Whether you have a normal birth or a caesarean is a "
              "medical decision your doctor makes with you. If a planned "
              "caesarean is suggested, it's fine to ask why, as you would for "
              "any operation."),
        ),
      ),
      PvReadSection(
        heading: _en('How can we keep costs down without cutting corners?'),
        bullets: [
          _en("Choose the room carefully. A shared room or a general ward "
              "gets the same doctors and care, and can cost much less."),
          _en("Check which hospitals are in your insurance network before "
              "you choose."),
          _en("Ask whether tests can be done at a lab of your choice, and "
              "compare prices."),
          _en("Ask your doctor whether a generic medicine would do. Jan "
              "Aushadhi Kendras sell generic medicines at low prices."),
          _en("Register early at a government hospital as a back-up, even if "
              "you plan to deliver privately. If plans change, they'll "
              "already have your records."),
          _en("Don't agree to extras you don't understand. Ask what each one "
              "is for, and whether you need it."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the months before the birth?'),
        paragraphs: [
          _en("Checkups, scans, blood tests and medicines add up over nine "
              "months. At a government hospital most of this is free. Our "
              "read \"What scans cost in India\", in Scans & tests, gives "
              "ranges for the private scans and tests."),
          _en("Keep every bill and report in one folder. Some insurance "
              "policies pay for tests before and after a hospital stay, and "
              "you'll need the bills to claim."),
        ],
      ),
    ],
    whenToSeeSomeone: _moneyCall,
    faqs: [
      PvReadFaq(
        question: _en('Is care in a government hospital good enough?'),
        answer: _en("Many government hospitals, especially district hospitals "
            "and medical colleges, handle large numbers of births, including "
            "complicated ones. Visit, ask questions, and choose what feels "
            "right."),
      ),
      PvReadFaq(
        question: _en('What if the final bill is much higher than the '
            'estimate?'),
        answer: _en("Ask for an itemised bill and for someone to go through "
            "it with you. Sometimes there's a good medical reason. If "
            "something looks wrong, ask the billing desk to explain it in "
            "writing."),
      ),
      PvReadFaq(
        question: _en('Can I switch from a private to a government hospital '
            'late in pregnancy?'),
        answer: _en("Yes. Take all your reports and your Mother and Child "
            "Protection card, and register early so they know you before "
            "labour starts."),
      ),
    ],
    evidence: _en('Janani Shishu Suraksha Karyakram guidelines, National '
        'Health Mission, Ministry of Health and Family Welfare · Ayushman '
        'Bharat Pradhan Mantri Jan Arogya Yojana, National Health Authority, '
        'health benefit packages.'),
    readNext: [
      'preg_work_read_insurance',
      'preg_work_read_schemes',
      'preg_work_read_money_plan',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Health insurance and maternity cover
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_insurance',
    hue: _hue,
    kicker: _kMoney,
    title: _en('Does my insurance cover the birth?'),
    teaser: _en("Waiting periods, work policies, newborn cover, and the small "
        "print worth checking now."),
    shortAnswer: _en("It depends on your policy. Many individual and family "
        "policies cover a delivery only after a waiting period, often two to "
        "four years, and up to a set limit. Group policies from employers "
        "often cover maternity from day one. Check your policy wording now, "
        "and ask your insurer or HR."),
    scaleSetter: _en("Insurance can feel confusing, but you only need a few "
        "answers from your policy. If it doesn't cover this birth, there are "
        "other ways to plan, including free care in government hospitals."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In India, maternity cover is often an add-on, with its own rules "
            "and limits. Two people with the same insurer can have very "
            "different cover. So the only answer that counts is in your own "
            "policy wording. Here's what to look for."),
      ]),
      PvReadSection(
        heading: _en("What's a waiting period?"),
        paragraphs: [
          _en("It's the time you need to have held the policy before it "
              "will pay for a delivery. For maternity, two to four years is "
              "common in individual and family policies, though a few plans "
              "are shorter. Some policies don't cover maternity at all."),
          _en("If you buy a policy after you're pregnant, that pregnancy is "
              "usually not covered. It's still worth having a policy for your "
              "family's future, and for your baby."),
        ],
      ),
      PvReadSection(
        heading: _en('What does my work policy cover?'),
        paragraphs: [
          _en("Group health policies from employers often cover maternity "
              "from the first day, with no waiting period, up to a fixed "
              "limit. Many also cover the spouse, so check your husband's "
              "company policy too."),
          _en("Ask HR for the policy document and look for the maternity "
              "limit, the newborn cover, and the list of hospitals where you "
              "can be treated cashless. Cover usually ends when you leave the "
              "job, so ask whether you can move to an individual policy with "
              "the same insurer if you're planning to change jobs."),
        ],
      ),
      PvReadSection(
        heading: _en('Is my baby covered?'),
        paragraphs: [
          _en("Many policies cover a newborn from birth for a set time, often "
              "only if the policy covers maternity. After that, you usually "
              "have to add the baby to the policy, often at renewal or within "
              "a fixed number of days."),
          _en("Check how long newborn cover lasts, whether it includes NICU "
              "care and vaccines, and exactly how and when to add your baby. "
              "Put a reminder in your phone for that date."),
        ],
      ),
      PvReadSection(
        heading: _en('What small print should I check?'),
        bullets: [
          _en("The maternity limit, and whether it's different for a normal "
              "birth and a caesarean."),
          _en("The room rent limit. If you choose a room above it, many "
              "policies cut the whole bill in proportion, not only the room "
              "charge."),
          _en("Whether checkups, scans and medicines before and after the "
              "birth are covered, and for how many days."),
          _en("Any co-payment, where you pay a share of every bill."),
          _en("Whether complications of pregnancy are covered separately from "
              "the maternity limit."),
          _en("Which hospitals are cashless, and whether yours is one of "
              "them."),
        ],
        tip: PvReadTip(
          title: _en('Ask for it in writing'),
          body: _en("Call or email the insurer, or the TPA (the company that "
              "handles claims), with your questions. Ask them to reply in "
              "writing, and keep it with your policy."),
        ),
      ),
      PvReadSection(
        heading: _en('Buying a policy now: what should I look for?'),
        paragraphs: [
          _en("Even if it won't cover this birth, a family policy bought now "
              "protects you all later, and your baby's cover can build on it. "
              "When you compare policies, look at:"),
        ],
        bullets: [
          _en("The maternity waiting period and limit, if you may want "
              "another child."),
          _en("How the newborn is covered, and how to add them."),
          _en("The room rent limit and any co-payment."),
          _en("The list of cashless hospitals near you."),
        ],
        tip: PvReadTip(
          title: _en('Always tell the insurer you are pregnant'),
          body: _en("When you fill in the proposal form, answer every health "
              "question honestly, including the pregnancy. If something is "
              "left out, the insurer can refuse a claim later."),
        ),
      ),
      PvReadSection(
        heading: _en("How do I claim?"),
        paragraphs: [
          _en("For a cashless claim, tell your insurer or TPA before a "
              "planned admission, usually a few days ahead. The hospital's "
              "insurance desk sends the paperwork. In an emergency, it's done "
              "after you're admitted, usually within a day."),
          _en("For a reimbursement claim, you pay first and claim later. Keep "
              "every bill, receipt, report and the discharge summary. Many "
              "insurers set a time limit for sending them."),
        ],
      ),
      PvReadSection(
        heading: _en("I'm pregnant and have no cover. What now?"),
        paragraphs: [
          _en("You still have options. Check whether your husband's employer "
              "policy covers you. Look at government hospitals, where care is "
              "free under JSSK, and at whether your family is eligible for "
              "Ayushman Bharat PM-JAY or a state health scheme. Compare "
              "private hospital packages, and start setting money aside."),
        ],
      ),
    ],
    whenToSeeSomeone: _moneyCall,
    faqs: [
      PvReadFaq(
        question: _en('Is IVF pregnancy care covered?'),
        answer: _en("The pregnancy and delivery are usually treated like any "
            "other under a maternity cover. The fertility treatment itself "
            "is often not covered. Check your policy wording."),
      ),
      PvReadFaq(
        question: _en('Should we buy a separate policy for the baby?'),
        answer: _en("Usually the simplest step is to add your baby to your "
            "family floater policy. Ask your insurer how, and by when."),
      ),
      PvReadFaq(
        question: _en("Will my insurance pay for my baby's vaccines?"),
        answer: _en("Usually not, unless your policy says so. The routine "
            "vaccines are free at government health centres under the "
            "Universal Immunisation Programme."),
      ),
    ],
    evidence: _en('IRDAI Master Circular on Health Insurance Business (2024) · '
        'IRDAI (Health Insurance) Regulations, 2016 · Janani Shishu Suraksha Karyakram, National Health Mission · '
        'Ayushman Bharat PM-JAY, National Health Authority.'),
    readNext: [
      'preg_work_read_delivery_cost',
      'preg_work_read_schemes',
      'preg_work_read_money_plan',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Government schemes
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_schemes',
    hue: _hue,
    kicker: _kMoney,
    title: _en('Government help for mothers'),
    teaser: _en("JSSK, JSY, PMMVY and Ayushman Bharat: what each gives, who "
        "it's for, and how to apply."),
    shortAnswer: _en("JSSK gives free delivery and care in government "
        "hospitals to every pregnant woman. JSY gives cash for giving birth in "
        "a hospital, and PMMVY may give ₹5,000 for a first child and ₹6,000 "
        "for a second child if she's a girl. Ayushman Bharat PM-JAY covers "
        "hospital care for eligible families. Your ASHA or anganwadi centre "
        "can help you register."),
    scaleSetter: _en("These schemes exist so that no woman in India has to go "
        "without care because of money. Many families who qualify never "
        "claim. It's worth a visit to find out what you can get."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Some of these are open to every pregnant woman. Others depend on "
            "your income, your state, or where you give birth. Amounts and "
            "rules are updated from time to time, so check the current "
            "details with your health centre or anganwadi before you plan "
            "around them."),
      ]),
      PvReadSection(
        heading: _en('Janani Shishu Suraksha Karyakram (JSSK)'),
        paragraphs: [
          _en("Open to every pregnant woman who gives birth in a government "
              "hospital or health centre. It gives a free delivery, including "
              "a caesarean, free medicines, tests, blood and food, and free "
              "transport to hospital and back home. Sick newborns and babies "
              "up to one year old get free care too. You don't need to apply. "
              "It's your entitlement when you go."),
        ],
      ),
      PvReadSection(
        heading: _en('Janani Suraksha Yojana (JSY)'),
        paragraphs: [
          _en("A one-time cash amount for giving birth in a government "
              "hospital or an accredited private one. The amount depends on "
              "your state and whether you live in a village or a town. In "
              "some states every pregnant woman qualifies, and in others it's "
              "for families below the poverty line or from SC and ST "
              "communities. Your ASHA worker can tell you if you're eligible "
              "and help with the paperwork."),
        ],
      ),
      PvReadSection(
        heading: _en('Pradhan Mantri Matru Vandana Yojana (PMMVY)'),
        paragraphs: [
          _en("A cash benefit paid into your bank or post office account. "
              "Under the 2022 guidelines, it gives ₹5,000 for a first child "
              "in two instalments: one in pregnancy, after you register and "
              "have a checkup, and one after the birth is registered and your "
              "baby has had the first vaccines. For a second child, if she's "
              "a girl, it gives ₹6,000 after the birth."),
          _en("It's meant for women from lower-income and disadvantaged "
              "families. For example, you may qualify if your family's income "
              "is under ₹8 lakh a year, or you have an Ayushman Bharat, "
              "e-Shram, BPL ration or MGNREGA card. It isn't for women in "
              "regular government jobs, or who get paid maternity leave under "
              "another law."),
        ],
      ),
      PvReadSection(
        heading: _en('Ayushman Bharat PM-JAY'),
        paragraphs: [
          _en("Health cover of up to ₹5 lakh per family per year for hospital "
              "care, cashless, at government and listed private hospitals. It "
              "includes packages for normal and caesarean deliveries and for "
              "newborn care. It's for eligible families, mostly based on "
              "government lists. You can check at the PM-JAY website or by "
              "calling 14555. Many states run their own health schemes "
              "alongside it."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I apply?'),
        bullets: [
          _en("Register your pregnancy early at your nearest government "
              "health centre or anganwadi. You'll get a Mother and Child "
              "Protection (MCP) card. Keep it safe, as most schemes ask for "
              "it."),
          _en("Keep your Aadhaar and a bank or post office account ready. "
              "Payments usually go to an account linked to your Aadhaar."),
          _en("Ask your ASHA worker or anganwadi worker which schemes you "
              "qualify for. They can fill in the forms with you."),
          _en("For PMMVY you can also register online on the scheme's "
              "portal."),
          _en("Some of these can be combined. For example, you can give "
              "birth free under JSSK and also get JSY or PMMVY if you "
              "qualify."),
        ],
        tip: PvReadTip(
          title: _en('Ask about your state too'),
          body: _en("Many states run their own schemes for mothers, with cash, "
              "nutrition kits or extra help for girls. Your anganwadi centre "
              "will know what's on offer where you live."),
        ),
      ),
      PvReadSection(
        heading: _en("What if I'm asked to pay in a government hospital?"),
        paragraphs: [
          _en("Under JSSK, you shouldn't be charged for your delivery, "
              "medicines, tests, blood, food or transport in a government "
              "hospital. If someone asks you to pay or to buy medicines from "
              "outside, ask politely whether it's covered under JSSK."),
          _en("If it doesn't get sorted, ask to speak to the hospital's "
              "medical superintendent or grievance desk. Many states also run "
              "a health helpline on 104. Your ASHA worker can help you raise "
              "it too."),
        ],
      ),
      PvReadSection(
        heading: _en('What else is free?'),
        bullets: [
          _en("Take-home food rations for pregnant and breastfeeding women, "
              "and for children from six months, at your anganwadi centre."),
          _en("Iron, folic acid and calcium tablets at government health "
              "centres."),
          _en("All the routine vaccines for your baby under the Universal "
              "Immunisation Programme."),
        ],
      ),
    ],
    whenToSeeSomeone: _moneyCall,
    faqs: [
      PvReadFaq(
        question: _en('Can I get JSY if I give birth in a private hospital?'),
        answer: _en("Only in some cases, if the private hospital is accredited "
            "under the scheme. Ask your ASHA worker before you choose."),
      ),
      PvReadFaq(
        question: _en("I didn't register early. Can I still claim PMMVY?"),
        answer: _en("Ask at your anganwadi centre. There are time limits, but "
            "they can tell you what you can still claim."),
      ),
      PvReadFaq(
        question: _en('Do I need to pay anyone to register?'),
        answer: _en("No. These schemes are free to register for. If someone "
            "asks for money, don't pay, and tell the health centre."),
      ),
    ],
    evidence: _en('Janani Shishu Suraksha Karyakram and Janani Suraksha Yojana '
        'guidelines, National Health Mission, Ministry of Health and Family '
        'Welfare · Pradhan Mantri Matru Vandana Yojana guidelines under Mission '
        'Shakti (2022), Ministry of Women and Child Development · Ayushman '
        'Bharat PM-JAY, National Health Authority · Saksham Anganwadi and '
        'Poshan 2.0 · Universal Immunisation Programme.'),
    readNext: [
      'preg_work_read_delivery_cost',
      'preg_work_read_government_informal',
      'preg_work_read_baby_budget',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  A baby budget for the first year
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_baby_budget',
    hue: _hue,
    kicker: _kMoney,
    title: _en('A baby budget for the first year'),
    teaser: _en("What costs money in India, what you can skip or borrow, and "
        "a simple way to plan it."),
    shortAnswer: _en("After the birth, the biggest costs in the first year are "
        "usually help at home, nappies, doctor visits, and any income you "
        "lose while on leave. Clothes and gear can mostly be borrowed. "
        "Vaccines are free at government centres, and breastfeeding, if it "
        "works for you, costs nothing."),
    scaleSetter: _en("Babies need much less than the shops suggest. Families "
        "on every budget raise happy, healthy children. A simple plan helps "
        "you spend on what matters and skip the rest."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Every family's costs are different. They depend on your city, "
            "the help you have, how you feed your baby and what you choose to "
            "buy. So this read doesn't give prices. It helps you list what "
            "your family will spend on, and put your own numbers beside it."),
      ]),
      PvReadSection(
        heading: _en('What costs money in the first year?'),
        bullets: [
          _en("Help at home, if you hire it: a nanny or a japa maid for the "
              "first weeks, or extra help with cooking and cleaning."),
          _en("Nappies. Disposable nappies are a steady monthly cost. Cloth "
              "nappies cost more at the start and less over time."),
          _en("Doctor visits, and any optional vaccines you choose at a "
              "private clinic."),
          _en("Formula, if you use it. It's a big monthly cost, so plan for "
              "it if you think you'll need it."),
          _en("Lost income, if either of you takes unpaid leave or stops "
              "work."),
          _en("Childcare when you go back to work: a crèche, a nanny, or "
              "family help."),
          _en("Ceremonies and gifts, which can cost more than families "
              "expect."),
        ],
      ),
      PvReadSection(
        heading: _en('What can we skip or borrow?'),
        paragraphs: [
          _en("Babies grow out of things in weeks, and family and friends are "
              "often happy to pass things on."),
        ],
        bullets: [
          _en("Newborn clothes. You'll need a few soft cotton sets. Borrow "
              "the rest, or wait for gifts."),
          _en("Baby shoes, which babies don't need until they walk."),
          _en("A bath tub, a bottle warmer, a wipes warmer or a changing "
              "table. A basin, warm water and a towel on the bed work just as "
              "well."),
          _en("A pram, if you'll mostly carry your baby. A soft carrier or a "
              "cloth wrap may suit you better."),
          _en("Toys in the first months. Your face and voice are what your "
              "baby likes most."),
        ],
      ),
      PvReadSection(
        heading: _en("What's worth buying new?"),
        paragraphs: [
          _en("A few things are about safety, and are worth buying new or "
              "from someone you know well. For most other things, second-hand "
              "is fine once it's been washed."),
        ],
        bullets: [
          _en("A car seat, if you'll travel by car, and one you know the "
              "history of. A seat that has been in an accident may not "
              "protect your baby."),
          _en("A firm, flat mattress for wherever your baby sleeps, with no "
              "pillows, bumpers or soft toys around them."),
          _en("Feeding basics like a good feeding pillow, or bottles and a "
              "steriliser if you'll use them."),
          _en("A digital thermometer, so you can check a fever before you "
              "call the doctor."),
        ],
      ),
      PvReadSection(
        heading: _en("What's free?"),
        bullets: [
          _en("All the routine vaccines under the Universal Immunisation "
              "Programme, at government health centres."),
          _en("Growth checks and take-home food rations for children from six "
              "months at your anganwadi centre."),
          _en("Care for your baby at government hospitals, free up to one "
              "year under JSSK."),
          _en("Breastfeeding, if it works for you. Ask the hospital staff "
              "to help you get started."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the first 40 days?'),
        paragraphs: [
          _en("In many Indian families, the weeks after the birth come with "
              "their own costs: a massage (maalish) helper, special foods like "
              "panjiri, laddoos and ghee, extra help in the kitchen, and "
              "ceremonies such as the naming day."),
          _en("These traditions can be lovely, and they can also add up. "
              "Talk with your family early about what matters most to you "
              "both, who will pay for what, and what can be kept simple. "
              "It's easier to agree before the baby comes than in the "
              "tired first weeks."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we make a simple budget?'),
        paragraphs: [
          _en("Sit down together for half an hour, with a notebook or a "
              "spreadsheet. Make three lists."),
        ],
        bullets: [
          _en("One-time costs: the delivery, any big items, ceremonies."),
          _en("Monthly costs: nappies, help at home, formula if used, doctor "
              "visits, childcare later."),
          _en("Yearly costs: health insurance premiums, and any policy for "
              "the baby."),
          _en("Next to each, write what you think it will cost. Add about a "
              "tenth on top for surprises."),
          _en("Then write what's coming in, including leave pay and any "
              "scheme money, and see what's left each month."),
        ],
        tip: PvReadTip(
          title: _en('Start small, and start now'),
          body: _en("If you can, set aside a small fixed amount each month in "
              "a separate account. It doesn't have to be much. What matters "
              "is that it's there when the bills come."),
        ),
      ),
    ],
    whenToSeeSomeone: _moneyCall,
    faqs: [
      PvReadFaq(
        question: _en('Are private "painless" vaccines worth paying for?'),
        answer: _en("Ask your baby's doctor. The free vaccines under the "
            "Universal Immunisation Programme protect your baby. The private "
            "versions may cause less fever or soreness but cost much more."),
      ),
      PvReadFaq(
        question: _en('Should we buy a lot of clothes before the birth?'),
        answer: _en("No. Buy a few, and wait. Many families receive clothes "
            "as gifts, and you'll know your baby's size after the birth."),
      ),
      PvReadFaq(
        question: _en("Is cloth or disposable cheaper?"),
        answer: _en("Cloth nappies usually cost less over a year, but take "
            "more washing. Many families use cloth at home and disposable at "
            "night or when out."),
      ),
    ],
    evidence: _en('Universal Immunisation Programme, Ministry of Health and '
        'Family Welfare · Janani Shishu Suraksha Karyakram, National Health '
        'Mission · Saksham Anganwadi and Poshan 2.0, Ministry of Women and '
        'Child Development · American Academy of Pediatrics, Sleep-related '
        'infant deaths: updated 2022 recommendations.'),
    readNext: [
      'preg_work_read_money_plan',
      'preg_work_read_schemes',
      'preg_work_read_delivery_cost',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Getting your money ready, month by month
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_work_read_money_plan',
    hue: _hue,
    kicker: _kMoney,
    title: _en('Getting your money ready, month by month'),
    teaser: _en("A simple money checklist for each stage of pregnancy, and "
        "what to do when money worries keep you up."),
    shortAnswer: _en("Early on, check your insurance and leave, and register "
        "for the schemes you may qualify for. In the middle months, choose a "
        "hospital, get a written estimate and make a budget. In the last "
        "months, keep money and papers ready. After the birth, add your baby "
        "to your insurance and register the birth."),
    scaleSetter: _en("You don't have to sort everything at once. One or two "
        "small jobs a month is enough, and by the time your baby comes, most "
        "of it will be done."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Money is one of the most common worries in pregnancy, and it "
            "often feels bigger at night. Breaking it into small jobs helps. "
            "Here's a simple plan, stage by stage. Tick off what applies to "
            "you and skip the rest."),
        _en("If you're sharing this with your partner, split the list. One "
            "of you can take insurance and the hospital, the other leave and "
            "the schemes. Then sit down together once a month to see where "
            "things stand."),
      ]),
      PvReadSection(
        heading: _en('What should we sort in the first three months?'),
        bullets: [
          _en("Read your health insurance policy for maternity cover, the "
              "waiting period and the limits."),
          _en("Find out your maternity leave, and his paternity leave, from "
              "HR."),
          _en("Register your pregnancy at a government health centre or "
              "anganwadi, get your MCP card, and ask about PMMVY and JSY."),
          _en("Start a small monthly saving in a separate account."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the middle months?'),
        bullets: [
          _en("Visit two or three hospitals, and ask each for a written "
              "estimate and what it leaves out."),
          _en("Check that your chosen hospital is cashless with your "
              "insurer, and what paperwork they need before admission."),
          _en("Make your first-year budget together. Our baby budget read "
              "shows how."),
          _en("Plan your leave dates, and his."),
          _en("Update the nominees on your bank accounts, insurance and "
              "provident fund."),
        ],
      ),
      PvReadSection(
        heading: _en('And the last months?'),
        bullets: [
          _en("Keep the hospital deposit ready, in the account or form the "
              "hospital accepts."),
          _en("Put your insurance card, policy number, ID, MCP card and "
              "reports in one folder, and pack it in your hospital bag."),
          _en("Give written notice of your leave at work."),
          _en("Keep some money aside for surprises, like a longer stay or "
              "NICU care."),
        ],
      ),
      PvReadSection(
        heading: _en('And after the birth?'),
        bullets: [
          _en("Add your baby to your health insurance within the time your "
              "policy allows."),
          _en("Register the birth. Births should be registered within 21 "
              "days. Hospitals usually report the birth, but check with them "
              "and collect the certificate from your local registrar or "
              "municipal office."),
          _en("Claim the next PMMVY instalment if you qualify."),
          _en("Think about term life cover if others depend on your income, "
              "and make or update a will."),
        ],
      ),
      PvReadSection(
        heading: _en('What if our baby needs NICU care?'),
        paragraphs: [
          _en("Some babies need a stay in the newborn unit (NICU), for "
              "example if they're born early. In a private hospital this is "
              "charged by the day and can become the biggest part of the "
              "bill."),
          _en("Check now whether your insurance covers NICU care, and up to "
              "what limit. If a stay is needed, ask the billing desk for the "
              "daily charge and a weekly update on the bill. Government "
              "hospitals with a special newborn care unit (SNCU) treat sick "
              "newborns free under JSSK, and a transfer can be discussed with "
              "your baby's doctor."),
        ],
      ),
      PvReadSection(
        heading: _en('What papers should we keep in one place?'),
        bullets: [
          _en("Your health insurance card, policy document and the insurer's "
              "or TPA's phone number."),
          _en("Your MCP card, all pregnancy reports and prescriptions."),
          _en("ID and address proof for both of you, and your Aadhaar."),
          _en("The hospital's written estimate and any deposit receipts."),
          _en("Your leave letters and HR emails."),
        ],
      ),
      PvReadSection(
        heading: _en('What if money worries keep me up at night?'),
        paragraphs: [
          _en("You're not alone in this. Many parents worry about money "
              "before a baby, whatever they earn. A few things often help:"),
        ],
        bullets: [
          _en("Write the worry down, with the next small step beside it. A "
              "step feels smaller than a worry."),
          _en("Talk about it with your partner at a calm time, not late at "
              "night."),
          _en("Remind yourself that free care is available at government "
              "hospitals, whatever happens."),
          _en("If worry is stopping you sleeping or eating, or you feel low "
              "most days, tell your doctor."),
        ],
      ),
      PvReadSection(
        heading: _en('What if one of us stops earning?'),
        paragraphs: [
          _en("Plan it early. Work out what you'll live on, and cut back on "
              "things you won't miss before the income stops, so the change "
              "is gentler. If you can, keep three to six months of expenses "
              "aside for emergencies. And talk about how money decisions "
              "will be shared, so the partner at home still has a say."),
          _en("Try living on one income for a month or two before the change, "
              "and save the other. It shows you what's possible, and builds "
              "a cushion at the same time."),
        ],
      ),
    ],
    whenToSeeSomeone: _moneyCall,
    faqs: [
      PvReadFaq(
        question: _en('Should we take a loan for the delivery?'),
        answer: _en("Try other options first: your insurance, a government "
            "hospital, a scheme, or a hospital's payment plan. If you do "
            "borrow, read the interest and charges carefully."),
      ),
      PvReadFaq(
        question: _en('Do we need life insurance now?'),
        answer: _en("If others depend on your income, a simple term life "
            "policy is worth looking at. It's usually cheaper when you're "
            "young and healthy."),
      ),
      PvReadFaq(
        question: _en("We don't have savings. Is it too late?"),
        answer: _en("No. Even a small amount each month helps, and free care "
            "at government hospitals is there for everyone."),
      ),
    ],
    evidence: _en('Registration of Births and Deaths Act, 1969 · Pradhan '
        'Mantri Matru Vandana Yojana guidelines (2022) · Janani Suraksha '
        'Yojana and Janani Shishu Suraksha Karyakram, National Health Mission · '
        'Maternity Benefit Act, 1961, as amended 2017 · IRDAI consumer '
        'guidance on health insurance.'),
    readNext: [
      'preg_work_read_baby_budget',
      'preg_work_read_insurance',
      'preg_work_read_schemes',
    ],
  ),
];

/// A read in this file by id, or null.
PvRead? workReadById(String id) {
  for (final r in kPregnancyReadsWork) {
    if (r.id == id) return r;
  }
  return null;
}
