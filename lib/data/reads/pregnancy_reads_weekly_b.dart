// =============================================================================
//  Pregnancy reads — the weekly reads, written out (b: weeks 18–36)
// -----------------------------------------------------------------------------
//  See pregnancy_reads_weekly_a.dart for why these exist and the bar they
//  are written to. Same clinical rules; nothing here reads HER result.
//
//  Rewritten 2026-09-29 to docs/PREG-VOICE.md, each read with a shortAnswer.
//  Trust (gap analysis P1): every read is `reviewed: false` under the desk
//  byline; see the note in pregnancy_reads_weekly_a.dart.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import 'pregnancy_reads_weekly_a.dart' show kPregWeekReadPrefix;

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

const double _hue = 344;

/// The honest byline until a real, named clinician has read the piece.
const LocalizedText _desk =
    LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');
const LocalizedText _deskRole = LocalizedText(
    en: 'Written by the ParentVeda team', hi: 'Written by the ParentVeda team');

final List<PvRead> kPregnancyReadsWeeklyB = [
  // ---------------------------------------------------------------------------
  //  halfway · weeks 18–22
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}halfway',
    hue: _hue,
    kicker: _en('Second trimester'),
    title: _en("You're halfway. What changes now"),
    teaser: _en('Twenty weeks: the scan that looks at everything, the first '
        'flutters, a bump that finally looks like a bump, and how to sleep.'),
    shortAnswer: _en('At 20 weeks your baby is about 25 cm long and can hear. '
        'You may feel the first flutters any time from 16 to 24 weeks, and '
        'the detailed anomaly scan falls now. It\'s also the time to book '
        'the glucose test, the Tdap vaccine and a birth class.'),
    scaleSetter: _en('Week twenty is the middle of your pregnancy and, for '
        'most women, the best part of it. The nausea has gone and the '
        'tiredness has eased. Your baby is big enough to feel and not yet big '
        "enough to be in the way. It's also the week of the most detailed "
        "scan you'll have, so it deserves a plan rather than a walk-in."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('At twenty weeks your baby is about 25 centimetres from head to '
            'heel and weighs around 300 grams, about the length of a banana. '
            'The skin is covered in a waxy layer (vernix) and fine hair '
            '(lanugo).'),
        _en('Your baby swallows the fluid around them, practises breathing '
            'movements, sleeps and wakes in cycles, and can hear. Your womb '
            'has reached your navel. From here it rises about a centimetre a '
            'week, and the bump height your doctor measures in centimetres '
            '(fundal height) roughly matches the week.'),
      ]),
      PvReadSection(
        heading: _en('When will you feel your baby move?'),
        paragraphs: [
          _en('The first movements you can feel (quickening) arrive between '
              'weeks 16 and 24. They come later in a first pregnancy, and '
              'earlier when the placenta is at the back. They feel like '
              'bubbles, a flutter, or a fish turning. Many women take them '
              'for wind for a week.'),
          _en('By 24 weeks the movements are unmistakable. From 28 weeks '
              "you'll be asked to get to know your baby's pattern."),
          _en("If you haven't felt anything by 24 weeks, mention it at your "
              'next visit. It usually comes down to where the placenta is and '
              'your own build, and a quick listen settles it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is the anomaly scan?'),
        paragraphs: [
          _en('Between 18 and 22 weeks, in India most often at 19 to 20, the '
              'anomaly or "level II" scan checks your baby\'s brain, face, '
              'spine, heart, stomach, kidneys, bladder and limbs. It measures '
              'growth and finds where the placenta is.'),
          _en('It takes twenty to forty minutes. This is the one scan worth '
              "taking your partner to. There's a full piece on getting the "
              'most from it in the rail below.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is your body doing this month?'),
        bullets: [
          _en('Round ligament pain: a sharp pull low on one side when you turn '
              'over or stand up fast. It\'s normal and passes in seconds. '
              'Pain that lasts, or comes with bleeding, is different: call '
              'your doctor.'),
          _en('Sleeping on your side is advised, ideally from about 28 weeks. '
              'Lying flat lets your womb press on the large vein that carries '
              'blood back to your heart. Start the habit now. A pillow between '
              'your knees helps.'),
          _en('A dark line down your belly (linea nigra) and darker patches on '
              'your face (melasma) come from hormones and fade after birth. '
              'Sunscreen keeps the face patches lighter.'),
          _en('A stuffy nose and bleeding gums come from more blood flowing '
              'through softer tissue. A saline spray and a soft toothbrush '
              'help.'),
          _en('Leg cramps at night. Stretch your calves before bed and keep up '
              'fluids and calcium. Magnesium is sometimes suggested.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you book now?'),
        paragraphs: [
          _en('The glucose tolerance test falls at 24 to 28 weeks, the Tdap '
              'vaccine at 27 to 36 weeks, and the growth scan around 28 to 32. '
              'If you plan to take a birth class, the third trimester fills '
              'up, so book it this month.'),
          _en("If you haven't chosen where to deliver yet, the second "
              'trimester is the time to visit two hospitals. Ask what a '
              'normal delivery and a caesarean each cost, and what their '
              'caesarean rate is.'),
        ],
      ),

      PvReadSection(
        heading: _en('What do women ask at twenty weeks?'),
        paragraphs: [
          _en('Is it too late to start exercising? No. Walking thirty minutes '
              'most days, started now, is what the guidelines recommend. It '
              'helps with the glucose test to come, with back pain and with '
              'sleep.'),
          _en('Can I have sex? Yes, in a normal pregnancy, all the way '
              'through. Can I dye my hair, paint the nursery, get a pedicure? '
              'Yes, yes in a room with open windows, and yes. Can I fast for a '
              'festival? Talk to your doctor first. A day of fasting with '
              'fluids is usually fine in an uncomplicated pregnancy. A fast '
              'without water is not advised.'),
          _en('Should I be taking a particular supplement now? Iron and '
              'calcium, if they are prescribed. Folic acid can usually stop '
              "after twelve weeks unless your doctor has said otherwise. "
              'Vitamin D is low in most Indian women and is worth a check. '
              'Beyond that, your plate does more than the chemist.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en('You have bleeding, a gush or steady trickle of fluid, '
          'contractions or tightening that comes regularly, a severe headache '
          'with vision changes, sudden swelling of your face or hands, or '
          'pain when you pass urine along with fever. These are checked the '
          'same day at any stage.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is it safe to sleep on my back?'),
        answer: _en('Before 28 weeks, yes. After that, sleeping on your side '
            'is advised. If you wake up on your back, just turn over. Waking '
            "up is your body's own alarm."),
      ),
      PvReadFaq(
        question: _en("My bump is smaller than a friend's at the same week. "
            'Should I worry?'),
        answer: _en('Bumps vary with height, muscle tone, earlier pregnancies '
            'and where the placenta is. What matters is the bump height '
            'your doctor measures, and the growth scan.'),
      ),
      PvReadFaq(
        question: _en('Can I still fly?'),
        answer: _en('Most airlines allow it up to 36 weeks with one baby, '
            'with a fit-to-fly letter after 28 weeks. The second trimester '
            'is the most comfortable time to go.'),
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
        'What is checked, what "soft markers" mean, and what to ask before '
        'you leave the room.'),
    shortAnswer: _en('The anomaly scan, at 18 to 22 weeks, checks your baby '
        'from head to toe, along with growth and the placenta. In more than '
        '19 pregnancies out of 20 it finds nothing to act on. If something '
        'is noted, it is most often something to watch, not a diagnosis.'),
    scaleSetter: _en('The anomaly scan is a survey, not a verdict. In more '
        'than nineteen pregnancies out of twenty it finds nothing to act on. '
        "When it does find something, it's most often a finding to watch "
        'rather than a diagnosis. Knowing that before you go in keeps a '
        'twenty-minute scan from turning into a fortnight of fear.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Done between 18 and 22 weeks, the scan works through your baby '
            'one part at a time. The head and brain: the shape of the skull, '
            'the ventricles, the cerebellum. The face: the lips and the '
            'profile. The spine, along its whole length.'),
        _en('Then the heart: four chambers and the vessels leaving it. This '
            "part takes longest and depends most on your baby's position. "
            'Then the stomach, kidneys and bladder, the wall of the tummy, '
            'and the arms, legs, hands and feet. Last come the placenta, '
            'where it sits, the cord, and the amount of fluid.'),
        _en('Measurements are taken as it goes: head circumference, '
            'abdominal circumference, femur length. Together they estimate '
            'weight and confirm your baby is growing in step with the dates.'),
      ]),
      PvReadSection(
        heading: _en('How can you prepare?'),
        bullets: [
          _en('Take your partner or someone who can hold on to the questions. '
              'The sonographer is concentrating, and you may find it hard to.'),
          _en("Eat normally. A full bladder usually isn't needed at this "
              'stage. Wear a two-piece outfit.'),
          _en('Bring your dating scan report so the dates match.'),
          _en('Expect quiet. Sonographers are trained to check before they '
              'speak. Silence during the heart views is normal. It doesn\'t '
              'mean something is wrong.'),
          _en("Ask at the start whether they'll explain as they go or at the "
              "end, so you know which kind of silence you're in."),
        ],
      ),
      PvReadSection(
        heading: _en('What are "soft markers"?'),
        paragraphs: [
          _en('A soft marker is a small variation. Examples are a bright spot '
              'in the heart (echogenic focus), slightly wider kidney drainage '
              'areas (renal pelvises), a choroid plexus cyst, or a single '
              'umbilical artery. On its own, a marker means very little, and '
              'most babies with one are entirely well.'),
          _en('Some markers were once used to adjust the chance of a '
              'chromosomal condition. Now that blood screening (NIPT) is '
              'available, most change nothing on their own. If one is noted, '
              'ask: "Does this change what you recommend?" Often the honest '
              'answer is no.'),
        ],
      ),
      PvReadSection(
        heading: _en('What if the scan needs a second look?'),
        paragraphs: [
          _en("Sometimes your baby's position hides the heart or the spine. "
              "You'll be asked to walk around, have a sweet drink and come "
              'back, or to return in a fortnight. That is the most common '
              "reason for a repeat. It only means the view wasn't good enough."),
          _en('A referral to a fetal medicine specialist is the next step when '
              'something specific needs a closer or more expert look. It is '
              'an appointment, not a conclusion.'),
          _en('A low-lying placenta at twenty weeks is noted in around one '
              'pregnancy in twenty. In the great majority it moves up by the '
              'third-trimester rescan. It is a reason for a follow-up scan, '
              'not for alarm.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you ask before you leave?'),
        bullets: [
          _en('Was everything you looked for seen, and normal? If not, what '
              "wasn't seen, and when will it be?"),
          _en('Where is the placenta, and does it need a rescan?'),
          _en('Is the growth in step with my dates?'),
          _en('Is there anything here my obstetrician should act on, or '
              'only note?'),
          _en('Can I have a copy of the report and the images today?'),
        ],
      ),

      PvReadSection(
        heading: _en('What happens if something is found?'),
        paragraphs: [
          _en('It helps to know what happens in the small number of scans '
              'that find something, because fear of that is most of the dread '
              "going in. You'll be told what was seen, in the room or by your "
              'obstetrician the same week.'),
          _en("You'll usually be referred to a fetal medicine specialist for "
              'a detailed scan, sometimes with a heart scan for your baby '
              '(fetal echo). You may be offered more tests, such as an NIPT '
              'blood test or an amniocentesis, and a genetic counsellor if '
              'the finding could be chromosomal.'),
          _en('Many findings are managed, not treated. A slightly widened '
              'kidney is rescanned at 32 weeks and after birth. A small heart '
              'finding is checked by a children\'s heart doctor (paediatric '
              'cardiologist) in the first week. Some need the birth planned at '
              'a hospital with a NICU.'),
          _en('A few are serious. That conversation with your doctors is not '
              'one to have alone. Take your partner, take notes, and ask for '
              'a second appointment once the first has sunk in.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Your doctor reads your report'),
      body: _en('Nothing here replaces the doctor who asked for the scan. If a '
          'line worries you, or a repeat scan or referral has been suggested, '
          'take the report to your obstetrician the same week and ask what '
          "it means for you. They know your history, and this page doesn't."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Will they tell me the sex?'),
        answer: _en('No. Under the PCPNDT Act, telling anyone the sex of a baby '
            'before birth is illegal in India, and sonographers may not '
            'answer even if you ask.'),
      ),
      PvReadFaq(
        question: _en('Is a 3D or 4D scan better?'),
        answer: _en('Not for checking your baby. The anomaly scan is a 2D '
            'survey by design. 3D pictures are for the album, and they '
            "don't replace it."),
      ),
      PvReadFaq(
        question: _en('What does it cost?'),
        answer: _en('At private centres in Indian metros, roughly ₹2,500 to '
            '₹6,000 in 2026, and more at fetal medicine units. Government '
            'hospitals do it free or for a small charge.'),
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
        'reaches your baby, what they do with it, and why your voice matters '
        'most.'),
    shortAnswer: _en("Your baby's ear is formed by about 20 weeks, and they "
        'respond to sound from around 24 to 26 weeks. Your voice reaches '
        'them most clearly, because it travels through your body too. No '
        'gadget is needed: ordinary talk and songs do the job.'),
    scaleSetter: _en('By the third trimester your baby can hear, tell one '
        'voice from another, and remember a tune well enough to calm to it '
        "after birth. None of that needs a gadget. It needs the sounds that "
        "are already there, your voice, your partner's and the household's, "
        'and a little intention.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('The inner ear is fully formed by around week twenty. The nerve '
            'pathways that carry sound to the brain mature over the next few '
            'weeks. By 24 to 26 weeks babies respond reliably to sound from '
            'outside, with a change in heart rate or a movement. From about '
            '28 weeks the response is steady enough to be used in '
            'monitoring.'),
        _en('What reaches your baby is filtered. The fluid and the wall of '
            'your tummy muffle high sounds and let low ones through. So the '
            "womb isn't silent. It carries your heartbeat, your digestion "
            'and the rush of blood, all at about the loudness of a quiet '
            'conversation. Voices arrive as rhythm and melody more than as '
            'words.'),
      ]),
      PvReadSection(
        heading: _en('Why is your voice different?'),
        paragraphs: [
          _en('Your voice reaches your baby in two ways. It travels through '
              'the air like every other sound, and through your body, carried '
              'by bone and tissue. That makes it the loudest and clearest '
              'voice your baby hears.'),
          _en("The studies bear this out. Newborns suck harder to hear a "
              "recording of their mother's voice than a stranger's. They also "
              'prefer a story their mother read aloud in the last trimester '
              "over one she didn't."),
          _en("Your partner's voice, heard often and close, is recognised "
              'too. It is less strong, because it only comes through the air, '
              'but it is reliable. That is the evidence behind "talk to the '
              'bump", and it holds.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does music help?'),
        paragraphs: [
          _en('Babies respond to music in the womb and can recognise a melody '
              "after birth. What the evidence doesn't support is the idea "
              'that certain music makes a baby cleverer. The "Mozart effect" '
              'was a small, short-lived result in adults that was never '
              'repeated in babies.'),
          _en('The honest case for music in pregnancy is that it relaxes you. '
              'A calmer mother is the effect that reaches the baby.'),
          _en('Volume matters more than the kind of music. Keep it at the '
              'level of conversation. Headphones on your belly are '
              "unnecessary and, turned up, unwise. The fluid doesn't protect "
              'against loud sound pressed right against the skin.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about loud places?'),
        paragraphs: [
          _en('An occasional wedding, a festival procession or a film in a '
              "cinema won't harm your baby. If the speakers at a sangeet feel "
              'too loud for you, step back from them for your own comfort.'),
          _en('Constant loud noise at work is different. Above about 85 '
              'decibels for a full shift, day after day, as in some '
              'factories, it is linked with a small increase in hearing '
              'problems at birth. That is a reason to ask for a quieter '
              'posting from the second trimester.'),
        ],
      ),

      PvReadSection(
        heading: _en('How is hearing checked after birth?'),
        paragraphs: [
          _en("Your baby's hearing is checked in the first days after birth. "
              'Most hospitals in Indian cities now do a newborn hearing '
              'screen. A small earpiece plays soft clicks while your baby '
              "sleeps and records the ear's echo. It takes minutes and is "
              'painless.'),
          _en('A "refer" result on the first day usually means fluid in the '
              'ear from the birth, not hearing loss. A repeat at two to four '
              'weeks settles it. Ask whether your hospital does the screen, '
              "and ask for it if they don't offer it."),
          _en('Permanent hearing loss affects around one to three babies in '
              'a thousand. Finding it in the first months rather than the '
              "second year changes a child's language for life. That's the "
              'practical reason all this listening in the womb ends with a '
              'test on the ward.'),
        ],
      ),

      PvReadSection(
        heading: _en("Can a scan harm your baby's hearing?"),
        paragraphs: [
          _en('Scans work by sound, so it\'s a fair question. The answer is '
              'no. Scan ultrasound is far above the range of hearing, at low '
              'energy, for minutes at a time. Forty years of monitoring have '
              'found no effect on hearing or on anything else.'),
          _en('The 3D "keepsake" scans sold in some cities are unnecessary, '
              "not dangerous. The guidance is just not to scan for "
              'entertainment.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A general note, and one thing to act on'),
      body: _en('Nothing about sound in pregnancy is an emergency. One related '
          "thing is. From 28 weeks, if your baby's movements drop noticeably "
          "for a day, including not responding to sounds or touch that "
          'usually get a reaction, call your doctor the same day. Don\'t '
          'wait to see.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can the baby hear us arguing?'),
        answer: _en('Your baby hears raised voices as louder rhythm, not as '
            'meaning. What research links to outcomes is long-lasting stress '
            'in the mother, not a single argument.'),
      ),
      PvReadFaq(
        question: _en('Does reading in Hindi or English matter?'),
        answer: _en('No. Your baby learns the rhythm and melody of whatever '
            'they hear most, which is one reason bilingual newborns respond '
            'to both. Read in the language you love.'),
      ),
      PvReadFaq(
        question: _en('When does the baby start to hear?'),
        answer: _en('Responses to sound are seen from about 24 weeks and are '
            'steady by 28. Talking earlier does no harm and builds your own '
            'habit.'),
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
    teaser: _en('It feels odd for about a week. Then it becomes something you '
        'do. What to say, when your baby hears it, and why the awkwardness '
        'is worth it.'),
    shortAnswer: _en('Your baby starts hearing around 24 weeks and learns your '
        'voice in the last trimester. A couple of minutes a day, in any '
        'language, is enough. Repeating one song or rhyme gives you '
        'something that can calm your baby after birth.'),
    scaleSetter: _en("There is no script. Babies don't learn words in the "
        'womb. They learn a voice, its rhythm, and the feeling of a room '
        'that is calm when it speaks. Two minutes a day, said to your bump '
        'in whatever language you think in, does the whole job.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Talking to your bump isn't only sentimental. Your baby hears "
            "from around 24 weeks, knows your voice at birth, and settles "
            'faster to it than to any other sound. The same is true, less '
            "strongly, of your partner's voice if they hear it often. That "
            'recognition is built in the last trimester, and it is built by '
            'ordinary talk.'),
        _en('The awkwardness is real, and it passes. Most people find it '
            'easier to describe what they\'re doing than to speak to the '
            'baby directly. "I\'m making dal, the pressure cooker is about '
            'to go" counts as talking to your baby. So does reading the news '
            'aloud, or singing badly in the kitchen.'),
      ]),
      PvReadSection(
        heading: _en('When does your baby hear it?'),
        bullets: [
          _en("Before 24 weeks: it's for you. The habit forms, though your "
              "baby can't hear yet."),
          _en('24 to 28 weeks: your baby responds to sound, more to low '
              'voices than high ones.'),
          _en('From 28 weeks: recognition builds. A phrase, a song or a '
              'passage repeated most days from now on is the one your baby '
              'will know at birth.'),
        ],
      ),
      PvReadSection(
        heading: _en('What works?'),
        paragraphs: [
          _en('Pick one thing to repeat: a lullaby, a shloka, a verse, a '
              'nursery rhyme, or the same paragraph of the same book. The '
              'research that showed newborns preferring what they heard in '
              'the womb used repetition, not variety. One song sung every '
              'evening at the same time can work like a switch after birth.'),
          _en('Give your partner a slot. Their voice needs more repetition to '
              'be learnt, because it reaches the baby only through the air. '
              'Two minutes every night with a hand on your belly is enough. '
              'It is often the first way a partner feels part of a pregnancy '
              "that's otherwise happening to you."),
          _en("Answer the kicks. When your baby moves, say something. They "
              "don't understand the words. You're building a habit of "
              'responding to your child, and that habit is the base of the '
              'first year.'),
        ],
      ),
      PvReadSection(
        heading: _en("What isn't it?"),
        paragraphs: [
          _en("It isn't a way to make a baby cleverer, and no product that "
              "claims to do that has evidence behind it. It isn't a test of "
              'you as a parent. Women who never talk to the bump raise '
              'children who talk just fine.'),
          _en("And it doesn't need a device, an app or a speaker on your "
              'belly. Your voice, at an ordinary volume, is the one sound '
              'built to reach your baby best.'),
        ],
      ),

      PvReadSection(
        heading: _en("A week of ideas, if you don't know what to say"),
        bullets: [
          _en('Monday: tell your baby what you ate today and which part you '
              'liked.'),
          _en("Tuesday: read one page of whatever you're reading, out loud, "
              'even the news.'),
          _en('Wednesday: sing the song your mother sang to you, badly.'),
          _en("Thursday: describe the room you're sitting in."),
          _en("Friday: your partner's turn. Two minutes, hand on your belly, "
              'anything at all.'),
          _en("Saturday: tell your baby one thing about the family they're "
              'joining.'),
          _en('Sunday: say the same thing you said last Sunday. Repetition '
              'is the point.'),
        ],
        paragraphs: [
          _en("None of this is a programme. It's a way past the silence for "
              "the first week. After that, most people find they don't need "
              'it.'),
        ],
      ),

      PvReadSection(
        heading: _en('What happens after the birth?'),
        paragraphs: [
          _en('The payoff comes in the first week. A newborn crying in a '
              'strange room calms faster to the voice they know than to any '
              'other sound. The song you repeated becomes the one that works '
              'at 3am.'),
          _en('Keep the same song. Keep talking the way you did: describing, '
              'narrating, answering. The habit you built in the last '
              'trimester carries a family through the first year, and it '
              'costs nothing but a week of feeling awkward.'),
        ],
      ),

      PvReadSection(
        heading: _en("What if it's twins, or your baby comes early?"),
        paragraphs: [
          _en('Twins hear the same voice at the same time and learn it the '
              "same way. There's nothing extra to do."),
          _en('A baby born early misses some of the last-trimester listening. '
              "Neonatal units that play recordings of the mother's voice in "
              'the incubator are making up exactly that. If it happens, ask '
              'whether you can record a song for the nurses to play. It\'s one '
              'of the few things you can do for a baby in an incubator, and '
              'the evidence says it helps.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('A general note, and one thing to act on'),
      body: _en("Nothing here is clinical. But if, from 28 weeks, your baby's "
          'movements are noticeably less over a day (fewer kicks, no response '
          'to the voice or touch that usually gets one), call your doctor the '
          'same day. Reduced movement is checked, not watched.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should I use a belly speaker?'),
        answer: _en('No. Your baby hears you better through your body than '
            'through any speaker, and sound pressed to the skin skips the '
            "fluid's muffling."),
      ),
      PvReadFaq(
        question: _en('What if I feel silly?'),
        answer: _en("Describe instead of addressing. Tell your baby what you're "
            'doing. The feeling fades in a week, and the habit stays.'),
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
    teaser: _en('Half of pregnant women get it, mostly from the second '
        'trimester. Why it happens, what helps, and the two kinds of back '
        'pain that need a doctor.'),
    shortAnswer: _en('Back pain in pregnancy is common and comes from your '
        'changing shape and looser ligaments. Regular walking, swimming or '
        'prenatal yoga help most, along with good posture and sleeping on '
        'your side. Pain that comes in waves, or comes with fever, needs a '
        'call to your doctor.'),
    scaleSetter: _en('Pregnancy back pain is mechanical. Your centre of '
        'gravity moves forward, the ligaments of your pelvis loosen under a '
        'hormone called relaxin, and your back muscles work harder in a '
        'worse position. That\'s good news, because mechanical problems '
        'respond to mechanical fixes: posture, support, movement and a few '
        'simple stretches.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Two patterns are common. The first is low back pain: a dull ache '
            'across your lower spine, worse after sitting or standing for a '
            'long time, and better when you move.'),
        _en('The second is pelvic girdle pain. It is felt at the back of your '
            'pelvis, on one or both sides, and sometimes at the pubic bone. '
            'It gets worse on stairs, turning in bed, or standing on one leg '
            'to get dressed. It is more common later in pregnancy, and in '
            "women who've had it before."),
        _en('Both are more likely if you have had a back problem before, do '
            "heavy physical work, or have been pregnant before. Neither harms "
            'your baby.'),
      ]),
      PvReadSection(
        heading: _en('What helps most?'),
        bullets: [
          _en('Exercise. Regular walking, swimming, and a prenatal yoga or '
              'pilates class have the strongest evidence of anything. They '
              'work better than rest, which makes it worse.'),
          _en('A maternity support belt for pelvic girdle pain. Wear it when '
              'you walk or stand for a long time, not all day.'),
          _en('Posture at work: a chair with a straight back, feet flat, a '
              'small cushion at your lower back, and standing up every thirty '
              'minutes. Keep the laptop on a table, not your lap.'),
          _en('Sleeping on your side with a pillow between your knees and, '
              'later, one under your bump.'),
          _en('Heat on your lower back: a hot water bottle wrapped in cloth, '
              'for twenty minutes. Not on your tummy.'),
          _en('Flat, supportive footwear. Heels tilt your pelvis further.'),
          _en('Paracetamol is safe in pregnancy at the usual dose. Ibuprofen '
              'and other NSAIDs are not, especially after 20 weeks. Ask before '
              'taking any painkiller.'),
        ],
      ),
      PvReadSection(
        heading: _en('Which stretches help?'),
        paragraphs: [
          _en('The pelvic tilt: get on your hands and knees with your back '
              'flat. Breathe out and round your back upward like a cat, then '
              'let it flatten. Do it ten times, twice a day. It loosens the '
              'lower spine and is safe right to the end.'),
          _en('The hip opener: sit on the floor with the soles of your feet '
              'together, knees dropping outward, back straight, for a minute. '
              'Or sit cross-legged on a cushion in the evening instead of on '
              'the sofa. Both ease the pelvis without loading it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about lifting, and your toddler?'),
        paragraphs: [
          _en('If you have an older child, the back pain is often about '
              'lifting. Squat rather than bend, and hold your child close. '
              'Teach them to climb onto a chair or into the car seat '
              'themselves. Ask for the shopping to be carried.'),
          _en("None of this means you're fragile. Your ligaments really are "
              'looser right now.'),
        ],
      ),
      PvReadSection(
        heading: _en('When is back pain something else?'),
        paragraphs: [
          _en('Low back pain that comes and goes in waves before 37 weeks can '
              'be preterm labour, especially with tightening of your belly or '
              'a change in discharge.'),
          _en('Back pain with fever, chills or pain when you pass urine can be '
              'a kidney infection. It is common in pregnancy and is treated '
              'promptly.'),
          _en('Both feel different from the usual ache, and both need a call '
              'to your doctor, not a stretch.'),
        ],
      ),

      PvReadSection(
        heading: _en('How can you sit and stand at work?'),
        paragraphs: [
          _en('For many women in cities, the biggest cause of back pain in '
              'pregnancy is the chair, not the pregnancy. Eight hours in a '
              'seat with no lower back support, a laptop below eye level, and '
              'a commute either side load exactly the muscles pregnancy is '
              'already asking more of.'),
          _en('Small changes do most of the good. Raise the screen to eye '
              'level, put a rolled towel at the small of your back, and keep '
              'your feet flat or on a box. Most of all, stand up and walk for '
              "two minutes every half hour. You're entitled to ask for that."),
          _en('Standing work is the opposite problem. Shift your weight from '
              'foot to foot, rest one foot on a low stool, and sit down every '
              'hour to ease the strain on your pelvis. If your job involves '
              'lifting, the Maternity Benefit Act allows you to ask for '
              'lighter duties. Put the request in writing.'),
        ],
      ),

      PvReadSection(
        heading: _en('What about a belly binder?'),
        paragraphs: [
          _en('Relatives may offer you a cloth wrap or a tight binder "for '
              'support". A proper maternity belt is fine and has evidence for '
              'pelvic pain. It is elastic and adjustable, and sits under the '
              'bump and around the pelvis.'),
          _en("A tight cloth wound around your tummy isn't the same thing. It "
              "restricts your breathing and does nothing for your back. If "
              'one is offered, the maternity belt is the answer that keeps '
              'the peace and looks after your spine.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en('The pain comes in regular waves, especially with belly '
          'tightening or a change in discharge before 37 weeks. Or there is '
          'fever, chills or burning when you pass urine. Or there is '
          'numbness, weakness in a leg, or trouble controlling your bladder '
          'or bowels. Or the pain is severe and sudden.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is a massage safe?'),
        answer: _en('Yes, from a therapist who works with pregnant women, with '
            'you lying on your side rather than face-down. Avoid deep '
            'pressure on your tummy.'),
      ),
      PvReadFaq(
        question: _en('Can I see a physiotherapist?'),
        answer: _en("Yes. A women's health physiotherapist is the right person "
            'for pelvic girdle pain that limits your walking or sleep, and '
            "many will see you without a doctor's letter."),
      ),
      PvReadFaq(
        question: _en('Will it go after the birth?'),
        answer: _en('For most women, within a few months. If pelvic girdle '
            'pain carries on, see a physiotherapist rather than waiting it '
            'out.'),
      ),
    ],
    evidence: _en('Cochrane review: Interventions for preventing and '
        'treating low-back and pelvic pain during pregnancy (2015); RCOG '
        'patient information on pelvic girdle pain; NICE NG201; FDA / MHRA '
        'guidance on NSAIDs after 20 weeks (2020).'),
    readNext: ['${kPregWeekReadPrefix}third_tri_prep', '${kPregWeekReadPrefix}halfway'],
  ),
];
