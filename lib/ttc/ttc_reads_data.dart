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
  // ===========================================================================
  //  INFERTILITY & IVF — "when to seek help"
  // ===========================================================================
  //  Excel Content cell: "When to seek help, the tests, IUI/IVF explained, cost
  //  expectations." Four topics, and only three are written here — "the tests"
  //  is already carried properly by `ttc_tests_data.dart`, which holds ten
  //  tests with real Indian price ranges, when in the cycle each is taken, and
  //  how to read the result. Writing a second version of that would be filler,
  //  and the reads below point at it instead.
  //
  //  ---------------------------------------------------------------------------
  //  ⚠️ THE THREE RULES THIS BRACKET ENFORCES HARDER THAN ANY OTHER
  //  ---------------------------------------------------------------------------
  //
  //  · **NO COMMERCE. AT ALL.** `ttc_brackets.dart` marks Products
  //    `notApplicable` here with the plainest reason in the file: "Not a fit
  //    (clinical)". No product row, no course upsell, no "recommended for you".
  //    A woman reading this has been trying for two years. The consult exists
  //    because she asked for it, not because we are selling it.
  //  · **NEVER A SUCCESS RATE. NEVER "YOUR CHANCES."** Not a per-cycle figure,
  //    not a clinic's advertised number, not an age-banded table. See the
  //    clinical invariants in CLAUDE.md and the header of `kTtcInfertility`.
  //    What IS allowed, and is done below, is teaching her how to read the
  //    number a clinic shows her — that lowers pressure instead of setting a
  //    target.
  //  · **THE COSTS CARRY A DATE AND A CAVEAT ABOUT THEIR SOURCE.** Fertility
  //    pricing in India is published almost entirely by the clinics selling the
  //    treatment. That does not make it useless; it makes it a range to sanity-
  //    check against, and saying so is the difference between informing her and
  //    repeating an advertisement.
  PvRead(
    id: 'ttc_read_when_to_seek_help',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('When it is time to see someone'),
    teaser: _en('The guidance on how long to try, who should not wait it out, '
        'and what actually happens at a first appointment.'),

    scaleSetter: _en('Seeing a fertility doctor is not a decision that '
        'something is wrong. It is a set of tests and a conversation, and for '
        'a large share of couples it ends with a small correction rather than '
        'a treatment. Going early costs you very little; going late is the '
        'thing that is hard to undo.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_when_to_seek_help',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('There is a standard answer to this, and then there is a longer '
              'list of situations where the standard answer does not apply. '
              'The second list matters more, because it is the one people do '
              'not know about and therefore wait through.'),
        ],
      ),

      PvReadSection(
        heading: _en('The usual guideline'),
        paragraphs: [
          _en('Twelve months of regular, unprotected sex, if you are under 36. '
              'That is the threshold used by NICE and echoed by most bodies '
              'internationally, and "regular" means every two or three days '
              'across the cycle rather than timed attempts around a window.'),
          _en('At 36 or over, the advice is to be seen at presentation — that '
              'is, when you first raise it, rather than after a waiting '
              'period. The reason is not that fertility falls off a cliff at '
              '36; it is that investigation and treatment both take months, '
              'and a year spent waiting is a year that cannot be recovered.'),
          _en('It is worth being precise about what the twelve months is '
              'measuring. It is a marker for when investigating becomes '
              'worthwhile across a whole population — not a diagnosis, not a '
              'deadline, and not a statement about you.'),
        ],
      ),

      PvReadSection(
        heading: _en('Reasons not to wait at all'),
        paragraphs: [
          _en('The twelve-month rule assumes regular ovulation and no known '
              'reason for difficulty. If any of the following is true, that '
              'assumption is already broken and the clock does not apply — you '
              'can reasonably ask to be seen now.'),
        ],
        bullets: [
          _en('Cycles that are irregular, very long, or absent — including a '
              'known PCOS diagnosis. Nothing is gained by waiting a year to '
              'find out you are not ovulating predictably.'),
          _en('Periods that are very painful or very heavy, or pain during '
              'sex — the usual reasons endometriosis is suspected.'),
          _en('Any previous pelvic surgery, a ruptured appendix, or a past '
              'pelvic infection — all of which can affect the tubes.'),
          _en('A semen analysis that has already come back abnormal, or a '
              'known problem on his side. Half of all cases involve a male '
              'factor and it is the fastest thing in the whole workup to '
              'check.'),
          _en('Two or more miscarriages.'),
          _en('Cancer treatment planned for either of you — this is the one '
              'situation where the referral is genuinely urgent, because '
              'fertility preservation has to happen before treatment starts.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('The one that is most often missed'),
          body: _en('Irregular cycles. Women wait out the full year assuming '
              'the guidance applies to them, when the guidance was written for '
              'people whose cycles are predictable. If yours are not, the '
              'twelve months was never your number.'),
        ),
      ),

      PvReadSection(
        heading: _en('What a first appointment is actually like'),
        paragraphs: [
          _en('Almost nobody is treated at the first visit, which surprises '
              'people in both directions — some expect to start immediately, '
              'others are braced for something invasive.'),
          _en('What happens is a history, an examination, and a set of tests '
              'ordered for both of you. His semen analysis is usually the '
              'first thing requested, because it is quick, cheap and rules a '
              'great deal in or out. Yours will typically include blood tests '
              'timed to particular days of the cycle, and a scan.'),
          _en('You then come back with results, and the conversation about '
              'what to do next happens with something concrete in front of '
              'you. That second appointment is the real one.'),
        ],
        tip: PvReadTip(
          title: _en('What to take with you'),
          body: _en('Three months of cycle dates, any previous test results '
              'even if they look old or irrelevant, a list of everything '
              'either of you takes including supplements, and — if you can — '
              'him. A first fertility appointment attended by one person '
              'investigates one person, and half of this is his.'),
        ),
      ),

      PvReadSection(
        heading: _en('Who to see'),
        paragraphs: [
          _en('In India this usually starts with a gynaecologist rather than a '
              'fertility clinic, and that is the sensible order. A general '
              'gynaecologist runs the initial workup and manages ovulation '
              'induction routinely, which is where a meaningful share of '
              'couples stop.'),
          _en('A referral onward to a fertility specialist tends to come when '
              'tablets have been tried without success, when a tubal or male '
              'factor is found, or when age makes moving faster sensible.'),
          _en('Going straight to a large fertility chain is not wrong, but be '
              'aware of what it means: their pathway is built around the '
              'treatments they provide. It is reasonable to ask, at any '
              'clinic, what the least intensive option for your situation '
              'would be.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Going to a fertility clinic means ending up on IVF.'),
          fact: _en('Most couples who are investigated do not have IVF. The '
              'workup exists to find the specific reason, and the specific '
              'reason is frequently something addressed with a tablet, a minor '
              'procedure, or a change on his side. IVF is where the pathway '
              'goes when the earlier steps do not fit — not where it starts.'),
        ),
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('We have only been trying eight months but I am '
            'anxious. Is it too early?'),
        answer: _en('No. Nothing about being seen earlier is harmful, and the '
            'first appointment is a conversation and some tests. If waiting is '
            'costing you sleep, that is itself a reasonable thing to take to a '
            'doctor.'),
      ),
      PvReadFaq(
        question: _en('Does he really need to come?'),
        answer: _en('For the semen analysis, yes, and it is worth him being at '
            'the first appointment too. Male factor is involved in about half '
            'of cases and is the single quickest thing to check — investigating '
            'only one of you can waste months.'),
      ),
      PvReadFaq(
        question: _en('What if my reports come back normal?'),
        answer: _en('That happens in a meaningful minority of couples, and it '
            'has a name — unexplained infertility. It is frustrating to hear '
            'and it is not the same as being told nothing can be done; there '
            'is a standard pathway for it, and it does not mean the tests were '
            'pointless.'),
      ),
      PvReadFaq(
        question: _en('Will they judge us for waiting this long?'),
        answer: _en('They will not, and if they do, that is information about '
            'the clinic. Most couples arrive later than the guidelines suggest, '
            'for entirely ordinary reasons.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not wait for the twelve months'),
      body: _en('Book now, rather than at the end of a waiting period, if your '
          'cycles are irregular or absent, if periods are very painful or very '
          'heavy, if sex is painful, if you have had pelvic surgery or a '
          'pelvic infection, if there have been two or more miscarriages, or '
          'if you are 36 or over. And treat it as urgent — days, not weeks — '
          'if either of you is about to start cancer treatment, because '
          'fertility preservation has to happen first.'),
    ),

    evidence: _en('Referral thresholds follow the NICE fertility guidance: '
        'referral after 12 months of regular unprotected intercourse for women '
        'under 36, referral at presentation for women 36 or over or where '
        'there is a known or suspected cause or a predisposing history, and '
        'expedited referral where planned treatment may cause infertility. '
        'Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, one by one'),
        value: _en('What each one measures, when in the cycle it is taken, and '
            'what it costs in India.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Three months of dates to take with you'),
        value: _en('The single most useful thing you can bring to a first '
            'appointment.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Speak to a fertility specialist'),
        value: _en('A first conversation, on video, before you commit to a '
            'clinic.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_ivf_explained'],
  ),

  // ===========================================================================
  //  INFERTILITY & IVF — "IUI/IVF explained"
  // ===========================================================================
  //  ⚠️ THIS IS THE READ THE DOOR HAS BEEN PROMISING AND NOT DELIVERING.
  //  The hub door "Understand my tests & treatment" says "What IUI and IVF
  //  actually involve, step by step, including what they cost", and it opened
  //  `ttc_treatment` — which is an IVF CYCLE TRACKER (stim start, trigger,
  //  retrieval, transfer, beta). Excellent for someone already in a cycle;
  //  useless to someone deciding whether to have one. The tracker is now what
  //  this read hands her at the end, which is the right order.
  PvRead(
    id: 'ttc_read_ivf_explained',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('What IUI and IVF actually involve'),
    teaser: _en('Step by step, in order, with the parts nobody warns you '
        'about — and an honest account of what each one asks of you.'),

    scaleSetter: _en('Neither of these is one event. IUI is a few scans and a '
        'two-minute procedure spread across one cycle. IVF is roughly a month '
        'of injections, monitoring and waiting, with one day under sedation in '
        'the middle. Knowing the shape of it in advance is most of what makes '
        'it manageable.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_ivf_walkthrough',

    sections: [
      PvReadSection(
        heading: _en('IUI, first — because it is much smaller'),
        paragraphs: [
          _en('Intrauterine insemination does one thing: it places prepared '
              'sperm directly into the uterus at the right moment, skipping '
              'the journey through the cervix. Everything else about the cycle '
              'is your own.'),
          _en('A cycle runs like this. Tablets or a low dose of injections at '
              'the start, to make sure a follicle develops. Two or three short '
              'scans to watch it grow. A trigger injection when it is ready, '
              'which sets ovulation to a known time. Then, a day or so later, '
              'the procedure itself — a soft catheter, about two minutes, no '
              'anaesthetic, and mild cramping at worst. You go home '
              'immediately.'),
          _en('IUI suits some situations and not others. It needs at least one '
              'open tube and reasonable sperm quality. It is often the first '
              'treatment offered for unexplained infertility, mild male '
              'factor, or where sex is difficult or infrequent — and it is '
              'usually tried for a small number of cycles before moving on, '
              'because almost all of the pregnancies it produces come in the '
              'first three.'),
        ],
      ),

      PvReadSection(
        heading: _en('IVF: the month, in order'),
        paragraphs: [
          _en('IVF replaces the whole first half of the process. Eggs are '
              'grown deliberately, collected, fertilised in a laboratory, and '
              'one embryo is put back.'),
        ],
        bullets: [
          _en('Stimulation — around ten to twelve days of daily injections '
              'you give yourself at home, to grow several follicles instead of '
              'one. Bloating and tenderness are normal by the end.'),
          _en('Monitoring — scans and blood tests every few days. This is '
              'the part people underestimate: it means repeated early-morning '
              'clinic visits, and it is the main reason IVF is difficult to '
              'combine with a rigid job.'),
          _en('Trigger — one injection at a precisely specified time, '
              'usually late at night, that matures the eggs. The timing is '
              'exact and it matters.'),
          _en('Retrieval — about twenty minutes under sedation, eggs '
              'collected with a fine needle guided by ultrasound. You are home '
              'the same day, usually sore and tired.'),
          _en('The laboratory — fertilisation happens overnight, either by '
              'mixing eggs and sperm or, in ICSI, by injecting a single sperm '
              'into each egg. Embryos are then grown for a few days, and you '
              'get a phone call each day about how many are continuing. Those '
              'calls are the hardest part of the process for many people.'),
          _en('Transfer — one embryo placed in the uterus with a fine '
              'catheter. It takes minutes, needs no anaesthetic, and feels '
              'like very little.'),
          _en('The wait — about two weeks, on progesterone support, until '
              'a blood test. Home pregnancy tests during this window are '
              'unreliable because of the trigger injection, which is why '
              'clinics ask you not to.'),
        ],
      ),

      PvReadSection(
        heading: _en('Fresh, frozen, and why so many transfers are frozen now'),
        paragraphs: [
          _en('An embryo can be transferred in the same cycle it was made — a '
              'fresh transfer — or frozen and transferred in a later, quieter '
              'cycle.'),
          _en('Freezing has become common because the stimulation that '
              'produces a good crop of eggs also leaves the uterine lining in '
              'a less receptive state, and because freezing lets the body come '
              'down before implantation is attempted. Being told your transfer '
              'will be frozen is normal practice rather than a setback, though '
              'it very often lands as one.'),
          _en('It also means a single stimulation cycle can produce several '
              'chances, which is the thing most worth understanding before you '
              'price any of it.'),
        ],
        tip: PvReadTip(
          title: _en('The question to ask about ICSI'),
          body: _en('ICSI — injecting a single sperm into each egg — is '
              'essential where sperm quality or count is the problem, and it '
              'is also applied routinely by many clinics regardless. It adds '
              'cost. It is entirely reasonable to ask: is ICSI being '
              'recommended because of our specific results, or as standard '
              'practice here?'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Necessary, and not what she came to the page for.
        collapsible: true,
        summary: _en('OHSS, the emotional shape of the two-week wait, and what '
            'the injections actually feel like.'),
        heading: _en('What it asks of you'),
        paragraphs: [
          _en('Physically, the commonest complication is ovarian '
              'hyperstimulation — the ovaries overreacting to stimulation, '
              'causing bloating, discomfort and, rarely, something that needs '
              'admission. Protocols have improved a great deal and severe '
              'cases are now uncommon, but it is the reason monitoring is '
              'frequent and the reason a cycle is sometimes cancelled or '
              'frozen partway.'),
          _en('The injections themselves are subcutaneous, fine-needled, and '
              'almost universally described as far less bad than expected. '
              'The bruising is the annoying part.'),
          _en('Emotionally, the shape is specific: a long busy stretch where '
              'you are doing something every day, then an abrupt stop into two '
              'weeks where there is nothing to do at all. Almost everyone '
              'finds the second part harder, and almost nobody is warned. '
              'Plan something for those two weeks before you reach them.'),
        ],
      ),

      PvReadSection(
        heading: _en('About the numbers you will be shown'),
        paragraphs: [
          _en('Every clinic publishes a success rate, and we deliberately do '
              'not give you one — not ours, not theirs, not an age-banded '
              'table. A single figure cannot describe your situation, and '
              'carrying one into a cycle turns it into a target you can fail.'),
          _en('What is worth knowing is how to read theirs. Ask what the '
              'denominator is: per cycle started, per retrieval, or per '
              'transfer? Those three numbers can differ enormously from the '
              'same clinic, and the most flattering one is per transfer, '
              'because it excludes every cycle that did not get that far.'),
          _en('Ask, too, whether the figure is live births or pregnancies, and '
              'for which age band. A clinic that answers all three questions '
              'without hesitating is telling you something useful about '
              'itself.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Is egg retrieval painful?'),
        answer: _en('It is done under sedation, so not during. Afterwards, '
            'expect cramping and a heavy, bloated feeling for a day or two, '
            'similar to a bad period. Most people take the day off and are '
            'fine the next.'),
      ),
      PvReadFaq(
        question: _en('How many IUI cycles before moving to IVF?'),
        answer: _en('Commonly three, sometimes up to six depending on age and '
            'cause, because the large majority of IUI pregnancies happen in '
            'the first three cycles. It is a fair question to ask at the '
            'start.'),
      ),
      PvReadFaq(
        question: _en('Can I work through an IVF cycle?'),
        answer: _en('Most people do. The constraint is not the injections, it '
            'is the monitoring — several early-morning clinic visits at short '
            'notice over about two weeks, plus one day off for retrieval. Jobs '
            'with fixed hours and no flexibility are the difficult ones.'),
      ),
      PvReadFaq(
        question: _en('Does bed rest after transfer help?'),
        answer: _en('No. Lying still afterwards has been studied and does not '
            'improve outcomes; an embryo cannot fall out. Clinics that still '
            'advise it are being kind rather than evidence-led. Ordinary '
            'activity is fine.'),
      ),
      PvReadFaq(
        question: _en('Are IVF babies different in any way?'),
        answer: _en('No meaningful difference in health or development has '
            'been shown. There is a slightly higher rate of preterm birth and '
            'low birth weight, much of which is explained by multiple '
            'pregnancies — which is precisely why single embryo transfer has '
            'become standard practice.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('During a cycle, call the clinic'),
      body: _en('Not an emergency department, and not the internet — your own '
          'clinic, which will have a number for exactly this. Call if you have '
          'marked bloating or rapid weight gain over a day or two, severe '
          'abdominal pain, breathlessness, or if you are passing much less '
          'urine than usual. These are the signs of ovarian hyperstimulation, '
          'and reported early it is very manageable. Anything about your own '
          'dose, your own scan or your own embryos belongs with the team '
          'treating you.'),
    ),

    evidence: _en('Procedure sequence, the rationale for freeze-all transfers, '
        'single embryo transfer as standard practice, and ovarian '
        'hyperstimulation as the principal complication reflect standard '
        'assisted-reproduction practice as described by ESHRE and ASRM. '
        'Reviewed August 2026. Nothing here describes your own protocol, which '
        'is set by your clinic.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('What it actually costs in India'),
        value: _en('Real ranges, what a package leaves out, and the bills that '
            'arrive separately.'),
        surfaceId: 'ttc_read/ttc_read_ivf_costs',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Track a cycle you are already in'),
        value: _en('Stim, trigger, retrieval, transfer and the test date — in '
              'one place, and shared with him.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your reports together'),
        value: _en('Every result in one place, so a second opinion takes an '
            'evening rather than a week.'),
        surfaceId: 'ttc_records',
      ),
    ],

    readNext: ['ttc_read_ivf_costs'],
  ),

  // ===========================================================================
  //  INFERTILITY & IVF — "cost expectations"
  // ===========================================================================
  //  ⚠️ ITS OWN READ, NOT A SECTION, and the Excel is the reason: "cost
  //  expectations" is listed as a distinct topic in the Content cell. It is
  //  also the single most searched aspect of this bracket and the one the app
  //  had nothing on at all — the treatment screen contains no rupee figure
  //  anywhere.
  //
  //  ⚠️ EVERY FIGURE IS DATED AND ATTRIBUTED, because fertility pricing in
  //  India is published almost entirely by the clinics selling the treatment.
  //  That does not make it useless — it makes it a range to sanity-check
  //  against rather than a quotation, and saying so is the difference between
  //  informing her and reprinting an advertisement.
  PvRead(
    id: 'ttc_read_ivf_costs',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('What it actually costs in India'),
    teaser: _en('Real ranges as of 2026, what an advertised package leaves '
        'out, and the bills that arrive separately.'),

    scaleSetter: _en('The number a clinic advertises is almost never the '
        'number you pay. It is usually the procedure fee alone, and the '
        'medicines — which are a third of the bill — are billed separately. '
        'Knowing that one thing before you walk in is worth more than any '
        'other piece of financial advice here.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Fertility treatment in India is not covered by most health '
              'insurance, is paid out of pocket, and is priced very '
              'differently from one clinic to the next. The ranges below are '
              'what clinics across the country were publishing in 2026 — '
              'treat them as a sanity check on a quotation you are given, not '
              'as a price list.'),
        ],
      ),

      PvReadSection(
        heading: _en('IUI'),
        paragraphs: [
          _en('A natural-cycle IUI, with no stimulation, is commonly quoted '
              'around ₹5,000 to ₹10,000 for the procedure. Most IUI is '
              'medicated, and a medicated cycle typically lands between '
              '₹15,000 and ₹35,000 all in, with ovulation medicines adding '
              'roughly ₹5,000 to ₹10,000 on top of the procedure fee.'),
          _en('Because IUI is usually tried for around three cycles, the '
              'figure worth budgeting is the three, not the one.'),
        ],
      ),

      PvReadSection(
        heading: _en('IVF: the honest all-in range'),
        paragraphs: [
          _en('For one complete IVF cycle in 2026, a realistic all-in figure '
              'is roughly ₹1.5 to ₹2.5 lakh at an independent clinic, and '
              '₹2 to ₹3.5 lakh at a large fertility chain in a metro. In '
              'tier-2 cities the same cycle commonly runs ₹1 to ₹1.8 lakh.'),
          _en('Against that, the packages advertised at ₹90,000 to ₹1.2 lakh '
              'are the base procedure fee: egg retrieval, fertilisation in the '
              'laboratory, and one embryo transfer. That is a real number for '
              'a real part of the treatment. It is not the cost of the '
              'treatment.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('What sits outside the package, almost always'),
          body: _en('Stimulation medicines, at roughly ₹40,000 to ₹90,000 and '
              'about a third of the final bill. ICSI, adding roughly ₹15,000 '
              'to ₹45,000. Embryo freezing and its annual storage. A frozen '
              'transfer later, which is a separate cycle with its own fee. '
              'Monitoring scans beyond the number the package includes. And '
              'the initial tests for both of you, before any of it starts.'),
        ),
      ),

      PvReadSection(
        heading: _en('The questions that change the number'),
        paragraphs: [
          _en('Ask these before you pay anything, and ask for the answers in '
              'writing. A clinic that will not put a quotation on paper has '
              'told you something.'),
        ],
        bullets: [
          _en('What exactly is in the package, and what is billed separately?'),
          _en('How many monitoring scans are included, and what does each '
              'extra one cost?'),
          _en('Is ICSI included, and is it being recommended for our results '
              'or applied as standard?'),
          _en('What is the cost of freezing, of a year of storage, and of a '
              'frozen transfer later?'),
          _en('If the cycle is cancelled before retrieval, what is refunded?'),
          _en('Are the medicines bought through the clinic or from a chemist, '
              'and may we compare?'),
        ],
        tip: PvReadTip(
          title: _en('On medicines specifically'),
          body: _en('They are the largest single variable and often the '
              'largest single line. Prices differ meaningfully between the '
              'clinic pharmacy and an outside chemist, and between brands of '
              'the same drug. Asking whether you may source them yourself is a '
              'normal question, not a rude one.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Practical and grim; needed on the day it is needed.
        collapsible: true,
        summary: _en('Insurance, EMI schemes, refund packages and the '
            'multi-cycle offers — read before signing.'),
        heading: _en('Paying for it'),
        paragraphs: [
          _en('Most Indian health insurance excludes fertility treatment '
              'outright, though a small number of employer group policies have '
              'begun including limited cover. It is worth reading your own '
              'policy wording rather than assuming, and worth asking your HR '
              'directly.'),
          _en('Many clinics offer EMI arrangements, often through a third-'
              'party lender. Check the interest rate rather than the monthly '
              'figure — the monthly figure is designed to be reassuring.'),
          _en('Multi-cycle and refund packages are increasingly common: pay '
              'more up front for two or three cycles, with a partial refund if '
              'none works. These can be genuinely good value for someone '
              'likely to need more than one cycle, and poor value for someone '
              'likely to need one. Read the exclusions closely — eligibility '
              'criteria, what counts as a cycle, and what a refund actually '
              'covers are where the detail lives.'),
        ],
      ),

      PvReadSection(
        heading: _en('One thing worth saying out loud'),
        paragraphs: [
          _en('Deciding how much to spend on this is not a medical question '
              'and nobody at a clinic can answer it for you. It is worth the '
              'two of you agreeing a number, and a point at which you would '
              'stop, before the first cycle rather than during the third.'),
          _en('That conversation is uncomfortable and it protects you. The '
              'alternative is deciding it one cycle at a time, at the moment '
              'you are least able to.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Why do quotes differ so much between clinics?'),
        answer: _en('Laboratory quality and staffing are the genuine '
            'differences, and they are real. Beyond that, much of the spread '
            'is city, brand and what has been bundled into the headline '
            'figure. A higher price is not by itself evidence of a better '
            'laboratory.'),
      ),
      PvReadFaq(
        question: _en('Is treatment abroad cheaper?'),
        answer: _en('For most people in India, no — India is already among the '
            'lower-cost countries for IVF, which is why people travel here for '
            'it. Travel, accommodation and repeat visits usually erase any '
            'difference.'),
      ),
      PvReadFaq(
        question: _en('Does a government hospital do IVF?'),
        answer: _en('Some larger public and teaching hospitals run assisted '
            'reproduction units at substantially lower cost, with waiting '
            'lists and eligibility criteria. It is worth asking about locally; '
            'availability varies a great deal by state.'),
      ),
      PvReadFaq(
        question: _en('Should we budget for more than one cycle?'),
        answer: _en('It is the more realistic way to plan, and it is why '
            'freezing matters financially — a single stimulation that produces '
            'several embryos gives several chances at the much lower cost of a '
            'frozen transfer, rather than a full cycle each time.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Before you pay a deposit'),
      body: _en('Ask for the full quotation in writing, including what is '
          'excluded and what happens to your money if the cycle is cancelled. '
          'If a clinic will not provide that, or presses you to decide the '
          'same day, treat both as reasons to get a second opinion first. '
          'Nothing about this treatment is so urgent that it cannot wait for a '
          'written quotation — and your own doctor remains the person to ask '
          'what is medically necessary in your case.'),
    ),

    evidence: _en('Cost ranges reflect prices published by Indian fertility '
        'clinics and treatment aggregators during 2026, and are given as '
        'ranges because pricing varies widely by city, clinic and inclusions. '
        '⚠️ Note the source honestly: almost all fertility pricing in India is '
        'published by the clinics that sell the treatment, so these figures '
        'are a sanity check against a quotation you are given — never a '
        'substitute for one in writing. Checked August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, with their own price ranges'),
        value: _en('What the workup costs before treatment even starts.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Get a second opinion before you commit'),
        value: _en('A fertility specialist who is not the clinic quoting you.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_when_to_seek_help'],
  ),
  // ===========================================================================
  //  GETTING READY — "pre-pregnancy diet, folic acid, weight"
  // ===========================================================================
  //  Excel Content cell: "Pre-pregnancy diet, folic acid, weight, tests &
  //  vaccinations before trying." Four topics, two reads — the first three
  //  belong together because they are one behaviour change across one window,
  //  and the fourth is a different kind of errand entirely.
  //
  //  ⚠️ CHAPTER-LOCKED AGAIN, THE THIRD TIME THIS HAS COME UP.
  //  `ttc_chapter_data.dart` chapter one carries "Folic acid, and why the
  //  timing is the whole point" and "The blood tests worth doing once", and
  //  both are good. Both are visible only to a woman the engine has placed in
  //  chapter one. Someone in the waiting days who taps "Getting ready" sees a
  //  different chapter. Same reachability gap as the fertile-window door, same
  //  two-sources-of-truth debt written down there.
  //
  //  ⚠️ AND `ttc_nutrition` IS NOT THIS. It is a day-by-day eating planner —
  //  useful, and not an answer to "what should I change before we start". A
  //  planner tells you what to eat on Thursday; this tells you why the three
  //  months matter at all.
  PvRead(
    id: 'ttc_read_three_months_before',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('The three months before'),
    teaser: _en('Why this particular window, what folic acid is actually '
        'doing, and how much weight really matters — for both of you.'),

    scaleSetter: _en('Almost nothing on this list is urgent and almost all of '
        'it is cheap. The reason it is worth doing now rather than later is '
        'timing, not effort: an egg spends about three months maturing before '
        'it is released, and sperm take about eleven weeks to make. What you '
        'change today shows up in a cycle three months from now.'),

    author: _en('Meghna Iyer'),
    authorRole: _en('Fertility nutritionist · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_three_months_before',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('There is a reason preconception advice always names three '
              'months, and it is not a round number chosen for convenience.'),
          _en('An egg is not made in the cycle it is released. It spends '
              'roughly ninety days maturing inside its follicle first. Sperm '
              'take about seventy-four days to produce, plus a couple of weeks '
              'to finish. So the sperm involved in a pregnancy this month '
              'began forming around eleven weeks ago, and the egg started '
              'maturing about three months ago.'),
          _en('This is unusually good news, and it is rarely framed that way. '
              'It means the window you can actually influence is open now, and '
              'it means nothing that happened before it is still counted '
              'against you.'),
        ],
      ),

      PvReadSection(
        heading: _en('Folic acid, and why the timing is the whole point'),
        paragraphs: [
          _en('The neural tube — which becomes the brain and spinal cord — '
              'closes in the first four weeks after conception. That is often '
              'before a period is even missed, and always before most women '
              'know. Folic acid has to already be in your body by then, which '
              'is why every guideline says start while trying rather than '
              'after a positive test.'),
          _en('FOGSI puts the standard dose at 400 to 500 micrograms a day, '
              'started at least a month before you begin trying and continued '
              'through the first trimester. It costs a few rupees a day and it '
              'is the single most evidence-backed thing anyone will suggest in '
              'this whole stage.'),
          _en('A much higher dose — 4 to 5 milligrams — is recommended for '
              'specific situations: a previous pregnancy affected by a neural '
              'tube defect, diabetes, epilepsy medication, a significantly '
              'raised BMI, thalassaemia or another haemoglobinopathy, or an '
              'MTHFR variant. That is a prescription decision, not a shelf '
              'decision.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Check what you are actually holding'),
          body: _en('Many Indian prenatal combinations sold over the counter '
              'contain 5 mg rather than 400 mcg, because that is the dose '
              'commonly prescribed in pregnancy here. That is not dangerous, '
              'but it is a twelvefold difference and worth knowing you have '
              'chosen it rather than discovering it. Read the strip.'),
        ),
      ),

      PvReadSection(
        heading: _en('Weight, honestly, in both directions'),
        paragraphs: [
          _en('Weight affects ovulation at both ends, and only one end is ever '
              'discussed. Being significantly underweight suppresses ovulation '
              'as reliably as being significantly overweight does — the body '
              'reads scarcity and stops spending energy on reproduction.'),
          _en('Where weight is raised, the figure the evidence keeps returning '
              'to is about five per cent. Not a target weight, not a BMI '
              'number — five per cent of what you currently weigh is enough to '
              'shift insulin sensitivity meaningfully, and in a real share of '
              'women that alone restores cycles.'),
          _en('And BMI reads Indian bodies badly. The thresholds were derived '
              'from European populations, and metabolic risk in South Asians '
              'appears at lower numbers — which is why waist measurement is '
              'often more informative here than the BMI figure that gets '
              'quoted at you.'),
        ],
        mythFact: PvMythFact(
          myth: _en('You need to reach a healthy BMI before you start trying.'),
          fact: _en('For most people that is neither realistic nor necessary. '
              'The evidence supports a modest, sustained change — around five '
              'per cent — rather than reaching a particular number first. '
              'Postponing trying for a year to hit a BMI target trades a small '
              'benefit for a year of age, which for many women is the worse '
              'deal.'),
        ),
      ),

      PvReadSection(
        heading: _en('What to actually eat'),
        paragraphs: [
          _en('There is no fertility diet, and anything sold as one should be '
              'treated with suspicion. What the evidence supports is a general '
              'pattern — plenty of vegetables and whole grains, pulses and '
              'other whole-food protein, some dairy, unsaturated fats, and not '
              'much ultra-processed food.'),
          _en('What matters more in India specifically is a short list of '
              'deficiencies that are genuinely common here and genuinely worth '
              'correcting.'),
        ],
        bullets: [
          _en('Iron. Anaemia is very common in Indian women of reproductive '
              'age and worth testing rather than guessing at. Pair iron-rich '
              'food with vitamin C, and keep tea and coffee away from meals — '
              'both block absorption.'),
          _en('Vitamin B12. Frequently low on a vegetarian diet, and it '
              'matters for the same neural-tube reasons folate does. A blood '
              'test settles it.'),
          _en('Vitamin D. Low in a majority of Indian adults regardless of '
              'sunshine, and cheap to correct.'),
          _en('Iodine. Use iodised salt; thyroid function and early brain '
              'development both depend on it.'),
        ],
        tip: PvReadTip(
          title: _en('The one change with the best return'),
          body: _en('Protein at breakfast. The standard Indian morning meal is '
              'carbohydrate-forward and eaten fast, and adding curd, an egg, '
              'sprouts, peanuts or a besan chilla beside it steadies the whole '
              'day. It is also the change most likely to survive a year, which '
              'matters more than any single nutrient on the list above.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Everyone already knows most of this; it is here to be
        // complete and to be specific about the Indian one, not to lecture.
        collapsible: true,
        summary: _en('Alcohol, tobacco and caffeine — what the evidence '
            'actually supports, including the one that matters most here.'),
        heading: _en('What to cut, and by how much'),
        paragraphs: [
          _en('Tobacco is the clearest. It lowers egg quality and sperm '
              'quality, brings menopause forward, and roughly doubles the risk '
              'of miscarriage. In India this specifically includes chewing '
              'tobacco, gutka and khaini, which are frequently not counted as '
              'smoking by the person using them and are just as relevant.'),
          _en('Alcohol has no established safe level in pregnancy, and while '
              'trying the honest position is that heavy drinking clearly '
              'affects fertility in both partners while the evidence on '
              'occasional drinking is much weaker. Most guidance suggests '
              'stopping once you are trying, on the grounds that you may be '
              'pregnant before you know.'),
          _en('Caffeine is the one people over-worry about. Moderate intake — '
              'around two to three cups of coffee a day — has not been shown '
              'to reduce fertility. You do not need to give up chai.'),
        ],
      ),

      PvReadSection(
        heading: _en('Half of this is his'),
        paragraphs: [
          _en('Everything above about the three-month window applies to him '
              'too, and rather more directly: sperm are made continuously, so '
              'a change in his habits shows up in a full cycle of production '
              'about eleven weeks later.'),
          _en('The list is short and mostly the same — tobacco first, alcohol '
              'second, heat third. Laptops on laps, long hot baths and tight '
              'synthetic underwear all raise scrotal temperature enough to '
              'matter, and all are easy to change.'),
          _en('If only one of you is going to do any of this, the honest '
              'answer is that it should probably be both — but the male half '
              'is the one more often skipped entirely, and it is the half that '
              'responds fastest.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Do I need an expensive prenatal, or is plain folic acid '
            'enough?'),
        answer: _en('Plain folic acid covers the thing with the strongest '
            'evidence behind it. A combined prenatal is convenient if it also '
            'covers iron, B12 and vitamin D — which is worth checking against '
            'your own blood tests rather than assuming. Price is a poor guide '
            'to what is in the strip.'),
      ),
      PvReadFaq(
        question: _en('I have been taking folic acid for years. Is that a '
            'problem?'),
        answer: _en('No. It is water-soluble and the standard dose is safe '
            'long-term. If you are on a high dose without a specific reason, '
            'that is worth raising, mainly because very high folate can mask a '
            'B12 deficiency on a blood test.'),
      ),
      PvReadFaq(
        question: _en('How long should we do all this before starting to try?'),
        answer: _en('About three months is the usual advice and it matches the '
            'biology. But do not treat it as a gate — start folic acid and '
            'start trying at the same time if that is where you are. The '
            'window is a reason to begin now, not a reason to wait.'),
      ),
      PvReadFaq(
        question: _en('Should I stop my regular medication?'),
        answer: _en('Never on your own, and this is one of the more important '
            'lines on this page. Some medicines do need changing before '
            'pregnancy and some conditions are far more dangerous untreated '
            'than the medicine ever was. Take the full list to your doctor and '
            'let them decide which is which.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Book before you start trying, not after'),
      body: _en('See a doctor first if you take regular medication of any kind '
          '— particularly for epilepsy, thyroid, diabetes, blood pressure, '
          'acne or mental health — or if you have a long-term condition, a '
          'previous pregnancy affected by a neural tube defect, or a family '
          'history of thalassaemia or another inherited condition. All of '
          'these change what dose or which drug is right, and all are far '
          'easier to sort out before conception than after it.'),
    ),

    evidence: _en('Folic acid dosing follows FOGSI Good Clinical Practice '
        'Recommendations on Preconception Care — 400 to 500 mcg daily for '
        'low-risk women started at least a month before conception, and 4 to '
        '5 mg for defined high-risk groups. Gamete maturation timelines and '
        'the deficiency priorities reflect the Indian Academy of Pediatrics '
        'consensus guidelines on preconception care (2024). Reviewed August '
        '2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Next: the tests and vaccinations'),
        value: _en('The errands worth doing once, including the two vaccines '
            'that need a month of notice.'),
        surfaceId: 'ttc_read/ttc_read_preconception_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Record what you are taking'),
        value: _en('What you started and when — the thing every doctor asks '
            'and nobody remembers.'),
        surfaceId: 'ttc_supplements',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a preconception nutritionist'),
        value: _en('A plan built around how your family actually eats, rather '
            'than a printout.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_preconception_tests'],
  ),

  // ===========================================================================
  //  GETTING READY — "tests & vaccinations before trying"
  // ===========================================================================
  //  ⚠️ THE VACCINATION HALF OF THIS DID NOT EXIST ANYWHERE IN TTC. A grep for
  //  rubella, MMR or "vaccin" across the entire stage returned nothing — while
  //  the workbook names it explicitly in this bracket's Content cell. This is
  //  the largest genuine content hole the audit found, as opposed to the
  //  reachability gaps elsewhere.
  //
  //  ⚠️ AND IT IS TIME-SENSITIVE IN A WAY ALMOST NOTHING ELSE HERE IS. Rubella
  //  and varicella are live vaccines: if she is not immune, she needs the jab
  //  AND a month of not conceiving afterwards. A woman who finds this out in
  //  her first antenatal appointment has missed the window entirely, and
  //  congenital rubella syndrome is exactly the thing it prevents.
  PvRead(
    id: 'ttc_read_preconception_tests',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('The tests and vaccinations worth doing first'),
    teaser: _en('A short list of errands, done once — including two vaccines '
        'that need a month of notice, and one blood test that matters more in '
        'India than almost anywhere else.'),

    scaleSetter: _en('This is not a fertility work-up and it is not a sign '
        'anything is wrong. It is a handful of cheap tests that are common to '
        'be abnormal in Indian adults, easy to correct, and much easier to '
        'deal with now than at eight weeks pregnant.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_preconception_tests',

    sections: [
      PvReadSection(
        heading: _en('The blood tests worth doing once'),
        paragraphs: [
          _en('None of these investigates your fertility. They look for things '
              'that are common, quiet, and fixable with a tablet — and each '
              'one is better found now than discovered six months in.'),
        ],
        bullets: [
          _en('Haemoglobin. Anaemia is very common in Indian women of '
              'reproductive age and worth correcting before pregnancy adds to '
              'the demand.'),
          _en('TSH, for thyroid. Undertreated thyroid disease affects both '
              'cycles and early pregnancy, and correction is a daily tablet.'),
          _en('Vitamin D and vitamin B12. Both frequently low here, both '
              'cheap, both easily corrected.'),
          _en('Blood sugar — fasting glucose or HbA1c. Particularly worth '
              'doing with a family history of diabetes or with PCOS.'),
          _en('Blood group and Rh type, for both of you, if you do not already '
              'know them.'),
        ],
      ),

      PvReadSection(
        heading: _en('The one that matters more in India'),
        paragraphs: [
          _en('Thalassaemia carrier screening, and the reason it stands apart '
              'is what FOGSI actually recommends: it should be offered to '
              'ALL couples, regardless of family history, at the preconception '
              'stage or the first antenatal visit.'),
          _en('That is a deliberately broad recommendation, and it is broad '
              'because carriers have no symptoms whatsoever. Beta-thalassaemia '
              'carrier rates are substantial across several Indian '
              'communities, and a carrier will typically have no idea. The '
              'situation that matters is when both partners are carriers — '
              'which is why the screening is a couple test rather than a '
              'woman test.'),
          _en('The test is a haemoglobin HPLC, widely available and '
              'inexpensive. If it is done once, in your life, this is the '
              'moment for it.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Being a carrier is not being ill'),
          body: _en('A thalassaemia carrier is healthy and stays healthy. The '
              'finding only becomes relevant if your partner is also a '
              'carrier, and even then it opens a conversation with a genetic '
              'counsellor about options — it does not close anything. Most '
              'people who screen come back clear, and those who do not are '
              'better off knowing early than late.'),
        ),
      ),

      PvReadSection(
        heading: _en('The vaccinations, and why the timing matters'),
        paragraphs: [
          _en('Start with the reassuring part, because it is true and it is '
              'almost never said: about 85 in 100 Indian women of reproductive '
              'age are already immune to rubella. For most people this whole '
              'section resolves to one blood test that comes back fine.'),
          _en('It still belongs before rather than during, because it is the '
              'one part of preconception care with an actual deadline '
              'attached — and the deadline only applies to the roughly one in '
              'seven for whom the test comes back non-immune.'),
          _en('Rubella is the important one. Caught in early pregnancy it can '
              'cause serious harm to a baby — the reason congenital rubella '
              'syndrome has its own name — and the protection is a vaccine '
              'most Indian women had as a child but few can document. The '
              'blood test that settles it is called rubella IgG, and it is '
              'worth asking for by name.'),
          _en('If you are not immune, the MMR vaccine is given and then you '
              'wait. MMR is a live vaccine, so the advice is to avoid '
              'conceiving for about a month — 28 days — after it. That is the '
              'whole reason this belongs before trying rather than after: '
              'discovering it at a first antenatal appointment means the '
              'window has already passed.'),
          _en('Varicella — chickenpox — works the same way. If you have never '
              'had it and never been vaccinated, it is two doses four weeks '
              'apart, and again a month before conceiving.'),
        ],
        tip: PvReadTip(
          title: _en('"I have already had TT injections" — the commonest '
              'confusion here'),
          body: _en('TT and Td protect against tetanus and diphtheria. They '
              'do not protect against whooping cough, and whooping cough is '
              'the one that is dangerous to a newborn in its first months. '
              'Tdap is the version that adds it, and antibodies cross the '
              'placenta to protect the baby before it can be vaccinated '
              'itself. FOGSI has recommended Tdap in pregnancy since 2014, at '
              '27 to 36 weeks — and you can have it even if you have already '
              'had two doses of TT. That is not a double dose to worry about; '
              'it is a different vaccine doing a different job.'),
        ),
      ),

      PvReadSection(
        // ⚠️ THE INDIA-SPECIFIC PARAGRAPH THIS SECTION WAS MISSING.
        //
        // The first draft described the vaccines correctly and described them
        // as though this were a country where they simply happen to you. In
        // India none of these is in the Universal Immunization Programme for
        // an adult woman — UIP gives Td at 10 and 16 and tetanus cover in
        // pregnancy, and that is all. Everything on this page is private,
        // costs money, and has to be asked for by name. Writing the clinical
        // facts without that is describing someone else's health system.
        heading: _en('None of these will be offered to you automatically'),
        paragraphs: [
          _en('This is the part that makes the difference in India. The '
              'Universal Immunization Programme covers Td at ten and sixteen, '
              'and tetanus protection during pregnancy. Adult MMR, varicella, '
              'Tdap, influenza and hepatitis B are all outside it.'),
          _en('In practice that means they are private-market vaccines: you '
              'pay for them, and — more importantly — nobody will raise them '
              'unless you do. A routine antenatal visit in most of the country '
              'will not ask whether you are rubella immune.'),
          _en('So take this page, or a written list, to the appointment. '
              'Asking for rubella IgG by name is the single most useful '
              'sentence in it.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Ask about the influenza one seasonally'),
          body: _en('Influenza vaccine is inactivated, safe in pregnancy, and '
              'recommended — but it is seasonal and its availability in India '
              'varies through the year. If you are planning to conceive, it is '
              'worth asking about whenever the current season’s vaccine is '
              'in stock rather than waiting for someone to offer it.'),
        ),
      ),

      PvReadSection(
        heading: _en('His half of the list'),
        paragraphs: [
          _en('Shorter, and routinely skipped entirely. A semen analysis is '
              'not part of a routine preconception check and is not needed '
              'unless there is a reason — but the thalassaemia screening '
              'explicitly is, because it only means anything as a pair.'),
          _en('Beyond that: his blood group, and a conversation about his own '
              'regular medications, since several common ones affect sperm '
              'production and almost nobody thinks to mention them.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Real, easily forgotten, and not what she came here for.
        collapsible: true,
        summary: _en('Dental work, the medication review, and the infection '
            'screens that are usually bundled in anyway.'),
        heading: _en('The errands nobody mentions'),
        paragraphs: [
          _en('Dental. Gum disease is associated with preterm birth, treatment '
              'is more awkward once you are pregnant, and a cleaning now is '
              'straightforward. It is the single most-forgotten item on any '
              'preconception list.'),
          _en('A medication review, which is the most important thing on this '
              'page after the rubella test. Take everything you both take — '
              'prescriptions, over-the-counter tablets, ayurvedic and herbal '
              'preparations, supplements — to a doctor in one go. Some need '
              'changing before conception; some conditions are far more '
              'dangerous untreated than the medicine ever was. That judgment '
              'is not one to make from an article.'),
          _en('HIV, syphilis and hepatitis B screening are usually included in '
              'antenatal panels anyway, and doing them before rather than '
              'during removes an anxious wait from a first appointment.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('I had MMR as a child. Do I still need the test?'),
        answer: _en('It is worth it, because immunity is what matters rather '
            'than the record — a small proportion of people vaccinated in '
            'childhood are not immune as adults, and most people cannot find '
            'their childhood card anyway. It is one line on a blood form.'),
      ),
      PvReadFaq(
        question: _en('What if I conceive by accident within the month after '
            'MMR?'),
        answer: _en('Tell your doctor, and do not panic. The one-month wait is '
            'a precaution rather than a known harm — in the cases where this '
            'has happened, no pattern of vaccine-caused congenital rubella '
            'syndrome has been found. It is not a reason to consider ending a '
            'pregnancy.'),
      ),
      PvReadFaq(
        question: _en('Is all of this expensive?'),
        answer: _en('The blood panel is modest — most of these are routine, '
            'widely available tests, and many labs bundle them. Hb HPLC for '
            'thalassaemia and rubella IgG are each inexpensive on their own. '
            'It is a one-time cost, not a recurring one.'),
      ),
      PvReadFaq(
        question: _en('Can I just do all this at my first antenatal visit '
            'instead?'),
        answer: _en('Most of it, yes. The vaccinations are the exception and '
            'they are the reason this list exists — a live vaccine cannot be '
            'given in pregnancy, so if you are not immune to rubella, the '
            'chance to fix it has gone until afterwards.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Take this list to a doctor, do not self-order it'),
      body: _en('A gynaecologist or a GP can order all of the above in one '
          'visit and, more importantly, read the results in the context of '
          'your own history. Go sooner rather than later if you take regular '
          'medication, if either family has a history of thalassaemia or '
          'another inherited condition, or if you have any long-term '
          'condition at all. And if a rubella result comes back non-immune, '
          'treat the vaccination as the thing to do this month rather than '
          'next.'),
    ),

    evidence: _en('Thalassaemia carrier screening offered to all couples '
        'irrespective of family history, via Hb HPLC at the preconception '
        'stage or first antenatal visit, follows FOGSI Good Clinical Practice '
        'Recommendations. The preconception immunisation review — rubella and '
        'varicella immunity with a minimum one-month delay before conceiving '
        'after a live vaccine, hepatitis B where indicated, and up-to-date '
        'Tdap and influenza — follows FOGSI preconception care guidance and '
        'the CDC and ASRM recommendations for patients planning pregnancy. '
        'The rubella immunity figure is from Indian serosurveys of pregnant '
        'women, which put seroprevalence at roughly 85 per cent in 2022 and '
        '82 to 83 per cent in the 2017 and 2019–20 rounds. Reviewed August '
        '2026.'),

    nextSteps: [
      // ⚠️ THE VACCINATION TOOL FIRST, NOT THE TEST LIBRARY. This read's whole
      // point is that vaccination has a deadline; the screen is where that
      // deadline is actually tracked, and reading about it without recording
      // anything is how a woman ends up learning it twice.
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Check your vaccinations'),
        value: _en('Which to ask for by name, and whether anything on the '
            'list means waiting a month.'),
        surfaceId: 'ttc_vaccinations',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The full test library'),
        value: _en('Every test explained, when in the cycle to take it, and '
            'what it costs in India.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep the reports together'),
        value: _en('One place for all of it, so the next doctor sees the whole '
            'picture in a minute.'),
        surfaceId: 'ttc_records',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Back to: the three months before'),
        value: _en('Diet, folic acid and weight — the other half of getting '
            'ready.'),
        surfaceId: 'ttc_read/ttc_read_three_months_before',
      ),
    ],

    readNext: ['ttc_read_three_months_before'],
  ),
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
  // ===========================================================================
  //  AFTER A LOSS — the two reads, and the rules they are written under
  // ===========================================================================
  //  Excel Content cell: "Physical recovery, when it is safe to try again,
  //  emotional support." Three topics, two reads — the second and third are one
  //  decision rather than two, because "when is it safe" and "when am I ready"
  //  are asked in the same breath and answered by different people.
  //
  //  ---------------------------------------------------------------------------
  //  ⚠️ THE MOST CONSTRAINED BRACKET IN THE STAGE. FIVE OF ITS SEVEN LAYERS SAY
  //  "NOT A FIT" AND EVERY REFUSAL IS RIGHT.
  //  ---------------------------------------------------------------------------
  //
  //  No product row. No course card. No consult upsell dressed as a next step.
  //  No tracker, no checklist, no habit. A woman who has just lost a pregnancy
  //  is shown a person and, if she wants it, other people.
  //
  //  ⚠️ AND NO CHEERFUL LANGUAGE ANYWHERE. The house tone across the rest of
  //  this stage is warm; here it is quiet. Short sentences. No encouragement,
  //  no "you've got this", no silver lining, and above all no timeline
  //  presented as a rule she is behind on. `kTtcAfterLoss` states this and the
  //  journey is two steps long for the same reason — padding a grieving
  //  woman's screen with more would be the injury, not the care.
  //
  //  ⚠️ THE SCALE-SETTER IS NOT REASSURANCE HERE. Everywhere else in this
  //  library it answers "how worried should I be". That is not her question.
  //  Hers is closer to "what happens now" and "was this my fault", and the
  //  field is used to answer those instead.
  PvRead(
    id: 'ttc_read_loss_recovery',
    hue: 26,
    kicker: _en('After a loss'),
    title: _en('Physical recovery, in plain terms'),
    teaser: _en('What the body does over the next few weeks, what is normal, '
        'and the small number of things that need a doctor today.'),

    scaleSetter: _en('Most of what follows is bleeding that settles, hormones '
        'that fall, and a cycle that starts again. It usually takes a few '
        'weeks. Very little of it needs intervention, and none of it is '
        'something you caused.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_loss_recovery',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('This page is only about the body. It is here because the '
              'physical side is the part nobody explains and the part that '
              'generates the most fear at two in the morning.'),
          _en('The rest of it — the part that is not about the body — does not '
              'have a timeline and is not on this page.'),
        ],
      ),

      PvReadSection(
        heading: _en('The bleeding'),
        paragraphs: [
          _en('Bleeding usually lasts one to two weeks, heavier than a period '
              'at first and then tapering. Cramping through the first few days '
              'is expected, and can be strong.'),
          _en('How this went depends on how it was managed. If it happened on '
              'its own, bleeding tends to be heaviest early. If you took '
              'medication, it usually begins within a few hours of the second '
              'dose. If you had a surgical procedure — a D&C, or vacuum '
              'aspiration — bleeding is often lighter and shorter than either '
              'of the others.'),
          _en('Some spotting on and off for another week or two after the main '
              'bleeding stops is common and is not a sign that something has '
              'gone wrong.'),
        ],
      ),

      PvReadSection(
        heading: _en('Hormones, and the pregnancy test'),
        paragraphs: [
          _en('hCG — the pregnancy hormone — falls over days to weeks rather '
              'than immediately. A home test can stay positive for two to four '
              'weeks afterwards, sometimes longer.'),
          _en('This catches people badly, and it is worth knowing in advance: '
              'a positive test after a loss is almost always the hormone '
              'clearing, not a continuing pregnancy. If you are going to test '
              'at all, it is better done because a doctor asked for it than '
              'out of hope at home.'),
          _en('Breast tenderness and nausea usually ease within about a week '
              'as the levels fall. Some people find that these fading is its '
              'own kind of difficult, and that is not unusual.'),
        ],
      ),

      PvReadSection(
        heading: _en('When the cycle comes back'),
        paragraphs: [
          _en('The first period usually arrives four to eight weeks after the '
              'loss, counting from when the bleeding began. It is often '
              'heavier than usual, sometimes with more clotting, and it can be '
              'more painful. That is expected and it settles over the next '
              'cycle or two.'),
          _en('Ovulation typically returns before that first period — often '
              'around two to four weeks after the loss — which means pregnancy '
              'is possible again before you have had a period at all.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Which matters if you are not ready'),
          body: _en('Because ovulation can return before the first period, it '
              'is worth using contraception if you would not want to conceive '
              'yet. This is not usually mentioned, and finding out afterwards '
              'is worse than reading it here.'),
        ),
      ),

      PvReadSection(
        heading: _en('If you had a procedure'),
        paragraphs: [
          _en('After a D&C or vacuum aspiration, the usual advice is to avoid '
              'putting anything in the vagina — tampons, menstrual cups, sex — '
              'for around two weeks, while the cervix closes. Swimming and '
              'baths are usually included in that; showers are fine.'),
          _en('Light activity is fine as soon as you feel able. There is no '
              'evidence that resting more improves recovery, and no evidence '
              'that ordinary movement harms it.'),
          _en('A follow-up appointment is normal practice and worth keeping '
              'even if you feel physically fine — it is where anything '
              'incomplete gets picked up, and where the conversation about '
              'what happens next can start if you want it to.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Real and worth having, and reading it on day two is not
        // what most people need. The fold is care, not omission.
        collapsible: true,
        summary: _en('Rh status, and what happens if some tissue is left '
            'behind — the two follow-ups that get missed.'),
        heading: _en('Two things that get missed'),
        paragraphs: [
          _en('Rh status. If your blood group is Rh negative, you may need an '
              'anti-D injection after a pregnancy loss, and the timing matters '
              '— usually within seventy-two hours. It protects future '
              'pregnancies rather than this one. If nobody has mentioned your '
              'blood group, ask.'),
          _en('Retained tissue. Occasionally some pregnancy tissue stays '
              'behind, which shows up as bleeding that does not settle, '
              'bleeding that restarts heavily after stopping, or a persistent '
              'positive test weeks later. It is straightforward to diagnose '
              'with a scan and straightforward to treat, and it is the '
              'commonest reason a recovery takes longer than expected.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Did anything I did cause this?'),
        answer: _en('No. The great majority of early losses are caused by a '
            'chromosomal error present from the beginning — a random event in '
            'a single cell, not something inherited and not something either '
            'of you influenced. Working, exercising, lifting, stress, an '
            'argument, travel, sex, a missed vitamin: none of these cause '
            'miscarriage. This question is asked by almost everyone, and the '
            'answer is the same every time.'),
      ),
      PvReadFaq(
        question: _en('How long until I feel physically normal?'),
        answer: _en('Most people feel physically recovered within two to four '
            'weeks, and tired for longer than they expect — bleeding of any '
            'length is depleting, and grief is physically exhausting on its '
            'own. If you were further along, it takes longer.'),
      ),
      PvReadFaq(
        question: _en('Is it normal that my milk came in?'),
        answer: _en('After a later loss, yes, and it can be very distressing '
            'when it is not expected. It settles over a few days. A firm bra, '
            'cold compresses and avoiding expressing are the usual advice, and '
            'there is medication that can help if it is severe — ask.'),
      ),
      PvReadFaq(
        question: _en('When can we have sex again?'),
        answer: _en('Physically, once bleeding has stopped and any procedure '
            'has had about two weeks — the usual advice is to wait for the '
            'cervix to close. Beyond that there is no medical reason to wait, '
            'and there is often a reason that has nothing to do with '
            'medicine.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go to a hospital today, not tomorrow'),
      body: _en('Soaking through more than two thick pads in an hour for two '
          'hours running, or passing clots larger than a lemon. A fever above '
          '38°C. Severe pain that painkillers do not touch, or pain in one '
          'shoulder tip. Discharge that smells offensive. Feeling faint, or '
          'fainting. These are signs of heavy bleeding or infection, both of '
          'which are treatable and neither of which should wait for a morning '
          'appointment. Trust yourself on this — if something feels wrong, be '
          'seen.'),
    ),

    evidence: _en('Bleeding duration, hCG clearance, return of ovulation '
        'before the first period, and the four-to-eight-week window for '
        'menstruation returning reflect standard early-pregnancy-loss guidance '
        'as described by NICE, RCOG and the American Pregnancy Association. '
        'Anti-D prophylaxis timing per standard obstetric practice. Reviewed '
        'August 2026.'),

    nextSteps: [
      // ⚠️ COMMUNITY FIRST, AND NO PRODUCT ROW OF ANY KIND. The workbook marks
      // products, tools, activities and course all "Not a fit" on this
      // bracket. The one layer it actively wants is a person.
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('On trying again'),
        value: _en('When it is safe, what the evidence actually says about '
            'waiting, and who decides.'),
        surfaceId: 'ttc_read/ttc_read_trying_again',
      ),
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en('Others who have been here'),
        value: _en('People who have been exactly here, whenever you want '
            'them. Or not at all.'),
        surfaceId: 'ttc_community',
      ),
    ],

    readNext: ['ttc_read_trying_again'],
  ),

  // ===========================================================================
  //  AFTER A LOSS — "when it is safe to try again", and the emotional half
  // ===========================================================================
  //  ⚠️ NO HERO VIDEO ON THIS ONE, DELIBERATELY, and it is the only read in the
  //  library without one. A play control at the top of a page about whether she
  //  is ready to try again is the wrong texture — it makes the page feel
  //  produced at the moment it most needs to feel written. The physical
  //  recovery piece carries the film for this bracket; this one is words.
  //
  //  ⚠️ THE CORRECTION IN HERE IS WORTH DEFENDING. Many Indian clinicians still
  //  say wait three to six months, on the strength of a WHO recommendation from
  //  2007 that rests on a single study. Larger cohorts since have not found the
  //  harm it assumed. Saying so is not contradicting her doctor — CLAUDE.md
  //  forbids that, and this page does not tell her to ignore anyone. It tells
  //  her the question is open, so that she can ask it rather than assume the
  //  waiting is settled fact.
  PvRead(
    id: 'ttc_read_trying_again',
    hue: 26,
    kicker: _en('After a loss'),
    title: _en('On trying again'),
    teaser: _en('What the evidence says about waiting, what your body needs, '
        'and the part no evidence can answer.'),

    scaleSetter: _en('There are two questions here and they get muddled '
        'together. When is it physically safe is a medical question with a '
        'reasonably clear answer. When are you ready is not a medical question '
        'at all, and nobody — including us — gets to answer it for you.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    sections: [
      PvReadSection(
        heading: _en('The six-month advice, and where it came from'),
        paragraphs: [
          _en('Many people are told to wait three to six months. That advice '
              'traces back to a World Health Organization recommendation from '
              '2007, which rested largely on a single study.'),
          _en('Larger studies since have not found the harm it assumed. A '
              'Norwegian cohort of nearly seventy-three thousand pregnancies '
              'found no increased risk of complications when women conceived '
              'within six months of a miscarriage — and some analyses have '
              'found slightly better outcomes in that group, not worse.'),
          _en('So the current position, for an early loss with no '
              'complications, is that there is no medical reason to wait '
              'months. Many clinicians now suggest waiting for one normal '
              'period, and the reason is practical rather than protective: it '
              'makes dating a next pregnancy much easier.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('If your doctor has told you to wait'),
          body: _en('There may be a specific reason — a later loss, an '
              'infection, a procedure, a molar pregnancy, or something in your '
              'own history. Ask what the reason is rather than assuming it is '
              'the general advice. If it is the general advice, it is '
              'reasonable to say you have read that the evidence has moved. '
              'This page is not a reason to disregard your own doctor.'),
        ),
      ),

      PvReadSection(
        heading: _en('It was almost certainly not preventable'),
        paragraphs: [
          _en('Around one in five to one in four recognised pregnancies ends '
              'in miscarriage, and the great majority of early losses are '
              'caused by a chromosomal error present from the moment of '
              'fertilisation. Not inherited. Not caused. Not preventable, by '
              'anything anyone could have done differently.'),
          _en('This matters for trying again specifically, because the most '
              'common private theory is that something was done wrong and must '
              'now be done right. There is usually nothing to correct.'),
          _en('It also means that after one loss, the odds for a next '
              'pregnancy are essentially what they were before. A miscarriage '
              'is not a pattern.'),
        ],
      ),

      PvReadSection(
        heading: _en('When investigation is worth asking for'),
        paragraphs: [
          _en('After two losses. ESHRE moved this threshold — recurrent '
              'pregnancy loss is now defined as two or more, not necessarily '
              'consecutive, and investigation can reasonably start there.'),
          _en('That is a change worth knowing about, because older practice '
              'in many places still waits for three. If you have had two and '
              'are told to try again before anything is looked into, asking '
              'about the two-loss threshold is a fair question rather than a '
              'demanding one.'),
          _en('Investigation typically looks at hormones including thyroid, '
              'antiphospholipid antibodies, the shape of the uterus, and — '
              'depending on the picture — chromosomal testing for both of you. '
              'A cause is found in about half of couples, and the half where '
              'nothing is found still go on to have live births more often '
              'than not.'),
        ],
      ),

      PvReadSection(
        heading: _en('The part that is not medical'),
        paragraphs: [
          _en('There is no correct interval, and there is no version of this '
              'where being ready sooner or later means anything about you.'),
          _en('Some people want to try immediately, and find that the next '
              'attempt is what makes the waiting bearable. Some cannot face it '
              'for a long time. Some find that the two of them do not want the '
              'same thing at the same time, which is common and is worth '
              'saying out loud rather than negotiating silently.'),
          _en('It is also worth knowing that a next pregnancy after a loss is '
              'often frightening rather than joyful, particularly up to the '
              'point where the previous one ended. That is not a bad sign and '
              'it is not ingratitude. It is extremely common, it has a name in '
              'the literature, and it usually eases.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Practical, and not everyone wants it.
        collapsible: true,
        summary: _en('What to do differently next time — a short list, and a '
            'shorter one than the internet suggests.'),
        heading: _en('If and when you do try again'),
        paragraphs: [
          _en('Restart folic acid if you stopped, and keep taking it. Have any '
              'long-term condition — thyroid, diabetes, blood pressure — '
              'reviewed, because control matters more before conception than '
              'after it. And if either of you smokes, this is the change with '
              'the clearest evidence behind it.'),
          _en('Beyond that, the honest list is short. Most of what is sold and '
              'recommended after a loss — supplements, aspirin, progesterone, '
              'restricted activity — has either no evidence behind it or '
              'applies only to specific diagnosed situations. Progesterone in '
              'particular has a genuine but narrow role, and it is not a '
              'general precaution.'),
          _en('There is no need to do more than this, and doing more will not '
              'make it more likely to work.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Should I wait for one period, or can we try straight '
            'away?'),
        answer: _en('For an early, uncomplicated loss, physically there is no '
            'strong reason to wait beyond bleeding stopping. Waiting for one '
            'period makes dating a next pregnancy easier, which is the usual '
            'reason it is suggested. Either is reasonable.'),
      ),
      PvReadFaq(
        question: _en('Are we more likely to lose another one?'),
        answer: _en('After a single loss, the chance for a next pregnancy is '
            'close to what it was before — one loss does not make a pattern. '
            'The picture changes after two or more, which is exactly why the '
            'investigation threshold sits there.'),
      ),
      PvReadFaq(
        question: _en('My partner seems fine. Is that normal?'),
        answer: _en('Common, and it is very often not what it looks like. '
            'Grief after a loss is frequently asynchronous — one person '
            'processes early and one later, and the one who seems fine is '
            'often holding it together on purpose. It is worth asking rather '
            'than concluding.'),
      ),
      PvReadFaq(
        question: _en('I do not want to try again. Is that allowed?'),
        answer: _en('Yes. Not trying again is a whole and legitimate outcome, '
            'not a failure to recover, and it does not need to be permanent to '
            'be respected right now.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Some of this needs a person, not a page'),
      body: _en('Ask for a referral if you have had two or more losses, if a '
          'loss happened after twelve weeks, if it was ectopic or molar, or if '
          'you have a known condition like thyroid disease or a clotting '
          'disorder. And speak to someone — a counsellor, your doctor, anyone '
          '— if grief is not shifting at all after several weeks, if you '
          'cannot sleep or function, or if you have thoughts of harming '
          'yourself. That last one is not a reason to wait for an appointment; '
          'it is a reason to tell someone today.'),
    ),

    evidence: _en('The six-month interval originates in a 2007 WHO '
        'recommendation based on limited evidence; the absence of increased '
        'risk with a shorter interval is from a Norwegian cohort study of '
        'approximately 73,000 pregnancies following miscarriage or induced '
        'abortion (2008–2016), published in PLOS Medicine, and consistent with '
        'subsequent systematic reviews. The two-loss threshold for '
        'investigation follows the ESHRE guideline on recurrent pregnancy '
        'loss. Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en('Others who have been here'),
        value: _en('People who have been exactly here, whenever you want '
            'them. Or not at all.'),
        surfaceId: 'ttc_community',
      ),
      // ⚠️ THE ONE PAID THING THIS BRACKET ALLOWS, AND IT IS NAMED AS A PERSON.
      // The workbook wants counselling and a gynae here — the only layer it
      // actively asks for. It is placed last, described as a conversation, and
      // carries no price in its blurb.
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talking to someone who does this'),
        value: _en('A counsellor who works with pregnancy loss, or a doctor '
            'who can look at what happened. At your pace.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_loss_recovery'],
  ),
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
        'from meta-analyses of mind-body interventions. ⚠️ We are not aware of '
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

/// Lookup by id. Null is a real answer — see `ttc_surface_router.dart`.
PvRead? ttcReadById(String id) {
  for (final r in kTtcReads) {
    if (r.id == id) return r;
  }
  return null;
}

/// Title for a read-next card, without handing the reader the whole library.
LocalizedText? ttcReadTitle(String id) => ttcReadById(id)?.title;
