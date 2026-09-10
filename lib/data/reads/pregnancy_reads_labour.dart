// =============================================================================
//  Labour prep — the ONE read this door adds
// -----------------------------------------------------------------------------
//  The brief: *"Net-new in the whole area: just the short pain-relief primer in
//  Sub-tab 3."* Everything else is reuse or a single-source link.
//
//  ---------------------------------------------------------------------------
//  ⚠️ A FREE PRIMER IN FRONT OF A PAID CLASS, AND THE LINE BETWEEN THEM MATTERS
//  ---------------------------------------------------------------------------
//
//  Class 4 of the Birthing Course is "Pain relief - natural, epidural &
//  C-section", twenty-four minutes, and it is locked. This is the free version,
//  and the brief calls it a *"short free primer (the paid class covers it in
//  depth)"*.
//
//  That arrangement is only honest if the free thing is genuinely useful on its
//  own. A primer written to make the class look necessary is an advertisement
//  wearing an article's chip — and this app's own rule is that a tile which
//  costs money must be legible as such BEFORE she taps, which cuts both ways:
//  a free tile must actually be free of the sell.
//
//  So this answers the question completely at the level somebody asks it at
//  34 weeks: what the options are, what each actually feels like, what it costs
//  in an Indian hospital, and what to decide now versus on the day. The class
//  goes deeper. Neither sentence below exists to make you buy it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE VOICE RULE, WHICH THIS AREA STATES MOST STRONGLY
//  ---------------------------------------------------------------------------
//
//  *"Every line the user reads is spoken TO her, warmly, like an app talks to a
//  person, NEVER like a legal notice or company copy."*
//
//  Practically, on a subject like this: no "it is recommended that", no "may be
//  associated with", no hedging a real answer into uselessness. Where the
//  honest answer is "it depends on your hospital", say that.
//
//  ⚠️ AND NO DECISION IS MADE FOR HER. Pain relief in labour is the most
//  judged choice in pregnancy, in both directions, and an app taking a side
//  here would be taking it from someone who is going to be in pain and outnumbered
//  in the room. Every option below is described as what it is, not as what a
//  sensible person would pick.
//
//  ⚠️ "C-section" IS KEPT — the brief says so, and it is the word people use —
//  paired with a plain line. "Braxton Hicks" appears nowhere: it is a linked
//  page title in Complications, never a label we write.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The labour bracket's hue.
const double _hue = 344;

