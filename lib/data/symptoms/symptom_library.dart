// =============================================================================
//  The symptom library — every ordinary discomfort of pregnancy, by body area
// -----------------------------------------------------------------------------
//  2026-09-22, the Symptoms door (docs/SYMPTOMS-DOOR-PLAN.md). The old
//  companion carried twelve ordinary symptoms and five urgent ones. A door
//  she opens at 2am with a new ache needs the ache to be there, so this adds
//  twenty-one more — the ones every antenatal leaflet lists and every second
//  mother asks about — and groups all of them by WHERE she feels it, which
//  is how she looks for it ("my back", "my head", "down there"), not by the
//  medical category the old model used.
//
//  ⚠️ EDUCATIONAL AND REASSURING, NEVER A DIAGNOSIS. Every entry says how
//  common it is, why it happens, three things that may help, and the one line
//  about when to contact the doctor. Anything that can be dangerous
//  (bleeding, less movement, a headache with vision changes, sudden swelling,
//  leaking fluid) is NOT here — it is in `kSymptoms` as `urgent` and on the
//  door's pinned flag, and "Is this normal?" (symptom_normal.dart) routes it
//  to a call, not to a read.
//
//  2026-09-29: SPOTTING IS THE ONE EXCEPTION, on purpose. The gap analysis
//  asks for a spotting page because women log it; the page's first tip and
//  its closing line are "call now", its callout wears the urgent tone
//  (`kSymptomUrgentCallout`), and it links to "I am bleeding" first. It never
//  says a bleed can wait.
//
//  ⚠️ ENGLISH ONLY (CLAUDE.md, 2026-08-27). The `Symptom` model is bilingual
//  because the twelve shipped ones are; the new entries carry the English on
//  both sides via `_s`, which is the house `_same`.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/symptom.dart';
import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import '../symptom_data.dart';

LocalizedText _s(String en) => LocalizedText(en: en, hi: en);

/// Where she feels it — the door's grouping.
enum SymptomArea {
  tummy,
  head,
  body,
  sleepMood,
  skinSenses,
  babyBelly;

  String get label => switch (this) {
        SymptomArea.tummy => 'Tummy and digestion',
        SymptomArea.head => 'Head, eyes and breathing',
        SymptomArea.body => 'Back, legs and joints',
        SymptomArea.sleepMood => 'Sleep and mood',
        SymptomArea.skinSenses => 'Breasts, skin and senses',
        SymptomArea.babyBelly => 'Belly, baby and down below',
      };

  /// One line under the label on the door.
  String get blurb => switch (this) {
        // Rewritten 2026-09-29 to docs/PREG-VOICE.md, with the new symptoms.
        SymptomArea.tummy => 'Nausea, heartburn, constipation, loose motions, a metal taste.',
        SymptomArea.head => 'Headaches, dizziness, blurry vision, breathlessness, nosebleeds.',
        SymptomArea.body => 'Back and leg pain, cramps, pelvic aches, swelling, veins.',
        SymptomArea.sleepMood => 'Sleep, dreams, restless legs, mood, sex drive.',
        SymptomArea.skinSenses => 'Breasts, itching, gums, hair, smells, feeling hot.',
        SymptomArea.babyBelly => 'Cramps, spotting, discharge, kicks and tightenings.',
      };

  IntentMark get mark => switch (this) {
        SymptomArea.tummy => IntentMark.tummyMark,
        SymptomArea.head => IntentMark.headMark,
        SymptomArea.body => IntentMark.bodyMark,
        SymptomArea.sleepMood => IntentMark.moonMark,
        SymptomArea.skinSenses => IntentMark.skinMark,
        SymptomArea.babyBelly => IntentMark.kickMark,
      };

  double get hue => switch (this) {
        SymptomArea.tummy => 42,
        SymptomArea.head => 206,
        SymptomArea.body => 26,
        SymptomArea.sleepMood => 268,
        SymptomArea.skinSenses => 344,
        SymptomArea.babyBelly => 160,
      };
}

/// The area a symptom belongs to.
SymptomArea symptomArea(Symptom s) => switch (s.id) {
      'nausea' || 'heartburn' || 'constipation' || 'metallicTaste' || 'foodAversions' || 'bloating' ||
      'excessSaliva' || 'diarrhoea' =>
        SymptomArea.tummy,
      'headache' || 'dizziness' || 'breathlessness' || 'nosebleeds' || 'blockedNose' || 'blurryVision' =>
        SymptomArea.head,
      'backPain' || 'legCramps' || 'swelling' || 'pelvicGirdle' || 'carpalTunnel' || 'varicoseVeins' || 'ribPain' ||
      'sciatica' || 'lightningCrotch' || 'clumsiness' =>
        SymptomArea.body,
      'fatigue' || 'troubleSleeping' || 'moodSwings' || 'restlessLegs' || 'vividDreams' || 'libido' =>
        SymptomArea.sleepMood,
      'itching' || 'bleedingGums' || 'hairSkin' || 'hotFlushes' || 'smellSensitivity' || 'frequentUrination' ||
      'breasts' || 'leakyBreasts' || 'redPalms' =>
        SymptomArea.skinSenses,
      // cramps, spotting, discharge (2026-09-29), and the belly-and-baby set.
      _ => SymptomArea.babyBelly,
    };

