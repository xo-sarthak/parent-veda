// =============================================================================
//  veda_showcase - curated, structured "showcase" answers for Ask Veda
// -----------------------------------------------------------------------------
//  The product doc specifies a FIXED structured result page (Veda Answer → what
//  it means → next actions → ParentVeda content → community → products →
//  services). We can't yet generate that for every question (no LLM backend), so
//  these are 5 hand-authored, web-researched answers that demo the full format.
//  When the question matches one of these, Ask Veda returns the structured card;
//  everything else falls through to the offline whole-app retrieval.
//
//  Content is general guidance written for ParentVeda (informed by NHS / Tommy's
//  / Mayo Clinic guidance) - never a diagnosis; the doctor disclaimer always
//  shows, and the reduced-movements entry is emergency-aware.
// =============================================================================

import '../localization/app_language.dart';

class VedaShowcase {
  const VedaShowcase({
    required this.id,
    required this.question,
    required this.keywords,
    this.urgent = false,
    required this.answer,
    required this.meaning,
    required this.actions,
    required this.pvContent,
    required this.community,
    this.products = const [],
    required this.services,
  });

  final String id;
  final LocalizedText question; // the showcase question (shown to the user)
  final List<String> keywords; // lowercase match terms
  final bool urgent; // emergency-aware → red banner
  final LocalizedText answer; // S1 - the single best answer
  final LocalizedText meaning; // S2 - what this means for you
  final List<LocalizedText> actions; // S3 - recommended next actions
  final List<LocalizedText> pvContent; // S4 - ParentVeda content/tools
  final LocalizedText community; // S5 - community insight
  final List<LocalizedText> products; // S6 - products (may be empty → hide)
  final List<LocalizedText> services; // S7 - services
}

