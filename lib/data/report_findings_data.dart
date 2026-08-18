// =============================================================================
//  Understanding Your Report™  - curated seed
// -----------------------------------------------------------------------------
//  Calm, reassurance-first explainers for the most common scan/test findings
//  (all six "popular topics" + several more). GENERAL educational guidance - not
//  a diagnosis, not a prediction - written to leave a worried mother CALMER, per
//  the spec's writing rules (never "dangerous/serious/fatal"; "what does this
//  mean?" before "what are the risks?"). Needs medical review before the long
//  tail is expanded to the full ~27-condition launch list.
//
//  English-first: `_t` / `_l` mirror en into hi so Hindi can be authored later.
// =============================================================================

import '../localization/app_language.dart';
import '../models/report_finding.dart';

/// `_same('English')` mirrors, `_t('English', 'हिन्दी')` translates.
///
/// The second argument is optional so the file can be translated a section at
/// a time without a flag day: anything not yet given Hindi still renders its
/// English rather than a blank, which is the failure mode that matters when
/// the subject is a mother reading her own test report.
LocalizedText _t(String en, [String? hi]) =>
    LocalizedText(en: en, hi: hi ?? en);

/// Identical in both languages BY NATURE - a brand, a drug name printed on
/// a packet, an acronym a mother reads in Latin either way. Distinct from
/// `_en()`, which means 'English for now, Hindi owed'. This one is finished
/// work, and saying so is what keeps tool/hindi_audit.py honest.
LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

// `_l` is gone: it mirrored a list of English strings into `hi`, which is
// exactly what left the doctor questions and reassurances untranslated. Lists
// now hold `_t(en, hi)` pairs directly, so a new entry cannot be added without
// its Hindi being visible by its absence.

/// Popular-topic chips on the home (entry ids, per the spec's six).
const List<String> kReportPopular = [
  'low_lying_placenta',
  'nuchal_cord',
  'gestational_diabetes',
  'breech',
  'preeclampsia',
  'low_fluid',
];

