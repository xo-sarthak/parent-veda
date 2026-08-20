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
    // inside section 4, where it is relevant. Repeating it in the foot rail
    // would show the same film twice on one page.
    //
    // ⚠️ NO `readNext` UNTIL `ttc_read_pcos_food` IS WRITTEN. A dangling id
    // resolves to null, which renders the "Read next" heading over nothing —
    // the empty-promise shape this whole build is removing.
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