/// The twenty-one added on 2026-09-22. Rewritten 2026-09-29 to
/// docs/PREG-VOICE.md.
final List<Symptom> kMoreSymptoms = [
  // ---- tummy ----------------------------------------------------------------
  Symptom(
    id: 'bloating',
    category: SymptomCategory.digestive,
    trimesters: const [1, 2, 3],
    keywords: const ['gas', 'wind', 'full', 'pet phoolna'],
    name: _s('Bloating and wind'),
    commonness: _s("Very common from the first weeks, and it tends to stay."),
    why: _s("Progesterone slows your gut, so food moves through more slowly. Later, your uterus leaves your bowel less room."),
    tips: [
      _s('Eat smaller meals, slowly, and take a short walk after them.'),
      _s('Go easy on beans, cabbage, cauliflower and fizzy drinks for a few days, and see what changes.'),
      _s("Ajwain or saunf after a meal is the old remedy, and it's a safe one."),
    ],
    doctorGuidance: _s("If it comes with pain that doesn't pass, or vomiting, or you haven't opened your bowels for days, tell your doctor."),
  ),
  Symptom(
    id: 'metallicTaste',
    category: SymptomCategory.digestive,
    trimesters: const [1],
    keywords: const ['taste', 'metal', 'dysgeusia', 'muh ka swad'],
    name: _s('A metallic taste'),
    commonness: _s('Common in the first trimester. Most women lose it by the second.'),
    why: _s('Oestrogen changes the way your taste buds work, and a coin-like taste is the usual result.'),
    tips: [
      _s('Sour, sharp things cut through it: nimbu pani, imli, a slice of amla.'),
      _s('Brush your tongue as well as your teeth. A mint or saunf helps between meals.'),
      _s('Steel cutlery makes it worse for some women. Try a wooden or plastic spoon for a week.'),
    ],
    doctorGuidance: _s("It's harmless. Mention it at your next visit if it's stopping you eating."),
  ),
  Symptom(
    id: 'foodAversions',
    category: SymptomCategory.digestive,
    trimesters: const [1, 2],
    keywords: const ['aversion', 'cannot eat', 'smell of food', 'khana achha nahi lagta'],
    name: _s('Food aversions'),
    commonness: _s('Most women have at least one, often the very thing they used to love.'),
    why: _s('The same hormones behind nausea sharpen your smell and taste, and your body steers you away from what it reads as risky.'),
    tips: [
      _s('Eat what stays down. Cold food smells less than hot food.'),
      _s("Let someone else cook the thing you can't face, and eat away from the kitchen."),
      _s("If it's a whole food group, say all dal, swap the nutrient, not the meal: paneer, eggs, curd."),
    ],
    doctorGuidance: _s("If you can't keep most food or fluids down, or you're losing weight, contact your doctor."),
  ),

  // ---- head and breathing --------------------------------------------------------
  Symptom(
    id: 'dizziness',
    category: SymptomCategory.circulation,
    trimesters: const [1, 2, 3],
    keywords: const ['faint', 'lightheaded', 'chakkar', 'giddy'],
    name: _s('Dizziness'),
    commonness: _s('Common, especially when you stand up quickly or get hot.'),
    why: _s('Your blood vessels relax to carry more blood, so your pressure can dip for a moment when you stand. Low sugar and heat make it worse.'),
    tips: [
      _s('Stand up slowly. The moment you feel it, sit down or lie on your left side.'),
      _s('Eat every three to four hours, and carry something to nibble.'),
      _s("Drink water through the day, and don't stand still in the heat for long."),
    ],
    doctorGuidance: _s('If you faint, or the dizziness comes with a headache, bleeding, blurred vision or a racing heart, contact your doctor the same day.'),
  ),
  Symptom(
    id: 'breathlessness',
    category: SymptomCategory.circulation,
    trimesters: const [2, 3],
    keywords: const ['short of breath', 'breathing', 'saans phoolna', 'winded'],
    name: _s('Breathlessness'),
    commonness: _s('Common, and more so in the third trimester as your uterus rises.'),
    why: _s('Progesterone makes you breathe more deeply, which brings your baby more oxygen. Later, your baby pushes your diaphragm up, so each breath has less room.'),
    tips: [
      _s('Sit and stand tall. Slouching squeezes your lungs further.'),
      _s('Sleep propped up on pillows, or on your left side.'),
      _s('Take stairs slowly. It eases when your baby drops in the last weeks.'),
    ],
    doctorGuidance: _s('Breathlessness that comes on suddenly, with chest pain, a cough, a racing heart or blue lips, needs a doctor now.'),
  ),
  Symptom(
    id: 'nosebleeds',
    category: SymptomCategory.circulation,
    trimesters: const [1, 2, 3],
    keywords: const ['nose bleed', 'naak se khoon', 'epistaxis'],
    name: _s('Nosebleeds'),
    commonness: _s('About one in five women get them. They are usually short and light.'),
    why: _s('You have more blood, and the small vessels inside your nose swell and get delicate. Gums bleed for the same reason.'),
    tips: [
      _s('Sit up, lean forward and pinch the soft part of your nose for ten minutes without letting go.'),
      _s('Dab a little petroleum jelly inside your nostrils at night. In a dry room, a humidifier or a bowl of water helps.'),
      _s('Blow gently, and try not to pick.'),
    ],
    doctorGuidance: _s("If a bleed won't stop after twenty minutes, or bleeds are heavy and frequent, contact your doctor."),
  ),
  Symptom(
    id: 'blockedNose',
    category: SymptomCategory.circulation,
    trimesters: const [1, 2, 3],
    keywords: const ['stuffy', 'congestion', 'rhinitis', 'naak band'],
    name: _s('A blocked nose'),
    commonness: _s('So common in pregnancy it has its own name: pregnancy rhinitis.'),
    why: _s("Hormones swell the lining of your nose. It isn't a cold, and it clears after the birth."),
    tips: [
      _s('Use saline drops or a saline rinse, or breathe steam from a bowl with a towel over your head.'),
      _s('Sleep with the head of the bed raised.'),
      _s("Ask before using any decongestant spray. Most aren't meant for pregnancy."),
    ],
    doctorGuidance: _s('If it comes with a fever, coloured mucus or pain in your face, it may be an infection. See your doctor.'),
  ),

  // ---- back, legs and joints ---------------------------------------------------------
  Symptom(
    id: 'pelvicGirdle',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['pelvic pain', 'pubic bone', 'spd', 'hip pain', 'kamar ke neeche dard'],
    name: _s('Pelvic girdle pain'),
    commonness: _s('One in five women get it, often from the middle of pregnancy.'),
    why: _s('Relaxin loosens the joints of your pelvis to make room for your baby at birth. Loosened joints ache, especially at the pubic bone and the back of the pelvis.'),
    tips: [
      _s('Keep your knees together when you turn over in bed or get out of a car.'),
      _s('Sit down to get dressed, take stairs one step at a time, and avoid standing on one leg.'),
      _s('A physiotherapist who knows pregnancy can give you a support belt and exercises that help.'),
    ],
    doctorGuidance: _s("If the pain stops you walking or climbing stairs, ask for a physiotherapy referral. It's treatable, and you don't have to wait it out."),
  ),
  Symptom(
    id: 'carpalTunnel',
    category: SymptomCategory.physical,
    trimesters: const [3],
    keywords: const ['tingling', 'numb fingers', 'wrist', 'haath sunn'],
    name: _s('Tingling or numb fingers'),
    commonness: _s("Common in the last trimester, and usually worst at night."),
    why: _s('Fluid gathers in your wrist and presses on the nerve that runs through it to your thumb and first fingers.'),
    tips: [
      _s('Shake and stretch your hands, and sleep with your wrist straight. A wrist splint from the chemist works.'),
      _s('Raise your hand when it tingles, and take breaks from your phone or keyboard.'),
      _s('It fades within weeks of the birth, as the fluid goes.'),
    ],
    doctorGuidance: _s('If a hand is weak, you keep dropping things, or the numbness never lets up, tell your doctor. A splint or a referral can be arranged.'),
  ),
  Symptom(
    id: 'varicoseVeins',
    category: SymptomCategory.circulation,
    trimesters: const [2, 3],
    keywords: const ['veins', 'legs', 'blue veins', 'nasein'],
    name: _s('Varicose veins'),
    commonness: _s('Common, especially if your mother had them. They show on the legs, and sometimes the vulva.'),
    why: _s('You have more blood, your vein walls are softer, and your uterus presses on the veins that drain your legs.'),
    tips: [
      _s("Put your feet up whenever you sit, don't cross your legs, and sleep on your left side."),
      _s('Wear compression stockings, put on before you get out of bed.'),
      _s('Walk every day. Your calf muscles pump the blood back up.'),
    ],
    doctorGuidance: _s('A vein that is hot, red, hard and painful, or a calf that is swollen and tender on one side, needs a doctor the same day.'),
  ),
  Symptom(
    id: 'ribPain',
    category: SymptomCategory.physical,
    trimesters: const [3],
    keywords: const ['ribs', 'under the breast', 'pasli', 'side pain'],
    name: _s('Rib pain'),
    commonness: _s('Common in the third trimester, usually on the right.'),
    why: _s("Your uterus pushes your ribs outwards and your baby's feet find them. The muscles between your ribs stretch."),
    tips: [
      _s('Sit tall in a straight-backed chair, and lift your arms over your head for a minute.'),
      _s('Put a warm pack over your ribs, and sleep on the other side.'),
      _s('It eases when your baby drops in the last weeks.'),
    ],
    doctorGuidance: _s('Pain under your right ribs with a headache, vision changes, or swelling of your face and hands is a same-day call. It can be a sign of pre-eclampsia.'),
  ),

  // ---- sleep and mood ---------------------------------------------------------------
  Symptom(
    id: 'restlessLegs',
    category: SymptomCategory.sleep,
    trimesters: const [2, 3],
    keywords: const ['legs at night', 'crawling', 'cannot keep still', 'taange'],
    name: _s('Restless legs'),
    commonness: _s("One in five women get it in the second half of pregnancy. It's worst in the evening."),
    why: _s("It isn't fully understood. Low iron and folate are often behind it, and hormones make it worse."),
    tips: [
      _s('Ask for an iron check. Low iron is the one cause that can be fixed.'),
      _s('Stretch your calves before bed, have a warm bath, and walk about when it starts.'),
      _s('Have less chai and coffee after noon.'),
    ],
    doctorGuidance: _s('Mention it at your next visit. An iron and folate test is easy, and treating low iron often settles it.'),
  ),
  Symptom(
    id: 'vividDreams',
    category: SymptomCategory.sleep,
    trimesters: const [1, 2, 3],
    keywords: const ['dreams', 'nightmares', 'sapne', 'sex dreams'],
    name: _s('Vivid dreams'),
    commonness: _s("Most women notice them. They're strange, detailed and often about the baby."),
    why: _s('Broken sleep means you wake during dreams and remember them. Hormones, and your mind working through a big change, do the rest.'),
    tips: [
      _s('Nothing needs fixing. Writing a dream down in the morning takes some of its power away.'),
      _s('A calmer evening, with less screen time and a warm drink, makes for gentler dreams.'),
      _s('If a dream frightens you, tell someone about it. It feels smaller once it\'s said.'),
    ],
    doctorGuidance: _s("If dreams leave you dreading sleep, or you feel low and anxious through the day, talk to your doctor. That's worth getting help for."),
  ),

  // ---- skin, senses and small things ------------------------------------------------
  Symptom(
    id: 'itching',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['itch', 'khujli', 'scratching', 'skin'],
    name: _s('Itchy skin'),
    commonness: _s('Common over the belly and breasts as your skin stretches.'),
    why: _s('Stretching, drier skin and hormones cause most of it. Itching on the palms and soles is a different thing: see the line at the end.'),
    tips: [
      _s('Use a thick, unscented moisturiser after your bath, while your skin is still damp. Coconut oil works.'),
      _s('Wash in lukewarm water, not hot, and wear loose cotton.'),
      _s('Hold a cool compress on the itchy patch.'),
    ],
    doctorGuidance: _s("Itching on your palms and soles, worse at night, with no rash, needs a blood test the same day. It can be a liver condition of pregnancy (cholestasis). Please call, don't wait."),
  ),
  Symptom(
    id: 'bleedingGums',
    category: SymptomCategory.physical,
    trimesters: const [1, 2, 3],
    keywords: const ['gums', 'masoode', 'bleeding when brushing', 'gingivitis', 'loose teeth'],
    name: _s('Bleeding gums'),
    commonness: _s('Half of pregnant women get it. It even has its own name: pregnancy gingivitis.'),
    why: _s("Hormones make your gums softer and more inflamed, so plaque that never bothered you before now makes them bleed."),
    tips: [
      _s("Brush twice a day with a soft brush, and floss gently. Bleeding is a reason to keep going, not to stop."),
      _s("A dental check-up in pregnancy is safe, and worth booking."),
      _s('Rinse with warm salt water.'),
    ],
    doctorGuidance: _s("Gums that are very swollen or painful, or a lump on the gum, need a dentist's look."),
  ),
  Symptom(
    id: 'hairSkin',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['dark line', 'linea nigra', 'melasma', 'pigmentation', 'hair growth', 'acne'],
    name: _s('Skin and hair changes'),
    commonness: _s('Most women get some of it: a dark line down the belly, darker patches on the face, thicker hair.'),
    why: _s("Hormones drive the cells that make pigment, and hair that would have fallen out stays put."),
    tips: [
      _s('Wear sunscreen every day. The sun darkens the patches (melasma).'),
      _s('Use gentle, fragrance-free products. The acne treatments to avoid are retinoids, so ask before using one.'),
      _s("It fades in the months after the birth. Your hair falls out then too, and that's normal."),
    ],
    doctorGuidance: _s("A mole that changes shape or colour is worth a doctor's look, pregnant or not."),
  ),
  Symptom(
    id: 'hotFlushes',
    category: SymptomCategory.physical,
    trimesters: const [1, 2, 3],
    keywords: const ['hot', 'sweating', 'garmi', 'flush'],
    name: _s('Feeling hot and sweaty'),
    commonness: _s('Common. More blood and a faster metabolism make you run warm.'),
    why: _s("Your blood volume is up by half and your body is working harder, so you feel the heat before anyone else in the room."),
    tips: [
      _s('Wear cotton in layers, and keep a fan on. A cold drink and a wet cloth on your wrists help.'),
      _s('Drink through the day. Sweating loses fluid.'),
      _s('Stay out of the midday sun and hot, crowded rooms where you can.'),
    ],
    doctorGuidance: _s("A measured fever (38°C or over), or feeling hot with chills, isn't a flush. Contact your doctor."),
  ),
  Symptom(
    id: 'smellSensitivity',
    category: SymptomCategory.physical,
    trimesters: const [1],
    keywords: const ['smell', 'nose', 'perfume', 'khushboo', 'badboo'],
    name: _s('A sharper sense of smell'),
    commonness: _s('Very common in the first trimester, and often the first sign of pregnancy.'),
    why: _s('Oestrogen sharpens your sense of smell. Cooking, perfume and the fridge suddenly feel strong.'),
    tips: [
      _s('Open the windows while cooking. Cold meals smell less.'),
      _s('Keep a drop of lemon or mint on a handkerchief to hold under your nose.'),
      _s('For most women it settles by the second trimester.'),
    ],
    doctorGuidance: _s("Harmless on its own. If it's making you so sick that you can't drink, contact your doctor."),
  ),
  Symptom(
    id: 'frequentUrination',
    category: SymptomCategory.physical,
    trimesters: const [1, 3],
    keywords: const ['peeing', 'urine', 'toilet', 'bathroom', 'peshab'],
    name: _s('Needing to pee often'),
    commonness: _s('Nearly everyone, early on and again in the last weeks.'),
    why: _s("Your kidneys filter more blood, and your uterus presses on your bladder: first as it rises, then as your baby's head comes down."),
    tips: [
      _s('Lean forward on the toilet to empty your bladder fully.'),
      _s("Drink through the day and a little less in the two hours before bed. Never cut down on water to go less."),
      _s('Start pelvic floor exercises now, to help with leaks later.'),
    ],
    doctorGuidance: _s('Burning or pain when you pee, cloudy or smelly urine, or a fever points to an infection. In pregnancy it needs treating the same day.'),
  ),

  // ---- belly and baby ----------------------------------------------------------------
  Symptom(
    id: 'roundLigament',
    category: SymptomCategory.physical,
    trimesters: const [2],
    keywords: const ['sharp pain side', 'groin', 'stretch', 'pet mein khichav', 'ligament'],
    name: _s('A sharp pull at the side of the belly'),
    commonness: _s('Very common in the second trimester. It is called round ligament pain.'),
    why: _s('The ligaments that hold your uterus stretch as it grows. A cough, a sneeze or turning over tugs on them.'),
    tips: [
      _s('Move slowly when you change position, and bend towards the pain to ease the pull.'),
      _s('A warm bath, or a belly band for support.'),
      _s("It's brief: seconds, or a minute. If it lasts, it's something else."),
    ],
    doctorGuidance: _s('Pain that lasts, comes in waves, or comes with bleeding, a fever or pain when you pee, needs a call the same day.'),
  ),
  Symptom(
    id: 'pelvicPressure',
    category: SymptomCategory.physical,
    trimesters: const [3],
    keywords: const ['heavy', 'pressure', 'dropping', 'lightening', 'bhaari'],
    name: _s('Pressure low in the pelvis'),
    commonness: _s('Common in the last weeks, as your baby settles head-down.'),
    why: _s("Your baby drops: the head moves down into your pelvis. Breathing gets easier, and there's more weight below."),
    tips: [
      _s('Rest with your feet up, and wear a support belt for walking.'),
      _s('Do your pelvic floor exercises, and try a warm bath.'),
      _s('Sit on a birthing ball rather than a soft sofa.'),
    ],
    doctorGuidance: _s('Pressure with regular tightenings, a gush or trickle of fluid, or bleeding, before 37 weeks, is a call now.'),
  ),
];

