// =============================================================================
//  Labour prep — the door's reads
// -----------------------------------------------------------------------------
//  The brief (30 Aug 2026): *"Net-new in the whole area: just the short
//  pain-relief primer in Sub-tab 3."* That was the first read. On 2026-09-29
//  the pregnancy gap analysis (Flo / What to Expect vs ParentVeda, "Behind ·
//  Labour & birth", P1) found this door the thinnest one at the end of
//  pregnancy, and asked for the birth itself to be written. So this file now
//  holds:
//
//    · the pain-relief primer, rewritten to `docs/PREG-VOICE.md`;
//    · the four reads the door marked coming soon: the C-section, the first
//      hour after birth, what labour is like and your options, and what your
//      partner can do;
//    · and, spread in from two sibling files, the "Signs and stages" reads
//      (`pregnancy_reads_labour_birth.dart`) and the "Feeding and first days"
//      reads (`pregnancy_reads_labour_feeding.dart`).
//
//  ⚠️ THE SPREAD IS HERE, NOT IN `pregnancy_reads.dart`. That file's one shared
//  line is `...kPregnancyReadsLabour`; spreading the siblings into this list
//  means a door can grow without anyone touching the shared index.
//
//  ---------------------------------------------------------------------------
//  ⚠️ A FREE PRIMER IN FRONT OF A PAID CLASS, AND THE LINE BETWEEN THEM MATTERS
//  ---------------------------------------------------------------------------
//
//  Class 4 of the Birthing Course is "Pain relief - natural, epidural &
//  C-section", twenty-four minutes, and it is locked. The primer is the free
//  version. That arrangement is only honest if the free thing is useful on its
//  own, so it answers the question completely at the level somebody asks it at
//  34 weeks. The class goes deeper. Nothing below exists to make you buy it.
//
//  ⚠️ AND NO DECISION IS MADE FOR HER. Pain relief is the most judged choice in
//  pregnancy, in both directions. Every option is described as what it is, not
//  as what a sensible person would pick.
//
//  ⚠️ TRUST (gap analysis P1): the primer used to carry a named reviewer who
//  never reviewed it. Every read here is `reviewed: false` with the desk
//  byline until a real clinician has read it.
//
//  ⚠️ "C-section" IS KEPT — the brief says so, and it is the word people use.
//  "Braxton Hicks" may appear inside a read, after the plain words, never as a
//  door label (the door test holds that).
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import 'pregnancy_reads_labour_birth.dart';
import 'pregnancy_reads_labour_feeding.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The labour bracket's hue.
const double _hue = 344;

/// The honest byline until a real clinician has read the piece.
final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('Labour prep');

