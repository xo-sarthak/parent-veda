// =============================================================================
//  Prepare - content model + data
// -----------------------------------------------------------------------------
//  Single source of truth for the "Prepare" tab. Every category screen lists
//  from here, and every detail page renders from the matching object - so
//  nothing dead-ends. Content is a faithful, on-brand extension of the Claude
//  Design mock (Priya · 30 weeks). Static for now; a future pass can make it
//  week-adaptive and back it with a CMS/DB.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/prepare/prepare_common.dart';
import '../localization/app_language.dart';

// ---- shared value types -----------------------------------------------------
LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

/// Identical in both languages BY NATURE - a brand, a drug name printed on
/// a packet, an acronym a mother reads in Latin either way. Distinct from
/// `_en()`, which means 'English for now, Hindi owed'. This one is finished
/// work, and saying so is what keeps tool/hindi_audit.py honest.
LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

/// English-only, awaiting translation. Same shape as a translated pair so
/// the model can widen, but deliberately NOT `_t(x, x)`: an identical pair
/// reads as finished work to anything counting pairs.
/// `grep -c '_en('` is the size of what is left here.
///
/// UNUSED AS OF 2026-08-11 — nothing in this file is English-owed any more, and
/// that is the reason to keep it rather than to delete it: it is the marker for
/// the next English-only string added here. Without it the obvious move is
/// `_t(x, x)`, which reads as finished work to every audit.
// ignore: unused_element
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

class Coach {
  const Coach(this.name, this.role, this.bio);
  final LocalizedText name;
  final LocalizedText role;
  final LocalizedText bio;
}

class QuickFact {
  const QuickFact(this.big, this.small);
  final LocalizedText big;
  final LocalizedText small;
}

class Testimonial {
  const Testimonial(this.quote, this.who, this.when);
  final LocalizedText quote;
  final LocalizedText who;
  final LocalizedText when;
}

class Faq {
  const Faq(this.q, [this.a]);
  final LocalizedText q;
  final LocalizedText? a; // open (with answer) vs collapsed
}

class Review {
  const Review(this.who, this.when, this.quote);
  final LocalizedText who;
  final LocalizedText when;
  final LocalizedText quote;
}

