// =============================================================================
//  Mind & body › Hard days — the reads for this tab
// -----------------------------------------------------------------------------
//  ⚠️ ONE FILE PER BRACKET, SO FIVE PEOPLE CAN BUILD FIVE DOORS AT ONCE.
//
//  Written 2026-09-26 for the TTC gap plan (docs/TTC-GAP-PLAN.md, stream A,
//  Mind & body › Hard days, P1). Six reads for the days trying hurts most: the
//  period arriving, someone else's announcement, whether to tell family, the
//  months when trying fills everything, the "koi good news?" question, and the
//  long run of months that don't work.
//
//  ⚠️ THESE ARE HELD, NOT LECTURED. Each opens on a scene she will recognise
//  (a godh bharai invite, the family WhatsApp group, a period at her desk),
//  names the feeling once, then gives the honest, kind fact. None of them may
//  hint that a bad month was her doing.
//
//  ⚠️ THE HELPLINE IS STATED ONE WAY EVERYWHERE. Tele-MANAS is the Government
//  of India's free national tele mental health service (Ministry of Health and
//  Family Welfare, with NIMHANS): 14416, or 1-800-891-4416, 24 hours a day, in
//  English and many Indian languages. The app's constant lives in
//  `lib/data/mind_mood_data.dart` (kCrisisHelplineNumber); if that number ever
//  changes, these strings change with it.
//
//  ⚠️ THE AGGREGATOR IS STILL THE ONLY PUBLIC ENTRY POINT. Nothing outside
//  `ttc_reads_data.dart` should import this file.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, ON PURPOSE. See ttc_reads_mind_body.dart.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsHardDays = [
  // ===========================================================================
  //  HARD DAYS — the day the period comes
  // ===========================================================================
  //  Gap analysis P1 "Coping with TTC disappointment". The chapter section
  //  "If the period arrives" touches this, but there was nothing she could
  //  find on the day itself. Population figures only (NICE CG156); no number
  //  is ever attached to her.
  PvRead(
    id: 'ttc_read_period_came',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('Your period came. What now?'),
    teaser: _en("What today means, what it doesn't, and a few small things "
        'that help you get to next month.'),
    shortAnswer: _en("A period means this cycle didn't lead to a pregnancy. "
        "It doesn't mean something is wrong, and it isn't something you "
        'caused. Today, be gentle with yourself, note day 1 in your log, and '
        'let next month wait a day or two.'),
    scaleSetter: _en("Most couples who get pregnant don't do it in the first "
        'month, or the second. A period after trying is the most common way '
        'any single month ends, even for couples with no fertility problem at '
        'all.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('You feel the cramp at your desk, or see the first spot of blood '
              "in the bathroom at home. Maybe it's right after you let "
              'yourself think this month felt different. For a lot of women, '
              'this is the hardest day of the month.'),
          _en("It's okay to need a moment, or a whole evening. Here's what "
              "this period does and doesn't mean, and a few small things that "
              'make the next few days easier.'),
        ],
      ),

      PvReadSection(
        heading: _en('What does a period this month tell me?'),
        paragraphs: [
          _en("It tells you this cycle didn't end in a pregnancy. That's all "
              "it tells you. It doesn't say anything is wrong with you, with "
              'your partner, or with how you tried.'),
          _en('Getting pregnant takes time for most healthy couples. NICE, the '
              'UK body that writes fertility guidance, says around 8 in 10 '
              'couples under 40 who have regular sex get pregnant within a '
              'year. Around 9 in 10 do within two years.'),
          _en('Almost every one of those couples had periods along the way. '
              "Many had several in a row. A period this month puts you in the "
              'same place as most people who go on to have a baby.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Something you did this month made your period come: the '
              'food, the stress, lifting something heavy, the long drive.'),
          fact: _en('Nothing you ate, carried or worried about brought this '
              'period on. Most months end in a period even when everything '
              'is working well. It is not your fault.'),
        ),
      ),

      PvReadSection(
        heading: _en('Why does it hurt this much?'),
        paragraphs: [
          _en("Every cycle when you're trying has a hopeful half. You count "
              'days, you notice every twinge, and part of you starts to '
              "picture it. So a period isn't only bleeding. It can feel like "
              "a small loss, and it's normal to grieve it."),
          _en('Many women feel sad, angry, flat or oddly calm, sometimes all '
              'in one day. Some feel a flash of envy at a friend, then guilt '
              "for feeling it. None of this means you're coping badly. It's "
              'what months of hoping feel like.'),
          _en('Your partner may feel it differently, or show it less. That '
              "doesn't mean it matters less to him. People grieve at "
              'different speeds, and it helps to say so out loud.'),
        ],
      ),

      PvReadSection(
        heading: _en('What can I do today?'),
        paragraphs: [
          _en("Keep today small. You don't need a plan yet. These are "
              'things that help most women on day 1, in roughly this order.'),
        ],
        bullets: [
          _en("1. Let yourself feel it. Cry, sleep early, cancel a plan. You "
              "don't have to be fine by the evening."),
          _en('2. Tell your partner in whatever way is easiest, even a short '
              'message. The day goes better when neither of you has to guess '
              'how the other is.'),
          _en('3. Note day 1 in your log. It takes a few seconds, and it means '
              'your next fertile days are worked out for you.'),
          _en('4. Look after the cramps with a hot-water bottle, rest, and a '
              "painkiller your doctor has already said is fine for you."),
          _en('5. Put off big decisions for a day or two, like changing '
              'doctors or buying a new kind of test.'),
        ],
        tip: PvReadTip(
          title: _en('Two lines in your journal'),
          body: _en('Write one line about how today felt, and one line about '
              "something that isn't about trying. Over a few months, the "
              'second line matters more than it seems.'),
        ),
      ),

      PvReadSection(
        heading: _en('What about next month?'),
        paragraphs: [
          _en('Give it a day or two before you plan. When you feel ready, your '
              'new cycle has already started. If your cycles are regular, your '
              'fertile days come round in about two weeks.'),
          _en("It can help to decide one thing only: what you'll keep doing, "
              "and what you'll let go. If testing every day felt heavy last "
              'month, you can stop.'),
          _en('Having sex every two or three days through the middle of your '
              'cycle covers your fertile days without any strips or counting. '
              'This is what NICE suggests for most couples, and it takes a lot '
              'of pressure off.'),
        ],
      ),

      PvReadSection(
        heading: _en('How do I get through the next few days?'),
        paragraphs: [
          _en('The first two or three days are usually the heaviest. If you '
              'can, keep them light. Skip the family dinner, order in, or '
              'leave work on time. You are allowed to protect these days the '
              'way you would after any sad news.'),
          _en('If you have to be around people, decide one thing to say if '
              'anyone asks why you seem low. "I\'m just tired this week" is '
              "enough. You don't owe anyone the real reason."),
          _en('Some women find it helps to do one small, ordinary thing that '
              'feels good: a walk in the evening, a favourite meal, an old '
              "film. It won't fix the day, but it reminds you that your life "
              'is bigger than this month.'),
          _en('By the end of the week, most women feel the edge soften a '
              "little. If it doesn't, or each month feels heavier than the "
              'last, that is worth talking about with someone.'),
        ],
      ),

      PvReadSection(
        heading: _en('Is this period different from usual?'),
        collapsible: true,
        summary: _en('A late, heavier period, or bleeding after a positive '
            'test, is worth telling your doctor about.'),
        paragraphs: [
          _en('Sometimes a period comes a few days late and heavier than '
              'usual, or after a faint positive test. That can be a very early '
              "pregnancy loss, often called a chemical pregnancy. Bleeding "
              "alone can't tell you which it was."),
          _en('If you had a positive test this cycle and then bled, tell your '
              'doctor. Most very early losses need no treatment, but your '
              "doctor should know. And it's okay to grieve it, even if few "
              'people knew.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Should I take a pregnancy test anyway?'),
        answer: _en("If you're bleeding like a normal period, there's usually "
            'no need. If the bleeding is much lighter or shorter than usual, '
            "or you're not sure, a home test from the chemist can settle it. "
            'Use the first urine of the morning.'),
      ),
      PvReadFaq(
        question: _en('Is it normal to feel angry at my own body?'),
        answer: _en('Yes, very. Your body is doing what bodies do most months, '
            "but it doesn't feel that way when you want something this much. "
            'The anger usually eases within a few days. If it stays, or turns '
            'into hating yourself, talk to someone.'),
      ),
      PvReadFaq(
        question: _en('How many periods before we should see a doctor?'),
        answer: _en("See a doctor after a year of trying if you're under 35, "
            "or after six months if you're 35 or older. Go sooner if your "
            'periods are irregular or very painful, or if either of you has a '
            'known health problem that can affect fertility.'),
      ),
      PvReadFaq(
        question: _en("My husband seems fine. Doesn't he care?"),
        answer: _en('Men often show disappointment differently: by going '
            'quiet, getting busy, or trying to fix things. Ask him how he is '
            "instead of guessing. You may find he's been waiting for you to "
            'go first.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to call a doctor, or someone to talk to'),
      body: _en('See a doctor within a few days if this period is much '
          'heavier than usual (soaking a pad every hour for a few hours), has '
          'large clots, or comes after a positive test. Go to a hospital today '
          'if you have severe pain on one side, pain in the tip of your '
          'shoulder, feel faint, or bleed heavily after a positive test. If '
          "the sadness hasn't lifted after two weeks, or you have thoughts of "
          'harming yourself, talk to someone now. Tele-MANAS, the Government '
          "of India's free mental health helpline, answers on 14416 at any "
          'hour.'),
    ),

    evidence: _en('How long couples usually take to conceive, and when to '
        'see a doctor, follow NICE guideline CG156 (Fertility problems: '
        'assessment and treatment) and ASRM. The emotional side follows the '
        'ESHRE guideline on routine psychosocial care in infertility and '
        'medically assisted reproduction. Tele-MANAS details are from the '
        'Ministry of Health and Family Welfare, Government of India. Sources '
        'checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log day 1'),
        value: _en('A few seconds today, and your next fertile days are '
            'worked out for you.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en('Write two lines'),
        value: _en('How today felt, and one thing that has nothing to do with '
            'trying.'),
        surfaceId: 'ttc_journal',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a psychologist'),
        value: _en('Someone who works with women going through these same '
            'months.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_month_after_month', 'ttc_read_others_news'],
  ),

  // ---------------------------------------------------------------------------
  //  HARD DAYS — someone else's announcement
  // ---------------------------------------------------------------------------
  //  Gap analysis P1 "Why is everyone else pregnant?" and P2 "Dealing with baby
  //  envy", clustered: they are the same feeling. Written for the Indian
  //  version of it, where the news arrives in a family group and the baby
  //  shower is an invitation you're expected to accept.
  PvRead(
    id: 'ttc_read_others_news',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en("When other people's pregnancy news is hard"),
    teaser: _en('Why the envy comes, why it doesn\'t make you a bad person, '
        'and what to do when the news arrives.'),
    shortAnswer: _en("Feeling sad or jealous when someone else is pregnant is "
        "very common when you're trying, and it doesn't mean you wish them "
        "anything bad. You're allowed to protect yourself: mute a group, send "
        'love instead of going, or ask for a day before you celebrate.'),
    scaleSetter: _en('Envy at other people\'s pregnancies is one of the most '
        "common feelings among women who are trying. It isn't a flaw in you. "
        "It's a sign of how much you want this."),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('The family WhatsApp group lights up. Your cousin has posted a '
              'scan photo, and within minutes there are rows of hearts and a '
              'voice note from your mother-in-law. You type congratulations, '
              'turn the phone face down, and feel something heavy in your '
              'chest.'),
          _en("If that's happened to you, you're far from alone. It's one of "
              'the hardest parts of trying, and one of the least talked about.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why does everyone else seem to be pregnant?'),
        paragraphs: [
          _en("Partly because you're noticing. When you want something, your "
              'mind picks it out everywhere: the bump in the lift, the pram in '
              'the park, the reel you never searched for.'),
          _en('And partly because many people your age are starting families, '
              'so the news really does come in waves. What you don\'t see is the '
              'people who are also waiting. WHO says about 1 in 6 people '
              'worldwide have trouble conceiving at some point.'),
          _en("Some of the couples you're comparing yourself with waited a "
              "long time too. People tend to share the scan, not the months "
              'before it.'),
        ],
      ),

      PvReadSection(
        heading: _en('Am I a bad person for feeling this?'),
        paragraphs: [
          _en('No. You can love your cousin and still feel a stab of pain at '
              'her news. Both are true at once, and neither cancels the '
              'other.'),
          _en("Envy here doesn't mean you want what she has taken away from "
              "her. It means you want it for yourself, and today it's a "
              'reminder of what you don\'t have yet. Guilt about the feeling '
              'usually hurts more than the feeling itself.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('A feeling is not an action'),
          body: _en('What matters is how you treat people, and most women in '
              'your place are kind to the pregnant friend while hurting '
              "inside. You don't need to feel happy to behave kindly."),
        ),
      ),

      PvReadSection(
        heading: _en('What can I do when the news arrives?'),
        paragraphs: [
          _en('You don\'t have to react straight away. A few small moves can '
              'give you time to catch your breath.'),
        ],
        bullets: [
          _en('1. Take a minute before you reply. A message sent an hour later '
              'is still a kind message.'),
          _en('2. Keep it short. "So happy for you both" is enough. Nobody '
              'expects a speech.'),
          _en('3. Let yourself feel it after. Step outside, call a friend who '
              'knows, or write it down.'),
          _en("4. Tell your partner that today was hard, so you aren't "
              'carrying it alone.'),
          _en('5. Do something kind for yourself that evening, even something '
              'small, like a long bath or an early night.'),
        ],
      ),

      PvReadSection(
        heading: _en("What if it's someone very close?"),
        paragraphs: [
          _en('News from a sister, a sister-in-law or your closest friend can '
              'hit hardest of all. You may have planned to be pregnant '
              'together, or thought your children would grow up side by side. '
              'Now that picture has changed, and that is a loss too.'),
          _en('You may also see her often, at family meals and on calls, so '
              'there is less room to step away. It can help to tell one person '
              'in the family how you feel, so someone understands if you are '
              'quieter than usual.'),
          _en('Being there for her does not have to mean being at every '
              'scan update and shopping trip. You can send a message, ask how '
              'she is feeling, and still keep some distance on the hard days.'),
        ],
      ),

      PvReadSection(
        heading: _en('How do I stop comparing?'),
        paragraphs: [
          _en('You probably can\'t stop the thought from coming. What you can '
              'do is notice it, and not follow it all the way down. "She got '
              'pregnant so fast, so something must be wrong with me" is a '
              'story, not a fact.'),
          _en("You don't know how long she tried, what she went through, or "
              'what the next months hold for her. Her timing tells you nothing '
              'about yours. Every couple starts from a different place.'),
        ],
      ),

      PvReadSection(
        heading: _en('Do I have to go to the godh bharai?'),
        paragraphs: [
          _en("You don't. A baby shower can be the hardest event of all, "
              'with the songs, the blessings and the questions. You can go for '
              'a short while, go and leave early, or send a gift with a warm '
              'message.'),
          _en('"I can\'t make it, but I\'m sending all my love" is a complete '
              'answer. If you do go, agree with your partner beforehand how '
              "long you'll stay and a signal for when you need to leave."),
          _en('Going and finding it too much is also fine. You can slip out '
              'after the blessings, message the mother-to-be later, and let '
              'that be enough.'),
        ],
      ),

      PvReadSection(
        heading: _en('Can I mute people for a while?'),
        paragraphs: [
          _en('Yes. Muting a group, snoozing someone on Instagram, or skipping '
              "the bump updates isn't rude. It's looking after yourself. They "
              'will never see it, and you can undo it any time.'),
          _en('With a close friend or sister, it can help to be honest. "I\'m '
              'so happy for you, and I\'m also finding this hard. Can you tell '
              'me news on my own, not in the group?" Most people are glad to '
              'be asked.'),
          _en('If a video call or a visit is planned soon after the news, it '
              'is okay to ask for a few days first. "Let me call you this '
              'weekend, I want to hear everything properly" buys you time and '
              'still sounds warm.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en("My sister is pregnant and I can't stop crying. What's "
            'wrong with me?'),
        answer: _en("Nothing. The closer the person, the harder it can hit, "
            'because you had pictured doing this together. Give yourself a '
            "few days. You'll find your way back to being glad for her, even "
            "if it isn't today."),
      ),
      PvReadFaq(
        question: _en('Should I tell a pregnant friend how I feel?'),
        answer: _en("Only if you want to, and only if you trust her with it. "
            'A good friend usually understands. If saying it would feel like '
            'too much, you can see her a little less for now.'),
      ),
      PvReadFaq(
        question: _en("What if someone hands me their baby and I don't want "
            'to hold it?'),
        answer: _en('You can smile and say "Oh, I\'ve just washed my hands for '
            'the kitchen", or "Let me watch her sleep for a bit." You never '
            'owe anyone a reason.'),
      ),
      PvReadFaq(
        question: _en('Does this get easier?'),
        answer: _en('For most women it comes and goes. Some news lands softly, '
            'and some knocks you over. Having a plan for the hard ones, and '
            'someone to tell, makes the bad days shorter.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When the hurt needs more than time'),
      body: _en('Talk to a psychologist if you find you\'re avoiding most '
          'people and places for weeks, if low mood or anxiety has lasted '
          "more than two weeks, or if you can't sleep or work properly. If you "
          'ever have thoughts of harming yourself, talk to someone today. '
          'Tele-MANAS, the Government of India\'s free mental health '
          'helpline, answers on 14416 (or 1-800-891-4416), at any hour, in '
          'many Indian languages.'),
    ),

    evidence: _en('The figure of about 1 in 6 people affected by infertility '
        'is from the WHO report on infertility prevalence (2023). Guidance on '
        'emotional support follows the ESHRE guideline on routine psychosocial '
        'care in infertility and medically assisted reproduction, and NICE '
        'guideline CG156. Tele-MANAS details are from the Ministry of Health '
        'and Family Welfare, Government of India. Sources checked September '
        '2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en('Write it down'),
        value: _en('Getting the feeling onto a page often takes some of its '
            'weight away.'),
        surfaceId: 'ttc_journal',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a psychologist'),
        value: _en('For the weeks when the news keeps coming and it all feels '
            'like too much.'),
        surfaceId: 'ttc_prepare',
      ),
    ],

    readNext: ['ttc_read_good_news_answers', 'ttc_read_telling_family'],
  ),

  // ---------------------------------------------------------------------------
  //  HARD DAYS — whether to tell anyone at all
  // ---------------------------------------------------------------------------
  //  Gap analysis P3 "Should you tell people you're TTC?" and P3 "Pre-baby
  //  socializing" (Talk pack), given their own read because the existing
  //  `ttc_read_family_asking` is about answering the question once it comes;
  //  this is the decision that comes before it. Linked both ways.
  PvRead(
    id: 'ttc_read_telling_family',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en("Should you tell family you're trying?"),
    teaser: _en('What telling people gives you, what it costs, and how to '
        'decide together.'),
    shortAnswer: _en("There's no right answer. Telling a few people can bring "
        'support, but it often brings monthly questions too. Many couples in '
        'India keep it private, tell one or two people they trust, and change '
        'their minds later. Decide together, and you can always tell people '
        'later.'),
    scaleSetter: _en("This is your decision as a couple, and it isn't a test "
        'of how close you are to your family. Whatever you choose now can be '
        'changed.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Your mother calls every Sunday. This week she asks about your '
              'health in a slightly different voice, and you wonder whether '
              'she has guessed. You want to tell her, and you also want this '
              'to stay yours for a while.'),
          _en('Both feelings make sense. Here\'s a way to think it through, '
              'so the decision is one you make together and not one that '
              'happens by accident.'),
        ],
      ),

      PvReadSection(
        heading: _en('What do we gain by telling people?'),
        paragraphs: [
          _en('Support, mainly. Someone who knows can check on you after a '
              'hard month, understand why you skipped the party, and keep '
              'others from asking. You stop having to act fine in front of '
              'them.'),
          _en("If you're seeing a doctor, a parent who knows can help with "
              'the practical side, like travel to appointments or time off '
              'from family duties.'),
          _en('Some women also find that telling one person takes away a '
              'strain they had not noticed: the effort of hiding it. Not '
              'having to invent a reason for skipping a festival or a fast can '
              'be a relief on its own.'),
        ],
      ),

      PvReadSection(
        heading: _en('And what does it cost?'),
        paragraphs: [
          _en('Once people know, the question changes from "any news?" to '
              '"did it work this month?" For some couples, that monthly check '
              'is harder than the silence was.'),
          _en('Advice tends to follow too: foods, prayers, fasts, a doctor '
              'someone\'s cousin went to. It\'s usually loving, and it can '
              'still be tiring. And news travels. What you tell one aunt may '
              'reach the whole family by the next festival.'),
        ],
        mythFact: PvMythFact(
          myth: _en('If you keep it private, you\'re hiding something or '
              "don't trust your family."),
          fact: _en("Keeping trying private is common and healthy. It's a "
              'choice about timing and privacy, not about love. Plenty of '
              'couples tell family only once there is news to share.'),
        ),
      ),

      PvReadSection(
        heading: _en('How do we decide together?'),
        paragraphs: [
          _en('Talk about it before a visit, not during one. Most hurt comes '
              'when one of you tells someone without knowing what the other '
              'wanted. These questions can help you both get clear.'),
        ],
        bullets: [
          _en('1. Who, if anyone, would you each want to know? Name people, '
              'not "family".'),
          _en('2. What would you want from them: support, help, or just not '
              'being asked?'),
          _en('3. Would you tell them only that you\'re trying, or also if '
              "you're seeing a doctor?"),
          _en("4. Should both sets of parents hear at the same time, so no "
              'one feels left out?'),
          _en('5. Who tells whom? It usually works best when each of you '
              'talks to your own family.'),
        ],
        tip: PvReadTip(
          title: _en('Start with one person'),
          body: _en('You don\'t have to choose between telling everyone and '
              'telling no one. One trusted person, a sister or a close friend, '
              'is often enough support without the whole family knowing.'),
        ),
      ),

      PvReadSection(
        heading: _en('If we do tell, how do we say it?'),
        paragraphs: [
          _en('Say what you want to share, and say what you need from them. '
              'Both parts matter. People who love you often want to help, and '
              "they can't if they don't know what helps."),
          _en('Pick a calm moment, not a festival or a crowded room. A '
              'one-to-one talk, or a call from the two of you together, keeps '
              'it from turning into a family discussion.'),
        ],
        bullets: [
          _en('"We\'ve started trying for a baby. We wanted you to know, and '
              'we\'d love your support. Please don\'t ask about it every month. '
              'We\'ll tell you when there\'s news."'),
          _en('"We\'re trying, and it\'s taking a while. We\'re fine, and we\'re '
              'looking after it. What would help most is not hearing advice '
              'from everyone."'),
          _en('"We\'re telling only you for now. Please keep it between us."'),
        ],
      ),

      PvReadSection(
        heading: _en("What if we're already seeing a doctor?"),
        paragraphs: [
          _en('That is a separate choice from telling people you are trying. '
              'Some couples tell family about trying but keep the tests and '
              'treatment private. Others share both, because they need help '
              'with travel, time off or money.'),
          _en('If you do share, you can keep it general: "We\'re seeing a '
              'doctor, and we\'re following her advice." You don\'t have to '
              'explain the tests, the results, or whose they are.'),
          _en('Keep in mind that medical details, once shared, can lead to '
              'questions about whose "problem" it is. That kind of talk helps '
              'nobody. Fertility is a matter for both partners, and you are '
              'allowed to keep that between the two of you.'),
        ],
      ),

      PvReadSection(
        heading: _en('What about friends and gatherings?'),
        paragraphs: [
          _en("You don't have to tell friends either. But it can help to "
              'have one friend outside the family who knows, so there\'s '
              'someone to message after a hard day.'),
          _en("It's also fine to skip some gatherings for a while. A cousin's "
              'baby naming or a friend\'s baby shower can wait. Choose the '
              'events that feel good, and let the others go without guilt.'),
        ],
      ),

      PvReadSection(
        heading: _en('What if we change our minds?'),
        paragraphs: [
          _en('You can. Many couples keep it private for the first months and '
              'tell a parent later, when it starts to feel heavy to carry '
              'alone. Others tell early and then ask people to stop asking.'),
          _en('"We\'d rather not talk about it for a while" is a fair thing to '
              'say to someone you told before. Most people will respect it '
              'once they hear it plainly.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Is it wrong to keep it from my own mother?'),
        answer: _en("No. You can be close to your mother and still keep this "
            "private for now. It isn't a lie to not share something yet. You "
            'can tell her whenever it feels right.'),
      ),
      PvReadFaq(
        question: _en('My husband told his mother without asking me. What now?'),
        answer: _en('It happens often, usually from excitement, not '
            "disrespect. Tell him how it felt, then agree on what's shared "
            "from here on. You can't untell it, but you can decide what she "
            'hears next.'),
      ),
      PvReadFaq(
        question: _en('Should we tell them if we start fertility treatment?'),
        answer: _en('Only if it helps you. Some couples find family help '
            'with appointments and costs is worth the questions. Others '
            'find treatment is easier with fewer people watching. Both are '
            'fine.'),
      ),
      PvReadFaq(
        question: _en('What if they have already guessed?'),
        answer: _en('You can confirm it without giving details: "Yes, and '
            'we\'ll tell you when there\'s news." That answers the guess and '
            'closes the topic at the same time.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When the family pressure is too much'),
      body: _en('Talk to someone if the pressure at home has become constant, '
          "if you're being blamed for not conceiving, or if you're afraid of "
          'anyone in your household. A psychologist in this app can help, and '
          "Tele-MANAS, the Government of India's free mental health helpline, "
          'answers on 14416 at any hour. If anyone threatens or hurts you, call '
          '181, the women\'s helpline, or 112 in an emergency.'),
    ),

    evidence: _en('This is emotional and practical guidance rather than '
        'medical advice. It follows the ESHRE guideline on routine '
        'psychosocial care in infertility and medically assisted '
        'reproduction, and NICE guideline CG156 on offering counselling and '
        'support. Helpline details are from the Ministry of Health and Family '
        'Welfare (Tele-MANAS) and the Ministry of Women and Child Development '
        '(181 Women Helpline), Government of India. Sources checked September '
        '2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Talk it through with your partner'),
        value: _en('Share what you both want before the next family visit.'),
        surfaceId: 'ttc_partner',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('When family keeps asking'),
        value: _en('Sentences that end the question kindly, once you\'ve '
            'decided what to share.'),
        surfaceId: 'ttc_read/ttc_read_family_asking',
      ),
    ],

    readNext: ['ttc_read_family_asking', 'ttc_read_good_news_answers'],
  ),

  // ---------------------------------------------------------------------------
  //  HARD DAYS — when trying fills everything
  // ---------------------------------------------------------------------------
  //  Plan: "When trying takes over your life". Also takes the Understand
  //  pack's P3 items on recognising stress and when tension becomes a
  //  problem, and the P3 note on acupuncture and similar therapies (stated as
  //  NICE CG156 states it: not properly evaluated, so not recommended; never
  //  mocked).
  PvRead(
    id: 'ttc_read_trying_takes_over',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('When trying starts to take over your life'),
    teaser: _en('How to notice when it has, and small ways to give trying a '
        'smaller place in your days.'),
    shortAnswer: _en("It's very common for trying to fill your thoughts, "
        "especially after a few months. You don't have to stop trying to feel "
        'better. Tracking less, keeping some days trying-free, and setting a '
        'date to see a doctor can all make it lighter.'),
    scaleSetter: _en('Thinking about trying a lot is normal. It becomes worth '
        'acting on when it starts to cost you sleep, work, friends, or '
        'closeness with your partner.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('You check the app before you open your eyes. You plan a family '
              'trip around your fertile days. A friend asks what\'s new, and '
              "you realise you can't think of anything that isn't about "
              'trying.'),
          _en("If that sounds familiar, you haven't done anything wrong. It "
              'happens to a lot of women, slowly, month by month. The good '
              'news is that small changes can give you some room back.'),
        ],
      ),

      PvReadSection(
        heading: _en('How did it get this big?'),
        paragraphs: [
          _en('Trying runs on a monthly loop: hope, waiting, testing, and '
              'often a period. Each turn of the loop pulls you a little '
              'closer. Apps, strips and forums add more things to check, and '
              'each one feels like it might help.'),
          _en('Wanting to do everything right is a caring instinct. But once '
              'every day has a task, there are no days off, and that is tiring '
              'for anyone.'),
          _en('Family can add to it too. When relatives ask often, or suggest '
              'a new food or prayer each visit, it can feel as if the whole '
              'house is watching the calendar with you.'),
        ],
      ),

      PvReadSection(
        heading: _en('How do I know if I\'m stressed?'),
        paragraphs: [
          _en('Stress often shows up in your body and habits before you name '
              'it. These are common signs. A few of them now and then is '
              'normal. Many at once, most days, is a signal to ease off.'),
        ],
        bullets: [
          _en("Trouble falling asleep, or waking at night and checking your "
              'phone.'),
          _en('Headaches, a tight jaw or shoulders, or an upset stomach.'),
          _en("Snapping at people you love, then feeling bad about it."),
          _en("Finding it hard to focus at work because you're counting days."),
          _en('Searching symptoms late at night, and feeling worse after.'),
          _en('Sex that feels like a task, for one or both of you.'),
        ],
      ),

      PvReadSection(
        heading: _en('What can make it smaller?'),
        paragraphs: [
          _en("You don't need to fix all of this at once. Try one or two of "
              'these for a month, and see how it feels.'),
        ],
        bullets: [
          _en('1. Track less. Pick one thing, like your period dates, and drop '
              'the rest for a cycle. Sex every two or three days covers your '
              'fertile days anyway.'),
          _en('2. Keep some days trying-free. Agree with your partner that '
              "certain evenings aren't for talking about it at all."),
          _en('3. Put a limit on searching. Set a time, like fifteen minutes '
              'after dinner, and close the tabs after that.'),
          _en('4. Keep one thing that is only yours: a class, a walk with a '
              'friend, a book, cooking something new.'),
          _en('5. Set a date to see a doctor, so you are not deciding again '
              'every single month.'),
          _en('6. Turn off the reminders you no longer need, so your phone '
              'stops bringing it up for you.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('The doctor date'),
          body: _en("See a doctor after a year of trying if you're under 35, "
              "or after six months if you're 35 or older. Sooner if your "
              'periods are irregular. Write the date down, and let it hold the '
              'worry for you until then.'),
        ),
      ),

      PvReadSection(
        heading: _en('When is it more than ordinary worry?'),
        paragraphs: [
          _en('Most worry comes in waves. It rises around your fertile days or '
              'the day your period is due, then settles. That is the normal '
              'rhythm of trying, and it tends to ease on its own.'),
          _en('It is different when the tension does not settle between the '
              'waves. You may feel on edge most days, or find one stressful '
              'week running straight into the next, with no gap to recover.'),
          _en('Other signs are when you start avoiding things you used to '
              'enjoy, when you feel numb instead of sad, or when you stop '
              'being able to picture a good day at all. These are good reasons '
              'to talk to a psychologist, not signs that you have failed.'),
        ],
      ),

      PvReadSection(
        heading: _en('Does stress stop me getting pregnant?'),
        paragraphs: [
          _en('Very high stress that goes on for a long time can upset '
              'ovulation. Everyday stress, like a tough month at work or '
              "worrying about this, hasn't been shown to stop pregnancy. So "
              "easing off isn't about fixing your fertility. It's about "
              'feeling better now.'),
          _en('You may hear about acupuncture, hypnosis or special retreats. '
              "NICE says these haven't been properly tested for fertility, so "
              "they can't be recommended for helping you conceive. If "
              'something safe helps you relax, that is reason enough.'),
        ],
      ),

      PvReadSection(
        heading: _en('How do we keep us from becoming only this?'),
        paragraphs: [
          _en('Make some time together that has nothing to do with a '
              'calendar: a film, a drive, dinner out, talking about anything '
              'else. Couples who do this often say it brings back the feeling '
              'of being on the same side.'),
          _en("If you're the one who carries the tracking, it's fair to share "
              'it. Your partner can hold the calendar for a month, or you can '
              'both agree to stop for one.'),
          _en('It also helps to keep sex from being only about the fertile '
              'days. Closeness outside the window, with no goal in mind, '
              'reminds you both why you wanted a family together in the first '
              'place.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en("If I stop tracking, won't I miss my fertile days?"),
        answer: _en('Not if you have sex every two or three days through the '
            'middle of your cycle. That covers the fertile days without '
            'knowing exactly which they are. Many couples find it easier than '
            'aiming for one day.'),
      ),
      PvReadFaq(
        question: _en("I feel guilty when I'm not thinking about it. Is that "
            'normal?'),
        answer: _en('Yes. It can feel like not thinking about it means not '
            "caring. It doesn't. Your body does its part whether you're "
            "watching or not, and a break doesn't change that."),
      ),
      PvReadFaq(
        question: _en('Should I stop reading forums?'),
        answer: _en('If you usually feel worse after, try a break for a month. '
            'Forums can help you feel less alone, but late-night scrolling '
            'through other people\'s symptoms often adds worry you didn\'t '
            'have before.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When stress needs more than small changes'),
      body: _en('Talk to a psychologist if low mood or anxiety has lasted '
          "more than two weeks, if you can't sleep or cope at work, if you've "
          "stopped seeing people, or if you're drinking more to get through "
          'it. If you have thoughts of harming yourself, talk to someone today. '
          "Tele-MANAS, the Government of India's free mental health helpline, "
          'answers on 14416 at any hour.'),
    ),

    evidence: _en('Advice on how often to have sex, when to see a doctor, and '
        'on complementary therapies follows NICE guideline CG156 (Fertility '
        'problems: assessment and treatment) and ASRM. Guidance on stress and '
        'emotional care follows the ESHRE guideline on routine psychosocial '
        'care in infertility and medically assisted reproduction. Tele-MANAS '
        'details are from the Ministry of Health and Family Welfare, '
        'Government of India. Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en("Today's practice"),
        value: _en('Five minutes that are about you, not the calendar.'),
        surfaceId: 'ttc_ritual',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Stress, and the thing everyone says about it'),
        value: _en('What stress does and doesn\'t do to fertility, in plain '
            'words.'),
        surfaceId: 'ttc_read/ttc_read_stress_fertility',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('When to get help'),
        value: _en('Set your doctor date, so the worry has somewhere to go.'),
        surfaceId: 'ttc_fertility_help',
      ),
    ],

    readNext: ['ttc_read_stress_fertility', 'ttc_read_bringing_him_in'],
  ),

  // ---------------------------------------------------------------------------
  //  HARD DAYS — "koi good news?"
  // ---------------------------------------------------------------------------
  //  Plan title kept as the user wrote it in docs/TTC-GAP-PLAN.md. The quoted
  //  question is what she hears; it is quoted speech, not house style, so it
  //  is not the Latin-script Hindi CLAUDE.md retired. Three askers, because
  //  what sits behind the question differs by who asks. Kept distinct from
  //  `ttc_read_family_asking` (the general sentences); this one is scripts
  //  per person.
  PvRead(
    id: 'ttc_read_good_news_answers',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en('Three answers for "Koi good news?"'),
    teaser: _en('What to say to an aunt, a mother-in-law and a colleague, '
        'with a gentle answer and a firmer one for each.'),
    shortAnswer: _en("You don't owe anyone news about your body. A short, "
        'warm line said the same way every time usually ends the question. '
        "Below are answers for an aunt, a mother-in-law and a colleague, "
        'because each one asks for a different reason.'),
    scaleSetter: _en('This question is asked constantly in Indian families, '
        "almost always kindly, and it still hurts. That's normal. A ready "
        'answer makes it much easier to get through.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("You're at a wedding, plate in hand. An aunt you see once a year "
              'squeezes your arm, looks at your stomach, and asks, "Koi good '
              'news?" Three other relatives turn to hear the answer.'),
          _en('It takes a second, and it can stay with you all evening. '
              'Having an answer ready means you don\'t have to find the words '
              'while it hurts.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why does one small question hurt so much?'),
        paragraphs: [
          _en("Because it's never really small when you're trying. It lands "
              'on months of hoping, and it usually comes in public, when you '
              "can't show what you feel."),
          _en("It helps to know that most people ask it the way they'd ask "
              'about your job. It\'s a habit, not a judgement. That doesn\'t '
              'make it hurt less, but it can make it easier not to take it '
              'personally.'),
          _en('You also get to decide how much of yourself goes into the '
              'answer. A short line is not a lie and not a rejection. It is a '
              'way of keeping something tender safe until you are ready to '
              'share it.'),
        ],
      ),

      PvReadSection(
        heading: _en('What can I say to an aunt at a wedding?'),
        paragraphs: [
          _en("She's making conversation, and she'll forget the answer by "
              'dessert. You need something short and light that moves her on.'),
          _en("Don't give her a reason, like work or \"we're not ready yet\". "
              'A reason invites advice, and advice invites a longer talk. A '
              'smile and a new topic close it faster.'),
        ],
        bullets: [
          _en('Gentle: "When there\'s news, you\'ll hear it first. Now tell me, '
              'how is Rinku\'s new job?"'),
          _en('Firmer: "That\'s something we keep between us, Mausi. How have '
              'you been?"'),
        ],
        tip: PvReadTip(
          title: _en('Ask about her'),
          body: _en('Turning the question back to her life is the line that '
              'works most often. People love to talk about themselves and '
              'rarely come back to you.'),
        ),
      ),

      PvReadSection(
        heading: _en('What can I say to my mother-in-law?'),
        paragraphs: [
          _en('Her question often carries real worry, and sometimes pressure '
              'from her own circle. She\'ll ask again, so the answer needs to '
              'be kind but clear, and your husband should be part of it.'),
          _en('It can help to name what she may be feeling. "I know you\'re '
              'looking forward to it" tells her you see her hope, which often '
              'makes her less likely to push.'),
        ],
        bullets: [
          _en('Gentle: "We want it too, Mummy ji. When there\'s something to '
              'share, you\'ll be one of the first to know."'),
          _en('Firmer: "It hurts me when this comes up so often. Please trust '
              'us to tell you when there is news."'),
          _en('If you\'re seeing a doctor: "We\'re already seeing a good '
              'doctor, and we\'re following her advice."'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Let him answer his side'),
          body: _en('It usually goes better when your husband handles '
              'questions from his family. He can say, "We\'ve talked about it, '
              'and we\'d like you to leave it with us."'),
        ),
      ),

      PvReadSection(
        heading: _en('What can I say to a colleague?'),
        paragraphs: [
          _en('At work, you never have to discuss your plans for a family. '
              'A short, calm answer and a change of topic is enough. If you need '
              'time off for tests, "a medical appointment" is all anyone needs '
              'to know.'),
          _en('If a colleague keeps pushing, or it happens in front of your '
              "manager, you can say, \"I'd rather not talk about personal "
              'things at work." That is a fair line in any office, and it '
              'protects you without sounding upset.'),
        ],
        bullets: [
          _en('Gentle: "Nothing to report. How was your weekend?"'),
          _en('Firmer: "I keep that side of life private. Shall we look at '
              'the deck?"'),
        ],
      ),

      PvReadSection(
        heading: _en('What if it happens in front of everyone?'),
        paragraphs: [
          _en('A question in a full room is harder, because the answer feels '
              'like a performance. Keep your line even shorter. "Not yet, '
              'but thank you for asking" and a sip of your tea is enough.'),
          _en('If your partner is nearby, he can step in with a change of '
              'topic. Agree this before you arrive, so he knows it is his cue '
              'and not an interruption.'),
          _en('If the room goes quiet and waits for more, you can let the '
              'silence sit for a moment. Someone almost always fills it, and '
              'the talk moves on.'),
        ],
      ),

      PvReadSection(
        heading: _en('What about friends and neighbours?'),
        paragraphs: [
          _en('Friends may ask more directly, and sometimes with their own '
              'story attached. You can be honest with a close friend if you '
              'want to be. With others, the aunt\'s line works just as well.'),
          _en('A neighbour who asks every time you meet on the stairs can get '
              'the same cheerful "Nothing yet, aunty" every time. After a few '
              "rounds of the same answer, most people stop asking."),
        ],
      ),

      PvReadSection(
        heading: _en('What if they keep asking?'),
        paragraphs: [
          _en('Say the same line, in the same calm voice, every time. When '
              "the answer never changes, there's nothing to push against, and "
              'most people stop.'),
          _en('If someone still won\'t leave it, "Please don\'t ask me that '
              'again" is allowed. You can say it kindly, and you don\'t need '
              'to explain it.'),
          _en('Afterwards, give yourself a minute. Tell your partner who asked '
              'and how it felt. Saying it out loud to someone on your side '
              'helps it go.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Is it rude to not answer an elder?'),
        answer: _en('Not if you answer politely. A warm line and a change of '
            "topic is respectful. You're choosing not to share private "
            "health news, which you're always allowed to do."),
      ),
      PvReadFaq(
        question: _en('What if I start crying when someone asks?'),
        answer: _en('It happens, and it\'s okay. You can say "Excuse me a '
            'moment" and step away. Nobody is owed an explanation, and most '
            'people feel bad for asking once they see it.'),
      ),
      PvReadFaq(
        question: _en("People say \"don't wait too long\". How do I answer?"),
        answer: _en('"Thank you, we\'re looking after it" is enough. You '
            'don\'t have to defend your age or your timing to anyone.'),
      ),
      PvReadFaq(
        question: _en('Should I skip family events to avoid the question?'),
        answer: _en('Skipping some is fine, especially the ones centred on '
            'babies. For the rest, go with an answer ready and a plan to leave '
            'if you need to.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When questions turn into blame'),
      body: _en('Talk to someone if the questions have turned into blame, '
          'taunts or threats, or if you dread going home. If low mood or '
          "anxiety lasts more than two weeks, see a psychologist. Tele-MANAS, "
          "the Government of India's free mental health helpline, answers on "
          '14416 at any hour. If anyone threatens or hurts you, call 181, the '
          "women's helpline, or 112 in an emergency."),
    ),

    evidence: _en('This is emotional and practical guidance rather than '
        'medical advice. It draws on the boundary-setting approaches used in '
        'infertility counselling and described in the ESHRE guideline on '
        'routine psychosocial care in infertility and medically assisted '
        'reproduction. Helpline details are from the Ministry of Health and '
        'Family Welfare (Tele-MANAS) and the Ministry of Women and Child '
        'Development (181 Women Helpline), Government of India. Sources '
        'checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Agree your line together'),
        value: _en('Decide what you both say, before the next wedding.'),
        surfaceId: 'ttc_partner',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('When family keeps asking'),
        value: _en('Deciding who may ask, and how to handle a wedding or a '
            'festival.'),
        surfaceId: 'ttc_read/ttc_read_family_asking',
      ),
    ],

    readNext: ['ttc_read_family_asking', 'ttc_read_telling_family'],
  ),

  // ---------------------------------------------------------------------------
  //  HARD DAYS — the long run of months
  // ---------------------------------------------------------------------------
  //  Gap analysis P2 "Fertility and emotional support" (a psychologist's
  //  course on a diagnosis, emotions, other people and the partner), plus the
  //  P3 "trying in three words" film folded in as a journal prompt. The film
  //  itself is owed content and is not written here. Population figures only.
  PvRead(
    id: 'ttc_read_month_after_month',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en("Coping when month after month doesn't work"),
    teaser: _en('For the long stretch: how it wears on you, how to look after '
        'each other, and where to get help.'),
    shortAnswer: _en('Months of trying without a pregnancy can wear you down, '
        "and feeling low, angry or numb is a normal response. It isn't your "
        'fault. A doctor\'s check after a year (or six months if you\'re 35 or '
        'older), a few steady habits, and someone to talk to all help.'),
    scaleSetter: _en('Taking many months is common, and it is not the same as '
        'not being able to have a baby. WHO says about 1 in 6 people '
        'worldwide have trouble conceiving at some point, and many go on to '
        'have children.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Another month, another single line on the test. You\'ve '
              'stopped telling your partner which day you test. The cousin who '
              'announced her pregnancy when you started trying now has a baby '
              'who is learning to crawl.'),
          _en('The long stretch is its own kind of hard. It isn\'t one big '
              'blow. It\'s a small loss every month that adds up, and it can '
              'change how you feel about yourself, your body and your plans.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why does it get harder, not easier?'),
        paragraphs: [
          _en('Each month has its own hope and its own end. After many of '
              'them, you may find you hope less to protect yourself, then feel '
              'guilty for hoping less. That tiredness is sometimes called '
              'fertility fatigue, and it is very common.'),
          _en('Studies find that anxiety and low mood are much more common '
              'in people having trouble conceiving than in people who aren\'t. '
              "That's not weakness. It's what a long, uncertain wait does to "
              'most people.'),
        ],
        mythFact: PvMythFact(
          myth: _en('If you were more positive, it would have happened by now.'),
          fact: _en('How hopeful you feel does not decide whether you get '
              "pregnant. Your mood can't block a pregnancy, and you don't "
              'need to force yourself to feel positive.'),
        ),
      ),

      PvReadSection(
        heading: _en("What if we've been given a diagnosis?"),
        paragraphs: [
          _en('A name for the problem, like PCOS, low sperm count or blocked '
              'tubes, can bring relief and grief at once. Relief that there '
              'is a reason. Grief that the easy version of this may be gone.'),
          _en('Take a few days before deciding anything. Write down your '
              'questions for the next visit. Ask your doctor what the '
              'diagnosis means for you, since general figures online may not '
              'fit your case.'),
          _en("A diagnosis is about a body, not about blame. It isn't his "
              "fault or yours, and it doesn't make either of you less of a "
              'partner.'),
        ],
      ),

      PvReadSection(
        heading: _en('How do we stay close through this?'),
        paragraphs: [
          _en('Couples often cope in different ways. One wants to talk and '
              'read everything, the other wants to get on with the day. '
              "Neither is wrong, but it helps to name it, so it doesn't feel "
              'like not caring.'),
          _en('Try a short, set time to talk about trying, like twenty minutes '
              'on a Sunday. The rest of the week can stay about other things. '
              'Keep some closeness that has nothing to do with the calendar.'),
          _en('On the hardest days, you may both need different things. Ask '
              'each other a plain question: "Do you want to talk, or do you '
              'want me to just be with you?" Either answer is fine.'),
        ],
      ),

      PvReadSection(
        heading: _en('What small things help most?'),
        paragraphs: [
          _en('None of these make a pregnancy more likely. They make the wait '
              'easier to live in, which matters on its own.'),
          _en('Pick the ones that fit your life. Even one or two, kept up '
              'over the months, can make the stretch feel less like it is '
              'only about waiting.'),
        ],
        bullets: [
          _en('1. Keep a steady day: regular sleep, some movement, meals you '
              'enjoy.'),
          _en('2. Plan one thing each month to look forward to that has '
              'nothing to do with trying.'),
          _en('3. Keep a short journal. Some women find one line a day is '
              'enough.'),
          _en('4. Have one person, besides your partner, who knows and can be '
              'messaged on a bad day.'),
          _en('5. Know your next medical step, so each month is not a fresh '
              'decision.'),
        ],
        tip: PvReadTip(
          title: _en('Trying, in three words'),
          body: _en('If you had to describe these months in three words, what '
              'would they be? Write them in your journal, and ask your partner '
              'for his. Comparing them can start a conversation that has been '
              'hard to begin.'),
        ),
      ),

      PvReadSection(
        heading: _en('How do I handle other people through the long stretch?'),
        paragraphs: [
          _en('Over many months, the questions, the advice and the '
              'announcements can start to feel like a weight you carry into '
              'every room. It is fine to see some people less for a while, '
              'and to choose who you let in.'),
          _en('Pick one or two people who can hear the whole truth, and give '
              'everyone else one short line. That way you are held by a few, '
              'and not worn out by many.'),
          _en('If someone says something hurtful, like "you must be doing '
              'something wrong", it tells you about what they understand, not '
              'about you. You can end the talk and leave the room.'),
        ],
      ),

      PvReadSection(
        heading: _en('Is it okay to take a break from trying?'),
        paragraphs: [
          _en('Yes. Some couples stop tracking or stop thinking about timing '
              'for a month or two, just to breathe. That is a real choice, and '
              'not giving up.'),
          _en("If you're 35 or older, or already seeing a doctor, talk to "
              'your doctor before a long pause, so it fits your plan. A short '
              'break from the tracking, while still living as a couple, can '
              'suit most people at any age.'),
        ],
      ),

      PvReadSection(
        heading: _en('When should I get help for how I feel?'),
        paragraphs: [
          _en("You don't have to wait for things to be very bad. Talking to a "
              'psychologist while trying is common and useful, and it can '
              'happen alongside your medical care.'),
          _en('NICE and ESHRE both say people having fertility tests or '
              'treatment should be offered emotional support. Many fertility '
              "clinics in India have a counsellor. It's fine to ask for one."),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('Is it normal to not want to try any more some months?'),
        answer: _en('Yes. Needing a break for a month or two is common, and '
            'you can talk it through with your doctor if you have one. Your '
            'feelings about wanting a baby can change month to month and '
            'still be real.'),
      ),
      PvReadFaq(
        question: _en('I feel like I\'m letting my family down.'),
        answer: _en("You aren't. Trouble conceiving is a health matter, not a "
            'failure, and it can come from either partner or both. If people '
            'around you are adding to that feeling, a counsellor can help you '
            'both find words for it.'),
      ),
      PvReadFaq(
        question: _en('Does seeing a psychologist mean something is wrong '
            'with me?'),
        answer: _en('No. It means you\'re carrying something heavy and want '
            'help with it. Many women see someone for a few sessions during '
            'trying, the same way they would see a doctor for the medical '
            'side.'),
      ),
      PvReadFaq(
        question: _en('When should we see a fertility doctor?'),
        answer: _en("After a year of trying if you're under 35, or six months "
            "if you're 35 or older. Go sooner if your periods are irregular, "
            'if you have had pelvic infections or surgery, or if either of you '
            'has a known health problem.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to get help for low mood or anxiety'),
      body: _en('See a psychologist or doctor if you have felt low, empty or '
          'anxious most days for more than two weeks, if you have lost '
          "interest in things you used to enjoy, or if you can't sleep, eat "
          'or work as usual. If you have thoughts of harming yourself or that '
          'life is not worth living, talk to someone today. Tele-MANAS, the '
          "Government of India's free mental health helpline, answers on 14416 "
          'or 1-800-891-4416, 24 hours a day. In immediate danger, call 112.'),
    ),

    evidence: _en('The figure of about 1 in 6 people affected by infertility '
        'is from the WHO report on infertility prevalence (2023). When to see '
        'a doctor follows NICE guideline CG156 and ASRM. Emotional support '
        'during fertility care follows NICE CG156 and the ESHRE guideline on '
        'routine psychosocial care in infertility and medically assisted '
        'reproduction. Tele-MANAS details are from the Ministry of Health and '
        'Family Welfare, Government of India. Sources checked September '
        '2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a psychologist'),
        value: _en('Someone who works with couples through these same long '
            'months.'),
        surfaceId: 'ttc_prepare',
      ),
      PvReadNextStep(
        kind: PvNextKind.activity,
        title: _en('Your journal'),
        value: _en('One line a day is enough, and it is only for you.'),
        surfaceId: 'ttc_journal',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Is it time for a check?'),
        value: _en('See when a fertility doctor makes sense for the two of '
            'you.'),
        surfaceId: 'ttc_fertility_help',
      ),
    ],

    readNext: ['ttc_read_when_to_seek_help', 'ttc_read_bringing_him_in'],
  ),
];
