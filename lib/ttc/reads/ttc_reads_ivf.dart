// =============================================================================
//  IVF & IUI — the reads for this door
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

final List<PvRead> kTtcReadsIvf = [
  // ===========================================================================
  //  INFERTILITY & IVF — "when to seek help"
  // ===========================================================================
  //  Excel Content cell: "When to seek help, the tests, IUI/IVF explained, cost
  //  expectations." Four topics, and only three are written here — "the tests"
  //  is already carried properly by `ttc_tests_data.dart`, which holds ten
  //  tests with real Indian price ranges, when in the cycle each is taken, and
  //  how to read the result. Writing a second version of that would be filler,
  //  and the reads below point at it instead.
  //
  //  ---------------------------------------------------------------------------
  //  ⚠️ THE THREE RULES THIS BRACKET ENFORCES HARDER THAN ANY OTHER
  //  ---------------------------------------------------------------------------
  //
  //  · **NO COMMERCE. AT ALL.** `ttc_brackets.dart` marks Products
  //    `notApplicable` here with the plainest reason in the file: "Not a fit
  //    (clinical)". No product row, no course upsell, no "recommended for you".
  //    A woman reading this has been trying for two years. The consult exists
  //    because she asked for it, not because we are selling it.
  //  · **NEVER A SUCCESS RATE. NEVER "YOUR CHANCES."** Not a per-cycle figure,
  //    not a clinic's advertised number, not an age-banded table. See the
  //    clinical invariants in CLAUDE.md and the header of `kTtcInfertility`.
  //    What IS allowed, and is done below, is teaching her how to read the
  //    number a clinic shows her — that lowers pressure instead of setting a
  //    target.
  //  · **THE COSTS CARRY A DATE AND A CAVEAT ABOUT THEIR SOURCE.** Fertility
  //    pricing in India is published almost entirely by the clinics selling the
  //    treatment. That does not make it useless; it makes it a range to sanity-
  //    check against, and saying so is the difference between informing her and
  //    repeating an advertisement.
  PvRead(
    id: 'ttc_read_when_to_seek_help',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en("When it's time to see a doctor"),
    teaser: _en("How long to try first, who shouldn't wait, and what really "
        'happens at a first appointment.'),
    shortAnswer: _en("If you're under 36, see a doctor after twelve months of "
        "regular sex without contraception. If you're 36 or over, go as soon "
        'as you want to, with no waiting period. At any age, go now if your '
        'cycles are irregular, periods are very painful, or there is a known '
        'problem on either side.'),

    scaleSetter: _en("Seeing a fertility doctor doesn't mean something is "
        "wrong. It's a set of tests and a talk. For many couples it ends with "
        'a small fix, not a big treatment. Going early costs you very little. '
        "Going late is the part that's hard to undo."),

    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),

    heroVideoSlot: 'ttc_vid_when_to_seek_help',

    sections: [
      PvReadSection(
        paragraphs: [
          _en("There's a standard answer to this. Then there's a longer list "
              "of cases where the standard answer doesn't apply. That second "
              "list matters more, because most people don't know about it, "
              "so they keep waiting when they don't need to."),
        ],
      ),

      PvReadSection(
        heading: _en('How long should you try first?'),
        paragraphs: [
          _en("If you're under 36, the guideline is twelve months of regular "
              "sex without contraception. That's the line used by NICE and "
              'most health bodies around the world. "Regular" means every two '
              'or three days all through the cycle, not only timed tries '
              'around your fertile days.'),
          _en("If you're 36 or over, the advice is to be seen as soon as you "
              "bring it up, with no waiting period first. Fertility doesn't "
              'suddenly drop at 36. The reason is that tests and treatment '
              "both take months, and a year spent waiting can't be won back."),
          _en("It helps to be clear about what the twelve months means. It's "
              'the point where tests become worth doing across a whole '
              "population. It isn't a diagnosis, it isn't a deadline, and "
              'it says nothing about you.'),
        ],
      ),

      // Gap plan 2026-09-26: the everyday reasons it takes longer.
      PvReadSection(
        heading: _en('Why can it take longer than you hoped?'),
        paragraphs: [
          _en('Most of the time, a few months without a positive test is how '
              'the numbers work, not a sign of a problem. Even with good '
              'timing, pregnancy only happens in some cycles. Within a year of '
              'trying, more than eight in ten couples are pregnant.'),
          _en('A few everyday things can stretch it out. None of them is a '
              'diagnosis, and many of them can be changed.'),
        ],
        bullets: [
          _en('Timing that misses the fertile days. The window is the five '
              'days before ovulation and the day itself, and it often comes '
              'earlier than people expect.'),
          _en('Cycles that change from month to month, so ovulation is hard to '
              'predict.'),
          _en('Age. From the mid-thirties the number of eggs falls faster, and '
              'it can take longer.'),
          _en('Weight well above or below the healthy range, which can upset '
              'ovulation and affect sperm.'),
          _en('His health. An illness with a fever, heat and some medicines can '
              'lower sperm quality for about three months, which is how long '
              'new sperm take to make.'),
          _en('Smoking or heavy drinking, for either of you.'),
          _en("A problem you can't feel, like a blocked tube or endometriosis. "
              'Only tests can find these, which is one more reason not to wait '
              'too long.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('If some of these fit'),
          body: _en("They're worth raising at a first visit, where a doctor can "
              'help you work out which ones matter for you. Sorting that out is '
              'part of what the appointment is for.'),
        ),
      ),

      PvReadSection(
        heading: _en("When shouldn't you wait at all?"),
        paragraphs: [
          _en("The twelve-month rule assumes you ovulate regularly and there's "
              'no known reason for trouble. If any of the points below is true, '
              "that assumption no longer holds and the clock doesn't apply. "
              'You can fairly ask to be seen now.'),
        ],
        bullets: [
          _en('Cycles that are irregular, very long, or missing, including a '
              "known PCOS diagnosis. Waiting a year only to learn you're not "
              'ovulating on a regular pattern gains you nothing.'),
          _en('Periods that are very painful or very heavy, or pain during '
              'sex. These are the usual reasons doctors suspect endometriosis.'),
          _en('Any past surgery in the pelvis, a burst appendix, or a past '
              'pelvic infection. Each of these can affect the tubes.'),
          _en('A semen analysis that has already come back abnormal, or a '
              'known problem on his side. Half of all cases involve a male '
              "factor, and it's the quickest thing in all the tests to "
              'check.'),
          _en('Two or more miscarriages.'),
          _en('Cancer treatment planned for either of you. This is the one '
              'case where the referral is really urgent, because saving '
              'fertility (eggs, sperm or embryos) has to happen before '
              'treatment starts.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('The one people miss most often'),
          body: _en('Irregular cycles. Many women wait the full year, thinking '
              'the guideline applies to them. But it was written for people '
              "whose cycles are predictable. If yours aren't, the twelve "
              'months was never meant for you.'),
        ),
      ),

      PvReadSection(
        heading: _en('What happens at a first appointment?'),
        paragraphs: [
          _en('Almost nobody gets treatment at the first visit. That surprises '
              'people both ways. Some expect to start straight away, and '
              'others are ready for something painful or invasive.'),
          _en('What happens is a talk about your history, an examination, and '
              'tests ordered for both of you.'),
          _en('His semen analysis is usually '
              "asked for first, because it's quick and cheap and tells the "
              'doctor a lot. Yours will usually include blood tests on '
              'certain days of your cycle, and a scan.'),
          _en('Then you go back with the results. The talk about what to do '
              'next happens with real answers in front of you. That second '
              'appointment is the one that counts.'),
        ],
        tip: PvReadTip(
          title: _en('What to take with you'),
          body: _en('Three months of cycle dates. Any old test results, even if '
              'they seem out of date or beside the point. A list of '
              'everything either of you takes, supplements too. And, if you '
              'can, him. When only one of you goes, only one of you gets '
              'checked, and half of this is his.'),
        ),
      ),

      // Gap plan 2026-09-26: a short list to fill in at home before the visit.
      PvReadSection(
        heading: _en('What should you note down before the visit?'),
        paragraphs: [
          _en('A few notes made at home make a first visit go much further. '
              'Doctors ask the same questions every time, and dates are hard '
              'to remember on the spot.'),
        ],
        bullets: [
          _en('The first day of each of your last three periods or more, and '
              'how many days each one lasted.'),
          _en("How long you've been trying, and roughly how often you have "
              'sex.'),
          _en('Anything unusual: bleeding between periods or after sex, pain '
              'with periods or sex, or a change in discharge.'),
          _en('Any past pregnancies or losses, and any surgery, infection or '
              'long-term condition for either of you.'),
          _en('Every medicine and supplement either of you takes.'),
          _en('The questions you most want answered, written down so they '
              "don't slip away in the room."),
        ],
      ),

      PvReadSection(
        heading: _en('Who should you see first?'),
        paragraphs: [
          _en('In India this usually starts with a gynaecologist, not a '
              "fertility clinic, and that's a sensible order. A general "
              'gynaecologist does the first tests and often gives tablets to '
              'help you ovulate. Quite a few couples need nothing more than '
              'that.'),
          _en("You're usually sent on to a fertility specialist when tablets "
              "haven't worked, when a problem with the tubes or with sperm is "
              'found, or when your age makes it sensible to move faster.'),
          _en("Going straight to a big fertility chain isn't wrong. Just know "
              'that their path is built around the treatments they offer. At '
              "any clinic, it's fair to ask what the gentlest option for your "
              'situation would be.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Going to a fertility clinic means ending up on IVF.'),
          fact: _en("Most couples who get tested don't have IVF. The tests are "
              'there to find the exact reason, and that reason is often '
              'treated with a tablet, a small procedure, or a change on his '
              "side. IVF is where things go when the earlier steps don't fit. "
              "It isn't where they start."),
        ),
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en("We've only been trying for eight months, but I'm "
            'anxious. Is it too early?'),
        answer: _en('No. Being seen earlier does no harm, and the first '
            'appointment is a talk and some tests. If the waiting is costing '
            'you sleep, that on its own is a fair reason to see a doctor.'),
      ),
      PvReadFaq(
        question: _en('Does he really need to come?'),
        answer: _en('For the semen analysis, yes, and it helps if he comes to '
            'the first appointment too. A male factor is involved in about '
            "half of cases, and it's the quickest thing to check. Testing "
            'only one of you can waste months.'),
      ),
      PvReadFaq(
        question: _en('What if my reports come back normal?'),
        answer: _en('That happens to a fair number of couples, and it has a '
            "name: unexplained infertility. It's frustrating to hear. But it "
            "isn't the same as being told nothing can be done. There's a "
            "standard plan for it, and it doesn't mean the tests were a "
            'waste.'),
      ),
      PvReadFaq(
        question: _en('Will they judge us for waiting this long?'),
        answer: _en("They shouldn't, and if they do, that tells you something "
            'about the clinic. Most couples come later than the guidelines '
            'suggest, for very ordinary reasons.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't wait for the twelve months"),
      // Written as short sentences (2026-09-26) so the door's pinned flag
      // shows one clear line per reason; same reasons, same urgency.
      body: _en("Book now if your cycles are irregular or missing. Book now if "
          "periods are very painful or very heavy, or if sex is painful. Book "
          "now if you've had pelvic surgery or a pelvic infection. Book now if "
          'there have been two or more miscarriages, or if you\'re 36 or over. '
          'Treat it as urgent (days, not weeks) if either of you is about to '
          'start cancer treatment, because saving fertility has to happen '
          'first.'),
    ),

    evidence: _en('When to be referred follows the NICE fertility guidance: '
        'after 12 months of regular sex without contraception for women under '
        "36; as soon as you ask for women 36 or over, or where there's a known "
        'or suspected cause or a history that makes one likely; and faster '
        'still where planned treatment may cause infertility. Sources checked '
        'August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, one by one'),
        value: _en("What each one measures, when in the cycle it's done, and "
            'what it costs in India.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Three months of dates to take with you'),
        value: _en('The most useful thing you can bring to a first '
            'appointment.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Speak to a fertility specialist'),
        value: _en('A first talk, on video, before you sign up with a '
            'clinic.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: [
      'ttc_read_ivf_explained',
      'ttc_read_how_long_it_takes',
      'ttc_read_age_after_35',
    ],
  ),


  // ===========================================================================
  //  INFERTILITY & IVF — "IUI/IVF explained"
  // ===========================================================================
  //  ⚠️ THIS IS THE READ THE DOOR HAS BEEN PROMISING AND NOT DELIVERING.
  //  The hub door "Understand my tests & treatment" says "What IUI and IVF
  //  actually involve, step by step, including what they cost", and it opened
  //  `ttc_treatment` — which is an IVF CYCLE TRACKER (stim start, trigger,
  //  retrieval, transfer, beta). Excellent for someone already in a cycle;
  //  useless to someone deciding whether to have one. The tracker is now what
  //  this read hands her at the end, which is the right order.
  PvRead(
    id: 'ttc_read_ivf_explained',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('What IUI and IVF involve'),
    teaser: _en("Step by step, in order, with the parts people don't warn you "
        'about, and a plain account of what each one asks of you.'),
    shortAnswer: _en('IUI places prepared sperm in the uterus around '
        "ovulation. It's a two-minute procedure after a few scans, with no "
        'anaesthetic. IVF collects eggs after about two weeks of injections, '
        'joins them with sperm in a lab and puts one embryo back, and it '
        'usually takes two to three months from the first tests to a '
        'result.'),

    scaleSetter: _en('Neither of these happens in one go. IUI is a few scans '
        'and a two-minute procedure spread over one cycle. IVF is about a '
        'month of injections, check-ups and waiting, with one day under '
        'sedation in the middle. Knowing the shape of it before you start '
        'makes it much easier to cope with.'),

    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),

    heroVideoSlot: 'ttc_vid_ivf_walkthrough',

    sections: [
      PvReadSection(
        heading: _en('What happens in IUI?'),
        paragraphs: [
          _en('Intrauterine insemination (IUI) does one thing. It places '
              'prepared sperm straight into the uterus at the right '
              'moment, so they skip the trip through the cervix. Everything '
              'else about the cycle is your own.'),
          _en('A cycle goes like this. Tablets or a low dose of injections at '
              'the start, to help a follicle grow. Two or three short scans to '
              "watch it. A trigger injection when it's ready, which sets "
              'ovulation for a known time.'),
          _en('Then, a day or so later, the '
              'procedure itself: a soft tube, about two minutes, no '
              'anaesthetic, and some mild cramping at most. You go home '
              'straight after.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who is IUI for?'),
        paragraphs: [
          _en('IUI suits some couples and not others. It needs at least one '
              "open tube and fairly good sperm. It's often the first treatment "
              "offered when no cause is found, when there's a mild problem "
              'with sperm, or when sex is difficult or not often.'),
          _en("It's usually tried for a small number of cycles before moving "
              'on, '
              'because almost all the pregnancies it leads to come in the '
              'first three.'),
        ],
      ),

      PvReadSection(
        heading: _en('What happens in IVF, step by step?'),
        paragraphs: [
          _en('IVF takes over the whole first half of the process. Eggs are '
              'grown on purpose, collected, joined with sperm in a lab, and '
              'one embryo is put back.'),
        ],
        bullets: [
          _en('Stimulation: around ten to twelve days of daily injections '
              'you give yourself at home, to grow several follicles instead of '
              'one. Feeling bloated and tender by the end is normal.'),
          _en('Monitoring: scans and blood tests every few days. People often '
              'underestimate this part. It means many early-morning trips to '
              "the clinic, and it's the main reason IVF is hard to fit around "
              'a job with fixed hours.'),
          _en('Trigger: one injection at an exact time, usually late at '
              'night, that gets the eggs ready. The timing is exact, and it '
              'matters.'),
          _en('Retrieval: about twenty minutes under sedation, while the eggs '
              'are collected with a fine needle guided by ultrasound. You go '
              'home the same day, usually sore and tired.'),
          _en('The lab: fertilisation happens overnight, either by putting '
              'eggs and sperm together or, in ICSI, by injecting one sperm '
              'into each egg. The embryos then grow for a few days, and you '
              'get a phone call each day about how many are still growing. '
              'For many people, those calls are the hardest part.'),
          _en('Transfer: one embryo is placed in the uterus with a fine, soft '
              "tube. It takes minutes, needs no anaesthetic, and you'll feel "
              'very little.'),
          _en('The wait: about two weeks, on progesterone support, until a '
              "blood test. Home pregnancy tests in this time can't be trusted "
              "because of the trigger injection. That's why clinics ask you "
              'not to use them.'),
        ],
      ),

      PvReadSection(
        heading: _en('Fresh or frozen: why are so many transfers frozen now?'),
        paragraphs: [
          _en('An embryo can be put back in the same cycle it was made, which '
              'is called a fresh transfer. Or it can be frozen and put back in '
              'a later, calmer cycle.'),
          _en('Freezing has become common for two reasons. The injections that '
              'grow lots of eggs also leave the lining of the uterus less ready '
              'to accept an embryo. And freezing gives your body time to '
              'settle before implantation is tried.'),
          _en('Being told your transfer '
              'will be frozen is normal practice, not a setback, even though '
              'it often feels like one.'),
          _en('It also means one round of injections can give you several '
              "tries. That's the thing most worth understanding before you "
              'look at any prices.'),
        ],
        tip: PvReadTip(
          title: _en('The question to ask about ICSI'),
          body: _en("ICSI means injecting one sperm into each egg. It's needed "
              'when sperm count or quality is the problem, but many clinics '
              "also use it for everyone. It adds to the cost. It's completely "
              'fair to ask: are you suggesting ICSI because of our own '
              "results, or because it's what you always do here?"),
        ),
      ),

      // ⚠️ TWO SECTIONS WERE REMOVED FROM HERE, AND THEY WERE NOT LOST.
      //
      // This article was written when it was the only long piece in the door,
      // so it carried everything: the procedures, fresh versus frozen, what a
      // cycle asks of you, and how to read a clinic's numbers. The IVF rebuild
      // gave the last two their own pieces — "The injections, honestly" and the
      // "How to read a clinic's success rate" carousel — which cover them far
      // better than a folded section inside an overview ever did.
      //
      // Leaving both in place would have meant a reader tapping "What IUI and
      // IVF involve" and then "The injections, honestly" reading the same
      // material twice, in two voices. That is worse than either version alone.
      //
      // ⚠️ AND THE ARTICLE ITSELF SURVIVES, WHICH THE BRIEF DID NOT ASK FOR.
      // Step 5 says to split this up and delete it. What that would cost is the
      // one piece that answers "what actually IS this" for someone who has just
      // been told to consider IVF and knows nothing — and that reader is most
      // of this door's traffic. So it keeps the three sections nothing else
      // covers and hands over the two that are now owned elsewhere.
      //
      // Moved to `ttc_read_ivf_injections`:  what a cycle asks of you.
      // Moved to the clinic-numbers carousel: how to read a success rate.

      // ⚠️ WRITTEN TO REPLACE THEM, NOT TO PAD THE COUNT. Removing two sections
      // dropped this below the shape floor, and the honest fix was to ask what
      // an overview still owed a reader that nothing else in the door answers.
      // It is this: how long the whole thing takes. Every other piece explains
      // a part; nobody had written the calendar.
      PvReadSection(
        heading: _en('How long does the whole thing take?'),
        paragraphs: [
          _en('From a first appointment to a result is usually two to three '
              'months. Most of that time is waiting, not treatment.'),
          _en('The tests come first and usually take one or two cycles, '
              'because several of them have to be done on certain days. Then '
              "there's often a wait for a cycle to start at a time the clinic "
              'can fit you in.'),
          _en('The busy part is short. Stimulation takes about two weeks, '
              'retrieval takes a morning, and a fresh transfer is three to five '
              'days later. Then comes the two-week wait. Everyone finds that '
              'fortnight the hardest, whichever way they got there.'),
          _en('If everything is frozen, the transfer moves to a later cycle '
              "and adds a few weeks. That's a common choice made on purpose, "
              'not a delay, and it helps to hear it that way when your clinic '
              'suggests it.'),
          _en("So a cycle isn't a whole month out of your life, the way people "
              "imagine. It's a fortnight of injections and a few early "
              'mornings, inside a couple of months of appointments and '
              'waiting.'),
        ],
      ),

      // Gap plan 2026-09-26: twins, said before anyone starts. No personal
      // figure, by rule.
      PvReadSection(
        heading: _en('Does treatment make twins more likely?'),
        paragraphs: [
          _en('Yes. Any treatment that grows more than one follicle, or puts '
              'back more than one embryo, makes twins more likely than in a '
              'pregnancy without treatment. That includes the tablets and '
              'injections used with IUI.'),
          _en('Twins can sound like a lovely bonus. But carrying twins brings '
              'more risk for you and for the babies, especially of an early '
              'birth. So clinics watch follicles closely in IUI cycles, and may '
              'stop a cycle where too many are growing.'),
          _en('In IVF, putting back one embryo at a time is now the standard '
              "way to keep this risk low. If you're offered two, it's fair to "
              'ask why, and to talk through the risks first.'),
        ],
      ),

      // Gap plan 2026-09-26: the other options, so IVF isn't the only door.
      PvReadSection(
        collapsible: true,
        summary: _en('Tablets, surgery, treatment on his side and donor '
            'options: the other choices a doctor may talk about.'),
        heading: _en('Are there other treatments besides IUI and IVF?'),
        paragraphs: [
          _en('Yes, and many couples need one of these rather than IVF. Your '
              'doctor chooses from them based on what the tests find.'),
        ],
        bullets: [
          _en('Tablets to bring on ovulation, such as letrozole or clomifene, '
              "when eggs aren't being released regularly. This is often the "
              'very first treatment.'),
          _en('Keyhole surgery, when something physical is in the way. It can '
              'treat endometriosis, remove polyps or fibroids that change the '
              'inside of the uterus, and sometimes open a tube with mild '
              'damage.'),
          _en('Treatment on his side, such as surgery for swollen veins in the '
              'scrotum (a varicocele), or medicine when a hormone problem is '
              'the cause.'),
          _en('Collecting sperm with a fine needle or a small operation (TESA, '
              'PESA or TESE) when none show up in the semen but the testicles '
              'are still making some.'),
          _en('Sperm washing, which separates the healthy, moving sperm from '
              "the rest of the semen. It's part of every IUI and IVF, and it's "
              'also used when one partner has a virus such as HIV, to lower the '
              'risk of passing it on.'),
          _en('Donor eggs or donor sperm, and in a few cases surrogacy. In '
              'India these follow strict rules under the ART (Regulation) Act '
              '2021 and the Surrogacy (Regulation) Act 2021, and your clinic '
              'will confirm what applies to you.'),
        ],
      ),

    ],

    faqs: [
      PvReadFaq(
        question: _en('Is egg retrieval painful?'),
        answer: _en("It's done under sedation, so you won't feel it at the "
            'time. Afterwards, expect cramps and a heavy, bloated feeling for '
            'a day or two, a bit like a bad period. Most people take the day '
            'off and feel fine the next day.'),
      ),
      PvReadFaq(
        question: _en('How many IUI cycles before moving to IVF?'),
        answer: _en('Usually three, sometimes up to six depending on age and '
            'the cause, because most IUI pregnancies happen in the first three '
            "cycles. It's a fair question to ask right at the start."),
      ),
      PvReadFaq(
        question: _en('Can I work through an IVF cycle?'),
        answer: _en("Most people do. The hard part isn't the injections. It's "
            'the monitoring: several early-morning clinic visits at short '
            'notice over about two weeks, plus one day off for retrieval. Jobs '
            'with fixed hours and no give are the tricky ones.'),
      ),
      PvReadFaq(
        question: _en('Does bed rest after transfer help?'),
        answer: _en('No. Lying still afterwards has been studied, and it '
            "doesn't improve results. An embryo can't fall out. Clinics that "
            'still suggest it are being kind, not following the research. '
            'Normal daily activity is fine.'),
      ),
      PvReadFaq(
        question: _en('Are IVF babies different in any way?'),
        answer: _en('No real difference in health or development has been '
            "shown. There's a slightly higher rate of early (preterm) birth "
            'and low birth weight, and much of that comes from twins and '
            "triplets. That's exactly why putting back one embryo at a time "
            'is now standard practice.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('During a cycle, call the clinic'),
      body: _en('Not the emergency department, and not the internet. Call your '
          'own clinic, which will have a number for exactly this. Call if you '
          'have a lot of bloating or put on weight fast over a day or two, severe '
          "pain in your tummy, trouble breathing, or if you're passing much "
          'less urine than usual. These are signs of ovarian '
          "hyperstimulation, and when it's reported early it's very "
          'manageable. Anything about your own dose, your own scan or your '
          'own embryos belongs with the team treating you.'),
    ),

    evidence: _en('The order of the steps, the reasons for freezing all '
        'embryos, putting back one embryo as standard practice, and ovarian '
        'hyperstimulation as the main complication follow standard fertility '
        'treatment practice as described by ESHRE and ASRM. Twins with '
        'treatment and the other treatments listed follow NICE CG156. Donor '
        'and surrogacy rules: the ART (Regulation) Act 2021 and the Surrogacy '
        '(Regulation) Act 2021. Sources checked August 2026. Nothing here '
        'describes your own treatment plan, which your clinic sets.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('What it costs in India'),
        value: _en('Real price ranges, what a package leaves out, and the bills '
            'that come separately.'),
        surfaceId: 'ttc_read/ttc_read_ivf_costs',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Track a cycle you're already in"),
        value: _en('Injections, trigger, retrieval, transfer and the test date, '
              'all in one place and shared with him.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your reports together'),
        value: _en('Every result in one place, so a second opinion takes an '
            'evening, not a week.'),
        surfaceId: 'ttc_records',
      ),
    ],

    readNext: [
      'ttc_read_ivf_costs',
      'ttc_read_ovulation_tablets',
      'ttc_read_clinic_glossary',
    ],
  ),

  // ===========================================================================
  //  ⚠️ THE MOST DANGEROUS ARTICLE IN THIS DOOR, AND THE SCOPE IS THE SAFETY
  // ===========================================================================
  //
  //  "How to read a clinic's success rate" sits one careless sentence away from
  //  the thing this product never does: a personalised probability. The rule
  //  that keeps it on the right side is a scope decision, not a wording one —
  //
  //     It teaches the MEASURES. It never applies them.
  //
  //  So: what a denominator is, why "success" has four possible meanings, what
  //  case-mix does to a number. Never "so your chance is", never "a good clinic
  //  is above X", never a benchmark figure she could hold a clinic against.
  //
  //  ⚠️ AND IT NAMES NO CLINIC AND RANKS NONE. Not modesty — we have no data,
  //  no audit and no standing, and a fertility clinic's reputation is somebody's
  //  livelihood. The article gives her the questions; the answers are the
  //  clinic's to give and hers to judge.
  //
  //  ⚠️ NO FIGURES AT ALL, INCLUDING "TYPICAL" ONES. A number in an article
  //  becomes a target on a screenshot. Every quantity here is relational —
  //  higher, lower, smaller, wider — which is what she actually needs to
  //  compare two clinics, and it is the half that cannot be misread as a
  //  promise about her.
  PvRead(
    id: 'ttc_read_ivf_success_rates',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en("How to read a clinic's success rate"),
    teaser: _en('Two clinics can quote very different numbers and both be '
        'telling the truth. What the number is counting is the part that '
        'matters.'),
    shortAnswer: _en('A success rate depends on what it counts: a positive '
        'test, a pregnancy seen on a scan, or a live birth, and whether it is '
        'per cycle started or per transfer. It also depends on the age and '
        "needs of the clinic's patients. Ask which number you're looking at "
        'before you compare two clinics.'),
    scaleSetter: _en('A success rate is a fraction, and most of what matters '
        "is in the bottom half, the part it's divided by. Nothing here says a "
        "number is too low or high enough. An app can't know that about a "
        'clinic, or about you. What this does is give you the same questions '
        'a doctor would ask if they were reading the figure with you.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("If you've started looking at clinics, you've seen success "
              "rates. They're usually on the website, often on the wall, and "
              "they're the first thing most people try to compare."),
          _en("They're worth reading. But you can't compare them the way you "
              "compare prices, because there's no single agreed way to work "
              'one out. Two honest clinics can show very different figures for '
              'the same work. And two clinics doing very different work can '
              'show the same figure.'),
          _en("This isn't about catching anyone out. Most of the difference "
              'comes from choices made in the open: which patients, which '
              'cycles, and which result was counted. Once you know those '
              'choices, the number starts to help instead of confuse.'),
        ],
      ),
      PvReadSection(
        heading: _en('Success at what, exactly?'),
        paragraphs: [
          _en('In fertility, the word success can mean at least four '
              'different things. The further down this list you go, the more '
              'they differ.'),
          _en('A positive pregnancy test comes earliest and gives the '
              'biggest number. A clinical pregnancy comes a few weeks later: '
              'a scan showing a pregnancy in the right place, with a '
              'heartbeat. That number is smaller.'),
          _en('A live birth is what almost '
              "everyone really means, and it's the smallest of the three."),
        ],
      ),
      PvReadSection(
        heading: _en('What is a cumulative rate?'),
        paragraphs: [
          _en('The fourth is a different kind of number. A cumulative rate '
              'counts everything that came from one egg collection, including '
              "frozen embryos put back months later. It's a useful figure, "
              "and it's much larger than a per-transfer one, because it "
              'answers a bigger question.'),
          _en("So first, find out which of the four you're looking at. A "
              'clinic quoting a positive-test rate and a clinic quoting a '
              "live-birth rate aren't disagreeing. They're talking about "
              'different things.'),
        ],
      ),
      PvReadSection(
        heading: _en('Out of how many?'),
        paragraphs: [
          _en('The other half of the fraction is which cycles were counted. '
              'It changes the answer as much as the result being counted '
              'does.'),
          _en('Per cycle started counts everyone who began treatment, '
              "including cycles stopped before any eggs were collected. It's "
              'the toughest way to count, and the most honest about what '
              'someone walking in is signing up for.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why do other counts give bigger numbers?'),
        paragraphs: [
          _en('Per egg collection leaves out the stopped cycles. Per transfer '
              'leaves those out too, and also anyone who reached collection '
              'but had no embryo to put back.'),
          _en('Each step up removes some of the '
              'people for whom things went least well. So each step gives a '
              'bigger number from the same results.'),
          _en('None of those three is wrong. They answer different questions. '
              '"Per cycle started" is the closest to what people really want '
              'to know: what happens to someone like me who walks through '
              'this door.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who was counted, and why does it matter most?'),
        paragraphs: [
          _en('Age affects IVF results more than anything else, by a long way. '
              'A clinic whose patients are younger on average will show better '
              'figures than a clinic doing the same work with older patients. '
              'Neither clinic has done anything unusual.'),
          _en('Other things matter too. A centre that takes '
              'hard cases (many failed cycles, serious sperm problems, low '
              'egg reserve, people other clinics have turned away) is being '
              'judged on a harder group of patients. Its number can be lower '
              "because of the work it's willing to do."),
          _en("That's why one overall figure for the whole clinic is the least "
              'useful number on the page. It describes a mix of people, and '
              "you aren't a mix."),
          _en('Figures split by age group tell you more. A '
              'clinic that shares that split is telling you something about '
              "itself before you've even asked."),
        ],
      ),
      PvReadSection(
        heading: _en("Why won't we give you a personal figure?"),
        paragraphs: [
          _en('It\'s also why the honest answer to "what are my chances" comes '
              'from a doctor who has seen your results, not from a number on a '
              'website.'),
          _en("ParentVeda won't give you that figure, and no app "
              'should. It depends on things only a doctor looking at your '
              'tests can weigh up.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why do small numbers jump around?'),
        paragraphs: [
          _en('A rate worked out from only a few cycles can move a lot on very '
              'little. In a small enough group, a couple of extra pregnancies '
              'one year and a couple fewer the next can change the main figure '
              'hugely, with nothing about the clinic changing at all.'),
          _en('So ask how many cycles the figure is based on, and over what '
              'period. A rate from many cycles over a set stretch of time is '
              'steadier than a rate from a handful, even when the handful '
              'looks better.'),
          _en('Be a little careful of a figure with no time period attached. '
              '"Our success rate" without a year is a claim you can\'t check '
              'against anything, not even the same clinic next year.'),
        ],
      ),
      PvReadSection(
        heading: _en("What doesn't the number cover?"),
        paragraphs: [
          _en('Some of what makes a clinic good never shows up in a success '
              'rate.'),
          _en('Whether the same doctor sees you each visit. Whether '
              "someone picks up the phone at nine at night when you're "
              'frightened. Whether the counselling is real or just for show. '
              "Whether they told you honestly when a cycle wasn't worth "
              'starting.'),
          _en("There's a harder one too. A clinic can push its published "
              'figure up by being choosy about who it treats. And a clinic '
              'that takes on people with a difficult outlook will look worse '
              "on paper for doing something generous. The number can't tell "
              'those two apart. A conversation can.'),
          _en("Safety doesn't show up either. How often patients end up in "
              'hospital with ovarian hyperstimulation, and how many embryos '
              'they put back at a time: a success rate can look better by '
              "ignoring both. It's fair to ask about them out loud."),
        ],
      ),
      PvReadSection(
        heading: _en('What should you ask, in the room?'),
        paragraphs: [
          _en('Is that a live-birth rate, a clinical-pregnancy rate, or a '
              'positive-test rate?'),
          _en('Is it per cycle started, per egg collection, or per transfer?'),
          _en('Is it cumulative? Does it include frozen transfers from the '
              'same collection?'),
          _en("What's the figure for my age group, not overall?"),
          _en('How many cycles is that based on, and over what period?'),
          _en('How many embryos do you usually put back at a time?'),
          _en('None of these is a pushy question. A clinic that reports '
              'carefully will have the answers ready and will be glad you '
              "asked. A clinic that's vague about which number it's quoting "
              'has told you something too.'),
        ],
      ),
      PvReadSection(
        heading: _en('Then use it as one thing among several'),
        paragraphs: [
          _en('Once you know what a figure is counting, it goes into the '
              'decision with everything else.'),
          _en("How far you'll travel at six in "
              'the morning for a scan. What the whole thing will cost, '
              'including the parts outside the package. Whether you were '
              'listened to. Whether you trust the person explaining it.'),
          _en('Lots of people choose a clinic they can get to, that they can '
              'afford, where someone was kind to them and honest with them. '
              "That isn't settling. So much of a rate depends on who else walks "
              'through the door, so this is a sensible way to choose.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When a number is used to hurry you'),
      body: _en('A success rate should help you decide, not push you. If a '
          'figure is being used to press you to start right away, to pay '
          "today, or to buy add-ons nobody has explained, that's a reason to "
          'slow down and get a second opinion. A second opinion before '
          'starting treatment is normal and expected. And if anyone ever gives '
          'you a personal chance as a firm number, a set percentage just for '
          "you, ask what it's based on. An honest answer gives a range and "
          'the things that could change it.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is a higher rate always a better clinic?'),
        answer: _en('No. It can mean better care. It can also mean younger '
            'patients, simpler cases, a kinder way of counting, or a smaller '
            'group. Until you know which it is, two numbers on two websites '
            "aren't measuring the same thing."),
      ),
      PvReadFaq(
        question: _en('Can you tell me what my chances are?'),
        answer: _en("No, and that's a limit we set on purpose, not a gap. A "
            'personal chance depends on things only a doctor who has seen '
            'your results can weigh up. A figure from an app would be a guess '
            'with a decimal point on it. Take your results to a specialist and '
            'ask them directly.'),
      ),
      PvReadFaq(
        question: _en('Should I pick the clinic with the best figure?'),
        answer: _en('Treat it as one of several things. The cost, including '
            'what sits outside the package. How easy it is to reach for '
            'early-morning scans. How many embryos they put back at a time. '
            'Whether you felt heard. All of these belong in the same '
            'decision.'),
      ),
      PvReadFaq(
        question: _en("Why doesn't anyone publish one number we can compare?"),
        answer: _en("Because there's no single agreed meaning of success, or "
            'of which cycles to count. And the kinds of patients differ so '
            'much between clinics that one ranked figure would mislead more '
            'than it explained. Official records in several countries publish '
            'breakdowns, not league tables, for exactly that reason.'),
      ),
    ],
    evidence: _en('ICMR National Guidelines for Accreditation, Supervision and '
        'Regulation of ART Clinics in India; the ART (Regulation) Act 2021 and '
        'what it asks clinics to report; HFEA guidance on how clinic success '
        'rates should be shown and compared; ESHRE and ICMART definitions of '
        'ART outcome terms; NICE CG156. On purpose, this article has no '
        'figures, benchmarks or clinic names. It explains how to read a rate, '
        'never what a rate should be. Sources checked August 2026.'),
    readNext: ['ttc_read_ivf_package', 'ttc_read_ivf_costs'],
  ),


  // ===========================================================================
  //  INFERTILITY & IVF — "cost expectations"
  // ===========================================================================
  //  ⚠️ ITS OWN READ, NOT A SECTION, and the Excel is the reason: "cost
  //  expectations" is listed as a distinct topic in the Content cell. It is
  //  also the single most searched aspect of this bracket and the one the app
  //  had nothing on at all — the treatment screen contains no rupee figure
  //  anywhere.
  //
  //  ⚠️ EVERY FIGURE IS DATED AND ATTRIBUTED, because fertility pricing in
  //  India is published almost entirely by the clinics selling the treatment.
  //  That does not make it useless — it makes it a range to sanity-check
  //  against rather than a quotation, and saying so is the difference between
  //  informing her and reprinting an advertisement.
  PvRead(
    id: 'ttc_read_ivf_costs',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('What IVF really costs in India'),
    teaser: _en('Real price ranges as of 2026, what an advertised package '
        'leaves out, and the bills that come separately.'),
    shortAnswer: _en('One full IVF cycle in India usually costs about ₹1.5 to '
        '₹2.5 lakh in 2026, and more at big-city chains. Advertised packages '
        'of ₹90,000 to ₹1.2 lakh often leave out the medicines, which are '
        'about a third of the bill. IUI costs much less, often ₹15,000 to '
        '₹35,000 a cycle with medicines.'),

    scaleSetter: _en('The price a clinic advertises is almost never what you '
        "pay. It's usually the procedure fee alone. The medicines, which are "
        'about a third of the bill, are charged separately. Knowing that one '
        'thing before you walk in is worth more than any other money tip '
        'here.'),

    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("In India, most health insurance doesn't cover fertility "
              'treatment. You pay for it yourself, and prices vary a lot from '
              'one clinic to the next.'),
          _en('The ranges below are what clinics '
              'across the country were publishing in 2026. Use them to check '
              "whether a quote you're given seems sensible, not as a fixed "
              'price list.'),
          _en('The first tests for both of you usually come before any of '
              'this. They add up to several thousand rupees, and the tests page '
              'lists each one with its own range.'),
        ],
      ),

      PvReadSection(
        heading: _en('What does IUI cost?'),
        paragraphs: [
          _en('A natural-cycle IUI, with no fertility medicines, is usually '
              'quoted at around ₹5,000 to ₹10,000 for the procedure. Most IUI '
              'uses medicines, and a medicated cycle usually comes to between '
              '₹15,000 and ₹35,000 in total. The ovulation medicines add '
              'roughly ₹5,000 to ₹10,000 on top of the procedure fee.'),
          _en('IUI is usually tried for around three cycles, so budget for '
              'three, not one.'),
          _en("IUI costs less partly because there's no egg collection, no "
              'lab work on eggs and no sedation. But three cycles can add up to '
              'a good part of one IVF cycle, so it helps to ask early when your '
              'doctor would suggest moving on.'),
        ],
      ),

      PvReadSection(
        heading: _en('What does one IVF cycle really cost?'),
        paragraphs: [
          _en('For one full IVF cycle in 2026, a realistic total is roughly '
              '₹1.5 to ₹2.5 lakh at an independent clinic, and ₹2 to ₹3.5 '
              'lakh at a large fertility chain in a big city. In tier-2 cities '
              'the same cycle often costs ₹1 to ₹1.8 lakh.'),
          _en('The packages advertised at ₹90,000 to ₹1.2 lakh are only the '
              'basic procedure fee: collecting the eggs, fertilising them in '
              "the lab, and one embryo transfer. That's a real price for a real "
              "part of the treatment. It isn't the cost of the whole "
              'treatment.'),
          _en("A frozen transfer later, if the first try doesn't work or you'd "
              'like a second child, costs much less than a full cycle. There '
              'are no stimulation injections and no egg collection. Ask for its '
              'price at the same time as the package.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('What almost always sits outside the package'),
          body: _en('Stimulation medicines, at roughly ₹40,000 to ₹90,000, which '
              'is about a third of the final bill. ICSI, which adds roughly '
              '₹15,000 to ₹45,000. Freezing embryos, and storing them each '
              'year. A frozen transfer later, which is a separate cycle with its '
              'own fee. Extra scans beyond the number in the package. And the '
              'first tests for both of you, before any of it starts.'),
        ),
      ),

      PvReadSection(
        heading: _en('Which questions change the price?'),
        paragraphs: [
          _en('Ask these before you pay anything, and ask for the answers in '
              "writing. If a clinic won't put a quote on paper, that tells you "
              'something.'),
        ],
        bullets: [
          _en('What exactly is in the package, and what is charged separately?'),
          _en('How many monitoring scans are included, and what does each '
              'extra one cost?'),
          _en('Is ICSI included, and is it being suggested because of our '
              'results or because you always do it?'),
          _en('What does freezing cost, and a year of storage, and a frozen '
              'transfer later?'),
          _en('If the cycle is stopped before egg collection, what do we get '
              'back?'),
          _en('Do we buy the medicines through the clinic or from a chemist, '
              'and can we compare prices?'),
        ],
        tip: PvReadTip(
          title: _en('About the medicines'),
          body: _en("They change the most from person to person, and they're "
              'often the biggest single cost. Prices can differ a fair bit '
              'between the clinic pharmacy and an outside chemist, and between '
              'brands of the same medicine. Asking if you can buy them yourself '
              'is a normal question, not a rude one.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Practical and grim; needed on the day it is needed.
        collapsible: true,
        summary: _en('Insurance, EMI plans, refund packages and offers for '
            'several cycles. Read this before you sign.'),
        heading: _en('How do people pay for it?'),
        paragraphs: [
          _en("Most Indian health insurance doesn't cover fertility treatment "
              'at all, though a few company group policies have started to '
              'offer some cover. Read your own policy instead of guessing, and '
              'ask your HR team directly.'),
          _en('Many clinics offer EMI plans, often through an outside lender. '
              'Look at the interest rate, not the monthly amount. The monthly '
              'amount is made to look comforting.'),
          _en('Packages for several cycles, with a refund, are more and more '
              'common. You pay more up front for two or three cycles, and get '
              'part of it back if none works.'),
          _en("They can be good value if you're "
              "likely to need more than one cycle, and poor value if you're "
              'likely to need one. Read the small print closely. Who qualifies, '
              'what counts as a cycle, and what a refund really covers are '
              'where the details hide.'),
        ],
      ),

      PvReadSection(
        heading: _en('One thing worth saying out loud'),
        paragraphs: [
          _en("How much to spend on this isn't a medical question, and nobody "
              'at a clinic can answer it for you. It helps if the two of you '
              "agree on an amount, and a point where you'd stop, before the "
              'first cycle rather than during the third.'),
          _en('That talk is uncomfortable, and it protects you. Otherwise you '
              "end up deciding one cycle at a time, just when it's hardest to "
              'think clearly.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Why do quotes differ so much between clinics?'),
        answer: _en('Lab quality and staff are real differences, and they '
            'matter. Beyond that, much of the gap comes from the city, the '
            "brand, and what's been bundled into the advertised price. A higher "
            "price on its own doesn't prove a better lab."),
      ),
      PvReadFaq(
        question: _en('Is treatment abroad cheaper?'),
        answer: _en('For most people in India, no. India is already one of '
            'the cheaper countries for IVF, which is why people travel here '
            'for it. Travel, somewhere to stay and repeat visits usually wipe '
            'out any saving.'),
      ),
      PvReadFaq(
        question: _en('Does a government hospital do IVF?'),
        answer: _en('Some larger public and teaching hospitals have fertility '
            'units that cost much less, with waiting lists and rules about who '
            "can be treated. It's worth asking near you. What's on offer "
            'varies a lot from state to state.'),
      ),
      PvReadFaq(
        question: _en('Should we budget for more than one cycle?'),
        answer: _en("It's the more realistic way to plan. It's also why "
            'freezing matters for your budget. One round of injections that '
            'makes several embryos gives several tries at the much lower cost '
            'of a frozen transfer, instead of a full cycle each time.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Before you pay a deposit'),
      body: _en("Ask for the full quote in writing, including what's left out "
          'and what happens to your money if the cycle is stopped. If a clinic '
          "won't give you that, or pushes you to decide the same day, take "
          'both as reasons to get a second opinion first. Nothing about this '
          "treatment is so urgent that it can't wait for a written quote. And "
          'your own doctor is still the person to ask what you really need '
          'medically.'),
    ),

    evidence: _en('Cost ranges come from prices published by Indian fertility '
        "clinics and treatment comparison sites during 2026. They're given as "
        "ranges because prices vary a lot by city, clinic and what's included. "
        'To be honest about the source: almost all fertility pricing in India '
        'is published by the clinics selling the treatment. So these figures '
        "are a check against a quote you're given, never a replacement for one "
        'in writing. Checked August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, with their own price ranges'),
        value: _en('What the tests cost before treatment even starts.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Get a second opinion before you commit'),
        value: _en("A fertility specialist who isn't the clinic quoting you."),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_when_to_seek_help'],
  ),
  // ===========================================================================
  //  The IVF & IUI rebuild set
  // ---------------------------------------------------------------------------
  //  ⚠️ TWO RULES BIND EVERY ONE OF THESE, HARDER HERE THAN ANYWHERE ELSE IN
  //  THE STAGE.
  //
  //  **No success rate, no chances, no prediction.** Not for her, not for a
  //  cycle, not "couples like you". Population figures survive only where they
  //  reduce pressure. `ttc_brackets.dart` also marks products notApplicable on
  //  this bracket with the reason "Not a fit (clinical)" — so nothing here sells
  //  anything either. The consult is a door because she asked for it.
  //
  //  **A clinic owns the cycle.** Where a clinician has made a decision we
  //  explain what it is for; we never restate it as advice, never suggest a
  //  dose, and never imply a protocol should have been different. See
  //  `TimingOwnership` in `ttc_care_pathway.dart`.
  // ===========================================================================

  PvRead(
    id: 'ttc_read_ivf_icsi',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en("ICSI: when it's needed, and when it's just routine"),
    teaser: _en("An extra step inside IVF that's sometimes essential, and "
        'sometimes charged for anyway.'),
    shortAnswer: _en('ICSI is one lab step inside IVF, where a single sperm is '
        "injected into each egg. It's needed when there's a sperm problem, "
        'when sperm were collected by surgery, or when an earlier cycle had no '
        "fertilisation. With normal semen results, research hasn't shown it "
        'leads to more live births than standard IVF.'),
    scaleSetter: _en("ICSI isn't a different treatment from IVF. It's one step "
        'inside IVF, done a different way. Whether you need it depends almost '
        'entirely on his semen results. Knowing that helps you ask a useful '
        'question when it shows up on a quote.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('In standard IVF, eggs and prepared sperm are put together in a '
              'dish, and fertilisation is left to happen by itself. In ICSI, '
              'a lab specialist (an embryologist) picks one sperm and injects '
              'it straight into each mature egg.'),
          _en('Everything before that point is exactly the same: the same '
              'injections, the same scans, the same egg collection. Everything '
              'after is the same too. ICSI is one step in the lab, not a '
              'different treatment path.'),
          _en("On reports and quotes it's often written as IVF-ICSI or "
              'ICSI-IVF. Both mean the same thing.'),
        ],
      ),
      PvReadSection(
        heading: _en('When is ICSI really needed?'),
        paragraphs: [
          _en('The clear reason is a sperm problem: a low count, poor '
              'movement, or a high share of oddly shaped sperm.'),
          _en('If too few '
              'sperm can reach an egg and get inside it on their own, leaving '
              "it to happen in a dish means hoping for something that isn't "
              'likely to happen.'),
          _en("It's also used when sperm had to be collected by surgery, when "
              'an earlier IVF cycle led to no fertilisation at all, and '
              'sometimes when eggs were frozen and thawed. The outer layer of '
              'a thawed egg can be harder for sperm to get through.'),
          _en("In these cases ICSI isn't an upgrade. It's what makes "
              'fertilisation possible.'),
        ],
      ),
      PvReadSection(
        heading: _en("Why is it added when there's no sperm problem?"),
        paragraphs: [
          _en('ICSI is now used in most IVF cycles around the world, including '
              'many where the semen results are completely normal. The '
              "research doesn't back that up."),
          _en("When there's no sperm problem, trials and large reviews of "
              "records have mostly found that ICSI doesn't lead to more live "
              "births than standard IVF. It isn't dangerous. It isn't free "
              "either. It's a lab procedure with a fee attached."),
          _en('So when it shows up on a quote, the useful question is: what '
              'in our results makes ICSI the right choice for us? A clinic '
              "with a reason will give it to you in a sentence. It's a fair "
              "thing to ask, and it isn't picking a fight."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('This is a question, not an accusation'),
          body: _en('Plenty of clinics use ICSI for everyone for reasons they '
              'can explain, including results from their own lab. Asking for '
              "the reason gets you information. Assuming there isn't one gets "
              'you a difficult appointment.'),
        ),
      ),
      PvReadSection(
        heading: _en("What doesn't ICSI do?"),
        paragraphs: [
          _en('ICSI makes it more likely that an egg gets fertilised. It '
              "doesn't improve egg quality. It doesn't make an embryo more "
              "likely to implant. And it doesn't change anything about the "
              'pregnancy that follows.'),
          _en('It helps to be clear about this, because ICSI is sometimes '
              'talked about as if it makes IVF work better in general. It '
              'solves one step, for one particular problem.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about the other add-ons on a quote?'),
        paragraphs: [
          _en('The same goes for the add-ons that often sit next to ICSI on a '
              'quote, like assisted hatching, embryo glue, and various '
              'embryo-picking methods with confident names.'),
          _en('Most have weak or '
              'no evidence that they lead to more live births. Several cost '
              'extra. And none of them is the reason a cycle worked or '
              "didn't."),
          _en('A sensible way through a long quote is to ask which items are '
              'part of the treatment and which are optional. For each optional '
              "one, ask what it's expected to change in your case. It's a "
              "short talk, and it's the one most likely to save you money."),
        ],
      ),
      PvReadSection(
        heading: _en('Is ICSI safe for the baby?'),
        paragraphs: [
          _en('Large studies that followed children born through ICSI have '
              'mostly been reassuring. Some data show a small rise in certain '
              'outcomes. Current thinking is that much of this probably comes '
              'from the reason ICSI was needed (the sperm problem itself), not '
              'from the method.'),
          _en("That's an honest summary of an area that's still being "
              "studied. It's best talked through with the specialist who knows "
              'your results, rather than reading your own conclusion into it.'),
          _en("If a genetic cause for a low count has been found, there's a "
              'separate, more specific point. Some of those causes can be '
              'passed on to a son.'),
          _en("That's a talk for a specialist, and "
              "sometimes a genetics doctor. It's also a reason to ask what "
              'caused the low count, not only how to work around it.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask before you sign the consent form'),
      body: _en('If ICSI is on your plan or your quote, ask what in your '
          'results makes it the right choice, and what it costs. Ask before '
          "you sign, not after. If you've had a cycle with no fertilisation at "
          'all, bring that up clearly, because it changes the answer.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is ICSI better than IVF?'),
        answer: _en("Not in general. When there's a sperm problem, it's often "
            "needed. When semen results are normal, the research mostly hasn't "
            'found more live births than with standard IVF.'),
      ),
      PvReadFaq(
        question: _en('Our clinic only offers ICSI. Is that a problem?'),
        answer: _en("It's a reason to ask why. Some labs use it for everyone "
            'because of their own results and to keep things consistent. A '
            'clinic that can explain its policy is different from one that has '
            'never been asked.'),
      ),
      PvReadFaq(
        question: _en('Does ICSI let us choose the best sperm?'),
        answer: _en('The embryologist picks a sperm by how it looks and moves, '
            "which only tells them so much. It's a choice by eye, not a "
            "genetic test, and it shouldn't be described as choosing a better "
            'baby.'),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems); ESHRE guidance on when to '
        'use ICSI; Cochrane review of ICSI compared with standard IVF when '
        "there's no male factor; long-term follow-up studies of children "
        'conceived by ICSI. Sources checked August 2026.'),
    readNext: ['ttc_read_ivf_explained'],
  ),

  PvRead(
    id: 'ttc_read_ivf_workup',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('What a fertility check involves'),
    teaser: _en('The tests, roughly when in your cycle they happen, and what '
        'each one is for, so the first appointment holds no surprises.'),
    shortAnswer: _en('A fertility check answers three questions: are you '
        'releasing an egg, is the path open, and is there enough healthy '
        'sperm. For you that usually means blood tests, a scan and sometimes '
        'a tube test. For him it means a semen analysis, and the whole check '
        'takes one or two cycles.'),
    scaleSetter: _en('A first fertility appointment is mostly a talk and a '
        'plan for tests. Very little is decided on the day. If you know what '
        'is likely to be ordered, and why, it stops feeling like being '
        'questioned and becomes a talk you can take part in.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('A fertility check tries to answer three questions. Is an egg '
              'being released? Is there a clear path for it? Is there enough '
              'healthy sperm to meet it?'),
          _en("Almost every test you're sent for belongs to one of those "
              'three. A first appointment usually starts on all three at once, '
              'rather than going through them one by one.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is an egg being released?'),
        paragraphs: [
          _en('The direct check is a progesterone blood test, done about a '
              'week before your period is due. A raised result means you '
              'ovulated that cycle. If your cycles are irregular, timing this '
              'test is harder and it may need repeating.'),
          _en('Some clinics watch ovulation with a series of vaginal scans '
              'across one cycle, called follicle tracking or a follicular '
              'study. The scans show a follicle growing and then collapsing '
              "once the egg is out. It's the most direct way to see ovulation "
              "happen, and it's common in India."),
          _en('Home ovulation kits and a rise in your resting temperature give '
              "useful clues, and they're worth bringing to the appointment. A "
              'biopsy of the womb lining was once used to check ovulation, but '
              "it isn't recommended for this any more."),
        ],
      ),
      PvReadSection(
        heading: _en('What do the hormone tests show?'),
        paragraphs: [
          _en('Hormone tests in the first few days of your cycle fill in the '
              'rest of the picture. These are usually FSH, LH and oestradiol, '
              'and often thyroid and prolactin too.'),
          _en('Thyroid and prolactin are '
              'checked to rule out common causes that are easy to treat and '
              'have nothing to do with fertility treatment.'),
          _en('AMH can be tested on any day of the cycle. It gives a rough '
              'idea of how many eggs you have left. It says nothing about how '
              "good they are. A low result doesn't mean pregnancy isn't "
              "possible. It's the number people misread most in fertility "
              'care.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is there a clear path?'),
        paragraphs: [
          _en('An ultrasound scan looks at the uterus and the ovaries, and '
              "counts the small follicles on each ovary. It's usually the "
              "first scan you'll have, and at worst it's a bit uncomfortable."),
          _en('Checking whether the tubes are open is a separate test. In '
              'India this is often an HSG, an X-ray with dye, or a HyCoSy, '
              'which uses ultrasound instead.'),
          _en('Both cause some cramping, and '
              "both take under half an hour. It's fine to ask for pain relief "
              'before, and to ask which of the two the clinic uses and why.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Most of this is blood tests and one scan'),
          body: _en('The list looks long on paper. In real life, a first round '
              'is usually two blood tests on different days of one cycle, one '
              'scan, and a semen sample. The tube test is booked separately, if '
              'you need it.'),
        ),
      ),
      // Gap plan 2026-09-26: the internal exam, gently, and how to get ready.
      PvReadSection(
        heading: _en('What happens in an internal exam?'),
        paragraphs: [
          _en('A fertility check often includes an internal exam. Each kind '
              'takes a few minutes. You lie back with your knees up and apart '
              'and a sheet over your lap, and you can ask the doctor to pause or '
              'stop at any time.'),
        ],
        bullets: [
          _en('A vaginal scan. A slim probe, covered and lubricated, goes a '
              'little way into the vagina to see the uterus and ovaries '
              'clearly. It feels like pressure more than pain.'),
          _en('A speculum exam. A smooth instrument gently holds the vagina '
              'open so the doctor can see your cervix, and take a swab or a Pap '
              'smear if one is due.'),
          _en('A hand exam. The doctor places two gloved fingers inside and '
              'presses gently on your tummy with the other hand, to feel the '
              'size and position of the uterus and ovaries.'),
        ],
        tip: PvReadTip(
          title: _en('Getting ready for an internal exam'),
          body: _en('Wear something easy to change out of, like a kurta with a '
              'separate bottom. For a day or two before a swab or Pap smear, '
              'skip sex and any vaginal creams or washes, because they can '
              'affect the result. If you worry about wind, eat light the night '
              'before and skip fizzy drinks that morning. Having your period '
              "doesn't usually stop a scan, and some are booked for exactly "
              "those days, so ask the clinic if you're unsure."),
        ),
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('If you feel nervous'),
          body: _en('Breathe out slowly as the probe or speculum goes in, '
              'because tight muscles make it more uncomfortable. You can ask '
              'for a woman doctor, or for a female chaperone to be in the room. '
              'If an exam has ever hurt or frightened you, say so first, and a '
              'good doctor will go slower.'),
        ),
      ),
      PvReadSection(
        heading: _en('What test does he need?'),
        paragraphs: [
          _en('For what it costs, a semen analysis tells you more than any '
              "other test in the whole check. It's also the one most often put "
              'off. A male factor is involved in around half of cases.'),
          _en('He needs to go two to five days without ejaculating before the '
              "test. It's usually repeated if the first result is abnormal, "
              'because results can change a lot from one sample to the next. '
              'Illness, fever and a hard few months can all show up.'),
          _en('A couple who have been getting tested for six months without '
              'this test are six months into answering only half the '
              'question.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to bring, and what not to expect'),
        paragraphs: [
          _en('Bring the dates of your last few periods, any old test results '
              'however old, a list of medicines and supplements, and the '
              'history of any past pregnancy or loss. Bring him too, if he '
              'can come.'),
          _en("Don't expect to leave with a diagnosis. A first appointment "
              'usually ends with a test plan and a date to come back. That '
              'means the appointment went as it should, not that things are '
              'being held up.'),
          _en('Do ask what happens if the tests come back normal. Unexplained '
              'infertility is a real and common result. Knowing ahead of time '
              "that there's a plan for it makes it far less frightening to "
              'hear.'),
        ],
      ),
      PvReadSection(
        heading: _en('How long does it take, and what does it cost?'),
        paragraphs: [
          _en('Several tests have to be done on certain days of your cycle, so '
              'a full check usually takes one to two cycles, not one week. '
              "That's normal and doesn't mean the clinic is slow. A "
              "progesterone test can't be done on whatever day you happen to "
              'be free.'),
          _en('In India, as checked in August 2026, a first consultation '
              'usually costs about ₹500 to ₹1,500 at a general hospital, and '
              'more at a fertility centre.'),
          _en('A basic hormone panel is usually '
              '₹1,500 to ₹4,000, AMH around ₹1,200 to ₹2,500, a semen analysis '
              'about ₹500 to ₹1,500, and a tube test roughly ₹2,500 to ₹6,000 '
              'depending on which one is used.'),
          _en("Prices vary a lot by city and by whether you're quoted a "
              'package. These were checked in August 2026. A price with no date '
              'on it is worse than no price, because you plan around it. Ask '
              'for the list in writing before you agree to a bundle.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't wait the full year if any of this applies"),
      body: _en("Book before twelve months if you're 36 or over, if your "
          "cycles are irregular or missing, if you've had two or more "
          "miscarriages, if you've had pelvic surgery or a pelvic infection, or "
          'if either of you has been told about a condition that affects '
          'fertility. If cancer treatment is planned, ask about saving your '
          'fertility straight away. That one is measured in days, not weeks.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en("My AMH is low. Does that mean IVF won't work?"),
        answer: _en('No. AMH gives a rough count of the eggs you have left. It '
            "doesn't measure their quality or whether a pregnancy is possible. "
            "It helps your doctor choose a treatment plan. It isn't a verdict, "
            'and it should never be given to you as one.'),
      ),
      PvReadFaq(
        question: _en('Is the tube test painful?'),
        answer: _en('Most people describe strong, period-like cramps for a few '
            "minutes. You're often told to take a painkiller an hour before, "
            "and it's completely fine to ask the clinic what they suggest."),
      ),
      PvReadFaq(
        question: _en("Everything came back normal and we're still not "
            'pregnant. What now?'),
        answer: _en("That's called unexplained infertility. It's common, and "
            "it isn't a dead end. There's a standard plan for it, and the talk "
            "moves on to what to try, not what's wrong."),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems: assessment and treatment); '
        'WHO laboratory manual for the examination of human semen, sixth '
        'edition; ESHRE guidance on unexplained infertility; ICMR guidance on '
        'ART practice in India. Sources checked August 2026.'),
    readNext: [
      'ttc_read_semen_analysis',
      'ttc_read_follicle_scans',
      'ttc_read_clinic_glossary',
    ],
  ),


  PvRead(
    id: 'ttc_read_ivf_injections',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en("The injections: what they're really like"),
    teaser: _en("What you'll be doing every evening for about two weeks, and "
        'how it feels.'),
    shortAnswer: _en('IVF injections use a very fine needle, given just under '
        'the skin of your tummy or thigh, once a day for about ten to fourteen '
        'days. Most people feel a quick sting, and the bloating in the second '
        'week bothers them more. The one injection with an exact time is the '
        'trigger.'),
    scaleSetter: _en('Most people fear the injections more than anything else '
        'in a cycle. Afterwards, most say they were the easiest part to get '
        'used to. The needles are very fine and go just under the skin, not '
        'into muscle.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The stimulation part of an IVF cycle is roughly ten to fourteen '
              'days of daily injections. You give them at home, usually in the '
              'evening at the same time each day.'),
          _en('They go into the fat just '
              'under the skin of your tummy or upper thigh, with a short, fine '
              "needle. Often it's a pre-filled pen that clicks to the right "
              'dose.'),
          _en('Your clinic will teach you or your partner how to do it, and a '
              'nurse will give or watch the first one. Nobody expects you to '
              "learn it from a leaflet. Ask if there's a video you can watch "
              'again at home.'),
        ],
      ),
      PvReadSection(
        heading: _en("What's in the injections?"),
        paragraphs: [
          _en('The main injection helps several follicles grow at once, '
              'instead of the single one your body would pick in a natural '
              "cycle. That's the whole point of stimulation."),
          _en('A second injection is usually added to stop your body releasing '
              'the eggs too early, because the aim is to collect them, not '
              'lose them. Some treatment plans use it from the start. Others '
              'add it partway through.'),
          _en("Then there's one trigger injection at an exact time, often late "
              'at night. It starts the last stage of the eggs getting ready. '
              'Egg collection is booked around it, usually about thirty-four '
              'to thirty-six hours later. This is the one injection where the '
              'exact time really matters.'),
          _en('After egg collection or transfer, progesterone support is '
              "common. It's often a pessary or gel, not an injection. When it "
              "is an injection, it's a different, thicker one that goes into "
              'the muscle.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('The trigger time is the one to set an alarm for'),
          body: _en('Everything else has some wiggle room. The trigger is timed '
              'to your egg collection slot, so the clinic will give you an exact '
              'time and mean it. Set two alarms, and tell whoever is with you.'),
        ),
      ),
      PvReadSection(
        heading: _en('What does it really feel like?'),
        paragraphs: [
          _en('Most people say the injection itself is a sting or a pinch for '
              'a second or two. Bruises and small red marks where you inject '
              'are common and mean nothing. Changing the spot each time '
              'helps.'),
          _en('A fuller feeling builds in the second week. As several '
              'follicles grow, your ovaries really do get bigger. Most people '
              'feel bloated and heavy low in the tummy, and notice clothes '
              'fitting differently. Bending and sudden moves can be '
              'uncomfortable.'),
          _en('Headaches, tiredness and moods that feel less steady than '
              'usual are all common. Being upset during a stimulation cycle '
              "isn't a weakness in you. And it isn't a sign that stress will "
              'affect the result.'),
        ],
      ),
      PvReadSection(
        heading: _en('What makes it easier?'),
        paragraphs: [
          _en("Store the medicines the way you're told. Some need to go in the "
              "fridge and some don't. Check before you travel with them."),
          _en('Pick a time you can stick to on a work day and on a Sunday. Put '
              'it in a shared calendar so someone else knows it too.'),
          _en('A few tricks make the sting smaller. Let the alcohol wipe dry '
              'fully before you inject. Hold ice on the spot for a minute '
              "first. And if your clinic says it's fine, take a fridge medicine "
              'out a little early, because a cold injection can sting more.'),
          _en("Loose clothes in the second week help more than you'd think. So "
              'does drinking as normal and not standing for long stretches.'),
          _en('Ask your clinic what to do about a missed or late dose before it '
              "happens. Every clinic has an answer, and it's much calmer to "
              'know it ahead of time than to be searching at eleven at '
              'night.'),
          _en('Gentle walking is usually fine. Hard exercise and anything with '
              'twisting is usually best avoided in the second week, because '
              'bigger ovaries can move. Ask your own clinic where the line is '
              'for you.'),
        ],
      ),
      PvReadSection(
        heading: _en('Can someone else give them?'),
        paragraphs: [
          _en('Your partner, a family member or a nurse can all give these. '
              "Many people find it easier when someone else does it. It's not "
              'a test of how independent you are.'),
          _en("If you're doing it alone, ask the clinic to watch you do one "
              "before you go home. It's a normal thing to ask, and it can turn "
              'two weeks of worry into two weeks of feeling sure.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the clinic straight away for these'),
      body: _en('Contact your clinic straight away if you have severe pain or '
          'swelling in your tummy, weight gain of two kilos or more in a day or '
          "two, vomiting that won't stop, trouble breathing, or you're passing "
          'much less urine than usual. These can be signs of ovarian '
          'hyperstimulation and need checking quickly. Also call if you have a '
          'fever, or redness and heat spreading out from where you injected. '
          'Never change a prescribed dose yourself.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do the injections hurt?'),
        answer: _en('Most people feel a quick sting. The needles are very fine '
            'and go just under the skin. Most say the bloating in the second '
            'week is more uncomfortable than the needles.'),
      ),
      PvReadFaq(
        question: _en("What if I'm an hour late?"),
        answer: _en('For the daily injections, an hour is usually not a '
            'problem. But ask your own clinic ahead of time so you know and '
            "don't have to guess. The trigger injection is the exception. Its "
            'time is set for a reason.'),
      ),
      PvReadFaq(
        question: _en('Can I keep working?'),
        answer: _en('Most people do through the stimulation phase. The catch '
            'is that monitoring scans mean several early-morning clinic '
            "visits. You'll need egg collection day off, because of the "
            'sedation.'),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems); ESHRE guideline on ovarian '
        'stimulation for IVF/ICSI; RCOG green-top guidance on ovarian '
        'hyperstimulation syndrome; ICMR National Guidelines for ART clinics in '
        'India. Sources checked August 2026.'),
    readNext: ['ttc_read_ivf_ohss'],
  ),

  // ⚠️ THE ONE SAFETY ARTICLE IN THIS DOOR, AND IT IS WRITTEN TO BE FOUND IN A
  // HURRY. Sections are short, the symptom list appears twice on purpose — once
  // as prose and once as the urgent callout — and the first paragraph says what
  // to do rather than what OHSS is. Someone opening this at midnight is not
  // reading it for education.
  PvRead(
    id: 'ttc_read_ivf_ohss',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('OHSS: when to call the clinic'),
    teaser: _en('The one complication of the injections worth knowing by name, '
        'what to watch for, and when not to wait until morning.'),
    shortAnswer: _en('OHSS is when your ovaries react too strongly to the '
        'fertility injections and fluid leaks into your tummy. Mild bloating '
        'after egg collection is common and settles by itself. Call your '
        'clinic now for severe tummy pain or swelling, fast weight gain, '
        'vomiting, breathlessness or passing much less urine.'),
    scaleSetter: _en('Contact your clinic now if you have severe pain or '
        "swelling in your tummy, are gaining weight fast, can't keep fluids "
        'down, are short of breath, or are passing much less urine than usual. '
        "Don't wait for your next appointment. Most cases are mild. The reason "
        'to know the name is so the severe ones are spotted early.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Ovarian hyperstimulation syndrome (OHSS) happens when your body '
              'reacts too strongly to the medicines used to grow several '
              'follicles at once. The ovaries get bigger, and fluid leaks out '
              'of the blood vessels into the tummy.'),
          _en('Mild OHSS is common and settles by itself. Moderate and severe '
              'OHSS are much less common and need a doctor, sometimes in '
              "hospital. Today's treatment plans and careful monitoring have "
              'made severe cases much rarer than they used to be.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does mild OHSS feel like?'),
        paragraphs: [
          _en('Bloating, a full, heavy tummy, mild nausea and some discomfort '
              'in the days after the trigger or egg collection are very common. '
              "Usually it's just a sign the cycle is working."),
          _en('Drink as much as you feel like, keep moving gently, and tell the '
              "clinic next time you're in touch. Mild OHSS usually eases within "
              'a week or so.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which signs mean you should call now?'),
        paragraphs: [
          _en('Severe pain in your tummy, or pain that keeps getting worse, or '
              "a belly that's swelling fast and you can see it."),
          _en('Gaining two kilos or more within a day or two. This is fluid, '
              'not fat.'),
          _en("Vomiting that won't stop, or not being able to keep fluids "
              'down.'),
          _en('Being short of breath, or finding it hard to lie flat.'),
          _en('Passing much less urine than usual, or none for several hours.'),
          _en('Pain or swelling in your calf, or chest pain. These are about '
              'the risk of a blood clot and need urgent care, not a message.'),
          _en("None of these means you're making a fuss. Clinics expect these "
              "calls, and they'd much rather get one that turns out to be "
              'nothing.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who is more likely to get it?'),
        paragraphs: [
          _en("The risk is usually higher if you're younger, have PCOS or a "
              'high antral follicle count (lots of small follicles on the '
              'scan), have a high AMH, have had OHSS before, or are responding '
              'strongly to the injections this cycle.'),
          _en('If any of these apply to you, say so before the cycle starts. '
              "It changes what your doctor chooses, and there's a lot they can "
              'change: a lower dose, a different trigger, freezing all the '
              'embryos instead of a transfer in the same cycle, and closer '
              'monitoring.'),
          _en('That last one matters. A fresh transfer in a cycle that has '
              "over-responded can make OHSS worse and last longer. That's why "
              'freezing everything and transferring later is a common, sensible '
              'choice, not a setback.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does it happen at all?'),
        paragraphs: [
          _en('The injections ask your ovaries to ripen several follicles in '
              'one cycle instead of the usual one. In some people the ovaries '
              'respond much more strongly than planned. The enlarged ovaries '
              'then release substances that make small blood vessels leak.'),
          _en('That leak is the whole condition. Fluid moves out of the blood '
              "and collects in the tummy. That's why the signs are swelling and "
              "weight that appears overnight. In severe cases there's also less "
              'urine and thicker blood, because the fluid has left the blood '
              'vessels where it belongs.'),
          _en("It's set off by the hormone that finishes getting the eggs "
              'ready, and by the pregnancy hormone if you get pregnant.'),
          _en("That's why symptoms usually start a few days after the trigger "
              "or egg collection, not in the first week of injections. It's also why "
              'a doctor may change which trigger is used for someone at higher '
              'risk.'),
        ],
      ),
      PvReadSection(
        heading: _en('How is it treated?'),
        paragraphs: [
          _en('Mild cases are looked after at home with fluids, rest and '
              'check-ups.'),
          _en('Moderate cases may mean more check-ups, blood tests and scans. '
              'Severe cases are treated in hospital. There, fluid can be given '
              "through a drip, extra fluid can be drained from the tummy if it's "
              'causing pressure, and medicine to prevent clots can be started.'),
        ],
      ),
      PvReadSection(
        heading: _en('How long does it last?'),
        paragraphs: [
          _en("It does go away. If you don't get pregnant that cycle, it usually "
              'settles within a week or two.'),
          _en('If you do get pregnant, it can last '
              'longer, because the pregnancy hormone keeps stimulating the '
              "ovaries. It helps to know this, so a longer stretch doesn't feel "
              'like something going wrong.'),
          _en("Being admitted to hospital doesn't mean the cycle has failed. "
              "Eggs already collected aren't affected. Embryos already frozen "
              "aren't affected. A transfer put off because of OHSS is put off, "
              'not cancelled. The embryos wait safely for a cycle when your body '
              "isn't dealing with this."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Contact your clinic straight away'),
      body: _en('Severe pain or swelling in your tummy, or pain that keeps '
          'getting worse. Weight gain of two kilos or more in a day or two. '
          "Vomiting you can't stop, or not being able to keep fluids down. "
          'Being short of breath or finding it hard to lie flat. Passing much '
          'less urine than usual. Pain in your calf or chest. Any of these '
          'means contact your clinic or emergency services now, not at your '
          "next appointment. If you can't reach the clinic, go to an emergency "
          "department and tell them you're in an IVF cycle."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is some bloating normal?'),
        answer: _en('Yes. Mild bloating and a full, heavy feeling after the '
            'trigger or egg collection is very common and usually settles '
            "within a week. It's bloating that gets worse fast, quick weight "
            'gain and being short of breath that mean you should call.'),
      ),
      PvReadFaq(
        question: _en('I have PCOS. Am I going to get OHSS?'),
        answer: _en("PCOS comes with a higher risk. It's also one of the things "
            'doctors plan around most carefully, with lower doses, a different '
            'trigger, or freezing all the embryos. Tell your clinic before the '
            'cycle starts.'),
      ),
      PvReadFaq(
        question: _en("Will this affect the pregnancy if I'm pregnant?"),
        answer: _en('OHSS in a cycle where you get pregnant tends to last '
            'longer, because the pregnancy hormone keeps the ovaries '
            "stimulated. It can be managed, and it's a question for the team "
            'looking after you, not for an article.'),
      ),
    ],
    evidence: _en('RCOG Green-top Guideline No. 5, Ovarian Hyperstimulation '
        'Syndrome, Management; ESHRE guideline on ovarian stimulation for '
        'IVF/ICSI; NICE CG156; ICMR National Guidelines for ART clinics in '
        'India. Sources checked August 2026.'),
    readNext: ['ttc_read_ivf_injections'],
  ),

  // ⚠️ WRITTEN TO CONVERT A CAROUSEL, AND THE BRIEF ALWAYS SAID ARTICLE. The
  // "what a package leaves out" content shipped as six swipeable cards because
  // the format list had nowhere better to put a step-shaped explainer. It is not
  // step-shaped: it is a list of costs somebody is about to be surprised by, and
  // a reader comparing two quotes needs to hold all of it at once rather than
  // remember card four while reading card five.
  //
  // ⚠️ AND IT NAMES RANGES, NEVER A PRICE. Clinic pricing in India varies by
  // city and by clinic, and a number in an app becomes the number she expects.
  // Every figure below is a band, sourced, and framed as "ask what yours
  // includes" rather than "this is what it costs".
  PvRead(
    id: 'ttc_read_ivf_package',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('What a package leaves out'),
    teaser: _en("The price you're quoted is rarely the final one. Here's what "
        'usually sits outside it, and the questions that let you compare '
        'quotes.'),
    shortAnswer: _en("An IVF package is each clinic's own bundle, so two quotes "
        'for the same price can cover very different things. Medicines, ICSI, '
        'freezing, storage, frozen transfers and extra scans are often charged '
        "separately. Ask each clinic what's inside, in writing, before you "
        'compare.'),
    scaleSetter: _en('An IVF "package" in India is usually the clinic\'s own '
        'bundle, not a standard one. So two quotes for the same amount can '
        'cover very different things. None of this means a clinic is being '
        'dishonest. It means the word package tells you less than it seems '
        "to. The only way to compare two of them is to ask each one what's "
        'inside.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("A package price is a bundle the clinic has put together. There's "
              "no national rule about what one has to include. So what's "
              'inside varies between clinics in the same city, and sometimes '
              'between doctors in the same clinic.'),
          _en('It helps to know this before you compare two prices. A lower '
              'quote without medicines and a higher quote with them can end up '
              'the same. The lower one can even end up costing more.'),
        ],
      ),
      PvReadSection(
        heading: _en('Are the medicines included?'),
        paragraphs: [
          _en('The stimulation medicines are often quoted separately, and '
              "they're not a small extra. In many Indian clinics they're a big "
              'part of what a cycle costs in total.'),
          _en("The amount isn't fixed either. The dose depends on your age, on "
              'how many eggs you have left, and on how your ovaries respond once '
              'the cycle starts.'),
          _en('So the same plan costs different people '
              'different amounts. A clinic can give you a likely range, but not '
              'a sure figure before the cycle happens.'),
          _en("Ask whether the quote includes medicines. If it doesn't, ask "
              'what a typical range is for someone with your test results. '
              'That one question explains most of the gap between two '
              'quotes.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which add-ons cost extra?'),
        paragraphs: [
          _en('ICSI, where one sperm is injected into each egg, is often an '
              "extra, not part of a standard cycle. It's standard practice when "
              "there's a sperm problem, and it isn't always needed "
              'otherwise.'),
          _en("Freezing has two costs, not one. There's the freezing itself, and "
              'then storage, which is usually charged every year for as long as '
              'the embryos are kept. A package that covers the first often '
              "doesn't cover the second."),
          _en('A frozen embryo transfer is usually a separate cycle with its '
              'own cost. If a package says "one cycle", ask whether that means '
              'one egg collection, one transfer, or both. The three are priced '
              'differently, and the word cycle is used for all of them.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about genetic testing and other extras?'),
        paragraphs: [
          _en('Genetic testing of embryos, assisted hatching, embryo glue and '
              'similar extras are almost always outside a basic package. For '
              'most people, several of them have little proof that they help.'),
          _en('So asking "is this suggested for me in particular, and what '
              'changes if I say no" is a fair question, not a rude one.'),
        ],
      ),
      PvReadSection(
        heading: _en('What do you pay before the cycle starts?'),
        paragraphs: [
          _en('Consultations, blood tests, scans, semen analysis and the '
              'infection tests both partners need are usually charged before a '
              'package begins. None of them is large on its own, but they add '
              'up.'),
          _en('Repeat scans during the injections are part of monitoring. They '
              'may or may not be in the bundle. Ask how many are included and '
              'what an extra one costs, because the number depends on how your '
              'ovaries respond, not on a plan made in advance.'),
        ],
      ),
      PvReadSection(
        heading: _en('What happens if the cycle is stopped'),
        paragraphs: [
          _en('Cycles are sometimes stopped before egg collection. Too few '
              "follicles may grow, the ovaries may over-respond so it isn't "
              "safe to carry on, or there may be a personal reason. It isn't "
              "rare, and it doesn't mean the care failed."),
          _en("What it costs you depends entirely on the clinic's policy. "
              'Some move your payment to the next try, some give part of it '
              'back, and some do neither. This is the question people most '
              "often wish they'd asked. It's easiest to ask before any money "
              'has changed hands.'),
        ],
      ),
      PvReadSection(
        heading: _en('Are packages for several cycles worth it?'),
        paragraphs: [
          _en('Packages for several cycles exist and can bring down the cost of '
              'each try.'),
          _en('Read what has to happen for the second and third try, '
              'and what happens to the money if you get pregnant on the first or '
              "stop partway. A discount that assumes you'll use all three is "
              'only a discount if you do.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which questions let you compare two quotes?'),
        paragraphs: [
          _en("Does this include medicines, and what's a likely range for "
              'someone with my results?'),
          _en('Does "one cycle" mean egg collection, transfer, or both?'),
          _en('What is charged separately? ICSI, freezing, storage, genetic '
              'testing, extra scans?'),
          _en('What happens to our money if the cycle is stopped before egg '
              'collection?'),
          _en('What total should I plan for, at the low end and the high end, '
              'if things go as normal?'),
          _en("Ask for the answers in writing. A clinic that's used to being "
              "asked will have this ready. One that won't put it in writing has "
              'told you something too.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Talk to your clinic before you pay'),
      body: _en("If you're being asked to decide quickly, to pay in cash "
          'without a written breakdown, or to add treatments nobody has '
          "explained, stop and ask for it in writing. If a clinic won't give you "
          "a quote with every item listed, that's a reason to get a second "
          'opinion. A second opinion before starting is normal and expected, and '
          "you don't owe anyone an apology for it."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is a cheaper package worse care?'),
        answer: _en('Not on its own. It usually means fewer things are included. '
            'Compare what each one contains before you compare what each one '
            "costs. That's the only way the two prices mean the same "
            'thing.'),
      ),
      PvReadFaq(
        question: _en('Should I take a package for several cycles?'),
        answer: _en('It depends on what has to happen for the later tries, and '
            "what happens to the money if you don't need them. Ask both, in "
            "writing. Then it's an ordinary decision, not a bet."),
      ),
      PvReadFaq(
        question: _en('Can anyone tell me exactly what my cycle will cost?'),
        answer: _en('No. A clinic that gives one sure figure before the cycle '
            'starts is guessing the medicine dose. A low-to-high range is the '
            'honest answer.'),
      ),
    ],
    evidence: _en('ICMR National Guidelines for Accreditation, Supervision and '
        'Regulation of ART Clinics in India; the ART (Regulation) Act 2021, '
        'which requires clinics to share their costs; NICE CG156 on fertility '
        'problems; ESHRE guidance on add-ons with limited evidence. Prices vary '
        'by city and clinic, so no figures are given here. Sources checked '
        'August 2026.'),
    readNext: ['ttc_read_ivf_costs'],
  ),

  // ⚠️ THE QUESTION PEOPLE ASK LAST AND WORRY ABOUT FIRST. It shipped as a
  // carousel and the brief always said article, which is right: the honest
  // answer has a before, a during and an after, and a reader who is frightened
  // wants to find the paragraph that applies to her rather than swipe until it
  // arrives.
  //
  // ⚠️ AND IT DOES NOT PROMISE PAINLESSNESS. "You will not feel a thing" is the
  // reassurance that costs trust the moment somebody feels something. Every
  // section here says what is usual, what is not, and who to tell.
  PvRead(
    id: 'ttc_read_ivf_retrieval',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Is egg retrieval painful?'),
    teaser: _en("What's done, what you're given for it, and how the days "
        'before and after really feel.'),
    shortAnswer: _en('Egg retrieval is done under sedation or a short '
        "anaesthetic, so you don't feel it while it happens. Afterwards most "
        'people have period-like cramps and bloating for a day or two. Pain '
        'that gets worse instead of better is the sign to call your clinic.'),
    scaleSetter: _en('Egg retrieval (egg collection) is a short procedure, '
        "usually fifteen to thirty minutes. It's done under sedation or "
        "anaesthesia, so you don't feel it while it happens. Most people say "
        'the day after brings period-like cramps and soreness, not real pain, '
        "and they're back to normal within a day or two. It's uncomfortable, "
        "not agonising, and you won't be awake for it."),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The procedure itself takes about fifteen to thirty minutes. A '
              'fine needle, guided by ultrasound, goes through the wall of the '
              'vagina to each ovary. The fluid in each mature follicle is drawn '
              'out and passed to the lab, where the eggs are found under a '
              'microscope.'),
          _en("There's no cut and no stitches. What feels sore afterwards is "
              'the ovaries, which have spent two weeks growing several '
              'follicles and are bigger than usual. There are also the tiny '
              'holes the needle made on its way in.'),
        ],
      ),
      PvReadSection(
        heading: _en('What will you be given for it?'),
        paragraphs: [
          _en('Most clinics in India use either conscious sedation or a short '
              "general anaesthetic. Under sedation you're very drowsy and "
              "usually remember nothing. Under a general anaesthetic you're "
              'asleep. Either way, nobody expects you to lie still and put up '
              'with it.'),
          _en('Ask which one your clinic uses and who gives it. You should '
              'expect an anaesthetist (the doctor who gives the sedation) to be '
              "there for the procedure. It's fair to check this rather than "
              'assume it.'),
          _en("You'll be asked not to eat or drink for some hours before, and "
              "you'll need someone to take you home. Plan for that instead of "
              'trying to manage alone. The reason is the sedation, not the '
              'procedure.'),
        ],
      ),
      PvReadSection(
        heading: _en('How will you feel that day?'),
        paragraphs: [
          _en('You wake up in a recovery room and are usually watched for an '
              'hour or two before going home. Feeling groggy, a bit sick from '
              'the sedation, and crampy like a heavy period is all normal.'),
          _en('Light spotting is common. It comes from where the needle went '
              'in, not from anything going wrong. Bloating is very common too, '
              'because the ovaries are bigger and some fluid moves around.'),
          _en('Most people take the day itself off and feel fine for desk '
              'work the next day. Plan the day off anyway. Being able to sleep '
              'it off is better than finding out the hard way that you needed '
              'to.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about the days after?'),
        paragraphs: [
          _en('Cramps and a full, heavy tummy usually settle over two to three '
              'days. Simple painkillers are usually enough, and your clinic '
              'will tell you which ones to use. Some are avoided around a '
              'transfer, so go by their list, not the one you usually use.'),
          _en("Your ovaries stay bigger for a little while. That's why clinics "
              'advise no hard exercise or heavy lifting for a few days. The '
              'advice is about your ovaries, not about you being fragile.'),
          _en('Pain that gets worse after the first day, instead of better, is '
              'what to watch for. Discomfort should be fading by day two or '
              "three. If it keeps building instead, it's worth a call, and the "
              'next section explains why.'),
        ],
      ),
      PvReadSection(
        heading: _en('What makes it hurt more, and what can a clinic change?'),
        paragraphs: [
          _en('More follicles means more needle holes and usually more '
              'soreness afterwards. Someone with lots of follicles is likely to '
              "feel it more than someone with only a few. That doesn't mean "
              'anything was done badly.'),
          _en('Ovaries in an awkward position, endometriosis, or scarring from '
              'past surgery can make the ovaries harder to reach and recovery '
              'achier. Tell your clinic beforehand if any of these apply to '
              'you, because it changes how they plan the procedure.'),
          _en('If a past egg collection hurt much more than you were told to '
              'expect, say so before the next one. How deep the sedation is '
              'and the pain relief afterwards can both be changed. A doctor who '
              'knows is a doctor who can change something.'),
        ],
      ),
      PvReadSection(
        heading: _en("Being scared of it isn't an overreaction"),
        paragraphs: [
          _en('Fear of this procedure is one of the most common reasons people '
              'put off starting a cycle. It rarely comes up at appointments, '
              'because nobody asks.'),
          _en("You're allowed to ask what happens minute by minute, to meet "
              "the anaesthetist, to ask what they'll give you if you wake up "
              "uncomfortable, and to bring someone with you as far as they're "
              'allowed to come. Clinics answer these questions all the time.'),
          _en('The people who find the day hardest are usually the ones who '
              "didn't know what to expect, not the ones who felt the most. "
              'Knowing how the day will go is most of the preparing you need '
              'to do.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Contact your clinic straight away'),
      body: _en('Severe pain in your tummy, or pain that gets worse instead of '
          'easing. Heavy bleeding from the vagina, more than light spotting. '
          'Fever. Fainting, or feeling like you might. Pain at the tip of your '
          "shoulder, being short of breath, or a belly that's swelling fast. "
          'Not being able to pass urine. Any of these means contact your clinic '
          'or emergency services now, not at your next appointment. Tell them '
          "you've just had an egg retrieval."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Will I be awake?'),
        answer: _en("Almost certainly not in any way you'll remember. Ask your "
            'clinic whether they use sedation or a general anaesthetic, and '
            'whether an anaesthetist will be there.'),
      ),
      PvReadFaq(
        question: _en("How long until I'm back to normal?"),
        answer: _en('Most people feel fine for everyday things within a day '
            'or two. Hard exercise usually waits a few more days, because the '
            'ovaries are still bigger than usual.'),
      ),
      PvReadFaq(
        question: _en('Does it hurt more if they collect more eggs?'),
        answer: _en('Usually yes, a little. More follicles means more needle '
            "holes and more soreness after. It doesn't mean anything is going "
            'wrong.'),
      ),
      PvReadFaq(
        question: _en('Can I go home alone afterwards?'),
        answer: _en('No. After sedation or anaesthesia you need someone to take '
            "you home, and most clinics won't let you leave otherwise."),
      ),
    ],
    evidence: _en('NICE CG156, Fertility problems: assessment and treatment; '
        'ESHRE guideline on ovarian stimulation for IVF/ICSI; RCOG patient '
        'information on egg collection; ICMR National Guidelines for ART '
        'clinics in India. Sources checked August 2026.'),
    readNext: ['ttc_read_ivf_ohss'],
  ),

  // ⚠️ IT SHIPPED AS A MYTH CARD AND THE BRIEF SAID ARTICLE, AND THE BRIEF WAS
  // RIGHT. A myth card needs a false belief to correct. There is no myth here:
  // "can I work through a cycle" is a genuine question with a genuine answer of
  // "usually yes, and here is what to plan for" — forcing it into two panels
  // meant inventing a wrong belief to knock down.
  //
  // ⚠️ AND IT DOES NOT TELL HER TO TAKE TIME OFF, OR NOT TO. Leave in India is
  // not evenly available and the article has no idea what her job is. It gives
  // the shape of the demands and lets her decide, which is the only honest
  // position for something that does not know whether she can afford a day.
  PvRead(
    id: 'ttc_read_ivf_working',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('Can I work through a cycle?'),
    teaser: _en('Most people do. What it asks of your calendar, which days '
        'are hard to move, and how much you need to tell anyone.'),
    shortAnswer: _en('Yes, most people work through most of an IVF cycle. The '
        'injections take minutes each evening, but monitoring means '
        'early-morning clinic visits every few days. Plan to take egg '
        'collection day off, and the day after if you can.'),
    scaleSetter: _en('Most people work through most of an IVF cycle. The load '
        "isn't even. The injection weeks are tiring but doable. Monitoring "
        'means early-morning clinic visits every few days. And there are one '
        "or two days, especially egg collection day, that really aren't "
        "workdays. It's better to plan around those than to try to push "
        'through them.'),
    author: _en('Dr Surbhi Sharma'),
    authorRole: _en('IVF gynaecologist, Bloom IVF'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('A cycle is roughly two to three weeks from the first injection '
              "to egg collection, and the load isn't spread evenly. Knowing "
              'which parts are heavy makes it much easier to manage.'),
          _en('Nothing about ordinary work (sitting, standing, screens, travel, '
              'thinking hard) affects whether a cycle works. You plan for the '
              'sake of your energy and your calendar, not the result.'),
        ],
      ),
      PvReadSection(
        heading: _en('What are the injection weeks like?'),
        paragraphs: [
          _en('Injections are daily, usually in the evening, and take a few '
              'minutes. Most people do them at home and go to work as usual.'),
          _en('They need to be kept in the fridge and taken at a steady time. '
              "So if your job has late nights you can't predict, make a small "
              'plan: a cool bag, or a fixed hour you can keep free.'),
          _en('Bloating, tiredness and moods that swing more than usual are '
              'common in the second week. People say it feels like a heavy '
              "week before a period, not like being ill. Clothes that don't "
              "press on your tummy help more than you'd expect."),
        ],
      ),
      PvReadSection(
        heading: _en('Why is monitoring the hard part to plan?'),
        paragraphs: [
          _en('Scans and blood tests happen every few days during the '
              "injections. They're almost always early in the morning, because "
              'the lab needs the results that day.'),
          _en('The visits are short. The problem is that the dates depend on '
              "how your ovaries respond, so they're only confirmed a day or two "
              'ahead, not booked in advance. The real clash is with a job that '
              "needs three weeks' notice for time off, not the appointments "
              'themselves.'),
          _en('This is the practical reason people end up telling one person at '
              "work something. It doesn't have to be the whole story. See "
              'below.'),
        ],
      ),
      PvReadSection(
        heading: _en("Which days aren't workdays?"),
        paragraphs: [
          _en("Egg collection day is a procedure under sedation. You can't eat "
              "before it, you need someone to take you home, and you shouldn't "
              'work, drive or sign anything afterwards. Take it as a full day '
              'off.'),
          _en('The day after is usually crampy and tiring. Many people manage '
              'desk work, and plenty would rather not. If you can keep one '
              'flexible day, keep this one.'),
          _en("Transfer is much lighter. It's a short procedure, usually "
              'without sedation, and most people get back to normal activity '
              "the same day. Bed rest afterwards isn't recommended, and it "
              "doesn't make pregnancy more likely."),
        ],
      ),
      PvReadSection(
        heading: _en('The two-week wait, at work'),
        paragraphs: [
          _en('For your body, this is the easiest stretch. For your feelings, '
              "it's the one people find hardest, and being at work is often "
              'better than being at home with it.'),
          _en('You may be on progesterone, which can make you tired and '
              "bloated. That's the medicine, not a sign of anything."),
          _en("If you can, decide ahead of time where you'll be when the result "
              'comes. Finding out at your desk is something lots of people get '
              "through. But it's better to choose the moment than to have it "
              'choose you.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about shift work, standing work and travel?'),
        paragraphs: [
          _en("A night shift doesn't stop a cycle working. What it makes harder "
              'is the timing of the injections, which should be at about the '
              'same hour each day. It also means the early-morning monitoring '
              'visits come at the end of your night, not the start of your '
              'morning.'),
          _en('Tell the clinic your shifts before the cycle starts, instead of '
              'working around them without saying. Injection timing has more '
              'room in it than people think. A nurse who knows you finish at '
              'seven can pick an hour that fits.'),
          _en('Physical work is fine during the injections. It needs a few days '
              'of care after egg collection, when the ovaries are still bigger '
              "than usual. That's the one time heavy lifting really matters, and "
              "it's short. If your job is all lifting, plan around this, not "
              'around the injections.'),
        ],
      ),
      PvReadSection(
        heading: _en('What if the dates move?'),
        paragraphs: [
          _en('Cycles get moved. Ovaries respond faster or slower than '
              'expected, so egg collection can shift by a couple of days either '
              'way. Sometimes a cycle is stopped completely before egg '
              'collection. None of that is rare, and none of it means anything '
              'has gone wrong.'),
          _en("That's why it's wise not to use up all your flexibility on the "
              "dates you're first given. If you can keep one loose day either "
              "side of the expected egg collection, keep it. That's worth more "
              'than one exact booked day.'),
          _en("If a cycle is stopped after you've already taken leave or moved "
              'work around, the disappointment usually hurts more than the '
              "planning. Decide ahead of time who at work, if anyone, you'd "
              "tell in that case, so you don't have to decide on the day."),
        ],
      ),
      PvReadSection(
        heading: _en('How much do you need to tell anyone?'),
        paragraphs: [
          _en("Nothing. Fertility treatment is medical information, and it's "
              "yours. In India you don't have to tell your employer. There's "
              'also no legal right to special fertility leave. What you get '
              'depends on where you work.'),
          _en('Some people tell one manager or one HR contact in general words, '
              'like "I\'m having a medical treatment for a few weeks that needs '
              'some early-morning appointments". This gets them flexibility '
              'without giving up their privacy. Others use their usual sick or '
              'casual leave and say nothing. Both are fine.'),
          _en('More and more Indian employers have a fertility or '
              "reproductive-health policy that they don't advertise. It's worth "
              "checking privately what yours offers before you assume there's "
              'nothing.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Stop and contact your clinic'),
      body: _en("Don't try to work through severe pain or swelling in your "
          "tummy, or pain that's getting worse, fast weight gain, vomiting you "
          "can't stop, being short of breath, or passing much less urine than "
          'usual. These are signs of ovarian hyperstimulation, and they need '
          'your clinic now, not at the end of the working day. Leaving is the '
          "right decision, and you don't need to explain it to anyone first."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do I have to tell my employer?'),
        answer: _en("No. It's medical information and it's yours. Some people "
            'tell one person in general words to make the early appointments '
            'easier. Plenty tell nobody.'),
      ),
      PvReadFaq(
        question: _en('How many days off should I plan for?'),
        answer: _en('One for sure: egg collection day. One more for the day '
            'after, if you can manage it. Everything else can usually be fitted '
            'around early-morning appointments.'),
      ),
      PvReadFaq(
        question: _en('Will a stressful job stop it working?'),
        answer: _en("Ordinary work isn't known to change whether a cycle works. "
            'Look after yourself because the weeks are tiring, not because '
            'your job puts the result at risk.'),
      ),
      PvReadFaq(
        question: _en('Can I travel for work during a cycle?'),
        answer: _en("During the injections it's hard, because the monitoring "
            "dates move with how you respond and can't be booked far ahead. "
            "Ask your clinic before you agree to anything you can't move."),
      ),
    ],
    evidence: _en('NICE CG156, Fertility problems: assessment and treatment; '
        'ESHRE guideline on ovarian stimulation for IVF/ICSI; Cochrane review '
        'on bed rest after embryo transfer, which found no benefit; ICMR '
        'National Guidelines for ART clinics in India. Leave from work in '
        'India varies by employer, and no right to leave is stated here. '
        'Sources checked August 2026.'),
    readNext: ['ttc_read_ivf_injections'],
  ),

];
