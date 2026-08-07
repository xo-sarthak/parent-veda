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
    keywords: ['morning sickness', 'vomiting', 'ulti', 'matli', 'सुबह की मिचली'],
    name: LocalizedText(en: 'Nausea', hi: 'मतली'),
    commonness: LocalizedText(
        en: 'Very common, especially in the first trimester.',
        hi: 'बहुत आम, ख़ासकर पहली तिमाही में।'),
    why: LocalizedText(
        en: 'Rising pregnancy hormones can upset your stomach, often in the morning.',
        hi: 'बढ़ते गर्भावस्था हार्मोन पेट को परेशान कर सकते हैं, अक्सर सुबह।'),
    tips: [
      LocalizedText(
          en: 'Eat small, frequent meals.', hi: 'थोड़ा-थोड़ा, बार-बार खाइए।'),
      LocalizedText(
          en: 'Keep dry snacks like crackers nearby.',
          hi: 'Crackers जैसे सूखे स्नैक्स पास रखिए।'),
      LocalizedText(en: 'Sip ginger or lemon water.', hi: 'अदरक या नींबू पानी पीजिए।'),
    ],
    doctorGuidance: LocalizedText(
        en: "If you can't keep fluids down or are losing weight, contact your doctor.",
        hi: 'अगर पानी भी न रुक पाए या वज़न गिर रहा हो, डॉक्टर से संपर्क कीजिए।'),
  ),
  Symptom(
    id: 'heartburn',
    category: SymptomCategory.digestive,
    trimesters: [2, 3],
    keywords: ['acidity', 'reflux', 'acid', 'jalan'],
    name: LocalizedText(en: 'Heartburn', hi: 'सीने में जलन'),
    commonness: LocalizedText(
        en: 'Very common in the second and third trimesters.',
        hi: 'दूसरी और तीसरी तिमाही में बहुत आम।'),
    why: LocalizedText(
        en: 'Hormones relax the valve to your stomach, and the growing uterus adds pressure.',
        hi: 'हार्मोन पेट के valve को ढीला करते हैं, और बढ़ती बच्चेदानी दबाव डालती है।'),
    tips: [
      LocalizedText(en: 'Eat smaller meals.', hi: 'छोटे भोजन खाइए।'),
      LocalizedText(
          en: 'Avoid lying down right after eating.',
          hi: 'खाने के तुरंत बाद मत लेटिए।'),
      LocalizedText(
          en: 'Notice and avoid trigger foods.',
          hi: 'परेशान करने वाले खाने पहचानिए और उनसे बचिए।'),
    ],
    doctorGuidance: LocalizedText(
        en: "If it's severe, persistent, or stops you eating or drinking, contact your doctor.",
        hi: 'अगर यह तेज़, लगातार हो या खाने-पीने में रुकावट दे, डॉक्टर से बात कीजिए।'),
  ),
  Symptom(
    id: 'constipation',
    category: SymptomCategory.digestive,
    keywords: ['kabz', 'bowel'],
    name: LocalizedText(en: 'Constipation', hi: 'क़ब्ज़'),
    commonness: LocalizedText(
        en: 'Common throughout pregnancy.', hi: 'पूरी गर्भावस्था में आम।'),
    why: LocalizedText(
        en: 'Pregnancy hormones slow digestion, and iron supplements can add to it.',
        hi: 'गर्भावस्था के हार्मोन पाचन धीमा करते हैं, और Iron सप्लीमेंट इसमें जोड़ सकते हैं।'),
    tips: [
      LocalizedText(en: 'Drink plenty of water.', hi: 'ख़ूब पानी पीजिए।'),
      LocalizedText(
          en: 'Eat fibre - fruit, vegetables, whole grains.',
          hi: 'Fibre खाइए — फल, सब्ज़ियाँ, साबुत अनाज।'),
      LocalizedText(
          en: 'Gentle daily movement helps.', hi: 'हल्की रोज़ाना हलचल मदद करती है।'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If it becomes painful or lasts despite these steps, ask your doctor.',
        hi: 'अगर दर्द हो या इन उपायों के बाद भी रहे, डॉक्टर से पूछिए।'),
  ),

  // ---- Physical -------------------------------------------------------------
  Symptom(
    id: 'fatigue',
    category: SymptomCategory.physical,
    trimesters: [1, 3],
    keywords: ['tiredness', 'thakaan', 'low energy', 'थकान'],
    name: LocalizedText(en: 'Fatigue', hi: 'थकान'),
    commonness: LocalizedText(
        en: 'Very common, especially early and late in pregnancy.',
        hi: 'बहुत आम, ख़ासकर गर्भावस्था की शुरुआत और अंत में।'),
    why: LocalizedText(
        en: "Your body is working hard to support your baby's growth.",
        hi: 'आपका शरीर शिशु की बढ़त के लिए बहुत मेहनत कर रहा है।'),
    tips: [
      LocalizedText(en: 'Rest when your body asks.', hi: 'जब शरीर कहे, आराम कीजिए।'),
      LocalizedText(en: 'Short naps can help.', hi: 'छोटी झपकी मदद करती है।'),
      LocalizedText(
          en: 'Stay hydrated and eat regularly.',
          hi: 'पानी पीती रहिए और समय पर खाइए।'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If you feel breathless, dizzy or unusually exhausted, mention it to your doctor.',
        hi: 'अगर साँस फूले, चक्कर आए या बहुत ज़्यादा थकान हो, डॉक्टर को बताइए।'),
  ),
  Symptom(
    id: 'backPain',
    category: SymptomCategory.physical,
    trimesters: [2, 3],
    keywords: ['back ache', 'kamar dard', 'कमर दर्द', 'पीठ दर्द'],
    name: LocalizedText(en: 'Back Pain', hi: 'कमर दर्द'),
    commonness: LocalizedText(
        en: 'Common as your bump grows.', hi: 'बंप बढ़ने के साथ आम।'),
    why: LocalizedText(
        en: 'Extra weight and shifting posture put strain on your back.',
        hi: 'ज़्यादा वज़न और बदलती मुद्रा कमर पर ज़ोर डालती है।'),
    tips: [
      LocalizedText(en: 'Support your back when sitting.', hi: 'बैठते वक़्त कमर को सहारा दीजिए।'),
      LocalizedText(en: 'Wear flat, comfortable shoes.', hi: 'सपाट, आरामदायक जूते पहनिए।'),
      LocalizedText(en: 'Gentle stretches and walking.', hi: 'हल्के stretches और चलना।'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If pain is severe, sudden, or with other symptoms, contact your doctor.',
        hi: 'अगर दर्द तेज़, अचानक या दूसरे लक्षणों के साथ हो, डॉक्टर से संपर्क कीजिए।'),
  ),
  Symptom(
    id: 'headache',
    category: SymptomCategory.physical,
    keywords: ['sir dard', 'migraine', 'सिर दर्द'],
    name: LocalizedText(en: 'Headache', hi: 'सिर दर्द'),
    commonness: LocalizedText(
        en: 'Fairly common, often early in pregnancy.',
        hi: 'काफ़ी आम, अक्सर गर्भावस्था की शुरुआत में।'),
    why: LocalizedText(
        en: 'Hormones, tiredness and changes in blood flow can trigger headaches.',
        hi: 'हार्मोन, थकान और ख़ून के बहाव के बदलाव सिर दर्द ला सकते हैं।'),
    tips: [
      LocalizedText(en: 'Rest in a quiet, dark room.', hi: 'शांत, अँधेरे कमरे में आराम कीजिए।'),
      LocalizedText(
          en: 'Stay hydrated and eat regularly.',
          hi: 'पानी पीती रहिए और समय पर खाइए।'),
      LocalizedText(
          en: 'Gentle neck and shoulder relaxation.',
          hi: 'गर्दन और कंधे को हल्का ढीला कीजिए।'),
    ],
    doctorGuidance: LocalizedText(
        en: 'A severe headache, or one with blurred vision or swelling, needs prompt medical attention.',
        hi: 'तेज़ सिर दर्द, या धुँधली नज़र/सूजन के साथ हो, तो तुरंत मेडिकल मदद लीजिए।'),
  ),

  // ---- Sleep ----------------------------------------------------------------
  Symptom(
    id: 'troubleSleeping',
    category: SymptomCategory.sleep,
    trimesters: [3],
    keywords: ['insomnia', 'neend', 'sleep'],
    name: LocalizedText(en: 'Trouble Sleeping', hi: 'नींद न आना'),
    commonness: LocalizedText(
        en: 'Common, especially later in pregnancy.',
        hi: 'आम, ख़ासकर गर्भावस्था के बाद के हिस्से में।'),
    why: LocalizedText(
        en: 'A growing bump, movements and frequent urination can disrupt sleep.',
        hi: 'बढ़ता बंप, हलचल और बार-बार पेशाब नींद ख़राब कर सकते हैं।'),
    tips: [
      LocalizedText(en: 'Try a pillow between your knees.', hi: 'घुटनों के बीच तकिया रखिए।'),
      LocalizedText(en: 'Wind down calmly before bed.', hi: 'सोने से पहले शांति से ढीला पड़िए।'),
      LocalizedText(en: 'Rest during the day when you can.', hi: 'दिन में जब मिले आराम कीजिए।'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If sleeplessness is severe or you feel very low, talk to your doctor.',
        hi: 'अगर नींद बिलकुल न आए या बहुत उदासी हो, डॉक्टर से बात कीजिए।'),
  ),

  // ---- Emotional ------------------------------------------------------------
  Symptom(
    id: 'moodSwings',
    category: SymptomCategory.emotional,
    keywords: ['mood', 'emotions', 'crying', 'rona'],
    name: LocalizedText(en: 'Mood Swings', hi: 'मन का बदलना'),
    commonness: LocalizedText(
        en: 'Very common throughout pregnancy.',
        hi: 'पूरी गर्भावस्था में बहुत आम।'),
    why: LocalizedText(
        en: 'Hormonal changes and big life changes can shift your emotions.',
        hi: 'हार्मोन के बदलाव और ज़िंदगी के बड़े बदलाव भावनाएँ बदल सकते हैं।'),
    tips: [
      LocalizedText(en: 'Be gentle with yourself.', hi: 'ख़ुद पर नरमी रखिए।'),
      LocalizedText(en: 'Talk to someone you trust.', hi: 'किसी अपने से बात कीजिए।'),
      LocalizedText(en: 'Rest and small joys help.', hi: 'आराम और छोटी ख़ुशियाँ मदद करती हैं।'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If you feel persistently low, anxious or unable to cope, please reach out to your doctor.',
        hi: 'अगर लगातार उदासी, घबराहट या सँभालना मुश्किल लगे, डॉक्टर से ज़रूर बात कीजिए।'),
  ),

  // ---- Circulation ----------------------------------------------------------
  Symptom(
    id: 'swelling',
    category: SymptomCategory.circulation,
    trimesters: [3],
    keywords: ['edema', 'soojan', 'puffiness'],
    name: LocalizedText(en: 'Swelling', hi: 'सूजन'),
    commonness: LocalizedText(
        en: 'Common in the third trimester, especially feet and ankles.',
        hi: 'तीसरी तिमाही में आम, ख़ासकर पैरों और टख़नों में।'),
    why: LocalizedText(
        en: 'Your body holds more fluid, and the growing uterus slows blood return.',
        hi: 'शरीर ज़्यादा तरल रखता है, और बढ़ती बच्चेदानी ख़ून की वापसी धीमी करती है।'),
    tips: [
      LocalizedText(en: 'Put your feet up when you can.', hi: 'जब मिले पैर ऊपर रखिए।'),
      LocalizedText(en: 'Stay hydrated.', hi: 'पानी पीती रहिए।'),
      LocalizedText(en: 'Avoid standing for long periods.', hi: 'लंबे समय खड़ी मत रहिए।'),
    ],
    doctorGuidance: LocalizedText(
        en: 'Sudden swelling of the face or hands, or with a headache, needs prompt medical advice.',
        hi: 'चेहरे/हाथों की अचानक सूजन, या सिर दर्द के साथ, तो तुरंत डॉक्टर की सलाह लीजिए।'),
  ),
  Symptom(
    id: 'legCramps',
    category: SymptomCategory.circulation,
    trimesters: [2, 3],
    keywords: ['cramp', 'leg cramp', 'cramps', 'पैर में ऐंठन'],
    name: LocalizedText(en: 'Leg Cramps', hi: 'टाँग की ऐंठन'),
    commonness: LocalizedText(
        en: 'Common, often at night in later pregnancy.',
        hi: 'आम, अक्सर रात को गर्भावस्था के बाद के दौर में।'),
    why: LocalizedText(
        en: 'Changes in circulation and minerals can cause muscle cramps.',
        hi: 'रक्त-संचार और खनिजों के बदलाव मांसपेशियों में ऐंठन ला सकते हैं।'),
    tips: [
      LocalizedText(en: 'Gently stretch the calf.', hi: 'पिंडली को हल्का stretch कीजिए।'),
      LocalizedText(en: 'Stay hydrated.', hi: 'पानी पीती रहिए।'),
      LocalizedText(en: 'Gentle daily movement.', hi: 'हल्की रोज़ाना हलचल।'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If a leg is red, swollen, warm or painful, contact your doctor promptly.',
        hi: 'अगर टाँग लाल, सूजी, गरम या दर्द भरी हो, तुरंत डॉक्टर से संपर्क कीजिए।'),
  ),

  // ---- Baby movement --------------------------------------------------------
  Symptom(
    id: 'babyHiccups',
    category: SymptomCategory.movement,
    trimesters: [3],
    keywords: ['hiccups', 'baby movement', 'fluttering', 'शिशु की हलचल'],
    name: LocalizedText(en: "Baby's Hiccups", hi: 'शिशु की हिचकी'),
    commonness: LocalizedText(
        en: 'Common and usually a healthy sign in the third trimester.',
        hi: 'आम और अक्सर तीसरी तिमाही में सेहतमंद संकेत।'),
    why: LocalizedText(
        en: 'Your baby practises breathing, which can feel like little rhythmic jumps.',
        hi: 'आपका शिशु साँस का अभ्यास करता है, जो छोटी लयबद्ध कूद जैसी लग सकती है।'),
    tips: [
      LocalizedText(
          en: "Enjoy the moment - it's usually a reassuring sign.",
          hi: 'इस पल का आनंद लीजिए — यह अक्सर तसल्ली देने वाला संकेत है।'),
    ],
    doctorGuidance: LocalizedText(
        en: "If you're ever worried about a change in your baby's movements, contact your maternity unit.",
        hi: 'अगर कभी शिशु की हलचल में बदलाव की चिंता हो, मैटरनिटी यूनिट से संपर्क कीजिए।'),
  ),

  // ---- Labour signs ---------------------------------------------------------
  Symptom(
    id: 'braxtonHicks',
    category: SymptomCategory.labour,
    trimesters: [3],
    keywords: ['practice contractions', 'false labour', 'tightening', 'झूठे संकुचन', 'झूठा दर्द'],
    name: LocalizedText(en: 'Braxton Hicks', hi: 'Braxton Hicks'),
    commonness: LocalizedText(
        en: 'Common in the third trimester.', hi: 'तीसरी तिमाही में आम।'),
    why: LocalizedText(
        en: "Your uterus 'practises' with irregular, usually painless tightenings.",
        hi: 'आपकी बच्चेदानी अनियमित, अक्सर बिना दर्द के कसाव से "अभ्यास" करती है।'),
    tips: [
      LocalizedText(en: 'Change position or rest.', hi: 'मुद्रा बदलिए या आराम कीजिए।'),
      LocalizedText(en: 'Drink water.', hi: 'पानी पीजिए।'),
      LocalizedText(en: 'Breathe slowly through them.', hi: 'इनके दौरान धीरे साँस लीजिए।'),
    ],
    doctorGuidance: LocalizedText(
        en: 'If tightenings become regular, painful or frequent, contact your doctor.',
        hi: 'अगर कसाव नियमित, दर्द भरे या बार-बार हों, डॉक्टर से संपर्क कीजिए।'),
  ),

  // ---- Urgent (calm, clear guidance - no panic language) --------------------
  Symptom(
    id: 'u_bleeding',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['bleeding', 'blood', 'khoon'],
    name: LocalizedText(en: 'Heavy Bleeding', hi: 'तेज़ ब्लीडिंग'),
    commonness: LocalizedText(
        en: 'This is one to act on, not wait on.',
        hi: 'इस पर इंतज़ार नहीं, तुरंत क़दम उठाइए।'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: 'Heavy vaginal bleeding needs urgent care - contact your doctor or maternity unit now.',
        hi: 'तेज़ vaginal bleeding के लिए तुरंत देखभाल चाहिए — अभी डॉक्टर या मैटरनिटी यूनिट से संपर्क कीजिए।'),
  ),
  Symptom(
    id: 'u_movement',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['reduced movement', 'no movement', 'harkat', 'हलचल कम', 'हलचल नहीं'],
    name: LocalizedText(
        en: "Reduced Baby Movement", hi: 'शिशु की हलचल कम'),
    commonness: LocalizedText(
        en: 'Always worth checking - never feel you are overreacting.',
        hi: 'हमेशा जाँचने लायक़ — कभी मत सोचिए कि आप ज़्यादा प्रतिक्रिया कर रही हैं।'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: "If your baby's movements slow or change noticeably, contact your maternity unit straight away - any time, day or night.",
        hi: 'अगर शिशु की हलचल धीमी हो या साफ़ तौर पर बदले, तुरंत मैटरनिटी यूनिट से संपर्क कीजिए — कभी भी, दिन हो या रात।'),
  ),
  Symptom(
    id: 'u_headache',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['severe headache', 'vision', 'tej sir dard', 'तेज सिर दर्द', 'सिर में तेज दर्द'],
    name: LocalizedText(en: 'Severe Headache', hi: 'तेज़ सिर दर्द'),
    commonness: LocalizedText(
        en: 'Especially with vision changes or swelling.',
        hi: 'ख़ासकर नज़र में बदलाव या सूजन के साथ।'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: 'A severe headache, especially with blurred vision or swelling, can be serious - seek medical care promptly.',
        hi: 'तेज़ सिर दर्द, ख़ासकर धुँधली नज़र या सूजन के साथ, गंभीर हो सकता है — तुरंत मेडिकल देखभाल लीजिए।'),
  ),
  Symptom(
    id: 'u_swelling',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['sudden swelling', 'face swelling', 'achaanak soojan', 'अचानक सूजन', 'चेहरे पर सूजन', 'अचानक सूजना'],
    name: LocalizedText(en: 'Sudden Swelling', hi: 'अचानक सूजन'),
    commonness: LocalizedText(
        en: 'Sudden swelling of the face, hands or feet.',
        hi: 'चेहरे, हाथों या पैरों की अचानक सूजन।'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: 'Sudden swelling can need urgent review - contact your doctor.',
        hi: 'अचानक सूजन के लिए तुरंत जाँच ज़रूरी हो सकती है — डॉक्टर से संपर्क कीजिए।'),
  ),
  Symptom(
    id: 'u_fluid',
    category: SymptomCategory.urgent,
    urgent: true,
    keywords: ['water broke', 'fluid leak', 'paani', 'पानी फटना', 'पानी रिसना'],
    name: LocalizedText(en: 'Fluid Leakage', hi: 'तरल का रिसाव'),
    commonness: LocalizedText(
        en: 'A gush or steady leak of fluid.',
        hi: 'तरल का अचानक बहाव या लगातार रिसाव।'),
    why: LocalizedText(en: '', hi: ''),
    tips: [],
    doctorGuidance: LocalizedText(
        en: 'A gush or steady leak of fluid may mean your waters have broken - contact your maternity unit.',
        hi: 'तरल का बहाव या रिसाव मतलब आपका पानी टूट सकता है — मैटरनिटी यूनिट से संपर्क कीजिए।'),
  ),
];
