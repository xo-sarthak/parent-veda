// =============================================================================
//  Symptom content (bilingual) - "Symptoms Companion"
// -----------------------------------------------------------------------------
//  Educational + reassurance only. Never diagnosis. Calm, human language; the
//  doctor is always the authority. Urgent symptoms use clear, non-alarming
//  guidance. Easy to extend - this is just data.
// =============================================================================

import '../localization/app_language.dart';
import '../models/symptom.dart';

const List<Symptom> kSymptoms = [
  // ---- Digestive ------------------------------------------------------------
  Symptom(
    id: 'nausea',
    category: SymptomCategory.digestive,
    trimesters: [1, 2],
    keywords: ['morning sickness', 'vomiting', 'ulti', 'matli'],
    name: LocalizedText(en: 'Nausea', hi: 'Matli'),
    commonness: LocalizedText(
        en: 'Very common, especially in the first trimester.',
        hi: 'Bahut aam, khaaskar pehli trimester mein.'),
    why: LocalizedText(
        en: 'Rising pregnancy hormones can upset your stomach, often in the morning.',
        hi: 'Badhte pregnancy hormones pet ko pareshaan kar sakte hain, aksar subah.'),
    tips: [
      LocalizedText(
          en: 'Eat small, frequent meals.', hi: 'Thode-thode, baar-baar khaayein.'),
      LocalizedText(
          en: 'Keep dry snacks like crackers nearby.',
          hi: 'Crackers jaise sookhe snacks paas rakhein.'),
      LocalizedText(en: 'Sip ginger or lemon water.', hi: 'Adrak ya nimbu paani piyein.'),
    ],
    doctorGuidance: LocalizedText(
        en: "If you can't keep fluids down or are losing weight, contact your doctor.",
        hi: 'Agar paani bhi na ruk paaye ya wazan gir raha ho, doctor se sampark karein.'),
  ),
  Symptom(
    id: 'heartburn',
    category: SymptomCategory.digestive,
    trimesters: [2, 3],
    keywords: ['acidity', 'reflux', 'acid', 'jalan'],
    name: LocalizedText(en: 'Heartburn', hi: 'Heartburn'),
    commonness: LocalizedText(
        en: 'Very common in the second and third trimesters.',
        hi: 'Doosri aur teesri trimester mein bahut aam.'),
    why: LocalizedText(
        en: 'Hormones relax the valve to your stomach, and the growing uterus adds pressure.',
        hi: 'Hormones pet ke valve ko dheela karte hain, aur badhta uterus dabaav daalta hai.'),
    tips: [
      LocalizedText(en: 'Eat smaller meals.', hi: 'Chhote meals khaayein.'),
      LocalizedText(
          en: 'Avoid lying down right after eating.',
          hi: 'Khaane ke turant baad na letein.'),
      LocalizedText(
          en: 'Notice and avoid trigger foods.',
          hi: 'Trigger karne wale foods pehchaanein aur avoid karein.'),
    ],
    doctorGuidance: LocalizedText(
        en: "If it's severe, persistent, or stops you eating or drinking, contact your doctor.",
        hi: 'Agar yeh tej, lagaataar ho ya khaane-peene mein rukaawat de, doctor se baat karein.'),
  ),
  Symptom(
    id: 'constipation',
    category: SymptomCategory.digestive,
    keywords: ['kabz', 'bowel'],
    name: LocalizedText(en: 'Constipation', hi: 'Kabz'),
    commonness: LocalizedText(
        en: 'Common throughout pregnancy.', hi: 'Poori pregnancy mein aam.'),
    why: LocalizedText(
        en: 'Pregnancy hormones slow digestion, and iron supplements can add to it.',
        hi: 'Pregnancy hormones digestion dheema karte hain, aur iron supplements isme jod sakte hain.'),
    tips: [
      LocalizedText(en: 'Drink plenty of water.', hi: 'Khoob paani piyein.'),
      LocalizedText(
          en: 'Eat fibre - fruit, vegetables, whole grains.',
          hi: 'Fibre khaayein - phal, sabziyan, saabut anaaj.'),
      LocalizedText(
          en: 'Gentle daily movement helps.', hi: 'Halki rozaana harkat madad karti hai.'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If it becomes painful or lasts despite these steps, ask your doctor.',
        hi: 'Agar dard ho ya in upaayon ke baad bhi rahe, doctor se poochein.'),
  ),

  // ---- Physical -------------------------------------------------------------
  Symptom(
    id: 'fatigue',
    category: SymptomCategory.physical,
    trimesters: [1, 3],
    keywords: ['tiredness', 'thakaan', 'low energy'],
    name: LocalizedText(en: 'Fatigue', hi: 'Thakaan'),
    commonness: LocalizedText(
        en: 'Very common, especially early and late in pregnancy.',
        hi: 'Bahut aam, khaaskar pregnancy ki shuruaat aur ant mein.'),
    why: LocalizedText(
        en: "Your body is working hard to support your baby's growth.",
        hi: 'Aapka sharir baby ki growth ke liye bahut mehnat kar raha hai.'),
    tips: [
      LocalizedText(en: 'Rest when your body asks.', hi: 'Jab sharir kahe, aaram karein.'),
      LocalizedText(en: 'Short naps can help.', hi: 'Chhoti jhapki madad karti hai.'),
      LocalizedText(
          en: 'Stay hydrated and eat regularly.',
          hi: 'Paani peete rahein aur samay par khaayein.'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If you feel breathless, dizzy or unusually exhausted, mention it to your doctor.',
        hi: 'Agar saans phoole, chakkar aaye ya bahut zyada thakaan ho, doctor ko bataayein.'),
  ),
  Symptom(
    id: 'backPain',
    category: SymptomCategory.physical,
    trimesters: [2, 3],
    keywords: ['back ache', 'kamar dard'],
    name: LocalizedText(en: 'Back Pain', hi: 'Kamar Dard'),
    commonness: LocalizedText(
        en: 'Common as your bump grows.', hi: 'Bump badhne ke saath aam.'),
    why: LocalizedText(
        en: 'Extra weight and shifting posture put strain on your back.',
        hi: 'Zyada wazan aur badalti posture kamar par zor daalti hai.'),
    tips: [
      LocalizedText(en: 'Support your back when sitting.', hi: 'Baithte waqt kamar ko sahaara dein.'),
      LocalizedText(en: 'Wear flat, comfortable shoes.', hi: 'Flat, aaraamdayak joote pehnein.'),
      LocalizedText(en: 'Gentle stretches and walking.', hi: 'Halke stretches aur chalna.'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If pain is severe, sudden, or with other symptoms, contact your doctor.',
        hi: 'Agar dard tej, achaanak ya doosre lakshanon ke saath ho, doctor se sampark karein.'),
  ),
  Symptom(
    id: 'headache',
    category: SymptomCategory.physical,
    keywords: ['sir dard', 'migraine'],
    name: LocalizedText(en: 'Headache', hi: 'Sir Dard'),
    commonness: LocalizedText(
        en: 'Fairly common, often early in pregnancy.',
        hi: 'Kaafi aam, aksar pregnancy ki shuruaat mein.'),
    why: LocalizedText(
        en: 'Hormones, tiredness and changes in blood flow can trigger headaches.',
        hi: 'Hormones, thakaan aur blood flow ke badlaav sir dard la sakte hain.'),
    tips: [
      LocalizedText(en: 'Rest in a quiet, dark room.', hi: 'Shaant, andhere kamre mein aaram karein.'),
      LocalizedText(
          en: 'Stay hydrated and eat regularly.',
          hi: 'Paani peete rahein aur samay par khaayein.'),
      LocalizedText(
          en: 'Gentle neck and shoulder relaxation.',
          hi: 'Gardan aur kandhe ko halka relax karein.'),
    ],
    doctorGuidance: LocalizedText(
        en: 'A severe headache, or one with blurred vision or swelling, needs prompt medical attention.',
        hi: 'Tej sir dard, ya dhundhli nazar/soojan ke saath ho, toh turant medical madad lein.'),
  ),

  // ---- Sleep ----------------------------------------------------------------
  Symptom(
    id: 'troubleSleeping',
    category: SymptomCategory.sleep,
    trimesters: [3],
    keywords: ['insomnia', 'neend', 'sleep'],
    name: LocalizedText(en: 'Trouble Sleeping', hi: 'Neend Na Aana'),
    commonness: LocalizedText(
        en: 'Common, especially later in pregnancy.',
        hi: 'Aam, khaaskar pregnancy ke baad ke hisse mein.'),
    why: LocalizedText(
        en: 'A growing bump, movements and frequent urination can disrupt sleep.',
        hi: 'Badhta bump, harkatein aur baar-baar peshaab neend kharaab kar sakte hain.'),
    tips: [
      LocalizedText(en: 'Try a pillow between your knees.', hi: 'Ghutno ke beech takiya rakhein.'),
      LocalizedText(en: 'Wind down calmly before bed.', hi: 'Sone se pehle shaanti se relax karein.'),
      LocalizedText(en: 'Rest during the day when you can.', hi: 'Din mein jab mile aaram karein.'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If sleeplessness is severe or you feel very low, talk to your doctor.',
        hi: 'Agar neend bilkul na aaye ya bahut udaasi ho, doctor se baat karein.'),
  ),

  // ---- Emotional ------------------------------------------------------------
  Symptom(
    id: 'moodSwings',
    category: SymptomCategory.emotional,
    keywords: ['mood', 'emotions', 'crying', 'rona'],
    name: LocalizedText(en: 'Mood Swings', hi: 'Mood Badalna'),
    commonness: LocalizedText(
        en: 'Very common throughout pregnancy.',
        hi: 'Poori pregnancy mein bahut aam.'),
    why: LocalizedText(
        en: 'Hormonal changes and big life changes can shift your emotions.',
        hi: 'Hormonal badlaav aur zindagi ke bade badlaav bhaavnaayein badal sakte hain.'),
    tips: [
      LocalizedText(en: 'Be gentle with yourself.', hi: 'Khud par narmi rakhein.'),
      LocalizedText(en: 'Talk to someone you trust.', hi: 'Kisi apne se baat karein.'),
      LocalizedText(en: 'Rest and small joys help.', hi: 'Aaram aur chhoti khushiyan madad karti hain.'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If you feel persistently low, anxious or unable to cope, please reach out to your doctor.',
        hi: 'Agar lagaataar udaasi, ghabraahat ya sambhaalna mushkil lage, doctor se zaroor baat karein.'),
  ),

  // ---- Circulation ----------------------------------------------------------
  Symptom(
    id: 'swelling',
    category: SymptomCategory.circulation,
    trimesters: [3],
    keywords: ['edema', 'soojan', 'puffiness'],
    name: LocalizedText(en: 'Swelling', hi: 'Soojan'),
    commonness: LocalizedText(
        en: 'Common in the third trimester, especially feet and ankles.',
        hi: 'Teesri trimester mein aam, khaaskar pairon aur takhno mein.'),
    why: LocalizedText(
        en: 'Your body holds more fluid, and the growing uterus slows blood return.',
        hi: 'Sharir zyada fluid rakhta hai, aur badhta uterus blood ki waapsi dheemi karta hai.'),
    tips: [
      LocalizedText(en: 'Put your feet up when you can.', hi: 'Jab mile pair upar rakhein.'),
      LocalizedText(en: 'Stay hydrated.', hi: 'Paani peete rahein.'),
      LocalizedText(en: 'Avoid standing for long periods.', hi: 'Lambe samay khade na rahein.'),
    ],
    doctorGuidance: LocalizedText(
        en: 'Sudden swelling of the face or hands, or with a headache, needs prompt medical advice.',
        hi: 'Chehre/haathon ki achaanak soojan, ya sir dard ke saath, toh turant doctor ki salah lein.'),
  ),
  Symptom(
    id: 'legCramps',
    category: SymptomCategory.circulation,
    trimesters: [2, 3],
    keywords: ['cramp', 'leg cramp', 'cramps'],
    name: LocalizedText(en: 'Leg Cramps', hi: 'Taang Ki Cramp'),
    commonness: LocalizedText(
        en: 'Common, often at night in later pregnancy.',
        hi: 'Aam, aksar raat ko later pregnancy mein.'),
    why: LocalizedText(
        en: 'Changes in circulation and minerals can cause muscle cramps.',
        hi: 'Circulation aur minerals ke badlaav muscle cramps la sakte hain.'),
    tips: [
      LocalizedText(en: 'Gently stretch the calf.', hi: 'Pindli ko halka stretch karein.'),
      LocalizedText(en: 'Stay hydrated.', hi: 'Paani peete rahein.'),
      LocalizedText(en: 'Gentle daily movement.', hi: 'Halki rozaana harkat.'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If a leg is red, swollen, warm or painful, contact your doctor promptly.',
        hi: 'Agar taang laal, soojan-bhari, garam ya dard-bhari ho, turant doctor se sampark karein.'),
  ),

  // ---- Baby movement --------------------------------------------------------
  Symptom(
    id: 'babyHiccups',
    category: SymptomCategory.movement,
    trimesters: [3],
    keywords: ['hiccups', 'baby movement', 'fluttering'],
    name: LocalizedText(en: "Baby's Hiccups", hi: 'Baby Ki Hichki'),
    commonness: LocalizedText(
        en: 'Common and usually a healthy sign in the third trimester.',
        hi: 'Aam aur aksar teesri trimester mein sehatmand sanket.'),
    why: LocalizedText(
        en: 'Your baby practises breathing, which can feel like little rhythmic jumps.',
        hi: 'Aapka baby saans ki practice karta hai, jo chhoti lai-bhari kudaan jaisi lag sakti hai.'),
    tips: [
      LocalizedText(
          en: "Enjoy the moment - it's usually a reassuring sign.",
          hi: 'Is pal ka aanand lein - yeh aksar tasalli dene wala sanket hai.'),
    ],
    doctorGuidance: LocalizedText(
        en: "If you're ever worried about a change in your baby's movements, contact your maternity unit.",
        hi: 'Agar kabhi baby ki harkat mein badlaav ki chinta ho, maternity unit se sampark karein.'),
  ),

  // ---- Labour signs ---------------------------------------------------------
  Symptom(
    id: 'braxtonHicks',
    category: SymptomCategory.labour,
    trimesters: [3],
    keywords: ['practice contractions', 'false labour', 'tightening'],
    name: LocalizedText(en: 'Braxton Hicks', hi: 'Braxton Hicks'),
    commonness: LocalizedText(
        en: 'Common in the third trimester.', hi: 'Teesri trimester mein aam.'),
    why: LocalizedText(
        en: "Your uterus 'practises' with irregular, usually painless tightenings.",
        hi: 'Aapka uterus anyamit, aksar bina-dard ke kasaav se "practice" karta hai.'),
    tips: [
      LocalizedText(en: 'Change position or rest.', hi: 'Position badlein ya aaram karein.'),
      LocalizedText(en: 'Drink water.', hi: 'Paani piyein.'),
      LocalizedText(en: 'Breathe slowly through them.', hi: 'Inke dauraan dheere saans lein.'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If tightenings become regular, painful or frequent, contact your doctor.',
        hi: 'Agar kasaav niyamit, dard-bhare ya baar-baar ho, doctor se sampark karein.'),
  ),

  // ---- Urgent (calm, clear guidance - no panic language) --------------------
  Symptom(
    id: 'u_bleeding',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['bleeding', 'blood', 'khoon'],
    name: LocalizedText(en: 'Heavy Bleeding', hi: 'Tej Bleeding'),
    commonness: LocalizedText(
        en: 'This is one to act on, not wait on.',
        hi: 'Is par intezaar nahi, turant kadam uthayein.'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: 'Heavy vaginal bleeding needs urgent care - contact your doctor or maternity unit now.',
        hi: 'Tej vaginal bleeding ke liye turant care chahiye - abhi doctor ya maternity unit se sampark karein.'),
  ),
  Symptom(
    id: 'u_movement',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['reduced movement', 'no movement', 'harkat'],
    name: LocalizedText(
        en: "Reduced Baby Movement", hi: 'Baby Ki Harkat Kam'),
    commonness: LocalizedText(
        en: 'Always worth checking - never feel you are overreacting.',
        hi: 'Hamesha check karne layak - kabhi na sochein ki aap zyada react kar rahi hain.'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: "If your baby's movements slow or change noticeably, contact your maternity unit straight away - any time, day or night.",
        hi: 'Agar baby ki harkat dheemi ya saaf taur par badle, turant maternity unit se sampark karein - kabhi bhi, din ya raat.'),
  ),
  Symptom(
    id: 'u_headache',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['severe headache', 'vision', 'tej sir dard'],
    name: LocalizedText(en: 'Severe Headache', hi: 'Tej Sir Dard'),
    commonness: LocalizedText(
        en: 'Especially with vision changes or swelling.',
        hi: 'Khaaskar nazar mein badlaav ya soojan ke saath.'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: 'A severe headache, especially with blurred vision or swelling, can be serious - seek medical care promptly.',
        hi: 'Tej sir dard, khaaskar dhundhli nazar ya soojan ke saath, gambhir ho sakta hai - turant medical care lein.'),
  ),
  Symptom(
    id: 'u_swelling',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['sudden swelling', 'face swelling', 'achaanak soojan'],
    name: LocalizedText(en: 'Sudden Swelling', hi: 'Achaanak Soojan'),
    commonness: LocalizedText(
        en: 'Sudden swelling of the face, hands or feet.',
        hi: 'Chehre, haathon ya pairon ki achaanak soojan.'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: 'Sudden swelling can need urgent review - contact your doctor.',
        hi: 'Achaanak soojan ke liye turant jaanch zaroori ho sakti hai - doctor se sampark karein.'),
  ),
  Symptom(
    id: 'u_fluid',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['water broke', 'fluid leak', 'paani'],
    name: LocalizedText(en: 'Fluid Leakage', hi: 'Fluid Ka Risaav'),
    commonness: LocalizedText(
        en: 'A gush or steady leak of fluid.',
        hi: 'Fluid ka achaanak behaav ya lagaataar risaav.'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: 'A gush or steady leak of fluid may mean your waters have broken - contact your maternity unit.',
        hi: 'Fluid ka behaav ya risaav matlab aapka paani toot sakta hai - maternity unit se sampark karein.'),
  ),
];
