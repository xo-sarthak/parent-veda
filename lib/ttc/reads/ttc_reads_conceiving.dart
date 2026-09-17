// =============================================================================
//  Fertile window — the reads for this door
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

final List<PvRead> kTtcReadsConceiving = [
  // ===========================================================================
  //  FERTILE WINDOW — the door's Excel Content cell, in two pieces
  // ===========================================================================
  //  Workbook: "How conception works, timing, cycle basics, common myths."
  //  Four topics, split as MECHANISM (this read) and TIMING (the next), because
  //  one piece covering all four runs past 3,000 words, and because the two
  //  halves are read at different moments — she looks up how a cycle works
  //  once, and looks up timing every single month.
  //
  //  ⚠️ THIS MATERIAL ALREADY PARTLY EXISTS, AND THAT IS THE POINT.
  //  `ttc_chapter_data.dart` carries "Why the window is six days and not one"
  //  and "Things that do not matter, despite what you have heard", and both are
  //  good. They are also CHAPTER-LOCKED: `ttc_chapter` routes to whichever
  //  chapter the engine has her in, so a woman in the waiting days who taps the
  //  fertile-window door and wants the myths gets a different chapter entirely.
  //  The content was never missing. It was unreachable from the door that
  //  promises it, which is the failure this repo has a gate for.
  //
  //  ⚠️ SO THERE ARE NOW TWO SOURCES FOR SOME OF THESE FACTS, AND THEY CAN
  //  SILENTLY DIVERGE. Edit the six-day window here and the chapter keeps
  //  saying the old thing, with nothing failing anywhere. The reconciliation to
  //  make later is for the chapter section to point AT these reads rather than
  //  restate them; it is not made now because the chapter reader is the most
  //  clinically reviewed surface in the stage and is not being rewritten in the
  //  middle of a content pass. Written down so it is a known debt, not a
  //  surprise for whoever finds the two copies.
  PvRead(
    id: 'ttc_read_how_conception_works',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('How conception actually works'),
    teaser: _en('The mechanism, in plain words — what a cycle is doing, what '
        'ovulation actually is, and why so much of this is invisible.'),

    scaleSetter: _en('Almost nothing about conception happens on a schedule '
        'you can see. Understanding the mechanism will not make it happen '
        'faster — but it turns a month of guessing into a month you can read, '
        'and that is most of what makes the waiting bearable.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    // ⚠️ COMMENTED OUT ON THIS ARTICLE ONLY. It now leads with a photograph,
    // and a 16:9 "coming soon" placeholder directly under a real header image
    // is two hero blocks stacked — the second one advertising that it is empty.
    //
    // The slot id is kept because the film is still owed: when
    // `ttc_vid_cycle_basics` exists, uncommenting this is the whole change.
    // Every other read in this file keeps its slot.
    // heroVideoSlot: 'ttc_vid_cycle_basics',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('A menstrual cycle is not one process. It is two, running back '
              'to back, and they behave completely differently — which is the '
              'single most useful thing to know about it, and the thing almost '
              'nobody is taught.'),
          _en('The first half is variable. The second half is not. Nearly '
              'everything confusing about cycle length comes from that one '
              'fact.'),
        ],
      ),

      PvReadSection(
        heading: _en('The first half: getting an egg ready'),
        paragraphs: [
          _en('From the first day of bleeding, a group of follicles in the '
              'ovaries begins to grow. Each one holds an immature egg. Over '
              'the next couple of weeks one pulls ahead of the rest and the '
              'others stop — quietly, with no symptoms at all.'),
          _en('This half is the follicular phase, and its length is genuinely '
              'variable. It usually runs somewhere between ten and fourteen '
              'days, but it can be shorter or longer, and it can differ in the '
              'same woman from one month to the next. Stress, illness, travel '
              'and broken sleep all move it.'),
          _en('That variability is why a cycle that is 28 days one month and '
              '33 the next is not a sign that something is wrong. What moved '
              'was almost certainly this half. The first half is the flexible '
              'one.'),
        ],
      ),

      PvReadSection(
        heading: _en('Ovulation: the part that lasts a day'),
        paragraphs: [
          _en('When the leading follicle is ready, a sharp rise in luteinising '
              'hormone — LH — triggers it to release its egg. That is '
              'ovulation. It takes minutes. Most women feel nothing, and the '
              'ones who do usually describe a dull one-sided ache rather than '
              'anything dramatic.'),
          _en('The egg then has about twenty-four hours. If it is not '
              'fertilised in that time it simply stops, and is reabsorbed. '
              'Nothing is wasted and nothing is lost — this happens several '
              'hundred times in a lifetime.'),
          _en('It is that LH rise which ovulation strips detect. Which is why '
              'a positive strip means ovulation is probably coming in the next '
              'day or so, not that it has already happened.'),
        ],
        tip: PvReadTip(
          title: _en('The one sign that arrives early enough to act on'),
          body: _en('Cervical mucus changes before ovulation, not after. In '
              'the days leading up to it, it turns clear, slippery and '
              'stretchy — the comparison everyone uses is raw egg white. That '
              'change is the body opening the door, and unlike a temperature '
              'rise it tells you something while there is still time to use '
              'it.'),
        ),
      ),

      PvReadSection(
        heading: _en('The second half: the fixed one'),
        paragraphs: [
          _en('The emptied follicle does not disappear. It converts into a '
              'small temporary gland, the corpus luteum, which produces '
              'progesterone — the hormone that holds the uterine lining in '
              'place and keeps it ready.'),
          _en('This half, the luteal phase, is far more consistent. It runs '
              'about fourteen days, and anything from ten to seventeen is '
              'normal. More usefully, it tends to be roughly the same length '
              'in the same woman every month.'),
          _en('If no pregnancy arrives, the corpus luteum winds down on its '
              'own schedule, progesterone falls, and the lining comes away. '
              'That is the period — the end of the sentence, not the '
              'beginning.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Why this matters for tracking'),
          body: _en('Because the second half is fixed and the first half is '
              'not, ovulation is better counted BACKWARDS from the next period '
              'than forwards from the last one. In a 33-day cycle it is far '
              'more likely around day 19 than around day 14 — which is exactly '
              'why the standard "day 14" advice misses so often for anyone '
              'whose cycle is not 28 days.'),
        ),
      ),

      PvReadSection(
        heading: _en('What has to line up'),
        paragraphs: [
          _en('For conception, several things have to happen in order — and '
              'each of them can quietly fail to happen in any given month.'),
        ],
        bullets: [
          _en('An egg has to be released, and be healthy.'),
          _en('Sperm have to be present in the tube at the right time, in '
              'sufficient number, and moving well.'),
          _en('One has to fertilise the egg — which happens in the fallopian '
              'tube, not in the uterus.'),
          _en('The fertilised egg has to keep dividing correctly for about a '
              'week while it travels down.'),
          _en('And it has to implant in a lining that is ready to receive it.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Reference, not the spine — it explains an arithmetic she
        // may want on a hard month and does not need on the day she is
        // learning what a follicle is.
        collapsible: true,
        summary: _en('Why a healthy couple does not conceive every month, and '
            'why that is arithmetic rather than a fault.'),
        heading: _en('Why it does not happen every month'),
        paragraphs: [
          _en('That chain has several links, and the commonest reason a month '
              'does not work is that a fertilised egg did not divide correctly '
              '— a chromosomal accident, at random, in a single cell. Nothing '
              'either of you did caused it and nothing could have prevented '
              'it.'),
          _en('The rate of those accidents rises with age, and that is most of '
              'what "age and fertility" actually means. It is not that the '
              'ovaries stop working. It is that a larger share of eggs carry '
              'an error which stops the process early — often before a period '
              'is even late.'),
          _en('This is why fertility is discussed across months rather than '
              'inside a single cycle. A month that does not work is the '
              'expected case rather than the exception, and it is not '
              'information about either of you.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('My cycle is not 28 days. Is that a problem?'),
        answer: _en('Not by itself. Cycles of roughly 21 to 35 days are '
            'considered normal, and what varies between them is almost always '
            'the first half. What matters more than the number is whether it '
            'is roughly the SAME number each month — a predictable 32-day '
            'cycle is far less concerning than one swinging between 26 and '
            '45.'),
      ),
      PvReadFaq(
        question: _en('Can I feel ovulation?'),
        answer: _en('Some women do — a dull ache on one side, lasting a few '
            'hours. It even has a name, mittelschmerz. Most women feel '
            'nothing, and feeling nothing says nothing at all about whether it '
            'happened.'),
      ),
      PvReadFaq(
        question: _en('Can you ovulate twice in one cycle?'),
        answer: _en('More than one egg can be released, but within the same '
            'short window — that is how non-identical twins happen. What does '
            'not occur is a second, separate ovulation later in the same '
            'cycle. Once progesterone rises, that door is shut for the month.'),
      ),
      PvReadFaq(
        question: _en('Does a period always mean I ovulated?'),
        answer: _en('Usually, but not always. A cycle can run without '
            'releasing an egg and still end in bleeding — the lining builds up '
            'and eventually sheds anyway. It is commoner when cycles are long '
            'or irregular, and it is one reason tracking across a few months '
            'tells you more than any single month can.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth raising with a doctor'),
      body: _en('If your cycles are shorter than 21 days or longer than 35, if '
          'they swing widely from month to month, if periods have stopped for '
          'three months or more, or if bleeding is heavy enough to interfere '
          'with your day. None of these is an emergency, and all of them are '
          'far easier to investigate with two or three months of dates written '
          'down — so start the record now and book when it suits you.'),
    ),

    evidence: _en('Cycle and phase physiology follows Endotext, "The Normal '
        'Menstrual Cycle and the Control of Ovulation" (NCBI Bookshelf), and '
        'StatPearls, "Physiology, Menstrual Cycle". Luteal-phase length range '
        'and the cervical-mucus sequence as described by the UCSF Center for '
        'Reproductive Health and Cleveland Clinic. Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Start a record of your own cycle'),
        value: _en('Three months of dates tells you where your ovulation '
            'actually sits, which no article can.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("See this cycle's window"),
        value: _en('Your own dates, turned into the days that count this '
            'month.'),
        surfaceId: 'ttc_window',
      ),
    ],

    // Two, so the Read-next rail shows two cards — the next question after
    // "how does it work" is "when", and after that "do I need a kit".
    readNext: ['ttc_read_timing_myths', 'ttc_read_ovulation_kits'],
  ),


  // ===========================================================================
  //  FERTILE WINDOW — timing, and the myths
  // ===========================================================================
  //  The other half of the Excel cell: "timing" and "common myths".
  //
  //  ⚠️ THE MYTHS ARE THE POINT OF THIS PIECE, and they are why it must not be
  //  written as a list of corrections. Every myth below was told to her by
  //  someone who loves her — a mother, a sister-in-law, a neighbour. A page
  //  that reads as a scoreboard of things her family got wrong is a page she
  //  will not send to anyone and may not finish. See the note on the myth
  //  component in `pv_reader_screen.dart`: the typography carries the
  //  judgment, and nothing scolds.
  PvRead(
    id: 'ttc_read_timing_myths',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Timing, and the advice worth putting down'),
    teaser: _en('When it actually matters, how often, and which of the things '
        'you have been told do nothing at all.'),

    scaleSetter: _en('The window is about six days wide, and the whole design '
        'of it is forgiving — being together every day or two across those '
        'days works as well as any amount of testing and counting. There is no '
        'single day to hit, and no way to miss it by an hour.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_timing_myths',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Almost all timing advice is built on one number that is wrong '
              'for most people: day fourteen. It assumes a 28-day cycle, and '
              'most cycles are not 28 days.'),
          _en('What is actually true is simpler and much less demanding than '
              'the counting suggests.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why the window is six days'),
        paragraphs: [
          _en('Sperm survive around five days inside the reproductive tract. '
              'An egg lives about a day after release. Put those together and '
              'you get a window of roughly six days, ending on the day of '
              'ovulation itself.'),
          _en('Note which end matters. The days BEFORE ovulation carry most of '
              'the chance, because sperm can wait and an egg cannot. The '
              'highest-probability stretch is the three days ending on the day '
              'of ovulation — which means that by the time a test tells you '
              'ovulation has happened, the most useful days have already '
              'passed.'),
          _en('This is the single most practical consequence in the whole '
              'piece: aim to be in the window before it closes, not to catch '
              'the moment.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('How often, and that is genuinely all'),
          body: _en('Every one to two days across the window. Not daily and '
              'timed. Not saved up. The guidance from the American Society for '
              'Reproductive Medicine is exactly this, and its plainness is the '
              'point — a couple having sex every other day does not need to '
              'track anything at all to be doing this correctly.'),
        ),
      ),

      PvReadSection(
        heading: _en('The things that do not matter'),
        paragraphs: [
          _en('These come up more than anything else, and each one costs '
              'somebody a small amount of dignity every month for no return.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Lie still with your legs up for twenty minutes '
              'afterwards.'),
          fact: _en('Sperm reach the cervix within minutes, and what is going '
              'to travel has already started. Getting up changes nothing. This '
              'one is worth putting down first because it is the one that most '
              'often turns a private moment into a procedure.'),
        ),
      ),

      PvReadSection(
        mythFact: PvMythFact(
          myth: _en('Some positions work better than others.'),
          fact: _en('There is no evidence that position affects whether '
              'conception happens. None of the studies that people cite for '
              'this measured pregnancy.'),
        ),
      ),

      PvReadSection(
        mythFact: PvMythFact(
          myth: _en('Save it up for a few days so the count is higher.'),
          fact: _en('Long gaps raise the number of sperm but lower how well '
              'they move, and movement is what matters here. Every one to two '
              'days is the sweet spot precisely because it balances the two. '
              'Abstaining for a week before the window is actively unhelpful.'),
        ),
      ),

      PvReadSection(
        mythFact: PvMythFact(
          myth: _en('If you are stressed, it will not happen.'),
          fact: _en('Severe, sustained stress can delay or stop ovulation, '
              'and that is real. Ordinary stress — work, a difficult month, '
              'worrying about this very question — has not been shown to '
              'prevent conception. This myth deserves particular impatience, '
              'because it hands a woman a reason to blame herself for '
              'something she cannot control.'),
        ),
      ),

      PvReadSection(
        heading: _en('The one that is actually true'),
        paragraphs: [
          _en('Most ordinary lubricants — and saliva — measurably reduce how '
              'well sperm move. This is the rare piece of bedroom advice that '
              'has real evidence behind it and is almost never mentioned.'),
          _en('If you use one, look for a product labelled fertility-friendly. '
              'They are widely available in India and cost a little more than '
              'the usual ones. Nothing else in this section is worth changing; '
              'this is.'),
        ],
        tip: PvReadTip(
          title: _en('If tracking has started to feel like a second job'),
          body: _en('You can stop. A couple having sex every two days through '
              'the middle of the cycle covers the window without a single '
              'strip, chart or app notification. Tracking is useful when '
              'cycles are irregular or when you want data for a doctor — it is '
              'not a requirement, and treating it as one is how this stage '
              'stops being bearable.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. A tool comparison she needs on the day she is standing in
        // a chemist, and does not need while reading about the window.
        collapsible: true,
        summary: _en('Strips, temperature and mucus — what each one actually '
            'answers, and which is worth your money.'),
        heading: _en('If you do want to track'),
        paragraphs: [
          _en('Three methods, and they answer different questions — which is '
              'the thing nobody explains when they sell you one.'),
        ],
        bullets: [
          _en('Ovulation strips detect the LH rise, so they warn you that '
              'ovulation is coming in a day or so. Useful, because they point '
              'forwards. A plain strip is as accurate as an expensive one.'),
          _en('Basal temperature rises after ovulation, so it confirms that it '
              'happened — after the window has closed. Useful across months to '
              'find your pattern, useless for this month.'),
          _en('Cervical mucus turns clear and stretchy in the days before. '
              'Free, points forwards, and needs nothing but attention.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('How long should we try before worrying?'),
        answer: _en('The usual guidance is a year under 35, and six months at '
            '35 or over. That assumes regular, predictable cycles — if yours '
            'are irregular, or you already know about PCOS, endometriosis or a '
            'previous pelvic surgery, the clock does not apply and it is '
            'reasonable to ask sooner.'),
      ),
      PvReadFaq(
        question: _en('We can only manage it once or twice a month. Does that '
            'ruin our chances?'),
        answer: _en('It lowers the odds of landing inside the window by '
            'chance, which is exactly the situation where tracking earns its '
            'keep — knowing roughly when the window is lets a small number of '
            'occasions be placed well. Long-distance couples do this '
            'successfully all the time.'),
      ),
      PvReadFaq(
        question: _en('Is there a best time of day?'),
        answer: _en('No. Sperm counts vary slightly through the day and the '
            'difference is far too small to plan around. Anyone selling you a '
            'time of day is selling you something.'),
      ),
      PvReadFaq(
        question: _en('Does it matter if it happens on the day of ovulation '
            'itself?'),
        answer: _en('It is a good day, but not the best one — the two days '
            'before it carry more, because sperm can already be waiting. This '
            'is why chasing a positive strip on the day tends to arrive '
            'slightly late.'),
      ),
      PvReadFaq(
        question: _en('Can an app tell me when I ovulate?'),
        answer: _en('It can estimate, and an estimate from your own logged '
            'dates is genuinely useful. What it cannot do is know — no app can '
            'see an ovary. Treat the estimate as a window to be present '
            'across, never as a date to hit.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When timing is not the problem'),
      body: _en('Book if you have been trying for a year — six months if you '
          'are 35 or over — with cycles you can predict. Sooner, without '
          'waiting out the clock, if your cycles are irregular or absent, if '
          'sex is painful, if periods are very heavy, or if either of you has '
          'had pelvic surgery, chemotherapy or a known fertility condition. '
          'Timing advice cannot fix any of those and no amount of better '
          'timing will.'),
    ),

    evidence: _en('The fertile window, the three-day highest-probability '
        'interval, the every-one-to-two-days recommendation and the caution on '
        'commercial lubricants all follow "Optimizing natural fertility: a '
        'committee opinion" from the Practice Committees of the American '
        'Society for Reproductive Medicine and the Society for Reproductive '
        'Endocrinology and Infertility (updated 2022). Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("See this cycle's window"),
        value: _en('Your own dates, turned into the days that count this '
            'month.'),
        surfaceId: 'ttc_window',
      ),
      PvReadNextStep(
        kind: PvNextKind.product,
        title: _en('Strips, and what else is worth having'),
        value: _en('The two things worth keeping in the house, and what to '
            'skip.'),
        surfaceId: 'ttc_products',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Ask a fertility specialist'),
        value: _en('If the timing is right and it still is not happening, that '
            'is a different conversation.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_how_conception_works'],
  ),


  // ===========================================================================
  //  Ovulation kits
  // ---------------------------------------------------------------------------
  //  WRITTEN BECAUSE THE FOCUS PAGE HAD A TILE AND NO ARTICLE. That tile opened
  //  a lighter second reader built for four paragraphs, which meant the same
  //  "Article" chip opened two different-looking screens depending on which one
  //  you tapped. Deleting the second reader is only honest if the content comes
  //  up to the format rather than the format coming down to the content - so
  //  this is a real read, at the shape assertShape requires.
  PvRead(
    id: 'ttc_read_ovulation_kits',
    hue: 344,
    kicker: _en('Fertile window'),
    title: _en('Ovulation kits: do they help?'),
    teaser: _en('Sometimes, and for a narrower set of people than the box '
        'suggests. Here is when a kit earns its money, and when it only tells '
        'you what your body already told you.'),
    scaleSetter: _en('A kit is a convenience, not a requirement. Nobody needs '
        'one to conceive, and a couple being together every other day through '
        'the week before ovulation is already doing the thing a kit exists to '
        'help them time. If the cost or the daily testing is a burden, putting '
        'it down is a reasonable decision, not a corner cut.'),
    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist, 14 years, reviewed August 2026'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('An ovulation predictor kit tests your urine for luteinising '
              'hormone, usually shortened to LH. LH sits low for most of the '
              'cycle and then rises sharply about a day to a day and a half '
              'before an egg is released.'),
          _en('That surge is what the second line is reporting. It is a '
              'genuinely useful signal, and it is also narrower than most '
              'packaging implies.'),
        ],
      ),
      PvReadSection(
        heading: _en('What a positive actually tells you'),
        paragraphs: [
          _en('A positive means the surge has started, so ovulation is likely '
              'in the next twelve to thirty-six hours. The two days beginning '
              'with that positive are the highest-chance days of the month.'),
          _en('What it does not tell you is that an egg was definitely '
              'released. LH can rise without ovulation following. It happens '
              'occasionally in cycles that otherwise look normal, and more '
              'often in some conditions. A kit reports a hormone, not an '
              'outcome.'),
          _en('It also arrives late in the window. The six fertile days end on '
              'the day of ovulation, so a kit that turns positive is telling '
              'you about the last two of them. Useful, but not the whole '
              'picture.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Cheap strips test the same hormone'),
          body: _en('The expensive digital readers and the plain paper strips '
              'both measure LH. What you pay extra for is the reading of the '
              'line, not the chemistry behind it. If squinting at a faint line '
              'is stressful, a digital is worth it for that reason alone, but '
              'it is not a better test.'),
        ),
      ),
      PvReadSection(
        heading: _en('When a kit is genuinely worth it'),
        paragraphs: [
          _en('If your cycles vary by more than a few days, counting forward '
              'from your last period does not place the window reliably, and a '
              'kit gives you something your calendar cannot.'),
          _en('It also helps if you find the body signs hard to read, or if '
              'you and your partner are apart for stretches and need to plan '
              'rather than simply keep a rhythm.'),
          _en('If your cycles are regular and you can already see the fertile '
              'mucus change, clear and wet and stretchy a few days before, a '
              'kit will mostly confirm what you had already noticed.'),
        ],
      ),
      PvReadSection(
        heading: _en('When kits mislead'),
        paragraphs: [
          _en('Polycystic ovary syndrome is the important case. PCOS can hold '
              'LH high for much of the cycle, so kits read positive again and '
              'again without a surge having happened. If you have PCOS and '
              'your kit is positive most days, the kit is not broken and '
              'neither are you. It is the wrong tool for that cycle.'),
          _en('Some fertility medicines containing hCG or LH will also produce '
              'a positive that means nothing about your own cycle. If a clinic '
              'is running your treatment, follow their monitoring rather than a '
              'strip.'),
          _en('And testing once a day can miss a short surge. If you are using '
              'kits seriously, testing twice a day through the expected '
              'stretch catches more of them.'),
        ],
      ),
      PvReadSection(
        heading: _en('The other things sold alongside them'),
        paragraphs: [
          _en('Saliva ferning scopes claim to show a crystal pattern under a '
              'lens around ovulation. The pattern is real but reading it is '
              'subjective, and studies comparing it against ultrasound have '
              'found it unreliable enough that no guideline recommends it.'),
          _en('Basal body temperature is the opposite case: genuinely '
              'informative, and informative too late. Temperature rises after '
              'ovulation, so charting tells you what your cycle usually does '
              'over several months rather than what to do this week. Useful '
              'for learning your own pattern. Useless for timing this cycle.'),
          _en('Wearables that estimate ovulation from skin temperature and '
              'pulse are improving quickly, and some are now cleared by '
              'regulators as contraception aids. They are also expensive, and '
              'for most people trying to conceive they answer the same '
              'question a five-rupee strip answers.'),
          _en('None of these is a requirement. If you own one already, use it. '
              'If you do not, the gap between owning one and not owning one is '
              'much smaller than the marketing suggests.'),
        ],
      ),

      PvReadSection(
        heading: _en('How to use one without it taking over'),
        paragraphs: [
          _en('Start testing about three days before your earliest likely '
              'ovulation. For a 28-day cycle, that is around day ten. Test in '
              'the afternoon rather than first thing, because LH usually shows '
              'up in urine later in the day than the hormone pregnancy tests '
              'look for.'),
          _en('When it turns positive, that day and the next are the ones. '
              'Then stop testing for the month. The commonest way a kit makes '
              'things worse is by becoming a daily exam with a pass and a fail '
              'attached to it.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When the kit is telling you to ask someone'),
      body: _en('If you have tested through several full cycles and never seen '
          'a positive, that is worth a conversation with a doctor. It may mean '
          'ovulation is not happening reliably, which is common and usually '
          'treatable. The same applies if your cycles are shorter than 21 days '
          'or longer than 35, or have stopped.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is it too late if the kit is already positive?'),
        answer: _en('No. A positive means the best two days are now, that day '
            'and the next. It is the start of the most useful stretch, not the '
            'end of it.'),
      ),
      PvReadFaq(
        question: _en('Can a kit tell me I am pregnant?'),
        answer: _en('No, and the two are easy to confuse because both are '
            'urine strips. Pregnancy tests look for hCG. Ovulation kits look '
            'for LH. They are different hormones and not interchangeable.'),
      ),
      PvReadFaq(
        question: _en('Do I still need to track if I use a kit?'),
        answer: _en('Not really. If you are being together every day or two '
            'across the week before ovulation, you are already covering the '
            'window. A kit narrows the aim. It does not change the target.'),
      ),
    ],
    evidence: _en('NICE fertility guideline CG156; ASRM/SREI committee opinion '
        'on optimising natural fertility (2022); NHS guidance on ovulation '
        'predictor kits.'),
  ),
];
