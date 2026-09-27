// =============================================================================
//  After a loss — the reads for this door
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

final List<PvRead> kTtcReadsAfterLoss = [
  // ===========================================================================
  //  AFTER A LOSS — the two reads, and the rules they are written under
  // ===========================================================================
  //  Excel Content cell: "Physical recovery, when it is safe to try again,
  //  emotional support." Three topics, two reads — the second and third are one
  //  decision rather than two, because "when is it safe" and "when am I ready"
  //  are asked in the same breath and answered by different people.
  //
  //  ---------------------------------------------------------------------------
  //  ⚠️ THE MOST CONSTRAINED BRACKET IN THE STAGE. FIVE OF ITS SEVEN LAYERS SAY
  //  "NOT A FIT" AND EVERY REFUSAL IS RIGHT.
  //  ---------------------------------------------------------------------------
  //
  //  No product row. No course card. No consult upsell dressed as a next step.
  //  No tracker, no checklist, no habit. A woman who has just lost a pregnancy
  //  is shown a person and, if she wants it, other people.
  //
  //  ⚠️ AND NO CHEERFUL LANGUAGE ANYWHERE. The house tone across the rest of
  //  this stage is warm; here it is quiet. Short sentences. No encouragement,
  //  no "you've got this", no silver lining, and above all no timeline
  //  presented as a rule she is behind on. `kTtcAfterLoss` states this and the
  //  journey is two steps long for the same reason — padding a grieving
  //  woman's screen with more would be the injury, not the care.
  //
  //  ⚠️ THE SCALE-SETTER IS NOT REASSURANCE HERE. Everywhere else in this
  //  library it answers "how worried should I be". That is not her question.
  //  Hers is closer to "what happens now" and "was this my fault", and the
  //  field is used to answer those instead.
  PvRead(
    id: 'ttc_read_loss_recovery',
    hue: 26,
    kicker: _en('After a loss'),
    title: _en('Physical recovery, in plain terms'),
    teaser: _en("What your body does over the next few weeks, what's normal, "
        'and the few things that need a doctor today.'),
    shortAnswer: _en('Bleeding usually lasts one to two weeks and then '
        'settles. The pregnancy hormone takes a few weeks to clear, and your '
        'first period usually comes four to eight weeks later. Most of this '
        'needs no treatment, and none of it is something you caused.'),

    scaleSetter: _en('Most of what follows is bleeding that settles, hormones '
        'that fall, and a cycle that starts again. It usually takes a few '
        'weeks. Very little of it needs treatment. None of it is something '
        'you caused.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    heroVideoSlot: 'ttc_vid_loss_recovery',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('This page is only about your body. The physical side is the '
              'part nobody explains, and the part that brings the most fear '
              'at two in the morning.'),
          _en("The rest of it, the part that isn't about the body, has no "
              "timeline. It isn't on this page."),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): the three ways a miscarriage is
      // managed, explained so she can take part in the choice. The choice
      // itself stays with her and her doctor; nothing here ranks them.
      PvReadSection(
        heading: _en('How is a miscarriage managed?'),
        paragraphs: [
          _en("If the pregnancy hasn't fully passed on its own, there are "
              'usually three ways forward. Each is safe for most women, and '
              'your doctor will talk them through with you.'),
          _en('Which suits you depends on how far along you were, how much '
              "you're bleeding, your health and what you'd prefer. You can ask "
              'for time to think, and you can change your mind if waiting '
              'becomes too hard.'),
        ],
        bullets: [
          _en('Waiting: letting the pregnancy pass on its own, often within a '
              'week or two. You stay at home, with a number to call if you '
              'need it.'),
          _en('Tablets: misoprostol, sometimes with mifepristone first, help '
              'it pass. They can be taken at home or in hospital.'),
          _en('A small procedure: vacuum aspiration, or a D&C, removes it in '
              'one visit. Bleeding afterwards is often lighter and shorter.'),
        ],
        tip: PvReadTip(
          title: _en('Checking that it is complete'),
          body: _en('After waiting or tablets, you will usually be asked to do '
              'a home pregnancy test about three weeks later. If it is still '
              "positive, call your doctor. It often just needs a check, but "
              "it shouldn't be left."),
        ),
      ),

      PvReadSection(
        heading: _en('How long does the bleeding last?'),
        paragraphs: [
          _en("Bleeding usually lasts one to two weeks. It's heavier than a "
              'period at first, then slowly eases. Cramping in the first few '
              'days is expected, and it can be strong.'),
          _en('How it goes depends on how it was managed. If it happened on '
              'its own, bleeding tends to be heaviest early on. If you took '
              'medicine, bleeding usually starts within a few hours of the '
              'second dose.'),
          _en('If you had a surgical procedure (a D&C, or vacuum '
              'aspiration), bleeding is often lighter and shorter than with '
              'either of the others.'),
          _en('Some spotting on and off for another week or two after the main '
              "bleeding stops is common. It isn't a sign that something has "
              'gone wrong.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why is my pregnancy test still positive?'),
        paragraphs: [
          _en('hCG, the pregnancy hormone, falls slowly over days to weeks. A '
              'home test can stay positive for two to four weeks afterwards, '
              'sometimes longer.'),
          _en("This can hurt a lot if you don't expect it, so it helps to "
              'know now. A positive test after a loss is almost always the '
              "hormone clearing, not a pregnancy that's still going."),
          _en('If you '
              "test at all, it's better to do it because a doctor asked you "
              'to than out of hope at home.'),
          _en('Sore breasts and nausea usually ease within about a week as the '
              'levels fall. Some people find it hard when these fade, and '
              "that's not unusual."),
        ],
      ),

      PvReadSection(
        heading: _en('When will my period come back?'),
        paragraphs: [
          _en('Your first period usually comes four to eight weeks after the '
              "loss, counting from when the bleeding began. It's often "
              'heavier than usual, sometimes with more clots, and it can hurt '
              "more. That's expected, and it settles over the next cycle or "
              'two.'),
          _en('Ovulation often comes back before that first period, usually '
              'around two to four weeks after the loss. So you can get '
              "pregnant again before you've had a period at all."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("If you're not ready yet"),
          body: _en('Because ovulation can come back before your first '
              "period, it's worth using contraception if you don't want to "
              "conceive yet. This isn't often mentioned, and it's kinder to "
              'read it here than to find out later.'),
        ),
      ),

      PvReadSection(
        heading: _en('What if you had a procedure?'),
        paragraphs: [
          _en('After a D&C or vacuum aspiration, the usual advice is to put '
              'nothing in the vagina for around two weeks while the cervix '
              'closes. That means no tampons, menstrual cups or sex. Swimming '
              'and baths usually count too. Showers are fine.'),
          _en('Light activity is fine as soon as you feel up to it. There is '
              'no evidence that extra rest helps you recover, and no evidence '
              'that normal movement harms it.'),
          _en('A follow-up appointment is normal, and worth keeping even if '
              "you feel fine in your body. It's where anything left behind "
              "gets picked up. It's also where you can start talking about "
              'what happens next, if you want to.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Real and worth having, and reading it on day two is not
        // what most people need. The fold is care, not omission.
        collapsible: true,
        summary: _en('Rh status, and what happens if some tissue is left '
            'behind. These are the two follow-ups that get missed.'),
        heading: _en('Two things that get missed'),
        paragraphs: [
          _en('Rh status. If your blood group is Rh negative, you may need an '
              'anti-D injection after a pregnancy loss. The timing matters: '
              'usually within seventy-two hours. It protects future '
              'pregnancies, not this one. If nobody has mentioned your blood '
              'group, ask.'),
          _en('Retained tissue. Sometimes a little pregnancy tissue stays '
              "behind. It shows up as bleeding that doesn't settle, bleeding "
              "that starts again heavily after stopping, or a test that's "
              'still positive weeks later.'),
          _en('A scan finds it easily, and it is '
              "easy to treat. It's the most common reason recovery takes "
              'longer than expected.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): the rarer complications. Folds
      // for the same reason as the section above: real, and not what most
      // people need on day two.
      PvReadSection(
        collapsible: true,
        summary: _en('Infection and scarring inside the womb. Both are rare, '
            'both can be treated, and the signs are worth knowing.'),
        heading: _en('Are there rarer problems to know about?'),
        paragraphs: [
          _en('A few problems are rare, and it helps to know their names '
              'without worrying about them. Infection can follow any kind of '
              'miscarriage. That is why a fever or a bad-smelling discharge '
              'needs a doctor the same day.'),
          _en('Very rarely, usually after a procedure, the lining of the womb '
              "scars and sticks together. This is called Asherman's syndrome. "
              "The sign is periods that become very light or don't come back."),
          _en('It can be treated, and it matters if you want to try again. So '
              "if your period hasn't returned within about eight weeks, or "
              'comes back much lighter than before, tell your doctor.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Did anything I did cause this?'),
        answer: _en('No. Most early losses are caused by a chromosome error '
            "that was there from the very beginning. It's a random event in a "
            "single cell. It isn't inherited, and nothing either of you did "
            'made it happen. Working, exercise, lifting, stress, an argument, '
            'travel, sex, a missed vitamin: none of these cause a miscarriage. '
            'Almost everyone asks this, and the answer is the same every '
            'time.'),
      ),
      PvReadFaq(
        question: _en('How long until my body feels normal again?'),
        answer: _en('Most people feel physically better within two to four '
            'weeks. You may feel tired for longer than you expect, because '
            'any bleeding drains you, and grief is tiring for the body too. '
            'If you were further along, it takes longer.'),
      ),
      PvReadFaq(
        question: _en('Is it normal that my milk came in?'),
        answer: _en('After a later loss, yes. It can be very upsetting when '
            "you don't expect it. It settles over a few days. A firm bra, "
            'cold compresses and not expressing milk are the usual advice. If '
            "it's severe, there's medicine that can help, so ask."),
      ),
      PvReadFaq(
        question: _en('When can we have sex again?'),
        answer: _en('Physically, once the bleeding has stopped and about two '
            'weeks have passed since any procedure, to let the cervix close. '
            "After that there's no medical reason to wait. Often there's a "
            "reason that has nothing to do with medicine, and that's okay "
            'too.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go to a hospital today, not tomorrow'),
      body: _en('Soaking through more than two thick pads in an hour, for two '
          'hours in a row. Passing clots bigger than a lemon. A fever above '
          "38°C. Severe pain that painkillers don't touch, or pain in the tip "
          'of one shoulder. Discharge that smells bad. Feeling faint, or '
          'fainting. These are signs of heavy bleeding or infection. Both can '
          'be treated, and neither should wait for a morning appointment. '
          'Trust yourself on this. If something feels wrong, get seen.'),
    ),

    evidence: _en('Bleeding length, hCG clearing, ovulation returning before '
        'the first period, and the four-to-eight-week window for periods to '
        'return follow standard early pregnancy loss guidance from NICE, RCOG '
        'and the American Pregnancy Association. The three ways of managing '
        'a miscarriage, and the pregnancy test about three weeks later, follow '
        'NICE NG126 (ectopic pregnancy and miscarriage). Infection and '
        "Asherman's syndrome as rare complications follow RCOG patient "
        'information on miscarriage. Anti-D timing follows standard obstetric '
        'practice. Sources checked September 2026.'),

    nextSteps: [
      // ⚠️ COMMUNITY FIRST, AND NO PRODUCT ROW OF ANY KIND. The workbook marks
      // products, tools, activities and course all "Not a fit" on this
      // bracket. The one layer it actively wants is a person.
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('On trying again'),
        value: _en("When it's safe, what the evidence says about waiting, and "
            'who decides.'),
        surfaceId: 'ttc_read/ttc_read_trying_again',
      ),
      // Community held back for launch (2026-09-26, TTC gap plan §7.1) — kept for revert.
      // PvReadNextStep(
      //   kind: PvNextKind.activity,
      //   title: _en('Others who have been here'),
      //   value: _en("People who've been through this too, whenever you want "
      //       'them. Or not at all.'),
      //   surfaceId: 'ttc_community',
      // ),
    ],

    readNext: ['ttc_read_trying_again', 'ttc_read_miscarriage_causes'],
  ),


  // ===========================================================================
  //  AFTER A LOSS — "when it is safe to try again", and the emotional half
  // ===========================================================================
  //  ⚠️ NO HERO VIDEO ON THIS ONE, DELIBERATELY, and it is the only read in the
  //  library without one. A play control at the top of a page about whether she
  //  is ready to try again is the wrong texture — it makes the page feel
  //  produced at the moment it most needs to feel written. The physical
  //  recovery piece carries the film for this bracket; this one is words.
  //
  //  ⚠️ THE CORRECTION IN HERE IS WORTH DEFENDING. Many Indian clinicians still
  //  say wait three to six months, on the strength of a WHO recommendation from
  //  2007 that rests on a single study. Larger cohorts since have not found the
  //  harm it assumed. Saying so is not contradicting her doctor — CLAUDE.md
  //  forbids that, and this page does not tell her to ignore anyone. It tells
  //  her the question is open, so that she can ask it rather than assume the
  //  waiting is settled fact.
  PvRead(
    id: 'ttc_read_trying_again',
    hue: 26,
    kicker: _en('After a loss'),
    title: _en('On trying again'),
    teaser: _en('What the evidence says about waiting, what your body needs, '
        'and the part no evidence can answer.'),
    shortAnswer: _en("For an early loss with no complications, there's no "
        'medical reason to wait months. Many doctors suggest waiting for one '
        'period, so the next pregnancy is easier to date. Most women who lose '
        'a pregnancy later carry a healthy one, and when you feel ready is '
        'yours to decide.'),

    scaleSetter: _en('There are two questions here, and they often get mixed '
        "up. When it's safe for your body is a medical question with a fairly "
        "clear answer. When you're ready isn't a medical question at all. "
        'Nobody, including us, gets to answer that one for you.'),

    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),

    sections: [
      PvReadSection(
        heading: _en('Where did the advice to wait six months come from?'),
        paragraphs: [
          _en('Many people are told to wait three to six months. That advice '
              'goes back to a World Health Organization recommendation from '
              '2007, which was based mostly on a single study.'),
          _en("Larger studies since then haven't found the harm it assumed. A "
              'Norwegian study of nearly seventy-three thousand pregnancies '
              'found no higher risk of complications when women conceived '
              'within six months of a miscarriage. Some analyses even found '
              'slightly better outcomes in that group, not worse.'),
          _en('So for an early loss with no complications, the current view '
              "is that there's no medical reason to wait months. Many doctors "
              'now suggest waiting for one normal period. The reason is '
              'practical, not protective: it makes the next pregnancy much '
              'easier to date.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('If your doctor has told you to wait'),
          body: _en('There may be a specific reason, such as a later loss, an '
              'infection, a procedure, a molar pregnancy, or something in your '
              "own history. Ask what the reason is, rather than assuming it's "
              "the general advice. If it is the general advice, it's fair to "
              "say you've read that the evidence has changed. This page isn't "
              'a reason to ignore your own doctor.'),
        ),
      ),

      PvReadSection(
        heading: _en("It almost certainly couldn't have been prevented"),
        paragraphs: [
          _en('Around one in five to one in four known pregnancies ends in '
              'miscarriage. Most early losses are caused by a chromosome error '
              "that was there from the moment of fertilisation. It isn't "
              "inherited. It isn't caused. Nothing anyone could have done "
              'differently would have prevented it.'),
          _en('This matters when you think about trying again. Many people '
              'privately believe something was done wrong and must now be done '
              "right. Usually there's nothing to correct."),
          _en('It also means that after one loss, the outlook for a next '
              'pregnancy is much the same as it was before. One miscarriage '
              "isn't a pattern."),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): the population figures she is
      // looking for. Population only, never a figure for her, and the drop
      // with age and more losses is said rather than hidden.
      PvReadSection(
        heading: _en('Will it happen again?'),
        paragraphs: [
          _en('This is the question almost everyone asks, and the answer is '
              'mostly reassuring. Most women who lose a pregnancy go on to '
              'carry a healthy one later.'),
          _en('The risk does rise a little with each loss, which is why tests '
              'start after two. But even after three or more losses with no '
              'cause found, about three in four women go on to have a baby, '
              'with supportive care and early scans rather than special '
              'treatment.'),
          _en("These are figures for large groups of women, not a forecast "
              'for you. They are lower with age and with more losses, and '
              'that is part of what a specialist looks at.'),
        ],
      ),

      PvReadSection(
        heading: _en('When should you ask for tests?'),
        paragraphs: [
          _en('After two losses. ESHRE, the European fertility society, moved '
              'this line. Recurrent pregnancy loss now means two or more '
              'losses, not always one after the other, and tests can '
              'reasonably start there.'),
          _en("This change is worth knowing, because in many places older "
              "practice still waits for three. If you've had two and are told "
              'to try again before anything is checked, asking about the '
              "two-loss threshold is a fair question. You're not being "
              'demanding.'),
          _en('Tests usually look at hormones including thyroid, '
              'antiphospholipid antibodies, the shape of the uterus, and, '
              'depending on the picture, chromosome tests for both of you.'),
          _en('A cause is found in about half of couples. In the half where '
              'nothing is found, more often than not couples still go on to '
              'have a baby.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): what genetic counselling is,
      // because the tests above can lead to it and the word alone frightens.
      PvReadSection(
        heading: _en('What is genetic counselling?'),
        paragraphs: [
          _en('In a small number of couples with repeated losses, one partner '
              'carries a change in how their chromosomes are arranged. The '
              'most common is a balanced translocation, where two chromosomes '
              'have swapped pieces.'),
          _en('The person carrying it is healthy, because nothing is missing. '
              'But some pregnancies receive an unbalanced set, and those are '
              'more likely to end early.'),
          _en('If a test finds this, you will usually be offered genetic '
              'counselling. A specialist explains what the result means, the '
              'options for a next pregnancy, and whether other family members '
              'might want testing. It is a conversation, not a decision you '
              'have to make in the room.'),
        ],
      ),

      PvReadSection(
        heading: _en('When will you feel ready?'),
        paragraphs: [
          _en("There's no right amount of time. Being ready sooner or later "
              "doesn't say anything about you."),
          _en('Some people want to try straight away, and find that trying '
              'again is what makes the waiting bearable. Some can\'t face it '
              'for a long time.'),
          _en("Some couples find they don't want the same thing at the same "
              "time. That's common, and it's better said out loud than worked "
              'out in silence.'),
          _en('It also helps to know that a pregnancy after a loss often feels '
              'frightening rather than happy, especially until you pass the '
              "point where the last one ended. That isn't a bad sign, and it "
              "isn't ingratitude. It's very common, doctors have a name for "
              'it, and it usually eases.'),
        ],
      ),

      // ⚠️ ADDED 2026-09-26 (TTC gap plan): the next pregnancy's mixed
      // feelings, with the few practical things that help. Quiet, like the
      // rest of this bracket.
      PvReadSection(
        heading: _en('How might the next pregnancy feel?'),
        paragraphs: [
          _en('A baby after a loss is sometimes called a rainbow baby. Many '
              'women expect relief and find fear alongside it. You may not want '
              "to tell anyone for a while, or feel you can't enjoy it until a "
              'certain week has passed.'),
          _en("All of that is normal. It doesn't take anything away from this "
              'baby, or from the one you lost.'),
          _en('A few things can help. Tell your doctor about the loss at the '
              'first visit, so they know. Ask whether an early scan is '
              'possible. And take it one appointment at a time, rather than '
              'the whole nine months at once.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Practical, and not everyone wants it.
        collapsible: true,
        summary: _en("What to do differently next time. It's a short list, "
            'shorter than the internet suggests.'),
        heading: _en('If and when you do try again'),
        paragraphs: [
          _en('Start folic acid again if you stopped, and keep taking it. Get '
              'any long-term condition checked, such as thyroid, diabetes or '
              'blood pressure, because keeping it under control matters more '
              'before conception than after. And if either of you smokes, '
              'stopping is the change with the clearest evidence behind it.'),
          _en("Beyond that, the honest list is short. Most of what's sold or "
              'suggested after a loss (supplements, aspirin, progesterone, '
              'cutting back on activity) has no evidence behind it, or only '
              'helps in specific diagnosed situations. Progesterone has a real '
              "but narrow role. It isn't a general precaution."),
          _en("You don't need to do more than this. Doing more won't make it "
              'more likely to work.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Should I wait for one period, or can we try straight '
            'away?'),
        answer: _en("For an early loss with no complications, there's no "
            'strong physical reason to wait beyond the bleeding stopping. '
            'Waiting for one period makes the next pregnancy easier to date, '
            "which is why it's usually suggested. Either choice is fine."),
      ),
      PvReadFaq(
        question: _en('Are we more likely to lose another one?'),
        answer: _en('After a single loss, the chance for a next pregnancy is '
            "close to what it was before. One loss doesn't make a pattern. "
            'Things change after two or more, which is exactly why testing '
            'starts there.'),
      ),
      PvReadFaq(
        question: _en('My partner seems fine. Is that normal?'),
        answer: _en("It's common, and it's often not what it looks like. "
            'After a loss, two people often grieve at different times. One '
            'feels it early and one later, and the one who seems fine is '
            "often holding it together on purpose. It's worth asking, rather "
            'than deciding what it means.'),
      ),
      PvReadFaq(
        question: _en("I don't want to try again. Is that okay?"),
        answer: _en('Yes. Not trying again is a whole and valid choice. It '
            "isn't a failure to recover, and it doesn't need to be forever "
            'to be respected right now.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to ask for more help'),
      body: _en("Ask for a referral if you've had two or more losses, if a "
          'loss happened after twelve weeks, if it was ectopic or molar, or if '
          'you have a known condition like thyroid disease or a clotting '
          'disorder. And talk to someone (a counsellor, your doctor, anyone) '
          "if the grief isn't easing at all after several weeks, if you "
          "can't sleep or get through the day, or if you have thoughts of "
          "harming yourself. That last one isn't a reason to wait for an "
          "appointment. It's a reason to tell someone today."),
    ),

    evidence: _en('The six-month wait comes from a 2007 WHO recommendation '
        'based on limited evidence. The finding of no higher risk with a '
        'shorter wait is from a Norwegian cohort study of about 73,000 '
        'pregnancies after miscarriage or induced abortion (2008 to 2016), '
        'published in PLOS Medicine, and matches later systematic reviews. '
        'The two-loss threshold for tests, and genetic counselling after a '
        'chromosome finding, follow the ESHRE guideline on recurrent '
        'pregnancy loss (2022). The outlook after unexplained recurrent '
        'miscarriage with supportive care follows RCOG Green-top Guideline '
        'No. 17. Sources checked September 2026.'),

    nextSteps: [
      // Community held back for launch (2026-09-26, TTC gap plan §7.1) — kept for revert.
      // PvReadNextStep(
      //   kind: PvNextKind.activity,
      //   title: _en('Others who have been here'),
      //   value: _en("People who've been through this too, whenever you want "
      //       'them. Or not at all.'),
      //   surfaceId: 'ttc_community',
      // ),
      // ⚠️ THE ONE PAID THING THIS BRACKET ALLOWS, AND IT IS NAMED AS A PERSON.
      // The workbook wants counselling and a gynae here — the only layer it
      // actively asks for. It is placed last, described as a conversation, and
      // carries no price in its blurb.
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to someone who helps with this'),
        value: _en('A counsellor who works with pregnancy loss, or a doctor '
            'who can look at what happened. At your own pace.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: [
      'ttc_read_loss_recovery',
      'ttc_read_recurrent_miscarriage',
      'ttc_read_loss_feelings',
    ],
  ),
];