final List<PvRead> kPregnancyReadsLabour = [
  PvRead(
    id: 'preg_labour_read_pain_relief',
    hue: _hue,
    kicker: _en('Labour prep'),
    title: _en('Pain relief: natural, epidural and C-section'),
    teaser: _en('What each one actually involves, what it costs in an Indian '
        'hospital, and what you can leave until the day.'),

    scaleSetter: _en('There is no brave option and no easy one. Women who plan '
        'an epidural manage without it, women who planned nothing ask for '
        'everything, and both are ordinary. What helps is knowing what is on '
        'the menu before you are in a position to read a menu.'),

    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Labour hurts, and there is a whole spectrum of things that help '
              '— from a hot water bottle to an anaesthetist. Most women use '
              'several, in the order they need them, and very few stick to '
              'whatever they wrote down beforehand.'),
          _en('The one thing worth deciding in advance is not WHICH you want. '
              'It is whether the hospital you have chosen can give you the '
              'options you might want, because that is the question you cannot '
              'answer at 2am.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Ask this at your next visit'),
          body: _en('"Is an anaesthetist available at night and at weekends?" '
              'In many Indian hospitals the honest answer is "usually", and '
              '"usually" is worth knowing before you are in labour.'),
        ),
      ),

      PvReadSection(
        heading: _en('Without medicine'),
        paragraphs: [
          _en('These are not a consolation prize. They are what most women in '
              'the world use, they work best when labour is progressing, and '
              'they can be started the moment it does.'),
        ],
        bullets: [
          _en('Moving and changing position — walking, leaning, rocking, on '
              'all fours. Being upright genuinely helps labour along as well '
              'as helping the pain, which is why lying flat is no longer '
              'routine.'),
          _en('Breathing you have practised. Untrained breathing in labour '
              'tends to become breath-holding, which makes everything worse; '
              'practised breathing is the single most useful thing on this '
              'list and the only one that is free and needs no permission.'),
          _en('Heat — a hot water bottle or a warm compress on the lower back. '
              'Simple and underrated.'),
          _en('Counter-pressure on the lower back from whoever is with you. '
              'This is the main practical thing a partner can do, and it is '
              'the thing they are most often not told about.'),
          _en('Warm water, where a shower is available. Not every Indian '
              'labour room has one; it is worth asking.'),
        ],
        tip: PvReadTip(
          title: _en('Practise the breathing now, not then'),
          body: _en('Whatever you learn about breathing in labour has to be '
              'automatic by the time you need it. Ten minutes a week from '
              'around thirty weeks is enough, and it is the highest-return '
              'preparation there is.'),
        ),
      ),

      PvReadSection(
        heading: _en('An epidural'),
        paragraphs: [
          _en('An injection into the space around the nerves in your lower '
              'back, giving continuous relief through a fine tube for as long '
              'as you need it. It is the most effective pain relief there is '
              'in labour, and in most Indian city hospitals it is available if '
              'an anaesthetist is on site.'),
          _en('What it is actually like: you sit or lie curled forward and '
              'have to stay still through a contraction or two while it goes '
              'in. There is a local anaesthetic first, so it stings rather '
              'than hurts. It takes fifteen to twenty minutes to work fully.'),
          _en('What changes afterwards: your legs feel heavy and you will '
              'usually stay in bed, often with a catheter and continuous '
              'monitoring of the baby. Some women find the loss of movement a '
              'bigger deal than they expected; others sleep for the first time '
              'in a day and arrive at pushing with something left.'),
          _en('The honest costs: a headache afterwards in a small number of '
              'cases, a longer pushing stage on average, and more chance of '
              'needing help with forceps or a vacuum. It does not increase the '
              'chance of a C-section, which is the belief most worth '
              'correcting here. Backache afterwards is very common in general '
              'and is not caused by the epidural.'),
        ],
        mythFact: PvMythFact(
          myth: _en('An epidural means you are more likely to end up with a '
              'C-section.'),
          fact: _en('It does not. Large reviews of the evidence find no '
              'increase in caesarean births with an epidural. It does make an '
              'assisted delivery — forceps or vacuum — somewhat more likely, '
              'and it lengthens the pushing stage a little. Those are real '
              'trade-offs; a C-section is not one of them.'),
        ),
      ),

      PvReadSection(
        heading: _en('What it costs in India'),
        paragraphs: [
          _en('Prices vary as much as everything else does, and the figure is '
              'usually quoted on top of the delivery package rather than '
              'inside it.'),
          _en('An epidural typically adds somewhere between ₹8,000 and '
              '₹25,000 in a private hospital, depending on the city and the '
              'anaesthetist\'s fee. In a government hospital it is generally '
              'free where it is offered at all, and availability is the '
              'limiting factor rather than cost.'),
          _en('Ask for it in writing as part of your delivery estimate. "Is '
              'the epidural included?" is a question with two very different '
              'answers, and the time to hear which one applies is now.'),
        ],
      ),

      PvReadSection(
        heading: _en('If it becomes a C-section'),
        paragraphs: [
          _en('A C-section is an operation to deliver the baby through a cut '
              'in your abdomen and womb, rather than through the vagina. It is '
              'planned in advance for some pregnancies and decided during '
              'labour for others.'),
          _en('Nearly all are done awake, with a spinal injection that numbs '
              'you from the chest down — similar to an epidural but a single '
              'dose that works faster. You are awake for the birth, your '
              'partner can usually be there, and you can usually hold the baby '
              'soon afterwards. A general anaesthetic is reserved for genuine '
              'emergencies.'),
          _en('Afterwards you have a wound, and pain relief is managed with '
              'tablets and sometimes an injection for the first day or two. '
              'Recovery is longer than after a vaginal birth and you will be '
              'told not to lift anything heavier than the baby for a while.'),
          _en('It is worth saying plainly: needing one is not a failure of '
              'anything, and it is not something you talked yourself into by '
              'asking for pain relief. India has a high caesarean rate in '
              'private hospitals, which is a real conversation to have with '
              'your own doctor about your own pregnancy — and a different '
              'conversation from this one.'),
        ],
      ),

      PvReadSection(
        heading: _en('What to decide now, and what to leave'),
        collapsible: true,
        summary: _en('Three things now. Everything else on the day.'),
        paragraphs: [
          _en('Decide now: which hospital, whether an anaesthetist is there at '
              'night, and who is coming with you and what you want them to '
              'do. All three are hard to change later and all three shape what '
              'is actually available to you.'),
          _en('Leave until the day: whether you want an epidural. You cannot '
              'know, nobody can, and deciding firmly in advance mostly creates '
              'something to feel bad about. "I would like to try without, and '
              'I will ask if I want it" is a complete plan.'),
          _en('And tell whoever is with you what you want them to say if you '
              'ask for something. Some women want to be encouraged to keep '
              'going; some want to be taken seriously immediately. Your '
              'partner cannot guess which you are in the moment.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor if'),
      body: _en('Your waters break, you have any bleeding, the baby is moving '
          'less than usual, or you have a bad headache with blurred vision — '
          'whatever your contractions are doing. And if something feels wrong '
          'and is not on any list, call anyway.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Is it too late for an epidural if I am already far '
            'along?'),
        answer: _en('Usually not, though there is a point near the very end '
            'where there is no time for one to work. Ask as soon as you think '
            'you might want it rather than waiting to be sure — you can always '
            'change your mind while they set up.'),
      ),
      PvReadFaq(
        question: _en('Will it hurt the baby?'),
        answer: _en('Very little of the medicine reaches the baby. Babies are '
            'occasionally a bit sleepy at first, and it is watched for. This '
            'is one of the most studied interventions in medicine.'),
      ),
      PvReadFaq(
        question: _en('What if the hospital says no?'),
        answer: _en('Usually it means no anaesthetist is free right then '
            'rather than a refusal. Ask what else they can offer and ask again '
            'later. If it matters a great deal to you, it is a reason to '
            'choose the hospital on that basis in the first place.'),
      ),
      PvReadFaq(
        question: _en('My family thinks pain relief is unnecessary.'),
        answer: _en('That is common and it is not medical advice. This is your '
            'labour and your body, and nobody who is not in the room gets a '
            'say. Your doctor will support whatever you decide on the day.'),
      ),
    ],

    evidence: _en('Cochrane reviews of epidural versus non-epidural analgesia '
        'in labour · NICE guideline CG190, intrapartum care · FOGSI good '
        'clinical practice recommendations on labour analgesia · Private '
        'hospital rate cards sampled September 2026.'),

    readNext: ['preg_cond_read_less_movement', 'preg_cond_read_bleeding'],
  ),
];