/// The thirteen added on 2026-09-29 from the pregnancy gap analysis (the
/// symptoms What to Expect's journal logs and we did not cover, and the
/// Appendix A pieces for belly cramps, discharge and breast changes). Pelvic
/// pain, the twelfth on the analysis list, is on the cramps page (and pelvic
/// girdle pain already had one). Their short answers and longer sections
/// are in `symptom_pages.dart`.
final List<Symptom> kAddedSymptoms = [
  Symptom(
    id: 'cramps',
    category: SymptomCategory.physical,
    trimesters: const [1, 2, 3],
    keywords: const ['cramps', 'cramping', 'period pain', 'belly pain', 'stomach pain', 'lower abdomen', 'pelvic pain', 'pet dard', 'pet mein dard'],
    name: _s('Belly cramps'),
    commonness: _s("Mild cramps are common, especially in the first weeks, and they're usually harmless."),
    why: _s('Early on, your uterus is growing and its blood supply is increasing, which can feel like a light period ache. Later, stretching ligaments, gas and constipation cause most cramps.'),
    tips: [
      _s('Sit or lie down, and rest until it eases.'),
      _s('A warm, not hot, water bottle on your lower back, or a warm bath.'),
      _s('Drink water and empty your bladder. A full bladder or constipation can make cramps worse.'),
    ],
    doctorGuidance: _s("Go to hospital now if cramps come with bleeding, if the pain is on one side, if it's severe or doesn't ease with rest, or if you get regular tightenings before 37 weeks. For milder cramps that keep coming back, tell your doctor."),
  ),
  Symptom(
    id: 'spotting',
    category: SymptomCategory.physical,
    trimesters: const [1, 2, 3],
    keywords: const ['spotting', 'spots of blood', 'light bleeding', 'pink discharge', 'brown discharge', 'blood', 'khoon ke daag'],
    name: _s('Spotting'),
    commonness: _s("Common in early pregnancy, and often fine, but it's always a call to your doctor now."),
    why: _s('Early on, spotting can come from the pregnancy settling into the lining of the womb, or from a cervix that bleeds easily after sex or an internal exam. But bleeding can also be a sign of something that needs care.'),
    tips: [
      _s("Call your doctor or maternity unit now. Say how much, what colour, and whether there's any pain."),
      _s('Wear a pad, not a tampon, so you can see how much there is. Note the time it started.'),
      _s("Don't have sex until you've been checked."),
    ],
    doctorGuidance: _s('Any bleeding in pregnancy, even light spotting, is a call now, at any hour. Heavy bleeding (soaking a pad in an hour), clots, pain or cramps with it, or feeling faint: go to hospital straight away.'),
  ),
  Symptom(
    id: 'discharge',
    category: SymptomCategory.physical,
    trimesters: const [1, 2, 3],
    keywords: const ['discharge', 'white discharge', 'vaginal discharge', 'safed pani', 'leucorrhoea', 'yeast', 'thrush', 'itching down there', 'bv', 'fishy smell', 'vulva', 'hygiene'],
    name: _s('More vaginal discharge'),
    commonness: _s("Very common. Most women have more discharge in pregnancy, and it's a normal, healthy thing."),
    why: _s('Higher oestrogen and more blood flow to the area make more discharge. It helps keep infections away from your vagina and womb.'),
    tips: [
      _s("Wear cotton underwear and change it when it's damp. Panty liners are fine; tampons aren't."),
      _s('Wash the outside (the vulva) with plain water. Skip douches, scented washes and wipes.'),
      _s('Wipe from front to back, and let the area breathe at night.'),
    ],
    doctorGuidance: _s('Call your doctor today if your discharge is itchy, lumpy like curd, green, grey, smells fishy or bad, or if it burns or hurts. Watery fluid that keeps coming, or a gush, is a call now: it may be your waters. Any pink, red or brown discharge is a call now too.'),
  ),
  Symptom(
    id: 'breasts',
    category: SymptomCategory.physical,
    trimesters: const [1, 2, 3],
    keywords: const ['breast', 'breasts', 'sore breasts', 'tender breasts', 'nipples', 'bra', 'breast lump', 'breast changes', 'stan', 'chhati'],
    name: _s('Sore or tender breasts'),
    commonness: _s('Very common, and often one of the first signs. The soreness usually eases after the first trimester.'),
    why: _s('Rising hormones and more blood flow get your breasts ready to feed your baby. The milk ducts grow, so your breasts can feel full, heavy and tingly.'),
    tips: [
      _s('Wear a soft, well-fitting bra without underwire, and a cotton sports bra at night if it helps.'),
      _s('Hold a cool compress or a cold, damp cloth on them for a few minutes to ease the ache.'),
      _s('Get measured again as you grow. Many women go up a size or two.'),
    ],
    doctorGuidance: _s('Show your doctor any new lump, a red, hot or painful patch, skin that dimples, or blood from a nipple. Most lumps in pregnancy are harmless, but every one should be checked.'),
  ),
  Symptom(
    id: 'leakyBreasts',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['leaking', 'leaky breasts', 'colostrum', 'milk', 'nipple discharge', 'doodh'],
    name: _s('Leaking breasts'),
    commonness: _s("Common in the later months, and normal. Plenty of women don't leak at all, and that's normal too."),
    why: _s('From around the middle of pregnancy your breasts make colostrum, the thick, yellowish first milk. A little can leak out, especially when your breasts are touched.'),
    tips: [
      _s('Tuck washable or disposable breast pads inside your bra.'),
      _s('Change pads when they get damp, so your skin stays comfortable.'),
      _s("There's no need to squeeze to check for milk. It'll be there when your baby needs it."),
    ],
    doctorGuidance: _s('Tell your doctor if the fluid is bloody, comes from one breast on its own, or comes with a lump, redness or pain.'),
  ),
  Symptom(
    id: 'lightningCrotch',
    category: SymptomCategory.physical,
    trimesters: const [3],
    keywords: const ['lightning crotch', 'sharp pain down there', 'vagina pain', 'shooting pain', 'pelvic pain', 'neeche chubhan'],
    name: _s('Sharp jabs down below'),
    commonness: _s("Common in the last trimester, and usually harmless. It's often called lightning crotch."),
    why: _s("As your baby moves lower, their head can press on nerves in your pelvis. You feel a quick, sharp zing in your vagina or pelvis that's gone in a second or two."),
    tips: [
      _s('Change position slowly, and keep moving. Long spells of sitting or standing make it worse.'),
      _s('On hands and knees, gently round your back and let it flatten again, a few times. Or circle your hips on a birthing ball.'),
      _s("A support belt can take some of your baby's weight off your pelvis."),
    ],
    doctorGuidance: _s('Quick jabs that pass are normal. Call your doctor if the pain lasts, or comes with a fever or bleeding. With regular tightenings before 37 weeks, call now.'),
  ),
  Symptom(
    id: 'sciatica',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['sciatica', 'leg pain', 'buttock pain', 'shooting pain leg', 'nas dard', 'kamar se pair tak dard'],
    name: _s('Pain down the back of the leg'),
    commonness: _s('Fairly common in the second half of pregnancy, and it usually settles after the birth.'),
    why: _s('The nerve that runs from your lower back down each leg (the sciatic nerve) can get pressed or irritated as your posture changes and your joints loosen.'),
    tips: [
      _s('Sit on a chair, rest the ankle of the sore leg on the other knee, and lean forward gently until you feel a stretch in your bottom. Hold for about 30 seconds.'),
      _s('Put a warm pack on the sore spot, and sleep with a pillow between your knees.'),
      _s("Avoid heavy lifting and standing on one leg. A pregnancy physiotherapist can help a lot."),
    ],
    doctorGuidance: _s('Tell your doctor if the pain is severe or stops you walking. Numbness around your bottom or between your legs, or trouble controlling your bladder or bowels, means going to hospital now.'),
  ),
  Symptom(
    id: 'blurryVision',
    category: SymptomCategory.circulation,
    trimesters: const [1, 2, 3],
    keywords: const ['blurry vision', 'blurred vision', 'eyes', 'vision', 'dry eyes', 'contact lenses', 'dhundhla', 'aankh'],
    name: _s('Blurry vision'),
    commonness: _s('Mild blurring is fairly common, and it usually goes back to normal after the birth.'),
    why: _s('Pregnancy hormones make your body hold more fluid, including in your eyes, which can change their shape slightly. Your eyes can also feel drier.'),
    tips: [
      _s('Rest your eyes often, especially at a screen. Ask your doctor about lubricating eye drops.'),
      _s('If contact lenses feel uncomfortable, switch to glasses for a while.'),
      _s('Wait a few months after the birth before getting new glasses or laser eye surgery. Your eyes may change back.'),
    ],
    doctorGuidance: _s('Blurred vision, flashing lights or spots, especially with a headache or swelling of your face or hands, is a call now. It can be a sign of pre-eclampsia. Mild blurring on its own: mention it at your next visit.'),
  ),
  Symptom(
    id: 'excessSaliva',
    category: SymptomCategory.digestive,
    trimesters: const [1],
    keywords: const ['saliva', 'spit', 'drooling', 'ptyalism', 'thook', 'mouth watering'],
    name: _s('Extra saliva'),
    commonness: _s('Fairly common in the first trimester, often along with nausea. It usually fades as the sickness does.'),
    why: _s('Hormones may make you produce more saliva, and nausea can make you swallow less, so it builds up in your mouth.'),
    tips: [
      _s('Chew sugar-free gum or suck a sugar-free mint. It makes swallowing easier.'),
      _s('Brush your teeth and rinse your mouth a few times a day to keep it fresh.'),
      _s("Sip water often, and keep a tissue handy on the bad days."),
    ],
    doctorGuidance: _s("It's harmless on its own. If nausea and vomiting mean you can't keep fluids down, contact your doctor."),
  ),
  Symptom(
    id: 'redPalms',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['red palms', 'red hands', 'red feet', 'red soles', 'palmar erythema', 'hatheli laal'],
    name: _s('Red palms and soles'),
    commonness: _s('Common, and harmless. It fades soon after the birth.'),
    why: _s('More blood flow and higher oestrogen make the small blood vessels in your palms and soles show through as redness. They may feel warm.'),
    tips: [
      _s('Cool water on your hands and feet feels good.'),
      _s('Keep away from very hot water and harsh soaps.'),
      _s('Use a plain moisturiser if the skin feels dry.'),
    ],
    doctorGuidance: _s('Redness alone is harmless. Itching on your palms and soles, worse at night, needs a blood test the same day, so call your doctor. It can be a liver condition of pregnancy (cholestasis).'),
  ),
  Symptom(
    id: 'clumsiness',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['clumsy', 'clumsiness', 'dropping things', 'balance', 'tripping', 'falling'],
    name: _s('Feeling clumsy'),
    commonness: _s("Very common, especially as your bump grows. It isn't you being careless."),
    why: _s('Your centre of balance moves forward, loosened joints feel less steady, and swollen fingers and tiredness make things slip.'),
    tips: [
      _s('Wear flat shoes with a good grip, and hold the railing on stairs.'),
      _s('Keep floors clear, and wipe up spills straight away, especially in the bathroom.'),
      _s('Slow down, and use both hands for anything hot or heavy.'),
    ],
    doctorGuidance: _s('After a fall onto your belly, or any fall after 20 weeks, get checked the same day. Numb or weak hands, or dropping things often, are worth telling your doctor.'),
  ),
  Symptom(
    id: 'libido',
    category: SymptomCategory.emotional,
    trimesters: const [1, 2, 3],
    keywords: const ['libido', 'sex drive', 'desire', 'sex', 'intimacy', 'no interest in sex'],
    name: _s('Changes in sex drive'),
    commonness: _s('Very common. Some women want sex more, some much less, and it can change from one trimester to the next.'),
    why: _s('Hormones and extra blood flow can make you feel more sensitive and interested. Nausea, tiredness, sore breasts, worry or a changing body can make you feel less so.'),
    tips: [
      _s("Tell your partner how you feel. It helps you both to know it isn't about them."),
      _s('Closeness counts too: a massage, a cuddle, time together.'),
      _s('If sex is uncomfortable, try other positions, such as lying on your side.'),
    ],
    doctorGuidance: _s("For most women sex is safe all through pregnancy. Ask your doctor first if you've had bleeding, a low-lying placenta, leaking fluid or early labour before. If sex brings bleeding, pain or fluid, stop and call."),
  ),
  Symptom(
    id: 'diarrhoea',
    category: SymptomCategory.digestive,
    trimesters: const [1, 2, 3],
    keywords: const ['diarrhoea', 'diarrhea', 'loose motion', 'loose motions', 'dast', 'upset stomach', 'stomach bug', 'pet kharab'],
    name: _s('Loose motions (diarrhoea)'),
    commonness: _s('Fairly common, and usually passes in a day or two. In the Indian summer, watch how much water you lose.'),
    why: _s('A stomach bug or food that didn\'t agree with you is the usual cause. Hormone changes, a change in diet or some supplements can loosen motions too.'),
    tips: [
      _s('Sip ORS (oral rehydration solution) after each loose motion, plus water, coconut water or thin buttermilk.'),
      _s('Eat light, simple food: khichdi, curd rice, banana, toast.'),
      _s('Wash your hands well, and ask your doctor before taking any medicine to stop it.'),
    ],
    doctorGuidance: _s("Call your doctor today if it lasts more than a day, or if there's blood or mucus, a fever, belly pain, or vomiting so you can't keep fluids down. Very little or dark pee, or feeling dizzy, can mean you're drying out: get seen today."),
  ),
];

