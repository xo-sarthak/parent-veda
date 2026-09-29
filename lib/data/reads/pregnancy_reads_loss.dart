// =============================================================================
//  After a loss (pregnancy) — the reads behind the door
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "After a loss (pregnancy)", P1: *"If her pregnancy ends, the
//  app has no way to be told. It keeps showing her baby growing week by
//  week."* The door is `lib/data/doors/pv_door_after_loss.dart`; every read
//  here sits on one of its tiles, and `test/pv_door_after_loss_test.dart`
//  holds that.
//
//  ⚠️ THE MOST SENSITIVE WRITING IN THE APP. She may be reading this in the
//  worst week of her life. So, beyond `docs/PREG-VOICE.md`:
//
//  · Name the feeling once, then help. No paragraph of sympathy.
//  · Never cheerful, never a silver lining, never a phrase that makes the
//    loss smaller. The test bans the usual offenders by name.
//  · No baby-size or growth language, no product, no upsell. The one paid
//    thing reachable from the door (counselling) is a person, not a product,
//    and its price is on its own screen, never in these words.
//  · Population numbers only, and only where they lift guilt or fear. No
//    sentence puts "your" beside a chance word
//    (`test/pregnancy_reads_shape_test.dart` scans for exactly that).
//  · Every "straight away" and "today" is exact and is never softened.
//  · The Complications condition pages ("Miscarriage / pregnancy loss",
//    "Ectopic pregnancy") keep the medical facts; these reads agree with them
//    and refer to them by name rather than repeating them. Mind & mood's
//    "Pregnant again after a loss" keeps the feelings of a next pregnancy.
//  · `reviewed: false`, ParentVeda editorial, until a doctor and a
//    counsellor have read every one (the gap analysis asks for both).
//
//  Not yet spread into `kPregnancyReads`: the lead does that in
//  `pregnancy_reads.dart`, one line.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, as in the other pregnancy reads files.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

const double _hue = 250;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('After a loss');

final LocalizedText _kBody = _en('Your body');
final LocalizedText _kUnderstand = _en('Understand');
final LocalizedText _kSupport = _en('Support');
final LocalizedText _kAgain = _en('Trying again');

/// The "go now" list for the body, in one place so the signs can't drift
/// apart between reads. Agrees with the `callNow` lines on the Complications
/// "Miscarriage / pregnancy loss" page (a pad in an hour or less, severe
/// pain, fever or a bad smell, feeling faint), and adds the ectopic and
/// after-birth signs.
final PvCallout _bodyUrgent = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Go to hospital straight away if'),
  body: _en("You're soaking through a pad in an hour or less, you pass large "
      "clots, you have severe pain in your tummy that pain relief doesn't "
      "ease, you have a fever or shivering, the bleeding or discharge smells "
      "bad, or you feel faint or dizzy. Pain at the tip of your shoulder, "
      "chest pain or sudden breathlessness also mean going in straight away. "
      "If you can't get there safely, call 108 for an ambulance. If you have "
      "any thought of harming yourself, call Tele-MANAS on 14416, free at any "
      "hour, or 112 if you're in danger now."),
);

/// The same, led by the mind, for the Support reads.
final PvCallout _heartUrgent = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Get help today if'),
  body: _en("You have any thought of harming yourself, or feel you can't keep "
      "yourself safe. Call Tele-MANAS on 14416 (or 1-800-891-4416), free, "
      "day and night, in English and many Indian languages, or call 112 if "
      "you're in danger now. Tell your doctor this week if you've felt low, "
      "numb or hopeless, or haven't been able to sleep or eat, for more than "
      "two weeks. For your body: heavy bleeding, fever, severe pain or "
      "feeling faint mean going to hospital straight away."),
);

final LocalizedText _evLoss = _en('NICE guideline NG126, Ectopic pregnancy '
    'and miscarriage: diagnosis and initial management (2019, updated 2023) · '
    'RCOG patient information, Early miscarriage · WHO, Abortion care '
    'guideline (2022), on care after pregnancy loss · FOGSI guidance on early '
    'pregnancy loss.');

final LocalizedText _evMind = _en('NICE guideline CG192, Antenatal and '
    'postnatal mental health (2014, updated 2020) · WHO, Why we need to talk '
    'about losing a baby (2019) · Tele-MANAS details from the Ministry of '
    'Health and Family Welfare, Government of India.');

