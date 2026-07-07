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
      en: "Your first ultrasound (a 'dating' or 'viability' scan) is usually done between about 6 and 9 weeks. A small probe shows your baby in the womb - it confirms the pregnancy is in the right place, looks for a heartbeat, sees how many babies there are, and measures your baby to work out an accurate due date.",
      hi: "Aapka pehla ultrasound ('dating' ya 'viability' scan) aam taur par karib 6 se 9 hafte ke beech hota hai. Ek chhota probe aapke baby ko garbh mein dikhata hai - yeh confirm karta hai ki pregnancy sahi jagah hai, dhadkan dekhta hai, kitne baby hain yeh dekhta hai, aur sahi due date ke liye baby ko naapta hai.",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'Gestational sac', hi: 'Gestational sac'),
        LocalizedText(
            en: 'The fluid-filled space your baby grows in. Seeing it in the womb confirms the pregnancy is in the right place.',
            hi: 'Wo dravya-bhari jagah jisme baby badhta hai. Ise garbh mein dekhna confirm karta hai ki pregnancy sahi jagah hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'CRL (Crown–Rump Length)', hi: 'CRL (Crown–Rump Length)'),
        LocalizedText(
            en: "Your baby's length from head to bottom. It's the most accurate way to date the pregnancy this early.",
            hi: 'Aapke baby ki sir se neeche tak ki lambai. Itni jaldi pregnancy ki date nikaalne ka yeh sabse sahi tareeka hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'FHR / cardiac activity', hi: 'FHR / dhadkan'),
        LocalizedText(
            en: "Your baby's heartbeat. A heartbeat (often from around 6 weeks) is reassuring; before then it can simply be too early to see.",
            hi: 'Aapke baby ki dhadkan. Dhadkan (aksar karib 6 hafte se) aashwasan deti hai; usse pehle yeh dikhne mein bas jaldi ho sakti hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Yolk sac', hi: 'Yolk sac'),
        LocalizedText(
            en: 'A tiny early structure that nourishes your baby at the start. Seeing it is a normal early sign.',
            hi: 'Ek nanhi shuruaati rachna jo shuru mein baby ko poshan deti hai. Ise dekhna ek normal shuruaati sanket hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Single / twins', hi: 'Single / twins'),
        LocalizedText(
            en: 'How many babies are growing.',
            hi: 'Kitne baby badh rahe hain.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'EDD (Estimated Due Date)', hi: 'EDD (Estimated Due Date)'),
        LocalizedText(
            en: 'Your expected delivery date, calculated from the measurements. It can be adjusted slightly from your period dates.',
            hi: 'Aapki anumaanit delivery date, naap se nikaali gayi. Yeh aapki period dates se thodi adjust ho sakti hai.'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_nt': ScanGuide(
    whatIs: LocalizedText(
      en: "The NT (nuchal translucency) scan is done between 11 and 14 weeks. It measures a small pocket of fluid at the back of your baby's neck. With a blood test (the 'combined' or 'double marker' test) and your age, it gives a CHANCE for conditions like Down's syndrome. A newer blood test, NIPT, can also be offered. These are SCREENING tests - they give a likelihood, not a diagnosis.",
      hi: "NT (nuchal translucency) scan 11 se 14 hafte ke beech hota hai. Yeh baby ki gardan ke peechhe ke dravya ko naapta hai. Ek blood test ('combined' ya 'double marker' test) aur aapki umar ke saath, yeh Down's syndrome jaisi cheezon ki SAMBHAVNA batata hai. Ek naya blood test, NIPT, bhi offer ho sakta hai. Ye SCREENING test hain - ye sambhavna batate hain, diagnosis nahi.",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'NT measurement (mm)', hi: 'NT measurement (mm)'),
        LocalizedText(
            en: 'The fluid at the back of the neck. Most babies measure under about 3.5 mm. A higher value raises the calculated chance but does NOT confirm anything.',
            hi: 'Gardan ke peechhe ka dravya. Zyadatar baby karib 3.5 mm se kam hote hain. Zyada value sambhavna badhati hai par kuch confirm NAHI karti.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Nasal bone', hi: 'Nasal bone'),
        LocalizedText(
            en: 'Present or absent. An absent nasal bone can slightly raise the calculated chance - on its own it is not a diagnosis.',
            hi: 'Maujood ya gair-maujood. Nasal bone na hona sambhavna thodi badha sakta hai - akele mein yeh diagnosis nahi hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Free β-hCG / PAPP-A', hi: 'Free β-hCG / PAPP-A'),
        LocalizedText(
            en: 'The blood markers, usually reported as "MoM" (multiples of the median). They feed into your overall chance.',
            hi: 'Blood markers, aksar "MoM" mein bataye jaate hain. Ye aapki kul sambhavna mein jaate hain.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Risk / chance (e.g. 1 in 1500)', hi: 'Risk / chance (e.g. 1 in 1500)'),
        LocalizedText(
            en: 'Your screening result. A "low chance" (a big number like 1 in 1500) is reassuring; a "higher chance" may lead to an offer of NIPT or a diagnostic test.',
            hi: 'Aapka screening result. "Low chance" (1 in 1500 jaisa bada number) aashwasan deta hai; "higher chance" par NIPT ya diagnostic test offer ho sakta hai.'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_anomaly': ScanGuide(
    whatIs: LocalizedText(
      en: "The anomaly scan (also called the 20-week or mid-pregnancy scan) is a detailed ultrasound between 18 and 22 weeks. The sonographer looks closely at your baby's brain, face, spine, heart, chest, tummy, kidneys and limbs, and checks the placenta, the fluid and how your baby is growing.",
      hi: "Anomaly scan (jise 20-week ya mid-pregnancy scan bhi kehte hain) 18 se 22 hafte ke beech ek vistrit ultrasound hai. Sonographer baby ke dimaag, chehre, reedh, dil, seene, pet, kidney aur haath-pair ko gaur se dekhte hain, aur placenta, dravya aur baby ki growth check karte hain.",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: '"Appears normal" / NAD', hi: '"Appears normal" / NAD'),
        LocalizedText(
            en: 'That part looked as expected on the scan. "NAD" means No Abnormality Detected.',
            hi: 'Wo hissa scan par ummeed ke mutabik dikha. "NAD" yaani koi abnormality nahi mili.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Placenta (position)', hi: 'Placenta (position)'),
        LocalizedText(
            en: 'Where the placenta sits (e.g. anterior/posterior). If it is low near the cervix now, a later scan usually shows it has moved up.',
            hi: 'Placenta kahan hai (jaise anterior/posterior). Agar abhi yeh cervix ke paas neeche hai, to baad ke scan mein aksar yeh upar chala jaata hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Amniotic fluid (AFI / liquor)', hi: 'Amniotic fluid (AFI / liquor)'),
        LocalizedText(
            en: 'The fluid around your baby - reported as normal, increased or reduced.',
            hi: 'Baby ke aas-paas ka dravya - normal, zyada ya kam bataya jaata hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Biometry (BPD, HC, AC, FL)', hi: 'Biometry (BPD, HC, AC, FL)'),
        LocalizedText(
            en: 'Head, abdomen and thigh-bone measurements used to track growth and estimate weight.',
            hi: 'Sir, pet aur jaangh-haddi ki naap - growth track karne aur wazan ka andaaza lagaane ke liye.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Soft markers', hi: 'Soft markers'),
        LocalizedText(
            en: 'Minor findings that are common and usually nothing to worry about on their own. Your doctor will explain any that are noted.',
            hi: 'Chhoti baatein jo aam hain aur akele mein aksar chinta ki baat nahi. Doctor inhe samjhaayenge.'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_glucose': ScanGuide(
    whatIs: LocalizedText(
      en: "The glucose screening (often a Glucose Tolerance Test, GTT) is usually done between 24 and 28 weeks. You drink a measured sugary drink and your blood sugar is checked before and a couple of hours after. It checks how your body handles sugar in pregnancy and screens for gestational diabetes.",
      hi: "Glucose screening (aksar Glucose Tolerance Test, GTT) aam taur par 24 se 28 hafte ke beech hota hai. Aap ek naapi hui meethi drink peeti hain aur uske pehle aur kuch ghante baad blood sugar check hoti hai. Yeh dekhta hai ki pregnancy mein sharir sugar ko kaise sambhaalta hai aur gestational diabetes ke liye screen karta hai.",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'Fasting glucose', hi: 'Fasting glucose'),
        LocalizedText(
            en: 'Your blood sugar before the drink, after not eating overnight.',
            hi: 'Drink se pehle, raat bhar bina khaaye, aapki blood sugar.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: '1-hour / 2-hour value', hi: '1-hour / 2-hour value'),
        LocalizedText(
            en: 'Your blood sugar after the glucose drink. The body should bring it back down within the lab range.',
            hi: 'Glucose drink ke baad aapki blood sugar. Sharir ise lab range mein wapas le aana chahiye.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Normal vs raised', hi: 'Normal vs raised'),
        LocalizedText(
            en: 'Values within the lab range are reassuring. Raised values may mean gestational diabetes - very manageable with diet, monitoring and sometimes medication.',
            hi: 'Lab range ke andar values aashwasan deti hain. Zyada values gestational diabetes dikha sakti hain - diet, monitoring aur kabhi dawa se aasaani se sambhalti hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'HbA1c', hi: 'HbA1c'),
        LocalizedText(
            en: 'Sometimes checked - it reflects your average blood sugar over recent weeks.',
            hi: 'Kabhi check hota hai - yeh pichhle hafton ki average blood sugar dikhata hai.'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_growth': ScanGuide(
    whatIs: LocalizedText(
      en: "A growth scan is an ultrasound, usually from around 28 weeks and only if advised, that measures your baby's size, the fluid around them, and the blood flow in the cord and placenta (Doppler). It checks your baby is growing well and getting enough nourishment as the due date nears.",
      hi: "Growth scan ek ultrasound hai, aam taur par karib 28 hafte se aur sirf salah hone par, jo baby ka size, aas-paas ka dravya, aur cord & placenta mein blood flow (Doppler) naapta hai. Yeh dekhta hai ki due date paas aate-aate baby achhe se badh raha hai aur kaafi poshan paa raha hai.",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'EFW (Estimated Fetal Weight)', hi: 'EFW (Estimated Fetal Weight)'),
        LocalizedText(
            en: "An estimate of your baby's weight from the measurements. It's an estimate, not an exact figure.",
            hi: 'Naap se baby ke wazan ka andaaza. Yeh ek andaaza hai, pakka figure nahi.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Centile (e.g. 50th)', hi: 'Centile (e.g. 50th)'),
        LocalizedText(
            en: 'Where your baby sits compared with others. Following their OWN curve over time matters more than a single number.',
            hi: 'Aapka baby doosron ke mukable kahan hai. Samay ke saath APNI curve par chalna ek number se zyada maayne rakhta hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'AFI / liquor', hi: 'AFI / liquor'),
        LocalizedText(
            en: 'The amount of fluid around your baby - reported normal, increased or reduced.',
            hi: 'Baby ke aas-paas dravya ki maatra - normal, zyada ya kam bataai jaati hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Doppler (PI / RI)', hi: 'Doppler (PI / RI)'),
        LocalizedText(
            en: 'Blood-flow checks in the cord and vessels. Normal flow is reassuring about the placenta and nourishment.',
            hi: 'Cord aur naadiyon mein blood-flow ki jaanch. Normal flow placenta aur poshan ke baare mein aashwasan deta hai.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Presentation (cephalic / breech)', hi: 'Presentation (cephalic / breech)'),
        LocalizedText(
            en: 'Which way up your baby is. Many babies turn head-down (cephalic) by term.',
            hi: 'Baby kis taraf hai. Kai baby term tak sar-neeche (cephalic) ho jaate hain.'),
      ),
    ],
  ),
  // ---------------------------------------------------------------------------
  'm_gbs': ScanGuide(
    whatIs: LocalizedText(
      en: "Group B Streptococcus (GBS) is a common bacterium many women carry harmlessly. A simple swab, usually around 36–37 weeks, checks whether you're carrying it near your due date. If you are, antibiotics during labour greatly reduce the small chance of passing it to your baby. Carrying GBS is common and is not an infection in you.",
      hi: "Group B Streptococcus (GBS) ek aam bacteria hai jo kai mahilaayein bina nuksaan ke carry karti hain. Ek aasaan swab, aam taur par karib 36–37 hafte, dekhta hai ki due date ke paas aap ise carry kar rahi hain ya nahi. Agar haan, to labour ke dauraan antibiotics baby tak pahunchne ka chhota khatra bahut kam kar dete hain. GBS carry karna aam hai aur yeh aapme koi infection nahi hai.",
    ),
    interpret: [
      ScanInterpretRow(
        LocalizedText(en: 'Positive / carrier', hi: 'Positive / carrier'),
        LocalizedText(
            en: "GBS was found. It's common and not an infection in you - you'd simply be offered antibiotics in labour as a precaution.",
            hi: 'GBS mila. Yeh aam hai aur aapme infection nahi - bas ehtiyaat ke taur par labour mein antibiotics offer kiye jaate hain.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Negative', hi: 'Negative'),
        LocalizedText(
            en: "GBS wasn't found on this swab.",
            hi: 'Is swab par GBS nahi mila.'),
      ),
      ScanInterpretRow(
        LocalizedText(en: 'Why it matters', hi: 'Yeh kyun maayne rakhta hai'),
        LocalizedText(
            en: 'It simply lets your team plan to protect your baby during birth.',
            hi: 'Yeh bas aapki team ko janm ke samay baby ko surakshit rakhne ki planning mein madad karta hai.'),
      ),
    ],
  ),
};
