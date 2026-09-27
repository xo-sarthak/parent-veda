// =============================================================================
//  Body and cycle — the reads for the "Your cycle" tab
// -----------------------------------------------------------------------------
//  Written 2026-09-26 from the TTC gap analysis (docs/TTC-GAP-PLAN.md, stream
//  A, "Body and cycle › Your cycle"). Every topic came from a competitor piece
//  the analysis sent here; the text is our own, written from the named bodies
//  in each read's evidence note.
//
//  ⚠️ ONE FILE PER BRACKET. Nothing outside `ttc_reads_data.dart` should import
//  this file; the aggregator is the only public entry point, so the shape and
//  clinical tests scan these reads with every other.
//
//  ⚠️ THESE FACTS MUST AGREE WITH `ttc_read_how_conception_works`
//  (ttc_reads_conceiving.dart): cycles of 21 to 35 days are normal, the second
//  half is about fourteen days (ten to seventeen normal), and the fertile
//  window is six days ending on ovulation day. Change one there, change it
//  here, or the two pages will contradict each other with nothing failing.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// Private and duplicated per file, on purpose (see ttc_reads_conceiving.dart).
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsBodyCycle = [
  // ===========================================================================
  //  1. A late period
  // ===========================================================================
  PvRead(
    id: 'ttc_read_late_period',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('What counts as a late period, and the usual reasons'),
    teaser: _en("When a period counts as late, what to do while you wait, and "
        "the common reasons it can be late when you're not pregnant."),
    shortAnswer: _en("A period is usually called late once it's about five days "
        "past the day you expected it, and missed once six weeks have passed "
        "since the last one started. Take a pregnancy test from the day it was "
        "due, and again a few days later if it's negative and nothing has come. "
        "A late ovulation that month is the most common reason of all."),
    scaleSetter: _en("A late period is very common, and most of the time it "
        "means ovulation came late that month, not that something is wrong. "
        "One late period on its own isn't a reason to worry. It's worth a "
        "doctor's visit if it keeps happening, or if your periods stop for "
        "three months."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("A few days of waiting can feel very long when you're trying. "
              "You check for signs every hour, and every twinge seems to mean "
              "something. This read sets out what counts as late, what to do "
              "next, and what else can cause it."),
          _en("Here's the key fact. Your period comes about two weeks after "
              "you ovulate. So if ovulation came late this month, your period "
              "comes late too, even when nothing else has changed."),
        ],
      ),
      PvReadSection(
        heading: _en('When does a period count as late?'),
        paragraphs: [
          _en("Your cycle doesn't run to the exact day. A difference of a few "
              "days from one month to the next is normal for most women. So a "
              "period that's two or three days later than you expected isn't "
              "late in any medical sense."),
          _en("Most doctors call a period late once it's about five days past "
              "the day you expected it. If six weeks have passed since your "
              "last period started, it's usually called a missed period."),
          _en("To know your own expected day, you need a few months of dates. "
              "If your cycles usually run between 28 and 32 days, a period on "
              "day 31 is on time for you, even if an app said day 28."),
          _en("If you track ovulation, that helps too. Your period usually "
              "comes 10 to 17 days after it. So if you ovulated around day 20, "
              "a period around day 34 is on time, not late."),
        ],
        tip: PvReadTip(
          title: _en('Work out your own usual length'),
          body: _en("Add up your last three or four cycle lengths and divide by "
              "how many there are. That's your usual length. Apps that assume "
              "28 days will call a lot of normal periods late."),
        ),
      ),
      PvReadSection(
        heading: _en("My period is late. What should I do now?"),
        paragraphs: [
          _en("Here's a simple order to follow. It saves a lot of guessing and "
              "a lot of test strips."),
        ],
        bullets: [
          _en("Take a home pregnancy test from the day your period was due. "
              "Morning urine is the most concentrated, which helps if it's "
              "early."),
          _en("If it's negative and your period still hasn't come, test again "
              "in three or four days. The pregnancy hormone roughly doubles "
              "every two to three days in early pregnancy, so a later test can "
              "turn positive."),
          _en("If you get a clear positive, book a visit with your doctor. You "
              "don't need a blood test to confirm it before you go."),
          _en("If a week has passed with negative tests and still no period, "
              "it's reasonable to see a doctor. They can check for the usual "
              "reasons."),
          _en("Keep having sex as usual while you wait, unless your doctor has "
              "told you otherwise. A late period isn't a reason to stop."),
        ],
      ),
      PvReadSection(
        heading: _en('What else can make a period late?'),
        paragraphs: [
          _en("Most reasons come back to the same thing. Something delayed "
              "ovulation this month, so the whole cycle ran longer. These are "
              "the common ones."),
          _en("A late period can also come from something that needs a simple "
              "blood test, like a thyroid problem, raised prolactin or PCOS. "
              "The read on irregular cycles covers these."),
          _en("If one of these fits your month, give it one more cycle. Most "
              "cycles go back to their usual length once the cause has "
              "passed."),
        ],
        bullets: [
          _en("Stress. A hard month, a death in the family, exams or a big "
              "move can delay ovulation by days or even weeks."),
          _en("Illness. A fever, a bad cold or an infection around the middle "
              "of your cycle can push ovulation later."),
          _en("Travel and sleep. Long trips, night shifts and a changed "
              "routine can shift your cycle for a month."),
          _en("Weight change. Losing or gaining a lot of weight quickly, or "
              "eating much less than your body needs, can delay or stop "
              "ovulation."),
          _en("A lot of hard exercise, especially without enough food to "
              "match it."),
          _en("Coming off hormonal contraception. Cycles can take a few months "
              "to settle."),
          _en("Breastfeeding, if you've had a baby recently."),
        ],
      ),
      PvReadSection(
        heading: _en('Could it be a pregnancy that ended very early?'),
        paragraphs: [
          _en("Sometimes. A very early loss, before a scan could see anything, "
              "can make a period a few days late and a little heavier than "
              "usual. You might see a faint positive test that then fades."),
          _en("This is common, and nothing you did caused it. It doesn't need "
              "treatment in most cases. If it happens more than once, or the "
              "bleeding is very heavy, tell your doctor."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("A late period isn't a warning sign on its own"),
          body: _en("Most women have a late cycle now and then. What a doctor "
              "looks at is the pattern over several months, which is why "
              "noting your dates helps so much."),
        ),
      ),
      PvReadSection(
        heading: _en('What if my periods are often late?'),
        paragraphs: [
          _en("If your periods are often late, or your cycles are often longer "
              "than 35 days, it's worth seeing a gynaecologist. The first tests "
              "are usually simple blood tests, and sometimes an ultrasound."),
          _en("If you're trying and your cycles are long or hard to predict, "
              "you don't need to wait a full year before asking for help. "
              "Irregular cycles are a good reason to be seen sooner."),
          _en("Bring your dates, any test results and a list of the medicines "
              "you take. It makes the first visit much more useful, and often "
              "saves a second one."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can stress really delay my period?'),
        answer: _en("Yes. Stress can delay ovulation, and your period follows "
            "about two weeks after ovulation. It isn't a reason to blame "
            "yourself, though. Everyday worry doesn't stop you getting "
            "pregnant."),
      ),
      PvReadFaq(
        question: _en('My test is negative but I feel pregnant. Is it wrong?'),
        answer: _en("If you tested early, it may be too soon to show. Test "
            "again in three or four days. The feelings before a period and in "
            "early pregnancy come from the same hormone, progesterone, so they "
            "can't tell you which one it is."),
      ),
      PvReadFaq(
        question: _en('Is it bad to test every day?'),
        answer: _en("It won't harm you, but it can make the wait harder and "
            "cost more. Testing on the day your period is due, then every "
            "three or four days, gives you the same answer with less worry."),
      ),
      PvReadFaq(
        question: _en("Does a late period mean I didn't ovulate?"),
        answer: _en("Not usually. Most often it means you ovulated later than "
            "usual. Sometimes a cycle has no ovulation and ends in a late "
            "bleed. An occasional one is common. If it happens often, a "
            "doctor can check."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor, and how soon'),
      body: _en("Go to a hospital today if you have a positive test or a late "
          "period together with severe pain low on one side, pain in the tip "
          "of your shoulder, fainting or feeling very dizzy, or heavy "
          "bleeding. These can be signs of an ectopic pregnancy. Book a "
          "normal visit if your periods stop for three months, if your cycles "
          "are often longer than 35 days, or if a week has passed with "
          "negative tests and still no period."),
    ),
    evidence: _en('What counts as late and missed follows Cleveland Clinic, '
        '"Late Period". Pregnancy testing and the rise of the pregnancy '
        'hormone follow NHS "Doing a pregnancy test" and StatPearls (NCBI), '
        '"Human Chorionic Gonadotropin". Causes of delayed or absent periods '
        'follow NHS "Stopped or missed periods" and StatPearls (NCBI), '
        '"Secondary Amenorrhea". Ectopic pregnancy warning signs follow NHS '
        'and RCOG. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log the day it comes'),
        value: _en("A few months of dates shows your own usual length, so "
            "you'll know when a period is really late."),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en("Irregular cycles when it isn't PCOS"),
        value: _en('If late periods keep happening, these are the usual '
            'reasons and the tests that find them.'),
        surfaceId: 'ttc_read/ttc_read_irregular_not_pcos',
      ),
    ],
    readNext: [
      'ttc_read_irregular_not_pcos',
      'ttc_read_bleeding_kinds',
      'ttc_read_stress_fertility',
    ],
  ),

  // ===========================================================================
  //  2. Irregular cycles without PCOS
  // ===========================================================================
  //  The PCOS door already carries `ttc_read_pcos_irregular`. This is the piece
  //  for the woman who has ruled PCOS out, or never had its other signs, and
  //  would not look in that door.
  PvRead(
    id: 'ttc_read_irregular_not_pcos',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en("Irregular cycles when it isn't PCOS"),
    teaser: _en("The other common reasons cycles go irregular, how doctors "
        "check whether you're ovulating, and what the first tests look for."),
    shortAnswer: _en("PCOS is only one reason cycles go irregular. Thyroid "
        "problems, raised prolactin, big changes in weight, food or exercise, "
        "and long stress can all do it too. A few simple blood tests usually "
        "find the reason, and most causes can be treated."),
    scaleSetter: _en("Irregular cycles are common, and they usually have a "
        "cause that can be found and treated. They're also a good reason to "
        "see a doctor early instead of waiting out a year of trying. That's "
        "not because something is badly wrong. It's because a clear answer "
        "saves you months."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("If your cycles jump around, you've probably wondered about "
              "PCOS. It's a fair question, because PCOS is common. But plenty "
              "of women with irregular cycles don't have it, and the answer "
              "for them is different."),
          _en("What links almost every cause is ovulation. When ovulation "
              "comes late, or doesn't come at all, the cycle stretches or "
              "becomes hard to predict. So a doctor's real question is what's "
              "getting in the way of ovulation."),
        ],
      ),
      PvReadSection(
        heading: _en('What counts as irregular?'),
        paragraphs: [
          _en("Cycles of about 21 to 35 days are normal. A difference of up to "
              "about a week between your shortest and longest cycle is normal "
              "too. So cycles of 27, 31 and 29 days are a regular pattern, "
              "even though no two months match."),
          _en("Irregular means cycles that are often shorter than 21 days or "
              "longer than 35, or that swing by more than about a week from "
              "month to month. Periods that stop for three months or more "
              "count too."),
          _en("One odd cycle doesn't make you irregular. Doctors look at the "
              "pattern over several months, not a single month that ran "
              "long."),
        ],
      ),
      PvReadSection(
        heading: _en('What else can cause irregular cycles?'),
        paragraphs: [
          _en("These are the common reasons other than PCOS. Several of them "
              "are easy to test for with a single blood sample."),
        ],
        bullets: [
          _en("Thyroid problems. An underactive or an overactive thyroid can "
              "both upset your cycle. A blood test called TSH checks it. "
              "Thyroid problems are common in India."),
          _en("Raised prolactin. Prolactin is the hormone that makes breast "
              "milk. If it's high when you're not breastfeeding, it can stop "
              "ovulation. Some women notice a milky discharge from the "
              "nipples."),
          _en("Low weight, eating too little, or a lot of hard exercise. When "
              "the brain senses the body is short of energy, it can slow the "
              "hormones that start ovulation."),
          _en("Long stress or a big shock. This works the same way, through "
              "the brain."),
          _en("Higher weight. Even without PCOS, carrying extra weight can "
              "make ovulation less regular."),
          _en("A recent change, like stopping hormonal contraception, having a "
              "baby, breastfeeding or a recent loss. Cycles often take a few "
              "months to find their rhythm again."),
          _en("Some medicines, including some used for mental health or "
              "nausea, can raise prolactin. Don't stop any medicine on your "
              "own. Ask the doctor who prescribed it."),
          _en("The ovaries slowing down early. In about 1 in 100 women this "
              "happens before 40. It often comes with hot flushes or night "
              "sweats, and blood tests can check for it."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm not ovulating every month?"),
        paragraphs: [
          _en("A cycle without ovulation is called anovulatory. Most women "
              "have one now and then, often without noticing, because you can "
              "still bleed at the end of it. One odd month isn't a problem."),
          _en("It matters when it happens often, because a pregnancy can't "
              "start in a month without an egg. Signs that a cycle may have "
              "had no ovulation include a very long or very short cycle, and "
              "ovulation strips that never turn positive."),
          _en("None of these signs proves it on its own. A blood test does a "
              "much better job, and it's simple."),
          _en("Your partner's semen test is usually done at the same time. "
              "It's quick, and it means you're not waiting on one answer "
              "before starting the next."),
        ],
        tip: PvReadTip(
          title: _en('Negative ovulation strips all month?'),
          body: _en("It doesn't always mean you didn't ovulate. You may have "
              "started testing too early or too late, missed a short surge, or "
              "used very diluted urine. If it happens two or three months in a "
              "row, mention it to your doctor."),
        ),
      ),
      PvReadSection(
        heading: _en('How does a doctor check?'),
        paragraphs: [
          _en("The simplest test is a progesterone blood test about seven days "
              "before your next period is due. In a 28-day cycle that's around "
              "day 21. A raised level shows you ovulated that month."),
          _en("If your cycles are long, the right day comes later, so your "
              "doctor may repeat the test. Some doctors also do a few "
              "ultrasound scans across one cycle to watch an egg grow and be "
              "released. This is called follicle tracking."),
          _en("The first blood tests usually also include TSH for the thyroid, "
              "prolactin, and often FSH and LH early in the cycle. A pelvic "
              "ultrasound looks at the womb and ovaries."),
          _en("Bring two or three months of cycle dates to the visit. They "
              "help the doctor pick the right day for the progesterone test "
              "and see the pattern quickly."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens after the tests?'),
        paragraphs: [
          _en("Treatment depends on the cause, and it's often simple. A "
              "thyroid problem is treated with a daily tablet. High prolactin "
              "often settles with medicine. When weight, food or exercise is "
              "behind it, steady changes can bring ovulation back."),
          _en("If no cause is found and you're still not ovulating, doctors "
              "can use tablets that help an egg grow and be released. Your "
              "doctor will explain which option fits you, and how you'll be "
              "monitored."),
          _en("While you wait for tests, keep trying as usual. Having sex "
              "every two to three days through the cycle means you don't need "
              "to know exactly when you ovulate."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('One of the most treatable parts of fertility'),
          body: _en("When ovulation is the problem, and the tubes and sperm "
              "are fine, treatment often works well. Getting checked early is "
              "the step that helps most."),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Could I have PCOS without extra hair or acne?'),
        answer: _en("Yes. PCOS doesn't look the same in everyone, and for some "
            "women irregular cycles are the main sign. That's why a doctor "
            "tests rather than guesses."),
      ),
      PvReadFaq(
        question: _en('My TSH is borderline. Does that matter when trying?'),
        answer: _en("It can. Many doctors aim for a lower TSH when you're "
            "trying and in pregnancy than they would otherwise. Ask your "
            "doctor what level they want for you, and don't change a thyroid "
            "dose on your own."),
      ),
      PvReadFaq(
        question: _en('Can I wait and see if my cycles settle?'),
        answer: _en("If it's a few months after stopping the pill or after a "
            "loss, waiting a little is reasonable. If your cycles have been "
            "irregular for a long time and you're trying, it's better to be "
            "seen now. You don't need to wait twelve months."),
      ),
      PvReadFaq(
        question: _en('Will eating better fix my cycle?'),
        answer: _en("Sometimes, if your cycle changed after weight loss, "
            "weight gain or eating very little. It won't fix a thyroid or "
            "prolactin problem, which needs its own treatment. The tests tell "
            "you which one applies."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("Book a visit if your cycles are often shorter than 21 days or "
          "longer than 35, if they swing by more than about a week, or if "
          "your periods stop for three months. Go within a week or two if "
          "you also have a milky nipple discharge, bad headaches or changes "
          "in your eyesight, hot flushes before 40, or you've lost a lot of "
          "weight quickly."),
    ),
    evidence: _en('Normal cycle limits follow ACOG and FIGO. Causes of '
        'irregular and absent periods follow NHS "Irregular periods" and '
        'StatPearls (NCBI), "Oligomenorrhea", "Amenorrhea" and '
        '"Hyperprolactinemia". Early ovarian insufficiency follows ESHRE '
        'guidance. Checking ovulation with a mid-luteal progesterone test '
        'follows NICE fertility guideline CG156. Sources checked September '
        '2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep a record of your cycles'),
        value: _en('Three months of dates is the first thing a doctor will '
            'ask for.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See the first tests'),
        value: _en('What TSH, prolactin and a progesterone test look for, in '
            'plain words.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Check the signs of PCOS'),
        value: _en('A short check that helps you decide what to ask your '
            'doctor about.'),
        surfaceId: 'ttc_pcos_check',
      ),
    ],
    readNext: [
      'ttc_read_normal_cycle',
      'ttc_read_pcos_irregular',
      'ttc_read_when_to_seek_help',
    ],
  ),

  // ===========================================================================
  //  3. Five kinds of bleeding
  // ===========================================================================
  PvRead(
    id: 'ttc_read_bleeding_kinds',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Five kinds of bleeding, and how to tell them apart'),
    teaser: _en('Your period, spotting, implantation bleeding, breakthrough '
        'bleeding, and the bleeding that needs a doctor, side by side.'),
    shortAnswer: _en("A period is usually red, needs a pad and lasts a few "
        "days. Spotting is a few drops that don't need more than a liner, and "
        "it can come at ovulation, around implantation or for other reasons. "
        "Colour alone can't tell you which it is, so your dates and a "
        "pregnancy test tell you more."),
    scaleSetter: _en("Most light bleeding while you're trying is harmless and "
        "very common. What matters is the timing, how much there is, and "
        "whether there's pain with it. A few kinds do need a doctor, and "
        "they're listed clearly near the end."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Blood you didn't expect can set your mind racing when you're "
              "trying. This read goes through the five kinds you're most "
              "likely to see, what each one usually looks like, and when it's "
              "worth a call."),
          _en("One thing first. The colour and amount of blood give clues, "
              "but they can't tell you for certain which kind it is. Your "
              "dates, and a pregnancy test when the timing fits, tell you much "
              "more."),
          _en("So keep a note of what you see, even if it seems small. Over a "
              "few cycles, the notes often answer the question better than any "
              "single day can."),
        ],
      ),
      PvReadSection(
        heading: _en('1. What does a normal period look like?'),
        paragraphs: [
          _en("A period usually lasts two to seven days. It often starts "
              "light, gets heavier on the first or second day, then tapers "
              "off. The colour runs from bright red to a deeper red, and small "
              "clots on heavy days are normal."),
          _en("It comes about two weeks after ovulation, so it arrives roughly "
              "on time for your usual cycle. You'll need a pad, cup or tampon, "
              "and the flow builds up rather than stopping after a few "
              "drops."),
          _en("The first day of real flow, not spotting, is day one of your "
              "cycle. That's the day to log, because every other date is "
              "counted from it."),
        ],
      ),
      PvReadSection(
        heading: _en('2. What is spotting?'),
        paragraphs: [
          _en("Spotting is light bleeding outside your period. It's usually a "
              "few drops, or a smear on your underwear or when you wipe. It's "
              "often pink or brown and needs no more than a panty liner."),
          _en("Brown means older blood that took a while to leave the body. "
              "Pink is fresh blood mixed with discharge. Neither colour is a "
              "warning sign on its own."),
          _en("Some women spot for a day or so around ovulation, in the middle "
              "of the cycle. It comes from the quick change in hormones as the "
              "egg is released, and it's harmless."),
          _en("Spotting on its own doesn't mean anything is wrong with your "
              "fertility. Most women spot now and then over a year."),
        ],
      ),
      PvReadSection(
        heading: _en('3. Is it implantation bleeding?'),
        paragraphs: [
          _en("Some women have light spotting when an embryo settles into the "
              "lining of the womb. This happens about six to twelve days after "
              "ovulation, often a few days before or around the time a period "
              "is due."),
          _en("Implantation bleeding is usually light, pink or brown, and "
              "lasts from a few hours to two days. Many pregnancies have none "
              "at all, so not seeing it doesn't mean anything."),
          _en("Here's the hard part. Spotting just before a period is also "
              "very common, and it looks the same. The only way to know is to "
              "take a pregnancy test from the day your period is due."),
          _en("Waiting those few days is hard. If you test early and it's "
              "negative, it may just be too soon, so test again on the day "
              "your period is due."),
        ],
        mythFact: PvMythFact(
          myth: _en('Implantation bleeding is a sure sign of pregnancy.'),
          fact: _en("It can't be told apart from spotting before a period just "
              "by looking. A test on or after the day your period is due "
              "gives you the answer."),
        ),
      ),
      PvReadSection(
        heading: _en('4. What is breakthrough bleeding?'),
        paragraphs: [
          _en("Breakthrough bleeding is light, unplanned bleeding while your "
              "hormones are being changed by medicine. You might see it in the "
              "first months after stopping hormonal contraception, or while "
              "taking some fertility medicines or progesterone."),
          _en("It's usually light and settles on its own. If you're on "
              "fertility treatment, tell your clinic about any bleeding. They "
              "may want to check your levels or move a date. Don't stop or "
              "change a medicine because of spotting unless they tell you "
              "to."),
          _en("If you've recently stopped the pill, it can take a few months "
              "for your cycle to find its own rhythm. Light, irregular bleeding "
              "in that time is common and usually settles."),
        ],
      ),
      PvReadSection(
        heading: _en('5. Which bleeding needs a doctor?'),
        paragraphs: [
          _en("Most spotting is harmless. These kinds are worth getting "
              "checked. Some need a doctor the same day, and some within a "
              "week or two."),
          _en("If you're not sure which kind you're seeing, it's always fine "
              "to call your doctor and describe it. No one will think you're "
              "making a fuss."),
        ],
        bullets: [
          _en("Any bleeding with a positive pregnancy test. Light spotting is "
              "common in early pregnancy, but your doctor should know, and "
              "bleeding with pain needs checking the same day."),
          _en("Bleeding after sex that happens more than once."),
          _en("Spotting between periods that keeps coming back for two or "
              "three cycles."),
          _en("A period that's much heavier than usual, soaks a pad in an hour "
              "or two, or has clots bigger than a ten-rupee coin."),
          _en("Bleeding that lasts more than seven days."),
          _en("Bleeding with a fever, discharge that smells bad, or pain low "
              "in your tummy, which can be signs of an infection."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Write down three things'),
          body: _en("Note the day of your cycle, the colour, and how much. A "
              "doctor can do far more with that than with a memory of "
              "\"some bleeding last month\"."),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I have a period and still be pregnant?'),
        answer: _en("Not a true period, because pregnancy stops your cycle. "
            "But some women have bleeding in early pregnancy that looks like a "
            "light period. If your period seems different and you're unsure, "
            "take a test."),
      ),
      PvReadFaq(
        question: _en('I spot a day or two before every period. Is that okay?'),
        answer: _en("It's common and often harmless. If it lasts several days "
            "each month, or is getting longer, mention it to your doctor. "
            "Sometimes it's linked to a small polyp or a short second half of "
            "the cycle, and both can be checked."),
      ),
      PvReadFaq(
        question: _en('Is brown blood at the start or end of a period normal?'),
        answer: _en("Yes. It's older blood leaving slowly, which happens when "
            "the flow is light. It isn't dirty blood, and nothing needs to be "
            "cleaned out."),
      ),
      PvReadFaq(
        question: _en('Should I stop trying if I have spotting?'),
        answer: _en("No. Spotting on its own isn't a reason to stop. If it "
            "happens often or after sex, get it checked, and your doctor will "
            "tell you if there's any reason to pause."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go today, or book a visit'),
      body: _en("Go to a hospital today if you have bleeding with a positive "
          "test or a late period and severe pain on one side, pain in the tip "
          "of your shoulder, or fainting. Go today too if you're soaking a pad "
          "every hour for more than two hours. Book a visit within a week or "
          "two for spotting that keeps coming back, bleeding after sex, or "
          "periods lasting more than seven days."),
    ),
    evidence: _en('Normal period length and the signs of heavy bleeding '
        'follow ACOG and NICE guideline NG88. The timing of implantation '
        'follows ACOG and Cleveland Clinic, "Implantation Bleeding". Bleeding '
        'in early pregnancy and ectopic warning signs follow NHS and RCOG. '
        'Bleeding between periods and after sex follows NHS and StatPearls '
        '(NCBI), "Abnormal Uterine Bleeding". Sources checked September '
        '2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Note it in your log'),
        value: _en('The day, the colour and how much, so a pattern shows up '
            'over a few cycles.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Spotting between periods'),
        value: _en('The usual reasons for pink, brown or a few red drops, and '
            'when to get them checked.'),
        surfaceId: 'ttc_read/ttc_read_spotting',
      ),
    ],
    readNext: [
      'ttc_read_spotting',
      'ttc_read_late_period',
      'ttc_read_heavy_flow',
    ],
  ),

  // ===========================================================================
  //  4. Spotting between periods
  // ===========================================================================
  PvRead(
    id: 'ttc_read_spotting',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Spotting between periods: what it usually means'),
    teaser: _en('Pink, brown or a few red drops between periods, the usual '
        'reasons for each, and when to get it checked.'),
    shortAnswer: _en("Spotting between periods is common and usually "
        "harmless. It can come from ovulation, a change in hormones, the "
        "cervix after sex, or a small growth like a polyp. If it keeps "
        "happening, comes after sex, or comes with pain or a bad smell, see a "
        "doctor."),
    scaleSetter: _en("Most spotting is small, passes quickly and has a "
        "harmless cause. It's still worth a check if it keeps coming back, "
        "because the common causes are easy to find and easy to treat."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Seeing a pink or brown mark on your underwear in the middle of "
              "your cycle can be unsettling, especially when you're watching "
              "your body closely. It's one of the most common things women "
              "notice while trying."),
          _en("This read goes through the usual reasons, by colour and by "
              "timing. None of them can be diagnosed from a colour. But "
              "knowing the likely ones helps you decide what to do next."),
          _en("Most of the time it's gone within a day and turns out to mean "
              "nothing. It's still good to know what to look out for."),
        ],
      ),
      PvReadSection(
        heading: _en("Can spotting mean I'm ovulating?"),
        paragraphs: [
          _en("It can. Around ovulation, oestrogen dips for a short time. In "
              "some women that causes a little bleeding for a day or so. It's "
              "usually pink or light red, and often mixed with clear, stretchy "
              "discharge."),
          _en("If it comes at the same point in the middle of each cycle and "
              "lasts about a day, ovulation is the likely cause. Note it in "
              "your log. It's another clue about when your fertile days "
              "fall."),
          _en("Ovulation spotting doesn't mean anything is wrong with your "
              "hormones. It's a sign your cycle is doing its job. Not every "
              "woman has it, and it may come in some months and not others."),
        ],
      ),
      PvReadSection(
        heading: _en('What does pink or brown discharge mean?'),
        paragraphs: [
          _en("Pink discharge is a little fresh blood mixed with normal "
              "discharge. It's often seen around ovulation, after sex, or just "
              "before a period starts."),
          _en("Brown discharge is older blood that has taken time to leave the "
              "body. Brown spotting just before a period, or for a day or two "
              "after it, is very common. It's usually the start or the tail "
              "end of the period itself."),
          _en("Brown spotting for several days before every period is worth "
              "mentioning to a doctor. It sometimes goes with a short second "
              "half of the cycle or a small polyp, and both can be checked."),
          _en("Some women also notice pink discharge for a day after an "
              "internal examination or a scan with a probe. That's from the "
              "cervix being touched, and it settles on its own."),
        ],
        tip: PvReadTip(
          title: _en('Note three things when you see it'),
          body: _en("Write down the day of your cycle, the colour, and whether "
              "it followed sex. Two or three months of notes will show a "
              "pattern, and your doctor will find it very useful."),
        ),
      ),
      PvReadSection(
        heading: _en('Why do I spot after sex?'),
        paragraphs: [
          _en("Light bleeding after sex usually comes from the cervix, the "
              "neck of the womb. Its surface can be delicate, and friction can "
              "make it bleed a little. A common, harmless cause is cervical "
              "ectropion, where softer cells sit on the outside of the "
              "cervix."),
          _en("Other causes include an infection like chlamydia, a small "
              "growth called a polyp, or dryness. Rarely, it's a sign of "
              "changes on the cervix that need treatment. That's why bleeding "
              "after sex more than once should be checked."),
          _en("A doctor will usually look at your cervix, may take a swab, "
              "and will check your cervical screening is up to date. If you "
              "haven't had a Pap smear or HPV test in the last few years, ask "
              "for one."),
          _en("If dryness is part of it, a fertility-friendly lubricant can "
              "help. Many ordinary lubricants slow sperm down, so choose one "
              "made for couples who are trying."),
        ],
      ),
      PvReadSection(
        heading: _en('What else can cause spotting between periods?'),
        paragraphs: [
          _en("These are the other common reasons. A doctor can check for "
              "each of them, usually with an examination and an ultrasound."),
          _en("Take your notes to the visit: how often it happens, what "
              "colour it is, and whether it follows sex. If you can, book it "
              "for a day when you aren't bleeding."),
        ],
        bullets: [
          _en("Changing hormones, like after stopping the pill, or in the "
              "first months after a baby or a loss."),
          _en("Polyps, small soft growths in the womb or on the cervix. "
              "They're usually harmless and can be removed."),
          _en("Fibroids, lumps of muscle in the wall of the womb."),
          _en("Infections, including some that can affect fertility if left "
              "untreated. These may come with discharge that smells, or a "
              "sore tummy."),
          _en("Some fertility medicines and progesterone support."),
          _en("A thyroid problem, which can make bleeding less predictable."),
          _en("Early pregnancy, if the spotting comes around the time your "
              "period is due."),
        ],
      ),
      PvReadSection(
        heading: _en('Does spotting affect trying to conceive?'),
        paragraphs: [
          _en("Most spotting doesn't. Ovulation spotting and spotting before a "
              "period are part of a working cycle. You can keep trying as "
              "usual."),
          _en("A few causes, like an untreated infection or a polyp inside "
              "the womb, can make it harder to get pregnant. They're usually "
              "easy to treat once found, which is another good reason to get "
              "spotting checked if it keeps happening."),
          _en("If you're having fertility treatment, spotting can also come "
              "from the medicines or from a procedure like an IUI. Tell your "
              "clinic, and don't change any medicine on your own."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('The common causes are simple to treat'),
          body: _en("An infection needs a short course of medicine, and a "
              "polyp can be removed in a short procedure. Finding the cause is "
              "usually the hardest part."),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it okay to have sex if I spot afterwards?'),
        answer: _en("If it happens once, it's rarely a worry. If it keeps "
            "happening, get checked. Your doctor will tell you if there's any "
            "reason to pause until then."),
      ),
      PvReadFaq(
        question: _en('I spotted a week after ovulation. Is it implantation?'),
        answer: _en("It might be, but spotting at that time is also common "
            "without a pregnancy. There's no way to tell by looking. Wait "
            "until your period is due and take a test then."),
      ),
      PvReadFaq(
        question: _en('Could spotting mean my hormones are low?'),
        answer: _en("Spotting for days before each period sometimes goes with "
            "lower progesterone in the second half of the cycle. It isn't "
            "something to guess at or treat on your own. If it happens every "
            "month, a doctor can check."),
      ),
      PvReadFaq(
        question: _en('Can I have a Pap smear while trying?'),
        answer: _en("Yes. It's a quick test and it's safe while you're "
            "trying. It's best done on a day when you don't have your "
            "period."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("Book a visit within a week or two if you bleed after sex more "
          "than once, if spotting between periods comes back for two or three "
          "cycles, or if it comes with discharge that smells, itching or pain "
          "during sex. Go to a hospital today if spotting comes with a "
          "positive test and pain on one side, shoulder-tip pain or "
          "fainting, or if it turns into heavy bleeding with strong pain."),
    ),
    evidence: _en('Causes of bleeding between periods and after sex follow '
        'NHS "Bleeding between periods" and StatPearls (NCBI), "Postcoital '
        'Bleeding" and "Cervical Ectropion". Mid-cycle spotting follows '
        'Cleveland Clinic. Cervical screening follows WHO guidance and the '
        'Ministry of Health and Family Welfare operational guidelines for '
        'cervical cancer screening. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Note the day and colour'),
        value: _en('A few cycles of notes turns a worry into a pattern your '
            'doctor can use.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Plan a check-up'),
        value: _en('Keep the visit, the questions and the answers in one '
            'place.'),
        surfaceId: 'ttc_appointments',
      ),
    ],
    readNext: [
      'ttc_read_bleeding_kinds',
      'ttc_read_ovulation_pain',
    ],
  ),

  // ===========================================================================
  //  5. Ovulation pain and other mid-cycle signs
  // ===========================================================================
  //  Also holds the second-half signs (sore breasts, bloating), because the
  //  question she brings to them is the same one: is this my cycle or is it
  //  pregnancy? The answer is the progesterone paragraph, said once.
  PvRead(
    id: 'ttc_read_ovulation_pain',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Ovulation pain and other mid-cycle signs'),
    teaser: _en('What the mid-cycle twinge feels like, why it happens, the '
        'other signs around ovulation, and when pain needs a doctor.'),
    shortAnswer: _en("A dull ache or a sharp twinge on one side of your lower "
        "tummy, around the middle of your cycle, is usually ovulation pain. It "
        "lasts from a few minutes to a day or two and is harmless. Pain that's "
        "severe, lasts longer, or comes with fever, vomiting or a late period "
        "needs a doctor."),
    scaleSetter: _en("Ovulation pain is common and isn't a sign that anything "
        "is wrong. It doesn't make a month more or less likely to work, "
        "either. Only a few kinds of mid-cycle pain need a doctor, and "
        "they're easy to recognise."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Some women feel a twinge low down on one side every month and "
              "have never known what it is. It has a name, mittelschmerz, "
              "which is German for middle pain. About 1 in 5 women notice it, "
              "and many feel it most months."),
          _en("Feeling it is fine, and not feeling it is fine too. Most women "
              "who ovulate every month feel nothing at all."),
        ],
      ),
      PvReadSection(
        heading: _en('What does ovulation pain feel like?'),
        paragraphs: [
          _en("It's usually felt low in the tummy, on one side, just inside "
              "the hip bone. It can be a dull ache like a mild cramp, or a "
              "sudden sharp twinge that makes you stop for a second."),
          _en("It lasts anything from a few minutes to a day or two. It may "
              "switch sides from month to month, depending on which ovary "
              "releases the egg. It doesn't always take turns neatly."),
          _en("Some women notice a little spotting or extra discharge at the "
              "same time. A few feel it in the lower back too."),
          _en("It shouldn't be severe. If a twinge makes you double over or "
              "doesn't pass, that isn't typical ovulation pain, and it's worth "
              "getting checked."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does it happen?'),
        paragraphs: [
          _en("As the egg grows, the follicle around it stretches the surface "
              "of the ovary. When the follicle opens to release the egg, a "
              "little fluid and sometimes a little blood comes out. This can "
              "irritate the lining of the tummy and cause pain."),
          _en("Some women feel it just before the egg is released and some "
              "just after. So a twinge can't tell you the exact hour you "
              "ovulated. It tells you ovulation is happening around now."),
          _en("The pain isn't a sign that the egg is healthier or weaker. It's "
              "just how your body happens to feel that part of the cycle."),
        ],
        tip: PvReadTip(
          title: _en('What helps'),
          body: _en("A hot-water bottle, a warm bath, rest or a gentle walk "
              "usually help. Paracetamol is the usual choice if you need a "
              "painkiller. If you're trying, ask a pharmacist before taking "
              "ibuprofen around ovulation, because regular use at that time "
              "may delay the egg's release."),
        ),
      ),
      PvReadSection(
        heading: _en('What are the other signs around ovulation?'),
        paragraphs: [
          _en("Your body gives a few clues in the days around ovulation. You "
              "might notice some of them, all of them, or none."),
          _en("You don't need to track all of these. Many women watch just "
              "one, often the discharge, and that's enough to know when their "
              "fertile days are."),
        ],
        bullets: [
          _en("Discharge that turns clear, slippery and stretchy, like raw egg "
              "white. It comes before ovulation, which makes it the most "
              "useful sign."),
          _en("A rise in your desire for sex around your fertile days."),
          _en("A positive ovulation strip, which picks up the LH surge a day "
              "or so before the egg is released."),
          _en("A small rise in your resting temperature after ovulation, "
              "about 0.2 to 0.5 degrees Celsius, which stays up until your "
              "period."),
          _en("Mild bloating or tender breasts, which often start after "
              "ovulation and last until your period."),
        ],
      ),
      PvReadSection(
        heading: _en('Sore breasts and bloating: is it pregnancy or my cycle?'),
        paragraphs: [
          _en("After ovulation, your body makes progesterone. It can make your "
              "breasts feel full or sore, slow your gut a little and leave you "
              "bloated. These feelings can last until your period starts."),
          _en("Early pregnancy runs on the same hormone, so it can feel "
              "exactly the same. That's why sore breasts or bloating in the "
              "second half of your cycle can't tell you whether you're "
              "pregnant. A test on the day your period is due can."),
          _en("It's also why so many women feel sure one month and then get "
              "their period. Your body isn't tricking you. The signs are real, "
              "they just come from the cycle."),
          _en("If bloating stays all month, doesn't follow your cycle, or "
              "comes with changes in your bowels, your gut is the more likely "
              "cause. Bloating on most days for three weeks or more is worth "
              "showing a doctor."),
        ],
      ),
      PvReadSection(
        heading: _en('When is mid-cycle pain not ovulation?'),
        paragraphs: [
          _en("Some pain in the same area comes from other things. These need "
              "a doctor, and some need one quickly."),
          _en("If you're not sure, it's fine to ring your doctor and describe "
              "it. Say where it is, how long it has lasted, and how bad it is "
              "from 0 to 10. That helps them decide how soon to see you."),
        ],
        bullets: [
          _en("Pain that's severe, getting worse, or lasting more than two "
              "days."),
          _en("Pain with a fever, vomiting, or burning when you pass urine."),
          _en("Sudden severe pain on one side with vomiting, which can mean "
              "an ovary has twisted. This is an emergency."),
          _en("Pain low on the right side that moves or keeps getting worse, "
              "which can be appendicitis."),
          _en("Pain with a positive test or a late period, which can be an "
              "ectopic pregnancy."),
          _en("Pain during sex, or pain at many points in your cycle, which "
              "can be a sign of endometriosis."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does the side of the pain mean that ovary released the '
            'egg?'),
        answer: _en("Usually, but not always. It doesn't matter much for "
            "trying, because the tube on either side can pick up an egg."),
      ),
      PvReadFaq(
        question: _en('Should we time sex around the pain?'),
        answer: _en("It's a useful clue, but by the time you feel it, "
            "ovulation may be close or already here. Having sex every two to "
            "three days through your fertile days works better than waiting "
            "for a twinge, because the days before ovulation count most."),
      ),
      PvReadFaq(
        question: _en("I never feel ovulation. Does that mean I'm not "
            "ovulating?"),
        answer: _en("No. Most women feel nothing at all. Regular cycles of 21 "
            "to 35 days usually mean you're ovulating. If you're unsure, a "
            "doctor can confirm it with a blood test."),
      ),
      PvReadFaq(
        question: _en('Is ovulation pain a sign of endometriosis?'),
        answer: _en("Not on its own. Ordinary ovulation pain is short and "
            "mild. Endometriosis pain tends to be stronger and last longer, "
            "and often comes with painful periods or pain during sex."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help, and how fast'),
      body: _en("Go to a hospital today for sudden severe pain on one side, "
          "pain with vomiting or fainting, pain with a fever, or any strong "
          "pain with a positive test or a late period, especially with pain "
          "in the tip of your shoulder. Book a visit if mid-cycle pain stops "
          "your normal day, lasts more than two days, or gets worse from "
          "month to month."),
    ),
    evidence: _en('Ovulation pain follows NHS "Ovulation pain" and StatPearls '
        '(NCBI), "Mittelschmerz". Signs of ovulation follow Cleveland Clinic '
        'and NICE fertility guideline CG156. Warning signs of ectopic '
        'pregnancy and ovarian torsion follow NHS and RCOG. Bloating that '
        'lasts follows NHS "Bloating". Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("See this cycle's window"),
        value: _en('Your own dates, turned into the days that count this '
            'month.'),
        surfaceId: 'ttc_window',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log the twinge'),
        value: _en('Over a few months it can show you roughly when you '
            'ovulate.'),
        surfaceId: 'ttc_cycle',
      ),
    ],
    readNext: [
      'ttc_read_how_conception_works',
      'ttc_read_ovulation_kits',
      'ttc_read_period_pain',
    ],
  ),

  // ===========================================================================
  //  6. Is a "normal" cycle real?
  // ===========================================================================
  //  ⚠️ The arithmetic here (cycle length minus fourteen, six-day window ending
  //  on ovulation day) is the same arithmetic as the conceiving read and the
  //  window tool. Keep them saying one thing.
  PvRead(
    id: 'ttc_read_normal_cycle',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Is there such a thing as a "normal" cycle?'),
    teaser: _en('Why cycles differ between women and from month to month, what '
        'late ovulation means, and when a short or long cycle is worth '
        'checking.'),
    shortAnswer: _en("Yes, but normal is a range, not one number. Cycles of "
        "about 21 to 35 days are normal, and yours can change by up to about "
        "a week from month to month. Many women don't ovulate on day 14, so "
        "counting back from your next period works better."),
    scaleSetter: _en("If your cycle isn't 28 days, nothing is wrong. A steady "
        "cycle anywhere in the normal range is a working cycle. It's big "
        "swings, or cycles well outside the range, that are worth a doctor's "
        "look."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Most of us were taught that a cycle lasts 28 days and "
              "ovulation happens on day 14. It's a neat rule, and it fits "
              "fewer women than you'd think. Many ovulate earlier or later, "
              "and the same woman can change from month to month."),
          _en("Knowing your own pattern matters more than matching the "
              "textbook. It tells you which days count for you."),
          _en("This read explains why cycles differ, what counts as normal, "
              "and what a long or short cycle means when you're trying."),
        ],
      ),
      PvReadSection(
        heading: _en('Why are cycles different lengths?'),
        paragraphs: [
          _en("Your cycle has two halves. The first half, from your period to "
              "ovulation, is the part that changes. It can take ten days in "
              "one woman and twenty in another, depending on how quickly an "
              "egg grows."),
          _en("The second half, from ovulation to your next period, is much "
              "steadier. It lasts about fourteen days, and anything from ten "
              "to seventeen is normal. So when cycles differ, it's almost "
              "always the first half that's different."),
          _en("Age, genes, weight, stress, illness and sleep can all change "
              "how fast the first half moves. That's why your cycle can be 28 "
              "days one month and 32 the next."),
          _en("None of this is something you can see or feel. That's why a "
              "few months of your own dates tell you more than any rule."),
        ],
      ),
      PvReadSection(
        heading: _en('How much variation is normal?'),
        paragraphs: [
          _en("Cycles of about 21 to 35 days are normal for adults. Within "
              "that, a difference of up to about a week between your shortest "
              "and longest cycle is still counted as regular."),
          _en("Cycles change with age too. Many women find their cycles get a "
              "little shorter, and sometimes less regular, from their late 30s "
              "onwards."),
          _en("Your period itself usually lasts two to seven days. The flow "
              "can change from month to month as well, and one lighter or "
              "heavier period on its own is rarely a worry."),
          _en("One very different cycle in a year, after an illness or a "
              "stressful month, is common. It doesn't change what your normal "
              "is."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Count back, not forward'),
          body: _en("Take your usual cycle length and subtract fourteen. That "
              "gives a rough ovulation day. In a 32-day cycle, it's around day "
              "18, not day 14. Your fertile window is the six days ending on "
              "that day."),
        ),
      ),
      PvReadSection(
        heading: _en('What does late ovulation mean for trying?'),
        paragraphs: [
          _en("Late ovulation means the first half of your cycle is long. In "
              "a 35-day cycle, ovulation usually comes around day 21. That's "
              "normal for that length, as long as the cycle is fairly "
              "steady."),
          _en("The main problem is following a day 14 rule. If you ovulate "
              "around day 21 but only have sex between days 10 and 16, you "
              "could miss your fertile days every month without knowing."),
          _en("Having sex every two to three days all through the cycle "
              "avoids this. So does watching your own signs, like egg-white "
              "discharge or a positive ovulation strip, instead of a date on "
              "a calendar."),
          _en("If your cycle length changes a lot from month to month, "
              "counting back from the next period is harder. That's when "
              "ovulation strips or watching your discharge help most."),
        ],
      ),
      PvReadSection(
        heading: _en("Do long cycles mean it'll take longer to get pregnant?"),
        paragraphs: [
          _en("A long cycle means fewer cycles in a year. A 28-day cycle gives "
              "about thirteen ovulations a year, and a 40-day cycle gives about "
              "nine. That's the main difference."),
          _en("If your long cycles are steady and you're ovulating, many women "
              "in your place get pregnant without any help. Knowing when you "
              "ovulate matters more for you than for someone with shorter "
              "cycles."),
          _en("If your cycles are often longer than 35 days, or hard to "
              "predict, don't wait a full year to see a doctor. Long cycles "
              "sometimes mean ovulation isn't happening every month, and that "
              "is usually treatable."),
          _en("Plenty of women have long cycles with no problem at all. Your "
              "doctor can tell you whether yours needs a closer look."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my cycles are short, or my period comes early?'),
        paragraphs: [
          _en("A cycle of 21 to 24 days is still normal. It usually means your "
              "first half is quick. You may ovulate as early as day 7 to 10, "
              "so your fertile days can start soon after your period ends."),
          _en("With a short cycle, your period and your fertile days can sit "
              "close together. Some women find their fertile days begin while "
              "they're still spotting at the end of a period."),
          _en("An early period now and then often follows stress, illness or "
              "travel. Cycles that are often shorter than 21 days are worth "
              "showing a doctor. Sometimes the cause is a thyroid problem, a "
              "polyp or fibroid, or the ovaries slowing down."),
          _en("Sometimes what looks like two periods in a month is one period "
              "and one spell of ovulation spotting. Noting the colour and the "
              "amount helps tell them apart."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('My cycle changed after 35. Is that normal?'),
        answer: _en("Often, yes. Cycles tend to get shorter, and sometimes "
            "less regular, from the late 30s. If you're trying, mention it to "
            "your doctor along with how long you've been trying."),
      ),
      PvReadFaq(
        question: _en('Can I have two periods in one month?'),
        answer: _en("Yes, if your cycle is short. A 21-day cycle can fit two "
            "periods into one calendar month and still be normal. If it's new "
            "for you, or your cycles are often under 21 days, get it "
            "checked."),
      ),
      PvReadFaq(
        question: _en('Does a period app know when I ovulate?'),
        answer: _en("An app estimates from your past dates. It's a good "
            "starting point, but it can't see ovulation. Signs like egg-white "
            "discharge or a positive strip tell you what's happening this "
            "month."),
      ),
      PvReadFaq(
        question: _en('Will my cycle match my sister or friends if we live '
            'together?'),
        answer: _en("It's a popular idea, but good studies haven't found it. "
            "Cycles of different lengths drift in and out of line with each "
            "other by chance."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("Book a visit if your cycles are often shorter than 21 days or "
          "longer than 35, if they swing by more than about a week, if your "
          "periods stop for three months, or if you keep bleeding twice a "
          "month. None of these is an emergency. Two or three months of dates "
          "will help your doctor a lot, so start noting them now."),
    ),
    evidence: _en('Normal cycle length follows ACOG. Limits for a regular '
        'cycle follow the FIGO system for normal and abnormal uterine '
        'bleeding (2018). Phase lengths follow Endotext, "The Normal '
        'Menstrual Cycle and the Control of Ovulation" (NCBI Bookshelf), and '
        'StatPearls, "Physiology, Menstrual Cycle". Sex every two to three '
        'days follows NICE fertility guideline CG156. Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Find your own pattern'),
        value: _en('Log a few cycles and see your usual length, not the '
            "textbook's."),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("See this cycle's window"),
        value: _en('Counted back from your own cycle, not from day 14.'),
        surfaceId: 'ttc_window',
      ),
    ],
    readNext: [
      'ttc_read_how_conception_works',
      'ttc_read_irregular_not_pcos',
      'ttc_read_timing_myths',
    ],
  ),

  // ===========================================================================
  //  7. Period pain
  // ===========================================================================
  PvRead(
    id: 'ttc_read_period_pain',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en("Period pain: what's usual and what isn't"),
    teaser: _en('How much period pain is normal, what helps, what strong pain '
        'can point to, and when to ask a doctor.'),
    shortAnswer: _en("Cramps in the first day or two of a period that ease "
        "with heat or a painkiller are normal. Pain that stops your day, "
        "isn't helped by painkillers, gets worse over the years, or comes "
        "with pain during sex isn't something to put up with. It can point to "
        "conditions like endometriosis, which a doctor can check."),
    scaleSetter: _en("Most period pain is normal and isn't a sign of a "
        "fertility problem. But many women are told for years that strong "
        "pain is part of being a woman, and that isn't true. If your pain is "
        "severe, it deserves a proper look."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Many of us grew up hearing that period pain is something you "
              "just bear. That makes it hard to know when pain is ordinary and "
              "when it's telling you something. This read helps you sort the "
              "two."),
          _en("It matters more while you're trying. A few conditions that "
              "cause strong period pain can also make it harder to get "
              "pregnant, and they're easier to manage when they're found "
              "early."),
          _en("The aim isn't to worry you. It's to make sure strong pain gets "
              "the attention it deserves."),
        ],
      ),
      PvReadSection(
        heading: _en('What causes period cramps?'),
        paragraphs: [
          _en("Before and during your period, the lining of the womb releases "
              "chemicals called prostaglandins. They make the womb muscle "
              "tighten to shed the lining. Those squeezes are the cramps you "
              "feel."),
          _en("Ordinary cramps usually start just before or as bleeding "
              "begins, and last one to three days. You feel them low in the "
              "tummy, and sometimes in the lower back or thighs."),
          _en("Some women also feel sick, have loose stools, get a headache or "
              "feel faint on the first day. Prostaglandins cause these too, and "
              "they usually pass as the period settles."),
        ],
      ),
      PvReadSection(
        heading: _en('How much pain is normal?'),
        paragraphs: [
          _en("Normal period pain can be uncomfortable, but it's manageable. "
              "Heat, rest or an ordinary painkiller takes the edge off, and "
              "you can mostly get on with your day."),
          _en("Pain is less likely to be ordinary when it looks like any of "
              "these."),
          _en("Having one of these doesn't mean you have a condition. It means "
              "it's worth asking, instead of putting up with it for another "
              "year."),
        ],
        bullets: [
          _en("It stops you going to work or college, or keeps you in bed."),
          _en("Painkillers taken as directed don't help much."),
          _en("It's getting worse year by year, or it started after years of "
              "easy periods."),
          _en("It comes with pain during or after sex, or pain when you open "
              "your bowels or pass urine during your period."),
          _en("You have pain on many days outside your period too."),
          _en("Your periods are also very heavy."),
        ],
      ),
      PvReadSection(
        heading: _en('What can strong period pain point to?'),
        paragraphs: [
          _en("Pain that comes from another condition is called secondary "
              "period pain. These are the common causes. Only a doctor can "
              "tell which, if any, applies to you."),
          _en("Endometriosis often takes years to be found, partly because the "
              "pain gets brushed off. Asking early, and describing the pain "
              "clearly, can shorten that wait."),
        ],
        bullets: [
          _en("Endometriosis. Tissue like the womb lining grows outside the "
              "womb, often on the ovaries or around the pelvis. It affects "
              "about 1 in 10 women of reproductive age and can make it harder "
              "to get pregnant."),
          _en("Adenomyosis. The lining grows into the muscle wall of the "
              "womb, often causing heavy, painful periods."),
          _en("Fibroids. Lumps of muscle in or on the womb, which can cause "
              "heavy bleeding and a feeling of pressure."),
          _en("Pelvic infection. An untreated infection can cause ongoing "
              "pain and damage the tubes. In India, genital TB is one cause "
              "worth ruling out."),
        ],
        mythFact: PvMythFact(
          myth: _en('Painful periods get better after marriage or after a '
              'baby.'),
          fact: _en("Ordinary cramps sometimes ease with age or after "
              "childbirth. Severe pain from a condition like endometriosis "
              "doesn't go away by waiting, and it deserves a check now."),
        ),
      ),
      PvReadSection(
        heading: _en("What helps period pain while I'm trying?"),
        paragraphs: [
          _en("Heat helps more than many people expect. A hot-water bottle on "
              "your tummy or back, a warm bath, and gentle movement like "
              "walking or stretching can all ease cramps."),
          _en("Ibuprofen or mefenamic acid, taken with food in the first day "
              "or two of your period, work well for most women because they "
              "lower prostaglandins. If you might be pregnant, check with a "
              "pharmacist first. Paracetamol is the usual choice until you "
              "know."),
          _en("Take a painkiller as soon as the pain begins, rather than "
              "waiting for it to peak. Painkillers work better that way."),
          _en("Hormone tablets are often used for strong period pain, but "
              "they don't fit with trying. So if your pain is only kept down "
              "by painkillers for days at a time, tell your doctor. There are "
              "other ways to help."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do I still have cramps after my period ends?'),
        paragraphs: [
          _en("A day or two of cramping after bleeding stops can be the womb "
              "settling. Cramps around the middle of your cycle are often "
              "ovulation pain. Both are usually harmless."),
          _en("Cramps that keep going between periods, pain on many days of "
              "the month, or pain with fever or unusual discharge should be "
              "checked. It can come from endometriosis, adenomyosis, a cyst "
              "or an infection."),
          _en("Some lower tummy pain isn't from the womb or ovaries at all. "
              "Constipation, a urine infection, irritable bowel and "
              "appendicitis can all feel similar. That's why a doctor will "
              "ask about your bowels and bladder."),
          _en("A simple note of which days hurt, and how much, shows whether "
              "the pain follows your cycle. That one detail helps a doctor "
              "more than almost anything else you can bring."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Do painful periods mean I am more fertile?'),
        answer: _en("No. Period pain doesn't show how fertile you are, either "
            "way. Most women with painful periods conceive normally. Very "
            "strong pain is worth checking because of the conditions that can "
            "cause it, not because pain itself is a sign."),
      ),
      PvReadFaq(
        question: _en('How is endometriosis found?'),
        answer: _en("A doctor starts with your story and an examination. An "
            "ultrasound can show some kinds, like cysts on the ovaries. Some "
            "cases only show up in keyhole surgery, called laparoscopy. Your "
            "doctor will explain whether that's needed."),
      ),
      PvReadFaq(
        question: _en('Is it okay to take painkillers every month while '
            'trying?'),
        answer: _en("Taking them in the first days of your period is common. "
            "If you need them often through the month, or at high doses, talk "
            "to your doctor."),
      ),
      PvReadFaq(
        question: _en('Will my doctor think I am making a fuss?'),
        answer: _en("A good doctor won't. It helps to say how the pain affects "
            "your day, like missing work or not sleeping. Rating it from 0 to "
            "10 each month and noting it in your log gives them something "
            "clear to go on."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to go today, and when to book'),
      body: _en("Go to a hospital today for sudden severe tummy pain, pain "
          "with a fever or vomiting, pain with fainting, or any strong pain "
          "with a positive test or a late period. Book a visit within a few "
          "weeks if period pain stops your normal day, isn't helped by "
          "painkillers, is getting worse over time, or comes with pain during "
          "sex or very heavy periods."),
    ),
    evidence: _en('Causes and treatment of period pain follow NHS "Period '
        'pain", ACOG "Dysmenorrhea: Painful Periods" and StatPearls (NCBI), '
        '"Dysmenorrhea". Endometriosis figures and signs follow the WHO fact '
        'sheet "Endometriosis" and NICE guideline NG73. Adenomyosis and '
        'fibroids follow RCOG and Cleveland Clinic. Genital TB follows '
        'StatPearls (NCBI), "Genitourinary Tuberculosis". Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Note your pain each month'),
        value: _en('A score and the days it lasted is the clearest thing you '
            'can show a doctor.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Plan the visit'),
        value: _en('Keep your questions and what the doctor said in one '
            'place.'),
        surfaceId: 'ttc_appointments',
      ),
    ],
    readNext: [
      'ttc_read_heavy_flow',
      'ttc_read_ovulation_pain',
    ],
  ),

  // ===========================================================================
  //  8. Heavy, light or long periods
  // ===========================================================================
  //  ⚠️ ADDED BEYOND THE SEVEN PLANNED READS. The topic pack sends two P2 and
  //  eight P3 pieces on flow (heavy bleeding, clots, light periods, long
  //  periods, lifestyle and flow) and none of the seven had room for them
  //  without running past 1,100 words. Heavy bleeding before pregnancy is an
  //  iron question in India, which is reason enough for its own page.
  PvRead(
    id: 'ttc_read_heavy_flow',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Heavy, light or long periods: when to get them checked'),
    teaser: _en('What counts as heavy, what clots mean, why a period can turn '
        'light or long, and what to do about it before pregnancy.'),
    shortAnswer: _en("A period is heavy if you soak a pad every hour or two, "
        "pass clots bigger than a ten-rupee coin, or plan your day around it. "
        "Heavy periods are common and treatable, and worth checking before "
        "pregnancy because they can leave you low on iron. One lighter period "
        "is usually nothing, but periods that have become much lighter, or "
        "last over seven days, are worth mentioning."),
    scaleSetter: _en("Changes in flow are common, and most are small and "
        "harmless. Heavy bleeding is the one to take seriously. That's not "
        "because it's dangerous in most cases. It's because it's easy to treat, "
        "and it slowly drains your iron."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Many women live with heavy periods for years because they've "
              "always been that way. It can seem normal when your mother and "
              "sisters have the same. But heavy bleeding is worth a check, "
              "especially before a pregnancy."),
          _en("This read covers the changes women ask about most: heavy, "
              "light and long periods, and what clots mean."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I know if my period is heavy?'),
        paragraphs: [
          _en("Doctors judge heavy bleeding by how it affects your life, not "
              "by measuring blood. If it gets in the way of your work, sleep "
              "or plans, it counts. These are the common signs."),
          _en("Many women don't realise their periods are heavy, because "
              "they've never had anything to compare them with. If you're not "
              "sure, count the pads you use on your heaviest day and tell your "
              "doctor."),
        ],
        bullets: [
          _en("Soaking through a pad or tampon every one to two hours."),
          _en("Needing two pads at once, or changing more than once at "
              "night."),
          _en("Clots bigger than about 2.5 cm, roughly a ten-rupee coin."),
          _en("Bleeding through onto clothes or bedding."),
          _en("Feeling tired, breathless or dizzy during or after your "
              "period."),
          _en("Periods that last more than seven days."),
        ],
      ),
      PvReadSection(
        heading: _en('Are blood clots normal?'),
        paragraphs: [
          _en("Small clots on the heaviest days are normal. When blood flows "
              "fast, it can thicken before it leaves the body. These clots are "
              "usually dark red and smaller than a coin."),
          _en("Clots larger than about 2.5 cm, or lots of clots every period, "
              "are worth showing a doctor. They often go with heavy bleeding, "
              "and sometimes point to fibroids or polyps."),
          _en("Clots on their own, without heavy bleeding, are rarely a worry. "
              "It's their size, and how often they come, that matters."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do heavy periods matter before pregnancy?'),
        paragraphs: [
          _en("Heavy periods are one of the most common reasons for low iron "
              "in women. In India, more than half of women aged 15 to 49 are "
              "anaemic, according to the National Family Health Survey."),
          _en("Because it's so common, anaemia is often treated as normal for "
              "women. It isn't, and it's much better fixed before a pregnancy "
              "than during one."),
          _en("Pregnancy needs a lot of extra iron. Starting it with low iron "
              "makes tiredness worse and raises the risk of anaemia later. A "
              "simple blood test for haemoglobin, and often ferritin, shows "
              "where you stand."),
          _en("Heavy bleeding can also come from fibroids, polyps or "
              "adenomyosis, some of which can affect trying. Thyroid problems "
              "and bleeding disorders are other causes. Often, no cause is "
              "found at all."),
          _en("Treatment doesn't have to wait until after a baby. Sorting out "
              "heavy bleeding and low iron now means you start pregnancy "
              "stronger."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Heavy periods are treatable'),
          body: _en("There are tablets without hormones, taken only during your "
              "period, that reduce bleeding, and iron to build your stores back "
              "up. Polyps and some fibroids can be removed. Your doctor will "
              "choose options that fit with trying."),
        ),
      ),
      PvReadSection(
        heading: _en('Why is my period lighter than usual?'),
        paragraphs: [
          _en("A lighter period now and then is usually nothing. Stress, "
              "weight change, travel, a lot of exercise or a change in routine "
              "can all make one period lighter or shorter."),
          _en("Periods can also be lighter for a few months after stopping "
              "hormonal contraception, and they change a little with age. A "
              "light bleed near the time your period is due can also be early "
              "pregnancy bleeding, so a test helps if you're unsure."),
          _en("Tell your doctor if your periods have become much lighter and "
              "stayed that way, especially after a procedure to clear the "
              "womb, like a D&C, or an infection like genital TB. Rarely, these "
              "can scar the inside of the womb."),
          _en("A lighter period doesn't mean your lining is too thin to hold a "
              "pregnancy. The lining is checked on a scan, not guessed from "
              "the flow."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my period lasts longer than a week?'),
        paragraphs: [
          _en("Periods usually last two to seven days. One longer period can "
              "follow a late ovulation or a change in hormones. If yours often "
              "go past seven days, it's worth a check."),
          _en("Common causes include polyps, fibroids, thyroid problems and "
              "cycles where no egg was released. A pelvic ultrasound and a few "
              "blood tests usually find the reason."),
          _en("Keep a note of how many days you bleed each month. It's one of "
              "the first things a doctor will ask."),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('How weight, food, exercise and stress can change your '
            'flow, and the foods that help replace iron.'),
        heading: _en('Can food, sleep or stress change my flow?'),
        paragraphs: [
          _en("Yes, a little. Big changes in weight, eating much less, hard "
              "training or a stressful month can make periods lighter, later "
              "or less regular. Ordinary day-to-day changes rarely make a big "
              "difference."),
          _en("Iron-rich foods help your body replace what it loses each "
              "month. Good ones include green leafy vegetables, dals, ragi, "
              "and eggs or meat if you eat them. Having something with "
              "vitamin C, like lemon or amla, at the same meal helps you "
              "absorb the iron."),
          _en("Tea and coffee with meals make iron harder to absorb, so it "
              "helps to have them between meals instead."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it normal to change pads at night?'),
        answer: _en("Changing once at night on your heaviest day can happen. "
            "Needing to change more than once most nights, or bleeding "
            "through, is a sign of heavy bleeding worth a check."),
      ),
      PvReadFaq(
        question: _en('Can heavy periods stop me getting pregnant?'),
        answer: _en("Heavy bleeding itself doesn't stop a pregnancy. Some of "
            "its causes, like certain fibroids or polyps, can make it harder, "
            "so it's worth knowing why yours are heavy."),
      ),
      PvReadFaq(
        question: _en('Should I start iron tablets on my own?'),
        answer: _en("It's better to have a blood test first, so you know "
            "whether you need them and how much. Iron is cheap and easy to "
            "take, but the right dose depends on your levels. Your doctor can "
            "prescribe it."),
      ),
      PvReadFaq(
        question: _en('My mother had heavy periods too. Does that matter?'),
        answer: _en("It can. Some causes, like fibroids and some bleeding "
            "disorders, run in families. Tell your doctor, because it helps "
            "them decide what to check."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to go today, and when to book'),
      body: _en("Go to a hospital today if you're soaking a pad every hour for "
          "more than two hours, if you feel faint or breathless or your heart "
          "is racing, or if heavy bleeding comes with a positive test or "
          "strong pain. Book a visit within a few weeks for periods that are "
          "often heavy, last more than seven days, have large clots, or have "
          "become much lighter and stayed that way."),
    ),
    evidence: _en('Heavy menstrual bleeding follows NICE guideline NG88 and '
        'ACOG. Clot size follows NHS "Heavy periods". Anaemia in Indian women '
        'follows the National Family Health Survey 2019 to 21 (NFHS-5), '
        'Ministry of Health and Family Welfare. Scarring inside the womb '
        'follows StatPearls (NCBI), "Asherman Syndrome". Iron-rich foods follow '
        'ICMR-NIN. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Ask for a blood count'),
        value: _en('Haemoglobin and ferritin show whether heavy periods have '
            'left you low on iron.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Iron in everyday meals'),
        value: _en('Indian foods that help build your stores before '
            'pregnancy.'),
        surfaceId: 'ttc_nutrition',
      ),
    ],
    readNext: [
      'ttc_read_period_pain',
      'ttc_read_bleeding_kinds',
    ],
  ),
];
