// =============================================================================
//  Move & rest — the reads behind the tenth pregnancy door
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Move & rest", P1: *"The only tile on our home
//  without a door is this one"*, and "is it safe to exercise?" had no written
//  answer anywhere in the stage, only twelve short Can I verdicts. These are
//  our own versions, in the pregnancy voice (`docs/PREG-VOICE.md`), never
//  Flo's or What to Expect's sentences.
//
//  Every read here sits on a tile of `kMoveDoor` (`pv_door_move.dart`);
//  `test/pv_door_move_test.dart` fails if one is orphaned.
//
//  ⚠️ THE CLINICAL LINE THIS FILE HOLDS
//
//  · The stop signs are ACOG Committee Opinion 804's list, unsoftened, in one
//    shared callout (`_stopNow`) so no two reads can drift apart on them.
//  · The "don't exercise" list is ACOG's absolute contraindications, and the
//    read that carries it says plainly that her own doctor decides.
//  · Population numbers only. No sentence puts "your" beside a chance word
//    (`test/pregnancy_reads_shape_test.dart` scans for exactly that).
//  · `reviewed: false`, ParentVeda editorial, until a clinician has read them.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The Yoga & fitness bracket's own hue, so a read opened from the door
/// keeps the door's colour.
const double _hue = 160;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('Move and rest');
final LocalizedText _kMove = _en('Move safely');
final LocalizedText _kPelvic = _en('Pelvic floor');
final LocalizedText _kRest = _en('Sleep and rest');

/// The stop signs every movement read ends on (ACOG CO 804's warning signs
/// to stop exercising), in one place so they can't drift apart between reads.
final PvCallout _stopNow = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Stop, and call your doctor straight away, if'),
  body: _en("You have bleeding or fluid leaking from your vagina, feel dizzy "
      "or faint, or get a headache, chest pain or breathlessness that "
      "doesn't settle when you rest. The same goes for pain or swelling in "
      "one calf, regular painful tightenings, weakness that upsets your "
      "balance, or your baby moving less than usual. For chest pain, heavy "
      "bleeding or fainting, call 108 or go to hospital now."),
);

/// The pelvic floor tab's call line: a urine infection, and the leak that
/// may be her waters.
final PvCallout _pelvicCall = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Call your doctor today if'),
  body: _en("It burns or stings when you pee, you need to go far more often "
      "with only a little coming out, there's blood in your pee, or you have "
      "a fever or pain in your back or side. If fluid keeps trickling or "
      "gushes from your vagina and you can't hold it back, call your "
      "hospital straight away, as it may be your waters. Do the same for "
      "any bleeding, or if your baby is moving less than usual."),
);

/// The sleep reads' call line.
final PvCallout _sleepCall = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Call your doctor straight away if'),
  body: _en("Your baby is moving less than usual, or you have a severe "
      "headache, blurred vision, or sudden swelling of your face, hands or "
      "feet. Don't wait until morning to report reduced movements. Call "
      "today if you have itching that's worse at night, especially on your "
      "palms and soles, or if you feel so low or anxious that you can't "
      "cope."),
);

