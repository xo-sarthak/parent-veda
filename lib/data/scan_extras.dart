// =============================================================================
//  Scan extras — the three things the scan library does not carry
// -----------------------------------------------------------------------------
//  `kTestsScans` is rich: what a scan is, why, when, preparation, procedure, the
//  parameters on the report, how to read it. It is missing exactly three things,
//  and each one is a question a mother in India asks out loud.
//
//  ---------------------------------------------------------------------------
//  1. WHAT IT COSTS
//  ---------------------------------------------------------------------------
//  Nobody in this market answers this honestly, and it is the single most-asked
//  practical question about a scan. A range, not a price: the same scan is
//  ₹1,200 in a standalone lab in a tier-2 city and ₹4,500 in a corporate
//  hospital in Mumbai, and quoting one number would be wrong for almost
//  everyone.
//
//  ⚠️ THESE ARE PUBLIC PRICE RANGES, NOT A QUOTE, and the copy says so. They
//  exist to stop her being surprised at the counter and to let her recognise
//  being overcharged — that is the whole job.
//
//  ---------------------------------------------------------------------------
//  2. WHAT THEY CANNOT TELL YOU  ← the most India-specific line in the product
//  ---------------------------------------------------------------------------
//  Sex determination is illegal in India under the PCPNDT Act, 1994. The
//  sonographer will refuse — sometimes with a sign on the wall, sometimes
//  brusquely, occasionally in a way that sounds like an accusation.
//
//  **If we have not told her beforehand, she reads that refusal as something
//  being hidden about her baby.** That is the failure this line prevents, and it
//  is worth stating plainly: the law exists because sex-selective abortion
//  killed millions of girls, so the refusal is the system working, not the
//  clinic being difficult.
//
//  One sentence, calm, on every scan page, BEFORE the day. No imported design
//  will ever contain this, because no design tool knows the Act exists.
//
//  ---------------------------------------------------------------------------
//  3. WHEN TO CALL BEFORE YOUR NEXT APPOINTMENT
//  ---------------------------------------------------------------------------
//  Per scan, because the red flags after a dating scan and after a growth scan
//  are not the same list. `kFindings.whenToContact` covers findings; this covers
//  the SCAN.
//
//  ⚠️ Nothing here is a diagnosis and nothing here is a threshold. Every line is
//  an instruction to contact a human, which is the only safe output.
// =============================================================================

import '../localization/app_language.dart';

/// What a scan usually costs, as a public range.
class ScanCost {
  const ScanCost({required this.low, required this.high, this.note});

  /// Rupees. Rendered as "₹low – ₹high".
  final int low;
  final int high;

  /// Anything that changes the number — "free at a government hospital",
  /// "usually bundled with the anomaly scan".
  final LocalizedText? note;
}

/// Public price ranges, India, private labs and hospitals.
///
/// ⚠️ REVIEW THESE BEFORE LAUNCH. They are researched public ranges, not a
/// negotiated rate card, and prices move. A wrong number here is worse than no
/// number, because she will quote it at a counter.
const Map<String, ScanCost> kScanCost = {
  'blood_tests': ScanCost(
      low: 800,
      high: 3000,
      note: LocalizedText(
          en: 'The first-visit panel together. Free at most government '
              'hospitals under the national programme.',
          hi: 'पहली विज़िट का पूरा panel साथ में। ज़्यादातर सरकारी अस्पतालों में '
              'राष्ट्रीय कार्यक्रम के तहत मुफ़्त।')),
  'dating_scan': ScanCost(low: 800, high: 2500),
  'nt_scan': ScanCost(
      low: 1500,
      high: 4000,
      note: LocalizedText(
          en: 'Often quoted together with the double marker blood test.',
          hi: 'अक्सर double marker blood test के साथ मिलाकर बताया जाता है।')),
  'nipt': ScanCost(
      low: 11000,
      high: 25000,
      note: LocalizedText(
          en: 'The most expensive test in pregnancy, and optional. It is a '
              'screening test, not a diagnosis.',
          hi: 'गर्भावस्था का सबसे महँगा test, और यह वैकल्पिक है। यह screening है, '
              'निदान नहीं।')),
  'anomaly_scan': ScanCost(
      low: 2000,
      high: 5000,
      note: LocalizedText(
          en: 'Takes the longest of all the scans, so the price reflects the '
              'time as much as the machine.',
          hi: 'सभी scans में सबसे लंबा, तो क़ीमत मशीन जितनी ही समय की भी है।')),
  'ogtt': ScanCost(low: 400, high: 1200),
  'growth_scan': ScanCost(low: 1200, high: 3000),
  'doppler': ScanCost(
      low: 1500,
      high: 3500,
      note: LocalizedText(
          en: 'Usually done together with a growth scan and billed as one.',
          hi: 'आम तौर पर growth scan के साथ ही होता है और एक ही बिल बनता है।')),
  'gbs': ScanCost(low: 600, high: 1800),
};

