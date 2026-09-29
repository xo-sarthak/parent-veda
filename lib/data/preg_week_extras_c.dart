// Part c of the week page extras (weeks 29 to 40). See preg_week_extras.dart.
//
// Written 2026-09-29 to docs/PREG-VOICE.md. Each week's `symptomTips` pair
// with `momJourney.commonSymptoms` in weekContent.json by their English label;
// test/preg_week_extras_c_test.dart holds that pairing.
import 'preg_week_extras.dart';

const List<PregWeekExtra> kPregWeekExtrasC = [
  // ---- week 29 ----
  PregWeekExtra(
    week: 29,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Frequent urination',
        tip:
            'Your bump now presses on your bladder. Keep drinking through the day, and drink a little less in the two hours before bed.',
        symptomId: 'frequentUrination',
      ),
      PregWeekSymptomTip(
        symptom: 'Heartburn',
        tip:
            'Wait two hours after eating before you lie down, and raise the head of your bed a little. A glass of cold milk soothes it for many women.',
        symptomId: 'heartburn',
      ),
      PregWeekSymptomTip(
        symptom: 'Shortness of breath',
        tip:
            'Your uterus now pushes up towards your lungs. Take stairs slowly, and sit up tall to give your lungs more room.',
        symptomId: 'breathlessness',
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip:
            'Your bump pulls your posture forward. Keep a small cushion behind your lower back when you sit, and bend your knees, not your back, to pick things up.',
        symptomId: 'backPain',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "How do I keep track of my baby's movements?",
        a: "Get to know your baby's own pattern: when they're busy and how it feels. There's no set number to count, and movements shouldn't slow down as you get closer to the birth. If they slow down or change, call your hospital straight away, day or night, and don't wait until the next day.",
      ),
      PregWeekQuestion(
        q: 'Which way up is my baby at 29 weeks?',
        a: "Any way at all. About one in five babies is still bottom-down (breech) around 28 weeks, and there's plenty of room left to turn. Most turn head-down by themselves, and your doctor checks the position again at around 36 weeks.",
      ),
      PregWeekQuestion(
        q: 'Is it all right to sleep on my back now?',
        a: "From 28 weeks, go to sleep on your side, and either side is fine. If you wake up on your back, turn onto your side; you haven't done any harm. A pillow tucked behind your back helps you stay there.",
      ),
    ],
    sources: ['mohfw_anc', 'who_anc', 'nice_ng201', 'rcog_rfm', 'acog_month'],
  ),
  // ---- week 30 ----
  PregWeekExtra(
    week: 30,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Shortness of breath',
        tip:
            'Sleeping propped up on a couple of pillows makes breathing easier at night. Breathlessness that comes on suddenly, or with chest pain or a racing heart, needs a doctor now.',
        symptomId: 'breathlessness',
      ),
      PregWeekSymptomTip(
        symptom: 'Heartburn',
        tip:
            'Fried or spicy food, strong tea and coffee often set it off. Ask your doctor before taking any antacid, even a common one from the chemist.',
        symptomId: 'heartburn',
      ),
      PregWeekSymptomTip(
        symptom: 'Back pain',
        tip:
            'A warm (not hot) water bottle and a gentle massage from someone at home often ease it. Flat, cushioned chappals are kinder to your back than heels.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Difficulty sleeping',
        tip:
            "Go to sleep on your side, with a pillow between your knees. If you wake on your back, turn over; it isn't a cause for worry.",
        symptomId: 'troubleSleeping',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'My feet swell by evening. Is that normal?',
        a: 'Yes, mild swelling of the feet and ankles is common now, and worse on hot days or after standing. Put your feet up, lie on your side and keep drinking water. Swelling that comes on suddenly, or in your face or hands, or with a headache or blurred vision, needs a call to your doctor straight away.',
      ),
      PregWeekQuestion(
        q: 'When should we start childbirth classes?',
        a: "Around now is a good time, so you finish well before your due date. Many hospitals in India run antenatal classes, and your husband or a family member can often come too. You'll learn the signs of labour, how to breathe through contractions and how the first feeds go.",
      ),
      PregWeekQuestion(
        q: 'How often will I see my doctor from now on?',
        a: "Many doctors in India see you every two weeks from about 28 weeks, then every week from 36. Your own doctor may plan it differently, and their plan is the one to follow. Each visit checks your blood pressure, urine and weight, and your baby's growth and heartbeat.",
      ),
    ],
    sources: ['mohfw_anc', 'who_anc', 'nice_ng201', 'acog_month'],
  ),
  // ---- week 31 ----
  PregWeekExtra(
    week: 31,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Difficulty sleeping',
        tip:
            'A pillow behind your back and one under your bump help you stay comfortable on your side. A calm half hour before bed, with a warm glass of milk, helps many women settle.',
        symptomId: 'troubleSleeping',
      ),
      PregWeekSymptomTip(
        symptom: 'Back pain',
        tip:
            'Gentle stretches on your hands and knees, rounding and then flattening your back, can ease stiffness. A pregnancy yoga class can show you more.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Heartburn',
        tip:
            'Have dinner early, at least two hours before bed. Sip water between meals rather than with them.',
        symptomId: 'heartburn',
      ),
      PregWeekSymptomTip(
        symptom: 'Shortness of breath',
        tip:
            'Low iron can make you more breathless, so keep taking your iron tablets as prescribed. Lifting your arms above your head for a few breaths gives your lungs more room.',
        symptomId: 'breathlessness',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'Which way up is my baby at 31 weeks?',
        a: "Many babies are head-down by now, but plenty aren't, and that's normal at this stage. Your baby still has room to turn, and most do by themselves in the coming weeks. Your doctor will feel your bump to check at around 36 weeks.",
      ),
      PregWeekQuestion(
        q: 'My bump keeps going hard. What is that?',
        a: "Those are practice tightenings (Braxton Hicks): your whole bump firms up for under a minute, then softens. They come and go without a pattern and usually don't hurt. If they become regular or painful before 37 weeks, call your hospital straight away.",
      ),
      PregWeekQuestion(
        q: 'If my baby came now, would they be all right?',
        a: 'A baby born at 31 weeks is premature and needs care in a newborn unit (NICU or SNCU) for a while, for breathing, warmth and feeding. Most babies born at this stage do well with that care. Every extra week inside helps, which is why early signs of labour always need a call.',
      ),
    ],
    sources: ['mohfw_anc', 'who_anc', 'acog_month', 'moore_embryology'],
  ),
  // ---- week 32 ----
  PregWeekExtra(
    week: 32,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Frequent urination',
        tip:
            'Lean forward on the toilet so your bladder empties fully. If it burns or stings when you pee, tell your doctor the same day, as a urine infection needs treating.',
        symptomId: 'frequentUrination',
      ),
      PregWeekSymptomTip(
        symptom: 'Shortness of breath',
        tip:
            "Walk and talk at an easy pace, and if you can't finish a sentence, slow down. It usually eases in the last weeks, once your baby drops lower.",
        symptomId: 'breathlessness',
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip:
            'Sitting on the floor for long can strain your back now. Use a chair with good back support, and get up to stretch every half hour.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Difficulty sleeping',
        tip:
            'If a busy mind keeps you up, put your phone away for the last half hour and keep the room dark. Nap in the day when you can.',
        symptomId: 'troubleSleeping',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'When should I pack my hospital bag?',
        a: 'Start now, and have it ready by 36 weeks. Put in your hospital file, all your reports and scans, ID and insurance papers, loose front-opening nighties, maternity pads, and a few soft baby clothes with a cap, socks and a swaddle. Keep your phone charger on the list for the last minute.',
      ),
      PregWeekQuestion(
        q: "What's this ache at the front of my pelvis?",
        a: "It's often pelvic girdle pain: the joints of your pelvis loosen to make room for your baby, and they ache. Keep your knees together when you turn in bed or get out of a car, and take stairs one step at a time. A physiotherapist who knows pregnancy can help, so ask your doctor for a referral.",
      ),
      PregWeekQuestion(
        q: "I'm going to my mother's home for the delivery. What should I sort out?",
        a: 'Plan to travel before about 34 weeks, and ask your doctor first. Take your full file and a summary letter from your doctor, and book a visit at the new hospital as soon as you arrive so they know you before labour. Many airlines ask for a fitness letter late in pregnancy, so check before you book.',
      ),
    ],
    sources: ['mohfw_anc', 'mohfw_pmsma', 'nice_ng201', 'acog_month'],
  ),
  // ---- week 33 ----
  PregWeekExtra(
    week: 33,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Pelvic pressure',
        tip:
            'A heavy feeling low down is common as your baby grows. If it comes with regular tightenings, leaking fluid or bleeding, call your hospital now.',
        symptomId: 'pelvicPressure',
      ),
      PregWeekSymptomTip(
        symptom: 'Shortness of breath',
        tip:
            'Heat makes breathing feel harder, so sit under a fan or near an open window on hot days. Sudden breathlessness with chest pain or blue lips needs a doctor now.',
        symptomId: 'breathlessness',
      ),
      PregWeekSymptomTip(
        symptom: 'Back discomfort',
        tip:
            'Lifting heavy bags or an older child strains your back now. Ask for help with lifting, and keep things you use every day at waist height.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Fatigue',
        tip:
            'Your body is carrying more and your sleep is broken, so tiredness is expected. A short rest after lunch with your feet up can make evenings easier.',
        symptomId: 'fatigue',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'If my baby is born at 33 weeks, will they be all right?',
        a: "Babies born at 33 weeks are premature, but most do well. Many need a few days or weeks in a newborn unit for help with breathing, feeding or keeping warm. If early labour looks likely before 34 weeks, doctors often give you steroid injections to help your baby's lungs.",
      ),
      PregWeekQuestion(
        q: 'Why do my hips hurt at night?',
        a: 'Lying on your side puts your weight on one hip, and your loosened joints feel it more now. A pillow between your knees and a folded quilt under your hip spread the pressure. Turning onto the other side for a while helps too.',
      ),
      PregWeekQuestion(
        q: "Should my baby's movements feel different now?",
        a: "They often do: more rolls, pushes and stretches than sharp kicks, as there's less room. But they shouldn't become fewer or weaker. If they slow down or change, call your hospital straight away, day or night.",
      ),
    ],
    sources: [
      'mohfw_anc',
      'who_anc',
      'rcog_rfm',
      'acog_month',
      'moore_embryology',
    ],
  ),
  // ---- week 34 ----
  PregWeekExtra(
    week: 34,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Pelvic pressure',
        tip:
            'A maternity support belt from the chemist takes some weight off when you walk. Rest on your side with your feet up when the heaviness builds.',
        symptomId: 'pelvicPressure',
      ),
      PregWeekSymptomTip(
        symptom: 'Back pain',
        tip:
            'Back pain that comes in waves, in a regular rhythm, can be early labour. Before 37 weeks, call your hospital straight away if you notice that.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Heartburn',
        tip:
            "Your baby is pressing up on your stomach, so eat slowly and stop before you feel full. If it's keeping you awake, your doctor can suggest a safe antacid.",
        symptomId: 'heartburn',
      ),
      PregWeekSymptomTip(
        symptom: 'Fatigue',
        tip:
            'If you feel exhausted all the time, breathless or dizzy, ask your doctor to check your haemoglobin. Anaemia is common in pregnancy in India, and a blood test shows it.',
        symptomId: 'fatigue',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'My breasts are leaking. Is that normal?',
        a: "Yes. That's colostrum, your baby's first milk, and it can be yellow and sticky. Some women leak and many don't, and neither says anything about how feeding will go. Breast pads, or a folded soft cotton cloth inside your bra, help.",
      ),
      PregWeekQuestion(
        q: 'How can I ease constipation?',
        a: "Drink plenty of water and add fibre: fruit like guava and pear, vegetables, dalia and whole dals. Iron tablets can make it worse, but don't stop them; ask your doctor about a gentle remedy such as isabgol. Moving every day helps too.",
      ),
      PregWeekQuestion(
        q: 'My vision seems blurry. Should I be worried?',
        a: 'Mild blurring or dry eyes can happen in pregnancy and usually go after the birth. But blurring that comes on suddenly, flashing lights, or blurring with a bad headache or swelling can be a sign of high blood pressure (pre-eclampsia). Call your doctor straight away if you notice any of these.',
      ),
    ],
    sources: ['mohfw_anc', 'icmr_nin', 'nice_ng201', 'acog_month'],
  ),
  // ---- week 35 ----
  PregWeekExtra(
    week: 35,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Pelvic pressure',
        tip:
            'Sitting on a birthing ball, or leaning forward over the back of a chair, takes weight off your pelvis. Pressure with regular tightenings or fluid before 37 weeks needs a call now.',
        symptomId: 'pelvicPressure',
      ),
      PregWeekSymptomTip(
        symptom: 'Frequent urination',
        tip:
            "Your baby's head is moving lower onto your bladder. Don't cut down on water to go less often, because your body and your baby need it.",
        symptomId: 'frequentUrination',
      ),
      PregWeekSymptomTip(
        symptom: 'Back pain',
        tip:
            'Stand tall and tuck your bottom in a little, as slouching makes it worse. A support belt for walking helps some women.',
        symptomId: 'backPain',
      ),
      PregWeekSymptomTip(
        symptom: 'Braxton Hicks contractions',
        tip:
            'Your bump goes hard for under a minute, then softens. Drink some water and change position, and if they become regular before 37 weeks, call your hospital straight away.',
        symptomId: 'braxtonHicks',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'How can I tell practice tightenings from real labour?',
        a: 'Practice tightenings come and go without a pattern and ease when you rest, walk or drink water. Labour contractions come regularly, get closer together, last longer and get stronger, whatever you do. Before 37 weeks, regular tightenings mean calling your hospital straight away.',
      ),
      PregWeekQuestion(
        q: 'Is my baby head-down yet?',
        a: "Many babies settle head-down around now. Your doctor will feel your bump at around 36 weeks, and may check with a scan if they're unsure. If your baby is still bottom-down (breech), they'll talk you through the choices.",
      ),
      PregWeekQuestion(
        q: 'Why do I leak a little when I cough or sneeze?',
        a: "Your baby is pressing on your bladder, and your pelvic floor muscles are softer now. Squeeze those muscles a few times a day, as if holding in a pee, and wear a panty liner. A steady trickle you can't stop could be your waters, so call your hospital.",
      ),
    ],
    sources: ['mohfw_anc', 'nice_ng201', 'rcog_rfm', 'acog_month'],
  ),
  // ---- week 36 ----
  PregWeekExtra(
    week: 36,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Pelvic pressure',
        tip:
            "Your baby may be moving down into your pelvis. It's heavier below, but many women find breathing and eating get easier.",
        symptomId: 'pelvicPressure',
      ),
      PregWeekSymptomTip(
        symptom: 'Waddling walk',
        tip:
            'Your pelvis loosens and your baby sits lower, so your walk changes. If it hurts at the front or back of your pelvis, a pregnancy physiotherapist can help.',
        symptomId: 'pelvicGirdle',
      ),
      PregWeekSymptomTip(
        symptom: 'Frequent urination',
        tip:
            'Once your baby drops, you may need the toilet every hour. When you go out, find the toilets first and carry water and tissues.',
        symptomId: 'frequentUrination',
      ),
      PregWeekSymptomTip(
        symptom: 'Braxton Hicks contractions',
        tip:
            "They're often stronger after a busy day or with a full bladder. Rest, drink some water and empty your bladder, and they usually settle.",
        symptomId: 'braxtonHicks',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'When does labour usually start?',
        a: 'Most babies arrive between 38 and 41 weeks, and only about 1 in 20 comes on the due date itself. Nobody can know your exact day. Keep your bag ready and your phone charged from now on.',
      ),
      PregWeekQuestion(
        q: 'What happens at my check-ups from now on?',
        a: "Most doctors see you every week now. They check your blood pressure, urine, weight, the height of your bump, your baby's heartbeat and which way up your baby is lying. Some hospitals also do an NST (non-stress test), where a belt on your bump records your baby's heartbeat for about 20 to 40 minutes.",
      ),
      PregWeekQuestion(
        q: 'What if my baby is still bottom-down?',
        a: "Only about 3 or 4 in 100 babies are still breech at full term, and some still turn. Your doctor may offer to turn your baby by pressing gently on your bump (external cephalic version), or talk with you about a planned caesarean. They'll help you decide what's right for you.",
      ),
    ],
    sources: [
      'mohfw_anc',
      'mohfw_pmsma',
      'nice_ng201',
      'who_intrapartum',
      'acog_month',
    ],
  ),
  // ---- week 37 ----
  PregWeekExtra(
    week: 37,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Pelvic pressure',
        tip:
            "A warm bath or shower and a rest on your side ease the heaviness. It usually means your baby's head is settling low, ready for birth.",
        symptomId: 'pelvicPressure',
      ),
      PregWeekSymptomTip(
        symptom: 'Braxton Hicks contractions',
        tip:
            'Time a few of them. Practice tightenings stay irregular and ease with rest, while labour contractions come regularly and get stronger.',
        symptomId: 'braxtonHicks',
      ),
      PregWeekSymptomTip(
        symptom: 'Frequent urination',
        tip:
            'Night trips are common now. Keep a small light on so you can get up safely, as your balance is different with a big bump.',
        symptomId: 'frequentUrination',
      ),
      PregWeekSymptomTip(
        symptom: 'Difficulty sleeping',
        tip:
            "Many women sleep in short stretches now. Rest in the day when you can, and don't count the hours at night, because lying still with your eyes closed helps too.",
        symptomId: 'troubleSleeping',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'What does full term mean?',
        a: "From 37 weeks your baby isn't counted as premature any more, and could be born any day. Babies still gain from each extra week, so doctors don't plan an early birth without a medical reason. Your doctor's dates are the ones to follow.",
      ),
      PregWeekQuestion(
        q: 'What are the signs labour is near?',
        a: 'Your baby may drop lower, so breathing gets easier and you pee more. You might notice more discharge, a jelly-like show, loose motions, or tightenings that start to settle into a rhythm. Call the labour ward when contractions become regular, your waters break, you bleed, or your baby moves less.',
      ),
      PregWeekQuestion(
        q: 'Should I still keep an eye on movements?',
        a: 'Yes, right up to the birth. Your baby should keep moving as much as before, even if it feels more like rolling and pushing. If the movements slow down or change, call your hospital straight away, day or night.',
      ),
    ],
    sources: [
      'mohfw_anc',
      'who_intrapartum',
      'nice_ng201',
      'rcog_rfm',
      'acog_month',
    ],
  ),
  // ---- week 38 ----
  PregWeekExtra(
    week: 38,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Pelvic pressure',
        tip:
            'Several short rests through the day help more than one long one. Pelvic floor squeezes help your muscles carry the extra weight.',
        symptomId: 'pelvicPressure',
      ),
      PregWeekSymptomTip(
        symptom: 'Braxton Hicks contractions',
        tip:
            "They can feel stronger and more uncomfortable now. If they come regularly and don't settle with rest, call the labour ward.",
        symptomId: 'braxtonHicks',
      ),
      PregWeekSymptomTip(
        symptom: 'Difficulty sleeping',
        tip:
            "If you can't sleep after 20 minutes, get up, sit somewhere quiet and come back when you feel sleepy. Lying there worrying makes it harder.",
        symptomId: 'troubleSleeping',
      ),
      PregWeekSymptomTip(
        symptom: 'Frequent urination',
        tip:
            "Keep drinking even though it means more trips. Clear or pale yellow pee tells you you're drinking enough.",
        symptomId: 'frequentUrination',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'Why does my belly go hard?',
        a: "It's usually practice tightenings (Braxton Hicks), which can feel stronger this late. They stay irregular and ease with rest, a change of position or a glass of water. When they come regularly and get closer together and stronger, labour may be starting.",
      ),
      PregWeekQuestion(
        q: 'What is the show (the mucus plug)?',
        a: "It's a plug of thick mucus that seals your cervix, and it can come away as a jelly-like blob, clear, pink or streaked with a little blood. Labour may follow within hours, or not for days. Bleeding like a period isn't a show, so go to the hospital straight away.",
      ),
      PregWeekQuestion(
        q: 'When should I go to the hospital?',
        a: "Your hospital will tell you when to come in, often when contractions are about five minutes apart and regular for an hour. Go sooner if your waters break, you bleed, your baby moves less, or you have a severe headache or blurred vision. Call before you set off so they're ready for you.",
      ),
    ],
    sources: ['mohfw_anc', 'who_intrapartum', 'rcog_rfm', 'acog_month'],
  ),
  // ---- week 39 ----
  PregWeekExtra(
    week: 39,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Pelvic pressure',
        tip:
            "Sharp, brief twinges low down are common as your baby's head presses on nerves. Changing position usually eases them.",
        symptomId: 'pelvicPressure',
      ),
      PregWeekSymptomTip(
        symptom: 'Braxton Hicks contractions',
        tip:
            "Breathing slowly through them is good practice for labour. If they come regularly, get closer together, or you're not sure, call the labour ward.",
        symptomId: 'braxtonHicks',
      ),
      PregWeekSymptomTip(
        symptom: 'Difficulty sleeping',
        tip:
            "Try an early night, a short afternoon nap and a dark, cool room. Rest still counts, even when sleep doesn't come.",
        symptomId: 'troubleSleeping',
      ),
      PregWeekSymptomTip(
        symptom: 'Burst of nesting energy',
        tip:
            'Many women get a sudden urge to clean and get everything ready. Enjoy it, but leave ladders, heavy lifting and strong cleaning products to someone else.',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: 'How will I know if my waters have broken?',
        a: "It can be a gush, or a slow trickle you can't hold back. Wear a pad, note the time and the colour, and call your hospital even if you have no pain. If the fluid is green, brown or bloody, go in straight away.",
      ),
      PregWeekQuestion(
        q: 'Will ghee or castor oil help labour start?',
        a: "Many families give extra ghee in the ninth month, out of love, but it doesn't bring on labour or make it easier. A little as part of your food is fine, while a lot can add heartburn and weight. Don't take castor oil unless your doctor tells you to, as it can cause strong loose motions and dehydration.",
      ),
      PregWeekQuestion(
        q: 'What if I need a caesarean?',
        a: "Some births need one, planned or at short notice, and it's a safe, common operation. You're usually awake, with the lower half of your body numbed, and you can often hold your baby soon after. Recovery takes a few weeks, so line up help at home either way.",
      ),
    ],
    sources: [
      'mohfw_anc',
      'who_intrapartum',
      'nice_ng207',
      'rcog_rfm',
      'acog_month',
    ],
  ),
  // ---- week 40 ----
  PregWeekExtra(
    week: 40,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: 'Pelvic pressure',
        tip:
            'Gentle walks and rocking your hips on a birthing ball can feel good now. If the pressure starts coming and going in a pattern, time it, as it may be early labour.',
        symptomId: 'pelvicPressure',
      ),
      PregWeekSymptomTip(
        symptom: 'Irregular contractions',
        tip:
            'Tightenings that come and go without a pattern are often your body warming up. Rest, eat and drink, and when they become regular and stronger, call the labour ward.',
        symptomId: 'braxtonHicks',
      ),
      PregWeekSymptomTip(
        symptom: 'Difficulty sleeping',
        tip:
            'Waiting can keep your mind busy at night. Breathing slowly, in for a count of four and out for six, helps many women settle.',
        symptomId: 'troubleSleeping',
      ),
      PregWeekSymptomTip(
        symptom: 'Emotional ups and downs',
        tip:
            "Feeling tearful one hour and excited the next is common in the last days. Tell someone close how you feel, and tell your doctor if low mood or worry doesn't lift.",
        symptomId: 'moodSwings',
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "What happens if my baby hasn't come by the due date?",
        a: "It's very common, especially with a first baby. Your doctor will check you and your baby more often, sometimes with an NST or a scan, and talk to you about helping labour start (induction). Many hospitals offer this from about 41 weeks, and your doctor will decide the timing with you.",
      ),
      PregWeekQuestion(
        q: 'What can I do while I wait?',
        a: "Rest, eat and drink well, and take gentle walks if you feel like it. Keep your bag by the door and your phone charged. Keep noticing your baby's movements, and if they slow down or change, call your hospital straight away, day or night.",
      ),
      PregWeekQuestion(
        q: "I'm scared of labour. Is that normal?",
        a: 'Very normal, and saying it out loud helps. Ask your doctor what pain relief your hospital offers, such as an epidural, and whether you can have a birth companion with you. Many hospitals in India now let a woman you trust, like your mother or sister, stay with you in labour.',
      ),
    ],
    sources: [
      'mohfw_anc',
      'nice_ng207',
      'who_intrapartum',
      'rcog_rfm',
      'acog_month',
    ],
  ),
];
