// =============================================================================
//  Symptom pages — the short answer and the extra sections each page carries
// -----------------------------------------------------------------------------
//  2026-09-29, the pregnancy warmth pass (docs/PREG-VOICE.md, the pregnancy
//  gap analysis). A symptom page is built from the `Symptom` model by
//  `pvReadFromSymptom` (symptom_reads.dart). The model holds how common, why,
//  three tips and the doctor line; it has no room for the two things the gap
//  analysis asks of every read:
//
//    · a SHORT ANSWER at the top (two or three sentences answering the
//      title), and
//    · the longer pages the new symptoms need (which cramps mean hospital,
//      which colours of discharge mean the doctor), and the Appendix A
//      additions folded into pages we already had.
//
//  Both live here, keyed by the symptom id, so the `Symptom` model (shared
//  with the old companion and Ask Veda's local index) stays as it is.
//
//  ⚠️ ENGLISH ONLY (CLAUDE.md, 2026-08-27). Plain strings; the adapter wraps
//  them with `_same`.
//
//  ⚠️ NEVER A DIAGNOSIS, AND EVERY "CALL" KEEPS ITS URGENCY. A page may say
//  what is common and what usually causes it; it never says what she has.
// =============================================================================

/// One extra section on a symptom page: a heading in her words, then
/// paragraphs and/or bullets.
class SymptomPageSection {
  const SymptomPageSection({required this.heading, this.paragraphs = const [], this.bullets = const []});
  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;
}

/// Pages whose closing "when to contact your doctor" callout wears the urgent
/// tone, because its first instruction is to call now or go to hospital.
const Set<String> kSymptomUrgentCallout = {'cramps', 'spotting', 'blurryVision'};

/// Reads offered first under "Read next" on a page, ahead of its area's other
/// symptoms. This is how a page links to the urgent answers in "Is this
/// normal?" (a `normal_` id opens that answer in the same reader).
const Map<String, List<String>> kSymptomReadFirst = {
  'cramps': ['normal_bleeding', 'normal_contractions'],
  'spotting': ['normal_bleeding', 'symptom_cramps', 'symptom_discharge'],
  'discharge': ['normal_fluid', 'normal_bleeding', 'normal_urine'],
  'breasts': ['symptom_leakyBreasts'],
  'leakyBreasts': ['symptom_breasts'],
  'blurryVision': ['normal_headache', 'normal_swelling'],
  'redPalms': ['normal_itching', 'symptom_itching'],
  'clumsiness': ['normal_fall', 'symptom_carpalTunnel'],
  'lightningCrotch': ['symptom_pelvicPressure', 'symptom_cramps'],
  'sciatica': ['symptom_backPain', 'symptom_pelvicGirdle'],
  'excessSaliva': ['symptom_nausea'],
  'diarrhoea': ['normal_fever'],
  'nausea': ['symptom_excessSaliva'],
  'roundLigament': ['symptom_cramps'],
  'pelvicPressure': ['symptom_lightningCrotch'],
  'backPain': ['symptom_sciatica'],
  'braxtonHicks': ['normal_contractions'],
  'itching': ['normal_itching', 'symptom_redPalms'],
  'hairSkin': ['symptom_breasts'],
};

