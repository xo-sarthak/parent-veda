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
    teaser: _en('Half of this involves him, it is the fastest thing in the '
        'whole workup to check, and it is the half most often left '
        'uninvestigated for a year.'),

    scaleSetter: _en('A male factor is involved in roughly half of couples '
        'who take longer than expected. That is not a statement about him — it '
        'is the reason the investigation should start with both of you, '
        'because his half takes one test and a few days, and hers takes months '
        'of timed bloods and scans.'),

    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist · 11 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_whose_side',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('In most Indian clinics the woman is investigated first. Her '
              'tests are slower, costlier and more invasive, and by the time '
              'anyone asks for a semen analysis several months have usually '
              'gone.'),
          _en('There is no medical reason for that order. There is a social '
              'one, and it is worth naming plainly: a semen analysis is felt '
              'as a judgement in a way a blood test is not, so it gets put '
              'off — by him, and often by everyone around him.'),
          _en('The practical case for doing it early has nothing to do with '
              'fairness. It is that it is quick, it is inexpensive, and a '
              'normal result closes off half the possible explanations in '
              'seventy-two hours.'),
        ],
      ),

      PvReadSection(
        heading: _en('What sperm health actually means'),
        paragraphs: [
          _en('Three things get measured, and they answer different '
              'questions.'),
        ],
        bullets: [
          _en('How many — the concentration per millilitre, and the total in '
              'the sample. This is the number everyone knows about and it is '
              'not the most important one.'),
          _en('How well they move — motility, and specifically progressive '
              'motility, meaning the proportion swimming forwards rather than '
              'in circles. Movement matters more than count, because the '
              'journey is long.'),
          _en('What shape they are — morphology, the proportion with normal '
              'form. This one is measured strictly and the normal figure is '
              'much lower than people expect.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Production takes about eleven weeks'),
          body: _en('Sperm are made continuously, and one full cycle of '
              'production takes roughly seventy-four days plus a couple of '
              'weeks to finish maturing. So the sample he gives today reflects '
              'what his body was doing about three months ago — and any change '
              'he makes now shows up in a test about three months from now. '
              'That is a long wait and it is also the reason a repeat test is '
              'usually scheduled that far out.'),
        ),
      ),

      PvReadSection(
        heading: _en('What it is not'),
        paragraphs: [
          _en('A semen analysis measures a sample, on a day. It is not a '
              'measure of virility, of health, or of anything about him as a '
              'partner — and the fact that this needs saying at all is most of '
              'why the test gets delayed.'),
          _en('It is also genuinely variable. The same man tested twice, six '
              'weeks apart, can produce noticeably different numbers — '
              'illness, a fever, a stressful month, how long since the last '
              'ejaculation. This is why an abnormal result is almost always '
              'repeated before anyone acts on it, and why a single low number '
              'should not be treated as a verdict.'),
        ],
        mythFact: PvMythFact(
          myth: _en('If he has fathered a child before, his side is fine.'),
          fact: _en('Not necessarily. Sperm production changes with age, '
              'illness, weight, medication and time — and secondary '
              'infertility, where a couple who conceived before cannot again, '
              'frequently has a male factor. A previous pregnancy is history, '
              'not a current test result.'),
        ),
      ),

      PvReadSection(
        heading: _en('Having the conversation'),
        paragraphs: [
          _en('This is the part no clinical page covers, and it is the part '
              'that usually decides whether the test happens.'),
          _en('What tends not to work is presenting it as his turn. Framed '
              'that way it lands as an accusation even when nothing of the '
              'sort was meant, and the usual response is not refusal but '
              'delay — next month, after this project, once work settles.'),
          _en('What tends to work is doing the first round together, as one '
              'errand. Both of you book, both of you give a sample of '
              'something, both of you get results back on the same day. That '
              'is also simply better medicine: investigating one half of a '
              'couple is how six months disappear.'),
          _en('It is worth knowing what the test is not, too, because that is '
              'usually the real objection underneath. There is no '
              'examination, no needle and no doctor in the room. It is a '
              'private room at a lab, or increasingly a sample produced at '
              'home and dropped off within the hour.'),
        ],
        tip: PvReadTip(
          title: _en('If he has already said no once'),
          body: _en('Leave it a fortnight and come back to it as logistics '
              'rather than as a subject — which lab, which morning, who is '
              'driving. A decision that has been argued about is hard to '
              'reverse; an appointment is easy to keep. And if it stays stuck, '
              'a short consult where a doctor asks for it is often what moves '
              'it, because it stops being your request.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Genuinely useful, and not the thing she opened this for.
        collapsible: true,
        summary: _en('Varicocele, infections, hormones and blockages — the '
            'causes that are found, and which are fixable.'),
        heading: _en('What actually causes a low result'),
        paragraphs: [
          _en('A varicocele is the commonest finding — enlarged veins in the '
              'scrotum that raise the temperature around the testes and impair '
              'production. It is found in a substantial minority of men with '
              'low results and is often repairable, though the evidence on '
              'whether repair improves live birth rates specifically is '
              'genuinely mixed rather than settled.'),
          _en('Beyond that: past infections, undescended testes in childhood, '
              'hormonal causes, certain medications, and blockages in the '
              'tubes carrying sperm. Several of these are correctable, and a '
              'few of them are correctable completely.'),
          _en('And in a real proportion of men no cause is found at all, which '
              'is unsatisfying and is not the same as nothing being done — the '
              'pathway from there is the same one either way.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('He refuses to get tested. What do I do?'),
        answer: _en('Common, and worth naming rather than pushing through. The '
            'thing that tends to move it is framing: not "get tested", but '
            '"let us both do the first round together and rule things out". '
            'The test itself is a sample given privately at a lab, with no '
            'examination and no procedure, and most men are surprised how '
            'ordinary it is.'),
      ),
      PvReadFaq(
        question: _en('Does his age matter?'),
        answer: _en('Less sharply than hers, and it is not nothing. Sperm '
            'quality and DNA integrity decline gradually from around the '
            'forties, and the effect is slower and less absolute than the '
            'change on her side. It is a factor, not a deadline.'),
      ),
      PvReadFaq(
        question: _en('Can a lifestyle change actually fix a low result?'),
        answer: _en('It can improve one, sometimes substantially, and it '
            'depends entirely on what is causing it. Tobacco, heat and weight '
            'are the levers with real evidence behind them. What lifestyle '
            'cannot fix is a blockage or a structural cause, which is why the '
            'test comes before the effort.'),
      ),
      PvReadFaq(
        question: _en('Should he test even if we have only been trying a few '
            'months?'),
        answer: _en('There is no harm in it, and there is a decent argument '
            'for it — it is cheap, quick, and a normal result removes a whole '
            'category of worry early. It becomes clearly worth doing at six '
            'months if anything about her cycles is irregular, or at any point '
            'if he has a known reason.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Reasons for him to be seen sooner'),
      body: _en('Do not wait out a year if he has had an undescended testis, '
          'testicular surgery or injury, a past mumps infection after '
          'puberty, chemotherapy or radiotherapy, a visible swelling in the '
          'scrotum, or difficulty with erections or ejaculation. And treat it '
          'as urgent — this week — if there is a new lump, or pain and '
          'swelling in one testis, both of which need looking at for reasons '
          'that have nothing to do with fertility.'),
    ),

    evidence: _en('Male factor involvement in roughly half of couples '
        'presenting with infertility, spermatogenesis of approximately 74 days '
        'plus epididymal transit, and varicocele as the commonest identifiable '
        'cause reflect standard andrology practice as described by ASRM and '
        'EAU. Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('What a semen analysis actually involves'),
        value: _en('How it is done, and how to read the report without '
            'panicking at it.'),
        surfaceId: 'ttc_read/ttc_read_semen_analysis',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Heat, habits and time'),
        value: _en('The three levers with real evidence, and roughly what '
            'each is worth.'),
        surfaceId: 'ttc_read/ttc_read_heat_habits',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to an andrologist'),
        value: _en('In confidence, on video, without a waiting room.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_semen_analysis', 'ttc_read_heat_habits'],
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
    title: _en('What a semen analysis actually involves'),
    teaser: _en('How the test is done, what the numbers on the report mean, '
        'and why "below normal" does not mean what it looks like it means.'),

    scaleSetter: _en('The reference numbers on the report are not a pass '
        'mark. They are the fifth percentile of men who fathered children '
        'naturally — meaning one in twenty men who conceived without any help '
        'would score below them. A result under the line is a reason to look '
        'further, never a verdict.'),

    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist · 11 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_semen_analysis',

    sections: [
      PvReadSection(
        heading: _en('How it is actually done'),
        paragraphs: [
          _en('A sample, produced by masturbation, into a sterile container. '
              'At a lab there is a private room; many labs will also allow '
              'collection at home if it can reach them within about an hour, '
              'kept close to body temperature.'),
          _en('The one instruction that matters is abstinence: two to seven '
              'days since the last ejaculation. Shorter and the count reads '
              'low; much longer and motility drops. Getting this wrong is the '
              'commonest reason a test has to be repeated, which costs a month '
              'as well as the fee.'),
          _en('No examination, no needle, no procedure. Results usually come '
              'back within a day or two, and in India this typically costs a '
              'few hundred to about fifteen hundred rupees depending on the '
              'lab — checked August 2026.'),
        ],
        tip: PvReadTip(
          title: _en('Book the repeat before you read the first one'),
          body: _en('Results vary between samples from the same man, so an '
              'abnormal first result is almost always repeated before anyone '
              'acts on it. Knowing that in advance takes most of the weight '
              'out of an unexpected number — the first report is a data point, '
              'not a diagnosis, and the second one is what a decision gets '
              'made on.'),
        ),
      ),

      PvReadSection(
        heading: _en('Reading the report'),
        paragraphs: [
          _en('The current WHO reference limits, from the 2021 sixth edition, '
              'are the ones most Indian labs now print. They are worth having '
              'in front of you, with the caveat above firmly attached.'),
        ],
        bullets: [
          _en('Concentration — 16 million per millilitre or above.'),
          _en('Total motility — 42 per cent or above moving at all.'),
          _en('Progressive motility — 30 per cent or above moving forwards. '
              'This is usually the most informative single number.'),
          _en('Normal forms (morphology) — 4 per cent or above. Yes, four. '
              'The measurement is deliberately strict and a result of 5 per '
              'cent is normal, not borderline.'),
          _en('Volume, pH and vitality are also reported; vitality is only '
              'assessed when motility is low.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Where these numbers come from'),
          body: _en('They are the fifth percentile of roughly 3,500 men whose '
              'partners conceived within a year. That is the entire basis of '
              'the "normal" line — so a man slightly below it is in the same '
              'range as one in twenty men who fathered children without any '
              'assistance at all. It is a signal to investigate, not a '
              'conclusion.'),
        ),
      ),

      PvReadSection(
        heading: _en('The words on the report, in plain English'),
        bullets: [
          _en('Oligozoospermia — fewer sperm than the reference count.'),
          _en('Asthenozoospermia — reduced motility.'),
          _en('Teratozoospermia — a lower proportion of normal forms.'),
          _en('Oligoasthenoteratozoospermia — all three together. It is a '
              'frightening word and it is only those three findings stacked '
              'into one term.'),
          _en('Azoospermia — no sperm found in the sample. This one is '
              'genuinely different, needs a specialist, and still has '
              'pathways: in many cases sperm can be retrieved directly, and '
              'the cause is sometimes an obstruction that can be treated.'),
        ],
      ),

      PvReadSection(
        heading: _en('If the result is normal and nothing is happening'),
        paragraphs: [
          _en('This is commoner than the alternative, and it lands oddly — '
              'relief and frustration at the same time, because a normal '
              'result closes a door without opening one.'),
          _en('What it genuinely means is that the commonest male causes have '
              'been ruled out, which is worth having. What it does not mean is '
              'that his side is certainly fine: a standard analysis counts '
              'sperm and watches them move, and it cannot see DNA damage, '
              'cannot assess how they behave near an egg, and cannot tell you '
              'whether they would fertilise one.'),
          _en('So a normal report moves the investigation to her side rather '
              'than ending it — and if everything there is normal too, that '
              'combination has a name. Unexplained infertility is a real '
              'diagnosis rather than a shrug, it accounts for a substantial '
              'minority of couples, and it has a standard treatment pathway of '
              'its own.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('A normal result is not a wasted test'),
          body: _en('Couples often feel a normal semen analysis achieved '
              'nothing. It removed half the possible explanations in three '
              'days, for a few hundred rupees, and it means nothing that '
              'follows will be aimed at the wrong person. That is exactly what '
              'a good first test is supposed to do.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Ordered tests he may be sent for next — useful when it
        // happens, and premature worry when it has not.
        collapsible: true,
        summary: _en('DNA fragmentation, hormone panels and scans — what gets '
            'ordered next, and which are worth paying for.'),
        heading: _en('If the first test is abnormal'),
        paragraphs: [
          _en('A repeat, first, usually after about three months — which is '
              'one full production cycle, and long enough for any change he '
              'makes to show.'),
          _en('Then, depending on the picture: a hormone panel including FSH, '
              'LH and testosterone; a scrotal ultrasound looking for a '
              'varicocele or an obstruction; and in some cases genetic '
              'testing, which is standard practice where the count is very '
              'low or absent.'),
          _en('Sperm DNA fragmentation testing is widely offered privately in '
              'India and is worth a careful question. It has genuine uses — '
              'recurrent miscarriage, repeated failed cycles — and it is also '
              'sold routinely where it will not change what anyone does next. '
              'Ask what the result would alter before paying for it.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('He is embarrassed about producing a sample at a lab.'),
        answer: _en('Most labs allow home collection if you can get it there '
            'within about an hour, kept warm — ask when booking rather than on '
            'the day. It is an extremely common request and no one at the lab '
            'will find it unusual.'),
      ),
      PvReadFaq(
        question: _en('Does a fever affect the result?'),
        answer: _en('Yes, and noticeably. A high fever can depress sperm '
            'production for two to three months afterwards, because it '
            'affects the cycle already in progress. If he was ill in the '
            'months before the test, that is worth mentioning — it may be the '
            'whole explanation.'),
      ),
      PvReadFaq(
        question: _en('The report says morphology is 3 per cent. Is that '
            'terrible?'),
        answer: _en('It is just below the reference limit of 4 per cent, and '
            'morphology on its own is the weakest of the three predictors. It '
            'is a reason to repeat the test and look at the whole picture, not '
            'a result to act on alone.'),
      ),
      PvReadFaq(
        question: _en('Can we do IUI or IVF with a low result?'),
        answer: _en('Frequently, yes — that is much of what those treatments '
            'exist for. IUI needs a reasonable number of motile sperm; ICSI, '
            'where a single sperm is injected into each egg, works with very '
            'few indeed. A low count narrows the route rather than closing '
            'it.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Take an abnormal result to a person, not a search engine'),
      body: _en('An andrologist or a urologist reads these in context — his '
          'history, his examination, the whole panel — and a report read '
          'alone at midnight is the least reliable version of it. Book '
          'straight away rather than repeating first if the sample showed no '
          'sperm at all, if there is pain or a lump in a testis, or if he has '
          'symptoms of low testosterone. Everything else usually starts with '
          'a repeat.'),
    ),

    evidence: _en('Reference limits are the WHO laboratory manual for the '
        'examination and processing of human semen, sixth edition (2021): '
        'concentration 16 million per millilitre, total motility 42 per cent, '
        'progressive motility 30 per cent, normal forms 4 per cent — each the '
        'fifth centile of a reference population of approximately 3,500 men '
        'whose partners conceived within twelve months. Abstinence of two to '
        'seven days per the same manual. Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep his reports with yours'),
        value: _en('One place for both sides, so a second opinion takes an '
            'evening rather than a week.'),
        surfaceId: 'ttc_records',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The test library'),
        value: _en('His tests listed beside hers, with what each costs in '
            'India.'),
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
    teaser: _en('Three levers with real evidence behind them, roughly what '
        'each is worth, and how long before any of it shows up on a test.'),

    scaleSetter: _en('Sperm are made continuously, so unlike almost anything '
        'else in fertility this responds to change — but on its own schedule. '
        'A change made today shows up in a test in about three months. That is '
        'the deal: real improvement, delayed feedback.'),

    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist · 11 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_heat_habits',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('There is a large industry selling men things for this, and a '
              'short list of things that actually have evidence. The short '
              'list is below, roughly in order of how much it is worth.'),
        ],
      ),

      PvReadSection(
        heading: _en('Tobacco, in all its forms'),
        paragraphs: [
          _en('The clearest of the three. Smoking measurably lowers count, '
              'motility and normal forms, and raises sperm DNA fragmentation '
              'by around ten per cent — the damage that a standard semen '
              'analysis does not show and that matters for miscarriage risk.'),
          _en('It is also the one that reverses. Men studied before and after '
              'stopping showed significant improvement in volume, '
              'concentration and total count within about three months — one '
              'production cycle, which is exactly what you would expect.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Gutka, khaini and paan masala count'),
          body: _en('Asked "do you smoke?", a man who chews tobacco will '
              'usually say no, and he is answering honestly as he understands '
              'the question. Smokeless tobacco carries the same relevance '
              'here, and in much of India it is the commoner form. It is worth '
              'asking about specifically rather than assuming the general '
              'question covered it.'),
        ),
      ),

      PvReadSection(
        heading: _en('Heat'),
        paragraphs: [
          _en('The testes sit outside the body for a reason: sperm production '
              'needs a temperature a couple of degrees below core. Anything '
              'that raises scrotal temperature for sustained periods reduces '
              'output.'),
          _en('The practical list is short and unglamorous, and it is the '
              'cheapest thing on this page to change.'),
        ],
        bullets: [
          _en('A laptop actually on the lap, for hours. Use a table.'),
          _en('Long hot baths, saunas and steam rooms.'),
          _en('Tight synthetic underwear, and long stretches in a hot vehicle '
              'cabin — relevant for drivers specifically.'),
          _en('A varicocele raises the temperature from the inside, which is '
              'why it comes up here at all and why it is worth having a '
              'swelling looked at.'),
        ],
      ),

      PvReadSection(
        heading: _en('Alcohol, weight and the rest'),
        paragraphs: [
          _en('Heavy or chronic drinking raises DNA fragmentation by roughly '
              'the same magnitude smoking does, disrupts the hormonal axis, '
              'and in sustained use can affect the testes directly. The '
              'evidence on light or occasional drinking is much weaker, and '
              'the honest position is that heavy is clearly a problem and '
              'occasional is probably not.'),
          _en('Weight matters through hormones — fat tissue converts '
              'testosterone to oestrogen, so a significantly raised weight '
              'shifts the balance. The effect is real and it is slower to '
              'shift than tobacco or heat.'),
          _en('Exercise helps, and extremes do not: intense endurance training '
              'and anabolic steroids both suppress production. Steroids are '
              'worth naming outright, because their effect on sperm can take '
              'many months to recover and men taking them almost never '
              'volunteer it.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Supplements will fix a low count.'),
          fact: _en('The evidence for antioxidant supplements in male '
              'infertility is weak and inconsistent — some trials show a '
              'modest effect on parameters, few show a difference in live '
              'births. Zinc and CoQ10 are the two with the most respectable '
              'data, and both are worth far less than stopping tobacco. They '
              'are not a substitute for finding out what is actually causing a '
              'low result.'),
        ),
      ),

      PvReadSection(
        heading: _en('What three months actually looks like'),
        paragraphs: [
          _en('The hardest thing about this list is not any single item on '
              'it. It is that nothing gives feedback for twelve weeks, so it '
              'is very easy to start and quietly stop.'),
          _en('A version that tends to survive: pick the two that apply most '
              'to him rather than all of them, book the repeat test for three '
              'months out on the day you start, and do not test before then. '
              'A disappointing result at six weeks is measuring the old batch '
              'and is the commonest reason couples give up on this.'),
          _en('It also helps to make the changes structural rather than '
              'effortful. A laptop on a table stays on a table. Tobacco out '
              'of the house is a decision made once. Anything that needs '
              'remembering every day is the thing that stops in week three.'),
        ],
        bullets: [
          _en('Week one — the structural changes. Laptop off the lap, hot '
              'baths shortened, tobacco out of the house.'),
          _en('Weeks two to six — the ones that need support. Alcohol down, '
              'movement up, and any workplace exposure raised with someone.'),
          _en('Week twelve — the repeat test, booked at the start so it '
              'actually happens.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Real, and reading it before there is a reason to is how a
        // page like this creates worry rather than removing it.
        collapsible: true,
        summary: _en('Medicines and exposures that affect sperm, and are '
            'almost never mentioned at an appointment.'),
        heading: _en('Things worth mentioning to a doctor'),
        paragraphs: [
          _en('Several ordinary medicines affect sperm production and almost '
              'nobody thinks to bring them up: some for hair loss, certain '
              'antibiotics, some blood pressure and psychiatric medicines, and '
              'anything containing testosterone — which suppresses production '
              'rather than helping it, the opposite of what most men assume.'),
          _en('Occupational exposure matters too, and is easy to forget: '
              'pesticides, solvents, heavy metals, and sustained heat at work. '
              'Painters, welders, farmers and long-distance drivers all have a '
              'reason to mention what they do for a living.'),
          _en('None of this is a reason to stop anything on your own. It is a '
              'list to take to the appointment.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('How long until any of this makes a difference?'),
        answer: _en('About three months to show on a test, because that is one '
            'full production cycle. Which means a repeat test sooner than that '
            'is measuring the old batch, and a disappointing result at six '
            'weeks says nothing about whether the changes are working.'),
      ),
      PvReadFaq(
        question: _en('Do boxers really work better than briefs?'),
        answer: _en('There is some evidence that looser underwear is '
            'associated with slightly better parameters, and it is a very '
            'small effect compared with tobacco or heat exposure. It costs '
            'nothing to switch, and it is not the thing that will change a '
            'result on its own.'),
      ),
      PvReadFaq(
        question: _en('Is cycling bad for sperm?'),
        answer: _en('Long-distance cycling has been associated with reduced '
            'parameters, through both pressure and heat. Ordinary commuting '
            'has not. If he rides for many hours a week, a wider saddle and '
            'some time off is a reasonable experiment; casual riding is not '
            'worth worrying about.'),
      ),
      PvReadFaq(
        question: _en('Does frequent sex lower his count?'),
        answer: _en('It lowers the count in any individual sample and does not '
            'lower fertility — the total available across the fertile window '
            'is what matters, and every one to two days is the recommended '
            'frequency precisely because it balances count against motility. '
            '"Saving it up" is the more common mistake.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Some of this is not a lifestyle question'),
      body: _en('See a doctor rather than making changes and waiting if he '
          'has a swelling, lump or aching in the scrotum, difficulty with '
          'erections or ejaculation, very little or no semen, or if he takes '
          'testosterone or anabolic steroids in any form. And do not stop '
          'prescribed medication on the strength of anything on this page — '
          'take the list to the person who prescribed it.'),
    ),

    evidence: _en('Effects of smoking and chronic alcohol use on sperm DNA '
        'fragmentation, and improvement in volume, concentration and total '
        'count within approximately three months of smoking cessation, from '
        'peer-reviewed reviews of lifestyle and environmental factors in male '
        'fertility indexed on PubMed Central. Scrotal temperature and '
        'varicocele effects, and the mixed evidence on varicocele repair '
        'improving live birth rates, per the same literature. Reviewed August '
        '2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('What he can track'),
        value: _en('His own habits and health, on his side of the app, '
            'privately.'),
        surfaceId: 'ttc_partner',
      ),
      PvReadNextStep(
        kind: PvNextKind.product,
        title: _en('The two supplements with any evidence'),
        value: _en('Zinc and CoQ10, honestly described — including what they '
            'are not.'),
        surfaceId: 'ttc_supplements',
      ),
      PvReadNextStep(
        kind: PvNextKind.course,
        title: _en('The half nobody talks about'),
        value: _en('A short course built entirely around his side of this.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_whose_side'],
  ),
];
