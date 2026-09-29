// =============================================================================
//  Labour prep › Signs and stages — the birth, written for Indian hospitals
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "Labour prep › Signs and stages", P1: *"Birth is what every
//  pregnant woman thinks about most in the last months"*, and this door had one
//  real read about it. What to Expect has forty labour articles; Flo has four
//  labour collections. These are our own versions, in the pregnancy voice
//  (`docs/PREG-VOICE.md`), never their sentences.
//
//  Spread into `kPregnancyReadsLabour` (pregnancy_reads_labour.dart), which is
//  what the shared index already spreads, so no shared file changed.
//
//  ⚠️ THE CLINICAL LINE THIS FILE HOLDS
//
//  · Urgent signs are never softened: green or brown waters, bleeding, the
//    baby moving less, severe headache, fever, constant pain, a cord felt in
//    the vagina, labour before 37 weeks. Each routes to hospital "now".
//  · Population numbers only. No sentence puts "your" beside a chance word
//    (`test/pregnancy_reads_shape_test.dart` scans for exactly that).
//  · The doctor decides induction, C-section and VBAC. We explain, remind and
//    help her prepare; every such read ends with her doctor's plan.
//  · `reviewed: false`, ParentVeda editorial, until a clinician has read them.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

const double _hue = 344;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('Labour prep');
final LocalizedText _kicker = _en('Signs and stages');

/// The "go now" list every read in this file ends on, in one place so the
/// urgent signs can't drift apart between reads.
final PvCallout _goNow = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Go to hospital now, and call on the way, if'),
  body: _en("Your waters are green, brown or smell bad, you're bleeding more "
      "than a streak of mucus, the baby is moving less than usual, you have a "
      "severe headache, blurred vision or a fever, or you have constant pain "
      "that doesn't come and go. If you feel or see the cord in your vagina, "
      "or you feel faint, call 108 for an ambulance."),
);

