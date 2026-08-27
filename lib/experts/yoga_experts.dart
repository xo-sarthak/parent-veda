// =============================================================================
//  The movement roster — yoga, breathwork and body-recovery teachers
// -----------------------------------------------------------------------------
//  These seven teach the classes in `pp_yoga_data.dart`. That file names them
//  with three loose strings per class — `instructorName`, `instructorCredential`
//  and (sometimes) `instructorBio` — which meant the SAME teacher was described
//  differently depending on which class you opened:
//
//    * Nisha Pillai was a "Yoga & Breathwork Guide · 8 yrs" on six classes and
//      a "Meditation & Breathwork Guide · 8 yrs" on four others. One person,
//      one data file, two credentials, nothing to catch it.
//    * Sana Kapoor was a "Postnatal & Core Coach · 9 yrs" in Yoga and a
//      "Certified prenatal instructor" in the Pregnancy Prepare tab — the same
//      person, split across two stages, described by two authors.
//    * Only Aditi Verma had a bio at all, so only her class page could say
//      anything about who was teaching. Everyone else got a name and a rank.
//
//  A roster fixes all three at once, because there is now exactly one place a
//  teacher is described and every class points at it.
//
//  ⚠️ WHY THIS ROSTER IS NOT IN `pregnancy_experts.dart` OR IN THE PARENTING
//  LIST: these teachers belong to BOTH stages. `prepare_hub_screen.dart` opens
//  `yoga_home_screen.dart`, so a pregnant mother and a mother of a six-month-old
//  reach the same marketplace and the same teachers. Filing them under either
//  stage would have been the same mistake `Expert` itself was just moved out
//  of.
//
//  ⚠️ SEED DATA. Every qualification and registration number below is a
//  placeholder for a person who does not exist yet — see the same warning in
//  `pregnancy_experts.dart`. Real teachers arrive through `expert_profiles`.
//
//  Bilingual because Pregnancy reaches these people: yoga is on the Prepare hub.
//  Script boundary as shipped: the practice names a mother says aloud take
//  Devanagari (योग, प्राणायाम), the certifications she reads off a certificate
//  stay Latin (`RYT-500`, `Lamaze`, `IBCLC`, `BPT`).
// =============================================================================

import 'expert.dart';

