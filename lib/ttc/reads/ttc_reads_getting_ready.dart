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
];
