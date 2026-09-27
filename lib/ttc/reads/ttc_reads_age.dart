// =============================================================================
//  IVF & IUI › Age and second baby — the reads for this tab, plus two IVF
//  reference reads (a glossary, and ovulation tablets with follicle scans)
// -----------------------------------------------------------------------------
//  Written 2026-09-26 from the TTC gap analysis (stream A, "Age and second
//  baby", P2, and the IVF & IUI P3 row). One file of its own so several
//  helpers can add reads at once without touching each other's brackets.
//
//  ⚠️ THE AGGREGATOR IS STILL THE ONLY PUBLIC ENTRY POINT. Nothing outside
//  `ttc_reads_data.dart` should import this file.
//
//  ⚠️ AGE IS WHERE THE "NEVER HER CHANCES" RULE IS EASIEST TO BREAK. Every
//  figure below is a population figure (NICE's table of pregnancies within one
//  and two years by age band), phrased "in 100 women", never attached to her.
//  No per-cycle IVF rate by age appears anywhere, on purpose.
//
//  ⚠️ INDIAN LAW IS STATED AS FACT, WITH THE ACT'S NAME AND YEAR, AND EVERY
//  LEGAL SECTION ENDS WITH "your clinic will confirm what applies to you".
//  The Surrogacy Rules on donor gametes changed in 2023 and again in 2024; if
//  they change again, the surrogacy read is the one to revisit first.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../ttc_read_blocks.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, ON PURPOSE — see the note in
// `ttc_reads_ivf.dart`.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsAge = [
  // ===========================================================================
  //  Trying after 35
  // ===========================================================================
  PvRead(
    id: 'ttc_read_age_after_35',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Trying for a baby after 35: what changes?'),
    teaser: _en("What age changes, what it doesn't, and when to see a doctor "
        'sooner.'),
    shortAnswer: _en('Fertility dips gently in the early thirties and more '
        'clearly after 35, mostly because eggs change with age. Most women '
        'aged 35 to 39 still get pregnant within a year or two of trying. '
        'The main difference is timing: see a doctor after six months of '
        'trying, not twelve.'),
    scaleSetter: _en('Many women in India now start trying in their '
        'thirties, and most of them have babies. Age matters, but it changes '
        "slowly, not overnight on a birthday. What helps most is knowing when "
        "to ask for help, so you don't lose time waiting."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      // Age, asked once, with one tap (2026-09-26, gap plan). The TTC openers
      // draw it (`ttcReadCustomBlock`); it writes the same saved answer the
      // fertility-help tool keeps, and shows that answer if she already gave
      // it. Anywhere else this section draws nothing and the read is whole.
      const PvReadSection(custom: TtcAgeBandAskBlock()),
      PvReadSection(
        paragraphs: [
          _en("If you're 35 or older and trying, you've probably heard a lot "
              'of warnings. Some of it is true and some of it is overdone. '
              'This read sorts out which is which, with real figures and no '
              'scare stories.'),
          _en("The number 35 isn't a cliff. It's the age where doctors start "
              'to act a little sooner, because time matters a bit more from '
              'here. Nothing about your body changes on the morning of your '
              'birthday.'),
        ],
      ),
      PvReadSection(
        heading: _en('What happens to eggs as you get older?'),
        paragraphs: [
          _en("You're born with all the eggs you'll ever have. There are one "
              'to two million at birth, around 300,000 by puberty, and about '
              '25,000 by the late thirties. Each month a small group starts '
              "to grow, and most are lost, whether or not you're trying."),
          _en("The number matters less than you'd think. What changes more "
              'with age is quality. An older egg is more likely to carry the '
              'wrong number of chromosomes, the tiny packages that hold the '
              'instructions for building a baby.'),
          _en("An embryo made from such an egg usually doesn't implant, or "
              'the pregnancy ends very early. This is the main reason it can '
              'take longer after 35, and why early miscarriage becomes more '
              "common. It's biology. It isn't anything you did or didn't do."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('What the figures say'),
          body: _en("These figures come from NICE's fertility guideline and "
              'count women having regular sex without contraception. Aged 19 '
              'to 26: about 92 in 100 are pregnant within a year, and 98 in '
              '100 within two years. Aged 35 to 39: about 82 in 100 within a '
              'year, and 90 in 100 within two years. They describe large '
              'groups of women, not what will happen to any one person.'),
        ),
      ),
      PvReadSection(
        heading: _en("Do men's sperm get older too?"),
        paragraphs: [
          _en("Yes, though more slowly. Men make new sperm all the time, so "
              "they don't run out. But from around 40 to 45, sperm quality "
              'tends to dip, and it can take a little longer to conceive when '
              'the man is older.'),
          _en('Older fathers are also linked to a small rise in some rare '
              'health conditions in children. The rise is small, and most '
              "children of older fathers are healthy. It's one more reason "
              'his health counts as much as yours, and his test belongs at '
              'the first visit, not the last.'),
        ],
      ),
      PvReadSection(
        heading: _en('When should you see a doctor?'),
        paragraphs: [
          _en("If you're 35 to 39, see a gynaecologist after six months of "
              "regular sex without a pregnancy. You don't need to wait the "
              'full twelve months younger couples are told. The American '
              'Society for Reproductive Medicine (ASRM) and ACOG both advise '
              'this.'),
          _en("Go sooner, without waiting six months, if your periods are "
              'irregular or have stopped, if you have had endometriosis, '
              'pelvic infection or surgery on your ovaries or tubes, or if '
              'your partner has a known sperm problem.'),
          _en('A first visit usually checks these things:'),
        ],
        bullets: [
          _en('An AMH blood test and a scan to count small follicles, which '
              'show roughly how many eggs are left.'),
          _en("Whether you're ovulating, with a scan or a progesterone blood "
              'test.'),
          _en('Whether your tubes are open, often with an HSG.'),
          _en("A semen analysis for your partner, which is simple and "
              'should come early.'),
          _en('Thyroid and prolactin, and blood sugar if needed.'),
        ],
        tip: PvReadTip(
          title: _en("AMH isn't a fertility test"),
          body: _en("A low AMH means fewer eggs are left. It doesn't mean you "
              "can't get pregnant naturally, and it says little about egg "
              "quality. It's most useful for planning treatment. If you're "
              'told your AMH is low, ask what it changes about the plan.'),
        ),
      ),
      PvReadSection(
        heading: _en('What can you do that helps?'),
        paragraphs: [
          _en("You can't change your age, and nothing slows down how eggs "
              'age. But the things that help anyone trying count for you '
              'too, and a few matter a little more now.'),
        ],
        bullets: [
          _en('Have sex every two to three days through the month. You '
              "don't need to time it to the hour."),
          _en('Take folic acid, 400 micrograms a day, starting before you '
              'conceive.'),
          _en('Get your blood pressure, blood sugar and thyroid checked '
              'before pregnancy, since these problems are more common after '
              '35.'),
          _en('Both of you stop smoking and cut out alcohol.'),
          _en('Aim for a healthy weight, without crash dieting.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('Be careful with anything sold to "improve egg quality". Some '
              'supplements, like CoQ10 or DHEA, are used in clinics for '
              'certain women, but the evidence is limited. Ask your doctor '
              'before you spend money on them.'),
        ],
      ),
      PvReadSection(
        heading: _en('Should you think about treatment sooner?'),
        paragraphs: [
          _en('Not everyone over 35 needs treatment. Many women conceive on '
              'their own after a check shows nothing in the way. If a problem '
              "does turn up, it's better to know at six months than at "
              'eighteen.'),
          _en('If tests show fewer eggs than expected, your doctor may suggest '
              "moving to IUI or IVF sooner. That's a conversation, not an "
              'order. You can ask how long it would be reasonable to keep '
              'trying on your own first.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('A few risks rise a little with age, and routine checks '
            'are there to catch them early.'),
        heading: _en('What about the pregnancy itself?'),
        paragraphs: [
          _en('Most women who get pregnant after 35 have healthy pregnancies '
              'and healthy babies. A few things do become more common, such '
              'as high blood pressure, gestational diabetes and needing a '
              'caesarean.'),
          _en('Conditions caused by an extra chromosome, like Down syndrome, '
              'also become more common with age. Screening tests for these '
              'are offered in pregnancy, and your doctor will explain them at '
              'the right time.'),
          _en('Twins become a little more likely after 35 too, even without '
              'treatment, because the body sometimes releases more than one '
              'egg in a cycle.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is 35 too old to start trying?'),
        answer: _en('No. Many women start trying at 35 or later and go on to '
            "have babies. The age is a reason to see a doctor sooner if it's "
            'taking time, not a reason to panic.'),
      ),
      PvReadFaq(
        question: _en('Should I get my AMH tested before I start trying?'),
        answer: _en("You don't need to. AMH doesn't tell you whether you'll "
            "conceive naturally. It helps if you're thinking about egg "
            "freezing, or once you're under a fertility doctor's care. On its "
            'own it often causes worry without changing what you should do.'),
      ),
      PvReadFaq(
        question: _en('My periods are regular. Does that mean my eggs are '
            'fine?'),
        answer: _en("Regular periods usually mean you're ovulating, which is "
            "good news. But they can't tell you about egg quality, the part "
            'that changes with age. That is why doctors suggest a check after '
            'six months at 35 or older, even with regular cycles.'),
      ),
      PvReadFaq(
        question: _en('Can I improve my egg quality?'),
        answer: _en("You can't undo the effect of age on eggs. You can avoid "
            'what harms them, like smoking, and keep a healthy weight. '
            'Supplements sold for egg quality have limited evidence, so ask '
            'your doctor before paying for them.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('See a doctor sooner, not later'),
      body: _en("If you're 35 to 39, book a visit with a gynaecologist after "
          'six months of trying without a pregnancy. Go now, without waiting, '
          'if your periods are irregular, very painful or have stopped, if '
          "you've had pelvic infection, endometriosis or surgery on your "
          'tubes or ovaries, or if your partner has a known sperm problem. '
          "None of this is an emergency, but time is worth using well."),
    ),
    evidence: _en("Egg numbers across life follow ACOG's patient guidance "
        '"Having a Baby After Age 35" and ACOG Committee Opinion 589, "Female '
        'Age-Related Fertility Decline". The figures by age follow NICE '
        'guideline CG156, "Fertility problems: assessment and treatment". '
        'When to seek help follows ASRM, "Definitions of infertility and '
        'recurrent pregnancy loss" (2023), and ASRM\'s committee opinion on '
        'testing ovarian reserve. Folic acid follows WHO. Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See when to get help'),
        value: _en('The right time for your age, and what to take along.'),
        surfaceId: 'ttc_fertility_help',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, one by one'),
        value: _en('What each test shows, when it is done and what it costs.'),
        surfaceId: 'ttc_tests',
      ),
    ],
    readNext: [
      'ttc_read_how_long_it_takes',
      'ttc_read_age_after_40',
      'ttc_read_ivf_workup',
    ],
  ),

  // ===========================================================================
  //  Trying after 40
  // ===========================================================================
  PvRead(
    id: 'ttc_read_age_after_40',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Trying for a baby after 40'),
    teaser: _en("An honest look at what's possible, and why seeing a doctor "
        'straight away helps.'),
    shortAnswer: _en('Getting pregnant with your own eggs is still possible '
        'after 40, but it usually takes longer and early miscarriage is more '
        'common. Doctors advise a fertility check as soon as you start '
        "trying. If it doesn't happen, treatment with your own eggs or with "
        'donor eggs are the main options.'),
    scaleSetter: _en('Women do have babies in their forties, naturally and '
        "with help. It's also true that time matters more now than at any "
        'earlier age. So the kindest thing we can do is be honest and help you '
        'move early, while you have the most options.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('You might be here because life took you somewhere else first, '
              "or because you've been trying for a while already. Either way, "
              "there's no blame in being 40."),
          _en('There is a clock that runs a little faster now, and a plan '
              'works better when it starts early. This read explains what '
              'changes, what to do first, and what the options are.'),
        ],
      ),
      PvReadSection(
        heading: _en('What changes after 40?'),
        paragraphs: [
          _en('Two things change. There are fewer eggs left, and more of the '
              'eggs that remain carry the wrong number of chromosomes. The '
              'second one matters more.'),
          _en("An egg with a chromosome error usually can't become a healthy "
              'pregnancy. The embryo may not implant, or the pregnancy may '
              'end in the first weeks. So after 40, a month without a '
              'pregnancy, or an early loss, is more often about the egg than '
              'anything you did.'),
          _en('Natural fertility tends to end some years before periods '
              'stop. Menopause usually comes between 45 and 55, so regular '
              "periods in your early forties don't mean nothing has changed."),
          _en('Early miscarriage also becomes more common in the forties, for '
              "the same reason. If it happens, it's almost always because of "
              "the egg's chromosomes, not work, stress, travel or something "
              'you ate.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why see a doctor straight away?'),
        paragraphs: [
          _en('ASRM and ACOG both advise that women over 40 have a fertility '
              'check as soon as they start trying. Waiting six or twelve '
              'months costs time that is worth more now.'),
          _en('A first visit is usually quick. It looks at how many eggs are '
              'left (an AMH test and a scan), whether you ovulate, whether '
              "your tubes are open, and your partner's semen. Your general "
              'health is checked too: blood pressure, blood sugar and thyroid.'),
          _en('With those results, your doctor can suggest whether to keep '
              'trying naturally for a short while, try IUI, or move to IVF. '
              'Many doctors suggest moving to treatment sooner at this age.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('A kind but honest word about IVF'),
          body: _en("IVF helps, but it can't undo the effect of age on eggs. "
              'After 40, IVF with your own eggs works less often per attempt '
              'than it does at 35, and it often takes more than one try. A '
              "good clinic will say this plainly and won't promise more. Be "
              'careful of any clinic that does.'),
        ),
      ),
      PvReadSection(
        heading: _en("What if your own eggs don't work?"),
        paragraphs: [
          _en('Donor eggs come from a younger woman, so the embryos behave '
              'like eggs of her age. You carry the pregnancy and give birth. '
              'For many women in their mid forties, this is the route doctors '
              'most often suggest.'),
          _en('Donor eggs are legal in India under the Assisted Reproductive '
              'Technology (Regulation) Act, 2021, known as the ART Act. The '
              'donor is anonymous, and the law treats the baby as fully '
              'yours.'),
          _en('The same Act lets ART clinics treat women aged 21 to 50 and '
              'men aged 21 to 55. Your clinic will confirm what applies to '
              'you.'),
          _en('Some women ask about freezing their own eggs at this age. After '
              '40, a freezing cycle usually collects only a few eggs, so '
              'doctors rarely suggest it as a way to wait. Ask what makes '
              'sense for you.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does a sensible plan look like?'),
        bullets: [
          _en('Book a fertility check in your first month of trying.'),
          _en('Ask for his semen analysis at the same visit, so nothing '
              'waits.'),
          _en('Agree with your doctor how long to try naturally, such as three '
              'to six months, before the next step.'),
          _en('Ask early whether IVF, and later donor eggs, are options for '
              "you, so you're not deciding in a rush later."),
          _en('Keep all your reports in one place, so a second opinion is '
              'quick.'),
        ],
        paragraphs: [
          _en("A plan like this isn't about rushing into treatment. It makes "
              "sure every month you spend trying naturally is a month you've "
              'chosen, with the facts in front of you.'),
        ],
      ),
      PvReadSection(
        heading: _en('How can you get your body ready?'),
        paragraphs: [
          _en('Pregnancy after 40 carries higher risks of high blood '
              'pressure, gestational diabetes and needing a caesarean. Many '
              'women over 40 still have healthy pregnancies, and good care '
              'before and during pregnancy catches problems early.'),
        ],
        bullets: [
          _en('Start folic acid, 400 micrograms a day, now.'),
          _en('Get your blood pressure, blood sugar and thyroid checked, and '
              'treat anything that turns up before you conceive.'),
          _en('Aim for a healthy weight, since it lowers pregnancy risks.'),
          _en('Go over any regular medicines with your doctor, to check they '
              'are safe in pregnancy.'),
          _en('Both of you stop smoking and drinking alcohol.'),
        ],
      ),
      PvReadSection(
        heading: _en("It's okay to feel what you feel"),
        paragraphs: [
          _en('Trying at this age can bring pressure from every side, '
              'including from yourself. Hearing "you left it late" hurts, and '
              "it isn't fair. Most reasons women try later, like health, work "
              "or meeting the right partner, weren't choices about fertility "
              'at all.'),
          _en('A counsellor who knows fertility can help you think through '
              'big decisions, like donor eggs, which can bring up strong '
              'feelings for both of you. Asking for that support is part of '
              'good care, not a sign that you are not coping.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I get pregnant naturally at 42 or 43?'),
        answer: _en("Some women do, and it isn't rare. But it becomes less "
            'common each year through the forties, and early losses are more '
            'common. That is why doctors advise a check straight away, so you '
            'can decide your next step with real information.'),
      ),
      PvReadFaq(
        question: _en('Is my AMH result the final word?'),
        answer: _en('No. A low AMH means fewer eggs are left, which matters '
            "for how you respond to IVF medicines. It doesn't measure egg "
            'quality, and some women with low AMH still conceive. Use it to '
            'plan with your doctor, not as a verdict.'),
      ),
      PvReadFaq(
        question: _en('Will people know the baby came from a donor egg?'),
        answer: _en('Only if you choose to tell them. Donors in India are '
            'anonymous under the ART Act 2021, and the law treats the baby as '
            'fully yours. Many couples find it helps to talk it through with a '
            'counsellor first.'),
      ),
      PvReadFaq(
        question: _en('Is there an upper age limit for IVF in India?'),
        answer: _en('Yes. The ART (Regulation) Act 2021 lets clinics treat '
            'women from 21 up to 50 years of age, and men from 21 to 55. Your '
            'clinic will confirm what applies to you.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('See a fertility specialist now'),
      body: _en("If you're 40 or older and want to get pregnant, book a "
          "fertility check as soon as you start trying. Don't wait six "
          'months. Go sooner still if your periods have become irregular or '
          "stopped. If you've had a positive test, go to a hospital the same "
          'day for heavy bleeding, severe pain on one side of your tummy, '
          'pain in the tip of your shoulder, or fainting.'),
    ),
    evidence: _en('ASRM, "Definitions of infertility and recurrent pregnancy '
        'loss" (2023), and ACOG Committee Opinion 589, "Female Age-Related '
        'Fertility Decline". NICE guideline CG156 on age and fertility '
        'treatment. Age limits and donor rules follow the Assisted '
        'Reproductive Technology (Regulation) Act, 2021. Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Speak to a fertility specialist'),
        value: _en('At 40 or over, the first visit is worth booking now.'),
        surfaceId: 'ttc_fertility_help',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, one by one'),
        value: _en('What a first check looks at, with price ranges.'),
        surfaceId: 'ttc_tests',
      ),
    ],
    readNext: [
      'ttc_read_donor_eggs_sperm',
      'ttc_read_egg_freezing',
      'ttc_read_ivf_explained',
    ],
  ),

  // ===========================================================================
  //  How long does it take
  // ===========================================================================
  PvRead(
    id: 'ttc_read_how_long_it_takes',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('How long does getting pregnant usually take?'),
    teaser: _en("What's normal, what can slow it down, and when it's time to "
        'ask for help.'),
    shortAnswer: _en('For most couples it takes several months. When the '
        'woman is under 40, over 80 in 100 couples having regular sex get '
        'pregnant within a year, and about half of the rest do in the second '
        "year. Not being pregnant after a few months is normal and doesn't "
        'mean something is wrong.'),
    scaleSetter: _en('Month after month of negative tests can feel like '
        "failing. It isn't. Even for young, healthy couples, most single "
        'months end without a pregnancy. Taking several months is the usual '
        'story, not the exception.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Most people expect it to happen fast, because for years the '
              'worry was how not to get pregnant. So when it takes months, '
              "it's easy to think something must be wrong."),
          _en("Usually nothing is. It's how the numbers work, and knowing "
              'them can take some of the weight off each month. It also tells '
              "you when it's time to ask for help, which is at the end of this "
              'read.'),
        ],
      ),
      PvReadSection(
        heading: _en("What's normal?"),
        paragraphs: [
          _en("In any single month, most couples don't get pregnant, even "
              'when everything is healthy and the timing is right. Many '
              'things have to line up, and some months they just '
              "don't."),
          _en('Over time, it adds up. NICE, the UK guideline body, says that '
              'over 80 in 100 couples get pregnant within a year when the '
              'woman is under 40 and they have regular sex. Of those who '
              "don't, about half do in the second year."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("If you're three months in"),
          body: _en('Three or four months without a positive test is very '
              "common. It's not a sign that anything is wrong. Most couples "
              'who are not pregnant after a few months are still well within '
              'the normal range.'),
        ),
      ),
      PvReadSection(
        heading: _en('Does age change how long it takes?'),
        paragraphs: [
          _en("Yes, a little. These are the figures NICE's fertility "
              'guideline uses for women having regular sex, counting '
              'pregnancies within one and two years:'),
        ],
        bullets: [
          _en('Aged 19 to 26: about 92 in 100 within a year, and 98 in 100 '
              'within two years.'),
          _en('Aged 27 to 34: about 86 in 100 within a year, and 95 in 100 '
              'within two years.'),
          _en('Aged 35 to 39: about 82 in 100 within a year, and 90 in 100 '
              'within two years.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en("These are averages across many women. They can't tell you "
              'what will happen for you, but they show that most women in '
              'every age group do get pregnant. After 40 it tends to take '
              'longer, which is why doctors suggest a check straight away.'),
        ],
      ),
      PvReadSection(
        heading: _en("Why doesn't it happen every month?"),
        paragraphs: [
          _en('Even in a well-timed month, several steps have to go right. An '
              'egg must be released, sperm must reach it in time, it must be '
              'fertilised, and the embryo must grow and settle into the '
              'lining.'),
          _en('Many embryos carry a chromosome error by accident and stop '
              'growing very early, often before a period is even late. This '
              'happens at every age, and it is the most common reason a '
              "well-timed month doesn't work. It isn't something either of "
              'you did.'),
        ],
      ),
      PvReadSection(
        heading: _en('What can make it take longer?'),
        paragraphs: [
          _en("Often it's just time. But a few everyday things can slow it "
              'down, and some of them are easy to change.'),
        ],
        bullets: [
          _en('Timing. Sex that misses the fertile days, or only happens now '
              'and then, can add months.'),
          _en("Irregular cycles. Long or unpredictable cycles may mean you're "
              'not releasing an egg every month, which is common with PCOS '
              'and thyroid problems.'),
          _en('Weight. Being very underweight or quite overweight can upset '
              'ovulation. For him, extra weight can lower sperm quality.'),
          _en('Age. After 35 it tends to take longer, for both of you, though '
              'more so for women.'),
          _en("His health. In around half of couples who struggle, a sperm "
              'problem is part of the reason. Heat, smoking, alcohol and some '
              'medicines can all affect sperm.'),
          _en('Smoking and alcohol. Smoking harms eggs and sperm, and heavy '
              'drinking lowers fertility in both of you.'),
          _en("Stress. Everyday stress hasn't been shown to stop you getting "
              'pregnant. Very high stress that goes on for a long time can '
              'upset cycles.'),
        ],
      ),
      PvReadSection(
        heading: _en('What helps, without turning it into a project?'),
        paragraphs: [
          _en('Have sex every two to three days all month. You '
              "don't need to track to the hour. If you'd like to aim, the "
              'three days before ovulation and the day itself are the best '
              'days.'),
          _en('Keep taking folic acid, eat well, and stay active in a way you '
              'enjoy. Tracking helps if your cycles are irregular or you want '
              "notes for a doctor, but it isn't a must."),
        ],
      ),
      PvReadSection(
        heading: _en('When is it time to see a doctor?'),
        paragraphs: [
          _en('Under 35, see a doctor after 12 months of regular sex without a '
              'pregnancy. From 35 to 39, after 6 months. At 40 or over, go '
              'now.'),
          _en('Go sooner, whatever your age, if your periods are irregular or '
              "absent, if you've had pelvic infection, endometriosis or "
              'surgery on your tubes, or if he has had surgery or problems '
              'with his testicles.'),
          _en("Being past the year mark doesn't mean it won't happen. About "
              "half of couples who aren't pregnant after one year are pregnant "
              "by the end of the second. But it's the right time for tests, "
              'because finding a problem early gives you more options.'),
          _en('The tests are usually simple: blood tests, a scan, a tube test '
              'and a semen analysis. Many things they find, like not '
              'ovulating or a thyroid problem, are easy to treat.'),
        ],
        tip: PvReadTip(
          title: _en('What to note before the visit'),
          body: _en('Write down the dates your last three to six periods '
              'started, how long they lasted and how heavy they were. Note any '
              'pain, spotting between periods, or discharge that has changed. '
              'List the medicines and supplements you both take, any past '
              'pregnancies or losses, and any surgery. Jot your questions down '
              'too.'),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en("We've been trying for three months. Should we worry?"),
        answer: _en('No. Three months is well within normal. Most couples who '
            'are not pregnant at three months get there later on their own. '
            'Keep having sex every two to three days, and see a doctor at the '
            'usual time for your age.'),
      ),
      PvReadFaq(
        question: _en('Does having sex every day help?'),
        answer: _en("Having sex every day doesn't harm sperm, so it's fine if "
            'you both want to. But every two to three days works about as '
            'well. Keeping it enjoyable helps you keep going for as long as '
            'it takes.'),
      ),
      PvReadFaq(
        question: _en('I got pregnant fast the first time. Why is it slow '
            'now?'),
        answer: _en("Each time is different. You're older now, your body has "
            'changed, and life may be busier. It is common and it doesn\'t '
            "mean something is wrong, but if it's been six to twelve months, "
            'see a doctor.'),
      ),
      PvReadFaq(
        question: _en('Do we both need to be checked?'),
        answer: _en('Yes. A sperm problem is part of the picture for many '
            'couples who take longer, and a semen analysis is easy to do. '
            'Testing you both from the start avoids months of tests on one '
            'person while the other waits.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Time to see a doctor'),
      body: _en("See a gynaecologist after 12 months of trying if you're "
          "under 35, after 6 months if you're 35 to 39, and straight away if "
          "you're 40 or older. Go sooner if your periods are irregular or "
          "have stopped, if sex is painful, if you've had pelvic infection or "
          'surgery, or if your partner has a known problem. Get urgent care '
          'the same day for severe tummy pain, heavy bleeding or fainting.'),
    ),
    evidence: _en('NICE guideline CG156, "Fertility problems: assessment and '
        'treatment", for how long conception takes by age and how often to '
        'have sex. ASRM, "Definitions of infertility and recurrent pregnancy '
        'loss" (2023), for when to seek help. WHO, "Infertility" fact sheet. '
        'Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("See this cycle's window"),
        value: _en('Your own dates, turned into the days that count.'),
        surfaceId: 'ttc_window',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See when to get help'),
        value: _en('The right time for your age, and what to bring.'),
        surfaceId: 'ttc_fertility_help',
      ),
    ],
    readNext: [
      'ttc_read_timing_myths',
      'ttc_read_when_to_seek_help',
      'ttc_read_age_after_35',
    ],
  ),

  // ===========================================================================
  //  A second baby (secondary infertility)
  // ===========================================================================
  PvRead(
    id: 'ttc_read_second_baby',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Why is it harder to get pregnant the second time?'),
    teaser: _en('Secondary infertility: why it happens, what doctors check, '
        'and when to go.'),
    shortAnswer: _en("Having trouble getting pregnant after you've had a "
        'baby is called secondary infertility, and it is more common than '
        'people think. Age, changes since the last pregnancy, or a problem on '
        'either side can all play a part. The timing rule is the same: see a '
        "doctor after 12 months of trying, or 6 if you're 35 or older."),
    scaleSetter: _en('This catches many parents by surprise, because the '
        'first time seemed to prove everything worked. It did work, and that '
        'still counts. Most couples with secondary infertility can be helped, '
        'and the checks are the same ones used for anyone.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('People may tell you to be grateful for the child you have. You '
              'are, and you can still want another. Both are true, and '
              "wanting a second baby doesn't need defending."),
          _en("It's also easy to feel alone with this, because it's rarely "
              'talked about. Many couples who come to fertility clinics '
              'already have a child.'),
          _en('Secondary infertility has the same meaning as any infertility: '
              "no pregnancy after a year of trying, or six months if you're 35 "
              "or older. The only difference is that you've been pregnant "
              'before.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why can it take longer this time?'),
        paragraphs: [
          _en('Often more than one thing has changed since your last '
              "pregnancy. None of these mean something went wrong the first "
              'time. Each of them can be checked, and many can be treated.'),
        ],
        bullets: [
          _en("Age. You're both older, and even a few years can make a "
              'difference after 35.'),
          _en('Weight and health. Weight gain after pregnancy, thyroid '
              'problems, diabetes or PCOS can affect ovulation.'),
          _en('The last birth. Rarely, an infection after birth, a D and C, '
              'or problems with the placenta can leave scarring inside the '
              'womb or in the tubes.'),
          _en('A caesarean scar. Sometimes a small pocket forms in the scar, '
              'called a niche. It can cause spotting and may affect fertility '
              'for a few women.'),
          _en('His side. Sperm can change with age, weight, heat, smoking, '
              'new medicines or illness since last time.'),
          _en('Life with a small child. Tiredness and less time alone often '
              'mean less sex, which on its own can add months.'),
        ],
      ),
      PvReadSection(
        heading: _en('When does fertility come back after a birth?'),
        paragraphs: [
          _en('Ovulation can return as early as three weeks after giving '
              "birth, especially if you're not breastfeeding. You can release "
              'an egg before your first period comes back, so there may be no '
              'warning.'),
          _en('Breastfeeding, especially at night, can hold back ovulation '
              'for months. Once your periods are back and regular, many women '
              'conceive while still breastfeeding. Ask your doctor if you are '
              'unsure.'),
          _en('WHO suggests waiting at least two years after a birth before '
              'getting pregnant again. It gives your body time to recover and '
              'lowers some risks for the next baby. After a caesarean, ask '
              'your doctor what gap they advise for you.'),
          _en("If your periods haven't settled into a pattern yet, noting "
              'them for a few months before you start trying helps you and '
              "your doctor see what's happening."),
        ],
      ),
      PvReadSection(
        heading: _en('What do the checks look like?'),
        paragraphs: [
          _en("The tests are the same as for any couple. Take your records "
              'from the last pregnancy and birth, especially if you had a '
              'caesarean, a D and C or an infection. They save time.'),
        ],
        bullets: [
          _en("A check that you're ovulating, with a scan or a blood test."),
          _en('An AMH test and a scan to see roughly how many eggs are left.'),
          _en('A look at your tubes and the inside of your womb, such as an '
              'HSG or a hysteroscopy.'),
          _en('Thyroid, prolactin and blood sugar.'),
          _en("A semen analysis for your partner, even though he's fathered "
              'a child before.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('His test matters too'),
          body: _en("Having had a child before doesn't mean his sperm is the "
              'same now. A semen analysis is quick, cheap and painless. Doing '
              'it early can save months of tests on you alone.'),
        ),
      ),
      PvReadSection(
        heading: _en('When should you see a doctor?'),
        paragraphs: [
          _en("Use the same timing as anyone else: after 12 months of trying "
              "if you're under 35, after 6 months if you're 35 to 39, and "
              'straight away at 40 or over.'),
          _en('Go sooner if your periods have changed since the birth, become '
              "very heavy or painful, or haven't come back three months after "
              'you stop breastfeeding. Spotting for days after each period, '
              'if it started after a caesarean, is worth mentioning too.'),
        ],
      ),
      PvReadSection(
        heading: _en('What might treatment look like?'),
        paragraphs: [
          _en('Treatment depends on what the tests find, as it would the '
              "first time. If you're not ovulating, tablets like letrozole may "
              "be enough. If there's scarring inside the womb, a hysteroscopy "
              'can often remove it.'),
          _en("If the tubes are blocked or his sperm has changed, IUI or IVF "
              'may be suggested. Many couples need only a small step, and '
              "having a child before doesn't limit your options."),
        ],
      ),
      PvReadSection(
        heading: _en('How do you look after yourself while you wait?'),
        paragraphs: [
          _en('Trying again while caring for a small child is tiring. It can '
              'bring guilt too, about wanting more, or about how much of you '
              'goes into trying. Both are normal.'),
          _en('If friends say "at least you have one", they usually mean '
              "well. You can tell them it's hard for you anyway. And your "
              "child doesn't need every detail. A short, honest line is "
              'enough if they ask.'),
          _en("Your partner may feel it differently, and that's okay. Some "
              'couples find it helps to agree a time limit before seeing a '
              "doctor, so there's a plan and less to argue about."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it common to struggle the second time?'),
        answer: _en('Yes. Many couples who see fertility doctors already have '
            'a child. WHO estimates about 1 in 6 people face infertility at '
            'some point in their lives, and that includes people trying for a '
            'second baby.'),
      ),
      PvReadFaq(
        question: _en('Could my caesarean be the reason?'),
        answer: _en('It can be for a few women, but most women who have had a '
            'caesarean get pregnant again without trouble. If you have '
            'spotting for days after your period ends, tell your doctor. A '
            'scan can look at the scar.'),
      ),
      PvReadFaq(
        question: _en('Should we wait until our first child is older?'),
        answer: _en("There's no perfect age gap. WHO's advice to wait at least "
            "two years after a birth is about your health and the next baby's. "
            'Beyond that, the right time is when it feels right for your '
            'family, keeping in mind that fertility slowly changes with age.'),
      ),
      PvReadFaq(
        question: _en("I'm still breastfeeding. Do I need to stop?"),
        answer: _en('Not always. If your periods are back and regular, many '
            "women conceive while breastfeeding. If your periods haven't "
            "returned and you'd like to try, talk to your doctor about your "
            'options.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See a gynaecologist after 12 months of trying if you're "
          "under 35, after 6 months if you're 35 to 39, and straight away if "
          "you're 40 or over. Go sooner if your periods haven't returned "
          'three months after you stop breastfeeding, if they have become '
          'very heavy or painful, or if you had an infection or surgery after '
          'your last birth. Get care the same day for fever with pelvic pain, '
          'heavy bleeding or fainting.'),
    ),
    evidence: _en('WHO, "Infertility" fact sheet and the report of the WHO '
        'technical consultation on birth spacing. NICE guideline CG156 and '
        'ASRM, "Definitions of infertility and recurrent pregnancy loss" '
        '(2023), for when to seek help. NHS guidance on getting pregnant '
        'after giving birth. StatPearls (NCBI) on caesarean scar niche and on '
        'Asherman syndrome. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See when to get help'),
        value: _en('The right time for your age, and what to take along.'),
        surfaceId: 'ttc_fertility_help',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your reports together'),
        value: _en('Last pregnancy, last birth, and every test since.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: [
      'ttc_read_how_long_it_takes',
      'ttc_read_ivf_workup',
    ],
  ),

  // ===========================================================================
  //  Egg freezing in India
  // ===========================================================================
  //  ⚠️ COSTS ARE CLINIC-PUBLISHED RANGES, DATED, and the read says so. The
  //  storage limit under the ART Act is deliberately not stated as a number:
  //  the read sends her to her consent form and clinic instead.
  PvRead(
    id: 'ttc_read_egg_freezing',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Egg freezing in India: is it right for me?'),
    teaser: _en('What happens, what it costs, what the law says, and what it '
        "can and can't promise."),
    shortAnswer: _en('Egg freezing means collecting eggs after about two '
        'weeks of hormone injections and freezing them to use later. It works '
        'best when done younger, ideally before 35. It gives you an option for '
        'later, not a promise of a baby.'),
    scaleSetter: _en('Egg freezing is a real choice, and more women in India '
        "are making it. It's also expensive, and it can't promise a baby "
        'later. The best decisions come from knowing both sides, without '
        'pressure from a clinic or from anyone else.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("You might be thinking about it because you'd like to wait, "
              "because you haven't met the right partner, or because a medical "
              'treatment could affect your fertility. All of these are good '
              'reasons to ask the question.'),
        ],
      ),
      PvReadSection(
        heading: _en('What happens, step by step?'),
        paragraphs: [
          _en('The process is the same as the first half of an IVF cycle. It '
              'usually takes two to three weeks from the first test to the '
              'day the eggs are frozen.'),
        ],
        bullets: [
          _en('First, tests: an AMH blood test and a scan to count small '
              'follicles, to judge how your ovaries may respond.'),
          _en('Then about 8 to 14 days of hormone injections, usually given '
              'at home, to help several eggs grow at once.'),
          _en('Scans and blood tests every few days, to see how the '
              'follicles are growing.'),
          _en('A trigger injection to ripen the eggs, given at an exact time.'),
          _en('Egg collection about 36 hours later: a short procedure under '
              'sedation, using a fine needle passed through the vagina.'),
          _en('The eggs are frozen very fast, a method called vitrification, '
              'and stored in liquid nitrogen.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('Most women are back to normal life the next day. Your period '
              'usually comes about a week or two after collection.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does it work?'),
        paragraphs: [
          _en('With modern freezing, most eggs survive thawing, and ASRM '
              'stopped calling egg freezing experimental in 2012. But not '
              'every egg becomes an embryo, and not every embryo becomes a '
              'pregnancy.'),
          _en('The age at which you freeze matters most. Eggs frozen in your '
              'early thirties do better than eggs frozen at 38 or 40, because '
              'fewer carry chromosome errors. Doctors often suggest freezing '
              'more eggs the older you are, which can mean more than one '
              'cycle.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("What it can't promise"),
          body: _en('Frozen eggs are an option, not a guarantee. Some women '
              'who freeze never need to use them. Others use them and do not '
              'get pregnant. Any clinic that promises a baby from egg freezing '
              "isn't being straight with you."),
        ),
      ),
      PvReadSection(
        heading: _en('What does it cost in India?'),
        paragraphs: [
          _en('Prices vary a lot by city and clinic. As a rough guide, one '
              'cycle including medicines often costs ₹1.2 lakh to ₹2.5 lakh. '
              'Medicines are a big part of this and depend on the dose you '
              'need.'),
          _en('Storage is charged separately, often ₹15,000 to ₹35,000 a year. '
              'Using the eggs later means an IVF cycle with ICSI, which is '
              'another cost at that time.'),
          _en("These ranges come mostly from clinics' own published prices, "
              'so use them to check a quote, not as a fixed figure. Ask for a '
              'written quote that lists medicines, storage, and what happens '
              'if the cycle is stopped.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does the law in India say?'),
        paragraphs: [
          _en('Egg freezing is covered by the Assisted Reproductive '
              'Technology (Regulation) Act, 2021, the ART Act. Only clinics '
              'and banks registered under the Act can collect and store '
              'eggs.'),
          _en('The Act lets clinics offer ART services to women aged 21 to '
              '50. Your eggs are yours. They cannot be used for anyone else, '
              'or for research, without your written consent.'),
          _en('How long eggs can be stored, and what happens to any you do '
              'not use, is set out in your consent form. Your clinic will '
              'confirm what applies to you.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is it right for me?'),
        paragraphs: [
          _en("It may make sense if you're in your late twenties or early "
              'thirties, want children later, and can afford it. It is also '
              'offered before cancer treatment that could harm the ovaries. '
              'Then it is urgent, and your cancer doctor and a fertility '
              'doctor should talk quickly.'),
          _en("It may make less sense if you're around 40 or older, or your "
              'AMH is very low, because fewer eggs will be collected and more '
              'may carry errors. Some women with a partner choose to freeze '
              'embryos instead. Your doctor can explain the difference.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about freezing embryos instead?'),
        paragraphs: [
          _en('If you have a partner, you can freeze embryos instead of eggs. '
              'The eggs are fertilised first, and the embryos are frozen. '
              'Embryos survive freezing well, and you learn more about how '
              'your eggs fertilise.'),
          _en('The catch is that embryos belong to both of you, and using them '
              'later needs the consent you both gave. If the relationship '
              'changes, this can get complicated, so talk it through before '
              'you choose.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('Six questions that help you compare clinics and '
            'quotes.'),
        heading: _en('What should you ask a clinic?'),
        bullets: [
          _en('How many eggs do you expect to collect for someone my age with '
              'my AMH?'),
          _en("What does the price include, and what's extra?"),
          _en('How much is storage each year, and for how long can eggs be '
              'kept?'),
          _en('How many women my age have used their frozen eggs here, and '
              'what happened?'),
          _en('Is the clinic registered under the ART Act 2021?'),
          _en('What happens to my eggs if I move city, or the clinic closes?'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does egg freezing use up my eggs or bring menopause '
            'earlier?'),
        answer: _en('No. Each month your body starts growing a group of eggs, '
            'and usually only one is released. The injections rescue some '
            'from that same group, which would have been lost anyway. It '
            "doesn't use up eggs meant for later months."),
      ),
      PvReadFaq(
        question: _en('Is it painful?'),
        answer: _en('The injections sting a little, and your tummy may feel '
            'full and bloated near the end. The collection is done under '
            "sedation, so most women don't feel it. Some cramps for a day or "
            'two afterwards are common.'),
      ),
      PvReadFaq(
        question: _en("Can I freeze my eggs if I'm not married?"),
        answer: _en('Yes. The ART Act 2021 covers women aged 21 to 50 and '
            "doesn't require you to be married to freeze your own eggs. Your "
            'clinic will confirm what applies to you.'),
      ),
      PvReadFaq(
        question: _en('What age is best?'),
        answer: _en('Results are best when eggs are frozen younger, generally '
            "before 35. It isn't too late after 35, but you may need more "
            'cycles to freeze enough eggs, and fewer eggs frozen later lead to '
            'a baby.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to call the clinic'),
      body: _en('During a freezing cycle, call your clinic the same day if '
          "your tummy becomes very swollen or painful, you feel breathless, "
          "you're vomiting, or you're passing much less urine. These can be "
          'signs of OHSS. After egg collection, go to hospital straight away '
          "for heavy bleeding, fever, or severe pain that painkillers don't "
          'ease.'),
    ),
    evidence: _en('ASRM, "Mature oocyte cryopreservation: a guideline" '
        '(2013), and the ASRM Ethics Committee opinion on planned oocyte '
        'cryopreservation (2018). ESHRE guideline, "Female fertility '
        'preservation" (2020). The Assisted Reproductive Technology '
        '(Regulation) Act, 2021. Cost ranges are from Indian clinics\' '
        'published prices in 2026 and vary widely. Sources checked September '
        '2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, one by one'),
        value: _en('AMH and the follicle scan, with price ranges.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Speak to a fertility specialist'),
        value: _en('Talk it through before you pay for anything.'),
        surfaceId: 'ttc_fertility_help',
      ),
    ],
    readNext: [
      'ttc_read_ivf_injections',
      'ttc_read_ivf_retrieval',
      'ttc_read_age_after_35',
    ],
  ),

  // ===========================================================================
  //  Donor eggs and donor sperm in India
  // ===========================================================================
  //  ⚠️ FACTS OF THE ART (REGULATION) ACT 2021 AS THEY STAND. Not legal advice.
  //  Deliberately NOT stated: whether a known or related donor is allowed (the
  //  read says donors come through a bank and stay anonymous, which is the
  //  Act's shape, without ruling on relatives).
  PvRead(
    id: 'ttc_read_donor_eggs_sperm',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Donor eggs and donor sperm in India: what the law says'),
    teaser: _en('Who can use them, where they come from, and what the ART Act '
        '2021 says.'),
    shortAnswer: _en('Donor eggs and donor sperm are legal in India under '
        'the Assisted Reproductive Technology (Regulation) Act, 2021. They '
        'must come through a registered ART bank, the donor stays anonymous, '
        'and the baby is legally yours. Your clinic will confirm what applies '
        'to you.'),
    scaleSetter: _en('Being told a donor may be your best route can be a lot '
        "to take in. You don't need to decide quickly. Many families in India "
        'have children this way, and the law is clear that the child is yours '
        'in every sense.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Doctors may suggest donor eggs when your own eggs are unlikely '
              'to work: after several failed IVF cycles, with very few eggs '
              "left, after early menopause, or when there's a genetic "
              "condition you don't want to pass on."),
          _en('Donor sperm may be suggested when no sperm can be found, even '
              'with surgery, or for a single woman who wants a baby.'),
          _en("If this has come up for you, it's normal to need time. Some "
              "couples decide in weeks and others take a year. There's no "
              'right speed.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does the ART Act say about donors?'),
        paragraphs: [
          _en('The Assisted Reproductive Technology (Regulation) Act, 2021 '
              'sets the rules. These are the main ones, as they stand:'),
        ],
        bullets: [
          _en('Only an ART bank registered under the Act can find, screen and '
              'supply donors. Clinics get donor eggs and sperm through such a '
              'bank.'),
          _en('A sperm donor must be a man aged 21 to 55.'),
          _en('An egg donor must be a woman aged 23 to 35 who has been married '
              'and has at least one child of her own, aged three or older.'),
          _en('An egg donor can donate only once in her life, and no more '
              'than seven eggs can be taken from her.'),
          _en("One donor's eggs or sperm can be given to only one couple or "
              'woman.'),
          _en('Buying or selling eggs, sperm or embryos is an offence.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('Rules like these can be updated, and clinics may read them '
              'slightly differently. Your clinic will confirm what applies to '
              'you.'),
        ],
      ),
      PvReadSection(
        heading: _en('Will we know who the donor is?'),
        paragraphs: [
          _en('No. The bank keeps the donor\'s identity confidential, and the '
              "donor doesn't learn who you are. You may be told basic details "
              'such as age, height, blood group and health screening results.'),
          _en('Donors are screened for infections like HIV and hepatitis, and '
              'for some genetic conditions, before their eggs or sperm are '
              'used.'),
          _en('You can ask the clinic which details it can share, and how the '
              'donor was screened. A good clinic will answer clearly and in '
              'writing.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is the baby legally ours?'),
        paragraphs: [
          _en('Yes. The Act says a child born through ART is the biological '
              'child of the couple or woman who had the treatment, with all '
              'the rights of a child born naturally.'),
          _en('The donor gives up all parental rights over the child. They '
              'have no legal link to the baby and no say in the child\'s life.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who can use donor eggs or sperm?'),
        paragraphs: [
          _en('Under the Act, ART services are open to a married couple where '
              'the woman is 21 to 50 and the man is 21 to 55, and to a woman '
              'aged 21 to 50 on her own. As it stands, the Act does not cover '
              'single men or unmarried couples.'),
          _en('The Act also asks the couple or woman receiving donor eggs to '
              'arrange insurance cover for the egg donor. Your clinic will '
              'explain this, and confirm what applies to you.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is treatment like?'),
        paragraphs: [
          _en('With donor eggs, the donor has the injections and the egg '
              "collection. The eggs are fertilised with your partner's sperm, "
              'or donor sperm, and an embryo is placed in your womb. You carry '
              'the pregnancy and give birth.'),
          _en('Your lining is prepared with tablets or patches so it is ready '
              'for the embryo. Many clinics now freeze the embryos first and '
              'transfer one in a later cycle.'),
          _en('With donor sperm, treatment is usually IUI or IVF, depending '
              'on your own tests. Donor egg treatment usually costs more than '
              "IVF with your own eggs, because the donor's care, screening and "
              'insurance are included. Ask for a written quote.'),
          _en('Tests before treatment usually include a look at your womb, '
              'blood tests, and a semen analysis for your partner.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('Six questions to ask the clinic before you sign '
            'anything.'),
        heading: _en('What should you ask before you start?'),
        bullets: [
          _en('Which registered ART bank does the clinic use, and can we see '
              'its registration?'),
          _en('What details about the donor will we be told?'),
          _en('What screening has the donor had?'),
          _en("What does the quote include: the donor's care, insurance, "
              'medicines, freezing?'),
          _en("What happens to any embryos we don't use?"),
          _en('Is counselling included, before and after treatment?'),
        ],
      ),
      PvReadSection(
        heading: _en('How do you handle the feelings, and telling your child?'),
        paragraphs: [
          _en('Using a donor can bring up grief for the genetic link you hoped '
              "for, even when you're sure it's the right choice. That's "
              'normal, and it often softens with time. A fertility counsellor '
              'can help you both talk it through before you start.'),
          _en('Whether and how to tell your child is your decision. Many '
              'counsellors suggest simple, honest words from an early age, so '
              "it's never a shock later. You don't have to tell other family "
              'members at all.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Will the baby look like us?'),
        answer: _en('If only one donor is used, the baby gets half their genes '
            'from the partner who is not using a donor. Banks usually share '
            'basic features like height and skin tone. And every child is '
            'their own mix, including children born without a donor.'),
      ),
      PvReadFaq(
        question: _en('Is using a donor egg the same as surrogacy?'),
        answer: _en('No. With donor eggs, you carry and give birth to the baby '
            'yourself. Surrogacy is when another woman carries the pregnancy, '
            'and it comes under a separate law, the Surrogacy (Regulation) '
            'Act, 2021.'),
      ),
      PvReadFaq(
        question: _en("Can we choose the baby's sex, or pick a donor for "
            'looks?'),
        answer: _en("Choosing a baby's sex is illegal in India, under the ART "
            'Act 2021 and the PC-PNDT Act 1994. Banks share basic details '
            'about donors, but the law is built around anonymity, not '
            'choosing a donor to order.'),
      ),
      PvReadFaq(
        question: _en('Will I bond with a baby from a donor egg?'),
        answer: _en('Parents who have children through egg donation describe '
            'the same love as any parent. Carrying the pregnancy, and all the '
            "caring that follows, is what makes you the mother. It's okay if "
            'the feeling takes a little time.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to call your clinic'),
      body: _en('After a donor egg transfer, call your clinic the same day for '
          'heavy bleeding or severe tummy pain. After a positive test, go to '
          'hospital the same day for severe pain on one side, pain in the tip '
          'of your shoulder, heavy bleeding or fainting, as these can be signs '
          'of an ectopic pregnancy. For legal questions, speak to your '
          "clinic's counsellor before you sign any consent form."),
    ),
    evidence: _en('The Assisted Reproductive Technology (Regulation) Act, 2021 '
        '(the sections on ART banks, donors, eligibility and the rights of '
        'the child) and the ART (Regulation) Rules, 2022. The Pre-Conception '
        'and Pre-Natal Diagnostic Techniques (PC-PNDT) Act, 1994. ASRM and '
        'ESHRE guidance on donor treatment. This is a summary of the law, not '
        'legal advice. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Speak to a fertility specialist'),
        value: _en('Ask what the Act means for your own situation.'),
        surfaceId: 'ttc_fertility_help',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Track a cycle you're already in"),
        value: _en('Medicines, scans and the transfer date in one place.'),
        surfaceId: 'ttc_treatment',
      ),
    ],
    readNext: [
      'ttc_read_age_after_40',
      'ttc_read_surrogacy_india',
      'ttc_read_ivf_explained',
    ],
  ),

  // ===========================================================================
  //  Surrogacy in India
  // ===========================================================================
  //  ⚠️ THE DONOR-GAMETE RULE CHANGED TWICE (a 2023 amendment barred donor
  //  gametes; a 2024 amendment allowed one donor gamete on a District Medical
  //  Board's certificate). The read says so and sends her to the clinic.
  PvRead(
    id: 'ttc_read_surrogacy_india',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en("Surrogacy in India: who it's for and what the law says"),
    teaser: _en('The Surrogacy (Regulation) Act 2021 in plain words: who can '
        'use it and how it works.'),
    shortAnswer: _en("Surrogacy is legal in India only when it's altruistic, "
        "which means the surrogate isn't paid beyond her medical costs and "
        "insurance. It's for married Indian couples, and some widowed or "
        "divorced women, who have a medical reason they can't carry a "
        'pregnancy. Your clinic will confirm what applies to you.'),
    scaleSetter: _en('Most people trying for a baby will never need '
        "surrogacy. If a doctor has raised it, it's usually because carrying a "
        "pregnancy isn't possible or safe for you. The law is strict, but it "
        'gives a clear route for those who need it.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Surrogacy is when another woman carries a pregnancy for you '
              'and gives the baby to you after birth. In India, the embryo is '
              'made in a lab through IVF, and the surrogate has no genetic '
              'link to the baby.'),
          _en('It comes under the Surrogacy (Regulation) Act, 2021, and the '
              'Surrogacy (Regulation) Rules, 2022. Surrogacy clinics must be '
              'registered, and the process runs through authorities set up in '
              'each state. This is what the law says, as it stands.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does "altruistic only" mean?'),
        paragraphs: [
          _en('Commercial surrogacy, where a surrogate is paid a fee, is '
              'banned in India. Only altruistic surrogacy is allowed.'),
          _en('The surrogate can receive her medical expenses and insurance '
              'cover, and nothing more. The couple must buy health insurance '
              'for her covering 36 months. Paying her beyond this is an '
              'offence under the Act.'),
          _en("There's no fee for the surrogate, but surrogacy isn't free. "
              "The couple pays for IVF, the surrogate's medical care through "
              'pregnancy and birth, her insurance, and the legal steps. Ask the '
              'clinic for a written estimate of each part.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who can use surrogacy?'),
        paragraphs: [
          _en('The Act allows these people to become parents through '
              'surrogacy:'),
        ],
        bullets: [
          _en('A married Indian couple, where the woman is 23 to 50 and the '
              'man is 26 to 55.'),
          _en('They must have no living child, whether by birth, adoption or '
              'surrogacy. There is an exception if a child has a serious '
              'illness or disability.'),
          _en('A widowed or divorced Indian woman aged 35 to 45.'),
          _en('In every case there must be a medical reason, certified by a '
              'District Medical Board. Examples include having no womb, an '
              'illness that makes pregnancy dangerous, or repeated failed IVF '
              'or miscarriages.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('As it stands, the Act does not cover unmarried couples, single '
              'men, or women who have never married. Your clinic will confirm '
              'what applies to you.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who can be a surrogate?'),
        bullets: [
          _en('A woman aged 25 to 35 who has been married and has a child of '
              'her own.'),
          _en('She can be a surrogate only once in her life.'),
          _en('She must have a certificate showing she is medically and '
              'psychologically fit.'),
          _en("She can't use her own eggs. The embryo is made from the "
              "couple's eggs and sperm, or with a donor where the rules "
              'allow.'),
          _en('She must give written consent, and she can withdraw it before '
              'the embryo is transferred.'),
        ],
      ),
      PvReadSection(
        heading: _en('Can donor eggs or sperm be used?'),
        paragraphs: [
          _en('This part of the rules has changed more than once. Under a 2024 '
              'amendment to the Surrogacy Rules, a couple may use a donor egg '
              'or donor sperm if the District Medical Board certifies a '
              'medical need, but at least one of the two must come from the '
              'couple.'),
          _en('A widowed or divorced woman must use her own eggs, with donor '
              'sperm. Because this has changed recently, your clinic will '
              'confirm what applies to you.'),
        ],
      ),
      PvReadSection(
        heading: _en('What are the steps?'),
        bullets: [
          _en('A doctor confirms the medical reason, and the District Medical '
              'Board certifies it.'),
          _en('The couple or woman applies to the appropriate authority for a '
              'certificate of essentiality and eligibility.'),
          _en("A court order sets out the baby's parentage and custody before "
              'treatment starts.'),
          _en('Insurance is bought for the surrogate, and consent forms are '
              'signed.'),
          _en('IVF makes the embryo, which is transferred at a surrogacy '
              'clinic registered under the Act.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who are the legal parents?'),
        paragraphs: [
          _en('The Act says a child born through surrogacy is the biological '
              'child of the couple or woman who planned it, with all the '
              'rights of any child. The surrogate has no parental rights.'),
          _en("The couple can't refuse to take the child for any reason, "
              "including illness or disability. Choosing the baby's sex is "
              'banned, and so is any advert offering surrogacy for money.'),
          _en('No one can force the surrogate to end the pregnancy. Any '
              'termination needs her written consent and the approval of the '
              'authority, and must follow the Medical Termination of Pregnancy '
              'Act, 1971.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you think about first?'),
        paragraphs: [
          _en('Surrogacy is a big step, legally and emotionally. Before it, '
              'doctors usually look at whether the problem can be treated, '
              'such as surgery for a womb problem, or a full review after '
              'failed IVF.'),
          _en('For some couples, adoption through CARA, the Central Adoption '
              "Resource Authority, is another path to a family. It's worth "
              "knowing about, even if it isn't your choice."),
          _en('A counsellor can help too. Surrogacy can bring up feelings '
              'about the pregnancy you hoped to carry, and about sharing '
              'something so private with another woman and her family.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does the surrogate have to be a relative?'),
        answer: _en("No. The final 2021 Act doesn't require the surrogate to "
            'be a relative. She must meet the age, marriage and health rules, '
            "and she can't be paid beyond medical costs and insurance. Your "
            'clinic will confirm what applies to you.'),
      ),
      PvReadFaq(
        question: _en('How long does the process take?'),
        answer: _en('Getting the certificates and the court order can take a '
            'few months before treatment starts. Then there is IVF and a full '
            'pregnancy. Ask your clinic how long the paperwork usually takes '
            'in your state.'),
      ),
      PvReadFaq(
        question: _en('Is surrogacy the same as using a donor egg?'),
        answer: _en('No. With a donor egg, you carry the pregnancy yourself. '
            'With surrogacy, another woman carries it. They come under two '
            'different laws: the ART (Regulation) Act 2021 and the Surrogacy '
            '(Regulation) Act 2021.'),
      ),
      PvReadFaq(
        question: _en("We already have a child. Can we still use surrogacy?"),
        answer: _en('Usually not. The Act allows it only for couples with no '
            'living child, unless that child has a serious illness or '
            'disability. Your clinic will confirm what applies to you.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Talk to a specialist first'),
      body: _en('If you have a condition that makes pregnancy risky, such as '
          'serious heart or kidney disease, see your specialist before you '
          'try at all, because a pregnancy could put your health at risk. If '
          "you've had several failed IVF transfers or repeated miscarriages, "
          'ask for a full review with a fertility specialist before your next '
          'attempt, and before thinking about surrogacy.'),
    ),
    evidence: _en('The Surrogacy (Regulation) Act, 2021; the Surrogacy '
        '(Regulation) Rules, 2022, with their amendments of 2023 and 2024. '
        'The Assisted Reproductive Technology (Regulation) Act, 2021. This is '
        'a summary of the law, not legal advice. Sources checked September '
        '2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Speak to a fertility specialist'),
        value: _en('Ask whether the Act applies to your situation.'),
        surfaceId: 'ttc_fertility_help',
      ),
    ],
    readNext: [
      'ttc_read_donor_eggs_sperm',
      'ttc_read_ivf_explained',
    ],
  ),

  // ===========================================================================
  //  A plain glossary of clinic words
  // ===========================================================================
  //  Reference material, so three of seven sections fold. The P3 "lesser-known
  //  treatments" item (tubal surgery, sperm washing, surgical sperm retrieval)
  //  is folded in here as entries.
  PvRead(
    id: 'ttc_read_clinic_glossary',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Words your clinic uses: a plain glossary'),
    teaser: _en('AMH, HSG, ICSI, beta hCG and more, each in a line or two.'),
    shortAnswer: _en('Fertility clinics use a lot of short forms. This '
        'glossary explains the common ones in plain words, grouped by when '
        "you'll hear them. If a word on your report isn't here, ask your "
        'doctor. Explaining it is part of their job.'),
    scaleSetter: _en('Nobody is expected to know these words before they need '
        "them. Doctors use them because they're quick, not because you should "
        'already understand. Asking what something means is always a fair '
        'question.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Keep this open during a visit or when you read a report. Each '
              "word says what it is and, where it helps, what it's for."),
          _en('The words are grouped by when you are likely to hear them: '
              'blood tests, scans, the name for what is going on, treatments, '
              'the IVF cycle, and after a transfer.'),
        ],
      ),
      PvReadSection(
        heading: _en('What do the blood test names mean?'),
        bullets: [
          _en('AMH (anti-Müllerian hormone): shows roughly how many eggs are '
              "left. It doesn't measure egg quality or tell you whether you'll "
              'conceive naturally.'),
          _en('FSH (follicle stimulating hormone): the hormone that makes '
              'follicles grow. Checked on day 2 to 5. A high level can mean '
              'fewer eggs are left.'),
          _en('LH (luteinising hormone): its surge makes an egg release. '
              'Ovulation strips detect it.'),
          _en('E2 (oestradiol): a form of oestrogen made by growing '
              "follicles. Checked in treatment to see how you're responding."),
          _en('Progesterone: made after ovulation. A test about a week before '
              'your period is due shows whether you ovulated. Often called a '
              'day 21 test.'),
          _en('TSH (thyroid stimulating hormone): a thyroid test. Thyroid '
              'problems can affect cycles and pregnancy.'),
          _en('Prolactin: a hormone that can stop ovulation when it is high. '
              "It's easy to treat."),
          _en('Beta hCG: the pregnancy hormone, measured in blood, usually '
              'about two weeks after a transfer or IUI.'),
        ],
      ),
      PvReadSection(
        heading: _en('What are the scans and tube tests?'),
        bullets: [
          _en('TVS (transvaginal scan): an ultrasound with a thin probe '
              'inside the vagina. It shows the ovaries and womb more clearly '
              'than a scan on the tummy.'),
          _en('AFC (antral follicle count): the number of small follicles '
              'seen on a scan early in the cycle. Like AMH, it shows roughly '
              'how many eggs are left.'),
          _en('Follicular study, or folliculometry: a series of scans that '
              'watch a follicle grow, to see if and when you ovulate.'),
          _en('Dominant follicle: the one follicle that grows ahead of the '
              'rest and usually releases the egg.'),
          _en('Endometrium: the lining of the womb, measured in millimetres '
              'on a scan.'),
          _en('HSG (hysterosalpingogram): an X-ray taken while dye passes '
              'through the womb, to see if the tubes are open.'),
          _en('Hysteroscopy: a thin camera passed through the cervix to look '
              'inside the womb.'),
          _en('Laparoscopy: keyhole surgery through the tummy, to look at and '
              'treat problems like endometriosis or blocked tubes.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('Primary and secondary infertility, low reserve, male '
            'factor and the other names for what is going on.'),
        heading: _en('What do the diagnosis words mean?'),
        bullets: [
          _en('Primary infertility: no pregnancy after a year of trying (six '
              'months at 35 or over), with no pregnancy before.'),
          _en('Secondary infertility: the same, after an earlier pregnancy.'),
          _en('Unexplained infertility: the standard tests are normal, but '
              "pregnancy hasn't happened. It's common, and treatment can still "
              'help.'),
          _en('Low ovarian reserve: fewer eggs left than expected for your '
              'age.'),
          _en('Poor responder: someone whose ovaries grow fewer follicles '
              'with IVF medicines.'),
          _en('Male factor: a sperm problem is part of the reason.'),
          _en('Tubal factor: blocked or damaged tubes are part of the '
              'reason.'),
          _en('PCOS (polycystic ovary syndrome): a common hormone condition '
              'that can make ovulation irregular.'),
          _en('Endometriosis: tissue like the womb lining growing outside the '
              'womb. It can cause pain and affect fertility.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('OI, IUI, IVF, ICSI and the other treatment names, each '
            'in a line.'),
        heading: _en('What are the treatments called?'),
        bullets: [
          _en('OI (ovulation induction): tablets or injections that help you '
              'release an egg, often letrozole or clomiphene.'),
          _en('IUI (intrauterine insemination): washed sperm placed in the '
              'womb with a thin tube, around ovulation.'),
          _en('Sperm washing: separating the best moving sperm from the semen '
              'before IUI or IVF.'),
          _en('IVF (in vitro fertilisation): eggs and sperm are joined in a '
              'lab, and an embryo is placed in the womb.'),
          _en('ICSI (intracytoplasmic sperm injection): one sperm is injected '
              'into each egg. Used mainly when sperm count or movement is low.'),
          _en('Tubal surgery: an operation to open or repair damaged tubes, '
              'sometimes offered instead of IVF.'),
          _en('Surgical sperm retrieval (TESA, PESA, TESE): taking sperm '
              'straight from the testicle, or the tube beside it, when there '
              'is none in the semen.'),
          _en('Donor eggs or donor sperm: from an anonymous donor, through a '
              'registered ART bank.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('Stims, trigger, egg collection, blastocyst and the rest '
            "of an IVF cycle's words."),
        heading: _en('What will you hear during an IVF cycle?'),
        bullets: [
          _en('Stimulation, or stims: daily hormone injections that grow '
              'several follicles at once.'),
          _en('Trigger injection: timed to ripen the eggs. Egg '
              'collection is about 34 to 36 hours later.'),
          _en('OPU (ovum pick-up), or egg retrieval: collecting eggs with a '
              'fine needle under sedation.'),
          _en('Blastocyst: an embryo at about day 5 or 6, ready to be '
              'transferred or frozen.'),
          _en("Embryo grading: the lab's description of how an embryo looks. "
              "It's a rough guide, not a verdict."),
          _en('ET (embryo transfer): placing an embryo in the womb through a '
              'thin tube. It feels a lot like a Pap smear.'),
          _en('FET (frozen embryo transfer): transferring an embryo that was '
              'frozen earlier, in a later cycle.'),
          _en('PGT-A: a test on a few cells from an embryo to check its '
              'chromosome count. Not needed for everyone.'),
          _en('OHSS (ovarian hyperstimulation syndrome): the ovaries react '
              'too strongly to the medicines, causing swelling and fluid. '
              'Mostly mild, rarely serious.'),
        ],
      ),
      PvReadSection(
        heading: _en('And after a transfer or IUI?'),
        bullets: [
          _en('Luteal support: progesterone, as pessaries, gel, tablets or '
              'injections, to support the lining after a transfer.'),
          _en('Two-week wait: the days between a transfer or IUI and the '
              'pregnancy test.'),
          _en('Positive beta: a blood hCG level that shows pregnancy. A second '
              "test a couple of days later checks it's rising."),
          _en('Chemical pregnancy: a very early loss, where hCG rises and then '
              'falls before anything can be seen on a scan.'),
          _en('Clinical pregnancy: a pregnancy confirmed on a scan, with a sac '
              'in the womb.'),
          _en('Ectopic pregnancy: a pregnancy growing outside the womb, '
              'usually in a tube. It needs urgent care.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it rude to ask my doctor to explain a word?'),
        answer: _en('Not at all. Doctors expect questions, and a good one will '
            'be glad you asked. It helps to write the word down and ask, '
            '"What does this mean for us?"'),
      ),
      PvReadFaq(
        question: _en('My report has numbers with no explanation. What do I '
            'do?'),
        answer: _en("Don't try to decode them alone. Normal "
            'ranges differ between labs and with the day of your cycle. Take '
            'the report to your doctor, and look for the reference range the '
            'lab prints beside each result.'),
      ),
      PvReadFaq(
        question: _en('Why do clinics use different words for the same '
            'thing?'),
        answer: _en('Many tests have two or three names, like follicular '
            'study and folliculometry, or OPU and egg retrieval. They mean the '
            "same thing. If you're unsure, ask whether two names are the same "
            'test before paying twice.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When a word comes with symptoms'),
      body: _en("If you're in a treatment cycle, call your clinic the same day "
          'for a very swollen or painful tummy, breathlessness, vomiting, or '
          'passing much less urine. After a positive test, go to hospital the '
          'same day for severe one-sided pain, pain in the tip of your '
          'shoulder, heavy bleeding or fainting.'),
    ),
    evidence: _en('Definitions follow the International Glossary on '
        'Infertility and Fertility Care (ICMART and WHO, 2017), NICE guideline '
        'CG156, and StatPearls (NCBI) entries on anti-Müllerian hormone, '
        'hysterosalpingography and ovarian hyperstimulation syndrome. Sources '
        'checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, one by one'),
        value: _en('Each test in more depth, with price ranges.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your reports together'),
        value: _en('So every word has its report beside it.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: [
      'ttc_read_ivf_explained',
      'ttc_read_ivf_workup',
      'ttc_read_report_words',
    ],
  ),

  // ===========================================================================
  //  Ovulation tablets: letrozole and clomiphene
  // ===========================================================================
  //  Carries the P3 "twins" point (tablets raise the twin rate a little) as an
  //  FAQ, with no figure. Deliberately says nothing about Indian regulatory
  //  history on letrozole; the read says "off label" and sends her to her
  //  doctor.
  PvRead(
    id: 'ttc_read_ovulation_tablets',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Ovulation tablets in plain words: letrozole and clomiphene'),
    teaser: _en("What these tablets do, how they're taken, and what to watch "
        'for.'),
    shortAnswer: _en('Letrozole and clomiphene are tablets that help your '
        'ovaries release an egg. They are usually taken for five days early '
        'in your cycle, with scans to check the response. They help women who '
        "don't ovulate regularly, most often with PCOS, and are usually one of "
        'the first treatments offered.'),
    scaleSetter: _en('Being given tablets to help you ovulate is a common '
        "first step, and a gentle one. It isn't IVF, and it doesn't mean "
        "something is badly wrong. Many women who don't ovulate regularly get "
        'pregnant this way.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('If your cycles are long or irregular, you may not be releasing '
              'an egg every month. Ovulation tablets give your ovaries a '
              'nudge. Doctors call this ovulation induction, or OI.'),
          _en('They are not meant for women who already ovulate every month '
              'with no other problem found. For them, the tablets are unlikely '
              'to help and still carry side effects.'),
        ],
      ),
      PvReadSection(
        heading: _en('How do they work?'),
        paragraphs: [
          _en('Your brain sends a hormone called FSH to the ovaries to grow '
              'follicles. Both tablets make the brain sense less oestrogen, so '
              'it sends out more FSH. That extra push helps a follicle grow '
              'and release an egg.'),
          _en("Letrozole lowers how much oestrogen the body makes. Clomiphene "
              'blocks the brain from noticing the oestrogen that is there. The '
              'effect is similar, but the side effects differ.'),
          _en('Neither tablet is a hormone. They change how your own hormones '
              'talk to each other for a few days, and then they leave the '
              'body.'),
        ],
      ),
      PvReadSection(
        heading: _en('Letrozole or clomiphene: which is used?'),
        paragraphs: [
          _en('For women with PCOS, letrozole is now usually the first '
              'choice. Large studies found more live births with letrozole '
              'than with clomiphene in women with PCOS, and the international '
              'PCOS guideline recommends it first.'),
          _en('Letrozole is also a breast cancer medicine, so using it for '
              'ovulation is called "off label". This is common and backed by '
              'international guidelines. Your doctor can explain why they '
              'chose it for you.'),
          _en('Clomiphene has been used for decades and still works well for '
              'many women. Your doctor will choose based on your history, your '
              "tests and what's worked before."),
          _en("For women who don't have PCOS but ovulate irregularly, either "
              'tablet may be used. Clomiphene or letrozole is sometimes used '
              'alongside IUI too.'),
        ],
      ),
      PvReadSection(
        heading: _en('How are they taken?'),
        bullets: [
          _en('You start on day 2, 3, 4 or 5 of your period, as your doctor '
              'says.'),
          _en('You take the dose once a day for five days.'),
          _en('Letrozole usually starts at 2.5 mg a day, and clomiphene at 50 '
              'mg a day. The dose may go up in later cycles if you do not '
              'respond.'),
          _en('You may have scans from around day 9 to 12 to see how the '
              'follicles are growing.'),
          _en('Some doctors add a trigger injection when a follicle is ready, '
              'and suggest sex over the next day or two.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('Take only the dose and days your doctor has given you. Please '
              "don't restart old tablets on your own, even if they worked "
              'before, because the scans are part of the treatment.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does a cycle on tablets look like?'),
        paragraphs: [
          _en('Day 1 is the first day of real bleeding. If your period '
              "doesn't come on its own, your doctor may first give a short "
              'course of tablets to bring on a bleed.'),
          _en("Around day 10 you'll have your first scan. When a follicle "
              'reaches the right size, your doctor tells you which days to '
              'have sex, or gives a trigger injection. About two weeks after '
              "ovulation, you test if your period hasn't come."),
          _en("If you don't ovulate, your doctor may raise the dose next "
              'cycle. Some women need two or three cycles to find the dose '
              'that works for them.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why do the scans matter?'),
        paragraphs: [
          _en('Scans check that a follicle is growing, and how many are '
              "growing. They also show when you're likely to ovulate, so you "
              'know which days to have sex.'),
          _en('If three or more follicles grow, your doctor may advise '
              'avoiding sex that cycle, or change the plan. This is to avoid a '
              'pregnancy with triplets or more, which carries serious risks.'),
          _en('NICE advises that clomiphene treatment includes at least one '
              'scan in the first cycle, for exactly this reason.'),
        ],
      ),
      PvReadSection(
        heading: _en('What are the side effects?'),
        paragraphs: [
          _en('Most women manage the five days without much trouble. These '
              'are the common ones:'),
        ],
        bullets: [
          _en('Hot flushes, more often with clomiphene.'),
          _en('Headaches, tiredness or feeling dizzy.'),
          _en('Bloating or mild pelvic discomfort mid-cycle.'),
          _en('Mood changes, like feeling low or tearful.'),
          _en('Blurred vision or seeing spots, which is rare. Stop and tell '
              'your doctor straight away if it happens.'),
        ],
        tip: PvReadTip(
          title: _en('A difference worth knowing'),
          body: _en('In some women, clomiphene makes cervical mucus thicker '
              "and the womb lining thinner. Letrozole doesn't tend to do this. "
              'If your lining looks thin on a scan, your doctor may switch.'),
        ),
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('Why doctors review after a few cycles, and what comes '
            'next.'),
        heading: _en('How long can you take them?'),
        paragraphs: [
          _en('Most women who get pregnant on these tablets do so within the '
              'first few cycles in which they ovulate. NICE advises taking '
              'clomiphene for no more than six months.'),
          _en('If it has not worked by then, your doctor will usually suggest '
              'other tests or a next step. That might be FSH injections, IUI, '
              'or keyhole surgery on the ovaries for PCOS.'),
          _en("Your partner's semen analysis and a check of your tubes should "
              "be done before or early in treatment, if they haven't been "
              'already.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Do these tablets cause twins?'),
        answer: _en('They make twins a little more likely than in a natural '
            'cycle, clomiphene more than letrozole. This is one reason scans '
            'are done. If several follicles grow, your doctor may advise you to '
            'skip that cycle.'),
      ),
      PvReadFaq(
        question: _en('Will letrozole harm the baby if I get pregnant?'),
        answer: _en('The tablets are taken for five days early in the cycle, '
            "before ovulation, and they leave the body quickly. Large studies "
            'have not found more birth defects with letrozole than with '
            'clomiphene. If you are worried, ask your doctor.'),
      ),
      PvReadFaq(
        question: _en('Can I buy these at the chemist and take them myself?'),
        answer: _en("Please don't. Without scans, you won't know if too many "
            'follicles are growing, or if the tablets are working at all. They '
            "need a prescription and a doctor's follow-up."),
      ),
      PvReadFaq(
        question: _en("I ovulated but I'm still not pregnant. Why?"),
        answer: _en('Ovulating is one step. The sperm, the tubes and the '
            'timing all have to line up too. Even in a good cycle, most months '
            "don't end in pregnancy. Give it a few cycles, and ask your doctor "
            'when they will review.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor'),
      body: _en('Stop the tablets and call your doctor the same day if you get '
          'blurred vision, flashes or spots in your sight. Call the same day '
          'for severe tummy pain or swelling, breathlessness or vomiting. '
          'After a positive test, go to hospital the same day for severe '
          'one-sided pain, pain in the tip of your shoulder, heavy bleeding or '
          'fainting.'),
    ),
    evidence: _en('NICE guideline CG156, "Fertility problems: assessment and '
        'treatment". The International Evidence-based Guideline for the '
        'Assessment and Management of Polycystic Ovary Syndrome (2023). ASRM '
        'Practice Committee guidance on ovulation induction. StatPearls '
        '(NCBI), "Clomiphene" and "Letrozole". Sources checked September '
        '2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log your tablets'),
        value: _en('Dose, days and reminders, so nothing is missed.'),
        surfaceId: 'ttc_medication',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Track a cycle you're in"),
        value: _en('Scans, sizes and the trigger, in one place.'),
        surfaceId: 'ttc_treatment',
      ),
    ],
    readNext: [
      'ttc_read_follicle_scans',
      'ttc_read_pcos_ovulation',
    ],
  ),

  // ===========================================================================
  //  Follicle scans (the P1 "ultrasound tracking" topic)
  // ===========================================================================
  //  Also carries the "should I get help" pack's scan-day practicalities
  //  (sex before a scan, gas, a chaperone) and how else doctors confirm
  //  ovulation (the day 21 progesterone test).
  PvRead(
    id: 'ttc_read_follicle_scans',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Follicle scans: what is the doctor looking for?'),
    teaser: _en("Why you're having scans mid-cycle, what they show, and what "
        'the numbers mean.'),
    shortAnswer: _en('A follicle scan, or follicular study, is a series of '
        "internal ultrasound scans that watch an egg's follicle grow. It shows "
        'whether you ovulate, when, and how your womb lining is thickening. '
        "It's the most direct way to see ovulation, and it's quick and "
        'usually painless.'),
    scaleSetter: _en('Being sent for a follicular study is very common in '
        "India, often long before any talk of IVF. It doesn't mean something "
        "is wrong. It's a way of looking, not a diagnosis."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Most ways of tracking ovulation guess from signs, like strips '
              'or temperature. A scan looks directly at the ovary.'),
          _en('That is why doctors use it to confirm ovulation, to time sex or '
              "an IUI, and to see how you're responding to ovulation tablets."),
          _en('Many women in India are asked to come in several times in one '
              "cycle and aren't told why. This read explains what each visit "
              'is for.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why is it done, and for whom?'),
        bullets: [
          _en('To check whether you ovulate, if your cycles are irregular or '
              'a blood test was unclear.'),
          _en('To time sex or IUI to the day the egg is released.'),
          _en('To watch how you respond to letrozole or clomiphene, and make '
              'sure not too many follicles grow.'),
          _en('To check the lining before a frozen embryo transfer.'),
          _en('To look for cysts or fibroids that may need attention.'),
        ],
        paragraphs: [
          _en('A baseline scan is different. It is done on day 2 or 3 to '
              'count the small follicles and check the ovaries are quiet '
              'before treatment starts. A follicle scan comes in the middle of '
              'the cycle, to watch one follicle grow.'),
        ],
      ),
      PvReadSection(
        heading: _en('What happens at a scan?'),
        paragraphs: [
          _en('It is an internal scan, done with a thin probe gently placed '
              'inside the vagina. This gets much closer to the ovaries than a '
              'scan on the tummy, so the picture is clearer.'),
          _en("It usually takes 5 to 10 minutes, lying back with your "
              "knees raised. You may feel some pressure, but it shouldn't "
              'hurt. If it does, say so, and the doctor can slow down or '
              'stop.'),
          _en('The doctor or sonologist will often tell you the sizes as they '
              'go, and give you a short report after each visit. Keep them '
              'together, because each scan is read against the last.'),
        ],
        tip: PvReadTip(
          title: _en('Getting ready for the scan'),
          body: _en('Empty your bladder first, and wear something easy to take '
              "off below the waist. You don't need to avoid sex before a "
              'follicle scan unless your doctor says so. If gas makes scans '
              'uncomfortable, skip fizzy drinks and heavy meals of beans or '
              'rajma the night before.'),
        ),
      ),
      PvReadSection(
        heading: _en('How often, and when?'),
        bullets: [
          _en('The first scan is often around day 9 to 11 of a regular '
              "cycle, or as your doctor says if you're on tablets."),
          _en('Then every one to three days, as the follicle grows.'),
          _en('A last scan after the expected ovulation checks that the '
              'follicle has released its egg.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('Most women need three to five scans in a cycle. Ask for the '
              'likely dates at the start, so you can plan work around them.'),
          _en("If no follicle is growing that cycle, your doctor may stop the "
              'scans and plan the next cycle instead, so you are not paying '
              "for visits that won't help."),
        ],
      ),
      PvReadSection(
        heading: _en('What do the numbers mean?'),
        paragraphs: [
          _en('The report lists follicles by size in millimetres. A follicle '
              'usually grows about 1 to 2 mm a day, and tends to release its '
              'egg at around 18 to 24 mm.'),
          _en('Your report may say "dominant follicle", "DF" or "leading '
              'follicle". They all mean the one growing ahead of the rest. If '
              'there is more than one, each size is listed.'),
          _en('The report also measures your lining, the endometrium. It '
              'thickens through the cycle. Many doctors like to see about 7 mm '
              'or more around ovulation, though pregnancies happen with '
              'thinner linings too.'),
          _en('After ovulation, the follicle collapses and may leave a little '
              'fluid behind the womb. That is a sign an egg was released.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('One scan is a snapshot'),
          body: _en('Sizes vary a little between machines and between the '
              'people scanning. What matters is the pattern across several '
              'scans, and what your doctor makes of it. Try not to read too '
              'much into one number on your own.'),
        ),
      ),
      PvReadSection(
        heading: _en('What else can a scan show?'),
        paragraphs: [
          _en("Sometimes a follicle grows but doesn't release its egg. "
              'Doctors may call this a luteinised unruptured follicle. If it '
              'keeps happening, your doctor may add a trigger injection.'),
          _en('A follicle that grows very large without releasing can become a '
              'simple cyst. These usually go away on their own within one or '
              'two cycles.'),
          _en('A scan can also show cysts, fibroids, polyps, or ovaries with '
              'a polycystic look. None of these is a diagnosis on its own. '
              'Your doctor puts it together with your other tests.'),
        ],
      ),
      PvReadSection(
        heading: _en('How else do doctors confirm ovulation?'),
        paragraphs: [
          _en('A progesterone blood test about seven days before your next '
              'period is due shows whether you ovulated. In a 28-day cycle '
              "that's day 21, which is why it's called a day 21 test. It needs "
              "one visit, but it can't show when you ovulated."),
          _en('A period that comes every 21 to 35 days is itself a good sign '
              "that you're ovulating. Tests help most when cycles are "
              'irregular, or when timing matters for treatment.'),
          _en('Strips and temperature charts can help at home. A small sample '
              'of the womb lining was once used for this, but it is rarely '
              'done for this reason now.'),
          _en('A follicle scan often costs ₹800 to ₹2,500 a visit, so a full '
              'series adds up. Some clinics offer one price for the whole '
              'cycle, which is worth asking about.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I have a scan during my period?'),
        answer: _en('Yes. Some scans are done on day 2 or 3 on purpose, to '
            'count follicles at the start. An internal scan during your '
            'period is safe, and clinics are used to it.'),
      ),
      PvReadFaq(
        question: _en('Is an internal scan safe if I might be pregnant?'),
        answer: _en('Yes. Ultrasound uses sound waves, not radiation, and '
            'internal scans are used every day in early pregnancy.'),
      ),
      PvReadFaq(
        question: _en('Can I ask for a female doctor, or someone in the '
            'room?'),
        answer: _en('Yes. You can ask for a female sonologist, or for a nurse '
            'to stay with you, and you can ask the doctor to stop at any time. '
            "You don't need to explain why."),
      ),
      PvReadFaq(
        question: _en("My follicle was a good size, but I'm not pregnant. Did "
            'something go wrong?'),
        answer: _en('Not necessarily. A good follicle shows the first step '
            'went well. The sperm, the tubes and implantation all have to '
            "follow, and most months don't end in pregnancy even when "
            'everything is working.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to call your doctor'),
      body: _en('During a treatment cycle, call your doctor the same day for '
          'severe pelvic pain, a swollen tummy, or breathlessness. Go to '
          'hospital the same day for severe one-sided pain, pain in the tip '
          'of your shoulder, fainting or heavy bleeding, especially after a '
          'positive test. Mild cramps after an internal scan are normal and '
          'fade within the day.'),
    ),
    evidence: _en('NICE guideline CG156, "Fertility problems: assessment and '
        'treatment", for confirming ovulation with a mid-luteal progesterone '
        'test. ASRM Practice Committee, "Diagnostic evaluation of the '
        'infertile female" (2021). StatPearls (NCBI), "Transvaginal '
        'Ultrasound" and "Physiology, Ovulation". Scan price range as in '
        "ParentVeda's tests list. Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Add your scan dates'),
        value: _en('Reminders for each visit, so none are missed.'),
        surfaceId: 'ttc_appointments',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, one by one'),
        value: _en('The scan and the day 21 test, with prices.'),
        surfaceId: 'ttc_tests',
      ),
    ],
    readNext: [
      'ttc_read_ovulation_tablets',
      'ttc_read_ivf_workup',
    ],
  ),
];