final List<PvRead> kPregnancyReadsLoss = [
  // ===========================================================================
  //  YOUR BODY
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  After a miscarriage: bleeding, pain, pads
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_body_after_miscarriage',
    hue: _hue,
    kicker: _kBody,
    title: _en('Your body after a miscarriage'),
    teaser: _en("What the bleeding and pain are usually like, how long they "
        "last, and how to look after yourself."),
    shortAnswer: _en("After a miscarriage you'll usually bleed like a heavy "
        "period for a few days, then less, often for one to two weeks. Use "
        "pads, not tampons, and take the pain relief your doctor suggests. "
        "Soaking a pad in an hour or less, fever, severe pain or feeling "
        "faint mean going to hospital straight away."),
    scaleSetter: _en("This read is about the physical side, in plain words. "
        "Your body usually heals well after a miscarriage, and most of what "
        "you feel in the first days is expected. Read it in pieces if that's "
        "easier."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("We're so sorry. However early it was, this is a loss, and it's "
            "normal to feel shaken in body and mind."),
        _en("Your body has a few weeks of healing to do. Knowing what's normal "
            "can take a little of the fear out of it, and helps you spot the "
            "few things that need a doctor."),
      ]),
      PvReadSection(
        heading: _en('How much will I bleed, and for how long?'),
        paragraphs: [
          _en("Bleeding usually starts heavier than a normal period, with "
              "cramps and some clots, and then slows over a few days. Many "
              "women then have lighter bleeding or brown spotting for one to "
              "two weeks. Some spot on and off for a little longer."),
          _en("How much you bleed depends on how many weeks pregnant you were "
              "and how the miscarriage was managed. Bleeding after a short "
              "procedure is often lighter and shorter than after waiting for "
              "it to happen naturally or taking tablets."),
          _en("If you were given tablets to help the miscarriage along, the "
              "heaviest bleeding usually comes within a few hours of taking "
              "them. Your doctor or nurse should tell you what to expect and "
              "who to call, day or night. If they didn't, it's fine to ring "
              "and ask."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps with the pain?'),
        bullets: [
          _en("Take the pain relief your doctor suggests, at the times they "
              "suggest. Ask before taking anything else, including something "
              "from the chemist or a home remedy."),
          _en("A hot water bottle or a warm pack on your lower tummy or your "
              "back."),
          _en("Rest when you can. Lie on your side with a pillow between your "
              "knees, or curl up if that feels better."),
          _en("Cramps usually ease within a few days. Pain that gets worse "
              "instead of better is a reason to call your doctor."),
        ],
      ),
      PvReadSection(
        heading: _en('Why pads and not tampons?'),
        paragraphs: [
          _en("Use pads until the bleeding stops. Tampons and menstrual cups "
              "sit inside the vagina. While the neck of the womb (the cervix) "
              "is still a little open, doctors advise keeping things out of "
              "the vagina to help prevent infection."),
          _en("For the same reason, most doctors suggest no sex until the "
              "bleeding has stopped. A shower or a bucket bath is fine. Leave "
              "swimming until the bleeding has stopped too."),
          _en("If you're going out in the first week or two, keep a few pads "
              "and a spare set of clothes in your bag. It's one less thing to "
              "worry about."),
        ],
      ),
      PvReadSection(
        heading: _en('What else might I notice?'),
        bullets: [
          _en("Pregnancy signs like nausea and sore breasts usually fade over "
              "a few days."),
          _en("If you were further along, your breasts may leak a little milk. "
              "This passes. 'Recovering after a later loss or stillbirth' on "
              "this door explains what helps."),
          _en("A pregnancy test can stay positive for a few weeks while the "
              "pregnancy hormone leaves your body. If your doctor asked you to "
              "do a test after three weeks, do it, and call them if it's still "
              "positive."),
          _en("Tiredness, which can come as much from grief as from blood "
              "loss. If you feel breathless or very weak, ask your doctor to "
              "check your haemoglobin."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask my doctor?'),
        bullets: [
          _en("Your blood group. If it's Rh negative, ask whether you need an "
              "anti-D injection. It depends on how many weeks you were and how "
              "the miscarriage was managed, and it's given within 72 hours."),
          _en("Whether they want to see you again, or want a scan or blood "
              "test to check the miscarriage is complete."),
          _en("What to do if the bleeding changes, and the number to call at "
              "night."),
          _en("Whether any tissue was sent for testing, and when you'll "
              "hear."),
        ],
        tip: PvReadTip(
          title: _en('If you pass the pregnancy at home'),
          body: _en("Some women aren't sure what to do. You can place it in a "
              "clean container and take it to your doctor or hospital, who can "
              "examine it if needed. Or you can bury it in a way that feels "
              "right to you. Either is okay."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I look after myself this week?'),
        paragraphs: [
          _en("Eat what you can. Warm, easy food helps: dal, khichdi, eggs if "
              "you eat them, and green leafy vegetables to help replace iron. "
              "Sip water through the day. Sleep when you can."),
          _en("You don't have to go back to work or housework straight away. "
              "If family want to help, let them cook, clean and handle the "
              "phone calls."),
          _en("Your body and your feelings may heal at different speeds. Both "
              "are allowed to take their time."),
        ],
      ),
    ],
    whenToSeeSomeone: _bodyUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Is it normal to pass clots?'),
        answer: _en("Small clots are common in the first days. Clots bigger "
            "than a small lemon, or clots with heavy bleeding, mean going to "
            "hospital straight away."),
      ),
      PvReadFaq(
        question: _en('When can I go back to work?'),
        answer: _en("When you feel ready in body and mind. For many women "
            "that's a few days to two weeks after an early miscarriage. You "
            "may be entitled to paid leave; 'Going back to work, and the "
            "leave you may have' on this door explains it."),
      ),
      PvReadFaq(
        question: _en('Can I exercise?'),
        answer: _en("Gentle walking is fine as soon as you feel like it. Leave "
            "harder exercise and swimming until the bleeding has stopped."),
      ),
    ],
    evidence: _evLoss,
    readNext: [
      'preg_loss_read_when_hospital',
      'preg_loss_read_periods_after',
      'preg_loss_read_miscarriage',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  When to go to hospital
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_when_hospital',
    hue: _hue,
    kicker: _kBody,
    title: _en('When to go to hospital after a loss'),
    teaser: _en("The signs that mean going in straight away, and the ones "
        "that mean calling your doctor today."),
    shortAnswer: _en("Go to hospital straight away if you soak through a pad "
        "in an hour or less, have severe pain, a fever, bleeding that smells "
        "bad, or feel faint. Most women heal without any of these. If you're "
        "unsure, call. You're never a bother."),
    scaleSetter: _en("Most women recover after a loss without an emergency. "
        "This list is here so you know the few signs that can't wait, and "
        "don't have to guess in the middle of the night."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In the days and weeks after a loss, it's hard to know what's "
            "normal. Every cramp can feel frightening. This page puts the "
            "signs in one place, sorted by how quickly to act."),
        _en("Save these numbers on your phone now: your doctor, the "
            "hospital's casualty or labour ward, and 108 for an ambulance. "
            "Show whoever is with you where this list is."),
      ]),
      PvReadSection(
        heading: _en('When should I go to hospital straight away?'),
        bullets: [
          _en("Bleeding that soaks through a pad in an hour or less."),
          _en("Clots bigger than a small lemon, especially with heavy "
              "bleeding."),
          _en("Severe pain in your tummy that pain relief doesn't ease, or "
              "pain that keeps getting worse."),
          _en("Pain at the tip of your shoulder, or feeling faint, dizzy, very "
              "pale or sweaty. After an early loss this can mean bleeding "
              "inside from an ectopic pregnancy."),
          _en("A fever of 38°C (100.4°F) or more, shivering, or feeling very "
              "unwell."),
          _en("Bleeding or discharge that smells bad."),
          _en("Chest pain, or sudden breathlessness."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en("If you can't get there safely"),
          body: _en("Or if you faint, call 108 for an ambulance. Please don't "
              "drive yourself."),
        ),
      ),
      PvReadSection(
        heading: _en('When should I call my doctor today?'),
        bullets: [
          _en("Bleeding that was settling and has become heavy again."),
          _en("Bleeding or spotting that's still going on after two weeks."),
          _en("A pregnancy test that's still positive three weeks after the "
              "loss."),
          _en("Pain or burning when you pass urine."),
          _en("Pain, swelling or redness in one calf. If it comes with chest "
              "pain or breathlessness, go to hospital straight away "
              "instead."),
          _en("Tummy pain that isn't severe but won't go away."),
        ],
      ),
      PvReadSection(
        heading: _en('After a later loss or a stillbirth, what else should I '
            'watch for?'),
        paragraphs: [
          _en("After a loss later in pregnancy, your body goes through much of "
              "what it does after any birth. So the signs to watch for after a "
              "birth apply to you too."),
        ],
        bullets: [
          _en("A severe headache that won't go, blurred vision or flashing "
              "lights, or sudden swelling of your face or hands. Blood "
              "pressure can rise in the days after a birth. Go to hospital "
              "straight away."),
          _en("A breast that's hot, red and painful, with a fever or aches. "
              "Call your doctor today."),
          _en("Stitches or a caesarean wound that are red, leaking, opening "
              "or smell bad. Call your doctor today."),
        ],
      ),
      PvReadSection(
        heading: _en('What about my mind?'),
        paragraphs: [
          _en("Grief can make you feel low, numb or angry, and it can break "
              "your sleep. That's grief, not a sign that something is wrong "
              "with you. But some feelings need help quickly."),
        ],
        bullets: [
          _en("Any thought of harming yourself, or feeling you can't go on. "
              "Call Tele-MANAS on 14416, free at any hour, or 112 if you're in "
              "danger now. Tell someone near you."),
          _en("Feeling low, hopeless or unable to eat or sleep for more than "
              "two weeks. Tell your doctor this week."),
          _en("Panic attacks, or flashbacks to the loss that stop you getting "
              "through the day. Tell your doctor this week."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I take with me?'),
        bullets: [
          _en("Any discharge papers or scan reports from the loss."),
          _en("A list of the medicines you've taken, and when."),
          _en("A rough idea of how many pads you've used in the last few "
              "hours, and how soaked they were."),
          _en("Someone to go with you, if you can."),
        ],
        tip: PvReadTip(
          title: _en("You're never a bother"),
          body: _en("You never need to be sure it's serious before you call. "
              "Calling and being told you're fine is a good outcome."),
        ),
      ),
      PvReadSection(
        heading: _en("What's normal, and can wait for a routine visit?"),
        paragraphs: [
          _en("Most of what happens after a loss is expected, and it's good to "
              "know that too. These are usually normal in the first two "
              "weeks:"),
        ],
        bullets: [
          _en("Bleeding like a heavy period for a few days, then lighter "
              "bleeding or brown spotting."),
          _en("Small clots, especially when you stand up after lying down."),
          _en("Cramps like period pain that ease with the pain relief your "
              "doctor suggested."),
          _en("Feeling tired, tearful or unable to concentrate."),
          _en("Sore or leaking breasts, if you were further along."),
        ],
        tip: PvReadTip(
          title: _en('Still not sure?'),
          body: _en("Call your doctor or the labour ward and describe what's "
              "happening. They would rather hear from you than have you wait "
              "at home wondering."),
        ),
      ),
    ],
    whenToSeeSomeone: _bodyUrgent,
    faqs: [
      PvReadFaq(
        question: _en("I can't face the hospital where it happened. What can I "
            "do?"),
        answer: _en("That's understandable. You can go to any hospital with a "
            "gynaecology or maternity unit. Tell them you've had a recent "
            "pregnancy loss, and when."),
      ),
      PvReadFaq(
        question: _en('How do I know if I\'m bleeding too much?'),
        answer: _en("If you're soaking through a pad in an hour or less, that's "
            "too much. Go to hospital straight away."),
      ),
      PvReadFaq(
        question: _en("It's the middle of the night. Should I wait until "
            "morning?"),
        answer: _en("Not for any sign in the 'straight away' list. For the "
            "others, call the hospital's labour ward or casualty; they "
            "answer at night."),
      ),
    ],
    evidence: _en('NICE guideline NG126, Ectopic pregnancy and miscarriage '
        '(2019, updated 2023) · NICE guideline NG194, Postnatal care (2021), '
        'on signs after a birth · RCOG Green-top Guideline 55, Late '
        'intrauterine fetal death and stillbirth · Tele-MANAS details from '
        'the Ministry of Health and Family Welfare, Government of India.'),
    readNext: [
      'preg_loss_read_body_after_miscarriage',
      'preg_loss_read_later_loss_recovery',
      'preg_loss_read_someone_to_talk',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Recovery after a later loss or stillbirth
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_later_loss_recovery',
    hue: _hue,
    kicker: _kBody,
    title: _en('Recovering after a later loss or stillbirth'),
    teaser: _en("Bleeding, milk coming in, stitches and the checks ahead, when "
        "your baby was born later in pregnancy."),
    shortAnswer: _en("After a later loss your body recovers much as it would "
        "after any birth. You'll bleed for some weeks, your milk may come in, "
        "and you'll have a check around six weeks. Ask your doctor about a "
        "medicine that stops milk, if you'd like it."),
    scaleSetter: _en("Your body may carry on as though your baby were here, "
        "and that can be one of the hardest parts. This read explains what to "
        "expect, so less of it takes you by surprise."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("We're so sorry. If your baby was born in the second half of "
            "pregnancy, your body has given birth, whatever words the papers "
            "use. You deserve the same care as any woman after a birth."),
        _en("Take this slowly. You don't need to know all of it today."),
      ]),
      PvReadSection(
        heading: _en('How long will I bleed?'),
        paragraphs: [
          _en("Bleeding after a birth (lochia) is heavy and red for the first "
              "few days. Then it turns pink or brown, and later "
              "yellowish-white. It can go on for up to six weeks. Use "
              "maternity pads, not tampons."),
          _en("Bleeding that turns heavy and bright red again, large clots, or "
              "a bad smell mean calling your doctor or going in. Soaking a pad "
              "in an hour or less means going to hospital straight away."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens with my milk, and what helps?'),
        paragraphs: [
          _en("From around the middle of pregnancy, your body can make milk. "
              "Two to five days after the birth, your breasts may feel full, "
              "hard and sore, and may leak. Many women say this was one of "
              "the most painful reminders."),
        ],
        bullets: [
          _en("Ask your doctor about a medicine that stops milk being made. "
              "It works best soon after the birth, and it isn't right for "
              "everyone, so they'll check first."),
          _en("Wear a firm, supportive bra, day and night."),
          _en("Hold cold packs, or a cold cloth wrapped in a thin towel, on "
              "your breasts for a few minutes at a time."),
          _en("Take the pain relief your doctor suggests."),
          _en("If they're very full, press out a little milk by hand, just "
              "enough to ease the pressure. Taking out a lot tells your body "
              "to make more."),
          _en("A few women choose to express their milk and give it to a "
              "hospital milk bank. It's a choice, never an expectation."),
        ],
        tip: PvReadTip(
          title: _en('Call your doctor today if'),
          body: _en("Part of a breast is hot, red and painful, or you have a "
              "fever or flu-like aches. This can be an infection (mastitis) "
              "and needs treatment."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I look after stitches or a caesarean wound?'),
        paragraphs: [
          _en("If you had a tear or a cut (episiotomy), the stitches usually "
              "dissolve within a few weeks. Keep the area clean, pour warm "
              "water over it when you pee, and change pads often. A soft "
              "cushion makes sitting easier."),
          _en("If you had a caesarean, the wound needs the same care as after "
              "any caesarean. Keep it clean and dry, avoid heavy lifting for "
              "about six weeks, and ask your doctor before driving."),
          _en("Redness, leaking, opening or a bad smell from either means "
              "calling your doctor today."),
        ],
      ),
      PvReadSection(
        heading: _en('What checks will I have?'),
        bullets: [
          _en("Blood pressure and temperature checks in the first days."),
          _en("If your blood group is Rh negative, an anti-D injection, if "
              "your doctor advises it."),
          _en("A check with your doctor around six weeks after the birth, for "
              "your body and for how you're feeling."),
          _en("A separate appointment, often six to twelve weeks later, to go "
              "through any test results and what they mean for the future."),
        ],
        tip: PvReadTip(
          title: _en('Take your questions with you'),
          body: _en("Write questions down as they come to you, because it's "
              "easy to forget them in the room. Your partner or someone from "
              "your family can come with you and take notes."),
        ),
      ),
      PvReadSection(
        heading: _en('Rest, food and the weeks ahead'),
        paragraphs: [
          _en("The rest after a birth that many Indian families keep, often 40 "
              "days, can help your body here too. If it feels right, let "
              "family look after you. If being cared for like a new mother "
              "without your baby is too painful, you can tell them what you "
              "need instead."),
          _en("Eat well, with iron-rich foods like dal, green leafy "
              "vegetables, and eggs or meat if you eat them. Keep taking any "
              "iron or calcium tablets your doctor prescribed until they tell "
              "you to stop. Short, gentle walks help your body and your "
              "mood."),
          _en("For a while your body may feel like a stranger. Be patient "
              "with it. It carried your baby, and it's healing."),
        ],
      ),
    ],
    whenToSeeSomeone: _bodyUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Will the milk stop on its own?'),
        answer: _en("Yes. If you don't feed or express, it usually settles over "
            "a week or two, though it can be uncomfortable. The medicine can "
            "make it quicker and easier if it's right for you."),
      ),
      PvReadFaq(
        question: _en('When can we have sex again?'),
        answer: _en("When the bleeding has stopped and you both feel ready. "
            "Some couples want closeness soon, others not for a long time. "
            "Ask your doctor about contraception, because you can get "
            "pregnant before your first period."),
      ),
      PvReadFaq(
        question: _en('Should I still keep the 40 days of rest?'),
        answer: _en("Only if it helps you. Rest is good for your body. The "
            "rituals around it are yours to keep, change or skip."),
      ),
    ],
    evidence: _en('RCOG Green-top Guideline 55, Late intrauterine fetal death '
        'and stillbirth · NICE guideline NG194, Postnatal care (2021) · WHO '
        'recommendations on maternal and newborn care for a positive '
        'postnatal experience (2022).'),
    readNext: [
      'preg_loss_read_stillbirth',
      'preg_loss_read_when_hospital',
      'preg_loss_read_grief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Periods and the body in the weeks after
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_periods_after',
    hue: _hue,
    kicker: _kBody,
    title: _en('Your periods and your body in the weeks after'),
    teaser: _en("When your period comes back, sex and contraception, and "
        "getting your strength back."),
    shortAnswer: _en("After an early miscarriage your first period usually "
        "comes four to six weeks later, and it can be heavier than usual. You "
        "can get pregnant before it comes, so use contraception if you aren't "
        "ready. Good food and gentle movement help your body recover."),
    scaleSetter: _en("Your body finds its usual rhythm again over a month or "
        "two. Knowing the usual pattern helps you tell what's normal from "
        "what's worth a call."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In the weeks after a loss, you might watch your body closely, or "
            "not want to think about it at all. Both are understandable."),
        _en("This read covers the practical questions most women have in "
            "those weeks, so you have the answers when you want them."),
      ]),
      PvReadSection(
        heading: _en('When will my period come back?'),
        paragraphs: [
          _en("After an early miscarriage, most women have a period four to "
              "six weeks later. After a later loss it can take longer, "
              "especially if your milk came in."),
          _en("The first one or two periods may be heavier, more painful or "
              "less regular than you're used to. That usually settles."),
          _en("If you haven't had a period about eight weeks after the loss, "
              "do a pregnancy test and tell your doctor."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I get pregnant before my period comes?'),
        paragraphs: [
          _en("Yes. Your body can release an egg about two weeks before your "
              "first period, so you can get pregnant before you've had one. "
              "If you don't want to be pregnant yet, use contraception from "
              "the time you start having sex again."),
          _en("Most kinds, including condoms, the pill and a copper T, can be "
              "started soon after a miscarriage. Your doctor can help you "
              "choose. 'When is it okay to try again?' on this door covers "
              "the timing if you do want to."),
        ],
      ),
      PvReadSection(
        heading: _en('When can we have sex again?'),
        paragraphs: [
          _en("When the bleeding has stopped and you both want to. After an "
              "early miscarriage there's no medical reason to wait longer "
              "than that."),
          _en("Some couples find closeness comforting soon. Others need weeks "
              "or months, and the two of you may not feel the same. Talk about "
              "it gently. Sex can bring up feelings about the loss, and "
              "that's normal too."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I get my strength back?'),
        bullets: [
          _en("Iron. You may have lost blood. Eat dal, rajma, chana, green "
              "leafy vegetables, and eggs, fish or meat if you eat them, with "
              "a squeeze of lemon or some amla to help your body take the iron "
              "in. Keep taking any iron tablets your doctor prescribed."),
          _en("Folic acid. If you might try again, many doctors suggest "
              "carrying on with it."),
          _en("Sleep. Grief can break sleep. A regular bedtime, less time on "
              "your phone at night, and a short walk in daylight each morning "
              "help a little."),
          _en("Movement. Start with gentle walks. Yoga, the gym and running "
              "can wait until the bleeding has stopped and you feel ready."),
        ],
      ),
      PvReadSection(
        heading: _en('Is it normal that my body feels different?'),
        paragraphs: [
          _en("Yes. After a later loss, some women lose more hair than usual "
              "for a few months; it grows back. Your weight and your tummy may "
              "take time to settle. Your breasts may feel different for a "
              "while."),
          _en("Some women feel angry with their body, or disconnected from it. "
              "That's a common part of grief. It carried a pregnancy, and it "
              "deserves patience."),
          _en("If something doesn't feel right, or a period is very heavy, "
              "call your doctor. Soaking a pad in an hour or less means going "
              "to hospital straight away."),
        ],
      ),
      PvReadSection(
        heading: _en('What about pregnancy tests?'),
        paragraphs: [
          _en("The pregnancy hormone (hCG) takes time to leave your body. A "
              "home test can stay positive for a few weeks after a loss, and "
              "that's expected."),
          _en("If your doctor asked you to do a test three weeks after the "
              "loss, do it on that day. If it's still positive, call them. "
              "They may want a blood test or a scan to check that everything "
              "has come away."),
          _en("Some women find it hard to see a positive test again, even when "
              "they know why. If you'd rather not look, ask your partner or "
              "someone close to read it for you."),
        ],
      ),
      PvReadSection(
        heading: _en('Do I need a check-up?'),
        paragraphs: [
          _en("Not every woman needs a follow-up visit after an early "
              "miscarriage that has completed. Your doctor will tell you if "
              "they want to see you, or if they want a scan or blood test."),
          _en("It's still fine to ask for a visit, to talk about what "
              "happened, your periods, contraception or trying again. After "
              "a later loss, a stillbirth or an ectopic, you'll usually have "
              "a follow-up appointment anyway."),
        ],
      ),
    ],
    whenToSeeSomeone: _bodyUrgent,
    faqs: [
      PvReadFaq(
        question: _en('My first period was very heavy. Is that normal?'),
        answer: _en("The first period after a loss is often heavier than "
            "usual. Soaking a pad in an hour or less, or feeling faint, means "
            "going to hospital straight away."),
      ),
      PvReadFaq(
        question: _en('Should I track my cycle?'),
        answer: _en("Only if it helps you. Some women find it calming. Others "
            "find it a daily reminder. Either is fine."),
      ),
      PvReadFaq(
        question: _en('Can I start a copper T straight away?'),
        answer: _en("Often, yes, after an early miscarriage. Your doctor will "
            "check that the womb is empty and there's no infection first."),
      ),
    ],
    evidence: _en('NICE guideline NG126, Ectopic pregnancy and miscarriage '
        '(2019, updated 2023) · WHO Medical eligibility criteria for '
        'contraceptive use (2015) · RCOG patient information, Early '
        'miscarriage · ICMR Nutrient requirements for Indians (2020), on iron '
        'foods.'),
    readNext: [
      'preg_loss_read_trying_again',
      'preg_loss_read_body_after_miscarriage',
      'preg_loss_read_grief',
    ],
  ),

  // ===========================================================================
  //  UNDERSTAND
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Miscarriage, and why it wasn't her fault
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_miscarriage',
    hue: _hue,
    kicker: _kUnderstand,
    title: _en("Miscarriage, and why it wasn't your fault"),
    teaser: _en("Why miscarriages happen, the things that don't cause them, "
        "and what the words on your papers mean."),
    shortAnswer: _en("A miscarriage is when a pregnancy ends on its own before "
        "20 weeks. Most happen because the pregnancy couldn't develop, often "
        "because of a chromosome problem from the very start. Nothing you "
        "ate, lifted or felt caused it."),
    scaleSetter: _en("Around 1 in 5 to 1 in 6 known pregnancies end in "
        "miscarriage, most in the first 12 weeks. That doesn't make yours "
        "small. It does mean you're far from alone, even if nobody around you "
        "talks about it."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("If you're blaming yourself, you're not the only one. Almost every "
            "woman goes back over the days before, looking for the thing she "
            "did wrong. This read is here to answer that as clearly as we "
            "can."),
        _en("The medical facts, the signs and how it's managed are on the "
            "'Miscarriage / pregnancy loss' page in Complications. This read "
            "is about the questions that come after."),
      ]),
      PvReadSection(
        heading: _en('Why do miscarriages happen?'),
        paragraphs: [
          _en("In most early miscarriages, the pregnancy had a problem with its "
              "chromosomes from the moment it began. Chromosomes carry the "
              "instructions for growth. When there are too many or too few, "
              "the pregnancy can't develop, and the body ends it."),
          _en("This happens by chance, in the egg or the sperm or in the very "
              "first cell divisions. It isn't something either of you passed "
              "on, and it usually doesn't happen again."),
          _en("Less often, and more often in later losses, there's a cause "
              "like an infection, the shape of the womb, the neck of the womb "
              "opening too early, or a health condition like diabetes or "
              "thyroid disease that isn't under control. Your doctor can look "
              "into these."),
          _en("Often no cause is ever found. That's hard to accept, but it's "
              "common, and it doesn't mean something was missed."),
        ],
      ),
      PvReadSection(
        heading: _en("What doesn't cause a miscarriage?"),
        paragraphs: [
          _en("Families sometimes blame these, out of love and worry. None of "
              "them cause a miscarriage:"),
        ],
        bullets: [
          _en("Going to work, climbing stairs, travelling, or lifting everyday "
              "things."),
          _en("Walking, housework, yoga or normal exercise."),
          _en("Sex."),
          _en("Stress, an argument, crying or feeling sad."),
          _en("Papaya, pineapple or any other everyday food eaten in normal "
              "amounts."),
          _en("Having strong morning sickness, or none at all."),
          _en("The evil eye, a missed fast or puja, or anything you said or "
              "thought."),
        ],
        tip: PvReadTip(
          title: _en('If someone blames you'),
          body: _en("You can say, 'The doctor told me nothing I did caused "
              "this.' You can show them this page."),
        ),
      ),
      PvReadSection(
        heading: _en('Is anything linked to it?'),
        paragraphs: [
          _en("Across large groups of women, a few things are linked to more "
              "miscarriages: being older, smoking, heavy drinking, some "
              "medicines, and some illnesses that aren't treated."),
          _en("Linked across a population isn't the same as causing one "
              "particular loss. Many women with none of these still miscarry, "
              "and many women with them don't."),
          _en("If there's something in your health worth looking at before "
              "another pregnancy, your doctor will tell you. That's about care "
              "next time, not blame for this time."),
        ],
      ),
      PvReadSection(
        heading: _en('What do the words on my papers mean?'),
        bullets: [
          _en("Complete miscarriage: the pregnancy has passed and the womb is "
              "empty."),
          _en("Incomplete miscarriage: some tissue is still in the womb."),
          _en("Missed (silent) miscarriage: the pregnancy stopped growing but "
              "hasn't come away yet. It's often found on a routine scan, which "
              "can be a terrible shock."),
          _en("Chemical (biochemical) pregnancy: a very early loss, soon after "
              "a positive test, before anything shows on a scan."),
        ],
        tip: PvReadTip(
          title: _en("If your papers say 'abortion'"),
          body: _en("Hospital papers sometimes say 'spontaneous abortion' or "
              "'missed abortion'. In medicine this only means that a pregnancy "
              "ended. It doesn't mean anyone chose it. The word can still "
              "hurt, and it's okay to ask your doctor to use a different "
              "one."),
        ),
      ),
      PvReadSection(
        heading: _en('How is it managed?'),
        paragraphs: [
          _en("There are three ways: waiting for it to happen naturally, "
              "tablets to help it along, or a short procedure to empty the "
              "womb. All three are medically safe. Your doctor will talk "
              "through which fits your situation, and your wishes count."),
          _en("'Your body after a miscarriage' on this door explains what the "
              "days afterwards are usually like."),
        ],
      ),
      PvReadSection(
        heading: _en('Will it happen again?'),
        paragraphs: [
          _en("For most women, one miscarriage doesn't mean another. Most go "
              "on to have a healthy pregnancy next time."),
          _en("If you've had two or more losses, 'More than one loss: when to "
              "ask about tests' on this door explains what doctors look for "
              "and what can help."),
        ],
      ),
      PvReadSection(
        heading: _en("Why wasn't I offered tests?"),
        paragraphs: [
          _en("After one early miscarriage, most doctors don't order tests for "
              "a cause. That isn't because your loss doesn't matter. It's "
              "because a single early loss is almost always a chance problem "
              "in that pregnancy, and tests rarely find anything that would "
              "change what happens next."),
          _en("If you'd like to talk it through anyway, ask for a visit. Your "
              "doctor can go over your health and answer your questions."),
        ],
      ),
    ],
    whenToSeeSomeone: _bodyUrgent,
    faqs: [
      PvReadFaq(
        question: _en("Could I have stopped it if I'd gone to the doctor "
            "sooner?"),
        answer: _en("Almost always, no. Once a miscarriage has started, rest "
            "and medicine can't usually stop it. Going sooner helps with pain "
            "and bleeding, not with how it ends."),
      ),
      PvReadFaq(
        question: _en("Was it because I didn't rest enough?"),
        answer: _en("No. Bed rest doesn't prevent miscarriage."),
      ),
      PvReadFaq(
        question: _en('Did a fall cause it?'),
        answer: _en("An everyday slip or bump in early pregnancy doesn't cause "
            "a miscarriage. The womb is well protected inside your pelvis. If "
            "you had a serious fall or accident, your doctor will have "
            "checked for anything else."),
      ),
    ],
    evidence: _en('NICE guideline NG126, Ectopic pregnancy and miscarriage '
        '(2019, updated 2023) · RCOG patient information, Early miscarriage '
        '· Quenby S et al., Miscarriage matters, The Lancet (2021) · FOGSI '
        'guidance on early pregnancy loss.'),
    readNext: [
      'preg_loss_read_tests_after',
      'preg_loss_read_body_after_miscarriage',
      'preg_loss_read_grief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Ectopic pregnancy
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_ectopic',
    hue: _hue,
    kicker: _kUnderstand,
    title: _en('Ectopic pregnancy: the signs, and the treatments'),
    teaser: _en("Why an ectopic pregnancy can't continue, the signs that need "
        "a hospital straight away, and what each treatment involves."),
    shortAnswer: _en("An ectopic pregnancy grows outside the womb, usually in "
        "a tube, and it can't continue. It's treated by close watching, an "
        "injection or an operation, depending on what your doctor finds. "
        "Sharp one-sided pain, shoulder-tip pain or feeling faint means going "
        "to hospital straight away."),
    scaleSetter: _en("It happens in about 1 to 2 in every 100 pregnancies, "
        "and most are now found early, before an emergency. Being told a "
        "pregnancy can't continue is a loss, whatever the medical reason."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("An ectopic pregnancy can be frightening twice over: the loss of "
            "the pregnancy, and the worry for your own health. This read takes "
            "them one at a time."),
        _en("The 'Ectopic pregnancy' page in Complications has the short "
            "medical version. This one goes further into the treatments and "
            "what comes after."),
      ]),
      PvReadSection(
        heading: _en('What is an ectopic pregnancy?'),
        paragraphs: [
          _en("Normally a fertilised egg travels down a fallopian tube and "
              "settles in the lining of the womb. In an ectopic pregnancy it "
              "settles somewhere else, almost always in the tube."),
          _en("The tube can't stretch to hold a growing pregnancy. If it "
              "grows, the tube can burst and bleed inside. That's why it has "
              "to be treated, and why it can never become a baby."),
          _en("It isn't caused by anything you did. Some things make it more "
              "likely, like a past infection in the tubes, earlier surgery on "
              "the tubes or a past ectopic. Many women who have one have none "
              "of these."),
        ],
      ),
      PvReadSection(
        heading: _en('Which signs mean going to hospital straight away?'),
        bullets: [
          _en("Sharp or constant pain low in your tummy, often on one side."),
          _en("Pain at the tip of your shoulder, where your arm begins. This "
              "can mean bleeding inside."),
          _en("Feeling faint or dizzy, or looking very pale and sweaty."),
          _en("Pain when you poo or pee, or diarrhoea with the pain."),
          _en("Bleeding from the vagina, though some women have little or "
              "none."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en("Don't wait to see if it passes"),
          body: _en("If you have pain with any of these, go to the emergency "
              "department (casualty) straight away, or call 108."),
        ),
      ),
      PvReadSection(
        heading: _en('How is it found?'),
        paragraphs: [
          _en("With an internal (transvaginal) scan, and blood tests for the "
              "pregnancy hormone (beta-hCG), often repeated two days apart. "
              "How the level changes matters as much as one number."),
          _en("Sometimes it takes a few visits to be sure where the pregnancy "
              "is. The waiting is hard. It's fine to ask what each test is "
              "looking for, and when you'll know."),
        ],
      ),
      PvReadSection(
        heading: _en('What are the treatments?'),
        paragraphs: [
          _en("Your doctor decides with you, based on your scan, your hormone "
              "level and how you are."),
        ],
        bullets: [
          _en("Watching and waiting. If the hormone level is low and falling "
              "and you're well, some ectopic pregnancies end on their own. "
              "You'll have blood tests until the level is back to normal."),
          _en("An injection (methotrexate). This medicine stops the pregnancy "
              "growing so your body can absorb it, without surgery. You'll "
              "have blood tests for a few weeks. You'll be asked not to get "
              "pregnant for three months afterwards, because the medicine "
              "lowers folic acid."),
          _en("An operation, usually keyhole surgery (laparoscopy). The "
              "surgeon removes the pregnancy, most often with the tube "
              "(salpingectomy), or sometimes opens the tube and leaves it "
              "(salpingotomy). If there's bleeding inside, surgery happens "
              "straight away."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens after treatment?'),
        bullets: [
          _en("Some pain and light bleeding for a few days is normal. Severe "
              "pain, fever or feeling faint means going back to hospital "
              "straight away."),
          _en("If your blood group is Rh negative, ask whether you need an "
              "anti-D injection."),
          _en("After the injection, avoid alcohol and ask your doctor before "
              "taking any painkiller other than the one they suggest, until "
              "they say it's fine."),
          _en("Go to every follow-up blood test. They're how your doctor knows "
              "the treatment has worked."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I have a baby after an ectopic?'),
        paragraphs: [
          _en("Most women who have had one ectopic pregnancy go on to have "
              "healthy pregnancies, including women with only one tube."),
          _en("In a next pregnancy, tell your doctor as soon as you have a "
              "positive test. They'll usually offer an early scan to check "
              "where the pregnancy has settled."),
        ],
      ),
      PvReadSection(
        heading: _en('How might I feel?'),
        paragraphs: [
          _en("Many women say an ectopic pregnancy felt like two shocks at "
              "once: a pregnancy lost, and an emergency for their own body. "
              "Some feel grief straight away. Some feel only relief to be "
              "safe, and the sadness comes later."),
          _en("If you had surgery or lost a tube, you may also grieve the "
              "change in your body, or worry about the future. These feelings "
              "are all normal. The Support tab on this door has pieces on "
              "grief and on finding someone to talk to."),
        ],
      ),
    ],
    whenToSeeSomeone: _bodyUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Could the pregnancy have been moved into my womb?'),
        answer: _en("No. There's no way to move an ectopic pregnancy into the "
            "womb. Treating it is the only safe choice."),
      ),
      PvReadFaq(
        question: _en('Is it still a loss if it could never have continued?'),
        answer: _en("Yes. Many women grieve an ectopic pregnancy, and feel fear "
            "for their own body too. Both are real."),
      ),
      PvReadFaq(
        question: _en("I have one tube now. Will I ovulate less?"),
        answer: _en("No. Both ovaries still release eggs, and the remaining "
            "tube can pick up an egg from either side."),
      ),
    ],
    evidence: _en('NICE guideline NG126, Ectopic pregnancy and miscarriage '
        '(2019, updated 2023) · RCOG Green-top Guideline 21, Diagnosis and '
        'management of ectopic pregnancy (2016) · FOGSI guidance on ectopic '
        'pregnancy.'),
    readNext: [
      'preg_loss_read_when_hospital',
      'preg_loss_read_trying_again',
      'preg_loss_read_grief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Stillbirth
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_stillbirth',
    hue: _hue,
    kicker: _kUnderstand,
    title: _en('When your baby dies before birth (stillbirth)'),
    teaser: _en("What happens next, the choices you can make about time with "
        "your baby, and the questions tests can answer."),
    shortAnswer: _en("If your baby has died in the womb, most women are "
        "advised to give birth vaginally, usually with medicine to start "
        "labour, and you may be able to go home for a little while first. You "
        "can choose whether to see, hold and name your baby, and whether to "
        "have tests. There's no wrong choice."),
    scaleSetter: _en("This is one of the hardest things a family can go "
        "through. The hospital team should guide you step by step. This read "
        "is here so you know the choices ahead, and that each one is yours."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("We're so sorry. You may have just heard the words no parent "
            "should hear, or you may be looking back. Go gently. You can stop "
            "reading at any point and come back."),
        _en("Doctors use different week lines for the word 'stillbirth', from "
            "20 to 28 weeks, depending on the country and the record. However "
            "many weeks it was, your baby was your baby."),
      ]),
      PvReadSection(
        heading: _en('What happens after the news?'),
        paragraphs: [
          _en("Usually a scan confirms that your baby's heart has stopped. "
              "Your doctor will then talk with you about the birth. For most "
              "women a vaginal birth is safer than a caesarean, and it helps "
              "recovery and future pregnancies. Labour is usually started "
              "with tablets (induction)."),
          _en("If you're well and your waters haven't broken, you may be able "
              "to go home for a day or two first, to be with family and "
              "gather yourself. If there's an infection, bleeding or high "
              "blood pressure, your doctor will advise going ahead sooner."),
          _en("Sometimes a caesarean is advised. Ask your doctor to explain "
              "why. In labour you can have pain relief, including an epidural "
              "where it's available. Ask for what you need."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I see and hold my baby?'),
        paragraphs: [
          _en("Yes, if you want to. Many parents find time with their baby "
              "precious, and some later wish they'd had more. Others don't "
              "want to, and that's okay too. You can change your mind, and you "
              "can ask the staff to describe your baby first."),
        ],
        bullets: [
          _en("Seeing and holding your baby, alone or with family."),
          _en("Giving your baby a name."),
          _en("Photographs, handprints and footprints, or a lock of hair."),
          _en("Dressing your baby, or wrapping them in a cloth from home."),
          _en("Prayers, rites or a blessing in your faith, in the hospital."),
        ],
        tip: PvReadTip(
          title: _en('Someone to speak for you'),
          body: _en("Some hospitals in India have staff trained to help "
              "bereaved parents; many don't yet. Ask a family member to bring "
              "a phone for photos and a soft cloth, and to ask the staff for "
              "what you want."),
        ),
      ),
      PvReadSection(
        heading: _en('What can tests tell us?'),
        paragraphs: [
          _en("Tests can sometimes find why a baby died, which can help with "
              "grief and with care in a future pregnancy. They're offered, "
              "never required. Sometimes no cause is found, even after every "
              "test."),
        ],
        bullets: [
          _en("Blood tests for you, for infection, sugar, thyroid, clotting "
              "and blood group."),
          _en("An examination of the placenta, which often gives the most "
              "answers."),
          _en("Where it's available, a post-mortem examination of your baby "
              "by a specialist. You can choose a full one, a limited one of "
              "some areas only, or none. Your baby is treated with care and "
              "returned to you."),
          _en("Genetic tests on the baby or the placenta, if your doctor "
              "advises them."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we say goodbye?'),
        paragraphs: [
          _en("Your family's customs may guide what happens next, burial or "
              "cremation and the rites. Communities have different practices "
              "for a baby, and some families aren't sure what's expected. Ask "
              "whoever guides your family in faith, and do what feels right "
              "to you both."),
          _en("In India, a stillbirth is registered, like a birth. The "
              "hospital usually reports it to the registrar. Ask them which "
              "papers you'll get, and whether you need to do anything."),
        ],
      ),
      PvReadSection(
        heading: _en('What about my body, and our grief?'),
        paragraphs: [
          _en("Your body will recover as it would after any birth, with "
              "bleeding for some weeks and milk coming in a few days later. "
              "'Recovering after a later loss or stillbirth' on this door "
              "explains what helps."),
          _en("Some parents feel a crushing weight straight away. Some feel "
              "numb for weeks. Fathers and grandparents grieve too, often out "
              "of sight. The Support tab has reads on grief, on his grief, and "
              "on telling family."),
          _en("You'll be invited back to talk through any results, usually "
              "after several weeks. Before a next pregnancy, your doctor will "
              "talk with you about extra care."),
        ],
      ),
      PvReadSection(
        heading: _en('Who can be with us?'),
        paragraphs: [
          _en("You can ask for your husband or partner, or another person you "
              "choose, to stay with you through labour and afterwards. Many "
              "hospitals will try to give you a room away from the sounds of "
              "other babies. It's okay to ask for that."),
          _en("If family want to come and see your baby or say a prayer, the "
              "staff can usually make time and space for them."),
        ],
      ),
    ],
    whenToSeeSomeone: _bodyUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Did something I did cause this?'),
        answer: _en("Almost certainly not. Many stillbirths are linked to "
            "problems with the placenta, infection or conditions nobody could "
            "have seen coming. If you keep going back over the last days, "
            "please be gentle with yourself. Tests are for answers, not "
            "blame."),
      ),
      PvReadFaq(
        question: _en('Do we have to decide everything straight away?'),
        answer: _en("No. Ask for time. Most choices about seeing your baby, "
            "photos and tests can wait a few hours, and some a little longer. "
            "The staff can help you think."),
      ),
      PvReadFaq(
        question: _en('Can our older children see the baby?'),
        answer: _en("If you'd like them to, yes. Prepare them first with a few "
            "honest words about what they'll see."),
      ),
    ],
    evidence: _en('RCOG Green-top Guideline 55, Late intrauterine fetal death '
        'and stillbirth · WHO, Making every baby count: audit and review of '
        'stillbirths and neonatal deaths (2016) · Registration of Births and '
        'Deaths Act, 1969 (India) · NICE guideline NG194, Postnatal care '
        '(2021).'),
    readNext: [
      'preg_loss_read_later_loss_recovery',
      'preg_loss_read_grief',
      'preg_loss_read_his_grief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Ending a pregnancy for medical reasons
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_tfmr',
    hue: _hue,
    kicker: _kUnderstand,
    title: _en('Ending a pregnancy for medical reasons'),
    teaser: _en("When a scan or test finds a serious problem: what the law in "
        "India allows, what happens, and the grief that follows."),
    shortAnswer: _en("Sometimes a scan or test finds a serious problem with "
        "the baby or a danger to your health, and parents decide with their "
        "doctors to end the pregnancy. In India this is legal under the MTP "
        "Act, within limits set by weeks and by doctors' opinions. Whatever "
        "you decide, the grief afterwards is real."),
    scaleSetter: _en("This is one of the hardest decisions anyone can face, "
        "and no single answer fits every family. This page doesn't tell you "
        "what to choose. It explains what happens, so you can decide with "
        "your doctor and look after yourself afterwards."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("You may be reading this before a decision, or after one. Either "
            "way, you won't find judgement here."),
        _en("Many families in India face this, and very few talk about it. "
            "That silence can make it lonelier. You're not the only one."),
      ]),
      PvReadSection(
        heading: _en('What does the law in India say?'),
        paragraphs: [
          _en("The Medical Termination of Pregnancy (MTP) Act, updated in "
              "2021, allows a registered doctor to end a pregnancy in an "
              "approved hospital or clinic. In plain words:"),
        ],
        bullets: [
          _en("Up to 20 weeks, on the opinion of one doctor."),
          _en("From 20 to 24 weeks, on the opinion of two doctors, in certain "
              "situations. These include a serious problem found in the "
              "baby."),
          _en("After 24 weeks, when a serious problem is found in the baby, "
              "on the opinion of a Medical Board set up by the state."),
          _en("If you're an adult, the law asks for your own consent. It "
              "doesn't require your husband's or your family's signature."),
          _en("Your name and details are kept confidential by law."),
        ],
        tip: PvReadTip(
          title: _en('Your doctor explains what applies to you'),
          body: _en("The rules have detail, and they can change. Your doctor "
              "will explain what applies in your case, and help with the "
              "Medical Board if one is needed."),
        ),
      ),
      PvReadSection(
        heading: _en('How do we decide?'),
        paragraphs: [
          _en("Your doctors should explain the finding, what it means for your "
              "baby and for you, and what would happen if the pregnancy went "
              "on. You can ask for a second opinion, a specialist scan, or a "
              "meeting with a fetal medicine specialist or a genetic "
              "counsellor. Questions that often help:"),
        ],
        bullets: [
          _en("What exactly has been found, and how sure are you?"),
          _en("What would life be like for our baby, and for how long?"),
          _en("What would carrying on mean for my own health?"),
          _en("How would the pregnancy be ended at this stage, and what would "
              "that involve?"),
          _en("How much time do we have to think?"),
        ],
      ),
      PvReadSection(
        heading: _en('What happens?'),
        paragraphs: [
          _en("Earlier in pregnancy, it may be done with medicines or a short "
              "procedure. Later, it usually means labour is started with "
              "medicines and you give birth. Your doctor will explain each "
              "step, the pain relief you can have, and how long it may take."),
          _en("Later in pregnancy you have the same choices as any parent "
              "whose baby has died: seeing and holding your baby, a name, "
              "photos, tests, and the rites your family keeps. 'When your baby "
              "dies before birth' on this door explains these."),
          _en("Your body then recovers as it would after any loss at that "
              "stage. The Your body tab has what to expect."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does the grief feel so complicated?'),
        paragraphs: [
          _en("Grief after ending a pregnancy for medical reasons is real "
              "grief. It can come with guilt, relief, anger and sadness all at "
              "once, and with a feeling that you aren't allowed to mourn "
              "because you made a decision. You are allowed."),
          _en("Some families tell others the pregnancy was lost and keep the "
              "details private. That's your choice. Try to have one or two "
              "people you can be fully honest with, or a counsellor."),
        ],
      ),
      PvReadSection(
        heading: _en('What about my partner and family?'),
        paragraphs: [
          _en("Partners often grieve in their own way, and may feel they have "
              "to be the strong one. Talk about the decision together, now "
              "and in the months ahead."),
          _en("If a relative disagrees with a decision you made with your "
              "doctors, you don't owe them a debate. 'Telling family, and what "
              "people will say' on this door has words you can use."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I look after myself afterwards?'),
        paragraphs: [
          _en("Your body needs the same care as after any loss at that stage. "
              "The Your body tab explains the bleeding, the milk that may come "
              "in, and the signs that need a hospital."),
          _en("Many parents find the weeks afterwards harder than they "
              "expected, partly because so few people know. A counsellor who "
              "understands pregnancy loss can help, and so can talking to "
              "other parents who have made the same decision. Ask your "
              "hospital whether they know of a group."),
          _en("If a follow-up appointment is offered to go through results, "
              "try to go. It can help with questions that come later."),
        ],
      ),
    ],
    whenToSeeSomeone: _heartUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Will this affect a future pregnancy?'),
        answer: _en("Ending a pregnancy safely doesn't usually affect a future "
            "one. Depending on the finding, your doctor may suggest genetic "
            "counselling or early tests next time, to give you information."),
      ),
      PvReadFaq(
        question: _en("Can our baby be tested after the birth?"),
        answer: _en("Yes, if you choose. Tests afterwards can sometimes confirm "
            "the finding or add detail, which can help with planning for the "
            "future."),
      ),
      PvReadFaq(
        question: _en('Is it okay that I feel relief as well as sadness?'),
        answer: _en("Yes. Many parents feel both. Relief that a hard wait is "
            "over doesn't mean you loved your baby any less."),
      ),
    ],
    evidence: _en('The Medical Termination of Pregnancy Act, 1971, as amended '
        'in 2021, and the MTP (Amendment) Rules, 2021 · WHO, Abortion care '
        'guideline (2022) · RCOG, Termination of pregnancy for fetal '
        'abnormality (2010) · FOGSI guidance on medical termination of '
        'pregnancy.'),
    readNext: [
      'preg_loss_read_stillbirth',
      'preg_loss_read_grief',
      'preg_loss_read_telling_family',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  More than one loss: tests
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_tests_after',
    hue: _hue,
    kicker: _kUnderstand,
    title: _en('More than one loss: when to ask about tests'),
    teaser: _en("What doctors usually check after repeated losses, what large "
        "studies show, and what to ask."),
    shortAnswer: _en("Many doctors suggest tests after two or three "
        "miscarriages, and sooner after a later loss. Tests look for things "
        "that can be treated, like thyroid or clotting problems or the shape "
        "of the womb, though often no cause is found. Most women who've had "
        "repeated losses still go on to have a baby."),
    scaleSetter: _en("After more than one loss, fear about the next pregnancy "
        "is natural. The figures here come from large groups of women, not a "
        "forecast for anyone. Your doctor is the person to talk to about "
        "you."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("If this has happened more than once, you may feel your body is "
            "letting you down, or that you're somehow to blame. Neither is "
            "true."),
        _en("Repeated losses are often a run of bad luck. When there is a "
            "cause, it's often something that can be helped."),
      ]),
      PvReadSection(
        heading: _en('When do doctors start looking?'),
        paragraphs: [
          _en("Doctors define repeated (recurrent) miscarriage in different "
              "ways: some after two losses, others after three. Many will "
              "start tests after two, especially if you're over 35 or it took "
              "a long time to conceive."),
          _en("After a single loss in the second half of pregnancy, or a "
              "stillbirth, tests are usually offered straight away."),
          _en("Which tests make sense is your doctor's call. It's always fine "
              "to ask."),
        ],
      ),
      PvReadSection(
        heading: _en('What do large studies show?'),
        paragraphs: [
          _en("These figures come from studies of many thousands of women. "
              "They're here because they're often calmer than the fear. They "
              "can't say what will happen in any one pregnancy."),
        ],
        bullets: [
          _en("After one miscarriage, most women's next pregnancy continues, "
              "at close to the same rate as for anyone."),
          _en("After two or three losses, another loss is a little more "
              "common, and still most women go on to have a baby."),
          _en("Even when no cause is found, which happens often, most couples "
              "go on to have a successful pregnancy with good early care."),
        ],
      ),
      PvReadSection(
        heading: _en('What tests might be offered?'),
        bullets: [
          _en("Blood tests for antiphospholipid syndrome, a condition that "
              "makes the blood clot more easily. It can be treated in "
              "pregnancy."),
          _en("Thyroid and sugar tests."),
          _en("A scan of the shape of the womb, sometimes a 3D scan."),
          _en("In some cases, chromosome tests for both partners "
              "(karyotype), or of tissue from a loss."),
          _en("Other tests depending on your history, such as for infection, "
              "or a check of the neck of the womb after a later loss."),
        ],
        tip: PvReadTip(
          title: _en('Before you pay for a long list'),
          body: _en("Some tests are advertised for repeated loss, such as many "
              "immune or 'NK cell' tests, that most guidelines don't "
              "recommend. Ask your doctor what each test will change before "
              "you pay for it."),
        ),
      ),
      PvReadSection(
        heading: _en('What might help next time?'),
        bullets: [
          _en("If a cause is found, a treatment for it. For antiphospholipid "
              "syndrome that's usually low-dose aspirin and a blood thinner "
              "injection. Some womb shapes can be corrected with surgery."),
          _en("Progesterone, for some women who bleed in early pregnancy after "
              "a past miscarriage. Your doctor decides whether it's right for "
              "you."),
          _en("Early scans, regular visits and a named person to call. Care "
              "that starts early is linked with better outcomes, even when no "
              "cause is found."),
          _en("General health: folic acid, no smoking or alcohol, and good "
              "control of thyroid or sugar if you have those."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask at the appointment?'),
        bullets: [
          _en("Which tests do you recommend for us, and why?"),
          _en("Should my husband or partner be tested too?"),
          _en("What will we do differently in the next pregnancy?"),
          _en("Who do I call if I bleed early next time?"),
          _en("Can you refer us to a clinic that specialises in recurrent "
              "loss?"),
        ],
      ),
      PvReadSection(
        heading: _en('How do I get through the waiting?'),
        paragraphs: [
          _en("Tests can take weeks, and some need to be repeated a few weeks "
              "apart to be sure. The waiting can feel endless, especially if "
              "you want to try again."),
          _en("Ask your doctor for a rough timeline: which tests, when, and "
              "when you'll talk about the results. Knowing the next date helps "
              "many women."),
          _en("Keep all your reports, scans and discharge papers in one folder "
              "or on your phone. They're useful at every visit, and in any "
              "future pregnancy."),
        ],
      ),
      PvReadSection(
        heading: _en("What if we're told it's 'unexplained'?"),
        paragraphs: [
          _en("'Unexplained' means the tests haven't found a cause. It doesn't "
              "mean something was missed, and it doesn't mean nothing can be "
              "done. Early care in the next pregnancy still helps many "
              "couples."),
          _en("It can be frustrating to have no answer. Say so to your doctor, "
              "and ask what they would suggest for next time."),
        ],
      ),
      PvReadSection(
        heading: _en('Can my husband come to the appointment?'),
        paragraphs: [
          _en("Yes, and it helps if he can. Some tests are for both of you, "
              "and hearing the plan together means you don't have to carry "
              "it home alone. Repeated loss is something that happens to a "
              "couple, not to one body."),
        ],
      ),
    ],
    whenToSeeSomeone: _bodyUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Is it because of my age?'),
        answer: _en("Across large groups, miscarriage is more common with age, "
            "mostly because more eggs carry chromosome changes. It isn't "
            "your fault, and it doesn't decide what happens next."),
      ),
      PvReadFaq(
        question: _en('Should we try IVF to prevent another loss?'),
        answer: _en("IVF doesn't prevent miscarriage for most couples. Your "
            "doctor may discuss it if there's a separate fertility problem."),
      ),
      PvReadFaq(
        question: _en("The tests found nothing. Is that bad news?"),
        answer: _en("Often it's reassuring. When no cause is found, most "
            "couples still go on to have a baby."),
      ),
    ],
    evidence: _en('ESHRE guideline, Recurrent pregnancy loss (2022) · RCOG '
        'Green-top Guideline 17, Recurrent miscarriage (2023) · NICE guideline '
        'NG126 (2021 update), on progesterone for bleeding after a previous '
        'miscarriage · Magnus MC et al., BMJ (2019), on recurrence after '
        'miscarriage.'),
    readNext: [
      'preg_loss_read_next_pregnancy_care',
      'preg_loss_read_trying_again',
      'preg_loss_read_miscarriage',
    ],
  ),

  // ===========================================================================
  //  SUPPORT
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Grief
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_grief',
    hue: _hue,
    kicker: _kSupport,
    title: _en('Grief has no timetable'),
    teaser: _en("What grief after a pregnancy loss can feel like, why it "
        "comes in waves, and small things that help."),
    shortAnswer: _en("Grief after a pregnancy loss is real grief, at any "
        "number of weeks. It often comes in waves: numbness, sadness, anger, "
        "guilt, and some days that feel almost ordinary. There's no right way "
        "or right speed, and help is there if it gets too heavy."),
    scaleSetter: _en("Many women say the hardest part was how fast everyone "
        "else moved on. Your grief can take the time it takes."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("This is a lot to carry. You lost a pregnancy, and often a whole "
            "picture of the future with it: a name, a due date, a place in "
            "the home, a first festival together."),
        _en("This read won't tell you how to feel. It's here so you know that "
            "what you feel is normal, and where to turn if it gets too "
            "much."),
      ]),
      PvReadSection(
        heading: _en('What can grief feel like?'),
        bullets: [
          _en("Numbness, as if it happened to someone else."),
          _en("Deep sadness, and tears that come without warning."),
          _en("Anger: at your body, at doctors, at God, or at other pregnant "
              "women."),
          _en("Guilt, and going over the days before, looking for a reason."),
          _en("Jealousy of other people's babies, and then guilt about the "
              "jealousy."),
          _en("Fear about the future, and about trying again."),
          _en("Tiredness, poor sleep and trouble thinking clearly."),
        ],
        tip: PvReadTip(
          title: _en('All of these are normal'),
          body: _en("Grief doesn't move in a straight line. A good week can be "
              "followed by a hard day, and that doesn't mean you're going "
              "backwards."),
        ),
      ),
      PvReadSection(
        heading: _en('Why does it feel like no one understands?'),
        paragraphs: [
          _en("In many families a pregnancy isn't shared until the early weeks "
              "are over, so a loss can happen with almost no one knowing. "
              "People who do know may say little, or say the wrong thing. "
              "After a later loss, some families feel it's kinder not to speak "
              "of the baby at all."),
          _en("Your baby was real to you from the moment you knew. It's okay "
              "to talk about them, to say their name if you gave one, and to "
              "ask others to do the same."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps?'),
        bullets: [
          _en("Talking to one person who listens without trying to fix it: "
              "your partner, a sister, a friend or a counsellor."),
          _en("Writing a letter to your baby, or a few lines in a diary."),
          _en("A small ritual: lighting a diya, planting a tree, a prayer, or "
              "a donation in your baby's name."),
          _en("Keeping something: a scan picture, a hospital band, a small "
              "toy."),
          _en("Moving your body gently, like a morning walk or some "
              "stretching."),
          _en("Letting others help with food, chores and phone calls."),
          _en("A break from social media, or muting pregnancy and baby "
              "accounts for a while."),
        ],
      ),
      PvReadSection(
        heading: _en('What about my partner?'),
        paragraphs: [
          _en("Partners often grieve differently. One may want to talk, the "
              "other to keep busy. Neither means they care less."),
          _en("Try to tell each other what you need, even in one sentence: 'I "
              "just want you to sit with me,' or 'I need to talk about it "
              "tonight.' 'For her partner: your grief too' on this door is "
              "written for him."),
        ],
      ),
      PvReadSection(
        heading: _en('When is it more than grief?'),
        paragraphs: [
          _en("Grief and depression can look alike. Tell your doctor if, for "
              "more than two weeks, you feel hopeless most of the day, can't "
              "eat or sleep, can't manage ordinary tasks, or feel nothing at "
              "all."),
          _en("Some women also have anxiety or panic, or keep reliving the "
              "loss, which can be a sign of trauma. All of these can be "
              "treated, and asking for help isn't weakness."),
          _en("If you ever have thoughts of harming yourself, call Tele-MANAS "
              "on 14416, free at any hour, or 112 if you're in danger now."),
        ],
      ),
      PvReadSection(
        heading: _en('Will it always feel like this?'),
        paragraphs: [
          _en("For most people, the sharpest pain softens with time. You won't "
              "forget, and you don't have to. Many women find that the grief "
              "becomes something they carry more easily, with days that hurt "
              "and days that don't."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my family grieves differently?'),
        paragraphs: [
          _en("In many Indian homes, grief is shared by a big family, and each "
              "person carries it their own way. Your mother may want to "
              "look after you. Your mother-in-law may want to perform a "
              "ritual. An uncle may want to find a reason. Some may say "
              "nothing at all."),
          _en("Most of it comes from love, even when it doesn't feel like "
              "it. You can let in the care that helps, and ask someone close "
              "to gently turn away the rest for you."),
        ],
      ),
    ],
    whenToSeeSomeone: _heartUrgent,
    faqs: [
      PvReadFaq(
        question: _en("Is it strange to grieve an early loss this much?"),
        answer: _en("No. How much you grieve isn't measured in weeks."),
      ),
      PvReadFaq(
        question: _en('Should I be over it by now?'),
        answer: _en("There's no deadline. If people expect you to move on, "
            "you can tell them you're still sad, and that's okay."),
      ),
      PvReadFaq(
        question: _en("I don't feel much at all. Is something wrong with "
            "me?"),
        answer: _en("No. Numbness is a common part of grief, especially early "
            "on. If it lasts for weeks and you can't enjoy anything, tell your "
            "doctor."),
      ),
    ],
    evidence: _evMind,
    readNext: [
      'preg_loss_read_someone_to_talk',
      'preg_loss_read_hard_days',
      'preg_loss_read_his_grief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  His grief
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_his_grief',
    hue: _hue,
    kicker: _kSupport,
    title: _en('For her partner: your grief too'),
    teaser: _en("For her husband or partner: what she may need, and why your "
        "own grief matters as well."),
    shortAnswer: _en("Partners grieve a pregnancy loss too, even when all the "
        "attention goes to her. Being strong for her doesn't mean hiding your "
        "own sadness. Practical help and staying close matter most, and you "
        "can ask for support yourself."),
    scaleSetter: _en("This page is written to you, her partner. In many "
        "Indian families the husband is expected to handle everything and "
        "feel nothing. That's a heavy thing to carry."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("We're sorry for your loss too. It was your baby as well."),
        _en("Most of what's written about pregnancy loss is for the mother. "
            "This read is for you: how to help her, and how to look after "
            "yourself."),
      ]),
      PvReadSection(
        heading: _en('What might I be feeling?'),
        bullets: [
          _en("Helplessness, watching her in pain and not being able to fix "
              "it."),
          _en("Sadness you feel you have to hide, so she doesn't see it."),
          _en("Fear for her health, especially if there was heavy bleeding or "
              "surgery."),
          _en("Anger, at the doctors, at the timing, or at yourself."),
          _en("Guilt, about going back to work, or about feeling better sooner "
              "than she does."),
        ],
        tip: PvReadTip(
          title: _en('Say it out loud'),
          body: _en("Many men grieve by doing: fixing things, working, keeping "
              "busy. That's a real way of grieving. But she may read silence "
              "as not caring, so tell her: 'I'm sad too.'"),
        ),
      ),
      PvReadSection(
        heading: _en('How can I help her in the first weeks?'),
        bullets: [
          _en("Take over the calls and messages, if she wants you to. Tell "
              "family what happened so she doesn't have to repeat it."),
          _en("Handle the hospital, the papers, the chemist and the bills."),
          _en("Keep the list of warning signs on this door handy, and take her "
              "to hospital straight away if she has heavy bleeding, a fever, "
              "severe pain or feels faint."),
          _en("Protect her from visitors, questions and advice she isn't "
              "ready for, even from your own family."),
          _en("Sit with her. You don't need the right words. 'I'm here' is "
              "enough."),
          _en("Put the hard dates in your calendar, like the due date, and "
              "plan that day together."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I avoid saying?'),
        bullets: [
          _en("'It was God's will', unless she says it first."),
          _en("'We can try again soon.' She may not be ready to think about "
              "another pregnancy."),
          _en("Anything that hints at a reason, like 'you were working too "
              "hard'."),
        ],
        tip: PvReadTip(
          title: _en("If you're not sure"),
          body: _en("Ask her: 'Do you want to talk, or would you rather I just "
              "stay with you?'"),
        ),
      ),
      PvReadSection(
        heading: _en('What about my own grief?'),
        paragraphs: [
          _en("You're allowed to grieve. Talk to a friend, a brother, or a "
              "colleague you trust. Many men find it easier to talk side by "
              "side, on a walk or a drive, than face to face."),
          _en("If you feel low for weeks, drink more than usual, or can't "
              "concentrate at work, talk to a doctor or a counsellor. "
              "Tele-MANAS on 14416 is for you too, free, at any hour."),
          _en("At work, you may be able to take a few days of leave. Ask your "
              "manager or HR."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we stay close as a couple?'),
        paragraphs: [
          _en("Loss can pull a couple together, or push you apart for a while. "
              "Set aside a little time each day, even ten minutes, to check in "
              "with each other."),
          _en("Closeness and sex may take time to come back, and you may not "
              "feel ready at the same time. Be patient with each other. If "
              "you keep arguing, or can't talk about it at all, a couples "
              "counsellor can help."),
        ],
      ),
      PvReadSection(
        heading: _en('If the loss happened later in pregnancy'),
        paragraphs: [
          _en("After a later loss or a stillbirth, there may be more to "
              "handle: the hospital stay, paperwork, and the rites your family "
              "keeps for the baby. If you can, take these on, and ask a "
              "brother or a friend to help you."),
          _en("Her body will be recovering from a birth. She may have "
              "stitches, bleeding for weeks, and milk coming in, which can be "
              "very painful to go through without a baby. 'Recovering after a "
              "later loss or stillbirth' on this door explains what helps, so "
              "you know what to watch for."),
          _en("You may be asked about seeing your baby, photos or tests. You "
              "can make those choices together, and you can ask the staff for "
              "time."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my family expects me to carry on as normal?'),
        paragraphs: [
          _en("Some families expect the husband to be back at work in a day "
              "or two and to keep everyone else steady. You're allowed to say "
              "that you're sad too, and that you need a little time."),
          _en("If elders ask you to explain what went wrong, you can tell them "
              "the doctors have said no one caused it, and that she needs rest "
              "and quiet, not questions."),
        ],
      ),
    ],
    whenToSeeSomeone: _heartUrgent,
    faqs: [
      PvReadFaq(
        question: _en("She doesn't want to talk. What do I do?"),
        answer: _en("Stay near, and let her know you'll listen whenever she's "
            "ready. Small acts count: a cup of tea, a quiet evening, taking "
            "a call for her."),
      ),
      PvReadFaq(
        question: _en('When should I go back to work?'),
        answer: _en("When you both feel it's okay. Some couples need a few days "
            "together first."),
      ),
      PvReadFaq(
        question: _en('My family keeps asking me what went wrong. What do I '
            'say?'),
        answer: _en("'The doctors say nothing anyone did caused it. Please "
            "don't ask her about it.' Then change the subject."),
      ),
    ],
    evidence: _en('WHO, Why we need to talk about losing a baby (2019) · NICE '
        'guideline CG192, Antenatal and postnatal mental health (2014, updated '
        '2020) · Tele-MANAS details from the Ministry of Health and Family '
        'Welfare, Government of India.'),
    readNext: [
      'preg_loss_read_grief',
      'preg_loss_read_telling_family',
      'preg_loss_read_someone_to_talk',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Telling family
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_telling_family',
    hue: _hue,
    kicker: _kSupport,
    title: _en('Telling family, and what people will say'),
    teaser: _en("Short words for telling people, asking someone to tell "
        "others for you, and answering comments that hurt."),
    shortAnswer: _en("You don't owe anyone the full story. A short sentence is "
        "enough, and you can ask one person you trust to tell everyone else. "
        "When people say hurtful things, it's usually worry or awkwardness, "
        "and you can close the conversation kindly."),
    scaleSetter: _en("In India, news travels through families fast, and so do "
        "opinions. Having a few sentences ready can make the next "
        "conversations a little easier."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Telling people can feel like living the loss again each time. "
            "Some women want everyone to know. Others want almost no one to. "
            "Either is okay."),
        _en("Take what's useful here and leave the rest. You can change any "
            "of these words to sound like you."),
      ]),
      PvReadSection(
        heading: _en('What can I say?'),
        paragraphs: [
          _en("Keep it short. You can use or change any of these:"),
        ],
        bullets: [
          _en("'We lost the baby. We're very sad, and we need some quiet "
              "time.'"),
          _en("'The pregnancy ended. I'm okay physically, and I'm not ready "
              "to talk about it yet.'"),
          _en("'Our baby died before birth. We named our baby ___, and we'd "
              "like you to use the name.'"),
          _en("'Thank you for asking. I don't want to talk about it today.'"),
        ],
      ),
      PvReadSection(
        heading: _en('Can someone else tell people for me?'),
        paragraphs: [
          _en("Yes. Ask one person you trust, like your husband, a sister, a "
              "close friend or your mother, to tell others. Ask them to pass "
              "on what you'd like: calls, visits, or only messages for now. It "
              "saves you telling the story again and again."),
          _en("They could send one message to the family group, something "
              "like: 'Asha and Rohan lost their baby this week. They're "
              "grateful for your love. Please give them some space, and send "
              "a message rather than calling for now.'"),
        ],
      ),
      PvReadSection(
        heading: _en('What if people say things that hurt?'),
        paragraphs: [
          _en("Most people mean well and don't know what to say. Some comments "
              "still hurt. You may hear that it was early, that you're young "
              "and there will be others, or advice about what you should have "
              "eaten or avoided."),
          _en("You can answer, or not. A few lines that close the topic:"),
        ],
        bullets: [
          _en("'I know you mean well. It still hurts, and I'd rather not talk "
              "about why.'"),
          _en("'The doctor said nothing I did caused it.'"),
          _en("'This baby mattered to us, however many weeks it was.'"),
          _en("'I need to go and rest now.'"),
        ],
        tip: PvReadTip(
          title: _en('If an elder keeps looking for blame'),
          body: _en("Ask your husband, or someone they respect, to speak to "
              "them for you. You don't have to defend yourself while you're "
              "grieving."),
        ),
      ),
      PvReadSection(
        heading: _en('What about work and friends?'),
        paragraphs: [
          _en("At work you only need to tell your manager or HR what's needed "
              "for leave. 'I've had a pregnancy loss and my doctor has advised "
              "rest' is enough. You can ask them to tell the team you're on "
              "medical leave, without details."),
          _en("With friends who are pregnant or have small babies, it's okay "
              "to keep some distance for a while, and to tell them why if you "
              "want to. Good friends will understand."),
        ],
      ),
      PvReadSection(
        heading: _en('What about plans that were made?'),
        paragraphs: [
          _en("If a godh bharai or another celebration was planned, ask "
              "someone to cancel it for you. If you'd bought things for the "
              "baby, there's no rush to decide what to do with them."),
          _en("Some families hold a small prayer or ritual for the baby, and "
              "some don't. Do what feels right to you both, even if it's "
              "different from what others expect."),
        ],
      ),
      PvReadSection(
        heading: _en('What about WhatsApp and social media?'),
        paragraphs: [
          _en("If you'd shared the pregnancy online, you may get messages "
              "from people who don't know. You can post a short note if you "
              "want to, or ask someone to reply for you. You don't owe anyone "
              "a public update."),
          _en("It's okay to mute family groups for a while, and to mute or "
              "unfollow pregnancy and baby accounts. Many apps also let you "
              "hide memories and reminders of past posts."),
        ],
      ),
      PvReadSection(
        heading: _en("What if someone doesn't know and asks about the baby?"),
        paragraphs: [
          _en("It will probably happen: a neighbour, a shopkeeper, someone at "
              "a wedding. It can take your breath away."),
          _en("A short answer is enough: 'We lost the baby.' If they're "
              "shocked or say something clumsy, you don't have to comfort "
              "them. 'Thank you. I'd rather not talk about it' ends it. Then "
              "go somewhere quiet if you need to."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'd like people to keep talking about it?"),
        paragraphs: [
          _en("Some women find the silence afterwards harder than the "
              "questions. If you'd like people to say your baby's name, ask "
              "how you are, or mark the due date with you, tell one or two "
              "of them. Most people stay quiet because they're afraid of "
              "upsetting you, not because they've forgotten."),
        ],
      ),
    ],
    whenToSeeSomeone: _heartUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Should we tell our older child?'),
        answer: _en("Yes, in short, honest words that suit their age: 'The "
            "baby died, and we're very sad. It wasn't anyone's fault.' "
            "Children often understand more than we expect, and hidden "
            "sadness can confuse them."),
      ),
      PvReadFaq(
        question: _en('What if someone announces a pregnancy?'),
        answer: _en("It's okay to feel pain. You can send a short message "
            "later, and skip the celebration."),
      ),
      PvReadFaq(
        question: _en("We hadn't told anyone we were pregnant. Do we have to "
            "now?"),
        answer: _en("No. You can keep it private, or tell only one or two "
            "people. It still helps to have someone who knows."),
      ),
    ],
    evidence: _en('WHO, Why we need to talk about losing a baby (2019) · NICE '
        'guideline CG192, Antenatal and postnatal mental health (2014, updated '
        '2020), on support after pregnancy loss.'),
    readNext: [
      'preg_loss_read_grief',
      'preg_loss_read_work_leave',
      'preg_loss_read_his_grief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Work and leave
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_work_leave',
    hue: _hue,
    kicker: _kSupport,
    title: _en('Going back to work, and the leave you may have'),
    teaser: _en("The leave Indian law may give you after a miscarriage or "
        "stillbirth, how to ask for it, and easing back in."),
    shortAnswer: _en("Under the Maternity Benefit Act, you may be entitled to "
        "six weeks of paid leave after a miscarriage or a medical "
        "termination, and to maternity benefit after a stillbirth. It depends "
        "on your workplace and how long you've worked there, so ask HR. Go "
        "back when your body and mind are ready."),
    scaleSetter: _en("Most women need some time off after a loss, for the body "
        "and for the heart. This is a starting point, not legal advice. HR or "
        "a lawyer can confirm what applies to you."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Thinking about work may feel impossible right now. You don't "
            "have to sort it out today."),
        _en("This read is for when you, or someone helping you, are ready to "
            "look at it."),
      ]),
      PvReadSection(
        heading: _en('What leave might I be entitled to?'),
        paragraphs: [
          _en("The Maternity Benefit Act, 1961, as amended in 2017, covers "
              "many workplaces in India. In plain words, you may be entitled "
              "to:"),
        ],
        bullets: [
          _en("Six weeks of paid leave after a miscarriage, from the day after "
              "it, with proof such as a doctor's certificate."),
          _en("The same six weeks after a medical termination of pregnancy."),
          _en("Up to one more month of paid leave for an illness that comes "
              "from the pregnancy, the miscarriage, the termination or the "
              "birth, with a doctor's certificate."),
          _en("Maternity benefit after a stillbirth, because the Act counts a "
              "stillborn baby as a child."),
          _en("If you work for the central government, a special maternity "
              "leave of 60 days after a stillbirth or the death of a baby soon "
              "after birth."),
        ],
      ),
      PvReadSection(
        heading: _en('Does the Act cover my workplace?'),
        paragraphs: [
          _en("The Act usually applies to factories, mines and plantations, "
              "and to shops and offices with ten or more employees. You "
              "generally need to have worked there for 80 days in the twelve "
              "months before. State government jobs, ESI-covered workplaces "
              "and others may have their own rules."),
          _en("If your employer says you aren't covered, ask them to explain "
              "in writing which rule applies. You can also ask your state's "
              "Labour Department, or a lawyer."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I ask for it?'),
        bullets: [
          _en("Ask your doctor for a certificate that gives the date and says "
              "you've had a miscarriage, stillbirth or termination. You don't "
              "have to share more detail at work than that."),
          _en("Email HR or your manager with the certificate. A short note is "
              "enough: 'I had a pregnancy loss on [date]. My doctor's "
              "certificate is attached. I'd like to take the leave I'm "
              "entitled to under the Maternity Benefit Act.'"),
          _en("Keep a copy of everything you send and receive."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm self-employed or not covered?"),
        paragraphs: [
          _en("Many women in India work where the Act doesn't reach: family "
              "businesses, farms, homes, daily or gig work. Rest still matters "
              "for your recovery. Ask family to share your work for a while if "
              "they can, and ask your doctor what your body needs."),
          _en("If you're covered by ESI, ask your ESI branch about maternity "
              "benefit."),
        ],
      ),
      PvReadSection(
        heading: _en('When will I be ready to go back?'),
        paragraphs: [
          _en("Many women feel physically able to work within a week or two of "
              "an early miscarriage, and later after a later loss or surgery. "
              "Feeling ready inside can take longer, and it's hard to predict. "
              "Some find work a welcome routine. Others find it too much, too "
              "soon."),
        ],
        bullets: [
          _en("Ask whether you can start with shorter days, or work from home "
              "for a week or two."),
          _en("Decide what you want colleagues to know, and ask your manager "
              "to tell them."),
          _en("Have something that makes the day easier: a quiet place to go, "
              "a friend to message, headphones."),
          _en("Expect some moments to hurt: a pregnant colleague, a baby photo "
              "on a desk, a question you didn't see coming."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm struggling at work?"),
        paragraphs: [
          _en("If you can't concentrate, keep crying at work, or dread going "
              "in, that's common in grief. Tell your doctor. They can advise "
              "more time off, and a counsellor can help. The Support tab has "
              "more."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I talk to my manager?'),
        paragraphs: [
          _en("You only need to say what's needed for leave. If you'd rather "
              "not speak, an email is fine, or someone at home can call for "
              "you."),
          _en("If you'd like some flexibility when you come back, ask for it "
              "plainly: fewer meetings for a while, time off for follow-up "
              "visits, or a quiet place to step away. Many managers want to "
              "help and don't know how. Telling them what helps makes it "
              "easier for both of you."),
          _en("If someone at work says something that hurts, you can tell HR, "
              "or ask a colleague you trust to have a word."),
        ],
      ),
    ],
    whenToSeeSomeone: _heartUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Do I have to tell my employer it was a miscarriage?'),
        answer: _en("To claim leave under the Act, you'll need proof, such as "
            "a doctor's certificate. You don't have to share more than that "
            "with anyone else at work."),
      ),
      PvReadFaq(
        question: _en('Does my husband get leave?'),
        answer: _en("The Maternity Benefit Act doesn't give fathers leave after "
            "a loss. Some employers offer bereavement or other leave, so ask "
            "HR."),
      ),
      PvReadFaq(
        question: _en('Can I be let go for taking this leave?'),
        answer: _en("The Act says an employer can't dismiss you because of an "
            "absence it covers. If this happens, ask your state's Labour "
            "Department or a lawyer for help."),
      ),
    ],
    evidence: _en('The Maternity Benefit Act, 1961, as amended by the '
        'Maternity Benefit (Amendment) Act, 2017, sections 2, 3, 5, 9, 10 and '
        '12 · Department of Personnel and Training, Office Memorandum on '
        'special maternity leave for central government employees after a '
        'stillbirth or neonatal death (2022) · Employees\' State Insurance '
        'Act, 1948, on maternity benefit. Not legal advice.'),
    readNext: [
      'preg_loss_read_telling_family',
      'preg_loss_read_someone_to_talk',
      'preg_loss_read_grief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Someone to talk to
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_someone_to_talk',
    hue: _hue,
    kicker: _kSupport,
    title: _en('Finding someone to talk to'),
    teaser: _en("When to reach out, who can help, and the free helpline that "
        "answers at any hour."),
    shortAnswer: _en("You don't have to be in crisis to talk to someone. Your "
        "doctor, a counsellor or a support group can help you carry this. In "
        "India, Tele-MANAS answers free on 14416, at any hour, in many "
        "languages."),
    scaleSetter: _en("In many Indian families, seeing a counsellor still feels "
        "like a big step. It's a normal one. Talking to a trained person after "
        "a loss is care, not a sign that you aren't coping."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Some women lean on family and friends, and that's enough. Others "
            "find they need someone outside the family, someone who won't be "
            "hurt by what they say."),
        _en("Both are okay, and you can change your mind at any point."),
      ]),
      PvReadSection(
        heading: _en('Who can I talk to?'),
        bullets: [
          _en("Your doctor. They can check how you're doing, and refer you to "
              "a counsellor, psychologist or psychiatrist if you need one."),
          _en("A counsellor who understands pregnancy and loss. ParentVeda's "
              "Support tab has counsellors you can talk to, anonymously."),
          _en("Tele-MANAS, the Government of India's free mental health "
              "helpline: 14416, or 1-800-891-4416. It's open 24x7, in English "
              "and many Indian languages."),
          _en("A support group, in person or online, for parents after a loss. "
              "Some hospitals run one, so ask yours."),
          _en("Someone from your faith community, if that brings you "
              "comfort."),
        ],
      ),
      PvReadSection(
        heading: _en('When should I reach out?'),
        paragraphs: [
          _en("Whenever you want to. You don't have to wait until things are "
              "bad. It's worth reaching out soon if:"),
        ],
        bullets: [
          _en("You've felt low, hopeless or numb most days for more than two "
              "weeks."),
          _en("You can't sleep, can't stop sleeping, or have stopped eating."),
          _en("You keep reliving the loss, or have panic attacks."),
          _en("You're avoiding people, places or things that remind you of it, "
              "and it's getting in the way of life."),
          _en("You're drinking more, or relying on sleeping tablets."),
          _en("You and your partner can't talk about it, or keep arguing."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I have thoughts of harming myself?'),
        paragraphs: [
          _en("Please call Tele-MANAS on 14416 now, or 112 if you're in "
              "danger. Tell someone who is with you, and don't stay alone."),
          _en("These thoughts can come with deep grief. They're a sign you need "
              "help today, not a sign of weakness, and help works."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens when I call Tele-MANAS?'),
        paragraphs: [
          _en("A trained counsellor answers. You can choose your language, and "
              "the call is free. They'll listen, help you through the moment, "
              "and can connect you to a mental health professional near you "
              "if you need one."),
        ],
      ),
      PvReadSection(
        heading: _en('What is counselling like?'),
        paragraphs: [
          _en("A first session is usually a conversation. The counsellor will "
              "ask what happened and how you're feeling now. You can say as "
              "much or as little as you like."),
          _en("Counselling after a loss isn't about forgetting or moving on. It "
              "helps you find a way to live with what happened."),
          _en("If one counsellor doesn't feel right, it's okay to try "
              "another."),
        ],
      ),
      PvReadSection(
        heading: _en('Can my partner or family get help too?'),
        paragraphs: [
          _en("Yes. Partners, and sometimes grandparents, carry this grief as "
              "well. They can call Tele-MANAS or see a counsellor too, alone or "
              "with you."),
        ],
      ),
      PvReadSection(
        heading: _en("What if my family doesn't believe in counselling?"),
        paragraphs: [
          _en("In some families, talking to a stranger about feelings is seen "
              "as unnecessary, or even shameful. You don't need their "
              "permission to look after your mind, and you don't have to tell "
              "them."),
          _en("A phone call to Tele-MANAS or an online session with a "
              "counsellor can be done privately, from wherever you feel safe. "
              "If it helps, you can describe it at home as talking to a "
              "doctor, which is close to the truth."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I do tonight, on my own?'),
        bullets: [
          _en("Breathe slowly: in for four counts, out for six, for a few "
              "minutes. The breathing exercises in Mind & mood can guide "
              "you."),
          _en("Write down what you're feeling, even a few words. It can make "
              "a heavy night a little lighter."),
          _en("Message one person, even just 'I'm having a hard night.'"),
          _en("Eat something small and drink water. Grief is harder on an "
              "empty stomach."),
          _en("Put the phone down an hour before bed, and keep the room dark "
              "and cool."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I find a counsellor near me?'),
        bullets: [
          _en("Ask your gynaecologist or the hospital where you were treated. "
              "Many know a counsellor or psychologist they trust."),
          _en("Call Tele-MANAS and ask them to connect you to a service near "
              "you."),
          _en("Look for a clinical psychologist or counsellor who mentions "
              "pregnancy, loss or grief in their work, and ask about fees "
              "before the first session."),
          _en("Choose online sessions if travelling is hard, or if you'd "
              "rather talk from home."),
        ],
      ),
    ],
    whenToSeeSomeone: _heartUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Is counselling expensive?'),
        answer: _en("Tele-MANAS is free. Government hospitals often have a "
            "psychiatry or psychology department at low cost. Private fees "
            "vary, so ask the price before you book."),
      ),
      PvReadFaq(
        question: _en('Will anyone find out?'),
        answer: _en("Counsellors keep what you say private, except in rare "
            "cases where someone's safety is at risk."),
      ),
      PvReadFaq(
        question: _en("What if I don't know what to say when I call?"),
        answer: _en("You can start with 'I've had a pregnancy loss and I'm "
            "finding it hard.' The person who answers will take it from "
            "there."),
      ),
    ],
    evidence: _evMind,
    readNext: [
      'preg_loss_read_grief',
      'preg_loss_read_hard_days',
      'preg_loss_read_his_grief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Hard days
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_hard_days',
    hue: _hue,
    kicker: _kSupport,
    title: _en('Anniversaries, due dates and hard days'),
    teaser: _en("Why some days hit harder, and small ways to get through "
        "them."),
    shortAnswer: _en("The due date, the day of the loss, festivals and other "
        "people's baby news can bring grief back sharply, even months later. "
        "That's normal. Planning a little for those days, and marking them "
        "your own way, can help."),
    scaleSetter: _en("Grief often comes back around dates. Knowing that ahead "
        "of time won't stop it, but it can stop it catching you off guard."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Many women say they were doing better, and then a date or a small "
            "thing brought it all back. That isn't a step backwards. It's how "
            "grief works."),
        _en("This read is for planning ahead a little, and for the moments you "
            "can't plan for."),
      ]),
      PvReadSection(
        heading: _en('Which days are often hard?'),
        bullets: [
          _en("The date your baby was due."),
          _en("The day you found out, or the day of the loss."),
          _en("Festivals when family gathers, like Diwali, Eid, Christmas or "
              "Lohri, and family weddings."),
          _en("Mother's Day and Father's Day."),
          _en("Baby showers, naming ceremonies, and first birthdays of babies "
              "born around the same time."),
          _en("A pregnancy announcement, or a friend's scan photo."),
          _en("Doctor's visits, especially at the same hospital."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I plan for these days?'),
        bullets: [
          _en("Put the date in your calendar, so it doesn't creep up on you."),
          _en("Decide ahead whether you want company or quiet."),
          _en("Take the day off work if you can."),
          _en("Tell your partner or a friend it's coming, and what would "
              "help."),
          _en("Give yourself a way out of events: arrive late, leave early, or "
              "skip them. 'I'm not up to it this time' is enough."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I mark the day?'),
        paragraphs: [
          _en("Some parents find comfort in doing something for their baby. "
              "Some prefer not to mark the day at all. Both are okay."),
        ],
        bullets: [
          _en("Lighting a diya or a candle."),
          _en("Visiting a temple, mosque, gurdwara or church, or saying a "
              "prayer at home."),
          _en("Planting a tree or a tulsi plant."),
          _en("Writing a letter to your baby."),
          _en("Giving food or a donation in your baby's name."),
          _en("Spending the day with your partner, doing something gentle."),
        ],
      ),
      PvReadSection(
        heading: _en('What if grief catches me by surprise?'),
        paragraphs: [
          _en("Sometimes it isn't a date but a song, a baby crying in the "
              "market, or a question from someone who doesn't know. It can "
              "feel like a wave."),
          _en("Find a quiet place if you can. Breathe in slowly for four "
              "counts and out for six, a few times, and let it pass. It will "
              "pass. The breathing exercises in Mind & mood can help in those "
              "moments."),
          _en("If someone asks a question you can't answer, 'I'm sorry, I "
              "can't talk about that right now' is enough."),
        ],
      ),
      PvReadSection(
        heading: _en('What if the hard days are most days?'),
        paragraphs: [
          _en("If, months later, most days still feel as heavy as the first "
              "weeks, or you can't enjoy anything, tell your doctor or a "
              "counsellor. It isn't failing to grieve properly. Sometimes "
              "grief needs help to move."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the due date itself?'),
        paragraphs: [
          _en("For many parents, the date the baby was due is one of the "
              "hardest days of all. It can arrive when everyone else has "
              "moved on, and when you thought you'd be holding your baby."),
          _en("Some couples plan the day together: a quiet morning, a visit to "
              "a place that matters, a meal with one or two people who know. "
              "Some go to work to keep busy. Either can be right. It helps to "
              "decide a few days before, rather than on the morning."),
        ],
      ),
      PvReadSection(
        heading: _en('When a friend or relative is pregnant'),
        paragraphs: [
          _en("Other people's pregnancies can hurt, even when you're happy for "
              "them. You may feel jealous, then guilty for feeling jealous. "
              "Both are normal and neither makes you a bad person."),
          _en("You can keep some distance for a while. A short message, like "
              "'I'm so happy for you. I may be a bit quiet for a while, and "
              "it isn't about you', lets them know without a long "
              "conversation."),
        ],
      ),
      PvReadSection(
        heading: _en('What about festivals and family gatherings?'),
        paragraphs: [
          _en("Festivals bring family together, and with them come questions, "
              "children everywhere and sometimes a baby being passed around. "
              "It's okay to join for part of the day and leave early, or to "
              "stay home this year."),
          _en("If you do go, agree a signal with your partner for when you "
              "need to step out, and keep an answer ready for anyone who asks "
              "about the pregnancy. If you'd like to, you can light a diya for "
              "your baby as part of the festival, so the day holds them "
              "too."),
        ],
      ),
    ],
    whenToSeeSomeone: _heartUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Is it strange to still cry about it a year later?'),
        answer: _en("No. Many parents feel it sharply on dates for years, and "
            "more gently in between."),
      ),
      PvReadFaq(
        question: _en('What if my partner forgets the date?'),
        answer: _en("People hold dates differently. Tell them gently, a few "
            "days before, that the day matters to you."),
      ),
      PvReadFaq(
        question: _en("Do I have to go to my cousin's baby shower?"),
        answer: _en("No. Send your love with a message or a small gift if you "
            "want to, and stay home."),
      ),
    ],
    evidence: _evMind,
    readNext: [
      'preg_loss_read_grief',
      'preg_loss_read_someone_to_talk',
      'preg_loss_read_trying_again',
    ],
  ),

  // ===========================================================================
  //  TRYING AGAIN
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  When to try again
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_trying_again',
    hue: _hue,
    kicker: _kAgain,
    title: _en('When is it okay to try again?'),
    teaser: _en("What your body needs, what your heart needs, and why the "
        "answer is different for everyone."),
    shortAnswer: _en("After an early miscarriage, many doctors say it's fine "
        "to try again after one normal period, if you feel ready. After an "
        "ectopic treated with an injection, a later loss or a stillbirth, "
        "your doctor will advise how long to wait. Your heart's timing "
        "matters as much as your body's."),
    scaleSetter: _en("No single timing suits everyone. Some couples want to "
        "try again soon, some need months or longer, and some decide not to. "
        "Each is okay."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Thinking about another pregnancy can bring hope and fear "
            "together. You may feel ready one day and not the next."),
        _en("This read separates the two questions: when your body is ready, "
            "and when you are."),
      ]),
      PvReadSection(
        heading: _en('What does my body need?'),
        bullets: [
          _en("After an early miscarriage, many doctors say it's fine to try "
              "once you've had one normal period. That makes a new pregnancy "
              "easier to date, but it isn't a strict medical rule. WHO has "
              "suggested waiting about six months. Advice varies, so follow "
              "your own doctor."),
          _en("After an ectopic treated with methotrexate, wait three months, "
              "because the medicine lowers folic acid, which a new pregnancy "
              "needs."),
          _en("After surgery for an ectopic, or a procedure for a miscarriage, "
              "your doctor will tell you when you've healed."),
          _en("After a later loss or a stillbirth, most doctors suggest "
              "waiting until you've had your follow-up and any results, so "
              "extra care can be planned. How long is a conversation for you "
              "and your doctor."),
        ],
      ),
      PvReadSection(
        heading: _en('What does my heart need?'),
        paragraphs: [
          _en("Some women feel an urgent pull to be pregnant again. Some feel "
              "they can't face it. Some want to wait until the due date has "
              "passed. Each of these is a normal response."),
          _en("It can help to talk through a few things together. Do we feel "
              "ready for a new pregnancy, with its own worries? How will we "
              "manage the anxious early weeks? Who can support us? There are "
              "no wrong answers."),
          _en("You and your partner may not feel ready at the same time. Talk "
              "about it, and be patient with each other."),
        ],
      ),
      PvReadSection(
        heading: _en('What should we do before trying?'),
        bullets: [
          _en("Take folic acid, 400 micrograms a day, from before you start "
              "trying. Your doctor may advise a higher dose for some women."),
          _en("Have a check-up: blood pressure, sugar, thyroid and "
              "haemoglobin, and any condition you already have."),
          _en("If you've had two or more losses, ask about tests first. 'More "
              "than one loss: when to ask about tests' on this door explains "
              "them."),
          _en("Stop smoking and alcohol, and ask your doctor about any "
              "medicines you take."),
          _en("Note the dates of your periods, so a new pregnancy can be "
              "dated."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm not ready yet?"),
        paragraphs: [
          _en("Use contraception until you are. You can get pregnant before "
              "your first period comes back. Your doctor can help you "
              "choose."),
          _en("If you decide not to try again, that's a real choice, and a "
              "complete one."),
        ],
      ),
      PvReadSection(
        heading: _en('Where can I find more?'),
        paragraphs: [
          _en("When you're ready, the card 'When you're ready to try again' on "
              "this tab moves ParentVeda to the trying-to-conceive side. It "
              "has its own After a loss section, with more on the feelings of "
              "trying again. Nothing you saved here is lost."),
          _en("If you're pregnant again, 'Your care in the next pregnancy' on "
              "this door covers the practical side, and 'Pregnant again after "
              "a loss' in Mind & mood is written for the feelings."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the fear?'),
        paragraphs: [
          _en("Many women say that after a loss, a new pregnancy never feels "
              "carefree. Every twinge and every trip to the bathroom can bring "
              "fear. That's a normal response to what you've been through."),
          _en("It can help to plan for it before you start: who you'll call if "
              "you're scared, when your first scan might be, and who you'll "
              "tell early. 'Pregnant again after a loss' in Mind & mood is "
              "written for those weeks."),
        ],
      ),
      PvReadSection(
        heading: _en('After a later loss or a stillbirth'),
        paragraphs: [
          _en("A next pregnancy after a later loss is usually cared for more "
              "closely, with extra scans and a plan for the birth. Talk to "
              "your doctor before you start trying, so that plan is ready."),
          _en("Some couples want the results of every test first. Others "
              "can't bear to wait. Your doctor can tell you whether anything "
              "in your results needs to be treated or checked before you "
              "try."),
        ],
      ),
      PvReadSection(
        heading: _en('What if it takes a while?'),
        paragraphs: [
          _en("Many couples conceive again within a few months. If you're "
              "under 35 and it hasn't happened after a year of trying, or "
              "you're 35 or over and it's been six months, see your doctor. "
              "See your doctor sooner if your periods haven't come back "
              "regularly."),
        ],
      ),
    ],
    whenToSeeSomeone: _bodyUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Does trying soon after a miscarriage make another more '
            'likely?'),
        answer: _en("Large studies haven't found that trying soon after an "
            "early miscarriage leads to more losses. Your doctor may still "
            "advise waiting for other reasons, so ask."),
      ),
      PvReadFaq(
        question: _en('Should we wait until after the due date?'),
        answer: _en("Only if you'd like to. Some couples find it helps to get "
            "past that date first. There's no medical need to."),
      ),
      PvReadFaq(
        question: _en('Will a new baby replace the one we lost?'),
        answer: _en("No, and it doesn't have to. You can love a new baby and "
            "still hold the one you lost."),
      ),
    ],
    evidence: _en('WHO, Report of a technical consultation on birth spacing '
        '(2005) · NICE guideline NG126, Ectopic pregnancy and miscarriage '
        '(2019, updated 2023) · Kangatharan C et al., Interpregnancy interval '
        'following miscarriage, Human Reproduction Update (2017) · RCOG '
        'Green-top Guideline 55, Late intrauterine fetal death and '
        'stillbirth.'),
    readNext: [
      'preg_loss_read_next_pregnancy_care',
      'preg_loss_read_tests_after',
      'preg_loss_read_periods_after',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Care in the next pregnancy
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_loss_read_next_pregnancy_care',
    hue: _hue,
    kicker: _kAgain,
    title: _en('Your care in the next pregnancy'),
    teaser: _en("Telling your doctor early, the extra checks you may be "
        "offered, and what you can ask for."),
    shortAnswer: _en("If you're pregnant again, tell your doctor about your "
        "loss as early as you can. Depending on what happened, you may be "
        "offered an early scan, extra checks or a specialist. It's fine to ask "
        "for more reassurance when you need it."),
    scaleSetter: _en("Most pregnancies after a loss go well. Care that knows "
        "your history can make the early weeks feel a little less lonely."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("This read is about the practical side of a next pregnancy. For "
            "the feelings, 'Pregnant again after a loss' in Mind & mood is "
            "written for you."),
        _en("You may not want to read this until you need it. It'll be here."),
      ]),
      PvReadSection(
        heading: _en('When should I tell my doctor?'),
        paragraphs: [
          _en("As soon as you have a positive test. Tell them about every "
              "earlier loss: how many weeks, what happened, and any tests or "
              "results."),
          _en("Keep your old reports together in one folder, and take it to "
              "your first visit. If you have photos of them on your phone, "
              "that works too."),
        ],
      ),
      PvReadSection(
        heading: _en('What extra care might I be offered?'),
        bullets: [
          _en("After a miscarriage, many doctors offer an early scan around 6 "
              "to 7 weeks, if you'd like one."),
          _en("After an ectopic, an early scan to check where the pregnancy "
              "has settled."),
          _en("After two or more miscarriages, care that follows any test "
              "results, and sometimes progesterone if you bleed early."),
          _en("After a stillbirth or a later loss, closer checks, more growth "
              "scans, and a plan for when and how your baby will be born. Some "
              "women are cared for in a specialist or high-risk clinic."),
          _en("After ending a pregnancy for a medical reason, sometimes "
              "genetic counselling or early tests, depending on the finding."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I ask for?'),
        bullets: [
          _en("An extra visit or scan when you're anxious, especially around "
              "the weeks of your loss."),
          _en("A number to call if you bleed or feel something is wrong."),
          _en("To have your loss written clearly on your file, so you don't "
              "have to explain it at every visit."),
          _en("To bring someone with you to scans."),
          _en("To see the same doctor where you can."),
        ],
      ),
      PvReadSection(
        heading: _en('Which weeks feel hardest?'),
        paragraphs: [
          _en("The weeks around your earlier loss often feel the hardest. Some "
              "women hold off telling people, buying things or planning until "
              "they're past that point. That's okay."),
          _en("Your doctor can plan a check around that time if it helps. Ask "
              "at your first visit."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I look after myself?'),
        paragraphs: [
          _en("Keep taking folic acid. Go to every visit. Eat well, rest, and "
              "move gently. Unless your doctor has told you otherwise, normal "
              "daily life, work and walking are safe."),
          _en("From around 24 weeks, get to know your baby's pattern of "
              "movements. If the movements slow down or change, call the "
              "labour ward straight away. Don't wait until the next day."),
          _en("If anxiety is taking over, a counsellor who understands "
              "pregnancy after loss can help."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I bleed early on?'),
        paragraphs: [
          _en("Light bleeding or spotting in early pregnancy is common, and "
              "many pregnancies with it carry on well. After a loss, though, "
              "it's frightening, and you don't have to wait and see."),
          _en("Call your doctor the same day for any bleeding. Go to hospital "
              "straight away if it's heavy, or comes with pain, especially on "
              "one side, pain at the tip of your shoulder, or feeling faint."),
          _en("If you've had a miscarriage before and you bleed in early "
              "pregnancy, your doctor may offer progesterone. They'll decide "
              "whether it's right for you."),
        ],
      ),
      PvReadSection(
        heading: _en('When should we tell people?'),
        paragraphs: [
          _en("Whenever you want to. Some couples tell no one until after the "
              "weeks of their loss have passed. Others tell a few people very "
              "early, so there's someone to lean on if the worst happens "
              "again."),
          _en("There's no right answer. It can help to choose one or two "
              "people who know everything, and let the rest wait."),
        ],
      ),
      PvReadSection(
        heading: _en('What about my partner?'),
        paragraphs: [
          _en("Your partner may be anxious too, and may show it by going "
              "quiet or by trying to fix things. Bring him to scans and visits "
              "if you can, so you hear the same news together."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I bring to the first visit?'),
        bullets: [
          _en("Your old reports, scans and discharge papers, or photos of "
              "them."),
          _en("The date of your last period."),
          _en("A list of medicines and supplements you take, including folic "
              "acid."),
          _en("Your questions, written down, including the ones that feel "
              "silly. After a loss, none of them are."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('In a new pregnancy, call or go in straight away if'),
      body: _en("You have bleeding, pain low in your tummy, especially on one "
          "side, pain at the tip of your shoulder, or you feel faint. Later in "
          "pregnancy, call the labour ward straight away if your baby's "
          "movements slow down or change, your waters break, or you have a "
          "severe headache or blurred vision. If you have any thought of "
          "harming yourself, call Tele-MANAS on 14416, or 112 if you're in "
          "danger now."),
    ),
    faqs: [
      PvReadFaq(
        question: _en("Will my doctor think I'm overreacting if I call a "
            "lot?"),
        answer: _en("A good doctor won't. After a loss, calling is reasonable. "
            "If you feel brushed off, it's okay to ask for a second "
            "opinion."),
      ),
      PvReadFaq(
        question: _en('Should I avoid exercise or travel?'),
        answer: _en("Not usually. Unless your doctor has told you otherwise, "
            "normal activity doesn't cause a miscarriage. Ask about anything "
            "specific."),
      ),
      PvReadFaq(
        question: _en('Is it okay not to feel excited?'),
        answer: _en("Yes. Many women feel cautious, or numb, for weeks. "
            "Excitement can come later, or come and go."),
      ),
    ],
    evidence: _en('NICE guideline NG126, Ectopic pregnancy and miscarriage '
        '(2019, updated 2023) · RCOG Green-top Guideline 17, Recurrent '
        'miscarriage (2023) · RCOG Green-top Guideline 55, Late intrauterine '
        'fetal death and stillbirth · RCOG Green-top Guideline 57, Reduced '
        'fetal movements.'),
    readNext: [
      'preg_loss_read_trying_again',
      'preg_loss_read_tests_after',
      'preg_loss_read_someone_to_talk',
    ],
  ),
];
