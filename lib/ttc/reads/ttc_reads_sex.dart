// =============================================================================
//  Fertile window › Sex and closeness: the reads for the new tab
// -----------------------------------------------------------------------------
//  Written 2026-09-26 from the TTC gap plan (docs/TTC-GAP-PLAN.md, stream A,
//  "Sex and closeness", 21 competitor pieces, 2 of them P1). Our own words,
//  written from medical knowledge and the named sources in each read's
//  evidence line. Nothing here is taken from Flo or What to Expect.
//
//  ⚠️ CONSISTENT WITH `ttc_read_timing_myths` (ttc_reads_conceiving.dart):
//  every one to two days across the window, and most ordinary lubricants slow
//  sperm. If either fact changes there, change it here in the same edit.
//
//  ⚠️ THE TAB NEEDS ITS HIDE SWITCH BEFORE IT SHIPS (gap plan: "Hide sex and
//  intimacy content"). These reads are frank but never crude, for an Indian
//  couple who may be reading together.
//
//  The rules these are written under are stated once, in the aggregator's
//  header (`ttc_reads_data.dart`). Read that before adding one.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// Private and duplicated per file, on purpose: see ttc_reads_conceiving.dart.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsSex = [
  // ===========================================================================
  //  1. When sex starts to feel like homework
  // ===========================================================================
  //  Pack: Keeping intimacy fun (P1), 5 ways to make sex fun again, Beat
  //  conception sex anxiety, Sex for pregnancy = resentment?, In a
  //  baby-making rut, spice it up (P3), masturbation shame (P3).
  PvRead(
    id: 'ttc_read_sex_homework',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('When sex starts to feel like homework'),
    teaser: _en('Why timed sex wears couples down, and small changes that '
        'take the pressure off without losing the window.'),
    shortAnswer: _en('Sex on a schedule starts to feel like a task for most '
        "couples who've been trying for a few months. It isn't a sign that "
        "something is wrong between you. Spreading sex across the whole "
        "month, and not announcing \"the day\", takes a lot of the pressure "
        'away.'),
    scaleSetter: _en('This is one of the most common things couples feel '
        "while trying, and it doesn't mean your relationship is in trouble. "
        "It's a reaction to pressure, and pressure can be eased. Nothing here "
        'needs a doctor unless sex has become painful or stopped altogether.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('At the start, trying for a baby can feel exciting. After a '
              'few months of counting days, it often feels different. Sex '
              'turns into an appointment, and one of you might start to '
              'dread the fertile days.'),
          _en('If that sounds like you, you are in very good company. Couples '
              'in fertility clinics describe this more than almost anything '
              'else. The good news is that the window is more forgiving than '
              'it feels, and there is room to make it gentler.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does sex on a schedule feel so different?'),
        paragraphs: [
          _en('Desire likes ease and a bit of surprise. A schedule takes '
              'both away. When sex has a purpose and a deadline, your mind '
              'stays on the result instead of on each other.'),
          _en('Each month that ends in a period can also add a layer of '
              'sadness to the next window. So sex can start to carry hope, '
              'fear and disappointment all at once. That is a lot for one '
              'evening to hold.'),
        ],
      ),
      PvReadSection(
        heading: _en("Is it normal to feel resentful?"),
        paragraphs: [
          _en('Yes. The partner who tracks the cycle can feel like the only '
              'one carrying the plan. The other can feel summoned, or '
              'valued only on certain days. Both feelings are common, and '
              'neither makes either of you a bad partner.'),
          _en("Resentment grows when it isn't said. Naming it out loud, "
              "calmly and away from the bedroom, usually brings relief. Try "
              "\"I miss when this was just about us\" rather than \"You "
              "never feel like it any more\"."),
        ],
      ),
      PvReadSection(
        heading: _en("What if it doesn't work on the day that matters?"),
        paragraphs: [
          _en('Pressure affects bodies. Many men who have no trouble on '
              'other days find it hard to get or keep an erection, or to '
              'finish, on the days that count. Many women find they stay dry '
              "or tense. This is the body reacting to stress. It isn't a "
              'fertility problem.'),
          _en("If it happens, try not to make it a big moment. Stop, lie "
              "together, and try again later or the next day. The window "
              "lasts several days, so one difficult night doesn't cost you "
              'the month.'),
        ],
        mythFact: PvMythFact(
          myth: _en('If you miss one fertile day, the whole month is wasted.'),
          fact: _en('The fertile window is about six days long. Sex every one '
              "to two days across it is enough, so one missed night doesn't "
              'undo it. The days before ovulation count as much as the day '
              'itself.'),
        ),
      ),
      PvReadSection(
        heading: _en('How can we take the pressure off?'),
        paragraphs: [
          _en('None of these are rules. Pick one or two that suit you both '
              'and see how the next month feels.'),
        ],
        bullets: [
          _en('1. Spread it out. The NICE fertility guideline suggests sex '
              'every two to three days through the whole cycle. Then no '
              'single day is "the day", and you may not need to track at '
              'all.'),
          _en("2. Stop announcing it. If one of you tracks, that person can "
              "keep the dates private, or you can agree a quiet signal "
              "instead of \"it's today\"."),
          _en('3. Keep some sex for outside the window, just for the two of '
              'you, with no goal at all.'),
          _en('4. Change the setting. A different room, a weekend away, or '
              'an afternoon instead of late at night can feel new again.'),
          _en('5. Give each other a free pass. Either of you can say "not '
              'tonight" in the window without it becoming a fight.'),
          _en('6. Take the focus off finishing. Start with touch and time '
              'together, and let sex come from there, or not.'),
        ],
        tip: PvReadTip(
          title: _en('A line you can borrow'),
          body: _en('"I want a baby with you, and I also want us back. Can we '
              'plan the window together, and then forget about it for a '
              'bit?"'),
        ),
      ),
      PvReadSection(
        heading: _en('What if we want different things from the plan?'),
        paragraphs: [
          _en('Often one partner wants to track every sign and the other '
              'would rather not know the dates at all. Neither way is wrong. '
              'The trouble starts when one way is pushed on the other '
              'without a conversation.'),
          _en('Try meeting in the middle. The one who likes tracking keeps '
              'the dates, and shares only what is needed, a few days ahead. '
              'The other agrees to keep those evenings free. Then you look '
              'at how it went together, once a month, and change what '
              "didn't work."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we bring back a bit of fun?'),
        paragraphs: [
          _en('Fun comes back when sex stops being a test you can pass or '
              'fail. Small changes are enough. You do not need to become '
              'different people.'),
          _en('Think back to what you both enjoyed before the trying began, '
              'and bring one piece of it back. It might be a slow evening, '
              'a favourite song, dressing up a little, or just laughing '
              'together when something goes wrong.'),
        ],
        bullets: [
          _en('Take turns choosing how the evening goes.'),
          _en('Say one thing you like about each other before you start.'),
          _en('Keep phones and fertility talk out of the bedroom on '
              'window days.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('It does no harm to fertility, for either of you, and '
            "there's nothing to feel guilty about."),
        heading: _en('Is masturbation wrong or wasteful while trying?'),
        paragraphs: [
          _en("No. Masturbation doesn't harm fertility for either of you. The "
              'body makes new sperm all the time, so it isn\'t "used up". On '
              'the window days it makes sense for ejaculation to happen '
              "during sex, but on other days it doesn't matter."),
          _en('Many people carry guilt about this from how they grew up. '
              'Trying for a baby is not a reason to add to it. For some '
              'couples, touching themselves or each other is also a way back '
              'to desire when sex has started to feel like a chore.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Do I need to have an orgasm to get pregnant?'),
        answer: _en("No. There's no good evidence that a woman's orgasm is "
            'needed to conceive. It is lovely if it happens, and it '
            "shouldn't become one more thing to get right."),
      ),
      PvReadFaq(
        question: _en('Is it okay to skip a window because we just '
            "can't face it?"),
        answer: _en("Yes. Taking a month off can help you both come back "
            "to it more gently. If you're 35 or over, or you've been trying "
            "a long time, it's worth mentioning your plan at your next "
            'doctor visit.'),
      ),
      PvReadFaq(
        question: _en('My husband gets upset when it doesn\'t work on the day. '
            'What can I say?'),
        answer: _en('Tell him it happens to lots of men under pressure, and '
            "that you're not keeping score. Then change the subject to "
            'something warm. If it keeps happening for more than a few '
            'weeks, a doctor can help, and it is a common visit.'),
      ),
      PvReadFaq(
        question: _en('Does it matter if sex feels routine, as long as it '
            'happens?'),
        answer: _en("For getting pregnant, no. For the two of you, it can. "
            'Couples who keep some closeness that has nothing to do with '
            'the window often find the trying months easier to bear.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help'),
      body: _en('See a doctor if erection or ejaculation problems happen most '
          'times for more than a few weeks, or if sex is painful. Talk to a '
          'counsellor if sex has stopped for months and it hurts either of '
          "you. If you've felt low or hopeless most days for two weeks or "
          "more, see a doctor soon, or call Tele-MANAS, India's free mental "
          'health line, on 14416.'),
    ),
    evidence: _en('How often to have sex follows the NICE fertility guideline '
        'CG156 (every two to three days) and "Optimizing natural fertility: '
        'a committee opinion" from the American Society for Reproductive '
        'Medicine (updated 2022; every one to two days across the window). '
        'Stress and sexual difficulty while trying follow the ESHRE guideline '
        'on routine psychosocial care in infertility (2015) and Cleveland '
        'Clinic on performance anxiety. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        // Kept for revert (2026-09-28, explicit names): title: _en("See this cycle's window"),
        title: _en("See this cycle's fertile window"),
        value: _en('Know roughly when it is, so the rest of the month can be '
            'just yours.'),
        surfaceId: 'ttc_window',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Bring your partner in'),
        value: _en('Share the plan so one person isn\'t carrying the '
            'calendar.'),
        surfaceId: 'ttc_partner',
      ),
    ],
    readNext: [
      'ttc_read_keeping_close',
      'ttc_read_low_desire',
      'ttc_read_timing_myths',
    ],
  ),

  // ===========================================================================
  //  2. Low desire while trying, hers and his
  // ===========================================================================
  //  Pack: Don't feel like having sex?, Is your sex drive normal?, What to do
  //  if you don't want sex but your partner does?, Sex when you don't feel
  //  sexy, Too tired for sex (P3), Ovulation = pleasure peaks (P3), sex in
  //  the second half of the cycle (P3), sex in the follicular phase (P3).
  PvRead(
    id: 'ttc_read_low_desire',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Low desire while trying, hers and his'),
    teaser: _en("What's normal, why trying can dull desire for both of you, "
        'and when it is worth a word with a doctor.'),
    shortAnswer: _en("There's no normal amount of desire, and it often dips "
        "while you're trying because of pressure, tiredness and sadness. "
        'For many people, desire comes after closeness starts rather than '
        'before. If it has gone for months and bothers either of you, a '
        'doctor can look for a cause.'),
    scaleSetter: _en('Low desire on its own is very common and is not a '
        "fertility problem. It doesn't stop you conceiving if you still have "
        "sex in the window. It's worth a doctor's visit only when it lasts "
        'for months, comes with low mood, or sits alongside pain or '
        'erection trouble.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('It can feel strange to want a baby very much and not want '
              'sex at all. Many couples feel this, and many are too shy to '
              'say it even to each other.'),
          _en('This read covers both of you, because desire can drop on '
              'either side. None of it is about blame. It is about what '
              'changes desire and what helps it come back.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is my sex drive normal?'),
        paragraphs: [
          _en("There's no normal number. Some couples want sex most days and "
              'some a few times a month, and both are healthy. Desire also '
              'rises and falls through life, with work, health, sleep and '
              'worry.'),
          _en('What matters is not how often, but whether the gap between '
              'you bothers either of you. If you are both content, there is '
              'nothing to fix.'),
          _en('It is also normal for two people to want sex at different '
              'amounts. Almost every couple has some gap. It only becomes a '
              'problem when one of you feels pushed or the other feels '
              'turned away most of the time.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does trying make desire drop?'),
        paragraphs: [
          _en('Several things tend to pile up at once. Often there is no '
              'single cause.'),
        ],
        bullets: [
          _en('Pressure. Sex with a deadline is harder to want.'),
          _en('Sadness. Each period can bring a dip that lasts into the next '
              'window.'),
          _en('Tiredness from work, travel, housework and worry.'),
          _en('Body worries, from weight changes, PCOS symptoms such as '
              'extra hair, or feeling your body has let you down.'),
          _en('Health reasons, such as thyroid problems, low iron, a raised '
              'prolactin level, or low mood.'),
          _en('Some medicines, including some antidepressants. Fertility '
              'medicines can also leave you tired or moody.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does desire change through my cycle?'),
        paragraphs: [
          _en('For many women, yes. In the days before ovulation, rising '
              'oestrogen often brings a lift in desire and energy. That '
              'lines up well with the fertile window, which can make those '
              'days feel less like a task.'),
          _en('After ovulation, progesterone rises. Some women feel more '
              'tired, bloated or low in the second half, especially in the '
              'days before a period. Desire may dip then. This pattern '
              'varies a lot, and plenty of women notice no pattern at all.'),
        ],
        tip: PvReadTip(
          title: _en('Too tired by bedtime?'),
          body: _en('Try a different time. A weekend morning or an early '
              'evening often works better than 11 at night. Tiredness is one '
              'of the most common reasons couples give, and changing the '
              'hour is the easiest fix.'),
        ),
      ),
      PvReadSection(
        heading: _en("What if I don't feel sexy at all?"),
        paragraphs: [
          _en('Many women feel desire only after touching has started, not '
              'before. This is called responsive desire and it is completely '
              'normal. Waiting to "feel like it" first can mean waiting a '
              'long time.'),
          _en("So on days you don't feel sexy, it can help to start with "
              'something small and see how you feel: a massage, lying close, '
              'a long kiss. If nothing comes, you can stop there. You never '
              'owe anyone sex.'),
          _en('Feeling unattractive is common while trying, especially with '
              'weight changes, acne or extra hair from PCOS. Your partner '
              'rarely sees you the way you see yourself in those moments. '
              'Telling them how you feel often brings reassurance you '
              "didn't expect."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps desire come back?'),
        paragraphs: [
          _en('Desire usually returns slowly, once the pressure eases. These '
              'are small things couples find helpful.'),
        ],
        bullets: [
          _en('1. Sleep. Tiredness is one of the biggest dampers, and an '
              'early night helps more than most people expect.'),
          _en('2. Time together that is not about the baby, every week.'),
          _en('3. Touch without a goal on days outside the window.'),
          _en('4. Moving your body in ways you enjoy, like walking or yoga, '
              'which lifts mood and energy.'),
          _en('5. Talking to someone if sadness has settled in. Low mood '
              'and low desire often travel together, and treating one helps '
              'the other.'),
        ],
      ),
      PvReadSection(
        heading: _en("What if my partner wants sex and I don't?"),
        paragraphs: [
          _en("Talk about it away from the bedroom, when you're both calm. "
              "Say what you're feeling without blame, and ask what they "
              'miss. Often it is closeness more than sex.'),
          _en('Plan the window days together a few days ahead, so neither '
              'of you is caught off guard. Offer other kinds of touch on '
              'other days. You can always say no, and a kind "not tonight" '
              'is part of a healthy marriage.'),
        ],
      ),
      PvReadSection(
        heading: _en("And when he's the one who doesn't feel like it?"),
        paragraphs: [
          _en("Men's desire drops with stress and pressure too, and many men "
              'find it hard to say. It usually says nothing about how he '
              'feels about you. Worry about the result, or about performing '
              'on the day, is a common cause.'),
          _en('One warning: testosterone tablets, injections or gels, and '
              'many "stamina" products, can switch off sperm production. '
              'He should never take anything like this while trying without '
              'a doctor\'s advice.'),
          _en('If erections are a problem most times, or he has lost interest '
              'for months, a doctor can check for causes such as blood '
              'sugar, blood pressure, thyroid or low mood. It is a common '
              'visit, and most causes can be helped.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it normal to want sex only around ovulation?'),
        answer: _en('Yes, many women notice more desire around the middle of '
            "the cycle. It's hormones at work, and it can make the window a "
            'little easier.'),
      ),
      PvReadFaq(
        question: _en('Can low desire stop us from getting pregnant?'),
        answer: _en("Desire itself doesn't affect conception. What matters is "
            'having sex every one to two days across the window. Low desire '
            'only matters for fertility if it means sex rarely happens then.'),
      ),
      PvReadFaq(
        question: _en('Is there a tablet for low desire in women?'),
        answer: _en("There isn't a simple pill for it. A doctor will look for "
            'a cause first, such as thyroid, low iron, a medicine or low '
            'mood, and treat that. Talking with a counsellor helps many '
            'couples too.'),
      ),
      PvReadFaq(
        question: _en('He says it\'s fine, but I feel rejected. What now?'),
        answer: _en('Tell him how it feels for you, gently, and ask how he '
            'feels. Low desire is rarely about the other person. If it has '
            'lasted months, seeing a doctor or counsellor together is a '
            'caring step, not an accusation.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en('Book a visit if desire has been gone for several months and '
          'it bothers either of you, if erections are a problem most times, '
          'if sex is painful, or if you have milky discharge from your '
          "nipples when you're not breastfeeding. If you've felt low most "
          'days for two weeks or more, see a doctor soon, or call '
          'Tele-MANAS on 14416.'),
    ),
    evidence: _en('Causes of low desire follow StatPearls, "Female Sexual '
        'Dysfunction" and "Hypoactive Sexual Desire Disorder" (NCBI '
        'Bookshelf), and Cleveland Clinic on low libido. Cycle changes in '
        'desire follow Endotext, "The Normal Menstrual Cycle" (NCBI). The '
        'warning on testosterone follows the AUA/ASRM guideline on male '
        'infertility (2020). Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en("Today's practice"),
        value: _en('Five quiet minutes that can help on a heavy day.'),
        surfaceId: 'ttc_ritual',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a specialist privately'),
        value: _en('If desire has been low for months, a doctor can look for '
            'a cause.'),
        surfaceId: 'ttc_prepare',
      ),
    ],
    readNext: [
      'ttc_read_sex_homework',
      'ttc_read_stress_fertility',
    ],
  ),

  // ===========================================================================
  //  3. Pain during sex, including vaginismus
  // ===========================================================================
  //  Pack: What causes vaginismus and how it can be treated (P1), Common
  //  causes of pain during sex (P2). Gentle and private, with a route to a
  //  doctor who goes at her pace.
  PvRead(
    id: 'ttc_read_pain_vaginismus',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Pain during sex, including vaginismus'),
    teaser: _en('What can cause pain during sex, what vaginismus is, and how '
        'very treatable it is.'),
    shortAnswer: _en("Pain during sex is common, and it isn't something you "
        'have to put up with. It has causes a doctor can find, such as '
        'dryness, an infection, endometriosis or vaginismus. Vaginismus, '
        'where the muscles tighten on their own, is very treatable.'),
    scaleSetter: _en('Most causes of pain during sex are common and '
        'treatable, and none of them are your fault. It is worth seeing a '
        'doctor if it happens most times. It is urgent only with fever, '
        'sudden severe pain in your tummy, or heavy bleeding.'),
    author: _en('Dr Vaishnavi'),
    authorRole: _en('Pelvic and sexual health specialist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Many women never tell anyone that sex hurts. Some have never '
              'been able to have sex at all, and have kept it a secret for '
              'years. If that is you, please know that doctors see this '
              'often, and there is real help.'),
          _en('Pain during sex has a medical name, dyspareunia. It is a '
              'symptom, like a headache, with a cause behind it. Finding the '
              'cause is the first step to fixing it.'),
        ],
      ),
      PvReadSection(
        heading: _en('Where does it hurt?'),
        paragraphs: [
          _en('Where you feel the pain gives your doctor a useful clue. '
              "Pain at the entrance and pain deep inside tend to have "
              'different causes.'),
        ],
        bullets: [
          _en('Pain at the entrance: dryness or not enough time to get '
              'aroused, an infection such as thrush, a skin condition, '
              'vaginismus, or healing stitches after an earlier birth.'),
          _en('Burning at the entrance that keeps coming back with no '
              'infection can be vulvodynia, a long-lasting nerve pain that '
              'can be treated.'),
          _en('Deep pain: endometriosis, a pelvic infection, some ovarian '
              'cysts or fibroids, or bowel and bladder problems.'),
          _en('Deep pain that is worse around your period, with very painful '
              'periods, is worth mentioning, because it can point to '
              'endometriosis.'),
        ],
      ),
      PvReadSection(
        heading: _en('What will the doctor do?'),
        paragraphs: [
          _en('Most of the first visit is talking. The doctor will ask where '
              'it hurts, when it started, whether it happens every time, and '
              'how your periods are. Your answers often point to the cause '
              'before any check.'),
          _en('If a check is needed, it may start with just looking at the '
              'outside, and a swab if an infection is possible. An '
              'ultrasound can look for cysts, fibroids or signs of '
              'endometriosis. Infections such as thrush are usually cleared '
              'quickly with the right treatment.'),
          _en('It helps to jot down a few notes before you go: where the pain '
              'is, how bad it is, and what makes it better or worse. Then you '
              "don't have to find the words in the room."),
        ],
      ),
      PvReadSection(
        heading: _en('What is vaginismus?'),
        paragraphs: [
          _en('Vaginismus is when the muscles around the vagina tighten on '
              'their own when something is about to go in. You don\'t choose '
              'it and you can\'t stop it by trying harder. It can make sex '
              'painful, or impossible.'),
          _en('Some women have it from the very first time. Others develop '
              'it later, often after sex has hurt for another reason, such as '
              'an infection or a difficult birth. Tampons and internal '
              'check-ups may be hard too.'),
          _en('It often comes from fear: of pain, of tearing, or of sex '
              'itself after years of being told it is shameful. For some it '
              'follows a painful or frightening experience. Often there is '
              'no single reason. It has nothing to do with how much you love '
              'your partner.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Pain in the first months of marriage is normal and goes '
              'away if you keep trying.'),
          fact: _en('Some discomfort at first can happen. Pain that keeps '
              'coming back is a sign to see a doctor. Pushing through it can '
              'teach the muscles to tighten even more.'),
        ),
      ),
      PvReadSection(
        heading: _en('How is vaginismus treated?'),
        paragraphs: [
          _en('Treatment works well for most women and goes at your pace. '
              'It usually follows steps like these.'),
        ],
        bullets: [
          _en('1. A gentle first visit. The doctor listens first. Any check '
              'is done only with your permission, and you can say stop at '
              'any time.'),
          _en('2. Learning how the muscles work, and that tightening is a '
              'reflex, not a failure.'),
          _en('3. Pelvic floor physiotherapy, to learn to relax the muscles '
              'with breathing and gentle exercises.'),
          _en('4. Vaginal trainers (dilators), smooth tubes in growing '
              'sizes, used at home, in private, when you are ready.'),
          _en('5. Counselling or sex therapy, often with your partner, to '
              'ease the fear and rebuild closeness.'),
          _en('6. Trying sex again only when you feel ready, with you in '
              'control of what happens.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('This is very treatable'),
          body: _en('Most women with vaginismus are able to have comfortable '
              'sex after treatment. It can take weeks or months, and every '
              'step counts.'),
        ),
      ),
      PvReadSection(
        heading: _en('How can my partner help?'),
        paragraphs: [
          _en('A partner who is patient and on your side makes treatment much '
              'easier. The most helpful thing is to take the pressure off: no '
              'attempts at intercourse until you are ready, and closeness in '
              'other ways meanwhile.'),
          _en('Partners often feel guilty, rejected or worried they caused '
              'the pain. Talking about this, sometimes with a counsellor, '
              'helps you both. Some therapists invite partners to a session '
              'so they understand what the exercises involve.'),
        ],
      ),
      PvReadSection(
        heading: _en('Can we still get pregnant while it is treated?'),
        paragraphs: [
          _en('Yes, there are ways. Some couples first come to a fertility '
              'clinic because sex has not been possible. Doctors meet this '
              "often and won't judge you."),
          _en('Your doctor can talk about ways to conceive that don\'t need '
              'intercourse, such as IUI, if you would rather not wait. Many '
              'couples choose to do this alongside treatment.'),
          _en('Others prefer to treat the pain first and try naturally '
              'afterwards. Both are reasonable. Your age, how long you have '
              'been trying and how you both feel will shape the choice, and '
              'your doctor can help you weigh it up.'),
        ],
        tip: PvReadTip(
          title: _en('What you can say at the appointment'),
          body: _en('"Sex has been painful for me," or "We haven\'t been able '
              'to have sex." That is enough to start. You can ask for a woman '
              'doctor, and you can bring your partner or come alone.'),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Will the doctor have to examine me inside?'),
        answer: _en('Not always, and not at the first visit if you are not '
            'ready. A good doctor explains each step, asks first, and stops '
            'when you say so.'),
      ),
      PvReadFaq(
        question: _en('Does this mean I don\'t love my husband?'),
        answer: _en('No. Vaginismus is a body reflex, not a feeling about '
            'your partner. Many women with it love their partners very much '
            'and want to be close.'),
      ),
      PvReadFaq(
        question: _en('Can I use a numbing gel to get through it?'),
        answer: _en('It is better not to. Numbing hides the pain without '
            'treating the cause, and some gels are not kind to sperm. Ask '
            'your doctor what is safe for you.'),
      ),
      PvReadFaq(
        question: _en('Will vaginismus affect giving birth?'),
        answer: _en('Many women who have had vaginismus go on to have a '
            'vaginal birth. If you feel worried about it, talk it through '
            'with your doctor during pregnancy.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor, and how soon'),
      body: _en('Book a visit if sex hurts most times, if you have never been '
          'able to have sex, or if you bleed after sex more than once. See a '
          'doctor within a day or two if the pain comes with fever, unusual '
          'discharge or pain low in your tummy. Go to hospital today if you '
          'have sudden severe tummy pain, feel faint, or bleed heavily, '
          'especially if you could be pregnant.'),
    ),
    evidence: _en('Causes of pain during sex follow the ACOG patient FAQ '
        '"When Sex Is Painful", the NHS pages on pain during sex and on '
        'vaginismus, and StatPearls, "Dyspareunia" and "Vaginismus" (NCBI '
        'Bookshelf). Treatment of vaginismus follows Cleveland Clinic. '
        'Endometriosis signs follow NICE guideline NG73. Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a specialist privately'),
        value: _en('A calm, private first conversation, at your pace.'),
        surfaceId: 'ttc_prepare',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        // Kept for revert (2026-09-28, explicit names): title: _en('Note it for your next visit'),
        title: _en('Note the pain for your next visit'),
        value: _en('Where it hurts and when, written down, so you don\'t have '
            'to find the words on the day.'),
        surfaceId: 'ttc_appointments',
      ),
    ],
    readNext: [
      'ttc_read_lubricants',
      'ttc_read_when_to_seek_help',
    ],
  ),

  // ===========================================================================
  //  4. Lubricants: what to look for
  // ===========================================================================
  //  Pack: Why might your vagina stay dry even if you are turned on? (P2).
  //  ⚠️ Same fact as ttc_read_timing_myths: most ordinary lubricants, and
  //  saliva, slow sperm in lab tests. No price given: fertility-friendly
  //  tubes vary widely in India and a wrong range is worse than none.
  PvRead(
    id: 'ttc_read_lubricants',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Lubricants while trying: which ones are sperm-friendly?'),
    teaser: _en('Why you might be dry even when you want to be close, which '
        'lubricants slow sperm, and what to use instead.'),
    shortAnswer: _en('Many ordinary lubricants, saliva and some oils slow '
        'sperm down in lab tests. If you need one while trying, choose a '
        'lubricant labelled fertility-friendly or sperm-friendly. Being dry '
        'is common and is not a sign that anything is wrong.'),
    scaleSetter: _en('Dryness during sex is very common and usually harmless. '
        'The only change worth making while trying is which lubricant you '
        'use. See a doctor only if dryness comes with pain every time, '
        'itching or burning, or unusual discharge.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Being dry when you want to be close can feel confusing, or '
              'even embarrassing. It happens to most women at some point. '
              'Trying for a baby, with its pressure and timing, makes it more '
              'likely.'),
          _en('A lubricant is a simple, sensible fix. The one thing to know '
              'while trying is that not all of them are kind to sperm.'),
          _en('So this read covers why dryness happens, which products to '
              'skip on the fertile days, and what to reach for instead. None '
              'of it asks you to change anything else about how you are '
              'together.'),
        ],
      ),
      PvReadSection(
        heading: _en("Why am I dry even when I'm in the mood?"),
        paragraphs: [
          _en('Feeling aroused and getting wet don\'t always go together. '
              'Your mind can be ready before your body is, especially when '
              'you are stressed, tired or rushing.'),
        ],
        bullets: [
          _en('Not enough time. Arousal takes longer on tense days.'),
          _en('Where you are in your cycle. Natural wetness is highest in '
              'the fertile days and lower at other times.'),
          _en('Some medicines. Clomiphene, a common fertility tablet, can '
              'thicken or dry cervical mucus. Antihistamines and cold '
              'medicines can dry you too.'),
          _en('Breastfeeding, if you are trying for a second baby, because '
              'it lowers oestrogen for a while.'),
          _en('Worry itself. Stress hormones can slow the body\'s natural '
              'response.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is dryness a sign that something is wrong with my '
            'fertility?'),
        paragraphs: [
          _en("Usually not. Being dry during sex on a given day doesn't tell "
              'you whether you are ovulating or how fertile you are. Most of '
              'the time it is about time, mood and stress.'),
          _en('If you are on a fertility medicine and notice you have become '
              'much drier since starting it, mention it at your next visit. '
              "Don't stop the medicine on your own. Your doctor may have a "
              'simple way to help.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which lubricants slow sperm?'),
        paragraphs: [
          _en('In lab tests, many common water-based lubricants, saliva and '
              'olive oil make sperm move more slowly. Some also damage '
              'sperm directly. This is the one piece of bedroom advice with '
              'measured evidence behind it.'),
          _en('What has been measured is the effect on sperm in a dish. '
              'Whether it makes a real difference for couples is less clear. '
              'Since sperm-friendly options are easy to find, there is no '
              'reason to take the risk.'),
        ],
        bullets: [
          _en('Avoid anything with spermicide, often listed as '
              'nonoxynol-9.'),
          _en('Avoid warming, tingling or flavoured lubricants. They can '
              'irritate and are not made with sperm in mind.'),
          _en('Try not to use saliva as a lubricant on the fertile days. It '
              'slowed sperm in lab tests too.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does sperm-friendly mean?'),
        paragraphs: [
          _en('Sperm-friendly or fertility-friendly lubricants are made to '
              'match the natural balance of fertile cervical mucus, so sperm '
              'can move through them. The label will say so clearly.'),
          _en('The American Society for Reproductive Medicine notes that '
              'lubricants based on hydroxyethylcellulose, and mineral oil, '
              "didn't harm sperm in lab tests. A lubricant made for "
              'conception is the simplest choice. You will find them online '
              'and at larger chemists.'),
          _en('They usually cost a little more than ordinary ones, and a '
              'tube lasts a while because you need only a small amount. '
              'Outside the fertile days, you can use whatever feels '
              'comfortable for you.'),
        ],
        tip: PvReadTip(
          title: _en('How to use it'),
          body: _en('Use a small amount, warmed in your hand first. It can go '
              'on either of you. Some come with an applicator for inside. '
              'You only need it when you feel dry, not every time.'),
        ),
      ),
      PvReadSection(
        heading: _en('What about oils from the kitchen?'),
        paragraphs: [
          _en('Coconut oil and other home oils are common in Indian homes, '
              'and it is natural to reach for them. Olive oil slowed sperm '
              'in lab tests. There is too little good research on coconut '
              'oil to call it sperm-friendly.'),
          _en('Oils can also be harder to wash away and may irritate some '
              'women. On the fertile days, a product made for trying is the '
              'safer choice.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Egg white from the kitchen makes a natural, '
              'sperm-friendly lubricant.'),
          fact: _en("There's no good evidence it helps sperm, and raw egg "
              'can carry germs such as salmonella. It is better left in the '
              'kitchen.'),
        ),
      ),
      PvReadSection(
        heading: _en('Can we do anything besides lubricant?'),
        paragraphs: [
          _en('Yes. Spending longer on touch and kissing before sex gives '
              'your body time to catch up. So does taking the rush out of the '
              'fertile days, since sex every one to two days across the '
              'window is enough.'),
          _en('If dryness is making sex painful, stop and tell your partner. '
              'Carrying on through pain can make it worse next time.'),
          _en('It can also help to talk about it outside the bedroom. Many '
              'partners worry that dryness means you are not interested. '
              'Knowing that it is common, and mostly about stress and timing, '
              'takes that worry away for both of you.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('What to check on the pack before you buy.'),
        heading: _en('How do I read the label?'),
        paragraphs: [
          _en('Packs can be confusing, and the words that matter are often '
              'small. Look for these.'),
        ],
        bullets: [
          _en('The words fertility-friendly, sperm-friendly or made for '
              'couples trying to conceive.'),
          _en('No spermicide or nonoxynol-9 in the ingredients.'),
          _en('No warming, cooling, tingling or flavour on the front.'),
          _en('If you have sensitive skin, try a little on your inner arm '
              'first and wait a day.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it okay to use no lubricant at all?'),
        answer: _en('Yes, if sex is comfortable without one. There is no '
            'need to use a lubricant just because you are trying.'),
      ),
      PvReadFaq(
        question: _en('Will a sperm-friendly lubricant help us get pregnant '
            'faster?'),
        answer: _en("No. There's no evidence it speeds things up. It just "
            "keeps sex comfortable without getting in sperm's way."),
      ),
      PvReadFaq(
        question: _en('Can I use lubricant around IUI or IVF?'),
        answer: _en('Ask your clinic. Most are happy with a sperm-friendly '
            'one at home, but some have their own advice around procedures '
            'and semen collection.'),
      ),
      PvReadFaq(
        question: _en('I feel shy buying it. Is there an easier way?'),
        answer: _en('Many women order online for privacy. Chemists sell '
            'these every day, and you do not have to explain anything.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When dryness needs a doctor'),
      body: _en('See a doctor within a few days if you have itching, burning, '
          'a bad smell or unusual discharge, since an infection may need '
          'treatment. Book a visit if sex hurts every time, if you bleed '
          'after sex, or if dryness comes with hot flushes and periods that '
          'have become irregular or stopped.'),
    ),
    evidence: _en('The effect of lubricants and saliva on sperm follows '
        '"Optimizing natural fertility: a committee opinion" from the '
        'American Society for Reproductive Medicine (updated 2022). Causes '
        'of dryness follow the NHS page on vaginal dryness and Cleveland '
        'Clinic. The effect of clomiphene on cervical mucus follows '
        'StatPearls, "Clomiphene" (NCBI Bookshelf). Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.product,
        title: _en('What is worth having at home'),
        value: _en('Sperm-friendly options, and what to skip.'),
        surfaceId: 'ttc_products',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        // Kept for revert (2026-09-28, explicit names): title: _en("See this cycle's window"),
        title: _en("See this cycle's fertile window"),
        value: _en('The days you may want one to hand.'),
        surfaceId: 'ttc_window',
      ),
    ],
    readNext: [
      'ttc_read_timing_myths',
      'ttc_read_pain_vaginismus',
    ],
  ),

  // ===========================================================================
  //  5. Sex after the fertile window
  // ===========================================================================
  //  Planned by the gap plan. Ectopic signs are firm and specific, per the
  //  brief: severe one-sided pain, shoulder-tip pain, fainting, heavy
  //  bleeding, hospital today.
  PvRead(
    id: 'ttc_read_sex_after_window',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Sex after the fertile window: can it affect an early '
        'pregnancy?'),
    teaser: _en('Whether sex in the two-week wait can disturb implantation, '
        'and the few times a doctor might ask you to wait.'),
    shortAnswer: _en('No. Sex and orgasm in the days after ovulation do not '
        'disturb implantation or harm an early pregnancy. Unless your doctor '
        'or clinic has told you otherwise, you can carry on as you like.'),
    scaleSetter: _en('This is a common worry and the answer is reassuring. '
        'For most couples, sex in the two-week wait and in early pregnancy '
        'is safe. The exceptions are specific, such as after an embryo '
        'transfer or if you are bleeding, and your clinic will tell you.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Once the window has passed, many women start to worry that '
              'sex could shake something loose. Some stop being close '
              'altogether until the test, just in case.'),
          _en('It is a loving instinct, and it comes from wanting to protect '
              'something that might be there. The good news is that there '
              'is no need.'),
          _en('This read explains what is happening inside your body in '
              'those days, why sex does not reach it, and the few times a '
              'doctor might ask you to hold off.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is happening in the days after ovulation?'),
        paragraphs: [
          _en('If an egg is fertilised, it spends several days travelling '
              'down the tube towards the womb, dividing as it goes. It '
              'usually settles into the lining somewhere around six to ten '
              'days after ovulation.'),
          _en('All of this happens high up, inside the tube and the womb. '
              'After ovulation, progesterone also makes the mucus at the '
              'cervix thick, which acts like a seal. Sex does not reach '
              'where implantation happens.'),
          _en('Some women notice light spotting or mild cramps around this '
              'time, and many notice nothing at all. Neither can tell you '
              'whether you are pregnant, and sex does not cause either.'),
        ],
      ),
      PvReadSection(
        heading: _en('Can sex or an orgasm dislodge it?'),
        paragraphs: [
          _en('No. An orgasm makes the womb tighten gently for a short '
              'while. There is no evidence that this harms implantation or '
              'an early pregnancy. The womb is built to hold on.'),
          _en('The NHS advises that sex is safe in pregnancy unless your '
              'doctor has told you otherwise. The same is true in the days '
              'before you know.'),
          _en('An early embryo is tiny and settles deep into the soft lining '
              'of the womb. Everyday movement, like climbing stairs, lifting '
              'a bucket or travelling, does not shake it loose either. Your '
              'body is designed to carry on with normal life.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Sex in the two-week wait can cause a miscarriage.'),
          fact: _en('Most early losses happen because of a chance mistake in '
              'the chromosomes of the embryo. Sex, orgasm, walking and normal '
              'daily work do not cause them.'),
        ),
      ),
      PvReadSection(
        heading: _en('Is there a reason to keep having sex after the window?'),
        paragraphs: [
          _en('Yes, a few. Any estimate of your ovulation can be off by a '
              'day or two, so sex in the days after can still cover a late '
              'ovulation. That is one reason the NICE guideline suggests sex '
              'every two to three days through the whole cycle.'),
          _en('It also keeps sex from being only about the window. Being '
              'close with no goal, in the waiting days, can make the next '
              'fertile days feel much lighter.'),
          _en('The waiting days are often the hardest part of the month. '
              'Many couples find that closeness, of any kind, helps them get '
              'through them. There is no reason to give that up.'),
        ],
      ),
      PvReadSection(
        heading: _en('What if I feel nervous about sex now?'),
        paragraphs: [
          _en('That is understandable, especially after a loss or a long '
              'time trying. Knowing something is safe does not always make '
              'the worry go away straight away.'),
          _en('You do not have to have sex in the waiting days if you would '
              'rather not. Choosing to wait is fine, as long as it is your '
              'choice and not fear of harming a pregnancy. Tell your partner '
              'what you feel, and find other ways to be close for now.'),
        ],
      ),
      PvReadSection(
        heading: _en('And once the test is positive?'),
        paragraphs: [
          _en('For most women, sex stays safe right through a healthy '
              'pregnancy. Your desire may change, though. Tiredness, nausea '
              'and tender breasts in the early weeks can make sex the last '
              'thing on your mind, and that is normal.'),
          _en('Some couples feel closer than ever, and others need a pause. '
              'Both are fine. If sex becomes painful, or you notice bleeding '
              'afterwards, tell your doctor.'),
        ],
      ),
      PvReadSection(
        heading: _en('When might a doctor ask you to wait?'),
        paragraphs: [
          _en('There are a few specific times, and your doctor or clinic '
              'will say so if one applies to you.'),
        ],
        bullets: [
          _en('After an embryo transfer in IVF. Some clinics advise no sex '
              'for a few days, or until the pregnancy test. Follow your '
              'clinic.'),
          _en('If you are bleeding in early pregnancy, until a doctor has '
              'checked you.'),
          _en('If your doctor has given you personal advice, for example '
              'after repeated losses.'),
          _en('If sex is painful. Pain is worth checking, whatever the '
              'timing, and a doctor can usually find out why.'),
        ],
      ),
      PvReadSection(
        heading: _en('What if I spot after sex?'),
        paragraphs: [
          _en('In early pregnancy the cervix has more blood flowing to it and '
              'can bleed a little after sex. Light spotting like this is '
              'often harmless.'),
          _en('It still deserves a call to your doctor, because only a check '
              'can tell you what is causing it. Bleeding with pain, or '
              'bleeding that soaks a pad, is more urgent.'),
          _en('Spotting after sex does not mean the sex caused a problem. '
              'Try not to blame yourselves. Let your doctor know, and follow '
              'their advice on whether to wait for a while.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('What you can let go of'),
          body: _en('You do not need to lie still, avoid orgasm or stop being '
              'close in the two-week wait. None of these has been shown to '
              'help an early pregnancy.'),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can sex bring my period on early?'),
        answer: _en('No. Your period comes when progesterone falls, on its '
            'own schedule. Sex does not change that.'),
      ),
      PvReadFaq(
        question: _en('Could sex in the waiting days change what a pregnancy '
            'test shows?'),
        answer: _en('No. A pregnancy test looks for hCG, a hormone made only '
            'after implantation. Sex and semen do not change the result.'),
      ),
      PvReadFaq(
        question: _en('Should I rest in bed after ovulation?'),
        answer: _en('There is no evidence that bed rest helps. Carry on with '
            'normal life, including walking, work and sex.'),
      ),
      PvReadFaq(
        question: _en('We had an IUI. Is sex okay afterwards?'),
        answer: _en('Most clinics say yes, but advice varies. Ask your clinic, '
            'and follow what they tell you.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Signs that need a hospital today'),
      body: _en('Go to hospital today if you have severe pain low on one side, '
          'pain in the tip of your shoulder, feel faint or dizzy, or bleed '
          'heavily, especially if your period is late or a test was '
          'positive. These can be signs of an ectopic pregnancy. For light '
          'spotting after sex in early pregnancy, call your doctor the same '
          'day or the next.'),
    ),
    evidence: _en('Safety of sex in early pregnancy follows the NHS page on '
        'sex in pregnancy. Causes of early loss follow the ACOG FAQ "Early '
        'Pregnancy Loss". Ectopic warning signs follow RCOG patient '
        'information on ectopic pregnancy. How often to have sex follows the '
        'NICE fertility guideline CG156. Timing of implantation follows '
        'StatPearls (NCBI Bookshelf). Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Can I...?'),
        value: _en('Quick answers on what is safe in the waiting days.'),
        surfaceId: 'ttc_can_i',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        // Kept for revert (2026-09-28, explicit names): title: _en("See this cycle's window"),
        title: _en("See this cycle's fertile window"),
        value: _en('Where you are in the month, and when to test.'),
        surfaceId: 'ttc_window',
      ),
    ],
    readNext: [
      'ttc_read_timing_myths',
      'ttc_read_keeping_close',
    ],
  ),

  // ===========================================================================
  //  6. Keeping closeness alive through the months
  // ===========================================================================
  //  Pack: Keeping intimacy fun (P1, shared with read 1), In a baby-making
  //  rut, Fitting in sex when you have kids (P3), 7 non-penetrative ideas
  //  (P3), Too tired for sex (P3), Feeling down after sex (P3).
  PvRead(
    id: 'ttc_read_keeping_close',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Keeping closeness alive through the months'),
    teaser: _en('Small, everyday ways to stay close as a couple when trying '
        'takes longer than you hoped.'),
    shortAnswer: _en('Closeness is kept alive by small things on ordinary '
        'days, not only by sex in the window. Touch with no goal, time '
        'without fertility talk, and a way to talk when it gets hard all '
        'help. If you keep drifting apart, a couples counsellor can help.'),
    scaleSetter: _en('Feeling further apart while trying is common, and it '
        'usually eases when you both make a little room for each other. '
        'It needs outside help only if you argue most days, one of you has '
        'withdrawn for weeks, or either of you feels low most of the time.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Trying for a baby is something you do together, and it can '
              'still leave you feeling alone. Months of waiting, tests and '
              'family questions can crowd out the two of you.'),
          _en('The closeness is still there. It often needs a little '
              'protecting, in small ways, on the days that have nothing to '
              'do with the window.'),
          _en('None of what follows takes much time or money. Pick what fits '
              'your home and your week, and leave the rest.'),
        ],
      ),
      PvReadSection(
        heading: _en("Why do we feel further apart when we're trying so hard?"),
        paragraphs: [
          _en('One reason is that you may cope in different ways. One of you '
              'wants to talk about it, and the other goes silent. Each can '
              'read the other as not caring, when both are hurting.'),
          _en('Another is that the goal takes over. When most conversations '
              'are about dates, tests and results, there is little room left '
              'for the things that made you a couple in the first place.'),
          _en('It helps to say this out loud to each other: "We are dealing '
              'with this differently, and that is okay." It turns a silent '
              'misunderstanding into something you can work on together.'),
        ],
      ),
      PvReadSection(
        heading: _en('How can we stay close without it being about sex?'),
        paragraphs: [
          _en('Small, regular things matter more than big gestures. A few '
              'minutes of full attention each day builds more closeness than '
              'one expensive dinner a month.'),
        ],
        bullets: [
          _en('Tea together, without phones, once a day, even if it is only '
              'ten minutes.'),
          _en('A short walk after dinner, even round the building.'),
          _en('Holding hands or sitting close while you watch something.'),
          _en('One evening a week with no fertility talk at all.'),
          _en('Something to look forward to that is only yours, like a '
              'film, a trip or a new place to eat.'),
          _en('Saying one kind thing you noticed about each other that day.'),
        ],
      ),
      PvReadSection(
        heading: _en('What are some ways to be close without intercourse?'),
        paragraphs: [
          _en('On the days outside the window, touch can be just for '
              'pleasure and comfort. Taking intercourse off the table for a '
              'while can bring desire back, because nothing has to happen.'),
          _en('Talk first about what each of you would like, and what is off '
              'limits for now. Go slowly, and let either of you stop at any '
              'point without it being a big deal.'),
        ],
        bullets: [
          _en('A slow oil massage, taking turns.'),
          _en('Lying close and talking in the dark.'),
          _en("Kissing that doesn't have to lead anywhere."),
          _en('Bathing together, if your home allows the privacy.'),
          _en('Touching each other in ways you both enjoy, including to '
              'orgasm, without intercourse.'),
          _en('Sensate focus, an exercise therapists use: you take turns '
              'touching each other slowly, with no aim except noticing how it '
              'feels.'),
        ],
      ),
      PvReadSection(
        heading: _en('How do we find time and privacy in a full house?'),
        paragraphs: [
          _en('Many couples in India live with parents, in-laws or small '
              'children, and privacy is hard to find. That can make the '
              'fertile days feel even more awkward.'),
          _en('A lock on the door, a fan or soft music, and an afternoon when '
              'others are out can all help. If you have children, early '
              'mornings or nap time may work better than late nights. An '
              'occasional night away, even nearby, can feel like a small '
              'holiday.'),
        ],
        tip: PvReadTip(
          title: _en('When one of you is too tired'),
          body: _en('Lower the bar. Lying together for ten minutes still '
              'counts as closeness. On tired nights, a cuddle and sleep is a '
              'perfectly good choice.'),
        ),
      ),
      PvReadSection(
        heading: _en('How do we handle family questions together?'),
        paragraphs: [
          _en('Questions about "good news" from relatives can land hard, and '
              'they often land on one of you more than the other. Being '
              'asked again and again can leave you both tense before you '
              'have even closed the bedroom door.'),
          _en('Decide together what you will share and with whom. Agree a '
              'short answer you both use, and let the partner whose family it '
              'is do most of the answering. Facing it as a team protects '
              'your closeness as much as anything in this read.'),
        ],
      ),
      PvReadSection(
        heading: _en('What if one of us feels like a failure?'),
        paragraphs: [
          _en('Many people feel their body is letting the other person down. '
              'Some stop wanting to be touched, or pull away to protect '
              'themselves. It is a common reaction, and it is not the truth '
              'about either of you.'),
          _en("If your partner seems to feel this way, tell them it isn't "
              'their fault and that you are in it together. If it is you, '
              'try saying it out loud. Very often, the other person has been '
              'waiting for a way in.'),
        ],
      ),
      PvReadSection(
        heading: _en('How do we talk about it without a fight?'),
        paragraphs: [
          _en('Pick a calm time, not in bed and not right after a period '
              'arrives. Then try these steps.'),
        ],
        bullets: [
          _en('1. Start with what you miss, not what is wrong.'),
          _en('2. Say "I feel" instead of "you always".'),
          _en('3. Ask what your partner needs, and listen to the end.'),
          _en('4. Agree one small thing to try this month.'),
          _en('5. Check in again in a week or two.'),
        ],
        tip: PvReadTip(
          title: _en('If the talk goes badly'),
          body: _en('Stop, and agree to come back to it another day. A '
              'conversation paused kindly is better than one pushed to the '
              'end in anger.'),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Sometimes I feel sad or cry after sex. Is that '
            'normal?'),
        answer: _en('It can happen, especially when sex carries a lot of '
            'hope and worry. It is often a release of feeling. If it happens '
            'every time, or with low mood on other days, talk to a doctor or '
            'counsellor.'),
      ),
      PvReadFaq(
        question: _en('Is it wrong to want sex that has nothing to do with a '
            'baby?'),
        answer: _en('Not at all. Wanting each other for your own sake is '
            'healthy, and it can make the trying months easier.'),
      ),
      PvReadFaq(
        question: _en('Should we take a break from trying?'),
        answer: _en("Some couples find a month off helps. If you're 35 or "
            "over, or you've been trying a long time, talk it through with "
            'your doctor first.'),
      ),
      PvReadFaq(
        question: _en('Do other couples feel this distant too?'),
        answer: _en('Yes, many do. It is one of the most common things '
            'couples tell fertility counsellors, and it usually improves '
            'with a little time set aside for each other.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get outside help'),
      body: _en('See a couples counsellor if you argue most days, if one of '
          'you has withdrawn for weeks, or if sex has stopped for months and '
          "it hurts either of you. If you've felt low most days for two weeks "
          'or more, see a doctor soon or call Tele-MANAS on 14416. If you '
          'ever feel unsafe or pushed into sex, call the women\'s helpline on '
          '181, or 112 in an emergency.'),
    ),
    evidence: _en('Support for couples follows the NICE fertility guideline '
        'CG156, which advises that counselling be offered, and the ESHRE '
        'guideline on routine psychosocial care in infertility (2015). '
        'Sensate focus follows Cleveland Clinic. Tele-MANAS is run by the '
        'Ministry of Health and Family Welfare, Government of India. Sources '
        'checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en("Today's practice"),
        value: _en('Five minutes, with a part to do together.'),
        surfaceId: 'ttc_ritual',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Bring your partner in'),
        value: _en('Share the plan so neither of you carries it alone.'),
        surfaceId: 'ttc_partner',
      ),
      // Kept for revert (2026-09-28, journal out of TTC): this next step opened the journal, which left the stage.
      // PvReadNextStep(
      //   kind: PvNextKind.tool,
      //   title: _en('Write it down'),
      //   value: _en('A private place for what is hard to say out loud.'),
      //   surfaceId: 'ttc_journal',
      // ),
    ],
    readNext: [
      'ttc_read_sex_homework',
      'ttc_read_bringing_him_in',
    ],
  ),
];
