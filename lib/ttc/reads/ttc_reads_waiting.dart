// =============================================================================
//  Fertile window, "Waiting and testing": the reads for the new tab
// -----------------------------------------------------------------------------
//  Written 2026-09-26 from the TTC gap analysis (docs/TTC-GAP-PLAN.md, stream
//  A). This tab carried the most P1 items in the whole analysis: 36 competitor
//  pieces, 16 of them P1, and until now all we had was two short chapter
//  sections ("Why spotting symptoms can't tell you", "When a test can tell you
//  something") in `ttc_chapter_data.dart`, locked to the waiting-days chapter.
//
//  Eight reads, one per question she asks in these two weeks:
//    the wait itself, when to test, how to test, a faint line, spotting,
//    a late period with a negative test, early signs vs PMS, and feeling
//    pregnant when the test says no.
//
//  ⚠️ THE CHAPTER SAYS THE SAME THINGS, AND THE TWO MUST NOT DRIFT. These reads
//  keep its facts: implantation six to twelve days after ovulation, a test is
//  worth taking from the day the period is due, symptoms can't tell pregnancy
//  from a period because progesterone causes both, and "see a doctor if the
//  period is over a week late". Change a number here, change it there.
//
//  ⚠️ CLINICAL LINES THAT MUST SURVIVE EDITING: never a personal probability
//  (population figures only, test/pv_read_shape_test.dart); ectopic warning
//  signs route to a hospital the same day in every read; a clinic's own test
//  date after a trigger injection beats anything a home test or this page says.
//
//  English only (CLAUDE.md, "New work is English"). `_en` marks the Hindi owed.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../ttc_read_blocks.dart';