/// Every ordinary symptom on the door: the twelve shipped ones, the
/// twenty-one of 2026-09-22 and the thirteen of 2026-09-29. The five urgent entries in `kSymptoms` are NOT here — they
/// live on the pinned flag and in "Is this normal?".
final List<Symptom> kSymptomLibrary = [
  for (final s in kSymptoms)
    if (!s.urgent) s,
  ...kMoreSymptoms,
  ...kAddedSymptoms,
];

/// The five urgent ones, for the pinned flag.
final List<Symptom> kSymptomUrgent = [for (final s in kSymptoms) if (s.urgent) s];

Symptom? symptomById(String id) => [...kSymptoms, ...kMoreSymptoms, ...kAddedSymptoms].where((s) => s.id == id).firstOrNull;

/// The symptoms of [area], in the library's order.
List<Symptom> symptomsInArea(SymptomArea area) => [for (final s in kSymptomLibrary) if (symptomArea(s) == area) s];

/// When a symptom is at its most common, as a week range — the check-in's
/// "Common this week" leads with these. Where nothing is listed the
/// symptom's trimesters decide.
const Map<String, (int, int)> kSymptomPeakWeeks = {
  'nausea': (6, 14),
  'smellSensitivity': (5, 13),
  'metallicTaste': (5, 12),
  'foodAversions': (6, 14),
  'fatigue': (5, 13),
  'frequentUrination': (6, 13),
  'moodSwings': (6, 12),
  'headache': (8, 16),
  'dizziness': (10, 24),
  'bloating': (8, 40),
  'constipation': (10, 40),
  'roundLigament': (14, 24),
  'heartburn': (20, 40),
  'backPain': (20, 40),
  'legCramps': (24, 40),
  'pelvicGirdle': (20, 40),
  'troubleSleeping': (24, 40),
  'vividDreams': (14, 40),
  'restlessLegs': (24, 40),
  'itching': (24, 40),
  'swelling': (28, 40),
  'breathlessness': (28, 36),
  'carpalTunnel': (30, 40),
  'ribPain': (30, 37),
  'varicoseVeins': (24, 40),
  'braxtonHicks': (30, 40),
  'babyHiccups': (28, 40),
  'pelvicPressure': (35, 40),
  'hairSkin': (16, 40),
  'hotFlushes': (14, 40),
  'nosebleeds': (10, 40),
  'blockedNose': (10, 40),
  'bleedingGums': (10, 40),
  // 2026-09-29. Spotting, red palms, blurry vision, sex drive and loose
  // motions have no peak on purpose: they rank by trimester, never first.
  'cramps': (5, 14),
  'breasts': (4, 14),
  'excessSaliva': (6, 14),
  'discharge': (8, 40),
  'sciatica': (24, 40),
  'clumsiness': (24, 40),
  'leakyBreasts': (28, 40),
  'lightningCrotch': (32, 40),
};

/// The library ordered for [week]: the ones at their peak first, then the
/// ones whose trimester it is, then the rest — so the check-in's first row
/// is what she is likeliest to be feeling.
List<Symptom> symptomsCommonAt(int week) {
  final tri = week < 14 ? 1 : (week < 28 ? 2 : 3);
  int score(Symptom s) {
    final peak = kSymptomPeakWeeks[s.id];
    if (peak != null && week >= peak.$1 && week <= peak.$2) return 0;
    if (s.trimesters.contains(tri)) return 1;
    return 2;
  }
  final out = [...kSymptomLibrary];
  // Stable: `sort` is not, so the index breaks ties in library order.
  final index = {for (var i = 0; i < out.length; i++) out[i].id: i};
  out.sort((a, b) {
    final d = score(a).compareTo(score(b));
    return d != 0 ? d : index[a.id]!.compareTo(index[b.id]!);
  });
  return out;
}
