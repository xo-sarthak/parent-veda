// =============================================================================
//  TTC reads — the stage's long-form library
// -----------------------------------------------------------------------------
//  Written to `PvRead`. The model's head explains the reader; this file is the
//  content, and the rules it is written under are worth stating once because
//  every article added here has to keep them.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE CLINICAL RULES, WHICH DO NOT RELAX FOR PROSE
//  ---------------------------------------------------------------------------
//
//  · **Never a personalised probability.** No "your chance this month", no
//    computed success rate for her. Population figures are allowed, and only
//    where they REDUCE pressure rather than set a target — CLAUDE.md's exact
//    wording, and `test/ttc_clinical_review_test.dart` scans this source, not
//    just seed lists.
//  · **Never a diagnosis.** Every read carries `whenToSeeSomeone`, required on
//    the model so it cannot be the thing that got left off.
//  · **Never contradict her own clinician.** Where a doctor owns a decision we
//    explain it, remind about it, or help her prepare for it. We do not
//    recreate it. See `TimingOwnership` in `ttc_care_pathway.dart`.
//  · **Named sources, never "studies show".** `evidence` is required by the
//    shape test. An unsourced claim in a fertility article is indistinguishable
//    from the content this product exists to replace.
//
//  ⚠️ COSTS CARRY A DATE. A rupee figure with no year on it is worse than no
//  figure — she plans around it, and it silently rots. Every price range below
//  says when it was checked.
//
//  ENGLISH FIRST — every string is `_en(...)`, so `grep -c '_en('` here is the
//  size of the Hindi backlog. Never `_t(x, x)`: an identical pair reads as
//  finished work to every audit, which is how `can_i_data` was once reported
//  done with 302 strings still English.
// =============================================================================