final List<PvRead> kPregnancyReadsLabour = [
  // ---------------------------------------------------------------------------
  //  Pain relief (rewritten 2026-09-29 to docs/PREG-VOICE.md)
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_pain_relief',
    hue: _hue,
    kicker: _en('Labour prep'),
    title: _en('Pain relief: natural, epidural and C-section'),
    teaser: _en("What each one involves, what it costs in an Indian hospital, "
        "and what you can leave until the day."),
    shortAnswer: _en("You have options, from breathing and a hot water bottle "
        "to an epidural. The one thing to sort out now is whether your "
        "hospital can offer what you might want. Whether you'll want an "
        "epidural can wait until the day."),

    scaleSetter: _en("There's no brave option and no easy one. Women who plan "
        "an epidural manage without it, and women who planned nothing ask "
        "for everything. Both are normal. It helps to know your options "
        "before you're in labour."),

    author: _desk,
    authorRole: _deskRole,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Labour hurts, and lots of things help, from a hot water bottle "
              "to an anaesthetist. Most women use several, in the order they "
              "need them. Very few stick to what they wrote down beforehand."),
          _en("You don't need to know yet which one you'll want. What's "
              "worth checking now is whether your hospital can give you the "
              "options you might want. That's the question you can't answer "
              "at 2am."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Ask this at your next visit'),
          body: _en("'Is an anaesthetist available at night and at weekends?' "
              "In many Indian hospitals the honest answer is 'usually'. "
              "It's worth knowing that before you're in labour."),
        ),
      ),

      PvReadSection(
        heading: _en('What helps without medicine?'),
        paragraphs: [
          _en("These aren't second best. They're what most women in the world "
              "use. They work best when labour is moving, and you can start "
              "them as soon as it does."),
        ],
        bullets: [
          _en("Moving and changing position: walking, leaning, rocking, on "
              "all fours. Being upright helps labour along as well as "
              "helping the pain. That's why lying flat is no longer "
              "routine."),
          _en("Breathing you've practised. Untrained breathing in labour "
              "tends to turn into holding your breath, which makes "
              "everything harder. Practised breathing is free, needs no "
              "permission, and helps more than almost anything else here."),
          _en("Heat: a hot water bottle or a warm compress on your lower "
              "back. Easy, and it helps more than you'd think."),
          _en("Firm pressure on your lower back from whoever is with you. "
              "It's the most useful thing a partner can do, and the thing "
              "they're most often not told about."),
          _en("Warm water, if there's a shower. Not every Indian labour room "
              "has one, so ask."),
        ],
        tip: PvReadTip(
          title: _en('Practise the breathing now'),
          body: _en("Breathing only helps in labour if it's automatic by then. "
              "Ten minutes a week from about 30 weeks is enough. Breathe in "
              "through your nose for a count of four, and out slowly through "
              "your mouth for a count of six. Let your shoulders drop on the "
              "out-breath."),
        ),
      ),

      PvReadSection(
        heading: _en('What about hypnobirthing and other classes?'),
        paragraphs: [
          _en("Hypnobirthing classes are growing in Indian cities. They teach "
              "deep relaxation, breathing and calm words to use in labour. "
              "Many women find they feel less afraid and more in control."),
          _en("What they can't do is promise a painless birth, or stop a "
              "labour needing help. Think of it as a good way to practise "
              "breathing and calm, with a teacher. It fits alongside every "
              "other option on this page, including an epidural."),
          _en("A few hospitals also offer gas and air (nitrous oxide, often "
              "called Entonox), which you breathe through a mouthpiece "
              "during contractions. Some offer a pain-relief injection too. "
              "Ask your hospital which of these it has."),
        ],
      ),

      PvReadSection(
        heading: _en('What is an epidural like?'),
        paragraphs: [
          _en("An epidural is an injection into the space around the nerves "
              "in your lower back. A fine tube stays in, so the relief keeps "
              "going for as long as you need it. It's the strongest pain "
              "relief there is in labour. In most Indian city hospitals "
              "you can have one if an anaesthetist is on site."),
          _en("Here's what it's like. You sit or lie curled forward and stay "
              "still through a contraction or two while it goes in. You get "
              "a local anaesthetic first, so it stings rather than hurts. It "
              "takes 15 to 20 minutes to work fully."),
          _en("Afterwards your legs feel heavy and you'll usually stay in bed, "
              "often with a catheter and the baby's heartbeat monitored all "
              "the time. Some women mind not being able to move more than "
              "they expected. Others sleep for the first time in a day and "
              "reach the pushing stage with energy left."),
          _en("The honest downsides: a headache afterwards in a small number "
              "of women, a longer pushing stage on average, and more need for "
              "help with forceps or a vacuum. It doesn't make a C-section "
              "more likely, which is the belief most worth correcting. "
              "Backache after birth is very common anyway, and the epidural "
              "doesn't cause it."),
        ],
        mythFact: PvMythFact(
          myth: _en('An epidural means you are more likely to end up with a '
              'C-section.'),
          fact: _en("It doesn't. Large reviews of the evidence find no rise in "
              "C-section births with an epidural. It does make forceps or "
              "vacuum help somewhat more likely, and it makes the pushing "
              "stage a little longer. Those are real trade-offs. A C-section "
              "isn't one of them."),
        ),
      ),

      PvReadSection(
        heading: _en('What do women worry about with an epidural?'),
        bullets: [
          _en("The needle. You don't see it, it goes in behind you, and the "
              "skin is numbed first. Most women say the contractions were far "
              "worse."),
          _en("Back pain for years. Families often say this. Studies that "
              "followed women for years found no link between an epidural "
              "and long-term back pain."),
          _en("Not being able to push. Most women still push well. The "
              "team can let the dose ease a little near the end if needed, "
              "and they'll tell you when to push."),
          _en("Harm to the baby. Very little of the medicine reaches the "
              "baby, and the baby's heartbeat is watched throughout."),
        ],
      ),

      PvReadSection(
        heading: _en('When might an epidural not be possible?'),
        paragraphs: [
          _en("Sometimes it isn't safe or there isn't time. It's better to "
              "know this now than to hear it for the first time on the day."),
        ],
        bullets: [
          _en("A low platelet count or a blood-clotting problem."),
          _en("Blood-thinning injections given too close to the time. Your "
              "doctor will plan the timing if you're on them."),
          _en("An infection in your back where the needle would go, or an "
              "infection in the blood."),
          _en("Some past back surgery. Tell your doctor at a check-up so the "
              "anaesthetist can look at it early."),
          _en("A labour that's moving very fast, or no anaesthetist free "
              "right then."),
        ],
      ),

      PvReadSection(
        heading: _en('What does it cost in India?'),
        paragraphs: [
          _en("Prices vary a lot. The figure is usually added on top of the "
              "delivery package, not included in it."),
          _en("An epidural usually adds between ₹8,000 and ₹25,000 in a "
              "private hospital, depending on the city and the "
              "anaesthetist's fee. In a government hospital it's generally "
              "free where it's offered at all. There, whether it's available "
              "matters more than the cost."),
          _en("Ask for it in writing as part of your delivery estimate. 'Is "
              "the epidural included?' has two very different answers, and "
              "now is the time to find out which one is yours."),
        ],
      ),

      PvReadSection(
        heading: _en('And if it becomes a C-section?'),
        paragraphs: [
          _en("A C-section is an operation to deliver the baby through a cut "
              "in your tummy and womb. For some pregnancies it's planned in "
              "advance. For others it's decided during labour."),
          _en("Nearly all are done while you're awake, with a spinal "
              "injection that numbs you from the chest down. It's like an "
              "epidural, but one dose that works faster. You're awake for "
              "the birth and can usually hold the baby soon after. A general "
              "anaesthetic is kept for real emergencies."),
          _en("Needing one isn't a failure, and you didn't cause it by asking "
              "for pain relief. There's a full read on what happens in "
              "'If it becomes a C-section' on this door."),
        ],
      ),

      PvReadSection(
        heading: _en('What should I decide now, and what can wait?'),
        collapsible: true,
        summary: _en('Three things now. Everything else on the day.'),
        paragraphs: [
          _en("Decide now: which hospital, whether an anaesthetist is there "
              "at night, and who is coming with you and what you'd like them "
              "to do. All three are hard to change later, and all three "
              "shape what you can have on the day."),
          _en("Leave until the day: whether you want an epidural. Nobody can "
              "know that in advance, and deciding firmly now mostly gives you "
              "something to feel bad about later. 'I'd like to try without, "
              "and I'll ask if I want it' is a complete plan."),
          _en("Tell whoever is with you what you'd like them to say if you "
              "ask for something. Some women want to be encouraged to keep "
              "going. Some want to be taken seriously straight away. Your "
              "partner can't guess which one you'll be."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor if'),
      body: _en("Your waters break, you have any bleeding, the baby is moving "
          "less than usual, or you have a bad headache with blurred vision. "
          "Call whatever your contractions are doing. And if something feels "
          "wrong and isn't on any list, call anyway."),
    ),

    faqs: [
      PvReadFaq(
        question: _en("Is it too late for an epidural if I'm already far "
            "along?"),
        answer: _en("Usually not, though near the very end there may not be "
            "time for one to work. Ask as soon as you think you might want "
            "it, rather than waiting to be sure. You can change your mind "
            "while they set up."),
      ),
      PvReadFaq(
        question: _en('Will it hurt the baby?'),
        answer: _en("Very little of the medicine reaches the baby. Babies are "
            "sometimes a bit sleepy at first, and the team watches for it. "
            "It's one of the most studied treatments in medicine."),
      ),
      PvReadFaq(
        question: _en('What if the hospital says no?'),
        answer: _en("Usually it means no anaesthetist is free right then, not "
            "a refusal. Ask what else they can offer, and ask again later. If "
            "it matters a lot to you, choose your hospital with that in "
            "mind."),
      ),
      PvReadFaq(
        question: _en('My family thinks pain relief is unnecessary.'),
        answer: _en("That's common, and they mean well, but it isn't medical "
            "advice. This is your labour and your body. Your doctor will "
            "support whatever you decide on the day."),
      ),
    ],

    evidence: _en('Cochrane reviews of epidural versus non-epidural analgesia '
        'in labour · NICE guideline CG190, intrapartum care · FOGSI good '
        'clinical practice recommendations on labour analgesia · Obstetric '
        'Anaesthetists\' Association patient information on epidurals · '
        'Private hospital rate cards sampled September 2026.'),

    readNext: [
      'preg_labour_read_options',
      'preg_labour_read_c_section',
      'preg_cond_read_less_movement',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  If it becomes a C-section (was coming soon; written 2026-09-29)
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_c_section',
    hue: _hue,
    kicker: _en('Labour prep'),
    title: _en('If it becomes a C-section'),
    teaser: _en("Why it happens, planned or during labour, what happens in "
        "theatre, and what the first days after are like."),
    shortAnswer: _en("A C-section is an operation to deliver your baby "
        "through a cut low on your tummy. Most are done while you're awake, "
        "numbed from the chest down, and you can usually see and hold your "
        "baby soon after. It's a birth, and recovery takes a few weeks."),
    scaleSetter: _en("C-sections are very common in India, especially in "
        "private hospitals, and they're one of the safest operations there "
        "is. Knowing what happens means it won't be a shock if it's "
        "suggested, whether weeks ahead or in the middle of labour."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("A C-section (caesarean section) delivers your baby through a "
            "cut in your tummy and womb. The cut is usually low and "
            "sideways, along the bikini line, so the scar sits below your "
            "underwear."),
        _en("Some are planned weeks ahead, usually for around 39 weeks. "
            "Others are decided during labour, sometimes calmly over an "
            "hour and sometimes quickly. Either way, it's still your baby's "
            "birth, and you're still part of it."),
      ]),
      PvReadSection(
        heading: _en('Why might I need one?'),
        paragraphs: [
          _en("Your doctor will always explain the reason. These are the "
              "common ones, so the words aren't new to you."),
        ],
        bullets: [
          _en("Planned: the baby is bottom or feet first (breech) or lying "
              "sideways, and can't be turned."),
          _en("Planned: the placenta is low and covering the neck of the "
              "womb (placenta praevia)."),
          _en("Planned: two or more C-sections before, some twin "
              "pregnancies, or a health condition of yours that makes labour "
              "unsafe."),
          _en("During labour: labour has slowed or stopped and isn't moving "
              "even with help."),
          _en("During labour: the baby's heartbeat shows the baby isn't "
              "coping well with contractions."),
          _en("Urgent: heavy bleeding, the placenta coming away early, or "
              "the cord slipping down ahead of the baby."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens in theatre?'),
        paragraphs: [
          _en("You'll be asked to sign a consent form and to stop eating a "
              "few hours before, if there's time. A drip goes into your hand "
              "and a thin tube (catheter) drains your bladder. The "
              "anaesthetist gives you a spinal injection in your lower back. "
              "Within minutes your legs feel warm and heavy, then numb."),
          _en("A screen goes up across your chest, so you don't see the "
              "operation. Some hospitals will lower it for the moment of "
              "birth if you ask. The baby is usually out within 5 to 10 "
              "minutes. The whole operation takes about 45 minutes to an "
              "hour, most of it for the careful stitching after."),
          _en("If your hospital allows, your partner or one family member can "
              "sit by your head. Ask about this early, because rules for "
              "theatre are stricter than for the labour room."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('What it feels like'),
          body: _en("You won't feel pain. You will feel pulling, pressing and "
              "tugging, sometimes firmly, as the baby is lifted out. Many "
              "women shiver or feel sick for a while. Both are common and "
              "the team can help."),
        ),
      ),
      PvReadSection(
        heading: _en('When do I see my baby?'),
        paragraphs: [
          _en("Usually straight away. The baby is lifted up for you to see, "
              "checked by the paediatrician, and in many hospitals placed on "
              "your chest, skin to skin, while you're stitched. If that "
              "isn't possible, your partner can hold the baby skin to skin "
              "instead."),
          _en("You can breastfeed in the recovery room, often within the "
              "first hour. The nurses will help you find a comfortable "
              "position that keeps the baby off your wound."),
        ],
      ),
      PvReadSection(
        heading: _en('What are the first days like?'),
        paragraphs: [
          _en("You'll be helped to sit up and walk within about a day. The "
              "first walk is the hardest, and it gets easier each time. The "
              "catheter usually comes out within the first day. Take your "
              "pain medicine regularly, not only when it hurts, because "
              "moving and feeding are easier when you're comfortable."),
          _en("Most women stay in hospital for about three to four days after "
              "a C-section in India. At home, you'll be told not to lift "
              "anything heavier than your baby for about six weeks. Hold a "
              "pillow against your wound when you cough, laugh or get up."),
          _en("Things women say nobody told them: itching for a few hours "
              "from the spinal medicine, trapped wind that can hurt up into "
              "the shoulder, and a numb patch around the scar that can last "
              "for months. All of these are normal."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I choose a C-section?'),
        collapsible: true,
        summary: _en("You can ask. Decide together with your doctor."),
        paragraphs: [
          _en("Some women ask for a planned C-section because they're afraid "
              "of labour. That fear is real and worth talking about. Tell "
              "your doctor what frightens you. Sometimes a birth plan, a "
              "class or an epidural makes labour feel possible again."),
          _en("A planned C-section is safe, but it's still an operation. "
              "Recovery takes longer than after a vaginal birth, and each "
              "C-section can make later pregnancies a little more "
              "complicated, for example with where the placenta settles. "
              "Your doctor will go through this with you for your own "
              "pregnancy."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('After a C-section, call your doctor straight away if'),
      body: _en("Your wound becomes red, hot, swollen or starts to leak, you "
          "have a fever, the bleeding gets heavier or you pass large clots, "
          "you have pain or swelling in one calf, or you feel breathless or "
          "have chest pain. Breathlessness or chest pain means go to "
          "hospital now."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can I have a normal birth next time?'),
        answer: _en("Often, yes. Many women can try for a vaginal birth after "
            "one C-section. There's a read on this door, 'Birth after a "
            "C-section', and your doctor will look at your own case."),
      ),
      PvReadFaq(
        question: _en('When can I bathe and wash my hair?'),
        answer: _en("Usually once the dressing comes off, often after a day "
            "or two. Your hospital will tell you. Pat the wound dry gently "
            "afterwards."),
      ),
      PvReadFaq(
        question: _en('Will I be able to breastfeed?'),
        answer: _en("Yes. Milk can take a little longer to come in after a "
            "C-section, so feed often and ask for help early. The side-lying "
            "and underarm holds keep the baby off your wound."),
      ),
      PvReadFaq(
        question: _en('Does a C-section mean I failed at labour?'),
        answer: _en("No. It means you and your baby needed a different way "
            "out, and you had it. That's what good care looks like."),
      ),
    ],
    evidence: _en('NICE guideline NG192, Caesarean birth (2021) · WHO '
        'statement on caesarean section rates (2015) · FOGSI guidance on '
        'caesarean delivery · RCOG patient information, Caesarean birth.'),
    readNext: [
      'preg_labour_read_vbac',
      'preg_labour_read_first_hour',
      'preg_labour_read_pain_relief',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  The first hour after birth (was coming soon; written 2026-09-29)
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_first_hour',
    hue: _hue,
    kicker: _en('Labour prep'),
    title: _en('The first hour after birth'),
    teaser: _en("Skin to skin, the cord, the baby's first checks, the first "
        "feed, and what's happening to you at the same time."),
    shortAnswer: _en("If you're both well, your baby goes onto your bare "
        "chest, the cord is clamped after a minute or so, and the baby is "
        "checked while lying on you. The placenta comes out, any stitches "
        "are done, and most babies are ready for a first feed within the "
        "hour."),
    scaleSetter: _en("The hour after birth is often called the golden hour. A "
        "lot happens in it, and most of it is quiet and routine. You can ask "
        "for the things that matter to you, like skin to skin and the first "
        "feed, and put them in your birth plan now."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The first hour goes very fast. You may feel joy, relief, "
            "shaking, tears or just tiredness. All of it is normal, and "
            "none of it says anything about how much you love your baby."),
        _en("Here's what usually happens, in order, if you and your baby "
            "are both well. If either of you needs care first, the team "
            "does that, and the rest follows as soon as it can."),
      ]),
      PvReadSection(
        heading: _en('What is skin to skin, and why ask for it?'),
        paragraphs: [
          _en("Your baby is dried and placed straight onto your bare chest, "
              "tummy down, with a warm cloth over you both. Your body keeps "
              "the baby warm better than a cot can."),
          _en("Skin to skin steadies your baby's breathing, heartbeat and "
              "blood sugar. It calms you both. And it's how most babies find "
              "the breast on their own. WHO advises it for at least the first "
              "hour for every well baby."),
          _en("In many Indian hospitals the baby is taken away first to be "
              "cleaned and wrapped. You can ask for skin to skin first. Put "
              "it in your birth plan and tell the nurse when you arrive."),
        ],
        tip: PvReadTip(
          title: _en('After a C-section too'),
          body: _en("Many hospitals now place the baby on your chest in "
              "theatre. If they can't, your partner or your mother can hold "
              "the baby skin to skin until you're back in recovery."),
        ),
      ),
      PvReadSection(
        heading: _en('What happens to the cord?'),
        paragraphs: [
          _en("Waiting at least a minute before clamping the cord lets extra "
              "blood flow from the placenta to your baby, which gives the "
              "baby more iron for the first months. This is now standard "
              "advice from WHO and in Indian guidance."),
          _en("If your baby needs help breathing, the cord may be cut sooner "
              "so the team can help straight away. Your partner may be "
              "offered the scissors to cut it."),
        ],
      ),
      PvReadSection(
        heading: _en("What checks does my baby have?"),
        paragraphs: [
          _en("At one minute and at five minutes, the team gives your baby an "
              "Apgar score. It's a quick look at colour, breathing, heart "
              "rate, muscle tone and reflexes, each scored 0 to 2. Seven or "
              "more is fine. Most babies score eight or nine, and very few "
              "score ten, because hands and feet are often still blue at "
              "first."),
          _en("A low score at one minute usually rises by five minutes. The "
              "score isn't a grade on your baby's future. It only tells the "
              "team whether to help right then."),
          _en("Then, often while the baby is still on you or right after, "
              "the baby is weighed and measured, given a vitamin K injection "
              "to prevent a rare bleeding problem, and gets a name band. "
              "The first bath should wait at least a day, as WHO advises. "
              "The white coating on the skin (vernix) protects it."),
        ],
      ),
      PvReadSection(
        heading: _en("What's happening to me?"),
        paragraphs: [
          _en("You'll usually get an injection in your thigh as the baby is "
              "born, to help your womb contract and keep bleeding down. The "
              "placenta then comes out with a few mild contractions, usually "
              "within half an hour."),
          _en("The doctor or nurse checks for tears and stitches any that "
              "need it, under a local anaesthetic if you haven't had an "
              "epidural. They'll press on your tummy now and then to check "
              "your womb is firm, and check your bleeding and blood pressure. "
              "Shaking and shivering in this hour are common and pass."),
        ],
      ),
      PvReadSection(
        heading: _en('When does the first feed happen?'),
        paragraphs: [
          _en("Most babies are alert and keen to feed in the first hour, then "
              "sleep deeply for a few hours. Skin to skin is how many find "
              "the breast themselves, bobbing and rooting towards it. A nurse "
              "can help with the latch."),
          _en("What comes first is colostrum, a small amount of thick, "
              "yellowish milk. It's exactly what a newborn needs, so nothing "
              "else is needed. There's more in the read 'The first feed, in "
              "the golden hour' on this door."),
        ],
      ),
      PvReadSection(
        heading: _en('What can my companion do in this hour?'),
        paragraphs: [
          _en("Take a photo if you'd like one, then put the phone away. Keep "
              "the room calm and visitors outside. Remind the nurse about skin "
              "to skin and the first feed if it's in your plan, and help you "
              "sit comfortably while the baby feeds."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Tell the nurse or doctor straight away if'),
      body: _en("You're soaking pads fast or passing large clots, you feel "
          "faint or dizzy, or you have a severe headache. Tell them at once "
          "if your baby looks blue or grey around the lips, is floppy, "
          "breathes very fast or with grunting, or won't wake."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can the family see the baby in the first hour?'),
        answer: _en("Yes, but it can wait. Many women like the first hour "
            "quiet, with only their partner. Family can meet the baby once "
            "you've had skin to skin and a first feed."),
      ),
      PvReadFaq(
        question: _en('Should the baby be given honey, ghutti or water first?'),
        answer: _en("No. Doctors in India and WHO advise nothing but breast "
            "milk from birth. Honey is unsafe for babies under a year. Your "
            "family means well, and you can say the doctor asked for breast "
            "milk only."),
      ),
      PvReadFaq(
        question: _en("What if I don't feel a rush of love?"),
        answer: _en("That's common. Many women feel relief or tiredness first. "
            "The bond grows over days and weeks of holding and feeding."),
      ),
    ],
    evidence: _en('WHO recommendations on newborn health (2017) and on '
        'intrapartum care for a positive childbirth experience (2018) · '
        'WHO / UNICEF Baby-Friendly Hospital Initiative · Cochrane review of '
        'early skin-to-skin contact (2016) · Government of India, Home Based '
        'Newborn Care and MAA programme guidance.'),
    readNext: [
      'preg_labour_read_golden_hour_feed',
      'preg_week_read_first_24h',
      'preg_labour_read_tears',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  What labour is like, and your options (was coming soon; written
  //  2026-09-29). The title lost "actually" (PREG-VOICE §4).
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_options',
    hue: _hue,
    kicker: _en('Labour prep'),
    title: _en('What labour is like, and your options'),
    teaser: _en("Where you'll give birth, who can be with you, positions "
        "that help, and how to ask questions in the labour room."),
    shortAnswer: _en("Labour comes in waves, with rests in between, and it "
        "builds over hours. Most of your real choices are made before it "
        "starts: the hospital, who comes with you, and what you'd like. On "
        "the day, you can always ask what's happening and why."),
    scaleSetter: _en("You won't control everything about labour, and nobody "
        "expects you to. But you can choose where you'll be, who will be "
        "with you and how you'd like to be spoken to. Those things change "
        "how the day feels more than almost anything else."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Contractions feel like strong period cramps or a tight band "
            "round your belly and back. Each one builds, peaks and fades, "
            "usually over about a minute, and then there's a rest. Early on "
            "the rests are long. Near the end they're short."),
        _en("Most first labours take many hours. Much of the early part can "
            "be spent at home, eating, resting and walking. The hard part is "
            "usually the last few hours, and women often say that knowing "
            "what was coming made it easier to bear."),
      ]),
      PvReadSection(
        heading: _en('Where can I give birth in India?'),
        bullets: [
          _en("A government hospital. Delivery, including a C-section, "
              "medicines, tests, food and transport, is free under the "
              "Janani Shishu Suraksha Karyakram (JSSK). Wards can be busy."),
          _en("A private hospital or nursing home. You pay a package, and "
              "rooms, pain relief and who can stay with you vary a lot."),
          _en("A birth centre or midwife-led unit. There are a small number "
              "in some Indian cities, with trained nurse-midwives and a "
              "hospital close by if help is needed."),
          _en("Water for labour. A few hospitals offer a pool to labour in. "
              "Fewer offer birth in water. Ask what they do and who looks "
              "after you."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Always with a skilled attendant'),
          body: _en("Wherever you give birth, make sure a trained doctor, "
              "nurse or midwife is with you, and that a hospital is close. "
              "Birth at home without one isn't safe."),
        ),
      ),
      PvReadSection(
        heading: _en('What should I ask on a hospital visit?'),
        paragraphs: [
          _en("Try to visit by about 32 to 34 weeks. Take these questions, "
              "and ask for the answers about costs in writing."),
        ],
        bullets: [
          _en("Can I see the labour room? Is it shared or private?"),
          _en("Who can be with me in labour, and in theatre if it's a "
              "C-section?"),
          _en("Is an anaesthetist there day and night for an epidural?"),
          _en("Can I move around, eat light food and drink in early labour?"),
          _en("Do you do skin to skin and a first feed in the first hour?"),
          _en("Is there a newborn intensive care unit (NICU) here? If not, "
              "where would my baby go?"),
          _en("What does the package include, and what is extra?"),
        ],
      ),
      PvReadSection(
        heading: _en('What positions help in labour?'),
        paragraphs: [
          _en("Staying upright and moving helps the baby move down and often "
              "eases the pain. Change position every half hour or so, or "
              "whenever your body asks you to. If you have an epidural, the "
              "nurses can still help you shift from side to side."),
        ],
        bullets: [
          _en("Walking, and swaying your hips between contractions."),
          _en("Standing and leaning forward onto the bed or your partner."),
          _en("Sitting on a birthing ball, rocking gently."),
          _en("Kneeling and leaning over a pillow, or on all fours. This can "
              "help with back pain."),
          _en("Lying on your side with a pillow between your knees, to rest."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I ask questions in the labour room?'),
        paragraphs: [
          _en("You're allowed to understand what's happening to you. Asking "
              "isn't arguing with your doctor. It helps you agree with the "
              "plan and feel part of it. If you can't talk, your companion "
              "can ask for you."),
          _en("Short questions work best: What is this for? Is it urgent, or "
              "do we have a little time? What happens if we wait? Is there "
              "another way? Then listen, and follow the plan you've agreed "
              "with your doctor. In an emergency they may need to act first "
              "and explain afterwards."),
        ],
      ),
      PvReadSection(
        heading: _en('Is cord blood banking worth it?'),
        collapsible: true,
        summary: _en("Honest facts before the sales call, so you can decide "
            "calmly."),
        paragraphs: [
          _en("Private cord blood banks contact many Indian parents in the "
              "last months. They offer to freeze blood from the cord after "
              "birth in case your child needs it one day. Packages are "
              "often quoted at tens of thousands of rupees, sometimes more "
              "than ₹1,00,000, plus yearly fees."),
          _en("The honest picture: the Indian Council of Medical Research "
              "(ICMR) doesn't recommend storing cord blood privately as a "
              "routine for a healthy family. A child's own cord blood "
              "is rarely used, and for many illnesses it can't be. Public "
              "donation, where it's offered, helps others. If your family "
              "has a known blood disorder, ask your doctor, because the "
              "answer may be different."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go to hospital now if'),
      body: _en("Your waters break and the fluid is green or brown, you have "
          "bleeding, the baby is moving less, you have a severe headache, "
          "fever, or pain that doesn't ease between contractions. Call your "
          "doctor on the way."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can I eat and drink in labour?'),
        answer: _en("In early labour, light food and sips of water are "
            "usually fine. Hospitals differ once labour is established, so "
            "ask what yours allows."),
      ),
      PvReadFaq(
        question: _en('Will I have to lie on my back to give birth?'),
        answer: _en("Not always. Many hospitals now allow other positions. "
            "Ask on your visit, and put what you'd like in your birth plan."),
      ),
      PvReadFaq(
        question: _en('What is a doula?'),
        answer: _en("A doula is a trained birth companion who supports you "
            "with comfort, calm and information. She isn't a nurse or doctor "
            "and doesn't make medical decisions. Doulas are available in some "
            "Indian cities, so ask your hospital whether they allow one."),
      ),
    ],
    evidence: _en('WHO recommendations: intrapartum care for a positive '
        'childbirth experience (2018) · Ministry of Health and Family Welfare, '
        'Janani Shishu Suraksha Karyakram and LaQshya labour room guidelines '
        '(2017) · ICMR national guidelines for stem cell research (2017) on '
        'cord blood banking · FOGSI patient guidance.'),
    readNext: [
      'preg_labour_read_partner',
      'preg_labour_read_pain_relief',
      'preg_labour_read_stages',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  What your partner can do (was coming soon; written 2026-09-29). The
  //  title lost "actually" (PREG-VOICE §4).
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_partner',
    hue: 206,
    kicker: _en('For your partner'),
    title: _en('What your partner should do'),
    teaser: _en("The practical jobs, in order, for someone who has never done "
        "this either, and who can be in the room in an Indian hospital."),
    shortAnswer: _en("Your birth companion's job is to keep you calm, fed, "
        "watered and comfortable, and to speak up for you when you can't. "
        "In many Indian hospitals only one person can come in, so choose "
        "them early and prepare together."),
    scaleSetter: _en("Nobody expects your partner to know what to do. What "
        "helps is a few jobs learnt in advance and a calm person beside you. "
        "This read is written to them as much as to you, so share it."),
    author: _desk,
    authorRole: _en('For your partner'),
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The person with you in labour might be your husband, your "
            "mother, your sister or a friend. Whoever it is, their job is "
            "the same: to be calm, to be there, and to know a few practical "
            "things."),
        _en("Most of this can be learnt in an evening. Read it together "
            "in the last month, and practise the massage below once or "
            "twice."),
      ]),
      PvReadSection(
        heading: _en('Who can be in the room in an Indian hospital?'),
        paragraphs: [
          _en("Rules vary a lot. Many private hospitals let a husband stay "
              "for a vaginal birth. Fewer allow anyone into theatre for a "
              "C-section. Government hospitals often allow one female "
              "relative, and under the national LaQshya programme, many now "
              "welcome a birth companion of your choice."),
          _en("Ask your hospital at your next visit: how many people, who, "
              "and whether it's different at night or for a C-section. Get "
              "the answer before labour, so nobody is turned away at the "
              "door."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I choose my birth companion?'),
        paragraphs: [
          _en("Choose the person who makes you feel calm, not the person "
              "who expects to be there. It's fine if that isn't your "
              "husband. Some couples decide he waits outside and her mother "
              "goes in. Others decide the opposite."),
          _en("Look for someone who can stay steady when you're in pain, "
              "who will speak up kindly for you, and who can be there for "
              "many hours. Talk to them about what you'd like before the "
              "day."),
        ],
      ),
      PvReadSection(
        heading: _en('What are the jobs, in order?'),
        bullets: [
          _en("Before: know the route to the hospital, the time it takes at "
              "night and in traffic, and keep the doctor's number saved. "
              "Keep the hospital bag and file by the door."),
          _en("Early labour at home: use the contraction timer, keep her "
              "eating and drinking a little, and help her rest between "
              "contractions."),
          _en("At the hospital: hand over the file, give the details at "
              "the desk, and let her focus on the contractions."),
          _en("In active labour: offer water after each contraction, remind "
              "her to empty her bladder every hour or two, help her change "
              "position, and breathe slowly with her."),
          _en("If she asks for pain relief: take her seriously and pass it "
              "on to the nurse straight away, as you agreed beforehand."),
          _en("After the birth: help with skin to skin and the first feed, "
              "and then call the family."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I ease the pain with massage?'),
        paragraphs: [
          _en("During a contraction, press the heel of your hand firmly on "
              "the flat bone at the base of her spine (the sacrum). Lean "
              "your weight in and hold it through the contraction. Ask her "
              "if she wants it harder or softer, and where."),
          _en("Between contractions, slow strokes down her back or a "
              "shoulder rub help her let go. A warm compress or hot water "
              "bottle on the lower back also helps. If she doesn't want to "
              "be touched, that's fine too. Just stay close."),
        ],
        tip: PvReadTip(
          title: _en('Practise it now'),
          body: _en("Try the lower-back pressure a few times in the last "
              "weeks, so you both know where it goes and how firm it should "
              "be."),
        ),
      ),
      PvReadSection(
        heading: _en('What should I say, and not say?'),
        paragraphs: [
          _en("Short, calm words help: You're doing it. Breathe out slowly. "
              "This one is nearly over. Your voice matters more than the "
              "words."),
          _en("Try not to compare her to anyone, rush her, or look at your "
              "phone during a contraction. Keep the room calm, and keep "
              "worried relatives outside if she wants that. You're allowed "
              "to take a short break to eat. Tell the nurse before you step "
              "out."),
        ],
      ),
      PvReadSection(
        heading: _en('How can we prepare together before the day?'),
        paragraphs: [
          _en("Read the birth plan together, so your companion knows what you'd "
              "like and can say it for you. Agree a word or sign that means "
              "'I want pain relief now' and one that means 'keep encouraging "
              "me'."),
          _en("Do a practice run to the hospital, at night if you can. Find "
              "the entrance for the labour ward, where to park, and which desk "
              "to go to. Keep both your phones charged in the last weeks, and "
              "agree who calls the family, and when."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Take her to hospital straight away, and call on the way, if'),
      body: _en("Her waters break and the fluid is green, brown or smells "
          "bad, she's bleeding, the baby is moving less, she has a severe "
          "headache, blurred vision, fever, or constant pain that doesn't "
          "come and go. If she feels faint, call 108 for an ambulance."),
    ),
    faqs: [
      PvReadFaq(
        question: _en("What if I'm not allowed in?"),
        answer: _en("Stay nearby and reachable. Before she goes in, agree what "
            "she'd like the team told, and give them your number. You can "
            "still help with skin to skin and feeding after the birth."),
      ),
      PvReadFaq(
        question: _en('What if I faint or feel sick?'),
        answer: _en("It happens. Sit down, eat something before you go in, "
            "and tell the nurse. Stand by her head, not at the foot of the "
            "bed, if you feel wobbly."),
      ),
      PvReadFaq(
        question: _en('Should we hire a doula?'),
        answer: _en("If you can and your hospital allows one, a doula can "
            "support you both, especially if the partner can't be there all "
            "the time. She adds support. She doesn't replace your doctor or "
            "the nurses."),
      ),
    ],
    evidence: _en('WHO recommendations: intrapartum care for a positive '
        'childbirth experience (2018), on labour companions · Ministry of '
        'Health and Family Welfare, LaQshya labour room quality improvement '
        'initiative (2017) · Cochrane review of continuous support for women '
        'during childbirth (2017).'),
    readNext: [
      'preg_labour_read_when_to_go',
      'preg_labour_read_options',
      'preg_week_read_partner_support',
    ],
  ),

  // The Signs and stages reads, and the Feeding and first days reads.
  ...kPregnancyReadsLabourBirth,
  ...kPregnancyReadsLabourFeeding,
];