final List<PvRead> kPregnancyReadsMove = [
  // ===========================================================================
  //  MOVE SAFELY
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Is exercise safe, and how much
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_is_it_safe',
    hue: _hue,
    kicker: _kMove,
    title: _en('Is it safe to exercise in pregnancy?'),
    teaser: _en("How much movement is good for you and your baby, how hard to "
        "go, and how to start if you haven't been active."),
    shortAnswer: _en("Yes. For most healthy pregnancies, moving every day is "
        "safe and good for you and your baby. Aim for about 150 minutes a "
        "week of moderate activity, such as 30 minutes on five days. "
        "Moderate means you can talk while you move, but not sing."),
    scaleSetter: _en("Doctors no longer tell healthy pregnant women to rest "
        "all day. Regular, gentle movement is now part of good antenatal "
        "care. If your doctor has said your pregnancy needs extra care, read "
        "'When your doctor may say not to exercise' first."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Many of us grew up hearing that a pregnant woman should sit, "
              "rest and let others do the work. That advice comes from love. "
              "Today, doctors see it differently."),
        ],
        mythFact: PvMythFact(
          myth: _en("Exercise in pregnancy can harm the baby or bring on a "
              "miscarriage."),
          fact: _en("In a healthy pregnancy, moderate exercise doesn't cause "
              "miscarriage, early labour or harm to the baby. Most early "
              "losses happen because of a problem with the baby's "
              "chromosomes, not because of anything the mother did."),
        ),
      ),
      PvReadSection(
        heading: _en('What does exercise do for you and your baby?'),
        paragraphs: [
          _en("Staying active helps your body cope with the changes of "
              "pregnancy. It also gives you time that's only yours, and even "
              "ten minutes can lift a heavy day. In large groups of pregnant "
              "women, regular movement is linked to:"),
        ],
        bullets: [
          _en("Less back pain, less constipation and less swelling in the "
              "legs."),
          _en("Better sleep, a steadier mood, and less anxiety and low mood."),
          _en("Healthier weight gain."),
          _en("Lower rates of pregnancy diabetes (gestational diabetes) and "
              "of high blood pressure in pregnancy."),
          _en("More stamina for labour, and feeling like yourself sooner "
              "after the birth."),
        ],
      ),
      PvReadSection(
        heading: _en('How much, and how hard?'),
        paragraphs: [
          _en("The World Health Organization and doctors' groups give the "
              "same advice: about 150 minutes of moderate activity a week. "
              "That's 30 minutes on five days. You can split it up. Three "
              "brisk 10-minute walks count just as much as one long one."),
          _en("Moderate means your heart beats faster and you breathe a "
              "little harder, but you can still talk. This is the talk test. "
              "If you can chat in full sentences, you're at a good level. If "
              "you can't speak without gasping, slow down."),
          _en("Add some gentle muscle work two or three days a week: light "
              "weights, a resistance band, or moves like wall push-ups and "
              "standing up from a chair without using your hands."),
        ],
        tip: PvReadTip(
          title: _en('Housework counts'),
          body: _en("Sweeping, mopping, hanging washing and climbing the "
              "stairs at home all count as activity. Keep them at a "
              "comfortable pace, bend your knees to lift, and leave heavy "
              "buckets and ladders to someone else."),
        ),
      ),
      PvReadSection(
        heading: _en("What if I wasn't active before?"),
        paragraphs: [
          _en("That's fine, and pregnancy is a good time to start. Begin "
              "small: 10 to 15 minutes of walking or gentle movement, three "
              "days a week. Add a few minutes each week until you reach 30 "
              "minutes on most days."),
          _en("If you were already running, swimming, doing yoga or going to "
              "the gym, you can usually carry on at a similar level, with "
              "some changes as your bump grows. Tell your doctor what you "
              "do, and let them guide you. This isn't the time to train for "
              "a race or chase a personal best."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I keep it safe?'),
        bullets: [
          _en("Warm up for five minutes, and cool down for five."),
          _en("Drink water before, during and after. Carry a bottle."),
          _en("In Indian summers, move early in the morning or after sunset, "
              "in the shade or indoors with a fan. Skip hot yoga, and don't "
              "exercise in hot, humid heat."),
          _en("Eat a small snack an hour or so before, like a banana, a "
              "handful of nuts, or a roti with a little peanut butter. Your "
              "blood sugar can dip faster in pregnancy."),
          _en("Wear loose cotton clothes, a supportive bra, and shoes with a "
              "good grip."),
          _en("From the middle of pregnancy, don't lie flat on your back for "
              "long while you exercise. Prop yourself up, or lie on your "
              "side."),
          _en("Stop if something hurts. Don't push through dizziness or "
              "breathlessness."),
        ],
      ),
      PvReadSection(
        heading: _en('What kinds of exercise suit pregnancy?'),
        paragraphs: [
          _en("The best exercise is one you enjoy and can keep up. These are "
              "good choices for most women:"),
        ],
        bullets: [
          _en("Brisk walking, on flat ground or a treadmill."),
          _en("Swimming and water exercise, which take the weight off your "
              "joints."),
          _en("A stationary bike."),
          _en("Prenatal yoga and gentle stretching."),
          _en("Low-impact aerobics, or a dance class for pregnant women."),
          _en("Light strength work with bands or light weights."),
        ],
      ),
      PvReadSection(
        heading: _en('Where do I go from here?'),
        paragraphs: [
          _en("The other reads on this tab go through each trimester, "
              "walking and yoga, the things to leave out, and the signs that "
              "mean stop. If you like to follow along, our pregnancy yoga "
              "classes are grouped by month, so you can start with the one "
              "for where you are now."),
          _en("Before you start anything new, mention it at your next "
              "antenatal visit. Your doctor knows your pregnancy and can "
              "tell you if anything should change for you."),
        ],
      ),
    ],
    whenToSeeSomeone: _stopNow,
    faqs: [
      PvReadFaq(
        question: _en('Can I lift weights?'),
        answer: _en("If you lifted before pregnancy, you can usually carry on "
            "with lighter weights and more repetitions. Breathe out as you "
            "lift, and don't hold your breath. If you're new to it, start "
            "with light bands and learn the moves from a trained instructor."),
      ),
      PvReadFaq(
        question: _en('Will exercise take nourishment away from my baby?'),
        answer: _en("No. In a healthy pregnancy, your baby keeps getting what "
            "they need while you move. Eating well and drinking enough water "
            "is what matters."),
      ),
      PvReadFaq(
        question: _en("Is it okay to have days when I don't move at all?"),
        answer: _en("Yes. Some days you'll be too tired or sick. Rest then, "
            "and pick up again when you feel better."),
      ),
      PvReadFaq(
        question: _en("My mother-in-law says squatting to mop will make the "
            "birth easier. Is that true?"),
        answer: _en("Squatting to clean is fine if it feels comfortable. "
            "Nothing guarantees a normal birth, but staying active does help "
            "your body cope with labour."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 804, Physical activity and exercise '
        'during pregnancy and the postpartum period (2020) · WHO guidelines '
        'on physical activity and sedentary behaviour (2020) · UK Chief '
        "Medical Officers' physical activity guidance for pregnant women "
        '(2019).'),
    readNext: [
      'preg_move_read_when_to_stop',
      'preg_move_read_walking',
      'preg_move_read_when_not',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  First trimester
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_first_trimester',
    hue: _hue,
    kicker: _kMove,
    title: _en('Moving in the first three months'),
    teaser: _en("What to do when you're tired and sick, what helps nausea, and "
        "why gentle is enough for now."),
    shortAnswer: _en("In the first three months, gentle movement is safe and "
        "can ease tiredness and nausea. On good days, walk or do a light "
        "yoga session. On bad days, rest. Keep cool, drink water, and don't "
        "start anything new and hard."),
    scaleSetter: _en("Many women feel too tired or sick to exercise in the "
        "early weeks. That's normal, and for most it eases in the second "
        "trimester. Nothing you do or don't do in the gym now decides how "
        "your pregnancy goes."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The first trimester runs from the start of your pregnancy to the "
            "end of week 13. You may not look pregnant yet, but your body is "
            "working very hard. Your blood volume is rising, your hormones "
            "are changing, and building the placenta takes a lot of energy."),
        _en("So if climbing the stairs feels like a mountain some days, "
            "you're not unfit. You're pregnant."),
      ]),
      PvReadSection(
        heading: _en('Is it safe to exercise this early?'),
        paragraphs: [
          _en("Yes, for most women. Moderate exercise in early pregnancy "
              "doesn't cause miscarriage. Most early losses happen because "
              "the baby's chromosomes didn't form as they should, and "
              "nothing the mother did caused them."),
          _en("If you've had bleeding, a previous miscarriage, or you're "
              "pregnant after IVF, ask your doctor what's right for you. Many "
              "will still say gentle walking is fine."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps on a tired day?'),
        paragraphs: [
          _en("Tiredness in the early weeks can feel heavy. A little movement "
              "often helps more than you'd expect. A 10-minute walk in fresh "
              "air, some slow stretches or a short breathing practice can "
              "lift your energy for a while."),
        ],
        bullets: [
          _en("Move at the time of day you feel best. For many women that's "
              "mid-morning or early evening."),
          _en("Keep sessions short. Two short walks beat one long one you "
              "dread."),
          _en("Rest without guilt. Lie down after work, nap at the weekend, "
              "and let others help at home."),
        ],
      ),
      PvReadSection(
        heading: _en('Can movement help with nausea?'),
        paragraphs: [
          _en("It can. Some women find a slow walk outside settles a queasy "
              "stomach, especially in fresh air away from cooking smells. "
              "Gentle, low movements are easier than bending and twisting."),
        ],
        bullets: [
          _en("Eat a little something first, like a dry biscuit or a handful "
              "of puffed rice (murmura)."),
          _en("Sip water or lemon water through the session."),
          _en("Avoid moving in the heat, which can make nausea worse."),
          _en("If you're vomiting often or can't keep water down, don't "
              "exercise. Call your doctor."),
        ],
        tip: PvReadTip(
          title: _en('On sick days, rest counts'),
          body: _en("If the nausea is bad, lie on your side, breathe slowly, "
              "and try again tomorrow. One missed day, or one missed week, "
              "changes nothing."),
        ),
      ),
      PvReadSection(
        heading: _en('What should I be careful about now?'),
        bullets: [
          _en("Overheating. A high body temperature early in pregnancy is best "
              "avoided, so skip hot yoga, saunas and exercise in hot, humid "
              "heat."),
          _en("Starting something new and hard. This isn't the time to take "
              "up running or a boot camp. Build on what you already do."),
          _en("Contact sports, and anything where a fall is likely, like "
              "horse riding or cycling on busy roads."),
          _en("Feeling faint. Blood pressure dips in early pregnancy, so "
              "stand up slowly and don't skip meals before you exercise."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I wear, eat and drink?'),
        bullets: [
          _en("Your breasts may be sore and growing. A soft, supportive sports "
              "bra helps, and you may need a bigger size every few months."),
          _en("Loose cotton clothes let your skin breathe in the heat. A "
              "kurta with leggings is fine for a walk."),
          _en("Shoes with a good grip and some cushioning, not chappals."),
          _en("A small snack 30 to 60 minutes before, like a banana, a few "
              "dates or a slice of toast. An empty stomach can make nausea "
              "worse."),
          _en("Water before, during and after. Sip slowly if you feel "
              "queasy."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I used to work out hard?'),
        paragraphs: [
          _en("If you were running, lifting or doing hard classes before "
              "pregnancy, you can usually keep going, a little easier. Tell "
              "your trainer you're pregnant, even if you're not telling "
              "others yet."),
          _en("Drop anything that makes you very hot, breathless or dizzy, "
              "and stop chasing new records. Your fitness will still be there "
              "after the birth, and you'll build it back."),
        ],
      ),
      PvReadSection(
        heading: _en('What does a gentle week look like?'),
        paragraphs: [
          _en("Here's one idea. Change it to suit your body and your day."),
        ],
        bullets: [
          _en("Three or four days: a 15 to 20 minute walk."),
          _en("One or two days: a short prenatal yoga session, like "
              "'Settling-in gentle flow' or 'Ease for nausea days' in our "
              "pregnancy yoga classes."),
          _en("Every day: a few rounds of pelvic floor exercises (kegels), "
              "which take two minutes."),
          _en("Rest on any day you need it."),
        ],
      ),
    ],
    whenToSeeSomeone: _stopNow,
    faqs: [
      PvReadFaq(
        question: _en("I'm spotting a little. Can I still exercise?"),
        answer: _en("Stop, rest and call your doctor. Many women spot early on "
            "and go on to have a healthy pregnancy, but your doctor should "
            "know, and can tell you when to start again."),
      ),
      PvReadFaq(
        question: _en('I ran before I got pregnant. Can I keep running?'),
        answer: _en("Usually, yes, at an easier pace, if your doctor agrees. "
            "Use the talk test, stay cool, and stop if anything hurts."),
      ),
      PvReadFaq(
        question: _en('Should I stop going to the gym until my first scan?'),
        answer: _en("Not if you feel well and your doctor is happy. Carry on "
            "gently, avoid overheating and heavy straining, and keep to the "
            "talk test."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 804 (2020) · WHO guidelines on '
        'physical activity and sedentary behaviour (2020) · NHS guidance: '
        'Exercise in pregnancy.'),
    readNext: [
      'preg_move_read_second_trimester',
      'preg_move_read_is_it_safe',
      'preg_move_read_tiredness',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Second trimester
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_second_trimester',
    hue: _hue,
    kicker: _kMove,
    title: _en('Moving in the middle three months'),
    teaser: _en("Your energy often comes back now. How to use it, and what to "
        "change as your bump grows."),
    shortAnswer: _en("From 14 to 27 weeks, many women feel well enough to move "
        "more. Walking, swimming, yoga and light strength work are all good "
        "choices. As your bump grows, avoid lying flat on your back for "
        "long, take care with your balance, and leave out moves that crunch "
        "your belly."),
    scaleSetter: _en("This is often the easiest stretch of pregnancy for "
        "exercise. Most changes you'll make are small, for comfort and "
        "balance, not because moving has become unsafe."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The second trimester runs from week 14 to the end of week 27. "
            "For many women the nausea fades, the tiredness lifts, and the "
            "bump isn't heavy yet. It's a good time to build a habit you can "
            "keep till the end."),
        _en("If you still feel sick or drained, that's normal too. Go at "
            "your own pace."),
      ]),
      PvReadSection(
        heading: _en("What's changing in my body?"),
        bullets: [
          _en("Your bump grows forward, so your balance shifts and your lower "
              "back curves more."),
          _en("A hormone called relaxin loosens your ligaments to make room "
              "for birth. Joints can feel looser, so it's easier to "
              "over-stretch."),
          _en("Your heart pumps more blood, and your resting heart rate goes "
              "up."),
          _en("Your belly muscles stretch, and may start to move apart down "
              "the middle."),
        ],
        paragraphs: [
          _en("Your body changes a lot in these weeks. None of it means stop. "
              "It means move with a little more care."),
        ],
      ),
      PvReadSection(
        heading: _en('What exercise is good now?'),
        paragraphs: [
          _en("Keep to about 150 minutes a week and the talk test. Good "
              "choices now:"),
        ],
        bullets: [
          _en("Brisk walking, the easiest to fit into a busy day."),
          _en("Swimming, which many women love as the bump grows."),
          _en("Prenatal yoga, for posture, back care and breathing."),
          _en("Light strength work: squats down to a chair, wall push-ups, "
              "leg lifts lying on your side, and rows with a band."),
          _en("A stationary bike, which is safer than cycling on the road now "
              "that your balance is changing."),
        ],
      ),
      PvReadSection(
        heading: _en("Why shouldn't I lie on my back?"),
        paragraphs: [
          _en("When you lie flat on your back, the weight of your womb can "
              "press on a large vein that carries blood back to your heart. "
              "Some women feel dizzy, sick or short of breath. From the middle "
              "of pregnancy, around 20 weeks, it's best not to lie flat on "
              "your back for long."),
          _en("A minute or two won't hurt. Just change the moves that keep "
              "you on your back for a long stretch:"),
        ],
        bullets: [
          _en("Prop yourself up on pillows or a wedge, so you're half "
              "sitting."),
          _en("Lie on your side, with a pillow between your knees."),
          _en("Do floor exercises on your hands and knees instead."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I protect my balance and joints?'),
        bullets: [
          _en("Avoid jumping and sudden changes of direction."),
          _en("Use a wall or a chair for balance in standing poses."),
          _en("Stretch gently. Stop at a comfortable stretch, not your "
              "furthest one."),
          _en("Wear shoes with a good grip, and take care on wet bathroom "
              "floors and uneven roads."),
          _en("Leave out sit-ups, crunches and front planks, especially if "
              "you see a ridge bulging down the middle of your belly. 'Belly "
              "muscles separating' on this tab explains why."),
        ],
      ),
      PvReadSection(
        heading: _en('What does a week look like now?'),
        paragraphs: [
          _en("Here's one way to put it together. Swap days around to fit "
              "your work and home."),
        ],
        bullets: [
          _en("Three to five days: a 30-minute brisk walk, or a swim."),
          _en("Two days: 15 to 20 minutes of light strength work, like squats "
              "to a chair, wall push-ups, side-lying leg lifts and band rows, "
              "10 to 12 of each."),
          _en("One or two days: a prenatal yoga session, like 'Posture & "
              "alignment' or 'Back-care essentials' in our classes."),
          _en("Every day: your pelvic floor exercises."),
          _en("At least one full day of rest."),
        ],
      ),
      PvReadSection(
        heading: _en('What about my back and pelvis?'),
        paragraphs: [
          _en("Back and pelvic aches often start now, and movement usually "
              "helps. Try cat and cow on your hands and knees, gentle pelvic "
              "tilts, and swimming. Stand tall, sit with your back supported, "
              "and roll onto your side to get up from lying down."),
          _en("If you have sharp pain at the front of your pelvis, or in your "
              "hips or buttocks when you walk, climb stairs or turn in bed, "
              "it may be pelvic girdle pain. Tell your doctor. A "
              "physiotherapist can help, and some exercises are better left "
              "out for a while."),
        ],
        tip: PvReadTip(
          title: _en('Try it with support'),
          body: _en("If a move feels wobbly, do it holding the kitchen counter "
              "or the back of a sturdy chair. On long walks, a dupatta tied "
              "snugly under your bump can give it a little lift."),
        ),
      ),
    ],
    whenToSeeSomeone: _stopNow,
    faqs: [
      PvReadFaq(
        question: _en('Can I still swim?'),
        answer: _en("Yes. Swimming is one of the best exercises in pregnancy. "
            "Choose a clean pool, walk carefully on wet tiles, and don't dive "
            "or jump in."),
      ),
      PvReadFaq(
        question: _en('My heart beats faster than before when I exercise. Is '
            'that normal?'),
        answer: _en("Yes. Your resting heart rate rises in pregnancy, so it "
            "can feel faster. Use the talk test instead of a heart rate "
            "number. If your heart pounds when you're resting, or you feel "
            "faint or have chest pain, stop and call your doctor."),
      ),
      PvReadFaq(
        question: _en('Can I do exercises for my stomach?'),
        answer: _en("Gentle ones, yes: deep belly breathing, pelvic tilts, and "
            "moves on your hands and knees or your side. Leave out crunches "
            "and sit-ups, and stop any move that makes your belly dome into "
            "a ridge."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 804 (2020) · WHO guidelines on '
        'physical activity and sedentary behaviour (2020) · RCOG patient '
        'information: Pelvic girdle pain and pregnancy.'),
    readNext: [
      'preg_move_read_third_trimester',
      'preg_move_read_yoga',
      'preg_move_read_diastasis',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Third trimester
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_third_trimester',
    hue: _hue,
    kicker: _kMove,
    title: _en('Moving in the last three months'),
    teaser: _en("Slower, shorter and softer. How to stay active as your bump "
        "gets heavy, and gentle moves that help you get ready for birth."),
    shortAnswer: _en("From 28 weeks, keep moving gently if your doctor is "
        "happy: walking, swimming, prenatal yoga and birth ball work are all "
        "good. Go slower, rest more, and don't lie flat on your back. Stop "
        "and call your doctor if you have bleeding, fluid leaking, regular "
        "tightenings, or your baby moves less."),
    scaleSetter: _en("Most women need to slow down in the last months, and "
        "that's expected. Staying gently active until the birth is still "
        "good for you, even if 'active' now means a slow evening walk and a "
        "few stretches."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The third trimester runs from week 28 until your baby is born. "
            "Your bump is heavier, your breath is shorter, and your balance "
            "has moved forward. Everyday things, like getting out of bed, "
            "take more effort."),
        _en("Moving still helps. It can ease back ache, swelling and "
            "constipation, help you sleep, and keep your body strong for "
            "labour."),
        _en("Many women in India move to their mother's home for the last "
            "months. If you do, find a quiet, even route for walks there "
            "early on, and save the new hospital's number in your phone."),
      ]),
      PvReadSection(
        heading: _en('How should I change what I do?'),
        bullets: [
          _en("Shorten sessions and slow down. Two 15-minute walks may suit "
              "you better than one of 30."),
          _en("Use the talk test. You'll get breathless sooner now, so ease "
              "off earlier."),
          _en("Choose low-impact moves: walking, swimming, a stationary bike, "
              "prenatal yoga."),
          _en("Do floor work on your side or on your hands and knees, not "
              "flat on your back."),
          _en("Leave out jumping, and anything that needs quick balance."),
          _en("Rest when you need to, without guilt."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I get my body ready for birth?'),
        paragraphs: [
          _en("Some gentle moves can help you feel more open and comfortable, "
              "and let you practise positions you may use in labour. They "
              "won't decide how your birth goes, but many women find them "
              "soothing."),
        ],
        bullets: [
          _en("Hip circles on a birth ball. Sit on a large exercise ball with "
              "your feet wide and flat, and slowly circle your hips. Keep a "
              "wall or a person beside you."),
          _en("Supported squats. Hold the back of a chair or a window grille, "
              "lower slowly as far as is comfortable, and come back up. Skip "
              "them if they hurt your pelvis."),
          _en("Cat and cow on your hands and knees, which eases back ache and "
              "takes the weight of your bump off your spine."),
          _en("Kneeling and leaning forward over a pile of cushions or a "
              "birth ball, gently swaying your hips."),
          _en("Slow belly breathing, in through your nose and out through "
              "your mouth, which you can use in labour."),
        ],
        tip: PvReadTip(
          title: _en('Our classes help here'),
          body: _en("The sessions for months 7 to 9 in our pregnancy yoga "
              "classes, like 'Third-trimester hip release' and 'Pelvic-floor "
              "& birth prep', are made for this stage."),
        ),
      ),
      PvReadSection(
        heading: _en('Is walking still good in the last weeks?'),
        paragraphs: [
          _en("Yes. Walking is still one of the best things you can do. Walk "
              "on flat ground, wear shoes with a good grip, and take your "
              "phone and some water. A slow walk after dinner, round the "
              "colony or on the terrace, helps digestion and sleep."),
          _en("Many families say lots of walking brings labour on. There's no "
              "good evidence that it starts labour, but it keeps you "
              "comfortable and strong, and it's safe to carry on."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps with swelling and aches?'),
        bullets: [
          _en("Swollen feet: circle your ankles, put your feet up, and avoid "
              "standing still for long."),
          _en("Back ache: try cat and cow, a warm (not hot) compress, and "
              "sleeping on your side with a pillow between your knees."),
          _en("Leg cramps: stretch your calves before bed by pulling your "
              "toes towards you."),
          _en("Pelvic ache: take smaller steps, keep your knees together "
              "when you get in and out of a car or bed, and take the stairs "
              "one at a time."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en('Sudden swelling is different'),
          body: _en("Sudden swelling of your face, hands or feet, especially "
              "with a headache or blurred vision, can be a sign of high blood "
              "pressure in pregnancy. Call your doctor straight away."),
        ),
      ),
      PvReadSection(
        heading: _en('When should I ease off completely?'),
        paragraphs: [
          _en("Your doctor may ask you to stop exercising if your blood "
              "pressure rises, your baby isn't growing as expected, you've had "
              "bleeding, your placenta is low, or labour may start early. "
              "Follow their plan. You can still do gentle breathing and "
              "relaxation."),
          _en("Near your due date, stop if you have any sign of labour, like "
              "regular tightenings, your waters breaking, or a show with "
              "blood in it. The Labour prep door explains what to do next."),
        ],
      ),
    ],
    whenToSeeSomeone: _stopNow,
    faqs: [
      PvReadFaq(
        question: _en('Is it safe to climb stairs in the ninth month?'),
        answer: _en("Yes, if you feel steady. Hold the railing, take one step "
            "at a time, and don't carry heavy things up."),
      ),
      PvReadFaq(
        question: _en('Can a birth ball turn a breech baby?'),
        answer: _en("There's no good evidence that it can. If your baby is "
            "breech near your due date, your doctor will talk to you about "
            "the options."),
      ),
      PvReadFaq(
        question: _en('Should I walk more to bring on labour after my due '
            'date?'),
        answer: _en("Walking is safe and good for you, but it isn't a proven "
            "way to start labour. Your doctor will talk to you about what "
            "happens if you go past your due date."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 804 (2020) · WHO guidelines on '
        'physical activity and sedentary behaviour (2020) · NICE guideline '
        'NG201, Antenatal care (2021).'),
    readNext: [
      'preg_move_read_walking',
      'preg_move_read_perineal_massage',
      'preg_move_read_side_sleeping',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Walking
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_walking',
    hue: _hue,
    kicker: _kMove,
    title: _en('Walking: the easiest exercise in pregnancy'),
    teaser: _en("Why walking suits almost every pregnancy, how far and how "
        "fast to go, and how to stay safe in Indian weather and on Indian "
        "roads."),
    shortAnswer: _en("Walking is safe for almost every pregnancy and needs no "
        "equipment. Walk briskly enough that you can talk but not sing, and "
        "build up to about 30 minutes on most days. Split it into short "
        "walks if you like, and walk in the cool part of the day."),
    scaleSetter: _en("If you do only one kind of exercise in pregnancy, "
        "walking is a very good choice. It's gentle on your joints, you can "
        "do it from your first week to your last, and you can stop whenever "
        "you want."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Walking needs no class, no gym and no special kit. You can walk "
            "round your building, on the terrace, in a park, or up and down a "
            "long corridor at home. Many Indian families already take a walk "
            "after dinner, and that counts."),
      ]),
      PvReadSection(
        heading: _en('Why is walking so good for you now?'),
        bullets: [
          _en("It gets your heart and lungs working without jolting your "
              "joints."),
          _en("It helps digestion, eases constipation, and can settle "
              "heartburn after meals."),
          _en("A walk after a meal helps keep your blood sugar steadier, "
              "which matters if you have pregnancy diabetes."),
          _en("Daylight and fresh air help your mood and your sleep."),
          _en("It keeps your legs strong for the end of pregnancy and for "
              "labour."),
        ],
      ),
      PvReadSection(
        heading: _en('How long, and how fast?'),
        paragraphs: [
          _en("Aim for about 30 minutes on five days a week. If you're "
              "starting from nothing, begin with 10 minutes and add 5 minutes "
              "each week."),
          _en("Walk fast enough that you're a little out of breath but can "
              "still talk. That's the talk test. In the last months, slow "
              "down as you need to. A gentle stroll still counts."),
          _en("Three 10-minute walks, after breakfast, lunch and dinner, count "
              "just as much as one long walk."),
        ],
        tip: PvReadTip(
          title: _en('Counting steps?'),
          body: _en("You don't need a step count. If you like one, notice what "
              "you do on a normal day and add to it slowly. There's no set "
              "number you have to reach in pregnancy."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I walk safely?'),
        bullets: [
          _en("In summer, walk early in the morning or after sunset. Avoid "
              "the midday heat, and carry water."),
          _en("In the monsoon, walk indoors or on a covered terrace. Wet "
              "roads, open drains and mossy steps are easy to slip on."),
          _en("Choose flat, even paths. Broken pavements and potholes are "
              "harder to see over a bump."),
          _en("Wear shoes with a good grip. Loose chappals and slippers "
              "aren't safe for long walks."),
          _en("Wear loose cotton clothes and a supportive bra."),
          _en("In winter, check the air quality (AQI). On smoggy days, walk "
              "indoors, in a mall or up and down your building."),
          _en("Take your phone, and tell someone where you're going if you "
              "walk alone in the last months."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I make walking a habit?'),
        bullets: [
          _en("Walk with someone: your husband after dinner, a neighbour in "
              "the morning, or your mother on a phone call."),
          _en("Pick a route and a time, and treat it like an appointment."),
          _en("Break it up. A few minutes after each meal adds up."),
          _en("For short trips to the shop, the temple or the vegetable "
              "market, walk instead of taking the car, if the road is safe."),
          _en("On days you can't go out, walk up and down inside while you "
              "talk on the phone or listen to music."),
        ],
        tip: PvReadTip(
          title: _en('In festival season'),
          body: _en("Long days of cooking, shopping and standing can wear you "
              "out. All that bustle counts as activity. Keep a short, slow "
              "walk if it helps you unwind, and sit down whenever you can."),
        ),
      ),
      PvReadSection(
        heading: _en('Can I walk if I have a complication?'),
        paragraphs: [
          _en("Often, yes. Walking is the exercise doctors are most likely to "
              "allow when a pregnancy needs extra care, such as with "
              "pregnancy diabetes or twins. But if you have a low-lying "
              "placenta with bleeding, signs of early labour or high blood "
              "pressure, or your doctor has asked you to rest, ask what's "
              "safe before you walk for exercise."),
          _en("Walking round the house for everyday things is different from "
              "walking for exercise. If you're unsure which your doctor "
              "meant, ask."),
        ],
      ),
      PvReadSection(
        heading: _en('What if walking hurts?'),
        paragraphs: [
          _en("Some aches are common: a tired back, a pulling feeling at the "
              "sides of your bump (round ligament pain), or sore feet. Slow "
              "down, take smaller steps, and rest. A support belt, or a "
              "dupatta tied snugly under your bump, can help on longer "
              "walks."),
          _en("Pain at the front of your pelvis or in your hips when you walk "
              "may be pelvic girdle pain. Tell your doctor, and ask to see a "
              "physiotherapist."),
        ],
      ),
    ],
    whenToSeeSomeone: _stopNow,
    faqs: [
      PvReadFaq(
        question: _en('Is it safe to walk on a treadmill?'),
        answer: _en("Yes. Keep it flat or on a gentle slope, hold the rails if "
            "you feel unsteady, and don't go faster than you can talk."),
      ),
      PvReadFaq(
        question: _en('Will walking a lot bring on labour?'),
        answer: _en("There's no good evidence that walking starts labour. It's "
            "safe to keep walking up to your due date if you feel well."),
      ),
      PvReadFaq(
        question: _en('Can I walk during a festival fast, like Navratri?'),
        answer: _en("Keep walks short and gentle on fasting days, walk after "
            "you've eaten and had water, and skip them on hot days. Talk to "
            "your doctor before any long fast in pregnancy."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 804 (2020) · WHO guidelines on '
        'physical activity and sedentary behaviour (2020) · UK Chief Medical '
        "Officers' physical activity guidance for pregnant women (2019)."),
    readNext: [
      'preg_move_read_is_it_safe',
      'preg_move_read_third_trimester',
      'preg_move_read_cant_sleep',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Prenatal yoga
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_yoga',
    hue: _hue,
    kicker: _kMove,
    title: _en("Prenatal yoga: what's safe and what to skip"),
    teaser: _en("What yoga can do for you in pregnancy, which poses to change, "
        "and what to leave until after the birth."),
    shortAnswer: _en("Prenatal yoga is safe for most women and can help with "
        "back ache, sleep, breathing and stress. Choose a class made for "
        "pregnancy. Skip hot yoga, don't lie flat on your back for long "
        "after about 20 weeks, and if you're new to yoga, leave out deep "
        "twists and upside-down poses."),
    scaleSetter: _en("Yoga is one of the gentlest ways to stay active in "
        "pregnancy. Most changes are small: softer twists, more props, and "
        "less time on your back."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Yoga has been part of Indian homes for a long time, and many "
            "women are drawn to it in pregnancy. Prenatal yoga is yoga "
            "changed for a pregnant body, with slower moves, more support, "
            "and a lot of breathing."),
        _en("You don't need to be flexible, and you don't need to have done "
            "yoga before."),
      ]),
      PvReadSection(
        heading: _en('How can yoga help in pregnancy?'),
        paragraphs: [
          _en("It won't replace your antenatal checks, and no pose decides "
              "how your birth goes. But it helps in these ways:"),
        ],
        bullets: [
          _en("It eases back ache, stiff hips and tight shoulders."),
          _en("It can help you sleep, and calm your mind on anxious days."),
          _en("It keeps your balance steadier as your bump grows."),
          _en("It teaches breathing you can use in labour."),
          _en("It builds gentle strength in your legs and pelvic floor."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I skip or change?'),
        bullets: [
          _en("Hot yoga and hot rooms. Overheating is best avoided in "
              "pregnancy."),
          _en("Lying flat on your back for long after about 20 weeks. Use a "
              "wedge or pillows, or lie on your side."),
          _en("Deep twists from the belly. Twist gently from your upper back "
              "and shoulders instead, opening away from your bump rather "
              "than squeezing across it."),
          _en("Upside-down poses (inversions) like headstands and shoulder "
              "stands, if you're new to them. Even women with years of "
              "practice usually stop, and should check with their teacher "
              "and doctor."),
          _en("Deep backbends, and poses lying on your belly."),
          _en("Over-stretching. Your joints are looser now, so stop at a "
              "comfortable stretch."),
          _en("Holding your breath, and fast, forceful breathing like "
              "kapalbhati and bhastrika."),
          _en("Jumping between poses."),
        ],
      ),
      PvReadSection(
        heading: _en('Which poses tend to feel good?'),
        bullets: [
          _en("Cat and cow on your hands and knees, for your back."),
          _en("Child's pose with your knees wide, to make room for your bump."),
          _en("Butterfly (baddha konasana), sitting up against a wall, for "
              "your hips."),
          _en("A supported squat (malasana), with a block or cushion under "
              "you."),
          _en("Side-lying relaxation, with a pillow between your knees."),
          _en("Gentle standing poses near a wall, like a supported warrior."),
        ],
        paragraphs: [
          _en("Use props freely. A folded blanket, cushions, a chair or the "
              "wall all make poses safer and more comfortable. There's no "
              "prize for doing a pose without support, and a prop often "
              "lets you stay longer and breathe more easily."),
        ],
      ),
      PvReadSection(
        heading: _en('What does a gentle session look like?'),
        paragraphs: [
          _en("Here's a short home practice of about 15 minutes. Leave out "
              "anything that doesn't feel right on the day."),
        ],
        bullets: [
          _en("Sit tall on a cushion and breathe slowly for two minutes."),
          _en("Roll your neck and shoulders gently, a few times each way."),
          _en("Cat and cow on your hands and knees, for eight slow rounds."),
          _en("Child's pose with your knees wide, for five slow breaths."),
          _en("Standing side stretches with your feet apart, holding a chair "
              "if you need to."),
          _en("Butterfly against a wall, for a minute or two."),
          _en("Rest on your left or right side, with pillows, for three to "
              "five minutes."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I choose a class?'),
        bullets: [
          _en("Look for a class for pregnant women, or tell the teacher "
              "you're pregnant before you start."),
          _en("Ask if the teacher has trained in prenatal yoga."),
          _en("In a general class, be ready to rest in child's pose or on "
              "your side while others do poses you should skip."),
          _en("At home, choose sessions made for your stage of pregnancy. Our "
              "pregnancy yoga classes are grouped by month."),
        ],
        tip: PvReadTip(
          title: _en('Breathe slowly, never hold it'),
          body: _en("Slow breathing, with the out-breath a little longer than "
              "the in-breath, is safe all through pregnancy and helps you "
              "relax. Save strong breathing exercises for after the birth."),
        ),
      ),
      PvReadSection(
        heading: _en('When should I stop a session?'),
        paragraphs: [
          _en("Stop and rest if you feel dizzy, sick, too hot or out of "
              "breath. Stop and call your doctor straight away if you have "
              "bleeding, fluid leaking, pain in your belly or chest, or "
              "regular tightenings."),
          _en("If you have a condition like a low-lying placenta, high blood "
              "pressure or a stitch in your cervix, ask your doctor which "
              "parts of yoga are safe for you. Breathing and relaxation "
              "usually are."),
        ],
      ),
    ],
    whenToSeeSomeone: _stopNow,
    faqs: [
      PvReadFaq(
        question: _en("I've never done yoga. Can I start in pregnancy?"),
        answer: _en("Yes. Start with a beginner prenatal class or short "
            "sessions at home, and go slowly. You don't have to touch your "
            "toes."),
      ),
      PvReadFaq(
        question: _en('Is it okay to do Surya Namaskar?'),
        answer: _en("Many teachers change it for pregnancy: fewer rounds, "
            "slower, and without the parts where you lie on your belly or "
            "bend far back. If you're new to it, learn the changed version "
            "from a prenatal teacher. In the last months, most women stop."),
      ),
      PvReadFaq(
        question: _en('Can yoga turn a breech baby?'),
        answer: _en("There's no good evidence that any pose turns a breech "
            "baby. If your baby is breech near your due date, your doctor "
            "will talk to you about the options."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 804 (2020) · WHO guidelines on '
        'physical activity and sedentary behaviour (2020) · NHS guidance: '
        'Exercise in pregnancy.'),
    readNext: [
      'preg_move_read_second_trimester',
      'preg_move_read_third_trimester',
      'preg_move_read_avoid',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  What to avoid
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_avoid',
    hue: _hue,
    kicker: _kMove,
    title: _en('What to avoid when you exercise in pregnancy'),
    teaser: _en("The sports and moves to leave out for now, and why each one "
        "is on the list."),
    shortAnswer: _en("Leave out contact sports, anything where a fall is "
        "likely, scuba diving, hot yoga, and very heavy lifting or "
        "straining. Don't get too hot, and don't lie flat on your back for "
        "long from the middle of pregnancy. Almost everything else can be "
        "done more gently."),
    scaleSetter: _en("The list of things to avoid is short. Most activities "
        "are fine with a few changes, and the reasons below are about a "
        "fall, a blow to the bump, heat or pressure, not about exercise "
        "itself."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Most of what you already enjoy can carry on in some form, with "
            "a few changes as your bump grows."),
        _en("You don't need to wrap yourself in cotton wool. But a few "
            "activities carry a real risk of harm in pregnancy, and it's "
            "best to leave them until after the birth."),
        _en("Here's the list, and the reason for each."),
      ]),
      PvReadSection(
        heading: _en('Which sports are best left out?'),
        bullets: [
          _en("Contact sports, like kabaddi, boxing, football, hockey and "
              "martial arts sparring. A blow to the bump can hurt the "
              "placenta."),
          _en("Sports where a fall is likely, like horse riding, skiing, "
              "skating, gymnastics, and cycling on busy roads or rough "
              "tracks."),
          _en("Fast racquet sports like squash, if you're not used to them. "
              "Quick turns are harder with a bump."),
          _en("Scuba diving. Your baby can't protect itself from the pressure "
              "changes and gas bubbles in the blood."),
          _en("Skydiving, bungee jumping and adventure rides."),
          _en("On holiday: river rafting, paragliding, zip lines, quad bikes "
              "and jet skis."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does heat matter?'),
        paragraphs: [
          _en("A body temperature that climbs too high is best avoided in "
              "pregnancy, especially in the first trimester. So:"),
        ],
        bullets: [
          _en("Skip hot yoga, hot Pilates, saunas and steam rooms."),
          _en("Don't exercise in the midday heat of an Indian summer. Go early "
              "or late, or move indoors with a fan or cooler."),
          _en("Drink water before, during and after."),
          _en("Stop if you feel very hot, flushed or dizzy, and cool down in "
              "the shade."),
        ],
      ),
      PvReadSection(
        heading: _en('Which moves should I change?'),
        bullets: [
          _en("Lying flat on your back for long, from the middle of "
              "pregnancy. Prop yourself up, or lie on your side."),
          _en("Heavy lifting and straining. Lift lighter, breathe out as you "
              "lift, and never hold your breath to push."),
          _en("Crunches, sit-ups and full planks once your bump shows, "
              "especially if your belly bulges into a ridge."),
          _en("Deep twists, deep backbends and upside-down poses, if you're "
              "new to them."),
          _en("Jumping, bouncing and sudden changes of direction."),
          _en("Hard exercise high in the hills, above about 1,800 metres "
              "(6,000 feet), unless you live there. Many hill stations are "
              "this high, so keep holiday walks slow and easy."),
        ],
      ),
      PvReadSection(
        heading: _en('What about lifting at home and at work?'),
        paragraphs: [
          _en("Everyday lifting is usually fine. Picking up a toddler or a bag "
              "of vegetables won't harm your baby. What matters is how you "
              "lift."),
        ],
        bullets: [
          _en("Bend your knees and keep your back straight."),
          _en("Hold the load close to your body."),
          _en("Don't twist while you lift."),
          _en("Split heavy shopping into two bags."),
          _en("Leave full water buckets, gas cylinders, heavy furniture, and "
              "climbing on stools or ladders to someone else."),
        ],
        tip: PvReadTip(
          title: _en('If your job is physical'),
          body: _en("If your work involves heavy lifting, standing for long "
              "hours or night shifts, talk to your doctor. They can suggest "
              "changes and write a note for your employer."),
        ),
      ),
      PvReadSection(
        heading: _en('What about the gym?'),
        bullets: [
          _en("Tell the trainer you're pregnant, and how many weeks."),
          _en("Machines where you sit with your back supported are easier "
              "than free weights later on."),
          _en("Avoid machines and moves that press on your belly."),
          _en("Skip the steam room and sauna after your session."),
          _en("Keep your own water bottle, and take breaks between sets."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I dance at a wedding or garba?'),
        paragraphs: [
          _en("Yes, for most women, if you keep it gentle. Avoid fast spins, "
              "jumping, and crowded circles where someone could bump into "
              "you. Take breaks, drink water, and sit down between songs. "
              "Late nights on your feet are tiring, so rest the next day."),
        ],
      ),
      PvReadSection(
        heading: _en("Can I keep doing something I'm used to?"),
        paragraphs: [
          _en("Sometimes. If you've run, lifted weights or played a sport for "
              "years, your doctor may let you carry on at a lower level. Tell "
              "them exactly what you do and how often."),
          _en("Contact sports, scuba diving, and activities where a fall is "
              "likely stay off the list for everyone, however fit you are."),
          _en("If you're not sure where something you love fits, ask your "
              "doctor at your next visit. Describe it plainly: how hard it "
              "is, how long you do it, and whether you could fall or be hit. "
              "That makes the answer much easier to give."),
        ],
      ),
    ],
    whenToSeeSomeone: _stopNow,
    faqs: [
      PvReadFaq(
        question: _en('Can I play badminton?'),
        answer: _en("If you played before, a gentle, friendly game is usually "
            "fine early on. Avoid lunging and quick turns, and stop as your "
            "bump grows and your balance changes."),
      ),
      PvReadFaq(
        question: _en('Is swimming in the sea safe?'),
        answer: _en("Calm, shallow water with a lifeguard nearby is usually "
            "fine. Avoid strong waves and currents, and don't dive in."),
      ),
      PvReadFaq(
        question: _en('I lifted something heavy before I knew I was pregnant. '
            'Could that have hurt the baby?'),
        answer: _en("It's very unlikely. Everyday lifting doesn't cause "
            "miscarriage. If you have pain or bleeding, call your doctor."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 804 (2020) · WHO guidelines on '
        'physical activity and sedentary behaviour (2020) · UK Chief Medical '
        "Officers' physical activity guidance for pregnant women (2019)."),
    readNext: [
      'preg_move_read_when_to_stop',
      'preg_move_read_when_not',
      'preg_move_read_diastasis',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  When to stop
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_when_to_stop',
    hue: _hue,
    kicker: _kMove,
    title: _en('When to stop exercising and call your doctor'),
    teaser: _en("The signs that mean stop now, and which ones need the "
        "hospital."),
    shortAnswer: _en("Stop straight away and call your doctor if you have "
        "bleeding, fluid leaking, dizziness, chest pain, breathlessness "
        "before you start, a bad headache, calf pain or swelling, regular "
        "painful tightenings, or your baby moving less. For chest pain, "
        "heavy bleeding or fainting, call 108 or go to hospital now."),
    scaleSetter: _en("These signs are uncommon, and most women never meet "
        "them. They're here so that if one ever happens, you'll know what to "
        "do without searching for it."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Some aches and breathlessness are normal when you exercise in "
            "pregnancy. What matters is knowing the difference between 'I "
            "need a rest' and 'I need a doctor'. This page is about the "
            "second."),
      ]),
      PvReadSection(
        heading: _en('Which signs mean stop and call?'),
        bullets: [
          _en("Bleeding from your vagina, even a little."),
          _en("Fluid leaking or gushing from your vagina."),
          _en("Regular, painful tightenings of your bump."),
          _en("Feeling dizzy or faint."),
          _en("Chest pain, or a racing or pounding heart that doesn't settle."),
          _en("Being breathless before you've started, or breathlessness "
              "that doesn't settle with rest."),
          _en("A bad headache."),
          _en("Pain or swelling in one calf."),
          _en("Muscle weakness that upsets your balance."),
          _en("Your baby moving less than usual."),
        ],
      ),
      PvReadSection(
        heading: _en('How quickly do I need help?'),
        paragraphs: [
          _en("With any of the signs above, stop exercising for the day and "
              "call your doctor straight away. Don't wait for your next "
              "visit."),
          _en("Go to hospital now, or call 108 for an ambulance, if you "
              "have:"),
        ],
        bullets: [
          _en("Chest pain, or sudden breathlessness."),
          _en("Heavy bleeding."),
          _en("Fainting."),
          _en("A severe headache with blurred vision, or sudden swelling of "
              "your face and hands."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do these signs matter?'),
        paragraphs: [
          _en("Each one can point to something your doctor should check. "
              "Bleeding or fluid can mean a problem with the placenta, or your "
              "waters leaking. Regular tightenings can be early labour. Pain "
              "and swelling in one calf can be a blood clot, which is more "
              "common in pregnancy."),
          _en("Chest pain and sudden breathlessness can come from the heart "
              "or lungs, or from a clot that has moved. A bad headache with "
              "blurred vision can be a sign of high blood pressure in "
              "pregnancy (pre-eclampsia)."),
          _en("Often the check is reassuring. But each of these is worth a "
              "check today, not a wait and see."),
          _en("You won't be wasting anyone's time. Labour wards and "
              "casualty doctors would much rather see you and send you home "
              "than have you sit at home unsure."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my baby moves less?'),
        paragraphs: [
          _en("You'll get to know your baby's own pattern of movements. After "
              "exercise, some babies go quiet for a while, and others get "
              "busier."),
          _en("If you think your baby is moving less than usual, don't wait "
              "to see if it picks up after a rest or a cold drink. Call your "
              "hospital straight away, day or night. They'll check your "
              "baby's heartbeat, and it's always right to call."),
          _en("Don't use a home heartbeat monitor to check. Hearing a "
              "heartbeat at home can give false comfort."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I feel unwell later, not during?'),
        paragraphs: [
          _en("Signs don't always come during a session. If bleeding, fluid, "
              "tightenings or calf pain start later the same day or the next "
              "morning, treat them the same way: stop exercising and call "
              "your doctor."),
          _en("A little care each time keeps most sessions comfortable:"),
        ],
        bullets: [
          _en("Warm up, and cool down slowly."),
          _en("Drink water, and don't exercise in the heat."),
          _en("Eat a small snack first."),
          _en("Keep to the talk test."),
          _en("Get up slowly from the floor, rolling onto your side first."),
        ],
      ),
      PvReadSection(
        heading: _en("What's normal when I exercise?"),
        bullets: [
          _en("Breathing harder, but still able to talk."),
          _en("Feeling warm and a little sweaty."),
          _en("Mild muscle ache the next day."),
          _en("A pulling feeling at the sides of your bump when you move "
              "quickly (round ligament pain), which eases when you slow "
              "down."),
          _en("A practice tightening now and then (Braxton Hicks) that fades "
              "when you rest. If they come regularly or hurt, stop and "
              "call."),
        ],
        tip: PvReadTip(
          title: _en('Slow down first'),
          body: _en("If you're more out of breath than usual, stop, sit down, "
              "sip water and breathe slowly. If you feel fine in a few "
              "minutes, carry on more gently, or finish for the day."),
        ),
      ),
      PvReadSection(
        heading: _en('What should I tell the doctor when I call?'),
        bullets: [
          _en("How many weeks pregnant you are."),
          _en("What happened, and when."),
          _en("What you were doing at the time."),
          _en("Whether it has stopped or is still going on."),
          _en("How your baby has been moving today."),
        ],
        tip: PvReadTip(
          title: _en('Keep the number handy'),
          body: _en("Keep your antenatal card or file close, and your "
              "hospital's number saved in your phone and on the fridge, so "
              "anyone at home can find it."),
        ),
      ),
    ],
    whenToSeeSomeone: _stopNow,
    faqs: [
      PvReadFaq(
        question: _en('I felt dizzy once on a walk and it passed. Do I need to '
            'call?'),
        answer: _en("Stop for the day and tell your doctor. Call straight "
            "away if it lasts, comes back, you fainted, or it came with any "
            "other sign on this page."),
      ),
      PvReadFaq(
        question: _en('Can exercise make my waters break?'),
        answer: _en("Not in a healthy pregnancy. But if fluid leaks during or "
            "after exercise, stop and call your doctor so they can check."),
      ),
      PvReadFaq(
        question: _en('When can I exercise again after one of these signs?'),
        answer: _en("Only once your doctor has checked you and says it's "
            "okay."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 804 (2020), warning signs to stop '
        'exercise · NICE guideline NG201, Antenatal care (2021) · RCOG '
        'Green-top Guideline 37a, Reducing the risk of venous thromboembolism '
        'during pregnancy and the puerperium (2015).'),
    readNext: [
      'preg_move_read_when_not',
      'preg_move_read_is_it_safe',
      'preg_move_read_avoid',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  When not to exercise
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_when_not',
    hue: _hue,
    kicker: _kMove,
    title: _en('When your doctor may say not to exercise'),
    teaser: _en("The conditions where exercise needs your doctor's plan "
        "first, and what you can still do."),
    shortAnswer: _en("Some pregnancies need a different plan. Your doctor may "
        "ask you not to exercise if you have a low-lying placenta after 26 "
        "weeks, a stitch in your cervix, early labour, broken waters, "
        "pre-eclampsia, severe anaemia, or some heart or lung conditions. "
        "Your own doctor knows your case, so follow their advice."),
    scaleSetter: _en("Most pregnant women can exercise. This page is for the "
        "few who've been told, or may be told, to hold back. If that's you, "
        "it isn't something you caused, and there's still plenty you can do "
        "to feel better."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Doctors check for a short list of conditions before they say "
            "exercise is fine. Some mean no exercise for now. Others mean "
            "gentler exercise, with your doctor keeping an eye on things."),
        _en("Some of these show up on a scan, some at a blood pressure or "
            "blood check, and some only as symptoms, which is why the advice "
            "can change from one visit to the next."),
        _en("Only your own doctor knows your case. This page explains the "
            "usual reasons, so the advice makes sense when you hear it."),
      ]),
      PvReadSection(
        heading: _en('When is exercise usually not advised?'),
        bullets: [
          _en("A low-lying placenta (placenta praevia) after 26 weeks."),
          _en("A weak cervix, or a stitch in your cervix (cerclage)."),
          _en("Labour starting early, before 37 weeks, in this pregnancy."),
          _en("Your waters have broken."),
          _en("Bleeding that keeps coming back in the second or third "
              "trimester."),
          _en("Pre-eclampsia, or high blood pressure that started in "
              "pregnancy."),
          _en("Twins or triplets, when your doctor is concerned labour may "
              "start early."),
          _en("Severe anaemia."),
          _en("Some heart and lung conditions."),
        ],
      ),
      PvReadSection(
        heading: _en('When might I need a gentler plan?'),
        paragraphs: [
          _en("These don't rule exercise out, but your doctor will want to "
              "plan it with you:"),
        ],
        bullets: [
          _en("Mild or moderate anaemia."),
          _en("Diabetes, thyroid problems or epilepsy that aren't well "
              "controlled."),
          _en("High blood pressure from before pregnancy that isn't well "
              "controlled."),
          _en("A baby who isn't growing as expected."),
          _en("Being very underweight, or having been inactive for a long "
              "time."),
          _en("Joint or back problems."),
          _en("A heartbeat problem that hasn't been checked."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do these conditions matter?'),
        paragraphs: [
          _en("A low placenta or a weak cervix can bleed or open early with "
              "strain. Pre-eclampsia raises blood pressure, and hard exercise "
              "pushes it up further for a while. With severe anaemia, your "
              "heart is already working hard to carry oxygen, so exercise can "
              "leave you breathless and faint."),
          _en("With broken waters or early labour, the aim is to keep your "
              "baby safely inside for as long as your doctor advises. In each "
              "case, holding back for now protects you and your baby."),
        ],
      ),
      PvReadSection(
        heading: _en('What about pregnancy diabetes?'),
        paragraphs: [
          _en("Pregnancy diabetes (gestational diabetes) is different. "
              "Doctors often encourage walking with it, because moving after "
              "meals helps bring blood sugar down. Ask your doctor or "
              "dietitian how much is right for you."),
          _en("A 10 to 15 minute walk after each main meal is a common "
              "suggestion. If you take insulin, carry a sweet snack or "
              "glucose tablets on your walk, and check your sugar as your "
              "doctor has shown you. Stop and eat something if you feel "
              "shaky, sweaty or light-headed."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I still do?'),
        paragraphs: [
          _en("Even if you've been asked not to exercise, you may be able "
              "to:"),
        ],
        bullets: [
          _en("Do slow breathing and relaxation."),
          _en("Do gentle stretches for your neck, shoulders and ankles, "
              "sitting or lying on your side."),
          _en("Circle your ankles and flex your feet often, to help the blood "
              "flow in your legs."),
          _en("Do pelvic floor exercises, if your doctor agrees."),
          _en("Walk round the house for everyday things, unless you've been "
              "told to rest."),
        ],
        tip: PvReadTip(
          title: _en('Ask what "rest" means'),
          body: _en("Ask your doctor exactly what they mean: no exercise, no "
              "lifting, no sex, or lying down most of the day. Write their "
              "answer in your antenatal file, so everyone at home hears the "
              "same plan."),
        ),
      ),
      PvReadSection(
        heading: _en('Will I be able to exercise again?'),
        paragraphs: [
          _en("Often, yes. Some conditions settle: a low placenta may move "
              "up, anaemia gets better with treatment, and blood pressure can "
              "come under control. Your doctor will tell you when it's safe "
              "to start again, and how much."),
          _en("Being told to hold back can feel frustrating, or frightening. "
              "Both feelings are normal. If it's weighing on you, tell your "
              "doctor, or open the Mind & mood door."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my family says one thing and my doctor another?'),
        paragraphs: [
          _en("It happens a lot. Some family members worry that any movement "
              "is dangerous, and others say you should keep doing all the "
              "housework. Both come from care."),
          _en("Your doctor's advice is based on your own tests and scans, so "
              "let it lead, and share it kindly with the people around you. "
              "It can help to take your husband or mother-in-law to a visit "
              "so they can ask their questions too."),
        ],
      ),
    ],
    whenToSeeSomeone: _stopNow,
    faqs: [
      PvReadFaq(
        question: _en('My placenta was low at my 20-week scan. Should I stop '
            'exercising?'),
        answer: _en("Ask your doctor. A low placenta at 20 weeks often moves "
            "up by the third trimester, and you'll usually have another scan "
            "to check. If you've had no bleeding, many doctors allow gentle "
            "walking. If you've had bleeding, you'll probably be asked to "
            "avoid exercise and sex."),
      ),
      PvReadFaq(
        question: _en('I have a stitch in my cervix. Can I walk?'),
        answer: _en("Everyday walking is usually allowed, but not exercise. "
            "Ask your doctor exactly what's safe for you."),
      ),
      PvReadFaq(
        question: _en("I'm carrying twins. Can I exercise?"),
        answer: _en("Often yes, gently, if your doctor agrees. They'll look at "
            "your scans and may ask you to slow down earlier than with one "
            "baby."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 804 (2020), contraindications to '
        'exercise · NICE guideline NG201, Antenatal care (2021) · RCOG '
        'Green-top Guideline 27a, Placenta praevia and placenta accreta '
        '(2018).'),
    readNext: [
      'preg_move_read_when_to_stop',
      'preg_move_read_is_it_safe',
      'preg_move_read_pelvic_floor',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Diastasis recti
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_diastasis',
    hue: _hue,
    kicker: _kMove,
    title: _en('Belly muscles separating (diastasis recti)'),
    teaser: _en("Why the muscles down the middle of your belly move apart, how "
        "to spot it, and how to protect them."),
    shortAnswer: _en("As your bump grows, the two long muscles down the front "
        "of your belly stretch apart. Some separation is normal by the last "
        "months, and for most women the gap narrows in the months after "
        "birth. Avoid crunches and sit-ups, and roll onto your side to get "
        "up from lying down."),
    scaleSetter: _en("This is a normal part of making room for your baby, not "
        "an injury. It isn't painful for most women, and it isn't dangerous. "
        "A few everyday habits help protect the muscles."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Your 'six-pack' muscles (rectus abdominis) run in two strips "
            "from your ribs to your pubic bone, joined down the middle by a "
            "band of tissue. As your womb grows, that band stretches and "
            "thins, and the two strips move apart. This is called diastasis "
            "recti."),
        _en("Some widening happens in most pregnancies by the third "
            "trimester. It's how your body makes room."),
      ]),
      PvReadSection(
        heading: _en('How do I know if I have it?'),
        paragraphs: [
          _en("You may see a ridge or dome down the middle of your bump when "
              "you sit up from lying down, or lift your head. Some women see "
              "a soft dip above or below the belly button."),
          _en("It's usually painless. You might notice a weaker feeling in "
              "your middle, or more back ache."),
          _en("The gap is often wider with twins, a big baby, or pregnancies "
              "close together. It doesn't mean anything went wrong."),
          _en("It doesn't need testing in pregnancy. After the birth, your "
              "doctor or a physiotherapist can check how wide the gap is, "
              "usually by feeling along the middle of your belly as you lift "
              "your head."),
        ],
      ),
      PvReadSection(
        heading: _en('What makes it worse?'),
        bullets: [
          _en("Crunches, sit-ups and double leg lifts."),
          _en("Front planks and full push-ups, once your bump shows."),
          _en("Sitting straight up from lying on your back."),
          _en("Straining on the toilet."),
          _en("Lifting heavy things while holding your breath."),
          _en("Deep backbends that stretch the front of your belly."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I get up safely?'),
        paragraphs: [
          _en("Getting out of bed is where many women strain their belly "
              "without noticing. Try this instead:"),
        ],
        bullets: [
          _en("Bend your knees, with your feet flat on the bed."),
          _en("Roll onto your side, knees together, turning your shoulders "
              "and hips as one."),
          _en("Let your legs slide off the edge of the bed."),
          _en("Push up to sitting with your hands as your legs go down."),
          _en("Pause for a moment before you stand."),
        ],
        tip: PvReadTip(
          title: _en('Lying down is the same, in reverse'),
          body: _en("Sit on the edge, lower yourself onto your side using your "
              "arms, then lift your legs up. It helps a sore back and pelvis "
              "too."),
        ),
      ),
      PvReadSection(
        heading: _en('What helps?'),
        bullets: [
          _en("Deep belly breathing. Breathe in and let your belly and ribs "
              "widen. As you breathe out, gently draw your belly button in, "
              "as if hugging your baby."),
          _en("Pelvic floor exercises, which work together with your deep "
              "belly muscles."),
          _en("Pelvic tilts on your hands and knees, or standing against a "
              "wall."),
          _en("Standing tall, without letting your lower back sway."),
          _en("Breathing out as you lift, and bending your knees."),
          _en("Keeping your stools soft with water, fibre and fruit, so you "
              "don't strain."),
        ],
        tip: PvReadTip(
          title: _en('Watch for the ridge'),
          body: _en("If any exercise makes your belly bulge into a ridge, "
              "change it or leave it out. The ridge is a sign the muscles are "
              "being pushed apart."),
        ),
      ),
      PvReadSection(
        heading: _en('Which exercises are fine with it?'),
        bullets: [
          _en("Walking and swimming."),
          _en("Side-lying leg lifts and clams."),
          _en("Squats to a chair, breathing out as you stand."),
          _en("Wall push-ups instead of floor push-ups."),
          _en("Pelvic floor exercises, done daily."),
          _en("Prenatal yoga without deep backbends."),
        ],
        paragraphs: [
          _en("These keep you strong without pushing your belly outwards. "
              "Breathe out on the effort, keep your movements slow, and stop "
              "any exercise that makes a ridge appear down the middle of your "
              "bump."),
        ],
        tip: PvReadTip(
          title: _en('Carrying a toddler'),
          body: _en("Hold your toddler close on your front rather than on one "
              "hip, and breathe out as you lift. Where you can, let them "
              "climb up to you on a sofa or step."),
        ),
      ),
      PvReadSection(
        heading: _en('What happens after the birth?'),
        paragraphs: [
          _en("For most women, the gap narrows a lot in the first two to "
              "three months after birth. For some it stays wide. If you still "
              "see a bulge, or have back ache or leaking after six to eight "
              "weeks, ask your doctor to refer you to a women's health "
              "physiotherapist. The right exercises help, and it's never too "
              "late to start."),
          _en("A soft bulge that goes back in easily is common. A painful "
              "lump near your belly button that doesn't go back in may be a "
              "hernia, and your doctor should look at it."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor today if'),
      body: _en("You have a painful lump or bulge near your belly button that "
          "doesn't go back in, belly pain that doesn't ease, or any bleeding "
          "or fluid leaking from your vagina. If the lump is hard and very "
          "painful and you're being sick, go to hospital now."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Did I cause this by exercising?'),
        answer: _en("No. It happens because your womb grows, not because of "
            "anything you did."),
      ),
      PvReadFaq(
        question: _en('Should I wear a belly belt?'),
        answer: _en("A support belt can feel good for back ache in late "
            "pregnancy, but it won't stop the muscles separating. Don't wear "
            "one tight all day."),
      ),
      PvReadFaq(
        question: _en('Can I still do yoga?'),
        answer: _en("Yes. Leave out poses that make your belly dome, like deep "
            "backbends and boat pose, and roll onto your side to get up."),
      ),
    ],
    evidence: _en('Mota et al., Prevalence and risk factors of diastasis recti '
        'abdominis from late pregnancy to 6 months postpartum, Manual Therapy '
        '(2015) · Benjamin et al., Effects of exercise on diastasis of the '
        'rectus abdominis muscle, a systematic review, Physiotherapy (2014) · '
        'ACOG Committee Opinion 804 (2020).'),
    readNext: [
      'preg_move_read_pelvic_floor',
      'preg_move_read_second_trimester',
      'preg_move_read_avoid',
    ],
  ),

  // ===========================================================================
  //  PELVIC FLOOR
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Pelvic floor and kegels
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_pelvic_floor',
    hue: _hue,
    kicker: _kPelvic,
    title: _en('Your pelvic floor, and how to do kegels'),
    teaser: _en("What your pelvic floor does, why pregnancy strains it, and a "
        "short routine you can do anywhere."),
    shortAnswer: _en("Your pelvic floor is a sling of muscles that holds up "
        "your bladder, womb and bowel. Pregnancy and birth stretch it, and "
        "pelvic floor exercises (kegels) keep it strong. Squeeze and lift as "
        "if holding in wind and pee, hold, then let go fully. A few minutes "
        "a day, every day, is enough."),
    scaleSetter: _en("Doctors advise pelvic floor exercises for every "
        "pregnant woman, not only those with a problem. They take a few "
        "minutes, nobody can see you do them, and they help now and after "
        "the birth."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Your pelvic floor is a group of muscles stretched like a hammock "
            "from your pubic bone at the front to your tailbone at the back. "
            "It holds up your bladder, womb and bowel. It helps you control "
            "pee, wind and stools, and it plays a part in sex."),
        _en("In pregnancy, the growing weight of your baby presses down on "
            "it, and hormones soften it. A vaginal birth stretches it a lot. "
            "Strong muscles cope better with both."),
      ]),
      PvReadSection(
        heading: _en('What do kegels do for me?'),
        bullets: [
          _en("Fewer leaks when you cough, sneeze, laugh or lift."),
          _en("Better control of wind and stools."),
          _en("More support for your back and pelvis."),
          _en("A quicker recovery after the birth."),
          _en("Better support for your bladder and womb as you get older."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I find the right muscles?'),
        paragraphs: [
          _en("Sit comfortably with your knees slightly apart. Imagine you're "
              "trying to stop yourself passing wind, and at the same time "
              "trying to stop the flow of pee. That squeeze and lift, inside, "
              "is your pelvic floor."),
          _en("Another way: imagine picking up a small bead with your vagina "
              "and lifting it up inside you."),
          _en("Your tummy, buttocks and thighs should stay soft. Keep "
              "breathing normally."),
        ],
        tip: PvReadTip(
          title: _en("Don't practise on the toilet"),
          body: _en("You can stop your pee once to learn where the muscles "
              "are. Don't do it as an exercise, because it can stop your "
              "bladder emptying fully."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I do them?'),
        paragraphs: [
          _en("There are two kinds, and it helps to do both. The slow ones "
              "build strength, and the fast ones help the muscles react "
              "quickly when you cough or sneeze."),
        ],
        bullets: [
          _en("Slow squeezes: squeeze and lift, hold for up to 10 seconds, "
              "then let go fully and rest for the same time. Start with what "
              "you can manage, even 3 seconds, and build up."),
          _en("Fast squeezes: squeeze and lift quickly, hold for a second, "
              "and let go. Do 10 in a row."),
          _en("Aim for 10 slow and 10 fast squeezes, three times a day."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does letting go matter?'),
        paragraphs: [
          _en("Letting go fully matters as much as squeezing. A muscle that "
              "never relaxes gets tired and sore, and in labour you'll want "
              "these muscles to soften and open."),
          _en("Our Kegel Care tool counts the holds and rests for you. It "
              "starts with short holds and builds up by trimester, so you "
              "don't have to count."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I make it a habit?'),
        bullets: [
          _en("Link it to something you do every day: brushing your teeth, "
              "waiting for the pressure cooker whistle, or feeding a "
              "toddler."),
          _en("Do a set lying down at first, then sitting, then standing."),
          _en("Set a daily reminder on your phone."),
          _en("Check yourself now and then. After a set, you should feel the "
              "muscles let go fully."),
          _en("Give it time. It takes about three months of regular practice "
              "to feel a real difference."),
        ],
      ),
      PvReadSection(
        heading: _en('What if it feels tight or painful?'),
        paragraphs: [
          _en("Some women's pelvic floor is too tight rather than weak. Signs "
              "include pain during sex, pain with an internal check, or "
              "trouble starting to pee. If that's you, focus on letting go "
              "and breathing low into your belly, and ask your doctor about "
              "a physiotherapist before doing lots of squeezes."),
          _en("A planned C-section doesn't skip this. Carrying your baby for "
              "nine months puts weight on the pelvic floor, so it needs care "
              "whatever kind of birth you have."),
        ],
      ),
      PvReadSection(
        heading: _en('What else protects my pelvic floor?'),
        bullets: [
          _en("Don't strain on the toilet. Eat fibre and drink water, and on "
              "a western toilet, rest your feet on a small stool so your "
              "knees are above your hips. An Indian-style toilet already puts "
              "you in this position."),
          _en("Sit down fully on the seat. Hovering keeps the muscles tight "
              "when they should relax."),
          _en("Don't go to the toilet 'just in case' all the time. Go when "
              "you need to."),
          _en("Squeeze just before you cough, sneeze or lift. Physios call "
              "this 'the knack', and with practice it becomes automatic."),
          _en("Keep drinking water. Drinking less makes pee stronger, which "
              "can irritate your bladder."),
        ],
      ),
    ],
    whenToSeeSomeone: _pelvicCall,
    faqs: [
      PvReadFaq(
        question: _en('Can kegels make labour harder?'),
        answer: _en("No. A strong pelvic floor that can also relax well helps "
            "you in labour. Practise letting go fully after each squeeze."),
      ),
      PvReadFaq(
        question: _en('When should I start?'),
        answer: _en("Now, whatever week you are. It's never too early or too "
            "late."),
      ),
      PvReadFaq(
        question: _en('Should I keep doing them after the birth?'),
        answer: _en("Yes. Start gently in the first days, once it's "
            "comfortable, and keep going. After a tear or a C-section, your "
            "doctor or physiotherapist can guide you."),
      ),
      PvReadFaq(
        question: _en("I can't feel anything when I squeeze. What should I "
            "do?"),
        answer: _en("That's common at first. Try lying down, or ask your "
            "doctor to refer you to a women's health physiotherapist, who "
            "can check you're using the right muscles."),
      ),
    ],
    evidence: _en('NICE guideline NG210, Pelvic floor dysfunction: prevention '
        'and non-surgical management (2021) · Cochrane review, Woodley et al., '
        'Pelvic floor muscle training for preventing and treating urinary and '
        'faecal incontinence in antenatal and postnatal women (2020) · NHS '
        'guidance: Pelvic floor exercises.'),
    readNext: [
      'preg_move_read_leaking',
      'preg_move_read_perineal_massage',
      'preg_move_read_diastasis',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Leaking urine
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_leaking',
    hue: _hue,
    kicker: _kPelvic,
    title: _en('Leaking a little when you cough or sneeze'),
    teaser: _en("Why it happens in pregnancy, what helps, and how to tell a "
        "leak of pee from your waters."),
    shortAnswer: _en("Leaking a little pee when you cough, sneeze, laugh or "
        "lift is common in pregnancy. Your baby presses on your bladder, and "
        "your pelvic floor is under strain. Daily pelvic floor exercises help "
        "most women. If fluid keeps leaking and you can't stop it, call your "
        "hospital, as it may be your waters."),
    scaleSetter: _en("Many women leak a little in pregnancy, and few talk "
        "about it. It isn't your fault, it's nothing to hide from your "
        "doctor, and it usually gets better with simple exercises."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("It can catch you by surprise: a sneeze, a laugh with your "
              "sister, lifting a bucket, and a little wet patch. You're far "
              "from alone."),
        ],
        mythFact: PvMythFact(
          myth: _en("Leaking is just what happens when you have babies. You "
              "have to live with it."),
          fact: _en("Leaking is common, but you don't have to accept it. "
              "Pelvic floor exercises help most women, in pregnancy and "
              "after, and a physiotherapist can help if they don't."),
        ),
      ),
      PvReadSection(
        heading: _en('Why does it happen?'),
        paragraphs: [
          _en("Your bladder sits right under your womb. As your baby grows, "
              "there's more weight pressing on it and less room for it to "
              "fill. Pregnancy hormones also soften the pelvic floor muscles "
              "that keep your bladder closed."),
          _en("When you cough, sneeze or lift, the pressure in your belly "
              "jumps for a moment. If the muscles can't hold against it, a "
              "little pee escapes. This is called stress incontinence. "
              "'Stress' here means pressure, not worry."),
          _en("It's more common later in pregnancy, and in second and later "
              "pregnancies, but it can start at any time. Constipation makes "
              "it worse, because a full bowel presses on the bladder."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps?'),
        bullets: [
          _en("Pelvic floor exercises, every day. They're the main treatment, "
              "and they work for most women. 'Your pelvic floor, and how to do "
              "kegels' on this tab shows you how."),
          _en("Squeeze your pelvic floor just before you cough, sneeze, laugh "
              "or lift."),
          _en("Cross your legs when you feel a sneeze coming."),
          _en("Empty your bladder before exercise and long trips."),
          _en("Keep your stools soft so you don't strain."),
          _en("Cut back on fizzy drinks and strong tea or coffee if they make "
              "you need to go in a hurry."),
          _en("Wear a panty liner, or a pad made for bladder leaks, if it "
              "helps you feel confident. Change it often."),
        ],
        tip: PvReadTip(
          title: _en("Don't cut down on water"),
          body: _en("It's tempting to drink less to leak less. But strong, "
              "dark pee irritates the bladder and makes things worse, and you "
              "need water in pregnancy. Drink steadily through the day, and "
              "have less in the last hour or two before bed."),
        ),
      ),
      PvReadSection(
        heading: _en('Is it pee, or my waters?'),
        paragraphs: [
          _en("Late in pregnancy it can be hard to tell. Here's how they "
              "usually differ."),
        ],
        bullets: [
          _en("Pee comes when you cough, sneeze or laugh, then stops. It "
              "smells like urine."),
          _en("Your waters usually keep coming, especially when you stand or "
              "move, and a squeeze won't stop them. They're usually clear or "
              "pale pink, and smell faintly sweet or of nothing."),
          _en("Discharge is thicker, and doesn't soak a pad."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Not sure? Check with a pad'),
          body: _en("Put on a pad and lie down for half an hour. If it's wet "
              "again when you stand up, call your hospital. It's always fine "
              "to get it checked."),
        ),
      ),
      PvReadSection(
        heading: _en('When is it something else?'),
        paragraphs: [
          _en("A few signs mean you should see your doctor rather than just "
              "do the exercises:"),
        ],
        bullets: [
          _en("Burning or stinging when you pee, or needing to go far more "
              "often. This can be a urine infection, which is common in "
              "pregnancy and needs treating promptly. Call your doctor the "
              "same day."),
          _en("A sudden, strong urge to go that you can't hold back."),
          _en("Leaking all the time, not only with coughs or sneezes."),
          _en("Leaking stools, or wind you can't control."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I feel confident when I go out?'),
        bullets: [
          _en("Find the toilets when you arrive at the mall, office or "
              "temple."),
          _en("Carry a spare pad and a change of underwear in your bag."),
          _en("Go before long car or train trips, and ask to stop when you "
              "need to."),
          _en("Wear darker clothes if it helps you relax."),
          _en("Keep doing your pelvic floor exercises. Most women notice "
              "fewer leaks within a few weeks."),
        ],
      ),
      PvReadSection(
        heading: _en('Will it go away after the birth?'),
        paragraphs: [
          _en("For many women it gets better in the weeks and months after "
              "birth, especially with pelvic floor exercises. If you're still "
              "leaking three months after your baby is born, tell your "
              "doctor. A women's health physiotherapist can help, and there's "
              "no need to put up with it."),
        ],
      ),
    ],
    whenToSeeSomeone: _pelvicCall,
    faqs: [
      PvReadFaq(
        question: _en('Is leaking a sign something is wrong with my baby?'),
        answer: _en("No. It's about pressure on your bladder, not about your "
            "baby's health."),
      ),
      PvReadFaq(
        question: _en('Should I stop exercising because I leak?'),
        answer: _en("No. Keep moving, empty your bladder first, and choose "
            "gentler exercise like walking or swimming instead of "
            "jumping."),
      ),
      PvReadFaq(
        question: _en('Is it embarrassing to tell my doctor?'),
        answer: _en("Doctors hear this every day. Telling them means they can "
            "check for an infection and guide you to the right help."),
      ),
    ],
    evidence: _en('NICE guideline NG210, Pelvic floor dysfunction: prevention '
        'and non-surgical management (2021) · Cochrane review, Woodley et al. '
        '(2020) · NICE guideline NG109, Urinary tract infection (lower): '
        'antimicrobial prescribing (2018).'),
    readNext: [
      'preg_move_read_pelvic_floor',
      'preg_move_read_perineal_massage',
      'preg_move_read_cant_sleep',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Perineal massage
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_perineal_massage',
    hue: _hue,
    kicker: _kPelvic,
    title: _en('Perineal massage from 34 weeks'),
    teaser: _en("What it is, what it can do for a vaginal birth, and how to do "
        "it gently at home, on your own or with your husband."),
    shortAnswer: _en("Perineal massage means gently stretching the skin "
        "between your vagina and back passage in the last weeks of "
        "pregnancy. From about 34 weeks, once or twice a week, it can mean "
        "fewer tears that need stitches, especially in a first vaginal "
        "birth. It's optional, and it's fine to skip it."),
    scaleSetter: _en("Most first-time mothers have some tear, graze or cut in "
        "a vaginal birth, and most heal well. Perineal massage is one simple "
        "way to prepare. It isn't a test, and nothing bad happens if you "
        "choose not to."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Your perineum is the area of skin and muscle between your vagina "
            "and your back passage (anus). In a vaginal birth, it stretches "
            "to let your baby's head through. Sometimes it tears, or your "
            "doctor makes a small cut (an episiotomy)."),
        _en("Perineal massage helps the skin get used to stretching before "
            "the day. Few women in India have heard of it, but it's simple, "
            "private and free. Your doctor may not mention it, so it's fine "
            "to bring it up at a visit."),
      ]),
      PvReadSection(
        heading: _en('Does it help?'),
        paragraphs: [
          _en("A review that pooled several trials found that massage from "
              "about 34 weeks meant fewer tears needing stitches and fewer "
              "episiotomies, mainly for women having their first vaginal "
              "birth. Women who'd given birth vaginally before had less pain "
              "in the perineum in the months afterwards."),
          _en("It doesn't prevent every tear, and it doesn't change whether "
              "you'll need forceps or a C-section. It's one helpful thing, "
              "not a promise."),
        ],
      ),
      PvReadSection(
        heading: _en('When should I not do it?'),
        bullets: [
          _en("Before 34 weeks."),
          _en("If you have a low-lying placenta (placenta praevia), or any "
              "bleeding."),
          _en("If your waters have broken."),
          _en("If you have thrush, a vaginal infection, or herpes sores."),
          _en("If your doctor has told you not to."),
          _en("If it hurts. A stretch and a slight tingle are expected. Sharp "
              "pain isn't."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I do it?'),
        paragraphs: [
          _en("Choose a private, relaxed time, like after a warm bath. It "
              "takes about 5 minutes."),
        ],
        bullets: [
          _en("Wash your hands and trim your nails. Put a clean towel under "
              "you, and keep a small bottle of oil just for this."),
          _en("Sit or lean back somewhere comfortable, propped up with "
              "pillows, knees bent and apart. Some women prefer standing with "
              "one foot up on a stool."),
          _en("Put a little plain, unscented oil, like coconut or sweet "
              "almond oil, or a water-based lubricant, on your thumbs and "
              "around your perineum."),
          _en("Place your thumbs about 3 to 4 cm inside your vagina."),
          _en("Press down towards your back passage and out to the sides "
              "until you feel a stretch or slight tingle. Hold for about a "
              "minute."),
          _en("Then gently sweep your thumbs in a U shape, down and up the "
              "sides, for 2 to 3 minutes."),
          _en("Breathe slowly, and let the muscles relax, just as you will "
              "in labour."),
        ],
        tip: PvReadTip(
          title: _en('If your bump gets in the way'),
          body: _en("Use a mirror the first few times, or ask your husband to "
              "help, using his index fingers instead of thumbs. Tell him how "
              "much pressure feels right, and stop whenever you want."),
        ),
      ),
      PvReadSection(
        heading: _en('How often?'),
        paragraphs: [
          _en("Once or twice a week is enough. In the studies, doing it more "
              "often than that didn't help more."),
          _en("It may feel strange or a little uncomfortable the first few "
              "times. For most women it gets easier each week."),
          _en("Keep going until your baby is born, unless your waters break, "
              "you have bleeding, or your doctor asks you to stop."),
        ],
      ),
      PvReadSection(
        heading: _en('What else helps on the day?'),
        paragraphs: [
          _en("Some things that help happen during the birth, and your doctor "
              "or midwife will guide them:"),
        ],
        bullets: [
          _en("A warm compress held on your perineum as your baby's head is "
              "being born."),
          _en("Pushing slowly and gently as the head crowns, breathing your "
              "baby out rather than pushing hard."),
          _en("Positions that suit you, like lying on your side or kneeling "
              "on all fours."),
          _en("Your doctor's hands supporting the perineum."),
        ],
        tip: PvReadTip(
          title: _en('Ask at a visit'),
          body: _en("It's fine to ask your doctor how the hospital helps "
              "protect the perineum, and when they would do an episiotomy."),
        ),
      ),
      PvReadSection(
        heading: _en('What if I tear anyway?'),
        paragraphs: [
          _en("Most tears are small and heal within a few weeks. Your doctor "
              "will check you after the birth and stitch any tear that needs "
              "it, with numbing medicine first. Keeping the area clean, a "
              "cold pack wrapped in a cloth, and pelvic floor exercises all "
              "help it heal."),
          _en("A few women have a deeper tear that reaches the muscle around "
              "the back passage. It's repaired carefully in theatre and "
              "followed up, and most women recover well."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Stop, and call your doctor straight away, if'),
      body: _en("You have any bleeding, fluid leaking from your vagina, or "
          "pain that doesn't settle after you stop. Call today if you notice "
          "itching, a smelly discharge or sores, which can be an infection. "
          "If you're bleeding heavily or your baby is moving less than usual, "
          "go to hospital now."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is it safe for my baby?'),
        answer: _en("Yes. Your baby is well protected inside the womb, and the "
            "massage is only at the entrance to your vagina. Stop if you have "
            "any bleeding."),
      ),
      PvReadFaq(
        question: _en('Can my husband do it?'),
        answer: _en("Yes, if you're both comfortable. Many couples find it "
            "brings them closer before the birth."),
      ),
      PvReadFaq(
        question: _en('I only found out about this at 38 weeks. Is it too '
            'late?'),
        answer: _en("You can still start. Even a few sessions help you get "
            "used to the feeling of stretching."),
      ),
      PvReadFaq(
        question: _en('Which oil should I use?'),
        answer: _en("Plain, unscented oil like coconut or sweet almond oil, or "
            "a water-based lubricant. Avoid perfumed oils, and anything that "
            "stings."),
      ),
    ],
    evidence: _en('Cochrane review, Beckmann and Stock, Antenatal perineal '
        'massage for reducing perineal trauma (2013) · RCOG patient '
        'information: Perineal tears during childbirth · NICE guideline '
        'NG235, Intrapartum care (2023).'),
    readNext: [
      'preg_move_read_pelvic_floor',
      'preg_move_read_third_trimester',
      'preg_move_read_leaking',
    ],
  ),

  // ===========================================================================
  //  SLEEP AND REST
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Side sleeping
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_side_sleeping',
    hue: _hue,
    kicker: _kRest,
    title: _en('Sleeping on your side from 28 weeks'),
    teaser: _en("Why doctors advise going to sleep on your side in the last "
        "months, which side, and what to do if you wake up on your back."),
    shortAnswer: _en("From 28 weeks, go to sleep on your side, at night and "
        "for daytime naps. Left or right are both fine. If you wake up on "
        "your back, turn onto your side again. That's all you need to do. "
        "Pillows behind your back and between your knees make it easier."),
    scaleSetter: _en("This is simple, and you don't need to lie awake watching "
        "yourself. The advice is about the position you fall asleep in. "
        "Everyone moves in the night, and waking on your back is common and "
        "okay."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In the last three months, doctors advise going to sleep on your "
            "side. You may already find lying on your back uncomfortable, or "
            "you may have slept that way all your life. Either way, here's "
            "why it matters and how to make it easier. Most women find a way "
            "that works within a week or two."),
      ]),
      PvReadSection(
        heading: _en('Why does it matter?'),
        paragraphs: [
          _en("When you lie on your back late in pregnancy, the weight of "
              "your womb presses on the large blood vessels running behind "
              "it. This can reduce blood flow to your baby, and can make you "
              "feel dizzy or sick."),
          _en("Large studies from several countries found that, from 28 "
              "weeks, going to sleep lying on the back was linked to a higher "
              "rate of stillbirth. Going to sleep on the side was not."),
          _en("Stillbirth is uncommon. Going to sleep on your side is one "
              "easy thing that helps, and it costs nothing but a few pillows "
              "and a little getting used to."),
        ],
      ),
      PvReadSection(
        heading: _en('Which side is best?'),
        mythFact: PvMythFact(
          myth: _en("You must sleep on your left side only, or it harms the "
              "baby."),
          fact: _en("Either side is safe. The left side is often suggested, "
              "but studies found no difference between left and right. "
              "Choose whichever is comfortable, and switch sides in the "
              "night."),
        ),
      ),
      PvReadSection(
        heading: _en('What if I wake up on my back?'),
        paragraphs: [
          _en("That's normal. You can't control how you move in your sleep, "
              "and nobody expects you to. The research is about the position "
              "you go to sleep in, because that's where most people spend "
              "the longest stretch of the night."),
          _en("If you wake up on your back, turn onto your side and go back "
              "to sleep. There's nothing else you need to do, unless you've "
              "noticed your baby moving less."),
          _en("Some women feel faint, sick or sweaty when they lie flat on "
              "their back. If that happens, roll onto your side and it passes "
              "in a minute or two."),
          _en("The same goes for naps. If you doze on the sofa after lunch, "
              "lie on your side, or sit well propped up."),
        ],
      ),
      PvReadSection(
        heading: _en('How can pillows help?'),
        bullets: [
          _en("A pillow between your knees and ankles eases your hips and "
              "lower back."),
          _en("A pillow or rolled blanket behind your back stops you rolling "
              "onto it."),
          _en("A small pillow, or a folded dupatta, under your bump takes its "
              "weight."),
          _en("An extra pillow under your head and shoulders helps with "
              "heartburn and a blocked nose."),
          _en("A long pregnancy pillow does all of this at once, but ordinary "
              "pillows work just as well."),
          _en("In summer, cotton pillowcases and a fan keep the pillows from "
              "getting hot."),
        ],
        tip: PvReadTip(
          title: _en('Start a little earlier'),
          body: _en("If you're used to sleeping on your back, start practising "
              "side sleeping in the second trimester, so it feels normal by "
              "28 weeks."),
        ),
      ),
      PvReadSection(
        heading: _en('What if I sleep on the floor or a hard bed?'),
        paragraphs: [
          _en("Many Indian homes sleep on a thin mattress on the floor, or on "
              "a firm bed. That's fine in pregnancy. A thicker mattress or a "
              "folded quilt under your hips and shoulders makes side sleeping "
              "more comfortable."),
          _en("Getting up from the floor takes more effort later on. Roll "
              "onto your hands and knees first, then come up one leg at a "
              "time, holding something steady."),
        ],
      ),
      PvReadSection(
        heading: _en('What about long trips?'),
        paragraphs: [
          _en("On an overnight train or bus, lie on your side on the berth, "
              "or sit well propped up. On a long car ride, sit back rather "
              "than lying flat across the back seat. Stop every hour or two "
              "to walk and stretch your legs."),
        ],
      ),
      PvReadSection(
        heading: _en('What about my hips and back?'),
        paragraphs: [
          _en("Lying on one side for long can make your hip ache. Change "
              "sides when you wake, put a folded blanket or thin mattress "
              "topper on a hard bed, and keep a pillow between your knees."),
          _en("If turning over in bed hurts your pelvis, keep your knees "
              "together and roll your hips and shoulders as one. Tell your "
              "doctor if the pain is stopping you sleeping, as a "
              "physiotherapist can help."),
        ],
      ),
    ],
    whenToSeeSomeone: _sleepCall,
    faqs: [
      PvReadFaq(
        question: _en('Can I sleep on my back before 28 weeks?'),
        answer: _en("Yes, if it's comfortable. Many women find it isn't by "
            "then anyway."),
      ),
      PvReadFaq(
        question: _en('Is it okay to sleep propped up, half sitting?'),
        answer: _en("Yes. Sleeping at an angle with plenty of pillows is fine, "
            "and many women with heartburn prefer it."),
      ),
      PvReadFaq(
        question: _en('Is sleeping on my stomach safe?'),
        answer: _en("In early pregnancy, yes, and it won't hurt your baby. It "
            "just gets uncomfortable as your bump grows."),
      ),
    ],
    evidence: _en('NICE guideline NG201, Antenatal care (2021) · Heazell et '
        'al., the MiNESS study, BJOG (2017) · Cronin et al., individual '
        'participant data meta-analysis of going-to-sleep position and late '
        'stillbirth, EClinicalMedicine (2019).'),
    readNext: [
      'preg_move_read_cant_sleep',
      'preg_move_read_tiredness',
      'preg_move_read_third_trimester',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Can't sleep
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_cant_sleep',
    hue: _hue,
    kicker: _kRest,
    title: _en("When you can't sleep in pregnancy"),
    teaser: _en("Why sleep gets harder, and practical help for heartburn, "
        "bathroom trips, leg cramps, a blocked nose and a busy mind."),
    shortAnswer: _en("Poor sleep is very common in pregnancy, from hormones "
        "early on to heartburn, bathroom trips and a big bump later. A "
        "steady bedtime, an earlier, lighter dinner, a cool dark room, "
        "daytime walks and good pillows help most women. Don't take "
        "sleeping pills or herbal remedies without asking your doctor."),
    scaleSetter: _en("Most pregnant women sleep badly at some point, and it's "
        "hard. A few weeks of poor sleep won't harm your baby, and a few "
        "small changes can make nights easier."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In the first trimester, hormones can make you sleepy all day and "
            "awake at night, with trips to the bathroom. In the second, sleep "
            "often gets a little better. In the third, a heavy bump, "
            "heartburn, a kicking baby and a busy mind can all keep you up."),
        _en("You won't fix all of it, but you can make it easier."),
      ]),
      PvReadSection(
        heading: _en('What helps me fall asleep?'),
        bullets: [
          _en("Go to bed and get up at about the same time each day, "
              "weekends too."),
          _en("Get daylight in the morning, and move during the day. A walk "
              "helps you sleep better at night."),
          _en("Keep your room cool and dark, with a fan or cooler, cotton "
              "sheets and loose cotton nightclothes."),
          _en("Put your phone away an hour before bed, or at least dim it. "
              "Bright screens tell your brain it's daytime."),
          _en("Have a wind-down routine: a warm (not hot) bath, a few gentle "
              "stretches, slow breathing, a short prayer, or quiet music."),
          _en("Keep caffeine under about 200 mg a day, which is two to three "
              "cups of normal chai, and have it before lunch."),
          _en("If you can't sleep after about 20 minutes, get up, sit "
              "somewhere dim and do something calm, then go back to bed when "
              "you feel sleepy."),
        ],
      ),
      PvReadSection(
        heading: _en('What if heartburn keeps me up?'),
        bullets: [
          _en("Eat dinner earlier, two to three hours before bed, and keep it "
              "lighter. Save heavy, spicy or fried food for lunch."),
          _en("Eat smaller meals more often through the day."),
          _en("Raise the head end of your bed a little, or sleep propped up "
              "on pillows."),
          _en("A glass of cold milk, or a few fennel seeds (saunf) after "
              "dinner, soothes some women."),
          _en("Ask your doctor about a pregnancy-safe antacid if it's bad."),
        ],
      ),
      PvReadSection(
        heading: _en('What about bathroom trips and leg cramps?'),
        bullets: [
          _en("Drink plenty during the day and less in the last hour or two "
              "before bed, but don't cut down overall."),
          _en("Lean forward a little when you pee, to help empty your bladder "
              "fully."),
          _en("Keep a dim night light on the way to the bathroom, so you "
              "don't trip or wake yourself up fully."),
          _en("For leg cramps, stretch your calves before bed: stand facing a "
              "wall, one leg back, heel down, and lean in. When a cramp comes, "
              "pull your toes towards your knee and rub the muscle."),
          _en("Gentle daily walks and enough water help with cramps too."),
        ],
        tip: PvReadTip(
          title: _en('Restless legs at night'),
          body: _en("A creeping urge to move your legs at night can be linked "
              "to low iron. Tell your doctor about it."),
        ),
      ),
      PvReadSection(
        heading: _en('What if a blocked nose or snoring wakes me?'),
        paragraphs: [
          _en("Pregnancy hormones swell the lining of your nose, so a blocked "
              "nose at night is common. Saline nose drops, steam from a bowl "
              "of warm water, and an extra pillow can help. Ask your doctor "
              "before using decongestant sprays or tablets."),
          _en("Many women start snoring in pregnancy. Tell your doctor at "
              "your next visit if you snore loudly, or someone notices you "
              "stop breathing or gasp in your sleep. It can be linked to high "
              "blood pressure, and it can be treated."),
        ],
      ),
      PvReadSection(
        heading: _en("What if my mind won't switch off?"),
        paragraphs: [
          _en("Worries often get louder at night: the birth, money, work, "
              "your baby's health. Try writing them down before bed, with one "
              "small thing you'll do about each one tomorrow. Slow breathing "
              "helps too: breathe in for four counts, and out for six."),
          _en("If worry or low mood keeps you awake most nights, tell your "
              "doctor. It's common in pregnancy and it can be treated. The "
              "Mind & mood door has more help."),
        ],
        tip: PvReadTip(
          title: _en('Daytime rest counts'),
          body: _en("If your nights are broken, a nap of 20 to 30 minutes in "
              "the afternoon can help. Lie on your side, and try not to nap "
              "late in the evening."),
        ),
      ),
      PvReadSection(
        heading: _en('Can I take something to help me sleep?'),
        paragraphs: [
          _en("Don't take sleeping pills, antihistamines or herbal sleep "
              "remedies without asking your doctor first. Some aren't safe in "
              "pregnancy, and some leave you groggy the next day. Warm milk, a "
              "warm bath and a calm routine are safe to try."),
        ],
      ),
    ],
    whenToSeeSomeone: _sleepCall,
    faqs: [
      PvReadFaq(
        question: _en('Does poor sleep harm my baby?'),
        answer: _en("A few bad weeks won't harm your baby. But if you're "
            "barely sleeping, tell your doctor, because rest matters for "
            "you."),
      ),
      PvReadFaq(
        question: _en('Is it okay to sleep with the AC on?'),
        answer: _en("Yes. A cool room helps sleep. Keep it comfortable rather "
            "than cold, and keep a light sheet handy."),
      ),
      PvReadFaq(
        question: _en('I dream a lot more now. Is that normal?'),
        answer: _en("Yes. Vivid and strange dreams are common in pregnancy, "
            "partly because you wake more often and remember them."),
      ),
    ],
    evidence: _en('NICE guideline NG201, Antenatal care (2021) · WHO '
        'recommendations on antenatal care for a positive pregnancy '
        'experience (2016) · NHS guidance: Sleep and tiredness in '
        'pregnancy.'),
    readNext: [
      'preg_move_read_side_sleeping',
      'preg_move_read_tiredness',
      'preg_move_read_walking',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Tiredness
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_move_read_tiredness',
    hue: _hue,
    kicker: _kRest,
    title: _en("Tired all the time: when it's more than tiredness"),
    teaser: _en("Why pregnancy is so tiring, how to rest well, and the signs "
        "of low iron or something else your doctor should check."),
    shortAnswer: _en("Tiredness is very common in the first and last months "
        "of pregnancy, and rest, naps and gentle movement help. If you're "
        "breathless, dizzy or pale, your heart races, or tiredness stops you "
        "getting through the day, ask your doctor to check your blood. Low "
        "iron (anaemia) is common in pregnancy in India, and it can be "
        "treated."),
    scaleSetter: _en("Feeling worn out is one of the most normal parts of "
        "pregnancy. Most of the time it's your body doing its work. "
        "Sometimes it's a sign of something simple to fix, and a blood test "
        "tells the difference."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In the first trimester, your body is building a placenta, making "
            "more blood, and working under a flood of hormones. Many women "
            "feel more tired than they've ever been. In the second trimester, "
            "energy often comes back. In the last months, the weight you "
            "carry and broken nights bring the tiredness back."),
        _en("This isn't laziness, and you don't need to push through it."),
      ]),
      PvReadSection(
        heading: _en('How can I rest well?'),
        bullets: [
          _en("Nap when you can. A 20 to 30 minute nap on your side can lift "
              "you for hours."),
          _en("Go to bed earlier, even if it's only by half an hour."),
          _en("Say yes when family or friends offer help with cooking, "
              "cleaning or older children."),
          _en("Ask about sitting down at work, or a shorter shift for a "
              "while."),
          _en("Plan a rest after lunch, the way many of our grandmothers "
              "did."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I get through a workday?'),
        bullets: [
          _en("Keep snacks at your desk: fruit, roasted chana, nuts or a "
              "boiled egg."),
          _en("Stand up and walk for a few minutes every hour."),
          _en("Sit with your feet up on a box or low stool."),
          _en("Ask if you can start later or leave earlier for a while."),
          _en("Rest on the commute if you can. Ask for a seat, and use the "
              "ladies' coach."),
        ],
      ),
      PvReadSection(
        heading: _en('Can food and movement help?'),
        bullets: [
          _en("Eat small meals often, with some protein at each: dal, eggs, "
              "paneer, curd, sprouts, chicken or fish."),
          _en("Eat iron-rich foods like green leafy vegetables, rajma, chana, "
              "jaggery (gur), dates, and meat if you eat it. Have something "
              "with vitamin C, like lemon or amla, at the same meal."),
          _en("Keep tea and coffee away from meals, because they make iron "
              "harder to absorb."),
          _en("Drink enough water. Even mild dehydration in the heat can "
              "leave you drained and headachy."),
          _en("A short walk, especially in daylight, often helps more than "
              "lying down."),
        ],
      ),
      PvReadSection(
        heading: _en('Could it be low iron?'),
        paragraphs: [
          _en("Anaemia means you have fewer red blood cells, or less "
              "haemoglobin in them, to carry oxygen round your body. It's "
              "very common in pregnancy in India. The National Family Health "
              "Survey (NFHS-5) found it in about half of pregnant women."),
          _en("Signs include:"),
        ],
        bullets: [
          _en("Feeling tired and weak most of the time."),
          _en("Breathlessness with everyday things, like climbing stairs."),
          _en("Feeling dizzy or light-headed."),
          _en("Pale skin, lips, inner eyelids or nails."),
          _en("A fast or pounding heartbeat."),
          _en("Craving ice, mud, chalk or raw rice."),
          _en("Restless legs at night."),
        ],
      ),
      PvReadSection(
        heading: _en('How is it treated?'),
        paragraphs: [
          _en("Your doctor checks your haemoglobin at your first visit and "
              "again later in pregnancy. Iron and folic acid tablets are "
              "offered to every pregnant woman in India, free at government "
              "health centres. Take them as your doctor advises, with water "
              "or lemon water, not with tea or milk."),
        ],
        tip: PvReadTip(
          title: _en('If the tablets upset your stomach'),
          body: _en("Constipation and a sick feeling are common with iron. Try "
              "taking them at night, drink more water, eat more fibre, and "
              "tell your doctor. There are other kinds that may suit you "
              "better. Please don't just stop."),
        ),
      ),
      PvReadSection(
        heading: _en('What else can cause tiredness?'),
        bullets: [
          _en("An underactive thyroid, which can also make you feel cold and "
              "constipated. It's checked with a blood test."),
          _en("Low vitamin B12 or vitamin D, both common in India, especially "
              "if you're vegetarian or indoors a lot."),
          _en("Low mood or anxiety. If you've lost interest in things, feel "
              "hopeless, or can't sleep even when you're exhausted, tell your "
              "doctor. This is common in pregnancy and it can be treated."),
          _en("Pregnancy diabetes, which can make you very thirsty and tired. "
              "It's checked with a sugar test."),
        ],
      ),
      PvReadSection(
        heading: _en('When should I ask for a check?'),
        paragraphs: [
          _en("Tell your doctor if tiredness is stopping you getting through "
              "a normal day, if it's getting worse instead of better, or if "
              "you have any of the signs of anaemia above. A simple blood "
              "test can find most causes."),
          _en("If you're feeling low, you don't have to wait for a visit. "
              "Tele-MANAS, the government's free mental health helpline, "
              "answers day and night on 14416."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor today if'),
      body: _en("You feel breathless doing very little, your heart races or "
          "pounds, you feel dizzy, or you look very pale. If you have chest "
          "pain, you faint, or you're breathless at rest, call 108 or go to "
          "hospital now. If you have thoughts of harming yourself, tell your "
          "doctor or someone close to you today, or call Tele-MANAS on "
          "14416."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is it okay to sleep in the afternoon?'),
        answer: _en("Yes. A short nap on your side is good for you. Keep it to "
            "20 to 30 minutes if long naps stop you sleeping at night."),
      ),
      PvReadFaq(
        question: _en('My haemoglobin is a little low. Is my baby okay?'),
        answer: _en("Mild anaemia is common and treatable. Taking your iron as "
            "advised and eating iron-rich food usually brings it up, and your "
            "doctor will check it again."),
      ),
      PvReadFaq(
        question: _en("Should I stop working because I'm tired?"),
        answer: _en("Not usually. But ask about rest breaks, sitting down, and "
            "lighter duties. If your doctor feels you need leave, they'll "
            "tell you."),
      ),
    ],
    evidence: _en('WHO recommendations on antenatal care for a positive '
        'pregnancy experience (2016) · Anemia Mukt Bharat, Ministry of Health '
        'and Family Welfare (2018) · National Family Health Survey (NFHS-5), '
        '2019 to 2021 · NICE guideline NG201, Antenatal care (2021).'),
    readNext: [
      'preg_move_read_cant_sleep',
      'preg_move_read_side_sleeping',
      'preg_move_read_first_trimester',
    ],
  ),
];

/// A read in this file by id, or null.
PvRead? moveReadById(String id) {
  for (final r in kPregnancyReadsMove) {
    if (r.id == id) return r;
  }
  return null;
}