/// The short answer at the top of each page: two or three sentences that
/// answer the title. Every symptom in the library has one (the door test
/// holds it).
const Map<String, String> kSymptomShortAnswers = {
  // ---- the twelve from the first companion --------------------------------
  'nausea':
      "Feeling sick is very common in early pregnancy, and for most women it eases as the weeks go on. Small meals often, and something dry before you get up, help. If you can't keep fluids down, contact your doctor.",
  'heartburn':
      "Heartburn is very common from the middle of pregnancy and isn't harmful. Smaller meals and not lying down straight after eating help most. If it's severe or stops you eating, tell your doctor.",
  'constipation':
      "Constipation is common all through pregnancy, and iron tablets can add to it. Water, fibre and a daily walk usually get things moving. If it's painful or doesn't shift, ask your doctor.",
  'fatigue':
      "Feeling very tired is normal, especially in the first and last months. Your body is doing a lot of work. Rest when you can, and mention it if you're also breathless or dizzy.",
  'backPain':
      "Back pain is common as your bump grows and your posture shifts. Support when you sit, flat shoes and gentle stretches help. Severe or sudden pain is a call to your doctor.",
  'headache':
      "Headaches are fairly common, especially early on, and most ease with rest, water and food. A severe headache, or one with blurred vision or swelling, needs a doctor promptly.",
  'troubleSleeping':
      "Poor sleep is common later in pregnancy, with a bump, kicks and toilet trips in the way. A pillow between your knees and a calm evening help. If you're barely sleeping or feel very low, talk to your doctor.",
  'moodSwings':
      "Mood swings are very common in pregnancy, and they don't mean you're coping badly. Rest, kindness to yourself and someone to talk to help. If you keep feeling low or anxious, talk to your doctor.",
  'swelling':
      "Some swelling of the feet and ankles is normal, especially late in pregnancy and in the heat. Feet up and comfortable shoes help. Sudden swelling of the face or hands needs a doctor promptly.",
  'legCramps':
      "Leg cramps are common, often at night later in pregnancy. Stretching the calf eases them fast. A leg that's red, swollen, warm or painful needs your doctor promptly.",
  'babyHiccups':
      "Feeling your baby hiccup is common in the last trimester, and it's usually a good sign. It feels like small, regular jumps. If your baby's movements ever change, contact your maternity unit.",
  'braxtonHicks':
      "Practice tightenings are common in the third trimester and usually painless. They come and go and ease when you rest or drink water. Regular or painful tightenings before 37 weeks are a call now.",

  // ---- the twenty-one added 2026-09-22 ------------------------------------
  'bloating':
      "Bloating and wind are very common from the first weeks. Smaller meals, a walk afterwards and ajwain or saunf help. Pain that doesn't pass, or vomiting, is a reason to tell your doctor.",
  'metallicTaste':
      "A metal taste in your mouth is common early on and usually fades by the second trimester. Sour things like nimbu pani help cut through it. It's harmless.",
  'foodAversions':
      "Most women go off at least one food, often one they used to love. Eat what stays down and swap nutrients, not meals. If you can't keep most food down, contact your doctor.",
  'dizziness':
      "Feeling dizzy is common, especially when you stand up fast or get hot. Stand slowly, eat often and drink water. If you faint, or it comes with a headache, bleeding or blurred vision, call your doctor the same day.",
  'breathlessness':
      "Feeling short of breath is common, more so late in pregnancy as your baby grows upwards. Sitting tall and sleeping propped up help. Sudden breathlessness with chest pain needs a doctor now.",
  'nosebleeds':
      "Nosebleeds are common in pregnancy and are usually short and light. Lean forward and pinch the soft part of your nose for ten minutes. If it won't stop after twenty minutes, contact your doctor.",
  'blockedNose':
      "A stuffy nose is so common in pregnancy it has its own name, and it clears after the birth. Saline and steam help. Ask before using any decongestant spray.",
  'pelvicGirdle':
      "Pain at the front or back of your pelvis affects about one in five pregnant women. It's treatable, and a pregnancy physiotherapist can help a lot. If it stops you walking, ask for a referral.",
  'carpalTunnel':
      "Tingling or numb fingers are common late in pregnancy, often worse at night. A wrist splint and keeping your hand raised help, and it fades after birth. Weakness or constant numbness is worth telling your doctor.",
  'varicoseVeins':
      "Swollen, bluish veins are common in pregnancy, especially if your mother had them. Feet up, stockings and a daily walk help. A vein that's hot, red, hard and painful needs a doctor the same day.",
  'ribPain':
      "Sore ribs are common in the last trimester as your baby runs out of room. Sitting tall and stretching your arms up help, and it eases when your baby drops. Pain under the right ribs with a headache or swelling is a same-day call.",
  'restlessLegs':
      "Restless legs affect about one in five women in the second half of pregnancy. Low iron is often behind it and is easy to check. Mention it at your next visit.",
  'vividDreams':
      "Strange, vivid dreams are very common in pregnancy, and they don't mean anything is wrong. Broken sleep just means you remember more of them. If they leave you dreading sleep, talk to your doctor.",
  'itching':
      "Itchy skin over your belly and breasts is common as your skin stretches. A thick moisturiser helps. Itching on your palms and soles, worse at night, needs a blood test the same day.",
  'bleedingGums':
      "Bleeding gums affect about half of pregnant women, and it's caused by hormones. Keep brushing gently and see a dentist; it's safe in pregnancy. A painful lump or very swollen gums needs a dentist's look.",
  'hairSkin':
      "A dark line on your belly, darker patches on your face and thicker hair are all common in pregnancy. Most of it fades in the months after birth. Sunscreen helps stop patches getting darker.",
  'hotFlushes':
      "Feeling hot and sweaty is common, because your body has more blood and works harder. Cotton, a fan and plenty of water help. A measured fever of 38°C or over is different: contact your doctor.",
  'smellSensitivity':
      "A much sharper sense of smell is very common early on, and often one of the first signs. It usually settles by the second trimester. Fresh air and cold meals help.",
  'frequentUrination':
      "Needing to pee often is normal, early on and again in the last weeks. Never cut down on water to go less. Burning, pain or a fever with it needs treating the same day.",
  'roundLigament':
      "A sharp, brief pull low at the side of your belly is very common in the second trimester. It's the ligaments that hold your uterus stretching. Pain that lasts or comes with bleeding needs a call the same day.",
  'pelvicPressure':
      "A heavy feeling low in your pelvis is common in the last weeks, as your baby settles head-down. Rest and a support belt help. With tightenings, fluid or bleeding before 37 weeks, call now.",

  // ---- added 2026-09-29 (the gap analysis) --------------------------------
  'cramps':
      "Mild cramps, like a light period ache, are common in pregnancy and usually harmless, especially in the first weeks. Cramps with bleeding, pain on one side, or pain that doesn't ease mean going to hospital. So do regular tightenings before 37 weeks.",
  'spotting':
      "Light spotting is common in early pregnancy and often turns out to be fine. But any bleeding in pregnancy, even a few spots, is a call to your doctor or maternity unit now. They can check what's causing it.",
  'discharge':
      "More discharge is normal in pregnancy. Thin, white or clear discharge with little smell is the healthy kind. Itching, a fishy smell, a grey, green or curd-like look, or any blood mean calling your doctor.",
  'breasts':
      "Sore, heavy, tingly breasts are very common, and often one of the first signs of pregnancy. The soreness usually eases after the first trimester. A soft, supportive bra helps, and any new lump should be shown to your doctor.",
  'leakyBreasts':
      "Leaking a little yellowish milk in the later months is normal. It's colostrum, your baby's first milk. Not leaking is normal too, and says nothing about how you'll feed.",
  'lightningCrotch':
      "Quick, sharp jabs in your vagina or pelvis are common in the last trimester, as your baby's head presses on nerves. They're usually harmless and pass in seconds. Pain that lasts, or comes with bleeding or regular tightenings, is a call.",
  'sciatica':
      "A shooting pain from your bottom down the back of your leg is fairly common in pregnancy. Stretches, warmth and a physiotherapist help, and it usually settles after birth. Numbness between your legs, or losing control of your bladder, is an emergency.",
  'blurryVision':
      "Slightly blurry vision is fairly common in pregnancy and usually goes back to normal after the birth. But blurred vision with a headache or swelling of your face or hands is an emergency. Call now.",
  'excessSaliva':
      "Having much more saliva than usual is fairly common in early pregnancy, often along with nausea. It's harmless and usually fades as the sickness does. Sugar-free gum makes it easier to swallow.",
  'redPalms':
      "Red palms and soles are common in pregnancy and harmless. Extra blood flow and hormones cause them, and they fade after the birth. Itching on your palms and soles is different, and needs a blood test the same day.",
  'clumsiness':
      "Feeling clumsy is very common in pregnancy, and it isn't you being careless. Your balance, joints and grip all change. Flat shoes and a little extra care help, and any fall onto your belly needs a check the same day.",
  'libido':
      "Wanting sex more, less, or not at all are all normal in pregnancy, and it can change from month to month. Talking to your partner helps. For most women sex is safe; ask your doctor if you've been told otherwise or had bleeding.",
  'diarrhoea':
      "Loose motions are fairly common, and usually pass in a day or two. The main thing is to drink enough, with ORS. Blood, a fever, or signs of drying out mean calling your doctor today.",
};

