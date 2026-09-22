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
        SymptomArea.head => 'Head and breathing',
        SymptomArea.body => 'Back, legs and joints',
        SymptomArea.sleepMood => 'Sleep and mood',
        SymptomArea.skinSenses => 'Skin, senses and small things',
        SymptomArea.babyBelly => 'Belly and baby',
      };

  /// One line under the label on the door.
  String get blurb => switch (this) {
        SymptomArea.tummy => 'Nausea, heartburn, constipation, the taste of metal.',
        SymptomArea.head => 'Headaches, dizziness, breathlessness, nosebleeds.',
        SymptomArea.body => 'Back pain, cramps, pelvic aches, swelling, veins.',
        SymptomArea.sleepMood => 'Sleep, dreams, restless legs, mood.',
        SymptomArea.skinSenses => 'Itching, gums, hair, smells, hot flushes.',
        SymptomArea.babyBelly => 'Kicks, hiccups, tightenings, the pull of a growing belly.',
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
      'nausea' || 'heartburn' || 'constipation' || 'metallicTaste' || 'foodAversions' || 'bloating' =>
        SymptomArea.tummy,
      'headache' || 'dizziness' || 'breathlessness' || 'nosebleeds' || 'blockedNose' => SymptomArea.head,
      'backPain' || 'legCramps' || 'swelling' || 'pelvicGirdle' || 'carpalTunnel' || 'varicoseVeins' || 'ribPain' =>
        SymptomArea.body,
      'fatigue' || 'troubleSleeping' || 'moodSwings' || 'restlessLegs' || 'vividDreams' => SymptomArea.sleepMood,
      'itching' || 'bleedingGums' || 'hairSkin' || 'hotFlushes' || 'smellSensitivity' || 'frequentUrination' =>
        SymptomArea.skinSenses,
      _ => SymptomArea.babyBelly,
    };