// Private and duplicated per file, as in every other reads file.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsWaiting = [
  // ===========================================================================
  //  The two-week wait, day by day
  //  Covers: fertilisation and implantation (Flo "What happens at 3 weeks",
  //  "3 weeks: Fertilization & implantation"), how pregnancy weeks are counted
  //  (Flo "What happens at 1 week"), and getting through the fortnight.
  // ===========================================================================
  PvRead(
    id: 'ttc_read_two_week_wait',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('The two-week wait, day by day'),
    teaser: _en("What's happening inside your body each day after "
        "ovulation, why you can't feel it yet, and how to get through the "
        'wait.'),

    shortAnswer: _en('The two-week wait is the time between ovulation and '
        'your next period. A fertilised egg takes about a week to reach your '
        'womb and settle in, and only then does the pregnancy hormone start '
        "to rise. A home test usually can't tell you anything until the day "
        'your period is due.'),

    scaleSetter: _en("Nothing you do or don't do in these two weeks changes "
        'what is already happening inside. You can carry on with normal life: '
        'work, food, exercise and sex. The only real task is to wait until a '
        'test can give you a real answer.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('These can be the longest two weeks of the month. '
              "You've done what you can, and now there's nothing to see and "
              'nothing to measure.'),
          _en("It helps to know what's going on inside, day by "
              "day. You won't feel most of it. But knowing the timeline "
              'explains why the wait has to be this long, and why an early '
              'test so often says no.'),
        ],
      ),

      PvReadSection(
        heading: _en('What happens in the first week?'),
        paragraphs: [
          _en('Day 0 is ovulation, the day an egg is released. '
              'If sperm are already waiting in the tube, fertilisation '
              'happens within about a day. It takes place in the fallopian '
              "tube, not in the womb, and you won't feel it."),
          _en('Days 1 to 5: the fertilised egg starts to '
              'divide, one cell into two, then four, then more. It drifts '
              'slowly down the tube towards the womb. By about day 5 it has '
              'become a tiny ball of cells called a blastocyst.'),
          _en('All this time, your body behaves just as it does '
              'in any other month. Progesterone rises after ovulation whether '
              'or not an egg was fertilised. So the sore breasts, bloating '
              'and tiredness you may feel this week come in every cycle.'),
        ],
      ),

      PvReadSection(
        heading: _en('What happens in the second week?'),
        paragraphs: [
          _en('Days 6 to 12: the blastocyst reaches the womb '
              'and starts to settle into its lining. This is implantation. In '
              'most pregnancies it happens around 8 to 10 days after '
              'ovulation, but anywhere from 6 to 12 is normal.'),
          _en('Once it has settled, the new cells start to make '
              'hCG, the pregnancy hormone. hCG is what a pregnancy test looks '
              "for. At first there's very little of it, and it needs a few "
              'days to build up.'),
          _en('Around day 14, your period is due. If you are '
              'pregnant, hCG has usually risen enough by now for a home test '
              "to pick it up. If you're not, progesterone falls and your "
              'period starts.'),
        ],
        tip: PvReadTip(
          title: _en('Your own day 14 may be different'),
          body: _en('The second half of the cycle usually lasts 10 to '
              '17 days, and it tends to be about the same for you each month. '
              "If you've logged a few cycles, go by your own pattern rather "
              'than a textbook number.'),
        ),
      ),

      PvReadSection(
        heading: _en("Why can't I feel anything yet?"),
        paragraphs: [
          _en('Implantation is tiny. The whole blastocyst is '
              'smaller than a full stop on this page, and it settles into a '
              "lining that is shed and rebuilt every month. There's nothing "
              'big enough to feel.'),
          _en('Most of the signs people look for in this '
              'fortnight come from progesterone, and progesterone is high in '
              'every cycle after ovulation.'),
          _en("That's why early pregnancy and a period on its "
              'way can feel exactly the same. Every twinge you notice is '
              "real. It just can't tell you which one it is."),
          _en('Some women notice light spotting around the time '
              'of implantation. Many pregnant women never do, and spotting '
              'before a period is common too. We explain more in the read on '
              'implantation bleeding.'),
        ],
      ),

      PvReadSection(
        heading: _en('What can I do, and what should I avoid?'),
        paragraphs: [
          _en('Live as you normally would, with a few small '
              'cautions in case you are pregnant.'),
        ],
        bullets: [
          _en('Keep taking folic acid, 400 micrograms a day. '
              "The baby's spine starts to form in the first weeks, often "
              'before a missed period.'),
          _en('Work, travel, housework and lifting everyday '
              'loads are all fine.'),
          _en('Exercise you already do is fine. Walking, yoga '
              'and swimming are good choices.'),
          _en("Sex is fine, and it can't disturb implantation."),
          _en('Skip alcohol and smoking, as you would if you '
              'knew you were pregnant.'),
          _en('Keep caffeine under 200 mg a day, which is about '
              'two cups of instant coffee.'),
          _en('If you need a painkiller, paracetamol is the '
              'usual choice. Check with a doctor or chemist before taking '
              'anything else, including herbal remedies.'),
        ],
        mythFact: PvMythFact(
          myth: _en("Rest in bed, avoid stairs and don't lift "
              "anything, or it won't stick."),
          fact: _en('Implantation happens deep inside the lining of '
              "the womb. Walking, climbing stairs or lifting a bucket can't "
              "shake it loose. When a month doesn't work, it's almost always "
              'because of the egg or embryo itself, not because of anything '
              'you did that day.'),
        ),
      ),

      PvReadSection(
        collapsible: true,
        summary: _en('Doctors count from the day your last period '
            'started, so the two-week wait is weeks 3 and 4 of a pregnancy.'),
        heading: _en('Why is a positive test already called four weeks '
            'pregnant?'),
        paragraphs: [
          _en('Doctors count a pregnancy from the day your last '
              "period started, not from the day you conceived. That's about "
              'two weeks before ovulation. So on the day your period is due, '
              'a pregnancy is already counted as about four weeks.'),
          _en("It isn't a mistake in the maths. It's done this "
              'way because most women know the date their last period '
              'started, and almost nobody knows the day they conceived.'),
          _en('It also means weeks 1 and 2 of a pregnancy '
              "happen before you're pregnant at all. Week 3 is fertilisation "
              'and implantation. Week 4 is when a home test can turn '
              'positive.'),
        ],
      ),

      PvReadSection(
        heading: _en('How do I get through it?'),
        paragraphs: [
          _en('Many women find the second week harder than the '
              'first, because the answer feels so close. A few things help:'),
        ],
        bullets: [
          _en('Pick your test day in advance and write it down. '
              'Deciding once is easier than deciding every morning.'),
          _en("Buy one or two tests, not a big pack. It's "
              "easier not to test early when there isn't one in the drawer."),
          _en("Plan something for the evenings that isn't about "
              'this: a film, a visit, a new recipe.'),
          _en('Tell your partner where you are with it. You '
              "won't always feel the same on the same day."),
          _en('Stay off symptom forums in the second week. '
              "Other people's lists will pull you back into counting twinges."),
        ],
      ),

    ],

    faqs: [
      PvReadFaq(
        question: _en('Can I do anything to help implantation?'),
        answer: _en('Nothing has been shown to help in a natural cycle. '
            "Bed rest, special foods and pineapple don't make a difference. "
            'Keep taking folic acid, avoid alcohol and smoking, and live '
            "normally. That's enough."),
      ),
      PvReadFaq(
        question: _en('Is it okay to have sex during the two-week wait?'),
        answer: _en("Yes. Sex and orgasm don't disturb a pregnancy "
            "that's settling in. If you're having fertility treatment, follow "
            "your clinic's advice, as some clinics give their own "
            'instructions after a procedure.'),
      ),
      PvReadFaq(
        question: _en('Can I have a hot bath?'),
        answer: _en('Warm baths are fine. Very hot tubs and saunas are '
            "best skipped until you know, because getting very hot isn't "
            'advised in early pregnancy.'),
      ),
      PvReadFaq(
        question: _en('Why do I feel so low in the second week?'),
        answer: _en('Progesterone can make you tired and moody in this '
            'half of every cycle. On top of that, waiting with no information '
            "is hard for anyone. It doesn't mean something is wrong, and it "
            'says nothing about whether this month worked.'),
      ),
      PvReadFaq(
        question: _en('I took a painkiller before I knew. Is that a '
            'problem?'),
        answer: _en('Try not to worry. A few doses of a common medicine '
            'before a missed period are very unlikely to cause harm. Mention '
            'it to your doctor at your first visit, and ask before taking '
            'anything regular from now on.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help, and how soon'),
      body: _en('Go to a hospital the same day if you have strong '
          'pain low down on one side, pain at the tip of your shoulder, feel '
          'faint or dizzy, or bleed heavily, especially after a positive '
          'test. These can be signs of an ectopic pregnancy, one growing '
          "outside the womb. It's rare, but it needs care today, not an "
          'appointment next week. If the pain is severe or you faint, call '
          '108 or 112 for an ambulance. If your period is over a week late, '
          'take a test and speak to a doctor.'),
    ),

    evidence: _en('Timing of fertilisation and implantation follows '
        'StatPearls, "Physiology, Pregnancy" and "Embryology, Fertilization" '
        '(NCBI Bookshelf). Folic acid, alcohol, caffeine and painkiller '
        'advice follows the NHS guidance on planning a pregnancy and NICE. '
        'Dating a pregnancy from the last period follows ACOG. Ectopic '
        'warning signs follow the NHS and RCOG. Sources checked September '
        '2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        // Kept for revert (2026-09-28, explicit names): title: _en('When to take a test, and which one'),
        title: _en('When to take a pregnancy test, and which one'),
        value: _en('The day a test can give you a real answer, and how '
            'to choose one.'),
        surfaceId: 'ttc_read/ttc_read_when_to_test',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Can I...?'),
        value: _en('Check a food, medicine or activity in case you are '
            'pregnant.'),
        surfaceId: 'ttc_can_i',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        // Kept for revert (2026-09-28, explicit names): title: _en('Log your period when it comes'),
        title: _en('Log your next period'),
        value: _en('Your own dates make next month easier to read.'),
        surfaceId: 'ttc_calendar',
      ),
    ],

    // ⚠️ ONE READ, ONCE, AT THE FOOT (2026-09-28, no repetition):
    // 'ttc_read_when_to_test' is the next step "When to take a test, and which one",
    // so the Read next rail no longer lists it a second time.
    // Kept for revert:
    // readNext: ['ttc_read_when_to_test', 'ttc_read_early_signs', 'ttc_read_implantation_bleeding'],
    readNext: ['ttc_read_early_signs', 'ttc_read_implantation_bleeding'],
  ),

  // ===========================================================================
  //  When to take a pregnancy test, and which one
  //  Grows the chapter section "When a test can tell you something" into a full piece.
  //  Covers: how early, how soon after ovulation, a late period, accuracy before a missed
  //  period, the blood test, tests in India, irregular cycles, trigger injections.
  // ===========================================================================
  PvRead(
    id: 'ttc_read_when_to_test',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('When to take a pregnancy test, and which one'),
    teaser: _en('The day a test can give you a real answer, how early '
        'is too early, and which test to buy.'),

    shortAnswer: _en('The first day of your missed period is the earliest a '
        'home test is reliable. Testing before that often gives a negative '
        "even when you are pregnant. If you don't know when your period is "
        'due, test at least 21 days after the last time you had sex.'),

    scaleSetter: _en("Testing early can't harm anything except your hopes "
        'and your wallet. A negative before your period is due means very '
        "little, so it's worth waiting for the day a test can tell you "
        'something real.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('"Should I test today?" is a question that can '
              'come every month. The honest answer depends on one hormone, '
              'and how long it takes to build up.'),
          _en('Once you know that, the right day becomes much '
              'clearer, and you can stop spending tests on mornings that '
              "can't give you an answer."),
        ],
      ),

      PvReadSection(
        heading: _en('How does a pregnancy test work?'),
        paragraphs: [
          _en('A home test looks for hCG in your urine. hCG is '
              'only made once a fertilised egg has settled into the lining of '
              'your womb. That usually happens 6 to 12 days after ovulation.'),
          _en('After implantation, hCG rises quickly, roughly '
              'doubling every two to three days in the early weeks. But it '
              'starts from almost nothing, so it takes a few days to reach a '
              'level a test can see.'),
          _en("That's why a test can be negative on Monday and "
              'positive on Thursday. If you were pregnant, you were pregnant '
              "on both days. The hormone just hadn't built up yet."),
        ],
      ),

      PvReadSection(
        heading: _en('How early can I test?'),
        paragraphs: [
          _en('The first day of your missed period is when most '
              'home tests become reliable. Some tests say they work a few '
              "days earlier. They can for some pregnancies, but many won't "
              'show that early, because implantation happened later.'),
          _en('The "over 99 per cent accurate" printed on many '
              'boxes is measured from the day of the missed period, often in '
              'lab conditions. Before that day, a negative is much less '
              'certain.'),
          _en('If you know when you ovulated, for example from '
              'a positive ovulation strip, testing about two weeks after it '
              'is roughly the same as testing on the day your period is due.'),
          _en('If your period is late, today is a good day to '
              'test. A test taken a week after a missed period is the most '
              'reliable of all.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("The earliest day isn't the kindest one"),
          body: _en('An early negative often means nothing, and then '
              'you test again, and again. Waiting for the day your period is '
              'due saves money and a lot of hard mornings.'),
        ),
      ),

      PvReadSection(
        heading: _en('How soon after ovulation can I test?'),
        paragraphs: [
          _en("If you know roughly when you ovulated, here's "
              'how it usually goes, counting from that day:'),
        ],
        bullets: [
          _en('Days 1 to 6: no test can find a pregnancy yet, '
              "because implantation hasn't happened."),
          _en('Days 7 to 10: implantation is happening for most '
              'pregnancies. hCG is only just starting, so most tests are '
              'still negative.'),
          _en('Days 11 to 13: some sensitive tests turn '
              "positive for some pregnancies. A negative still doesn't mean "
              'much.'),
          _en('Day 14, or the day your period is due: most home '
              'tests become reliable.'),
          _en('A week after a missed period: the most reliable '
              'time for a home test.'),
        ],
      ),

      PvReadSection(
        heading: _en('What if my periods are irregular?'),
        paragraphs: [
          _en('With irregular cycles, including with PCOS, you '
              "can't always tell when a period is late. So count from sex "
              'instead of from your period.'),
          _en('Test at least 21 days after the last time you '
              'had sex. By then, a pregnancy from that time will usually show '
              'on a home test. If you use ovulation strips, test about two '
              'weeks after a positive one.'),
          _en("If you're trying all month, the 21 days keep "
              'moving. Many doctors suggest testing once your cycle has gone '
              'past the longest one you usually have. If periods often stop '
              "for months, see a doctor, as there's usually something they "
              'can help with.'),
        ],
      ),

      PvReadSection(
        collapsible: true,
        summary: _en('Every home test looks for the same hormone. Cheap '
            'ones from a chemist work well from the day your period is due.'),
        heading: _en('Which test should I buy?'),
        paragraphs: [
          _en('Every home test looks for the same hormone. The '
              'difference is mostly in how easy it is to use, and how small '
              'an amount it can pick up.'),
        ],
        bullets: [
          _en('Strip tests: a thin strip you dip in a clean cup '
              'of urine. The cheapest kind.'),
          _en('Cassette or card tests: you drop a little urine '
              'into a small window using the dropper in the pack. Very common '
              'in India, and easy to read. Most cost under ₹100 at a chemist.'),
          _en('Midstream tests: you hold the tip in your urine '
              'stream. Easy to use, and they usually cost a little more.'),
          _en('Digital tests: they show words instead of lines, '
              "so there's nothing to squint at. They cost a few hundred "
              'rupees, and some need a little more hCG to show a positive.'),
        ],
        tip: PvReadTip(
          title: _en('The number on some boxes'),
          body: _en("Some packs say 10 mIU/ml or 25 mIU/ml. That's "
              'the smallest amount of hCG the test can find. A lower number '
              'can show a pregnancy a little earlier. From the day your '
              'period is due, both work well.'),
        ),
      ),

      PvReadSection(
        heading: _en('When is a blood test better?'),
        paragraphs: [
          _en('A blood test for hCG, often called a beta hCG '
              'test, measures the exact amount of the hormone. It can find a '
              'pregnancy a few days earlier than a urine test, and it gives a '
              'number instead of a line.'),
          _en("It's most useful when a home test is unclear, "
              'after fertility treatment, or when a doctor wants to see '
              'whether the level is rising. Two tests about 48 hours apart '
              'show that best.'),
          _en('In India, most labs charge from a few hundred '
              "rupees to around ₹1,000, depending on the city. It's best to "
              'have your doctor order it, so someone can go through the '
              'number with you.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('If you had a trigger injection'),
          body: _en('Many IUI and IVF cycles use an injection that '
              'contains hCG. It can show on a home test for up to about 10 to '
              '14 days afterwards. Your clinic will give you a test date, '
              'often for a blood test. Go by their date, not the box.'),
        ),
      ),

    ],

    faqs: [
      PvReadFaq(
        // Kept for revert (2026-09-28, explicit names; shown on its own in
        // Learn's Common questions):
        // question: _en('Is morning urine really better?'),
        question: _en('Is morning urine really better for a pregnancy test?'),
        answer: _en('Early on, yes. First-morning urine has been in '
            'your bladder longest, so it holds the most hCG. From a few days '
            'after a missed period, the level is usually high enough that any '
            'time of day works.'),
      ),
      PvReadFaq(
        question: _en('I tested early and it was negative. Should I test '
            'again?'),
        answer: _en("Yes, if your period hasn't come. Wait until the "
            "day it's due, or two or three days after the last test. An early "
            "negative doesn't rule anything out."),
      ),
      PvReadFaq(
        question: _en('Does drinking a lot of water change the result?'),
        answer: _en('It can, early on. A lot of fluid thins your urine '
            'and can make a faint positive harder to see. Try not to drink '
            'much in the couple of hours before a test.'),
      ),
      PvReadFaq(
        question: _en('Are the cheap tests from the chemist reliable?'),
        answer: _en('Yes. They look for the same hormone as the '
            'expensive ones. From the day your period is due, a cheap test '
            "works as well, as long as you follow its leaflet and it's in "
            'date.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor, and how soon'),
      body: _en('See a doctor if your period is over a week late and '
          "tests are still negative, or if you keep getting results you can't "
          'read. Go to a hospital the same day if you have strong pain low '
          'down on one side, pain at the tip of your shoulder, feel faint or '
          'dizzy, or bleed heavily, especially after a positive test. These '
          'can be signs of an ectopic pregnancy, one growing outside the '
          "womb. It's rare, but it needs care today, not an appointment next "
          'week. If the pain is severe or you faint, call 108 or 112 for an '
          'ambulance.'),
    ),

    evidence: _en('How home tests find hCG, and when they are reliable, '
        "follows the NHS page \"Doing a pregnancy test\", Cleveland Clinic's "
        'guide to pregnancy tests, and StatPearls, "Human Chorionic '
        'Gonadotropin" (NCBI Bookshelf). The 21-day rule for irregular cycles '
        'follows the NHS. Trigger injection timing follows ESHRE and ASRM '
        'patient guidance. Prices are typical Indian chemist and lab ranges '
        'and vary by brand and city. Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        // Kept for revert (2026-09-28, explicit names): title: _en('How to take a test, step by step'),
        title: _en('How to take a pregnancy test, step by step'),
        value: _en('So you can trust the result you get.'),
        surfaceId: 'ttc_read/ttc_read_how_to_test',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your cycle dates'),
        value: _en('Your own dates tell you which day a test can '
            'answer.'),
        surfaceId: 'ttc_calendar',
      ),
      PvReadNextStep(
        kind: PvNextKind.product,
        title: _en('Tests and strips worth having'),
        value: _en('What to keep at home, and what to skip.'),
        surfaceId: 'ttc_products',
      ),
    ],

    // ⚠️ ONE READ, ONCE, AT THE FOOT (2026-09-28, no repetition):
    // 'ttc_read_how_to_test' is the next step "How to take a test, step by step",
    // so the Read next rail no longer lists it a second time.
    // Kept for revert:
    // readNext: ['ttc_read_how_to_test', 'ttc_read_faint_line', 'ttc_read_late_negative'],
    readNext: ['ttc_read_faint_line', 'ttc_read_late_negative'],
  ),

  // ===========================================================================
  //  How to take a home pregnancy test, step by step
  //  Covers: taking and reading a test, false negatives, false positives, and what to do
  //  after a positive (Flo "Detecting a pregnancy", "Why you might get a false negative").
  // ===========================================================================
  PvRead(
    id: 'ttc_read_how_to_test',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('How to take a home pregnancy test, step by step'),
    teaser: _en('How to take a test so you can trust the result, how to '
        'read it, and why a test is sometimes wrong.'),

    shortAnswer: _en('Use your first urine of the morning, follow the timing '
        'on the leaflet exactly, and read the result within the time it '
        'gives. Any line in the test window, however faint, usually means '
        "positive. A negative before your period is due isn't final, so test "
        "again in two or three days if your period hasn't come."),

    scaleSetter: _en("Home tests are very reliable when they're used on the "
        'right day and read at the right time. Most wrong results come from '
        'testing too early or reading too late, and both are easy to avoid.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Taking a test can feel like a big moment, even '
              'though it takes only a few minutes. Having a plan before you '
              'start makes those minutes easier.'),
          _en('Every brand is a little different, so the '
              'leaflet in your pack always comes first. What follows is '
              "what's true of almost all of them."),
          _en("If you're not sure what you're looking at when "
              "it's done, that's normal. A new test in two days will tell you "
              'more than staring at this one.'),
        ],
      ),

      PvReadSection(
        heading: _en('What should I do before I start?'),
        paragraphs: [
          _en('Plan to test first thing in the morning, before '
              'you drink anything. Early on, this urine has the most hCG in '
              'it.'),
          _en('Try to test when you have a few quiet minutes, '
              'not while rushing to work. Some women like their partner '
              'nearby. Others prefer to be alone. Either is fine.'),
        ],
        bullets: [
          _en('Check the expiry date, and that the foil pack '
              "isn't torn or damp."),
          _en('Read the leaflet the night before. Tests differ '
              'in how long to hold them and when to read them.'),
          _en('Keep a clean, dry cup ready if your test needs '
              'one.'),
          _en('Keep a timer or your phone clock close by.'),
        ],
      ),

      PvReadSection(
        heading: _en('How do I take the test?'),
        paragraphs: [
          _en('Here are the steps, in order:'),
        ],
        bullets: [
          _en('1. Wash your hands, and open the foil only when '
              "you're ready."),
          _en('2. For a strip: collect urine in the clean cup '
              'and dip the strip up to the marked line, for the number of '
              'seconds the leaflet says.'),
          _en('3. For a cassette: use the dropper to put the '
              'number of drops the leaflet asks for into the small sample '
              'well.'),
          _en('4. For a midstream test: hold the tip in your '
              'urine stream for the seconds it says, or dip it in the cup.'),
          _en('5. Lay the test flat, window up, on a clean, dry '
              'surface.'),
          _en('6. Wait the time the leaflet gives, usually a '
              'few minutes. Set a timer and step away if that helps.'),
          _en('7. Read the result within the time limit. After '
              'that, ignore it.'),
        ],
        tip: PvReadTip(
          title: _en('Why reading late causes confusion'),
          body: _en('As a test dries, a faint grey mark can appear '
              'where the test line sits. This is an evaporation line, not a '
              "result. It's why every leaflet gives a time limit, often ten "
              "minutes or less. A test picked out of the bin later can't tell "
              'you anything.'),
        ),
      ),

      PvReadSection(
        heading: _en('How do I read the result?'),
        paragraphs: [
          _en('Most line tests have two places for lines. The '
              'control line, often marked C, shows the test worked. The test '
              'line, often marked T, shows hCG.'),
        ],
        bullets: [
          _en('Two lines, even if the test line is faint: '
              'usually positive.'),
          _en('Only the control line: negative on this day.'),
          _en("No control line: the test didn't work. Use a new "
              "one, and don't try to read anything into the old one."),
          _en('Digital tests show words instead. Read them '
              'within the time given, as some screens go blank after a while.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('A faint line is still a line'),
          body: _en("If it's in the right place, has some colour and "
              'shows up within the time limit, a faint line usually means the '
              'test has found hCG. We explain more in the read on faint '
              'lines.'),
        ),
      ),

      PvReadSection(
        heading: _en("Why would a test say no when I'm pregnant?"),
        paragraphs: [
          _en("This is called a false negative. It's much more "
              'common than a false positive, and it almost always has the '
              'same cause: the test was taken before there was enough hCG to '
              'see. The usual reasons are:'),
        ],
        bullets: [
          _en('Testing before your period was due.'),
          _en('Ovulating later than you thought, so your period '
              "isn't really late yet."),
          _en('Very thin urine, after a lot of water or tea.'),
          _en('Reading the test too soon, before the full time.'),
          _en('An expired or damaged test.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('If it says no and your period stays away'),
          body: _en('Test again in two or three days, with '
              'first-morning urine. If your period is over a week late and '
              'tests are still negative, see a doctor.'),
        ),
      ),

      PvReadSection(
        heading: _en("Can a test say yes when I'm not pregnant?"),
        paragraphs: [
          _en("This is rare. When a line shows and there isn't "
              "an ongoing pregnancy, it's usually for one of these reasons:"),
        ],
        bullets: [
          _en('An evaporation line, from reading the test too '
              'late.'),
          _en('A pregnancy that began and ended very early, '
              'sometimes called a chemical pregnancy. The test was right '
              'about the hCG.'),
          _en('hCG still in your body after a recent pregnancy '
              'or pregnancy loss. It can take a few weeks to clear.'),
          _en('A fertility injection that contains hCG, often '
              'called a trigger injection.'),
          _en('Rarely, a medical condition, which a doctor can '
              'check with blood tests.'),
        ],
      ),

      PvReadSection(
        heading: _en('I got a positive. What now?'),
        paragraphs: [
          _en("It's normal to feel many things at once: joy, "
              "fear, disbelief, or all three in one minute. There's no right "
              'way to feel on this day.'),
          _en("Take a breath. There's nothing you need to do "
              'tonight. Keep taking folic acid, avoid alcohol and smoking, '
              'and check any medicines you take with a doctor or chemist.'),
          _en('Book a visit with a gynaecologist in the next '
              'couple of weeks. Most first appointments are between six and '
              'eight weeks of pregnancy, counted from your last period.'),
          _en("Note the day your last period started. It's the "
              "first thing a doctor will ask, and it's how your due date is "
              'worked out.'),
          _en("If you've had an ectopic pregnancy before, had "
              'surgery on your tubes, or conceived with treatment, tell your '
              'doctor early. They may want to see you sooner.'),
        ],
      ),

    ],

    faqs: [
      PvReadFaq(
        question: _en('Can I read the test again later?'),
        answer: _en('No. Once the time limit has passed, the test can '
            "change as it dries and no longer tells you anything. If you're "
            'unsure what you saw, take a new test in two days.'),
      ),
      PvReadFaq(
        question: _en('A line appeared after 20 minutes. Does it count?'),
        answer: _en('No. A line that shows up after the time on the '
            'leaflet is most likely an evaporation line. Test again with '
            'first-morning urine, and read it on time.'),
      ),
      PvReadFaq(
        question: _en("Can medicines I'm taking change the result?"),
        answer: _en("Most don't. Painkillers, antibiotics and most "
            "everyday medicines don't affect a pregnancy test. Ovulation "
            "tablets like letrozole or clomiphene don't either. The main "
            'exception is an injection that contains hCG.'),
      ),
      PvReadFaq(
        question: _en('Should I use two different brands to be sure?'),
        answer: _en('If a result is unclear, a second test two days '
            'later tells you more than a second brand the same morning, '
            'because the hormone will have had time to rise.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help, and how soon'),
      body: _en('Go to a hospital the same day if you have strong '
          'pain low down on one side, pain at the tip of your shoulder, feel '
          'faint or dizzy, or bleed heavily, especially after a positive '
          'test. These can be signs of an ectopic pregnancy, one growing '
          "outside the womb. It's rare, but it needs care today, not an "
          'appointment next week. If the pain is severe or you faint, call '
          '108 or 112 for an ambulance. If tests keep giving unclear results '
          'for more than a week, ask a doctor for a blood test.'),
    ),

    evidence: _en('How to take and read a home test, and the causes of '
        'false results, follow the NHS page "Doing a pregnancy test", '
        "Cleveland Clinic's guide to pregnancy tests, and StatPearls, \"Human "
        'Chorionic Gonadotropin" (NCBI Bookshelf). Timing of the first '
        'antenatal visit follows NICE antenatal care guidance and FOGSI. '
        'Ectopic warning signs follow the NHS and RCOG. Sources checked '
        'September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        // Kept for revert (2026-09-28, explicit names): title: _en('A faint line, explained'),
        title: _en('A faint line on a pregnancy test, explained'),
        value: _en('What it usually means, and when to test again.'),
        surfaceId: 'ttc_read/ttc_read_faint_line',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your doctor visits together'),
        value: _en('Your first appointment, and every one after, in '
            'one place.'),
        surfaceId: 'ttc_appointments',
      ),
    ],

    // ⚠️ ONE READ, ONCE, AT THE FOOT (2026-09-28, no repetition):
    // 'ttc_read_faint_line' is the next step "A faint line, explained",
    // so the Read next rail no longer lists it a second time.
    // Kept for revert:
    // readNext: ['ttc_read_faint_line', 'ttc_read_when_to_test', 'ttc_read_late_negative'],
    readNext: ['ttc_read_when_to_test', 'ttc_read_late_negative'],
  ),

  // ===========================================================================
  //  A faint line on a pregnancy test
  //  Covers: Flo "What does a faint line mean?", What to Expect "Does a Faint Line on a
  //  Pregnancy Test Mean It's Positive or Negative?". The gap plan's drawing of
  //  a line darkening is drawn in code (`TtcFaintLineDrawingBlock`, rendered
  //  by `ttcReadCustomBlock`), under "Does a faint line count as positive?".
  // ===========================================================================
  PvRead(
    id: 'ttc_read_faint_line',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('A faint line on a pregnancy test: what does it mean?'),
    teaser: _en('What a faint line usually means, why it can be pale, '
        'and when to test again.'),

    shortAnswer: _en('A faint line that shows in the right place within the '
        "test's time limit usually means the test has found hCG, the "
        "pregnancy hormone. It's often faint because it's early and the level "
        'is still low. Test again in two days with first-morning urine, and '
        'see a doctor to confirm.'),

    scaleSetter: _en('A faint line can feel like neither yes nor no, which '
        "is why it's so hard to live with. In most cases it's an early "
        'positive. The next test, two days later, usually makes things much '
        'clearer.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('You may have held the test up to the light, '
              'tilted it, and taken photos to compare. Almost everyone does.'),
          _en("Here's what a faint line can tell you, what it "
              "can't tell you yet, and what to do over the next few days."),
        ],
      ),

      PvReadSection(
        heading: _en('Does a faint line count as positive?'),
        paragraphs: [
          _en('Usually, yes. A test line only appears when the '
              "test finds hCG. It doesn't need to be as dark as the control "
              'line. If it has some colour, sits where the test line should '
              'be and showed up within the time limit, most doctors would '
              'call it positive.'),
          _en('How dark the line is depends mostly on how much '
              'hCG is in your urine at that moment. Early in pregnancy the '
              'level is low, so the line is pale.'),
          _en('Brands also show lines differently. The same '
              'amount of hCG can look paler on one test than on another, so '
              'compare like with like.'),
          _en("A single faint line can't tell you how things "
              "will go. Mostly, it tells you it's early."),
        ],
        // Four test windows, two days apart, the test line filling in beside
        // a solid control line (2026-09-26, gap plan).
        custom: const TtcFaintLineDrawingBlock(),
      ),

      PvReadSection(
        heading: _en('Why is the line faint?'),
        paragraphs: [
          _en('There are a few usual reasons. The first four '
              'are by far the most common, and the next test is what tells '
              'them apart:'),
        ],
        bullets: [
          _en("It's early. hCG was only made a few days ago and "
              "hasn't built up yet."),
          _en('Your urine was thin, from testing later in the '
              'day or after drinking a lot.'),
          _en('The test needs more hCG than some others to show '
              'a dark line.'),
          _en('Implantation happened a little later, so the '
              'level is still catching up.'),
          _en('Less often, the pregnancy has ended very early '
              'and the hCG level is falling.'),
        ],
      ),

      PvReadSection(
        heading: _en('Is it an evaporation line?'),
        paragraphs: [
          _en('An evaporation line is a thin, grey or '
              'colourless mark that can appear where the test line sits as '
              "the test dries. It isn't a result. Here's how they usually "
              'differ:'),
        ],
        bullets: [
          _en('A faint positive has colour, the same colour as '
              'the control line, only paler.'),
          _en('It shows up within the time the leaflet gives.'),
          _en('An evaporation line is usually grey and very '
              'thin, and appears only after the time limit.'),
        ],
        tip: PvReadTip(
          title: _en('Photos can mislead'),
          body: _en('Phone cameras, filters and lighting can make a '
              'line look darker or lighter than it is. If you compare tests '
              'across days, use the same brand, the same light and the same '
              'time of day, and go by what you see within the time limit.'),
        ),
      ),

      PvReadSection(
        heading: _en('What should I do today?'),
        paragraphs: [
          _en('If you might be pregnant, a few small things are '
              'worth doing now, while you wait for a clearer answer:'),
        ],
        bullets: [
          _en('Keep taking folic acid, 400 micrograms a day.'),
          _en('Skip alcohol and smoking from today.'),
          _en('Check any regular medicine with a doctor or '
              "chemist before your next dose. Don't stop a prescribed "
              'medicine on your own.'),
          _en('Note the day your last period started. A doctor '
              'will ask for it.'),
          _en('Put the other tests away until two days from '
              'now.'),
        ],
      ),

      PvReadSection(
        heading: _en('When should I test again?'),
        paragraphs: [
          _en('Wait two days, then test again with '
              'first-morning urine and the same brand. In an early pregnancy, '
              'hCG usually doubles every two to three days, so the line is '
              'often clearly darker.'),
          _en("If it's darker, that fits with a pregnancy "
              "that's carrying on. Book a visit with a gynaecologist in the "
              'next couple of weeks.'),
          _en('If it stays the same or gets lighter over a few '
              'days, or your period comes, the pregnancy may have ended very '
              "early. See the section below, and speak to a doctor if you're "
              'unsure.'),
          _en("If you'd rather have a number, a blood hCG test "
              'gives one. Two blood tests about 48 hours apart show whether '
              'the level is rising, and your doctor can read the pattern with '
              'you.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("Testing every day won't change the answer"),
          body: _en('Urine strength changes from morning to morning, '
              'so daily tests can seem to go up and down for no reason. Every '
              'two days is enough to see a real change.'),
        ),
      ),

      PvReadSection(
        heading: _en('What if the line fades?'),
        paragraphs: [
          _en('When a line appears and then fades, or your '
              "period comes a few days late, it's often a very early "
              "pregnancy loss, sometimes called a chemical pregnancy. It's "
              'very common. Many happen without anyone knowing, because '
              'nobody tested so early.'),
          _en("It's a real loss, even if it was very early and "
              "no one else knew. It's okay to be sad about it, and to take a "
              'little time before thinking about next month.'),
          _en("It isn't caused by anything you did, ate or "
              "lifted. Most often it's a chance problem in the early cells "
              'that nobody could have changed. Most women who have one go on '
              'to have a healthy pregnancy later.'),
        ],
      ),

      PvReadSection(
        collapsible: true,
        summary: _en('A trigger injection can leave a faint line for up '
            "to about two weeks. Go by your clinic's test date."),
        heading: _en("What if I'm having fertility treatment?"),
        paragraphs: [
          _en('Many IUI and IVF cycles use a trigger injection '
              'that contains hCG. It can show as a faint line for up to about '
              '10 to 14 days afterwards, depending on the dose. That line is '
              'the medicine, not a pregnancy.'),
          _en('Your clinic will give you a date for a blood '
              'test. Go by their plan, and ask them before reading anything '
              'into a home test.'),
        ],
      ),

    ],

    faqs: [
      PvReadFaq(
        question: _en('My test line is lighter than the control line. Is '
            'that bad?'),
        answer: _en('No. The control line is made to be dark every '
            'time. The test line only matches it once hCG is high, often a '
            'week or more after a missed period.'),
      ),
      PvReadFaq(
        question: _en('Can a faint line be a false positive?'),
        answer: _en("It's uncommon. The usual causes are reading the "
            'test after the time limit, a trigger injection that contains '
            'hCG, or hCG left over from a recent pregnancy or loss.'),
      ),
      PvReadFaq(
        question: _en('Should I tell my partner or family now?'),
        answer: _en("That's up to you. Some couples share straight "
            "away. Others wait for a clearer test or a doctor's visit. "
            "There's no right answer."),
      ),
      PvReadFaq(
        question: _en('Would a digital test help?'),
        answer: _en("It reads the result for you, so there's no line to "
            'squint at. Some need a little more hCG, so it may say "Not '
            'pregnant" on a day a sensitive line test shows faint. Waiting '
            'two days before using one helps.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help, and how soon'),
      body: _en('Go to a hospital the same day if you have strong '
          'pain low down on one side, pain at the tip of your shoulder, feel '
          'faint or dizzy, or bleed heavily, especially after a positive '
          'test. These can be signs of an ectopic pregnancy, one growing '
          "outside the womb. It's rare, but it needs care today, not an "
          'appointment next week. If the pain is severe or you faint, call '
          "108 or 112 for an ambulance. If a faint line doesn't get darker "
          "over a week and there's no period, see a doctor within a few days. "
          'A blood test and a scan can check where the pregnancy is.'),
    ),

    evidence: _en('How line tests work and how hCG rises in early '
        'pregnancy follow StatPearls, "Human Chorionic Gonadotropin" (NCBI '
        'Bookshelf), the NHS page "Doing a pregnancy test" and Cleveland '
        'Clinic. Very early pregnancy loss follows RCOG patient information '
        'on early miscarriage and the NHS. Trigger injection timing follows '
        'ESHRE and ASRM patient guidance. Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        // Kept for revert (2026-09-28, explicit names): title: _en('How to take a test, step by step'),
        title: _en('How to take a pregnancy test, step by step'),
        value: _en('Get the next test right, so it can answer you.'),
        surfaceId: 'ttc_read/ttc_read_how_to_test',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your doctor visits together'),
        value: _en('Book and keep your first visit in one place.'),
        surfaceId: 'ttc_appointments',
      ),
      // Kept for revert (2026-09-28, journal out of TTC): this next step opened the journal, which left the stage.
      // PvReadNextStep(
      //   kind: PvNextKind.activity,
      //   title: _en('Write it down'),
      //   value: _en('A few lines about today, just for you.'),
      //   surfaceId: 'ttc_journal',
      // ),
    ],

    // ⚠️ ONE READ, ONCE, AT THE FOOT (2026-09-28, no repetition):
    // 'ttc_read_how_to_test' is the next step "How to take a test, step by step",
    // so the Read next rail no longer lists it a second time.
    // Kept for revert:
    // readNext: ['ttc_read_how_to_test', 'ttc_read_chemical_pregnancy', 'ttc_read_implantation_bleeding'],
    readNext: ['ttc_read_chemical_pregnancy', 'ttc_read_implantation_bleeding'],
  ),

  // ===========================================================================
  //  Implantation bleeding or your period?
  //  Covers: Flo "Implantation bleeding vs. period", "Is it implantation cramps?",
  //  "Cramps but no period?", What to Expect "What Is Implantation Bleeding...".
  // ===========================================================================
  PvRead(
    id: 'ttc_read_implantation_bleeding',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Is it implantation bleeding or my period?'),
    teaser: _en('What implantation bleeding is, how it differs from a '
        'period, and when bleeding needs a doctor.'),

    shortAnswer: _en('Implantation bleeding is light spotting that some '
        'women have when a fertilised egg settles into the womb, often a few '
        "days before a period is due. It's usually pink or brown and lasts a "
        "few hours to two days. You can't tell it from early period spotting "
        'by looking, so a test on or after the day your period is due is the '
        'way to know.'),

    scaleSetter: _en('Light spotting before a period is common, whether or '
        "not you're pregnant. On its own it isn't a sign of a problem, and it "
        "isn't a sign of pregnancy either. What matters is when to test, and "
        'the few signs that need a doctor.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Seeing a little blood in the days before your '
              'period can send your mind racing. Is it starting? Or is it '
              'something else?'),
          _en("Here's what's known about implantation bleeding, "
              "what isn't, and how to find out which one you're seeing."),
        ],
      ),

      PvReadSection(
        heading: _en('What is implantation bleeding?'),
        paragraphs: [
          _en('About a week after ovulation, a fertilised egg '
              'reaches the womb and starts to settle into its lining. The '
              'lining is full of tiny blood vessels, and sometimes a few of '
              'them bleed a little as it settles.'),
          _en("When that blood comes out, it's usually a small "
              'amount of pink or brown spotting. It tends to happen around '
              'the time of implantation, often a few days before a period is '
              'due.'),
          _en('Many pregnant women never have it. Having it '
              "doesn't mean a pregnancy is stronger, and not having it isn't "
              'a bad sign.'),
        ],
      ),

      PvReadSection(
        heading: _en('How is it different from a period?'),
        paragraphs: [
          _en('There are some general differences. But they '
              'overlap a lot, and none of them is certain.'),
        ],
        bullets: [
          _en('Amount: implantation bleeding is usually '
              'spotting, a few drops or a light stain. A period usually '
              'becomes a flow that needs a pad.'),
          _en('Colour: often light pink or brown. A period '
              'usually turns bright or dark red after the first day.'),
          _en('How long: a few hours to two days. A period '
              'usually lasts two to seven days.'),
          _en("Clots: implantation bleeding doesn't have clots. "
              'A period can.'),
          _en('Pain: implantation may bring a mild twinge, or '
              'nothing. Period cramps are often stronger.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('The only way to know'),
          body: _en('Some periods start with a day or two of brown '
              'spotting, and some stay light all the way through. So wait '
              'until the day your period is due, or two or three days after '
              "the spotting, and take a home test. If it's negative and a "
              'normal period follows, it was your period.'),
        ),
      ),

      PvReadSection(
        heading: _en('Can I tell from the colour?'),
        paragraphs: [
          _en("Colour can hint, but it can't tell you. Brown "
              "blood is older blood that took a while to come out. It's "
              'common at the start and end of any period, and with '
              'implantation spotting too.'),
          _en('Pink is usually a small amount of fresh blood '
              'mixed with discharge. It can come with implantation, '
              "ovulation, or a period that's about to start."),
          _en('Red blood that keeps flowing and gets heavier '
              "over a day is most likely a period. If you've had a positive "
              'test, red bleeding needs a doctor to check.'),
        ],
      ),

      PvReadSection(
        heading: _en('Are these implantation cramps?'),
        paragraphs: [
          _en('Some women feel a mild pulling or cramp around '
              'the time of implantation. Whether implantation itself causes '
              "it hasn't been well studied."),
          _en('Progesterone and a period on its way cause the '
              'same kind of cramps. So a cramp in the second half of your '
              "cycle can't tell you whether you're pregnant."),
          _en('Cramps without a period can also come from '
              'ovulating later than usual, constipation, gas or an ovarian '
              'cyst. Most of these settle on their own. Cramps that are '
              'severe, one-sided or getting worse need a doctor, and the box '
              'at the end says how soon.'),
        ],
      ),

      PvReadSection(
        heading: _en('What else causes spotting before a period?'),
        paragraphs: [
          _en('Implantation is only one of several reasons. The '
              'common ones are:'),
        ],
        bullets: [
          _en('Spotting as progesterone drops in the day or two '
              'before a period. This is common.'),
          _en('Ovulation spotting, in the middle of the cycle, '
              'about two weeks earlier.'),
          _en('Sex, if the cervix is a little tender.'),
          _en('A cervical polyp or an infection, which a doctor '
              'can check.'),
          _en('Fertility medicines, or progesterone support in '
              'a treatment cycle.'),
          _en('A very early pregnancy loss, which can look like '
              'a slightly late, slightly heavier period.'),
        ],
        tip: PvReadTip(
          title: _en('If it happens every month'),
          body: _en('Spotting for several days before most periods is '
              "worth mentioning to your doctor. It's usually nothing serious, "
              'but a pattern is worth checking, and a few months of notes '
              'will help.'),
        ),
      ),

      PvReadSection(
        heading: _en('When should I test?'),
        paragraphs: [
          _en('Test on the day your period is due. If the '
              'spotting came earlier than that, wait, because hCG may still '
              'be too low to show.'),
          _en("If the test is negative and your period hasn't "
              'come two or three days later, test again with first-morning '
              'urine.'),
          _en('Make a note of the day the spotting started, how '
              'long it lasted and what it looked like. If you do see a '
              'doctor, it helps them a lot.'),
          _en("If it's positive, book a visit with a "
              'gynaecologist and tell them about the spotting. Bleeding in '
              'early pregnancy is common. ACOG says about 15 to 25 per cent '
              'of pregnant women have some bleeding in the first trimester, '
              'and it often settles.'),
          _en("If you're pregnant and bleeding, don't stop any "
              'medicine your doctor prescribed without asking them first.'),
        ],
      ),

      PvReadSection(
        collapsible: true,
        summary: _en('Progesterone support and procedures can cause '
            'spotting. Tell your clinic, and keep to their plan.'),
        heading: _en("What if I'm having fertility treatment?"),
        paragraphs: [
          _en('Spotting in the two weeks after an IUI or embryo '
              'transfer is common. Progesterone pessaries and gels can cause '
              'it, and so can the procedure itself.'),
          _en('Tell your clinic about any bleeding, and keep '
              'taking your medicines unless they tell you to stop. Spotting '
              "doesn't mean the cycle has failed."),
          _en('Your clinic will give you a test date, often for '
              'a blood test. Go by that date rather than testing at home '
              'because of the spotting.'),
        ],
      ),

    ],

    faqs: [
      PvReadFaq(
        question: _en('Can implantation bleeding be heavy?'),
        answer: _en("No, it's usually light. Bleeding heavy enough to "
            'fill a pad is much more likely to be a period, and if you might '
            'be pregnant, it needs a doctor to check.'),
      ),
      PvReadFaq(
        question: _en('How soon after spotting can I test?'),
        answer: _en('Wait until the day your period is due, or two to '
            'three days after the spotting, whichever is later. Testing on '
            'the day of spotting is usually too early.'),
      ),
      PvReadFaq(
        question: _en('I had spotting and then my period came. Was I '
            'pregnant?'),
        answer: _en('Most likely, the spotting was the start of your '
            'period. Brown spotting a day or two before a period is very '
            'common. If the period was later, heavier or more painful than '
            'usual, a doctor can talk it through with you.'),
      ),
      PvReadFaq(
        question: _en('Is spotting after sex a bad sign?'),
        answer: _en('Not usually. The cervix can bleed a little after '
            'sex. If it happens often, or comes with pain, see a doctor, as '
            'it has other causes worth checking.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help, and how soon'),
      body: _en('Go to a hospital the same day if you bleed heavily '
          '(soaking a pad in an hour), have strong pain on one side, pain at '
          'the tip of your shoulder, or feel faint or dizzy, especially if '
          "you've had a positive test or might be pregnant. These can be "
          'signs of an ectopic pregnancy or a miscarriage and need care '
          'today. If you faint or the pain is severe, call 108 or 112. See a '
          'doctor within a few days if spotting keeps happening, comes after '
          'sex, or comes between periods.'),
    ),

    evidence: _en('Implantation timing follows StatPearls, "Physiology, '
        'Pregnancy" (NCBI Bookshelf). Bleeding in early pregnancy follows '
        "ACOG's patient guidance \"Bleeding During Pregnancy\" and the NHS. "
        'Causes of spotting between periods follow the NHS and Cleveland '
        'Clinic. Ectopic and miscarriage warning signs follow the NHS and '
        'RCOG. Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        // Kept for revert (2026-09-28, explicit names): title: _en('When to take a test, and which one'),
        title: _en('When to take a pregnancy test, and which one'),
        value: _en('The day a test can give you a real answer.'),
        surfaceId: 'ttc_read/ttc_read_when_to_test',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log the spotting'),
        value: _en('A note of the day and colour helps you, and your '
            'doctor, later.'),
        surfaceId: 'ttc_symptom_log',
      ),
    ],

    // ⚠️ ONE READ, ONCE, AT THE FOOT (2026-09-28, no repetition):
    // 'ttc_read_when_to_test' is the next step "When to take a test, and which one",
    // so the Read next rail no longer lists it a second time.
    // Kept for revert:
    // readNext: ['ttc_read_when_to_test', 'ttc_read_spotting', 'ttc_read_faint_line'],
    readNext: ['ttc_read_spotting', 'ttc_read_faint_line'],
  ),

  // ===========================================================================
  //  Late period, negative test
  //  Covers: Flo "9 other reasons why your period may be late", "Your period is late. Is it
  //  time to take a pregnancy test?", "Why you shouldn't induce your period", "Pregnancy
  //  signs with irregular periods" (in part); What to Expect "Missed Your Period?".
  //  The "tablets to bring on a period" section is India-specific on purpose: it is common
  //  to be handed one without a test first.
  // ===========================================================================
  PvRead(
    id: 'ttc_read_late_negative',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('My period is late but the test is negative'),
    teaser: _en("The common reasons a period is late when you're not "
        'pregnant, when to test again, and when to see a doctor.'),

    shortAnswer: _en('The most common reason is that you ovulated later than '
        "usual, so your period isn't late yet and the test may be too early. "
        'Stress, illness, travel, weight change, PCOS and thyroid problems '
        'can also delay a period. Test again in three days to a week, and see '
        'a doctor if your period is over a week late and the test is still '
        'negative.'),

    scaleSetter: _en('A late period with a negative test is very common, and '
        'it usually has a simple reason. One late period is rarely a sign of '
        "anything serious. It's worth a doctor's visit if it goes on for more "
        'than a week, or keeps happening.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("It's one of the hardest mornings of trying. Your "
              "period hasn't come, the test says no, and you're left "
              'somewhere in between.'),
          _en("Here's what's usually going on, and what to do "
              'over the next week or so.'),
        ],
      ),

      PvReadSection(
        heading: _en('Could I still be pregnant?'),
        paragraphs: [
          _en('Sometimes, yes. If you ovulated later than usual '
              'this month, implantation happened later too, and hCG may not '
              "have built up yet. In that case your period isn't really late. "
              'The whole cycle has shifted.'),
          _en('Test again in three days to a week, with '
              'first-morning urine. Most pregnancies show on a home test by a '
              'week after a missed period.'),
          _en("If you're still unsure, a blood hCG test can "
              'find lower levels than a home test. Your doctor can order it, '
              'and the result usually comes back within a day.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why else might my period be late?'),
        paragraphs: [
          _en('Your cycle depends on a chain of hormones that '
              'starts in your brain, and lots of everyday things can nudge '
              'it. The common reasons are:'),
        ],
        bullets: [
          _en('A later ovulation this month. The first half of '
              'the cycle can stretch, and your period moves with it. This is '
              'the most common reason.'),
          _en('Stress. A hard month at work, a family event, or '
              'the strain of trying can delay ovulation.'),
          _en('Illness. A fever, a bad cold or a stomach bug '
              'around the middle of your cycle can push ovulation back.'),
          _en('Travel and night shifts, which upset sleep and '
              'body rhythms.'),
          _en('A big change in weight, eating much less than '
              'usual, or a lot more exercise than usual.'),
          _en('PCOS, which often makes cycles long or '
              'irregular.'),
          _en('A thyroid problem, whether the thyroid is too '
              'active or too slow.'),
          _en('A raised level of prolactin, a hormone that can '
              'stop ovulation. Some medicines raise it.'),
          _en('Recently stopping hormonal birth control. Cycles '
              'can take a few months to settle.'),
          _en('Breastfeeding, if you have a young baby.'),
          _en('Being in your forties, as cycles start to change '
              'in the years before menopause.'),
        ],
      ),

      PvReadSection(
        heading: _en('Can stress alone make my period late?'),
        paragraphs: [
          _en('It can. Stress affects the part of the brain '
              'that sets off ovulation each month. A tense couple of weeks '
              'around the middle of your cycle can delay ovulation by a few '
              'days, and your period moves with it.'),
          _en("This isn't your fault, and you didn't cause it "
              'by worrying. One late cycle after a hard month is common, and '
              'it usually settles by itself.'),
        ],
      ),

      PvReadSection(
        heading: _en('Should I take a tablet to bring my period on?'),
        paragraphs: [
          _en("In India, it's common to be offered tablets to "
              'bring on a late period, by a chemist, a relative or even a '
              "clinic, without a test first. Please don't take them until a "
              "doctor has checked that you aren't pregnant."),
          _en("Some hormone tablets used for this aren't meant "
              'for pregnancy. The bleed they cause can also be mistaken for a '
              'period, so a pregnancy in the wrong place could be missed.'),
          _en('Tablets that end a pregnancy are sometimes sold '
              'without a prescription. They should only ever be taken under a '
              "doctor's care, because they can cause heavy bleeding and "
              'infection.'),
          _en('If your period is late, the safe order is: test, '
              'wait a few days, test again, then see a doctor. If a doctor '
              'thinks your period needs bringing on, they can do it safely '
              "once they've checked."),
        ],
        mythFact: PvMythFact(
          myth: _en('A late period just needs a tablet to set it '
              'right.'),
          fact: _en('A late period is a sign, not the problem itself. '
              "A tablet can bring on a bleed, but it doesn't fix the reason "
              'the period was late, and it can hide a pregnancy. A test and a '
              'doctor come first.'),
        ),
      ),

      PvReadSection(
        heading: _en('What if my periods are always irregular?'),
        paragraphs: [
          _en('If your cycles already vary a lot, as they often '
              "do with PCOS, it's hard to know when a period is late. Count "
              'from sex instead: a test 21 days after the last time you had '
              'sex will show most pregnancies from that time.'),
          _en('If you use ovulation strips, test about two '
              'weeks after a positive one. Signs like sore breasts or nausea '
              "don't help much, because the same signs come before a period."),
          _en("It's worth seeing a doctor if your cycles are "
              'often longer than 35 days. PCOS, thyroid and prolactin '
              'problems can be checked with blood tests and a scan, and most '
              'can be treated.'),
        ],
      ),

      PvReadSection(
        heading: _en('What should I do now?'),
        paragraphs: [
          _en('A simple plan for the next few weeks:'),
        ],
        bullets: [
          _en('1. Test again in three days to a week, with '
              'first-morning urine.'),
          _en('2. Note the day your period should have come, '
              'and any spotting.'),
          _en('3. If your period is over a week late and the '
              'test is still negative, see a doctor.'),
          _en('4. If your periods stop for three months, or '
              'your cycles are often over 35 days, see a doctor for a check.'),
          _en("5. Don't take anything to bring on a period "
              'until a doctor has checked you.'),
        ],
      ),

    ],

    faqs: [
      PvReadFaq(
        question: _en('How late can a period be before I should worry?'),
        answer: _en('A few days either way is normal. More than a week '
            'late with negative tests is a reason to see a doctor, not a '
            'reason to panic. Most of the time the reason is simple.'),
      ),
      PvReadFaq(
        question: _en('Can a test be negative a week after a missed '
            "period and I'm still pregnant?"),
        answer: _en("It can happen, but it's uncommon. It's usually "
            'because ovulation was late, so the pregnancy is younger than you '
            'think. A blood test can settle it.'),
      ),
      PvReadFaq(
        question: _en("Does a late period mean I can't get pregnant?"),
        answer: _en('No. One late period says very little about '
            'fertility. A pattern of long or missing cycles is worth '
            "checking, because it can mean you don't ovulate every month, and "
            'that is often treatable.'),
      ),
      PvReadFaq(
        question: _en('Could it be an ectopic pregnancy?'),
        answer: _en('Rarely, an ectopic pregnancy gives a negative or '
            "very faint test. That's why pain on one side, shoulder-tip pain, "
            'dizziness or unusual bleeding with a late period should be '
            'checked the same day.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help, and how soon'),
      body: _en('Go to a hospital the same day if your period is late '
          'and you have strong pain low down on one side, pain at the tip of '
          'your shoulder, feel dizzy or faint, or bleed much more heavily '
          'than usual. Rarely, these are signs of an ectopic pregnancy, which '
          'can show a negative or faint test. If the pain is severe or you '
          "faint, call 108 or 112. Book a doctor's visit if your period is "
          "over a week late with negative tests, or if you've had no period "
          'for three months.'),
    ),

    evidence: _en('Causes of a late or missed period follow the NHS page '
        '"Stopped or missed periods", Cleveland Clinic on amenorrhoea, and '
        'StatPearls, "Amenorrhea" (NCBI Bookshelf). When to retest and the '
        '21-day rule follow the NHS page "Doing a pregnancy test". Ectopic '
        'warning signs follow the NHS and RCOG. Sources checked September '
        '2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log your cycle'),
        value: _en('The date your period should have come is worth '
            'keeping.'),
        surfaceId: 'ttc_calendar',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        // Kept for revert (2026-09-28, explicit names): title: _en('Is it time for a check?'),
        title: _en('Should you get a fertility check?'),
        value: _en("When a late or irregular cycle is worth a doctor's "
            'visit.'),
        surfaceId: 'ttc_fertility_help',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('PCOS check'),
        value: _en('If your cycles are often long, a few questions to '
            'take to a doctor.'),
        surfaceId: 'ttc_pcos_check',
      ),
    ],

    readNext: ['ttc_read_when_to_test', 'ttc_read_late_period', 'ttc_read_pcos_irregular'],
  ),

  // ===========================================================================
  //  Early pregnancy signs, and why most are also PMS
  //  Grows the chapter section "Why spotting symptoms can't tell you" into a full piece, and
  //  keeps its line: the same hormone causes both, so only a test can tell.
  //  Covers: Flo "9 early signs", "PMS vs. early pregnancy signs", "8 signs that are PMS",
  //  "Hate the wait", "Can discharge signal pregnancy?"; What to Expect "14 Early Signs",
  //  "Am I Pregnant or Is It Just PMS?". No quiz, on purpose: it would guess her result.
  // ===========================================================================
  PvRead(
    id: 'ttc_read_early_signs',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Early pregnancy signs, and why most are also PMS'),
    teaser: _en('What the earliest signs of pregnancy are, when they '
        "tend to start, and why they can't answer before a test can."),

    shortAnswer: _en('The first reliable sign of pregnancy is a missed '
        'period. Sore breasts, tiredness, cramps, bloating and mood changes '
        'are early signs too, but they come from progesterone, which rises '
        'after ovulation in every cycle. So before your period is due, early '
        'pregnancy and PMS feel the same, and only a test can tell them '
        'apart.'),

    scaleSetter: _en("If you've been reading every twinge this week, you're "
        "not alone, and you're not doing anything wrong. Knowing which signs "
        "can't tell you anything yet can take some of the pressure off the "
        'wait.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Search for early signs of pregnancy and you'll "
              'find long lists. Most of those signs are real signs of '
              'pregnancy.'),
          _en('The trouble is that most of them are also real '
              'signs of a period on its way. This read explains why, and '
              "which signs come later. It can't tell you whether this month "
              'worked. Nothing can, until a test does.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why do pregnancy and PMS feel the same?'),
        paragraphs: [
          _en('After ovulation, the empty follicle in your '
              'ovary makes progesterone, whether or not an egg was '
              'fertilised. Progesterone is behind most of what you feel in '
              'the second half of your cycle.'),
          _en("If you're pregnant, progesterone stays high. If "
              "you're not, it stays high until a day or two before your "
              'period. So for most of the two-week wait, your body feels much '
              'the same either way.'),
          _en('The pregnancy hormone, hCG, only starts after '
              'implantation, and it takes days to build up. Before a missed '
              "period, there's usually too little of it to cause signs of its "
              'own.'),
        ],
      ),

      PvReadSection(
        heading: _en('The signs, and what each one can tell you'),
        paragraphs: [
          _en("Here's how the common signs line up. The first "
              'seven come in both. The last few usually arrive after a test '
              'would already be positive.'),
        ],
        bullets: [
          _en('A missed period. The most reliable early sign, '
              'and the reason to test.'),
          _en('Sore or heavy breasts. Common in early '
              'pregnancy, and just as common before a period.'),
          _en('Tiredness. Progesterone makes you sleepy in '
              'both.'),
          _en('Mild cramps or a pulling feeling low down. '
              'Happen in both.'),
          _en('Bloating and constipation. Both, because '
              'progesterone slows the gut.'),
          _en('Mood changes and tears. Both.'),
          _en('Light spotting. Can be implantation, or the '
              'start of a period.'),
          _en('More discharge. It often increases in early '
              "pregnancy, but it changes through every cycle too, so it isn't "
              'a reliable sign.'),
          _en('Nausea. More typical of pregnancy, but it '
              'usually starts at or after the missed period, not before.'),
          _en('Needing to pee more, a metallic taste, or a '
              'strong sense of smell. These tend to come a little later.'),
        ],
      ),

      PvReadSection(
        heading: _en('Which signs come later?'),
        paragraphs: [
          _en('For most women, nausea starts somewhere between '
              'four and nine weeks of pregnancy, counted from the last '
              "period. That's at or after the missed period. Needing to pee "
              'more often tends to start around the same time.'),
          _en('Changes to the breasts, like darker skin around '
              'the nipple, come over the weeks that follow.'),
          _en('Some women also notice a stuffy nose, headaches, '
              'or feeling light-headed when they stand up quickly. These '
              'happen in early pregnancy, but a period, a cold or a poor '
              "night's sleep can bring them too."),
          _en('So if you feel sick three days after ovulation, '
              "it's very unlikely to be from a pregnancy. At that point "
              "implantation hasn't happened, and no hCG is being made."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('No signs is normal too'),
          body: _en('Many women who are pregnant feel nothing at all '
              'before their missed period, and some feel very little for '
              "weeks. Having no signs doesn't mean it didn't work."),
        ),
      ),

      PvReadSection(
        heading: _en('Can discharge or my temperature tell me?'),
        paragraphs: [
          _en('Discharge changes through every cycle. After '
              'ovulation it usually turns thicker and stickier, and many '
              'women have more of it before a period. It can increase in '
              "early pregnancy too, so it can't tell you which is happening."),
          _en('If you chart your temperature each morning, it '
              'rises after ovulation in every cycle and stays up while '
              "progesterone is high. If it's still up after the day your "
              "period was due, that's a good reason to take a test. On its "
              "own, it still isn't an answer."),
          _en('Checking the position or feel of your cervix '
              "can't tell you either. It changes through every cycle, and the "
              'changes in early pregnancy are too small to rely on.'),
        ],
      ),

      PvReadSection(
        heading: _en('What if my periods are irregular?'),
        paragraphs: [
          _en('With irregular cycles, including with PCOS, you '
              'may not know when your period is due, so a missed period is '
              'harder to spot. Signs like sore breasts and tiredness are no '
              'more reliable for you than for anyone else.'),
          _en('Count from sex instead of from your period. A '
              'test 21 days after the last time you had sex will show most '
              'pregnancies from that time. If you use ovulation strips, test '
              'about two weeks after a positive one.'),
          _en("If something feels new or different and you're "
              "unsure, a test is cheap and quick. It's fine to take one."),
        ],
      ),

      PvReadSection(
        heading: _en('How do I stop reading every twinge?'),
        paragraphs: [
          _en("It's hard not to. When you're hoping, you notice "
              "small changes you'd usually miss. A few things help:"),
        ],
        bullets: [
          _en('Log how you feel if it helps, then close the '
              'app. Notes are useful for your doctor, not as clues.'),
          _en('Choose your test day in advance, and wait for '
              'it.'),
          _en('Stay away from symptom forums in the second '
              'week.'),
          _en('When you notice a twinge, name it: progesterone, '
              'doing what it does every month.'),
        ],
        mythFact: PvMythFact(
          myth: _en('If this month feels different, I must be '
              'pregnant.'),
          fact: _en('Every cycle feels a little different. How you '
              'feel in the second half changes with sleep, stress, food and '
              "how closely you're paying attention. Feeling different doesn't "
              "mean pregnant, and feeling the same doesn't mean not."),
        ),
      ),

    ],

    faqs: [
      PvReadFaq(
        question: _en('Can I have pregnancy symptoms a week after sex?'),
        answer: _en("Not from a pregnancy. hCG isn't made until "
            'implantation, 6 to 12 days after ovulation, and it takes days '
            'more to build up. What you feel a week after sex comes from '
            'progesterone, which happens every cycle.'),
      ),
      PvReadFaq(
        question: _en('Is white discharge before my period a sign of '
            'pregnancy?'),
        answer: _en('Not a reliable one. Discharge changes through '
            'every cycle and often increases before a period. It can also '
            "increase in early pregnancy, so it can't tell you either way."),
      ),
      PvReadFaq(
        question: _en('My symptoms are stronger than usual this month. '
            'Does that mean something?'),
        answer: _en('Not on its own. The strength of these feelings '
            "changes from month to month, and it rises when you're watching "
            'closely. A test on the day your period is due is the answer.'),
      ),
      PvReadFaq(
        question: _en('Can I be pregnant with no symptoms at all?'),
        answer: _en('Yes. Many women feel nothing before a missed '
            'period, and some feel very little for the first few weeks. It '
            'says nothing about how the pregnancy is going.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help, and how soon'),
      body: _en('Go to a hospital the same day if you have strong '
          'pain low down on one side, pain at the tip of your shoulder, feel '
          'faint or dizzy, or bleed heavily, especially after a positive '
          'test. These can be signs of an ectopic pregnancy, one growing '
          "outside the womb. It's rare, but it needs care today, not an "
          'appointment next week. If the pain is severe or you faint, call '
          '108 or 112 for an ambulance. See a doctor within a few days if you '
          'have burning when you pee, a fever, or discharge that smells, '
          'itches or changes colour, as these point to an infection.'),
    ),

    evidence: _en('Progesterone and the luteal phase follow StatPearls, '
        '"Physiology, Menstrual Cycle" (NCBI Bookshelf) and Cleveland Clinic. '
        'Early pregnancy signs and when nausea starts follow the NHS page '
        "\"Signs and symptoms of pregnancy\" and ACOG's guidance on morning "
        'sickness. The 21-day rule follows the NHS page "Doing a pregnancy '
        'test". Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log how you feel'),
        value: _en('A note of what you felt is useful later, even if '
            "it isn't a clue now."),
        surfaceId: 'ttc_symptom_log',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        // Kept for revert (2026-09-28, explicit names): title: _en('When to take a test, and which one'),
        title: _en('When to take a pregnancy test, and which one'),
        value: _en('The day a test can give you a real answer.'),
        surfaceId: 'ttc_read/ttc_read_when_to_test',
      ),
    ],

    // ⚠️ ONE READ, ONCE, AT THE FOOT (2026-09-28, no repetition):
    // 'ttc_read_when_to_test' is the next step "When to take a test, and which one",
    // so the Read next rail no longer lists it a second time.
    // Kept for revert:
    // readNext: ['ttc_read_feeling_pregnant', 'ttc_read_when_to_test', 'ttc_read_two_week_wait'],
    readNext: ['ttc_read_feeling_pregnant', 'ttc_read_two_week_wait'],
  ),

  // ===========================================================================
  //  Feeling pregnant, but the test says no
  //  Covers: Flo "Feeling pregnant, but no positive test?", "5 reasons you may feel
  //  pregnant", "A negative pregnancy test. What does it mean?". Population figures only
  //  (NICE CG156, ASRM); never a number addressed to her.
  // ===========================================================================
  PvRead(
    id: 'ttc_read_feeling_pregnant',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Feeling pregnant, but the test says no'),
    teaser: _en("Why your body can feel pregnant when you're not, what "
        "a negative test does and doesn't mean, and what helps."),

    shortAnswer: _en("Your body can feel pregnant when you aren't, because "
        'progesterone, which is high after every ovulation, causes the same '
        'feelings as early pregnancy. Worry, fertility medicines and paying '
        'close attention can make those feelings stronger. A negative test on '
        'or after the day your period is due is usually right, but a negative '
        "before then isn't final."),

    scaleSetter: _en('Feeling pregnant and then seeing a negative test is '
        "one of the most painful parts of trying. It doesn't mean your body "
        'is broken, and it says nothing about next month. It means your body '
        'did what it does every cycle.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('You were sure this time. Your breasts ached, you '
              'felt sick, you were so tired. Then the test said no, or your '
              "period came. It's okay to feel crushed."),
          _en("Here's why it happens, so you know it isn't in "
              "your head, and it isn't your fault."),
        ],
      ),

      PvReadSection(
        heading: _en("Why do I feel pregnant when I'm not?"),
        paragraphs: [
          _en('There are a few common reasons, and more than '
              'one can happen at once:'),
        ],
        bullets: [
          _en('Progesterone. It rises after ovulation in every '
              'cycle and causes sore breasts, tiredness, bloating, cramps, '
              'mood changes and sometimes mild nausea. These are the same '
              'feelings as early pregnancy.'),
          _en("Paying close attention. When you're hoping, you "
              'notice every small change. Most of them happen every month, '
              "but usually you aren't looking."),
          _en('Worry. Anxiety can cause nausea, tiredness, poor '
              'sleep, an upset stomach and even a late period.'),
          _en('Fertility medicines. Progesterone support after '
              'IUI or IVF causes pregnancy-like feelings. Ovulation tablets '
              'like letrozole or clomiphene can bring hot flushes, bloating '
              'and mood changes.'),
          _en('Something else going on, like a stomach bug, '
              'acidity, a urine infection or a thyroid problem.'),
        ],
        tip: PvReadTip(
          title: _en('A rare kind of feeling pregnant'),
          body: _en('Very rarely, someone has strong signs of '
              'pregnancy for weeks or months, even a growing belly, without '
              "being pregnant. It's a real condition, not pretending, and a "
              'doctor can help.'),
        ),
      ),

      PvReadSection(
        heading: _en('Could the test be wrong?'),
        paragraphs: [
          _en('If you tested before your period was due, it may '
              'just be too early. The test can only find hCG after '
              'implantation, and it needs a few days to build up.'),
          _en('If you tested on the day your period was due or '
              'later, with first-morning urine, and read it on time, a '
              "negative is usually right. If your period still hasn't come, "
              'test again in three days to a week.'),
          _en('A negative test followed by a normal period '
              "means this cycle didn't lead to a pregnancy."),
          _en("If you're taking progesterone after treatment, "
              'your period may not come until you stop it, even when the test '
              'is negative. Ask your clinic what to do next rather than '
              'stopping on your own.'),
          _en('Now and then, a pregnancy starts and ends very '
              'early, before a test would show it. You might notice a '
              'slightly late or heavier period. This is common, and nothing '
              'you did caused it.'),
        ],
      ),

      PvReadSection(
        heading: _en('What does a negative test mean for next month?'),
        paragraphs: [
          _en("Very little. Most healthy couples don't get "
              'pregnant in any single month. For healthy couples in their '
              'twenties and early thirties, only about 20 per cent of cycles '
              'lead to a pregnancy, on average.'),
          _en('Over time, those months add up. NICE, the UK '
              'guideline body, says more than 80 per cent of couples conceive '
              'within a year of trying with regular sex, when the woman is '
              'under 40. About half of the rest do in the second year.'),
          _en('So a negative this month is what usually '
              "happens, even for couples who go on to have a baby. It isn't a "
              'sign that something is wrong.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("It isn't something you did"),
          body: _en('Nothing you ate, lifted or worried about this '
              'fortnight made this month not work. The most common reason is '
              'a chance problem in the egg or early embryo that nobody could '
              'see or change.'),
        ),
      ),

      PvReadSection(
        heading: _en('Is it normal to feel this low?'),
        paragraphs: [
          _en('Yes. Each cycle can bring two weeks of hope and '
              'then a sudden stop. Going through that month after month is '
              'tiring for anyone.'),
          _en('Feeling tearful, angry or flat on the day your '
              "period comes is common. It doesn't mean you're not coping, and "
              "it doesn't mean you want this too much."),
          _en('It can be hard when your partner seems to take '
              'it more lightly. People grieve differently, and some keep it '
              'inside. It helps to say out loud what the day is like for each '
              'of you.'),
        ],
      ),

      PvReadSection(
        heading: _en('How can I get through the day it says no?'),
        paragraphs: [
          _en("There's no right way to feel. A few things help "
              'many couples:'),
        ],
        bullets: [
          _en("Let yourself be sad. It's a real loss of hope, "
              'even if nothing was ever confirmed.'),
          _en('Decide in advance what that day looks like: who '
              'tells whom, and whether you take the evening off.'),
          _en("Put the tests away for this cycle. You don't "
              'need to plan the next one tonight.'),
          _en("Tell your partner how you're feeling. They may "
              'be sad too, even if they show it differently.'),
          _en("Do one small thing that's just for you."),
        ],
      ),

      PvReadSection(
        heading: _en('When is it worth seeing a doctor?'),
        paragraphs: [
          _en("If you've been trying for a year, or six months "
              "if you're 35 or older, it's time to see a doctor together. Go "
              'sooner if your periods are irregular, or you have a known '
              'condition.'),
          _en('If you have strong pregnancy-like signs every '
              'month and tests stay negative, a doctor can check your '
              'hormones, including thyroid and prolactin.'),
          _en('If the sadness stays for weeks, or each month '
              'feels harder than the last, talking to a counsellor can help. '
              "It's a common reason people look for support while trying."),
          _en("If you've had fertility treatment, ask your "
              'clinic when to test. They may prefer a blood test.'),
        ],
      ),

    ],

    faqs: [
      PvReadFaq(
        question: _en('Can I have a negative test and still be pregnant?'),
        answer: _en('Yes, if you tested early. From about a week after '
            'a missed period, a negative home test is very likely to be '
            "right. If you're still unsure, a blood test can settle it."),
      ),
      PvReadFaq(
        question: _en('Can wanting a baby so much make me feel pregnant?'),
        answer: _en("It can make you notice feelings you'd usually "
            "miss, and worry can cause nausea and tiredness. You're not "
            "imagining them. They're real, they just have another cause."),
      ),
      PvReadFaq(
        question: _en('Is it normal to cry every time my period comes?'),
        answer: _en("Yes. Many women do, month after month. If it's "
            "getting harder rather than easier, or it's affecting your sleep "
            "and work, that's a good time to talk to someone."),
      ),
      PvReadFaq(
        question: _en('Should I keep testing every day until my period '
            'comes?'),
        answer: _en("It won't give you an answer sooner. One test on "
            'the day your period is due, and another a few days later if it '
            "doesn't come, tells you just as much with fewer hard mornings."),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help, and how soon'),
      body: _en('See a doctor within a few days if your period is '
          "over a week late with negative tests, or if you've had no period "
          'for three months. Go to a hospital the same day if you have strong '
          'pain on one side, shoulder-tip pain, fainting or heavy bleeding. '
          'Rarely, these are signs of an ectopic pregnancy, which a home test '
          'can miss. If low mood is making it hard to get through the day, '
          'talk to a doctor or counsellor soon. If you ever feel you might '
          'harm yourself, call Tele MANAS on 14416 today.'),
    ),

    evidence: _en('Progesterone in the second half of the cycle follows '
        'StatPearls, "Physiology, Menstrual Cycle" (NCBI Bookshelf). Monthly '
        'and yearly conception figures follow NICE guideline CG156, '
        '"Fertility problems: assessment and treatment", and the ASRM '
        'committee opinion "Optimizing natural fertility". When to see a '
        'doctor follows NICE and ASRM. Tele MANAS is the Government of '
        "India's mental health helpline. Sources checked September 2026."),

    nextSteps: [
      // Kept for revert (2026-09-28, journal out of TTC): this next step opened the journal, which left the stage.
      // PvReadNextStep(
      //   kind: PvNextKind.activity,
      //   title: _en('Write it down'),
      //   value: _en('A few lines about today can help it feel less '
      //       'heavy.'),
      //   surfaceId: 'ttc_journal',
      // ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        // Kept for revert (2026-09-28, explicit names): title: _en('Is it time for a check?'),
        title: _en('Should you get a fertility check?'),
        value: _en("When trying for a while is worth a doctor's visit."),
        surfaceId: 'ttc_fertility_help',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log your period'),
        value: _en('A new cycle starts today, and your dates carry on.'),
        surfaceId: 'ttc_calendar',
      ),
    ],

    readNext: ['ttc_read_early_signs', 'ttc_read_period_came', 'ttc_read_when_to_seek_help'],
  ),

];
