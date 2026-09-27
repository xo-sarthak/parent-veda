// =============================================================================
//  His side — the reads for this door
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
import '../ttc_semen_limits.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, ON PURPOSE. Sharing one public helper
// would mean renaming `_en` at well over a thousand call sites for no gain; one
// line per file keeps every article body byte-identical to what it was, which
// is what makes this split reviewable as a move rather than as a rewrite.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsHisSide = [
  // ===========================================================================
  //  HIS SIDE — "sperm health"
  // ===========================================================================
  //  Excel Content cell: "Sperm health, lifestyle factors, when to test."
  //  Three topics, three reads, and the journey's three owed slots line up with
  //  them exactly — which is unusual and worth noticing rather than forcing.
  //
  //  ⚠️ WRITTEN FOR BOTH OF THEM, AND READ MOSTLY BY HER. These sit in her
  //  library and the partner door reaches the same material. So the voice is
  //  "the two of you" — never "tell him", which turns her into his nurse, and
  //  never "you" addressed at him alone, which makes the page unusable by the
  //  person actually holding the phone.
  //
  //  ⚠️ AND NEVER BLAME, IN EITHER DIRECTION. The single most useful fact in
  //  this bracket is that a male factor is involved in about half of couples
  //  who struggle. That fact exists to remove blame from her, not to move it
  //  onto him.
  PvRead(
    id: 'ttc_read_whose_side',
    hue: 186,
    kicker: _en('His side'),
    title: _en('Whose "side" is it, really'),
    teaser: _en("Your side is part of the picture about half the time. Your "
        "test is the quickest one in all the checks, and it's the one most "
        'often left for a year.'),
    shortAnswer: _en('It belongs to both of you. In about half of couples '
        'who take longer than expected, a male factor is part of the picture. '
        "Your test is one quick, private sample, so it's worth doing early "
        "rather than after months of checks on your partner."),

    scaleSetter: _en('In roughly half of couples who take longer than '
        "expected, a male factor is part of it. That isn't a comment on you. "
        "It's the reason checks should start with both of you, because your "
        'half takes one test and a few days. Your partner\'s half takes months '
        'of timed blood tests and scans.'),

    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,

    heroVideoSlot: 'ttc_vid_whose_side',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('In most Indian clinics, the woman is checked first. Her tests '
              'are slower, cost more and are more invasive. By the time '
              'anyone asks for a semen analysis, several months have usually '
              'gone by.'),
          _en("There's no medical reason for that order. There's a social "
              'one, and it helps to say it plainly. A semen analysis can feel '
              "like a judgement in a way a blood test doesn't, so it gets put "
              'off, by the man and often by everyone around him.'),
          _en('The practical reason to do it early has nothing to do with '
              "fairness. It's quick and it's cheap, and a normal result rules "
              'out half the possible explanations in seventy-two hours.'),
        ],
      ),

      PvReadSection(
        heading: _en('What does sperm health mean?'),
        paragraphs: [
          _en('Three things get measured, and each one answers a different '
              'question.'),
        ],
        bullets: [
          _en('How many: the number per millilitre, and the total in the '
              'sample. This is the number everyone knows about, but it '
              "isn't the most important one."),
          _en('How well they move: this is motility. What matters most is '
              'progressive motility, the share swimming forwards rather than '
              'in circles. Movement matters more than count, because sperm '
              'have a long way to go.'),
          _en('What shape they are: this is morphology, the share with a '
              "normal shape. It's measured strictly, so the normal figure is "
              'much lower than people expect.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Making sperm takes about eleven weeks'),
          body: _en('Your body makes sperm all the time. One full round takes '
              'roughly seventy-four days, plus a couple of weeks to finish '
              'maturing. So the sample you give today shows what your body '
              'was doing about three months ago. Any change you make now '
              "shows up in a test about three months from now. That's a long "
              "wait, and it's also why a repeat test is usually booked that "
              'far out.'),
        ),
      ),

      PvReadSection(
        heading: _en("What it isn't"),
        paragraphs: [
          _en('A semen analysis measures one sample, on one day. It '
              "doesn't measure your manhood, your health or anything about "
              'you as a partner. That this even needs saying is a big part of '
              'why the test gets put off.'),
          _en('Results also change a lot. The same man tested twice, six '
              'weeks apart, can get quite different numbers because of an '
              "illness, a fever, a stressful month or how long it's been "
              'since he last ejaculated.'),
          _en("That's why an abnormal result is almost always repeated "
              'before anyone acts on it. One low number shouldn\'t be treated '
              'as a final answer.'),
        ],
        mythFact: PvMythFact(
          myth: _en("If you've fathered a child before, your side is fine."),
          fact: _en('Not always. Sperm production changes with age, illness, '
              'weight, medicines and time. Secondary infertility, when a '
              "couple who conceived before can't again, often has a male "
              'factor. A past pregnancy is history, not a current test '
              'result.'),
        ),
      ),

      PvReadSection(
        heading: _en('How do you bring up the test?'),
        paragraphs: [
          _en("Medical pages rarely cover this part, and it's usually what "
              'decides whether the test happens.'),
          _en("What usually doesn't work is making it the man's turn. Put "
              'that way, it can sound like blame even when none is meant. '
              'The usual result is a delay rather than a refusal: next month, '
              'after this project, once work settles.'),
          _en('What tends to work is doing the first round together, as one '
              'errand. You both book, you both give a sample of something, '
              'and you both get results back on the same day. It\'s also '
              'better medicine, because checking only one of you is how six '
              'months disappear.'),
          _en("It also helps to know what the test isn't, because that's "
              "often the real worry underneath. There's no examination, no "
              "needle and no doctor in the room. It's a private room at a "
              'lab, or more and more often a sample collected at home and '
              'dropped off within the hour.'),
        ],
        tip: PvReadTip(
          title: _en('If the answer has been no once'),
          body: _en('Leave it for a fortnight. Then come back to it as plans '
              "rather than a big topic: which lab, which morning, who's "
              "driving. A decision you've argued about is hard to undo, but "
              'an appointment is easy to keep. If it stays stuck, a short '
              'consult where a doctor asks for the test often helps, because '
              "then it's no longer one partner asking the other."),
        ),
      ),

      PvReadSection(
        // ⚠️ UNFOLDED 2026-09-06 — Step 7 of the brief: "remove the
        // accordions". Was collapsible with a summary line; the section is
        // unchanged, it simply no longer starts shut.
        heading: _en('What causes a low result?'),
        paragraphs: [
          _en('The most common finding is a varicocele. These are enlarged '
              'veins in the scrotum that raise the temperature around the '
              'testes and slow down sperm production.'),
          _en("It's found in a fair share of men with low results, and it can "
              'often be repaired. The evidence on whether repair leads to more '
              'live births is mixed, not settled.'),
          _en('Other causes include past infections, testes that had not '
              'come down in childhood, hormone problems, certain medicines, '
              'and blockages in the tubes that carry sperm. Several of these '
              'can be treated, and a few can be fixed completely.'),
          _en("In quite a few men, no cause is found at all. That's "
              "frustrating, but it doesn't mean nothing can be done. The path "
              'from there is the same either way.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): his age, which the gap analysis
      // found missing. Kept to what the evidence supports: a slow change, a
      // small rise in risk, and most children of older fathers healthy.
      PvReadSection(
        heading: _en('How does age affect sperm?'),
        paragraphs: [
          _en('Age matters on your side too, just more slowly. Sperm are made '
              "all through life, so there's no sudden stop the way there is "
              'with eggs. But from around 40, sperm tend to move a little less '
              'well and carry a little more DNA damage.'),
          _en('In practice, couples take a little longer on average when the '
              'man is in his forties. After about 45, the miscarriage rate is '
              'slightly higher, and a few rare genetic conditions in children '
              'become a little more common. The rise is small, and most '
              'children of older fathers are healthy.'),
          _en("None of this is a reason to panic. It's a reason not to leave "
              'your test for last, and to make both your ages part of the '
              "conversation with a doctor. There's more in the piece on his "
              'age.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en("What if the man doesn't want to get tested?"),
        answer: _en("It's common, and it helps to talk about it openly rather "
            'than push. What tends to help is how it\'s put. Not "get '
            'tested", but "let\'s both do the first round together and rule '
            'things out". The test is a sample given in private at a lab, '
            'with no examination and no procedure. Most men are surprised by '
            "how ordinary it is."),
      ),
      PvReadFaq(
        question: _en("Does a man's age matter?"),
        answer: _en("Less sharply than a woman's, but it does count. Sperm "
            'quality and DNA health drop slowly from around the forties. The '
            "change is slower and less fixed than on your partner's side. "
            "It's a factor, not a deadline."),
      ),
      PvReadFaq(
        question: _en('Can changing habits fix a low result?'),
        answer: _en('It can improve one, sometimes by a lot. It depends on '
            "what's causing it. Tobacco, heat and weight are the changes with "
            "real evidence behind them. Habits can't fix a blockage or a "
            "problem in the body's structure, which is why the test comes "
            'before the effort.'),
      ),
      PvReadFaq(
        question: _en("Should I get tested if we've only been trying a few "
            'months?'),
        answer: _en("There's no harm in it, and there's a good case for it. "
            "It's cheap and quick, and a normal result takes a whole kind of "
            "worry off the table early. It's clearly worth doing at six "
            "months if your partner's cycles are irregular, or at any point "
            'if you have a known reason.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Reasons to be seen sooner'),
      body: _en("Don't wait a full year if you've had a testis that had not "
          'come down, surgery or an injury to the testes, mumps after '
          'puberty, chemotherapy or radiotherapy, a swelling you can see in '
          'the scrotum, or trouble with erections or ejaculation. Treat it '
          "as urgent, this week, if there's a new lump, or pain and swelling "
          'in one testis.\n\nBoth need checking for reasons that have nothing '
          'to do with fertility.'),
    ),

    evidence: _en('About half of couples with infertility have a male factor '
        'involved. Sperm take approximately 74 days to make, plus time to '
        'travel through the epididymis, and a varicocele is the most common '
        'cause that can be found. This reflects standard andrology practice '
        'as described by ASRM and EAU. The effects of a father\'s age follow '
        'ASRM and ACOG guidance on advanced paternal age. Sources checked '
        'September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('What a semen analysis involves'),
        value: _en("How it's done, and how to read the report without "
            'panicking.'),
        surfaceId: 'ttc_read/ttc_read_semen_analysis',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Heat, habits and time'),
        value: _en('The three changes with real evidence, and roughly how '
            'much each one helps.'),
        surfaceId: 'ttc_read/ttc_read_heat_habits',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to an andrologist'),
        value: _en('In private, on video, with no waiting room.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: [
      'ttc_read_semen_analysis',
      'ttc_read_heat_habits',
      'ttc_read_his_age',
    ],
  ),


  // ===========================================================================
  //  HIS SIDE — "when to test", and how to read what comes back
  // ===========================================================================
  //  ⚠️ THE ANXIETY-REDUCING FACT IS THE WHOLE SPINE OF THIS PIECE, and it is
  //  almost never explained: the WHO reference limits are the FIFTH PERCENTILE
  //  OF MEN WHO FATHERED A CHILD NATURALLY. Five per cent of men who conceived
  //  without help fall below them. So "below reference" does not mean infertile
  //  — it means below a line drawn through a fertile population — and a couple
  //  reading a report at midnight with no idea of that is the exact scenario
  //  this page exists for.
  PvRead(
    id: 'ttc_read_semen_analysis',
    hue: 186,
    kicker: _en('His side'),
    title: _en('What a semen analysis involves'),
    teaser: _en('How the test is done, what the numbers on the report mean, '
        'and why "below normal" doesn\'t mean what it looks like.'),
    shortAnswer: _en('You give a sample in a private room at a lab, or at home '
        'and deliver it within the hour. The lab counts the sperm, checks how '
        'they move and looks at their shape. A number below the reference line '
        'is a reason to repeat the test, not a verdict.'),

    scaleSetter: _en('The reference numbers on the report are not a pass '
        "mark. They're the fifth percentile of men who fathered children "
        'naturally. That means one in twenty men who conceived without any '
        'help would score below them. A result under the line is a reason to '
        'look further, never a final answer.'),

    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,

    heroVideoSlot: 'ttc_vid_semen_analysis',

    sections: [
      PvReadSection(
        heading: _en('How is the test done?'),
        paragraphs: [
          _en('You give a sample by masturbating into a sterile container. '
              'Labs have a private room for this. Many also let you collect '
              'at home if you can get it to them within about an hour, kept '
              'close to body temperature.'),
          _en('The one instruction that matters is abstinence: two to seven '
              'days since you last ejaculated. Any shorter and the count '
              'reads low. Much longer and motility drops. Getting this wrong '
              'is the most common reason a test has to be repeated, which '
              'costs a month as well as the fee.'),
          _en("There's no examination, no needle and no procedure. Results "
              'usually come back in a day or two. In India this usually costs '
              'a few hundred to about fifteen hundred rupees, depending on '
              'the lab (checked August 2026).'),
        ],
        tip: PvReadTip(
          title: _en('Book the repeat before you read the first one'),
          body: _en('Results vary between samples from the same man, so an '
              'abnormal first result is almost always repeated before anyone '
              'acts on it. Knowing that ahead of time takes most of the sting '
              'out of a surprise number. The first report is one piece of '
              'information, not a diagnosis. The second one is what a '
              'decision is based on.'),
        ),
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): the preparation list, so the
      // commonest reason for a repeat is on the page before the test.
      PvReadSection(
        heading: _en('How do you get ready for it?'),
        paragraphs: [
          _en('A few small things make the result fairer. Most tests that '
              'have to be repeated missed one of these.'),
        ],
        bullets: [
          _en('Leave two to seven days since you last ejaculated. Count the '
              'days and tell the lab.'),
          _en('Collect the whole sample. The first part holds the most sperm, '
              "so if any is lost, say so rather than hoping it won't matter."),
          _en("Don't use lubricant, saliva or an ordinary condom, because many "
              "of them harm sperm. Use only the lab's own container."),
          _en('If you collect at home, get it to the lab within about an '
              'hour, kept close to body temperature, such as in an inside '
              'pocket.'),
          _en('Tell the lab about any fever in the last three months, and any '
              'medicines or supplements you take.'),
        ],
      ),

      PvReadSection(
        heading: _en('How do you read the report?'),
        paragraphs: [
          _en('Most Indian labs now print the latest WHO reference limits, '
              "from the 2021 sixth edition. They're useful to have in front "
              'of you, as long as you keep the point above in mind.'),
        ],
        // ⚠️ GENERATED FROM `kTtcSemenLimits`, NOT TYPED HERE — 2026-09-04.
        //
        // These four bullets WERE the app's only copy of the WHO 2021 limits,
        // and they were hand-written prose. "Read your semen report" now
        // computes against the same four numbers, and two copies of a clinical
        // threshold in one app is how an article and a tool end up quietly
        // disagreeing after a guideline update.
        //
        // The words are preserved: each limit carries its own `plain` and
        // `note`, so the strict-morphology caveat and the
        // progressive-motility remark are still here — they moved into the
        // data rather than being dropped. `ttc_his_side_test.dart` asserts
        // every figure still appears in this article's rendered text.
        bullets: [
          for (final l in kTtcSemenLimits)
            _en('${l.name}: ${l.limitText} or above.'
                '${l.note == null ? '' : ' ${l.note}'}'),
          _en('Volume, pH and vitality are also reported. Vitality is only '
              'checked when motility is low.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Where these numbers come from'),
          body: _en("They're the fifth percentile of roughly 3,500 men whose "
              "partners conceived within a year. That's the whole basis of "
              'the "normal" line. So a man just below it is in the same range '
              'as one in twenty men who fathered children with no help at '
              "all. It's a signal to look further, not a conclusion."),
        ),
      ),

      PvReadSection(
        heading: _en('What do the words on the report mean?'),
        bullets: [
          _en('Oligozoospermia: fewer sperm than the reference count.'),
          _en('Asthenozoospermia: sperm that move less well.'),
          _en('Teratozoospermia: fewer sperm with a normal shape.'),
          _en("Oligoasthenoteratozoospermia: all three together. It's a "
              "frightening word, but it's only those three findings joined "
              'into one term.'),
          _en('Azoospermia: no sperm found in the sample. This one is '
              'different. It needs a specialist, and there are still '
              'options. In many cases sperm can be collected directly, and '
              'sometimes the cause is a blockage that can be treated.'),
        ],
      ),

      PvReadSection(
        heading: _en('What if the result is normal and nothing is happening?'),
        paragraphs: [
          _en('This is more common than the other way round, and it can feel '
              'odd. You feel relief and frustration at the same time, because '
              'a normal result closes one door without opening another.'),
          _en('What it does mean is that the most common male causes have '
              "been ruled out, and that's worth knowing. What it doesn't mean "
              'is that your side is certainly fine.'),
          _en("A standard analysis counts sperm and watches them move. It "
              "can't see DNA damage, "
              "can't check how sperm behave near an egg, and can't tell you "
              'whether they would fertilise one.'),
          _en("So a normal report moves the checks to your partner's side "
              'rather than ending them. If everything there is normal too, '
              'that has a name. Unexplained infertility is a real diagnosis, '
              'not a shrug. It covers a fair share of couples, and it has its '
              'own standard treatment path.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("A normal result isn't a wasted test"),
          body: _en('Couples often feel a normal semen analysis got them '
              'nothing. In fact it ruled out half the possible explanations '
              'in three days, for a few hundred rupees. It also means nothing '
              "that follows will be aimed at the wrong person. That's exactly "
              'what a good first test should do.'),
        ),
      ),

      PvReadSection(
        // ⚠️ UNFOLDED 2026-09-06 — Step 7 of the brief: "remove the
        // accordions". Was collapsible with a summary line; the section is
        // unchanged, it simply no longer starts shut.
        heading: _en('What if the first test is abnormal?'),
        paragraphs: [
          _en("First, a repeat, usually after about three months. That's one "
              'full round of sperm production, and long enough for any change '
              'you make to show.'),
          _en('Then, depending on what it shows: a hormone panel including '
              'FSH, LH and testosterone; a scrotal ultrasound to look for a '
              'varicocele or a blockage; and in some cases genetic testing. '
              'Genetic testing is standard when the count is very low or '
              'there are no sperm at all.'),
          _en('Sperm DNA fragmentation testing is widely offered at private '
              "labs in India, and it's worth asking about carefully. It has "
              'real uses, such as repeated miscarriage or repeated failed '
              "cycles. It's also sold routinely where it won't change what "
              'anyone does next. Before paying, ask what the result would '
              'change.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Giving a sample at a lab feels embarrassing.'),
        answer: _en('Most labs let you collect at home if you can get it '
            'there within about an hour, kept warm. Ask when you book, not '
            "on the day. It's a very common request and nobody at the lab "
            'will find it unusual.'),
      ),
      PvReadFaq(
        question: _en('Does a fever affect the result?'),
        answer: _en('Yes, noticeably. A high fever can lower sperm production '
            'for two to three months afterwards, because it affects the batch '
            'already being made. If you were ill in the months before the '
            'test, mention it. It may be the whole explanation.'),
      ),
      PvReadFaq(
        question: _en('The report says morphology is 3 per cent. Is that '
            'bad?'),
        answer: _en("It's just below the reference limit of 4 per cent. On its "
            'own, morphology is the weakest of the three signs. It\'s a '
            'reason to repeat the test and look at the whole picture, not a '
            'result to act on alone.'),
      ),
      PvReadFaq(
        question: _en('Can we do IUI or IVF with a low result?'),
        answer: _en("Often, yes. That's a big part of what those treatments "
            'are for. IUI needs a fair number of sperm that move well. ICSI, '
            'where a single sperm is injected into each egg, works with very '
            'few. A low count narrows the options rather than closing them.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Take an abnormal result to a person, not a search engine'),
      body: _en('An andrologist or a urologist reads these in context: your '
          'history, your examination and the whole panel. A report read '
          'alone at midnight is the least reliable version of it. Book '
          'straight away, rather than repeating first, if the sample showed '
          "no sperm at all, if there's pain or a lump in a testis, or if you "
          'have signs of low testosterone. Everything else usually starts '
          'with a repeat.'),
    ),

    evidence: _en('Reference limits are from the WHO laboratory manual for '
        'the examination and processing of human semen, sixth edition (2021): '
        'concentration 16 million per millilitre, total motility 42 per cent, '
        'progressive motility 30 per cent, normal forms 4 per cent. Each is '
        'the fifth centile of a reference group of approximately 3,500 men '
        'whose partners conceived within twelve months. The abstinence window '
        'of two to seven days and the collection instructions are from the '
        'same manual. Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep both your reports together'),
        value: _en('One place for both of you, so a second opinion takes an '
            'evening rather than a week.'),
        surfaceId: 'ttc_records',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The test library'),
        value: _en('Tests for both of you, side by side, with what each costs '
            'in India.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Have the report read properly'),
        value: _en('An andrologist, on video, with the numbers in front of '
            'them.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_heat_habits'],
  ),


  // ===========================================================================
  //  HIS SIDE — "lifestyle factors"
  // ===========================================================================
  //  ⚠️ THE INDIA-SPECIFIC ITEM HERE IS CHEWING TOBACCO, and it is the one a
  //  translated Western article always misses. Gutka, khaini and paan masala
  //  are frequently not counted as "smoking" by the person using them — asked
  //  "do you smoke?", he says no, truthfully as he understands it. Naming the
  //  products explicitly is the difference between the advice landing and
  //  sliding past.
  PvRead(
    id: 'ttc_read_heat_habits',
    hue: 186,
    kicker: _en('His side'),
    title: _en('Heat, habits and time'),
    teaser: _en('Three changes with real evidence behind them, roughly how '
        'much each helps, and how long before any of it shows on a test.'),
    shortAnswer: _en('Three changes have the clearest evidence: stopping '
        'tobacco in every form, keeping the testes cool, and cutting down '
        'heavy drinking. Weight, sleep and stress matter too. Whatever you '
        'change takes about three months to show on a test, because '
        "that's how long sperm take to make."),

    scaleSetter: _en('Your body makes sperm all the time. So unlike almost '
        'anything else in fertility, this responds to change, but on its own '
        'schedule. A change made today shows up in a test in about three '
        'months. So the improvement is real, but you have to wait to see it.'),

    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,

    heroVideoSlot: 'ttc_vid_heat_habits',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Lots of products are sold to men for this, and only a short '
              'list of things has real evidence. That short list is below, '
              'roughly in order of how much each one helps.'),
        ],
      ),

      PvReadSection(
        heading: _en('How much does tobacco matter?'),
        paragraphs: [
          _en('This is the clearest of the three. Smoking lowers count, '
              'motility and normal forms, and raises sperm DNA fragmentation '
              "by around ten per cent. That's damage a standard semen analysis "
              "doesn't show, and it matters for miscarriage risk."),
          _en("It's also the one that reverses. Men studied before and after "
              'stopping showed clear improvement in volume, concentration and '
              "total count within about three months. That's one round of "
              "sperm production, which is exactly what you'd expect."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Gutka, khaini and paan masala count'),
          body: _en('If someone asks "do you smoke?" and you chew tobacco, '
              'you\'d probably say no, and you\'d mean it. But smokeless '
              'tobacco matters here just as much, and in much of India it\'s '
              "the more common form. So it's worth naming it, rather than "
              'assuming the general question covered it.'),
        ),
      ),

      PvReadSection(
        heading: _en('Why does heat matter?'),
        paragraphs: [
          _en('The testes sit outside the body for a reason. Making sperm '
              "needs a temperature a couple of degrees below the body's core. "
              'Anything that keeps the scrotum warm for long stretches lowers '
              'output.'),
          _en("The practical list is short and ordinary, and it's the "
              'cheapest thing on this page to change.'),
        ],
        bullets: [
          _en('A laptop on your lap, for hours. Use a table.'),
          _en('Long hot baths, saunas and steam rooms.'),
          _en('Tight synthetic underwear, and long hours in a hot vehicle '
              'cabin. This matters for drivers in particular.'),
          _en("A varicocele raises the temperature from the inside. That's "
              'why it comes up here at all, and why a swelling is worth '
              'getting checked.'),
        ],
      ),

      PvReadSection(
        heading: _en('What about alcohol?'),
        paragraphs: [
          _en('Heavy or long-term drinking raises DNA fragmentation by about '
              'as much as smoking does. It upsets the hormone system, and '
              'with steady use it can affect the testes directly.'),
          _en('The evidence on light or occasional drinking is much weaker. '
              'The honest view is that heavy drinking is clearly a problem and '
              "occasional drinking probably isn't."),
        ],
      ),

      // ⚠️ SPLIT 2026-09-26 (TTC gap plan). Was one section, "Alcohol, weight
      // and the rest"; weight and stress each gained a paragraph the gap
      // analysis asked for, and the section had grown past a single heading.
      PvReadSection(
        heading: _en('Does weight matter?'),
        paragraphs: [
          _en('Weight matters because of hormones. Body fat turns '
              'testosterone into oestrogen, so a much higher weight shifts the '
              "balance. The effect is real, but it's slower to change than "
              'tobacco or heat.'),
          _en('Carrying a lot of extra weight, especially around the middle, '
              'is linked to lower count and movement and to more DNA damage. '
              'Losing some of it through steady meals and more movement may '
              'help the hormones settle.'),
          _en("This isn't about looks, and nobody needs to reach a perfect "
              'number. Crash diets are not the way, because they strain the '
              'body in other ways.'),
          _en("Exercise helps, but extremes don't. Very intense endurance "
              'training and anabolic steroids both lower production. Steroids '
              'are worth naming directly. Their effect on sperm can take many '
              'months to wear off, and men taking them almost never mention '
              'it.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Supplements will fix a low count.'),
          fact: _en('The evidence for antioxidant supplements in male '
              'infertility is weak and mixed. Some trials show a small effect '
              'on the numbers, but few show a difference in live births. Zinc '
              'and CoQ10 have the best data of the lot, and both are worth far '
              "less than stopping tobacco. They don't replace finding out "
              "what's causing a low result."),
        ),
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): his stress. Stated as narrowly as
      // the evidence allows, so it never becomes one more thing to blame.
      PvReadSection(
        heading: _en('Does stress affect sperm?'),
        paragraphs: [
          _en('Long-lasting stress can lower testosterone, and some studies '
              'link it to poorer semen numbers. The link is weaker than for '
              "tobacco or heat, and it's no reason to start worrying about "
              'worrying.'),
          _en('Stress also works through habits. Men under strain often sleep '
              'less, drink more and move less, and those have their own '
              'effects. What helps is ordinary: steady sleep, some movement, '
              'less drinking to unwind, and someone to talk to, which can be '
              'your partner or a professional.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-10, BECAUSE ANOTHER DOOR WAS POINTING AT IT.
      // Mind & body's sleep guide ends with *"See the sleep section in His side
      // for his half"* — a cross-reference to a section that did not exist.
      // The two honest options were to delete the sentence or to write the
      // section; the material is real (sleep and testosterone), it belongs on
      // the page already titled "Heat, habits and time", and pointing that
      // sentence at the nearest existing article instead would have been the
      // failure `reuse-only-the-thing-itself` describes.
      PvReadSection(
        heading: _en('Do sleep and shift work matter?'),
        paragraphs: [
          _en('Sperm production follows the same daily hormone rhythm as '
              'everything else in the body, and that rhythm is set by sleep '
              'and light. Regular short sleep is linked to lower '
              "testosterone. That's usually what people mean when they say "
              'sleep matters here.'),
          _en('Regular timing counts for more than total hours. Going to bed '
              'within the same hour most nights is better than sleeping long '
              'on some nights and short on others. What sets your body clock '
              'most is the time you get up, not the time you turn off the '
              'light.'),
          _en('Night shifts and shifts that keep changing are the part of '
              'this with real evidence behind it, and doctors rarely ask '
              'about them. If either of you works them, mention it. Not '
              "because it's the reason this is taking time, but because it's "
              'relevant and nobody will think to ask.'),
          _en("One honest limit: poor sleep isn't why this hasn't happened. "
              "It's worth fixing because it makes these months easier, and "
              "the rest of this list easier to stick to. That's reason enough "
              'on its own.'),
        ],
      ),

      PvReadSection(
        heading: _en('What three months looks like in real life'),
        paragraphs: [
          _en("The hardest thing about this list isn't any one item on it. "
              "It's that nothing gives you feedback for twelve weeks, so it's "
              'very easy to start and then slowly stop.'),
          _en('A version that tends to last: pick the two changes that fit '
              'you best rather than all of them. Book the repeat test for '
              "three months out on the day you start, and don't test before "
              'then.'),
          _en('A disappointing result at six weeks is measuring the old '
              "batch, and it's the most common reason couples give up on this."),
          _en('It also helps to make changes you set up once, rather than '
              'ones that need effort every day. A laptop on a table stays on '
              'a table. Getting tobacco out of the house is a decision made '
              'once.'),
          _en('Anything you have to remember every day is the thing that '
              'stops in week three.'),
        ],
        bullets: [
          _en('Week one: the set-up changes. Laptop off your lap, hot baths '
              'shorter, tobacco out of the house.'),
          _en('Weeks two to six: the ones that need support. Less alcohol, '
              'more movement, and any exposure at work raised with someone.'),
          _en('Week twelve: the repeat test, booked at the start so it '
              'happens.'),
        ],
      ),

      PvReadSection(
        // ⚠️ UNFOLDED 2026-09-06 — Step 7 of the brief: "remove the
        // accordions". Was collapsible with a summary line; the section is
        // unchanged, it simply no longer starts shut.
        heading: _en('What should you mention to a doctor?'),
        paragraphs: [
          _en('Several everyday medicines affect sperm production, and almost '
              'nobody thinks to mention them. These include some hair loss '
              'medicines, certain antibiotics, some blood pressure and mental '
              'health medicines, and anything with testosterone in it. '
              'Testosterone lowers production rather than helping it, the '
              'opposite of what most men assume.'),
          _en('Exposure at work matters too, and is easy to forget: '
              'pesticides, solvents, heavy metals, and long hours of heat on '
              'the job. Painters, welders, farmers and long-distance drivers '
              'all have a reason to mention what they do for a living.'),
          _en("None of this is a reason to stop anything on your own. It's a "
              'list to take to your appointment.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('How long until any of this makes a difference?'),
        answer: _en('About three months to show on a test, because that\'s '
            'one full round of sperm production. So a repeat test before then '
            'is measuring the old batch. A disappointing result at six weeks '
            'says nothing about whether the changes are working.'),
      ),
      PvReadFaq(
        question: _en('Do boxers really work better than briefs?'),
        answer: _en("There's some evidence that looser underwear is linked to "
            'slightly better numbers, but the effect is very small next to '
            'tobacco or heat. It costs nothing to switch. It just won\'t '
            'change a result on its own.'),
      ),
      PvReadFaq(
        question: _en('Is cycling bad for sperm?'),
        answer: _en('Long-distance cycling has been linked to lower numbers, '
            "through both pressure and heat. Ordinary commuting hasn't. If "
            'you ride for many hours a week, a wider saddle and some time off '
            "is a sensible thing to try. Casual riding isn't worth worrying "
            'about.'),
      ),
      PvReadFaq(
        question: _en('Does frequent sex lower my count?'),
        answer: _en("It lowers the count in any one sample, but it doesn't "
            'lower fertility. What matters is the total available across the '
            'fertile window. Sex every one to two days is recommended because '
            'it balances count against motility. "Saving it up" is the more '
            'common mistake.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Some of this isn't about habits"),
      body: _en('See a doctor, rather than making changes and waiting, if you '
          'have a swelling, lump or ache in the scrotum, trouble with '
          'erections or ejaculation, very little or no semen, or if you take '
          "testosterone or anabolic steroids in any form. And don't stop "
          'prescribed medicine because of anything on this page. Take the '
          'list to the person who prescribed it.'),
    ),

    evidence: _en('Effects of smoking and heavy long-term drinking on sperm '
        'DNA fragmentation, and improvement in volume, concentration and '
        'total count within approximately three months of stopping smoking, '
        'are from peer-reviewed reviews of lifestyle and environmental '
        'factors in male fertility on PubMed Central. Effects of scrotal '
        'temperature and varicocele, and the mixed evidence on whether '
        'varicocele repair improves live birth rates, are from the same '
        'research. Links between weight, stress and semen quality follow EAU '
        'guidance on male infertility and the same body of reviews. Sources '
        'checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('What you can track'),
        value: _en('Your own habits and health, on your side of the app, kept '
            'private.'),
        surfaceId: 'ttc_partner',
      ),
      PvReadNextStep(
        kind: PvNextKind.product,
        title: _en('The two supplements with any evidence'),
        value: _en("Zinc and CoQ10, described honestly, including what they "
            "can't do."),
        surfaceId: 'ttc_supplements',
      ),
      PvReadNextStep(
        kind: PvNextKind.course,
        title: _en('The half nobody talks about'),
        value: _en('A short course built around your side of this.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_whose_side', 'ttc_read_his_side_pressure'],
  ),
  // ===========================================================================
  //  ⚠️ WRITTEN 2026-09-04 FOR THE HIS-SIDE REBUILD
  // ---------------------------------------------------------------------------
  //  The brief splits one long article into rails and asks for four pieces the
  //  door did not have. They are written rather than extracted, because the
  //  originals were built as sections of an argument and a section lifted out
  //  of one reads as a fragment.
  //
  //  What did NOT change: `ttc_read_semen_analysis`, `ttc_read_whose_side` and
  //  `ttc_read_heat_habits` keep every doctor attribution, every WHO figure,
  //  the India specifics and the callouts. Step 7 of the brief is explicit —
  //  do not water it down — and the safest way to honour that was to leave
  //  them alone.
  //
  //  ⚠️ AND NONE OF THESE FOUR STATES A THRESHOLD OF ITS OWN. Where a number
  //  is needed it comes from `kTtcSemenLimits`, the same source the tool
  //  computes against and the same one the original article now generates its
  //  bullets from.
  // ===========================================================================

  // ⚠️ THE ONE THE BRIEF SAYS MUST NOT STAY BURIED, AND IT WAS BURIED.
  //
  // "No sperm found" currently exists as a paragraph inside a longer piece. It
  // is the single result that needs a specialist rather than a repeat, it is
  // the sentence a man is most likely to read alone at midnight, and it is the
  // one where the true information is far more hopeful than the phrase sounds.
  //
  // So it gets its own card and leads with the hope, because withholding that
  // until an appointment would be accurate and cruel.
  PvRead(
    id: 'ttc_read_azoospermia',
    hue: 186,
    kicker: _en('His side'),
    title: _en('If no sperm is found'),
    teaser: _en("It's not the end of the road. It's the one result that goes "
        'to a specialist rather than to a second sample.'),
    shortAnswer: _en('It means no sperm were seen in one sample, and it is '
        'often less final than it sounds. Sometimes sperm are being made but '
        'are blocked, and sometimes a surgeon can find sperm in the testis. '
        'The next step is an andrologist, who will arrange any repeat.'),
    scaleSetter: _en('Azoospermia means no sperm were seen in the sample. '
        "It's uncommon, and it's frightening to read. But it's often not what "
        "it sounds like. In many men, sperm are being made but can't get out. "
        'In many others, sperm can be collected directly. This is the one '
        'result where the next step is an andrologist rather than a repeat.'),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("If that's what your report says, the first thing to know is "
              'that the word describes one sample on one day.'),
          _en("The second is that it isn't one condition. There are two quite "
              'different '
              'situations that look the same under a microscope, and telling '
              'them apart is most of what the next appointment is for.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is it a blockage, or are sperm not being made?'),
        paragraphs: [
          _en('Obstructive azoospermia means sperm are being made normally '
              "but can't reach the sample, because something is blocking the "
              'way.'),
          _en('Causes include an infection years ago, surgery in '
              'childhood, being born without a vas deferens (the tube that '
              'carries sperm), or a vasectomy. In many of these, sperm can be '
              'collected, and some blockages can be repaired with surgery.'),
          _en('Non-obstructive azoospermia means production itself is low or '
              'absent. Even then, a surgeon who looks for sperm in the testis '
              'often finds some, and they can be used in IVF with ICSI.'),
          _en("You can't tell which one it is from the report. It takes an "
              'examination, hormone blood tests and sometimes a scan, and '
              "that's exactly the appointment to ask for."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens at the appointment?'),
        paragraphs: [
          _en('A physical examination. It sounds minor, but it isn\'t: a '
              'missing vas deferens or a varicocele can be found by hand in a '
              'minute.'),
          _en('Blood tests, usually FSH and testosterone. These say a lot '
              'about whether sperm are being made.'),
          _en('A repeat sample, done properly. Sometimes a small number of '
              'sperm turn up on a second look, and that changes the whole '
              'plan.'),
          _en('Genetic tests in some cases: a karyotype and a Y-chromosome '
              "microdeletion test. These matter for what's likely to be found "
              'and for what it could mean for a child.'),
        ],
      ),
      PvReadSection(
        heading: _en('Two things not to do tonight'),
        paragraphs: [
          _en("Don't buy anything. Lots of supplements are sold to men with "
              'this result, and none of them clears a blockage or restarts '
              'production that has stopped.'),
          _en("Don't decide anything about your marriage, your body or "
              "what's possible from one word on a page. This is when men "
              'most often stop talking, and it\'s exactly when talking matters '
              'most: to your partner, and to someone qualified who can explain '
              'it.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who should you tell?'),
        paragraphs: [
          _en('This is when men most often go silent, and the silence does '
              'more harm than the result. Your partner has very likely been '
              'through a string of tests already. Some were uncomfortable, '
              "and most were more public than yours. She isn't as fragile "
              'about this as you may be imagining.'),
          _en('What she will notice, and quickly, is that something has '
              "changed and you aren't saying what. A couple can take in a "
              "hard result together. What's much harder is one person "
              'carrying something alone and the other left guessing.'),
          _en("Beyond her, tell nobody until you've seen a specialist. Not "
              "because it's shameful, because it isn't, but because you "
              "don't yet know what you'd be telling them."),
          _en("\"No sperm were found in one sample and we're seeing "
              "someone\" is true. "
              'Anything more definite would be made up, and relatives will '
              'repeat it back to you for years.'),
          _en("If you find you can't talk about it at all, or you're not "
              "sleeping, or you're avoiding her, tell a doctor about that "
              'too. Men are offered counselling in fertility care far less '
              "often than women, and they're not offered it because nobody "
              'asks.'),
        ],
      ),
      PvReadSection(
        heading: _en('Can sperm always be found?'),
        paragraphs: [
          _en('Not every man with this result will have sperm collected. '
              "Some won't, and that's a real outcome that deserves to be said, "
              'not skipped over.'),
          _en("It's also true that many men who first read this word assume "
              "nothing is possible, and for most of them that's wrong."),
          _en("There's a big gap between \"no sperm in this sample\" and \"no "
              'way forward from here". Only a specialist can tell you where '
              "you are on it, so that's the next step."),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): donor sperm, written for India.
      // The rules are stated as facts with "your clinic will confirm", and
      // nothing here pushes a couple towards any one path.
      PvReadSection(
        heading: _en('What about donor sperm?'),
        paragraphs: [
          _en('If no sperm can be collected, some couples go on to use donor '
              'sperm. Others look at adoption. There is no right order, and no '
              'need to decide anything early. It usually comes up only after '
              'every other option has been looked at.'),
          _en('In India, donor sperm comes only through registered ART banks '
              'and clinics, under the Assisted Reproductive Technology '
              '(Regulation) Act, 2021. Donors are screened for infections and '
              "some genetic conditions, and the donor's identity is kept "
              'confidential. The sperm is then used in IUI or IVF.'),
          _en('Most clinics offer counselling first, and it is worth taking. '
              'Choosing a donor is a big step for both of you, and it helps to '
              'talk it through with someone who does this every day. Your '
              'clinic will confirm the rules that apply to you.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('This one goes to an andrologist, not to a repeat'),
      body: _en('Ask your doctor to refer you to an andrologist, or a '
          'urologist who works in fertility, and go sooner rather than later. '
          'Some causes are time-sensitive, and all of them are easier to plan '
          'around early. Go sooner still if you have pain, swelling or a lump '
          'in a testis, or if you take testosterone or anabolic steroids. '
          "Testosterone lowers sperm production, and it's one of the few "
          "causes on this list that can be reversed. Don't stop it yourself. "
          'Take it to whoever prescribed it.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en("Does this mean we can't have a child?"),
        answer: _en('No. It means this sample had none. The reason has to be '
            "found before anyone can say what's possible. Collecting sperm "
            'directly works for many men, and some blockages can be '
            'repaired.'),
      ),
      PvReadFaq(
        question: _en('Should I repeat the test first?'),
        answer: _en('A repeat is usually done, but as part of the checks, not '
            "instead of them. Book the specialist. They'll arrange the repeat "
            'along with the examination and the blood tests.'),
      ),
      PvReadFaq(
        question: _en('Is it something I did?'),
        answer: _en('Almost never. The common causes are something you were '
            'born with, an old infection or surgery, or genes. Heat and '
            "habits affect counts, but they don't usually cause this result."),
      ),
    ],
    evidence: _en('WHO laboratory manual for the examination and processing of '
        'human semen, sixth edition, 2021; EAU Guidelines on Sexual and '
        'Reproductive Health (male infertility); AUA/ASRM guidance on the '
        'evaluation of azoospermia; NICE CG156. Donor sperm in India follows '
        'the Assisted Reproductive Technology (Regulation) Act, 2021. Sources '
        'checked September 2026.'),
    readNext: ['ttc_read_semen_analysis', 'ttc_read_donor_eggs_sperm'],
  ),

  // ⚠️ A GLOSSARY, AND A GLOSSARY IS A REAL FORMAT RATHER THAN A LAZY ONE. A
  // semen report is a page of Latin and abbreviations handed over with no
  // explanation, and every one of those words has a plain meaning somebody
  // could have said out loud. This is that list.
  PvRead(
    id: 'ttc_read_report_words',
    hue: 186,
    kicker: _en('His side'),
    title: _en('The words on the report, in plain English'),
    teaser: _en('Every term on the page, said the way a person would say it. '
        'No numbers to pass, no final answers.'),
    shortAnswer: _en('Most words on a semen report are labels for one '
        "measurement being below a reference line. A long word doesn't mean a "
        'serious problem, and none of them is a diagnosis on its own. An '
        "andrologist reads them alongside your history and your partner's "
        'results.'),
    scaleSetter: _en('A semen report is written for a lab, not for the person '
        "it's about. Most of what looks alarming on it is just how things are "
        'named. A word ending in "-spermia" describes one measurement being '
        "low. It isn't a diagnosis of anything."),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("You won't need all of this. Read the two or three lines that "
              "match what's printed on yours and skip the rest."),
        ],
      ),
      PvReadSection(
        heading: _en('Which four numbers have reference lines?'),
        paragraphs: [
          _en('These are the four the reference limits apply to. The limits '
              'are the fifth percentile of men whose partners conceived '
              "within a year. They're not a pass mark."),
        ],
        bullets: [
          for (final l in kTtcSemenLimits)
            _en('${l.name}: ${l.plain} Reference line: ${l.limitText} or '
                'above.'),
        ],
      ),
      PvReadSection(
        heading: _en('What else does it measure?'),
        bullets: [
          _en('Volume: how much semen there was, in millilitres. It\'s '
              "reported, but it isn't one of the four. A very low volume with "
              'everything else normal is worth mentioning to a doctor.'),
          _en('pH: how acidic or alkaline the semen is. Almost always normal, '
              'and it only matters alongside a low volume.'),
          _en('Vitality: the share of sperm that are alive. Only measured '
              'when motility is low, to tell "not moving" apart from "not '
              'alive".'),
          _en('Liquefaction time: semen is thick at first and thins within '
              'about twenty minutes. A long liquefaction time sometimes '
              'matters.'),
          _en('Round cells or leucocytes: other cells in the sample. A high '
              'count sometimes points to an infection and is worth asking '
              'about.'),
          _en('Agglutination: sperm sticking together. Sometimes points to '
              'antibodies.'),
        ],
      ),
      PvReadSection(
        heading: _en('What do the "-spermia" words mean?'),
        paragraphs: [
          _en('These are the words most likely to send you to a search '
              'engine at midnight. Each one is a label for one measurement '
              'being below a line. None of them is a diagnosis on its own.'),
        ],
        bullets: [
          _en('Oligozoospermia: concentration below the line. "Few sperm".'),
          _en('Asthenozoospermia: motility below the line. "Slow sperm".'),
          _en('Teratozoospermia: normal forms below the line. "Oddly shaped".'),
          _en('Oligoasthenoteratozoospermia (OAT): all three at once. It\'s a '
              'long word for a common mix, not a rare disease.'),
          _en('Azoospermia: no sperm seen in the sample. This is the one that '
              'goes to a specialist rather than a repeat, and it has its own '
              'piece in this section.'),
          _en('Cryptozoospermia: none seen at first, but a few found after '
              'the sample is spun in a machine. Better news than azoospermia.'),
          _en('Normozoospermia: everything at or above the reference lines.'),
        ],
      ),
      // ⚠️ ADDED 2026-09-26 (TTC gap plan): antibodies, the MAR test and the
      // hormone tests, the three things a report or its covering note most
      // often mentions that this glossary did not explain.
      PvReadSection(
        heading: _en('What if it mentions antibodies or hormones?'),
        paragraphs: [
          _en("Some reports, or the tests ordered with them, go beyond the "
              'semen itself. These are the ones you are most likely to see.'),
        ],
        bullets: [
          _en('Antisperm antibodies: the immune system treating sperm as if '
              'they were foreign, so they clump together or struggle to swim. '
              'It can follow an injury, surgery, an infection or a vasectomy '
              "reversal. It's an uncommon reason for a low result."),
          _en('MAR test (mixed antiglobulin reaction): a lab test that checks '
              'how many moving sperm have antibodies stuck to them. A high '
              'result is worth taking to an andrologist. A low one means '
              'antibodies are unlikely to be the problem.'),
          _en('FSH, LH and testosterone: hormone blood tests, not part of the '
              'semen report, but often ordered alongside it. They show whether '
              "the brain's signal to the testes, and the testes' own output, "
              'look normal.'),
          _en('Prolactin: another hormone, sometimes checked when testosterone '
              'is low or desire has dropped.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why do the labels sound so bad?'),
        paragraphs: [
          _en('The way these words are built is the problem. Medicine stacks '
              'Greek roots onto "-zoospermia", so a small drop in three '
              'measurements becomes "oligoasthenoteratozoospermia". That\'s '
              'twenty-eight letters describing something very common. The '
              'word looks like a rare disease but describes an ordinary '
              'finding.'),
          _en("The words aren't graded either. There's no mild, moderate or "
              'severe built in. A concentration just under the line and one '
              'far under it get exactly the same word. So the label tells you '
              'which measurement was below a reference line, and nothing at '
              'all about how far.'),
          _en('Keep that in mind before you search for any of them. A search '
              'engine shows the worst version of every one of these words, '
              'because the worst version is what people write about.'),
        ],
      ),
      PvReadSection(
        heading: _en('What do Indian reports do differently?'),
        paragraphs: [
          _en('Many labs here still print reference columns from the fifth '
              'WHO edition, or their own ranges, next to the result. The '
              'older numbers are higher, so the same sample can look below '
              'the line on one report and within it on another.'),
          _en('Ask which '
              'edition the reference column is from. The numbers in this '
              'section are from the 2021 sixth edition.'),
          _en('Many reports also add a comment or "impression" at the bottom, '
              'a line of interpretation from whoever signed it. It\'s worth '
              'reading and worth taking to your appointment. But it\'s one '
              'professional\'s reading of one sample, and it\'s not a '
              'diagnosis either.'),
        ],
      ),
      PvReadSection(
        heading: _en("What doesn't the report say?"),
        paragraphs: [
          _en("It doesn't say whether you're fertile. There's no such test. "
              'The only proof of fertility is a pregnancy, and plenty of men '
              'with results below a line have fathered children.'),
          _en('It doesn\'t say whose "fault" anything is. About half of '
              'couples having difficulty have a male factor involved, very '
              'often alongside a female one. The word fault doesn\'t help '
              'anyone here.'),
          _en("And it doesn't say what to do. That's a conversation with "
              'someone who can put these numbers next to an examination, your '
              "history and your partner's side of things."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Take the printed report, not a summary'),
      body: _en('When you see anyone about this, bring the printed report '
          'rather than a number you remember. If the report says no sperm '
          'found, a very low volume or a high white-cell count, say so when '
          'you book. Those change how soon you should be seen. And see '
          'someone promptly, rather than repeating first, if you have pain, '
          'swelling or a lump in a testis, trouble with erections or '
          'ejaculation, or if you take testosterone or anabolic steroids.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('My morphology is 4 per cent. Is that bad?'),
        answer: _en("No, it's normal. The measurement is strict on purpose, "
            'and the reference line is 4 per cent. So 4 is at the line, and 5 '
            'is comfortably above it. This number worries more men than any '
            "other on the page, and it shouldn't."),
      ),
      PvReadFaq(
        question: _en('The report has a long Latin word on it. Is it serious?'),
        answer: _en("Usually it's a label for one number being below a line, "
            'as described above. The length of the word tells you nothing '
            'about how serious the finding is.'),
      ),
      PvReadFaq(
        question: _en('Why do different labs show different reference '
            'values?'),
        answer: _en('Some labs still print older WHO editions, and a few print '
            'their own. Ask which edition the reference column is from. The '
            'numbers here are from the 2021 sixth edition.'),
      ),
    ],
    evidence: _en('WHO laboratory manual for the examination and processing of '
        'human semen, sixth edition, 2021, including how it names each '
        'finding; EAU Guidelines on Sexual and Reproductive Health; NICE '
        'CG156. The reference limits on this page come from the same source '
        'as the rest of this section. The MAR test and hormone tests follow '
        'the same WHO manual and EAU guidance. Sources checked September '
        '2026.'),
    readNext: ['ttc_read_semen_analysis', 'ttc_read_azoospermia'],
  ),

  // ⚠️ TWO PIECES RATHER THAN ONE, BECAUSE THE TWO READERS ARE NOT THE SAME
  // PERSON. A man with a normal result is looking for permission to stop
  // worrying and needs to be told, gently, what it does not cover. A man with
  // an abnormal one is frightened and needs the variability explained before
  // anything else. One article addressed to both would fail both.
  PvRead(
    id: 'ttc_read_result_normal',
    hue: 186,
    kicker: _en('His side'),
    title: _en('If the result is normal'),
    teaser: _en('What a normal semen analysis rules out, and the two things '
        "it doesn't."),
    shortAnswer: _en("It's good news. A normal result rules out the most "
        "common male causes, but it doesn't prove fertility. If you've been "
        'trying for a year, or six months if your partner is 35 or over, the '
        'next questions are about the two of you as a couple.'),
    scaleSetter: _en('A result with everything at or above the reference lines '
        "is good news, and it's worth having. It rules out the most common "
        "male causes. What it doesn't do is prove fertility, or close the "
        "question if you've been trying for a while. The most common mistake "
        'after a normal result is to stop looking.'),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Take the good news first, because men are oddly slow to. A '
              'normal analysis means the numbers most likely to be the problem '
              "aren't the problem. That's a real answer, and it took one test "
              'to get.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does it rule out?'),
        paragraphs: [
          _en('Low concentration, poor movement and abnormal shape are most '
              'of what a semen analysis looks for. If all three are in the '
              'usual range, the common male causes are unlikely.'),
          _en("It also means a repeat isn't the next step. Repeating a normal "
              'test is a common way to spend money and months without '
              'learning anything.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is "normal" measured against?'),
        paragraphs: [
          _en('It helps to know what the lines you cleared really are. '
              "They're the fifth percentile of men whose partners conceived "
              'within a year. So one man in twenty who fathered a child '
              'naturally would have scored below them.'),
          _en('That works both ways, and the second way is the useful one. '
              "Clearing them doesn't set you apart, because a great many men "
              "do. And being under one of them doesn't rule anyone out, "
              'because one in twenty fathers was.'),
          _en('So "normal" here means "not in the group to check first". '
              "It's a screening line, not a grade. It was never meant to tell "
              'one man anything about himself.'),
        ],
      ),
      PvReadSection(
        heading: _en("What doesn't it do?"),
        paragraphs: [
          _en("It doesn't prove fertility. No test does. The only proof is a "
              'pregnancy. A semen analysis measures what a lab can measure, '
              'and fertilisation involves a lot more than that.'),
          _en("And it doesn't close the question if you've been trying for a "
              'while. Sperm DNA damage, hormone problems and problems in the '
              'body\'s structure can sit behind a normal-looking count, and '
              'none of them show on a routine analysis.'),
          _en('If a year has gone '
              'by, the next steps are about the couple, not either of you '
              'alone.'),
        ],
      ),
      PvReadSection(
        heading: _en('How long is "a while"?'),
        paragraphs: [
          _en('The usual definition is a year of regular sex without '
              'contraception, or six months if your partner is 35 or over. '
              "Those numbers aren't random. Most couples who will conceive "
              'without help do so within a year, so a year is when looking '
              'further stops being too early.'),
          _en("If you're inside that time with a normal analysis, the honest "
              "answer is that there's nothing more to do, and waiting isn't "
              "the same as doing nothing. If you're past it, a normal result "
              "doesn't change the timeline. It changes who the next questions "
              'are about.'),
          _en('It also helps to know that a normal result on your side and '
              "normal results on your partner's is a common and frustrating "
              'place to end up. Unexplained infertility is a real category. '
              'It doesn\'t mean "we didn\'t look properly", and there are '
              'treatment options for it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you talk about next?'),
        paragraphs: [
          _en('The useful question after a normal analysis isn\'t "what else '
              'can we test on me?" It\'s "what should we look at as a '
              'couple?"'),
          _en('Timing across your partner\'s fertile window, her '
              'cycles, whether she\'s ovulating and whether her tubes are '
              'open are the next things, and most of them are quick.'),
          _en('This is also the time to say out loud that the test happened '
              'and what it showed. Plenty of couples reach a clinic where the '
              'man has had an analysis, it was fine, and nobody mentioned it. '
              'So it gets done again.'),
          _en('And keep the report. A clinic will want the actual sheet, with '
              "the lab's name and the date on it, not a number remembered "
              'from a year ago.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you do with a normal result?'),
        paragraphs: [
          _en("File it. It's information a clinic will ask for, and a report "
              'saved on your phone is worth more than one lost in a drawer.'),
          _en('Keep the habits worth keeping anyway, like good sleep, not '
              'smoking and staying away from heat. Sperm are made all the '
              'time, and today\'s result describes the last eleven weeks, not '
              'a permanent state.'),
          _en('And take the pressure off your partner. A normal male result is '
              'often read, by everyone involved, as proof that the problem '
              "must be hers. It isn't. About half of couples having difficulty "
              'have a male factor somewhere in the picture, and plenty have no '
              'cause found at all.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("A normal result isn't a reason to wait forever"),
      body: _en("If you've been trying for a year, or six months if your "
          'partner is 35 or over, a normal semen analysis is a reason to turn '
          'the conversation to both of you, not a reason to keep waiting. And '
          'see someone whatever this result says if you have pain, swelling '
          'or a lump in a testis, trouble with erections or ejaculation, or '
          'if you take testosterone or anabolic steroids.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should I repeat it to be sure?'),
        answer: _en('Not usually. Repeating a normal result rarely changes '
            'anything, and the time is better spent on questions about you '
            'as a couple.'),
      ),
      PvReadFaq(
        question: _en('So the problem must be with her?'),
        answer: _en('No, and this is the conclusion to be most careful about. '
            'A normal analysis rules out the common male causes, not the '
            'rare ones. And a great many couples have no cause found on '
            'either side.'),
      ),
      PvReadFaq(
        question: _en('Is there a better test I should ask for?'),
        answer: _en('Sperm DNA fragmentation testing exists and is sometimes '
            "used after repeated loss or failed IVF. It's not a routine next "
            "step after a normal analysis. It's something to discuss with a "
            'specialist, not something to order online.'),
      ),
    ],
    evidence: _en('WHO laboratory manual, sixth edition, 2021; NICE CG156 '
        '(fertility problems); EAU Guidelines on Sexual and Reproductive '
        'Health; ESHRE guidance on unexplained infertility. Sources checked '
        'August 2026.'),
    readNext: ['ttc_read_semen_analysis'],
  ),

  PvRead(
    id: 'ttc_read_result_abnormal',
    hue: 186,
    kicker: _en('His side'),
    title: _en('If the first test is abnormal'),
    teaser: _en('One low number is a reason to repeat, not a conclusion. Why '
        "that's true is the most useful thing on this page."),
    shortAnswer: _en("Don't treat one low number as the answer. Semen results "
        'change a lot from sample to sample, so the next step is almost always '
        'a careful repeat at the same lab. If the second is low too, a '
        'specialist looks for the cause, and there are many options.'),
    scaleSetter: _en('Semen results vary a lot between samples from the same '
        'man. The same person can land on either side of a reference line a '
        'fortnight apart, for reasons as ordinary as a fever six weeks '
        "earlier. That's why nothing is decided on one test, and why the next "
        'step is almost always a second one, done properly.'),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en('If a number came back below a line, you may feel some mix of '
              "shame and finality. Neither fits what you're holding. What "
              "you're holding is one measurement of one sample on one day."),
        ],
      ),
      PvReadSection(
        heading: _en("Why doesn't one test decide anything?"),
        paragraphs: [
          _en('Making sperm takes about eleven weeks, so a sample shows what '
              'was happening two to three months ago. A fever, an illness, a '
              'stretch of very poor sleep or a course of certain medicines in '
              'that time shows up now, and may be gone by the next test.'),
          _en('How the sample is collected matters too. A sample given after '
              'a very short or very long gap, kept too cool or too warm, or '
              "with part of it lost won't show you fairly. The standard gap is "
              'two to seven days.'),
          _en("And the changes aren't small. Studies testing the same men "
              'again and again find swings big enough to cross reference '
              "lines in both directions. That's exactly why guidelines ask "
              'for two samples before anything is concluded.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you do next?'),
        paragraphs: [
          _en('Book the repeat. Most clinics suggest waiting a few weeks, '
              'longer if you were ill around the first one. Use the same lab '
              'so the two results can be compared.'),
          _en('Follow the collection instructions. Two to seven days since '
              'you last ejaculated, the whole sample collected, kept close to '
              'body temperature, and taken to the lab quickly. More results '
              'are spoiled by collection than by biology.'),
          _en('Then have both read together by an andrologist. Two reports '
              'side by side say much more than either one alone, and that '
              'reading is the appointment worth paying for.'),
        ],
      ),
      PvReadSection(
        heading: _en("What's worth changing in the meantime?"),
        paragraphs: [
          _en('Worth doing: stopping smoking and smokeless tobacco, cutting '
              'down heavy drinking, treating a fever properly, keeping laptops '
              'off your lap and keeping hot baths short. These have evidence '
              'behind them, and they work on the same eleven-week timescale.'),
          _en('Not worth doing: buying a pile of fertility supplements because '
              'of one report. The evidence for antioxidant supplements in male '
              'subfertility is weak, and this section says so in its own '
              'piece rather than selling you something.'),
          _en("And don't stop a prescribed medicine because you've read that "
              'it might affect sperm. Some do. The answer is to talk to '
              'whoever prescribed it, never to stop on your own.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is a repeat for?'),
        paragraphs: [
          _en("It's easy to see a repeat as the app or the doctor stalling. "
              "It's the opposite. A single sample gives you a number with no "
              'way to know how much of it is you and how much is the fortnight '
              'you happened to have.'),
          _en('Two samples give you a range, and a range is something an '
              'andrologist can work with.'),
          _en("That's why guidelines in most countries ask for two before "
              'anything is concluded. A clinic that changes a plan because of '
              'one report is moving faster than the evidence allows.'),
          _en("It's also why the second sample is worth doing properly, not "
              'quickly. Same lab, the standard two-to-seven-day gap, the whole '
              'sample collected, kept near body temperature and delivered '
              'promptly. A badly collected repeat loses you the comparison you '
              'were trying to make.'),
          _en('And if you were unwell in the weeks before the first one, '
              'especially with a fever, say so when you book. It may be worth '
              'waiting longer than usual, because you want to measure you, '
              'not the flu you had in March.'),
        ],
      ),
      PvReadSection(
        heading: _en('What if the repeat is also low?'),
        paragraphs: [
          _en("Then you have a pattern, not a one-off reading, and that's "
              'useful. It moves the conversation to why (an examination, '
              'hormone blood tests, sometimes a scan) and to what the options '
              'are. For most men, the options are much wider than they '
              'expect.'),
          _en("A low count isn't a closed door. IUI, IVF and ICSI exist for "
              'exactly this, and ICSI works with very small numbers of sperm. '
              "That's a conversation for when you get there, not tonight."),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): the causes a doctor looks for and
      // why the hormone panel comes next. Named so he knows what the
      // appointment is for, never so he can work out which one he has.
      PvReadSection(
        heading: _en('What can cause a low result?'),
        paragraphs: [
          _en('When the repeat is low too, the doctor looks for a reason. '
              'These are the common ones, and several can be treated.'),
        ],
        bullets: [
          _en('A varicocele: swollen veins in the scrotum, a bit like '
              'varicose veins in the leg. They warm the testes, and they are '
              'the most common cause found.'),
          _en('An infection, now or in the past, such as mumps after puberty '
              'or an infection of the prostate or the tubes that carry sperm.'),
          _en('Testes that came down late in childhood, or an injury or '
              'surgery there.'),
          _en("A hormone problem, where the brain doesn't send the testes a "
              'strong enough signal to make sperm.'),
          _en('Antibodies against sperm. Sometimes the immune system treats '
              'sperm as foreign, often after an injury, surgery or a vasectomy '
              "reversal, and they clump or struggle to swim. It's uncommon."),
          _en('Genes, such as a small missing piece of the Y chromosome or an '
              'extra X chromosome. These are looked for when the count is very '
              'low.'),
          _en('Medicines, anabolic steroids and testosterone, which can switch '
              'production down.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why are your hormones checked?'),
        paragraphs: [
          _en('Sperm are made on instructions from the brain. Two hormones, '
              'FSH and LH, travel from the pituitary gland to the testes. LH '
              'tells them to make testosterone, and FSH, with that '
              'testosterone, keeps sperm production going.'),
          _en('So a blood test for FSH, LH and testosterone shows where a '
              'problem sits. A high FSH usually means the testes are finding '
              'it hard to respond.'),
          _en('Low FSH and LH with low testosterone means '
              'the signal from the brain is weak, and that kind can often be '
              'treated with medicine.'),
          _en('Prolactin or thyroid is sometimes checked too. The test is a '
              'morning blood sample, because testosterone is highest early in '
              'the day. Quite often no cause is found, and treatment options '
              "don't depend on finding one."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Some results skip the repeat'),
      body: _en('See a doctor, rather than arranging another sample, if the '
          'report found no sperm at all, or if you have pain, swelling or a '
          'lump in a testis, very little or no semen when you ejaculate, '
          'trouble with erections or ejaculation, or if you take testosterone '
          'or anabolic steroids. Testosterone lowers sperm production. Don\'t '
          'stop it yourself. Take it to whoever prescribed it.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('How long should I wait before repeating?'),
        answer: _en('Usually a few weeks, and longer if you were ill around '
            'the first sample. Ask the clinic, and use the same lab so the two '
            'can be compared.'),
      ),
      PvReadFaq(
        question: _en('Does a low number mean we need IVF?'),
        answer: _en('Not on its own, and not from one test. Plenty of couples '
            'with a low first result conceive naturally. Where treatment is '
            "needed, it isn't always the most involved kind."),
      ),
      PvReadFaq(
        question: _en('Should I tell my partner?'),
        answer: _en('Yes. This is when men most often go quiet, and the '
            'silence is harder on a couple than the number is. She\'s already '
            "having every test going. You're not protecting her by carrying "
            'this alone.'),
      ),
    ],
    evidence: _en('WHO laboratory manual, sixth edition, 2021, including its '
        'guidance on repeat samples and how much results vary in the same '
        'man; NICE CG156; EAU Guidelines on Sexual and Reproductive Health, '
        'including the causes of male infertility and the hormone panel; '
        'Cochrane review of antioxidants for male subfertility. Sources '
        'checked September 2026.'),
    readNext: ['ttc_read_semen_analysis', 'ttc_read_heat_habits'],
  ),

  // ===========================================================================
  //  ⚠️ WRITTEN 2026-09-06 — THE THREE PIECES THE FIRST REBUILD SUBSTITUTED
  // ---------------------------------------------------------------------------
  //  The first pass at this door (2026-09-04) pointed three tiles at the
  //  nearest existing article rather than writing the piece the brief named:
  //  "The case for testing early" opened the semen-analysis article, "What
  //  three months looks like" opened the heat-and-habits article, and "Zinc
  //  and CoQ10, honestly" was a product shelf with no article behind it.
  //
  //  The rule that replaced that, stated by the user and worth keeping: reuse
  //  a piece only when it IS the piece. A card that promises a twelve-week
  //  plan and opens an essay with a plan somewhere in section five has not
  //  reused anything — it has substituted the closest thing and left the
  //  reader to notice.
  //
  //  So these three are written. The original articles are still untouched
  //  and still referenced where they are the piece.
  //
  //  ⚠️ NONE OF THE THREE STATES A REFERENCE LIMIT. Where a number is needed
  //  it comes from `kTtcSemenLimits`, and the abstinence window from the
  //  same file — one source, the same one the tool computes against.
  //
  //  ⚠️ CLINICAL READ OWED. All three carry Dr. Vikram Nair's byline because
  //  the door does; none has been past him. The supplement piece in
  //  particular quotes trial doses and Indian retail prices, and both are
  //  the kind of number that goes stale.
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  The short card that bridges into tab 2
  // ---------------------------------------------------------------------------
  //  Short by design — the brief calls it "a short card", and the argument is
  //  one paragraph long: the test is cheap, fast and answers half the
  //  question, so the reason to wait a year is habit rather than sense. It
  //  ends where tab 2 begins, with what the test involves and the tool.
  PvRead(
    id: 'ttc_read_case_for_testing',
    hue: 186,
    kicker: _en('His side'),
    title: _en('The case for testing early'),
    teaser: _en("One test, easy to find and cheap, and it answers a question "
        "a year of waiting can't."),
    shortAnswer: _en('Test early, not after a year. A semen analysis costs a '
        'few hundred rupees, takes a morning and answers about half the '
        "question. Doing it first doesn't mean you expect a problem. It's just "
        'the easiest test there is.'),
    scaleSetter: _en('A semen analysis is the cheapest, fastest and least '
        'invasive test in all of fertility. It costs a few hundred rupees, '
        'takes a morning, and rules in or out roughly half of the reasons a '
        "couple might be taking longer. Doing it early doesn't mean something "
        'is likely to be wrong. Finding out is just very easy.'),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Usually your partner goes first. Months of cycle tracking, '
              'then blood tests, then a scan, then a test of her tubes. Each '
              'one is slower, costs more and is more uncomfortable than the '
              'last.'),
          _en('Your test, which could have been done on day one, tends to '
              'come after all of that. That order is a habit, not a reason.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does it cost, and what does it save?'),
        paragraphs: [
          _en('In most Indian cities the test costs between three hundred and '
              'a thousand rupees at a diagnostic lab. The sample is given in '
              'a private room, or at home and delivered within the hour, and '
              'the result is back in a day or two.'),
          _en('What it saves is time. If your side is fine, you both know it, '
              'and the search narrows to things that can be looked at. If it '
              "isn't, you've found out in a week what waiting would have "
              'taken a year to hint at.'),
          _en('And because sperm take about three '
              'months to respond to any change, every month before you find '
              "out is a month that clock isn't running."),
        ],
      ),
      PvReadSection(
        heading: _en("When is it worth doing now, not after a year?"),
        bullets: [
          _en('Any time you have a known reason: a testis that had not come '
              'down as a child, surgery or injury there, mumps after puberty, '
              'chemotherapy, a swelling in the scrotum, or testosterone or '
              'steroid use, past or present.'),
          _en("At six months if your partner's cycles are irregular or she's "
              'over thirty-five, because the one-year rule assumes nothing '
              'else is going on.'),
          _en("Whenever the two of you would rather know than wait. There's "
              'no minimum.'),
        ],
      ),
      PvReadSection(
        heading: _en('How do you bring it up without it sounding like blame?'),
        paragraphs: [
          _en('The reason this test comes last is rarely medical. Suggesting '
              'it can sound like an accusation, and most couples would rather '
              'wait another six months than have that talk.'),
          _en('It helps to say the true thing plainly: half of these cases '
              'involve the man, his test is the easy one, and doing it first '
              'is the kind order, not the suspicious one.'),
          _en("If you're the man reading this: the sample isn't a judgement on "
              'anything. The result comes back to the two of you and nobody '
              "else, and nobody at the lab is judging."),
          _en("If you're his partner: the ask is \"let's do the easy test "
              "first\", not \"I think it's you\". Put that way, most men agree "
              "straight away. It's a small ask."),
        ],
      ),
      PvReadSection(
        heading: _en('What does a year of waiting cost?'),
        paragraphs: [
          _en('The standard advice is to try for a year before getting '
              "checked. That's sensible for a couple with no reason to think "
              'anything is wrong.'),
          _en("It's less sensible once you see what the year holds: twelve "
              'cycles of hope and disappointment, an age clock that keeps '
              'running, and, if your side is part of the answer, twelve months '
              'in which the one change that takes three months to work was '
              'never started.'),
          _en("That's a lot of time to lose to a test that takes one morning. "
              "Testing early doesn't shorten the year for anyone whose result "
              'is normal. It just means the year is spent knowing rather than '
              "wondering, and that's worth a few hundred rupees."),
        ],
        bullets: [
          _en('Have ready: the lab\'s name, how many days since you last '
              'ejaculated, and any medicine or supplement you take.'),
          _en('If you collect the sample at home, it goes to the lab within '
              'the hour, kept at body temperature. An inside pocket, not a '
              'car seat.'),
          _en('Ask for the printed report, not a phone summary. The tool in '
              'the next tab reads the printed numbers.'),
        ],
      ),
      PvReadSection(
        heading: _en("What can't the test tell you?"),
        paragraphs: [
          _en("It doesn't say whether you'll conceive. A normal result rules "
              'out the most common male causes and nothing more. A low result '
              'on one sample is a reason to repeat, not a diagnosis.'),
          _en('What the test involves, and how to read the report when it '
              'comes back, is all in the next tab.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Do I need a doctor to order it?'),
        answer: _en('In most Indian cities, no. Diagnostic labs do it on a '
            'walk-in basis. A referral helps if insurance is involved. Either '
            "way, it's worth having someone lined up to read the result "
            'properly afterwards.'),
      ),
      PvReadFaq(
        question: _en('Is it embarrassing?'),
        answer: _en('Most men expect it to be worse than it is. It\'s a '
            'private room at the lab, or a home sample in the lab\'s own '
            'container delivered within the hour. The staff have seen a '
            "thousand of these and won't remember yours."),
      ),
      PvReadFaq(
        question: _en('Should I change anything before the test?'),
        answer: _en('Two to seven days without ejaculating, no fever in the '
            'few weeks before if you can help it, and tell the lab about any '
            'medicine you take. Don\'t stop anything to get a "better" '
            'result. The point is to get a true one.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't wait for a test if"),
      body: _en('A new lump, or pain and swelling in one testis, needs a '
          'doctor this week, and it has nothing to do with fertility. So '
          'does very little or no semen, or trouble with erections or '
          'ejaculation. Those change what the test can even tell you, so '
          "they're looked at first."),
    ),
    evidence: _en('About half of couples with difficulty conceiving have a male '
        'factor involved, and semen analysis is the recommended first test '
        'for men, per NICE CG156 and ASRM and EAU guidance. Indian lab prices '
        'are from the test library. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Read your semen report'),
        value: _en('For when the result is back: every number explained, no '
            'final verdict, and someone to take it to.'),
        surfaceId: 'ttc_semen_report',
      ),
    ],
    readNext: ['ttc_read_semen_analysis', 'ttc_read_whose_side'],
  ),

  // ---------------------------------------------------------------------------
  //  The twelve-week plan — a GUIDE, written to be used
  // ---------------------------------------------------------------------------
  //  The heat-and-habits article explains the three levers and has a
  //  paragraph on why three months is the unit. This is the plan itself:
  //  which week, which change, and why the repeat is booked on day one.
  //  The article stays the explanation; this is the thing he does.
  PvRead(
    id: 'ttc_read_three_months',
    hue: 186,
    kicker: _en('His side'),
    title: _en('What three months looks like'),
    teaser: _en('The twelve-week plan: what to change in which week, and why '
        'the repeat test is booked on day one.'),
    shortAnswer: _en('Book the repeat test for twelve weeks away on day one. '
        'Make the set-up changes in week one, the habit changes in weeks two '
        'to six, and then hold steady without testing. Anything you change '
        "shows up around week twelve, because that's how long sperm take to "
        'make.'),
    scaleSetter: _en('Sperm are made all the time and take about eleven weeks '
        'from start to finish. So the sample in any test shows what your body '
        'was doing three months ago. This plan is built on that: anything you '
        'change today shows up around week twelve, and nothing shows up '
        'before then. The plan is short because the list of things with real '
        'evidence is short.'),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("This isn't a programme with a product at the end. It's three "
              'changes (tobacco in every form, heat, and the rest of everyday '
              'health) spread across twelve weeks in an order that tends to '
              'work in real life.'),
          _en('Pick the two that fit you best rather than all of them. Two '
              'you keep are worth more than five you drop in week three.'),
        ],
      ),
      PvReadSection(
        heading: _en('Day one: book the repeat test'),
        paragraphs: [
          _en('Before you change anything, book the semen analysis for twelve '
              "weeks from today. If it's booked at the start, it happens. If "
              "it's left until \"things have settled\", it doesn't."),
          _en("A test at week six measures the old batch, and that's the most "
              'common reason couples decide none of this works.'),
        ],
        bullets: [
          _en('Same lab as the first test, so the two can be compared.'),
          _en('Today\'s date noted in the reports folder, next to the first '
              'result.'),
        ],
      ),
      PvReadSection(
        heading: _en('Week one: the set-up changes'),
        paragraphs: [
          _en('The changes you make once, that then need no willpower.'),
        ],
        bullets: [
          _en('Tobacco out of the house. Cigarettes, bidi, gutka, khaini and '
              'paan masala all count, and the smokeless kinds are the ones '
              'nobody asks about.'),
          _en('The laptop onto a table. Hours on your lap means steady heat '
              'exactly where it matters.'),
          _en('Hot baths shorter, and saunas and steam rooms on hold for the '
              'twelve weeks.'),
          _en('Looser underwear. A small effect, and it costs nothing.'),
        ],
      ),
      PvReadSection(
        heading: _en('Weeks two to six: the ones that need support'),
        paragraphs: [
          _en('These are habits rather than one-off changes, so they need '
              "someone alongside you. That's why this works better as a "
              'couple than as your private project.'),
        ],
        bullets: [
          _en('Less alcohol. Heavy, regular drinking is the clear problem. '
              "The occasional drink isn't, and pretending otherwise makes the "
              'plan fail sooner.'),
          _en("More movement. A walk most days is enough. Extreme endurance "
              "training isn't the aim and can work against it."),
          _en('Anything at work, like heat, solvents, pesticides or long hours '
              'in a hot cab, raised with someone or cut down where you can.'),
          _en('Every medicine, supplement or "gym" product you take, written '
              'down for the appointment. Nothing stopped on your own.'),
          _en('Some strength work two or three times a week, if you enjoy it. '
              'Regular moderate exercise, weights included, is linked to better '
              'sperm numbers. Steroid-based "gym" products work the other way.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): what he eats, which this plan
      // said nothing about. Everyday Indian food, "linked to" and no more,
      // because the diet evidence is observational.
      PvReadSection(
        heading: _en('What should you eat?'),
        paragraphs: [
          _en("Food won't fix a low count on its own. But sperm are made from "
              'what you eat, and the pattern linked to healthier sperm is '
              'plain, ordinary food.'),
        ],
        bullets: [
          _en('More vegetables and fruit, of different colours, every day: '
              'amla, guava, oranges, tomatoes, spinach and carrots.'),
          _en('Dal, rajma, chana and other pulses, and a small handful of '
              'walnuts or almonds most days.'),
          _en('Whole grains, like whole-wheat roti, ragi, bajra and '
              'hand-pounded rice.'),
          _en('Fish once or twice a week if you eat it, and eggs and curd.'),
          _en('Less of the foods linked to poorer numbers: fried snacks, '
              'sweets, sugary drinks, processed meats and a lot of packaged '
              'food.'),
        ],
      ),
      PvReadSection(
        heading: _en("Weeks seven to eleven: hold steady, and don't test"),
        paragraphs: [
          _en("This is the slow stretch, and it's where most plans end. "
              "There's no feedback yet, because the sperm being made now "
              "won't be in a sample until week twelve. Two things help: the "
              'test is already booked, and you chose the two changes because '
              'you could keep them.'),
          _en('If something slips, it slips. Starting again a week later '
              'costs a week. Deciding the plan has failed costs the whole '
              'three months.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Six weeks is long enough to see a difference.'),
          fact: _en('A sample at six weeks measures sperm that started forming '
              'before anything changed. Nothing reliable shows until about '
              'week twelve.'),
        ),
      ),
      PvReadSection(
        heading: _en('What should you keep a note of?'),
        paragraphs: [
          _en('Two things, and both are for the appointment rather than for '
              'the app. First, a short log of sleep, alcohol, tobacco, '
              'anything hot and movement, so "I cut down" has numbers behind '
              'it when the second report is read.'),
          _en('The partner health tracker keeps it on your own account, in '
              'private. Second, the first '
              'report, in the reports folder beside the date you started the '
              'plan, so the andrologist at week twelve sees the before and '
              'after on one page.'),
        ],
        bullets: [
          _en('Any fever or bad illness during the twelve weeks, with the '
              'date. It can lower a sample for a whole cycle, and it\'s worth '
              'mentioning before the second result is read.'),
          _en('Any new medicine or supplement you start, with the date, for '
              'the same reason.'),
        ],
      ),
      PvReadSection(
        heading: _en('Week twelve: the repeat, read together'),
        paragraphs: [
          _en('Same lab, the standard two-to-seven-day window before the '
              'sample, and then both reports taken to an andrologist '
              'together. Two samples read side by side say far more than '
              "either alone. If the first was low and the second isn't, "
              "that's the pattern that tells you the changes were real."),
          _en("If the second is also below a line, it's still not a final "
              "answer. It's the point where a specialist looks for a cause, "
              'which is a different and more useful question than a third '
              'repeat.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en("What if I can't give up tobacco completely?"),
        answer: _en('Less is better than the same, and the smokeless kinds '
            'count as much as smoking. But this is the change with the most '
            "evidence behind it, so it's worth real effort and real help. A "
            'doctor can prescribe support for stopping.'),
      ),
      PvReadFaq(
        question: _en('Should I take a supplement during the twelve weeks?'),
        answer: _en('Read the piece on zinc and CoQ10 first. The evidence is '
            'weak, neither replaces anything above, and nothing here should '
            'be bought instead of stopping tobacco.'),
      ),
      PvReadFaq(
        question: _en('My first result was normal. Is this still worth '
            'doing?'),
        answer: _en('Yes, more gently. A normal result rules out the most '
            'common causes but says nothing about DNA damage. Tobacco and '
            'heavy drinking raise that damage, and it matters for '
            'miscarriage. Week one is worth doing either way.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Some of this isn't about habits"),
      body: _en('If you have a lump, pain or swelling in a testis, very little '
          'or no semen, or trouble with erections or ejaculation, or you take '
          'testosterone or anabolic steroids in any form, see a doctor now '
          'rather than starting a twelve-week plan. And never stop a '
          'prescribed medicine because of a plan. Take the list to the person '
          'who prescribed it.'),
    ),
    evidence: _en('Sperm take approximately 74 days to make, plus time to '
        'travel through the epididymis. Volume, concentration and total count '
        'improve measurably within about three months of stopping smoking. '
        'Effects of scrotal heat and DNA fragmentation are from peer-reviewed '
        'reviews of lifestyle factors in male fertility and EAU guidance. '
        'Links between diet, exercise and semen quality come from '
        'observational studies and reviews on PubMed Central, which show '
        'association rather than proof. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('What you can track'),
        value: _en('Sleep, alcohol, tobacco, heat and movement: your own log, '
            'on your own account.'),
        surfaceId: 'ttc_partner_health',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep both your reports together'),
        value: _en('Both results in one folder, in date order, for the '
            'appointment at week twelve.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: ['ttc_read_heat_habits', 'ttc_read_zinc_coq10'],
  ),

  // ---------------------------------------------------------------------------
  //  Zinc and CoQ10, honestly
  // ---------------------------------------------------------------------------
  //  The one piece in this door that names a negative trial by name. The
  //  brief asks for "weak-evidence" and the honest version of that is not
  //  "some studies suggest" — it is the Cochrane summary and the one large
  //  trial that found nothing, side by side, and then the doses and the
  //  rupees so the reader can decide with the facts rather than the
  //  packaging.
  PvRead(
    id: 'ttc_read_zinc_coq10',
    hue: 186,
    kicker: _en('His side'),
    title: _en('Zinc and CoQ10, honestly'),
    teaser: _en('The two supplements with any evidence at all: what the '
        "evidence shows, what they cost, and what they can't replace."),
    scaleSetter: _en('Lots of products are sold to men for this, and very few '
        'have any evidence behind them. Zinc and coenzyme Q10 are the two '
        'that do. Neither is a treatment, and both are worth far less than '
        'stopping tobacco. The honest summary of the research is "possibly a '
        'little, on some numbers, in some men". That\'s not nothing. It\'s '
        'also not what the packet says.'),
    shortAnswer: _en('Zinc and CoQ10 are the only two supplements with any '
        'real evidence for sperm, and that evidence is weak. They might help a '
        "little, on some numbers, in some men. They don't replace stopping "
        'tobacco, and they are no reason to skip the repeat test or a '
        'specialist.'),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The idea makes sense. Sperm are easily harmed by oxidative '
              'damage, and both of these are antioxidants. Zinc in particular '
              'is found in high amounts in semen and is involved in making '
              'sperm.'),
          _en("The trouble isn't the idea but the trials. They're "
              'small and short, they measure different things, and most '
              "don't measure what matters: whether a baby is born."),
        ],
      ),
      PvReadSection(
        heading: _en('What does the research show?'),
        paragraphs: [
          _en('The largest independent review, by Cochrane, has looked at '
              'antioxidant supplements for male subfertility several times. '
              'It concludes that they may increase the chance of a live '
              'birth, but that the evidence is low-certainty: small trials, '
              'at risk of bias, with wide margins.'),
          _en('On semen numbers, some trials show small improvements in '
              'motility or concentration and others show none.'),
          // ⚠️ "The one large, well-run trial" became "One large, well-run
          // trial" on 2026-09-26: FAZST (folic acid and zinc, JAMA 2020) is
          // also large and well run, and it is now named further down.
          _en('One large, well-run trial was the MOXI trial in the United '
              'States, published in 2020. It gave men a combined antioxidant '
              'formula for three to six months, compared with a dummy pill '
              '(placebo).'),
          _en('It found no difference in sperm numbers, DNA fragmentation or '
              "live births. It's among the strongest evidence there is, and "
              'its result is negative.'),
          _en('Put together: possibly a small benefit on some numbers, no '
              'reliable benefit on live births, and nothing close to the '
              'effect of stopping tobacco or getting a varicocele checked.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about zinc?'),
        bullets: [
          _en('What it is: a mineral found in high amounts in the prostate '
              'and semen, and needed to make sperm.'),
          _en('When it might help: in men who are low in it, from a poor '
              'diet, heavy drinking or some gut conditions. In men with '
              'normal levels the evidence is thin.'),
          _en('The dose in trials: usually around 25 to 66 mg a day of '
              "elemental zinc, for three months. More isn't better. High "
              'doses over time interfere with copper and cause nausea.'),
          _en('Cost in India: roughly ₹100 to ₹300 a month for a plain zinc '
              'tablet. The "male fertility" branded versions cost several '
              'times that for the same mineral.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about coenzyme Q10?'),
        bullets: [
          _en('What it is: a compound the body makes to produce energy in '
              "cells, including the sperm's tail."),
          _en('When it might help: on motility, in men whose motility is the '
              'low number. Several small trials show a small improvement. '
              'None shows a difference in pregnancy.'),
          _en('The dose in trials: 200 to 300 mg a day, for at least three '
              "months, because that's one round of sperm production."),
          _en('Cost in India: roughly ₹400 to ₹1,200 a month depending on the '
              "brand. It's the more expensive of the two, and the one with "
              'the weaker case for taking it without a reason.'),
        ],
      ),
      PvReadSection(
        heading: _en("What's on the shelf in India?"),
        paragraphs: [
          _en('Most chemists here stock zinc as zinc sulphate or zinc '
              'gluconate tablets, and the elemental zinc is printed in small '
              'type. A 220 mg zinc sulphate tablet has about 50 mg of '
              'elemental zinc, which is already at the top of the trial '
              'range, so one a day is plenty.'),
          _en('CoQ10 is sold as 100 mg or 300 mg capsules, mostly imported '
              'and priced to match.'),
          _en('The combined "male fertility" sachets and capsules are the '
              'same two ingredients plus vitamins, sold at three to five times '
              "the price. Their labels often don't state the elemental zinc at "
              "all, and that's the one number that matters for safety."),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): L-carnitine and folic acid for
      // men, the two ingredients most often added to the branded mixes.
      PvReadSection(
        heading: _en('What about L-carnitine and folic acid?'),
        paragraphs: [
          _en('L-carnitine is a nutrient that helps cells turn fat into '
              'energy, and sperm carry a lot of it. It is in many "male '
              'fertility" mixes. A few small trials found a small rise in '
              'movement, but the evidence is weaker than for CoQ10.'),
          _en('The MOXI trial included L-carnitine in its formula and found '
              'no benefit. So it is not a reason to buy the pricier mix.'),
          _en('Folic acid is well known for her side, and men are sometimes '
              'told to take it too. A large trial in the United States, the '
              'FAZST trial published in 2020, gave men folic acid with zinc '
              'for six months.'),
          _en('It found no improvement in sperm or in live births. So folic '
              'acid is not needed for your sperm unless a doctor finds you are '
              'low in folate. For your partner, folic acid before pregnancy is '
              'still strongly advised.'),
        ],
      ),
      PvReadSection(
        heading: _en("What can't they do?"),
        paragraphs: [
          _en('Neither fixes a varicocele, a blockage, a hormone problem or '
              'the effect of testosterone. Neither undoes the DNA damage from '
              "tobacco while you're still using it."),
          _en('And neither is a reason '
              'to skip the repeat test or the specialist. Taking a supplement '
              'instead of finding out why a number was low only buys three '
              'months of not knowing.'),
        ],
        mythFact: PvMythFact(
          myth: _en('A "male fertility" supplement is a treatment for a low '
              'count.'),
          fact: _en('Zinc and CoQ10 are the two ingredients with any '
              'evidence, and that evidence is weak. The branded mixes with '
              'many ingredients add nothing proven, at several times the '
              'price.'),
        ),
      ),
      PvReadSection(
        heading: _en('If you decide to take one'),
        bullets: [
          _en('Plain zinc or plain CoQ10, from a chemist, at the trial doses '
              'above.'),
          _en('For three months, one round of production, and then the '
              'repeat test. Not forever.'),
          _en('Tell the doctor at your appointment. It matters for reading '
              'the second result.'),
          _en('Along with the changes that have real evidence, never instead '
              'of them.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Should I take both?'),
        answer: _en("There's no good evidence that two work better than one, "
            'and the MOXI trial, which combined several, found no benefit. If '
            'motility is your low number, CoQ10 has the stronger case. If '
            'your diet is poor or you drink heavily, zinc does.'),
      ),
      PvReadFaq(
        question: _en('What about the branded fertility mixes?'),
        answer: _en('Mostly the same two ingredients plus vitamins C and E, '
            'selenium, L-carnitine and folate, at a much higher price. None '
            'of the extras has better evidence than the two named here, and '
            'some mixes go over a safe zinc dose.'),
      ),
      PvReadFaq(
        question: _en('Are there side effects?'),
        answer: _en('Zinc at high doses causes nausea and, over months, a lack '
            'of copper. CoQ10 is usually well tolerated, but it can interact '
            'with blood thinners, so anyone on warfarin should ask first.'),
      ),
      PvReadFaq(
        question: _en('Do they help if my result was normal?'),
        answer: _en("No trial has shown that. A supplement doesn't improve a "
            'normal result, and the money is better spent on a repeat test '
            "if there's any doubt."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("A supplement isn't the next step if"),
      body: _en('If the report found no sperm, if any number was low on two '
          'samples, or if you have a lump, pain or swelling in a testis, the '
          'next step is an andrologist, not a chemist. And never stop a '
          'prescribed medicine to make room for a supplement. Ask the person '
          'who prescribed it.'),
    ),
    evidence: _en('Cochrane review of antioxidants for male subfertility (de '
        'Ligny and colleagues, 2022 update): low-certainty evidence of a '
        'possible increase in live birth. Steiner and colleagues, Fertility '
        'and Sterility 2020 (the MOXI trial): no effect of a combined '
        'antioxidant formula on semen numbers, DNA fragmentation or live '
        'birth. Schisterman and colleagues, JAMA 2020 (the FAZST trial): no '
        'effect of folic acid and zinc for men on semen quality or live '
        'birth. Trial doses and Indian prices are approximate. Sources '
        'checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.product,
        title: _en('Zinc and CoQ10, on the shelf'),
        value: _en('Plain versions, at the trial doses, labelled honestly.'),
        surfaceId: 'ttc_supplements',
      ),
    ],
    readNext: ['ttc_read_heat_habits', 'ttc_read_three_months'],
  ),
];
