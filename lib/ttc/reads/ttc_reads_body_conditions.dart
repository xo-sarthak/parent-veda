// =============================================================================
//  Body and cycle › Other conditions — the reads for this tab
// -----------------------------------------------------------------------------
//  Written 2026-09-26 from the TTC gap plan (docs/TTC-GAP-PLAN.md, stream A,
//  "Body and cycle › Other conditions"). The topics are the ones the gap
//  analysis sent here; every word is our own, written to docs/TTC-VOICE.md
//  from the named guidelines in each read's evidence line.
//
//  ⚠️ PCOS IS DELIBERATELY NOT HERE. It has its own door and its own library
//  (`ttc_reads_pcos.dart`); these reads only point at it. A second PCOS piece
//  in this file would be two sources for one set of facts, free to diverge.
//
//  ⚠️ NINE READS, NOT EIGHT. The plan named eight; the topic pack also carries
//  two P2 pieces on ovarian cysts with nowhere else to go, so they have a read
//  of their own (`ttc_read_ovarian_cysts`). Polyps (P2) ride inside the
//  fibroids read, and a thin lining and adrenal problems (P3) inside the
//  overview, because each is a few paragraphs, not a piece.
//
//  Same rules as every read file: the aggregator (`ttc_reads_data.dart`) is the
//  only public entry point, and nothing else should import this file.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// Private and duplicated per file, on purpose (see ttc_reads_conceiving.dart).
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsBodyConditions = [
  // ===========================================================================
  //  ENDOMETRIOSIS — the lowdown, the signs, and what it means for trying
  // ===========================================================================
  PvRead(
    id: 'ttc_read_endometriosis',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Endometriosis and trying to conceive'),
    teaser: _en("What endometriosis is, the signs worth taking to a doctor, "
        "and what it means when you're hoping for a baby."),
    shortAnswer: _en("Endometriosis is when tissue like the lining of your "
        "womb grows in other places, such as on the ovaries or the lining of "
        "the pelvis. It can make periods very painful and can make getting "
        "pregnant harder. Many women with it still get pregnant, some "
        "naturally and some with help."),
    scaleSetter: _en("Endometriosis is common, and it isn't a danger to your "
        "life. It can take time to be named, and it can slow things down. "
        "There are good treatments, and a specialist can help you pick the "
        "one that fits your plans for a baby."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("If your periods have always hurt more than other women's seem "
              "to, you may have been told that's just how it is. Sometimes it "
              "is. Sometimes the pain has a cause, and endometriosis is one of "
              "the most common."),
          _en("About one in ten women of childbearing age has endometriosis, "
              "according to the WHO. So you're far from alone, even if nobody "
              "around you talks about it."),
        ],
      ),
      PvReadSection(
        heading: _en('What is endometriosis?'),
        paragraphs: [
          _en("The lining inside your womb is called the endometrium. With "
              "endometriosis, tissue that's similar to it grows outside the "
              "womb. It's often found on the ovaries, the fallopian tubes, "
              "the outer wall of the womb and the thin lining of the pelvis."),
          _en("Less often it grows on the bowel or the bladder. The patches "
              "can be tiny spots. They can also form cysts on an ovary, called "
              "endometriomas or chocolate cysts, because of the dark old blood "
              "inside them."),
          _en("Nobody knows exactly why it happens, though it often runs in "
              "families. It isn't caused by anything you did. It isn't an "
              "infection either, so it can't be passed to your partner."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does it hurt more during my period?'),
        paragraphs: [
          _en("These patches respond to the same hormones as your womb "
              "lining. Each month they thicken and bleed a little, like a tiny "
              "period. Blood inside the womb has a way out. Blood from these "
              "patches doesn't."),
          _en("So it irritates the tissue around it and causes swelling, "
              "called inflammation. Over time this can form bands of scar "
              "tissue, called adhesions, which can stick organs together. "
              "That's why the pain often builds before and during your period, "
              "and can get worse over the years."),
        ],
      ),
      PvReadSection(
        heading: _en('What are the signs?'),
        paragraphs: [
          _en("Signs vary a lot. Some women have strong pain and only small "
              "patches. Others have a lot of endometriosis and hardly any "
              "pain. These are the signs worth telling a doctor about:"),
        ],
        bullets: [
          _en("Period pain that stops you working, studying or sleeping, even "
              "with painkillers."),
          _en('Deep pain during sex, or an ache that lasts after it.'),
          _en("Pain when you pass urine or open your bowels, especially "
              "during your period."),
          _en('Pelvic pain on many days of the month, not only on period days.'),
          _en('Heavy periods, or feeling tired all the time.'),
          _en('Trying for a baby for a long while without getting pregnant.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Bad period pain is normal. You just have to bear it.'),
          fact: _en("Some cramping is normal. Pain that stops you living your "
              "day isn't something you should have to put up with. It's worth "
              "a doctor's visit, and telling the doctor exactly what the pain "
              "stops you doing helps them take it seriously."),
        ),
      ),
      PvReadSection(
        heading: _en('How do doctors find it?'),
        paragraphs: [
          _en("Endometriosis often takes years to name. Part of the reason is "
              "that its signs look like other things, such as fibroids, "
              "ovarian cysts, a pelvic infection, a bladder problem or an "
              "irritable bowel. Your doctor will want to rule those out."),
          _en("Most women start with a talk about symptoms and an internal "
              "examination. A scan through the vagina, called a transvaginal "
              "ultrasound, can show endometriomas and some deeper patches. An "
              "MRI scan is sometimes used as well."),
          _en("Small patches on the surface often don't show on any scan, so "
              "a normal scan doesn't rule endometriosis out. The only way to "
              "see those for certain is a laparoscopy. This is a keyhole "
              "operation where a thin camera looks inside your tummy."),
          _en("Current guidelines say a doctor can often start treatment based "
              "on your symptoms and scan, without an operation first. A "
              "laparoscopy is usually kept for when its answer would change "
              "the plan."),
        ],
      ),
      PvReadSection(
        heading: _en('How can it make getting pregnant harder?'),
        paragraphs: [
          _en("Endometriosis can get in the way in a few ways. Scar tissue can "
              "bend or block a tube, or hold an ovary out of place, so the egg "
              "isn't picked up. The inflammation may also affect eggs, sperm "
              "and the early embryo."),
          _en("Endometriomas may lower the number of eggs left in that ovary, "
              "and surgery on the ovary can lower it further. That's why "
              "fertility specialists think carefully before removing these "
              "cysts in a woman who is trying."),
          _en("Up to half of women with endometriosis find it harder to get "
              "pregnant. Looked at the other way, many conceive with no "
              "treatment at all. Mild endometriosis in particular often "
              "doesn't stop a pregnancy."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Pregnancy is often still possible'),
          body: _en("Having endometriosis doesn't mean you can't have a baby. "
              "Many women with it get pregnant naturally, and others do with "
              "help such as surgery, IUI or IVF. A specialist can look at your "
              "whole picture and say which route makes sense."),
        ),
      ),
      PvReadSection(
        heading: _en("What treatment helps when you're trying?"),
        paragraphs: [
          _en("Treatment depends on your pain, your scan, your age and how "
              "long you've been trying. Your doctor may talk about stages, "
              "from one (minimal) to four (severe). The stage describes how "
              "much endometriosis there is. It doesn't tell you how much pain "
              "you'll have."),
        ],
        bullets: [
          _en("Hormone treatments, such as certain pills, ease pain well. "
              "They also stop ovulation, so they can't be used while you're "
              "trying, and they don't improve fertility afterwards."),
          _en("Painkillers can help on bad days. Ask your doctor which ones "
              "are fine to take while you're trying."),
          _en("Keyhole surgery to remove or burn away patches can ease pain. "
              "For mild endometriosis it may also help natural conception."),
          _en("IUI, where washed sperm is placed inside the womb, is sometimes "
              "offered for mild endometriosis when the tubes are open."),
          _en("IVF is often suggested when the tubes are blocked, the "
              "endometriosis is severe, you're older, or simpler treatments "
              "haven't worked."),
        ],
        tip: PvReadTip(
          title: _en('Keep a simple pain diary'),
          body: _en("Note the day of your cycle, where it hurts, how bad it is "
              "out of ten and what helped. Bring it to your appointment. It "
              "turns 'my periods are painful' into something a doctor can act "
              "on."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I keep going with a long treatment?'),
        paragraphs: [
          _en("Endometriosis is often long-term, and treatment can take "
              "months. It helps to ask your doctor for a clear plan: what "
              "you're trying now, when you'll review it, and what comes next "
              "if it doesn't work."),
          _en("If a medicine gives you side effects, tell your doctor rather "
              "than stopping it on your own. There's usually another option. "
              "Heat pads, gentle walking or yoga and good sleep won't treat "
              "endometriosis, but many women find they make bad days easier."),
          _en("It's also fine to ask for a second opinion, especially before "
              "an operation. A good specialist won't mind."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Will getting pregnant cure my endometriosis?'),
        answer: _en("No. Many women have fewer symptoms while pregnant, "
            "because periods stop. But endometriosis usually comes back after "
            "the baby, and pregnancy isn't a treatment for it. Please don't "
            "let anyone rush you into a pregnancy for that reason."),
      ),
      PvReadFaq(
        question: _en('Sex hurts. Is it doing any harm?'),
        answer: _en("Sex doesn't harm endometriosis or make it spread. If it "
            "hurts, try positions that aren't as deep, and tell your partner "
            "what feels okay. Tell your doctor too, because pain during sex "
            "helps them understand your case."),
      ),
      PvReadFaq(
        question: _en('Does endometriosis mean I will need IVF?'),
        answer: _en("Not necessarily. Many women with endometriosis conceive "
            "naturally or with simpler treatment. IVF is one option, usually "
            "suggested when the tubes are affected, the disease is severe, or "
            "time matters because of age."),
      ),
      PvReadFaq(
        question: _en('Could my sister or daughter have it too?'),
        answer: _en("It can run in families, so women whose mother or sister "
            "has it are more likely to have it too. If someone in your family "
            "has very painful periods, encourage her to see a doctor rather "
            "than put up with it."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor, and how soon'),
      body: _en("Book a visit with a gynaecologist in the next few weeks if "
          "period pain stops your daily life, sex hurts deep inside, or "
          "you've been trying for 12 months (6 if you're 35 or over). Go to "
          "hospital today if you have sudden severe tummy pain with fever, "
          "vomiting or fainting, or one-sided pain with a positive pregnancy "
          "test."),
    ),
    evidence: _en('WHO fact sheet on endometriosis (2023); ESHRE guideline, '
        'Endometriosis (2022); NICE guideline NG73, Endometriosis: diagnosis '
        'and management; ASRM Practice Committee, Endometriosis and '
        'infertility: a committee opinion; Cleveland Clinic. Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log pain alongside your cycle'),
        value: _en('A few months of notes shows your doctor when the pain '
            'comes and how much it takes from you.'),
        surfaceId: 'ttc_symptom_log',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        // Kept for revert (2026-09-28, explicit names): title: _en("See if it's time for a fertility check"),
        title: _en('See whether you need a fertility check'),
        value: _en('A few questions that tell you whether to book now or '
            'give it more time.'),
        surfaceId: 'ttc_fertility_help',
      ),
    ],
    readNext: [
      'ttc_read_blocked_tubes_hsg',
      'ttc_read_ovarian_cysts',
      'ttc_read_ivf_explained',
    ],
  ),

  // ===========================================================================
  //  THYROID — how it runs the cycle, and the one test that checks it
  // ===========================================================================
  PvRead(
    id: 'ttc_read_thyroid_tsh',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Your thyroid and fertility: the TSH test'),
    teaser: _en('How a small gland in your neck affects your periods and '
        'ovulation, and how to read the one test that checks it.'),
    shortAnswer: _en("Your thyroid helps control your periods and ovulation. "
        "If it's too slow or too fast, cycles can become irregular and getting "
        "pregnant can take longer. A cheap blood test called TSH checks it, "
        "and a daily tablet usually fixes an underactive thyroid."),
    scaleSetter: _en("Thyroid problems are very common in India and very "
        "treatable. Most women with a thyroid condition get pregnant and have "
        "healthy babies once their levels are in range. This is one of the "
        "easier things to find and put right."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Your thyroid is a small, butterfly-shaped gland at the front of "
              "your neck. It makes hormones that set the pace for much of your "
              "body, from your heartbeat to how you use energy."),
          _en("It also works with the hormones that run your cycle. So when "
              "the thyroid is off, your periods often show it first."),
        ],
      ),
      PvReadSection(
        heading: _en('How common are thyroid problems in India?'),
        paragraphs: [
          _en("Very common. A large study across eight Indian cities found "
              "that about one adult in ten had an underactive thyroid, and "
              "about a third of them didn't know it. Women were affected far "
              "more often than men."),
          _en("That's why many doctors check the thyroid among the first tests "
              "for anyone trying to conceive. It's quick, and the answer is "
              "worth having."),
        ],
      ),
      PvReadSection(
        heading: _en('What does an underactive thyroid do to my cycle?'),
        paragraphs: [
          _en("An underactive thyroid is called hypothyroidism. The body slows "
              "down. Periods can become heavy, long, irregular, or sometimes "
              "stop. Ovulation may not happen every month, which makes timing "
              "harder."),
          _en("It can also raise prolactin, a hormone that can switch "
              "ovulation off. And if a pregnancy starts while the thyroid is "
              "very low and untreated, the risk of miscarriage is higher. "
              "Treatment brings that risk back down."),
          _en("You might notice tiredness, feeling cold, weight gain, "
              "constipation, dry skin, thinning hair or low mood. Many women "
              "notice nothing at all, which is why the blood test matters."),
          _en("The most common cause is Hashimoto's thyroiditis, where the "
              "immune system slowly damages the thyroid. Low iodine used to be "
              "a big cause too, but iodised salt has made that much rarer."),
        ],
      ),
      PvReadSection(
        heading: _en('And an overactive thyroid?'),
        paragraphs: [
          _en("An overactive thyroid is called hyperthyroidism. The body "
              "speeds up. Periods often become light or far apart. You may "
              "lose weight without trying, feel hot, shaky or anxious, sleep "
              "badly, or feel your heart racing."),
          _en("The most common cause is Graves' disease, where the immune "
              "system pushes the thyroid to work too hard."),
          _en("It needs treatment and a plan before pregnancy, because some of "
              "the medicines used for it are changed before or during "
              "pregnancy. Your doctor will guide you through this."),
        ],
      ),
      PvReadSection(
        heading: _en('What does the TSH test tell me?'),
        paragraphs: [
          _en("TSH stands for thyroid stimulating hormone. It comes from a "
              "gland at the base of your brain and tells the thyroid to work "
              "harder or ease off. So TSH moves the opposite way to what you "
              "might expect."),
        ],
        bullets: [
          _en("A high TSH usually means the thyroid is underactive. The brain "
              "is pushing hard to get it going."),
          _en("A low TSH usually means the thyroid is overactive. The brain is "
              "trying to calm it down."),
          _en("Free T4 is often tested alongside it, to show how much thyroid "
              "hormone is in your blood."),
          _en("TPO antibodies show whether your immune system is attacking the "
              "thyroid, which is a common cause of an underactive thyroid."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('About the numbers'),
          body: _en("Each lab prints its own normal range, often around 0.4 to "
              "4 for TSH. When you're trying, some doctors prefer TSH below "
              "2.5. Guidelines differ on the zone in between, so your doctor "
              "will decide what's right for you."),
        ),
      ),
      PvReadSection(
        heading: _en('How is the test done?'),
        paragraphs: [
          _en("It's a simple blood test and usually costs a few hundred "
              "rupees. You don't need to fast for it. If you already take a "
              "thyroid tablet, ask whether to take it before or after the "
              "blood is drawn."),
          _en("You can have it on any day of your cycle. If you're having "
              "other hormone tests, your doctor may book them together to save "
              "you a trip."),
          _en("If your TSH is only a little high and your free T4 is normal, "
              "that's called subclinical hypothyroidism. Some doctors treat it "
              "when you're trying, especially with positive antibodies or past "
              "miscarriages. Others watch it and test again."),
        ],
      ),
      PvReadSection(
        heading: _en('How is it treated?'),
        paragraphs: [
          _en("An underactive thyroid is treated with levothyroxine, a tablet "
              "that replaces the missing hormone. It's the same hormone your "
              "body makes, and it's safe while trying and in pregnancy. A few "
              "habits help it work well:"),
        ],
        bullets: [
          _en("Take it at the same time each day on an empty stomach, usually "
              "30 to 60 minutes before breakfast or tea."),
          _en("Keep iron and calcium tablets at least four hours away from it, "
              "because they stop it being absorbed."),
          _en("Don't stop it or change the dose on your own, even when you "
              "feel well."),
          _en("Your doctor will recheck TSH about six to eight weeks after any "
              "change in dose."),
        ],
        tip: PvReadTip(
          title: _en('Tell your doctor as soon as your test is positive'),
          body: _en("Pregnancy raises your need for thyroid hormone, often "
              "from the first weeks. Many women on levothyroxine need a higher "
              "dose once pregnant. Call your doctor within a few days of a "
              "positive test, rather than waiting for your first scan."),
        ),
      ),
      PvReadSection(
        heading: _en('Do I need to change what I eat?'),
        paragraphs: [
          _en("No food will fix a thyroid problem. Iodised salt gives most "
              "people enough iodine. Iodine tablets or seaweed supplements can "
              "make some thyroid problems worse, so skip them unless your "
              "doctor suggests them."),
          _en("Cabbage, cauliflower and soya are often blamed. Cooked and "
              "eaten in everyday Indian amounts, they're fine. Taking your "
              "tablet properly matters far more than any food."),
        ],
        mythFact: PvMythFact(
          myth: _en("If you have a thyroid problem, you can't get pregnant."),
          fact: _en("Many women with thyroid conditions get pregnant, often "
              "once their levels are brought into range. A thyroid problem is "
              "a reason to get tested and treated, not a reason to give up "
              "hope."),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Will the tablet make me put on weight?'),
        answer: _en("No. Levothyroxine replaces a hormone you're short of. If "
            "anything, some women find their weight easier to manage once "
            "their thyroid is back in range."),
      ),
      PvReadFaq(
        question: _en('Is it safe to take thyroid tablets while pregnant?'),
        answer: _en("Yes. Levothyroxine is the same as the hormone your body "
            "makes, and your baby needs you to have enough of it. Stopping it "
            "is the risk, not taking it."),
      ),
      PvReadFaq(
        question: _en("Should my husband's thyroid be checked too?"),
        answer: _en("If he has symptoms, yes. Thyroid problems can affect "
            "sperm too, though less often. It's an easy test to add if his "
            "doctor thinks it's worth doing."),
      ),
      PvReadFaq(
        question: _en('My TSH was normal last year. Do I need it again?'),
        answer: _en("Levels can change, especially after a pregnancy, a "
            "miscarriage or a big change in weight. If you're starting to try "
            "or your cycles have become irregular, a fresh test makes sense. "
            "Your doctor can say how often to repeat it."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to call your doctor'),
      body: _en("Book a check in the next few weeks if your cycles have become "
          "irregular, heavy or very light, or you have signs of a slow or fast "
          "thyroid. If you take a thyroid tablet and get a positive pregnancy "
          "test, call your doctor within a few days. Get help the same day for "
          "a racing or irregular heartbeat, chest pain, severe shaking or "
          "confusion."),
    ),
    evidence: _en('American Thyroid Association guidelines for thyroid '
        'disease during pregnancy and the postpartum (2017); ASRM Practice '
        'Committee, Subclinical hypothyroidism in the infertile female '
        'population (2015); NICE guideline NG145, Thyroid disease: assessment '
        'and management; Unnikrishnan and colleagues, prevalence of '
        'hypothyroidism in adults in eight Indian cities (Indian Journal of '
        'Endocrinology and Metabolism, 2013); Cleveland Clinic. Sources '
        'checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See the tests worth doing first'),
        value: _en('Where TSH sits among the first checks, and what each one '
            'tells you.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Set a daily tablet reminder'),
        value: _en('Levothyroxine works best at the same time every morning, '
            'before food.'),
        surfaceId: 'ttc_medication',
      ),
    ],
    readNext: [
      'ttc_read_high_prolactin',
      'ttc_read_preconception_tests',
      'ttc_read_slow_conception',
    ],
  ),

  // ===========================================================================
  //  FIBROIDS AND POLYPS — which ones matter for trying
  // ===========================================================================
  //  Polyps (a P2 in the pack) live here rather than in a read of their own:
  //  they are found on the same scans, removed by the same hysteroscopy, and
  //  matter for the same reason (the space an embryo implants into).
  PvRead(
    id: 'ttc_read_fibroids_polyps',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en("Fibroids and polyps: which ones matter when you're trying"),
    teaser: _en('What these common growths are, which kinds can get in the '
        'way of a pregnancy, and what to ask before any treatment.'),
    shortAnswer: _en("Fibroids are lumps of muscle in the womb, and polyps are "
        "small growths from its lining. Both are common and are almost never "
        "cancer. Most don't stop a pregnancy, but ones that bulge into the "
        "inside of the womb can, and these can often be removed."),
    scaleSetter: _en("If a scan has just shown a fibroid, take a breath. Most "
        "women with fibroids get pregnant and have healthy pregnancies. What "
        "matters is where it sits and how big it is, and your doctor can tell "
        "you both."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Hearing the word fibroid on a scan can be frightening, "
              "especially when you're trying for a baby. The good news is that "
              "fibroids are very common, and many women have them without ever "
              "knowing."),
          _en("By the age of 50, most women have had at least one. Many are "
              "found by chance, on a scan done for something else."),
        ],
      ),
      PvReadSection(
        heading: _en('What is a fibroid?'),
        paragraphs: [
          _en("A fibroid is a growth made from the muscle of the womb. It "
              "isn't cancer. It can be as small as a seed or as big as a "
              "melon, and you can have one or several."),
          _en("Fibroids grow with the hormone oestrogen. That's why they often "
              "grow during the years you have periods and shrink after the "
              "menopause. Nobody knows exactly what starts them, but they often "
              "run in families."),
        ],
      ),
      PvReadSection(
        heading: _en('Which fibroids affect getting pregnant?'),
        paragraphs: [
          _en("Doctors describe fibroids by where they are. For fertility this "
              "matters more than size, because what counts is whether the "
              "fibroid changes the space where an embryo would settle."),
        ],
        bullets: [
          _en("Submucosal fibroids bulge into the inside of the womb. These "
              "are the ones most likely to affect implantation and raise the "
              "risk of miscarriage, and removing them can help."),
          _en("Intramural fibroids sit within the muscle wall. Small ones "
              "usually don't matter. Larger ones may, and doctors weigh each "
              "case on its own."),
          _en("Subserosal fibroids grow on the outside of the womb. They "
              "usually don't affect getting pregnant at all."),
          _en("Pedunculated fibroids hang on a stalk, inside or outside the "
              "womb. Which side they hang on decides whether they matter."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('A fibroid on the outside usually does no harm'),
          body: _en("If your report says subserosal, the fibroid is on the "
              "outer surface of the womb. These rarely affect getting "
              "pregnant, and your doctor may just keep an eye on it."),
        ),
      ),
      PvReadSection(
        heading: _en('What does a fibroid feel like?'),
        paragraphs: [
          _en("Many fibroids cause no symptoms at all. When they do, heavy "
              "periods are the most common sign. You might pass clots, need to "
              "change pads very often, or bleed for more than a week. Other "
              "signs include:"),
        ],
        bullets: [
          _en('Tiredness or breathlessness from low iron, because of heavy '
              'bleeding.'),
          _en('A feeling of pressure or fullness low in your tummy.'),
          _en('Needing to pass urine often, or constipation.'),
          _en('Back pain, or pain during sex.'),
        ],
      ),
      PvReadSection(
        heading: _en('Are fibroids dangerous?'),
        paragraphs: [
          _en("Fibroids aren't cancer, and a growth that looks like a fibroid "
              "is very rarely anything else. The real problems are heavy "
              "bleeding and anaemia, and both can be treated. So heavy periods "
              "are always worth mentioning."),
          _en("A fibroid with no symptoms that doesn't touch the inside of the "
              "womb often needs nothing more than a check now and then."),
          _en("There's no proven way to prevent fibroids. Staying active and "
              "at a healthy weight is good for you anyway and may help a "
              "little, but the evidence is limited. Having fibroids isn't "
              "something you caused."),
        ],
      ),
      PvReadSection(
        heading: _en('Which treatment is right if I want a baby?'),
        paragraphs: [
          _en("Fibroid treatments differ a lot in what they mean for a future "
              "pregnancy. Before agreeing to any of them, ask your doctor one "
              "question: will this affect my ability to carry a baby?"),
        ],
        bullets: [
          _en("Watching and waiting. Many fibroids need no treatment, and you "
              "keep trying."),
          _en("Hysteroscopic removal. A thin camera goes through the vagina "
              "into the womb to remove fibroids that bulge inside. There are no "
              "cuts on your tummy, and most women go home the same day."),
          _en("Myomectomy. The fibroids are removed by keyhole or open surgery "
              "and the womb is kept. You may be asked to wait a few months "
              "before trying, and some women are advised to have a caesarean "
              "later."),
          _en("Medicines. Some ease heavy bleeding or shrink fibroids for a "
              "while. Most stop ovulation or aren't used while trying, so they "
              "tend to be a short bridge, not a fertility treatment."),
          _en("Treatments not usually offered if you want a baby. Blocking the "
              "fibroid's blood supply, called embolisation, isn't usually the "
              "first choice when pregnancy is planned. Removing the womb ends "
              "the possibility of pregnancy."),
        ],
      ),
      PvReadSection(
        heading: _en('What are uterine polyps?'),
        paragraphs: [
          _en("A polyp is a small, soft growth that hangs from the lining of "
              "the womb. Most are harmless and aren't cancer. They're often "
              "found on a scan during fertility checks."),
          _en("Polyps can cause bleeding between periods, spotting after sex "
              "or heavier periods. Some cause nothing. A polyp may get in the "
              "way of implantation, a bit like a fibroid that bulges inside."),
          _en("They're usually removed with a hysteroscopy, the same camera "
              "through the vagina. It's quick and often done as a day "
              "procedure, and many doctors do it before IUI or IVF. Small "
              "polyps sometimes go away on their own."),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('What changes if you get pregnant with a fibroid, and '
            'why most pregnancies still go normally.'),
        heading: _en('What if I get pregnant with a fibroid?'),
        paragraphs: [
          _en("Most women with fibroids have normal pregnancies. Some fibroids "
              "grow a little in early pregnancy. A few cause pain, which is "
              "usually managed with rest and pain relief your doctor "
              "approves."),
          _en("Large fibroids can sometimes affect the baby's position or how "
              "the birth happens. Your doctor will keep an eye on this through "
              "your pregnancy scans."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en("Will I need a caesarean if I've had fibroids removed?"),
        answer: _en("Not always. It depends on how deep the surgery went into "
            "the muscle of the womb. Ask your surgeon to write this down after "
            "the operation, so whoever looks after your pregnancy knows."),
      ),
      PvReadFaq(
        question: _en('Can fibroids come back after they are removed?'),
        answer: _en("Yes, new fibroids can grow over time. That's one reason "
            "doctors often suggest trying for a pregnancy fairly soon after "
            "the recovery period."),
      ),
      PvReadFaq(
        question: _en('Does a fibroid mean I will miscarry?'),
        answer: _en("No. Most women with fibroids don't miscarry because of "
            "them. Fibroids that bulge into the inside of the womb are linked "
            "to a higher risk, which is why doctors may suggest removing "
            "those before you try."),
      ),
      PvReadFaq(
        question: _en('I bleed a little after sex. Could it be a polyp?'),
        answer: _en("It could be. There are other causes too, including "
            "infections and changes on the cervix, so it isn't something to "
            "guess about. Book a gynaecologist visit and mention it, even if "
            "it has happened only a few times."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See a gynaecologist in the next few weeks if your periods are "
          "heavy or last more than a week, you bleed between periods or after "
          "sex, or you feel tired and breathless. Go to hospital today if "
          "you're soaking through a pad every hour for more than two hours, "
          "feel faint, or have sudden severe tummy pain with fever."),
    ),
    evidence: _en('ASRM Practice Committee, Removal of myomas in asymptomatic '
        'patients to improve fertility and/or reduce miscarriage rate (2017); '
        'ACOG Practice Bulletin 228, Management of symptomatic uterine '
        'leiomyomas (2021); NICE guideline NG88, Heavy menstrual bleeding; RCOG '
        'patient information on hysteroscopy; NHS; StatPearls, Endometrial '
        'Polyp. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your scan reports together'),
        value: _en('Size and position change over time, and your doctor will '
            'want to compare.'),
        surfaceId: 'ttc_records',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Plan your gynaecologist visit'),
        value: _en('Note the date and the questions you want answered before '
            'you go.'),
        surfaceId: 'ttc_appointments',
      ),
    ],
    readNext: [
      'ttc_read_slow_conception',
      'ttc_read_endometriosis',
      'ttc_read_ovarian_cysts',
    ],
  ),

  // ===========================================================================
  //  BLOCKED TUBES AND THE HSG — the main tubes piece, written for India
  // ===========================================================================
  //  Hydrosalpinx (P3) folds in as a section. Genital TB and PID each have a
  //  read of their own below, so this one names them as causes and links on.
  PvRead(
    id: 'ttc_read_blocked_tubes_hsg',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Blocked tubes and the HSG test'),
    teaser: _en("Why your fallopian tubes matter, what can block them, how the "
        "dye test works, and the honest options if they're blocked."),
    shortAnswer: _en("Your fallopian tubes are where the egg and sperm meet. "
        "If both are blocked, they can't meet, so pregnancy can't happen "
        "naturally. An HSG, a short X-ray with dye, checks whether the tubes "
        "are open, and IVF can work even when they aren't."),
    scaleSetter: _en("Tube problems are a common reason for trouble "
        "conceiving, and there are clear answers for them. One blocked tube "
        "often leaves the other working. When both are blocked, IVF goes "
        "around the tubes altogether."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Most of us never think about our fallopian tubes until a "
              "doctor mentions them. They're two thin tubes, one on each side, "
              "that run from the top of the womb out towards the ovaries."),
          _en("They're easy to forget because you can't feel them working. "
              "That's also why a problem in them usually shows up only as "
              "time passing without a pregnancy."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do the tubes matter so much?'),
        paragraphs: [
          _en("Each month the open end of a tube picks up the egg released by "
              "the ovary. Sperm swim up through the womb into the tube, and "
              "fertilisation happens there. The tube then carries the early "
              "embryo down to the womb over a few days."),
          _en("If a tube is blocked, the egg and sperm can't meet on that "
              "side. If it's damaged but still partly open, an embryo can get "
              "stuck on the way. That's an ectopic pregnancy, which is why "
              "damaged tubes need a doctor's eye."),
          _en("Tube problems are behind a good share of female infertility, "
              "often quoted as about a quarter to a third of cases."),
        ],
      ),
      PvReadSection(
        heading: _en('What blocks the tubes?'),
        paragraphs: [
          _en("Most blocked tubes come from past inflammation or scarring. "
              "Often there were no symptoms at the time, so many women have no "
              "idea until a test shows it. Common causes are:"),
        ],
        bullets: [
          _en("A past pelvic infection, called PID. This is often from an "
              "infection such as chlamydia that caused few or no symptoms."),
          _en("Genital TB. This is an important cause in India, and it can "
              "scar both the tubes and the lining of the womb."),
          _en('Endometriosis, which can cause scar tissue around the tubes.'),
          _en("Past surgery in the tummy or pelvis, a burst appendix, or a "
              "previous ectopic pregnancy."),
          _en('An infection after a delivery, a miscarriage or an abortion.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('This is not your fault'),
          body: _en("Infections that affect the tubes are common and are often "
              "silent. Where the damage came from matters much less now than "
              "what you do next."),
        ),
      ),
      PvReadSection(
        heading: _en('What is a hydrosalpinx?'),
        paragraphs: [
          _en("Sometimes the end of the tube near the ovary seals shut and "
              "fills with fluid. This is called a hydrosalpinx. It may show on "
              "an ordinary scan as a swollen, sausage-shaped tube."),
          _en("The fluid can leak back into the womb and make it harder for an "
              "embryo to settle, even during IVF. So doctors often advise "
              "removing or clipping a tube like this before IVF. It sounds "
              "drastic, but research shows it improves IVF results."),
        ],
      ),
      PvReadSection(
        heading: _en('How does the HSG test work?'),
        paragraphs: [
          _en("HSG stands for hysterosalpingography. A thin tube is passed "
              "through your cervix, and a dye is gently pushed into the womb. "
              "X-ray pictures show whether the dye flows out through both "
              "tubes. This is what to expect:"),
        ],
        bullets: [
          _en("It's done after your period ends and before you ovulate, "
              "usually around day 6 to 10 of your cycle, so you can't be "
              "pregnant at the time."),
          _en('It takes about 10 to 15 minutes, and you go home the same day.'),
          _en("It can cause cramps like period pain. Ask your doctor whether "
              "you can take a painkiller an hour before."),
          _en("Some spotting and mild cramps for a day or two afterwards are "
              "normal."),
          _en("Some clinics give an antibiotic, or test for an infection such "
              "as chlamydia first, so the dye doesn't spread one that's "
              "already there."),
        ],
        tip: PvReadTip(
          title: _en('Take someone with you'),
          body: _en("Most women feel fine to go home straight after. It's still "
              "nice to have someone with you, and to keep the rest of the day "
              "easy."),
        ),
      ),
      PvReadSection(
        heading: _en('Can the result be wrong?'),
        paragraphs: [
          _en("Yes, sometimes. An HSG can show a tube as blocked when it "
              "isn't, because the tube tightened for a moment during the test. "
              "So a 'blocked' result is often confirmed with another test "
              "before big decisions are made."),
          _en("Other ways to check are a special ultrasound with fluid, called "
              "HyCoSy or SSG, and a laparoscopy with dye. The laparoscopy is "
              "keyhole surgery. It gives the clearest answer and can treat "
              "problems like endometriosis at the same time."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my tubes are blocked?'),
        paragraphs: [
          _en("The options depend on how many tubes are affected, where the "
              "block is, your age and your other results. Your doctor will look "
              "at all of it together."),
        ],
        bullets: [
          _en("One blocked tube. The other tube can still pick up eggs, and "
              "many women conceive naturally. Ovulation tablets or IUI may be "
              "suggested to help."),
          _en("A block near the womb. This can sometimes be opened with a fine "
              "wire passed through the cervix, called tubal cannulation."),
          _en("Mild damage near the ovary end. Surgery to repair it is "
              "possible in a few cases, though the risk of an ectopic "
              "pregnancy afterwards is higher."),
          _en("Both tubes blocked or badly damaged. IVF is usually the most "
              "direct route. The egg is collected and fertilised outside the "
              "body, and the embryo is placed straight into the womb."),
          _en("Age matters too. If you're in your late thirties, or other tests "
              "also show problems, doctors may suggest going straight to IVF "
              "rather than spending months on surgery and waiting."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("IVF doesn't need your tubes"),
          body: _en("In IVF the tubes aren't used at all. IVF was first "
              "developed for women with blocked tubes, and it works well for "
              "them."),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does an HSG hurt?'),
        answer: _en("It's usually more uncomfortable than painful, like strong "
            "period cramps for a few minutes. A painkiller taken beforehand "
            "helps many women. If it hurts a lot, say so during the test, so "
            "the doctor can go slower."),
      ),
      PvReadFaq(
        question: _en('Can the HSG itself open my tubes?'),
        answer: _en("The dye can sometimes clear a small plug of mucus, and a "
            "few women conceive in the months after. It isn't a treatment for "
            "a real blockage, though, and shouldn't be relied on as one."),
      ),
      PvReadFaq(
        question: _en('Can I get pregnant naturally with one tube?'),
        answer: _en("Yes. Many women with one working tube get pregnant "
            "naturally. If it's been a while, your doctor may suggest tablets "
            "or IUI to help things along."),
      ),
      PvReadFaq(
        question: _en('After damaged tubes, should I have an early scan?'),
        answer: _en("Yes, it's a good idea. Damaged tubes raise the risk of an "
            "ectopic pregnancy, so tell your doctor as soon as your test is "
            "positive. An early scan checks the pregnancy is in the womb."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help fast'),
      body: _en("Call your doctor the same day if you get a fever, worsening "
          "tummy pain or smelly discharge in the days after an HSG. If you're "
          "pregnant or your period is late and you have severe one-sided "
          "tummy pain, pain at the tip of your shoulder, heavy bleeding, or "
          "you feel faint, go to hospital today. These can be signs of an "
          "ectopic pregnancy."),
    ),
    evidence: _en('ASRM Practice Committee, Role of tubal surgery in the era '
        'of assisted reproductive technology (2021); NICE guideline CG156, '
        'Fertility problems: assessment and treatment; Cochrane review, '
        'Surgical treatment for tubal disease in women due to undergo IVF; '
        'ACOG patient FAQ, Hysterosalpingography; StatPearls, '
        'Hysterosalpingography. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See which tests check your tubes'),
        value: _en('Where the HSG fits among the first tests, and when it is '
            'usually booked.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Look at the treatment routes'),
        value: _en('Tablets, IUI and IVF side by side, so the options feel '
            'less new when your doctor names them.'),
        surfaceId: 'ttc_treatment',
      ),
    ],
    readNext: [
      'ttc_read_genital_tb',
      'ttc_read_pelvic_infection',
      'ttc_read_ivf_explained',
    ],
  ),

  // ===========================================================================
  //  HIGH PROLACTIN
  // ===========================================================================
  PvRead(
    id: 'ttc_read_high_prolactin',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('High prolactin and trying to conceive'),
    teaser: _en('What prolactin is, why a high level can stop ovulation, and '
        'why the fix is often a simple tablet.'),
    shortAnswer: _en("Prolactin is the hormone that makes breast milk. When "
        "it's high outside pregnancy and breastfeeding, it can switch off "
        "ovulation, so periods become irregular or stop. Once the cause is "
        "found, treatment usually brings ovulation back."),
    scaleSetter: _en("A high prolactin result is a common finding on "
        "fertility tests, and it's one of the most treatable causes of trouble "
        "conceiving. Sometimes it's a one-off reading. When it's real, a "
        "tablet usually works well."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Prolactin is made by the pituitary, a pea-sized gland at the "
              "base of your brain. Its main job is making milk after birth. It "
              "also keeps ovulation switched off while you breastfeed, which is "
              "partly why periods take a while to return after a baby."),
          _en("When prolactin is high at other times, it can do the same "
              "thing. That's how it gets in the way of trying."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does high prolactin stop ovulation?'),
        paragraphs: [
          _en("Prolactin acts on the part of the brain that starts each "
              "cycle. When it's high, the brain sends out fewer of the signals "
              "that tell the ovaries to grow an egg. So no egg ripens, none is "
              "released, and the period that would follow comes late or not "
              "at all."),
          _en("This is how the body spaces out babies while a mother "
              "breastfeeds. Outside that time, it's a signal arriving at the "
              "wrong moment, not damage. Once prolactin comes down, the "
              "signals usually come back."),
        ],
      ),
      PvReadSection(
        heading: _en('What are the signs of high prolactin?'),
        paragraphs: [
          _en("Some women have no signs at all. Others notice some of these:"),
        ],
        bullets: [
          _en('Irregular periods, very light periods, or periods that stop.'),
          _en("A milky discharge from the nipples when you're not "
              "breastfeeding."),
          _en('Less interest in sex, or vaginal dryness.'),
          _en('Headaches or changes in your vision, which are less common.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Men can have it too'),
          body: _en("In men, high prolactin can lower sex drive, cause "
              "erection problems and affect sperm. It's checked with the same "
              "blood test."),
        ),
      ),
      PvReadSection(
        heading: _en('What makes prolactin go up?'),
        paragraphs: [
          _en("Prolactin is naturally high in pregnancy and while "
              "breastfeeding, so a raised result at those times is expected."),
          _en("Many things can raise it, and some are harmless. That's why "
              "doctors look for the cause before treating it:"),
        ],
        bullets: [
          _en("Stress, poor sleep, hard exercise, or sex or breast touching "
              "shortly before the test. Even a difficult blood draw can nudge "
              "it up."),
          _en("Some medicines, including certain tablets for nausea and "
              "acidity, depression, other mental health conditions and blood "
              "pressure."),
          _en("An underactive thyroid. Treating the thyroid often brings "
              "prolactin back down."),
          _en('Kidney or liver problems, less often.'),
          _en("A prolactinoma. This is a small growth on the pituitary gland "
              "that isn't cancer, and it's a common cause of a level that "
              "stays high."),
        ],
      ),
      PvReadSection(
        heading: _en('How is it tested?'),
        paragraphs: [
          _en("It's a simple blood test. Because so many things nudge "
              "prolactin up, how the test is done matters. A mildly high "
              "result is often repeated before anyone makes a plan."),
          _en("Sometimes a large, inactive form of prolactin shows up on the "
              "test. It makes the number look high but causes no trouble. The "
              "lab can check for it. It's called macroprolactin."),
          _en("If the level stays high, your doctor may check your thyroid. If "
              "prolactin is quite high, or you have headaches or vision "
              "changes, they may suggest an MRI scan of the pituitary gland."),
        ],
        tip: PvReadTip(
          title: _en('Getting a fair reading'),
          body: _en("Book the test for mid-morning if you can, since prolactin "
              "runs higher during sleep and just after waking. Sit and rest "
              "for a little while before the blood is taken. Avoid hard "
              "exercise and breast stimulation the day before, and tell the "
              "lab about any medicines you take."),
        ),
      ),
      PvReadSection(
        heading: _en('How is high prolactin treated?'),
        paragraphs: [
          _en("If a medicine or your thyroid is the cause, fixing that often "
              "fixes prolactin. If not, the usual treatment is a tablet such "
              "as cabergoline or bromocriptine. These lower prolactin, and in "
              "most women periods and ovulation come back."),
          _en("Cabergoline is usually taken once or twice a week. Some women "
              "feel sick or dizzy at first, which tends to settle. Taking it "
              "with food at bedtime can help."),
          _en("Your doctor will recheck prolactin a few weeks after you start, "
              "and adjust the dose if needed. Many women see their periods "
              "return within a few months."),
          _en("Once periods are back, you can usually keep trying as normal "
              "unless your doctor says otherwise. Some women also need "
              "ovulation tablets for a while."),
          _en("A prolactinoma usually shrinks with these tablets, and surgery "
              "is rarely needed."),
        ],
        mythFact: PvMythFact(
          myth: _en("A growth on the pituitary means a brain tumour, and "
              "that's always serious."),
          fact: _en("Prolactinomas are almost always small and aren't cancer. "
              "Most shrink with tablets, and many women who have one go on to "
              "have babies."),
        ),
      ),
      PvReadSection(
        heading: _en('What happens if I get pregnant on treatment?'),
        paragraphs: [
          _en("Many women are told to stop the tablet once a pregnancy is "
              "confirmed. That depends on the size of any growth and on your "
              "doctor's plan, so don't stop or change it on your own. Tell "
              "your doctor as soon as your test is positive."),
          _en("If you had a larger prolactinoma, your doctor will keep a "
              "closer eye on you during pregnancy, because it can grow a "
              "little. Tell them straight away about bad headaches or changes "
              "in your sight."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I tell my doctor?'),
        paragraphs: [
          _en("A few details make the result much easier to read. Bring these "
              "to your visit:"),
        ],
        bullets: [
          _en("Every medicine and supplement you take, including ones from the "
              "chemist."),
          _en('When your periods started to change.'),
          _en('Any nipple discharge, headaches or changes in your sight.'),
          _en("Whether you've had thyroid or kidney problems."),
          _en("Whether you might be pregnant, or have breastfed in the last "
              "year or so."),
          _en("Earlier test reports, so your doctor can see whether the level "
              "is rising, falling or steady."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is the milky discharge from my nipples dangerous?'),
        answer: _en("It isn't harmful on its own. It's a sign that prolactin "
            "may be high, so it's worth mentioning to your doctor. Try not to "
            "squeeze to check, as that can keep it going."),
      ),
      PvReadFaq(
        question: _en('Could a tablet I take for acidity or nausea be the cause?'),
        answer: _en("Some can. Domperidone and metoclopramide, often taken for "
            "nausea and acidity, are known to raise prolactin. Show your "
            "doctor everything you take, including tablets from the chemist, "
            "and don't stop a prescribed medicine without asking first."),
      ),
      PvReadFaq(
        question: _en('Will I have to take the tablet for life?'),
        answer: _en("Usually not. Many women take it for a while, then stop "
            "under their doctor's care once levels have settled or they're "
            "pregnant. Some need it again later."),
      ),
      PvReadFaq(
        question: _en('My prolactin was slightly high once. Should I worry?'),
        answer: _en("A single, slightly high result is common and is often "
            "normal when repeated. Ask for a repeat test before starting any "
            "treatment."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See your doctor in the next few weeks if your periods become "
          "irregular or stop, or you notice a milky nipple discharge when "
          "you're not breastfeeding. See a doctor the same day if you have a "
          "sudden, severe headache, or you lose part of your vision, such as "
          "the edges of what you can see."),
    ),
    evidence: _en('Endocrine Society clinical practice guideline, Diagnosis '
        'and treatment of hyperprolactinemia (2011); Pituitary Society '
        'consensus statement on the diagnosis and management of prolactin '
        'secreting pituitary tumours (2023); StatPearls, Hyperprolactinemia; '
        'Cleveland Clinic. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See the first hormone tests'),
        value: _en('Prolactin, thyroid and the others, and what each one '
            'answers.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Note your cycles for your doctor'),
        value: _en('A few months of dates shows whether treatment is bringing '
            'your periods back.'),
        surfaceId: 'ttc_cycle',
      ),
    ],
    readNext: [
      'ttc_read_thyroid_tsh',
      'ttc_read_slow_conception',
    ],
  ),

  // ===========================================================================
  //  GENITAL TB — common in India, easy to miss and easy to over-diagnose
  // ===========================================================================
  //  ⚠️ BOTH FAILURE MODES ARE IN THE COPY ON PURPOSE. Missing genital TB
  //  costs a woman her tubes; diagnosing it on a blood antibody test or a lone
  //  PCR costs her six months of drugs she did not need. The India TB
  //  guidelines (Index-TB, 2016) caution against both, and so does this read.
  PvRead(
    id: 'ttc_read_genital_tb',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Genital TB and fertility'),
    teaser: _en("Why TB of the womb and tubes matters in India, why it's easy "
        "to miss and easy to over-diagnose, and what treatment can and can't "
        "fix."),
    shortAnswer: _en("Genital TB is tuberculosis that has spread to the tubes "
        "or the lining of the womb. It's more common in India than in many "
        "countries, it often causes no clear symptoms, and it can scar the "
        "tubes. A full course of TB medicines cures it, and these are free at "
        "government centres."),
    scaleSetter: _en("TB of the reproductive organs is serious, but it can be "
        "cured, and treatment is free in India. What matters most is a proper "
        "diagnosis, because missing it and treating it when it isn't there "
        "both cause harm."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("India has more people with TB than any other country. Most of "
              "us think of TB as a cough, but it can also travel through the "
              "blood to other parts of the body, including the reproductive "
              "organs."),
          _en("When it settles there, it's called genital TB. In women it "
              "almost always affects the fallopian tubes, and often the lining "
              "of the womb as well."),
          _en("Genital TB usually shows up years after the first infection, "
              "which often went unnoticed. So you may never have had a TB cough "
              "at all."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does it matter for trying?'),
        paragraphs: [
          _en("Genital TB causes inflammation and scarring. In the tubes, this "
              "can block them. In the womb, it can leave the lining thin or "
              "make the walls stick together, which makes it hard for an "
              "embryo to settle."),
          _en("Indian studies find genital TB in a noticeable share of women "
              "tested for infertility, though the numbers vary a lot between "
              "studies. It's one reason Indian fertility doctors think about it "
              "more than doctors in many other countries."),
          _en("Some women only find out after an HSG or a laparoscopy done for "
              "another reason."),
          _en("Less often it affects the ovaries. It can also make periods "
              "scanty, because a scarred lining can't build up well."),
        ],
      ),
      PvReadSection(
        heading: _en('What are the signs?'),
        paragraphs: [
          _en("Often there are none, which is why it's missed. When there are "
              "signs, they can be vague:"),
        ],
        bullets: [
          _en('Very light periods, irregular periods, or periods that stop.'),
          _en('Pain low in the tummy that keeps coming back.'),
          _en('An unusual discharge.'),
          _en("A low fever in the evenings, night sweats, tiredness or weight "
              "loss."),
          _en('Trying for a long time without getting pregnant.'),
        ],
        tip: PvReadTip(
          title: _en('Mention any past TB'),
          body: _en("Tell your doctor if you've had TB before, or lived with "
              "someone who had it, even if it was years ago. It changes which "
              "tests they think of first."),
        ),
      ),
      PvReadSection(
        heading: _en('Who is more at risk?'),
        paragraphs: [
          _en("Anyone can get TB, but some things make it more likely. These "
              "include having had TB before, living with someone who had it, "
              "being very underweight, diabetes, or a weak immune system, such "
              "as from HIV."),
          _en("Many women with genital TB have none of these. That's why "
              "doctors keep it in mind for anyone whose tubes or lining look "
              "damaged without another clear reason."),
        ],
      ),
      PvReadSection(
        heading: _en('How is it diagnosed?'),
        paragraphs: [
          _en("This is the tricky part, and it's where many women get stuck. "
              "There's no single easy test, and some tests used in the past "
              "aren't reliable."),
          _en("The usual approach is to test a small sample of the womb "
              "lining, taken in a short procedure, often just before a "
              "period. The lab checks it for TB germs in a few ways."),
          _en("These include growing the germs in a culture, a rapid test "
              "called CBNAAT or GeneXpert, and a look at the tissue under the "
              "microscope. A laparoscopy or hysteroscopy can also show signs of "
              "TB, and a chest X-ray checks the lungs."),
          _en("An HSG may show patterns in the tubes that make a doctor think "
              "of TB. These patterns raise the question, but they don't settle "
              "it on their own."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Tests that don't prove genital TB"),
          body: _en("Blood antibody tests for TB aren't reliable, and India "
              "banned them for diagnosing TB in 2012. A positive Mantoux skin "
              "test or IGRA blood test shows you've met TB at some point, which "
              "is true for many Indians, not that it's in your womb. Indian "
              "guidelines also caution against starting treatment on a PCR "
              "result alone."),
        ),
      ),
      PvReadSection(
        heading: _en('How is it treated?'),
        paragraphs: [
          _en("Genital TB is treated with the same standard TB medicines used "
              "for TB in the lungs, usually for six months. Under India's "
              "National TB Elimination Programme, testing and treatment are "
              "free at government centres."),
          _en("There's also a monthly payment to help with nutrition while "
              "you're on treatment. Ask at the TB centre how to register for "
              "it."),
          _en("Finish the full course, even when you feel better. Stopping "
              "early can let TB come back in a form that's harder to treat."),
          _en("The tablets can cause side effects such as nausea, joint pain "
              "or, less often, liver problems. Tell your doctor or the TB "
              "centre about any, rather than stopping. Blood tests may be done "
              "to check your liver."),
          _en("One of the medicines, rifampicin, can turn your urine and tears "
              "orange-red. It's harmless, though it can stain contact lenses."),
        ],
        mythFact: PvMythFact(
          myth: _en("If there's any doubt, it's safer to take TB medicines "
              "anyway."),
          fact: _en("Six months of TB medicines is a lot to go through, and "
              "the tablets have side effects. Treating TB that isn't there "
              "won't help you conceive. A proper diagnosis first protects you."),
        ),
      ),
      PvReadSection(
        heading: _en('Can I get pregnant after genital TB?'),
        paragraphs: [
          _en("The medicines cure the infection, but they can't undo scarring "
              "that has already happened. If the tubes are open and the lining "
              "is healthy, some women conceive naturally after treatment."),
          _en("If the tubes are blocked, IVF is usually the route. If the "
              "lining is badly scarred, it's harder, and your doctor may "
              "suggest a procedure to separate the walls of the womb first. "
              "Finding TB early gives the best start."),
          _en("Ask your doctor when to start trying. Many advise finishing "
              "treatment first, and IVF is usually planned after the course is "
              "complete."),
          _en("If you do get pregnant while on treatment, keep taking the "
              "medicines and tell your doctor straight away. The standard TB "
              "medicines are considered safe in pregnancy, and stopping them "
              "is the bigger risk."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I pass genital TB to my husband?'),
        answer: _en("It's rarely passed on through sex, and it doesn't spread "
            "through everyday contact. If you also have TB in your lungs, that "
            "can spread through coughing, which is why a chest check is part "
            "of the tests."),
      ),
      PvReadFaq(
        // Kept for revert (2026-09-28, no repetition; the same question is in
        // the recurrent miscarriage read):
        // question: _en('Should my husband be tested too?'),
        question: _en('Should my husband be tested for TB too?'),
        answer: _en("Men can get genital TB too, though it's less common. If "
            "he has symptoms, has had TB before, or his semen test shows "
            "problems, his doctor may check."),
      ),
      PvReadFaq(
        question: _en('I was told I have TB because of a PCR test. What now?'),
        answer: _en("Ask your doctor what else supports the diagnosis, such as "
            "a culture, a GeneXpert result, the look of the tissue, or what "
            "was seen on a laparoscopy. It's fine to get a second opinion "
            "before starting six months of treatment."),
      ),
      PvReadFaq(
        question: _en('Will my family have to know?'),
        answer: _en("Your treatment is confidential. TB is common, curable and "
            "nobody's fault. You decide who you tell."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See a doctor in the next few weeks if your periods have "
          "become very light or stopped, or you've had TB before and are "
          "having trouble conceiving. Get a TB check soon, free at government "
          "centres, if you've had a cough for more than two weeks, evening "
          "fever, night sweats or weight loss. Go to hospital today for severe "
          "tummy pain with a high fever."),
    ),
    evidence: _en('WHO Global Tuberculosis Report; Index-TB Guidelines, '
        'Guidelines on extra-pulmonary tuberculosis for India (Ministry of '
        'Health and Family Welfare, 2016); National TB Elimination Programme, '
        'Government of India; Government of India ban on serological tests '
        'for the diagnosis of TB (2012); ICMR. Sources checked September '
        '2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See the tests that check your tubes'),
        value: _en('What each one shows, and which come first.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your reports in one place'),
        value: _en('A second opinion is much easier when every result is to '
            'hand.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: [
      'ttc_read_blocked_tubes_hsg',
      'ttc_read_slow_conception',
    ],
  ),

  // ===========================================================================
  //  PELVIC INFECTIONS (PID) — salpingitis folds in here
  // ===========================================================================
  //  ⚠️ NO BLAME, IN EITHER DIRECTION. Most of these infections were silent
  //  and may be years old; the copy says so before it says anything about sex,
  //  and the myth block is there because the shame is what stops women
  //  mentioning a past infection to the doctor who needs to know.
  PvRead(
    id: 'ttc_read_pelvic_infection',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Pelvic infections (PID) and fertility'),
    teaser: _en('What a pelvic infection is, why quick treatment protects your '
        'tubes, and how to talk about it without shame.'),
    shortAnswer: _en("PID is an infection of the womb, tubes or ovaries, "
        "usually caused by germs that travel up from the vagina. Treated early "
        "with antibiotics, it often leaves no lasting harm. Untreated or "
        "repeated infections can scar the tubes and make getting pregnant "
        "harder."),
    scaleSetter: _en("If you've had PID in the past, it doesn't mean you can't "
        "get pregnant. Many women who've had it conceive naturally. It's worth "
        "telling your doctor, so they can check your tubes if things take a "
        "while."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("PID stands for pelvic inflammatory disease. The name sounds "
              "alarming, but it means an infection that has spread from the "
              "vagina or cervix up into the womb, the tubes or the ovaries."),
          _en("It's common and treatable, and there's nothing shameful about "
              "it. Gynaecologists see it every week."),
        ],
      ),
      PvReadSection(
        heading: _en('What causes PID?'),
        paragraphs: [
          _en("Often it starts with an infection passed on during sex, such as "
              "chlamydia or gonorrhoea. These can cause few or no symptoms, so "
              "neither partner may know they ever had one."),
          _en("It can also follow childbirth, a miscarriage, an abortion or a "
              "procedure in the womb, if germs get in while the body heals. "
              "Sometimes germs that normally live in the vagina are the cause."),
          _en("Washing inside the vagina, called douching, can upset its "
              "natural balance and raise the risk."),
          _en("Salpingitis is the word for inflammation of the tubes, and it's "
              "part of PID. It's the part that matters most for fertility."),
          _en("PID isn't caught from toilet seats, swimming pools or shared "
              "towels."),
        ],
        mythFact: PvMythFact(
          myth: _en('Only women with many partners get PID.'),
          fact: _en("Anyone can get PID, including women in a long, faithful "
              "marriage. An infection may have been picked up years earlier by "
              "either partner without anyone knowing, and some cases follow "
              "childbirth or a procedure."),
        ),
      ),
      PvReadSection(
        heading: _en('What does PID feel like?'),
        paragraphs: [
          _en("It can be mild or strong. Some women have no symptoms and only "
              "find out years later, from a test of their tubes. Signs to look "
              "out for include:"),
        ],
        bullets: [
          _en('Pain low in the tummy or pelvis, on one or both sides.'),
          _en('Deep pain during sex.'),
          _en('Unusual discharge, especially yellow, green or bad-smelling.'),
          _en('Bleeding between periods or after sex.'),
          _en('Pain when passing urine.'),
          _en('Fever, feeling unwell, or vomiting in more severe cases.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why is it hard to tell from other pain?'),
        paragraphs: [
          _en("Pain from PID often gets worse during sex or when you move "
              "around, and it can feel like other causes of tummy pain. That's "
              "why a doctor's examination matters more than any list of "
              "symptoms."),
          _en("After a delivery, a miscarriage or a procedure in the womb, "
              "watch for fever, bad-smelling discharge or pain that gets worse "
              "over the following weeks. Get checked quickly if any of these "
              "appear."),
        ],
      ),
      PvReadSection(
        heading: _en('How does it affect fertility?'),
        paragraphs: [
          _en("The infection can leave scar tissue inside the tubes or around "
              "them. That can block the tubes, or slow an embryo on its way to "
              "the womb, which raises the risk of an ectopic pregnancy."),
          _en("About one woman in eight who has had PID has trouble getting "
              "pregnant later. The risk goes up with each repeat infection, and "
              "the longer treatment is delayed. That's why quick treatment "
              "matters so much."),
          _en("One infection that was treated quickly carries much less risk "
              "than several, or one that went untreated for a long time."),
          _en("Scarring can also leave some women with pelvic pain that lasts. "
              "Treating early lowers that risk as well."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Most women treated early are fine'),
          body: _en("Starting antibiotics as soon as PID is suspected gives your "
              "tubes the best protection. Most women treated promptly have no "
              "lasting damage."),
        ),
      ),
      PvReadSection(
        heading: _en('How is PID treated?'),
        paragraphs: [
          _en("PID is treated with antibiotics, usually two or three together, "
              "for about 14 days. Most women are treated at home. You'd be "
              "admitted to hospital if you're very unwell, could be pregnant, "
              "or a pocket of pus, called an abscess, is suspected."),
          _en("Some antibiotics used for PID aren't suitable in pregnancy, so "
              "tell your doctor if you could be pregnant. They'll choose one "
              "that's safe."),
          _en("Your doctor won't wait for test results before starting, "
              "because every day of delay matters for the tubes. A few steps "
              "make the treatment work:"),
        ],
        bullets: [
          _en('Finish the whole course, even once you feel better.'),
          _en("Your partner should be tested and treated too, even if he feels "
              "well. Otherwise the infection can pass back to you."),
          _en("Avoid sex until you've both finished treatment and your doctor "
              "says it's okay."),
          _en("Go back to your doctor if you're not feeling better within "
              "three days."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I had PID in the past?'),
        paragraphs: [
          _en("Tell your doctor, even if it was long ago or you're not sure it "
              "was PID. They may suggest checking your tubes sooner, with an HSG "
              "or another test, rather than waiting the usual time."),
          _en("Having had PID doesn't mean your tubes are damaged. Many "
              "women's tubes are open and working after treatment, and a test "
              "is the only way to know."),
          _en("If you get pregnant, an early scan helps confirm the pregnancy "
              "is in the womb. Ask your doctor whether you need one."),
          _en("Before a procedure like an HSG, some clinics test for infection "
              "or give antibiotics. This lowers the risk of stirring up an old "
              "infection."),
        ],
        tip: PvReadTip(
          title: _en("If you're not sure what you had"),
          body: _en("Many women were treated for 'an infection' years ago "
              "without being told the name. Mention it anyway, with the year "
              "and what you remember. Old prescriptions or discharge papers "
              "help too."),
        ),
      ),
      PvReadSection(
        heading: _en('Can I lower the risk of it happening again?'),
        paragraphs: [
          _en("Yes. Getting any new pain or unusual discharge checked early is "
              "the biggest help. So is making sure both of you finish "
              "treatment, so the infection isn't passed back and forth."),
          _en("Keep intimate washing to plain water on the outside. Skip "
              "vaginal washes, sprays and douches, which can upset the natural "
              "balance inside."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        // Kept for revert (2026-09-28, no repetition; the same question was in
        // the infection-test read on this door):
        // question: _en('How do I bring this up with my husband?'),
        question: _en('How do I tell my husband he needs treating for PID too?'),
        answer: _en("Keep it about health, not blame. You could say the doctor "
            "wants you both treated so the infection doesn't come back. Many "
            "infections cause no symptoms, so neither of you may have known."),
      ),
      PvReadFaq(
        question: _en('Does white discharge mean I have PID?'),
        answer: _en("Some white discharge is normal and changes through your "
            "cycle. Discharge that smells bad, looks green or yellow, or comes "
            "with pain or fever needs a doctor. Only a check can tell what it "
            "is."),
      ),
      PvReadFaq(
        question: _en('Can PID come back?'),
        answer: _en("Yes, if an infection is passed on again or wasn't fully "
            "treated. That's why partner treatment and finishing the course "
            "both matter."),
      ),
      PvReadFaq(
        question: _en('Can I try for a baby straight after treatment?'),
        answer: _en("Usually, once you've both finished treatment and your "
            "doctor is happy the infection has cleared. If it's been a while "
            "without a pregnancy after PID, ask about checking your tubes."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help'),
      body: _en("See a doctor within a day or two if you have pelvic pain with "
          "unusual discharge, pain during sex, or bleeding after sex. Go to "
          "hospital today if you have severe tummy pain, a fever of 38°C or "
          "more, vomiting, or you feel faint. If your period is late or you "
          "could be pregnant and you have one-sided pain, go today, as it could "
          "be an ectopic pregnancy."),
    ),
    evidence: _en('CDC Sexually Transmitted Infections Treatment Guidelines '
        '(2021), Pelvic inflammatory disease; NICE Clinical Knowledge Summary, '
        'Pelvic inflammatory disease; BASHH UK national guideline for the '
        'management of pelvic inflammatory disease (2019); WHO guidance on '
        'sexually transmitted infections; NHS. Sources checked September '
        '2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Plan a doctor visit'),
        value: _en('Note what you remember of the past infection, so nothing '
            'is left out on the day.'),
        surfaceId: 'ttc_appointments',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Bring your partner in'),
        value: _en("Treatment works when you're both treated, and he can "
            'follow along from his own phone.'),
        surfaceId: 'ttc_partner',
      ),
    ],
    readNext: [
      'ttc_read_blocked_tubes_hsg',
      'ttc_read_genital_tb',
    ],
  ),

  // ===========================================================================
  //  THE OVERVIEW — seven things that can slow conception
  // ===========================================================================
  //  The hub of this tab: short on each condition, then onward to its read.
  //  A thin lining and adrenal problems (both P3) live here, and secondary
  //  infertility (the pack's "trouble with a second baby") has its own section.
  //  ⚠️ PCOS IS A POINTER ONLY, to its own door.
  PvRead(
    id: 'ttc_read_slow_conception',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Seven things that can slow conception'),
    teaser: _en('A calm look at the common reasons getting pregnant takes '
        'longer, what each one means, and where to read more.'),
    shortAnswer: _en("Getting pregnant often takes several months even when "
        "nothing is wrong. When it takes longer, the usual reasons are "
        "ovulation, the tubes, endometriosis, the womb, cysts, age or sperm. "
        "Most can be found with simple tests, and many can be treated."),
    scaleSetter: _en("Most couples conceive within a year of trying. If it's "
        "taking longer, that's common too, and there's usually a reason a "
        "doctor can find. This list is here so the words feel less new when "
        "you hear them."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("More than eight in ten couples get pregnant within a year of "
              "regular sex, and about nine in ten within two years. So a few "
              "months without a positive test is normal. It isn't a sign that "
              "something is wrong."),
          _en("When it does take longer, there's usually a reason, and often "
              "more than one small one. These are the seven that doctors check "
              "most often."),
        ],
      ),
      PvReadSection(
        heading: _en('1. Is an egg being released each month?'),
        paragraphs: [
          _en("If an egg isn't released regularly, there's nothing for the "
              "sperm to meet. Signs include periods that come more often than "
              "every 21 days, less often than every 35, or at times you can't "
              "predict."),
          _en("PCOS is the most common cause, and it has its own door in the "
              "app. Thyroid problems and high prolactin are two others. Both "
              "are easy to test and usually easy to treat."),
          _en("Being very underweight, a lot of hard exercise, or eating too "
              "little for a long time can also switch ovulation off. The body "
              "holds back when it thinks food is scarce. Being very overweight "
              "can upset ovulation too."),
        ],
      ),
      PvReadSection(
        heading: _en('2. Are the tubes open?'),
        paragraphs: [
          _en("The egg and sperm meet in the fallopian tubes. Past infections, "
              "including genital TB, endometriosis and earlier surgery can "
              "block or damage them, often without any symptoms. A dye test "
              "called an HSG checks them."),
          _en("One blocked tube often leaves the other working. When both are "
              "blocked, IVF goes around them."),
        ],
      ),
      PvReadSection(
        heading: _en('3. Could it be endometriosis?'),
        paragraphs: [
          _en("Endometriosis is tissue like the womb lining growing outside "
              "the womb. It can cause painful periods and painful sex, and it "
              "can scar the tubes and ovaries. Some women have it with very "
              "little pain."),
          _en("Many women with endometriosis still conceive naturally. When it "
              "is slowing things down, surgery, IUI or IVF can help."),
        ],
      ),
      PvReadSection(
        heading: _en('4. Is something inside the womb in the way?'),
        paragraphs: [
          _en("Fibroids that bulge into the womb, polyps and scar tissue can "
              "make it harder for an embryo to settle. They're usually found on "
              "a scan, and many can be removed with a hysteroscopy, a thin "
              "camera passed through the vagina."),
          _en("You may also hear about a thin lining. The lining thickens "
              "before ovulation, and a scan measures it. Many doctors call it "
              "thin if it's under 7 mm around ovulation."),
          _en("Causes include scarring from past procedures or infection, "
              "including TB, and low oestrogen. Clomiphene, an ovulation "
              "tablet, can thin it in some women. What helps depends on the "
              "cause, so your doctor will guide this."),
        ],
      ),
      PvReadSection(
        heading: _en('5. What about ovarian cysts?'),
        paragraphs: [
          _en("Most cysts on the ovary are part of a normal cycle and go away "
              "on their own. They don't stop a pregnancy. Some kinds, like the "
              "chocolate cysts of endometriosis, can matter more, and your "
              "doctor will explain which kind you have."),
          _en("A repeat scan after your next period usually shows whether a "
              "cyst has gone."),
        ],
      ),
      PvReadSection(
        heading: _en('6. Is age playing a part?'),
        paragraphs: [
          _en("The number and quality of eggs both go down with age, faster "
              "after about 35. That's why doctors suggest seeing someone after "
              "6 months of trying if you're 35 or over, rather than 12."),
          _en("An AMH blood test gives a rough idea of how many eggs are left. "
              "It can't tell whether a pregnancy will happen, so it's only one "
              "piece of the picture."),
        ],
      ),
      PvReadSection(
        heading: _en('7. What about his side?'),
        paragraphs: [
          _en("Sperm problems play a part in about half of couples who find it "
              "hard to conceive. A semen analysis is simple, cheap and worth "
              "doing early. It's fair to test both of you from the start, not "
              "only you."),
          _en("Heat, smoking, heavy drinking, some medicines and being very "
              "overweight can all lower sperm. Many of these improve within "
              "about three months, which is how long new sperm take to form."),
        ],
      ),
      PvReadSection(
        heading: _en("What if it's our second baby?"),
        paragraphs: [
          _en("It can be a shock when a second pregnancy takes longer than the "
              "first. This is called secondary infertility, and it's more "
              "common than people think."),
          _en("Things may have changed since last time: your ages, weight, a "
              "new thyroid problem, an infection or scarring after a delivery, "
              "or changes in his sperm. The same tests apply, and so does the "
              "same kindness towards yourself."),
        ],
      ),
      PvReadSection(
        heading: _en('What if the tests find nothing?'),
        paragraphs: [
          _en("In about one couple in four, all the tests come back normal. "
              "This is called unexplained infertility. It's frustrating, but it "
              "often means there's no big barrier, and many of these couples "
              "go on to conceive, with or without treatment."),
        ],
      ),
      PvReadSection(
        heading: _en('When should we see a doctor?'),
        paragraphs: [
          _en("You don't always need to wait a full year. See a doctor sooner "
              "if any of these apply:"),
        ],
        bullets: [
          _en("You've been trying for 12 months, or 6 months if you're 35 or "
              "over."),
          _en('Your periods are irregular, very far apart, or have stopped.'),
          _en('You have very painful periods or pain during sex.'),
          _en("You've had a pelvic infection, TB, an ectopic pregnancy or "
              "surgery in your tummy."),
          _en("Your partner has had problems or surgery involving his "
              "testicles, or a known sperm issue."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it my fault that this is taking longer?'),
        answer: _en("No. None of these reasons come from something you did or "
            "didn't do. They're health conditions, and they're common. Finding "
            "the reason is the first step to doing something about it."),
      ),
      PvReadFaq(
        question: _en('Could stress be the reason?'),
        answer: _en("Everyday stress hasn't been shown to stop you getting "
            "pregnant. Very high stress over a long time can delay ovulation, "
            "but it's rarely the whole story. If you've been trying a while, "
            "tests will give you more answers than being told to relax."),
      ),
      PvReadFaq(
        question: _en('Can adrenal gland problems affect my cycle?'),
        answer: _en("They can, though they're rare. The adrenal glands make "
            "hormones too, and some conditions of theirs cause irregular "
            "periods and extra hair growth, much like PCOS. If your doctor "
            "suspects one, a blood test can check."),
      ),
      PvReadFaq(
        question: _en('Do we both need tests?'),
        answer: _en("Yes. It's normal for both partners to be checked early. "
            "Testing only one of you can miss half the picture."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("Book a fertility check after 12 months of trying, or 6 months "
          "if you're 35 or over, and sooner if your periods are irregular or "
          "you have a known condition. Go to hospital today if you have severe "
          "tummy pain, heavy bleeding, fever with pelvic pain, or one-sided "
          "pain with a late period or a positive test."),
    ),
    evidence: _en('NICE guideline CG156, Fertility problems: assessment and '
        'treatment; WHO fact sheet, Infertility (2024); ASRM Practice '
        'Committee, Fertility evaluation of infertile women (2021); ESHRE '
        'guideline, Unexplained infertility (2023); Cleveland Clinic. Sources '
        'checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        // Kept for revert (2026-09-28, explicit names): title: _en("Check if it's time to see someone"),
        title: _en('Check whether to see a doctor now'),
        value: _en('A few questions about how long, your age and your cycles, '
            'and a clear answer at the end.'),
        surfaceId: 'ttc_fertility_help',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See the first tests for both of you'),
        value: _en('What each test checks, and which ones come first.'),
        surfaceId: 'ttc_tests',
      ),
    ],
    readNext: [
      'ttc_read_endometriosis',
      'ttc_read_blocked_tubes_hsg',
      'ttc_read_pcos_diagnosed',
    ],
  ),

  // ===========================================================================
  //  OVARIAN CYSTS — added beyond the plan's eight (two P2 pieces, no home)
  // ===========================================================================
  PvRead(
    id: 'ttc_read_ovarian_cysts',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en("Ovarian cysts: which ones matter when you're trying"),
    teaser: _en("What 'cyst' on your scan report usually means, which kinds "
        "can affect getting pregnant, and when to act."),
    shortAnswer: _en("An ovarian cyst is a small sac of fluid on the ovary. "
        "Most are a normal part of your cycle and go away on their own without "
        "affecting fertility. A few kinds, such as the cysts of endometriosis, "
        "can matter more, and your doctor will tell you which you have."),
    scaleSetter: _en("A cyst on a scan report is one of the most common "
        "findings in women your age, and most are harmless. Many disappear "
        "within a cycle or two. Only a small number need treatment."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("It's easy to panic when a scan report says 'cyst'. The word "
              "covers many different things. Most of them are part of how your "
              "ovaries work every month."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do cysts form on the ovary?'),
        paragraphs: [
          _en("Each month an egg grows inside a small sac of fluid called a "
              "follicle. Normally the follicle breaks open to release the egg, "
              "then turns into a small gland that makes progesterone."),
          _en("Sometimes the follicle doesn't break open and keeps growing. Or "
              "the gland left behind fills with fluid or a little blood. Either "
              "way, you get a cyst. These are called functional cysts, and "
              "they're the most common kind."),
          _en("Functional cysts usually shrink on their own within one to "
              "three cycles. They don't affect fertility, and they're a sign "
              "your ovaries are working."),
          _en("A scan done before ovulation may also show a follicle of about "
              "2 cm, sometimes a little more. Some reports call this a cyst, "
              "but it's usually the month's egg getting ready."),
        ],
      ),
      PvReadSection(
        heading: _en('Is it the same as PCOS?'),
        paragraphs: [
          _en("No, though the names are confusing. In PCOS the ovaries have "
              "many small follicles that paused partway. They aren't true "
              "cysts. PCOS has its own door in the app, with reads on what it "
              "means for trying."),
          _en("Some reports mention 'polycystic-looking ovaries' in women who "
              "don't have PCOS. On its own, that look is common and doesn't "
              "mean you have the condition."),
          _en("If you've been told about a cyst and you also have irregular "
              "periods, extra hair growth or acne, ask whether PCOS has been "
              "checked. That's a separate question with its own tests."),
        ],
      ),
      PvReadSection(
        heading: _en('What does a cyst feel like?'),
        paragraphs: [
          _en("Most cysts cause no symptoms and are found on a routine scan. "
              "Larger ones can cause a dull ache or heaviness on one side, "
              "bloating, pain during sex, or needing to pass urine often."),
          _en("Pain on one side around the middle of your cycle is often just "
              "ovulation. Keeping a note of when the pain comes helps your "
              "doctor tell the two apart."),
        ],
      ),
      PvReadSection(
        heading: _en('Which cysts can affect getting pregnant?'),
        paragraphs: [
          _en("A few kinds deserve a closer look:"),
        ],
        bullets: [
          _en("Endometriomas, or chocolate cysts. These are filled with old "
              "blood and are caused by endometriosis. They can come with pain "
              "and may lower the number of eggs in that ovary."),
          _en("Dermoid cysts. These are harmless growths that can contain "
              "tissue such as hair or fat. They don't usually affect fertility, "
              "but may need removing if they grow, because a large cyst can "
              "twist the ovary."),
          _en("Cystadenomas. These grow from the surface of the ovary and can "
              "get large. They're usually not cancer, but they're often "
              "removed."),
          _en("Haemorrhagic cysts. These are functional cysts with a little "
              "bleeding inside. They can hurt, but usually settle by "
              "themselves."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('About the CA-125 blood test'),
          body: _en("This test is sometimes added when a cyst is found. It can "
              "be raised by many harmless things, including endometriosis and "
              "your period, so your doctor reads it alongside the scan, never "
              "on its own."),
        ),
      ),
      PvReadSection(
        heading: _en('What happens next?'),
        paragraphs: [
          _en("Most cysts are watched rather than treated. Your doctor may ask "
              "for a repeat scan after your next period, often in 6 to 12 "
              "weeks, to see whether it has gone. You can usually keep trying "
              "meanwhile. Ask if they'd like you to wait."),
          _en("Write down the size given on your report, so you can compare "
              "it with the next one."),
          _en("If a cyst is causing pain, a hot water bottle and pain relief "
              "your doctor approves often help while it settles."),
          _en("If a cyst needs removing, keyhole surgery can usually take out "
              "the cyst and keep the ovary. Surgery can lower your egg supply, "
              "though, so fertility doctors think carefully before operating "
              "on a cyst in a woman who is trying."),
        ],
        tip: PvReadTip(
          title: _en('Questions to ask at your visit'),
          body: _en("What kind of cyst do you think it is? Do I need a repeat "
              "scan, and when? Can we keep trying meanwhile? If surgery is "
              "suggested, how will it affect my eggs?"),
        ),
      ),
      PvReadSection(
        heading: _en("What if I'm having IVF?"),
        paragraphs: [
          _en("Before IVF, your doctor will look at any cysts on the scan. "
              "Small functional cysts are often left to settle, and treatment "
              "may wait a cycle."),
          _en("Endometriomas aren't always removed before IVF, because surgery "
              "can lower the egg count. The decision depends on size, pain, and "
              "whether the cyst would get in the way of collecting eggs."),
        ],
      ),
      PvReadSection(
        heading: _en('Could a cyst be serious?'),
        paragraphs: [
          _en("In women of childbearing age, cancer in an ovarian cyst is "
              "rare. Doctors look for certain features on the scan, such as "
              "solid parts, that make them want to check further. If that "
              "happens, they'll explain each step."),
          _en("The more urgent risk is twisting. A larger cyst can make the "
              "ovary twist on itself and cut off its own blood supply. That "
              "causes sudden, severe pain and needs surgery the same day to save "
              "the ovary."),
          _en("A cyst can also burst. This can cause sudden pain, and "
              "sometimes bleeding inside that needs hospital care."),
          _en("In early pregnancy, a cyst on the ovary is common. It usually "
              "supports the pregnancy and fades by itself in the months that "
              "follow."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can a cyst stop me getting pregnant this month?'),
        answer: _en("A functional cyst usually doesn't. You can still ovulate, "
            "from either ovary. If the cyst is large or you have pain, ask your "
            "doctor whether to wait a cycle."),
      ),
      PvReadFaq(
        question: _en('Will my cyst turn into cancer?'),
        answer: _en("Functional cysts don't turn into cancer. Other kinds are "
            "very rarely cancer in women your age, and your doctor will check "
            "any that look unusual."),
      ),
      PvReadFaq(
        question: _en('Is it safe to have sex with a cyst?'),
        answer: _en("Usually yes. If a cyst is large, your doctor may advise "
            "avoiding very vigorous exercise or sex until it's sorted, because "
            "of the small risk of twisting. If sex hurts, stop and mention it "
            "at your next visit."),
      ),
      PvReadFaq(
        question: _en('Do I need surgery?'),
        answer: _en("Most women don't. Surgery is for cysts that are large, "
            "painful, growing, not going away, or unusual on the scan."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help'),
      body: _en("See your doctor in the next few weeks if you have a dull ache "
          "on one side that keeps coming back, bloating that doesn't go, or "
          "pain during sex. Go to hospital today if you have sudden, severe "
          "pain low on one side, especially with vomiting, fever or feeling "
          "faint. If you could be pregnant and have one-sided pain, go today "
          "too."),
    ),
    evidence: _en('ACOG Practice Bulletin 174, Evaluation and management of '
        'adnexal masses (2016); RCOG Green-top Guideline 62, Management of '
        'suspected ovarian masses in premenopausal women; ESHRE guideline, '
        'Endometriosis (2022); NHS; Cleveland Clinic. Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Note when the pain comes'),
        value: _en('Pain logged against your cycle helps your doctor tell a '
            'cyst from ovulation.'),
        surfaceId: 'ttc_symptom_log',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your scan reports together'),
        value: _en('A repeat scan means most when it can be set beside the '
            'first.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: [
      'ttc_read_endometriosis',
      'ttc_read_pcos_diagnosed',
      'ttc_read_slow_conception',
    ],
  ),
];