// ---- masterclasses ----------------------------------------------------------
class Masterclass {
  const Masterclass({
    required this.id,
    required this.title,
    required this.listDesc,
    required this.longDesc,
    required this.price,
    required this.facts,
    required this.coaches,
    required this.learn,
    this.testimonials = const [],
    this.faqs = const [],
    this.badge,
    this.badgeIsCoral = true,
    this.listChip,
    this.listChipIsCoral = false,
    this.featured = false,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText listDesc; // one-liner on the list/featured card
  final LocalizedText longDesc; // detail hero paragraph
  final String price; // "₹799"
  final List<QuickFact> facts;
  final List<Coach> coaches;
  final List<LocalizedText> learn;
  final List<Testimonial> testimonials;
  final List<Faq> faqs;
  final LocalizedText? badge; // hero/featured pill, e.g. "Most-booked at 30 weeks"
  final bool badgeIsCoral;
  final LocalizedText? listChip; // small chip in the "more" list
  final bool listChipIsCoral;
  final bool featured;
}

final List<Masterclass> kMasterclasses = [
  Masterclass(
    id: 'mc_birth',
    featured: true,
    title: _same('Birth Confidence Masterclass'),
    badge: _t('Most-booked at 30 weeks', '30 हफ़्ते पर सबसे ज़्यादा बुक होने वाली'),
    price: '₹799',
    listDesc:
        _t('What labour really feels like: breathing, pain relief, C-section prep, and emotional readiness. 90 min live + lifetime recording.', 'लेबर असल में कैसा लगता है: साँस, दर्द से राहत, C-section की तैयारी, और मन की तैयारी। 90 min live + recording हमेशा के लिए।'),
    longDesc:
        _t('What labour really feels like - breathing, pain relief, C-section prep, and the emotional readiness no one talks about. One live evening that changes how you walk into the delivery room.', 'लेबर असल में कैसा लगता है — साँस, दर्द से राहत, C-section की तैयारी, और वह मन की तैयारी जिसकी बात कोई नहीं करता। एक live शाम, जो बदल देती है कि आप delivery room में किस भरोसे के साथ जाती हैं।'),
    facts: [QuickFact(_same('90 min'), _t('live', 'लाइव')), QuickFact(_t('Sun 13 Jul', 'रवि 13 Jul'), _t('8:00 pm', 'रात 8:00')), QuickFact(_t('Forever', 'हमेशा के लिए'), _t('recording', 'रिकॉर्डिंग'))],
    coaches: [
      Coach(_same('Dr. Ananya Rao'), _t('Obstetrician · 15 years', 'Obstetrician · 15 साल'),
          _t("Has delivered over 3,000 babies across Delhi's leading hospitals. Known for calm, plain-language guidance.", 'दिल्ली के बड़े अस्पतालों में 3,000 से ज़्यादा शिशुओं की डिलीवरी करा चुकी हैं। शांत, सीधी-सादी भाषा में समझाने के लिए जानी जाती हैं।')),
      Coach(_same('Deepti Sharma'), _t('Doula & birth coach', 'Doula और birth coach'),
          _t('Has supported 400+ births. Brings the emotional side - fear, partners, and staying in control.', '400+ जन्मों में साथ रह चुकी हैं। भावनात्मक पक्ष सामने लाती हैं — डर, partner, और खुद पर पकड़ बनाए रखना।')),
    ],
    learn: [
      _t('A clear picture of each stage of labour, minute by minute.', 'लेबर के हर चरण की साफ़ तस्वीर, मिनट-दर-मिनट।'),
      _t('Breathing techniques you can actually use through a contraction.', 'साँस की वे तकनीकें जो contraction के बीच सच में काम आती हैं।'),
      _t('The real pros and cons of epidural, natural and C-section.', 'epidural, normal और C-section — तीनों के असली फ़ायदे और नुक़सान।'),
      _t('How to write a birth plan your hospital will respect.', 'ऐसा birth plan कैसे लिखें जिसे आपका अस्पताल माने।'),
    ],
    testimonials: [
      Testimonial(
          _t('"I went in terrified and came out feeling like I could actually do this. The breathing section alone was worth it."', '"मैं डरी हुई गई थी और लौटी यह भरोसा लेकर कि मैं यह कर सकती हूँ। अकेले साँस वाला हिस्सा ही पूरे पैसे वसूल था।"'),
          _same('Ananya P.'),
          _t('delivered March 2025', 'डिलीवरी March 2025')),
      Testimonial(_t('"My husband finally understood how to help. We watched the recording together twice."', '"मेरे पति को आख़िरकार समझ आया कि मदद कैसे करनी है। हमने recording साथ में दो बार देखी।"'),
          _same('Ritika M.'), _t('34 weeks', '34 हफ़्ते')),
    ],
    faqs: [
      Faq(_t("What if I can't attend live?", 'अगर मैं live नहीं जुड़ पाई तो?'),
          _t("The full recording lands in your library within 24 hours, and it's yours forever.", 'पूरी recording 24 घंटे के भीतर आपकी library में आ जाती है, और हमेशा के लिए आपकी रहती है।')),
      Faq(_t('Is this okay at 30 weeks?', 'क्या 30 हफ़्ते पर यह ठीक है?')),
      Faq(_t('Can my partner join?', 'क्या मेरे partner भी जुड़ सकते हैं?')),
      Faq(_t('Is it in Hindi or English?', 'यह हिंदी में है या अंग्रेज़ी में?')),
    ],
  ),
  Masterclass(
    id: 'mc_playbook',
    title: _same('Pregnancy Playbook Workshop'),
    price: '₹699',
    listChip: _t('Great to catch up on', 'पीछे से देखने के लिए बढ़िया'),
    listDesc: _t('The whole journey, trimester by trimester, with a practical action plan.', 'पूरा सफ़र, तिमाही दर तिमाही, और साथ में एक काम आने वाला action plan।'),
    longDesc:
        _t('The whole pregnancy journey, trimester by trimester - what to expect, how to prepare in body and mind, the common fears addressed head-on, and a practical action plan you will actually use.', 'गर्भावस्था का पूरा सफ़र, तिमाही दर तिमाही — क्या होने वाला है, शरीर और मन को कैसे तैयार करें, आम डरों का सीधा जवाब, और एक ऐसा action plan जो आप सच में इस्तेमाल करेंगी।'),
    facts: [QuickFact(_same('120 min'), _t('recorded', 'रिकॉर्डेड')), QuickFact(_t('On demand', 'जब चाहें'), _t('anytime', 'कभी भी')), QuickFact(_t('Forever', 'हमेशा के लिए'), _t('access', 'पहुँच'))],
    coaches: [
      Coach(_same('Deepti Sharma'), _t('Doula & birth coach', 'Doula और birth coach'),
          _t('Distils a whole pregnancy into a calm, do-this-next plan - warm, practical, and refreshingly non-preachy.', 'पूरी गर्भावस्था को एक शांत, "अब यह करें" वाले plan में समेट देती हैं — गर्मजोशी से भरी, काम की, और बिना कोई उपदेश दिए।')),
    ],
    learn: [
      _t('A month-by-month map of your pregnancy.', 'आपकी गर्भावस्था का महीने-दर-महीने नक़्शा।'),
      _t('How to prepare your body and your mind for each trimester.', 'हर तिमाही के लिए शरीर और मन को कैसे तैयार करें।'),
      _t('The fears no one talks about - named and addressed.', 'वे डर जिनकी बात कोई नहीं करता — नाम लेकर, जवाब के साथ।'),
      _t('A practical, week-by-week action plan.', 'हफ़्ते-दर-हफ़्ते का काम आने वाला action plan।'),
    ],
    testimonials: [
      Testimonial(_t('"Finally something that told me what to actually do, not just what to worry about."', '"आख़िरकार कुछ ऐसा जिसने बताया कि करना क्या है, सिर्फ़ यह नहीं कि चिंता किस बात की करनी है।"'),
          _same('Sneha K.'), _t('18 weeks', '18 हफ़्ते')),
    ],
    faqs: [
      Faq(_t('When should I take this?', 'इसे कब लेना चाहिए?'),
          _t("It's built for early second trimester, but it's useful at any stage - you keep lifetime access.", 'यह दूसरी तिमाही की शुरुआत के लिए बना है, पर किसी भी पड़ाव पर काम आता है — access हमेशा के लिए आपका रहता है।')),
      Faq(_t('Is there a workbook?', 'क्या इसके साथ workbook मिलती है?')),
    ],
  ),
  Masterclass(
    id: 'mc_first100',
    title: _same('The First 100 Days with Baby'),
    price: '₹999',
    listChip: _t('Coming up next', 'अगला यही है'),
    listChipIsCoral: true,
    listDesc: _t('Newborn survival: feeding, sleep, and the fourth trimester.', 'नवजात के दिन संभालना: दूध पिलाना, नींद, और चौथी तिमाही।'),
    longDesc:
        _t('Newborn survival, made calm: feeding rhythms, decoding those early sleep patterns, the fourth-trimester emotional rollercoaster, and setting up real help at home.', 'नवजात के दिन, शांति से: दूध पिलाने की लय, शुरुआती नींद के तौर-तरीक़े समझना, चौथी तिमाही का भावनात्मक उतार-चढ़ाव, और घर पर असली मदद खड़ी करना।'),
    facts: [QuickFact(_same('120 min'), _t('live', 'लाइव')), QuickFact(_t('Sat 26 Jul', 'शनि 26 Jul'), _t('6:00 pm', 'शाम 6:00')), QuickFact(_t('Forever', 'हमेशा के लिए'), _t('recording', 'रिकॉर्डिंग'))],
    coaches: [
      Coach(_same('Dr. Kabir Rao'), _t('Paediatrician · 12 years', 'Paediatrician · 12 साल'),
          _t('Guides new parents through the newborn weeks with steady, no-panic advice grounded in Indian homes.', 'नए माता-पिता को नवजात के हफ़्तों से पार लगाते हैं — भारतीय घरों को समझने वाली, शांत और घबराहट-रहित सलाह के साथ।')),
      Coach(_same('Deepti Sharma'), _t('Doula & birth coach', 'Doula और birth coach'),
          _t('Covers the mother\'s side of the fourth trimester - recovery, mood, and asking for help.', 'चौथी तिमाही का माँ वाला पक्ष सँभालती हैं — रिकवरी, मन का हाल, और मदद माँगना।')),
    ],
    learn: [
      _t('Reading your newborn\'s feeding and hunger cues.', 'अपने नवजात के भूख और दूध के इशारे पढ़ना।'),
      _t('Realistic newborn sleep - and how to protect your own.', 'नवजात की नींद की असली तस्वीर — और अपनी नींद कैसे बचाएँ।'),
      _t('The fourth trimester for you: recovery and mood.', 'चौथी तिमाही आपके लिए: रिकवरी और मन का हाल।'),
      _t('Setting up help in a joint family without friction.', 'संयुक्त परिवार में बिना खटपट के मदद का इंतज़ाम।'),
    ],
    faqs: [
      Faq(_t('Is this before or after birth?', 'यह जन्म से पहले है या बाद में?'),
          _t('Take it now to feel ready - most mothers watch it again in the first week with the recording.', 'अभी ले लें ताकि तैयार महसूस करें — ज़्यादातर माँएँ पहले हफ़्ते में recording से इसे दोबारा देखती हैं।')),
    ],
  ),
  Masterclass(
    id: 'mc_bf',
    title: _same('Breastfeeding Basics'),
    price: '₹699',
    listDesc: _t('Latch, supply, and the first week - before baby arrives.', 'Latch, दूध की सप्लाई, और पहला हफ़्ता — शिशु के आने से पहले।'),
    longDesc:
        _t('Latch, supply, and the first tender week - everything you need to feel ready to breastfeed before baby arrives, from an IBCLC lactation expert.', 'Latch, दूध की सप्लाई, और वह नाज़ुक पहला हफ़्ता — शिशु के आने से पहले स्तनपान के लिए तैयार महसूस करने को जो चाहिए, एक IBCLC lactation विशेषज्ञ से।'),
    facts: [QuickFact(_same('75 min'), _t('live', 'लाइव')), QuickFact(_t('Wed 16 Jul', 'बुध 16 Jul'), _t('7:00 pm', 'शाम 7:00')), QuickFact(_t('Forever', 'हमेशा के लिए'), _t('recording', 'रिकॉर्डिंग'))],
    coaches: [
      Coach(_same('Sana Khan'), _same('Lactation Consultant · IBCLC'),
          _t('An IBCLC who makes the first week feel far less daunting - practical, gentle, and judgement-free.', 'एक IBCLC जो पहले हफ़्ते का डर काफ़ी कम कर देती हैं — काम की बातें, नरमी से, बिना किसी फ़ैसले के।')),
    ],
    learn: [
      _t('What a good latch looks and feels like.', 'अच्छा latch कैसा दिखता है और कैसा लगता है।'),
      _t('How milk supply really works - and how to protect it.', 'दूध की सप्लाई असल में कैसे बनती है — और उसे कैसे बनाए रखें।'),
      _t('Troubleshooting the tricky first week.', 'मुश्किल पहले हफ़्ते की दिक़्क़तें सुलझाना।'),
      _t('Pumping and return-to-work basics.', 'Pumping और काम पर लौटने की बुनियादी बातें।'),
    ],
    faqs: [
      Faq(_t('Can I take this before the baby is here?', 'क्या मैं शिशु के आने से पहले यह ले सकती हूँ?'),
          _t('Yes - preparing antenatally is exactly when it helps most.', 'हाँ — जन्म से पहले तैयारी करना ही वह समय है जब यह सबसे ज़्यादा काम आता है।')),
    ],
  ),
];

Masterclass? masterclassById(String id) {
  for (final m in kMasterclasses) {
    if (m.id == id) return m;
  }
  return null;
}

// ---- specialists (1:1 consultations) ----------------------------------------
class Specialist {
  const Specialist({
    required this.id,
    required this.icon,
    required this.role,
    required this.name,
    required this.cred,
    required this.fromPrice,
    required this.consultPrice,
    required this.rating,
    required this.desc,
    required this.about,
    required this.helps,
    required this.reviews,
    this.next,
    this.slots = const ['6:00 pm', '6:30 pm', '7:15 pm', '8:00 pm'],
  });

  final String id;
  final IconData icon;
  final LocalizedText role; // "Obstetrician"
  final LocalizedText name; // "Dr. Ananya Rao"
  final LocalizedText cred; // "MBBS, MD (OB-GYN)" / "RD"
  final LocalizedText fromPrice; // "from ₹999"
  final String consultPrice; // "₹999"
  final String rating; // "★ 4.9"
  final LocalizedText desc; // one-liner on the list
  final LocalizedText about;
  final List<LocalizedText> helps;
  final List<Review> reviews;
  final LocalizedText? next; // "Next: today 6pm"
  final List<String> slots;
}

final List<Specialist> kSpecialists = [
  Specialist(
    id: 'sp_ob',
    icon: Icons.medical_services_outlined,
    role: _same('Obstetrician'),
    name: _same('Dr. Ananya Rao'),
    cred: _t('MBBS, MD (OB-GYN) · 15 yrs', 'MBBS, MD (OB-GYN) · 15 साल'),
    fromPrice: _t('from ₹999', '₹999 से'),
    consultPrice: '₹999',
    rating: '★ 4.9',
    next: _t('Next: today 6pm', 'अगला: आज 6pm'),
    desc: _t("Your questions, a specialist's answer.", 'आपके सवाल, एक विशेषज्ञ का जवाब।'),
    about:
        _t("Senior obstetrician at a leading Delhi hospital, with over 3,000 deliveries. Mothers describe her as calm, unhurried, and refreshingly straight-talking. She's the expert behind ParentVeda's Birth Confidence Masterclass.", 'दिल्ली के एक बड़े अस्पताल में वरिष्ठ obstetrician, 3,000 से ज़्यादा डिलीवरी का अनुभव। माँएँ उन्हें शांत, बिना जल्दबाज़ी वाली और सीधी बात करने वाली बताती हैं। ParentVeda की Birth Confidence Masterclass उन्हीं की है।'),
    helps: [
      _t('Reading and understanding your scan reports', 'अपनी scan report पढ़ना और समझना'),
      _t('Birth-plan questions and delivery options', 'birth plan के सवाल और डिलीवरी के विकल्प'),
      _t('Third-trimester aches, movements and warning signs', 'तीसरी तिमाही के दर्द, शिशु की हलचल और चेतावनी के संकेत'),
    ],
    reviews: [
      Review(_same('Priya S.'), _t('30 weeks', '30 हफ़्ते'), _t('"She never rushed me. I finally understood my reports."', '"उन्होंने कभी जल्दी नहीं मचाई। मुझे आख़िरकार अपनी report समझ आईं।"')),
      Review(_same('Neha R.'), _t('delivered Feb 2025', 'डिलीवरी Feb 2025'), _t('"Calm and clear. Worth every rupee."', '"शांत और साफ़। एक-एक रुपया वसूल।"')),
    ],
  ),
  Specialist(
    id: 'sp_nutrition',
    icon: Icons.restaurant_outlined,
    role: _same('Prenatal Nutritionist'),
    name: _same('Ritu Malhotra'),
    cred: _t('RD · 10 yrs', 'RD · 10 साल'),
    fromPrice: _t('from ₹599', '₹599 से'),
    consultPrice: '₹599',
    rating: '★ 4.8',
    desc: _t('Eat right for you and baby.', 'अपने और शिशु के लिए सही खाना।'),
    about:
        _t('A registered dietitian who makes pregnancy nutrition simple and Indian-kitchen-friendly - no fads, no imported superfoods, just food that works for you and baby.', 'एक registered dietitian जो गर्भावस्था का पोषण आसान और भारतीय रसोई के हिसाब से बनाती हैं — कोई फ़ैशन नहीं, कोई विदेशी superfood नहीं, बस वह खाना जो आपके और शिशु के लिए काम करे।'),
    helps: [
      _t('Trimester-wise diet plans built around Indian meals', 'भारतीय खाने पर बने तिमाही-वार diet plan'),
      _t('Managing nausea, acidity and cravings', 'मतली, एसिडिटी और cravings को संभालना'),
      _t('Gestational-diabetes-friendly eating', 'Gestational diabetes के हिसाब से खाना'),
    ],
    reviews: [
      Review(_same('Aditi V.'), _t('22 weeks', '22 हफ़्ते'), _t('"Practical desi food swaps, not a boring diet chart."', '"काम के देसी खाने के बदल, कोई उबाऊ diet chart नहीं।"')),
      Review(_same('Meghna T.'), _t('delivered Jan 2025', 'डिलीवरी Jan 2025'), _t('"My sugar levels finally settled."', '"मेरा शुगर आख़िरकार सँभल गया।"')),
    ],
  ),
  Specialist(
    id: 'sp_lactation',
    icon: Icons.child_care_outlined,
    role: _same('Lactation Consultant'),
    name: _same('Sana Khan'),
    cred: _t('IBCLC · 8 yrs', 'IBCLC · 8 साल'),
    fromPrice: _t('from ₹799', '₹799 से'),
    consultPrice: '₹799',
    rating: '★ 4.9',
    desc: _t('Prepare to breastfeed before baby arrives.', 'शिशु के आने से पहले स्तनपान की तैयारी।'),
    about:
        _t('An IBCLC who helps you prepare to breastfeed before the baby arrives - so day one feels a little less daunting, and you know what a good start looks like.', 'एक IBCLC जो शिशु के आने से पहले स्तनपान की तैयारी कराती हैं — ताकि पहला दिन थोड़ा कम डरावना लगे, और आपको पता हो कि अच्छी शुरुआत कैसी होती है।'),
    helps: [
      _t('Getting ready to breastfeed before birth', 'जन्म से पहले स्तनपान की तैयारी'),
      _t('What a good latch looks and feels like', 'अच्छा latch कैसा दिखता और कैसा लगता है'),
      _t('Building and protecting your milk supply', 'दूध की सप्लाई बनाना और बनाए रखना'),
    ],
    reviews: [
      Review(_same('Ishita R.'), _t('36 weeks', '36 हफ़्ते'), _t('"I felt so much calmer about feeding after one call."', '"एक call के बाद दूध पिलाने को लेकर मैं बहुत शांत महसूस करने लगी।"')),
      Review(_same('Pooja M.'), _t('delivered Mar 2025', 'डिलीवरी Mar 2025'), _t('"Wish I had spoken to her even earlier."', '"काश मैंने उनसे और पहले बात की होती।"')),
    ],
  ),
  Specialist(
    id: 'sp_counsellor',
    icon: Icons.psychology_outlined,
    role: _same('Prenatal Counsellor'),
    name: _same('Dr. Neha Verma'),
    cred: _t('Clinical Psychologist · 11 yrs', 'Clinical Psychologist · 11 साल'),
    fromPrice: _t('from ₹899', '₹899 से'),
    consultPrice: '₹899',
    rating: '★ 5.0',
    desc: _t('Anxiety, mood, and the mental side of pregnancy.', 'घबराहट, मन का हाल, और गर्भावस्था का मानसिक पक्ष।'),
    about:
        _t('A clinical psychologist who holds space for the parts of pregnancy that are hard to say out loud - anxiety, mood swings, and the quiet weight of expectation.', 'एक clinical psychologist जो गर्भावस्था की उन बातों के लिए जगह बनाती हैं जो कहते नहीं बनतीं — घबराहट, मन के उतार-चढ़ाव, और उम्मीदों का चुपचाप बोझ।'),
    helps: [
      _t('Pregnancy anxiety and intrusive worries', 'गर्भावस्था की घबराहट और बार-बार आती चिंताएँ'),
      _t('Mood changes and low days', 'मन का बदलना और उदास दिन'),
      _t('Fears about birth and becoming a mother', 'जन्म और माँ बनने को लेकर डर'),
    ],
    reviews: [
      Review(_same('Ritika S.'), _t('28 weeks', '28 हफ़्ते'), _t('"She made me feel normal, not broken."', '"उन्होंने मुझे महसूस कराया कि मैं ठीक हूँ, टूटी हुई नहीं।"')),
      Review(_same('Kavita N.'), _t('delivered Feb 2025', 'डिलीवरी Feb 2025'), _t('"Gentle, warm, and genuinely helpful."', '"सौम्य, गर्मजोशी भरी, और सच में मददगार।"')),
    ],
  ),
  Specialist(
    id: 'sp_physio',
    icon: Icons.accessibility_new_rounded,
    role: _same('Physiotherapist'),
    name: _same('Kavya Menon'),
    cred: _t("Women's-health PT · 9 yrs", 'महिला-स्वास्थ्य PT · 9 साल'),
    fromPrice: _t('from ₹699', '₹699 से'),
    consultPrice: '₹699',
    rating: '★ 4.7',
    desc: _t('Back pain, pelvic floor, posture.', 'कमर दर्द, pelvic floor, और बैठने-चलने का ढंग।'),
    about:
        _t('A women\'s-health physiotherapist who eases the aches pregnancy brings and prepares your body for birth and recovery - with simple moves you can actually keep up.', 'महिला-स्वास्थ्य की physiotherapist, जो गर्भावस्था के दर्द कम करती हैं और आपके शरीर को जन्म और रिकवरी के लिए तैयार करती हैं — ऐसी आसान क़वायदों से जो आप सच में जारी रख पाएँगी।'),
    helps: [
      _t('Back, hip and pelvic-girdle pain', 'कमर, कूल्हे और pelvic-girdle का दर्द'),
      _t('Pelvic-floor prep for birth and recovery', 'जन्म और रिकवरी के लिए pelvic-floor की तैयारी'),
      _t('Safe posture and movement day to day', 'रोज़मर्रा में सुरक्षित मुद्रा और चलना-फिरना'),
    ],
    reviews: [
      Review(_same('Divya P.'), _t('31 weeks', '31 हफ़्ते'), _t('"My back pain eased within a week of her exercises."', '"उनकी exercise से एक हफ़्ते में ही मेरा कमर दर्द कम हो गया।"')),
      Review(_same('Anjali K.'), _t('delivered Dec 2024', 'डिलीवरी Dec 2024'), _t('"The pelvic-floor prep made recovery easier."', '"pelvic-floor की तैयारी ने रिकवरी आसान कर दी।"')),
    ],
  ),
];

Specialist? specialistById(String id) {
  for (final s in kSpecialists) {
    if (s.id == id) return s;
  }
  return null;
}

// ---- cohort programs --------------------------------------------------------
class Cohort {
  const Cohort({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.desc,
    required this.whatsInside,
    this.start,
    this.seats,
    this.recommended,
    this.coachName,
    this.forWhen,
    this.schedule = const [],
    this.reviews = const [],
    this.featured = false,
  });

  final String id;
  final LocalizedText name;
  final String price;
  final LocalizedText duration; // "4 weeks"
  final LocalizedText desc;
  final List<LocalizedText> whatsInside;
  final LocalizedText? start; // "starts Mon 6 Jul"
  final LocalizedText? seats; // "32 of 100 seats left"
  final LocalizedText? recommended; // "Recommended · 30–34 weeks"
  final LocalizedText? coachName; // "Meera Nair"
  final LocalizedText? forWhen; // list meta e.g. "for 6–13 weeks"
  final List<LocalizedText> schedule; // week-by-week
  final List<Review> reviews;
  final bool featured;
}

final List<Cohort> kCohorts = [
  Cohort(
    id: 'ch_birthready',
    featured: true,
    name: _same('Birth-Ready Bootcamp'),
    price: '₹6,999',
    duration: _t('4 weeks', '4 हफ़्ते'),
    start: _t('starts Mon 6 Jul', 'शुरू सोम 6 Jul'),
    seats: _t('32 of 100 seats left', '100 में से 32 सीटें बाक़ी'),
    recommended: _t('Recommended · 30–34 weeks', 'सुझाया गया · 30–34 हफ़्ते'),
    coachName: _same('Meera Nair'),
    desc:
        _t('Labour prep, breathing, and partner training - a live coach plus a peer group of mums due right around when you are.', 'लेबर की तैयारी, साँस, और partner की ट्रेनिंग — एक live कोच, और वे माँएँ जिनकी डिलीवरी लगभग आपके साथ है।'),
    whatsInside: [
      _t('4 live weekly sessions with Meera', 'Meera के साथ 4 live साप्ताहिक session'),
      _t('A small peer group of 30–34-week mums', '30–34 हफ़्ते की माँओं का एक छोटा समूह'),
      _t('Weekly homework + a birth-plan template', 'हर हफ़्ते homework + एक birth-plan template'),
      _t('A private WhatsApp group', 'एक private WhatsApp group'),
    ],
    schedule: [
      _t('Week 1 · Understanding labour, start to finish', 'Week 1 · लेबर को शुरू से आख़िर तक समझना'),
      _t('Week 2 · Breathing and coping techniques', 'Week 2 · साँस और सँभलने की तकनीकें'),
      _t('Week 3 · Positions, movement and your partner', 'Week 3 · मुद्राएँ, हलचल और आपके partner'),
      _t('Week 4 · Your birth plan and the big day', 'Week 4 · आपका birth plan और वह बड़ा दिन'),
    ],
    reviews: [
      Review(_same('Shreya M.'), _t('delivered Apr 2025', 'डिलीवरी Apr 2025'), _t('"The peer group got me through the last month."', '"आख़िरी महीना उस समूह के सहारे ही निकला।"')),
    ],
  ),
  Cohort(
    id: 'ch_first_tri',
    name: _same('First-Trimester Foundations'),
    price: '₹4,999',
    duration: _t('3 weeks', '3 हफ़्ते'),
    forWhen: _t('for 6–13 weeks', '6–13 हफ़्तों के लिए'),
    coachName: _same('Deepti Sharma'),
    desc: _t('Steady your first trimester - manage symptoms, quiet the early fears, and start pregnancy in control.', 'पहली तिमाही को सँभालें — लक्षणों को संभालना, शुरुआती डर को शांत करना, और गर्भावस्था की शुरुआत भरोसे के साथ करना।'),
    whatsInside: [
      _t('3 live weekly sessions', '3 live साप्ताहिक session'),
      _t('A first-trimester peer group', 'पहली तिमाही की माँओं का समूह'),
      _t('Symptom + nutrition toolkit', 'लक्षण + पोषण toolkit'),
      _t('A private WhatsApp group', 'एक private WhatsApp group'),
    ],
    schedule: [
      _t('Week 1 · Symptoms and what helps', 'Week 1 · लक्षण, और उनमें क्या काम आता है'),
      _t('Week 2 · Eating well when nothing appeals', 'Week 2 · जब कुछ भी अच्छा न लगे, तब सही खाना'),
      _t('Week 3 · Early fears and your first scan', 'Week 3 · शुरुआती डर और आपका पहला scan'),
    ],
  ),
  Cohort(
    id: 'ch_fit',
    name: _same('Fit & Strong Pregnancy'),
    price: '₹7,999',
    duration: _t('6 weeks', '6 हफ़्ते'),
    coachName: _same('Sana Kapoor'),
    desc: _t('A guided prenatal fitness cohort - safe, progressive workouts scaled to your trimester by a certified coach.', 'एक guided prenatal fitness cohort — सुरक्षित, धीरे-धीरे बढ़ते workout, जो एक प्रमाणित कोच आपकी तिमाही के हिसाब से ढालती हैं।'),
    whatsInside: [
      _t('6 weeks of guided workouts', '6 हफ़्ते के guided workout'),
      _t('Trimester-safe progressions', 'तिमाही के हिसाब से सुरक्षित बढ़त'),
      _t('Live form checks with the coach', 'कोच के साथ live form check'),
      _t('A private WhatsApp group', 'एक private WhatsApp group'),
    ],
  ),
  Cohort(
    id: 'ch_fourth_tri',
    name: _same('Fourth-Trimester Prep'),
    price: '₹6,499',
    duration: _t('4 weeks', '4 हफ़्ते'),
    coachName: _same('Dr. Kabir Rao'),
    desc: _t('Get ready for the newborn weeks before they arrive - feeding, sleep, recovery, and support at home.', 'नवजात के हफ़्तों की तैयारी उनके आने से पहले — दूध पिलाना, नींद, रिकवरी, और घर पर मदद।'),
    whatsInside: [
      _t('4 live weekly sessions', '4 live साप्ताहिक session'),
      _t('A due-soon peer group', 'जल्द डिलीवरी वाली माँओं का समूह'),
      _t('Newborn-setup checklist', 'नवजात की तैयारी की checklist'),
      _t('A private WhatsApp group', 'एक private WhatsApp group'),
    ],
  ),
];

Cohort? cohortById(String id) {
  for (final c in kCohorts) {
    if (c.id == id) return c;
  }
  return null;
}

// ---- yoga sessions ----------------------------------------------------------
//  Sessions are now month-tagged (month 1-9) so the Yoga screen can open on the
//  mother's current month and offer Month 1-9 tabs. The original untagged
//  five-session list is kept below (commented) for reference/revert.
class YogaSession {
  const YogaSession(this.id, this.title, this.duration, this.focus, this.blurb,
      {this.month = 1});
  final String id;
  final LocalizedText title;
  final LocalizedText duration; // "18 min"
  final LocalizedText focus; // "opening"
  final LocalizedText blurb;
  final int month; // 1-9, the pregnancy month this session is meant for
}

// // ---- original untagged list (pre month-tabs) -----------------------------
// const List<YogaSession> kYogaSessions = [
//   YogaSession('yg_hips', 'Hips & pelvis opener', '18 min', 'opening',
//       'Gentle openers to ease tightness in the hips and pelvis and make room as baby grows.'),
//   YogaSession('yg_back', 'Lower-back relief', '15 min', 'relief',
//       'Slow, supported movement to unload a tired lower back at the end of the day.'),
//   YogaSession('yg_breath', 'Breathing for labour', '12 min', 'breath',
//       'Practise the calm, steady breath that will carry you through contractions.'),
//   YogaSession('yg_evening', 'Gentle evening wind-down', '20 min', 'calm',
//       'A soothing sequence to quiet the body and mind before sleep.'),
//   YogaSession('yg_legsup', 'Legs-up restorative', '10 min', 'restore',
//       'A restful, restorative pose to ease swelling and reset your nervous system.'),
// ];

// TODO: month grouping below is a sensible approximation - once sessions carry a
// real trimester/week range from the content team, distribute them precisely.
final List<YogaSession> kYogaSessions = [
  // Month 1
  YogaSession('yg_m1_settle', _t('Settling-in gentle flow', 'शुरुआत का सौम्य flow'), _same('12 min'), _t('grounding', 'स्थिरता'),
      _t('A soft, grounding sequence for the very first weeks - nothing strenuous, just breath and ease.', 'बिलकुल शुरुआती हफ़्तों के लिए एक नरम, ठहराव देने वाला क्रम — कुछ भी ज़ोरदार नहीं, बस साँस और सुकून।'),
      month: 1),
  YogaSession('yg_m1_breath', _t('Breath awareness basics', 'साँस को पहचानने की बुनियाद'), _same('10 min'), _t('breath', 'साँस'),
      _t('Meet the calm, steady breath you will build on all pregnancy long.', 'उस शांत, ठहरी हुई साँस से मिलिए जिस पर आप पूरी गर्भावस्था टिकी रहेंगी।'),
      month: 1),
  // Month 2
  YogaSession('yg_m2_nausea', _t('Ease for nausea days', 'मतली वाले दिनों की राहत'), _same('12 min'), _t('relief', 'राहत'),
      _t('Slow, low movements and breathing to settle a queasy first-trimester tummy.', 'धीमी, नीचे रहकर की जाने वाली हरकतें और साँस — पहली तिमाही के उलझे पेट को शांत करने के लिए।'),
      month: 2),
  YogaSession('yg_m2_stretch', _t('Gentle full-body stretch', 'पूरे शरीर की सौम्य stretch'), _same('15 min'), _t('opening', 'खुलाव'),
      _t('Wake up stiff joints kindly, keeping everything within a safe early range.', 'अकड़े जोड़ों को नरमी से जगाएँ, सब कुछ शुरुआती दिनों की सुरक्षित सीमा में रखते हुए।'),
      month: 2),
  // Month 3
  YogaSession('yg_m3_hipsfound', _t('Hip-opener foundations', 'कूल्हे खोलने की बुनियाद'), _same('16 min'), _t('opening', 'खुलाव'),
      _t('Begin the hip work that makes room as baby grows - built up slowly and safely.', 'कूल्हों का वह काम शुरू करें जो शिशु के बढ़ने पर जगह बनाता है — धीरे-धीरे और सुरक्षित तरीक़े से।'),
      month: 3),
  YogaSession('yg_m3_calm', _t('Calm & steady wind-down', 'शांत और ठहरा हुआ समापन'), _same('14 min'), _t('calm', 'शांति'),
      _t('A soothing close to the first trimester to quiet body and mind.', 'पहली तिमाही का सुकून भरा समापन, शरीर और मन को शांत करने के लिए।'),
      month: 3),
  // Month 4
  YogaSession('yg_m4_energy', _t('Second-trimester energy flow', 'दूसरी तिमाही का ऊर्जा flow'), _same('18 min'), _t('strength', 'ताक़त'),
      _t('As energy returns, a gently strengthening flow to feel capable and strong.', 'जैसे-जैसे ऊर्जा लौटती है, एक सौम्य मज़बूती वाला flow — ताकि आप सक्षम और मज़बूत महसूस करें।'),
      month: 4),
  YogaSession('yg_m4_posture', _t('Posture & alignment', 'मुद्रा और सीध'), _same('15 min'), _t('align', 'सीध'),
      _t('Simple work to carry a growing bump with an easy, supported posture.', 'बढ़ते bump को आसान, सहारे वाली मुद्रा में सँभालने के लिए सरल अभ्यास।'),
      month: 4),
  // Month 5
  YogaSession('yg_m5_back', _t('Back-care essentials', 'कमर की देखभाल की ज़रूरी बातें'), _same('15 min'), _t('relief', 'राहत'),
      _t('Supported movement to unload a tired lower back as your centre of gravity shifts.', 'जैसे-जैसे शरीर का संतुलन बदलता है, थकी हुई कमर का बोझ हल्का करने वाली सहारे भरी हरकतें।'),
      month: 5),
  YogaSession('yg_m5_balance', _t('Steady balance & core', 'ठहरा संतुलन और core'), _same('16 min'), _t('strength', 'ताक़त'),
      _t('Gentle balance and deep-core work, adapted for the mid-pregnancy body.', 'सौम्य संतुलन और गहरे core का अभ्यास, बीच की गर्भावस्था वाले शरीर के हिसाब से।'),
      month: 5),
  // Month 6
  YogaSession('yg_m6_hips', _t('Hips & pelvis opener', 'कूल्हे और pelvis खोलने वाला क्रम'), _same('18 min'), _t('opening', 'खुलाव'),
      _t('Gentle openers to ease tightness in the hips and pelvis and make room as baby grows.', 'कूल्हों और pelvis की जकड़न कम करने वाली सौम्य क़वायदें, ताकि शिशु के बढ़ने पर जगह बने।'),
      month: 6),
  YogaSession('yg_m6_evening', _t('Gentle evening wind-down', 'शाम का सौम्य समापन'), _same('20 min'), _t('calm', 'शांति'),
      _t('A soothing sequence to quiet the body and mind before sleep.', 'सोने से पहले शरीर और मन को शांत करने वाला सुकून भरा क्रम।'),
      month: 6),
  // Month 7
  YogaSession('yg_m7_hips', _t('Third-trimester hip release', 'तीसरी तिमाही में कूल्हों की जकड़न ढीली करना'), _same('18 min'), _t('opening', 'खुलाव'),
      _t('Deeper, supported hip openers to ease the tightness that builds in the third trimester.', 'गहरी, सहारे वाली कूल्हा खोलने की क़वायदें — तीसरी तिमाही में जमा होती जकड़न के लिए।'),
      month: 7),
  YogaSession('yg_m7_back', _t('Lower-back relief', 'कमर के निचले हिस्से को राहत'), _same('15 min'), _t('relief', 'राहत'),
      _t('Slow, supported movement to unload a tired lower back at the end of the day.', 'दिन के आख़िर में थकी कमर का बोझ हल्का करने वाली धीमी, सहारे भरी हरकतें।'),
      month: 7),
  YogaSession('yg_m7_breath', _t('Breathing for labour', 'लेबर के लिए साँस'), _same('12 min'), _t('breath', 'साँस'),
      _t('Practise the calm, steady breath that will carry you through contractions.', 'उस शांत, ठहरी साँस का अभ्यास करें जो contractions के दौरान आपको सँभालेगी।'),
      month: 7),
  // Month 8
  YogaSession('yg_m8_legsup', _t('Legs-up restorative', 'पैर ऊपर, पूरा आराम'), _same('10 min'), _t('restore', 'विश्राम'),
      _t('A restful, restorative pose to ease swelling and reset your nervous system.', 'सूजन कम करने और नसों को शांत करने वाली एक आरामदेह मुद्रा।'),
      month: 8),
  YogaSession('yg_m8_pelvic', _t('Pelvic-floor & birth prep', 'Pelvic floor और जन्म की तैयारी'), _same('16 min'), _t('prepare', 'तैयारी'),
      _t('Gentle pelvic-floor awareness and opening to prepare your body for birth.', 'pelvic floor की सौम्य पहचान और खुलाव, आपके शरीर को जन्म के लिए तैयार करने के लिए।'),
      month: 8),
  YogaSession('yg_m8_evening', _t('Gentle evening wind-down', 'शाम का सौम्य समापन'), _same('20 min'), _t('calm', 'शांति'),
      _t('A soothing sequence to quiet the body and mind before sleep.', 'सोने से पहले शरीर और मन को शांत करने वाला सुकून भरा क्रम।'),
      month: 8),
  // Month 9
  YogaSession('yg_m9_positions', _t('Labour positions practice', 'लेबर की मुद्राओं का अभ्यास'), _same('18 min'), _t('prepare', 'तैयारी'),
      _t('Rehearse the positions and swaying that help labour progress and ease pain.', 'उन मुद्राओं और झूलने का अभ्यास जो लेबर को आगे बढ़ाती हैं और दर्द कम करती हैं।'),
      month: 9),
  YogaSession('yg_m9_breath', _t('Final breathing rehearsal', 'साँस की आख़िरी रिहर्सल'), _same('12 min'), _t('breath', 'साँस'),
      _t('One more calm run-through of the breath that will carry you through the big day.', 'उस साँस का एक और शांत अभ्यास, जो उस बड़े दिन आपको सँभालेगी।'),
      month: 9),
  YogaSession('yg_m9_restore', _t('Deep rest & restore', 'गहरा आराम और बहाली'), _same('14 min'), _t('restore', 'विश्राम'),
      _t('A soft, restorative close for the final stretch - rest, release, and wait well.', 'आख़िरी दौर के लिए एक नरम, आराम भरा समापन — विश्राम, ढील, और सुकून से इंतज़ार।'),
      month: 9),
];

/// Sessions for a given pregnancy month (1-9).
List<YogaSession> yogaSessionsForMonth(int month) =>
    kYogaSessions.where((y) => y.month == month).toList();

// ---- birthing classes -------------------------------------------------------
class BirthingClass {
  const BirthingClass(this.number, this.title, this.duration, this.blurb, {this.free = false});
  final int number;
  final LocalizedText title;
  final LocalizedText duration; // "22 min video"
  final LocalizedText blurb;
  final bool free;
}

final List<BirthingClass> kBirthingClasses = [
  BirthingClass(1, _t('The stages of labour, demystified', 'लेबर के चरण, आसान भाषा में'), _same('22 min video'),
      _t('A calm walkthrough of early, active and transition labour - so nothing takes you by surprise.', 'शुरुआती, active और transition लेबर की शांत जानकारी — ताकि कुछ भी अचानक न लगे।'),
      free: true),
  BirthingClass(2, _t('Breathing & relaxation that actually works', 'साँस और आराम — जो सच में काम आता है'), _same('18 min video'),
      _t('The breathing and relaxation tools that genuinely help when contractions build.', 'साँस और आराम के वे तरीक़े जो contractions बढ़ने पर सच में मदद करते हैं।')),
  BirthingClass(3, _t('Positions & movement for an easier labour', 'आसान लेबर के लिए मुद्राएँ और हलचल'), _same('20 min video'),
      _t('How to move, sway and rest in positions that help labour progress and ease pain.', 'कैसे चलें, झूलें और ऐसी मुद्राओं में आराम करें जो लेबर को आगे बढ़ाएँ और दर्द कम करें।')),
  BirthingClass(4, _t('Pain relief - natural, epidural & C-section', 'दर्द से राहत — normal, epidural और C-section'), _same('24 min video'),
      _t('An honest look at every pain-relief option, so your choices are informed, not fearful.', 'दर्द से राहत के हर विकल्प पर एक ईमानदार नज़र, ताकि आपके फ़ैसले समझ से हों, डर से नहीं।')),
  BirthingClass(5, _t('Your partner as birth support', 'जन्म के समय आपके partner का साथ'), _same('16 min video'),
      _t('Exactly how your partner can help - from counter-pressure to knowing when to speak up.', 'आपके partner ठीक-ठीक कैसे मदद कर सकते हैं — कमर दबाने से लेकर यह जानने तक कि कब बोलना है।')),
  BirthingClass(6, _t('The golden hour - the first hour after birth', 'Golden hour — जन्म के बाद का पहला घंटा'), _same('15 min video'),
      _t('Skin-to-skin, the first feed, and what really happens in the precious first hour.', 'Skin-to-skin, पहला दूध, और उस क़ीमती पहले घंटे में असल में क्या होता है।')),
];

// ---- helpers used by detail screens -----------------------------------------
Color chipColorFor(bool coral) => coral ? kCoral : kPurple;
Color chipBgFor(bool coral) => coral ? kCoralTint : kPanel;

// =============================================================================
//  Courses & Cohorts - unified "V2" learning model (mirrors the post-pregnancy
//  merged "Courses & Masterclasses" experience, adapted to pregnancy data + the
//  mother/purple theme). One `PrepProgram` list folds recorded courses, live
//  cohorts and masterclasses into a single searchable/filterable catalogue with
//  a shared rich detail page and business-logic CTA. It reuses the existing
//  masterclass/cohort content (kMasterclasses / kCohorts) so nothing is
//  duplicated by hand; the old standalone screens are kept for revert.
// =============================================================================

// accent palette for program thumbnails/details
const Color _pViolet = kPurple;
const Color _pRose = kCoral;
const Color _pAmber = Color(0xFFC98A2B);
const Color _pBlue = Color(0xFF3E6DA6);
const Color _pTeal = Color(0xFF2E8B8B);
const Color _pPlum = Color(0xFF8E4585);

/// The three kinds a mother can learn from - the merge of the old tabs.
enum PrepKind { course, cohort, masterclass }

extension PrepKindX on PrepKind {
  LocalizedText get label => switch (this) {
        PrepKind.course => _same('Course'),
        PrepKind.cohort => _same('Live cohort'),
        PrepKind.masterclass => _same('Masterclass'),
      };
  LocalizedText get filterLabel => switch (this) {
        PrepKind.course => _same('Courses'),
        PrepKind.cohort => _same('Cohorts'),
        PrepKind.masterclass => _same('Masterclasses'),
      };
}

/// Where a program sits in its selling / delivery lifecycle. Drives the CTA.
enum PrepStatus { reserveOpen, available, ongoing, completed }

/// One self-paced lesson inside a recorded course.
class PrepLesson {
  const PrepLesson(this.title, this.minutes, {this.locked = false});
  final LocalizedText title;
  final int minutes;
  final bool locked;
}

/// One live block in a schedule (a cohort week / a masterclass evening).
class PrepSession {
  const PrepSession({required this.label, required this.title, this.when = const LocalizedText(en: '', hi: ''), this.points = const []});
  final LocalizedText label; // "Week 1" / "Live evening"
  final LocalizedText title;
  final LocalizedText when; // "Mon 21 & Thu 24 Jul · 8-9pm"
  final List<LocalizedText> points;
}

class PrepProgram {
  const PrepProgram({
    required this.id,
    required this.kind,
    required this.instructorName,
    required this.instructorRole,
    required this.instructorBio,
    required this.title,
    required this.subtitle,
    required this.topics,
    required this.accent,
    required this.price,
    required this.status,
    // const, not _t(): a default parameter value must be a constant
    // expression, and Dart has no const functions.
    this.priceNote = const LocalizedText(
        en: 'free on ParentVeda+', hi: 'ParentVeda+ पर मुफ़्त'),
    this.isLiveScheduled = false,
    this.startLabel,
    this.sessionTimes = const [],
    this.sessions = const [],
    this.seatsLeft,
    this.lessons = const [],
    this.durationLabel = const LocalizedText(en: '', hi: ''),
    this.about = const LocalizedText(en: '', hi: ''),
    this.rating = 4.9,
    this.reviewsLabel = const LocalizedText(en: '', hi: ''),
    this.covers = const [],
    this.takeaways = const [],
    this.reviews = const [],
    this.featured = false,
    this.recency = 0,
  });

  final String id;
  final PrepKind kind;
  final LocalizedText instructorName;
  final LocalizedText instructorRole;
  final LocalizedText instructorBio;
  final LocalizedText title;
  final LocalizedText subtitle;
  final List<LocalizedText> topics;
  final Color accent;
  final String price;
  final LocalizedText priceNote;
  final PrepStatus status;
  final bool isLiveScheduled;
  final LocalizedText? startLabel;
  final List<LocalizedText> sessionTimes;
  final List<PrepSession> sessions;
  final int? seatsLeft;
  final List<PrepLesson> lessons;
  final LocalizedText durationLabel;
  final LocalizedText about;
  final double rating;
  final LocalizedText reviewsLabel;
  final List<LocalizedText> covers;
  final List<LocalizedText> takeaways;
  final List<Review> reviews;
  final bool featured;
  final int recency;

  bool get isCohort => kind == PrepKind.cohort;
  bool get isLive => kind == PrepKind.cohort || isLiveScheduled;

  LocalizedText get heroTag {
    if (kind == PrepKind.cohort) return startLabel ?? _same('Live cohort');
    if (isLiveScheduled) return startLabel ?? _same('Live');
    return durationLabel.en.isNotEmpty
        ? durationLabel
        : _same('Recorded');
  }
}

/// The resolved primary action for a program, so no screen hand-rolls the rules.
class PrepCta {
  const PrepCta(this.label, {this.enabled = true, this.watch = false, this.note});
  final LocalizedText label;
  final bool enabled;
  final bool watch; // "Watch now" = play flow, not a pay sheet
  final LocalizedText? note;
}

/// The single source of truth for "what button does this program show".
PrepCta ctaForPrep(PrepProgram p) {
  switch (p.kind) {
    case PrepKind.cohort:
      switch (p.status) {
        case PrepStatus.reserveOpen:
          return PrepCta(_t('Join the next cohort', 'अगले cohort में जुड़ें'), note: _t('Small group · a real coach', 'छोटा समूह · एक असली कोच'));
        case PrepStatus.available:
          return PrepCta(_t('Start', 'शुरू करें'), note: _t("You're in - your cohort has begun", 'आप जुड़ चुकी हैं — आपका cohort शुरू हो गया है'));
        case PrepStatus.ongoing:
          return PrepCta(_t('Cohort in progress', 'Cohort चल रहा है'), enabled: false, note: _t('This run has started - reserve the next one', 'यह batch शुरू हो चुका है — अगला बुक कर लें'));
        case PrepStatus.completed:
          return PrepCta(_t('View recordings', 'Recordings देखें'), watch: true, note: _t('Yours to keep', 'हमेशा के लिए आपकी'));
      }
    case PrepKind.masterclass:
      if (p.isLiveScheduled) {
        switch (p.status) {
          case PrepStatus.reserveOpen:
            return PrepCta(_t('Reserve a seat', 'सीट रोक लें'), note: _t('Live seat - the recording is yours forever', 'Live सीट — recording हमेशा के लिए आपकी'));
          case PrepStatus.available:
          case PrepStatus.ongoing:
            return PrepCta(_t('Join live', 'Live जुड़ें'), note: _t('Recording lands in your library', 'Recording आपकी library में आ जाएगी'));
          case PrepStatus.completed:
            return PrepCta(_t('Buy recorded', 'Recorded लें'), note: _t('Watch anytime, yours forever', 'जब चाहें देखें, हमेशा के लिए आपकी'));
        }
      }
      switch (p.status) {
        case PrepStatus.reserveOpen:
          return PrepCta(_t('Reserve', 'रोक लें'), note: _t('Pre-book before it opens', 'खुलने से पहले बुक कर लें'));
        case PrepStatus.available:
        case PrepStatus.ongoing:
        case PrepStatus.completed:
          return PrepCta(_t('Buy', 'ख़रीदें'), note: _t('Recording lands in your library', 'Recording आपकी library में आ जाएगी'));
      }
    case PrepKind.course:
      switch (p.status) {
        case PrepStatus.reserveOpen:
          return PrepCta(_t('Reserve', 'रोक लें'), note: _t('Notify me when it opens', 'खुलते ही मुझे बताएँ'));
        case PrepStatus.available:
        case PrepStatus.ongoing:
        case PrepStatus.completed:
          return PrepCta(_t('Start watching', 'देखना शुरू करें'), watch: true, note: _t('Free with ParentVeda+ · lifetime access', 'ParentVeda+ के साथ मुफ़्त · हमेशा के लिए access'));
      }
  }
}

/// Week-number prefixes stripped off a cohort schedule line, one per
/// language. Kept as constants so the pair is visible together - it is
/// exactly the kind of thing that gets translated on one side only.
final RegExp _kWeekPrefixEn = RegExp(r'^Week \d+ · ');
final RegExp _kWeekPrefixHi = RegExp(r'^हफ़्ता \d+ · ');

/// The common topic vocabulary backing the clickable filter chips.
final List<LocalizedText> kPrepTopics = [
  _t('Birth & Labour', 'जन्म और लेबर'),
  _t('Breathing', 'साँस'),
  _t('Nutrition', 'पोषण'),
  _t('Breastfeeding', 'स्तनपान'),
  _t('Newborn', 'नवजात'),
  _same('Fitness'),
  _t('Mind & Mood', 'मन और मिज़ाज'),
  _t('First Trimester', 'पहली तिमाही'),
];

// ---- new recorded courses (authored) ----------------------------------------
final List<PrepProgram> _kPrepCourses = [
  PrepProgram(
    id: 'course_pregnancy_guide',
    kind: PrepKind.course,
    instructorName: _same('Dr. Ananya Rao'),
    instructorRole: _t('Obstetrician · 15 yrs', 'Obstetrician · 15 साल'),
    instructorBio:
        _t("Senior obstetrician with 3,000+ deliveries. She scripts and hosts ParentVeda's flagship guide in calm, plain language.", '3,000+ डिलीवरी का अनुभव रखने वाली वरिष्ठ obstetrician। ParentVeda की सबसे बड़ी guide वही लिखती और पेश करती हैं, शांत और सीधी भाषा में।'),
    title: _same('The Complete Pregnancy Guide'),
    subtitle: _t('Week 1 to the first cry - every stage, taught properly, once.', 'हफ़्ता 1 से पहली किलकारी तक — हर पड़ाव, ढंग से, एक बार में।'),
    topics: [_t('First Trimester', 'पहली तिमाही'), _t('Birth & Labour', 'जन्म और लेबर'), _t('Newborn', 'नवजात')],
    accent: _pViolet,
    price: '₹2,999',
    status: PrepStatus.available,
    durationLabel: _same('80+ lessons'),
    about:
        _t('A documentary-style course that unlocks as your pregnancy grows and stays yours for life. You only ever see the lessons for your current stage; earlier and later ones are a tap away. Told through ParentVeda\'s own animated guides, scripted from research and reviewed by obstetricians.', 'एक documentary जैसा course, जो आपकी गर्भावस्था के साथ खुलता जाता है और हमेशा के लिए आपका रहता है। आपको हर बार सिर्फ़ अपने मौजूदा पड़ाव के lessons दिखते हैं; पहले और बाद वाले एक tap दूर हैं। ParentVeda के अपने animated guides के ज़रिए, शोध से लिखे और obstetricians द्वारा जाँचे गए।'),
    rating: 4.9,
    reviewsLabel: _t('1,240 mothers', '1,240 माँएँ'),
    lessons: [
      PrepLesson(_t('Your third trimester, week by week', 'आपकी तीसरी तिमाही, हफ़्ते-दर-हफ़्ते'), 16),
      PrepLesson(_t('Reading your body\'s labour signals', 'अपने शरीर के लेबर के संकेत पढ़ना'), 18),
      PrepLesson(_t('Packing your hospital bag, calmly', 'अपना hospital bag, इत्मीनान से पैक करना'), 12),
      PrepLesson(_t('The first 48 hours with baby', 'शिशु के साथ पहले 48 घंटे'), 20, locked: true),
    ],
    covers: [
      _t('A month-by-month map of your whole pregnancy.', 'आपकी पूरी गर्भावस्था का महीने-दर-महीने नक़्शा।'),
      _t('What to expect - and prepare - at each stage.', 'हर पड़ाव पर क्या होने वाला है — और क्या तैयार रखना है।'),
      _t('The warning signs that genuinely need a call.', 'वे चेतावनी संकेत जिन पर सच में डॉक्टर को फ़ोन करना चाहिए।'),
      _t('A gentle on-ramp into the newborn weeks.', 'नवजात के हफ़्तों में एक सौम्य प्रवेश।'),
    ],
    reviews: [
      Review(_same('Sneha K.'), _t('28 weeks', '28 हफ़्ते'), _t('"The one place that told me what to actually do, stage by stage."', '"बस यही एक जगह थी जिसने बताया कि असल में करना क्या है, पड़ाव दर पड़ाव।"')),
    ],
    featured: true,
    recency: 100,
  ),
  PrepProgram(
    id: 'course_birthprep',
    kind: PrepKind.course,
    instructorName: _same('Meera Nair'),
    instructorRole: _same('Childbirth educator'),
    instructorBio: _t('A certified, OB-reviewed childbirth educator who has prepared thousands of mothers for the big day.', 'एक प्रमाणित, OB द्वारा जाँची गई childbirth educator, जिन्होंने हज़ारों माँओं को उस बड़े दिन के लिए तैयार किया है।'),
    title: _same('Birth Prep Essentials'),
    subtitle: _t('A calm, self-paced walkthrough of everything the big day asks of you.', 'उस बड़े दिन आपसे जो कुछ चाहिए, उसकी शांत जानकारी — अपनी रफ़्तार से।'),
    topics: [_t('Birth & Labour', 'जन्म और लेबर'), _t('Breathing', 'साँस')],
    accent: _pBlue,
    price: '₹1,499',
    status: PrepStatus.available,
    durationLabel: _same('6 lessons · ~90 min'),
    about:
        _t('The self-paced companion to our live Birthing Classes - the stages of labour, breathing and positions, pain-relief options and the golden hour, all in short lessons you can watch and rewatch at your own pace.', 'हमारी live Birthing Classes का अपनी रफ़्तार वाला साथी — लेबर के चरण, साँस और मुद्राएँ, दर्द से राहत के विकल्प और golden hour, सब छोटे lessons में, जिन्हें आप अपनी रफ़्तार से बार-बार देख सकती हैं।'),
    rating: 4.8,
    reviewsLabel: _t('910 mothers', '910 माँएँ'),
    lessons: [
      PrepLesson(_t('The stages of labour, demystified', 'लेबर के चरण, आसान भाषा में'), 22),
      PrepLesson(_t('Breathing & relaxation that works', 'साँस और आराम — जो काम आता है'), 18),
      PrepLesson(_t('Positions & movement for an easier labour', 'आसान लेबर के लिए मुद्राएँ और हलचल'), 20),
      PrepLesson(_t('Pain relief - natural, epidural & C-section', 'दर्द से राहत — normal, epidural और C-section'), 24, locked: true),
    ],
    covers: [
      _t('A clear, unhurried picture of each stage of labour.', 'लेबर के हर चरण की साफ़, इत्मीनान भरी तस्वीर।'),
      _t('Breathing you can actually use through a contraction.', 'वह साँस जो contraction के बीच सच में काम आती है।'),
      _t('The honest pros and cons of every pain-relief option.', 'दर्द से राहत के हर विकल्प के ईमानदार फ़ायदे और नुक़सान।'),
      _t('What really happens in the golden first hour.', 'उस सुनहरे पहले घंटे में असल में क्या होता है।'),
    ],
    recency: 92,
  ),
  PrepProgram(
    id: 'course_trimester_fit',
    kind: PrepKind.course,
    instructorName: _same('Sana Kapoor'),
    instructorRole: _same('Certified prenatal instructor'),
    instructorBio: _t('A certified prenatal fitness instructor whose sessions are scaled safely to every trimester.', 'एक प्रमाणित prenatal fitness instructor, जिनके sessions हर तिमाही के हिसाब से सुरक्षित ढंग से ढाले जाते हैं।'),
    title: _same('Trimester-Safe Fitness'),
    subtitle: _t('Feel strong through pregnancy with movement scaled to your stage.', 'अपने पड़ाव के हिसाब से ढली हलचल के साथ पूरी गर्भावस्था मज़बूत महसूस करें।'),
    topics: [_same('Fitness')],
    accent: _pTeal,
    price: '₹1,299',
    status: PrepStatus.available,
    durationLabel: _same('5 lessons · ~60 min'),
    about:
        _t('A short, practical course on staying safely strong and mobile through pregnancy - what to do, what to skip, and how to scale everything to how you feel that day.', 'गर्भावस्था भर सुरक्षित ढंग से मज़बूत और चलती-फिरती रहने पर एक छोटा, काम का course — क्या करें, क्या छोड़ें, और उस दिन के मिज़ाज के हिसाब से सब कैसे ढालें।'),
    rating: 4.8,
    reviewsLabel: _t('540 mothers', '540 माँएँ'),
    lessons: [
      PrepLesson(_t('Safe strength, trimester by trimester', 'सुरक्षित मज़बूती, तिमाही दर तिमाही'), 14),
      PrepLesson(_t('Mobility for a changing body', 'बदलते शरीर के लिए लचक'), 12),
      PrepLesson(_t('Core & pelvic floor, done right', 'Core और pelvic floor, सही तरीक़े से'), 16),
      PrepLesson(_t('Rest, recovery and warning signs', 'आराम, रिकवरी और चेतावनी के संकेत'), 10),
    ],
    covers: [
      _t('What movement is safe - and what to skip - each trimester.', 'हर तिमाही में कौन-सी हलचल सुरक्षित है — और क्या छोड़ देना है।'),
      _t('Core and pelvic-floor work that helps birth and recovery.', 'Core और pelvic-floor का वह अभ्यास जो जन्म और रिकवरी में मदद करता है।'),
      _t('How to scale everything to your energy that day.', 'उस दिन की अपनी ऊर्जा के हिसाब से सब कुछ कैसे ढालें।'),
    ],
    recency: 84,
  ),
];

// ---- per-item mapping meta (topics/accent/status the old models don't carry) -
final Map<String,
        ({List<LocalizedText> topics, Color accent, PrepStatus status,
          bool live, int recency})> _mcMeta = {
  'mc_birth': (topics: [_t('Birth & Labour', 'जन्म और लेबर'), _t('Breathing', 'साँस')], accent: _pRose, status: PrepStatus.reserveOpen, live: true, recency: 99),
  'mc_first100': (topics: [_t('Newborn', 'नवजात')], accent: _pAmber, status: PrepStatus.reserveOpen, live: true, recency: 82),
  'mc_bf': (topics: [_t('Breastfeeding', 'स्तनपान'), _t('Newborn', 'नवजात')], accent: _pTeal, status: PrepStatus.reserveOpen, live: true, recency: 80),
  'mc_playbook': (topics: [_t('First Trimester', 'पहली तिमाही')], accent: _pViolet, status: PrepStatus.available, live: false, recency: 70),
};

final Map<String,
        ({List<LocalizedText> topics, Color accent, PrepStatus status,
          int seatsLeft, int recency})> _chMeta = {
  'ch_birthready': (topics: [_t('Birth & Labour', 'जन्म और लेबर'), _t('Breathing', 'साँस')], accent: _pBlue, status: PrepStatus.reserveOpen, seatsLeft: 32, recency: 98),
  'ch_first_tri': (topics: [_t('First Trimester', 'पहली तिमाही')], accent: _pAmber, status: PrepStatus.reserveOpen, seatsLeft: 14, recency: 74),
  'ch_fit': (topics: [_same('Fitness')], accent: _pTeal, status: PrepStatus.reserveOpen, seatsLeft: 20, recency: 66),
  'ch_fourth_tri': (topics: [_t('Newborn', 'नवजात'), _t('Breastfeeding', 'स्तनपान')], accent: _pPlum, status: PrepStatus.reserveOpen, seatsLeft: 18, recency: 60),
};

PrepProgram _fromMasterclass(Masterclass m) {
  final meta = _mcMeta[m.id]!;
  final coach = m.coaches.isNotEmpty ? m.coaches.first : Coach(_t('Your expert', 'आपकी विशेषज्ञ'), _t('ParentVeda expert', 'ParentVeda विशेषज्ञ'), _same(''));
  final when = m.facts.length >= 2
      ? LocalizedText(
          en: '${m.facts[1].big.en} · ${m.facts[1].small.en}',
          hi: '${m.facts[1].big.hi} · ${m.facts[1].small.hi}')
      : null;
  final duration = m.facts.isNotEmpty
      ? LocalizedText(
          en: '${m.facts.first.big.en} ${m.facts.first.small.en}',
          hi: '${m.facts.first.big.hi} ${m.facts.first.small.hi}')
      : const LocalizedText(en: '', hi: '');
  return PrepProgram(
    id: 'prog_${m.id}',
    kind: PrepKind.masterclass,
    instructorName: coach.name,
    instructorRole: coach.role,
    instructorBio: coach.bio,
    title: m.title,
    subtitle: m.listDesc,
    topics: meta.topics,
    accent: meta.accent,
    price: m.price,
    status: meta.status,
    isLiveScheduled: meta.live,
    startLabel: meta.live && when != null ? _same('LIVE · $when') : null,
    sessionTimes: meta.live && when != null ? [when] : const [],
    sessions: meta.live
        ? [
            PrepSession(
              label: _t('Live evening', 'Live शाम'),
              title: _t('One focused sitting + live Q&A', 'एक केंद्रित बैठक + live Q&A'),
              when: when ?? const LocalizedText(en: '', hi: ''),
              points: m.learn.take(3).toList(),
            ),
          ]
        : const [],
    durationLabel: duration,
    about: m.longDesc,
    rating: 4.9,
    reviewsLabel: _t('${(m.testimonials.length + 3) * 210} mothers', '${(m.testimonials.length + 3) * 210} माँएँ'),
    covers: m.learn,
    reviews: m.testimonials.map((t) => Review(t.who, t.when, t.quote)).toList(),
    featured: m.featured,
    recency: meta.recency,
  );
}

PrepProgram _fromCohort(Cohort c) {
  final meta = _chMeta[c.id]!;
  return PrepProgram(
    id: 'prog_${c.id}',
    kind: PrepKind.cohort,
    instructorName: c.coachName ?? _t('Your coach', 'आपकी कोच'),
    instructorRole: _same('Childbirth educator'),
    instructorBio: _t('Leads every live session and the private group.', 'हर live session और private group वही चलाती हैं।'),
    title: c.name,
    subtitle: c.desc,
    topics: meta.topics,
    accent: meta.accent,
    price: c.price,
    priceNote: _t('or ParentVeda+', 'या ParentVeda+'),
    status: meta.status,
    startLabel: c.start ?? c.forWhen,
    seatsLeft: meta.seatsLeft,
    sessionTimes: const [],
    sessions: [
      for (int i = 0; i < c.schedule.length; i++)
        // The prefix is stripped in EACH language separately. The old
        // single RegExp only matched English, so a translated schedule
        // would have kept showing 'हफ़्ता 1 · ' inside a row already
        // labelled 'हफ़्ता 1'.
        PrepSession(
            label: _t('Week ${i + 1}', 'हफ़्ता ${i + 1}'),
            title: LocalizedText(
              en: c.schedule[i].en.replaceFirst(_kWeekPrefixEn, ''),
              hi: c.schedule[i].hi.replaceFirst(_kWeekPrefixHi, ''),
            )),
    ],
    durationLabel: _same('${c.duration} · live'),
    about: c.desc,
    rating: 4.9,
    reviewsLabel: _t('${meta.seatsLeft * 20} mothers', '${meta.seatsLeft * 20} माँएँ'),
    covers: c.whatsInside,
    takeaways: c.whatsInside,
    reviews: c.reviews,
    featured: c.featured,
    recency: meta.recency,
  );
}

/// The full unified catalogue, built once from courses + masterclasses + cohorts.
final List<PrepProgram> kPrepPrograms = <PrepProgram>[
  ..._kPrepCourses,
  for (final m in kMasterclasses)
    if (_mcMeta.containsKey(m.id)) _fromMasterclass(m),
  for (final c in kCohorts)
    if (_chMeta.containsKey(c.id)) _fromCohort(c),
];

/// The catalogue in display order (featured first, then by recency).
List<PrepProgram> prepCatalogue() {
  final list = [...kPrepPrograms];
  list.sort((a, b) {
    if (a.featured != b.featured) return a.featured ? -1 : 1;
    return b.recency.compareTo(a.recency);
  });
  return list;
}

/// Filter the catalogue by an optional kind, topic and free-text query.
List<PrepProgram> filterPrograms({PrepKind? kind, String? topic, String? query}) {
  final q = (query ?? '').trim().toLowerCase();
  return prepCatalogue().where((p) {
    if (kind != null && p.kind != kind) return false;
    // .en: `topic` is a filter KEY. Comparing the rendered label would
    // make every filter silently match nothing in Hindi.
    if (topic != null && !p.topics.any((t) => t.en == topic)) return false;
    if (q.isNotEmpty) {
      // Search both languages, as elsewhere: she may type an English
      // title while reading in Hindi, or the reverse.
      final hay = [
        p.title.en, p.title.hi,
        p.subtitle.en, p.subtitle.hi,
        p.instructorName.en,
        for (final t in p.topics) ...[t.en, t.hi],
      ].join(' ').toLowerCase();
      if (!hay.contains(q)) return false;
    }
    return true;
  }).toList();
}

PrepProgram? programById(String id) {
  for (final p in kPrepPrograms) {
    if (p.id == id) return p;
  }
  return null;
}

// =============================================================================
//  Nutrition funnel - Assessment -> Recommended plans -> Trailer -> Book ->
//  Expert Consultation -> Personalized Diet Plan. Data for the plan cards and
//  the assessment options. Real plans/backends don't exist yet, so these are
//  tasteful placeholders that make the whole click-through work end to end.
// =============================================================================

/// One assessment answer option (a selectable chip).
class NutriOption {
  const NutriOption(this.id, this.label);
  final String id;
  final LocalizedText label;
}

final List<NutriOption> kNutriTrimesters = [
  NutriOption('t1', _t('First trimester', 'पहली तिमाही')),
  NutriOption('t2', _t('Second trimester', 'दूसरी तिमाही')),
  NutriOption('t3', _t('Third trimester', 'तीसरी तिमाही')),
];

final List<NutriOption> kNutriGoals = [
  NutriOption('nausea', _t('Manage nausea', 'मतली संभालना')),
  NutriOption('gd', _same('Gestational diabetes')),
  NutriOption('weight', _t('Healthy weight gain', 'सेहतमंद वज़न बढ़ना')),
  NutriOption('energy', _t('More energy', 'ज़्यादा ऊर्जा')),
  NutriOption('growth', _t("Baby's growth", 'शिशु की बढ़त')),
];

final List<NutriOption> kNutriDiets = [
  NutriOption('veg', _t('Vegetarian', 'शाकाहारी')),
  NutriOption('nonveg', _t('Non-vegetarian', 'मांसाहारी')),
  NutriOption('egg', _t('Eggetarian', 'अंडा खाने वाली')),
  NutriOption('vegan', _same('Vegan')),
];

class NutritionPlan {
  const NutritionPlan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.forGoals,
    required this.accent,
    required this.weeks,
    required this.highlights,
    required this.sampleDay,
    this.price = '₹1,499',
    // const, not _t(): a default parameter value must be a constant
    // expression, and Dart has no const functions.
    this.priceNote = const LocalizedText(
        en: 'free on ParentVeda+', hi: 'ParentVeda+ पर मुफ़्त'),
  });