final List<PvRead> kPregnancyReadsLabourBirth = [
  // ---------------------------------------------------------------------------
  //  Signs labour is near
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_signs_near',
    hue: _hue,
    kicker: _kicker,
    title: _en('Is labour near? The signs to look for'),
    teaser: _en("What happens in the days before labour, how practice "
        "tightenings differ from the real thing, and when babies usually "
        "come."),
    shortAnswer: _en("In the last weeks your baby may drop lower, you may "
        "lose a plug of mucus, and you may have loose stools or a dull "
        "backache. None of these means labour is hours away. Labour has "
        "started when tightenings come regularly and get stronger, longer "
        "and closer together."),
    scaleSetter: _en("Labour rarely starts all at once. For most women it "
        "creeps up over days, and even doctors can't say exactly when it "
        "will begin. Knowing the signs means you won't rush in too early, "
        "or wait too long."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Your due date is an estimate. Most babies are born somewhere "
            "between 37 and 42 weeks, and only about 4 in every 100 arrive "
            "on the due date itself. First babies often come a little after "
            "it."),
        _en("So instead of watching the calendar, watch your body. The signs "
            "below come in any order, and some women notice none of them "
            "before labour begins."),
      ]),
      PvReadSection(
        heading: _en('What happens in the days or weeks before?'),
        bullets: [
          _en("The baby drops. Your bump sits lower, breathing gets easier, "
              "and you need to pee even more often. In a first pregnancy this "
              "can happen two to four weeks before labour."),
          _en("The mucus plug comes away. You may see a blob of thick, clear "
              "or pinkish jelly, sometimes streaked with a little blood. This "
              "is called a show. Labour may follow in hours, or in a week "
              "or two."),
          _en("More practice tightenings, especially in the evening."),
          _en("Loose stools, a dull low backache, or period-like cramps that "
              "come and go."),
          _en("A burst of energy to clean and sort the house. Use it gently, "
              "and rest too."),
        ],
      ),
      PvReadSection(
        heading: _en('Is it practice tightenings or real labour?'),
        paragraphs: [
          _en("Practice tightenings (Braxton Hicks) are your womb warming up. "
              "Real contractions are the ones that open the neck of the womb "
              "(the cervix). Here's how they usually differ."),
        ],
        bullets: [
          _en("Practice tightenings come at odd times. Real contractions "
              "settle into a pattern and get closer together."),
          _en("Practice tightenings stay mild or fade. Real contractions get "
              "stronger and last longer, 45 seconds to a minute or more."),
          _en("Practice tightenings often ease if you rest, walk or drink "
              "water. Real contractions keep coming whatever you do."),
          _en("Practice tightenings are usually felt at the front. Real "
              "contractions often start in the back and wrap round to the "
              "front."),
        ],
        tip: PvReadTip(
          title: _en('Not sure? Time them'),
          body: _en("Use the contraction timer on this door for an hour. If "
              "they're getting regular, stronger and closer, it's labour. If "
              "they're all over the place, rest and see."),
        ),
      ),
      PvReadSection(
        heading: _en('What are the signs labour has started?'),
        bullets: [
          _en("Contractions that come regularly and build: stronger, longer "
              "and closer together over an hour or two."),
          _en("Your waters breaking, as a gush or a slow trickle you can't "
              "stop. Read 'When your waters break' on this door for what to "
              "do."),
          _en("A show together with regular contractions."),
          _en("A strong pressure low down, or an urge to push. That means go "
              "in now."),
        ],
      ),
      PvReadSection(
        heading: _en('When do babies usually come?'),
        paragraphs: [
          _en("Doctors call 37 to 42 weeks 'term'. 39 and 40 weeks are the most "
              "common weeks to give birth. Nobody can tell you your own date, "
              "not even from an internal check. A cervix that's a little open "
              "can stay that way for weeks, and a closed one can open in a "
              "day."),
          _en("If you're still pregnant at 40 weeks, your doctor will talk to "
              "you about what happens next. There's a read on this door, "
              "'Past your due date', for that."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I do in early labour at home?'),
        paragraphs: [
          _en("If contractions start and you're well, with no urgent signs, "
              "early labour is often best spent at home. Eat something light, "
              "like khichdi, toast or fruit, and sip water. Rest between "
              "contractions, even if you can't sleep. A warm shower, a walk "
              "round the house, and a hot water bottle on your lower back all "
              "help."),
          _en("Start the contraction timer when they feel regular. Tell your "
              "companion, and keep your folder and bag by the door. Call your "
              "doctor or the labour ward whenever you want advice. You don't "
              "have to be sure it's labour to call."),
          _en("If it turns out to be a false alarm, that's common, especially "
              "with a first baby. It isn't wasted. Your body is getting "
              "ready."),
        ],
      ),
      PvReadSection(
        heading: _en('Is it different with a second baby?'),
        paragraphs: [
          _en("Often, yes. The signs are the same, but labour tends to move "
              "faster, and the baby may not drop until labour starts. If "
              "this isn't your first baby, take regular contractions "
              "seriously sooner, and plan to leave for hospital earlier than "
              "you did last time."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en('I lost my mucus plug. Should I go in?'),
        answer: _en("Not if it's a small amount with a streak of blood and "
            "you feel well. Call your doctor if you're before 37 weeks, if "
            "there's fresh bleeding like a period, or if you're unsure."),
      ),
      PvReadFaq(
        question: _en('Can a scan or check tell me when labour will start?'),
        answer: _en("No. A check can tell your doctor how things look today, "
            "but it can't give a date."),
      ),
      PvReadFaq(
        question: _en("I've had tightenings on and off for days. Is that "
            "normal?"),
        answer: _en("Yes, this is common, especially in a first pregnancy. "
            "Rest, eat and drink. If they become regular and strong, or you're "
            "worn out, call your doctor."),
      ),
    ],
    evidence: _en('NICE guideline NG235, Intrapartum care (2023) · WHO '
        'recommendations: intrapartum care for a positive childbirth '
        'experience (2018) · ACOG Committee Opinion 579, Definition of term '
        'pregnancy · FOGSI patient guidance on labour.'),
    readNext: [
      'preg_labour_read_when_to_go',
      'preg_labour_read_waters',
      'preg_labour_read_preterm',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Waters breaking
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_waters',
    hue: _hue,
    kicker: _kicker,
    title: _en('When your waters break'),
    teaser: _en("What it feels like, what the colour means, and what to do "
        "next, whether or not contractions have started."),
    shortAnswer: _en("Your waters may break with a gush or a trickle. Put on "
        "a pad, note the time and the colour, and call your doctor or "
        "hospital. If the fluid is green, brown or bloody, or you feel the "
        "cord, go in now."),
    scaleSetter: _en("Only some women's waters break before labour starts. "
        "For many, it happens during labour, sometimes not until near the "
        "end. It rarely looks like the films, and it's rarely a flood in a "
        "public place."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Your baby grows inside a bag of fluid (the amniotic sac). When "
            "labour is near or under way, the bag breaks and the fluid comes "
            "out through the vagina. This is called your waters breaking."),
        _en("It may be a sudden gush, or a slow trickle that keeps coming. "
            "Late in pregnancy it's easy to mix it up with a little leaked "
            "urine or heavier discharge, and that's fine. If you're not "
            "sure, it's always worth a call."),
      ]),
      PvReadSection(
        heading: _en('How can I tell if it is my waters?'),
        bullets: [
          _en("Waters usually keep leaking, especially when you stand up or "
              "move, and you can't stop them."),
          _en("They're usually clear or pale pink, and smell faintly sweet "
              "or of nothing."),
          _en("Urine usually stops, and smells like urine."),
          _en("Discharge is thicker, and doesn't soak a pad."),
        ],
        tip: PvReadTip(
          title: _en('The pad check'),
          body: _en("Put on a sanitary pad, not a tampon, and lie down for "
              "half an hour. Then stand up. If the pad gets wet again, it's "
              "likely your waters. Take the pad with you if you go in."),
        ),
      ),
      PvReadSection(
        heading: _en('What does the colour mean?'),
        bullets: [
          _en("Clear, pale straw or slightly pink: usual. Call your doctor or "
              "hospital for advice."),
          _en("Green or brown: the baby may have passed its first stool "
              "(meconium). Go to hospital now."),
          _en("Bright red, or more than a streak of blood: go to hospital "
              "now."),
          _en("Smelly or cloudy, or you have a fever: go to hospital now."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I do next?'),
        paragraphs: [
          _en("Note the time, the colour and roughly how much. Put on a pad. "
              "Then call your doctor or the hospital. They'll tell you "
              "whether to come in straight away or wait a little at home. "
              "Most will want to see you soon, to check you and the baby."),
          _en("Don't have a bath, use a tampon or have sex once your waters "
              "have broken. The bag protects the baby from infection, and "
              "once it's open that protection is gone."),
          _en("Keep feeling for the baby's movements. If they're less than "
              "usual, go in now."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en('If you feel the cord'),
          body: _en("Very rarely, the cord slips down after the waters break. "
              "If you feel or see something in your vagina, call 108 and go "
              "straight to hospital. Get onto your knees with your bottom up "
              "and your head down while you wait."),
        ),
      ),
      PvReadSection(
        heading: _en('What if contractions don\'t start?'),
        paragraphs: [
          _en("Many women go into labour on their own within a day of their "
              "waters breaking at full term. The doctor may suggest waiting "
              "a while with checks, or starting labour with medicine "
              "(induction) to lower the chance of infection. Both are "
              "normal plans, and your doctor will say which suits you."),
          _en("If your waters break before 37 weeks, go to hospital straight "
              "away, even without contractions. The team will look after you "
              "and the baby, and may give medicine to help the baby's "
              "lungs."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens when I get to hospital?'),
        paragraphs: [
          _en("The nurse or doctor will ask when it happened and what colour "
              "the fluid was, and look at your pad. They'll check your "
              "temperature, pulse and blood pressure, and listen to the "
              "baby's heartbeat, often with the monitoring belt for a while."),
          _en("They may look gently with a speculum, the same instrument used "
              "for a smear test, to see whether fluid is coming from the "
              "cervix. Sometimes a quick strip or swab test is used. If "
              "your waters have broken, internal checks are kept to a "
              "minimum to lower infection."),
          _en("Then they'll explain the plan: whether to stay in, whether to "
              "wait for labour or start it, and when the next checks will be. "
              "Ask anything you're unsure about."),
        ],
      ),
      PvReadSection(
        heading: _en('Can the doctor break my waters?'),
        paragraphs: [
          _en("Yes. If your waters haven't broken by themselves, the doctor "
              "may break them during labour, or as part of starting labour. "
              "It's done with a small hook during an internal check. It feels "
              "like an internal check and doesn't hurt the baby. Contractions "
              "often get stronger soon after."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en('Will my waters break before labour?'),
        answer: _en("For most women they don't. They break during labour, "
            "or the doctor breaks them. So don't wait for your waters before "
            "timing contractions."),
      ),
      PvReadFaq(
        question: _en('Does it hurt when the waters break?'),
        answer: _en("No. You may feel a pop or just wetness. Contractions "
            "often get stronger afterwards."),
      ),
      PvReadFaq(
        question: _en('Will the baby be dry?'),
        answer: _en("No. Your body keeps making the fluid, so the baby isn't "
            "left dry while you wait."),
      ),
    ],
    evidence: _en('NICE guideline NG207, Inducing labour (2021), on prelabour '
        'rupture of membranes · NICE NG235, Intrapartum care (2023) · RCOG '
        'patient information, When your waters break early · WHO '
        'recommendations for induction of labour (2011).'),
    readNext: [
      'preg_labour_read_when_to_go',
      'preg_labour_read_induction',
      'preg_labour_read_signs_near',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  When to go to hospital
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_when_to_go',
    hue: _hue,
    kicker: _kicker,
    title: _en('When to go to hospital, and what to carry in your hand'),
    teaser: _en("What the contraction timings mean, when to call first and "
        "when to go straight in, and the file to keep by the door."),
    shortAnswer: _en("For a first baby, go in when contractions come every 5 "
        "minutes, last about a minute, and have done so for an hour. Leave "
        "sooner if the hospital is far, traffic is bad, or this isn't your "
        "first baby. Some signs mean go now, whatever the contractions are "
        "doing."),
    scaleSetter: _en("In most cases labour isn't an emergency, and early "
        "labour is often easier at home. But nobody is ever wrong to call. "
        "When in doubt, call your doctor or labour ward. That's what they're "
        "there for."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Early labour can last many hours, especially with a first baby. "
            "At home you can eat, rest, walk and shower, and that often "
            "helps labour move. Going in very early can mean being sent "
            "home, or lying in a ward bed for hours."),
        _en("But the rule that matters most is this one: your doctor's advice "
            "comes first. If they've told you to come in early, because of "
            "a condition, a previous C-section or anything else, follow "
            "what they told you."),
      ]),
      PvReadSection(
        heading: _en('What do the timings on the timer mean?'),
        paragraphs: [
          _en("The contraction timer counts two things. How long each "
              "contraction lasts, from start to end. And how often they come, "
              "from the start of one to the start of the next."),
        ],
        bullets: [
          _en("Every 10 to 20 minutes, lasting 30 to 45 seconds: early "
              "labour. Stay home, rest, eat and drink."),
          _en("Every 5 minutes, lasting about a minute, for an hour (the "
              "5-1-1 pattern): time to go in for a first baby."),
          _en("Every 2 to 3 minutes, strong and long: go in now if you "
              "haven't already."),
          _en("No pattern at all: probably not labour yet. Rest, and time "
              "again later."),
        ],
        tip: PvReadTip(
          title: _en('Follow what your doctor told you'),
          body: _en("These are general patterns. Your own doctor may give you "
              "different numbers. Theirs are the ones to use."),
        ),
      ),
      PvReadSection(
        heading: _en('When should I leave sooner?'),
        bullets: [
          _en("The hospital is more than half an hour away, or it's rush "
              "hour, monsoon or night."),
          _en("This isn't your first baby. Second labours are often much "
              "faster."),
          _en("You've had a C-section before, or your doctor asked you to "
              "come in early."),
          _en("You're finding it hard to cope at home. That's reason enough."),
        ],
      ),
      PvReadSection(
        heading: _en('When should I call first, and when go now?'),
        paragraphs: [
          _en("Call first if your waters break and they're clear, if you're "
              "not sure it's labour, or if you just want advice. Keep your "
              "doctor's and the labour ward's numbers saved and written on "
              "paper."),
          _en("Go now, and call on the way, for any of the urgent signs in "
              "the box at the end of this read. In an emergency, dial 108 for "
              "an ambulance. In many states, 102 is the free ambulance for "
              "pregnant women."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I carry in my hand?'),
        paragraphs: [
          _en("Your hospital bag can come behind you. These few things should "
              "go in the car with you, in one folder."),
        ],
        bullets: [
          _en("Your pregnancy file: your antenatal card and the doctor's "
              "notes."),
          _en("Your latest scan and blood reports, including your blood "
              "group."),
          _en("Photo ID (Aadhaar or another), and insurance or TPA card if "
              "you have one."),
          _en("Hospital registration or admission papers."),
          _en("Your phone, charger, and some cash."),
          _en("Your birth plan, if you've written one."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Do it this week'),
          body: _en("Put the folder by the door from about 36 weeks. Save the "
              "labour ward number, and plan the route at night and in "
              "traffic, with a backup car or cab."),
        ),
      ),
      PvReadSection(
        heading: _en('How do we plan the trip?'),
        paragraphs: [
          _en("Plan the route now, at the times you're most likely to travel: "
              "rush hour, late at night and in heavy rain. Note how long each "
              "takes. If it's more than half an hour, plan to leave earlier in "
              "labour."),
        ],
        bullets: [
          _en("Keep a car filled with fuel from 36 weeks, or save two cab "
              "apps and a local driver's number as backup."),
          _en("Save 108, the labour ward and your doctor on your phone and "
              "your companion's, and write them on paper in your folder."),
          _en("Arrange who looks after older children or elderly parents at "
              "short notice, day or night."),
          _en("Know which gate and which desk to go to after hours. Many "
              "hospitals use the emergency entrance at night."),
        ],
      ),
      PvReadSection(
        heading: _en('What if the baby is coming fast?'),
        paragraphs: [
          _en("Very rarely, a baby comes before you can reach hospital. If you "
              "feel a strong urge to push, or can see the head, call 108 and "
              "stay where you are. The call handler will guide you."),
        ],
        bullets: [
          _en("Lie on your side or sit propped up, somewhere clean and warm."),
          _en("Let the baby come with the contractions. Don't pull on the "
              "baby or the cord."),
          _en("Put the baby straight onto your bare chest, dry them, and "
              "cover you both with a cloth or shawl."),
          _en("Don't cut the cord. Leave the placenta for the ambulance team "
              "or the hospital."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en('What if they send me home?'),
        answer: _en("That's common in early labour and it doesn't mean you "
            "did anything wrong. Go home, rest and eat, and go back when "
            "things change or you're worried."),
      ),
      PvReadFaq(
        question: _en('Should I eat before I go?'),
        answer: _en("Something light is usually fine in early labour, like "
            "toast, khichdi or fruit. Ask your doctor if they've said "
            "otherwise."),
      ),
      PvReadFaq(
        question: _en('Can I drive myself?'),
        answer: _en("Please don't. Contractions can come suddenly. Arrange "
            "someone to drive, or book a cab, or call an ambulance."),
      ),
    ],
    evidence: _en('NICE guideline NG235, Intrapartum care (2023) · WHO '
        'recommendations: intrapartum care for a positive childbirth '
        'experience (2018) · Ministry of Health and Family Welfare, Janani '
        'Shishu Suraksha Karyakram and 102 / 108 ambulance services · FOGSI '
        'patient guidance.'),
    readNext: [
      'preg_labour_read_stages',
      'preg_labour_read_waters',
      'preg_week_read_hospital_bag',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Early labour, before 37 weeks
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_preterm',
    hue: _hue,
    kicker: _kicker,
    title: _en('Signs of early labour, before 37 weeks'),
    teaser: _en("The signs to know, why going in straight away matters, and "
        "what care for an early baby looks like in India."),
    shortAnswer: _en("Before 37 weeks, regular tightenings, period-like "
        "cramps, a low backache that comes and goes, pressure in your "
        "pelvis, or a change in discharge can be early labour. Go to hospital "
        "straight away. Treatment given early helps your baby most."),
    scaleSetter: _en("Most women who go in with early signs aren't in labour, "
        "and go home reassured. That's a good outcome, not a wasted trip. "
        "Going in fast when it is labour gives the team time to help."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("A baby born before 37 weeks is called preterm. About one baby "
            "in eight in India is born early, many of them only a little "
            "early, at 34 to 36 weeks."),
        _en("Early labour can be hard to spot, because the signs look like "
            "ordinary pregnancy aches. The difference is that they keep "
            "coming, or they follow a pattern. If you're not sure, go and "
            "get checked."),
      ]),
      PvReadSection(
        heading: _en('What are the signs?'),
        bullets: [
          _en("Tightenings or contractions that come regularly, four or more "
              "in an hour, even if they don't hurt."),
          _en("Period-like cramps, low in your tummy, that come and go."),
          _en("A dull low backache that comes in waves."),
          _en("Pressure in your pelvis, as if the baby is pushing down."),
          _en("A change in discharge: watery, mucus-like or with blood."),
          _en("Fluid leaking from the vagina."),
        ],
      ),
      PvReadSection(
        heading: _en('What will happen at the hospital?'),
        paragraphs: [
          _en("The team will check your baby's heartbeat and your "
              "contractions, and may examine your cervix or do a swab or "
              "scan. If labour is starting, they may give you steroid "
              "injections that help the baby's lungs, and other medicines to "
              "protect the baby or slow things down for a while."),
          _en("If your hospital doesn't have a newborn intensive care unit "
              "(NICU), they may move you to one that does before the birth. "
              "It's safer to travel with the baby still inside you."),
        ],
      ),
      PvReadSection(
        heading: _en('How early is safe?'),
        paragraphs: [
          _en("Every extra week inside helps. In general, babies born at 37 "
              "weeks or later are full term. Babies born at 34 to 36 weeks "
              "usually do well, though some need help with feeding, warmth "
              "or jaundice for a few days."),
          _en("Babies born earlier than that often need more time in a NICU, "
              "and the earlier the birth, the more help they need. Care for "
              "small babies in India has improved a lot. Government hospitals "
              "have special newborn care units (SNCUs) across districts. Your "
              "doctor and the baby doctor can tell you what to expect for "
              "your own baby."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps if my baby comes early?'),
        paragraphs: [
          _en("Holding your baby skin to skin, called kangaroo mother care, "
              "helps small babies stay warm, feed and grow. Indian hospitals "
              "encourage it, and fathers and grandmothers can do it too."),
          _en("Your breast milk helps an early baby more than anything else "
              "you can give. If the baby can't feed yet, the nurses will "
              "show you how to express milk by hand, from the first day."),
        ],
      ),
      PvReadSection(
        heading: _en('Who is more likely to have an early labour?'),
        paragraphs: [
          _en("Early labour can happen to anyone, often with no clear reason. "
              "It's more common in women who have had an early baby before, "
              "are carrying twins or more, have a short cervix on a scan, "
              "have high blood pressure, or have an infection such as a urine "
              "infection. A gap of less than about 18 months since the last "
              "birth, and smoking or chewing tobacco, also make it more "
              "common."),
          _en("If any of these apply to you, your doctor may see you more "
              "often, check your cervix on a scan, or give treatment such as "
              "progesterone for some women. Follow the plan they make for you."),
        ],
        bullets: [
          _en("Go to all your check-ups, and tell your doctor if you had an "
              "early baby before."),
          _en("Get burning or pain when you pee checked the same week, "
              "because urine infections are treated easily."),
          _en("Stay away from tobacco in any form, and from smoke at home."),
          _en("Know the signs above, and where to go, day or night."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my baby needs the NICU?'),
        paragraphs: [
          _en("A newborn intensive care unit (NICU), or an SNCU in a government "
              "hospital, looks after babies who are early, small or unwell. "
              "It can look frightening, with wires and machines. Most of them "
              "are there to watch your baby's breathing, heartbeat and "
              "warmth."),
          _en("Ask the nurses what each thing does and when you can visit, "
              "touch and hold your baby. Parents are part of the care. Your "
              "milk, your voice and your touch all help, and the team will "
              "show you how."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Before 37 weeks, go to hospital straight away if'),
      body: _en("You have regular tightenings or cramps, fluid leaking, "
          "bleeding, pressure low down, or the baby is moving less. Don't "
          "wait to see if it settles. Call your doctor on the way, or 108 if "
          "you need an ambulance."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Did I cause this?'),
        answer: _en("No. Early labour often happens without any clear reason, "
            "and nothing you ate, lifted or felt caused it."),
      ),
      PvReadFaq(
        question: _en('Can I stop early labour with bed rest at home?'),
        answer: _en("Bed rest at home isn't a treatment for early labour. If "
            "you have the signs, go to hospital."),
      ),
      PvReadFaq(
        question: _en('I was sent home. What now?'),
        answer: _en("That's good news. Go back straight away if the signs "
            "come back, even the same day."),
      ),
    ],
    evidence: _en('WHO recommendations on interventions to improve preterm '
        'birth outcomes (2015, updated 2022) · WHO Born Too Soon report '
        '(2023) · Ministry of Health and Family Welfare, India Newborn Action '
        'Plan and SNCU guidance · NICE guideline NG25, Preterm labour and '
        'birth.'),
    readNext: [
      'preg_labour_read_signs_near',
      'preg_labour_read_when_to_go',
      'preg_cond_read_less_movement',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  The three stages of labour
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_stages',
    hue: _hue,
    kicker: _kicker,
    title: _en('The three stages of labour, in an Indian hospital'),
    teaser: _en("From admission to the placenta: what each stage is, what "
        "'dilated' means, and the checks and drips you're likely to meet."),
    shortAnswer: _en("In the first stage, contractions open your cervix to "
        "10 centimetres. In the second, you push your baby out. In the "
        "third, the placenta comes out. The first stage is by far the "
        "longest, and much of its early part can be spent at home."),
    scaleSetter: _en("Labour has a shape: slow at first, building over hours, "
        "then a hard stretch near the end, and then your baby. A first labour "
        "often takes 12 to 18 hours from the first regular contractions. "
        "Later labours are usually shorter."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("When you arrive, you'll usually be asked for your file, and a "
            "nurse or doctor will check your blood pressure, pulse and "
            "temperature. They'll listen to the baby's heartbeat, feel your "
            "tummy, and often do an internal check."),
        _en("Then you're shown to the labour room, or to a ward if it's "
            "still early. How many people can stay with you depends on the "
            "hospital. Ask when you're admitted."),
      ]),
      PvReadSection(
        heading: _en('What happens in the first stage?'),
        paragraphs: [
          _en("Contractions slowly thin and open your cervix, from closed to "
              "10 centimetres, which is fully open. This is what "
              "'dilated' means. When the doctor says 'you're 3 centimetres', "
              "it's how open your cervix is."),
          _en("The early part (latent labour) goes up to about 4 to 5 "
              "centimetres. It can take many hours, with contractions that "
              "come and go. Then active labour begins. Contractions come every "
              "3 to 4 minutes, last about a minute, and the cervix opens more "
              "steadily."),
          _en("The last part, from about 8 to 10 centimetres, is called "
              "transition. It's usually the hardest hour. You may shake, feel "
              "sick, or feel you can't go on. That feeling usually means "
              "you're nearly there."),
        ],
      ),
      PvReadSection(
        heading: _en('What checks and drips might I have?'),
        bullets: [
          _en("Internal checks. The doctor or nurse feels how open your "
              "cervix is, usually every few hours in active labour. Only an "
              "internal check can tell how dilated you are. You can ask why "
              "and when the next one will be."),
          _en("The monitoring belt (CTG). Two straps on your tummy record the "
              "baby's heartbeat and your contractions. Some women have it on "
              "and off; others all the time, for example with an epidural or "
              "a drip."),
          _en("A drip (IV) in your hand, for fluids or medicines. Many "
              "Indian hospitals put one in for every labour, so it's ready if "
              "needed."),
          _en("Breaking the waters (amniotomy). If your waters haven't "
              "broken, the doctor may break them with a small hook. It "
              "doesn't hurt the baby and feels like an internal check."),
          _en("The oxytocin drip. If labour slows, a hormone drip can "
              "make contractions stronger. This is called augmentation. Ask "
              "why it's being started, and how you'll be monitored."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps labour move?'),
        paragraphs: [
          _en("Labour works best when you feel safe and calm. Fear, bright "
              "lights and lots of people coming in and out can slow it down. "
              "Low light, quiet, one trusted person, and moving freely all "
              "help your body's own labour hormones do their work."),
          _en("Keep changing position, sip water, and empty your bladder "
              "every hour or two. There's more on positions and pain relief "
              "in the reads on the Understand the birth tab."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens in the second and third stages?'),
        paragraphs: [
          _en("The second stage starts when your cervix is fully open and "
              "ends with the birth. You'll feel a strong urge to push. For a "
              "first baby it often takes one to two hours, sometimes longer "
              "with an epidural."),
          _en("The third stage is the placenta. After the baby is born, a "
              "few mild contractions push it out, usually within half an "
              "hour. You'll usually get an injection to help with this and "
              "to reduce bleeding. There's more on both stages in 'Pushing, "
              "and the placenta'."),
        ],
      ),
      PvReadSection(
        heading: _en('Who will be in the labour room?'),
        paragraphs: [
          _en("In many Indian hospitals, your own doctor comes in for the "
              "birth, and the nurses and junior doctors look after you through "
              "the hours before. In teaching hospitals, students may watch or "
              "help, and you can ask for fewer people if you'd like."),
          _en("It's fine to ask people their names and what they're there to "
              "do. Ask for the curtain to be drawn and for a sheet to cover "
              "you during checks. Your privacy matters in labour, and a good "
              "team will respect it."),
        ],
      ),
      PvReadSection(
        heading: _en('How will I know how things are going?'),
        paragraphs: [
          _en("Ask. The team can tell you how open your cervix is, how the "
              "baby's heartbeat looks, and what they expect next. If you'd "
              "rather not hear the numbers, say so, and ask them to tell your "
              "companion instead."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en('Do internal checks hurt?'),
        answer: _en("They can be uncomfortable, especially during a "
            "contraction. Ask for it to be done between contractions, and "
            "breathe out slowly."),
      ),
      PvReadFaq(
        question: _en("I've been 3 centimetres for hours. Is something wrong?"),
        answer: _en("Early labour is often slow and stop-start. It doesn't "
            "mean anything is wrong. Your doctor will watch how things change "
            "over time."),
      ),
      PvReadFaq(
        question: _en('Can I say no to the monitoring belt?'),
        answer: _en("You can ask whether it needs to be on all the time, or "
            "whether listening now and then is enough for you. The doctor "
            "will explain what's safest for your labour."),
      ),
    ],
    evidence: _en('WHO recommendations: intrapartum care for a positive '
        'childbirth experience (2018) · WHO Labour Care Guide (2020) · NICE '
        'guideline NG235, Intrapartum care (2023) · FOGSI good clinical '
        'practice recommendations on labour management.'),
    readNext: [
      'preg_labour_read_pushing_placenta',
      'preg_week_read_labour_prep',
      'preg_labour_read_pain_relief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Pushing and the placenta
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_pushing_placenta',
    hue: _hue,
    kicker: _kicker,
    title: _en('Pushing, and the placenta'),
    teaser: _en("What the pushing stage feels like, positions that help, "
        "the moment of birth, and the stage most women don't know about."),
    shortAnswer: _en("Once your cervix is fully open, you'll feel a strong "
        "urge to push, and the team will guide you. The baby's head "
        "stretches you for a minute or two, then the baby is born. Then a "
        "few mild contractions bring out the placenta, usually within half "
        "an hour."),
    scaleSetter: _en("Many women find pushing easier than the stage before it, "
        "because there's something to do. It's hard work, and it comes in "
        "waves with rests in between, just like before."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The second stage of labour begins when your cervix is fully open "
            "at 10 centimetres. The contractions change. Instead of just "
            "pain, you feel a deep, strong urge to bear down, like needing "
            "to open your bowels."),
        _en("With an epidural you may not feel the urge as strongly. The "
            "team will tell you when to push, and some hospitals wait a "
            "little for the baby to move down on its own first."),
      ]),
      PvReadSection(
        heading: _en('How do I push?'),
        paragraphs: [
          _en("Push with the contraction, not between them. When one builds, "
              "take a breath, tuck your chin, and push down into your bottom "
              "for as long as feels right. Most women push two or three times "
              "in each contraction."),
          _en("Rest completely between contractions. Sip water. Let your "
              "face and shoulders go soft. Your companion can wipe your face "
              "and tell you how well you're doing."),
          _en("Pushing in a way that follows your own body is usually as good "
              "as long, held pushes on command. If you're not sure, the nurse "
              "or doctor will guide you."),
        ],
      ),
      PvReadSection(
        heading: _en('Which positions help?'),
        bullets: [
          _en("Semi-sitting, propped up on the bed, pulling your knees back."),
          _en("Lying on your side with your top leg held up."),
          _en("Squatting, or kneeling upright, holding the bed or your "
              "partner."),
          _en("On all fours, which can ease back pain."),
        ],
        tip: PvReadTip(
          title: _en('Ask on your hospital visit'),
          body: _en("Many Indian hospitals still use lying on the back by "
              "habit. Ask which positions they allow for pushing, and put "
              "what you'd like in your birth plan."),
        ),
      ),
      PvReadSection(
        heading: _en('What happens at the moment of birth?'),
        paragraphs: [
          _en("As the head comes down, it stays visible between contractions. "
              "This is called crowning. You'll feel a strong stretching or "
              "burning. The doctor or nurse will ask you to stop pushing and "
              "to pant or breathe gently, so the head is born slowly. This "
              "helps protect you from tearing."),
          _en("Once the head is born, the shoulders and body usually follow "
              "with the next contraction. Your baby may be placed straight "
              "onto your tummy or chest. The cord is clamped after a minute "
              "or so and cut."),
          _en("Sometimes help is needed to get the baby out, with a vacuum "
              "cup (ventouse) or forceps. The doctor will explain why, and "
              "you'll have pain relief first."),
        ],
      ),
      PvReadSection(
        heading: _en('What is the third stage?'),
        paragraphs: [
          _en("The placenta has fed your baby for months. After the birth, "
              "your womb keeps contracting to push it out. You'll usually get "
              "an injection in your thigh as the baby is born, to speed this "
              "up and reduce bleeding. It's standard and safe."),
          _en("You may be asked to give one small push. The placenta usually "
              "comes out within half an hour, and the doctor checks that it's "
              "complete. If it doesn't come out, or part of it stays behind, "
              "the doctor removes it, with pain relief, in the labour room or "
              "theatre."),
          _en("Then the doctor checks for any tears and stitches them. The "
              "read 'Will I tear?' on this door explains what that involves."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm too tired to push?"),
        paragraphs: [
          _en("Many women feel they have nothing left by this point, "
              "especially after a long first stage. Tell the team. They can "
              "help you change position, give you sips of water or glucose, "
              "and let you rest through a contraction or two."),
          _en("With an epidural, waiting a little before pushing can help the "
              "baby move lower first, so the pushes do more. If the baby "
              "still isn't coming, or the baby's heartbeat shows they need to "
              "be born sooner, the doctor may suggest help with a vacuum or "
              "forceps, or rarely a C-section. They'll explain why before "
              "they start."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens to the cord?'),
        paragraphs: [
          _en("If you and the baby are well, the cord is clamped after at "
              "least a minute. This lets more blood pass from the placenta to "
              "your baby, which gives the baby more iron. Then it's cut. Your "
              "partner may be offered the scissors, if the hospital allows."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('After the birth, tell the nurse at once if'),
      body: _en("You're soaking pads fast or passing large clots, you feel "
          "faint, dizzy or cold and clammy, or you have a severe headache or "
          "blurred vision. Heavy bleeding after birth needs help straight "
          "away."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('What if I pass stool while pushing?'),
        answer: _en("It's very common, and the nurses see it all the time. "
            "They clean it away quickly. It usually means you're pushing in "
            "the right place."),
      ),
      PvReadFaq(
        question: _en('How long can pushing go on?'),
        answer: _en("For a first baby, often one to two hours. The team keeps "
            "checking you and the baby, and will explain if they think help "
            "is needed."),
      ),
      PvReadFaq(
        question: _en('Can we see the placenta?'),
        answer: _en("Usually, if you ask. Some families have traditions about "
            "it. Tell the team beforehand."),
      ),
    ],
    evidence: _en('WHO recommendations: intrapartum care for a positive '
        'childbirth experience (2018), on the second stage and pushing '
        'positions · WHO recommendations on uterotonics for the prevention '
        'of postpartum haemorrhage (2018) · WHO guideline on delayed umbilical '
        'cord clamping (2014) · NICE NG235, Intrapartum care (2023).'),
    readNext: [
      'preg_labour_read_tears',
      'preg_labour_read_first_hour',
      'preg_labour_read_stages',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Induction
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_induction',
    hue: _hue,
    kicker: _kicker,
    title: _en('Induction: why, how and what it feels like'),
    teaser: _en("Why your doctor might start labour, the methods used in "
        "Indian hospitals, and what to ask before you agree."),
    shortAnswer: _en("Induction means starting labour with medicine or a "
        "small procedure, instead of waiting for it to start on its own. "
        "It's common, often offered around 41 weeks or for a medical reason. "
        "It can take a day or more, so pack as if you'll stay."),
    scaleSetter: _en("Induction is one of the most common things that happens "
        "near the due date in India. When your doctor says 'we will induce', "
        "it's a plan, not a warning. It usually means they think the baby is "
        "better out than in, soon."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In a spontaneous labour, your body starts things by itself. In "
            "an induced labour, your doctor starts them. Once labour is "
            "going, it follows the same stages."),
        _en("Your doctor will explain why they're suggesting it and how "
            "they'll do it. You can ask questions, and then follow the plan "
            "you agree together."),
      ]),
      PvReadSection(
        heading: _en('Why might my doctor suggest it?'),
        bullets: [
          _en("You've reached about 41 weeks."),
          _en("Your waters have broken but labour hasn't started."),
          _en("High blood pressure or pre-eclampsia."),
          _en("Diabetes, in pregnancy or before."),
          _en("The baby isn't growing as expected, or there's less fluid "
              "around the baby."),
          _en("Other health reasons, for you or the baby."),
        ],
      ),
      PvReadSection(
        heading: _en('How is labour started?'),
        paragraphs: [
          _en("Doctors often use more than one step, in this rough order. "
              "Which ones you have depends on how ready your cervix is."),
        ],
        bullets: [
          _en("A membrane sweep. During an internal check the doctor sweeps "
              "a finger round the cervix to help release labour hormones. It "
              "may cause some cramps and spotting. It can be done at a "
              "check-up."),
          _en("A gel or tablet (prostaglandin). Placed in the vagina or "
              "taken by mouth, to soften and open the cervix. It may be "
              "repeated every few hours."),
          _en("A balloon (Foley catheter). A small balloon is placed in the "
              "cervix and filled with water, to open it gently."),
          _en("Breaking the waters (amniotomy), once the cervix has opened a "
              "little."),
          _en("The oxytocin drip. A hormone drip into your hand to bring on "
              "or strengthen contractions. It's turned up slowly, and the "
              "baby is watched on the monitoring belt."),
        ],
      ),
      PvReadSection(
        heading: _en('What does it feel like?'),
        paragraphs: [
          _en("The early steps can take a long time, often a day, sometimes "
              "longer, before labour really starts. Bring things to pass the "
              "time, and eat when you're allowed."),
          _en("Once contractions start, especially on the drip, they can "
              "build faster and feel stronger than in a labour that starts "
              "by itself. It's worth thinking about pain relief early, and "
              "asking about an epidural before you need one."),
          _en("Sometimes induction doesn't lead to labour, or labour doesn't "
              "progress. Then your doctor may suggest trying again later, or "
              "a C-section. They'll talk it through with you."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask before I agree?'),
        bullets: [
          _en("Why do you suggest induction for me, and why now?"),
          _en("What happens if we wait a few days, with checks?"),
          _en("Which method will you start with, and what comes next?"),
          _en("How long might it take, and can I walk around?"),
          _en("Will the baby be monitored all the time?"),
          _en("Is an epidural available if I want one?"),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('The plan to follow is your doctor\'s'),
          body: _en("Asking helps you understand and agree. Once you've "
              "agreed, follow the plan, and call if anything changes."),
        ),
      ),
      PvReadSection(
        heading: _en('How can I prepare for an induction?'),
        paragraphs: [
          _en("Induction is usually booked for a date and time, which means "
              "you can prepare. Ask what time to arrive, whether to eat first, "
              "and whether your companion can stay overnight."),
        ],
        bullets: [
          _en("Pack as if you'll stay two or three days, including phone "
              "chargers, snacks and something to pass the time."),
          _en("Eat a proper meal and sleep as well as you can the night "
              "before."),
          _en("Talk about pain relief early, and ask how you'll ask for an "
              "epidural if you want one."),
          _en("Bring your birth plan. Most of it still applies."),
          _en("If labour starts by itself or your waters break before the "
              "date, call the hospital and go in."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Induction and augmentation are different'),
          body: _en("Induction starts labour that hasn't begun. Augmentation "
              "strengthens a labour that has started but slowed, usually with "
              "the oxytocin drip or by breaking the waters."),
        ),
      ),
      PvReadSection(
        heading: _en('Can I bring on labour myself instead?'),
        paragraphs: [
          _en("Families often suggest home remedies near the due date. Some "
              "are harmless, some aren't, and none is proven to start labour. "
              "Please check with your doctor before trying anything. The read "
              "'Past your due date' on this door goes through the common "
              "ones, like walking, ghee and castor oil, one by one."),
          _en("If your doctor has already booked an induction, keep the "
              "date. Until then, rest, eat well and keep an eye on your "
              "baby's movements."),
        ],
      ),
    ],
    whenToSeeSomeone: _goNow,
    faqs: [
      PvReadFaq(
        question: _en('Is induction more painful?'),
        answer: _en("Contractions on the drip can come on faster and "
            "stronger. Pain relief, including an epidural, is usually "
            "available. Ask early."),
      ),
      PvReadFaq(
        question: _en('Can I go home after the gel?'),
        answer: _en("Some hospitals allow it for a few hours; most keep you "
            "in. Your doctor will tell you what's right for you."),
      ),
      PvReadFaq(
        question: _en('Does induction mean I will need a C-section?'),
        answer: _en("No. Many induced labours end in a vaginal birth. If a "
            "C-section is needed, it will be for a reason your doctor "
            "explains."),
      ),
    ],
    evidence: _en('WHO recommendations for induction of labour (2011, updated '
        '2022) · NICE guideline NG207, Inducing labour (2021) · FOGSI good '
        'clinical practice recommendations on induction of labour · ACOG '
        'Practice Bulletin 107, Induction of labor.'),
    readNext: [
      'preg_labour_read_past_due',
      'preg_labour_read_pain_relief',
      'preg_labour_read_stages',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Past your due date
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_past_due',
    hue: _hue,
    kicker: _kicker,
    title: _en('Past your due date'),
    teaser: _en("Why babies come late, the checks after 40 weeks, what's "
        "safe to try at home, and why doctors offer induction."),
    shortAnswer: _en("Going past your due date is common, especially with a "
        "first baby. After 40 weeks your doctor will check you and the baby "
        "more often, and most doctors in India offer induction at about 41 "
        "weeks. Check with your doctor before trying anything at home to "
        "bring labour on."),
    scaleSetter: _en("The due date is a best guess, not a deadline. Lots of "
        "healthy babies are born in the week or two after it. What changes "
        "after 40 weeks is how closely your doctor watches, not how worried "
        "you need to be."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Your due date is 40 weeks from the first day of your last "
            "period, or from your early scan. Most babies come between 37 "
            "and 42 weeks. First babies, and babies in families where others "
            "came late, often arrive after the date."),
        _en("Often there's no clear reason. The baby and your body just "
            "aren't ready yet. It isn't something you did or didn't do."),
      ]),
      PvReadSection(
        heading: _en('What checks will I have?'),
        paragraphs: [
          _en("After 40 weeks your doctor will usually see you more often. "
              "They may do a monitoring trace of the baby's heartbeat (a "
              "non-stress test), a scan to check the fluid around the baby, "
              "and an internal check to see how ready your cervix is."),
          _en("Keep feeling for your baby's movements every day. The pattern "
              "should stay the same right up to labour. Babies don't move "
              "less near the end."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do doctors offer induction?'),
        paragraphs: [
          _en("Late in pregnancy, the placenta can gradually work less well. "
              "Across large groups of women, the number of stillbirths rises "
              "slowly after 41 weeks and more after 42 weeks, though it stays "
              "low overall. That's why WHO and Indian doctors usually offer "
              "induction at around 41 weeks."),
          _en("Babies born after the due date are, on average, a little "
              "bigger. Your doctor may check the baby's size on a scan, but "
              "size estimates late in pregnancy are often off by a few "
              "hundred grams either way."),
          _en("If your cervix isn't opening at 41 weeks, that's common and "
              "doesn't mean labour won't work. It's why induction often "
              "starts with medicine to soften the cervix. Very few women in "
              "India reach 42 or 43 weeks, because most hospitals will have "
              "started labour before then."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I try at home?'),
        paragraphs: [
          _en("Your family may suggest many things. Here's what's known, "
              "kindly and honestly. Ask your doctor before trying anything."),
        ],
        bullets: [
          _en("Walking, gentle stairs and staying active: harmless if your "
              "doctor agrees, and good for you. There's little proof it "
              "starts labour."),
          _en("Sex, if your waters haven't broken and your doctor hasn't "
              "said to avoid it: generally safe. It may help a little, but "
              "the proof is weak."),
          _en("Ghee, dates and warm milk: fine as part of your normal food. "
              "Ghee doesn't start labour or make it easier, and a lot of it "
              "adds only calories."),
          _en("Castor oil: please don't take it unless your doctor tells "
              "you to. It can cause diarrhoea, vomiting and dehydration, and "
              "strong contractions that may stress the baby."),
          _en("Herbal remedies, unripe papaya, or pills from a chemist "
              "without a prescription: avoid them. None is proven, and some "
              "may be harmful."),
          _en("Nipple rubbing to bring on contractions: only with your "
              "doctor's advice, because it can cause strong contractions."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I cope with the waiting?'),
        paragraphs: [
          _en("The days after the due date can feel very long, with phone "
              "calls asking 'any news?'. It's fine to send one message to "
              "everyone and switch off for a while."),
          _en("Rest, eat well, and do small things you enjoy. Keep your bag "
              "and folder by the door. And keep your appointments, because "
              "they're how your doctor keeps you both safe while you wait."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens at 41 weeks?'),
        paragraphs: [
          _en("By about 41 weeks, most doctors in India will talk to you about "
              "a plan. Often that's an induction booked within the next few "
              "days, with checks on you and the baby until then. Sometimes a "
              "membrane sweep is offered first at a check-up."),
          _en("If there's a reason to act sooner, such as high blood pressure, "
              "less fluid around the baby, or the baby not growing well, your "
              "doctor may suggest induction earlier. They'll explain what "
              "they've seen and why. Ask your questions, and follow the plan "
              "you agree."),
        ],
      ),
      PvReadSection(
        heading: _en('Can a scan give me a new due date?'),
        paragraphs: [
          _en("No. Your due date is set from your early scans and doesn't "
              "change late in pregnancy. Late scans check the baby's wellbeing "
              "and the fluid, not the date."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go to hospital now if'),
      body: _en("The baby is moving less than usual or the pattern changes. "
          "Don't wait until the next day, and don't try to get the baby "
          "moving first. Also go now if your waters are green or brown, "
          "you're bleeding, you have a severe headache or fever, or constant "
          "pain."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('How late can I go?'),
        answer: _en("Most doctors in India plan induction at about 41 weeks "
            "and rarely let a pregnancy go past 42. Your doctor will set the "
            "plan for you."),
      ),
      PvReadFaq(
        question: _en('Can I say I\'d like to wait longer?'),
        answer: _en("You can talk about it. Some doctors agree to wait a "
            "little with extra checks. Follow the plan you agree together."),
      ),
      PvReadFaq(
        question: _en('Will a late baby be too big for a normal birth?'),
        answer: _en("Not usually. Most babies born after the due date are "
            "born vaginally. Your doctor will tell you if there's a concern."),
      ),
    ],
    evidence: _en('WHO recommendations for induction of labour (2022 update), '
        'on induction at 41 weeks · Cochrane review of induction of labour at '
        'or beyond term (2020) · NICE guideline NG207, Inducing labour (2021) '
        '· FOGSI good clinical practice recommendations on post-term '
        'pregnancy.'),
    readNext: [
      'preg_labour_read_induction',
      'preg_labour_read_signs_near',
      'preg_cond_read_less_movement',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Birth after a C-section (VBAC)
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_vbac',
    hue: _hue,
    kicker: _kicker,
    title: _en('Birth after a C-section'),
    teaser: _en("A second C-section isn't automatic. When a vaginal birth may "
        "still be possible, what it involves, and what to ask your doctor."),
    shortAnswer: _en("Many women who've had one C-section can try for a "
        "vaginal birth next time. This is called a VBAC. Whether it suits "
        "you depends on why you had the C-section, the kind of cut, and "
        "your hospital. Talk to your doctor early in this pregnancy."),
    scaleSetter: _en("Many second-time mothers in India assume a repeat "
        "C-section is the only way. For many it isn't. Both a planned repeat "
        "C-section and a trial of labour are safe choices for the right "
        "woman, and your doctor will help you weigh them."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("VBAC stands for vaginal birth after caesarean. Trying for one "
            "means going into labour, with extra care, and aiming for a "
            "vaginal birth. If labour doesn't go well, the team can move to "
            "a C-section."),
        _en("It's worth raising early, ideally in the first half of "
            "pregnancy, so you have time to think and to choose a hospital "
            "that supports it."),
      ]),
      PvReadSection(
        heading: _en('Who might be able to try?'),
        bullets: [
          _en("You've had one C-section, with a low, sideways cut on your "
              "womb. The cut on your skin doesn't always match the cut on "
              "your womb, so your doctor will check your old notes."),
          _en("The reason for the last C-section, like a breech baby, isn't "
              "likely to happen again."),
          _en("This pregnancy has no other reason for a C-section, such as "
              "a low-lying placenta."),
          _en("There has been a gap of more than about 18 months between the "
              "last birth and this one."),
          _en("Your hospital can do an emergency C-section at any hour and "
              "monitor you closely in labour."),
        ],
      ),
      PvReadSection(
        heading: _en('How often does it work?'),
        paragraphs: [
          _en("Across large studies, about 6 to 7 in every 10 women who try "
              "for a VBAC have a vaginal birth. Women who've had a vaginal "
              "birth before tend to do even better. The rest have a C-section "
              "during labour."),
          _en("A VBAC means a shorter recovery, no new scar, and fewer "
              "problems in later pregnancies. The main concern is the scar "
              "opening during labour (uterine rupture). It's rare, about 1 in "
              "200 women who labour after a C-section, but serious, which is "
              "why close monitoring and a ready theatre matter."),
          _en("These are numbers for large groups. Your doctor will talk "
              "about what they mean for you."),
        ],
      ),
      PvReadSection(
        heading: _en('What is labour like with a VBAC?'),
        paragraphs: [
          _en("Go to hospital early in labour, when contractions become "
              "regular, or as soon as your waters break. You'll usually have "
              "a drip in your hand and the baby's heartbeat monitored all "
              "the time. An epidural is usually fine."),
          _en("If labour needs to be started, your doctor will choose gentle "
              "methods, as some medicines used for induction aren't advised "
              "after a C-section."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask my doctor?'),
        bullets: [
          _en("Could I try for a VBAC? Why, or why not?"),
          _en("What kind of cut did I have on my womb?"),
          _en("Does this hospital support VBAC, day and night?"),
          _en("What happens if I go past my due date?"),
          _en("If I choose a repeat C-section, when would it be planned?"),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('After two or more C-sections'),
          body: _en("Most Indian hospitals advise a planned repeat C-section. "
              "Your doctor will explain the reasons for you."),
        ),
      ),
      PvReadSection(
        heading: _en('How can I prepare for a VBAC?'),
        bullets: [
          _en("Get the notes from your last C-section, or ask the hospital "
              "for them, so your doctor can see the kind of cut and why it "
              "was done."),
          _en("Choose a hospital that supports VBAC, with an anaesthetist and "
              "theatre ready day and night, and ask about their approach."),
          _en("Agree with your doctor what happens if you go past your due "
              "date, and when to come in once labour starts."),
          _en("Write a birth plan that covers both a VBAC and a repeat "
              "C-section, so either way you know what you'd like."),
          _en("Choose a calm birth companion, and prepare them for a longer "
              "stay in hospital."),
        ],
        paragraphs: [
          _en("If it ends in a C-section, that isn't a failed VBAC. You gave "
              "yourself the choice, and the team kept you both safe."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I want a repeat C-section?'),
        paragraphs: [
          _en("That's a real choice too. Some women prefer a planned date, "
              "or had a hard labour last time and don't want another. Tell "
              "your doctor what you're thinking and why."),
          _en("A planned repeat C-section is usually booked for about 39 "
              "weeks. If labour starts before the date, call your doctor and "
              "go to hospital. The recovery will be much like last time, and "
              "you'll know more about what helps."),
          _en("Whichever you choose, write it in your birth plan and share it "
              "with your companion. Knowing the plan ahead makes the day "
              "calmer for everyone."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('In labour after a C-section, go to hospital now if'),
      body: _en("You have constant pain over your scar or tummy that doesn't "
          "ease between contractions, bleeding, the baby moving less, "
          "contractions that suddenly stop, or you feel faint. Call 108 if "
          "you need an ambulance."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is a planned repeat C-section safer?'),
        answer: _en("Each choice has its own benefits and downsides, and "
            "both are safe choices for the right woman. Your doctor will "
            "help you decide based on your history."),
      ),
      PvReadFaq(
        question: _en('Can I change my mind?'),
        answer: _en("Yes, in either direction. Tell your doctor as early as "
            "you can."),
      ),
      PvReadFaq(
        question: _en('Will my scar hurt in labour?'),
        answer: _en("Some pulling is normal. Pain over the scar that stays "
            "between contractions isn't. Tell the team straight away."),
      ),
    ],
    evidence: _en('RCOG Green-top Guideline 45, Birth after previous caesarean '
        'birth (2015) · ACOG Practice Bulletin 205, Vaginal birth after '
        'cesarean delivery (2019) · NICE guideline NG192, Caesarean birth '
        '(2021) · FOGSI guidance on trial of labour after caesarean.'),
    readNext: [
      'preg_labour_read_c_section',
      'preg_labour_read_when_to_go',
      'preg_labour_read_induction',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Tears, episiotomy and stitches
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_tears',
    hue: _hue,
    kicker: _kicker,
    title: _en('Will I tear? Episiotomy, tears and stitches'),
    teaser: _en("What tears are, what an episiotomy is, what helps before "
        "and during the birth, and how stitches heal."),
    shortAnswer: _en("Many women have a small tear or graze with a first "
        "vaginal birth, and most heal well within a few weeks. An episiotomy "
        "is a small cut made only when needed. Massaging the area from about "
        "34 weeks and a slow birth of the head can both help."),
    scaleSetter: _en("This is one of the biggest fears before birth, and it's "
        "often worse in the imagination. Most tears are small. They're "
        "stitched with a numbing injection first, and heal on their own."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The skin and muscle between your vagina and bottom (the "
            "perineum) stretches a lot as your baby is born. Sometimes it "
            "tears a little. This is more common with a first vaginal birth, "
            "a big baby, or a birth helped by forceps or vacuum."),
        _en("You probably won't feel the tear itself at the time, because "
            "the stretching numbs the area. You'll know afterwards because "
            "the doctor will tell you and stitch it."),
      ]),
      PvReadSection(
        heading: _en('What kinds of tears are there?'),
        bullets: [
          _en("First degree: a small tear in the skin only. It often heals "
              "without stitches."),
          _en("Second degree: into the muscle. This is the most common kind "
              "that needs stitches, done in the labour room."),
          _en("Third and fourth degree: deeper, reaching the muscle around "
              "the back passage. These are uncommon, a few in every hundred "
              "first births, and are repaired in theatre with good pain "
              "relief."),
        ],
      ),
      PvReadSection(
        heading: _en('What is an episiotomy?'),
        paragraphs: [
          _en("An episiotomy is a small cut made by the doctor to widen the "
              "opening, usually slanting down and to one side. You'll have a "
              "numbing injection first if you don't have an epidural."),
          _en("It used to be done for almost every first birth in India. WHO "
              "and FOGSI now advise it only when needed, for example if the "
              "baby needs to be born quickly or forceps are used. You can ask "
              "your doctor about their practice at a check-up, and put your "
              "wishes in your birth plan."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps before and during the birth?'),
        paragraphs: [
          _en("Perineal massage from about 34 weeks helps reduce tears that "
              "need stitches in a first birth. Wash your hands, use a little "
              "plain oil, put one or two thumbs just inside the vagina, and "
              "press gently down and to the sides for a minute or two, until "
              "you feel a stretch. Do it a few times a week. Your partner can "
              "help. Skip it if your doctor has said not to, for example with "
              "a low-lying placenta or an infection."),
          _en("During the birth, a warm compress on the perineum and a slow "
              "birth of the head both help. When the doctor or nurse says "
              "stop pushing, pant or breathe gently. Pushing positions on your "
              "side or on all fours may help too."),
        ],
      ),
      PvReadSection(
        heading: _en('How do stitches heal?'),
        paragraphs: [
          _en("Stitches usually dissolve on their own in two to four weeks. "
              "The area is sore for a week or two and then eases."),
        ],
        bullets: [
          _en("Cool packs wrapped in a cloth, for 10 minutes at a time, in "
              "the first days."),
          _en("A warm sitz bath, sitting in a tub of plain warm water, once "
              "or twice a day after the first day or two."),
          _en("Pour water over the area while you pee, to ease the sting."),
          _en("Change pads often, and pat dry from front to back."),
          _en("Drink water and eat fibre so your stools stay soft. Your "
              "doctor may give a stool softener. Hold a clean pad against "
              "the stitches when you open your bowels."),
          _en("Paracetamol is usually fine. Ask about other pain relief if "
              "you're breastfeeding."),
          _en("Gentle pelvic floor squeezes from a few days after birth help "
              "healing."),
        ],
      ),
      PvReadSection(
        heading: _en('When will it feel normal again?'),
        paragraphs: [
          _en("Most women with small tears feel much better within two to "
              "three weeks. It can take a few months for the area to feel "
              "fully normal, and that's usual too."),
          _en("If you had a deeper tear, your doctor will see you again to "
              "check healing. Ask about a women's health physiotherapist, "
              "who helps with the pelvic floor and any leaking. Mention at "
              "your six-week check if you still have pain, leaking of urine "
              "or wind, or pain with sex. These are common and treatable, "
              "and you don't need to put up with them."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I tell my doctor beforehand?'),
        paragraphs: [
          _en("Ask at a check-up how often they do an episiotomy and why. Tell "
              "them about any past tear or surgery down below, and put your "
              "wishes in your birth plan. On the day, follow their advice."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor today if'),
      body: _en("Your stitches become more painful, hot, swollen or red, "
          "there's pus or a bad smell, you have a fever, or you can't control "
          "wind or stools. Go to hospital now if you're bleeding heavily or "
          "feel faint."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('When can I sit normally?'),
        answer: _en("Usually within a week or two. A soft cushion helps. Sit "
            "evenly rather than on one side."),
      ),
      PvReadFaq(
        question: _en('Will sex be painful after a tear?'),
        answer: _en("It can be tender the first few times. Wait until you "
            "feel ready and the bleeding has stopped, use a lubricant, and "
            "tell your doctor if pain continues."),
      ),
      PvReadFaq(
        question: _en('Will it tear again next time?'),
        answer: _en("Most women who tore in a first birth don't have a "
            "serious tear next time. Tell your doctor about any past tear."),
      ),
    ],
    evidence: _en('WHO recommendations: intrapartum care for a positive '
        'childbirth experience (2018), on episiotomy and perineal techniques '
        '· Cochrane reviews of antenatal perineal massage (2013) and '
        'perineal techniques in the second stage (2017) · RCOG Green-top '
        'Guideline 29, Third and fourth degree perineal tears · FOGSI patient '
        'guidance.'),
    readNext: [
      'preg_labour_read_pushing_placenta',
      'preg_labour_read_first_hour',
      'preg_week_read_first_24h',
    ],
  ),
];
