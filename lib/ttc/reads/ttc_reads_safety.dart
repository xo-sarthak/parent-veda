// =============================================================================
//  Mind & body › Talk — when home doesn't feel safe
// -----------------------------------------------------------------------------
//  ⚠️ ONE FILE PER BRACKET, SO SEVERAL PEOPLE CAN BUILD AT ONCE.
//
//  Written 2026-09-26 for the TTC gap plan (docs/TTC-GAP-PLAN.md, stream A,
//  Mind & body › Talk, P2): "Relationship abuse comes in many forms", "How to
//  end a dangerous relationship" and "Is your partner behaving
//  inappropriately?", clustered into one read. Pressure to conceive can turn
//  into control or harm at home, from a husband or from in-laws, and a woman
//  in that place needs one calm page with Indian helplines on it.
//
//  ⚠️ NEVER HER FAULT, NEVER CAUSED BY INFERTILITY. The myth/fact pair and the
//  "Is it my fault?" section carry this; do not soften either.
//
//  ⚠️ HELPLINES ARE STATED AS FACTS WITH ONE CAVEAT: "rules and contacts can
//  vary by state; a helpline will guide you". 112 (ERSS, Ministry of Home
//  Affairs), 181 (Women Helpline, Ministry of Women and Child Development),
//  1091 (women's police helpline), NCW WhatsApp 7217735372, Tele-MANAS 14416
//  (same number as kCrisisHelplineNumber in lib/data/mind_mood_data.dart). If
//  any of these changes, every string here changes with it.
//
//  ⚠️ PROMISE NO FEATURE THE APP DOES NOT HAVE. The shared-phone tip names
//  only the "Hide sex and intimacy content" setting (TtcContentPrefs) and
//  closing the app. No panic button, no disguise, no lock.
//
//  ⚠️ THE AGGREGATOR IS STILL THE ONLY PUBLIC ENTRY POINT. Nothing outside
//  `ttc_reads_data.dart` should import this file.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, ON PURPOSE. See ttc_reads_mind_body.dart.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsSafety = [
  // ===========================================================================
  //  TALK — when a relationship doesn't feel safe
  // ===========================================================================
  PvRead(
    id: 'ttc_read_relationship_safety',
    hue: 42,
    kicker: _en('Mind & body'),
    title: _en("When a relationship doesn't feel safe"),
    teaser: _en("What abuse at home can look like, why it's never your fault, "
        'and where to get help in India.'),
    shortAnswer: _en('If someone at home hurts you, controls you or threatens '
        "you, including over not getting pregnant, that is abuse. It isn't "
        'your fault. If you are in danger now, call 112. For help and advice '
        'at any hour, call the women\'s helpline on 181.'),
    scaleSetter: _en('Nearly 3 in 10 married women in India have faced '
        'physical or sexual violence from a husband, and many never call it '
        "abuse. You don't need to be sure, or ready to leave, to ask for "
        'help. Only one thing is urgent: if you are in danger right now, call '
        '112.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('This page is for you if home has started to feel frightening, '
              "or if the way you're treated there changed once you began "
              "trying for a baby. You might not know what to call it. That's "
              'okay. You can still ask for help.'),
          _en('Hurt at home can come from a husband, from his family, or from '
              'both. It can be loud, or it can happen without anyone raising '
              "a voice. Here's what it can look like, and where you can turn "
              'in India.'),
        ],
      ),

      PvReadSection(
        heading: _en('What can abuse at home look like?'),
        paragraphs: [
          _en('Abuse is when someone uses fear or force to control you. It '
              "isn't one argument or one bad day. It's a pattern, and it often "
              'gets worse over time. It can look like any of these.'),
        ],
        bullets: [
          _en('Hurtful words: insults, shouting, calling you useless or '
              "\"barren\", or threatening to send you back to your parents' "
              'home or to bring in another wife.'),
          _en('Control: checking your phone, stopping you from seeing your '
              'family or friends, or deciding where you may go.'),
          _en('Money: taking your salary, leaving you without money for '
              'basics, stopping you from working, or demanding dowry from '
              'your family.'),
          _en("Sexual: forcing or pressuring you into sex you don't want."),
          _en('Physical: hitting, slapping, pushing, pulling your hair, or '
              'locking you in or out of the house.'),
          _en('Threats: to hurt you, your children or your family if you '
              'speak up or leave.'),
        ],
      ),

      PvReadSection(
        heading: _en('Can pressure about getting pregnant be abuse?'),
        paragraphs: [
          _en('Yes, it can. Doctors call it reproductive coercion. It means '
              'someone takes control of your body and your choices about '
              'having a baby. For example:'),
        ],
        bullets: [
          _en("Forcing you to have sex on fertile days when you don't want "
              'to.'),
          _en("Forcing you into tests, treatments or tablets you haven't "
              'agreed to, or hiding the ones your doctor gave you.'),
          _en('Blaming, insulting or threatening you because you are not '
              'pregnant yet.'),
          _en("Pushing you to find out or choose a baby's sex, which is "
              'against the law in India.'),
        ],
        mythFact: PvMythFact(
          myth: _en("They treat me like this because I haven't given them a "
              "child, so it's my fault."),
          fact: _en('Not conceiving never causes abuse and never excuses it. '
              'Trouble conceiving is common, can come from either partner, '
              'and is a medical matter. The person hurting you is '
              'responsible for what they do.'),
        ),
      ),

      PvReadSection(
        heading: _en('Is it my fault?'),
        paragraphs: [
          _en('No. Nothing you did or didn\'t do makes it okay for someone to '
              'hurt you. Not a late period, not a negative test, not the '
              'dowry, not the way you cook or speak.'),
          _en("Many women are told they're the cause, and after a while they "
              "start to believe it. That feeling is common. It's part of how "
              "control works, and it doesn't make it true."),
          _en('You may be told to adjust and keep the family together, often '
              'by people who love you. You can respect them and still say that '
              "what's happening to you isn't okay."),
        ],
      ),

      PvReadSection(
        heading: _en('What small, safe steps can I take?'),
        paragraphs: [
          _en("You don't have to do everything at once, or leave today. These "
              'are small steps many women find useful. Do only what feels safe '
              'for you.'),
        ],
        bullets: [
          _en('1. Tell one person you trust, like a friend, sister, colleague '
              'or your own doctor. Agree on a word or message that means "I '
              'need help now".'),
          _en('2. Keep a short note of what happened, with dates and any '
              "injuries. Keep it where the people hurting you can't see it, "
              'like with a trusted friend or in an email only you can open.'),
          _en('3. See a doctor for any injury, and ask for it to be written '
              'down. A medical record can help you later.'),
          _en('4. Keep copies of important papers: Aadhaar, PAN, marriage '
              'certificate, bank details and your medical reports. A photo '
              'sent to someone you trust works too.'),
          _en('5. If you can, put a little money aside, and know your own bank '
              'and UPI details.'),
          _en('6. Keep your phone charged. Save helpline numbers under a name '
              "that doesn't stand out."),
        ],
        tip: PvReadTip(
          title: _en('Using this on a shared phone'),
          body: _en('You can close the app at any time and come back later. '
              'ParentVeda also has a setting to hide sex and intimacy content. '
              'Calls and messages to a helpline can show in your phone\'s '
              'history, so check that history if that feels safer.'),
        ),
      ),

      PvReadSection(
        heading: _en('Who can I call in India?'),
        paragraphs: [
          _en("These are free. You can call even if you're not sure what to "
              'say, or if you only want to talk it through.'),
        ],
        bullets: [
          _en("112: emergency, at any hour. Call this if you're in danger "
              'now.'),
          _en('181: the women\'s helpline, 24 hours. They listen, advise, and '
              'can connect you to police, legal help, counselling or a safe '
              'place to stay.'),
          _en("1091: the women's police helpline."),
          _en('National Commission for Women on WhatsApp, 7217735372, if '
              "calling isn't safe."),
          _en('Tele-MANAS, 14416: free emotional support from trained '
              'counsellors, any hour, in many Indian languages.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Help under one roof'),
          body: _en('Most districts have a One Stop Centre, called Sakhi, with '
              'medical help, police and legal support, counselling and a short '
              'safe stay in one place. The 181 helpline can tell you where '
              'yours is. Rules and contacts can vary by state; a helpline will '
              'guide you.'),
        ),
      ),

      PvReadSection(
        heading: _en('What does the law say?'),
        collapsible: true,
        summary: _en('The Domestic Violence Act, 2005 protects wives and women '
            'in a shared home, including from in-laws.'),
        paragraphs: [
          _en('The Protection of Women from Domestic Violence Act, 2005 '
              'protects wives and other women who live, or have lived, in a '
              'shared household. It covers physical, sexual, verbal, emotional '
              'and money abuse, including by a husband\'s relatives.'),
          _en('A Protection Officer appointed for your district can help you '
              'make a complaint and ask a court for orders. A court can order '
              'the abuse to stop, protect your right to live in the shared '
              'home, and order money for your needs.'),
          _en('Cruelty by a husband or his family, and demanding dowry, are '
              'also crimes in India. Free legal help is available through '
              'your District Legal Services Authority. Rules and contacts can '
              'vary by state; a helpline will guide you.'),
        ],
      ),

      PvReadSection(
        heading: _en("What if I'm not ready to leave?"),
        paragraphs: [
          _en("That's okay, and it's very common. Many women stay for a while "
              'because of money, children, family or fear of what comes next. '
              "Getting help doesn't mean you have to leave. It means you're not "
              'alone with this.'),
          _en('If you do decide to go, the time around leaving can be the '
              'riskiest. It helps to plan it first with a helpline or a '
              'counsellor, and to tell someone you trust when and where you '
              'will be.'),
          _en('If things calm down for a while, you\'re allowed to feel '
              'relief. If the hurt comes back, you can ask for help again, as '
              'many times as you need.'),
        ],
      ),
    ],

    faqs: [
      PvReadFaq(
        question: _en('My husband has never hit me. Can it still be abuse?'),
        answer: _en("Yes. Abuse doesn't have to leave a mark. Constant insults, "
            'threats, control over your money or where you go, and forced sex '
            'are all abuse. Indian law counts them as domestic violence too.'),
      ),
      PvReadFaq(
        question: _en("It's my mother-in-law, not my husband. Can I still get "
            'help?'),
        answer: _en('Yes. The Domestic Violence Act covers abuse by relatives '
            'in the shared home, including in-laws. The 181 helpline or a '
            'Protection Officer can explain what you can do.'),
      ),
      PvReadFaq(
        question: _en('If I call a helpline, will the police come to my '
            'house?'),
        answer: _en('Usually not, unless you ask for it or you are in danger '
            'right then. You can call just to talk and learn your options. It '
            'helps to say at the start what you do and don\'t want.'),
      ),
      PvReadFaq(
        question: _en('Can I tell my fertility doctor about this?'),
        answer: _en('Yes. Doctors see this more often than you might think. '
            'You can ask to speak to them alone, without your husband or '
            'in-laws in the room. They can treat and note any injury, and '
            'point you to help.'),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("If you're in danger"),
      body: _en("If you're in danger right now, or someone has threatened to "
          'kill or badly hurt you, call 112 straight away. If you can, go to a '
          'neighbour, a shop or anywhere with people around. Go to a hospital '
          "today if you've been hurt, if anyone has choked you even for a "
          'moment, or if you might be pregnant and have been hit. If you have '
          'thoughts of harming yourself, call Tele-MANAS on 14416 now. For '
          'advice and support at any hour, call 181.'),
    ),

    evidence: _en('The forms of abuse, including reproductive coercion, '
        'follow WHO guidance on violence against women and ACOG Committee '
        'Opinion 554 (Reproductive and sexual coercion). The figure for India '
        'is from the National Family Health Survey (NFHS-5, 2019 to 2021). '
        'Legal points follow the Protection of Women from Domestic Violence '
        'Act, 2005, the Dowry Prohibition Act, 1961 and the PC-PNDT Act, '
        '1994. Helplines are from the Ministry of Women and Child Development '
        '(181, One Stop Centres), the Ministry of Home Affairs (112), the '
        'National Commission for Women, and the Ministry of Health and Family '
        'Welfare (Tele-MANAS). Sources checked September 2026.'),

    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a psychologist'),
        value: _en('A private conversation with someone who works with women '
            'in hard situations at home.'),
        surfaceId: 'ttc_prepare',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('When family keeps asking'),
        value: _en('Ways to answer the questions and the pressure, in your own '
            'words.'),
        surfaceId: 'ttc_read/ttc_read_family_asking',
      ),
    ],

    // ⚠️ ONE READ, ONCE, AT THE FOOT (2026-09-28, no repetition):
    // 'ttc_read_family_asking' is the next step "When family keeps asking",
    // so the Read next rail no longer lists it a second time.
    // Kept for revert:
    // readNext: ['ttc_read_family_asking', 'ttc_read_good_news_answers'],
    readNext: ['ttc_read_good_news_answers'],
  ),
];
