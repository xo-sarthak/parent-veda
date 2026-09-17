// =============================================================================
//  Pregnancy reads — the weekly reads, written out (b: weeks 18–36)
// -----------------------------------------------------------------------------
//  See pregnancy_reads_weekly_a.dart for why these exist and the bar they
//  are written to. Same clinical rules; nothing here reads HER result.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import 'pregnancy_reads_weekly_a.dart' show kPregWeekReadPrefix;

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

const double _hue = 344;

final List<PvRead> kPregnancyReadsWeeklyB = [
  // ---------------------------------------------------------------------------
  //  halfway · weeks 18–22
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}halfway',
    hue: _hue,
    kicker: _en('Second trimester'),
    title: _en('You are halfway — what changes now'),
    teaser: _en('Twenty weeks: the scan that looks at everything, the first '
        'flutters, a bump that is finally a bump, and the sleep position '
        'question.'),
    scaleSetter: _en('Week twenty is the middle of the pregnancy and, for '
        'most women, the best of it. The nausea has gone, the tiredness has '
        'eased, the baby is big enough to feel and not yet big enough to be '
        'in the way. It is also the week of the most detailed scan you will '
        'have, which is why it deserves a plan rather than a walk-in.'),
    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('The baby at twenty weeks is about 25 centimetres from head to '
            'heel and around 300 grams — the length of a banana, in the '
            'usual comparison. The skin is covered in vernix, a waxy layer, '
            'and fine hair called lanugo. The baby swallows amniotic fluid, '
            'practises breathing movements, sleeps and wakes in cycles, and '
            'can hear. The uterus has reached your navel; from here it rises '
            'about a centimetre a week, and the fundal height your doctor '
            'measures in centimetres roughly matches the week.'),
      ]),
      PvReadSection(
        heading: _en('The first movements'),
        paragraphs: [
          _en('Quickening — the first felt movement — arrives between weeks '
              '16 and 24, later in a first pregnancy and earlier when the '
              'placenta is at the back. It feels like bubbles, a flutter, or '
              'a fish turning; many women mistake it for wind for a week. '
              'By 24 weeks the movements are unmistakable, and from 28 weeks '
              'you will be asked to know your baby\'s pattern.'),
          _en('If you have not felt anything by 24 weeks, say so at your next '
              'visit. It is usually a matter of placental position and your '
              'own build, and a quick listen settles it.'),
        ],
      ),
      PvReadSection(
        heading: _en('The anomaly scan'),
        paragraphs: [
          _en('Between 18 and 22 weeks — in India most often at 19 to 20 — '
              'the anomaly or "level II" scan checks the baby\'s brain, '
              'face, spine, heart, stomach, kidneys, bladder and limbs, '
              'measures growth, and locates the placenta. It takes twenty '
              'to forty minutes and is the one scan worth taking your '
              'partner to. There is a full piece on getting the most from '
              'it in the rail below.'),
        ],
      ),
      PvReadSection(
        heading: _en('Your body, this month'),
        bullets: [
          _en('Round ligament pain: a sharp pull low on one side when you '
              'turn over or stand up fast. Normal, and it passes in seconds. '
              'Pain that lasts or comes with bleeding is different — call.'),
          _en('Sleeping on your side, ideally from about 28 weeks, is advised '
              'because lying flat lets the uterus press on the large vein '
              'returning blood to the heart. Start the habit now; a pillow '
              'between the knees helps.'),
          _en('The linea nigra, a dark line down the belly, and darker '
              'patches on the face (melasma) are hormonal and fade after '
              'birth. Sunscreen limits the face.'),
          _en('Nasal stuffiness and bleeding gums — more blood flowing '
              'through softer tissue. A saline spray and a soft brush.'),
          _en('Leg cramps at night. Stretch the calf before bed, keep up '
              'fluids and calcium; magnesium is sometimes suggested.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to book now'),
        paragraphs: [
          _en('The glucose tolerance test falls at 24 to 28 weeks; the Tdap '
              'vaccine at 27 to 36 weeks; the growth scan around 28 to 32. '
              'If you plan a birth class, the third trimester fills up — '
              'book it this month. And if you have not yet chosen where to '
              'deliver, the second trimester is when to visit two hospitals '
              'and ask what a normal delivery and a caesarean each cost, '
              'and what their caesarean rate is.'),
        ],
      ),

      PvReadSection(
        heading: _en('What people ask at twenty weeks'),
        paragraphs: [
          _en('Is it too late to start exercising? No — walking thirty '
              'minutes most days, started now, is what the guidelines '
              'recommend and it helps with the glucose test to come, with '
              'back pain and with sleep. Can I have sex? Yes, in a normal '
              'pregnancy, throughout. Can I dye my hair, paint the nursery, '
              'get a pedicure? Yes, in a ventilated room, and yes. Can I '
              'fast for a festival? Talk to your doctor; a day of fasting '
              'with fluids is usually fine in an uncomplicated pregnancy, '
              'and a dry fast is not advised.'),
          _en('Should I be taking a specific supplement now? Iron and '
              'calcium, if prescribed, and the folic acid can usually stop '
              'after twelve weeks unless your doctor has said otherwise. '
              'Vitamin D is low in most Indian women and worth a check. '
              'Beyond that, the plate does more than the pharmacy.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en('You have bleeding, a gush or steady trickle of fluid, '
          'contractions or a tightening that comes regularly, a severe '
          'headache with vision changes, sudden swelling of the face or '
          'hands, or pain on passing urine with fever. These are checked '
          'the same day at any stage.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is it safe to sleep on my back?'),
        answer: _en('Before 28 weeks, yes. After that, side-sleeping is '
            'advised; if you wake on your back, simply turn — waking is '
            'the body\'s own alarm.'),
      ),
      PvReadFaq(
        question: _en('My bump is smaller than a friend\'s at the same week. '
            'Should I worry?'),
        answer: _en('Bumps vary with height, muscle tone, number of previous '
            'pregnancies and placental position. The measure that matters '
            'is the fundal height your doctor takes, and the growth scan.'),
      ),
      PvReadFaq(
        question: _en('Can I still travel by air?'),
        answer: _en('Most airlines allow it to 36 weeks in a single pregnancy '
            'with a fit-to-fly letter after 28. The second trimester is the '
            'most comfortable time to go.'),
      ),
    ],
    evidence: _en('NICE NG201 Antenatal care (2021); RCOG Green-top '
        'Guideline 57 on reduced fetal movements; Tommy\'s / Sleep on Side '
        'evidence summary (2019); FOGSI antenatal schedule.'),
    readNext: ['${kPregWeekReadPrefix}anomaly_scan', '${kPregWeekReadPrefix}back_pain'],
  ),

  // ---------------------------------------------------------------------------
  //  anomaly_scan · weeks 18–22
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}anomaly_scan',
    hue: 206,
    kicker: _en('Scans & tests'),
    title: _en('Making the most of the anomaly scan'),
    teaser: _en('The longest look anyone takes at your baby before birth. '
        'What is checked, what "soft markers" mean, and the questions to '
        'ask before you leave the room.'),
    scaleSetter: _en('The anomaly scan is a survey, not a verdict. In more '
        'than nineteen pregnancies out of twenty it finds nothing to act on. '
        'When it does find something, it is most often a finding to watch '
        'rather than a diagnosis — and knowing the difference before you go '
        'in is what keeps a twenty-minute scan from becoming a fortnight of '
        'fear.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Radiologist · 17 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('Done between 18 and 22 weeks, the scan works through the baby '
            'system by system. The head and brain — the shape of the skull, '
            'the ventricles, the cerebellum. The face — the lips, the '
            'profile. The spine, along its length. The heart — four chambers '
            'and the vessels leaving it, which is the part that takes '
            'longest and depends most on the baby\'s position. The stomach, '
            'kidneys and bladder. The abdominal wall. Arms, legs, hands, '
            'feet. Then the placenta, its position and the cord, and the '
            'amount of fluid.'),
        _en('Measurements are taken as it goes: head circumference, '
            'abdominal circumference, femur length. Together they estimate '
            'weight and confirm the baby is growing in step with its dates.'),
      ]),
      PvReadSection(
        heading: _en('Before you go'),
        bullets: [
          _en('Take your partner or someone who can hold the questions. The '
              'sonographer concentrates; you may not be able to.'),
          _en('Eat normally; a full bladder is not usually needed at this '
              'stage. Wear a two-piece outfit.'),
          _en('Bring the dating scan report so the dates are consistent.'),
          _en('Expect quiet. Sonographers are trained to check before they '
              'speak, and silence during the heart views is normal, not '
              'ominous.'),
          _en('Ask at the start whether they will explain as they go or at '
              'the end, so you know which silence you are in.'),
        ],
      ),
      PvReadSection(
        heading: _en('"Soft markers", and why they are not findings'),
        paragraphs: [
          _en('A soft marker is a small variation — a bright spot in the '
              'heart (echogenic focus), slightly enlarged kidney pelvises, a '
              'choroid plexus cyst, a single umbilical artery — that on its '
              'own means very little and that most babies with it are '
              'entirely well. Some markers were once used to adjust the '
              'chance of a chromosomal condition; with modern blood '
              'screening (NIPT) available, most on their own change '
              'nothing. If one is noted, the right question is: "Does this '
              'change what you recommend?" Often the honest answer is no.'),
        ],
      ),
      PvReadSection(
        heading: _en('When the scan needs a second look'),
        paragraphs: [
          _en('Sometimes the baby\'s position hides the heart or the spine, '
              'and you are asked to walk, have a sweet drink, and come back '
              '— or to return in a fortnight. That is the commonest reason '
              'for a repeat and means only that the view was not good '
              'enough. A referral to a fetal medicine specialist is the next '
              'step when something specific needs a closer or more expert '
              'look; it is an appointment, not a conclusion.'),
          _en('A low-lying placenta at twenty weeks is noted in around one '
              'pregnancy in twenty and moves up in the great majority by the '
              'third-trimester rescan. It is a reason for a follow-up scan, '
              'not for alarm.'),
        ],
      ),
      PvReadSection(
        heading: _en('Questions worth asking before you leave'),
        bullets: [
          _en('Is everything you looked for seen and normal? If not, what '
              'was not seen, and when will it be?'),
          _en('Where is the placenta, and does that need a rescan?'),
          _en('Is the growth in step with my dates?'),
          _en('Is there anything here my obstetrician should act on, or '
              'only note?'),
          _en('Can I have a copy of the report and the images today?'),
        ],
      ),

      PvReadSection(
        heading: _en('If something is found'),
        paragraphs: [
          _en('It is worth saying plainly what happens in the small minority '
              'of scans that find something, because the fear of that '
              'outcome is most of the dread going in. You will be told '
              'what was seen, in the room or by your obstetrician the same '
              'week. You will usually be referred to a fetal medicine '
              'specialist for a detailed scan, sometimes with a fetal echo '
              'for the heart. You may be offered further tests — an NIPT '
              'blood test, or an amniocentesis — and a genetic counsellor '
              'if the finding could be chromosomal.'),
          _en('Many findings are managed, not treated: a kidney that is '
              'slightly dilated is rescanned at 32 weeks and after birth; a '
              'small heart finding is checked by a paediatric cardiologist '
              'in the first week. Some need planning for the birth at a '
              'hospital with a NICU. A few are serious, and for those the '
              'conversation with your doctors is one nobody should have '
              'alone — take your partner, take notes, and ask for a second '
              'appointment once the first has sunk in.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Your report is read by your doctor'),
      body: _en('Nothing here replaces the person who ordered the scan. If a '
          'line worries you, or a repeat or referral has been suggested, '
          'take the report to your obstetrician the same week and ask what '
          'it means for you — they know your history and this page does '
          'not.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Will they tell me the sex?'),
        answer: _en('No. Under the PCPNDT Act, revealing the sex of a baby '
            'is illegal in India, and sonographers may not answer even if '
            'asked.'),
      ),
      PvReadFaq(
        question: _en('Is a 3D or 4D scan better?'),
        answer: _en('Not for checking the baby. The anomaly scan is a 2D '
            'survey by design; 3D images are for the album, and are not a '
            'substitute.'),
      ),
      PvReadFaq(
        question: _en('What does it cost?'),
        answer: _en('At private centres in Indian metros, roughly ₹2,500 to '
            '₹6,000 in 2026; more at fetal medicine units. Government '
            'hospitals do it free or for a nominal charge.'),
      ),
    ],
    evidence: _en('ISUOG practice guidelines: routine mid-trimester fetal '
        'ultrasound (2022); RCOG / Public Health England Fetal Anomaly '
        'Screening Programme handbook; the PCPNDT Act, 1994; private rate '
        'cards checked September 2026.'),
    readNext: ['preg_scan_read_calm', 'preg_scan_read_costs'],
  ),

  // ---------------------------------------------------------------------------
  //  baby_sound · weeks 20–28
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}baby_sound',
    hue: 275,
    kicker: _en('Second trimester'),
    title: _en('How babies begin responding to sound'),
    teaser: _en('The ear is built by 20 weeks and hearing by about 24. What '
        'reaches the baby, what it does with it, and why your voice is the '
        'one that matters.'),
    scaleSetter: _en('By the third trimester a baby can hear, tell one voice '
        'from another, and remember a tune well enough to calm to it after '
        'birth. None of that needs a gadget. It needs the sounds that are '
        'already there — your voice, your partner\'s, the household — and '
        'a little intention.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('The inner ear is structurally complete by around week twenty. '
            'The nerve pathways that carry sound to the brain mature over '
            'the following weeks, and by 24 to 26 weeks babies show '
            'reliable responses — a change in heart rate, a movement — to '
            'sound from outside. From about 28 weeks the response is '
            'consistent enough to be used in monitoring.'),
        _en('What reaches the baby is filtered. Amniotic fluid and the wall '
            'of the abdomen muffle high frequencies and pass low ones, so '
            'the womb is not silent — it carries your heartbeat, your '
            'digestion, the rush of blood, all at around the loudness of a '
            'quiet conversation — and voices arrive as rhythm and melody '
            'more than as words.'),
      ]),
      PvReadSection(
        heading: _en('Why your voice is different'),
        paragraphs: [
          _en('Your voice reaches the baby two ways: through the air like '
              'every other sound, and through your body, conducted by bone '
              'and tissue. That makes it the loudest and clearest voice the '
              'baby hears, and the studies bear it out: newborns suck harder '
              'to hear a recording of their mother\'s voice than a '
              'stranger\'s, and will choose a story their mother read aloud '
              'in the last trimester over one she did not.'),
          _en('A partner\'s voice, heard often and close, is recognised too '
              '— less strongly, because it arrives only through the air, but '
              'reliably. That is the evidence behind "talk to the bump", and '
              'it holds.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about music'),
        paragraphs: [
          _en('Babies respond to music in the womb and can recognise a '
              'melody after birth. What the evidence does not support is the '
              'idea that particular music makes a baby cleverer; the '
              '"Mozart effect" was a small, short-lived result in adults '
              'that never replicated in infants. The honest case for music '
              'in pregnancy is that it relaxes you, and a calmer mother is '
              'the effect that reaches the baby.'),
          _en('Volume matters more than genre. Keep it at the level of '
              'conversation. Headphones on the belly are unnecessary and, '
              'turned up, unwise — the fluid does not protect against loud '
              'sound pressed to the skin.'),
        ],
      ),
      PvReadSection(
        heading: _en('Loud places'),
        paragraphs: [
          _en('An occasional wedding, a festival procession, a film in a '
              'cinema — none of these harms the baby. Sustained loud noise '
              'at work — above about 85 decibels for a full shift, day after '
              'day, as in some factories — is associated with a small '
              'increase in hearing problems at birth and is a reason to ask '
              'for a quieter posting from the second trimester.'),
        ],
      ),

      PvReadSection(
        heading: _en('Hearing after birth, and the screening test'),
        paragraphs: [
          _en('The hearing built in the womb is checked in the first days '
              'after birth. Most hospitals in Indian cities now run a '
              'newborn hearing screen — a small earpiece that plays soft '
              'clicks while the baby sleeps and records the ear\'s echo. It '
              'takes minutes, is painless, and a "refer" result on the '
              'first day usually means fluid in the ear from the birth '
              'rather than hearing loss; a repeat at two to four weeks '
              'settles it. Ask whether your hospital does it, and ask for '
              'it if it does not offer.'),
          _en('Permanent hearing loss affects around one to three babies in '
              'a thousand, and finding it in the first months rather than '
              'the second year changes a child\'s language for life. That '
              'is the practical reason all this listening in the womb '
              'ends with a test in the ward.'),
        ],
      ),

      PvReadSection(
        heading: _en('Ultrasound, and the question people are afraid to ask'),
        paragraphs: [
          _en('Does the scan itself, which works by sound, harm the baby\'s '
              'hearing? No. Diagnostic ultrasound is far above the range of '
              'hearing, at low energy, for minutes at a time, and forty '
              'years of monitoring have found no effect on hearing or on '
              'anything else. The 3D "keepsake" scans sold in some cities '
              'are a different matter only in that they are unnecessary, '
              'not in that they are dangerous; the guidance is simply not '
              'to scan for entertainment.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A general note, and one thing to act on'),
      body: _en('Nothing about sound in pregnancy is an emergency. The one '
          'related thing that is: from 28 weeks, if the baby\'s movements '
          'drop noticeably for a day — including not responding to sounds '
          'or touch that usually get a reaction — call your doctor the same '
          'day rather than waiting to see.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can the baby hear us arguing?'),
        answer: _en('The baby hears raised voices as louder rhythm, not as '
            'meaning. What the research links to outcomes is sustained '
            'maternal stress, not a single argument.'),
      ),
      PvReadFaq(
        question: _en('Does reading in Hindi or English matter?'),
        answer: _en('No. The baby learns the rhythm and melody of whatever it '
            'hears most, which is one reason bilingual newborns respond to '
            'both. Read in the language you love.'),
      ),
      PvReadFaq(
        question: _en('When does the baby start to hear?'),
        answer: _en('Responses to sound are seen from about 24 weeks and are '
            'consistent by 28. Talking earlier does no harm and builds your '
            'own habit.'),
      ),
    ],
    evidence: _en('DeCasper & Fifer, Science (1980); DeCasper & Spence, '
        'Infant Behavior and Development (1986); Hepper & Shahidullah, '
        'Archives of Disease in Childhood (1994); ACOG Committee Opinion on '
        'occupational noise exposure.'),
    readNext: ['${kPregWeekReadPrefix}talking_baby', '${kPregWeekReadPrefix}res_voices'],
  ),

  // ---------------------------------------------------------------------------
  //  talking_baby · weeks 18–40
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}talking_baby',
    hue: 275,
    kicker: _en('For both of you'),
    title: _en('Talking to your baby before birth'),
    teaser: _en('It feels odd for about a week. Then it becomes the thing '
        'you do. What to say, when it lands, and why it is worth the '
        'awkwardness.'),
    scaleSetter: _en('There is no script. Babies do not learn words in the '
        'womb; they learn a voice, its rhythm, and the feeling of a room '
        'that is calm when it speaks. Two minutes a day, said to the bump '
        'in whatever language you think in, does the whole job.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('The case for talking to the bump is not sentimental. A baby '
            'hears from around 24 weeks, recognises its mother\'s voice at '
            'birth, and settles faster to it than to any other sound. The '
            'same is true, less strongly, of a partner\'s voice heard often. '
            'That recognition is built entirely in the last trimester, and '
            'it is built by ordinary talk.'),
        _en('The awkwardness is real and passes. Most people find it easier '
            'to narrate than to address: "I am making dal, the pressure '
            'cooker is about to go" is talking to the baby. So is reading '
            'the news aloud, or singing badly in the kitchen.'),
      ]),
      PvReadSection(
        heading: _en('When it lands'),
        bullets: [
          _en('Before 24 weeks — for you. The habit forms; the baby cannot '
              'hear yet.'),
          _en('24 to 28 weeks — the baby responds to sound, more to low '
              'voices than high ones.'),
          _en('28 weeks on — recognition builds. A phrase, a song or a '
              'passage repeated most days from here is the one the baby '
              'will know at birth.'),
        ],
      ),
      PvReadSection(
        heading: _en('Things that work'),
        paragraphs: [
          _en('Pick one thing to repeat. A lullaby, a shloka, a verse, a '
              'nursery rhyme, the same paragraph of the same book. The '
              'research that shows newborns preferring what they heard in '
              'the womb used repetition, not variety. One song sung every '
              'evening at the same time becomes, after birth, a switch.'),
          _en('Let the partner have a slot. Their voice needs more '
              'repetition to be learnt because it reaches the baby only '
              'through the air; a nightly two minutes with a hand on the '
              'belly is enough, and it is often the first way a partner '
              'feels part of a pregnancy that is otherwise happening to '
              'someone else.'),
          _en('Answer the kicks. When the baby moves, say something. It is '
              'not that the baby understands; it is that you are building a '
              'reflex of responding to your child, and that reflex is the '
              'foundation of the first year.'),
        ],
      ),
      PvReadSection(
        heading: _en('What it is not'),
        paragraphs: [
          _en('It is not a way to make a baby cleverer, and no product that '
              'claims to be one has evidence behind it. It is not a test of '
              'you as a parent; women who never talk to the bump raise '
              'children who talk fine. And it does not need a device, an '
              'app, or a speaker on the belly. Your voice, at ordinary '
              'volume, is the one sound engineered to reach the baby best.'),
        ],
      ),

      PvReadSection(
        heading: _en('A week of prompts, if a blank page is the problem'),
        bullets: [
          _en('Monday: tell the baby what you ate today and which part you '
              'liked.'),
          _en('Tuesday: read one page of whatever you are reading, out loud, '
              'even the news.'),
          _en('Wednesday: sing the song your mother sang to you, badly.'),
          _en('Thursday: describe the room you are sitting in.'),
          _en('Friday: your partner\'s turn — two minutes, hand on the '
              'belly, anything.'),
          _en('Saturday: tell the baby one thing about the family it is '
              'joining.'),
          _en('Sunday: say the same thing you said last Sunday. Repetition '
              'is the point.'),
        ],
        paragraphs: [
          _en('None of this is a programme. It is a way past the silence '
              'for the first week, after which most people find they no '
              'longer need it.'),
        ],
      ),

      PvReadSection(
        heading: _en('After the birth, the same voice'),
        paragraphs: [
          _en('The payoff arrives in the first week. A newborn who is '
              'crying in a strange room calms faster to the voice it knows '
              'than to any other sound, and the song you repeated becomes '
              'the one that works at 3am. Keep the same song. Keep talking '
              'the way you did — narrating, describing, answering. The '
              'habit built in the last trimester is the one that carries '
              'a family through the first year, and it costs nothing but '
              'the awkwardness of the first week.'),
        ],
      ),

      PvReadSection(
        heading: _en('If you are carrying twins, or the baby came early'),
        paragraphs: [
          _en('Twins hear the same voice at the same time and learn it the '
              'same way; there is nothing extra to do. A baby born early '
              'misses some of the last-trimester listening, and the '
              'neonatal units that play recordings of the mother\'s voice '
              'in the incubator are making up exactly that — so if it '
              'happens, ask whether you can record a song for the nurses '
              'to play. It is one of the few things a parent can do for a '
              'baby in an incubator, and the evidence says it helps.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A general note, and one thing to act on'),
      body: _en('Nothing here is clinical. If, from 28 weeks, the baby\'s '
          'movements are noticeably less over a day — fewer kicks, no '
          'response to the voice or the touch that usually get one — call '
          'your doctor the same day. Reduced movement is checked, not '
          'watched.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should I use a belly speaker?'),
        answer: _en('No. The baby hears you better through your body than '
            'through any speaker, and sound pressed to the skin bypasses '
            'the fluid\'s muffling.'),
      ),
      PvReadFaq(
        question: _en('What if I feel silly?'),
        answer: _en('Narrate instead of addressing. Tell the baby what you '
            'are doing. The feeling fades in a week; the habit stays.'),
      ),
    ],
    evidence: _en('DeCasper & Spence (1986); Partanen et al., PNAS (2013) on '
        'prenatal music memory; Hepper (1991) on prenatal learning of a '
        'theme tune; ACOG guidance on fetal movement counting.'),
    readNext: ['${kPregWeekReadPrefix}baby_sound', '${kPregWeekReadPrefix}exp_priya'],
  ),

  // ---------------------------------------------------------------------------
  //  back_pain · weeks 20–36
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}back_pain',
    hue: 42,
    kicker: _en('Second trimester'),
    title: _en('Easing back pain in pregnancy'),
    teaser: _en('Half of pregnant women get it, most from the second '
        'trimester. Why it happens, what actually helps, and the two kinds '
        'of back pain that need a doctor.'),
    scaleSetter: _en('Pregnancy back pain is mechanical. The centre of gravity '
        'moves forward, the ligaments of the pelvis loosen under relaxin, '
        'and the muscles of the back do more work in a worse position. That '
        'is good news, because mechanical problems respond to mechanical '
        'fixes — posture, support, movement, and a few specific stretches.'),
    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('Two patterns are common. Low back pain — a dull ache across the '
            'lower spine, worse after sitting or standing for long, better '
            'with movement. And pelvic girdle pain — pain at the back of the '
            'pelvis, one or both sides, sometimes at the pubic bone, worse '
            'on stairs, turning in bed, standing on one leg to dress. The '
            'second is more common in later pregnancy and in women who have '
            'had it before.'),
        _en('Both are more likely with a previous back problem, with heavy '
            'physical work, and with each pregnancy. Neither harms the '
            'baby.'),
      ]),
      PvReadSection(
        heading: _en('What helps, in order of evidence'),
        bullets: [
          _en('Exercise. Regular walking, swimming, and a prenatal yoga or '
              'pilates class have the strongest evidence of any measure — '
              'stronger than rest, which makes it worse.'),
          _en('A maternity support belt for pelvic girdle pain, worn when '
              'walking or standing long, not all day.'),
          _en('Posture at work: a chair with a straight back, feet flat, a '
              'small cushion at the lower back, and standing up every '
              'thirty minutes. Laptops on a table, not a lap.'),
          _en('Sleeping on your side with a pillow between the knees and, '
              'later, one under the bump.'),
          _en('Heat on the lower back — a hot water bottle wrapped in cloth, '
              'twenty minutes. Not on the abdomen.'),
          _en('Flat, supportive footwear. Heels tilt the pelvis further.'),
          _en('Paracetamol is safe in pregnancy at the usual dose. '
              'Ibuprofen and other NSAIDs are not, especially after 20 '
              'weeks — ask before taking any painkiller.'),
        ],
      ),
      PvReadSection(
        heading: _en('Two stretches worth learning'),
        paragraphs: [
          _en('The pelvic tilt: on hands and knees, back flat, breathe out and '
              'round the back upward like a cat, then let it flatten. Ten '
              'times, twice a day. It mobilises the lower spine and is safe '
              'to the end.'),
          _en('The hip opener: sit on the floor with the soles of the feet '
              'together, knees dropping outward, back straight, for a '
              'minute. Or sit cross-legged on a cushion in the evening '
              'instead of on the sofa. Both ease the pelvis without loading '
              'it.'),
        ],
      ),
      PvReadSection(
        heading: _en('Lifting, and the toddler problem'),
        paragraphs: [
          _en('If you have an older child, the back pain is often about '
              'lifting. Squat rather than bend, hold the child close, and '
              'teach them to climb onto a chair or into the car seat '
              'themselves. Ask for the shopping to be carried. None of this '
              'is fragility; it is the ligaments being genuinely looser.'),
        ],
      ),
      PvReadSection(
        heading: _en('When back pain is something else'),
        paragraphs: [
          _en('Rhythmic low back pain that comes and goes in waves before 37 '
              'weeks can be preterm labour, especially with tightening of '
              'the belly or a change in discharge. Back pain with fever, '
              'chills or pain on passing urine can be a kidney infection, '
              'which is common in pregnancy and treated promptly. Both are '
              'different in character from the mechanical ache, and both '
              'need a call rather than a stretch.'),
        ],
      ),

      PvReadSection(
        heading: _en('Sitting, standing, and the office'),
        paragraphs: [
          _en('The commonest cause of pregnancy back pain in city women is '
              'not the pregnancy but the chair. Eight hours in a seat with '
              'no lumbar support, a laptop below eye level, and a commute '
              'on either side loads exactly the muscles the pregnancy is '
              'already asking to do more. Small changes carry most of the '
              'benefit: the screen raised to eye level, a rolled towel at '
              'the small of the back, feet flat or on a box, and — the one '
              'that matters most — standing up and walking for two minutes '
              'every half hour, which is a right you are entitled to ask '
              'for.'),
          _en('Standing work is the reverse problem. Shifting weight from '
              'foot to foot, a low stool to rest one foot on, and a sit '
              'every hour reduce the pelvic strain. If your job involves '
              'lifting, the Maternity Benefit Act allows for lighter duties '
              'to be requested; put the request in writing.'),
        ],
      ),

      PvReadSection(
        heading: _en('One last thing: the belly binder'),
        paragraphs: [
          _en('Relatives may press a cloth wrap or a tight binder on you '
              '"for support". A proper maternity belt — elastic, adjustable, '
              'sitting under the bump and around the pelvis — is fine and '
              'has evidence for pelvic pain. A tight cloth wound around the '
              'abdomen is not the same thing, restricts breathing, and does '
              'nothing for the back. If it is offered, the belt is the '
              'answer that keeps the peace and the spine.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en('The pain comes in regular waves, especially with belly '
          'tightening or a change in discharge before 37 weeks; there is '
          'fever, chills or burning on passing urine; there is numbness, '
          'weakness in a leg, or trouble controlling the bladder or bowel; '
          'or the pain is severe and sudden.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is a massage safe?'),
        answer: _en('Yes, from a therapist who works with pregnant women, '
            'lying on your side rather than face-down. Avoid deep pressure '
            'on the abdomen.'),
      ),
      PvReadFaq(
        question: _en('Can I see a physiotherapist?'),
        answer: _en('Yes — a women\'s health physiotherapist is the right '
            'referral for pelvic girdle pain that limits walking or sleep, '
            'and many can be seen without a doctor\'s letter.'),
      ),
      PvReadFaq(
        question: _en('Will it go after the birth?'),
        answer: _en('For most women, within a few months. Pelvic girdle pain '
            'that persists is worth a physiotherapy review rather than '
            'waiting it out.'),
      ),
    ],
    evidence: _en('Cochrane review: Interventions for preventing and '
        'treating low-back and pelvic pain during pregnancy (2015); RCOG '
        'patient information on pelvic girdle pain; NICE NG201; FDA / MHRA '
        'guidance on NSAIDs after 20 weeks (2020).'),
    readNext: ['${kPregWeekReadPrefix}third_tri_prep', '${kPregWeekReadPrefix}halfway'],
  ),
];
