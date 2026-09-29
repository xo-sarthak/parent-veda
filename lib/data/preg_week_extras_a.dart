// Part a of the week page extras. See preg_week_extras.dart.
//
// Weeks 4 to 16. Written 2026-09-29 to docs/PREG-VOICE.md, English only.
// Every `symptom` is the week's `momJourney.commonSymptoms[i].en` in
// weekContent.json, word for word; test/preg_week_extras_a_test.dart pairs
// them. Questions asked for the month or trimester are left out on purpose:
// the page's top line already answers them.
import 'preg_week_extras.dart';

const List<PregWeekExtra> kPregWeekExtrasA = [
  // ---- Week 4 ---------------------------------------------------------------
  PregWeekExtra(
    week: 4,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Missed period",
        tip: "A late period is often the first sign. A home test is most reliable from the day your period was due, with the first pee of the morning.",
      ),
      PregWeekSymptomTip(
        symptom: "Breast tenderness",
        tip: "Rising hormones can make your breasts feel full and sore, a lot like before a period. A soft cotton bra without underwire helps.",
        symptomId: "breasts",
      ),
      PregWeekSymptomTip(
        symptom: "Mild cramping",
        tip: "A light, period-like ache is common as your uterus starts to grow. Rest and a warm (not hot) water bottle on your lower back help.",
        symptomId: "cramps",
      ),
      PregWeekSymptomTip(
        symptom: "Fatigue",
        tip: "Progesterone rises fast now and can make you sleepy in the middle of the day. Rest when you can, as this early tiredness usually lifts in the second trimester.",
        symptomId: "fatigue",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "What does being 4 weeks pregnant mean?",
        a: "Pregnancy weeks are counted from the first day of your last period, not from the day you conceived. So at 4 weeks your baby has been growing for about two weeks, and your period is only just due. If a scan or your doctor gives you a different date later, that's the one to follow.",
      ),
      PregWeekQuestion(
        q: "When will I have a baby bump?",
        a: "Not for a while yet. Your uterus is still tucked inside your pelvis, and it grows up and out of it at around 12 weeks. In a first pregnancy most women start to show somewhere between 12 and 16 weeks, often sooner in a second, and every body is different.",
      ),
      PregWeekQuestion(
        q: "When should I see a doctor?",
        a: "Book a visit as soon as you know. India's antenatal guidelines ask for your first check-up within the first 12 weeks, and earlier is better. Your doctor confirms the pregnancy, checks basics like your blood pressure and haemoglobin, and makes sure you're taking folic acid.",
      ),
    ],
    sources: ["mohfw_anc", "who_anc", "nice_ng201", "acog_month", "moore_embryology"],
  ),

  // ---- Week 5 ---------------------------------------------------------------
  PregWeekExtra(
    week: 5,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Missed period",
        tip: "If you haven't tested yet, a home test is reliable by now. There's no need to keep repeating it, as your doctor will confirm it at your first visit.",
      ),
      PregWeekSymptomTip(
        symptom: "Tiredness",
        tip: "Your body is building the placenta and making more blood, and that's tiring work. Short rests and an earlier bedtime help more than pushing through.",
        symptomId: "fatigue",
      ),
      PregWeekSymptomTip(
        symptom: "Sore breasts",
        tip: "A soft, well-fitting cotton bra, worn at night too if it helps, takes the edge off. The soreness usually eases after the first trimester.",
        symptomId: "breasts",
      ),
      PregWeekSymptomTip(
        symptom: "Needing to wee more",
        tip: "Your kidneys are filtering more blood, and your growing uterus presses on your bladder. Keep drinking water, and call your doctor the same day if it burns or hurts when you wee.",
        symptomId: "frequentUrination",
      ),
      PregWeekSymptomTip(
        symptom: "Mild nausea",
        tip: "Ginger tea, or a rusk or a few plain biscuits before you get out of bed, can settle it. Don't let your stomach go empty, even if breakfast is tiny.",
        symptomId: "nausea",
      ),
      PregWeekSymptomTip(
        symptom: "Mild cramping",
        tip: "A light pulling ache low in your tummy is common as your uterus grows. Cramps with bleeding, or strong pain on one side, need your doctor straight away.",
        symptomId: "cramps",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "Can I feel a bump at 5 weeks?",
        a: "Not yet. Your uterus is still small and sits low in your pelvis. If your tummy looks rounder or your jeans feel tight, that's bloating from pregnancy hormones, and a bump usually starts to show in the second trimester.",
      ),
      PregWeekQuestion(
        q: "The line on my test is faint. Am I pregnant?",
        a: "A faint line read within the time on the pack usually still means you're pregnant. The test picks up the pregnancy hormone (hCG), which is still low this early and rises over the next days. If you're unsure, test again in two or three days with morning pee, or ask your doctor for a blood test.",
      ),
      PregWeekQuestion(
        q: "When will a scan show the heartbeat?",
        a: "A heartbeat is usually seen on an internal (vaginal) scan from about 6 to 7 weeks. If an early scan shows only the pregnancy sac, it's often because it's too soon to see more. Your doctor may repeat the scan in a week or two.",
      ),
    ],
    sources: ["mohfw_anc", "who_anc", "nice_ng201", "acog_month", "moore_embryology"],
  ),

  // ---- Week 6 ---------------------------------------------------------------
  PregWeekExtra(
    week: 6,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Morning sickness",
        tip: "Despite the name, it can come at any time of day. Ginger in tea, sips of nimbu paani and a small dry snack every couple of hours help many women.",
        symptomId: "nausea",
      ),
      PregWeekSymptomTip(
        symptom: "Food aversions",
        tip: "Eat what stays down for now, even if it's the same plain meal every day. If you can't face dal, curd, paneer or eggs keep the protein coming.",
        symptomId: "foodAversions",
      ),
      PregWeekSymptomTip(
        symptom: "Smell sensitivity",
        tip: "Higher oestrogen makes cooking smells and perfume feel overpowering. Open the windows while the tadka's going, or ask someone else to cook for a while.",
        symptomId: "smellSensitivity",
      ),
      PregWeekSymptomTip(
        symptom: "Extreme fatigue",
        tip: "The first weeks are often the most tiring part of pregnancy. Lie down for 20 minutes in the afternoon if you can, and say yes when someone offers to help.",
        symptomId: "fatigue",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "Will I have a bump at 6 weeks?",
        a: "Not from your baby yet. Your baby is about the size of a pomegranate seed, and your uterus is still inside your pelvis. Some women look a little rounder from bloating, and that comes and goes through the day.",
      ),
      PregWeekQuestion(
        q: "What should I avoid now?",
        a: "Alcohol and smoking, and any medicine your doctor hasn't cleared, herbal ones included. Skip raw or undercooked meat and eggs, and milk that hasn't been boiled or pasteurised, and wash fruit and vegetables well. Keep caffeine under about 200 mg a day, counting coffee, chai and cola together.",
      ),
    ],
    sources: ["mohfw_anc", "icmr_nin", "who_anc", "nice_ng201", "acog_month"],
  ),

  // ---- Week 7 ---------------------------------------------------------------
  PregWeekExtra(
    week: 7,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Nausea",
        tip: "Sip drinks between meals rather than with them, so your stomach isn't too full. If you're being sick, small sips of coconut water or nimbu paani help replace lost fluid.",
        symptomId: "nausea",
      ),
      PregWeekSymptomTip(
        symptom: "Food cravings or aversions",
        tip: "Craving something sour or spicy, like achaar or chaat, is very common and fine in sensible amounts. A craving for things that aren't food, like mitti, chalk or ice, can be a sign of low iron, so tell your doctor.",
        symptomId: "foodAversions",
      ),
      PregWeekSymptomTip(
        symptom: "Frequent urination",
        tip: "Your growing uterus presses on your bladder, so you'll go more often. Don't cut down on water to go less, but drink a little less in the hour or two before bed.",
        symptomId: "frequentUrination",
      ),
      PregWeekSymptomTip(
        symptom: "Fatigue",
        tip: "Your body is making much more blood now, and that takes energy. Iron-rich food like dal, chana and green leaves, with a squeeze of nimbu, helps, and so does an earlier night.",
        symptomId: "fatigue",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "Should I have a bump yet?",
        a: "No, most women don't at 7 weeks. Your uterus is growing but still sits low, behind your pubic bone, so any roundness now is usually bloating. A bump from your baby tends to appear in the second trimester, a little earlier in a second pregnancy.",
      ),
      PregWeekQuestion(
        q: "Do my symptoms say how my pregnancy is going?",
        a: "Not reliably. Some women with healthy pregnancies feel very sick and others feel almost nothing, and symptoms often change from day to day. Your check-ups and scans tell you how things are going, and heavy bleeding or strong pain always needs a call to your doctor.",
      ),
    ],
    sources: ["mohfw_anc", "icmr_nin", "nice_ng201", "acog_month", "moore_embryology"],
  ),

  // ---- Week 8 ---------------------------------------------------------------
  PregWeekExtra(
    week: 8,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Nausea",
        tip: "For many women it's at its strongest around now, and eases as the first trimester ends. If you're vomiting many times a day or can't keep water down, call your doctor.",
        symptomId: "nausea",
      ),
      PregWeekSymptomTip(
        symptom: "Breast tenderness",
        tip: "Your breasts may be growing, with darker nipples and veins you can see. A bra fitting now, in a size that doesn't press, makes a real difference.",
        symptomId: "breasts",
      ),
      PregWeekSymptomTip(
        symptom: "Fatigue",
        tip: "Tiredness at 8 weeks is normal and isn't a sign that anything is wrong. If you also feel breathless or look pale, ask your doctor to check your haemoglobin.",
        symptomId: "fatigue",
      ),
      PregWeekSymptomTip(
        symptom: "Bloating",
        tip: "Progesterone slows your digestion, so food and gas move through more slowly. Smaller meals eaten slowly, a short walk afterwards and a pinch of ajwain or saunf can help.",
        symptomId: "bloating",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "Do I need to rest all the time now?",
        a: "Not unless your doctor has said so. In a healthy pregnancy, normal daily life, work and gentle walks are fine, and strict bed rest isn't needed. Rest when you're tired, and follow your doctor's advice if you've had bleeding or pain.",
      ),
      PregWeekQuestion(
        q: "What happens at the first antenatal visit?",
        a: "Your doctor asks about your health and any past pregnancies, checks your weight and blood pressure, and sends you for blood and urine tests. These usually include haemoglobin, blood group, blood sugar, and tests for HIV, syphilis and hepatitis B, and many clinics check your thyroid too. Many doctors also book an early scan to confirm your dates.",
      ),
      PregWeekQuestion(
        q: "Can I eat papaya and pineapple?",
        a: "Ripe papaya in small amounts is usually fine. Raw or unripe papaya, the kind in some salads and sabzis, is the one to skip. Pineapple in normal amounts is fine too, because a usual serving holds very little of the enzyme people worry about.",
      ),
    ],
    sources: ["mohfw_anc", "mohfw_pmsma", "icmr_nin", "who_anc", "nice_ng201"],
  ),

  // ---- Week 9 ---------------------------------------------------------------
  PregWeekExtra(
    week: 9,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Nausea",
        tip: "If ginger and small meals aren't enough, ask your doctor about medicine. There are options that are safe in pregnancy, and you don't have to put up with it.",
        symptomId: "nausea",
      ),
      PregWeekSymptomTip(
        symptom: "Fatigue",
        tip: "Your heart is pumping more blood and your body is working round the clock. Do the day's important jobs when you feel best, and let the rest wait.",
        symptomId: "fatigue",
      ),
      PregWeekSymptomTip(
        symptom: "Food aversions",
        tip: "If you can't face dal or sabzi, go for what you can: curd rice, fruit, a boiled egg or peanuts. Your prenatal tablets help cover the gaps while your appetite is off.",
        symptomId: "foodAversions",
      ),
      PregWeekSymptomTip(
        symptom: "Mood swings",
        tip: "Feeling tearful or snappy is common while hormones change this fast. If you feel low or anxious most days for two weeks or more, tell your doctor, because it can be helped.",
        symptomId: "moodSwings",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "Is week 9 the hardest week?",
        a: "For many women, weeks 8 to 11 are the toughest, with nausea and tiredness at their strongest. It usually starts to ease towards the end of the first trimester, though for some it takes a little longer.",
      ),
      PregWeekQuestion(
        q: "When will I hear the heartbeat?",
        a: "This early, your doctor sees it on a scan rather than hearing it. A handheld Doppler at the clinic can often pick it up from about 10 to 12 weeks, and it can take a few tries. Home Doppler devices aren't advised, because not finding the heartbeat can frighten you for no reason, and finding it can reassure you when you should be calling your doctor.",
      ),
    ],
    sources: ["mohfw_anc", "who_anc", "nice_ng201", "acog_month", "moore_embryology"],
  ),

  // ---- Week 10 --------------------------------------------------------------
  PregWeekExtra(
    week: 10,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Fatigue",
        tip: "You're in the last weeks of the most tiring stretch. Many women find their energy starts to come back from about 13 or 14 weeks.",
        symptomId: "fatigue",
      ),
      PregWeekSymptomTip(
        symptom: "Nausea",
        tip: "Still feeling sick at 10 weeks is normal. Cold food and cold drinks are often easier than hot, and a plain snack in your bag helps when a wave comes.",
        symptomId: "nausea",
      ),
      PregWeekSymptomTip(
        symptom: "Frequent urination",
        tip: "This may ease a little once your uterus rises out of your pelvis, at around 12 weeks. Until then, leaning forward a little when you wee helps your bladder empty fully.",
        symptomId: "frequentUrination",
      ),
      PregWeekSymptomTip(
        symptom: "Food cravings or aversions",
        tip: "Giving in to a craving now and then is fine. If you want sweets all day, have them with some protein, like a handful of peanuts or roasted chana, to keep your energy steady.",
        symptomId: "foodAversions",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "Is more discharge normal now?",
        a: "A thin, white or clear discharge with a mild smell is normal, and it often increases from now on. Wear cotton underwear and skip douches and scented washes. Call your doctor if it itches, burns, smells strong, turns green or grey, has blood in it, or is watery and keeps coming.",
      ),
      PregWeekQuestion(
        q: "Will I have a bump at 10 weeks?",
        a: "Probably not yet, though your clothes may feel tighter round the waist. Some women show a little earlier, especially in a second pregnancy. Bumps at the same week look very different from one woman to the next.",
      ),
      PregWeekQuestion(
        q: "When does an embryo become a fetus?",
        a: "At the end of week 10, counted from your last period, which is about eight weeks after conception. By then all the main organs have started to form. From here your baby is mostly growing and maturing.",
      ),
    ],
    sources: ["mohfw_anc", "who_anc", "nice_ng201", "acog_month", "moore_embryology"],
  ),

  // ---- Week 11 --------------------------------------------------------------
  PregWeekExtra(
    week: 11,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Fatigue",
        tip: "Your energy may be starting to lift, or not quite yet. Both are normal at 11 weeks, and a short walk outdoors in the morning can help you feel more awake.",
        symptomId: "fatigue",
      ),
      PregWeekSymptomTip(
        symptom: "Bloating",
        tip: "Burping and a tight, full tummy are common as digestion slows. Eat slowly, sit up for a while after meals, and go easy on fizzy drinks and fried food.",
        symptomId: "bloating",
      ),
      PregWeekSymptomTip(
        symptom: "Constipation",
        tip: "Fibre with plenty of water works best: guava, pear, oats, dal and whole grains. Iron tablets can add to it, so tell your doctor rather than stopping them.",
        symptomId: "constipation",
      ),
      PregWeekSymptomTip(
        symptom: "Mood swings",
        tip: "It's normal to feel happy one hour and teary the next. Talking to someone you trust, and getting enough sleep, both help steady things.",
        symptomId: "moodSwings",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "What is the NT scan, and when is it done?",
        a: "It's an ultrasound between 11 weeks and 13 weeks 6 days that measures the fluid at the back of your baby's neck, and it also checks your dates, the heartbeat and whether there's more than one baby. With a blood test, it screens for conditions such as Down syndrome. It's a screening, not a diagnosis, and your doctor will explain what your result means.",
      ),
      PregWeekQuestion(
        q: "Why is my skin breaking out?",
        a: "Pregnancy hormones make your skin oilier, so spots are common in the early months. A gentle face wash twice a day and an oil-free moisturiser are enough. Check with your doctor before using any acne cream, because some, like retinoids, aren't safe in pregnancy.",
      ),
    ],
    sources: ["mohfw_anc", "who_anc", "nice_ng201", "acog_month", "moore_embryology"],
  ),

  // ---- Week 12 --------------------------------------------------------------
  PregWeekExtra(
    week: 12,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Fatigue",
        tip: "Many women feel the tiredness start to lift around now, though for some it takes a few more weeks. Keep going to bed a little earlier until it does.",
        symptomId: "fatigue",
      ),
      PregWeekSymptomTip(
        symptom: "Occasional nausea",
        tip: "Nausea often fades over the next few weeks, though it can linger for some women. If it's suddenly much worse, or you can't keep water down, call your doctor.",
        symptomId: "nausea",
      ),
      PregWeekSymptomTip(
        symptom: "Frequent urination",
        tip: "Your uterus is starting to rise out of your pelvis, so the pressure on your bladder may ease soon. Burning, pain or a fever with it needs a call to your doctor the same day.",
        symptomId: "frequentUrination",
      ),
      PregWeekSymptomTip(
        symptom: "Breast changes",
        tip: "Your breasts may be bigger, with darker nipples, small bumps around them and blue veins under the skin. These changes are getting them ready to feed your baby.",
        symptomId: "breasts",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "What does the placenta do?",
        a: "The placenta grows on the wall of your uterus and passes oxygen and food from your blood to your baby through the umbilical cord, and carries waste away. Around the end of the first trimester it takes over making most of the pregnancy hormones. Your scan reports describe where it's attached, for example 'anterior' (front) or 'posterior' (back).",
      ),
      PregWeekQuestion(
        q: "How can I look after my placenta?",
        a: "The care you're already giving yourself helps it: regular check-ups, your supplements, good food, and no smoking or alcohol. Having your blood pressure checked at every visit matters, because high blood pressure can affect how well the placenta works.",
      ),
      PregWeekQuestion(
        q: "Will I show at 12 weeks?",
        a: "Some women do, and many don't. Around now your uterus rises out of your pelvis, so you may feel a firm rise just above your pubic bone before anyone can see anything. In a second pregnancy the bump often shows earlier.",
      ),
    ],
    sources: ["mohfw_anc", "who_anc", "nice_ng201", "acog_month", "moore_embryology"],
  ),

  // ---- Week 13 --------------------------------------------------------------
  PregWeekExtra(
    week: 13,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Improved energy",
        tip: "Many women feel more like themselves from about now. Use the good hours for a daily walk, and stop before you're worn out.",
      ),
      PregWeekSymptomTip(
        symptom: "Reduced nausea",
        tip: "As hormone levels settle, sickness eases for most women during the second trimester. If yours carries on, you're not alone, and your doctor can help.",
        symptomId: "nausea",
      ),
      PregWeekSymptomTip(
        symptom: "Increased appetite",
        tip: "In the second trimester you need only a little more food, about 350 extra kcal a day. That's roughly two rotis with a bowl of dal, not a second full meal.",
      ),
      PregWeekSymptomTip(
        symptom: "Occasional headaches",
        tip: "Water, regular meals and rest in a quiet, dark room help, and ask your doctor before taking any painkiller. A severe headache, or one with blurred vision or swelling, needs a call to your doctor straight away.",
        symptomId: "headache",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "Should I have a bump at 13 weeks?",
        a: "Some women start to show around now and others not for weeks yet, and both are normal. Your height, your build, your tummy muscles and whether it's your first baby all make a difference. Your doctor checks your baby's growth on scans and at your visits, not by how big you look.",
      ),
      PregWeekQuestion(
        q: "Why do my gums bleed when I brush?",
        a: "Pregnancy hormones make your gums softer and more easily irritated, so a little bleeding is common. Use a soft brush, floss gently, and see a dentist. A check-up and cleaning are safe in pregnancy, and the second trimester is a good time for them.",
      ),
      PregWeekQuestion(
        q: "When do I start iron and calcium tablets?",
        a: "In India, doctors usually start daily iron and folic acid tablets after the first trimester and continue them for at least 180 days, with calcium tablets from about the same time. Take iron with water or nimbu paani, not with tea, milk or your calcium tablet, because they stop your body taking it in. Follow the doses your doctor gives you.",
      ),
    ],
    sources: ["mohfw_anc", "mohfw_pmsma", "icmr_nin", "who_anc", "acog_month"],
  ),

  // ---- Week 14 --------------------------------------------------------------
  PregWeekExtra(
    week: 14,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Improved energy",
        tip: "A good time to start or keep up gentle exercise, like a daily walk or a prenatal yoga class. Build up slowly, and keep water with you.",
      ),
      PregWeekSymptomTip(
        symptom: "Increased appetite",
        tip: "Choose food that keeps you full: dal, chana, curd, eggs, nuts and whole grains. Keep roasted makhana or fruit in your bag, so hunger doesn't send you to the fried snacks.",
      ),
      PregWeekSymptomTip(
        symptom: "Round ligament discomfort",
        tip: "A quick, sharp pull low on one side, often when you stand up, cough or turn over, is the ligaments holding your uterus stretching. Move slowly, and bend towards the pain to ease it.",
        symptomId: "roundLigament",
      ),
      PregWeekSymptomTip(
        symptom: "Mild nasal congestion",
        tip: "Pregnancy hormones swell the lining of your nose, so it can feel blocked without a cold. Saline drops or steam help, but ask before using any nasal spray.",
        symptomId: "blockedNose",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "How big should my bump be at 14 weeks?",
        a: "There's no right size. Some women have a clear bump now and others still look the same, and bumps at the same week vary a lot. Your doctor checks your baby's growth at your visits and on scans, so comparing with friends won't tell you much.",
      ),
      PregWeekQuestion(
        q: "Why am I sleeping badly?",
        a: "Needing to wee, a busy mind and vivid dreams can break your sleep even before your bump is big. A regular bedtime, dinner at least two hours before bed and less time on your phone at night all help. If you're hardly sleeping, or you feel low, talk to your doctor.",
      ),
      PregWeekQuestion(
        q: "Is it normal to want sex more, or less?",
        a: "Both are normal. More blood flow to your pelvis and more energy make many women feel more interested in the second trimester, while others feel less. In a healthy pregnancy sex is safe unless your doctor has told you otherwise, and bleeding or pain afterwards needs a call to your doctor.",
      ),
    ],
    sources: ["mohfw_anc", "icmr_nin", "who_anc", "nice_ng201", "acog_month"],
  ),

  // ---- Week 15 --------------------------------------------------------------
  PregWeekExtra(
    week: 15,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Growing bump",
        tip: "Your uterus now sits above your pelvis, so your tummy may look rounder, especially by evening. Loose cotton kurtas and elastic-waist pants or salwars are more comfortable now.",
      ),
      PregWeekSymptomTip(
        symptom: "Increased appetite",
        tip: "Eating a little more is right, but you don't need to eat for two. Add one healthy snack a day, like fruit with a few nuts, or a bowl of sprouts chaat.",
      ),
      PregWeekSymptomTip(
        symptom: "Round ligament pain",
        tip: "A short, sharp tug in your side or groin when you move suddenly is common now. Get up slowly, and hold your tummy when you cough or sneeze.",
        symptomId: "roundLigament",
      ),
      PregWeekSymptomTip(
        symptom: "Occasional headaches",
        tip: "Many second-trimester headaches come from too little water, skipped meals or tight shoulders. A severe headache, or one with blurred vision or swelling, needs a call to your doctor straight away.",
        symptomId: "headache",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "How much weight should I have gained by now?",
        a: "There's no single right number, because it depends on your weight before pregnancy. Many women gain only 1 to 2 kg in the first trimester, and doctors in India often expect about 2 kg a month from here for someone who started at a healthy weight. Your doctor weighs you at every visit and will tell you what's right for you.",
      ),
      PregWeekQuestion(
        q: "Is it safe to travel now?",
        a: "The second trimester is usually the most comfortable time to travel, if your pregnancy is healthy. On long car or train journeys, get up and walk about every hour or two, drink water, and wear the seatbelt's lap strap below your bump. Carry your MCP card or antenatal file, and check with your doctor first, especially before flying or going far from good medical care.",
      ),
    ],
    sources: ["mohfw_anc", "icmr_nin", "who_anc", "nice_ng201", "acog_month"],
  ),

  // ---- Week 16 --------------------------------------------------------------
  PregWeekExtra(
    week: 16,
    symptomTips: [
      PregWeekSymptomTip(
        symptom: "Growing bump",
        tip: "The top of your uterus now reaches about halfway between your pubic bone and your belly button. As your skin stretches it may itch a little, and a plain moisturiser or coconut oil helps.",
      ),
      PregWeekSymptomTip(
        symptom: "Increased appetite",
        tip: "When you're hungry between meals, reach for curd, fruit, roasted chana or a glass of milk before biscuits and namkeen. Eating every three hours or so keeps hunger and acidity down.",
      ),
      PregWeekSymptomTip(
        symptom: "Back discomfort",
        tip: "Your changing posture and looser joints put more strain on your lower back. Wear flat, supportive chappals, sit with your back supported, and bend your knees, not your waist, to lift.",
        symptomId: "backPain",
      ),
      PregWeekSymptomTip(
        symptom: "Occasional round ligament pain",
        tip: "It's a brief stretch in the ligaments holding your growing uterus, and it usually passes in seconds. Pain that keeps going, comes in waves, or comes with bleeding or fever needs a call to your doctor the same day.",
        symptomId: "roundLigament",
      ),
    ],
    asked: [
      PregWeekQuestion(
        q: "Where is my baby lying at 16 weeks?",
        a: "Your baby has lots of room and floats freely, turning and changing position many times a day. Position only starts to matter in the last weeks, and most babies settle head down by about 36 weeks. A scan that says 'breech' now doesn't tell you anything about the birth.",
      ),
      PregWeekQuestion(
        q: "Is it safe to exercise now?",
        a: "For most women, yes. Aim for about 150 minutes a week of activity like brisk walking, swimming or prenatal yoga, at a pace where you can still talk. Avoid contact sports and anything with a risk of falling, and check with your doctor first if you've had bleeding or been told to take it easy.",
      ),
      PregWeekQuestion(
        q: "Which tests come next?",
        a: "Most doctors book a detailed anomaly scan between 18 and 20 weeks, to check how your baby's organs and body are growing. If you didn't have first trimester screening, some offer a blood screening test (the quadruple test) between 15 and 20 weeks. Your blood pressure, weight and urine are checked at every visit as before.",
      ),
    ],
    sources: ["mohfw_anc", "mohfw_pmsma", "who_anc", "nice_ng201", "acog_month"],
  ),
];
