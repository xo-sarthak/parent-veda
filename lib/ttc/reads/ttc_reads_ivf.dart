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
    title: _en('When it is time to see someone'),
    teaser: _en('The guidance on how long to try, who should not wait it out, '
        'and what actually happens at a first appointment.'),

    scaleSetter: _en('Seeing a fertility doctor is not a decision that '
        'something is wrong. It is a set of tests and a conversation, and for '
        'a large share of couples it ends with a small correction rather than '
        'a treatment. Going early costs you very little; going late is the '
        'thing that is hard to undo.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_when_to_seek_help',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('There is a standard answer to this, and then there is a longer '
              'list of situations where the standard answer does not apply. '
              'The second list matters more, because it is the one people do '
              'not know about and therefore wait through.'),
        ],
      ),

      PvReadSection(
        heading: _en('The usual guideline'),
        paragraphs: [
          _en('Twelve months of regular, unprotected sex, if you are under 36. '
              'That is the threshold used by NICE and echoed by most bodies '
              'internationally, and "regular" means every two or three days '
              'across the cycle rather than timed attempts around a window.'),
          _en('At 36 or over, the advice is to be seen at presentation — that '
              'is, when you first raise it, rather than after a waiting '
              'period. The reason is not that fertility falls off a cliff at '
              '36; it is that investigation and treatment both take months, '
              'and a year spent waiting is a year that cannot be recovered.'),
          _en('It is worth being precise about what the twelve months is '
              'measuring. It is a marker for when investigating becomes '
              'worthwhile across a whole population — not a diagnosis, not a '
              'deadline, and not a statement about you.'),
        ],
      ),

      PvReadSection(
        heading: _en('Reasons not to wait at all'),
        paragraphs: [
          _en('The twelve-month rule assumes regular ovulation and no known '
              'reason for difficulty. If any of the following is true, that '
              'assumption is already broken and the clock does not apply — you '
              'can reasonably ask to be seen now.'),
        ],
        bullets: [
          _en('Cycles that are irregular, very long, or absent — including a '
              'known PCOS diagnosis. Nothing is gained by waiting a year to '
              'find out you are not ovulating predictably.'),
          _en('Periods that are very painful or very heavy, or pain during '
              'sex — the usual reasons endometriosis is suspected.'),
          _en('Any previous pelvic surgery, a ruptured appendix, or a past '
              'pelvic infection — all of which can affect the tubes.'),
          _en('A semen analysis that has already come back abnormal, or a '
              'known problem on his side. Half of all cases involve a male '
              'factor and it is the fastest thing in the whole workup to '
              'check.'),
          _en('Two or more miscarriages.'),
          _en('Cancer treatment planned for either of you — this is the one '
              'situation where the referral is genuinely urgent, because '
              'fertility preservation has to happen before treatment starts.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('The one that is most often missed'),
          body: _en('Irregular cycles. Women wait out the full year assuming '
              'the guidance applies to them, when the guidance was written for '
              'people whose cycles are predictable. If yours are not, the '
              'twelve months was never your number.'),
        ),
      ),

      PvReadSection(
        heading: _en('What a first appointment is actually like'),
        paragraphs: [
          _en('Almost nobody is treated at the first visit, which surprises '
              'people in both directions — some expect to start immediately, '
              'others are braced for something invasive.'),
          _en('What happens is a history, an examination, and a set of tests '
              'ordered for both of you. His semen analysis is usually the '
              'first thing requested, because it is quick, cheap and rules a '
              'great deal in or out. Yours will typically include blood tests '
              'timed to particular days of the cycle, and a scan.'),
          _en('You then come back with results, and the conversation about '
              'what to do next happens with something concrete in front of '
              'you. That second appointment is the real one.'),
        ],
        tip: PvReadTip(
          title: _en('What to take with you'),
          body: _en('Three months of cycle dates, any previous test results '
              'even if they look old or irrelevant, a list of everything '
              'either of you takes including supplements, and — if you can — '
              'him. A first fertility appointment attended by one person '
              'investigates one person, and half of this is his.'),
        ),
      ),

      PvReadSection(
        heading: _en('Who to see'),
        paragraphs: [
          _en('In India this usually starts with a gynaecologist rather than a '
              'fertility clinic, and that is the sensible order. A general '
              'gynaecologist runs the initial workup and manages ovulation '
              'induction routinely, which is where a meaningful share of '
              'couples stop.'),
          _en('A referral onward to a fertility specialist tends to come when '
              'tablets have been tried without success, when a tubal or male '
              'factor is found, or when age makes moving faster sensible.'),
          _en('Going straight to a large fertility chain is not wrong, but be '
              'aware of what it means: their pathway is built around the '
              'treatments they provide. It is reasonable to ask, at any '
              'clinic, what the least intensive option for your situation '
              'would be.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Going to a fertility clinic means ending up on IVF.'),
          fact: _en('Most couples who are investigated do not have IVF. The '
              'workup exists to find the specific reason, and the specific '
              'reason is frequently something addressed with a tablet, a minor '
              'procedure, or a change on his side. IVF is where the pathway '
              'goes when the earlier steps do not fit — not where it starts.'),
        ),
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('We have only been trying eight months but I am '
            'anxious. Is it too early?'),
        answer: _en('No. Nothing about being seen earlier is harmful, and the '
            'first appointment is a conversation and some tests. If waiting is '
            'costing you sleep, that is itself a reasonable thing to take to a '
            'doctor.'),
      ),
      PvReadFaq(
        question: _en('Does he really need to come?'),
        answer: _en('For the semen analysis, yes, and it is worth him being at '
            'the first appointment too. Male factor is involved in about half '
            'of cases and is the single quickest thing to check — investigating '
            'only one of you can waste months.'),
      ),
      PvReadFaq(
        question: _en('What if my reports come back normal?'),
        answer: _en('That happens in a meaningful minority of couples, and it '
            'has a name — unexplained infertility. It is frustrating to hear '
            'and it is not the same as being told nothing can be done; there '
            'is a standard pathway for it, and it does not mean the tests were '
            'pointless.'),
      ),
      PvReadFaq(
        question: _en('Will they judge us for waiting this long?'),
        answer: _en('They will not, and if they do, that is information about '
            'the clinic. Most couples arrive later than the guidelines suggest, '
            'for entirely ordinary reasons.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not wait for the twelve months'),
      body: _en('Book now, rather than at the end of a waiting period, if your '
          'cycles are irregular or absent, if periods are very painful or very '
          'heavy, if sex is painful, if you have had pelvic surgery or a '
          'pelvic infection, if there have been two or more miscarriages, or '
          'if you are 36 or over. And treat it as urgent — days, not weeks — '
          'if either of you is about to start cancer treatment, because '
          'fertility preservation has to happen first.'),
    ),

    evidence: _en('Referral thresholds follow the NICE fertility guidance: '
        'referral after 12 months of regular unprotected intercourse for women '
        'under 36, referral at presentation for women 36 or over or where '
        'there is a known or suspected cause or a predisposing history, and '
        'expedited referral where planned treatment may cause infertility. '
        'Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, one by one'),
        value: _en('What each one measures, when in the cycle it is taken, and '
            'what it costs in India.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Three months of dates to take with you'),
        value: _en('The single most useful thing you can bring to a first '
            'appointment.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Speak to a fertility specialist'),
        value: _en('A first conversation, on video, before you commit to a '
            'clinic.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_ivf_explained'],
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
    title: _en('What IUI and IVF actually involve'),
    teaser: _en('Step by step, in order, with the parts nobody warns you '
        'about — and an honest account of what each one asks of you.'),

    scaleSetter: _en('Neither of these is one event. IUI is a few scans and a '
        'two-minute procedure spread across one cycle. IVF is roughly a month '
        'of injections, monitoring and waiting, with one day under sedation in '
        'the middle. Knowing the shape of it in advance is most of what makes '
        'it manageable.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_ivf_walkthrough',

    sections: [
      PvReadSection(
        heading: _en('IUI, first — because it is much smaller'),
        paragraphs: [
          _en('Intrauterine insemination does one thing: it places prepared '
              'sperm directly into the uterus at the right moment, skipping '
              'the journey through the cervix. Everything else about the cycle '
              'is your own.'),
          _en('A cycle runs like this. Tablets or a low dose of injections at '
              'the start, to make sure a follicle develops. Two or three short '
              'scans to watch it grow. A trigger injection when it is ready, '
              'which sets ovulation to a known time. Then, a day or so later, '
              'the procedure itself — a soft catheter, about two minutes, no '
              'anaesthetic, and mild cramping at worst. You go home '
              'immediately.'),
          _en('IUI suits some situations and not others. It needs at least one '
              'open tube and reasonable sperm quality. It is often the first '
              'treatment offered for unexplained infertility, mild male '
              'factor, or where sex is difficult or infrequent — and it is '
              'usually tried for a small number of cycles before moving on, '
              'because almost all of the pregnancies it produces come in the '
              'first three.'),
        ],
      ),

      PvReadSection(
        heading: _en('IVF: the month, in order'),
        paragraphs: [
          _en('IVF replaces the whole first half of the process. Eggs are '
              'grown deliberately, collected, fertilised in a laboratory, and '
              'one embryo is put back.'),
        ],
        bullets: [
          _en('Stimulation — around ten to twelve days of daily injections '
              'you give yourself at home, to grow several follicles instead of '
              'one. Bloating and tenderness are normal by the end.'),
          _en('Monitoring — scans and blood tests every few days. This is '
              'the part people underestimate: it means repeated early-morning '
              'clinic visits, and it is the main reason IVF is difficult to '
              'combine with a rigid job.'),
          _en('Trigger — one injection at a precisely specified time, '
              'usually late at night, that matures the eggs. The timing is '
              'exact and it matters.'),
          _en('Retrieval — about twenty minutes under sedation, eggs '
              'collected with a fine needle guided by ultrasound. You are home '
              'the same day, usually sore and tired.'),
          _en('The laboratory — fertilisation happens overnight, either by '
              'mixing eggs and sperm or, in ICSI, by injecting a single sperm '
              'into each egg. Embryos are then grown for a few days, and you '
              'get a phone call each day about how many are continuing. Those '
              'calls are the hardest part of the process for many people.'),
          _en('Transfer — one embryo placed in the uterus with a fine '
              'catheter. It takes minutes, needs no anaesthetic, and feels '
              'like very little.'),
          _en('The wait — about two weeks, on progesterone support, until '
              'a blood test. Home pregnancy tests during this window are '
              'unreliable because of the trigger injection, which is why '
              'clinics ask you not to.'),
        ],
      ),

      PvReadSection(
        heading: _en('Fresh, frozen, and why so many transfers are frozen now'),
        paragraphs: [
          _en('An embryo can be transferred in the same cycle it was made — a '
              'fresh transfer — or frozen and transferred in a later, quieter '
              'cycle.'),
          _en('Freezing has become common because the stimulation that '
              'produces a good crop of eggs also leaves the uterine lining in '
              'a less receptive state, and because freezing lets the body come '
              'down before implantation is attempted. Being told your transfer '
              'will be frozen is normal practice rather than a setback, though '
              'it very often lands as one.'),
          _en('It also means a single stimulation cycle can produce several '
              'chances, which is the thing most worth understanding before you '
              'price any of it.'),
        ],
        tip: PvReadTip(
          title: _en('The question to ask about ICSI'),
          body: _en('ICSI — injecting a single sperm into each egg — is '
              'essential where sperm quality or count is the problem, and it '
              'is also applied routinely by many clinics regardless. It adds '
              'cost. It is entirely reasonable to ask: is ICSI being '
              'recommended because of our specific results, or as standard '
              'practice here?'),
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
        heading: _en('How long the whole thing takes'),
        paragraphs: [
          _en('From a first appointment to a result is usually two to three '
              'months, and most of that is waiting rather than treatment.'),
          _en('The tests come first and generally span one or two cycles, '
              'because several of them are tied to particular days. Then there '
              'is often a wait for a cycle to start at a time the clinic can '
              'take you.'),
          _en('The active part is short. Stimulation is about two weeks, '
              'retrieval is a morning, and a fresh transfer is three to five '
              'days later. Then the two-week wait, which is the same fortnight '
              'everyone finds hardest whatever route they took to it.'),
          _en('Where everything is frozen, the transfer moves to a later cycle '
              'and adds a few weeks. That is a common and deliberate choice '
              'rather than a delay, and it is worth hearing it that way when it '
              'is offered.'),
          _en('So a cycle is not a month out of your life in the sense people '
              'imagine. It is a fortnight of injections and several early '
              'mornings, inside a couple of months of appointments and '
              'waiting.'),
        ],
      ),

    ],

    faqs: [
      PvReadFaq(
        question: _en('Is egg retrieval painful?'),
        answer: _en('It is done under sedation, so not during. Afterwards, '
            'expect cramping and a heavy, bloated feeling for a day or two, '
            'similar to a bad period. Most people take the day off and are '
            'fine the next.'),
      ),
      PvReadFaq(
        question: _en('How many IUI cycles before moving to IVF?'),
        answer: _en('Commonly three, sometimes up to six depending on age and '
            'cause, because the large majority of IUI pregnancies happen in '
            'the first three cycles. It is a fair question to ask at the '
            'start.'),
      ),
      PvReadFaq(
        question: _en('Can I work through an IVF cycle?'),
        answer: _en('Most people do. The constraint is not the injections, it '
            'is the monitoring — several early-morning clinic visits at short '
            'notice over about two weeks, plus one day off for retrieval. Jobs '
            'with fixed hours and no flexibility are the difficult ones.'),
      ),
      PvReadFaq(
        question: _en('Does bed rest after transfer help?'),
        answer: _en('No. Lying still afterwards has been studied and does not '
            'improve outcomes; an embryo cannot fall out. Clinics that still '
            'advise it are being kind rather than evidence-led. Ordinary '
            'activity is fine.'),
      ),
      PvReadFaq(
        question: _en('Are IVF babies different in any way?'),
        answer: _en('No meaningful difference in health or development has '
            'been shown. There is a slightly higher rate of preterm birth and '
            'low birth weight, much of which is explained by multiple '
            'pregnancies — which is precisely why single embryo transfer has '
            'become standard practice.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('During a cycle, call the clinic'),
      body: _en('Not an emergency department, and not the internet — your own '
          'clinic, which will have a number for exactly this. Call if you have '
          'marked bloating or rapid weight gain over a day or two, severe '
          'abdominal pain, breathlessness, or if you are passing much less '
          'urine than usual. These are the signs of ovarian hyperstimulation, '
          'and reported early it is very manageable. Anything about your own '
          'dose, your own scan or your own embryos belongs with the team '
          'treating you.'),
    ),

    evidence: _en('Procedure sequence, the rationale for freeze-all transfers, '
        'single embryo transfer as standard practice, and ovarian '
        'hyperstimulation as the principal complication reflect standard '
        'assisted-reproduction practice as described by ESHRE and ASRM. '
        'Reviewed August 2026. Nothing here describes your own protocol, which '
        'is set by your clinic.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('What it actually costs in India'),
        value: _en('Real ranges, what a package leaves out, and the bills that '
            'arrive separately.'),
        surfaceId: 'ttc_read/ttc_read_ivf_costs',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Track a cycle you are already in'),
        value: _en('Stim, trigger, retrieval, transfer and the test date — in '
              'one place, and shared with him.'),
        surfaceId: 'ttc_treatment',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your reports together'),
        value: _en('Every result in one place, so a second opinion takes an '
            'evening rather than a week.'),
        surfaceId: 'ttc_records',
      ),
    ],

    readNext: ['ttc_read_ivf_costs'],
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
    scaleSetter: _en('A success rate is a fraction, and almost all of the '
        'argument is in what sits underneath the line rather than on top of '
        'it. Nothing here says a number is too low or high enough — that is '
        'not something an app can know about a clinic or about you. What it '
        'does is give you the same questions a doctor would ask if they were '
        'reading the figure with you.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('If you have started looking at clinics, you have seen success '
              'rates. They are usually on the website, often on the wall, and '
              'they are the first thing most people try to compare.'),
          _en('They are worth reading. They are just not comparable the way a '
              'price is comparable, because there is no single agreed way to '
              'calculate one. Two honest clinics can publish very different '
              'figures for identical work, and two clinics doing very '
              'different work can publish the same figure.'),
          _en('This is not about catching anyone out. Most of the difference '
              'comes from choices made openly — which patients, which cycles, '
              'which outcome counted — and once you know what those choices '
              'are, the number starts being useful rather than confusing.'),
        ],
      ),
      PvReadSection(
        heading: _en('Success of what, exactly'),
        paragraphs: [
          _en('The word success is doing at least four different jobs in '
              'fertility, and they get further apart the further down the list '
              'you go.'),
          _en('A positive pregnancy test is the earliest and the most '
              'flattering. A clinical pregnancy — a scan showing a pregnancy '
              'in the right place with a heartbeat — is a few weeks later and '
              'a smaller number. A live birth is the one almost everybody '
              'actually means, and it is the smallest of the three.'),
          _en('The fourth is different in kind: a cumulative rate, which counts '
              'everything that came from one egg collection, including frozen '
              'embryos transferred months later. It is a genuinely useful '
              'figure and it is much larger than a per-transfer one, because it '
              'is answering a bigger question.'),
          _en('So the first thing to establish is which of the four you are '
              'looking at. A clinic quoting a positive-test rate and a clinic '
              'quoting a live-birth rate are not disagreeing with each other. '
              'They are not talking about the same thing.'),
        ],
      ),
      PvReadSection(
        heading: _en('Per what — the denominator'),
        paragraphs: [
          _en('The other half of the fraction is which cycles were counted, and '
              'it moves the answer as much as the outcome does.'),
          _en('Per cycle started counts everybody who began treatment, '
              'including the cycles that were cancelled before an egg '
              'collection. It is the hardest denominator and the most honest '
              'about what a person walking in is signing up for.'),
          _en('Per egg collection drops the cancelled cycles. Per transfer '
              'drops them and also drops anybody who reached collection but '
              'had no embryo to transfer. Each step up removes some of the '
              'people for whom things went least well, so each step up '
              'produces a larger number from the same underlying results.'),
          _en('None of those three is wrong. They answer different questions, '
              'and "per cycle started" is the one closest to the question a '
              'person is really asking, which is what happens to somebody like '
              'me who walks through this door.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who was counted — and why this is the big one'),
        paragraphs: [
          _en('Age is the strongest single influence on IVF outcomes, and it is '
              'not close. A clinic whose patients are younger on average will '
              'report better figures than a clinic doing identical work with '
              'older patients, and neither clinic has done anything unusual.'),
          _en('The same is true of what else is going on. A centre that takes '
              'complicated cases — repeated failed cycles, severe male factor, '
              'low ovarian reserve, people other clinics have turned away — is '
              'being measured on a harder set of patients. Its number can be '
              'lower precisely because of the work it is willing to do.'),
          _en('This is why an overall clinic-wide figure is the least useful '
              'one on the page. It describes a mix of people, and you are not '
              'a mix. A figure broken down by age band is more informative, '
              'and a clinic that publishes the breakdown is telling you '
              'something about itself before you have asked anything.'),
          _en('It is also why the honest version of "what are my chances" is a '
              'conversation with a doctor who has seen your results, and not a '
              'number on a website. ParentVeda will not give you that figure '
              'and neither should any app — it depends on things only a '
              'clinician looking at your tests can weigh.'),
        ],
      ),
      PvReadSection(
        heading: _en('Small numbers wobble'),
        paragraphs: [
          _en('A rate calculated from a small number of cycles moves a lot on '
              'very little. In a small enough group, a couple of extra '
              'pregnancies one year and a couple fewer the next can swing the '
              'headline figure dramatically, with nothing about the clinic '
              'having changed at all.'),
          _en('So ask how many cycles the figure is based on and over what '
              'period. A rate from a large number of cycles across a defined '
              'stretch of time is a more stable thing than a rate from a '
              'handful, even when the handful looks better.'),
          _en('Be a little careful of a figure with no time period attached. '
              '"Our success rate" without a year is a claim that cannot be '
              'checked against anything, including itself next year.'),
        ],
      ),
      PvReadSection(
        heading: _en('What the number does not cover at all'),
        paragraphs: [
          _en('Some of what makes a clinic good never appears in a success '
              'rate. Whether the same doctor sees you each visit. Whether '
              'somebody picks up the phone at nine at night when you are '
              'frightened. Whether the counselling is real or a formality. '
              'Whether they told you honestly when a cycle was not worth '
              'starting.'),
          _en('There is also a harder one. A clinic can raise its published '
              'figure by being selective about whom it treats, and a clinic '
              'that takes on people with a difficult prognosis will look worse '
              'on paper for doing something generous. The number cannot tell '
              'those two apart. A conversation can.'),
          _en('And safety does not show up either. How often people end up in '
              'hospital with ovarian hyperstimulation, and how many embryos '
              'they transfer at a time, are both things a success rate can be '
              'improved by ignoring. They are fair questions to ask out loud.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to ask, in the room'),
        paragraphs: [
          _en('Is that a live-birth rate, a clinical-pregnancy rate, or a '
              'positive-test rate?'),
          _en('Is it per cycle started, per egg collection, or per transfer?'),
          _en('Is it cumulative — does it include frozen transfers from the '
              'same collection?'),
          _en('What is the figure for my age band, rather than overall?'),
          _en('How many cycles is that based on, and over what period?'),
          _en('How many embryos do you usually transfer at a time?'),
          _en('None of these is an aggressive question. A clinic that reports '
              'carefully will have the answers to hand and will be glad to be '
              'asked; a clinic that is vague about which number it is quoting '
              'has given you information too.'),
        ],
      ),
      PvReadSection(
        heading: _en('And then use it as one thing among several'),
        paragraphs: [
          _en('Once you know what a figure is counting, it belongs in the '
              'decision alongside everything else: how far you have to travel '
              'at six in the morning for a scan, what the whole thing will '
              'cost including the parts outside the package, whether you were '
              'listened to, and whether you trust the person explaining it.'),
          _en('A great many people choose a clinic they can get to, that they '
              'can afford, where somebody was kind to them and straight with '
              'them. That is not settling. Given how much of a rate is decided '
              'by who else walks through the door, it is a reasonable way to '
              'choose.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When a number is being used to hurry you'),
      body: _en('A success rate should help you decide, not push you. If a '
          'figure is being used to press you into starting immediately, into '
          'paying today, or into add-ons nobody has explained, that is a reason '
          'to slow down and get a second opinion. A second opinion before '
          'starting treatment is normal and expected. And if you are ever '
          'quoted a personal chance as a firm number — a specific percentage '
          'for you — ask what it is based on. An honest answer describes a '
          'range and the things that could change it.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is a higher rate always a better clinic?'),
        answer: _en('No. It can mean better care, and it can mean younger '
            'patients, simpler cases, a more flattering denominator, or a '
            'smaller sample. Until you know which of those it is, the two '
            'numbers on two websites are not measuring the same thing.'),
      ),
      PvReadFaq(
        question: _en('Can you tell me what my chances are?'),
        answer: _en('No, and it is a deliberate limit rather than a gap. A '
            'personal chance depends on things only a clinician who has seen '
            'your results can weigh, and a figure from an app would be a guess '
            'wearing a decimal point. Take your results to a specialist and ask '
            'them directly.'),
      ),
      PvReadFaq(
        question: _en('Should I pick the clinic with the best figure?'),
        answer: _en('Consider it as one of several things. Cost including what '
            'sits outside the package, how reachable it is for early-morning '
            'scans, how many embryos they transfer at a time, and whether you '
            'felt heard all belong in the same decision.'),
      ),
      PvReadFaq(
        question: _en('Why does nobody publish one comparable number?'),
        answer: _en('Because there is no single agreed definition of success or '
            'of which cycles to count, and because case-mix differs so much '
            'between clinics that a single ranked figure would mislead more '
            'than it explained. Registries in several countries publish '
            'breakdowns rather than league tables for exactly that reason.'),
      ),
    ],
    evidence: _en('ICMR National Guidelines for Accreditation, Supervision and '
        'Regulation of ART Clinics in India; the ART (Regulation) Act 2021 and '
        'its reporting requirements; HFEA guidance on how clinic success rates '
        'should be presented and compared; ESHRE and ICMART definitions of ART '
        'outcome terms; NICE CG156. No figures, benchmarks or clinic names '
        'appear in this article by design — it explains how to read a rate, and '
        'never what a rate should be. Reviewed August 2026.'),
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
    title: _en('What it actually costs in India'),
    teaser: _en('Real ranges as of 2026, what an advertised package leaves '
        'out, and the bills that arrive separately.'),

    scaleSetter: _en('The number a clinic advertises is almost never the '
        'number you pay. It is usually the procedure fee alone, and the '
        'medicines — which are a third of the bill — are billed separately. '
        'Knowing that one thing before you walk in is worth more than any '
        'other piece of financial advice here.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Fertility treatment in India is not covered by most health '
              'insurance, is paid out of pocket, and is priced very '
              'differently from one clinic to the next. The ranges below are '
              'what clinics across the country were publishing in 2026 — '
              'treat them as a sanity check on a quotation you are given, not '
              'as a price list.'),
        ],
      ),

      PvReadSection(
        heading: _en('IUI'),
        paragraphs: [
          _en('A natural-cycle IUI, with no stimulation, is commonly quoted '
              'around ₹5,000 to ₹10,000 for the procedure. Most IUI is '
              'medicated, and a medicated cycle typically lands between '
              '₹15,000 and ₹35,000 all in, with ovulation medicines adding '
              'roughly ₹5,000 to ₹10,000 on top of the procedure fee.'),
          _en('Because IUI is usually tried for around three cycles, the '
              'figure worth budgeting is the three, not the one.'),
        ],
      ),

      PvReadSection(
        heading: _en('IVF: the honest all-in range'),
        paragraphs: [
          _en('For one complete IVF cycle in 2026, a realistic all-in figure '
              'is roughly ₹1.5 to ₹2.5 lakh at an independent clinic, and '
              '₹2 to ₹3.5 lakh at a large fertility chain in a metro. In '
              'tier-2 cities the same cycle commonly runs ₹1 to ₹1.8 lakh.'),
          _en('Against that, the packages advertised at ₹90,000 to ₹1.2 lakh '
              'are the base procedure fee: egg retrieval, fertilisation in the '
              'laboratory, and one embryo transfer. That is a real number for '
              'a real part of the treatment. It is not the cost of the '
              'treatment.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('What sits outside the package, almost always'),
          body: _en('Stimulation medicines, at roughly ₹40,000 to ₹90,000 and '
              'about a third of the final bill. ICSI, adding roughly ₹15,000 '
              'to ₹45,000. Embryo freezing and its annual storage. A frozen '
              'transfer later, which is a separate cycle with its own fee. '
              'Monitoring scans beyond the number the package includes. And '
              'the initial tests for both of you, before any of it starts.'),
        ),
      ),

      PvReadSection(
        heading: _en('The questions that change the number'),
        paragraphs: [
          _en('Ask these before you pay anything, and ask for the answers in '
              'writing. A clinic that will not put a quotation on paper has '
              'told you something.'),
        ],
        bullets: [
          _en('What exactly is in the package, and what is billed separately?'),
          _en('How many monitoring scans are included, and what does each '
              'extra one cost?'),
          _en('Is ICSI included, and is it being recommended for our results '
              'or applied as standard?'),
          _en('What is the cost of freezing, of a year of storage, and of a '
              'frozen transfer later?'),
          _en('If the cycle is cancelled before retrieval, what is refunded?'),
          _en('Are the medicines bought through the clinic or from a chemist, '
              'and may we compare?'),
        ],
        tip: PvReadTip(
          title: _en('On medicines specifically'),
          body: _en('They are the largest single variable and often the '
              'largest single line. Prices differ meaningfully between the '
              'clinic pharmacy and an outside chemist, and between brands of '
              'the same drug. Asking whether you may source them yourself is a '
              'normal question, not a rude one.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Practical and grim; needed on the day it is needed.
        collapsible: true,
        summary: _en('Insurance, EMI schemes, refund packages and the '
            'multi-cycle offers — read before signing.'),
        heading: _en('Paying for it'),
        paragraphs: [
          _en('Most Indian health insurance excludes fertility treatment '
              'outright, though a small number of employer group policies have '
              'begun including limited cover. It is worth reading your own '
              'policy wording rather than assuming, and worth asking your HR '
              'directly.'),
          _en('Many clinics offer EMI arrangements, often through a third-'
              'party lender. Check the interest rate rather than the monthly '
              'figure — the monthly figure is designed to be reassuring.'),
          _en('Multi-cycle and refund packages are increasingly common: pay '
              'more up front for two or three cycles, with a partial refund if '
              'none works. These can be genuinely good value for someone '
              'likely to need more than one cycle, and poor value for someone '
              'likely to need one. Read the exclusions closely — eligibility '
              'criteria, what counts as a cycle, and what a refund actually '
              'covers are where the detail lives.'),
        ],
      ),

      PvReadSection(
        heading: _en('One thing worth saying out loud'),
        paragraphs: [
          _en('Deciding how much to spend on this is not a medical question '
              'and nobody at a clinic can answer it for you. It is worth the '
              'two of you agreeing a number, and a point at which you would '
              'stop, before the first cycle rather than during the third.'),
          _en('That conversation is uncomfortable and it protects you. The '
              'alternative is deciding it one cycle at a time, at the moment '
              'you are least able to.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Why do quotes differ so much between clinics?'),
        answer: _en('Laboratory quality and staffing are the genuine '
            'differences, and they are real. Beyond that, much of the spread '
            'is city, brand and what has been bundled into the headline '
            'figure. A higher price is not by itself evidence of a better '
            'laboratory.'),
      ),
      PvReadFaq(
        question: _en('Is treatment abroad cheaper?'),
        answer: _en('For most people in India, no — India is already among the '
            'lower-cost countries for IVF, which is why people travel here for '
            'it. Travel, accommodation and repeat visits usually erase any '
            'difference.'),
      ),
      PvReadFaq(
        question: _en('Does a government hospital do IVF?'),
        answer: _en('Some larger public and teaching hospitals run assisted '
            'reproduction units at substantially lower cost, with waiting '
            'lists and eligibility criteria. It is worth asking about locally; '
            'availability varies a great deal by state.'),
      ),
      PvReadFaq(
        question: _en('Should we budget for more than one cycle?'),
        answer: _en('It is the more realistic way to plan, and it is why '
            'freezing matters financially — a single stimulation that produces '
            'several embryos gives several chances at the much lower cost of a '
            'frozen transfer, rather than a full cycle each time.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Before you pay a deposit'),
      body: _en('Ask for the full quotation in writing, including what is '
          'excluded and what happens to your money if the cycle is cancelled. '
          'If a clinic will not provide that, or presses you to decide the '
          'same day, treat both as reasons to get a second opinion first. '
          'Nothing about this treatment is so urgent that it cannot wait for a '
          'written quotation — and your own doctor remains the person to ask '
          'what is medically necessary in your case.'),
    ),

    evidence: _en('Cost ranges reflect prices published by Indian fertility '
        'clinics and treatment aggregators during 2026, and are given as '
        'ranges because pricing varies widely by city, clinic and inclusions. '
        'Note the source honestly: almost all fertility pricing in India is '
        'published by the clinics that sell the treatment, so these figures '
        'are a sanity check against a quotation you are given — never a '
        'substitute for one in writing. Checked August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('The tests, with their own price ranges'),
        value: _en('What the workup costs before treatment even starts.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Get a second opinion before you commit'),
        value: _en('A fertility specialist who is not the clinic quoting you.'),
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
    title: _en('ICSI: when it is needed, and when it is routine'),
    teaser: _en('An extra step inside IVF that is sometimes essential and is '
        'sometimes charged for anyway.'),
    scaleSetter: _en('ICSI is not a different treatment from IVF. It is one '
        'step inside it done differently, and whether you need it depends '
        'almost entirely on his semen results. Knowing that is what lets you '
        'ask a useful question when it appears on a quote.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('In conventional IVF, eggs and prepared sperm are placed together '
              'in a dish and fertilisation is left to happen on its own. In '
              'ICSI, an embryologist injects a single selected sperm directly '
              'into each mature egg.'),
          _en('Everything before that point is identical — the same stimulation, '
              'the same monitoring, the same egg retrieval. Everything after is '
              'identical too. ICSI is one step in the laboratory, not a '
              'different journey.'),
        ],
      ),
      PvReadSection(
        heading: _en('When it is genuinely needed'),
        paragraphs: [
          _en('The clear indication is male factor: a low sperm count, poor '
              'movement, or a high proportion of abnormally shaped sperm. If '
              'there are too few sperm capable of reaching and penetrating an '
              'egg on their own, leaving it to chance in a dish is leaving it '
              'to a chance that is not really there.'),
          _en('It is also used where sperm were retrieved surgically, where a '
              'previous IVF cycle produced no fertilisation at all, and '
              'sometimes where eggs have been frozen and thawed, because the '
              'outer layer of a thawed egg can be harder to penetrate.'),
          _en('In those situations ICSI is not an upgrade. It is the thing that '
              'makes fertilisation possible.'),
        ],
      ),
      PvReadSection(
        heading: _en('When it is being added anyway'),
        paragraphs: [
          _en('ICSI is now used in a majority of IVF cycles worldwide, '
              'including many where semen results are entirely normal. The '
              'evidence does not support that.'),
          _en('Where male factor is not present, trials and large registry '
              'reviews have generally found no improvement in live birth rates '
              'from ICSI over conventional IVF. It is not dangerous, and it is '
              'not free — it is a laboratory procedure with a fee attached.'),
          _en('So the useful question when it appears on a quote is simply: '
              'what in our results makes ICSI the right choice for us? A clinic '
              'with a reason will give it to you in a sentence. That is a fair '
              'question to ask and it is not a confrontational one.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('This is a question, not an accusation'),
          body: _en('Plenty of clinics use ICSI routinely for reasons they can '
              'defend, including their own laboratory outcomes. Asking what the '
              'reason is gets you information; assuming there is not one gets '
              'you a difficult appointment.'),
        ),
      ),
      PvReadSection(
        heading: _en('What it does not do'),
        paragraphs: [
          _en('ICSI improves the chance that an egg becomes fertilised. It does '
              'not improve egg quality, it does not make an embryo more likely '
              'to implant, and it does not change anything about the pregnancy '
              'that follows.'),
          _en('It is worth being clear about that, because ICSI is sometimes '
              'described as though it makes IVF work better in general. It '
              'solves one specific step for one specific problem.'),
          _en('The same goes for the add-ons that often sit next to it on a '
              'quote — assisted hatching, embryo glue, various selection '
              'techniques with confident names. Most have thin or absent '
              'evidence for improving live births, several are charged '
              'separately, and none of them is the reason a cycle worked or '
              'did not.'),
          _en('A reasonable way through a long quote is to ask which items are '
              'part of the treatment and which are optional, and for each '
              'optional one, what it is expected to change in your case. It is '
              'a short conversation and it is the one most likely to save '
              'money.'),
        ],
      ),
      PvReadSection(
        heading: _en('The safety question people actually have'),
        paragraphs: [
          _en('Large follow-up studies of children conceived with ICSI have '
              'been broadly reassuring. There is a small increase in certain '
              'outcomes reported in some datasets, and the current '
              'understanding is that much of this is likely to relate to the '
              'underlying reason ICSI was needed — the male factor itself — '
              'rather than to the technique.'),
          _en('That is an honest summary of an area still being studied, and it '
              'is the kind of thing worth raising with the specialist who knows '
              'your results rather than reading a conclusion into.'),
          _en('Where a genetic cause for a low count has been identified, there '
              'is a separate and more specific point: some of those causes can '
              'be passed to a son. That is a conversation for a specialist and '
              'sometimes for a geneticist, and it is a reason to ask what '
              'caused a low count rather than only how to work around it.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask before you sign the consent'),
      body: _en('If ICSI appears on your plan or your quote, ask what in your '
          'results makes it the right choice, and what the fee is. Ask before '
          'signing rather than after. If you have had a cycle with no '
          'fertilisation at all, raise that specifically — it changes the '
          'answer.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is ICSI better than IVF?'),
        answer: _en('Not in general. Where male factor is present it is often '
            'necessary; where semen results are normal, the evidence has '
            'generally not found better live birth rates than conventional '
            'IVF.'),
      ),
      PvReadFaq(
        question: _en('Our clinic offers only ICSI. Is that a problem?'),
        answer: _en('It is a reason to ask why. Some laboratories standardise '
            'on it for reasons to do with their own outcomes and consistency. '
            'A clinic that can explain its policy is different from one that '
            'has never been asked.'),
      ),
      PvReadFaq(
        question: _en('Does ICSI let us choose the best sperm?'),
        answer: _en('An embryologist selects a sperm on appearance and '
            'movement, which is a limited assessment. It is selection, not '
            'genetic screening, and it should not be described as choosing a '
            'better baby.'),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems); ESHRE guidance on ICSI '
        'indications; Cochrane review of ICSI versus conventional IVF in '
        'non-male-factor infertility; long-term follow-up cohorts of children '
        'conceived by ICSI. Reviewed August 2026.'),
    readNext: ['ttc_read_ivf_explained'],
  ),

  PvRead(
    id: 'ttc_read_ivf_workup',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('What a fertility check actually involves'),
    teaser: _en('The tests, roughly when in the cycle they happen, and what '
        'each one is for — so the first appointment is not a surprise.'),
    scaleSetter: _en('A first fertility appointment is mostly a conversation '
        'and a plan for tests. Very little is decided on the day. Knowing what '
        'is likely to be ordered, and why, is what turns it from an '
        'interrogation into a conversation you can take part in.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('A fertility check is trying to answer three questions. Is an egg '
              'being released. Is there a clear path for it. Is there enough '
              'healthy sperm to meet it.'),
          _en('Almost every test that gets ordered belongs to one of those '
              'three, and a first appointment usually starts all three at '
              'once rather than working through them in order.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is an egg being released'),
        paragraphs: [
          _en('A progesterone blood test taken about a week before a period is '
              'due is the direct check. A raised result means ovulation '
              'happened in that cycle. With irregular cycles the timing of this '
              'test is harder and it may be repeated.'),
          _en('Hormones taken in the first few days of a cycle — usually FSH, '
              'LH, oestradiol, and often thyroid function and prolactin — build '
              'the picture around it. Thyroid and prolactin are there to rule '
              'out causes that are common, treatable and nothing to do with '
              'fertility treatment.'),
          _en('AMH may be taken at any point in the cycle. It estimates how '
              'many eggs are in reserve. It says nothing about their quality, '
              'and a low result does not mean pregnancy is not possible — this '
              'is the single most misread number in fertility care.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is there a clear path'),
        paragraphs: [
          _en('An ultrasound scan looks at the uterus and the ovaries, and '
              'counts the small follicles on each ovary. It is usually the '
              'first imaging done and it is uncomfortable at worst.'),
          _en('Checking whether the tubes are open is a separate procedure. In '
              'India this is commonly an HSG, an X-ray with dye, or a HyCoSy, '
              'which uses ultrasound instead. Both involve some cramping and '
              'both take under half an hour. It is reasonable to ask for pain '
              'relief beforehand and reasonable to ask which of the two the '
              'clinic uses and why.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Most of this is blood tests and one scan'),
          body: _en('The list looks long written down. In practice a first '
              'round is typically two blood draws timed to different points in '
              'one cycle, one scan, and a semen sample — with the tubal test '
              'arranged separately if it is needed.'),
        ),
      ),
      PvReadSection(
        heading: _en('And his half, which is half'),
        paragraphs: [
          _en('A semen analysis is the single most informative test in the '
              'whole work-up relative to what it costs, and it is the one most '
              'often delayed. Male factor is involved in around half of cases.'),
          _en('It requires two to five days without ejaculation beforehand and '
              'is usually repeated if the first result is abnormal, because '
              'results vary considerably between samples — illness, fever and a '
              'difficult few months all show up.'),
          _en('A couple who have been investigating for six months without '
              'this test having been done are six months into answering half '
              'the question.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to bring, and what to expect not to get'),
        paragraphs: [
          _en('Bring the dates of your last few periods, any previous test '
              'results however old, a list of medicines and supplements, and '
              'the history of any previous pregnancy or loss. Bring him, if he '
              'can come.'),
          _en('Expect not to leave with a diagnosis. A first appointment '
              'usually ends with a test plan and a follow-up date, and that is '
              'the appointment working correctly rather than a delay.'),
          _en('Do ask what happens if the tests come back normal, because '
              'unexplained infertility is a real and common outcome, and '
              'knowing in advance that it has a pathway makes it much less '
              'frightening to hear.'),
        ],
      ),
      PvReadSection(
        heading: _en('How long it takes, and roughly what it costs'),
        paragraphs: [
          _en('Because several tests are tied to particular days of a cycle, a '
              'full work-up usually spans one to two cycles rather than one '
              'week. That is normal and not a sign of a slow clinic — a '
              'progesterone test simply cannot be taken on the day you happen '
              'to be free.'),
          _en('In India, as checked in August 2026, a first consultation '
              'commonly runs about ₹500 to ₹1,500 in a general hospital and '
              'more at a dedicated fertility centre. A basic hormone panel is '
              'typically ₹1,500 to ₹4,000, AMH around ₹1,200 to ₹2,500, a '
              'semen analysis about ₹500 to ₹1,500, and a tubal test roughly '
              '₹2,500 to ₹6,000 depending on which is used.'),
          _en('Prices vary widely by city and by whether a package is quoted, '
              'and these were checked in August 2026 — a figure with no date on '
              'it is worse than no figure, because you plan around it. Ask for '
              'the list in writing before agreeing to a bundle.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not wait for the full year if any of this applies'),
      body: _en('Book earlier than twelve months if you are 36 or over, if your '
          'cycles are irregular or absent, if you have had two or more '
          'miscarriages, if you have had pelvic surgery or a pelvic infection, '
          'or if either of you has been told about a fertility-related '
          'condition. If cancer treatment is planned, raise fertility '
          'preservation immediately — that one is measured in days, not weeks.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('My AMH is low. Does that mean IVF will not work?'),
        answer: _en('No. AMH estimates how many eggs are in reserve, not their '
            'quality and not whether a pregnancy is possible. It helps a '
            'clinician choose a protocol. It is not a verdict and should never '
            'be given as one.'),
      ),
      PvReadFaq(
        question: _en('Is the tubal test painful?'),
        answer: _en('Most people describe strong period-like cramping for a few '
            'minutes. Taking a painkiller an hour beforehand is commonly '
            'advised, and it is entirely reasonable to ask the clinic what they '
            'recommend.'),
      ),
      PvReadFaq(
        question: _en('Everything came back normal and we still are not '
            'pregnant. What now?'),
        answer: _en('That is unexplained infertility, and it is common rather '
            'than a dead end. There is a standard pathway for it, and the '
            'conversation moves to what to try rather than what is wrong.'),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems: assessment and treatment); '
        'WHO laboratory manual for the examination of human semen, sixth '
        'edition; ESHRE guidance on unexplained infertility; ICMR guidance on '
        'ART practice in India. Reviewed August 2026.'),
    readNext: ['ttc_read_semen_analysis'],
  ),


  PvRead(
    id: 'ttc_read_ivf_injections',
    hue: 206,
    kicker: _en('IVF & IUI'),
    title: _en('The injections, honestly'),
    teaser: _en('What you will actually be doing every evening for about two '
        'weeks, and what it feels like.'),
    scaleSetter: _en('Most people are more frightened of the injections than '
        'of anything else in a cycle, and most people report afterwards that '
        'they were the easiest part to get used to. The needles are very fine '
        'and go just under the skin, not into muscle.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The stimulation part of an IVF cycle is roughly ten to fourteen '
              'days of daily injections, given at home, usually in the evening '
              'at a consistent time. They go into the fat just under the skin '
              'of the abdomen or the upper thigh, using a short fine needle — '
              'often in a pre-filled pen that clicks to a dose.'),
          _en('Your clinic will teach you or your partner how to do it, and the '
              'first one is done or watched by a nurse. Nobody is expected to '
              'work it out from a leaflet.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is in them, in plain terms'),
        paragraphs: [
          _en('The main injection encourages several follicles to grow at once, '
              'rather than the single one a natural cycle would select. That is '
              'the whole purpose of stimulation.'),
          _en('A second injection is usually added to stop the body releasing '
              'the eggs too early, because the point of the cycle is to collect '
              'them rather than lose them. Some protocols use it from the '
              'start, others add it partway through.'),
          _en('Then there is a single trigger injection at a precisely stated '
              'time — often late at night — which starts the final maturing of '
              'the eggs. Retrieval is scheduled around it, usually about '
              'thirty-four to thirty-six hours later, and this is the one '
              'injection where the exact time genuinely matters.'),
          _en('After retrieval or transfer, progesterone support is common. That '
              'is frequently a pessary or gel rather than an injection, and '
              'where it is an injection it is a different, thicker one given '
              'into the muscle.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('The trigger time is the one to set an alarm for'),
          body: _en('Everything else has some flexibility. The trigger is timed '
              'to a retrieval slot, so a clinic will give you a specific time '
              'and mean it. Set two alarms and tell whoever is with you.'),
        ),
      ),
      PvReadSection(
        heading: _en('What it actually feels like'),
        paragraphs: [
          _en('The injection itself is usually described as a sting or a pinch '
              'for a second or two. Bruising and small red marks at the site '
              'are common and mean nothing. Rotating where you inject helps.'),
          _en('The fuller feeling builds over the second week. As several '
              'follicles grow, the ovaries genuinely enlarge, and most people '
              'describe bloating, a heavy low abdomen and clothes fitting '
              'differently. Bending and sudden movement can be uncomfortable.'),
          _en('Headaches, tiredness and mood that feels less steady than usual '
              'are all commonly reported. Being upset during a stimulation '
              'cycle is not a character failure and it is not evidence that '
              'stress will affect the outcome.'),
        ],
      ),
      PvReadSection(
        heading: _en('Practical things that make it easier'),
        paragraphs: [
          _en('Keep the medicines as instructed — some need refrigeration and '
              'some do not — and check before travelling with them.'),
          _en('Pick a time you can hold to on a working day and a Sunday, and '
              'put it in a shared calendar so someone else knows it too.'),
          _en('Loose clothing for the second week helps more than it sounds '
              'like it should. So does drinking normally and not standing for '
              'long stretches.'),
          _en('Ask your clinic what to do about a missed or late dose before '
              'it happens. Every clinic has an answer and it is much calmer to '
              'have it in advance than to be searching at eleven at night.'),
          _en('Gentle walking is generally fine. High-impact exercise and '
              'anything with twisting is usually discouraged in the second '
              'week, because enlarged ovaries can move — ask your own clinic '
              'where the line is for you.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who else can do them'),
        paragraphs: [
          _en('A partner, a family member or a nurse can all give these, and '
              'many people find someone else doing it easier than doing it '
              'themselves. It is not a test of independence.'),
          _en('If you are managing alone, ask the clinic to watch you do one '
              'before you go home. It is a normal request and it is the '
              'difference between two weeks of confidence and two weeks of '
              'doubt.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the clinic straight away for these'),
      body: _en('Contact your clinic immediately if you have severe abdominal '
          'pain or swelling, weight gain of two kilos or more in a day or two, '
          'persistent vomiting, breathlessness, or you are passing much less '
          'urine than usual. These can be signs of ovarian hyperstimulation and '
          'need prompt assessment. Also call for a fever, or redness and heat '
          'spreading from an injection site. Never change a prescribed dose '
          'yourself.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do the injections hurt?'),
        answer: _en('Most people describe a brief sting. The needles are very '
            'fine and go just under the skin. The bloating in the second week '
            'is usually reported as more uncomfortable than the needles.'),
      ),
      PvReadFaq(
        question: _en('What if I am late by an hour?'),
        answer: _en('For the daily injections, an hour is usually not a '
            'problem, but ask your own clinic in advance so you know rather '
            'than guess. The trigger injection is the exception — that time is '
            'set for a reason.'),
      ),
      PvReadFaq(
        question: _en('Can I keep working?'),
        answer: _en('Most people do through the stimulation phase, with the '
            'caveat that monitoring scans mean several early morning clinic '
            'visits. Retrieval day needs to be taken off, because of the '
            'sedation.'),
      ),
    ],
    evidence: _en('NICE CG156 (fertility problems); ESHRE guideline on ovarian '
        'stimulation for IVF/ICSI; RCOG green-top guidance on ovarian '
        'hyperstimulation syndrome; ICMR National Guidelines for ART clinics in '
        'India. Reviewed August 2026.'),
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
    teaser: _en('The one complication of stimulation worth knowing by name, '
        'what to watch for, and when not to wait until morning.'),
    scaleSetter: _en('If you have severe abdominal pain or swelling, are gaining '
        'weight fast, cannot keep fluids down, are short of breath, or are '
        'passing much less urine than usual, contact your clinic now. Do not '
        'wait for the next appointment. Most cases are mild; the reason to know '
        'the name is so the severe ones are recognised early.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Ovarian hyperstimulation syndrome is an over-response to the '
              'medicines used to grow several follicles at once. The ovaries '
              'enlarge and fluid shifts out of the blood vessels into the '
              'abdomen.'),
          _en('Mild forms are common and settle on their own. Moderate and '
              'severe forms are much less common and need medical attention, '
              'sometimes in hospital. Modern protocols and careful monitoring '
              'have made the severe end considerably rarer than it once was.'),
        ],
      ),
      PvReadSection(
        heading: _en('Mild, and expected'),
        paragraphs: [
          _en('Bloating, a full heavy abdomen, mild nausea and some discomfort '
              'in the days after the trigger or retrieval are extremely common '
              'and are usually just the cycle working.'),
          _en('Drink normally to thirst, keep moving gently, and tell the '
              'clinic at your next contact. Mild OHSS typically eases within a '
              'week or so.'),
        ],
      ),
      PvReadSection(
        heading: _en('The signs that mean call now'),
        paragraphs: [
          _en('Severe or worsening abdominal pain, or a belly that is visibly '
              'and rapidly swelling.'),
          _en('Gaining two kilos or more within a day or two, which is fluid '
              'rather than weight.'),
          _en('Vomiting that will not stop, or being unable to keep fluids '
              'down.'),
          _en('Breathlessness, or difficulty lying flat.'),
          _en('Passing much less urine than usual, or none for several hours.'),
          _en('Calf pain or swelling, or chest pain — these are about clotting '
              'risk and need urgent attention rather than a message.'),
          _en('None of these is a reason to feel you are making a fuss. Clinics '
              'expect these calls and would far rather have one that turns out '
              'to be nothing.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who is more likely to get it'),
        paragraphs: [
          _en('A higher risk is generally associated with being younger, having '
              'PCOS or a high antral follicle count, a high AMH, a previous '
              'episode of OHSS, and a strong response to stimulation in the '
              'current cycle.'),
          _en('If any of those apply to you, say so before the cycle starts. It '
              'changes what a clinician chooses, and there is a lot they can '
              'change: a lower dose, a different trigger, freezing all embryos '
              'rather than transferring in the same cycle, and closer '
              'monitoring.'),
          _en('That last one matters. A fresh transfer into a cycle that has '
              'over-responded can make OHSS worse and last longer, which is '
              'why freezing everything and transferring later is a common and '
              'sensible decision rather than a setback.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why it happens at all'),
        paragraphs: [
          _en('The medicines used in stimulation ask the ovaries to mature '
              'several follicles in one cycle instead of the usual one. In some '
              'people the ovaries respond far more strongly than intended, and '
              'the enlarged ovaries release substances that make small blood '
              'vessels leak.'),
          _en('That leak is the whole condition. Fluid moves out of the '
              'circulation and collects in the abdomen, which is why the '
              'symptoms are swelling, weight that appears overnight, and — in '
              'severe cases — less urine and thicker blood, because the fluid '
              'has left the vessels where it belonged.'),
          _en('It is triggered by the hormone that finishes maturing the eggs, '
              'and by the pregnancy hormone if a pregnancy follows. That is why '
              'symptoms typically appear a few days after the trigger or after '
              'retrieval rather than during the first week of injections, and '
              'why a clinician may change which trigger is used for someone at '
              'higher risk.'),
        ],
      ),
      PvReadSection(
        heading: _en('What treatment looks like'),
        paragraphs: [
          _en('Mild cases are managed at home with fluids, rest and monitoring.'),
          _en('Moderate cases may involve more frequent review, blood tests and '
              'scans. Severe cases are managed in hospital, where fluid can be '
              'given by drip, excess fluid drained from the abdomen if it is '
              'causing pressure, and clot prevention started.'),
          _en('It resolves. In cycles where no pregnancy occurs it usually '
              'settles within a week or two; where a pregnancy has occurred it '
              'can last longer, because the pregnancy hormone keeps stimulating '
              'the ovaries. That is worth knowing so a longer course does not '
              'feel like something going wrong.'),
          _en('Being admitted is not a sign the cycle has failed. Eggs already '
              'retrieved are unaffected, embryos already frozen are unaffected, '
              'and a transfer postponed because of OHSS is postponed rather '
              'than cancelled — the embryos wait, safely, for a cycle when your '
              'body is not dealing with this.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Contact your clinic immediately'),
      body: _en('Severe or worsening abdominal pain or swelling. Weight gain of '
          'two kilos or more in a day or two. Vomiting you cannot stop, or '
          'being unable to keep fluids down. Breathlessness or difficulty lying '
          'flat. Passing much less urine than usual. Calf or chest pain. Any of '
          'these means contact your clinic or emergency services now — not at '
          'the next appointment. If you cannot reach the clinic, go to an '
          'emergency department and tell them you are in an IVF cycle.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is some bloating normal?'),
        answer: _en('Yes. Mild bloating and a full heavy feeling after the '
            'trigger or retrieval is very common and usually settles within a '
            'week. It is the rapid worsening, the fast weight gain and the '
            'breathlessness that mean call.'),
      ),
      PvReadFaq(
        question: _en('I have PCOS. Am I going to get OHSS?'),
        answer: _en('PCOS is associated with a higher risk, and it is also one '
            'of the things clinicians most actively plan around — lower doses, '
            'a different trigger, freezing all embryos. Tell your clinic before '
            'the cycle starts.'),
      ),
      PvReadFaq(
        question: _en('Will this affect the pregnancy if I am pregnant?'),
        answer: _en('OHSS in a pregnancy cycle tends to last longer because the '
            'pregnancy hormone keeps the ovaries stimulated. It is managed, and '
            'it is a question for the team looking after you rather than for an '
            'article.'),
      ),
    ],
    evidence: _en('RCOG Green-top Guideline No. 5, Ovarian Hyperstimulation '
        'Syndrome, Management; ESHRE guideline on ovarian stimulation for '
        'IVF/ICSI; NICE CG156; ICMR National Guidelines for ART clinics in '
        'India. Reviewed August 2026.'),
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
    teaser: _en('The quoted price is rarely the final one. Here is what usually '
        'sits outside it, and the questions that make a quote comparable.'),
    scaleSetter: _en('An IVF "package" in India is usually the clinic’s own '
        'bundle rather than a standard one, so two quotes for the same number '
        'can cover very different things. Nothing here means a clinic is being '
        'dishonest. It means the word package is doing less work than it '
        'sounds like it is, and the only way to compare two of them is to ask '
        'each one what is inside.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('A package price is a bundle a clinic has put together. There is '
              'no national definition of what one has to contain, so what is '
              'inside varies between clinics in the same city and sometimes '
              'between doctors in the same clinic.'),
          _en('That is worth knowing before you compare two numbers. A lower '
              'quote that excludes medicines and a higher quote that includes '
              'them can end at the same place, and the lower one can end '
              'higher.'),
        ],
      ),
      PvReadSection(
        heading: _en('Medicines are usually the biggest thing outside it'),
        paragraphs: [
          _en('Stimulation drugs are frequently quoted separately, and they are '
              'not a rounding error — in many Indian clinics they are a '
              'substantial share of what a cycle costs in total.'),
          _en('The amount is not fixed either. Dose depends on age, on ovarian '
              'reserve and on how the ovaries respond once the cycle has '
              'started, so the same protocol costs different people different '
              'amounts. A clinic can give you a likely band; it cannot give you '
              'a certain figure before the cycle runs.'),
          _en('Ask whether the quote is with or without medicines, and if '
              'without, what a typical range looks like for someone with your '
              'test results. That single question moves most of the difference '
              'between two quotes.'),
        ],
      ),
      PvReadSection(
        heading: _en('The add-ons that are priced per use'),
        paragraphs: [
          _en('ICSI, where a single sperm is injected into each egg, is often '
              'an extra rather than part of a standard cycle. It is standard '
              'practice where there is a male factor and is not automatically '
              'needed otherwise.'),
          _en('Freezing is two costs, not one: the freezing itself, and then '
              'storage, which is usually billed annually and continues for as '
              'long as the embryos are stored. A package that covers the first '
              'often does not cover the second.'),
          _en('A frozen embryo transfer is normally a separate cycle with its '
              'own cost. If a package quotes "one cycle", ask whether that '
              'means one egg retrieval, one transfer, or both — the three '
              'are priced differently and the word cycle is used for all of '
              'them.'),
          _en('Genetic testing of embryos, assisted hatching, embryo glue and '
              'similar extras are almost always outside a base package. Several '
              'of them have limited evidence of benefit for most people, so '
              '"is this recommended for me specifically, and what changes if I '
              'decline" is a fair question rather than a rude one.'),
        ],
      ),
      PvReadSection(
        heading: _en('The costs before the cycle even starts'),
        paragraphs: [
          _en('Consultations, blood tests, scans, semen analysis and the '
              'infection screening both partners need are typically billed '
              'before a package begins. They are not large individually and '
              'they add up.'),
          _en('Repeat scans during stimulation are part of monitoring and may '
              'or may not be inside the bundle. Ask how many are included and '
              'what an extra one costs, because the number depends on how your '
              'ovaries respond rather than on a plan made in advance.'),
        ],
      ),
      PvReadSection(
        heading: _en('What happens if the cycle is cancelled'),
        paragraphs: [
          _en('Cycles are sometimes stopped before retrieval — too few '
              'follicles developing, an over-response that makes continuing '
              'unsafe, or a personal reason. It is not rare and it is not a '
              'failure of care.'),
          _en('What it costs you depends entirely on the clinic’s policy. '
              'Some carry the payment to the next attempt, some refund a '
              'portion, some do neither. This is the single question people '
              'most often wish they had asked, and it is easiest to ask before '
              'anyone has money.'),
          _en('Multi-cycle packages exist and can genuinely reduce the cost per '
              'attempt. Read what triggers the second and third attempt, and '
              'what happens to the money if you conceive on the first or stop '
              'partway. A discount that assumes you will use all three is only '
              'a discount if you do.'),
        ],
      ),
      PvReadSection(
        heading: _en('Five questions that make two quotes comparable'),
        paragraphs: [
          _en('Does this include medicines, and what is a likely range for '
              'someone with my results?'),
          _en('Does "one cycle" mean retrieval, transfer, or both?'),
          _en('What is charged separately — ICSI, freezing, storage, '
              'genetic testing, extra scans?'),
          _en('What happens, financially, if the cycle is cancelled before '
              'retrieval?'),
          _en('What is the total I should plan for, at the low end and the high '
              'end, assuming things go normally?'),
          _en('Ask for the answers in writing. A clinic used to being asked '
              'will have this ready, and one that will not put it in writing '
              'has told you something too.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Talk to your clinic before you pay'),
      body: _en('If you are being asked to decide quickly, to pay in cash '
          'without a written breakdown, or to add treatments you have not had '
          'explained, stop and ask for it in writing. If a clinic will not give '
          'you an itemised quote, that is a reason to get a second opinion — '
          'and a second opinion before starting is normal, expected, and not '
          'something you owe anyone an apology for.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is a cheaper package worse care?'),
        answer: _en('Not on its own. It usually means fewer things are inside '
            'it. Compare what each one contains before comparing what each one '
            'costs — that is the only way the two numbers mean the same '
            'thing.'),
      ),
      PvReadFaq(
        question: _en('Should I take the multi-cycle package?'),
        answer: _en('It depends on what triggers the later attempts and what '
            'happens to the money if you do not need them. Ask both, in '
            'writing, and then it is an ordinary decision rather than a bet.'),
      ),
      PvReadFaq(
        question: _en('Can anyone tell me what my cycle will cost exactly?'),
        answer: _en('No, and a clinic that offers a single certain figure '
            'before the cycle runs is guessing at the medicine dose. A '
            'low-to-high band is the honest answer.'),
      ),
    ],
    evidence: _en('ICMR National Guidelines for Accreditation, Supervision and '
        'Regulation of ART Clinics in India; the ART (Regulation) Act 2021, '
        'which requires clinics to disclose costs; NICE CG156 on fertility '
        'problems; ESHRE add-ons guidance on interventions with limited '
        'evidence. Prices vary by city and clinic and are not stated here as '
        'figures. Reviewed August 2026.'),
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
    teaser: _en('What is actually done, what you are given for it, and what the '
        'days either side genuinely feel like.'),
    scaleSetter: _en('Egg retrieval is a short procedure, usually fifteen to '
        'thirty minutes, done under sedation or anaesthesia so that you do not '
        'feel it while it happens. Most people describe the day after as '
        'period-like cramping and soreness rather than pain, and are back to '
        'ordinary activity within a day or two. It is uncomfortable rather '
        'than agonising, and it is not something you go through awake.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('The retrieval itself takes about fifteen to thirty minutes. A '
              'fine needle is guided by ultrasound through the vaginal wall to '
              'each ovary, and the fluid in each mature follicle is drawn out '
              'and passed to the laboratory, where the eggs are found under a '
              'microscope.'),
          _en('There is no cut and no stitch. What is sore afterwards is the '
              'ovaries, which have spent two weeks growing several follicles '
              'and are larger than usual, and the small punctures the needle '
              'made on its way in.'),
        ],
      ),
      PvReadSection(
        heading: _en('What you are given, and what you will remember'),
        paragraphs: [
          _en('Most clinics in India use either conscious sedation or a short '
              'general anaesthetic. Under sedation you are deeply drowsy and '
              'usually remember nothing; under general anaesthetic you are '
              'asleep. Either way this is not a procedure people are expected '
              'to lie still through and endure.'),
          _en('Ask which your clinic uses and who administers it. An '
              'anaesthetist present for the procedure is the standard you '
              'should expect, and it is a fair thing to confirm rather than '
              'assume.'),
          _en('You will be asked not to eat or drink for some hours before, and '
              'you will need somebody to take you home. Plan for that rather '
              'than intending to manage it alone — the sedation, not the '
              'procedure, is the reason.'),
        ],
      ),
      PvReadSection(
        heading: _en('The rest of that day'),
        paragraphs: [
          _en('You wake in recovery and are usually watched for an hour or two '
              'before going home. Grogginess, some nausea from the sedation, '
              'and cramping that feels like a heavy period are the ordinary '
              'picture.'),
          _en('Light spotting is common and comes from the puncture sites '
              'rather than from anything going wrong. Bloating is very common, '
              'because the ovaries are enlarged and some fluid shifts.'),
          _en('Most people take the day itself off and are comfortable enough '
              'the next day for desk work. Plan the day off anyway. Being able '
              'to sleep it off is better than testing whether you needed to.'),
        ],
      ),
      PvReadSection(
        heading: _en('The days after'),
        paragraphs: [
          _en('Cramping and a full, heavy abdomen usually settle over two to '
              'three days. Simple painkillers are normally enough, and your '
              'clinic will tell you which ones to use — some are avoided '
              'around a transfer, so take their list rather than the usual '
              'one.'),
          _en('Your ovaries stay enlarged for a little while, which is why '
              'clinics advise against strenuous exercise and heavy lifting for '
              'a few days. That advice is about the ovaries, not about being '
              'fragile.'),
          _en('Pain that gets worse rather than better after the first day is '
              'the thing to pay attention to. Discomfort should be fading by '
              'day two or three; something that climbs instead is worth a call, '
              'and the next section says why.'),
        ],
      ),
      PvReadSection(
        heading: _en('What makes it hurt more, and what a clinic can change'),
        paragraphs: [
          _en('More follicles means more punctures and generally more soreness '
              'afterwards. Someone with a high count is likely to feel it more '
              'than someone with a handful, and that is not a sign anything was '
              'done badly.'),
          _en('Ovaries sitting awkwardly, endometriosis, or scarring from '
              'previous surgery can make access harder and the recovery '
              'achier. Tell your clinic beforehand if any of those apply — it '
              'changes how they plan the procedure.'),
          _en('If a previous retrieval was much more painful than you were led '
              'to expect, say so before the next one. Sedation depth and pain '
              'relief afterwards are both adjustable, and a clinician who knows '
              'is a clinician who can change something.'),
        ],
      ),
      PvReadSection(
        heading: _en('Being frightened of it is not an overreaction'),
        paragraphs: [
          _en('Fear of this procedure is one of the most common reasons people '
              'delay starting a cycle, and it is rarely discussed in the '
              'consultation because nobody asks.'),
          _en('You are allowed to ask what happens minute by minute, to meet '
              'the anaesthetist, to ask what is used if you wake uncomfortable, '
              'and to bring somebody with you as far as they are permitted to '
              'come. Clinics answer these questions constantly.'),
          _en('The people who find the day hardest are usually the ones who '
              'did not know what to expect, rather than the ones who felt the '
              'most. Knowing the shape of the day is most of the preparation '
              'there is.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Contact your clinic immediately'),
      body: _en('Severe or worsening abdominal pain rather than easing '
          'cramping. Heavy vaginal bleeding, more than light spotting. Fever. '
          'Fainting or feeling like you might. Shoulder-tip pain, '
          'breathlessness, or a belly that is swelling quickly. Being unable to '
          'pass urine. Any of these means contact your clinic or emergency '
          'services now, not at the next appointment — and say you have just '
          'had an egg retrieval.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Will I be awake?'),
        answer: _en('Almost certainly not in any way you will remember. Ask '
            'your clinic whether they use sedation or a general anaesthetic, '
            'and whether an anaesthetist is present.'),
      ),
      PvReadFaq(
        question: _en('How long until I am back to normal?'),
        answer: _en('Most people are comfortable for ordinary activity within '
            'a day or two. Strenuous exercise usually waits a few days more, '
            'because the ovaries are still enlarged.'),
      ),
      PvReadFaq(
        question: _en('Does it hurt more if they collect more eggs?'),
        answer: _en('Generally yes, a little — more follicles means more '
            'punctures and more soreness after. It is not a sign of anything '
            'going wrong.'),
      ),
      PvReadFaq(
        question: _en('Can I go home alone afterwards?'),
        answer: _en('No. Sedation and anaesthesia both mean you need somebody '
            'to take you home, and most clinics will not discharge you '
            'otherwise.'),
      ),
    ],
    evidence: _en('NICE CG156, Fertility problems: assessment and treatment; '
        'ESHRE guideline on ovarian stimulation for IVF/ICSI; RCOG patient '
        'information on egg collection; ICMR National Guidelines for ART '
        'clinics in India. Reviewed August 2026.'),
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
    teaser: _en('Most people do. What it actually asks of your calendar, which '
        'days are hard to move, and how much you have to tell anyone.'),
    scaleSetter: _en('Most people work through most of an IVF cycle. The '
        'demands are not evenly spread: the injection weeks are tiring but '
        'workable, monitoring means early-morning clinic visits every few days, '
        'and there are one or two days — the retrieval especially — that are '
        'genuinely not workdays. Planning around those beats trying to absorb '
        'them.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Fertility specialist, 16 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('A cycle is roughly two to three weeks from the first injection '
              'to the retrieval, and the load is not spread evenly across it. '
              'Knowing which parts are heavy is most of what makes it '
              'manageable.'),
          _en('Nothing about ordinary work — sitting, standing, screens, '
              'travel, thinking hard — affects whether a cycle succeeds. The '
              'reason to plan is your energy and your calendar, not the '
              'outcome.'),
        ],
      ),
      PvReadSection(
        heading: _en('The injection weeks'),
        paragraphs: [
          _en('Injections are daily, usually in the evening, and take a few '
              'minutes. Most people do them at home and go to work as normal.'),
          _en('They need refrigeration and reasonable timing, so a job with '
              'unpredictable late nights needs a small plan — a cool bag, or '
              'doing them at a fixed hour you can protect.'),
          _en('Bloating, tiredness and mood that moves more than usual are '
              'common in the second week. People describe it as a heavy '
              'premenstrual week rather than as illness. Clothes that do not '
              'press on your abdomen help more than you would expect.'),
        ],
      ),
      PvReadSection(
        heading: _en('Monitoring is the part that eats the calendar'),
        paragraphs: [
          _en('Scans and blood tests happen every few days during stimulation, '
              'and they are almost always early in the morning because the lab '
              'needs the results that day.'),
          _en('The visits themselves are short. The problem is that the dates '
              'are decided by how your ovaries respond, so they are confirmed a '
              'day or two ahead rather than booked in advance. A job that '
              'needs three weeks’ notice for an absence is the real conflict, '
              'not the appointments.'),
          _en('This is the practical reason people end up telling one person at '
              'work something. It does not have to be the whole thing — see '
              'below.'),
        ],
      ),
      PvReadSection(
        heading: _en('The days that are not workdays'),
        paragraphs: [
          _en('Retrieval day is a procedure under sedation. You cannot eat '
              'beforehand, you need somebody to take you home, and you should '
              'not work, drive or sign anything afterwards. Treat it as a full '
              'day off.'),
          _en('The day after is usually crampy and tired. Many people manage '
              'desk work; plenty would rather not. If you can hold one flexible '
              'day, hold this one.'),
          _en('Transfer is much lighter — a short procedure, usually without '
              'sedation, and most people go back to ordinary activity the same '
              'day. Bed rest afterwards is not recommended and does not improve '
              'the odds.'),
        ],
      ),
      PvReadSection(
        heading: _en('The two-week wait, at work'),
        paragraphs: [
          _en('Physically this is the easiest stretch. Emotionally it is the '
              'one people find hardest, and being at work is often better than '
              'being at home with it.'),
          _en('You may be on progesterone, which can make you tired and '
              'bloated. That is the medicine, not a sign of anything.'),
          _en('Decide in advance where you will be when the result comes, if '
              'you can. Finding out at your desk is survivable and lots of '
              'people do it; choosing it is better than it choosing you.'),
        ],
      ),
      PvReadSection(
        heading: _en('Shift work, standing work, and travel'),
        paragraphs: [
          _en('A night shift does not stop a cycle working. What it complicates '
              'is the timing of the injections, which want to be at roughly the '
              'same hour each day, and the early-morning monitoring visits that '
              'land at the end of a night rather than the start of a morning.'),
          _en('Tell the clinic what your shifts are before the cycle starts '
              'rather than working around it silently. Injection timing has '
              'more give in it than people assume, and a nurse who knows you '
              'finish at seven can pick an hour that fits.'),
          _en('Physical work is fine during stimulation and needs a few days of '
              'care after retrieval, when the ovaries are still enlarged. That '
              'is the one window where heavy lifting genuinely matters, and it '
              'is short. If your job is entirely lifting, this is the thing to '
              'plan around rather than the injections.'),
        ],
      ),
      PvReadSection(
        heading: _en('When the dates move'),
        paragraphs: [
          _en('Cycles get rescheduled. Ovaries respond faster or slower than '
              'expected, so the retrieval can shift by a couple of days in '
              'either direction, and a cycle is sometimes stopped altogether '
              'before retrieval. None of that is rare and none of it means '
              'anything has gone wrong.'),
          _en('It is the reason not to spend your entire flexibility on the '
              'dates you were first given. If you can hold one loose day either '
              'side of the expected retrieval, hold it — that is worth more '
              'than a precisely booked one.'),
          _en('If a cycle is cancelled after you have already taken leave or '
              'moved work around, the disappointment is usually larger than the '
              'logistics. It is worth deciding in advance who at work, if '
              'anyone, you would tell in that situation, so the decision is not '
              'made on the day.'),
        ],
      ),
      PvReadSection(
        heading: _en('How much you have to tell anyone'),
        paragraphs: [
          _en('Nothing. Fertility treatment is medical information and it is '
              'yours. There is no obligation to disclose it to an employer in '
              'India, and no legal entitlement to fertility-specific leave '
              'either — what you get depends on your organisation.'),
          _en('Some people tell one manager or one HR contact, in general terms '
              '— "I am having a medical treatment for a few weeks that needs '
              'some early-morning appointments" — because it buys flexibility '
              'without giving up privacy. Others use existing sick or casual '
              'leave and say nothing. Both are reasonable.'),
          _en('An increasing number of Indian employers have a fertility or '
              'reproductive-health policy that is not advertised. It is worth '
              'checking quietly what yours has before assuming it has '
              'nothing.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Stop and contact your clinic'),
      body: _en('Do not try to work through severe or worsening abdominal pain '
          'or swelling, rapid weight gain, vomiting you cannot stop, '
          'breathlessness, or passing much less urine than usual. Those are the '
          'signs of ovarian hyperstimulation and they need your clinic now, not '
          'at the end of the working day. Leaving is the correct decision and '
          'you do not need to explain it to anyone first.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do I have to tell my employer?'),
        answer: _en('No. It is medical information and it is yours. Some people '
            'tell one person in general terms to make the early appointments '
            'easier; plenty tell nobody.'),
      ),
      PvReadFaq(
        question: _en('How many days off should I plan for?'),
        answer: _en('One certainly — retrieval day. One more if you can hold '
            'it, for the day after. Everything else is usually workable around '
            'early-morning appointments.'),
      ),
      PvReadFaq(
        question: _en('Will a stressful job stop it working?'),
        answer: _en('Ordinary work is not known to change whether a cycle '
            'succeeds. Look after yourself because the weeks are tiring, not '
            'because your job is a risk to the outcome.'),
      ),
      PvReadFaq(
        question: _en('Can I travel for work during a cycle?'),
        answer: _en('During stimulation it is difficult, because the monitoring '
            'dates move with your response and cannot be booked far ahead. Ask '
            'your clinic before committing to anything unmovable.'),
      ),
    ],
    evidence: _en('NICE CG156, Fertility problems: assessment and treatment; '
        'ESHRE guideline on ovarian stimulation for IVF/ICSI; Cochrane review '
        'on bed rest following embryo transfer, which found no benefit; ICMR '
        'National Guidelines for ART clinics in India. Employment leave in '
        'India varies by organisation and no entitlement is stated here. '
        'Reviewed August 2026.'),
    readNext: ['ttc_read_ivf_injections'],
  ),

];