const List<VedaShowcase> kVedaShowcase = [
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'anomaly_scan',
    question: LocalizedText(
        en: 'When should I have my anomaly scan?',
        hi: 'मेरा anomaly scan कब होना चाहिए?'),
    keywords: [
      'anomaly scan',
      '20 week scan',
      'mid pregnancy scan',
      'anomaly',
      'scan timing',
      // Hinglish
      'anomaly scan kab',
      'scan kab hona',
    ],
    answer: LocalizedText(
      en: "Your anomaly scan (the '20-week scan') is usually done between 18 and 21 weeks. It's a detailed ~30-minute ultrasound that checks your baby's growth and looks closely at the brain, heart, spine, face, kidneys and other organs, plus the placenta. It's offered to everyone, and it's your choice.",
      hi: "आपका anomaly scan (जिसे '20-week scan' कहते हैं) आम तौर पर 18 से 21 हफ़्ते के बीच होता है। यह एक विस्तृत ~30 मिनट का अल्ट्रासाउंड है जो शिशु की बढ़त देखता है और दिमाग़, दिल, रीढ़, चेहरा, kidney और दूसरे अंगों के साथ placenta को ग़ौर से जाँचता है। यह सबको दिया जाता है, और यह आपकी मर्ज़ी है।",
    ),
    meaning: LocalizedText(
      en: "You're around week 20 - right in the window for this scan. It's one of the most detailed, reassuring looks at how your baby is developing.",
      hi: "आप लगभग हफ़्ता 20 पर हैं — बिलकुल इस स्कैन के दायरे में। यह शिशु का विकास देखने के सबसे विस्तृत और भरोसा देने वाले तरीक़ों में से एक है।",
    ),
    actions: [
      LocalizedText(
          en: "If you haven't booked it, contact your hospital/clinic to schedule it for 18–21 weeks.",
          hi: "अगर अभी तक बुक नहीं किया, तो अपने अस्पताल/क्लिनिक से 18–21 हफ़्ते के लिए समय ले लीजिए।"),
      LocalizedText(
          en: "Ask your clinic if they want you to drink water beforehand.",
          hi: "क्लिनिक से पूछ लीजिए कि स्कैन से पहले पानी पीना है या नहीं।"),
      LocalizedText(
          en: "Jot down any questions for the sonographer.",
          hi: "Sonographer के लिए अपने सवाल लिख लीजिए।"),
      LocalizedText(
          en: "Add the appointment to your ParentVeda Calendar.",
          hi: "अपॉइंटमेंट को अपने ParentVeda कैलेंडर में जोड़ लीजिए।"),
    ],
    pvContent: [
      LocalizedText(
          en: 'Week 20 Journey - baby development',
          hi: 'हफ़्ता 20 सफ़र — शिशु का विकास'),
      LocalizedText(
          en: "'Your scans' in the weekly flow",
          hi: "साप्ताहिक फ़्लो में 'आपके स्कैन'"),
      LocalizedText(
          en: 'Calendar - log your appointment',
          hi: 'कैलेंडर — अपना अपॉइंटमेंट दर्ज कीजिए'),
    ],
    community: LocalizedText(
      en: 'Mothers often ask what the anomaly scan checks - most call it the most reassuring scan of pregnancy.',
      hi: 'माँएँ अक्सर पूछती हैं कि anomaly scan क्या जाँचता है — ज़्यादातर इसे गर्भावस्था का सबसे भरोसा देने वाला स्कैन कहती हैं।',
    ),
    products: [],
    services: [
      LocalizedText(
          en: 'Scan centre / Sonography', hi: 'स्कैन सेंटर / Sonography'),
      LocalizedText(
          en: 'Your gynaecologist / obstetrician',
          hi: 'आपकी gynaecologist / obstetrician'),
    ],
  ),
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'labour_signs',
    question: LocalizedText(
        en: 'What are the signs that labour is starting?',
        hi: 'प्रसव शुरू होने के संकेत क्या हैं?'),
    keywords: [
      'labour signs',
      'signs of labour',
      'labor',
      'contractions starting',
      'am i in labour',
      'when to go to hospital',
      // Hinglish
      'labour shuru',
      'labour ke signs',
      'labour kab',
      'delivery ke signs',
    ],
    answer: LocalizedText(
      en: "Common early signs of labour: a 'show' (a pinkish, jelly-like plug of mucus), contractions that get longer, stronger and closer together, backache or a heavy period-like ache, and your waters breaking (a trickle or a gush). Practice 'Braxton Hicks' tightenings are usually painless, irregular and don't build up.",
      hi: "प्रसव के आम शुरुआती संकेत: एक 'show' (गुलाबी, जेली जैसा mucus plug), संकुचन जो लंबे, तेज़ और पास-पास होते जाते हैं, कमर दर्द या भारी पीरियड जैसा दर्द, और पानी का टूटना (धीरे या एकदम)। अभ्यास वाले 'Braxton Hicks' कसाव आम तौर पर दर्द-रहित, अनियमित होते हैं और बढ़ते नहीं।",
    ),
    meaning: LocalizedText(
      en: "Near the end of pregnancy your body is preparing. Real labour contractions become regular and intensify, while practice ones fade. Before 37 weeks, these signs should be checked, as it could be early labour.",
      hi: "गर्भावस्था के अंत के पास आपका शरीर तैयारी कर रहा होता है। असली प्रसव के संकुचन नियमित और तेज़ होते जाते हैं, जबकि अभ्यास वाले हल्के पड़ जाते हैं। 37 हफ़्ते से पहले ये संकेत जाँचवाने चाहिए, क्योंकि यह जल्दी शुरू हुआ प्रसव हो सकता है।",
    ),
    actions: [
      LocalizedText(
          en: 'Time your contractions (our Contraction Timer tool helps).',
          hi: 'अपने संकुचन का समय देखिए (हमारा संकुचन टाइमर मदद करता है)।'),
      LocalizedText(
          en: 'Most are advised to head to hospital when contractions are regular - about every 5 minutes, each lasting ~60 seconds.',
          hi: 'ज़्यादातर को सलाह दी जाती है कि जब संकुचन नियमित हो जाएँ — लगभग हर 5 मिनट में, हर एक ~60 सेकंड का — तब अस्पताल जाएँ।'),
      LocalizedText(
          en: 'Call your midwife / maternity unit straight away if your waters break, you see bleeding, movements reduce, or it\'s before 37 weeks.',
          hi: 'अगर पानी टूट जाए, ब्लीडिंग दिखे, हलचल कम हो जाए, या 37 हफ़्ते से पहले हो — तो तुरंत अपनी midwife / मैटरनिटी यूनिट को कॉल कीजिए।'),
      LocalizedText(
          en: 'Keep your hospital bag ready.',
          hi: 'अपना अस्पताल बैग तैयार रखिए।'),
    ],
    pvContent: [
      LocalizedText(
          en: 'Contraction Timer tool', hi: 'संकुचन टाइमर'),
      LocalizedText(en: 'Hospital Bag checklist', hi: 'अस्पताल बैग चेकलिस्ट'),
      LocalizedText(
          en: 'Week-by-week labour prep', hi: 'हफ़्ते-दर-हफ़्ते प्रसव की तैयारी'),
    ],
    community: LocalizedText(
      en: 'A top question is telling real labour from Braxton Hicks - timing the contractions is the clearest way.',
      hi: 'एक बड़ा सवाल है असली प्रसव को Braxton Hicks से पहचानना — संकुचन का समय देखना सबसे साफ़ तरीक़ा है।',
    ),
    products: [
      LocalizedText(en: 'Hospital bag essentials', hi: 'अस्पताल बैग की ज़रूरी चीज़ें'),
    ],
    services: [
      LocalizedText(
          en: 'Maternity unit / Labour ward',
          hi: 'मैटरनिटी यूनिट / Labour ward'),
      LocalizedText(
          en: 'Your obstetrician / midwife',
          hi: 'आपकी obstetrician / midwife'),
    ],
  ),
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'iron_foods',
    question: LocalizedText(
        en: 'What foods help boost my iron in pregnancy?',
        hi: 'गर्भावस्था में Iron बढ़ाने के लिए कौन से खाने मदद करते हैं?'),
    keywords: [
      'iron',
      'iron rich foods',
      'hemoglobin',
      'haemoglobin',
      'anaemia',
      'anemia',
      'iron deficiency',
      'boost iron',
      // Hinglish
      'iron badhane',
      'iron wale food',
      'khoon ki kami',
    ],
    answer: LocalizedText(
      en: "In pregnancy you need about 27 mg of iron a day. Iron-rich foods include lean red meat, chicken, fish, eggs, lentils, beans, chickpeas, tofu, dark leafy greens like spinach, and iron-fortified cereals. Pair them with vitamin C (orange, lemon, tomato, bell pepper, amla) to absorb more iron - and keep tea/coffee away from mealtimes, as they reduce absorption.",
      hi: "गर्भावस्था में आपको रोज़ लगभग 27 mg Iron चाहिए। Iron से भरपूर खानों में हैं: lean red meat, चिकन, मछली, अंडे, दाल, बीन्स, छोले, tofu, गहरी हरी सब्ज़ियाँ जैसे पालक, और Iron-fortified cereals। इन्हें Vitamin C (संतरा, नींबू, टमाटर, शिमला मिर्च, आँवला) के साथ खाइए ताकि Iron ज़्यादा सोखा जाए — और चाय/कॉफ़ी को खाने के समय से दूर रखिए, क्योंकि वे सोखना कम करते हैं।",
    ),
    meaning: LocalizedText(
      en: "Your blood volume rises about 50% in pregnancy, so your iron needs jump. Enough iron helps prevent anaemia, which can leave you very tired, dizzy or breathless.",
      hi: "गर्भावस्था में आपका blood volume लगभग 50% बढ़ जाता है, इसलिए Iron की ज़रूरत भी बढ़ जाती है। पर्याप्त Iron anaemia से बचाता है, जिससे बहुत थकान, चक्कर या साँस फूलना हो सकता है।",
    ),
    actions: [
      LocalizedText(
          en: 'Include an iron-rich food at each main meal, with a vitamin-C food alongside.',
          hi: 'हर मुख्य भोजन में एक Iron से भरपूर चीज़ रखिए, साथ में एक Vitamin C वाली चीज़।'),
      LocalizedText(
          en: 'Keep tea and coffee between meals, not with them.',
          hi: 'चाय और कॉफ़ी खाने के बीच में लीजिए, खाने के साथ नहीं।'),
      LocalizedText(
          en: 'Take your prescribed prenatal / iron supplement as advised.',
          hi: 'अपना prescribed prenatal / Iron सप्लीमेंट सलाह के मुताबिक़ लीजिए।'),
      LocalizedText(
          en: 'If you feel very tired, dizzy or breathless, ask your doctor about a haemoglobin (Hb) test.',
          hi: 'अगर बहुत थकान, चक्कर या साँस फूलने लगे, तो डॉक्टर से haemoglobin (Hb) टेस्ट के बारे में पूछिए।'),
    ],
    pvContent: [
      LocalizedText(
          en: 'Pregnancy nutrition reads', hi: 'गर्भावस्था पोषण के पाठ'),
      LocalizedText(
          en: "'Can I eat…' food library", hi: "'क्या मैं खा सकती हूँ…' खाद्य संग्रह"),
      LocalizedText(en: 'Daily Learn - nutrition', hi: 'रोज़ाना सीखें — पोषण'),
    ],
    community: LocalizedText(
      en: 'Iron and energy are among the most-asked nutrition topics - small daily swaps add up.',
      hi: 'Iron और ऊर्जा सबसे ज़्यादा पूछे जाने वाले पोषण विषयों में से हैं — छोटे रोज़ के बदलाव काम आते हैं।',
    ),
    products: [],
    services: [
      LocalizedText(
          en: 'Dietitian / nutritionist', hi: 'Dietitian / nutritionist'),
      LocalizedText(
          en: 'Your gynaecologist (for Hb testing)',
          hi: 'आपकी gynaecologist (Hb जाँच के लिए)'),
    ],
  ),
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'sleep_back',
    question: LocalizedText(
        en: 'Is it safe to sleep on my back during pregnancy?',
        hi: 'क्या गर्भावस्था में पीठ के बल सोना सुरक्षित है?'),
    keywords: [
      'sleep on back',
      'sleeping position',
      'sleep position',
      'back sleeping',
      'which side to sleep',
      'sleep on side',
      // Hinglish
      'peeth ke bal',
      'peeth ke bal sona',
      'kis karwat sona',
      'kis taraf sona',
    ],
    answer: LocalizedText(
      en: "Up to about 28 weeks, back-sleeping is generally fine. From 28 weeks (third trimester), the advice is to GO TO SLEEP ON YOUR SIDE - research links going to sleep on your back in the third trimester with a higher stillbirth risk, because the womb can press on a major blood vessel and reduce blood flow to your baby. Either side is fine. If you wake up on your back, don't panic - just roll onto your side.",
      hi: "लगभग 28 हफ़्ते तक, पीठ के बल सोना आम तौर पर ठीक है। 28 हफ़्ते से (तीसरी तिमाही), सलाह है कि करवट लेकर सोइए — शोध तीसरी तिमाही में पीठ के बल सोने को ज़्यादा stillbirth ख़तरे से जोड़ता है, क्योंकि गर्भ एक बड़ी blood vessel पर दबाव डाल सकता है और शिशु तक ख़ून का बहाव कम कर सकता है। कोई भी करवट ठीक है। अगर आप पीठ के बल जाग जाएँ, तो घबराइए मत — बस करवट ले लीजिए।",
    ),
    meaning: LocalizedText(
      en: "You're around week 20, so it isn't a worry yet - but it's a good habit to start settling on your side now, so it feels natural by the third trimester.",
      hi: "आप लगभग हफ़्ता 20 पर हैं, तो अभी यह चिंता की बात नहीं — लेकिन अभी से करवट लेकर सोने की आदत डालना अच्छा है, ताकि तीसरी तिमाही तक यह स्वाभाविक लगे।",
    ),
    actions: [
      LocalizedText(
          en: 'From the third trimester, start going to sleep on your side (left or right).',
          hi: 'तीसरी तिमाही से, करवट (बाईं या दाईं) लेकर सोना शुरू कीजिए।'),
      LocalizedText(
          en: 'Use a pillow between your knees or a pregnancy pillow to stay comfy on your side.',
          hi: 'घुटनों के बीच तकिया या pregnancy pillow इस्तेमाल कीजिए ताकि करवट पर आराम रहे।'),
      LocalizedText(
          en: 'If you wake on your back, simply turn onto your side - no need to worry.',
          hi: 'अगर पीठ के बल जागें, तो बस करवट ले लीजिए — चिंता की कोई बात नहीं।'),
    ],
    pvContent: [
      LocalizedText(en: 'Sleep & comfort reads', hi: 'नींद और आराम के पाठ'),
      LocalizedText(
          en: "Weekly 'for you, mum' tips", hi: "साप्ताहिक 'आपके लिए, माँ' सुझाव"),
    ],
    community: LocalizedText(
      en: 'Side-sleeping and pillows are a top comfort topic in the third trimester.',
      hi: 'करवट लेकर सोना और तकिए तीसरी तिमाही का बड़ा आराम-विषय हैं।',
    ),
    products: [
      LocalizedText(en: 'Pregnancy pillow', hi: 'Pregnancy pillow'),
    ],
    services: [
      LocalizedText(
          en: 'Your midwife (if sleep worries persist)',
          hi: 'आपकी midwife (अगर नींद की चिंता बनी रहे)'),
    ],
  ),
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'reduced_movements',
    urgent: true,
    question: LocalizedText(
        en: 'My baby is moving less today - what should I do?',
        hi: 'मेरा शिशु आज कम हिल रहा है — मैं क्या करूँ?'),
    keywords: [
      'baby moving less',
      'reduced movements',
      'less movement',
      'baby not moving',
      'fewer kicks',
      'reduced fetal movement',
      // Hinglish
      'kam move',
      'baby kam move',
      'kam hil',
      'movement kam',
    ],
    answer: LocalizedText(
      en: "If your baby is moving less than usual, contact your maternity unit straight away - do not wait, even in the middle of the night. Reduced movements can be an important sign that needs checking. Do NOT rely on cold drinks, sugar or home tricks to make baby move - get checked.",
      hi: "अगर आपका शिशु आम से कम हिल रहा है, तो तुरंत अपनी मैटरनिटी यूनिट से संपर्क कीजिए — रुकिए मत, चाहे आधी रात हो। कम हलचल एक ज़रूरी संकेत हो सकता है जिसे जाँचना ज़रूरी है। शिशु को हिलाने के लिए ठंडे पेय, चीनी या घरेलू नुस्ख़ों पर भरोसा मत कीजिए — जाकर जाँच करवाइए।",
    ),
    meaning: LocalizedText(
      en: "There's no set 'normal number' of movements - what matters is YOUR baby's usual pattern. Movements increase up to about 32 weeks and then stay roughly steady; they should not fade near the end. A drop from what's normal for your baby should always be checked.",
      hi: "हलचल की कोई तय 'सामान्य संख्या' नहीं होती — जो मायने रखता है वह है आपके शिशु का अपना पैटर्न। हलचल लगभग 32 हफ़्ते तक बढ़ती है फिर लगभग स्थिर रहती है; अंत के पास इन्हें कम नहीं होना चाहिए। आपके शिशु के सामान्य से कमी हमेशा जाँचवानी चाहिए।",
    ),
    actions: [
      LocalizedText(
          en: 'Call your maternity unit / labour ward now and tell them movements are reduced.',
          hi: 'अभी अपनी मैटरनिटी यूनिट / labour ward को कॉल कीजिए और बताइए कि हलचल कम है।'),
      LocalizedText(
          en: 'Lie on your left side and focus on movements while you arrange to be seen.',
          hi: 'बाईं करवट लेटिए और हलचल पर ध्यान दीजिए जब तक आप जाँच का इंतज़ाम करती हैं।'),
      LocalizedText(
          en: "Go in to be checked - they'll listen to baby's heartbeat and may monitor.",
          hi: 'जाकर जाँच करवाइए — वे शिशु की धड़कन सुनेंगे और निगरानी कर सकते हैं।'),
      LocalizedText(
          en: 'Never wait until tomorrow.', hi: 'कभी कल तक इंतज़ार मत कीजिए।'),
    ],
    pvContent: [
      LocalizedText(
          en: 'Baby Movements / Kick Counter tool',
          hi: 'शिशु की हलचल / Kick Counter टूल'),
      LocalizedText(
          en: "'Your baby's movements' read",
          hi: "'आपके शिशु की हलचल' पाठ"),
    ],
    community: LocalizedText(
      en: 'This is one of the most important things to act on fast - mothers are always encouraged to get checked, never to wait.',
      hi: 'यह उन सबसे ज़रूरी चीज़ों में से है जिन पर जल्दी क़दम उठाना चाहिए — माँओं को हमेशा जाँच करवाने की सलाह दी जाती है, कभी इंतज़ार करने की नहीं।',
    ),
    products: [],
    services: [
      LocalizedText(
          en: 'Maternity unit / Labour ward (now)',
          hi: 'मैटरनिटी यूनिट / Labour ward (अभी)'),
      LocalizedText(
          en: 'Your obstetrician / midwife',
          hi: 'आपकी obstetrician / midwife'),
    ],
  ),
];
