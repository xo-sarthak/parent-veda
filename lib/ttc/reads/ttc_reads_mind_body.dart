// =============================================================================
//  Mind & body — the reads for this door
// -----------------------------------------------------------------------------
//  ⚠️ ONE FILE PER BRACKET, SO FIVE PEOPLE CAN BUILD FIVE DOORS AT ONCE.
//
//  These all lived in `ttc_reads_data.dart`, which reached 5,992 lines and one
//  closing bracket that every new article in the stage had to be appended to.
//  That is fine with one person and a merge hazard with several: every door
//  build inserts at the same byte position, so every pair of them conflicts,
//  and the failure mode in a content file is not a compile error — it is an
//  article quietly lost in a resolution.
//
//  Splitting by bracket makes the collision surface one line in the aggregator
//  rather than the whole library. It also means the file you open to add a PCOS
//  article contains PCOS articles and nothing else.
//
//  ⚠️ THE AGGREGATOR IS STILL THE ONLY PUBLIC ENTRY POINT. Nothing outside
//  `ttc_reads_data.dart` should import this file — `kTtcReads`, `ttcReadById`
//  and `ttcReadTitle` stay where they were, so no call site changed and the
//  shape and clinical tests still scan every read.
//
//  The rules these are written under are stated once, in the aggregator's
//  header. Read that before adding one.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, ON PURPOSE. Sharing one public helper
// would mean renaming `_en` at well over a thousand call sites for no gain; one
// line per file keeps every article body byte-identical to what it was, which
// is what makes this split reviewable as a move rather than as a rewrite.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsMindBody = [
  // ===========================================================================
  //  MIND & BODY — "stress & fertility"
  // ===========================================================================
  //  Excel Content cell: "Stress & fertility, meditation, preconception garbh
  //  sanskar." Three topics, two reads — meditation is not a subject of its own
  //  here, it is the practice this piece argues for and the one `ttc_ritual`
  //  already delivers daily.
  //
  //  ⚠️ THE MOST DAMAGING SENTENCE IN THIS WHOLE STAGE IS "JUST RELAX AND IT
  //  WILL HAPPEN", and this read exists to take it apart. It is said with
  //  affection, by mothers and sisters-in-law and colleagues, and it does two
  //  things at once: it makes her responsible for an outcome she does not
  //  control, and it makes her failure to conceive evidence that she is not
  //  calm enough. There is no version of that which helps.
  //
  //  ⚠️ AND THE HONEST ANSWER DOES NOT REQUIRE PRETENDING PRACTICE IS USELESS.
  //  The argument below is that a daily practice is worth doing because it
  //  makes the waiting bearable — which is a complete reason on its own and
  //  does not need to be propped up with a pregnancy rate it cannot support.
  //  That framing is also the only one compatible with CLAUDE.md's ban on
  //  personalised probability.
  PvRead(
    id: 'ttc_read_stress_fertility',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('Stress, and the thing everyone says about it'),
    teaser: _en('What the evidence shows, why "just relax" is wrong and '
        'unkind, and what a daily practice is really for.'),
    shortAnswer: _en("Everyday stress doesn't stop you getting pregnant. Very "
        'severe, long-lasting stress can delay ovulation, and so your period, '
        "but ordinary worry isn't why it hasn't happened yet. A daily practice "
        "is worth doing because it makes the wait easier, not because it's a "
        'fertility treatment.'),

    scaleSetter: _en("Everyday stress doesn't stop you getting pregnant. The "
        'largest studies find that feeling upset before treatment does not '
        "decide whether it works. So if you've been wondering whether your "
        "worry is the reason, it isn't."),

    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    heroVideoSlot: 'ttc_vid_stress_fertility',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Almost everyone trying to conceive has been told to relax. '
              "It's usually said kindly. It's also one of the more hurtful "
              'things a person can say.'),
          _en('It does two things at once. It makes you responsible for '
              "something you can't control. And it turns every month that "
              "doesn't work into proof that you weren't calm enough."),
          _en("That second part is why it sticks. After a while you're "
              'anxious '
              "about being anxious, and it's very hard to think your way out "
              'of that on your own.'),
        ],
      ),

      PvReadSection(
        heading: _en('What does the evidence say?'),
        paragraphs: [
          _en('The evidence is mixed. The honest summary is more comforting '
              'than the old sayings.'),
          _en('The biggest piece of it is a review of fourteen studies with '
              'more than three and a half thousand women. It found that '
              "emotional distress before treatment wasn't linked to whether "
              'fertility treatment worked.'),
          _en('Another study measured stress and the stress hormone cortisol '
              'directly. Neither was linked to embryo quality or pregnancy '
              'rate.'),
          _en('Some studies do find a link, usually with severe or '
              'long-lasting anxiety rather than everyday worry.'),
          _en('So a fair way to see it is this. Extreme, long-term stress is a '
              'real health '
              'problem, and worth treating for its own sake. The everyday '
              "strain of trying isn't why it hasn't happened yet."),
        ],
        mythFact: PvMythFact(
          myth: _en('Stop thinking about it and it will happen.'),
          fact: _en('People get pregnant while grieving, during exams, in war '
              'zones and in the worst months of their lives. Conception '
              "doesn't wait for a calm mind. And the couples told this most "
              "often are the ones who've been trying longest. For them, it's "
              'the least likely reason of all.'),
        ),
      ),

      PvReadSection(
        heading: _en('When does stress have a real effect?'),
        paragraphs: [
          _en("There's one honest exception, and it's worth naming. Leaving "
              'it out would make this page a comfortable half-truth.'),
          _en('Severe stress that goes on for a long time can stop ovulation. '
              'The body senses a long threat and turns down the hormone '
              'signals that run your cycle.'),
          _en("That's why cycles can get longer "
              'or stop during grief, serious illness, extreme weight loss or a '
              "real crisis. That's a big effect, and it looks nothing like the "
              'everyday worry this page is about.'),
          _en('Stress also affects the things around conception, even when it '
              "doesn't affect conception itself: sleep, appetite, how often "
              'you have sex, and whether either of you can face another talk '
              'about it. Those are real, and worth caring for in their own '
              'right.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): the late-period question. Stress
      // works before ovulation, so it moves a period by moving ovulation; the
      // test comes first, and a pattern goes to a doctor.
      PvReadSection(
        heading: _en('How long can stress delay a period?'),
        paragraphs: [
          _en('Stress acts on the part of your cycle that comes before '
              'ovulation. If a very hard stretch delays ovulation, your period '
              'comes later by about the same number of days. That can be a few '
              'days, and sometimes a week or two.'),
          _en('Once ovulation has happened, the second half of the cycle '
              'usually runs to its normal length. So stress in the days just '
              'before a period rarely moves it much. Everyday stress, like a '
              'busy week, seldom shifts a period at all.'),
          _en("When a period is over a week late and you've had sex, take a "
              'pregnancy test first. If periods keep coming very late, '
              "or stop for three months or more, it's worth telling a doctor. "
              'Several causes look the same from the outside.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): the signs of stress, and when
      // ordinary tension has become constant enough to talk to someone.
      PvReadSection(
        heading: _en('How do you know stress is building up?'),
        paragraphs: [
          _en('Stress often shows in the body and in habits before you name '
              'it. A few of these in a hard month are normal.'),
        ],
        bullets: [
          _en("Sleep that won't come, or waking early with your mind racing."),
          _en('Headaches, a tight jaw or shoulders, or an upset stomach.'),
          _en('Snapping at people, or crying more easily than usual.'),
          _en('Checking symptoms, forums or charts over and over.'),
          _en('Avoiding friends, baby showers or family calls you used to '
              'manage.'),
          _en('Eating, drinking or scrolling more to switch off.'),
        ],
        tip: PvReadTip(
          title: _en('When to talk to someone'),
          body: _en("If these have become most days for a few weeks, and you "
              "feel on edge all the time, it's worth talking to someone. "
              "That isn't weakness. Tension that never switches off is tiring, "
              'and a psychologist can help it ease.'),
        ),
      ),

      PvReadSection(
        heading: _en('So what is a daily practice for?'),
        paragraphs: [
          _en("Not to make it happen. It's worth being clear about that. A "
              'practice sold as a fertility treatment soon becomes one more '
              "thing you feel you're failing at."),
          _en('Mind-body programmes, like breathing, mindfulness, yoga and '
              'talking therapy such as CBT, reliably help people feel better '
              'while they wait. That finding holds across studies. Whether '
              "they change pregnancy rates hasn't been clearly shown, and it "
              "doesn't need to be."),
          _en('Making a long wait easier to bear is a full reason to do '
              "something. It's also the one result you can change yourself. "
              'After a year of trying, that counts for something.'),
        ],
        tip: PvReadTip(
          title: _en('Five minutes, and not as a target'),
          body: _en('Whatever you choose, keep it short enough that missing a '
              'day costs nothing. A calming practice most often turns '
              'stressful when it becomes a streak: one more thing to keep up, '
              'and one more thing to break. If you skip three days, you '
              "haven't lost anything."),
        ),
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): the "natural boosters" she hears
      // about. What the trials found, said plainly, without sneering at
      // anyone who finds a therapy relaxing.
      PvReadSection(
        heading: _en('Do acupuncture or hypnosis help?'),
        paragraphs: [
          _en("You'll hear about acupuncture, hypnotherapy, reflexology and "
              'many other therapies. For most of them, good trials have not '
              'shown that they help people get pregnant.'),
          _en('Acupuncture has been studied the most, mainly alongside IVF. '
              'The larger, better trials found no difference in live births. '
              'NICE does not recommend it for fertility for that reason.'),
          _en('Some people still find a therapy relaxing, and feeling better '
              'is a fair reason to use one. Choose a qualified practitioner, '
              "keep the cost in proportion, and don't let it delay medical "
              'checks. Tell your doctor about any herbs that come with it.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Useful, practical, and not the argument.
        collapsible: true,
        summary: _en('What to say to people who keep offering this advice, '
            'and how to protect the two of you from it.'),
        heading: _en('The people around you'),
        paragraphs: [
          _en("In most Indian families, this isn't a private matter. The "
              "advice comes all the time. It's kindly meant, and it never "
              'stops. The strain it causes is often bigger than anything '
              'medical.'),
          _en('A few things help. Agree with your partner what you will share '
              "and what you won't, before the next family gathering, not "
              'during it.'),
          _en('Have one short sentence ready that ends the topic '
              "without a fight. \"We're seeing someone about it, and we'll "
              "tell you when there's news\" closes most conversations. And "
              "decide ahead of time who's allowed to ask. It's usually a much "
              'shorter list than the people asking now.'),
          _en("None of this is rude. Protecting the two of you from comments "
              'is a fair thing to do. Without it, you can end up dreading '
              'every phone call.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('So should I stop trying to relax?'),
        answer: _en('Stop treating it as a task with a result attached. Rest, '
              "breathing and calm are good for you anyway, and that's the "
              "reason to do them. What's worth letting go of is the idea that "
              "you're doing them to get pregnant. That idea turns every month "
              "that doesn't work into a failure to relax."),
      ),
      PvReadFaq(
        question: _en('My periods stopped during a very stressful year. Was '
            'that stress?'),
        answer: _en('It may well have been. Severe, long-lasting stress can '
            'stop ovulation, and cycles stopping during a crisis is a known '
            "pattern. That's different from everyday worry. It's worth "
            'getting it checked rather than assuming, because several other '
            'causes look the same.'),
      ),
      PvReadFaq(
        question: _en('Does his stress matter?'),
        answer: _en('Long-lasting stress can affect sperm and testosterone. It '
            'also affects the same everyday things it does for you: sleep, '
            'drinking, and whether either of you has any energy for this. '
            "It's talked about far less, mostly because men are asked about "
            'it far less.'),
      ),
      PvReadFaq(
        question: _en('Is anxiety medication safe while trying?'),
        answer: _en('Several options are thought to be fine while trying to '
            'conceive and during pregnancy. This is a talk to have with the '
            'person who prescribes it, not something to settle from an '
            "article. What's worth knowing is that stopping suddenly because "
            "you're trying has its own risk. Untreated illness isn't as safe "
            'an option as it can seem.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When this is more than the strain of waiting'),
      body: _en('Talk to someone if low mood or anxiety has lasted more than a '
          "couple of weeks, if you can't sleep or can't cope at work, if "
          "you've stopped seeing people, if your cycles have stopped, or if "
          "you're drinking more to get through it. And talk to someone today, "
          'not at the next appointment, if you have thoughts of harming '
          "yourself. None of this means you've failed to cope. It means the "
          'right help now is a person rather than a practice.'),
    ),

    evidence: _en("The finding that emotional distress before treatment wasn't "
        'linked to fertility treatment outcomes comes from a meta-analysis of '
        '14 studies covering 3,583 women, and from a prospective study that '
        'measured psychological stress and cortisol against embryo quality '
        'and pregnancy rate. The finding that mind-body approaches improve '
        'mental health, with a less consistent effect on pregnancy rates, '
        'comes from meta-analyses of CBT, mindfulness-based stress reduction '
        'and yoga in people with fertility problems. How stress delays '
        'ovulation, and seeing a doctor when periods stop for three months, '
        'follow NICE guidance on fertility problems (CG156) and NHS advice on '
        'missed periods. The finding of no difference in live births with '
        'acupuncture alongside IVF is from a large randomised trial (Smith '
        'and colleagues, JAMA 2018), and NICE CG156 does not recommend '
        'complementary therapies for fertility. Sources checked September '
        '2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en("Today's practice"),
        value: _en('Five minutes. Reflection, breath, conversation and '
            'gratitude, and a missed day costs nothing.'),
        surfaceId: 'ttc_ritual',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Preconception garbh sanskar, honestly'),
        value: _en("What it is, what it doesn't promise, and why it's offered "
            'before conception at all.'),
        surfaceId: 'ttc_read/ttc_read_garbh_sanskar',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a psychologist'),
        value: _en('Someone who works with people going through this same '
            'wait.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_garbh_sanskar', 'ttc_read_trying_takes_over'],
  ),


  // ===========================================================================
  //  MIND & BODY — "preconception garbh sanskar"
  // ===========================================================================
  //  ⚠️ THE HARDEST TONE IN THE LIBRARY, AND IT HAS TWO WAYS TO FAIL.
  //
  //  Write it as devotion and it promises things about a baby who does not
  //  exist yet, which is both dishonest and — per CLAUDE.md — forbidden.
  //  Write it as debunking and it sneers at a practice that matters to a great
  //  many of the families this product is built for, in their own language,
  //  about their own tradition.
  //
  //  The line taken: describe it accurately, say plainly what it is good for
  //  (her, now), say plainly what it does not claim (an outcome), and let the
  //  reader decide what it means to her. The workbook's own US-subset column
  //  says "Reframed (secular calm / mind-body prep)" — so the secular reading
  //  is not a hedge invented here, it is the product's stated position.
  //
  //  ⚠️ NO OUTCOME CLAIMS OF ANY KIND. Not conception, not the baby's
  //  temperament, not intelligence. `test/ttc_clinical_review_test.dart` scans
  //  this source.
  PvRead(
    id: 'ttc_read_garbh_sanskar',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('Preconception garbh sanskar, honestly'),
    teaser: _en("What the tradition says, what it's good for, and what it "
        "doesn't claim. It's also for people who want the practice without "
        'the belief.'),
    shortAnswer: _en('Garbh sanskar is an Indian tradition of small daily '
        'practices for both parents, started before conception. It will not '
        'make a pregnancy happen, and it makes no promise about a baby. What '
        'it can do is give the wait a calm daily shape, for both of you.'),

    scaleSetter: _en('Garbh sanskar is a way to prepare, not a way to '
        'conceive. Nothing in it will make a pregnancy happen, and it '
        "doesn't need to. What it offers is a way to spend the wait that "
        "calms you rather than wears you down. That's a real thing to be "
        'offered.'),

    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    heroVideoSlot: 'ttc_vid_garbh_preconception',

    sections: [
      PvReadSection(
        heading: _en('What is garbh sanskar?'),
        paragraphs: [
          _en('Garbh sanskar roughly means teaching or caring for the womb. '
              'It comes from Ayurveda and wider Indian tradition. In its '
              "classic form, it's a set of practices for the parents: food, "
              'routine, music, reading, behaviour and stillness. They start '
              'before conception and carry on through pregnancy.'),
          _en('Most people come across the pregnancy version. The version '
              'before conception is older, and it may be the half that makes '
              'more sense. The tradition says getting ready starts with the '
              'parents, not with the pregnancy. Modern medicine for the months '
              'before pregnancy happens to agree, for very different '
              'reasons.'),
          _en("At its simplest, it's a daily practice with four or five parts, "
              'done regularly by both partners. We describe it plainly on '
              "purpose. That's what the practice is, whatever you believe "
              'about it.'),
        ],
      ),

      PvReadSection(
        heading: _en('What is it good for?'),
        paragraphs: [
          _en("You, now. That's the honest answer, and it isn't a small "
              "one. It's about how you feel today, while you wait, and not "
              "about a baby who isn't here yet."),
          _en('A daily practice gives shape to a time that otherwise has '
              'none. Trying to conceive can mean months of waiting with almost '
              'nothing to do.'),
          _en('Having something small of your own to do each '
              'day really does protect you. The evidence on mind-body practice '
              'backs exactly this: it reliably helps mental health through a '
              'hard time.'),
          _en("It's also one of the few things here that you can both do "
              'together without it being about performance or timing. By '
              'about month eight, that matters more than it sounds, for both '
              'of you.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("And if you're not religious"),
          body: _en('The practice works without the belief. Its parts are '
              'breath, stillness, music, reading aloud, gratitude and '
              'conversation. None of them needs faith, and the tradition cares '
              'more about what you do each day than what you believe. Take it '
              'as mind-body preparation if that fits you. It loses nothing '
              'that way.'),
        ),
      ),

      PvReadSection(
        heading: _en("What doesn't it claim?"),
        paragraphs: [
          _en("It won't make you conceive, and no honest teacher says "
              "otherwise. If something you're offered promises conception, "
              'that promise was added by whoever is selling it.'),
          _en("It also makes no claim we'd repeat about a child who doesn't "
              'exist yet.'),
          _en("You'll find material, a lot of it online and some "
              'of it sold for a lot of money, saying that certain practices '
              'before conception decide a baby’s intelligence, temperament or '
              "character. There's no evidence for that, and we won't tell you "
              'there is.'),
          _en("What's left once those claims are gone is still worth having. "
              "That's why we wrote this down."),
        ],
        mythFact: PvMythFact(
          myth: _en('Doing it properly shapes what your child will be '
              'like.'),
          fact: _en("There's no evidence that practices before conception "
              'shape a child’s intelligence or personality. What the '
              'tradition can fairly claim, and what modern care before '
              'pregnancy agrees with, is that the parents’ health and state '
              'of mind before conception are worth looking after. That is a '
              "much smaller claim, and it's the one that holds up."),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Practical detail for someone who has decided to do it, and
        // clutter for someone still working out what it is.
        collapsible: true,
        summary: _en('The five parts, what each is for, and how long it '
            'takes.'),
        heading: _en('What does a daily practice look like?'),
        paragraphs: [
          _en('Short. Five to fifteen minutes. Doing it regularly matters far '
              'more than how long it lasts, and almost every version of this '
              'agrees on that.'),
        ],
        bullets: [
          _en('Reflection: one thought or reading to sit with. Not analysis, '
              "and not journalling unless you'd like it to be."),
          _en('Breath: a few minutes of slow breathing. This is the part with '
              'the most direct evidence behind it for calming the nervous '
              'system.'),
          _en('Sound: music, chanting or reading aloud, whichever you find '
              'settling.'),
          _en('Conversation: one honest talk between the two of you that '
              "isn't about timing, tests or money."),
          _en("Gratitude: short, specific and not for show. It's the part most "
              'likely to feel forced at first, and the part you will most '
              'likely miss once it stops.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): how to begin, and how it sits
      // beside medical care. The second is the safety half: herbs, fasts and
      // any teacher who says to stop treatment.
      PvReadSection(
        heading: _en('How do you start?'),
        paragraphs: [
          _en('Start with one part, like five minutes of slow breathing '
              'before bed, and add the others when it feels natural. Tie it to '
              'a time you already have, such as after your morning tea.'),
          _en("If you'd like a guide, the free course in this app teaches it "
              'over eight short sessions, for both of you. A missed day costs '
              'nothing.'),
        ],
      ),
      PvReadSection(
        heading: _en('Can it sit alongside medical care?'),
        paragraphs: [
          _en('Yes, and it should. A daily practice and fertility care do '
              'different jobs, and neither replaces the other. Keep taking '
              'folic acid, keep your appointments, and keep to any plan your '
              'doctor has made.'),
          _en('Some garbh sanskar courses also recommend herbal mixes, special '
              'ghee preparations or fasts. Tell your doctor about any of these '
              'before you start. Some herbs interact with fertility medicines, '
              'and long fasts can unsettle a cycle.'),
          _en('If a course or teacher tells you to stop a medicine or skip '
              'treatment, leave the course, not the treatment.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Is there any scientific evidence for garbh sanskar?'),
        answer: _en("For the practice as a whole, no. It hasn't been studied "
            'as a package, so be careful with claims that it has. For its '
            'parts, yes: breathing, meditation and yoga have fair evidence for '
            'easing distress. So the honest view is that the parts are '
            'supported, but the promises sometimes attached to the whole are '
            'not.'),
      ),
      PvReadFaq(
        question: _en('Do both of us need to do it?'),
        answer: _en('The tradition says yes, and here tradition and the '
            'practical answer agree. A practice one person does alone becomes '
            "one more thing you're carrying. A practice you both do together "
            "is a rare part of this stage that's shared without being about "
            'performance.'),
      ),
      PvReadFaq(
        question: _en('Should I be following a particular diet for it?'),
        answer: _en('Classic garbh sanskar includes food advice, and much of '
            "it is ordinary: regular meals, fresh food, and less that's heavy "
            'or highly processed. If it starts asking for expensive '
            "preparations or banning everyday foods, it's worth questioning. "
            'Our nutrition advice is separate, and based on evidence for the '
            'months before pregnancy rather than on tradition.'),
      ),
      PvReadFaq(
        question: _en("We've been trying a long time. Is it too late to "
            'start?'),
        answer: _en('No. Nothing in it needs you to be at a certain point. '
            "It's a way of spending the wait, so it can help however long "
            "you've been waiting."),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("When a practice isn't the right answer"),
      body: _en('Nothing here replaces medical care, and it should never be a '
          'reason to put it off. See a doctor instead of waiting if your '
          "cycles are irregular or missing, if you've been trying for a year "
          "(six months if you're 35 or over), or if you have a known "
          'condition. And talk to a person, not a practice, if the waiting has '
          "turned into low mood or anxiety you can't put down. Be extra "
          'careful with anyone offering garbh sanskar instead of fertility '
          "treatment. The tradition itself doesn't claim that."),
    ),

    evidence: _en('Our description of garbh sanskar follows classical '
        "Ayurvedic and Indian tradition as it's commonly practised, rather "
        'than any single text. Evidence for its parts (breathing practice, '
        'meditation and yoga improving mental health in people with fertility '
        'problems) comes from meta-analyses of mind-body approaches. We know of '
        "no controlled evidence for the practice as a whole, and we don't "
        'claim any here. Folic acid before conception follows WHO and NHS '
        'advice, and the caution on herbal products reflects their known '
        'interactions with medicines. Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.course,
        title: _en('The free preconception garbh sanskar course'),
        value: _en('Eight short sessions, for both of you, with no fee. The '
            'practice taught properly, not just described.'),
        // Was 'ttc_prepare' — the catalogue the course is LISTED in, not the
        // course. See the note on the door's Go deeper tile.
        surfaceId: 'ttc_garbh_course',
      ),
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en("Today's practice"),
        value: _en('The five parts, ready for you. Five minutes.'),
        surfaceId: 'ttc_ritual',
      ),
    ],

    readNext: ['ttc_read_stress_fertility'],
  ),

  // ===========================================================================
  //  MIND & BODY — the four guides the rebuild adds
  // ===========================================================================
  //  ⚠️ THESE FOUR ARE THE ONLY NEW PROSE IN THE AREA, AND THEY HAVE NOT HAD A
  //  CLINICAL READ. The rebuild brief marks eleven cards `reuse` or `promote`
  //  and nine `reference` — all of those point at writing that already exists
  //  and was already reviewed. Only these four are marked `new`, and the byline
  //  below is inherited from the door rather than earned on them. Same standing
  //  debt as the Getting ready and His side batches; see `docs/STILL-OPEN.md`.
  //
  //  ⚠️ THE SLEEP PIECE IS THE ONE TO WATCH. "Why sleep matters when you are
  //  trying" is one careless sentence away from a fertility claim, and the
  //  claim would be the exact thing the area's position note refuses. What the
  //  evidence supports is narrow — sustained shift work and very short sleep
  //  are ASSOCIATED with cycle irregularity — and it is stated as narrowly as
  //  that, with the honest reason for caring about sleep put first: it is what
  //  everything else in a hard month rests on.

  PvRead(
    id: 'ttc_read_sleep_trying',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en("Why sleep matters when you're trying"),
    teaser: _en('Not because it makes conception happen. Because everything '
        "else you're trying to do gets harder without it."),
    shortAnswer: _en("Short sleep doesn't stop you getting pregnant. Sleep "
        'matters because every other healthy habit is easier on seven hours '
        'than on four. A steady wake-up time and daylight in the morning help '
        'most.'),

    scaleSetter: _en("Short sleep doesn't stop you getting pregnant, and "
        'nobody should add it to their list of things they are doing wrong. '
        "It's here because sleep is what every other habit rests on. It's "
        'also one of the few things in all this you can change this week.'),

    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Sleep advice arrives at this time of life like every other bit '
              "of advice: as one more thing you're probably failing at."),
          _en("So let's say at the start what this page isn't doing. It "
              "isn't saying your sleep is the reason. And it isn't giving you "
              'eight '
              'hours as a target to miss and then feel bad about.'),
          _en("It's here for a simpler reason. Almost everything else this "
              'area suggests is much harder on four hours than on seven: '
              'moving a bit, eating at home, staying patient with family, '
              "wanting your partner close. Sleep isn't one habit among many. "
              "It's the one the others rest on."),
        ],
      ),

      PvReadSection(
        heading: _en('What does the research show?'),
        paragraphs: [
          _en('The honest summary is narrower than most articles suggest. '
              'Long-term night-shift work and very short sleep, night after '
              'night, have been linked to more irregular cycles in large '
              'studies.'),
          _en('But linked is the key word. Those studies cannot '
              'separate the sleep from the stress, the light, the meal times '
              'or the job that comes with all four.'),
          _en("What hasn't been shown is that a normal run of late nights "
              'changes whether a healthy couple conceives. If you have been '
              "sleeping badly because of the worry, that's a result of what "
              "you're going through, not a cause of it."),
          _en("There's one exception worth knowing, not worrying, about. If "
              'your cycles have become irregular or stopped during a long '
              'stretch of shift work or badly broken sleep, show a doctor.'),
          _en('Not '
              'because sleep is surely the cause, but because irregular cycles '
              'have several causes and they look the same from the outside.'),
        ],
      ),

      PvReadSection(
        heading: _en('How does sleep shape the next day?'),
        paragraphs: [
          _en('Sleep sets up the next day, and the next day is where all of '
              'this happens. Tired people eat differently: more sugar, later, '
              "and less of what they'd planned."),
          _en('Tired people move less. Tired '
              'people drink a bit more in the evening to wind down. And tired '
              "people find it much harder to let a relative's remark go "
              'without it spoiling the afternoon.'),
          _en('None of that is a moral failing, and all of it is predictable. '
              'If you change nothing else this month, fixing the time you go '
              'to bed will help four other things without you having to think '
              'about any of them.'),
        ],
      ),

      PvReadSection(
        heading: _en("Why is sleep harder while you're trying?"),
        paragraphs: [
          _en('Trying to conceive affects sleep in a way ordinary sleep '
              "advice doesn't cover. The waiting happens at night. The two "
              'weeks after ovulation, the night before a test, the night after '
              'a period comes: these are when the thoughts get loudest, and '
              'they come on a schedule.'),
          _en("So bad sleep here often isn't a habit problem at all. It's "
              'grief and the waiting turning up at eleven at night, because '
              "that's the first moment of the day with nothing else in it."),
          _en("Sleep tips won't touch that. What usually helps is having "
              'somewhere else to put the thoughts: a talk, something written '
              'down, or a practice that gives your mind one small thing to '
              'hold instead.'),
        ],
      ),

      // ⚠️ THE BRIEF'S OWN CLOSING SECTION, AND IT WAS MISSING. *"This is not
      // only her."* The FAQ below covered his sleep, which is not the same
      // thing: a question at the foot of the page is something you go looking
      // for, and the point of this section is that she should not have to.
      PvReadSection(
        heading: _en('Both of you'),
        paragraphs: [
          _en("This isn't only about you. Sleep affects sperm production too, "
              'through the same hormone rhythm, and men get asked about it far '
              'less than women do.'),
          _en("It's also the practical reason to do it together. A fixed "
              'bedtime is much easier to keep when you both keep it, and '
              'almost impossible when one of you is still up with the TV '
              'on.'),
        ],
      ),

      PvReadSection(
        heading: _en("What's worth trying?"),
        bullets: [
          _en('Pick a bedtime, but hold the wake-up time, not the bedtime. The '
              'time you get up is what moves your body clock.'),
          _en('Get outside in daylight in the first hour or two after you '
              'wake, even for a few minutes. This does more than anything you '
              'can do at night.'),
          _en('Stop searching at a set time. Forums and symptom checking after '
              'ten at night have never helped anyone sleep.'),
          _en("If you're lying awake for more than twenty minutes, get up and "
              'sit somewhere dim until you feel sleepy. Staying in bed teaches '
              'you that bed is where you think.'),
          _en("Don't catch up on lost sleep at the weekend by four hours. One "
              "hour is fine. Four resets the clock you've just built."),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('I work nights. Is that a problem?'),
        answer: _en("It's worth telling your doctor, especially if your cycles "
            'are irregular, because shift work is one of the few sleep '
            "patterns with a real link in the research. It isn't a reason to "
            "leave your job, and nobody can tell you it's why this is taking "
            'time. On the days you are not on shift, keeping light and meals '
            'to a steady pattern helps more than trying to sleep like a day '
            'worker.'),
      ),
      PvReadFaq(
        question: _en('Is a sleeping tablet safe while trying?'),
        answer: _en("That's a question for whoever would prescribe it. It's a "
            'fair thing to ask, and nothing to feel bad about needing. It is '
            'worth knowing that sleep aids from the chemist and herbal '
            "products aren't safer just because nobody prescribed them. "
            "Several haven't been studied in people trying to conceive, and "
            "unstudied isn't the same as safe."),
      ),
      PvReadFaq(
        question: _en('Does his sleep matter too?'),
        answer: _en('The same practical reasons apply to him, and men get asked '
            'about it far less. Long-term poor sleep is linked to lower '
            'testosterone. It also affects everything around this in the same '
            'way it does for you: drinking, mood, and whether either of you '
            'has any energy for it all.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When poor sleep needs a doctor'),
      body: _en("See a doctor instead of trying harder if you haven't been "
          'able to sleep for more than two or three weeks, if you wake very '
          "early every morning and can't get back to sleep, if you're "
          'exhausted all day even after enough time in bed, if your partner '
          'has noticed you stop breathing or gasp in your sleep, or if you have '
          'been drinking to get to sleep. And talk to someone today, not at the '
          "next appointment, if you've had thoughts of harming yourself. Tell "
          'someone you trust as well as a professional.'),
    ),

    evidence: _en('Links between night-shift work, very short sleep and '
        'irregular periods come from large observational studies, which '
        "can't prove cause. We don't claim that normal changes in sleep "
        'affect conception, and we know of no evidence that would support '
        'that. The advice on sleep timing follows standard behavioural sleep '
        'practice. Sources checked August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en('Setting a bedtime you can keep'),
        value: _en('The practical half of this, in one short page.'),
        surfaceId: 'ttc_read/ttc_read_bedtime',
      ),
      // His half, and it is the section His side gained in order to be pointed
      // at rather than the nearest article that would have done.
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('His sleep, and the shift work question'),
        value: _en('The same rhythm on his side, and the one thing worth '
            'raising at an appointment.'),
        surfaceId: 'ttc_read/ttc_read_heat_habits',
      ),
    ],

    readNext: ['ttc_read_bedtime', 'ttc_read_stress_fertility'],
  ),

  // ---------------------------------------------------------------------------

  PvRead(
    id: 'ttc_read_bedtime',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('Setting a bedtime you can keep'),
    teaser: _en('Most bedtimes fail for the same three reasons. None of them '
        'is willpower.'),
    shortAnswer: _en('Bedtimes usually fail for practical reasons: the evening '
        'has no clear end, the late hour is your only free time, or bed has '
        'become where you worry. Fix the wake-up time first and move by '
        'fifteen minutes at a time. Keeping it four nights a week counts.'),

    scaleSetter: _en('A bedtime you keep four nights a week is worth more than '
        'a perfect one you give up by Wednesday. Everything below is written '
        "for the tired you who doesn't feel like it, because that's the one "
        'who decides.'),

    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Almost everyone who wants an earlier night has already tried '
              'the obvious thing: decide on eleven, then be in bed at eleven. '
              'It works for a few days and then stops. The usual explanation '
              "is that you didn't want it enough."),
          _en("That explanation is wrong, and it's worth letting go of, "
              "because it's also why people stop trying. Bedtimes fail for "
              'practical reasons. Each of the three has a fix that has nothing '
              'to do with trying harder.'),
        ],
      ),

      PvReadSection(
        heading: _en('Reason one: the evening has no ending'),
        paragraphs: [
          _en("Most late nights aren't a choice to stay up. They happen "
              'because nothing tells you to stop. The day just runs on until '
              "you notice it's half past midnight. Nothing marked the end of "
              'it.'),
          _en("So give the evening an ending that isn't getting into bed. "
              'Something small you repeat at the same time each night: the '
              'kitchen gets tidied, the phone goes to charge in another room, '
              'the main light goes off.'),
          _en("The task itself doesn't matter. What "
              'matters is that something has closed, and everything after it '
              'leads to sleep.'),
        ],
      ),

      PvReadSection(
        heading: _en("Reason two: you're owed an hour"),
        paragraphs: [
          _en('If the whole day went to work, family and everyone else, the '
              "hour after they're asleep is often the only hour that's yours. "
              'Going to bed early means giving it up. No amount of knowing '
              'about sleep makes a person give up the only free hour they '
              'had.'),
          _en("This is the main reason bedtimes fail, and willpower won't fix "
              'it. What works is moving the hour, not deleting it. Take it in '
              'the morning, or earlier in the evening before the day winds '
              "down, so going to bed isn't the end of your own time."),
        ],
      ),

      PvReadSection(
        heading: _en('Reason three: bed became where you think'),
        paragraphs: [
          _en("If you've spent weeks lying in the dark going over cycle dates, "
              'your mind now links bed with thinking. That link forms quickly, '
              "and it doesn't care how tired you are."),
          _en("Breaking it is uncomfortable, but it works. If you're awake and "
              'thinking for more than about twenty minutes, get up. Sit '
              'somewhere dim and dull until you feel sleepy, then go back.'),
          _en('It costs a few bad nights, and it works because it stops '
              'teaching '
              'your body that bed is for lying awake.'),
          _en("Don't check the time while you do this, and don't work out how "
              'much sleep is left. That sum is what turns being awake into '
              "worrying about being awake, and it's how a bad night becomes a "
              'bad week.'),
          _en('Twenty minutes here means about twenty minutes as it '
              'feels, not twenty minutes on a clock.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): what and when to eat in the
      // evening, the small practical addition the gap analysis asked for.
      PvReadSection(
        heading: _en('What and when should you eat in the evening?'),
        paragraphs: [
          _en('Dinner timing moves sleep more than most people expect. A big, '
              'late, spicy or fried meal keeps your stomach busy and can bring '
              'on heartburn when you lie down. Try to finish dinner two to '
              'three hours before bed, and keep it lighter than lunch where '
              'you can.'),
          _en('Tea and coffee last longer than they feel. A cup after about '
              'mid-afternoon can still be working at bedtime, so switch to '
              'something without caffeine after that. Alcohol makes you drowsy '
              'but breaks up sleep later in the night.'),
          _en("If you're hungry at bedtime, something small is better than "
              'lying awake hungry: a glass of warm milk, a banana or a few '
              'nuts.'),
        ],
      ),

      // ⚠️ TWO SECTIONS THE BRIEF CALLS OUT AND THIS GUIDE DID NOT HAVE, and
      // the first of them is the one it describes as *"the part most advice
      // ignores"*. A bedtime page written for somebody living in a flat of two
      // is a bedtime page that does not apply to most of the people reading
      // it here.
      PvReadSection(
        heading: _en('What if you live with family?'),
        paragraphs: [
          _en('Most bedtime advice assumes you run the household. If dinner is '
              'at ten because it always has been, or the TV is on in a room '
              "you have to walk through, a bedtime of your own isn't about "
              "willpower. It's about a schedule you didn't set."),
          _en('What works is being plain, not apologetic. Saying you are both '
              'trying to sleep earlier for your health is true. It needs no '
              "more explanation, and it doesn't invite the follow-up question "
              'that "we\'re trying" always does.'),
        ],
        bullets: [
          _en('Agree a dinner time with whoever cooks, instead of announcing a '
              'bedtime. Dinner is the thing that really moves.'),
          _en('Move the phones out of the bedroom. Nobody else needs to be '
              "involved in that one, and it's the change that helps most."),
          _en("Accept the nights it won't work: a guest, a festival, someone "
              'unwell. Getting closer to a regular time two or three nights a '
              'week is a real improvement.'),
        ],
      ),

      PvReadSection(
        heading: _en('What if one of you works shifts?'),
        paragraphs: [
          _en('A fixed bedtime may not be possible, and pretending it is won\'t '
              'help.'),
          _en('What you can do is keep a steady pattern within each shift '
              'rather than across the week: the same routine before sleep, a '
              'properly dark room if you sleep in the day, and meals at about '
              'the same points in your own day rather than the '
              'household\'s.'),
          _en("Mention the shift work at your next appointment. It's one of "
              'the few sleep patterns with a real link behind it, and doctors '
              'almost never ask about it.'),
        ],
      ),

      PvReadSection(
        heading: _en('What should you change first?'),
        paragraphs: [
          _en('Pick one of these and leave the rest. Five changes tried at '
              'once are usually dropped by the weekend, and the first one '
              'below does most of the work on its own.'),
          _en('It also helps to know roughly how long this takes, because most '
              'people give up just before it starts to work. Shifting your '
              'body clock takes a week or two of steady mornings, not a few '
              'good nights.'),
          _en('The first three or four days usually feel worse, '
              "not better, because you're getting up earlier before you've "
              'started falling asleep earlier. That means it is working, not '
              'failing.'),
        ],
        bullets: [
          _en('Move the wake-up time, not the bedtime. Getting up within the '
              'same half hour every day is what shifts the clock. Your bedtime '
              'follows by itself within a week or two.'),
          _en("Shift by fifteen minutes, not an hour. You'll notice an hour "
              "and push back against it. You won't notice fifteen minutes."),
          _en('Choose your evening ending before you choose your bedtime.'),
          _en("Expect to slip. A bedtime isn't a streak, and nothing here is "
              'counting. Miss three nights and the fourth is no harder than it '
              'would have been.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('We go to bed at different times. Does that matter?'),
        answer: _en('Not for sleep itself. Plenty of couples keep different '
            'hours and are fine. It matters if it means you have stopped '
            'sharing any part of the day. That happens easily during a long '
            "stretch of trying, and it's worth noticing before it becomes "
            'normal.'),
      ),
      PvReadFaq(
        question: _en('What about the phone, honestly?'),
        answer: _en('The blue light is the smallest part of it. The real '
            'problem is that a phone in bed so easily brings the one thing '
            'sure to wake you up this month: a forum, a symptom search, or '
            "someone's pregnancy news. Charging it in another room isn't about "
            "the screen. It's about what's on it."),
      ),
      PvReadFaq(
        question: _en("I'm fine on six hours. Do I need to change?"),
        answer: _en('A small number of people really are. If you wake up '
            "without an alarm and feel rested, you're probably one of them. "
            "The test isn't the number. It's whether you need caffeine to get "
            'through the day, and crash at the weekend.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When this needs more than a routine'),
      body: _en('See a doctor instead of changing your evening if you have '
          "not slept properly for weeks, if you wake very early and can't get "
          'back to sleep, if you sleep enough hours and are still exhausted '
          'all day, or if someone has noticed you stop breathing or gasp at '
          'night. And talk to someone today, not at the next appointment, if '
          'the nights have become a time you have thoughts of harming '
          'yourself.'),
    ),

    evidence: _en('The advice here follows standard practice for insomnia '
        '(a steady wake time, keeping bed for sleep, and shifting slowly), '
        'which is the first approach recommended before medicine. The advice '
        'on meal timing, caffeine and alcohol follows NHS sleep guidance. We '
        'make no claim about sleep and conception. See the companion piece '
        "for what the evidence on that does and doesn't support. Sources "
        'checked September 2026.'),

    readNext: ['ttc_read_sleep_trying', 'ttc_read_stress_fertility'],
  ),

  // ---------------------------------------------------------------------------

  PvRead(
    id: 'ttc_read_family_asking',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('When family keeps asking'),
    teaser: _en('What to say, what you owe them, and how to stop the question '
        'coming every week.'),
    shortAnswer: _en("You don't owe anyone an explanation. Agree with your "
        'partner what you will share, keep one short sentence ready, and say '
        "it the same way every time. It's fine to leave a gathering early, or "
        'to skip some for a while.'),

    scaleSetter: _en("You don't have to explain your body to anyone, even "
        "people who love you. It's worth saying plainly, because most of the "
        'strain here comes from feeling that you do.'),

    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("In most Indian families, this isn't a private matter. The "
              'question comes at weddings, on calls, in kitchens, and from '
              "people who'd be really upset to know they were hurting you. "
              "It's constant and kindly meant, and there's no good answer to "
              "it. That's what makes it so tiring."),
          _en('No sentence will make people stop asking forever. But some '
              'sentences end the conversation without a fight, and a couple of '
              'decisions make the whole thing smaller.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): whether to tell anyone at all,
      // which comes before every decision below it.
      PvReadSection(
        heading: _en("Should you tell anyone you're trying?"),
        paragraphs: [
          _en('Many couples in India keep it private, at least at first, and '
              "that's a perfectly good choice. Others tell one or two people, "
              "a sister or a close friend, so they aren't carrying it alone."),
          _en('Telling people can bring support, and someone to lean on after '
              'a hard month. It can also bring more questions, more advice, '
              "and news that travels further than you'd like."),
          _en('Many couples find a middle way works. Tell one or two people '
              'you trust, and ask them plainly to keep it between you.'),
        ],
      ),

      PvReadSection(
        heading: _en('What should you agree with your partner first?'),
        paragraphs: [
          _en('The most useful thing is to agree ahead of time, before the '
              "next gathering and not during it, what you'll share and what "
              "you won't. Whether anyone knows you're trying. Whether anyone "
              "knows you're seeing a doctor. Whether one set of parents hears "
              'before the other.'),
          _en('Do this early, because most of the hurt happens when one of you '
              'answers for both without knowing what the other wanted said. '
              "That's how a private thing becomes public in one sentence. When "
              "it's never been talked about, it's nobody's fault."),
          _en('It also decides who answers. Agreeing that he answers the '
              'questions put to you, and the questions from his family, takes '
              "a surprising amount of weight off. That's mostly because, in "
              'practice, nearly all the asking is aimed at you.'),
        ],
      ),

      PvReadSection(
        heading: _en('What can you say when someone asks?'),
        paragraphs: [
          _en("The sentence doesn't need to be clever, and it shouldn't open a "
              'debate. It needs to be short, warm enough not to start a fight, '
              'and finished, with nothing left hanging for a follow-up '
              'question.'),
          _en('Decide it ahead of time, because the question never comes at a '
              'good moment. It comes in a room full of people, or in the '
              'middle of something else.'),
          _en('Whatever you say on the spot will be '
              'sharper than you meant, or so vague that it invites a second '
              "question. With a line ready, you don't have to make one up "
              "while you're upset."),
          _en('Say it the same way every time, even to people you like. If '
              'your answer changes with who asked, people compare notes, and '
              'the version someone got is read as how much you trust them.'),
        ],
        bullets: [
          _en('"We\'ll tell you when there\'s news." Warm, closed, and it gives '
              'nothing away.'),
          _en('"We\'re seeing someone about it, and we\'d rather not discuss '
              'it." Works when they already guess, and stops advice without '
              'inviting sympathy.'),
          _en('"That\'s between us. But how are you?" The one that works most '
              'often. People asked about themselves rarely come back to it.'),
          _en('"Please don\'t ask me that again." For the person who has '
              "ignored the other three. You're allowed to say it."),
        ],
      ),

      PvReadSection(
        heading: _en("Who's allowed to ask?"),
        paragraphs: [
          _en('The list of people whose asking really bothers you is usually '
              'much shorter than it feels at three in the afternoon after a '
              'family lunch. Naming them, to yourself or out loud with him, '
              "changes how the next question lands, because you're no longer "
              'answering everyone at once.'),
          _en('Everyone else can get the same sentence every time, in the same '
              'tone, without you having to decide anything in the moment. '
              'Deciding in the moment is what wears you out.'),
        ],
      ),

      // ⚠️ THE BRIEF NAMES THESE AS THE HARDEST DAYS AND THIS GUIDE HAD
      // NOTHING ON THEM. Everything above is written for one question from one
      // person; a wedding is the same question from nine people in a row, in
      // front of each other, and the advice that works there is different —
      // it is logistical rather than verbal, and all of it has to be decided
      // before you arrive.
      PvReadSection(
        heading: _en('How do you get through a wedding or a festival?'),
        paragraphs: [
          _en('These are the hardest days, because everyone is in one place '
              'and the questions come as a group, not one at a time. Deciding '
              'how to handle it on the day, while upset, is much harder than '
              'deciding on the way there.'),
        ],
        bullets: [
          _en("Decide how long you're staying before you go, and say it out "
              'loud to each other.'),
          _en('Agree a signal between you for wanting out of a conversation. '
              "It doesn't have to be subtle. It just has to be agreed."),
          _en('Accept ahead of time that you might leave early, so leaving '
              'early is a plan and not a failure.'),
          _en('Decide who handles which room. Whoever\'s family it is answers '
              'the questions.'),
        ],
      ),

      PvReadSection(
        heading: _en('What about all the advice?'),
        paragraphs: [
          _en("Some of it will be harmless and some won't. Herbal products "
              'bought without a doctor, fasting, and anything sold as '
              "purifying or detoxifying aren't harmless just because a "
              'relative suggested them. Several interact with medicines, and '
              "some aren't safe in early pregnancy."),
          _en("You don't have to argue about any of it. \"Our doctor is "
              'handling that" is a full answer, and almost nobody argues with '
              'it.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): friends, hurtful remarks and
      // skipping gatherings, which the family-only version left out.
      PvReadSection(
        heading: _en('What about friends, and hurtful comments?'),
        paragraphs: [
          _en('Friends can be harder than family, because their news is often '
              'the hard part. A pregnancy announcement, a baby shower or a '
              "first birthday can hurt, even when you're really glad for "
              'them.'),
          _en("You're allowed to skip some of these for a while. Send a kind "
              "message or a gift, and say you can't make it. A good friend "
              "will understand, even if you don't give the reason."),
          _en("When someone says something that stings, you don't have to "
              'correct them on the spot. "I know you mean well, but that\'s '
              'hard to hear" is enough.'),
          _en('Later, you can tell the friends you are closest to what does '
              'help, like asking how you are rather than whether there is any '
              'news.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('They mean well. Am I being unfair?'),
        answer: _en('Meaning well and causing hurt can both be true, and you '
            'can see both without judging anyone. Protecting the two of you '
            "from constant comments is a fair thing to do. It isn't rude, and "
            "it isn't ungrateful."),
      ),
      PvReadFaq(
        question: _en("Should we tell them we're having treatment?"),
        answer: _en("There's no right answer, and it really is yours to "
            "decide. It's worth knowing that telling people usually swaps one "
            'kind of asking for another. The question stops being whether, and '
            'becomes how it went this month. Some people find the support '
            'worth it, and some find that much harder.'),
      ),
      PvReadFaq(
        question: _en("What if it's his family and he won't say anything?"),
        answer: _en("This is common. It's worth raising as a request, not an "
            "accusation, because it usually isn't that he doesn't care. More "
            "often he's never had to manage his own family before and doesn't "
            'know how. Agreeing that he handles his side and you handle yours '
            'is a fair split, and an easier talk than asking him to defend '
            'you.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When this is more than family being difficult'),
      body: _en('Talk to someone if the pressure at home has become constant '
          "criticism, if you're being blamed for not conceiving, if you're "
          "being made to take anything you haven't agreed to, or if you're "
          'afraid of someone in your household. And talk to someone today, not '
          "at the next appointment, if you've had thoughts of harming "
          'yourself. Tell a person you trust as well as a professional. '
          "There's a psychologist inside this app, and there are free "
          "helplines if that's easier."),
    ),

    evidence: _en('This is practical and emotional guidance rather than a '
        'medical topic. It draws on standard ways of setting boundaries used '
        'in infertility counselling. The caution about herbal products taken '
        'without a prescription reflects known risks of mixing them with '
        'medicines and unclear safety, not any claim about whether they work. '
        'The advice on friends and gatherings draws on the same counselling '
        'practice. Sources checked September 2026.'),

    readNext: [
      'ttc_read_stress_fertility',
      'ttc_read_bringing_him_in',
      'ttc_read_telling_family',
    ],
  ),

  // ---------------------------------------------------------------------------

  PvRead(
    id: 'ttc_read_bringing_him_in',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('Bringing him into this'),
    teaser: _en('Why it usually ends up being your project, and what changes '
        'that.'),
    shortAnswer: _en('It usually becomes one person\'s job because everything '
        "points at the woman, not because he doesn't care. What helps is "
        "handing him one task that's fully his, like booking his own test, and "
        'talking at a set time. About half of couples who take longer have a '
        'male factor, so this is his too.'),

    scaleSetter: _en("If this has become one person's job, that's the usual "
        "result of how the whole subject is set up. It isn't a judgement on "
        "him or on your marriage. It's also one of the few things here you "
        "can change without anyone's permission."),

    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('In most couples, one person carries this: tracking the dates, '
              'booking the appointments, reading at night, and taking the '
              "questions. It's almost always the woman, and it's rarely "
              'because anyone decided it should be.'),
          _en('It happens because everything around this points at you. The '
              'appointments are yours. The tests start with you. The advice '
              "comes addressed to you. By the time anyone notices, he's become "
              "someone who is told what's happening, rather than someone it's "
              "happening to. One conversation won't easily undo that."),
        ],
      ),

      PvReadSection(
        heading: _en('How much of this is his?'),
        paragraphs: [
          _en('A male factor plays a part in about half of couples who take '
              'longer than expected, either alone or alongside something on '
              "the woman's side. That fact changes the conversation, and most "
              'couples have never been told it.'),
          _en("It matters here for a clear reason. It's very hard to ask "
              "someone to share the weight of a problem he's been given no "
              'reason to think is his.'),
          _en('A semen analysis is quick, cheap and '
              'the least invasive test in the whole process. Yet in many '
              "couples it's done last, or not at all."),
        ],
      ),

      PvReadSection(
        heading: _en('What helps him share it?'),
        paragraphs: [
          _en("Asking him to care more doesn't work, and it's usually not true "
              "that he doesn't care. What works is handing over specific "
              'tasks, not describing a feeling.'),
          _en('This difference matters more than it sounds. "I need you to be '
              'more involved" is about how you feel, and the only reply he has '
              'is sorry or a defence. Neither changes anything the next week.'),
          _en('"Will you book your test?" is a task with an owner and a date, '
              'and that kind of request gets done.'),
          _en('Handing over one thing completely also works better than '
              "sharing several. A job that's half his is still a job you're "
              'tracking, and the tracking is most of the weight.'),
        ],
        bullets: [
          _en("One thing that's fully his, like booking his own test or "
              "handling his own family's questions. Not helping with yours; "
              'owning one.'),
          _en('He comes to one appointment. Not as support, but as someone the '
              'appointment is also about.'),
          _en('He reads one thing. Just one, picked out, not a folder.'),
          _en('A set time to talk about it, so it stops coming up at eleven at '
              'night and hanging over every other hour.'),
          // ⚠️ THE BRIEF'S OWN POINT, AND IT IS SHARPER THAN THE ONE ABOVE.
          // *"Pick a time to talk that is not the moment a period arrives.
          // That is the worst possible time and it is when it usually comes
          // up."* A fixed time is the mechanism; this is the specific hour to
          // avoid, and it is the hour the conversation nearly always happens.
          _en("And not on the day a period arrives. That's the worst time to "
              "have any version of this talk, and it's usually when it "
              'happens.'),
          // ⚠️ THE CROSS-REFERENCE THE PRACTICE LIBRARY WAS BUILT FOR. The
          // brief: *"Do things together that are not about trying. The couple
          // part of the daily practice exists for this reason."* Naming it
          // here is the difference between a card sitting in a library and a
          // card somebody has a reason to open.
          _en("Something the two of you do together that isn't about trying. "
              'Ten slow breaths in the same room is enough. The couple part of '
              'the daily practice exists for exactly this.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why might he be quiet, even when he cares?'),
        paragraphs: [
          _en('Men in this situation are very rarely asked about it, by '
              'doctors, family or friends. Someone nobody asks usually decides '
              'his job is to stay steady and not add to the load. From the '
              'outside, that looks just like not minding.'),
          _en("It's also true that a possible problem he hasn't been tested "
              "for is easier to leave untested. That's fear, not avoiding "
              'you. Saying the half-of-couples fact out loud usually helps more '
              'than any appeal, because it turns the test from an accusation '
              'into a normal step.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): how to talk when trying strains
      // the two of you. Practical, one habit per line, and a counsellor
      // offered as ordinary rather than as a last resort.
      PvReadSection(
        heading: _en("How do you talk when it's straining you both?"),
        paragraphs: [
          _en('Months of trying wear on any couple. A few small habits make '
              'the talks you do have easier.'),
        ],
        bullets: [
          _en('One calm check-in a week, at a time you both agree, instead of '
              'many tense ones.'),
          _en('Say what you need rather than what he got wrong. "I\'d like '
              'you at the next scan" lands better than "you never come".'),
          _en('One topic at a time. "This month\'s appointment" is easier than '
              '"everything about this".'),
          _en('Hear him out, then say back what you heard before you answer. '
              'It feels stiff, and it stops a lot of arguments growing.'),
          _en("If it heats up, take a break, and agree when you'll come back "
              "to it so the break doesn't feel like a door shutting."),
          _en("Talk about other things too. A walk or a meal where trying "
              "isn't mentioned counts."),
        ],
        tip: PvReadTip(
          title: _en('If it keeps turning into the same argument'),
          body: _en('A couples counsellor can help, and going is not a sign '
              'the marriage is failing. Many couples find it easier to be '
              'heard with a third person in the room.'),
        ),
      ),

      PvReadSection(
        heading: _en('What tends to backfire?'),
        paragraphs: [
          // ⚠️ THE BRIEF'S "what tends not to work", WHICH THIS SECTION DID NOT
          // HAVE. It warned about scheduling — a real and different failure —
          // and said nothing about the framing that causes the commonest one.
          // Worth keeping because the symptom is not refusal, which is what
          // people watch for; it is agreement followed by nothing.
          _en('First, two ways of putting it almost always fail: saying it is '
              "his turn, or making it a test of whether he's serious about "
              'this. Both are understandable, and both make him defensive.'),
          _en("The answer is almost never no. It's delay. Next month, after "
              'this project, once work settles. Nothing moves, and resentment '
              "builds on both sides while it doesn't."),
          _en('The most common attempt is scheduling: telling him which days '
              "matter and when. It's completely reasonable, and it's the thing "
              'most likely to make him pull back further, because it turns '
              'him into a task on a calendar.'),
        ],
      ),

      // ⚠️ SPLIT 2026-09-26 (TTC gap plan): the second half of the section
      // above, given its own heading so no section runs past three
      // paragraphs. Same words.
      PvReadSection(
        heading: _en('What if the calendar has taken over?'),
        paragraphs: [
          _en("If that's already happened, the way back is usually to stop "
              'announcing the days for a cycle or two. You lose nothing by it. '
              'Sex every one to two days across the week works as well as '
              'precise timing, which means the calendar was never worth what '
              'it cost.'),
          _en("Tell him you're doing this, rather than just doing it. If you "
              'stop mentioning dates for a month without saying why, it can '
              "look to him like you've given up or pulled away."),
          _en("That's the opposite of what's happening, and it's much harder "
              'to come back from than the first problem.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en("He says he doesn't want to talk about it. Now what?"),
        answer: _en('Ask for a short version with an end, instead of an open '
            'one: ten minutes on Sunday, not "we need to talk about this". '
            'Someone who refuses an open-ended talk will often agree to a '
            "short one. What he's saying no to is usually the endlessness, "
            'not the subject.'),
      ),
      PvReadFaq(
        question: _en('Is it fair to ask him to test before I do?'),
        answer: _en("It's more than fair. It's the cheaper and less invasive "
            'order, and several clinics do it that way as standard. If yours '
            "hasn't suggested it, it's reasonable to ask."),
      ),
      PvReadFaq(
        question: _en("We've stopped enjoying any of this. Is that normal?"),
        answer: _en("It's very common, and it's one of the easier parts to "
            'fix. Sex that has become a scheduled task stops being something '
            'either of you wants. The usual first step is to take the calendar '
            'out of it for a while, rather than trying harder within it.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to bring in a third person'),
      body: _en('See a professional together if this has become an argument '
          'you have every month, if either of you has stopped wanting any '
          'physical closeness at all, if one of you is drinking more to get '
          'through it, or if either of you has been low or unable to cope for '
          'more than a couple of weeks. And talk to someone today, not at the '
          'next appointment, if either of you has had thoughts of harming '
          'yourself.'),
    ),

    evidence: _en('The share of couples with a male factor involved follows '
        'standard infertility research, as reflected in major clinical '
        'guidance. The advice on making decisions together, and on how '
        "scheduled sex affects a couple's distress, follows infertility "
        'counselling practice, as do the everyday ways of talking when the '
        'strain builds. We make no claim that any of this changes the '
        'chance of conceiving. Sources checked September 2026.'),

    readNext: [
      'ttc_read_stress_fertility',
      'ttc_read_family_asking',
      'ttc_read_trying_takes_over',
    ],
  ),
];
