// =============================================================================
//  PCOS — the reads for this door
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

final List<PvRead> kTtcReadsPcos = [
  // ===========================================================================
  //  PCOS — "Understand my PCOS", step one
  // ===========================================================================
  //  The first read written for this reader, and deliberately the hardest one:
  //  PCOS is the highest-demand bracket in the stage and the app had NOTHING
  //  for it — the word appears in eight files in passing and there is no
  //  explainer anywhere.
  //
  //  ⚠️ THE EXISTING `pcos` ENTRY IN `conditions_data.dart` IS NOT THIS.
  //  That one is "PCOS and pregnancy" — written for a woman who has already
  //  conceived, about what her obstetrician will watch more closely. Its
  //  `babyImpact` field is the giveaway. Reusing it here would answer a
  //  question she has not asked yet and skip the one she has.
  PvRead(
    id: 'ttc_read_pcos_cycle',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('What PCOS is doing to your cycle'),
    teaser: _en('Not a diagnosis, and not a verdict. What the pattern '
        'actually is, why it makes a cycle hard to read, and what genuinely '
        'shifts it.'),

    // ⚠️ SCALE BEFORE DEFINITION. She has been handed a word by a sonographer
    // or found it herself at 1am, and the question underneath is not "what is
    // PCOS" — it is "have I just been told I cannot have children".
    scaleSetter: _en('PCOS is the single commonest reason ovulation turns '
        'irregular, and irregular ovulation is one of the most treatable '
        'things in fertility medicine. It makes a cycle harder to read. It '
        'does not close a door.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_pcos_explained',

    sections: [
      // ---- 1. the name -----------------------------------------------------
      PvReadSection(
        paragraphs: [
          _en('Almost everything confusing about PCOS starts with its name. '
              '"Polycystic ovary syndrome" describes something a sonographer '
              'sees on a screen, and what she sees is not what the name says '
              'it is.'),
          _en('The "cysts" are not cysts. They are ordinary follicles — the '
              'small fluid-filled sacs every ovary makes each month, each '
              'holding an egg. In a typical cycle a handful start growing, one '
              'pulls ahead, and that one releases. In PCOS a larger number '
              'start and none of them pulls ahead, so they sit there, visible, '
              'in a ring around the edge of the ovary. A scan counts twenty of '
              'them and the report says "polycystic".'),
          _en('That is a picture of stalled ovulation, not of disease in the '
              'ovary. Which matters enormously, because a stall is something '
              'that can be nudged.'),
        ],
        mythFact: PvMythFact(
          myth: _en('A scan showing polycystic ovaries means you have PCOS.'),
          fact: _en('It does not. Up to a quarter of women with completely '
              'regular cycles have that appearance on a scan and nothing '
              'else. PCOS needs two of three things — irregular cycles, '
              'raised androgens, and the scan picture — which is why a scan '
              'alone is not a diagnosis.'),
        ),
      ),

      // ---- 2. how common ---------------------------------------------------
      PvReadSection(
        heading: _en('How common this actually is'),
        paragraphs: [
          _en('Common enough that the number depends on where you draw the '
              'line. In a national Indian study of nearly ten thousand women '
              'aged eighteen to forty, about one in five met the broader '
              'Rotterdam definition and about one in fourteen met the '
              'stricter NIH one. A pooled analysis across Indian studies lands '
              'around one in nine.'),
          _en('Read that spread the right way round. It is not uncertainty '
              'about whether this is real — it is three committees disagreeing '
              'about where a normal cycle stops and a syndrome starts. The '
              'women in the middle of that disagreement are, by definition, '
              'the mildest cases.'),
          _en('Practically: in a room of twenty Indian women of reproductive '
              'age, several have this. Most of them will have children. Some '
              'of them already do.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('The number worth holding on to'),
          body: _en('PCOS accounts for roughly eight in ten cases where '
              'ovulation is the problem — and ovulation problems are the '
              'category fertility medicine is best at treating. Being in the '
              'commonest, most-studied group is a good place to be standing.'),
        ),
      ),

      // ---- 3. symptoms -----------------------------------------------------
      //  ⚠️ ADDED AFTER REVIEW. The Excel's Content cell for this bracket names
      //  four topics — "PCOS & fertility, symptoms, insulin & diet, cycle
      //  regulation" — and the first draft of this piece covered three. Symptoms
      //  were scattered into bullets in the cycle section and into the
      //  when-to-see-someone box, which is not the same as answering "is what I
      //  have this?".
      PvReadSection(
        heading: _en('What it actually looks like'),
        paragraphs: [
          _en('PCOS is diagnosed on two of three findings, not on how you feel '
              '— but how you feel is usually what brings someone in. These are '
              'the signs that cluster together.'),
        ],
        bullets: [
          _en('Cycles longer than 35 days, or fewer than eight or nine periods '
              'in a year. The commonest first sign, and the one that matters '
              'most for conceiving.'),
          _en('Acne that arrives or persists well past the teenage years, '
              'often along the jaw and chin rather than the forehead.'),
          _en('Coarser hair on the face, chest or stomach, or thinning at the '
              'crown — both driven by the same raised androgens.'),
          _en('Darker, velvety patches of skin at the neck, underarms or '
              'groin. This one is a marker of insulin resistance specifically, '
              'and is worth mentioning even if nothing else on this list fits.'),
          _en('Weight that is difficult to shift, particularly around the '
              'middle — though a normal weight does not rule any of this out.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Having some of these is not having PCOS'),
          body: _en('Every sign on this list has other causes — thyroid '
              'disease and raised prolactin both produce irregular cycles, and '
              'both are ruled out with a blood test before anyone says the '
              'word PCOS. This list is what to describe at an appointment, not '
              'a scorecard to total up at home.'),
        ),
      ),

      // ---- 4. insulin ------------------------------------------------------
      PvReadSection(
        heading: _en('Insulin, and why your doctor keeps mentioning it'),
        paragraphs: [
          _en('For a lot of women with PCOS the engine underneath is insulin. '
              'Insulin is the hormone that moves sugar out of the blood and '
              'into cells. When cells respond to it sluggishly, the body '
              'compensates by making more of it, and blood insulin runs high.'),
          _en('High insulin does two things to an ovary. It nudges it to make '
              'more testosterone, and it lowers a carrier protein in the blood '
              'that normally keeps testosterone bound and quiet. So more is '
              'made and more of it is free — which is where the acne, the hair '
              'changes and the stalled follicles come from.'),
          _en('This is also the honest reason "just lose weight" is such '
              'unhelpful advice, and why it is not the whole story. Insulin '
              'resistance is commoner at a higher weight but it is not caused '
              'by it, and plenty of slim women have textbook PCOS. The target '
              'is the insulin curve, not the number on the scale.'),
        ],
        tip: PvReadTip(
          title: _en('Why the order you eat things in matters'),
          body: _en('The same plate produces a smaller blood-sugar rise when '
              'the protein and vegetables go in before the rice or the roti. '
              'It is one of the few pieces of advice here that costs nothing, '
              'changes no recipe, and has actual trial evidence behind it. '
              'Start there before you start removing food groups.'),
        ),
      ),

      // ---- 5. the cycle ----------------------------------------------------
      PvReadSection(
        heading: _en('Why your cycle became hard to read'),
        paragraphs: [
          _en('An ordinary cycle has a clean structure. Follicles grow, one '
              'wins, it releases, and the empty follicle then produces '
              'progesterone for about a fortnight. If no pregnancy arrives, '
              'progesterone falls and the lining comes away. The period is '
              'the full stop at the end of that sentence.'),
          _en('When nothing releases, none of the second half happens. There '
              'is no progesterone, so there is no fall, so there is no full '
              'stop — and the cycle simply runs on. Thirty-eight days. '
              'Fifty-two. Sometimes months.'),
          _en('And when bleeding does eventually come it may not be a period '
              'in the strict sense at all, but a lining that has grown too '
              'thick to hold itself up. That is why it can be heavier, and '
              'why it arrives with no warning you can learn to recognise.'),
        ],
        bullets: [
          _en('Cycles longer than 35 days, or fewer than eight or nine periods '
              'in a year, is the pattern worth mentioning to a doctor.'),
          _en('An ovulation strip can read positive several times in a long '
              'cycle without ovulation following — the hormone it detects can '
              'sit high in PCOS rather than spiking once.'),
          _en('A basal thermometer confirms ovulation happened, after the '
              'fact. In a long irregular cycle that is often more useful than '
              'strips, because it answers a different question.'),
        ],
        videoSlot: 'ttc_vid_pcos_plate',
      ),

      // ---- 6. what actually works -----------------------------------------
      PvReadSection(
        heading: _en('What actually shifts it'),
        paragraphs: [
          _en('Two things carry most of the weight, and neither is exotic.'),
          _en('The first is the insulin curve — steadier blood sugar across '
              'the day, through what is on the plate and through movement. '
              'Muscle takes up glucose without needing much insulin at all, '
              'which is why a walk after dinner is doing something specific '
              'rather than something virtuous. Where weight is raised, a '
              'modest loss of around five per cent restores ovulation in a '
              'meaningful share of women. That is a few kilograms, not a '
              'transformation.'),
          _en('The second is medication, if and when you are trying. Since '
              '2023 the international guideline — written jointly by ESHRE, '
              'ASRM and Monash, which is as close to a settled global position '
              'as fertility medicine gets — names letrozole as the preferred '
              'first-line treatment for ovulation induction in PCOS, ahead of '
              'clomiphene. It is a tablet, taken for five days early in the '
              'cycle, and it is inexpensive.'),
          _en('If letrozole does not work, the path continues rather than '
              'ending: clomiphene with metformin, then injectable '
              'gonadotrophins or ovarian drilling, and IVF as a third line '
              'rather than a first resort. Very few people need to walk the '
              'whole path.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('One thing to know before you read a success rate '
              'anywhere'),
          body: _en('Ovulation-induction trials report live births across '
              'several cycles, not one — in the largest, roughly a quarter of '
              'women had a live birth over five letrozole cycles. Say that the '
              'right way round: most individual cycles do not work, and that '
              'is the normal shape of this treatment rather than a sign it is '
              'failing. A cycle that does not work is not information about '
              'you.'),
        ),
      ),

      // ---- 7. supplements — REFERENCE, FOLDS -------------------------------
      PvReadSection(
        // ⚠️ FOLDS. This is a lookup, not a step in the argument — useful the
        // day she is standing in a chemist, dead weight the day she is trying
        // to understand her own cycle. The spine of the piece still reads with
        // this shut, which is the test `assertShape` applies.
        collapsible: true,
        summary: _en('Inositol, folic acid, and the ones that are inositol '
            'again at four times the price.'),
        heading: _en('The supplements you will be sold'),
        paragraphs: [
          _en('Inositol is the one with the most respectable evidence behind '
              'it — trials suggest it can improve insulin sensitivity and, in '
              'some women, restore ovulation. The guideline stops short of '
              'recommending it outright, on the grounds that the trials are '
              'small and inconsistent. That is a fair summary: promising, not '
              'proven, unlikely to hurt.'),
          _en('Almost everything else marketed for PCOS in India is either '
              'inositol under another name at four times the price, or a '
              'multivitamin with a photograph of an ovary on the box.'),
          _en('Folic acid is the exception, and it is not for PCOS at all — '
              'it is for the neural tube, it needs to already be in your body '
              'before a positive test, and at eighty rupees a month it is the '
              'best-evidenced thing anyone will sell you in this whole '
              'category.'),
        ],
        tip: PvReadTip(
          title: _en('Before you spend on a supplement'),
          body: _en('Ask what test would show whether it is working, and when '
              'you would stop. If there is no answer to either question, the '
              'honest position is that you would be buying a feeling of doing '
              'something — which is a real need, and there are cheaper ways '
              'to meet it.'),
        ),
      ),

      // ---- 8. what it is not — REFERENCE, FOLDS ----------------------------
      PvReadSection(
        // ⚠️ FOLDS. Everything here is reassurance she has already been given
        // by the lede and by "how common this actually is" — it is worth
        // having, and it is worth having as a box she can choose to open
        // rather than three more screens of scroll on the way to the FAQ.
        collapsible: true,
        summary: _en('Not your fault, not permanent, and not a fertility '
            'sentence — the three fears, answered directly.'),
        heading: _en('What PCOS is not'),
        paragraphs: [
          _en('It is not something you brought on. It runs in families, it '
              'shows up in slim women and larger women, in women who eat '
              'carefully and women who do not, and no decision you made caused '
              'it.'),
          _en('It is not permanent in the way a structural problem is '
              'permanent. Nothing is blocked and nothing is missing. It is a '
              'signalling pattern, and signalling patterns move.'),
          _en('And it is not a fertility sentence. It is a reason cycles are '
              'unpredictable, which makes timing harder — and timing is the '
              'part of this that a tablet, a tracker and a doctor can '
              'genuinely help with.'),
        ],
        mythFact: PvMythFact(
          myth: _en('PCOS means you will need IVF.'),
          fact: _en('For most women it means the opposite — PCOS is the '
              'situation ovulation induction was designed for. The 2023 '
              'guideline places IVF third in line, after tablets and after '
              'injectables, and specifically says it should not be offered '
              'first in the absence of another reason.'),
        ),
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('My scan said polycystic ovaries but my periods are '
            'regular. Do I have PCOS?'),
        answer: _en('Probably not. The diagnosis needs two of three features, '
            'and the scan is only one of them. Regular cycles suggest you are '
            'ovulating, which is the thing that actually matters for '
            'conceiving. Many women have that scan appearance and nothing '
            'else, for their whole lives.'),
      ),
      PvReadFaq(
        question: _en('Will I have to be on metformin forever?'),
        answer: _en('Metformin is usually used for a purpose and a period — '
            'insulin resistance, or alongside ovulation induction — rather '
            'than indefinitely. If you were on it before conceiving, do not '
            'stop or continue it on your own once you are pregnant; that is a '
            'decision your doctor makes with the whole picture in front of '
            'them.'),
      ),
      PvReadFaq(
        question: _en('Does PCOS get worse with age?'),
        answer: _en('Often the opposite. Cycles frequently become more '
            'regular through the thirties as the follicle count naturally '
            'falls, and some women who never had a predictable cycle in their '
            'twenties do later. The metabolic side needs continued attention, '
            'but the cycle side often eases.'),
      ),
      PvReadFaq(
        question: _en('Should I stop eating rice and roti?'),
        answer: _en('No, and being told to is usually a sign the advice is '
            'not built for an Indian kitchen. What changes the blood-sugar '
            'curve is what sits beside the carbohydrate and what you eat '
            'first — protein, dal, vegetables, curd — not removing the '
            'carbohydrate. A diet you cannot keep for a year is not a '
            'treatment.'),
      ),
      PvReadFaq(
        question: _en('How long should I try before seeing someone about '
            'this?'),
        answer: _en('If your cycles are irregular, the usual advice to try '
            'for a year first does not apply — it assumes you are ovulating '
            'predictably, and that is the assumption PCOS breaks. Irregular '
            'cycles are themselves a reason to have the conversation, at any '
            'point.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth an appointment, not an emergency'),
      body: _en('Book if your cycles run longer than 35 days or you have had '
          'fewer than eight or nine periods this year; if you have been '
          'trying for six months with cycles you cannot predict; or if you '
          'have new hair growth, acne past your teens, or patches of darker '
          'skin at the neck or underarms. Sooner rather than later if you '
          'are over 35. None of these is urgent today — they are all reasons '
          'to be in front of someone within the next few weeks rather than '
          'the next few years.'),
    ),

    evidence: _en('International Evidence-based Guideline for the Assessment '
        'and Management of Polycystic Ovary Syndrome (2023), developed by '
        'Monash University with ESHRE and ASRM — the source for letrozole as '
        'preferred first-line ovulation induction and for the ordering of '
        'second and third-line treatment. Indian prevalence figures from a '
        'national cross-sectional study of 9,824 women aged 18–40 and a '
        'systematic review and meta-analysis of Indian studies. Reviewed '
        'August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Start reading your own cycle'),
        value: _en('Three or four months of dates turns "I think it is '
            'irregular" into something a doctor can act on.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Tests worth knowing about'),
        value: _en('What a first PCOS appointment usually checks, and what '
            'each result is actually for.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a PCOS specialist'),
        value: _en('A gynaecologist who works with this every day, on video, '
            'at a time you pick.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    // ⚠️ NO `relatedVideoSlots` HERE — `ttc_vid_pcos_plate` is already placed
    // inside a section, where it is relevant. Repeating it in the foot rail
    // would show the same film twice on one page.
    //
    // Both of these are written now, so the chain is real rather than a
    // dangling id resolving to null under a "Read next" heading.
    readNext: ['ttc_read_pcos_treatment', 'ttc_read_pcos_food'],
  ),

  // ===========================================================================
  //  PCOS — cycle regulation, i.e. "what treatment usually looks like"
  // ===========================================================================
  //  The Excel Content cell for this bracket names four topics: "PCOS &
  //  fertility, symptoms, insulin & diet, cycle regulation."
  //  `ttc_read_pcos_cycle` covers all four at overview depth. This piece and
  //  the next take the last two to the depth they are actually asked about —
  //  which is legitimate rather than padding, because the workbook lists them
  //  as separate topics and because "what will they put me on" is a different
  //  question from "what is PCOS".
  //
  //  ⚠️ THE HARDEST LINE IN THIS STAGE TO HOLD IS HERE. Treatment is the
  //  clinician's decision, full stop — see `TimingOwnership` in
  //  `ttc_care_pathway.dart`. What this piece may do is EXPLAIN what she is
  //  likely to be offered and PREPARE her to ask about it. What it may never do
  //  is recommend, rank for her own case, or give her a reason to argue with
  //  the doctor in front of her. Every paragraph below was written against that
  //  distinction.
  PvRead(
    id: 'ttc_read_pcos_treatment',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('What treatment usually looks like'),
    teaser: _en('The order things are normally tried in, what each one is '
        'actually doing, and what to ask before you agree to any of it.'),

    scaleSetter: _en('Treatment for PCOS almost always starts with the least '
        'invasive thing that might work and stops as soon as something does. '
        'Most women never reach the second step. Almost nobody reaches the '
        'last one.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_pcos_treatment',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('There is a settled international order for this, which is worth '
              'knowing before you walk into a clinic — not so you can argue '
              'with anyone, but so nothing that happens is a surprise and you '
              'know which questions are reasonable to ask.'),
          _en('The order below is from the 2023 international guideline, '
              'written jointly by ESHRE, ASRM and Monash University. It is '
              'about as close to a settled global position as fertility '
              'medicine gets.'),
        ],
      ),

      PvReadSection(
        heading: _en('First: nothing you swallow'),
        paragraphs: [
          _en('Before any tablet, the first line is the insulin curve — what '
              'is on the plate, and movement. Where weight is raised, a loss '
              'of around five per cent is the figure the evidence keeps '
              'returning to, and in a meaningful share of women that alone '
              'brings cycles back.'),
          _en('Five per cent is a few kilograms. It is not a transformation, '
              'and the number is deliberately small because the target is '
              'insulin sensitivity rather than a dress size.'),
          _en('This step is genuinely first, and it is also the step most '
              'often delivered badly — "lose weight" said across a desk in '
              'four seconds, with no plan attached. If that is what you get, '
              'the reasonable question back is: how much, by when, and what '
              'would tell us it is working?'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('And if your weight is already normal'),
          body: _en('Plenty of women with textbook PCOS are slim, and this '
              'step still applies to them — the target was never the scale. '
              'Steadier blood sugar through the day and regular movement do '
              'the same work at any weight. If a clinician skips straight past '
              'this because you are not overweight, it is worth asking about '
              'insulin resistance directly.'),
        ),
      ),

      PvReadSection(
        heading: _en('Then: a tablet to bring on ovulation'),
        paragraphs: [
          _en('If cycles are still not producing an egg, the next step is '
              'ovulation induction — a short course of tablets early in the '
              'cycle that pushes the ovary to mature and release one follicle.'),
          _en('Since 2023 the preferred first choice is letrozole. It is '
              'taken for five days, usually from about day two to day six, and '
              'it is inexpensive — a cycle costs less than most people expect. '
              'Clomiphene was the standard for decades and is still used; the '
              'guideline moved letrozole ahead of it because it produced more '
              'live births in head-to-head trials.'),
          _en('Whichever is used, the cycle is normally monitored with a scan '
              'to check how many follicles are developing. That monitoring is '
              'not optional caution — it is how the dose gets adjusted and how '
              'a twin pregnancy is avoided.'),
        ],
        tip: PvReadTip(
          title: _en('What to ask before the first tablet'),
          body: _en('How many cycles will we try this for before changing '
              'course? Will this cycle be monitored with a scan? And what '
              'would count as it working — a period, a confirmed ovulation, or '
              'a pregnancy? Those three answers turn an open-ended treatment '
              'into something with a shape, which is most of what makes it '
              'bearable.'),
        ),
      ),

      PvReadSection(
        heading: _en('Where metformin fits'),
        paragraphs: [
          _en('Metformin is a diabetes medicine, and being handed it for '
              'fertility unsettles almost everyone. It is not a mistake and it '
              'does not mean anyone thinks you are diabetic.'),
          _en('It works on the same thing the diet advice works on — it makes '
              'cells respond better to insulin, which lowers circulating '
              'insulin, which lowers the androgen production driving the '
              'stall. In the current guideline it sits alongside clomiphene as '
              'a second-line combination rather than as a first move on its '
              'own.'),
          _en('It is also the one that most often has side effects worth '
              'planning around — nausea and loose stools in the first weeks, '
              'usually easing, and usually much better on the slow-release '
              'form and taken with food. If it is intolerable, say so early '
              'rather than stopping quietly; the dose and the form can both '
              'change.'),
        ],
        mythFact: PvMythFact(
          myth: _en('If they put me on metformin, I must be pre-diabetic.'),
          fact: _en('Not necessarily. It is prescribed here for insulin '
              'resistance, which is a different finding from diabetes and very '
              'common in PCOS at completely normal blood-sugar readings. Your '
              'HbA1c may well be fine and metformin still be the right '
              'choice.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Almost nobody reaches these steps, and putting them open
        // in the middle of the page means everyone reads about ovarian surgery
        // on the day they were told about a tablet.
        collapsible: true,
        summary: _en('Injections, ovarian drilling and IVF — what they are, '
            'and why they sit third rather than second.'),
        heading: _en('If tablets do not work'),
        paragraphs: [
          _en('The next step is usually injectable gonadotrophins — the '
              'hormones the brain would normally send, given directly, at low '
              'dose and closely monitored. They work well and they carry a '
              'higher risk of stimulating too many follicles at once, which is '
              'exactly why the monitoring tightens.'),
          _en('Laparoscopic ovarian drilling is the other second-line option: '
              'keyhole surgery making a few tiny punctures in the ovary, which '
              'lowers androgen production and can restore ovulation for a '
              'period afterwards. It is offered less often now than it once '
              'was, and it is a reasonable choice for someone who cannot '
              'attend frequent monitoring.'),
          _en('IVF sits third. The guideline is explicit that it should not be '
              'offered first for PCOS-related anovulation in the absence of '
              'another reason — because the earlier steps work often enough '
              'that starting with IVF means most women would have gone through '
              'it unnecessarily.'),
        ],
      ),

      PvReadSection(
        heading: _en('What none of it does'),
        paragraphs: [
          _en('None of these treats PCOS. They treat the stall. Ovulation '
              'induction makes an egg arrive this cycle; it does not change '
              'the underlying pattern, which is why cycles often go back to '
              'being irregular once treatment stops.'),
          _en('That sounds discouraging and is not meant to be. It is the '
              'reason the first step — the insulin curve — stays relevant '
              'through all the others rather than being something you graduate '
              'out of. It is also why nobody should feel they have failed when '
              'a cycle needs help again later.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('How many cycles of tablets before something else?'),
        answer: _en('Commonly around six ovulatory cycles before the approach '
            'is reconsidered, though this varies with age and with what else '
            'is going on. It is a fair question to ask at the start rather '
            'than discovering it at cycle seven.'),
      ),
      PvReadFaq(
        question: _en('Will treatment give me twins?'),
        answer: _en('The chance of a multiple pregnancy is higher than with an '
            'unassisted cycle, which is precisely why cycles are monitored '
            'with a scan and why a cycle is sometimes cancelled. Letrozole '
            'carries a lower multiple rate than clomiphene, which is one of '
            'the reasons it is preferred.'),
      ),
      PvReadFaq(
        question: _en('Can I take letrozole without monitoring? It is cheaper.'),
        answer: _en('This is a conversation for your own doctor and not one to '
            'settle from an article — but the monitoring exists to adjust the '
            'dose and to catch a cycle with too many follicles developing, and '
            'those are the two things that make the treatment safe rather than '
            'merely effective.'),
      ),
      PvReadFaq(
        question: _en('I was put on the pill for my PCOS. Does that help me '
            'conceive?'),
        answer: _en('No, and it is not meant to. The combined pill is used to '
            'regulate bleeding, control acne and protect the uterine lining '
            'when cycles are very long — all real reasons, none of them about '
            'conceiving, and it prevents pregnancy while you take it. If your '
            'goal has changed to trying, that is the thing to tell your '
            'doctor.'),
      ),
      PvReadFaq(
        question: _en('Does treatment have to be at a fertility clinic?'),
        answer: _en('Not for the first steps. A general gynaecologist manages '
            'ovulation induction routinely, and it is usually where this '
            'starts in India. A referral onward tends to come when tablets '
            'have been tried, or when something else in the picture needs a '
            'specialist.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('While you are on treatment'),
      body: _en('Call your clinic — not an emergency department, your clinic — '
          'if you develop marked bloating, quick weight gain over a few days, '
          'severe abdominal pain, or breathlessness during or after a '
          'stimulated cycle. These are the signs of ovarian hyperstimulation, '
          'which is uncommon on tablets and more relevant with injections, and '
          'which is very manageable when it is reported early. Anything about '
          'your own dose, your own scan or your own next step belongs with the '
          'doctor who prescribed it.'),
    ),

    evidence: _en('The treatment order — lifestyle first, letrozole as '
        'preferred first-line pharmacological therapy, clomiphene with '
        'metformin and gonadotrophins or ovarian surgery as second line, IVF '
        'as third — follows the International Evidence-based Guideline for the '
        'Assessment and Management of Polycystic Ovary Syndrome (2023), '
        'developed by Monash University with ESHRE and ASRM. Reviewed August '
        '2026. Nothing here is a recommendation for your own case; that is '
        'your doctor.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Tests worth knowing about'),
        value: _en('What a first PCOS appointment usually checks, and what '
            'each result is for.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep a record for the appointment'),
        value: _en('Three months of dates is the single most useful thing you '
            'can bring with you.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a PCOS specialist'),
        value: _en('Someone who can see your own reports, on video, at a time '
            'you pick.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_pcos_food'],
  ),


  // ===========================================================================
  //  PCOS — insulin & diet
  // ===========================================================================
  //  ⚠️ THE INDIA-FIRST PIECE IN THIS BRACKET, and the reason it cannot be
  //  adapted from a Western source. Almost all PCOS diet advice in circulation
  //  is built around removing carbohydrate, which in an Indian kitchen means
  //  removing the meal. A diet she cannot keep for a year is not a treatment,
  //  and telling a woman to give up rice and roti is how a page gets closed.
  PvRead(
    id: 'ttc_read_pcos_food',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('Food, insulin and PCOS'),
    teaser: _en('What actually changes the blood-sugar curve in an Indian '
        'kitchen — and why nothing has to leave it.'),

    scaleSetter: _en('There is no PCOS diet. The 2023 international guideline '
        'looked for one and concluded that no single eating pattern beats the '
        'others — what works is the one you can keep. That is a more useful '
        'finding than a meal plan, and it is the opposite of what you will be '
        'sold.'),

    author: _en('Meghna Iyer'),
    authorRole: _en('Fertility nutritionist · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_pcos_plate',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('The target is not calories and it is not carbohydrate. It is '
              'the shape of the curve — how steeply blood sugar rises after '
              'you eat, and therefore how much insulin the body has to send to '
              'deal with it.'),
          _en('Flatten that curve and circulating insulin falls. Lower insulin '
              'means less androgen production in the ovary, which is the thing '
              'stalling the follicles. That is the whole mechanism, and every '
              'genuinely useful piece of advice below is a way of flattening '
              'the same curve.'),
        ],
      ),

      PvReadSection(
        heading: _en('The order you eat things in'),
        paragraphs: [
          _en('This is first because it is free, changes no recipe, removes '
              'nothing, and has real trial evidence behind it.'),
          _en('The same plate produces a smaller blood-sugar rise when the '
              'protein and the vegetables go in before the rice or the roti. '
              'Not a different plate. The same one, in a different order.'),
          _en('In practice that means starting with the sabzi and the dal, or '
              'the curd, or the salad, and coming to the carbohydrate a few '
              'minutes later. Nobody at the table has to know you are doing '
              'it.'),
        ],
        tip: PvReadTip(
          title: _en('If you change one thing this week'),
          body: _en('Make it this, and make it breakfast. The Indian breakfast '
              'is where the curve is usually steepest — poha, upma, bread, '
              'idli, all carbohydrate-forward and often eaten fastest. Adding '
              'a boiled egg, a bowl of curd, a handful of peanuts or a besan '
              'chilla beside it changes the whole morning.'),
        ),
      ),

      PvReadSection(
        heading: _en('What the evidence actually supports'),
        paragraphs: [
          _en('Low glycaemic index eating is the pattern with the most direct '
              'support in PCOS specifically. A head-to-head trial against '
              'conventional dietary advice found menstrual regularity improved '
              'significantly more on the low-GI approach — and menstrual '
              'regularity is a direct marker that ovulation has returned, '
              'which makes it a far more meaningful outcome than a weight '
              'reading.'),
          _en('Alongside it: where weight is raised, a loss of around five per '
              'cent restores cycles in a meaningful share of women. Both of '
              'these work through the same door, which is why doing one tends '
              'to help the other.'),
          _en('What the guideline stops short of is naming a winner. No single '
              'named diet — keto, paleo, low-carb, intermittent fasting — has '
              'been shown to beat the others for PCOS. Approaches that reduce '
              'insulin demand outperform standard advice; beyond that, '
              'sustainability is the deciding variable.'),
        ],
        mythFact: PvMythFact(
          myth: _en('You have to give up rice and roti.'),
          fact: _en('You do not, and being told to is usually a sign the '
              'advice was not built for an Indian kitchen. What changes the '
              'curve is what sits beside the carbohydrate, what you eat first, '
              'and how much of it — not its removal. A diet that ends the way '
              'your family eats will not last a year, and a year is the '
              'timescale that matters.'),
        ),
      ),

      PvReadSection(
        heading: _en('What actually moves the curve, in an Indian kitchen'),
        bullets: [
          _en('Protein at every meal, and especially at breakfast — dal, '
              'curd, paneer, egg, sprouts, chana. This is the single '
              'commonest gap.'),
          _en('Whole grains where they are already normal — hand-pounded or '
              'brown rice, bajra, jowar, ragi — rather than a wholesale swap '
              'to unfamiliar food.'),
          _en('Cooling and reheating rice raises its resistant starch, which '
              'lowers the rise. Yesterday’s rice is genuinely better for '
              'you than today’s.'),
          _en('Fat and acid alongside carbohydrate slow it down — ghee on the '
              'roti, a squeeze of lime, curd with the meal.'),
          _en('Movement after eating, even ten minutes. Muscle takes up '
              'glucose with very little insulin, which is why a walk after '
              'dinner is doing something specific rather than something '
              'virtuous.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. A chemist-aisle lookup, not part of the argument.
        collapsible: true,
        summary: _en('Inositol, vitamin D, berberine and the rest — what has '
            'evidence and what is priced like it does.'),
        heading: _en('The supplements'),
        paragraphs: [
          _en('Inositol is the one with the most respectable evidence. Trials '
              'suggest it improves insulin sensitivity and, in some women, '
              'restores ovulation. The 2023 guideline stops short of '
              'recommending it outright on the grounds that the trials are '
              'small and inconsistent — which is a fair summary: promising, '
              'not proven, unlikely to hurt.'),
          _en('Vitamin D is worth testing rather than assuming, and worth '
              'correcting if it is low, which in India it very often is. That '
              'is general health rather than PCOS treatment, and it is still '
              'worth doing.'),
          _en('Almost everything else marketed for PCOS here is inositol under '
              'another name at several times the price, or a multivitamin with '
              'an ovary on the box. Berberine appears in a lot of these; the '
              'evidence is thin and it interacts with other medicines, so it '
              'is not one to start on your own.'),
        ],
      ),

      PvReadSection(
        heading: _en('What this is not asking of you'),
        paragraphs: [
          _en('Not a separate meal cooked for you. Not weighing food. Not '
              'explaining yourself at a family table. Almost everything above '
              'is an adjustment to a meal that is already being made.'),
          _en('And not perfection across every meal. The curve is a daily and '
              'weekly average, not a test you pass or fail at each sitting — '
              'a mithai at a wedding does not undo a month.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('If eating has started to feel like a job'),
          body: _en('That is worth saying out loud to someone. Restrictive '
              'eating and disordered eating are both commoner in PCOS than '
              'average, partly because of how often women with it are told to '
              'lose weight. A plan that is making you anxious about food is '
              'not working, whatever it is doing to the numbers.'),
        ),
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Is keto good for PCOS?'),
        answer: _en('It lowers insulin, and short trials show metabolic '
            'improvement. What it does not have is evidence of being better '
            'than other approaches over the timescales that matter, and it is '
            'the hardest of them to keep in an Indian household. If you can '
            'sustain it and enjoy it, it is a legitimate choice; it is not a '
            'requirement and it is not a cure.'),
      ),
      PvReadFaq(
        question: _en('Should I do intermittent fasting?'),
        answer: _en('The evidence in PCOS specifically is limited and mixed. '
            'For some women a shorter eating window helps; for others skipping '
            'breakfast makes the rest of the day worse. It is worth trying '
            'only if it feels easy — and it is worth avoiding if you have any '
            'history of disordered eating.'),
      ),
      PvReadFaq(
        question: _en('How long before I see a change?'),
        answer: _en('Insulin sensitivity begins shifting within weeks, but '
            'cycles are the slow signal — three to six months is a realistic '
            'window before you can tell whether the pattern has changed. This '
            'is the main reason people give up too early.'),
      ),
      PvReadFaq(
        question: _en('I am not overweight. Does any of this apply to me?'),
        answer: _en('Yes. Insulin resistance occurs at every body size, and '
            'lean PCOS is common. Nothing above is about weight loss — the '
            'order you eat in, the protein, the walk after dinner all do the '
            'same work whatever the scale says.'),
      ),
      PvReadFaq(
        question: _en('Do I need to see a dietitian?'),
        answer: _en('Not to start — everything above can be done from your own '
            'kitchen. It becomes worth it if you have tried for a few months '
            'without change, if you have another condition to eat around, or '
            'if you would simply rather have a plan built for how your family '
            'actually eats.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth an appointment'),
      body: _en('Book if you have darker velvety patches at the neck or '
          'underarms, marked thirst or unexplained weight change, or a family '
          'history of type 2 diabetes — all reasons to have blood sugar and '
          'insulin looked at properly rather than managed by diet alone. And '
          'speak to someone sooner if food has become a source of anxiety '
          'rather than a lever you are using. Nothing on this page replaces '
          'the plan your own clinician gives you.'),
    ),

    evidence: _en('Low glycaemic index eating and menstrual regularity from a '
        'systematic review and meta-analysis of low-GI diets in PCOS, and from '
        'a randomised isocaloric low-GI trial in women with PCOS (both indexed '
        'on PubMed Central). The five per cent weight-loss figure and the '
        'finding that no single dietary pattern is superior are from the '
        'International Evidence-based Guideline for the Assessment and '
        'Management of Polycystic Ovary Syndrome (2023). Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Supplements, recorded honestly'),
        value: _en('What you are taking and when you started — the thing a '
            'doctor always asks and nobody remembers.'),
        surfaceId: 'ttc_supplements',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Eating, day to day'),
        value: _en('The nutrition planner, built around what an Indian '
            'kitchen already cooks.'),
        surfaceId: 'ttc_nutrition',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a fertility nutritionist'),
        value: _en('A plan built for how your family actually eats, rather '
            'than a printout.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_pcos_treatment'],
  ),


  // ===========================================================================
  //  PCOS — the rebuild set
  // ---------------------------------------------------------------------------
  //  ⚠️ THESE EIGHT WERE WRITTEN FOR THE PCOS FOCUS PAGE, and two rules shaped
  //  every one of them.
  //
  //  **Nothing here diagnoses.** PCOS is diagnosed on the Rotterdam criteria by
  //  a clinician who can examine, scan and test. Every piece therefore describes
  //  what is generally true and routes the specific question to a doctor.
  //
  //  **Nothing here sets a weight target, a number, or a plan.** Not a BMI, not
  //  a percentage of body weight, not "a few kilos". The brief is explicit and
  //  the reason is that weight talk is the fastest way to lose a reader who is
  //  already being told, by everyone, that her body is the problem.
  // ===========================================================================

  PvRead(
    id: 'ttc_read_pcos_irregular',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('Irregular periods, explained'),
    teaser: _en('What "irregular" actually means, why it happens, and why it '
        'is a symptom rather than a diagnosis.'),
    scaleSetter: _en('An irregular cycle is one of the most common reasons '
        'anyone books a gynaecology appointment, and it has a long list of '
        'causes. PCOS is one of them. So are thyroid problems, stress, a '
        'recent birth, coming off contraception, and simply being in the first '
        'or last few years of having periods at all.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('A cycle is counted from the first day of one period to the day '
              'before the next. Anywhere from 21 to 35 days is considered '
              'ordinary, and a cycle that is consistently 33 days is not '
              'irregular — it is simply long.'),
          _en('What makes a cycle irregular is that it does not repeat. If one '
              'month runs 26 days, the next 41 and the one after 33, that '
              'variation is the thing worth describing, not the individual '
              'numbers.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why a cycle becomes unpredictable'),
        paragraphs: [
          _en('Most of a cycle is spent doing one job: growing a follicle until '
              'one of them is ready to release an egg. Ovulation is the hinge. '
              'Once it happens, the second half of the cycle is remarkably '
              'consistent, usually twelve to fourteen days, because it is run '
              'by a structure with a fixed lifespan.'),
          _en('So when a cycle is unpredictable, it is almost always the first '
              'half that is varying. The follicles take longer to mature, or '
              'several start and none finishes, and the period arrives late '
              'because the ovulation it follows arrived late.'),
          _en('That is why "irregular" and "hard to time" are the same problem '
              'described twice. It is not that the window moves around '
              'mysteriously; it is that the window is arriving on a schedule '
              'the calendar cannot predict.'),
        ],
      ),
      PvReadSection(
        heading: _en('The long list of causes'),
        paragraphs: [
          _en('PCOS is the most common single cause of irregular cycles in '
              'people of reproductive age, and it is worth knowing that. It is '
              'not the only one, and assuming it is has two costs: it can send '
              'someone down a PCOS route when a thyroid test would have '
              'answered it in a week, and it can convince someone who does '
              'have PCOS that a normal thyroid rules it out.'),
          _en('Thyroid function, both under and over active, changes cycles '
              'and is checked with a single blood test. Raised prolactin does '
              'the same and is also a blood test. Significant weight change in '
              'either direction affects ovulation. Heavy training, illness, '
              'poor sleep and sustained stress all can.'),
          _en('Coming off hormonal contraception often gives a few irregular '
              'months before a pattern returns. Breastfeeding suppresses '
              'cycles by design. The years after periods start and the years '
              'approaching menopause are both naturally irregular.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('One irregular cycle is not a pattern'),
          body: _en('Almost everyone has an off month. Illness, a difficult '
              'stretch at work or a long journey can push ovulation later, and '
              'the period follows it. What is worth investigating is a run of '
              'them, or a cycle length that keeps changing by more than a week '
              'or two.'),
        ),
      ),
      PvReadSection(
        heading: _en('What "irregular" means when you are trying'),
        paragraphs: [
          _en('The practical difficulty is timing rather than possibility. An '
              'irregular cycle usually still ovulates, just not on a date '
              'anyone can predict from the calendar, so ovulation kits, '
              'cervical mucus and basal temperature become more useful than '
              'counting days.'),
          _en('Some cycles do not ovulate at all. These are called anovulatory '
              'cycles, and they can still produce bleeding, which is what '
              'makes them easy to miss. A cycle that regularly runs past about '
              'forty-five days is more likely to be one of these, and it is '
              'the pattern most worth taking to a doctor.'),
          _en('None of that means a long wait. Irregular ovulation is one of '
              'the most treatable causes of difficulty conceiving, and the '
              'usual first step is a tablet taken for five days early in the '
              'cycle. That is a conversation with a doctor, not something to '
              'arrange yourself.'),
        ],
      ),
      PvReadSection(
        heading: _en('What actually helps you find out'),
        paragraphs: [
          _en('Three months of logged period start dates is worth more at an '
              'appointment than any description. It turns "they are all over '
              'the place" into a set of dates a doctor can read in ten seconds, '
              'and it is the single most useful thing to arrive with.'),
          _en('Note the longest gap you have had, whether periods are heavier '
              'or lighter than they used to be, and anything else that changed '
              'around the time the pattern did — a new medicine, a big weight '
              'change, a stressful year. Those details are what turn a general '
              'complaint into a specific question.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth booking rather than waiting'),
      body: _en('Book a check if you have gone three months or more without a '
          'period and pregnancy is ruled out, if cycles are consistently '
          'shorter than 21 days or longer than 35, if you are bleeding between '
          'periods or after sex, or if periods have become much heavier. Any '
          'of these is a reason for a conversation, and none of them is an '
          'emergency.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('My cycles are always 34 days. Is that irregular?'),
        answer: _en('No. That is a long but regular cycle, and a regular cycle '
            'is a predictable one whatever its length. Ovulation is simply '
            'happening later than it would in a 28-day cycle.'),
      ),
      PvReadFaq(
        question: _en('Does an irregular cycle mean I have PCOS?'),
        answer: _en('No. It is one of several possible causes and the most '
            'common single one, but a thyroid test, a prolactin test and a '
            'conversation about the last year usually come first. Only a '
            'doctor can work out which it is.'),
      ),
      PvReadFaq(
        question: _en('Can I still get pregnant with irregular cycles?'),
        answer: _en('Yes, and many people do without any help at all. The '
            'difficulty is usually timing rather than possibility, and where '
            'ovulation is genuinely not happening it is one of the more '
            'treatable causes there is.'),
      ),
    ],
    evidence: _en('NICE guideline NG156 (heavy menstrual bleeding) and CG156 '
        '(fertility assessment and treatment); the 2023 International '
        'Evidence-Based Guideline for the Assessment and Management of PCOS; '
        'RCOG patient information on irregular periods. Reviewed August 2026.'),
    readNext: ['ttc_read_pcos_cycle'],
  ),


  PvRead(
    id: 'ttc_read_pcos_diagnosed',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('If a doctor says PCOS'),
    teaser: _en('What the diagnosis is actually based on, what it does and '
        'does not mean, and what to ask before you leave the room.'),
    scaleSetter: _en('Being told you have PCOS lands hard, partly because the '
        'name sounds like a disease of the ovaries and partly because the '
        'internet is full of language about it that no doctor would use. It is '
        'a hormonal pattern, it is common, and it is managed rather than '
        'cured.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('PCOS is diagnosed on a set of criteria rather than a single '
              'test. There are three things a doctor looks at: whether '
              'ovulation is irregular or absent, whether there are signs of '
              'raised androgens, and what an ultrasound shows about the '
              'ovaries. Two of the three are enough, once other causes have '
              'been ruled out.'),
          _en('That last clause does a lot of work. Thyroid problems and '
              'raised prolactin produce a similar picture and are excluded '
              'first, which is why a diagnosis usually involves blood tests '
              'that are not about PCOS at all.'),
        ],
      ),
      PvReadSection(
        heading: _en('The name is misleading, and that matters'),
        paragraphs: [
          _en('"Polycystic" suggests cysts, and it is the single most '
              'frightening word in the diagnosis. What an ultrasound is '
              'actually showing is a larger than usual number of small '
              'follicles — the fluid-filled sacs every ovary makes each month, '
              'each one holding an immature egg. They are not cysts in the '
              'sense of something that has gone wrong and needs removing.'),
          _en('This is also why the scan alone does not diagnose anything. A '
              'lot of people have ovaries that look like this and have no '
              'other feature of PCOS, and some people with clear PCOS have '
              'ovaries that look ordinary.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('It is common, and it is not rare to have it mildly'),
          body: _en('PCOS affects somewhere around one in ten people of '
              'reproductive age worldwide. It exists on a wide spectrum: some '
              'have every feature strongly, many have a mild version that only '
              'shows up as slightly unpredictable cycles.'),
        ),
      ),
      PvReadSection(
        heading: _en('What it means for having children'),
        paragraphs: [
          _en('The honest version is that PCOS often makes conceiving take '
              'longer, and that most people with PCOS who want to have '
              'children do. Those two statements are both true and the second '
              'one gets left out far too often.'),
          _en('The difficulty is ovulation. If eggs are released rarely or '
              'unpredictably, there are fewer chances in a year and they are '
              'harder to time. It is not a problem with the eggs themselves, '
              'and egg supply in PCOS is typically good rather than poor.'),
          _en('That is why the usual first treatment is a short course of '
              'tablets to encourage ovulation, and why it works for a large '
              'proportion of people who try it. Your own situation is a '
              'conversation with the doctor who knows your history.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to ask before you leave'),
        paragraphs: [
          _en('Ask which of the criteria you met, and whether other causes were '
              'excluded. It is a reasonable question and it tells you what the '
              'diagnosis is actually resting on.'),
          _en('Ask whether your insulin or glucose was checked, and whether it '
              'should be. Insulin resistance is common alongside PCOS and it '
              'changes what treatment makes sense.'),
          _en('Ask what to do now if you are trying to conceive, and what to '
              'do if you are not. The answers are different, and being handed '
              'the wrong one is a common reason people leave confused.'),
          _en('Ask when to come back. A diagnosis with no next appointment '
              'attached is the part that most often turns into a year of '
              'nothing happening.'),
        ],
      ),
      PvReadSection(
        heading: _en('The part that is not about fertility'),
        paragraphs: [
          _en('PCOS is a metabolic condition as much as a reproductive one, '
              'and a good doctor will mention that even in an appointment '
              'about trying to conceive. Over years it carries a higher chance '
              'of insulin resistance and of type 2 diabetes, and that risk is '
              'worth knowing about precisely because it is one of the more '
              'modifiable things in medicine.'),
          _en('Said plainly and without alarm: this is a reason for an '
              'occasional blood test and for the ordinary, unglamorous habits '
              'that help anyway — moving regularly, sleeping properly, eating '
              'in a way you can keep up. It is not a reason to overhaul your '
              'life this week.'),
          _en('It also matters during pregnancy. Gestational diabetes is more '
              'common with PCOS, which usually means an earlier glucose test '
              'rather than anything more dramatic. Mentioning the diagnosis at '
              'a first antenatal appointment is enough for that to be handled '
              'routinely.'),
        ],
      ),
      PvReadSection(
        heading: _en('What not to do this week'),
        paragraphs: [
          _en('Do not start a supplement stack you found in a forum. Some are '
              'harmless and expensive, a few interact with real medicines, and '
              'none of them replaces the conversation you have just had.'),
          _en('Do not start an aggressive diet. There is no PCOS diet in the '
              'sense the internet means it, nothing is forbidden, and the '
              'changes that help are ordinary and gradual.'),
          _en('Do not treat the diagnosis as a verdict on whether you can have '
              'children. It is information about how your cycle behaves, and '
              'it is the beginning of a plan rather than the end of one.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go back sooner if these appear'),
      body: _en('Contact a doctor if you have gone more than three or four '
          'months without a period, if you are bleeding very heavily or '
          'between periods, if hair growth or hair loss is changing quickly, '
          'or if you have been told you have PCOS but nobody checked your '
          'thyroid or prolactin. Rapid changes in particular deserve a '
          'conversation rather than a wait.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Does PCOS go away?'),
        answer: _en('It is managed rather than cured, and its features often '
            'soften over time — cycles frequently become more regular through '
            'the thirties and forties. Managing it well changes how much it '
            'affects daily life.'),
      ),
      PvReadFaq(
        question: _en('I was diagnosed on a scan alone. Is that right?'),
        answer: _en('A scan on its own is not enough — two of the three '
            'criteria are needed. If a scan was the only thing that happened, '
            'it is very reasonable to go back and ask what else was '
            'considered.'),
      ),
      PvReadFaq(
        question: _en('Will I need IVF?'),
        answer: _en('Most people with PCOS do not. Ovulation-inducing tablets '
            'are the usual first step and they work for many; IVF is further '
            'along the same road, not the starting point.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of Polycystic Ovary Syndrome (Monash '
        'University, endorsed by ESHRE and ASRM); Rotterdam consensus '
        'criteria; NICE CG156. Reviewed August 2026.'),
    readNext: ['ttc_read_pcos_treatment'],
  ),



  PvRead(
    id: 'ttc_read_pcos_ovulation',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('PCOS and ovulation'),
    teaser: _en('Why the egg is usually fine and the release is the problem, '
        'and what that changes about trying.'),
    scaleSetter: _en('Almost everything difficult about conceiving with PCOS '
        'comes down to one mechanism. Understanding it makes the rest of the '
        'advice make sense, including why the first treatment is a tablet '
        'rather than anything more involved.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Every month the ovaries start growing a group of follicles. '
              'Normally one pulls ahead, becomes dominant, and releases its '
              'egg. The rest are reabsorbed. That selection is the whole '
              'event, and it depends on a rise and fall of hormones with '
              'fairly precise timing.'),
          _en('In PCOS that selection often stalls. Several follicles start, '
              'none becomes clearly dominant, and none is released. They stay '
              'as small follicles — which is what an ultrasound is seeing when '
              'it describes polycystic ovaries — and the cycle stretches on '
              'waiting for something that has not happened.'),
        ],
      ),
      PvReadSection(
        heading: _en('The eggs themselves are usually fine'),
        paragraphs: [
          _en('This is the part most worth carrying away. PCOS is a problem of '
              'release, not of supply. Egg reserve in PCOS is typically good '
              'and often higher than average for age, which is why AMH results '
              'in PCOS frequently come back high and can be misread as good '
              'news or bad news when they are really just a count.'),
          _en('So the goal of treatment is not to fix the eggs. It is to get '
              'one released, reliably, on a schedule anyone can work with.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Irregular does not mean never'),
          body: _en('Many people with PCOS ovulate, just not every cycle and '
              'not on a predictable date. A long cycle is often a cycle where '
              'ovulation happened late rather than not at all, and pregnancies '
              'conceived on cycle day thirty-something are entirely ordinary.'),
        ),
      ),
      PvReadSection(
        heading: _en('A cycle that bleeds but did not ovulate'),
        paragraphs: [
          _en('An anovulatory cycle is one where no egg was released. It can '
              'still end in bleeding, which is what makes it easy to miss — '
              'the lining builds up and eventually breaks down without the '
              'usual hormonal sequence behind it.'),
          _en('These are often lighter or heavier than usual, and irregular in '
              'timing. A cycle running well past forty-five days is more '
              'likely to be one, and a run of them is the pattern most worth '
              'showing a doctor.'),
          _en('Ovulation kits are useful here but need reading carefully. In '
              'PCOS, the hormone they detect can sit high for long stretches '
              'without an egg being released, so a positive result is less '
              'reliable than it is for other people. A rise in basal body '
              'temperature that holds for several days is better evidence, '
              'because it happens after the fact.'),
        ],
      ),
      PvReadSection(
        heading: _en('What timing looks like in practice'),
        paragraphs: [
          _en('Counting fourteen days back from an expected period only works '
              'if the period is expected on a date. With unpredictable cycles '
              'the calendar cannot lead, so the body has to.'),
          _en('Cervical mucus is the most useful free sign there is. In the '
              'days before ovulation it becomes clearer, wetter and stretchy, '
              'and that change is the window opening. It is worth learning '
              'because it costs nothing and it works whatever the cycle length.'),
          _en('The other approach is simply to stop timing. Sex every two or '
              'three days across the cycle covers ovulation whenever it '
              'arrives, without anyone having to predict it. For couples '
              'finding the timing exhausting, this is a legitimate strategy '
              'rather than a consolation prize.'),
          _en('That works because the window is longer than most people '
              'assume. Sperm can survive in the reproductive tract for up to '
              'about five days in good conditions, so sex a few days before an '
              'egg is released still counts. It is the egg that is brief, '
              'lasting somewhere between twelve and twenty-four hours after '
              'release.'),
          _en('Which is why every-two-or-three-days works without any '
              'prediction at all: it keeps sperm present across the whole '
              'stretch when an egg might arrive. With an unpredictable cycle '
              'that is often more effective than a well-timed guess, and it is '
              'considerably kinder to live with.'),
        ],
      ),
      PvReadSection(
        heading: _en('When help is offered, what it is'),
        paragraphs: [
          _en('The usual first step is a short course of tablets taken early '
              'in the cycle to encourage one follicle to become dominant. It '
              'is taken for about five days, monitored with scans in the first '
              'cycles, and it induces ovulation in a large proportion of '
              'people who take it.'),
          _en('Metformin is sometimes used alongside where insulin resistance '
              'is part of the picture. It is a diabetes medicine being used '
              'for its effect on insulin, and in PCOS that can help ovulation '
              'return.'),
          _en('Both are prescription decisions that depend on your history, '
              'your other results and what a doctor finds. Nothing here '
              'replaces that, and nothing here should be started on the basis '
              'of an article.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth asking about now'),
      body: _en('See a doctor if your cycles regularly run past forty-five '
          'days, if you have gone three months or more without a period, or if '
          'you have been trying for a year without success — six months if you '
          'are over 35. Irregular ovulation is one of the most treatable '
          'causes of difficulty conceiving, so this is a conversation worth '
          'having early rather than late.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('My ovulation kit is positive nearly every day. Why?'),
        answer: _en('In PCOS the hormone these kits detect can stay elevated '
            'for long stretches without an egg being released, so repeated '
            'positives are common and not very informative. Cervical mucus and '
            'basal temperature are more useful, and a doctor can confirm '
            'ovulation with a blood test.'),
      ),
      PvReadFaq(
        question: _en('Does a period mean I ovulated?'),
        answer: _en('Not always. A cycle can bleed without an egg having been '
            'released. That is why a doctor may suggest a blood test about a '
            'week before a period is due, which is the straightforward way to '
            'check.'),
      ),
      PvReadFaq(
        question: _en('My AMH is high. Is that good?'),
        answer: _en('It is neither good nor bad on its own. A high AMH in PCOS '
            'reflects the larger number of small follicles and is expected. It '
            'is a count, not a measure of quality or of how easily you will '
            'conceive.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS; NICE CG156 (fertility problems); '
        'Cochrane reviews of ovulation induction agents in PCOS. Reviewed '
        'August 2026.'),
    readNext: ['ttc_read_pcos_treatment'],
  ),


  // ⚠️ RENAMED FROM THE BRIEF'S "Your realistic odds with PCOS", DELIBERATELY.
  //
  // A possessive plus a probability word is the exact construction CLAUDE.md's
  // clinical invariants forbid, and `ttc_clinical_review_test.dart` scans for
  // it. The rule is not pedantry: "your odds" frames a population statistic as
  // a fact about her, which is what turns a reassuring number into a target she
  // is failing to hit.
  //
  // The content the brief wanted — honest, non-vague, not falsely cheerful — is
  // entirely deliverable without that framing. Population figures stay; the
  // possessive goes.
  PvRead(
    id: 'ttc_read_pcos_timelines',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('Conceiving with PCOS, realistically'),
    teaser: _en('What the research actually says about how long it takes, said '
        'without either false cheer or doom.'),
    scaleSetter: _en('Two things are true at once and most articles only tell '
        'you one of them. PCOS often makes conceiving take longer. And the '
        'large majority of people with PCOS who want children have them. '
        'Holding both is the honest position.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The reason PCOS lengthens the road is arithmetic rather than '
              'anything sinister. Conception needs an egg released and sperm '
              'present at the right time. Someone with a 28-day cycle has '
              'roughly thirteen opportunities a year. Someone whose cycles run '
              'sixty days has six, and they are harder to locate.'),
          _en('Fewer chances, spread further apart, is most of the difficulty. '
              'It is not that each chance is worth less.'),
        ],
      ),
      PvReadSection(
        heading: _en('What the population numbers say'),
        paragraphs: [
          _en('Across studies of people with PCOS who set out to have '
              'children, the large majority do — most estimates land somewhere '
              'around three quarters to four in five, counting both '
              'unassisted conception and treatment. Studies that follow people '
              'for long enough tend to find higher figures than studies that '
              'stop at two years, which tells you something about patience as '
              'much as about biology.'),
          _en('Ovulation-inducing tablets are the usual first treatment and '
              'they induce ovulation in a substantial majority of people who '
              'take them. Not everyone who ovulates conceives in that cycle, '
              'which is true of everybody and not a PCOS finding.'),
          _en('These are figures about groups of people, not about you. Nobody '
              'can tell an individual how long it will take, and any app or '
              'article that offers a personal number is inventing it.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Why we will never show you a personal percentage'),
          body: _en('A number attached to you would be made up. It would also '
              'become a target — something to check against every month and '
              'fail. Population figures are here because they reduce pressure; '
              'a personal one would add it.'),
        ),
      ),
      PvReadSection(
        heading: _en('What genuinely shifts the picture'),
        paragraphs: [
          _en('Getting ovulation to happen is the biggest single lever, which '
              'is why treatment starts there. A cycle that ovulates is a cycle '
              'that counts.'),
          _en('Age matters here as it does for everyone, and it is the reason '
              'not to spend three years waiting to see. It is also the reason '
              'guidance suggests seeking help after six months rather than '
              'twelve once you are past 35.'),
          _en('Where insulin resistance is part of the picture, addressing it '
              'often helps cycles return. That is a medical conversation with '
              'ordinary, gradual lifestyle changes alongside — not a diet, not '
              'a target, and not something to attack.'),
          _en('The male half is half. A semen analysis is cheap, quick and '
              'frequently skipped in couples where a PCOS diagnosis has '
              'already been made, which means a second cause can sit '
              'undiscovered for a year.'),
        ],
      ),
      PvReadSection(
        heading: _en('When to stop waiting and ask'),
        paragraphs: [
          _en('The general advice is a year of trying before seeking help, or '
              'six months over 35. With PCOS, that clock is worth starting '
              'earlier, because a cycle that is not ovulating is not really '
              '"trying" in the way the guidance assumes.'),
          _en('If your cycles are long or absent, there is no benefit in '
              'waiting out a year to prove it. A conversation at three or four '
              'months is reasonable, and the first steps are simple ones.'),
          _en('It also helps to count cycles rather than months. Twelve months '
              'of trying with a 28-day cycle is thirteen attempts; twelve '
              'months with a 70-day cycle is five. Someone who has been '
              '"trying for a year" in the second case has had roughly the same '
              'number of chances as someone five months in — which is worth '
              'saying to yourself, and worth saying to a doctor who is working '
              'out how urgent this is.'),
          _en('That framing cuts both ways, and the second edge is the reason '
              'to go early rather than a reason to relax. Fewer chances per '
              'year means the calendar moves faster than the attempts do, and '
              'age keeps counting in months regardless of how many cycles fit '
              'inside them.'),
        ],
      ),
      PvReadSection(
        heading: _en('The part nobody writes down'),
        paragraphs: [
          _en('Trying for longer than expected is hard in a way that has '
              'nothing to do with statistics. Timed sex stops being intimacy. '
              'Every announcement lands differently. The advice to relax is '
              'both useless and infuriating.'),
          _en('None of that is a failure of attitude, and stress is not why '
              'this is taking time. If it is wearing you down, that is worth '
              'saying out loud to a doctor too — it is a legitimate part of '
              'the appointment, not a distraction from it.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not wait out the full year'),
      body: _en('If your cycles are irregular or absent, book a conversation '
          'after three or four months of trying rather than twelve. Go sooner '
          'if you have gone three months without a period, or if you are over '
          '35. Ovulation problems are among the most treatable causes of '
          'difficulty conceiving, and the earlier steps are the simplest ones.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Will I need IVF?'),
        answer: _en('Most people with PCOS do not. Tablets to induce ovulation '
            'are the usual first step and they help a large proportion; IVF '
            'sits further along the same road for those it does not.'),
      ),
      PvReadFaq(
        question: _en('Is my egg quality worse because of PCOS?'),
        answer: _en('PCOS is generally a problem of releasing eggs rather than '
            'of the eggs themselves, and egg reserve is often higher than '
            'average. Quality is affected by age much as it is for anyone.'),
      ),
      PvReadFaq(
        question: _en('Everyone tells me to relax. Does stress cause this?'),
        answer: _en('No. Severe, sustained stress can affect cycles, but PCOS '
            'is a hormonal and metabolic condition and it is not caused by '
            'worrying. You have not done this to yourself.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS; NICE CG156; Cochrane reviews of '
        'letrozole and clomifene for ovulation induction; long-term follow-up '
        'cohort studies of fertility outcomes in PCOS. Reviewed August 2026.'),
    readNext: ['ttc_read_pcos_ovulation'],
  ),



  PvRead(
    id: 'ttc_read_pcos_insulin',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('What changes the curve, nothing banned'),
    teaser: _en('Insulin is the lever most worth understanding in PCOS, and '
        'nothing about it requires giving up rice.'),
    scaleSetter: _en('There is no PCOS diet. There is no forbidden food. What '
        'there is, for many people with PCOS, is a body that responds more '
        'strongly to a sharp rise in blood sugar — and a handful of ordinary '
        'changes that flatten those rises without removing anything.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Insulin is the hormone that moves sugar out of the blood and '
              'into cells. In insulin resistance, cells respond less readily, '
              'so the body makes more insulin to get the same job done. The '
              'sugar ends up where it should be, but the insulin level stays '
              'high.'),
          _en('That matters in PCOS because high insulin pushes the ovaries to '
              'make more androgens, and raised androgens are one of the things '
              'that interferes with a follicle becoming dominant. This is the '
              'loop that connects a metabolic issue to an ovulation one.'),
          _en('Not everyone with PCOS has insulin resistance, and it is not '
              'limited to people at any particular size. It is checked with a '
              'blood test rather than guessed at, which is why it is worth '
              'asking whether yours has been.'),
        ],
      ),
      PvReadSection(
        heading: _en('The curve, not the food'),
        paragraphs: [
          _en('If insulin follows blood sugar, the useful question is not '
              '"what should I cut out" but "what makes the rise gentler". Those '
              'are very different questions and only one of them has a '
              'workable answer.'),
          _en('The same food produces a different curve depending on what is '
              'with it. Carbohydrate eaten alone spikes faster than the same '
              'carbohydrate eaten alongside protein, fat or fibre, because '
              'those slow how quickly it is broken down and absorbed.'),
          _en('This is why "nothing banned" is not a kindness, it is the '
              'actual mechanism. Rice with dal, curd and a vegetable behaves '
              'very differently from rice on its own — and it is the same '
              'rice, in the same quantity.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Roti and rice are not the problem'),
          body: _en('Indian food is often described online as uniquely bad for '
              'PCOS, which is nonsense. A traditional thali is naturally built '
              'the way this article recommends: carbohydrate arriving with '
              'protein, fat, fibre and fermented food. What changes the curve '
              'is usually the composition of a plate, not its cuisine.'),
        ),
      ),
      PvReadSection(
        heading: _en('What actually helps, in plain terms'),
        paragraphs: [
          _en('Eat protein at every meal, including breakfast. Breakfast is '
              'the meal most often pure carbohydrate — poha, upma, toast, tea '
              'with sugar — and adding eggs, curd, paneer, chana or nuts to it '
              'changes the shape of the whole morning.'),
          _en('Do not eat carbohydrate on its own, particularly as a snack. A '
              'biscuit with tea is a sharper rise than the same biscuit after '
              'a meal.'),
          _en('Move after eating. A ten or fifteen minute walk after a meal '
              'lowers the peak measurably, because working muscle takes up '
              'sugar without needing much insulin at all. It is the highest '
              'return per unit of effort on this list.'),
          _en('Sleep matters more than it sounds like it should. A few short '
              'nights measurably worsens insulin sensitivity in healthy people, '
              'let alone in someone already resistant.'),
          _en('Strength work helps over months rather than days. More muscle '
              'means more places for sugar to go, which lowers the insulin '
              'needed to put it there.'),
        ],
      ),
      PvReadSection(
        heading: _en('What the internet gets wrong about this'),
        paragraphs: [
          _en('Cutting carbohydrate to almost nothing works while it lasts and '
              'almost nobody sustains it. A change kept for six weeks and '
              'abandoned does less than a smaller change kept for two years.'),
          _en('"Anti-inflammatory" food lists, detoxes, and eliminating entire '
              'categories of ordinary food are not supported by evidence in '
              'PCOS and they carry a real cost: they make eating stressful and '
              'they make eating with other people awkward.'),
          _en('Nothing here is about weight. These changes affect insulin '
              'directly, and they are worth making whether or not anything '
              'else about your body changes at all.'),
        ],
      ),
      PvReadSection(
        heading: _en('If a doctor suggests metformin'),
        paragraphs: [
          _en('Metformin is a diabetes medicine used in PCOS for its effect on '
              'insulin. Where insulin resistance is part of the picture it can '
              'help cycles become more regular, and it is sometimes used '
              'alongside ovulation-inducing tablets.'),
          _en('It is a prescription and a decision that depends on your test '
              'results, not something to seek out because a forum recommended '
              'it. Food changes and metformin are not alternatives — they work '
              'on the same problem from different directions, and a doctor '
              'deciding between them has information an article does not.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask for the test rather than guessing'),
      body: _en('Ask a doctor whether your fasting glucose, HbA1c or insulin '
          'have been checked, particularly if you have skin darkening on your '
          'neck or armpits, a family history of type 2 diabetes, or cycles '
          'that have become longer over time. If you are already on any '
          'medicine, or you are pregnant or trying, discuss changes with a '
          'doctor before making large ones.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do I have to give up rice?'),
        answer: _en('No. What it is eaten with, and what you do in the hour '
            'after, changes the response far more than removing it would. Rice '
            'with dal, curd and vegetables is a completely reasonable meal '
            'with PCOS.'),
      ),
      PvReadFaq(
        question: _en('Is intermittent fasting good for PCOS?'),
        answer: _en('The evidence is thin and mixed. For some people it '
            'usefully reduces snacking; for others it produces a very large '
            'meal that spikes hard, or a difficult relationship with eating. '
            'It is not a PCOS treatment and it is not required.'),
      ),
      PvReadFaq(
        question: _en('I am not overweight. Does insulin resistance still '
            'apply to me?'),
        answer: _en('It can. Insulin resistance occurs across the whole range '
            'of body sizes in PCOS, which is exactly why it is worth testing '
            'rather than assuming either way.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS; Endocrine Society clinical '
        'practice guideline on PCOS; trials of post-meal walking on '
        'postprandial glucose; Cochrane review of metformin in PCOS. Reviewed '
        'August 2026.'),
    readNext: ['ttc_read_pcos_food'],
  ),


  PvRead(
    id: 'ttc_read_pcos_inositol',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('Inositol: what is shown to help'),
    teaser: _en('The one supplement in the PCOS aisle with real evidence '
        'behind it, and an honest account of how strong that evidence is.'),
    scaleSetter: _en('The PCOS supplement market is enormous and most of it is '
        'marketing. Inositol is the exception worth knowing about — not '
        'because it is a cure, but because it is the one with trials behind '
        'it, and because the trials are more modest than the packaging.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Inositol is a sugar-like compound the body makes itself and '
              'also gets from food — fruit, beans, grains and nuts all carry '
              'it. It is involved in how cells respond to insulin, which is '
              'why it turns up in PCOS research at all.'),
          _en('Two forms matter: myo-inositol and D-chiro-inositol. Most '
              'products sold for PCOS combine them, often in a ratio of about '
              'forty to one, which is roughly the ratio found in the body.'),
        ],
      ),
      PvReadSection(
        heading: _en('What the trials actually found'),
        paragraphs: [
          _en('Across a number of randomised trials, inositol improved markers '
              'of insulin sensitivity in people with PCOS and was associated '
              'with more regular cycles and more frequent ovulation than '
              'placebo.'),
          _en('The honest caveats matter. Many of the trials are small. They '
              'use different doses, different forms and different ratios, '
              'which makes them hard to pool. Several were funded by companies '
              'selling the product. And the outcomes measured are mostly '
              'cycles and ovulation rather than babies, which is a real '
              'distinction.'),
          _en('So the fair summary is: promising, reasonably safe, not '
              'established as a fertility treatment, and not a substitute for '
              'anything a doctor has prescribed.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('It is a supplement, not a medicine'),
          body: _en('Supplements are not regulated the way medicines are. What '
              'is on the label is not verified the way a prescription is, and '
              'the amount in the capsule can differ from the amount printed on '
              'the box. Buying from a pharmacy rather than a marketplace '
              'listing is a small thing that helps.'),
        ),
      ),
      PvReadSection(
        heading: _en('How it is usually taken'),
        paragraphs: [
          _en('The dose used in most trials is around four grams of '
              'myo-inositol a day, typically split into two, often with a '
              'small amount of D-chiro-inositol alongside. Effects on cycles '
              'in the studies took roughly three months to appear, which is '
              'worth knowing before deciding after three weeks that it has '
              'not worked.'),
          _en('Side effects are generally mild and mostly digestive at higher '
              'doses. It is not known to interact dangerously with common '
              'medicines, but it does affect insulin, so anyone on metformin '
              'or diabetes treatment should mention it rather than simply '
              'adding it.'),
          _en('Powders and capsules both exist and neither is better. Powder '
              'is usually cheaper per gram and dissolves in water with a '
              'faintly sweet taste; capsules mean swallowing several at a '
              'time to reach the studied dose, which is worth checking on the '
              'label before buying, because a bottle that looks affordable at '
              'one capsule a day may be a fraction of what the trials used.'),
          _en('That is the most common way money is wasted here. A product '
              'containing a few hundred milligrams is being sold against '
              'evidence built on four grams, and the number on the front of '
              'the box is frequently the combined weight of everything in the '
              'blend rather than the inositol in it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What the rest of the shelf is doing'),
        paragraphs: [
          _en('Vitamin D is worth checking rather than assuming, and '
              'deficiency is very common in India. If yours is low, correcting '
              'it is sensible for reasons that have nothing to do with PCOS.'),
          _en('Berberine appears in a lot of PCOS marketing. It does have some '
              'effect on glucose, and it also interacts with a long list of '
              'medicines, which is why it belongs in a conversation with a '
              'doctor rather than in a basket.'),
          _en('Most of the rest — the fertility blends, the detox teas, the '
              'proprietary mixes with confident names — has no evidence in '
              'PCOS at all. Some are harmless and expensive. A few are neither.'),
          _en('Whatever you take, write it down and take the list to '
              'appointments. Supplements are the thing people most often '
              'forget to mention because they did not come from a pharmacy, '
              'and they are exactly what a doctor needs to know about.'),
        ],
      ),
      PvReadSection(
        heading: _en('The honest bottom line'),
        paragraphs: [
          _en('If you want to try inositol, it is a defensible thing to try, '
              'and it is the only item in this category that reaches that bar. '
              'Give it three months, buy it from somewhere reputable, and tell '
              'your doctor.'),
          _en('If you would rather not, you are not missing a treatment. The '
              'things with the strongest evidence in PCOS remain ovulation '
              'induction where it is needed, and the ordinary changes that '
              'improve insulin sensitivity.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Tell a doctor what you are taking'),
      body: _en('Speak to a doctor before starting inositol if you are on '
          'metformin or any diabetes medicine, if you are pregnant or '
          'breastfeeding, or if you are already taking other supplements for '
          'PCOS. Stop and seek advice if you develop persistent digestive '
          'upset, dizziness, or symptoms of low blood sugar.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is inositol better than metformin?'),
        answer: _en('They are not directly comparable and metformin has far '
            'more evidence behind it. Some trials suggest similar effects on '
            'certain markers with fewer digestive side effects, but metformin '
            'is a prescribed medicine and inositol is not a replacement for '
            'one.'),
      ),
      PvReadFaq(
        question: _en('How long before I know if it works?'),
        answer: _en('The trials that saw changes in cycles generally saw them '
            'over about three months. Judging it after a few weeks will not '
            'tell you anything.'),
      ),
      PvReadFaq(
        question: _en('Can I take it while trying to conceive?'),
        answer: _en('Many people do and it is not known to be harmful, but '
            'this is a question for the doctor who knows your history, '
            'particularly if you are on any treatment.'),
      ),
    ],
    evidence: _en('Cochrane review of inositol for PCOS; 2023 International '
        'Evidence-Based Guideline for the Assessment and Management of PCOS, '
        'which grades inositol as having limited evidence and advises it be '
        'considered experimental; randomised trials of myo-inositol on '
        'ovulation and cycle regularity. Reviewed August 2026.'),
  ),



  // ⚠️ THE HARDEST ONE IN THE SET TO WRITE, AND THE RULE IS ABSOLUTE: no
  // number, no target, no range, no plan. Not a BMI, not a percentage of body
  // weight, not "even a few kilos". The brief forbids it, the clinical
  // invariants forbid a personalised target, and the practical reason is the
  // strongest of the three — a woman with PCOS has usually been told about her
  // weight by everyone already, and the app that does it again is the app she
  // closes. This piece exists to be the one place that does not.
  PvRead(
    id: 'ttc_read_pcos_weight',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('Weight and PCOS, said kindly'),
    teaser: _en('Why the advice you have been given is incomplete, and what is '
        'actually worth your attention.'),
    scaleSetter: _en('If you have PCOS you have probably been told to lose '
        'weight, possibly by someone who said nothing else. This piece will '
        'not repeat that, will not give you a number, and will not suggest a '
        'plan. It will explain what the relationship actually is, because that '
        'turns out to be more useful.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The first thing worth saying is that the arrow points both '
              'ways. PCOS is usually described as if weight causes it, and '
              'that is not what the evidence shows. The insulin resistance '
              'that often comes with PCOS makes weight easier to gain and '
              'harder to lose, which means for many people the weight is a '
              'consequence of the condition at least as much as a cause.'),
          _en('That matters because being told to fix the cause by addressing '
              'the symptom is both confusing and unfair, and because it '
              'explains something people are frequently disbelieved about: '
              'that the same effort produces less result than it does for '
              'other people. It does.'),
        ],
      ),
      PvReadSection(
        heading: _en('Lean PCOS is real and often missed'),
        paragraphs: [
          _en('A significant proportion of people with PCOS are not '
              'overweight, and they are frequently diagnosed later because the '
              'picture does not match what a clinician is looking for.'),
          _en('If that is you, the whole conversation about weight simply does '
              'not apply, and the parts of management that do — insulin, '
              'ovulation, cycles — are unchanged. Insulin resistance occurs '
              'across the full range of body sizes in PCOS, which is precisely '
              'why it is tested rather than assumed from appearance.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('You did not cause this'),
          body: _en('PCOS has a strong genetic component and runs in families. '
              'It is not caused by anything you ate, did not do, or should '
              'have known. If someone has implied otherwise, they were wrong.'),
        ),
      ),
      PvReadSection(
        heading: _en('What the research supports, without a number'),
        paragraphs: [
          _en('Where someone with PCOS is carrying extra weight and insulin '
              'resistance is present, studies do find that changes in body '
              'composition are associated with cycles becoming more regular '
              'and ovulation returning more often.'),
          _en('We are not going to turn that into a target for you, and the '
              'reason is not squeamishness. A number given by an app becomes '
              'something to check yourself against every month and fail, and '
              'the research is about populations rather than about any '
              'individual. What is right for your body is a conversation with '
              'a doctor who can see your results.'),
          _en('It is also worth knowing that much of the benefit in those '
              'studies tracks with insulin sensitivity improving rather than '
              'with the scale moving. Sleep, movement and how meals are put '
              'together all shift insulin, and they shift it whether or not '
              'anything else changes.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why aggressive dieting backfires here'),
        paragraphs: [
          _en('Very restrictive eating is harder to sustain with PCOS and more '
              'likely to end in a cycle of restriction and rebound, which '
              'leaves insulin sensitivity no better and morale considerably '
              'worse.'),
          _en('Under-eating is also its own risk to ovulation. The body '
              'reduces reproductive function when energy is scarce, which '
              'means a severe diet undertaken to help conception can work '
              'against it directly.'),
          _en('Disordered eating is more common in people with PCOS than in '
              'the general population, and years of weight-focused medical '
              'advice is part of why. If food or your body has become a source '
              'of real distress, that is a legitimate thing to raise with a '
              'doctor in its own right — it is not a side issue to the '
              'fertility conversation.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is actually worth your attention'),
        paragraphs: [
          _en('Whether your insulin, glucose or HbA1c have been checked. That '
              'is a specific question with a specific answer, and it changes '
              'what treatment makes sense.'),
          _en('Whether you are ovulating, and how often. This is the thing '
              'that most directly affects trying to conceive, and it is '
              'measurable.'),
          _en('Movement you would keep doing in six months, at whatever '
              'intensity that is. A walk after dinner most days beats a gym '
              'plan abandoned in February, and the post-meal timing genuinely '
              'matters for insulin.'),
          _en('Sleep, which is the most under-rated item on any PCOS list and '
              'the one nobody sells anything for.'),
          _en('None of those is a weight instruction, and all of them are '
              'things you can raise at an appointment on Monday.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Some of this needs a person, not an article'),
      body: _en('Speak to a doctor if food, eating or your body has become a '
          'source of real distress, if you are restricting significantly, or '
          'if weight has changed quickly without a clear reason. Ask for your '
          'glucose or HbA1c to be checked rather than being given advice about '
          'weight alone — and if an appointment leaves you with only that '
          'advice and no plan, it is reasonable to ask what else was '
          'considered.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('My doctor only said lose weight. Is that all there is?'),
        answer: _en('No, and it is a fair thing to push back on. Ask whether '
            'your insulin and glucose have been checked, whether ovulation is '
            'happening, and what the plan is if you are trying to conceive. '
            'Those are the questions a fuller appointment covers.'),
      ),
      PvReadFaq(
        question: _en('I am not overweight. Does any of this apply?'),
        answer: _en('The weight parts do not. The insulin, ovulation and cycle '
            'parts may well, because insulin resistance in PCOS is not '
            'confined to any body size and is worth testing for regardless.'),
      ),
      PvReadFaq(
        question: _en('Why is it so much harder for me than for other people?'),
        answer: _en('Because it genuinely is. Insulin resistance changes how '
            'the body stores and releases energy, so the same effort produces '
            'a different result. You have not been imagining it and you have '
            'not been doing it wrong.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS, including its recommendations on '
        'weight-inclusive language and screening for disordered eating; '
        'Endocrine Society clinical practice guideline on PCOS; studies of '
        'lifestyle intervention and ovulatory function in PCOS. Reviewed '
        'August 2026.'),
    readNext: ['ttc_read_pcos_insulin'],
  ),


  PvRead(
    id: 'ttc_read_pcos_meds',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('Letrozole, metformin and the usual order'),
    teaser: _en('What gets tried first, what each medicine is actually doing, '
        'and what the steps look like if the first one does not work.'),
    scaleSetter: _en('Treatment for PCOS when you are trying to conceive '
        'follows a fairly settled order, and knowing it makes an appointment '
        'much easier to follow. None of this is something to arrange yourself '
        '— every item here is prescribed and monitored.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Because the central problem in PCOS is usually that ovulation '
              'is not happening reliably, the first treatments are aimed at '
              'exactly that. They are called ovulation induction, and they are '
              'tablets rather than injections.'),
          _en('This matters because a lot of people assume a PCOS diagnosis '
              'means IVF is coming. For most, it does not. The first steps are '
              'cheap, oral, and taken at home.'),
        ],
      ),
      PvReadSection(
        heading: _en('Letrozole, and why it moved to first place'),
        paragraphs: [
          _en('Letrozole is taken for about five days early in the cycle. It '
              'briefly lowers oestrogen, which prompts the body to send a '
              'stronger signal to the ovaries, which encourages one follicle '
              'to become dominant.'),
          _en('For years clomifene was the standard first choice and letrozole '
              'the alternative. That order has largely reversed: in PCOS, '
              'trials found letrozole produced more ovulation and more live '
              'births than clomifene, and current guidance recommends it '
              'first.'),
          _en('It is usually monitored with scans in the first cycles, to '
              'check the response is neither absent nor too strong. Side '
              'effects are generally mild — tiredness, headaches, hot flushes '
              'in some people.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Being prescribed a cancer drug is not what it sounds '
              'like'),
          body: _en('Letrozole is licensed for breast cancer and is used in '
              'fertility care outside that licence, which is common, well '
              'established and recommended by guidelines. If it worries you, '
              'it is a completely reasonable thing to ask about.'),
        ),
      ),
      PvReadSection(
        heading: _en('Metformin, which is doing a different job'),
        paragraphs: [
          _en('Metformin is a diabetes medicine and in PCOS it is used for its '
              'effect on insulin rather than on the ovaries directly. Where '
              'insulin resistance is part of the picture, lowering it can help '
              'cycles become more regular on their own.'),
          _en('It is sometimes used alone, sometimes alongside letrozole where '
              'letrozole by itself has not produced ovulation. The commonest '
              'side effect is digestive upset, which is usually managed by '
              'starting low and increasing slowly, and by taking it with food.'),
          _en('It is not a weight-loss drug and should not be described as '
              'one, though some people do lose a little weight on it.'),
          _en('Whether it is continued once pregnancy is confirmed varies, and '
              'it is a decision for the doctor prescribing it rather than a '
              'general rule. Some continue it through the first trimester, '
              'others stop; either is a normal instruction to be given, and '
              'the important thing is to ask rather than assume.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why the order is the order'),
        paragraphs: [
          _en('Fertility treatment is deliberately built as a ladder, and each '
              'rung is chosen to be the least invasive thing with a reasonable '
              'chance of working. Tablets before injections, injections before '
              'procedures, and each step reviewed after an agreed number of '
              'cycles rather than continued indefinitely.'),
          _en('That is worth understanding because it explains something that '
              'otherwise feels like being fobbed off. Being offered a five-day '
              'course of tablets when you were braced for IVF is not a clinic '
              'being cautious with its resources — it is the step most likely '
              'to work with the least done to you, and for a large proportion '
              'of people with PCOS it is where the road ends.'),
          _en('It also explains why monitoring matters more than the '
              'prescription. The first cycles of any of these are as much '
              'about finding the right dose for your body as about that '
              'cycle succeeding.'),
        ],
      ),
      PvReadSection(
        heading: _en('What comes after, if it is needed'),
        paragraphs: [
          _en('If tablets do not produce ovulation after several monitored '
              'cycles, the next options usually involve a specialist. '
              'Injectable gonadotropins stimulate the ovaries more directly '
              'and need close monitoring, because PCOS ovaries can respond '
              'strongly.'),
          _en('Ovarian drilling is a keyhole procedure that is offered less '
              'often now than it once was, but is still occasionally used.'),
          _en('IUI and IVF sit further along the same path. IVF is effective '
              'in PCOS, and one particular caution applies: the same strong '
              'ovarian response that helps also raises the risk of ovarian '
              'hyperstimulation, which is why protocols are adjusted and '
              'monitoring is careful.'),
        ],
      ),
      PvReadSection(
        heading: _en('Questions worth asking at the appointment'),
        paragraphs: [
          _en('How many cycles of this before we try something else. Having a '
              'number agreed in advance stops a year passing by default.'),
          _en('Will this cycle be monitored, and how. Scans in the early '
              'cycles are usual and they are what tells you whether the dose '
              'is right.'),
          _en('Has a semen analysis been done. It is quick and inexpensive, '
              'and skipping it because a PCOS diagnosis already exists is one '
              'of the more common ways a second cause goes unnoticed.'),
          _en('What are the signs something is wrong, and who do I call. Worth '
              'asking before you need the answer.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the clinic straight away for these'),
      body: _en('If you are on ovulation induction or fertility injections and '
          'develop severe abdominal pain or swelling, rapid weight gain over a '
          'day or two, persistent vomiting, breathlessness, or greatly reduced '
          'urine output, contact your clinic or seek urgent care immediately. '
          'These can be signs of ovarian hyperstimulation, which needs prompt '
          'assessment. Never adjust a prescribed dose yourself.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Will letrozole give me twins?'),
        answer: _en('There is a slightly raised chance of twins compared with '
            'conceiving without treatment, and it is lower with letrozole than '
            'with clomifene. Monitoring in the early cycles is partly there to '
            'watch for too many follicles responding.'),
      ),
      PvReadFaq(
        question: _en('Can I take metformin without a diabetes diagnosis?'),
        answer: _en('Yes, it is prescribed in PCOS for its effect on insulin '
            'rather than for diabetes. It is still a prescription and needs a '
            'doctor.'),
      ),
      PvReadFaq(
        question: _en('How long do people usually stay on these?'),
        answer: _en('Ovulation induction is generally tried for a limited '
            'number of cycles before reviewing, rather than continued '
            'indefinitely. Agreeing that number with your doctor at the start '
            'is the useful part.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS; NICE CG156; Legro et al., '
        'letrozole versus clomiphene for infertility in PCOS (NEJM); Cochrane '
        'reviews of aromatase inhibitors and of metformin in PCOS. Reviewed '
        'August 2026.'),
    readNext: ['ttc_read_pcos_treatment'],
  ),
];
