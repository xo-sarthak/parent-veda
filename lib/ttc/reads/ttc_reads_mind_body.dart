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
    title: _en('Why sleep matters when you are trying'),
    teaser: _en('Not because it makes conception happen. Because everything '
        'else you are trying to do gets harder without it.'),

    scaleSetter: _en('Short sleep does not stop you conceiving, and nobody '
        'should add it to the list of things they are doing wrong. It is on '
        'this page because sleep is the thing every other habit here rests '
        'on — and because it is one of the few things in this process you can '
        'actually change this week.'),

    author: _en('Dr. Sharanya Menon'),
    authorRole: _en('Perinatal psychologist · reviewed August 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Sleep advice arrives in this part of life the same way every '
              'other piece of advice does — as one more thing you are '
              'presumably failing at. So it is worth saying at the start what '
              'this page is not doing. It is not telling you that your sleep '
              'is the reason, and it is not offering eight hours as a target '
              'to hit and then feel bad about.'),
          _en('It is here for a plainer reason. Almost everything else this '
              'area suggests — moving a bit, eating at home, being civil to '
              'your family, wanting your partner near you — is markedly '
              'harder on four hours than on seven. Sleep is not one habit '
              'among several. It is the one the others sit on.'),
        ],
      ),

      PvReadSection(
        heading: _en('What is actually known, and what is not'),
        paragraphs: [
          _en('The honest summary is narrower than most articles suggest. '
              'Sustained night-shift work and persistently very short sleep '
              'have been associated with more irregular cycles in large '
              'observational studies. Associated is the operative word: those '
              'studies cannot separate the sleep from the stress, the light, '
              'the eating times or the job that comes with all four.'),
          _en('What has not been shown is that an ordinary run of late nights '
              'changes whether a healthy couple conceives. If you have been '
              'sleeping badly through the worry of this, that is a consequence '
              'of what you are going through, not a cause of it.'),
          _en('There is one exception worth knowing about rather than worrying '
              'about. If your cycles have become irregular or stopped '
              'altogether during a long period of shift work or severe sleep '
              'disruption, that is worth showing a doctor — not because sleep '
              'is the certain cause, but because irregular cycles have several '
              'causes and they look the same from outside.'),
        ],
      ),

      PvReadSection(
        heading: _en('The part nobody argues about'),
        paragraphs: [
          _en('Sleep sets how the next day goes, and the next day is where all '
              'of this actually happens. Tired people eat differently — more '
              'sugar, later, and less of whatever they had planned. Tired '
              'people move less. Tired people drink a bit more in the evening '
              'to come down. And tired people are far worse at absorbing a '
              'remark from a relative without it ruining the afternoon.'),
          _en('None of that is a moral failing and all of it is predictable. '
              'If you fix nothing else this month, fixing the hour you go to '
              'bed quietly improves four other things without you having to '
              'think about any of them.'),
        ],
      ),

      PvReadSection(
        heading: _en('And it is worse in this particular month'),
        paragraphs: [
          _en('Trying to conceive has a specific effect on sleep that ordinary '
              'sleep advice does not account for. The waiting happens at '
              'night. The two weeks after ovulation, the night before a test, '
              'the night after a period arrives — these are when the thinking '
              'gets loudest, and they arrive on a schedule.'),
          _en('That means bad sleep here is often not a habit problem at all. '
              'It is grief and anticipation turning up at eleven at night '
              'because that is the first moment of the day with nothing in it. '
              'Treating that as sleep hygiene will not touch it. What helps is '
              'usually having somewhere else to put the thinking — a '
              'conversation, something written down, or a practice that gives '
              'the mind one small thing to hold instead.'),
        ],
      ),

      PvReadSection(
        heading: _en('What is worth trying'),
        bullets: [
          _en('Pick a bedtime and hold the wake-up time, not the bedtime. The '
              'hour you get up is what actually moves your body clock.'),
          _en('Get outside in daylight in the first hour or two you are awake, '
              'even for a few minutes. This does more than anything you can do '
              'at night.'),
          _en('Stop searching at a fixed hour. Forums and symptom-checking '
              'after ten at night have never once helped anybody sleep.'),
          _en('If you are lying awake for more than twenty minutes, get up and '
              'sit somewhere dim until you are sleepy. Staying in bed teaches '
              'you that bed is where you think.'),
          _en('Do not chase lost sleep at the weekend by four hours. An hour '
              'is fine; four resets the clock you have just built.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('I work nights. Is that a problem?'),
        answer: _en('It is worth mentioning to your doctor, particularly if '
            'your cycles are irregular, because shift work is one of the few '
            'sleep patterns with a real association in the research. It is not '
            'a reason to leave your job, and nobody can tell you it is why '
            'this is taking time. Anchoring light and meals to a consistent '
            'pattern on the days you are not on shift helps more than trying '
            'to sleep like a day worker on your days off.'),
      ),
      PvReadFaq(
        question: _en('Is a sleeping tablet safe while trying?'),
        answer: _en('That is a question for whoever would prescribe it, and it '
            'is a reasonable question to ask rather than something to feel bad '
            'about needing. What is worth knowing is that over-the-counter '
            'sleep aids and herbal preparations are not automatically the '
            'safer choice simply because nobody prescribed them — several are '
            'unstudied in this context, which is not the same as being safe.'),
      ),
      PvReadFaq(
        question: _en('Does his sleep matter too?'),
        answer: _en('The same practical argument applies to him, and it gets '
            'asked about far less. Sustained poor sleep is associated with '
            'lower testosterone, and it affects everything around this in the '
            'same way it does for you — drinking, mood, and whether either of '
            'you has any appetite for the process.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When sleep is a symptom, not a habit'),
      body: _en('Speak to a doctor rather than trying harder if you have been '
          'unable to sleep for more than two or three weeks, if you are waking '
          'very early every morning and cannot get back to sleep, if you are '
          'exhausted all day despite spending long enough in bed, if your '
          'partner has noticed you stop breathing or gasp in your sleep, or if '
          'you have been drinking to get to sleep. And today, not at the next '
          'appointment, if you have had thoughts of harming yourself — tell '
          'someone you trust as well as a professional.'),
    ),

    evidence: _en('Associations between night-shift work, very short sleep '
        'duration and menstrual irregularity are drawn from large '
        'observational cohorts, which cannot establish cause. No effect of '
        'ordinary sleep variation on conception is claimed here and we are not '
        'aware of evidence that would support one. Sleep timing guidance '
        'follows standard behavioural sleep practice. Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en('Fixing a bedtime you will actually keep'),
        value: _en('The practical half of this, in one short page.'),
        surfaceId: 'ttc_read/ttc_read_bedtime',
      ),
    ],

    readNext: ['ttc_read_bedtime', 'ttc_read_stress_fertility'],
  ),

  // ---------------------------------------------------------------------------

  PvRead(
    id: 'ttc_read_bedtime',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('Fixing a bedtime you will actually keep'),
    teaser: _en('Most bedtimes fail for the same three reasons. None of them '
        'is willpower.'),

    scaleSetter: _en('A bedtime you keep four nights a week is worth more than '
        'a perfect one you abandon by Wednesday. Everything below is written '
        'for the version of you who is tired and does not feel like it, '
        'because that is the version who decides.'),

    author: _en('Dr. Sharanya Menon'),
    authorRole: _en('Perinatal psychologist · reviewed August 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Almost everybody who wants an earlier night has already tried '
              'the obvious thing: decide on eleven, and then be in bed at '
              'eleven. It works for a few days and then stops, and the usual '
              'explanation is that you did not want it enough.'),
          _en('That explanation is wrong and it is worth dropping, because it '
              'is also the reason people stop trying. Bedtimes fail for '
              'structural reasons, and each of the three has a fix that is not '
              'about trying harder.'),
        ],
      ),

      PvReadSection(
        heading: _en('Reason one: the evening has no ending'),
        paragraphs: [
          _en('Most late nights are not a decision to stay up. They are the '
              'absence of a decision to stop — the day simply runs on until '
              'you notice it is half past midnight. Nothing marked the end of '
              'it.'),
          _en('So give the evening an ending that is not getting into bed. '
              'Something small and repeatable that happens at the same time: '
              'the kitchen gets tidied, the phone goes on to charge in another '
              'room, the light in the main room goes off. The point is not the '
              'task. The point is that something has closed, and everything '
              'after it is heading for sleep.'),
        ],
      ),

      PvReadSection(
        heading: _en('Reason two: you are owed an hour'),
        paragraphs: [
          _en('If the whole day belonged to work, family and everybody else, '
              'the hour after everyone is asleep is often the only hour that '
              'is yours. Going to bed early means giving that up, and no '
              'amount of knowing about sleep makes a person volunteer to give '
              'up the only free hour they had.'),
          _en('This is the reason most bedtimes really fail, and it does not '
              'yield to discipline. What works is moving the hour rather than '
              'deleting it — taking it in the morning, or earlier in the '
              'evening before the day closes, so that going to bed is not the '
              'same thing as being finished.'),
        ],
      ),

      PvReadSection(
        heading: _en('Reason three: bed became where you think'),
        paragraphs: [
          _en('If you have spent several weeks lying in the dark going over '
              'cycle dates, then bed is now a place your mind associates with '
              'thinking. That association builds quickly and it does not care '
              'how tired you are.'),
          _en('Breaking it is uncomfortable and reliable: if you are awake and '
              'thinking for more than about twenty minutes, get up. Sit '
              'somewhere dim and dull until you feel sleepy, then go back. It '
              'costs a few bad nights and it works, because it stops teaching '
              'your body that bed is for staying awake in.'),
          _en('Do not check the time while you are doing it, and do not '
              'calculate how much sleep is left. That arithmetic is the thing '
              'that turns being awake into being anxious about being awake, '
              'and it is the reason a bad night becomes a bad week. Twenty '
              'minutes here means roughly twenty minutes as it feels, not '
              'twenty minutes measured.'),
        ],
      ),

      PvReadSection(
        heading: _en('What to change first'),
        paragraphs: [
          _en('Pick one of these and leave the rest. A list of five changes '
              'attempted at once is a list abandoned by the weekend, and the '
              'first one below does most of the work on its own.'),
          _en('It is also worth knowing roughly how long this takes, because '
              'most people give up at the point it is about to work. Shifting '
              'a body clock is a matter of a week or two of consistent '
              'mornings, not a matter of a few good nights — and the first '
              'three or four days usually feel worse rather than better, '
              'because you are getting up earlier without yet falling asleep '
              'earlier. That is the change working, not failing.'),
        ],
        bullets: [
          _en('Move the wake-up time, not the bedtime. Getting up within the '
              'same half hour every day is what shifts the clock; the bedtime '
              'follows within a week or two on its own.'),
          _en('Shift by fifteen minutes, not by an hour. An hour is a change '
              'you will notice and resist. Fifteen minutes is one you will '
              'not.'),
          _en('Choose the ending ritual before you choose the bedtime.'),
          _en('Expect to break it. A bedtime is not a streak and there is '
              'nothing here counting — miss three nights and the fourth is '
              'not harder than it would have been.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('We go to bed at different times. Does that matter?'),
        answer: _en('Not for sleep itself — plenty of couples keep different '
            'hours perfectly well. It matters if it means you have stopped '
            'having any part of the day together, which happens easily during '
            'a long stretch of trying and is worth noticing before it becomes '
            'the normal arrangement.'),
      ),
      PvReadFaq(
        question: _en('What about the phone, honestly?'),
        answer: _en('The blue light is the least of it. The real problem is '
            'that a phone in bed reliably delivers the one thing guaranteed to '
            'wake you up in this particular month — a forum, a symptom search, '
            'or somebody\'s announcement. Charging it in another room is not '
            'about the screen; it is about what is on it.'),
      ),
      PvReadFaq(
        question: _en('I am fine on six hours. Do I need to change?'),
        answer: _en('A small number of people genuinely are, and if you wake '
            'up without an alarm feeling rested, you are probably one of them. '
            'The test is not the number. It is whether you are relying on '
            'caffeine to be functional and crashing at the weekend.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When this needs more than a routine'),
      body: _en('See a doctor rather than adjusting your evening if you have '
          'not slept properly for weeks, if you wake very early and cannot get '
          'back to sleep, if you are sleeping enough hours and still exhausted '
          'all day, or if someone has noticed you stop breathing or gasp at '
          'night. And speak to someone today, not at the next appointment, if '
          'the nights have become a time you have thoughts of harming '
          'yourself.'),
    ),

    evidence: _en('Behavioural guidance here follows standard practice for '
        'insomnia — consistent wake time, stimulus control, and gradual '
        'shifting — which is the first-line approach recommended ahead of '
        'medication. No claim is made about sleep and conception; see the '
        'companion piece for what the evidence on that does and does not '
        'support. Reviewed August 2026.'),

    readNext: ['ttc_read_sleep_trying', 'ttc_read_stress_fertility'],
  ),

  // ---------------------------------------------------------------------------

  PvRead(
    id: 'ttc_read_family_asking',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('When family keeps asking'),
    teaser: _en('What to say, what you owe them, and how to stop the question '
        'arriving every week.'),

    scaleSetter: _en('You are not obliged to explain your body to anybody, '
        'including people who love you. That is worth saying plainly, because '
        'most of the strain here comes from feeling that you are.'),

    author: _en('Dr. Sharanya Menon'),
    authorRole: _en('Perinatal psychologist · reviewed August 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('In most Indian families this is not a private process. The '
              'question arrives at weddings, on calls, in kitchens, and from '
              'people who would be genuinely upset to know they were hurting '
              'you. That combination — constant, well-meant, and impossible to '
              'answer — is what makes it so wearing.'),
          _en('There is no sentence that makes people stop asking forever. '
              'There are sentences that end the conversation without a fight, '
              'and a couple of decisions that make the whole thing smaller.'),
        ],
      ),

      PvReadSection(
        heading: _en('Decide with him first, not in the room'),
        paragraphs: [
          _en('The single most useful thing is agreeing in advance — before '
              'the next gathering rather than during it — what is shared and '
              'what is not. Whether anyone knows you are trying. Whether '
              'anyone knows you are seeing a doctor. Whether either set of '
              'parents is told before the other.'),
          _en('The reason to do this early is that most of the damage happens '
              'when one of you answers on behalf of both without knowing what '
              'the other wanted said. That is how a private thing becomes '
              'public in one sentence, and it is nobody\'s fault when it has '
              'never been discussed.'),
          _en('It also decides who answers. Agreeing that questions to her go '
              'to him, and questions about his family go to him, takes a '
              'surprising amount of weight off — largely because in practice '
              'almost all of the asking is aimed at her.'),
        ],
      ),

      PvReadSection(
        heading: _en('Have one sentence ready'),
        paragraphs: [
          _en('The sentence does not need to be clever and should not be a '
              'debate. It needs to be short, warm enough not to start a fight, '
              'and finished — nothing left dangling for a follow-up question.'),
          _en('The reason to decide it in advance is that the question never '
              'arrives at a convenient moment. It comes in a room full of '
              'people, or in the middle of something else, and whatever you '
              'produce on the spot will be either sharper than you meant or so '
              'vague that it invites a second question. Having one line ready '
              'means you are not composing anything while upset.'),
          _en('Say it the same way every time, including to people you like. '
              'A sentence that varies by who asked is a sentence people compare '
              'notes on, and the version somebody got is then read as how much '
              'you trust them.'),
        ],
        bullets: [
          _en('"We will tell you when there is news." Warm, closed, and it '
              'concedes nothing.'),
          _en('"We are seeing someone about it, and we would rather not '
              'discuss it." Works when they already suspect, and stops advice '
              'without inviting sympathy.'),
          _en('"That is between us — but how are you?" The most reliable one. '
              'People asked about themselves rarely come back to it.'),
          _en('"Please do not ask me that again." For the person who has '
              'ignored the other three. It is allowed.'),
        ],
      ),

      PvReadSection(
        heading: _en('Decide who is allowed to ask'),
        paragraphs: [
          _en('There is usually a much shorter list of people whose asking you '
              'actually mind than it feels like at three in the afternoon '
              'after a family lunch. Naming it — to yourself, or out loud with '
              'him — changes how the next question lands, because you are no '
              'longer answering everybody at once.'),
          _en('Everyone else can be handled with the same sentence every time, '
              'said in the same tone, without you having to decide anything in '
              'the moment. Deciding in the moment is what is exhausting.'),
        ],
      ),

      PvReadSection(
        heading: _en('And the advice, when it comes anyway'),
        paragraphs: [
          _en('Some of it will be harmless and some of it will not be. Herbal '
              'preparations bought without a doctor, fasting, and anything '
              'sold as purifying or detoxifying are not neutral just because a '
              'relative recommended them — several interact with medication '
              'and some are not safe in early pregnancy.'),
          _en('You do not have to argue about any of it. "Our doctor is '
              'handling that" is a complete answer and it is one almost nobody '
              'contradicts.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('They mean well. Am I being unfair?'),
        answer: _en('Meaning well and causing harm are not opposites, and you '
            'can hold both without a verdict on anybody. Protecting a couple '
            'from constant commentary is a legitimate thing to do — it is not '
            'rudeness, and it is not ingratitude.'),
      ),
      PvReadFaq(
        question: _en('Should we tell them we are having treatment?'),
        answer: _en('There is no right answer and it is genuinely yours to '
            'decide. What is worth thinking about is that telling people '
            'usually swaps one kind of asking for another — the question stops '
            'being whether, and becomes how it went this month. Some people '
            'find the support worth it and some find that far harder.'),
      ),
      PvReadFaq(
        question: _en('What if it is his family and he will not say anything?'),
        answer: _en('This is common and it is worth raising as a request '
            'rather than an accusation, because it usually is not indifference '
            '— it is a person who has never had to manage his own family '
            'before and does not know how. Agreeing that he handles his side '
            'and you handle yours is a fair division and an easier '
            'conversation than asking him to defend you.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When this is more than family being difficult'),
      body: _en('Speak to someone if the pressure at home has become constant '
          'criticism, if you are being blamed for not conceiving, if you are '
          'being made to take anything you have not agreed to, or if you are '
          'afraid of someone in your household. And today, not at the next '
          'appointment, if you have had thoughts of harming yourself — tell a '
          'person you trust as well as a professional. There is a psychologist '
          'inside this app, and there are free helplines if that is easier.'),
    ),

    evidence: _en('This is practical and psychological guidance rather than a '
        'clinical topic, drawn from standard approaches to boundary-setting in '
        'infertility counselling. The caution about unprescribed herbal '
        'preparations reflects known interaction and safety uncertainty rather '
        'than any claim about efficacy. Reviewed August 2026.'),

    readNext: ['ttc_read_stress_fertility', 'ttc_read_bringing_him_in'],
  ),

  // ---------------------------------------------------------------------------

  PvRead(
    id: 'ttc_read_bringing_him_in',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('Bringing him into this'),
    teaser: _en('Why it usually ends up being her project, and what actually '
        'changes that.'),

    scaleSetter: _en('If this has become one person\'s job, that is the '
        'ordinary outcome of how the whole subject is arranged rather than a '
        'verdict on him or on your marriage. It is also one of the few things '
        'here you can change without anybody\'s permission.'),

    author: _en('Dr. Sharanya Menon'),
    authorRole: _en('Perinatal psychologist · reviewed August 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('In most couples one person is carrying this — tracking the '
              'dates, booking the appointments, reading at night, and '
              'absorbing the questions. It is almost always her, and it is '
              'rarely the result of anybody deciding it should be.'),
          _en('It happens because everything around this points at her. The '
              'appointments are hers. The tests start with her. The advice '
              'arrives addressed to her. By the time anyone notices, he has '
              'become a person who is told what is happening rather than a '
              'person it is happening to, and that is difficult to reverse '
              'with a single conversation.'),
        ],
      ),

      PvReadSection(
        heading: _en('The half that is genuinely his'),
        paragraphs: [
          _en('A male factor is involved in about half of couples who take '
              'longer than expected, either on its own or alongside something '
              'on her side. That is the fact that changes the conversation, '
              'and most couples have never been told it.'),
          _en('It matters here for a specific reason: it is very hard to ask '
              'somebody to share the weight of a problem he has been given no '
              'reason to think is his. A semen analysis is quick, cheap and '
              'the least invasive test in the whole process, and in many '
              'couples it is done last or not at all.'),
        ],
      ),

      PvReadSection(
        heading: _en('What actually shifts it'),
        paragraphs: [
          _en('Asking him to care more does not work, and it is usually not '
              'true that he does not. What works is transferring specific '
              'things rather than describing a feeling.'),
          _en('The distinction matters more than it sounds. "I need you to be '
              'more involved" is a statement about how you feel, and the only '
              'available reply is either an apology or a defence — neither of '
              'which moves anything the following week. "Will you book your '
              'test" is a task with an owner and a date, and it is the kind of '
              'request that gets done.'),
          _en('Transferring one thing completely also works better than '
              'splitting several. A job that is half his is still a job you '
              'are tracking, and tracking it is most of the weight.'),
        ],
        bullets: [
          _en('One thing that is entirely his — booking his own test, or '
              'handling his own family\'s questions. Not helping with yours; '
              'owning one.'),
          _en('He comes to one appointment. Not as support — as somebody the '
              'appointment is also about.'),
          _en('He reads one thing. One, chosen, not a folder.'),
          _en('A fixed time to talk about it, so it stops arriving at eleven '
              'at night and stops being present at every other hour.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why he may be quiet, and why that is not indifference'),
        paragraphs: [
          _en('Men in this situation are asked about it very rarely — by '
              'doctors, by families, by friends. A person nobody asks generally '
              'concludes that his part is to stay steady and not add to it, '
              'and from the outside that is indistinguishable from not '
              'minding.'),
          _en('It is also true that a possible problem he has not tested for '
              'is easier to leave untested, and that this is fear rather than '
              'avoidance of you. Saying the half-of-couples fact out loud tends '
              'to help more than any appeal, because it moves the test from an '
              'accusation to a normal step.'),
        ],
      ),

      PvReadSection(
        heading: _en('And a warning about the fix that backfires'),
        paragraphs: [
          _en('The most common attempt is scheduling — telling him which days '
              'matter and when. It is completely reasonable and it is the one '
              'thing most likely to make him withdraw further, because it '
              'turns him into a task on a calendar.'),
          _en('Where it has already happened, the way back is usually to stop '
              'announcing the days for a cycle or two. Nothing is lost by it: '
              'every one to two days across the week does as well as timing '
              'anything precisely, which means the calendar was never worth '
              'what it cost.'),
          _en('This is worth saying to him rather than doing quietly. A month '
              'in which you stop mentioning dates, without explaining why, '
              'reads from his side as you having given up or withdrawn — which '
              'is the opposite of what is happening and a much harder thing to '
              'come back from than the original problem.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('He says he does not want to talk about it. Now what?'),
        answer: _en('Ask for a bounded version rather than a general one — ten '
            'minutes on Sunday rather than "we need to talk about this". A '
            'person who has refused an open-ended conversation will often '
            'agree to a short one with an end, because what he is declining is '
            'usually the endlessness rather than the subject.'),
      ),
      PvReadFaq(
        question: _en('Is it fair to ask him to test before I do?'),
        answer: _en('It is more than fair; it is the cheaper and less invasive '
            'order, and several clinics do it that way as standard. If yours '
            'has not suggested it, asking is reasonable.'),
      ),
      PvReadFaq(
        question: _en('We have stopped enjoying any of this. Is that normal?'),
        answer: _en('It is extremely common and it is one of the more '
            'treatable parts. Sex that has become a scheduled procedure stops '
            'being something either person wants, and the usual first step is '
            'taking the calendar out of it for a while rather than trying '
            'harder inside it.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to bring in a third person'),
      body: _en('Speak to a professional together if this has become an '
          'argument you have every month, if either of you has stopped wanting '
          'any physical closeness at all, if one of you is drinking more to '
          'get through it, or if either of you has been low or unable to '
          'function for more than a couple of weeks. And today, not at the '
          'next appointment, if either of you has had thoughts of harming '
          'yourself.'),
    ),

    evidence: _en('The proportion of couples with a contributing male factor '
        'follows standard infertility epidemiology as reflected in major '
        'clinical guidance. Guidance on shared decision-making and on the '
        'effect of scheduled intercourse on couple distress follows '
        'infertility counselling practice. No claim is made that any of this '
        'changes the chance of conceiving. Reviewed August 2026.'),

    readNext: ['ttc_read_stress_fertility', 'ttc_read_family_asking'],
  ),
];
