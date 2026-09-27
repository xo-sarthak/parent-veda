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
    // ⚠️ A CALENDAR, NOT A LANDSCAPE. The first URL here was a mountain,
    // picked for looking calm rather than for meaning anything — the exact
    // failure of stock imagery, where a picture is chosen for mood and ends
    // up decorating a subject it has nothing to do with. This piece is about
    // WHICH DAYS, so the picture is days. (Moved here from the door tile,
    // 2026-09-17, so the piece carries its picture wherever it opens.)
    imageUrl:
        'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=800&h=600&fit=crop',
    kicker: _en('Fertile window'),
    title: _en('How conception works'),
    teaser: _en('How it works, in plain words: what your cycle is doing, what '
        "ovulation is, and why so much of it can't be seen."),
    shortAnswer: _en('Once a cycle, an egg is released and lives for about a '
        'day. If sperm meet it in the fallopian tube, the fertilised egg '
        'travels to the womb and settles into its lining about a week later. '
        "Most of this happens without any sign you can feel, and it doesn't "
        'happen every month, even for healthy couples.'),

    scaleSetter: _en("Most of what happens when you're trying to conceive "
        "happens out of sight. Knowing how it works won't make it happen "
        'faster. It can turn a month of guessing into a month that makes '
        'sense, and that makes the wait a little easier.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

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
          _en('Your cycle is really two halves, one after the other, and they '
              'behave very differently. Most of us were never taught this. '
              'Once you know it, a lot of the confusing parts start to make '
              'sense.'),
          _en('The first half can change in length. The second half mostly '
              "doesn't. Almost everything confusing about cycle length comes "
              'from that.'),
        ],
      ),

      PvReadSection(
        heading: _en('What happens in the first half of my cycle?'),
        paragraphs: [
          _en('From the first day of your period, a group of follicles in '
              'your ovaries starts to grow. Each one holds an egg that '
              "isn't ready yet. Over the next couple of weeks, one grows "
              'ahead of the rest and the others stop. You feel no symptoms '
              'at all.'),
          _en('This half is called the follicular phase, and its length '
              'really does vary. It usually lasts between ten and fourteen '
              'days, but it can be shorter or longer. It can also change for '
              'you from one month to the next. Stress, illness, travel and '
              'poor sleep can all shift it.'),
          _en("That's why a cycle of 28 days one month and 33 the next "
              "doesn't mean something is wrong. What changed was almost "
              'certainly this half. The first half is the flexible one.'),
        ],
      ),

      PvReadSection(
        heading: _en('What is ovulation?'),
        paragraphs: [
          _en('When the leading follicle is ready, a sharp rise in LH '
              '(luteinising hormone) makes it release its egg. That is '
              'ovulation, and it takes minutes. Most women feel nothing. '
              'Those who do usually notice a dull ache on one side, nothing '
              'dramatic.'),
          _en('The egg then has about twenty-four hours. If it '
              "isn't fertilised in that time, it breaks down and the body "
              'takes it back in. Nothing is wasted or lost. This happens '
              'several hundred times in a lifetime.'),
          _en('Ovulation strips pick up that LH rise. So a positive strip '
              'means ovulation is probably coming in the next day or so. It '
              "doesn't mean it has already happened."),
        ],
        tip: PvReadTip(
          title: _en('The sign that comes early enough to use'),
          body: _en('Cervical mucus (the discharge from your cervix) changes '
              'before ovulation, not after. In the days leading up to it, it '
              'turns clear, slippery and stretchy, a lot like raw egg white. '
              'This is your body getting ready. Unlike a rise in temperature, '
              "it tells you something while there's still time to use it."),
        ),
      ),

      PvReadSection(
        heading: _en('Why is the second half so steady?'),
        paragraphs: [
          _en("The empty follicle doesn't disappear. It turns into a small, "
              'short-lived gland called the corpus luteum. This makes '
              'progesterone, the hormone that keeps the lining of your womb '
              'in place and ready.'),
          _en('This half, the luteal phase, is much more steady. It lasts '
              'about fourteen days, and anything from ten to seventeen is '
              'normal. Better still, it tends to be about the same length '
              'for you every month.'),
          _en('Progesterone does more than hold the lining. It nudges your '
              'resting temperature up a little and thickens your discharge, '
              'so it turns sticky or dry. It can also bring tender breasts, '
              'bloating, tiredness or a low mood in the days before a period.'),
          _en("If you don't get pregnant, the corpus luteum winds down on its "
              'own schedule and progesterone falls. Then the lining comes '
              "away. That's your period, which marks the end of this cycle's "
              'work, not the start of it.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Why this matters for tracking'),
          body: _en("The second half is steady and the first half isn't. So "
              "it's better to count ovulation backwards from your next "
              'period than forwards from your last one. In a 33-day cycle, '
              'ovulation is much more likely around day 19 than day 14. '
              'That\'s why the usual "day 14" advice so often misses for '
              'anyone whose cycle isn\'t 28 days.'),
        ),
      ),

      PvReadSection(
        heading: _en('What has to happen for me to get pregnant?'),
        paragraphs: [
          _en('For you to get pregnant, several things have to happen in '
              'order. Any one of them can fail to happen in a given month, '
              'with no sign at all.'),
        ],
        bullets: [
          _en('An egg has to be released, and be healthy.'),
          _en('Sperm have to reach the tube at the right time, in large '
              'enough numbers, and moving well.'),
          _en('One sperm has to fertilise the egg. This happens in the '
              'fallopian tube, not in the womb.'),
          _en('The fertilised egg has to keep dividing correctly for about a '
              'week as it travels down.'),
          _en("And it has to implant, or settle, into a lining that's ready "
              'for it.'),
        ],
      ),

      PvReadSection(
        heading: _en('When does a pregnancy begin, and how are the weeks '
            'counted?'),
        paragraphs: [
          _en('The fertilised egg settles into the lining about six to ten '
              'days after ovulation. Only then does it start making hCG, the '
              'pregnancy hormone. That is what a pregnancy test looks for, '
              "and it's why a test before your period is due often shows "
              'nothing yet.'),
          _en('Doctors date a pregnancy from the day your last period began, '
              'not from the day you conceived. So in a 28-day cycle, '
              "you're called four weeks pregnant around the day your period "
              'is missed, even though conception was only about two weeks '
              'earlier.'),
          _en('It sounds odd, but there is a good reason. Almost nobody knows '
              'the day they conceived, while most people know when their last '
              'period began. Counting from that date gives every pregnancy the '
              'same starting line.'),
        ],
        mythFact: PvMythFact(
          myth: _en('You can feel the moment you conceive.'),
          fact: _en('Fertilisation and implantation happen without any feeling '
              'you can pick out. The tender breasts, bloating and tiredness '
              'of the second half come from progesterone, and they happen '
              'whether or not you conceived. A test once your period is late '
              'is the only way to know.'),
        ),
      ),

      PvReadSection(
        // ⚠️ FOLDS. Reference, not the spine — it explains an arithmetic she
        // may want on a hard month and does not need on the day she is
        // learning what a follicle is.
        collapsible: true,
        summary: _en("Why a healthy couple doesn't get pregnant every month, "
            "and why that's just how the numbers work, not anyone's fault."),
        heading: _en("Why doesn't it happen every month?"),
        paragraphs: [
          _en('There are several links in that chain. The most common reason '
              "a month doesn't work is that a fertilised egg didn't divide "
              'correctly. This is a chance mistake in the chromosomes of a '
              'single cell. Nothing either of you did caused it, and nothing '
              'could have stopped it.'),
          _en('These chance mistakes become more common with age, and that is '
              'most of what "age and fertility" means. It isn\'t that the '
              'ovaries stop working. It\'s that more of the eggs carry an '
              'error that stops things early, often before a period is even '
              'late.'),
          _en("That's why doctors talk about fertility over several months, "
              "not one cycle. A month that doesn't work is what usually "
              "happens, not the exception. It doesn't say anything about "
              'either of you.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en("My cycle isn't 28 days. Is that a problem?"),
        answer: _en('Not on its own. Cycles of about 21 to 35 days are '
            'normal, and the difference between them is almost always in the '
            'first half. What matters more than the number is whether it '
            'stays about the same each month. A steady 32-day cycle is much '
            'less worrying than one that swings between 26 and 45.'),
      ),
      PvReadFaq(
        question: _en('Can I feel ovulation?'),
        answer: _en('Some women do, as a dull ache on one side that lasts a '
            'few hours. It even has a name: mittelschmerz. Most women feel '
            "nothing, and feeling nothing doesn't tell you whether it "
            'happened or not.'),
      ),
      PvReadFaq(
        question: _en('Can you ovulate twice in one cycle?'),
        answer: _en('More than one egg can be released, but only within the '
            "same short window. That's how non-identical twins happen. What "
            "doesn't happen is a second, separate ovulation later in the "
            'same cycle. Once progesterone rises, that door is closed for the '
            'month.'),
      ),
      PvReadFaq(
        question: _en('Does a period always mean I ovulated?'),
        answer: _en('Usually, but not always. A cycle can go by without '
            'releasing an egg and still end in bleeding, because the lining '
            'builds up and sheds anyway. This is more common when cycles are '
            "long or irregular. It's one reason a few months of tracking "
            'tells you more than any single month can.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Worth talking to a doctor about'),
      body: _en("It's worth seeing a doctor if your cycles are shorter than "
          '21 days or longer than 35, if they change a lot from month to '
          'month, if your periods have stopped for three months or more, or '
          'if bleeding is heavy enough to get in the way of your day. None '
          'of these is an emergency. Two or three months of dates will help '
          'your doctor a lot, so start noting them now and book a visit when '
          'it suits you.'),
    ),

    evidence: _en('Cycle and phase physiology follows Endotext, "The Normal '
        'Menstrual Cycle and the Control of Ovulation" (NCBI Bookshelf), and '
        'StatPearls, "Physiology, Menstrual Cycle". The normal length of the '
        'luteal phase and the order of cervical mucus changes follow the UCSF '
        'Center for Reproductive Health and Cleveland Clinic. The timing of '
        'implantation and hCG follows StatPearls, and counting pregnancy weeks '
        'from the last period follows NHS and ACOG guidance on estimating a due '
        'date. Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Start noting your own cycle'),
        value: _en('Three months of dates shows where your ovulation falls, '
            'which no article can tell you.'),
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
    title: _en('Timing, and the advice you can let go of'),
    teaser: _en('When it matters, how often, and which of the things '
        "you've been told make no difference at all."),
    shortAnswer: _en('You can get pregnant on about six days each cycle: the '
        'five days before ovulation and the day itself. Having sex every one '
        'to two days across those days is enough, and there is no single '
        'perfect day to hit. Most other rules you hear, like lying with your '
        'legs up, make no difference.'),

    scaleSetter: _en("Your fertile window is about six days long, and it's "
        'forgiving. Being together every day or two across those days works '
        "as well as any amount of testing and counting. There's no single "
        "day to hit, and you can't miss it by an hour."),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    heroVideoSlot: 'ttc_vid_timing_myths',

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Most timing advice is built on one number that's wrong for "
              'most people: day fourteen. It assumes a 28-day cycle, and most '
              "cycles aren't 28 days."),
          _en("What's true is simpler, and asks much less of you than all "
              'that counting.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why is the window six days long?'),
        paragraphs: [
          _en('Sperm survive around five days inside the body. An egg lives '
              "about a day after it's released. Put those together and you "
              'get a window of about six days, ending on the day of ovulation '
              'itself.'),
          _en('The days before ovulation matter most, because sperm can wait '
              "and an egg can't. The best stretch is the three days ending on "
              'the day of ovulation. So by the time a test tells you '
              'ovulation has happened, the most useful days have already '
              'gone.'),
          _en('This is the most useful thing to take from this whole piece. '
              'Aim to be together in the window before it closes, rather than '
              'trying to catch the exact moment.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("How often, and that's all you need"),
          body: _en("Every one to two days across the window. It doesn't have "
              "to be daily or timed, and there's no need to save it up. This "
              'is exactly what the American Society for Reproductive Medicine '
              "advises. It's that plain on purpose: a couple having sex every "
              "other day doesn't need to track anything to be doing this "
              'right.'),
        ),
      ),

      PvReadSection(
        heading: _en('Which tips can I let go of?'),
        paragraphs: [
          _en('These come up more than anything else. Each one makes a '
              'private moment a little more awkward every month, and none of '
              'them helps.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Lie still with your legs up for twenty minutes '
              'afterwards.'),
          fact: _en('Sperm reach the cervix within minutes, and the ones that '
              'will travel are already on their way. Getting up changes '
              "nothing. It's a good one to let go of first, because it's the "
              'one that most often turns a private moment into a procedure.'),
        ),
      ),

      PvReadSection(
        mythFact: PvMythFact(
          myth: _en('Some positions work better than others.'),
          fact: _en("There's no evidence that position affects whether you "
              'get pregnant. None of the studies people quote for this '
              'measured pregnancy.'),
        ),
      ),

      PvReadSection(
        mythFact: PvMythFact(
          myth: _en('Save it up for a few days so the count is higher.'),
          fact: _en('Long gaps raise the number of sperm but make them move '
              'less well, and movement is what matters here. Every one to two '
              'days works best because it balances the two. Holding off for '
              'a week before the window works against you.'),
        ),
      ),

      PvReadSection(
        mythFact: PvMythFact(
          myth: _en("If you're stressed, it won't happen."),
          fact: _en('Very high stress that goes on for a long time can delay '
              "or stop ovulation, and that's real. Everyday stress, like a "
              "hard month at work or worrying about this, hasn't been shown "
              'to stop you getting pregnant. So if someone tells you to just '
              "relax, please don't hear it as your fault. It isn't."),
        ),
      ),

      PvReadSection(
        heading: _en('Does lubricant make a difference?'),
        paragraphs: [
          _en('Most ordinary lubricants, and saliva, make sperm move less '
              "well, and this has been measured. It's a rare piece of bedroom "
              'advice with real evidence behind it, and hardly anyone '
              'mentions it.'),
          _en('If you use one, look for a product labelled fertility-friendly. '
              "They're easy to find in India and cost a little more than the "
              'usual ones. Nothing else in this section is worth changing. '
              'This one is.'),
        ],
        tip: PvReadTip(
          title: _en('If tracking has started to feel like a second job'),
          body: _en("It's okay to stop. Having sex every two days through the "
              'middle of your cycle covers your fertile days without a single '
              'strip, chart or reminder. Tracking helps if your cycles are '
              "irregular or you'd like notes for a doctor. It isn't a must, "
              "and it shouldn't make this time harder than it already is."),
        ),
      ),

      PvReadSection(
        heading: _en('How do I check my discharge?'),
        paragraphs: [
          _en("Checking your discharge is free, and it shows your window "
              "opening while there's still time to use it. Once you know what "
              'to look for, it takes a few seconds a day.'),
          _en('The changes come from your hormones. As oestrogen rises before '
              'ovulation, discharge gets wetter, clearer and more slippery, '
              'which helps sperm swim. After ovulation, progesterone makes it '
              'thick and sticky, or dries it up.'),
        ],
        bullets: [
          _en('1. Check at about the same time each day, such as when you go '
              'to the toilet. Wipe with clean tissue before you pee, or look '
              "at what's on your underwear."),
          _en('2. Notice how it feels: dry, sticky, creamy, wet or slippery.'),
          _en('3. Stretch a little between your thumb and finger. Fertile '
              'discharge is clear and stretches a few centimetres without '
              'breaking, like raw egg white.'),
          _en('4. Note what you saw. Your wet, slippery, stretchy days are the '
              'most fertile ones, and the last of them usually falls close to '
              'ovulation.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Creamy white is normal too'),
          body: _en('Creamy, white, lotion-like discharge is common on the less '
              'fertile days, before the wet days start and after ovulation. '
              "It's nothing to worry about on its own. Discharge that itches, "
              'burns, smells bad, or turns green, grey or lumpy is different, '
              'and worth showing a doctor.'),
        ),
      ),

      PvReadSection(
        paragraphs: [
          _en('Your cervix changes too. Near ovulation it sits higher, feels '
              'softer and opens a little. Some women learn to check it with a '
              "clean finger, but it's much harder to read than discharge, and "
              "you don't need it."),
        ],
      ),

      PvReadSection(
        heading: _en('What can change my discharge?'),
        paragraphs: [
          _en('A few ordinary things can make fertile discharge harder to '
              'see. Knowing them stops you reading too much into one dry '
              'month.'),
        ],
        bullets: [
          _en('Some cold and allergy medicines. The antihistamines that dry a '
              'runny nose can dry discharge too.'),
          _en('Clomiphene, a common ovulation tablet, can make it thinner or '
              'scantier for some women.'),
          _en('Vaginal washes and douching. They upset the natural balance '
              'and wash away the very thing you are trying to notice. Plain '
              'water on the outside is enough.'),
          _en('An infection, which changes the colour, smell and feel.'),
          _en('Age. Having fewer wet days as you get older is common.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Drinking lots of water gives you more fertile discharge.'),
          fact: _en('Being very dehydrated may make everything a little drier. '
              "But drinking extra water hasn't been shown to improve fertile "
              "discharge. Drink when you're thirsty, as you usually would."),
        ),
      ),

      PvReadSection(
        heading: _en('How do I know ovulation is over?'),
        paragraphs: [
          _en('The egg lives for about a day, so once ovulation has passed, '
              'the window for this cycle has closed. Knowing the signs lets a '
              'tired couple ease off without worrying.'),
        ],
        bullets: [
          _en('Your discharge dries up, or turns thick, sticky or creamy after '
              'the wet, stretchy days.'),
          _en('Your resting temperature rises a little, often by about 0.2 to '
              '0.5 degrees Celsius, and stays up for at least three days in a '
              'row.'),
          _en("A positive ovulation strip turns negative again. It isn't proof "
              'on its own, but with the other signs it helps.'),
          _en('A mid-cycle ache on one side fades, and your breasts may start '
              'to feel tender.'),
        ],
      ),

      PvReadSection(
        paragraphs: [
          _en("None of these is exact, and you don't need all of them. If "
              "you're unsure, carrying on every day or two for a couple more "
              'days does no harm.'),
        ],
      ),

      PvReadSection(
        heading: _en("What if we're busy, on shifts or in different cities?"),
        paragraphs: [
          _en('Long hours, night shifts and a partner working in another city '
              "are common here. You don't need every day of the window. A few "
              'well-placed days still count.'),
        ],
        bullets: [
          _en('1. Learn roughly when your window falls. A few months of period '
              'dates, or a few strips, show you which days to protect.'),
          _en('2. Plan visits, leave or a quiet evening around those days, '
              'rather than around day 14 on the calendar.'),
          _en('3. If you can only manage two or three times, aim for the days '
              'before ovulation, not after it.'),
          _en('4. Keep the rest of the month free of timing. Being close '
              "without a reason matters too, and it's what keeps this "
              'bearable over many months.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. A tool comparison she needs on the day she is standing in
        // a chemist, and does not need while reading about the window.
        collapsible: true,
        summary: _en('Strips, temperature and mucus: what each one tells you, '
            'and which is worth your money.'),
        heading: _en('How else can I track my fertile days?'),
        paragraphs: [
          _en('There are three methods, and they answer different questions. '
              'Shops rarely explain this when they sell you one.'),
        ],
        bullets: [
          _en('Ovulation strips pick up the LH rise, so they warn you that '
              "ovulation is coming in a day or so. That's useful, because "
              'they look ahead. A plain strip is as accurate as an expensive '
              'one.'),
          _en('Basal temperature (your temperature at rest) rises after '
              'ovulation, so it confirms ovulation happened, but only after '
              "the window has closed. It's useful over months for finding "
              'your pattern, and no help for this month.'),
          _en('Cervical mucus turns clear and stretchy in the days before. '
              "It's free, it looks ahead, and it only needs you to notice."),
          _en('A mild ache or twinge on one side around the middle of your '
              'cycle is common, just before or around ovulation. Some women '
              'feel it every month and many never do, so its absence means '
              'nothing.'),
          _en("A doctor can confirm ovulation, if there's a reason to. A "
              'progesterone blood test about a week before your period is due '
              'shows whether you ovulated. A few ultrasound scans across the '
              'cycle, called follicle tracking, can watch an egg grow and be '
              'released.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('How long should we try before worrying?'),
        answer: _en("The usual advice is a year if you're under 35, and six "
            "months if you're 35 or over. That assumes regular cycles you can "
            'predict. If yours are irregular, or you already know about PCOS, '
            "endometriosis or past pelvic surgery, you don't need to wait that "
            "long. It's reasonable to ask sooner."),
      ),
      PvReadFaq(
        question: _en('We can only manage it once or twice a month. Is that '
            'enough?'),
        answer: _en("It makes it less likely you'll land in the window by "
            'luck. This is exactly when tracking is worth it. Knowing roughly '
            'when your window is lets you place those few times well. Couples '
            'who live apart do this successfully all the time.'),
      ),
      PvReadFaq(
        question: _en('Is there a best time of day?'),
        answer: _en('No. Sperm counts change a little through the day, but '
            'not enough to matter. Whatever time suits the two of you is the '
            'right time.'),
      ),
      PvReadFaq(
        question: _en('Does it matter if we have sex on the day of ovulation '
            'itself?'),
        answer: _en("It's a good day, but not the best one. The two days "
            'before it count for more, because sperm can already be waiting. '
            "That's why waiting for a positive strip and trying that day "
            'tends to be slightly late.'),
      ),
      PvReadFaq(
        question: _en('Should I avoid peeing or showering straight after '
            'sex?'),
        answer: _en('No. The sperm that matter reach your cervix within '
            'minutes, and urine leaves through a different opening. Peeing '
            "after sex helps prevent urine infections, so it's a good habit to "
            'keep. A shower is fine too.'),
      ),
      PvReadFaq(
        question: _en('Can I get pregnant from sex during my period?'),
        answer: _en("It's unlikely, but it can happen. Sperm can live for about "
            'five days. If your cycle is short and you ovulate early, sex near '
            'the end of your period can fall inside your window. Bleeding in '
            'the middle of a cycle can also be mistaken for a period.'),
      ),
      PvReadFaq(
        question: _en('Can an app tell me when I ovulate?'),
        answer: _en('It can make an estimate, and an estimate from your own '
            "logged dates is useful. What it can't do is know for sure, "
            'because no app can see an ovary. Treat the estimate as a window '
            'to be together across, never as a date to hit.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("When timing isn't the problem"),
      body: _en("Book a visit if you've been trying for a year (six months if "
          "you're 35 or over) and your cycles are predictable. Go sooner, "
          'without waiting that long, if your cycles are irregular or have '
          'stopped, if sex is painful, if periods are very heavy, or if '
          'either of you has had pelvic surgery, chemotherapy or a known '
          "fertility condition. Timing advice can't fix any of those, and "
          'no amount of better timing will.'),
    ),

    evidence: _en('The fertile window, the three days most likely to lead to '
        'pregnancy, the advice of every one to two days and the caution about '
        'ordinary lubricants all follow "Optimizing natural fertility: a '
        'committee opinion" from the Practice Committees of the American '
        'Society for Reproductive Medicine and the Society for Reproductive '
        'Endocrinology and Infertility (updated 2022). How discharge and '
        'temperature change across the cycle follows Cleveland Clinic and the '
        'NHS, and the progesterone test for confirming ovulation follows the '
        'NICE fertility guideline CG156. Sources checked September 2026.'),

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
        value: _en('The two things worth keeping at home, and what to skip.'),
        surfaceId: 'ttc_products',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Ask a fertility specialist'),
        value: _en("If the timing is right and it still isn't happening, "
            "that's a different conversation."),
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
    teaser: _en('Sometimes, and for fewer people than the box suggests. '
        "Here's when a kit is worth the money, and when it only tells you "
        'what your body already told you.'),
    shortAnswer: _en('An ovulation kit picks up the rise in LH that comes a '
        'day or so before an egg is released, so it helps you spot your best '
        "days. It's most useful when your cycles vary and less useful with "
        "PCOS, where it can mislead. You don't need one to get pregnant."),
    scaleSetter: _en('A kit is a convenience, not a must. Nobody needs one to '
        'get pregnant. A couple being together every other day through the '
        'week before ovulation is already doing what a kit is meant to help '
        'them time. If the cost or the daily testing feels like a burden, '
        "it's fine to stop. That's a sensible choice, not a shortcut."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('An ovulation kit tests your urine for luteinising hormone, '
              'or LH for short. LH stays low for most of the cycle. Then it '
              'rises sharply about a day to a day and a half before an egg '
              'is released.'),
          _en("That rise is what the second line on the strip shows. It's a "
              'useful signal, but it tells you less than most packaging '
              'suggests.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does a positive strip mean?'),
        paragraphs: [
          _en('A positive means the LH rise has started, so ovulation is '
              'likely in the next twelve to thirty-six hours. The two days '
              'starting with that positive are the best days of the month to '
              'try.'),
          _en("What it doesn't tell you is that an egg was definitely "
              'released. LH can rise without ovulation following. This '
              'happens now and then in cycles that otherwise look normal, and '
              'more often with some conditions. A kit reports a hormone, not '
              'a result.'),
          _en('It also comes late in the window. The six fertile days end on '
              'the day of ovulation, so a kit that turns positive is telling '
              "you about the last two of them. That's useful, but it isn't "
              'the whole picture.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Cheap strips test the same hormone'),
          body: _en('Expensive digital readers and plain paper strips both '
              'measure LH. The extra money pays for reading the line for you, '
              'not for better chemistry. If squinting at a faint line '
              'stresses you, a digital one is worth it for that alone. But it '
              "isn't a better test."),
        ),
      ),
      PvReadSection(
        heading: _en('When is a kit worth it?'),
        paragraphs: [
          _en('If your cycles vary by more than a few days, counting forward '
              "from your last period won't place the window reliably. A kit "
              "gives you something your calendar can't."),
          _en("It also helps if you find your body's signs hard to read, or if "
              'you and your partner are apart for stretches and need to plan '
              'instead of keeping a rhythm.'),
          _en('If your cycles are regular and you can already notice the '
              'fertile mucus change (clear, wet and stretchy a few days '
              "before), a kit will mostly confirm what you'd already noticed."),
        ],
      ),
      PvReadSection(
        heading: _en('When can a kit get it wrong?'),
        paragraphs: [
          _en('Polycystic ovary syndrome (PCOS) is the big one. PCOS can keep '
              'LH high for much of the cycle, so kits show positive again and '
              'again without a real rise.'),
          _en("If you have PCOS and your kit is positive most days, the kit "
              "isn't broken and neither are you. It's the wrong tool for that "
              'cycle.'),
          _en('Some fertility medicines that contain hCG or LH will also give '
              'a positive that says nothing about your own cycle. If a clinic '
              'is running your treatment, follow their monitoring instead of '
              'a strip.'),
          _en('A recent pregnancy or loss can leave hCG in your body for a '
              'few weeks, and some strips read it as LH. In the years before '
              'menopause, LH runs higher, so strips can show positive often.'),
          _en('So treat a kit as a guide, and read it alongside your discharge '
              'and your dates.'),
          _en('Testing once a day can also miss a short rise. If you are '
              'using kits seriously, testing twice a day through the expected '
              'days catches more of them.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about scopes, thermometers and wearables?'),
        paragraphs: [
          _en('Saliva ferning scopes claim to show a crystal pattern under a '
              'lens around ovulation. The pattern is real, but reading it is '
              'a matter of opinion. Studies comparing it with ultrasound found '
              'it unreliable enough that no guideline recommends it.'),
          _en('Basal body temperature is the opposite. It tells you something '
              'real, but too late. Your temperature rises after ovulation, so '
              'charting shows what your cycle usually does over several '
              'months, not what to do this week.'),
          _en("It's useful for learning your own pattern, and no help for "
              'timing this cycle.'),
          _en('Wearables that estimate ovulation from skin temperature and '
              'pulse are getting better quickly. Some are now cleared by '
              'regulators to help with contraception.'),
          _en("They're also expensive, and for most people trying to "
              'conceive, they answer the same question a five-rupee strip '
              'does.'),
          _en("None of these is a must. If you already own one, use it. If you "
              "don't, you're missing much less than the marketing suggests."),
        ],
      ),

      PvReadSection(
        heading: _en("What's worth buying in India?"),
        paragraphs: [
          _en("Prices change by brand and shop, so treat these as rough "
              'ranges. They are here so you know what you are paying extra '
              'for.'),
        ],
        bullets: [
          _en('Plain LH strips. The cheapest, often about ₹5 to ₹40 a strip '
              'when bought in packs from a chemist or online. They work as '
              'well as anything else.'),
          _en('Midstream or cassette tests. The same test in a plastic '
              'holder, easier to use and several times the price of a strip.'),
          _en('Digital readers. They show a symbol or a word instead of a '
              'line, which helps if faint lines stress you. A pack usually '
              'costs ₹1,500 or more.'),
          _en('A basal body thermometer that reads to two decimal places. A '
              'few hundred rupees, and useful only if you chart every '
              'morning.'),
          _en('Wearable trackers. Many thousands of rupees. Worth it only if '
              'you would wear one anyway.'),
        ],
        tip: PvReadTip(
          title: _en('What most couples need'),
          body: _en('A pack of plain strips, used in the afternoon on the '
              'right days, plus noticing your discharge. That covers what '
              'the costlier options do.'),
        ),
      ),

      PvReadSection(
        heading: _en('Which day should I start testing?'),
        paragraphs: [
          _en('Start testing about three days before the earliest day you '
              "might ovulate. For a 28-day cycle, that's around day ten."),
          _en('If you want a rule, many kit leaflets take 17 away from your '
              'usual cycle length. That gives day 11 for a 28-day cycle, so '
              'day ten or eleven are both fine.'),
        ],
        bullets: [
          _en('A 24-day cycle: start around day 7.'),
          _en('A 28-day cycle: start around day 10 or 11.'),
          _en('A 32-day cycle: start around day 15.'),
          _en('A 35-day cycle: start around day 18.'),
        ],
      ),

      PvReadSection(
        paragraphs: [
          _en('Test in the afternoon, not first thing in the morning. LH '
              'usually shows up in urine later in the day than the hormone '
              'pregnancy tests look for.'),
          _en('Try not to drink a lot in the two hours before you test. Very '
              'watery urine can hide a faint rise.'),
        ],
        tip: PvReadTip(
          title: _en('Why some people test twice a day'),
          body: _en('For some women the LH rise lasts less than a day, and a '
              'once-a-day test can miss it. Around the days you expect a '
              'positive, test twice, for example late morning and early '
              'evening.'),
        ),
      ),

      PvReadSection(
        heading: _en('What if my cycles are irregular?'),
        paragraphs: [
          _en('Work from your shortest recent cycle. If your last few cycles '
              'ran from 26 to 38 days, test as if your cycle were 26 days, '
              'starting on day 9.'),
          _en("You'll use more strips this way, sometimes two packs a cycle. "
              'To save strips, watch your discharge and start testing daily '
              'once it turns wetter.'),
          _en('If your cycles are very long or hard to predict, or you have '
              'PCOS, a kit may not be the right tool. Help from a doctor with '
              'the cycle itself is often more useful than more strips.'),
          _en('The read on ovulation tests with irregular cycles goes through '
              'this step by step.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why do I keep getting negatives?'),
        paragraphs: [
          _en('A run of negative strips is worrying. It often has an everyday '
              'reason.'),
        ],
        bullets: [
          _en('Starting too late, so the rise came before your first test.'),
          _en('Testing once a day and missing a short rise.'),
          _en('Testing first-morning urine, or after drinking a lot.'),
          _en("A cycle without ovulation. Everyone has one now and then, and "
              "they're more common with PCOS, thyroid problems, high "
              'prolactin, a big change in weight, heavy exercise, stress or '
              'breastfeeding.'),
          _en('In your forties, cycles change and ovulation becomes less '
              'regular.'),
        ],
      ),

      PvReadSection(
        heading: _en('How do I use a kit without it taking over?'),
        paragraphs: [
          _en('When it turns positive, that day and the next are the ones. '
              'Then stop testing for the month. The most common way a kit '
              'makes things worse is by turning into a daily exam you can pass '
              'or fail.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When the kit is a sign to ask a doctor'),
      body: _en("If you've tested through several full cycles and never seen "
          "a positive, it's worth talking to a doctor. It may mean ovulation "
          "isn't happening reliably, which is common and usually treatable. "
          'The same goes if your cycles are shorter than 21 days or longer '
          'than 35, or have stopped.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is it too late if the kit is already positive?'),
        answer: _en('No. A positive means the best two days are now: that day '
            "and the next. It's the start of the most useful stretch, not the "
            'end of it.'),
      ),
      PvReadFaq(
        question: _en("Can a kit tell me I'm pregnant?"),
        answer: _en("No. It's easy to mix them up because both are urine "
            'strips. Pregnancy tests look for hCG. Ovulation kits look for '
            "LH. They're different hormones, and one can't stand in for the "
            'other.'),
      ),
      PvReadFaq(
        question: _en('Do I still need to track if I use a kit?'),
        answer: _en("Not really. If you're together every day or two across "
            "the week before ovulation, you're already covering the window. "
            "A kit helps you aim more closely. It doesn't change the target."),
      ),
    ],
    evidence: _en('NICE fertility guideline CG156; ASRM/SREI committee opinion '
        'on optimising natural fertility (2022); NHS guidance on ovulation '
        'predictor kits; StatPearls on the LH surge and on anovulation. '
        'Prices are rough ranges from Indian chemists and online shops. '
        'Sources checked September 2026.'),

    // Walked on the phone 2026-09-17: this was the one read in the door whose
    // foot ended in blank space, because it had no Read next. The question
    // after "do kits help" is "how does it actually work", then "when".
    readNext: [
      'ttc_read_ovulation_tests_irregular',
      'ttc_read_how_conception_works',
      'ttc_read_timing_myths',
    ],
  ),
];
