// Part b of the week page extras. See preg_week_extras.dart.
//
// Weeks 17 to 28. Written 2026-09-29 to docs/PREG-VOICE.md, against the
// English in weekContent.json for the same weeks (nothing here repeats it
// word for word or contradicts it). Every `symptom` is the week's
// `momJourney.commonSymptoms[i].en` exactly; test/preg_week_extras_b_test.dart
// pairs them.
import 'preg_week_extras.dart';

const List<PregWeekExtra> kPregWeekExtrasB = [
  // ---------------------------------------------------------------- week 17
  PregWeekExtra(
    week: 17,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Growing bump',
        tip: 'Your uterus is rising out of your pelvis now, so the bump shows '
            'more each week. Loose kurtas and a stretchy salwar are kinder '
            'than tight waistbands.',
      ),
      PregWeekSymptomTip(
        symptom: 'Increased appetite',
        tip: 'Your baby is growing faster and your body is making more blood, '
            'so hunger picks up. You need only a little more food, so a small '
            'snack between meals, like roasted chana, fruit or curd, usually '
            'fills the gap.',
      ),
      PregWeekSymptomTip(
        symptom: 'Mild back discomfort',
        tip: 'As your bump grows, your back takes more of the load. Sit with a '
            'cushion behind your lower back, and bend your knees, not your '
            'back, when you pick something up.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Occasional dizziness when standing quickly',
        tip: 'Your blood vessels relax in pregnancy, so your blood pressure can '
            'dip for a moment when you get up. If the room spins, sit, or lie '
            'on your left side, until it passes.',
        symptomId: 'dizziness',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'When will I feel my baby move?',
        a: 'Most women first feel movement between 16 and 24 weeks. In a first '
            'pregnancy it often comes nearer 20 weeks, and it can take longer '
            'if your placenta lies at the front of your uterus, where it '
            'cushions the kicks. If you still haven\'t felt anything by 24 '
            'weeks, tell your doctor so they can check.',
      ),
      PregWeekQuestion(
        q: 'How do I know my pregnancy is going well?',
        a: "No sign at home can tell you for sure, and feeling well or unwell "
            "isn't a reliable guide. Your check-ups are the real measure: your "
            "blood pressure, urine, weight, bump and your baby's heartbeat, "
            'and the anomaly scan in the next few weeks. Between visits, watch '
            'for the warning signs on this page and call your doctor if you '
            'notice one.',
      ),
    ],
    sources: ['mohfw_anc', 'who_anc', 'nice_ng201', 'rcog_rfm', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------- week 18
  PregWeekExtra(
    week: 18,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'Your changing balance tips you forward, so your back works harder '
            'to hold you up. Flat chappals with a good grip, and a short walk '
            'each day, help more than lying still.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Growing bump',
        tip: 'Your bump may seem to grow overnight this month. Drawstring '
            'salwars and loose kurtas grow with you, and leave your tummy room '
            'after meals.',
      ),
      PregWeekSymptomTip(
        symptom: 'Increased appetite',
        tip: "Hunger now is real, and it's fine to answer it. Keep filling "
            'snacks close by, like a banana, peanuts, a boiled egg or a bowl of '
            "poha, so you're not reaching for biscuits.",
      ),
      PregWeekSymptomTip(
        symptom: 'Occasional dizziness',
        tip: 'Standing still for long, a hot crowded room or a long gap between '
            'meals can all bring it on. Sit down as soon as you feel it, and '
            'call your doctor the same day if you faint.',
        symptomId: 'dizziness',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'What happens at the anomaly scan?',
        a: "It's a detailed ultrasound, usually done between 18 and 22 weeks, "
            "that checks your baby's growth and organs: the brain, heart, "
            'spine, kidneys, hands and feet. It also looks at where the '
            'placenta lies and how much fluid there is. It takes longer than '
            'your earlier scans, and if your baby is lying awkwardly you may '
            'be asked to walk about for a while or come back another day.',
      ),
      PregWeekQuestion(
        q: 'What should I still avoid now?',
        a: 'Mostly the same things as before: smoking, alcohol, raw or '
            'half-cooked eggs and meat, and unboiled milk. Check every medicine '
            'with your doctor first, including herbal, ayurvedic and '
            'over-the-counter ones. Leave heavy lifting, like a full bucket or '
            'a gas cylinder, to someone else.',
      ),
      PregWeekQuestion(
        q: 'My bump looks smaller than other women\'s at 18 weeks. Is that okay?',
        a: 'Usually, yes. Bumps at the same week look very different, '
            'depending on your height, your muscles, how your baby is lying '
            "and whether you've been pregnant before. Your doctor checks your "
            "baby's growth at each visit and on the scan, and those are the "
            'measurements that count.',
      ),
    ],
    sources: ['mohfw_anc', 'mohfw_pmsma', 'nice_ng201', 'who_anc', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------- week 19
  PregWeekExtra(
    week: 19,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Stronger stretching sensations',
        tip: 'The ligaments that hold your uterus are stretching as it grows. A '
            'brief, sharp pull at the side when you cough or turn is common: '
            'move slowly, and bend towards the pain to ease it.',
        symptomId: 'roundLigament',
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'A warm (not hot) water bottle on your lower back eases the ache. '
            'At night, sleep on your side with a pillow between your knees to '
            'keep your back straight.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Growing bump',
        tip: 'The top of your uterus is close to your belly button now. At your '
            "visits, your doctor feels your bump to check how your baby is "
            'growing.',
      ),
      PregWeekSymptomTip(
        symptom: 'Increased appetite',
        tip: 'Smaller meals, more often, help with both hunger and heartburn. '
            'Add some protein, like dal, paneer, curd or eggs, so a meal keeps '
            'you full for longer.',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'Why is there a dark line down my belly?',
        a: "It's called the linea nigra. Pregnancy hormones make your skin "
            'produce more pigment, so it often shows clearly on brown skin, '
            'along with darker nipples and underarms. It fades slowly in the '
            "months after birth, so there's nothing to scrub or bleach.",
      ),
      PregWeekQuestion(
        q: 'Is it safe to travel in these middle months?',
        a: 'For most women, yes, and the middle months are often the easiest '
            'time to travel. On a long car or train ride, wear the lap belt '
            'under your bump, and get up to walk and drink water every hour '
            "or two. Check with your doctor before you book, especially if "
            "you've had any complication, and check the airline's rules, "
            "since many ask for a doctor's letter later in pregnancy.",
      ),
    ],
    sources: ['mohfw_anc', 'nice_ng201', 'acog_month', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------- week 20
  PregWeekExtra(
    week: 20,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Stronger fetal movements',
        tip: 'What began as flutters may now feel like clear taps and rolls, '
            "often when you lie down in the evening. If you haven't felt much "
            "yet, that's common, especially in a first pregnancy.",
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'Pregnancy hormones loosen your joints to make room for your baby, '
            'which adds to back strain. Gentle stretching on all fours, arching '
            "and then rounding your back, can ease it, as long as it doesn't "
            'hurt.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Stretching sensations in the abdomen',
        tip: 'As your uterus grows past your belly button, the ligaments around '
            'it stretch. A pull that lasts seconds is normal. Pain that stays, '
            'comes in waves or comes with bleeding needs a call to your doctor '
            'the same day.',
        symptomId: 'roundLigament',
      ),
      PregWeekSymptomTip(
        symptom: 'Increased appetite',
        tip: "You don't need to eat for two. Add a small extra meal, and ask "
            'your doctor what weight gain is right for you.',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'Am I really halfway?',
        a: 'Yes, by the way doctors count. Pregnancy is counted from the first '
            'day of your last period, about two weeks before you conceived, so '
            'a full-term pregnancy is about 40 weeks. If a scan changed your '
            "due date, go by the new date, because it's the one your doctor "
            'uses.',
      ),
      PregWeekQuestion(
        q: 'What if the scan shows something?',
        a: 'Most anomaly scans are reassuring. If something needs a closer '
            'look, the usual next step is a repeat scan or a scan with a fetal '
            'medicine specialist, and some findings turn out to be minor or '
            'settle on their own. Ask your doctor to explain what was seen and '
            'what it means for you, and take someone with you to that talk.',
      ),
      PregWeekQuestion(
        q: 'Why do I feel kicks some days and not others?',
        a: 'Your baby has lots of room now and no set routine yet, so quiet '
            'days are common. A regular pattern usually settles in over the '
            "next few weeks. Once you know your baby's pattern, a change in it "
            'or a slowing down is a reason to call your doctor straight away.',
      ),
    ],
    sources: ['mohfw_anc', 'nice_ng201', 'rcog_rfm', 'acog_month', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------- week 21
  PregWeekExtra(
    week: 21,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Noticeable baby movements',
        tip: 'Kicks may now come often enough to notice through the day. '
            "There's no number to count yet. For now, enjoy getting to know "
            'them.',
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'Carry bags on both sides rather than one heavy bag on one '
            'shoulder. Ask someone else to carry the full bucket or lift the '
            'gas cylinder.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Increased appetite',
        tip: "Some days you'll be hungrier than others, and that's normal. "
            'Have a glass of water first when a craving hits, since thirst can '
            'feel like hunger.',
      ),
      PregWeekSymptomTip(
        symptom: 'Mild leg cramps',
        tip: 'A cramp often wakes you at night with a tight calf. Pull your toes '
            'up towards your knee and hold until it eases, then walk around a '
            'little.',
        symptomId: 'legCramps',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'Which way is my baby lying now?',
        a: "Any way at all: head up, head down or sideways. There's plenty of "
            'room at 21 weeks, and your baby turns many times a day. Most '
            'babies settle head down in the last weeks, and your doctor checks '
            'the position then.',
      ),
      PregWeekQuestion(
        q: 'Why do I feel off balance?',
        a: 'Your growing bump moves your centre of balance forward, and '
            'pregnancy hormones loosen your joints. Wear chappals with a good '
            'grip, take care on wet bathroom floors and stairs, and hold the '
            'railing. If you fall onto your bump, call your doctor the same day '
            'even if you feel fine, and straight away if there\'s bleeding, '
            'pain or leaking fluid.',
      ),
    ],
    sources: ['mohfw_anc', 'nice_ng201', 'acog_month', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------- week 22
  PregWeekExtra(
    week: 22,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Stronger kicks',
        tip: 'Your baby is bigger and moves with more force, so you may feel '
            "kicks when you're sitting still or lying down. Many babies are "
            "busiest when you're resting.",
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'Ask for help with heavy jobs around the house, like moving '
            'furniture. A firm chair with a straight back is kinder to your '
            'back than a soft sofa.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Stretching sensations',
        tip: 'A quick, sharp pull low on one side when you stand or sneeze is '
            'your ligaments stretching. Supporting your bump with a hand, or a '
            'belly band, can help.',
        symptomId: 'roundLigament',
      ),
      PregWeekSymptomTip(
        symptom: 'Occasional leg cramps',
        tip: 'Stretch your calves for a minute before bed. If a leg is red, '
            'swollen, warm or painful rather than cramped, call your doctor '
            'straight away.',
        symptomId: 'legCramps',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'When does the third trimester start?',
        a: "Most doctors count it from 28 weeks, and some from 27, so you're "
            'five or six weeks away. It\'s the stretch when your baby puts on '
            'most of their weight and gets ready for birth. Your check-ups '
            'usually come more often from then on.',
      ),
      PregWeekQuestion(
        q: 'Is it normal for my interest in sex to change?',
        a: 'Yes, in either direction. More blood flows to your pelvis in the '
            'middle months, and some women want sex more while others want it '
            'less. In a healthy pregnancy sex is safe, but ask your doctor '
            "first if you've had bleeding or leaking fluid, or been told your "
            'placenta is low.',
      ),
    ],
    sources: ['mohfw_anc', 'nice_ng201', 'acog_month', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------- week 23
  PregWeekExtra(
    week: 23,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Noticeable kicks',
        tip: 'Sometimes you can see a kick ripple across your bump now. Your '
            'partner may feel one too, if they keep a hand still on your bump '
            'for a while.',
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'Stand with your weight on both feet, not on one hip. A pregnancy '
            'yoga or physiotherapy class can teach you stretches that are safe '
            'for your back.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Leg cramps',
        tip: 'Before bed, stand an arm\'s length from a wall and lean in with '
            'your heels down to stretch your calves. It takes a minute and can '
            'head off a cramp in the night.',
        symptomId: 'legCramps',
      ),
      PregWeekSymptomTip(
        symptom: 'Increased appetite',
        tip: 'Pick snacks that keep you full, like peanuts, sprouts chaat or a '
            'glass of buttermilk. Fried namkeen and sweets fill you briefly and '
            'bring the hunger back sooner.',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'Why are my breasts leaking?',
        a: 'From the middle months your breasts start making colostrum, the '
            'first milk, and a few yellowish, sticky drops may leak. Some women '
            "leak and some don't, and neither says anything about how "
            'breastfeeding will go. Breast pads help, and tell your doctor if '
            'the fluid is blood-stained.',
      ),
      PregWeekQuestion(
        q: 'Are these tightenings normal?',
        a: 'Usually, yes. Practice tightenings (Braxton Hicks) can start around '
            'now: your bump goes hard for a short while, on and off with no '
            'pattern, and it eases when you rest, change position or drink '
            'water. Before 37 weeks, call your doctor or go to the labour ward '
            'straight away if tightenings come regularly or get stronger, or '
            'come with period-like pain, a low backache, bleeding or leaking '
            'fluid.',
      ),
    ],
    sources: ['mohfw_anc', 'nice_ng201', 'acog_month', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------- week 24
  PregWeekExtra(
    week: 24,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Noticeable kicks',
        tip: 'Your baby now has times of sleep and times of activity, so kicks '
            'come in busy spells with quiet gaps between. Noticing when they '
            "come is the start of knowing your baby's pattern.",
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'When you get out of bed, roll onto your side first and push up '
            'with your arms. It saves your back and your tummy muscles a '
            'strain.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Leg cramps',
        tip: 'Cramps get more common from now on, often at night. Keep drinking '
            'water through the day, and mention it at your next visit if they '
            'come often.',
        symptomId: 'legCramps',
      ),
      PregWeekSymptomTip(
        symptom: 'Mild swelling in feet',
        tip: 'Some swelling by evening is common, more so in hot weather, so put '
            'your feet up when you can. Call your doctor straight away if your '
            'face or hands swell suddenly, or swelling comes with a headache '
            'or blurred vision.',
        symptomId: 'swelling',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'What is the glucose test?',
        a: 'It checks for gestational diabetes, a rise in blood sugar that some '
            "women get in pregnancy. It's common in India, so every pregnant "
            'woman is tested, usually at the first visit and again between 24 '
            'and 28 weeks. You drink a measured glucose drink and a blood '
            'sample is taken, often two hours later, but some labs ask you to '
            'come fasting and take more samples, so ask how yours is done.',
      ),
      PregWeekQuestion(
        q: 'Why do doctors call 24 weeks a milestone?',
        a: 'From around 24 weeks, some babies born very early can survive with '
            'intensive newborn care, so doctors see it as a turning point. '
            "It's still early, and every extra week in the womb matters for "
            "your baby's lungs and brain. From now on, signs of labour starting "
            'early, like regular tightenings, a gush of fluid or bleeding, need '
            'a call to your doctor or the labour ward straight away.',
      ),
    ],
    sources: ['mohfw_anc', 'mohfw_pmsma', 'nice_ng201', 'who_anc', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------- week 25
  PregWeekExtra(
    week: 25,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Stronger kicks',
        tip: 'Kicks can now be strong enough to startle you, or to wake you at '
            'night. Changing position or a slow walk sometimes settles a busy '
            'baby.',
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'A warm compress and a pillow behind you when you sit both help. '
            'If backache comes and goes in a rhythm, like period pains, call '
            'your doctor straight away, as it can be a sign of early labour.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Heartburn',
        tip: 'Your uterus presses up on your stomach, and hormones loosen the '
            'valve at its top. Eat smaller meals, keep dinner early, and ask '
            'your doctor before taking an antacid.',
        symptomId: 'heartburn',
      ),
      PregWeekSymptomTip(
        symptom: 'Leg cramps',
        tip: 'Pointing your toes when you stretch in bed can set off a cramp. '
            'Flex your feet up towards you instead.',
        symptomId: 'legCramps',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "Why can't I keep my legs still at night?",
        a: 'That restless, crawly urge to move your legs is common in the '
            'second half of pregnancy, and usually worst in the evening. Low '
            'iron can be behind it, so keep taking your iron tablets and '
            'mention it at your next visit, where a blood test can check your '
            'level. Stretching your calves, a warm bath and less chai after '
            'noon may also help.',
      ),
      PregWeekQuestion(
        q: 'When is swelling a worry?',
        a: 'Some swelling of the feet and ankles, worse by evening and in the '
            'heat, is common and eases when you rest with your feet up. Call '
            'your doctor straight away if your face, hands or feet swell '
            'suddenly, or swelling comes with a bad headache, blurred vision '
            'or pain under your ribs. These can be signs of high blood '
            'pressure in pregnancy (pre-eclampsia), which needs checking '
            'quickly.',
      ),
    ],
    sources: ['mohfw_anc', 'icmr_nin', 'nice_ng201', 'acog_month'],
  ),

  // ---------------------------------------------------------------- week 26
  PregWeekExtra(
    week: 26,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Stronger kicks',
        tip: 'Your baby is close to a kilo now, so movements feel bigger: rolls, '
            'stretches and jabs. You may notice more of them after you eat or '
            'when you lie down.',
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'After a day on your feet, lie on your side for twenty minutes with '
            'a pillow under your bump and one between your knees. If the ache '
            'stays, a physiotherapist can show you safe exercises.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Heartburn',
        tip: 'Spicy, oily or very sour food, and tea or coffee, are common '
            'triggers. Sitting upright for an hour after meals helps, and a '
            'glass of cold milk can ease it for a while.',
        symptomId: 'heartburn',
      ),
      PregWeekSymptomTip(
        symptom: 'Leg cramps',
        tip: 'If cramps keep waking you, mention it at your next visit so your '
            'doctor can look at what might help.',
        symptomId: 'legCramps',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'Do I still need my iron and calcium tablets?',
        a: 'Yes. In India most women are given a daily iron and folic acid '
            'tablet and a calcium tablet from the fourth month, and they matter '
            "even more now as your blood volume and your baby's bones grow. "
            'Take them at different times, because calcium blocks iron: iron '
            'with something that has vitamin C and away from tea, calcium with '
            'another meal.',
      ),
      PregWeekQuestion(
        q: 'What are the signs of labour starting too early?',
        a: 'Before 37 weeks, watch for tightenings that come regularly or get '
            'stronger, period-like cramps, a dull low backache that comes and '
            'goes, pressure low in your pelvis, a gush or trickle of fluid, '
            'bleeding, or a change in your discharge. If you notice any of '
            'these, call your doctor or the labour ward straight away. '
            "Don't wait to see if it settles.",
      ),
      PregWeekQuestion(
        q: 'Is the urge to clean and get ready normal?',
        a: 'Yes. Many women feel a strong pull to sort the house and get the '
            "baby's things ready (nesting), sometimes now and often nearer "
            'the end. Enjoy it, and leave ladders, heavy lifting and strong '
            'cleaning chemicals to someone else.',
      ),
    ],
    sources: ['mohfw_anc', 'icmr_nin', 'who_anc', 'nice_ng201', 'acog_month'],
  ),

  // ---------------------------------------------------------------- week 27
  PregWeekExtra(
    week: 27,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Stronger fetal movements',
        tip: 'You may see your whole bump shift when your baby turns. Small, '
            'rhythmic jerks that come in a run are usually hiccups.',
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip: 'Your baby is putting on weight fast, and so is the pull on your '
            'back. A maternity support belt can take some of the load when '
            "you're on your feet.",
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Heartburn',
        tip: 'Finish dinner two to three hours before bed, and prop yourself up '
            "with an extra pillow at night. If it's severe or stops you eating "
            'properly, tell your doctor.',
        symptomId: 'heartburn',
      ),
      PregWeekSymptomTip(
        symptom: 'Difficulty finding comfortable sleeping positions',
        tip: 'A long body pillow, or a rolled razai tucked behind your back, '
            "stops you rolling over. If you can't settle, get up for a while "
            'and try again, rather than lying awake.',
        symptomId: 'troubleSleeping',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'Which side should I sleep on?',
        a: 'From 28 weeks, doctors advise going to sleep on your side, because '
            'lying flat on your back lets the weight of your uterus press on '
            'large blood vessels. Your left side is often suggested, but '
            "either side is fine. If you wake up on your back, that's all "
            'right: turn onto your side and settle again.',
      ),
      PregWeekQuestion(
        q: 'What changes in the third trimester?',
        a: 'Your check-ups come more often, usually every two weeks and then '
            'every week near the end, though your doctor sets your plan. Your '
            'blood count and blood pressure are checked again, and many women '
            'have a growth scan. If your blood group is negative, your doctor '
            'may talk about an anti-D injection around 28 weeks, and some '
            'offer a whooping cough vaccine (Tdap) between 27 and 36 weeks.',
      ),
    ],
    sources: ['mohfw_anc', 'mohfw_pmsma', 'nice_ng201', 'acog_month', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------- week 28
  PregWeekExtra(
    week: 28,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Stronger fetal movements',
        tip: "From now, get to know your baby's usual pattern of movement. If "
            'it slows down, changes or stops, call your doctor or maternity '
            'unit straight away, day or night.',
      ),
      PregWeekSymptomTip(
        symptom: 'Back pain',
        tip: 'Sit with support behind your lower back, and ask about a '
            "maternity belt or a physiotherapist if it's getting in the way of "
            'your day. Severe or sudden pain, or pain that comes in waves, '
            'needs a call to your doctor.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Heartburn',
        tip: 'Heartburn often peaks in the last three months as your baby '
            'pushes up. Small meals through the day, and waiting before you '
            'lie down, usually help more than cutting out one food.',
        symptomId: 'heartburn',
      ),
      PregWeekSymptomTip(
        symptom: 'Sleep disturbances',
        tip: 'Kicks, trips to the toilet and a big bump all break sleep now. '
            'Drink most of your water earlier in the day, and rest in the '
            'afternoon if you can.',
        symptomId: 'troubleSleeping',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'Should I start counting kicks?',
        a: "From about 28 weeks, many doctors ask you to notice your baby's "
            "movements every day. There's no number that's right for every "
            "baby: what matters is knowing your own baby's pattern, and the "
            'Baby Movement Tracker in Tools can help you learn it. If the '
            'movements slow down, change or stop, call your doctor or '
            'maternity unit straight away, even at night, rather than waiting '
            'for the next day.',
      ),
      PregWeekQuestion(
        q: 'Why am I so tired again?',
        a: 'Tiredness often comes back in the last three months, with a '
            'heavier body, broken sleep and a baby growing fast. Anaemia can '
            'add to it, which is why your blood count is checked again around '
            'now, so keep taking your iron tablets. If you feel breathless, '
            'dizzy or far more worn out than usual, tell your doctor.',
      ),
      PregWeekQuestion(
        q: 'Why is my skin so itchy?',
        a: 'As your belly and breasts stretch, the skin gets dry and itchy, and '
            'a thick unscented moisturiser after your bath and loose cotton '
            'help. Itching on your palms and soles, worse at night, is '
            'different: call your doctor today, because it needs a blood test '
            'the same day.',
      ),
    ],
    sources: ['mohfw_anc', 'rcog_rfm', 'nice_ng201', 'acog_month', 'moore_embryology'],
  ),
];
