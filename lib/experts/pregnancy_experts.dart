// =============================================================================
//  The Pregnancy roster — the people the "Prepare" tab names
// -----------------------------------------------------------------------------
//  ⚠️ WHY THIS FILE EXISTS: PREGNANCY WAS NAMING PEOPLE WITHOUT HAVING ANY.
//
//  `lib/data/prepare_data.dart` described its experts three different ways —
//  `Coach(name, role, bio)` on a masterclass, `Specialist` on a consultation,
//  and a loose `instructorName` / `instructorRole` / `instructorBio` trio on a
//  programme. All three were STRINGS typed into a content file. That has three
//  consequences and every one of them was live:
//
//    1. The name could not be tapped, because there was nothing to open. A
//       mother reported exactly this: the coach on a masterclass is dead, the
//       teacher on a yoga class is not.
//    2. The same person drifted. "Sana Kapoor" was a "Certified prenatal
//       instructor" in Prepare and a "Postnatal & Core Coach · 9 yrs" in Yoga.
//       Nisha Pillai carried two different credentials in ONE data file.
//    3. Every screen had to re-state who she was, because there was nowhere
//       else to put it — which is why a coach block on a masterclass carried a
//       bio, and the yoga class page carried a whole "About Aditi Verma"
//       section under a row that already opened her profile.
//
//  The fix is the one `test/pp_expert_links_test.dart` already argues for in
//  Parenting: **content references an ID, not a name.** An id resolves, so it
//  can be checked by a test; a name cannot be checked against anything, so it
//  drifts and it can be invented.
//
//  ⚠️ THESE PEOPLE ARE SEED DATA AND THE CREDENTIALS ARE PLACEHOLDERS. Degrees,
//  registrations and hospital affiliations are CLAIMS about a person. Nothing
//  here has been verified because nobody here is real yet; the day a real
//  clinician is onboarded, her record comes from `expert_profiles` via
//  `ExpertStore`, verified by an operator. The app must never invent, infer or
//  compute a credential — see `lib/experts/expert.dart`.
//
//  ⚠️ BILINGUAL, IN A SHAPE THE HINDI SCANNERS DO NOT KNOW. Pregnancy is the
//  migrated stage, so every sentence here is paired. The pairing shape is
//  `ExpertHindi`, which is neither `_t(en, hi)` nor `LocalizedText(en:, hi:)`,
//  so `tool/scan_live_hinglish.py` and friends will not see it — that is the
//  "fifth shape" the bilingual skill warns exists. Register it there before
//  trusting a clean scan.
//
//  Script boundary applied as the shipped Pregnancy content already had it:
//  professions and qualifications a mother reads off a clinic door or a
//  degree certificate stay Latin (`Obstetrician`, `IBCLC`, `MBBS`, `MD`,
//  `Doula`, `physiotherapy`); everything she says aloud takes Devanagari.
// =============================================================================

import 'expert.dart';

