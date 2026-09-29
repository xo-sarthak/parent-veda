// =============================================================================
//  Journey milestone content (bilingual)
// -----------------------------------------------------------------------------
//  Authored in Dart (type-safe LocalizedText) rather than JSON: this is small,
//  structured, config-like content - unlike the bulk week/daily JSON sets.
//  Educational only; never diagnosis or medical advice.
// =============================================================================

import '../localization/app_language.dart';
import '../models/journey_node.dart';

/// Every milestone node on the Pregnancy Journey trail.
const List<JourneyMilestone> kJourneyMilestones = [
  // ===========================================================================
  //  TYPE 2 · ACHIEVEMENTS (gold) - celebrate progress
  // ===========================================================================
  JourneyMilestone(
    id: 'a_w5',
    type: JourneyNodeType.achievement,
    anchorWeek: 5,
    emoji: '🌟',
    title: LocalizedText(en: 'Pregnancy confirmed', hi: 'गर्भावस्था की पुष्टि'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: "It's really happening. A tiny life has started growing with "
              "you.",
          hi: 'यह सच में हो रहा है। एक नन्ही सी जान ने आपके साथ अपना सफ़र शुरू कर दिया है। 🌟',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w6',
    type: JourneyNodeType.achievement,
    anchorWeek: 6,
    emoji: '❤️',
    title: LocalizedText(en: 'First heartbeat', hi: 'पहली धड़कन'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: "Your baby's heart has started to beat, a small, steady rhythm.",
          hi: 'आपके शिशु का दिल धड़कने लगा है — एक शांत, स्थिर धड़कन सिर्फ़ आपके लिए। ❤️',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w12',
    type: JourneyNodeType.achievement,
    anchorWeek: 12,
    emoji: '🌿',
    title: LocalizedText(en: 'First trimester done', hi: 'पहली तिमाही पूरी'),
    ctaWeek: 12,
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: "You've finished the first third of your pregnancy. Many women "
              "find the next weeks a little easier.",
          hi: 'आपने अपने सफ़र का एक-तिहाई हिस्सा पूरा कर लिया। सबसे नाज़ुक हफ़्ते अब पीछे हैं। 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w18',
    type: JourneyNodeType.achievement,
    anchorWeek: 19,
    emoji: '🦋',
    rangeLabel: LocalizedText(en: 'Week 18–20', hi: 'हफ़्ता 18–20'),
    title: LocalizedText(en: 'First movements', hi: 'पहली हलचल महसूस'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Those first flutters, like tiny bubbles, are your baby moving.',
          hi: 'वे पहली हल्की हलचलें — जैसे नन्ही तितलियाँ — आपका शिशु नमस्ते कह रहा है। 🦋',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w20',
    type: JourneyNodeType.achievement,
    anchorWeek: 20,
    emoji: '🌗',
    title: LocalizedText(en: 'Halfway', hi: 'आधा सफ़र'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Halfway there. Look how far you and your baby have come '
              'together.',
          hi: 'आधा सफ़र पूरा। देखिए आप और आपका शिशु साथ में कितनी दूर आ चुके हैं। 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w24',
    type: JourneyNodeType.achievement,
    anchorWeek: 24,
    emoji: '💪',
    title: LocalizedText(en: 'A big milestone at 24 weeks', hi: 'Viability का पड़ाव'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Your baby is growing stronger every day, and your care team '
              'is watching over you both.',
          hi: 'एक ज़रूरी पड़ाव — आपका शिशु हर दिन और मज़बूत हो रहा है। 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w28',
    type: JourneyNodeType.achievement,
    anchorWeek: 28,
    emoji: '🌅',
    title: LocalizedText(en: 'Third trimester begins', hi: 'तीसरी तिमाही शुरू'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: "The last stretch begins. Soon you'll be holding your baby.",
          hi: 'आख़िरी अध्याय शुरू। जल्द ही आप अपने नन्हे को गोद में लेंगी। 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w37',
    type: JourneyNodeType.achievement,
    anchorWeek: 37,
    emoji: '✅',
    title: LocalizedText(en: 'Full term', hi: 'पूरा समय'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Your baby is now full term, and ready to arrive whenever the '
              'time is right.',
          hi: 'आपका शिशु अब पूरे समय का है — सही वक़्त आने पर दुनिया से मिलने के लिए तैयार। 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w40',
    type: JourneyNodeType.achievement,
    anchorWeek: 40,
    emoji: '🍼',
    title: LocalizedText(en: 'Due date', hi: 'डिलीवरी की तारीख़'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Forty weeks of care and strength. Your baby is almost here.',
          hi: 'चालीस हफ़्तों का प्यार, ताक़त और जादू। आपका नन्हा बस आने ही वाला है। 🎉',
        ),
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 3 · MEDICAL (purple) - preparation & education (no diagnosis)
  // ===========================================================================
  JourneyMilestone(
    id: 'm_ultrasound',
    type: JourneyNodeType.medical,
    anchorWeek: 7,
    emoji: '🩺',
    rangeLabel: LocalizedText(en: 'Week 6–8', hi: 'हफ़्ता 6–8'),
    title: LocalizedText(en: 'First ultrasound', hi: 'पहला अल्ट्रासाउंड'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'यह क्यों ज़रूरी है'),
        LocalizedText(
          en: "The first scan confirms the pregnancy and usually shows your "
              "baby's heartbeat and how many weeks you are.",
          hi: 'पहला स्कैन गर्भावस्था की पुष्टि करता है और अक्सर शिशु की धड़कन और आप कितने हफ़्तों की हैं यह दिखाता है।',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'आम तौर पर कब'),
        LocalizedText(en: 'Usually between weeks 6 and 8.', hi: 'आम तौर पर हफ़्ता 6 से 8 के बीच।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Preparation tips', hi: 'तैयारी के सुझाव'),
        [
          LocalizedText(en: 'A full bladder can help an early scan. Ask your '
                            'clinic.', hi: 'जल्दी वाले स्कैन में भरा bladder मदद करता है — अपने क्लिनिक से पूछिए।'),
          LocalizedText(en: 'Wear comfortable, loose clothes.', hi: 'आरामदायक, ढीले कपड़े पहनिए।'),
        ],
      ),
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'क्या पूछें'),
        [
          LocalizedText(en: "How many weeks am I, and what's my due date?", hi: 'मैं कितने हफ़्तों की हूँ, और मेरी डिलीवरी की तारीख़ क्या है?'),
          LocalizedText(en: 'Is everything developing as expected?', hi: 'क्या सब कुछ ठीक से विकसित हो रहा है?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_nt',
    type: JourneyNodeType.medical,
    anchorWeek: 12,
    emoji: '🩺',
    rangeLabel: LocalizedText(en: 'Week 11–13', hi: 'हफ़्ता 11–13'),
    title: LocalizedText(en: 'NT Scan', hi: 'NT Scan'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'यह क्यों ज़रूरी है'),
        LocalizedText(
          en: "A routine screening scan that checks early growth. It's often "
              "combined with a blood test.",
          hi: 'एक routine screening scan जो शुरुआती बढ़त जाँचता है। अक्सर blood test के साथ होता है।',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'आम तौर पर कब'),
        LocalizedText(en: 'Usually between weeks 11 and 13.', hi: 'आम तौर पर हफ़्ता 11 से 13 के बीच।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Preparation tips', hi: 'तैयारी के सुझाव'),
        [
          LocalizedText(en: 'Carry any previous reports with you.', hi: 'अपनी पुरानी रिपोर्ट साथ ले जाइए।'),
          LocalizedText(en: "It's a gentle, routine check, so try to stay "
                            "relaxed.", hi: 'शांत रहिए — यह आराम से होने वाला routine check है।'),
        ],
      ),
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'क्या पूछें'),
        [
          LocalizedText(en: 'Do you recommend any additional screening?', hi: 'क्या आप कोई और screening सुझाते हैं?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_anomaly',
    type: JourneyNodeType.medical,
    anchorWeek: 20,
    emoji: '🩺',
    rangeLabel: LocalizedText(en: 'Week 18–22', hi: 'हफ़्ता 18–22'),
    title: LocalizedText(en: 'Anomaly scan', hi: 'Anomaly scan'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'यह क्यों ज़रूरी है'),
        LocalizedText(
          en: "A detailed scan that looks at how your baby's organs and body "
              "are forming.",
          hi: 'एक विस्तृत स्कैन जो देखता है कि आपके शिशु के अंग और शरीर कैसे विकसित हो रहे हैं।',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'आम तौर पर कब'),
        LocalizedText(en: 'Usually between weeks 18 and 22.', hi: 'आम तौर पर हफ़्ता 18 से 22 के बीच।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Preparation tips', hi: 'तैयारी के सुझाव'),
        [
          LocalizedText(en: 'It can take longer than other scans, so allow '
                            'some time.', hi: 'यह दूसरे स्कैन से ज़्यादा वक़्त ले सकता है — थोड़ा समय रखिए।'),
          LocalizedText(en: 'They may be able to tell you which way your '
                            'baby is lying.', hi: 'आपको शिशु की मुद्रा पता चल सकती है।'),
        ],
      ),
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'क्या पूछें'),
        [
          LocalizedText(en: 'Is my baby growing well for this stage?', hi: 'क्या शिशु इस चरण के हिसाब से ठीक बढ़ रहा है?'),
          LocalizedText(en: 'Where is the placenta?', hi: 'Placenta की स्थिति कहाँ है?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_glucose',
    type: JourneyNodeType.medical,
    anchorWeek: 26,
    emoji: '🩺',
    rangeLabel: LocalizedText(en: 'Week 24–28', hi: 'हफ़्ता 24–28'),
    title: LocalizedText(en: 'Sugar test', hi: 'Sugar test'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'यह क्यों ज़रूरी है'),
        LocalizedText(
          en: 'A simple test that checks how your body handles sugar during '
              'pregnancy.',
          hi: 'एक आसान टेस्ट जो देखता है कि गर्भावस्था में आपका शरीर sugar को कैसे सँभाल रहा है।',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'आम तौर पर कब'),
        LocalizedText(en: 'Usually between weeks 24 and 28.', hi: 'आम तौर पर हफ़्ता 24 से 28 के बीच।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Preparation tips', hi: 'तैयारी के सुझाव'),
        [
          LocalizedText(en: 'Your clinic may ask you to fast, so check '
                            'beforehand.', hi: 'क्लिनिक आपसे ख़ाली पेट आने को कह सकती है — पहले पुष्टि कर लीजिए।'),
          LocalizedText(en: 'Carry a snack for after the test.', hi: 'टेस्ट के बाद के लिए एक स्नैक साथ रखिए।'),
        ],
      ),
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'क्या पूछें'),
        [
          LocalizedText(en: 'Do I need to do anything to get ready for the '
                            'test?', hi: 'टेस्ट से पहले मुझे कुछ तैयारी करनी है?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_growth',
    type: JourneyNodeType.medical,
    anchorWeek: 32,
    emoji: '🩺',
    title: LocalizedText(en: 'Growth scan (if advised)', hi: 'Growth Scan (अगर सलाह हो)'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'यह क्यों ज़रूरी है'),
        LocalizedText(
          en: "If your doctor advises it, this scan checks your baby's size, "
              "position and growth as your due date gets closer.",
          hi: 'अगर सलाह हो, यह स्कैन डिलीवरी की तारीख़ पास आने पर शिशु का आकार, मुद्रा और बढ़त जाँचता है।',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'आम तौर पर कब'),
        LocalizedText(en: 'Around week 32, only if your doctor recommends it.', hi: 'लगभग हफ़्ता 32, सिर्फ़ जब डॉक्टर सलाह दें।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'क्या पूछें'),
        [
          LocalizedText(en: 'Which way is my baby lying?', hi: 'क्या शिशु अच्छी मुद्रा में है?'),
          LocalizedText(en: 'Is growth on track?', hi: 'क्या बढ़त ठीक चल रही है?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_birthplan',
    type: JourneyNodeType.medical,
    anchorWeek: 36,
    emoji: '🩺',
    title: LocalizedText(en: 'Birth planning visit', hi: 'जन्म की योजना वाली मुलाक़ात'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'यह क्यों ज़रूरी है'),
        LocalizedText(
          en: "A chance to talk through what you'd like for the birth and "
              "what to expect in the last weeks.",
          hi: 'अपनी जन्म से जुड़ी पसंद और आख़िरी हफ़्तों में क्या उम्मीद करें, इस पर बात करने का मौक़ा।',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'आम तौर पर कब'),
        LocalizedText(en: 'Around week 36.', hi: 'लगभग हफ़्ता 36।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'क्या पूछें'),
        [
          LocalizedText(en: 'When should I go to the hospital?', hi: 'मुझे अस्पताल कब जाना चाहिए?'),
          LocalizedText(en: 'What are my pain relief options?', hi: 'दर्द कम करने के क्या विकल्प हैं?'),
          LocalizedText(en: 'Who can I call at any time of day?', hi: 'मैं किसी भी वक़्त किसे कॉल कर सकती हूँ?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_gbs',
    type: JourneyNodeType.medical,
    anchorWeek: 36,
    emoji: '🧫',
    rangeLabel: LocalizedText(en: 'Week 36–37', hi: 'हफ़्ता 36–37'),
    title: LocalizedText(en: 'Group B Strep test', hi: 'Group B Strep test'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'यह क्यों ज़रूरी है'),
        LocalizedText(
          en: 'A simple swab near your due date checks whether you carry '
              'Group B Strep, so your team can protect your baby during '
              'birth if needed. Carrying it is common and harmless to you.',
          hi: 'पूरे समय के पास एक आसान swab देखता है कि आप Group B Strep साथ रखती हैं या नहीं, ताकि ज़रूरत पर टीम जन्म के समय शिशु को सुरक्षित रख सके। इसे साथ रखना आम है और आपके लिए हानिरहित है।',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'आम तौर पर कब'),
        LocalizedText(
            en: 'Usually around weeks 36 to 37.',
            hi: 'आम तौर पर हफ़्ता 36 से 37 के बीच।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'क्या पूछें'),
        [
          LocalizedText(
              en: 'If I carry GBS, what happens during labour?',
              hi: 'अगर मैं GBS साथ रखती हूँ, तो प्रसव में क्या होगा?'),
          LocalizedText(
              en: 'Do you offer this test routinely here?',
              hi: 'क्या यहाँ यह टेस्ट रूटीन में होता है?'),
        ],
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 4 · BABY DEVELOPMENT (blue) - wonder & education
  // ===========================================================================
  JourneyMilestone(
    id: 'b_w8',
    type: JourneyNodeType.babyDev,
    anchorWeek: 8,
    emoji: '👶',
    title: LocalizedText(en: 'Embryo becomes fetus', hi: 'Embryo से Fetus'),
    ctaWeek: 8,
    sections: [
      CardSection(
        LocalizedText(en: "What's happening", hi: 'क्या हो रहा है'),
        LocalizedText(en: 'Your baby is now called a fetus instead of an '
                          'embryo. Tiny limbs and features are forming.', hi: 'आपका शिशु embryo से fetus बन गया है — नन्हे हाथ-पैर और नक़्श बन रहे हैं।'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'इसका मतलब'),
        LocalizedText(en: "The basic parts are in place. From now on it's "
                          "mostly about growing.", hi: 'बुनियादी चीज़ें बन चुकी हैं; अब सिर्फ़ बढ़ना बाक़ी है।'),
      ),
      CardSection(
        LocalizedText(en: 'Did you know?', hi: 'मज़ेदार बात'),
        LocalizedText(en: 'Your baby is about the size of a raspberry right '
                          'now.', hi: 'आपका शिशु अभी लगभग एक रसभरी जितना बड़ा है।'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w16',
    type: JourneyNodeType.babyDev,
    anchorWeek: 16,
    emoji: '👶',
    title: LocalizedText(en: 'Your baby can hear sounds', hi: 'शिशु आवाज़ सुनता है'),
    ctaWeek: 16,
    sections: [
      CardSection(
        LocalizedText(en: "What's happening", hi: 'क्या हो रहा है'),
        LocalizedText(en: 'Tiny ears are forming, and your baby is starting '
                          'to pick up sounds.', hi: 'नन्हे कान बन रहे हैं और आपका शिशु आवाज़ें सुनने लगता है।'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'इसका मतलब'),
        LocalizedText(en: "It's a lovely time to talk, sing and play gentle "
                          "music.", hi: 'यह बात करने, गाने और हल्का संगीत सुनाने का प्यारा समय है।'),
      ),
      CardSection(
        LocalizedText(en: 'Did you know?', hi: 'मज़ेदार बात'),
        LocalizedText(en: 'Your voice is one of the first sounds your baby '
                          'learns.', hi: 'आपकी आवाज़ उन पहली आवाज़ों में है जो आपका शिशु पहचानना सीखता है।'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w24',
    type: JourneyNodeType.babyDev,
    anchorWeek: 24,
    emoji: '👶',
    title: LocalizedText(en: 'Responds to sound', hi: 'आवाज़ पर हलचल करता है'),
    ctaWeek: 24,
    sections: [
      CardSection(
        LocalizedText(en: "What's happening", hi: 'क्या हो रहा है'),
        LocalizedText(en: 'Your baby may now move or kick when they hear '
                          'sounds and your voice.', hi: 'आपका शिशु अब आवाज़ों और आपकी आवाज़ पर हिल सकता है।'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'इसका मतलब'),
        LocalizedText(en: 'A two-way bond is forming between you and your '
                          'baby.', hi: 'आपके और आपके नन्हे के बीच एक सच्चा दो-तरफ़ा रिश्ता बन रहा है।'),
      ),
      CardSection(
        LocalizedText(en: 'Did you know?', hi: 'मज़ेदार बात'),
        LocalizedText(en: 'Babies often settle to music they heard a lot in '
                          'the womb.', hi: 'बच्चे अक्सर उस संगीत से शांत हो जाते हैं जो उन्होंने गर्भ में बार-बार सुना हो।'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w28',
    type: JourneyNodeType.babyDev,
    anchorWeek: 28,
    emoji: '👶',
    title: LocalizedText(en: 'Eyes open', hi: 'आँखें खुलती हैं'),
    ctaWeek: 28,
    sections: [
      CardSection(
        LocalizedText(en: "What's happening", hi: 'क्या हो रहा है'),
        LocalizedText(en: "Your baby's eyes can now open and close, and "
                          "sense light.", hi: 'आपके शिशु की आँखें अब खुल-बंद हो सकती हैं और रोशनी महसूस कर सकती हैं।'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'इसका मतलब'),
        LocalizedText(en: 'Their senses are maturing, getting ready for the '
                          'world outside.', hi: 'इंद्रियाँ परिपक्व हो रही हैं, बाहर की दुनिया के लिए तैयार।'),
      ),
      CardSection(
        LocalizedText(en: 'Did you know?', hi: 'मज़ेदार बात'),
        LocalizedText(en: 'Your baby may turn towards a soft light shone on '
                          'your bump.', hi: 'आपके पेट पर पड़ी हल्की रोशनी की तरफ़ शिशु मुड़ सकता है।'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w32',
    type: JourneyNodeType.babyDev,
    anchorWeek: 32,
    emoji: '👶',
    title: LocalizedText(en: 'Practises breathing', hi: 'साँस लेने का अभ्यास'),
    ctaWeek: 32,
    sections: [
      CardSection(
        LocalizedText(en: "What's happening", hi: 'क्या हो रहा है'),
        LocalizedText(en: 'Your baby practises breathing movements, getting '
                          'their lungs ready.', hi: 'आपका शिशु साँस लेने की हरकतें अभ्यास करता है, फेफड़ों को तैयार करता है।'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'इसका मतलब'),
        LocalizedText(en: 'It gets them ready for that very first breath '
                          'after birth.', hi: 'जन्म के बाद पहली साँस के लिए ज़रूरी तैयारी।'),
      ),
      CardSection(
        LocalizedText(en: 'Did you know?', hi: 'मज़ेदार बात'),
        LocalizedText(en: 'Your baby "breathes" amniotic fluid in and out to '
                          'practise.', hi: 'अभ्यास के लिए शिशु amniotic fluid को अंदर-बाहर "साँस" लेता है।'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w36',
    type: JourneyNodeType.babyDev,
    anchorWeek: 36,
    emoji: '👶',
    title: LocalizedText(en: 'Head may move down', hi: 'सिर नीचे आ सकता है'),
    ctaWeek: 36,
    sections: [
      CardSection(
        LocalizedText(en: "What's happening", hi: 'क्या हो रहा है'),
        LocalizedText(en: 'Many babies start to settle head down, getting '
                          'into position for birth.', hi: 'कई शिशु सिर-नीचे बैठने लगते हैं, जन्म के लिए मुद्रा में आते हैं।'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'इसका मतलब'),
        LocalizedText(en: 'Your baby is getting ready to be born. Not every '
                          'baby does this at the same time.', hi: 'आपका शिशु बाहर के सफ़र की तैयारी कर रहा है। हर शिशु यह एक ही समय पर नहीं करता।'),
      ),
      CardSection(
        LocalizedText(en: 'Did you know?', hi: 'मज़ेदार बात'),
        LocalizedText(en: 'This settling is sometimes called "lightening".', hi: 'इस बैठने को कभी-कभी "lightening" कहते हैं।'),
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 5 · MOTHER (pink) - make the mother feel seen
  // ===========================================================================
  JourneyMilestone(
    id: 'mo_w12',
    type: JourneyNodeType.mother,
    anchorWeek: 12,
    emoji: '🌸',
    title: LocalizedText(en: 'Morning sickness often eases', hi: 'सुबह की मतली अक्सर बेहतर होती है'),
    sections: [
      CardSection(
        LocalizedText(en: 'What many women feel', hi: 'कई माँएँ क्या महसूस करती हैं'),
        LocalizedText(en: 'Around now, nausea often starts to ease and a '
                          'little energy comes back.', hi: 'इस समय के आस-पास, मतली अक्सर कम होने लगती है और थोड़ी ऊर्जा लौटती है।'),
      ),
      CardSection(
        LocalizedText(en: "If it's hard", hi: 'भावनात्मक सहारा'),
        LocalizedText(en: "If you still feel unwell, that's okay too. Every "
                          "body is different.", hi: 'अगर अभी भी तबीयत ठीक नहीं लग रही, तो यह भी ठीक है — हर शरीर अलग होता है।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Looking after yourself', hi: 'अपना ख़याल'),
        [
          LocalizedText(en: 'Eat small meals often.', hi: 'थोड़ा-थोड़ा, बार-बार खाइए।'),
          LocalizedText(en: 'Rest whenever your body asks for it.', hi: 'जब भी शरीर कहे, आराम कीजिए।'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'mo_w20',
    type: JourneyNodeType.mother,
    anchorWeek: 20,
    emoji: '🌸',
    title: LocalizedText(en: 'Bump and first kicks', hi: 'बंप और पहली हलचल'),
    sections: [
      CardSection(
        LocalizedText(en: 'What many women feel', hi: 'कई माँएँ क्या महसूस करती हैं'),
        LocalizedText(en: 'A growing bump, first kicks, and often a rush of '
                          'excitement and connection.', hi: 'बढ़ता बंप, पहली हलचल, और अक्सर उत्साह और जुड़ाव की एक लहर।'),
      ),
      CardSection(
        LocalizedText(en: "If it's hard", hi: 'भावनात्मक सहारा'),
        LocalizedText(en: "It's natural to feel both joy and nerves. Both "
                          "are welcome.", hi: 'ख़ुशी और घबराहट दोनों महसूस होना स्वाभाविक है। दोनों का स्वागत है।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Looking after yourself', hi: 'अपना ख़याल'),
        [
          LocalizedText(en: 'Take a photo of your bump to remember this week.', hi: 'इस हफ़्ते को याद रखने के लिए अपने बंप की फ़ोटो लीजिए।'),
          LocalizedText(en: 'Gentle movement like walking can feel good.', hi: 'हल्की हलचल जैसे चलना बहुत अच्छा लग सकता है।'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'mo_w28',
    type: JourneyNodeType.mother,
    anchorWeek: 28,
    emoji: '🌸',
    title: LocalizedText(en: 'Getting ready for the third trimester', hi: 'शरीर तीसरी तिमाही के लिए तैयार'),
    sections: [
      CardSection(
        LocalizedText(en: 'What many women feel', hi: 'कई माँएँ क्या महसूस करती हैं'),
        LocalizedText(en: 'A bit more tiredness, some backache, and stronger '
                          'movements from your baby.', hi: 'थोड़ी ज़्यादा थकान, कभी कमर दर्द, और शिशु की तेज़ हलचल।'),
      ),
      CardSection(
        LocalizedText(en: "If it's hard", hi: 'भावनात्मक सहारा'),
        LocalizedText(en: "You're carrying a lot. Be as gentle with yourself "
                          "as you would be with a friend.", hi: 'आप बहुत कुछ सँभाल रही हैं — ख़ुद पर उतनी ही नरमी रखिए जितनी एक दोस्त पर।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Looking after yourself', hi: 'अपना ख़याल'),
        [
          LocalizedText(en: 'Support your back with a pillow when you rest.', hi: 'आराम करते वक़्त कमर के नीचे तकिया लगाइए।'),
          LocalizedText(en: 'Keep drinking water through the day.', hi: 'दिन भर पानी पीती रहिए।'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'mo_w36',
    type: JourneyNodeType.mother,
    anchorWeek: 36,
    emoji: '🌸',
    title: LocalizedText(en: 'The last stretch', hi: 'आख़िरी पड़ाव'),
    sections: [
      CardSection(
        LocalizedText(en: 'What many women feel', hi: 'कई माँएँ क्या महसूस करती हैं'),
        LocalizedText(en: 'Excitement, an urge to get everything ready, and '
                          'sometimes impatience to meet your baby.', hi: 'इंतज़ार, घर सजाने की ऊर्जा, और कभी शिशु से मिलने की बेताबी।'),
      ),
      CardSection(
        LocalizedText(en: "If it's hard", hi: 'भावनात्मक सहारा'),
        LocalizedText(en: "You're nearly there. Trust your body and lean on "
                          "the people who love you.", hi: 'आप बस पहुँचने ही वाली हैं। अपने शरीर पर भरोसा कीजिए और अपनों का सहारा लीजिए।'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Looking after yourself', hi: 'अपना ख़याल'),
        [
          LocalizedText(en: 'Rest in short stretches, and sleep when you can.', hi: 'थोड़ा-थोड़ा आराम कीजिए; जब मौक़ा मिले सो लीजिए।'),
          LocalizedText(en: 'Keep your hospital bag ready.', hi: 'अपना अस्पताल बैग तैयार रखिए।'),
        ],
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 6 · PARENTVEDA JOURNEY (green) - emotional engagement (day-anchored)
  // ===========================================================================
  JourneyMilestone(
    id: 'pv_d30',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 4,
    anchorDay: 30,
    emoji: '❤️',
    title: LocalizedText(en: '30 days together', hi: '30 दिन साथ'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: 'Thirty days of this together. The bond is already '
                          'growing.', hi: 'तीस दिन इस सफ़र में साथ चलते हुए। रिश्ता अभी से गहरा हो रहा है। ❤️'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'pv_d100',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 14,
    anchorDay: 100,
    emoji: '❤️',
    title: LocalizedText(en: '100 days together', hi: '100 दिन साथ'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: 'One hundred days of love, care and small moments.', hi: 'सौ दिन प्यार, देखभाल और शांत पलों के। ❤️'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'pv_d140',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 20,
    anchorDay: 140,
    emoji: '❤️',
    title: LocalizedText(en: '140 days together', hi: '140 दिन साथ'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: "One hundred and forty days. That's halfway. Look "
                          "how far you've come.", hi: 'एक सौ चालीस दिन — ठीक आधे। देखिए आप कितनी दूर आ चुकी हैं। ❤️'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'pv_d200',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 28,
    anchorDay: 200,
    emoji: '❤️',
    title: LocalizedText(en: '200 days together', hi: '200 दिन साथ'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: "Two hundred days. You're nearly there now.", hi: 'दो सौ दिन इस ख़ूबसूरत सफ़र के। अब बस थोड़ा और। ❤️'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'pv_d280',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 40,
    anchorDay: 280,
    emoji: '❤️',
    title: LocalizedText(en: 'Welcome, little one', hi: 'सफ़र पूरा'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: 'Two hundred and eighty days brought you here. '
                          'Welcome to the world, little one.', hi: 'दो सौ अस्सी दिन के प्यार ने आपको यहाँ पहुँचाया। दुनिया में स्वागत है, नन्हे। ❤️'),
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 7 · FEATURE UNLOCKS (teal) - natural feature discovery
  // ===========================================================================
  JourneyMilestone(
    id: 'f_weight',
    type: JourneyNodeType.feature,
    anchorWeek: 8,
    emoji: '🔓',
    title: LocalizedText(en: 'Weight tracker', hi: 'वज़न ट्रैकर'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'यह क्या करता है'),
        LocalizedText(en: 'Logs your weight through pregnancy, so you can '
                          'see steady change over time.', hi: 'गर्भावस्था में आपका वज़न हल्के से दर्ज करता है ताकि आप समय के साथ सेहतमंद, स्थिर बदलाव देख सकें।'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'यह क्यों मायने रखता है'),
        LocalizedText(en: 'Steady weight gain is one simple sign that things '
                          'are going well.', hi: 'स्थिर वज़न बढ़ना एक आसान संकेत है कि सब ठीक चल रहा है।'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'f_kegel',
    type: JourneyNodeType.feature,
    anchorWeek: 24,
    emoji: '🔓',
    title: LocalizedText(en: 'Kegel care', hi: 'Kegel care'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'यह क्या करता है'),
        LocalizedText(en: 'Guides you through gentle pelvic floor exercises, '
                          'with simple reminders.', hi: 'आसान रिमाइंडर के साथ हल्के pelvic-floor व्यायाम करवाता है।'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'यह क्यों मायने रखता है'),
        LocalizedText(en: 'A strong pelvic floor supports your body now and '
                          'helps you recover later.', hi: 'मज़बूत pelvic floor अभी आपके शरीर को सहारा देता है और बाद में रिकवरी में मदद करता है।'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'f_movement',
    type: JourneyNodeType.feature,
    anchorWeek: 28,
    emoji: '🔓',
    title: LocalizedText(en: 'Baby movement tracker', hi: 'शिशु हलचल ट्रैकर'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'यह क्या करता है'),
        LocalizedText(en: "Helps you get to know your baby's daily pattern "
                          "of movements, with no pressure to count.", hi: 'आपके शिशु की रोज़ाना हलचल के पैटर्न पर ध्यान देने में मदद करता है — गिनती का कोई दबाव नहीं।'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'यह क्यों मायने रखता है'),
        LocalizedText(en: "Knowing what's normal for your baby brings peace "
                          "of mind in the third trimester.", hi: 'अपने शिशु के लिए क्या सामान्य है यह जानना तीसरी तिमाही में सुकून देता है।'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'f_hospital',
    type: JourneyNodeType.feature,
    anchorWeek: 34,
    emoji: '🔓',
    title: LocalizedText(en: 'Hospital bag planner', hi: 'अस्पताल बैग प्लानर'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'यह क्या करता है'),
        LocalizedText(en: 'A ready checklist for your hospital bag, for you, '
                          'your baby and your partner.', hi: 'आपके अस्पताल बैग के लिए तैयार चेकलिस्ट — आपके, शिशु और साथी के लिए।'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'यह क्यों मायने रखता है'),
        LocalizedText(en: 'Packing early means one less thing to think about '
                          'when the day comes.', hi: 'पहले से पैक करना मतलब उस दिन एक कम चिंता।'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'f_contraction',
    type: JourneyNodeType.feature,
    anchorWeek: 36,
    emoji: '🔓',
    title: LocalizedText(en: 'Contraction tracker', hi: 'संकुचन ट्रैकर'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'यह क्या करता है'),
        LocalizedText(en: 'Times your contractions and the gaps between '
                          'them, so you know how things are moving along.', hi: 'आपके संकुचन और उनके बीच का समय दर्ज करता है, ताकि पता चले कब चीज़ें आगे बढ़ रही हैं।'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'यह क्यों मायने रखता है'),
        LocalizedText(en: 'Clear timing helps you and your doctor decide '
                          'when to go in.', hi: 'साफ़ समय आपको और डॉक्टर को तय करने में मदद करता है कि कब जाना है।'),
      ),
    ],
  ),
];
