// =============================================================================
//  Pregnancy reads — the weekly reads, written out (d: expert and research)
// -----------------------------------------------------------------------------
//  See pregnancy_reads_weekly_a.dart. The two "expert" items keep their
//  named authors (a paediatrician, a lactation consultant — the seed's own
//  cast); the three "research" items are editorial and cite the studies
//  they summarise. Same bar, same clinical rules.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import 'pregnancy_reads_weekly_a.dart' show kPregWeekReadPrefix;

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kPregnancyReadsWeeklyD = [
  // ---------------------------------------------------------------------------
  //  exp_priya · weeks 16–40
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}exp_priya',
    hue: 275,
    kicker: _en('Expert note'),
    title: _en('Building emotional connection before birth'),
    teaser: _en('Bonding does not start in the delivery room. A paediatrician '
        'on what attachment actually is, why some parents feel nothing yet, '
        'and the small habits that build it.'),
    scaleSetter: _en('Attachment is not a feeling that arrives; it is a '
        'pattern of responding that gets built. Parents who talk to, touch '
        'and think about the baby before birth tend to find the first weeks '
        'afterwards less bewildering — not because the baby is different, '
        'but because the habit of noticing is already there.'),
    author: _en('Dr. Priya Sharma'),
    authorRole: _en('Paediatrician · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('In clinic I meet two kinds of expectant parents who worry about '
            'bonding. The first felt an instant, overwhelming love at the '
            'scan and are frightened it will fade. The second felt nothing '
            'in particular and are frightened that means something. Both '
            'are normal, and neither predicts how the relationship with the '
            'child will go. Prenatal attachment — the term researchers use '
            '— is not measured in feelings. It is measured in behaviour: '
            'whether you think about the baby as a person, whether you '
            'respond to movements, whether you have begun to imagine '
            'caring for it.'),
      ]),
      PvReadSection(
        heading: _en('What the evidence actually shows'),
        paragraphs: [
          _en('Studies that follow women from the second trimester find that '
              'higher prenatal attachment — the behavioural kind — is '
              'associated with more sensitive responding to the baby in the '
              'first months and with lower rates of postnatal depression. '
              'The link is modest and it is not a verdict on anyone; it '
              'says that the habits below are worth having, not that '
              'lacking them harms a child.'),
          _en('The strongest single predictor of a difficult start is not '
              'low bonding in pregnancy. It is an unsupported mother — '
              'without help, sleep, or someone to talk to. That is why the '
              'partner piece in this rail matters more than any bonding '
              'exercise.'),
        ],
      ),
      PvReadSection(
        heading: _en('Habits that build it'),
        bullets: [
          _en('Respond to movements. When the baby kicks, put a hand there '
              'and say something. You are practising the loop — notice, '
              'respond — that runs the first year.'),
          _en('Give the baby a name to use now, even a nickname. People '
              'bond to persons, not to "the baby".'),
          _en('Talk about the baby as someone with a temperament: "she is '
              'always awake after dinner." You are probably right, and it '
              'is the beginning of knowing them.'),
          _en('Involve the partner in the same habits. Fathers who talk to '
              'the bump report stronger attachment at three months, and the '
              'baby knows the voice.'),
          _en('Look after the mother. Sleep, food, and someone to say the '
              'worries to. Attachment is easier in a body that is not '
              'exhausted.'),
        ],
      ),
      PvReadSection(
        heading: _en('When bonding is hard'),
        paragraphs: [
          _en('An unplanned pregnancy, a previous loss, a difficult '
              'relationship, depression or anxiety, and a pregnancy after '
              'IVF all make it harder to let yourself attach — often as '
              'self-protection. None of these means you will not bond with '
              'the child. It does mean the second and third trimesters are '
              'the time to say so to your doctor, because antenatal '
              'depression is common (around one woman in eight), '
              'treatable, and the thing most likely to get in the way.'),
        ],
      ),
      PvReadSection(
        heading: _en('And after the birth'),
        paragraphs: [
          _en('Skin-to-skin in the first hour, rooming in rather than a '
              'nursery, and feeding on demand are the three hospital '
              'practices with evidence for early bonding. Ask for them in '
              'your birth plan. And if the first days bring nothing but '
              'exhaustion and a stranger who cries — that, too, is a normal '
              'start, and it changes.'),
        ],
      ),

      PvReadSection(
        heading: _en('The older sibling'),
        paragraphs: [
          _en('If there is already a child, attachment to the new baby is '
              'usually not the worry; the worry is the older one. Children '
              'under three do not understand a pregnancy and do not need '
              'to; a two-year-old told "a baby is coming" in month four '
              'has forgotten by month five. Tell them close to the birth, '
              'let them feel the kicks, and give them a small job that is '
              'theirs — fetching the nappy, choosing the baby\'s first '
              'song. The regression that often follows a birth — the '
              'toilet-trained three-year-old who wets again — is normal and '
              'brief, and it is easier to meet with patience if it was '
              'expected.'),
          _en('And keep one small ritual unchanged through the whole period '
              '— the bedtime story, the Sunday walk. A child who keeps one '
              'thing that was theirs adjusts to sharing everything else.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Talk to your doctor this week if'),
      body: _en('You have felt low, flat or anxious most days for two weeks '
          'or more, cannot sleep even when you can, have lost interest in '
          'the pregnancy or in things you liked, or have thoughts of '
          'harming yourself. Antenatal depression is common and treatable, '
          'and it is the thing most likely to get between you and the '
          'baby — which is exactly why it is worth saying out loud.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('I feel nothing yet. Is something wrong?'),
        answer: _en('No. Many parents feel little until the baby is in their '
            'arms, and some not for weeks after. The behaviours above build '
            'the relationship; the feeling follows at its own pace.'),
      ),
      PvReadFaq(
        question: _en('Does a difficult birth affect bonding?'),
        answer: _en('It can delay it, particularly after an emergency '
            'caesarean or a NICU stay, and that delay is not permanent. '
            'Skin-to-skin as soon as it is possible helps.'),
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
    kicker: _en('Expert note'),
    title: _en('Why early breastfeeding preparation helps'),
    teaser: _en('A lactation consultant on the three things worth knowing '
        'before the first feed, and why the first week goes better for '
        'women who learnt them in the third trimester.'),
    scaleSetter: _en('Breastfeeding is natural and it is also learnt — by you '
        'and by the baby, together, in the first week. The women I see '
        'struggling on day three are almost never the ones who cannot '
        'feed. They are the ones who did not know what normal looked like '
        'and assumed the worst. Half an hour of preparation in the third '
        'trimester prevents most of that.'),
    author: _en('Dr. Meera Nair'),
    authorRole: _en('Lactation consultant · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('The body prepares on its own. From mid-pregnancy the breasts '
            'make colostrum; some women leak a little in the last weeks, '
            'most do not, and neither tells you anything about supply. '
            'Nothing needs to be done to the nipples — the old advice to '
            '"toughen" them with a towel does harm. What needs preparing is '
            'the knowledge.'),
      ]),
      PvReadSection(
        heading: _en('The first thing: what normal looks like'),
        paragraphs: [
          _en('Day one, a few millilitres of colostrum per feed, eight to '
              'twelve feeds, and a baby that sleeps a lot. Day two, a baby '
              'that feeds almost constantly through the evening and night — '
              'the "second night" that convinces many mothers they have no '
              'milk. They do; the baby is placing the order. Day three or '
              'four, the milk comes in, the breasts feel full and hot, and '
              'the baby settles. By day five, six wet nappies and yellow '
              'stools. Knowing that sequence in advance is the single most '
              'useful thing.'),
        ],
      ),
      PvReadSection(
        heading: _en('The second: the latch'),
        paragraphs: [
          _en('A good latch is wide, deep and off-centre — more of the areola '
              'in the baby\'s mouth below the nipple than above it, chin '
              'pressed in, nose free, lips turned out. It should not hurt '
              'beyond the first seconds. Pain that continues through a feed '
              'means the latch is shallow, and the fix is to take the baby '
              'off (a finger in the corner of the mouth) and start again, '
              'not to endure it. Sore nipples are a latch problem, not a '
              'toughness problem.'),
          _en('Watch a video of a latch before the birth, and ask the '
              'lactation nurse to watch a feed on day one, while someone is '
              'there to correct it.'),
        ],
      ),
      PvReadSection(
        heading: _en('The third: what to refuse'),
        bullets: [
          _en('A bottle of formula "just for tonight" on day two, unless a '
              'paediatrician has a medical reason. It is the commonest way '
              'supply is undermined, because the order for milk is placed '
              'by the baby at the breast.'),
          _en('Honey, ghutti, janam ghutti, sugar water — any pre-lacteal '
              'feed. Colostrum is the first food, and honey carries a real '
              'risk of infant botulism.'),
          _en('A schedule. Newborns feed on cue, eight to twelve times a '
              'day; the clock comes later.'),
          _en('Advice that your milk is "thin" or "not enough" from someone '
              'who has not weighed the baby. Weight and nappies are the '
              'measures; opinion is not.'),
        ],
      ),
      PvReadSection(
        heading: _en('Set up before the birth'),
        paragraphs: [
          _en('Find out whether your hospital has a lactation consultant and '
              'ask for her on day one. Buy two nursing bras a size up and a '
              'tube of purified lanolin. Decide with your partner who will '
              'field the relatives\' feeding advice so that you do not have '
              'to. And if you have flat or inverted nipples, a previous '
              'breast surgery, or a baby expected early, ask for a '
              'lactation appointment in the third trimester — the plan is '
              'different and it is better made in advance.'),
        ],
      ),

      PvReadSection(
        heading: _en('The questions I am asked most'),
        paragraphs: [
          _en('"Will my breasts be big enough?" Size has nothing to do with '
              'supply; the milk-making tissue is the same and the rest is '
              'fat. "Is my milk thin?" Foremilk looks watery and hindmilk '
              'looks creamy, and both are right. "How do I know the baby is '
              'getting enough?" Wet nappies — six or more a day from day '
              'five — and weight, checked at the paediatrician\'s. Not the '
              'clock, not the crying, not a relative\'s opinion. "Can I eat '
              'what I like?" Yes; there is no food a breastfeeding mother '
              'must avoid, and the long lists in circulation are '
              'tradition, not evidence. "How long?" Exclusively for six '
              'months if you can, alongside food to two years if you want '
              'to, and for exactly as long as works for you and the baby — '
              'which is a decision, not a test.'),
        ],
      ),

      PvReadSection(
        heading: _en('The one number to remember'),
        paragraphs: [
          _en('Six. Six or more wet nappies a day from day five means the '
              'baby is getting enough, whatever anyone in the room believes '
              'about the size of your breasts, the colour of the milk, or '
              'the length of the feed. Count nappies, weigh at the '
              'paediatrician\'s, and let everything else be opinion.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Ask for help the same day if, after the birth'),
      body: _en('The baby has fewer than six wet nappies a day after day '
          'five, is sleepy and hard to wake for feeds, is yellow and '
          'getting more so, or has lost more than a tenth of its birth '
          'weight; or you have a hot, red, painful area of the breast with '
          'fever. None of these means stopping; all of them mean a '
          'paediatrician or lactation consultant that day.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should I pump before the birth?'),
        answer: _en('Not routinely. Hand-expressing colostrum from 36 weeks '
            'is sometimes advised for women with diabetes or an expected '
            'early birth; ask your doctor before starting, as it can bring '
            'on contractions.'),
      ),
      PvReadFaq(
        question: _en('Can I breastfeed after a caesarean?'),
        answer: _en('Yes. Skin-to-skin in the theatre or recovery room and a '
            'side-lying or football hold that keeps the baby off the wound '
            'are the two things to ask for.'),
      ),
      PvReadFaq(
        question: _en('What if I decide to use formula?'),
        answer: _en('Then you will feed your baby well. Preparation still '
            'helps — how to make it up safely, how much and how often — and '
            'the lactation consultant can advise on both.'),
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
    teaser: _en('Four decades of experiments, one consistent finding: a '
        'newborn already knows its mother\'s voice, and what it heard most '
        'in the last trimester.'),
    scaleSetter: _en('In 1980 two psychologists gave newborns a dummy wired to '
        'a tape recorder and found that babies a day old would change how '
        'they sucked in order to hear their own mother\'s voice rather than '
        'another woman\'s. Everything since has refined that result and '
        'nothing has overturned it.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('The DeCasper and Fifer experiment worked because newborns '
            'cannot be asked, but they can be given a choice. Sucking in '
            'one rhythm played the mother; another rhythm played a '
            'stranger. Ten of twelve babies learnt within minutes to '
            'produce the rhythm that brought their mother\'s voice. The '
            'only way that preference could exist on day one is if it was '
            'formed before birth.'),
      ]),
      PvReadSection(
        heading: _en('What exactly is learnt'),
        paragraphs: [
          _en('A follow-up in 1986 had mothers read a particular story — '
              '"The Cat in the Hat" — aloud twice a day for the last six '
              'weeks of pregnancy. After birth, the babies preferred that '
              'story to a new one, even when both were read by a stranger. '
              'So it is not only the voice: it is the rhythm and melody of '
              'a specific, repeated passage. Babies learn prosody in the '
              'womb, which is why newborns\' cries carry the melody of '
              'their parents\' language, French babies rising and German '
              'babies falling, within days of birth.'),
        ],
      ),
      PvReadSection(
        heading: _en('How much reaches the womb'),
        paragraphs: [
          _en('Recordings made inside the uterus show that the mother\'s '
              'voice arrives clearly, carried through her body as well as '
              'through the air, at a level above the background of '
              'heartbeat and gut. Other voices arrive muffled, the '
              'consonants lost and the melody kept. That is why the '
              'mother\'s voice is learnt strongly, the father\'s and '
              'siblings\' voices weakly but reliably if heard often, and '
              'the television not at all.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why it matters after birth'),
        bullets: [
          _en('Newborns calm faster to their mother\'s voice than to any '
              'other sound, including recordings of other women.'),
          _en('Premature babies in intensive care who hear recordings of '
              'their mother\'s voice show steadier heart rates and, in some '
              'studies, better feeding.'),
          _en('The voice is a bridge across the birth: the one thing that is '
              'the same on both sides of it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What it does not mean'),
        paragraphs: [
          _en('It does not mean the baby understands words, learns a '
              'language, or is made cleverer. Products that promise any of '
              'that are selling past the evidence. It means that ordinary '
              'talking, singing and reading aloud in the last trimester '
              'give the baby something it will recognise on the first day '
              'of a very strange new world — and that is enough.'),
        ],
      ),

      PvReadSection(
        heading: _en('How the experiments were done'),
        paragraphs: [
          _en('Every study of what a newborn knows has the same problem: '
              'the subject cannot answer. The solutions are ingenious and '
              'worth knowing, because they are why the findings can be '
              'trusted. Sucking rate is one: babies suck in bursts, the '
              'pattern can be measured, and a baby who changes it to get a '
              'reward has shown a preference. Head-turning is another — a '
              'baby will turn toward a sound it prefers. Heart rate is a '
              'third; it slows briefly when a baby attends to something '
              'familiar. And in the last decade, brain recordings through '
              'a soft cap have shown the response to a known tune directly '
              'in the cortex.'),
          _en('Each of these methods, on its own, could be doubted. Together, '
              'across forty years and several countries, they agree, which '
              'is what makes a small finding in a psychology laboratory '
              'into something a pregnant woman can act on with a nursery '
              'rhyme.'),
        ],
      ),

      PvReadSection(
        heading: _en('What to do with it'),
        paragraphs: [
          _en('Talk, sing, and read aloud in the last trimester, in your own '
              'language, at ordinary volume. Repeat one thing — a song, a '
              'verse, a page — most days. Let your partner do the same. '
              'None of it needs equipment or a schedule; it needs the '
              'habit, and the habit is what the studies measured. The '
              'reward is a newborn who, in the first hours of a strange '
              'world, already knows two voices in it.'),
        ],
      ),

      PvReadSection(
        heading: _en('The limits of what is known'),
        paragraphs: [
          _en('Most of this research was done on full-term babies born to '
              'mothers speaking one language, in laboratories in Europe '
              'and North America. Whether a baby raised in a household of '
              'three languages sorts them before birth, and how much a '
              'grandmother\'s daily voice registers beside a mother\'s, are '
              'open questions. What holds across every study is the '
              'simple version: the voice heard most, from the body it '
              'comes from, is the one the baby knows first.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A general note, and one thing to act on'),
      body: _en('Nothing about hearing in pregnancy is an emergency. The one '
          'related thing that is: from 28 weeks, if the baby\'s movements '
          'drop noticeably for a day — including no response to the voice '
          'or touch that usually gets one — call your doctor the same day.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('From what week can the baby hear me?'),
        answer: _en('Responses to sound are seen from about 24 weeks and are '
            'consistent by 28; the learning shown in these studies happened '
            'in the last six to twelve weeks.'),
      ),
      PvReadFaq(
        question: _en('Will the baby know my partner\'s voice?'),
        answer: _en('If it is heard often and close, yes — less strongly than '
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
    title: _en('Music and the womb: what is actually known'),
    teaser: _en('Babies remember a tune from before birth. They do not get '
        'cleverer from Mozart. What the studies found, and what they '
        'did not.'),
    scaleSetter: _en('Music in pregnancy sits between two exaggerations: the '
        'claim that it builds intelligence, and the dismissal that it does '
        'nothing. The evidence is in the middle and it is rather lovely — '
        'a baby can carry a melody across the birth, and a calmer mother '
        'is the effect that reaches the baby most.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('In 2013 a Helsinki group played "Twinkle Twinkle Little Star" '
            'to babies in the womb five times a week for the last trimester. '
            'After birth, and again at four months, those babies\' brains '
            'responded more strongly to the tune — and to a version with '
            'notes changed — than the brains of babies who had not heard '
            'it. The memory was specific and it lasted. An earlier British '
            'study found newborns quietened to the theme of a soap opera '
            'their mothers had watched daily, and not to other music.'),
      ]),
      PvReadSection(
        heading: _en('The Mozart effect, and why it is not one'),
        paragraphs: [
          _en('The 1993 study behind the phrase found that university '
              'students did slightly better on a spatial puzzle for about '
              'fifteen minutes after listening to a Mozart sonata. It said '
              'nothing about babies, nothing about the womb, and nothing '
              'lasting. Later work found the same short boost from any '
              'music the listener enjoyed. Products that play classical '
              'music to the bump to raise IQ are built on a study that '
              'never made that claim.'),
        ],
      ),
      PvReadSection(
        heading: _en('What music does do'),
        bullets: [
          _en('Lowers maternal anxiety and blood pressure in several trials, '
              'including in Indian antenatal clinics — the effect on the '
              'mother is the best-evidenced one.'),
          _en('Changes the baby\'s heart rate and movement in response to '
              'sound, from about 28 weeks — a sign of hearing, not of '
              'preference.'),
          _en('Builds a memory for a specific repeated tune that persists '
              'for months after birth and can settle a newborn.'),
          _en('Gives a partner a way in: a song sung nightly by the '
              'father\'s voice is the one the baby is most likely to know '
              'him by.'),
        ],
      ),
      PvReadSection(
        heading: _en('How to do it, if you want to'),
        paragraphs: [
          _en('Play music you like, at conversation volume, in the room — '
              'not on headphones pressed to the belly, which bypass the '
              'fluid\'s protection and add nothing. Choose one or two pieces '
              'to repeat if you want the baby to know them. Sing; your own '
              'voice reaches the baby better than any speaker. And treat '
              'the twenty minutes as yours, because the mother\'s calm is '
              'the measurable part.'),
        ],
      ),

      PvReadSection(
        heading: _en('The Indian tradition, and what it gets right'),
        paragraphs: [
          _en('Garbh sanskar — the practice of shaping the child in the '
              'womb through what the mother hears, reads and thinks — long '
              'predates the laboratory, and its central claim, that the '
              'baby is affected by the mother\'s state, is the one the '
              'evidence supports. Where the modern research parts from the '
              'tradition is in the mechanism: it is not the raga or the '
              'text that reaches the baby but the calm of the woman '
              'listening to it, and the melody she repeats.'),
          _en('So the honest version of the practice is the traditional '
              'one with the promises trimmed. Sit, listen to something you '
              'love, sing it, do it most evenings. The baby will know it, '
              'and you will have had twenty minutes of quiet a day for '
              'three months, which no study has ever found harmful.'),
        ],
      ),

      PvReadSection(
        heading: _en('A short reading list, for the curious'),
        paragraphs: [
          _en('The Helsinki study (Partanen and colleagues, 2013) is short, '
              'open-access and readable. Hepper\'s 1991 paper on the soap '
              'opera theme is the origin of the "babies remember music" '
              'finding. And the 2010 meta-analysis by Pietschnig and '
              'colleagues, titled bluntly "Mozart effect — Shmozart '
              'effect", is where the intelligence claim was laid to rest; '
              'it is worth having to hand the next time a relative sends a '
              'link.'),
        ],
      ),

      PvReadSection(
        heading: _en('And the one caution'),
        paragraphs: [
          _en('The only harm in any of this is the harm of a promise. A '
              'mother who plays a raga every evening because she enjoys it '
              'has lost nothing if the baby turns out ordinary. A mother '
              'who plays it because a product told her it would raise an '
              'IQ, and who feels she failed when the school reports arrive, '
              'has been sold something. Buy the music, if you like. Do not '
              'buy the claim. The evidence supports the pleasure and the '
              'memory, and nothing more — which, read again, is quite a lot.'),
          _en('And if you find that music in the evening is the only time '
              'in the day the house is quiet, then it has done the job the '
              'research actually measured, and you can stop reading '
              'studies.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A general note, and one thing to act on'),
      body: _en('Nothing here is clinical. Sustained loud noise at work — '
          'above about 85 decibels for a full shift — is the one sound '
          'exposure with evidence of harm, and is a reason to ask for a '
          'quieter posting from the second trimester. And from 28 weeks, '
          'reduced movements are always a same-day call.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is classical music better?'),
        answer: _en('No. The studies used lullabies, pop, film themes and '
            'Mozart; what mattered was repetition and the mother\'s '
            'enjoyment.'),
      ),
      PvReadFaq(
        question: _en('Can loud concerts harm the baby?'),
        answer: _en('An occasional event does not. Standing by the speakers '
            'for hours is worth avoiding — not because of proven harm, but '
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
    teaser: _en('Ordinary stress does not harm a baby. Sustained, '
        'unsupported stress can. Where the line is, what the studies '
        'measured, and what actually helps.'),
    scaleSetter: _en('Every pregnant woman is told to stay calm, usually by '
        'someone adding to her stress. The research is more useful than '
        'the advice: a bad week, a hard job, an argument — these do not '
        'reach the baby. Months of anxiety or depression without support '
        'are associated with real, modest effects, and every one of them '
        'is reduced by the same thing: help.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('Stress hormones — cortisol chiefly — cross the placenta in '
            'small amounts, and the placenta itself has an enzyme that '
            'breaks most of it down. The system is built to buffer ordinary '
            'life. What the large cohort studies find is that women with '
            'high anxiety or depression scores sustained across the '
            'pregnancy have babies who are, on average, born slightly '
            'earlier and slightly lighter, and who score a little higher '
            'on measures of emotional reactivity in early childhood. The '
            'effects are small, they are averages, and they are '
            'substantially reduced when the mother has social support.'),
      ]),
      PvReadSection(
        heading: _en('What "stress" meant in the studies'),
        paragraphs: [
          _en('Not deadlines. The studies with clear effects looked at '
              'clinical anxiety and depression, bereavement, domestic '
              'violence, and severe life events sustained over weeks. A '
              'demanding job on its own, in a woman who is otherwise '
              'supported and sleeping, does not show up. The distinction '
              'matters because the advice to "avoid stress" is impossible '
              'and the advice to "get help if you are anxious or low for '
              'more than two weeks" is not.'),
        ],
      ),
      PvReadSection(
        heading: _en('India, specifically'),
        paragraphs: [
          _en('Indian studies put antenatal depression at around one woman '
              'in six, higher than many Western estimates, with the '
              'strongest associations being a lack of support from the '
              'partner or the family, pressure about the baby\'s sex, and '
              'financial strain. Those are not things a breathing exercise '
              'fixes. They are things a conversation with the doctor, and '
              'sometimes a counsellor, can begin to.'),
        ],
      ),
      PvReadSection(
        heading: _en('What helps, with evidence'),
        bullets: [
          _en('Exercise — thirty minutes of walking most days lowers anxiety '
              'scores in pregnant women in trial after trial.'),
          _en('Sleep, protected. Antenatal insomnia is treatable and is '
              'itself a driver of low mood.'),
          _en('Yoga and breathing practice: modest but consistent '
              'reductions in anxiety in Indian and international trials.'),
          _en('Someone to talk to. Partner involvement, a mother or friend '
              'who visits, a peer group. Support is the variable that '
              'changes outcomes most.'),
          _en('Treatment when it is needed. Talking therapy is first-line; '
              'several antidepressants are used safely in pregnancy, and '
              'untreated depression carries its own risks. That decision '
              'belongs with your doctor, not with anyone who tells you to '
              'stop a medicine.'),
        ],
      ),
      PvReadSection(
        heading: _en('And guilt, which does not help'),
        paragraphs: [
          _en('Reading that stress can affect a baby produces, reliably, '
              'more stress. So: the effects are small, averaged, and '
              'reduced by support; a hard month does not damage a child; '
              'and the one action the research points to is telling '
              'someone. If this piece describes you, that is the next step, '
              'and it is not a failure.'),
        ],
      ),

      PvReadSection(
        heading: _en('A word on the word "stress"'),
        paragraphs: [
          _en('Part of the confusion is that the same word covers a '
              'deadline, a bereavement and a diagnosis. The research uses '
              'validated questionnaires — the Edinburgh scale for '
              'depression, the state-trait inventory for anxiety — and '
              'those measure a sustained state, not a bad afternoon. When '
              'a headline says "stress in pregnancy affects the baby", it '
              'is reporting a study of women who scored in the clinical '
              'range for weeks, and it is reporting an average difference '
              'of days of gestation or grams of birth weight. Those are '
              'real and worth acting on. They are not what happens to a '
              'child because its mother had a hard week at work.'),
          _en('The one measure that consistently blunts the effect is '
              'social support — a partner who helps, a family that does not '
              'add pressure, a friend who listens. That is the finding to '
              'carry: the stress that matters is the unsupported kind, and '
              'support is something other people can provide.'),
        ],
      ),

      PvReadSection(
        heading: _en('Five minutes that count'),
        paragraphs: [
          _en('If a practice is wanted, the one with the most consistent '
              'evidence in pregnancy is slow breathing — four seconds in, '
              'six out, for five minutes, twice a day. It lowers heart '
              'rate and measured anxiety within the session, and it is the '
              'breathing that will be asked of you in labour, so the '
              'practice is not wasted. It is not a treatment for '
              'depression, and it is not a substitute for telling someone. '
              'It is five minutes that are yours.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Talk to your doctor this week if'),
      body: _en('You have felt low, flat or anxious most days for two weeks '
          'or more; you cannot sleep even when you have the chance; you '
          'have stopped enjoying things; you feel unsafe at home; or you '
          'have thoughts of harming yourself. Say it in the words you have. '
          'Antenatal depression and anxiety are common, treatable, and '
          'nothing to be ashamed of.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('I had a very stressful month. Have I harmed the baby?'),
        answer: _en('No. The associations in the research are with sustained, '
            'unsupported distress over the pregnancy, and even those are '
            'small averages. One hard month is not on that scale.'),
      ),
      PvReadFaq(
        question: _en('Should I stop my antidepressant?'),
        answer: _en('Not on your own. Many are used safely in pregnancy, and '
            'stopping suddenly carries risks of its own. Discuss it with the '
            'doctor who prescribed it and your obstetrician together.'),
      ),
      PvReadFaq(
        question: _en('Where can I get help in India?'),
        answer: _en('Your obstetrician first; many hospitals have a '
            'counsellor. The national Tele-MANAS helpline (14416) is free '
            'and available around the clock.'),
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