import '../localization/app_language.dart';
import '../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReads = [
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
  //  FERTILE WINDOW — the door's Excel Content cell, in two pieces
  // ===========================================================================
  //  Workbook: "How conception works, timing, cycle basics, common myths."
  //  Four topics, split as MECHANISM (this read) and TIMING (the next), because
  //  one piece covering all four runs past 3,000 words, and because the two
  //  halves are read at different moments — she looks up how a cycle works
  //  once, and looks up timing every single month.
  //
  //  ⚠️ THIS MATERIAL ALREADY PARTLY EXISTS, AND THAT IS THE POINT.
  //  `ttc_chapter_data.dart` carries "Why the window is six days and not one"
  //  and "Things that do not matter, despite what you have heard", and both are
  //  good. They are also CHAPTER-LOCKED: `ttc_chapter` routes to whichever
  //  chapter the engine has her in, so a woman in the waiting days who taps the
  //  fertile-window door and wants the myths gets a different chapter entirely.
  //  The content was never missing. It was unreachable from the door that
  //  promises it, which is the failure this repo has a gate for.
  //
  //  ⚠️ SO THERE ARE NOW TWO SOURCES FOR SOME OF THESE FACTS, AND THEY CAN
  //  SILENTLY DIVERGE. Edit the six-day window here and the chapter keeps
  //  saying the old thing, with nothing failing anywhere. The reconciliation to
  //  make later is for the chapter section to point AT these reads rather than
  //  restate them; it is not made now because the chapter reader is the most
  //  clinically reviewed surface in the stage and is not being rewritten in the
  //  middle of a content pass. Written down so it is a known debt, not a
  //  surprise for whoever finds the two copies.
  PvRead(
    id: 'ttc_read_how_conception_works',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('How conception actually works'),
    teaser: _en('The mechanism, in plain words — what a cycle is doing, what '
        'ovulation actually is, and why so much of this is invisible.'),

    scaleSetter: _en('Almost nothing about conception happens on a schedule '
        'you can see. Understanding the mechanism will not make it happen '
        'faster — but it turns a month of guessing into a month you can read, '
        'and that is most of what makes the waiting bearable.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_cycle_basics',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('A menstrual cycle is not one process. It is two, running back '
              'to back, and they behave completely differently — which is the '
              'single most useful thing to know about it, and the thing almost '
              'nobody is taught.'),
          _en('The first half is variable. The second half is not. Nearly '
              'everything confusing about cycle length comes from that one '
              'fact.'),
        ],
      ),

      PvReadSection(
        heading: _en('The first half: getting an egg ready'),
        paragraphs: [
          _en('From the first day of bleeding, a group of follicles in the '
              'ovaries begins to grow. Each one holds an immature egg. Over '
              'the next couple of weeks one pulls ahead of the rest and the '
              'others stop — quietly, with no symptoms at all.'),
          _en('This half is the follicular phase, and its length is genuinely '
              'variable. It usually runs somewhere between ten and fourteen '
              'days, but it can be shorter or longer, and it can differ in the '
              'same woman from one month to the next. Stress, illness, travel '
              'and broken sleep all move it.'),
          _en('That variability is why a cycle that is 28 days one month and '
              '33 the next is not a sign that something is wrong. What moved '
              'was almost certainly this half. The first half is the flexible '
              'one.'),
        ],
      ),

      PvReadSection(
        heading: _en('Ovulation: the part that lasts a day'),
        paragraphs: [
          _en('When the leading follicle is ready, a sharp rise in luteinising '
              'hormone — LH — triggers it to release its egg. That is '
              'ovulation. It takes minutes. Most women feel nothing, and the '
              'ones who do usually describe a dull one-sided ache rather than '
              'anything dramatic.'),
          _en('The egg then has about twenty-four hours. If it is not '
              'fertilised in that time it simply stops, and is reabsorbed. '
              'Nothing is wasted and nothing is lost — this happens several '
              'hundred times in a lifetime.'),
          _en('It is that LH rise which ovulation strips detect. Which is why '
              'a positive strip means ovulation is probably coming in the next '
              'day or so, not that it has already happened.'),
        ],
        tip: PvReadTip(
          title: _en('The one sign that arrives early enough to act on'),
          body: _en('Cervical mucus changes before ovulation, not after. In '
              'the days leading up to it, it turns clear, slippery and '
              'stretchy — the comparison everyone uses is raw egg white. That '
              'change is the body opening the door, and unlike a temperature '
              'rise it tells you something while there is still time to use '
              'it.'),
        ),
      ),

      PvReadSection(
        heading: _en('The second half: the fixed one'),
        paragraphs: [
          _en('The emptied follicle does not disappear. It converts into a '
              'small temporary gland, the corpus luteum, which produces '
              'progesterone — the hormone that holds the uterine lining in '
              'place and keeps it ready.'),
          _en('This half, the luteal phase, is far more consistent. It runs '
              'about fourteen days, and anything from ten to seventeen is '
              'normal. More usefully, it tends to be roughly the same length '
              'in the same woman every month.'),
          _en('If no pregnancy arrives, the corpus luteum winds down on its '
              'own schedule, progesterone falls, and the lining comes away. '
              'That is the period — the end of the sentence, not the '
              'beginning.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Why this matters for tracking'),
          body: _en('Because the second half is fixed and the first half is '
              'not, ovulation is better counted BACKWARDS from the next period '
              'than forwards from the last one. In a 33-day cycle it is far '
              'more likely around day 19 than around day 14 — which is exactly '
              'why the standard "day 14" advice misses so often for anyone '
              'whose cycle is not 28 days.'),
        ),
      ),

      PvReadSection(
        heading: _en('What has to line up'),
        paragraphs: [
          _en('For conception, several things have to happen in order — and '
              'each of them can quietly fail to happen in any given month.'),
        ],
        bullets: [
          _en('An egg has to be released, and be healthy.'),
          _en('Sperm have to be present in the tube at the right time, in '
              'sufficient number, and moving well.'),
          _en('One has to fertilise the egg — which happens in the fallopian '
              'tube, not in the uterus.'),
          _en('The fertilised egg has to keep dividing correctly for about a '
              'week while it travels down.'),
          _en('And it has to implant in a lining that is ready to receive it.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Reference, not the spine — it explains an arithmetic she
        // may want on a hard month and does not need on the day she is
        // learning what a follicle is.
        collapsible: true,
        summary: _en('Why a healthy couple does not conceive every month, and '
            'why that is arithmetic rather than a fault.'),
        heading: _en('Why it does not happen every month'),
        paragraphs: [
          _en('That chain has several links, and the commonest reason a month '
              'does not work is that a fertilised egg did not divide correctly '
              '— a chromosomal accident, at random, in a single cell. Nothing '
              'either of you did caused it and nothing could have prevented '
              'it.'),
          _en('The rate of those accidents rises with age, and that is most of '
              'what "age and fertility" actually means. It is not that the '
              'ovaries stop working. It is that a larger share of eggs carry '
              'an error which stops the process early — often before a period '
              'is even late.'),
          _en('This is why fertility is discussed across months rather than '
              'inside a single cycle. A month that does not work is the '
              'expected case rather than the exception, and it is not '
              'information about either of you.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('My cycle is not 28 days. Is that a problem?'),
        answer: _en('Not by itself. Cycles of roughly 21 to 35 days are '
            'considered normal, and what varies between them is almost always '
            'the first half. What matters more than the number is whether it '
            'is roughly the SAME number each month — a predictable 32-day '
            'cycle is far less concerning than one swinging between 26 and '
            '45.'),
      ),
      PvReadFaq(
        question: _en('Can I feel ovulation?'),
        answer: _en('Some women do — a dull ache on one side, lasting a few '
            'hours. It even has a name, mittelschmerz. Most women feel '
            'nothing, and feeling nothing says nothing at all about whether it '
            'happened.'),
      ),
      PvReadFaq(
        question: _en('Can you ovulate twice in one cycle?'),
        answer: _en('More than one egg can be released, but within the same '
            'short window — that is how non-identical twins happen. What does '
            'not occur is a second, separate ovulation later in the same '
            'cycle. Once progesterone rises, that door is shut for the month.'),
      ),
      PvReadFaq(
        question: _en('Does a period always mean I ovulated?'),
        answer: _en('Usually, but not always. A cycle can run without '
            'releasing an egg and still end in bleeding — the lining builds up '
            'and eventually sheds anyway. It is commoner when cycles are long '
            'or irregular, and it is one reason tracking across a few months '
            'tells you more than any single month can.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth raising with a doctor'),
      body: _en('If your cycles are shorter than 21 days or longer than 35, if '
          'they swing widely from month to month, if periods have stopped for '
          'three months or more, or if bleeding is heavy enough to interfere '
          'with your day. None of these is an emergency, and all of them are '
          'far easier to investigate with two or three months of dates written '
          'down — so start the record now and book when it suits you.'),
    ),

    evidence: _en('Cycle and phase physiology follows Endotext, "The Normal '
        'Menstrual Cycle and the Control of Ovulation" (NCBI Bookshelf), and '
        'StatPearls, "Physiology, Menstrual Cycle". Luteal-phase length range '
        'and the cervical-mucus sequence as described by the UCSF Center for '
        'Reproductive Health and Cleveland Clinic. Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Start a record of your own cycle'),
        value: _en('Three months of dates tells you where your ovulation '
            'actually sits, which no article can.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("See this cycle's window"),
        value: _en('Your own dates, turned into the days that count this '
            'month.'),
        surfaceId: 'ttc_window',
      ),
    ],

    readNext: ['ttc_read_timing_myths'],
  ),

  // ===========================================================================
  //  FERTILE WINDOW — timing, and the myths
  // ===========================================================================
  //  The other half of the Excel cell: "timing" and "common myths".
  //
  //  ⚠️ THE MYTHS ARE THE POINT OF THIS PIECE, and they are why it must not be
  //  written as a list of corrections. Every myth below was told to her by
  //  someone who loves her — a mother, a sister-in-law, a neighbour. A page
  //  that reads as a scoreboard of things her family got wrong is a page she
  //  will not send to anyone and may not finish. See the note on the myth
  //  component in `pv_reader_screen.dart`: the typography carries the
  //  judgment, and nothing scolds.
  PvRead(
    id: 'ttc_read_timing_myths',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Timing, and the advice worth putting down'),
    teaser: _en('When it actually matters, how often, and which of the things '
        'you have been told do nothing at all.'),

    scaleSetter: _en('The window is about six days wide, and the whole design '
        'of it is forgiving — being together every day or two across those '
        'days works as well as any amount of testing and counting. There is no '
        'single day to hit, and no way to miss it by an hour.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_timing_myths',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Almost all timing advice is built on one number that is wrong '
              'for most people: day fourteen. It assumes a 28-day cycle, and '
              'most cycles are not 28 days.'),
          _en('What is actually true is simpler and much less demanding than '
              'the counting suggests.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why the window is six days'),
        paragraphs: [
          _en('Sperm survive around five days inside the reproductive tract. '
              'An egg lives about a day after release. Put those together and '
              'you get a window of roughly six days, ending on the day of '
              'ovulation itself.'),
          _en('Note which end matters. The days BEFORE ovulation carry most of '
              'the chance, because sperm can wait and an egg cannot. The '
              'highest-probability stretch is the three days ending on the day '
              'of ovulation — which means that by the time a test tells you '
              'ovulation has happened, the most useful days have already '
              'passed.'),
          _en('This is the single most practical consequence in the whole '
              'piece: aim to be in the window before it closes, not to catch '
              'the moment.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('How often, and that is genuinely all'),
          body: _en('Every one to two days across the window. Not daily and '
              'timed. Not saved up. The guidance from the American Society for '
              'Reproductive Medicine is exactly this, and its plainness is the '
              'point — a couple having sex every other day does not need to '
              'track anything at all to be doing this correctly.'),
        ),
      ),

      PvReadSection(
        heading: _en('The things that do not matter'),
        paragraphs: [
          _en('These come up more than anything else, and each one costs '
              'somebody a small amount of dignity every month for no return.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Lie still with your legs up for twenty minutes '
              'afterwards.'),
          fact: _en('Sperm reach the cervix within minutes, and what is going '
              'to travel has already started. Getting up changes nothing. This '
              'one is worth putting down first because it is the one that most '
              'often turns a private moment into a procedure.'),
        ),
      ),

      PvReadSection(
        mythFact: PvMythFact(
          myth: _en('Some positions work better than others.'),
          fact: _en('There is no evidence that position affects whether '
              'conception happens. None of the studies that people cite for '
              'this measured pregnancy.'),
        ),
      ),

      PvReadSection(
        mythFact: PvMythFact(
          myth: _en('Save it up for a few days so the count is higher.'),
          fact: _en('Long gaps raise the number of sperm but lower how well '
              'they move, and movement is what matters here. Every one to two '
              'days is the sweet spot precisely because it balances the two. '
              'Abstaining for a week before the window is actively unhelpful.'),
        ),
      ),

      PvReadSection(
        mythFact: PvMythFact(
          myth: _en('If you are stressed, it will not happen.'),
          fact: _en('Severe, sustained stress can delay or stop ovulation, '
              'and that is real. Ordinary stress — work, a difficult month, '
              'worrying about this very question — has not been shown to '
              'prevent conception. This myth deserves particular impatience, '
              'because it hands a woman a reason to blame herself for '
              'something she cannot control.'),
        ),
      ),

      PvReadSection(
        heading: _en('The one that is actually true'),
        paragraphs: [
          _en('Most ordinary lubricants — and saliva — measurably reduce how '
              'well sperm move. This is the rare piece of bedroom advice that '
              'has real evidence behind it and is almost never mentioned.'),
          _en('If you use one, look for a product labelled fertility-friendly. '
              'They are widely available in India and cost a little more than '
              'the usual ones. Nothing else in this section is worth changing; '
              'this is.'),
        ],
        tip: PvReadTip(
          title: _en('If tracking has started to feel like a second job'),
          body: _en('You can stop. A couple having sex every two days through '
              'the middle of the cycle covers the window without a single '
              'strip, chart or app notification. Tracking is useful when '
              'cycles are irregular or when you want data for a doctor — it is '
              'not a requirement, and treating it as one is how this stage '
              'stops being bearable.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. A tool comparison she needs on the day she is standing in
        // a chemist, and does not need while reading about the window.
        collapsible: true,
        summary: _en('Strips, temperature and mucus — what each one actually '
            'answers, and which is worth your money.'),
        heading: _en('If you do want to track'),
        paragraphs: [
          _en('Three methods, and they answer different questions — which is '
              'the thing nobody explains when they sell you one.'),
        ],
        bullets: [
          _en('Ovulation strips detect the LH rise, so they warn you that '
              'ovulation is coming in a day or so. Useful, because they point '
              'forwards. A plain strip is as accurate as an expensive one.'),
          _en('Basal temperature rises after ovulation, so it confirms that it '
              'happened — after the window has closed. Useful across months to '
              'find your pattern, useless for this month.'),
          _en('Cervical mucus turns clear and stretchy in the days before. '
              'Free, points forwards, and needs nothing but attention.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('How long should we try before worrying?'),
        answer: _en('The usual guidance is a year under 35, and six months at '
            '35 or over. That assumes regular, predictable cycles — if yours '
            'are irregular, or you already know about PCOS, endometriosis or a '
            'previous pelvic surgery, the clock does not apply and it is '
            'reasonable to ask sooner.'),
      ),
      PvReadFaq(
        question: _en('We can only manage it once or twice a month. Does that '
            'ruin our chances?'),
        answer: _en('It lowers the odds of landing inside the window by '
            'chance, which is exactly the situation where tracking earns its '
            'keep — knowing roughly when the window is lets a small number of '
            'occasions be placed well. Long-distance couples do this '
            'successfully all the time.'),
      ),
      PvReadFaq(
        question: _en('Is there a best time of day?'),
        answer: _en('No. Sperm counts vary slightly through the day and the '
            'difference is far too small to plan around. Anyone selling you a '
            'time of day is selling you something.'),
      ),
      PvReadFaq(
        question: _en('Does it matter if it happens on the day of ovulation '
            'itself?'),
        answer: _en('It is a good day, but not the best one — the two days '
            'before it carry more, because sperm can already be waiting. This '
            'is why chasing a positive strip on the day tends to arrive '
            'slightly late.'),
      ),
      PvReadFaq(
        question: _en('Can an app tell me when I ovulate?'),
        answer: _en('It can estimate, and an estimate from your own logged '
            'dates is genuinely useful. What it cannot do is know — no app can '
            'see an ovary. Treat the estimate as a window to be present '
            'across, never as a date to hit.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When timing is not the problem'),
      body: _en('Book if you have been trying for a year — six months if you '
          'are 35 or over — with cycles you can predict. Sooner, without '
          'waiting out the clock, if your cycles are irregular or absent, if '
          'sex is painful, if periods are very heavy, or if either of you has '
          'had pelvic surgery, chemotherapy or a known fertility condition. '
          'Timing advice cannot fix any of those and no amount of better '
          'timing will.'),
    ),

    evidence: _en('The fertile window, the three-day highest-probability '
        'interval, the every-one-to-two-days recommendation and the caution on '
        'commercial lubricants all follow "Optimizing natural fertility: a '
        'committee opinion" from the Practice Committees of the American '
        'Society for Reproductive Medicine and the Society for Reproductive '
        'Endocrinology and Infertility (updated 2022). Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("See this cycle's window"),
        value: _en('Your own dates, turned into the days that count this '
            'month.'),
        surfaceId: 'ttc_window',
      ),
      PvReadNextStep(
        kind: PvNextKind.product,
        title: _en('Strips, and what else is worth having'),
        value: _en('The two things worth keeping in the house, and what to '
            'skip.'),
        surfaceId: 'ttc_products',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Ask a fertility specialist'),
        value: _en('If the timing is right and it still is not happening, that '
            'is a different conversation.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_how_conception_works'],
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
];

/// Lookup by id. Null is a real answer — see `ttc_surface_router.dart`.
PvRead? ttcReadById(String id) {
  for (final r in kTtcReads) {
    if (r.id == id) return r;
  }
  return null;
}

/// Title for a read-next card, without handing the reader the whole library.
LocalizedText? ttcReadTitle(String id) => ttcReadById(id)?.title;