/// The extra sections, in order, after "What may help" and "Why does this
/// happen?". Appendix A items folded into existing pages carry the date.
const Map<String, List<SymptomPageSection>> kSymptomExtraSections = {
  // ---- new pages ---------------------------------------------------------
  'cramps': [
    SymptomPageSection(
      heading: 'Which cramps are normal?',
      paragraphs: [
        "In the first weeks, a mild ache low in your belly, like a light period, is common as your uterus grows. It comes and goes and eases when you rest.",
        "In the second trimester, a quick, sharp pull at the side when you move is usually the ligaments stretching. Gas, constipation and a full bladder can cause cramps at any stage.",
        "Later on, practice tightenings come and go and don't build up. A short cramp after sex is common too, and passes.",
      ],
    ),
    SymptomPageSection(
      heading: 'When should I go to hospital?',
      bullets: [
        'Cramps or belly pain with any bleeding or spotting.',
        'Pain on one side of your belly, especially in the first 12 weeks, or pain that spreads to the tip of your shoulder.',
        "Pain that's severe, or doesn't ease when you rest.",
        'Regular tightenings that get stronger or closer together before 37 weeks.',
        'Cramps with leaking fluid, a fever, or your baby moving less than usual.',
      ],
      paragraphs: [
        "If you're not sure, call. The labour ward would always rather hear from you. The full list of signs to call about at any hour is on this door's Talk tab.",
      ],
    ),
  ],
  'spotting': [
    SymptomPageSection(
      heading: 'Why call if it often turns out fine?',
      paragraphs: [
        "Most spotting in early pregnancy settles and the pregnancy carries on well. But bleeding can also be the first sign of something that needs care, such as an early loss, a pregnancy outside the womb, or later, a problem with the placenta. Nobody can tell which from home, so the check isn't optional.",
      ],
    ),
    SymptomPageSection(
      heading: 'What should I tell them?',
      bullets: [
        'How many weeks pregnant you are.',
        'How much: a few spots, a panty liner, or a pad.',
        'What colour: pink, red or brown.',
        'When it started, and whether you have pain, cramps or fluid with it.',
      ],
      paragraphs: [
        "The signs to call about at any hour are on this door's Talk tab, and \"I'm bleeding. Is that normal?\" below says exactly what to do.",
      ],
    ),
  ],
  'discharge': [
    SymptomPageSection(
      heading: 'What does normal discharge look like?',
      paragraphs: [
        'Healthy pregnancy discharge is thin or creamy, white or clear, and has a mild smell or none. It can be a little sticky or stretchy. There is usually more of it as the weeks go on, and most in the last weeks.',
        "Some women notice very little, and that's normal too. Discharge varies from one woman to the next.",
      ],
    ),
    SymptomPageSection(
      heading: 'Which colours and smells mean calling my doctor?',
      bullets: [
        "Thick, white and lumpy, like curd, with itching or soreness. This is often a yeast infection (thrush). It's easy to treat, but ask your doctor before using any cream or pessary. Call today.",
        'Thin, grey or white, with a fishy smell that is often stronger after sex. This can be an infection called bacterial vaginosis (BV). It matters more in pregnancy, so see your doctor for treatment. Call today.',
        'Yellow or green, frothy, or with a bad smell, burning or pain. Call your doctor today.',
        'Watery fluid that keeps coming, or a gush. Call your maternity unit now: it may be your waters.',
        'Pink, red or brown, or streaked with blood. Call now. Any bleeding is a call.',
      ],
    ),
    SymptomPageSection(
      heading: 'How should I keep clean down there?',
      paragraphs: [
        "Plain water on the outside (the vulva) is enough. The vagina keeps itself clean, and soaps, douches, scented washes and wipes can upset its balance and cause itching. Pat dry, wear cotton, and change damp underwear.",
      ],
    ),
  ],
  'breasts': [
    SymptomPageSection(
      heading: 'How else might my breasts change?',
      paragraphs: [
        'Your nipples and the skin around them (the areola) often get darker and bigger, and small bumps on the areola may stand out. Blue veins can show more.',
        "Some women's breasts grow a lot, and some hardly change. Both are normal. Size has nothing to do with how well you'll feed.",
      ],
    ),
    SymptomPageSection(
      heading: 'Is it normal to leak?',
      paragraphs: [
        "From the later months, some women leak a little yellowish milk (colostrum). Others don't leak at all, and that's normal too. There's a page on leaking breasts next to this one.",
      ],
    ),
    SymptomPageSection(
      heading: 'What if I find a lump?',
      paragraphs: [
        "Breasts get lumpier in pregnancy, and most lumps are harmless, such as a blocked duct or a small fluid-filled cyst. But please show your doctor any new lump. Don't wait until after the birth.",
      ],
    ),
  ],
  'sciatica': [
    SymptomPageSection(
      heading: 'Is this the same as back pain?',
      paragraphs: [
        "Not quite. Ordinary pregnancy back pain stays in your back. Sciatica shoots, burns or tingles from your bottom down the back of one leg, sometimes to your foot. The two can come together, and the same care helps both.",
      ],
    ),
  ],
  'blurryVision': [
    SymptomPageSection(
      heading: 'When is blurry vision an emergency?',
      bullets: [
        'Blurred vision, flashing lights or spots, with a headache that won\'t lift.',
        'Any change in your vision with sudden swelling of your face, hands or around your eyes.',
        'Any of these with pain under your right ribs.',
      ],
      paragraphs: [
        'These can be signs of high blood pressure in pregnancy (pre-eclampsia). Call your doctor or maternity unit now.',
      ],
    ),
  ],

  // ---- Appendix A, folded into pages we already had ----------------------
  // Chew sugarless gum (What to Expect, P3): extra saliva on the nausea page.
  'nausea': [
    SymptomPageSection(
      heading: 'Why is there so much saliva in my mouth?',
      paragraphs: [
        'Extra saliva often comes with early nausea. Sugar-free gum or a mint makes it easier to swallow. There is a page on it in Tummy and digestion.',
      ],
    ),
  ],
  // Cramping is often normal (What to Expect, P2): early cramps on the belly
  // pull page, pointing to the cramps page.
  'roundLigament': [
    SymptomPageSection(
      heading: 'What about cramps in the first weeks?',
      paragraphs: [
        "A mild, period-like ache in the first trimester is common as your uterus grows. Cramps with bleeding, pain on one side, or pain that doesn't ease mean going to hospital. The Belly cramps page has the full list.",
      ],
    ),
  ],
  // 3 Ways to Relieve Lightning Crotch (What to Expect, P3).
  'pelvicPressure': [
    SymptomPageSection(
      heading: 'What about sudden sharp jabs down below?',
      paragraphs: [
        'Quick, sharp jabs in the vagina or pelvis are common as your baby moves lower. Rocking your pelvis on hands and knees, circling your hips on a birthing ball, and a support belt can help. They should pass in seconds. Pain that lasts is a call to your doctor.',
      ],
    ),
  ],
  // Stretch to prevent sciatica (What to Expect, P3).
  'backPain': [
    SymptomPageSection(
      heading: 'What if the pain shoots down my leg?',
      paragraphs: [
        'That can be sciatica, a pressed nerve. Try this: sit on a chair, rest the ankle of the sore leg on the other knee, and lean forward gently until you feel a stretch in your bottom. Hold for about 30 seconds. The sciatica page has more.',
      ],
    ),
  ],
  // The Shoes You Need for Pregnancy (What to Expect, P3).
  'swelling': [
    SymptomPageSection(
      heading: 'Which shoes help?',
      paragraphs: [
        'Flat or low-heeled shoes with room to spare, soft straps or laces you can loosen, and a good grip. Feet are most swollen by evening, so try new shoes on then.',
      ],
    ),
  ],
  // Time for the Tooth Fairy again? (What to Expect, P3).
  'bleedingGums': [
    SymptomPageSection(
      heading: 'Why do my teeth feel a little loose?',
      paragraphs: [
        'Pregnancy hormones loosen the tissue that holds your teeth, so they can feel slightly wobbly. It usually settles after the birth. If it keeps on, or a tooth feels very loose, see a dentist.',
      ],
    ),
  ],
  // Pregnancy sex dreams explained (Flo, P3).
  'vividDreams': [
    SymptomPageSection(
      heading: 'Is it normal to have sex dreams?',
      paragraphs: [
        "Yes. Dreams of every kind are common in pregnancy, including sexual ones, and they're nothing to feel strange or guilty about.",
      ],
    ),
  ],
  // Foodie to food averse (Flo, P3): the tips; a real story is owed.
  'foodAversions': [
    SymptomPageSection(
      heading: 'What if I miss food I used to love?',
      paragraphs: [
        "It's hard when the smell of your favourite dal turns your stomach. Most aversions ease after the first trimester. Until then, eat what you can without guilt, and try the old favourite again every few weeks.",
      ],
    ),
  ],
  // Breast growth (and no breast growth) are both normal (What to Expect,
  // P3): lives on the new breasts page; a pointer here.
  'hairSkin': [
    SymptomPageSection(
      heading: 'What about my breasts?',
      paragraphs: [
        'Breast changes (soreness, darker nipples, growing or hardly growing) have their own page: Sore or tender breasts.',
      ],
    ),
  ],
};
