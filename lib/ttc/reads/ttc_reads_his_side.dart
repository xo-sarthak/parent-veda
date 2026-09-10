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
        // ⚠️ UNFOLDED 2026-09-06 — Step 7 of the brief: "remove the
        // accordions". Was collapsible with a summary line; the section is
        // unchanged, it simply no longer starts shut.
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
            _en('${l.name} — ${l.limitText} or above.'
                '${l.note == null ? '' : ' ${l.note}'}'),
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
        // ⚠️ UNFOLDED 2026-09-06 — Step 7 of the brief: "remove the
        // accordions". Was collapsible with a summary line; the section is
        // unchanged, it simply no longer starts shut.
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
        // ⚠️ UNFOLDED 2026-09-06 — Step 7 of the brief: "remove the
        // accordions". Was collapsible with a summary line; the section is
        // unchanged, it simply no longer starts shut.
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
    teaser: _en('It is not the end of the road, and it is the one result that '
        'goes to a specialist rather than to a second sample.'),
    scaleSetter: _en('Azoospermia means no sperm were seen in the sample. It '
        'is uncommon, it is frightening to read, and it is very often not what '
        'it sounds like: in many men sperm are being made and cannot get out, '
        'and in many others they can be retrieved directly. This is the one '
        'result where the next step is an andrologist rather than a repeat.'),
    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('If that is what your report says, the first thing worth knowing '
              'is that the word describes one sample on one day. The second is '
              'that it is not one condition — it is two quite different '
              'situations that happen to look the same on a slide, and telling '
              'them apart is most of what the next appointment is for.'),
        ],
      ),
      PvReadSection(
        heading: _en('Made but blocked, or not being made'),
        paragraphs: [
          _en('Obstructive azoospermia means sperm are being produced normally '
              'and cannot reach the sample — a blockage somewhere along the '
              'way. Causes include an infection years ago, surgery in '
              'childhood, an absent vas deferens present from birth, or a '
              'vasectomy. In many of these, sperm can be retrieved, and some '
              'blockages can be repaired surgically.'),
          _en('Non-obstructive azoospermia means production itself is low or '
              'absent. Even here, sperm are frequently found in the testis '
              'when a surgeon looks for them, and used in IVF with ICSI.'),
          _en('The distinction is not one you can make from the report. It '
              'takes an examination, hormone bloods and sometimes a scan, and '
              'that is exactly the appointment to ask for.'),
        ],
      ),
      PvReadSection(
        heading: _en('What the appointment usually involves'),
        paragraphs: [
          _en('A physical examination, which sounds trivial and is not — a '
              'missing vas deferens or a varicocele is found by hand in a '
              'minute.'),
          _en('Blood tests, usually FSH and testosterone, which say a good deal '
              'about whether production is happening.'),
          _en('A repeat sample, done properly, because occasionally a small '
              'number of sperm are found on a second look and that changes '
              'everything about the plan.'),
          _en('Genetic tests in some cases — karyotype and Y-chromosome '
              'microdeletion — which matter for what is likely to be found and '
              'for what it means for a child.'),
        ],
      ),
      PvReadSection(
        heading: _en('Two things worth not doing tonight'),
        paragraphs: [
          _en('Do not buy anything. There is a large market in supplements '
              'sold to men with this result and nothing on it changes an '
              'obstruction or restores absent production.'),
          _en('Do not conclude anything about your marriage, your body or what '
              'is possible from a word on a page. This is the point at which '
              'men '
              'most often stop talking, and it is the point at which talking '
              'matters most — to her, and to somebody qualified.'),
        ],
      ),
      PvReadSection(
        heading: _en('Telling her, and telling nobody else'),
        paragraphs: [
          _en('This is the point at which men most reliably go silent, and the '
              'silence does more damage than the result. She has almost '
              'certainly been through a series of tests already, some of them '
              'uncomfortable and most of them public in a way yours was not, '
              'and she is not fragile about this in the way you are imagining.'),
          _en('What she will notice, and quickly, is that something has '
              'changed and you are not saying what. A couple can absorb a '
              'difficult result together. What is much harder to absorb is one '
              'person quietly carrying something and the other guessing at '
              'it.'),
          _en('Beyond her, tell nobody until you have seen a specialist. Not '
              'because it is shameful — it is not — but because you do not yet '
              'know what you are telling them. "No sperm were found in one '
              'sample and we are seeing somebody" is a true sentence. Anything '
              'more definite is one you would be inventing, and it will come '
              'back to you from relatives for years.'),
          _en('And if you find yourself unable to talk about it at all, or not '
              'sleeping, or avoiding her, that is worth saying to a doctor in '
              'its own right. Men are offered counselling in fertility care far '
              'less often than women are, and they are not offered it because '
              'nobody asks.'),
        ],
      ),
      PvReadSection(
        heading: _en('And the honest limits'),
        paragraphs: [
          _en('Not every man with this result will have sperm retrieved. Some '
              'will not, and that is a real outcome that deserves saying '
              'rather than glossing over.'),
          _en('What is also true is that a great many men who read this word '
              'first assume it means nothing is possible, and for most of them '
              'that is wrong. The distance between "no sperm in this sample" '
              'and "no path from here" is very large, and only a specialist '
              'can tell you where on it you are.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('This one goes to an andrologist, not to a repeat'),
      body: _en('Ask your doctor to refer you to an andrologist or a urologist '
          'with a fertility interest, and go sooner rather than later — some '
          'causes are time-sensitive and all of them are easier to plan around '
          'early. Go sooner still if you have pain, swelling or a lump in a '
          'testis, or if you take testosterone or anabolic steroids: '
          'testosterone suppresses sperm production, and that is one of the '
          'few genuinely reversible causes on this list. Do not stop it '
          'yourself — take it to whoever prescribed it.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Does this mean we cannot have a child?'),
        answer: _en('No. It means this sample had none, and the reason has to '
            'be established before anybody can say anything about what is '
            'possible. Retrieval works for many men, and some blockages are '
            'repairable.'),
      ),
      PvReadFaq(
        question: _en('Should I repeat the test first?'),
        answer: _en('A repeat is usually done, but as part of the workup rather '
            'than instead of it. Book the specialist; they will arrange the '
            'repeat alongside the examination and the bloods.'),
      ),
      PvReadFaq(
        question: _en('Is it something I did?'),
        answer: _en('Almost never. The common causes are congenital, from an '
            'old infection or surgery, or genetic. Heat and lifestyle affect '
            'counts; they do not usually produce this result.'),
      ),
    ],
    evidence: _en('WHO laboratory manual for the examination and processing of '
        'human semen, sixth edition, 2021; EAU Guidelines on Sexual and '
        'Reproductive Health (male infertility); AUA/ASRM guidance on the '
        'evaluation of azoospermia; NICE CG156. Reviewed August 2026.'),
    readNext: ['ttc_read_semen_analysis'],
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
    teaser: _en('Every term on the page, said the way somebody would say it. '
        'No numbers to pass, no verdicts.'),
    scaleSetter: _en('A semen report is written for a laboratory, not for the '
        'person it is about. Most of what looks alarming on it is a naming '
        'convention: a word ending in "-spermia" is simply a description of '
        'one measurement being low, not a diagnosis of anything.'),
    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('You will not need all of this. Read the two or three lines that '
              'match what is printed on yours and ignore the rest.'),
        ],
      ),
      PvReadSection(
        heading: _en('The four numbers with reference lines'),
        paragraphs: [
          _en('These are the four the reference limits apply to. The limits '
              'themselves are the fifth percentile of men whose partners '
              'conceived within a year — not a pass mark.'),
        ],
        bullets: [
          for (final l in kTtcSemenLimits)
            _en('${l.name} — ${l.plain} Reference line: ${l.limitText} or '
                'above.'),
        ],
      ),
      PvReadSection(
        heading: _en('The other things it measures'),
        bullets: [
          _en('Volume — how much semen there was, in millilitres. Reported, and '
              'not one of the four. A very low volume with everything else '
              'normal is worth mentioning to a doctor.'),
          _en('pH — how acidic or alkaline. Almost always normal, and only of '
              'interest alongside a low volume.'),
          _en('Vitality — the share alive. Only measured when motility is low, '
              'to tell "not moving" apart from "not alive".'),
          _en('Liquefaction time — semen is thick when produced and thins '
              'within about twenty minutes. A long liquefaction time is '
              'occasionally relevant.'),
          _en('Round cells or leucocytes — other cells present. A high count '
              'sometimes suggests infection and is worth asking about.'),
          _en('Agglutination — sperm sticking together. Occasionally points to '
              'antibodies.'),
        ],
      ),
      PvReadSection(
        heading: _en('The -spermia words, and what each one is describing'),
        paragraphs: [
          _en('These are the terms most likely to send somebody to a search '
              'engine at midnight. Each one is a label for one measurement '
              'being below a line, and none of them is a diagnosis on its own.'),
        ],
        bullets: [
          _en('Oligozoospermia — concentration below the line. "Few sperm".'),
          _en('Asthenozoospermia — motility below the line. "Slow sperm".'),
          _en('Teratozoospermia — normal forms below the line. "Oddly shaped".'),
          _en('Oligoasthenoteratozoospermia (OAT) — all three at once. It is a '
              'long word for a common combination, not a rare disease.'),
          _en('Azoospermia — no sperm seen in the sample. The one that goes to '
              'a specialist rather than a repeat, and it has its own piece in '
              'this section.'),
          _en('Cryptozoospermia — none seen at first, a few found after the '
              'sample is spun down. Better news than azoospermia.'),
          _en('Normozoospermia — everything at or above the reference lines.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why the labels sound worse than the findings'),
        paragraphs: [
          _en('The naming convention is the problem. Medicine builds these '
              'words by stacking Greek roots onto "-zoospermia", so a modest '
              'reduction in three measurements becomes '
              '"oligoasthenoteratozoospermia" — twenty-eight letters '
              'describing something extremely common. The word looks like a '
              'rare disease and describes an ordinary finding.'),
          _en('Nothing in that vocabulary is graded, either. There is no mild, '
              'moderate or severe built into the term: a concentration a '
              'fraction under the line and one far under it attract exactly '
              'the same word. So the label tells you which measurement was '
              'below a reference line, and nothing whatsoever about how far.'),
          _en('That is worth holding on to before you search any of them. A '
              'search engine will return the worst version of every one of '
              'these words, because the worst version is what gets written '
              'about.'),
        ],
      ),
      PvReadSection(
        heading: _en('Two things Indian reports do differently'),
        paragraphs: [
          _en('Many laboratories here still print reference columns from the '
              'fifth WHO edition, or from their own internal ranges, alongside '
              'the result. The older numbers are higher, so the same sample can '
              'read as below the line on one report and within it on another. '
              'Ask which edition the reference column is from; the numbers in '
              'this section are the 2021 sixth edition.'),
          _en('And a good many reports add a comment or an impression at the '
              'foot — a sentence of interpretation written by whoever signed '
              'it. That line is worth reading and worth taking to your '
              'appointment, but it is one professional\'s reading of one '
              'sample and not a diagnosis either.'),
        ],
      ),
      PvReadSection(
        heading: _en('What the report does not say'),
        paragraphs: [
          _en('It does not say whether you are fertile. There is no such test — '
              'the only proof of fertility is a pregnancy, and plenty of men '
              'with results below a line have fathered children.'),
          _en('It does not say whose "fault" anything is. About half of couples '
              'having difficulty have a male factor involved, very often '
              'alongside a female one, and the word fault does not appear '
              'anywhere useful in this subject.'),
          _en('And it does not say what to do. That is a conversation with '
              'somebody who can put these numbers next to an examination, your '
              'history and her side of it.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Take the sheet, not the summary'),
      body: _en('When you see anybody about this, bring the printed report '
          'rather than a number you remembered. If the report mentions no '
          'sperm found, a very low volume, or a high white-cell count, say so '
          'when you book — those change how soon you should be seen. And see '
          'somebody promptly rather than repeating first if you have pain, '
          'swelling or a lump in a testis, difficulty with erections or '
          'ejaculation, or if you take testosterone or anabolic steroids.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('My morphology is 4 per cent. Is that terrible?'),
        answer: _en('No — it is normal. The measurement is deliberately strict '
            'and the reference line is 4 per cent, so 4 is at the line and 5 '
            'is comfortably above it. This number alarms more men than any '
            'other on the page and it should not.'),
      ),
      PvReadFaq(
        question: _en('The report has a long Latin word on it. Is it serious?'),
        answer: _en('Usually it is a label for one number being below a line, '
            'described above. The length of the word says nothing about the '
            'seriousness of the finding.'),
      ),
      PvReadFaq(
        question: _en('Different labs, different reference values. Why?'),
        answer: _en('Some labs still print older WHO editions, and a few print '
            'their own. Ask which edition the reference column is from — the '
            'numbers here are the 2021 sixth edition.'),
      ),
    ],
    evidence: _en('WHO laboratory manual for the examination and processing of '
        'human semen, sixth edition, 2021, including its nomenclature; EAU '
        'Guidelines on Sexual and Reproductive Health; NICE CG156. Reference '
        'limits on this page are generated from the same source the rest of '
        'this section uses. Reviewed August 2026.'),
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
    teaser: _en('What a normal semen analysis actually rules out, and the two '
        'things it does not.'),
    scaleSetter: _en('A result with everything at or above the reference lines '
        'is genuinely good news and it is worth having. It rules out the '
        'commonest male causes. What it does not do is prove fertility, or '
        'mean the question is closed if you have been trying for a while — and '
        'the commonest mistake after a normal result is to stop looking.'),
    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Take the good news first, because men are oddly reluctant to. A '
              'normal analysis means the numbers most likely to be the problem '
              'are not the problem. That is a real answer and it took one '
              'test to get.'),
        ],
      ),
      PvReadSection(
        heading: _en('What it rules out'),
        paragraphs: [
          _en('Low concentration, poor movement and abnormal shape are, '
              'between them, most of what a semen analysis is looking for. All '
              'three being in the usual range means the ordinary male-factor '
              'explanations are unlikely.'),
          _en('It also means a repeat is not the next step. Repeating a normal '
              'test is a common way to spend money and months without '
              'learning anything.'),
        ],
      ),
      PvReadSection(
        heading: _en('What "normal" is measured against'),
        paragraphs: [
          _en('It is worth knowing what the lines you cleared actually are. '
              'They are the fifth percentile of men whose partners conceived '
              'within a year — meaning one man in twenty who fathered a child '
              'naturally would have scored below them.'),
          _en('That cuts both ways, and the second way is the useful one. '
              'Clearing them is not a distinction; a great many men do. And '
              'being under one of them is not a disqualification, because one '
              'in twenty fathers was.'),
          _en('So "normal" here means "not in the group worth investigating '
              'first". It is a screening line, not a grade, and it was never '
              'designed to tell an individual man anything about himself.'),
        ],
      ),
      PvReadSection(
        heading: _en('The two things it does not do'),
        paragraphs: [
          _en('It does not prove fertility. There is no test that does — the '
              'only proof is a pregnancy. A semen analysis measures what can '
              'be measured in a laboratory, and fertilisation involves rather '
              'more than that.'),
          _en('And it does not close the question if you have been trying a '
              'while. Sperm DNA fragmentation, hormonal issues and structural '
              'problems can sit behind a normal-looking count, and none of '
              'them appear on a routine analysis. If a year has gone by, the '
              'conversation moves to the couple rather than to either of you '
              'alone.'),
        ],
      ),
      PvReadSection(
        heading: _en('What "a while" actually means'),
        paragraphs: [
          _en('The usual definition is a year of regular unprotected sex, or '
              'six months if she is 35 or over. Those numbers are not '
              'arbitrary: most couples who are going to conceive without help '
              'do so within a year, so a year is the point at which looking '
              'further stops being premature.'),
          _en('If you are inside that window with a normal analysis, the '
              'honest answer is that there is nothing more to do and waiting '
              'is not passivity. If you are past it, a normal result does not '
              'change the timeline — it changes who the next questions are '
              'about.'),
          _en('It is also worth knowing that a normal result on his side and a '
              'normal set of results on hers is a common and frustrating '
              'place to end up. Unexplained infertility is a real category, it '
              'is not a euphemism for "we did not look properly", and there '
              'are treatment paths for it.'),
        ],
      ),
      PvReadSection(
        heading: _en('The conversation a normal result opens'),
        paragraphs: [
          _en('The useful question after a normal analysis is not "what else '
              'can we test on him" — it is "what should we be looking at as a '
              'couple". Timing across her fertile window, her cycles, whether '
              'she is ovulating, whether her tubes are open: those are the '
              'next things, and most of them are quick.'),
          _en('This is also the moment to say out loud that the test happened '
              'and what it showed. A surprising number of couples reach a '
              'clinic where he has had an analysis, it was fine, and nobody '
              'mentioned it — so it gets repeated.'),
          _en('And keep the report. A clinic will want the actual sheet, with '
              'the laboratory name and the date on it, not a number remembered '
              'from a year ago.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to do with a normal result'),
        paragraphs: [
          _en('File it. It is a piece of information a clinic will ask for, '
              'and a report that was on a phone is worth more than one that '
              'was in a drawer.'),
          _en('Keep the habits that are worth keeping anyway — sleep, not '
              'smoking, the heat business — because sperm are produced '
              'continuously and today\'s result describes the last eleven '
              'weeks rather than a permanent state.'),
          _en('And take the pressure off her. A normal male result frequently '
              'gets read, by everybody involved, as confirmation that the '
              'problem must be hers. It is not: about half of couples having '
              'difficulty have a male factor somewhere in the picture, and '
              'plenty have no identified cause at all.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A normal result is not a reason to wait indefinitely'),
      body: _en('If you have been trying for a year — or six months if she is '
          '35 or over — a normal semen analysis is a reason to move the '
          'conversation to both of you, not a reason to keep waiting. And see '
          'somebody regardless of this result if you have pain, swelling or a '
          'lump in a testis, difficulty with erections or ejaculation, or if '
          'you take testosterone or anabolic steroids.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should I repeat it to be sure?'),
        answer: _en('Not usually. Repeating a normal result rarely changes '
            'anything, and the time is better spent on the couple-level '
            'questions.'),
      ),
      PvReadFaq(
        question: _en('So the problem must be with her?'),
        answer: _en('No, and this is the conclusion to be most careful about. '
            'A normal analysis rules out the common male causes and not the '
            'uncommon ones, and a great many couples have no identified cause '
            'on either side.'),
      ),
      PvReadFaq(
        question: _en('Is there a better test I should ask for?'),
        answer: _en('Sperm DNA fragmentation testing exists and is sometimes '
            'used after recurrent loss or failed IVF. It is not a routine '
            'next step after a normal analysis, and it is a conversation with '
            'a specialist rather than something to order online.'),
      ),
    ],
    evidence: _en('WHO laboratory manual, sixth edition, 2021; NICE CG156 '
        '(fertility problems); EAU Guidelines on Sexual and Reproductive '
        'Health; ESHRE guidance on unexplained infertility. Reviewed August '
        '2026.'),
    readNext: ['ttc_read_semen_analysis'],
  ),

  PvRead(
    id: 'ttc_read_result_abnormal',
    hue: 186,
    kicker: _en('His side'),
    title: _en('If the first test is abnormal'),
    teaser: _en('One low number is a reason to repeat, not a conclusion — and '
        'the reason why is the most useful thing on this page.'),
    scaleSetter: _en('Semen parameters vary enormously between samples from '
        'the same man. The same person can land either side of a reference '
        'line a fortnight apart, for reasons as ordinary as a fever six weeks '
        'ago. That is why nothing is decided on one test, and why the next '
        'step is almost always a second one done properly.'),
    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('If a number came back below a line, the feeling is usually some '
              'combination of shame and finality, and neither is warranted by '
              'what you are holding. What you are holding is one measurement '
              'of one sample on one day.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why one test decides nothing'),
        paragraphs: [
          _en('Production takes about eleven weeks, so a sample reflects what '
              'was happening two to three months ago. A fever, an illness, a '
              'stretch of very poor sleep or a course of certain medicines in '
              'that window shows up now and may be gone by the next one.'),
          _en('Collection matters too. A sample produced after a very short or '
              'very long gap, kept too cool or too warm, or with part of it '
              'lost, will not represent you fairly. The standard gap is two to '
              'seven days.'),
          _en('And the variation is not small. Studies measuring the same men '
              'repeatedly find swings large enough to cross reference lines in '
              'both directions, which is precisely why guidance asks for two '
              'samples before anything is concluded.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to do next, in order'),
        paragraphs: [
          _en('Book the repeat. Most clinics suggest leaving a few weeks — '
              'longer if you were ill around the first one — and doing it at '
              'the same laboratory so the two are comparable.'),
          _en('Do the collection to the instructions. Two to seven days since '
              'the last ejaculation, the whole sample collected, kept close to '
              'body temperature, and to the lab quickly. More results are '
              'ruined by collection than by biology.'),
          _en('Then have both read together by an andrologist. Two reports side '
              'by side say considerably more than either alone, and that '
              'reading is the appointment worth paying for.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is worth changing meanwhile, and what is not'),
        paragraphs: [
          _en('Worth doing: stopping smoking and smokeless tobacco, cutting '
              'heavy drinking, treating a fever properly, keeping laptops off '
              'your lap and long hot baths shorter. These have evidence behind '
              'them and the timescale is the same eleven weeks.'),
          _en('Not worth doing: buying a fertility supplement stack on the '
              'strength of one report. The evidence for antioxidant '
              'supplements in male subfertility is weak, and this section says '
              'so in its own piece rather than selling you something.'),
          _en('And do not stop a prescribed medicine because you have read '
              'that it might affect sperm. Some do; the answer is a '
              'conversation with whoever prescribed it, never a unilateral '
              'stop.'),
        ],
      ),
      PvReadSection(
        heading: _en('What a repeat is really for'),
        paragraphs: [
          _en('It is easy to read a repeat as the app or the doctor stalling. '
              'It is the opposite. A single sample gives you a number with no '
              'idea how much of it is you and how much is the fortnight you '
              'happened to have. Two samples give you a range, and a range is '
              'the thing an andrologist can actually reason about.'),
          _en('That is why guidance in most countries asks for two before '
              'anything is concluded, and why a clinic that changes a plan on '
              'the strength of one report is moving faster than the evidence '
              'allows.'),
          _en('It is also why the second sample is worth doing properly rather '
              'than quickly. Same laboratory, the standard two-to-seven-day '
              'gap, the whole sample collected, kept near body temperature and '
              'delivered promptly. A badly collected repeat has cost you the '
              'comparison you were trying to make.'),
          _en('And if you were unwell in the weeks before the first one — a '
              'fever in particular — say so when you book. It may be worth '
              'leaving longer than usual, because what you are trying to '
              'measure is you rather than the flu you had in March.'),
        ],
      ),
      PvReadSection(
        heading: _en('If the repeat is also low'),
        paragraphs: [
          _en('Then you have a pattern rather than a reading, and that is '
              'genuinely useful. It moves the conversation to why — an '
              'examination, hormone bloods, sometimes a scan — and to what the '
              'options are, which for most men are considerably wider than '
              'they expect.'),
          _en('A low count is not a closed door. IUI, IVF and ICSI exist '
              'precisely for this, and ICSI works with very small numbers of '
              'sperm. That is a conversation to have when you get there, not '
              'tonight.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Some results skip the repeat'),
      body: _en('See a doctor rather than arranging another sample if the '
          'report found no sperm at all, or if you have pain, swelling or a '
          'lump in a testis, very little or no semen when you ejaculate, '
          'difficulty with erections or ejaculation, or if you take '
          'testosterone or anabolic steroids. Testosterone suppresses sperm '
          'production — do not stop it yourself, take it to whoever prescribed '
          'it.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('How long should I wait before repeating?'),
        answer: _en('Usually a few weeks, and longer if you were ill around '
            'the first sample. Ask the clinic — and use the same laboratory so '
            'the two are comparable.'),
      ),
      PvReadFaq(
        question: _en('Does a low number mean we need IVF?'),
        answer: _en('Not on its own, and not from one test. Plenty of couples '
            'with a low first result conceive naturally, and where treatment '
            'is needed it is not always the most involved kind.'),
      ),
      PvReadFaq(
        question: _en('Should I tell her?'),
        answer: _en('Yes. This is the point at which men most often go quiet, '
            'and the silence is harder on a couple than the number is. She is '
            'already having every test going; you are not protecting her by '
            'carrying this alone.'),
      ),
    ],
    evidence: _en('WHO laboratory manual, sixth edition, 2021, including its '
        'guidance on repeat sampling and within-subject variability; NICE '
        'CG156; EAU Guidelines on Sexual and Reproductive Health; Cochrane '
        'review of antioxidants for male subfertility. Reviewed August 2026.'),
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
    teaser: _en('One test, widely available, inexpensive — and it answers a '
        'question a year of waiting cannot.'),
    scaleSetter: _en('A semen analysis is the cheapest, fastest and least '
        'invasive test in the whole of fertility. It costs a few hundred '
        'rupees, takes a morning, and rules in or out roughly half of the '
        'reasons a couple might be taking longer. The case for doing it early '
        'is not that something is likely to be wrong. It is that finding out '
        'is so easy.'),
    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist · reviewed September 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The usual order is her first. Months of cycle tracking, then '
              'blood tests, then a scan, then a tube test — each slower, '
              'costlier and more uncomfortable than the last. His test, which '
              'could have been done on day one, tends to come after all of '
              'that. The order is a habit, not a reason.'),
        ],
      ),
      PvReadSection(
        heading: _en('What it costs, and what it saves'),
        paragraphs: [
          _en('In most Indian cities the test costs between three hundred and '
              'a thousand rupees at a diagnostic lab, the sample is given in '
              'a private room or at home and delivered within the hour, and '
              'the result is back in a day or two.'),
          _en('What it saves is time. If his side is fine, the couple knows '
              'it and the search narrows to things that can actually be '
              'looked at. If it is not, they have found out in a week what '
              'waiting would have taken a year to hint at — and because '
              'sperm take about three months to respond to any change, every '
              'month before finding out is a month that clock is not '
              'running.'),
        ],
      ),
      PvReadSection(
        heading: _en('When it is worth doing now rather than at a year'),
        bullets: [
          _en('Any time he has a known reason — an undescended testis as a '
              'child, surgery or injury there, mumps after puberty, '
              'chemotherapy, a swelling in the scrotum, or testosterone or '
              'steroid use, past or present.'),
          _en('At six months if her cycles are irregular or she is over '
              'thirty-five, because the year rule assumes nothing else is '
              'going on.'),
          _en('Whenever the two of you would rather know than wait. There is '
              'no minimum.'),
        ],
      ),
      PvReadSection(
        heading: _en('How to raise it without it landing as blame'),
        paragraphs: [
          _en('The reason this test comes last is rarely medical. It is that '
              'suggesting it sounds like an accusation, and most couples '
              'would rather wait another six months than have that '
              'conversation. It helps to say the true thing plainly: half of '
              'these cases involve him, his test is the easy one, and doing '
              'it first is the considerate order rather than the suspicious '
              'one.'),
          _en('If he is the one reading this: the sample is not a verdict on '
              'anything, the result comes back to the two of you and nobody '
              'else, and nobody at the lab is judging. If she is: the ask is '
              '"let us do the easy test first", not "I think it is you". '
              'Said that way, most men agree in a sentence.'),
        ],
      ),
      PvReadSection(
        heading: _en('What a year of waiting actually costs'),
        paragraphs: [
          _en('The standard advice is to try for a year before investigating, '
              'and it is sensible advice for a couple with no reason to think '
              'anything is wrong. It is less sensible once you notice what '
              'the year contains: twelve cycles of hope and disappointment, '
              'an age clock that runs regardless, and — if his side is part '
              'of the answer — twelve months in which the one lever that '
              'takes three months to move was never pulled.'),
          _en('Doing his test early does not shorten the year for anyone '
              'whose result is normal. It only means the year is spent '
              'knowing rather than wondering, and that is worth a few hundred '
              'rupees.'),
        ],
        bullets: [
          _en('Have ready: the lab\'s name, how many days since he last '
              'ejaculated, and any medicine or supplement he takes.'),
          _en('If the sample is produced at home, it goes to the lab within '
              'the hour, kept at body temperature — an inside pocket, not a '
              'car seat.'),
          _en('Ask for the printed report, not a phone summary. The tool in '
              'the next tab reads the printed numbers.'),
        ],
      ),
      PvReadSection(
        heading: _en('What it does not do'),
        paragraphs: [
          _en('It does not say whether you will conceive. A normal result '
              'rules out the commonest male causes and nothing more, and a '
              'low result on one sample is a reason to repeat, not a '
              'diagnosis. What the test involves, and how to read the report '
              'when it comes back, is the whole of the next tab.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does he need a doctor to order it?'),
        answer: _en('In most Indian cities, no — diagnostic labs run it on a '
            'walk-in basis. A referral helps if insurance is involved, and '
            'it is worth having somebody lined up to read the result '
            'properly afterwards either way.'),
      ),
      PvReadFaq(
        question: _en('Is it embarrassing?'),
        answer: _en('Most men expect it to be worse than it is. A private '
            'room at the lab, or a home sample in the lab\'s own container '
            'delivered within the hour. The staff have seen a thousand of '
            'these and will not remember his.'),
      ),
      PvReadFaq(
        question: _en('Should he change anything before the test?'),
        answer: _en('Two to seven days without ejaculation, no fever in the '
            'previous few weeks if it can be helped, and tell the lab about '
            'any medicine he takes. Do not stop anything to get a "better" '
            'result — the point is a true one.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not wait for a test if'),
      body: _en('A new lump, or pain and swelling in one testis, needs a '
          'doctor this week, and it has nothing to do with fertility. So '
          'does very little or no semen, or difficulty with erections or '
          'ejaculation — those change what the test can even tell you, and '
          'they are looked at first.'),
    ),
    evidence: _en('Male factor involvement in roughly half of couples with '
        'difficulty conceiving, and semen analysis as the recommended '
        'first-line male investigation, per NICE CG156 and ASRM and EAU '
        'guidance. Indian lab pricing from the test library. Reviewed '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Read your semen report'),
        value: _en('When the result is back — every number explained, no '
            'verdict, and somebody to take it to.'),
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
    scaleSetter: _en('Sperm are made continuously and take about eleven weeks '
        'from start to finish, so the sample in any test reflects what his '
        'body was doing three months ago. That is the deal this plan is '
        'built on: anything changed today shows up around week twelve, and '
        'nothing shows up before it. The plan is short because the list of '
        'things with real evidence is short.'),
    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist · reviewed September 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('This is not a programme with a product at the end of it. It '
              'is three levers — tobacco in every form, heat, and the rest '
              'of ordinary health — spread across twelve weeks in the order '
              'that tends to survive contact with real life. Pick the two '
              'that apply most to him rather than all of them; two kept is '
              'worth more than five abandoned in week three.'),
        ],
      ),
      PvReadSection(
        heading: _en('Day one — book the repeat test'),
        paragraphs: [
          _en('Before changing anything, book the semen analysis for twelve '
              'weeks from today. Booked at the start, it happens. Left until '
              '"when things have settled", it does not — and a test done at '
              'week six measures the old batch, which is the commonest '
              'reason couples conclude that none of this works.'),
        ],
        bullets: [
          _en('Same lab as the first test, so the two are comparable.'),
          _en('Today\'s date noted in the reports folder, next to the first '
              'result.'),
        ],
      ),
      PvReadSection(
        heading: _en('Week one — the structural changes'),
        paragraphs: [
          _en('The changes that are made once and then need no willpower.'),
        ],
        bullets: [
          _en('Tobacco out of the house. Cigarettes, bidi, gutka, khaini and '
              'paan masala all count, and the smokeless kinds are the ones '
              'nobody asks about.'),
          _en('The laptop onto a table. Hours on the lap is sustained heat '
              'exactly where it matters.'),
          _en('Hot baths shortened; saunas and steam rooms paused for the '
              'twelve weeks.'),
          _en('Looser underwear. A small effect, and it costs nothing.'),
        ],
      ),
      PvReadSection(
        heading: _en('Weeks two to six — the ones that need support'),
        paragraphs: [
          _en('These are habits rather than settings, so they need somebody '
              'alongside — which is the point of doing this as a couple '
              'rather than as his private project.'),
        ],
        bullets: [
          _en('Alcohol down. Heavy and regular is the clear problem; the '
              'occasional drink is not, and pretending otherwise makes the '
              'plan fail sooner.'),
          _en('Movement up. A walk most days is enough. Extreme endurance '
              'training is not the aim and can work against it.'),
          _en('Anything at work — heat, solvents, pesticides, long hours in '
              'a hot cab — raised with somebody, or reduced where it can be.'),
          _en('Every medicine, supplement or "gym" product he takes written '
              'down for the appointment. Nothing stopped on his own.'),
        ],
      ),
      PvReadSection(
        heading: _en('Weeks seven to eleven — hold, and do not test'),
        paragraphs: [
          _en('The quiet stretch, and the one where most plans end. There is '
              'no feedback yet, because the sperm being made now will not be '
              'in a sample until week twelve. Two things help: the test is '
              'already booked, and the two changes were chosen because they '
              'could be kept.'),
          _en('If something slips, it slips. Restarting a week later costs a '
              'week. Deciding the plan has failed costs the whole three '
              'months.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Six weeks is long enough to see a difference.'),
          fact: _en('A sample at six weeks is measuring sperm that started '
              'forming before anything changed. Nothing reliable shows until '
              'about week twelve.'),
        ),
      ),
      PvReadSection(
        heading: _en('What to keep during the twelve weeks'),
        paragraphs: [
          _en('Two things, and both are for the appointment rather than for '
              'the app. A short log — sleep, alcohol, tobacco, anything hot, '
              'movement — so that "I cut down" has numbers behind it when the '
              'second report is read; the partner-health tracker keeps it on '
              'his own account, privately. And the first report, in the '
              'reports folder beside the date the plan started, so the '
              'andrologist at week twelve sees the before and the after on '
              'one page.'),
        ],
        bullets: [
          _en('A fever or a bad illness during the twelve weeks, with the '
              'date. It can lower a sample for a whole cycle and is worth '
              'mentioning before the second result is read.'),
          _en('Any new medicine or supplement started, with the date, for '
              'the same reason.'),
        ],
      ),
      PvReadSection(
        heading: _en('Week twelve — the repeat, read together'),
        paragraphs: [
          _en('Same lab, the standard two-to-seven-day window before the '
              'sample, and then both reports taken to an andrologist '
              'together. Two samples read side by side say far more than '
              'either alone — and if the first was low and the second is '
              'not, that is the pattern that tells you the changes were '
              'real.'),
          _en('If the second is also below a line, it is still not a '
              'verdict. It is the point where a specialist looks for a '
              'cause, which is a different and more useful question than a '
              'third repeat.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('What if he cannot give up tobacco completely?'),
        answer: _en('Less is genuinely better than the same, and the '
            'smokeless kinds count as much as smoking. But this is the lever '
            'with the most evidence behind it, so it is worth real effort '
            'and real help — a doctor can prescribe support for stopping.'),
      ),
      PvReadFaq(
        question: _en('Should he take a supplement during the twelve weeks?'),
        answer: _en('Read the piece on zinc and CoQ10 first. The evidence is '
            'weak, neither replaces anything above, and nothing here should '
            'be bought instead of stopping tobacco.'),
      ),
      PvReadFaq(
        question: _en('His first result was normal. Is this still worth '
            'doing?'),
        answer: _en('Yes, more gently. A normal result rules out the '
            'commonest causes and says nothing about DNA damage, which '
            'tobacco and heavy drinking raise and which matters for '
            'miscarriage. Week one is worth doing regardless.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Some of this is not a lifestyle question'),
      body: _en('If he has a lump, pain or swelling in a testis, very little '
          'or no semen, difficulty with erections or ejaculation, or takes '
          'testosterone or anabolic steroids in any form, see a doctor now '
          'rather than starting a twelve-week plan. And never stop a '
          'prescribed medicine on the strength of a plan — take the list to '
          'the person who prescribed it.'),
    ),
    evidence: _en('Spermatogenesis of approximately 74 days plus epididymal '
        'transit; measurable improvement in volume, concentration and total '
        'count within about three months of stopping smoking; scrotal heat '
        'and DNA fragmentation effects, from peer-reviewed reviews of '
        'lifestyle factors in male fertility and EAU guidance. Reviewed '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('What he can track'),
        value: _en('Sleep, alcohol, tobacco, heat and movement — his own '
            'log, on his own account.'),
        surfaceId: 'ttc_partner_health',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep his reports with yours'),
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
    teaser: _en('The two supplements with any evidence at all — what the '
        'evidence actually shows, what they cost, and what they cannot '
        'replace.'),
    scaleSetter: _en('There is a large industry selling men things for this '
        'and a very short list with any evidence behind it. Zinc and '
        'coenzyme Q10 are the two on that list. Neither is a treatment, '
        'both are worth far less than stopping tobacco, and the honest '
        'summary of the research is "possibly a little, on some numbers, in '
        'some men". That is not nothing. It is also not what the packaging '
        'says.'),
    author: _en('Dr. Vikram Nair'),
    authorRole: _en('Andrologist · reviewed September 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The theory is reasonable. Sperm are unusually exposed to '
              'oxidative damage, both of these are antioxidants, and zinc in '
              'particular is concentrated in semen and involved in making '
              'sperm. The problem is not the theory but the trials, which '
              'are small, short, mixed in what they measure, and mostly not '
              'measuring the thing that matters — whether a baby is born.'),
        ],
      ),
      PvReadSection(
        heading: _en('What the research actually shows'),
        paragraphs: [
          _en('The largest independent review, by Cochrane, has looked at '
              'antioxidant supplements for male subfertility several times. '
              'Its conclusion is that they may increase the chance of a live '
              'birth, but that the evidence is low-certainty — small trials, '
              'at risk of bias, with wide margins. On semen numbers, some '
              'trials show modest improvements in motility or concentration '
              'and others show none.'),
          _en('The one large, well-run trial — the MOXI trial in the United '
              'States, published in 2020 — gave men a combined antioxidant '
              'formula for three to six months against a placebo, and found '
              'no difference in sperm numbers, DNA fragmentation or live '
              'births. It is the single best piece of evidence there is, and '
              'it is negative.'),
          _en('Put together: possibly a small benefit on some parameters, no '
              'reliable benefit on live birth, and nothing that comes close '
              'to the effect of stopping tobacco or having a varicocele '
              'looked at.'),
        ],
      ),
      PvReadSection(
        heading: _en('Zinc'),
        bullets: [
          _en('What it is: a mineral, concentrated in the prostate and '
              'semen, needed to make sperm.'),
          _en('When it plausibly helps: in men who are actually short of it '
              '— a poor diet, heavy drinking, some gut conditions. In men '
              'with normal levels the evidence is thin.'),
          _en('The dose in trials: usually around 25 to 66 mg a day of '
              'elemental zinc, for three months. More is not better — high '
              'doses over time interfere with copper and cause nausea.'),
          _en('Cost in India: roughly ₹100 to ₹300 a month for a plain zinc '
              'tablet. The "male fertility" branded versions cost several '
              'times that for the same mineral.'),
        ],
      ),
      PvReadSection(
        heading: _en('Coenzyme Q10'),
        bullets: [
          _en('What it is: a compound the body makes for producing energy in '
              'cells, including the sperm tail.'),
          _en('When it plausibly helps: on motility, in men whose motility '
              'is the low number. Several small trials show a modest '
              'improvement; none shows a difference in pregnancy.'),
          _en('The dose in trials: 200 to 300 mg a day, for at least three '
              'months, because that is one production cycle.'),
          _en('Cost in India: roughly ₹400 to ₹1,200 a month depending on '
              'brand. It is the more expensive of the two and the one with '
              'the weaker case for taking it without a reason.'),
        ],
      ),
      PvReadSection(
        heading: _en('The Indian shelf, specifically'),
        paragraphs: [
          _en('Most pharmacies here stock zinc as zinc sulphate or zinc '
              'gluconate tablets, and the elemental zinc is printed in small '
              'type — a 220 mg zinc sulphate tablet is about 50 mg of '
              'elemental zinc, which is already at the top of the trial '
              'range, so one a day is plenty. CoQ10 is sold as 100 mg or '
              '300 mg capsules, mostly imported and priced accordingly. The '
              'combined "male fertility" sachets and capsules are the same '
              'two ingredients plus vitamins, sold at three to five times the '
              'price, and their labels often do not state the elemental zinc '
              'at all — which is the one number that matters for safety.'),
        ],
      ),
      PvReadSection(
        heading: _en('What neither of them does'),
        paragraphs: [
          _en('Neither fixes a varicocele, an obstruction, a hormone problem '
              'or the effect of testosterone. Neither reverses the DNA '
              'damage from tobacco while the tobacco continues. And neither '
              'is a reason to skip the repeat test or the specialist: a man '
              'taking a supplement instead of finding out why a number was '
              'low has bought three months of not knowing.'),
        ],
        mythFact: PvMythFact(
          myth: _en('A "male fertility" supplement is a treatment for a low '
              'count.'),
          fact: _en('Zinc and CoQ10 are the two ingredients with any '
              'evidence, the evidence is weak, and the branded '
              'multi-ingredient stacks add nothing proven at several times '
              'the price.'),
        ),
      ),
      PvReadSection(
        heading: _en('If you decide to take one'),
        bullets: [
          _en('Plain zinc or plain CoQ10, from a pharmacy, at the trial '
              'doses above.'),
          _en('For three months — one production cycle — and then the '
              'repeat test, rather than indefinitely.'),
          _en('Tell the doctor at the appointment. It matters for reading '
              'the second result.'),
          _en('Alongside the levers with real evidence, never instead of '
              'them.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Should he take both?'),
        answer: _en('There is no good evidence that two is better than one, '
            'and the MOXI trial, which combined several, found no benefit. '
            'If motility is his low number, CoQ10 has the more specific '
            'case; if his diet is poor or he drinks heavily, zinc.'),
      ),
      PvReadFaq(
        question: _en('What about the branded fertility stacks?'),
        answer: _en('Mostly the same two ingredients plus vitamins C and E, '
            'selenium, L-carnitine and folate, at a much higher price. None '
            'of the extras has better evidence than the two named here, and '
            'some stacks exceed a safe zinc dose.'),
      ),
      PvReadFaq(
        question: _en('Are there side effects?'),
        answer: _en('Zinc at high doses causes nausea and, over months, '
            'copper deficiency. CoQ10 is generally well tolerated; it can '
            'interact with blood thinners, so anyone on warfarin should ask '
            'first.'),
      ),
      PvReadFaq(
        question: _en('Do they help if his result was normal?'),
        answer: _en('No trial has shown that. A normal result is not '
            'improved by a supplement, and the money is better spent on a '
            'repeat test if there is any doubt.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A supplement is not the next step if'),
      body: _en('If the report found no sperm, if any number was low on two '
          'samples, or if he has a lump, pain or swelling in a testis, the '
          'next step is an andrologist, not a pharmacy. And never stop a '
          'prescribed medicine to make room for a supplement — ask the '
          'person who prescribed it.'),
    ),
    evidence: _en('Cochrane review of antioxidants for male subfertility (de '
        'Ligny and colleagues, 2022 update): low-certainty evidence of a '
        'possible increase in live birth. Steiner and colleagues, Fertility '
        'and Sterility 2020 (the MOXI trial): no effect of a combined '
        'antioxidant formula on semen parameters, DNA fragmentation or live '
        'birth. Trial doses and Indian retail pricing are approximate. '
        'Reviewed September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.product,
        title: _en('Zinc and CoQ10, on the shelf'),
        value: _en('Plain versions, at the trial doses, honestly labelled.'),
        surfaceId: 'ttc_supplements',
      ),
    ],
    readNext: ['ttc_read_heat_habits', 'ttc_read_three_months'],
  ),
];
