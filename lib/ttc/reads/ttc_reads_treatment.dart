// =============================================================================
//  IVF & IUI — the treatment-round reads (gaps G1 to G12)
// -----------------------------------------------------------------------------
//  Written 2026-09-26 from `docs/TTC-TREATMENT-FLOW.md` §1 (how a round unfolds
//  in India) and §3b (the twelve content gaps a running round exposed). Each
//  read here belongs to one step of a clinic round, so the round can put the
//  right piece in front of her on the right day. P1 first (G4, G8, G9, G10,
//  G11), then the rest in gap order.
//
//  ⚠️ THE CLINIC OWNS EVERY DATE (CLAUDE.md, clinical ownership). These reads
//  EXPLAIN, REMIND and help her PREPARE. They never give a date, a dose or a
//  step as hers, never read her beta number, never say what a delay means,
//  and never give her a chance of success. Every timing is "as your clinic
//  tells you"; typical ranges are said to be typical.
//
//  ⚠️ FACTS MARKED "(confirm)" IN THE FLOW DOC ARE WRITTEN CONSERVATIVELY and
//  go to Dr Surbhi Sharma before shipping: IUI timing after the trigger, the
//  day count of progesterone before a frozen transfer, the natural-cycle FET
//  gap, how long progesterone continues after a positive, when a period comes
//  after stopping it, and how many IUI attempts clinics usually suggest.
//
//  English only (CLAUDE.md, "New work is English"). `_en` marks the Hindi owed.
//  Nothing outside the aggregator should import this file.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// Private and duplicated per file, on purpose (see `ttc_reads_ivf.dart`).
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsTreatment = [
  // ===========================================================================
  //  G4 · S4 · The trigger shot (P1)
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_trigger_shot',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('The trigger shot: why the time is exact'),
    teaser: _en("What the trigger does, why your clinic gives you a time to the minute, and what to do if something goes wrong."),
    shortAnswer: _en("The trigger is one injection that finishes getting your eggs ready. In IVF, egg collection is booked about 34 to 36 hours after it, so the time your clinic gives you is exact. If you're late, unsure or missed it, call your clinic straight away and let them decide what happens next."),
    scaleSetter: _en("This is one injection, and most people give it without any trouble. It feels bigger than it is because of the exact time. A little planning takes away most of the worry, and every clinic has a plan for when something goes wrong."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("After days of injections and scans, your clinic will call and say it's time for the trigger. Often it comes with a time like 10:15 at night, said very clearly. That can feel like a lot of pressure for one small injection."),
          _en("Here's what the trigger does, why its timing matters so much, and how to make the evening go smoothly. Every time and date in your own cycle comes from your clinic. This read explains them. It doesn't set any."),
        ],
      ),
      PvReadSection(
        heading: _en('What does the trigger shot do?'),
        paragraphs: [
          _en("In a natural cycle, your brain sends a surge of LH, the hormone that makes a ripe egg ready to be released. The trigger does the same job on purpose, at a time your clinic chooses."),
          _en("It starts the last stage of ripening inside each follicle. That takes about a day and a half. After that, the eggs would be released on their own."),
          _en("Clinics use one of two kinds of trigger, and sometimes both together. One is hCG, a hormone very like LH. The other is a medicine that makes your own body release a burst of LH."),
          _en("Your clinic picks the one that suits your cycle. Whichever it is, what you need to do stays the same: give it at the time they gave you."),
        ],
      ),
      PvReadSection(
        heading: _en('Why 34 to 36 hours?'),
        paragraphs: [
          _en("In IVF, the aim is to collect the eggs just before they would be released. So egg collection is booked about 34 to 36 hours after the trigger."),
          _en("Too early, and some eggs may not be ready. Too late, and some may already have left the follicle, where they can't be collected. That's why the clinic works backwards from its theatre slot and gives you a time to the minute."),
          _en("For an IUI, the insemination is usually planned for about a day and a half after the trigger. With tablets and timed sex, your clinic will say which days to have sex, often the day of the trigger and the day after. Go by the times your clinic gives you."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Your clinic's time is the one that counts"),
          body: _en("Every clinic plans this a little differently. If anything you read, including this page, is different from what your clinic told you, follow your clinic."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I get the evening right?'),
        paragraphs: [
          _en("A little planning on the day makes the evening feel much calmer. These steps help most people."),
        ],
        bullets: [
          _en("1. As soon as you get the time, write it down and read it back to the nurse on the phone. Check whether it's morning or night."),
          _en("2. Set two alarms, 15 minutes apart, and tell your partner or whoever is with you."),
          _en("3. Check you have the right medicine and the right dose. The trigger may look different from your daily pens, so ask the clinic to show you."),
          _en("4. If it needs mixing, practise with the nurse or watch the clinic's video well before the evening."),
          _en("5. Keep it stored the way you were told, in the fridge or out of it."),
          _en("6. Ask the clinic ahead of time what counts as late for them, so you're not guessing at night."),
          _en("7. Give it at the time they gave you, then take a photo of the empty pen or vial next to a clock, in case the clinic asks."),
        ],
        tip: PvReadTip(
          title: _en("If you'll be out that evening"),
          body: _en("Plan where you'll give it before you leave home. Many people give it in a clean washroom at a wedding or a family dinner. Nobody needs to know what it is."),
        ),
      ),
      PvReadSection(
        heading: _en("What if I'm late, missed it, or aren't sure it went in?"),
        paragraphs: [
          _en("Call your clinic now, day or night. Most IVF clinics give an emergency number for exactly this. Save it in your phone before trigger night."),
          _en("Don't give a second dose unless the clinic tells you to. Don't try to work out what a delay means by yourself, and don't wait until morning to ask."),
          _en("This happens more often than you'd think. A pen jams, a needle bends, or some medicine leaks back out. Clinics have seen all of it, and calling quickly gives them the most options."),
        ],
        mythFact: PvMythFact(
          myth: _en("If anything goes wrong with the trigger, the whole cycle is ruined."),
          fact: _en("Not always. Your clinic may be able to change the plan or the collection time. Only they can say, which is why the phone call matters more than the worry."),
        ),
      ),
      PvReadSection(
        heading: _en('What happens in the day and a half after?'),
        paragraphs: [
          _en("For most people, not much. You may feel bloated and full, like the last days of injections. Your daily injections usually stop now, but only stop the ones your clinic tells you to stop."),
          _en("The clinic will give you instructions for egg collection day: when to stop eating and drinking, when to arrive, and who should take you home. Keep that message somewhere easy to find."),
          _en("Your partner will usually give his sample that morning. Ask the clinic how many days he should go without ejaculating beforehand, so it isn't a last-minute question."),
        ],
      ),
      PvReadSection(
        heading: _en('Can the trigger affect a pregnancy test?'),
        paragraphs: [
          _en("Yes. If your trigger contains hCG, a home test can pick it up for up to about 10 to 14 days afterwards, depending on the dose. A line in that time may be the medicine, not a pregnancy."),
          _en("That's one reason your clinic gives you a date for a blood test, and why testing early at home can be so confusing. Go by their date."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does the trigger hurt more than the other injections?'),
        answer: _en("Usually not. Some triggers go under the skin like your daily pens, and some go into muscle, which can ache a little more. It's one injection, and it's over quickly."),
      ),
      PvReadFaq(
        question: _en('Can we have sex after the trigger?'),
        answer: _en("Ask your clinic. Before egg collection, many clinics advise against it. With an IUI or timed sex, the advice is different. Their plan for your cycle is the one to follow."),
      ),
      PvReadFaq(
        question: _en('Why did my clinic move the trigger day at the last minute?'),
        answer: _en("Follicles don't always grow on schedule, so the trigger day moves with the scans. A change like this is common and doesn't mean something is wrong."),
      ),
      PvReadFaq(
        question: _en("I have a dull ache on one side after the trigger. Is that normal?"),
        answer: _en("A dull ache and bloating are common as the follicles reach full size. Severe pain, pain that keeps getting worse, or any of the signs below needs a call to your clinic now."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your clinic now, day or night'),
      body: _en("Call straight away if you missed the trigger, gave it late, or aren't sure the full dose went in. Call the same day for severe tummy pain or swelling, vomiting that won't stop, breathlessness, passing much less urine, or gaining two kilos or more in a day or two. These can be signs of OHSS, ovarian hyperstimulation. For trouble breathing or fainting, go to a hospital straight away."),
    ),
    evidence: _en("Trigger timing and the gap before egg collection follow the ESHRE guideline on ovarian stimulation for IVF/ICSI (2019) and ASRM patient information on IVF. How long trigger hCG shows on a test follows StatPearls, “Human Chorionic Gonadotropin” (NCBI Bookshelf). OHSS warning signs follow the RCOG guideline on the management of ovarian hyperstimulation syndrome (2016). Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Add your trigger time'),
        value: _en('So the exact time sits in one place you and your partner can both see.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('OHSS: when to call the clinic'),
        value: _en('The signs worth knowing in the days after the trigger.'),
        surfaceId: 'ttc_read/ttc_read_ivf_ohss',
      ),
    ],
    readNext: [
      'ttc_read_ivf_retrieval',
      'ttc_read_ivf_injections',
      'ttc_read_tx_iui_day',
    ],
  ),

  // ===========================================================================
  //  G8 · S7 · Transfer day and progesterone (P1)
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_transfer_day',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Transfer day, and the progesterone after it'),
    teaser: _en("What happens in the few minutes of an embryo transfer, and why the medicine after it matters so much."),
    shortAnswer: _en("An embryo transfer takes a few minutes, needs no anaesthetic, and feels much like a smear test. Afterwards you can have a normal, gentle day, because bed rest doesn't help. Keep taking your progesterone exactly as your clinic says, until they tell you to stop."),
    scaleSetter: _en("Transfer day is usually one of the easiest days of treatment for your body, even if it's a huge day in every other way. Nothing you're likely to do in the hours after it has been shown to change what happens next."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("After weeks of injections, scans and calls from the lab, transfer day can feel enormous. The procedure itself is short and gentle. Knowing what to expect helps the morning feel calmer."),
          _en("This read covers a fresh or a frozen transfer, because the steps are almost the same. Your clinic will give you your own time and instructions."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens at the transfer?'),
        paragraphs: [
          _en("You'll usually be asked to come with a comfortably full bladder. It helps the doctor see your womb clearly on the tummy scan that guides the transfer."),
          _en("Before it starts, the embryologist will check your name and details with you. They'll often tell you about the embryo being transferred, and some clinics show it to you on a screen."),
          _en("The doctor puts in a speculum, like at a smear test. A very thin, soft tube carries the embryo through the neck of the womb, guided by the scan. It takes a few minutes. Most people feel pressure or a mild cramp, not pain."),
          _en("Afterwards, the embryologist checks the tube under a microscope to make sure the embryo has gone in. Then you can empty your bladder. The embryo is inside the womb, well away from the opening, and standing up or going to the toilet can't move it."),
        ],
      ),
      PvReadSection(
        heading: _en('How many embryos will they put back?'),
        paragraphs: [
          _en("Most clinics now transfer one embryo at a time, especially when it's a day-5 embryo. Twins carry more risk for you and for the babies, so guidelines lean towards one."),
          _en("In India, the ART (Regulation) Act 2021 limits how many embryos can be transferred in one cycle. Your clinic will explain what applies to you and talk it through with you both before the day."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I do for the rest of the day?'),
        paragraphs: [
          _en("Go home and have an ordinary, gentle day. Lying down for hours or days after a transfer hasn't been shown to help, and it can make the wait feel longer. Walking, sitting, climbing stairs and going to the toilet are all fine."),
          _en("Many people go back to desk work the next day. Ask your clinic about heavy lifting, hard exercise, swimming and sex, because advice differs between clinics. Theirs is the one to follow."),
          _en("Eat what you normally eat. No food helps an embryo implant, and there's no food you need to fear because of the transfer."),
          _en("If family wants you to stay in bed for two weeks, it's fine to say that doctors now advise normal, gentle activity. They're asking out of love, and you can answer kindly."),
        ],
        mythFact: PvMythFact(
          myth: _en('You should lie flat and avoid stairs after a transfer.'),
          fact: _en("There's no evidence that this helps, and the embryo can't fall out. Rest if you're tired, and move about as you like."),
        ),
      ),
      PvReadSection(
        heading: _en('Why does progesterone matter so much?'),
        paragraphs: [
          _en("Progesterone is the hormone that gets the lining of the womb ready for an embryo and keeps it ready. In a natural cycle, your ovary makes it after ovulation."),
          _en("After IVF, your own supply may not be enough, because the stimulation and the egg collection change how your body makes it. In a frozen transfer with medicines, your body may make almost none. So the clinic gives it to you."),
          _en("That makes progesterone support one of the most important parts of the cycle. It isn't an extra. Take it exactly as your clinic says."),
        ],
        tip: PvReadTip(
          title: _en('Make every dose easy to remember'),
          body: _en("Set an alarm for each dose and keep a simple tick list on the fridge. Your partner can see it too and remind you."),
        ),
      ),
      PvReadSection(
        heading: _en('What forms does progesterone come in?'),
        collapsible: true,
        summary: _en('Vaginal pessaries or gel, injections, and tablets. Many clinics use two together.'),
        bullets: [
          _en("A pessary, gel or tablet you put into the vagina, often two or three times a day."),
          _en("An injection into the muscle, usually the buttock, once a day. It can leave sore lumps. Ask your clinic whether warmth and gentle massage afterwards are okay."),
          _en("An injection under the skin, given like your stimulation pens."),
          _en("Tablets you swallow, often used alongside another form."),
        ],
        paragraphs: [
          _en("The vaginal kinds can leak a white or creamy discharge. That's the medicine coming out, not the embryo, and it's expected."),
        ],
      ),
      PvReadSection(
        heading: _en('Can progesterone feel like pregnancy?'),
        paragraphs: [
          _en("Yes, very much. Sore breasts, bloating, tiredness, mood changes, constipation and a little spotting can all come from progesterone."),
          _en("So these feelings can't tell you whether the transfer worked, and feeling nothing can't either. Plenty of people feel nothing and are pregnant, and plenty feel everything and aren't. The blood test is the only way to know."),
        ],
      ),
      PvReadSection(
        heading: _en('How long do I keep taking it?'),
        paragraphs: [
          _en("Until the blood test, and after that for as long as your clinic says. If the test is positive, it often carries on for several more weeks. If it's negative, your clinic will tell you when to stop."),
          _en("Never stop progesterone on your own, even if you start bleeding. Call the clinic first. Bleeding while you're on progesterone doesn't always mean the cycle has ended, and only a test can tell."),
          _en("If you miss a dose, don't double the next one unless the clinic says so. Call them and ask what to do."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I sneeze, cough or laugh after the transfer?'),
        answer: _en("Yes. None of these can push an embryo out. The womb is a closed muscle, and the embryo is tucked inside it."),
      ),
      PvReadFaq(
        question: _en('Is it okay to go home by auto or car?'),
        answer: _en("Yes, for ordinary travel in town. A bumpy road can't move an embryo. For a long trip by road or a flight, ask your clinic first."),
      ),
      PvReadFaq(
        question: _en('I had a little bleeding on transfer day. Did it fail?'),
        answer: _en("Not necessarily. A small amount of spotting after the speculum and the tube is common. If bleeding is heavy, or you're worried, call your clinic."),
      ),
      PvReadFaq(
        question: _en('Can I bathe normally?'),
        answer: _en("A normal bath or shower is fine. Many clinics advise avoiding very hot tubs, saunas and swimming pools for a while, so ask yours."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your clinic, or go to hospital today'),
      body: _en("Call your clinic the same day for fever or chills, bleeding like a period or heavier, or tummy pain that's getting worse. Call too for bloating that keeps growing, vomiting, breathlessness or passing much less urine, which can be signs of OHSS. Go to a hospital today for severe pain on one side, pain in the tip of your shoulder, or feeling faint. Ectopic pregnancy is uncommon after IVF, but it can happen."),
    ),
    evidence: _en("Transfer technique and luteal phase support follow the ESHRE guideline on ovarian stimulation for IVF/ICSI (2019) and NICE fertility guideline CG156, which also advises that long bed rest after transfer does not help. Single embryo transfer follows ASRM guidance on the number of embryos to transfer (2021). The limit on embryos transferred follows the Assisted Reproductive Technology (Regulation) Act 2021. Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Your medicines, dose by dose'),
        value: _en('Reminders for every progesterone dose, so none slips.'),
        surfaceId: 'ttc_medication',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Your round, day by day'),
        value: _en('Transfer day, test day and what comes between, in one place.'),
        surfaceId: 'ttc_treatment',
      ),
    ],
    readNext: [
      'ttc_read_tx_wait_after_treatment',
      'ttc_read_tx_frozen_transfer',
      'ttc_read_tx_beta_test',
    ],
  ),

  // ===========================================================================
  //  G9 · S8 · The wait after IVF or IUI (P1)
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_wait_after_treatment',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('The two-week wait after IVF or IUI'),
    teaser: _en("What's happening inside, what the medicines can make you feel, and how to get through the days until the blood test."),
    shortAnswer: _en("The wait runs from your transfer or IUI to the blood test date your clinic gives you, usually about 9 to 14 days. The medicines can cause feelings that seem like pregnancy, so symptoms can't tell you either way. Keep taking everything as prescribed and go by your clinic's test."),
    scaleSetter: _en("Many people say this wait is the hardest part of treatment, harder than the injections. Feeling on edge is normal and doesn't affect the result. Nothing you're likely to do on an ordinary day can harm an embryo."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("The wait after treatment feels different from the wait in a natural month. You've come a long way to get here. And the medicines you're taking can make your body feel different almost every day."),
          _en("This read goes through what's happening, what's normal, and some ways to make the days easier. Your own dates, test day and medicines come from your clinic."),
        ],
      ),
      PvReadSection(
        heading: _en("What's happening in these days?"),
        paragraphs: [
          _en("After a day-5 transfer, the embryo usually starts to attach to the lining of the womb within a day or two. After a day-3 transfer, it takes a couple of days longer, because the embryo keeps growing first."),
          _en("Once it attaches, it starts making hCG, the pregnancy hormone. It takes several more days for enough to build up to show on a blood test. That's why your clinic's test date is set where it is."),
          _en("After an IUI, the timing is like a natural cycle. The egg and sperm meet in the tube, and it's about a week before the embryo reaches the womb and attaches."),
          _en("Your clinic's test date already allows for all of this. There's nothing for you to count or work out, and nothing you need to feel in order for it to be happening."),
        ],
      ),
      PvReadSection(
        heading: _en('Is this symptom a sign?'),
        paragraphs: [
          _en("It's natural to watch every twinge. But in this wait, the medicines you're on cause most of what you feel. Progesterone can bring sore breasts, bloating, cramps, tiredness, spotting and mood swings."),
          _en("Early pregnancy can bring the same things, and so can a period on its way. So no symptom, and no lack of symptoms, can tell you what's happening."),
          _en("That's hard to hear, but it can also be a relief. You don't have to read your body every hour. The blood test will tell you, and until then your body can't."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Feeling nothing is common'),
          body: _en("Plenty of people with a positive result felt nothing at all in the wait. A calm body isn't a sign that it didn't work."),
        ),
      ),
      PvReadSection(
        heading: _en('What if I see spotting or bleeding?'),
        paragraphs: [
          _en("Light spotting in the wait is common. It can come from the vaginal progesterone, from the neck of the womb after the transfer, or sometimes from the embryo attaching. It can be pink, brown or red."),
          _en("Keep taking all your medicines, and call your clinic to tell them. Don't stop anything on your own, even if it looks like your period is starting. Bleeding on progesterone doesn't always mean the cycle has ended."),
          _en("Your clinic may keep your test date as it is, or ask you to come in sooner. Either way, the blood test is what gives the answer."),
        ],
      ),
      PvReadSection(
        heading: _en('Should I test at home?'),
        paragraphs: [
          _en("Most clinics ask you not to. If you had an hCG trigger, it can show on a home test for up to about 10 to 14 days. So an early line may be the medicine, not a pregnancy."),
          _en("An early negative can be wrong too, because the hormone may not have built up yet. A home test in this window can bring a lot of confusion and not much of an answer."),
          _en("If you do test, and many people do, try not to change anything because of it. Keep taking your medicines and go to the blood test as planned."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I do, and what should I leave for now?'),
        bullets: [
          _en("Take every dose of every medicine on time. This matters more than anything else in the wait."),
          _en("Go to work if you'd like to. Many people find the routine helps the days pass."),
          _en("Walk, cook, do gentle yoga and see friends. Ordinary movement is fine."),
          _en("Ask your clinic about hard exercise, heavy lifting, sex, long travel and hot tubs. Advice differs, and theirs is the one to follow."),
          _en("Don't smoke or drink alcohol. Check any new medicine, even a cold tablet, with your clinic or chemist first."),
          _en("Eat as you normally would. There's no special food for this wait, and everyday home food in normal amounts is fine."),
        ],
        paragraphs: [
          _en("Sleep in whatever position is comfortable, and bathe or shower as usual. None of this can reach the embryo."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I get through the days?'),
        paragraphs: [
          _en("Many people find it helps to plan the days, not just wait through them. A film on one evening, dinner with a friend on another, a small outing the day before the test."),
          _en("Decide ahead of time who knows your test date. Fewer people means fewer calls asking for news. It's fine to say, “We'll share when we're ready.”"),
          _en("Talk with your partner about how each of you wants to hear the result, and where you'd like to be. That one talk can make test day much easier."),
          _en("If worry is taking over your sleep or your days, tell your clinic. Most have a counsellor, and asking for one is common."),
        ],
        tip: PvReadTip(
          title: _en('Keep a list for the clinic, not for your body'),
          body: _en("Instead of noting every twinge, jot down questions for your clinic as they come. It gives the worry somewhere useful to go."),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('I have cramps like my period is coming. Has it failed?'),
        answer: _en("Not necessarily. Cramps are common in the wait. They can come from progesterone, from the ovaries settling after collection, and sometimes from early pregnancy. They can't tell you either way."),
      ),
      PvReadFaq(
        question: _en("I'm spotting. Should I stop my medicines?"),
        answer: _en("No. Keep taking everything and call your clinic. Light spotting is common in the wait and doesn't always mean the cycle has ended. Only the blood test can tell you."),
      ),
      PvReadFaq(
        question: _en('Can stress or crying stop the embryo implanting?'),
        answer: _en("There's no good evidence that everyday stress or crying changes the result. Feeling upset in this wait is normal. It isn't something you're doing to the embryo."),
      ),
      PvReadFaq(
        question: _en('Can I lift my toddler or do housework?'),
        answer: _en("Usually yes. Everyday lifting and light housework are fine for most people. If your clinic has given you a limit, follow theirs."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your clinic today, or go to hospital'),
      body: _en("Call your clinic the same day for bleeding as heavy as a period or heavier, fever, or tummy pain that's getting worse. Call today too for growing bloating, vomiting, breathlessness, passing much less urine, or gaining two kilos or more in a day or two, because OHSS can start or get worse in early pregnancy. Go to a hospital today for severe pain on one side, pain in the tip of your shoulder, or feeling faint."),
    ),
    evidence: _en("Implantation timing and luteal phase support follow the ESHRE guideline on ovarian stimulation for IVF/ICSI (2019) and NICE fertility guideline CG156. Trigger hCG on home tests follows StatPearls, “Human Chorionic Gonadotropin” (NCBI Bookshelf). Stress and treatment outcome follow the ESHRE guideline on routine psychosocial care in infertility and medically assisted reproduction (2015). OHSS in early pregnancy follows the RCOG guideline on the management of ovarian hyperstimulation syndrome (2016). Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Your round, day by day'),
        value: _en('Your test date and your medicines, in one place.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('A place for the hard days'),
        value: _en('Write down what you feel, for no one but you.'),
        surfaceId: 'ttc_journal',
      ),
    ],
    readNext: [
      'ttc_read_tx_beta_test',
      'ttc_read_stress_fertility',
      'ttc_read_tx_transfer_day',
    ],
  ),

  // ===========================================================================
  //  G10 · S9 · The beta test (P1). Never how to read her own number.
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_beta_test',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en("The beta test: what it is, and why it's sometimes repeated"),
    teaser: _en("What the blood test after treatment measures, how the result reaches you, and what usually happens next."),
    shortAnswer: _en("The beta test is a blood test for hCG, the pregnancy hormone, usually 9 to 14 days after a transfer on a date your clinic gives. Your clinic reads the result and tells you what it means for you. Sometimes they repeat it about two days later, to see whether the level is rising."),
    scaleSetter: _en("A repeat test is common and on its own isn't bad news. Clinics often want two results, because the change between them tells them more than one number. Whatever the result, your clinic will plan the next step with you."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("After the wait, test day can feel like everything rests on one blood sample. It helps to know what the test is, why it's done the way it is, and what to expect from the call afterwards."),
          _en("We won't tell you how to read your own number. That's your clinic's job, because they know your treatment, your embryo and your history. This read covers everything around it."),
        ],
      ),
      PvReadSection(
        heading: _en('What is the beta test?'),
        paragraphs: [
          _en("It measures hCG in your blood. This is the hormone an embryo starts making once it attaches to the lining of the womb. The test looks for one part of the hormone, called the beta part, which is where the name comes from."),
          _en("A blood test can pick up smaller amounts than a home urine test, and it gives a number, not just a line. That's why clinics use it after treatment."),
          _en("You'll usually have it at your clinic, or at a lab they name, so the result goes straight to the doctors who know your cycle."),
        ],
      ),
      PvReadSection(
        heading: _en('Why is it done on that day?'),
        paragraphs: [
          _en("Your clinic picks the date from your transfer day and your embryo's age, or from your IUI or trigger. It's usually about 9 to 14 days after a transfer and about 14 days after an IUI."),
          _en("Before that, there may not be enough hormone to measure yet. And if you had an hCG trigger, some of it could still be in your blood. Testing on your clinic's day avoids both problems."),
          _en("Keep taking all your medicines on test day, and on the days after, until your clinic tells you otherwise. You don't usually need to fast for this test, but check with your lab."),
        ],
      ),
      PvReadSection(
        heading: _en('Why would they repeat it?'),
        paragraphs: [
          _en("In early pregnancy, hCG normally rises quickly. One number shows where it is on one day. Two numbers, usually about 48 hours apart, show which way it's heading."),
          _en("So many clinics repeat the test as a routine, even when the first result is positive. Others repeat it when the first number is lower than they'd expect or harder to read."),
          _en("A repeat on its own doesn't tell you the answer. It means your clinic wants more information before saying anything firm. Two days of not knowing can be hard, so plan something kind for yourself in between."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Why we don't explain the numbers"),
          body: _en("hCG numbers vary hugely between healthy pregnancies, and between labs. A number that looks low on a forum can be normal for your day and your embryo. Your clinic is the only one who can put yours in context."),
        ),
      ),
      PvReadSection(
        heading: _en('How will I hear the result?'),
        paragraphs: [
          _en("Clinics do this differently. Some call you in the afternoon. Some send the report and call after. Some ask you to phone them. On the day, ask how and when you'll hear."),
          _en("If the report reaches you first, it can help to wait for the clinic's call before searching the number. Reports often print general ranges that aren't meant for a pregnancy after treatment, so they can mislead you."),
          _en("Think about where you'd like to be when the call comes. Some people want to be at home with their partner. Some want to be busy at work. There's no right way."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I make test day easier?'),
        paragraphs: [
          _en("A few small plans can take some of the weight off the day."),
        ],
        bullets: [
          _en("1. Book the earliest slot you can, so the waiting part of the day is shorter."),
          _en("2. Take your usual medicines that morning, unless your clinic has said otherwise."),
          _en("3. Ask the lab or clinic what time the result is usually ready, and who will call you."),
          _en("4. Keep your phone charged and the ringer on, and save the clinic's number so you know it's them."),
          _en("5. Plan something gentle for the evening, whatever the news. A walk, a favourite meal, or an early night."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens after each kind of result?'),
        bullets: [
          _en("Positive: your clinic will usually repeat the test, keep your medicines going and book your first scan, often at around 6 to 7 weeks of pregnancy. Your due date will come from your clinic, worked out from your transfer or IUI date, not your last period."),
          _en("Unclear, or lower than expected: your clinic will repeat the test and may plan a scan later. Keep taking your medicines unless they say to stop."),
          _en("Negative: your clinic will tell you when to stop your medicines and will offer a review. There's more on the weeks after a negative in our read on that."),
          _en("Positive, then falling: sometimes an embryo starts to implant but doesn't keep growing. This is called a biochemical or chemical pregnancy. It's very common, in treatment and outside it, and nothing you did caused it."),
        ],
        paragraphs: [
          _en("Whatever the result, you don't have to decide anything on the phone. It's okay to say you'll call back with questions."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I ask the lab for my number and read it myself?'),
        answer: _en("It's your report, so yes. But please talk to your clinic before deciding what it means. The same number can mean different things depending on your transfer day and your embryo."),
      ),
      PvReadFaq(
        question: _en("My friend's number was much higher. Should I worry?"),
        answer: _en("Numbers vary a lot between healthy pregnancies, even with the same kind of transfer. Comparing with someone else's doesn't tell you much. Your clinic will look at yours and at how it changes."),
      ),
      PvReadFaq(
        question: _en('My home test was positive. Do I still need the blood test?'),
        answer: _en("Yes. The blood test gives your clinic a number to follow over time, and a home test can pick up trigger hormone. Go to the blood test as planned."),
      ),
      PvReadFaq(
        question: _en('What if my period comes before test day?'),
        answer: _en("Call your clinic, and keep taking your medicines until they tell you otherwise. Bleeding before the test doesn't always mean the cycle hasn't worked, and most clinics still want the blood test done."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go to hospital today for these'),
      body: _en("Go to a hospital today for severe pain on one side of your lower tummy, pain in the tip of your shoulder, feeling faint, or heavy bleeding (soaking more than two thick pads an hour for two hours). Tell them you've had fertility treatment and may be pregnant. Call your clinic the same day for any bleeding, growing bloating, vomiting or breathlessness."),
    ),
    evidence: _en("What hCG is and how it is measured follows StatPearls, “Human Chorionic Gonadotropin” (NCBI Bookshelf). Test timing after transfer follows the ESHRE guideline on ovarian stimulation for IVF/ICSI (2019). Biochemical pregnancy follows the ESHRE guideline on recurrent pregnancy loss (2022). Dating a pregnancy after IVF from the transfer follows ACOG committee opinion 700, Methods for Estimating the Due Date. Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Record your result when you're ready"),
        value: _en("There's no hurry. The round waits until you are."),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('When the test is negative after treatment'),
        value: _en('What usually happens in the few weeks after.'),
        surfaceId: 'ttc_read/ttc_read_tx_negative_after_treatment',
      ),
    ],
    readNext: [
      'ttc_read_tx_negative_after_treatment',
      'ttc_read_chemical_pregnancy',
      'ttc_read_faint_line',
    ],
  ),

  // ===========================================================================
  //  G11 · S10/S11 · A negative result after treatment (P1)
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_negative_after_treatment',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('When the test is negative after treatment: the next few weeks'),
    teaser: _en("What usually happens to your body, your medicines and your plans in the weeks after a negative result."),
    shortAnswer: _en("Your clinic will tell you when to stop your medicines, and a period usually follows within about a week of stopping. Most clinics then offer a review appointment to talk about what's next. There's no rush to decide anything, and whatever you're feeling is a normal response to a real loss."),
    scaleSetter: _en("A negative result after treatment is very common, even in cycles where everything went to plan. It isn't a sign that you did something wrong in the wait. Many couples need more than one round."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("This is a hard call to get. You may have spent weeks on injections, scans and waiting, and it can feel as if it was all for nothing. Your doctors do learn something from every round, including this one."),
          _en("Here's what usually happens next, in the order it tends to come. Your clinic will guide the timing for you."),
        ],
      ),
      PvReadSection(
        heading: _en('When do I stop the medicines?'),
        paragraphs: [
          _en("Only when your clinic says. Some clinics repeat the test first, or want to confirm the result before you stop progesterone and anything else."),
          _en("Once they tell you to stop, stop everything they name, and ask about anything they didn't mention. Some people are on several tablets, and it's easy to miss one."),
          _en("If you're not sure about one of them, keep taking it for now and call the clinic to check. It's a quick question, and they're used to it."),
        ],
      ),
      PvReadSection(
        heading: _en('When will my period come?'),
        paragraphs: [
          _en("It usually comes within about a week of stopping progesterone, sometimes sooner. It may be heavier or crampier than usual, or it may feel much like any other period."),
          _en("If it hasn't come in the time your clinic told you to expect, let them know. They may want to repeat the test."),
          _en("Your cycles may take a month or two to settle after treatment. That's common, and usually nothing to worry about."),
        ],
      ),
      PvReadSection(
        heading: _en("Why didn't it work?"),
        paragraphs: [
          _en("Often there's no single reason anyone can find. One of the most common reasons an embryo doesn't implant is a problem in its chromosomes that nobody could see under a microscope. It happens at every age."),
          _en("It wasn't the stairs, the work call, the argument or the spicy dinner. Everyday life in the wait doesn't make an embryo fail."),
          _en("Sometimes a first test is positive and then the level falls. That's called a biochemical or chemical pregnancy. It's very common, and it can hurt in its own way, because for a day or two there was good news. Your clinic will usually treat the next steps the same way."),
        ],
        mythFact: PvMythFact(
          myth: _en('If I had rested more, it would have worked.'),
          fact: _en("Bed rest doesn't help an embryo implant, and normal activity doesn't harm one. How you spent the wait didn't cause this."),
        ),
      ),
      PvReadSection(
        heading: _en('What will the review appointment cover?'),
        paragraphs: [
          _en("Most clinics offer a follow-up consultation a few weeks after a negative result. It's a chance to go over what happened in this round and talk about what could come next."),
          _en("You can ask anything. It helps to write your questions down beforehand, and we have a read with questions worth taking."),
        ],
      ),
      PvReadSection(
        heading: _en('What could come next?'),
        paragraphs: [
          _en("Your clinic will talk through which of these fits you. Usually it's one of the following."),
        ],
        bullets: [
          _en("If you have frozen embryos, a frozen transfer, often after one full period."),
          _en("If you don't, a new round of stimulation, often after a break of one or two cycles."),
          _en("A change to the plan, like a different medicine, dose or protocol, based on what the clinic saw this time."),
          _en("A pause. Many couples take a few months off treatment for their bodies, their hearts or their savings."),
          _en("Trying on your own between rounds, if your clinic agrees it makes sense for you."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Nothing has to be decided today'),
          body: _en("None of these needs deciding on the day you get the result. It's okay to tell your clinic you'll come back to them."),
        ),
      ),
      PvReadSection(
        heading: _en('How do we think about money and time?'),
        paragraphs: [
          _en("Treatment in India is mostly paid for by families themselves, and a round can cost a lot. It's normal for money to be part of what you're feeling now. Talking about it openly is sensible, not cold."),
          _en("Before your review, look at what your package included. Some cover a frozen transfer or a second round, and some don't. Ask the clinic for the cost of each option in writing, so you can compare calmly at home."),
          _en("Time matters too, especially if you're in your late thirties or older. Your doctor can help you weigh a break against starting again soon. That's a good question to take to the review, not one to answer alone at night."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I look after myself this week?'),
        paragraphs: [
          _en("Let yourself be sad. A negative after treatment is a real loss, of hope and of the weeks you gave to it. It can come out as tears, anger, numbness or tiredness, and all of these are normal."),
          _en("You and your partner may feel it differently, or at different times. One of you may want to talk and the other may want to keep busy. That doesn't mean either of you cares less."),
          _en("Decide together what to tell family. A short line is enough: “It didn't work this time. We'll share more when we're ready.”"),
          _en("If you feel low for more than a couple of weeks, or can't eat, sleep or work, tell your doctor or ask your clinic's counsellor for time. You don't have to carry this alone."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('How soon can we try again?'),
        answer: _en("It depends on whether you have frozen embryos and how your body is doing. Many clinics plan a frozen transfer after one full period, and a new stimulation after one or two. Your clinic will tell you what fits."),
      ),
      PvReadFaq(
        question: _en('Can we try naturally before the next round?'),
        answer: _en("Often yes, if your clinic agrees. Ask at your review. For some couples it makes sense, and for others the reason they needed treatment means it doesn't."),
      ),
      PvReadFaq(
        question: _en("Does one negative mean IVF won't work for us?"),
        answer: _en("No. Many couples need more than one round, and one result doesn't decide the next."),
      ),
      PvReadFaq(
        question: _en("I can't stop crying at work. Is that normal?"),
        answer: _en("Yes. Grief after treatment often comes in waves, at odd times. If you can, take a day or two off. If it doesn't ease over a couple of weeks, please talk to someone."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to call, and when to go today'),
      body: _en("Go to a hospital today for very heavy bleeding (soaking more than two thick pads an hour for two hours), severe tummy pain, pain on one side or in the tip of your shoulder, or feeling faint. Call your clinic the same day for a fever or bad-smelling discharge. If you've felt very low for more than two weeks, tell your doctor this week. If you have thoughts of harming yourself, get help today: call Tele-MANAS on 14416."),
    ),
    evidence: _en("Next steps after an unsuccessful cycle and the timing of further treatment follow the ESHRE guideline on ovarian stimulation for IVF/ICSI (2019) and NICE fertility guideline CG156. Chromosome problems as a common reason embryos do not implant follow the ESHRE good practice recommendations on recurrent implantation failure (2023). Emotional care follows the ESHRE guideline on routine psychosocial care in infertility (2015). Tele-MANAS is the Government of India's mental health helpline. Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Close this round when you're ready"),
        value: _en('It stays in your history, and your own cycle comes back.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Add your review appointment'),
        value: _en('So the date and your questions sit together.'),
        surfaceId: 'ttc_appointments',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('A place for the hard days'),
        value: _en('Write down what you feel, for no one but you.'),
        surfaceId: 'ttc_journal',
      ),
    ],
    readNext: [
      'ttc_read_tx_review_appointment',
      'ttc_read_period_came',
      'ttc_read_month_after_month',
    ],
  ),

  // ===========================================================================
  //  G1 · S1/S2 · The baseline scan
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_baseline_scan',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Your first treatment visit: the baseline scan'),
    teaser: _en("What happens on day 2 or 3 of your period when a round starts, and why your clinic checks first."),
    shortAnswer: _en("The baseline scan is an internal ultrasound, usually on day 2 or 3 of your period, before any injections start. It checks that your ovaries are quiet and your lining is thin, and it counts the small follicles. If all is well, your clinic usually lets you start that day or the next."),
    scaleSetter: _en("This is a routine check, not a test you pass or fail. If the clinic sees a reason to wait, like a small cyst, they may move the start by a few days or a cycle. That's common, and it doesn't change what's possible."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("A treatment round usually starts with your period. You call the clinic when it comes, and they book a scan for day 2 or 3. For many people, this is the moment IVF starts to feel real."),
          _en("Some clinics give you birth control pills for a few weeks first, to time the start. Others use a different medicine in the cycle before. Your clinic will tell you which applies to you."),
          _en("Day 1 is the first day of proper red flow, not spotting. If your period starts late at night, ask your clinic which day they count as day 1."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens at the scan?'),
        paragraphs: [
          _en("It's an internal scan, where a thin probe goes gently into the vagina. It's done with an empty bladder and takes about ten minutes. Having your period doesn't matter. Clinics do these scans every day."),
          _en("Some clinics also take blood on the same day, to check hormones such as estradiol. Many do both, then call you later with the plan."),
          _en("Your partner may be asked to come too. It might be for consent forms, his own tests, or a sample to freeze in case he can't be there on collection day."),
        ],
      ),
      PvReadSection(
        heading: _en('What are they checking?'),
        paragraphs: [
          _en("The scan is a quick look at the starting line before any medicine goes in. The doctor usually checks four things."),
        ],
        bullets: [
          _en("That your ovaries are quiet, with no large follicle or cyst left over from last cycle."),
          _en("That the lining of your womb is thin, as it should be at the start of a period."),
          _en("How many small resting follicles there are. This is the antral follicle count, and it helps the clinic choose your starting dose."),
          _en("Anything else that might change the plan, like fluid in the womb or a polyp."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("The follicle count isn't a score"),
          body: _en("It's used to plan your medicine. It doesn't tell you how many eggs you'll get, and it doesn't tell you whether treatment will work."),
        ),
      ),
      PvReadSection(
        heading: _en('What if they say I have to wait?'),
        paragraphs: [
          _en("Sometimes a cyst from last cycle is still there, or a hormone level suggests your ovaries aren't fully quiet. The clinic may wait a few days and scan again, or move the start to your next period."),
          _en("This is one of the most common changes to a treatment plan. It's frustrating when you've got yourself ready to start. But starting with quiet ovaries gives the medicines the best setting to work in."),
          _en("If the start moves, ask what happens to the medicines you've already bought and how to store them until then."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens if I get the go-ahead?'),
        paragraphs: [
          _en("The clinic will explain your medicines, show you or your partner how to inject, and give you a date for your first monitoring scan. That's usually about five to seven days into the injections."),
          _en("You'll be asked to sign consent forms. Under the ART (Regulation) Act 2021, clinics must be registered, and they need written consent from both of you. Your clinic will confirm what applies to you."),
          _en("Read the forms carefully and ask about anything you don't understand, including what happens to any extra embryos. You can take them home to read if you need to."),
          _en("Before you leave, ask how to reach the clinic out of hours, and save the number in both your phones."),
        ],
      ),
      PvReadSection(
        heading: _en('What does the first injection day look like?'),
        paragraphs: [
          _en("Many clinics give the first injection at the clinic, or have a nurse watch you do it. After that, you'll usually give them at home in the evening, at about the same time each day."),
          _en("It's normal to feel nervous about the first one. Most people say the needle is smaller than they imagined, and the second evening is much easier than the first."),
          _en("Before you leave, write down the dose, the time and the date of your next scan. Details are easy to forget once you're home."),
        ],
      ),
      PvReadSection(
        heading: _en('How might this day feel?'),
        paragraphs: [
          _en("Starting treatment can bring hope and fear at the same time. Some people feel relieved that something is finally happening. Others feel sad that they need treatment at all. Both are common, and they can sit side by side."),
          _en("If you'd like someone with you, ask your partner or a close friend to come. It's a short visit, but it's a big step."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I bring?'),
        collapsible: true,
        summary: _en('Your reports, a list of medicines, your period date, and something to eat.'),
        bullets: [
          _en("All your reports and past scan results, in one folder."),
          _en("A list of the medicines and supplements you take."),
          _en("The date your period started."),
          _en("Your partner, or someone who can hear the medicine plan with you."),
          _en("A way to pay for medicines. Some clinics ask for the first batch to be paid for on the day."),
          _en("Something to eat and drink, because waits can be long."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does the scan hurt when I have my period?'),
        answer: _en("Most people find it a little uncomfortable, not painful. The probe is thin and the scan is quick. Tell the doctor if you're tense, and they'll go slower."),
      ),
      PvReadFaq(
        question: _en('My period came on a Sunday. Is that a problem?'),
        answer: _en("Most IVF clinics scan on Sundays and holidays, or will tell you what to do. Call the number they gave you and they'll book you in."),
      ),
      PvReadFaq(
        question: _en('Can I have the baseline scan at another centre?'),
        answer: _en("Some clinics allow it, especially if you live far away. Ask first, because they may want their own scan and blood tests."),
      ),
      PvReadFaq(
        question: _en('I have PCOS and lots of follicles. Is that bad?'),
        answer: _en("It isn't bad, but it matters for planning. A high count helps your clinic choose a gentler dose and watch closely for OHSS."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to call your clinic, and when to go today'),
      body: _en("Call your clinic if your period is much heavier or more painful than usual, or doesn't come when they said it would after the pills. Once injections start, call the same day for severe tummy pain, swelling, vomiting or breathlessness. Go to a hospital today for fainting or sudden severe pain on one side."),
    ),
    evidence: _en("The baseline assessment and antral follicle count follow the ESHRE guideline on ovarian stimulation for IVF/ICSI (2019) and NICE fertility guideline CG156. Clinic registration and written consent follow the Assisted Reproductive Technology (Regulation) Act 2021. Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Add your clinic's dates"),
        value: _en("We'll follow your round with you, step by step."),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your reports in one place'),
        value: _en('Ready to show at every visit.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: [
      'ttc_read_ivf_injections',
      'ttc_read_tx_monitoring_scans',
      'ttc_read_clinic_glossary',
    ],
  ),

  // ===========================================================================
  //  G2 · S2 · Frozen embryo transfer, step by step
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_frozen_transfer',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Frozen embryo transfer, step by step'),
    teaser: _en("How a frozen transfer cycle usually runs, with medicines or with your own cycle, from your period to the test."),
    shortAnswer: _en("A frozen embryo transfer, or FET, puts an embryo frozen in an earlier round back into your womb. It's much lighter than an IVF round, with no stimulation injections and no egg collection. Your clinic prepares your lining with medicines or follows your own ovulation, then times the transfer to your embryo's age."),
    scaleSetter: _en("A frozen cycle is gentler on your body than a full IVF round. Freezing and thawing embryos is a routine part of IVF today, and most good embryos come through thawing well."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("If you have embryos in the freezer, your next step may be a frozen transfer. Many people come to it after a fresh transfer. Others come to it after a round where every embryo was frozen and none went in fresh."),
          _en("There are two main ways to plan it. Your clinic chooses based on your cycles and your history, and the dates are always theirs. Here's how each one usually goes."),
        ],
      ),
      PvReadSection(
        heading: _en('How does a medicated FET go?'),
        paragraphs: [
          _en("This is the most common kind. Medicines do the work of building up your lining, so the dates can be planned ahead."),
        ],
        bullets: [
          _en("1. Your period starts and you call the clinic. Some clinics do a scan on day 2 or 3."),
          _en("2. You take estrogen, usually tablets, sometimes patches or gel, from about day 2 or 3. This builds up the lining of your womb, usually over about 10 to 14 days."),
          _en("3. One to three scans check that the lining is thick enough and has the right look."),
          _en("4. Progesterone starts on a day your clinic gives you. It turns the lining from growing to ready."),
          _en("5. The transfer is booked after a set number of days of progesterone, matched to your embryo's age. A day-5 embryo and a day-3 embryo go in on different days."),
          _en("6. You carry on with both estrogen and progesterone until the blood test, and beyond it if the test is positive."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Why every dose matters here'),
          body: _en("In a medicated cycle your own ovulation is switched off, so the medicines are doing the whole job. Missing doses matters more than usual. If you miss one, call your clinic."),
        ),
      ),
      PvReadSection(
        heading: _en('What about a natural-cycle FET?'),
        paragraphs: [
          _en("Here your clinic uses your own ovulation. Scans watch a follicle grow, and you may be asked to do home LH tests too, or to have a trigger injection."),
          _en("The transfer is timed from your LH surge or your trigger, about a week later for a day-5 embryo. Progesterone is often added for support. Your clinic will give you the exact day."),
          _en("This suits people whose cycles are regular. Some clinics prefer it because there are fewer medicines. Others prefer the medicated way because the dates are easier to plan around work and family."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens on transfer day?'),
        paragraphs: [
          _en("The embryo is thawed in the lab on the morning of the transfer, or a little earlier for some embryos. The embryologist checks how it looks after thawing and tells you before the transfer."),
          _en("The transfer itself is the same as a fresh one: a few minutes, with a full bladder, and no anaesthetic. You go home the same day and can have an ordinary, gentle day."),
          _en("Clinics usually thaw one embryo at a time. If one doesn't come through thawing well, they'll talk to you about what to do next."),
        ],
      ),
      PvReadSection(
        heading: _en('What if the cycle is cancelled?'),
        paragraphs: [
          _en("Sometimes the lining doesn't thicken enough, or a scan shows something worth waiting for. The clinic may carry on the estrogen for longer, change the plan, or stop and start again next cycle."),
          _en("Your embryos stay safely frozen while that happens. A cancelled FET cycle doesn't harm them, even though it's disappointing to stop."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I prepare for a frozen cycle?'),
        bullets: [
          _en("1. Check you have enough estrogen and progesterone for the whole cycle, with a few days spare. Running out on a Sunday night is stressful."),
          _en("2. Set an alarm for every dose. Estrogen is often taken two or three times a day."),
          _en("3. Ask your clinic what to do if you vomit soon after a tablet, or miss a dose."),
          _en("4. Plan the transfer morning: the time, the full bladder, and who's coming with you."),
          _en("5. Ask for the test date early, so you know how long the wait will be."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens after the transfer?'),
        paragraphs: [
          _en("The wait and the blood test work the same way as after a fresh transfer. Keep taking both estrogen and progesterone until your clinic tells you to stop."),
          _en("If the test is positive, you'll usually stay on them for some weeks, until the pregnancy can make enough hormones of its own. Your clinic will tell you when and how to stop."),
          _en("Your due date will come from your clinic, worked out from the transfer date and your embryo's age."),
        ],
      ),
      PvReadSection(
        heading: _en('How long can embryos stay frozen?'),
        collapsible: true,
        summary: _en('For years, without losing quality over time. Storage needs your consent, has legal limits and yearly fees.'),
        paragraphs: [
          _en("Embryos frozen by vitrification, the very fast freezing most clinics use, can be stored for many years. Studies haven't found that the time spent in storage changes how they do."),
          _en("Under the ART (Regulation) Act 2021, storage needs your written consent and has time limits. Clinics also charge a yearly storage fee. Ask what yours charges and what happens when the time limit is reached. Your clinic will confirm what applies to you."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is a frozen transfer less likely to work than a fresh one?'),
        answer: _en("For most people, large studies have found fresh and frozen transfers give broadly similar results overall. Your clinic chooses based on your situation, not because one is second best."),
      ),
      PvReadFaq(
        question: _en('Do I need time off work?'),
        answer: _en("Usually not much. There are fewer scans than in IVF, and the transfer takes an hour or two of your day. Many people go back to work the next day."),
      ),
      PvReadFaq(
        question: _en('Why am I on estrogen if I want to be pregnant?'),
        answer: _en("In a medicated cycle, estrogen builds your lining the way your own ovaries would. It's a normal part of preparing for a frozen transfer."),
      ),
      PvReadFaq(
        question: _en('Can I have a frozen transfer at a different clinic?'),
        answer: _en("Moving embryos between clinics is possible but needs consent, paperwork and safe transport. Ask both clinics before you plan on it."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your clinic, or go to hospital today'),
      body: _en("Call your clinic the same day if you've missed or run out of estrogen or progesterone, or have bleeding like a period, a fever, or tummy pain that's getting worse. Go to a hospital today for pain or swelling in one leg, chest pain or sudden breathlessness, because estrogen slightly raises the risk of a clot. Go today too for severe pain on one side, shoulder-tip pain or fainting after the transfer."),
    ),
    evidence: _en("Medicated and natural-cycle frozen transfers follow ASRM and Cleveland Clinic patient information on frozen embryo transfer and NICE fertility guideline CG156. Broadly similar results from fresh and frozen transfers overall follow the ESHRE good practice recommendations on add-ons in reproductive medicine (2023). Storage limits and consent follow the Assisted Reproductive Technology (Regulation) Act 2021. Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Track your frozen transfer'),
        value: _en('Your estrogen start, lining scans and transfer day, in one place.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Your medicines, dose by dose'),
        value: _en('Reminders for estrogen and progesterone, so none slips.'),
        surfaceId: 'ttc_medication',
      ),
    ],
    readNext: [
      'ttc_read_tx_transfer_day',
      'ttc_read_tx_fresh_or_frozen',
      'ttc_read_tx_wait_after_treatment',
    ],
  ),

  // ===========================================================================
  //  G3 · S3 · Monitoring scans during IVF
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_monitoring_scans',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en("Monitoring scans during IVF: what they're checking"),
    teaser: _en("Why you'll be at the clinic every few mornings, what the doctor measures, and why your dose keeps changing."),
    shortAnswer: _en("During stimulation, you'll usually have a scan, often with a blood test, every one to three days from about day 5 to 7 of injections. The doctor measures how many follicles are growing, how big they are, and how thick your lining is. The results guide your dose and the trigger day."),
    scaleSetter: _en("Dose changes and extra scans are part of how IVF normally works. They aren't a sign that something is going wrong. Every body responds a little differently, and these scans are how your clinic adjusts to yours."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("The stimulation part of IVF means injections in the evening and, every few mornings, a trip to the clinic. The visits are short, but they can feel like a report card. They aren't. They're how your clinic steers the cycle."),
          _en("If you've had follicle scans before, for tablets or an IUI, those were watching for one follicle. IVF scans are different, because the aim is to grow several at once."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens at each visit?'),
        bullets: [
          _en("1. An internal scan, the same kind as your baseline scan. It takes a few minutes, with an empty bladder."),
          _en("2. Often a blood test for estradiol, a hormone the growing follicles make, and sometimes for LH or progesterone."),
          _en("3. Later that day, a call or message from the clinic with your plan: the dose for tonight and the date of your next visit."),
        ],
        paragraphs: [
          _en("Early morning slots are common, so you can get to work after. It helps to tell your manager you'll have a few short morning appointments over about two weeks. You don't have to say what they're for."),
          _en("Most visits are short, but waiting times vary, so leave a little slack in your morning."),
        ],
      ),
      PvReadSection(
        heading: _en('What are they measuring?'),
        paragraphs: [
          _en("Follicles are small sacs of fluid in the ovary, and each one may hold an egg. On the scan they look like dark circles, and the doctor measures each one in millimetres."),
          _en("They're watching how many are growing, how fast they grow, and whether they grow at a similar pace. Once stimulation is under way, a follicle often grows by about 1 to 2 mm a day."),
          _en("They also measure the lining of your womb, which thickens as your estrogen rises. The blood test adds to the picture. Estradiol rises as follicles grow, and a very high level can be a reason for the clinic to watch closely for OHSS."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does my dose keep changing?'),
        paragraphs: [
          _en("Your starting dose was a careful first guess, based on your age, your tests and your baseline scan. The monitoring scans show how your ovaries are responding, and the dose follows."),
          _en("Going up, going down, or adding the second injection that stops the eggs being released early are all ordinary changes. They don't mean you've done something wrong, or that the cycle is going badly."),
          _en("Always follow the latest instruction, and write it down. If a message from the clinic isn't clear, call and check before your evening dose."),
        ],
        tip: PvReadTip(
          title: _en('Keep one note for the whole round'),
          body: _en("Write each day's dose, the next scan date and any change in one note on your phone. It stops the details blurring together by the second week."),
        ),
      ),
      PvReadSection(
        heading: _en('How do they decide the trigger day?'),
        paragraphs: [
          _en("When several of the leading follicles reach about 17 to 20 mm, the clinic usually plans the trigger. Your blood results help decide the exact day."),
          _en("The trigger day can move by a day or two from what was first planned. That's why clinics often give you a rough window at the start and the exact date near the end."),
          _en("Near the end, follicles can grow quickly, so the clinic may want to see you every day. That's normal, and it's about getting the timing right."),
        ],
      ),
      PvReadSection(
        heading: _en("Does the follicle count tell me how many eggs I'll get?"),
        paragraphs: [
          _en("Not exactly. Not every follicle holds an egg, and not every egg collected is mature. So the count on your last scan and the number of eggs on collection day are often different."),
          _en("Try not to compare your numbers with anyone else's. A smaller number isn't a failure, and a bigger one isn't a promise. What matters is what your own clinic makes of it."),
        ],
        mythFact: PvMythFact(
          myth: _en('More follicles always means a better cycle.'),
          fact: _en("Not always. Very high numbers can raise the risk of OHSS, and a smaller number of good eggs can be enough. Your clinic is aiming for what's safe and right for you, not for the most."),
        ),
      ),
      PvReadSection(
        heading: _en('What if the plan changes?'),
        paragraphs: [
          _en("Sometimes there are too few follicles, or too many for safety, or an egg looks likely to be released early. The clinic may stop the round, change it to an IUI, or go ahead and freeze all the embryos."),
          _en("Plans change often in treatment. It's a hard day when it happens, but it doesn't say much about the next round, and your clinic will plan that with you."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I make the fortnight easier?'),
        bullets: [
          _en("Book the earliest scan slots you can, so you get to work or home sooner."),
          _en("Keep a small bag ready with your reports, water and a snack."),
          _en("Wear clothes that are easy to change out of for the scan."),
          _en("Share the scan dates with your partner, so one of you can plan around them."),
          _en("Keep your evenings free enough to take the clinic's call about tonight's dose."),
        ],
        paragraphs: [
          _en("Feeling tired and a bit tearful in the second week is common. Your hormones are high, the visits are many, and you're carrying a lot. Go easy on yourself, and let others help where they can."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I have the scans at a clinic near my office?'),
        answer: _en("Some clinics accept scans from another centre. Ask first, because they may want to see the images themselves and use the same machine each time."),
      ),
      PvReadFaq(
        question: _en('One ovary has more follicles than the other. Is that a problem?'),
        answer: _en("It's very common and usually nothing to worry about. Ovaries often respond unevenly."),
      ),
      PvReadFaq(
        question: _en('Do I need to fast before the blood test?'),
        answer: _en("Usually not for these hormone tests, but ask your clinic, because a few want a morning sample before breakfast."),
      ),
      PvReadFaq(
        question: _en('Should I ask for my follicle sizes?'),
        answer: _en("You can, and many clinics share them. Ask them to tell you what they mean for your plan, rather than working them out yourself."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the same day, or go today'),
      body: _en("Call your clinic the same day for tummy pain or swelling that's getting worse, feeling sick or vomiting, breathlessness, passing much less urine, or gaining two kilos or more in a day or two. These can be signs of OHSS. Go to a hospital today for sudden severe pain on one side, which can mean an enlarged ovary has twisted, or for chest pain or fainting."),
    ),
    evidence: _en("Monitoring with ultrasound and estradiol, dose adjustment and trigger criteria follow the ESHRE guideline on ovarian stimulation for IVF/ICSI (2019). OHSS signs and ovarian torsion follow the RCOG guideline on the management of ovarian hyperstimulation syndrome (2016). Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Add each scan as it is booked'),
        value: _en('Your next visit and tonight\'s plan, always in one place.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('OHSS: when to call the clinic'),
        value: _en('The signs worth knowing during stimulation.'),
        surfaceId: 'ttc_read/ttc_read_ivf_ohss',
      ),
    ],
    readNext: [
      'ttc_read_tx_trigger_shot',
      'ttc_read_ivf_injections',
      'ttc_read_follicle_scans',
    ],
  ),

  // ===========================================================================
  //  G5 · S5 · IUI day, with his sample
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_iui_day',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('IUI day: what happens'),
    teaser: _en("The morning of an IUI, from his sample to the few minutes on the couch, and what the rest of the day looks like."),
    shortAnswer: _en("On IUI day, your partner gives a sample, which the lab washes and prepares for about 1 to 2 hours. Then a thin, soft tube places the sperm inside your womb. It takes a few minutes, feels much like a smear test, and you can go about a normal day afterwards."),
    scaleSetter: _en("IUI is one of the gentlest treatments in fertility care. There's no anaesthetic and no recovery time, and most people are in and out of the clinic in a morning."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("IUI stands for intrauterine insemination. Prepared sperm are placed high inside the womb, closer to where the egg will be. It's timed around ovulation, often after a trigger injection."),
          _en("Here's what the day usually looks like, for both of you. Your clinic will give you your own times."),
        ],
      ),
      PvReadSection(
        heading: _en('When is the IUI done?'),
        paragraphs: [
          _en("It's usually planned for about a day and a half after the trigger injection, when the egg is expected to be released. Some clinics time it from your own LH surge instead, often the day after a positive home test."),
          _en("Your clinic will give you an exact time to arrive. Plan the morning around it, including how long the sample takes to prepare."),
          _en("Some clinics do two IUIs a day apart in the same cycle. Your clinic will tell you if that's their plan."),
        ],
      ),
      PvReadSection(
        heading: _en('What does my partner need to do?'),
        bullets: [
          _en("1. Go without ejaculating for the number of days the clinic suggests, often 2 to 5. Longer isn't better."),
          _en("2. Give the sample at the clinic, in a private room, or at home if the clinic allows it."),
          _en("3. If it's from home, get it to the lab within about an hour, kept close to body warmth and never in the fridge."),
          _en("4. Bring ID. The lab labels and checks every sample carefully."),
          _en("5. Tell the clinic about any fever or illness in the last few months, and any new medicines."),
        ],
        paragraphs: [
          _en("It can feel awkward. Clinics do this every day, and the staff are used to it. If he's worried about managing on the day, ask about freezing a backup sample beforehand."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens to his sample?'),
        paragraphs: [
          _en("The lab washes it. Washing separates the healthiest moving sperm from the fluid and everything else. It takes about 1 to 2 hours, so this is a good time for a cup of tea."),
          _en("Washing matters, because unwashed semen can't safely go into the womb. It can cause strong cramps."),
          _en("The lab will often tell you how many moving sperm are in the prepared sample. Your clinic will explain what it means for this cycle."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens during the IUI?'),
        paragraphs: [
          _en("You lie on the couch as you would for a smear test. The doctor puts in a speculum and passes a very thin, soft tube through the neck of the womb. The sperm go in slowly through the tube."),
          _en("It takes a few minutes. Most people feel a mild cramp or some pressure, if anything at all."),
          _en("Some clinics ask you to lie still for 10 to 15 minutes afterwards. The sperm are already inside the womb, and they won't come out when you stand up. A little fluid leaking later is normal."),
        ],
        mythFact: PvMythFact(
          myth: _en('You need to keep your legs up for an hour after an IUI.'),
          fact: _en("The sperm are placed inside the womb, past the neck of it. Standing up doesn't let them out. Follow your clinic's advice on resting, and then carry on with your day."),
        ),
      ),
      PvReadSection(
        heading: _en('What about the rest of the day?'),
        paragraphs: [
          _en("You can go back to work or home and do your usual things. There's no need for bed rest."),
          _en("Light spotting from the speculum or the tube is common. Mild cramps can last for the rest of the day."),
          _en("Your clinic may start progesterone from today or soon after. They may also suggest sex that evening or the next day. Follow their plan for this cycle."),
          _en("Your pregnancy test will usually be about 14 days later, on a date your clinic gives. A home test before then can pick up the trigger hormone and confuse you."),
        ],
      ),
      PvReadSection(
        heading: _en('What if the plan changes on the day?'),
        paragraphs: [
          _en("Sometimes the last scan shows several large follicles. The clinic may then cancel the IUI or ask you to avoid sex that cycle, because several eggs could mean twins or more. It can feel like a lost month, but it's a safety call."),
          _en("Sometimes you ovulate before the IUI, or his sample isn't what the clinic hoped for. Your clinic will tell you what they suggest. That may be going ahead, timed sex instead, or waiting for the next cycle."),
        ],
      ),
      PvReadSection(
        heading: _en('How might this feel for both of you?'),
        paragraphs: [
          _en("IUI can feel clinical, a long way from how you imagined making a baby. Many couples feel that, and it's okay to say it to each other."),
          _en("He may feel pressure around the sample, and you may feel pressure about everything else. A kind word both ways helps more than you'd think. Some couples plan a relaxed lunch together afterwards."),
        ],
      ),
      PvReadSection(
        heading: _en('What should we bring?'),
        collapsible: true,
        summary: _en('ID, any forms, his sample container, your trigger time, a snack and a pad.'),
        bullets: [
          _en("ID for both of you, and your consent forms if they weren't signed earlier."),
          _en("The clean container from the clinic, if he's collecting at home."),
          _en("Your trigger time, written down."),
          _en("Something to eat and drink for the wait while the sample is prepared."),
          _en("A sanitary pad, for any spotting afterwards."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does IUI hurt?'),
        answer: _en("For most people, no more than a smear test. Some feel a short cramp as the tube passes through the neck of the womb."),
      ),
      PvReadFaq(
        question: _en("His count was lower on the day. Is the cycle wasted?"),
        answer: _en("Not necessarily. Counts change from day to day, and your clinic will tell you whether they're going ahead. Ask what they think before deciding what it means."),
      ),
      PvReadFaq(
        question: _en('How many IUIs do couples usually try?'),
        answer: _en("Many clinics suggest a few attempts, often three or four, before talking about IVF. Your clinic will plan this with you, based on your tests and your ages."),
      ),
      PvReadFaq(
        question: _en('Can I travel home on a two-wheeler?'),
        answer: _en("Yes. Riding home can't affect the sperm, which are already inside the womb. If you're crampy, a car or an auto may just be more comfortable."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your clinic the same day for these'),
      body: _en("Call your clinic the same day for fever or chills, bad-smelling discharge, or tummy pain that gets worse over the day or two after the IUI. Infection is uncommon, but it needs treating quickly. If you had injections, call too for growing bloating, vomiting or breathlessness. Go to a hospital today for severe pain on one side, shoulder-tip pain or feeling faint."),
    ),
    evidence: _en("IUI timing and sperm preparation follow NICE fertility guideline CG156 and the ESHRE guideline on unexplained infertility (2023). Sample collection follows the WHO laboratory manual for the examination and processing of human semen (2021). Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Add your IUI to your round'),
        value: _en('Your trigger, IUI and test day, in one place.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Share the day with your partner'),
        value: _en('So he knows his part of the morning, too.'),
        surfaceId: 'ttc_partner',
      ),
    ],
    readNext: [
      'ttc_read_semen_analysis',
      'ttc_read_tx_wait_after_treatment',
      'ttc_read_ivf_explained',
    ],
  ),

  // ===========================================================================
  //  G6 · S6 · Embryo days: the words only, never a grading of hers
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_embryo_days',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Day 1, day 3, day 5: the words the lab uses'),
    teaser: _en("A plain guide to the updates from the embryology lab after egg collection, word by word."),
    shortAnswer: _en("After egg collection, the lab checks fertilisation on day 1, looks at dividing embryos on day 3, and on day 5 or 6 looks for blastocysts. Each update has its own words and grades. They describe how an embryo looks, not what it will become, and your clinic will tell you what they mean for you."),
    scaleSetter: _en("It's normal for the number of embryos to fall from one day to the next. That happens in every lab and every cycle. It's how the lab finds the embryos that are most ready for transfer."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("In the days after egg collection, the lab will call or message with updates. They come quickly, in words most people have never heard, and each one can feel huge."),
          _en("Here are the words, so the calls are easier to follow. We don't grade your embryos or say what your numbers mean. Only your embryologist and doctor can do that."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens on collection day?'),
        paragraphs: [
          _en("Your eggs and your partner's sperm meet in the lab on the same day. In IVF, eggs and sperm are placed together in a dish. In ICSI, one sperm is placed into each mature egg."),
          _en("A mature egg is one that's ready to be fertilised. Some eggs collected won't be mature. That's normal, and it's why the number used can be lower than the number collected."),
          _en("From here, the eggs and embryos stay in incubators kept at body temperature, and the lab checks on them at set times. There's nothing you need to do at home except rest and keep taking your medicines."),
        ],
      ),
      PvReadSection(
        heading: _en('Day 1: did they fertilise?'),
        paragraphs: [
          _en("The lab checks each egg for signs of fertilisation. You may hear “2PN”, which means two pronuclei: one from the egg and one from the sperm. It's the sign of normal fertilisation."),
          _en("Not every mature egg fertilises. The clinic will tell you how many did. Many people find this the hardest call, because it's the first time the number drops."),
        ],
      ),
      PvReadSection(
        heading: _en('Day 2 and day 3: what does cleavage stage mean?'),
        paragraphs: [
          _en("The fertilised egg starts to divide. By day 3, an embryo often has about 6 to 8 cells. This is called the cleavage stage."),
          _en("You may hear about fragmentation, which means small pieces broken off the cells, and symmetry, which means whether the cells are even in size. Labs use these to grade day-3 embryos."),
          _en("Some clinics transfer on day 3. Others wait to see which embryos reach day 5. Your clinic will tell you which day they're planning, and why."),
        ],
      ),
      PvReadSection(
        heading: _en("Day 5 and day 6: what's a blastocyst?"),
        paragraphs: [
          _en("A blastocyst, often shortened to “blasto”, is an embryo with many more cells and a space filled with fluid inside. It has two parts. The inner cell mass becomes the baby, and the outer layer, called the trophectoderm, becomes the placenta."),
          _en("Some embryos reach this stage on day 5, and some on day 6. Day-6 blastocysts can also be transferred or frozen."),
          _en("Not every day-3 embryo reaches day 5, and that's expected. Embryos that stop growing often had a problem that couldn't be seen earlier."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do the numbers drop each day?'),
        paragraphs: [
          _en("Every step from egg to blastocyst filters out some embryos. Some eggs aren't mature, some don't fertilise, and some embryos stop dividing. This happens in natural conception too. In a lab, you just get to see it."),
          _en("It's painful to watch the number fall. But the embryos that keep growing to day 5 are showing that they can. That's what the lab is watching for."),
        ],
      ),
      PvReadSection(
        heading: _en('How will the lab give updates?'),
        paragraphs: [
          _en("Some labs call every day. Some call on day 1 and then on transfer or freezing day. Ask at egg collection how you'll hear, and who will call."),
          _en("Keep a note on your phone for the numbers and words they use. It's easy to forget them in the moment, and you can ask your doctor about them later."),
          _en("If a call leaves you confused or worried, it's fine to ask the embryologist to explain again, more slowly."),
        ],
      ),
      PvReadSection(
        heading: _en('What do the grades mean?'),
        collapsible: true,
        summary: _en('Numbers and letters describing how a blastocyst looks. A guide for the lab, not a verdict.'),
        paragraphs: [
          _en("Many labs grade blastocysts with a number and two letters, like 4AA or 3BB. The number describes how expanded the blastocyst is. The first letter describes the inner cell mass, and the second describes the outer layer."),
          _en("Grades help the lab choose which embryo to transfer first. They're based on how an embryo looks under a microscope, which is only part of the story. Embryos with lower grades lead to healthy babies too."),
          _en("Clinics use different systems, so a grade from one lab can't be compared directly with a grade from another."),
        ],
      ),
      PvReadSection(
        heading: _en('What other words might I hear?'),
        collapsible: true,
        summary: _en('Freezing, hatching, PGT, arrested and spare embryos, in plain words.'),
        bullets: [
          _en("Vitrification: freezing embryos very quickly so they can be used later."),
          _en("Assisted hatching: making a small opening in the embryo's outer shell. Some clinics offer it, but most people don't need it."),
          _en("PGT: testing a few cells from the outer layer of a blastocyst for chromosome problems. It's used in some situations, and your clinic will explain whether it applies to you."),
          _en("Arrested: an embryo that has stopped growing."),
          _en("Spare or surplus embryos: good embryos that aren't transferred now, which can be frozen with your consent."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Do ICSI embryos grow differently?'),
        answer: _en("No. After fertilisation, embryos from IVF and from ICSI grow in the same way, and the lab uses the same words for both."),
      ),
      PvReadFaq(
        question: _en('Should I ask for my embryo grades?'),
        answer: _en("You can, and many clinics share them. Ask them to explain the grades in plain words, and what they mean for your plan."),
      ),
      PvReadFaq(
        question: _en('What if the lab says none fertilised, or none reached day 5?'),
        answer: _en("That's a very hard call, and it does happen in some cycles. Ask for a review appointment. What the lab saw often tells your clinic something useful for the next round."),
      ),
      PvReadFaq(
        question: _en('Can I see pictures of my embryos?'),
        answer: _en("Many clinics will show you or send photos, and some have time-lapse images. Ask if you'd like them."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('In the days after egg collection'),
      body: _en("Call your clinic the same day for a fever of 38°C or more, bad-smelling discharge, pain that's getting worse, or bleeding heavier than a light period. Call too for growing bloating, vomiting, breathlessness or passing much less urine, which can be signs of OHSS. Go to a hospital today for severe pain, fainting or trouble breathing."),
    ),
    evidence: _en("Embryo development stages and grading terms follow the Istanbul consensus on embryo assessment from ESHRE and Alpha Scientists in Reproductive Medicine (2011, since updated). Assisted hatching and PGT follow the ESHRE good practice recommendations on add-ons in reproductive medicine (2023). Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Your round, day by day'),
        value: _en('Collection day, embryo days and transfer day, in one place.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Fresh or frozen transfer'),
        value: _en('How clinics decide what happens after day 5.'),
        surfaceId: 'ttc_read/ttc_read_tx_fresh_or_frozen',
      ),
    ],
    readNext: [
      'ttc_read_ivf_icsi',
      'ttc_read_clinic_glossary',
      'ttc_read_tx_fresh_or_frozen',
    ],
  ),

  // ===========================================================================
  //  G7 · S6 · Fresh or frozen transfer
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_fresh_or_frozen',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Fresh or frozen transfer: how clinics decide'),
    teaser: _en("Why your clinic might transfer an embryo this cycle, or freeze them all for later, and what each path looks like."),
    shortAnswer: _en("In a fresh transfer, an embryo goes in 3 or 5 days after egg collection, in the same cycle. In a freeze-all cycle, every good embryo is frozen and transferred in a later cycle. For most people, results are broadly similar overall, so clinics decide based on safety and your situation."),
    scaleSetter: _en("Hearing that your clinic wants to freeze all your embryos can feel like a setback. It's a common and careful choice, and often the safer one. It isn't a sign that something has gone wrong with your embryos."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Some couples expect a transfer a few days after egg collection, and then hear that the clinic wants to freeze everything. Others are asked what they'd prefer. Either way, it helps to know how clinics weigh it up."),
          _en("The decision belongs to your clinic and the two of you together. This read explains the usual reasons, so the conversation makes more sense."),
        ],
      ),
      PvReadSection(
        heading: _en("What's the difference?"),
        paragraphs: [
          _en("In a fresh transfer, the embryo goes into your womb in the same cycle as egg collection, usually on day 3 or day 5. Any other good embryos are frozen for later."),
          _en("In a freeze-all cycle, there's no transfer this time. All good embryos are frozen, and a frozen embryo transfer happens in a later cycle, often after one period."),
          _en("Either way, the transfer itself is the same few minutes. What differs is the timing, and the medicines around it."),
        ],
      ),
      PvReadSection(
        heading: _en('Why might a clinic freeze everything?'),
        paragraphs: [
          _en("There are several common reasons, and your clinic may have more than one."),
        ],
        bullets: [
          _en("A risk of OHSS. Pregnancy hormone can make OHSS worse, so waiting lets your ovaries settle first."),
          _en("Hormone levels around trigger day, such as a raised progesterone, which can make the lining less ready."),
          _en("A lining that isn't right for a transfer this cycle, or fluid in the womb."),
          _en("Embryo testing, called PGT, where results take time to come back."),
          _en("Illness, travel or a personal reason that makes a transfer now hard."),
          _en("The clinic's usual way of working, based on its own experience."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Freezing is about timing'),
          body: _en("Each of these reasons is about making the transfer as safe and well timed as it can be. None of them means your embryos are weaker."),
        ),
      ),
      PvReadSection(
        heading: _en('Why might a clinic choose fresh?'),
        paragraphs: [
          _en("If the cycle went smoothly, your hormone levels are in range and there's no sign of OHSS, a fresh transfer saves time. It also saves the cost of a separate frozen transfer cycle."),
          _en("Fewer weeks of waiting matters to many couples. For some, going straight on from collection to transfer feels easier than stopping and starting again."),
          _en("If you're not sure why your clinic chose one path over the other, ask them to tell you what decided it in your case."),
        ],
      ),
      PvReadSection(
        heading: _en('Is one better than the other?'),
        paragraphs: [
          _en("For most people, large studies have found fresh and frozen transfers give broadly similar results overall. International guidance doesn't recommend freezing all embryos for everyone. It's used when there's a reason."),
          _en("For someone at risk of OHSS, freezing all lowers that risk. A fresh transfer is quicker and avoids thawing. Your clinic is weighing these for you, not choosing a better or worse path."),
          _en("Clinics follow the research and their own experience. The right choice for you can also change from one round to the next."),
        ],
        mythFact: PvMythFact(
          myth: _en('Frozen embryos are second best.'),
          fact: _en("Freezing today is very fast and gentle, and most good embryos come through thawing well. An embryo isn't weaker for having waited."),
        ),
      ),
      PvReadSection(
        heading: _en('What does it mean for our costs and time?'),
        paragraphs: [
          _en("A freeze-all adds a frozen transfer cycle, with its own medicines, scans and fees. Ask your clinic what your package includes, and what a frozen transfer costs on its own."),
          _en("It also adds some weeks, usually at least one period, before the transfer. For some couples that's welcome breathing space. For others it's hard. Both are normal reactions."),
          _en("Frozen embryos have a storage fee too, usually charged each year."),
          _en("If money is tight, say so. Some clinics can suggest ways to spread the cost, or plan the frozen transfer for when it suits you."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens after a freeze-all?'),
        paragraphs: [
          _en("Your next period comes, and your clinic plans the frozen transfer from there. Many clinics do it in the cycle after, once your ovaries are back to their usual size. Some wait a little longer."),
          _en("In the meantime, the bloating from stimulation usually settles over a week or two. If it gets worse instead of better, call your clinic."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we decide together?'),
        paragraphs: [
          _en("Most of the time the clinic decides for medical reasons, and there's little to choose. Sometimes it's more open, and they'll ask what you'd prefer."),
          _en("If they ask, think about your work, your savings, your leave and how you're both feeling. A short pause can be a relief or a strain, and only you know which. Tell the doctor what matters to you, and ask what they'd suggest."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I ask my clinic?'),
        bullets: [
          _en("Why are you suggesting a fresh transfer, or a freeze-all, for us?"),
          _en("If we freeze all, when would the transfer be, and would it be medicated or natural?"),
          _en("What's included in our package, and what isn't?"),
          _en("How many embryos are frozen, and at what stage?"),
          _en("What happens to the embryos we don't use, and what do we need to consent to?"),
          _en("If the plan changes on collection day, who will tell us, and when?"),
          _en("Is there anything we should do differently before the frozen transfer?"),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I ask for a fresh transfer if my clinic advises freeze-all?'),
        answer: _en("You can ask why, and you should get a clear answer. If the reason is a risk of OHSS, the clinic is protecting your health, and it's wise to follow their advice."),
      ),
      PvReadFaq(
        question: _en('If we freeze all, will I need the injections again?'),
        answer: _en("Not the stimulation injections. A frozen transfer uses much lighter medicines, or little beyond progesterone in a natural cycle."),
      ),
      PvReadFaq(
        question: _en('Is a day-3 or a day-5 transfer better?'),
        answer: _en("Clinics decide based on how many embryos you have and how they're growing. Both lead to healthy pregnancies. Ask your clinic why they chose the day they did."),
      ),
      PvReadFaq(
        question: _en('Will freezing all delay our baby by months?'),
        answer: _en("Usually by about one cycle, sometimes two. It can feel long when you've waited so much already, but it's usually a matter of weeks."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('After egg collection, call for these'),
      body: _en("Call your clinic the same day for tummy swelling that keeps growing, pain that's getting worse, vomiting, breathlessness, passing much less urine, or gaining two kilos or more in a day or two. These are signs of OHSS, one of the main reasons clinics freeze all. Go to a hospital today for trouble breathing, chest pain or fainting."),
    ),
    evidence: _en("When to freeze all, and broadly similar results from fresh and frozen transfers overall, follow the ESHRE good practice recommendations on add-ons in reproductive medicine (2023) and the ESHRE guideline on ovarian stimulation for IVF/ICSI (2019). OHSS prevention follows the RCOG guideline on the management of ovarian hyperstimulation syndrome (2016). Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Mark a freeze-all in your round'),
        value: _en('Your round updates, and the frozen transfer can follow on.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('What a package leaves out'),
        value: _en('What to check is included before you sign.'),
        surfaceId: 'ttc_read/ttc_read_ivf_package',
      ),
    ],
    readNext: [
      'ttc_read_tx_frozen_transfer',
      'ttc_read_ivf_ohss',
      'ttc_read_ivf_costs',
    ],
  ),

  // ===========================================================================
  //  G12 · S11 · The review appointment
  // ===========================================================================
  PvRead(
    id: 'ttc_read_tx_review_appointment',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Your review appointment: questions to take'),
    teaser: _en("How to get the most from the follow-up after a round, with the questions worth asking and how to ask them."),
    shortAnswer: _en("A review appointment, or follow-up consult, is a chance to talk through your last round with your doctor and plan what comes next. Write your questions down, bring your partner if you can, and ask for anything you don't understand in plain words. You don't have to decide anything on the day."),
    scaleSetter: _en("This isn't an exam, and it isn't a complaint. It's a normal part of treatment, and good clinics expect you to come with questions."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("After a round ends, most clinics offer a follow-up meeting. It may come a few weeks after a negative test, after a cycle that stopped early, or before a frozen transfer."),
          _en("It can be hard to think clearly in that room, especially if you're still sad. Taking a list helps. Here are questions many couples find useful. Pick the ones that fit you, and leave the rest."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I prepare?'),
        bullets: [
          _en("1. Book it when you feel ready. Waiting a few weeks is common and fine."),
          _en("2. Bring your partner if you can. Two people remember more than one."),
          _en("3. Bring your reports, your medicine list and your dates. The dates in your round tracker can help."),
          _en("4. Write your questions down, and put the three that matter most at the top."),
          _en("5. Ask if you can take notes on your phone, or record the talk to listen to later."),
          _en("6. If you can, pick a time of day when you won't have to rush back to work."),
        ],
      ),
      PvReadSection(
        heading: _en('What might the doctor say?'),
        paragraphs: [
          _en("Often the doctor will go through your round step by step: the medicines, the scans, the eggs, the embryos and the transfer. Ask them to stop and explain any word you don't know."),
          _en("They may suggest keeping the same plan, because one round often doesn't show much. Or they may suggest a change. Either can be the right answer."),
          _en("If they suggest more tests, ask what each test would change about the plan. A test that wouldn't change anything may not be worth the cost."),
        ],
      ),
      PvReadSection(
        heading: _en('What happened in this round?'),
        bullets: [
          _en("How did my ovaries respond to the medicines? Was it what you expected?"),
          _en("How many eggs were collected, how many were mature, and how many fertilised?"),
          _en("How did the embryos grow, and what did the lab see?"),
          _en("Was there anything about the transfer or my lining you'd want to change?"),
          _en("Do you have any idea why it didn't work, or is it something we can't know?"),
        ],
        paragraphs: [
          _en("It's okay if the answer to that last question is that nobody can say. That's common, and a good doctor will tell you so honestly."),
        ],
      ),
      PvReadSection(
        heading: _en('What would you change next time?'),
        bullets: [
          _en("Would you change the medicines, the dose or the protocol?"),
          _en("Do you suggest any more tests, for either of us?"),
          _en("Would a different approach help, like ICSI, a freeze-all or a natural-cycle transfer?"),
          _en("Is there anything we can do in the meantime, like weight, sleep, smoking, or treating a health condition?"),
          _en("Is anything on his side worth checking again?"),
        ],
      ),
      PvReadSection(
        heading: _en('What are our options, and when?'),
        bullets: [
          _en("If we have frozen embryos, when could we do a frozen transfer?"),
          _en("If we don't, when could we start another round?"),
          _en("Is it okay to try naturally in between?"),
          _en("Would taking a break be a reasonable choice for us?"),
          _en("What would the next round cost, and what's in the package?"),
          _en("How long should we wait before starting again?"),
          _en("If we want to try another clinic, which records will we need?"),
        ],
        tip: PvReadTip(
          title: _en('Ask for the plan in writing'),
          body: _en("Before you leave, ask for the next steps in a message or on paper. It's easier to talk it over at home when you're not relying on memory."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I ask about things that feel awkward?'),
        paragraphs: [
          _en("Money, extra treatments and second opinions can feel awkward to raise. They're normal questions. You might say, “Could you help us understand the cost of each option?”"),
          _en("You may be offered an add-on, which is a test or treatment on top of standard IVF. It's fair to ask what the evidence is for people like you, and what it costs. Many add-ons have limited evidence behind them."),
          _en("If you'd like a second opinion, that's your right. Ask for copies of all your reports and embryo records to take with you."),
          _en("It's also fine to ask directly, “What would you suggest we do?” Most doctors will give you their honest view when you ask."),
        ],
      ),
      PvReadSection(
        heading: _en('What if we feel too low to plan?'),
        paragraphs: [
          _en("Then the review can be about this round only, with no decisions. Tell the doctor at the start. It's a kind thing to say for both of you."),
          _en("Many clinics have a counsellor. Asking to see one alongside your review is common, and it isn't a sign that you're not coping."),
        ],
      ),
      PvReadSection(
        heading: _en('What should we do after the appointment?'),
        paragraphs: [
          _en("Give yourselves a day or two before deciding. Talk it over at home, away from the clinic."),
          _en("Look at your notes together, and write down anything you're still unsure about. Most clinics are happy to answer a follow-up message or call."),
          _en("When you're ready, tell the clinic your decision and ask for the next dates. You can add them to a new round as soon as you have them."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it rude to ask why it failed?'),
        answer: _en("No. It's one of the main reasons the appointment exists, and doctors expect it."),
      ),
      PvReadFaq(
        question: _en('Can I bring my mother or mother-in-law?'),
        answer: _en("Yes, if you both want her there. Some couples find it easier with family, and others prefer to keep it private. It's your choice."),
      ),
      PvReadFaq(
        question: _en('What if I cry in the appointment?'),
        answer: _en("That's very common, and doctors see it often. Take a moment, and let your partner or your list carry on for you."),
      ),
      PvReadFaq(
        question: _en("What if the doctor doesn't have time for all my questions?"),
        answer: _en("Ask if you can send the rest by message, or book a longer slot. A good clinic will make room for your questions."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't wait for the review for these"),
      body: _en("Go to a hospital today for very heavy bleeding (soaking more than two thick pads an hour for two hours), severe tummy pain, a fever, or feeling faint. Call your clinic if your period hasn't come within the time they told you to expect after stopping medicines. If you've felt very low for more than two weeks, talk to your doctor, or call Tele-MANAS on 14416."),
    ),
    evidence: _en("What a review after an unsuccessful cycle can cover follows NICE fertility guideline CG156 and the ESHRE guideline on ovarian stimulation for IVF/ICSI (2019). Add-ons and their evidence follow the ESHRE good practice recommendations on add-ons in reproductive medicine (2023). Emotional care follows the ESHRE guideline on routine psychosocial care in infertility (2015). Sources checked September 2026."),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Add your review appointment'),
        value: _en('So the date and your questions sit together.'),
        surfaceId: 'ttc_appointments',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Your reports, ready to take'),
        value: _en('Everything from this round in one place.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: [
      'ttc_read_tx_negative_after_treatment',
      'ttc_read_ivf_success_rates',
      'ttc_read_ivf_package',
    ],
  ),
];
