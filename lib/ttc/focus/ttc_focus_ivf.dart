// =============================================================================
//  IVF & IUI — the focus page for this door
// -----------------------------------------------------------------------------
//  ⚠️ ONE FILE PER BRACKET. See `docs/TTC-DOOR-BUILD.md` §2 — the tile model and
//  the registry stay in `ttc_focus_data.dart`, only the content lives here, so
//  several doors can be built at once without colliding.
//
//  ---------------------------------------------------------------------------
//  ⚠️ TEN SECTIONS ON ONE SCROLL, NOT FIVE SUB-TABS
//  ---------------------------------------------------------------------------
//
//  The brief asked for a tab bar. Same answer as PCOS and for a sharper reason
//  here: the two questions people arrive at this door with are "is it time to
//  get help" and "what is this going to cost", and those would have been in
//  different tabs. Someone frightened enough to open a door called IVF should
//  not have to guess which fifth of it holds her question.
//
//  The tab names survive as section headings, which is the work they were
//  actually doing.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NO COMMERCE BEYOND THE CONSULT, AND THAT IS A DATA DECISION ALREADY MADE
//  ---------------------------------------------------------------------------
//
//  `ttc_brackets.dart` marks products `notApplicable` on this bracket with the
//  plainest reason in that file: "Not a fit (clinical)." So there is no product
//  tile here and no course upsell. The consult is a door because seeking a
//  specialist is the reason she opened this area — not because we are selling
//  one.
//
//  ⚠️ AND NO SUCCESS RATES ANYWHERE. Not in a tile title, not in a blurb, not
//  in a carousel slide. `test/ttc_clinical_review_test.dart` scans this file.
//  "How to read a clinic's success rate" is about reading someone ELSE'S
//  published number critically, which is the opposite of quoting one.
// =============================================================================

import '../../data/hubs/ttc_hubs.dart' show kTtcActConsult;
import '../ttc_focus_data.dart';

