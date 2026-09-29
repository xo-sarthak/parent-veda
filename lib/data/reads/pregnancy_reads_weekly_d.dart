// =============================================================================
//  Pregnancy reads — the weekly reads, written out (d: expert and research)
// -----------------------------------------------------------------------------
//  See pregnancy_reads_weekly_a.dart. The two "expert" items used to carry
//  named authors (a paediatrician, a lactation consultant — the seed's own
//  cast); the three "research" items are editorial and cite the studies
//  they summarise. Same bar, same clinical rules.
//
//  Rewritten 2026-09-29 to docs/PREG-VOICE.md, each read with a shortAnswer.
//  Trust (gap analysis P1): the named authors belonged to nobody and no
//  review took place, so all five are now `reviewed: false` under the desk
//  byline, and the two expert pieces no longer speak in a clinician's first
//  person. See the note in pregnancy_reads_weekly_a.dart.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import 'pregnancy_reads_weekly_a.dart' show kPregWeekReadPrefix;

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The honest byline until a real, named clinician has read the piece.
const LocalizedText _desk =
    LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');
const LocalizedText _deskRole = LocalizedText(
    en: 'Written by the ParentVeda team', hi: 'Written by the ParentVeda team');

final List<PvRead> kPregnancyReadsWeeklyD = [
  // ---------------------------------------------------------------------------
  //  exp_priya · weeks 16–40
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}exp_priya',
    hue: 275,
    kicker: _en('Bonding'),
    title: _en('Building emotional connection before birth'),
    teaser: _en("Bonding doesn't start in the delivery room. What attachment "
        'is, why some parents feel nothing yet, and the small habits that '
        'build it.'),
    shortAnswer: _en('Bonding is a habit of noticing and responding, and it '
        'can start now. Answer the kicks, talk to your baby, and let your '
        "partner do the same. Feeling nothing much yet is normal, and it "
        "doesn't predict how you'll bond after birth."),
    scaleSetter: _en("Attachment isn't a feeling that arrives. It's a way of "
        'responding that gets built. Parents who talk to, touch and think '
        'about their baby before birth tend to find the first weeks after '
        "less bewildering. That's not because the baby is different. It's "
        'because the habit of noticing is already there.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Expecting parents who worry about bonding usually worry in one '
            'of two ways. Some felt an instant, overwhelming love at the scan '
            'and are frightened it will fade. Others felt nothing in '
            'particular and are frightened that means something.'),
        _en('Both are normal, and neither predicts how things will go with '
            'your child. Researchers call this prenatal attachment, and they '
            "don't measure it in feelings. They measure it in what you do: "
            'whether you think of your baby as a person, whether you respond '
            'to movements, and whether you have begun to imagine caring for '
            'them.'),
      ]),
      PvReadSection(
        heading: _en('What does the evidence show?'),
        paragraphs: [
          _en('Studies that follow women from the second trimester find a '
              'link. Stronger prenatal attachment, the kind you can see in '
              'what parents do, goes with more sensitive responding to the '
              'baby in the first months, and with lower rates of postnatal '
              'depression.'),
          _en("The link is modest, and it isn't a verdict on anyone. It says "
              'the habits below are worth having. It does not say that '
              'lacking them harms a child.'),
          _en('The strongest sign of a difficult start is not low bonding in '
              'pregnancy. It is a mother without support: without help, '
              "sleep or someone to talk to. That's why the partner piece in "
              'this rail matters more than any bonding exercise.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which habits build it?'),
        bullets: [
          _en('Respond to movements. When your baby kicks, put a hand there '
              "and say something. You're practising the loop of noticing and "
              'responding that runs the first year.'),
          _en("Give your baby a name to use now, even a nickname. People bond "
              'with a person, not with "the baby".'),
          _en('Talk about your baby as someone with a personality: "she\'s '
              'always awake after dinner." You\'re probably right, and it\'s '
              'the beginning of knowing them.'),
          _en('Bring your partner into the same habits. Fathers who talk to '
              'the bump report stronger attachment at three months, and the '
              'baby knows their voice.'),
          _en('Look after yourself. Sleep, food, and someone to tell the '
              "worries to. Bonding is easier in a body that isn't exhausted."),
        ],
      ),
      PvReadSection(
        heading: _en('What if bonding feels hard?'),
        paragraphs: [
          _en('An unplanned pregnancy, a previous loss, a difficult '
              'relationship, depression or anxiety, or a pregnancy after IVF '
              'can all make it harder to let yourself attach. Often that is '
              "self-protection. None of these means you won't bond with your "
              'child.'),
          _en('It does mean the second and third trimesters are the time to '
              'tell your doctor. Depression in pregnancy is common (around one '
              'woman in eight), it can be treated, and it is the thing most '
              'likely to get in the way.'),
        ],
      ),
      PvReadSection(
        heading: _en('What helps after the birth?'),
        paragraphs: [
          _en('Three hospital practices have evidence for early bonding: '
              'skin-to-skin in the first hour, keeping your baby in your room '
              'rather than a nursery, and feeding whenever your baby asks. Ask '
              'for them in your birth plan.'),
          _en('And if the first days bring nothing but exhaustion and a '
              'stranger who cries, that is a normal start too, and it changes.'),
        ],
      ),

      PvReadSection(
        heading: _en('What about an older child?'),
        paragraphs: [
          _en("If you already have a child, bonding with the new baby usually "
              "isn't the worry. The older one is. Children under three don't "
              "understand a pregnancy, and they don't need to. A two-year-old "
              'told "a baby is coming" in month four has forgotten by month '
              'five.'),
          _en('Tell them close to the birth, let them feel the kicks, and give '
              "them a small job of their own, like fetching the nappy or "
              "choosing the baby's first song. Many children slip back a "
              'little after a birth, like a toilet-trained three-year-old who '
              "wets again. It's normal and brief, and easier to meet with "
              'patience if you expected it.'),
          _en('Keep one small ritual the same the whole way through, like the '
              'bedtime story or the Sunday walk. A child who keeps one thing '
              'that is theirs finds it easier to share everything else.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Talk to your doctor this week if'),
      body: _en("You've felt low, flat or anxious most days for two weeks or "
          "more, can't sleep even when you have the chance, have lost "
          'interest in the pregnancy or in things you liked, or have thoughts '
          'of harming yourself. Depression in pregnancy is common and can be '
          'treated. It is the thing most likely to come between you and your '
          "baby, which is why it's worth saying out loud."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('I feel nothing yet. Is something wrong?'),
        answer: _en('No. Many parents feel little until the baby is in their '
            'arms, and some not for weeks after. The habits above build the '
            'relationship, and the feeling follows at its own pace.'),
      ),
      PvReadFaq(
        question: _en('Does a difficult birth affect bonding?'),
        answer: _en('It can delay it, especially after an emergency caesarean '
            "or a NICU stay. That delay isn't permanent. Skin-to-skin as soon "
            "as it's possible helps."),
      ),
    ],
    evidence: _en('Alhusen, Journal of Obstetric, Gynecologic & Neonatal '
        'Nursing (2008), review of maternal–fetal attachment; Rossen et '
        'al., Archives of Women\'s Mental Health (2016); Howard et al., '
        'Lancet (2014) on perinatal mental health; WHO / UNICEF '
        'Baby-Friendly Hospital Initiative.'),
    readNext: ['${kPregWeekReadPrefix}talking_baby', '${kPregWeekReadPrefix}partner_support'],
  ),

  // ---------------------------------------------------------------------------
  //  exp_meera · weeks 28–40
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}exp_meera',
    hue: 12,
    kicker: _en('Feeding'),
    title: _en('Why early breastfeeding preparation helps'),
    teaser: _en('Three things worth knowing before the first feed, and why '
        'the first week goes better when you learn them in the third '
        'trimester.'),
    shortAnswer: _en('Half an hour of learning before birth makes the first '
        'week easier. Know what a normal first week looks like, how a good '
        'latch looks and feels, and what to say no to. Six or more wet '
        'nappies a day from day five means your baby is getting enough.'),
    scaleSetter: _en("Breastfeeding is natural, and it's also learnt, by you "
        'and your baby together, in the first week. Women who struggle on '
        "day three are rarely the ones who can't feed. More often they "
        "didn't know what normal looked like and feared the worst. Half an "
        'hour of preparation in the third trimester prevents most of that.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Your body prepares on its own. From mid-pregnancy your breasts '
            'make colostrum. Some women leak a little in the last weeks and '
            "most don't. Neither tells you anything about how much milk "
            "you'll have."),
        _en('Nothing needs to be done to your nipples. The old advice to '
            '"toughen" them with a towel does harm. What needs preparing is '
            'what you know.'),
      ]),
      PvReadSection(
        heading: _en('What does a normal first week look like?'),
        paragraphs: [
          _en('Day one: a few millilitres of colostrum per feed, eight to '
              'twelve feeds, and a baby who sleeps a lot.'),
          _en('Day two: a baby who feeds almost nonstop through the evening '
              'and night. This "second night" convinces many mothers they have '
              "no milk. They do. The baby is placing the order."),
          _en('Day three or four: the milk comes in, your breasts feel full '
              'and hot, and your baby settles. By day five, six wet nappies '
              'and yellow stools.'),
          _en('Knowing that sequence in advance helps more than anything else '
              'on this page.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does a good latch look like?'),
        paragraphs: [
          _en('A good latch is wide, deep and off-centre. More of the dark '
              "skin around your nipple (areola) is in your baby's mouth below "
              'the nipple than above it. The chin is pressed in, the nose is '
              'free, and the lips are turned out.'),
          _en("It shouldn't hurt beyond the first few seconds. Pain that "
              'carries on through a feed means the latch is shallow. The fix '
              'is to take your baby off (slide a finger into the corner of '
              "their mouth) and start again, not to put up with it. Sore "
              'nipples are a latch problem, not a toughness problem.'),
          _en('Watch a video of a latch before the birth. On day one, ask the '
              "lactation nurse to watch a feed while someone's there to help "
              'you correct it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you say no to?'),
        bullets: [
          _en('A bottle of formula "just for tonight" on day two, unless a '
              'paediatrician has a medical reason. It is the most common way '
              'supply gets undermined, because your baby places the order for '
              'milk at the breast.'),
          _en('Honey, ghutti, janam ghutti, sugar water, or any feed before '
              'breast milk. Colostrum is the first food, and honey carries a '
              'real risk of infant botulism.'),
          _en('A schedule. Newborns feed when they show they are hungry, eight '
              'to twelve times a day. The clock comes later.'),
          _en('Being told your milk is "thin" or "not enough" by someone who '
              "hasn't weighed your baby. Weight and nappies are the measures. "
              "Opinion isn't."),
        ],
      ),
      PvReadSection(
        heading: _en('What can you set up before the birth?'),
        paragraphs: [
          _en('Find out whether your hospital has a lactation consultant, and '
              'ask for her on day one. Buy two nursing bras a size up and a '
              'tube of purified lanolin. Decide with your partner who will '
              "handle the relatives' feeding advice, so you don't have to."),
          _en('If you have flat or inverted nipples, have had breast surgery, '
              'or your baby is expected early, ask for a lactation appointment '
              "in the third trimester. The plan is different, and it's better "
              'made in advance.'),
        ],
      ),

      PvReadSection(
        heading: _en('What do women ask most?'),
        paragraphs: [
          _en('"Will my breasts be big enough?" Size has nothing to do with '
              'supply. The milk-making tissue is the same, and the rest is '
              'fat.'),
          _en('"Is my milk thin?" The milk at the start of a feed looks watery '
              'and the milk at the end looks creamy. Both are right.'),
          _en('"How do I know my baby is getting enough?" Wet nappies, six or '
              "more a day from day five, and weight checked at the "
              "paediatrician's. Not the clock, not the crying, not a "
              "relative's opinion."),
          _en('"Can I eat what I like?" Yes. There is no food a breastfeeding '
              'mother must avoid. The long lists going around are tradition, '
              'not evidence.'),
          _en('"How long should I feed?" Only breast milk for six months if '
              'you can, alongside food to two years if you want to, and for '
              "exactly as long as works for you and your baby. That's a "
              'decision, not a test.'),
        ],
      ),

      PvReadSection(
        heading: _en('Which number should you remember?'),
        paragraphs: [
          _en('Six. Six or more wet nappies a day from day five means your '
              'baby is getting enough. That holds whatever anyone in the room '
              'believes about the size of your breasts, the colour of the '
              'milk, or the length of the feed.'),
          _en("Count nappies, weigh at the paediatrician's, and let everything "
              'else be opinion.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask for help the same day if, after the birth'),
      body: _en('Your baby has fewer than six wet nappies a day after day '
          'five, is sleepy and hard to wake for feeds, is yellow and getting '
          'more so, or has lost more than a tenth of their birth weight. Or '
          'if you have a hot, red, painful area on your breast with fever. '
          'None of these means stopping. All of them mean seeing a '
          'paediatrician or lactation consultant that day.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should I pump before the birth?'),
        answer: _en('Not as a routine. Hand-expressing colostrum from 36 weeks '
            'is sometimes advised for women with diabetes or an early birth '
            'expected. Ask your doctor before starting, as it can bring on '
            'contractions.'),
      ),
      PvReadFaq(
        question: _en('Can I breastfeed after a caesarean?'),
        answer: _en('Yes. Ask for skin-to-skin in the theatre or recovery room, '
            'and for help with a side-lying or football hold that keeps your '
            'baby off the wound.'),
      ),
      PvReadFaq(
        question: _en('What if I decide to use formula?'),
        answer: _en("Then you'll feed your baby well. Preparation still helps: "
            'how to make it up safely, how much and how often. The lactation '
            'consultant can advise on both.'),
      ),
    ],
    evidence: _en('WHO / UNICEF Ten Steps to Successful Breastfeeding (2018); '
        'Academy of Breastfeeding Medicine clinical protocols 3 and 26; '
        'Indian Academy of Pediatrics infant feeding guidelines (2016); '
        'Cochrane review on antenatal breastfeeding education (2016).'),
    readNext: ['${kPregWeekReadPrefix}first_24h', '${kPregWeekReadPrefix}hospital_bag'],
  ),

  // ---------------------------------------------------------------------------
  //  res_voices · research
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}res_voices',
    hue: 206,
    kicker: _en('What the research says'),
    title: _en('Babies recognise familiar voices before birth'),
    teaser: _en("Four decades of experiments, one steady finding: a newborn "
        "already knows their mother's voice, and what they heard most in the "
        'last trimester.'),
    shortAnswer: _en("Yes. Newborns a day old already prefer their mother's "
        'voice, and even a story read aloud to them in the last weeks of '
        'pregnancy. They learn the rhythm and melody, not the words. Ordinary '
        'talking, singing and reading aloud are all it takes.'),
    scaleSetter: _en('In 1980 two psychologists gave newborns a dummy wired to '
        'a tape recorder. Babies a day old changed how they sucked so they '
        "could hear their own mother's voice rather than another woman's. "
        'Every study since has refined that result, and none has overturned '
        'it.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The DeCasper and Fifer experiment worked because newborns can't "
            'be asked, but they can be given a choice. Sucking in one rhythm '
            'played the mother. Another rhythm played a stranger.'),
        _en('Ten of twelve babies learnt within minutes to make the rhythm '
            "that brought their mother's voice. That preference could only "
            'exist on day one if it had formed before birth.'),
      ]),
      PvReadSection(
        heading: _en('What exactly do babies learn?'),
        paragraphs: [
          _en('A follow-up in 1986 had mothers read one story, "The Cat in '
              'the Hat", aloud twice a day for the last six weeks of '
              'pregnancy. After birth the babies preferred that story to a '
              'new one, even when a stranger read both.'),
          _en("So it isn't only the voice. It's the rhythm and melody of a "
              'particular passage, repeated. Babies learn the music of speech '
              "(prosody) in the womb. That's why, within days of birth, "
              "newborns' cries carry the melody of their parents' language: "
              'French babies rising, German babies falling.'),
        ],
      ),
      PvReadSection(
        heading: _en('How much reaches the womb?'),
        paragraphs: [
          _en("Recordings made inside the womb show that the mother's voice "
              'arrives clearly. It is carried through her body as well as the '
              'air, above the background of heartbeat and gut. Other voices '
              'arrive muffled, with the consonants lost and the melody kept.'),
          _en("That's why the mother's voice is learnt strongly. The father's "
              "and siblings' voices are learnt more weakly but reliably, if "
              'they are heard often. The television is not learnt at all.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does it matter after birth?'),
        bullets: [
          _en("Newborns calm faster to their mother's voice than to any other "
              'sound, including recordings of other women.'),
          _en('Premature babies in intensive care who hear recordings of their '
              "mother's voice show steadier heart rates and, in some studies, "
              'better feeding.'),
          _en('Your voice is a bridge across the birth: the one thing that is '
              'the same on both sides of it.'),
        ],
      ),
      PvReadSection(
        heading: _en("What doesn't it mean?"),
        paragraphs: [
          _en("It doesn't mean your baby understands words, learns a language, "
              'or becomes cleverer. Products that promise any of that are '
              'selling past the evidence.'),
          _en('It means that ordinary talking, singing and reading aloud in '
              'the last trimester give your baby something they will recognise '
              'on the first day of a very strange new world. That is enough.'),
        ],
      ),

      PvReadSection(
        heading: _en('How were the experiments done?'),
        paragraphs: [
          _en("Every study of what a newborn knows has the same problem: the "
              "baby can't answer. The ways round it are clever and worth "
              "knowing, because they're why the findings can be trusted."),
          _en('Sucking rate is one. Babies suck in bursts, the pattern can be '
              'measured, and a baby who changes it to get a reward has shown a '
              'preference. Head-turning is another: a baby turns towards a '
              'sound they prefer. Heart rate is a third. It slows briefly when '
              'a baby pays attention to something familiar. In the last '
              'decade, brain recordings through a soft cap have shown the '
              'response to a known tune directly.'),
          _en('Each method on its own could be doubted. Together, across forty '
              'years and several countries, they agree. That is what turns a '
              'small finding in a psychology laboratory into something you can '
              'act on with a nursery rhyme.'),
        ],
      ),

      PvReadSection(
        heading: _en('What can you do with it?'),
        paragraphs: [
          _en('Talk, sing and read aloud in the last trimester, in your own '
              'language, at an ordinary volume. Repeat one thing most days: a '
              'song, a verse, a page. Let your partner do the same.'),
          _en('None of it needs equipment or a schedule. It needs the habit, '
              'and the habit is what the studies measured. The reward is a '
              'newborn who, in the first hours of a strange world, already '
              'knows two voices in it.'),
        ],
      ),

      PvReadSection(
        heading: _en("What don't we know yet?"),
        paragraphs: [
          _en('Most of this research was done on full-term babies whose '
              'mothers spoke one language, in laboratories in Europe and North '
              'America. Some questions are still open. Does a baby in a home '
              "with three languages sort them before birth? How much does a "
              "grandmother's daily voice register beside a mother's?"),
          _en('What holds across every study is the plain version. The voice '
              'heard most, from the body it comes from, is the one your baby '
              'knows first.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A general note, and one thing to act on'),
      body: _en('Nothing about hearing in pregnancy is an emergency. One '
          "related thing is. From 28 weeks, if your baby's movements drop "
          'noticeably for a day, including no response to the voice or touch '
          'that usually gets one, call your doctor the same day.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('From what week can the baby hear me?'),
        answer: _en('Responses to sound are seen from about 24 weeks and are '
            'steady by 28. The learning in these studies happened in the '
            'last six to twelve weeks.'),
      ),
      PvReadFaq(
        question: _en("Will the baby know my partner's voice?"),
        answer: _en('If they hear it often and close, yes. Less strongly than '
            'yours, because it arrives only through the air.'),
      ),
    ],
    evidence: _en('DeCasper & Fifer, Science 208 (1980); DeCasper & Spence, '
        'Infant Behavior and Development 9 (1986); Mampe et al., Current '
        'Biology 19 (2009) on newborn cry melody; Doheny et al., Journal of '
        'Maternal-Fetal & Neonatal Medicine (2012) on maternal voice in the '
        'NICU.'),
    readNext: ['${kPregWeekReadPrefix}baby_sound', '${kPregWeekReadPrefix}res_music'],
  ),

  // ---------------------------------------------------------------------------
  //  res_music · research
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}res_music',
    hue: 275,
    kicker: _en('What the research says'),
    title: _en("Music and the womb: what's known"),
    teaser: _en("Babies remember a tune from before birth. They don't get "
        "cleverer from Mozart. What the studies found, and what they didn't."),
    shortAnswer: _en('Babies can remember a tune they heard often in the womb, '
        "and it can settle them after birth. Music won't raise their IQ. The "
        'best-proven benefit is to you: it lowers anxiety, and a calmer '
        'mother is what reaches the baby most.'),
    scaleSetter: _en('Music in pregnancy sits between two exaggerations. One '
        'says it builds intelligence. The other says it does nothing. The '
        'evidence is in the middle, and it\'s rather lovely: a baby can carry '
        'a melody across the birth, and a calmer mother is the effect that '
        'reaches the baby most.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('In 2013 a group in Helsinki played "Twinkle Twinkle Little Star" '
            'to babies in the womb five times a week for the last trimester. '
            "After birth, and again at four months, those babies' brains "
            'responded more strongly to the tune, and to a version with notes '
            "changed, than the brains of babies who hadn't heard it. The "
            'memory was specific, and it lasted.'),
        _en('An earlier British study found that newborns went quiet to the '
            'theme tune of a soap opera their mothers had watched every day, '
            'and not to other music.'),
      ]),
      PvReadSection(
        heading: _en('What about the "Mozart effect"?'),
        paragraphs: [
          _en('The 1993 study behind the phrase found that university students '
              'did slightly better on a spatial puzzle for about fifteen '
              'minutes after listening to a Mozart sonata. It said nothing '
              'about babies, nothing about the womb, and nothing lasting.'),
          _en('Later work found the same short boost from any music the '
              'listener enjoyed. Products that play classical music to the '
              'bump to raise IQ are built on a study that never made that '
              'claim.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does music do?'),
        bullets: [
          _en('It lowers anxiety and blood pressure in mothers in several '
              'trials, including in Indian antenatal clinics. The effect on '
              'you is the best-proven one.'),
          _en("It changes your baby's heart rate and movement in response to "
              'sound, from about 28 weeks. That is a sign of hearing, not of '
              'liking.'),
          _en('It builds a memory for a particular tune, repeated, that lasts '
              'for months after birth and can settle a newborn.'),
          _en("It gives your partner a way in. A song sung every night in the "
              "father's voice is the one your baby is most likely to know him "
              'by.'),
        ],
      ),
      PvReadSection(
        heading: _en('How can you do it, if you want to?'),
        paragraphs: [
          _en('Play music you like, at conversation volume, in the room. Skip '
              'headphones pressed to your belly. They bypass the fluid\'s '
              'protection and add nothing.'),
          _en('Choose one or two pieces to repeat if you want your baby to '
              'know them. Sing: your own voice reaches your baby better than '
              "any speaker. And treat the twenty minutes as yours, because "
              "your calm is the part that can be measured."),
        ],
      ),

      PvReadSection(
        heading: _en('What does garbh sanskar get right?'),
        paragraphs: [
          _en("Garbh sanskar is the practice of shaping the child in the womb "
              'through what the mother hears, reads and thinks. It is far older '
              "than the laboratory. Its central idea, that the baby is affected "
              "by the mother's state, is the part the evidence supports."),
          _en('Where modern research differs is in how it works. It isn\'t the '
              'raga or the text that reaches the baby. It is the calm of the '
              'woman listening, and the melody she repeats.'),
          _en('So the honest version is the traditional one with the promises '
              'trimmed. Sit, listen to something you love, sing it, and do it '
              'most evenings. Your baby will know it, and you\'ll have had '
              'twenty minutes of quiet a day for three months, which no study '
              'has ever found harmful.'),
        ],
      ),

      PvReadSection(
        heading: _en('A short reading list, if you\'re curious'),
        paragraphs: [
          _en('The Helsinki study (Partanen and colleagues, 2013) is short, '
              "free to read and clear. Hepper's 1991 paper on the soap opera "
              'theme is where the "babies remember music" finding began.'),
          _en('The 2010 review of many studies by Pietschnig and colleagues, '
              'bluntly titled "Mozart effect, Shmozart effect", is where the '
              'intelligence claim was laid to rest. It\'s handy the next time '
              'a relative sends you a link.'),
        ],
      ),

      PvReadSection(
        heading: _en('Is there any harm in it?'),
        paragraphs: [
          _en('The only harm is the harm of a promise. If you play a raga every '
              "evening because you enjoy it, you've lost nothing if your child "
              'turns out ordinary. If you play it because a product said it '
              'would raise an IQ, and then feel you failed when the school '
              'reports arrive, you were sold something.'),
          _en("Buy the music if you like. Don't buy the claim. The evidence "
              'supports the pleasure and the memory, and nothing more.'),
          _en('And if music in the evening is the only time of day the house '
              "is quiet, it's already doing what the research measured."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A general note, and one thing to act on'),
      body: _en('Nothing here is clinical. Constant loud noise at work, above '
          'about 85 decibels for a full shift, is the one sound exposure with '
          'evidence of harm. It is a reason to ask for a quieter posting from '
          'the second trimester. And from 28 weeks, reduced movements are '
          'always a same-day call.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is classical music better?'),
        answer: _en('No. The studies used lullabies, pop, film themes and '
            "Mozart. What mattered was repetition and the mother's "
            'enjoyment.'),
      ),
      PvReadFaq(
        question: _en('Can loud concerts harm the baby?'),
        answer: _en("An occasional event doesn't. Standing by the speakers for "
            "hours is worth avoiding. That's not because of proven harm, but "
            'because the fluid muffles less than people assume.'),
      ),
    ],
    evidence: _en('Partanen et al., PLoS ONE (2013); Hepper, Irish Journal '
        'of Psychology (1991); Rauscher, Shaw & Ky, Nature (1993) and the '
        'Pietschnig et al. meta-analysis, Intelligence (2010); Cochrane '
        'review on music for anxiety in pregnancy (2020).'),
    readNext: ['${kPregWeekReadPrefix}res_voices', '${kPregWeekReadPrefix}talking_baby'],
  ),

  // ---------------------------------------------------------------------------
  //  res_stress · research
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}res_stress',
    hue: 104,
    kicker: _en('What the research says'),
    title: _en('Calm matters: stress and pregnancy'),
    teaser: _en("Ordinary stress doesn't harm a baby. Long-lasting stress "
        'without support can. Where the line is, what the studies measured, '
        'and what helps.'),
    shortAnswer: _en("A bad week, a hard job or an argument won't harm your "
        'baby. The studies that found small effects looked at months of '
        'anxiety or depression without support. If you have felt low or '
        'anxious most days for two weeks, telling your doctor is the step '
        'that helps.'),
    scaleSetter: _en('Pregnant women are always told to stay calm, usually by '
        'someone adding to the stress. The research is more useful than the '
        "advice. A bad week, a hard job, an argument: these don't reach your "
        'baby. Months of anxiety or depression without support are linked '
        'with real but modest effects, and every one of them is reduced by '
        'the same thing: help.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Stress hormones, mainly cortisol, cross the placenta in small '
            'amounts. The placenta itself has an enzyme that breaks most of '
            'it down. The system is built to buffer ordinary life.'),
        _en('The large studies found this. When women have high anxiety or '
            'depression scores that last across the pregnancy, their babies '
            'are, on average, born slightly earlier and slightly lighter. '
            'They also score a little higher on measures of emotional '
            'reactivity in early childhood.'),
        _en('The effects are small, and they are averages. They are much '
            'smaller when the mother has support from the people around her.'),
      ]),
      PvReadSection(
        heading: _en('What did "stress" mean in the studies?'),
        paragraphs: [
          _en('Not deadlines. The studies with clear effects looked at '
              'clinical anxiety and depression, bereavement, domestic '
              'violence, and severe life events lasting weeks. A demanding job '
              "on its own, for a woman who is otherwise supported and "
              "sleeping, doesn't show up."),
          _en('The difference matters. "Avoid stress" is impossible advice. '
              '"Get help if you\'re anxious or low for more than two weeks" is '
              'advice you can follow.'),
        ],
      ),
      PvReadSection(
        heading: _en('What do Indian studies show?'),
        paragraphs: [
          _en('Indian studies put depression in pregnancy at around one woman '
              'in six, higher than many Western estimates. The strongest links '
              'are a lack of support from the partner or family, pressure '
              "about the baby's sex, and money worries."),
          _en("A breathing exercise won't fix those. A conversation with your "
              'doctor, and sometimes a counsellor, can be a start.'),
        ],
      ),
      PvReadSection(
        heading: _en('What helps?'),
        bullets: [
          _en('Exercise. Thirty minutes of walking most days lowers anxiety '
              'scores in pregnant women, trial after trial.'),
          _en('Protected sleep. Sleeplessness in pregnancy can be treated, and '
              'it drives low mood in its own right.'),
          _en('Yoga and breathing practice: small but consistent drops in '
              'anxiety in Indian and international trials.'),
          _en('Someone to talk to. A partner who is involved, a mother or '
              'friend who visits, a group of other mothers. Support is what '
              'changes outcomes most.'),
          _en('Treatment when it is needed. Talking therapy comes first. '
              'Several antidepressants are used safely in pregnancy, and '
              'untreated depression carries its own risks. That decision '
              'belongs with your doctor, not with anyone who tells you to stop '
              'a medicine.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about the guilt?'),
        paragraphs: [
          _en('Reading that stress can affect a baby almost always causes more '
              'stress. So, plainly: the effects are small, they are averages, '
              "and support reduces them. A hard month doesn't damage a child."),
          _en('The one action the research points to is telling someone. If '
              "this piece sounds like you, that's the next step, and it isn't "
              'a failure.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why is the word "stress" so confusing?'),
        paragraphs: [
          _en('Part of the confusion is that one word covers a deadline, a '
              'bereavement and a diagnosis. The research uses tested '
              'questionnaires, like the Edinburgh scale for depression and the '
              'state-trait inventory for anxiety. These measure a lasting '
              'state, not a bad afternoon.'),
          _en('When a headline says "stress in pregnancy affects the baby", '
              'it is reporting a study of women who scored in the clinical '
              'range for weeks. And it is reporting an average difference of '
              'days of pregnancy or grams of birth weight. Those are real and '
              "worth acting on. They are not what happens to a child because "
              'their mother had a hard week at work.'),
          _en('The one thing that consistently softens the effect is support: '
              "a partner who helps, a family that doesn't add pressure, a "
              'friend who listens. The stress that matters is the unsupported '
              'kind, and support is something other people can give.'),
        ],
      ),

      PvReadSection(
        heading: _en('Is there a five-minute practice that helps?'),
        paragraphs: [
          _en('If you want one, slow breathing has the most consistent '
              'evidence in pregnancy. Breathe in for four seconds and out for '
              'six, for five minutes, twice a day. It lowers heart rate and '
              'measured anxiety within the session. It is also the breathing '
              "you'll be asked to do in labour, so the practice isn't wasted."),
          _en("It isn't a treatment for depression, and it doesn't replace "
              "telling someone. It's five minutes that are yours."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Talk to your doctor this week if'),
      body: _en("You've felt low, flat or anxious most days for two weeks or "
          "more, you can't sleep even when you have the chance, you've "
          'stopped enjoying things, you feel unsafe at home, or you have '
          'thoughts of harming yourself. Say it in whatever words you have. '
          'Depression and anxiety in pregnancy are common, can be treated, '
          'and are nothing to be ashamed of.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('I had a very stressful month. Have I harmed the baby?'),
        answer: _en('No. The links in the research are with distress that '
            'lasts across the pregnancy without support, and even those are '
            'small averages. One hard month is not on that scale.'),
      ),
      PvReadFaq(
        question: _en('Should I stop my antidepressant?'),
        answer: _en('Not on your own. Many are used safely in pregnancy, and '
            'stopping suddenly carries risks of its own. Talk it through with '
            'the doctor who prescribed it and your obstetrician together.'),
      ),
      PvReadFaq(
        question: _en('Where can I get help in India?'),
        answer: _en('Your obstetrician first. Many hospitals have a counsellor. '
            'The national Tele-MANAS helpline (14416) is free and open around '
            'the clock.'),
      ),
    ],
    evidence: _en('Glover, Best Practice & Research Clinical Obstetrics & '
        'Gynaecology (2014); Stein et al., Lancet (2014) on perinatal '
        'mental disorders; Fisher et al., Bulletin of the WHO (2012) on '
        'low- and middle-income countries; Upadhyay et al., Bulletin of '
        'the WHO (2017) on antenatal depression in India; Cochrane review '
        'on exercise for antenatal depression (2018).'),
    readNext: ['${kPregWeekReadPrefix}partner_support', '${kPregWeekReadPrefix}exp_priya'],
  ),
];