/// Every teacher named by the yoga & movement marketplace.
///
/// `category` and `timings` stay empty for the same two reasons given in
/// `kPregnancyExperts`: Find help is a Parenting consult door these teachers do
/// not belong to, and class booking already lives on the class page.
final List<Expert> kYogaExperts = [
  Expert(
    id: 'aditi_verma',
    name: 'Aditi Verma',
    credential: 'Certified Yoga Acharya · 15 years',
    backLabel: 'Yoga teacher',
    location: 'Mysuru · online classes',
    topPick: true,
    rating: '4.9',
    reviewsCount: '604 reviews',
    mid: ('15 years', 'teaching'),
    fee: ('₹399', 'per class'),
    qualifications: [
      'Yoga Acharya — Ashtanga Yoga Research Institute, Mysuru',
      'RYT-500 — Yoga Alliance',
      'Certified in prenatal and postnatal yoga',
      'Trained in diastasis recti and pelvic-floor rehabilitation',
    ],
    experience: '15 years, almost entirely with pregnant and postpartum women',
    practisesAt: 'ParentVeda live classes · own shala, Mysuru',
    registration: 'Yoga Alliance RYT-500 · 218844',
    memberships: ['Yoga Alliance'],
    blurb:
        'Trained in Mysore and has spent fifteen years working almost entirely with pregnant and postpartum women.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She is unusually careful about diastasis recti and pelvic-floor recovery, and will slow a session down rather than push a pose that is not ready. Every posture in her class is optional and she says so out loud.',
    tags: [
      'Hindi',
      'English',
      'Postpartum recovery',
      'Pelvic floor',
      'Diastasis recti',
      'Gentle prenatal',
    ],
    reviews: const [],
    ctaPrice: '₹399',
    ctaSub: 'per class',
    ctaLabel: 'View her classes',
    disclaimer:
        'Classes are hosted inside ParentVeda. Check with your doctor before starting any new practice in pregnancy or after birth.',
    hi: const ExpertHindi(
      credential: 'प्रमाणित योग आचार्य · 15 साल',
      location: 'मैसूर · ऑनलाइन क्लास',
      qualifications: [
        'योग आचार्य — अष्टांग योग रिसर्च इंस्टिट्यूट, मैसूर',
        'RYT-500 — Yoga Alliance',
        'गर्भावस्था और प्रसव के बाद के योग में प्रमाणित',
        'diastasis recti और pelvic-floor पुनर्वास का प्रशिक्षण',
      ],
      experience: '15 साल, लगभग पूरी तरह गर्भवती और प्रसव के बाद वाली महिलाओं के साथ',
      practisesAt: 'ParentVeda की live क्लास · अपनी शाला, मैसूर',
      blurb:
          'मैसूर में प्रशिक्षित, और पंद्रह साल से लगभग पूरी तरह गर्भवती और प्रसव के बाद वाली महिलाओं के साथ काम कर रही हैं।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'diastasis recti और pelvic floor की रिकवरी को लेकर वे असाधारण रूप से सावधान हैं — जो मुद्रा अभी तैयार नहीं, उसे ज़ोर देने के बजाय वे पूरी क्लास धीमी कर देती हैं। उनकी क्लास में हर मुद्रा वैकल्पिक है, और वे यह ख़ुद कहकर बताती हैं।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'प्रसव के बाद रिकवरी',
        'pelvic floor',
        'diastasis recti',
        'सौम्य prenatal योग',
      ],
    ),
  ),

  Expert(
    id: 'radhika_menon',
    name: 'Radhika Menon',
    credential: 'Prenatal Yoga Therapist · 12 years',
    backLabel: 'Prenatal yoga therapist',
    location: 'Bengaluru · online classes',
    topPick: true,
    rating: '4.9',
    reviewsCount: '706 reviews',
    mid: ('12 years', 'prenatal yoga'),
    fee: ('₹449', 'per class'),
    qualifications: [
      'Certified Yoga Therapist (C-IAYT)',
      'RYT-500 — Yoga Alliance',
      'Diploma in Yoga Therapy — SVYASA, Bengaluru',
      'Specialist training in trimester-safe sequencing',
    ],
    experience: '12 years teaching prenatal yoga only',
    practisesAt: 'ParentVeda live classes · studio practice, Bengaluru',
    registration: 'IAYT Cert. C-4471',
    memberships: ['International Association of Yoga Therapists'],
    blurb:
        'A yoga therapist who teaches nothing but prenatal — every sequence is scaled to the trimester you are actually in.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She will ask which week you are in before she starts, and she changes the class for it. Mothers with pelvic-girdle pain and a tired lower back come to her first.',
    tags: [
      'Hindi',
      'English',
      'Malayalam',
      'Trimester-safe sequencing',
      'Hip and pelvis opening',
      'Lower-back relief',
    ],
    reviews: const [],
    ctaPrice: '₹449',
    ctaSub: 'per class',
    ctaLabel: 'View her classes',
    disclaimer:
        'Classes are hosted inside ParentVeda. Check with your doctor before starting any new practice in pregnancy.',
    hi: const ExpertHindi(
      credential: 'Prenatal योग चिकित्सक · 12 साल',
      location: 'बेंगलुरु · ऑनलाइन क्लास',
      qualifications: [
        'प्रमाणित योग चिकित्सक (C-IAYT)',
        'RYT-500 — Yoga Alliance',
        'योग चिकित्सा में डिप्लोमा — SVYASA, बेंगलुरु',
        'तिमाही के हिसाब से सुरक्षित क्रम बनाने का विशेष प्रशिक्षण',
      ],
      experience: 'सिर्फ़ prenatal योग सिखाते हुए 12 साल',
      practisesAt: 'ParentVeda की live क्लास · अपना studio, बेंगलुरु',
      blurb:
          'एक योग चिकित्सक जो सिर्फ़ prenatal योग सिखाती हैं — हर क्रम उसी तिमाही के हिसाब से ढाला जाता है जिसमें आप सच में हैं।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'शुरू करने से पहले वे पूछती हैं कि आप कौन-से हफ़्ते में हैं, और उसी के हिसाब से क्लास बदल देती हैं। pelvic-girdle का दर्द और थकी हुई कमर लेकर माँएँ सबसे पहले उन्हीं के पास आती हैं।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'मलयालम',
        'तिमाही के हिसाब से सुरक्षित क्रम',
        'कूल्हे और pelvis खोलना',
        'कमर के निचले हिस्से में राहत',
      ],
    ),
  ),

  Expert(
    id: 'nisha_pillai',
    // ⚠️ ONE CREDENTIAL, ON PURPOSE. The class data called her a "Yoga &
    // Breathwork Guide" on six classes and a "Meditation & Breathwork Guide"
    // on four. She teaches all three, so the roster says all three once
    // instead of letting each class page pick a subset.
    name: 'Nisha Pillai',
    credential: 'Yoga, Breathwork & Meditation Guide · 8 years',
    backLabel: 'Breathwork guide',
    location: 'Kochi · online classes',
    rating: '4.8',
    reviewsCount: '2,588 reviews',
    mid: ('8 years', 'breath and stillness'),
    fee: ('₹299', 'per class'),
    qualifications: [
      'RYT-200 — Yoga Alliance',
      'Certified Pranayama teacher — Kaivalyadhama, Lonavala',
      'Trained in mindfulness-based stress reduction (MBSR)',
    ],
    experience: '8 years teaching breath, sleep and stillness',
    practisesAt: 'ParentVeda live and recorded classes',
    registration: 'Yoga Alliance RYT-200 · 341902',
    memberships: ['Yoga Alliance'],
    blurb:
        'Teaches the quiet half of the practice — breath, sleep and settling a racing mind, for people who are certain they cannot meditate.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'Her classes are short enough to actually do at the end of a bad day, and she never asks anyone to empty their mind. The labour-breathing sessions are the ones mothers say they used for real.',
    tags: [
      'Hindi',
      'English',
      'Malayalam',
      'Breathing for labour',
      'Sleep and wind-down',
      'Anxiety and overwhelm',
    ],
    reviews: const [],
    ctaPrice: '₹299',
    ctaSub: 'per class',
    ctaLabel: 'View her classes',
    disclaimer:
        'Classes are hosted inside ParentVeda. Breathwork supports how you feel; it is not treatment for a medical condition.',
    hi: const ExpertHindi(
      credential: 'योग, प्राणायाम और ध्यान की शिक्षिका · 8 साल',
      location: 'कोच्चि · ऑनलाइन क्लास',
      qualifications: [
        'RYT-200 — Yoga Alliance',
        'प्रमाणित प्राणायाम शिक्षिका — कैवल्यधाम, लोनावला',
        'mindfulness पर आधारित तनाव-प्रबंधन (MBSR) का प्रशिक्षण',
      ],
      experience: 'साँस, नींद और ठहराव सिखाते हुए 8 साल',
      practisesAt: 'ParentVeda की live और रिकॉर्डेड क्लास',
      blurb:
          'अभ्यास का शांत आधा हिस्सा सिखाती हैं — साँस, नींद, और भागते मन को टिकाना; उनके लिए भी जिन्हें पक्का यक़ीन है कि उनसे ध्यान नहीं होता।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'उनकी क्लास इतनी छोटी हैं कि एक ख़राब दिन के आख़िर में भी सच में हो जाएँ, और वे कभी नहीं कहतीं कि मन ख़ाली कर लीजिए। लेबर की साँस वाले session वही हैं जिन्हें माँएँ कहती हैं कि उन्होंने असल में इस्तेमाल किए।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'मलयालम',
        'लेबर के लिए साँस',
        'नींद और शांति',
        'घबराहट और बोझ',
      ],
    ),
  ),

  Expert(
    id: 'farah_sheikh',
    name: 'Farah Sheikh',
    credential: 'Lamaze Educator · 10 years',
    backLabel: 'Lamaze educator',
    location: 'Hyderabad · online classes',
    rating: '4.8',
    reviewsCount: '462 reviews',
    mid: ('10 years', 'birth preparation'),
    fee: ('₹499', 'per class'),
    qualifications: [
      'Lamaze Certified Childbirth Educator (LCCE)',
      'Certified prenatal yoga teacher',
      'Trained in comfort measures and labour positioning',
    ],
    experience: '10 years preparing couples for labour',
    practisesAt: 'ParentVeda live classes · independent practice, Hyderabad',
    registration: 'LCCE Cert. 19-2280',
    memberships: ['Lamaze International'],
    blurb:
        'A Lamaze educator who teaches movement and positioning for labour — what to do with your body when a contraction arrives.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She teaches the partner as much as the mother, because in an Indian delivery room the partner is often the only person free to hold a hip. Practical, unsentimental, and very hard to panic.',
    tags: [
      'Hindi',
      'English',
      'Urdu',
      'Labour positions',
      'Comfort measures',
      'Partner coaching',
    ],
    reviews: const [],
    ctaPrice: '₹499',
    ctaSub: 'per class',
    ctaLabel: 'View her classes',
    disclaimer:
        'Classes are hosted inside ParentVeda. Birth preparation supports your care team; it never replaces it.',
    hi: const ExpertHindi(
      credential: 'Lamaze शिक्षिका · 10 साल',
      location: 'हैदराबाद · ऑनलाइन क्लास',
      qualifications: [
        'Lamaze प्रमाणित Childbirth Educator (LCCE)',
        'प्रमाणित prenatal योग शिक्षिका',
        'लेबर में आराम के तरीक़ों और मुद्राओं का प्रशिक्षण',
      ],
      experience: 'दस साल से जोड़ों को लेबर के लिए तैयार कर रही हैं',
      practisesAt: 'ParentVeda की live क्लास · अपना स्वतंत्र काम, हैदराबाद',
      blurb:
          'एक Lamaze शिक्षिका जो लेबर के लिए हलचल और मुद्राएँ सिखाती हैं — contraction आने पर शरीर का क्या करना है।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'वे माँ जितना ही partner को भी सिखाती हैं, क्योंकि भारतीय delivery room में अक्सर partner ही अकेला होता है जो कूल्हा दबा सके। काम की बातें, बिना भावुकता, और घबराना उन्हें आता ही नहीं।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'उर्दू',
        'लेबर की मुद्राएँ',
        'आराम के तरीक़े',
        'partner की तैयारी',
      ],
    ),
  ),

  Expert(
    id: 'kavya_reddy',
    name: 'Kavya Reddy',
    credential: 'Fertility Yoga Specialist · 7 years',
    backLabel: 'Fertility yoga specialist',
    location: 'Hyderabad · online classes',
    rating: '4.9',
    reviewsCount: '316 reviews',
    mid: ('7 years', 'fertility yoga'),
    fee: ('₹399', 'per class'),
    qualifications: [
      'RYT-500 — Yoga Alliance',
      'Certified in yoga for fertility and hormonal health',
      'Trained in restorative practice for IVF cycles',
    ],
    experience: '7 years working with couples trying to conceive',
    practisesAt: 'ParentVeda live classes · independent practice, Hyderabad',
    registration: 'Yoga Alliance RYT-500 · 402117',
    memberships: ['Yoga Alliance'],
    blurb:
        'Teaches gentle, restorative practice for people trying to conceive — including the weeks around an IVF or IUI cycle.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She is careful about the one thing this subject gets wrong constantly: she never suggests a practice will make you pregnant. What she offers is a body that feels less braced, on months that are hard.',
    tags: [
      'Hindi',
      'English',
      'Telugu',
      'Restorative practice',
      'Stress and the two-week wait',
      'Gentle movement through treatment',
    ],
    reviews: const [],
    ctaPrice: '₹399',
    ctaSub: 'per class',
    ctaLabel: 'View her classes',
    disclaimer:
        'Classes are hosted inside ParentVeda. Yoga supports how you feel; it does not treat infertility and never replaces your clinic.',
    hi: const ExpertHindi(
      credential: 'Fertility योग विशेषज्ञ · 7 साल',
      location: 'हैदराबाद · ऑनलाइन क्लास',
      qualifications: [
        'RYT-500 — Yoga Alliance',
        'fertility और हार्मोन-स्वास्थ्य के योग में प्रमाणित',
        'IVF चक्र के दौरान आराम देने वाले अभ्यास का प्रशिक्षण',
      ],
      experience: 'गर्भधारण की कोशिश कर रहे जोड़ों के साथ 7 साल',
      practisesAt: 'ParentVeda की live क्लास · अपना स्वतंत्र काम, हैदराबाद',
      blurb:
          'गर्भधारण की कोशिश कर रहे लोगों के लिए सौम्य, आराम देने वाला अभ्यास सिखाती हैं — IVF या IUI चक्र के आसपास के हफ़्तों में भी।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'इस विषय में जो ग़लती बार-बार होती है, उससे वे बचती हैं: वे कभी नहीं कहतीं कि किसी अभ्यास से गर्भ ठहर जाएगा। वे बस इतना देती हैं कि मुश्किल महीनों में शरीर थोड़ा कम अकड़ा हुआ लगे।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'तेलुगु',
        'आराम देने वाला अभ्यास',
        'तनाव और दो हफ़्ते का इंतज़ार',
        'इलाज के दौरान सौम्य हलचल',
      ],
    ),
  ),

  Expert(
    id: 'meghna_rao',
    name: 'Meghna Rao',
    credential: 'Pelvic Floor Physiotherapist · 11 years',
    backLabel: 'Pelvic floor physiotherapist',
    location: 'Mumbai · online and in person',
    rating: '4.9',
    reviewsCount: '450 reviews',
    mid: ('11 years', 'pelvic health'),
    fee: ('₹799', 'per session'),
    qualifications: [
      'MPT (Obstetrics & Gynaecology) — Nitte Institute of Physiotherapy',
      'BPT — Maharashtra University of Health Sciences',
      'Certified in pelvic-floor and abdominal-wall rehabilitation',
    ],
    experience: '11 years in pelvic-floor and postpartum recovery',
    practisesAt: 'Independent practice, Mumbai',
    registration: 'MSCPT Reg. 14286',
    memberships: ['Indian Association of Physiotherapists'],
    blurb:
        'A physiotherapist for the parts of recovery nobody warns you about — leaking, heaviness, and an abdominal wall that has not closed.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She treats pelvic-floor symptoms as a thing to fix rather than a thing to live with, and she says the words out loud so a mother does not have to find them first.',
    tags: [
      'Hindi',
      'English',
      'Marathi',
      'Pelvic floor',
      'Diastasis recti',
      'Postpartum core recovery',
    ],
    reviews: const [],
    ctaPrice: '₹799',
    ctaSub: 'per session',
    ctaLabel: 'View her classes',
    disclaimer:
        'Sessions are hosted inside ParentVeda. Stop anything that hurts, and see a doctor for pain, bleeding or fever.',
    hi: const ExpertHindi(
      credential: 'Pelvic floor physiotherapist · 11 साल',
      location: 'मुंबई · ऑनलाइन और आमने-सामने',
      qualifications: [
        'MPT (Obstetrics & Gynaecology) — नित्ते इंस्टिट्यूट ऑफ़ फ़िज़ियोथेरेपी',
        'BPT — महाराष्ट्र यूनिवर्सिटी ऑफ़ हेल्थ साइंसेज़',
        'pelvic floor और पेट की दीवार के पुनर्वास में प्रमाणित',
      ],
      experience: 'pelvic floor और प्रसव के बाद की रिकवरी में 11 साल',
      practisesAt: 'अपना स्वतंत्र काम, मुंबई',
      blurb:
          'रिकवरी के उन हिस्सों की physiotherapist जिनके बारे में कोई पहले से नहीं बताता — पेशाब का रिसना, भारीपन, और पेट की दीवार का न जुड़ पाना।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'वे pelvic floor की तकलीफ़ को "झेलते रहने वाली बात" नहीं, "ठीक होने वाली बात" मानती हैं — और वे शब्द ख़ुद बोल देती हैं, ताकि माँ को पहले उन्हें ढूँढना न पड़े।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'मराठी',
        'pelvic floor',
        'diastasis recti',
        'प्रसव के बाद core की रिकवरी',
      ],
    ),
  ),

  // ⚠️ ONE PERSON, TWO STAGES. She was "Postnatal & Core Coach · 9 yrs" in the
  // yoga catalogue and "Certified prenatal instructor" in Pregnancy's
  // `Fit & Strong Pregnancy` cohort. The credential below covers both, which is
  // the whole reason the roster exists: a teacher is described once.
  Expert(
    id: 'sana_kapoor',
    name: 'Sana Kapoor',
    credential: 'Prenatal & postnatal coach · 9 years',
    backLabel: 'Fitness coach',
    location: 'Delhi NCR · online cohorts',
    rating: '4.9',
    reviewsCount: '952 reviews',
    mid: ('9 years', 'pre & postnatal'),
    fee: ('₹4,999', 'per cohort'),
    qualifications: [
      'Certified Pre & Postnatal Coach — GGS (Girls Gone Strong)',
      'ACE Certified Personal Trainer',
      'Certified in core and pelvic-floor safe progression',
    ],
    experience: '9 years coaching pregnancy and postpartum strength',
    practisesAt: 'ParentVeda cohorts and live classes',
    registration: 'ACE Cert. 1288104',
    memberships: ['Girls Gone Strong Coaching Association'],
    blurb:
        'A certified pre- and postnatal coach whose sessions are scaled safely to every trimester — and to whatever your body is actually doing that week.',
    whyHeading: 'Why ParentVeda picks her',
    why:
        'She progresses people rather than protecting them into doing nothing, which is rarer than it should be in this field. Nothing she programmes needs a gym.',
    tags: [
      'Hindi',
      'English',
      'Safe strength in pregnancy',
      'Core recovery',
      'Trimester-scaled workouts',
      'Home workouts, no equipment',
    ],
    reviews: const [],
    ctaPrice: '₹4,999',
    ctaSub: 'per cohort',
    ctaLabel: 'View her programmes',
    disclaimer:
        'Cohorts and classes are hosted inside ParentVeda. Get your doctor\'s clearance before starting or returning to exercise.',
    hi: const ExpertHindi(
      credential: 'Prenatal और postnatal कोच · 9 साल',
      location: 'दिल्ली NCR · ऑनलाइन cohort',
      qualifications: [
        'प्रमाणित Pre & Postnatal Coach — GGS (Girls Gone Strong)',
        'ACE प्रमाणित Personal Trainer',
        'core और pelvic floor के लिए सुरक्षित प्रगति में प्रमाणित',
      ],
      experience: 'गर्भावस्था और प्रसव के बाद की मज़बूती सिखाते हुए 9 साल',
      practisesAt: 'ParentVeda के cohort और live क्लास',
      blurb:
          'एक प्रमाणित pre- और postnatal कोच, जिनके session हर तिमाही के हिसाब से सुरक्षित ढंग से ढाले जाते हैं — और उस हफ़्ते आपका शरीर जैसा है, उसके हिसाब से भी।',
      whyHeading: 'ParentVeda इन्हें क्यों चुनता है',
      why:
          'वे लोगों को आगे बढ़ाती हैं, इतना बचाकर नहीं रखतीं कि कुछ करना ही न बचे — इस क्षेत्र में यह जितना आम होना चाहिए, उतना है नहीं। उनका कोई भी workout gym माँगता नहीं।',
      tags: [
        'हिन्दी',
        'अंग्रेज़ी',
        'गर्भावस्था में सुरक्षित मज़बूती',
        'core की रिकवरी',
        'तिमाही के हिसाब से workout',
        'घर पर, बिना सामान',
      ],
    ),
  ),
];
