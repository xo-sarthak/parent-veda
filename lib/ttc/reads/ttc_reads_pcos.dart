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
    teaser: _en("This isn't a diagnosis or a verdict. It's what PCOS is, why "
        'it makes your cycle hard to read, and what really helps.'),
    shortAnswer: _en('PCOS is a common hormone pattern that makes ovulation '
        'irregular, so your cycle gets long and hard to predict. It '
        "doesn't mean you can't get pregnant. Irregular ovulation is one of "
        'the most treatable problems in fertility care.'),

    // ⚠️ SCALE BEFORE DEFINITION. She has been handed a word by a sonographer
    // or found it herself at 1am, and the question underneath is not "what is
    // PCOS" — it is "have I just been told I cannot have children".
    scaleSetter: _en('PCOS is the most common reason ovulation becomes '
        'irregular. And irregular ovulation is one of the most treatable '
        'problems in fertility care. PCOS makes your cycle harder to read. It '
        "doesn't mean you can't get pregnant."),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    heroVideoSlot: 'ttc_vid_pcos_explained',

    sections: [
      // ---- 1. the name -----------------------------------------------------
      PvReadSection(
        paragraphs: [
          _en('Most of the confusion about PCOS starts with its name. '
              '"Polycystic ovary syndrome" describes what the person doing '
              "your scan sees on the screen. But what they see isn't what the "
              'name suggests.'),
          _en("The \"cysts\" aren't cysts. They're ordinary follicles, the "
              'small sacs of fluid every ovary makes each month, and each one '
              'holds an egg.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does the scan really show?'),
        paragraphs: [
          _en('In a usual cycle a handful start to grow, one moves ahead of '
              'the rest, and that one releases its egg.'),
          _en('In PCOS more of them start, but none moves ahead. So they stay '
              'there, '
              'easy to see, in a ring around the edge of the ovary. The scan '
              'counts twenty of them and the report says "polycystic".'),
          _en('So the picture shows ovulation that has stalled, not a '
              'diseased ovary. That matters a lot, because a stall is '
              'something that can be nudged along.'),
        ],
        mythFact: PvMythFact(
          myth: _en('A scan showing polycystic ovaries means you have PCOS.'),
          fact: _en("It doesn't. Up to a quarter of women with completely "
              'regular cycles look like this on a scan, and have nothing '
              'else. PCOS needs two of three things: irregular cycles, raised '
              'androgens (male-type hormones) and the scan picture. That is '
              "why a scan alone isn't a diagnosis."),
        ),
      ),

      // ---- 2. how common ---------------------------------------------------
      PvReadSection(
        heading: _en('How common is PCOS?'),
        paragraphs: [
          _en("It's so common that the number depends on where you draw the "
              'line.'),
          _en('A national Indian study looked at nearly ten thousand '
              'women aged eighteen to forty. About one in five met the broader '
              'Rotterdam definition, and about one in fourteen met the '
              'stricter NIH one. When Indian studies are pooled together, it '
              'comes to about one in nine.'),
          _en("Read that spread the right way round. It doesn't mean doctors "
              'are unsure whether PCOS is real. It means three expert '
              'committees disagree on where a normal cycle ends and PCOS '
              'begins. The women caught in the middle of that disagreement '
              'have the mildest kind.'),
          _en('In real life: in a room of twenty Indian women of childbearing '
              'age, several have PCOS. Most of them will have children. Some '
              'of them already do.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('The number to hold on to'),
          body: _en('PCOS causes about eight in ten of the cases where '
              'ovulation is the problem. And ovulation problems are the kind '
              'fertility medicine is best at treating. Being in the most '
              'common, most studied group is a good place to be.'),
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
        heading: _en('What are the signs of PCOS?'),
        paragraphs: [
          _en('PCOS is diagnosed on two of three findings, not on how you '
              'feel. But how you feel is usually what brings someone to a '
              'doctor. These are the signs that tend to come together.'),
        ],
        bullets: [
          _en('Cycles longer than 35 days, or fewer than eight or nine periods '
              'in a year. This is the most common first sign, and the one that '
              'matters most for getting pregnant.'),
          _en('Acne that starts or carries on well past your teenage years, '
              'often along the jaw and chin rather than the forehead.'),
          _en('Thicker hair on the face, chest or stomach, or thinning hair on '
              'top of the head. Both come from the same raised androgens.'),
          _en('Darker, velvety patches of skin on the neck, underarms or '
              'groin. This one is a sign of insulin resistance in particular. '
              'Mention it even if nothing else on this list fits.'),
          _en("Weight that's hard to lose, especially around the middle. But "
              "a normal weight doesn't rule any of this out."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Having some of these doesn't mean you have PCOS"),
          body: _en('Every sign on this list has other causes. Thyroid '
              'problems and raised prolactin can both cause irregular cycles, '
              'and both are ruled out with a blood test before anyone says the '
              'word PCOS. Use this list to describe what you notice at an '
              'appointment, not as a score to add up at home.'),
        ),
        tip: PvReadTip(
          title: _en('Before you buy a hair supplement'),
          body: _en('Thinning hair has other common causes too, like low iron, '
              'low vitamin D and a thyroid problem. Ask your doctor to check '
              'these with a blood test first. If one is low, treating it can '
              "help your hair. If none is low, extra vitamins aren't likely to "
              'make a difference.'),
        ),
      ),

      // ---- 4. insulin ------------------------------------------------------
      PvReadSection(
        heading: _en('Why does your doctor keep mentioning insulin?'),
        paragraphs: [
          _en('For many women with PCOS, insulin is what drives it. Insulin '
              'is the hormone that moves sugar out of your blood and into your '
              'cells. When your cells respond to it slowly, your body makes up '
              'for it by making more. So the insulin in your blood runs high.'),
          _en('High insulin does two things to an ovary. It pushes the ovary '
              'to make more testosterone. It also lowers a carrier protein in '
              'the blood that usually holds testosterone and keeps it '
              'inactive.'),
          _en('So more testosterone is made, and more of it is free '
              "to act. That's where the acne, the hair changes and the stalled "
              'follicles come from.'),
          _en('This is also why "just lose weight" is such unhelpful advice, '
              'and why it misses most of the picture.'),
          _en('Insulin resistance is '
              "more common at a higher weight, but weight doesn't cause it, "
              'and plenty of slim women have classic PCOS. What you are '
              'working on is the insulin curve, not the number on the scale.'),
        ],
        tip: PvReadTip(
          title: _en('Why the order you eat things in matters'),
          body: _en('The same plate gives a smaller rise in blood sugar when '
              'you eat the protein and vegetables before the rice or roti. '
              "It's one of the few tips here that costs nothing, changes no "
              'recipe, and is backed by real trials. Start there before you '
              'cut out any food groups.'),
        ),
      ),

      // ---- 4b. testosterone (gap plan, 2026-09-26) ---------------------------
      PvReadSection(
        heading: _en("What does testosterone do in a woman's body?"),
        paragraphs: [
          _en("Testosterone isn't only a male hormone. Every woman makes a "
              'small amount in her ovaries and adrenal glands. It helps keep '
              'your muscles and bones strong, supports energy and sex drive, '
              'and some of it is turned into oestrogen.'),
          _en("In PCOS the problem isn't that it's there. It's that there's "
              'more of it than usual, and more of it free to act. That extra '
              'is what a doctor means by raised androgens.'),
        ],
      ),

      // ---- 5. the cycle ----------------------------------------------------
      PvReadSection(
        heading: _en('Why did your cycle get so hard to read?'),
        paragraphs: [
          _en('A usual cycle has a clear order. Follicles grow, one wins, and '
              'it releases its egg. The empty follicle then makes progesterone '
              "for about two weeks. If you don't get pregnant, progesterone "
              'drops and the lining comes away. Your period is the full stop '
              'at the end of that sentence.'),
          _en('When no egg is released, none of the second half happens. '
              "There's no progesterone, so there's no drop, so there's no full "
              'stop. The cycle just keeps going. Thirty-eight days. '
              'Fifty-two. Sometimes months.'),
          _en('When bleeding does finally come, it may not be a true period '
              'at all. It may be a lining that has grown too thick to hold '
              "itself up. That's why it can be heavier, and why it comes with "
              'no warning signs you can learn to spot.'),
        ],
        bullets: [
          _en('Cycles longer than 35 days, or fewer than eight or nine periods '
              'in a year, is the pattern to mention to a doctor.'),
          _en('An ovulation strip can show positive several times in a long '
              'cycle without ovulation following. In PCOS, the hormone it '
              'tests for can stay high instead of rising once.'),
          _en('A basal thermometer (for your resting temperature) confirms '
              "ovulation happened, after it's over. In a long, irregular cycle "
              'that is often more useful than strips, because it answers a '
              'different question.'),
        ],
        videoSlot: 'ttc_vid_pcos_plate',
      ),

      // ---- 6. what actually works -----------------------------------------
      PvReadSection(
        heading: _en('What helps with PCOS?'),
        paragraphs: [
          _en('Two things do most of the work, and neither is unusual.'),
          _en('The first is the insulin curve: steadier blood sugar through '
              "the day, from what's on your plate and from moving your body. "
              'Muscle takes up sugar without needing much insulin at all. '
              "That's why a walk after dinner does something real, not just "
              'something good for you.'),
          _en('If your weight is raised, losing around '
              'five per cent brings back ovulation in a fair share of women. '
              "That's a few kilograms, not a whole new you."),
          _en("The second is medicine, if and when you're trying. Since 2023 "
              'the international guideline names letrozole as the first '
              'choice to bring on ovulation in PCOS, ahead of clomiphene.'),
          _en('It was written jointly by ESHRE, ASRM and Monash, which is as '
              'close to a settled worldwide view as fertility medicine gets. '
              'Letrozole is a tablet, taken for five days early in your cycle, '
              "and it doesn't cost much."),
          _en("If letrozole doesn't work, there are more steps, not a dead "
              'end: clomiphene with metformin, then hormone injections '
              '(gonadotrophins) or ovarian drilling, and IVF third in line '
              'rather than first. Very few people need to go through every '
              'step.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('One thing to know before you read any success rate'),
          body: _en('Trials of ovulation tablets count live births over '
              'several cycles, not one. In the largest, about a quarter of '
              'women had a live birth over five letrozole cycles. Put the '
              "other way round: most single cycles don't work. That's the "
              "normal pattern of this treatment, not a sign it's failing. A "
              "cycle that doesn't work says nothing about you."),
        ),
      ),

      // ---- 7. supplements — REFERENCE, FOLDS -------------------------------
      PvReadSection(
        // ⚠️ FOLDS. This is a lookup, not a step in the argument — useful the
        // day she is standing in a chemist, dead weight the day she is trying
        // to understand her own cycle. The spine of the piece still reads with
        // this shut, which is the test `assertShape` applies.
        collapsible: true,
        summary: _en('Inositol, folic acid, and the ones that are just '
            'inositol again at four times the price.'),
        heading: _en("What about the supplements you'll be offered?"),
        paragraphs: [
          _en('Inositol has the best evidence behind it. Trials suggest it '
              'can help your body use insulin better and, in some women, '
              "bring back ovulation. The guideline doesn't go as far as "
              "recommending it, because the trials are small and don't all "
              'agree.'),
          _en("That's a fair summary: promising, not proven, and "
              'unlikely to hurt.'),
          _en('Almost everything else sold for PCOS in India is either '
              'inositol under another name at four times the price, or a '
              'multivitamin with a picture of an ovary on the box.'),
          _en("Folic acid is different, and it isn't for PCOS at all. It "
              "protects your baby's developing spine and brain (the neural "
              'tube), and it needs to be in your body before a positive test.'),
          _en("At eighty rupees a month, it's the best-proven thing anyone "
              'will sell you in this whole category.'),
        ],
        tip: PvReadTip(
          title: _en('Before you spend on a supplement'),
          body: _en("Ask what test would show it's working, and when you'd "
              'stop. If no one can answer either question, you would be '
              "paying for the feeling of doing something. That's a real need, "
              'and there are cheaper ways to meet it.'),
        ),
      ),

      // ---- 8. what it is not — REFERENCE, FOLDS ----------------------------
      PvReadSection(
        // ⚠️ FOLDS. Everything here is reassurance she has already been given
        // by the lede and by "how common this actually is" — it is worth
        // having, and it is worth having as a box she can choose to open
        // rather than three more screens of scroll on the way to the FAQ.
        collapsible: true,
        summary: _en('Not your fault, not permanent, and not a sentence of '
            'infertility. Three fears, answered plainly.'),
        heading: _en('What PCOS is not'),
        paragraphs: [
          _en("It's not something you caused. It runs in families. It shows "
              'up in slim women and larger women, in women who eat carefully '
              "and women who don't. Nothing you did brought it on."),
          _en("It's not permanent the way a physical blockage is. Nothing is "
              "blocked and nothing is missing. It's a pattern in how your "
              'hormones signal, and those patterns can change.'),
          _en("And it doesn't mean you can't have children. It makes your "
              'cycles hard to predict, so timing is harder. Timing is the part '
              'a tablet, a tracker and a doctor can really help with.'),
        ],
        mythFact: PvMythFact(
          myth: _en("PCOS means you'll need IVF."),
          fact: _en("For most women it's the other way round. PCOS is exactly "
              'what ovulation medicines were made for. The 2023 guideline puts '
              'IVF third in line, after tablets and after injections. It '
              "clearly says IVF shouldn't be offered first unless there is "
              'another reason.'),
        ),
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('My scan says polycystic ovaries, but my periods are '
            'regular. Do I have PCOS?'),
        answer: _en('Probably not. PCOS needs two of three signs, and the scan '
            "is only one of them. Regular cycles suggest you're ovulating, and "
            "that's what matters for getting pregnant. Many women look like "
            'this on a scan and have nothing else, all their lives.'),
      ),
      PvReadFaq(
        question: _en('Will I have to take metformin forever?'),
        answer: _en('Metformin is usually given for a reason and for a set '
            'time, such as insulin resistance, or alongside medicine to help '
            "you ovulate. It isn't usually for life. If you were taking it "
            "before you got pregnant, don't stop it or carry on with it on "
            "your own once you're pregnant. That's a decision for your doctor, "
            'who can see the whole picture.'),
      ),
      PvReadFaq(
        question: _en('Does PCOS get worse as you get older?'),
        answer: _en("Often it's the other way round. Cycles often get more "
            'regular through your thirties, as the number of follicles falls '
            'naturally. Some women who never had a predictable cycle in their '
            'twenties get one later. The metabolic side (blood sugar and '
            'weight) still needs looking after, but the cycle side often gets '
            'easier.'),
      ),
      PvReadFaq(
        question: _en('Should I stop eating rice and roti?'),
        answer: _en("No. If someone tells you to, the advice probably wasn't "
            'made for an Indian kitchen. What changes your blood-sugar curve '
            'is what you eat with the carbohydrate, and what you eat first: '
            "protein, dal, vegetables, curd. Cutting out the carbohydrate isn't "
            "the answer. A diet you can't keep up for a year isn't a "
            'treatment.'),
      ),
      PvReadFaq(
        question: _en('How long should I try before I see a doctor about '
            'this?'),
        answer: _en('If your cycles are irregular, the usual advice to try '
            "for a year first doesn't apply to you. That advice assumes you "
            'ovulate on a regular pattern, and PCOS changes that. Irregular '
            'cycles are a reason to talk to a doctor on their own, at any '
            'time.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth booking, but not an emergency'),
      body: _en('Book a visit if your cycles are longer than 35 days, or '
          "you've had fewer than eight or nine periods this year. Book if "
          "you've been trying for six months with cycles you can't predict. "
          'Book too if you have new hair growth, acne past your teens, or '
          'darker patches of skin on your neck or underarms. Go sooner if '
          "you're over 35. None of these is urgent today. They're all reasons "
          'to see someone in the next few weeks, not the next few years.'),
    ),

    evidence: _en('International Evidence-based Guideline for the Assessment '
        'and Management of Polycystic Ovary Syndrome (2023), developed by '
        'Monash University with ESHRE and ASRM. This is the source for '
        'letrozole as the preferred first treatment to bring on ovulation, and '
        'for the order of second and third-line treatment. Indian figures on '
        'how common PCOS is come from a national study of 9,824 women aged 18 '
        'to 40, and a systematic review and meta-analysis of Indian studies. '
        'Sources checked August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Start logging your own cycle'),
        value: _en("Three or four months of dates turn \"I think it's "
            'irregular" into something a doctor can act on.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Tests worth knowing about'),
        value: _en('What a first PCOS appointment usually checks, and what '
            'each result tells you.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a PCOS specialist'),
        value: _en('A gynaecologist who sees PCOS every day, on video, at a '
            'time you choose.'),
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
    teaser: _en('The order things are usually tried in, what each one does, '
        'and what to ask before you agree to any of it.'),
    shortAnswer: _en('Treatment usually starts with the gentlest step and stops '
        'as soon as something works. First come everyday changes to food and '
        'movement, then letrozole, a tablet taken for five days to bring on '
        'ovulation. Injections, keyhole surgery and IVF come later, and most '
        'women never need them.'),

    scaleSetter: _en('Treatment for PCOS nearly always starts with the gentlest '
        'thing that might work, and stops as soon as something does. Most '
        'women never reach the second step. Almost no one reaches the last '
        'one.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    heroVideoSlot: 'ttc_vid_pcos_treatment',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('There is an agreed international order for this, and it helps '
              'to know it before you walk into a clinic. Not so you can argue '
              'with anyone, but so nothing comes as a surprise and you know '
              'which questions are fair to ask.'),
          _en('The order below comes from the 2023 international guideline, '
              "written jointly by ESHRE, ASRM and Monash University. It's "
              'about as close to a settled worldwide view as fertility '
              'medicine gets.'),
        ],
      ),

      PvReadSection(
        heading: _en('What comes before any tablet?'),
        paragraphs: [
          _en('Before any tablet, the first step is the insulin curve: '
              "what's on your plate, and moving your body. If your weight is "
              'raised, losing around five per cent is the figure the research '
              'keeps coming back to. In a fair share of women, that alone '
              'brings cycles back.'),
          _en("Five per cent is a few kilograms. It isn't a whole new you. "
              'The number is small on purpose, because the aim is to help your '
              'body use insulin better, not to reach a dress size.'),
          _en('This step really does come first. It is also the step most '
              'often given badly: "lose weight" said across a desk in four '
              "seconds, with no plan. If that's what you get, it's fair to ask "
              'back: how much, by when, and how will we know it is working?'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('And if your weight is already normal'),
          body: _en('Plenty of women with classic PCOS are slim, and this step '
              'still applies to them. The aim was never the scale. Steadier '
              'blood sugar through the day and regular movement do the same '
              'work at any weight. If a doctor skips past this because you '
              "aren't overweight, it's worth asking about insulin resistance "
              'directly.'),
        ),
      ),

      PvReadSection(
        heading: _en('Then: a tablet to bring on ovulation'),
        paragraphs: [
          _en("If your cycles still aren't releasing an egg, the next step is "
              'ovulation induction. This is a short course of tablets early in '
              'your cycle that pushes the ovary to ripen and release one '
              'follicle.'),
          _en("Since 2023 the first choice is letrozole. It's taken for five "
              'days, usually from about day two to day six. It costs little, '
              'and a cycle is cheaper than most people expect.'),
          _en('Clomiphene was '
              'the standard for decades and is still used. The guideline moved '
              'letrozole ahead of it because it led to more live births when '
              'the two were compared in trials.'),
          _en('Whichever one is used, the cycle is usually checked with a scan '
              'to see how many follicles are growing. This checking is not '
              'extra caution. It is how the dose gets adjusted, and how a twin '
              'pregnancy is avoided.'),
        ],
        tip: PvReadTip(
          title: _en('What to ask before the first tablet'),
          body: _en('How many cycles will we try this before we change the '
              'plan? Will this cycle be checked with a scan? And what would '
              'count as it working: a period, a confirmed ovulation, or a '
              'pregnancy? Those three answers give an open-ended treatment a '
              'clear shape, and that makes it much easier to live with.'),
        ),
      ),

      PvReadSection(
        heading: _en('Where does metformin fit?'),
        paragraphs: [
          _en('Metformin is a diabetes medicine, and being given it for '
              "fertility worries almost everyone. It isn't a mistake, and it "
              "doesn't mean anyone thinks you have diabetes."),
          _en('It works on the same thing the food advice works on. It helps '
              'your cells respond better to insulin, so there is less insulin '
              'in your blood.'),
          _en('That lowers the androgens that are stalling '
              'ovulation. In the current guideline it is paired with '
              'clomiphene as a second step, not used alone as a first one.'),
          _en("It's also the one most likely to have side effects you need to "
              'plan for: feeling sick and loose stools in the first weeks. '
              'These usually ease, and are usually much better on the '
              'slow-release form taken with food.'),
          _en('If you really can\'t cope '
              'with it, say so early instead of stopping without telling '
              'anyone. The dose and the form can both change.'),
        ],
        mythFact: PvMythFact(
          myth: _en('If they put me on metformin, I must be pre-diabetic.'),
          fact: _en("Not necessarily. Here it's given for insulin resistance. "
              "That's different from diabetes, and very common in PCOS even "
              'when blood-sugar readings are completely normal. Your HbA1c may '
              'be fine and metformin can still be the right choice.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Almost nobody reaches these steps, and putting them open
        // in the middle of the page means everyone reads about ovarian surgery
        // on the day they were told about a tablet.
        collapsible: true,
        summary: _en('Injections, ovarian drilling and IVF: what they are, '
            'and why they come third, not second.'),
        heading: _en("What if tablets don't work?"),
        paragraphs: [
          _en('The next step is usually injections of gonadotrophins. These '
              'are the hormones your brain would normally send, given '
              'directly, at a low dose and watched closely. They work well, '
              'but there is a higher risk of too many follicles growing at '
              "once. That's exactly why the checks get closer together."),
          _en('Laparoscopic ovarian drilling is the other second-step option. '
              'It is keyhole surgery that makes a few tiny holes in the ovary. '
              'This lowers androgens and can bring back ovulation for a while '
              'afterwards.'),
          _en("It's offered less often now than it used to be, and "
              "it's a fair choice for someone who can't come in for frequent "
              'scans.'),
          _en('IVF comes third. The guideline clearly says it should not be '
              'offered first when PCOS is stopping ovulation, unless there is '
              'another reason. The earlier steps work often enough that '
              'starting with IVF would mean most women going through it when '
              "they didn't need to."),
        ],
      ),

      PvReadSection(
        heading: _en("What can't treatment change?"),
        paragraphs: [
          _en("None of these treats PCOS. They treat the stall. Tablets to "
              'bring on ovulation help an egg come this cycle. They don\'t '
              "change the pattern underneath, which is why cycles often become "
              'irregular again once treatment stops.'),
          _en("That can sound discouraging, but it isn't meant to. It's the "
              'reason the first step, the insulin curve, stays useful through '
              "all the others. It isn't something you finish and leave behind. "
              "And it's why no one should feel they have failed if a cycle "
              'needs help again later.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('How many cycles of tablets before trying something '
            'else?'),
        answer: _en('Often around six cycles with ovulation before the plan is '
            'looked at again. This varies with age and with what else is going '
            "on. It's a fair question to ask at the start, rather than finding "
            'out at cycle seven.'),
      ),
      PvReadFaq(
        question: _en('Will treatment give me twins?'),
        answer: _en('Twins or more are more likely than in a cycle without '
            "treatment. That's exactly why cycles are checked with a scan, and "
            'why a cycle is sometimes cancelled. Letrozole leads to twins less '
            "often than clomiphene, and that's one reason it's preferred."),
      ),
      PvReadFaq(
        question: _en("Can I take letrozole without scans? It's cheaper."),
        answer: _en('This is one for your own doctor, not something to decide '
            'from an article. But the scans are there to adjust the dose and '
            'to catch a cycle with too many follicles growing. Those two '
            'things are what make the treatment safe, not just effective.'),
      ),
      PvReadFaq(
        question: _en('I was put on the pill for my PCOS. Does that help me '
            'get pregnant?'),
        answer: _en("No, and it isn't meant to. The combined pill is used to "
            'control bleeding, calm acne and protect the lining of the womb '
            'when cycles are very long. Those are all real reasons, but none '
            'of them is about getting pregnant, and it stops pregnancy while '
            'you take it. If you now want to try, tell your doctor.'),
      ),
      PvReadFaq(
        question: _en('Does treatment have to be at a fertility clinic?'),
        answer: _en('Not for the first steps. A general gynaecologist gives '
            "ovulation tablets all the time, and that's usually where this "
            'starts in India. You tend to be referred on once tablets have '
            'been tried, or when something else needs a specialist.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("While you're on treatment"),
      body: _en('Call your clinic (your own clinic, not an emergency '
          'department) if you get a lot of bloating, gain weight fast over a '
          'few days, have severe pain in your tummy, or feel breathless during '
          'or after a stimulated cycle. These are signs of ovarian '
          "hyperstimulation. It's uncommon on tablets and more likely with "
          "injections, and it's very manageable when it's reported early. "
          'Anything about your own dose, your own scan or your own next step '
          'belongs with the doctor who prescribed it.'),
    ),

    evidence: _en('The treatment order (lifestyle first, letrozole as the '
        'preferred first medicine, clomiphene with metformin and '
        'gonadotrophins or ovarian surgery as the second step, IVF as the '
        'third) follows the International Evidence-based Guideline for the '
        'Assessment and Management of Polycystic Ovary Syndrome (2023), '
        'developed by Monash University with ESHRE and ASRM. Sources checked '
        'August 2026. Nothing here is advice for your own case. That comes '
        'from your doctor.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Tests worth knowing about'),
        value: _en('What a first PCOS appointment usually checks, and what '
            'each result tells you.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep a record for the appointment'),
        value: _en('Three months of dates is the most useful thing you can '
            'bring with you.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a PCOS specialist'),
        value: _en('Someone who can look at your own reports, on video, at a '
            'time you choose.'),
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
    teaser: _en('What changes your blood-sugar curve in an Indian kitchen, '
        'and why no food has to go.'),
    shortAnswer: _en("There's no special PCOS diet, and you don't have to give "
        'up rice or roti. What helps is a gentler rise in blood sugar: protein '
        'and vegetables first, whole grains where you can, and a short walk '
        'after eating. The best way of eating is the one you can keep up.'),

    scaleSetter: _en('There is no PCOS diet. The 2023 international guideline '
        'looked for one and found that no single way of eating beats the '
        "others. What works is the one you can keep up. That's more useful "
        "than a meal plan, and it's the opposite of what you'll be sold."),

    author: _en('Akanksha Srivastava'),
    authorRole: _en('Maternal and child nutritionist'),

    heroVideoSlot: 'ttc_vid_pcos_plate',

    sections: [
      PvReadSection(
        paragraphs: [
          _en("What you're working on isn't calories, and it isn't "
              "carbohydrate. It's the shape of the curve: how fast your blood "
              'sugar rises after you eat, and so how much insulin your body '
              'has to send to deal with it.'),
          _en('Flatten that curve and the insulin in your blood falls. Lower '
              'insulin means the ovary makes fewer androgens, and androgens '
              "are what stall the follicles. That's the whole idea, and every "
              'useful tip below is a way of flattening the same curve.'),
        ],
      ),

      PvReadSection(
        heading: _en('Does the order you eat in matter?'),
        paragraphs: [
          _en("This comes first because it's free. It changes no recipe, "
              'takes nothing away, and has real trials behind it.'),
          _en('The same plate gives a smaller rise in blood sugar when you eat '
              'the protein and vegetables before the rice or roti. Not a '
              'different plate. The same one, in a different order.'),
          _en('In practice, that means starting with the sabzi and dal, or '
              'the curd, or the salad, and coming to the carbohydrate a few '
              "minutes later. No one at the table has to know you're doing "
              'it.'),
        ],
        tip: PvReadTip(
          title: _en('If you change one thing this week'),
          body: _en('Make it this, and make it breakfast. An Indian breakfast '
              'is often where the curve is steepest. Poha, upma, bread and '
              'idli are mostly carbohydrate and often eaten fast. Adding a '
              'boiled egg, a bowl of curd, a handful of peanuts or a besan '
              'chilla on the side changes your whole morning.'),
        ),
      ),

      PvReadSection(
        heading: _en('What does the research support?'),
        paragraphs: [
          _en('Low glycaemic index (low-GI) eating, which means foods that '
              'raise blood sugar slowly, has the most direct support in PCOS. '
              'A trial compared it with standard diet advice. Periods became '
              'regular much more often on the low-GI approach.'),
          _en('Regular periods '
              'are a direct sign that ovulation has come back, so this means '
              'far more than a number on the scale.'),
          _en('Alongside it: if your weight is raised, losing around five per '
              'cent brings cycles back in a fair share of women. Both work in '
              "the same way, which is why doing one tends to help the other."),
          _en("What the guideline doesn't do is name a winner. No single named "
              'diet (keto, paleo, low-carb, intermittent fasting) has been '
              'shown to beat the others for PCOS.'),
          _en('Ways of eating that lower '
              'the need for insulin do better than standard advice. Beyond '
              'that, what matters most is whether you can keep it up.'),
        ],
        mythFact: PvMythFact(
          myth: _en('You have to give up rice and roti.'),
          fact: _en("You don't. If someone tells you to, the advice probably "
              "wasn't made for an Indian kitchen. What changes the curve is "
              'what you eat with the carbohydrate, what you eat first, and how '
              "much. Not cutting it out. A diet that's at odds with how your "
              "family eats won't last a year, and a year is the time that "
              'matters.'),
        ),
      ),

      PvReadSection(
        heading: _en('What helps, in an Indian kitchen?'),
        bullets: [
          _en('Protein at every meal, and especially at breakfast: dal, curd, '
              'paneer, egg, sprouts, chana. This is the most common gap.'),
          _en("Whole grains where they're already part of your meals: "
              'hand-pounded or brown rice, bajra, jowar, ragi. No need to swap '
              'everything for food you don\'t know.'),
          _en('Cooling and reheating rice raises its resistant starch, which '
              'means a smaller rise in blood sugar. Yesterday’s rice really is '
              'better for you than today’s.'),
          _en('Fat and something sour with your carbohydrate slow it down: '
              'ghee on the roti, a squeeze of lime, curd with the meal.'),
          _en('Moving after you eat, even for ten minutes. Muscle takes up '
              "sugar with very little insulin. That's why a walk after dinner "
              'does something real, not just something good for you.'),
        ],
      ),

      // Gap plan 2026-09-26: a sample day, so the "why" above has a "how".
      PvReadSection(
        heading: _en('What does a day of eating like this look like?'),
        paragraphs: [
          _en("Here's one example of a vegetarian day. It's a picture to "
              'borrow from, not a plan to follow exactly. Swap in whatever your '
              'family already cooks, and eat the amounts that suit your '
              'hunger.'),
        ],
        bullets: [
          _en('Morning tea: with little or no sugar, and a few nuts or some '
              "roasted chana alongside, so it isn't on an empty stomach."),
          _en('Breakfast: two moong dal or besan chillas with mint chutney and '
              'a bowl of curd. Or vegetable poha with peanuts and a small bowl '
              'of sprouts.'),
          _en('Mid-morning: a fruit, such as a guava, an apple or an orange.'),
          _en('Lunch: salad, dal and a vegetable sabzi first, then one or two '
              'rotis of wheat, bajra or jowar, or a small bowl of rice, with '
              'curd or chaas.'),
          _en('Evening: roasted makhana or chana, or a bowl of sprouts chaat, '
              'with your tea.'),
          _en('Dinner: paneer bhurji, rajma or chole with a vegetable, and one '
              'roti or a little rice. Then a ten-minute walk.'),
        ],
        tip: PvReadTip(
          title: _en('If you eat eggs, fish or chicken'),
          body: _en('They fit in anywhere this day has paneer, dal or chana. '
              'An egg at breakfast is one of the easiest ways to add protein '
              'to the meal that most needs it.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. A chemist-aisle lookup, not part of the argument.
        collapsible: true,
        summary: _en('Inositol, vitamin D, berberine and the rest: what has '
            'proof, and what is only priced as if it does.'),
        heading: _en('What about supplements?'),
        paragraphs: [
          _en('Inositol has the best evidence. Trials suggest it helps your '
              'body use insulin better and, in some women, brings back '
              "ovulation. The 2023 guideline doesn't go as far as recommending "
              "it, because the trials are small and don't all agree."),
          _en("That's a fair summary: promising, not proven, and unlikely "
              'to hurt.'),
          _en("Vitamin D is worth testing rather than guessing. If it's low, "
              "and in India it very often is, it's worth correcting. That's "
              "for your general health rather than PCOS, and it's still worth "
              'doing.'),
          _en('Almost everything else sold for PCOS here is inositol under '
              'another name at several times the price, or a multivitamin with '
              'an ovary on the box.'),
          _en('Berberine is in a lot of these. The proof '
              'is thin and it clashes with other medicines, so it is not one '
              'to start on your own.'),
        ],
      ),

      PvReadSection(
        heading: _en("What this isn't asking of you"),
        paragraphs: [
          _en('Not a separate meal cooked just for you. Not weighing food. Not '
              'explaining yourself at the family table. Almost everything '
              "above is a small change to a meal that's already being made."),
          _en("And not getting every meal right. The curve is a daily and "
              "weekly average, not a test you pass or fail at each meal. A "
              "mithai at a wedding doesn't undo a month."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('If eating has started to feel like a job'),
          body: _en("Tell someone. Cutting back hard on food and eating "
              'problems are both more common in PCOS than in other women, '
              'partly because women with PCOS are told so often to lose '
              "weight. A plan that makes you anxious about food isn't working, "
              'whatever it does to the numbers.'),
        ),
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Is keto good for PCOS?'),
        answer: _en('It lowers insulin, and short trials show better blood '
            "sugar. What it doesn't have is proof that it beats other ways of "
            "eating over the time that matters. It's also the hardest to keep "
            'up in an Indian home. If you can stick with it and enjoy it, '
            "it's a fair choice. It isn't a must, and it isn't a cure."),
      ),
      PvReadFaq(
        question: _en('Should I do intermittent fasting?'),
        answer: _en('The evidence in PCOS is limited and mixed. For some women '
            'a shorter eating window helps. For others, skipping breakfast '
            "makes the rest of the day worse. Try it only if it feels easy, "
            "and it's best avoided if you've ever had an eating disorder."),
      ),
      PvReadFaq(
        question: _en('How long before I see a change?'),
        answer: _en('Your body starts using insulin better within weeks, but '
            'cycles change slowly. Give it three to six months before you '
            'judge whether the pattern has changed. This is the main reason '
            'people give up too early.'),
      ),
      PvReadFaq(
        question: _en("I'm not overweight. Does any of this apply to me?"),
        answer: _en('Yes. Insulin resistance happens at every body size, and '
            'PCOS in slim women is common. Nothing above is about losing '
            'weight. The order you eat in, the protein and the walk after '
            'dinner all do the same work, whatever the scale says.'),
      ),
      PvReadFaq(
        question: _en('Do I need to see a dietitian?'),
        answer: _en('Not to start. You can do everything above in your own '
            "kitchen. It's worth seeing one if you've tried for a few months "
            "without change, if you have another condition to eat around, or "
            "if you'd just like a plan made for the way your family eats."),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth an appointment'),
      body: _en('Book a visit if you have darker, velvety patches on your neck '
          'or underarms, a lot of thirst, weight change you can\'t explain, or '
          'type 2 diabetes in your family. These are all reasons to have '
          'your blood sugar and insulin checked properly, not just managed by '
          'diet. And talk to someone sooner if food has become a worry rather '
          "than something you're using to help. Nothing on this page replaces "
          'the plan your own doctor gives you.'),
    ),

    evidence: _en('Low glycaemic index eating and regular periods: from a '
        'systematic review and meta-analysis of low-GI diets in PCOS, and from '
        'a randomised trial of low-GI eating at equal calories in women with '
        'PCOS (both listed on PubMed Central). The five per cent weight-loss '
        'figure, and the finding that no single way of eating is best, come '
        'from the International Evidence-based Guideline for the Assessment '
        'and Management of Polycystic Ovary Syndrome (2023). Sources checked '
        'August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep a list of your supplements'),
        value: _en("What you're taking and when you started. Doctors always "
            "ask, and it's hard to remember."),
        surfaceId: 'ttc_supplements',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Eating, day to day'),
        value: _en('The meal planner, built around what an Indian kitchen '
            'already cooks.'),
        surfaceId: 'ttc_nutrition',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a fertility nutritionist'),
        value: _en('A plan made for the way your family eats, not a '
            'printout.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_pcos_treatment', 'ttc_read_meal_plan_week'],
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
    teaser: _en('What "irregular" means, why it happens, and why it is a '
        'symptom rather than a diagnosis.'),
    shortAnswer: _en('An irregular cycle is one whose length keeps changing '
        'from month to month, not just one that is long. PCOS is the most '
        'common cause, but thyroid problems, raised prolactin, weight change, '
        'stress and hard training can all do it too. A doctor can find the '
        'cause with a few blood tests, and most causes can be treated.'),
    scaleSetter: _en('An irregular cycle is one of the most common reasons '
        'people book a gynaecology visit, and it has many possible causes. '
        'PCOS is one of them. So are thyroid problems, stress, a recent birth, '
        'coming off birth control, and just being in the first or last few '
        'years of having periods.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Your cycle starts on day one of your period and ends the day '
              'before your next period starts. Anything from 21 to 35 days is '
              "normal. A cycle that is always 33 days isn't irregular. It's "
              'just long.'),
          _en("What makes a cycle irregular is that it doesn't repeat. If one "
              'month is 26 days, the next 41 and the one after 33, that change '
              'from month to month is what to describe, not each number on '
              'its own.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does a cycle become hard to predict?'),
        paragraphs: [
          _en('Most of a cycle goes on one job: growing follicles until one is '
              'ready to release an egg. Ovulation is the turning point.'),
          _en('Once it happens, the second half of the cycle is very steady, '
              "usually twelve to fourteen days, because it's run by something "
              'in the ovary that only lasts a set time.'),
          _en("So when a cycle is hard to predict, it's nearly always the "
              'first half that changes. The follicles take longer to ripen, or '
              'several start and none finishes. Then the period comes late '
              'because the ovulation before it came late.'),
          _en('That\'s why "irregular" and "hard to time" are the same problem '
              "said twice. Your fertile window isn't moving around at random. "
              "It's coming on a schedule the calendar can't predict."),
        ],
      ),
      PvReadSection(
        heading: _en('What can cause irregular periods?'),
        paragraphs: [
          _en('PCOS is the most common cause of irregular cycles in people of '
              "childbearing age, and it's worth knowing that. But it isn't the "
              'only one, and assuming it is can cost you in two ways.'),
          _en('It can send you down a PCOS path when a thyroid test would have given '
              'the answer in a week. And it can make someone who does have '
              'PCOS think a normal thyroid rules it out.'),
          _en('A thyroid that works too slowly or too fast changes cycles, and '
              'one blood test checks it. Raised prolactin does the same, and '
              'that is a blood test too. A big weight change either way '
              'affects ovulation. So can hard training, illness, poor sleep '
              'and long-lasting stress.'),
          _en('Coming off hormonal birth control often brings a few irregular '
              'months before a pattern comes back. Breastfeeding holds back '
              'cycles, as it is meant to. The years after periods start and '
              'the years before menopause are both naturally irregular.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("One irregular cycle isn't a pattern"),
          body: _en('Almost everyone has an off month. Illness, a hard stretch '
              'at work or a long trip can push ovulation later, and your period '
              'follows it. What is worth looking into is a run of them, or a '
              'cycle length that keeps changing by more than a week or two.'),
        ),
      ),
      PvReadSection(
        heading: _en("What does irregular mean when you're trying?"),
        paragraphs: [
          _en('The hard part is timing, not whether it can happen. An '
              'irregular cycle usually still ovulates, just not on a date '
              "anyone can predict from the calendar. So ovulation kits, "
              'cervical mucus (the discharge that changes near ovulation) and '
              'basal temperature become more useful than counting days.'),
          _en("Some cycles don't ovulate at all. These are called anovulatory "
              'cycles. You can still bleed in them, which is why they are easy '
              'to miss.'),
          _en('A cycle that often goes past about forty-five days is '
              "more likely to be one of these, and it's the pattern most worth "
              'taking to a doctor.'),
          _en("None of that means a long wait. Irregular ovulation is one of "
              'the most treatable reasons for trouble getting pregnant. The '
              'usual first step is a tablet taken for five days early in the '
              "cycle. That's for a doctor to decide with you, not something to "
              'arrange yourself.'),
        ],
      ),
      PvReadSection(
        heading: _en("How do you find out what's causing it?"),
        paragraphs: [
          _en('Three months of logged period start dates is worth more at an '
              'appointment than any description. It turns "they\'re all over '
              'the place" into dates a doctor can read in ten seconds. It is '
              'the most useful thing you can bring.'),
          _en("Note the longest gap you've had, whether periods are heavier "
              'or lighter than they used to be, and anything else that changed '
              'when the pattern did: a new medicine, a big weight change, a '
              'stressful year. Those details turn a general worry into a clear '
              'question.'),
        ],
      ),
      // Gap plan 2026-09-26: what can help a cycle settle, cause first.
      PvReadSection(
        heading: _en('Can you make your cycle regular again?'),
        paragraphs: [
          _en('Often, yes, but it depends on the cause, so finding the cause '
              'comes first. If a thyroid problem or raised prolactin is behind '
              'it, treating that often brings cycles back by themselves.'),
          _en('Regular sleep and meals help whatever the cause. With PCOS, '
              'steadier blood sugar and regular movement help your body use '
              'insulin better, and that can help ovulation come back. With '
              'very hard training or eating too little, eating more and easing '
              'off usually helps.'),
          _en('Be wary of anything sold to "regulate" periods, like teas, '
              'herbal mixes or tablets bought without a prescription. A tablet '
              "can bring on a bleed, but a bleed made by a tablet doesn't mean "
              "you ovulated. That's why a doctor looks for the cause before "
              'treating the pattern.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth booking, not waiting'),
      body: _en("Book a check if you've gone three months or more without a "
          "period and you know you're not pregnant. Book if your cycles are "
          'always shorter than 21 days or longer than 35, if you bleed between '
          'periods or after sex, or if your periods have got much heavier. Any '
          'of these is a reason to talk to a doctor, and none of them is an '
          'emergency.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('My cycles are always 34 days. Is that irregular?'),
        answer: _en("No. That's a long but regular cycle, and a regular cycle "
            'is one you can predict, whatever its length. You just ovulate '
            'later than you would in a 28-day cycle.'),
      ),
      PvReadFaq(
        question: _en('Does an irregular cycle mean I have PCOS?'),
        answer: _en("No. It's one of several possible causes, and the most "
            'common one. But a thyroid test, a prolactin test and a talk '
            'about the last year usually come first. Only a doctor can work '
            'out which it is.'),
      ),
      PvReadFaq(
        question: _en('Can I still get pregnant with irregular cycles?'),
        answer: _en('Yes, and many people do without any help at all. The hard '
            'part is usually timing. And where ovulation really is not '
            "happening, it's one of the more treatable causes there is."),
      ),
    ],
    evidence: _en('NICE guideline NG156 (heavy menstrual bleeding) and CG156 '
        '(fertility assessment and treatment); the 2023 International '
        'Evidence-Based Guideline for the Assessment and Management of PCOS; '
        'RCOG patient information on irregular periods. Sources checked '
        'August 2026.'),
    readNext: ['ttc_read_pcos_cycle'],
  ),


  PvRead(
    id: 'ttc_read_pcos_diagnosed',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('If a doctor says PCOS'),
    teaser: _en("What the diagnosis is based on, what it does and doesn't "
        'mean, and what to ask before you leave the room.'),
    shortAnswer: _en('PCOS is diagnosed when you have two of three signs: '
        'irregular ovulation, signs of raised male-type hormones, and many '
        'small follicles on a scan, once thyroid and prolactin problems are '
        "ruled out. It's a common hormone pattern that is managed, not cured. "
        'Most women with PCOS who want children do have them.'),
    scaleSetter: _en('Being told you have PCOS can hit hard. Partly because the '
        'name sounds like a disease of the ovaries, and partly because the '
        'internet talks about it in ways no doctor would. It is a hormone '
        "pattern, it's common, and it's managed rather than cured."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('PCOS is diagnosed on a set of signs, not a single test. A '
              'doctor looks at three things: whether ovulation is irregular or '
              'missing, whether there are signs of raised androgens (male-type '
              'hormones), and what an ultrasound shows about the ovaries.'),
          _en('Two of the three are enough, once other causes have been ruled '
              'out. That last part matters a lot. Thyroid problems and raised '
              'prolactin can look very similar, so they are ruled out first. '
              "That's why a diagnosis usually includes blood tests that aren't "
              'about PCOS at all.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does polycystic mean you have cysts?'),
        paragraphs: [
          _en('"Polycystic" suggests cysts, and it is the scariest word in the '
              'diagnosis. What the ultrasound shows is more small follicles '
              'than usual.'),
          _en('These are the fluid sacs every ovary makes each '
              'month, each one holding an egg that is not yet ripe. They '
              "aren't cysts in the sense of something gone wrong that needs "
              'removing.'),
          _en("This is also why the scan alone doesn't diagnose anything. Lots "
              'of people have ovaries that look like this and have no other '
              'sign of PCOS. And some people with clear PCOS have ovaries that '
              'look ordinary.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("It's common, and many people have a mild kind"),
          body: _en('PCOS affects around one in ten people of childbearing age '
              'around the world. It ranges widely. Some people have every sign '
              'strongly. Many have a mild kind that only shows up as cycles '
              'that are a little hard to predict.'),
        ),
      ),
      PvReadSection(
        heading: _en('What does it mean for having children?'),
        paragraphs: [
          _en('The honest answer is that PCOS often makes getting pregnant '
              'take longer, and that most people with PCOS who want children '
              'do have them. Both are true, and the second one gets left out '
              'far too often.'),
          _en('The problem is ovulation. If eggs are released rarely or at '
              'unpredictable times, there are fewer chances in a year and they '
              "are harder to time. It isn't a problem with the eggs "
              'themselves. In PCOS the egg supply is usually good, not poor.'),
          _en("That's why the usual first treatment is a short course of "
              'tablets to help you ovulate, and why it works for a large share '
              "of the people who try it. Your own situation is one to talk "
              'through with the doctor who knows your history.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you ask before you leave?'),
        paragraphs: [
          _en('Ask which of the signs you have, and whether other causes were '
              "ruled out. It's a fair question, and it tells you what the "
              'diagnosis is based on.'),
          _en('Ask whether your insulin or blood sugar was checked, and whether '
              'it should be. Insulin resistance often comes with PCOS, and it '
              'changes which treatment makes sense.'),
          _en("Ask what to do now if you're trying to get pregnant, and what to "
              "do if you're not. The answers are different, and being given "
              'the wrong one is a common reason people leave confused.'),
          _en('Ask when to come back. A diagnosis with no next appointment is '
              'the part that most often turns into a year of nothing '
              'happening.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does PCOS affect more than fertility?'),
        paragraphs: [
          _en('PCOS affects how your body handles sugar as much as it affects '
              'fertility. A good doctor will mention this, even in a visit about '
              'trying for a baby.'),
          _en('Over the years it raises the risk of insulin '
              "resistance and type 2 diabetes. That's worth knowing, because "
              "it's one of the risks you can do the most about."),
          _en('Said plainly and calmly: this is a reason for a blood test now '
              'and then, and for the everyday habits that help anyway. Moving '
              'regularly, sleeping well, eating in a way you can keep up. It '
              "isn't a reason to change your whole life this week."),
          _en('It also matters in pregnancy. Diabetes in pregnancy '
              '(gestational diabetes) is more common with PCOS. That usually '
              'just means an earlier sugar test. Mention your diagnosis at '
              'your first pregnancy check-up, and it will be handled as a '
              'matter of routine.'),
        ],
      ),
      PvReadSection(
        heading: _en('What not to do this week'),
        paragraphs: [
          _en("Don't start a pile of supplements you found on a forum. Some "
              'are harmless but costly, a few clash with real medicines, and '
              "none of them replaces the talk you've just had."),
          _en("Don't start a harsh diet. There is no PCOS diet in the way the "
              'internet means it. Nothing is banned, and the changes that help '
              'are ordinary and slow.'),
          _en("Don't take the diagnosis as a verdict on whether you can have "
              "children. It tells you how your cycle behaves. It's the start of "
              'a plan, not the end of one.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go back sooner if these appear'),
      body: _en("Contact a doctor if you've gone more than three or four "
          "months without a period, if you're bleeding very heavily or "
          'between periods, or if hair growth or hair loss is changing fast. '
          "Go back too if you've been told you have PCOS but no one checked "
          'your thyroid or prolactin. Fast changes in particular need a '
          'conversation, not a wait.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Does PCOS go away?'),
        answer: _en("It's managed rather than cured, and its signs often ease "
            'over time. Cycles often get more regular through your thirties '
            'and forties. Managing it well changes how much it affects your '
            'daily life.'),
      ),
      PvReadFaq(
        question: _en('I was diagnosed on a scan alone. Is that right?'),
        answer: _en("A scan on its own isn't enough. Two of the three signs "
            'are needed. If a scan was the only thing done, it is very fair to '
            'go back and ask what else was looked at.'),
      ),
      PvReadFaq(
        question: _en('Will I need IVF?'),
        answer: _en("Most people with PCOS don't. Tablets to help you ovulate "
            'are the usual first step, and they work for many. IVF is further '
            'along the same road, not the starting point.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of Polycystic Ovary Syndrome (Monash '
        'University, endorsed by ESHRE and ASRM); Rotterdam consensus '
        'criteria; NICE CG156. Sources checked August 2026.'),
    readNext: ['ttc_read_pcos_treatment'],
  ),



  PvRead(
    id: 'ttc_read_pcos_ovulation',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('PCOS and ovulation'),
    teaser: _en('Why the egg is usually fine and the release is the problem, '
        'and what that means while you try.'),
    shortAnswer: _en('In PCOS the eggs are usually fine. The problem is that '
        "one often isn't released on time, or at all, so cycles get long and "
        "hard to time. That's why the first treatment is usually a short "
        'course of tablets to help one egg be released.'),
    scaleSetter: _en('Almost everything hard about getting pregnant with PCOS '
        'comes down to one thing. Once you understand it, the rest of the '
        'advice makes sense, including why the first treatment is a tablet '
        'and nothing bigger.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Every month your ovaries start growing a group of follicles. '
              'Usually one moves ahead, takes the lead, and releases its egg. '
              'The rest are taken back up by the body. Picking that one is the '
              'whole event, and it depends on hormones rising and falling at '
              'fairly exact times.'),
          _en('In PCOS that picking often stalls. Several follicles start, '
              'none clearly takes the lead, and none is released. They stay as '
              'small follicles, which is what an ultrasound sees when it '
              'reports polycystic ovaries. The cycle stretches on, waiting for '
              "something that hasn't happened."),
        ],
      ),
      PvReadSection(
        heading: _en('Are your eggs affected?'),
        paragraphs: [
          _en('This is the part most worth taking away. PCOS is a problem of '
              'release, not of supply. In PCOS the egg reserve is usually good, '
              'and often higher than average for your age.'),
          _en('That is why AMH '
              'results in PCOS often come back high. People read them as good '
              "or bad news, when they're really just a count."),
          _en("So treatment isn't about fixing the eggs. It's about getting "
              'one released, reliably, on a schedule you can work with.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("Irregular doesn't mean never"),
          body: _en('Many people with PCOS do ovulate, just not every cycle and '
              'not on a date you can predict. A long cycle is often one where '
              'ovulation came late, not one where it never came. Getting '
              'pregnant on cycle day thirty-something is completely normal.'),
        ),
      ),
      PvReadSection(
        heading: _en('Can you bleed without ovulating?'),
        paragraphs: [
          _en('An anovulatory cycle is one where no egg was released. It can '
              'still end in bleeding, which is why it is easy to miss. The '
              'lining of the womb builds up and in the end breaks down, '
              'without the usual hormone steps behind it.'),
          _en('These bleeds are often lighter or heavier than usual, and come '
              'at irregular times. A cycle that goes well past forty-five days '
              'is more likely to be one. A run of them is the pattern most '
              'worth showing a doctor.'),
          _en('Ovulation kits help here, but read them with care. In PCOS the '
              'hormone they test for can stay high for long stretches without '
              'an egg being released. So a positive result is less reliable '
              'than it is for other people.'),
          _en('A rise in basal body temperature '
              '(your resting temperature) that holds for several days is '
              'better proof, because it only happens after ovulation.'),
        ],
      ),
      PvReadSection(
        heading: _en('How do you time sex with PCOS?'),
        paragraphs: [
          _en('Counting fourteen days back from your next period only works if '
              "you know when that period is coming. With cycles you can't "
              "predict, the calendar can't lead, so your body has to."),
          _en('Cervical mucus (the discharge that changes near ovulation) is '
              'the most useful free sign there is. In the days before '
              'ovulation it gets clearer, wetter and stretchy, and that change '
              "means your fertile window is opening. It's worth learning, "
              'because it costs nothing and works whatever your cycle length.'),
          _en('The other way is to stop timing altogether. Sex every two or '
              'three days through the cycle covers ovulation whenever it '
              'comes, without anyone having to predict it. If you find the '
              'timing exhausting, this is a real plan, not a second best.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does every two or three days work?'),
        paragraphs: [
          _en('It works because the window is longer than most people think. '
              'Sperm can survive inside the body for up to about five days in '
              'good conditions, so sex a few days before the egg is released '
              'still counts.'),
          _en("It's the egg that doesn't last long: somewhere "
              'between twelve and twenty-four hours after release.'),
          _en("That's why every two or three days works with no prediction at "
              'all. It keeps sperm there across the whole stretch when an egg '
              'might come. With a cycle you can\'t predict, that often works '
              "better than a well-timed guess, and it's much kinder to live "
              'with.'),
        ],
      ),
      PvReadSection(
        heading: _en('What help will you be offered?'),
        paragraphs: [
          _en('The usual first step is a short course of tablets taken early '
              'in the cycle, to help one follicle take the lead. You take it '
              'for about five days, with scans to check in the first cycles.'),
          _en('It brings on ovulation in a large share of the people who take '
              'it. Metformin is sometimes added when insulin resistance is part '
              "of the picture. It's a diabetes medicine used here for its effect "
              'on insulin, and in PCOS that can help ovulation come back.'),
          _en('Both are prescription decisions. They depend on your history, '
              'your other results and what a doctor finds. Nothing here '
              "replaces that, and you shouldn't start either one because of "
              'an article.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth asking about now'),
      body: _en('See a doctor if your cycles often go past forty-five days, if '
          "you've gone three months or more without a period, or if you've "
          'been trying for a year without getting pregnant. Make that six '
          "months if you're over 35. Irregular ovulation is one of the most "
          'treatable reasons for trouble getting pregnant, so this is a talk '
          'worth having early rather than late.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('My ovulation kit is positive nearly every day. Why?'),
        answer: _en('In PCOS the hormone these kits test for can stay high for '
            'long stretches without an egg being released. So repeated '
            "positives are common and don't tell you much. Cervical mucus and "
            'basal temperature are more useful, and a doctor can confirm '
            'ovulation with a blood test.'),
      ),
      PvReadFaq(
        question: _en('Does a period mean I ovulated?'),
        answer: _en("Not always. You can bleed without an egg being released. "
            "That's why a doctor may suggest a blood test about a week before "
            'your period is due. It is the easy way to check.'),
      ),
      PvReadFaq(
        question: _en('My AMH is high. Is that good?'),
        answer: _en("On its own, it's neither good nor bad. A high AMH in PCOS "
            'reflects the larger number of small follicles, and it is '
            "expected. It's a count. It doesn't measure egg quality or how "
            'easily you will get pregnant.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS; NICE CG156 (fertility problems); '
        'Cochrane reviews of ovulation induction medicines in PCOS. Sources '
        'checked August 2026.'),
    readNext: ['ttc_read_pcos_treatment', 'ttc_read_follicle_scans'],
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
    title: _en('Getting pregnant with PCOS: what to expect'),
    teaser: _en('What research says about how long it takes, told honestly, '
        'without false cheer or doom.'),
    shortAnswer: _en('PCOS often makes getting pregnant take longer, mostly '
        'because you ovulate less often. But most women with PCOS who want '
        'children do have them, on their own or with simple treatment. If your '
        'cycles are irregular, see a doctor after three or four months of '
        'trying, not twelve.'),
    scaleSetter: _en('Two things are true at once, and most articles only tell '
        'you one of them. PCOS often makes getting pregnant take longer. And '
        'most people with PCOS who want children do have them. The honest '
        'view keeps both in mind.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('PCOS makes the wait longer for a simple reason: it comes down '
              'to counting. To get pregnant, an egg needs to be released with '
              'sperm there at the right time.'),
          _en('With a 28-day cycle, that '
              'happens about thirteen times a year. With cycles of sixty days, '
              "it's six times, and they're harder to find."),
          _en('Fewer chances, further apart, is most of the difficulty. It '
              "isn't that each chance is worth less."),
        ],
      ),
      PvReadSection(
        heading: _en('What do the numbers say?'),
        paragraphs: [
          _en('In studies of people with PCOS who set out to have children, '
              'most do. Most estimates land around three quarters to four in '
              'five, counting both those who conceive on their own and those '
              'who have treatment.'),
          _en('Studies that follow people for longer tend '
              'to find higher figures than studies that stop at two years. '
              'That says something about patience as much as biology.'),
          _en('Tablets to bring on ovulation are the usual first treatment, '
              'and they work for a clear majority of the people who take them. '
              'Not everyone who ovulates gets pregnant that cycle. That is '
              "true for everyone, and isn't about PCOS."),
          _en('These are figures about groups of people, not about you. No one '
              'can tell one person how long it will take. Any app or article '
              'that gives you a personal number is making it up.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Why we'll never show you a personal percentage"),
          body: _en('A number about you would be made up. It would also turn '
              'into a target, something to check every month and fail. '
              'Population figures are here because they ease the pressure. A '
              'personal one would add to it.'),
        ),
      ),
      PvReadSection(
        heading: _en('What makes a real difference?'),
        paragraphs: [
          _en("Getting ovulation to happen matters most, and that's why "
              'treatment starts there. A cycle where you ovulate is a cycle '
              'that counts.'),
          _en("Age matters here as it does for everyone. It's the reason not "
              "to spend three years waiting to see. It's also why, once you're "
              'past 35, the advice is to get help after six months, not '
              'twelve.'),
          _en('Where insulin resistance is part of the picture, treating it '
              'often helps cycles come back. That means a talk with your '
              'doctor, with small, steady changes to daily habits alongside. '
              'Not a diet, not a target, and not something to fight.'),
          _en("Your partner's side is half the picture. A semen analysis is "
              'cheap and quick, but it is often skipped once a PCOS diagnosis '
              'has been made. That means a second cause can go unnoticed for a '
              'year.'),
        ],
      ),
      PvReadSection(
        heading: _en('When should you stop waiting and ask?'),
        paragraphs: [
          _en('The general advice is to try for a year before getting help, '
              "or six months if you're over 35. With PCOS it's worth starting "
              "that clock earlier. A cycle where you don't ovulate isn't really "
              '"trying" in the way the advice assumes.'),
          _en('If your cycles are long or missing, there is no point waiting a '
              'full year to prove it. Talking to a doctor at three or four '
              'months is reasonable, and the first steps are simple ones.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why count cycles, not months?'),
        paragraphs: [
          _en('It also helps to count cycles, not months. Twelve months of '
              'trying with a 28-day cycle is thirteen tries. Twelve months with '
              'a 70-day cycle is five.'),
          _en('So "trying for a year" in the second '
              'case gives about the same number of chances as five months of '
              'trying in the first. Say that to yourself, and say it to a '
              'doctor who is working out how urgent this is.'),
          _en('That works both ways, and the second way is a reason to go '
              'early, not a reason to relax. Fewer chances a year means the '
              'calendar moves faster than the tries do. And age keeps counting '
              'in months, however many cycles fit inside them.'),
        ],
      ),
      PvReadSection(
        heading: _en("The part that's hard to talk about"),
        paragraphs: [
          _en('Trying for longer than you expected is hard in ways that have '
              'nothing to do with numbers. Timed sex stops feeling close. Every '
              'pregnancy announcement feels different. Being told to relax is '
              'both useless and maddening.'),
          _en("None of that means your attitude is wrong, and stress isn't why "
              "this is taking time. If it's wearing you down, tell your doctor "
              "that too. It's a real part of the appointment, not a "
              'distraction from it.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't wait out the full year"),
      body: _en('If your cycles are irregular or missing, book a visit after '
          'three or four months of trying, not twelve. Go sooner if you have '
          "gone three months without a period, or if you're over 35. "
          'Ovulation problems are among the most treatable reasons for '
          'trouble getting pregnant, and the first steps are the simplest '
          'ones.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Will I need IVF?'),
        answer: _en("Most people with PCOS don't. Tablets to bring on "
            'ovulation are the usual first step, and they help a large share '
            'of people. IVF is further along the same road for those they '
            "don't help."),
      ),
      PvReadFaq(
        question: _en('Is my egg quality worse because of PCOS?'),
        answer: _en('PCOS is usually a problem of releasing eggs, not of the '
            'eggs themselves, and egg reserve is often higher than average. '
            'Egg quality is affected by age, the same as for anyone.'),
      ),
      PvReadFaq(
        question: _en('Everyone tells me to relax. Does stress cause this?'),
        answer: _en('No. Very high stress that goes on for a long time can '
            'affect cycles, but PCOS is a hormone and metabolism condition. '
            "Worrying doesn't cause it. You haven't done this to yourself."),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS; NICE CG156; Cochrane reviews of '
        'letrozole and clomifene for ovulation induction; long-term follow-up '
        'studies of fertility outcomes in PCOS. Sources checked August 2026.'),
    readNext: ['ttc_read_pcos_ovulation'],
  ),



  PvRead(
    id: 'ttc_read_pcos_insulin',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('Eating for steadier blood sugar, with nothing banned'),
    teaser: _en('Insulin is the part of PCOS most worth understanding, and '
        'none of it means giving up rice.'),
    shortAnswer: _en("You don't have to cut out any food. What helps with PCOS "
        'is a gentler rise in blood sugar: protein at every meal, '
        'carbohydrate eaten with other food rather than alone, and a short '
        'walk after eating. Good sleep and regular movement help your body use '
        'insulin better too.'),
    scaleSetter: _en('There is no PCOS diet, and no food is forbidden. What '
        'many people with PCOS do have is a body that reacts more strongly '
        'to a sharp rise in blood sugar. A few ordinary changes can soften '
        'those rises without cutting anything out.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Insulin is the hormone that moves sugar out of your blood and '
              'into your cells. In insulin resistance, cells respond less '
              'easily, so your body makes more insulin to do the same job. The '
              'sugar ends up where it should, but the insulin level stays '
              'high.'),
          _en('That matters in PCOS because high insulin pushes the ovaries to '
              'make more androgens. Raised androgens are one of the things that '
              "stop a follicle taking the lead. That's the loop linking how "
              'your body handles sugar to whether you ovulate.'),
          _en("Not everyone with PCOS has insulin resistance, and it isn't "
              "limited to any body size. It's checked with a blood test, not "
              "guessed at. That's why it's worth asking whether yours has been "
              'checked.'),
        ],
      ),
      PvReadSection(
        heading: _en("Why isn't any food banned?"),
        paragraphs: [
          _en('If insulin follows blood sugar, the useful question isn\'t '
              '"what should I cut out" but "what makes the rise gentler". '
              'Those are very different questions, and only one of them has an '
              'answer you can live with.'),
          _en('The same food gives a different curve depending on what you eat '
              'with it. Carbohydrate eaten alone makes blood sugar jump faster '
              'than the same carbohydrate eaten with protein, fat or fibre. '
              'Those slow down how fast it is broken down and taken in.'),
          _en('So "nothing banned" isn\'t just being kind. It\'s how it works. '
              'Rice with dal, curd and a vegetable acts very differently from '
              "rice on its own, and it's the same rice, in the same amount."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("Roti and rice aren't the problem"),
          body: _en("You'll often read online that Indian food is especially "
              "bad for PCOS. That isn't true. A home thali is already built "
              'the way this article suggests: carbohydrate with protein, fat, '
              'fibre and fermented food. What changes the curve is usually '
              "what's on the plate together, not the kind of cooking."),
        ),
      ),
      PvReadSection(
        heading: _en('What helps, day to day?'),
        paragraphs: [
          _en('Eat protein at every meal, including breakfast. Breakfast is '
              'the meal most often made of only carbohydrate: poha, upma, '
              'toast, tea with sugar. Adding eggs, curd, paneer, chana or nuts '
              'changes the shape of your whole morning.'),
          _en("Don't eat carbohydrate on its own, especially as a snack. A "
              'biscuit with tea gives a sharper rise than the same biscuit '
              'after a meal.'),
          _en('Move after you eat. A ten or fifteen minute walk after a meal '
              'lowers the peak in a way you can measure, because working '
              'muscle takes up sugar without needing much insulin. On this '
              'list, it gives you the most for the least effort.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why do sleep and exercise matter?'),
        paragraphs: [
          _en('Sleep matters more than you might think. A few short nights '
              'make the body use insulin less well, even in healthy people, '
              'and more so if you already have insulin resistance.'),
          _en('Strength exercise helps over months, not days. More muscle '
              'means more places for sugar to go, so less insulin is needed '
              'to put it there.'),
          _en("Any movement you'll keep doing helps, and research hasn't found "
              'one best kind for PCOS. Steady exercise, like brisk walking, '
              'cycling or swimming, helps your body use insulin better. So does '
              'strength work with your body weight, bands or light weights. A '
              'mix of both works well.'),
        ],
      ),
      // Gap plan 2026-09-26: yoga and mood, said honestly.
      PvReadSection(
        heading: _en('Does yoga help, and what about your mood?'),
        paragraphs: [
          _en('Yoga counts too. A few small trials in PCOS found regular yoga '
              'helped with insulin, hormone levels and anxiety. The trials are '
              'small, so treat it as one good kind of movement, not a treatment '
              "on its own. If you enjoy it, that's reason enough to choose it."),
          _en('Movement helps your mood too. Low mood and anxiety are more common in women with PCOS, and '
              'regular activity is one of the few things that helps both your '
              'blood sugar and how you feel. Many people notice the lift in '
              'mood well before any other change.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does the internet get wrong?'),
        paragraphs: [
          _en('Cutting carbohydrate to almost nothing works while it lasts, but '
              'almost no one keeps it up. A change kept for six weeks and then '
              'dropped does less than a smaller change kept for two years.'),
          _en('"Anti-inflammatory" food lists, detoxes, and cutting out whole '
              "groups of everyday food aren't backed by evidence in PCOS. And "
              'they have a real cost: they make eating stressful, and they '
              'make eating with other people awkward.'),
          _en("None of this is about weight. These changes act on insulin "
              "directly. They're worth making whether or not anything else "
              'about your body changes.'),
        ],
      ),
      PvReadSection(
        heading: _en('What if a doctor suggests metformin?'),
        paragraphs: [
          _en('Metformin is a diabetes medicine used in PCOS for its effect on '
              'insulin. When insulin resistance is part of the picture, it can '
              "help cycles become more regular. It's sometimes given alongside "
              'tablets that bring on ovulation.'),
          _en("It's a prescription, and the decision depends on your test "
              "results. It isn't something to ask for because a forum said "
              'so.'),
          _en("Food changes and metformin aren't a choice of one or the other. "
              'They work on the same problem from different sides, and a '
              "doctor choosing between them knows things an article doesn't."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask for the test instead of guessing'),
      body: _en('Ask a doctor whether your fasting glucose, HbA1c or insulin '
          'has been checked. This matters most if the skin on your neck or '
          'armpits has darkened, if type 2 diabetes runs in your family, or if '
          "your cycles have got longer over time. If you're already on any "
          "medicine, or you're pregnant or trying, talk to a doctor before "
          'making big changes.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do I have to give up rice?'),
        answer: _en('No. What you eat it with, and what you do in the hour '
            'after, changes the response far more than cutting it out would. '
            'Rice with dal, curd and vegetables is a perfectly good meal with '
            'PCOS.'),
      ),
      PvReadFaq(
        question: _en('Is intermittent fasting good for PCOS?'),
        answer: _en('The evidence is thin and mixed. For some people it helps '
            'cut down on snacking. For others it leads to one very big meal '
            "that spikes hard, or a difficult feeling about food. It isn't a "
            "PCOS treatment, and you don't have to do it."),
      ),
      PvReadFaq(
        question: _en("I'm not overweight. Can I still have insulin "
            'resistance?'),
        answer: _en('Yes, you can. In PCOS, insulin resistance happens at every '
            "body size. That's exactly why it's worth testing rather than "
            'assuming either way.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS; Endocrine Society clinical '
        'practice guideline on PCOS; trials of walking after meals on blood '
        'sugar after eating; small randomised trials of yoga in women with '
        'PCOS; Cochrane review of metformin in PCOS. Sources checked August '
        '2026.'),
    readNext: ['ttc_read_pcos_food'],
  ),


  PvRead(
    id: 'ttc_read_pcos_inositol',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('Inositol: what the studies show'),
    teaser: _en('The one PCOS supplement with real evidence behind it, and an '
        'honest look at how strong that evidence is.'),
    shortAnswer: _en('Inositol is the one PCOS supplement with real trials '
        'behind it. It may help your body use insulin and make cycles more '
        "regular, but the trials are small and it isn't a proven fertility "
        'treatment. If you try it, give it about three months and tell your '
        'doctor.'),
    scaleSetter: _en('Most of the huge PCOS supplement market is marketing. '
        "Inositol is the one worth knowing about. Not because it's a cure, but "
        "because it's the one with trials behind it, and the trials are more "
        'modest than the packets suggest.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Inositol is a sugar-like substance your body makes itself and '
              'also gets from food. Fruit, beans, grains and nuts all contain '
              'it. It plays a part in how cells respond to insulin, which is '
              'why it shows up in PCOS research at all.'),
          _en('Two forms matter: myo-inositol and D-chiro-inositol. Most '
              'products sold for PCOS mix the two, often at about forty to '
              'one, which is close to the mix found in the body.'),
        ],
      ),
      PvReadSection(
        heading: _en('What did the trials find?'),
        paragraphs: [
          _en('Across a number of randomised trials, inositol helped the body '
              'use insulin better in people with PCOS. It was also linked with '
              'more regular cycles and more frequent ovulation than a dummy '
              'pill (placebo).'),
          _en('The honest catches matter. Many of the trials are small. They '
              'use different doses, forms and mixes, which makes them hard to '
              'combine. Several were paid for by companies selling the '
              'product. And they mostly measured cycles and ovulation, not '
              "babies, which is a real difference."),
          _en("So the fair summary is: promising, fairly safe, not proven as a "
              'fertility treatment, and not a replacement for anything a '
              'doctor has prescribed.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("It's a supplement, not a medicine"),
          body: _en("Supplements aren't checked the way medicines are. What's "
              "on the label isn't verified like a prescription, and the amount "
              'in the capsule can differ from the amount printed on the box. '
              'Buying from a chemist rather than a random online listing is a '
              'small thing that helps.'),
        ),
      ),
      PvReadSection(
        heading: _en('How is it usually taken?'),
        paragraphs: [
          _en('The dose in most trials is around four grams of myo-inositol a '
              'day, usually split into two, often with a little '
              'D-chiro-inositol too. In the studies, changes in cycles took '
              "about three months to show. That's worth knowing before you "
              "decide after three weeks that it hasn't worked."),
          _en('Side effects are usually mild, mostly an upset stomach at higher '
              "doses. It isn't known to react dangerously with common "
              'medicines. But it does affect insulin, so if you take metformin '
              'or diabetes medicine, tell your doctor rather than just adding '
              'it.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which form should you buy?'),
        paragraphs: [
          _en('Powders and capsules both exist, and neither is better. Powder '
              'is usually cheaper per gram and dissolves in water with a '
              'slightly sweet taste. With capsules, you need to swallow several '
              'at a time to reach the dose used in trials.'),
          _en('Check the label '
              'before you buy. A bottle that looks cheap at one capsule a day '
              'may hold only a small part of what the trials used.'),
          _en("That's the most common way money gets wasted here. A product "
              'with a few hundred milligrams is sold on the back of research '
              'that used four grams.'),
          _en('And the big number on the front of the '
              'box is often the weight of everything in the mix, not the '
              'inositol in it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about the other PCOS supplements?'),
        paragraphs: [
          _en('Vitamin D is worth checking rather than guessing, and low levels '
              "are very common in India. If yours is low, it's sensible to "
              'correct it, for reasons that have nothing to do with PCOS.'),
          _en('Berberine shows up in a lot of PCOS marketing. It does have some '
              'effect on blood sugar. It also reacts with a long list of '
              "medicines, so it's something to discuss with a doctor, not to "
              'add to your cart.'),
          _en('Most of the rest, like fertility blends, detox teas and mixes '
              'with confident brand names, has no evidence in PCOS at all. Some '
              'are harmless but costly. A few are neither.'),
          _en('Whatever you take, write it down and bring the list to '
              'appointments. People most often forget to mention supplements '
              "because they didn't come on a prescription, and they're exactly "
              'what a doctor needs to know about.'),
        ],
      ),
      PvReadSection(
        heading: _en('So, is it worth trying?'),
        paragraphs: [
          _en("If you want to try inositol, it's a reasonable thing to try, "
              "and it's the only product in this group that meets that bar. "
              'Give it three months, buy it from somewhere you trust, and tell '
              'your doctor.'),
          _en("If you'd rather not, you aren't missing out on a treatment. The "
              'things with the strongest evidence in PCOS are still tablets to '
              'bring on ovulation when needed, and the everyday changes that '
              'help your body use insulin better.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Tell a doctor what you're taking"),
      body: _en('Speak to a doctor before starting inositol if you take '
          "metformin or any diabetes medicine, if you're pregnant or "
          "breastfeeding, or if you're already taking other supplements for "
          'PCOS. Stop and get advice if you have a stomach upset that won\'t '
          'settle, dizziness, or signs of low blood sugar.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is inositol better than metformin?'),
        answer: _en("They can't be compared directly, and metformin has far "
            'more evidence behind it. Some trials suggest similar effects on '
            'certain measures, with fewer stomach side effects. But metformin '
            "is a prescribed medicine, and inositol isn't a replacement for "
            'one.'),
      ),
      PvReadFaq(
        question: _en('How long before I know if it works?'),
        answer: _en('The trials that saw changes in cycles usually saw them '
            "over about three months. Judging it after a few weeks won't tell "
            'you anything.'),
      ),
      PvReadFaq(
        question: _en('Can I take it while trying to get pregnant?'),
        answer: _en("Many people do, and it isn't known to be harmful. But "
            'this is a question for the doctor who knows your history, '
            "especially if you're on any treatment."),
      ),
    ],
    evidence: _en('Cochrane review of inositol for PCOS; 2023 International '
        'Evidence-Based Guideline for the Assessment and Management of PCOS, '
        'which rates the evidence for inositol as limited and says it should '
        'be seen as experimental; randomised trials of myo-inositol on '
        'ovulation and cycle regularity. Sources checked August 2026.'),
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
    teaser: _en("Why the advice you've been given leaves things out, and what "
        'is worth your attention.'),
    shortAnswer: _en('PCOS and weight affect each other both ways, because '
        'insulin resistance makes weight easier to gain and harder to lose. '
        "Many women with PCOS are slim, and PCOS isn't your fault. What "
        "matters most is how your body handles insulin and whether you're "
        'ovulating, not a number on the scale.'),
    scaleSetter: _en("If you have PCOS, you've probably been told to lose "
        'weight, maybe by someone who said nothing else. This piece won\'t '
        "repeat that. It won't give you a number, and it won't suggest a "
        'plan. It will explain how weight and PCOS are linked, because that '
        'turns out to be more useful.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The first thing to say is that it works both ways. PCOS is '
              "usually talked about as if weight causes it, and that isn't "
              'what the research shows.'),
          _en('The insulin resistance that often '
              'comes with PCOS makes weight easier to gain and harder to lose. '
              'So for many people, the weight is at least as much a result of '
              'PCOS as a cause.'),
          _en('That matters, because being told to fix the cause by working '
              "on the symptom is confusing and unfair. It also explains "
              "something people often aren't believed about: the same effort "
              "gives them less result than it gives other people. It does."),
        ],
      ),
      PvReadSection(
        heading: _en("Can you have PCOS if you're slim?"),
        paragraphs: [
          _en("A good number of people with PCOS aren't overweight. They're "
              'often diagnosed later, because they don\'t match the picture a '
              'doctor is looking for.'),
          _en("If that's you, the whole talk about weight doesn't apply. The "
              'parts of care that do apply (insulin, ovulation, cycles) stay '
              'exactly the same. Insulin resistance happens at every body size '
              'in PCOS, which is exactly why your doctor tests for it rather '
              'than guessing from how you look.'),
          _en("If you're slim and your cycles are irregular, it's fair to ask "
              "about PCOS directly. Being slim doesn't rule it out."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("You didn't cause this"),
          body: _en('PCOS is strongly linked to your genes and runs in '
              "families. It isn't caused by anything you ate, didn't do, or "
              'should have known. If someone has hinted otherwise, they were '
              'wrong.'),
        ),
      ),
      PvReadSection(
        heading: _en('What the research supports, without a number'),
        paragraphs: [
          _en('When someone with PCOS carries extra weight and has insulin '
              'resistance, studies do find that changes in body make-up are '
              'linked with cycles becoming more regular and ovulation coming '
              'back more often.'),
          _en("We won't turn that into a target for you, and not because it "
              'feels awkward. A number from an app becomes something to check '
              'yourself against every month and fail.'),
          _en('And the research is '
              'about groups of people, not about any one person. What is right '
              'for your body is a talk with a doctor who can see your results.'),
          _en("It's also worth knowing that much of the benefit in those "
              'studies follows your body using insulin better, not the scale '
              'moving. Sleep, movement and how your meals are put together all '
              'change insulin, and they change it whether or not anything else '
              'changes.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does harsh dieting backfire?'),
        paragraphs: [
          _en('Very strict eating is harder to keep up with PCOS. It is more '
              'likely to end in a loop of cutting back and bouncing back. That '
              'leaves insulin no better, and leaves you feeling much worse.'),
          _en('Eating too little is also a risk to ovulation in itself. When '
              'food is short, the body turns down the systems for making a '
              'baby. So a harsh diet started to help you get pregnant can work '
              'directly against it.'),
          _en('Eating disorders are more common in people with PCOS than in '
              'other people, and years of medical advice focused on weight is '
              'part of why.'),
          _en('If food or your body has become a real source of '
              "distress, that's worth raising with a doctor for its own sake. "
              "It isn't a side issue next to fertility. It matters just as "
              'much.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is worth your attention?'),
        paragraphs: [
          _en('Whether your insulin, glucose or HbA1c have been checked. That '
              'is a clear question with a clear answer, and it changes which '
              'treatment makes sense.'),
          _en("Whether you're ovulating, and how often. This affects trying "
              "for a baby most directly, and it can be measured."),
          _en("Movement you'd still be doing in six months, at whatever pace "
              'suits you. A walk after dinner most days beats a gym plan '
              'dropped in February, and walking after meals really does help '
              'insulin.'),
          _en('Sleep. It gets the least credit of anything on a PCOS list, and '
              'no one is selling anything for it.'),
          _en('Your mood. Low mood and anxiety are more common with PCOS. '
              "They're worth raising at an appointment as much as any blood "
              'test.'),
          _en('None of these is an instruction about weight, and you can raise '
              'all of them at an appointment on Monday.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Some of this needs a person, not an article'),
      body: _en('Speak to a doctor if food, eating or your body has become a '
          "real source of distress, if you're cutting back on food a lot, or "
          'if your weight has changed fast for no clear reason. Ask for your '
          'glucose or HbA1c to be checked, rather than only getting advice '
          'about weight. If an appointment leaves you with only that advice '
          "and no plan, it's fair to ask what else was considered."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('My doctor only said lose weight. Is that all there is?'),
        answer: _en("No, and it's fair to push back on that. Ask whether your "
            'insulin and glucose have been checked, whether you are '
            "ovulating, and what the plan is if you're trying to get pregnant. "
            'Those are the questions a fuller appointment covers.'),
      ),
      PvReadFaq(
        question: _en("I'm not overweight. Does any of this apply?"),
        answer: _en("The weight parts don't. The insulin, ovulation and cycle "
            "parts may well apply, because insulin resistance in PCOS isn't "
            "limited to any body size. It's worth testing for either way."),
      ),
      PvReadFaq(
        question: _en('Why is it so much harder for me than for other people?'),
        answer: _en('Because it really is harder. Insulin resistance changes '
            'how your body stores and uses energy, so the same effort gives a '
            "different result. You haven't been imagining it, and you "
            "haven't been doing it wrong."),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS, including its advice on using '
        'language that includes every body size and on checking for eating '
        'disorders; Endocrine Society clinical practice guideline on PCOS; '
        'studies of lifestyle change and ovulation in PCOS. Sources checked '
        'August 2026.'),
    readNext: ['ttc_read_pcos_insulin'],
  ),


  PvRead(
    id: 'ttc_read_pcos_meds',
    hue: 288,
    kicker: _en('PCOS'),
    title: _en('Letrozole, metformin and the usual order'),
    teaser: _en('What gets tried first, what each medicine does, and what the '
        "next steps look like if the first one doesn't work."),
    shortAnswer: _en('Letrozole, a tablet taken for about five days early in '
        'your cycle, is now the usual first medicine to help you ovulate with '
        'PCOS. Metformin is sometimes added to help your body use insulin. '
        "Injections, keyhole surgery and IVF come later, only if tablets don't "
        'work.'),
    scaleSetter: _en("Treatment for PCOS when you're trying to get pregnant "
        'follows a fairly set order, and knowing it makes an appointment much '
        "easier to follow. None of it is something to arrange yourself. "
        'Every item here is prescribed and checked by a doctor.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("In PCOS the main problem is usually that ovulation isn't "
              'happening reliably, so the first treatments aim at exactly '
              "that. They're called ovulation induction, and they are tablets, "
              'not injections.'),
          _en('This matters because many people assume a PCOS diagnosis means '
              "IVF is coming. For most, it doesn't. The first steps are cheap "
              'tablets that you take at home.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why is letrozole now tried first?'),
        paragraphs: [
          _en("Letrozole is taken for about five days early in your cycle. "
              'It lowers oestrogen for a short time. That makes your body send '
              'a stronger signal to the ovaries, which helps one follicle take '
              'the lead.'),
          _en('For years clomifene was the usual first choice, and letrozole '
              'was the backup. That order has mostly flipped. In PCOS, trials '
              'found letrozole led to more ovulation and more live births than '
              'clomifene, and current guidance recommends it first.'),
          _en('It is usually checked with scans in the first cycles, to make '
              "sure the ovaries respond, but not too strongly. Side effects are "
              'usually mild: tiredness, headaches, or hot flushes in some '
              'people.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Being given a cancer drug isn't what it sounds like"),
          body: _en('Letrozole is licensed for breast cancer and used in '
              'fertility care outside that licence. This is common, well '
              'established and recommended by guidelines. If it worries you, '
              "it's completely fair to ask about it."),
        ),
      ),
      PvReadSection(
        heading: _en('What does metformin do?'),
        paragraphs: [
          _en("Metformin is a diabetes medicine. In PCOS it's used for its "
              'effect on insulin, not on the ovaries directly. When insulin '
              'resistance is part of the picture, lowering it can help cycles '
              'become more regular on their own.'),
          _en("It's sometimes used alone, and sometimes added to letrozole when "
              "letrozole alone hasn't brought on ovulation. The most common "
              'side effect is an upset stomach. This is usually helped by '
              'starting on a low dose, raising it slowly, and taking it with '
              'food.'),
          _en("It isn't a weight-loss drug and shouldn't be called one, though "
              'some people do lose a little weight on it.'),
        ],
      ),
      PvReadSection(
        heading: _en("What happens to metformin once you're pregnant?"),
        paragraphs: [
          _en('Whether you keep taking it once you know you\'re pregnant '
              'varies. That is for the doctor who prescribed it to decide, not '
              'a general rule.'),
          _en('Some people continue it through the first '
              'trimester and others stop. Either is a normal thing to be told. '
              'What matters is that you ask rather than assume.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why do the steps come in this order?'),
        paragraphs: [
          _en('Fertility treatment is built like a ladder on purpose. Each '
              'rung is the gentlest thing with a fair likelihood of working. '
              'Tablets before injections, injections before procedures. Each '
              'step is reviewed after an agreed number of cycles, not kept '
              'going forever.'),
          _en("That's worth knowing, because otherwise it can feel like being "
              'brushed off. Being offered a five-day course of tablets when '
              "you were ready for IVF isn't a clinic saving money. It's the "
              'step most likely to work with the least done to you.'),
          _en("For a large share of people with PCOS, it's the last step they "
              'need.'),
          _en('It also explains why the checking matters more than the '
              'prescription. The first cycles of any of these are as much '
              'about finding the right dose for your body as about that cycle '
              'working.'),
        ],
      ),
      PvReadSection(
        heading: _en('What comes next, if you need it?'),
        paragraphs: [
          _en("If tablets don't bring on ovulation after several checked "
              'cycles, the next options usually involve a specialist. '
              'Injections of gonadotropins act on the ovaries more directly. '
              'They need close checking, because ovaries with PCOS can react '
              'strongly.'),
          _en("Ovarian drilling is a keyhole procedure. It's offered less "
              'often now than it used to be, but it is still sometimes used.'),
          _en('IUI and IVF are further along the same path. IVF works well in '
              'PCOS, with one caution. The same strong response from the '
              'ovaries that helps also raises the risk of ovarian '
              "hyperstimulation. That's why the treatment plan is adjusted and "
              'checked carefully.'),
        ],
      ),
      // Gap plan 2026-09-26: these tablets are not only for PCOS. Kept short;
      // the full ovulation-tablets read lives in its own file.
      PvReadSection(
        heading: _en('Are these tablets only for PCOS?'),
        paragraphs: [
          _en('No. Letrozole and clomifene are also given to women who '
              'ovulate irregularly for other reasons, and to some who do '
              'ovulate, often alongside IUI. In those cycles the aim is to '
              'grow one or two follicles on a known timetable.'),
          _en('Some causes need a different medicine first. A thyroid problem '
              'is treated with thyroid tablets, and raised prolactin with a '
              'tablet such as cabergoline. Once those levels settle, ovulation '
              'often comes back without anything else.'),
          _en('If ovulation has stopped because the brain has turned down its '
              'signals, for example after very low weight or very hard '
              "training, these tablets don't help. Then the usual answer is "
              'eating more and easing off, and sometimes hormone injections '
              'given by a specialist.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you ask at the appointment?'),
        paragraphs: [
          _en('How many cycles of this before we try something else? Agreeing '
              'a number at the start stops a year slipping by.'),
          _en('Will this cycle be checked, and how? Scans in the early cycles '
              'are usual, and they tell you whether the dose is right.'),
          _en("Has my partner had a semen analysis? It's quick and cheap. "
              'Skipping it because you already have a PCOS diagnosis is one of '
              'the more common ways a second cause goes unnoticed.'),
          _en("What are the signs something is wrong, and who do I call? It's "
              'worth asking before you need the answer.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the clinic straight away for these'),
      body: _en("If you're taking tablets to bring on ovulation or fertility "
          'injections, and you get severe pain or swelling in your tummy, '
          'fast weight gain over a day or two, vomiting that won\'t stop, '
          'breathlessness, or you pass much less urine than usual, contact '
          'your clinic or get urgent care immediately. These can be signs of '
          'ovarian hyperstimulation, which needs to be checked quickly. Never '
          'change a prescribed dose yourself.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Will letrozole give me twins?'),
        answer: _en('Twins are a little more likely than when you conceive '
            'without treatment, and less likely with letrozole than with '
            'clomifene. Scans in the early cycles are partly there to watch '
            'for too many follicles growing.'),
      ),
      PvReadFaq(
        question: _en("Can I take metformin if I don't have diabetes?"),
        answer: _en("Yes. In PCOS it's prescribed for its effect on insulin, "
            "not for diabetes. It's still a prescription medicine and needs a "
            'doctor.'),
      ),
      PvReadFaq(
        question: _en('How long do people usually stay on these?'),
        answer: _en('Tablets to bring on ovulation are usually tried for a set '
            'number of cycles and then reviewed, not taken forever. The '
            'useful part is agreeing that number with your doctor at the '
            'start.'),
      ),
    ],
    evidence: _en('2023 International Evidence-Based Guideline for the '
        'Assessment and Management of PCOS; NICE CG156; Legro et al., '
        'letrozole versus clomiphene for infertility in PCOS (NEJM); Cochrane '
        'reviews of aromatase inhibitors and of metformin in PCOS. Sources '
        'checked August 2026.'),
    readNext: ['ttc_read_pcos_treatment', 'ttc_read_ovulation_tablets'],
  ),
];