/// The PCPNDT line. One string, shown on every scan page.
///
/// ⚠️ DO NOT REWRITE THIS TO BE SHORTER. Each clause is doing a job: it names
/// the law so she knows it is not the clinic's choice, it warns her that the
/// refusal may be blunt so she is not hurt by it, and it says why the law
/// exists so the refusal reads as protection rather than obstruction.
const LocalizedText kPcpndtLine = LocalizedText(
  en: "They will not tell you the baby's sex, and they are not allowed to — "
      'the PCPNDT Act makes it illegal anywhere in India. Some sonographers '
      'say so bluntly, and there is often a sign on the wall. It is not about '
      'you. The law exists because sex-selective abortion cost this country '
      'millions of daughters.',
  hi: 'वे आपको बच्चे का लिंग नहीं बताएँगे, और बता भी नहीं सकते — PCPNDT Act के '
      'तहत यह पूरे भारत में ग़ैरक़ानूनी है। कई sonographer सीधे मना कर देते हैं, '
      'और दीवार पर बोर्ड भी लगा होता है। यह आप पर शक नहीं है। यह क़ानून इसलिए है '
      'क्योंकि लिंग-चयन ने इस देश की लाखों बेटियाँ छीन लीं।',
);

/// Per-scan red flags — "call before your next appointment".
///
/// Empty list = nothing specific to this scan beyond the general ones, which is
/// an honest answer and renders no section.
const Map<String, List<LocalizedText>> kScanRedFlags = {
  'dating_scan': [
    _RF(
        'Bleeding, or pain low down on one side — especially if the scan could '
        'not yet see the pregnancy in the womb.',
        'ख़ून आना, या नीचे एक तरफ़ दर्द — ख़ासकर अगर scan में गर्भ अभी गर्भाशय में '
            'दिखा ही न हो।'),
  ],
  'nt_scan': [
    _RF('Any bleeding in the days after the scan.',
        'scan के बाद के दिनों में किसी भी तरह का ख़ून आना।'),
  ],
  'anomaly_scan': [
    _RF('Fluid leaking, steady bleeding, or a tight painful belly.',
        'पानी जाना, लगातार ख़ून आना, या पेट का कसकर दर्द करना।'),
    _RF(
        'If they mentioned the placenta is low, note it — it changes what to '
        'watch for, and it usually moves up by the third trimester.',
        'अगर उन्होंने placenta नीचे होने की बात कही हो तो याद रखिए — इससे ध्यान '
            'रखने वाली बातें बदल जाती हैं, और आम तौर पर तीसरी तिमाही तक वह ऊपर '
            'चला जाता है।'),
  ],
  'growth_scan': [
    _RF('The baby moving noticeably less than usual, on any day.',
        'किसी भी दिन बच्चे का रोज़ से काफ़ी कम हिलना-डुलना।'),
  ],
  'doppler': [
    _RF('Reduced movements, or a headache with blurred vision or swelling.',
        'हलचल कम होना, या सिरदर्द के साथ धुँधला दिखना या सूजन।'),
  ],
  'ogtt': [
    _RF('Feeling faint, shaky or very unwell during the test itself — tell the '
        'lab staff at once rather than finishing it.',
        'test के दौरान ही चक्कर, कँपकँपी या बहुत तबीयत ख़राब लगना — test पूरा '
            'करने की बजाय तुरंत lab के स्टाफ़ को बताइए।'),
  ],
};

/// The general red flags — the ones that do not belong to a scan.
///
/// ⚠️ ORDER IS DELIBERATE. Shoulder-tip pain is third and not last: it is the
/// classic sign of a ruptured ectopic pregnancy, it sounds like nothing, and it
/// is the one on this list a mother would otherwise ignore. ~74,000 people a
/// month search "ectopic".
const List<LocalizedText> kScanUrgentSigns = [
  _RF('Bleeding — more than spotting, or with clots.',
      'ख़ून आना — हल्के दाग़ से ज़्यादा, या थक्कों के साथ।'),
  _RF('Sharp pain low down on one side that does not ease.',
      'नीचे एक तरफ़ तेज़ दर्द जो कम नहीं हो रहा।'),
  _RF('Pain at the tip of your shoulder, with belly pain or feeling faint.',
      'कंधे के सिरे पर दर्द, साथ में पेट दर्द या चक्कर।'),
  _RF('Fluid leaking, or a gush of water.',
      'पानी रिसना, या एकदम से पानी जाना।'),
  _RF('The baby moving much less than usual.',
      'बच्चे का रोज़ से बहुत कम हिलना।'),
  _RF('A bad headache with blurred vision, or sudden swelling of face and hands.',
      'तेज़ सिरदर्द के साथ धुँधला दिखना, या चेहरे और हाथों में अचानक सूजन।'),
  _RF('Fever above 38°C, or burning that makes you dread passing urine.',
      '38°C से ऊपर बुख़ार, या पेशाब में इतनी जलन कि जाने से डर लगे।'),
];

/// `const` constructor alias so the maps above stay const.
// ignore: camel_case_types
class _RF extends LocalizedText {
  const _RF(String en, String hi) : super(en: en, hi: hi);
}
