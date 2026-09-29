// =============================================================================
//  Scan guides - "What is this scan" + "How to interpret the report"
// -----------------------------------------------------------------------------
//  Keyed by the medical milestone id (see journey_milestones.dart). Each guide
//  adds, to a scan's detail page: a plain-language "what is this scan" intro, and
//  a "how to interpret the report" glossary (the terms a mother sees on her
//  report and what they mean - the WHOLE picture, not half-knowledge).
//
//  EDUCATIONAL ONLY. This is general information to help a mother understand her
//  own report; it is NOT a diagnosis and never replaces her doctor. The detail
//  screen shows a clear "not for medical diagnosis" disclaimer with it.
// =============================================================================

import '../localization/app_language.dart';

/// One "term → what it means" row in the interpret-your-report glossary.
class ScanInterpretRow {
  const ScanInterpretRow(this.term, this.meaning);
  final LocalizedText term;
  final LocalizedText meaning;
}

class ScanGuide {
  const ScanGuide({required this.whatIs, required this.interpret});

  /// A clear "what is a [X] scan" explainer, shown at the top of the detail page.
  final LocalizedText whatIs;

  /// The report glossary, shown in the full-screen "how to interpret" pop-up.
  final List<ScanInterpretRow> interpret;
}

const Map<String, ScanGuide> kScanGuides = {
  // ---------------------------------------------------------------------------
  'm_ultrasound': ScanGuide(
    whatIs: LocalizedText(
      en: "Your first ultrasound (a 'dating' or 'viability' scan) is usually "
          "done between about 6 and 9 weeks. A small probe shows your baby "
          "in the womb. It checks the pregnancy is in the right place, looks "
          "for a heartbeat, sees how many babies there are, and measures "
          "your baby to work out an accurate due date.",
      hi: "आपका पहला अल्ट्रासाउंड ('dating' या 'viability' scan) आम तौर पर लगभग 6 से 9 हफ़्ते के बीच होता है। एक छोटा probe आपके शिशु को गर्भ में दिखाता है — यह पुष्टि करता है कि गर्भावस्था सही जगह है, धड़कन देखता है, कितने शिशु हैं यह देखता है, और सही डिलीवरी तारीख़ के लिए शिशु को नापता है।",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'Gestational sac', hi: 'Gestational sac'),
        LocalizedText(
            en: 'The fluid-filled space your baby grows in. Seeing it in the '
                'womb confirms the pregnancy is in the right place.',
            hi: 'वह तरल से भरी जगह जिसमें शिशु बढ़ता है। इसे गर्भ में देखना पुष्टि करता है कि गर्भावस्था सही जगह है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'CRL (Crown–Rump Length)', hi: 'CRL (Crown–Rump Length)'),
        LocalizedText(
            en: "Your baby's length from head to bottom. It's the most "
                "accurate way to date a pregnancy this early.",
            hi: 'आपके शिशु की सिर से नीचे तक की लंबाई। इतनी जल्दी गर्भावस्था की तारीख़ निकालने का यह सबसे सही तरीक़ा है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'FHR / cardiac activity', hi: 'FHR / धड़कन'),
        LocalizedText(
            en: "Your baby's heartbeat. A heartbeat (often seen from around "
                "6 weeks) is reassuring. Before then it can just be too "
                "early to see.",
            hi: 'आपके शिशु की धड़कन। धड़कन (अक्सर लगभग 6 हफ़्ते से) भरोसा देती है; उससे पहले यह दिखने में बस जल्दी हो सकती है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Yolk sac', hi: 'Yolk sac'),
        LocalizedText(
            en: 'A tiny early structure that feeds your baby at the very '
                'start. Seeing it is a normal early sign.',
            hi: 'एक नन्ही शुरुआती रचना जो शुरू में शिशु को पोषण देती है। इसे देखना एक सामान्य शुरुआती संकेत है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Single / twins', hi: 'एक / जुड़वाँ'),
        LocalizedText(
            en: 'How many babies are growing.',
            hi: 'कितने शिशु बढ़ रहे हैं।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'EDD (Estimated Due Date)', hi: 'EDD (Estimated Due Date)'),
        LocalizedText(
            en: 'The date your baby is expected, worked out from the '
                'measurements. It may be moved a little from your period '
                'dates.',
            hi: 'आपकी अनुमानित डिलीवरी तारीख़, नाप से निकाली गई। यह आपकी पीरियड की तारीख़ों से थोड़ी अलग हो सकती है।'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_nt': ScanGuide(
    whatIs: LocalizedText(
      en: "The NT (nuchal translucency) scan is done between 11 and 14 "
          "weeks. It measures a small pocket of fluid at the back of your "
          "baby's neck. With a blood test (the 'combined' or 'double marker' "
          "test) and your age, it gives a chance for conditions like Down's "
          "syndrome. A newer blood test, NIPT, may also be offered. These "
          "are screening tests. They give a likelihood, not a diagnosis.",
      hi: "NT (nuchal translucency) scan 11 से 14 हफ़्ते के बीच होता है। यह शिशु की गर्दन के पीछे के तरल को नापता है। एक blood test ('combined' या 'double marker' test) और आपकी उम्र के साथ, यह Down's syndrome जैसी स्थितियों की संभावना बताता है। एक नया blood test, NIPT, भी दिया जा सकता है। ये SCREENING टेस्ट हैं — ये संभावना बताते हैं, निदान नहीं।",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'NT measurement (mm)', hi: 'NT measurement (mm)'),
        LocalizedText(
            en: "The fluid at the back of the neck. Most babies measure "
                "under about 3.5 mm. A higher value raises the calculated "
                "chance, but it doesn't confirm anything.",
            hi: 'गर्दन के पीछे का तरल। ज़्यादातर शिशु लगभग 3.5 mm से कम होते हैं। ज़्यादा मान संभावना बढ़ाता है पर कुछ पक्का नहीं करता।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Nasal bone', hi: 'Nasal bone'),
        LocalizedText(
            en: "Present or absent. If it isn't seen, the calculated chance "
                "can go up a little. On its own it isn't a diagnosis.",
            hi: 'मौजूद या ग़ैर-मौजूद। Nasal bone न होना संभावना थोड़ी बढ़ा सकता है — अकेले में यह निदान नहीं है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Free β-hCG / PAPP-A', hi: 'Free β-hCG / PAPP-A'),
        LocalizedText(
            en: 'The blood markers, usually reported as "MoM" (multiples of '
                'the median). They go into the overall screening result.',
            hi: 'Blood markers, अक्सर "MoM" में बताए जाते हैं। ये आपकी कुल संभावना में जाते हैं।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Risk / chance (e.g. 1 in 1500)', hi: 'जोखिम / संभावना (जैसे 1 in 1500)'),
        LocalizedText(
            en: 'Your screening result. A "low chance" (a big number like 1 '
                'in 1500) is reassuring. A "higher chance" may lead to an '
                'offer of NIPT or a diagnostic test.',
            hi: 'आपका screening नतीजा। "Low chance" (1 in 1500 जैसा बड़ा नंबर) भरोसा देता है; "higher chance" पर NIPT या diagnostic test दिया जा सकता है।'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_anomaly': ScanGuide(
    whatIs: LocalizedText(
      en: "The anomaly scan (also called the 20-week or mid-pregnancy scan) "
          "is a detailed ultrasound between 18 and 22 weeks. The sonographer "
          "looks closely at your baby's brain, face, spine, heart, chest, "
          "tummy, kidneys and limbs, and checks the placenta, the fluid and "
          "how your baby is growing.",
      hi: "Anomaly scan (जिसे 20-week या mid-pregnancy scan भी कहते हैं) 18 से 22 हफ़्ते के बीच एक विस्तृत अल्ट्रासाउंड है। Sonographer शिशु के दिमाग़, चेहरे, रीढ़, दिल, सीने, पेट, kidney और हाथ-पैर को ग़ौर से देखते हैं, और placenta, तरल और शिशु की बढ़त जाँचते हैं।",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: '"Appears normal" / NAD', hi: '"Appears normal" / NAD'),
        LocalizedText(
            en: 'That part looked as expected on the scan. "NAD" means No '
                'Abnormality Detected.',
            hi: 'वह हिस्सा स्कैन पर उम्मीद के मुताबिक़ दिखा। "NAD" यानी कोई गड़बड़ी नहीं मिली।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Placenta (position)', hi: 'Placenta (स्थिति)'),
        LocalizedText(
            en: "Where the placenta is attached (for example anterior, at "
                "the front, or posterior, at the back). Both are normal. If "
                "it's low near the cervix now, a later scan usually shows it "
                "has moved up.",
            hi: 'Placenta कहाँ है (जैसे anterior/posterior)। अगर अभी यह cervix के पास नीचे है, तो बाद के स्कैन में अक्सर यह ऊपर चला जाता है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Amniotic fluid (AFI / liquor)', hi: 'Amniotic fluid (AFI / liquor)'),
        LocalizedText(
            en: 'The fluid around your baby, reported as normal, increased '
                'or reduced.',
            hi: 'शिशु के आस-पास का तरल — सामान्य, ज़्यादा या कम बताया जाता है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Biometry (BPD, HC, AC, FL)', hi: 'Biometry (BPD, HC, AC, FL)'),
        LocalizedText(
            en: 'Head, tummy and thigh-bone measurements used to follow '
                'growth and estimate weight.',
            hi: 'सिर, पेट और जाँघ की हड्डी की नाप — बढ़त देखने और वज़न का अंदाज़ा लगाने के लिए।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Soft markers', hi: 'Soft markers'),
        LocalizedText(
            en: 'Small findings that are common and usually mean nothing on '
                'their own. Your doctor will explain any that are noted.',
            hi: 'छोटी बातें जो आम हैं और अकेले में अक्सर चिंता की बात नहीं। डॉक्टर इन्हें समझाएँगे।'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_glucose': ScanGuide(
    whatIs: LocalizedText(
      en: 'The sugar test (often a Glucose Tolerance Test, GTT) is usually '
          'done between 24 and 28 weeks. You drink a measured sugary drink, '
          'and your blood sugar is checked before and a couple of hours '
          'after. It shows how your body handles sugar in pregnancy and '
          'screens for gestational diabetes.',
      hi: "Glucose screening (अक्सर Glucose Tolerance Test, GTT) आम तौर पर 24 से 28 हफ़्ते के बीच होता है। आप एक नापी हुई मीठी ड्रिंक पीती हैं और उसके पहले और कुछ घंटे बाद blood sugar जाँची जाती है। यह देखता है कि गर्भावस्था में शरीर sugar को कैसे सँभालता है और gestational diabetes के लिए स्क्रीन करता है।",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'Fasting glucose', hi: 'Fasting glucose'),
        LocalizedText(
            en: 'Your blood sugar before the drink, after not eating '
                'overnight.',
            hi: 'ड्रिंक से पहले, रात भर बिना खाए, आपकी blood sugar।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: '1-hour / 2-hour value', hi: '1-hour / 2-hour value'),
        LocalizedText(
            en: "Your blood sugar after the glucose drink. Your body should "
                "bring it back down within the lab's range.",
            hi: 'Glucose ड्रिंक के बाद आपकी blood sugar। शरीर को इसे lab range में वापस ले आना चाहिए।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Normal vs raised', hi: 'सामान्य बनाम बढ़ा हुआ'),
        LocalizedText(
            en: "Values within the lab's range are reassuring. Raised values "
                "may mean gestational diabetes, which is very manageable "
                "with food changes, checking your sugar and sometimes "
                "medicine.",
            hi: 'Lab range के अंदर के मान भरोसा देते हैं। ज़्यादा मान gestational diabetes दिखा सकते हैं — खानपान, निगरानी और कभी दवा से आसानी से सँभलता है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'HbA1c', hi: 'HbA1c'),
        LocalizedText(
            en: 'Sometimes checked. It shows your average blood sugar over '
                'the last few weeks.',
            hi: 'कभी जाँचा जाता है — यह पिछले हफ़्तों की औसत blood sugar दिखाता है।'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_growth': ScanGuide(
    whatIs: LocalizedText(
      en: "A growth scan is an ultrasound, usually from around 28 weeks and "
          "only if your doctor advises it. It measures your baby's size, the "
          "fluid around them, and the blood flow in the cord and placenta "
          "(Doppler). It checks your baby is growing well and getting enough "
          "nourishment as your due date gets closer.",
      hi: "Growth scan एक अल्ट्रासाउंड है, आम तौर पर लगभग 28 हफ़्ते से और सिर्फ़ सलाह होने पर, जो शिशु का आकार, आस-पास का तरल, और cord व placenta में blood flow (Doppler) नापता है। यह देखता है कि डिलीवरी की तारीख़ पास आते-आते शिशु अच्छे से बढ़ रहा है और पर्याप्त पोषण पा रहा है।",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'EFW (Estimated Fetal Weight)', hi: 'EFW (Estimated Fetal Weight)'),
        LocalizedText(
            en: "An estimate of your baby's weight from the measurements. "
                "It's an estimate, not an exact weight.",
            hi: 'नाप से शिशु के वज़न का अंदाज़ा। यह एक अंदाज़ा है, पक्का आँकड़ा नहीं।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Centile (e.g. 50th)', hi: 'Centile (जैसे 50th)'),
        LocalizedText(
            en: 'Where your baby sits compared with other babies. Your baby '
                'following their own curve over time matters more than one '
                'number.',
            hi: 'आपका शिशु दूसरों के मुक़ाबले कहाँ है। समय के साथ अपनी ही curve पर चलना एक नंबर से ज़्यादा मायने रखता है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'AFI / liquor', hi: 'AFI / liquor'),
        LocalizedText(
            en: 'The amount of fluid around your baby, reported as normal, '
                'increased or reduced.',
            hi: 'शिशु के आस-पास तरल की मात्रा — सामान्य, ज़्यादा या कम बताई जाती है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Doppler (PI / RI)', hi: 'Doppler (PI / RI)'),
        LocalizedText(
            en: 'Blood-flow checks in the cord and blood vessels. Normal '
                'flow is reassuring about the placenta and nourishment.',
            hi: 'Cord और नाड़ियों में blood-flow की जाँच। सामान्य flow placenta और पोषण के बारे में भरोसा देता है।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Presentation (cephalic / breech)', hi: 'Presentation (cephalic / breech)'),
        LocalizedText(
            en: 'Which way up your baby is lying. Many babies turn head down '
                '(cephalic) by the end.',
            hi: 'शिशु किस तरफ़ है। कई शिशु पूरे समय तक सिर-नीचे (cephalic) हो जाते हैं।'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_gbs': ScanGuide(
    whatIs: LocalizedText(
      en: "Group B Streptococcus (GBS) is a common bacteria many women carry "
          "without harm. A simple swab, usually around 36–37 weeks, checks "
          "whether you're carrying it near your due date. If you are, "
          "antibiotics during labour greatly reduce the small chance of "
          "passing it to your baby. Carrying GBS is common, and it isn't an "
          "infection in you.",
      hi: "Group B Streptococcus (GBS) एक आम bacteria है जो कई महिलाएँ बिना नुक़सान के साथ रखती हैं। एक आसान swab, आम तौर पर लगभग 36–37 हफ़्ते, देखता है कि डिलीवरी की तारीख़ के पास आप इसे साथ रखती हैं या नहीं। अगर हाँ, तो प्रसव के दौरान antibiotics शिशु तक पहुँचने का छोटा ख़तरा बहुत कम कर देते हैं। GBS होना आम है और यह आपमें कोई संक्रमण नहीं है।",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'Positive / carrier', hi: 'Positive / carrier'),
        LocalizedText(
            en: "GBS was found. It's common and isn't an infection in you. "
                "You'd be offered antibiotics in labour as a precaution.",
            hi: 'GBS मिला। यह आम है और आपमें संक्रमण नहीं — बस एहतियात के तौर पर प्रसव में antibiotics दिए जाते हैं।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Negative', hi: 'Negative'),
        LocalizedText(
            en: "GBS wasn't found on this swab.",
            hi: 'इस swab पर GBS नहीं मिला।'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Why it matters', hi: 'यह क्यों मायने रखता है'),
        LocalizedText(
            en: 'It lets your team plan to protect your baby during birth.',
            hi: 'यह बस आपकी टीम को जन्म के समय शिशु को सुरक्षित रखने की योजना बनाने में मदद करता है।'),
      ),
    ],
  ),
};