final List<ReportFinding> kReportFindings = [
  ReportFinding(
    id: 'low_lying_placenta',
    tests: ['anomaly_scan', 'growth_scan'],
    name: _t('Low-Lying Placenta', 'नीचे बैठा Placenta'),
    altName: _same('Placenta Previa'),
    weekFrom: 18,
    weekTo: 22,
    whatItMeans: _t('This means the placenta is sitting lower in the uterus than usual, near or over the cervix. In most cases it gradually moves upward and out of the way as the uterus grows.', 'इसका मतलब है कि placenta बच्चेदानी में सामान्य से नीचे, cervix के पास या उस पर बैठा है। ज़्यादातर मामलों में बच्चेदानी बढ़ने के साथ यह धीरे-धीरे ऊपर खिसक जाता है और रास्ते से हट जाता है।'),
    howCommon: _t('It is a common finding on the mid-pregnancy scan. In the large majority of cases the placenta moves higher on its own later in pregnancy.', 'बीच की गर्भावस्था के स्कैन में यह आम बात है। बड़ी संख्या में मामलों में placenta आगे चलकर अपने आप ऊपर चला जाता है।'),
    whatNext: _t('Your doctor will usually arrange a follow-up scan later in pregnancy to check the placenta\'s position. That scan helps guide any plans for your delivery.', 'आपके डॉक्टर आम तौर पर आगे चलकर एक और स्कैन कराएँगे ताकि placenta की जगह देखी जा सके। वही स्कैन डिलीवरी की योजना तय करने में मदद करता है।'),
    questions: [
      _t('Has the placenta moved since my last scan?', 'क्या पिछले स्कैन के बाद placenta ऊपर खिसका है?'),
      _t('Will I need another scan to check the position?', 'क्या जगह देखने के लिए एक और स्कैन चाहिए?'),
      _t('Does this change anything about my delivery plan?', 'क्या इससे मेरी डिलीवरी की योजना में कुछ बदलता है?'),
    ],
    remember: [
      _t('Most low-lying placentas move up on their own.', 'ज़्यादातर नीचे बैठे placenta अपने आप ऊपर चले जाते हैं।'),
      _t('Follow-up scans for this are very common.', 'इसके लिए आगे स्कैन कराना बहुत आम है।'),
      _t('Your provider will keep an eye on it over time.', 'आपके डॉक्टर समय के साथ इस पर नज़र रखेंगे।'),
    ],
    aliases: ['placenta', 'previa', 'placenta previa', 'low placenta', 'cervix को ढकता placenta', 'नीचे लगा placenta'],
  ),
  ReportFinding(
    id: 'breech',
    tests: ['growth_scan'],
    name: _t('Breech Position', 'उल्टी मुद्रा (Breech)'),
    altName: _t('Breech Baby', 'Breech शिशु'),
    weekFrom: 32,
    weekTo: 36,
    whatItMeans: _t('This means your baby is currently positioned bottom- or feet-down rather than head-down. Many babies are breech earlier in pregnancy and turn head-down on their own before birth.', 'इसका मतलब है कि आपका शिशु अभी सिर के बजाय कूल्हे या पैर नीचे किए हुए है। कई शिशु गर्भावस्था के शुरुआती दौर में breech होते हैं और जन्म से पहले ख़ुद ही सिर नीचे कर लेते हैं।'),
    howCommon: _t('Being breech is common through much of pregnancy. The number of babies who stay breech keeps falling as the due date comes closer.', 'गर्भावस्था के बड़े हिस्से में breech होना आम है। डिलीवरी की तारीख़ जैसे-जैसे पास आती है, breech रह जाने वाले शिशुओं की संख्या घटती जाती है।'),
    whatNext: _t('Your doctor will keep checking your baby\'s position. If your baby is still breech later on, they may discuss gentle options to encourage turning, or the safest way to plan your birth.', 'आपके डॉक्टर शिशु की मुद्रा देखते रहेंगे। अगर आगे भी शिशु breech रहा, तो वे उसे घुमाने के सौम्य तरीक़े, या जन्म की सबसे सुरक्षित योजना पर बात कर सकते हैं।'),
    questions: [
      _t('Is there still time for the baby to turn?', 'क्या शिशु के घूमने के लिए अभी समय है?'),
      _t('What are my options if the baby stays breech?', 'अगर शिशु breech ही रहा तो मेरे पास क्या विकल्प हैं?'),
      _t('Would you recommend anything to help the baby turn?', 'शिशु को घूमने में मदद के लिए आप क्या सुझाएँगे?'),
    ],
    remember: [
      _t('Many babies turn head-down on their own before birth.', 'बहुत से शिशु जन्म से पहले ख़ुद ही सिर नीचे कर लेते हैं।'),
      _t('Position is checked again as you get closer to term.', 'पूरे समय के क़रीब मुद्रा दोबारा जाँची जाती है।'),
      _t('There are safe options if your baby stays breech.', 'अगर शिशु breech रहे, तब भी सुरक्षित विकल्प मौजूद हैं।'),
    ],
    aliases: ['breech', 'breech baby', 'baby position', 'footling', 'breech शिशु', 'शिशु की स्थिति'],
  ),
  ReportFinding(
    id: 'nuchal_cord',
    tests: ['growth_scan', 'anomaly_scan'],
    name: _t('Cord Around Neck', 'गर्दन के चारों ओर गर्भनाल'),
    altName: _same('Nuchal Cord'),
    weekFrom: 36,
    whatItMeans: _t('This means the umbilical cord is looped around the baby\'s neck. Scans often pick this up, and in most pregnancies it does not cause problems - the cord is built to keep delivering oxygen.', 'इसका मतलब है कि गर्भनाल शिशु की गर्दन के चारों ओर लिपटी है। स्कैन में यह अक्सर दिख जाता है, और ज़्यादातर गर्भावस्थाओं में इससे कोई दिक़्क़त नहीं होती — गर्भनाल ऑक्सीजन पहुँचाती रहने के लिए ही बनी है।'),
    howCommon: _t('A nuchal cord is a frequent scan finding, especially closer to term. Many babies are born safely with a cord around the neck.', 'Nuchal cord स्कैन में अक्सर मिलता है, ख़ासकर पूरे समय के क़रीब। बहुत से शिशु गर्दन में गर्भनाल के साथ सुरक्षित जन्म लेते हैं।'),
    whatNext: _t('Your doctor will note it and continue routine monitoring of your baby. It usually does not change how your birth is planned.', 'आपके डॉक्टर इसे दर्ज कर लेंगे और शिशु की सामान्य निगरानी जारी रखेंगे। आम तौर पर इससे जन्म की योजना नहीं बदलती।'),
    questions: [
      _t('Does this change anything about my delivery?', 'क्या इससे मेरी डिलीवरी में कुछ बदलता है?'),
      _t('Will you keep monitoring the baby during labour?', 'क्या प्रसव के दौरान आप शिशु पर नज़र रखेंगे?'),
      _t('Is there anything I should watch for?', 'क्या मुझे किसी बात का ध्यान रखना है?'),
    ],
    remember: [
      _t('A nuchal cord is common and often unwinds on its own.', 'Nuchal cord आम है और अक्सर अपने आप खुल जाती है।'),
      _t('The cord keeps supplying oxygen throughout.', 'गर्भनाल पूरे समय ऑक्सीजन पहुँचाती रहती है।'),
      _t('Your team monitors the baby closely during labour.', 'प्रसव के दौरान आपकी टीम शिशु पर क़रीबी नज़र रखती है।'),
    ],
    aliases: ['cord', 'nuchal cord', 'cord around neck', 'cord around baby', 'गर्दन में लिपटी गर्भनाल', 'गर्दन के चारों ओर गर्भनाल', 'शिशु के चारों ओर गर्भनाल'],
  ),
  ReportFinding(
    id: 'gestational_diabetes',
    tests: ['ogtt', 'growth_scan'],
    name: _t('Gestational Diabetes', 'गर्भावस्था की डायबिटीज़'),
    altName: _same('GDM'),
    weekFrom: 24,
    weekTo: 28,
    whatItMeans: _t('This means your body is having some trouble managing blood sugar during pregnancy. With the right steps it is usually well controlled, and it most often goes away after the baby is born.', 'इसका मतलब है कि गर्भावस्था के दौरान आपके शरीर को blood sugar सँभालने में थोड़ी दिक़्क़त हो रही है। सही क़दमों से यह आम तौर पर अच्छी तरह क़ाबू में रहती है, और ज़्यादातर शिशु के जन्म के बाद चली जाती है।'),
    howCommon: _t('Gestational diabetes is one of the more common findings, picked up by a routine sugar test in mid-pregnancy.', 'Gestational diabetes ज़्यादा आम नतीजों में से एक है, जो बीच की गर्भावस्था में एक सामान्य शुगर टेस्ट से पकड़ी जाती है।'),
    whatNext: _t('Your doctor will guide you on diet, gentle activity and checking your sugar levels. Some mothers also need medication. Regular check-ins help keep everything on track.', 'आपके डॉक्टर खानपान, हल्की गतिविधि और शुगर जाँचने पर मार्गदर्शन देंगे। कुछ माँओं को दवा भी लगती है। नियमित जाँच से सब कुछ पटरी पर रहता है।'),
    questions: [
      _t('What diet changes would help most?', 'खानपान में कौन से बदलाव सबसे ज़्यादा मदद करेंगे?'),
      _t('How often should I check my sugar levels?', 'मुझे अपनी शुगर कितनी बार जाँचनी चाहिए?'),
      _t('Will this affect my delivery?', 'क्या इसका असर मेरी डिलीवरी पर पड़ेगा?'),
    ],
    remember: [
      _t('It is usually well managed with simple changes.', 'आसान बदलावों से यह आम तौर पर अच्छी तरह सँभल जाती है।'),
      _t('It most often resolves after birth.', 'ज़्यादातर यह जन्म के बाद ठीक हो जाती है।'),
      _t('Your care team will support you through it.', 'आपकी देखभाल करने वाली टीम पूरे समय साथ रहेगी।'),
    ],
    aliases: ['gestational diabetes', 'gdm', 'diabetes', 'sugar', 'high sugar', 'gtt', 'गर्भावस्था की diabetes', 'शक्कर ज़्यादा'],
  ),
  ReportFinding(
    id: 'low_fluid',
    tests: ['growth_scan', 'doppler'],
    name: _t('Low Amniotic Fluid', 'कम Amniotic Fluid'),
    altName: _same('Oligohydramnios'),
    weekFrom: 30,
    weekTo: 40,
    whatItMeans: _t('This means the amount of fluid around your baby is on the lower side. The level can change, and your doctor will look at it alongside how your baby is growing and moving.', 'इसका मतलब है कि आपके शिशु के आस-पास तरल की मात्रा कुछ कम है। यह स्तर बदल सकता है, और आपके डॉक्टर इसे शिशु की बढ़त और हलचल के साथ मिलाकर देखेंगे।'),
    howCommon: _t('Lower fluid levels are sometimes seen on later scans, and the reading can vary from one scan to the next.', 'बाद के स्कैन में कभी-कभी तरल कम दिखता है, और यह माप एक स्कैन से दूसरे में बदल भी सकता है।'),
    whatNext: _t('Your doctor may suggest extra fluids, more frequent scans, or closer monitoring of your baby. The plan depends on how far along you are and how your baby is doing.', 'आपके डॉक्टर ज़्यादा पानी पीने, बार-बार स्कैन, या शिशु पर क़रीबी नज़र रखने की सलाह दे सकते हैं। योजना इस पर निर्भर करती है कि आप कितनी आगे हैं और शिशु कैसा है।'),
    questions: [
      _t('Would drinking more water help?', 'क्या ज़्यादा पानी पीने से मदद मिलेगी?'),
      _t('How often will the fluid be re-checked?', 'तरल दोबारा कितनी बार जाँचा जाएगा?'),
      _t('How is my baby\'s growth and movement?', 'मेरे शिशु की बढ़त और हलचल कैसी है?'),
    ],
    remember: [
      _t('Fluid levels can change between scans.', 'एक स्कैन से दूसरे में तरल का स्तर बदल सकता है।'),
      _t('Extra monitoring is a common, careful step.', 'ज़्यादा निगरानी एक आम, सावधानी भरा क़दम है।'),
      _t('Staying well hydrated is often advised.', 'पर्याप्त पानी पीते रहने की सलाह अक्सर दी जाती है।'),
    ],
    aliases: ['low fluid', 'amniotic fluid', 'oligohydramnios', 'low water', 'afi', 'liquor', 'पानी की कमी', 'गर्भ का पानी', 'गर्भ का पानी कम'],
  ),
  ReportFinding(
    id: 'preeclampsia',
    tests: ['blood_tests', 'doppler'],
    name: _same('Preeclampsia'),
    weekFrom: 20,
    whatItMeans: _t('This means your blood pressure is raised during pregnancy, sometimes with other signs that your body needs closer attention. It is something doctors watch carefully and manage step by step.', 'इसका मतलब है कि गर्भावस्था में आपका ब्लड प्रेशर बढ़ा हुआ है, कभी-कभी कुछ और संकेतों के साथ जो बताते हैं कि शरीर पर ज़्यादा ध्यान चाहिए। डॉक्टर इस पर सावधानी से नज़र रखते हैं और क़दम-दर-क़दम सँभालते हैं।'),
    howCommon: _t('It is a recognised pregnancy finding that care teams screen for at routine visits - which is why your blood pressure and urine are checked each time.', 'यह गर्भावस्था का एक जाना-पहचाना नतीजा है जिसके लिए हर सामान्य विज़िट पर जाँच होती है — इसीलिए हर बार आपका ब्लड प्रेशर और पेशाब देखा जाता है।'),
    whatNext: _t('Your doctor will monitor your blood pressure more closely, may run some tests, and will guide the timing and plan for a safe delivery. Rest and follow-up visits are usually part of this.', 'आपके डॉक्टर ब्लड प्रेशर पर और क़रीबी नज़र रखेंगे, कुछ टेस्ट करा सकते हैं, और सुरक्षित डिलीवरी का समय व योजना बताएँगे। आराम और बार-बार विज़िट आम तौर पर इसका हिस्सा होते हैं।'),
    questions: [
      _t('How often should my blood pressure be checked?', 'मेरा ब्लड प्रेशर कितनी बार जाँचा जाना चाहिए?'),
      _t('Are there any signs I should call you about?', 'किन संकेतों पर मुझे आपको फ़ोन करना चाहिए?'),
      _t('How might this affect the timing of delivery?', 'इससे डिलीवरी के समय पर क्या असर पड़ सकता है?'),
    ],
    remember: [
      _t('It is usually found through the routine checks at your visits.', 'यह आम तौर पर विज़िट की सामान्य जाँच में ही पकड़ में आता है।'),
      _t('Closer monitoring helps your team manage it well.', 'क़रीबी निगरानी से आपकी टीम इसे अच्छी तरह सँभालती है।'),
      _t('Your provider will guide every next step.', 'आपके डॉक्टर हर अगले क़दम पर मार्गदर्शन देंगे।'),
    ],
    aliases: ['preeclampsia', 'pre eclampsia', 'high bp', 'blood pressure', 'pih', 'protein in urine', 'गर्भावस्था का high bp', 'bp ज़्यादा', 'पेशाब में protein'],
  ),
  ReportFinding(
    id: 'high_fluid',
    tests: ['growth_scan'],
    name: _t('High Amniotic Fluid', 'ज़्यादा Amniotic Fluid'),
    altName: _same('Polyhydramnios'),
    weekFrom: 28,
    weekTo: 40,
    whatItMeans: _t('This means there is a little more fluid around your baby than average. In many cases no specific cause is found and the pregnancy continues well.', 'इसका मतलब है कि आपके शिशु के आस-पास औसत से थोड़ा ज़्यादा तरल है। कई बार कोई ख़ास वजह नहीं मिलती और गर्भावस्था अच्छी चलती रहती है।'),
    howCommon: _t('Higher fluid levels are sometimes noted on later scans, and are often mild.', 'बाद के स्कैन में तरल का ज़्यादा होना कभी-कभी दिखता है, और अक्सर हल्का ही होता है।'),
    whatNext: _t('Your doctor may recommend follow-up scans and a few checks to understand the cause, while keeping an eye on your comfort and your baby\'s growth.', 'आपके डॉक्टर आगे के स्कैन और कुछ जाँचें सुझा सकते हैं ताकि वजह समझी जा सके, साथ ही आपकी सहूलियत और शिशु की बढ़त पर नज़र रखी जाए।'),
    questions: [
      _t('Is there a cause we should look into?', 'क्या कोई वजह है जिसे देखना चाहिए?'),
      _t('Will I need more scans?', 'क्या मुझे और स्कैन कराने होंगे?'),
      _t('Is there anything I should watch for?', 'क्या मुझे किसी बात का ध्यान रखना है?'),
    ],
    remember: [
      _t('Mild increases are often harmless.', 'हल्की बढ़ोतरी अक्सर हानिरहित होती है।'),
      _t('A clear cause is not always found, and that is okay.', 'साफ़ वजह हमेशा नहीं मिलती, और यह ठीक है।'),
      _t('Follow-up keeps everything monitored.', 'आगे की जाँच से सब कुछ नज़र में रहता है।'),
    ],
    aliases: ['high fluid', 'polyhydramnios', 'excess fluid', 'too much water', 'afi high', 'गर्भ का पानी ज़्यादा', 'ज़रूरत से ज़्यादा पानी', 'पानी बहुत ज़्यादा', 'afi ज़्यादा'],
  ),
  ReportFinding(
    id: 'short_cervix',
    tests: ['anomaly_scan', 'growth_scan'],
    name: _t('Short Cervix', 'छोटा Cervix'),
    weekFrom: 18,
    weekTo: 24,
    whatItMeans: _t('This means the cervix is measuring shorter than average on a scan. Your doctor pays attention to this because it helps them support a full-term pregnancy.', 'इसका मतलब है कि स्कैन में cervix औसत से छोटा नाप रहा है। आपके डॉक्टर इस पर ध्यान देते हैं क्योंकि इससे पूरे समय तक गर्भावस्था सँभालने में मदद मिलती है।'),
    howCommon: _t('It is a finding that mid-pregnancy scans can pick up, and there are well-established ways to support it.', 'यह वह बात है जो बीच की गर्भावस्था के स्कैन में पकड़ में आ सकती है, और इसे सँभालने के जाने-माने तरीक़े मौजूद हैं।'),
    whatNext: _t('Depending on the measurement, your doctor may suggest follow-up scans, more rest, or a simple supportive treatment. They will tailor the plan to you.', 'माप के हिसाब से आपके डॉक्टर आगे के स्कैन, ज़्यादा आराम, या एक आसान सहारा देने वाला इलाज सुझा सकते हैं। योजना वे आपके हिसाब से बनाएँगे।'),
    questions: [
      _t('Will the cervix length be measured again?', 'क्या cervix की लंबाई दोबारा नापी जाएगी?'),
      _t('Is there a treatment that would help?', 'क्या कोई इलाज है जो मदद करेगा?'),
      _t('Is there anything I should do differently?', 'क्या मुझे कुछ अलग करना चाहिए?'),
    ],
    remember: [
      _t('There are established ways to support a short cervix.', 'छोटे cervix को सँभालने के जाने-माने तरीक़े मौजूद हैं।'),
      _t('Follow-up measurements are common.', 'आगे दोबारा नाप लेना आम बात है।'),
      _t('Your provider will personalise the plan.', 'आपके डॉक्टर योजना आपके हिसाब से बनाएँगे।'),
    ],
    aliases: ['short cervix', 'cervix', 'cervical length', 'cervical', 'छोटा cervix', 'cervix की लंबाई'],
  ),
  ReportFinding(
    id: 'placental_calcification',
    tests: ['growth_scan'],
    name: _t('Placental Calcification', 'Placenta में Calcification'),
    weekFrom: 28,
    weekTo: 40,
    whatItMeans: _t('This means small calcium deposits are showing in the placenta. This is a normal part of the placenta maturing as pregnancy goes on, especially later.', 'इसका मतलब है कि placenta में calcium के छोटे जमाव दिख रहे हैं। गर्भावस्था आगे बढ़ने के साथ placenta का परिपक्व होना सामान्य है, ख़ासकर बाद के दौर में।'),
    howCommon: _t('Calcification is a common observation on later scans, and is often simply a sign of a maturing placenta.', 'बाद के स्कैन में calcification आम बात है, और अक्सर यह सिर्फ़ परिपक्व होते placenta का संकेत होता है।'),
    whatNext: _t('Usually no special action is needed. Your doctor will continue routine monitoring of your baby\'s growth and wellbeing.', 'आम तौर पर कुछ ख़ास करने की ज़रूरत नहीं। आपके डॉक्टर शिशु की बढ़त और सेहत की सामान्य निगरानी जारी रखेंगे।'),
    questions: [
      _t('Does this affect my baby\'s growth?', 'क्या इससे मेरे शिशु की बढ़त पर असर पड़ता है?'),
      _t('Is any extra monitoring needed?', 'क्या कोई अतिरिक्त निगरानी चाहिए?'),
      _t('Is this expected for my stage of pregnancy?', 'क्या यह मेरी गर्भावस्था के इस चरण के लिए सामान्य है?'),
    ],
    remember: [
      _t('It is often a normal sign of a maturing placenta.', 'यह अक्सर परिपक्व होते placenta का सामान्य संकेत होता है।'),
      _t('It is commonly seen on later scans.', 'बाद के स्कैन में यह आम तौर पर दिखता है।'),
      _t('Routine monitoring usually continues as normal.', 'सामान्य निगरानी आम तौर पर जारी रहती है।'),
    ],
    aliases: ['placental calcification', 'calcification', 'placenta grade', 'grade 3 placenta', 'placenta', 'placenta में calcification', 'placenta का grade', 'grade 3 वाला placenta'],
  ),
  ReportFinding(
    id: 'twin_pregnancy',
    tests: ['dating_scan', 'anomaly_scan'],
    name: _t('Twin Pregnancy', 'जुड़वाँ गर्भावस्था'),
    weekFrom: 6,
    weekTo: 12,
    whatItMeans: _t('This means you are expecting more than one baby. Twin pregnancies are followed a little more closely, with some extra scans and visits to support you and your babies.', 'इसका मतलब है कि आपके गर्भ में एक से ज़्यादा शिशु हैं। जुड़वाँ गर्भावस्था पर थोड़ी ज़्यादा क़रीबी नज़र रखी जाती है — कुछ अतिरिक्त स्कैन और विज़िट के साथ, आपके और आपके शिशुओं के लिए।'),
    howCommon: _t('Twins are usually identified on an early scan. They are well understood and routinely cared for.', 'जुड़वाँ आम तौर पर शुरुआती स्कैन में ही पता चल जाते हैं। इन्हें अच्छी तरह समझा गया है और इनकी देखभाल रोज़ की बात है।'),
    whatNext: _t('Your doctor will arrange a schedule of extra scans and check-ups to monitor growth and wellbeing, and will talk you through what to expect.', 'आपके डॉक्टर बढ़त और सेहत देखने के लिए अतिरिक्त स्कैन और जाँच का कार्यक्रम बनाएँगे, और आपको बताएँगे कि आगे क्या उम्मीद रखनी है।'),
    questions: [
      _t('How often will I have scans and visits?', 'मेरे स्कैन और विज़िट कितनी बार होंगे?'),
      _t('What extra care does a twin pregnancy need?', 'जुड़वाँ गर्भावस्था में अतिरिक्त देखभाल क्या चाहिए?'),
      _t('What should I expect around delivery?', 'डिलीवरी के आस-पास मुझे क्या उम्मीद रखनी चाहिए?'),
    ],
    remember: [
      _t('Twin pregnancies are routinely and safely cared for.', 'जुड़वाँ गर्भावस्था की देखभाल रोज़ की और सुरक्षित बात है।'),
      _t('Extra scans are a normal, supportive step.', 'अतिरिक्त स्कैन एक सामान्य, सहारा देने वाला क़दम है।'),
      _t('Your team will guide you the whole way.', 'आपकी टीम पूरे रास्ते साथ रहेगी।'),
    ],
    aliases: ['twin', 'twins', 'twin pregnancy', 'multiple', 'two babies', 'जुड़वाँ गर्भावस्था', 'दो शिशु'],
  ),
  ReportFinding(
    id: 'anemia',
    tests: ['blood_tests', 'growth_scan'],
    name: _t('Anemia During Pregnancy', 'गर्भावस्था में ख़ून की कमी'),
    whatItMeans: _t('This means your blood has fewer healthy red cells or less iron than ideal - common in pregnancy as your body makes more blood for your baby. It is usually straightforward to improve.', 'इसका मतलब है कि आपके ख़ून में सेहतमंद लाल कोशिकाएँ या Iron ज़रूरत से कम हैं — गर्भावस्था में यह आम है, क्योंकि शरीर शिशु के लिए ज़्यादा ख़ून बनाता है। इसे सुधारना आम तौर पर आसान होता है।'),
    howCommon: _t('Mild anemia is very common in pregnancy and is picked up by routine blood tests.', 'हल्की anemia गर्भावस्था में बहुत आम है और सामान्य ख़ून की जाँच में पकड़ में आ जाती है।'),
    whatNext: _t('Your doctor will usually recommend iron-rich foods and often an iron supplement, then re-check your levels. Most mothers improve with these simple steps.', 'आपके डॉक्टर आम तौर पर Iron से भरपूर खाना और अक्सर एक Iron सप्लीमेंट सुझाएँगे, फिर स्तर दोबारा जाँचेंगे। इन आसान क़दमों से ज़्यादातर माँओं में सुधार हो जाता है।'),
    questions: [
      _t('Which iron supplement and dose do you recommend?', 'आप कौन सा Iron सप्लीमेंट और कितनी मात्रा सुझाएँगे?'),
      _t('Which foods would help most?', 'कौन से खाने सबसे ज़्यादा मदद करेंगे?'),
      _t('When should we re-check my levels?', 'हमें मेरा स्तर दोबारा कब जाँचना चाहिए?'),
    ],
    remember: [
      _t('Mild anemia in pregnancy is very common.', 'गर्भावस्था में हल्की anemia बहुत आम है।'),
      _t('It usually improves with iron and diet.', 'Iron और खानपान से यह आम तौर पर सुधर जाती है।'),
      _t('Levels are simply re-checked after treatment.', 'इलाज के बाद बस स्तर दोबारा जाँच लिया जाता है।'),
    ],
    aliases: ['anemia', 'anaemia', 'low hemoglobin', 'low hb', 'iron', 'haemoglobin', 'haemoglobin की कमी', 'कम hb'],
  ),
  ReportFinding(
    id: 'reduced_movements',
    tests: ['growth_scan', 'doppler'],
    name: _t('Reduced Fetal Movements', 'शिशु की हलचल कम होना'),
    weekFrom: 28,
    whatItMeans: _t('This means your baby\'s movements have felt less frequent or different than usual. Movement patterns naturally change, and getting it checked is always the right thing to do.', 'इसका मतलब है कि आपके शिशु की हलचल पहले से कम या अलग महसूस हुई है। हलचल का ढंग स्वाभाविक रूप से बदलता है, और इसे जँचवा लेना हमेशा सही क़दम है।'),
    howCommon: _t('Many mothers notice changes in movement at some point. It is one of the most common reasons for a quick reassurance check.', 'कई माँओं को कभी न कभी हलचल में बदलाव महसूस होता है। जल्दी से तसल्ली कर लेने की यह सबसे आम वजहों में से एक है।'),
    whatNext: _t('If you ever feel reduced movements, contact your doctor or hospital - they will check your baby, often with a simple heartbeat or monitoring test. It is always okay to get checked.', 'अगर कभी हलचल कम लगे, तो अपने डॉक्टर या अस्पताल से संपर्क कीजिए — वे शिशु को जाँचेंगे, अक्सर एक आसान धड़कन या निगरानी टेस्ट से। जँचवा लेना हमेशा ठीक है।'),
    questions: [
      _t('What is the best way to monitor movements?', 'हलचल पर नज़र रखने का सबसे अच्छा तरीक़ा क्या है?'),
      _t('When exactly should I call you?', 'मुझे ठीक-ठीक कब आपको फ़ोन करना चाहिए?'),
      _t('Can I come in for a reassurance check?', 'क्या मैं तसल्ली के लिए जाँच कराने आ सकती हूँ?'),
    ],
    remember: [
      _t('Always get reduced movements checked - never wait it out.', 'हलचल कम लगे तो हमेशा जँचवाइए — इंतज़ार मत कीजिए।'),
      _t('A reassurance check is quick and very common.', 'तसल्ली वाली जाँच जल्दी होती है और बहुत आम है।'),
      _t('You know your baby\'s usual pattern best.', 'अपने शिशु का रोज़ का ढंग आप सबसे बेहतर जानती हैं।'),
    ],
    aliases: ['reduced movements', 'baby not moving', 'less movement', 'fetal movements', 'kicks', 'हलचल कम होना', 'शिशु हिल नहीं रहा', 'कम हलचल', 'शिशु की हलचल'],
  ),
  ReportFinding(
    id: 'braxton_hicks',
    name: _t('Braxton Hicks Contractions', 'Braxton Hicks संकुचन'),
    weekFrom: 20,
    whatItMeans: _t('This means you are feeling practice contractions - your uterus tightening and relaxing as it prepares for labour. They are usually irregular and ease off with rest or a change of position.', 'इसका मतलब है कि आपको अभ्यास वाले संकुचन महसूस हो रहे हैं — बच्चेदानी कस रही है और ढीली हो रही है, प्रसव की तैयारी में। ये आम तौर पर अनियमित होते हैं और आराम करने या करवट बदलने पर कम हो जाते हैं।'),
    howCommon: _t('Braxton Hicks are a very common, normal part of the second half of pregnancy.', 'Braxton Hicks गर्भावस्था के दूसरे आधे हिस्से का बहुत आम, सामान्य हिस्सा हैं।'),
    whatNext: _t('Usually nothing is needed beyond rest, water and changing position. Your doctor will explain how to tell these apart from real labour, and when to call.', 'आम तौर पर आराम, पानी और मुद्रा बदलने से ज़्यादा कुछ नहीं चाहिए। आपके डॉक्टर बताएँगे कि इन्हें असली प्रसव से कैसे पहचानें, और कब फ़ोन करना है।'),
    questions: [
      _t('How do I tell these apart from real labour?', 'इन्हें असली प्रसव से कैसे पहचानूँ?'),
      _t('When should I call you about contractions?', 'संकुचन के बारे में मुझे आपको कब फ़ोन करना चाहिए?'),
      _t('Is there anything that helps ease them?', 'क्या कुछ है जिससे इनमें आराम मिले?'),
    ],
    remember: [
      _t('They are practice contractions, usually harmless.', 'ये अभ्यास वाले संकुचन हैं, आम तौर पर हानिरहित।'),
      _t('They tend to be irregular and ease with rest.', 'ये अक्सर अनियमित होते हैं और आराम से कम हो जाते हैं।'),
      _t('Your provider will explain the signs of real labour.', 'आपके डॉक्टर असली प्रसव के संकेत समझा देंगे।'),
    ],
    aliases: ['braxton hicks', 'practice contractions', 'false labour', 'tightening', 'contractions', 'Braxton Hicks संकुचन', 'अभ्यास वाले संकुचन', 'झूठा प्रसव दर्द'],
  ),
  ReportFinding(
    id: 'high_bp',
    tests: ['blood_tests'],
    name: _t('High Blood Pressure', 'ज़्यादा ब्लड प्रेशर'),
    altName: _same('Gestational Hypertension'),
    weekFrom: 20,
    whatItMeans: _t('This means your blood pressure is higher than usual during pregnancy. It is something your care team watches closely and manages step by step.', 'इसका मतलब है कि गर्भावस्था में आपका ब्लड प्रेशर सामान्य से ज़्यादा है। आपकी देखभाल करने वाली टीम इस पर क़रीबी नज़र रखती है और क़दम-दर-क़दम सँभालती है।'),
    howCommon: _t('Raised blood pressure is a recognised pregnancy finding - which is why it is checked at every routine visit.', 'बढ़ा हुआ ब्लड प्रेशर गर्भावस्था का एक जाना-पहचाना नतीजा है — इसीलिए हर सामान्य विज़िट पर इसकी जाँच होती है।'),
    whatNext: _t('Your doctor will monitor your readings more often, may suggest some rest and a few tests, and will guide you on what to watch for. Many mothers manage it well with regular follow-up.', 'आपके डॉक्टर आपकी रीडिंग ज़्यादा बार देखेंगे, कुछ आराम और कुछ टेस्ट सुझा सकते हैं, और बताएँगे कि किन बातों पर ध्यान रखना है। बहुत सी माँएँ नियमित जाँच के साथ इसे अच्छी तरह सँभाल लेती हैं।'),
    questions: [
      _t('How often should my blood pressure be checked?', 'मेरा ब्लड प्रेशर कितनी बार जाँचा जाना चाहिए?'),
      _t('Are there any signs I should call you about?', 'किन संकेतों पर मुझे आपको फ़ोन करना चाहिए?'),
      _t('Will I need any medication?', 'क्या मुझे कोई दवा लगेगी?'),
    ],
    remember: [
      _t('It is picked up by the routine checks at your visits.', 'यह विज़िट की सामान्य जाँच में ही पकड़ में आ जाता है।'),
      _t('Closer monitoring helps keep it well managed.', 'क़रीबी निगरानी से यह अच्छी तरह क़ाबू में रहता है।'),
      _t('Your provider will guide each step.', 'आपके डॉक्टर हर क़दम पर मार्गदर्शन देंगे।'),
    ],
    aliases: ['high blood pressure', 'bp', 'hypertension', 'gestational hypertension', 'pih', 'ज़्यादा ब्लड प्रेशर', 'गर्भावस्था का hypertension'],
  ),
  ReportFinding(
    id: 'placenta_resolved',
    tests: ['growth_scan', 'anomaly_scan'],
    name: _t('Low-Lying Placenta (Resolved)', 'नीचे बैठा Placenta (ठीक हो गया)'),
    altName: _t('Placenta Moved Up', 'Placenta ऊपर चला गया'),
    weekFrom: 28,
    weekTo: 36,
    whatItMeans: _t('This is good news - a placenta that was earlier sitting low has now moved upward, away from the cervix, as the uterus grew. This is exactly what usually happens.', 'यह अच्छी ख़बर है — जो placenta पहले नीचे बैठा था, वह बच्चेदानी बढ़ने के साथ अब ऊपर, cervix से दूर चला गया है। आम तौर पर ऐसा ही होता है।'),
    howCommon: _t('Most low-lying placentas resolve this way by the later scans. It is the common, expected outcome.', 'ज़्यादातर नीचे बैठे placenta बाद के स्कैन तक इसी तरह ठीक हो जाते हैं। यही आम और अपेक्षित नतीजा है।'),
    whatNext: _t('Usually nothing further is needed for this. Your doctor will continue your regular pregnancy care as normal.', 'इसके लिए आम तौर पर आगे कुछ नहीं चाहिए। आपके डॉक्टर आपकी सामान्य गर्भावस्था देखभाल जारी रखेंगे।'),
    questions: [
      _t('Does this mean my delivery plan is back to normal?', 'क्या इसका मतलब है कि मेरी डिलीवरी की योजना सामान्य हो गई?'),
      _t('Is any further scan needed for this?', 'क्या इसके लिए आगे कोई स्कैन चाहिए?'),
      _t('Is there anything I should watch for?', 'क्या मुझे किसी बात का ध्यान रखना है?'),
    ],
    remember: [
      _t('A resolved low-lying placenta is reassuring news.', 'नीचे बैठे placenta का ठीक हो जाना तसल्ली देने वाली ख़बर है।'),
      _t('This is the usual outcome.', 'आम तौर पर यही नतीजा निकलता है।'),
      _t('Normal care typically continues.', 'सामान्य देखभाल आम तौर पर वैसे ही चलती रहती है।'),
    ],
    aliases: ['placenta moved', 'low lying placenta resolved', 'placenta', 'previa resolved', 'placenta ऊपर चला गया', 'नीचे लगा placenta ठीक हो गया', 'previa ठीक हो गया'],
  ),
  ReportFinding(
    id: 'small_baby',
    tests: ['growth_scan', 'doppler'],
    name: _t('Small Baby For Gestational Age', 'उम्र के हिसाब से छोटा शिशु'),
    altName: _same('SGA'),
    weekFrom: 28,
    weekTo: 40,
    whatItMeans: _t('This means your baby is measuring a little smaller than average for this stage. Babies come in many healthy sizes, and your doctor looks at the trend over time, not a single number.', 'इसका मतलब है कि आपका शिशु इस चरण के औसत से थोड़ा छोटा नाप रहा है। शिशु कई सेहतमंद आकारों में आते हैं, और आपके डॉक्टर एक अकेले नंबर के बजाय समय के साथ का रुझान देखते हैं।'),
    howCommon: _t('It is a common scan observation. In many cases the baby is simply naturally small and growing steadily along their own curve.', 'यह स्कैन में आम बात है। कई बार शिशु बस स्वाभाविक रूप से छोटा होता है और अपनी ही curve पर लगातार बढ़ता रहता है।'),
    whatNext: _t('Your doctor may arrange follow-up growth scans and check the blood flow and fluid, to make sure your baby keeps growing well. The plan depends on how things track.', 'आपके डॉक्टर आगे बढ़त वाले स्कैन करा सकते हैं और ख़ून का बहाव व तरल जाँच सकते हैं, ताकि पक्का हो कि शिशु अच्छे से बढ़ता रहे। योजना इस पर निर्भर करती है कि चीज़ें कैसे चलती हैं।'),
    questions: [
      _t('Is my baby growing along their own curve?', 'क्या मेरा शिशु अपनी ही curve पर बढ़ रहा है?'),
      _t('How often will growth be re-checked?', 'बढ़त दोबारा कितनी बार जाँची जाएगी?'),
      _t('Are the blood flow and fluid normal?', 'क्या ख़ून का बहाव और तरल सामान्य हैं?'),
    ],
    remember: [
      _t('Babies come in many healthy sizes.', 'शिशु कई सेहतमंद आकारों में आते हैं।'),
      _t('The growth trend matters more than one measurement.', 'एक अकेली नाप से ज़्यादा मायने बढ़त का रुझान रखता है।'),
      _t('Follow-up scans keep it monitored.', 'आगे के स्कैन से इस पर नज़र बनी रहती है।'),
    ],
    aliases: ['small baby', 'sga', 'iugr', 'fgr', 'growth restriction', 'baby small', 'छोटा शिशु', 'बढ़त में रुकावट', 'शिशु छोटा'],
  ),
  ReportFinding(
    id: 'large_baby',
    tests: ['growth_scan'],
    name: _t('Large Baby For Gestational Age', 'उम्र के हिसाब से बड़ा शिशु'),
    altName: _same('LGA'),
    weekFrom: 28,
    weekTo: 40,
    whatItMeans: _t('This means your baby is measuring a little larger than average for this stage. Scan size estimates are approximate, and a bigger baby is often simply a healthy, well-grown baby.', 'इसका मतलब है कि आपका शिशु इस चरण के औसत से थोड़ा बड़ा नाप रहा है। स्कैन में आकार का अंदाज़ा लगभग होता है, और बड़ा शिशु अक्सर बस एक सेहतमंद, अच्छी तरह बढ़ा हुआ शिशु होता है।'),
    howCommon: _t('It is a common scan observation, and estimates can vary. Many large-for-dates babies are born without any trouble.', 'यह स्कैन में आम बात है, और अंदाज़े बदल सकते हैं। बहुत से बड़े नाप वाले शिशु बिना किसी परेशानी के जन्म लेते हैं।'),
    whatNext: _t('Your doctor may keep an eye on growth and, closer to term, discuss the best plan for a comfortable, safe delivery.', 'आपके डॉक्टर बढ़त पर नज़र रख सकते हैं और पूरे समय के क़रीब आरामदेह, सुरक्षित डिलीवरी की सबसे अच्छी योजना पर बात करेंगे।'),
    questions: [
      _t('How accurate is the size estimate?', 'आकार का अंदाज़ा कितना सही होता है?'),
      _t('Does this change my delivery plan?', 'क्या इससे मेरी डिलीवरी की योजना बदलती है?'),
      _t('Should my blood sugar be checked?', 'क्या मेरी blood sugar जाँची जानी चाहिए?'),
    ],
    remember: [
      _t('Scan size estimates are only approximate.', 'स्कैन में आकार का अंदाज़ा सिर्फ़ लगभग होता है।'),
      _t('A larger baby is often simply well-grown.', 'बड़ा शिशु अक्सर बस अच्छी तरह बढ़ा हुआ शिशु होता है।'),
      _t('Your team will plan a safe delivery with you.', 'आपकी टीम आपके साथ मिलकर सुरक्षित डिलीवरी की योजना बनाएगी।'),
    ],
    aliases: ['large baby', 'lga', 'big baby', 'macrosomia', 'baby big', 'बड़ा शिशु', 'ज़्यादा वज़न वाला शिशु', 'शिशु बड़ा'],
  ),
  ReportFinding(
    id: 'subchorionic_hematoma',
    tests: ['dating_scan', 'anomaly_scan'],
    name: _same('Subchorionic Hematoma'),
    weekFrom: 6,
    weekTo: 20,
    whatItMeans: _t('This means a small collection of blood has formed between the pregnancy sac and the wall of the uterus. Many of these are small and resolve on their own.', 'इसका मतलब है कि गर्भ की थैली और बच्चेदानी की दीवार के बीच थोड़ा ख़ून जमा हो गया है। इनमें से कई छोटे होते हैं और अपने आप ठीक हो जाते हैं।'),
    howCommon: _t('It is a fairly common early-pregnancy scan finding. Most clear up by themselves as the pregnancy continues.', 'शुरुआती गर्भावस्था के स्कैन में यह काफ़ी आम बात है। ज़्यादातर गर्भावस्था आगे बढ़ने के साथ अपने आप ठीक हो जाते हैं।'),
    whatNext: _t('Your doctor may recommend a follow-up scan and, sometimes, a little extra rest. They will let you know what to watch for, such as spotting.', 'आपके डॉक्टर आगे एक स्कैन और कभी-कभी थोड़ा ज़्यादा आराम सुझा सकते हैं। वे बताएँगे कि किन बातों पर ध्यान रखना है, जैसे spotting।'),
    questions: [
      _t('What size is it, and is it changing?', 'यह कितना बड़ा है, और क्या बदल रहा है?'),
      _t('Should I rest or avoid anything?', 'क्या मुझे आराम करना चाहिए या कुछ छोड़ना चाहिए?'),
      _t('What should I watch for?', 'मुझे किन बातों का ध्यान रखना है?'),
    ],
    remember: [
      _t('Many subchorionic hematomas are small.', 'बहुत से subchorionic hematoma छोटे होते हैं।'),
      _t('Most resolve on their own.', 'ज़्यादातर अपने आप ठीक हो जाते हैं।'),
      _t('A follow-up scan keeps it monitored.', 'आगे एक स्कैन से इस पर नज़र बनी रहती है।'),
    ],
    aliases: ['subchorionic hematoma', 'haematoma', 'bleed near sac', 'sch', 'clot', 'बच्चेदानी की दीवार के पास ख़ून जमना', 'थैली के पास ख़ून जमना'],
  ),
  ReportFinding(
    id: 'vanishing_twin',
    tests: ['dating_scan'],
    name: _t('Vanishing Twin', 'जुड़वाँ में से एक का न बढ़ना'),
    weekFrom: 6,
    weekTo: 12,
    whatItMeans: _t('This means an early scan had shown two pregnancy sacs, and now only one is developing. It happens very early, and the continuing pregnancy usually carries on normally.', 'इसका मतलब है कि शुरुआती स्कैन में दो गर्भ थैलियाँ दिखी थीं, और अब सिर्फ़ एक बढ़ रही है। यह बहुत शुरू में होता है, और चलती हुई गर्भावस्था आम तौर पर सामान्य रूप से आगे बढ़ती है।'),
    howCommon: _t('This is a recognised early-pregnancy event, noticed more often now that scans are done so early.', 'यह शुरुआती गर्भावस्था की एक जानी-पहचानी बात है, जो अब इसलिए ज़्यादा दिखती है क्योंकि स्कैन इतनी जल्दी होने लगे हैं।'),
    whatNext: _t('Your doctor will continue caring for your ongoing pregnancy as usual. It is natural to have mixed feelings - please be gentle with yourself.', 'आपके डॉक्टर आपकी चल रही गर्भावस्था की देखभाल सामान्य रूप से जारी रखेंगे। मन में मिले-जुले भाव आना स्वाभाविक है — कृपया अपने आप पर नरमी रखिए।'),
    questions: [
      _t('Does this affect my continuing baby?', 'क्या इसका असर मेरे चल रहे शिशु पर पड़ता है?'),
      _t('Is any extra monitoring needed?', 'क्या कोई अतिरिक्त निगरानी चाहिए?'),
      _t('Is there support available if I am feeling low?', 'अगर मन उदास लगे तो क्या कोई सहारा मिल सकता है?'),
    ],
    remember: [
      _t('The continuing pregnancy usually progresses normally.', 'चलती हुई गर्भावस्था आम तौर पर सामान्य रूप से आगे बढ़ती है।'),
      _t('This happens very early on.', 'यह बहुत शुरुआती दौर में होता है।'),
      _t('It is okay to have mixed emotions.', 'मन में मिले-जुले भाव आना बिलकुल ठीक है।'),
    ],
    aliases: ['vanishing twin', 'lost twin', 'twin', 'one sac', 'जुड़वाँ में से एक का न बढ़ना', 'जुड़वाँ में से एक का रुक जाना', 'एक ही थैली'],
  ),
  ReportFinding(
    id: 'marginal_cord',
    tests: ['anomaly_scan', 'growth_scan'],
    name: _t('Marginal Cord Insertion', 'किनारे पर जुड़ी गर्भनाल'),
    weekFrom: 18,
    weekTo: 28,
    whatItMeans: _t('This means the umbilical cord joins the placenta near its edge rather than the centre. In most pregnancies this works perfectly well and the baby grows normally.', 'इसका मतलब है कि गर्भनाल placenta के बीच के बजाय उसके किनारे के पास जुड़ी है। ज़्यादातर गर्भावस्थाओं में यह बिलकुल ठीक चलता है और शिशु सामान्य रूप से बढ़ता है।'),
    howCommon: _t('It is a not-uncommon scan finding. The majority of babies with it grow and arrive without any issue.', 'स्कैन में यह कोई अनोखी बात नहीं। इसके साथ ज़्यादातर शिशु बिना किसी दिक़्क़त के बढ़ते और आते हैं।'),
    whatNext: _t('Your doctor may add a growth scan or two to keep an eye on your baby\'s growth, simply to be thorough.', 'आपके डॉक्टर बस पूरी तसल्ली के लिए एक-दो बढ़त वाले स्कैन जोड़ सकते हैं, ताकि शिशु की बढ़त पर नज़र रहे।'),
    questions: [
      _t('Does this affect my baby\'s growth?', 'क्या इससे मेरे शिशु की बढ़त पर असर पड़ता है?'),
      _t('Will I have extra growth scans?', 'क्या मेरे अतिरिक्त बढ़त वाले स्कैन होंगे?'),
      _t('Does it change my delivery plan?', 'क्या इससे मेरी डिलीवरी की योजना बदलती है?'),
    ],
    remember: [
      _t('In most pregnancies this works perfectly well.', 'ज़्यादातर गर्भावस्थाओं में यह बिलकुल ठीक चलता है।'),
      _t('Babies with it usually grow normally.', 'इसके साथ शिशु आम तौर पर सामान्य रूप से बढ़ते हैं।'),
      _t('A growth scan or two keeps it monitored.', 'एक-दो बढ़त वाले स्कैन से इस पर नज़र बनी रहती है।'),
    ],
    aliases: ['marginal cord insertion', 'cord insertion', 'cord', 'marginal cord', 'किनारे पर जुड़ी गर्भनाल', 'गर्भनाल का जुड़ाव', 'किनारे वाली गर्भनाल'],
  ),
  ReportFinding(
    id: 'single_umbilical_artery',
    tests: ['anomaly_scan'],
    name: _t('Single Umbilical Artery', 'गर्भनाल में एक ही धमनी'),
    altName: _same('Two-Vessel Cord'),
    weekFrom: 18,
    weekTo: 22,
    whatItMeans: _t('This means the umbilical cord has one artery instead of the usual two (alongside the vein). On its own, this is often harmless and the baby develops normally.', 'इसका मतलब है कि गर्भनाल में सामान्य दो के बजाय एक धमनी है (नस के साथ)। अकेले में यह अक्सर हानिरहित होता है और शिशु सामान्य रूप से विकसित होता है।'),
    howCommon: _t('It is a recognised scan finding. In many cases it is an isolated finding with no other concerns.', 'यह स्कैन में मिलने वाली एक जानी-पहचानी बात है। कई बार यह अकेली बात होती है और कोई और चिंता नहीं होती।'),
    whatNext: _t('Your doctor may take a closer look at your baby\'s growth and anatomy with a scan, to confirm everything else is developing as expected.', 'आपके डॉक्टर स्कैन में शिशु की बढ़त और बनावट को थोड़ा ग़ौर से देख सकते हैं, ताकि पक्का हो कि बाक़ी सब उम्मीद के मुताबिक़ बन रहा है।'),
    questions: [
      _t('Is this an isolated finding?', 'क्या यह अकेली बात है?'),
      _t('Will my baby\'s growth be monitored?', 'क्या मेरे शिशु की बढ़त पर नज़र रखी जाएगी?'),
      _t('Is any other check recommended?', 'क्या कोई और जाँच सुझाई जाती है?'),
    ],
    remember: [
      _t('On its own, this is often harmless.', 'अकेले में यह अक्सर हानिरहित होता है।'),
      _t('Many babies with it develop normally.', 'इसके साथ बहुत से शिशु सामान्य रूप से विकसित होते हैं।'),
      _t('A detailed scan confirms the rest is on track.', 'एक विस्तृत स्कैन पुष्टि कर देता है कि बाक़ी सब ठीक है।'),
    ],
    aliases: ['single umbilical artery', 'sua', 'two vessel cord', 'cord', 'one artery', 'गर्भनाल में एक ही धमनी', 'दो नली वाली गर्भनाल', 'एक ही धमनी'],
  ),
  ReportFinding(
    id: 'ventriculomegaly',
    tests: ['anomaly_scan'],
    name: _t('Mild Ventriculomegaly', 'हल्का Ventriculomegaly'),
    weekFrom: 18,
    weekTo: 24,
    whatItMeans: _t('This means the fluid-filled spaces in the baby\'s brain are measuring slightly wider than average. When it is mild and isolated, the outlook is usually reassuring.', 'इसका मतलब है कि शिशु के दिमाग़ की तरल भरी जगहें औसत से थोड़ी चौड़ी नाप रही हैं। जब यह हल्का और अकेला हो, तो आगे की उम्मीद आम तौर पर तसल्ली देने वाली होती है।'),
    howCommon: _t('It is a finding the anomaly scan can pick up. Mild, isolated cases often stay stable or settle on their own.', 'यह वह बात है जो anomaly scan पकड़ सकता है। हल्के, अकेले मामले अक्सर वैसे ही रहते हैं या अपने आप ठीक हो जाते हैं।'),
    whatNext: _t('Your doctor may recommend a follow-up scan to track the measurement, and sometimes a few additional tests, to build a fuller picture.', 'आपके डॉक्टर माप पर नज़र रखने के लिए एक और स्कैन, और कभी-कभी कुछ अतिरिक्त टेस्ट सुझा सकते हैं, ताकि पूरी तस्वीर साफ़ हो।'),
    questions: [
      _t('Is it mild and isolated?', 'क्या यह हल्का और अकेला है?'),
      _t('Will it be re-measured?', 'क्या इसे दोबारा नापा जाएगा?'),
      _t('Are any other tests suggested?', 'क्या कोई और टेस्ट सुझाया जाता है?'),
    ],
    remember: [
      _t('Mild, isolated cases are usually reassuring.', 'हल्के, अकेले मामले आम तौर पर तसल्ली देने वाले होते हैं।'),
      _t('Follow-up scans track the measurement.', 'आगे के स्कैन से माप पर नज़र रहती है।'),
      _t('Your team will explain each step.', 'आपकी टीम हर क़दम समझा देगी।'),
    ],
    aliases: ['ventriculomegaly', 'brain ventricles', 'fluid in brain', 'mild ventriculomegaly', 'दिमाग़ के ventricles', 'दिमाग़ में तरल', 'हल्का ventriculomegaly'],
  ),
  ReportFinding(
    id: 'eif',
    tests: ['anomaly_scan', 'nt_scan'],
    name: _t('Echogenic Intracardiac Focus', 'दिल में चमकीला बिंदु'),
    altName: _same('EIF'),
    weekFrom: 18,
    weekTo: 22,
    whatItMeans: _t('This means a tiny bright spot was seen in the baby\'s heart on the scan. It is a normal variation, does not affect how the heart works, and usually fades over time.', 'इसका मतलब है कि स्कैन में शिशु के दिल में एक नन्हा चमकीला बिंदु दिखा। यह एक सामान्य भिन्नता है, दिल के काम पर असर नहीं डालती, और आम तौर पर समय के साथ मिट जाती है।'),
    howCommon: _t('It is a common scan finding, especially on the anomaly scan, and is considered a "soft marker" rather than a problem.', 'यह स्कैन में आम बात है, ख़ासकर anomaly scan में, और इसे समस्या नहीं बल्कि एक "soft marker" माना जाता है।'),
    whatNext: _t('Usually nothing needs to be done. Your doctor will consider it alongside the rest of your scan, which is typically reassuring.', 'आम तौर पर कुछ करने की ज़रूरत नहीं। आपके डॉक्टर इसे आपके पूरे स्कैन के साथ मिलाकर देखेंगे, जो आम तौर पर तसल्ली देने वाला होता है।'),
    questions: [
      _t('Does this affect my baby\'s heart?', 'क्या इसका असर मेरे शिशु के दिल पर पड़ता है?'),
      _t('Is the rest of the scan normal?', 'क्या बाक़ी स्कैन सामान्य है?'),
      _t('Is any follow-up needed?', 'क्या आगे कोई जाँच चाहिए?'),
    ],
    remember: [
      _t('It is a normal variation, not a heart problem.', 'यह एक सामान्य भिन्नता है, दिल की कोई दिक़्क़त नहीं।'),
      _t('It does not affect how the heart works.', 'इससे दिल के काम पर असर नहीं पड़ता।'),
      _t('It usually fades over time.', 'यह आम तौर पर समय के साथ मिट जाता है।'),
    ],
    aliases: ['echogenic intracardiac focus', 'eif', 'bright spot heart', 'soft marker', 'heart spot', 'दिल में चमकीला बिंदु', 'दिल में चमकीला धब्बा', 'स्कैन का soft marker', 'दिल में धब्बा'],
  ),
  ReportFinding(
    id: 'soft_markers',
    tests: ['anomaly_scan', 'nt_scan', 'nipt'],
    name: _t('Soft Markers On Scan', 'स्कैन में Soft Markers'),
    weekFrom: 18,
    weekTo: 22,
    whatItMeans: _t('This means the scan noted one or more "soft markers" - small, subtle features that are usually harmless variations. They are not abnormalities in themselves.', 'इसका मतलब है कि स्कैन में एक या ज़्यादा "soft marker" दिखे — छोटी, हल्की बातें जो आम तौर पर हानिरहित भिन्नताएँ होती हैं। ये अपने आप में कोई गड़बड़ी नहीं हैं।'),
    howCommon: _t('Soft markers are seen on many routine anomaly scans. On their own, most are of no concern.', 'बहुत से सामान्य anomaly scan में soft markers दिखते हैं। अकेले में ज़्यादातर चिंता की बात नहीं होते।'),
    whatNext: _t('Your doctor will look at any marker in the context of your whole scan and earlier tests, and explain whether anything further is helpful - often it is not.', 'आपके डॉक्टर किसी भी marker को आपके पूरे स्कैन और पहले के टेस्ट के संदर्भ में देखेंगे, और बताएँगे कि आगे कुछ करना उपयोगी है या नहीं — अक्सर नहीं होता।'),
    questions: [
      _t('Which soft marker was seen?', 'कौन सा soft marker दिखा?'),
      _t('Are the rest of my scan and screening normal?', 'क्या मेरा बाक़ी स्कैन और screening सामान्य है?'),
      _t('Is any further test recommended?', 'क्या कोई और टेस्ट सुझाया जाता है?'),
    ],
    remember: [
      _t('Soft markers are common, usually harmless variations.', 'Soft markers आम हैं, आम तौर पर हानिरहित भिन्नताएँ।'),
      _t('They are not abnormalities by themselves.', 'ये अपने आप में कोई गड़बड़ी नहीं हैं।'),
      _t('Context from your whole scan matters most.', 'सबसे ज़्यादा मायने आपके पूरे स्कैन का संदर्भ रखता है।'),
    ],
    aliases: ['soft markers', 'soft marker', 'scan markers', 'marker', 'स्कैन में soft markers', 'स्कैन का soft marker', 'स्कैन के marker'],
  ),
  ReportFinding(
    id: 'fibroids',
    tests: ['dating_scan', 'anomaly_scan'],
    name: _t('Fibroids During Pregnancy', 'गर्भावस्था में Fibroids'),
    weekFrom: 8,
    weekTo: 20,
    whatItMeans: _t('This means there are one or more fibroids - non-cancerous growths of muscle in the wall of the uterus. Many women have them, and most pregnancies with fibroids progress smoothly.', 'इसका मतलब है कि बच्चेदानी की दीवार में एक या ज़्यादा fibroid हैं — मांसपेशी की ग़ैर-कैंसर वाली गाँठें। बहुत सी महिलाओं में ये होते हैं, और fibroid वाली ज़्यादातर गर्भावस्थाएँ आराम से आगे बढ़ती हैं।'),
    howCommon: _t('Fibroids are common, and are often noticed for the first time on a pregnancy scan. The majority cause no trouble during pregnancy.', 'Fibroids आम हैं, और अक्सर पहली बार गर्भावस्था के स्कैन में ही दिखते हैं। ज़्यादातर गर्भावस्था के दौरान कोई परेशानी नहीं करते।'),
    whatNext: _t('Your doctor will note their size and position and keep an eye on them. Occasionally they cause some discomfort, which can be managed; your team will guide any care needed.', 'आपके डॉक्टर इनका आकार और जगह दर्ज करेंगे और नज़र रखेंगे। कभी-कभी इनसे थोड़ी तकलीफ़ होती है, जिसे सँभाला जा सकता है; ज़रूरत पड़ने पर आपकी टीम मार्गदर्शन करेगी।'),
    questions: [
      _t('Where are the fibroids, and what size are they?', 'Fibroids कहाँ हैं, और कितने बड़े हैं?'),
      _t('Could they cause any discomfort?', 'क्या इनसे कोई तकलीफ़ हो सकती है?'),
      _t('Will they be monitored during pregnancy?', 'क्या गर्भावस्था के दौरान इन पर नज़र रखी जाएगी?'),
    ],
    remember: [
      _t('Fibroids are non-cancerous and very common.', 'Fibroids ग़ैर-कैंसर वाले और बहुत आम होते हैं।'),
      _t('Most pregnancies with fibroids go smoothly.', 'Fibroid वाली ज़्यादातर गर्भावस्थाएँ आराम से चलती हैं।'),
      _t('Your team will monitor them if needed.', 'ज़रूरत हुई तो आपकी टीम इन पर नज़र रखेगी।'),
    ],
    aliases: ['fibroid', 'fibroids', 'myoma', 'uterus growth', 'बच्चेदानी में गाँठ'],
  ),
  ReportFinding(
    id: 'group_b_strep',
    tests: ['gbs'],
    name: _same('Group B Strep'),
    altName: _same('GBS'),
    weekFrom: 35,
    weekTo: 37,
    whatItMeans: _t('This means a common bacteria called Group B Strep was found, which many healthy people carry naturally. It simply tells your doctor to take a simple precaution around delivery.', 'इसका मतलब है कि Group B Strep नाम का एक आम bacteria मिला है, जो बहुत से सेहतमंद लोग स्वाभाविक रूप से साथ रखते हैं। यह बस आपके डॉक्टर को बताता है कि डिलीवरी के आस-पास एक आसान एहतियात बरतनी है।'),
    howCommon: _t('Carrying GBS is common and usually causes no symptoms. Many mothers are screened for it late in pregnancy.', 'GBS साथ रखना आम है और आम तौर पर इसके कोई लक्षण नहीं होते। बहुत सी माँओं की गर्भावस्था के आख़िरी दौर में इसकी जाँच होती है।'),
    whatNext: _t('Your doctor will typically plan antibiotics during labour as a precaution, which greatly reduces any risk to the baby. Usually nothing is needed before then.', 'आपके डॉक्टर आम तौर पर एहतियात के तौर पर प्रसव के दौरान antibiotics की योजना बनाएँगे, जिससे शिशु को कोई भी ख़तरा बहुत कम हो जाता है। उससे पहले आम तौर पर कुछ नहीं चाहिए।'),
    questions: [
      _t('Will I need antibiotics during labour?', 'क्या प्रसव के दौरान मुझे antibiotics लगेंगे?'),
      _t('Is there anything to do before then?', 'उससे पहले कुछ करना है?'),
      _t('Will this change my birth plan?', 'क्या इससे मेरी जन्म की योजना बदलेगी?'),
    ],
    remember: [
      _t('GBS is a common, naturally carried bacteria.', 'GBS एक आम bacteria है जो शरीर में स्वाभाविक रूप से रहता है।'),
      _t('A simple precaution at delivery handles it.', 'डिलीवरी के समय एक आसान एहतियात से यह सँभल जाता है।'),
      _t('It usually causes no symptoms for you.', 'आम तौर पर आपको इसके कोई लक्षण नहीं होते।'),
    ],
    aliases: ['group b strep', 'gbs', 'strep', 'streptococcus', 'Group B Strep का bacteria'],
  ),
  ReportFinding(
    id: 'rh_negative',
    tests: ['blood_tests'],
    name: _t('Rh-Negative Pregnancy', 'Rh-Negative गर्भावस्था'),
    altName: _t('Rh Negative Blood', 'Rh Negative ख़ून'),
    weekFrom: 28,
    whatItMeans: _t('This means your blood type is Rh-negative. It is completely normal - it just means your doctor takes a simple, routine step to protect your future pregnancies.', 'इसका मतलब है कि आपका ब्लड ग्रुप Rh-negative है। यह पूरी तरह सामान्य है — बस इतना कि आपके डॉक्टर आपकी आगे की गर्भावस्थाओं की रक्षा के लिए एक आसान, नियमित क़दम उठाते हैं।'),
    howCommon: _t('Being Rh-negative is common and well understood. The care for it is straightforward and routine.', 'Rh-negative होना आम है और अच्छी तरह समझा गया है। इसकी देखभाल सीधी और रोज़ की बात है।'),
    whatNext: _t('Your doctor will usually offer an injection (anti-D) at certain points, and after birth if needed. This is a standard, preventive measure.', 'आपके डॉक्टर आम तौर पर कुछ ख़ास मौक़ों पर, और ज़रूरत हो तो जन्म के बाद, एक इंजेक्शन (anti-D) देंगे। यह एक मानक, बचाव वाला क़दम है।'),
    questions: [
      _t('Will I need an anti-D injection, and when?', 'क्या मुझे anti-D इंजेक्शन लगेगा, और कब?'),
      _t('Does my partner\'s blood type matter here?', 'क्या यहाँ मेरे साथी का ब्लड ग्रुप मायने रखता है?'),
      _t('Is there anything else to plan?', 'क्या और कुछ योजना बनानी है?'),
    ],
    remember: [
      _t('Being Rh-negative is completely normal.', 'Rh-negative होना बिलकुल सामान्य है।'),
      _t('The care for it is simple and routine.', 'इसकी देखभाल आसान और रोज़ की बात है।'),
      _t('A preventive injection is the usual step.', 'एक बचाव वाला इंजेक्शन ही आम क़दम है।'),
    ],
    aliases: ['rh negative', 'rh-negative', 'negative blood', 'anti d', 'rhesus', 'blood group', 'Rh negative ख़ून', 'Rh-negative गर्भावस्था', 'negative ब्लड ग्रुप', 'anti-D इंजेक्शन', 'ब्लड ग्रुप'],
  ),
];

// ---------------------------------------------------------------------------
//  Lookup helpers
// ---------------------------------------------------------------------------

ReportFinding? reportById(String id) {
  for (final f in kReportFindings) {
    if (f.id == id) return f;
  }
  return null;
}

/// Prefix-first search across name + alt name + aliases.
List<ReportFinding> reportSearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final prefix = <ReportFinding>[];
  final contains = <ReportFinding>[];
  for (final f in kReportFindings) {
    final terms = <String>[
      f.name.en.toLowerCase(),
      if (f.altName != null) f.altName!.en.toLowerCase(),
      ...f.aliases.map((a) => a.toLowerCase()),
    ];
    if (terms.any((t) => t.startsWith(q))) {
      prefix.add(f);
    } else if (terms.any((t) => t.contains(q))) {
      contains.add(f);
    }
  }
  int byName(ReportFinding a, ReportFinding b) =>
      a.name.en.toLowerCase().compareTo(b.name.en.toLowerCase());
  prefix.sort(byName);
  contains.sort(byName);
  return [...prefix, ...contains];
}
