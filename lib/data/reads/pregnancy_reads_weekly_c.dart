// =============================================================================
//  Pregnancy reads — the weekly reads, written out (c: weeks 24–40)
// -----------------------------------------------------------------------------
//  See pregnancy_reads_weekly_a.dart. Same bar, same clinical rules.
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

final List<PvRead> kPregnancyReadsWeeklyC = [
  // ---------------------------------------------------------------------------
  //  third_tri_prep · weeks 24–30
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}third_tri_prep',
    hue: _hue,
    kicker: _en('Third trimester'),
    title: _en('Getting ready for the third trimester'),
    teaser: _en('From 28 weeks the visits get closer, the tests get more '
        "specific, and your baby doubles in weight. What's on the calendar "
        'and what to sort out before it starts.'),
    shortAnswer: _en('From 28 weeks you\'ll see your doctor every two weeks, '
        'then weekly from 36. The glucose test, Tdap vaccine and growth scan '
        'fall now. The weeks before 28 are the best time to sort out the '
        'hospital, the money, your leave and who will help at home.'),
    scaleSetter: _en('The third trimester is thirteen weeks in which your baby '
        'goes from about a kilo to three and a half, and pregnancy asks the '
        'most of you. Most of what makes it easier is arranged in the last '
        'weeks of the second trimester. That is now.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('From 28 weeks your antenatal visits usually move to every two '
            'weeks, and from 36 weeks to every week. Each visit checks your '
            'blood pressure, your urine for protein, your bump height, and '
            "your baby's heartbeat and position."),
        _en('The particular tests of this trimester are the glucose tolerance '
            "test if it hasn't been done, a repeat haemoglobin, the Tdap "
            'vaccine and a growth scan. In some practices there is also a swab '
            'for group B streptococcus from 36 weeks.'),
      ]),
      PvReadSection(
        heading: _en("What's on the calendar?"),
        bullets: [
          _en('24 to 28 weeks: the oral glucose tolerance test for gestational '
              'diabetes. An anti-D injection at 28 weeks if your blood group '
              'is Rh negative.'),
          _en('27 to 36 weeks: the Tdap vaccine, which protects your newborn '
              'from whooping cough through your antibodies. A flu shot in '
              'season.'),
          _en("28 to 32 weeks: a growth scan, and getting to know your baby's "
              'movement pattern.'),
          _en('32 to 36 weeks: a second growth scan if advised, a placenta '
              'rescan if it was low earlier, and the birth plan conversation.'),
          _en('From 36 weeks: weekly visits, your baby\'s position checked, '
              'and the hospital bag by the door.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you sort out now?'),
        paragraphs: [
          _en('The hospital. Register if the hospital asks you to. Find out '
              'what the package includes and leaves out, the caesarean rate, '
              'whether your partner can be with you, and what happens at '
              "night and on holidays. Ask about the NICU. You probably won't "
              "need it, but knowing there's one on site is one less thing to "
              'fear.'),
          _en('The money. Maternity insurance in India usually has a waiting '
              'period of two to four years and a sub-limit. Check yours now, '
              'not at discharge. Employer schemes and the PMMVY cash benefit '
              'for a first child each need paperwork done in advance.'),
          _en('The leave. The Maternity Benefit Act gives 26 weeks of paid '
              'leave for a first or second child, and up to eight of them can '
              'be taken before the due date. Give your employer the dates in '
              'writing by the end of the second trimester.'),
          _en('The help. Who will be in the house in the first month? Your '
              'mother, your mother-in-law, a hired helper, your partner on '
              'leave? Decide, and decide who is in charge of what, before '
              'everyone arrives at once.'),
        ],
      ),
      PvReadSection(
        heading: _en('How will your body feel from here?'),
        paragraphs: [
          _en('Breathless on the stairs, as your womb presses up on your '
              'diaphragm.'),
          _en('Heartburn, as it presses on your stomach. Small meals, an '
              'extra pillow, and antacids your doctor approves all help.'),
          _en('Swollen feet by evening, eased by putting them up. Swelling of '
              'your face and hands is different, and is a reason to call.'),
          _en('Braxton Hicks tightenings from around 30 weeks. They are '
              'irregular and painless.'),
          _en('Harder sleep. Lie on your side with a pillow between your '
              'knees, and take a short afternoon rest without guilt.'),
        ],
      ),

      PvReadSection(
        heading: _en('What is each test for?'),
        bullets: [
          _en('Glucose tolerance test: a sugar drink, then blood taken at set '
              'times, to find gestational diabetes. It is common in India, '
              'and diet is usually the first treatment.'),
          _en('Anti-D: an injection for Rh-negative mothers. It stops your '
              "body reacting to an Rh-positive baby's blood, which protects "
              'this pregnancy and future ones.'),
          _en('Haemoglobin: repeated because anaemia is most common now, '
              'when your baby is taking the most iron.'),
          _en("Growth scan: your baby's size against the dates, the fluid, "
              'and the blood flow in the cord.'),
          _en('Group B strep swab: a bacterium many women carry harmlessly. '
              'If you have it, antibiotics in labour stop it reaching your '
              "baby. Not every practice tests for it, so ask."),
          _en('Blood pressure and urine at every visit: these two checks '
              "catch pre-eclampsia early. That's why the visits get closer."),
        ],
      ),

      PvReadSection(
        heading: _en('Is it all right to rest more?'),
        paragraphs: [
          _en('Yes. In the third trimester "listen to your body" stops being '
              'a platitude. Sleep is broken by your bladder, your hips and '
              "your baby's evening football. The afternoon rest that was "
              'optional at twenty weeks really restores you at thirty-four.'),
          _en('Lie down for half an hour after lunch if you can, on your left '
              "side. Let the household know it's medical, not lazy, because "
              'it is.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en('You have a severe headache, blurred vision or flashing '
          'lights, sudden swelling of your face or hands, pain under your '
          'right ribs, bleeding, a gush or trickle of fluid, regular '
          'tightenings before 37 weeks, fever, or your baby is moving '
          'noticeably less. None of these waits for the next visit.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is the Tdap vaccine safe?'),
        answer: _en('Yes, and it\'s recommended in every pregnancy. The '
            'antibodies you make cross to your baby and protect against '
            'whooping cough until their own vaccines begin at six weeks.'),
      ),
      PvReadFaq(
        question: _en('When should I stop working?'),
        answer: _en("There's no medical rule for an uncomplicated pregnancy. "
            'Many women work to 36 or 38 weeks. Heavy or standing work may '
            'need adjusting earlier. The eight weeks of leave allowed before '
            'the due date are yours to place.'),
      ),
      PvReadFaq(
        question: _en('What is a birth plan?'),
        answer: _en('A short written note of what you\'d prefer: pain relief, '
            'who is with you, skin-to-skin, feeding. You talk it through with '
            "your doctor at around 34 to 36 weeks. It's a conversation, not a "
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
    title: _en("Knowing your baby's movements"),
    teaser: _en('From 28 weeks, the pattern matters more than the count. How '
        'to learn yours, what "less" means, and why the advice is to call '
        'rather than wait.'),
    shortAnswer: _en("Get to know your baby's usual pattern of movements by "
        '28 weeks. Babies don\'t move less as they run out of room. If the '
        'movements are fewer, weaker or different, call your doctor or '
        'hospital the same day, at any hour.'),
    scaleSetter: _en("Your baby's movements are the one check you can do "
        'yourself, every day, for free. The evidence is clear that women who '
        "know their baby's pattern and act on a change catch problems "
        "earlier. The rule is this: learn what's normal for your baby, and if "
        "it changes, call the same day. Don't wait until morning, and don't "
        'test it with cold water or a sweet.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Movements are felt from 16 to 24 weeks and become regular by 28. '
            "After that they don't \"slow down as the baby runs out of room\". "
            "That's a myth, and a dangerous one."),
        _en('The kind of movement changes as your baby grows, from kicks to '
            "rolls and stretches. How often they move shouldn't fall. A baby "
            'who moves less is a baby to be checked.'),
        _en('Every baby has their own pattern: a busy time in the evening, a '
            'quiet spell after you walk, a response to a meal or to lying on '
            "your left side. By 28 weeks you'll know yours. That pattern, not "
            'a number, is your baseline.'),
      ]),
      PvReadSection(
        heading: _en('What about "count ten kicks"?'),
        paragraphs: [
          _en('Kick counting, ten movements in two hours, was the older advice '
              "and some clinics still use it. It isn't wrong, but it has two "
              'problems. It makes women who feel eight movements panic. And it '
              'reassures women who feel ten when their baby usually does '
              'forty.'),
          _en('Current guidance in the UK, Australia and more and more in '
              'India is to know your pattern and act on a change. If your '
              'doctor has given you a counting method, use it. If not, the '
              'pattern is the better guide.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does "less" look like?'),
        bullets: [
          _en("The evening burst that always comes doesn't come."),
          _en("You realise at lunchtime that you haven't felt anything since "
              'you woke up.'),
          _en('Movements are there but feel weaker, or fewer, than yesterday '
              'and the day before.'),
          _en("Your baby doesn't respond to the things that usually get a "
              'reaction: your voice, a hand on your belly, lying down.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you do?'),
        paragraphs: [
          _en('Lie on your left side somewhere quiet for up to two hours and '
              'pay attention. If the movements go back to normal, that is '
              'usually all it was, but tell your doctor at the next visit.'),
          _en("If they don't, or you're still unsure, call the hospital or "
              "your doctor the same day, at any hour. You'll be asked to come "
              "in so they can listen to your baby's heartbeat. After 28 weeks "
              "there's usually a CTG trace too, lasting twenty to forty "
              'minutes.'),
          _en('No one at a maternity unit thinks less of you for coming in '
              'with reduced movements and being sent home reassured. That '
              'visit is the system working. The visit that worries doctors is '
              "the one that didn't happen."),
        ],
      ),
      PvReadSection(
        heading: _en("What doesn't help?"),
        paragraphs: [
          _en('A cold drink, a sugary snack, poking your belly, or a home '
              'doppler. None of these is a reliable test. A home doppler in '
              'particular can pick up your own pulse or the placenta and give '
              'false reassurance.'),
          _en('If you feel the need to check, that feeling is your reason to '
              'call.'),
        ],
      ),

      PvReadSection(
        heading: _en('What happens when you go in?'),
        paragraphs: [
          _en("Knowing the visit is calm and routine makes it easier to go. "
              "You'll be asked when you last felt your baby and what their "
              'usual pattern is. A midwife or doctor will listen to the '
              'heartbeat with a handheld doppler.'),
          _en("After 28 weeks you'll usually be put on a CTG: two belts on "
              'your belly that trace the heartbeat and any contractions for '
              'twenty to forty minutes. A reassuring trace shows a heart rate '
              "that rises when your baby moves. If the trace isn't clear, or "
              'there are other risk factors, a scan of the fluid and the blood '
              'flow in the cord follows the same day.'),
          _en('In the great majority of visits the trace is normal, your baby '
              'wakes up under the belts and kicks the monitor, and you go '
              "home. In the small number where it isn't, the timing of that "
              'visit is what made the difference. Both are the reason the '
              'advice is "call", not "wait".'),
        ],
      ),

      PvReadSection(
        heading: _en('What about twins, or a placenta at the front?'),
        paragraphs: [
          _en("With twins you won't be able to tell which baby is moving, and "
              "you aren't expected to. The rule is the same: the overall "
              'pattern, and a change in it.'),
          _en('A placenta at the front of the womb cushions the kicks. They '
              'can feel later and softer, especially before 28 weeks. By the '
              "third trimester you'll still know your baby's pattern, and the "
              'same rule applies without exception.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the same day, at any hour, if'),
      body: _en("Your baby's movements are fewer, weaker, or different from "
          'the pattern you know. Call every time it happens, even if you were '
          "checked last week. Don't wait until morning. Don't use a home "
          'doppler to decide.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can the baby move too much?'),
        answer: _en('A sudden, unusually frantic burst of movement, unlike '
            'anything before, is worth a call too. It is much less often a '
            'sign of a problem than reduced movement is.'),
      ),
      PvReadFaq(
        question: _en('Does the placenta at the front hide movements?'),
        answer: _en("It can dull them, especially before 28 weeks. It doesn't "
            "change the rule: learn your baby's pattern, whatever it is, and "
            'act on a change.'),
      ),
      PvReadFaq(
        question: _en('Should I use an app to count?'),
        answer: _en('If it helps you notice the pattern, yes. If it replaces '
            'noticing with a number, no. The tool in this app records your '
            "baby's pattern rather than setting a target."),
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
        'front pocket. What goes in, what Indian hospitals provide, and what '
        'nobody uses.'),
    shortAnswer: _en('Pack your bag by 36 weeks and keep it by the door. The '
        'most important thing in it is the file with all your reports, your '
        'ID and your insurance papers. Ask your hospital what they provide, '
        'and pack for two nights after a normal birth or four to five after '
        'a caesarean.'),
    scaleSetter: _en("The bag isn't about the things. It's about not having "
        'to think at 3am. Pack it once, properly, by week 36. Put the file '
        'with every report and the insurance card in the outside pocket. '
        'Hospitals ask for that file first, and families forget it most.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Indian hospitals vary more than any list can cover. A large '
            'private hospital will provide gowns, baby clothes for the stay, '
            'nappies and toiletries, and will tell you at registration what '
            'to bring. A smaller nursing home or a government hospital may '
            'provide almost nothing.'),
        _en("Ask at the pre-admission visit. If you're not sure, pack as if "
            'they provide nothing.'),
        _en('Plan for a two-night stay after a normal delivery, and four to '
            'five nights after a caesarean. Two bags is a sensible split: one '
            'for labour and the first hours, one for the stay.'),
      ]),
      PvReadSection(
        heading: _en('The documents: the pocket that matters'),
        bullets: [
          _en('Your antenatal file: every scan report and blood test, in date '
              'order.'),
          _en("Hospital registration papers and the doctor's admission "
              'letter, if you were given one.'),
          _en('Your insurance card and the TPA pre-authorisation, or the cash '
              'arrangement.'),
          _en('ID cards for both of you (Aadhaar or passport). They are '
              'needed for the birth registration.'),
          _en('Your blood group card.'),
          _en('A written birth plan if you have one, and the phone numbers of '
              'the people to call.'),
        ],
      ),
      PvReadSection(
        heading: _en('For labour and the first hours'),
        bullets: [
          _en('A loose cotton nightdress or kurta that opens at the front, '
              'and a dupatta or shawl.'),
          _en('Rubber slippers you can slip on, and socks. Labour rooms are '
              'cold.'),
          _en('A hair tie, lip balm, a water bottle with a straw, and '
              "something to eat afterwards. You'll be hungrier than you "
              'expect.'),
          _en('Your phone, a long charging cable and a power bank.'),
          _en('For your partner: a change of clothes, snacks, and the list of '
              'who to call in what order.'),
        ],
      ),
      PvReadSection(
        heading: _en('For the stay'),
        bullets: [
          _en('Two or three front-opening nightdresses, and a light dressing '
              'gown.'),
          _en('Nursing bras (a size up from now) and breast pads.'),
          _en("Maternity pads, the thick kind, two packs. The hospital's "
              'supply runs out on day two.'),
          _en('Old, large, soft cotton underwear, six or more. After a '
              'caesarean, high-waisted ones that sit above the cut.'),
          _en('Toiletries, a towel and a small mirror. A comfortable going-home '
              'outfit that fitted you at six months.'),
          _en('For your baby: three or four cotton jhablas or bodysuits, '
              'mittens, a cap, two soft cotton sheets and a light blanket, a '
              'pack of newborn nappies, and cotton wool or fragrance-free '
              'wipes. Keep the going-home outfit in a separate bag.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does nobody use?'),
        paragraphs: [
          _en("The birthing ball you won't be allowed in the labour room. The "
              'playlist. The second bag of baby clothes. The massage oil. The '
              'fancy robe. A book, perhaps, since labour has long slow '
              'stretches, but your phone usually does that job.'),
          _en('What women wish they had brought: a second phone charger, more '
              'pads, a small pillow of their own, and snacks for the night.'),
        ],
      ),

      PvReadSection(
        heading: _en('What paperwork comes after the birth?'),
        paragraphs: [
          _en('Two documents from the hospital often get lost. The first is '
              'the discharge summary. Every paediatrician asks for it at the '
              'first visit, and it records the birth weight, the Apgar scores '
              'and the vaccines given. The second is the immunisation card, '
              'which your child will need for school admission years from '
              'now. Photograph both before you leave.'),
          _en('The birth certificate is applied for at the municipal office, '
              "usually within 21 days, using the hospital's birth report. The "
              'hospital will tell you whether they file it or you do. The '
              'answer varies by city.'),
          _en("If you're claiming maternity insurance, the claim needs the "
              'discharge summary, the itemised bill and the '
              'pre-authorisation. Keep them together in the file that held '
              'your antenatal reports. That file, started in the first '
              "trimester, is now your child's first medical record."),
        ],
      ),

      PvReadSection(
        heading: _en("What if it's a planned caesarean?"),
        paragraphs: [
          _en('Pack for four nights rather than two. Add high-waisted '
              "underwear, a loose kurta that won't press on the wound, and a "
              'small pillow to hold against your tummy when you cough or '
              'laugh.'),
          _en("You'll be asked not to eat or drink from midnight and to come "
              'in early. A phone charger and something to read matter more '
              'that morning than on a labour day.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't wait for the bag if"),
      body: _en('Your waters break, there is bleeding, contractions are five '
          'minutes apart or less, or your baby is moving much less. Go, and '
          'send someone back for the bag. A hospital can lend you everything '
          "in it. It can't lend you the hour."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('When should the bag be packed?'),
        answer: _en('By 36 weeks. Pack earlier if you have had a preterm '
            "birth before, you're carrying twins, or you've been told your "
            'baby may come early.'),
      ),
      PvReadFaq(
        question: _en('Should I bring a car seat?'),
        answer: _en("If you'll drive home, yes. Fit it in the car in advance, "
            "rather than carrying it up to the ward. Indian hospitals don't "
            "require one for discharge, but it's the safest way home."),
      ),
      PvReadFaq(
        question: _en("What about the baby's first vaccines?"),
        answer: _en('BCG, the birth dose of hepatitis B and OPV are given '
            "before discharge in most hospitals. You don't bring them. Ask "
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
        'contraction feels like, and when "go in" means now.'),
    shortAnswer: _en('Labour has three stages: your cervix opens, your baby '
        'is born, then the placenta comes. A first labour usually takes 12 '
        'to 18 hours from the first regular contractions. Go in when '
        'contractions come every five minutes, last a minute, for an hour, '
        'or sooner if your waters break or anything worries you.'),
    scaleSetter: _en('Labour has a shape, and knowing the shape is most of '
        'what makes it manageable. It begins slowly, builds over hours, has '
        'a hard hour or two near the end, and then there is a baby. A first '
        'labour averages twelve to eighteen hours from the first regular '
        'contractions. Second labours are usually much shorter.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Before labour there are often early signs. Your baby settles '
            'lower ("dropping"), your pelvis feels heavier, and you have more '
            'discharge. There may be a "show", a plug of mucus sometimes '
            'streaked with blood. Many women also get a burst of tidying '
            'energy that everyone laughs about. None of these means labour is '
            'hours away. The show can come a week early.'),
        _en('Braxton Hicks tightenings are the rehearsal. They are irregular '
            'and painless, and ease when you walk or change position. Real '
            'contractions are regular, get closer together and stronger, and '
            "don't stop when you move."),
      ]),
      PvReadSection(
        heading: _en('The first stage: your cervix opens'),
        paragraphs: [
          _en('This is the longest stage. It runs from the first regular '
              'contractions until your cervix is fully open at 10 '
              'centimetres.'),
          _en('The early ("latent") phase can last many hours. Contractions '
              'come every five to twenty minutes and last thirty to '
              'forty-five seconds, and your cervix opens to about four '
              'centimetres. This part is best spent at home: eat, drink, rest '
              'between contractions, walk, shower.'),
          _en('Established labour is the part that needs the hospital. '
              'Contractions come every three to four minutes and last a '
              'minute, and your cervix opens from four to ten. In a first '
              'labour it usually moves at about a centimetre an hour.'),
          _en('The last stretch, from about eight to ten centimetres, is '
              'called transition. It is the hardest hour: contractions almost '
              'continuous, shaking, nausea, and a feeling that you can\'t do '
              "it. That feeling is a reliable sign you're nearly there."),
        ],
      ),
      PvReadSection(
        heading: _en('The second stage: your baby is born'),
        paragraphs: [
          _en('This runs from fully open to birth. It usually takes under two '
              'hours in a first labour, and often under an hour after that. '
              'The contractions change to an urge to push. Many women find '
              "this easier than the first stage, because there's something "
              'to do.'),
          _en('Positions that use gravity shorten it: squatting, kneeling, on '
              'all fours, sitting upright. Lying flat suits the doctor more '
              'than you, and most hospitals now allow other positions.'),
          _en('The head crowns and stretches the skin around the vagina '
              '(perineum), with a burning feeling for a minute or two. Then '
              'your baby is out in one or two more pushes.'),
        ],
      ),
      PvReadSection(
        heading: _en('The third stage: the placenta'),
        paragraphs: [
          _en('Five to thirty minutes after your baby, a few mild contractions '
              'deliver the placenta. Most Indian hospitals give an injection '
              'of oxytocin as the baby is born, to reduce bleeding. This is '
              'called "active management", and it is standard and safe.'),
          _en('Your baby can be on your chest the whole time. Skin-to-skin in '
              'the first hour, and the first feed, are the two things worth '
              'asking for in your birth plan.'),
        ],
      ),
      PvReadSection(
        heading: _en('When should you go in?'),
        bullets: [
          _en('Contractions every five minutes, lasting a minute, for an hour '
              '(the "5-1-1" rule). Go sooner if the hospital is far or this '
              "isn't your first baby."),
          _en('Your waters break, whether or not contractions have started. '
              'Note the colour: clear or pink is usual. Green or brown means '
              'go now.'),
          _en('Bleeding that is more than the streaks of a show.'),
          _en('Your baby moving less.'),
          _en('You feel you need to. Nobody is sent away for coming early.'),
        ],
      ),

      PvReadSection(
        heading: _en('What if labour is started or helped along?'),
        paragraphs: [
          _en('Around one labour in four in Indian private hospitals is '
              'induced, which means started with medicine. The most common '
              'reasons are going past 41 weeks, the waters breaking without '
              'contractions, high blood pressure, or a baby growing slowly.'),
          _en('Induction usually starts with a gel or tablet to soften the '
              'cervix, then breaking the waters, then an oxytocin drip. It can '
              'take a day or more from the first dose. The contractions of an '
              'induced labour often build faster than in one that starts on '
              'its own. That is worth knowing when you think about pain '
              'relief.'),
          _en('About one in three women in Indian private hospitals give birth '
              'by caesarean. It may be planned, for a breech baby, a placenta '
              'over the cervix, twins in some positions, or by choice after an '
              'earlier caesarean. It may be unplanned, when labour stalls or '
              'the baby shows signs of not coping.'),
          _en('Either way it is a thirty-to-sixty-minute operation under a '
              'spinal anaesthetic. You are awake, and in most hospitals now '
              'your baby is on your chest in the theatre. At 36 weeks, ask '
              'your doctor when they would suggest each. Honest answers vary, '
              "and you're entitled to them."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go now, and call on the way, if'),
      body: _en('The waters are green or brown, there is bright red bleeding, '
          'your baby is moving much less, you have a severe headache or '
          'vision changes, you feel a cord in your vagina, or labour begins '
          "before 37 weeks. Call an ambulance if you're faint or the "
          'contractions are coming on top of each other.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('How much does it hurt?'),
        answer: _en('Contractions are intense and come in waves, with rests '
            'between them. Pain relief runs from breathing, water and '
            'position, through gas-and-air and injections, to an epidural. '
            "There's a full read on the options in the rail below."),
      ),
      PvReadFaq(
        question: _en("What if I'm overdue?"),
        answer: _en('Most doctors offer induction between 41 and 42 weeks, '
            "sometimes earlier for a specific reason. It's a conversation at "
            'your 40-week visit, not a surprise.'),
      ),
      PvReadFaq(
        question: _en('Can my partner be in the room?'),
        answer: _en('In most private hospitals, yes, for a normal delivery. '
            'Rules vary for caesareans. Ask at registration, in writing.'),
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
    teaser: _en('What happens to your baby, what happens to you, the first '
        'feed, and the checks and jabs that fill the first day.'),
    shortAnswer: _en('Your baby is dried, checked and put on your chest, and '
        'usually feeds within the first hour. You are watched for bleeding '
        'and helped up. Vitamin K and the first vaccines are given, and by '
        "evening you'll have done most things once."),
    scaleSetter: _en('The first day is a string of ordinary things that feel '
        'enormous. Your baby is checked, dried, put on your chest, and feeds '
        'within the hour. You are stitched if needed, watched for bleeding, '
        "and helped to the bathroom. By evening you'll have done most of it "
        "once, and that once is what the day is for."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('At birth your baby is dried and, if breathing well, placed on '
            'your chest, skin to skin, with a warm cloth over you both. The '
            'cord is clamped after a minute or so, then cut. This delayed '
            'clamping is now routine and gives your baby extra iron.'),
        _en('The Apgar score at one and five minutes is a quick check of '
            'colour, breathing, heart rate, muscle tone and reflexes. Seven or '
            'above is fine, and most babies score eight or nine.'),
        _en('Weight, length and head size are measured. A vitamin K '
            'injection is given to prevent a rare bleeding disorder, and an '
            "ID band goes on your baby's ankle. In India the BCG, the birth "
            'dose of hepatitis B and the oral polio drops are usually given '
            'in the first day or before discharge.'),
      ]),
      PvReadSection(
        heading: _en('How does the first feed go?'),
        paragraphs: [
          _en('Babies are alert for about an hour after birth and then sleep '
              'deeply. That hour is the window for the first feed. With '
              'skin-to-skin contact, most babies find the breast on their '
              'own.'),
          _en('What comes first is colostrum: thick, yellow, a few '
              'millilitres. That is exactly the amount a stomach the size of '
              'a marble needs. Your milk "comes in" on day two to four.'),
          _en('A baby who feeds eight to twelve times in the first day is '
              'doing the job. A baby who sleeps through the first day may need '
              'waking every three hours.'),
          _en('Ask for the lactation nurse on day one, not day three. The '
              "latch is worth getting right while someone's there to watch."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens to you?'),
        bullets: [
          _en('Bleeding (lochia) like a heavy period. It is red for the first '
              'few days, then brown, then yellowish over two to six weeks. '
              'Passing clots bigger than a lemon, or soaking a pad an hour, is '
              'a reason to call the nurse.'),
          _en('Afterpains: cramping as your womb shrinks, stronger during '
              'feeds and after a second birth. Paracetamol is fine.'),
          _en('Stitches, if you had a tear or a cut (episiotomy). They are sore '
              'for a week. Ice, a warm sitz bath, and pouring water while you '
              'pass urine all help.'),
          _en('After a caesarean: up and walking within a day, the catheter '
              'out, and pain managed with regular medicine rather than waiting '
              'for it to build.'),
          _en('Passing urine for the first time within six hours. The first '
              'bowel movement often doesn\'t come until day two or three, '
              "and that's normal."),
        ],
      ),
      PvReadSection(
        heading: _en("What is your baby's first day like?"),
        paragraphs: [
          _en('The first stool is meconium: black, sticky, alarming and '
              'normal. It changes to green, then yellow, over three days. One '
              'or two wet nappies on day one is enough.'),
          _en('Newborns sneeze and hiccup. They can have swollen genitals from '
              'your hormones, small white spots on the nose (milia), and a '
              'bluish tint to the hands and feet in the first hours. None of '
              'these needs anything.'),
          _en('Jaundice appearing after day two is common and is checked '
              "before discharge. Jaundice in the first 24 hours isn't usual "
              'and is looked at straight away.'),
        ],
      ),
      PvReadSection(
        heading: _en('What happens before you go home?'),
        paragraphs: [
          _en('A paediatrician examines your baby. There is the hearing screen, '
              'the immunisation card, the discharge summary and, in most '
              'cities, the birth registration form, which the hospital files '
              'and you collect later.'),
          _en('Ask what the follow-up plan is for you and for your baby, and '
              'get the number to call at night.'),
        ],
      ),

      PvReadSection(
        heading: _en('Two feelings that can take you by surprise'),
        paragraphs: [
          _en('The first is feeling nothing much. Some women feel a rush of '
              'love in the first minute. Many feel relief, exhaustion, and a '
              "polite interest in the stranger on their chest. That's normal "
              "and common, and it isn't a verdict on you or your baby. The "
              'bond is built over the first weeks by feeding and holding, and '
              'it arrives for almost everyone.'),
          _en('The second is the third-day dip. Around day three, as your milk '
              'comes in and your hormones fall, most women cry for no reason '
              'they can name. These "baby blues" affect up to eight women in '
              'ten, last a few days, and need only rest and someone kind.'),
          _en('Low mood that lasts beyond two weeks, or that makes it hard to '
              'care for your baby, is different and can be treated. Say so at '
              'the postnatal visit, or before.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Tell the nurse or doctor at once if'),
      body: _en("You're soaking a pad an hour or passing large clots, feel "
          'faint, have a fever, a severe headache, or a red, painful calf. '
          "Or if your baby isn't feeding at all, is blue around the lips, is "
          'floppy, is breathing fast or grunting, or is yellow in the first '
          'day. After you go home, the same list means a call the same '
          'hour.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Should the baby have honey or ghutti?'),
        answer: _en('No. Nothing but breast milk (or formula, if you choose '
            'it) for the first six months. Honey can carry botulism spores. '
            'Traditional first feeds before breast milk push out colostrum '
            'and raise infection risk.'),
      ),
      PvReadFaq(
        question: _en('When can visitors come?'),
        answer: _en('When you want them, and briefly. The first day is for '
            'feeding, sleeping and getting to know your baby. A ward full of '
            'relatives makes all three harder.'),
      ),
      PvReadFaq(
        question: _en('How long will we stay?'),
        answer: _en('Usually 24 to 48 hours after a normal delivery, and three '
            'to five days after a caesarean, depending on how you both are.'),
      ),
    ],
    evidence: _en('WHO recommendations on maternal and newborn care for a '
        'positive postnatal experience (2022); NICE NG194 Postnatal care '
        '(2021); Indian Academy of Pediatrics newborn care and immunisation '
        'guidance; WHO / UNICEF Baby-Friendly Hospital Initiative.'),
    readNext: ['${kPregWeekReadPrefix}exp_meera', '${kPregWeekReadPrefix}hospital_bag'],
  ),
];
