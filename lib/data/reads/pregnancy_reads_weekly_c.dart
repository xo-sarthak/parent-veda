// =============================================================================
//  Pregnancy reads — the weekly reads, written out (c: weeks 24–40)
// -----------------------------------------------------------------------------
//  See pregnancy_reads_weekly_a.dart. Same bar, same clinical rules.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import 'pregnancy_reads_weekly_a.dart' show kPregWeekReadPrefix;

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

const double _hue = 344;

final List<PvRead> kPregnancyReadsWeeklyC = [
  // ---------------------------------------------------------------------------
  //  third_tri_prep · weeks 24–30
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}third_tri_prep',
    hue: _hue,
    kicker: _en('Third trimester'),
    title: _en('Getting ready for the third trimester'),
    teaser: _en('From 28 weeks the visits get closer, the tests get '
        'specific, and the baby doubles in weight. What is on the calendar '
        'and what to sort before it starts.'),
    scaleSetter: _en('The third trimester is thirteen weeks in which the baby '
        'goes from about a kilo to three and a half, and in which the '
        'pregnancy asks the most of you. Most of what makes it easier is '
        'arranged in the last weeks of the second — which is now.'),
    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('From 28 weeks antenatal visits usually move to every two weeks, '
            'and from 36 to weekly. Each checks blood pressure, urine for '
            'protein, fundal height and the baby\'s heartbeat and position. '
            'The specific tests of the trimester are the glucose tolerance '
            'test if it has not been done, a repeat haemoglobin, the Tdap '
            'vaccine, a growth scan, and — from 36 weeks in some practices '
            '— a swab for group B streptococcus.'),
      ]),
      PvReadSection(
        heading: _en('The calendar'),
        bullets: [
          _en('24–28 weeks: oral glucose tolerance test for gestational '
              'diabetes; anti-D injection at 28 weeks if your blood group '
              'is Rh negative.'),
          _en('27–36 weeks: Tdap vaccine, which protects the newborn from '
              'whooping cough through your antibodies. A flu shot in season.'),
          _en('28–32 weeks: growth scan, and the start of knowing your '
              'baby\'s movement pattern.'),
          _en('32–36 weeks: a second growth scan if advised; the placenta '
              'rescan if it was low earlier; the birth plan conversation.'),
          _en('36 weeks on: weekly visits; position checked; the hospital '
              'bag by the door.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to sort now'),
        paragraphs: [
          _en('The hospital. Register, if the hospital asks for it, and '
              'find out what the package includes and excludes, the '
              'caesarean rate, whether your partner can be present, and what '
              'happens at night and on holidays. Ask about the NICU — not '
              'because you will need it, but because knowing it exists on '
              'site is one less thing to fear.'),
          _en('The money. Maternity insurance in India usually has a waiting '
              'period of two to four years and a sub-limit; check yours now, '
              'not at discharge. Employer schemes and the PMMVY cash '
              'benefit for a first child each need paperwork done in advance.'),
          _en('The leave. The Maternity Benefit Act gives 26 weeks paid '
              'leave for a first or second child, up to eight of which can '
              'be taken before the due date. Put the dates in writing to '
              'your employer by the end of the second trimester.'),
          _en('The help. Who will be in the house in the first month? A '
              'mother, a mother-in-law, a hired help, a partner on leave — '
              'decide, and decide who is in charge of what, before everyone '
              'arrives at once.'),
        ],
      ),
      PvReadSection(
        heading: _en('Your body, from here'),
        paragraphs: [
          _en('Breathlessness on stairs as the uterus presses on the '
              'diaphragm; heartburn as it presses on the stomach — small '
              'meals, an extra pillow, and antacids your doctor approves. '
              'Swollen feet by evening, eased by putting them up; swelling '
              'of the face and hands is different and is a reason to call. '
              'Braxton Hicks tightenings, irregular and painless, from '
              'around 30 weeks. Sleep that gets harder — the side-lying '
              'habit, a pillow between the knees, and a short afternoon rest '
              'without guilt.'),
        ],
      ),

      PvReadSection(
        heading: _en('The tests, explained in a line each'),
        bullets: [
          _en('Glucose tolerance test: a sugar drink and blood taken at '
              'intervals, to find gestational diabetes, which is common in '
              'India and managed well with diet first.'),
          _en('Anti-D: an injection for Rh-negative mothers that stops the '
              'body reacting to a Rh-positive baby\'s blood, protecting this '
              'and future pregnancies.'),
          _en('Haemoglobin: repeated because anaemia is commonest now, when '
              'the baby is taking the most iron.'),
          _en('Growth scan: the baby\'s size against its dates, the fluid, '
              'and the blood flow in the cord.'),
          _en('Group B strep swab: a bacterium many women carry harmlessly, '
              'which is treated with antibiotics in labour if present so it '
              'does not reach the baby. Not every practice tests; ask.'),
          _en('Blood pressure and urine, every visit: the two checks that '
              'catch pre-eclampsia early, which is why the visits get '
              'closer.'),
        ],
      ),

      PvReadSection(
        heading: _en('Rest, and the permission to take it'),
        paragraphs: [
          _en('The third trimester is where the advice to "listen to your '
              'body" stops being a platitude. Sleep is broken by the '
              'bladder, the hips and the baby\'s evening football; the '
              'afternoon rest that was optional at twenty weeks is '
              'restorative at thirty-four. Lie down for half an hour after '
              'lunch if you can, on your left side, and let the household '
              'know it is medical rather than lazy — because it is.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en('You have a severe headache, blurred vision or flashing '
          'lights, sudden swelling of the face or hands, pain under the '
          'right ribs, bleeding, a gush or trickle of fluid, regular '
          'tightenings before 37 weeks, fever, or the baby is moving '
          'noticeably less. None of these waits for the next visit.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is the Tdap vaccine safe?'),
        answer: _en('Yes, and recommended in every pregnancy, because the '
            'antibodies you make cross to the baby and protect against '
            'whooping cough until its own vaccines begin at six weeks.'),
      ),
      PvReadFaq(
        question: _en('When should I stop working?'),
        answer: _en('There is no medical rule for an uncomplicated pregnancy. '
            'Many women work to 36 or 38 weeks; heavy or standing work may '
            'need adjusting earlier. The eight weeks of leave allowed before '
            'the due date is yours to place.'),
      ),
      PvReadFaq(
        question: _en('What is a birth plan?'),
        answer: _en('A short written note of your preferences — pain relief, '
            'who is present, skin-to-skin, feeding — discussed with your '
            'doctor at around 34 to 36 weeks. It is a conversation, not a '
            'contract.'),
      ),
    ],
    evidence: _en('NICE NG201 Antenatal care (2021); ACOG Committee Opinion '
        '718 on Tdap in pregnancy; the Maternity Benefit (Amendment) Act, '
        '2017; Pradhan Mantri Matru Vandana Yojana guidelines.'),
    readNext: ['${kPregWeekReadPrefix}movement_awareness', '${kPregWeekReadPrefix}hospital_bag'],
  ),

  // ---------------------------------------------------------------------------
  //  movement_awareness · weeks 24–30
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}movement_awareness',
    hue: 186,
    kicker: _en('Third trimester'),
    title: _en('Knowing your baby\'s movements'),
    teaser: _en('From 28 weeks, the pattern matters more than the count. '
        'How to learn yours, what "less" means, and why the advice is to '
        'call rather than wait.'),
    scaleSetter: _en('A baby\'s movements are the one check you can do '
        'yourself, every day, for free — and the evidence is clear that '
        'women who know their baby\'s pattern and act on a change catch '
        'problems earlier. The rule is simple: learn what is normal for '
        'your baby, and if it changes, call the same day. Do not wait until '
        'morning, and do not test it with cold water or a sweet.'),
    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('Movements are felt from 16 to 24 weeks and become regular by '
            '28. From then on they do not "slow down as the baby runs out '
            'of room" — that is a myth, and a dangerous one. The type of '
            'movement changes as the baby grows, from kicks to rolls and '
            'stretches, but the frequency should not fall. A baby that '
            'moves less is a baby to be checked.'),
        _en('Every baby has its own pattern: a busy time in the evening, a '
            'quiet spell after you walk, a response to a meal or to lying '
            'on your left side. By 28 weeks you will know yours. That '
            'pattern, not a number, is the baseline.'),
      ]),
      PvReadSection(
        heading: _en('What about "count ten kicks"?'),
        paragraphs: [
          _en('Kick counting — ten movements in two hours — was the older '
              'advice and is still used in some clinics. It is not wrong, '
              'but it has two problems: it makes women who feel eight '
              'movements panic, and it reassures women who feel ten when '
              'their baby usually does forty. Current guidance in the UK, '
              'Australia and increasingly in India is to know your pattern '
              'and act on a change. If your doctor has given you a counting '
              'method, use it; if not, the pattern is the better guide.'),
        ],
      ),
      PvReadSection(
        heading: _en('What "less" looks like'),
        bullets: [
          _en('The evening burst that always comes does not come.'),
          _en('You realise at lunchtime that you have not felt anything '
              'since waking.'),
          _en('Movements are there but feel weaker, or fewer, than yesterday '
              'and the day before.'),
          _en('The baby does not respond to the things that usually get a '
              'reaction — your voice, a hand on the belly, lying down.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to do'),
        paragraphs: [
          _en('Lie on your left side somewhere quiet for up to two hours and '
              'pay attention. If the movements return to normal, that is '
              'usually all it was — but tell your doctor at the next visit. '
              'If they do not, or you are still unsure, call the hospital '
              'or your doctor the same day, at any hour. You will be asked '
              'to come in for a listen to the heartbeat and, after 28 weeks, '
              'usually a CTG trace of twenty to forty minutes.'),
          _en('Nobody at a maternity unit thinks less of a woman who comes in '
              'for reduced movements and is sent home reassured. That visit '
              'is the system working. The visit that worries doctors is the '
              'one that did not happen.'),
        ],
      ),
      PvReadSection(
        heading: _en('Things that do not help'),
        paragraphs: [
          _en('A cold drink, a sugary snack, poking the belly, a home doppler. '
              'None of these is a reliable test, and a home doppler in '
              'particular can pick up your own pulse or the placenta and '
              'give false reassurance. If you feel the need to check, that '
              'feeling is the reason to call.'),
        ],
      ),

      PvReadSection(
        heading: _en('What happens when you go in'),
        paragraphs: [
          _en('Knowing the visit is undramatic makes it easier to make. You '
              'will be asked when you last felt the baby and what its '
              'pattern usually is. A midwife or doctor will listen to the '
              'heartbeat with a handheld doppler, and after 28 weeks you '
              'will usually be put on a CTG — two belts on the belly '
              'tracing the heartbeat and any contractions for twenty to '
              'forty minutes. A reassuring trace shows a heart rate that '
              'rises with the baby\'s movements. If the trace is not clear, '
              'or you have other risk factors, a scan of the fluid and the '
              'cord blood flow follows the same day.'),
          _en('In the great majority of visits the trace is normal, the '
              'baby wakes up under the belts and kicks the monitor, and '
              'you go home. In the small minority it is not, and the '
              'timing of that visit is what made the difference. Both '
              'outcomes are the reason the advice is "call", not "wait".'),
        ],
      ),

      PvReadSection(
        heading: _en('Twins, and a placenta at the front'),
        paragraphs: [
          _en('With twins you will not be able to tell which baby is moving, '
              'and you are not expected to; the rule is the same — the '
              'overall pattern, and a change in it. A placenta at the front '
              'of the uterus cushions the kicks and can make them feel '
              'later and softer, especially before 28 weeks, but by the '
              'third trimester you will still know your baby\'s pattern, '
              'and the same rule applies without exception.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the same day, at any hour, if'),
      body: _en('Your baby\'s movements are fewer, weaker, or different from '
          'the pattern you know — and every time it happens, even if you '
          'were checked last week. Do not wait until morning. Do not use a '
          'home doppler to decide.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can the baby move too much?'),
        answer: _en('A sudden, unusually frantic burst of movement that is '
            'unlike anything before is worth a call too, though it is much '
            'less often a sign of a problem than reduced movement is.'),
      ),
      PvReadFaq(
        question: _en('Does the placenta at the front hide movements?'),
        answer: _en('It can dull them, especially before 28 weeks. It does not '
            'change the rule: learn your baby\'s pattern, whatever it is, '
            'and act on a change.'),
      ),
      PvReadFaq(
        question: _en('Should I use an app to count?'),
        answer: _en('If it helps you notice the pattern, yes. If it replaces '
            'noticing with a number, no. The tool in this app records the '
            'pattern rather than setting a target.'),
      ),
    ],
    evidence: _en('RCOG Green-top Guideline 57: Reduced Fetal Movements '
        '(2011, reviewed 2020); the AFFIRM trial, Lancet (2018); Tommy\'s '
        'movement awareness guidance; FOGSI clinical practice guidance on '
        'fetal surveillance.'),
    readNext: ['preg_cond_read_less_movement', '${kPregWeekReadPrefix}third_tri_prep'],
  ),

  // ---------------------------------------------------------------------------
  //  hospital_bag · weeks 32–40
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}hospital_bag',
    hue: 12,
    kicker: _en('Third trimester'),
    title: _en('Preparing your hospital bag'),
    teaser: _en('Packed by 36 weeks, by the door, with the documents in the '
        'front pocket. What goes in, what Indian hospitals actually '
        'provide, and what nobody uses.'),
    scaleSetter: _en('The bag is not about the things. It is about not '
        'having to think at 3am. Pack it once, properly, by week 36, and '
        'put the file with every report and the insurance card in the '
        'outside pocket — that file is the item hospitals ask for first and '
        'families forget most.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('Indian hospitals vary more than any list can cover. A large '
            'private hospital will provide gowns, baby clothes for the '
            'stay, nappies, and toiletries, and will tell you at '
            'registration what to bring. A smaller nursing home or a '
            'government hospital may provide almost nothing. Ask at the '
            'pre-admission visit, and pack for the second case if you are '
            'not sure.'),
        _en('Plan for a two-night stay after a normal delivery and four to '
            'five after a caesarean. Two bags is a sensible split: one for '
            'labour and the first hours, one for the stay.'),
      ]),
      PvReadSection(
        heading: _en('The documents — the pocket that matters'),
        bullets: [
          _en('The antenatal file: every scan report and blood test, in date '
              'order.'),
          _en('Hospital registration papers and the doctor\'s admission '
              'letter, if given.'),
          _en('Insurance card and the TPA pre-authorisation, or the cash '
              'arrangement.'),
          _en('Both of your ID cards (Aadhaar or passport), needed for the '
              'birth registration.'),
          _en('Your blood group card.'),
          _en('A written birth plan, if you have one, and the phone numbers '
              'of the people to call.'),
        ],
      ),
      PvReadSection(
        heading: _en('For labour and the first hours'),
        bullets: [
          _en('A loose cotton nightdress or kurta that opens at the front, '
              'and a dupatta or shawl.'),
          _en('Rubber slippers that slip on; socks — labour rooms are cold.'),
          _en('A hair tie, lip balm, a water bottle with a straw, and '
              'something to eat afterwards — you will be hungrier than you '
              'expect.'),
          _en('Phone, a long charging cable, and a power bank.'),
          _en('For your partner: a change of clothes, snacks, and the list '
              'of who to call in what order.'),
        ],
      ),
      PvReadSection(
        heading: _en('For the stay'),
        bullets: [
          _en('Two or three front-opening nightdresses; a light dressing '
              'gown.'),
          _en('Nursing bras (a size up from now) and breast pads.'),
          _en('Maternity pads — the thick kind, two packs; the hospital\'s '
              'supply runs out on day two.'),
          _en('Old, large, soft cotton underwear — six or more — and after a '
              'caesarean, high-waisted ones that sit above the cut.'),
          _en('Toiletries, a towel, and a small mirror; a comfortable '
              'going-home outfit that fitted at six months.'),
          _en('For the baby: three or four cotton jhablas or bodysuits, '
              'mittens, a cap, two soft cotton sheets and a light blanket, '
              'a pack of newborn nappies, and cotton wool or fragrance-free '
              'wipes. The going-home outfit in a separate bag.'),
        ],
      ),
      PvReadSection(
        heading: _en('What nobody uses'),
        paragraphs: [
          _en('The birthing ball you will not be allowed in the labour room; '
              'the playlist; the second bag of baby clothes; the massage '
              'oil; the fancy robe. A book, perhaps — labour has long slow '
              'stretches — but the phone usually does that job. What people '
              'wish they had brought: a second phone charger, more pads, '
              'a small pillow of their own, and snacks for the night.'),
        ],
      ),

      PvReadSection(
        heading: _en('The paperwork after the birth'),
        paragraphs: [
          _en('Two documents come out of the hospital that families '
              'commonly lose: the discharge summary, which every '
              'paediatrician will ask for at the first visit and which '
              'records the birth weight, the Apgar scores and the vaccines '
              'given; and the immunisation card, which the baby will need '
              'for school admission years from now. Photograph both before '
              'you leave. The birth certificate is applied for at the '
              'municipal office, usually within 21 days, using the '
              'hospital\'s birth report — the hospital will tell you '
              'whether they file it or you do, and the answer varies by '
              'city.'),
          _en('If you are claiming maternity insurance, the claim needs the '
              'discharge summary, the itemised bill, and the '
              'pre-authorisation; keep them together in the same file that '
              'held the antenatal reports. That file, started in the first '
              'trimester, is now the child\'s first medical record.'),
        ],
      ),

      PvReadSection(
        heading: _en('If it is a planned caesarean'),
        paragraphs: [
          _en('Pack for four nights rather than two, add high-waisted '
              'underwear and a loose kurta that will not press on the '
              'wound, and a small pillow to hold against the abdomen when '
              'you cough or laugh. You will be asked to fast from midnight '
              'and to come in early; a phone charger and something to read '
              'matter more that morning than on a labour day.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not wait for the bag if'),
      body: _en('Your waters break, there is bleeding, contractions are five '
          'minutes apart or less, or the baby is moving much less. Go, and '
          'send someone back for the bag. A hospital can lend everything '
          'in it; it cannot lend the hour.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('When should the bag be packed?'),
        answer: _en('By 36 weeks — earlier if you have had a preterm birth, '
            'are carrying twins, or have been told the baby may come early.'),
      ),
      PvReadFaq(
        question: _en('Should I bring a car seat?'),
        answer: _en('If you will drive home, yes — fitted in the car in '
            'advance, not carried up to the ward. Indian hospitals do not '
            'require one for discharge, but it is the safest way home.'),
      ),
      PvReadFaq(
        question: _en('What about the baby\'s first vaccines?'),
        answer: _en('BCG, the birth dose of hepatitis B and OPV are given '
            'before discharge in most hospitals; you do not bring them. Ask '
            'for the immunisation card before you leave.'),
      ),
    ],
    evidence: _en('NICE NG235 Intrapartum care (2023) on when to go in; '
        'Indian Academy of Pediatrics immunisation schedule (2024); FOGSI '
        'patient guidance; the Registration of Births and Deaths Act, 1969.'),
    readNext: ['${kPregWeekReadPrefix}labour_prep', '${kPregWeekReadPrefix}first_24h'],
  ),

  // ---------------------------------------------------------------------------
  //  labour_prep · weeks 34–40
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}labour_prep',
    hue: _hue,
    kicker: _en('Birth'),
    title: _en('Labour, step by step'),
    teaser: _en('The three stages, how long each usually takes, what a '
        'contraction feels like from the inside, and when "go in" means '
        'now.'),
    scaleSetter: _en('Labour is a process with a shape, and knowing the shape '
        'is most of what makes it manageable. It begins slowly, builds over '
        'hours, has a hard hour or two near the end, and then a baby. A '
        'first labour averages twelve to eighteen hours from the first '
        'regular contractions; second labours are usually much shorter.'),
    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('Before labour there is often a prelude: the baby settling lower '
            '("dropping"), a heavier feeling in the pelvis, an increase in '
            'discharge, the "show" — a plug of mucus, sometimes streaked '
            'with blood — and a burst of tidying energy that everyone '
            'laughs about and everyone gets. None of these means labour is '
            'hours away; the show can come a week early.'),
        _en('Braxton Hicks tightenings are the rehearsal: irregular, '
            'painless, easing when you walk or change position. Real '
            'contractions are regular, get closer together and stronger, '
            'and do not stop when you move.'),
      ]),
      PvReadSection(
        heading: _en('The first stage: the cervix opens'),
        paragraphs: [
          _en('The longest stage, from the first regular contractions until '
              'the cervix is fully open at 10 centimetres. The early or '
              '"latent" phase — contractions every five to twenty minutes, '
              'lasting thirty to forty-five seconds, the cervix opening to '
              'about four centimetres — can last many hours, and is best '
              'spent at home: eat, drink, rest between contractions, walk, '
              'shower. Established labour — contractions every three to '
              'four minutes, a minute long, the cervix from four to ten — '
              'is the part that needs the hospital, and it usually moves at '
              'about a centimetre an hour in a first labour.'),
          _en('The last stretch, "transition", from about eight to ten '
              'centimetres, is the hardest hour: contractions almost '
              'continuous, shaking, nausea, a feeling of not being able to '
              'do it. That feeling is the reliable sign that you nearly '
              'have.'),
        ],
      ),
      PvReadSection(
        heading: _en('The second stage: the baby is born'),
        paragraphs: [
          _en('From fully open to birth — usually under two hours in a first '
              'labour, often under an hour after that. The contractions '
              'change character to a pushing urge, which many women find '
              'easier than the first stage because there is something to '
              'do. Positions that use gravity — squatting, kneeling, on '
              'all fours, sitting upright — shorten it; lying flat is the '
              'position for the doctor, not for you, and most hospitals now '
              'allow others. The head crowns, stretches the perineum with '
              'a burning feeling for a minute or two, and then the baby is '
              'out in one or two more pushes.'),
        ],
      ),
      PvReadSection(
        heading: _en('The third stage: the placenta'),
        paragraphs: [
          _en('Five to thirty minutes after the baby, a few mild '
              'contractions deliver the placenta. Most Indian hospitals give '
              'an injection of oxytocin as the baby is born to reduce '
              'bleeding — "active management" — and it is standard and '
              'safe. The baby can be on your chest throughout; skin-to-skin '
              'in the first hour and the first feed are the two things '
              'worth asking for in the birth plan.'),
        ],
      ),
      PvReadSection(
        heading: _en('When to go in'),
        bullets: [
          _en('Contractions every five minutes, lasting a minute, for an '
              'hour — the "5-1-1" rule — or sooner if the hospital is far '
              'or this is not your first.'),
          _en('Your waters break, whether or not contractions have started. '
              'Note the colour: clear or pink is usual; green or brown means '
              'go now.'),
          _en('Bleeding more than the streaks of a show.'),
          _en('The baby moving less.'),
          _en('You feel you need to. Nobody is sent away for coming early.'),
        ],
      ),

      PvReadSection(
        heading: _en('When labour is started or helped along'),
        paragraphs: [
          _en('Around one labour in four in Indian private hospitals is '
              'induced — started with medicine — most often for going past '
              '41 weeks, for the waters breaking without contractions, for '
              'high blood pressure, or for a baby growing slowly. Induction '
              'usually begins with a gel or tablet to soften the cervix, '
              'then breaking the waters, then an oxytocin drip. It can take '
              'a day or more from the first dose, and the contractions of '
              'an induced labour often build faster than a spontaneous one, '
              'which is worth knowing when deciding about pain relief.'),
          _en('A caesarean is the birth for about one in three women in '
              'Indian private hospitals — planned for a breech baby, a '
              'placenta over the cervix, twins in some positions, or a '
              'previous caesarean by choice; unplanned when labour stalls '
              'or the baby shows signs of not coping. Either way it is a '
              'thirty-to-sixty-minute operation under a spinal anaesthetic, '
              'awake, with the baby on your chest in the theatre in most '
              'hospitals now. Ask your doctor at 36 weeks what their '
              'threshold for each is; the honest answers vary, and you are '
              'entitled to them.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go now, and call on the way, if'),
      body: _en('The waters are green or brown, there is bright red '
          'bleeding, the baby is moving much less, you have a severe '
          'headache or vision changes, you feel a cord in the vagina, or '
          'labour begins before 37 weeks. Call an ambulance if you are '
          'faint or the contractions are on top of each other.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('How much does it hurt?'),
        answer: _en('Contractions are intense, wave-shaped, and have rests '
            'between them. Pain relief runs from breathing, water and '
            'position through gas-and-air and injections to an epidural; '
            'there is a full read on the options in the rail below.'),
      ),
      PvReadFaq(
        question: _en('What if I am overdue?'),
        answer: _en('Most doctors offer induction between 41 and 42 weeks, '
            'sometimes earlier for a specific reason. It is a conversation '
            'at your 40-week visit, not a surprise.'),
      ),
      PvReadFaq(
        question: _en('Can my partner be in the room?'),
        answer: _en('In most private hospitals, yes, for a normal delivery; '
            'policies vary for caesareans. Ask at registration, in writing.'),
      ),
    ],
    evidence: _en('NICE NG235 Intrapartum care for healthy women and babies '
        '(2023); WHO recommendations: intrapartum care for a positive '
        'childbirth experience (2018); ACOG Committee Opinion 766 on '
        'approaches to limit intervention; FOGSI labour guidance.'),
    readNext: ['preg_labour_read_pain_relief', '${kPregWeekReadPrefix}first_24h'],
  ),

  // ---------------------------------------------------------------------------
  //  first_24h · weeks 36–40
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}first_24h',
    hue: 12,
    kicker: _en('Birth'),
    title: _en('The first 24 hours after birth'),
    teaser: _en('What happens to the baby, what happens to you, the first '
        'feed, and the checks and jabs that fill the first day.'),
    scaleSetter: _en('The first day is a sequence of ordinary things that '
        'feel enormous. The baby is checked, dried, put on your chest, and '
        'feeds within the hour. You are stitched if needed, watched for '
        'bleeding, and helped to the bathroom. By the evening you will '
        'have done most of it once — and that once is what the day is for.'),
    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('At birth the baby is dried, and if breathing well is placed on '
            'your chest, skin to skin, with a warm cloth over both of you. '
            'The cord is clamped after a minute or so — delayed clamping is '
            'now routine and gives the baby extra iron — and cut. The '
            'Apgar score at one and five minutes is a quick check of '
            'colour, breathing, heart rate, tone and reflexes; seven or '
            'above is fine, and most babies score eight or nine.'),
        _en('Weight, length and head circumference are measured, a vitamin '
            'K injection is given to prevent a rare bleeding disorder, and '
            'an ID band goes on the baby\'s ankle. In India the BCG, the '
            'birth dose of hepatitis B and the oral polio drops are usually '
            'given in the first day or before discharge.'),
      ]),
      PvReadSection(
        heading: _en('The first feed'),
        paragraphs: [
          _en('Babies are alert for about an hour after birth and then sleep '
              'deeply; that hour is the window for the first feed, and '
              'skin-to-skin contact is how most find the breast on their '
              'own. What comes first is colostrum — thick, yellow, a few '
              'millilitres — which is exactly the volume a stomach the size '
              'of a marble needs. Milk "comes in" on day two to four. A '
              'baby who feeds eight to twelve times in the first day is '
              'doing the job; a baby who sleeps through the first day may '
              'need waking every three hours.'),
          _en('Ask for the lactation nurse on day one, not day three. The '
              'latch is the thing worth getting right while someone is '
              'watching.'),
        ],
      ),
      PvReadSection(
        heading: _en('What happens to you'),
        bullets: [
          _en('Bleeding (lochia) like a heavy period, red for the first few '
              'days, then brown, then yellowish over two to six weeks. '
              'Passing clots bigger than a lemon, or soaking a pad an hour, '
              'is a reason to call the nurse.'),
          _en('Afterpains — cramping as the uterus shrinks, stronger during '
              'feeds and in second births. Paracetamol is fine.'),
          _en('Stitches, if there was a tear or an episiotomy: sore for a '
              'week, eased by ice, a warm sitz bath, and pouring water while '
              'passing urine.'),
          _en('After a caesarean: up and walking within a day, the catheter '
              'out, and pain managed with regular medicine rather than '
              'waiting for it.'),
          _en('The first pass of urine within six hours, and the first '
              'bowel movement — often not until day two or three, which is '
              'normal.'),
        ],
      ),
      PvReadSection(
        heading: _en('The baby\'s first day'),
        paragraphs: [
          _en('The first stool is meconium — black, sticky, alarming and '
              'normal; it changes to green then yellow over three days. One '
              'or two wet nappies on day one is enough. Newborns sneeze, '
              'hiccup, have swollen genitals from your hormones, and may '
              'have small white spots on the nose (milia) and a bluish tint '
              'to hands and feet in the first hours. None of these needs '
              'anything. Jaundice appearing after day two is common and is '
              'checked before discharge; jaundice in the first 24 hours is '
              'not usual and is looked at straight away.'),
        ],
      ),
      PvReadSection(
        heading: _en('Before you go home'),
        paragraphs: [
          _en('The newborn examination by a paediatrician, the hearing '
              'screen, the immunisation card, the discharge summary, and — '
              'in most cities — the birth registration form, which the '
              'hospital files and you collect later. Ask what the follow-up '
              'plan is for you and for the baby, and get the number to call '
              'at night.'),
        ],
      ),

      PvReadSection(
        heading: _en('The two feelings nobody warns you about'),
        paragraphs: [
          _en('The first is nothing. Some women feel a rush of love in the '
              'first minute; many feel relief, exhaustion, and a polite '
              'interest in the stranger on their chest. That is normal, it '
              'is common, and it is not a verdict on you or the baby. The '
              'bond is built over the first weeks by feeding and holding, '
              'and it arrives for almost everyone.'),
          _en('The second is the third-day dip. Around day three, as the '
              'milk comes in and the hormones fall, most women cry for no '
              'reason they can name. The "baby blues" affect up to eight '
              'women in ten, last a few days, and need only rest and '
              'someone kind. Low mood that lasts beyond two weeks, or that '
              'makes it hard to care for the baby, is different and is '
              'treated — say so at the postnatal visit, or before.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Tell the nurse or doctor at once if'),
      body: _en('You are soaking a pad an hour or passing large clots, feel '
          'faint, have a fever, a severe headache, or a red painful calf; '
          'or the baby is not feeding at all, is blue around the lips, is '
          'floppy, is breathing fast or grunting, or is yellow in the first '
          'day. After discharge, the same list means a call the same hour.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should the baby have honey or ghutti?'),
        answer: _en('No. Nothing but breast milk (or formula if chosen) in the '
            'first six months. Honey can carry botulism spores, and '
            'traditional pre-lacteal feeds displace colostrum and raise '
            'infection risk.'),
      ),
      PvReadFaq(
        question: _en('When can visitors come?'),
        answer: _en('When you want them, and briefly. The first day is for '
            'feeding, sleeping and learning the baby; a hospital ward full '
            'of relatives makes all three harder.'),
      ),
      PvReadFaq(
        question: _en('How long will we stay?'),
        answer: _en('Usually 24 to 48 hours after a normal delivery, three to '
            'five days after a caesarean, depending on how you both are.'),
      ),
    ],
    evidence: _en('WHO recommendations on maternal and newborn care for a '
        'positive postnatal experience (2022); NICE NG194 Postnatal care '
        '(2021); Indian Academy of Pediatrics newborn care and immunisation '
        'guidance; WHO / UNICEF Baby-Friendly Hospital Initiative.'),
    readNext: ['${kPregWeekReadPrefix}exp_meera', '${kPregWeekReadPrefix}hospital_bag'],
  ),
];
