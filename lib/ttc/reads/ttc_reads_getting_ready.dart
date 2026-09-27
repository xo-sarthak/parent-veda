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
    teaser: _en('Why these months matter, what folic acid really does, and how '
        'much weight matters, for both of you.'),
    shortAnswer: _en('Start folic acid at least a month before you begin '
        'trying, and check for the shortages that are common in India, like '
        'iron, B12 and vitamin D. Stop tobacco and cut alcohol, both of you. '
        'Eggs and sperm take about three months to mature, so what you change '
        'now shows up about three months later.'),

    scaleSetter: _en('Almost nothing on this list is urgent, and almost all of '
        'it is cheap. The reason to do it now is timing, not effort. An egg '
        "spends about three months maturing before it's released, and sperm "
        'take about eleven weeks to make. What you change today shows up in a '
        'cycle three months from now.'),

    author: _en('Akanksha Srivastava'),
    authorRole: _en('Maternal and child nutritionist'),

    heroVideoSlot: 'ttc_vid_three_months_before',

    sections: [
      PvReadSection(
        paragraphs: [
          _en("There's a reason advice for before pregnancy always says three "
              "months. It isn't a round number picked because it's easy."),
          _en("An egg isn't made in the cycle it's released. It spends roughly "
              'ninety days maturing inside its follicle, the small sac that '
              'holds it. Sperm take about seventy-four days to make, plus a '
              'couple of weeks to finish.'),
          _en('So the sperm in a pregnancy this '
              'month began forming around eleven weeks ago, and the egg '
              'started maturing about three months ago.'),
          _en("This is good news, though it's rarely put that way. It means "
              'the window you can change is open right now. And nothing that '
              'happened before it still counts against you.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why start folic acid before you try?'),
        paragraphs: [
          _en("The neural tube becomes the baby's brain and spinal cord. It "
              "closes in the first four weeks after conception. That's often "
              'before a period is even missed, and always before most women '
              'know.'),
          _en("So folic acid has to be in your body by then. That's why "
              'every guideline says to start while trying, not after a '
              'positive test.'),
        ],
      ),

      PvReadSection(
        heading: _en('How much folic acid should I take?'),
        paragraphs: [
          _en('FOGSI, the body for Indian gynaecologists, puts the standard '
              'dose at 400 to 500 micrograms a day. Start at least a month '
              'before you begin trying, and keep going through the first '
              'trimester.'),
          _en('It costs a few rupees a day. Of everything anyone will suggest '
              'at this stage, it has the strongest evidence behind it.'),
          _en('A much higher dose, 4 to 5 milligrams, is advised in some '
              'cases: a past pregnancy affected by a neural tube defect, '
              'diabetes, epilepsy medicine, a much raised BMI, thalassaemia or '
              'another haemoglobinopathy (an inherited blood disorder), or an '
              'MTHFR variant.'),
          _en("That's for a doctor to prescribe, not something to pick off a "
              'shelf.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Check what's in your strip"),
          body: _en('Many prenatal combinations sold over the counter in India '
              "contain 5 mg, not 400 mcg, because that's the dose often "
              "prescribed in pregnancy here. It isn't dangerous. But it's a "
              "twelvefold difference, and it's better to choose it knowingly "
              'than to find out later. Read the strip.'),
        ),
      ),

      PvReadSection(
        heading: _en('Does my weight matter?'),
        paragraphs: [
          _en('Weight affects ovulation at both ends, but people usually talk '
              'about only one. Being very underweight stops ovulation just as '
              'reliably as being very overweight. The body senses a shortage '
              'and stops spending energy on making a baby.'),
          _en('If weight is on the higher side, the figure the evidence keeps '
              'coming back to is about five per cent. Not a target weight, and '
              'not a BMI number.'),
          _en('Losing five per cent of what you weigh now is enough to change '
              'how well your body handles insulin. For a real share of women, '
              'that alone brings cycles back.'),
          _en('BMI also reads Indian bodies badly. Its cut-offs came from '
              'European populations, and in South Asians the health risks '
              "start at lower numbers. That's why your waist measurement often "
              'tells you more here than the BMI figure people quote at you.'),
        ],
        mythFact: PvMythFact(
          myth: _en('You need to reach a healthy BMI before you start trying.'),
          fact: _en("For most people that's neither realistic nor needed. The "
              'evidence supports a modest change you keep up, around five '
              'per cent, rather than hitting a number first. Putting off '
              'trying for a year to reach a BMI target swaps a small benefit '
              "for a year of age. For many women, that's the worse deal."),
        ),
      ),

      PvReadSection(
        heading: _en('What should I eat?'),
        paragraphs: [
          _en("There's no such thing as a fertility diet, so be wary of "
              'anything sold as one. What the evidence supports is a general '
              'pattern: plenty of vegetables and whole grains, pulses and '
              'other whole-food protein, some dairy, healthy oils and fats, '
              'and not much packaged, processed food.'),
          _en('What matters more in India is a short list of shortages that '
              'are very common here and worth fixing.'),
        ],
        bullets: [
          _en('Iron. Anaemia is very common in Indian women of childbearing '
              "age, so it's worth testing rather than guessing. Eat iron-rich "
              'food with vitamin C, and keep tea and coffee away from meals, '
              'because both stop iron being absorbed.'),
          _en('Vitamin B12. Often low on a vegetarian diet, and it matters for '
              'the same neural-tube reasons folate does. A blood test settles '
              'it.'),
          _en('Vitamin D. Low in most Indian adults, however much sun there '
              'is, and cheap to correct.'),
          _en("Iodine. Use iodised salt. Your thyroid and your baby's early "
              'brain growth both depend on it.'),
        ],
        tip: PvReadTip(
          title: _en('The one change that pays off most'),
          body: _en('Protein at breakfast. The usual Indian breakfast is '
              'mostly carbohydrate and eaten in a hurry. Adding curd, an egg, '
              'sprouts, peanuts or a besan chilla keeps you steadier all day. '
              "It's also the change you're most likely to keep for a year, and "
              'that matters more than any single nutrient above.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Everyone already knows most of this; it is here to be
        // complete and to be specific about the Indian one, not to lecture.
        collapsible: true,
        summary: _en('Alcohol, tobacco and caffeine: what the evidence '
            'supports, including the one that matters most here.'),
        heading: _en('What should we cut, and by how much?'),
        paragraphs: [
          _en('Tobacco is the clearest. It lowers egg and sperm quality, '
              'brings menopause earlier, and roughly doubles the risk of '
              'miscarriage.'),
          _en('In India this includes chewing tobacco, gutka and khaini. '
              "People who use them often don't count them as smoking, but "
              'they matter just as much.'),
          _en('No amount of alcohol is known to be safe in pregnancy. While '
              'trying, the honest answer is this: heavy drinking clearly '
              'affects fertility in both partners, and the evidence on the odd '
              'drink is much weaker.'),
          _en("Most advice is to stop once you're trying, because you may be "
              'pregnant before you know.'),
          _en('Caffeine is the one people worry about too much. A moderate '
              "amount, around two to three cups of coffee a day, hasn't been "
              "shown to lower fertility. You don't need to give up chai."),
        ],
      ),

      PvReadSection(
        heading: _en('What does your partner need to do?'),
        paragraphs: [
          _en('Everything above about the three-month window applies to him '
              'too, and even more directly. Sperm are made all the time, so a '
              'change in his habits shows up in a full round of sperm about '
              'eleven weeks later.'),
          _en('His list is short and mostly the same: tobacco first, alcohol '
              'second, heat third. Laptops on laps, long hot baths and tight '
              'synthetic underwear all warm the testicles enough to matter, '
              'and all are easy to change.'),
          _en('If only one of you is going to do any of this, the honest '
              'answer is that it should probably be both. But the male half is '
              "the one most often skipped, and it's the half that responds "
              'fastest.'),
        ],
      ),

      PvReadSection(
        heading: _en('Should I see a gynaecologist before we start?'),
        paragraphs: [
          _en('It helps, and many women never do. One visit before trying lets '
              'a doctor check your health, your medicines and your tests while '
              "there's still time to change things."),
          _en('Choose someone you find easy to talk to, close enough to reach '
              'often, and linked to a hospital where you would be happy to '
              'give birth. A recommendation from a friend or relative is a '
              'good place to start.'),
          _en('Take your period dates, the boxes of anything you take, and a '
              'short list of questions. The read on seeing a gynaecologist '
              'before you try, in this door, has the list ready for you.'),
        ],
      ),

      PvReadSection(
        heading: _en('What about money, work and each other?'),
        paragraphs: [
          _en("Health is only part of getting ready. It's worth looking at "
              'money now, because some of it needs months of notice.'),
          _en('Many health insurance plans in India only cover delivery after '
              'a waiting period, often two years or more. Check your policy '
              'now. Group cover through an employer often starts sooner, so '
              'read that too.'),
          _en('It also helps to talk together about work, help at home in '
              "the first months, and how you'll look after each other if this "
              'takes a while. The money read in this door goes through leave, '
              'costs and savings in more detail.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Do I need an expensive prenatal, or is plain folic acid '
            'enough?'),
        answer: _en('Plain folic acid covers the thing with the strongest '
            'evidence. A combined prenatal is handy if it also covers iron, '
            'B12 and vitamin D. Check that against your own blood tests rather '
            "than assuming. Price tells you very little about what's in the "
            'strip.'),
      ),
      PvReadFaq(
        question: _en("I've been taking folic acid for years. Is that a "
            'problem?'),
        answer: _en('No. It dissolves in water, and the standard dose is safe '
            "long-term. If you're on a high dose without a clear reason, "
            'mention it to your doctor, mainly because very high folate can '
            'hide a B12 deficiency on a blood test.'),
      ),
      PvReadFaq(
        question: _en('How long should we do all this before starting to try?'),
        answer: _en('About three months is the usual advice, and it matches '
            "how the body works. But don't treat it as a gate. If that's where "
            'you are, start folic acid and start trying at the same time. The '
            'window is a reason to begin now, not a reason to wait.'),
      ),
      PvReadFaq(
        question: _en('Should I stop my regular medication?'),
        answer: _en('Never on your own. This is one of the most important '
            'lines on this page. Some medicines do need changing before '
            'pregnancy, and some conditions are far more dangerous untreated '
            'than the medicine ever was. Take the full list to your doctor and '
            'let them decide which is which.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Book before you start trying, not after'),
      body: _en('See a doctor first if you take regular medicine of any kind, '
          'especially for epilepsy, thyroid, diabetes, blood pressure, acne or '
          'mental health. Do the same if you have a long-term condition, a '
          'past pregnancy affected by a neural tube defect, or a family '
          'history of thalassaemia or another inherited condition. All of '
          'these change which dose or which drug is right, and all are far '
          'easier to sort out before conception than after it.'),
    ),

    evidence: _en('Folic acid dosing follows FOGSI Good Clinical Practice '
        'Recommendations on Preconception Care: 400 to 500 mcg daily for '
        'low-risk women, started at least a month before conception, and 4 to '
        '5 mg for defined high-risk groups. How long eggs and sperm take to '
        'mature, and which deficiencies come first, follow the Indian Academy '
        'of Pediatrics consensus guidelines on preconception care (2024). The '
        'preconception visit follows FOGSI preconception care guidance and '
        'ACOG. Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Next: the tests and vaccinations'),
        value: _en('The errands worth doing once, including the two vaccines '
            "that need a month's notice."),
        surfaceId: 'ttc_read/ttc_read_preconception_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Record what you're taking"),
        value: _en('What you started and when. Every doctor asks, and nobody '
            'remembers.'),
        surfaceId: 'ttc_supplements',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a preconception nutritionist'),
        value: _en('A plan built around how your family really eats, not a '
            'printout.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: [
      'ttc_read_preconception_tests',
      'ttc_read_first_gyn_visit',
      'ttc_read_money_before_baby',
    ],
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
    teaser: _en('A short list of errands, done once. Two vaccines need a '
        "month's notice, and one blood test matters more in India than almost "
        'anywhere else.'),
    shortAnswer: _en('Before trying, a few cheap blood tests are worth doing '
        'once, along with thalassaemia carrier screening and a check that '
        "you're immune to rubella and chickenpox. If you aren't immune, the "
        "vaccine needs a month's wait before you conceive, so do it first. "
        'Infection tests for both of you and a smear test are worth doing now '
        'too.'),

    scaleSetter: _en("This isn't a fertility work-up, and it isn't a sign "
        "anything is wrong. It's a handful of cheap tests that often come back "
        "abnormal in Indian adults. They're easy to correct, and much easier "
        'to deal with now than at eight weeks pregnant.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    heroVideoSlot: 'ttc_vid_preconception_tests',

    sections: [
      PvReadSection(
        heading: _en('Which blood tests should I have?'),
        paragraphs: [
          _en('None of these checks your fertility. They look for things that '
              'are common, silent and fixable with a tablet. Each one is '
              'better found now than six months in.'),
        ],
        bullets: [
          _en('Haemoglobin. Anaemia is very common in Indian women of '
              "childbearing age. It's worth correcting before pregnancy adds "
              'to the demand.'),
          _en("TSH, for thyroid. Thyroid problems that aren't fully treated "
              'affect both your cycles and early pregnancy, and the fix is a '
              'daily tablet.'),
          _en('Vitamin D and vitamin B12. Both are often low here, both are '
              'cheap, and both are easy to correct.'),
          _en('Blood sugar: fasting glucose or HbA1c. Especially worth doing '
              'if diabetes runs in your family or you have PCOS.'),
          _en("Blood group and Rh type, for both of you, if you don't already "
              'know them.'),
        ],
      ),

      PvReadSection(
        heading: _en('What if my blood group is Rh negative?'),
        paragraphs: [
          _en('Most people are Rh positive. If you are Rh negative and your '
              'partner is Rh positive, your baby may be Rh positive. In '
              'pregnancy your body can then make antibodies against the '
              "baby's blood, which can affect a later pregnancy."),
          _en('This is easy to prevent. An injection called anti-D is given '
              'during pregnancy, after the birth, and after any bleeding or '
              'loss. Nothing needs doing before you conceive. Just know your '
              'group and tell every doctor you see.'),
        ],
      ),

      PvReadSection(
        heading: _en('Which test matters more in India?'),
        paragraphs: [
          _en('Thalassaemia carrier screening. It stands apart because of what '
              'FOGSI recommends: it should be offered to all couples, whatever '
              'their family history, before pregnancy or at the first '
              'antenatal visit.'),
          _en("That's a deliberately wide recommendation, and it's wide "
              'because carriers have no symptoms at all. Beta-thalassaemia '
              'carrier rates are high across several Indian communities, and a '
              'carrier usually has no idea.'),
          _en("What matters is when both partners are carriers. That's why "
              "it's a test for the couple, not just for the woman."),
          _en("The test is called haemoglobin HPLC. It's widely available and "
              'inexpensive. If you do it once in your life, now is the time.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Being a carrier is not being ill'),
          body: _en('A thalassaemia carrier is healthy and stays healthy. The '
              'result only matters if your partner is also a carrier. Even '
              'then, it starts a conversation with a genetic counsellor about '
              "your options. It doesn't close anything. Most people who are "
              "screened come back clear, and those who don't are better off "
              'knowing early than late.'),
        ),
      ),

      PvReadSection(
        heading: _en('Which vaccines do I need, and why does timing matter?'),
        paragraphs: [
          _en("Start with the reassuring part, because it's true and hardly "
              'anyone says it: about 85 in 100 Indian women of childbearing '
              'age are already immune to rubella. For most people, this whole '
              'section comes down to one blood test that comes back fine.'),
          _en("It still belongs before pregnancy rather than during. It's the "
              'one part of getting ready with a real deadline. And that '
              'deadline only applies to the roughly one in seven whose test '
              "shows they aren't immune."),
          _en('Rubella is the important one. Caught in early pregnancy, it can '
              "seriously harm a baby. That's why congenital rubella syndrome "
              'has its own name.'),
          _en('Most Indian women had the vaccine as a child, '
              'but few have the record. The blood test that settles it is '
              "called rubella IgG, and it's worth asking for by name."),
        ],
      ),

      PvReadSection(
        heading: _en("What if I'm not immune?"),
        paragraphs: [
          _en("If you're not immune, you get the MMR vaccine and then wait. "
              'MMR is a live vaccine, so the advice is to avoid getting '
              'pregnant for about a month (28 days) after it.'),
          _en("That's the whole "
              'reason this comes before trying. If you only find out at your '
              'first antenatal visit, the window has already passed.'),
          _en("Varicella (chickenpox) works the same way. If you've never had "
              "it and never been vaccinated, it's two doses four weeks apart, "
              'and again a month before you conceive.'),
        ],
        tip: PvReadTip(
          title: _en('"I\'ve already had TT injections": the most common '
              'mix-up here'),
          body: _en('TT and Td protect against tetanus and diphtheria. They '
              "don't protect against whooping cough, and whooping cough is the "
              "one that's dangerous to a newborn in the first months. Tdap is "
              'the version that adds it. Its antibodies cross the placenta and '
              'protect the baby before it can be vaccinated itself. FOGSI has '
              'recommended Tdap in pregnancy since 2014, at 27 to 36 weeks. '
              "You can have it even if you've already had two doses of TT. It "
              "isn't a double dose to worry about. It's a different vaccine "
              'doing a different job.'),
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
        heading: _en('Will anyone offer me these vaccines?'),
        paragraphs: [
          _en('This is the part that makes the difference in India. The '
              'Universal Immunization Programme covers Td at ten and sixteen, '
              'and tetanus protection during pregnancy. Adult MMR, varicella, '
              'Tdap, influenza and hepatitis B are all outside it.'),
          _en('In practice, that means you get them privately. You pay for '
              'them, and more importantly, nobody will bring them up unless '
              "you do. In most of the country, a routine antenatal visit won't "
              "ask whether you're immune to rubella."),
          _en('So take this page, or a written list, to your appointment. The '
              'most useful thing you can say there is to ask for rubella IgG '
              'by name.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Ask about the flu vaccine each season'),
          body: _en("The influenza vaccine isn't a live vaccine. It's safe in "
              "pregnancy, and it's recommended. But it's seasonal, and how "
              "easy it is to find in India changes through the year. If you're "
              "planning to conceive, ask about it whenever this season's "
              'vaccine is in stock, rather than waiting for someone to offer '
              'it.'),
        ),
      ),

      PvReadSection(
        heading: _en('Why test for infections, both of you?'),
        paragraphs: [
          _en('Some infections passed on during sex cause no symptoms at all. '
              'Chlamydia and gonorrhoea are the main ones. Left alone, they '
              'can inflame and block the fallopian tubes, and in men they can '
              'affect sperm.'),
          _en('Both of you are tested because an infection can pass back and '
              'forth. Treating only one person means it comes back. Asking '
              "for these tests isn't a comment on anyone's past or on your "
              'relationship. Doctors suggest them for everyone.'),
          _en('Tests for HIV, syphilis and hepatitis B are usually part of the '
              'antenatal blood tests anyway. Doing them before pregnancy, not '
              'during, takes an anxious wait out of your first appointment.'),
          _en('The syphilis test, often called VDRL, is routine in India. If '
              'it is positive, treatment is a course of penicillin injections, '
              'and treating it before pregnancy protects the baby. If your '
              'hepatitis B test shows you are not immune, the vaccine can be '
              'given now.'),
        ],
      ),

      PvReadSection(
        heading: _en('Should I have a smear test first?'),
        paragraphs: [
          _en('A smear test, or Pap test, checks the cervix for early cell '
              'changes, long before any cancer. Many Indian women have never '
              'had one. It is easier to do before pregnancy, and guidance in '
              'India suggests starting from about 25 to 30.'),
          _en('The doctor gently opens the vagina with a speculum and takes '
              'cells from the cervix with a soft brush. It takes a minute. It '
              "can feel uncomfortable, but it shouldn't hurt. Book it for a "
              'day when you are not bleeding.'),
          _en('Most unusual results are small changes, often caused by HPV, a '
              'common virus, and many clear up on their own. Your doctor may '
              'repeat the test or take a closer look with a magnifier, called '
              'a colposcopy.'),
          _en('If treatment is needed, it is usually a short procedure. Tell '
              'your doctor you are planning a pregnancy, because it can change '
              'the timing.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Why a doctor may do a pelvic exam'),
          body: _en('It lets the doctor check the size and position of your '
              'womb and ovaries, and look for signs of infection, fibroids or '
              "cysts. It takes a few minutes. You can ask for a woman doctor "
              'or for someone to stay with you, and you can ask to stop at any '
              'point.'),
        ),
      ),

      PvReadSection(
        heading: _en('Which tests does your partner need?'),
        paragraphs: [
          _en("It's shorter, and it's usually skipped altogether. A semen "
              "analysis isn't part of a routine check before pregnancy, and "
              "isn't needed unless there's a reason. But thalassaemia "
              'screening is on his list, because it only means something as a '
              'pair.'),
          _en('Beyond that: his blood group, and a talk about his own regular '
              'medicines. Several common ones affect sperm production, and '
              'almost nobody thinks to mention them.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Real, easily forgotten, and not what she came here for.
        collapsible: true,
        summary: _en('Dental work and the medicine review, the two most often '
            'forgotten.'),
        heading: _en('What else is easy to forget?'),
        paragraphs: [
          _en('Dental. Gum disease is linked to babies being born early, and '
              "treatment is harder once you're pregnant. A cleaning now is "
              "easy. It's the item most often forgotten on any list for before "
              'pregnancy.'),
          _en("A medicine review. After the rubella test, it's the most "
              'important thing on this page. Take everything you both take to '
              'a doctor in one go: prescriptions, over-the-counter tablets, '
              'ayurvedic and herbal remedies, and supplements.'),
          _en('Some need changing before conception. Some conditions are far '
              'more dangerous untreated than the medicine ever was. '
              "That's not a call to make from an article."),
          // The HIV, syphilis and hepatitis B paragraph moved up into "Why
          // test for infections, both of you?" (2026-09-26), same words.
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('I had MMR as a child. Do I still need the test?'),
        answer: _en("It's worth it, because what matters is whether you're "
            'immune, not what the record says. A small number of people '
            "vaccinated as children aren't immune as adults. And most people "
            "can't find their childhood card anyway. It's one line on a blood "
            'form.'),
      ),
      PvReadFaq(
        question: _en('What if I get pregnant by accident within a month of '
            'MMR?'),
        answer: _en("Tell your doctor, and don't panic. The one-month wait is "
            'a precaution, not a known harm. Where this has happened, no '
            'pattern of vaccine-caused congenital rubella syndrome has been '
            "found. It isn't a reason to consider ending a pregnancy."),
      ),
      PvReadFaq(
        question: _en('Is all of this expensive?'),
        answer: _en("The blood tests don't cost much. Most are routine, widely "
            'available tests, and many labs offer them as a package. Hb HPLC '
            'for thalassaemia and rubella IgG are each inexpensive on their '
            "own. It's a one-time cost, not a repeat one."),
      ),
      PvReadFaq(
        question: _en('Can I just do all this at my first antenatal visit '
            'instead?'),
        answer: _en('Most of it, yes. The vaccines are the exception, and '
            "they're the reason this list exists. A live vaccine can't be "
            "given in pregnancy. So if you're not immune to rubella, the "
            'chance to fix it is gone until after the baby.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Take this list to a doctor, don't order it yourself"),
      body: _en('A gynaecologist or a GP can order all of this in one visit. '
          'More importantly, they can read the results alongside your own '
          'history. Go sooner rather than later if you take regular medicine, '
          'if either family has a history of thalassaemia or another inherited '
          'condition, or if you have any long-term condition at all. And if a '
          "rubella result shows you aren't immune, make the vaccine something "
          'you do this month, not next.'),
    ),

    evidence: _en('Thalassaemia carrier screening offered to all couples '
        'irrespective of family history, via Hb HPLC at the preconception '
        'stage or first antenatal visit, follows FOGSI Good Clinical Practice '
        'Recommendations. The preconception vaccine review (rubella and '
        'varicella immunity with at least a one-month wait before conceiving '
        'after a live vaccine, hepatitis B where needed, and up-to-date Tdap '
        'and influenza) follows FOGSI preconception care guidance and the CDC '
        'and ASRM recommendations for patients planning pregnancy. The rubella '
        'immunity figure is from Indian surveys of pregnant women, which put '
        'immunity at roughly 85 per cent in 2022 and 82 to 83 per cent in the '
        '2017 and 2019-20 rounds. Testing both partners for chlamydia, '
        'gonorrhoea, HIV, syphilis and hepatitis B follows CDC and NICE CG156. '
        'Cervical screening follows the Government of India operational '
        'framework for cancer screening and FOGSI guidance, and anti-D for Rh '
        'negative mothers follows RCOG and NICE. Sources checked September '
        '2026.'),

    nextSteps: [
      // ⚠️ THE VACCINATION TOOL FIRST, NOT THE TEST LIBRARY. This read's whole
      // point is that vaccination has a deadline; the screen is where that
      // deadline is actually tracked, and reading about it without recording
      // anything is how a woman ends up learning it twice.
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Check your vaccinations'),
        value: _en('Which ones to ask for by name, and whether any of them '
            'means waiting a month.'),
        surfaceId: 'ttc_vaccinations',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The full test library'),
        value: _en('Every test explained, when in your cycle to take it, and '
            'what it costs in India.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep the reports together'),
        value: _en('One place for all of it, so your next doctor sees the '
            'whole picture in a minute.'),
        surfaceId: 'ttc_records',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Back to: the three months before'),
        value: _en('Diet, folic acid and weight: the other half of getting '
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
    title: _en('Folic acid: why you need it before, not after'),
    teaser: _en('Of everything on the getting-ready list, this has the '
        "strongest evidence behind it. It's also the one whose timing is most "
        'often missed.'),
    shortAnswer: _en('Start folic acid, 400 micrograms daily, at least a month '
        'before you try, and keep going until twelve weeks into pregnancy. It '
        'protects '
        "the baby's brain and spine as they form, which happens before most "
        "women know they're pregnant. If you started late, start now."),
    scaleSetter: _en("It's cheap, every chemist sells it, and it's the most "
        "useful thing you can start today. It also isn't urgent in a scary "
        'way. Starting a month before you conceive covers what matters, and if '
        "you started late, you haven't done harm you need to carry."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Folic acid is the man-made form of folate, a B vitamin your '
              'body uses to build new cells. In very early pregnancy it does '
              'one specific job. It helps close the neural tube, the part that '
              "becomes the baby's brain and spinal cord."),
          _en('That closing happens in the first four weeks after conception. '
              "That's the whole reason this article exists."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does the timing matter so much?'),
        paragraphs: [
          _en('Four weeks after conception is roughly when a period is missed. '
              'So for most women, the window folic acid protects has already '
              'closed by the time a test turns positive.'),
          _en('Starting when you find out still helps, because folate keeps '
              'doing other work all through pregnancy. But the protection this '
              'vitamin is known for has to be in place already.'),
          _en("That's why every guideline says to start before conceiving, "
              'ideally at least a month before.'),
          _en("If a pregnancy wasn't planned, or you started late, start now "
              "and don't spend a moment on guilt. Most pregnancies where folic "
              'acid began late are completely fine.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('The evidence here is unusually strong'),
          body: _en('Folic acid taken before conception greatly lowers the '
              "risk of neural tube defects. It's one of the clearest findings "
              "in pregnancy care. It has been repeated over decades, and it's "
              'the reason dozens of countries add folic acid to flour.'),
        ),
      ),
      PvReadSection(
        heading: _en('How much should I take, and which kind?'),
        paragraphs: [
          _en('The usual amount is 400 micrograms a day. Take it from at least '
              'a month before conceiving through the first twelve weeks.'),
          _en('Take it at a time you already remember, like with breakfast or '
              'after brushing your teeth. If you miss a day, take the next '
              "one as usual. There's no need to double up."),
          _en('Plain folic acid is what the research used. A multivitamin for '
              'before pregnancy with 400 mcg works just as well, and is often '
              'easier to remember.'),
          _en("What you shouldn't do is take a general multivitamin without "
              'checking it. Some contain vitamin A as retinol, which '
              "isn't recommended in pregnancy."),
          _en("Food helps, but it doesn't replace the tablet. Dal, spinach, "
              'methi, chickpeas, citrus and fortified cereals all have folate, '
              'but almost nobody gets the protective amount from food alone.'),
        ],
      ),
      PvReadSection(
        heading: _en('When is a higher dose needed?'),
        paragraphs: [
          _en('Some women are advised to take 5 milligrams a day instead of '
              "400 micrograms. That's more than ten times the standard amount, "
              "and it's for a doctor to prescribe, not something to pick off a "
              'shelf.'),
          _en("It's usually considered after a past pregnancy affected by a "
              'neural tube defect, or if the mother has diabetes, epilepsy '
              'treated with certain medicines, coeliac disease, sickle cell '
              'disease, or a high BMI.'),
          _en('If any of these apply to you, bring it up at your next '
              'appointment instead of changing the dose yourself.'),
        ],
      ),
      PvReadSection(
        heading: _en('What else is worth taking?'),
        paragraphs: [
          _en('Vitamin D is the other one with good support. Low levels are '
              'very common in India, even in people who spend time outdoors, '
              'because clothing, air pollution and skin tone all reduce how '
              'much the body makes.'),
          _en('Ten micrograms a day is the usual advice, and a blood test will '
              'tell you if you need more.'),
          _en("Iodine matters for the baby's growing brain and is easy to "
              'cover. Iodised salt in everyday cooking is enough for most '
              'people.'),
          _en('Check your iron rather than guessing. Anaemia is common and '
              "makes pregnancy harder. But iron you don't need causes "
              'constipation and nausea for no benefit. A blood count settles '
              'it.'),
        ],
      ),

      PvReadSection(
        heading: _en("What isn't worth buying?"),
        paragraphs: [
          _en("What isn't worth buying is the long list of fertility blends "
              'sold with confident words and no evidence: coenzyme Q10, '
              'inositol outside PCOS, royal jelly, most herbal mixes.'),
          _en('Some are harmless and expensive. A few interact with real '
              "medicines. That's why it's worth mentioning anything you take "
              'at an appointment, even if it came from a health shop and not '
              'a pharmacy.'),
        ],
      ),

      PvReadSection(
        heading: _en('Does my partner need folic acid?'),
        paragraphs: [
          _en("Folate plays a part in making sperm too, which is why it's in "
              "most men's supplements for before pregnancy. But the evidence "
              'there is much weaker than it is for the neural tube.'),
          _en("And it doesn't replace the three things that do have evidence "
              'on his side: not smoking, drinking in moderation, and keeping '
              'heat down.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask before you change the dose'),
      body: _en('If you have epilepsy, diabetes, coeliac disease, a past '
          'pregnancy affected by a spinal problem, or you already take other '
          'supplements or medicines, ask a doctor which dose is right for you '
          'before you start. This is one of the few places where more is '
          "sometimes better. It's a decision that needs your history, not an "
          'article.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en("I've taken it for months and I'm not pregnant yet. Is "
            'that a problem?'),
        answer: _en("No. Folic acid isn't a fertility treatment and doesn't "
            "change how quickly you conceive. It's protection kept ready for "
            'whenever conception happens. Taking it for a long time at the '
            'standard amount does no harm.'),
      ),
      PvReadFaq(
        question: _en('Can I just eat more spinach instead?'),
        answer: _en('Not reliably. Your body absorbs folate from food less '
            "well than from a tablet, and it's hard to get the protective "
            'amount from food alone. Eat the greens as well, not instead.'),
      ),
      PvReadFaq(
        question: _en('Is there harm in taking it if I stop trying?'),
        answer: _en('At 400 mcg, no. It dissolves in water, and your body '
            "passes out what it doesn't use. The caution is only about very "
            'high doses taken without a reason.'),
      ),
    ],
    evidence: _en('NICE guideline NG201 (antenatal care); WHO recommendations '
        'on antenatal care; RCOG and NHS preconception folic acid guidance; '
        'Cochrane review of periconceptional folate supplementation. Sources '
        'checked September 2026.'),
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
    teaser: _en("It's a short list, and shorter than the internet suggests. "
        "Three things that really matter, and several that don't."),
    shortAnswer: _en('Three changes have real evidence behind them: stop '
        "smoking and tobacco, stop alcohol while you're trying, and keep "
        'caffeine to '
        'about 200 mg a day, roughly two mugs of instant coffee. They matter '
        'for both of you. Spicy '
        'food, papaya in normal amounts and everyday exercise are fine.'),
    scaleSetter: _en('Most of what gets passed around as "must give up before '
        'trying" has little behind it, and worrying about all of it has its '
        'own cost. Three changes have real evidence. The rest of this piece is '
        'mostly about the things you can stop feeling guilty about.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("There's a way of getting ready that turns into a list of bans. "
              'It makes people miserable without making them more likely to '
              'conceive. This is the other way.'),
          _en("Three things are worth changing, and they're worth changing for "
              'both of you, not just for you. Everything after that is '
              'optional, and some of it is folklore.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does smoking matter, even second-hand?'),
        paragraphs: [
          _en('This one has the least argument around it. Smoking affects '
              "fertility in both partners. It's linked to taking longer to "
              'conceive, a lower egg reserve, and poorer sperm quality and '
              'movement. It also raises the risk of miscarriage once a '
              'pregnancy starts.'),
          _en("Second-hand smoke counts. Someone who doesn't smoke but shares "
              "a home or a car with a smoker is still exposed. That's one of "
              "several reasons this isn't only a woman's item."),
          _en("Stopping is really hard, and willpower isn't the whole story. "
              'Nicotine patches or gum, support from a doctor and quitlines '
              'exist because stopping alone works for only a few people. If '
              "you've tried and it didn't last, that's the usual result of "
              "trying alone. It isn't a verdict on you."),
        ],
      ),
      PvReadSection(
        heading: _en('Do I need to stop drinking?'),
        paragraphs: [
          _en("The clear part first. Once you're pregnant, no amount is known "
              "to be safe. A pregnancy doesn't show for several weeks, so "
              'advice in most countries is to stop while trying, not when a '
              'test turns positive.'),
          _en('The less clear part: whether light drinking affects how quickly '
              'you conceive is still argued over. Heavy drinking is linked to '
              'taking longer. The evidence at low levels is mixed, and honest '
              'advice says so instead of pretending to be sure just to keep '
              'things tidy.'),
          _en('In practice, cutting down is worth doing, and a glass at a '
              "wedding four months ago isn't something to lie awake about. For "
              'him, heavy drinking is linked to poorer semen quality. Ordinary '
              'amounts are less clear there too.'),
        ],
      ),
      PvReadSection(
        heading: _en('Do I have to give up tea and coffee?'),
        paragraphs: [
          _en('Most advice is to limit caffeine, not stop it. The limit '
              "usually given is about 200 mg a day in pregnancy. That's "
              'roughly two mugs of instant coffee, and Indian filter coffee '
              'and strong tea both count toward it.'),
          _en("It's worth knowing what else has caffeine. Cola, energy drinks, "
              'green tea and dark chocolate all add to it. Several '
              'over-the-counter painkillers contain caffeine too, without '
              'saying so clearly on the front.'),
          _en("You don't need to get to zero. Stopping all at once usually "
              'brings three days of headache, which helps nobody. Cutting from '
              'four cups to two is the change that matters.'),
        ],
      ),
      PvReadSection(
        heading: _en('What can I stop worrying about?'),
        paragraphs: [
          _en("Spicy food doesn't affect fertility. Neither do papaya and "
              'pineapple, in the amounts people eat. The enzyme stories about '
              'both come from lab amounts, not from a bowl of fruit.'),
          _en("Everyday exercise is good for you and doesn't need to stop. "
              'Warm baths are fine for you. Heat matters more for him, and '
              'even there the effect is small and reversible.'),
          _en('Sex doesn\'t need rationing to "save up". For most couples, '
              'every day or every other day around the fertile window is fine, '
              "and going without for long stretches doesn't help."),
          _en('And none of this is a reason to go back over the last six '
              "months. What you did before you decided to try can't be "
              "changed, and it's very unlikely to be the reason for anything."),
        ],
      ),
      PvReadSection(
        heading: _en("What about the things I can't avoid?"),
        paragraphs: [
          _en("Some exposures aren't lifestyle choices. If you work with "
              'solvents, pesticides, some paints, lead or certain industrial '
              'chemicals, mention it to a doctor. The answer may be protective '
              'equipment or a short-term change, not leaving your job.'),
          _en("The same goes for prescribed medicines. Don't stop anything you "
              'were told to take just to be "clean" before trying. Stopping a '
              'medicine that manages a real condition is usually riskier than '
              "carrying on with it. That's something to talk through, not a "
              'decision to make alone.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't stop a prescribed medicine to get ready"),
      body: _en('If you take something regularly, for thyroid, blood pressure, '
          'epilepsy, diabetes, mental health or anything else, talk to the '
          'doctor who prescribed it before changing anything. Some are swapped '
          'for a different one before pregnancy, and some are carried on '
          "unchanged. Stopping suddenly is almost never right. If you're "
          "trying to stop smoking or drinking and it isn't lasting, ask for "
          'help rather than trying harder alone.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Does he have to stop too?'),
        answer: _en('For smoking, yes, for the same reasons plus one more: you '
            'breathe it in too. For alcohol, heavy drinking is worth cutting. '
            "Beyond that, doing it together mostly helps because it's easier "
            'than doing it alone.'),
      ),
      PvReadFaq(
        question: _en('How long before trying should I change things?'),
        answer: _en('Sperm take roughly two to three months to develop, so '
            'changes on his side show up on about that timescale. On your side '
            "there's no waiting period. Earlier is better, and starting today "
            'is fine.'),
      ),
      PvReadFaq(
        question: _en('I drank before I knew I was pregnant. What now?'),
        answer: _en('Tell your doctor honestly, and then stop. This is common, '
            'and your doctor has heard it many times. What helps is stopping '
            'now, not counting backwards.'),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems: assessment and treatment); '
        'NHS preconception guidance; RCOG statements on alcohol and on smoking '
        'in pregnancy; the UK Chief Medical Officers’ alcohol guidelines; EFSA '
        'opinion on caffeine intake. Sources checked August 2026.'),
    readNext: ['ttc_read_three_months_before'],
  ),

  PvRead(
    id: 'ttc_read_supplement_timing',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('When to start what, and how early'),
    teaser: _en('Folic acid has a deadline that has already passed by the time '
        "most people find out they're pregnant. Almost nothing else does."),
    shortAnswer: _en('Start folic acid at least a month before you try. Check '
        'vitamin D, iron and B12 with a blood test before taking them, '
        "especially if you're vegetarian. Most fertility blends have little "
        'evidence behind them, and high-dose vitamin A is best avoided.'),
    scaleSetter: _en('This is about timing, not a shopping list. One '
        'supplement really needs to start before you conceive. A couple are '
        'worth checking your levels for. Most of the rest are sold on hope. '
        'Nothing here replaces asking a doctor what you need.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The supplement aisle is designed to make you feel late. Most of '
              "it isn't urgent, and some of it isn't useful. But one thing "
              'really is time-sensitive, and it helps to keep that separate '
              'from everything else.'),
        ],
      ),
      PvReadSection(
        heading: _en('When should I start folic acid?'),
        paragraphs: [
          _en('This is the one with a real deadline. The neural tube, which '
              'becomes the brain and spinal cord, closes in the first few '
              'weeks, often before a period is missed.'),
          _en('Folic acid has to be in your system already when that happens. '
              'So starting on a positive test is starting late.'),
          _en('Advice is to begin at least one month before conception and '
              'carry on through the first twelve weeks. Three months ahead '
              "gives you a comfortable margin, but it isn't a must."),
        ],
      ),
      PvReadSection(
        heading: _en('How much folic acid do I need?'),
        paragraphs: [
          _en('The standard amount is 400 micrograms a day. A higher dose is '
              'advised for some people: a past pregnancy affected by a neural '
              'tube defect, diabetes, epilepsy medicine, certain conditions '
              'that affect absorption, and, in some guidance, a higher body '
              'weight.'),
          _en("That's for a doctor to prescribe, not something to pick off a "
              'shelf.'),
          _en("If you're already pregnant and haven't been taking it, start "
              'today. Later is better than not at all, and nobody needs a '
              'lecture about the weeks already gone.'),
        ],
      ),
      PvReadSection(
        heading: _en('Should I take vitamin D?'),
        paragraphs: [
          _en("Low vitamin D is common in India despite the sunshine. That's "
              'mostly because of indoor work, clothing and air pollution, not '
              'where India sits on the map. Taking it in pregnancy is widely '
              'advised.'),
          _en('The honest answer: a blood test tells you where you are, and '
              'the dose for someone who is very low is different from an '
              'everyday amount. So ask about this one rather than picking it '
              'off a shelf. The test is inexpensive.'),
        ],
      ),
      PvReadSection(
        heading: _en('Do I need iron or B12?'),
        paragraphs: [
          _en("Anaemia is common enough among Indian women that it's worth "
              'knowing your numbers before pregnancy, not finding out at your '
              "first antenatal visit. It's easier to fix beforehand than when "
              "you're pregnant and feeling sick."),
          _en('Low B12 is common on long-term vegetarian and vegan diets, '
              "which describes a great many homes here. It's easy to test and "
              'easy to correct.'),
          _en('Iron is the one supplement where more is clearly not better. '
              'Taking it without a reason can cause real problems. So test '
              'first, then treat, rather than taking it just in case.'),
        ],
      ),
      PvReadSection(
        heading: _en("What if we're vegetarian?"),
        paragraphs: [
          _en('A vegetarian diet can give you everything you need for '
              'pregnancy. It just leaves a few gaps that are worth closing on '
              'purpose, and they matter for many Indian homes.'),
        ],
        bullets: [
          _en('B12 comes only from animal foods. Milk, curd, paneer and eggs '
              'give some. If you eat no dairy or eggs, you will need fortified '
              'foods or a supplement, so ask for a B12 test.'),
          _en('Iron from plants is harder for the body to absorb. Pair dal, '
              'greens, rajma, poha or jaggery with vitamin C, like lemon, amla '
              'or guava, and keep tea and coffee an hour away from meals.'),
          _en('Protein adds up from dal with rice or roti, paneer, curd, soya, '
              'sprouts and nuts. A little at every meal is easier than a lot '
              'at one.'),
          _en('Omega-3 fats are harder to get without fish. Flaxseed, walnuts '
              'and chia help, and the omega-3 read in this door goes through '
              'the rest.'),
        ],
        mythFact: PvMythFact(
          myth: _en('A vegetarian diet makes it harder to get pregnant.'),
          fact: _en("There's no good evidence for this. A varied vegetarian "
              'diet supports fertility and pregnancy well. What matters is '
              'closing the few gaps above, which a blood test and a little '
              'planning take care of.'),
        ),
      ),
      PvReadSection(
        heading: _en('Do fertility supplements work?'),
        paragraphs: [
          _en('Fertility blends, most antioxidant mixes, and a long list of '
              'branded formulas for before pregnancy are sold on ingredients '
              "that sound good. There's little evidence that they help people "
              'conceive.'),
          _en("That doesn't make them harmful. It makes them expensive, and it "
              "means you don't need to feel guilty for not buying them."),
          _en("If a blend contains 400 mcg of folic acid and you'd otherwise "
              "take a folic acid tablet, it's a costlier way to do the same "
              'thing.'),
          _en("Here's an honest look at what's most often sold. Check with "
              'your doctor before you start any of them.'),
        ],
        bullets: [
          _en('Folic acid: yes. It protects the baby, though it doesn\'t make '
              'you conceive faster.'),
          _en('Vitamin D: worth it if a test shows you are low. There is no '
              'proof it speeds up conception.'),
          _en('Myo-inositol: some evidence that it helps cycles in PCOS. '
              'Outside PCOS, little evidence.'),
          _en('Coenzyme Q10: small studies, mostly in IVF. Not proven for '
              'trying naturally.'),
          _en('DHEA: only when a fertility specialist prescribes it for a '
              'specific reason. Not something to buy yourself.'),
          _en("Omega-3: good for your health and the baby's brain in "
              'pregnancy. No proof it helps you conceive.'),
          _en("Men's antioxidant blends: large, careful trials found they "
              "didn't lead to more pregnancies."),
          _en('Royal jelly, maca and most herbal fertility mixes: no good '
              'evidence, and some interact with medicines.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is vitamin A safe?'),
        paragraphs: [
          _en('One warning that matters: vitamin A in high doses, especially '
              "as retinol, isn't safe in pregnancy. Check any multivitamin for "
              "it, and be careful with general supplements that aren't made "
              'for people who might conceive.'),
          _en('Avoid high-dose vitamin A supplements and fish liver oil '
              "capsules while you're trying, and keep liver dishes occasional. "
              'Vitamin A from everyday food, like carrots, mango, papaya and '
              'spinach, is fine.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should I check on the box?'),
        paragraphs: [
          _en("Two units appear on these boxes, and they're a thousand times "
              'apart. Folic acid is measured in micrograms, written mcg or ug, '
              'and the standard amount is 400 of them.'),
          _en('A box showing 5 mg (milligrams) is a prescription-strength '
              "tablet. It isn't a stronger version of the same thing. It's "
              'meant for specific situations, not for everyday use.'),
          _en('Combination products vary a lot. Two boxes both labelled '
              '"preconception" can contain quite different things. So turn the '
              "box over and read what's inside, rather than trusting the word "
              'on the front.'),
          _en('Check for vitamin A, listed as retinol or retinyl palmitate. '
              "General multivitamins sometimes contain amounts that aren't "
              "right for someone who might conceive, and it isn't always "
              'pointed out.'),
          _en('One practical tip: keep the box, or take a photo of it. At an '
              'appointment, "a white tablet, some kind of multivitamin" '
              "doesn't give a doctor anything to go on. The label takes two "
              'seconds to show.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about your partner?'),
        paragraphs: [
          _en('Sperm take roughly two to three months to develop, so anything '
              'he changes shows up on that timescale, not straight away. '
              "That's a reason to start early, not to panic about the last two "
              'months.'),
          _en("The evidence for men's fertility supplements is weaker than the "
              'adverts suggest. A decent diet, less alcohol, no smoking and '
              'enough sleep have better support than any capsule.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask before taking a higher dose of anything'),
      body: _en('If you have diabetes, epilepsy, coeliac disease, a past '
          'pregnancy affected by a neural tube defect, or take medicines that '
          'affect folate, your folic acid dose may need to be several times '
          "the standard one. That's prescribed, not chosen. In the same way, "
          "don't take iron or high-dose vitamin A unless you've been told to. "
          "If you already take something and aren't sure, bring the box itself "
          'to your next appointment instead of describing it.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('I started folic acid late. Have I ruined something?'),
        answer: _en('No. Start now and carry on through the first twelve '
            'weeks. Most people who conceive without planning start late, and '
            "most pregnancies are fine. It's a reason to start today, not a "
            'reason to look back.'),
      ),
      PvReadFaq(
        question: _en('Do I need a special preconception multivitamin?'),
        answer: _en('Not necessarily. What you need is folic acid, plus '
            "anything a blood test says you're low in. A multivitamin is "
            "handy, but it isn't automatically better. Check that it doesn't "
            'contain high-dose vitamin A.'),
      ),
      PvReadFaq(
        question: _en('How long before trying should I start?'),
        answer: _en('At least one month for folic acid, and three is '
            'comfortable. For anything based on a blood test, allow time to '
            'test and then correct. A couple of months is realistic.'),
      ),
    ],
    evidence: _en('NICE NG201 (antenatal care); WHO antenatal care '
        'recommendations; RCOG and NHS preconception guidance; ICMR-NIN '
        'dietary guidelines for Indians and national data on anaemia '
        'prevalence; Cochrane reviews of periconceptional folate and of '
        'antioxidants for male subfertility; the FAZST and MOXI trials of '
        "men's supplements; ESHRE and ASRM guidance on add-ons and on "
        'inositol in PCOS; WHO guidance on vitamin A in pregnancy. Sources '
        'checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('A week of meals, planned for you'),
        value: _en('Seven days of Indian vegetarian food that covers iron, '
            'B12 and protein without a special diet.'),
        surfaceId: 'ttc_read/ttc_read_meal_plan_week',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Record what you're taking"),
        value: _en('What you started and when, so any doctor can see it at a '
            'glance.'),
        surfaceId: 'ttc_supplements',
      ),
    ],
    readNext: [
      'ttc_read_folic_acid',
      'ttc_read_iron_before_pregnancy',
      'ttc_read_ask_dietitian',
    ],
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
    teaser: _en("Weight does affect fertility. It's also the subject that "
        'hurts people most often, and the helpful version of this talk has no '
        'target in it.'),
    shortAnswer: _en('Weight can affect ovulation at both ends. Carrying a lot '
        'more or a lot less can make periods irregular or stop them. You '
        "don't need to reach a target first: a small, steady change often "
        'helps, and treating a cause like thyroid or PCOS matters more than '
        'willpower.'),
    scaleSetter: _en("There's no number in this piece, on purpose. Weight is "
        'one factor among several. It shifts the odds rather than deciding '
        "anything, and a target you can't reach is worse than no target at "
        'all. What helps is direction. Even a small change in the right '
        'direction does more than most people expect.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Most people coming to this subject have already been told '
              'something about it, usually bluntly, often by someone nobody '
              'asked. So first: weight is one factor among several. Plenty of '
              'people conceive at every size. And nothing here is a judgement '
              'on whether you deserve a baby.'),
          _en("Second: it does matter, and pretending it doesn't would be its "
              'own kind of unkindness.'),
        ],
      ),
      PvReadSection(
        heading: _en('How does weight affect fertility?'),
        paragraphs: [
          _en("Body fat isn't just stored energy. It makes oestrogen. Carrying "
              'more of it changes the hormone signals reaching the ovaries. In '
              'some people that upsets ovulation, which shows up as irregular '
              'or missing periods.'),
          _en('Carrying very little does the same thing from the other side. '
              'Below a certain point, the body treats having a baby as '
              'something to put off, and periods become irregular or stop. '
              "That's why this isn't only about being heavier."),
          _en('Insulin resistance is the other way weight has an effect. It '
              "means the body stops responding well to insulin, and it's what "
              "links this subject to PCOS. It's common, it's treatable, and it "
              'responds to change faster than most people are told.'),
          _en('And it affects both of you. Weight is linked to sperm quality '
              'too. This is one of several places in this stage where the load '
              'gets put on one person when it belongs to two.'),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm on the thin side?"),
        paragraphs: [
          _en('Most weight advice is about losing it, so this side is easy to '
              'miss. Being underweight is common in India, and it can stop '
              'ovulation just as surely. Often the only sign is periods that '
              'come late, come rarely or stop.'),
          _en('The usual reasons are ordinary: skipped meals, eating less than '
              'your work or exercise uses, hard training, a long illness or a '
              'lot of stress. Sometimes it is a medical cause, like an '
              'overactive thyroid or coeliac disease, which a doctor can '
              'check.'),
          _en('What helps is the opposite of a diet. Regular meals, with a '
              'little more at each: ghee on your roti, a handful of nuts, milk, '
              'paneer, eggs or curd. Easing off very hard exercise helps too. '
              'Gaining a little often brings periods back.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why is a small change enough?'),
        paragraphs: [
          _en("Here's the part that usually goes missing. A fairly small "
              'change in weight can bring ovulation back in someone whose '
              'cycles had become irregular. Not a transformation. A modest '
              'change you can keep up.'),
          _en('That matters because the advice people usually get sounds like '
              'a long project with a far-off finish line. And a far-off finish '
              'line is exactly what makes someone give up in week three.'),
          _en('The more useful way to see it: the benefit starts early, and '
              "you don't have to arrive anywhere in particular."),
          _en("It's also why crash diets work against you. Losing weight very "
              'fast upsets cycles on its own, and the weight usually comes '
              "back. Slow and boring isn't second best here. It's the version "
              'that works.'),
        ],
      ),
      PvReadSection(
        heading: _en('What helps in an Indian kitchen?'),
        paragraphs: [
          _en('Nothing fancy and nothing imported. More of each meal made of '
              'vegetables and dal, whole grains instead of refined ones where '
              'you can, and fewer fried snacks and sweets between meals. In '
              "most homes, that's where the surprise is, not in the main "
              'meals.'),
          _en("Movement you'll keep doing beats an intense plan you'll drop. A "
              'daily walk that happens is worth more than a gym membership '
              "that doesn't."),
          _en('Sleep is the one people leave out. Short sleep directly affects '
              "how hungry you feel, and it's usually easier to fix than diet."),
          _en("And if there's a reason behind the weight, like thyroid, PCOS "
              'or a medicine that causes weight gain, then treating that '
              'reason is the work. Effort spent on willpower instead is effort '
              'wasted.'),
        ],
      ),
      PvReadSection(
        heading: _en("What if the scale isn't moving?"),
        paragraphs: [
          _en("This is where most people stop, so it helps to know what's "
              'going on. Weight is a poor measure from week to week. It moves '
              'with water, with salt, with where you are in your cycle, and '
              "with what you ate yesterday. A flat week doesn't mean nothing "
              'is working.'),
          _en("More importantly, the things that matter for ovulation don't "
              'wait for the scale. Regular movement helps your body use '
              'insulin better, and better sleep helps too, whether or not the '
              'number has changed.'),
          _en('Cycles sometimes become more regular before your weight changes '
              "much at all. That's a strong reason to watch your periods "
              'rather than the scale.'),
          _en('So if you want something to track, track the first day of each '
              "period. It's the measure most closely tied to what you're "
              "trying to do, and it doesn't make anybody feel worse on a "
              'Tuesday morning.'),
          _en('And plateaus are normal, not a sign of failure. Bodies adjust. '
              'Progress here is rarely a straight line, and stopping at the '
              'first flat stretch is what turns a slow change into no change.'),
        ],
      ),
      PvReadSection(
        heading: _en("What if you've been treated unkindly about this?"),
        paragraphs: [
          _en('Some clinics set a weight limit before they offer treatment. '
              'Being told to come back lighter, with no help on how, is common '
              'and very disheartening.'),
          _en("You're allowed to ask what the limit is for, whether it's a "
              'medical need or a clinic policy, and what support is available. '
              "You're allowed to get a second opinion. And you're allowed to "
              "say that the way it was said didn't help."),
        ],
      ),
      PvReadSection(
        heading: _en('What if food has become a struggle?'),
        paragraphs: [
          _en('If food has become something you fight with, like restricting, '
              'bingeing or thinking about it all the time, raise that with a '
              'doctor in its own right. Do it before, and separately from, any '
              'talk about conceiving.'),
          _en('An eating disorder, now or in the past, can stop periods and '
              'ovulation. That includes eating very little, making yourself '
              'sick, using laxatives, or exercising to make up for food. It '
              'can also make pregnancy harder on your body.'),
          _en("This isn't a failing, and you don't have to sort it out alone. "
              'Recovery often brings cycles back on its own. A doctor, a '
              'psychologist or a dietitian who knows eating disorders can help '
              'you at a pace that feels safe.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Some of this isn't about willpower"),
      body: _en('If your periods have become irregular or stopped, if your '
          'weight has changed a lot without a change in what you eat, or if '
          'you have signs like ongoing tiredness, thinning hair or always '
          'feeling cold, ask for thyroid and PCOS checks rather than trying '
          'harder. And if your relationship with food or with your body has '
          "become distressing, please tell a doctor. That's a health matter in "
          "itself and deserves care, whether or not you're trying to "
          'conceive.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do I have to reach a particular weight before trying?'),
        answer: _en("There's no single number that applies to everybody, which "
            "is why this piece doesn't give one. Some clinics use limits for "
            "specific treatments, and that's a conversation to have with the "
            'clinic. For trying naturally, direction matters more than '
            'arriving anywhere.'),
      ),
      PvReadFaq(
        question: _en('Can I be too thin for this?'),
        answer: _en('Yes. Below a certain point, cycles become irregular or '
            'stop, and the fix is the opposite of what most advice assumes. If '
            "your periods have stopped and you're very lean or exercising "
            "hard, it's worth seeing someone about."),
      ),
      PvReadFaq(
        question: _en('Should I lose weight quickly to save time?'),
        answer: _en('No. Losing weight fast upsets cycles by itself and rarely '
            'lasts. A steady change you can keep up is both kinder and more '
            'effective, and the benefit starts well before any finish line.'),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems) and NICE guidance on weight '
        'management before pregnancy; RCOG and WHO statements on preconception '
        'care; evidence on modest weight change and restoration of ovulation '
        'in anovulatory infertility; NICE NG69 (eating disorders) and ACOG on '
        'low body weight, eating disorders and absent periods. No thresholds, '
        'targets or BMI figures are stated here by editorial decision. Sources '
        'checked September 2026.'),
    readNext: ['ttc_read_three_months_before'],
  ),

  PvRead(
    id: 'ttc_read_coming_off_birth_control',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Coming off birth control'),
    teaser: _en('What comes back quickly, what takes a while, and why "let it '
        'clear out of your system" isn\'t doing you any favours.'),
    scaleSetter: _en('For most methods, fertility comes back quickly, '
        'sometimes straight away. The main exception is the contraceptive '
        'injection, and that one really does take a long time. None of these '
        'needs a waiting period "to flush it out". That idea is folklore, and '
        'it costs people months.'),
    shortAnswer: _en('After the pill, patch, ring, coil or implant, fertility '
        'usually comes back within a cycle or two, and you can try straight '
        'away. The contraceptive injection is the exception and can take many '
        "months. There's no need to wait for anything to leave your system."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Two beliefs cause most of the trouble here. One is that you '
              'must wait several months for contraception to "leave your '
              'system" before it\'s safe to try. The other is that using it '
              'for a long time causes lasting infertility. Neither is backed '
              'by evidence.'),
          _en('What is true is that different methods bring your own cycle '
              'back on very different timescales. Knowing which one you were '
              'on changes what to expect.'),
        ],
      ),
      PvReadSection(
        heading: _en('How soon does fertility come back after the pill?'),
        paragraphs: [
          _en('Ovulation usually comes back quickly after stopping, for many '
              'people within the first cycle or two. You can get pregnant '
              "before having a single period in between. That's worth knowing "
              'if you were planning to count from one.'),
          _en("The first bleed after stopping often isn't a normal period, and "
              'the first few cycles can be irregular while your own rhythm '
              "returns. That's your body settling, not a problem."),
          _en("There's no need to wait a set number of months before trying. "
              'The old advice to wait three cycles was mostly about making a '
              'pregnancy easier to date, not about safety. Scans have made '
              'that reason out of date.'),
          _en('One thing the pill can hide: if your cycles were irregular '
              'before you started it, they may well be irregular again '
              "afterwards. That's your own pattern coming back, not something "
              'the pill caused.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is there a fertility boost right after stopping?'),
        paragraphs: [
          _en('You may hear that fertility jumps in the first months after '
              'the pill, so you should try straight away to catch it. There '
              "isn't good evidence for a special boost."),
          _en('What studies do show is reassuring in a quieter way. Within a '
              'year of stopping, about as many people conceive as those who '
              'never used the pill. So there is no rush to catch a window, and '
              'no delay to make up for.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Years on the pill make it harder to get pregnant.'),
          fact: _en('Long use of the pill is not linked to lower fertility '
              'afterwards. Age matters, and so does any condition the pill '
              'was covering up. The pill itself does not use up eggs or leave '
              'lasting harm.'),
        ),
      ),
      PvReadSection(
        heading: _en('What about coils, implants and the injection?'),
        paragraphs: [
          _en('When a copper or hormonal coil is removed, fertility comes back '
              'more or less straight away. The same goes for an implant once '
              "it's taken out."),
          _en('The contraceptive injection is the real exception. It can take '
              'many months after the last dose before ovulation comes back, '
              'and for some people close to a year or more.'),
          _en('This is a delay, '
              "not damage. It doesn't lower your fertility in the end. But if "
              "you're on it and thinking about trying soon, talk to your "
              'doctor sooner rather than later.'),
          _en("Emergency contraception doesn't affect future fertility at all, "
              'and needs no waiting period.'),
        ],
      ),
      PvReadSection(
        heading: _en('What might contraception have been hiding?'),
        paragraphs: [
          _en("A bleed on the combined pill isn't a period. It's a withdrawal "
              "bleed that happens because the hormones pause. That's why it "
              'tends to be lighter, shorter and more on time than anything '
              'your own body makes.'),
          _en('Losing that regularity is the change people find most '
              "unsettling. It isn't a problem. It's your own cycle, which was "
              'never that neat.'),
          _en('Symptoms often come back with it. Period pain, heavier '
              'bleeding, mood changes before a period, and acne are all often '
              "held back by hormonal contraception. When they return, it's "
              'your own pattern showing again, not something new going wrong.'),
          _en('That matters for one reason. If you were first given the pill '
              'for painful or heavy periods, for acne or for irregular cycles, '
              'whatever it was managing is still there.'),
          _en('Severe period pain especially is worth getting checked '
              "properly instead of putting up with it. It's one way "
              'endometriosis goes unnoticed for years, and those years matter '
              "more when you're trying to conceive."),
        ],
      ),
      PvReadSection(
        heading: _en('What changes might I notice after stopping?'),
        paragraphs: [
          _en('Most changes settle within a few months. These are the ones '
              'people notice most often.'),
        ],
        bullets: [
          _en('Spots or oilier skin, especially along the jaw.'),
          _en('Periods that come at uneven gaps for a while.'),
          _en('Heavier or more painful periods than you had on the pill.'),
          _en('Mood changes or tender breasts in the days before a period.'),
          _en('More discharge in the middle of your cycle, and sometimes a '
              'one-sided twinge. Both are signs of ovulation returning.'),
          _en('Headaches that came with the pill may ease.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Worth a check rather than a wait'),
          body: _en('Acne that is severe or scarring, new hair growth on the '
              'face or body, or periods that stay very far apart are worth '
              'showing a doctor. They can point to PCOS, which is easier to '
              'manage once it is named.'),
        ),
      ),
      PvReadSection(
        heading: _en('What should I do when I stop?'),
        paragraphs: [
          _en('Start folic acid before you stop contraception, not after. It '
              'needs to be in your system before conception, and conception '
              'can happen sooner than you expect here. So earlier really is '
              'better.'),
          _en('If you want to get to know your own cycle again, start noting '
              'the first day of each period. Almost every later question '
              'depends on that one fact, and it costs nothing to record.'),
          _en('Give yourself a few cycles before deciding how regular you are. '
              'Judging your cycle on the first one after stopping is like '
              'judging a road by its first ten metres.'),
        ],
      ),
      PvReadSection(
        heading: _en('When should I ask a doctor?'),
        paragraphs: [
          _en("If your period hasn't come back within about three months of "
              'stopping the pill, a coil or an implant, bring it up with a '
              "doctor. It's usually something ordinary, like thyroid, PCOS, "
              'stress or a change in weight, and finding out is quicker than '
              'waiting.'),
          _en('The injection is judged differently, because a long wait is '
              "expected there. Even so, if it's been more than a year since "
              'your last dose and nothing has come back, ask.'),
          _en('And once your cycles are back, the usual timelines apply. Time '
              'trying is counted from when you started trying, not from when '
              'you stopped contraception.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to ask rather than wait'),
      body: _en("See a doctor if your periods haven't come back about three "
          'months after stopping the pill, a coil or an implant. See one too '
          'if they come back but are still very irregular after several '
          'cycles, if you have severe pain, very heavy bleeding or bleeding '
          "between periods, or if you're on the contraceptive injection and "
          'hoping to conceive within the next year. That last one is worth '
          'planning early rather than finding out late.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do I need to wait for it to leave my system?'),
        answer: _en('No. That idea has no basis for any of these methods. The '
            "only real wait is with the contraceptive injection, and that's "
            'about ovulation coming back, not about anything clearing out.'),
      ),
      PvReadFaq(
        question: _en('I was on the pill for ten years. Has that harmed me?'),
        answer: _en("Long use isn't linked to lower fertility afterwards. What "
            'long use does is hide what your own cycle was like. So anything '
            'irregular that shows up afterwards was usually there before.'),
      ),
      PvReadFaq(
        question: _en('Can I get pregnant before my first period?'),
        answer: _en('Yes. Ovulation comes before a period, so you can conceive '
            'in the first cycle after stopping. Start folic acid before you '
            'stop, not after.'),
      ),
      PvReadFaq(
        question: _en('My cycles are irregular now. Is that the pill?'),
        answer: _en('The first few cycles are often irregular while things '
            "settle. After that, it's more often the pattern you had before "
            "the pill showing again. That's worth getting checked rather than "
            'waiting out.'),
      ),
    ],
    evidence: _en('NICE CG156; FSRH (Faculty of Sexual and Reproductive '
        'Healthcare) guidance on return of fertility after contraception; NHS '
        'contraception guidance; WHO medical eligibility criteria; a 2018 '
        'systematic review of return of fertility after stopping '
        'contraception (Contraception and Reproductive Medicine). Sources '
        'checked September 2026.'),
    readNext: ['ttc_read_how_conception_works'],
  ),

  PvRead(
    id: 'ttc_read_meds_and_conditions',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Medicines and conditions to check with a doctor'),
    teaser: _en('The appointment worth having before you start, and the one '
        "decision you shouldn't make on your own."),
    scaleSetter: _en("The most important line here: don't stop a prescribed "
        'medicine to get ready. Some are changed before pregnancy, some are '
        'carried on exactly as they are, and stopping suddenly is almost never '
        "right. A condition that's well controlled going into pregnancy is "
        'worth far more than a medicine list that sounds clean.'),
    shortAnswer: _en("Don't stop any prescribed medicine on your own to get "
        'ready, including medicine for depression or anxiety. Book one visit '
        'a few months before trying and take everything you both take. The '
        'doctor will say what to keep, what to switch, and whether your folic '
        'acid dose should change.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Once people decide to try, there's often an urge to strip back "
              'to nothing: stop the tablets, come off everything, start clean. '
              "It comes from a good place, and it's the most common avoidable "
              'mistake at this stage.'),
          _en("A condition that isn't under control is a risk to a pregnancy "
              "in a way a well-chosen medicine usually isn't. The work isn't "
              "stopping things. It's one conversation with the person who "
              'prescribed them, early enough that any change has time to '
              'settle.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which conditions should I review before we start?'),
        paragraphs: [
          _en('Thyroid, whether too high or too low. Thyroid levels affect '
              'ovulation and early pregnancy. The target levels are often '
              'different in pregnancy, and doses often need adjusting. If you '
              'take thyroid medicine, this is the most worthwhile check before '
              'pregnancy.'),
          _en('Diabetes, including diabetes managed with tablets rather than '
              'insulin. Good control before conception matters more than '
              'control after, because the earliest weeks count most. The folic '
              'acid dose is often higher too.'),
          _en('Epilepsy. Some seizure medicines carry real risks in pregnancy, '
              'and others are much safer. So a planned switch well ahead of '
              'time is very valuable. Stopping on your own is dangerous here. '
              'An uncontrolled seizure is a serious event for you and for a '
              'pregnancy.'),
          _en('High blood pressure, and autoimmune conditions such as lupus, '
              'inflammatory bowel disease and rheumatoid arthritis. For most '
              'of these, the goal is to be stable before conceiving, and '
              'several of the medicines used can be taken in pregnancy.'),
        ],
      ),
      PvReadSection(
        heading: _en('What if I take medicine for depression or anxiety?'),
        paragraphs: [
          _en("Stopping an antidepressant that's "
              'working, just to get ready, carries real risks of its own, for '
              'you and for a pregnancy. It needs the same careful conversation '
              'as any other medicine, not a sudden stop you decide on alone.'),
          _en('Stopping suddenly can bring withdrawal symptoms and can let the '
              'depression or anxiety come back, sometimes at the hardest time. '
              'Pregnancy and the months after birth are already a time when '
              'mood problems are more likely.'),
          _en('Many commonly used antidepressants can be carried on in '
              'pregnancy. Your doctor may keep your medicine as it is, switch '
              'you to one with more pregnancy data, or adjust the dose. Talking '
              'therapy can help alongside it.'),
          _en('So plan it with the doctor who prescribed it, a few months '
              'before trying if you can. Tell your gynaecologist too, so '
              'everyone looking after you knows.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which medicines should I ask about?'),
        paragraphs: [
          _en('Some are known to be unsafe in pregnancy and are usually '
              'changed ahead of time. Certain blood pressure medicines, some '
              'acne treatments, methotrexate, warfarin and several epilepsy '
              'drugs are the ones most often named.'),
          _en('If you take any of these, '
              'book the appointment before you start trying, not after a '
              'positive test.'),
          _en("Over-the-counter doesn't mean automatically safe. Taking "
              'anti-inflammatory painkillers for a long time can interfere '
              "with ovulation, and high-dose vitamin A supplements aren't safe "
              'in pregnancy.'),
          _en('Ayurvedic, homeopathic and herbal remedies count as medicines '
              "for this conversation. Many are fine. Some haven't been studied "
              'well, and a few unregulated products have been found to contain '
              'heavy metals. Mention what you take, rather than assuming a '
              'doctor only wants to hear about allopathic drugs.'),
          _en('Bring the boxes themselves to the appointment. Names are easy '
              'to mix up, doses are easy to misremember, and a strip in your '
              'bag settles both in ten seconds.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask at the appointment?'),
        paragraphs: [
          _en("Say clearly that you're planning to conceive, and roughly when. "
              '"We\'re hoping to start trying in a few months" changes what a '
              "doctor thinks about, and it's easy to leave unsaid because it "
              'feels awkward.'),
          _en('Ask three things. Does anything I take need changing? Does '
              'anything need changing ahead of time, rather than at a positive '
              'test? Does anything about my condition change the folic acid '
              'dose I should take?'),
          _en('Ask who to contact when you do conceive, and whether you should '
              'be seen sooner than a first routine antenatal visit. For '
              'several of the conditions above, the answer is yes.'),
        ],
      ),
      PvReadSection(
        heading: _en("Do my partner's medicines matter?"),
        paragraphs: [
          _en('A few medicines affect how sperm are made or how they work, '
              'including some used for hair loss, and testosterone in '
              'particular. Taking testosterone lowers sperm production, which '
              'surprises people who expected the opposite.'),
          _en("If he takes anything regularly and you're planning to conceive, "
              "it's worth mentioning at his own appointment. That's better "
              'than it coming up for the first time at a fertility clinic a '
              'year later.'),
        ],
      ),
      PvReadSection(
        heading: _en('What else should we check at the same time?'),
        paragraphs: [
          _en('Two checks are easy to forget. The first is a dental check-up. '
              'Gum disease is linked to babies being born early, and a '
              "cleaning is simpler now than when you're pregnant."),
          _en('The second is infection tests for both of you, including '
              'chlamydia, HIV, syphilis and hepatitis B. Some infections cause '
              'no symptoms and can affect the tubes or a pregnancy. Testing '
              'both of you means neither passes it back.'),
          _en('The read on tests and vaccinations before trying explains each '
              'one, and which vaccines need a month of notice.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Never stop a prescribed medicine to prepare for pregnancy'),
      body: _en("Don't stop or cut down anything you were prescribed, for "
          'thyroid, epilepsy, diabetes, blood pressure, mental health or '
          'anything else, without talking to the doctor who prescribed it. A '
          "condition that isn't under control is a bigger risk than almost any "
          'well-chosen medicine, and some medicines are dangerous to stop '
          "suddenly. If you've already stopped something, say so clearly at "
          "the appointment. It's useful information, not a confession."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should I stop everything before we start trying?'),
        answer: _en('No. Ask instead. Some medicines are swapped ahead of '
            'time, many are carried on unchanged, and stopping suddenly is '
            'almost never right.'),
      ),
      PvReadFaq(
        question: _en('How far ahead should I book this appointment?'),
        answer: _en('A few months ahead is comfortable, because any change in '
            'medicine needs time to settle and be checked. If that time has '
            'already passed, go anyway. Sooner is better than never.'),
      ),
      PvReadFaq(
        question: _en('Do I need to mention Ayurvedic medicines?'),
        answer: _en('Yes. They count as medicines here. Many are fine, some '
            "haven't been studied well, and a doctor can only take into "
            "account what they're told about."),
      ),
      PvReadFaq(
        question: _en("I'm on an antidepressant. Do I have to come off it?"),
        answer: _en('Not automatically, and this is one to talk through rather '
            "than decide alone. Depression that isn't treated in pregnancy "
            'carries real risks of its own. A psychiatrist or GP can help you '
            'weigh up the balance.'),
      ),
      PvReadFaq(
        question: _en('I had an abortion in the past. Do I need to mention '
            'it?'),
        answer: _en("Yes, it's worth mentioning, and it stays between you and "
            'your doctor. For most women a safe abortion does not make it '
            'harder to get pregnant later. The read on a past abortion in this '
            'door explains the few things worth checking.'),
      ),
    ],
    evidence: _en('NICE NG201 (antenatal care) and NICE guidance on epilepsy, '
        'diabetes and antenatal mental health; RCOG preconception care '
        'statements; MHRA valproate safety guidance; UK Teratology Information '
        'Service principles on medicine use around conception; published '
        'reports of heavy-metal contamination in some unregulated herbal '
        'preparations; NICE CG192 (antenatal and postnatal mental health) on '
        'planning antidepressant use before pregnancy. Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Next: the tests and vaccinations'),
        value: _en('Infection tests for both of you, the dental check and '
            "the vaccines that need a month's notice."),
        surfaceId: 'ttc_read/ttc_read_preconception_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep a list of your medicines'),
        value: _en('What you take and at what dose, ready to show at the '
            'appointment.'),
        surfaceId: 'ttc_medication',
      ),
    ],
    readNext: ['ttc_read_preconception_tests', 'ttc_read_after_abortion'],
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
    teaser: _en('One inexpensive blood test, done once. Most Western advice '
        'for before pregnancy never mentions it, but it matters here more than '
        'almost anywhere.'),
    scaleSetter: _en('Thalassemia carrier screening is a routine blood test. '
        "Most people who take it aren't carriers and never think about it "
        "again. It's on this list because India has more children born with "
        'thalassemia major than any other country, and because being a carrier '
        "causes no symptoms at all. And the test only changes anything if it's "
        'done before a pregnancy, not during one.'),
    shortAnswer: _en('Thalassemia carrier screening is one inexpensive blood '
        "test, usually HbA2 by HPLC, done once in your life. A carrier is "
        'healthy. It only matters if both of you are carriers, and then a '
        'genetic counsellor explains your options, which are wider before '
        'pregnancy than during it.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("If you've read a Western checklist for before trying, this "
              "probably wasn't on it. That isn't a mistake on their part. How "
              'common carriers are differs hugely between populations, and in '
              "India it's common enough to belong near the top."),
          _en('The whole thing is one blood test. It costs less than a '
              'restaurant meal, and for most people the result ends the '
              'matter.'),
        ],
      ),
      PvReadSection(
        heading: _en("Does being a carrier mean I'm ill?"),
        paragraphs: [
          _en('Hold on to this, because "carrier" and "thalassemia" sit one '
              'word apart, but they mean very different things.'),
          _en('A thalassemia carrier is a healthy person. You may also see it '
              'called thalassemia trait or thalassemia minor. No treatment, no '
              'limits, no shorter life, and usually no symptoms at all. Many '
              'carriers reach middle age without ever knowing.'),
          _en('What a carrier sometimes has is slightly small red blood cells '
              "and mild anaemia that iron doesn't fix. That matters for a "
              'practical reason.'),
          _en("It's often mistaken for iron deficiency and treated with iron "
              'tablets for years. That does nothing useful, and taken long '
              "enough without a real deficiency, iron isn't harmless."),
          _en('So if you\'ve been told you\'re "always a little anaemic" and '
              'iron has never really fixed it, this test answers a question '
              "you've already been asking."),
        ],
      ),
      PvReadSection(
        heading: _en('Why test before pregnancy, not during?'),
        paragraphs: [
          _en("One carrier and one non-carrier can't have a child with "
              'thalassemia major. It only becomes a serious conversation when '
              "both partners are carriers. That's why it's a couple's test, "
              "not a woman's test."),
          _en('Where both are carriers, a genetic counsellor will explain what '
              'the inheritance means. In each pregnancy, separately, there is '
              'a one-in-four chance of a child with thalassemia major, a '
              'one-in-two chance of a carrier like the parents, and a '
              'one-in-four chance of neither.'),
          _en('Those are the numbers of inheritance, not a prediction about '
              "you, and they don't change from one pregnancy to the next."),
          _en('Thalassemia major is a serious lifelong condition that needs '
              'regular blood transfusions from infancy. It can be treated and '
              "people live with it, but nobody pretends it's a small thing."),
          _en("And here's why the timing matters. A couple who know before "
              'conceiving have options that a couple who find out at twenty '
              "weeks don't. Those options are for a genetic counsellor to "
              'explain, not an app, and they exist.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which test is it, and who goes first?'),
        paragraphs: [
          _en('Start with a complete blood count, the ordinary CBC most people '
              'have had many times. A doctor looks at the size of the red '
              'cells. A low MCV or MCH is the sign to look further.'),
          _en('The test that answers it is haemoglobin electrophoresis or '
              'HPLC, usually reported as HbA2. A raised HbA2 points to beta '
              'thalassemia trait. Ask for it by name, "HbA2 by HPLC", because '
              'an "anaemia panel" means different things at different labs.'),
          _en('Test one partner first, usually whoever is having other blood '
              'tests before pregnancy anyway. If that comes back negative, '
              "you're finished. If it's positive, the other partner is tested. "
              'Only if both are carriers does anything more follow.'),
          _en("It's inexpensive and widely available across India, and it's a "
              "once-in-a-lifetime test. Your result doesn't change."),
        ],
      ),
      PvReadSection(
        heading: _en('Who should be sure to have it?'),
        paragraphs: [
          _en('Anyone planning a pregnancy in India can reasonably have it, '
              'and several national programmes recommend exactly that. Some '
              'situations make it more pressing.'),
          _en('Carrier rates are higher in some communities than others, among '
              'them Sindhi, Punjabi, Gujarati, Bengali and several others. '
              'Sickle cell trait, which is screened the same way, is more '
              'common in central and tribal India. If you know your community '
              'carries either, treat this as a definite, not a maybe.'),
          _en('Anyone with a family history of thalassemia or sickle cell '
              'disease, or a relative who needed regular transfusions as a '
              'child. Anyone whose parents were related by blood, which raises '
              'the chance that both partners carry the same variant.'),
          _en('And anyone with long-standing mild anaemia that iron has never '
              'fixed. For that person, the test is worth doing whether or not '
              'a pregnancy is planned.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does my result mean?'),
        paragraphs: [
          _en('Not a carrier: nothing to do, and the question is closed for '
              'life.'),
          _en("You're a carrier and your partner isn't: your children may be "
              'carriers like you, but no child of you two will have '
              "thalassemia major. Write it down so a future doctor knows. It's "
              'worth telling your brothers and sisters too, because carrier '
              'status runs in families.'),
          _en('Both of you are carriers: this is the conversation to have with '
              'a genetic counsellor, before conceiving rather than after. Ask '
              "to be referred. Don't try to work it out from the internet, and "
              "don't let anyone rush you."),
          _en("One thing to watch for: a normal HbA2 doesn't rule out every "
              'form. Alpha thalassemia and some rarer types need different '
              'tests, and a doctor who sees small red cells with a normal HbA2 '
              'will know to look further.'),
          _en("That's another reason to take the "
              'result to someone rather than reading it alone.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask for a genetic counsellor, not for an opinion'),
      body: _en('If both of you are carriers, ask your doctor to refer you to '
          "a genetic counsellor before you start trying. It's a specific "
          "referral, and it's available in most Indian cities. Don't act on "
          "anything you've read here or anywhere else without it. And if "
          "you've been taking iron for years for anaemia nobody has explained, "
          'ask for this test before taking any more. Iron for an anaemia that '
          "isn't iron deficiency does no good and can do harm."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('I feel completely fine. Do I still need it?'),
        answer: _en("Yes, and that's the point of it. Carriers feel fine. "
            "That's what keeps carrier status hidden until two carriers have a "
            'child together.'),
      ),
      PvReadFaq(
        question: _en('Do both of us have to be tested?'),
        answer: _en('Only if the first result is positive. Test one of you, '
            "and if that's negative, you're done. It's a couple's test in what "
            'it means, not in what it costs.'),
      ),
      PvReadFaq(
        question: _en('Is it expensive?'),
        answer: _en("No. It's one of the cheaper tests on any list for before "
            "pregnancy, it's available across India, and it's done once in a "
            'lifetime.'),
      ),
      PvReadFaq(
        question: _en("We're already pregnant. Is it too late?"),
        answer: _en("It isn't too late to be tested, and it's worth doing now "
            'rather than waiting. The options are different from those before '
            'conceiving, and a genetic counsellor is the person to explain '
            'them. Go sooner rather than later.'),
      ),
      PvReadFaq(
        question: _en("What if we're both carriers?"),
        answer: _en('Ask for a genetic counsellor before you start trying. '
            "There are real options, and they're the counsellor's to explain "
            "properly. What doesn't help is deciding anything from a search "
            'result at midnight.'),
      ),
    ],
    evidence: _en('ICMR guidance on haemoglobinopathy screening in India; the '
        'National Health Mission Guidelines for Prevention and Control of '
        'Haemoglobinopathies (thalassemia and sickle cell disease); '
        'Thalassemia International Federation guidelines on carrier screening '
        'and genetic counselling; WHO estimates of carrier prevalence by '
        'region; NICE and RCOG guidance on antenatal haemoglobinopathy '
        'screening. Community prevalence varies widely and no figure for any '
        'individual community is stated here. Sources checked August 2026.'),
    readNext: ['ttc_read_preconception_tests'],
  ),
];
