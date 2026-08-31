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
    teaser: _en('What the evidence actually shows, why "just relax" is both '
        'wrong and cruel, and what a daily practice is genuinely for.'),

    scaleSetter: _en('Ordinary stress does not stop you conceiving. The '
        'largest analyses find that emotional distress before treatment does '
        'not determine whether it works — so if you have been quietly '
        'wondering whether your worrying is the reason, it is not.'),

    author: _en('Dr. Sharanya Menon'),
    authorRole: _en('Perinatal psychologist · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_stress_fertility',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Almost everyone trying to conceive has been told to relax. It '
              'is usually said kindly, and it is one of the more harmful '
              'things a person can say.'),
          _en('It does two things at once. It hands her responsibility for '
              'something she does not control, and it turns every month that '
              'does not work into evidence that she was not calm enough. The '
              'second part is what makes it stick — because after a while she '
              'is anxious about being anxious, and there is no way out of that '
              'from the inside.'),
        ],
      ),

      PvReadSection(
        heading: _en('What the evidence actually says'),
        paragraphs: [
          _en('It is genuinely mixed, and the honest summary is more '
              'reassuring than the folklore.'),
          _en('The largest piece of it is a meta-analysis of fourteen studies '
              'covering more than three and a half thousand women, which found '
              'that emotional distress before treatment was not associated '
              'with whether assisted reproduction worked. A prospective study '
              'measuring both psychological stress and cortisol directly found '
              'neither related to embryo quality or pregnancy rate.'),
          _en('Some studies do find an association, usually with severe or '
              'sustained anxiety rather than ordinary worry. So the position '
              'worth holding is: extreme, chronic stress is a real health '
              'problem and worth treating for its own sake, and the everyday '
              'strain of trying to conceive is not why it has not happened.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Stop thinking about it and it will happen.'),
          fact: _en('People conceive during bereavements, during exams, in '
              'war zones and in the middle of the worst months of their lives. '
              'Conception is not gated on a state of mind, and the couples who '
              'are told this most often are the ones who have already been '
              'trying longest — which is to say, the ones for whom it is least '
              'likely to be the explanation.'),
        ),
      ),

      PvReadSection(
        heading: _en('Where stress does have a real effect'),
        paragraphs: [
          _en('There is one honest exception and it is worth naming, because '
              'leaving it out would make this page a comfortable half-truth.'),
          _en('Severe, sustained stress can suppress ovulation. The body reads '
              'prolonged threat and down-regulates the hormonal signalling '
              'that drives a cycle — which is why cycles can lengthen or stop '
              'during bereavement, serious illness, extreme weight loss or '
              'genuine crisis. That is a large effect and it looks nothing '
              'like the everyday worry this page is about.'),
          _en('And stress affects the things around conception even when it '
              'does not affect conception: sleep, appetite, how often a couple '
              'has sex, whether either of them can face another conversation '
              'about it. Those are real and they are worth attending to on '
              'their own terms.'),
        ],
      ),

      PvReadSection(
        heading: _en('So what is a daily practice actually for'),
        paragraphs: [
          _en('Not to make it happen. It is worth being blunt about that, '
              'because a practice sold as a fertility treatment quietly '
              'becomes one more thing she is failing at.'),
          _en('Mind-body programmes — breathing, mindfulness, yoga, '
              'cognitive-behavioural work — reliably improve how people feel '
              'while they wait. That is the finding that holds across studies. '
              'Whether they change pregnancy rates is not consistently '
              'demonstrated, and it does not need to be.'),
          _en('Making a long wait bearable is a complete reason to do '
              'something. It is also the one outcome you can actually '
              'influence, which after a year of trying is not nothing.'),
        ],
        tip: PvReadTip(
          title: _en('Five minutes, and not as a target'),
          body: _en('Whatever you choose, keep it short enough that missing a '
              'day costs nothing. The commonest way a calming practice becomes '
              'a source of stress is by becoming a streak — something else to '
              'maintain, and something else to have broken. If you skip three '
              'days, you have not lost anything.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Useful, practical, and not the argument.
        collapsible: true,
        summary: _en('What to say to people who keep offering this advice, '
            'and how to protect the two of you from it.'),
        heading: _en('The people around you'),
        paragraphs: [
          _en('In most Indian families this is not a private process. The '
              'advice arrives constantly, it is well-meant, and it is '
              'relentless — and the strain it creates is frequently larger '
              'than anything medical.'),
          _en('A few things that help. Agreeing with your partner what is '
              'shared and what is not, before the next family gathering rather '
              'than during it. Having one short sentence ready that ends the '
              'topic without a fight — "we are seeing someone about it, and we '
              'will tell you when there is news" closes most conversations. '
              'And deciding in advance who is allowed to ask, which is usually '
              'a much shorter list than the one currently asking.'),
          _en('None of this is rudeness. Protecting a couple from commentary '
              'is a legitimate thing to do, and the version of you that has '
              'not done it is the version that dreads every phone call.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('So should I stop trying to relax?'),
        answer: _en('Stop treating it as a task with a result attached. Rest, '
              'breathing and quiet are good for you regardless — that is the '
              'reason to do them. What is worth putting down is the idea that '
              'you are doing them in order to conceive, because that makes '
              'every unsuccessful month a failure of relaxation.'),
      ),
      PvReadFaq(
        question: _en('My periods stopped during a very stressful year. Was '
            'that stress?'),
        answer: _en('It may well have been — severe, sustained stress can '
            'suppress ovulation, and cycles stopping during a crisis is a '
            'recognised pattern. That is a different thing from everyday '
            'worry, and it is worth having looked at rather than assumed, '
            'because several other causes look the same.'),
      ),
      PvReadFaq(
        question: _en('Does his stress matter?'),
        answer: _en('Sustained stress can affect sperm parameters and '
            'testosterone, and it affects the same surrounding things it does '
            'for her — sleep, drinking, whether either of you has any appetite '
            'for this. It gets discussed far less, largely because he is asked '
            'about it far less.'),
      ),
      PvReadFaq(
        question: _en('Is anxiety medication safe while trying?'),
        answer: _en('Several options are considered compatible with trying to '
            'conceive and with pregnancy, and this is a conversation for the '
            'person prescribing rather than something to settle from an '
            'article. What is worth knowing is that stopping abruptly because '
            'you are trying is its own risk — untreated illness is not the '
            'safer option it can appear to be.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When this is more than the strain of waiting'),
      body: _en('Speak to someone if low mood or anxiety has lasted more than '
          'a couple of weeks, if you cannot sleep or cannot function at work, '
          'if you have stopped seeing people, if your cycles have stopped, or '
          'if you are drinking more to get through it. And today, not at the '
          'next appointment, if you have thoughts of harming yourself. None of '
          'this is a failure of coping — it is the point at which the right '
          'help is a person rather than a practice.'),
    ),

    evidence: _en('The finding that pre-treatment emotional distress was not '
        'associated with assisted-reproduction outcomes comes from a '
        'meta-analysis of 14 studies covering 3,583 women, and from a '
        'prospective study measuring psychological stress and cortisol against '
        'embryo quality and pregnancy rate. Mind-body interventions improving '
        'mental health outcomes, with less consistent effect on pregnancy '
        'rates, per meta-analyses of CBT, mindfulness-based stress reduction '
        'and yoga in fertility populations. Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en("Today's practice"),
        value: _en('Five minutes. Reflection, breath, conversation, '
            'gratitude — and a day missed costs nothing.'),
        surfaceId: 'ttc_ritual',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Preconception garbh sanskar, honestly'),
        value: _en('What it actually is, what it does not promise, and why it '
            'is offered before conception at all.'),
        surfaceId: 'ttc_read/ttc_read_garbh_sanskar',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talking to a psychologist'),
        value: _en('Someone who works with people in exactly this waiting.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_garbh_sanskar'],
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
    teaser: _en('What the tradition actually says, what it is good for, and '
        'what it does not claim — including for people who want the practice '
        'without the belief.'),

    scaleSetter: _en('Garbh sanskar is a practice of preparation, not a '
        'method of conception. Nothing in it will make a pregnancy happen, and '
        'nothing in it needs to — what it offers is a way to spend the waiting '
        'that is calming rather than corrosive, which is a real thing to be '
        'offered.'),

    author: _en('Dr. Sharanya Menon'),
    authorRole: _en('Perinatal psychologist · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_garbh_preconception',

    sections: [
      PvReadSection(
        heading: _en('What it actually is'),
        paragraphs: [
          _en('Garbh sanskar translates roughly as the education or refinement '
              'of the womb. It comes from Ayurvedic and broader Indian '
              'tradition, and in its classical form it is a set of practices '
              'for the parents — food, routine, music, reading, conduct, '
              'stillness — undertaken from before conception through '
              'pregnancy.'),
          _en('The part most people encounter is the pregnancy version. The '
              'preconception version is older and is arguably the more '
              'coherent half of it: the tradition holds that preparation '
              'begins with the parents rather than with the pregnancy, which '
              'is a claim modern preconception medicine happens to agree with '
              'for entirely different reasons.'),
          _en('Stripped to its structure, it is a daily practice with four or '
              'five parts, done consistently, by both partners. That '
              'description is deliberately plain — it is what the practice is, '
              'whatever framework you hold it in.'),
        ],
      ),

      PvReadSection(
        heading: _en('What it is good for'),
        paragraphs: [
          _en('Her, now. That is the honest answer and it is not a small '
              'one.'),
          _en('A daily practice gives shape to a stretch of time that '
              'otherwise has none — trying to conceive is months of waiting '
              'with almost nothing to do, and having something small and yours '
              'to do each day is genuinely protective. The evidence on '
              'mind-body practice supports exactly this: better mental health '
              'through a difficult period, reliably.'),
          _en('It is also one of the few things in this stage that both '
              'partners can do together without it being about performance or '
              'timing. That matters more than it sounds by about month eight.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('And if you are not religious'),
          body: _en('The practice works without the framework. Breath, '
              'stillness, music, reading aloud, gratitude and conversation are '
              'the components — none of them requires belief, and the '
              'tradition itself is more interested in what you do daily than '
              'in what you profess. Take it as mind-body preparation if that '
              'is what fits, and nothing about it is diminished.'),
        ),
      ),

      PvReadSection(
        heading: _en('What it does not claim'),
        paragraphs: [
          _en('It will not make you conceive, and no honest teacher of it '
              'says otherwise. If something you are offered promises '
              'conception, that promise was added by whoever is selling it.'),
          _en('It also makes no claim we would repeat about a child who does '
              'not exist yet. You will find material — a great deal of it '
              'online, some of it sold at considerable expense — asserting '
              'that particular practices before conception determine a baby’s '
              'intelligence, temperament or character. There is no evidence '
              'for that, and we will not tell you there is.'),
          _en('What is left after removing those claims is still worth having. '
              'That is rather the point of writing this down.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Doing it properly influences what the child will be '
              'like.'),
          fact: _en('There is no evidence that practices before conception '
              'shape a child’s intelligence or personality. What the '
              'tradition can reasonably claim — and what modern preconception '
              'care agrees with — is that the parents’ health and state of '
              'mind before conception are worth attending to. That is a much '
              'smaller claim, and it is the one that survives scrutiny.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Practical detail for someone who has decided to do it, and
        // clutter for someone still working out what it is.
        collapsible: true,
        summary: _en('The five parts, what each is for, and how long it '
            'actually takes.'),
        heading: _en('What a daily practice looks like'),
        paragraphs: [
          _en('Short. Five to fifteen minutes, and the consistency matters far '
              'more than the duration — which is the one instruction almost '
              'every version of this agrees on.'),
        ],
        bullets: [
          _en('Reflection — a single thought or reading to sit with. Not '
              'analysis, and not journalling unless you want it to be.'),
          _en('Breath — a few minutes of slow breathing, which is the '
              'component with the most direct evidence behind it for calming '
              'the nervous system.'),
          _en('Sound — music, chanting or reading aloud, depending entirely on '
              'what you find settling.'),
          _en('Conversation — one honest exchange between the two of you that '
              'is not about timing, tests or money.'),
          _en('Gratitude — brief, specific and not performed. This is the part '
              'most likely to feel forced at first and most likely to be '
              'missed once it stops.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Is there any scientific evidence for garbh sanskar?'),
        answer: _en('For the practice as a whole, no — it has not been '
            'studied as a package, and claims that it has should be treated '
            'carefully. For its components, yes: breathing, meditation and '
            'yoga have reasonable evidence for reducing distress. So the '
            'honest position is that the parts are supported and the promises '
            'sometimes attached to the whole are not.'),
      ),
      PvReadFaq(
        question: _en('Do both of us need to do it?'),
        answer: _en('The tradition says yes, and it is one of the few places '
            'where tradition and the practical answer agree. A practice one '
            'person does alone becomes another thing she is carrying; a '
            'practice both do together is the rare part of this stage that is '
            'shared without being about performance.'),
      ),
      PvReadFaq(
        question: _en('Should I be following a particular diet for it?'),
        answer: _en('Classical garbh sanskar includes dietary guidance, and '
            'much of it is unremarkable — regular meals, fresh food, less '
            'that is heavy or over-processed. Where it starts prescribing '
            'expensive preparations or forbidding ordinary foods, that is '
            'worth questioning. Our nutrition guidance is separate and is '
            'built on preconception evidence rather than on tradition.'),
      ),
      PvReadFaq(
        question: _en('We have been trying a long time. Is it too late to '
            'start?'),
        answer: _en('No, and there is nothing in it that requires you to be at '
            'a particular point. It is a way of spending the waiting, and '
            'people who have been waiting longest are the ones with most of it '
            'to spend.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Where a practice is not the right answer'),
      body: _en('Nothing here replaces medical care, and it should never be a '
          'reason to postpone it. See a doctor rather than waiting if your '
          'cycles are irregular or absent, if you have been trying for a year '
          '— six months at 35 or over — or if you have a known condition. And '
          'speak to a person rather than a practice if the waiting has become '
          'low mood or anxiety you cannot put down. Be especially careful with '
          'anyone offering garbh sanskar as an alternative to fertility '
          'treatment; the tradition itself does not claim that.'),
    ),

    evidence: _en('Description of garbh sanskar follows classical Ayurvedic '
        'and Indian tradition as commonly practised, rather than any single '
        'text. Evidence for the components — breathing practice, meditation '
        'and yoga improving psychological outcomes in fertility populations — '
        'from meta-analyses of mind-body interventions. We are not aware of '
        'controlled evidence for the practice as a whole, and none is claimed '
        'here. Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.course,
        title: _en('The free preconception garbh sanskar course'),
        value: _en('Eight short sessions, both of you, no fee — the practice '
            'taught properly rather than described.'),
        surfaceId: 'ttc_prepare',
      ),
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en("Today's practice"),
        value: _en('The five parts, already waiting, five minutes.'),
        surfaceId: 'ttc_ritual',
      ),
    ],

    readNext: ['ttc_read_stress_fertility'],
  ),
];