/// Every expert the Pregnancy stage names, in one list.
///
/// Appended to `kExperts` (see `pp_experts_data.dart`), so `expertById`,
/// `expertByName` and `ExpertStore`'s merge reach these people without any
/// caller learning that there are two stages.
///
/// ⚠️ `category` IS DELIBERATELY EMPTY ON ALL OF THEM. `kFindHelpExperts`
/// filters on a non-empty category, and Find help is a PARENTING door — a
/// mother looking for a paediatrician for her six-month-old should not be
/// offered a prenatal doula. Leaving it empty is what keeps these people
/// reachable everywhere they are named and invisible in a flow they do not
/// belong to.
///
/// ⚠️ `timings` IS ALSO EMPTY, and that is what stops the profile growing a
/// "Book a consultation" bar. Pregnancy consults are bought on the
/// consultation screen, which owns the slot picker and the price; a second
/// booking entry point on the profile would be a second thing to keep correct.
/// The profile links to what she offers instead.
final List<Expert> kPregnancyExperts = [
  // ---------------------------------------------------------------------------
  //  Obstetrics
  // ---------------------------------------------------------------------------
  //  ⚠️ RENAMED FROM "Dr. Ananya Rao" ON 2026-08-27, AND IT WAS NOT COSMETIC.
  //  Parenting already had a `Dr. Ananya Rao` — id `ananya`, a paediatrician
  //  whose subject is infant sleep and vaccinations. Pregnancy's was an
  //  obstetrician with 3,000 deliveries. Two professions, one full name, and
  //  the moment both became tappable, tapping the obstetrician in Prepare
  //  would have opened a paediatrician's profile. That is the exact defect
  //  already recorded against `doctorInfoById()` and `expert_roster` — a real
  //  person's name presented as somebody else's.
  //
  //  Pregnancy was the side that moved because it had four references to
  //  parenting's ten-plus, not because it mattered less.
  Expert(
    id: 'aparna',
    name: 'Dr. Aparna Joshi',
    credential: 'Obstetrician · 15 years',
    backLabel: 'Obstetrician',
    location: 'New Delhi · online consults',
    topPick: true,
    rating: '4.9',
    reviewsCount: '480 reviews',
    mid: ('3,000+', 'births attended'),
    fee: ('₹999', 'per consult'),
    qualifications: [
      'MBBS — Maulana Azad Medical College, New Delhi',
      'MD (Obstetrics & Gynaecology) — AIIMS, New Delhi',
      'Fellowship in high-risk pregnancy',
    ],
    experience: '15 years · over 3,000 deliveries',
    practisesAt: 'Senior Consultant, Obstetrics — Sitaram Bhartia Institute, New Delhi',
    registration: 'DMC Reg. 45120',
    memberships: ['FOGSI', 'Indian Medical Association'],
    blurb:
        "Senior obstetrician at a leading Delhi hospital, with over 3,000 deliveries. Mothers describe her as calm, unhurried, and refreshingly straight-talking.",
    whyHeading: 'Why ParentVeda picks her',
    why:
        "She explains a scan report the way a friend would, then tells you plainly what she would do and why. She is the expert behind ParentVeda's Birth Confidence Masterclass, and she does not talk down to anyone.",
    tags: [
      'Hindi',
      'English',
      'Birth planning',
      'C-section preparation',
      'High-risk pregnancy',
      'Reading scan reports',
    ],
    reviews: const [],
    ctaPrice: '₹999',
    ctaSub: 'per consult',
    ctaLabel: 'View consultations',
    disclaimer:
        'Consultations are held inside ParentVeda. A consult supports your care — it never replaces your own doctor.',
    hi: const ExpertHindi(
      credential: 'Obstetrician · 15 साल',
      location: 'नई दिल्ली · ऑनलाइन consult',
      qualifications: [
        'MBBS — मौलाना आज़ाद मेडिकल कॉलेज, नई दिल्ली',
        'MD (Obstetrics & Gynaecology) — AIIMS, नई दिल्ली',
        'हाई-रिस्क प्रेग्नेंसी में fellowship',
      ],
      experience: '15 साल · 3,000 से ज़्यादा डिलीवरी',
      practisesAt: 'वरिष्ठ Consultant, Obstetrics — सीताराम भारतिया संस्थान, नई दिल्ली',
      blurb:
          'दिल्ली के एक बड़े अस्पताल में वरिष्ठ obstetrician, 3,000 से ज़्यादा डिलीवरी का अनुभव। माँएँ उन्हें शांत, बिना जल्दबाज़ी वाली और सीधी बात करने वाली बताती हैं।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'वे scan report ऐसे समझाती हैं जैसे कोई अपना समझाए, और फिर साफ़ बताती हैं कि वे क्या करतीं और क्यों। ParentVeda की Birth Confidence Masterclass उन्हीं की है, और वे किसी से भी छोटा करके बात नहीं करतीं।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'जन्म की योजना',
        'C-section की तैयारी',
        'हाई-रिस्क प्रेग्नेंसी',
        'scan report समझना',
      ],
    ),
  ),

  // ---------------------------------------------------------------------------
  //  Birth support
  // ---------------------------------------------------------------------------
  Expert(
    id: 'deepti',
    name: 'Deepti Sharma',
    credential: 'Doula & birth coach · 9 years',
    backLabel: 'Birth coach',
    location: 'Gurugram · online and in person',
    topPick: true,
    rating: '4.9',
    reviewsCount: '610 reviews',
    mid: ('400+', 'births supported'),
    fee: ('₹1,299', 'per masterclass'),
    qualifications: [
      'Certified Birth Doula — DONA International',
      'Lamaze-informed childbirth educator',
      'Certified in perinatal emotional support',
    ],
    experience: '9 years · 400+ births supported',
    practisesAt: 'Independent practice, Delhi NCR',
    registration: 'DONA Cert. D-8842',
    memberships: ['DONA International'],
    blurb:
        'A birth doula who brings the part of labour nobody schedules — fear, partners, and staying in control of your own birth.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She distils a whole pregnancy into a calm, do-this-next plan: warm, practical, and refreshingly non-preachy. She is as good with a nervous partner in the room as she is with you.',
    tags: [
      'Hindi',
      'English',
      'Labour support',
      'Birth plans',
      'Partner coaching',
      'Fourth trimester',
    ],
    reviews: const [],
    ctaPrice: '₹1,299',
    ctaSub: 'per masterclass',
    ctaLabel: 'View sessions',
    disclaimer:
        'Sessions are hosted inside ParentVeda. A doula supports you through birth; she does not give medical advice.',
    hi: const ExpertHindi(
      credential: 'Doula और birth coach · 9 साल',
      location: 'गुरुग्राम · ऑनलाइन और आमने-सामने',
      qualifications: [
        'प्रमाणित Birth Doula — DONA International',
        'Lamaze पर आधारित childbirth educator',
        'प्रसव-काल की भावनात्मक मदद में प्रमाणित',
      ],
      experience: '9 साल · 400+ जन्मों में साथ',
      practisesAt: 'अपना स्वतंत्र काम, दिल्ली NCR',
      blurb:
          'एक birth doula जो लेबर का वह हिस्सा सामने लाती हैं जिसकी कोई तैयारी नहीं करता — डर, partner, और अपने जन्म पर अपनी पकड़।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'वे पूरी गर्भावस्था को एक शांत, "अब यह करें" वाले plan में समेट देती हैं — गर्मजोशी से भरी, काम की, और बिना कोई उपदेश दिए। घबराए हुए partner को भी उतनी ही आसानी से सँभालती हैं।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'लेबर में साथ',
        'जन्म की योजना',
        'partner की तैयारी',
        'चौथी तिमाही',
      ],
    ),
  ),

  Expert(
    id: 'meera_nair',
    name: 'Meera Nair',
    credential: 'Childbirth educator · 11 years',
    backLabel: 'Childbirth educator',
    location: 'Kochi · online classes',
    rating: '4.8',
    reviewsCount: '820 reviews',
    mid: ('9k+', 'mothers taught'),
    fee: ('₹2,499', 'per course'),
    qualifications: [
      'Certified Childbirth Educator — Lamaze International',
      'BSc Nursing — Christian Medical College, Vellore',
      'Course reviewed by a practising obstetrician',
    ],
    experience: '11 years teaching birth preparation',
    practisesAt: 'ParentVeda Birthing Classes · independent practice, Kochi',
    registration: 'LCCE Cert. 22-1907',
    memberships: ['Lamaze International'],
    blurb:
        'A certified, OB-reviewed childbirth educator who has prepared thousands of mothers for the big day.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She teaches labour the way it actually unfolds — stage by stage, with the honest bits left in. Nothing in her classes is designed to frighten you into a choice.',
    tags: [
      'Hindi',
      'English',
      'Malayalam',
      'Stages of labour',
      'Breathing for birth',
      'Pain-relief options',
    ],
    reviews: const [],
    ctaPrice: '₹2,499',
    ctaSub: 'complete course',
    ctaLabel: 'View classes',
    disclaimer:
        'Classes are hosted inside ParentVeda. Every class is reviewed by an obstetrician and is never a substitute for your own.',
    hi: const ExpertHindi(
      credential: 'Childbirth educator · 11 साल',
      location: 'कोच्चि · ऑनलाइन क्लास',
      qualifications: [
        'प्रमाणित Childbirth Educator — Lamaze International',
        'BSc Nursing — क्रिश्चियन मेडिकल कॉलेज, वेल्लोर',
        'course की जाँच एक practising obstetrician ने की है',
      ],
      experience: 'जन्म की तैयारी सिखाते हुए 11 साल',
      practisesAt: 'ParentVeda Birthing Classes · अपना स्वतंत्र काम, कोच्चि',
      blurb:
          'एक प्रमाणित, OB द्वारा जाँची गई childbirth educator, जिन्होंने हज़ारों माँओं को उस बड़े दिन के लिए तैयार किया है।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'वे लेबर वैसे ही सिखाती हैं जैसे वह सच में होता है — चरण दर चरण, ईमानदार हिस्सों को हटाए बिना। उनकी किसी क्लास का मक़सद आपको डराकर कोई फ़ैसला करवाना नहीं है।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'मलयालम',
        'लेबर के चरण',
        'जन्म के लिए साँस',
        'दर्द से राहत के विकल्प',
      ],
    ),
  ),

  // ---------------------------------------------------------------------------
  //  Newborn care
  // ---------------------------------------------------------------------------
  Expert(
    id: 'kabir_rao',
    name: 'Dr. Kabir Rao',
    credential: 'Paediatrician · 12 years',
    backLabel: 'Paediatrician',
    location: 'Bengaluru · online consults',
    rating: '4.8',
    reviewsCount: '390 reviews',
    mid: ('12 years', 'newborn care'),
    fee: ('₹1,499', 'per masterclass'),
    qualifications: [
      'MBBS — Kasturba Medical College, Manipal',
      'MD (Paediatrics) — St. John\'s Medical College, Bengaluru',
      'Neonatal resuscitation programme instructor',
    ],
    experience: '12 years in newborn and infant care',
    practisesAt: 'Consultant Paediatrician — Rainbow Children\'s Hospital, Bengaluru',
    registration: 'KMC Reg. 71204',
    memberships: ['Indian Academy of Paediatrics'],
    blurb:
        'Guides new parents through the newborn weeks with steady, no-panic advice grounded in Indian homes.',
    whyHeading: 'Why ParentVeda picks him',
    why:
        'He answers the 2am questions without making anyone feel foolish for asking, and he is honest about which worries are worth a hospital trip and which are worth a night\'s sleep.',
    tags: [
      'Hindi',
      'English',
      'Kannada',
      'Newborn care',
      'Feeding and weight',
      'First vaccinations',
    ],
    reviews: const [],
    ctaPrice: '₹1,499',
    ctaSub: 'per masterclass',
    ctaLabel: 'View sessions',
    disclaimer:
        'Sessions are hosted inside ParentVeda. Nothing here is a diagnosis — for anything urgent, see your paediatrician.',
    hi: const ExpertHindi(
      credential: 'Paediatrician · 12 साल',
      location: 'बेंगलुरु · ऑनलाइन consult',
      qualifications: [
        'MBBS — कस्तूरबा मेडिकल कॉलेज, मणिपाल',
        'MD (Paediatrics) — सेंट जॉन्स मेडिकल कॉलेज, बेंगलुरु',
        'नवजात resuscitation कार्यक्रम के instructor',
      ],
      experience: 'नवजात और शिशु देखभाल में 12 साल',
      practisesAt: 'Consultant Paediatrician — रेनबो चिल्ड्रन्स हॉस्पिटल, बेंगलुरु',
      blurb:
          'नए माता-पिता को नवजात के हफ़्तों से पार लगाते हैं — भारतीय घरों को समझने वाली, शांत और घबराहट-रहित सलाह के साथ।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'रात दो बजे वाले सवालों का जवाब वे बिना किसी को छोटा महसूस कराए देते हैं, और साफ़ बताते हैं कि कौन-सी चिंता अस्पताल लायक़ है और कौन-सी बस एक अच्छी नींद लायक़।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'कन्नड़',
        'नवजात की देखभाल',
        'दूध और वज़न',
        'पहले टीके',
      ],
    ),
  ),

  Expert(
    id: 'sana_khan',
    name: 'Sana Khan',
    credential: 'Lactation Consultant · IBCLC · 8 years',
    backLabel: 'Lactation consultant',
    location: 'Mumbai · online consults',
    topPick: true,
    rating: '4.9',
    reviewsCount: '540 reviews',
    mid: ('2,000+', 'mothers helped'),
    fee: ('₹799', 'per consult'),
    qualifications: [
      'IBCLC — International Board Certified Lactation Consultant',
      'BSc Nursing — KEM Hospital, Mumbai',
      'Certified in tongue-tie and latch assessment',
    ],
    experience: '8 years · 2,000+ feeding consults',
    practisesAt: 'Independent lactation practice, Mumbai',
    registration: 'IBLCE Reg. L-32118',
    memberships: ['ILCA — International Lactation Consultant Association'],
    blurb:
        'An IBCLC who makes the first week feel far less daunting — practical, gentle, and judgement-free.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She prepares you to breastfeed BEFORE the baby arrives, which is the half almost nobody covers. She will also tell you plainly when formula is the right answer, which is why mothers trust her.',
    tags: [
      'Hindi',
      'English',
      'Urdu',
      'Latch and positioning',
      'Milk supply',
      'Returning to work',
    ],
    reviews: const [],
    ctaPrice: '₹799',
    ctaSub: 'per consult',
    ctaLabel: 'View consultations',
    disclaimer:
        'Consultations are held inside ParentVeda. Feeding support is not medical treatment — see a doctor for anything clinical.',
    hi: const ExpertHindi(
      credential: 'Lactation Consultant · IBCLC · 8 साल',
      location: 'मुंबई · ऑनलाइन consult',
      qualifications: [
        'IBCLC — International Board Certified Lactation Consultant',
        'BSc Nursing — KEM अस्पताल, मुंबई',
        'tongue-tie और latch की जाँच में प्रमाणित',
      ],
      experience: '8 साल · 2,000+ feeding consult',
      practisesAt: 'अपना स्वतंत्र lactation काम, मुंबई',
      blurb:
          'एक IBCLC जो पहले हफ़्ते का डर काफ़ी कम कर देती हैं — काम की बातें, नरमी से, बिना किसी फ़ैसले के।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'वे शिशु के आने से पहले ही स्तनपान की तैयारी कराती हैं — वह आधा हिस्सा जिसे लगभग कोई नहीं छूता। और जब formula ही सही जवाब हो, वे साफ़ कह देती हैं; माँएँ इसीलिए उन पर भरोसा करती हैं।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'उर्दू',
        'latch और मुद्रा',
        'दूध की सप्लाई',
        'काम पर वापसी',
      ],
    ),
  ),

  // ---------------------------------------------------------------------------
  //  Mind and body
  // ---------------------------------------------------------------------------
  Expert(
    id: 'neha_verma',
    name: 'Dr. Neha Verma',
    credential: 'Clinical Psychologist · 11 years',
    backLabel: 'Prenatal counsellor',
    location: 'Pune · online sessions',
    rating: '5.0',
    reviewsCount: '260 reviews',
    mid: ('11 years', 'perinatal practice'),
    fee: ('₹899', 'per session'),
    qualifications: [
      'MPhil Clinical Psychology — NIMHANS, Bengaluru',
      'MA Psychology — Savitribai Phule Pune University',
      'Certified in perinatal mental health',
    ],
    experience: '11 years · perinatal anxiety and mood',
    practisesAt: 'Independent practice, Pune',
    registration: 'RCI Reg. A-55831',
    memberships: ['Rehabilitation Council of India'],
    blurb:
        'A clinical psychologist who holds space for the parts of pregnancy that are hard to say out loud — anxiety, mood swings, and the quiet weight of expectation.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She is unhurried and completely unshockable. Mothers describe leaving a session feeling normal rather than fixed, which is usually the thing they came for.',
    tags: [
      'Hindi',
      'English',
      'Marathi',
      'Pregnancy anxiety',
      'Mood changes',
      'Fear of birth',
    ],
    reviews: const [],
    ctaPrice: '₹899',
    ctaSub: 'per session',
    ctaLabel: 'View consultations',
    disclaimer:
        'Sessions are held inside ParentVeda. If you are in crisis, please contact a doctor or a helpline immediately.',
    hi: const ExpertHindi(
      credential: 'Clinical Psychologist · 11 साल',
      location: 'पुणे · ऑनलाइन session',
      qualifications: [
        'MPhil Clinical Psychology — NIMHANS, बेंगलुरु',
        'MA मनोविज्ञान — सावित्रीबाई फुले पुणे विश्वविद्यालय',
        'प्रसव-काल के मानसिक स्वास्थ्य में प्रमाणित',
      ],
      experience: '11 साल · प्रसव-काल की घबराहट और मन का हाल',
      practisesAt: 'अपना स्वतंत्र काम, पुणे',
      blurb:
          'एक clinical psychologist जो गर्भावस्था की उन बातों के लिए जगह बनाती हैं जो कहते नहीं बनतीं — घबराहट, मन के उतार-चढ़ाव, और उम्मीदों का चुपचाप बोझ।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'वे जल्दी में नहीं होतीं, और उन्हें कुछ भी चौंकाता नहीं। माँएँ कहती हैं कि session के बाद वे "ठीक की गई" नहीं, बल्कि सामान्य महसूस करती हैं — अक्सर वही चीज़ जिसके लिए वे आई थीं।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'मराठी',
        'गर्भावस्था की घबराहट',
        'मन का बदलना',
        'जन्म का डर',
      ],
    ),
  ),

  Expert(
    id: 'kavya_menon',
    name: 'Kavya Menon',
    credential: "Women's-health physiotherapist · 9 years",
    backLabel: 'Physiotherapist',
    location: 'Chennai · online and in person',
    rating: '4.7',
    reviewsCount: '310 reviews',
    mid: ('9 years', "women's health"),
    fee: ('₹699', 'per session'),
    qualifications: [
      'MPT (Obstetrics & Gynaecology) — Sri Ramachandra Institute, Chennai',
      'BPT — Tamil Nadu Dr. MGR Medical University',
      'Certified in pelvic-floor rehabilitation',
    ],
    experience: "9 years in women's-health physiotherapy",
    practisesAt: 'Independent practice, Chennai',
    registration: 'TNSMC PT Reg. 9042',
    memberships: ['Indian Association of Physiotherapists'],
    blurb:
        "A women's-health physiotherapist who eases the aches pregnancy brings and prepares your body for birth and recovery — with simple moves you can actually keep up.",
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She gives you three things to do, not thirty, and she checks that you can do them in a normal Indian home without equipment. Her pelvic-floor prep is the part mothers thank her for after the birth.',
    tags: [
      'Hindi',
      'English',
      'Tamil',
      'Back and pelvic pain',
      'Pelvic floor',
      'Posture and movement',
    ],
    reviews: const [],
    ctaPrice: '₹699',
    ctaSub: 'per session',
    ctaLabel: 'View consultations',
    disclaimer:
        'Sessions are held inside ParentVeda. Stop any exercise that hurts and check with your doctor before starting.',
    hi: const ExpertHindi(
      credential: 'महिला-स्वास्थ्य physiotherapist · 9 साल',
      location: 'चेन्नई · ऑनलाइन और आमने-सामने',
      qualifications: [
        'MPT (Obstetrics & Gynaecology) — श्री रामचंद्र संस्थान, चेन्नई',
        'BPT — तमिलनाडु डॉ. एमजीआर मेडिकल यूनिवर्सिटी',
        'pelvic-floor पुनर्वास में प्रमाणित',
      ],
      experience: 'महिला-स्वास्थ्य physiotherapy में 9 साल',
      practisesAt: 'अपना स्वतंत्र काम, चेन्नई',
      blurb:
          'महिला-स्वास्थ्य की physiotherapist, जो गर्भावस्था के दर्द कम करती हैं और आपके शरीर को जन्म और रिकवरी के लिए तैयार करती हैं — ऐसी आसान क़वायदों से जो आप सच में जारी रख पाएँगी।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'वे तीस नहीं, तीन चीज़ें करने को देती हैं — और यह भी देखती हैं कि वे एक आम भारतीय घर में बिना किसी सामान के हो पाएँ। जन्म के बाद माँएँ उनके pelvic-floor वाले हिस्से के लिए सबसे ज़्यादा शुक्रिया कहती हैं।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'तमिल',
        'कमर और pelvic दर्द',
        'pelvic floor',
        'मुद्रा और हलचल',
      ],
    ),
  ),
];
