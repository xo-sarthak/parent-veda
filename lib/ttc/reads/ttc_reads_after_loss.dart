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
    teaser: _en('What the body does over the next few weeks, what is normal, '
        'and the small number of things that need a doctor today.'),

    scaleSetter: _en('Most of what follows is bleeding that settles, hormones '
        'that fall, and a cycle that starts again. It usually takes a few '
        'weeks. Very little of it needs intervention, and none of it is '
        'something you caused.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    heroVideoSlot: 'ttc_vid_loss_recovery',

    sections: [
      PvReadSection(
        paragraphs: [
          _en('This page is only about the body. It is here because the '
              'physical side is the part nobody explains and the part that '
              'generates the most fear at two in the morning.'),
          _en('The rest of it — the part that is not about the body — does not '
              'have a timeline and is not on this page.'),
        ],
      ),

      PvReadSection(
        heading: _en('The bleeding'),
        paragraphs: [
          _en('Bleeding usually lasts one to two weeks, heavier than a period '
              'at first and then tapering. Cramping through the first few days '
              'is expected, and can be strong.'),
          _en('How this went depends on how it was managed. If it happened on '
              'its own, bleeding tends to be heaviest early. If you took '
              'medication, it usually begins within a few hours of the second '
              'dose. If you had a surgical procedure — a D&C, or vacuum '
              'aspiration — bleeding is often lighter and shorter than either '
              'of the others.'),
          _en('Some spotting on and off for another week or two after the main '
              'bleeding stops is common and is not a sign that something has '
              'gone wrong.'),
        ],
      ),

      PvReadSection(
        heading: _en('Hormones, and the pregnancy test'),
        paragraphs: [
          _en('hCG — the pregnancy hormone — falls over days to weeks rather '
              'than immediately. A home test can stay positive for two to four '
              'weeks afterwards, sometimes longer.'),
          _en('This catches people badly, and it is worth knowing in advance: '
              'a positive test after a loss is almost always the hormone '
              'clearing, not a continuing pregnancy. If you are going to test '
              'at all, it is better done because a doctor asked for it than '
              'out of hope at home.'),
          _en('Breast tenderness and nausea usually ease within about a week '
              'as the levels fall. Some people find that these fading is its '
              'own kind of difficult, and that is not unusual.'),
        ],
      ),

      PvReadSection(
        heading: _en('When the cycle comes back'),
        paragraphs: [
          _en('The first period usually arrives four to eight weeks after the '
              'loss, counting from when the bleeding began. It is often '
              'heavier than usual, sometimes with more clotting, and it can be '
              'more painful. That is expected and it settles over the next '
              'cycle or two.'),
          _en('Ovulation typically returns before that first period — often '
              'around two to four weeks after the loss — which means pregnancy '
              'is possible again before you have had a period at all.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Which matters if you are not ready'),
          body: _en('Because ovulation can return before the first period, it '
              'is worth using contraception if you would not want to conceive '
              'yet. This is not usually mentioned, and finding out afterwards '
              'is worse than reading it here.'),
        ),
      ),

      PvReadSection(
        heading: _en('If you had a procedure'),
        paragraphs: [
          _en('After a D&C or vacuum aspiration, the usual advice is to avoid '
              'putting anything in the vagina — tampons, menstrual cups, sex — '
              'for around two weeks, while the cervix closes. Swimming and '
              'baths are usually included in that; showers are fine.'),
          _en('Light activity is fine as soon as you feel able. There is no '
              'evidence that resting more improves recovery, and no evidence '
              'that ordinary movement harms it.'),
          _en('A follow-up appointment is normal practice and worth keeping '
              'even if you feel physically fine — it is where anything '
              'incomplete gets picked up, and where the conversation about '
              'what happens next can start if you want it to.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Real and worth having, and reading it on day two is not
        // what most people need. The fold is care, not omission.
        collapsible: true,
        summary: _en('Rh status, and what happens if some tissue is left '
            'behind — the two follow-ups that get missed.'),
        heading: _en('Two things that get missed'),
        paragraphs: [
          _en('Rh status. If your blood group is Rh negative, you may need an '
              'anti-D injection after a pregnancy loss, and the timing matters '
              '— usually within seventy-two hours. It protects future '
              'pregnancies rather than this one. If nobody has mentioned your '
              'blood group, ask.'),
          _en('Retained tissue. Occasionally some pregnancy tissue stays '
              'behind, which shows up as bleeding that does not settle, '
              'bleeding that restarts heavily after stopping, or a persistent '
              'positive test weeks later. It is straightforward to diagnose '
              'with a scan and straightforward to treat, and it is the '
              'commonest reason a recovery takes longer than expected.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Did anything I did cause this?'),
        answer: _en('No. The great majority of early losses are caused by a '
            'chromosomal error present from the beginning — a random event in '
            'a single cell, not something inherited and not something either '
            'of you influenced. Working, exercising, lifting, stress, an '
            'argument, travel, sex, a missed vitamin: none of these cause '
            'miscarriage. This question is asked by almost everyone, and the '
            'answer is the same every time.'),
      ),
      PvReadFaq(
        question: _en('How long until I feel physically normal?'),
        answer: _en('Most people feel physically recovered within two to four '
            'weeks, and tired for longer than they expect — bleeding of any '
            'length is depleting, and grief is physically exhausting on its '
            'own. If you were further along, it takes longer.'),
      ),
      PvReadFaq(
        question: _en('Is it normal that my milk came in?'),
        answer: _en('After a later loss, yes, and it can be very distressing '
            'when it is not expected. It settles over a few days. A firm bra, '
            'cold compresses and avoiding expressing are the usual advice, and '
            'there is medication that can help if it is severe — ask.'),
      ),
      PvReadFaq(
        question: _en('When can we have sex again?'),
        answer: _en('Physically, once bleeding has stopped and any procedure '
            'has had about two weeks — the usual advice is to wait for the '
            'cervix to close. Beyond that there is no medical reason to wait, '
            'and there is often a reason that has nothing to do with '
            'medicine.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go to a hospital today, not tomorrow'),
      body: _en('Soaking through more than two thick pads in an hour for two '
          'hours running, or passing clots larger than a lemon. A fever above '
          '38°C. Severe pain that painkillers do not touch, or pain in one '
          'shoulder tip. Discharge that smells offensive. Feeling faint, or '
          'fainting. These are signs of heavy bleeding or infection, both of '
          'which are treatable and neither of which should wait for a morning '
          'appointment. Trust yourself on this — if something feels wrong, be '
          'seen.'),
    ),

    evidence: _en('Bleeding duration, hCG clearance, return of ovulation '
        'before the first period, and the four-to-eight-week window for '
        'menstruation returning reflect standard early-pregnancy-loss guidance '
        'as described by NICE, RCOG and the American Pregnancy Association. '
        'Anti-D prophylaxis timing per standard obstetric practice. Reviewed '
        'August 2026.'),

    nextSteps: [
      // ⚠️ COMMUNITY FIRST, AND NO PRODUCT ROW OF ANY KIND. The workbook marks
      // products, tools, activities and course all "Not a fit" on this
      // bracket. The one layer it actively wants is a person.
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('On trying again'),
        value: _en('When it is safe, what the evidence actually says about '
            'waiting, and who decides.'),
        surfaceId: 'ttc_read/ttc_read_trying_again',
      ),
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en('Others who have been here'),
        value: _en('People who have been exactly here, whenever you want '
            'them. Or not at all.'),
        surfaceId: 'ttc_community',
      ),
    ],

    readNext: ['ttc_read_trying_again'],
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

    scaleSetter: _en('There are two questions here and they get muddled '
        'together. When is it physically safe is a medical question with a '
        'reasonably clear answer. When are you ready is not a medical question '
        'at all, and nobody — including us — gets to answer it for you.'),

    author: _en('Dr. Ananya Rao'),
    authorRole: _en('Gynaecologist · 14 years · reviewed August 2026'),

    sections: [
      PvReadSection(
        heading: _en('The six-month advice, and where it came from'),
        paragraphs: [
          _en('Many people are told to wait three to six months. That advice '
              'traces back to a World Health Organization recommendation from '
              '2007, which rested largely on a single study.'),
          _en('Larger studies since have not found the harm it assumed. A '
              'Norwegian cohort of nearly seventy-three thousand pregnancies '
              'found no increased risk of complications when women conceived '
              'within six months of a miscarriage — and some analyses have '
              'found slightly better outcomes in that group, not worse.'),
          _en('So the current position, for an early loss with no '
              'complications, is that there is no medical reason to wait '
              'months. Many clinicians now suggest waiting for one normal '
              'period, and the reason is practical rather than protective: it '
              'makes dating a next pregnancy much easier.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('If your doctor has told you to wait'),
          body: _en('There may be a specific reason — a later loss, an '
              'infection, a procedure, a molar pregnancy, or something in your '
              'own history. Ask what the reason is rather than assuming it is '
              'the general advice. If it is the general advice, it is '
              'reasonable to say you have read that the evidence has moved. '
              'This page is not a reason to disregard your own doctor.'),
        ),
      ),

      PvReadSection(
        heading: _en('It was almost certainly not preventable'),
        paragraphs: [
          _en('Around one in five to one in four recognised pregnancies ends '
              'in miscarriage, and the great majority of early losses are '
              'caused by a chromosomal error present from the moment of '
              'fertilisation. Not inherited. Not caused. Not preventable, by '
              'anything anyone could have done differently.'),
          _en('This matters for trying again specifically, because the most '
              'common private theory is that something was done wrong and must '
              'now be done right. There is usually nothing to correct.'),
          _en('It also means that after one loss, the odds for a next '
              'pregnancy are essentially what they were before. A miscarriage '
              'is not a pattern.'),
        ],
      ),

      PvReadSection(
        heading: _en('When investigation is worth asking for'),
        paragraphs: [
          _en('After two losses. ESHRE moved this threshold — recurrent '
              'pregnancy loss is now defined as two or more, not necessarily '
              'consecutive, and investigation can reasonably start there.'),
          _en('That is a change worth knowing about, because older practice '
              'in many places still waits for three. If you have had two and '
              'are told to try again before anything is looked into, asking '
              'about the two-loss threshold is a fair question rather than a '
              'demanding one.'),
          _en('Investigation typically looks at hormones including thyroid, '
              'antiphospholipid antibodies, the shape of the uterus, and — '
              'depending on the picture — chromosomal testing for both of you. '
              'A cause is found in about half of couples, and the half where '
              'nothing is found still go on to have live births more often '
              'than not.'),
        ],
      ),

      PvReadSection(
        heading: _en('The part that is not medical'),
        paragraphs: [
          _en('There is no correct interval, and there is no version of this '
              'where being ready sooner or later means anything about you.'),
          _en('Some people want to try immediately, and find that the next '
              'attempt is what makes the waiting bearable. Some cannot face it '
              'for a long time. Some find that the two of them do not want the '
              'same thing at the same time, which is common and is worth '
              'saying out loud rather than negotiating silently.'),
          _en('It is also worth knowing that a next pregnancy after a loss is '
              'often frightening rather than joyful, particularly up to the '
              'point where the previous one ended. That is not a bad sign and '
              'it is not ingratitude. It is extremely common, it has a name in '
              'the literature, and it usually eases.'),
        ],
      ),

      PvReadSection(
        // ⚠️ FOLDS. Practical, and not everyone wants it.
        collapsible: true,
        summary: _en('What to do differently next time — a short list, and a '
            'shorter one than the internet suggests.'),
        heading: _en('If and when you do try again'),
        paragraphs: [
          _en('Restart folic acid if you stopped, and keep taking it. Have any '
              'long-term condition — thyroid, diabetes, blood pressure — '
              'reviewed, because control matters more before conception than '
              'after it. And if either of you smokes, this is the change with '
              'the clearest evidence behind it.'),
          _en('Beyond that, the honest list is short. Most of what is sold and '
              'recommended after a loss — supplements, aspirin, progesterone, '
              'restricted activity — has either no evidence behind it or '
              'applies only to specific diagnosed situations. Progesterone in '
              'particular has a genuine but narrow role, and it is not a '
              'general precaution.'),
          _en('There is no need to do more than this, and doing more will not '
              'make it more likely to work.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Should I wait for one period, or can we try straight '
            'away?'),
        answer: _en('For an early, uncomplicated loss, physically there is no '
            'strong reason to wait beyond bleeding stopping. Waiting for one '
            'period makes dating a next pregnancy easier, which is the usual '
            'reason it is suggested. Either is reasonable.'),
      ),
      PvReadFaq(
        question: _en('Are we more likely to lose another one?'),
        answer: _en('After a single loss, the chance for a next pregnancy is '
            'close to what it was before — one loss does not make a pattern. '
            'The picture changes after two or more, which is exactly why the '
            'investigation threshold sits there.'),
      ),
      PvReadFaq(
        question: _en('My partner seems fine. Is that normal?'),
        answer: _en('Common, and it is very often not what it looks like. '
            'Grief after a loss is frequently asynchronous — one person '
            'processes early and one later, and the one who seems fine is '
            'often holding it together on purpose. It is worth asking rather '
            'than concluding.'),
      ),
      PvReadFaq(
        question: _en('I do not want to try again. Is that allowed?'),
        answer: _en('Yes. Not trying again is a whole and legitimate outcome, '
            'not a failure to recover, and it does not need to be permanent to '
            'be respected right now.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Some of this needs a person, not a page'),
      body: _en('Ask for a referral if you have had two or more losses, if a '
          'loss happened after twelve weeks, if it was ectopic or molar, or if '
          'you have a known condition like thyroid disease or a clotting '
          'disorder. And speak to someone — a counsellor, your doctor, anyone '
          '— if grief is not shifting at all after several weeks, if you '
          'cannot sleep or function, or if you have thoughts of harming '
          'yourself. That last one is not a reason to wait for an appointment; '
          'it is a reason to tell someone today.'),
    ),

    evidence: _en('The six-month interval originates in a 2007 WHO '
        'recommendation based on limited evidence; the absence of increased '
        'risk with a shorter interval is from a Norwegian cohort study of '
        'approximately 73,000 pregnancies following miscarriage or induced '
        'abortion (2008–2016), published in PLOS Medicine, and consistent with '
        'subsequent systematic reviews. The two-loss threshold for '
        'investigation follows the ESHRE guideline on recurrent pregnancy '
        'loss. Reviewed August 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en('Others who have been here'),
        value: _en('People who have been exactly here, whenever you want '
            'them. Or not at all.'),
        surfaceId: 'ttc_community',
      ),
      // ⚠️ THE ONE PAID THING THIS BRACKET ALLOWS, AND IT IS NAMED AS A PERSON.
      // The workbook wants counselling and a gynae here — the only layer it
      // actively asks for. It is placed last, described as a conversation, and
      // carries no price in its blurb.
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talking to someone who does this'),
        value: _en('A counsellor who works with pregnancy loss, or a doctor '
            'who can look at what happened. At your pace.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_loss_recovery'],
  ),
];