const TtcFocusPage kTtcIvfFocus = TtcFocusPage(
  bracketId: 'ttc_infertility',

  // ⚠️ THE HUB'S HERO LINE, KEPT VERBATIM. The brief asks for it explicitly and
  // it is the best sentence in this part of the product — it names the feeling
  // without naming a diagnosis.
  intro: "When it's taking longer than expected. What the tests and treatments "
      'involve, what they cost, and who to talk to.',

  heroVideoSlot: 'ttc_infertility_intro',
  heroVideoTitle: 'When waiting stops being the answer',

  sections: [
    // -------------------------------------------------------------------------
    //  Should I get help? — FIRST, not third.
    // -------------------------------------------------------------------------
    //  ⚠️ THE BRIEF PUTS THIS SECOND, BEHIND "Understand". It is first here,
    //  and the reason is the one thing this door is for. Somebody who has been
    //  trying for fourteen months and is finally opening this area is not
    //  looking for an explanation of ICSI — she is trying to find out whether it
    //  is time. Making her scroll past an education section to reach the only
    //  question she came with is the same mistake as putting it behind a tab.
    TtcFocusSection(
      heading: 'Is it time to get help?',
      tiles: [
        TtcToolTile(
          title: 'Check where you stand',
          blurb: 'Six short questions. It tells you whether a conversation is '
              'worth having — never a score, and never a prediction.',
          surfaceId: 'ttc_fertility_help',
        ),
        TtcArticleTile(
          title: 'When to stop waiting and ask',
          blurb: 'The points at which guidance says to look into it, rather '
              'than give it more time.',
          readId: 'ttc_read_when_to_seek_help',
        ),
        TtcBookingTile(
          title: 'Speak to a fertility specialist',
          blurb: 'A 1:1 with someone who does this daily. Bring your dates and '
              'any results you have.',
          action: kTtcActConsult,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Understand
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What do the treatments actually involve?',
      tiles: [
        TtcArticleTile(
          title: 'What IUI and IVF involve',
          blurb: 'Both procedures, step by step, without the jargon.',
          readId: 'ttc_read_ivf_explained',
        ),
        TtcVideoTile(
          title: 'An IVF cycle, start to finish',
          blurb: 'The whole month, walked through by a specialist.',
          slotId: 'ttc_ivf_cycle_walkthrough',
          duration: '8 MIN',
        ),
        TtcCarouselTile(
          title: 'IUI or IVF, and when you move up',
          blurb: 'Two different treatments, and the point where one becomes '
              'the other.',
          coverTitle: 'IUI or IVF?',
          coverBlurb: 'They are not two strengths of the same thing.',
          coverHue: 206,
          cards: [
            TtcCarouselCard(
              title: 'IUI places prepared sperm directly into the uterus.',
              body: 'Fertilisation still happens inside your body, in the '
                  'usual place, on its own.',
            ),
            TtcCarouselCard(
              title: 'So IUI needs open tubes and reasonable sperm.',
              body: 'It shortens the journey. It cannot replace a step that '
                  'is blocked.',
            ),
            TtcCarouselCard(
              title: 'IVF fertilises the egg outside the body.',
              body: 'Eggs are collected, met with sperm in a laboratory, and '
                  'an embryo is placed back.',
            ),
            TtcCarouselCard(
              title: 'Which is why IVF works where tubes are blocked.',
              body: 'It bypasses the tubes entirely rather than helping '
                  'something through them.',
            ),
            TtcCarouselCard(
              title: 'IUI is cheaper, simpler and less effective per cycle.',
              body: 'It is usually tried for a limited number of cycles before '
                  'reviewing, rather than indefinitely.',
            ),
            TtcCarouselCard(
              title: 'Agree that number at the start.',
              body: 'How many IUI cycles before we reconsider is the single '
                  'most useful question to settle early.',
            ),
          ],
          reviewedBy: 'Reviewed by Dr. Meera Krishnan, Fertility specialist',
        ),
        TtcArticleTile(
          title: 'ICSI: when it is needed, when it is routine',
          blurb: 'One step inside IVF that is sometimes essential and often '
              'charged for anyway.',
          readId: 'ttc_read_ivf_icsi',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'What will they test, and why?',
      tiles: [
        TtcArticleTile(
          title: 'What a fertility check involves',
          blurb: 'Every test a first round usually orders, and what each one '
              'is trying to answer.',
          readId: 'ttc_read_ivf_workup',
        ),
        TtcArticleTile(
          title: 'His side of the tests',
          blurb: 'A semen analysis is the most informative test for the money '
              'and the one most often delayed.',
          readId: 'ttc_read_semen_analysis',
        ),
        TtcMythTile(
          title: 'Does a low AMH mean it is over?',
          blurb: 'The most misread number in fertility care.',
          myth: 'A low AMH means my eggs are bad and IVF will not work for me.',
          fact: 'AMH estimates how MANY eggs are in reserve, not their quality '
              'and not whether a pregnancy is possible. It helps a clinician '
              'choose a protocol. People with low AMH conceive, and people '
              'with high AMH sometimes do not — it is a count, not a verdict.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Money and clinics
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What does this cost in India?',
      tiles: [
        TtcArticleTile(
          title: 'What IVF actually costs in India',
          blurb: 'Real ranges, with the date they were checked.',
          readId: 'ttc_read_ivf_costs',
        ),
        TtcCarouselTile(
          title: 'What a package leaves out',
          blurb: 'The items that are usually quoted separately.',
          coverTitle: 'What a package leaves out',
          coverBlurb: 'The quote is rarely the total.',
          coverHue: 42,
          cards: [
            TtcCarouselCard(
              title: 'Medicines are frequently not included.',
              body: 'Stimulation drugs are one of the largest single costs and '
                  'vary with the dose you end up needing.',
            ),
            TtcCarouselCard(
              title: 'Nor is ICSI, in many quotes.',
              body: 'Ask whether it is included, and what in your results '
                  'makes it necessary.',
            ),
            TtcCarouselCard(
              title: 'Freezing has two costs.',
              body: 'The freezing itself, and then annual storage. Ask what '
                  'the yearly fee is and when it starts.',
            ),
            TtcCarouselCard(
              title: 'A frozen transfer later is usually its own charge.',
              body: 'So "one cycle" may mean the collection only, not the '
                  'transfer that produces a pregnancy.',
            ),
            TtcCarouselCard(
              title: 'Genetic testing of embryos is almost always extra.',
              body: 'And it is optional in most situations. Ask what it would '
                  'change for you before agreeing to it.',
            ),
            TtcCarouselCard(
              title: 'Ask for the full list in writing.',
              body: 'Every clinic can produce one. A clinic that will not is '
                  'telling you something.',
            ),
          ],
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'How do we choose a clinic?',
      tiles: [
        TtcCarouselTile(
          title: "How to read a clinic's success rate",
          blurb: 'The number on the hoarding is not the number you want.',
          coverTitle: "Reading a clinic's numbers",
          coverBlurb: 'Six questions that change what a figure means.',
          coverHue: 268,
          cards: [
            TtcCarouselCard(
              title: 'Ask: per cycle started, or per transfer?',
              body: 'Per transfer excludes every cycle that never reached one, '
                  'which makes the figure look much higher.',
            ),
            TtcCarouselCard(
              title: 'Ask: pregnancies, or live births?',
              body: 'A pregnancy rate counts positive tests. A live birth rate '
                  'counts babies. They are not close.',
            ),
            TtcCarouselCard(
              title: 'Ask: for which age group?',
              body: 'An overall figure is dominated by whichever ages the '
                  'clinic treats most. Ask for your own band.',
            ),
            TtcCarouselCard(
              title: 'Ask: over how many cycles?',
              body: 'A number from twenty cycles is not evidence. Ask how many '
                  'the figure is based on.',
            ),
            TtcCarouselCard(
              title: 'Ask: who is excluded?',
              body: 'A clinic that declines difficult cases will publish '
                  'better numbers while helping fewer people.',
            ),
            TtcCarouselCard(
              title: 'Then compare like with like, or not at all.',
              body: 'Two clinics quoting different measures cannot be compared. '
                  'The willingness to explain is itself the useful signal.',
            ),
          ],
          reviewedBy: 'Reviewed by Dr. Meera Krishnan, Fertility specialist',
        ),
        TtcCarouselTile(
          title: 'Questions to ask before you sign up',
          blurb: 'Eight things worth settling in the first appointment.',
          coverTitle: 'Before you sign',
          coverBlurb: 'Questions that are easier to ask now than later.',
          coverHue: 160,
          cards: [
            TtcCarouselCard(
              title: 'Who will actually see me each visit?',
              body: 'Continuity matters, and in busy centres it is not '
                  'guaranteed unless you ask.',
            ),
            TtcCarouselCard(
              title: 'What is included, and what is billed separately?',
              body: 'In writing. This is the question that prevents most '
                  'unpleasant surprises.',
            ),
            TtcCarouselCard(
              title: 'How many cycles before we review the plan?',
              body: 'Agreeing a number at the start stops a year passing by '
                  'default.',
            ),
            TtcCarouselCard(
              title: 'What is your policy on ICSI and on add-ons?',
              body: 'A clinic with a reason will give it in a sentence.',
            ),
            TtcCarouselCard(
              title: 'How do you decide fresh or frozen transfer?',
              body: 'Freezing everything is often the safer choice, not a '
                  'setback.',
            ),
            TtcCarouselCard(
              title: 'Who do I call at night, and what number?',
              body: 'Ask before you need it. Every clinic has an answer.',
            ),
            TtcCarouselCard(
              title: 'Are you registered under the ART Act?',
              body: 'Registration is a legal requirement for clinics in India. '
                  'It is a fair thing to confirm.',
            ),
            TtcCarouselCard(
              title: 'Can we have the plan in writing?',
              body: 'Not a challenge — just how you will remember it next '
                  'week.',
            ),
          ],
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Going through it
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'What will a cycle ask of me?',
      tiles: [
        TtcArticleTile(
          title: 'The injections, honestly',
          blurb: 'What you will be doing every evening for two weeks, and what '
              'it feels like.',
          readId: 'ttc_read_ivf_injections',
        ),
        TtcArticleTile(
          title: 'OHSS: when to call the clinic',
          blurb: 'The one complication worth knowing by name, and the signs '
              'that mean do not wait until morning.',
          readId: 'ttc_read_ivf_ohss',
        ),
        TtcVideoTile(
          title: 'Getting through the two-week wait',
          blurb: 'The hardest fortnight of the cycle, and what helps.',
          slotId: 'ttc_ivf_two_week_wait',
          duration: '6 MIN',
        ),
      ],
    ),

    TtcFocusSection(
      heading: 'The things people are afraid to ask',
      tiles: [
        TtcCarouselTile(
          title: 'Is egg retrieval painful?',
          blurb: 'What the twenty minutes actually involves.',
          coverTitle: 'Is egg retrieval painful?',
          coverBlurb: 'The honest version, step by step.',
          coverHue: 206,
          cards: [
            TtcCarouselCard(
              title: 'You are sedated. You will not feel the procedure.',
              body: 'In India this is usually short sedation or light general '
                  'anaesthesia, arranged by the clinic.',
            ),
            TtcCarouselCard(
              title: 'It takes about fifteen to twenty minutes.',
              body: 'A fine needle is guided by ultrasound to draw fluid from '
                  'each follicle. No incision is made.',
            ),
            TtcCarouselCard(
              title: 'You will be asked not to eat beforehand.',
              body: 'Usually from midnight. The clinic will give you a time — '
                  'this one matters.',
            ),
            TtcCarouselCard(
              title: 'Afterwards: cramping, and some spotting.',
              body: 'Most people describe strong period pain for a day, eased '
                  'by ordinary painkillers.',
            ),
            TtcCarouselCard(
              title: 'You cannot drive, and you should not go alone.',
              body: 'Take the day off and take someone with you. This is not '
                  'optional after sedation.',
            ),
            TtcCarouselCard(
              title: 'Call if pain worsens over the next few days.',
              body: 'Increasing pain, swelling or fever after retrieval is '
                  'what the clinic wants to hear about.',
            ),
          ],
          reviewedBy: 'Reviewed by Dr. Meera Krishnan, Fertility specialist',
        ),
        TtcMythTile(
          title: 'Does bed rest after transfer help?',
          blurb: 'One of the most persistent beliefs in fertility care.',
          myth: 'I should stay in bed after an embryo transfer to help it '
              'implant.',
          fact: 'Trials have not found that bed rest improves the chance of a '
              'pregnancy, and some found slightly worse outcomes. An embryo '
              'is not held in place by lying still. Ordinary gentle activity '
              'is what is generally advised — and lying in bed for days is '
              'hard on the body and harder on the mind. Follow whatever your '
              'own clinic tells you.',
        ),
        TtcMythTile(
          title: 'Can I work through a cycle?',
          blurb: 'What the two weeks actually demand of a working week.',
          myth: 'I will have to take the whole cycle off work.',
          fact: 'Most people work through the stimulation phase. What it does '
              'demand is several early-morning monitoring scans at short '
              'notice, retrieval day off entirely because of the sedation, and '
              'a quieter day or two after. Telling one person at work is '
              'usually what makes the scan appointments survivable.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Track — tools you use, not things you read
    // -------------------------------------------------------------------------
    TtcFocusSection(
      heading: 'Keep track of a cycle you are in',
      tiles: [
        TtcToolTile(
          title: 'Track this treatment cycle',
          blurb: 'Trigger, retrieval, transfer and the wait — the dates the '
              'clinic gave you, in one place.',
          surfaceId: 'ttc_treatment',
        ),
        TtcToolTile(
          title: 'Keep your reports together',
          blurb: 'Every result and letter in one place, so the next '
              'appointment starts from what is known.',
          surfaceId: 'ttc_records',
        ),
        TtcToolTile(
          title: 'Your medicines and timings',
          blurb: 'What to take and when, including the trigger time that '
              'genuinely matters.',
          surfaceId: 'ttc_medication',
        ),
        TtcToolTile(
          title: 'Appointments',
          blurb: 'Monitoring scans arrive at short notice. This is where they '
              'live.',
          surfaceId: 'ttc_appointments',
        ),
        // ⚠️ THE SAFETY TILE BELONGS IN *THIS* SECTION, NOT ONLY IN "GOING
        // THROUGH IT". OHSS has an article three sections up, which is the
        // right place to learn about it and the wrong place to find it at
        // eleven at night. Track is where someone mid-cycle actually is, so the
        // one thing that might need doing urgently has a door here too.
        //
        // The duplication is deliberate and it is the only duplicated tile on
        // the page.
        TtcArticleTile(
          title: 'When to call the clinic',
          blurb: 'The signs that mean phone now rather than wait for the '
              'morning. Worth reading before you need it.',
          readId: 'ttc_read_ivf_ohss',
        ),
      ],
    ),
  ],
);
