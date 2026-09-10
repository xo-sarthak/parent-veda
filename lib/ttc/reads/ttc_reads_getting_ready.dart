// =============================================================================
//  Getting ready — the reads for this door
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

final List<PvRead> kTtcReadsGettingReady = [
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
  //  Folic acid
  // ---------------------------------------------------------------------------
  //  ITS OWN PIECE RATHER THAN A SECTION INSIDE "Three months before". That
  //  article covers folic acid among eight other things, and a tile promising
  //  "Folic acid: why she needs it" that opens a general preparation piece is
  //  the wrong-screen failure this stage keeps writing tests about.
  PvRead(
    id: 'ttc_read_folic_acid',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Folic acid: why she needs it before, not after'),
    teaser: _en('The one item on the whole preparation list with the strongest '
        'evidence behind it, and the one whose timing is most often missed.'),
    scaleSetter: _en('This is cheap, sold in every chemist, and the single most '
        'useful thing anyone reading this can start today. It is also not '
        'urgent in the frightening sense: starting a month before conceiving '
        'covers what matters, and nobody who started late has done harm they '
        'need to carry.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Folic acid is the manufactured form of folate, a B vitamin the '
              'body uses to build new cells. In very early pregnancy it does '
              'one specific job: it supports the closing of the neural tube, '
              'the structure that becomes the brain and the spinal cord.'),
          _en('That closing happens in the first four weeks after conception, '
              'which is the whole reason this article exists.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why the timing is the point'),
        paragraphs: [
          _en('Four weeks after conception is roughly the moment a period is '
              'missed. So for most women, the window folic acid protects has '
              'already closed by the time a test turns positive.'),
          _en('Starting when you find out is not useless, because folate keeps '
              'doing other work throughout pregnancy. But the specific '
              'protection this vitamin is known for has to already be in '
              'place. That is why every guideline says to start before '
              'conceiving, ideally at least a month before.'),
          _en('If a pregnancy was not planned, or you started late, start now '
              'and do not spend anything on guilt. Most pregnancies where '
              'folic acid began late are entirely fine.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('The evidence here is unusually strong'),
          body: _en('Folic acid taken before conception reduces the risk of '
              'neural tube defects substantially. This is one of the clearest '
              'findings in preventive obstetrics, replicated across decades '
              'and used to justify flour fortification in dozens of countries.'),
        ),
      ),
      PvReadSection(
        heading: _en('How much, and which one'),
        paragraphs: [
          _en('The usual amount is 400 micrograms a day, taken from at least a '
              'month before conceiving through the first twelve weeks.'),
          _en('Plain folic acid is what the evidence was built on. A '
              'preconception multivitamin containing 400 mcg is equally fine, '
              'and often easier to remember. What you should not do is take a '
              'general multivitamin without checking it, because some contain '
              'vitamin A as retinol, which is not recommended in pregnancy.'),
          _en('Food helps but does not replace it. Dal, spinach, methi, '
              'chickpeas, citrus and fortified cereals all carry folate, and '
              'almost nobody reaches the protective amount from diet alone.'),
        ],
      ),
      PvReadSection(
        heading: _en('When a much higher dose is advised'),
        paragraphs: [
          _en('Some women are advised 5 milligrams a day rather than 400 '
              'micrograms, more than ten times the standard amount. That is a '
              'prescription decision, not a shelf decision.'),
          _en('It is usually considered where there has been a previous '
              'pregnancy affected by a neural tube defect, or where the mother '
              'has diabetes, epilepsy treated with certain medicines, coeliac '
              'disease, sickle cell disease, or a high BMI.'),
          _en('If any of those apply to you, raise it at your next appointment '
              'rather than adjusting the dose yourself.'),
        ],
      ),
      PvReadSection(
        heading: _en('What else is worth taking, and what is not'),
        paragraphs: [
          _en('Vitamin D is the other one with reasonable support. Deficiency '
              'is very common in India, including in people who spend time '
              'outdoors, because clothing, air quality and skin tone all '
              'reduce how much is made. Ten micrograms a day is the usual '
              'recommendation, and a blood test will tell you if you need '
              'more.'),
          _en('Iodine matters for the baby\'s developing brain and is easy to '
              'cover: iodised salt in ordinary cooking is enough for most '
              'people.'),
          _en('Iron is worth checking rather than assuming. Anaemia is common '
              'and it makes pregnancy harder, but taking iron you do not need '
              'causes constipation and nausea for no benefit. A blood count '
              'settles it.'),
          _en('What is not worth buying is the long tail of fertility blends '
              'sold with confident language and no evidence: coenzyme Q10, '
              'inositol outside PCOS, royal jelly, most herbal mixes. Some are '
              'harmless and expensive. A few interact with real medicines, '
              'which is why anything you are taking is worth mentioning at an '
              'appointment even when it came from a health shop rather than a '
              'pharmacy.'),
        ],
      ),

      PvReadSection(
        heading: _en('What about him'),
        paragraphs: [
          _en('Folate has a role in sperm production too, and it appears in '
              'most male preconception supplements for that reason. The '
              'evidence there is much weaker than the evidence for the neural '
              'tube, and it is not a substitute for the three things that do '
              'have evidence on his side: not smoking, drinking moderately, '
              'and keeping heat down.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask before you change the dose'),
      body: _en('If you have epilepsy, diabetes, coeliac disease, a previous '
          'pregnancy affected by a spinal problem, or you are already on other '
          'supplements or medicines, ask a doctor what dose is right for you '
          'before starting. This is one of the few places where more is '
          'sometimes genuinely better, and it is a decision that needs your '
          'history rather than an article.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('I have taken it for months and I am not pregnant yet. '
            'Is that a problem?'),
        answer: _en('No. Folic acid is not a fertility treatment and does not '
            'affect how quickly you conceive. It is protection held ready for '
            'whenever conception happens, and there is no harm in taking it '
            'for a long time at the standard amount.'),
      ),
      PvReadFaq(
        question: _en('Can I just eat more spinach instead?'),
        answer: _en('Not reliably. Food folate is absorbed less efficiently '
            'than the supplement form, and reaching the protective amount from '
            'diet alone is difficult. Eat the greens as well, not instead.'),
      ),
      PvReadFaq(
        question: _en('Is there harm in taking it if I stop trying?'),
        answer: _en('At 400 mcg, no. It is water-soluble and the excess is '
            'passed out. The caution is only about very high doses taken '
            'without a reason.'),
      ),
    ],
    evidence: _en('NICE guideline NG201 (antenatal care); WHO recommendations '
        'on antenatal care; RCOG and NHS preconception folic acid guidance; '
        'Cochrane review of periconceptional folate supplementation.'),
  ),
  // ===========================================================================
  //  ⚠️ WRITTEN 2026-09-03 FOR THE GETTING-READY REBUILD
  // ---------------------------------------------------------------------------
  //  The door's brief asked for five new pieces. Four are here; the fifth —
  //  "The carrier screening that matters in India" — is deliberately NOT
  //  written. The brief itself says to confirm which screen is meant before it
  //  goes into copy, and naming a specific medical test is the one place in
  //  this door where guessing is not a style choice. See docs/STILL-OPEN.md.
  //
  //  ⚠️ AND NONE OF THESE SCARE ANYBODY INTO ANYTHING. This is the calmest
  //  door in the stage — nobody here has a problem yet, they are getting ready
  //  — so the tone that works in the IVF door would be wrong in this one. Every
  //  piece below says what is worth doing, says plainly what does not matter
  //  much, and none of them implies that a delay is her fault.
  // ===========================================================================

  PvRead(
    id: 'ttc_read_what_to_cut',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('What to cut before trying'),
    teaser: _en('A short list, and it is shorter than the internet suggests. '
        'Three things that genuinely matter, and several that do not.'),
    scaleSetter: _en('Most of what circulates as "must give up before trying" '
        'has little behind it, and worrying about all of it is its own cost. '
        'Three changes have real evidence. The rest of this piece is mostly '
        'about the things you can stop feeling guilty about.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('There is a version of getting ready that turns into a list of '
              'bans, and it makes people miserable without making them more '
              'likely to conceive. This is the other version.'),
          _en('Three things are worth changing, and they are worth changing '
              'for both of you rather than for her alone. Everything after '
              'that is optional, and some of it is folklore.'),
        ],
      ),
      PvReadSection(
        heading: _en('Smoking, and being around it'),
        paragraphs: [
          _en('This is the one with the least argument around it. Smoking '
              'affects fertility in both partners — it is associated with '
              'taking longer to conceive, with lower egg reserve, and with '
              'poorer sperm quality and movement. It also raises the risk of '
              'miscarriage once a pregnancy starts.'),
          _en('Second-hand smoke counts. Somebody who does not smoke but '
              'shares a home or a car with somebody who does is still exposed, '
              'which is one of several reasons this is not a woman-only item.'),
          _en('Stopping is genuinely difficult and willpower is not the whole '
              'story. Nicotine replacement, prescribed support and quitlines '
              'exist because stopping unaided works for a minority. If you '
              'have tried and it did not hold, that is the usual outcome of '
              'trying alone, not a verdict on you.'),
        ],
      ),
      PvReadSection(
        heading: _en('Alcohol, honestly'),
        paragraphs: [
          _en('The clear part first: once pregnant, no amount is established as '
              'safe, and since a pregnancy is not visible for several weeks, '
              'guidance in most countries is to stop while trying rather than '
              'to stop on a positive test.'),
          _en('The less clear part: whether light drinking affects how quickly '
              'you conceive is genuinely contested. Heavy drinking is '
              'associated with taking longer; the evidence at low levels is '
              'mixed, and honest guidance says so rather than inventing '
              'certainty to make the advice tidier.'),
          _en('What that means in practice is that cutting down is worth '
              'doing, and that a glass at a wedding four months ago is not '
              'something to lie awake about. For him, heavy drinking is '
              'associated with poorer semen quality; ordinary amounts are less '
              'clear there too.'),
        ],
      ),
      PvReadSection(
        heading: _en('Caffeine, in moderation rather than not at all'),
        paragraphs: [
          _en('Most guidance lands on limiting rather than stopping. The '
              'commonly cited ceiling is about 200 mg a day in pregnancy, '
              'which is roughly two mugs of instant coffee — and Indian filter '
              'coffee and strong tea both count toward it.'),
          _en('It is worth knowing what else carries it. Cola, energy drinks, '
              'green tea and dark chocolate all contribute, and several '
              'over-the-counter painkillers contain caffeine without saying so '
              'loudly on the front.'),
          _en('Going to zero is not required and going cold turkey usually '
              'produces three days of headache, which helps nobody. Cutting '
              'from four cups to two is the change that matters.'),
        ],
      ),
      PvReadSection(
        heading: _en('The things you can stop worrying about'),
        paragraphs: [
          _en('Spicy food does not affect fertility. Papaya and pineapple do '
              'not either, in the amounts a person eats — the enzyme stories '
              'attached to both come from laboratory quantities, not from a '
              'bowl of fruit.'),
          _en('Ordinary exercise is good for you and does not need to stop. '
              'Warm baths are fine for her; heat matters more for him, and '
              'even there the effect is modest and reversible.'),
          _en('Sex does not need rationing to "save up" — for most couples, '
              'every day or every other day around the fertile window is fine, '
              'and abstaining for long stretches does not improve anything.'),
          _en('And none of this is a reason to audit the last six months. What '
              'you did before you decided to try is not a factor you can '
              'change and is very unlikely to be the reason for anything.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to do about the things you cannot cut'),
        paragraphs: [
          _en('Some exposures are not lifestyle choices. Working with solvents, '
              'pesticides, some paints, lead or certain industrial chemicals '
              'is worth mentioning to a doctor, because the answer may be '
              'protective equipment or a temporary change rather than leaving '
              'a job.'),
          _en('The same is true of prescribed medicines. Do not stop anything '
              'you were told to take in order to be "clean" before trying — '
              'the risk of stopping a medicine that manages a real condition is '
              'usually larger than the risk of continuing it. That is a '
              'conversation, not a decision to make alone.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not stop a prescribed medicine to prepare'),
      body: _en('If you take something regularly — for thyroid, blood '
          'pressure, epilepsy, diabetes, mental health or anything else — talk '
          'to the doctor who prescribed it before changing a thing. Some are '
          'swapped for a different one before pregnancy, some are continued '
          'unchanged, and stopping suddenly is the option that is almost never '
          'right. If you are trying to stop smoking or drinking and it is not '
          'holding, ask for help rather than trying harder alone.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Does he have to stop too?'),
        answer: _en('For smoking, yes, and for the same reasons plus one more: '
            'she is exposed to it. For alcohol, heavy drinking is worth '
            'cutting. Beyond that, doing it together mostly helps because it '
            'is easier than doing it alone.'),
      ),
      PvReadFaq(
        question: _en('How long before trying should I change things?'),
        answer: _en('Sperm take roughly two to three months to develop, so '
            'changes on his side show up on about that timescale. On her side '
            'there is no waiting period — earlier is better and starting today '
            'is fine.'),
      ),
      PvReadFaq(
        question: _en('I drank before I knew I was pregnant. What now?'),
        answer: _en('Tell your doctor, honestly, and then stop. This is common, '
            'the doctor has heard it many times, and the useful response is '
            'stopping now rather than counting backwards.'),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems: assessment and treatment); '
        'NHS preconception guidance; RCOG statements on alcohol and on '
        'smoking in pregnancy; the UK Chief Medical Officers’ alcohol '
        'guidelines; EFSA opinion on caffeine intake. Reviewed August 2026.'),
    readNext: ['ttc_read_three_months_before'],
  ),

  PvRead(
    id: 'ttc_read_supplement_timing',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('When to start what, and how early'),
    teaser: _en('Folic acid has a deadline that has already passed by the time '
        'most people find out. Almost nothing else does.'),
    scaleSetter: _en('This is a timing question rather than a shopping list. '
        'One supplement genuinely needs to be started before you conceive, a '
        'couple are worth checking your levels for, and most of the rest are '
        'sold on hope. Nothing here replaces asking a doctor what YOU need.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The supplement aisle is designed to make you feel late. Most of '
              'it is not urgent and some of it is not useful — but one thing '
              'genuinely is time-sensitive, and it is worth separating that '
              'from everything else.'),
        ],
      ),
      PvReadSection(
        heading: _en('Folic acid: at least a month before, ideally three'),
        paragraphs: [
          _en('This is the one with a real deadline. The neural tube — which '
              'becomes the brain and spinal cord — closes in the first few '
              'weeks, often before a period is missed. Folic acid has to '
              'already be in your system when that happens, which is why '
              'starting on a positive test is starting late.'),
          _en('Guidance is to begin at least one month before conception and '
              'to continue through the first twelve weeks. Three months ahead '
              'is a comfortable margin rather than a requirement.'),
          _en('The standard amount is 400 micrograms daily. A higher dose is '
              'advised for some people — a previous pregnancy affected by a '
              'neural tube defect, diabetes, epilepsy medication, certain '
              'absorption conditions, and higher body weight in some guidance '
              '— and that is a prescription decision, not a shelf decision.'),
          _en('If you are already pregnant and have not been taking it, start '
              'today. Later is better than not at all, and nobody needs a '
              'lecture about the weeks already gone.'),
        ],
      ),
      PvReadSection(
        heading: _en('Vitamin D: worth checking, not worth guessing'),
        paragraphs: [
          _en('Deficiency is common in India despite the sunshine, for reasons '
              'that are mostly about indoor work, clothing and air quality '
              'rather than about latitude. Supplementation in pregnancy is '
              'widely advised.'),
          _en('The honest position: a blood test tells you where you actually '
              'are, and the dose for somebody genuinely deficient is different '
              'from a maintenance amount. This is one worth asking about '
              'rather than choosing off a shelf, and the test is inexpensive.'),
        ],
      ),
      PvReadSection(
        heading: _en('Iron and B12: test first, in India especially'),
        paragraphs: [
          _en('Anaemia is common enough among Indian women that it is worth '
              'knowing your numbers before pregnancy rather than discovering '
              'them at a first antenatal visit. Correcting it beforehand is '
              'easier than correcting it while pregnant and nauseous.'),
          _en('B12 deficiency is common in long-term vegetarian and vegan '
              'diets, which describes a great many households here. It is '
              'straightforward to test and straightforward to correct.'),
          _en('Iron is the one supplement where more is clearly not better. '
              'Taking it without a reason can cause real problems, so this is a '
              'test-then-treat item rather than a take-it-just-in-case one.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is sold to you and does not have much behind it'),
        paragraphs: [
          _en('Fertility blends, most antioxidant combinations, and a long tail '
              'of branded preconception formulas are sold on the strength of '
              'plausible-sounding ingredients rather than on evidence that they '
              'help people conceive.'),
          _en('That does not make them harmful. It makes them expensive, and it '
              'makes the guilt attached to not buying them unearned. If a blend '
              'contains 400 mcg of folic acid and you would otherwise take a '
              'folic acid tablet, it is a more costly way to do the same '
              'thing.'),
          _en('One caution that matters: vitamin A in high doses, especially as '
              'retinol, is not safe in pregnancy. Check any multivitamin for '
              'it, and be careful of general-purpose supplements not made for '
              'people who might conceive.'),
        ],
      ),
      PvReadSection(
        heading: _en('Reading the strip, before you buy it'),
        paragraphs: [
          _en('Two units appear on these boxes and they are a thousand times '
              'apart. Folic acid is measured in micrograms — written mcg or '
              'ug — and the standard amount is 400 of them. A box printed in '
              'milligrams showing 5 mg is a prescription-strength tablet, not '
              'a stronger version of the same thing, and it is meant for '
              'specific situations rather than for general use.'),
          _en('Combination products vary widely. Two boxes both labelled '
              '"preconception" can contain quite different things, so it is '
              'worth turning the box over and reading what is actually in it '
              'rather than trusting the word on the front.'),
          _en('Check for vitamin A, listed as retinol or as retinyl palmitate. '
              'General multivitamins sometimes carry amounts that are not '
              'appropriate for somebody who might conceive, and it is not '
              'always flagged.'),
          _en('One practical thing: keep the box, or photograph it. At an '
              'appointment "a white tablet, some kind of multivitamin" is not '
              'information a doctor can act on, and the label takes two '
              'seconds to show.'),
        ],
      ),
      PvReadSection(
        heading: _en('And his side, on his own timescale'),
        paragraphs: [
          _en('Sperm take roughly two to three months to develop, so anything '
              'he changes shows up on that timescale rather than immediately. '
              'That is an argument for starting early, not for panicking about '
              'the last two months.'),
          _en('The evidence for male fertility supplements is weaker than the '
              'marketing suggests. A reasonable diet, less alcohol, no '
              'smoking and reasonable sleep are better established than any '
              'capsule.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask before taking a higher dose of anything'),
      body: _en('If you have diabetes, epilepsy, coeliac disease, a previous '
          'pregnancy affected by a neural tube defect, or take medicines that '
          'affect folate, your folic acid dose may need to be several times '
          'the standard one — and that is prescribed, not chosen. Equally, do '
          'not take iron or high-dose vitamin A without being told to. If you '
          'are already taking something and are unsure, bring the actual box '
          'to your next appointment rather than describing it.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('I started folic acid late. Have I ruined something?'),
        answer: _en('No. Start now and continue through the first twelve '
            'weeks. Most people who conceive without planning start late, and '
            'most pregnancies are fine. It is a reason to start today, not a '
            'reason to look backwards.'),
      ),
      PvReadFaq(
        question: _en('Do I need a special preconception multivitamin?'),
        answer: _en('Not necessarily. What you need is folic acid, plus '
            'anything a blood test says you are short of. A multivitamin is '
            'convenient; it is not automatically better, and it is worth '
            'checking it does not contain high-dose vitamin A.'),
      ),
      PvReadFaq(
        question: _en('How long before trying should I start?'),
        answer: _en('One month minimum for folic acid, three is comfortable. '
            'For anything based on a blood test, allow enough time to test and '
            'then correct — a couple of months is realistic.'),
      ),
    ],
    evidence: _en('NICE NG201 (antenatal care); WHO antenatal care '
        'recommendations; RCOG and NHS preconception guidance; ICMR-NIN '
        'dietary guidelines for Indians and national data on anaemia '
        'prevalence; Cochrane reviews of periconceptional folate and of '
        'antioxidants for male subfertility. Reviewed August 2026.'),
    readNext: ['ttc_read_folic_acid'],
  ),
  // ⚠️ THE ONE WITH NO NUMBERS IN IT, AND THAT IS THE BRIEF, NOT A STYLE.
  // The door's spec says "Weight before pregnancy, said kindly — Article (no
  // numbers)". So there is no BMI figure, no target, no range and no threshold
  // anywhere below, and the same rule already governs the pre-pregnancy
  // checklist's weight item and the `ttc_bmi` surface.
  //
  // The reason is not squeamishness. A number on this subject is read as a
  // verdict on her body by someone who is already anxious about it, and a
  // number she cannot reach becomes a reason to stop trying rather than a
  // reason to see somebody. What actually helps is the shape of the effect and
  // the direction of travel — which is what this piece gives.
  PvRead(
    id: 'ttc_read_weight_kindly',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Weight before pregnancy, said kindly'),
    teaser: _en('Weight does affect fertility. It is also the subject people '
        'are hurt by most often, and the useful version of this conversation '
        'has no target in it.'),
    scaleSetter: _en('There is no number in this piece on purpose. Weight is '
        'one factor among several, it moves the odds rather than deciding '
        'anything, and a target you cannot reach is worse than no target at '
        'all. What helps is direction, and even a modest change in the right '
        'direction does more than most people expect.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Most people arriving at this subject have already been told '
              'something about it, usually bluntly, often by somebody who was '
              'not asked. So the first thing worth saying is that weight is '
              'one factor among several, that plenty of people conceive at '
              'every size, and that nothing here is a judgement about whether '
              'you deserve a baby.'),
          _en('The second thing is that it does matter, and pretending '
              'otherwise would be its own kind of unkindness.'),
        ],
      ),
      PvReadSection(
        heading: _en('What weight actually does, mechanically'),
        paragraphs: [
          _en('Fat tissue is not inert — it produces oestrogen. Carrying more '
              'of it changes the hormonal signal reaching the ovaries, and in '
              'some people that disrupts ovulation, which shows up as '
              'irregular or absent periods.'),
          _en('Carrying very little does the same thing from the other '
              'direction. Below a certain point the body treats reproduction as '
              'something to postpone, and periods become irregular or stop. '
              'This is why the conversation is not only about being heavier.'),
          _en('Insulin resistance is the other mechanism, and it is the one '
              'that connects this subject to PCOS. It is common, it is '
              'treatable, and it responds to change more readily than most '
              'people are told.'),
          _en('And it affects both of you. Weight is associated with sperm '
              'quality too, which is one of several places in this stage where '
              'a burden gets put on one person and belongs to two.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why the direction matters more than the destination'),
        paragraphs: [
          _en('Here is the part that usually goes missing. A relatively small '
              'change in weight can restore ovulation in someone whose cycles '
              'had become irregular. Not a transformation — a modest, '
              'sustainable shift.'),
          _en('That matters because the version of this advice that people '
              'usually receive implies a long project with a distant finish '
              'line, and a distant finish line is exactly what makes somebody '
              'give up in week three. The useful framing is that the benefit '
              'starts early, and it does not require arriving anywhere in '
              'particular.'),
          _en('It is also why crash dieting works against you. Losing weight '
              'very fast disrupts cycles in its own right, and the weight '
              'usually returns. Slow and boring is not a compromise here; it '
              'is the version that works.'),
        ],
      ),
      PvReadSection(
        heading: _en('What actually helps, in an Indian kitchen'),
        paragraphs: [
          _en('Nothing exotic and nothing imported. More of the meal made of '
              'vegetables and dal, whole grains in place of refined ones where '
              'that is practical, and fewer fried snacks and sweets between '
              'meals — which in most households is where the surprise sits, '
              'not in the main meals.'),
          _en('Movement that you will actually keep doing beats an intense plan '
              'you will abandon. A daily walk that happens is worth more than a '
              'gym membership that does not.'),
          _en('Sleep is the one people leave out. Short sleep affects appetite '
              'regulation directly, and it is usually easier to fix than diet.'),
          _en('And if there is a reason behind the weight — thyroid, PCOS, a '
              'medicine that causes gain — then treating the reason is the '
              'work, and effort spent on willpower instead is effort wasted.'),
        ],
      ),
      PvReadSection(
        heading: _en('When the scale is not moving'),
        paragraphs: [
          _en('This is where most people stop, and it is worth knowing what is '
              'actually happening. Weight is a poor week-to-week measure — it '
              'moves with water, with salt, with where you are in your cycle, '
              'and with what you ate yesterday. A flat week is not evidence '
              'that nothing is working.'),
          _en('More importantly, the things that matter for ovulation do not '
              'wait for the scale. Better insulin sensitivity from regular '
              'movement, and better sleep, are doing their work whether or not '
              'the number has changed. Cycles sometimes become more regular '
              'before any substantial weight change at all, which is a strong '
              'argument for watching your periods rather than the scale.'),
          _en('So if you want something to track, track the first day of each '
              'period. It is the measure that is actually connected to what '
              'you are trying to do, and it does not make anybody feel worse '
              'on a Tuesday morning.'),
          _en('And plateaus are normal rather than a sign of failure. Bodies '
              'adjust; progress in this direction is rarely a straight line, '
              'and stopping at the first flat stretch is what turns a slow '
              'change into no change.'),
        ],
      ),
      PvReadSection(
        heading: _en('If you are already being treated unkindly about this'),
        paragraphs: [
          _en('Some clinics apply a weight threshold before offering treatment, '
              'and being told to come back lighter, with no help offered about '
              'how, is a common and demoralising experience.'),
          _en('You are allowed to ask what the threshold is for, whether it is '
              'a clinical requirement or a policy, and what support is '
              'available. You are allowed to seek a second opinion. And you are '
              'allowed to say that the way it was said was not helpful.'),
          _en('If food has become something you fight with — restricting, '
              'bingeing, or thinking about it constantly — that is worth '
              'raising with a doctor in its own right, before and separately '
              'from any conversation about conceiving.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Some of this is not about willpower'),
      body: _en('If your periods have become irregular or stopped, if weight '
          'has changed considerably without a change in what you eat, or if '
          'you have symptoms like persistent tiredness, hair thinning or cold '
          'intolerance, ask for thyroid and PCOS checks rather than trying '
          'harder. And if your relationship with food or with your body has '
          'become distressing, please tell a doctor — that is a health matter '
          'in itself and deserves care, whether or not you are trying to '
          'conceive.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do I have to reach a particular weight before trying?'),
        answer: _en('There is no single number that applies to everybody, '
            'which is why this piece does not print one. Some clinics use '
            'thresholds for specific treatments; that is a conversation to have '
            'with the clinic. For trying naturally, direction matters more than '
            'arriving anywhere.'),
      ),
      PvReadFaq(
        question: _en('Can I be too thin for this?'),
        answer: _en('Yes. Below a certain point cycles become irregular or '
            'stop, and the fix is the opposite of what most advice assumes. If '
            'your periods have stopped and you are lean or exercising heavily, '
            'that is worth seeing somebody about.'),
      ),
      PvReadFaq(
        question: _en('Should I lose weight quickly to save time?'),
        answer: _en('No. Rapid loss disrupts cycles by itself and rarely '
            'holds. A steady change you can maintain is both kinder and more '
            'effective, and the benefit begins well before any destination.'),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems) and NICE guidance on weight '
        'management before pregnancy; RCOG and WHO statements on preconception '
        'care; evidence on modest weight change and restoration of ovulation '
        'in anovulatory infertility. No thresholds, targets or BMI figures are '
        'stated here by editorial decision. Reviewed August 2026.'),
    readNext: ['ttc_read_three_months_before'],
  ),

  PvRead(
    id: 'ttc_read_coming_off_birth_control',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Coming off birth control'),
    teaser: _en('What returns quickly, what takes a while, and why the phrase '
        '"let it clear out of your system" is doing you no favours.'),
    scaleSetter: _en('For most methods, fertility returns quickly — sometimes '
        'immediately. The main exception is the contraceptive injection, and it '
        'is a genuinely long one. Nothing here needs a waiting period "to '
        'flush it out"; that idea is folklore and it costs people months.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Two beliefs cause most of the trouble here. The first is that '
              'you must wait several months for contraception to "leave your '
              'system" before it is safe to try. The second is that long use '
              'causes lasting infertility. Neither is supported.'),
          _en('What is true is that different methods return you to your own '
              'cycle on very different timescales, and knowing which one you '
              'were on changes what to expect.'),
        ],
      ),
      PvReadSection(
        heading: _en('The pill, the patch and the ring'),
        paragraphs: [
          _en('Ovulation usually returns quickly after stopping — for many '
              'people within the first cycle or two. It is entirely possible to '
              'conceive before having a single period in between, which is '
              'worth knowing if you were planning to count from one.'),
          _en('The first bleed after stopping is often not a normal period, and '
              'the first few cycles can be irregular while your own rhythm '
              'reasserts itself. That is settling, not a problem.'),
          _en('There is no need to wait a set number of months before trying. '
              'The older advice to wait three cycles was mostly about making '
              'dating a pregnancy easier, not about safety, and scans have made '
              'that argument redundant.'),
          _en('One thing the pill can mask: if your cycles were irregular '
              'before you started it, they may well be irregular again '
              'afterwards. That is the underlying pattern reappearing rather '
              'than the pill having caused something.'),
        ],
      ),
      PvReadSection(
        heading: _en('Coils, implants and the injection'),
        paragraphs: [
          _en('A copper or hormonal coil is removed and fertility returns '
              'essentially straight away. The same is true of an implant once '
              'it is taken out.'),
          _en('The contraceptive injection is the real exception. It can take '
              'many months after the last dose before ovulation returns, and '
              'for some people close to a year or more. This is a delay, not '
              'damage — it does not reduce your eventual fertility — but if you '
              'are on it and thinking about trying in the near future, that is '
              'a conversation to have sooner rather than later.'),
          _en('Emergency contraception does not affect future fertility at '
              'all, and does not need any waiting period.'),
        ],
      ),
      PvReadSection(
        heading: _en('What it may have been hiding'),
        paragraphs: [
          _en('A bleed on the combined pill is not a period. It is a '
              'withdrawal bleed that happens because the hormones pause, which '
              'is why it tends to be lighter, shorter and more punctual than '
              'anything your own body produces. Losing that predictability is '
              'the change people find most disorienting, and it is not a '
              'problem — it is your own cycle, which was never that tidy.'),
          _en('Symptoms often come back with it. Period pain, heavier '
              'bleeding, premenstrual mood changes and acne are all commonly '
              'suppressed by hormonal contraception, and their return is the '
              'underlying pattern reappearing rather than something new going '
              'wrong.'),
          _en('That matters for one specific reason. If the pill was '
              'originally prescribed for painful or heavy periods, for acne or '
              'for irregular cycles, then the thing it was managing is still '
              'there. Severe period pain in particular is worth investigating '
              'properly rather than enduring — it is one of the ways '
              'endometriosis goes unnoticed for years, and the years matter '
              'more when you are trying to conceive.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to do in the gap'),
        paragraphs: [
          _en('Start folic acid before you stop contraception rather than '
              'after. It needs to be in your system before conception, and '
              'since conception can happen sooner than expected here, earlier '
              'is genuinely better.'),
          _en('If you want to know your own cycle again, start noting the first '
              'day of each period. That single fact is what almost every later '
              'question depends on, and it costs nothing to record.'),
          _en('Give yourself a few cycles before drawing conclusions about '
              'regularity. Judging your cycle on the first one after stopping '
              'is like judging a road by its first ten metres.'),
        ],
      ),
      PvReadSection(
        heading: _en('When the pause is worth asking about'),
        paragraphs: [
          _en('If your period has not returned within about three months of '
              'stopping the pill, a coil or an implant, that is worth raising. '
              'It is usually something ordinary — thyroid, PCOS, stress, weight '
              'change — and finding out is quicker than waiting.'),
          _en('The injection is judged differently, because a long wait is '
              'expected rather than surprising. Even so, if you are past a year '
              'from your last dose with nothing, ask.'),
          _en('And the usual timelines still apply once your cycles are back. '
              'Time trying is counted from when you started trying, not from '
              'when you stopped contraception.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to ask rather than wait'),
      body: _en('See a doctor if your periods have not returned about three '
          'months after stopping the pill, a coil or an implant; if they '
          'return but are very irregular after several cycles; if you have '
          'severe pain, unusually heavy bleeding, or bleeding between periods; '
          'or if you are on the contraceptive injection and hoping to conceive '
          'within the next year — that last one is worth planning early rather '
          'than discovering late.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do I need to wait for it to leave my system?'),
        answer: _en('No. That idea has no basis for any of these methods. The '
            'only genuine wait is the contraceptive injection, and that is '
            'about ovulation returning rather than about anything clearing '
            'out.'),
      ),
      PvReadFaq(
        question: _en('I was on the pill for ten years. Has that harmed me?'),
        answer: _en('Long use is not associated with reduced fertility '
            'afterwards. What long use does do is hide what your own cycle was '
            'like, so anything irregular that appears afterwards is usually '
            'something that was there before.'),
      ),
      PvReadFaq(
        question: _en('Can I get pregnant before my first period?'),
        answer: _en('Yes. Ovulation comes before a period, so it is quite '
            'possible to conceive in the first cycle after stopping. Start '
            'folic acid before you stop rather than after.'),
      ),
      PvReadFaq(
        question: _en('My cycles are irregular now. Is that the pill?'),
        answer: _en('The first few cycles are commonly irregular while things '
            'settle. Beyond that, it is more often the pattern you had before '
            'the pill becoming visible again — which is worth investigating '
            'rather than waiting out.'),
      ),
    ],
    evidence: _en('NICE CG156; FSRH (Faculty of Sexual and Reproductive '
        'Healthcare) guidance on return of fertility after contraception; NHS '
        'contraception guidance; WHO medical eligibility criteria. Reviewed '
        'August 2026.'),
    readNext: ['ttc_read_how_conception_works'],
  ),

  PvRead(
    id: 'ttc_read_meds_and_conditions',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Medicines and conditions to check with a doctor'),
    teaser: _en('The appointment worth having before you start — and the one '
        'decision you should not make on your own.'),
    scaleSetter: _en('The single most important sentence here is: do not stop '
        'a prescribed medicine to get ready. Some are changed before pregnancy, '
        'some are continued exactly as they are, and stopping suddenly is '
        'almost never the right answer. A well-controlled condition going into '
        'pregnancy is worth far more than a clean-sounding medicine list.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('There is a reflex, once people decide to try, to strip back to '
              'nothing — stop the tablets, come off everything, start clean. '
              'It comes from a good instinct and it is the most common '
              'avoidable mistake in this part of the journey.'),
          _en('An uncontrolled condition is a risk to a pregnancy in a way that '
              'a well-chosen medicine usually is not. The work is not stopping '
              'things; it is having one conversation with the person who '
              'prescribed them, early enough that any change has time to '
              'settle.'),
        ],
      ),
      PvReadSection(
        heading: _en('The conditions worth reviewing before you start'),
        paragraphs: [
          _en('Thyroid, either direction. Thyroid function affects ovulation '
              'and early pregnancy, targets are often different in pregnancy '
              'from outside it, and doses commonly need adjusting. If you are '
              'on thyroid medication, this is the single most worthwhile '
              'pre-pregnancy check.'),
          _en('Diabetes, including diabetes managed with tablets rather than '
              'insulin. Control before conception matters more than control '
              'after, because the earliest weeks are when it counts most, and '
              'the folic acid dose is often higher.'),
          _en('Epilepsy. Some seizure medicines carry real risks in pregnancy '
              'and others are much safer, so this is one where a planned switch '
              'well beforehand is genuinely valuable. It is also one where '
              'stopping unilaterally is dangerous — an uncontrolled seizure is '
              'a serious event for both of you.'),
          _en('High blood pressure, autoimmune conditions such as lupus, '
              'inflammatory bowel disease and rheumatoid arthritis. In most of '
              'these, being stable before conceiving is the goal, and several '
              'of the medicines used are compatible with pregnancy.'),
          _en('Mental health treatment. Stopping an antidepressant that is '
              'working, in order to prepare, is a decision with its own '
              'substantial risks — for her and for a pregnancy. It deserves the '
              'same careful conversation as any other medicine and not a '
              'quiet, unilateral stop.'),
        ],
      ),
      PvReadSection(
        heading: _en('Medicines specifically worth asking about'),
        paragraphs: [
          _en('Some are known to be unsafe in pregnancy and are usually changed '
              'in advance — certain blood pressure medicines, some acne '
              'treatments, methotrexate, warfarin and several epilepsy drugs '
              'are the ones most often named. If you take any of these, the '
              'appointment is worth making before you start trying, not after '
              'a positive test.'),
          _en('Over-the-counter is not automatically safe. Long-term '
              'anti-inflammatory painkillers can interfere with ovulation, and '
              'high-dose vitamin A supplements are not safe in pregnancy.'),
          _en('Ayurvedic, homeopathic and herbal preparations count as '
              'medicines for this conversation. Many are fine; some are not '
              'well studied, and a few heavy-metal contamination problems have '
              'been documented in unregulated products. Mention what you take '
              'rather than assuming a doctor only wants to hear about '
              'allopathic drugs.'),
          _en('Bring the actual boxes to the appointment. Names are easy to '
              'mix up, doses are easy to misremember, and a strip in a bag '
              'settles both in ten seconds.'),
        ],
      ),
      PvReadSection(
        heading: _en('How to ask, so the appointment is useful'),
        paragraphs: [
          _en('Say plainly that you are planning to conceive and roughly when. '
              '"We are hoping to start trying in a few months" changes what a '
              'doctor considers, and it is easy to leave unsaid out of '
              'awkwardness.'),
          _en('Ask three things: does anything I take need changing, does '
              'anything need changing in advance rather than at a positive '
              'test, and does anything about my condition change the folic acid '
              'dose I should be on.'),
          _en('Ask who to contact when you do conceive, and whether you should '
              'be seen sooner than a first routine antenatal appointment. For '
              'several of the conditions above, the answer is yes.'),
        ],
      ),
      PvReadSection(
        heading: _en('And his medicines count too'),
        paragraphs: [
          _en('A few medicines affect sperm production or function, including '
              'some used for hair loss and testosterone in particular — '
              'testosterone supplementation suppresses sperm production, which '
              'surprises people who assumed it did the opposite.'),
          _en('If he takes anything regularly and you are planning to conceive, '
              'it is worth a mention at his own appointment rather than being '
              'raised for the first time at a fertility clinic a year later.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Never stop a prescribed medicine to prepare for pregnancy'),
      body: _en('Do not stop or reduce anything you were prescribed — for '
          'thyroid, epilepsy, diabetes, blood pressure, mental health or '
          'anything else — without speaking to the doctor who prescribed it. '
          'An uncontrolled condition is a greater risk than almost any '
          'well-chosen medicine, and some medicines are dangerous to stop '
          'abruptly. If you have already stopped something, say so plainly at '
          'the appointment; that is information, not a confession.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should I stop everything before we start trying?'),
        answer: _en('No. Ask instead. Some medicines are swapped ahead of time, '
            'many are continued unchanged, and stopping suddenly is the option '
            'that is almost never right.'),
      ),
      PvReadFaq(
        question: _en('How far ahead should I book this appointment?'),
        answer: _en('A few months is comfortable, because any medicine change '
            'needs time to settle and be checked. If that has already passed, '
            'go anyway — sooner is better than never.'),
      ),
      PvReadFaq(
        question: _en('Do I need to mention Ayurvedic medicines?'),
        answer: _en('Yes. They are medicines for this purpose. Many are fine, '
            'some are not well studied, and a doctor can only account for what '
            'they are told about.'),
      ),
      PvReadFaq(
        question: _en('I am on an antidepressant. Do I have to come off it?'),
        answer: _en('Not automatically, and this is one to discuss rather than '
            'decide alone. Untreated depression in pregnancy carries its own '
            'real risks, and the choice is a balance a psychiatrist or GP can '
            'help you weigh.'),
      ),
    ],
    evidence: _en('NICE NG201 (antenatal care) and NICE guidance on epilepsy, '
        'diabetes and antenatal mental health; RCOG preconception care '
        'statements; MHRA valproate safety guidance; UK Teratology Information '
        'Service principles on medicine use around conception; published '
        'reports of heavy-metal contamination in some unregulated herbal '
        'preparations. Reviewed August 2026.'),
    readNext: ['ttc_read_preconception_tests'],
  ),
  // ===========================================================================
  //  ⚠️ THE MOST INDIA-SPECIFIC ARTICLE IN THIS DOOR, AND THE ONE MOST WESTERN
  //  PRECONCEPTION ADVICE LEAVES OUT ENTIRELY.
  //
  //  Written 2026-09-03, after the test was confirmed. The brief listed it as
  //  "The carrier screening that matters in India" and said to confirm exactly
  //  which screen was meant before it went into copy, because naming a medical
  //  test is a place to be precise. Confirmed: thalassemia carrier screening,
  //  by HbA2 on HPLC.
  //
  //  ⚠️ THE TONE IS THE HARD PART. Two people who are both carriers are facing
  //  a genuinely serious conversation, and the same article is read by a very
  //  large number of people for whom the answer will be "you are not a carrier,
  //  that is the end of it". So it has to be accurate enough to matter and calm
  //  enough not to frighten the majority into a test they will misread.
  //
  //  ⚠️ AND CARRIER IS NOT ILL. Stated early and repeated, because "carrier"
  //  and "thalassemia" are one word apart in most people's heads and the
  //  distance between them is enormous.
  //
  //  ⚠️ THE ONE-IN-FOUR IS MENDELIAN INHERITANCE, NOT A PERSONALISED
  //  PROBABILITY. This stage never computes a chance for a specific woman. The
  //  recurrence risk for two carriers is a fact of genetics that every
  //  counsellor states, framed here as what a counsellor will explain rather
  //  than as a number about her — and the article routes to that counsellor
  //  rather than doing their job.
  // ===========================================================================
  PvRead(
    id: 'ttc_read_carrier_screening',
    hue: 206,
    kicker: _en('Getting ready'),
    title: _en('The carrier screening that matters in India'),
    teaser: _en('One inexpensive blood test, done once, that most Western '
        'preconception advice never mentions — and that matters here more '
        'than almost anywhere.'),
    scaleSetter: _en('Thalassemia carrier screening is a routine blood test. '
        'Most people who take it are not carriers and never think about it '
        'again. It is on this list because India has more children born with '
        'thalassemia major than any other country, because being a carrier '
        'causes no symptoms at all, and because the test only changes anything '
        'if it is done BEFORE a pregnancy rather than during one.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('If you have read a Western checklist of things to do before '
              'trying, this was probably not on it. That is not an oversight '
              'on their part — carrier frequencies differ enormously between '
              'populations, and in India this one is high enough that it '
              'belongs near the top.'),
          _en('The whole thing is one blood test, it costs less than a '
              'restaurant meal, and for most people the result ends the '
              'conversation.'),
        ],
      ),
      PvReadSection(
        heading: _en('Being a carrier is not being ill'),
        paragraphs: [
          _en('This is the sentence to hold on to, because "carrier" and '
              '"thalassemia" sit one word apart and the distance between them '
              'is enormous.'),
          _en('A thalassemia carrier — you may also see it written as '
              'thalassemia trait or thalassemia minor — is a healthy person. '
              'No treatment, no restrictions, no shortened life, usually no '
              'symptoms at all. Many carriers reach middle age without ever '
              'knowing.'),
          _en('What a carrier sometimes has is slightly small red blood cells '
              'and mild anaemia that does not respond to iron. That matters '
              'for a practical reason: it is frequently mistaken for iron '
              'deficiency and treated with iron tablets for years, which does '
              'nothing useful and, taken long enough without a genuine '
              'deficiency, is not harmless.'),
          _en('So if you have been told you are "always a little anaemic" and '
              'iron has never really fixed it, this test answers a question '
              'you have already been asking.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why it matters before a pregnancy rather than during'),
        paragraphs: [
          _en('One carrier and one non-carrier cannot have a child with '
              'thalassemia major. This only becomes a serious conversation '
              'when BOTH partners are carriers — which is why it is a couple\'s '
              'test rather than a woman\'s test.'),
          _en('Where both are carriers, a genetic counsellor will explain what '
              'the inheritance means: in each pregnancy, independently, there '
              'is a one-in-four chance of a child with thalassemia major, a '
              'one-in-two chance of a carrier like the parents, and a '
              'one-in-four chance of neither. Those are the numbers of '
              'inheritance rather than a prediction about you, and they do not '
              'change from one pregnancy to the next.'),
          _en('Thalassemia major is a serious lifelong condition requiring '
              'regular blood transfusions from infancy. It is treatable and '
              'people live with it; nobody pretends it is a small thing.'),
          _en('And the reason the timing matters: a couple who know before '
              'conceiving have options that a couple who find out at twenty '
              'weeks do not. Those options are a genetic counsellor\'s to '
              'explain, not an app\'s, and they exist.'),
        ],
      ),
      PvReadSection(
        heading: _en('The actual test, and the order to do it in'),
        paragraphs: [
          _en('Start with a complete blood count — the ordinary CBC most '
              'people have had many times. What a doctor looks at is the size '
              'of the red cells: a low MCV or MCH is the flag that says look '
              'further.'),
          _en('The test that answers it is haemoglobin electrophoresis or HPLC, '
              'usually reported as HbA2. A raised HbA2 indicates beta '
              'thalassemia trait. Ask for it by name — HbA2 by HPLC — because '
              '"anaemia panel" means different things at different labs.'),
          _en('Test one partner first, usually whoever is having other '
              'preconception bloods done anyway. If that comes back negative, '
              'you are finished. If it is positive, the other partner is '
              'tested, and only if BOTH are carriers does anything further '
              'follow.'),
          _en('It is inexpensive and widely available across India, and it is a '
              'once-in-a-lifetime test. Your result does not change.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who should be especially sure to do it'),
        paragraphs: [
          _en('Everybody planning a pregnancy in India can reasonably have it, '
              'and several national programmes recommend exactly that. Some '
              'situations make it more pressing.'),
          _en('Carrier rates are higher in some communities than others — '
              'among them Sindhi, Punjabi, Gujarati, Bengali and several '
              'others. Sickle cell trait, which is screened the same way, is '
              'more common in central and tribal India. If you know your '
              'community carries either, treat this as a definite rather than '
              'a maybe.'),
          _en('Anyone with a family history of thalassemia, of sickle cell '
              'disease, or of a relative who needed regular transfusions as a '
              'child. Anyone whose parents were related by blood, which raises '
              'the chance both partners carry the same variant.'),
          _en('And anyone with long-standing mild anaemia that iron has never '
              'corrected — for that person the test is worth doing whether or '
              'not a pregnancy is being planned.'),
        ],
      ),
      PvReadSection(
        heading: _en('What a result actually means, in plain terms'),
        paragraphs: [
          _en('Not a carrier: nothing to do, and the question is closed for '
              'life.'),
          _en('You are a carrier and your partner is not: your children may be '
              'carriers like you, and no child will have thalassemia major '
              'from the two of you. It is worth writing down so a future '
              'doctor knows, and worth mentioning to siblings, because carrier '
              'status runs in families.'),
          _en('Both of you are carriers: this is the conversation to have with '
              'a genetic counsellor, before conceiving rather than after. Ask '
              'to be referred; do not try to work it out from the internet, '
              'and do not let anybody rush you.'),
          _en('One thing to be careful of: a normal HbA2 does not rule out '
              'every form. Alpha thalassemia and some rarer variants need '
              'different tests, and a doctor who sees small red cells with a '
              'normal HbA2 will know to look further. That is another reason '
              'to take the result to somebody rather than reading it alone.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask for a genetic counsellor, not for an opinion'),
      body: _en('If both of you are carriers, ask your doctor to refer you to '
          'a genetic counsellor before you start trying. That is a specific '
          'referral and it is available in most Indian cities. Do not act on '
          'anything you have read here or anywhere else without it. And if you '
          'have been taking iron for years for anaemia nobody has explained, '
          'ask for this test before taking any more — iron for an anaemia that '
          'is not iron deficiency does no good and can do harm.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('I feel completely fine. Do I still need it?'),
        answer: _en('Yes, and that is the point of it. Carriers feel fine — '
            'that is what makes carrier status invisible until two carriers '
            'have a child together.'),
      ),
      PvReadFaq(
        question: _en('Do both of us have to be tested?'),
        answer: _en('Only if the first result is positive. Test one of you; if '
            'that is negative you are done. It is a couple\'s test in what it '
            'means, not in what it costs.'),
      ),
      PvReadFaq(
        question: _en('Is it expensive?'),
        answer: _en('No. It is one of the cheaper tests on any preconception '
            'list, it is available across India, and it is done once in a '
            'lifetime.'),
      ),
      PvReadFaq(
        question: _en('We are already pregnant. Is it too late?'),
        answer: _en('It is not too late to be tested, and it is worth doing '
            'now rather than waiting. Options differ from those available '
            'before conceiving, and a genetic counsellor is the person to '
            'explain them. Go sooner rather than later.'),
      ),
      PvReadFaq(
        question: _en('What if we are both carriers?'),
        answer: _en('Ask for a genetic counsellor before you start trying. '
            'There are real options and they are theirs to explain properly. '
            'What is not useful is deciding anything from a search result at '
            'midnight.'),
      ),
    ],
    evidence: _en('ICMR guidance on haemoglobinopathy screening in India; the '
        'National Health Mission Guidelines for Prevention and Control of '
        'Haemoglobinopathies (thalassemia and sickle cell disease); Thalassemia '
        'International Federation guidelines on carrier screening and genetic '
        'counselling; WHO estimates of carrier prevalence by region; NICE and '
        'RCOG guidance on antenatal haemoglobinopathy screening. Community '
        'prevalence varies widely and no figure for any individual community '
        'is stated here. Reviewed August 2026.'),
    readNext: ['ttc_read_preconception_tests'],
  ),
];
