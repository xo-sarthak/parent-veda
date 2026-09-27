// =============================================================================
//  Extra reads from the TTC gap plan — new pieces for doors that already exist
// -----------------------------------------------------------------------------
//  ⚠️ ONE FILE, SEVERAL DOORS, ON PURPOSE. Every other read file holds one
//  bracket. These are the gap-plan topics (docs/TTC-GAP-PLAN.md, stream A) that
//  needed a NEW read inside a door that already had its own file, written by a
//  helper working alongside the ones editing those files. Putting them in the
//  existing bracket files would have meant two people appending at the same
//  closing bracket, which is the merge hazard the split was made to remove.
//  Each read still carries its own door's kicker and hue, so where it lives on
//  disk changes nothing she sees. Moving one into its bracket file later is a
//  cut and paste.
//
//  ⚠️ THE AGGREGATOR IS STILL THE ONLY PUBLIC ENTRY POINT. Nothing outside
//  `ttc_reads_data.dart` should import this file — `kTtcReads`, `ttcReadById`
//  and `ttcReadTitle` stay where they were, so the shape and clinical tests
//  scan these reads like every other.
//
//  The rules these are written under are stated once, in the aggregator's
//  header, and the voice in `docs/TTC-VOICE.md`. Read both before adding one.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, ON PURPOSE — same reason as the other
// read files: one line per file keeps each file self-contained.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsExtra = [
  // ===========================================================================
  //  HIS SIDE — erection and ejaculation trouble under pressure
  // ===========================================================================
  //  Gap plan: His side (P2) "Erection or ejaculation trouble under pressure".
  //  Pack: his_side_talk ("How scheduled sex affects men").
  //
  //  ⚠️ WRITTEN FOR BOTH OF THEM, READ MOSTLY BY HER. "You" is the couple or
  //  her; he is "your partner" or "he". Never "tell him", never blame in either
  //  direction. No roster doctor covers male sexual health, so the byline is
  //  the desk and `reviewed` is false.
  PvRead(
    id: 'ttc_read_his_side_pressure',
    hue: 186,
    kicker: _en('His side'),
    title: _en('When sex is hard for him under pressure'),
    teaser: _en("Erection or ejaculation trouble in the fertile days is common, "
        "and it's usually about pressure, not his body. Here's what helps, and "
        'when to see a doctor.'),
    shortAnswer: _en("Trouble getting or keeping an erection, or finishing, is "
        'common once sex is tied to a calendar. It usually comes from the '
        "pressure, not a problem with his body, and it often eases when sex "
        "stops feeling like a test. If it happens most times, or outside the "
        'fertile days too, a doctor can help.'),
    scaleSetter: _en('This happens to many men once trying starts, and it '
        "rarely means anything is wrong with his body or his sperm. One hard "
        "night doesn't lose you the month, because the fertile window lasts "
        "several days. It's worth a doctor's visit if it keeps happening, but "
        "it isn't an emergency."),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Once you start trying, sex can change. It gets tied to a date '
              'on an app, and some nights it starts to feel like a task with '
              "a deadline. For many men, that's when their body stops "
              'cooperating.'),
          _en("If this is happening to you both, you're far from alone. "
              'Doctors who look after couples trying to conceive hear about '
              "it all the time. It's rarely talked about, so each couple "
              "thinks they're the only ones."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does pressure affect erections?'),
        paragraphs: [
          _en('An erection needs a relaxed body. Blood flows in when the '
              'nerves that calm you are in charge. Worry switches on the '
              'opposite system, the one that gets you ready to run. That '
              'system tightens blood vessels, so an erection is harder to get '
              'or keep.'),
          _en('So when a night feels like it has to go right, the worry itself '
              'gets in the way. One difficult night makes the next one feel '
              "bigger, and the loop tightens. None of it is a choice, and it "
              "isn't a sign of less love or less wanting."),
          _en('The same thing can happen with finishing. Some men find they '
              "can't ejaculate during sex in the fertile days, even though "
              'they can at other times. Others finish much sooner than usual. '
              'Both are common reactions to pressure.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is it pressure, or something in his body?'),
        paragraphs: [
          _en('Only a doctor can say for sure. But a few things tend to point '
              "towards pressure rather than a physical cause, and they're "
              'worth noticing before you worry.'),
        ],
        bullets: [
          _en("Erections are fine at other times of the month, when sex "
              "isn't about trying."),
          _en('He still wakes up with an erection on some mornings.'),
          _en('It started around the time you began trying or tracking.'),
          _en("Erections are fine when he's on his own."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Erection trouble can be an early health signal'),
          body: _en('Erections depend on healthy blood vessels. So trouble '
              'that keeps happening may be an early warning of diabetes or '
              'heart problems, sometimes years before anything else shows. '
              'A check of blood pressure and blood sugar is worth doing for '
              'that reason alone.'),
        ),
      ),
      PvReadSection(
        paragraphs: [
          _en('If the trouble happens every time, at any point in the month, '
              'or came on slowly over a year or two, that points more towards '
              'a physical cause.'),
          _en('Diabetes, high blood pressure, some medicines, smoking and '
              "heavy drinking can all play a part. That's a reason to see a "
              'doctor, not to panic. Many of these causes can be treated.'),
        ],
      ),
      PvReadSection(
        heading: _en('What takes the pressure off?'),
        paragraphs: [
          _en('The most useful change is to stop aiming at one night. The '
              "fertile window is about six days long. The UK's NICE guideline "
              'advises sex every two to three days through the cycle, which '
              'covers the window without anyone needing to know the exact '
              'date.'),
          _en("When there's no single night that matters, there's much less "
              'to perform for. Many couples find things ease once the date '
              'stops being announced. These steps help:'),
        ],
        bullets: [
          _en('Whoever tracks the dates can keep them loose. "This week" is '
              'enough, rather than "tonight".'),
          _en("Have sex outside the window too, for no reason at all. It "
              "reminds you both that it's still yours."),
          _en('Drop the extras, like legs up afterwards, special positions or '
              'a set time. None of them help.'),
          _en("If a night doesn't work, let it go and try again in a day or "
              'two. Nothing is lost.'),
          _en('Keep alcohol low. A drink may relax you, but more than a '
              'little makes erections harder.'),
        ],
        tip: PvReadTip(
          title: _en('Talk about it on an ordinary day'),
          body: _en('Not in bed, and not the morning after a hard night. Pick '
              'a calm moment, on a walk or over tea. Saying "this happens to '
              "lots of couples, let's make it easier\" goes a long way. Blame, "
              'in either direction, makes the next time harder.'),
        ),
      ),
      PvReadSection(
        heading: _en('What can a doctor do?'),
        paragraphs: [
          _en('A family doctor, a urologist or an andrologist (a doctor for '
              "men's reproductive health) can help. The first visit is "
              'usually a conversation, a blood pressure check and a few blood '
              'tests, such as sugar and sometimes hormones.'),
          _en('Tablets that help erections, such as sildenafil or tadalafil, '
              'work well for many men and are often used by couples who are '
              "trying. They need a prescription. They aren't safe with some "
              'heart medicines called nitrates, so a doctor should check '
              'first.'),
          _en('Please avoid "sex power" products sold online or by the '
              'roadside. Regulators have found hidden prescription drugs in '
              'some of them, at unknown doses. They can be risky, especially '
              'for anyone with a heart problem.'),
          _en('Talking to a counsellor or sex therapist helps too, especially '
              "when pressure is the cause. It's usually a few sessions, often "
              'with both of you. Your gynaecologist or fertility clinic can '
              'suggest someone.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('If sex in the window stays hard'),
          body: _en('There are other ways to get sperm where they need to be. '
              'A doctor may suggest IUI, a short clinic procedure where a '
              "sample is placed in the womb. It's a recognised option for "
              'couples who find sex difficult for any reason, and it takes '
              'the pressure off completely.'),
        ),
      ),
      PvReadSection(
        // Open, not folded: His side reads never start folded
        // (ttc_his_side_test), so nothing he came for is hidden.
        heading: _en('What about other ejaculation problems?'),
        bullets: [
          _en("Finishing sooner than you'd both like doesn't stop a "
              'pregnancy, as long as it happens inside the vagina.'),
          _en("Not being able to finish during sex, while it's fine at other "
              'times, is often pressure. A doctor can help if it keeps '
              'happening.'),
          _en('An orgasm with little or no fluid, or cloudy urine afterwards, '
              'can mean semen is going backwards into the bladder. This can '
              'happen with diabetes, after some operations or with some '
              'medicines, and it can often be treated.'),
          _en('Pain when ejaculating, or blood in the semen, needs a '
              "doctor's visit."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does erection trouble mean his sperm are poor?'),
        answer: _en('No. Erections and sperm come from different systems. A '
            'man can have trouble with erections and normal sperm, or the '
            'other way round. A semen analysis is the only way to check '
            'sperm.'),
      ),
      PvReadFaq(
        question: _en("Is it because he doesn't find me attractive any more?"),
        answer: _en('Almost never. Pressure affects the body whatever he '
            'feels. Many men say the more they want it to go well, the harder '
            "it gets. It's worth hearing that from him, in a calm moment."),
      ),
      PvReadFaq(
        question: _en('Are erection tablets safe while we are trying?'),
        answer: _en("They aren't known to harm a pregnancy, and many couples "
            'use them while trying. Ask the doctor who prescribes them, and '
            "say you're trying, so they can check his other medicines too."),
      ),
      PvReadFaq(
        question: _en('Should we take a break from trying?'),
        answer: _en('Some couples find a month off the calendar helps a lot. '
            "You can still have sex, just without tracking. If you're 35 or "
            'over, or have been trying a while, talk to your doctor before a '
            'long break, because time counts too.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en('Book a visit if erection or ejaculation trouble happens most '
          "times for more than a few weeks, if it's there at any time of the "
          'month, or if there is pain, a new bend in the penis, blood in the '
          'semen, or little or no fluid when he finishes. Go to a hospital '
          'straight away if an erection lasts more than four hours, or if '
          'there is chest pain during or after sex.'),
    ),
    evidence: _en('Sex every two to three days follows the NICE fertility '
        'guideline CG156, which also names IUI as an option for couples who '
        'find intercourse very difficult. The link between erection trouble, '
        'blood vessel health and diabetes, and the use and safety of '
        'erection tablets, follow the NHS pages on erectile dysfunction and '
        'Cleveland Clinic. Semen going backwards into the bladder follows '
        'StatPearls (NCBI) on retrograde ejaculation. Hidden medicines in '
        'sexual enhancement products follow warnings from the US Food and '
        'Drug Administration. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Bring your partner in'),
        value: _en("A shared view of the month, so the dates aren't one "
            "person's job."),
        surfaceId: 'ttc_partner',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a specialist'),
        value: _en('A private conversation about what is going on, and what '
            'would help.'),
        surfaceId: 'ttc_prepare',
      ),
    ],
    readNext: [
      'ttc_read_timing_myths',
      'ttc_read_bringing_him_in',
      'ttc_read_whose_side',
    ],
  ),

  // ===========================================================================
  //  HIS SIDE — his age
  // ===========================================================================
  //  Pack: his_side_understand, "How does age affect male fertility?" (P2,
  //  new) and "How does your partner's reproductive function change with
  //  age?" (P3, same topic). Before this the only line on it was one FAQ in
  //  `ttc_read_whose_side`. Population facts only, never a figure for them.
  PvRead(
    id: 'ttc_read_his_age',
    hue: 186,
    kicker: _en('His side'),
    title: _en('Does his age affect getting pregnant?'),
    teaser: _en("A man's fertility changes with age too, more slowly than a "
        "woman's. Here's what changes, from when, and what it means for you "
        'both.'),
    shortAnswer: _en('Yes, a little, and slowly. From around 40, sperm tend to '
        'move less well and carry more DNA damage, and couples may take a bit '
        "longer to conceive. The effect is much smaller than a woman's age, "
        'and most older fathers have healthy babies.'),
    scaleSetter: _en("His age matters less than yours does, and it changes "
        "slowly, not all at once. There's no cut-off age for a man. If he's "
        "over 40, it's a reason to check his side early, not a reason to "
        'worry.'),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Most talk about age and fertility is about women. So many '
              "couples assume a man's age doesn't count at all. It does, a "
              'little. Knowing how much helps you plan, and it shares the '
              'load more fairly.'),
          _en("Men make new sperm all their lives, so there's no sudden stop "
              'like menopause. What changes is the quality, slowly, over many '
              'years.'),
        ],
      ),
      PvReadSection(
        heading: _en('What changes as men get older?'),
        paragraphs: [
          _en('Studies of healthy men find a slow drift, not a drop. It tends '
              'to show from around 40, and more clearly after 45 or 50.'),
        ],
        bullets: [
          _en('Semen volume goes down a little.'),
          _en('Sperm move less well, and movement matters more than count.'),
          _en("More sperm carry damaged DNA. A standard semen test can't see "
              'this.'),
          _en('Testosterone falls slowly, which can lower desire and make '
              'erections less reliable for some men.'),
          _en('Health problems that affect fertility, like diabetes, high '
              'blood pressure and weight gain, become more common, and so do '
              'the medicines for them.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('Each change on its own is small. Together, they add up to a '
              'gentle slope rather than a cliff.'),
          _en('Men also vary a lot. Some men of 50 have better semen results '
              'than some men of 30, because health and habits count as well '
              'as the years.'),
        ],
        mythFact: PvMythFact(
          myth: _en("A man can father a child at any age, so his age doesn't "
              'matter.'),
          fact: _en('Men can father children late in life, and many do. But '
              'sperm quality still changes with age. That is one reason his '
              'half is worth checking early rather than last.'),
        ),
      ),
      PvReadSection(
        heading: _en('Does it make getting pregnant take longer?'),
        paragraphs: [
          _en("On average, a little. Studies that allow for the woman's age "
              'still find that couples take longer to conceive when the man '
              "is over 40 or 45 than when he's younger."),
          _en('These numbers are about large groups of couples. They say '
              'nothing about the two of you. Plenty of men in their forties '
              'and fifties become fathers without any delay at all.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Your age still counts for more'),
          body: _en('When you are both older, the woman\'s age is usually the '
              'bigger factor, because eggs change faster than sperm do. His '
              "age adds to the picture. It doesn't replace it."),
        ),
      ),
      PvReadSection(
        heading: _en("What about the baby's health?"),
        paragraphs: [
          _en('This is the question many couples worry about and rarely ask. '
              "The honest answer is that some risks rise slightly with a "
              "father's age, and they stay low."),
          _en('Children of older fathers, mostly over 45 or 50, have a '
              'slightly higher chance of a few rare genetic conditions. There '
              'are also small rises in the chance of miscarriage and of some '
              'conditions such as autism. For each one, most babies are not '
              'affected.'),
          _en("There's no routine test before pregnancy based on a father's "
              'age alone. The usual pregnancy scans and screening are offered '
              "to everyone. If you're worried, your doctor can talk it "
              'through, or suggest a genetic counsellor.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does this mean for the two of you?'),
        paragraphs: [
          _en('When a couple takes longer than they hoped, the woman is often '
              'the first and only one checked. His age is one more reason that '
              'order makes little sense. You both play a part in how long it '
              'takes, and you can both be checked.'),
          _en("None of this is about blame. Age isn't anyone's fault, and "
              'neither is a test result. Knowing the facts means neither of '
              'you has to carry the whole question alone.'),
          _en("If there's a big age gap between you, say so to your doctor at "
              'the first visit. It helps them decide which tests to do first, '
              'and how soon to do them.'),
        ],
      ),
      PvReadSection(
        heading: _en('What can he do about it?'),
        paragraphs: [
          _en('Nothing turns back age. What he can change are the things '
              'that add to it, and they matter more as he gets older.'),
        ],
        bullets: [
          _en('Stop tobacco in every form, including gutka and khaini.'),
          _en('Keep alcohol low.'),
          _en('Work towards a healthy weight, and stay active.'),
          _en('Avoid long spells of heat, like hot tubs, saunas or a laptop '
              'on the lap.'),
          _en('Get blood sugar and blood pressure checked, and treated if '
              'needed.'),
          _en('Check with a doctor before taking testosterone or bodybuilding '
              'supplements. Testosterone taken from outside can switch off '
              'sperm production.'),
        ],
        tip: PvReadTip(
          title: _en('Changes take about three months to show'),
          body: _en('Sperm take around three months to make. So a change '
              'started today shows up in a semen test about three months '
              "from now. It's a good reason to start with the test, then "
              'the changes, then the repeat.'),
        ),
      ),
      PvReadSection(
        heading: _en('When should he get tested?'),
        paragraphs: [
          _en("If he's 40 or over, there's a good case for a semen analysis "
              'early, at the same time as your first tests. It is quick, '
              'cheap and private, and it answers a question that otherwise '
              'waits for months.'),
          _en('The sample is given in private at a lab, after two to seven '
              'days without ejaculating. Results usually come back within a '
              'few days.'),
          _en('A normal result is reassuring, though it can\'t measure DNA '
              'damage. A result below the usual range is almost always '
              'repeated after about three months before anyone decides '
              'anything, because one sample can vary a lot.'),
          _en("If you're planning to wait several years before trying, some "
              "men choose to freeze sperm while they're younger. It isn't "
              'needed for most people. It is worth a conversation with a '
              'doctor if the wait will be long, or if a treatment like '
              'chemotherapy is coming.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('At what age is a man "older" for fertility?'),
        answer: _en("There's no agreed age. Many doctors use 40, and some use "
            "45 or 50. It's a slow change, so any cut-off is only a rough "
            'guide.'),
      ),
      PvReadFaq(
        question: _en("He's much older than me. Should we see a doctor "
            'sooner?'),
        answer: _en("The usual advice is a year of trying if you're under 35. "
            'Many doctors are happy to see you sooner when the man is older, '
            'and a semen test can be done at any time. Asking early is always '
            'reasonable.'),
      ),
      PvReadFaq(
        question: _en('He already has a child. Does his age still matter?'),
        answer: _en('Yes. A child from years ago shows his sperm were fine '
            'then. Age, weight, health and medicines can all have changed '
            'things since. A fresh test gives a current answer.'),
      ),
      PvReadFaq(
        question: _en('Can supplements make older sperm younger?'),
        answer: _en('No supplement reverses age. Some antioxidants are sold '
            'for DNA damage, and the evidence for them is weak and mixed. '
            'Stopping tobacco and keeping a healthy weight do more.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See a doctor after a year of trying (six months if you're 35 "
          'or over). Go sooner, without waiting, if he has had surgery on the '
          'testes or groin, mumps that affected the testes after puberty, or '
          'chemotherapy, has trouble with erections or ejaculation, or takes '
          'testosterone or anabolic steroids. A lump or swelling in a testis '
          "should be checked by a doctor soon, even if it doesn't hurt."),
    ),
    evidence: _en('Changes in semen with age and the longer time to pregnancy '
        'with older fathers follow the ASRM committee opinion on optimising '
        'natural fertility (2022) and StatPearls (NCBI) on male infertility. '
        'Genetic and pregnancy risks with older fathers follow ACOG and '
        'Cleveland Clinic. Testosterone switching off sperm production '
        'follows the American Urological Association and ASRM guideline on '
        'infertility in men (2020). When to seek help follows the NICE '
        'fertility guideline CG156. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The test library'),
        value: _en('What a semen analysis checks, and how to book one.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to an andrologist'),
        value: _en('A specialist can say what his age means alongside his '
            'own results.'),
        surfaceId: 'ttc_prepare',
      ),
    ],
    readNext: [
      'ttc_read_case_for_testing',
      'ttc_read_heat_habits',
      'ttc_read_semen_analysis',
    ],
  ),

  // ===========================================================================
  //  FERTILE WINDOW — ovulation tests with irregular cycles
  // ===========================================================================
  //  Pack: fertile_window_your_window. Covers the two P1 items (testing with
  //  irregular cycles; which day to start) and the P2 pair (negatives for
  //  several cycles; false positives), plus the P3 twice-a-day tip. The
  //  general kits read, `ttc_read_ovulation_kits`, stays the "do they help?"
  //  piece; this one is the how-to for a cycle that moves.
  PvRead(
    id: 'ttc_read_ovulation_tests_irregular',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Ovulation tests when your cycles are irregular'),
    teaser: _en('When to start, how often to test, and what it means when the '
        'strips stay negative or keep turning positive.'),
    shortAnswer: _en('Start from your shortest recent cycle, not your average. '
        'Take 17 away from it and begin testing on that day, then keep going '
        'until you get a positive or your period comes. If strips stay '
        'negative for three cycles, or turn positive again and again, see a '
        'doctor rather than buying more.'),
    scaleSetter: _en('Irregular cycles make ovulation tests harder to use, not '
        'useless. Many women with irregular cycles do ovulate, just on a day '
        "that moves. A run of confusing strips isn't a verdict on your "
        "fertility. It's often a sign that a doctor's test would tell you "
        'more.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Ovulation tests are sold as if every cycle were 28 days. The '
              'leaflet says to start on day ten or eleven. If your cycles are '
              '32 days one month and 45 the next, that advice fits badly, and '
              'you can use up a whole pack before anything happens.'),
          _en("Here's a way of using them that fits a cycle that moves "
              'around.'),
        ],
      ),
      PvReadSection(
        heading: _en('What counts as irregular?'),
        paragraphs: [
          _en('Most cycles vary a little. A difference of up to 7 to 9 days '
              'between your shortest and longest cycle is still normal. '
              'Irregular usually means more than that, or cycles shorter than '
              '21 days or longer than 35.'),
          _en('The part that moves is the stretch from your period to '
              'ovulation. The second half, from ovulation to your period, '
              'usually stays close to 14 days. So a long cycle usually means '
              'a late ovulation, not a missing one.'),
          _en('Logging your dates for a few months shows how much your own '
              'cycle moves.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which day should I start testing?'),
        paragraphs: [
          _en('Look back at your last six cycles, or as many as you have, and '
              'find the shortest one. Take 17 away from that number. That is '
              'the cycle day to start testing, counting the first day of your '
              'period as day one.'),
        ],
        bullets: [
          _en('Shortest cycle 26 days: start on day 9.'),
          _en('Shortest cycle 30 days: start on day 13.'),
          _en('Shortest cycle 35 days: start on day 18.'),
        ],
        tip: PvReadTip(
          title: _en('Let your body tell you when to test harder'),
          body: _en('Watch for wet, clear, stretchy discharge, like raw egg '
              'white. It usually shows up in the days before ovulation. When '
              "you see it, that's the time to test carefully, twice a day if "
              'you can.'),
        ),
      ),
      PvReadSection(
        paragraphs: [
          _en("Using the shortest cycle means you're unlikely to miss an "
              'early ovulation. The cost is more strips in the longer months. '
              'Keep testing each day until you get a positive or your period '
              'starts.'),
          _en("If you've only logged one or two cycles, use the shorter one "
              'for now. As the months go by, you may see a rough pattern, and '
              'that can let you start a little later and use fewer strips.'),
        ],
      ),
      PvReadSection(
        heading: _en('How often, and at what time?'),
        paragraphs: [
          _en('Once a day is enough for many people. With irregular cycles, '
              'testing twice a day around the likely days catches more short '
              'rises of LH, the hormone that triggers ovulation. Some rises '
              'last less than a day and fall between two tests.'),
        ],
        bullets: [
          _en('Test between late morning and evening. First-morning urine is '
              'best for pregnancy tests, not for these.'),
          _en('If you test twice, leave about 10 to 12 hours between tests.'),
          _en("Try not to drink a lot for two hours before. It dilutes your "
              'urine and can hide a rise.'),
          _en("Read the result at the time the leaflet says. A line that "
              "appears later doesn't count."),
          _en('A positive means the test line is as dark as the control line, '
              'or darker. A faint line is a negative.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Plain strips are fine'),
          body: _en('Buy plain strips in bulk packs rather than branded kits. '
              'They test the same hormone and cost far less per strip, which '
              'matters when a cycle can run to 40 days or more.'),
        ),
      ),
      PvReadSection(
        heading: _en('Why do my strips stay negative?'),
        paragraphs: [
          _en('A few cycles of negatives is common with irregular cycles, and '
              'there are several possible reasons. Some are about the strips, '
              'and some are about your cycle.'),
        ],
        bullets: [
          _en('The rise was short and fell between two tests.'),
          _en('You stopped testing too early in a long cycle.'),
          _en('Your urine was diluted when you tested.'),
          _en('The strips were past their date, or kept somewhere hot or '
              'damp.'),
          _en("You didn't ovulate that cycle. This happens now and then to "
              'everyone, and more often with PCOS, thyroid problems, high '
              'prolactin, a big change in weight, or in the first months '
              'after stopping the pill.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('One negative cycle tells you very little. Three in a row, '
              'tested properly, are worth taking to a doctor. A blood test can '
              'show whether you are ovulating.'),
        ],
        mythFact: PvMythFact(
          myth: _en('A positive ovulation test means I ovulated.'),
          fact: _en('It means LH rose. Most of the time ovulation follows '
              'within a day or two, but not always, and less reliably when '
              'cycles are irregular. Only a blood test or a scan can confirm '
              'it.'),
        ),
      ),
      PvReadSection(
        heading: _en('What if they keep turning positive?'),
        paragraphs: [
          _en('Some women see positive or nearly positive lines on many days, '
              'or more than once in a cycle. This is common with PCOS, where '
              'LH can stay high for long stretches. It also happens when the '
              "body gets ready to ovulate, doesn't, and tries again later."),
          _en("In cycles like these, a positive can't tell you when ovulation "
              "happens, or whether it does. The strips aren't faulty. They're "
              'the wrong tool for that cycle. Sex every two to three days all '
              'through the cycle works better, with a doctor to confirm '
              'ovulation.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en("The blood test and scans that confirm ovulation when "
            "strips can't."),
        heading: _en('How can a doctor check ovulation?'),
        paragraphs: [
          _en('The usual test is a progesterone blood test, taken about seven '
              'days before your next period. Progesterone rises after '
              'ovulation, so a high level shows it happened. With irregular '
              'cycles, your doctor may repeat it weekly until your period '
              'comes, because the right day is hard to guess.'),
          _en('Some doctors use a series of scans instead, to watch a follicle '
              'grow and release its egg. Your doctor may also check thyroid, '
              'prolactin and other hormones, to find out why your cycles '
              'vary.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I skip the strips altogether?'),
        answer: _en('Yes. Sex every two to three days through the whole cycle '
            'covers ovulation whenever it happens, with no testing at all. '
            'Many doctors suggest this for irregular cycles, because it takes '
            'the guessing away.'),
      ),
      PvReadFaq(
        question: _en('Do digital tests work better if I have PCOS?'),
        answer: _en('Not really. They measure the same hormone. Some also '
            'track a second hormone, and they can still give confusing '
            "results with PCOS. They're easier to read, but they don't solve "
            'the problem of high LH.'),
      ),
      PvReadFaq(
        question: _en('My period is late and my ovulation test is positive. '
            'Am I pregnant?'),
        answer: _en('Maybe, maybe not. The pregnancy hormone can make some '
            'ovulation strips turn positive, but so can a late LH rise in a '
            "long cycle. Take a pregnancy test instead. It's the only strip "
            'that answers that question.'),
      ),
      PvReadFaq(
        question: _en('How many strips should I buy?'),
        answer: _en('Enough for about three weeks of testing each cycle, more '
            'if you test twice a day. Bulk packs of plain strips keep this '
            'affordable.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor rather than buy more strips'),
      body: _en('Book a visit if your cycles are shorter than 21 days or '
          'longer than 35, if they change by more than 7 to 9 days, if '
          "you've tested properly for three cycles without a clear positive, "
          "or if your periods stop for three months and you're not pregnant. "
          'Go sooner if you also notice new hair on your face or body, a milky '
          'discharge from your nipples, or very heavy bleeding. With '
          "irregular cycles, you don't need to wait a year of trying before "
          'you ask.'),
    ),
    evidence: _en('The normal range for cycle length and variation follows '
        'ACOG Committee Opinion 651, "Menstruation in girls and adolescents: '
        'using the menstrual cycle as a vital sign". Sex every two to three '
        'days and the repeated progesterone test for irregular cycles follow '
        'the NICE fertility guideline CG156. How LH tests work, and why they '
        'mislead with PCOS, follow the ASRM committee opinion on optimising '
        'natural fertility (2022) and Cleveland Clinic. '
        'Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log your cycle lengths'),
        value: _en('Your shortest cycle is the number this whole method starts '
            'from.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Note your ovulation tests'),
        value: _en('A few cycles of results is exactly what a doctor will ask '
            'to see.'),
        surfaceId: 'ttc_ovulation',
      ),
    ],
    readNext: [
      'ttc_read_ovulation_kits',
      'ttc_read_pcos_ovulation',
      'ttc_read_pcos_irregular',
    ],
  ),

  // ===========================================================================
  //  GETTING READY — a past abortion
  // ===========================================================================
  //  Pack: getting_ready_before_you_start, "Getting pregnant after an
  //  abortion" (P2, new). Non-judging, reassuring first, then the three
  //  complications that do matter. Indian law stated as fact (MTP Amendment
  //  Act 2021, confidentiality).
  PvRead(
    id: 'ttc_read_after_abortion',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Can a past abortion affect getting pregnant?'),
    teaser: _en('What the evidence says about an earlier abortion and your '
        'fertility now, what to tell your doctor, and the few things worth '
        'checking.'),
    shortAnswer: _en("For most women, no. A safe abortion, with pills or a "
        "procedure by a trained doctor, doesn't make it harder to get "
        'pregnant later. Rarely, an infection or scarring afterwards can '
        'affect fertility, and a doctor can check for that.'),
    scaleSetter: _en('Many women carry this worry for years without saying it '
        "out loud. The evidence is reassuring: a safe abortion doesn't harm "
        'future fertility. There are a few signs worth a check, and they are '
        'listed below. Nothing here is a judgement about a choice you made.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("If you've had an abortion before, you may wonder whether it's "
              "the reason things are taking time. It's one of the most common "
              'worries women keep to themselves, often because they fear '
              'being judged.'),
          _en('You deserve a straight answer, so here it is, with the few '
              'exceptions explained.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does an abortion affect future fertility?'),
        paragraphs: [
          _en("A safe abortion doesn't lower your fertility. This is true for "
              'abortion with medicines and for a procedure done by a trained '
              "doctor. Guidelines from WHO and the UK's NICE agree on this."),
          _en("Having had more than one abortion doesn't change this on its "
              'own. What matters is whether there were complications, and the '
              'section below covers those.'),
          _en("Your body gets back to its usual rhythm quickly. Ovulation can "
              'return as soon as two weeks after an early abortion, often '
              'before your first period. So you can get pregnant again before '
              'a period comes.'),
          _en("If you're trying now and it's taking a while, the abortion is "
              'very unlikely to be the reason. Most couples take several '
              'months, and the usual causes are the same for everyone.'),
        ],
      ),
      PvReadSection(
        heading: _en('When can it make a difference?'),
        paragraphs: [
          _en('Problems are uncommon, and they come from complications, not '
              "from the abortion itself. They're more likely if the abortion "
              "wasn't done by a trained provider, or if an infection went "
              'untreated.'),
        ],
        bullets: [
          _en('An infection afterwards that spread to the tubes. This can '
              'scar them. Fever, pain and a bad-smelling discharge in the '
              'weeks after are the usual signs.'),
          _en("Scarring inside the womb, called Asherman's syndrome. It's "
              'rare, and more likely after more than one procedure that '
              'scraped the lining, or after an infection. Periods that became '
              'much lighter, or stopped, after the procedure are the main '
              'clue.'),
          _en('Tissue left behind, which is more likely when pills were taken '
              "without a doctor's care. It usually causes long or heavy "
              'bleeding afterwards and is easy to treat.'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('If none of these happened to you, a past abortion almost '
              'certainly has nothing to do with how long this is taking.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('If one of these did happen'),
          body: _en('Each can be checked, and most can be treated. The tubes '
              'can be checked with an X-ray test called an HSG. Scarring '
              'inside the womb can be seen with a small camera, and is often '
              'removed in the same procedure. Knowing is better than '
              'wondering.'),
        ),
      ),
      PvReadSection(
        heading: _en('What if the abortion was recent?'),
        paragraphs: [
          _en('Give your body a little time. Bleeding usually settles within '
              'about two weeks, and your next period tends to come four to six '
              'weeks after the abortion.'),
          _en('If you were asked to do a pregnancy test or have a check a few '
              "weeks later, please do it. It's how you and your doctor know "
              'the abortion is complete.'),
          _en('Some abortions end a pregnancy that was wanted, because of a '
              "health problem in the baby or in the mother. If that's what "
              'happened to you, the grief is real. Our After a loss reads may '
              'help too.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does it matter for a future pregnancy?'),
        paragraphs: [
          _en("Mostly, no. A past abortion doesn't raise the chance of "
              'miscarriage in a later pregnancy.'),
          _en('Some studies find a small rise in the chance of an early birth '
              "after several surgical abortions. It's a small difference, and "
              "your doctor can keep an eye on it. It's one more reason to "
              'mention it at your first pregnancy visit.'),
          _en('If your blood group is negative, like O negative or B '
              'negative, tell your doctor whether you had an injection called '
              "anti-D at the time. It protects later pregnancies. If you "
              "didn't, a blood test can check whether it matters now."),
        ],
      ),
      PvReadSection(
        heading: _en('Should I tell my doctor?'),
        paragraphs: [
          _en('Yes, it helps. Your doctor needs your full history to read '
              'your tests and plan your care. They see this every day, and a '
              "good doctor won't judge you."),
          _en('If you took pills bought without a prescription, say so. It '
              "isn't about blame. It tells the doctor what is worth "
              'checking.'),
          _en('In India, the Medical Termination of Pregnancy (Amendment) '
              "Act, 2021 says a doctor mustn't reveal the name or details of "
              'a woman who has had an abortion, except to someone the law '
              'allows. It stays between you and your doctor.'),
          _en("You don't have to tell family members. Whether you tell your "
              'partner is your choice.'),
        ],
        tip: PvReadTip(
          title: _en('What to say'),
          body: _en("You don't need to explain why. \"I had an abortion in "
              '2019, with pills, at about seven weeks, and no problems '
              'afterwards" is all a doctor needs. Add anything unusual, like '
              'an infection or heavy bleeding.'),
        ),
      ),
      PvReadSection(
        heading: _en('What about the feelings?'),
        paragraphs: [
          _en('Some women feel settled about a past abortion. Others find it '
              'comes back when they start trying, as guilt, sadness or a fear '
              'of being punished. All of these are normal, and none of them '
              "affect your body's ability to get pregnant."),
          _en("If it's weighing on you, a counsellor can help. It's a safe "
              'place to say what you feel, without anyone else knowing.'),
          _en('And if the worry keeps coming back while you wait, bring it to '
              'your doctor too. Hearing "this is not the reason" from someone '
              'who knows your history can settle it.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en("Could an abortion years ago be why I can't get "
            'pregnant now?'),
        answer: _en("It's very unlikely, unless there was an infection or "
            "scarring afterwards. It's still worth telling your doctor, so "
            'they can rule it out and look for the more common reasons.'),
      ),
      PvReadFaq(
        question: _en('Were pills safer for my fertility than a procedure?'),
        answer: _en('Both are safe for future fertility when done properly. '
            'Scarring inside the womb is linked mainly to procedures that '
            'scraped the lining, especially more than once.'),
      ),
      PvReadFaq(
        question: _en('How long should I wait to try after an abortion?'),
        answer: _en('Your body can be ready quickly. WHO has suggested waiting '
            'at least six months before the next pregnancy, and some doctors '
            'are more flexible. Ask yours, and give yourself time to feel '
            'ready too.'),
      ),
      PvReadFaq(
        question: _en('Will a scan show that I had an abortion?'),
        answer: _en('Usually not. An abortion without complications leaves '
            'nothing a scan would pick up. Telling your doctor is still '
            'better, because it helps them understand your history.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor, and when to go today'),
      body: _en("Go to a hospital today if, after a recent abortion, you're "
          'soaking through two pads an hour for two hours in a row, have a '
          'fever, a bad-smelling discharge or severe pain in your belly, or '
          'feel faint. Book a visit, not urgently, if your periods became '
          'much lighter or stopped after an abortion, if you had an infection '
          "afterwards, or if you've been trying for a year (six months if "
          "you're 35 or over)."),
    ),
    evidence: _en('That a safe abortion does not reduce later fertility, and '
        'the rare complications, follow the WHO Abortion care guideline '
        '(2022) and the NICE guideline on abortion care, NG140 (2019). '
        'Recovery times follow the NHS. The '
        'small link with early birth follows RCOG. Scarring inside the womb '
        "follows StatPearls (NCBI) on Asherman's syndrome. The six-month "
        'interval follows the WHO technical consultation on birth spacing '
        '(2005). Confidentiality follows the Medical Termination of Pregnancy '
        '(Amendment) Act, 2021. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your history in one place'),
        value: _en('Old reports and dates, ready for the doctor who asks.'),
        surfaceId: 'ttc_records',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a gynaecologist'),
        value: _en('A private conversation about your history and what, if '
            'anything, is worth checking.'),
        surfaceId: 'ttc_prepare',
      ),
    ],
    readNext: [
      'ttc_read_first_gyn_visit',
      'ttc_read_preconception_tests',
      'ttc_read_when_to_seek_help',
    ],
  ),

  // ===========================================================================
  //  GETTING READY — money before a baby, in India
  // ===========================================================================
  //  Pack: getting_ready_before_you_start, "why start thinking about money?"
  //  (P2, new), with "Money hacks" (P3) and "Not sure if you're ready?" (P3)
  //  folded in. Indian rules stated as facts with a pointer to HR and the
  //  health centre. No roster doctor covers money, so the desk signs it.
  PvRead(
    id: 'ttc_read_money_before_baby',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Money before a baby: what to sort out now'),
    teaser: _en('Health insurance waiting periods, maternity leave, '
        'government help and a few honest questions, written for India.'),
    shortAnswer: _en('Check your health insurance first, because many Indian '
        'policies only cover delivery after a waiting period of two to four '
        'years. Then find out your maternity leave, look at what the '
        'government offers, and start a small monthly saving.'),
    scaleSetter: _en("You don't need to be rich to have a baby, and you don't "
        'need everything sorted before you start. Most of this is a few '
        "checks and one or two decisions. The one thing that can't wait is "
        'health insurance, because its waiting period starts from the day you '
        'buy it.'),
    author: _en('ParentVeda team'),
    authorRole: _en('Written from the sources listed at the end'),
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Money isn't the first thing you think of when you're trying. "
              'But in India, some of the biggest costs of having a baby '
              "depend on choices you can only make before you're pregnant. "
              'Health insurance is the main one.'),
          _en("Here's what is worth doing now, in the order it matters."),
        ],
      ),
      PvReadSection(
        heading: _en('Does my health insurance cover having a baby?'),
        paragraphs: [
          _en('Many individual and family health policies in India cover '
              'maternity only after a waiting period. Two to four years is '
              "common. Some policies don't cover it at all, and some cap it at "
              'a set amount per delivery.'),
          _en("If you buy a policy after you're pregnant, that pregnancy is "
              "usually not covered. That's why this is the one item on the "
              'list with a clock on it. Read the policy wording itself, not '
              'only the brochure, and check these points:'),
        ],
        bullets: [
          _en('Is maternity covered, and after how long a waiting period?'),
          _en("What's the limit for a normal delivery, and for a caesarean?"),
          _en('Is the newborn covered from birth, and for how long?'),
          _en('Are checkups and scans in pregnancy covered, or only the '
              'hospital stay?'),
          _en('Is fertility treatment covered? Most policies list it as not '
              'covered, though a few now include some cover.'),
        ],
        tip: PvReadTip(
          title: _en('Check your work policy first'),
          body: _en('Group policies from employers often cover maternity from '
              'the first day, with no waiting period, up to a set limit. Ask '
              "HR for the policy document, and check whether your spouse's "
              'employer policy covers you too.'),
        ),
      ),
      PvReadSection(
        heading: _en('What maternity leave can I get?'),
        paragraphs: [
          _en('Under the Maternity Benefit Act, 1961, as amended in 2017, '
              'women working in places with ten or more employees can get 26 '
              'weeks of paid leave for each of their first two children. For '
              'a third child, it is 12 weeks.'),
          _en('You usually need to have worked at least 80 days in the 12 '
              'months before your due date. Your company policy will have the '
              'details, and some offer more than the law asks.'),
          _en("There's no law on paternity leave for private jobs. Central "
              'government employees get 15 days. Many companies now offer '
              "some paternity leave, so it's worth asking early."),
          _en('The 2017 changes also ask workplaces with 50 or more employees '
              'to provide a crèche, and allow work from home after leave where '
              'the job suits it and you and your employer agree.'),
        ],
      ),
      PvReadSection(
        heading: _en('What help does the government offer?'),
        paragraphs: [
          _en('Some schemes are open to everyone, and some depend on income '
              'or where you give birth. Your local health centre or ASHA '
              'worker can tell you which ones apply to you.'),
        ],
        bullets: [
          _en('Janani Shishu Suraksha Karyakram (JSSK): free delivery, '
              'including a caesarean, in government hospitals, with free '
              'medicines, tests and food.'),
          _en('Pradhan Mantri Matru Vandana Yojana (PMMVY): ₹5,000 for a '
              'first child, paid in instalments, and ₹6,000 for a second '
              'child if she is a girl. There are conditions on who '
              'qualifies.'),
          _en('Janani Suraksha Yojana (JSY): cash support for giving birth '
              'in a hospital, mainly for women from lower-income homes.'),
          _en('Many states run their own schemes on top of these.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Rules and amounts change'),
          body: _en('Scheme amounts and rules are updated from time to time. '
              'Check the current details with your health centre, and check '
              'leave with your HR team, before you plan around them.'),
        ),
      ),
      PvReadSection(
        heading: _en('How much should we plan for?'),
        paragraphs: [
          _en('Costs vary a lot by city and hospital. In a private city '
              'hospital, a normal delivery often costs roughly ₹50,000 to '
              '₹1.5 lakh, and a caesarean more. Checkups, scans and tests '
              'through the pregnancy add to that.'),
          _en('Ask two or three hospitals for their delivery package, and '
              'what it leaves out. Then compare it with what your insurance '
              'will pay.'),
          _en('If fertility treatment might be part of your plans, those '
              'costs are separate and usually not insured. Our read on IVF '
              'costs goes through them.'),
          _en("Think about the baby's first year too: doctor visits, nappies, "
              'clothes and, if needed, formula. The routine vaccines are free '
              'at government health centres.'),
          _en('It is also a good time to update the nominees on your bank '
              'accounts, insurance and provident fund. If others will depend '
              'on your income, a term life policy is worth looking at.'),
        ],
        tip: PvReadTip(
          title: _en('Small savings that add up'),
          body: _en('Start a small monthly amount now, even ₹2,000 or ₹5,000, '
              'in a separate account. Borrow baby clothes and gear from '
              'family, since babies outgrow things in weeks. If you can, keep '
              'three to six months of expenses aside for emergencies.'),
        ),
      ),
      PvReadSection(
        heading: _en('What should we talk about before we start?'),
        paragraphs: [
          _en("No one is ever fully ready, and you don't need to be. But a "
              'few honest conversations now can save arguments later. Take '
              'one question at a time, over tea, not all at once.'),
        ],
        bullets: [
          _en('Will either of us change work, or hours, after the baby?'),
          _en('Who will look after the baby when leave ends: family, a crèche '
              'or a nanny?'),
          _en('Where will we live, and is there room?'),
          _en('What help can we expect from family, and what help do we '
              'want?'),
          _en('How will we share night feeds and housework?'),
          _en('If it takes longer than we hope, how far would we go with '
              'treatment, and what could we spend?'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('There are no right answers here. The point is to know where '
              'each of you stands, so nothing comes as a surprise later.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en("Can I buy maternity cover after I'm pregnant?"),
        answer: _en('Usually not for this pregnancy. Most policies treat a '
            'pregnancy that has already started as not covered, and waiting '
            'periods still apply. Buy early if you can, or rely on an '
            'employer policy.'),
      ),
      PvReadFaq(
        question: _en('Is IVF covered by insurance in India?'),
        answer: _en('Mostly not. Infertility treatment is a standard exclusion '
            'in many policies, though a few insurers now offer some cover. '
            'Read the exclusions list, and ask the insurer to confirm in '
            'writing.'),
      ),
      PvReadFaq(
        question: _en('My work is informal. Do I get maternity leave?'),
        answer: _en('The Maternity Benefit Act mainly covers workplaces with '
            "ten or more employees. If you're self-employed or in informal "
            'work, schemes like PMMVY and JSSK may still help. Your local '
            'health centre can guide you.'),
      ),
      PvReadFaq(
        question: _en('Is it wrong to think about money when we want a '
            'baby?'),
        answer: _en('No. Planning is a way of caring for the family you hope '
            'to have. It usually makes the months ahead calmer, not less '
            'hopeful.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't let cost delay a check-up"),
      body: _en('If money is stopping you from seeing a doctor, government '
          'hospitals and medical colleges offer fertility checks at low cost. '
          "See a doctor after a year of trying (six months if you're 35 or "
          'over), or sooner if your cycles are shorter than 21 days or longer '
          'than 35, if your periods stop, if sex is painful, or if either of '
          'you has a known health condition.'),
    ),
    evidence: _en('Maternity leave follows the Maternity Benefit Act, 1961 and '
        'the Maternity Benefit (Amendment) Act, 2017. Paternity leave for '
        'central government staff follows the Central Civil Services (Leave) '
        'Rules, 1972. JSSK and JSY follow the Ministry of Health and Family '
        'Welfare, and PMMVY the Ministry of Women and Child Development. '
        'Insurance exclusions follow the IRDAI guidelines on standard '
        'exclusions in health insurance (2019). Delivery costs are broad '
        'ranges for private city hospitals and vary widely. When to see a '
        'doctor follows the NICE fertility guideline CG156. '
        'Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('What IVF really costs in India'),
        value: _en('The treatment costs insurance usually leaves out, with '
            'price ranges.'),
        surfaceId: 'ttc_read/ttc_read_ivf_costs',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your papers together'),
        value: _en('Reports and documents in one place, for the doctor and '
            'the insurer.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: [
      'ttc_read_three_months_before',
      'ttc_read_first_gyn_visit',
      'ttc_read_ivf_costs',
    ],
  ),

  // ===========================================================================
  //  GETTING READY — the first gynaecologist visit before trying
  // ===========================================================================
  //  Pack: getting_ready_before_you_start, "What can you ask the gynecologist
  //  about?" (P2, new) and "Preparation for pregnancy: Visiting an OB-GYN"
  //  (P2; choosing a doctor and the first visit). We had a question list for
  //  fertility clinics and none for this visit.
  PvRead(
    id: 'ttc_read_first_gyn_visit',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Seeing a gynaecologist before you try: what to ask'),
    teaser: _en('How to choose a doctor, what to take along, and the questions '
        'that make one visit count.'),
    shortAnswer: _en("A visit before you start trying lets a doctor check your "
        "health, medicines and vaccines while there's still time to act. Take "
        'your period dates, your medicines and a written list of questions. '
        'One visit two to three months before trying is enough for most '
        'women.'),
    scaleSetter: _en('Most women never have a visit like this, and most go on '
        "to have healthy pregnancies. It isn't a test you pass or fail. It's "
        'a chance to catch the few things that are easier to sort out before '
        'pregnancy than during it.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('In India, many women see a gynaecologist for the first time '
              "once they're already pregnant. A visit before trying is less "
              'common, but it can make a real difference. Vaccines, folic '
              'acid and changes to a medicine all work best before pregnancy '
              'begins.'),
          _en("Two to three months before you start is a good time. Here's "
              'how to make that visit count.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why go before trying, and not after?'),
        paragraphs: [
          _en("A few things can't be sorted quickly once you're pregnant, or "
              'work best if they are dealt with first.'),
        ],
        bullets: [
          _en('Vaccines like rubella (German measles) and chickenpox '
              "can't be given in pregnancy. Doctors usually advise waiting a "
              'month after them before trying.'),
          _en("Folic acid protects the baby's spine best when it's started at "
              'least a month before pregnancy.'),
          _en('Diabetes, thyroid problems and high blood pressure are safer '
              "for you and the baby when they're well controlled before you "
              'conceive.'),
          _en('Some medicines, such as certain ones for epilepsy or acne, need '
              "to be changed before pregnancy, with your doctor's help."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I choose a gynaecologist?'),
        paragraphs: [
          _en('Look for a doctor with a postgraduate qualification in '
              'obstetrics and gynaecology, such as MD, MS, DNB or DGO. If '
              "you'd like the same doctor through a pregnancy, choose one "
              "linked to a hospital you'd be happy to give birth in."),
        ],
        bullets: [
          _en('Do they explain things and answer questions without rushing '
              'you?'),
          _en('Is the hospital close enough to reach quickly, day or night?'),
          _en("Would you prefer a woman doctor? It's fine to ask for one."),
          _en('Do they give you your reports to keep?'),
        ],
      ),
      PvReadSection(
        paragraphs: [
          _en('Recommendations from friends and family help, but trust how '
              "you feel in the room. It's fine to see someone else if it "
              "doesn't feel right."),
          _en("Fees vary a lot between clinics, and it's fine to ask what a "
              'consultation costs before you book.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should I take along?'),
        paragraphs: [
          _en('A little preparation saves a lot of time in the room. Bring '
              'these on paper or on your phone.'),
        ],
        bullets: [
          _en('The date your last period started, and how long your last '
              'three cycles were, if you know.'),
          _en('Every medicine and supplement you take, with doses. Photos of '
              'the strips are fine.'),
          _en('Past illnesses, operations and pregnancies, including any '
              'miscarriage or abortion.'),
          _en('Family health, such as diabetes, thyroid problems, high blood '
              'pressure, and blood conditions like thalassaemia.'),
          _en('Your vaccination record, if you have it.'),
          _en('Old test reports, especially thyroid, blood sugar and blood '
              'group.'),
        ],
        tip: PvReadTip(
          title: _en('Bring your partner if you can'),
          body: _en('His health, habits and family history matter too, and it '
              'helps if you both hear the same advice.'),
        ),
      ),
      PvReadSection(
        heading: _en('What happens at the visit?'),
        paragraphs: [
          _en('Most of it is talking. The doctor will ask about your periods, '
              "health and plans. They'll usually check your weight and blood "
              'pressure, and may examine your breasts, belly or pelvis.'),
          _en("A pelvic exam is usually short, and you can ask what's being "
              'checked and why. You can ask for a woman to be in the room, '
              'and you can ask to stop at any time.'),
          _en('You may also be offered cervical screening, such as a Pap '
              "test, if you haven't had one. It checks the neck of the womb "
              'for early changes, long before they could cause trouble.'),
          _en('Many doctors order a few blood tests, such as a blood count, '
              'blood group, thyroid, sugar and infections. Our read on the '
              'tests worth doing first explains each one. You should leave '
              'with a plan, even if the plan is that nothing needs doing yet.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask?'),
        paragraphs: [
          _en("Write your questions down before you go. Doctors are busy, "
              "and it's easy to forget in the room. These are a good start."),
        ],
        bullets: [
          _en('Do I need any blood tests before we start trying?'),
          _en('Which vaccines do I need, and how long should I wait after '
              'them before trying?'),
          _en('Are my medicines safe for pregnancy? Should anything change, '
              'and how?'),
          _en('What dose of folic acid should I take, and when should I '
              'start?'),
          _en('Is there anything about my weight, blood pressure, sugar or '
              'thyroid to work on first?'),
          _en('Is anything about my periods worth checking?'),
          _en('Is there anything in our family history to test for, like '
              'thalassaemia?'),
          _en('Should I have cervical screening before we start?'),
          _en('Should my partner have any tests?'),
          _en('How long should we try before coming back to you?'),
          _en('What should I do when I get a positive test?'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Never stop a medicine on your own'),
          body: _en('If you take medicine for depression, anxiety, epilepsy, '
              'thyroid, blood pressure or anything else, keep taking it until '
              "you've talked it through with your doctor. Stopping suddenly "
              'can be risky, and many medicines are safe or have safer '
              'options. Your doctor will plan any change with you.'),
        ),
      ),
      PvReadSection(
        heading: _en('What if the visit feels rushed?'),
        paragraphs: [
          _en("It's fine to say, \"I have a few questions, can we go through "
              'them?" Most doctors appreciate a clear list. Ask for a printed '
              'copy of any reports and prescriptions.'),
          _en('If you leave with questions unanswered, a follow-up visit or a '
              "second opinion is normal. You're not being difficult. This is "
              'your health and your family.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en("Is it too early to see a doctor if we haven't started "
            'trying?'),
        answer: _en('No. Before trying is the best time, because some changes, '
            'like vaccines and folic acid, need weeks or months to work.'),
      ),
      PvReadFaq(
        question: _en('Can I see a family doctor instead?'),
        answer: _en('Yes. A family doctor can cover much of this: folic acid, '
            'vaccines, medicines and basic tests. A gynaecologist is worth '
            'seeing if you have period problems or a known condition, or want '
            'the same doctor for your pregnancy.'),
      ),
      PvReadFaq(
        question: _en('Will the doctor ask about our sex life?'),
        answer: _en("They may ask how often you have sex, and whether it's "
            "ever painful. It's routine, and honest answers help. You can "
            'always say if a question makes you uncomfortable.'),
      ),
      PvReadFaq(
        question: _en("What if I'm embarrassed to mention a past abortion or "
            'infection?'),
        answer: _en('Doctors hear this every day, and they need it to look '
            'after you properly. You can keep it short. It stays between you '
            'and your doctor.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't wait for a planned visit if"),
      body: _en('See a doctor soon, rather than at a planned visit, if you '
          'have bleeding between periods or after sex, very heavy periods, '
          'pelvic pain that is getting worse, a lump in your breast, or if '
          "your periods have stopped for three months and you're not "
          'pregnant. Go to a hospital today if you have a positive pregnancy '
          'test with severe pain on one side, pain at the tip of your '
          'shoulder, heavy bleeding or fainting.'),
    ),
    evidence: _en('Preconception care follows the WHO policy brief on '
        'preconception care (2013), ACOG Committee Opinion 762 on '
        'prepregnancy counselling (2019) and the NICE fertility guideline '
        'CG156. The month to wait after rubella and chickenpox vaccines '
        'follows the CDC. Warning signs of an ectopic pregnancy follow RCOG '
        'and the NHS. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Check your vaccinations'),
        value: _en('See which ones are worth asking about at the visit.'),
        surfaceId: 'ttc_vaccinations',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Book and note the visit'),
        value: _en('Keep the date, and what the doctor said, in one place.'),
        surfaceId: 'ttc_appointments',
      ),
    ],
    readNext: [
      'ttc_read_preconception_tests',
      'ttc_read_meds_and_conditions',
      'ttc_read_three_months_before',
    ],
  ),
];