  final String id;
  final LocalizedText name;
  final LocalizedText tagline;
  final List<String> forGoals; // NutriOption goal ids this plan best suits
  final Color accent;
  final LocalizedText weeks; // "4-week plan"
  final List<LocalizedText> highlights;
  final List<({LocalizedText meal, LocalizedText food})> sampleDay;
  final String price;
  final LocalizedText priceNote;
}

final List<NutritionPlan> kNutritionPlans = [
  NutritionPlan(
    id: 'plan_settle',
    name: _same('Settle & Nourish'),
    tagline: _t('Gentle, tummy-friendly eating for queasy days.', 'मतली वाले दिनों के लिए सौम्य, पेट को रास आने वाला खाना।'),
    forGoals: ['nausea', 'energy'],
    accent: _pAmber,
    weeks: _t('4-week plan', '4 हफ़्ते का plan'),
    highlights: [
      _t('Small, frequent meals that calm nausea', 'छोटे-छोटे, बार-बार खाने जो मतली शांत करें'),
      _t('Iron and folate without the heaviness', 'Iron और Folate, बिना भारीपन के'),
      _t('Desi swaps for when nothing appeals', 'जब कुछ अच्छा न लगे, तब के देसी बदल'),
    ],
    sampleDay: [
      (meal: _t('Early morning', 'सुबह उठते ही'), food: _t('Soaked almonds + a dry toast', 'भीगे बादाम + एक सूखा toast')),
      (meal: _t('Breakfast', 'नाश्ता'), food: _t('Vegetable poha with lemon', 'सब्ज़ियों वाला पोहा, नींबू के साथ')),
      (meal: _t('Lunch', 'दोपहर का खाना'), food: _t('Khichdi with curd and a little ghee', 'खिचड़ी, दही और थोड़े घी के साथ')),
      (meal: _t('Evening', 'शाम'), food: _t('Coconut water + roasted makhana', 'नारियल पानी + भुना मखाना')),
      (meal: _t('Dinner', 'रात का खाना'), food: _t('Moong dal, soft rice, steamed veg', 'मूँग दाल, नरम चावल, भाप में पकी सब्ज़ी')),
    ],
  ),
  NutritionPlan(
    id: 'plan_balance',
    name: _same('Balanced Bump'),
    tagline: _t('Steady energy and healthy weight gain, Indian-first.', 'ठहरी हुई ऊर्जा और सेहतमंद वज़न, भारतीय खाने के साथ।'),
    forGoals: ['weight', 'energy', 'growth'],
    accent: _pViolet,
    weeks: _t('6-week plan', '6 हफ़्ते का plan'),
    highlights: [
      _t('Balanced macros built around Indian meals', 'भारतीय खाने पर बना संतुलित पोषण'),
      _t('Protein at every meal for baby\'s growth', 'शिशु की बढ़त के लिए हर खाने में Protein'),
      _t('Smart snacks that keep energy even', 'ऐसे snacks जो ऊर्जा एक-सी बनाए रखें'),
    ],
    sampleDay: [
      (meal: _t('Breakfast', 'नाश्ता'), food: _t('Besan chilla + curd + fruit', 'बेसन चीला + दही + फल')),
      (meal: _t('Mid-morning', 'दिन चढ़े'), food: _t('A fruit + a handful of nuts', 'एक फल + मुट्ठी भर मेवे')),
      (meal: _t('Lunch', 'दोपहर का खाना'), food: _t('2 rotis, dal, sabzi, salad, curd', '2 रोटी, दाल, सब्ज़ी, सलाद, दही')),
      (meal: _t('Evening', 'शाम'), food: _t('Sprouts chaat or paneer tikka', 'स्प्राउट्स चाट या पनीर टिक्का')),
      (meal: _t('Dinner', 'रात का खाना'), food: _t('Rice/roti, rajma, greens', 'चावल/रोटी, राजमा, हरी सब्ज़ी')),
    ],
  ),
  NutritionPlan(
    id: 'plan_sugar',
    name: _same('Sugar-Smart'),
    tagline: _t('Gestational-diabetes-friendly eating that still tastes like home.', 'Gestational diabetes के हिसाब से खाना, जिसका स्वाद फिर भी घर जैसा हो।'),
    forGoals: ['gd', 'weight'],
    accent: _pTeal,
    weeks: _t('8-week plan', '8 हफ़्ते का plan'),
    highlights: [
      _t('Low-GI meals that keep sugars steady', 'Low-GI खाना जो शुगर एक-सी रखे'),
      _t('Portion and pairing rules made simple', 'कितना और किसके साथ खाएँ — आसान नियम'),
      _t('Sweet cravings handled the smart way', 'मीठे की तलब, समझदारी से संभाली'),
    ],
    sampleDay: [
      (meal: _t('Breakfast', 'नाश्ता'), food: _t('Vegetable oats + boiled egg / paneer', 'सब्ज़ियों वाला oats + उबला अंडा / पनीर')),
      (meal: _t('Mid-morning', 'दिन चढ़े'), food: _t('A small guava or apple', 'एक छोटा अमरूद या सेब')),
      (meal: _t('Lunch', 'दोपहर का खाना'), food: _t('Millet roti, dal, lots of sabzi, salad', 'मोटे अनाज की रोटी, दाल, ख़ूब सब्ज़ी, सलाद')),
      (meal: _t('Evening', 'शाम'), food: _t('Buttermilk + roasted chana', 'छाछ + भुना चना')),
      (meal: _t('Dinner', 'रात का खाना'), food: _t('Grilled paneer/chicken + veg, no rice', 'ग्रिल्ड पनीर/चिकन + सब्ज़ी, चावल नहीं')),
    ],
  ),
];

/// Recommend plans for the chosen goal (falls back to all). Simple placeholder
/// scoring - a real engine would weigh trimester, diet and history too.
List<NutritionPlan> recommendPlans({String? goalId}) {
  if (goalId == null) return kNutritionPlans;
  final matched = kNutritionPlans.where((p) => p.forGoals.contains(goalId)).toList();
  return matched.isEmpty ? kNutritionPlans : matched;
}