/// The twenty-one added on 2026-09-22.
final List<Symptom> kMoreSymptoms = [
  // ---- tummy ----------------------------------------------------------------
  Symptom(
    id: 'bloating',
    category: SymptomCategory.digestive,
    trimesters: const [1, 2, 3],
    keywords: const ['gas', 'wind', 'full', 'pet phoolna'],
    name: _s('Bloating and wind'),
    commonness: _s('Very common from the first weeks, and it tends to stay.'),
    why: _s('Progesterone slows the gut so food moves through more slowly, and later the uterus leaves the bowel less room.'),
    tips: [
      _s('Smaller meals, eaten slowly, and a short walk after them.'),
      _s('Go easy on beans, cabbage, cauliflower and fizzy drinks for a few days and see what changes.'),
      _s('Ajwain or saunf after a meal is the old remedy, and it is a safe one.'),
    ],
    doctorGuidance: _s('If it comes with pain that does not pass, vomiting, or you have not opened your bowels for days, tell your doctor.'),
  ),
  Symptom(
    id: 'metallicTaste',
    category: SymptomCategory.digestive,
    trimesters: const [1],
    keywords: const ['taste', 'metal', 'dysgeusia', 'muh ka swad'],
    name: _s('A metallic taste'),
    commonness: _s('Common in the first trimester; most women lose it by the second.'),
    why: _s('Oestrogen changes the way taste buds work, and a coin-like taste is the usual result.'),
    tips: [
      _s('Sour and sharp things cut through it: nimbu pani, imli, a slice of amla.'),
      _s('Brush your tongue as well as your teeth; a mint or saunf helps between meals.'),
      _s('Steel cutlery can make it worse for some women — try a wooden or plastic spoon for a week.'),
    ],
    doctorGuidance: _s('It is harmless. Mention it at your next visit if it is stopping you eating.'),
  ),
  Symptom(
    id: 'foodAversions',
    category: SymptomCategory.digestive,
    trimesters: const [1, 2],
    keywords: const ['aversion', 'cannot eat', 'smell of food', 'khana achha nahi lagta'],
    name: _s('Food aversions'),
    commonness: _s('Most women have at least one — often the very thing they used to love.'),
    why: _s('The same hormones behind nausea sharpen smell and taste; the body steers you away from what it reads as risky.'),
    tips: [
      _s('Eat what stays down. Cold food smells less than hot food.'),
      _s('Let someone else cook the thing you cannot face, and eat away from the kitchen.'),
      _s('If it is a whole food group — say all dal — swap the nutrient, not the meal: paneer, eggs, curd.'),
    ],
    doctorGuidance: _s('If you cannot keep most food or fluids down, or you are losing weight, contact your doctor.'),
  ),

  // ---- head and breathing --------------------------------------------------------
  Symptom(
    id: 'dizziness',
    category: SymptomCategory.circulation,
    trimesters: const [1, 2, 3],
    keywords: const ['faint', 'lightheaded', 'chakkar', 'giddy'],
    name: _s('Dizziness'),
    commonness: _s('Common, especially standing up quickly or in a hot room.'),
    why: _s('Blood vessels relax to carry more blood, and pressure can dip for a moment when you stand; low sugar and heat make it worse.'),
    tips: [
      _s('Stand up slowly, and sit or lie on your left side the moment you feel it.'),
      _s('Eat every three to four hours; carry something to nibble.'),
      _s('Water through the day, and avoid standing still in heat for long.'),
    ],
    doctorGuidance: _s('If you faint, or dizziness comes with a headache, bleeding, blurred vision or a racing heart, contact your doctor the same day.'),
  ),
  Symptom(
    id: 'breathlessness',
    category: SymptomCategory.circulation,
    trimesters: const [2, 3],
    keywords: const ['short of breath', 'breathing', 'saans phoolna', 'winded'],
    name: _s('Breathlessness'),
    commonness: _s('Common, and more so in the third trimester as the uterus rises.'),
    why: _s('Progesterone makes you breathe deeper, and later the baby pushes the diaphragm up so each breath has less room.'),
    tips: [
      _s('Sit and stand tall; a slouch squeezes the lungs further.'),
      _s('Sleep propped on pillows, or on your left side.'),
      _s('Slow down on stairs. It eases when the baby drops in the last weeks.'),
    ],
    doctorGuidance: _s('Breathlessness that comes on suddenly, with chest pain, a cough, a racing heart or blue lips, needs a doctor now.'),
  ),
  Symptom(
    id: 'nosebleeds',
    category: SymptomCategory.circulation,
    trimesters: const [1, 2, 3],
    keywords: const ['nose bleed', 'naak se khoon', 'epistaxis'],
    name: _s('Nosebleeds'),
    commonness: _s('About one in five women get them; usually short and light.'),
    why: _s('More blood, and swollen, delicate vessels inside the nose — the same reason gums bleed.'),
    tips: [
      _s('Sit up, lean forward, pinch the soft part of the nose for ten minutes without letting go.'),
      _s('A little petroleum jelly inside the nostrils at night; a humidifier or a bowl of water in a dry room.'),
      _s('Blow gently, and avoid picking.'),
    ],
    doctorGuidance: _s('If a bleed will not stop after twenty minutes, or they are heavy and frequent, contact your doctor.'),
  ),
  Symptom(
    id: 'blockedNose',
    category: SymptomCategory.circulation,
    trimesters: const [1, 2, 3],
    keywords: const ['stuffy', 'congestion', 'rhinitis', 'naak band'],
    name: _s('A blocked nose'),
    commonness: _s('"Pregnancy rhinitis" — common enough to have its own name.'),
    why: _s('Hormones swell the lining of the nose. It is not a cold, and it clears after the birth.'),
    tips: [
      _s('Saline drops or a saline rinse; steam from a bowl with a towel over your head.'),
      _s('Sleep with the head of the bed raised.'),
      _s('Ask before any decongestant spray — most are not for pregnancy.'),
    ],
    doctorGuidance: _s('If it comes with fever, coloured discharge or face pain, it may be an infection — see your doctor.'),
  ),

  // ---- back, legs and joints ---------------------------------------------------------
  Symptom(
    id: 'pelvicGirdle',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['pelvic pain', 'pubic bone', 'spd', 'hip pain', 'kamar ke neeche dard'],
    name: _s('Pelvic girdle pain'),
    commonness: _s('One in five women; often from the middle of pregnancy.'),
    why: _s('Relaxin loosens the joints of the pelvis so the baby can pass; loosened joints ache, especially at the pubic bone and the back of the pelvis.'),
    tips: [
      _s('Keep your knees together when turning in bed and getting out of a car.'),
      _s('Sit to dress; take stairs one at a time; avoid standing on one leg.'),
      _s('A physiotherapist who knows pregnancy can give a support belt and exercises that genuinely help.'),
    ],
    doctorGuidance: _s('If pain stops you walking or climbing stairs, ask for a physiotherapy referral — this is treatable and you do not have to wait it out.'),
  ),
  Symptom(
    id: 'carpalTunnel',
    category: SymptomCategory.physical,
    trimesters: const [3],
    keywords: const ['tingling', 'numb fingers', 'wrist', 'haath sunn'],
    name: _s('Tingling or numb fingers'),
    commonness: _s('Common in the last trimester, and usually worst at night.'),
    why: _s('Fluid gathers in the wrist and presses on the nerve that runs through it to the thumb and first fingers.'),
    tips: [
      _s('Shake and stretch the hands; sleep with the wrist straight — a splint from the chemist works.'),
      _s('Keep the hand raised when it tingles; avoid long stretches at a phone or keyboard.'),
      _s('It fades within weeks of the birth as the fluid goes.'),
    ],
    doctorGuidance: _s('If a hand is weak, you drop things, or the numbness is constant, tell your doctor — a splint or a referral can be arranged.'),
  ),
  Symptom(
    id: 'varicoseVeins',
    category: SymptomCategory.circulation,
    trimesters: const [2, 3],
    keywords: const ['veins', 'legs', 'blue veins', 'nasein'],
    name: _s('Varicose veins'),
    commonness: _s('Common, especially if your mother had them; the legs and sometimes the vulva.'),
    why: _s('More blood, softer vein walls, and a uterus pressing on the veins that drain the legs.'),
    tips: [
      _s('Feet up whenever you sit; do not cross your legs; sleep on your left side.'),
      _s('Compression stockings, put on before you get out of bed.'),
      _s('Walk daily — the calf muscles pump the blood back up.'),
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
    why: _s('The uterus pushes the ribs outwards and the baby\'s feet find them; the muscles between the ribs stretch.'),
    tips: [
      _s('Sit tall, arms lifted over your head for a minute; a chair with a straight back.'),
      _s('A warm pack over the ribs; sleep on the other side.'),
      _s('It eases when the baby drops in the last weeks.'),
    ],
    doctorGuidance: _s('Pain under the right ribs with a headache, vision changes or swelling of the face and hands is a same-day call — it can be a sign of pre-eclampsia.'),
  ),

  // ---- sleep and mood ---------------------------------------------------------------
  Symptom(
    id: 'restlessLegs',
    category: SymptomCategory.sleep,
    trimesters: const [2, 3],
    keywords: const ['legs at night', 'crawling', 'cannot keep still', 'taange'],
    name: _s('Restless legs'),
    commonness: _s('One in five women in the second half; worst in the evening.'),
    why: _s('Not fully understood — low iron and folate are often behind it, and hormones make it worse.'),
    tips: [
      _s('Ask for an iron check; low iron is the one fixable cause.'),
      _s('Stretch the calves before bed; a warm bath; walk about when it starts.'),
      _s('Less chai and coffee after noon.'),
    ],
    doctorGuidance: _s('Mention it at your next visit — an iron and folate test is easy, and treating low iron often settles it.'),
  ),
  Symptom(
    id: 'vividDreams',
    category: SymptomCategory.sleep,
    trimesters: const [1, 2, 3],
    keywords: const ['dreams', 'nightmares', 'sapne'],
    name: _s('Vivid dreams'),
    commonness: _s('Most women notice them; they are strange, detailed and often about the baby.'),
    why: _s('Broken sleep means you wake during dream sleep and remember it; hormones and the mind working through a big change do the rest.'),
    tips: [
      _s('Nothing needs fixing. Writing one down in the morning takes its charge away.'),
      _s('A calmer evening — less screen, a warm drink — makes for gentler dreams.'),
      _s('If a dream frightens you, say it out loud to someone; it shrinks.'),
    ],
    doctorGuidance: _s('If dreams leave you dreading sleep, or you feel low and anxious through the day, talk to your doctor — that is worth help.'),
  ),

  // ---- skin, senses and small things ------------------------------------------------
  Symptom(
    id: 'itching',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['itch', 'khujli', 'scratching', 'skin'],
    name: _s('Itchy skin'),
    commonness: _s('Common over the belly and breasts as the skin stretches.'),
    why: _s('Stretching skin and drier skin; hormones. Itching on the palms and soles is a different thing — see below.'),
    tips: [
      _s('A thick, unscented moisturiser after the bath, while the skin is damp; coconut oil works.'),
      _s('Lukewarm water, not hot; loose cotton.'),
      _s('A cool compress over the itchy patch.'),
    ],
    doctorGuidance: _s('Itching on the palms and soles, worse at night, with no rash, needs a blood test the same day — it can be a liver condition of pregnancy (cholestasis). Call.'),
  ),
  Symptom(
    id: 'bleedingGums',
    category: SymptomCategory.physical,
    trimesters: const [1, 2, 3],
    keywords: const ['gums', 'masoode', 'bleeding when brushing', 'gingivitis'],
    name: _s('Bleeding gums'),
    commonness: _s('Half of pregnant women; "pregnancy gingivitis" has its own name.'),
    why: _s('Hormones make the gums softer and more inflamed, so plaque that never bothered you now makes them bleed.'),
    tips: [
      _s('Brush twice a day with a soft brush; floss gently — bleeding is a reason to keep going, not stop.'),
      _s('A dental check in pregnancy is safe and worth booking.'),
      _s('Rinse with warm salt water.'),
    ],
    doctorGuidance: _s('Gums that are very swollen, painful, or a lump on the gum, deserve a dentist\'s look.'),
  ),
  Symptom(
    id: 'hairSkin',
    category: SymptomCategory.physical,
    trimesters: const [2, 3],
    keywords: const ['dark line', 'linea nigra', 'melasma', 'pigmentation', 'hair growth', 'acne'],
    name: _s('Skin and hair changes'),
    commonness: _s('The dark line down the belly, darker patches on the face, thicker hair — most women get some of it.'),
    why: _s('Hormones drive the cells that make pigment, and hair that would have fallen stays put.'),
    tips: [
      _s('Sunscreen every day; the sun darkens melasma.'),
      _s('Gentle, fragrance-free products; the acne treatments to avoid are the retinoids — ask before using one.'),
      _s('It fades in the months after the birth. The hair falls then too — that is normal.'),
    ],
    doctorGuidance: _s('A mole that changes shape or colour is worth a doctor\'s look, pregnant or not.'),
  ),
  Symptom(
    id: 'hotFlushes',
    category: SymptomCategory.physical,
    trimesters: const [1, 2, 3],
    keywords: const ['hot', 'sweating', 'garmi', 'flush'],
    name: _s('Feeling hot and sweaty'),
    commonness: _s('Common; more blood and a faster metabolism run warm.'),
    why: _s('Your blood volume is up by half and your body is working harder, so you feel the heat before anyone else in the room.'),
    tips: [
      _s('Cotton, layers, a fan; a cold drink and a wet cloth on the wrists.'),
      _s('Drink through the day — sweating loses fluid.'),
      _s('Avoid the midday sun and hot, crowded rooms where you can.'),
    ],
    doctorGuidance: _s('A measured fever (38°C or over), or feeling hot with chills, is not a flush — contact your doctor.'),
  ),
  Symptom(
    id: 'smellSensitivity',
    category: SymptomCategory.physical,
    trimesters: const [1],
    keywords: const ['smell', 'nose', 'perfume', 'khushboo', 'badboo'],
    name: _s('A sharper sense of smell'),
    commonness: _s('Very common in the first trimester, and often the first sign of pregnancy.'),
    why: _s('Oestrogen sharpens smell. Cooking, perfume and the fridge suddenly have edges.'),
    tips: [
      _s('Open windows while cooking; cold meals smell less.'),
      _s('A drop of lemon or mint on a handkerchief to hold under the nose.'),
      _s('It settles by the second trimester for most women.'),
    ],
    doctorGuidance: _s('Harmless on its own. If it is driving nausea that stops you drinking, contact your doctor.'),
  ),
  Symptom(
    id: 'frequentUrination',
    category: SymptomCategory.physical,
    trimesters: const [1, 3],
    keywords: const ['peeing', 'urine', 'toilet', 'bathroom', 'peshab'],
    name: _s('Needing to pee often'),
    commonness: _s('Nearly everyone — early on, and again in the last weeks.'),
    why: _s('Kidneys filter more blood, and the uterus presses on the bladder — first as it rises, then as the baby\'s head comes down.'),
    tips: [
      _s('Lean forward on the toilet to empty fully.'),
      _s('Drink through the day, less in the two hours before bed — but never cut water to go less.'),
      _s('Pelvic floor exercises now, for leaks later.'),
    ],
    doctorGuidance: _s('Burning or pain when you pee, cloudy or smelly urine, or a fever, points to an infection — it needs treating the same day in pregnancy.'),
  ),

  // ---- belly and baby ----------------------------------------------------------------
  Symptom(
    id: 'roundLigament',
    category: SymptomCategory.physical,
    trimesters: const [2],
    keywords: const ['sharp pain side', 'groin', 'stretch', 'pet mein khichav', 'ligament'],
    name: _s('A sharp pull at the side of the belly'),
    commonness: _s('Very common in the second trimester — round ligament pain.'),
    why: _s('The ligaments that hold the uterus stretch as it grows; a cough, a sneeze or turning over tugs them.'),
    tips: [
      _s('Move slowly when you change position; bend towards the pain to slacken the ligament.'),
      _s('A warm bath; a belly band for support.'),
      _s('It is brief — seconds, a minute. If it lasts, it is something else.'),
    ],
    doctorGuidance: _s('Pain that lasts, comes in waves, or comes with bleeding, fever or pain on passing urine, needs a call the same day.'),
  ),
  Symptom(
    id: 'pelvicPressure',
    category: SymptomCategory.physical,
    trimesters: const [3],
    keywords: const ['heavy', 'pressure', 'dropping', 'lightening', 'bhaari'],
    name: _s('Pressure low in the pelvis'),
    commonness: _s('Common in the last weeks as the baby settles head-down.'),
    why: _s('The baby "drops" — the head moves into the pelvis, which eases breathing and adds weight below.'),
    tips: [
      _s('Rest with feet up; a support belt for walking.'),
      _s('Pelvic floor exercises; a warm bath.'),
      _s('Sit on a birthing ball rather than a soft sofa.'),
    ],
    doctorGuidance: _s('Pressure with regular tightenings, a gush or trickle of fluid, or bleeding, before 37 weeks, is a call now.'),
  ),
];

/// Every ordinary symptom on the door: the twelve shipped ones and the
/// twenty-one above. The five urgent entries in `kSymptoms` are NOT here — they
/// live on the pinned flag and in "Is this normal?".
final List<Symptom> kSymptomLibrary = [
  for (final s in kSymptoms)
    if (!s.urgent) s,
  ...kMoreSymptoms,
];

/// The five urgent ones, for the pinned flag.
final List<Symptom> kSymptomUrgent = [for (final s in kSymptoms) if (s.urgent) s];

Symptom? symptomById(String id) => [...kSymptoms, ...kMoreSymptoms].where((s) => s.id == id).firstOrNull;

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
